// TestUploadOperations.swift
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

class TestUploadOperations: XCTestCase {
    lazy var configuration: Configuration = {
        return Configuration(cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                               verbose: true)
    }()

    lazy var client: Client<TestRepository> = {
        return .init(environment: Env.termiNetworkRemote,
                     configuration: configuration)
    }()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDataUpload() {
        let expectation = XCTestExpectation(description: "testDataUpload")
        var failed = true
        var completed = false

        guard let filePath = Bundle(for: TestUploadOperations.self).path(forResource: "photo",
                                                                         ofType: "jpg"),
        let uploadData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            XCTAssert(false)
            return
        }

        let checksum = TestHelpers.sha256(url: URL(fileURLWithPath: filePath))

        client.request(for: .dataUpload(data: uploadData, param: "bhbbrbrbrhbh"))
            .upload(progressUpdate: { bytesSent, totalBytes, progress in
                completed = bytesSent == totalBytes && progress == 1
            })
            .success(responseType: FileResponse.self) { response in
                failed = !(response.success &&
                           response.checksum == checksum &&
                           response.param == "bhbbrbrbrhbh")
                expectation.fulfill()
            }
            .failure { error in
                print(String(describing: error.localizedDescription))
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 30)

        XCTAssert(!failed && completed)
    }

    func testDataUploadWithTransformer() {
        let expectation = XCTestExpectation(description: "testDataUploadWithTransformer")
        var failed = true
        var completed = false

        guard let filePath = Bundle(for: TestUploadOperations.self).path(forResource: "photo",
                                                                         ofType: "jpg"),
        let uploadData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            assert(false)
        }

        let checksum = TestHelpers.sha256(url: URL(fileURLWithPath: filePath))

        client.request(for: .dataUpload(data: uploadData, param: "bhbbrbrbrhbh"))
            .upload(progressUpdate: { bytesSent, totalBytes, progress in
                completed = bytesSent == totalBytes && progress == 1
            })
            .success(transformer: TestUploadTransformer.self) { response in
                failed = !(response.value == checksum && response.param == "bhbbrbrbrhbh")
                expectation.fulfill()
            }
            .failure { error in
                print(String(describing: error.localizedDescription))
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 30)

        XCTAssert(!failed && completed)
    }

    func testFileUpload() {
        let expectation = XCTestExpectation(description: "testFileUpload")
        guard let url = Bundle(for: TestUploadOperations.self).url(forResource: "photo",
                                                                   withExtension: "jpg") else {
            XCTAssert(false)
            return
        }

        let checksum = TestHelpers.sha256(url: url)
        var progressSuccessCount = 0
        var successCount = 0
        let iterations = 1

        let queue = Queue(failureMode: .cancelAll)
        queue.maxConcurrentOperationCount = 1

        for _ in 0..<iterations {
            client.request(for: .fileUpload(url: url, param: "bhbbrbrbrhbh"))
                .queue(queue)
                .upload(progressUpdate: { bytesSent, totalBytes, progress in
                    if bytesSent == totalBytes && progress == 1 {
                        progressSuccessCount += 1
                    }
                })
                .success(responseType: FileResponse.self) { response in
                    if response.success && response.checksum == checksum {
                        successCount  += 1
                    }
                    if progressSuccessCount == iterations {
                        expectation.fulfill()
                    }
                }
                .failure { error in
                    print(String(describing: error.localizedDescription))
                    expectation.fulfill()
                }
        }

        wait(for: [expectation], timeout: 500)

        XCTAssert(successCount == iterations && progressSuccessCount == iterations)
    }

    func testRandomFileUpload() {
        let expectation = XCTestExpectation(description: "testRandomFileUpload")

        var progressSuccessCount = 0
        var successCount = 0
        let iterations = 12

        let queue = Queue(failureMode: .cancelAll)
        queue.maxConcurrentOperationCount = 1

        let urls = (0..<iterations).map { TestHelpers.createDummyFile(String($0)) }
        let checksums = urls.map { TestHelpers.sha256(url: $0!) }
        client.configuration?.timeoutInterval = 600

        for key in 0..<iterations {
            client.request(for: .fileUpload(url: urls[key]!, param: "bhbbrbrbrhbh"))
                .queue(queue)
                .upload(progressUpdate: { bytesSent, totalBytes, progress in
                    if bytesSent == totalBytes && progress == 1 {
                        progressSuccessCount += 1
                    }
                })
                .success(responseType: FileResponse.self) { response in
                    if response.success && response.checksum == checksums[key] {
                        successCount  += 1
                    } else {
                        XCTAssert(false, "Files not match!")
                    }
                    try? FileManager.default.removeItem(at: urls[key]!)
                    if progressSuccessCount == iterations {
                        expectation.fulfill()
                    }
                }
                .failure { error in
                    print(String(describing: error.localizedDescription))
                    try? FileManager.default.removeItem(at: urls[key]!)
                    expectation.fulfill()
                }
        }

        wait(for: [expectation], timeout: 500)

        XCTAssert(successCount == iterations && progressSuccessCount == iterations)
    }

    func testInvalidFileUrlUpload() {
        let expectation = XCTestExpectation(description: "testInvalidFileUrlUpload")
        var failed: Bool = false

        client.request(for: .fileUpload(url: URL(string: "http://www.google.com")!,
                                        param: "tsttt"))
        .upload()
        .success(responseType: FileResponse.self) { _ in
            expectation.fulfill()
        }
        .failure { error in
            print(error.localizedDescription! as Any)
            failed = true
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssert(failed)
    }

    func testInvalidFileUrlUploadWithoutRepository() {
        let expectation = XCTestExpectation(description: "testInvalidFileUrlUpload")
        var failed: Bool = true

        Request(method: .post,
                url: Env.termiNetworkRemote.configure().stringURL,
                params: [
                    "file1": .url(.init(string: "/path/to/file.zip")!),
                    "file2": .data(data: Data(), filename: "test.png", contentType: "zip"),
                    "expiration_date": .value(value: Date().description)
                ])
        .upload { _, _, progress in
            debugPrint("\(progress * 100)% completed")
        }
        .success {
            failed = true
            expectation.fulfill()
        }
        .failure { _ in
            failed = false
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testValidFileUrlUploadWithoutRepository() {
        let expectation = XCTestExpectation(description: "testInvalidFileUrlUpload")
        var failed: Bool = true

        guard let url = Bundle(for: TestUploadOperations.self).url(forResource: "photo",
                                                                   withExtension: "jpg") else {
            XCTAssert(false)
            return
        }

        Request(method: .post,
                url: "\(Env.termiNetworkRemote.configure().stringURL)/file_upload",
                params: [
                    "file": .url(url)
                ], configuration: .init(verbose: true))
        .upload { _, _, progress in
            debugPrint("\(progress * 100)% completed")
        }
        .success {
            failed = false
            expectation.fulfill()
        }
        .failure { _ in
            failed = true
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }
}
