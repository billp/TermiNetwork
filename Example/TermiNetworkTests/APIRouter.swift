//
//  Router.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 05/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import TermiNetwork

enum APIRouter: TNRouteProtocol {
    // Define your routes
    case testHeaders
    case testGetParams(value1: Bool, value2: Int, value3: Double, value4: String, value5: String?)
    case testInvalidParams(value1: String, value2: String)
    case testStatusCode(code: Int)
    case testPostParams
    case testEmptyBody
    case testImage(imageName: String)
    
    // Set method, path, params, headers for each route
    internal func construct() -> TNRouteReturnType {
        switch self {
        case .testHeaders:
            return (
                method: .get,
                path: path("test_headers"),
                params: nil,
                headers: ["Authorization": "XKJajkBXAUIbakbxjkasbxjkas", "Custom-Header": "test!!!!"]
            )
        case let .testGetParams(value1, value2, value3, value4, value5):
            return (
                method: .post,
                path: path("test_params"),
                params: ["key1": value1, "key2": value2, "key3": value3, "key4": value4, "key5": value5],
                headers: nil
            )
        case let .testInvalidParams(value1, value2):
            return (
                method: .get,
                path: path("test_params"),
                params: ["fff": value1, "aaa": value2],
                headers: nil
            )
        case .testStatusCode(let code):
            return (
                method: .get,
                path: path("test_status_code"),
                params: ["status_code": code],
                headers: nil
            )
        case .testPostParams:
            return (
                method: .post,
                path: path("test_params"),
                params: ["key1": "value1", "key2": "value2"],
                headers: nil
            )
        case .testEmptyBody:
            return (
                method: .get,
                path: path("test_empty_response"),
                params: nil,
                headers: nil
            )
        case .testImage(let imageName):
            return (
                method: .get,
                path: path(imageName),
                params: nil,
                headers: nil
            )
        }
    }
}
