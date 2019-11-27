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
public with sharing class TestHitListTrigger {
	static testmethod void createHitList(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
            try{
                List<Account> accounts = TestDataFactory.createAccounts();
                insert accounts;
                List < Contact > contacts = TestdataFactory.createContacts(accounts);
                insert contacts;
                List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
                insert refReqs;
                List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
                insert refTypes;
                List < Reference_Request_Account__c > refReqAccount = TestDataFactory.createAccountRequests(accounts,refReqs,refTypes);
                insert refReqAccount;
                List<Community_Invite__c> cis = TestDataFactory.createCommunityInvite(refReqAccount);
                insert cis;
                Community_Invite__c ci = cis[0];
                Hit_List__c hitList = new Hit_List__c();
				hitList.Account__c = accounts[0].id;
                hitList.Contact__c = contacts[0].id;
                hitList.Community_Invite__c = cis[0].id;
                insert hitList;
                System.assert(hitList.id !=null);
            }catch(Exception e){
                System.debug('Error '+e.getMessage());
            }   
        }
    }
}