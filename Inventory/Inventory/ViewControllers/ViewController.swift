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
import SVProgressHUD

class ViewController: UIViewController {
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    var ref: DatabaseReference!
    var productsArray = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        setUpCollectionView()
        if !CommonUtils.isInternetAvailable(){
            CommonUtils.alertWithOkButton(title: kError_Network, message: kError_Internet, viewController: self) { (bool) in
                // if wanna do anything when OK pressed
            }
        }
        getProductsFromFirebase()
    }
    
    func setUpCollectionView() {
        productsCollectionView.dataSource = self
        productsCollectionView.delegate = self
        
        productsCollectionView.register(ProductCollectionViewCell.cellNib, forCellWithReuseIdentifier: ProductCollectionViewCell.cellIdentifier)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getProductsFromFirebase(){
        SVProgressHUD.show(withStatus: "Fetching data")
        SVProgressHUD.setDefaultMaskType(.clear)
        ref.child(APIKey_Products).observe(.value) { (snapshot) in
            //print(snapshot.value)
            guard let productAutoIdDictionary = snapshot.value as? [String : Any] else{ return }
            var tempProductArray = [Product]()
            for product in productAutoIdDictionary.enumerated(){
                
                if let productDictionary = product.element.value as? [String : Any]{
                    tempProductArray.append(Product.initWithDictionary(dict: productDictionary))
                    
                }
            }
            self.productsArray = tempProductArray
            self.productsCollectionView.reloadData()
            SVProgressHUD.dismiss()
        }
        if !CommonUtils.isInternetAvailable(){
            SVProgressHUD.dismiss()
        }
    }
    // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProduct"{
            
            if let indexPath = sender as? IndexPath, let destinationController = segue.destination as? ProductDetailViewController{
                destinationController.selectedProduct = productsArray[indexPath.row]
            }
        }
     }
}

// MARK: - UICollectionViewDataSource
extension ViewController :UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.cellIdentifier, for: indexPath) as! ProductCollectionViewCell
        cell.configCell(product: productsArray[indexPath.row], indexPath: indexPath)
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let numberOfProductsInRow = 2
        let itemWidth = (CommonUtils.screenWidth() - 60) / CGFloat(numberOfProductsInRow)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showProduct", sender: indexPath)
    }
}

