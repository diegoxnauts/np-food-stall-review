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

class CanteensViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    var canteenController: CanteenController = CanteenController();
    var stallController: StallController = StallController();
    var feedbackController: FeedbackController = FeedbackController();
    
    var canteenList: [Canteen] = [];
    
    var isMapInitialized = false;
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var canteensTableView: UITableView!
    
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
        locationManager.delegate = locationDelegate;
        canteensTableView.delegate = self;
        mapView.showsUserLocation = true;
        
        // load the canteens
        
        DispatchQueue.global(qos: .utility).async { // this line means that this function will run in the background thread which is the utility thread so it wont block the main thread
            let semaphore = DispatchSemaphore(value: 0);
            
            // Execute functions serially
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
                for canteen in self.canteenList {
                    let stalls = try self.stallController.retrieveStallsByCanteenId(canteenID: canteen.canteenId)
                    canteen.stalls = stalls
                    semaphore.signal()
                }
            } catch {
                print(error);
                return;
            }
            
            semaphore.wait()
            
            DispatchQueue.main.async { // this line goes back to the main thread which is the inital thread to communicate with UI stuff
                self.canteensTableView.reloadData();
                print("Stalls: \(self.canteenList[0].stalls)");
            }
        }
    }
    
    // MARK: TABLE: Title & Headers
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil;
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
        
    // MARK: Specify Number of Rows
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return canteenList.count;
    }
    
    // MARK: Specify Cell Content
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CanteenCell", for: indexPath)
        
        let canteen = canteenList[indexPath.row];
        cell.textLabel?.text = canteen.name;
        return cell;
    }
    
    // MARK: Row Tap Event
    /*
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let canteen = canteenList[indexPath.row];
        
    }*/
    
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
}
