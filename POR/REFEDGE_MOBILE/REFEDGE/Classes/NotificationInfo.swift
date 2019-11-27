//
//  NotificationInfo.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 09/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

import Foundation
/*
* This structure is use to keep notification information.
*/
struct NotificationInfo {
    var notificationData: NSDictionary!
    var deadline: NSDate
    var UUID: String
    var isViewed :Bool!
    var title :String
    
    init(deadline: NSDate, notificationData: NSDictionary, UUID: String, title: String) {
        self.deadline = deadline
        self.notificationData = notificationData
        self.UUID = UUID
        self.title = title
    }
    
    var isOverdue: Bool {
        return (NSDate().compare(self.deadline) == NSComparisonResult.OrderedDescending) // deadline is earlier than current date
    }
}