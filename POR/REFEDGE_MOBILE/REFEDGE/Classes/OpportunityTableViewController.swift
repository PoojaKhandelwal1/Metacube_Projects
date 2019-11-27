
//
//  OpportunityTableViewController.swift
//  REFEDGE
//
//  Created by Tejpal Kumawat on 07/11/15.
//  Copyright © 2015 Point of Reference Inc. All rights reserved.
//

import UIKit

class OpportunityTableViewController:UITableViewController{
    
    private let handler : ReferenceHandler = ReferenceHandler()
    private let progressBar = ProgressBar(text: Constants.NotificationKey.notificationLoadingMessage)
    var userInfo:UserInfo!
    var items: [NSDictionary] = [[:]]
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.Label.opportunities
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        self.tableView.addSubview(progressBar)
        loadOpportunities();
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
        return self.items.count;
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("oppCell", forIndexPath: indexPath)
        let data : NSDictionary = self.items[indexPath.row]
        //cell.detailTextLabel?.text = ">>"
        cell.textLabel!.font = UIFont(name: "AvenirNext-Regular", size: 16)
        cell.textLabel?.text = data["Name"] as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let addView = self.storyboard?.instantiateViewControllerWithIdentifier("AddEvent") as? AddEventViewController
        let data = items[indexPath.row]
        if(userInfo != nil){
            addView?.userInfo = userInfo
            addView?.oppDetail = data
        }
        self.navigationController?.pushViewController(addView!, animated: true)
    }
    
    func loadOpportunities(){
        self.handler.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.handler.watchInfo?.isIOSApp = false
                let arr : NSArray = parentValues["results"]! as! NSArray
                var targetArr = [["":""]]
                targetArr.removeAtIndex(0)
                for record in arr{
                    let account:NSDictionary = record as! NSDictionary
                    var target = [String: String]()
                    target["Name"] = (account["Name"] as? String)!
                    target["Id"] = (account["Id"] as? String)!
                    targetArr.append(target)
                }
                self.items = targetArr
                self.tableView.reloadData()
                self.progressBar.removeFromSuperview()
            }
        })
        self.handler.watchInfo?.isIOSApp = true
        self.handler.getOpportunities(userInfo.userId)
    }
}
