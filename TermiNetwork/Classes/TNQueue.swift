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

public typealias completedCallbackType = ((Bool)->())

open class TNQueue: OperationQueue {
    // MARK: - Static variables
    public static var shared = TNQueue()
    
    // MARK: - Private variables
    private var completedWithError = false
    
    // MARK: - Pulblic variables
    public var completedCallback: completedCallbackType?
    
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
    
    func operationFinished(error: Bool) {
        
        // Keep if there is an error if any request failed
        self.completedWithError = error == true ? true : self.completedWithError
        
        if error {
            print("error")
        }
        
        if self.operationCount == 0 {
            completedCallback?(self.completedWithError)
            self.completedWithError = false
        }
        
    }
}
