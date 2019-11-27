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
public with sharing class TestContentAttributeTrigger {
    //Test method 
    static testMethod void testBeforeForDuplicacy() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        system.runAs(u) {
            try {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = new List<Account> {TestDataFactory.createAccounts()[0]};
                insert accounts;
                Reference_Basic_Information__c rbi = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id);
                insert rbi;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                insert referObject;
                list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
                insert attributes;
                list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
                insert childAttributes;
                list < Attribute__c > childAttributes1 = new list < Attribute__c >();
                childAttributes1.add(childAttributes[0]);
                childAttributes1.add(childAttributes[1]);
                TestDataFactory.createContentAttributes(referObject, childAttributes1);
                Content_Attribute__c contentAttrib = new Content_Attribute__c(Reference_Content__c = referObject[0].Id, Attribute__c = childAttributes.get(0).Id);
                insert contentAttrib;
            } catch (System.DmlException e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Content_Attribute);
            }
        }
        //Stop test method
        test.stopTest();
    }

    //Test method
    static testMethod void testAfterForAccountAttrib() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        system.runAs(u) {
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = new List<Account> {TestDataFactory.createAccounts()[0]};
                insert accounts;
                Reference_Basic_Information__c rbi = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id);
                insert rbi;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                insert referObject;
                list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
                insert attributes;
                list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
                insert childAttributes;
                childAttributes.get(2).Parent__c = childAttributes.get(3).Id;
                update childAttributes[2];
                childAttributes.get(0).Parent__c = childAttributes.get(2).Id;
                update childAttributes[0];
                list < Attribute__c > childAttributes1 = new list < Attribute__c >();
                childAttributes1.add(childAttributes[0]);
                childAttributes1.add(childAttributes[1]);
                
                Account_Reference_Content__c accountReferObject = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject;
                TestDataFactory.createContentAttributes(referObject, childAttributes1);
                list < Content_Attribute__c > contAtt = [select Id from Content_Attribute__c where Reference_Content__c = : referObject[0].Id];
                system.assertEquals(4, contAtt.size());
                list<Account_Attribute__c> accAttLst = [select Id from Account_Attribute__c where Reference_Content__c = : referObject[0].Id];
                system.assertEquals(4, accAttLst.size());
            } catch (Exception e) {
                
            }
        }
        //Stop test method
        test.stopTest();
    }
    
    //Test method for Undeletion
    static testMethod void testUndelete() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        system.runAs(u) {
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = new List<Account> {TestDataFactory.createAccounts()[0]};
                insert accounts;
                Reference_Basic_Information__c rbi = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id);
                insert rbi;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                insert referObject;
                list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
                insert attributes;
                list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
                insert childAttributes;
                attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
                insert attributes;
                list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(attributes, 1,1);
                insert childAttributes1;
                list<Account_Attribute__c> accAtt = TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, childAttributes1,true);
                accAtt[0].Reference_Content__c = referObject[0].Id;
                update accAtt;
                childAttributes1 = new list < Attribute__c >();
                childAttributes1.add(childAttributes[0]);
                childAttributes1.add(childAttributes[1]);
                Account_Reference_Content__c accountReferObject = new Account_Reference_Content__c(Reference_Content__c = referObject[0].Id, Account__c = accounts[0].Id);
                insert accountReferObject;
                ConstantsController.fromAccountToContent = false;
                list < Content_Attribute__c > contAtt = TestDataFactory.createContentAttributes(referObject, childAttributes1);
                delete contAtt[0];
                list < Content_Attribute__c > contAtt1 = [select Id from Content_Attribute__c where Reference_Content__c = : referObject[0].Id];
                system.assertEquals(2, contAtt1.size());
                database.undelete(contAtt[0]);
                contAtt1 = [select Id from Content_Attribute__c where Reference_Content__c = : referObject[0].Id];
                system.assertEquals(3, contAtt1.size());
            } catch (Exception e) {
                
            }
        }
        //Stop test method
        test.stopTest();
    }
    
}