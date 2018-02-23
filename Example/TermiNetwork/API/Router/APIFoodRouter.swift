//
//  APIFoodRouter.swift
//  SimpleNetworking_Example
//
//  Created by Vasilis Panagiotopoulos on 15/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import TermiNetwork

enum APIFoodRouter: TNRouteProtocol {
    // Define your routes
    case categories
    case test
    
    // Set method, path, params, headers for each route
    internal func construct() -> TNRouteReturnType {
        switch self {
        case .categories:
            return (
                method: .get,
                path: path("categories.php"),
                params: nil,
                headers: nil
            )
        case .test:
            return (
                method: .post,
                path: path("categories.php2"),
                params: nil,
                headers: nil
            )
        }
        
    }
    
    // Create static helper functions for each route
    static func getCategories(onSuccess: @escaping TNSuccessCallback<FoodCategories>, onFailure: @escaping TNFailureCallback) {
        try! TNCall(route: APIFoodRouter.categories).start(onSuccess: onSuccess, onFailure: onFailure)
    }
    
    static func testFailureCall(onSuccess: @escaping TNSuccessCallback<Data>, onFailure: @escaping TNFailureCallback) {
        try! TNCall(route: APIFoodRouter.test).start(onSuccess: onSuccess, onFailure: { error, data in
            
            switch error {
            case .notSuccess(let statusCode):
                debugPrint("Status code " + String(statusCode))
                break
            case .networkError(let error):
                debugPrint("Network error: " + error.localizedDescription)
                break
            case .cancelled(let error):
                debugPrint("Request cancelled with error: " + error.localizedDescription)
                break
            default: break
            }
            
            onFailure(error, data)
        })
    }
}
