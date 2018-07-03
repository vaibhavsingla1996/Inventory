//
//  ViewController.swift
//  Inventory
//
//  Created by Vaibhav Singla on 02/07/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
class ViewController: UIViewController {
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addNewProduct(_ sender: UIButton) {
        print("product added")
        let product = Product.initWithValues(name: "asian paint", unitsInStock: 10)
        ref.child(APIKey_Products).childByAutoId().setValue(product.getProductDictionary())
        
    }
    
    
    
}

