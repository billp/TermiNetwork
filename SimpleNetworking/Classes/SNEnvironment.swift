//
//  Environment.swift
//  ServiceRouter
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

public enum SNURLScheme: String {
    case http
    case https
}

open class SNEnvironment {
    
    // MARK: - Properties
    var scheme: SNURLScheme
    var host: String
    var port: Int?
    var suffix: String?
    var timeoutInterval: TimeInterval = 60

    // MARK: - Static properties
    public static var active: SNEnvironment!
    
    
    // MARK: - Initializers
    public init(scheme: SNURLScheme, host: String, suffix: String?, port: Int?) {
        self.scheme = scheme
        self.host = host
        self.suffix = suffix
        self.port = port
    }
    
    public convenience init(scheme: SNURLScheme, host: String, port: Int) {
        self.init(scheme: scheme, host: host, suffix: nil, port: port)
    }
    
    public convenience init(scheme: SNURLScheme, host: String, suffix: String) {
        self.init(scheme: scheme, host: host, suffix: suffix, port: nil)
    }
    
    public convenience init(scheme: SNURLScheme, host: String, suffix: String, port: Int) {
        self.init(scheme: scheme, host: host, suffix: suffix, port: port)
    }
}


// MARK: - CustomStringConvertible
extension SNEnvironment: CustomStringConvertible {
    public var description: String {
        var urlComponents = [String]()
        urlComponents.append(scheme.rawValue + ":/")
        urlComponents.append(host)
        
        if port != nil {
            urlComponents.append(":" + String(describing: port!))
        }
        if suffix != nil {
            urlComponents.append(suffix!)
        }
        
        return urlComponents.joined(separator: "/")
    }
}
