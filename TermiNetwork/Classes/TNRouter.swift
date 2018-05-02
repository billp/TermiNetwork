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
    public static func makeCall<T, R: TNRouteProtocol>(route: R, skipBeforeAfterAllRequestsHooks: Bool = false, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: Decodable {
        try TNCall(route: route).start(skipBeforeAfterAllRequestsHooks: skipBeforeAfterAllRequestsHooks, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    public static func makeCall<T, R: TNRouteProtocol>(route: R, skipBeforeAfterAllRequestsHooks: Bool = false, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: UIImage {
        try TNCall(route: route).start(skipBeforeAfterAllRequestsHooks: skipBeforeAfterAllRequestsHooks, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    public static func makeCall<R: TNRouteProtocol>(route: R, skipBeforeAfterAllRequestsHooks: Bool = false, onSuccess: @escaping TNSuccessCallback<Data>, onFailure: @escaping TNFailureCallback) throws {
        try TNCall(route: route).start(skipBeforeAfterAllRequestsHooks: skipBeforeAfterAllRequestsHooks, onSuccess: onSuccess, onFailure: onFailure)
    }
}
