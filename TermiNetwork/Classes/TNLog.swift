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
        
        let url: String! = (try? call.asRequest().url?.absoluteString) ?? ""
        
        print("|=== TermiNetwork verbose BEGIN ===|")
        print("|> URL: " + url)
        print("|> Message: " + message)
        if let data = responseData {
            print("|> Data: " + (data.toString() ?? "[non-printable]")!)
        }
        print("|=== TermiNetwork verbose   END ===|")
        print()
    }
}
