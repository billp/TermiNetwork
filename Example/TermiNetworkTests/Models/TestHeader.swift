//
//  TestHeader.swift
//  TermiNetworkTests
//
//  Created by Vasilis Panagiotopoulos on 05/03/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

struct HeaderRootClass : Codable {
    
    let authorization : String?
    let customHeader : String?
    
    
    enum CodingKeys: String, CodingKey {
        case authorization = "HTTP_AUTHORIZATION"
        case customHeader = "HTTP_CUSTOM_HEADER"
    }
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        authorization = try values.decodeIfPresent(String.self, forKey: .authorization)
        customHeader = try values.decodeIfPresent(String.self, forKey: .customHeader)
    }
}
