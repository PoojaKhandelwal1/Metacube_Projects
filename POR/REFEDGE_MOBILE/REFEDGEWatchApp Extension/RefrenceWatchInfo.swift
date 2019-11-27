//
//  RefrenceWatchInfo.swift
//  REFEDGE
//
//  Created by Tejpal Kumawat on 23/10/15.
//  Copyright © 2015 Point of Reference Inc. All rights reserved.
//

import WatchKit

class RefrenceWatchInfo: NSObject {

    let response: ([String : AnyObject]!) -> Void
    
    init(reply: ([String : AnyObject]!) -> Void) {
        response = reply
    }
}
