//
//  DatabaseProtocol.swift
//  W03 - Lab
//
//  Created by Michael Wybrow on 4/4/20.
//  Copyright © 2020 Monash University. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    
    case products
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    
    func onProductListChange(change: DatabaseChange, products: [Product])
}

protocol DatabaseProtocol: AnyObject {
    
    
    func cleanup()
    func addProduct(name: String, price: Int) -> Product
    
    func deleteProduct(product: Product)
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
