//
//  APICustomHelpers.swift
//  SimpleNetworking_Example
//
//  Created by Vasilis Panagiotopoulos on 16/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import SimpleNetworking

struct APICustomHelpers {
    static func getImage(url: String, onSuccess: @escaping SNSuccessCallback<UIImage>, onFailure: @escaping SNFailureCallback) throws -> SNCall {
        let call = SNCall(method: .get, url: url, params: nil)
        try call.start(onSuccess: onSuccess, onFailure: onFailure)
        
        return call
    }
}
