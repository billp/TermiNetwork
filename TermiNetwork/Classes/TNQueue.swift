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
    
    public init(failureMode: TNQueueFailureMode = .continue) {
        self.failureMode = failureMode
    }
}
