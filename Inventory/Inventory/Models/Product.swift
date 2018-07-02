//
//  Product.swift
//  Inventory
//
//  Created by Vaibhav Singla on 01/07/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import Foundation
import UIKit

class Product{
    var name: String
    var unitsInStock: Int
    var image: UIImage
    var imageURL: String
    
    
    init(){
        name = ""
        unitsInStock = 0
        image = #imageLiteral(resourceName: "placeholderImage")
        imageURL = ""
        
    }
    static func initWithValues(name: String = "", unitsInStock: Int = 0, image: UIImage = #imageLiteral(resourceName: "placeholderImage"), imageURL: String = "" )-> Product {
        let product = Product()
        product.name = name
        product.unitsInStock = unitsInStock
        product.image = image
        product.imageURL = imageURL
        return product
    }
    func getProductDictionary()-> [String:Any]{
        var dict = Dictionary<String,Any>()
        dict[APIKey_ProductName] = self.name
        dict[APIKey_ProductImageUrl] = self.imageURL
        dict[APIKey_ProductStock] = self.unitsInStock
        return dict
    }
    func getAllProducts(){
        
    }
    static func getProductDictionary(product: Product){
        
    }
    
    
}
