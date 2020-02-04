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
    var canteenList:[Canteen] = []
    
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
        mapView.showsUserLocation = true;
        mapView.delegate = self
        AppDelegate.currentCoordinate = mapView.region
        AppDelegate.cameraBoundary = mapView.cameraBoundary
        let defaultLocation = CLLocationCoordinate2D(latitude: 1.332118, longitude: 103.774369)
        let region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 700, longitudinalMeters: 700)
        mapView.setRegion(region, animated: true)
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
        }
        stallList.removeAll()
        
        DispatchQueue.global(qos: .utility).async {
            
            let semaphore = DispatchSemaphore(value: 0);
            do {
                let canteens = try self.canteenController.retrieveCanteens()
                self.canteenList = canteens
                semaphore.signal()
            } catch {
                print(error);
                return;
            }
            semaphore.wait();
            do {
                let stalls = try self.stallController.retrieveStalls()
                self.stallList = stalls
                semaphore.signal()
            } catch {
                print(error);
                return;
            }
            semaphore.wait()
            // Fetch feedback for each stalls, derive stall rating value
            do {
                for stall in self.stallList {
                    var rating:Double = 0.0;
                    let feedbacks = try self.feedbackController.retrieveFeedbacksByStallId(stallId: stall.stallId)
                    stall.feedbacks = feedbacks
                    for feedback in feedbacks {
                        rating += feedback.rating!;
                    }
                    if (feedbacks.count > 0) {
                        let x = rating / Double(feedbacks.count); //round it to closest .5
                        rating = round(x * 2.0) / 2.0;
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
                
                for canteen in self.canteenList{
                    let annotation = MKPointAnnotation()  // <-- new instance here
                    let canteenLocation = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
                    annotation.coordinate = canteenLocation
                    annotation.title = "\(canteen.name)"
                    self.mapView.addAnnotation(annotation)
                    AppDelegate.annotationsList.append(annotation)
                }
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
       self.stallList.sort{ //sort ratings and feedback in descending order
           if $0.rating != nil{
               if $0.rating! != $1.rating!{ //check ratings first
                   return $0.rating! > $1.rating! //sort ratings
               }
               else{
                   return $0.feedbacks.count > $1.feedbacks.count //sort feedbacks
               }
           }
           return false
       }
        let stall = stallList[indexPath.row]
        for canteen in canteenList{
            if canteen.canteenId == stall.canteenId{
                cell.canteenLabel.text = canteen.name
            }
        }
        cell.cellDisplay(stall: stall)
        cell.fbBtn.tag = indexPath.row
        cell.mBtn.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let stall = stallList[indexPath.row]
        for canteen in canteenList{
            if canteen.canteenId == stall.canteenId{
                let canteenLocation = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
                let region = MKCoordinateRegion(center: canteenLocation, latitudinalMeters: 200, longitudinalMeters: 200)
                mapView.setRegion(region, animated: true)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToViewFeedbackPage") {
            let parentVC = segue.destination as! UINavigationController
            let destVC = parentVC.topViewController as! FeedbacksViewController
            let senderCell = sender as! UIButton
            let stallIndex = senderCell.tag
            let stall = stallList[stallIndex]
            destVC.selectedStall = stall
            for canteen in canteenList{
                if canteen.canteenId == stall.canteenId{
                    destVC.selectedCanteen = canteen
                }
            }
            
        } else if (segue.identifier == "ToViewItemPage") {
            let parentVC = segue.destination as! UINavigationController
            let destVC = parentVC.topViewController as! ShowItemViewController
            let senderCell = sender as! UIButton
            let stallIndex = senderCell.tag
            let stall = stallList[stallIndex]
            destVC.selectedStall = stall
            for canteen in canteenList{
                if canteen.canteenId == stall.canteenId{
                    destVC.selectedCanteen = canteen
                }
            }
        }
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
