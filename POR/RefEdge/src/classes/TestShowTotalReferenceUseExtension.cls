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
public with sharing class TestShowTotalReferenceUseExtension {

    static testMethod void testConstructorAccount() {
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        System.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = new list<Account>{TestDataFactory.createAccounts()[0]};
            insert accounts;
            Reference_Basic_Information__c accRBI = new Reference_Basic_Information__c(Account__c = accounts[0].Id);
            insert accRBI;
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            list<Reference_Request__c> refReqObject = new list<Reference_Request__c> { TestDataFactory.createReferenceRequest()[0]};
            insert refReqObject;
            list < Reference_Request_Account__c > rrAccList = TestDataFactory.createAccountRequests(accounts, refReqObject, refTypes);
            for(Reference_Request_Account__c rra : rrAccList){
            	rra.Account_Request_Status__c = 'Completed';
            }
            insert rrAccList;
            Apexpages.currentPage().getParameters().put('Id', accRBI.Id);
            ShowTotalReferenceUseExtension testObj = new ShowTotalReferenceUseExtension();
            system.assertEquals(1, testObj.mapSize);
        }
        //Stop test method
        test.stopTest();
    }

    static testMethod void testConstructorContact() {
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        System.runAs(u) {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            list<Reference_Basic_Information__c> accRBIs = TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            list<Reference_Basic_Information__c> conRBIs = TestDataFactory.setUpContactRBI(contacts); 
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            list<Reference_Request__c> refReqObject = new list<Reference_Request__c> { TestDataFactory.createReferenceRequest()[0]};
            insert refReqObject;
            list < Reference_Request_Account__c > rrAccList = TestDataFactory.createAccountRequests(new list<Account>{accounts[0]}, refReqObject, refTypes);
            for(Reference_Request_Account__c rra : rrAccList){
            	rra.Account_Request_Status__c = 'Completed';
            }
            insert rrAccList;
            list < Reference_Request_Account_Contact__c > rrACntList = TestDataFactory.createContactRequests(new list<Contact>{contacts[0]}, rrAccList, refTypes);
            for(Reference_Request_Account_Contact__c rra : rrACntList){
            	rra.Contact_Request_Status__c = 'Completed';
            }
            insert rrACntList;
            Apexpages.currentPage().getParameters().put('Id', conRBIs[0].Id);
            ShowTotalReferenceUseExtension testObj = new ShowTotalReferenceUseExtension();
            system.assertEquals(1, testObj.mapSize);
        }
         //Stop test method
        test.stopTest();
    }
}