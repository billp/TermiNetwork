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
public typealias TNFailureCallback = (_ error: TNResponseError, _ data: Data?)->()
public typealias TNBeforeAllRequestsCallback = ()->()
public typealias TNAfterAllRequestsCallback = ()->()
public typealias TNBeforeEachRequestCallback = (_ call: TNCall)->()
public typealias TNAfterEachRequestCallback = (_ call: TNCall, _ data: Data?, _ response: URLResponse?, _ error: Error?)->()

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

public enum TNRequestBodyType: String {
    case xWWWFormURLEncoded = "application/x-www-form-urlencoded"
    case JSON = "application/json"
}

open class TNCall: TNOperation {
    //MARK: - Static properties
    public static var fixedHeaders = [String: String]()
    public static var allowEmptyResponseBody = false
    public static var requestBodyType: TNRequestBodyType = .xWWWFormURLEncoded
    static private var numberOfRequestsStarted: Int = 0

    //MARK: - Instance properties
    private var headers: [String: String]?
    private var method: TNMethod!
    private var path: String
    private var cachePolicy: URLRequest.CachePolicy
    private var timeoutInterval: TimeInterval?
    private var params: [String: Any?]?
    private var pathType: SNPathType = .normal
    private var dataTask: URLSessionDataTask?
    private var currentQueue: TNQueue!
    
    public var skipBeforeAfterAllRequestsHooks: Bool = false
    internal var cachedRequest: URLRequest!
    

    // Hooks
    public static var beforeAllRequestsBlock: TNBeforeAllRequestsCallback?
    public static var afterAllRequestsBlock: TNAfterAllRequestsCallback?
    public static var beforeEachRequestBlock: TNBeforeEachRequestCallback?
    public static var afterEachRequestBlock: TNAfterEachRequestCallback?
    
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
        
        if cachedRequest != nil {
            return cachedRequest!
        }
        
        let urlString = NSMutableString()
        
        if pathType == .normal {
            urlString.setString(currentEnvironment.description + "/" + path)
        }  else {
            urlString.setString(path)
        }
        
        // Create query string from the given params
        let queryString = try params?.filter({ $0.value != nil }).map { param -> String in
            if let value = String(describing: param.value!).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
                return param.key + "=" + value
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
        
        // Add headers
        if headers == nil && TNCall.fixedHeaders.keys.count > 0 {
            headers = [:]
        }
        headers?.merge(TNCall.fixedHeaders, uniquingKeysWith: { (_, new) in new })
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        if let timeoutInterval = timeoutInterval {
            request.timeoutInterval = timeoutInterval
        }
        
        // Set http method
        request.httpMethod = method.rawValue
        
        // Set body params if method is not get
        if method != .get {
            request.addValue(TNCall.requestBodyType.rawValue, forHTTPHeaderField: "Content-Type")
            
            if TNCall.requestBodyType == .xWWWFormURLEncoded {
                request.httpBody = queryString?.data(using: .utf8)
            } else {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params ?? [], options: .prettyPrinted)
                } catch {
                    throw TNRequestError.invalidParams
                }
            }
        }
        
        cachedRequest = request

        return request
    }
    
    // Cancelation
    open override func cancel() {
        super.cancel()
        dataTask?.cancel()
    }
    
    // MARK: - Helper methods
    private func sessionDataTask(request: URLRequest, completionHandler: ((Data)->())?, onFailure: TNFailureCallback?) -> URLSessionDataTask {
        
        // Call hooks if needed
        if TNCall.numberOfRequestsStarted == 0 && !skipBeforeAfterAllRequestsHooks {
            DispatchQueue.main.async {
                TNCall.beforeAllRequestsBlock?()
            }
        }
        TNCall.beforeEachRequestBlock?(self)
        increaseStartedRequests()
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            var customError: TNResponseError?
            var statusCode: Int?
            
            self.decreaseStartedRequests()
            TNCall.afterEachRequestBlock?(self, data, urlResponse, error)
            if TNCall.numberOfRequestsStarted == 0 && !self.skipBeforeAfterAllRequestsHooks {
                DispatchQueue.main.async {
                    TNCall.afterAllRequestsBlock?()
                }
            }
            
            // Error handling
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    customError = TNResponseError.cancelled(error)
                } else {
                    customError = TNResponseError.networkError(error)
                }
            }
            else if let response = urlResponse as? HTTPURLResponse {
                statusCode = response.statusCode as Int?
            
                if statusCode != nil && statusCode! / 100 != 2 {
                    customError = TNResponseError.notSuccess(statusCode!)
                }
            }
            
            if customError != nil {
                _ = TNLog(call: self, message: "Error: " + (error?.localizedDescription ?? "")! + ", urlResponse:" + (urlResponse?.description ?? "")!)
                
                DispatchQueue.main.sync {
                    onFailure?(customError!, data)
                }
            }
            else if (data == nil || data!.isEmpty) && !TNCall.allowEmptyResponseBody {
                _ = TNLog(call: self, message: "Empty body received")
                
                DispatchQueue.main.sync {
                    onFailure?(TNResponseError.responseDataIsEmpty, data)
                }
            } else {
                completionHandler?(data!)
            }
        }
        
        return dataTask
    }
    
    func increaseStartedRequests() {
        if !skipBeforeAfterAllRequestsHooks {
            TNCall.numberOfRequestsStarted += 1
        }
    }
    func decreaseStartedRequests() {
        if !skipBeforeAfterAllRequestsHooks {
            TNCall.numberOfRequestsStarted -= 1
        }
    }
    
    // MARK: - Operation
    open override func start() {
        _executing = true
        _finished = false
        dataTask?.resume()
    }
    
    func handleDataTaskCompleted() {
        _executing = false
        _finished = true
    }
    
    func handleDataTaskFailure() {
        switch currentQueue.failureMode {
        case .continue:
            break
        case .stop:
            currentQueue.cancelAllOperations()
        }
        
        _executing = false
        _finished = true
    }
    
    // Deserialize objects with Decodable
    public func start<T>(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) throws where T: Decodable {
        currentQueue = queue ?? TNQueue.shared
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            let object: T!
            
            do {
                object = try data.deserializeJSONData() as T
            } catch let error {
                _ = TNLog(call: self, message: error.localizedDescription, responseData: data)
                onFailure?(TNResponseError.cannotDeserialize(error), data)
                return
            }
            
            _ = TNLog(call: self, message: "Successfully deserialized data", responseData: data)

            DispatchQueue.main.sync {
                onSuccess?(object)
            }
            
            self.handleDataTaskCompleted()
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
    
    // Deserialize objects with UIImage
    public func start<T>(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) throws where T: UIImage {
        currentQueue = queue
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            let image = T(data: data)
            
            if image == nil {
                _ = TNLog(call: self, message: "Unable to deserialize image (data not an image)")

                DispatchQueue.main.sync {
                    onFailure?(TNResponseError.responseInvalidImageData, data)
                }
            } else {
                DispatchQueue.main.sync {
                    _ = TNLog(call: self, message: "Successfully deserialized image")

                    onSuccess?(image!)
                }
            }
        }, onFailure: onFailure)
        
        currentQueue.addOperation(self)
    }
    
    // For any other object
    public func start(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<Data>?, onFailure: TNFailureCallback?) throws {
        currentQueue = queue
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            DispatchQueue.main.async {
                onSuccess?(data)
            }
        }, onFailure: onFailure)
        
        currentQueue.addOperation(self)
    }
}
