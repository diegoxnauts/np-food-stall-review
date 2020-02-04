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
import CoreLocation
import Cosmos
import GoogleSignIn

struct ExpandableCanteen {
    var isExpanded:Bool
    var canteen: Canteen
    
    init(isExpanded: Bool, canteen: Canteen) {
        self.isExpanded = isExpanded
        self.canteen = canteen
    }
}

class CanteensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var canteenController: CanteenController = CanteenController();
    var stallController: StallController = StallController();
    var feedbackController: FeedbackController = FeedbackController();
    let afterGoogleSignin = Notification.Name(rawValue: afterGoogleSignInKey)
    
    var canteenList: [Canteen] = [];
    
    var expandableCanteenList: [ExpandableCanteen] = []
    
    var isMapInitialized = false;
    
    var isFetching:Bool = false;
    
    var cameraBoundary = AppDelegate.cameraBoundary
    var currentCoordinate = AppDelegate.currentCoordinate
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var canteensTableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    let locationDelegate = LocationDelegate()
    
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load");
        
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
        
        locationManager.delegate = locationDelegate;
        canteensTableView.delegate = self;
        mapView.showsUserLocation = true;
        mapView.delegate = self
        AppDelegate.currentCoordinate = mapView.region
        AppDelegate.cameraBoundary = mapView.cameraBoundary
        let defaultLocation = CLLocationCoordinate2D(latitude: 1.332118, longitude: 103.774369)
        let region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 700, longitudinalMeters: 700)
        mapView.setRegion(region, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        if (AppDelegate.googleUser != nil) {
            loginBtn.isHidden = true
            logoutBtn.isHidden = false
        } else {
            logoutBtn.isHidden = true
            loginBtn.isHidden = false
        }
        
        mapView.setRegion(AppDelegate.currentCoordinate!, animated: false)
        mapView.setCameraBoundary(AppDelegate.cameraBoundary, animated: false)
        
        // So tableview would refresh the data and not add duplicate items
        canteenList.removeAll();
        expandableCanteenList.removeAll();
        self.canteensTableView.reloadData();
        
        // Indicate fetching is ongoing
        loadingIndicator.startAnimating();
        print("Async call started");
        
        // This line means that this function will run in the background thread which is the utility thread so it wont block the main thread
        DispatchQueue.global(qos: .utility).async {
            
            let semaphore = DispatchSemaphore(value: 0);
            
            // Fetch Canteens
            do {
                let canteens = try self.canteenController.retrieveCanteens()
                self.canteenList = canteens
                semaphore.signal()
            } catch {
                print(error);
                return;
            }
            semaphore.wait();
            
            // Fetch Stalls for each canteen
            do {
                for canteen in self.canteenList {
                    let stalls = try self.stallController.retrieveStallsByCanteenId(canteenID: canteen.canteenId)
                    canteen.stalls = stalls
                }
                semaphore.signal()
            } catch {
                print(error);
                return;
            }
            semaphore.wait()
            
            // Fetch feedback for each stalls, derive stall rating and sort form high - low
            do {
                for canteen in self.canteenList {
                    let stalls = canteen.stalls;
                    for stall in stalls {
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
                }
                semaphore.signal();
            } catch {
                print(error);
                return;
            }
            semaphore.wait()
            
            DispatchQueue.main.async { // this line goes back to the main thread which is the inital thread to communicate with UI stuff
                AppDelegate.annotationsList = []
                for canteen in self.canteenList {
                    self.expandableCanteenList.append(ExpandableCanteen(isExpanded: false, canteen: canteen))
                    let annotation = MKPointAnnotation()  // <-- new instance here
                    let canteenLocation = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
                    annotation.coordinate = canteenLocation
                    annotation.title = "\(canteen.name)"
                    self.mapView.addAnnotation(annotation)
                    AppDelegate.annotationsList.append(annotation)
                    print(canteen.name)
                }
                self.loadingIndicator.stopAnimating();
                print("Async call done");
                self.isFetching = false;
                self.canteensTableView.reloadData();
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
    
    // MARK: TABLE: Section Headers
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell") as! CanteenHeaderCell;
        cell.setup(expandableCanteen: expandableCanteenList[section]);
        cell.toggleBtn.tag = section;
        cell.toggleBtn.addTarget(self, action: #selector(toggleSection), for: .touchUpInside)
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell") as! CanteenHeaderCell;
        
        return cell.bounds.height;
    }

    @objc func toggleSection(button: UIButton) {
        // close
        let section = button.tag;
        var indexPaths = [IndexPath]();
        for row in expandableCanteenList[section].canteen.stalls.indices {
            //print(section, row);
            let indexPath = IndexPath(row: row, section: section)
            indexPaths.append(indexPath)
        }
        let isExpanded = expandableCanteenList[section].isExpanded
        expandableCanteenList[section].isExpanded = !isExpanded
        
        if (isExpanded) {
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        }
        
        if isExpanded {
            canteensTableView.deleteRows(at: indexPaths, with: .fade)
        } else {
           canteensTableView.insertRows(at: indexPaths, with: .fade)
        }
    }
    
    //  MARK: Specify number of Sections
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return expandableCanteenList.count
    }
        
    // MARK: Specify Number of Rows
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !expandableCanteenList[section].isExpanded {
            return 0
        }
        
        return expandableCanteenList[section].canteen.stalls.count
    }
    
    // MARK: Specify Cell Content
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StallCell", for: indexPath) as! StallCell;
        
        let stall = expandableCanteenList[indexPath.section].canteen.stalls[indexPath.row];
        
        cell.setup(stall: stall);
        cell.feedbackBtn.tag = indexPath.row
        cell.feedbackBtn.accessibilityIdentifier = "\(indexPath.section)"
        
        cell.menuBtn.tag = indexPath.row
        cell.menuBtn.accessibilityIdentifier = "\(indexPath.section)"
        
        return cell;
    }
    
    // MARK: Row Tap Event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let canteen = canteenList[indexPath.section]
        let canteenLocation = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
        let region = MKCoordinateRegion(center: canteenLocation, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: MAP Functions
    
    func initializeMapCanteenLabels() {
        for canteen in canteenList {
            let canteenLocation = CLLocation(latitude: canteen.latitude, longitude: canteen.longitude);
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = canteenLocation.coordinate;
            annotation.title = canteen.name;
            self.mapView.addAnnotation(annotation);
        }
    }
    
    
    let regionRadius: CLLocationDistance = 250
    
    func centerMapOnLocation(location: CLLocation)
    {
        let coordinateRegion = MKCoordinateRegion (
        center: location.coordinate,
        latitudinalMeters: regionRadius,
        longitudinalMeters: regionRadius)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ToViewFeedbackPage") {
            let parentVC = segue.destination as! UINavigationController
            let destVC = parentVC.topViewController as! FeedbacksViewController
            let senderCell = sender as! UIButton
            let canteenIndex = Int(senderCell.accessibilityIdentifier!)!
            let stallIndex = senderCell.tag
            let stall = expandableCanteenList[canteenIndex].canteen.stalls[stallIndex]
            let canteen = canteenList[canteenIndex]
            destVC.selectedStall = stall
            destVC.selectedCanteen = canteen
            
        } else if (segue.identifier == "ToViewItemPage") {
            let parentVC = segue.destination as! UINavigationController
            let destVC = parentVC.topViewController as! ShowItemViewController
            let senderCell = sender as! UIButton
            let canteenIndex = Int(senderCell.accessibilityIdentifier!)!
            let stallIndex = senderCell.tag
            let stall = expandableCanteenList[canteenIndex].canteen.stalls[stallIndex]
            let canteen = canteenList[canteenIndex]
            destVC.selectedStall = stall
            destVC.selectedCanteen = canteen
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
