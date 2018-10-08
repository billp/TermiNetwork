//
//  TNRouter.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 06/03/2018.
//

import Foundation

// MARK: - Custom types
public struct TNRouteConfiguration {
    var method: TNMethod
    var path: TNPath
    var params: [String: Any?]? = nil
    var headers: [String: String]? = nil
    var requestBodyType: TNRequestBodyType = .xWWWFormURLEncoded
    
    public init(method: TNMethod, path: TNPath, params: [String: Any?]? = nil, headers: [String: String]? = nil, requestBodyType: TNRequestBodyType = .xWWWFormURLEncoded) {
        self.method = method
        self.path = path
        self.params = params
        self.headers = headers
        self.requestBodyType = requestBodyType
    }
}

// MARK: - Protocols
public protocol TNRouteProtocol {
    func configure() -> TNRouteConfiguration
}
