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
}
