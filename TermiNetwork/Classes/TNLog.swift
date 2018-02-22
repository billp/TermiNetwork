//
//  Environment.swift
//  ServiceRouter
//
//  Created by Vasilis Panagiotopoulos on 22/02/2018.
//  Copyright © 2018 Vasilis Panagiotopoulos. All rights reserved.
//

import Foundation

internal class TNLog {
    init(call: TNCall, message: String, responseData: Data? = nil) {
        guard TNEnvironment.verbose else { return }
        
        let url: String! = (try? call.asRequest().url?.absoluteString) ?? ""
        
        debugPrint("|=== TermiNetwork verbose BEGIN ===|")
        debugPrint("|> URL: " + url)
        debugPrint("|> Message: " + message)
        if let data = responseData {
            debugPrint("|> Data: " + (data.toString() ?? "[non-printable]")!)
        }
        debugPrint("|=== TermiNetwork verbose   END ===|")
        debugPrint()
    }
}
