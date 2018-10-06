//
//  TNQueue.swift
//  Pods-TermiNetwork_Example
//
//  Created by Vasilis Panagiotopoulos on 28/05/2018.
//

import Foundation

public enum TNQueueFailureMode {
    case cancelAll
    case `continue`
}

public typealias TNBeforeAllRequestsCallbackType = ()->()
public typealias TNAfterAllRequestsCallbackType = (_ error: Bool)->()
public typealias TNBeforeEachRequestCallbackType = (_ request: TNRequest)->()
public typealias TNAfterEachRequestCallbackType = (_ request: TNRequest, _ data: Data?, _ response: URLResponse?, _ error: Error?)->()

open class TNQueue: OperationQueue {
    // MARK: - Static variables
    public static var shared = TNQueue()
    
    // MARK: - Private variables
    private var completedWithError = false
    
    // MARK: - Pulblic variables
    public var beforeAllRequestsCallback: TNBeforeAllRequestsCallbackType?
    public var afterAllRequestsCallback: TNAfterAllRequestsCallbackType?
    public var beforeEachRequestCallback: TNBeforeEachRequestCallbackType?
    public var afterEachRequestCallback: TNAfterEachRequestCallbackType?
    
    var failureMode: TNQueueFailureMode!
    
    /**
     Initializes a new queue.
     
     - parameters:
        - failureMode: Supported values are .continue (continues the execution of queue even if a request fails, this is the default) and .cancelAll (cancels all the remaining requests in queue)
     */
    public init(failureMode: TNQueueFailureMode = .continue) {
        super.init()
        
        self.failureMode = failureMode
    }
    
    internal func beforeOperationStart(request: TNRequest) {
        if operationCount == 0 {
            beforeAllRequestsCallback?()
        }
        beforeEachRequestCallback?(request)
    }
    
    internal func afterOperationFinished(request: TNRequest, data: Data?, response: URLResponse?, error: Error?) {
        self.completedWithError = error != nil ? true : self.completedWithError
        
        if self.operationCount == 0 {
            afterAllRequestsCallback?(self.completedWithError)
            self.completedWithError = false
        }
        
        afterEachRequestCallback?(request, data, response, error)
    }
}
