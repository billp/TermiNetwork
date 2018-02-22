//
//  Environment.swift
//  ServiceRouter
//
//  Created by Vasilis Panagiotopoulos on 15/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

public struct TNPath {
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

public typealias path = TNPath
