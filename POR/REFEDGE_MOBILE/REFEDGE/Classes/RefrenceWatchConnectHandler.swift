//
//  RefrenceWatchConnectHandler.swift
//  REFEDGE
//
//  Created by Narender Singh on 13/11/15.
//  Copyright © 2015 Point of Reference Inc. All rights reserved.
//

import Foundation
import WatchConnectivity

class RefrenceWatchConnectHandler:NSObject,WCSessionDelegate{
    
    private let handler : ReferenceHandler = ReferenceHandler()
    var refWatchInfo : WatchInfo?
    private let session : WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    /*
    * Life cycle method when app initilize
    */
    override init() {
        super.init()
        session?.delegate = self
        session?.activateSession()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        dispatch_async(dispatch_get_main_queue()) {
            if let requestType = message[Constants.NotificationKey.requestType] as? String {
                NSLog("didReceiveMessage requestType \(requestType)", self)
                self.handler.watchInfo = WatchInfo(userInfo : ["IOS":"IOSAPP"] ,reply: { (parentValues) -> Void in
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                        self.handler.watchInfo?.isIOSApp = false
                        NSLog("didReceiveMessage :\(parentValues)", self)
                        if let arr : NSArray = parentValues["results"]! as? NSArray{
                            let applicationData = ["results" : arr,Constants.NotificationKey.requestType:requestType]
                            replyHandler(applicationData);
                            //self.sendMessage(applicationData)
                        }else{
                            NSLog("error : \(parentValues)", self)
                        }
                    }
                })
                self.handler.watchInfo?.isIOSApp = true
                if(requestType == "saveNotification"){
                    let notificationData = message["notification"] as? NSDictionary
                    let title = message["title"] as? String
                    let uuid = message["uuid"] as? String
                    self.handler.saveNotification(notificationData!, title: title!, uuid: uuid!)
                }else if(requestType == "deleteAllNotification"){
                    self.handler.deleteAll()
                }else if(requestType == "dismissNotification"){
                    let uuid = message["uuid"] as? String
                    self.handler.deletNotification(uuid!)
                    let applicationData = ["results" : "success",Constants.NotificationKey.requestType:requestType]
                    replyHandler(applicationData);
                }else if(requestType == "allNotification"){
                    self.handler.getAll()
                }else if(requestType == "snoozeNotification"){
                    let fireTime = message["snoozeTime"] as? NSDate
                    let notificationData = message["snoozeData"] as? NSDictionary
                    let uuid = message["uuid"] as? String
                    self.handler.snooze(fireTime!, notiticatioData: notificationData!, uuid: uuid!)
                    let applicationData = ["results" : "success",Constants.NotificationKey.requestType:requestType]
                    replyHandler(applicationData);
                }else if(requestType == "reference-Details"){
                    if let accountId = message["accountId"] as? String {
                        self.handler.getReferenceDetail(accountId)
                    }
                }
                else if(requestType == "accounts"){
                    if let accountIds = message["accountIds"] as? String {
                        self.handler.getAccounts(accountIds)
                    }
                }
            }
        }
    }
    
    private func sendMessage(message : [String:AnyObject]){
        //NSLog("Sending message to watch : \(message)", self)
        if((session) != nil){
            session!.sendMessage(message,
                replyHandler: { replyData in
                    NSLog("Data send : \(message)", self)
                }, errorHandler: { error in
                    NSLog("Data send error : \(error)")
            })
        }
        
    }
}