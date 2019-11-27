//
//  Constants.swift
//  SalesforceWatch
//
//  Created by Narender Singh on 02/09/15.
//  Copyright (c) 2015 Point Of reference Inc. All rights reserved.
//

struct Constants {
    struct NotificationKey {
        static let sampleId : String  = "sampleID"
        static let sampleReference : String  = "Sample Referenced Account"
        static let requestType :String = "request-type"
    }
    struct Label {
        //Reference Detail Page labels
        static let summary :String = "Summary"
        static let summaryDetail :String = "This section of reference details provides Summary."
        static let keyPoints :String = "Key Points"
        static let attribute :String = "Attributes"
        static let noSummaryMessage :String = "No Summmary found."
        static let noKeyPointsMessage :String = "No Key Points found."
        static let noAttributeMessage :String = "No Attribute found."
        static let keyPointsDetail :String = "This section of reference details provides key talking points."
        static let attributeDetail :String = "This section of reference details list of Account Attributes."
        //Notification Page labels
        static let noInternetConnection :String = "The Internet connection appears to be offline."
        static let noNotification : String  = "You have no notifications."
        static let noAccountMessage :String = "No accounts found."
        static let noOpportunityMessage :String = "No opportunity found."
        
        //static let welcomeMessage :String = "Welcome : %@"
        static let referenceMessage :String = "reference accounts match your %@ opportunity"

    }
    struct Button {
        static let snooze:String = "Snooze"
        static let dismiss:String = "Dismiss"
    }
}