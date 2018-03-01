//
//  TNErrors.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 25/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

// Errors before execution of a request
public enum TNRequestError: Error {
    case invalidURL
    case environmentNotSet
}

// Errors after execution of a request
public enum TNResponseError: Error {
    case responseDataIsEmpty
    case responseInvalidImageData
    case cannotDeserialize
    case networkError(Error)
    case notSuccess(Int)
    case cancelled(Error)
}
