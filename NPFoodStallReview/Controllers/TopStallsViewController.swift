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
import Cosmos
import GoogleSignIn

class TopStallsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var canteenController: CanteenController = CanteenController();
    var stallController: StallController = StallController();
    var feedbackController: FeedbackController = FeedbackController();

    var stallList:[Stall] = []
    
    @IBOutlet weak var mapView: MKMapView!
    var cameraBoundary : MKMapView.CameraBoundary?
    var currentCoordinate : CLLocationCoordinate2D?
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    let afterGoogleSignin = Notification.Name(rawValue: afterGoogleSignInKey)
    
    @IBOutlet weak var TopStallTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.setRegion(AppDelegate.currentCoordinate!, animated: false)
        mapView.setCameraBoundary(AppDelegate.cameraBoundary, animated: false)
        mapView.showsUserLocation = true;
        for annotation in AppDelegate.annotationsList {
            mapView.addAnnotation(annotation)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if (AppDelegate.googleUser != nil) {
            loginBtn.isHidden = true
            logoutBtn.isHidden = false
        } else {
            logoutBtn.isHidden = true
            loginBtn.isHidden = false
        }
        
        createObserver();
        TopStallTableView.delegate = self;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        mapView.setRegion(AppDelegate.currentCoordinate!, animated: false)
        mapView.setCameraBoundary(AppDelegate.cameraBoundary, animated: false)
        for annotation in AppDelegate.annotationsList {
            mapView.addAnnotation(annotation)
        }
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        if (AppDelegate.googleUser != nil) {
            loginBtn.isHidden = true
            logoutBtn.isHidden = false
        } else {
            logoutBtn.isHidden = true
            loginBtn.isHidden = false
        stallList.removeAll()
        TopStallTableView.reloadData()
        
        DispatchQueue.global(qos: .utility).async {
            
            let semaphore = DispatchSemaphore(value: 0);
            do {
                let stalls = try self.stallController.retrieveStalls()
                self.stallList = stalls
                semaphore.signal()
            } catch {
                print(error);
                return;
            }
            semaphore.wait()
            // Fetch feedback for each stalls, derive stall rating and sort form high - low
            do {
                for stall in self.stallList {
                    var rating:Double = 0.0;
                    let feedbacks = try self.feedbackController.retrieveFeedbacksByStallId(stallId: stall.stallId)
                    stall.feedbacks = feedbacks
                    for feedback in feedbacks {
                        rating += feedback.rating!;
                    }
                    if (feedbacks.count > 0) {
                        rating = rating / Double(feedbacks.count);
                    }
                    stall.rating = rating;
                }

            semaphore.signal();
            }
             catch {
                print(error);
                return;
            }
            semaphore.wait()
            DispatchQueue.main.async { // this line goes back to the main thread which is the inital thread to communicate with UI stuff
                    self.TopStallTableView.reloadData();
                    print(self.stallList.count)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func createObserver() {
        // Google Sign in observer
        NotificationCenter.default.addObserver(self, selector: #selector(enableLogoutDisableLogin), name: afterGoogleSignin, object: nil)
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        AppDelegate.currentCoordinate = mapView.region
        AppDelegate.cameraBoundary = mapView.cameraBoundary
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stallList.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell", for: indexPath) as! TopStallCell
        let sortedStall = stallList.sorted(by:
        {$0.feedbacks.count > $1.feedbacks.count})
        
        let stall = sortedStall[indexPath.row]
        cell.cellDisplay(stall: stall)
        return cell
    }
    
    @IBAction func loginToGoogleBtn(_ sender: Any) {
        loginAlert()
    }
    
    @objc func enableLogoutDisableLogin() {
        self.loginBtn.isHidden = true
        self.logoutBtn.isHidden = false
    }
    
    @IBAction func logoutFromGoogleBtn(_ sender: Any) {
        logoutAlert()
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
            AppDelegate.googleUser = nil
            self.loginBtn.isHidden = false
            self.logoutBtn.isHidden = true
        })
        
        alert.addAction(action)
        alert.addAction(action2)
        
        present(alert, animated: true, completion: nil)
    }
}

