//
//  ItemCell.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 29/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit

class ItemCell : UITableViewCell {

    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var likesNo: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var unlikeBtn: UIButton!
    
    func setup(item: Item) {
        itemName.text = item.name
        itemPrice.text = convertDoubleToCurrency(amount: item.price)
        
        var count = 0;
        
        for (_, value) in item.userWhoLike {
            if (value) {
                count += 1;
            }
        }
        
        likesNo.text = "\(count) Likes";
    }
    
    func convertDoubleToCurrency(amount: Double) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        return numberFormatter.string(from: NSNumber(value: amount))!
    }
}
