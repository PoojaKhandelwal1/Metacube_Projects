//
//  WatchInfo.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 16/07/15.
//  Copyright (c) 2015 Salesforce, Inc. All rights reserved.
//
/*
 * This WatchInfo object is used as DTO to pass data from IOS app  to watchkit and watchkit to IOS
 * We sends User Info to IOS App from watchkit and sends back reply to Watchkit
 */

import Foundation


class WatchInfo: NSObject, SFRestDelegate {
    
    var userInfo: [NSObject : AnyObject]!
    
    let response: ([NSObject : AnyObject]!) -> Void
    var isIOSApp :Bool!
    var iosAppData : [String : AnyObject]!
    
    init(userInfo: [NSObject : AnyObject], reply: ([NSObject : AnyObject]!) -> Void) {
        
        self.userInfo = userInfo
        response = reply
    }
       
}
