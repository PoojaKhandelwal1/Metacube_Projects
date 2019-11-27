//
//  ReferenceHandler.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 16/07/15.
//  Copyright (c) 2015 Salesforce, Inc. All rights reserved.
//
/*
* This file swift file is responsible to call Force.com Rest and get response as json format
* For Help Go to URL = http://forcedotcom.github.io/SalesforceMobileSDK-iOS/Documentation/SalesforceRestAPI/SFRestAPI_h/Classes/SFRestAPI/index.html#//apple_ref/occ/cl/SFRestAPI
* For More api Implementation
*/
import Foundation

class ReferenceHandler : NSObject, SFRestDelegate {
    
    var watchInfo : WatchInfo?
    
    var nottifyMeSetting:String!
    /*
    * Get Opportunity and associated account from Force.com using rest api
    */
    func getReferences() {
        //NSLog("Start of getReference()..",self)
        var query = "SELECT Id, Name, Account.Name ,Account.Id FROM Opportunity  limit 1"
        if let oppId:String = watchInfo?.userInfo["oppId"] as? String{
            query+=" where id = '\(oppId)'"
        }
        
        getData(query)
    }
    /*
    * Get Opportunity from Force.com using rest api
    */
    
    func getOpportunityDetail(oppId :String){
        //NSLog("Start of getOpportunityDetail().. oppId : \(oppId)",self)
        let query="select id, name from Opportunity where id = '"+(oppId as String)+"'"
        getData(query)
    }
    
    /*
    * Get Opportunity from Force.com using rest api
    */
    
    func getOpportunities(userId: String){
        //NSLog("Start of getOpportunityDetail().. oppId : \(oppId)",self)
        let query="select id, name from Opportunity where ownerId = '"+userId+"'";
        getData(query)
    }
    /*
    * Get Account from Force.com using rest api
    */
    func getAccounts(accountIds :String){
        //NSLog("Start of getReferenceDetails().. targetID : \(accountIds)",self)
        let query="select id, name from Account where id in ("+(accountIds as String)+") ORDER BY Name"
        getData(query)
    }
    
    /*
    * Get Key Points, Summary and Attributes from Force.com using rest api
    */
    func getReferenceDetail(accountId : NSString){
        //NSLog("Start of getKeyPoints().. accountId : \(accountId)",self)
        let query="SELECT Key_Points__c,Summary__c,refedge__Attributes__c FROM refedge__Reference_Basic_Information__c WHERE refedge__Account__c = '"+(accountId as String)+"' and refedge__Contact__c = null"
        getData(query)
        //NSLog("End of getKeyPoints() IOS APP..",self)
        
    }
    /*
    * Get User info to check is notificaion enable or not
    * @param userId
    */
    func getNotificaionSetting(userId: String){
        let query = "select Refedge_Notification__c from User where id = '"+userId+"'";
        getData(query)
    }
    
    /*
    * Updating user
    * @param userId
    * @param updateFields {fields dictionary to update}
    * @param bool
    */
    func updateUserNotificationSetting(id: String,object:String,updateFields :NSMutableDictionary)-> Bool{
        //NSLog("\(id) \(object) \(updateFields)", self)
        let api = SFRestAPI.sharedInstance()
        var flag :Bool = false
        let restRequest = api.requestForUpdateWithObjectType(object, objectId: id, fields: updateFields as [NSObject : AnyObject])
        api.sendRESTRequest(restRequest, failBlock: {
            (NSError error) -> Void in
            //NSLog("Error : \(error)",self)
            }) {
                (AnyObject dataResponse) -> Void in
                //NSLog("Success response : \(dataResponse)", self)
                flag = true
        }
        return flag
    }
    /*
    * This function is use to create object in salesforce like Account, Contact, Event  or any object.
    * @param objectType
    * @parma fieldsData {object fields}
    */
    func createObject(objectType :String,fieldsData :NSDictionary){
        //NSLog("Create Data object \(objectType) fields \(fieldsData)", self)
        let api = SFRestAPI.sharedInstance()
        let restRequest = api.requestForCreateWithObjectType(objectType, fields: fieldsData as [NSObject:AnyObject])
        api.sendRESTRequest(restRequest, failBlock: {
            (NSError error) -> Void in
            //NSLog("Error : \(error)",self)
            if let watchInfo = self.watchInfo {
                let stuff = ["results" : Constants.NotificationKey.error]
                watchInfo.response(stuff)
            }
            }) {
                (AnyObject dataResponse) -> Void in
                //NSLog("Success response : \(dataResponse)", self)
                if let watchInfo = self.watchInfo {
                    let stuff = ["results" : Constants.NotificationKey.success]
                    watchInfo.response(stuff)
                }
        }
    }
    /*
    * Get Notificaion info
    * @param userId
    */
    func getRefNotificaionEvents(userId: String){
        let lastFetchDate = NSUserDefaults.standardUserDefaults().objectForKey("LAST_FETCH_TIME") as? NSDate
        let fetchTime = SFDateUtil.toSOQLDateTimeString(lastFetchDate,isDateTime:true)
        let query = "select id, Opportunity__c, Opportunity__r.Name, Account_Ids__c,Number_of_accounts__c,Reminder__C, Event_start__c,Event_Subject__c from Notification_info__c where user__c = '"+userId+"' and Event_start__c > "+fetchTime+"";
        getData(query)
    }
    
