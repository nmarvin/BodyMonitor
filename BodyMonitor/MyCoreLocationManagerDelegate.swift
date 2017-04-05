//
//  MyCoreLocationManagerDelegate.swift
//  BodyMonitor
//
//  Created by Nicole Marvin on 4/1/17.
//  Copyright © 2017 Nicole Marvin. All rights reserved.
//

import CoreLocation

class MyCoreLocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    
    override init() {
        super.init()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("authorized")
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.requestLocation()
            //manager.startUpdatingLocation()
            //print("updating location")
        }
        else {
            print("authorization status changed")
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // send locations to be stored; send a notification to viewController
        let locationIndex = locations.count - 1
        let currentLocation = locations[locationIndex].coordinate
        currentAltitude = locations[locationIndex].altitude
        currentLatitude = currentLocation.latitude
        currentLongitude = currentLocation.longitude
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // put locations as nil
        currentLatitude = nil
        currentLongitude = nil
        print("Error: \(error)")
    }
    
}
