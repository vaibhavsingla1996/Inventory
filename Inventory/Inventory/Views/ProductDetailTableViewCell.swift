//
//  ProductDetailTableViewCell.swift
//  Inventory
//
//  Created by Vaibhav Singla on 02/07/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import UIKit

@objc  protocol ProductdetailDelegate {
    @objc optional func textFieldTextChanged(updatedText: String, cellIndexPath: IndexPath)
}
class ProductDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dataTextField: UITextField!
    weak var delegate: ProductdetailDelegate?
    var cellIndexPath: IndexPath?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dataTextField.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func cellConfig(name: String, indexPath: IndexPath) {
        nameLabel.text = name
        cellIndexPath = indexPath
        
    }
}
extension ProductDetailTableViewCell: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        if let updatedString = newString, let indexPath = cellIndexPath{
            delegate?.textFieldTextChanged!(updatedText: updatedString, cellIndexPath: indexPath)
        }
        return true
    }
}