    func getNotifyMeSetting(){
        let query = "select id,Event_Notification_Timeframe__c from refedge__Custom_Settings__c ";
        getData(query)
    }
    /*
    *
    * Calling Force.com api
    *
    */
    func getData(query :String){
        //NSLog("Query : \(query)", self)
        let api = SFRestAPI.sharedInstance()
        let restRequest = api.requestForQuery(query)
        api.sendRESTRequest(restRequest, failBlock: {
            (NSError error) -> Void in
            NSLog("request:didFailLoadWithError: \(error)",self)

            if let watchInfo = self.watchInfo {
                let stuff = ["results" : error]
                watchInfo.response(stuff)
            }
            SFAuthenticationManager.sharedManager().logout();
            }, completeBlock: {
                (AnyObject dataResponse) -> Void in
                //parse the JSON data response
                if let records = dataResponse.objectForKey("records") as? NSArray {
                    //NSLog("Size: \(records.count) Data :  \(records)")
                    
                    if (self.watchInfo?.isIOSApp == true){
                        let stuff = ["results" : records]
                        self.watchInfo!.response(stuff)
                    }else{
                        if let watchInfo = self.watchInfo {
                            let stuff = ["results" : records]
                            watchInfo.response(stuff)
                        }
                    }
                }
        })
    }
    /*
    * This function is use by watchkit to save notificaion to NSDefault
    * @param notification{userInfo}
    * @param uuid
    */
    func saveNotification(notification:NSDictionary,title :NSString,uuid:String){
        let message = title
        let notificationHandler: ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
        let info = NotificationInfo(deadline: NSDate(),notificationData: notification,UUID: uuid,title:message as String)
        notificationHandler.addNotificaionInLocal(info)
        let notifications = notificationHandler.allItems()
        var response = [[:]]
        response.removeAtIndex(0)
        for notificationinfo in notifications{
            response.append(["message":notificationinfo.title,"notificationData":notificationinfo.notificationData,"uuid":notificationinfo.UUID])
        }
        if let watchInfo = self.watchInfo {
            let stuff = ["results" : response]
            watchInfo.response(stuff)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("refreshNotificationTable", object: nil , userInfo : nil)
    }
    /*
    * This function is use by watchkit to delate all notificaion from NSDefault
    */
    func deleteAll(){
        let notificationHandler: ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
        notificationHandler.deleteNotificationFromLocal()
        if let watchInfo = self.watchInfo {
            let stuff = ["results" : []]
            watchInfo.response(stuff)
        }
        NSNotificationCenter.defaultCenter().postNotificationName("refreshNotificationTable", object: nil , userInfo : nil)
    }
    /*
    * This function is use by watchkit to get all notificaion from NSDefault
    */
    func getAll(){
        let notificationHandler: ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
        let notifications = notificationHandler.allItems()
        var response = [[:]]
        response.removeAtIndex(0)
        for notificationinfo in notifications{
            response.append(["message":notificationinfo.title,"notificationData":notificationinfo.notificationData,"uuid":notificationinfo.UUID])
        }
        if let watchInfo = self.watchInfo {
            let stuff = ["results" : response]
            watchInfo.response(stuff)
        }
    }
    /*
    * This function is use to load all notification object from salesforce.
    * @param userId
    * @return void
    */
    func loadNotificationInLocal(userId:String){
        //NSLog("loadNotificationInLocal Starts",self)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let setting = userDefaults.objectForKey("notificaionSetting") as! Bool
        var notificationIds = userDefaults.objectForKey("notificationsIds") as? NSMutableArray
        let notificationHandler: ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
        //checking if notification is enable or not
        if(setting){
            self.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    //NSLog("load notificatio in local response \(parentValues)", self)
                    let arr : NSArray = parentValues["results"]! as! NSArray
                    var Reminder__c :String = ""
                    
                    for notificationInfo in arr{
                        let id :String = (notificationInfo["Id"] as? String)!
                        let Event_Start__c : String = (notificationInfo["Event_Start__c"] as? String)!
                        // If reminder is null
                        if let reminder = notificationInfo["Reminder__c"] as? String{
                            Reminder__c = reminder
                        }else{
                            Reminder__c = Event_Start__c
                        }
                        if let ids = notificationIds{
                            if(ids.count  == 24){
                                notificationIds!.removeAllObjects()
                            }
                            if(!ids.containsObject(id)){
                                self.scheduleMe(notificationInfo as! NSDictionary,notificationHandler: notificationHandler)
                                //var index = notificationIds!.count
                                //notificationIds!.addObject(id)
                                let mutable = notificationIds?.mutableCopy() as? NSMutableArray
                                mutable!.addObject(id)
                                userDefaults.setObject(mutable, forKey:"notificationsIds")
                                userDefaults.synchronize()
                            }else{
                                // cancel last notification if reminder time is changed and re-schedule notification
                                let app = UIApplication.sharedApplication()
                                for localNotification in app.scheduledLocalNotifications!
                                {
                                    let notify :UILocalNotification = localNotification
                                    if let userInfo = notify.userInfo as [NSObject:AnyObject]? {
                                        
                                        let notificationId = userInfo["id"] as! String
                                        if (id == notificationId) {
                                            let fireTime = notify.fireDate
                                            let dateFormatter = NSDateFormatter()
                                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
                                            let date : NSDate = dateFormatter.dateFromString(Reminder__c)!
                                            // Checking if date is modified
                                            if date.compare(fireTime!) == NSComparisonResult.OrderedDescending
                                            {
                                                //NSLog("Re Schedule Notification.. for \(userInfo) ..", self)
                                                app.cancelLocalNotification(localNotification)
                                                self.scheduleMe(notificationInfo as! NSDictionary,notificationHandler: notificationHandler)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }else{
                            notificationIds = NSMutableArray()
                            notificationIds!.addObject(id)
                            userDefaults.setObject(notificationIds, forKey:"notificationsIds")
                            userDefaults.synchronize()
                            self.scheduleMe(notificationInfo as! NSDictionary,notificationHandler: notificationHandler)
                        }
                        
                    }
                }
            })
            self.watchInfo?.isIOSApp = true
            self.getRefNotificaionEvents(userId)
        }
    }
    /*
    * This function is use to schedule a new local notification
    * @param notificationInfo {notificationInfo is object contains data related to notification like userInfo,fireTime,uuid,title}
    *
    */
    private func scheduleMe(notificationInfo : NSDictionary,notificationHandler: ReferenceLocalNotificaionHandler){
        /*
        * Extracting data and creating aps object for notification
        */
        var Reminder__c :String = ""
        var Account_Ids__c : String = (notificationInfo["Account_Ids__c"] as? String)!
        Account_Ids__c = Account_Ids__c.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        //let Number_of_accounts__c : Int = (notificationInfo["Number_of_accounts__c"] as? Int)!
        let Opportunity__c : String = (notificationInfo["Opportunity__c"] as? String)!
        let opp : NSDictionary = (notificationInfo["Opportunity__r"] as? NSDictionary)!
        let Opportunity__Name : String = (opp["Name"] as? String)!
        let Event_Start__c : String = (notificationInfo["Event_Start__c"] as? String)!
        // If reminder is null
        if let reminder = notificationInfo["Reminder__c"] as? String{
            Reminder__c = reminder
        }else{
            Reminder__c = Event_Start__c
        }
        var apnsData = [String:String]()
        apnsData ["alert"] = notificationInfo["Event_Subject__c"] as? String
        apnsData ["sound"] = "Default"
        var apns = [NSObject:AnyObject]();
        apns["aps"] = apnsData
        apns["id"] = (notificationInfo["Id"] as? String)!
        apns["oppId"] = Opportunity__c
        apns["oppName"] = Opportunity__Name
        apns["accountIds"] = Account_Ids__c
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        let date : NSDate = dateFormatter.dateFromString(Reminder__c)!
        let updateDate = date.addHours(-Int(nottifyMeSetting)!)
        //NSLog(" date \(date) notified date\(updateDate) notify hours\(nottifyMeSetting)", self)
        //adding last fetch time will be use to background data
        let placesData = NSKeyedArchiver.archivedDataWithRootObject(NSDate())
        NSUserDefaults.standardUserDefaults().setObject(placesData, forKey: "LAST_FETCH_TIME")
        let info = NotificationInfo(deadline: updateDate,notificationData: apns,UUID: (notificationInfo["Id"] as? String)!,title:(notificationInfo["Event_Subject__c"] as? String)!)
        notificationHandler.saveEvents(info)
        //triggeting local notificaion
        notificationHandler.triggerLocalNotificaion(updateDate, notiticatioData: apns)
        
    }
    /**
     * This func is use to get setting that tells is notification is enable or not for user.
     * @param userId
     *
     */
    func fetchSettings(userId: String){
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let _ = userDefaults.objectForKey("notificaionSetting") as? Bool{
            
        }else{
            userDefaults.setObject(true, forKey: "notificaionSetting")
            watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                    let arr : NSArray = parentValues["results"]! as! NSArray
                    let user = arr[0] as! NSDictionary
                    if let _ = userDefaults.objectForKey("notificaionSetting") as? Bool{
                        if let isEnable = user[Constants.NotificationKey.refedgeNotificaionRequest] as? Bool{
                            //NSLog("Setting \(isEnable)", self)
                            userDefaults.setObject(isEnable, forKey: "notificaionSetting")
                            userDefaults.synchronize()
                        }
                    }
                }
            })
            watchInfo?.isIOSApp = true
            getNotificaionSetting(userId)
        }
        
    }
    /*
    *
    * Delete notification info object from NSdefault used by watchkit
    * @param uuid{notification info object id}
    * @return void
    */
    func deletNotification(uuid:String){
        let notificationHandler: ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
        notificationHandler.removeNotification(uuid)
        NSNotificationCenter.defaultCenter().postNotificationName("refreshNotificationTable", object: nil , userInfo : nil)
    }
    /*
    *
    * Snooze notification means schedule a new notification on a new time
    * @param firetime
    * @param notiticatioData {userInfo for notificat@available(iOS 8.0, *)
    ion}
    * @param uuid{this is use to remove notification onject from nsdefault}
    * @return void
    */
    func snooze(fireTime : NSDate!, notiticatioData : NSDictionary!,uuid:String){
        let notificationHandler: ReferenceLocalNotificaionHandler = ReferenceLocalNotificaionHandler()
        notificationHandler.removeNotification(uuid)
        notificationHandler.triggerLocalNotificaion(fireTime, notiticatioData: notiticatioData)
        NSNotificationCenter.defaultCenter().postNotificationName("refreshNotificationTable", object: nil , userInfo : nil)
    }
    
