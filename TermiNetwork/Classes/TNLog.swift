//
//  TNLog.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 22/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

internal class TNLog {
    init(call: TNRequest, message: String, responseData: Data? = nil) {
        guard TNEnvironment.verbose else { return }
        
        let url = call.cachedRequest?.url?.absoluteString ?? "n/a"
        let headers = call.cachedRequest?.allHTTPHeaderFields
        
        print("----------------------------------")
        print(">>> TermiNetwork request BEGIN <<<")
        print("----------------------------------")
        print("URL             : " + url)
        print("Method          : " + call.method.rawValue)
        if let headers = headers, headers.keys.count > 0 {
            print("Request Headers : " + headers.description)
        }
        print("Message         : " + message)
        if let data = responseData {
            print("Response        : \n" + (data.toJSONString() ?? "[non-printable]")!)
        }
        print("--------------------------------")
        print(">>> TermiNetwork request END <<<")
        print("--------------------------------")
        print()
    }
}
