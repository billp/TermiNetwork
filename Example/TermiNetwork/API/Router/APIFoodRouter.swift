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
    case filter(categoryTitle: String)
    case createCategory(title: String)
    
    // Set method, path, params, headers for each route
    func configure() -> TNRouteConfiguration {
        switch self {
        case .categories:
            return TNRouteConfiguration(
                method: .get,
                path: path("categories.php") // Generates: http(s)://.../categories.php
            )
        case .filter(let categoryTitle):
            return TNRouteConfiguration(
                method: .get,
                path: path("search.php"), // Generates: http(s)://.../category/1236
                params: ["filter": categoryTitle]
            )
        case .createCategory(let title):
            return TNRouteConfiguration(
                method: .post,
                path: path("categories", "create"), // Generates: http(s)://.../categories/create
                params: ["title": title]
            )
        }
    }
    
    // Create static helper functions for each route
    static func getCategories(onSuccess: @escaping TNSuccessCallback<FoodCategories>, onFailure: @escaping TNFailureCallback) {
        do {
            try TNRequest(route: self.categories).start(responseType: FoodCategories.self, onSuccess: onSuccess, onFailure: onFailure)
        } catch TNRequestError.environmentNotSet {
            debugPrint("environment not set")
        } catch TNRequestError.invalidURL {
            debugPrint("invalid url")
        } catch {
            debugPrint("any other error")
        }
    }
}
