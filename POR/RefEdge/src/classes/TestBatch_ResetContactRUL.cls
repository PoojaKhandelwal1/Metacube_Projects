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
public class TestBatch_ResetContactRUL {
	//Unit test method
    static testmethod void myUnitTest01() {  
    	try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
	        insert refTypes;
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
	        refReqs = TestDataFactory.createMoreReferenceRequest();
	        insert refReqs;
	        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
	        for(Reference_Request_Account__c rra : refReqAccs){
	        	rra.Activity_Date__c = system.today();
	        	rra.Reference_Use__c = true;
	        	rra.Managed_Request__c=true;
	        	rra.Account_Request_Status__c = 'Completed';
	        }
	        insert refReqAccs;
	        list<Reference_Request_Account_Contact__c> refReqAccContact = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
	        for(Reference_Request_Account_Contact__c rrac : refReqAccContact){
	        	rrac.Activity_Date__c = system.today();
	        	rrac.Reference_Use__c = true;
	        	rrac.Contact_Request_Status__c = 'Completed';
	        }
	        insert refReqAccContact;
	        //Start test method
	        test.startTest(); 
		        Batch_ResetContactRULWithAccountRBI batchContactRUL = new Batch_ResetContactRULWithAccountRBI();
		        ID batchprocessid = database.executebatch(batchContactRUL);
	        //Stop test method
	        test.stopTest();
	      	list<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c where Contact__c =:contacts[0].Id];
	        system.assertEquals(rbiList.size(),1);
    	}catch(Exception e){
    		
    	}
    }
}