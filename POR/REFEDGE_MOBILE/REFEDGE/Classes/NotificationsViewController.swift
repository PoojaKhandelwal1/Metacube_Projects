//
//  NotificationsViewController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 09/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

import UIKit


class NotificationsViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    private let handler : ReferenceHandler = ReferenceHandler()
    private let progressBar = ProgressBar(text: Constants.NotificationKey.notificationLoadingMessage)
    private let localNotificaionHandler : ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
    private let NOTIFICATION_KEY = "referenceNotification"
    private var items :[NotificationInfo]!
    
    var isOffline : Bool = Bool()
    var notificationData :NSDictionary!
    var userInfo : UserInfo!
    
    /*
    * Life cycle function will be get called when app will load
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(progressBar)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleNotification:"),name: "RemoteNotification",object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("refresh:"),name: "refreshNotificationTable",object: nil)
        let imageView = UIImageView(frame: CGRect(x: -0, y: 0, width: 38, height: 38))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "Title")
        imageView.image = image
        navigationItem.titleView = imageView
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        self.welcomeMessage.font = UIFont(name: "AvenirNext-Regular", size: 16)
        if(!isOffline){
            self.welcomeMessage.text = Constants.Label.noInternetConnection
            setLabels()
            items = localNotificaionHandler.allItems()
            enableSetting()
        }else{
            let message = String(format : Constants.Label.welcomeMessage,self.userInfo.userName)
            self.welcomeMessage.text = message
            items = localNotificaionHandler.allItems()
            enableSetting()
            if((notificationData) != nil){
                loadNotificationList(notificationData)
            }else{
                self.disableSettings()
            }
        }
        //testAPI()
    }
    /*
    * Handling Remote Notifications
    *
    */
    func refresh(notification: NSNotification) {
        items = localNotificaionHandler.allItems()
        self.tableView.reloadData()
    }
    /*
    * Handling Remote Notifications
    *
    */
    func handleNotification(notification: NSNotification) {
        if let userInfo = notification.object as? NSDictionary {
            notificationData = userInfo
            loadNotificationList(notificationData)
        }
    }
    private func loadNotificationList(notificationData :NSDictionary){
        welcomeMessage.hidden = true
        self.view.addSubview(progressBar)
        if let remoteaps:NSDictionary = notificationData["aps"] as? NSDictionary{
            if let remoteMessage:String = remoteaps["alert"] as? String{
                let id = notificationData["id"] as! String
                let info = NotificationInfo(deadline: NSDate(),notificationData: notificationData,UUID: id,title:remoteMessage)
                localNotificaionHandler.addNotificaionInLocal(info)
                items = localNotificaionHandler.allItems()
                self.tableView.reloadData()
                self.disableSettings()
                self.showNotificationView(info);
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("notification", forIndexPath: indexPath) as UITableViewCell
        if let notificaionList = items{
            let info =  notificaionList[indexPath.row]
            cell.textLabel?.text = info.title
            cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 16)
            cell.detailTextLabel?.text = "\(info.deadline)"
            cell.tintColor = UIColor.blueColor()
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let notificaionList = items{
            let info =  notificaionList[indexPath.row]
            self.showNotificationView(info);
        }
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
        self.tableView.hidden = true
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "notification")
    }
    private func disableSettings(){
        self.tableView.hidden = false
        setLabels()
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
        welcomeMessage.hidden = false
    }
    
    @IBAction func refreshTable(sender: AnyObject) {
        self.view.addSubview(progressBar)
        self.handler.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.handler.watchInfo?.isIOSApp = false
                let status : Bool = (parentValues["results"]! as? Bool)!
                if (status == true){
                    let fullName = SFUserAccountManager.sharedInstance().currentUser.fullName
                    let message = String(format : Constants.Label.welcomeMessage,fullName)
                    self.welcomeMessage.text = message
                    self.items = self.localNotificaionHandler.allItems()
                    self.enableSetting()
                    if((self.notificationData) != nil){
                        self.loadNotificationList(self.notificationData)
                    }else{
                        self.disableSettings()
                    }
                }else{
                    self.welcomeMessage.text = Constants.Label.noInternetConnection
                    self.setLabels()
                    self.enableSetting()
                }
            }
        })
        handler.checkInternetConnection()
        items = localNotificaionHandler.allItems()
        self.tableView.reloadData()
    }
    
    @IBAction func settings(sender: AnyObject) {
        let settingView = self.storyboard?.instantiateViewControllerWithIdentifier("SettingView") as? SettingViewController
        if(userInfo != nil){
            settingView?.userId = userInfo.userId
        }
        self.navigationController?.pushViewController(settingView!, animated: true)
    }
    @IBAction func deleteAll(sender: AnyObject) {
        localNotificaionHandler.deleteNotificationFromLocal()
        items = localNotificaionHandler.allItems()
        self.tableView.reloadData()
    }
    
    @IBAction func addEvent(sender: AnyObject) {
        let opportunitys = self.storyboard?.instantiateViewControllerWithIdentifier("OpportunityList") as? OpportunityTableViewController
        if(userInfo != nil){
            opportunitys?.userInfo = userInfo
        }
        self.navigationController?.pushViewController(opportunitys!, animated: true)
    }
    
    private func showNotificationView(info:NotificationInfo){
        let referenceListView = self.storyboard?.instantiateViewControllerWithIdentifier("NotificationDetail") as? NotificationDetailController
        referenceListView?.notificationInfo = info
        self.navigationController?.pushViewController(referenceListView!, animated: true)
    }
    
    
    func fetchDataInLocal(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("LAST_FETCH_TIME") as? NSDate
        {
            userDefaults.setObject(NSDate(), forKey: "LAST_FETCH_TIME")
        }
        handler.loadNotificationInLocal(userInfo.userId)
    }
    func testAPI(){
        let dicnary = ["aps":["alert":"2 References","badge":"0","sound":"default"],"oppId":"0061a00000AdCzKAAV","accountIds":"0011a000009cpbNAAQ,0011a000006nViaAAE","id":"111121s","oppName":"Hello Noti"]
        NSNotificationCenter.defaultCenter().postNotificationName("RemoteNotification", object: dicnary , userInfo : dicnary as [NSObject : AnyObject])
    }
}