//
//  ReferenceRowController.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 16/07/15.
//  Copyright (c) 2015 Salesforce, Inc. All rights reserved.
//
/*
* This ReferenceRowController object represent a row in reference table
* In this object we are having recordId and name that we use to pass to next Detail page
*/
import Foundation
import WatchKit

class ReferenceNotificationRowController :NSObject{
    
    @IBOutlet weak var titleMessage: WKInterfaceLabel!
    
    @IBOutlet weak var detailDiscloser: WKInterfaceLabel!
    var id:String!
    
    var userInfo:NSDictionary!
    func setNotificationRow(titleMessage:String,detailDiscloser:Bool,id:String,userInfo:NSDictionary){
        self.titleMessage.setText(titleMessage)
        self.detailDiscloser.setHidden(detailDiscloser)
        self.id = id
        self.userInfo = userInfo
    }
}
