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
public with sharing class TestNominationRefTrigger {
	
	//Unit Test Method
	static testMethod void unitTest01(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        
        list < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        list < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        list<Nomination__c> nominations = TestDataFactory.createNominations(new list<Account>{accounts[0]}, new list<Contact>());
        insert nominations;
        
        //Start test method
        test.startTest();
        	//Insert
            list < Nomination_Referenceability__c > nomiRefs = TestDataFactory.createNominationReferenceability(refTypes, nominations);
            
            //Delete
            delete nomiRefs;
            
            //Undelete
            undelete nomiRefs;
        //Stop test method
        test.stopTest();
        
        list<Nomination_Referenceability__c> listNR = [select Id from Nomination_Referenceability__c where Nomination__c =: nominations[0].Id];
        system.assertEquals(true, listNR.size() > 0);
    }
}