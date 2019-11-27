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
 * Class : AccountLevelRULController
 * Description : Controller used for Account RBI inline.  
 * Last modified by : Rajesh @21 Apr 2017
 */ 
@isTest(SeeAllData=false)
public class TestAccountLevelRULController {
	/**
     * Test Method to check controller
     */
   	@istest
    public static void testcontroller(){
    	List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        
    	PageReference pageRef = Page.sf1_AccountNominationForm;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(accounts[0]);
    	InlinePageNavigationController obj = new InlinePageNavigationController(sc);
    	
    	system.assertEquals(obj.isSLDS, false);
    }
    
    /**
     * Test Method to check user set Referenceability Status to "Active" with Account RUL value .
     */
    public static testMethod void testActiveStatusWithAccountRULValue() {	 
		Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        //Start test method
        Test.startTest();
            PageReference pageRef = Page.AccountLevelRULPage;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(accounts[0]);
            AccountLevelRULController alrc = new AccountLevelRULController(sc);
            alrc.editRBI();
            alrc.RBI.Is_Referenceable__c = true;
            alrc.RBI.Referenceability_Status__c = 'Active';
            alrc.saveRBI();
            alrc.accountLevelRULValue = 'true';
            alrc.updateAccount();
            system.assertEquals(alrc.RBI.Account_Level_RUL__c, true);
        //Stop test method
        Test.stopTest();
		 
    }

    /**
     * Test Method to check user set Referenceability Status to "Active" with RBI .
     */ 
    public static testMethod void testActiveStatusWithRBI() {         
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        insert new Reference_Basic_Information__c(Account__c = accounts[1].Id);
        
        Test.startTest();
            PageReference pageRef = Page.AccountLevelRULPage;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(accounts[1]);
            AccountLevelRULController alrc = new AccountLevelRULController(sc);
            alrc.RBI.Is_Referenceable__c = true;
            alrc.RBI.Reference_Program_Candidate__c = true;
            alrc.RBI.Referenceability_Status__c = 'Active';
            alrc.saveRBI();
            alrc.RBI.Is_Referenceable__c = true;
            alrc.saveRBI();
            alrc.accountLevelRULValue = 'false';
            alrc.updateAccount();
            system.assertEquals(alrc.RBI.Account_Level_RUL__c, false);
            alrc.cancelRBI();
        Test.stopTest();       
    }
    
    /**
     * Test Method to check user set Referenceability Status to "Active" .
     */ 
    public static testMethod void testActiveStatus() {        
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Case> caseList = TestDataFactory.createCases(new List<Account> { accounts[0] });
        caseList[0].AccountId = accounts[0].id; 
        caseList.add(TestDataFactory.createCases(new List<Account> { accounts[0] }).get(0));
        caseList[1].AccountId = null;
        insert caseList;
        Test.startTest();
            PageReference pageRef = Page.AccountLevelRULPage;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(caseList[0]);   
            AccountLevelRULController alrc = new AccountLevelRULController(sc);
            
            alrc.RBI.Is_Referenceable__c = false;
            alrc.RBI.Referenceability_Status__c = 'Active';
            alrc.saveRBI();
            alrc.RBI.Is_Referenceable__c = true;
            alrc.saveRBI();
            alrc.accountLevelRULValue = 'false';
            alrc.updateAccount();
            system.assertEquals(alrc.RBI.Account_Level_RUL__c, false);
            alrc.cancelRBI();
            ApexPages.StandardController scNoAccount = new ApexPages.standardController(caseList[1]);   
            AccountLevelRULController alrcNoAccount = new AccountLevelRULController(scNoAccount);
            system.assertEquals(alrcNoAccount.isAccountExist, false);
        Test.stopTest();         
    }
    
    /**
     * Test Method to check user set Referenceability Status to "Inactive" and provide its Reason then it will create reference note record.
     */  
    public static testMethod void testInactiveStatus() {      
    	//Creating Custom Setting Data
		Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
		//Creating Account
		Account account = new Account(Name = 'testAccount');
		insert account;
		 
		//Start test method
		Test.startTest();
		    PageReference pageRef = Page.AccountLevelRULPage;
		    Test.setCurrentPage(pageRef);
		    ApexPages.StandardController sc = new ApexPages.standardController(account);
		    AccountLevelRULController alrc = new AccountLevelRULController(sc);
		    alrc.editRBI();
		    alrc.RBI.Is_Referenceable__c = true;
		    alrc.RBI.Referenceability_Status__c = 'Inactive';
		    alrc.RBI.Inactive_Reason__c = 'This is test reason'; 
		    alrc.saveRBI();
		    List<Reference_Note__c> lstNote = [SELECT Note__c FROM Reference_Note__c WHERE Account__c = : account.Id];
		     
		    system.assertEquals(lstNote.size(), 1);
		//Stop test method
		Test.stopTest();         
    }
}