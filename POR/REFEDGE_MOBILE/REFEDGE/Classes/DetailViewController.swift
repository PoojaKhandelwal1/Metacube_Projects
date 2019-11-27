//
//  DetailViewController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 26/08/15.
//  Copyright (c) 2015 Reference Edge. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var keyPointLabel: UILabel!
    @IBOutlet weak var attributeLabel: UILabel!
    @IBOutlet weak var summary: UILabel!
    @IBOutlet weak var keyPoints: UILabel!
    @IBOutlet weak var attributes: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    private let progressBar = ProgressBar(text: Constants.NotificationKey.notificationLoadingMessage)
    private var summaryDetial : String!
    private var keyPointsDetail :String!
    private var attributeDetail :String!
    var detail : NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        summaryLabel.text = ""
        attributeLabel.text = ""
        keyPointLabel.text = ""
        summary.text = ""
        keyPoints.text = ""
        attributes.text = ""
        self.view.addSubview(progressBar)
        let referenceId = detail["Id"] as? String
        self.title = detail["Name"] as? String
        let nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.blueColor()]
        getReferenceDetail(referenceId!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    /*
    * Getting summary,attributes and keypoints of refrence
    * @param id {reference account id}
    * @return void
    */
    private func getReferenceDetail(id : String){
        let handler : ReferenceHandler = ReferenceHandler()
        handler.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                handler.watchInfo?.isIOSApp = false
                //NSLog("Response getOpportunity :  \(reply)",self)
                let arr : NSArray = parentValues["results"]! as! NSArray
                let account = arr[0] as! NSDictionary
                if let summaryC = account["Summary__c"] as? String{
                    self.summaryDetial = summaryC
                }else{
                    self.summaryDetial = Constants.Label.noSummaryMessage
                }
                if let keyPoint = account["Key_Points__c"] as? String{
                    self.keyPointsDetail = keyPoint
                }else{
                    self.keyPointsDetail = Constants.Label.noKeyPointsMessage
                }
                if let attribute = account["refedge__Attributes__c"] as? String{
                    self.attributeDetail = attribute
                }else{
                    self.attributeDetail = Constants.Label.noAttributeMessage
                }
                self.setLabels()
            }
        })
        handler.watchInfo?.isIOSApp = true
        handler.getReferenceDetail(id)
    }
    
    private func setLabels(){
        if let sum = self.summaryDetial{
            if let kp = self.keyPointsDetail{
                if let att = attributeDetail{
                    self.summaryLabel.text = Constants.Label.summary
                    self.keyPointLabel.text = Constants.Label.keyPoints
                    self.attributeLabel.text = Constants.Label.attribute
                    self.summary.text = sum
                    self.keyPoints.text = kp
                    self.attributes.text = att
                    self.progressBar.removeFromSuperview()
                    //------------------------------------------
                    let xAxis = CGFloat(10)
                    let font = CGFloat(15)
                    var scrollViewHeight = 0
                    let defaultSpace = CGFloat(10)
                    let labelWidth = self.view.frame.width-15
                    var y  = CGFloat(10)
                    
                    summaryLabel.frame = CGRect(x: xAxis, y: y, width: labelWidth, height: 1)
                    summaryLabel.font = UIFont(name: "AvenirNext-Regular", size: font+1)
                    summaryLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    summaryLabel.textAlignment = NSTextAlignment.Justified
                    summaryLabel.numberOfLines = 0
                    summaryLabel.sizeToFit();
                    var height = summaryLabel.frame.height
                    y = summaryLabel.frame.maxY+defaultSpace
                    //NSLog("attributeLabel Y : \(y) Width : \(labelWidth) Height : \(height) scrollViewHeight : \(scrollViewHeight)", self)
                    scrollViewHeight += Int(height)
                    
                    summary.frame = CGRect(x: xAxis, y: y, width: labelWidth, height:1)
                    summary.font = UIFont(name: "AvenirNext-Regular", size: font)
                    summary.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    summary.textAlignment = NSTextAlignment.Justified
                    summary.numberOfLines = 0
                    summary.sizeToFit();
                    height = summary.frame.height
                    y = summary.frame.maxY+defaultSpace
                    //NSLog(" summary Y : \(y) Width : \(labelWidth) Height : \(height)", self)
                    
                    scrollViewHeight += Int(height)
                    
                    keyPointLabel.frame = CGRect(x: xAxis, y: y, width: labelWidth, height: 1)
                    keyPointLabel.font = UIFont(name: "AvenirNext-Regular", size: font+1)
                    keyPointLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    keyPointLabel.textAlignment = NSTextAlignment.Justified
                    keyPointLabel.numberOfLines = 0
                    keyPointLabel.sizeToFit();
                    height = keyPointLabel.frame.height
                    y = keyPointLabel.frame.maxY+defaultSpace
                    //NSLog("attributeLabel Y : \(y) Width : \(labelWidth) Height : \(height) scrollViewHeight : \(scrollViewHeight)", self)
                    scrollViewHeight += Int(height)
                    
                    keyPoints.frame = CGRect(x: xAxis, y: y, width: labelWidth, height: 1)
                    keyPoints.font = UIFont(name: "AvenirNext-Regular", size: font)
                    keyPoints.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    keyPoints.textAlignment = NSTextAlignment.Justified
                    keyPoints.numberOfLines = 0
                    keyPoints.sizeToFit();
                    height = keyPoints.frame.height
                    y = keyPoints.frame.maxY+defaultSpace
                    scrollViewHeight += Int(height)
                    //NSLog("keyPoints Y : \(y) Width : \(labelWidth) Height : \(height)", self)
                    
                    attributeLabel.frame = CGRect(x: xAxis, y: y, width: labelWidth, height: 1)
                    attributeLabel.font = UIFont(name: "AvenirNext-Regular", size: font+1)
                    attributeLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    attributeLabel.textAlignment = NSTextAlignment.Justified
                    attributeLabel.numberOfLines = 0
                    attributeLabel.sizeToFit();
                    height = attributeLabel.frame.height
                    y = attributeLabel.frame.maxY+defaultSpace
                    //NSLog("attributeLabel Y : \(y) Width : \(labelWidth) Height : \(height) scrollViewHeight : \(scrollViewHeight)", self)
                    scrollViewHeight += Int(height)
                    
                    attributes.frame = CGRect(x: xAxis, y: y, width: labelWidth, height: 1)
                    attributes.font = UIFont(name: "AvenirNext-Regular", size: font)
                    attributes.lineBreakMode = NSLineBreakMode.ByWordWrapping
                    attributes.textAlignment = NSTextAlignment.Justified
                    attributes.numberOfLines = 0
                    attributes.sizeToFit();
                    height = attributes.frame.height
                    y = attributes.frame.maxY+defaultSpace
                    //NSLog("attributs Y : \(y) Width : \(labelWidth) Height : \(height)", self)
                    scrollViewHeight += Int(height)
                    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, CGFloat(scrollViewHeight)+font );
                    //--------------------------------
                }
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        switch UIDevice.currentDevice().orientation {
        case .Portrait, .PortraitUpsideDown, .Unknown:
            return true
        default:
            return false
        }
    }
}
