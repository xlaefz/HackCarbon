//
//  FeedClasses.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit

class Post: SafeJsonObject {
    var name: String?
    var profileImageName: String?
    var statusText: String?
    var statusImageName: String?
    var numLikes: NSNumber?
    var numComments: NSNumber?
    var startTime: String?
    var endTime: String?
    var location: Location?
    
    override func setValue(_ value: Any?, forKey key: String) {
        if key == "location" {
            location = Location()
            location?.setValuesForKeys(value as! [String: AnyObject])
        } else {
            super.setValue(value, forKey: key)
        }
    }
    func setDescription(description: String){
        self.statusText = description
    }
}

class Location: NSObject {
    var city: String?
    var state: String?
}

class Feed: SafeJsonObject {
    var feedUrl, title, link, author, type: String?
}
