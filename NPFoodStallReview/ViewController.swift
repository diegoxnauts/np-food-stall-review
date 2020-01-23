//
//  ViewController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 19/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import UIKit
import GoogleSignIn

class ViewController: UIViewController {

    @IBOutlet weak var username: UILabel!
    
    var canteenController = CanteenController()
    var stallController = StallController()
    var feedbackController = FeedbackController()
    var itemController = ItemController()
    
    var canteensList:[Canteen] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        retrieveCanteens()
        //retrieveAllStalls()
        //retrieveItemsByStallId(stallId: "stall1")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        toggleAuthUI()
    }
    
    func retrieveCanteens() {
        canteenController.retrieveCanteens() {(canteens) -> () in
            if canteens.count > 0 {
                for canteen in canteens {
                    self.stallController.retrieveStallsByCanteenId(canteenID: canteen.canteenId) {(stalls) -> () in
                        if stalls.count > 0 {
                            canteen.stalls = stalls
                            for stall in canteen.stalls {
                                self.feedbackController.retrieveFeedbacksByStallId(stallId: stall.stallId) {(feedbacks) -> () in
                                    stall.feedbacks = feedbacks
                                    print("\nCanteen: \(canteen.canteenId)")
                                    print("Stall: \(stall.stallId)")
                                    for feedback in stall.feedbacks {
                                        print("Feedback: \(feedback.message!)")
                                    }
                                }
                            }
                        }
                    }
                }
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
    
    @IBAction func btnGoogleSignIn(_ sender: Any) {
       GIDSignIn.sharedInstance()?.presentingViewController = self
//
//       if (AppDelegate.googleUser == nil){
//           GIDSignIn.sharedInstance().signIn()
//       } else {
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if (AppDelegate.googleUser == nil) {
            GIDSignIn.sharedInstance()?.signIn()
        }
        print(AppDelegate.googleUser?.profile.email)
//       }
        toggleAuthUI()
    }
    
    @IBAction func SignOut(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        //btnSignIn.isEnabled = true
        //btnSignOut.isEnabled = false
        username.text = "Logout"
    }
    
    func toggleAuthUI() {
        if let _ = GIDSignIn.sharedInstance()?.currentUser?.authentication {
            username.text = "Hello, \(String((AppDelegate.googleUser?.profile.name)!))."
            var u:String = (AppDelegate.googleUser?.profile.imageURL(withDimension: 200)!.absoluteString)!
            //print(u)
            //let url = URL(string: u)
            //UserImage.kf.setImage(with: url)
        } else {
            username.text = "Please Login"
        }
    }
}

