//
//  LocationDelegate.swift
//  NPFoodStallReview
//
//  Created by Jm San Diego on 25/1/20.
//  Copyright © 2020 Jm San Diego. All rights reserved.
//

import CoreLocation

class LocationDelegate : NSObject, CLLocationManagerDelegate
{
    var locationCallback: ((CLLocation) -> ())? = nil
    
    func locationManager(_ manager: CLLocationManager,
                        didUpdateLocations locations: [CLLocation])
    {
        guard let currentLocation = locations.last else { return }
        locationCallback?(currentLocation)
    }
}

