//
//  ReferenceDetailController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 16/07/15.
//  Copyright (c) 2015 Salesforce, Inc. All rights reserved.
//
/*
* This ReferenceDetailController swift file is use to to show Detail Page.
* Here we call Forcer.com to get Summary, KeyPoints and Attributes of reference
*
*/
import Foundation
import WatchKit
import WatchConnectivity

class ReferenceDetailController : WKInterfaceController
{
    
    @IBOutlet weak var referenceName: WKInterfaceLabel!
    @IBOutlet weak var summaryDetail: WKInterfaceLabel!
    @IBOutlet weak var keyPointDetail: WKInterfaceLabel!
    @IBOutlet weak var attributeDetail: WKInterfaceLabel!
    @IBOutlet weak var summary: WKInterfaceLabel!
    @IBOutlet weak var keyPoint: WKInterfaceLabel!
    @IBOutlet weak var attributes: WKInterfaceLabel!
    @IBOutlet weak var spinner: WKInterfaceImage!
    @IBOutlet weak var summarySeparator: WKInterfaceSeparator!
    @IBOutlet weak var keyPointSeparator: WKInterfaceSeparator!
    @IBOutlet weak var attributeSeparator: WKInterfaceSeparator!
    
    var handler :RefrenceWatchHandler!
    
    /*
    * Life cycle method called when context created
    */
    override func awakeWithContext(context: AnyObject?) {
        //NSLog("Start of ReferenceDetailController.awakeWithContext()...", self)
        handler = RefrenceWatchHandler()
        let record : NSDictionary = (context as? NSDictionary)!
        let name = record["Name"] as! String
        let id = record["id"] as! String
        summarySeparator.setHidden(true)
        keyPointSeparator.setHidden(true)
        attributeSeparator.setHidden(true)
        //Starting Spinner
        self.spinner.startAnimating()
        self.spinner.setImageNamed("spinner")
        if id == Constants.NotificationKey.sampleId{
            self.stopSpinner()
            self.referenceName.setText(name)
            self.keyPointDetail.setText(Constants.Label.keyPointsDetail);
            self.attributeDetail.setText(Constants.Label.attributeDetail);
            self.summaryDetail.setText(Constants.Label.summaryDetail);
        }else{
            self.referenceName.setText(name)
            self.getReferenceDetail(id)
        }
        
        //NSLog("End of ReferenceDetailController.awakeWithContext()...", self)
    }
    /**
     * Getting reference Detail
     * @param Id as String
     * @return void
     */
    private func getReferenceDetail(id:NSString){
        let applicationData = [Constants.NotificationKey.requestType : "reference-Details", "accountId" : id]
        handler.refWatchInfo = RefrenceWatchInfo(reply: { (parentValues) -> Void in
            //NSLog("getReferenceDetail() parentValues  :\(parentValues)", self)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                if let results = parentValues["results"] as? [NSDictionary] {
                    let results = results[0]
                    let reference=results as NSDictionary
                    if let attrib=reference["refedge__Attributes__c"] as? String{
                        self.attributeDetail.setText("\(attrib)");
                    }else{
                        self.attributeDetail.setText(Constants.Label.noAttributeMessage);
                    }
                    if let summary=reference["Summary__c"] as? String{
                        self.summaryDetail.setText("\(summary)");
                    }else{
                        self.summaryDetail.setText(Constants.Label.noSummaryMessage);
                    }
                    if let keyPoints=reference["Key_Points__c"] as? String{
                        self.keyPointDetail.setText("\(keyPoints)");
                    }else{
                        self.keyPointDetail.setText(Constants.Label.noKeyPointsMessage);
                    }
                }
                self.stopSpinner()
            }
        })
        handler.sendMessage(applicationData)
        //NSLog("End of ReferenceDetail.getReferenceDetail()", self)
    }
    
    private func stopSpinner(){
        self.spinner.stopAnimating()
        self.spinner.setImageNamed("")
        summarySeparator.setHidden(false)
        keyPointSeparator.setHidden(false)
        attributeSeparator.setHidden(false)
        self.summary.setText(Constants.Label.summary)
        self.keyPoint.setText(Constants.Label.keyPoints)
        self.attributes.setText(Constants.Label.attribute)
        
    }
    /*
    * Life cycle method when app initilize
    */
    override init() {
        super.init()
    }
    override func didDeactivate() {
        super.didDeactivate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    /*
    * Life cycle method when app about to visible to user
    */
    override func willActivate() {
        super.willActivate()
    }
}
