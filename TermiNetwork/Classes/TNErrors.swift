//
//  TNErrors.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 25/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

// Errors before execution of a request
public enum TNError: Error {
    case invalidURL
    case environmentNotSet
    case invalidParams
    case responseDataIsEmpty
    case responseInvalidImageData
    case cannotDeserialize(Error)
    case cannotConvertToJSON(Error)
    case networkError(Error)
    case notSuccess(Int)
    case cancelled(Error)
}

@available(*, deprecated, message: "and will be removed from future releases. Use TNError instead.")
typealias TNRequestError = TNError

extension TNError: LocalizedError {
    public var description: String {
        switch self {
        case .invalidURL:
            return NSLocalizedString("The URL is invalid", comment: "TNResponseError")
        case .environmentNotSet:
            return NSLocalizedString("Environment not set, use TNEnvironment.set(YOUR_ENVIRONMENT)", comment: "TNResponseError")
        case .invalidParams:
            return NSLocalizedString("The parameters are not valid", comment: "TNResponseError")
        case .responseDataIsEmpty:
            return NSLocalizedString("The response data is empty. Set TNRequest.allowEmptyResponseBody to true get rid of this error", comment: "TNResponseError")
        case .responseInvalidImageData:
            return NSLocalizedString("The response data is not a valid image", comment: "TNResponseError")
        case .cannotDeserialize(let error):
            let debugDescription = (error as NSError).userInfo["NSDebugDescription"] as! String
            var errorKeys = ""
            if let codingPath = (error as NSError).userInfo["NSCodingPath"] as? [CodingKey] {
                errorKeys = (codingPath.count > 0 ? " Key(s): " : "") + codingPath.map({
                    $0.stringValue
                }).joined(separator: ", ")
            }
            let fullDescription = "\(debugDescription)\(errorKeys)"
            return NSLocalizedString("Cannot deserialize object: \(fullDescription)", comment: "TNResponseError")
        case .networkError(let error):
                return NSLocalizedString("Network error: \(error)", comment: "TNResponseError")
        case .cannotConvertToJSON(let error):
            return NSLocalizedString("Cannot create JSON object (SwiftyJSON): \(error)", comment: "TNResponseError")
        case .notSuccess(let code):
            return NSLocalizedString("The request didn't return 2xx status code but \(code) instead", comment: "TNResponseError")
        case .cancelled(let error):
            return NSLocalizedString("The request has been cancelled: \(error)", comment: "TNResponseError")
        }
    }
}
