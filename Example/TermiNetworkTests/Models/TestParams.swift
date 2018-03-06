//
//  TestParams.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 06/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct TestParam: Codable {
    
    let param1 : String?
    let param2 : String?
    
    enum CodingKeys: String, CodingKey {
        case param1 = "key1"
        case param2 = "key2"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        param1 = try values.decodeIfPresent(String.self, forKey: .param1)
        param2 = try values.decodeIfPresent(String.self, forKey: .param2)
    }
}
