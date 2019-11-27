//
//  SnoozeViewController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 02/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

import UIKit

class SnoozeViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var snoozeButton: UIButton!
    
    private var localNotificaionHandler : ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
    var notificationInfo : NotificationInfo!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.Label.notiticationSnoozeLabel
        snoozeButton.setTitle(Constants.Label.notiticationButtonSnoozeLabel, forState: .Normal)
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        switch UIDevice.currentDevice().orientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return true
        default:
            return false
        }
    }
    @IBAction func snooze(sender: AnyObject) {
        //NSLog("\(datePicker.date) notification : ",self)
        localNotificaionHandler.triggerLocalNotificaion(datePicker.date,notiticatioData: notificationInfo.notificationData)
        self.localNotificaionHandler.removeNotification(notificationInfo.UUID)
        NSNotificationCenter.defaultCenter().postNotificationName("disableSnooze", object: nil , userInfo : nil)
    }
}
