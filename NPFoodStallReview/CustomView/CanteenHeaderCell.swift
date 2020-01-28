//
//  CanteenHeaderCell.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 28/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit

class CanteenHeaderCell : UITableViewCell {
    @IBOutlet weak var canteenLbl: UILabel!
    @IBOutlet weak var toggleBtn: UIButton!
    
    func setup(expandableCanteen: ExpandableCanteen) {
        canteenLbl.text = expandableCanteen.canteen.name
    }
}
