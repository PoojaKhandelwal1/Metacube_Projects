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
        static let refedgeNotificaionRequest :String = "Refedge_Notification__c"
        static let settingPageTitle: String = "Setting"
        static let notificationCategory :String = "referenceNotification"
        static let notificationLoadingMessage = ""//"Loading...."
        static let lastFetchTime = "LAST_FETCH_TIME"
        static let APP_GROUP_ID = "com.pointofreference.SalesforceWatchApp_notificaion"
        static let error = "Error"
        static let success = "Success"
        static let client_secret = "7448579479540523819"
        static let client_id = "3MVG9sG9Z3Q1RlbdjdipI7.mQaoLMU4gnI5Zvfe9_h_mbDCwBfDRQtLyHL.YBSDxgn3nRG.qfR63VqE9IxmTf"
        static let path = "/services/oauth2/token?"
        static let host = "https://login.salesforce.com"
    }
    struct Label {
        static let summary :String = "Summary"
        //static let summaryDetail :String = "This section of reference details provides Summary."
        static let keyPoints :String = "Key Points"
        static let attribute :String = "Attributes"
        //static let keyPointsDetail :String = "This section of reference details provides key talking points."
        //static let attributeDetail :String = "This section of reference details list of Account Attributes."
        static let noInternetConnection :String = "The Internet connection appears to be offline."
        static let noNotification : String  = "You have no notifications."
        static let noAccountMessage :String = "No accounts found."
        static let noOpportunityMessage :String = "No opportunity found."
        static let noSummaryMessage :String = "No Summmary found."
        static let noKeyPointsMessage :String = "No Key Points found."
        static let noAttributeMessage :String = "No Attribute found."
        static let welcomeMessage :String = "Welcome : %@"
        static let addEventUserLabel :String  = "User : %@"
        static let addEventOppLabel :String  = "Opportunity : %@"
        static let referenceMessage :String = "reference accounts match your %@ opportunity"
        static let notificationSettingLabel :String = "Allow Notifications"
        static let notiticationSnoozeLabel :String = "Snooze Notification"
        static let notiticationButtonSnoozeLabel :String = "Snooze"
        static let notifyMeTimeFrame = "Notify Me Time Frame"
        static let notifyMeTimeFrameButton = "Notify Me"
        static let addEvent = "Add Event"
        static let addEventButtonLabel = "Add"
        static let opportunities = "Opportunities"
        static let dismissButtonLabel = "Dismiss"
    }
}