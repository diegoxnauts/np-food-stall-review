//
//  SearchViewController.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 23/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import GoogleSignIn

class SearchViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var searchContainerView: UIView!
     @IBOutlet weak var searchTableView: UITableView!
    
    var searchController = UISearchController()
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    var canteenController: CanteenController = CanteenController();
    var stallController: StallController = StallController();
    var feedbackController: FeedbackController = FeedbackController();
    var itemController: ItemController = ItemController();

    var itemsList:[Item] = []
    var curItemList:[Item] = []
    var canteenList:[Canteen] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    let afterGoogleSignin = Notification.Name(rawValue: afterGoogleSignInKey)
    
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
        searchTableView.delegate = self
        searchController = UISearchController(searchResultsController: nil) //Pass to the same view
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false //Interact with tableview
        searchController.definesPresentationContext = true
        searchContainerView.addSubview(searchController.searchBar) //add searchbar
        searchController.searchBar.delegate = self
        searchTableView.keyboardDismissMode = .onDrag //dismiss keyboard on tableview movement
        
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
        if itemsList.count == 0{
            loading.startAnimating()
        }
        itemsList.removeAll()
        
        DispatchQueue.global(qos: .utility).async {
            
            let semaphore = DispatchSemaphore(value: 0);
            do {
                let items = try self.itemController.retrieveItems()
                self.itemsList = items
                semaphore.signal()
            } catch {
                print(error);
                return;
            }
            semaphore.wait();
            
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
            DispatchQueue.main.async { // this line goes back to the main thread which is the inital thread to communicate with UI stuff
                for canteen in self.canteenList{
                    let annotation = MKPointAnnotation()  
                    let canteenLocation = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
                    annotation.coordinate = canteenLocation
                    annotation.title = "\(canteen.name)"
                    self.mapView.addAnnotation(annotation)
                    AppDelegate.annotationsList.append(annotation)
                }
                self.loading.stopAnimating()
                self.curItemList = self.itemsList
                self.searchTableView.reloadData();
                print(self.itemsList.count)
            }
        }
        
    }
    func filterCurrent(search: String){
        if search.count > 0{
            curItemList = itemsList //fresh state
            
            let filter = curItemList.filter{$0.name.replacingOccurrences(of: " ", with: "").lowercased().contains(search.replacingOccurrences(of: " ", with: "").lowercased())}
            
            curItemList = filter
            searchTableView.reloadData()
        }
    }
    func restore(){
        curItemList = itemsList
        print("reloaded data")
        searchTableView.reloadData()
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
            GIDSignIn.sharedInstance()?.presentingViewController = self
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
            GIDSignIn.sharedInstance()?.presentingViewController = self
            GIDSignIn.sharedInstance()?.signOut()
            self.loginBtn.isHidden = false
            self.logoutBtn.isHidden = true
        })
        
        alert.addAction(action)
        alert.addAction(action2)
        
        present(alert, animated: true, completion: nil)
    }
}
extension SearchViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        if let search = searchController.searchBar.text{
            filterCurrent(search: search)
        }
    }
    
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        if let search = searchBar.text{
            filterCurrent(search: search)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchController.isActive = false
        restore()
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curItemList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell", for: indexPath) as! searchCell
        
        
        curItemList.sort { (a, b) -> Bool in
            var aLikes = 0;
            var bLikes = 0;
            for (_, value) in a.userWhoLike {
                if (value) {
                    aLikes += 1;
                }
            }
            for (_, value) in b.userWhoLike {
                if (value) {
                    bLikes += 1;
                }
            }
            return aLikes > bLikes;
        }
        
        let curItem = curItemList[indexPath.row]

        var count = 0
        for (_, value) in curItem.userWhoLike {
            if (value) {
                count += 1;
            }
        }
        cell.likeCount.text = "\(count) Likes";
        
        for canteen in canteenList{
            for stall in canteen.stalls{
                if stall.stallId == curItem.stallId{
                    cell.stallTitle.text = "\(stall.name) (\(canteen.name))"
                }
            }
        }
        
        cell.itemTitle?.text = curItem.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = curItemList[indexPath.row]
        for canteen in canteenList{
            for stall in canteen.stalls{
                if canteen.canteenId == stall.canteenId && item.stallId == stall.stallId{
                    let canteenLocation = CLLocationCoordinate2D(latitude: canteen.latitude, longitude: canteen.longitude)
                    let region = MKCoordinateRegion(center: canteenLocation, latitudinalMeters: 200, longitudinalMeters: 200)
                    mapView.setRegion(region, animated: true)
                    print(item.name)
                    print(stall.name)
                    print(canteen.name)
                }
            }
        }
    }
}

