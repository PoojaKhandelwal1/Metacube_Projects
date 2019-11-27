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
 * Class : InvitationSLDSController
 * Description :Test class for Invitation Lightning
 * Modified by: Rajesh @03 June 2017
 */ 
@isTest(seeAllData = false) 	
public with sharing class TestInvitationSLDSController {
	/**
  	 * Test Method for invitation controller
  	 */   
      //Unit Test Method
	static testMethod void TestContorller() {
      	//Start test method 
 		Microsite__c microsite = new Microsite__c(Name = 'test1', Available_for_Use__c = true);
      	insert microsite;
      	
      	microsite = new Microsite__c(Name = 'test2', Available_for_Use__c = true);
      	insert microsite;
      	
      	List<Microsite__c> microsites = new List<Microsite__c>();
        microsites=[SELECT Id, Name FROM Microsite__c WHERE Available_for_Use__c = true];
        
        test.startTest();
       
        system.assertEquals(InvitationSLDSController.getMicrositesList().size(),microsites.size()+1);
        // check Data Format
        system.assertNotEquals(InvitationSLDSController.getDateFormat(),''); 	
        test.stopTest();
   	}    
	
	/**
  	 * Test Method for get Email List
  	 */
	public static testMethod void testgetEmailList() {
		InvitationSLDSController invCtrl = new InvitationSLDSController();
		string selectedRefContents = invCtrl.selectedRefContents;
		string opportunity = invCtrl.opportunity;
		string caseId = invCtrl.caseId;
		boolean forContent = invCtrl.forContent;
		boolean forAccount = invCtrl.forAccount;
		string leadId = invCtrl.leadId;
		
		List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        contacts[0].email = 'abc@abc.abc';
        insert contacts;
        
        User usr = TestDataFactory.createUser();
        usr.email = 'abc1@abc1.abc1';
        insert usr;
        List<InvitationSLDSController.EmailRequestWrapper> emailWrapperList = InvitationSLDSController.getEmailList();
        system.assertNotEquals(emailWrapperList.size(), 0);
	}
	 
	/**
  	 * Test Method for get Email List on key words
  	 */
	public static testMethod void testgetEmailSearchList() { 
		List<Account> accounts = TestDataFactory.createAccounts();		
        insert accounts;
         
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        contacts[0].email = 'abc@abc.abc';
        contacts[0].LastName = 'TestContact';
        insert contacts;
        
        User usr = TestDataFactory.createUser();
        usr.email = 'abc1@abc1.abc1'; 
        insert usr; 
        
        List<InvitationSLDSController.EmailRequestWrapper> emailWrapperList = InvitationSLDSController.getEmailSearchList('abc');
        
        system.assertEquals(emailWrapperList.size(),2);       
	}
	
	/**
  	 * Test Method for set DefaultTemplate
  	 */
	public static testMethod void testSetDefaultTemplate() {
		Microsite__c microsite = new Microsite__c(Name = 'test1', Available_for_Use__c = true);
      	insert microsite;
      	
      	microsite = new Microsite__c(Name = 'test2', Available_for_Use__c = true);
      	insert microsite;
      	
      	List<Microsite__c> microsites = new List <Microsite__c>();
        microsites = [SELECT Id, Name FROM Microsite__c WHERE Available_for_Use__c = true];
        Boolean setDefaultTemplateResult = InvitationSLDSController.setDefaultTemplate(microsites[0].Id);
        system.assert(setDefaultTemplateResult);
	}
	
	/**
  	 * Test Method for getPageInputs method used  on page load 
  	 */
	public static testMethod void testgetPageInputs() {
		List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
		List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
		List<InvitationSLDSController.PageInputWrapper> pageInputList = InvitationSLDSController.getPageInputs(oppList[0].Id, '');
		system.assertEquals(pageInputList, null);
		insert oppList;
		
		List<InvitationSLDSController.PageInputWrapper> pageInput = InvitationSLDSController.getPageInputs(oppList[0].Id, '');
		system.assertNotEquals(pageInput.size(), 0);
	}
	
	/**
  	 * Test Method for create invitation
  	 */ 
	public static testMethod void testcreateInvitation() {
		Custom_Settings__c cs = TestDataFactory.createCustomSetting();
		RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        
        if (protectedAppConfig.Microsite_Key__c == null || protectedAppConfig.Microsite_Key__c == '') {
            
            if (protectedAppConfig.Current_Package_Date__c == null) {
                protectedAppConfig.Current_Package_Date__c = Datetime.now();
            }
            protectedAppConfig.Microsite_Key__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
        }
        
        upsert protectedAppConfig;
        
		cs.Auto_Assign_Sales_Rewards__c = true;
		cs.Enable_Sales_Rewards_Notification__c = true;
		cs.User_Reward_Onscreen_Notification__c = true;
		update cs;
		
		RefEdgeEditionFeatures.isBasic = false;
		Map<String, List<String>> emailsMap = new Map<String, List<String>>();
		emailsMap.put('toContacts', new List<String>());
		emailsMap.get('toContacts').add('abc@abc.abc1');
        emailsMap.put('ccContacts', new List<String>());
        emailsMap.get('ccContacts').add('abc@abc.abc2');
        emailsMap.put('bccContacts', new List<String>());
        emailsMap.get('bccContacts').add('abc@abc.abc3');
        emailsMap.put('toUser', new List<String>());
        emailsMap.get('toUser').add('abc@abc.abc4');
        emailsMap.put('ccUser', new List<String>());
        emailsMap.get('ccUser').add('abc@abc.abc5');
        emailsMap.put('bccUser', new List<String>());
        emailsMap.get('bccUser').add('abc@abc.abc6');
        emailsMap.put('toOther', new List<String>());
        emailsMap.get('toOther').add('abc@abc.abc7');
        emailsMap.put('ccOther', new List<String>());
        emailsMap.get('ccOther').add('abc@abc.abc8');
        emailsMap.put('bccOther', new List<String>());
        emailsMap.get('bccOther').add('abc@abc.abc9');
		List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
        User usr = TestDataFactory.createUser();
        usr.email = 'abc@abc.abc4';
        insert usr;
        
        List<Referenceability_Type__c> rfTypes = TestDataFactory.createUserRewardReferenceabilityType();
        insert rfTypes;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
        insert oppList;
        
        Microsite__c microsite = new Microsite__c(Name = 'test1', Available_for_Use__c = true);
      	insert microsite;
      	
      	List<Reference_Content__c> refContentList = TestDataFactory.createReferenceContent();
      	insert refContentList;
      	
        String sendInvResult = InvitationSLDSController.createInvitation(contacts[0].Id + ',' + contacts[1].Id,
        																	JSON.serialize(emailsMap),
        																	(String)usr.Id,
        																	'abc@abc.abc7' + ',' + 'abc@abc.abc8',
        																	'test subject',
        																	'test email content',
        																	'test inv name',
        																	(String)oppList[0].Id,
        																	'',
        																	string.valueOf(date.today().addDays(2)),
        																	(String)microsite.Id,
        																	'test notes',
        																	(String)refContentList[0].Id);
        																	
        //Here Invitation to Contact is page action for reward and 20 is user points		 															 
		system.assertEquals(sendInvResult, 'Invitation to Contact,20');
	}
	
	/**
  	 * Test Method for content download
  	 */
	public static testMethod void testcontentDownload() {
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
		
		String downloadURL = InvitationSLDSController.contentDownload(refContents[0].Id);
		system.assertNotEquals('', downloadURL);
	}
	
	/**
  	 * Test Method for load Reference Content
  	 */
	public static testMethod void testloadReferenceContent() {
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
		
		List<Reference_Interview__c> refInterviewList = TestDataFactory.createReferenceInterview(refContents);
		insert refInterviewList;
		
		ContentVersion CV = new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = TestDataFactory.createFile());
        insert CV;
         
        List<InvitationSLDSController.RefContentWrapper> refWrapperList = InvitationSLDSController.loadReferenceContent(refContents[0].Id);
        
		if (refWrapperList != null) {
			system.assertNotEquals(refWrapperList.size(), 0);
        } else {
			system.assertEquals(refWrapperList, null);
        }	
	}
}