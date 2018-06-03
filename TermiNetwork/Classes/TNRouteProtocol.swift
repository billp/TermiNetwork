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
    /**
     Wrapper method that starts a TNCall requess. The response object in success callback is of type Decodable.
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - skipBeforeAfterAllRequestsHooks: A boolean that indicates if the request takes part to beforeAllRequests/afterAllRequests. Default value is true (optional)
     - route: a TNRouteProtocol enum value
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public static func makeCall<T, R: TNRouteProtocol>(queue: TNQueue? = TNQueue.shared, skipBeforeAfterAllRequestsHooks: Bool = true, route: R, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: Decodable {
        let call = TNCall(route: route)
        call.skipBeforeAfterAllRequestsHooks = skipBeforeAfterAllRequestsHooks
        try call.start(queue: queue, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /**
     Wrapper method that starts a TNCall requess. The response object in success callback is of type UIImage.
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - skipBeforeAfterAllRequestsHooks: A boolean that indicates if the request takes part to beforeAllRequests/afterAllRequests. Default value is true (optional)
     - route: a TNRouteProtocol enum value
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public static func makeCall<T, R: TNRouteProtocol>(queue: TNQueue? = TNQueue.shared, skipBeforeAfterAllRequestsHooks: Bool = true, route: R, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: UIImage {
        let call = TNCall(route: route)
        call.skipBeforeAfterAllRequestsHooks = skipBeforeAfterAllRequestsHooks
        try call.start(queue: queue, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /**
     Wrapper method that starts a TNCall requess. The response object in success callback is of type Data.
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - skipBeforeAfterAllRequestsHooks: A boolean that indicates if the request takes part to beforeAllRequests/afterAllRequests. Default value is true (optional)
     - route: a TNRouteProtocol enum value
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public static func makeCall<R: TNRouteProtocol>(queue: TNQueue? = TNQueue.shared, skipBeforeAfterAllRequestsHooks: Bool = true, route: R, onSuccess: @escaping TNSuccessCallback<Data>, onFailure: @escaping TNFailureCallback) throws {
        let call = TNCall(route: route)
        call.skipBeforeAfterAllRequestsHooks = skipBeforeAfterAllRequestsHooks
        try call.start(queue: queue, onSuccess: onSuccess, onFailure: onFailure)
    }
}
