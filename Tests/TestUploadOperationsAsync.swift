// TestUploadOperationsAsync.swift
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

class TestUploadOperationsAsync: XCTestCase {
    lazy var configuration: Configuration = {
        return Configuration(cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                             timeoutInterval: 60,
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

    func testDataUpload() async {
        var failed = true
        var completed = false

        guard let filePath = Bundle(for: TestUploadOperations.self).path(forResource: "photo",
                                                                         ofType: "jpg"),
        let uploadData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            XCTAssert(false)
            return
        }

        let checksum = TestHelpers.sha256(url: URL(fileURLWithPath: filePath))

        do {
            let response = try await client.request(for: .dataUpload(data: uploadData, param: "bhbbrbrbrhbh"))
                .asyncUpload(
                    as: FileResponse.self,
                    progressUpdate: { bytesSent, totalBytes, progress in
                        completed = bytesSent == totalBytes && progress == 1
                    })

            failed = !(response.success &&
                        response.checksum == checksum &&
                        response.param == "bhbbrbrbrhbh")
        } catch let error {
            print(String(describing: error.localizedDescription))
        }

        XCTAssert(!failed && completed)
    }

    func testDataUploadCancel() {
        let expectation = XCTestExpectation(description: "testDataUploadCancel")

        let task = Task {
            var failed = true

            guard let filePath = Bundle(for: TestUploadOperations.self).path(forResource: "photo",
                                                                             ofType: "jpg"),
            let uploadData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
                assert(false)
            }

            do {
                try await client.request(for: .dataUpload(data: uploadData, param: "bhbbrbrbrhbh"))
                    .asyncUpload(
                        as: FileResponse.self,
                        progressUpdate: nil)

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

    func testDataUploadWithTransformer() async {
        var failed = true
        var completed = false

        guard let filePath = Bundle(for: TestUploadOperations.self).path(forResource: "photo",
                                                                         ofType: "jpg"),
        let uploadData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            assert(false)
        }

        let checksum = TestHelpers.sha256(url: URL(fileURLWithPath: filePath))

        do {
            let response = try await client.request(for: .dataUpload(data: uploadData, param: "bhbbrbrbrhbh"))
                .asyncUpload(using: TestUploadTransformer.self,
                             progressUpdate: { bytesSent, totalBytes, progress in
                                 completed = bytesSent == totalBytes && progress == 1
                             })

            failed = !(response.value == checksum && response.param == "bhbbrbrbrhbh")

        } catch let error {
            print(String(describing: error.localizedDescription))
        }

        XCTAssert(!failed && completed)
    }

    func testDataUploadWithTransformerCancel() {
        let expectation = XCTestExpectation(description: "testDataUploadWithTransformerCancel")

        let task = Task {
            var failed = true

            guard let filePath = Bundle(for: TestUploadOperations.self).path(forResource: "photo",
                                                                             ofType: "jpg"),
            let uploadData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
                assert(false)
            }

            do {
                try await client.request(for: .dataUpload(data: uploadData, param: "bhbbrbrbrhbh"))
                    .asyncUpload(using: TestUploadTransformer.self,
                                 progressUpdate: nil)

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

    func testFileUpload() async {
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
            do {
                let response = try await client.request(for: .fileUpload(url: url, param: "bhbbrbrbrhbh"))
                    .asyncUpload(as: FileResponse.self,
                                 progressUpdate: { bytesSent, totalBytes, progress in
                        if bytesSent == totalBytes && progress == 1 {
                            progressSuccessCount += 1
                        }
                    })

                if response.success && response.checksum == checksum {
                    successCount  += 1
                }
            } catch let error {
                print(String(describing: error.localizedDescription))
            }
        }

        XCTAssert(successCount == iterations && progressSuccessCount == iterations)
    }

    func testRandomFileUpload() async {
        var progressSuccessCount = 0
        var successCount = 0
        let iterations = 10

        let urls = (0..<iterations).compactMap { TestHelpers.createDummyFile(String($0)) }
        let checksums = urls.map { TestHelpers.sha256(url: $0) }

        for key in 0..<iterations {
            do {
                let response = try await client.request(for: .fileUpload(url: urls[key], param: "bhbbrbrbrhbh"))
                    .asyncUpload(as: FileResponse.self,
                                 progressUpdate: { bytesSent, totalBytes, progress in
                        if bytesSent == totalBytes && progress == 1 {
                            progressSuccessCount += 1
                        }
                    })

                if response.success && response.checksum == checksums[key] {
                    successCount += 1
                } else {
                    XCTAssert(false, "Files don't match!")
                }
                try? FileManager.default.removeItem(at: urls[key])
            } catch let error {
                print(String(describing: error.localizedDescription))
                try? FileManager.default.removeItem(at: urls[key])
            }
        }

        XCTAssert(successCount == iterations && progressSuccessCount == iterations)
    }

    func testInvalidFileUrlUpload() async {
        var failed: Bool = false

        do {
            _ = try await client.request(for: .fileUpload(url: URL(string: "http://www.google.com")!,
                                            param: "tsttt"))
            .asyncUpload(as: FileResponse.self,
                         progressUpdate: nil)
        } catch let error {
            print(error.localizedDescription)
            failed = true
        }

        XCTAssert(failed)
    }

    func testInvalidFileUrlUploadWithoutRepository() async {
        do {
            try await Request(method: .post,
                    url: Env.termiNetworkRemote.configure().stringURL,
                    params: [
                        "file1": .url(.init(string: "/path/to/file.zip")!),
                        "file2": .data(data: Data(), filename: "test.png", contentType: "zip"),
                        "expiration_date": .value(value: Date().description)
                    ])
            .asyncUpload(as: Data.self) { _, _, progress in
                debugPrint("\(progress * 100)% completed")
            }
            XCTAssert(true)
        } catch let error {
            print(error)
            XCTAssert(true)
        }
    }

    func testValidFileUrlUploadWithoutRepository() async {

        guard let url = Bundle(for: TestUploadOperations.self).url(forResource: "photo",
                                                                   withExtension: "jpg") else {
            XCTAssert(false)
            return
        }

        do {
            try await Request(method: .post,
                              url: "\(Env.termiNetworkRemote.configure().stringURL)/file_upload",
                              params: [
                                "file": .url(url)
                              ])
            .asyncUpload(as: String.self, progressUpdate: { _, _, progress in
                debugPrint("\(progress * 100)% completed")
            })

            XCTAssert(true)
        } catch {
            XCTAssert(false)
        }
    }
}
