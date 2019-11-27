//
//  ReferenceNotificaionListController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 09/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class ReferenceNotificaionListController: WKInterfaceController
{
    
    @IBOutlet var spinner: WKInterfaceImage!
    @IBOutlet weak var notificationMessage: WKInterfaceLabel!
    @IBOutlet weak var deletAll: WKInterfaceButton!
    @IBOutlet weak var refrenceMessageTable: WKInterfaceTable!
    
    var isNotification :Bool = false
    var notification : [NSObject:AnyObject]!
    var refHandler :RefrenceWatchHandler = RefrenceWatchHandler()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        self.notificationMessage.setHidden(true)
        self.deletAll.setHidden(true)
        self.refrenceMessageTable.setHidden(true)
        self.startSpinner()
        super.willActivate()
        if(!isNotification){
            getDefaultData()
        }
        self.isNotification = false
    }
    override init() {
        super.init()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func deleteAll() {
        
    }
    
    override func handleActionWithIdentifier(identifier: String?, forLocalNotification localNotification: UILocalNotification) {
        // When local notification received
        notification = localNotification.userInfo
        self.handleNotificaion(localNotification.userInfo!)
    }
    
    override func handleActionWithIdentifier(identifier: String?, forRemoteNotification remoteNotification: [NSObject : AnyObject]) {
        self.handleNotificaion(remoteNotification)
    }
    private func handleNotificaion(remoteNotification: [NSObject : AnyObject]){
        isNotification = true
        self.startSpinner()
        notification = remoteNotification
        refrenceMessageTable.setHidden(true)
        if let remoteaps:NSDictionary = remoteNotification["aps"] as? NSDictionary{
            if let remoteMessage:String = remoteaps["alert"] as? String{
                //NSLog("\(remoteMessage)", self)
                let id = remoteNotification["id"] as! String
                self.saveNotification(remoteNotification,title: remoteMessage,uuid:id)
            }
        }
    }
    
    /*
    * This function is use to add notification to nsdefault
    * @param notification as NSDictionary
    * @return void
    */
    private func saveNotification(notification: NSDictionary,title:NSString,uuid:NSString){
        let applicationData = [Constants.NotificationKey.requestType :"saveNotification","notification": notification,"title":title,"uuid":uuid]
        self.refHandler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
            NSLog("saveNotification() parentValues  :\(parentValues)", self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                let id = self.notification["id"] as! String
                let pushData = ["data":self.notification,"uuid":id]
                self.pushControllerWithName("referenceList", context: pushData)
            }
        })
        refHandler.sendMessage(applicationData)
    }
    private func loadNotificationTable(arr : NSArray){
        refrenceMessageTable.setNumberOfRows(arr.count, withRowType: "notificationRow")
        deletAll.setHidden(true)
        for (index,record) in arr.enumerate(){
            let row = refrenceMessageTable.rowControllerAtIndex(index) as!ReferenceNotificationRowController
            let notificationInfo:NSDictionary = record as! NSDictionary
            let message = notificationInfo["message"] as? String
            row.setNotificationRow(message!, detailDiscloser: false, id: (notificationInfo["uuid"] as? String)!, userInfo: notificationInfo["notificationData"] as! NSDictionary)
            deletAll.setHidden(false)
        }
        refrenceMessageTable.setHidden(false)
    }
    /*
    * this function will called when we click on row of a reference table
    */
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row = refrenceMessageTable.rowControllerAtIndex(rowIndex) as? ReferenceNotificationRowController
        let userInfo: NSDictionary = (row!.userInfo as NSDictionary)
        let id = row!.id
        let pushData = ["data":userInfo,"uuid":id ]
        self.pushControllerWithName("referenceList", context: pushData)
    }
    
    @IBAction func deleteNotifications() {
        let applicationData = [Constants.NotificationKey.requestType :"deleteAllNotification"]
        self.refHandler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
            //NSLog("deleteNotifications() parentValues  :\(parentValues)", self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if let arr : NSArray = parentValues["results"] as? NSArray{
                    if(arr.count == 0){
                        self.isNotification = false
                        self.loadNotificationTable(arr)
                        self.notificationMessage.setHidden(false)
                        self.notificationMessage.setText(Constants.Label.noNotification)
                        self.deletAll.setHidden(true)
                    }else{
                        //NSLog("ReferenceNotificaionListController.deleteNotifications().. no response", self)
                    }
                }
            }
        })
        refHandler.sendMessage(applicationData)
    }
    
    /*
    * Getting Sample Reference data for watch app this will be called we access app  by tapping on app icon in watch
    */
    func getDefaultData(){
        let applicationData = [Constants.NotificationKey.requestType :"allNotification"]
        self.refHandler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
            //NSLog("getDefaultData() parentValues  :\(parentValues)", self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if let arr : NSArray = parentValues["results"] as? NSArray{
                    if(arr.count == 0){
                        self.isNotification = false
                        self.loadNotificationTable(arr)
                        self.notificationMessage.setHidden(false)
                        self.notificationMessage.setText(Constants.Label.noNotification)
                        self.deletAll.setHidden(true)
                        self.stopSpinner();
                    }else{
                        self.loadNotificationTable(arr)
                        self.stopSpinner();
                        self.refrenceMessageTable.setHidden(false)
                    }
                }
            }
        })
        refHandler.sendMessage(applicationData)
        //NSLog("End of ReferenceController.getReferences()..", self)
    }

    private func startSpinner(){
        //Starting Spinners
        self.spinner.setImageNamed("spinner")
        self.spinner.startAnimating()
    }
    private func stopSpinner(){
        //Stopping spinner
        self.spinner.stopAnimating()
        self.spinner.setImageNamed("")
    }
}
