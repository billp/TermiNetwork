//
//  ViewController.swift
//  SimpleNetworking
//
//  Created by Bill Panagiotopouplos on 02/14/2018.
//  Copyright (c) 2018 Bill Panagiotopouplos. All rights reserved.
//

import UIKit
import TermiNetwork
import SwiftyJSON

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var categories = [FoodCategory]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.isHidden = true
        
        TNRequest(method: .get,
                  url: "https://jsonplaceholder.typicode.com/todos/1",
                  params: ["params": true]).start(responseType: JSON.self, onSuccess: { json in
            print(json)
        }) { (error, data) in
            print(error)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        APIFoodRouter.getCategories(onSuccess: { categories in
            self.categories = categories.categories
            self.tableView.reloadData()
            self.tableView.isHidden = false
        }, onFailure: { error, data in
            debugPrint(error.localizedDescription)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodCategoryCell") as! FoodCategoryCell
        let category = categories[indexPath.row]
        
        cell.titleLabel.text = category.strCategory
        cell.descriptionLabel.text = category.strCategoryDescription
        cell.thumbImageView.url = category.strCategoryThumb
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
