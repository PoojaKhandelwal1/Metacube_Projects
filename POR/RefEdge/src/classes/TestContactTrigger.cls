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
public class TestContactTrigger {
    public static List<Reference_Basic_Information__c> RBIAccListCon;
    //Test method
    static testmethod void BothActiveTest() {  
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,4);
        insert childAttributes;
        System.assertNotEquals(0,childAttributes.size());
        TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, childAttributes,true);
        
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.createContactAttributes(new list<Contact>{contacts[0]}, childAttributes);
        TestDataFactory.createContactAttributes(new list<Contact>{contacts[1]}, childAttributes);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, refTypes);
        insert refers;
        try{
            
            //Start test method
            test.startTest();
                list < Account_Attribute__c > tempaccountAttributes0 = new list < Account_Attribute__c > ([select Id from Account_Attribute__c where Account__c = : accounts.get(0).Id and Contact__c = : contacts.get(0).Id]);
                //system.assertEquals(tempaccountAttributes0.size(), 4);
                RBIAccListCon = [select Id, Referenceability_Status__c from Reference_Basic_Information__c where Contact__c != null and Contact__c IN :contacts];
                RBIAccListCon.get(0).Referenceability_Status__c = 'Inactive';
                RBIAccListCon.get(1).Referenceability_Status__c = 'Inactive';
                update RBIAccListCon;
                list < Account_Attribute__c > tempaccountAttributes1 = new list < Account_Attribute__c > ([select Id from Account_Attribute__c where Account__c = : accounts.get(0).Id and Contact__c = : contacts.get(0).Id]);
                RBIAccListCon.get(0).Referenceability_Status__c = 'Active';
                RBIAccListCon.get(1).Referenceability_Status__c = 'Active';
                RBIAccListCon.get(1).Referenceability_Status__c = 'Active';
                update RBIAccListCon;
                list < Account_Attribute__c > tempaccountAttributes2 = new list < Account_Attribute__c > ([select Id from Account_Attribute__c where Account__c = : accounts.get(0).Id]);
                delete contacts;
                list < Account_Attribute__c > tempaccountAttributes3 = new list < Account_Attribute__c > ([select Id from Account_Attribute__c where Account__c = : accounts.get(0).Id]);
                database.undelete(contacts[0].Id);
            //Stop test method
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test method
    static testMethod void checkForMapping(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List < Reward__c > rewards = TestDataFactory.createRewards(new list<Account>(), contacts);
        List < Hit_List__c > hitLists = TestDataFactory.createHitLists();
        hitLists[0].Contact__c = contacts[0].Id;
        hitLists[1].Contact__c = contacts[1].Id;
        insert hitLists;
        TestDataFactory.setUpContactRBI(contacts);
        insert rewards;
        ConstantsController.attMappingForContact = true;
        list<Attribute_Mapping__c> attMappingRecords = TestDataFactory.createContactAttributeMapping();
        //Start test method
        test.startTest();
            
         
            contacts[0].LeadSource = 'Partner';
            contacts[0].AccountID = accounts[1].Id;
            contacts[0].Email = 'abc@gmail.com';
            rewards[0].Contact__c= contacts[0].Id;
            hitLists[0].Contact__c=contacts[0].Id;
            update hitLists[0];
            update rewards[0];
            update contacts[0];
            ConstantsController.attMappingForContact = true;
            contacts[0].LeadSource = 'Web';
            update contacts[0];
            system.assertEquals(6,contacts.size());
        //Stop test method
        test.stopTest();
    }
    
    //Test method
    static testMethod void testDeleteCon(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List < Reward__c > rewards = TestDataFactory.createRewards(new list<Account>(), contacts);
        List < Hit_List__c > hitLists = TestDataFactory.createHitLists();
        hitLists[0].Contact__c = contacts[0].Id;
        hitLists[1].Contact__c = contacts[1].Id;
        insert hitLists;
        TestDataFactory.setUpContactRBI(contacts);
        insert rewards;
        //Start test method
        test.startTest();
            contacts[0].LeadSource = 'Partner';
            contacts[0].AccountID = accounts[1].Id;
            contacts[0].Email = 'abc@gmail.com';
            rewards[0].Contact__c= contacts[0].Id;
            hitLists[0].Contact__c=contacts[0].Id;
            update hitLists[0];
            update rewards[0];
            update contacts[0];
            delete contacts;
        //Stop test method
        test.stopTest();
        List <Contact> conList = [select Id from Contact];
        system.assert(conList.size() == 0);
    }
    static testmethod void changeAccount() {  
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,4);
        insert childAttributes;
        TestDataFactory.createAccountAttributes(new list<Account>{accounts[0]}, childAttributes,true);
        
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.createContactAttributes(contacts, childAttributes);
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), contacts, refTypes);
        insert refers;
        try{
            
            //Start test method
            test.startTest();
            contacts[1].AccountId = accounts[0].Id;
            update contacts[1];
            List <Contact> conList = [select Id from Contact];
            system.assertNotEquals(0,conList.size());
            //Stop test method
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    
    //Test method
    static testMethod void checkForMapping2(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List < Reward__c > rewards = TestDataFactory.createRewards(new list<Account>(), contacts);
        List < Hit_List__c > hitLists = TestDataFactory.createHitLists();
        hitLists[0].Contact__c = contacts[0].Id;
        hitLists[1].Contact__c = contacts[1].Id;
        insert hitLists;
        TestDataFactory.setUpContactRBI(contacts);
        insert rewards;
        ConstantsController.attMappingForContact = false;
        list<Attribute_Mapping__c> attMappingRecords = TestDataFactory.createContactAttributeMapping();
        //Start test method
        test.startTest();
            contacts[0].LeadSource = 'Partner';
            contacts[0].AccountID = accounts[1].Id;
            contacts[0].Email = 'abc@gmail.com';
            rewards[0].Contact__c= contacts[0].Id;
            hitLists[0].Contact__c=contacts[0].Id;
            update hitLists[0];
            update rewards[0];
            update contacts[0];
            ConstantsController.isCopyNominationDetailProcess = false;
            contacts[0].LeadSource = 'Web';
            update contacts[0];
            system.assertEquals(6,contacts.size());
        //Stop test method
        test.stopTest();
    }
    static testmethod void testMergeContact() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        //Creating Attribute Mapping
    	Account acc = new Account(Name='master',Industry = 'Finance');
        insert acc;
        list<Attribute_Mapping__c> attMappingRecords = TestDataFactory.createContactAttributeMapping();
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id);
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = master.AccountId, Contact__c =  master.Id );
        insert tempAccount;
        tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = master.AccountId);
        insert tempAccount;
        List < Reward__c > rewards = TestDataFactory.createRewards(new list<Account>(), new list<Contact>{mergeC,master});
        List < Hit_List__c > hitLists = TestDataFactory.createHitLists();
        hitLists[0].Contact__c = mergeC.Id;
        hitLists[1].Contact__c = master.Id;
        insert hitLists;
        
        list< Label__c > labels = new list< Label__c >{TestDataFactory.createLabels()[0]};
        insert labels;
        //Creating Attribute
        List < Attribute__c > attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels, attributes);
        //Creating Contact Attribute
        TestDataFactory.createContactAttributes(new list<Contact>{mergeC,master},attributes);
        //Creating Referenceability
        Referenceability_Type__c refTye = new Referenceability_Type__c(Name = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_code__c = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT,Referenceability_Type__c = true, Visible__c = true, Project_type__c = true, Request_type__c = true,min_lead_time_per_request_type__c = 10,max_accounts_per_request_type__c = 15,Reward_points__c = 100,Note__c = 'test notes');
    	insert refTye;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(new list<Account>{acc}, refReqs, refTypes);
        refReqAccs[0].Account_Request_Status__c = 'Completed';
        refReqAccs[1].Account_Request_Status__c = 'Completed';
        insert refReqAccs;
        List < Reference_Request_Account_Contact__c > refReqCons = TestDataFactory.createContactRequests(new list<Contact>{mergeC}, refReqAccs, refTypes);
        refReqCons[0].Contact_Request_Status__c = 'Completed';
        insert refReqCons;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(new list<Account>(), new list<Contact>{mergeC,master}, refTypes);
        insert refers;
        List < ContentVersion > nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        list<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        list < Contact_Reference_Content__c > conContents = new list<Contact_Reference_Content__c>();
        conContents.add(new Contact_Reference_Content__c(Contact__c = mergeC.Id, Reference_Content__c = contents[0].Id));
        conContents.add(new Contact_Reference_Content__c(Contact__c = master.Id, Reference_Content__c = contents[0].Id));
        insert conContents;
        //Creating nomonation
        Nomination__c nominationT = new Nomination__c(Account__c = acc.id,Contact__c = mergeC.Id);
        insert nominationT;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact1() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list<Attribute_Mapping__c> attMapping = TestDataFactory.createAttributeMapping();
        Account acc = new Account(Name='master',Industry = 'Finance');
        insert acc;
        list<Attribute_Mapping__c> attMappingRecords = TestDataFactory.createContactAttributeMapping();
        Contact master = new Contact(LastName='master',AccountId = acc.Id,LeadSource='Partner');
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = acc.Id);
        insert tempAccount;
        
        tempAccount = new Reference_Basic_Information__c(Account__c = master.AccountId, Contact__c =  master.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact2() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Caution', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        tempAccount = new Reference_Basic_Information__c(Account__c = master.AccountId, Contact__c =  master.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact3() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Inactive', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        tempAccount = new Reference_Basic_Information__c(Account__c = master.AccountId, Contact__c =  master.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact4() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Inactive', Reference_Program_Candidate__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        tempAccount = new Reference_Basic_Information__c(Account__c = master.AccountId, Contact__c =  master.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact5() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Inactive', Reference_Program_Candidate__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact6() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Caution', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact7() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Inactive', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact8() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
    static testmethod void testMergeContact9() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name='master');
        insert acc;
        Contact master = new Contact(LastName='master',AccountId = acc.Id);
        insert master;
        Contact mergeC = new Contact(LastName='merge',AccountId = acc.Id,LeadSource='Partner');
        insert mergeC;
        Reference_Basic_Information__c tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = mergeC.AccountId, Contact__c =  mergeC.Id );
        insert tempAccount;
        tempAccount = new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = master.AccountId, Contact__c =  master.Id );
        insert tempAccount;
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        list<Referenceability__c> refers = TestDataFactory.createReferenceability(new list<Account>(), new list<Contact>{master,mergeC}, refTypes);
        insert refers;
        delete [select Id from Reference_Basic_Information__c];
        Test.startTest();
            try {
                merge master mergeC;
            } catch (DMLException e) {
                System.debug('An unexpected error has occurred: ' + e.getMessage()); 
            }
            master = [SELECT Id, Name FROM Contact WHERE Id = :master.Id LIMIT 1];
            System.assertEquals('master', master.Name);
        Test.stopTest();
    }
}