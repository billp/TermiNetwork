//
//  ViewController.swift
//  SimpleNetworking
//
//  Created by Bill Panagiotopouplos on 02/14/2018.
//  Copyright (c) 2018 Bill Panagiotopouplos. All rights reserved.
//

import UIKit
import SimpleNetworking

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Test call
        let params = [
            "sort_by": "first_name",
            "mode": "ascending"
        ]
        
        let headers = [
            "Content-type": "application/json"
        ]
        
        try? SNCall(method: .get, headers: headers, path: path("users", "list"), params: params).start(onSuccess: { data in
            //Do something with data
        }, onFailure: { error in
            //Do something with error
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
