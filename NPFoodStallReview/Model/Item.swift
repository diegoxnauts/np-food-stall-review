//
//  Item.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 21/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation

class Item {
    var itemId:String
    var name:String
    var price:Double
    var stallId:String
    var userWhoLike:[String:Bool]
    
    init(itemId:String, name:String, price:Double, stallId:String, userWhoLike:[String:Bool]) {
        self.itemId = itemId
        self.name = name
        self.price = price
        self.stallId = stallId
        self.userWhoLike = userWhoLike
    }
}
