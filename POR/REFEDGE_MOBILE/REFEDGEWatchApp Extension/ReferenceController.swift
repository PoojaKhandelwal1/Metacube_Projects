    //
    //  ReferenceController.swift
    //  SalesforceWatch
    //
    //  Created by Narender Singh on 16/07/15.
    //  Copyright (c) 2015 Salesforce, Inc. All rights reserved.
    //
    
    import Foundation
    import WatchKit
    
    class ReferenceController : WKInterfaceController
    {
        
        @IBOutlet weak var referencesTable: WKInterfaceTable!
        @IBOutlet weak var referencesCount: WKInterfaceLabel!
        @IBOutlet weak var refrenceAppMsg: WKInterfaceLabel!
        @IBOutlet weak var snoozButton: WKInterfaceButton!
        @IBOutlet weak var spinner: WKInterfaceImage!
        @IBOutlet weak var dismiss: WKInterfaceButton!
        
        var notificationData : NSDictionary!
        var notificationID :String!
        var disableSnooze :Bool = false
        // This field holds accounts information to cache data so every time we no need to call api to show data.
        var result : NSArray!
        // Holds Opportunity name use for cache opportunity name
        var oppName : NSString!
        var handler :RefrenceWatchHandler!
        
        /*
        * Life cycle method when app about to visible to user
        */
        override func willActivate() {
            super.willActivate()
            snoozButton.setTitle("Snooze")
        }
        
        @IBAction func dismissNotificaion() {
            //NSLog("Dismiss Notification: \(notificationID)", self)
            let applicationData = [Constants.NotificationKey.requestType : "dismissNotification","uuid":notificationID]
            handler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
                NSLog("dismissNotificaion() parentValues  :\(parentValues)", self)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    if let response :String = parentValues["results"] as? String {
                        //NSLog("Dismiss Success", self)
                        if(response == "success"){
                            self.popToRootController()
                        }
                    }
                }
            })
            handler.sendMessage(applicationData)
            
        }
        /*
        * Life cycle method called when context created
        */
        override func awakeWithContext(context: AnyObject?) {
            handler = RefrenceWatchHandler()
            NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("handleLocalNotification:"),name: "disableSnooze",object: nil)
            notificationData = (context as! [NSObject:AnyObject])["data"] as? NSDictionary
            notificationID = (context as! [NSObject:AnyObject])["uuid"] as? String
            if(notificationData != nil)
            {
                loadReferenceNotification()
            }
        }
        /*
        * Life cycle method when app initilize
        */
        override init() {
            super.init()
        }
        
        /*
        * call parent app to get data from salseforce.
        * @param opportunityId : accountsIds
        * @return void
        */
        private func loadReferenceNotification(){
            self.startSpinner()
            let array = []
            loadTable(array)
            self.refrenceAppMsg.setText("")
            self.referencesCount.setText("")
            let oppId = (notificationData["oppId"] as? String)!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.oppName = notificationData["oppName"] as? String
            let accountIds = (notificationData["accountIds"] as? String)!.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            getReferences(oppId,accountIds: accountIds)
            disableSnooze = false
            self.dismiss.setHidden(false)
            self.snoozButton.setHidden(false)
        }
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
            dispatch_async(dispatch_get_main_queue()) {
            let applicationData = ["accountIds" : accountIds,Constants.NotificationKey.requestType:"accounts"]
            self.handler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
                //NSLog("getAccounts() parentValues  :\(parentValues)", self)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    if let arr = parentValues["results"] as? NSArray {
                        self.spinner.stopAnimating()
                        self.spinner.setImageNamed("")
                        self.result = arr
                        self.loadTable(self.result)
                    }
                    else {
                        self.referencesCount.setText(Constants.Label.noAccountMessage)
                    }
                }
            })
            self.handler.sendMessage(applicationData)
            }
        }
        /*
        * Create table to show in UI
        * @param accounts as NSArray
        * @return void
        */
        private func loadTable(result : NSArray){
            self.referencesCount.setText("\(result.count)")
            if oppName == nil{
                let message = String(format : Constants.Label.noNotification,"")
                self.refrenceAppMsg.setText(message)
            }else{
                let message = String(format : Constants.Label.referenceMessage,oppName)
                self.refrenceAppMsg.setText(message)
            }
            referencesTable.setNumberOfRows(result.count, withRowType: "refrenceRows")
            for (index,record) in result.enumerate(){
                let row = referencesTable.rowControllerAtIndex(index) as!ReferenceRowController
                let account:NSDictionary = record as! NSDictionary
                row.setRow((account["Name"] as? String)!, recordId: account["Id"] as! String, name: (account["Name"] as! String))
            }
        }
        
        /*
        * This function will called when we click on row of a reference table
        */
        override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
            let row = referencesTable.rowControllerAtIndex(rowIndex) as? ReferenceRowController
            let name = row!.name as String
            let id = row!.recordId as String
            let segueData : NSDictionary = ["Name": "\(name)","id": "\(id)"]
            self.pushControllerWithName("referenceDetails", context:segueData)
        }
        /*
        * Life cycle method of watch app will be called when we move to next page or screen every time
        */
        override func didDeactivate() {
            super.didDeactivate()
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        //Starting Spinners
        private func startSpinner(){
            self.spinner.setImageNamed("spinner")
            self.spinner.startAnimating()
        }
        //Stopping spinner
        private func stopSpinner(){
            self.spinner.stopAnimating()
            self.spinner.setImageNamed("")
        }
        func handleLocalNotification(notification: NSNotification) {
            self.popToRootController()
        }
        
        override func contextForSegueWithIdentifier(segueIdentifier: String) ->
            AnyObject? {
                return ["data":self.notificationData,"uuid":notificationID]
        }
    }
