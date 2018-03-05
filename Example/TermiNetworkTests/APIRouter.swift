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
        }
        
    }
    
    // Create static helper functions for each route
    static func testHeadersCall(onSuccess: @escaping TNSuccessCallback<HeaderRootClass>, onFailure: @escaping TNFailureCallback) {
        try? TNCall(route: self.testHeaders, cachePolicy: nil, timeoutInterval: 5).start(onSuccess: onSuccess, onFailure: onFailure)
    }
}
