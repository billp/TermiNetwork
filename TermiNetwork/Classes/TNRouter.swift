//
//  TNRouter.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 06/03/2018.
//

import Foundation

// MARK: - Custom types
public typealias TNRouteReturnType = (method: TNMethod, path: TNPath, params: [String: Any?]?, headers: [String: String]?)

// MARK: - Protocols
public protocol TNRouteProtocol {
    func construct() -> TNRouteReturnType
}

// MARK: - Default router helpers
extension TNRouteProtocol {
    public static func makeCall<T, R: TNRouteProtocol>(route: R, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) where T: Decodable {
        try? TNCall(route: route).start(onSuccess: onSuccess, onFailure: onFailure)
    }
    
    public static func makeCall<T, R: TNRouteProtocol>(route: R, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) where T: UIImage {
        try? TNCall(route: route).start(onSuccess: onSuccess, onFailure: onFailure)
    }
    
    public static func makeCall<R: TNRouteProtocol>(route: R, onSuccess: @escaping TNSuccessCallback<Data>, onFailure: @escaping TNFailureCallback) {
        try? TNCall(route: route).start(onSuccess: onSuccess, onFailure: onFailure)
    }
}
