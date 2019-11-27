//
//  ReferenceSnoozedLocalNotificaionHandler.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 04/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

import Foundation

class ReferenceLocalNotificaionHandler :NSObject {
    
    
    private let NOTIFICATION_KEY = "referenceNotification"
    private let EVENT_KEY = "referenceEvent"
    var shared = NSUserDefaults(suiteName: Constants.NotificationKey.APP_GROUP_ID)
    
    /* This function is use to trigger local notification
    * @param fireTime
    * @param notificationData {userInfo}
    */
    func triggerLocalNotificaion(fireTime : NSDate!, notiticatioData : NSDictionary!){
        let notification = UILocalNotification()
        notification.category = "referenceNotification"
        //notification.alertTitle = "My title"
        if let remoteaps = notiticatioData {
            if let remoteMessage:NSDictionary = remoteaps["aps"] as? NSDictionary{
                notification.alertBody = remoteMessage["alert"] as? String
            }
        }
        notification.alertAction = "View Detail"
        notification.fireDate = fireTime//NSDate(timeIntervalSinceNow: NSTimeInterval(10))
        //notification.applicationIconBadgeNumber = 1
        notification.userInfo = notiticatioData as [NSObject : AnyObject]
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    /* This function is use to add notificationInfo object to NSDefault
    *  @param notificationInfo   @see NotificationInfo
    */
    func addNotificaionInLocal(notificationInfo : NotificationInfo){
        //var userDefaults = NSUserDefaults.standardUserDefaults()
        // persist a representation of this todo item in NSUserDefaults
        if(shared == nil){
            shared = NSUserDefaults(suiteName: Constants.NotificationKey.APP_GROUP_ID)
        }
        var notificationDictionary = shared!.dictionaryForKey(NOTIFICATION_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
        notificationDictionary[notificationInfo.UUID] = ["deadline": notificationInfo.deadline, "notificationData": notificationInfo.notificationData, "UUID": notificationInfo.UUID,"title":notificationInfo.title] // store NSData representation of todo item in dictionary with UUID as key
        shared!.setObject(notificationDictionary, forKey: NOTIFICATION_KEY)
        shared!.synchronize()
        
    }
    /* This function is use to remove all notificationInfo object from NSDefault
    */
    func deleteNotificationFromLocal(){
        //var userDefaults = NSUserDefaults.standardUserDefaults()
        if(shared == nil){
            shared = NSUserDefaults(suiteName: Constants.NotificationKey.APP_GROUP_ID)
        }
        shared!.removeObjectForKey(NOTIFICATION_KEY)
        shared!.synchronize()
    }
    /* This function is use to getAll notificationInfo object from NSDefault
    *  @return [NotificationInfo]
    */
    func allItems() -> [NotificationInfo] {
        if(shared == nil){
            shared = NSUserDefaults(suiteName: Constants.NotificationKey.APP_GROUP_ID)
        }
        let todoDictionary = shared!.dictionaryForKey(NOTIFICATION_KEY) ?? [:]
        let items = Array(todoDictionary.values)
        return items.map({
            NotificationInfo(deadline: $0["deadline"] as! NSDate, notificationData: $0["notificationData"] as! NSDictionary, UUID: $0["UUID"] as! String!, title: $0["title"] as! String!)
        }).sort({(left: NotificationInfo, right:NotificationInfo) -> Bool in
            (left.deadline.compare(right.deadline) == .OrderedDescending)
        })
    }
    /* This function is use to remove notificationInfo object from NSDefault
    *  @param notificationUUID
    *  @return void
    */
    func removeNotification(notificationUUID:String){
        //var userDefaults = NSUserDefaults.standardUserDefaults()
        if(shared == nil){
            shared = NSUserDefaults(suiteName: Constants.NotificationKey.APP_GROUP_ID)
        }
        var notificationDictionary = shared!.dictionaryForKey(NOTIFICATION_KEY) ?? Dictionary()
        notificationDictionary.removeValueForKey(notificationUUID)
        shared!.setObject(notificationDictionary, forKey: NOTIFICATION_KEY)
        shared!.synchronize()
    }
    //save event to nsdefault
    func saveEvents(notificationInfo : NotificationInfo){
        if(shared == nil){
            shared = NSUserDefaults(suiteName: Constants.NotificationKey.APP_GROUP_ID)
        }
        var notificationDictionary = shared!.dictionaryForKey(EVENT_KEY) ?? Dictionary() // if todoItems hasn't been set in user defaults, initialize todoDictionary to an empty dictionary using nil-coalescing operator (??)
        notificationDictionary[notificationInfo.UUID] = ["deadline": notificationInfo.deadline, "notificationData": notificationInfo.notificationData, "UUID": notificationInfo.UUID,"title":notificationInfo.title] // store NSData representation of todo item in dictionary with UUID as key
        shared!.setObject(notificationDictionary, forKey: EVENT_KEY)
        shared!.synchronize()
    }
    // Get all events from nsdefault
    func getAllEvents() -> [NotificationInfo]{
        if(shared == nil){
            shared = NSUserDefaults(suiteName: Constants.NotificationKey.APP_GROUP_ID)
        }
        let todoDictionary = shared!.dictionaryForKey(EVENT_KEY) ?? [:]
        let items = Array(todoDictionary.values)
        return items.map({
            NotificationInfo(deadline: $0["deadline"] as! NSDate, notificationData: $0["notificationData"] as! NSDictionary, UUID: $0["UUID"] as! String!, title: $0["title"] as! String!)
        }).sort({(left: NotificationInfo, right:NotificationInfo) -> Bool in
            (left.deadline.compare(right.deadline) == .OrderedDescending)
        })
    }
}

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}