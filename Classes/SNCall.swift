//
//  SRCall.swift
//  ServiceRouter
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

enum SNMethod: String {
    case get
    case head
    case post
    case put
    case delete
    case connect
    case options
    case trace
    case patch
}

struct SNPath {
    var components: [String]!
    
    init(_ components: String...) {
        self.components = components
    }
}

enum SNError: Error {
    case invalidURL
    case invalidParams
}

typealias path = SNPath

class SNCall {
    static var fixedHeaders = [String: String]()
    var headers: [String: String]?
    var method: SNMethod!
    var path: String
    var cachePolicy: URLRequest.CachePolicy?
    var timeoutInterval: TimeInterval?
    var params: [String: Any?]?
    
    
    //MARK: - Initializers
    init(method: SNMethod, headers: [String: String]?, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?, path: SNPath, params: [String: Any?]?) {
        self.method = method
        self.headers = headers
        self.path = path.components.joined(separator: "/")
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.params = params
    }
    
    convenience init(method: SNMethod, headers: [String: String], path: SNPath, params: [String: Any?]?) {
        self.init(method: method, headers: headers, cachePolicy: nil, timeoutInterval: nil, path: path, params: params)
    }
    
    convenience init(method: SNMethod, path: SNPath, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: path, params: nil)
    }
    
    
    // MARK: - Create request
    func asRequest() throws -> URLRequest {
        guard let url = URL(string: SNEnvironment.active.description) else {
            throw SNError.invalidURL
        }
        
        var request = URLRequest(url: url.appendingPathComponent(path), cachePolicy: .useProtocolCachePolicy, timeoutInterval: SNEnvironment.active.timeoutInterval)
        
        params?.merge(SNCall.fixedHeaders, uniquingKeysWith: { (_, new) in new })
        
        request.allHTTPHeaderFields = params as? [String : String]
        request.httpMethod = method.rawValue
        
        if cachePolicy != nil {
            request.cachePolicy = cachePolicy!
        }
        if timeoutInterval != nil {
            request.timeoutInterval = timeoutInterval!
        }
        if params != nil {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params!, options: .prettyPrinted)
            } catch {
                throw SNError.invalidParams
            }
        }
        return request
    }
    
    // MARK: - Start request
    func start(onSuccess: @escaping (Data)->(), onFailure: @escaping (Error)->()) throws {
        let session = URLSession.shared.dataTask(with: try asRequest()) { data, urlResponse, error in
            if error != nil {
                onFailure(error!)
            } else if data != nil {
                onSuccess(data!)
            }
        }
        
        session.resume()
    }
    
    
}
