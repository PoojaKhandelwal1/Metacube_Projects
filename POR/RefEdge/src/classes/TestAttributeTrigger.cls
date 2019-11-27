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
public class TestAttributeTrigger {
    
    //Test Method for Insertion
    static testMethod void testInsert() {
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Contact > contacts = TestDataFactory.createContacts(accounts);
                insert contacts;
                TestDataFactory.setUpContactRBI(contacts);
                list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
                insert referObjects;
                list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
                insert attributes;
                list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,1);
                insert childAttributes;
                list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2,1);
                insert childAttributes1;
                list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3,1);
                insert childAttributes2;
                Attribute__c tempAtt = [select level__c from Attribute__c where Id = : attributes[0].Id limit 1];
                system.assertEquals(tempAtt.Level__c, 0);
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    //test method for updation
    static testMethod void testUpdate() {
        //Start test method
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Contact > contacts = TestDataFactory.createContacts(accounts);
                insert contacts;
                TestDataFactory.setUpContactRBI(contacts);
                list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
                insert referObjects;
                list < Attribute__c > attributes = TestDataFactory.createAttribute();
                insert attributes;
                list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1,1);
                insert childAttributes;
                list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2,1);
                insert childAttributes1;
                list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3,1);
                insert childAttributes2;
                TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes2,false);
                TestDataFactory.createContactAttributes(new list< Contact > {contacts[0]}, childAttributes2);
                TestDataFactory.createContentAttributes(referObjects, childAttributes2);
            //Stop test method
            test.stopTest();
            Attribute__c tempAtt = [select level__c from Attribute__c where Id = : childAttributes2[0].Id limit 1];
            system.assertEquals(tempAtt.level__c, 3);
            childAttributes2[0].parent__c = childAttributes[0].Id;
            childAttributes2[0].Inheritable__c = true;
            update childAttributes2;
            childAttributes2[0].Parent__c = null;
            childAttributes2[0].Name = 'new one';
            update childAttributes2[0];
            attributes[0].Name = 'test att';
            update attributes[0];
            system.assertEquals(childAttributes2[0].Name, 'new one');
        }catch(Exception e){
            
        }
    }
    //Test method for Deletion
    static testMethod void testDelete() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Nomination__c> nominations = TestDataFactory.createNominations(accounts, new list<Contact>());
        insert nominations;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1,1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2,1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3,1);
        insert childAttributes2;
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        
        //Start test method
        test.startTest();
            try {
                delete tempAtt;
            } catch (Exception e) {
                system.assertEquals(e.getDmlMessage(0), System.Label.Attribute_reassign_before_delete);
            }
            //Stop test method
        test.stopTest();
    }
}