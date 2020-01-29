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
    
    var canteenList: [Canteen] = [];
    
    var expandableCanteenList: [ExpandableCanteen] = []
    
    var isMapInitialized = false;
    
    var isFetching:Bool = false;
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var canteensTableView: UITableView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
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
                        rating = rating / Double(feedbacks.count);
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
                for canteen in self.canteenList {
                    self.expandableCanteenList.append(ExpandableCanteen(isExpanded: false, canteen: canteen))
                }
                self.loadingIndicator.stopAnimating();
                print("Async call done");
                self.isFetching = false;
                self.canteensTableView.reloadData();
            }
        }
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
