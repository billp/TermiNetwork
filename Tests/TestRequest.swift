// TestRequest.swift
//
// Copyright © 2018-2021 Vasilis Panagiotopoulos. All rights reserved.
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

class TestRequest: XCTestCase {
    lazy var router: Router<APIRoute> = {
        return Router<APIRoute>(configuration: Configuration(verbose: true))
    }()

    lazy var router2: Router<APIRoute> = {
        return Router<APIRoute>(environment: Env.google)
    }()

    lazy var routerWithMiddleware: Router<APIRoute> = {
        let configuration = Configuration()
        configuration.requestMiddleware = [CryptoMiddleware.self]
        configuration.verbose = true
        configuration.requestBodyType = .JSON

        let router = Router<APIRoute>(environment: Env.termiNetworkRemote,
                                        configuration: configuration)

        return router
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

    func testHeaders() {
        let expectation = XCTestExpectation(description: "testHeaders")
        var failed = true

        router.request(for: .testHeaders)
            .success(responseType: TestHeaders.self) { object in
                failed = !(object.authorization == "XKJajkBXAUIbakbxjkasbxjkas" && object.customHeader == "test!!!!")
                expectation.fulfill()
            }
            .failure { _ in
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testOverrideHeaders() {
        let expectation = XCTestExpectation(description: "testOverrideHeaders")
        var failed = true

        router.request(for: .testOverrideHeaders)
            .success(responseType: TestHeaders.self) { object in
                failed = !(object.authorization == "0" &&
                            object.customHeader == "0" &&
                             object.userAgent == "ios")
                expectation.fulfill()
            }
            .failure { _ in
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testGetParams() {
        let expectation = XCTestExpectation(description: "testGetParams")
        var failed = true

        router.request(for: .testGetParams(value1: true,
                                           value2: 3,
                                           value3: 5.13453124189,
                                           value4: "test",
                                           value5: nil))
            .success(responseType: TestParams.self) { object in
                failed = !(object.param1 == "true" &&
                    object.param2 == "3" &&
                    object.param3 == "5.13453124189" &&
                    object.param4 == "test" &&
                    object.param5 == nil)
                failed = false
                expectation.fulfill()
            }
            .failure { _ in
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testGetParamsEscaped() {
        let expectation = XCTestExpectation(description: "testGetParamsEscaped")
        var failed = true

        router.request(for: .testGetParams(value1: true,
                                           value2: 3,
                                           value3: 5.13453124189,
                                           value4: "τεστ",
                                           value5: nil))
            .success(responseType: TestParams.self) { object in
                failed = !(object.param1 == "true" &&
                    object.param2 == "3" &&
                    object.param3 == "5.13453124189" &&
                    object.param4 == "τεστ" &&
                    object.param5 == nil)
                failed = false
                expectation.fulfill()
            }
            .failure { _ in
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testPostParams() {
        let expectation = XCTestExpectation(description: "testPostParams")
        var failed = true

        router.request(for: .testPostParamsxWWWFormURLEncoded(value1: true,
                                                              value2: 3,
                                                              value3: 5.13453124189,
                                                              value4: "test",
                                                              value5: nil))
            .success(responseType: TestParams.self) { object in
                failed = !(object.param1 == "true" &&
                    object.param2 == "3" &&
                    object.param3 == "5.13453124189" &&
                    object.param4 == "test" &&
                    object.param5 == nil)
                expectation.fulfill()
            }
            .failure { _ in
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testJSONRequestPostParams() {
        let expectation = XCTestExpectation(description: "testJSONRequestPostParams")
        var failed = true

        router.request(for: .testPostParams(value1: true,
                                            value2: 3,
                                            value3: 5.13453124189,
                                            value4: "test",
                                            value5: nil))
            .success(responseType: TestJSONParams.self) { object in
                failed = !(object.param1 == true &&
                    object.param2 == 3 &&
                    object.param3 == 5.13453124189 &&
                    object.param4 == "test" &&
                        object.param5 == nil)
                expectation.fulfill()
            }
            .failure { _ in
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testBeforeAllRequests() {
        let expectation = XCTestExpectation(description: "testBeforeAllRequests")
        let queue = Queue()
        queue.beforeAllRequestsCallback = {
            expectation.fulfill()
        }

        self.sampleRequest(queue: queue)
        self.sampleRequest(queue: queue)
        self.sampleRequest(queue: queue)

        wait(for: [expectation], timeout: 60)

        XCTAssert(queue.operationCount == 3)
    }

    func testAfterAllRequests() {
        let expectation = XCTestExpectation(description: "testAfterAllRequests")
        let queue = Queue()
        var failed = true

        queue.afterAllRequestsCallback = { _ in
            failed = queue.operations.count > 0
            expectation.fulfill()
        }

        sampleRequest(queue: queue)
        sampleRequest(queue: queue)
        sampleRequest(queue: queue)

        wait(for: [expectation], timeout: 60)

        XCTAssert(!failed)
    }

    func testBeforeEachRequest() {
        let expectation = XCTestExpectation(description: "testBeforeEachRequest")
        var failed = true
        let queue = Queue()

        queue.beforeEachRequestCallback = { _ in
            expectation.fulfill()
            failed = false
        }

        sampleRequest(queue: queue)

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testAfterEachRequest() {
        let expectation = XCTestExpectation(description: "testAfterEachRequest")
        var failed = true
        Queue.shared.cancelAllOperations()

        Queue.shared.afterEachRequestCallback = { _, _, _, _ in
            failed = false
            expectation.fulfill()
        }

        sampleRequest(onSuccess: { _ in })

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testStringResponse() {
        let expectation = XCTestExpectation(description: "testStringResponse")
        var failed = true
        Queue.shared.cancelAllOperations()

        let request = Request(route: APIRoute.testPostParams(value1: true,
                                                               value2: 3,
                                                               value3: 5.13453124189,
                                                               value4: "test",
                                                               value5: nil))
        request.configuration.requestBodyType = .JSON
        request.configuration.verbose = true
        request.success(responseType: String.self) { _ in
            failed = false
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testConfiguration() {
        var request = Request(route: APIRoute.testInvalidParams(value1: "a", value2: "b"))
        var urlRequest = try? request.asRequest()
        XCTAssert(urlRequest?.timeoutInterval == 60)
        XCTAssert(request.configuration.cachePolicy == .useProtocolCachePolicy)
        XCTAssert(request.configuration.requestBodyType == .xWWWFormURLEncoded)

        Environment.set(Env.termiNetworkLocal)
        request = Request(route: APIRoute.testHeaders)
        urlRequest = try? request.asRequest()
        XCTAssert(urlRequest?.timeoutInterval == 32)
        XCTAssert(request.configuration.cachePolicy == .returnCacheDataElseLoad)
        XCTAssert(request.configuration.requestBodyType == .JSON)

        Environment.set(Env.termiNetworkRemote)
        request = Request(route: APIRoute.testConfiguration)
        urlRequest = try? request.asRequest()
        XCTAssert(urlRequest?.timeoutInterval == 12)
        XCTAssert(request.configuration.cachePolicy == .reloadIgnoringLocalAndRemoteCacheData)
        XCTAssert(request.configuration.requestBodyType == .JSON)
    }

    func testOverrideEnvironment() {
        Environment.set(Env.termiNetworkRemote)

        let expectation1 = XCTestExpectation(description: "testOverrideEnvironment1")
        let expectation2 = XCTestExpectation(description: "testOverrideEnvironment2")

        var failed = true

        router.request(for: .testGetParams(value1: false,
                                           value2: 2,
                                           value3: 3,
                                           value4: "1",
                                           value5: nil))
            .success(responseType: Data.self) { _ in
                failed = false
                expectation1.fulfill()
            }
            .failure { _ in
                failed = true
                expectation1.fulfill()
            }

        wait(for: [expectation1], timeout: 60)

        XCTAssert(!failed)

        failed = true

        router2.request(for: .testGetParams(value1: false,
                                            value2: 2,
                                            value3: 3,
                                            value4: "1",
                                            value5: nil))
            .success(responseType: String.self) { _ in
                expectation2.fulfill()
            }
            .failure { error in
                if case .notSuccess(404) = error {
                    failed = false
                }
                expectation2.fulfill()
            }

        wait(for: [expectation2], timeout: 60)
        XCTAssert(!failed)
    }

    func testMiddleware() {
        var failed = true

        let expectation = XCTestExpectation(description: "testMiddleware")

        routerWithMiddleware.request(for: .testEncryptParams(value: "Hola!!!"))
            .success(responseType: EncryptedModel.self) { model in
                failed = model.value != "Hola!!!"
                expectation.fulfill()
            }
            .failure { _ in
                failed = true
                expectation.fulfill()
            }
            .responseHeaders { (headers, _) in
                failed = !(headers?["X-Test-Header"] == "test123!")
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    fileprivate func sampleRequest(queue: Queue? = Queue.shared,
                                   onSuccess: SuccessCallback<TestJSONParams>? = nil) {
        let call = Request(route: APIRoute.testPostParams(value1: true,
                                                          value2: 3,
                                                          value3: 5.13453124189,
                                                          value4: "test",
                                                          value5: nil))
        call.configuration.requestBodyType = .JSON
        call.queue(queue ?? Queue.shared)
            .success(responseType: TestJSONParams.self) { object in
                onSuccess?(object)
            }
    }

    func testResponseHeaders() {
        var failed = true

        let expectation = XCTestExpectation(description: "testResponseHeaders")

        routerWithMiddleware.request(for: .testEncryptParams(value: "Hola!!!"))
            .success(responseType: Data.self, responseHandler: { _ in })
            .responseHeaders { (headers, _) in
                failed = headers?["Content-Type"] != "application/json; charset=utf-8"
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testInvalidResponseHeaders() {
        var failed = true

        let expectation = XCTestExpectation(description: "testMiddleware")

        routerWithMiddleware.request(for: .testEncryptParams(value: "Hola!!!"))
            .responseHeaders { (_, error) in
                if case .cannotReadResponseHeaders = error {
                    failed = false
                } else {
                    failed = true
                }
                expectation.fulfill()
            }

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }
}
