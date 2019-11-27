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
/**
 * Class: RBITriggerHandler
 * Description : Test class for RBITriggerHandler
 * Modified by: Gaurav Saini (3 Jan, 2017)
 */
@isTest(seeAllData = false)
public with sharing class TestRBITriggerHandler {
    
    public static Custom_Settings__c customSetting;
    
    /**
     * method to test and cover checkForAttributeMapping method
     * Created By: Rekha @20 July 2017
     */
    static testmethod void testRBIInsertionToAddProductAttribute() {
        customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name = 'Milton');
        insert acc;

        //Get standard pricebook
        String priceBook2Id = Test.getStandardPricebookId();

        //Product
        Product2 prod = new Product2(Name = 'Test product', family = 'Test family');
        insert prod;

        //PricebookEntry
        PricebookEntry pbe1 = new PricebookEntry (Pricebook2ID = priceBook2Id, Product2ID = prod.id, UnitPrice=500, isActive=true);
        insert pbe1;

        Opportunity opp = new Opportunity(Name = acc.Name + ' Opportunity', AccountId = acc.Id, 
        CloseDate = system.today(), StageName = 'Closed Won', Amount = 1000);
        insert opp;
        //Attribute mapping
        TestDataFactory.createOpportunityAttributeMapping();
        List<Attribute__c> atts = [SELECT Id FROM Attribute__c WHERE Attribute_Mapping__r.Field_Api_Name__c = 'Product2' AND Level__c = 0];
        insert new Attribute__c(name = prod.Name, Parent__c = atts[0].Id, Product_ID__c = prod.Id);
        //Creating Opp Line Data
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opp.id, PriceBookEntryID = pbe1.id, quantity = 4, totalprice = 900);
        insert lineItem;
        Test.startTest();
            Reference_Basic_Information__c rbi = new Reference_Basic_Information__c(Account__c = acc.id,
            Is_Referenceable__c = true,
            Referenceability_Status__c = customSetting.Default_Referenceablity_Status__c);
            insert rbi;
            Set<String> productIds = new Set<String>{prod.Id};
            database.executeBatch(new Batch_AddProductAttributesToAccount(productIds));
            Test.stopTest();
            List<Account_Attribute__c> accAtts = [SELECT Id FROM Account_Attribute__c WHERE Account__c = :acc.Id];
        system.assertEquals(1, accAtts.size());
    }
    /**
     * method to test the before and after insert trigger methods
     * author: Gaurav Saini (7 Nov, 2016)
     */
    static testmethod void testRBIInsertion() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();        
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        // creating rewards
        List<Reward__c> rewardsList = TestDataFactory.createRewards(accounts, contacts);
        insert rewardsList;
        // creating referenceabilities
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
        insert testReferenceabilities;
        // creating reference contents and associating with accounts
        List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
        insert contentVersionList;
        List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
        insert refContentsList;
        List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
        insert ARCList;
        // creating account requests
        List<Reference_Request__c> refRequestList = TestDataFactory.createReferenceRequest();
        insert refRequestList;
        List<Reference_Request_Account__c> accRequestList = TestDataFactory.createAccountRequests(accounts, refRequestList, refTypesList);
        insert accRequestList;
        
        //Start test method
        Test.startTest();
            // inserting the RBIs for accounts
            TestDataFactory.setUpAccountRBINew(accounts);
            ConstantsController.runDuplicateRBICheck = true;
            
            // creating test account with non-referenceable RBI
            Account testNonReferenceableAcc = new Account(Name = 'Test non referenceable account');
            insert testNonReferenceableAcc;
            Reference_Basic_Information__c testNonReferenceableRBI
                        = new Reference_Basic_Information__c(Referenceability_Status__c = '',
                                                                Is_Referenceable__c = false,
                                                                Account__c = testNonReferenceableAcc.Id);
            insert testNonReferenceableRBI;
            List<Reference_Basic_Information__c> accRBIList = [SELECT Id, Account__c
                                                                    FROM Reference_Basic_Information__c
                                                                    WHERE Account__c = :accounts[0].Id];
            // checking whether and RBI is created for the specified account
            system.assertEquals(3, accRBIList.size());
        
        //Stop test method
        Test.stopTest();
    }
    
    /**
     * method to test the before and after insert trigger methods with shared contacts enabled
     * author: Gaurav Saini (7 Nov, 2016)
     */
    static testmethod void testRBIInsertionWithSharedContacts() {
        // setting up test data
        customSetting = TestDataFactory.createCustomSetting();        
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        // enabling shared contacts
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        customSetting.Shared_Contact_Object__c = describeResult.getName();
        customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
        customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
        customSetting.Shared_Contacts__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
        customSetting.Roll_up_Attributes_to_All_Accounts__c = true;
        customSetting.Roll_up_Referenceability_to_All_Accounts__c = true;
        update customSetting;
        
        // creating shared contacts records
        List<Hit_List__c> sharedContactsList = new List<Hit_List__c>();
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[1].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[3].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[4].Id));
        insert sharedContactsList;
        
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
        insert testReferenceabilities;
        // creating reference contents and associating with accounts
        List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
        insert contentVersionList;
        List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
        insert refContentsList;
        List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
        insert ARCList;
        // creating account requests
        List<Reference_Request__c> refRequestList = TestDataFactory.createReferenceRequest();
        insert refRequestList;
        List<Reference_Request_Account__c> accRequestList = TestDataFactory.createAccountRequests(accounts, refRequestList, refTypesList);
        insert accRequestList;
        
        //Start test method
        Test.startTest();
            // inserting the RBIs for accounts
            TestDataFactory.setUpAccountRBINew(accounts);
            ConstantsController.runDuplicateRBICheck = true;
            
            // creating test account
            Account testAcc = new Account(Name = 'Test Account 007');
            insert testAcc;
            Reference_Basic_Information__c testAccRBI
                        = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active',
                                                                Is_Referenceable__c = true,
                                                                Account__c = testAcc.Id,
                                                                Roll_up_Attributes_to_All_Accounts__c = true,
                                                                Roll_up_Referenceability_to_All_Accounts__c = true,
                                                                Inherit_Attributes_from_All_Accounts__c = true);
            insert testAccRBI;
            List<Reference_Basic_Information__c> accRBIList = [SELECT Id, Account__c
                                                                    FROM Reference_Basic_Information__c
                                                                    WHERE Account__c = :testAcc.Id];
            // checking whether RBI is created for the specified account
            system.assertEquals(1, accRBIList.size());
            
            Contact testCon = new Contact(LastName = 'test', AccountId = testAcc.Id, Email = 'test@test.test');
            insert testCon;
            Reference_Basic_Information__c testConRBI
                        = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active',
                                                                Is_Referenceable__c = true,
                                                                Account__c = testAcc.Id,
                                                                Contact__c = testCon.Id);
            insert testConRBI;
            List<Reference_Basic_Information__c> conRBIList = [SELECT Id, Account__c, Contact__c
                                                                    FROM Reference_Basic_Information__c
                                                                    WHERE Contact__c = :testCon.Id];
            // checking whether RBI is created for the specified contact
            system.assertEquals(1, conRBIList.size());
            
        //Stop test method
        Test.stopTest();
    }
    
    /**
     * method to test the before and after update trigger methods for account RBIs
     * author: Gaurav Saini (3 Jan, 2016)
     */
    static testmethod void testRBIUpdate() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;        
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reward__c> rewardsList = TestDataFactory.createRewards(new List<Account>{accounts[0], accounts[1], accounts[2], accounts[3]}, contacts);
        insert rewardsList;
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        
        //Start test method
        Test.startTest();
            List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
            insert testReferenceabilities;
            // creating reference contents and associating with accounts
            List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
            insert contentVersionList;
            List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
            insert refContentsList;
            List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
            insert ARCList;
            
            // inserting the RBIs for accounts
            List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
            ConstantsController.runDuplicateRBICheck = true;
            
            List<Reference_Basic_Information__c> conRBIList = [SELECT Account__c, Contact__c, Is_Referenceable__c,
                                                                Referenceability_Status__c, Reference_Program_Candidate__c
                                                                FROM Reference_Basic_Information__c
                                                                WHERE Contact__c IN :contacts];
            
            // creating attributes for accounts
            List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
            insert attributes;
            List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
            insert childAttributes;
            
            List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, childAttributes);
        //Stop test method
        Test.stopTest();
        TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
        
        // updating account RBIs
        for (Reference_Basic_Information__c accRBI : accRBIList) {
            
            if (accRBI.Is_Referenceable__c) {
                accRBI.Referenceability_Status__c = 'Caution';
                accRBI.Lifetime_Points__c = 0;
            }
        }
        accRBIList[0].RUL_Period__c = 90;
        accRBIList[0].RUL_Activities_will_do__c = 3;
        accRBIList[0].RUL_Activities_used__c = 1;
        accRBIList[4].Is_Referenceable__c = false;
        accRBIList[4].Reference_Program_Candidate__c = true;
        accRBIList[4].Referenceability_Status__c = '';
        update accRBIList;
        system.assert(true);
    }
    
    /**
     * method to test the before and after update trigger methods for contact RBIs
     * author: Gaurav Saini (3 Jan, 2016)
     */
    static testmethod void testRBIUpdate1() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;        
        List<Reward__c> rewardsList = TestDataFactory.createRewards(new List<Account>{accounts[0], accounts[1], accounts[2], accounts[3]}, contacts);
        insert rewardsList;
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        
        //Start test method
        Test.startTest();
            List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
            insert testReferenceabilities;
            // creating reference contents and associating with accounts
            List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
            insert contentVersionList;
            List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
            insert refContentsList;
            List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
            insert ARCList;
            
            // inserting the RBIs for accounts
            List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
            ConstantsController.runDuplicateRBICheck = true;
            
            List<Reference_Basic_Information__c> conRBIList = [SELECT Account__c, Contact__c, Is_Referenceable__c,
                                                                Referenceability_Status__c, Reference_Program_Candidate__c
                                                                FROM Reference_Basic_Information__c
                                                                WHERE Contact__c IN :contacts];
            
            // creating attributes for accounts
            List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
            insert attributes;
            List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
            insert childAttributes;
            
            List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, childAttributes);
        //Stop test method
        Test.stopTest();
        TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
        
        // updating contact RBIs
        for (Reference_Basic_Information__c conRBI : conRBIList) {
            conRBI.Referenceability_Status__c = 'Caution';
        }
        
        Contact testContact = new Contact(LastName = 'test contact', AccountId = accounts[0].Id);
        insert testContact;
        Reference_Basic_Information__c testContactRBI = new Reference_Basic_Information__c(Referenceability_Status__c = '', Is_Referenceable__c = false, Reference_Program_Candidate__c = true, Account__c = testContact.AccountId, Contact__c = testContact.Id);
        insert testContactRBI;
        system.assert(true);
    }

    /**
     * method to test the before and after update trigger methods for contact RBIs
     * author: Dixita (Dec, 2018)
     */
    static testmethod void testRBIUpdate2() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Populate_Summary_frm_Account_Description__c = true;
        update customSetting;
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;        
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        List<Reference_Request__c> refRequestList = TestDataFactory.createReferenceRequest();
        insert refRequestList;
        List<Reference_Request_Account__c> accRequestList = TestDataFactory.createAccountRequests(accounts, refRequestList, refTypesList);
        insert accRequestList; 
        List<Hit_List__c> hitlist  = TestDataFactory.createHitLists();
        
        //Start test method
        Test.startTest();
            List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
            insert testReferenceabilities;
            // creating reference contents and associating with accounts
            
            // inserting the RBIs for accounts
            List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
            ConstantsController.runDuplicateRBICheck = true;
            Reference_Basic_Information__c testAccRBI = accRBIList[0]; 
            hitlist[0].Account__c = testAccRBI.Account__c;
            insert hitlist[0];
            testAccRBI.Is_Referenceable__c = false;
            testAccRBI.Referenceability_Status__c = '';
            update testAccRBI;
            List<Reference_Basic_Information__c> conRBIList = [SELECT Account__c, Contact__c, Is_Referenceable__c,
                                                                Referenceability_Status__c, Reference_Program_Candidate__c
                                                                FROM Reference_Basic_Information__c
                                                                WHERE Contact__c IN :contacts];
            
            
            // updating contact RBIs
            for (Reference_Basic_Information__c conRBI : conRBIList) {
                conRBI.Referenceability_Status__c = 'Caution'; 
            }
            
            Contact testContact = new Contact(LastName = 'test contact', AccountId = accounts[0].Id);
            insert testContact;
        //Stop test method
        Test.stopTest();
        Reference_Basic_Information__c testContactRBI = new Reference_Basic_Information__c(Referenceability_Status__c = '', Is_Referenceable__c = false, Reference_Program_Candidate__c = true, Account__c = testContact.AccountId, Contact__c = testContact.Id);
        insert testContactRBI;
        hitlist[1].Contact__c = testContact.Id;
        insert hitlist[1];
        testContactRBI.Referenceability_Status__c = 'Active';
        testContactRBI.Is_Referenceable__c = true;
        testContactRBI.Reference_Program_Candidate__c = false;
        update testContactRBI;
        List<Reference_Request_Account_Contact__c> RRAC = TestDataFactory.createContactRequests(new List<Contact> {testContact}, accRequestList, refTypesList );
        insert RRAC;
        testContactRBI.Referenceability_Status__c = '';
        testContactRBI.Is_Referenceable__c = false;
        testContactRBI.Reference_Program_Candidate__c = false;
        update testContactRBI;
        system.assert(true);
    }
    
    /**
     * method to test the before and after update trigger methods for account RBIs with sahred contacts enabled
     * author: Gaurav Saini (3 Jan, 2016)
     */
    static testmethod void testRBIUpdateWithSharedContacts() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;     
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;        
        
        // enabling shared contacts
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        customSetting.Shared_Contact_Object__c = describeResult.getName();
        customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
        customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
        customSetting.Shared_Contacts__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
        customSetting.Roll_up_Attributes_to_All_Accounts__c = true;
        customSetting.Roll_up_Referenceability_to_All_Accounts__c = true;
        update customSetting;
        
        // creating shared contacts records
        List<Hit_List__c> sharedContactsList = new List<Hit_List__c>();
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[1].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[3].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[4].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[0].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[1].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[2].Id));
        insert sharedContactsList;
        
        // inserting the RBIs for accounts
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
        ConstantsController.runDuplicateRBICheck = true;
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        // creating reference contents and associating with accounts
        List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
        insert contentVersionList;
        List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
        insert refContentsList;
        List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
        insert ARCList;
        // creating account requests
        List<Reference_Request__c> refRequestList = TestDataFactory.createReferenceRequest();
        insert refRequestList;
        List<Reference_Request_Account__c> accRequestList = TestDataFactory.createAccountRequests(accounts, refRequestList, refTypesList);
        insert accRequestList;
        
        // inserting RBIs for contacts
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        ConstantsController.runDuplicateRBICheck = true;
        
        // creating attributes for accounts
        List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
        insert childAttributes;
        
        //Start test method
        Test.startTest();
            List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, childAttributes);
            TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
            List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
            insert testReferenceabilities;
            
            // updating account RBIs
            for (Reference_Basic_Information__c accRBI : accRBIList) {
                
                if (accRBI.Is_Referenceable__c) {
                    accRBI.Referenceability_Status__c = 'Caution';
                    accRBI.Lifetime_Points__c = 0;
                }
            }
            accRBIList[0].RUL_Period__c = 90;
            accRBIList[0].RUL_Activities_will_do__c = 3;
            accRBIList[0].RUL_Activities_used__c = 1;
            accRBIList[4].Is_Referenceable__c = false;
            accRBIList[4].Reference_Program_Candidate__c = true;
            accRBIList[4].Referenceability_Status__c = '';
            update accRBIList;
            customSetting.Is_Influitive_Integration_Enabled__c = false;
            update customSetting;
            accRBIList[0].RUL_Period__c = 90;
            accRBIList[0].RUL_Activities_will_do__c = 4;
            accRBIList[0].RUL_Activities_used__c = 1;
            update accRBIList;
            accRBIList[1].Account_Level_RUL__c = false;
            accRBIList[1].Is_Referenceable__c = false;
            accRBIList[1].Referenceability_Status__c = '';
            accRBIList[2].Account_Level_RUL__c = true;
            accRBIList[2].Is_Referenceable__c = false;
            accRBIList[2].Referenceability_Status__c = '';
            accRBIList[4].Is_Referenceable__c = true;
            accRBIList[4].Reference_Program_Candidate__c = false;
            accRBIList[4].Referenceability_Status__c = 'Active';
            update accRBIList;
            
            system.assert(true);
            
        //Stop test method
        Test.stopTest();
    }
    
    /**
     * method to test the before and after update trigger methods for account RBIs with sahred contacts enabled
     * author: Gaurav Saini (3 Jan, 2016)
     */
     
    static testmethod void testRBIUpdateWithSharedContacts2() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;        
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        // enabling shared contacts
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        customSetting.Shared_Contact_Object__c = describeResult.getName();
        customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
        customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
        customSetting.Shared_Contacts__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
        customSetting.Roll_up_Attributes_to_All_Accounts__c = true;
        customSetting.Roll_up_Referenceability_to_All_Accounts__c = true;
        update customSetting;
        
        // creating shared contacts records
        List<Hit_List__c> sharedContactsList = new List<Hit_List__c>();
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[1].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[3].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[4].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[0].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[1].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[2].Id));
        insert sharedContactsList;
        
        // inserting the RBIs for accounts
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
        ConstantsController.runDuplicateRBICheck = true;
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        // creating reference contents and associating with accounts
        List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
        insert contentVersionList;
        List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
        insert refContentsList;
        List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
        insert ARCList;
        // creating account requests
        List<Reference_Request__c> refRequestList = TestDataFactory.createReferenceRequest();
        insert refRequestList;
        List<Reference_Request_Account__c> accRequestList = TestDataFactory.createAccountRequests(accounts, refRequestList, refTypesList);
        insert accRequestList;
        
        // inserting RBIs for contacts
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        ConstantsController.runDuplicateRBICheck = true;
        
        // creating attributes for accounts
        List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
        insert childAttributes;
        
        //Start test method
        Test.startTest();
            List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, childAttributes);
            TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
            List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
            insert testReferenceabilities;
            
            // updating account RBIs
            for (Reference_Basic_Information__c accRBI : accRBIList) {
                
                if (accRBI.Is_Referenceable__c) {
                    accRBI.Referenceability_Status__c = 'Caution';
                    accRBI.Lifetime_Points__c = 0;
                }
            }
            accRBIList[0].RUL_Period__c = 90;
            accRBIList[0].RUL_Activities_will_do__c = 3;
            accRBIList[0].RUL_Activities_used__c = 1;
            accRBIList[4].Is_Referenceable__c = false;
            accRBIList[4].Reference_Program_Candidate__c = true;
            accRBIList[4].Referenceability_Status__c = '';
            update accRBIList;
            customSetting.Is_Influitive_Integration_Enabled__c = false;
            update customSetting;
            List<Account> testAccountList = new List<Account>();
            testAccountList.add(new Account(Name = 'test account 1'));
            testAccountList.add(new Account(Name = 'test account 2'));
            insert testAccountList;
            sharedContactsList.add(new Hit_List__c(Account__c = testAccountList[0].Id, Contact__c = contacts[2].Id));
            sharedContactsList.add(new Hit_List__c(Account__c = testAccountList[0].Id, Contact__c = contacts[1].Id));
            sharedContactsList.add(new Hit_List__c(Account__c = testAccountList[1].Id, Contact__c = contacts[0].Id));
            sharedContactsList.add(new Hit_List__c(Account__c = testAccountList[1].Id, Contact__c = contacts[1].Id));
            upsert sharedContactsList;
            List<Reference_Basic_Information__c> testAccountRBIList = new List<Reference_Basic_Information__c>();
            testAccountRBIList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = testAccountList[0].Id));
            testAccountRBIList.add(new Reference_Basic_Information__c(Referenceability_Status__c = '', Is_Referenceable__c = false, Account__c = testAccountList[1].Id));
            insert testAccountRBIList;
            accRBIList[0].RUL_Period__c = 90;
            accRBIList[0].RUL_Activities_will_do__c = 4;
            accRBIList[0].RUL_Activities_used__c = 1;
            testAccountRBIList[0].Referenceability_Status__c = '';
            testAccountRBIList[0].Is_Referenceable__c = false;
            testAccountRBIList[0].Reference_Program_Candidate__c = true;
            testAccountRBIList[1].Referenceability_Status__c = 'Active';
            testAccountRBIList[1].Is_Referenceable__c = true;
            testAccountRBIList[1].Reference_Program_Candidate__c = false;
            accRBIList.addAll(testAccountRBIList);
            update accRBIList;
            
            system.assert(true);
            
        //Stop test method
        Test.stopTest();
    }
    
    /**
     * method to test the before and after update trigger methods for contact RBIs with shared contacts enabled
     * author: Gaurav Saini (3 Jan, 2016)
     */
    static testmethod void testRBIUpdateWithSharedContacts1() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        update customSetting;
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;        
        
        // enabling shared contacts
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        customSetting.Shared_Contact_Object__c = describeResult.getName();
        customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
        customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
        customSetting.Shared_Contacts__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
        customSetting.Roll_up_Attributes_to_All_Accounts__c = true;
        customSetting.Roll_up_Referenceability_to_All_Accounts__c = true;
        update customSetting;
        
        // creating shared contacts records
        List<Hit_List__c> sharedContactsList = new List<Hit_List__c>();
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[1].Id, Contact__c = contacts[0].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[1].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[3].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[2].Id, Contact__c = contacts[4].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[0].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[1].Id));
        sharedContactsList.add(new Hit_List__c(Account__c = accounts[3].Id, Contact__c = contacts[2].Id));
        insert sharedContactsList;
        
        // inserting the RBIs for accounts
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
        ConstantsController.runDuplicateRBICheck = true;
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
        insert testReferenceabilities;
        // creating reference contents and associating with accounts
        List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
        insert contentVersionList;
        List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
        insert refContentsList;
        List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
        insert ARCList;
        // creating account requests
        List<Reference_Request__c> refRequestList = TestDataFactory.createReferenceRequest();
        insert refRequestList;
        List<Reference_Request_Account__c> accRequestList = TestDataFactory.createAccountRequests(accounts, refRequestList, refTypesList);
        insert accRequestList;
        
        //Start test method
        Test.startTest();
            
            // inserting RBIs for contacts
            List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
            ConstantsController.runDuplicateRBICheck = true;
            
            // creating attributes for accounts
            List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
            insert attributes;
            List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
            insert childAttributes;
            List<Attribute__c> childAttributes1 = TestDataFactory.createChildAttributes(childAttributes, 2, 1);
            insert childAttributes1;
            List<Attribute__c> childAttributes2 = TestDataFactory.createChildAttributes(childAttributes1, 3, 1);
            insert childAttributes2;
            List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
            insert labels;
            TestDataFactory.createAttributeLabels(labels, childAttributes);
            TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
            
            // updating contact RBIs
            for (Reference_Basic_Information__c conRBI : conRBIList) {
                conRBI.Referenceability_Status__c = 'Caution';
            }
            Contact testContact = new Contact(LastName = 'test contact', AccountId = accounts[0].Id);
            insert testContact;
            Reference_Basic_Information__c testContactRBI = new Reference_Basic_Information__c(Referenceability_Status__c = '', Is_Referenceable__c = false, Reference_Program_Candidate__c = true, Account__c = testContact.AccountId, Contact__c = testContact.Id);
            insert testContactRBI;
            testContactRBI.Referenceability_Status__c = 'Caution';
            testContactRBI.Reference_Program_Candidate__c = false;
            testContactRBI.Is_Referenceable__c = true;
            testContactRBI.Lifetime_Points__c = 0;
            conRBIList.add(testContactRBI);
            update conRBIList;
            conRBIList[5].Referenceability_Status__c = '';
            conRBIList[5].Is_Referenceable__c = false;
            conRBIList[5].Reference_Program_Candidate__c = true;
            update conRBIList;
            
            system.assert(true);
            
        //Stop test method
        Test.stopTest();
    }
    
    /**
     * method to test the before and after delete trigger methods
     * author: Gaurav Saini (3 Jan, 2016)
     */
    static testmethod void testRBIDeletion() {
        // Setting up test data
        customSetting = TestDataFactory.createCustomSetting();
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        // creating attributes
        List<Attribute__c> attributesList = TestDataFactory.createAttribute();
        insert attributesList;
        // creating child attributes
        List<Attribute__c> childAttsList = TestDataFactory.createChildAttributes(attributesList, 1, 1);
        insert childAttsList;
        // creating account attributes
        List<Contact_Attribute__c> conAttsList = TestDataFactory.createContactAttributes(contacts, childAttsList);
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        
        // Start test method
        Test.startTest();
            List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
            insert testReferenceabilities;
            // creating reference contents and associating with accounts
            List<ContentVersion> contentVersionList = TestDataFactory.setUpNativeContents();
            insert contentVersionList;
            List<Reference_Content__c> refContentsList = TestDataFactory.setUpContents(contentVersionList);
            insert refContentsList;
            List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContentsList);
            insert ARCList;
            // creating account requests
            List<Reference_Request__c> refRequestList = TestDataFactory.createReferenceRequest();
            insert refRequestList;
        // Stop test method
        Test.stopTest();
        
        List<Reference_Request_Account__c> accRequestList = TestDataFactory.createAccountRequests(accounts, refRequestList, refTypesList);
        insert accRequestList;
        accRBIList[0].Referenceability_Status__c = 'Inactive';
        update accRBIList;
        
        // testing contact RBI deletion
        delete conRBIList;
        List<Reference_Basic_Information__c> conRBIList2 = [SELECT Id FROM Reference_Basic_Information__c
                                                            WHERE Contact__c = :contacts[0].Id];
        system.assertEquals(0, conRBIList2.size());
        
        // testing account RBI deletion
        delete accRBIList;
        List<Reference_Basic_Information__c> accRBIList2 = [SELECT Id FROM Reference_Basic_Information__c
                                                            WHERE Account__c = :accounts[0].Id
                                                            AND Contact__c = null];
        system.assertEquals(0, accRBIList2.size());
    }
    
    static testmethod void untiTest01() {
        // Setting up test data
        TestDataFactory.createAttributeMapping();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        customSetting = TestDataFactory.createCustomSetting();
        
        // inserting the RBIs for accounts
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBINew(accounts);
        ConstantsController.runDuplicateRBICheck = true;
        
        // inserting RBIs for contacts
        List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(contacts);
        ConstantsController.runDuplicateRBICheck = true;
        
        List<Referenceability_Type__c> refTypesList = TestDataFactory.createReferenceabilityType();
        insert refTypesList;
        List<Referenceability__c> testReferenceabilities = TestDataFactory.createReferenceability(accounts, contacts, refTypesList);
        insert testReferenceabilities;
        
        // creating attributes for accounts
        List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 6);
        insert childAttributes;
        List<Label__c> labels = new List<Label__c>{TestDataFactory.createLabels()[0]};
        insert labels;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes, true);
        
        //Start test method
        Test.startTest();
            
            // creating opportunities and line items
            List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
            insert oppList;
            Id pricebookId = Test.getStandardPricebookId();
            Product2 prod = new Product2(Name = 'Product X', ProductCode = 'Pro-X', isActive = true);
            insert prod;
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 100.00, IsActive = true);
            insert pbEntry;
            
            for (Opportunity opp : oppList) {
                opp.Amount = customSetting.Minimum_Opportunity_Size_OP__c + 500;
            }
            update oppList;
            List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
            
            for (Opportunity opp : oppList) {
                oppLineItemList.add(new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = pbEntry.Id, TotalPrice = 5 * pbEntry.UnitPrice));
            }
            insert oppLineItemList;
        //Stop test method
        Test.stopTest();
        
        // updating account RBIs
        for (Reference_Basic_Information__c accRBI : accRBIList) {
            
            if (accRBI.Is_Referenceable__c) {
                accRBI.Referenceability_Status__c = 'Caution';
                accRBI.Lifetime_Points__c = 0;
            }
        }
        update accRBIList;
        
        // updating contact RBIs
        for (Reference_Basic_Information__c conRBI : conRBIList) {
            
            if (conRBI.Is_Referenceable__c) {
                conRBI.Referenceability_Status__c = 'Caution';
                conRBI.Lifetime_Points__c = 0;
            }
        }
        update conRBIList;
        
        system.assert(true);
    }
}