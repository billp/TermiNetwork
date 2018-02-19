//
//  SRCall.swift
//  ServiceRouter
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

public typealias SNSuccessCallback<T> = (T)->()
public typealias SNFailureCallback = (Error)->()


public enum SNMethod: String {
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

public enum SNError: Error {
    case invalidURL
    case invalidParams
    case responseDataIsEmpty
    case responseInvalidImageData
}

public enum SNCallSerializationType {
    case JSON
    case image
}

public typealias SNRouteReturnType = (method: SNMethod, path: SNPath, params: [String: Any?]?, headers: [String: String]?)

public protocol SNRouteProtocol {
    func construct() -> SNRouteReturnType
}

public protocol SNEnvironmentProtocol {
    func configure() -> SNEnvironment
}

open class SNCall {
    static var fixedHeaders = [String: String]()
    var headers: [String: String]?
    var method: SNMethod!
    var path: String
    var cachePolicy: URLRequest.CachePolicy?
    var timeoutInterval: TimeInterval?
    var params: [String: Any?]?
    private var pathType: SNPathType = .normal
    private var dataTask: URLSessionDataTask?
    
    //MARK: - Initializers
    public init(method: SNMethod, headers: [String: String]?, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?, path: SNPath, params: [String: Any?]?) {
        self.method = method
        self.headers = headers
        self.path = path.components.joined(separator: "/")
        self.cachePolicy = cachePolicy
        self.timeoutInterval = timeoutInterval
        self.params = params
    }
    
    public convenience init(method: SNMethod, headers: [String: String], path: SNPath, params: [String: Any?]?) {
        self.init(method: method, headers: headers, cachePolicy: nil, timeoutInterval: nil, path: path, params: params)
    }
    
    public convenience init(method: SNMethod, path: SNPath, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: path, params: nil)
    }

    public convenience init(route: SNRouteProtocol) {
        let params = route.construct()
        
        self.init(method: params.method, headers: params.headers, cachePolicy: nil, timeoutInterval: nil, path: params.path, params: params.params)
    }
    
    // Convenience method for passing a string instead of path
    public convenience init(method: SNMethod, url: String, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: SNPath("-"), params: nil)
        self.pathType = .full
        self.path = url
    }
    
    // MARK: - Create request
    public func asRequest() throws -> URLRequest {
        let urlString = pathType == .normal ? SNEnvironment.current.description + "/" + path : path
        
        guard let url = URL(string: urlString) else {
            throw SNError.invalidURL
        }
        
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: SNEnvironment.current.timeoutInterval)
        
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
    
    // Cancel data task
    public func cancel() {
        dataTask?.cancel()
    }
    
    // MARK: - Helper methods
    private func sessionDataTask(request: URLRequest, completionHandler: @escaping (Data)->(), onFailure: @escaping SNFailureCallback) throws -> URLSessionDataTask {
        dataTask = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            if error != nil {
                DispatchQueue.main.sync {
                    onFailure(error!)
                }
            }
            else if data == nil {
                DispatchQueue.main.sync {
                    onFailure(SNError.responseDataIsEmpty)
                }
            } else {
                completionHandler(data!)
            }
        }
        
        return dataTask!
    }
    
    // MARK: - Start requests
    
    // Deserialize objects with Decodable
    public func start<T>(onSuccess: @escaping SNSuccessCallback<T>, onFailure: @escaping SNFailureCallback) throws where T: Decodable {
        try sessionDataTask(request: try asRequest(), completionHandler: { data in
            let jsonDecoder = JSONDecoder()
            let object = try! jsonDecoder.decode(T.self, from: data)
            
            DispatchQueue.main.sync {
                onSuccess(object)
            }

        }, onFailure: onFailure).resume()
    }
    
    // Deserialize objects with UIImage
    public func start<T>(onSuccess: @escaping SNSuccessCallback<T>, onFailure: @escaping SNFailureCallback) throws where T: UIImage {
        try sessionDataTask(request: try asRequest(), completionHandler: { data in
            let image = T(data: data)
            
            if image == nil {
                DispatchQueue.main.sync {
                    onFailure(SNError.responseInvalidImageData)
                }
            } else {
                DispatchQueue.main.sync {
                    onSuccess(image!)
                }
            }
        }, onFailure: onFailure).resume()
    }
    
    // For any other object
    public func start(onSuccess: @escaping SNSuccessCallback<Data>, onFailure: @escaping SNFailureCallback) throws {
        try sessionDataTask(request: try asRequest(), completionHandler: { data in
            DispatchQueue.main.sync {
                onSuccess(data)
            }
        }, onFailure: onFailure).resume()
    }
}
