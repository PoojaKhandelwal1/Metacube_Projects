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
public with sharing class TestContentContactTriggerHandler {

    public static Contact_Reference_Content__c referContactObj;
    public static Contact_Reference_Content__c referContactObj1;
    public static list < Contact_Reference_Content__c > referContactList;

    //test method for Duplicacy in Insertion
    static testMethod void chkForDuplicacyInInsertion() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.createUser();
        insert u;
        //Start test method
        test.startTest();
        system.runAs(u) {
            try {
                Account account = new Account(Name = 'Acc1');
                insert account;
                Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
                insert contact;
                Reference_Content__c referObject = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English');
                insert referObject;
                referContactObj = new Contact_Reference_Content__c(Reference_Content__c = referObject.Id, Contact__c = contact.Id);
                insert referContactObj;
                referContactObj1 = new Contact_Reference_Content__c(Reference_Content__c = referObject.Id, Contact__c = contact.Id);
                insert referContactObj1;
            } catch (System.DmlException e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Junction_already_exists);
            }
        }
        //Stop test method
        test.stopTest();
    }
    
    //Test method for Duplicacy in Undeletion
    static testMethod void chkForDuplicacyInUndelete() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.createUser();
        insert u;
         //Start test method
        test.startTest();
        system.runAs(u) {
            try {
                Account account = new Account(Name = 'Acc1');
                insert account;
                Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
                insert contact;
                Reference_Content__c referObject = new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active',  Language__c = 'English');
                insert referObject;
                referContactObj = new Contact_Reference_Content__c(Reference_Content__c = referObject.Id, Contact__c = contact.Id);
                insert referContactObj;
                delete referContactObj;
                referContactObj1 = new Contact_Reference_Content__c(Reference_Content__c = referObject.Id, Contact__c = contact.Id);
                insert referContactObj1;
                Database.undelete(referContactObj.Id);
            } catch (System.DmlException e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Junction_already_exists);
            }
        }
        //Stop test method
        test.stopTest();
    }
}