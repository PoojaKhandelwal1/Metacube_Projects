//
//  TableViewController.swift
//  REFEDGEAPP
//
//  Created by Narender Singh on 08/10/15.
//  Copyright © 2015 Point of Reference Inc. All rights reserved.
//

import UIKit
import WatchConnectivity

class NotifyTableViewController: UITableViewController{
    private let handler : ReferenceHandler = ReferenceHandler()
    private let progressBar = ProgressBar(text: Constants.NotificationKey.notificationLoadingMessage)
    private let dataRows:[NSDictionary]  = [["0":"0 hour"],["1":"1 hour"],["2":"2 hours"], ["3":"3 hours"], ["4":"4 hours"],["5": "5 hours"],["6":"6 hours"],["7": "7 hours"],["8": "8 hours"],["9" :"9 hours"], ["10":"10 hours"],["11": "11 hours"],["12":"12 hours"],["13":"13 hours"],["14":"14 hours"],["15":"15 hour"],["16":"16 hours"], ["17":"17 hours"], ["18":"18 hours"],["19": "19 hours"],["20":"20 hours"],["21":"21 hours"], ["22":"22 hours"], ["23":"23 hours"]]
    var selectedIndex = -1
    var customSettingId :String!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.Label.notifyMeTimeFrame
        self.tableView.addSubview(progressBar)
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        loadSetting()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataRows.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let data = dataRows[indexPath.row]
        let text = data["\(indexPath.row)"]
        // Configure the cell...
        cell.textLabel?.text = text as? String
        cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
        if(indexPath.row == selectedIndex){
            cell.detailTextLabel?.text = "Selected"
        }else{
            cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        self.tableView.reloadData()
        let updateDictionary : NSMutableDictionary = ["Event_Notification_Timeframe__c":selectedIndex]
        handler.updateUserNotificationSetting(customSettingId ,object: "refedge__Custom_Settings__c",updateFields: updateDictionary)
        
    }
    
    func loadSetting(){
        self.handler.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                //NSLog("\(parentValues)", self)
                self.handler.watchInfo?.isIOSApp = false
                let arr : NSArray = parentValues["results"]! as! NSArray
                let timeFrameData = arr[0] as! NSDictionary
                let notifyMe = timeFrameData["Event_Notification_Timeframe__c"] as! String
                self.customSettingId = timeFrameData["Id"] as! String
                self.selectedIndex = Int(notifyMe)!
                self.progressBar.removeFromSuperview()
                self.tableView.reloadData()
                self.tableView.hidden = false
            }
        })
        self.handler.watchInfo?.isIOSApp = true
        self.handler.getNotifyMeSetting()
        
    }
}

