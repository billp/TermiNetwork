// Queue.swift
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

import Foundation
import TermiNetwork

// swiftlint:disable function_body_length cyclomatic_complexity

enum TestRepository: EndpointProtocol {
    // Define your endpoints
    case testHeaders
    case testOverrideHeaders
    case testGetParams(value1: Bool, value2: Int, value3: Double, value4: String, value5: String?)
    case testPostParams(value1: Bool, value2: Int, value3: Double, value4: String, value5: String?)
    case testPostParamsxWWWFormURLEncoded(value1: Bool, value2: Int, value3: Double, value4: String, value5: String?)
    case testInvalidParams(value1: String, value2: String)
    case testStatusCode(code: Int)
    case testEmptyBody
    case testConfiguration
    case testConfigurationParameterized(conf: Configuration)
    case testImage(imageName: String)
    case testPinning(certPath: String)
    case testEncryptParams(value: String?)
    case dataUpload(data: Data, param: String)
    case fileUpload(url: URL, param: String)
    case fileDownload

    func testPinningConfiguration(withCertPaths certPaths: [String]) -> Configuration {
        let configuration = Configuration(certificatePaths: certPaths)
        configuration.headers = ["Custom-Header": "1"]
        return configuration
    }

    // Set method, path, params, headers for each endpoint
    func configure() -> EndpointConfiguration {
        switch self {
        case .testHeaders:
            return .init(
                method: .get,
                path: .path(["test_headers"]),
                headers: ["Authorization": "XKJajkBXAUIbakbxjkasbxjkas", "Custom-Header": "test!!!!"],
                mockFilePath: .path(["main-repo", "headers.json"])
            )
        case .testOverrideHeaders:
            return .init(
                method: .get,
                path: .path(["test_headers"]),
                headers: ["Authorization": "0",
                          "Custom-Header": "0",
                          "User-Agent": "ios"],
                mockFilePath: .path(["main-repo", "invalid.json"])
            )
        case let .testGetParams(value1, value2, value3, value4, value5):
            return .init(method: .get,
                         path: .path(["test_params"]),
                         params: ["key1": value1, "key2": value2, "key3": value3, "key4": value4, "key5": value5]
            )
        case let .testPostParamsxWWWFormURLEncoded(value1, value2, value3, value4, value5):
            return .init(method: .post,
                         path: .path(["test_params"]),
                         params: ["key1": value1, "key2": value2, "key3": value3, "key4": value4, "key5": value5],
                         configuration: Configuration(requestBodyType: .xWWWFormURLEncoded)
            )
        case .testConfiguration:
            return .init(method: .post,
                         path: .path(["test_params"]),
                         configuration: Configuration(cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                                      timeoutInterval: 12,
                                                      requestBodyType: .JSON)
            )
        case .testConfigurationParameterized(let conf):
            return .init(method: .get,
                         path: .path(["a"]),
                         params: nil,
                         headers: nil,
                         configuration: conf)
        case let .testPostParams(value1, value2, value3, value4, value5):
            return .init(method: .post,
                         path: .path(["test_params"]),
                         params: ["key1": value1, "key2": value2, "key3": value3, "key4": value4, "key5": value5],
                         configuration: Configuration(requestBodyType: .JSON)
            )
        case let .testInvalidParams(value1, value2):
            return .init(method: .get,
                         path: .path(["test_params"]),
                         params: ["fff": value1, "aaa": value2]
            )
        case .testStatusCode(let code):
            return .init(method: .get,
                         path: .path(["test_status_code"]),
                         params: ["status_code": code]
            )
        case .testEmptyBody:
            return .init(method: .get,
                         path: .path(["test_empty_response"])
            )
        case .testImage(let imageName):
            return .init(method: .get,
                         path: .path([imageName])
            )
        case .testPinning(let certPath):
            return .init(method: .get,
                         path: .path(["test_empty_response"]),
                         configuration: testPinningConfiguration(withCertPaths: [certPath])
            )
        case .testEncryptParams(let value):
            return .init(method: .post,
                         path: .path(["test_encrypt_params"]),
                         params: ["value": value]
            )
        case .dataUpload(let data, let param):
            return .init(method: .post,
                         path: .path(["file_upload"]),
                         params: ["file": .data(data: data,
                                                filename: "test.jpg",
                                                contentType: "image/jpeg"),
                                  "test_param": .value(value: param)]
            )
        case .fileUpload(let url, let param):
            return .init(method: .post,
                         path: .path(["file_upload"]),
                         params: ["file": .url(url),
                                  "test_param": .value(value: param)]
            )
        case .fileDownload:
            return EndpointConfiguration(method: .get,
                                         path: .path(["downloads", "3cwHqdwsRyuX"]))
        }
    }
}

// swiftlint:enable function_body_length cyclomatic_complexity
