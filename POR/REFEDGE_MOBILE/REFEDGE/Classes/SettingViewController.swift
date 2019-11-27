//
//  SettingViewController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 01/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
 
    @IBOutlet weak var notificationSettingLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notifyMe: UIButton!
    @IBOutlet weak var pickView: UIPickerView!
    var pickerDataSource = ["0 minutes", "10 minutes", "15 minutes", "30 minutes","1 hour", "2 hours", "3 hours", "4 hours", "5 hours", "6 hours", "7 hours", "8 hours", "9 hours", "10 hours", "11 hours"];
    var handler : ReferenceHandler = ReferenceHandler()
    var userId : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = Constants.NotificationKey.settingPageTitle
        notificationSettingLabel.text = Constants.Label.notificationSettingLabel
        notifyMe.setTitle(Constants.Label.notifyMeTimeFrameButton, forState: .Normal)
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        notificationSettingLabel.text = Constants.Label.notificationSettingLabel
        notificationSwitch.addTarget(self, action: Selector("stateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        // Do any additional setup after loading the view.
        if(userId != nil){
            self.getUserNotificationSetting()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func stateChanged(switchState: UISwitch) {
        if(userId != nil){
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let updateDictionary : NSMutableDictionary = [:]
            updateDictionary.removeAllObjects()
            
            var isEnable = false
            if switchState.on {
                //NSLog("The Switch is On",self)
                isEnable = true
            } else {
                //NSLog("The Switch is Off",self)
                isEnable = false
                
            }
            updateDictionary[Constants.NotificationKey.refedgeNotificaionRequest] = isEnable
            userDefaults.setObject(isEnable, forKey: "notificaionSetting")
            userDefaults.synchronize()
            handler.updateUserNotificationSetting(userId,object: "User",updateFields: updateDictionary)
        }
    }
    private func getUserNotificationSetting(){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let setting = userDefaults.objectForKey("notificaionSetting") as! Bool
        self.notificationSwitch.setOn(setting, animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    override func shouldAutorotate() -> Bool {
        switch UIDevice.currentDevice().orientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return true
        default:
            return false
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        //NSLog("Selected \(pickerDataSource[row])",self) //
    }
    @IBAction func notifyMeSetting(sender: AnyObject){
        let notifyMeView = self.storyboard?.instantiateViewControllerWithIdentifier("NotifyMeDataList") as? NotifyTableViewController
        
        self.navigationController?.pushViewController(notifyMeView!, animated: true)
    }
}
