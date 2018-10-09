//
//  TNRequest_Deprecated.swift
//  Pods-TermiNetwork_Example
//
//  Created by Vasilis Panagiotopoulos on 08/10/2018.
//

import UIKit

extension TNRequest {
    // Deserialize objects with Decodable
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type Decodable
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    @available(*, deprecated, message: "and will be removed from future releases. Use start(queue:responseType:onSuccess:onFailure)  instead.")
    public func start<T>(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) throws where T: Decodable {
        currentQueue = queue ?? TNQueue.shared
        currentQueue.beforeOperationStart(request: self)
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            let object: T!
            
            do {
                object = try data.deserializeJSONData() as T
            } catch let error {
                self.customError = .cannotDeserialize(error)
                TNLog.logRequest(request: self)
                onFailure?(.cannotDeserialize(error), data)
                self.handleDataTaskFailure()
                return
            }
            
            DispatchQueue.main.sync {
                TNLog.logRequest(request: self)
                onSuccess?(object)
            }
            
            self.handleDataTaskCompleted()
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
    
    // Deserialize objects with UIImage
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type UIImage
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    @available(*, deprecated, message: "and will be removed from future releases. Use start(queue:responseType:onSuccess:onFailure)  instead.")
    public func start<T>(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<T>?, onFailure: TNFailureCallback?) throws where T: UIImage {
        currentQueue = queue
        currentQueue.beforeOperationStart(request: self)
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            let image = T(data: data)
            
            if image == nil {
                self.customError = .responseInvalidImageData
                TNLog.logRequest(request: self)
                
                DispatchQueue.main.sync {
                    onFailure?(.responseInvalidImageData, data)
                }
                self.handleDataTaskFailure()
            } else {
                DispatchQueue.main.sync {
                    TNLog.logRequest(request: self)
                    onSuccess?(image!)
                }
                self.handleDataTaskCompleted()
            }
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
    
    // For any other object
    /**
     Adds a request to a queue and starts it's execution. The response object in success callback is of type Data
     
     - parameters:
     - queue: A TNQueue instance. If no queue is specified it uses the default one. (optional)
     - onSuccess: specifies a success callback of type TNSuccessCallback<T> (optional)
     - onFailure: specifies a failure callback of type TNFailureCallback<T> (optional)
     */
    @available(*, deprecated, message: "and will be removed from future releases. Use start(queue:responseType:onSuccess:onFailure)  instead.")
    public func start(queue: TNQueue? = TNQueue.shared, onSuccess: TNSuccessCallback<Data>?, onFailure: TNFailureCallback?) throws {
        currentQueue = queue
        currentQueue.beforeOperationStart(request: self)
        
        dataTask = sessionDataTask(request: try asRequest(), completionHandler: { data in
            DispatchQueue.main.async {
                TNLog.logRequest(request: self)
                onSuccess?(data)
            }
            self.handleDataTaskCompleted()
        }, onFailure: { error, data in
            onFailure?(error, data)
            self.handleDataTaskFailure()
        })
        
        currentQueue.addOperation(self)
    }
}