//
//  SRCall.swift
//  ServiceRouter
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

public typealias TNSuccessCallback<T> = (T)->()
public typealias TNFailureCallback = (Error)->()


public enum TNMethod: String {
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

public enum TNError: Error {
    case invalidURL
    case invalidParams
    case responseDataIsEmpty
    case responseInvalidImageData
    case environmentNotSet
}

public enum TNCallSerializationType {
    case JSON
    case image
}

public typealias TNRouteReturnType = (method: TNMethod, path: TNPath, params: [String: Any?]?, headers: [String: String]?)

public protocol TNRouteProtocol {
    func construct() -> TNRouteReturnType
}

open class TNCall {
    static var fixedHeaders = [String: String]()
    var headers: [String: String]?
    var method: TNMethod!
    var path: String
    var cachePolicy: URLRequest.CachePolicy?
    var timeoutInterval: TimeInterval?
    var params: [String: Any?]?
    private var pathType: SNPathType = .normal
    private var dataTask: URLSessionDataTask?
    
    //MARK: - Initializers
    public init(method: TNMethod, headers: [String: String]?, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?, path: TNPath, params: [String: Any?]?) {
        self.method = method
        self.headers = headers
        self.path = path.components.joined(separator: "/")
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.params = params
    }
    
    public convenience init(method: TNMethod, headers: [String: String], path: TNPath, params: [String: Any?]?) {
        self.init(method: method, headers: headers, cachePolicy: nil, timeoutInterval: nil, path: path, params: params)
    }
    
    public convenience init(method: TNMethod, path: TNPath, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: path, params: nil)
    }

    public convenience init(route: TNRouteProtocol) {
        let params = route.construct()
        
        self.init(method: params.method, headers: params.headers, cachePolicy: nil, timeoutInterval: nil, path: params.path, params: params.params)
    }
    
    // Convenience method for passing a string instead of path
    public convenience init(method: TNMethod, url: String, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: TNPath("-"), params: nil)
        self.pathType = .full
        self.path = url
    }
    
    // MARK: - Create request
    public func asRequest() throws -> URLRequest {
        guard let currentEnvironment = TNEnvironment.current else { throw TNError.environmentNotSet }
        
        let urlString = pathType == .normal ? currentEnvironment.description + "/" + path : path
        
        guard let url = URL(string: urlString) else {
            throw TNError.invalidURL
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: currentEnvironment.timeoutInterval)
        
        params?.merge(TNCall.fixedHeaders, uniquingKeysWith: { (_, new) in new })
        
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
                throw TNError.invalidParams
            }
        }
        return request
    }
    
    // Cancel data task
    public func cancel() {
        dataTask?.cancel()
    }
    
    // MARK: - Helper methods
    private func sessionDataTask(request: URLRequest, completionHandler: @escaping (Data)->(), onFailure: @escaping TNFailureCallback) throws -> URLSessionDataTask {
        dataTask = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            if error != nil {
                DispatchQueue.main.sync {
                    onFailure(error!)
                }
            }
            else if data == nil {
                DispatchQueue.main.sync {
                    onFailure(TNError.responseDataIsEmpty)
                }
            } else {
                completionHandler(data!)
            }
        }
        
        return dataTask!
    }
    
    // MARK: - Start requests
    
    // Deserialize objects with Decodable
    public func start<T>(onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: Decodable {
        try sessionDataTask(request: try asRequest(), completionHandler: { data in
            let jsonDecoder = JSONDecoder()
            let object = try! jsonDecoder.decode(T.self, from: data)
            
            DispatchQueue.main.sync {
                onSuccess(object)
            }

        }, onFailure: onFailure).resume()
    }
    
    // Deserialize objects with UIImage
    public func start<T>(onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: UIImage {
        try sessionDataTask(request: try asRequest(), completionHandler: { data in
            let image = T(data: data)
            
            if image == nil {
                DispatchQueue.main.sync {
                    onFailure(TNError.responseInvalidImageData)
                }
            } else {
                DispatchQueue.main.sync {
                    onSuccess(image!)
                }
            }
        }, onFailure: onFailure).resume()
    }
    
    // For any other object
    public func start(onSuccess: @escaping TNSuccessCallback<Data>, onFailure: @escaping TNFailureCallback) throws {
        try sessionDataTask(request: try asRequest(), completionHandler: { data in
            DispatchQueue.main.sync {
                onSuccess(data)
            }
        }, onFailure: onFailure).resume()
    }
}
