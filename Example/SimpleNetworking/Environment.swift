//
//  Environment.swift
//  SimpleNetworking_Example
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import SimpleNetworking

struct Environment {
    static let localhost = SNEnvironment(scheme: .https, host: "localhost", port: 8080)
    static let dev = SNEnvironment(scheme: .https, host: "mydevserver.com", suffix: "v1")
    static let production = SNEnvironment(scheme: .https, host: "my-production-server.com", suffix: "v1")
    
    static func setup() {
        SNEnvironment.active = Environment.dev
    }
}
