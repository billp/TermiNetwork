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

open class TNQueue: OperationQueue {
    // MARK: - Static variables
    open static var shared = TNQueue()
    
    var failureMode: TNQueueFailureMode!
    
    /**
     Initializes a new queue.
     
     - parameters:
        - failureMode: Supported values are .continue (continues the execution of queue even if a request fails, this is the default) and .cancelAll (cancels all the remaining requests in queue)
     */
    public init(failureMode: TNQueueFailureMode = .continue) {
        self.failureMode = failureMode
    }
}
