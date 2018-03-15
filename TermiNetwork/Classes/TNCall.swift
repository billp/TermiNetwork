//
//  TNCall.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

//MARK: - Custom types
public typealias TNSuccessCallback<T> = (T)->()
public typealias TNFailureCallback = (TNResponseError, Data?)->()


//MARK: - Enums
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

public enum TNCallSerializationType {
    case JSON
    case image
}

open class TNCall {
    //MARK: - Static properties
    public static var fixedHeaders = [String: String]()
    public static var allowEmptyResponseBody = false
    
    //MARK: - Instance properties
    var headers: [String: String]?
    var method: TNMethod!
    var path: String
    var cachePolicy: URLRequest.CachePolicy
    var timeoutInterval: TimeInterval?
    var params: [String: Any?]?
    private var pathType: SNPathType = .normal
    private var dataTask: URLSessionDataTask?
    
    //MARK: - Initializers
    public init(method: TNMethod, headers: [String: String]?, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?, path: TNPath, params: [String: Any?]?) {
        self.method = method
        self.headers = headers
        self.path = path.components.joined(separator: "/")
        self.cachePolicy = cachePolicy ?? .useProtocolCachePolicy
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
        let route = route.construct()
        
        self.init(method: route.method, headers: route.headers, cachePolicy: nil, timeoutInterval: nil, path: route.path, params: route.params)
    }
    
    public convenience init(route: TNRouteProtocol, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?) {
        let params = route.construct()
        
        self.init(method: params.method, headers: params.headers, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval, path: params.path, params: params.params)
    }
    
    // Convenience method for passing a string instead of path
    public convenience init(method: TNMethod, url: String, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: TNPath("-"), params: nil)
        self.pathType = .full
        self.path = url
    }
    
    // MARK: - Create request
    public func asRequest() throws -> URLRequest {
        guard let currentEnvironment = TNEnvironment.current else { throw TNRequestError.environmentNotSet }
        
        let urlString = NSMutableString()
        
        if pathType == .normal {
            urlString.setString(currentEnvironment.description + "/" + path)
        }  else {
            urlString.setString(path)
        }
        
        // Create query string from the given params
        let queryString = try params?.map { param -> String in
            if let key = param.key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed), let value = (param.value as? String)?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                return key + "=" + value
            } else {
                throw TNRequestError.invalidParams
            }
        }.joined(separator: "&")
        
        // Append query string to url in case of .get method
        if method == .get && queryString != nil {
            urlString.append("?" + queryString!)
        }
        
        guard let url = URL(string: urlString as String) else {
            throw TNRequestError.invalidURL
        }
        
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: currentEnvironment.timeoutInterval)
        
        if headers == nil && TNCall.fixedHeaders.keys.count > 0 {
            headers = [:]
        }
        headers?.merge(TNCall.fixedHeaders, uniquingKeysWith: { (_, new) in new })

        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        request.httpMethod = method.rawValue
        
        if timeoutInterval != nil {
            request.timeoutInterval = timeoutInterval!
        }
        
        // Set body params if method is not get
        if method != .get {
            request.httpBody = queryString?.data(using: .utf8)
        }

        return request
    }
    
    // Cancelation
    public func cancel() {
        dataTask?.cancel()
    }
    
    // MARK: - Helper methods
    private func sessionDataTask(request: URLRequest, completionHandler: @escaping (Data)->(), onFailure: @escaping TNFailureCallback) throws -> URLSessionDataTask {
        
        dataTask = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            var customError: TNResponseError?
            var statusCode: Int?
            
            // Error handling
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    customError = TNResponseError.cancelled(error)
                } else {
                    customError = TNResponseError.networkError(error)
                }
            }
            
            if let response = urlResponse as? HTTPURLResponse{
                statusCode = response.statusCode as Int?
            
                if statusCode != nil && statusCode! / 100 != 2 {
                    customError = TNResponseError.notSuccess(statusCode!)
                }
            }
            
            if customError != nil {
                _ = TNLog(call: self, message: "Error: " + (error?.localizedDescription ?? "")! + ", urlResponse:" + (urlResponse?.description ?? "")!)
                
                DispatchQueue.main.sync {
                    onFailure(customError!, data)
                }
            }
            else if data == nil && !TNCall.allowEmptyResponseBody {
                _ = TNLog(call: self, message: "Empty body received")
                
                DispatchQueue.main.sync {
                    onFailure(TNResponseError.responseDataIsEmpty, data)
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
        let request = try asRequest()

        try sessionDataTask(request: request, completionHandler: { data in
            
            let object: T!
            
            do {
                object = try data.deserializeJSONData() as T
            } catch let error {
                _ = TNLog(call: self, message: "Cannot deserialize data. Check your models", responseData: data)
                onFailure(TNResponseError.cannotDeserialize(error), data)
                return
            }
            
            _ = TNLog(call: self, message: "Successfully deserialized data", responseData: data)

            DispatchQueue.main.sync {
                onSuccess(object)
            }
        }, onFailure: onFailure).resume()
    }
    
    // Deserialize objects with UIImage
    public func start<T>(onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: UIImage {
        let request = try asRequest()
        
        try sessionDataTask(request: request, completionHandler: { data in
            let image = T(data: data)
            
            if image == nil {
                _ = TNLog(call: self, message: "Unable to deserialize image (data not an image)")

                DispatchQueue.main.sync {
                    onFailure(TNResponseError.responseInvalidImageData, data)
                }
            } else {
                DispatchQueue.main.sync {
                    _ = TNLog(call: self, message: "Successfully deserialized image")

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
