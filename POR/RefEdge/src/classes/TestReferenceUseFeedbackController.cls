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
public class TestReferenceUseFeedbackController {
    public static Custom_Settings__c customSetting;
    public static List < Referenceability_Type__c > refTypes;
    public static List < Account > accounts;
    public static List < Contact > contacts;
    public static List < Opportunity > opps;
    public static List < Reference_Request__c > refReqs;
    public static List < Task > tasks;
    public static List < Reference_Request_Account__c > refReqAccs;
    //Test Method
    static testMethod void changeFeedbakOptionsUnsuccessfulTest() {
        createData();
        //Start Test Method
        Test.startTest();
            PageReference pageRef = Page.SelectReferenceUseContacts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
            String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[3].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
            Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
            rrac.Feedback_Status__c = ConstantsController.FEEDBACK_UNSUCCESSFUL;
            rrac.Task_ID__c = tasks[0].Id;
            update rrac;
            pageRef = Page.ReferenceUseFeedback;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', rrac.Id);
            ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
            RUFObj.changeFeedbakOptions();
            system.assertEquals(RUFObj.diplayUnsuccessfulPanel, true);
            system.assertEquals(RUFObj.diplayNotcompletedPanel, false);
        //Stop Test Method
        test.stopTest();
    }
    
    //Test Method
    static testMethod void changeFeedbakOptionsnotcompletedTest() {
        createData();
        //Start Test Method
        Test.startTest();
            PageReference pageRef = Page.SelectReferenceUseContacts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
            String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[3].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
            Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
            rrac.Feedback_Status__c = ConstantsController.FEEDBACK_YET_NOT_COMPLETED;
            rrac.Task_ID__c = tasks[0].Id;
            update rrac;
            pageRef = Page.ReferenceUseFeedback;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', rrac.Id);
            ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
            RUFObj.changeFeedbakOptions();
            system.assertEquals(RUFObj.diplayUnsuccessfulPanel, false);
            system.assertEquals(RUFObj.diplayNotcompletedPanel, true);
        //Stop Test Method
        test.stopTest();
    }
    
