//
//  TopStallsViewController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 23/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class tStallCell : UITableViewCell{

    @IBOutlet weak var testSwitch: UISwitch!
    
    @IBOutlet weak var testLbl: UILabel!
    
    
    @IBAction func testSw(_ sender: Any) {
    if testSwitch.isOn {
        testLbl.text = "ON"
    }
    else {
        testLbl.text = "OFF"
    }
    }
}

class TopStallsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell", for: indexPath) as! tStallCell
    
        return cell
    }
}
