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
public with sharing class TestExpireCommunityInviteController {
    
    //Test Method 
    static testMethod void unitTest01(){
        list < Contact > contacts;
        list < Community_Invite__c > cciList;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        list < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        
        list < Referenceability__c > listReferenceability = TestDataFactory.createReferenceability(accounts, contacts, rfTypes);
        insert listReferenceability;
        
        list<Reference_Request__c> refReqObject = new list<Reference_Request__c> { TestDataFactory.createReferenceRequest()[0]};
        insert refReqObject;
        
        list < Reference_Request_Account__c > rrAccList = TestDataFactory.createAccountRequests(new list<Account>{accounts[0]}, refReqObject, rfTypes);
        insert rrAccList;
        
        cciList = TestDataFactory.createCommunityInvite(rrAccList);
        insert cciList;
        
        rrAccList.get(0).Community_Invite__c = cciList.get(0).id;
        update rrAccList;
        list < Community_Invite_Contact__c > newCICrecords = new list < Community_Invite_Contact__c > ();
        newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = cciList[0].Id, Contact__c = contacts[0].Id, Response__c = 'Yes'));
        newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = cciList[0].Id, Contact__c = contacts[1].Id));
        insert newCICrecords;
        
        Test.startTest();
                ApexPages.StandardController sc = new ApexPages.standardController(cciList[0]);
                ExpireCommunityInviteController conObj = new ExpireCommunityInviteController(sc);
                conObj.expire();
                list<Community_Invite_Contact__c> tempList = [select id,Response__c from Community_Invite_Contact__c where Id = : newCICrecords.get(1).id];
                System.assertEquals('No Response',tempList[0].Response__c);
        Test.stopTest();
    }
}