//
//  TNQueue.swift
//  Pods-TermiNetwork_Example
//
//  Created by Vasilis Panagiotopoulos on 28/05/2018.
//

import Foundation

enum TNQueueFailureMode {
    case stop
    case `continue`
}

open class TNQueue: OperationQueue {
    // MARK: - Static variables
    open static var shared = TNQueue()
    
    var failureMode: TNQueueFailureMode = .continue
}
