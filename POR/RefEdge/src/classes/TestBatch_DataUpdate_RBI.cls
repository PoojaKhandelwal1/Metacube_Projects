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
private class TestBatch_DataUpdate_RBI {
    //Test Method 01
    static testmethod void unitTest01() {
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
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
        insert childAttributes2;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        
        list<Reference_Content__c> contents = TestDataFactory.createReferenceContent();
        insert contents;
        list<Account_Attribute__c> accountAttribute = TestDataFactory.createAccountAttributes(accounts, tempAtt, false);
        list<Contact_Attribute__c> contactAttribute = TestDataFactory.createContactAttributes(contacts, tempAtt);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(accounts, contacts, refTypes);
        insert refers;
        Test.startTest();
            try {
                Batch_DataUpdate_RBI batchRBIUpdate = new Batch_DataUpdate_RBI();
                ID batchprocessid = database.executebatch(batchRBIUpdate);
                List < Reference_Basic_Information__c > lstAcc1 = [Select a.Attributes__c,a.Label_Ids1__c,a.Label_Ids2__c,ReferenceabilityType_Ids1__c From Reference_Basic_Information__c a where Account__c = : accounts[0].Id];
                system.assertNotEquals(0,lstAcc1.size());
                delete childAttributes2;
                batchRBIUpdate = new Batch_DataUpdate_RBI();
                batchprocessid = database.executebatch(batchRBIUpdate);
            } catch (Exception e) {
            
            }
        Test.stopTest();
    }
    
