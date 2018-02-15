//
//  ViewController.swift
//  SimpleNetworking
//
//  Created by Bill Panagiotopouplos on 02/14/2018.
//  Copyright (c) 2018 Bill Panagiotopouplos. All rights reserved.
//

import UIKit
import SimpleNetworking

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
            
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

enum APIAuthenticationRouter: SNRouteProtocol {
    // Define your routes
    case login(username: String, password: String)
    case logout
    
    // Set method, path, params, headers for each route
    internal func construct() -> SNRouteReturnType {
        switch self {
        case let .login(username, password):
            return (
                method: .post,
                path: path("auth", "login"),
                params: ["username": username, "password": password],
                headers: [:]
            )
        case .logout:
            return (
                method: .get,
                path: path("auth", "logout"),
                params: nil,
                headers: [:]
            )
        }
    }
    
    // Create static helper functions for each route
    static func callLogin(username: String, password: String, onSuccess: @escaping SNSuccessCallback, onFailure: @escaping SNFailureCallback) {
        try? SNCall(route: APIAuthenticationRouter.login(username: username, password: password)).start(onSuccess: onSuccess, onFailure: onFailure)
    }
    
    static func callLogout(onSuccess: @escaping SNSuccessCallback, onFailure: @escaping SNFailureCallback) {
        try? SNCall(route: APIAuthenticationRouter.logout).start(onSuccess: onSuccess, onFailure: onFailure)
    }
}

