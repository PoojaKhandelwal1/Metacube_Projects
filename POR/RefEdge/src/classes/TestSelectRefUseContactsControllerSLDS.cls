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
public with sharing class TestSelectRefUseContactsControllerSLDS {
    /**
     * Test Method for approval succeed
     */
    static testMethod void approveTest() {
        TestDataFactory.createCustomNotifications();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Enable_Sales_Rewards_Notification__c = true;
        customSetting.Auto_Assign_Sales_Rewards__c = true;
        update customSetting;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        contacts.add(new Contact(LeadSource = 'Partner',FirstName = 'Daniel', LastName = 'Freeman',AccountId = accounts[0].Id, Email = 'daniel@test.test'));
        contacts.add(new Contact(LeadSource = 'Partner',FirstName = 'David', LastName = 'DeRosa',AccountId = accounts[0].Id, Email = 'david@test.test'));
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List < Task > tasks = TestDataFactory.createTask();
        insert tasks;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        refTypes[0].Sales_Point__c = 100;
        insert refTypes;
        list<Reference_Basic_Information__c> rbi = [SELECT Id, Reference_Owner__c FROM Reference_Basic_Information__c WHERE Account__c =: accounts[0].Id];
        rbi[0].Reference_Owner__c = Userinfo.getUserId();
        update rbi;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(new list<Account>{accounts[0]}, refReqs, refTypes);
        refReqAccs[0].Account_Request_Status__c = 'Completed';
        refReqAccs[0].Managed_Request__c = true;
        refReqAccs[0].Task_Id__c = tasks[0].Id;
        insert refReqAccs;
        insert new Reference_Basic_Information__c(Referenceability_Status__c = 'Inactive', Is_Referenceable__c = true, Account__c = contacts[6].AccountId, Contact__c =  contacts[6].Id );
        //Start test method
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id', refReqAccs[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[0]);
            SelectRefUseContactsControllerSLDS sruccObj = new SelectRefUseContactsControllerSLDS();
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper cs = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.InfoWrapper info = (SelectRefUseContactsControllerSLDS.InfoWrapper)JSON.deserialize(SelectRefUseContactsControllerSLDS.fetchInfo(sruccObj.refReqAccId), SelectRefUseContactsControllerSLDS.InfoWrapper.class);
            list<SelectRefUseContactsControllerSLDS.ContactWrapper> contactWps = (list<SelectRefUseContactsControllerSLDS.ContactWrapper>)JSON.deserialize(SelectRefUseContactsControllerSLDS.fetchContacts(info.rraAccountId), list<SelectRefUseContactsControllerSLDS.ContactWrapper>.class);
            SelectRefUseContactsControllerSLDS.ContactWrapper contactWp = (SelectRefUseContactsControllerSLDS.ContactWrapper)JSON.deserialize(SelectRefUseContactsControllerSLDS.activateContact(contacts[6].Id, true, true, true, ''), SelectRefUseContactsControllerSLDS.ContactWrapper.class);
            contactWp = (SelectRefUseContactsControllerSLDS.ContactWrapper)JSON.deserialize(SelectRefUseContactsControllerSLDS.activateContact(contacts[7].Id, true, true, true, ''), SelectRefUseContactsControllerSLDS.ContactWrapper.class);
            contactWps = (list<SelectRefUseContactsControllerSLDS.ContactWrapper>)JSON.deserialize(SelectRefUseContactsControllerSLDS.fetchContacts(info.rraAccountId), list<SelectRefUseContactsControllerSLDS.ContactWrapper>.class);
            string contactWpsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(info.rraAccountId);
            string status = SelectRefUseContactsControllerSLDS.approve(sruccObj.refReqAccId,'','test',contactWpsJSON,cs,contacts[7].Id,true);
            system.assertEquals('success:100',status);
        //Stop test method
        Test.stopTest();
    }
    /**
     * Test Method for decline succeed
     */
    static testMethod void declineTest() {
        TestDataFactory.createCustomNotifications();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List < Task > tasks = TestDataFactory.createTask();
        insert tasks;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(new list<Account>{accounts[0]}, refReqs, refTypes);
        refReqAccs[0].Account_Request_Status__c = 'Completed';
        refReqAccs[0].Task_Id__c = tasks[0].Id;
        insert refReqAccs;
        //Start test method
        Test.startTest();
            ApexPages.currentPage().getParameters().put('id', refReqAccs[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[0]);
            SelectRefUseContactsControllerSLDS sruccObj = new SelectRefUseContactsControllerSLDS();
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper cs = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.InfoWrapper info = (SelectRefUseContactsControllerSLDS.InfoWrapper)JSON.deserialize(SelectRefUseContactsControllerSLDS.fetchInfo(sruccObj.refReqAccId), SelectRefUseContactsControllerSLDS.InfoWrapper.class);
            list<SelectRefUseContactsControllerSLDS.ContactWrapper> contactWps = (list<SelectRefUseContactsControllerSLDS.ContactWrapper>)JSON.deserialize(SelectRefUseContactsControllerSLDS.fetchContacts(info.rraAccountId), list<SelectRefUseContactsControllerSLDS.ContactWrapper>.class);
            string status = SelectRefUseContactsControllerSLDS.decline(sruccObj.refReqAccId,cs,'test');
            system.assertEquals('',status);
        //Stop test method
        Test.stopTest();
    }
}