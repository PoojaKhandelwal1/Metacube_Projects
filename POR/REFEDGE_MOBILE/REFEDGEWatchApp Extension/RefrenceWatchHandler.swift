//
//  RefrenceWatchHandler.swift
//  REFEDGE
//
//  Created by Narender Singh on 23/10/15.
//  Copyright © 2015 Point of Reference Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity

class RefrenceWatchHandler: NSObject,WCSessionDelegate {
    
    var refWatchInfo: RefrenceWatchInfo?
    private let session : WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    private var sendMessage :[String : AnyObject]!
    /*
    * Life cycle method when app initilize
    */
    override init() {
        super.init()
        session?.delegate = self
        session?.activateSession()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        NSLog("ReferenceWatchHandler didReceiveMessage watch \(message)", self)
        /*dispatch_async(dispatch_get_main_queue()) {
            self.refWatchInfo?.response(message)
        }*/
    }
    
    func sendMessage(message: [String : AnyObject]){
        NSLog("ReferenceWatchHandler sendMessage watchapp \(message)", self)
        sendMessage = message
        if let session = session where session.reachable {
            session.sendMessage(message,
                replyHandler: { replyData in
                    // handle reply from iPhone app here
                    //print("Reply :\(replyData)")
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refWatchInfo?.response(replyData)
                    }
                    
                }, errorHandler: { error in
                    // catch any errors here
                    if (error.code == 7014 || error.code == 7007){
                        self.sendMessage(self.sendMessage)
                    }
                    print("Error :\(error)")
            })
        } else {
            NSLog("session.reachable error", self)
            // when the iPhone is not connected via Bluetooth
        }
    }
}
