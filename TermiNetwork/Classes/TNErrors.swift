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
    case invalidParams
}

// Errors after execution of a request
public enum TNResponseError: Error {
    case responseDataIsEmpty
    case responseInvalidImageData
    case cannotDeserialize(Error)
    case networkError(Error)
    case notSuccess(Int)
    case cancelled(Error)
}

extension TNRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The URL is invalid", comment: "TNResponseError")
        case .environmentNotSet:
            return NSLocalizedString("Environment not set, use TNEnvironment.set(YOUR_ENVIRONMENT)", comment: "TNResponseError")
        case .invalidParams:
            return NSLocalizedString("The parameters are not valid", comment: "TNResponseError")
        }
    }
}

extension TNResponseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .responseDataIsEmpty:
            return NSLocalizedString("The response data is empty. Set TNCall.allowEmptyResponseBody to true to avoid this error", comment: "TNResponseError")
        case .responseInvalidImageData:
            return NSLocalizedString("The response data is not a valid image", comment: "TNResponseError")
        case .cannotDeserialize(let error):
            let debugDescription = (error as NSError).userInfo["NSDebugDescription"] as! String
            let errorKey = ((error as NSError).userInfo["NSCodingPath"] as! [Any]).last!
            let fullDescription = "\(debugDescription) Key: \(errorKey)"
            return NSLocalizedString("Cannot deserialize object: \(fullDescription)", comment: "TNResponseError")
        case .networkError(let error):
            return NSLocalizedString("Network error: \(error)", comment: "TNResponseError")
        case .notSuccess(let error):
            return NSLocalizedString("The request doesn't return 2xx status code: \(error)", comment: "TNResponseError")
        case .cancelled(let error):
            return NSLocalizedString("The request has been cancelled: \(error)", comment: "TNResponseError")
        }
    }
}
