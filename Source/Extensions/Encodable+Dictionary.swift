//
//  Encodable+Dictionary.swift
//  TermiNetwork
//
//  Created by Vassilis Panagiotopoulos on 29/8/23.
//  Copyright © 2023 Bill Panagiotopoulos. All rights reserved.
//

import Foundation

extension Encodable {
    func asDictionary() throws -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard let jsonDictionary = jsonObject as? [String: Any] else {
                return nil
            }
            return jsonDictionary
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
