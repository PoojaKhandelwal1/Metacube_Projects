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
 * Class: AddAssociatedRefContentController
 * Description: class to Test AND cover AddAssociatedRefContentController
 * Modified by: Rajesh @20 July 2017
 */
@isTest
private class TestAddAssociatedRefContentController {
	public static User u;
    public static Profile p;
    public static Blob blobfile;
    public static ContentVersion cv;
    public static String fileName;
    public static Reference_Content__c referObject;
    public static Reference_Content_Type__c customRefContent;
	public static AddNewReferenceContentController controllerObj;
	
	/**
     * Method to cover all method and Constructor 
     */
     static testMethod void testSaveContentMethodForNewForCustomContent(){
    	CreateUser();
    	test.startTest();
        system.runAs(u) {
        	// Insert Values
        	POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        	insert cs;
        	Account testAccount = new Account(); 
        	testAccount.Name='Test Account'; 
        	insert testAccount; 
 
        	Contact cont = new Contact(); 
        	cont.FirstName='Test '; 
        	cont.LastName='Contact'; 
        	cont.Accountid= testAccount.id; 
        	insert cont;
        	
        	// Insert Ref Content 
        	customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
        	insert customRefContent;
        	Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true);
        	insert tempObj;
        	
        	/*Case for only Save*/        	
        	Id contentId = tempObj.id;    
        	PageReference rfPage = new PageReference('AddAssociatedAccountsAndContacts');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('refConId',contentId); 
        	AddAssociatedRefContentController assocationController = new AddAssociatedRefContentController();
        	assocationController.accountIds = String.Valueof(testAccount.id); 
        	assocationController.contactIds = String.Valueof(cont.id);
        	assocationController.isSaveAndNew = false;
        	assocationController.save();
        	List<Account_Reference_Content__c> lstAccRef = [SELECT Account__c, Account__r.Name FROM Account_Reference_Content__c  WHERE Reference_Content__c =: contentId];
        	system.assertEquals(lstAccRef.size(), 1);
        	
        	assocationController.reBindContact();
        	assocationController.reBindAccount();
        	
        	/*Case for Save and New*/ 
        	// Insert Values
        	testAccount = new Account(); 
        	testAccount.Name='Test Account1'; 
        	insert testAccount; 
 			
        	cont = new Contact(); 
        	cont.FirstName='Test2 '; 
        	cont.LastName='Contact2'; 
        	cont.Accountid= testAccount.id; 
        	insert cont;
         	rfPage = new PageReference('AddAssociatedAccountsAndContacts');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('refConId',contentId); 
        	assocationController = new AddAssociatedRefContentController();
        	assocationController.isNewAccount = false; 
        	assocationController.accountIds = String.Valueof(testAccount.id); 
        	assocationController.isNewContact = false;
        	assocationController.contactIds = String.Valueof(cont.id);
        	assocationController.isSaveAndNew = true;
        	assocationController.save();
        	system.assertEquals(lstAccRef.size(), 1);
        	
        	/*Remove Account*/
        	assocationController.accountIds = String.Valueof(testAccount.id);   
        	assocationController.removeAssociatedAccount();
        	
        	/*Remove Account*/
        	assocationController.accountIds = String.Valueof(testAccount.id);
        	assocationController.selectedAccountId = testAccount.id; 
        	assocationController.removeAssociatedAccount();
        	
        	List<Account_Reference_Content__c> lstAcc = [SELECT Account__c, Account__r.Name FROM Account_Reference_Content__c  WHERE Account__c =: testAccount.id];
        	system.assertEquals(lstAcc.size(), 0);
        	
        	/*Remove Contact*/
        	assocationController.contactIds = String.Valueof(cont.id);   
        	assocationController.removeAssociatedContact();
        	
        	/*Remove Account*/
        	assocationController.contactIds = String.Valueof(cont.id);
        	assocationController.selectedContactId = cont.id; 
        	assocationController.removeAssociatedContact();
        	
        	List<Contact_Reference_Content__c> lstCon = [SELECT Contact__c FROM Contact_Reference_Content__c  WHERE Contact__c =: cont.id];
        	system.assertEquals(lstCon.size(), 0);
        	
        	
        	/*Case for Exeption*/  
        	assocationController = new AddAssociatedRefContentController();
        	assocationController.accountIds = ''; 
        	assocationController.contactIds = '';
        	assocationController.isSaveAndNew = false;
        	assocationController.save(); 
        	ApexPages.Message[] pageMessages = ApexPages.getMessages(); 
			System.assertNotEquals(0, pageMessages.size());
        	
        	/*Case for Exception*/ 
        	assocationController = new AddAssociatedRefContentController(); 
        	assocationController.isSaveAndNew = null;
        	assocationController.accountIds = null;
        	assocationController.save(); 
        	pageMessages = ApexPages.getMessages(); 
			System.assertNotEquals(0, pageMessages.size());
			
        }
        test.stopTest();
	}
   	
	/**
     * Method to test Account test search
     */
   	static testMethod void testSaveContentMethodForSearchText(){
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        accounts[1].Name = 'UCO Bank';
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            Account_Reference_Content__c accReferObject = new Account_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
           	PageReference rfPage = new PageReference('AddAssociatedAccountsAndContacts');
            Test.setCurrentPage(rfPage);
           	ApexPages.currentPage().getParameters().put('refConId',referObjects[0].Id); 
        	AddAssociatedRefContentController assocationController = new AddAssociatedRefContentController();
            
            assocationController.accName = accounts[0].Name;
            PageReference pg = assocationController.save();
            assocationController.accName = accounts[2].Name + ' Test ';
            pg = assocationController.save();
            List<Account_Reference_Content__c> lst = [SELECT Id FROM Account_Reference_Content__c WHERE Account__c = :accounts[2].Id];
            system.assertNotEquals(null, lst);
        //Stop Test method
        Test.stopTest();
   	}
   	
   	/**
     * Method to test contact text search
     */
   	static testMethod void testSaveContentMethodForContactSearchText(){
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
    	insert accounts;
    	List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
    	List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
    	insert referObjects;
        //Start test Method
        test.startTest();
        	referObjects = [SELECT Name FROM Reference_Content__c WHERE Id IN : referObjects];
	        PageReference rfPage = new PageReference('AddAssociatedAccountsAndContacts');
            Test.setCurrentPage(rfPage);
           	ApexPages.currentPage().getParameters().put('refConId',referObjects[0].Id); 
        	AddAssociatedRefContentController assocationController = new AddAssociatedRefContentController();
        	
            assocationController.conName = 'test';
            PageReference pg = assocationController.save();
            assocationController.conName = '';
            pg = assocationController.save();
            assocationController.conName = 'RC-00';
	        pg = assocationController.save();
	        List<Account_Reference_Content__c> lst = [SELECT Id FROM Account_Reference_Content__c];
            system.assertNotEquals(null, lst);
	       
        //Stop test method
        test.stopTest();
   	}
     
     //Craetion of user
    private static void CreateUser() {
        p = [select id from profile where name like '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
    }
     
}