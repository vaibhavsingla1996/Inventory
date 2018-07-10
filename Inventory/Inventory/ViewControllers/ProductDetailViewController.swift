//
//  ProductDetailViewController.swift
//  Inventory
//
//  Created by Vaibhav Singla on 7/5/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import UIKit
import SDWebImage

class ProductDetailViewController: UIViewController {

    @IBOutlet weak var productDetailTableView: UITableView!
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var imageBgView: UIView!
    
    var selectedProduct: Product?
    let showProductTableDetailsArray: [ProductDetailEnum] = [.name, .stock]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpViews()
        self.setUpBarButtons()
    }

    override func viewWillAppear(_ animated: Bool) {
        if CommonUtils.isInternetAvailable(){
            productDetailTableView.reloadData()
            guard let product = selectedProduct else{ return }
            if !product.imageURL.isEmpty, let url = URL(string: product.imageURL){
                productImageView.sd_setImage(with: url, completed: nil)
            }
        }else{
            CommonUtils.alertWithOkButton(title: kError_Network, message: kError_Internet+"\n Cannot load Image", viewController: self) { (bool) in
                self.productImageView.image = #imageLiteral(resourceName: "placeholderImage")
            }
        }
        
        
    }
    func setUpBarButtons(){
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonTapped))
        self.navigationItem.rightBarButtonItem = editButton
    }
    
    @objc func editButtonTapped(){
        self.performSegue(withIdentifier: "editProduct", sender: nil)
    }
    func setUpViews(){
        
        productImageView.cornerRadius(productImageView.frame.size.width/2)
        productDetailTableView.dataSource = self
        productDetailTableView.delegate = self
        productDetailTableView.estimatedRowHeight = UITableViewAutomaticDimension
        productDetailTableView.rowHeight = UITableViewAutomaticDimension
        productDetailTableView.register(ShowProductDetailsTableViewCell.cellNib, forCellReuseIdentifier: ShowProductDetailsTableViewCell.cellIdentifier)
        productDetailTableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProduct"{
            let destinationController = segue.destination as! AddProductViewController
            destinationController.isEditingMode = true
            destinationController.product = self.selectedProduct ?? Product()
        }
    }

}

extension ProductDetailViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showProductTableDetailsArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ShowProductDetailsTableViewCell.cellIdentifier, for: indexPath) as! ShowProductDetailsTableViewCell
        guard  let product = selectedProduct else {
            return cell
        }
        switch(showProductTableDetailsArray[indexPath.row]){
        case .name:
            cell.configCell(titleLabelText: "Name", detailLabelText: product.name, indexPath: indexPath)
        case .stock:
            cell.configCell(titleLabelText: "Units", detailLabelText: String(product.unitsInStock), indexPath: indexPath)
        }
        return cell
    }
    
}
extension ProductDetailViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
