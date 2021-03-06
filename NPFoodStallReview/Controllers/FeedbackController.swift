//
//  FeedbackController.swift
//  NPFoodStallReview
//
//  Created by Zhi Xuan Lee on 22/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class FeedbackController {
    func retrieveFeedbacksByStallId(stallId:String, completion: @escaping([Feedback]) -> ()) {
        var feedbacks:[Feedback?] = []
        
        let database = Database.database()
        let feedbacksRef = database.reference(withPath: "feedbacks/\(stallId)/")
        feedbacksRef.observeSingleEvent(of: .value, with: {snapshot in
            for child in snapshot.children.allObjects {
                let feedbackSnapshot = child as! DataSnapshot
                if let feedbackInfo = feedbackSnapshot.value as? [String:AnyObject] {
                    let message = feedbackInfo["message"] as! String?
                    let name = feedbackInfo["name"] as! String?
                    let rating = feedbackInfo["rating"] as! Double?
                    let feedback = Feedback(stallId: stallId, userId: feedbackSnapshot.key, message: message!, name: name!, rating: rating!)
                    feedbacks.append(feedback)
                }
            }
            if let feedbacksList = feedbacks as? [Feedback] {
                completion(feedbacksList)
            }
        })
    }
    
    func checkIfFeedbackForStallExists(stallId:String) -> Bool {
        let semaphore = DispatchSemaphore(value: 0);
        var exists:Bool = false
        let database = Database.database()
        let feedbacksRef = database.reference(withPath: "feedbacks/")
        feedbacksRef.observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.hasChild("\(stallId)") {
                exists = true
            }
            semaphore.signal()
        }, withCancel: {(err) in
                print("Retrieve Error: \(err)")
                semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return exists
    }
    
    //MARK: Retrieve feedbacks by stallId using Semaphore method
    func retrieveFeedbacksByStallId(stallId:String) throws -> [Feedback] {
        var isError = false
        var feedbacks:[Feedback] = []
        
        let semaphore = DispatchSemaphore(value: 0);
        
        let database = Database.database()
        let feedbacksRef = database.reference(withPath: "feedbacks/\(stallId)/")
        feedbacksRef.observeSingleEvent(of: .value, with: {snapshot in
            if (snapshot.exists()) {
                for child in snapshot.children.allObjects {
                    let feedbackSnapshot = child as! DataSnapshot
                    if let feedbackInfo = feedbackSnapshot.value as? [String:AnyObject] {
                        let message = feedbackInfo["message"] as! String?
                        let name = feedbackInfo["name"] as! String?
                        let rating = feedbackInfo["rating"] as! Double?
                        let feedback = Feedback(stallId: stallId, userId: feedbackSnapshot.key, message: message!, name: name!, rating: rating!)
                        feedbacks.append(feedback)
                    }
                }
            }
            semaphore.signal()
        }, withCancel: {(err) in
            print("Retrieve Error: \(err)");
            isError = true;
            semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        if (isError) {
            throw FireBaseError.server;
        }
        
        return feedbacks;
    }
    
    func checkIfFeedbackForUserExists(stallId:String, userId:String) -> Bool {
        let semaphore = DispatchSemaphore(value: 0);
        var exists:Bool = false
        let database = Database.database()
        let feedbacksRef = database.reference(withPath: "feedbacks/")
        feedbacksRef.observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.hasChild("\(stallId)/\(userId)") {
                exists = true
            }
            semaphore.signal()
        }, withCancel: {(err) in
                print("Retrieve Error: \(err)")
                semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return exists
    }
    
    func retrieveFeedbackForStallByUserId(stallId:String, userId:String) throws -> Feedback {
        var isError = false
        var feedback:Feedback? = nil
        
        let semaphore = DispatchSemaphore(value: 0);
        
        let database = Database.database()
        let feedbacksRef = database.reference(withPath: "feedbacks/\(stallId)/\(userId)")
        feedbacksRef.observeSingleEvent(of: .value, with: {snapshot in
            if let feedbackInfo = snapshot.value as? [String:AnyObject] {
                let message = feedbackInfo["message"] as! String?
                let name = feedbackInfo["name"] as! String?
                let rating = feedbackInfo["rating"] as! Double?
                feedback = Feedback(stallId: stallId, userId: userId, message: message!, name: name!, rating: rating!)
            }
                semaphore.signal()
            }, withCancel: {(err) in
                print("Retrieve Error: \(err)");
                isError = true;
                semaphore.signal()
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        if (isError) {
            throw FireBaseError.server;
        }
        
        return feedback!
    }
    
    func addOrUpdateFeedback(newFeedback:Feedback) -> Bool {
        let semaphore = DispatchSemaphore(value: 0);
        var success:Bool = true
        let database = Database.database()
        let feedbacksRef = database.reference(withPath: "feedbacks/\(newFeedback.stallId!)/\(newFeedback.userId!)")
        let newFeedbackDictionary = ["message" : newFeedback.message!,
                                     "name" : newFeedback.name!,
                                     "rating" : newFeedback.rating!] as [String : Any]
        feedbacksRef.setValue(newFeedbackDictionary, withCompletionBlock: { err, ref in
            if let error = err {
                print("Feedback was not saved: \(error.localizedDescription)")
                success = false
                semaphore.signal()
            } else {
                print("Feedback saved successfully!")
                semaphore.signal()
            }
        })
        
        _ = semaphore.wait(wallTimeout: .distantFuture)
        
        return success
    }
}
