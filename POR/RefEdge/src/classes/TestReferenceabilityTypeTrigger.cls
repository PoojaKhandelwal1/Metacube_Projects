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
public with sharing class TestReferenceabilityTypeTrigger {
    
    //Unit Test Method
    static testMethod void testAppendingRFTypesOnInsert() {
        try {
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
            insert refTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            Test.startTest();
            Referenceability_Type__c newRef = new Referenceability_Type__c(Name = 'Reference Interview',Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 0,max_accounts_per_request_type__c = 15,Reward_points__c = 900);
            try{
                insert newRef;
            }
            catch(exception e){}
            
            newRef.min_lead_time_per_request_type__c = 10;
            insert newRef;
            try{
                newRef.min_lead_time_per_request_type__c = 0;
                update newRef;
            }
            catch(exception e){}
            //Insert rfTypes
            List < Referenceability__c > refers = TestDataFactory.createReferenceability(accounts, contacts, refTypes);
            insert refers;
            refTypes[0].Name = 'RFType10';
            refTypes[1].Name = 'RFType20';
            refTypes[2].Name = 'RFType30';
            update refTypes;
            system.assertNotEquals(refTypes[0].Name,null);
            //Delete Ref Type
            delete refTypes;
            
            Test.stopTest();
        } catch (Exception e) {
            system.debug('Error:' + e);
        }
    }
}