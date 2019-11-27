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
public with sharing class TestBatch_AccConUpdateOnCustomSetting {
    //Unit Test Method
  	static testmethod void myUnitTest01() {
  		try{
		    Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Account > accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        TestDataFactory.setUpAccountRBI(accounts);
	        List < Contact > contacts = TestDataFactory.createContacts(accounts);
	        insert contacts;
	        TestDataFactory.setUpContactRBI(contacts);
	        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
	        insert refTypes;
	        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
	        insert refReqs;
	        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
	        insert refReqAccs;
	        List < Reference_Request_Account_Contact__c > refReqCons = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
	        insert refReqCons;
	        //Start test method
	        test.startTest();
		        Batch_AccConUpdateOnCustomSetting batchConAcc = new Batch_AccConUpdateOnCustomSetting(customSetting.RUL_Period__c,10, customSetting.RUL_Period_Contact__c,10, true, true,customSetting.RUL_Activities__c,customSetting.RUL_Activities_Contact__c);
		        ID batchprocessid = database.executebatch(batchConAcc);
	        //Stop test method
	        test.stopTest();
	        list<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c where Contact__c =:contacts[0].Id];
	    	system.assertEquals(rbiList.size(),1);
  		}catch(Exception e){
  			
  		}		
  	}
  	//Unit Test Method
  	static testmethod void myUnitTest02() {
  		try{
		    Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Account > accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        TestDataFactory.setUpAccountRBI(accounts);
	        List < Contact > contacts = TestDataFactory.createContacts(accounts);
	        insert contacts;
	        TestDataFactory.setUpContactRBI(contacts);
	        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
	        insert refTypes;
	        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
	        insert refReqs;
	        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(new List < Account > {accounts[0]}, refReqs, refTypes);
	        insert refReqAccs;
	        List < Reference_Request_Account_Contact__c > refReqCons = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
	        insert refReqCons;
	        //Start test method
	        test.startTest();
		        Batch_AccConUpdateOnCustomSetting batchConAcc = new Batch_AccConUpdateOnCustomSetting(customSetting.RUL_Period__c,20, customSetting.RUL_Period_Contact__c,10, true, false,customSetting.RUL_Activities__c,customSetting.RUL_Activities_Contact__c);
		        ID batchprocessid = database.executebatch(batchConAcc);
	        //Stop test method
	        test.stopTest();
	        list<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c where Contact__c =:contacts[0].Id];
	    	system.assertEquals(rbiList.size(),1);
  		}catch(Exception e){
  			
  		}
  	}
  	//Unit Test Method
  	static testmethod void myUnitTest03() { 
  		try{
		    Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Account > accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        TestDataFactory.setUpAccountRBI(accounts);
	        List < Contact > contacts = TestDataFactory.createContacts(accounts);
	        insert contacts;
	        TestDataFactory.setUpContactRBI(contacts);
	        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
	        insert refTypes;
	        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
	        insert refReqs;
	        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(new List < Account > {accounts[0]}, refReqs, refTypes);
	        insert refReqAccs;
	        List < Reference_Request_Account_Contact__c > refReqCons = TestDataFactory.createContactRequests(contacts,new list < Reference_Request_Account__c > { refReqAccs[0]}, refTypes);
	        insert refReqCons;
	        //Start test method
	        test.startTest();
		        Batch_AccConUpdateOnCustomSetting batchConAcc = new Batch_AccConUpdateOnCustomSetting(customSetting.RUL_Period__c,10, customSetting.RUL_Period_Contact__c,30, false, true,customSetting.RUL_Activities__c,customSetting.RUL_Activities_Contact__c);
		        ID batchprocessid = database.executebatch(batchConAcc);
	        //Stop test method
	        test.stopTest();
	        list<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c where Contact__c =:contacts[0].Id];
	    	system.assertEquals(rbiList.size(),1);
  		}catch(Exception e){
  			
  		}
  		
  	}
}