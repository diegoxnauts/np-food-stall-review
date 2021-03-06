//
//  ViewController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 19/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import UIKit
import GoogleSignIn

// Own Error Type
enum FireBaseError: Error {
    case server
}

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
        print(AppDelegate.googleUser?.profile.email!)
//       }
        toggleAuthUI()
    }
    
    @IBAction func SignOut(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        //btnSignIn.isEnabled = true
        //btnSignOut.isEnabled = false
        username.text = "Logout"
    }
    
    @IBAction func triggerSomething(_ sender: Any) {
        //Must check whether user is logged in or not, if not will crash
        DispatchQueue.global(qos: .utility).async {
            let semaphore = DispatchSemaphore(value: 0);
            
            let feedback:Feedback = Feedback(stallId: "stall1", userId: (AppDelegate.googleUser?.userID)!, message: "newjhjh message!", name: (AppDelegate.googleUser?.profile.name)!, rating: 4)
            let success: Bool = self.feedbackController.addOrUpdateFeedback(newFeedback: feedback)
            semaphore.signal()
            semaphore.wait()
            DispatchQueue.main.async {
                if success {
                    print("success")
                } else {
                    print("Failed")
                }
            }
        }
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

