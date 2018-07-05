//
//  ShowProductDetailsTableViewCell.swift
//  Inventory
//
//  Created by Vaibhav Singla on 7/5/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import UIKit

class ShowProductDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    class var cellNib: UINib{
        return UINib.init(nibName: String.init(describing: ShowProductDetailsTableViewCell.self), bundle: nil)
    }
    class var cellIdentifier: String{
        return String.init(describing: ShowProductDetailsTableViewCell.self)
    }
    
    
    var cellIndexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configCell(titleLabelText: String,detailLabelText: String = "" , indexPath: IndexPath){
        self.cellIndexPath = indexPath
        titleLabel.text = titleLabelText
        detailLabel.text = detailLabelText
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
