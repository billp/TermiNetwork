//
//  TNRequest.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 14/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation
import SwiftyJSON

// Backward compatibility for TNCall (is being replaced with TNRequest)
@available(*, deprecated, message: "TNCall is deprecated and will be removed from future releases. Use TNRequest instead")
public typealias TNCall = TNRequest

//MARK: - Custom types
public typealias TNSuccessCallback<T> = (T)->()
public typealias TNFailureCallback = (_ error: TNError, _ data: Data?)->()

// MARK: - DEPRECATED TYPES
public typealias TNBeforeAllRequestsCallback = ()->()
public typealias TNAfterAllRequestsCallback = ()->()
public typealias TNBeforeEachRequestCallback = (_ call: TNRequest)->()
public typealias TNAfterEachRequestCallback = (_ call: TNRequest, _ data: Data?, _ response: URLResponse?, _ error: Error?)->()

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

    // MARK: - Internal properties
    internal var method: TNMethod!
    internal var currentQueue: TNQueue!
    internal var dataTask: URLSessionDataTask?
    internal var customError: TNError?
    internal var data: Data?
    internal var urlResponse: URLResponse?
    internal var params: [String: Any?]?

    // MARK: - Private properties
    private var headers: [String: String]?
    private var path: String
    private var pathType: SNPathType = .normal

    
    // MARK: - Public properties
    public var cachePolicy: URLRequest.CachePolicy
    public var timeoutInterval: TimeInterval?
    public var requestBodyType: TNRequestBodyType = .xWWWFormURLEncoded
    
    // MARK: - Deprecations
    @available(*, deprecated, message: "beforeAllRequestsBlock Hook is deprecated and will be removed from future releases. Use TNQueue hooks instead. All TNCall hooks are forewarded to TNQueue.shared.[HOOK]. See docs for more info.")
    public static var beforeAllRequestsBlock: TNBeforeAllRequestsCallback? {
        didSet {
            TNQueue.shared.beforeAllRequestsCallback = {
                beforeAllRequestsBlock?()
            }
        }
    }
    @available(*, deprecated, message: "afterAllRequestsBlock Hook is deprecated and will be removed from future releases. Use TNQueue hooks instead. All TNCall hooks are forewarded to TNQueue.shared.[HOOK]. See docs for more info.")
    public static var afterAllRequestsBlock: TNAfterAllRequestsCallback? {
        didSet {
            TNQueue.shared.afterAllRequestsCallback = { _ in
                afterAllRequestsBlock?()
            }
        }
    }
    @available(*, deprecated, message: "beforeEachRequestBlock Hook is deprecated and will be removed from future releases. Use TNQueue hooks instead. All TNCall hooks are forewarded to TNQueue.shared.[HOOK]. See docs for more info.")
    public static var beforeEachRequestBlock: TNBeforeEachRequestCallback? {
        didSet {
            TNQueue.shared.beforeEachRequestCallback = { request in
                beforeEachRequestBlock?(request)
            }
        }
    }
    @available(*, deprecated, message: "afterEachRequestBlock Hook is deprecated and will be removed from future releases. Use TNQueue hooks instead. All TNCall hooks are forewarded to TNQueue.shared.[HOOK]. See docs for more info.")
    public static var afterEachRequestBlock: TNAfterEachRequestCallback? {
        didSet {
            TNQueue.shared.afterEachRequestCallback = { request, data, response, error in
                afterEachRequestBlock?(request, data, response, error)
            }
        }
    }

    @available(*, deprecated, message: "skipBeforeAfterAllRequestsHooks Hook is deprecated and will be removed from future releases.")
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
    public init(method: TNMethod, headers: [String: String]?, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?, path: TNPath, params: [String: Any?]?, requestBodyType: TNRequestBodyType? = nil) {
        self.method = method
        self.headers = headers
        self.path = path.components.joined(separator: "/")
        self.cachePolicy = cachePolicy ?? .useProtocolCachePolicy
        self.timeoutInterval = timeoutInterval
        self.params = params
        self.requestBodyType = requestBodyType ?? .xWWWFormURLEncoded
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
        let route = route.configure()
        
        self.init(method: route.method, headers: route.headers, cachePolicy: nil, timeoutInterval: nil, path: route.path, params: route.params, requestBodyType: route.requestBodyType)
    }
    
    /**
     Initializes a TNRequest request
     
     - parameters:
        - route: a TNRouteProtocol enum value
        - cachePolicy: Cache policy of type URLRequest.CachePolicy. See Apple's documentation for details (optional)
     */
    public convenience init(route: TNRouteProtocol, cachePolicy: URLRequest.CachePolicy?, timeoutInterval: TimeInterval?) {
        let route = route.configure()
        
        self.init(method: route.method, headers: route.headers, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval, path: route.path, params: route.params)
        self.requestBodyType = route.requestBodyType
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
        self.init(method: method, headers: nil, cachePolicy: nil, timeoutInterval: nil, path: TNPath("-"), params: params)
        self.pathType = .full
        self.path = url
    }
    
    // MARK: - Create request
    /**
     Converts a TNRequest instance to asRequest
    */
    public func asRequest() throws -> URLRequest {
        guard let currentEnvironment = TNEnvironment.current else { throw TNError.environmentNotSet }
        
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
                throw TNError.invalidParams
            }
        }.joined(separator: "&")
        
        // Append query string to url in case of .get method
        if method == .get && queryString != nil {
            urlString.append("?" + queryString!)
        }
        
        guard let url = URL(string: urlString as String) else {
            throw TNError.invalidURL
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
        if ![TNMethod.get, TNMethod.head].contains(method) {
            request.addValue(requestBodyType.rawValue, forHTTPHeaderField: "Content-Type")
            
            if requestBodyType == .xWWWFormURLEncoded {
                request.httpBody = queryString?.data(using: .utf8)
            } else {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params ?? [], options: .prettyPrinted)
                } catch {
                    throw TNError.invalidParams
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
    internal func sessionDataTask(request: URLRequest, completionHandler: ((Data)->())?, onFailure: TNFailureCallback?) -> URLSessionDataTask {
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            var statusCode: Int?
            self.data = data
            self.urlResponse = urlResponse

            // Error handling
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    self.customError = TNError.cancelled(error)
                } else {
                    self.customError = TNError.networkError(error)
                }
            }
            else if let response = urlResponse as? HTTPURLResponse {
                statusCode = response.statusCode as Int?
            
                if statusCode != nil && statusCode! / 100 != 2 {
                    self.customError = TNError.notSuccess(statusCode!)
                } else if (data == nil || data!.isEmpty) && !TNRequest.allowEmptyResponseBody {
                    self.customError = TNError.responseDataIsEmpty
                }
            }

            if let customError = self.customError {
                DispatchQueue.main.async {
                    TNLog.logRequest(request: self)
                    onFailure?(customError, data)
                    self.handleDataTaskFailure()
                }
            } else {
                completionHandler?(data!)
            }
        }
        
        return dataTask
    }
    
    func callBeforeRequestHoooks() {
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
        
        currentQueue.afterOperationFinished(request: self, data: data, response: urlResponse, error: customError)
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
        
        currentQueue.afterOperationFinished(request: self, data: data, response: urlResponse, error: customError)
    }
    
    // Deserialize objects with Decodable
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type Decodable
     
     - parameters:
        - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
        - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
        - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public func start<T>(queue: TNQueue? = TNQueue.shared, responseType: T.Type, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) where T: Decodable {
        currentQueue = queue ?? TNQueue.shared
        currentQueue.beforeOperationStart(request: self)
        
        let request: URLRequest!
        do {
            request = try asRequest()
        } catch let error {
            onFailure?(error as! TNError, nil)
            return
        }

        dataTask = sessionDataTask(request: request, completionHandler: { data in
            let object: T!
            
            do {
                object = try data.deserializeJSONData() as T
            } catch let error {
                self.customError = .cannotDeserialize(error)
                TNLog.logRequest(request: self)
                onFailure?(.cannotDeserialize(error), data)
                self.handleDataTaskFailure()
                return
            }
            
            DispatchQueue.main.sync {
                TNLog.logRequest(request: self)
                onSuccess?(object)
                self.handleDataTaskCompleted()
            }
            
            
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
    public func start<T>(queue: TNQueue? = TNQueue.shared, responseType: T.Type, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) where T: UIImage {
        currentQueue = queue
        currentQueue.beforeOperationStart(request: self)
        
        let request: URLRequest!
        do {
            request = try asRequest()
        } catch let error {
            onFailure?(error as! TNError, nil)
            return
        }

        dataTask = sessionDataTask(request: request, completionHandler: { data in
            let image = T(data: data)
            
            if image == nil {
                self.customError = .responseInvalidImageData
                TNLog.logRequest(request: self)

                DispatchQueue.main.sync {
                    onFailure?(.responseInvalidImageData, data)
                }
                self.handleDataTaskFailure()
            } else {
                DispatchQueue.main.sync {
                    TNLog.logRequest(request: self)
                    onSuccess?(image!)
                    self.handleDataTaskCompleted()
                }
            }
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
    
    // Swifty JSON
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type JSON (SwiftyJSON)
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public func start(queue: TNQueue? = TNQueue.shared, responseType: JSON.Type, onSuccess: TNSuccessCallback<JSON>?, onFailure: TNFailureCallback?) {
        currentQueue = queue
        currentQueue.beforeOperationStart(request: self)
        
        let request: URLRequest!
        do {
            request = try asRequest()
        } catch let error {
            onFailure?(error as! TNError, nil)
            return
        }
        
        dataTask = sessionDataTask(request: request, completionHandler: { data in
            DispatchQueue.main.async {
                TNLog.logRequest(request: self)
                do {
                    let json = try JSON(data: data)
                    TNLog.logRequest(request: self)
                    onSuccess?(json)
                    self.handleDataTaskCompleted()
                } catch let error {
                    let error = TNError.cannotConvertToJSON(error)
                    onFailure?(error, nil)
                    self.handleDataTaskFailure()
                }
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
    public func start(queue: TNQueue? = TNQueue.shared, responseType: Data.Type, onSuccess: TNSuccessCallback<Data>?, onFailure: TNFailureCallback?) {
        currentQueue = queue
        currentQueue.beforeOperationStart(request: self)
        
        let request: URLRequest!
        do {
            request = try asRequest()
        } catch let error {
            onFailure?(error as! TNError, nil)
            return
        }
        
        dataTask = sessionDataTask(request: request, completionHandler: { data in
            DispatchQueue.main.async {
                TNLog.logRequest(request: self)
                onSuccess?(data)
                self.handleDataTaskCompleted()
            }
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
}
