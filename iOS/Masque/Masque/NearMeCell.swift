//
//  NearMeCell.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKCoreKit
import SwiftyJSON

class NearMeCell: BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    var posts = [Post]()
    
    let cellId = "cellId"
    
    override func setupViews() {
        super.setupViews()
//        print("THIS IS HIT AFTER LOGOUT")
        self.locationManager.requestWhenInUseAuthorization()
        
        startUpdatingLocation()
        backgroundColor = .brown
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        hardCodeData()
    }
    
    var feedController:FeedController?
    
    func hardCodeData(){
        
    }
    
    func getCityFromLocation(location: CLLocation){
        var returnCity:String? = nil
        print(location.coordinate)
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
                let cityQuery = returnCity?.replacingOccurrences(of: " ", with: "%20")
                let params = ["fields": "owner, parent_group, description, end_time, name, place, start_time, id, attending_count, declined_count, cover"]
                let graphRequest = FBSDKGraphRequest(graphPath: "search?q=" + cityQuery! + "%20gay&type=event&center=37.785834,-122.406417&distance=1000" , parameters: params)
                _ = graphRequest?.start(completionHandler: 	{
                    (connection, result, error) -> Void in
                    if (error == nil){
//                        print(result!)
                        
                        self.posts = [Post]()
                        let json = JSON(result!)
                        print(json["data"])
                        
                        if(json["data"].array?.count == 0){
                            print("Data is empty")
                            self.handleEmptyData()
                        }else{
                            
                            for (index,subJson):(String, JSON) in json["data"] {
                                let post = Post()
                                post.setDescription(description: subJson["description"].stringValue)
                                post.name = subJson["name"].stringValue
                                post.statusImageName = subJson["cover"]["source"].stringValue
                                let quasaPhotoURL = "https://scontent.xx.fbcdn.net/v/t1.0-1/p50x50/17458186_1267974996648203_6951156693000357520_n.png?oh=c5dc8527932dc00d4bd10596a9c9f211&oe=59888CEB"
                                post.profileImageName = quasaPhotoURL
                                let placeName = subJson["place"]["name"]
                                let addressJson = subJson["place"]["location"]
                                let location = Location()
                                if(addressJson != JSON.null){
                                    if(addressJson["street"] != JSON.null){
                                        
                                        location.city = addressJson["street"].stringValue + ", " + addressJson["city"].stringValue + ", " +
                                            addressJson["zip"].stringValue
                                        location.state = addressJson["state"].stringValue
                                    }else{
                                        location.city = placeName.stringValue
                                        location.state = ""
                                    }
                                }else{
                                    location.city = placeName.stringValue
                                    location.state = ""
                                }
                                post.location = location
                                post.numLikes = subJson["attending_count"].int! as NSNumber
                                post.numComments = subJson["declined_count"].int! as NSNumber
                                post.startTime = subJson["start_time"].stringValue
                                post.endTime = subJson["end_time"].stringValue
                                
                                self.posts.append(post)
                            }
                            self.collectionView.alwaysBounceVertical = true
                            self.collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                            self.collectionView.register(FeedCell.self, forCellWithReuseIdentifier: self.cellId)
                            self.collectionView.reloadData()
                        }
                    }else{
                        print(error!)
                    }
                })
            }
        }
    }
    
    func handleEmptyData(){
        let params = ["fields": "description, end_time, name, place, start_time, id, attending_count, declined_count, cover"]
        let graphRequest = FBSDKGraphRequest(graphPath: "search?q=Los%20Angeles%20gay&type=event&center=37.785834,-122.406417&distance=1000" , parameters: params)
        _ = graphRequest?.start(completionHandler: 	{
            (connection, result, error) -> Void in
            if (error == nil){
                self.posts = [Post]()
                let json = JSON(result!)
                //                print(json)
                for (index,subJson):(String, JSON) in json["data"] {
                    let post = Post()
                    post.setDescription(description: subJson["description"].stringValue)
                    post.name = subJson["name"].stringValue
                    post.statusImageName = subJson["cover"]["source"].stringValue
                    let quasaPhotoURL = "https://scontent.xx.fbcdn.net/v/t1.0-1/p50x50/17458186_1267974996648203_6951156693000357520_n.png?oh=c5dc8527932dc00d4bd10596a9c9f211&oe=59888CEB"
                    post.profileImageName = quasaPhotoURL
                    let placeName = subJson["place"]["name"]
                    let addressJson = subJson["place"]["location"]
                    let location = Location()
                    if(addressJson != JSON.null){
                        if(addressJson["street"] != JSON.null){
                            location.city = addressJson["street"].stringValue + ", " + addressJson["city"].stringValue + ", " +
                                addressJson["zip"].stringValue
                            location.state = addressJson["state"].stringValue
                        }else{
                            location.city = placeName.stringValue
                            location.state = ""
                        }
                    }else{
                        location.city = placeName.stringValue
                        location.state = ""
                    }
                    post.location = location
                    post.numLikes = subJson["attending_count"].int! as NSNumber
                    post.numComments = subJson["declined_count"].int! as NSNumber
                    post.startTime = subJson["start_time"].stringValue
                    post.endTime = subJson["end_time"].stringValue
                    
                    self.posts.append(post)
                }
                self.collectionView.alwaysBounceVertical = true
                self.collectionView.backgroundColor = UIColor(white: 0.95, alpha: 1)
                self.collectionView.register(FeedCell.self, forCellWithReuseIdentifier: self.cellId)
                self.collectionView.reloadData()
            }else{
                print(error!)
            }
        })
    }
    
    var currentLocation: CLLocation = CLLocation()
    func startUpdatingLocation(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
//            print("THIS IS HIT AFTER LOGOUT 2")
            if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorized){
                currentLocation = locationManager.location!
                //                locationManager.stopUpdatingLocation()
            }else{
                print("FAILED IF STATEMENT")
            }
        }else{
            print("SERVICES NOT ENABLED")
        }
    }
    
    func stopUpdatingLocation(){
        locationManager.stopUpdatingLocation()
    }
    
    //this method will be called each time when a user change his location access preference.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("User allowed us to access location")
            //do whatever init activities here.
        }
    }
    
    //this method is called by the framework on locationManager.requestLocation();
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Did location updates is called")
        let location = locations.last
        self.getCityFromLocation(location: location!)
        self.stopUpdatingLocation()
//        print("HIT LOCATION MANAGER FIRST")
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Did location updates is called but failed getting location \(error)")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! FeedCell
        
        feedCell.post = posts[indexPath.item]
        feedCell.feedController = feedController
        
        return feedCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if let statusText = posts[indexPath.item].statusText {
            
            let rect = NSString(string: statusText).boundingRect(with: CGSize(width: frame.width, height: 1000), options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            
            let knownHeight: CGFloat = 8 + 44 + 4 + 4 + 200 + 8 + 24 + 8 + 44
            
            return CGSize(width: frame.width, height: rect.height + knownHeight + 24)
        }
        
        return CGSize(width: frame.width, height: 500)
    }
    
}
