//
//  ManageProductCollectionViewController.swift
//  whale_market
//
//  Created by Jingyu on 21/5/20.
//  Copyright © 2020 xiongjingyu. All rights reserved.
//

import UIKit
import FirebaseAuth

private let reuseIdentifier = "Cell"

class ManageProductCollectionViewController: UICollectionViewController, DatabaseListener, UISearchResultsUpdating {
    func onArticleListChange(change: DatabaseChange, articles: [Article]) {
        
    }
    
    
    
    var allProducts: [Product] = []
    var filteredProducts: [Product] = []
    var productInfo : Product?
    
    
    
    
    let locationImages = [UIImage(named: "hawaiiResort"), UIImage(named: "mountainExpedition"), UIImage(named: "scubaDiving"),UIImage(named: "scubaDiving"),UIImage(named: "scubaDiving"),UIImage(named: "scubaDiving"),UIImage(named: "scubaDiving"),UIImage(named: "hawaiiResort"),UIImage(named: "hawaiiResort"),UIImage(named: "hawaiiResort"),UIImage(named: "hawaiiResort"),UIImage(named: "hawaiiResort"),UIImage(named: "hawaiiResort"),UIImage(named: "hawaiiResort"),UIImage(named: "mountainExpedition"),UIImage(named: "mountainExpedition"),UIImage(named: "mountainExpedition"),UIImage(named: "mountainExpedition")]
    
    
    weak var databaseController: DatabaseProtocol?
    var listenerType: ListenerType = .all
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //print(Auth.auth().currentUser)
        authCheck()
        
        
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        filteredProducts = allProducts
       
               
               
       
        
        
        
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Products"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        
        // This view controller decides how the search controller is presented
        definesPresentationContext = true
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // Do any additional setup after loading the view.
    }
    func authCheck() {
        
        if Auth.auth().currentUser?.uid == nil{
            print("test")
            let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.loginViewController) as? LoginViewController
            
            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
        }
        print("double check")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    func setImage(from url: String) {
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }
        if searchText.count > 0 {
            filteredProducts = allProducts.filter({ (product: Product) -> Bool in
                return product.name.lowercased().contains(searchText)
            })
        } else {
            filteredProducts = allProducts
        }
        collectionView.reloadData()
        
        
        
        
    }
    func onProductListChange(change: DatabaseChange, products: [Product]) {
        allProducts = products
//        for x in 0...allProducts.count-1{
//            if products[x].uid != Auth.auth().currentUser?.uid{
//                filteredProducts.remove(at: x)
//
//            }
//        }
        allProducts = products.filter({ (product: Product) -> Bool in
                       return product.uid ==  Auth.auth().currentUser?.uid
        })
       
        //print(allProducts.count)
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return self.locationNames.count
        print(self.filteredProducts.count)
        return self.filteredProducts.count
        
    }
   
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.productInfo = allProducts[indexPath.row]
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        if filteredProducts[indexPath.row].imageUrl != ""{
            let imageURL = URL(string: filteredProducts[indexPath.row].imageUrl)

                // just not to cause a deadlock in UI!
            DispatchQueue.global().async {
                let imageData = try? Data(contentsOf: imageURL!)

                let image = UIImage(data: imageData!)
                DispatchQueue.main.async {
                cell.ProductImage.image = image
                 }
             }
            
        }
        cell.ProductImage.image=UIImage(named: "loading")
        
        //cell.ProductImage.image = locationImages[indexPath.row]
        cell.ProductName.text = filteredProducts[indexPath.row].name
        cell.ProductDescription.text = "$" + String(filteredProducts[indexPath.row].price)
        
        
        //This creates the shadows and modifies the cards a little bit
        cell.contentView.layer.cornerRadius = 4.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
        
        
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("world")
        if segue.identifier == "productDetailSegue", let cell = sender as?
        UICollectionViewCell {
            if let indexPath = collectionView.indexPath(for: cell){
                let destination = segue.destination as! DisplayProductDetailViewController
                destination.productDetail = allProducts[indexPath.row]
                
 
            }
            
        }
    }

    
    
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    
}
