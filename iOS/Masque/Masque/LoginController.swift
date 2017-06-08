//
//  LoginController.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

protocol LoginControllerDelegate: class {
    func finishLoggingIn()
}

class LoginController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, LoginControllerDelegate, FBSDKLoginButtonDelegate {
    
    let loginManager = LocationHandler()
    var pageControlBottomAnchor: NSLayoutConstraint?
    
    var image1 : UIImageView!
    var image2 : UIImageView!
    var image3 : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide navigation controller
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.isNavigationBarHidden = true
        //Background Images
        image1 = UIImageView(image: UIImage(named: "page1"))
        image2 = UIImageView(image: UIImage(named: "page2"))
        image3 = UIImageView(image: UIImage(named: "page3"))
        
        //set opacity of background images
        image2.alpha = 0
        image3.alpha = 0
        
        //Facebook Button
        //        let loginButton = UIButton(type: .custom)
        //        loginButton.backgroundColor = .darkGray
        //        loginButton.frame = CGRect(x: 0, y: 0, width: 180, height: 40)
        //        loginButton.setTitle("Login With Facebook", for: .normal)
        //        loginButton.addTarget(self, action: #selector(self.loginButtonClicked), for: .TouchUpInside)
        //        loginButton = FBSDKLoginButton()
        //        loginButton.readPermissions = ["public_profile", "email", "user_friends", "user_events"]
        //        loginButton.delegate = self
        //        loginButton.setTitle("Login With Facebook", for: UIControlState.normal)
        
        //add items to view
        view.addSubview(image3)
        view.addSubview(image2)
        view.addSubview(image1)
        view.addSubview(collectionView)
        view.addSubview(pageControl)
        //        view.addSubview(loginButton)
        