    //Test Method 02
    static TestMethod void unitTest02() {
        User u = TestDataFactory.CreateUser();
        insert u;
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
        insert childAttributes2;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        list<Reference_Content__c> contents = TestDataFactory.createReferenceContent();
        insert contents;
        //Test Start
        Test.startTest();
            try{
                system.runas(u) {
                    Batch_DataUpdate_RBI batchRBIUpdate = new Batch_DataUpdate_RBI();
                    ID batchprocessid = database.executebatch(batchRBIUpdate);
                    List < Attributes_Labels__c > lstAcc1 = [Select Id From Attributes_Labels__c  where label__c = :labels[0].Id];
                    system.assertEquals(1,lstAcc1.size());
                }
            } catch (Exception e) {
                
            }
        //Test Stop
        Test.stopTest();
    } 
    //Test Method 02
    static TestMethod void unitTest03() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        ConstantsController.isCopyNominationDetailProcess = true;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
        insert childAttributes2;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        
        list<Reference_Content__c> contents = TestDataFactory.createReferenceContent();
        insert contents;
        list<Account_Attribute__c> accountAttribute = TestDataFactory.createAccountAttributes(accounts, tempAtt, false);
        list<Contact_Attribute__c> contactAttribute = TestDataFactory.createContactAttributes(contacts, tempAtt);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(accounts, contacts, refTypes);
        insert refers;
        ConstantsController.isCopyNominationDetailProcess = false;
        Test.startTest();
            try {
                Batch_DataUpdate_RBI batchRBIUpdate = new Batch_DataUpdate_RBI();
                ID batchprocessid = database.executebatch(batchRBIUpdate);
                List < Reference_Basic_Information__c > lstAcc1 = [Select a.Attributes__c,a.Label_Ids1__c,a.Label_Ids2__c,ReferenceabilityType_Ids1__c From Reference_Basic_Information__c a where Account__c = : accounts[0].Id];
                system.assertNotEquals(0,lstAcc1.size());
                delete childAttributes2;
                batchRBIUpdate = new Batch_DataUpdate_RBI();
                batchprocessid = database.executebatch(batchRBIUpdate);
            } catch (Exception e) {
            
            }
        Test.stopTest();
    }
    
    static testMethod void testCreateData() {
    	Schema.DescribeSObjectResult describeResult = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c').getDescribe();
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
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts; 
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
		List<Hit_List__c> sharedContactObj = new List<Hit_List__c>();
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[1].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[2].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[3].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        insert sharedContactObj; 
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list < Attribute__c > childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
        insert childAttributes2;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt); 
        list<Reference_Content__c> contents = TestDataFactory.createReferenceContent();
        insert contents; 
        system.assertNotEquals(0, contents.Size());
        tempAtt = [select Id,level__c from Attribute__c where level__c != 0 and level__c = 2]; 
        list<Account_Attribute__c> accountAttribute = TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, tempAtt, true);
        list<Contact_Attribute__c> contactAttribute = TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, tempAtt);
      
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        system.assertNotEquals(0,refTypes.Size());
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>{accounts[0]}, new list<Contact>{contacts[0]}, refTypes);
        insert refers;
        Set<Id> rbiIds = new Set<Id>();
        for (Reference_Basic_Information__c accRBI : accRBIList) {
        	rbiIds.add(accRBI.Id);
        } 
        set<string> accIds = new set<String>();
        accIds.add(accounts[0].Id);
    	accIds.add(accounts[1].Id);
    	accIds.add(accounts[2].Id);
		//Batch_DataUpdate_RBI tempObj = new Batch_DataUpdate_RBI(rbiIds, accounts[0].Id, contacts[0].Id, true, accIds);
		Test.startTest();  
        Batch_DataUpdate_RBI batchRBIUpdate = new Batch_DataUpdate_RBI(rbiIds, accounts[0].Id, contacts[0].Id, true, accIds,new set<string>(),new set<string>(), true);
        ID batchprocessid = database.executebatch(batchRBIUpdate);
        //List < Reference_Basic_Information__c > lstAcc1 = [Select a.Attributes__c,a.Label_Ids1__c,a.Label_Ids2__c,ReferenceabilityType_Ids1__c From Reference_Basic_Information__c a where Account__c = : accounts[0].Id];
        //system.assertNotEquals(0, lstAcc1.size());
            
        Test.stopTest();
    }
    static testMethod void testCreateData2() {
    	Schema.DescribeSObjectResult describeResult = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c').getDescribe();
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
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
		List<Hit_List__c> sharedContactObj = new List<Hit_List__c>();
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[1].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[2].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[3].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        insert sharedContactObj;
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        Set<Id> rbiIds = new Set<Id>();
        for (Reference_Basic_Information__c accRBI : accRBIList) {
        	rbiIds.add(accRBI.Id);
        }
        set<string> accIds = new set<String>();
    	accIds.add(accounts[0].Id);
    	accIds.add(accounts[1].Id);
    	accIds.add(accounts[2].Id);
        ConstantsController.isCopyNominationDetailProcess = true;
        tempAtt = [select Id,level__c from Attribute__c where level__c != 0 and level__c = 2];
        list<Account_Attribute__c> accountAttribute1 = TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, tempAtt, false);
        list<Contact_Attribute__c> contactAttribute1 = TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, tempAtt);
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>{accounts[0]}, new list<Contact>{contacts[0]}, refTypes);
        insert refers;
        ConstantsController.isCopyNominationDetailProcess = false;
		//Batch_DataUpdate_RBI tempObj = new Batch_DataUpdate_RBI(rbiIds, accounts[0].Id, contacts[0].Id, true);
		Test.startTest();
            try {
                Batch_DataUpdate_RBI batchRBIUpdate = new Batch_DataUpdate_RBI(rbiIds, accounts[0].Id, contacts[0].Id, true, accIds,new set<string>(),new set<string>(), true);
                ID batchprocessid = database.executebatch(batchRBIUpdate);
                List < Reference_Basic_Information__c > lstAcc1 = [Select a.Attributes__c,a.Label_Ids1__c,a.Label_Ids2__c,ReferenceabilityType_Ids1__c From Reference_Basic_Information__c a where Account__c = : accounts[0].Id];
                system.assertNotEquals(0, lstAcc1.size());
            } catch (Exception e) {}
        Test.stopTest();
    }
    static testMethod void testCreateData3() {
    	Schema.DescribeSObjectResult describeResult = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c').getDescribe();
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
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
		List<Hit_List__c> sharedContactObj = new List<Hit_List__c>();
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[1].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[2].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[3].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        insert sharedContactObj;
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        Set<Id> rbiIds = new Set<Id>();
        for (Reference_Basic_Information__c accRBI : accRBIList) {
        	rbiIds.add(accRBI.Id);
        }
        set<string> accIds = new set<String>();
    	accIds.add(accounts[0].Id);
    	accIds.add(accounts[1].Id);
    	accIds.add(accounts[2].Id);
        ConstantsController.isCopyNominationDetailProcess = true;
        tempAtt = [select Id,level__c from Attribute__c where level__c != 0 and level__c = 2];
        list<Account_Attribute__c> accountAttribute1 = TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, tempAtt, true);
        //list<Contact_Attribute__c> contactAttribute1 = TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, tempAtt);
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>{accounts[0]}, new list<Contact>{}, refTypes);
        insert refers;
        ConstantsController.isCopyNominationDetailProcess = false;
		//Batch_DataUpdate_RBI tempObj = new Batch_DataUpdate_RBI(rbiIds, accounts[0].Id, contacts[0].Id, true);
		Test.startTest();
            try {
                Batch_DataUpdate_RBI batchRBIUpdate = new Batch_DataUpdate_RBI(rbiIds, accounts[0].Id, null, true, accIds,new set<string>(),new set<string>(), true);
                ID batchprocessid = database.executebatch(batchRBIUpdate);
                List < Reference_Basic_Information__c > lstAcc1 = [Select a.Attributes__c,a.Label_Ids1__c,a.Label_Ids2__c,ReferenceabilityType_Ids1__c From Reference_Basic_Information__c a where Account__c = : accounts[0].Id];
                system.assertNotEquals(0, lstAcc1.size());
            } catch (Exception e) {}
        Test.stopTest();
    }
    static testMethod void testCreateData4() {
    	Schema.DescribeSObjectResult describeResult = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c').getDescribe();
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
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
		List<Hit_List__c> sharedContactObj = new List<Hit_List__c>();
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[1].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[2].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[0].Id, Contact__c = contacts[3].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactObj.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[0].Id));
        insert sharedContactObj;
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        list < Attribute__c > attributes = new list< Attribute__c > {TestDataFactory.createAttribute()[0]};
        attributes[0].Inheritable__c = true;
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(new list< Attribute__c > {attributes[0]}, 1, 1);
        insert childAttributes;
        list < Attribute__c > childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
        insert childAttributes1;
        list<Attribute__c> tempAtt = [select Id,level__c from Attribute__c where level__c != 0];
        TestDataFactory.createAttributeLabels(labels, tempAtt);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        Set<Id> rbiIds = new Set<Id>();
        for (Reference_Basic_Information__c accRBI : accRBIList) {
        	rbiIds.add(accRBI.Id);
        }
        set<string> accIds = new set<String>();
    	accIds.add(accounts[0].Id);
    	accIds.add(accounts[1].Id);
    	accIds.add(accounts[2].Id);
        ConstantsController.isCopyNominationDetailProcess = true;
        tempAtt = [select Id,level__c from Attribute__c where level__c != 0 and level__c = 2];
        //list<Account_Attribute__c> accountAttribute1 = TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, tempAtt, false);
        list<Contact_Attribute__c> contactAttribute1 = TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, tempAtt);
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>{}, new list<Contact>{contacts[0]}, refTypes);
        insert refers;
        ConstantsController.isCopyNominationDetailProcess = false;
		//Batch_DataUpdate_RBI tempObj = new Batch_DataUpdate_RBI(rbiIds, accounts[0].Id, contacts[0].Id, true);
		Test.startTest();
            try {
                Batch_DataUpdate_RBI batchRBIUpdate = new Batch_DataUpdate_RBI(rbiIds, null, contacts[0].Id, true, accIds,new set<string>(),new set<string>(), true);
                ID batchprocessid = database.executebatch(batchRBIUpdate);
                List < Reference_Basic_Information__c > lstAcc1 = [Select a.Attributes__c,a.Label_Ids1__c,a.Label_Ids2__c,ReferenceabilityType_Ids1__c From Reference_Basic_Information__c a where Account__c = : accounts[0].Id];
                system.assertNotEquals(0, lstAcc1.size());
            } catch (Exception e) {}
        Test.stopTest();
    }
}