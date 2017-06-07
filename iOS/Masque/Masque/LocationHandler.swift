//
//  LocationHandler.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import CoreLocation

class LocationHandler : NSObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var location:CLLocation? = nil
    var currentCity:String? = nil
    
    override init() {
        super.init()
        if(CLLocationManager.locationServicesEnabled() == false){
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdatingLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //reverse geocode function
    
    func getCityFromLocation(location: CLLocation){
        var returnCity:String? = nil
        geoCoder.reverseGeocodeLocation(location)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // City
            if let city = placeMark.addressDictionary?["City"] as? NSString
            {
                returnCity = city as String
                self.currentCity = returnCity!
            }
        }
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    //get current city function
    func getCurrentCity() -> String{
        var returnCity:String? = nil
        if let currentLocation = location{
            geoCoder.reverseGeocodeLocation(currentLocation)
            {
                (placemarks, error) -> Void in
                
                let placeArray = placemarks as [CLPlacemark]!
                
                // Place details
                var placeMark: CLPlacemark!
                placeMark = placeArray?[0]
                
                // City
                if let city = placeMark.addressDictionary?["City"] as? NSString
                {
                    returnCity = city as String
                }
            }
        }
        while(returnCity != nil){
            //chill here
            print("stuck in return City")
        }
        return returnCity!
    }
    
    func isAuthorizedtoGetUserLocation() {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
        }
    }
    
    //this method is called by the framework on         locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
        self.getCityFromLocation(location: location!)
        self.stopUpdatingLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
}

