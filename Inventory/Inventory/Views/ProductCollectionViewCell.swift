//
//  ProductCollectionViewCell.swift
//  Inventory
//
//  Created by Vaibhav Singla on 03/07/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import UIKit
import SDWebImage

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var bgView: UIView!
    var cellProduct: Product?
    var cellIndexPath: IndexPath?
    
    class var cellNib: UINib{
        return UINib.init(nibName: String.init(describing: ProductCollectionViewCell.self), bundle: nil)
    }
    class var cellIdentifier: String{
        return String.init(describing: ProductCollectionViewCell.self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bgView.layer.cornerRadius = 10
        // Initialization code
        
    }

    func configCell(product: Product, indexPath: IndexPath){
        
        cellProduct = product
        cellIndexPath = indexPath
        productNameLabel.text = product.name
        if let url = URL(string: product.imageURL), !product.imageURL.isEmpty{
            productImageView.sd_setImage(with: url, completed: nil)
        }else{
            productImageView.image = #imageLiteral(resourceName: "placeholderImage")
        }
    }
}
