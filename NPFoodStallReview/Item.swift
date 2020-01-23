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
    var likes:Int
    var name:String
    var price:Double
    var stallId:String
    
    init(itemId:String, likes:Int, name:String, price:Double, stallId:String) {
        self.itemId = itemId
        self.likes = likes
        self.name = name
        self.price = price
        self.stallId = stallId
    }
}
