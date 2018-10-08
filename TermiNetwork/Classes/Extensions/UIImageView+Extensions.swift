//
//  UIImageView+Extensions.swift
//  Pods-TermiNetwork_Example
//
//  Created by Vasilis Panagiotopoulos on 08/05/2018.
//

import UIKit

extension UIImageView {
    private static var activeRequestsHashMap: [String: TNRequest] = [:]
    private static var imageViewQueue: TNQueue = TNQueue()

    fileprivate static func downloadImage(url: String, onSuccess: @escaping TNSuccessCallback<UIImage>, onFailure: @escaping TNFailureCallback) throws -> TNRequest {
        let request = TNRequest(method: .get, url: url, params: nil)
        try request.start(queue: imageViewQueue, onSuccess: onSuccess, onFailure: onFailure)
        
        return request
    }

    /**
     Sets a remote image from url
     
     - parameters:
         - url: The url of the remote image
         - defaultImage: the UIImage showed while the image url is downloading (optional)
         - beforeStart: a block of code executed before image download (optional)
         - preprocessImage: a block of code that preprocess the image before showing. It should return the new image. This block will run in the background thread (optional)
         - onFinish: a block of code executed after the completion of the download image request. It may fail so error will be returned in that case (optional)
     */
    public func setRemoteImage(url: String, defaultImage: UIImage? = nil, beforeStart: (()->())? = nil, preprocessImage: ((UIImage)->(UIImage))? = nil, onFinish: ((UIImage?, Error?)->())? = nil) throws {
        
        self.image = defaultImage
        
        beforeStart?()
        
        cancelActiveCallInImageView()
        
        setActiveCallInImageView(try UIImageView.downloadImage(url: url, onSuccess: { image in
            var image = image
            
            DispatchQueue.global(qos: .background).async {
                image = preprocessImage?(image) ?? image
                
                DispatchQueue.main.async {
                    self.image = image
                    onFinish?(image, nil)
                }
            }
        }, onFailure: { error, data in
            self.image = nil
            onFinish?(nil, error)
        }))
    }
    
    // MARK: - Helpers
    private func getAddress() -> String {
        return String(describing: Unmanaged.passUnretained(self).toOpaque())
    }
    
    private func cancelActiveCallInImageView() {
        UIImageView.activeRequestsHashMap[getAddress()]?.cancel()
    }
    
    private func setActiveCallInImageView(_ call: TNRequest) {
        UIImageView.activeRequestsHashMap[getAddress()] = call
    }
}
