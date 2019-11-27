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
public class TestReferenceabilityTrigger {
    
    //Unit Test method for Insertion
    static testMethod void testAppendingRFTypesOnInsert() {
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
            Test.startTest();
                List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, refTypes);
                insert refers;
                system.assertEquals(refers.size(), 30);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Unit Test method
    static testMethod void testInsertError() {
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
            try {
                List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, refTypes);
                insert refers;
                Referenceability__c ref = new Referenceability__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Referenceability_Type__c = refTypes[0].Id, Status__c = 'Approved', Verified__c = System.today());
                insert ref;
            } catch (System.DmlException e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Contact_Referenceabiltity);
            }
        Test.stopTest();
    }

    //Unit Test method for Updation
    static testMethod void testAppendingRFTypesOnUpdate() {
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
            List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, refTypes);
            insert refers;
            try {
                refers[1].status__c = 'Declined:Unknown reason';
                update refers[1];
                refers[1].Referenceability_Type__c = refTypes[2].Id;
                update refers[1];
                list<Contact> con = [select AccountId from Contact where AccountId = : accounts[0].Id];
                for(Contact c: con)
                    c.AccountId = accounts[1].Id;
                update con;
                
                refers[1].Account__c = accounts[1].Id;
                refers[2].Account__c = accounts[1].Id;
                ConstantsController.updateReferenceabilityOnAccountChange = true;
                update refers;
            } catch (exception e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Contact_Referenceabiltity);
            }
        Test.stopTest();
    }

    //Unit Test method for Deletion
    static testMethod void testAppendingRFTypesOnDelete() {
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
            List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, refTypes);
            insert refers;
            Test.startTest();
                delete refers[1];           
                system.assertEquals(refers.size(), 30);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }

    //Unit Test method for Undeletion
    static testMethod void testAppendingRFTypesOnUndelete() {
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
            List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, refTypes);
            insert refers;
            Test.startTest();
                delete refers[1];
                Database.undelete(refers[1]);
                system.assertEquals(refers.size(), 30);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
}