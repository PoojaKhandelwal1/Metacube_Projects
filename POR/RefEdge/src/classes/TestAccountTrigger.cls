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
public class TestAccountTrigger {

    // Unit test Method
    static testmethod void UnitTest01() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            Attribute_Mapping__c attrMapping = new Attribute_Mapping__c(Object__c = 'Account',Field__c = 'Last Name', Attribute_Name__c = 'Last Name', Filter_Label_Name__c='Last Name',Field_Api_Name__c='LastName',Is_Related_Mapping__c = true,Mapping_Type__c = 'Parent Object', Related_Object__c ='User', RelationShip_Name__c = 'OwnerId');
            Insert attrMapping;  
            Reference_Basic_Information__c tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
            tempAccount.Is_Referenceable__c = false;
            tempAccount.Referenceability_Status__c = 'Inactive';
            update tempAccount;
            List<Reference_Basic_Information__c> RBIConList = [select Id, Is_Referenceable__c, Referenceability_Status__c from Reference_Basic_Information__c where Contact__c != null and Account__c = : accounts[0].Id];
            system.assertEquals(RBIConList[0].Referenceability_Status__c, 'Active');
            tempAccount.Is_Referenceable__c = true;
            tempAccount.Referenceability_Status__c = 'Active';
            update tempAccount;
            ConstantsController.attMappingForAccount = true;
            TestDataFactory.createAttributeMapping();
            accounts[0].Industry = 'Finance';
            update accounts;
            Test.startTest();   
             // Test Match Class 
        User usr = TestDataFactory.createUser();
        insert usr;
                ConstantsController.attMappingForAccount = true;
                accounts[0].OwnerId = usr.Id;
                update accounts;
                delete accounts;
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    //Test method
    static testMethod void testRULsettings() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            //Start Test Method
            test.startTest();
                List<Reference_Basic_Information__c> RBIList = [select Id, Name, Account__c,Account_Level_RUL__c,RUL_Period__c from Reference_Basic_Information__c where Contact__c = null and Account__c IN : accounts];
                RBIList.get(0).Account_Level_RUL__c = true;
                RBIList.get(0).RUL_Period__c = 50;
                update RBIList[0];
                List<Reference_Basic_Information__c> RBIConList = [select Id, Name, Account__c,RUL_Period__c from Reference_Basic_Information__c where Contact__c != null and Account__c = : RBIList.get(0).Account__c];
                RBIList.get(0).Account_Level_RUL__c = false;
                update RBIList[0];
                List<Reference_Basic_Information__c> RBIConList1 = [select Id, Name, Account__c,RUL_Period__c from Reference_Basic_Information__c where Contact__c != null and Account__c = : RBIList.get(0).Account__c];
                system.assertEquals(RBIConList1[0].RUL_Period__c, customSetting.RUL_Period_Contact__c);
                RBIList.get(0).RUL_Activities_will_do__c = 1;
                RBIList.get(0).RUL_Activities_used__c = 1;
                RBIList.get(0).RUL_Period__c = 50;
                RBIList.get(0).RUL_Last_Activity_Date__c = System.today();
                update RBIList[0];
                Reference_Basic_Information__c tempAccount = [select Id, Name, Account__c,RUL_Limit_Reached__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : RBIList[0].Account__c limit 1];
                system.assertEquals(tempAccount.RUL_Limit_Reached__c, false);
            //Stop Test Method
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    // Unit test Method
    static testmethod void UnitTest_ContactNull() {
        List<Reward__c> issueRewards = new List<Reward__c>();
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            
            TestDataFactory.setUpAccountRBI(accounts);
            
            //Creating Attribute Mapping
        	Attribute_Mapping__c attMapping = new Attribute_Mapping__c(Object__c = ConstantsController.ACCOUNT,
                                                                   Is_Related_Mapping__c = false ,
                                                                   Attribute_Name__c = 'accountsource',
                                                                   Field__c = 'accountsource',
                                                                   Related_Object__c = 'Contact',
                                                                   Filter_Label_Name__c='accountsource',
                                                                   Mapping_Type__c = 'Child Object',
                                                                   Child_RelationShipName__c = 'Contacts',
                                                                   RelationShip_Name__c = 'AccountId',
                                                                   Field_Api_Name__c='accountsource',
                                                                   Inheritable__c = true);
        	insert attMapping;
            
            //update Account
            ConstantsController.accountDeletePrevious = true;
            Account acc = accounts[0];
            acc.Industry = 'Finance';
            acc.name = 'Test Acc';
            update acc;
            
            //Creating Referenceability
            Referenceability_Type__c refTye = new Referenceability_Type__c(Name = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_code__c = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100,Note__c = 'test notes');
        	insert refTye;
            
            //Creating reward
            Reward__c reward = new Reward__c(Account__c = accounts[0].id,Contact__c = null,
                                                           Transaction__c ='Issue',Amount__c = 1000, 
                                                           Available_Points__c = 1000,Referenceability_Type__c = refTye.id,Influitive_ID2__c = '',RewardDate__c = System.today()); 
            issueRewards.add(reward);
            insert issueRewards;
            
            //Creating nomonation
            Nomination__c nominationT = new Nomination__c(Account__c = accounts[0].id);
            insert nominationT;
            
            //Creating hitList
            Hit_List__c hitObj = new Hit_List__c();
            hitObj.Account__c = accounts[0].id;
            insert hitObj;
            
            //Creating Attribute
            List < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            
            //Creating Account Attribute
            List<Account_Attribute__c> accAttrs = TestDataFactory.createAccountAttributes(accounts,attributes,true);
            Test.startTest();   
                delete accounts;
                List<Account> tempList = [SELECT Id FROM Account];
                System.assertEquals(tempList.size(), 0);
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    static testmethod void testMergeAccount() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reward__c> issueRewards = new List<Reward__c>();
        TestDataFactory.setUpAccountRBI(accounts);
        
        //Creating Attribute Mapping
    	list<Attribute_Mapping__c> attMapping = TestDataFactory.createAttributeMapping();
        //update Account
        Account acc = accounts[0];
        acc.Industry = 'Finance';
        acc.name = 'Test Acc';
        update acc;
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        //Creating Attribute
        List < Attribute__c > attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        //Creating Account Attribute
        List<Account_Attribute__c> accAttrs = TestDataFactory.createAccountAttributes(accounts,attributes,true);
        //Creating Referenceability
        Referenceability_Type__c refTye = new Referenceability_Type__c(Name = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_code__c = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100,Note__c = 'test notes');
    	insert refTye;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        //Creating reward
        Reward__c reward = new Reward__c(Account__c = accounts[0].id,Contact__c = null,
                                                       Transaction__c ='Issue',Amount__c = 1000, 
                                                       Available_Points__c = 1000,Referenceability_Type__c = refTye.id,Influitive_ID2__c = '',RewardDate__c = System.today()); 
        issueRewards.add(reward);
        insert issueRewards;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Account_Request_Status__c = 'Completed';
        refReqAccs[1].Account_Request_Status__c = 'Completed';
        insert refReqAccs;
        list<Referenceability__c> refers = TestDataFactory.createReferenceability(accounts, new list<Contact>(), refTypes);
        insert refers;
        List < ContentVersion > nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        list<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        list < Account_Reference_Content__c > accountContents = TestDataFactory.createAccountRefContents(new list< Account > {accounts[1]}, contents);
        insert accountContents;
        //Creating nomonation
        Nomination__c nominationT = new Nomination__c(Account__c = accounts[0].id);
        insert nominationT;
        
        //Creating hitList
        Hit_List__c hitObj = new Hit_List__c();
        hitObj.Account__c = accounts[0].id;
        insert hitObj;
        
        Account masterAcct = accounts[0];
        Account mergeAcct = accounts[1];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        tempAccount[0].Is_Referenceable__c = true;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :accounts.get(0).Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount9() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Referenceability__c> refers = TestDataFactory.createReferenceability(accounts, new list<Contact>(), refTypes);
        insert refers;
        
        Account masterAcct = accounts[0];
        Account mergeAcct = accounts[1];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        delete tempAccount;
        tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[1].Id limit 1];
        delete tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :accounts.get(0).Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount1() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        Account masterAcct = accounts[0];
        Account mergeAcct = accounts[1];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        tempAccount[0].Is_Referenceable__c = true;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[1].Id limit 1];
        tempAccount[0].Is_Referenceable__c = true;
        tempAccount[0].Referenceability_Status__c = 'Caution';
        update tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :accounts.get(0).Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount2() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        Account masterAcct = accounts[0];
        Account mergeAcct = accounts[1];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        tempAccount[0].Is_Referenceable__c = true;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[1].Id limit 1];
        tempAccount[0].Is_Referenceable__c = true;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :accounts.get(0).Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount3() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        Account masterAcct = accounts[0];
        Account mergeAcct = accounts[1];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        tempAccount[0].Is_Referenceable__c = false;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[1].Id limit 1];
        tempAccount[0].Is_Referenceable__c = false;
        tempAccount[0].Reference_Program_Candidate__c = true;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :accounts.get(0).Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount4() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        Account masterAcct = new Account(Name='master');
        insert masterAcct;
        Account mergeAcct = accounts[0];
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :masterAcct.Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount5() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        Account masterAcct = new Account(Name='master');
        insert masterAcct;
        Account mergeAcct = accounts[0];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        tempAccount[0].Is_Referenceable__c = true;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :masterAcct.Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount7() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        Account masterAcct = new Account(Name='master');
        insert masterAcct;
        Account mergeAcct = accounts[0];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        tempAccount[0].Is_Referenceable__c = true;
        tempAccount[0].Referenceability_Status__c = 'Caution';
        update tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :masterAcct.Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    static testmethod void testMergeAccount8() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        Account masterAcct = new Account(Name='master');
        insert masterAcct;
        Account mergeAcct = accounts[0];
        list<Reference_Basic_Information__c> tempAccount = [select Id, Name, Is_Referenceable__c,Reference_Program_Candidate__c,Referenceability_Status__c from Reference_Basic_Information__c where Contact__c = null and Account__c = : accounts[0].Id limit 1];
        tempAccount[0].Is_Referenceable__c = false;
        tempAccount[0].Reference_Program_Candidate__c = true;
        tempAccount[0].Referenceability_Status__c = 'Inactive';
        update tempAccount;
        Contact c = new Contact(FirstName='Joe', LastName='Merged');
        c.AccountId = mergeAcct.Id;
        insert c;
        Test.startTest();
            try {
                merge masterAcct mergeAcct;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            masterAcct = [SELECT Id, Name, (SELECT FirstName, LastName From Contacts) FROM Account WHERE Id = :masterAcct.Id LIMIT 1];
            System.assert(masterAcct.getSObjects('Contacts').size() > 0);
            System.assertEquals('Joe', masterAcct.getSObjects('Contacts')[0].get('FirstName'));
            System.assertEquals('Merged', masterAcct.getSObjects('Contacts')[0].get('LastName'));
        Test.stopTest();
    }
    
    static testmethod void testAfterDelete() {
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
        delete accounts;
        system.assertNotEquals(accounts, null);
    }
}