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
    case testGetParams(value1: String, value2: String)
    case testPostParams
    
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
        case let .testGetParams(value1, value2):
            return (
                method: .get,
                path: path("test_params"),
                params: ["key1": value1, "key2": value2],
                headers: nil
            )
        case .testPostParams:
            return (
                method: .post,
                path: path("test_params"),
                params: ["key1": "value1", "key2": "value2"],
                headers: nil
            )
        }
    }
}
