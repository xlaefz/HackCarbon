//
//  MainNavigationController.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class MainNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        if(FBSDKAccessToken.current() != nil){
            //if user is logged in
            //            let homeController = HomeController()
            //            viewControllers = [homeController]
            let feedController = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            viewControllers = [feedController]
        } else {
            perform(#selector(showLoginController), with: nil, afterDelay: 0.01)
        }
    }
    
    func showLoginController() {
        let loginController = LoginController()
        present(loginController, animated: true, completion: {
            //idk maybe do something
        })
    }
}
