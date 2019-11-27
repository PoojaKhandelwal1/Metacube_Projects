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

class ReferenceRowController :NSObject{
    
    
    @IBOutlet weak var referenceName: WKInterfaceLabel!
    
    var recordId:String!
    
    var name:String!
    
    func setRow(referenceName:String,recordId:String,name:String){
        self.referenceName.setText(referenceName)
        self.recordId = recordId
        self.name = name
    }
}
