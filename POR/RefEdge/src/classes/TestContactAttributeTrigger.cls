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
public class TestContactAttributeTrigger {

	//Test method
    static testMethod void testAppendingAttOnInsertWithException() {
        try {
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Account > accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        TestDataFactory.setUpAccountRBI(accounts);
	        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
	        insert attributes;
	        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
	        insert childAttributes;
	        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, childAttributes);
	        childAttributes.get(2).Parent__c = childAttributes.get(3).Id;
	        update childAttributes[2];
	        childAttributes.get(0).Parent__c = childAttributes.get(2).Id;
	        update childAttributes[0];
	        list < Attribute__c > childAttributes1 = new list < Attribute__c >();
	        childAttributes1.add(childAttributes[0]);
	        childAttributes1.add(childAttributes[1]);
	        TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, childAttributes1,true);
	        childAttributes1.clear();
	        childAttributes1.add(childAttributes[0]);
	        TestDataFactory.createAccountAttributes(new list<Account>{accounts[1]}, childAttributes1,true);
	        List < Contact > contacts = TestDataFactory.createContacts(accounts);
	        insert contacts;
	        childAttributes1.clear();
	        childAttributes1.add(childAttributes[4]);
	        childAttributes1.add(childAttributes[5]);
	        TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, childAttributes1);
        
        	//Start test method
            Test.startTest();
	            List < Contact_Attribute__c > lstCon = [Select Attribute__r.Name, Id From Contact_Attribute__c where Contact__c = : contacts[0].Id];
	            system.assertEquals(6, lstCon.size());
            //Stop test method
            Test.stopTest();
        } catch (System.DmlException e) {
            //system.assertEquals(e.getDmlMessage(0), System.Label.Contact_Attribute);
        }
    }
    
    //Test method
    static testMethod void testAppendingAttOnInsertWithOutException() {
        try {
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Account > accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        TestDataFactory.setUpAccountRBI(accounts);
	        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
	        insert attributes;
	        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
	        insert childAttributes;
	        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, childAttributes);
	        childAttributes.get(2).Parent__c = childAttributes.get(3).Id;
	        update childAttributes[2];
	        childAttributes.get(0).Parent__c = childAttributes.get(2).Id;
	        update childAttributes[0];
	        list < Attribute__c > childAttributes1 = new list < Attribute__c >();
	        childAttributes1.add(childAttributes[4]);
	        childAttributes1.add(childAttributes[5]);
	        TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, childAttributes1,true);
	        
	        List < Contact > contacts = TestDataFactory.createContacts(accounts);
	        insert contacts;
	        
        
        	//Start test method
            Test.startTest();
	            List < Contact_Attribute__c > lstCon = [Select Attribute__r.Name, Id From Contact_Attribute__c where Contact__c = : contacts[0].Id];
	            system.assertEquals(0, lstCon.size());
	            //Insert Contact Attributes
	            TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, childAttributes1);
	            List < Contact_Attribute__c > lstCon1 = [Select Attribute__r.Name, Id From Contact_Attribute__c where Contact__c = : contacts[0].Id];
	            system.assertEquals(2, lstCon1.size());
            //Stop test method
            Test.stopTest();
        } catch (System.DmlException e) {
            system.assertEquals(e.getDmlMessage(0), System.Label.Contact_Attribute);
        }
    }

	//Test method for deletion 
    static testMethod void testAppendingAttOnDelete() {
        try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Account > accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        TestDataFactory.setUpAccountRBI(accounts);
	        List < Contact > contacts = TestDataFactory.createContacts(accounts);
	        insert contacts;
	        TestDataFactory.setUpContactRBI(contacts);
	        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
	        insert attributes;
	        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
	        insert childAttributes;
	        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, childAttributes);
	        list < Attribute__c > childAttributes1 = new list < Attribute__c >();
	        childAttributes1.add(childAttributes[4]);
	        childAttributes1.add(childAttributes[5]);
	        TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, childAttributes1);
	        
	        //Start test method
	        Test.startTest();
        	
		        //delete conAtts[1];
		        List < Contact_Attribute__c > lstCon = [Select Attribute__c From Contact_Attribute__c where Contact__c = : contacts[0].Id and Attribute__c = : childAttributes[5].Id];
		        delete lstCon;
		        //system.assertEquals(lstCon.size(), 3);
		        list < Account_Attribute__c > lstAcc = [select Attribute__c from Account_Attribute__c where Contact__c = : contacts[0].Id];
		        system.assertEquals(lstAcc.size(), 1);
	        Test.stopTest();
	        } catch (Exception e) {}
        //Stop test method
        
    }

	//Test method for Undeletion
    static testMethod void testAppendingAttOnUndelete() {
         try{
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        List < Account > accounts = TestDataFactory.createAccounts();
	        insert accounts;
	        TestDataFactory.setUpAccountRBI(accounts);
	        List < Contact > contacts = TestDataFactory.createContacts(accounts);
	        insert contacts;
	        TestDataFactory.setUpContactRBI(contacts);
	        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
	        insert attributes;
	        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
	        insert childAttributes;
	        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
	        insert labels;
	        TestDataFactory.createAttributeLabels(labels, childAttributes);
	        list < Attribute__c > childAttributes1 = new list < Attribute__c >();
	        childAttributes1.add(childAttributes[0]);
	        childAttributes1.add(childAttributes[1]);
	        TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, childAttributes1);
	        
	        //Start test method
	        Test.startTest();
	       
		        List < Contact_Attribute__c > lstCon = [Select Attribute__c From Contact_Attribute__c where Contact__c = : contacts[0].Id and Attribute__c = : childAttributes[1].Id];
		        delete lstCon;
		        //system.assertEquals(lstCon.size(), 1);
		        Database.undelete(lstCon);
		        List < Contact_Attribute__c > lstCon1 = [Select Attribute__c From Contact_Attribute__c where Contact__c = : contacts[0].Id];
		        system.assertEquals(lstCon1.size(), 2);
		    	 Test.stopTest();
		    } catch (Exception e) {
		    	
		    }
        //Stop test method
    }
    
    static testMethod void testBeforeInsertWithSharedContactEnabled() {
    	try {
    		Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
			customSetting.Shared_Contacts__c = true;
			update customSetting;
			List<Account> accounts = TestDataFactory.createAccounts();
			insert accounts;
			TestDataFactory.setUpAccountRBI(accounts);
			List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
			insert attributes;
			List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
			insert childAttributes;
			List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
			insert labels;
			TestDataFactory.createAttributeLabels(labels, childAttributes);
			childAttributes.get(2).Parent__c = childAttributes.get(3).Id;
			update childAttributes[2];
			childAttributes.get(0).Parent__c = childAttributes.get(2).Id;
			update childAttributes[0];
			list < Attribute__c > childAttributes1 = new list < Attribute__c >();
			childAttributes1.add(childAttributes[0]);
			childAttributes1.add(childAttributes[1]);
			TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, childAttributes1,true);
			childAttributes1.clear();
			childAttributes1.add(childAttributes[0]);
			TestDataFactory.createAccountAttributes(new list<Account>{accounts[1]}, childAttributes1,true);
			List<Contact> contacts = TestDataFactory.createContacts(accounts);
			insert contacts;
			childAttributes1.clear();
			childAttributes1.add(childAttributes[4]);
			childAttributes1.add(childAttributes[5]);
			TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, childAttributes1);
			
			Test.startTest();
				List < Contact_Attribute__c > lstCon = [Select Attribute__r.Name, Id From Contact_Attribute__c where Contact__c = : contacts[0].Id];
				system.assertEquals(6, lstCon.size());
				delete lstCon;
		        Database.undelete(lstCon);
			Test.stopTest();
    	} catch(Exception e) {
    		
    	}
    }
    
    static testMethod void testMethodWithSharedContactEnabled1() {
    	try {
    		Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
			customSetting.Shared_Contacts__c = true;
			update customSetting;
			List<Account> accounts = TestDataFactory.createAccounts();
			insert accounts;
			TestDataFactory.setUpAccountRBI(accounts);
			List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
			insert attributes;
			List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
			insert childAttributes;
			List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
			insert labels;
			List<Contact> contacts = TestDataFactory.createContacts(accounts);
			insert contacts;
			TestDataFactory.createAttributeLabels(labels, childAttributes);
			childAttributes.get(2).Parent__c = childAttributes.get(3).Id;
			update childAttributes[2];
			childAttributes.get(0).Parent__c = childAttributes.get(2).Id;
			update childAttributes[0];
			list < Attribute__c > childAttributes1 = new list < Attribute__c >();
			childAttributes1.add(childAttributes[0]);
			childAttributes1.add(childAttributes[1]);
			TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, childAttributes1);
			TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, childAttributes1,true);
			childAttributes1.clear();
			childAttributes1.add(childAttributes[0]);
			TestDataFactory.createAccountAttributes(new list<Account>{accounts[1]}, childAttributes1,true);
			childAttributes1.clear();
			childAttributes1.add(childAttributes[4]);
			childAttributes1.add(childAttributes[5]);
			
			Test.startTest();
				List < Contact_Attribute__c > lstCon = [Select Attribute__r.Name, Id From Contact_Attribute__c where Contact__c = : contacts[0].Id];
				system.assertEquals(6, lstCon.size());
			Test.stopTest();
    	} catch(Exception e) {
    		
    	}
    }
}