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
* Class : SLDSAccountRBIInlineController
* Description : Controller used for Contact RBI inline.  
* Last modified by : Rajesh @07 June 2017
*/
@isTest(seeAllData = false)
public class TestSLDSAccountLevelRULController {
   /**
	* Test Method to GetInfoFields.
	*/
    public static testMethod void testGetInfoFields() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);        
        Test.startTest();
	        String infoFieldsString = SLDSAccountLevelRULController.getInfoFields(accountList.get(0).Id);
	        List<SLDSAccountLevelRULController.FieldWrapper> infoFields = (List<SLDSAccountLevelRULController.FieldWrapper>)JSON.deserialize(infoFieldsString, List<SLDSAccountLevelRULController.FieldWrapper>.class);
	        //check dateFormat
            system.assertNotEquals(SLDSAccountLevelRULController.getDateFormat(),'');
        	system.assertEquals(infoFields.get(0).label, 'Reference Program Candidate');
        Test.stopTest(); 
    }
    
   /**
	* Test Method to GetLimitFields.
	*/
    public static testMethod void testGetLimitFields() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);
        
        Test.startTest();
	        String limitFieldsString = SLDSAccountLevelRULController.getLimitFields(accountList.get(0).Id);
	        List<SLDSAccountLevelRULController.FieldWrapper> limitFields = (List<SLDSAccountLevelRULController.FieldWrapper>)JSON.deserialize(limitFieldsString, List<SLDSAccountLevelRULController.FieldWrapper>.class);
	        system.assertEquals(limitFields.get(0).label, 'Limit Reached');
        Test.stopTest(); 
    }
    
   /**
	* Test Method to GetRewardFields.
	*/
    public static testMethod void testGetRewardFields() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);        
        Test.startTest();
	        String rewardFieldsString = SLDSAccountLevelRULController.getRewardFields(accountList.get(0).Id);
	        List<SLDSAccountLevelRULController.FieldWrapper> rewardFields = (List<SLDSAccountLevelRULController.FieldWrapper>)JSON.deserialize(rewardFieldsString, List<SLDSAccountLevelRULController.FieldWrapper>.class);
	        system.assertEquals(rewardFields.get(0).label, 'Lifetime Points');
        Test.stopTest(); 
    }
    
   /**
	* Test Method to GetExtraFields.
	*/
    public static testMethod void testGetExtraFields() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);
        
        Test.startTest();
	        String extraFieldsString = SLDSAccountLevelRULController.getExtraFields(accountList.get(0).Id);
	        List<SLDSAccountLevelRULController.FieldWrapper> extraFields = (List<SLDSAccountLevelRULController.FieldWrapper>)JSON.deserialize(extraFieldsString, List<SLDSAccountLevelRULController.FieldWrapper>.class);
	        system.assertNotEquals(null, extraFields);
        Test.stopTest();
         
    }
    
   /**
	* Test Method to GetPickList.
	*/
    public static testMethod void testGetPickList() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);        
        Test.startTest();
	        String picklistOptionsString = SLDSAccountLevelRULController.getPickList();
	        List<String> picklistOptions = (List<String>)JSON.deserialize(picklistOptionsString, List<String>.class);
	        system.assertEquals(picklistOptions.get(0), 'Active');
        Test.stopTest(); 
    }
    
   /**
	* Test Method to GetLastSectionHeader.
	*/
    public static testMethod void testGetLastSectionHeader() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);
        
        Test.startTest();
	        String lastSectionHeader = SLDSAccountLevelRULController.getLastSectionHeader();
	        system.assertEquals(lastSectionHeader, 'Client-configured Section Heading');
        Test.stopTest(); 
    }
    
   /**
	* Test Method to GetLookupData.
	*/
    public static testMethod void testGetLookupDataByObjectAndName() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList); 
        Test.startTest();
	        List<sObject> userList = SLDSAccountLevelRULController.getLookupDataByObjectAndName('User');
	        system.assertNotEquals(userList.size(), 0);
        Test.stopTest(); 
    }
    
   /**
	* Test Method to save RBI with positive outcome.
	*/
    public static testMethod void testSaveRBIPositive() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList); 
        Test.startTest();
	        accountRBIList.get(0).Referenceability_Status__c = 'Active';
	        String savedRBIString = SLDSAccountLevelRULController.saveRBIRecords(JSON.serialize(accountRBIList.get(0)), '','');
	        Reference_Basic_Information__c savedRBI = (Reference_Basic_Information__c)JSON.deserialize(savedRBIString, Reference_Basic_Information__c.class);
	        system.assertEquals(savedRBI.Referenceability_Status__c, 'Active');
        Test.stopTest(); 
    }
    
   /**
	* Test Method to save RBI with negative outcome.
	*/
    public static testMethod void testSaveRBINegative() { 
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);        
        Test.startTest();
	        accountRBIList.get(0).Is_Referenceable__c = false;
	        accountRBIList.get(0).Referenceability_Status__c = 'Active';
	        accountRBIList.get(0).Is_Referenceable__c = true;
	        String savedRBIStringNegative = SLDSAccountLevelRULController.saveRBIRecords(JSON.serialize(accountRBIList.get(0)), '','');  
	        Reference_Basic_Information__c savedRBINegative = (Reference_Basic_Information__c)JSON.deserialize(savedRBIStringNegative, Reference_Basic_Information__c.class);
	        system.assertEquals(savedRBINegative.Is_Referenceable__c, true);
        Test.stopTest(); 
    }
    
   /**
	* Test Method to check user set Referenceability Status to "Inactive" and provide its Reason then it will create reference note record.
	*/  
    public static testMethod void testInactiveStatus() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);        
        Test.startTest();
	        accountRBIList.get(0).Referenceability_Status__c = 'Inactive';
	        accountRBIList.get(0).Inactive_Reason__c = 'This is test reason';
	        String savedRBIString = SLDSAccountLevelRULController.saveRBIRecords(JSON.serialize(accountRBIList.get(0)), '','Inactive');
	        Reference_Basic_Information__c savedRBI = (Reference_Basic_Information__c)JSON.deserialize(savedRBIString, Reference_Basic_Information__c.class);
	        List<Reference_Note__c> lstNote = [SELECT Note__c FROM Reference_Note__c]; 
	        system.assertEquals(lstNote.size(), 1);
        Test.stopTest(); 
    }
    
    /**
	 * Test Method to show total reference uses
	 */  
    public static testMethod void testShowTotalReferenceUses() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accountList = TestDataFactory.createAccounts();
        insert accountList;
        
        List<Reference_Basic_Information__c> accountRBIList = TestDataFactory.setUpAccountRBI(accountList);   
        
        List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;     
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accountList, refReqs, refTypes);

        for (Reference_Request_Account__c rra : refReqAccs) {
        	rra.Account_Request_Status__c = 'Completed';
        }
        insert refReqAccs;
        Test.startTest();
	        List<SLDSAccountLevelRULController.RefTypeWrapper> references = SLDSAccountLevelRULController.showTotalReferenceUses(accountList[0].Id);
	        system.assertEquals(4, references.size());
        Test.stopTest(); 
    }
}