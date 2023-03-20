// TestInterceptors.swift
//
// Copyright © 2018-2023 Vassilis Panagiotopoulos. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in the
// Software without restriction, including without limitation the rights to use, copy,
// modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
// and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies
// or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FIESS FOR A PARTICULAR
// PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import XCTest
import TermiNetwork

class TestInterceptors: XCTestCase {
    lazy var client: Client<TestRepository> = {
        let configuration = Configuration()
        configuration.interceptors = [GlobalInterceptor.self]
        configuration.verbose = true
        return Client<TestRepository>(configuration: configuration)
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Environment.set(Env.termiNetworkRemote)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInterceptorContinue() {
        Environment.set(Env.termiNetworkRemote)

        let expectation = XCTestExpectation(description: "testInterceptorContinue")
        var failed = true

        client.request(for: .testPostParams(value1: false,
                                            value2: 1,
                                            value3: 2,
                                            value4: "",
                                            value5: nil))
            .success(responseType: TestJSONParams.self) { response in
                failed = !(response.param3 == 2)
                expectation.fulfill()
            }
            .failure { _ in
                failed = true
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testInterceptorRetry() {
        Environment.set(Env.invalidHost)

        let expectation = XCTestExpectation(description: "testInterceptorRetry")
        var failed = true

        client.request(for: .testPostParams(value1: false,
                                            value2: 1,
                                            value3: 2,
                                            value4: "",
                                            value5: nil))
            .success(responseType: TestJSONParams.self) { response in
                failed = !(response.param3 == 2)
                expectation.fulfill()
            }
            .failure { error in
                print(error)
                failed = true
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 120)

        XCTAssert(!failed)
    }

    func testInterceptorRetryFileUpload() {
        Environment.set(Env.invalidHost)

        let expectation = XCTestExpectation(description: "testInterceptorRetry")
        var failed = true

        guard let url = Bundle(for: TestUploadOperations.self).url(forResource: "photo",
                                                                   withExtension: "jpg") else {
            XCTAssert(false)
            return
        }

        let checksum = TestHelpers.sha256(url: url)
        var progressSucceded = false
        var successCount = 0

        client.request(for: .fileUpload(url: url, param: "test"))
            .upload(responseType: FileResponse.self,
                    progressUpdate: { bytesSent, totalBytes, progress in
                        if bytesSent == totalBytes && progress == 1 {
                            progressSucceded = true
                        }
                    },
                    responseHandler: { response in
                        if response.success && response.checksum == checksum {
                            successCount  += 1
                        }
                        failed = !progressSucceded
                        expectation.fulfill()
                    })
            .failure { _ in
                failed = true
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 120)

        XCTAssert(!failed)
    }

    func testInterceptorRetryFileDownload() {
        Environment.set(Env.invalidHost)

        let expectation = XCTestExpectation(description: "testInterceptorRetryFileDownload")

        var failed = true

        guard var cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            XCTAssert(false)
            return
        }
        cacheURL.appendPathComponent("testDownload")

        try? FileManager.default.removeItem(at: cacheURL)

        client.request(for: .fileDownload)
            .download(destinationPath: cacheURL.path,
                      progressUpdate: { bytesSent, totalBytes, progress in
                        if bytesSent == totalBytes && progress == 1 {
                            failed = false
                        }
                    }, completionHandler: {
                        failed = TestHelpers.sha256(url: cacheURL) !=
                            "63b54b4506e233839f55e1228b59a1fcdec7d5ff9c13073c8a1faf92e9dcc977"

                        expectation.fulfill()
                    })
            .failure { error in
                failed = true
                print(String(describing: error.localizedDescription))
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 500)

        XCTAssert(!failed)
    }

    func testMultipleInterceptors() {
        Environment.set(Env.termiNetworkLocal)

        let expectation = XCTestExpectation(description: "testMultipleInterceptors")
        var failed = true

        client.configuration?.interceptors?.append(DoNothingInterceptor.self)
        client.configuration?.cachePolicy = .reloadIgnoringLocalCacheData

        let request = client.request(for: .testPostParams(value1: false,
                                                          value2: 1,
                                                          value3: 2,
                                                          value4: "",
                                                          value5: nil))

        request.success(responseType: TestJSONParams.self) { response in
            failed = !(response.param3 == 2 &&
                        (request.associatedObject as? NSNumber)?.boolValue == true)
            expectation.fulfill()
        }
        .failure { _ in
            failed = true
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        client.configuration?.interceptors?.removeLast()

        XCTAssert(!failed)
    }

    func testUnauthorizedInterceptor() {
        Environment.set(Env.termiNetworkRemote)

        let expectation = XCTestExpectation(description: "testUnauthorizedInterceptor")
        var failed = true

        client.configuration?.interceptors = [UnauthorizedInterceptor.self]
        client.configuration?.cachePolicy = .reloadIgnoringLocalCacheData

        let authValue = UnauthorizedInterceptor.authorizationValue
        let request = client.request(for: .testStatusCode(code: 401))
        request.success(responseType: Data.self) { _ in
            let dummyRequest = try? self.client.request(for: .testStatusCode(code: 200)).asRequest()
            failed = !(
                Environment.current.configuration?.headers?["Authorization"] == authValue &&
                    request.headers?["Authorization"] == authValue  &&
                    dummyRequest?.allHTTPHeaderFields?["Authorization"] == authValue
            )

            expectation.fulfill()
        }
        .failure { _ in
            failed = true
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 180)

        client.configuration?.interceptors?.removeLast()

        XCTAssert(!failed)
    }
}
