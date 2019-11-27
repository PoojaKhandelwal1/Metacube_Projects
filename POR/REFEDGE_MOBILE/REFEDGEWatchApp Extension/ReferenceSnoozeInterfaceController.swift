//
//  ReferenceSnoozeInterfaceController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 03/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class ReferenceSnoozeInterfaceController: WKInterfaceController
{
    var refHandler :RefrenceWatchHandler!
    var time :Float!
    var notificationData : NSDictionary!
    var notificationID :String!
    
    @IBOutlet weak var snoozeTime: WKInterfaceLabel!
    @IBOutlet weak var snoozeButton: WKInterfaceButton!
    @IBAction func snoozeSlider(value: Float) {
        time = value
        snoozeTime.setText("\(Int(time))")
        self.snoozeButton.setEnabled(true)
    }
    @IBAction func snoozeAction() {
        let snoozeTime = NSDate(timeIntervalSinceNow: NSTimeInterval(60*time))
        NSNotificationCenter.defaultCenter().postNotificationName("disableSnooze", object: nil , userInfo : nil)
        let applicationData = [Constants.NotificationKey.requestType : "snoozeNotification","snoozeData":notificationData,"snoozeTime":snoozeTime,"uuid":notificationID]
        refHandler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
            NSLog("snoozeAction() parentValues  :\(parentValues)", self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if let response :String = parentValues["results"] as? String {
                    //NSLog("Snooze Success", self)
                    if(response == "success"){
                        self.popToRootController()
                    }
                }
            }
        })
        refHandler.sendMessage(applicationData)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        refHandler = RefrenceWatchHandler()
        notificationData = (context as! [NSObject:AnyObject])["data"] as? NSDictionary
        notificationID = (context as! [NSObject:AnyObject])["uuid"] as? String
        // Configure interface objects here.
    }
    
    // This method is called when watch view controller is about to be visible to user
    override func willActivate() {
        super.willActivate()
        self.snoozeButton.setEnabled(false)
    }
    /*
    * Life cycle method when app initilize
    */
    override init() {
        super.init()
    }
    // This method is called when watch view controller is no longer visible
    override func didDeactivate() {
        super.didDeactivate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
