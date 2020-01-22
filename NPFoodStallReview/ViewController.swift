//
//  ViewController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 19/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var canteenController = CanteenController()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        displayCanteens()
    }
    
    func displayCanteens() {
        var canteensString = ""
        canteenController.retrieveCanteens() {(canteens) -> () in
            if canteens.count > 0 {
                for canteen in canteens {
                    canteensString += "Canteen ID: \(canteen.canteenId), Name: \(canteen.name), Longitude: \(canteen.longitude), Latitude: \(canteen.latitude)\n"
                }
                print(canteensString)
            }
        }
    }
}

