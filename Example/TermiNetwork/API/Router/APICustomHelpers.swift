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
    static func getImage(url: String, onSuccess: @escaping TNSuccessCallback<UIImage>, onFailure: @escaping TNFailureCallback) throws -> TNCall {
        let call = TNCall(method: .get, url: url, params: nil)
        call.skipBeforeAfterAllRequestsHooks = true
        try call.start(onSuccess: onSuccess, onFailure: onFailure)
        
        return call
    }
}
