//
//  Environment.swift
//  ServiceRouter
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

public protocol TNEnvironmentProtocol {
    func configure() -> TNEnvironment
}

public enum TNURLScheme: String {
    case http
    case https
}

open class TNEnvironment {
    // MARK: - Properties
    var scheme: TNURLScheme
    var host: String
    var port: Int?
    var suffix: TNPath?
    var timeoutInterval: TimeInterval = 60

    // MARK: - Static members
    internal static var current: TNEnvironment!
    public static var env: TNEnvironmentProtocol! {
        didSet {
            current = env.configure()
        }
    }
    public static var verbose = false
        
    // MARK: - Initializers
    public init(scheme: TNURLScheme, host: String, suffix: TNPath?, port: Int?) {
        self.scheme = scheme
        self.host = host
        self.suffix = suffix
        self.port = port
    }
    
    public convenience init(scheme: TNURLScheme, host: String, port: Int) {
        self.init(scheme: scheme, host: host, suffix: nil, port: port)
    }
    
    public convenience init(scheme: TNURLScheme, host: String, suffix: TNPath) {
        self.init(scheme: scheme, host: host, suffix: suffix, port: nil)
    }
    
    public convenience init(scheme: TNURLScheme, host: String, suffix: TNPath, port: Int) {
        self.init(scheme: scheme, host: host, suffix: suffix, port: port)
    }
}


// MARK: - CustomStringConvertible
extension TNEnvironment: CustomStringConvertible {
    public var description: String {
        var urlComponents = [String]()
        urlComponents.append(scheme.rawValue + ":/")
        urlComponents.append(host)
        
        if port != nil {
            urlComponents.append(":" + String(describing: port!))
        }
        if suffix != nil {
            urlComponents.append(suffix!.components.joined(separator: "/"))
        }
        
        return urlComponents.joined(separator: "/")
    }
}
