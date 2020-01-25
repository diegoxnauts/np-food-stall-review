//
//  MainController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 23/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//


import Foundation
import UIKit
import MapKit

class CanteensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var canteensTableView: UITableView!
    
    var canteenController: CanteenController = CanteenController();
    var stallController: StallController = StallController();
    var feedbackController: FeedbackController = FeedbackController();
    
    var canteenList: [Canteen] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        canteensTableView.delegate = self;
        
        // load the canteens
        canteenController.retrieveCanteens() {(canteens) -> () in
            for canteen in canteens {
                self.canteenList.append(canteen);
            }
            
            self.canteensTableView.reloadData();
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return canteenList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell", for: indexPath)
        
        var canteen = canteenList[indexPath.row];
        cell.textLabel?.text = canteen.name;
        return cell
    }
}