        //page control constraints
        pageControlBottomAnchor = pageControl.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 300, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 40)[1]
        
        //collectionView constraints
        collectionView.anchorToTop(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor)
        
        //loginbutton constraints
        //        _ = loginButton.anchor(pageControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: view.bounds.size.width - 64, heightConstant: 40)
        
        let customFBButton = UIButton(type: .custom)
        //        customFBButton.backgroundColor = .blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        //        customFBButton.setTitle("Login With Facebook", for: .normal)
        //        customFBButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        //        customFBButton.setTitleColor(.white, for: .normal)
        let facebookLoginImage = UIImage(named: "facebookButton")
        customFBButton.setImage(facebookLoginImage, for: .normal)
        view.addSubview(customFBButton)
        customFBButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
        
        let registerLabel = UILabel(frame: CGRect(x: 100, y: 70, width: view.frame.width-32, height: 100))
        registerLabel.numberOfLines = 0
        registerLabel.textAlignment = NSTextAlignment.center
        registerLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        registerLabel.textColor = .white
        registerLabel.text = "Please Register With Facebook To Use Our App"
        registerLabel.font = UIFont(name: "BebasNueue", size: CGFloat(2))
        view.addSubview(registerLabel)
        
        _ = customFBButton.anchor(pageControl.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 50, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: view.bounds.size.width - 64, heightConstant: 50)
        _ = registerLabel.anchor(customFBButton.bottomAnchor, left:view.leftAnchor, bottom:nil, right:view.rightAnchor, topConstant: 0, leftConstant: 32, bottomConstant: 0, rightConstant: 32, widthConstant: view.bounds.size.width-64, heightConstant: 100)
        
        //background imageviews
        _ = image1.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = image2.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        _ = image3.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        image1?.clipsToBounds = false
        image2?.clipsToBounds = false
        image3?.clipsToBounds = false
        
        self.view.backgroundColor = UIColor.clear
        registerCells()
    }
    
    func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["public_profile", "email", "user_friends"], from: self) { (result, err) in
            if err != nil {
                print("Custom FB Login failed:", err!)
                return
            }
            self.finishLoggingIn()
        }
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        if (error != nil) {
            print("\(error)")
            
        } else if(result.token != nil) {
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
            finishLoggingIn()
        } else {
            print("Unknown error occured")
        }
        print("loginButton didCompleteWith \(error)")
        
        //store user here
        
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
        
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        cv.dataSource = self
        cv.delegate = self
        cv.isPagingEnabled = true
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        return cv
    }()
    
    let cellId = "cellId"
    let loginCellId = "loginCellId"
    
    let pages: [Page] = {
        let firstPage = Page(title: "Welcome To Masque", message: "An app built to support the LGBT community", imageName: "page1")
        
        let secondPage = Page(title: "Events", message: "Scroll through the event feed to check out events tailored to you!", imageName: "page2")
        
        let thirdPage = Page(title: "Anonymous Chat", message: "Come Chat and Build a Community!", imageName: "page3")
        
        return [firstPage, secondPage, thirdPage]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.pageIndicatorTintColor = .lightGray
        pc.currentPageIndicatorTintColor = UIColor(red: 247/255, green: 154/255, blue: 27/255, alpha: 1)
        pc.numberOfPages = self.pages.count
        pc.isEnabled = false
        return pc
    }()
    
    func nextPage() {
        //we are on the last page
        if pageControl.currentPage == pages.count {
            return
        }
        
        //second last page
        if pageControl.currentPage == pages.count - 1 {
            moveControlConstraintsOffScreen()
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        
        let indexPath = IndexPath(item: pageControl.currentPage + 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage += 1
    }
    
    
    //blend background images
    private var lastContentOffset: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if(self.lastContentOffset > 0 &&  self.lastContentOffset < 375){
            //blend pages 1 and 2
            let alpha = self.lastContentOffset/375
            image1.alpha = 1-alpha
            image2.alpha = alpha
            
        }else if(self.lastContentOffset > 375 && self.lastContentOffset < 750){
            //blend pages 2 and 3
            let alpha = (self.lastContentOffset-375)/375
            image2.alpha = 1-alpha
            image3.alpha = alpha
        }
        self.lastContentOffset = collectionView.contentOffset.x
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        pageControl.currentPage = pageNumber
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    fileprivate func moveControlConstraintsOffScreen() {
        pageControlBottomAnchor?.constant = 40
    }
    
    fileprivate func registerCells() {
        collectionView.register(PageCell.self, forCellWithReuseIdentifier: cellId)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! PageCell
        
        let page = pages[(indexPath as NSIndexPath).item]
        cell.page = page
        
        return cell
    }
    
    func finishLoggingIn() {
        
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        guard let mainNavigationController = rootViewController as? MainNavigationController else { return }
        
        mainNavigationController.viewControllers = [FeedController(collectionViewLayout: UICollectionViewFlowLayout())]
        
        
        //facebook auth
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else
        {return}
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        Auth.auth().signIn(with: credentials, completion: {
            (user,error) in
            if error != nil {
                print("something went wrong")
            }
            //successfully authenticated user
            print("Success", user ?? "")
            
            guard let uid = user?.uid else{
                return
            }
            let graphRequest = FBSDKGraphRequest(graphPath: "/me?fields=id,name" , parameters: nil)
            _ = graphRequest?.start(completionHandler: 	{
                (connection, result, error) -> Void in
                
                if (error == nil){
                    let resultDict = result as! [String:Any]
                    //store user in database
                    if let name = resultDict["name"]{
                        if let facebookid = resultDict["id"]{
                            
                            //successfully authenticated user
                            let imageName = UUID().uuidString
                            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
                            
                            let profileImage = UIImage(named: "anon")
                            if let uploadData = UIImageJPEGRepresentation(profileImage!, 0.1) {
                                
                                //            if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {
                                storageRef.putData(uploadData, metadata: nil, completion: {
                                    (metadata, error) in
                                    if error != nil{
                                        print(error!)
                                        return
                                    }
                                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                                        
                                        let values = ["name": name, "email": "", "profileImageUrl": profileImageUrl]
                                        
                                        self.registerUserIntoDatabaseWithUID(uid, values: values as [String : AnyObject])
                                    }

                                })
                                
                            }
                        }
                    }
                }
            })
        })
        
        
        dismiss(animated: true, completion: nil)
    }
    
    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("users").child(uid)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            
            if err != nil {
                print(err!)
                return
            }
            let user = User(dictionary: values)
            //            self.messagesController?.setupNavBarWithUser(user)
            
            //            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.height)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
        
        let indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        //scroll to indexPath after the rotation is going
        DispatchQueue.main.async {
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            self.collectionView.reloadData()
        }
        
    }
    
}