    func checkIsAppOnline(){
        /*var appDeligate : AppDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
        let allAccounts = SFUserAccountManager.sharedInstance().allUserAccounts as! [SFUserAccount]?
        var uid = SFUserAccountManager.sharedInstance().currentUser.credentials.userId
        var fullName = SFUserAccountManager.sharedInstance().currentUser.fullName*/
    }
    // Check if internet is available or not
    func checkInternetConnection(){
        var Status:Bool = false
        let url = NSURL(string: "https://login.salesforce.com")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData
        request.timeoutInterval = 10.0
        let task1 = NSURLSession.sharedSession().dataTaskWithURL(url!) {
            (data, response, error) in
            //NSLog("resp : \(response)", self)
            if let httpResponse = response as? NSHTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    Status = true
                    //NSLog("Status  : \(Status)",self)
                    if let watchInfo = self.watchInfo {
                        let stuff = ["results" : Status]
                        watchInfo.response(stuff)
                    }
                }
            }else{
                if let watchInfo = self.watchInfo {
                    Status = false
                    let stuff = ["results" : Status]
                    watchInfo.response(stuff)
                }
            }
        }
        task1.resume()
        
        RemoteCenter.post("5Aep861_rWM1iAJC.hWh8xuCT9HOM0UVLkTQCs84h7o2khOllRWuEKYyvpg9._i2_Pa_p8Hlc1EltMdgivzHYjY",completion: completionHandler)
    }
    func completionHandler(message: NSData?){
        let anyObj: NSDictionary?
        do {
            anyObj = try NSJSONSerialization.JSONObjectWithData(message!, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
        } catch is ErrorType {
            anyObj = nil
        }
        
        print("I got \(anyObj!["access_token"])")
    }
    func loadNotifyMeSetting(userId:String){
        self.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                let arr : NSArray = parentValues["results"]! as! NSArray
                let timeFrameData = arr[0] as! NSDictionary
                self.nottifyMeSetting = timeFrameData["Event_Notification_Timeframe__c"] as! String
                self.loadNotificationInLocal(userId)
            }
        })
        self.getNotifyMeSetting()
    }
    
    /*func validateSession(id:String, callback: (Bool) -> ()) {
        self.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                NSLog("\(parentValues)", self)
                var status  :Bool = false
                if let arr : NSError = parentValues["results"]! as? NSError{
                    NSLog("error code = \(arr.code)", self)
                    status = true
                }
                callback(status)
            }
        })
        self.getReferences()
    }*/
}

struct RemoteCenter {
    static func post(refreshToken :String,completion: (message: NSData?) -> Void) {
        let url = Constants.NotificationKey.host+Constants.NotificationKey.path+"client_id="+Constants.NotificationKey.client_id+"&client_secret="+Constants.NotificationKey.client_secret+"&grant_type=refresh_token&refresh_token="+refreshToken
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        //let postString = "data=xxxxxxx"
        //request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            completion(message: data)
        }
        task.resume()
    }
    
    
}