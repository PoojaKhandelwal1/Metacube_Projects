//
//  AddEventViewController.swift
//  REFEDGE
//
//  Created by Tejpal Kumawat on 27/10/15.
//  Copyright © 2015 Point of Reference Inc. All rights reserved.
//

import UIKit

class AddEventViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var opportunity: UILabel!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var sDateLabel: UILabel!
    @IBOutlet weak var sDatePicker: UIDatePicker!
    @IBOutlet weak var eDateLabel: UILabel!
    @IBOutlet weak var eDatePicker: UIDatePicker!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let localNotificaionHandler : ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()

    private let progressBar = ProgressBar(text: Constants.NotificationKey.notificationLoadingMessage)
    private let handler : ReferenceHandler = ReferenceHandler()
    var userInfo : UserInfo!
    var oppDetail : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.subject.delegate = self
        let opportunityName :String =  String(format : Constants.Label.addEventOppLabel,(oppDetail["Name"] as? String)!)
        let uName = String(format : Constants.Label.addEventUserLabel,self.userInfo.userName)
        userName.text = uName
        opportunity.text = opportunityName
        createButton.setTitle(Constants.Label.addEventButtonLabel, forState: .Normal)
        userName.font = UIFont(name: "AvenirNext-Regular", size: 16)
        opportunity.font = UIFont(name: "AvenirNext-Regular", size: 16)
        self.title = Constants.Label.addEvent
        eDatePicker.setDate(NSDate(timeIntervalSinceNow: NSTimeInterval(60*60)), animated: false)
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    @IBAction func create(sender: AnyObject) {
        let allFine = validate();
        if(allFine){
            createEvent()
        }
    }
    
    func createEvent(){
        let startDate = SFDateUtil.toSOQLDateTimeString(sDatePicker.date,isDateTime:true)
        let endDate = SFDateUtil.toSOQLDateTimeString(eDatePicker.date,isDateTime:true)
        let type = "Event"
        let opportunityId :String = (oppDetail["Id"] as? String)!
        let fieldData = ["StartDateTime":startDate,"EndDateTime":endDate,"ownerId":userInfo.userId,"Subject":subject.text,"ReminderDateTime":startDate,"WhatId":opportunityId]
        self.handler.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.handler.watchInfo?.isIOSApp = false
                let status : String = parentValues["results"]! as! String
                self.progressBar.removeFromSuperview()
                if(status == Constants.NotificationKey.error){
                    self.showAlert(status, message: "Event Not created.")
                }else{
                    self.showAlert(status, message: "Event successfully created.")
                }
                
            }
        })
        handler.createObject(type,fieldsData: fieldData)
        contentView.addSubview(progressBar)

    }
    func validate()->Bool{
        var flag = true
        if(subject.text == ""){
            flag = false
            showAlert("Error:",message: "Please Enter Subject")
        }else if (sDatePicker.date.isGreaterThanDate(eDatePicker.date)){
            flag = false
            showAlert("Error:",message: "Start date can't be grater than end date.")
        }
        return flag
    }
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title: title, message:message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
            //NSLog("\(title) "+"\(Constants.NotificationKey.success)")
            if(title == Constants.NotificationKey.success){
                self.navigationController?.popToRootViewControllerAnimated(true)

            }
        }))
        self.presentViewController(alert, animated: true){}
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        return false;
    }
    
}
