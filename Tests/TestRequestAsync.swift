// TestRequest.swift
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

class TestRequestAsync: XCTestCase {
    lazy var client: Client<TestRepository> = .init(configuration: Configuration(verbose: true))
    lazy var client2: Client<TestRepository> = .init(environment: Env.google)

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Environment.set(Env.termiNetworkRemote)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testHeaders() async {
        var failed = true
        do {
            let response: TestHeaders = try await client.request(for: .testHeaders).async()
            failed = !(response.authorization == "XKJajkBXAUIbakbxjkasbxjkas" && response.customHeader == "test!!!!")
        } catch { }

        XCTAssert(!failed)
    }

    func testStringResponse() async {
        let request = Request(method: .get, url: "https://www.github.com")
        let response: String? = try? await request.async(as: String.self)
        request.configuration.verbose = true

        XCTAssert(response != nil)
    }

    func testStringResponseCancel() {
        let expectation = XCTestExpectation(description: "testStringResponseCancel")
        let request = Request(method: .get, url: "https://www.github.com")
        request.configuration.verbose = true

        let task = Task {
            var failed = true

            do {
                try await request.async(as: String.self)
                expectation.fulfill()
            } catch let error {
                let error = error as? TNError
                if case .cancelled = error {
                    failed = false
                } else {
                    failed = true
                }

                expectation.fulfill()
                XCTAssert(!failed)
            }
        }

        task.cancel()

        wait(for: [expectation], timeout: 60)
    }

    func testDataResponse() async {
        let request = Request(method: .get, url: "https://www.github.com")
        request.configuration.verbose = true

        var failed = true

        do {
            let response: Data = try await request.async(as: Data.self)
            failed = response.count == 0
        } catch { }

        XCTAssertFalse(failed)
    }

    func testDataResponseCancel() {
        let expectation = XCTestExpectation(description: "testDataResponseCancel")
        let request = Request(method: .get, url: "https://www.github.com")
        request.configuration.verbose = true

        let task = Task {
            var failed = true

            do {
                try await request.async(as: Data.self)
                expectation.fulfill()
            } catch let error {
                let error = error as? TNError
                if case .cancelled = error {
                    failed = false
                } else {
                    failed = true
                }

                expectation.fulfill()
                XCTAssert(!failed)
            }
        }

        task.cancel()

        wait(for: [expectation], timeout: 60)
    }

    func testGetParamsWithTransformerSuccess() async {
        let testModel = try? await client.request(
            for: .testGetParams(value1: true,
                                value2: 3,
                                value3: 5.13453124189,
                                value4: "test",
                                value5: nil)
        ).async(using: TestTransformer.self)

        XCTAssert(testModel?.value == "true")
    }

    func testGetParamsWithTransformerCancel() {
        let expectation = XCTestExpectation(description: "testGetParamsWithTransformerCancel")

        let task = Task {
            var failed = true

            do {
                try await client.request(
                    for: .testGetParams(value1: true,
                                        value2: 3,
                                        value3: 5.13453124189,
                                        value4: "test",
                                        value5: nil)
                ).async(using: TestTransformer.self)
                expectation.fulfill()
            } catch let error {
                let error = error as? TNError
                if case .cancelled = error {
                    failed = false
                } else {
                    failed = true
                }

                expectation.fulfill()
                XCTAssert(!failed)
            }
        }

        task.cancel()

        wait(for: [expectation], timeout: 60)
    }

    func testGetParamsWithTransformerSuccessTransformError() async {
        var failed = true

        let req = client.request(
            for: .testGetParams(value1: true,
                                value2: 3,
                                value3: 5.13453124189,
                                value4: "test",
                                value5: nil))

        do {
            _ = try await req.async(using: StatusCodeTransformer.self)
        } catch let error as TNError {
            if case .cannotDeserialize = error {
                failed = false
            } else {
                failed = true
            }
        } catch { }

        XCTAssert(!failed)
    }

    func testResponseValidImageData() async {
        let image = try? await client.request(for: .testImage(imageName: "sample.jpeg")).async(as: UIImage.self)

        XCTAssertNotNil(image)
    }
}
