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
 * Class : ContactRBIInlineController
 * Description : Controller used for Contact RBI inline.  
 * Last modified by : Rajesh @21 Apr 2017
 */
@isTest(seeAllData = false)
public class TestContactRBIInlineController {
    
    /**
     * Test Method to check user set Referenceability Status to "Active".
     */
    public static testMethod void testActiveStatus() {        
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account account = new Account(Name = 'testAccount');
        insert account;
        
        Contact contact = new Contact(LastName='test Contact', AccountId = account.Id);
        insert contact;
        
        //Start test method
        Test.startTest();
            PageReference pageRef = Page.AccountLevelRULPage;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(contact);
            ContactRBIInlineController alrc = new ContactRBIInlineController(sc);
            alrc.editRBI();
            alrc.RBI.Is_Referenceable__c = true;
            alrc.RBI.Referenceability_Status__c = 'Active';
            alrc.saveRBI();
            system.assertEquals(alrc.RBI.Is_Referenceable__c, true);
        //Stop test method
        Test.stopTest(); 
    }

    /**
     * Test Method to check user set Referenceability Status to "Active" with created RBI.
     */
    public static testMethod void testActiveStatusWithRBI() {       
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account account = new Account(Name = 'testAccount');
        insert account;
        
        Contact contact = new Contact(LastName='test Contact', AccountId = account.Id);
        insert contact;
        
        insert new Reference_Basic_Information__c(Account__c = contact.AccountId, Contact__c = contact.Id);
        //Start test method
        Test.startTest();
            PageReference pageRef = Page.AccountLevelRULPage;
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.standardController(contact);
            ContactRBIInlineController alrc = new ContactRBIInlineController(sc);
            alrc.RBI.Is_Referenceable__c = false;
            alrc.RBI.Referenceability_Status__c = 'Active';
            alrc.saveRBI();
            alrc.RBI.Is_Referenceable__c = true;
            alrc.saveRBI();
            system.assertEquals(alrc.RBI.Is_Referenceable__c, true);
            alrc.cancelRBI();
        //Stop test method
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
		//Creating Contact
		Contact contact = new Contact(LastName='test Contact', AccountId = account.Id);
		insert contact;
		
		//Start test method
		Test.startTest();
		    PageReference pageRef = Page.AccountLevelRULPage;
		    Test.setCurrentPage(pageRef);
		    ApexPages.StandardController sc = new ApexPages.standardController(contact);
		    ContactRBIInlineController alrc = new ContactRBIInlineController(sc);
		    alrc.editRBI();
		    alrc.RBI.Is_Referenceable__c = true;
		    alrc.RBI.Referenceability_Status__c = 'Inactive';
		    alrc.RBI.Inactive_Reason__c = 'This is test reason'; 
		    alrc.saveRBI();
		    List<Reference_Note__c> lstNote = [SELECT Note__c FROM Reference_Note__c WHERE Contact__c = : contact.Id];
		     
		    system.assertEquals(lstNote.size(), 1);
		//Stop test method
		Test.stopTest();         
    }
}