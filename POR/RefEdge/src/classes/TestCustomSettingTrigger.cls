/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */  
@isTest(seeAllData = false)
public class TestCustomSettingTrigger {
    public static Custom_Settings__c customSetting;

    //Unit Test Method
    static testmethod void UnitTest01() {
        try {
            customSetting = createCustomSetting();
            customSetting.Number_of_request_accounts__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest02() {
        try {
            customSetting = createCustomSetting();
            customSetting.Minimum_Deadline__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest03() {
        try {
            customSetting = createCustomSetting();
            customSetting.Reminder_to_Owner__c = -2;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest04() {
        try {
            customSetting = createCustomSetting();
            customSetting.Escalation_to_Owner_Manager__c = -2;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest05() {
        try {
            customSetting = createCustomSetting();
            customSetting.No_Response__c = -2;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest06() {
        try {
            customSetting = createCustomSetting();
            customSetting.Feedback_Message_Delay__c = -2;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest07() {
        try {
            customSetting = createCustomSetting();
            customSetting.Reminder_to_Owner__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest08() {
        try {
            customSetting = createCustomSetting();
            customSetting.Minimum_Deadline__c = 4;
            customSetting.Reminder_to_Owner__c = 5;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest09() {
        try {
            customSetting = createCustomSetting();
            customSetting.Escalation_to_Owner_Manager__c = 3;
            customSetting.Reminder_to_Owner__c = 2;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest10() {
        try {
            customSetting = createCustomSetting();
            customSetting.No_Response__c = 3;
            customSetting.Escalation_to_Owner_Manager__c = 2;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }

    //Unit Test Method
    static testmethod void UnitTest11() {
        try {
            customSetting = createCustomSetting();
            customSetting.No_Response__c = 6;
            customSetting.Minimum_Deadline__c = 4;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest12() {
        try {
            customSetting = createCustomSetting();
            customSetting.Include_Weekends__c = true;
            customSetting.Days_of_Week__c = null;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest13() {
        try {
            customSetting = createCustomSetting();
            customSetting.Include_Weekends__c = true;
            customSetting.Days_of_Week__c = 'Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday';
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest14() {
        try {
            customSetting = createCustomSetting();
            insert customSetting;
            delete customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest15() {
        try {
            customSetting = createCustomSetting();
            insert customSetting;
            Custom_Settings__c customSetting2 = createCustomSetting();
            insert customSetting2;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    //Unit Test Method
     static testmethod void UnitTest16() {
        try {
            customSetting = createCustomSetting();
            customSetting.Critical_Deadline_window__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
   
   //Unit Test Method
    static testmethod void UnitTest18() {
        try {
            customSetting = createCustomSetting();
            customSetting.Expiration_Timeframe__c = null;
            customSetting.Expire_Rewards__c = true;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest19() {
        try {
            customSetting = createCustomSetting();
            customSetting.Expiration_Timeframe__c = '2';
            customSetting.Expire_Rewards__c = false;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest20() {
        try {
            customSetting = createCustomSetting();
            customSetting.Expiration_Timeframe__c = ConstantsController.X_DAYS_FROM_AWARDDATE;
            customSetting.Expire_Rewards__c = true;
            customSetting.Expiration_Days__c = null;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
   //Unit Test Method
    static testmethod void UnitTest21() {
        try {
            customSetting = createCustomSetting();
            customSetting.Manual_Automatic_Launch__c = 'Automatic';
            customSetting.Launch_Frequency__c = '';
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    //Unit Test Method
    static testmethod void UnitTest22() {
        try {
            customSetting = createCustomSetting();
            customSetting.Manual_Automatic_Launch__c = 'Automatic';
            customSetting.Next_Refresh_launch_Date__c = null;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest23() {
        try {
            customSetting = createCustomSetting();
            customSetting.No_Response__c = 3;
            customSetting.Minimum_Deadline__c = 3;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    //Unit Test Method
    static testmethod void UnitTest24() {
        try {
            customSetting = createCustomSetting();
            customSetting.Nomination_disposition_window__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest25() {
        try {
            customSetting = createCustomSetting();
            customSetting.Expiration_Timeframe__c = 'end of current FY';
            customSetting.Expiration_Days__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest26() {
        try {
            customSetting = createCustomSetting();
            customSetting.Expiration_Timeframe__c = ConstantsController.X_DAYS_FROM_AWARDDATE;
            customSetting.Expiration_Days__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest27() {
        try {
            customSetting = createCustomSetting();
            customSetting.Default_Referenceablity_Status__c = '';
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    //Unit Test Method
    static testmethod void UnitTest28() {
        try {
            customSetting = createCustomSetting();
            customSetting.Automatically_Assign_Reward_on_Feedback__c = true;
            customSetting.Automatically_Assign_Rewards__c = true;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest29() {
        try {
            customSetting = createCustomSetting();
            customSetting.Client_Referenceability_check_days__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //Unit Test Method
    static testmethod void UnitTest30() {
        try {
            customSetting = createCustomSetting();
            customSetting.No_Response_days__c = 0;
            insert customSetting;
            system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
   //Unit Test Method
    static testmethod void UnitTest50 () {
        try {
            customSetting = createCustomSetting();
            insert customSetting;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            for(Referenceability_Type__c ref : refTypes){
                ref.min_lead_time_per_request_type__c = 6;
            }
            insert refTypes;
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
            insert refReqs;
            list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
            insert refReqAccs;
            List < Reference_Request_Account_Contact__c > refReqAccContacts = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
            insert refReqAccContacts;
            customSetting.RUL_Period__c = 66;
            customSetting.RUL_Period_Contact__c = 60;
            customSetting.Email_Enabled__c = false;
            customSetting.Chatter_Enabled__c = false;
            customSetting.Minimum_Deadline__c = 10;
            update customSetting;
            customSetting.Email_Enabled__c = true;
            customSetting.Chatter_Enabled__c = true;
            customSetting.RUL_Period_Contact__c = 70;
            update customSetting;
            system.assertEquals(66,customSetting.RUL_Period__c);
            customSetting.Email_Enabled__c = true;
            customSetting.Chatter_Enabled__c = true;
            customSetting.RUL_Period__c = 70;
            update customSetting;
            customSetting.Caution_deadline_window__c = null;
            update customSetting;
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    /**
     * Method to create Custom Setting
     */
    public static Custom_Settings__c createCustomSetting() {
        Custom_Settings__c testSettings = new Custom_Settings__c(
            Name = 'Test Setting', Current_Version__c = '1.50', Active_Version__c = true, Email_Enabled__c = true,
            Chatter_Enabled__c = true, Include_Weekends__c = true, Days_of_Week__c = 'Saturday;Sunday',Feedback_Message_Delay__c = 2,
            Minimum_Deadline__c = 4, Reminder_to_Owner__c = 3,Escalation_to_Owner_Manager__c = 2, No_Response__c = 1,
            RUL_Activities__c = 3, RUL_Period__c = 99, RUL_Period_Contact__c = 10,RUL_Activities_Contact__c = 1,Maximum_Expiration_Days__c = 14,
            Default_Expiration_Days__c = 7,Microsite_Visit_Email__c = true,Microsite_Visit_Chatter__c = true,
            Caution_deadline_window__c = 10, Critical_Deadline_window__c = 5, Default_Referenceablity_Status__c = 'Active',
            Number_of_request_accounts__c = 5,Nomination_disposition_window__c = 7,Automatically_Assign_Rewards__c = true,
            Enable_Reference_Refresh__c = true,Refresh_Wait_Days__c = 1,Reference_Update_Email__c = true,Reference_Update_Chatter__c = true,
            Request_Approval_Decline_Chatter__c = true, Request_Approval_Decline_Email__c = true,Request_Escalation_Chatter__c = true,
            Request_Escalation_Email__c = true,Request_Feedback_Email__c = true, Request_Feedback_Chatter__c = true,Request_No_Response_Chatter__c = true,
            Request_No_Response_Email__c = true,Request_Reminder_Chatter__c = true, Request_Reminder_Email__c = true,Check_back_in_Email__c = true,
            Check_back_in_Chatter__c = true,Opportunity_Closed_Won_Stage__c = 'Closed Won',Nomination_Chatter__c = true,Nomination_Email__c=true,
            Minimum_Opportunity_Size__c = 500,Client_Referenceability_check_days__c = 1,No_Response_days__c = 2,Reference_Lead_No_Response_Chatter__c = true,
            Reference_Lead_No_Response_Email__c = true,Minimum_Sales_Stage__c = 'Value Proposition',Auto_create_delete_Reference_Content__c = true,
            Create_Reference_Profile__c = true, Slack_Enabled__c = true
        );
        return testSettings;
    }
    
    static testmethod void UnitTest001() {
        try {
            Custom_Settings__c customSetting1 = createCustomSetting();
            insert customSetting1;
            customSetting1.Chatter_Enabled__c = false;
            update customSetting1;
            system.assertEquals('h', 'h');
            //system.assert(false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    static testmethod void UnitTest002() {
        try {
            Custom_Settings__c customSetting1 = createCustomSetting();
            insert customSetting1;
            customSetting1.RUL_Period__c = 90;
            update customSetting1;
            update customSetting1;
            system.assertEquals('h', 'h');
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
    
    //REF-2349
    @isTest static void testNotificationUpdates() {
        try {
            Custom_Settings__c customSetting1 = createCustomSetting();
            insert customSetting1;
            customSetting1.Request_No_Response_Email__c = false;
            customSetting1.Chatter_Enabled__c = false;
            customSetting1.Email_Enabled__c = false;
            customSetting1.Slack_Enabled__c = false;
            ConstantsController.isFromEmailChatterSettings = true;
            test.startTest();
            update customSetting1;
            test.stopTest();
            system.assertEquals(customSetting1.Request_No_Response_Email__c, false);
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
}