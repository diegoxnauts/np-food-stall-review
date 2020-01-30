//
//  AddUpdateFeedbackViewController.swift
//  NPFoodStallReview
//
//  Created by Zhi Xuan Lee on 28/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class AddUpdateFeedbackViewController:UIViewController, UITextFieldDelegate {
    
    var feedbackStall : Stall?
    var feedbackCanteen : Canteen?
    var feedbackController:FeedbackController = FeedbackController()
    
    @IBOutlet weak var txtStallName: UILabel?
    @IBOutlet weak var txtCanteenName: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var txtFeedbackMessage: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFeedbackMessage.delegate = self
        
        //Need to check if the user is logged in. If not redirect them to the login page
        //If user is already logged in, retrieve existing feedback if any. The path should be by stall because the stall may not have any feedbacks yet=
        var existingFeedback:Feedback? = nil
        DispatchQueue.global(qos: .utility).async {
            let semaphore = DispatchSemaphore(value: 0)
            let exists : Bool = self.feedbackController.checkIfFeedbackForUserExists(stallId: self.feedbackStall!.stallId, userId: (AppDelegate.googleUser?.userID)!)
            semaphore.signal()
            semaphore.wait()
            DispatchQueue.main.async {
                if exists {
                    print("exists")
                    //retrieve the feedback here
                    DispatchQueue.global(qos: .utility).async {
                        let semaphore = DispatchSemaphore(value: 0);
                        do {
                            existingFeedback = try self.feedbackController.retrieveFeedbackForStallByUserId(stallId: self.feedbackStall!.stallId, userId: (AppDelegate.googleUser?.userID)!)
                            semaphore.signal()
                        } catch {
                            print(error)
                            return
                        }
                        semaphore.wait()
                        DispatchQueue.main.async {
                            print("Existing feedback rating: \(existingFeedback!.rating!)")
                            self.title = "Edit Feedback"
                            self.ratingView!.rating = existingFeedback!.rating!
                            self.txtFeedbackMessage!.text = existingFeedback!.message
                            self.txtStallName!.text = self.feedbackStall?.name
                            self.txtCanteenName!.text = self.feedbackCanteen?.name
                        }
                    }
                } else {
                    print("does not exist")
                    self.title = "New Feedback"
                    self.ratingView!.rating = 5
                    self.txtStallName!.text = self.feedbackStall?.name
                    self.txtCanteenName!.text = self.feedbackCanteen?.name
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        let feedbackMessage = txtFeedbackMessage!.text!
        let newFeedback:Feedback = Feedback(stallId: feedbackStall!.stallId, userId: (AppDelegate.googleUser?.userID)!, message: feedbackMessage, name: (AppDelegate.googleUser?.profile.name)!, rating: ratingView!.rating)
        DispatchQueue.global(qos: .utility).async {
            let semaphore = DispatchSemaphore(value: 0);
            let success: Bool = self.feedbackController.addOrUpdateFeedback(newFeedback: newFeedback)
            semaphore.signal()
            semaphore.wait()
            DispatchQueue.main.async {
                if success {
                    print("success")
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("Failed")
                }
            }
        }
    }
}
