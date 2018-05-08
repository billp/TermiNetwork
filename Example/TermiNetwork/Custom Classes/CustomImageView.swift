//
//  SNImageView.swift
//  SimpleNetworking_Example
//
//  Created by Vasilis Panagiotopoulos on 19/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import TermiNetwork

class CustomImageView: UIImageView {
    var call: TNCall?
    
    var url: String! {
        didSet {
            self.setRemoteImage(url: url)
        }
    }
}
