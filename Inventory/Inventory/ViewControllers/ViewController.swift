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
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    var ref: DatabaseReference!
    var productsArray = [Product]()
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
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
    
}

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

extension ViewController: UICollectionViewDelegate{
    
}

