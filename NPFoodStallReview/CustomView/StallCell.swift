//
//  StallCell.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 28/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class StallCell : UITableViewCell {
    
    @IBOutlet weak var stallIcon: UIImageView!
    @IBOutlet weak var stallLbl: UILabel!
    @IBOutlet weak var feedbackBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingNo: UILabel!
    
    func setup(stall: Stall) {
        stallLbl.text = stall.name;
        if (stall.rating != nil) {
            ratingView.rating = stall.rating!
            ratingNo.text = "(\(stall.feedbacks.count))";
        } else {
            ratingView.rating = 0;
            ratingNo.text = "(0)";
        }
    }
    
}
