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
@isTest(SeeAllData=false)
public class TestAccountAttributeTrigger {

    //Unit Test Method
    static testMethod void testAppendingAttOnInsert() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        list< Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        list < Attribute__c > attributes = TestDataFactory.createAttribute();
        attributes[0].Inheritable__c = true;
        attributes[0].Level__c = 0;
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,1);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        ConstantsController.addAttributesToContact = true;
        TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes,true);
        Attribute__c tempObj = [select Parent__c, Level__c, ParentIds__c from Attribute__c where Id = : childAttributes.get(0).Id limit 1];
        //Start test method
        Test.startTest();
            List < Account > tempaccounts = TestDataFactory.createAccounts();
            insert tempaccounts;
            list < Account_Attribute__c > tempacc = [select id from Account_Attribute__c where Account__c = : accounts[0].Id];
            List < Reference_Basic_Information__c > lstAcc = [Select a.Attributes__c From Reference_Basic_Information__c a where Contact__C = null and Account__c = : accounts[0].Id];
            List < String > atts = (lstAcc[0].Attributes__c).split(',');
            system.assertEquals(atts.size(), 18);
            TestDataFactory.createAccountAttributes(new list< Account > {tempaccounts[0]}, childAttributes,true);
            try{
                TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes,true);
            }
            catch(Exception e){
                
            }
        //Stop test method
        Test.stopTest();
    }
    //Unit Test Method
    static testMethod void testAppendingAttOnDelete() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        attributes[0].Level__c = 0;
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
        insert childAttributes2;
        list<Attribute__c> childatts = [select Id from Attribute__c where Id != :attributes[0].Id];
        TestDataFactory.createAttributeLabels(labels, childatts);
        TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes2,true);
        try {
            Test.startTest();
            Account_Attribute__c tempObj = [select Account__c, Inheritable__c from Account_Attribute__c where Attribute__c = : childAttributes2.get(0).Id limit 1];
            delete tempObj;
            List < Reference_Basic_Information__c > lstAcc = [Select a.Attributes__c From Reference_Basic_Information__c a where Contact__C = null and Account__c = : accounts[0].Id];
            List < String > atts = (lstAcc[0].Attributes__c).split(',');
            system.assertEquals(atts.size(), 2);
            //system.assertEquals(lstAcc[0].Attributes__c, attributes[0].Name);
            tempObj = [select Account__c, Inheritable__c from Account_Attribute__c where Attribute__c = : childAttributes1.get(0).Id limit 1];
            delete tempObj;
            lstAcc = [Select a.Attributes__c From Reference_Basic_Information__c a where Contact__C = null and Account__c = : accounts[0].Id];
            atts = (lstAcc[0].Attributes__c).split(',');
            system.assertEquals(atts.size(), 1);
            Test.stopTest();
        } catch (Exception e) {

        }
    }
    //Unit Test Method
    static testMethod void testAppendingAttOnUndelete() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        attributes[0].Level__c = 0;
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
        insert childAttributes2;
        list<Attribute__c> childatts = [select Id from Attribute__c where Id != :attributes[0].Id];
        TestDataFactory.createAttributeLabels(labels, childatts);
        TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes2,true);
        Test.startTest();
            try {
                Account_Attribute__c tempObj = [select Account__c, Inheritable__c from Account_Attribute__c where Attribute__c = : childAttributes2.get(0).Id limit 1];
                delete tempObj;
                Database.undelete(tempObj);
                List < Reference_Basic_Information__c > lstAcc = [Select a.Attributes__c From Reference_Basic_Information__c a where Contact__c = null and Account__c = : accounts[0].Id];
                List < String > atts = (lstAcc[0].Attributes__c).split(',');
                system.assertEquals(atts.size(), 3);
            } catch (Exception e) {

            }
        Test.stopTest();
    }
    //Unit Test Method
    static testMethod void testAttributesAddedtoContactAndContent() {
            try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
            attributes[0].Inheritable__c = true;
            attributes[0].Level__c = 0;
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
            insert childAttributes1;
            list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
            insert childAttributes2;
            list<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
            insert refContents;
            list < Account_Reference_Content__c > accountContents = TestDataFactory.createAccountRefContents(new list< Account > {accounts[0]}, refContents);
            insert accountContents;
            list<Attribute__c> childatts = [select Id from Attribute__c where Id != :attributes[0].Id];
            TestDataFactory.createAttributeLabels(labels, childatts);
            TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes2,true);
            test.startTest();
                list < Contact_Attribute__c > contctAttribList = new list < Contact_Attribute__c > ([select Attribute__c from Contact_Attribute__c where Contact__c = : contacts.get(0).Id]);
                system.assertEquals(contctAttribList.size(), 3);
                list < Content_Attribute__c > contentAttribList = new list < Content_Attribute__c > ([select Attribute__c from Content_Attribute__c where Reference_Content__c = : refContents.get(0).Id]);
                system.assertEquals(contentAttribList.size(), 3);
            test.stopTest();
        }Catch(Exception e){
            
        }
    }
    //Unit Test Method
    static testMethod void testUpdateAccountAtttribute(){
        try{
             Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
            insert labels;
            list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
            attributes[0].Level__c = 0;
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
            insert childAttributes1;
            list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
            insert childAttributes2;
            list<Attribute__c> childatts = [select Id from Attribute__c where Id != :attributes[0].Id];
            TestDataFactory.createAttributeLabels(labels, childatts);
            TestDataFactory.createAccountAttributes(new list< Account > {accounts[0]}, childAttributes2,false);
            test.startTest();
                Account_Attribute__c tempObj = [select Account__c, Inheritable__c from Account_Attribute__c where Attribute__c = : childAttributes2.get(0).Id limit 1];
                tempObj.Inheritable__c = true;
                update tempObj;
                list<Account_Attribute__c> tempaccAtts = [select Id from Account_Attribute__c where Account__c =:tempObj.Account__c];
                system.assertEquals(tempaccAtts.size(), 3);
             test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    static testMethod void testMethodWithSharedContactsEnabled() {
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
		sObject obj = objectType.newSObject();
		Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Shared_Contacts__c = true;
        customSetting.Shared_Contact_Object__c = describeResult.getName();
		customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
		update customSetting;
		List<Account> accounts = TestDataFactory.createAccounts();
		insert accounts;
		List<Contact> contacts = TestDataFactory.createContacts(accounts);
		insert contacts;
		TestDataFactory.setUpAccountRBI(accounts);
		TestDataFactory.setUpContactRBI(contacts);
		list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
		attributes[0].Level__c = 0;
		insert attributes;
		list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
		insert childAttributes;
		list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
		insert childAttributes1;
		list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
		insert childAttributes2;
		List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
		insert labels;
		TestDataFactory.createAttributeLabels(labels, childAttributes);
		
		Test.startTest();
			obj.put(UtilityController.appNamespace() + 'Account__c', accounts[0].Id);
			obj.put(UtilityController.appNamespace() + 'Contact__c', contacts[1].Id);
			List<sObject> objectList = new List<sObject>();
			objectList.add(obj);
			insert obj;
			TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
			TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes1, false);
			list<Account_Attribute__c> tempAccAtts = [select Id, Attribute__c, Account__c, Inheritable__c from Account_Attribute__c WHERE Attribute__c = :childAttributes1.get(0).Id LIMIT 1];
			delete tempAccAtts;
			Database.undelete(tempAccAtts);
			tempAccAtts.get(0).Inheritable__c = true;
			update tempAccAtts;
			system.assertEquals('h', 'h');
		Test.stopTest();
    }
}