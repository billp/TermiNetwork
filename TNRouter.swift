//
//  TNRouter.swift
//  Pods-TermiNetwork_Example
//
//  Created by Vasilis Panagiotopoulos on 03/10/2018.
//
import Foundation

open class TNRouter {
    /**
     Wrapper method that starts a TNRequest requess. The response object in success callback is of type Decodable.
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - skipBeforeAfterAllRequestsHooks: A boolean that indicates if the request takes part to beforeAllRequests/afterAllRequests. Default value is true (optional)
     - route: a TNRouteProtocol enum value
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public static func start<T, R: TNRouteProtocol>(queue: TNQueue? = TNQueue.shared, route: R, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: Decodable {
        let call = TNRequest(route: route)
        
        try call.start(queue: queue, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /**
     Wrapper method that starts a TNRequest requess. The response object in success callback is of type UIImage.
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - skipBeforeAfterAllRequestsHooks: A boolean that indicates if the request takes part to beforeAllRequests/afterAllRequests. Default value is true (optional)
     - route: a TNRouteProtocol enum value
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public static func start<T, R: TNRouteProtocol>(queue: TNQueue? = TNQueue.shared, route: R, responseType: T.Type, onSuccess: @escaping TNSuccessCallback<T>, onFailure: @escaping TNFailureCallback) throws where T: UIImage {
        let call = TNRequest(route: route)
        try call.start(queue: queue, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /**
     Wrapper method that starts a TNRequest requess. The response object in success callback is of type Data.
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - skipBeforeAfterAllRequestsHooks: A boolean that indicates if the request takes part to beforeAllRequests/afterAllRequests. Default value is true (optional)
     - route: a TNRouteProtocol enum value
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    public static func start<R: TNRouteProtocol>(queue: TNQueue? = TNQueue.shared, route: R, onSuccess: @escaping TNSuccessCallback<Data>, onFailure: @escaping TNFailureCallback) throws {
        let call = TNRequest(route: route)
        try call.start(queue: queue, onSuccess: onSuccess, onFailure: onFailure)
    }
}
