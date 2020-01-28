//
//  Stall.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 21/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation

class Stall {
    var stallId: String
    var name: String
    var imageName: String
    var canteenId: String
    var feedbacks: [Feedback] = []
    var rating: Double?
    
    init(stallId: String, name : String, imageName : String, canteenId: String, feedbacks: [Feedback], rating: Double?) {
        self.stallId = stallId
        self.name = name
        self.imageName = imageName
        self.canteenId = canteenId
        self.feedbacks = feedbacks
    }
}
