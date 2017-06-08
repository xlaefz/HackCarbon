//
//  NewMessageController.swift
//  Masque
//
//  Created by Jason Zheng on 3/28/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUser()
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(dictionary: dictionary)
                user.id = snapshot.key
//                if Auth.auth().currentUser?.uid == "MM9OjaWVeVbI9NljKmsFnslqo4x2" {
                    if(user.id != Auth.auth().currentUser?.uid){
                        self.users.append(user)
                    }
//                } else {
////                    fetchUserAndSetupNavBarTitle()
//                    if(user.id == "hhqGum8YxmOPqcBVIc1V7sqNCr52"){
//                        self.users.append(user)
//                    }
//                }
//                //this will crash because of background thread, so lets use dispatch_async to fix
                DispatchQueue.global(qos: .background).async {
                    var bTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
                    bTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
                        UIApplication.shared.endBackgroundTask(bTask)
                        bTask = UIBackgroundTaskInvalid
                        print("task ended")
                    })
                    let backgroundTimerRemaining = UIApplication.shared.backgroundTimeRemaining
                    if(backgroundTimerRemaining > 100){
                        DispatchQueue.main.async(execute: {
                            
                            self.tableView.reloadData()
                        })
                    }else{
                        print("no time")
                    }
                }
            }
        }, withCancel: nil)
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            print("Dismiss completed")
            let user = self.users[indexPath.row]
            self.messagesController?.showChatControllerForUser(user)
        }
    }
    
}








