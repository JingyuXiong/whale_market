//
//  FirebaseController.swift
//  whale_market
//
//  Created by xiongjingyu on 16/5/20.
//  Copyright © 2020 xiongjingyu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
   
    
    
    let DEFAULT_TEAM_NAME = "Default Team"
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var productsRef: CollectionReference?
    var productList: [Product]
    override init() {
        // To use Firebase in our application we first must run the
        // FirebaseApp configure method
        FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        productList = [Product]()
        
        
        super.init()
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be // any time later
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else { fatalError("Firebase authentication failed")
            }
            // Once we have authenticated we can attach our listeners to // the firebase firestore
            self.setUpProductListener()
        } }
    // MARK:- Setup code for Firestore listeners
    func setUpProductListener() {
        productsRef = database.collection("products")
        productsRef?.addSnapshotListener { (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else { print("Error fetching documents: \(error!)")
                return
            }
            self.parseProductsSnapshot(snapshot: querySnapshot)
            // Team listener references heroes, so we need to
            //do it after we have parsed heroes.
            
            
        } }
    
    
    // MARK:- Parse Functions for Firebase Firestore responses
    func parseProductsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in let productID = change.document.documentID
            print(productID)
            var parsedProduct: Product?
            do {
                parsedProduct = try change.document.data(as:Product.self)
            } catch {
                print("Unable to decode product. Is the product malformed?")
                return
            }
            guard let product = parsedProduct else {
                print("Document doesn't exist")
                return;
            }
            product.id = productID
            if change.type == .added {
                productList.append(product) }
            else if change.type == .modified {
                let index = getProductIndexByID(productID)!
                productList[index] = product }
            else if change.type == .removed {
                if let index = getProductIndexByID(productID) {
                    productList.remove(at: index) }
            } }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.products ||
                listener.listenerType == ListenerType.all { listener.onProductListChange(change: .update, products: productList)
            } }
    }
    
    // MARK:- Utility Functions
    func getProductIndexByID(_ id: String) -> Int? {
        if let product = getProductByID(id) {
            return productList.firstIndex(of: product) }
        return nil
    }
    func getProductByID(_ id: String) -> Product? { for product in productList {
        if product.id == id { return product
        } }
        return nil
    }
    // MARK:- Required Database Functions
    func cleanup() {
    }
    func addProduct(name: String, price: Int) -> Product { let product = Product()
        product.name = name
        product.price = price
        do {
            if let productRef = try productsRef?.addDocument(from: product) {
                product.id = productRef.documentID }
        } catch {
            print("Failed to serialize product")
        }
        return product }
    
    func deleteProduct(product: Product) { if let productID = product.id {
        productsRef?.document(productID).delete() }
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
      
        if listener.listenerType == ListenerType.products ||
            listener.listenerType == ListenerType.all { listener.onProductListChange(change: .update, products: productList)
        } }
    func removeListener(listener: DatabaseListener) { listeners.removeDelegate(listener)
    }
}
