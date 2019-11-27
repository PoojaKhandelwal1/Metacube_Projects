//
//  ReferenceNotificationController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 17/07/15.
//  Copyright (c) 2015 Salesforce, Inc. All rights reserved.
//
/*
* This is notification file that handles all push notification and shows tables of all availble all references of opportunity
*
*/

import Foundation
import WatchKit
import WatchConnectivity

class ReferenceNotificationController : WKUserNotificationInterfaceController
{
    
    @IBOutlet weak var referenceCount: WKInterfaceLabel!
    @IBOutlet weak var referenceMessage: WKInterfaceLabel!
    @IBOutlet weak var referenceTable: WKInterfaceTable!
    @IBOutlet weak var spinner: WKInterfaceImage!
    
    var result : NSArray!
    let refHandler :RefrenceWatchHandler = RefrenceWatchHandler()
    
    /*
    *This function automatic get called when a loacal notification is received by watch.
    */
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        if let lacalaps:NSDictionary = localNotification.userInfo{
            let oppId = (lacalaps["oppId"] as? String)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            let  oppName = lacalaps["oppName"] as? String
            let message = String(format : Constants.Label.referenceMessage,oppName!)
            self.referenceMessage.setText(message)
            let accountIds = (lacalaps["accountIds"] as? String)!.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            getReferences(oppId,accountIds: accountIds)
        }
        completionHandler(WKUserNotificationInterfaceType.Custom)
        //NSLog("End of ReferenceNotificationController.didReceiveLocalNotification() ", self)
    }
    /*
    *This function automatic called when a remote notification is received by watch.
    */
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        //Starting Spinners
        self.spinner.startAnimating()
        self.spinner.setImageNamed("spinner")
        let oppId = (remoteNotification["oppId"] as? String)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        let  oppName = remoteNotification["oppName"] as? String
        let message = String(format : Constants.Label.referenceMessage,oppName!)
        self.referenceMessage.setText(message)
        let accountIds = (remoteNotification["accountIds"] as? String)!.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        getReferences(oppId,accountIds: accountIds)
        completionHandler(WKUserNotificationInterfaceType.Custom)
    }
    
    /*
    * call parent app to get data from salseforce.
    * @param opportunityId : accountsIds
    * @return void
    */
    private func getReferences(oppId : String,accountIds : String){
        let accs = accountIds.componentsSeparatedByString(",")
        var resultAcc = ""
        for data in accs{
            resultAcc += resultAcc == "" ? "'\(data)'" : ",'\(data)'"
        }
        self.getAccounts(resultAcc)
    }
    
    /*
    * This function is use to get account detail by calling parent ios app
    * @param accountIds as String
    * @return void
    */
    func getAccounts(accountIds: String){
        //let applicationData = ["accountIds" : accountIds,Constants.NotificationKey.requestType:"accounts"]
        let applicationData = ["accountIds" : accountIds,Constants.NotificationKey.requestType:"accounts"]
        refHandler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
            //NSLog("Notification Controller getAccounts() parentValues  :\(parentValues)", self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if let arr = parentValues["results"] as? NSArray {
                    self.spinner.stopAnimating()
                    self.spinner.setImageNamed("")
                    self.result = arr
                    self.loadTable(self.result)
                    self.referenceCount.setText("\(self.result.count)")
                }
                else {
                    self.referenceCount.setText(Constants.Label.noAccountMessage)
                }
            }
        })
        refHandler.sendMessage(applicationData)
    }
    /*
    * Create table to show in UI
    * @param accounts as NSArray
    * @return void
    */
    private func loadTable(result : NSArray){
        referenceTable.setNumberOfRows(result.count, withRowType: "referenceRows")
        for (index,record) in result.enumerate(){
            let row = referenceTable.rowControllerAtIndex(index) as! ReferenceRowController
            let account:NSDictionary = record as! NSDictionary
            row.setRow((account["Name"] as? String)!, recordId: account["Id"] as! String, name: (account["Name"] as! String))
        }
    }
    
    /*
    * this function will called when we click on row of a reference table
    */
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let row = referenceTable.rowControllerAtIndex(rowIndex) as? ReferenceRowController
        self.pushControllerWithName("referenceDetails", context: row?.recordId)
    }
    /*
    * Life cycle method of watch app will be called when we move to next page or screen every time
    */
    override func didDeactivate() {
        super.didDeactivate()
    }
    override init() {
        super.init()
    }
    
    override func willActivate() {
    }
}