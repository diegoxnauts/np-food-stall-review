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
    var stallController = StallController()
    var feedbackController = FeedbackController()
    var itemController = ItemController()
    
    var canteensList:[Canteen] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //displayCanteens()
        //retrieveAllStalls()
        //retrieveStallsByCanteenId(canteenId: "canteen3")
        retrieveItemsByStallId(stallId: "stall1")
    }
    
    func displayCanteens() {
        var canteensString = ""
        canteenController.retrieveCanteens() {(canteens) -> () in
            if canteens.count > 0 {
                for canteen in canteens {
                    canteensString += "Canteen ID: \(canteen.canteenId), Name: \(canteen.name), Longitude: \(canteen.longitude), Latitude: \(canteen.latitude)\n"
                }
                self.canteensList = canteens
                print("No. of Canteens: \(self.canteensList.count)")
                print("All Canteens: \n\(canteensString)")
            }
        }
    }
    
    func retrieveAllStalls() {
        stallController.retrieveStalls() {(stalls) -> () in
            if stalls.count > 0 {
                for stall in stalls {
                    //Retrieving feedback for the each stall based on StallId
                    self.feedbackController.retrieveFeedbacksByStallId(stallId: stall.stallId) {(feedbacks) -> () in
                        if feedbacks.count > 0 {
                            stall.feedbacks = feedbacks
                        }
                        var feedbackCount = 1
                        print("\nStall ID: \(stall.stallId), Canteen ID: \(stall.canteenId), Name: \(stall.name), Image Name: \(stall.imageName)")
                        for feedback in stall.feedbacks {
                            print("Feedback \(feedbackCount): \(feedback.message!)")
                            feedbackCount += 1
                        }
                    }
                }
            }
        }
    }
    
    func retrieveStallsByCanteenId(canteenId:String) {
        stallController.retrieveStallsByCanteenId(canteenID: canteenId) {(stalls) -> () in
            if stalls.count > 0 {
                for stall in stalls {
                    self.feedbackController.retrieveFeedbacksByStallId(stallId: stall.stallId) {(feedbacks) -> () in
                        if feedbacks.count > 0 {
                            stall.feedbacks = feedbacks
                        }
                        var feedbackCount = 1
                        print("\nStall ID: \(stall.stallId), Canteen ID: \(stall.canteenId), Name: \(stall.name), Image Name: \(stall.imageName)")
                        for feedback in stall.feedbacks {
                            print("Feedback \(feedbackCount): \(feedback.message!)")
                            feedbackCount += 1
                        }
                    }
                }
            }
        }
    }
    
    func retrieveItemsByStallId(stallId:String) {
        itemController.retrieveItemsByStallId(stallId: stallId) {(items) -> () in
            if items.count > 0 {
                print("Item in \(stallId)")
                for item in items {
                    print("Name: \(item.name), Likes: \(item.likes), Price: \(item.price)")
                }
            }
        }
    }
}

