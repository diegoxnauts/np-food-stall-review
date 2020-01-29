//
//  FeedbacksViewController.swift
//  NPFoodStallReview
//
//  Created by Zhi Xuan Lee on 28/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

class FeedbacksViewController:UITableViewController {
    
    var selectedStall:Stall?
    var selectedCanteen:Canteen?
    var feedbackController = FeedbackController()
    var feedbackList:[Feedback] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .utility).async {
            let semaphore = DispatchSemaphore(value: 0);
            do {
                let feedbacks = try self.feedbackController.retrieveFeedbacksByStallId(stallId: self.selectedStall!.stallId)
                self.feedbackList = feedbacks
                semaphore.signal()
            } catch {
                print(error)
                return
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .utility).async {
            let semaphore = DispatchSemaphore(value: 0);
            do {
                let feedbacks = try self.feedbackController.retrieveFeedbacksByStallId(stallId: self.selectedStall!.stallId)
                self.feedbackList = feedbacks
                semaphore.signal()
            } catch {
                print(error)
                return
            }
            semaphore.wait()

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return feedbackList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "feedbackCell", for: indexPath)
        
        let feedback = feedbackList[indexPath.row]
        cell.textLabel!.text = "\(feedback.message!)"
        
        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "ToAddUpdateFeedbackPage") {
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
            if (AppDelegate.googleUser != nil) {
                return true
            } else {
                GIDSignIn.sharedInstance()?.signIn()
            }
        }
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToAddUpdateFeedbackPage") {
            let destVC = segue.destination as! AddUpdateFeedbackViewController
            destVC.feedbackStall = selectedStall
            destVC.feedbackCanteen = selectedCanteen
        }
    }
}
