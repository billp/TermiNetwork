//
//  SNImageView.swift
//  SimpleNetworking_Example
//
//  Created by Vasilis Panagiotopoulos on 19/02/2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import SimpleNetworking

class CustomImageView: UIImageView {
    var call: SNCall?
    
    var url: String! {
        didSet {
            call?.cancel()
            image = nil
            
            call = try? APICustomHelpers.getImage(url: url, onSuccess: { image in
                self.image = image
            }, onFailure: { error in
                self.image = nil
            })
        }
    }

}
