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
    func cellDisplay(stall: Stall) {
        stallLabel.text = stall.name
        
    }
}
