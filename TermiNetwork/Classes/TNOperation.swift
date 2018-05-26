//
//  TNOperation.swift
//  Pods-TermiNetwork_Example
//
//  Created by Vasilis Panagiotopoulos on 26/05/2018.
//

import Foundation

open class TNOperation: Operation {
    internal var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override open var isExecuting: Bool {
        return _executing
    }
    
    internal var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override open var isFinished: Bool {
        return _finished
    }
    
    func executing(_ executing: Bool) {
        _executing = executing
    }
    
    func finish(_ finished: Bool) {
        _finished = finished
    }
}