    //Test Method
    static testMethod void changeFeedbakOptionSuccessfulTest() {
        createData();
        //Start Test Method
        Test.startTest();
            Contact con = [select Id,AccountId from Contact where AccountId = :refReqAccs[0].Account__c];
            PageReference pageRef = Page.SelectReferenceUseContacts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', refReqAccs[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[0]);
            String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
            Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c, Task_ID__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[0].Id];
            rrac.Feedback_Status__c = ConstantsController.FEEDBACK_SUCCESSFUL;
            rrac.Task_ID__c = tasks[0].Id;
            update rrac;
            pageRef = Page.ReferenceUseFeedback;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', rrac.Id);
            ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
            RUFObj.changeFeedbakOptions();
            system.assertEquals(RUFObj.diplayUnsuccessfulPanel, false);
            system.assertEquals(RUFObj.diplayNotcompletedPanel, false);
        //Stop Test Method
        Test.stopTest();
    }

    // feedbakResponse is null for unsuccessfull
    static testMethod void sendUpdateForUnsuccessfulTest() {
        createData();
        //Start Test Method
        Test.startTest();
            try{
                PageReference pageRef = Page.SelectReferenceUseContacts;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
                ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
                String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
                Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c, Task_ID__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
                rrac.Feedback_Status__c = ConstantsController.FEEDBACK_UNSUCCESSFUL;
                rrac.Task_ID__c = tasks[0].Id;
                update rrac;
                pageRef = Page.ReferenceUseFeedback;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', rrac.Id);
                ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
                RUFObj.changeFeedbakOptions();
                Pagereference pgRef1 = RUFObj.sendUpdate();
                system.assertEquals(pgRef1, null);
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assert(msgs != null);
            }
        //Stop Test Method
        test.stopTest();
    }

    // feedbakResponse is not null for unsuccessfull
    static testMethod void sendUpdateForUnsuccessfulWithFeedbakTest() {
        createData();
        //Start Test Method
        Test.startTest();
            try{
                PageReference pageRef = Page.SelectReferenceUseContacts;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
                ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
                String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
                Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c, Task_ID__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
                rrac.Feedback_Status__c = ConstantsController.FEEDBACK_UNSUCCESSFUL;
                rrac.Task_ID__c = tasks[0].Id;
                update rrac;
                pageRef = Page.ReferenceUseFeedback;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', rrac.Id);
                ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
                RUFObj.changeFeedbakOptions();
                RUFObj.feedbakResponse = 'this was unsuccessful';
                Pagereference pgRef1 = RUFObj.sendUpdate();
                system.assertEquals(pgRef1.getUrl(), '/home/home.jsp');
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assertEquals(msgs.size(), 0);
            }
        //Stop Test Method
        Test.stopTest();
    }

    // Chatter Disabled
    static testMethod void sendUpdateForChatterDisabledTest() {
        createData();
        //Start Test Method
        Test.startTest();
            try{
                PageReference pageRef = Page.SelectReferenceUseContacts;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
                ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
                String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
                Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c, Task_ID__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
                rrac.Feedback_Status__c = ConstantsController.FEEDBACK_UNSUCCESSFUL;
                rrac.Task_ID__c = tasks[0].Id;
                update rrac;
                pageRef = Page.ReferenceUseFeedback;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', rrac.Id);
                ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
                RUFObj.changeFeedbakOptions();
                RUFObj.feedbakResponse = 'this was unsuccessful';
                Pagereference pgRef1 = RUFObj.sendUpdate();
                system.assertEquals(pgRef1.getUrl(), '/home/home.jsp');
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assertEquals(msgs.size(), 0);
            }
        //Stop Test Method
        Test.stopTest();
    }

    // deadline is not null for not completed
    static testMethod void sendUpdateForNotCompletedTest() {
        createData();
        //Start Test Method
        Test.startTest();
            try{
                PageReference pageRef = Page.SelectReferenceUseContacts;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
                ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
                String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
                Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c, Task_ID__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
                rrac.Feedback_Status__c = ConstantsController.FEEDBACK_YET_NOT_COMPLETED;
                rrac.Task_ID__c = tasks[0].Id;
                update rrac;
                refReqAccs[3].Deadline__c = null;
                update refReqAccs[3];
                pageRef = Page.ReferenceUseFeedback;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', rrac.Id);
                ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
                RUFObj.changeFeedbakOptions();
                Pagereference pgref1 = RUFObj.sendUpdate();
                system.assertEquals(pgRef1, null);
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assertEquals(msgs.size(), 1);
                refReqAccs[3].Deadline__c = system.today().addDays(-5);
                update refReqAccs[3];
                RUFObj = new ReferenceUseFeedbackController();
                RUFObj.changeFeedbakOptions();
                pgref1 = RUFObj.sendUpdate();
                refReqAccs[3].Deadline__c = system.today();
                update refReqAccs[3];
                RUFObj = new ReferenceUseFeedbackController();
                pgref1 = RUFObj.sendUpdate();
                delete refReqAccs[3];
                pgref1 = RUFObj.sendUpdate();
            }catch(Exception e){}
        //Stop Test Method
        Test.stopTest();
        
    }

    // deadline is not null for not completed
    static testMethod void sendUpdateForNotCompletedWithFeedbakTest() {
        createData();
        //Start Test Method
        Test.startTest();
            try{
                PageReference pageRef = Page.SelectReferenceUseContacts;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
                ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
                String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
                Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c, Task_ID__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
                rrac.Feedback_Status__c = ConstantsController.FEEDBACK_YET_NOT_COMPLETED;
                rrac.Task_ID__c = tasks[0].Id;
                update rrac;
                pageRef = Page.ReferenceUseFeedback;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', rrac.Id);
                ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
                RUFObj.changeFeedbakOptions();
                RUFObj.refReqAccountContact.Reference_Request_Account__r.Deadline__c = null;
                Pagereference pgref1 = RUFObj.sendUpdate();
                system.assertEquals(pgRef1, null);
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assertEquals(msgs.size(), 1);
            }catch(Exception e){}
        //Stop Test Method
        Test.stopTest();
    }
    // is Feed back received is true and testing catch
    static testMethod void isFeedBackReceivedTrueTest() {
        createData();
        //Start Test Method
        Test.startTest();
            try{
                PageReference pageRef = Page.SelectReferenceUseContacts;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', refReqAccs[3].Id);
                ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[3]);
                String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, contacts[0].Id, true);
                Reference_Request_Account_Contact__c rrac = [select Id, Feedback_Status__c, Task_ID__c from Reference_Request_Account_Contact__c where Reference_Request_Account__c = : refReqAccs[3].Id];
                rrac.Feedback_Status__c = ConstantsController.FEEDBACK_YET_NOT_COMPLETED;
                rrac.Task_ID__c = tasks[0].Id;
                rrac.Is_Feedback_Received__c = true;
                update rrac;
                pageRef = Page.ReferenceUseFeedback;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('id', rrac.Id);
                ReferenceUseFeedbackController RUFObj = new ReferenceUseFeedbackController();
                RUFObj.changeFeedbakOptions();
                Database.delete(RUFObj.refReqAccountContact);
                Pagereference pgref1 = RUFObj.sendUpdate();
                system.assertEquals(pgRef1, null);
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assertEquals(msgs.size(), 1);
            }catch(Exception e){}
        //Stop Test Method
        Test.stopTest();
    }
    
    //Custom_Settings SetUp
    private static void createData() {
        customSetting = TestDataFactory.createCustomSetting();
        TestDataFactory.createCustomNotifications();
        refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        tasks = TestDataFactory.createTask();
        insert tasks;
        refReqs = new list<Reference_Request__c>{TestDataFactory.createReferenceRequest()[0]};
        refReqs[0].Opportunity__c = opps[0].Id;
        insert refReqs;
        refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Task_ID__c = tasks[0].Id;
            rra.Account_Request_Status__c = 'Completed';
        }
        refReqAccs[1].Approve_Deny_Notes__c = 'Approved';
        refReqAccs[1].Approval_Status__c = 'Approved';
        refReqAccs[2].Approve_Deny_Notes__c = 'Declined';
        refReqAccs[2].Approval_Status__c = 'Declined';
        insert refReqAccs;
    }
}