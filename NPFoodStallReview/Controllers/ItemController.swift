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
    
    //MARK: Retrieve items by stallId using Semaphore method
    
    func retrieveItemsByStallId(stallId:String) throws -> [Item] {
        var isError = false;
        var items:[Item] = []
        
        let semaphore = DispatchSemaphore(value: 0);
        
        let database = Database.database()
        let itemsRef = database.reference(withPath: "items")
        itemsRef.observeSingleEvent(of: .value, with: {snapshot in
            if (snapshot.exists()) {
                for child in snapshot.children.allObjects {
                    let itemSnapshot = child as! DataSnapshot
                    if let itemInfo = itemSnapshot.value as? [String:AnyObject] {
                        let stallID = itemInfo["stallId"] as! String
                        if (stallId == stallID) {
                            let name = itemInfo["name"] as! String
                            let price = itemInfo["price"] as! Double
                            // define empty dictionary
                            var userWhoLikeDict = [String: Bool]();
                            if let userWhoLike = itemInfo["userWhoLike"] {
                                userWhoLikeDict = userWhoLike as! [String:Bool];
                            }
                            let item = Item(itemId: itemSnapshot.key, name: name, price: price, stallId: stallID, userWhoLike: userWhoLikeDict)
                            items.append(item)
                        }
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
    
    
    // MARK: Add or Update Item Likes
    func addOrUpdateLikes(itemId: String, userId: String, value: Bool) -> Bool {
        // TODO: logic
        let semaphore = DispatchSemaphore(value: 0);
        var success:Bool = true;
        let database = Database.database();
        let userWhoLikeRef = database.reference(withPath: "items/\(itemId)/userWhoLike/\(userId)");
        
        userWhoLikeRef.setValue(value, withCompletionBlock: { err, ref in
            if let error = err {
                print("Item Like was not successful: \(error.localizedDescription)")
                success = false
                semaphore.signal()
            } else {
                print("Item Liked successfully!")
                semaphore.signal()
            }
        });
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return success;
        
    }
}
