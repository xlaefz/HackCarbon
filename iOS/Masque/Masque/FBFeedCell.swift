//
//  FBFeedCell.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import SwiftyJSON
import FBSDKCoreKit

class FBFeedCell : BaseCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var posts = [Post]()

    let cellId = "cellId"

    var feedController:FeedController?

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .white
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    func hardCodeData(){
        
        let params = ["fields": "description, end_time, name, place, start_time, id, attending_count, declined_count, cover"]
        let graphRequest = FBSDKGraphRequest(graphPath: "GayStarNews/events" , parameters: params)
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
                    let quasaPhotoURL = "https://scontent.xx.fbcdn.net/v/t1.0-1/p50x50/18195082_1368603776549269_859758123656953752_n.png?oh=b7392692382e98cb8549a99dac4f11b0&oe=59D7C77C"
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
    
    override func setupViews() {
        super.setupViews()
        addSubview(collectionView)
        addConstraintsWithFormat("H:|[v0]|", views: collectionView)
        addConstraintsWithFormat("V:|[v0]|", views: collectionView)
        hardCodeData()
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
