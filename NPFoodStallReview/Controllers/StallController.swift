//
//  StallController.swift
//  NPFoodStallReview
//
//  Created by Zhi Xuan Lee on 22/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class StallController {
    func retrieveStalls(completion: @escaping([Stall]) -> ()) {
        var stalls:[Stall?] = []
        
        let database = Database.database()
        let stallsRef = database.reference(withPath: "stalls")
        stallsRef.observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children.allObjects {
                let stallSnapshot = child as! DataSnapshot
                if let stallInfo = stallSnapshot.value as? [String:AnyObject] {
                    let canteenId = stallInfo["canteenId"] as! String
                    let imageName = stallInfo["imageName"] as! String
                    let name = stallInfo["name"] as! String
                    let stall = Stall(stallId: stallSnapshot.key, name: name, imageName: imageName, canteenId: canteenId, feedbacks: [], rating: nil)
                    stalls.append(stall)
                }
            }
            if let stallsList = stalls as? [Stall] {
                completion(stallsList)
            }
        })
    }
    
    func retrieveStallsByCanteenId(canteenID:String, completion: @escaping([Stall]) -> ()) {
        var stalls:[Stall?] = []
        
        let database = Database.database()
        let stallsRef = database.reference(withPath: "stalls")
        stallsRef.observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children.allObjects {
                let stallSnapshot = child as! DataSnapshot
                if let stallInfo = stallSnapshot.value as? [String:AnyObject] {
                    let canteenId = stallInfo["canteenId"] as! String
                    if (canteenID == canteenId) {
                        let imageName = stallInfo["imageName"] as! String
                        let name = stallInfo["name"] as! String
                        let stall = Stall(stallId: stallSnapshot.key, name: name, imageName: imageName, canteenId: canteenId, feedbacks: [], rating: nil)
                        stalls.append(stall)
                    }
                }
            }
            if let stallsList = stalls as? [Stall] {
                completion(stallsList)
            }
        })
    }
    
    // MARK: Retrieve Stalls Using Semaphore
    func retrieveStalls() throws -> [Stall] {
        var isError = false;
        var stalls:[Stall] = [];
        
        let semaphore = DispatchSemaphore(value: 0);
        
        let database = Database.database()
        let stallsRef = database.reference(withPath: "stalls")
        stallsRef.observeSingleEvent(of: .value, with: {snapshot in
            if (snapshot.exists()) {
                for child in snapshot.children.allObjects {
                    let stallSnapshot = child as! DataSnapshot
                    if let stallInfo = stallSnapshot.value as? [String:AnyObject] {
                        let canteenId = stallInfo["canteenId"] as! String
                        let imageName = stallInfo["imageName"] as! String
                        let name = stallInfo["name"] as! String
                        let stall = Stall(stallId: stallSnapshot.key, name: name, imageName: imageName, canteenId: canteenId, feedbacks: [], rating: nil)
                        stalls.append(stall)
                    }
                }
            }
            semaphore.signal();
        }, withCancel: {(err) in
            print (err)
            isError = true
            semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        if (isError) {
            throw FireBaseError.server;
        }
        
        return stalls
    }
    
    // MARK: Retrieve Stalls By CanteenID Using Semaphore method
    func retrieveStallsByCanteenId(canteenID:String) throws -> [Stall] {
        var isError = false;
        var stalls:[Stall] = [];
        
        let semaphore = DispatchSemaphore(value: 0);
        
        let database = Database.database()
        let stallsRef = database.reference(withPath: "stalls")
        stallsRef.observeSingleEvent(of: .value, with: {snapshot in
            if (snapshot.exists()) {
                for child in snapshot.children.allObjects {
                    let stallSnapshot = child as! DataSnapshot
                    if let stallInfo = stallSnapshot.value as? [String:AnyObject] {
                        let canteenId = stallInfo["canteenId"] as! String
                        if (canteenID == canteenId) {
                            let imageName = stallInfo["imageName"] as! String
                            let name = stallInfo["name"] as! String
                            let stall = Stall(stallId: stallSnapshot.key, name: name, imageName: imageName, canteenId: canteenId, feedbacks: [], rating: nil)
                            stalls.append(stall)
                        }
                    }
                }
            }
            semaphore.signal()
        }, withCancel: { (err) in
            print(err)
            isError = true
            semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        if (isError) {
            throw FireBaseError.server;
        }
        
        return stalls
    }
}
