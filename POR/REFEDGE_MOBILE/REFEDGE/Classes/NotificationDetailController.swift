
//
//  NotificationDetailController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 16/07/15.
//  Copyright (c) 2015 Salesforce, Inc. All rights reserved.
//
/*
* This is NotificationDetailController class will be get called when IOS app launched
*
*/

import UIKit

class NotificationDetailController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var refrenceCount: UILabel!
    @IBOutlet weak var refrenceMessage: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    
    var items: [NSDictionary] = [[:]]
    var notificationInfo : NotificationInfo!
    var handler : ReferenceHandler = ReferenceHandler()
    let progressBar = ProgressBar(text: Constants.NotificationKey.notificationLoadingMessage)
    var localNotificaionHandler : ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
    /*
    * Life cycle function will be get called when app will load
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleLocalNotification:"),name: "disableSnooze",object: nil)
        self.view.addSubview(progressBar)
        dismissButton.hidden = true
        progressBar.show();
        let imageView = UIImageView(frame: CGRect(x: -0, y: 0, width: 38, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        navigationItem.titleView = imageView
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        self.refrenceCount.text = ""
        self.refrenceMessage.text = ""
        if let remoteaps:NSDictionary = notificationInfo.notificationData["aps"] as? NSDictionary{
            if let _:String = remoteaps["alert"] as? String{
                let oppId = (notificationInfo.notificationData["oppId"] as? String)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let oppName : String = (notificationInfo.notificationData["oppName"] as? String)!
                let message = String(format : Constants.Label.referenceMessage,oppName)
                self.refrenceMessage.text = message
                let accountIds = (notificationInfo.notificationData["accountIds"] as? String)!.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                let accs = accountIds.componentsSeparatedByString(",")
                var resultAcc = ""
                for data in accs{
                    resultAcc += resultAcc == "" ? "'\(data)'" : ",'\(data)'"
                }
                getAccountData(resultAcc,oppId: oppId)
            }
        }
        enableSetting()
    }
    /*
    * Handling Local Notifications
    *
    */
    func handleLocalNotification(notification: NSNotification) {
        NSNotificationCenter.defaultCenter().postNotificationName("refreshNotificationTable", object: ["id":notificationInfo.UUID] , userInfo : nil)
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.localNotificaionHandler.removeNotification(notificationInfo.UUID)
        self.navigationController?.popToRootViewControllerAnimated(true) // return to root view
        NSNotificationCenter.defaultCenter().postNotificationName("refreshNotificationTable", object: ["id":notificationInfo.UUID] , userInfo : nil)
    }
    
    @IBAction func snoozeNotification(sender: AnyObject) {
        let snoozeView = self.storyboard?.instantiateViewControllerWithIdentifier("SnoozeView") as? SnoozeViewController
        snoozeView?.notificationInfo = self.notificationInfo
        
        self.navigationController?.pushViewController(snoozeView!, animated: true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("refrenceCell", forIndexPath: indexPath) as UITableViewCell
        let data : NSDictionary = self.items[indexPath.row]
        cell.detailTextLabel?.text = ">>"
        cell.textLabel!.font = UIFont(name: "AvenirNext-Regular", size: 16)
        cell.textLabel?.text = data["Name"] as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailView = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as? DetailViewController
        let data = items[indexPath.row]
        detailView?.detail = data
        self.navigationController?.pushViewController(detailView!, animated: true)
    }
    /*
    * Get Accounts detail based on ids
    * @param accounts id
    * @return void
    *
    */
    private func getAccountData(accountIds : String,oppId :String){
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
                self.refrenceCount.text = "\(arr.count)"
                self.tableView.reloadData()
                self.disableSettings()
            }
        })
        self.handler.watchInfo?.isIOSApp = true
        self.handler.getAccounts(accountIds)
    }
    // This function is called before the segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }
    
    /*
    * Life cycle deinit block
    */
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    private func enableSetting(){
        items.removeAtIndex(0)
        self.tableView.hidden = true
        self.refrenceCount.hidden = true
        self.refrenceMessage.hidden = true
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "refrenceCell")
    }
    private func disableSettings(){
        self.tableView.hidden = false
        self.refrenceMessage.hidden = false
        setLabels()
    }
    private func disableSnooze(notification: NSNotification){
    }
    
    override func shouldAutorotate() -> Bool {
        switch UIDevice.currentDevice().orientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return true
        default:
            return false
        }
    }
    
    private func setLabels(){
        self.progressBar.removeFromSuperview()
        refrenceMessage.font = UIFont(name: "AvenirNext-Regular", size: 16)
        dismissButton.setTitle(Constants.Label.dismissButtonLabel, forState: .Normal)
        dismissButton.hidden = false
        refrenceCount.hidden = false
    }
}
