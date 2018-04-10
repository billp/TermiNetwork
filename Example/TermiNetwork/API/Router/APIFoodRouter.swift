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
    case category(id: Int)
    case createCategory(title: String)
    
    // Set method, path, params, headers for each route
    internal func construct() -> TNRouteReturnType {
        switch self {
        case .categories:
            return (
                method: .get,
                path: path("categories.php"), // Generates: http(s)://.../categories.php
                params: nil,
                headers: nil
            )
        case .category(let id):
            return (
                method: .get,
                path: path("category", String(id)), // Generates: http(s)://.../category/1236
                params: nil,
                headers: nil
            )
        case .createCategory(let title):
            return (
                method: .post,
                path: path("categories", "create"), // Generates: http(s)://.../categories/create
                params: ["title": title],
                headers: nil
            )
        }
    }
    
    // Create static helper functions for each route
    static func getCategories(onSuccess: @escaping TNSuccessCallback<FoodCategories>, onFailure: @escaping TNFailureCallback) {
        do {
            try TNCall(route: self.categories).start(onSuccess: onSuccess, onFailure: onFailure)
        } catch TNRequestError.environmentNotSet {
            debugPrint("environment not set")
        } catch TNRequestError.invalidURL {
            debugPrint("invalid url")
        } catch {
            debugPrint("any other error")
        }
    }
}
