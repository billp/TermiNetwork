//
//  TNRequest.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

// Backward compatibility for TNCall (is being replaced with TNRequest)
@available(*, deprecated, message: "TNCall is deprecated and will be removed from future releases. Use TNRequest instead")
public typealias TNCall = TNRequest

//MARK: - Custom types
public typealias TNSuccessCallback<T> = (T)->()
public typealias TNFailureCallback = (_ error: TNResponseError, _ data: Data?)->()


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

open class TNRequest: TNOperation {
    //MARK: - Static properties
    public static var fixedHeaders = [String: String]()
    public static var allowEmptyResponseBody = false
    public static var requestBodyType: TNRequestBodyType = .xWWWFormURLEncoded
    static private var numberOfRequestsStarted: Int = 0

    //MARK: - Instance properties
    internal var method: TNMethod!
    private var headers: [String: String]?
    public var cachePolicy: URLRequest.CachePolicy
    public var timeoutInterval: TimeInterval?
    private var path: String
    private var params: [String: Any?]?
    private var pathType: SNPathType = .normal
    private var dataTask: URLSessionDataTask?
    private var currentQueue: TNQueue!
    private var data: Data?
    private var urlResponse: URLResponse?
    private var error: TNResponseError?
    
    public var skipBeforeAfterAllRequestsHooks: Bool = false
    internal var cachedRequest: URLRequest!
    
    //MARK: - Initializers
    /**
     Initializes a TNRequest request
     
     - parameters:
         - method:
            The http method of request, e.g. .get, .post, .head, etc.
         - headers: A Dictionary of header values, etc. ["Content-type": "text/html"] (optional)
         - cachePolicy: Cache policy of type URLRequest.CachePolicy. See Apple's documentation for details (optional)
         - timeoutInterval: Timeout interval of request in seconds (optional)
         - path: The path that is appended to your Environments current hostname and prefix. Use 'path(...)' for this, e.g. path("user", "5"), it generates http//website.com/user/5
         - params: A Dictionary that is send as request params. If method is .get it automatically appends them to url, otherwise it sets them as request body.
     */
    public init(method: TNMethod, headers: [String: String]?, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?, path: TNPath, params: [String: Any?]?) {
        self.method = method
        self.headers = headers
        self.path = path.components.joined(separator: "/")
        self.cachePolicy = cachePolicy ?? .useProtocolCachePolicy
        self.timeoutInterval = timeoutInterval
        self.params = params
    }
    
    /**
     Initializes a TNRequest request
     
     - parameters:
         - method:
         The http method of request, e.g. .get, .post, .head, etc.
         - headers: A Dictionary of header values, etc. ["Content-type": "text/html"] (optional)
         - path: The path that is appended to your Environments current hostname and prefix. Use 'path(...)' for this, e.g. path("user", "5"), it generates http//website.com/user/5
         - params: A Dictionary that is send as request params. If method is .get it automatically appends them to url, otherwise it sets them as request body.
     */
    public convenience init(method: TNMethod, headers: [String: String], path: TNPath, params: [String: Any?]?) {
        self.init(method: method, headers: headers, cachePolicy: nil, timeoutInterval: nil, path: path, params: params)
    }
    
