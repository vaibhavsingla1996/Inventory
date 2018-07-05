//
//  Extensions.swift
//  Inventory
//
//  Created by Vaibhav Singla on 7/5/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func cornerRadius(_ value: CGFloat = 10){
        self.clipsToBounds = true
        self.layer.cornerRadius = value
    }
}
