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
                    let canteen = Canteen(canteenId: canteenSnapshot.key, name: name, longitude: longitude, latitude: latitude)
                    canteens.append(canteen)
                }
            }
            if let canteensList = canteens as? [Canteen] {
                completion(canteensList)
            }
        })
    }
}
