//
//  ResourcesViewController.swift
//  Masque
//
//  Created by Jason Zheng on 6/7/17.
//  Copyright © 2017 Jason Zheng. All rights reserved.
//

import UIKit
import Firebase

class ResourceViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var channels: [Channel] = []
    
    @IBAction func healthTouched(_ sender: Any) {
        let channel = channels[0]
        self.performSegue(withIdentifier: "showHealth", sender: channel)
    }
    
    let tableData : [String] = [
        "health",
        "dates & relationships",
        "workplace",
        "religion",
        "social advice",
        "politics",
        "book recommendations",
        "personal finance"
    ]
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")

    private var channelRefHandle: DatabaseHandle?
    
    func createChannel(_ name:String) {
        let newChannelRef = channelRef.childByAutoId() // 2
        let channelItem = [ // 3
            "name": name
        ]
        newChannelRef.setValue(channelItem) // 4
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for name in tableData{
            createChannel(name)
        }
        channels.append(Channel(id: "Km4dT7M3yoIj3XGt8hg", name: "health"))
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    
    let cellId = "cellId"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if(cell == nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: cellId)
        }
        
        cell?.textLabel?.text = tableData[indexPath.row]
        return cell!
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.senderDisplayName = "Turtle"
            chatVc.channel = channel
            chatVc.channelRef = channelRef.child(channel.id)
        }
    }
}


