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
 * test class for refedge setup page
 * last modified by: Rajesh (14 Nov, 2017) for #1127
 */
@isTest(seeAllData = false)
public with sharing class TestRefedgeSetupHomeController {
    /**
     * Test Method to to Update all fields 
     */
    static testMethod void testUpdateAll() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        Opportunity testOpp = new Opportunity(AccountId = accounts[0].Id, Name = 'Test opportunity 123',
                                                Amount = 1000, StageName = 'Prospecting', CloseDate = Date.today() + 2);
        insert testOpp;
        testOpp.StageName = 'Closed Won';
        update testOpp;
        
        TestDataFactory.setUpAccountRBI(accounts);
        test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.updateReferenceabilityTypes();
            rshc.updateReferenceProfiles();
            rshc.updateReferenceContents();
            rshc.updateReferenceRequestsInvitations();
            rshc.deleteRewards();
            rshc.groupName = 'Customer Reference Team';
            rshc.createPublicGroup();
            rshc.updateContactAvailablePoints();
            rshc.updateFilterNumbers();
            rshc.updateRewardsOnInfluitiveIntegration();
            rshc.psName = 'RE Salesperson';
            rshc.createPermissionSet();
            rshc.upgradeCustomSetting();
            rshc.updateRefLeads();
        test.stopTest();
        List<Group> publicGroups = [SELECT Id FROM Group WHERE Name = :'Customer Reference Team'
                                    LIMIT :limits.getLimitQueryRows()];
                                    
        system.assert(publicGroups.size() > 0);
    }
    
    /**
     * Test Method to to Update Reference Profiles
     */
    static testMethod void testUpdateReferenceProfiles() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.PUM_No_Response_Days__c = 5;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Attribute__c> attributeList = TestDataFactory.createAttribute();
        attributeList[0].Level__c = 2;
        System.debug('attributes'+attributeList);
        insert attributeList;
        
        TestDataFactory.setUpAccountRBI(accounts);
        test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.updateAccountContactRequests();
            rshc.updateFilters();
            rshc.updateAttributes();
            rshc.updateProfileUpdates();
        rshc.isUpdateReferenceabilityTypes = false;
        rshc.updateReferenceProfiles();
        test.stopTest();
        List<Group> publicGroups = [SELECT Id FROM Group WHERE Name = :'Customer Reference Team'
                                    LIMIT :limits.getLimitQueryRows()];
        system.assert(publicGroups.size() > 0);
    }
    
    /**
     * Test Method to to Update Create Sales RefTypes
     */
    static testMethod void testUpdateCreateSalesRefTypes() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.updateCreateSalesRefTypes();
            List<Referenceability_Type__c> refTypesList = [SELECT Referenceability_code__c, Name, Id FROM Referenceability_Type__c 
                                                            WHERE Visible__c = true AND Referenceability_code__c != null];
            system.assertEquals(ConstantsController.INVITATION_TO_CO_WORKER, refTypesList[0].Referenceability_code__c);
        Test.stopTest();
    }
    
    /**
     * Test Method to to Update Create Sales RefTypes With Record
     */
    static testMethod void testUpdateCreateSalesRefTypesWithRecordUpdate() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Test.startTest();
            List<Referenceability_Type__c> rfTypes = new List<Referenceability_Type__c>();
            rfTypes.add(new Referenceability_Type__c(Name = 'Invitation to Co-Worker', Referenceability_code__c = ConstantsController.INVITATION_TO_CO_WORKER, Sales_Reward__c = true, Sales_Point__c = 2, Visible__c  = false));
            insert rfTypes;
            
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.updateCreateSalesRefTypes();
            List<Referenceability_Type__c> refTypesList = [SELECT Referenceability_code__c, Name, Id
                                                            FROM Referenceability_Type__c 
                                                            WHERE Visible__c = true AND Referenceability_code__c != null];
            system.assertEquals(ConstantsController.INVITATION_TO_CO_WORKER, refTypesList[0].Referenceability_code__c);
        Test.stopTest();
    }
    
    /**
     * Test Method to Update Rewards On Influitive Integration
     */
    static testMethod void testUpdateRewardsOnInfluitiveIntegration() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Is_Influitive_Integration_Enabled__c = true;
        upsert customSetting;
        system.assertEquals(true, customSetting.Is_Influitive_Integration_Enabled__c);
        Test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.updateRewardsOnInfluitiveIntegration();
            POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();            
        Test.stopTest();
    }
    
    /**
     * Test Method to Update Profile Updates
     */
    static testMethod void testUpdateProfileUpdates() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.PUM_No_Response_Days__c = 2;
        upsert customSetting;
        Test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.updateProfileUpdates();
            customSetting.PUM_No_Response_Days__c = 0;
            upsert customSetting;
            POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
            system.assertEquals(true, appConfig.Update_Profile_Updates__c);
            rshc.updateProfileUpdates();
            upsert customSetting;
        Test.stopTest();
    }
    
    /**
     * Test Method to Update Contact Attributes
     */
    static testMethod void testUpdateContactAttributes() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.updateContactAttributes();
            POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults();
            system.assertEquals(true, appConfig.Update_Account_in_Contact_Attributes__c);
        test.stopTest();
    }
    
    /**
     * Test Method to GetDeploy Xml
     */
    static testMethod void testGetDeployXml() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController(); 
            String RSSDeployString = rshc.getDeployXml();
            system.assertNotEquals('', RSSDeployString);
        test.stopTest();
    }
    
    /**
     * Test Method to Update Account and Contact Related AttributeMappings
     */
    static testMethod void testUpdateAccConRelatedAttributeMappings() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        TestDataFactory.createRelatedAttributeMappingAccount();
       
        test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();          
            rshc.updateAccConRelatedAttributeMappings(); 
            List<Attribute_Mapping__c> attMapping = [SELECT Id  FROM Attribute_Mapping__c  WHERE Object__c = 'Reference Profile' LIMIT : limits.getLimitQueryRows()]; 
        test.stopTest();
        system.assertEquals(attMapping.size(), 2);  
    } 
    
    /**
     * Test Method to Update RBI points
     */
    static testMethod void testUpdateRBIPoint() {        
        test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();  
            rshc.updateRBIPoint(); 
            POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults(); 
        test.stopTest();
        system.assertEquals(appConfig.Update_Current_Available_Points_for_RBI__c, true);
    } 
    
    /**
     * Test Method to Update Inheritable Attributes
     */
    static testMethod void testUpdateInheritableAttributes() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        TestDataFactory.createRelatedAttributeMappingAccount();
        
        test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();      
            rshc.updateInheritableAttributes(); 
            rshc.scheduleJobs();
            POR_App_Configuration__c appConfig = POR_App_Configuration__c.getOrgDefaults(); 
            system.assertEquals(appConfig.Update_Inheritable_Value_in_Attributes__c, true);  
        test.stopTest();
    }  
    
    /**
     * Test Method to create reference activities for nomination re #1127
     */
    static testMethod void testcreateReferenceActivities() { 
        List<Data_Mapping__c> mapDataMapping = new List<Data_Mapping__c>();
        //Create referenceability Type 
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes; 
        
        //Create data mapping for nomination 
        List<Data_Mapping__c> dmList = new List<Data_Mapping__c>();
        Data_Mapping__c dm = new Data_Mapping__c(Name = refTypes[0].Name, Referenceability_Type__c = refTypes[0].Id, Visible__c = true, 
                                                             Object__c = ConstantsController.NOMINATION_REFERENCEABILITY);
        dmList.add(dm);
        
        Test.startTest();
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.createReferenceActivities();
            mapDataMapping = [SELECT Referenceability_Type__c FROM Data_Mapping__c WHERE Object__c = :ConstantsController.NOMINATION_REFERENCEABILITY 
                                                    AND Visible__c = true LIMIT :limits.getLimitQueryRows()]; 
            system.assertEquals(5, mapDataMapping.size());
        Test.stopTest();
    }
    
    /**
     * Test Method to create reference activities for nomination re #1184
     */
    static testMethod void testupdateAttributeInRefContent() { 
        Test.startTest();
        RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
        rshc.updateAttributeInRefContent();
        system.assertNotEquals(null,rshc);
        Test.stopTest();
    }
    
    /**
     * Rajneesh Raj (Jan 10, 2019)
     */
    static testMethod void testUnitMethod() { 
        Test.startTest();

            list<Attribute_Mapping__c> attMap = TestDataFactory.createAttributeMapping();
            attMap[0].Auto_populate__c = false;
            attMap[0].Object__c = ConstantsController.OPPORTUNITY;
            attMap[0].Related_Object__c = ConstantsController.OPPORTUNITYLINEITEM;
            attMap[0].Mapping_Type__c	= 'Child Object';
            update attMap;
            List<Attribute__c> attriList = TestDataFactory.createAttribute();
            attriList[0].Level__c = 0;
            attriList[0].Attribute_Mapping__c = attMap[0].Id;
            insert attriList;
            system.assertEquals(false, attMap[0].Auto_populate__c);
            RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
            rshc.resetOpportunityProductAM();
            rshc.resetColumnSelector();
            List<Account> accList = TestDataFactory.createAccounts();
            insert accList;
            List<Contact> conList = TestDataFactory.createContacts(accList);
            insert conList;
            List<Reference_Basic_Information__c> conRBIList = TestDataFactory.setUpContactRBI(conList);
            List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accList);
            system.assert(accRBIList.size() > 0, 'Size is :- '+accRBIList.size());
            rshc.removeDuplicateRBIs();
            rshc.updateUpdateFilterIdInRootAttributeForProduct();       
        Test.stopTest();
    }

    /**
     * Complete code coverage is not possible because duplicate RBIs cannot be created with code
     * REF-1259
     */
    @isTest static void testRemoveDuplicateRBIs() {        
        Test.startTest();
        RefedgeSetupHomeController rshc = new RefedgeSetupHomeController();
        rshc.removeDuplicateRBIs();
        system.assertNotEquals(null,rshc);
        Test.stopTest();
    }
}