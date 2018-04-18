//
//  TNLog.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 22/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

internal class TNLog {
    init(call: TNCall, message: String, responseData: Data? = nil) {
        guard TNEnvironment.verbose else { return }
        
        let url = call.cachedRequest?.url?.absoluteString ?? "n/a"
        let headers = call.cachedRequest?.allHTTPHeaderFields?.description ?? "n/a"
        
        print("|=== TermiNetwork verbose BEGIN ===|")
        print("|> URL: " + url)
        print("|> Request Headers: " + headers)
        print("|> Message: " + message)
        if let data = responseData {
            print("|> Data: " + (data.toString() ?? "[non-printable]")!)
        }
        print("|=== TermiNetwork verbose   END ===|")
        print()
    }
}
