//
//  CanteenController.swift
//  NPFoodStallReview
//
//  Created by Zhi Xuan Lee on 22/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class CanteenController {

    
    func retrieveCanteens(completion: @escaping([Canteen]) -> ()) {
        var canteens:[Canteen?] = []
        
        let database = Database.database()
        let canteensRef = database.reference(withPath: "canteens")
        canteensRef.observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children.allObjects {
                let canteenSnapshot = child as! DataSnapshot
                if let canteenInfo = canteenSnapshot.value as? [String:AnyObject] {
                    let name = canteenInfo["name"] as! String
                    let longitude = canteenInfo["longitude"] as! Double
                    let latitude = canteenInfo["latitude"] as! Double
                    let canteen = Canteen(canteenId: canteenSnapshot.key, name: name, longitude: longitude, latitude: latitude, stalls: [])
                    canteens.append(canteen)
                }
            }
            if let canteensList = canteens as? [Canteen] {
                completion(canteensList)
            }
        })
    }
    
    //MARK: Retrieve Canteens using Semaphore method
    
    func retrieveCanteens() throws -> [Canteen] {
        var isError = false;
        var canteens:[Canteen] = []
        
        let semaphore = DispatchSemaphore(value: 0);
        
        let database = Database.database()
        let canteensRef = database.reference(withPath: "canteens")
        canteensRef.observeSingleEvent(of: .value , with: {snapshot in
            for child in snapshot.children.allObjects {
                let canteenSnapshot = child as! DataSnapshot
                if let canteenInfo = canteenSnapshot.value as? [String:AnyObject] {
                    let name = canteenInfo["name"] as! String
                    let longitude = canteenInfo["longitude"] as! Double
                    let latitude = canteenInfo["latitude"] as! Double
                    let canteen = Canteen(canteenId: canteenSnapshot.key, name: name, longitude: longitude, latitude: latitude, stalls: [])
                    canteens.append(canteen)
                }
            }
            semaphore.signal()
        }, withCancel: { (err) in
            print("Retrieve Error: \(err)");
            isError = true;
            semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        if (isError) {
            throw FireBaseError.server;
        }
        
        return canteens;
    }
    
    
}
