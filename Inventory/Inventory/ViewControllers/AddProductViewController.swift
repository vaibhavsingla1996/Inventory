//
//  AddProductViewController.swift
//  Inventory
//
//  Created by Vaibhav Singla on 02/07/18.
//  Copyright © 2018 Vaibhav Singla. All rights reserved.
//

import UIKit
import Gallery
import FirebaseDatabase
import FirebaseStorage
import SVProgressHUD

class AddProductViewController: UIViewController {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var detailsTableView: UITableView!
    var product = Product()
    var tapGesture: UITapGestureRecognizer?
    let productTableCellType: [AddNewProductEnum] = [.name, .stock]
    var isEditingMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
        
    }

    func configView(){

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        // ImageView Configuration
        productImageView.layer.cornerRadius = 100
        productImageView.image = #imageLiteral(resourceName: "placeholderImage")
        if isEditingMode{
            if !product.imageURL.isEmpty, let url = URL(string: product.imageURL){
                productImageView.sd_setImage(with: url, completed: nil)
            }
        }
        if let imageTapGesture = tapGesture{
            productImageView.addGestureRecognizer(imageTapGesture)
        }
        
        // table view configuration
        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        detailsTableView.register(ProductDetailTableViewCell.cellNib, forCellReuseIdentifier: ProductDetailTableViewCell.cellIdentifier)
        detailsTableView.estimatedRowHeight = UITableViewAutomaticDimension
        detailsTableView.rowHeight = UITableViewAutomaticDimension
        detailsTableView.tableFooterView = UIView()
        
        // add bar button
        let saveButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        if isEditingMode{
            let deleteButton = UIBarButtonItem(image: #imageLiteral(resourceName: "garbage"), style: .done, target: self, action: #selector(deleteButtonTapped))
            self.navigationItem.rightBarButtonItems = [saveButton,deleteButton]
        }else {
            self.navigationItem.rightBarButtonItem = saveButton
        }
    }
    @objc func saveButtonTapped(){
        isEditingMode ?  updatingOldProduct() : savingNewProduct()
    }
    @objc func deleteButtonTapped(){
        
        let alertController = UIAlertController(title: "Delete \(self.product.name)", message: "Are you sure you want to delete this product", preferredStyle: .alert)
        alertController.addAction(.init(title: "Delete", style: .destructive, handler: { (action) in
            // deleted code
            self.deleteProduct()
        }))
        alertController.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func imageTapped(){
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.initialTab = .imageTab
        Config.Camera.imageLimit = 1
        
        let gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
        
    }
    
    func deleteProduct(){
        
        SVProgressHUD.show(withStatus: "Deleting Product")
        SVProgressHUD.setDefaultMaskType(.clear)
        guard let key = self.product.productAutoId else{
            CommonUtils.alertWithOkButton(title: "Sorry", message: "Cannot delete this product", viewController: self) { (bool) in
                // code if success
                SVProgressHUD.dismiss()
            }
            return
        }
        let ref = Database.database().reference().child(APIKey_Products).child(key)
        ref.removeValue { (error, ref) in
            if error != nil{
                CommonUtils.alertWithOkButton(title: "Sorry", message: "Cannot delete this product", viewController: self) { (bool) in
                    // code if success
                    SVProgressHUD.dismiss()
                }
                return
            }
            CommonUtils.alertWithOkButton(title: "Congrats", message: "Product has been Successfully deleted", viewController: self) { (bool) in
                // code if success
                SVProgressHUD.dismiss()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    func savingNewProduct(){
        if product.name.isEmpty{
            CommonUtils.alertWithOkButton(title: "", message: "Name "+kError_FieldEmpty, viewController: self) { (bool) in
                // if ok pressed worl here
            }
        }else{
            SVProgressHUD.show(withStatus: "Saving Product")
            SVProgressHUD.setDefaultMaskType(.clear)
            if let productImage = productImageView.image{
                product.image = productImage
            }
            // sendImage and Get URL
            let timeStamp = NSDate().timeIntervalSince1970
            let imageName: String = "\(Int(timeStamp)).png"
            let storageRef = Storage.storage().reference().child(imageName)
            if let uploadData = UIImagePNGRepresentation(product.image){
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if error != nil{
                        print("error \(error!)")
                        SVProgressHUD.dismiss()
                        CommonUtils.alertWithOkButton(title: kError_SavingProduct, message: error?.localizedDescription, viewController: self, sucessAction: { (bool) in
                            self.navigationController?.popViewController(animated: true)
                            
                        })
                        return
                    }else{
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil{
                                SVProgressHUD.dismiss()
                                CommonUtils.alertWithOkButton(title: kError_SavingImage, message: error?.localizedDescription, viewController: self, sucessAction: { (bool) in
                                    self.navigationController?.popViewController(animated: true)
                                    
                                })
                            }
                            self.product.imageURL = url?.absoluteString ?? ""
                            let ref = Database.database().reference()
                            ref.child(APIKey_Products ).childByAutoId().setValue(self.product.getProductDictionary())
                            SVProgressHUD.dismiss()
                            CommonUtils.alertWithOkButton(title: "Congrats", message: "Your item is saved successfully.", viewController: self, sucessAction: { (bool) in
                                self.navigationController?.popViewController(animated: true)
                            })
                        })
                    }
                }
                if !CommonUtils.isInternetAvailable(){
                    SVProgressHUD.dismiss()
                    CommonUtils.alertWithOkButton(title: kError_Network, message: kError_Internet + "\n" + kDataIsSavedLocally, viewController: self) { (bool) in
                        if bool{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else{
                SVProgressHUD.dismiss()
                print("cannot convert it to data")
            }
        }
    }
    func updatingOldProduct(){
        if product.name.isEmpty{
            CommonUtils.alertWithOkButton(title: "", message: "Name "+kError_FieldEmpty, viewController: self) { (bool) in
                // if ok pressed worl here
            }
        }else{
            SVProgressHUD.show(withStatus: "Updating Product")
            SVProgressHUD.setDefaultMaskType(.clear)
            if let productImage = productImageView.image{
                product.image = productImage
            }
            // sendImage and Get URL
            let timeStamp = NSDate().timeIntervalSince1970
            let imageName: String = "\(Int(timeStamp)).png"
            let storageRef = Storage.storage().reference().child(imageName)
            if let uploadData = UIImagePNGRepresentation(product.image){
                storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if error != nil{
                        print("error \(error!)")
                        SVProgressHUD.dismiss()
                        CommonUtils.alertWithOkButton(title: kError_SavingProduct, message: error?.localizedDescription, viewController: self, sucessAction: { (bool) in
                            self.navigationController?.popViewController(animated: true)
                            
                        })
                        return
                    }else{
                        storageRef.downloadURL(completion: { (url, error) in
                            if error != nil{
                                SVProgressHUD.dismiss()
                                CommonUtils.alertWithOkButton(title: kError_SavingImage, message: error?.localizedDescription, viewController: self, sucessAction: { (bool) in
                                    self.navigationController?.popViewController(animated: true)
                                    
                                })
                            }
                            self.product.imageURL = url?.absoluteString ?? ""
                            let ref = Database.database().reference()
                            var textMessageForAlert = ""
                            var title = "Congrats"
                            if let key = self.product.productAutoId{
                                ref.updateChildValues(["\(APIKey_Products)/\(key)":self.product.getProductDictionary()])
                                textMessageForAlert = "Your item is updated successfully."
                            }else{
                                ref.child(APIKey_Products ).childByAutoId().setValue(self.product.getProductDictionary())
                                textMessageForAlert = "Sorry we were not able to update your Product. We have created new Product with the values you provided."
                                title = "Sorry"
                            }
                            SVProgressHUD.dismiss()
                            CommonUtils.alertWithOkButton(title: title, message: textMessageForAlert, viewController: self, sucessAction: { (bool) in
                                self.navigationController?.popViewController(animated: true)
                                
                            })
                        })
                    }
                }
                if !CommonUtils.isInternetAvailable(){
                    SVProgressHUD.dismiss()
                    CommonUtils.alertWithOkButton(title: kError_Network, message: kError_Internet + "\n" + kDataIsSavedLocally, viewController: self) { (bool) in
                        if bool{
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }else{
                SVProgressHUD.dismiss()
                print("cannot convert it to data")
            }
            
            
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
// MARK: - TableViewDataSource
extension AddProductViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productTableCellType.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductDetailTableViewCell.cellIdentifier, for: indexPath) as! ProductDetailTableViewCell
        cell.delegate = self
        switch productTableCellType[indexPath.row] {
        case .name:
            cell.cellConfig(name: "Name", indexPath: indexPath, textFieldData: self.product.name)
        case .stock:
            cell.cellConfig(name: "Quantity", indexPath: indexPath, textFieldData: String(self.product.unitsInStock))
            cell.dataTextField.keyboardType = .numberPad
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - TableViewDelegate

extension AddProductViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
extension AddProductViewController: GalleryControllerDelegate{
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        print("Selected images")
        Image.resolve(images: images) { (imagesArray) in
            if !imagesArray.isEmpty && imagesArray.first != nil{
                self.productImageView.image = imagesArray.first!
            }
        }
        dismiss(animated: true) {
            // completion Block
        }
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        print("Selected video")

    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        print("Selected lightBox")

    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        dismiss(animated: true) {
            // completion Block
        }
    }
    
}

// MARK: - ProductDetailCellDelegate
extension AddProductViewController: ProductdetailDelegate{
    func textFieldTextChanged(updatedText: String, cellIndexPath: IndexPath) {
        switch productTableCellType[cellIndexPath.row] {
        case .name:
            product.name = updatedText
        case .stock:
            product.unitsInStock = Int(updatedText) ?? 0
            
        }
    }
}
