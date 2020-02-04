//
//  TopStallCell.swift
//  NPFoodStallReview
//
//  Created by Yeow Keng Chiu on 30/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class TopStallCell : UITableViewCell{
    
    @IBOutlet weak var stallLabel: UILabel!
    @IBOutlet weak var canteenLabel: UILabel!
    @IBOutlet weak var ratings: CosmosView!
    @IBOutlet weak var noOfRatings: UILabel!
    func cellDisplay(stall: Stall) {
        stallLabel.text = stall.name
        if (stall.rating != nil) {
            ratings.rating = stall.rating!
            noOfRatings.text = "(\(String(stall.feedbacks.count)))"
        }
        
    }
}
