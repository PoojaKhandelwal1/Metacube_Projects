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
public class TestBatch_ReferenceRequestFeedback {

    //Unit Test 01 Include Weekends = false
    static testmethod void myUnitTest01() {
        createDataMappings();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Include_Weekends__c = false;
        update customSetting;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        list<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        for(Reference_Request__c rr : refReqs){
            rr.Opportunity__c = opps[index].Id;
            index++;
            if(index >= opps.size())
                index = 0;
        }
        insert refReqs;
        list<Task> tasks = TestDataFactory.createTask();
        insert tasks;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Task_ID__c = tasks[0].Id;
            rra.Deadline__c = Date.today();
            rra.Account_Request_Status__c = 'Completed';
        }
        refReqAccs[0].Approve_Deny_Notes__c = 'approved';
        refReqAccs[0].Approval_Status__c = 'Approved';
        refReqAccs[1].Approve_Deny_Notes__c = 'Declined';
        refReqAccs[1].Approval_Status__c = 'Declined';
        insert refReqAccs;
        test.startTest();
            //update Reference_Request_Account
            refReqAccs[0].Deadline__c = system.today() - 2;
            update refReqAccs[0];
            //insert Reference_Request_Account contact
            List < Reference_Request_Account_Contact__c > refReqAccContacts = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
            insert refReqAccContacts;
            Batch_ReferenceRequestFeedback batchrrf = new Batch_ReferenceRequestFeedback();
            ID batchprocessid = database.executebatch(batchrrf);
        test.stopTest();
        List < Reference_Request_Account_Contact__c > testList = [select id, Is_Feedback_Notification_Send__c from Reference_Request_Account_Contact__c];
        system.assertEquals(testList[0].Is_Feedback_Notification_Send__c, true);
    }

    //Unit Test 02 Include Weekends = true
    static testmethod void myUnitTest02() {
        createDataMappings();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        update customSetting;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        list<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        for(Reference_Request__c rr : refReqs){
            rr.Opportunity__c = opps[index].Id;
            index++;
            if(index >= opps.size())
                index = 0;
        }
        insert refReqs;
        list<Task> tasks = TestDataFactory.createTask();
        insert tasks;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Task_ID__c = tasks[0].Id;
            rra.Deadline__c = Date.today();
            rra.Account_Request_Status__c = 'Completed';
        }
        refReqAccs[0].Approve_Deny_Notes__c = 'approved';
        refReqAccs[0].Approval_Status__c = 'Approved';
        refReqAccs[1].Approve_Deny_Notes__c = 'Declined';
        refReqAccs[1].Approval_Status__c = 'Declined';
        insert refReqAccs;
        test.startTest();
            //update Reference_Request_Account
            refReqAccs[0].Deadline__c = system.today() - 2;
            update refReqAccs[0];
            //insert Reference_Request_Account contact
            List < Reference_Request_Account_Contact__c > refReqAccContacts = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
            insert refReqAccContacts;
            Batch_ReferenceRequestFeedback batchrrf = new Batch_ReferenceRequestFeedback();
            ID batchprocessid = database.executebatch(batchrrf);
        test.stopTest();
        List < Reference_Request_Account_Contact__c > testList = [select id, Is_Feedback_Notification_Send__c from Reference_Request_Account_Contact__c];
        system.assert(testList.size() > 0);
    }

    //Unit Test 03 Catch Section
    static testmethod void myUnitTest03() {
        createDataMappings();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        update customSetting;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        list<Reference_Request__c> refReqs = TestDataFactory.createMoreReferenceRequest();
        integer index = 0;
        for(Reference_Request__c rr : refReqs){
            rr.Opportunity__c = opps[index].Id;
            index++;
            if(index >= opps.size())
                index = 0;
        }
        insert refReqs;
        list<Task> tasks = TestDataFactory.createTask();
        insert tasks;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Task_ID__c = tasks[0].Id;
            rra.Deadline__c = Date.today();
            rra.Account_Request_Status__c = 'Completed';
        }
        refReqAccs[0].Approve_Deny_Notes__c = 'approved';
        refReqAccs[0].Approval_Status__c = 'Approved';
        refReqAccs[1].Approve_Deny_Notes__c = 'Declined';
        refReqAccs[1].Approval_Status__c = 'Declined';
        insert refReqAccs;
        test.startTest();
            //update Reference_Request_Account
            refReqAccs[0].Deadline__c = null;
            update refReqAccs[0];
            //insert Reference_Request_Account contact
            List < Reference_Request_Account_Contact__c > refReqAccContacts = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
            insert refReqAccContacts;
            Batch_ReferenceRequestFeedback batchrrf = new Batch_ReferenceRequestFeedback();
            ID batchprocessid = database.executebatch(batchrrf);
        test.stopTest();
        List < Reference_Request_Account_Contact__c > testList = [select id, Is_Feedback_Notification_Send__c from Reference_Request_Account_Contact__c];
        system.assertEquals(testList[0].Is_Feedback_Notification_Send__c, false);
        system.assertEquals(testList[1].Is_Feedback_Notification_Send__c, false);
    }
    
    private static void createDataMappings() {
        List<Data_Mapping__c> customNotificationsList = new List<Data_Mapping__c>();
        ConstantsController.shouldDataMappingProcessed = true;

        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Section_Name__c = 'email header doc',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Section_Name__c = 'email footer doc',
                                                        Visible__c = false));
        customNotificationsList.add(new Data_Mapping__c(Object__c = 'Notification',
                                                        Field_API_Name__c = UtilityController.appNamespace() + 'Request_Feedback_Email__c',
                                                        Label__c = UtilityController.appNamespace() + 'Request_Feedback_Chatter__c',
                                                        DC_Message__c = 'Could you please provide feedback on your recent reference use:',
                                                        Default__c = 'Opportunity Account: [Opportunity Account]\n'
                                                            + 'Reference Account: [Requested Account]\n'
                                                            + 'Use Requested: [Request Type]\n'
                                                            + 'Use Date: [Deadline]',
                                                        Section_Name__c = 'Provide Reference Use Feedback',
                                                        Visible__c = true));
        insert customNotificationsList;
    }
}