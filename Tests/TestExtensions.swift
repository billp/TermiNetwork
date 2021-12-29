// TestExtensions.swift
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
@testable import TermiNetwork
import SwiftUI

class TestExtensions: XCTestCase {
    lazy var sampleImageURL = Environment.current.stringURL + "/sample.jpeg"

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        Environment.set(Env.termiNetworkRemote)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testImageViewRemoteURL() {
        let expectation = XCTestExpectation(description: "Test testImageViewRemoteURL")
        var failed = true
        let imageSize = CGSize(width: 86, height: 32)

        let imageView = UIImageView()
        imageView.tn_setRemoteImage(url: sampleImageURL,
                                    defaultImage: nil,
                                    resize: imageSize,
                                    preprocessImage: { image in
            return image
        }, onFinish: { image, error in
            guard let size = image?.size else {
                expectation.fulfill()
                return
            }
            failed = !(image != nil &&
                        [imageSize.width, imageSize.height].contains(max(size.width, size.height)) &&
                        error == nil)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testImageViewRemoteInvalidURL() {
        let expectation = XCTestExpectation(description: "Test testImageViewRemoteInvalidURL")
        var failed = true

        let imageView = UIImageView()
        imageView.tn_setRemoteImage(url: "abcdef",
                                    defaultImage: nil,
                                    resize: CGSize(width: 50, height: 50),
                                    preprocessImage: { image in
            return image
        }, onFinish: { image, error in
            failed = !(image?.size == nil && error != nil)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testImageViewRemoteRequest() {
        let expectation = XCTestExpectation(description: "Test testImageViewRemoteRequest")
        var failed = true
        var tmp = 0

        let imageView = UIImageView()
        imageView.tn_setRemoteImage(request: Request.init(method: .get, url: sampleImageURL),
                                    defaultImage: nil,
                                    preprocessImage: { image in
            tmp += 1
            return image
        }, onFinish: { image, error in
            failed = !(tmp == 1 && image != nil && error == nil)
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testImageViewRemoteInvalidRequest() {
        let expectation = XCTestExpectation(description: "Test testImageViewRemoteInvalidRequest")
        var failed = true
        var tmp = 0

        let imageView = UIImageView()
        imageView.tn_setRemoteImage(request: Request.init(method: .get, url: "dtest!@#"),
                                    defaultImage: nil,
                                    preprocessImage: { image in
            tmp += 1
            return image
        }, onFinish: { _, error in
            failed = error == nil
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testSwiftUIImageViewRemoteRequest() {
        Cache.shared.clearCache()

        let expectation = XCTestExpectation(description: "Test testSwiftUIImageViewRemoteRequest")
        var failed = true
        var tmp = 1

        let image = Image(withRequest: Request.init(method: .get, url: sampleImageURL),
                          defaultImage: nil,
                          resize: nil,
                          preprocessImage: { image in
                              tmp += 1
                              if tmp != 2 {
                                  failed = true
                                  expectation.fulfill()
                              }
                              return image
                          }, onFinish: { image, error in
                              failed = !(tmp == 2 && image != nil && error == nil)
                              expectation.fulfill()
                          })
        image.imageLoader.loadImage()

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }

    func testSwiftUIImageViewRemoteURL() {
        Cache.shared.clearCache()

        let expectation = XCTestExpectation(description: "testSwiftUIImageViewRemoteURL")
        var failed = true
        var tmp = 1

        let image = Image(withURL: sampleImageURL,
                          defaultImage: nil,
                          resize: nil,
                          preprocessImage: { image in
                              tmp += 1
                              if tmp != 2 {
                                  failed = true
                                  expectation.fulfill()
                              }
                              return image
                          }, onFinish: { image, error in
                              failed = !(tmp == 2 && image != nil && error == nil)
                              expectation.fulfill()
                          })
        image.imageLoader.loadImage()

        wait(for: [expectation], timeout: 60)
        XCTAssert(!failed)
    }
}
