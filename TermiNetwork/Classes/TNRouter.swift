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

extension TNRouteProtocol {
    public static func makeCall<T: Decodable, R: TNRouteProtocol>(route: R, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) {
        try? TNCall(route: route, cachePolicy: nil, timeoutInterval: 15).start(onSuccess: onSuccess, onFailure: onFailure)
    }
}
