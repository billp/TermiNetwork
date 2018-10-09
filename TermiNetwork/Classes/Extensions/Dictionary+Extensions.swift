//
//  Dictionary+Extensions.swift
//  Pods-TermiNetwork_Example
//
//  Created by Vasilis Panagiotopoulos on 09/10/2018.
//

import UIKit

extension Dictionary {
    internal func toJSONString() -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted) {
            return data.toJSONString()
        }
        return nil
    }
}