    /**
     Initializes a TNRequest request
     
     - parameters:
         - method:
         The http method of request, e.g. .get, .post, .head, etc.
         - path: The path that is appended to your Environments current hostname and prefix. Use 'path(...)' for this, e.g. path("user", "5"), it generates http//website.com/user/5
         - params: A Dictionary that is send as request params. If method is .get it automatically appends them to url, otherwise it sets them as request body.
     */
    public convenience init(method: TNMethod, path: TNPath, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: path, params: nil)
    }

    /**
     Initializes a TNRequest request
     
     - parameters:
         - route: a TNRouteProtocol enum value
     */
    public convenience init(route: TNRouteProtocol) {
        let route = route.construct()
        
        self.init(method: route.method, headers: route.headers, cachePolicy: nil, timeoutInterval: nil, path: route.path, params: route.params)
    }
    
    /**
     Initializes a TNRequest request
     
     - parameters:
        - route: a TNRouteProtocol enum value
        - cachePolicy: Cache policy of type URLRequest.CachePolicy. See Apple's documentation for details (optional)
     */
    public convenience init(route: TNRouteProtocol, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?) {
        let params = route.construct()
        
        self.init(method: params.method, headers: params.headers, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval, path: params.path, params: params.params)
    }
    
    // Convenience method for passing a string instead of path
    /**
     Initializes a TNRequest request
     
     - parameters:
        - route: a TNRouteProtocol enum value
        - cachePolicy: Cache policy of type URLRequest.CachePolicy. See Apple's documentation for details (optional)
        - params: A Dictionary that is send as request params. If method is .get it automatically appends them to url, otherwise it sets them as request body.
     */
    public convenience init(method: TNMethod, url: String, params: [String: Any?]?) {
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: TNPath("-"), params: nil)
        self.pathType = .full
        self.path = url
    }
    
    // MARK: - Create request
    /**
     Converts a TNRequest instance to asRequest
    */
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
        if headers == nil && TNRequest.fixedHeaders.keys.count > 0 {
            headers = [:]
        }
        headers?.merge(TNRequest.fixedHeaders, uniquingKeysWith: { (_, new) in new })
        
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
            request.addValue(TNRequest.requestBodyType.rawValue, forHTTPHeaderField: "Content-Type")
            
            if TNRequest.requestBodyType == .xWWWFormURLEncoded {
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
    /**
     Cancels a TNRequest started request
     */
    open override func cancel() {
        super.cancel()
        dataTask?.cancel()
    }
    
    // MARK: - Helper methods
    private func sessionDataTask(request: URLRequest, completionHandler: ((Data)->())?, onFailure: TNFailureCallback?) -> URLSessionDataTask {
        
        // FIXME: Remove comments
        // Call hooks if needed
        /*if TNRequest.numberOfRequestsStarted == 0 && !skipBeforeAfterAllRequestsHooks {
            DispatchQueue.main.async {
                TNRequest.beforeAllRequestsBlock?()
            }
        }*/
        //TNRequest.beforeEachRequestBlock?(self)
        //increaseStartedRequests()
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            var customError: TNResponseError?
            var statusCode: Int?
            
            self.data = data
            
            // FIXME: Remove comments
            /*self.decreaseStartedRequests()
            TNRequest.afterEachRequestBlock?(self, data, urlResponse, error)
            if TNRequest.numberOfRequestsStarted == 0 && !self.skipBeforeAfterAllRequestsHooks {
                DispatchQueue.main.async {
                    TNRequest.afterAllRequestsBlock?()
                }
            }*/
            
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
            
            if (data == nil || data!.isEmpty) && !TNRequest.allowEmptyResponseBody {
                _ = TNLog(call: self, message: "Empty body received")
                
                customError = TNResponseError.responseDataIsEmpty
            }
            
            if let customError = customError {
                _ = TNLog(call: self, message: "Error: " + (error?.localizedDescription ?? "")! + ", urlResponse:" + (urlResponse?.description ?? "")!)
                
                DispatchQueue.main.sync {
                    onFailure?(customError, data)
                }
            } else {
                completionHandler?(data!)
            }
        }
        
        return dataTask
    }
    
    // FIXME: Remove comment
    /*
    private func increaseStartedRequests() {
        if !skipBeforeAfterAllRequestsHooks {
            TNRequest.numberOfRequestsStarted += 1
        }
    }
    private func decreaseStartedRequests() {
        if !skipBeforeAfterAllRequestsHooks {
            TNRequest.numberOfRequestsStarted -= 1
        }
    }*/
    
    // MARK: - Operation
    open override func start() {
        _executing = true
        _finished = false
        dataTask?.resume()
    }
    
    func handleDataTaskCompleted() {
        _executing = false
        _finished = true
        
        currentQueue.operationFinished(request: self, data: data, response: urlResponse, error: error)
    }
    
    func handleDataTaskFailure() {
        switch currentQueue.failureMode {
        case .continue?:
            break
        case .cancelAll?:
            currentQueue.cancelAllOperations()
        default:
            break
        }
        
        _executing = false
        _finished = true
        
        currentQueue.operationFinished(request: self, data: data, response: urlResponse, error: error)
    }
    
    // Deserialize objects with Decodable
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type Decodable
     
     - parameters:
        - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
        - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
        - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public func start<T>(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) throws where T: Decodable {
        currentQueue = queue ?? TNQueue.shared
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            let object: T!
            
            do {
                object = try data.deserializeJSONData() as T
            } catch let error {
                _ = TNLog(call: self, message: error.localizedDescription, responseData: data)
                onFailure?(TNResponseError.cannotDeserialize(error), data)
                self.handleDataTaskFailure()
                return
            }
            
            _ = TNLog(call: self, message: "Successfully deserialized data (\(String(describing: T.self)))", responseData: data)

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
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type UIImage
     
     - parameters:
         - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
         - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
         - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public func start<T>(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) throws where T: UIImage {
        currentQueue = queue
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            let image = T(data: data)
            
            if image == nil {
                _ = TNLog(call: self, message: "Unable to deserialize image (data not an image)")

                DispatchQueue.main.sync {
                    onFailure?(TNResponseError.responseInvalidImageData, data)
                }
                self.handleDataTaskFailure()
            } else {
                DispatchQueue.main.sync {
                    _ = TNLog(call: self, message: "Successfully deserialized image")

                    onSuccess?(image!)
                }
                self.handleDataTaskCompleted()
            }
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
    
    // For any other object
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type Data
     
     - parameters:
         - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
         - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
         - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public func start(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<Data>?, onFailure: TNFailureCallback?) throws {
        currentQueue = queue
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            DispatchQueue.main.async {
                onSuccess?(data)
            }
            self.handleDataTaskCompleted()
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
}
