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
    
    var canteenController: CanteenController = CanteenController();
    var stallController: StallController = StallController();
    var feedbackController: FeedbackController = FeedbackController();
    var itemController: ItemController = ItemController();

    var itemsList:[Item] = []
    var curItemList:[Item] = []
    
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
        searchContainerView.addSubview(searchController.searchBar) //add searchbar
        searchController.searchBar.delegate = self
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
            
            DispatchQueue.main.async { // this line goes back to the main thread which is the inital thread to communicate with UI stuff
                
                self.curItemList = self.itemsList
                self.searchTableView.reloadData();
                print(self.itemsList.count)
            }
        }
        
    }
    @IBAction func refreshBtn(_ sender: Any) {
        restore()
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
        if let search = searchBar.text, !search.isEmpty{
            restore()
        }
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return curItemList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell", for: indexPath) as! searchCell
        cell.itemTitle?.text = curItemList[indexPath.row].name
        return cell
    }
}
