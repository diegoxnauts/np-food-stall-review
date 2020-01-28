//
//  ItemController.swift
//  NPFoodStallReview
//
//  Created by Zhi Xuan Lee on 23/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class ItemController {
    func retrieveItemsByStallId(stallId:String, completion: @escaping([Item]) -> ()) {
        var items:[Item?] = []
        
        let database = Database.database()
        let itemsRef = database.reference(withPath: "items")
        itemsRef.observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children.allObjects {
                let itemSnapshot = child as! DataSnapshot
                if let itemInfo = itemSnapshot.value as? [String:AnyObject] {
                    let stallID = itemInfo["stallId"] as! String
                    if (stallId == stallID) {
                        let likes = itemInfo["likes"] as! Int
                        let name = itemInfo["name"] as! String
                        let price = itemInfo["price"] as! Double
                        let item = Item(itemId: itemSnapshot.key, likes: likes, name: name, price: price, stallId: stallID)
                        items.append(item)
                    }
                }
            }
            if let itemsList = items as? [Item] {
                completion(itemsList)
            }
        })
    }
    
    //MARK: Retrieve items by stallId using Semaphore method
    
    func retrieveItemsByStallId(stallId:String) throws -> [Item] {
        var isError = false;
        var items:[Item] = []
        
        let semaphore = DispatchSemaphore(value: 0);
        
        let database = Database.database()
        let itemsRef = database.reference(withPath: "items")
        itemsRef.observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children.allObjects {
                let itemSnapshot = child as! DataSnapshot
                if let itemInfo = itemSnapshot.value as? [String:AnyObject] {
                    let stallID = itemInfo["stallId"] as! String
                    if (stallId == stallID) {
                        let likes = itemInfo["likes"] as! Int
                        let name = itemInfo["name"] as! String
                        let price = itemInfo["price"] as! Double
                        let item = Item(itemId: itemSnapshot.key, likes: likes, name: name, price: price, stallId: stallID)
                        items.append(item)
                    }
                }
            }
            semaphore.signal()
        }, withCancel: {(err) in
            print("Retrieve Error: \(err)");
            isError = true;
            semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        if (isError) {
            throw FireBaseError.server;
        }
        
        return items;
    }
    
}
