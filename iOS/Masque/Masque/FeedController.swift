//
//  FeedController.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import Firebase

import UIKit
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth

class FeedController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let cellId = "cellId"
    let FBFeedCell2 = "FBFeedCell"
    let titles = ["LGBT Events Near Me", " LGBT Events"]
    
    
    func handleSignOut() {
        FBSDKAccessToken.setCurrent(nil)
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    
    lazy var settingsLauncher:SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.feedController = self
        return launcher
    }()
    
    func handleSettings(){
        settingsLauncher.showSettings()
    }
    
    func showControllerForSetting(setting: Setting){
        navigationController?.navigationBar.tintColor = .white
        let resourcesViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "resources")
        if(setting.name == "LGBT Resources"){
//            imageView = UIImageView(image: UIImage(named:"puripuri"))
            self.navigationController?.pushViewController(resourcesViewController, animated: true)
        }else{
//            imageView = UIImageView(image: UIImage(named:"saitama"))
        }
    }
    
    func handleChat(){
//        let messagesController = MessagesController()
//        navigationController?.pushViewController(messagesController, animated: true)
        
        print("touched chat")
    }
    
    //    var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
        self.view.addSubview(navBar);
        
        //title label
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height))
        titleLabel.text = "  Events Near Me"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        navigationItem.titleView = titleLabel
        
        self.navigationController?.navigationBar.tintColor = .white
        let settingsIcon = UIImage(named: "more_icon")
        
        //settings button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: settingsIcon, style: .plain, target: self, action: #selector(handleSettings))
        
        //chat button
        let chatButton = UIButton(frame: CGRect(x: self.view.bounds.width/2, y: self.view.bounds.height, width: self.view.bounds.width, height: 50))
        chatButton.setTitle("Chat With Us", for: .normal)
        if let image = UIImage(named: "chatbutton"){
            chatButton.setImage(image, for: .normal)
        }
        chatButton.backgroundColor = .red
        chatButton.addTarget(self, action: #selector(handleChat), for: .touchUpInside)
        
        self.view.addSubview(chatButton)
        _ = chatButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: 0, heightConstant: 50)
        
        self.navigationController?.navigationBar.isTranslucent = false
        
        setupCollectionView()
        
        setupMenuBar()
    }
    
    func scrollToMenuIndex(menuIndex: Int){
        let indexPath = NSIndexPath(item: menuIndex, section: 0)
        collectionView?.scrollToItem(at: indexPath as IndexPath, at: [] , animated: true)
        setTitleForIndex(index: menuIndex)
    }
    
    private func setTitleForIndex(index:Int){
        if let titleLabel = navigationItem.titleView as? UILabel {
            titleLabel.text = "  \(titles[index])"
        }
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = targetContentOffset.pointee.x / view.frame.width
        let indexPath = NSIndexPath(item: Int(index), section: 0)
        menuBar.collectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: [])
        
        //set title of page on scroll
        setTitleForIndex(index: Int(index))
    }
    
    func setupCollectionView(){
        if let flowLayout = collectionView?.collectionViewLayout as?
            UICollectionViewFlowLayout{
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
        
        collectionView?.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0)
        collectionView?.superview?.backgroundColor = .clear
        collectionView?.superview?.superview?.backgroundColor = .yellow
        //        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(NearMeCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.register(FBFeedCell.self, forCellWithReuseIdentifier: FBFeedCell2)
        
        //spacing at the bot/top
        collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 50, 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 50, 0)
        collectionView?.clipsToBounds = false
        collectionView?.isPagingEnabled = true
    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        mb.feedController = self
        return mb
    }()
    
    fileprivate func setupMenuBar() {
        //navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.hidesBarsOnSwipe = true
        
        //gets rid of gap between menubar and nav bar
        let blueView = UIView()
        blueView.backgroundColor = UIColor(red: 51/255, green: 90/255, blue: 149/255, alpha: 1)
        view.addSubview(blueView)
        view.addConstraintsWithFormat("H:|[v0]|", views: blueView)
        view.addConstraintsWithFormat("V:[v0(50)]", views:blueView)
        
        view.addSubview(menuBar)
        view.addConstraintsWithFormat("H:|[v0]|", views: menuBar)
        view.addConstraintsWithFormat("V:[v0(50)]", views: menuBar)
        
        menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        menuBar.horizontalBarLeftConstraint?.constant = scrollView.contentOffset.x / 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item == 1 {
            return collectionView.dequeueReusableCell(withReuseIdentifier: FBFeedCell2, for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! NearMeCell
        cell.feedController = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height - 105)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    let zoomImageView = UIImageView()
    let blackBackgroundView = UIView()
    let navBarCoverView = UIView()
    let tabBarCoverView = UIView()
    
    var statusImageView: UIImageView?
    
    func animateImageView(_ statusImageView: UIImageView) {
        self.statusImageView = statusImageView
        
        if let startingFrame = statusImageView.superview?.convert(statusImageView.frame, to: nil) {
            
            statusImageView.alpha = 0
            
            blackBackgroundView.frame = self.view.frame
            blackBackgroundView.backgroundColor = UIColor.black
            blackBackgroundView.alpha = 0
            view.addSubview(blackBackgroundView)
            
            //this is jank need to change
            navBarCoverView.frame = CGRect(x: 0, y: 0, width: 1000, height: 20 + 44 + 64)
            navBarCoverView.backgroundColor = UIColor.black
            navBarCoverView.alpha = 0
            
            
            
            if let keyWindow = UIApplication.shared.keyWindow {
                keyWindow.addSubview(navBarCoverView)
                
                tabBarCoverView.frame = CGRect(x: 0, y: keyWindow.frame.height - 49, width: 1000, height: 49)
                tabBarCoverView.backgroundColor = UIColor.black
                tabBarCoverView.alpha = 0
                keyWindow.addSubview(tabBarCoverView)
            }
            
            zoomImageView.backgroundColor = UIColor.red
            zoomImageView.frame = startingFrame
            zoomImageView.isUserInteractionEnabled = true
            zoomImageView.image = statusImageView.image
            zoomImageView.contentMode = .scaleAspectFill
            zoomImageView.clipsToBounds = true
            view.addSubview(zoomImageView)
            
            zoomImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FeedController.zoomOut)))
            
            UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { () -> Void in
                
                let height = (self.view.frame.width / startingFrame.width) * startingFrame.height
                
                let y = self.view.frame.height / 2 - height / 2
                
                self.zoomImageView.frame = CGRect(x: 0, y: y, width: self.view.frame.width, height: height)
                
                self.blackBackgroundView.alpha = 1
                
                self.navBarCoverView.alpha = 1
                
                self.tabBarCoverView.alpha = 1
                
            }, completion: nil)
            
        }
    }
    
    func zoomOut() {
        if let startingFrame = statusImageView!.superview?.convert(statusImageView!.frame, to: nil) {
            
            UIView.animate(withDuration: 0.75, animations: { () -> Void in
                self.zoomImageView.frame = startingFrame
                
                self.blackBackgroundView.alpha = 0
                self.navBarCoverView.alpha = 0
                self.tabBarCoverView.alpha = 0
                
            }, completion: { (didComplete) -> Void in
                self.zoomImageView.removeFromSuperview()
                self.blackBackgroundView.removeFromSuperview()
                self.navBarCoverView.removeFromSuperview()
                self.tabBarCoverView.removeFromSuperview()
                self.statusImageView?.alpha = 1
            })
            
        }
    }
    
}
