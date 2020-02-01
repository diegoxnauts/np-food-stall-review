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
import GoogleSignIn

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

class TopStallsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var cameraBoundary : MKMapView.CameraBoundary?
    var currentCoordinate : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.setRegion(AppDelegate.currentCoordinate!, animated: false)
        mapView.setCameraBoundary(AppDelegate.cameraBoundary, animated: false)
        mapView.showsUserLocation = true;
        for annotation in AppDelegate.annotationsList {
            mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        mapView.setRegion(AppDelegate.currentCoordinate!, animated: false)
        mapView.setCameraBoundary(AppDelegate.cameraBoundary, animated: false)
        for annotation in AppDelegate.annotationsList {
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        AppDelegate.currentCoordinate = mapView.region
        AppDelegate.cameraBoundary = mapView.cameraBoundary
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell", for: indexPath) as! tStallCell
    
        return cell
    }
    
    @IBAction func loginLogoutBtn(_ sender: Any) {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if (AppDelegate.googleUser != nil) {
            logoutAlert()
        } else {
            loginAlert()
        }
    }
    
    func loginAlert() {
        let alert = UIAlertController(title: "Log In", message: "Would you like to log in?", preferredStyle: .alert)
        let action = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let action2 = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            GIDSignIn.sharedInstance()?.signIn()
        })
        
        alert.addAction(action)
        alert.addAction(action2)
        
        present(alert, animated: true, completion: nil)
    }
    
    func logoutAlert() {
        let alert = UIAlertController(title: "Log Out", message: "Would you like to log out?", preferredStyle: .alert)
        let action = UIAlertAction(title: "No", style: .cancel, handler: nil)
        let action2 = UIAlertAction(title: "Yes", style: .default, handler: { _ in
            GIDSignIn.sharedInstance()?.signOut()
        })
        
        alert.addAction(action)
        alert.addAction(action2)
        
        present(alert, animated: true, completion: nil)
    }
}
