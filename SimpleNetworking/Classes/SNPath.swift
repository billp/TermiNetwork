//
//  SNPath.swift
//  Nimble
//
//  Created by Vasilis Panagiotopoulos on 15/02/2018.
//

import Foundation

public struct SNPath {
    var components: [String]!
    
    public init(_ components: String...) {
        self.components = components
    }
    
    public init(_ components: [String]) {
        self.components = components
    }
}

internal enum SNPathType: Error {
    case normal
    case full
}

public typealias path = SNPath
