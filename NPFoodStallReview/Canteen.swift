//
//  Canteen.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 21/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation

class Canteen {
    var canteenId:String
    var name:String
    var longitude:Double
    var latitude:Double
    
    init(canteenId:String, name:String, longitude:Double, latitude:Double) {
        self.canteenId = canteenId
        self.name = name
        self.longitude = longitude
        self.latitude = latitude
    }
}
