//
//  APICustomHelpers.swift
//  SimpleNetworking_Example
//
//  Created by Vasilis Panagiotopoulos on 16/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import TermiNetwork

struct APICustomHelpers {
    static func getImage(url: String, onSuccess: @escaping TNSuccessCallback<UIImage>, onFailure: @escaping TNFailureCallback) throws -> TNRequest {
        let call = TNRequest(method: .get, url: url, headers: nil, params: nil)
        call.start(responseType: UIImage.self, onSuccess: onSuccess, onFailure: onFailure)
        
        return call
    }
}
