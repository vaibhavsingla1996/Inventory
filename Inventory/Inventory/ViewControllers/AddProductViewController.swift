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

class AddProductViewController: UIViewController {

    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var detailsTableView: UITableView!
    let product = Product()
    var tapGesture: UITapGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    func configView(){

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        // ImageView Configuration
        productImageView.layer.cornerRadius = 100
        productImageView.image = #imageLiteral(resourceName: "placeholderImage")
        if let imageTapGesture = tapGesture{
            productImageView.addGestureRecognizer(imageTapGesture)
        }
        
        // table view configuration
        detailsTableView.dataSource = self
        detailsTableView.delegate = self
        detailsTableView.register(UINib.init(nibName: String(describing: ProductDetailTableViewCell.self), bundle: nil), forCellReuseIdentifier: kReuseIdentifer_ProductDetailTableCell)
        detailsTableView.estimatedRowHeight = UITableViewAutomaticDimension
        detailsTableView.rowHeight = UITableViewAutomaticDimension
        detailsTableView.tableFooterView = UIView()
        
        // add bar button
        let saveButton = UIBarButtonItem.init(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        self.navigationItem.rightBarButtonItem = saveButton
    }
    @objc func saveButtonTapped(){
        //
        print("saved")
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
                    
                }
                storageRef.downloadURL(completion: { (url, error) in
                    self.product.imageURL = url?.absoluteString ?? ""
                    let ref = Database.database().reference()
                    ref.child(APIKey_Products ).childByAutoId().setValue(self.product.getProductDictionary())
                })
                
            }
        }else{
            print("cannot convert it to data")
        }
    }
    
    
    @objc func imageTapped(){
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.initialTab = .imageTab
        Config.Camera.imageLimit = 1
        
        let gallery = GalleryController()
        gallery.delegate = self
        present(gallery, animated: true, completion: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension AddProductViewController: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseIdentifer_ProductDetailTableCell, for: indexPath) as! ProductDetailTableViewCell
        cell.delegate = self
        switch indexPath.row {
        case 0:
            cell.cellConfig(name: "Name", indexPath: indexPath)
        case 1:
            cell.cellConfig(name: "Quantity", indexPath: indexPath)
            cell.dataTextField.keyboardType = .numberPad
        default:
            // default code
            cell.cellConfig(name: "units in stock", indexPath: indexPath)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

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
extension AddProductViewController: ProductdetailDelegate{
    func textFieldTextChanged(updatedText: String, cellIndexPath: IndexPath) {
        switch cellIndexPath.row {
        case 0:
            product.name = updatedText
        case 1:
            product.unitsInStock = Int(updatedText) ?? 0
        default:
            print("new section")
            // default code
            
        }
    }
}
