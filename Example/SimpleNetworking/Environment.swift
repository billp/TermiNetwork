//
//  Environment.swift
//  SimpleNetworking_Example
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import SimpleNetworking


enum Environment {
    case localhost
    case dev
    case production
    
    func configure() -> SNEnvironment {
        switch self {
        case .localhost:
            return SNEnvironment(scheme: .https, host: "localhost", port: 8080)
        case .dev:
            return SNEnvironment(scheme: .https, host: "mydevserver.com", suffix: "v1")
        case .production:
            return SNEnvironment(scheme: .https, host: "my-production-server.com", suffix: "v1")
        }
    }
}
