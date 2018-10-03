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
