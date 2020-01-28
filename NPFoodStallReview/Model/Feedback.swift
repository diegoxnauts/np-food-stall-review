//
//  Feedback.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 21/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation

class Feedback {
    var stallId:String?
    var userId:String?
    var message:String?
    var name:String?
    var rating:Double?
    
    init(stallId:String, userId:String, message:String, name:String, rating:Double) {
        self.stallId = stallId
        self.userId = userId
        self.message = message
        self.name = name
        self.rating = rating
    }
}
