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
public with sharing class TestContentAccountTrigger {
    
    public static Account_Reference_Content__c accountReferObject;
    public static Account_Reference_Content__c accountReferObject1;
	
	//Test method for Duplicacy in Insertion
    static testMethod void chkForDuplicacyInInsertion() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        system.runAs(u) {
            try {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = new List<Account> {TestDataFactory.createAccounts()[0]};
        		insert accounts;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                insert referObject;
                accountReferObject = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject;
                accountReferObject1 = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject1;
            } catch (System.DmlException e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Junction_already_exists);
            }
        }
        //Stop test method
        test.stopTest();
    }

	//Test method Duplicacy in Undeletion
    static testMethod void chkForDuplicacyInUndelete() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        system.runAs(u) {
            try {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = new List<Account> {TestDataFactory.createAccounts()[0]};
        		insert accounts;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                insert referObject;
                accountReferObject = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject;
                delete accountReferObject;
                accountReferObject1 = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject1;
                Database.undelete(accountReferObject.Id);
            } catch (System.DmlException e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Junction_already_exists);
            }
        }
        //Stop test method
        test.stopTest();
    }

	//Test method 
    static testMethod void chkForAttributeOnReferenceContentInsert() {
        User u = TestDataFactory.CreateUser();
        insert u;
        test.startTest();
        //Start test method
        system.runAs(u) {
            try {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = new List<Account> {TestDataFactory.createAccounts()[0]};
        		insert accounts;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                insert referObject;
                list < Attribute__c > attributes = TestDataFactory.createAttribute();
		        insert attributes;
		        list<Account_Attribute__c> accAtt = TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, attributes,true);
		        accAtt[0].Reference_Content__c = referObject[0].Id;
		        accAtt[1].Reference_Content__c = referObject[0].Id;
		        accAtt[2].Reference_Content__c = referObject[0].Id;
		        update accAtt;
		        accountReferObject = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject;
                list<Content_Attribute__c> contAtt = [select Id from Content_Attribute__c where Reference_Content__c = : referObject[0].Id];
                system.assertEquals(18, contAtt.size());
            } catch (exception e) {

            }
        }
        //Stop test method
        test.stopTest();
    }
    
	//Test method 
    static testMethod void chkForAttributeOnReferenceContentDelete() {
        User u = TestDataFactory.CreateUser();
        insert u;
        test.startTest();
        //Start test method
        system.runAs(u) {
            try {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = new List<Account> {TestDataFactory.createAccounts()[0]};
        		insert accounts;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                insert referObject;
                list < Attribute__c > attributes = TestDataFactory.createAttribute();
		        insert attributes;
		        list < Attribute__c > childAttributes1 = new list < Attribute__c >();
		        childAttributes1.add(attributes[0]);
		        childAttributes1.add(attributes[1]);
		        childAttributes1.add(attributes[2]);
		        childAttributes1.add(attributes[3]);
		        childAttributes1.add(attributes[4]);
		        childAttributes1.add(attributes[5]);
		        TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, attributes,true);
		        TestDataFactory.createContentAttributes(referObject, childAttributes1);
		        accountReferObject = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject;
                list<Content_Attribute__c> contAtt = [select Id from Content_Attribute__c where Reference_Content__c = : referObject[0].Id];
                system.assertEquals(18, contAtt.size());
                delete accountReferObject;
                contAtt = [select Id from Content_Attribute__c where Reference_Content__c = : referObject[0].Id];
                system.assertEquals(6, contAtt.size());
            } catch (exception e) {

            }
        }
        //Stop test method
        test.stopTest();
    }
}