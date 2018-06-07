//
//  Data+Extensions.swift
//  TermiNetwork
//
//  Created by Vasilis Panagiotopoulos on 22/02/2018.
//

import Foundation

extension Data {
    public func deserializeJSONData<T>() throws -> T where T:Decodable  {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(T.self, from: self)
    }
    
    internal func toJSONString() -> String? {
        if let dictionary = try? JSONSerialization.jsonObject(with: self, options: []) {
            if let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted), let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        }
        return nil
    }
    
    internal func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}
