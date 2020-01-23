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
                    let stall = Stall(stallId: stallSnapshot.key, name: name, imageName: imageName, canteenId: canteenId, feedbacks: [])
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
                        let stall = Stall(stallId: stallSnapshot.key, name: name, imageName: imageName, canteenId: canteenId, feedbacks: [])
                        stalls.append(stall)
                    }
                }
            }
            if let stallsList = stalls as? [Stall] {
                completion(stallsList)
            }
        })
    }
}
