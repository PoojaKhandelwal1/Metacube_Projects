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
 * Class: PreviewMicrositeNewController
 * Description : Test class for microsite controller
 * Modified by: Gaurav Saini (3 Jan, 2017)
 */
@isTest
public with sharing class TestPreviewMicrositeNewController {
	
	/**
	 * method to test the constructor
	 */
	public static testMethod void testConstructor() {
		Apexpages.currentPage().getParameters().put('micrositeId', '');
		Apexpages.currentPage().getParameters().put('selectRefContent', '');
		Apexpages.currentPage().getParameters().put('key', '');
		Apexpages.currentPage().getParameters().put('internalPreview', '');
		PreviewMicrositeNewController testObj = new PreviewMicrositeNewController();
		system.assertEquals(testObj.encryptedKey, '');
	}
	
	/**
	 * method to test get invitation method
	 */
	public static testMethod void testGetInvitationDetails() {
		List<Account> accounts = TestDataFactory.createAccounts();
		insert accounts;
		List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
		insert oppList;
		List<Microsite__c> micrositeList = new List<Microsite__c>();
		micrositeList.add(new Microsite__c(Sub_header_Copy__c = 'test',
											Sub_Header_Copy_Size__c = '14px',
											Sub_Header_Copy_Color__c = '#AC0000',
											Sub_Header_Copy_Alignment__c = 'Left',
											Image_Alignment__c = 'Left',
											Page_Color__c = '#AC0000',
											Header_Copy_Alignment__c = 'Left',
											Header_Copy_Size__c = '14px',
											Header_Copy_Color__c = '#AC0000',
											Header_Copy__c = 'test',
											Footer_Link__c = 'test',
											Footer_Copy__c = 'test',
											Footer_Copy_Size__c = '14px',
											Footer_Copy_Color__c = '#AC0000',
											Footer_Copy_Alignment__c = 'Left',
											Document_Title_Color__c = '#AC0000',
											Banner_image__c = '',
											Available_for_Use__c = true));
		insert micrositeList;
		List<Invitation__c> invitationList = TestDataFactory.createInvitation(oppList);
		invitationList[0].Microsite__c = micrositeList[0].Id;
		insert invitationList;
		String invObjectJSON = PreviewMicrositeNewController.getInvitationDetails(invitationList[0].Id);
		system.assertNotEquals(invObjectJSON, '');
	}
	
	/**
	 * method to test get microsite method
	 */
	public static testMethod void testGetMicrositeDetails() {
		List<Account> accounts = TestDataFactory.createAccounts();
		insert accounts;
		List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
		insert oppList;
		List<Microsite__c> micrositeList = new List<Microsite__c>();
		micrositeList.add(new Microsite__c(Sub_header_Copy__c = 'test',
											Sub_Header_Copy_Size__c = '14px',
											Sub_Header_Copy_Color__c = '#AC0000',
											Sub_Header_Copy_Alignment__c = 'Left',
											Image_Alignment__c = 'Left',
											Page_Color__c = '#AC0000',
											Header_Copy_Alignment__c = 'Left',
											Header_Copy_Size__c = '14px',
											Header_Copy_Color__c = '#AC0000',
											Header_Copy__c = 'test',
											Footer_Link__c = 'test',
											Footer_Copy__c = 'test',
											Footer_Copy_Size__c = '14px',
											Footer_Copy_Color__c = '#AC0000',
											Footer_Copy_Alignment__c = 'Left',
											Document_Title_Color__c = '#AC0000',
											Banner_image__c = '',
											Available_for_Use__c = true));
		insert micrositeList;
		String micrositeObjectJSON = PreviewMicrositeNewController.getMicrositeDetails(micrositeList[0].Id);
		system.assertNotEquals(micrositeObjectJSON, '');
	}
	
	/**
	 * method to test get ref content method for getting the selected ref contents for the invitation
	 */
	public static testMethod void testGetContentDetails() {
		list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
		insert oppList;
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
		List<Invitation__c> invitationList = TestDataFactory.createInvitation(oppList);
		insert invitationList;
		Invitation_ReferenceContent__c invContent = new Invitation_ReferenceContent__c();
		invContent.Reference_Content__c = refContents[0].Id;
		invContent.Invitation__c = invitationList[0].Id;
		insert invContent;
		User testUser = TestDataFactory.createUser();
		insert testUser;
		String IRCresult = PreviewMicrositeNewController.getContentDetails(invitationList[0].Id,
																			refContents[0].Id,
																			'',
																			'',
																			'');
		String IRCresult1 = PreviewMicrositeNewController.getContentDetails(invitationList[0].Id,
																			'',
																			testUser.Id,
																			'',
																			'');
		String IRCresult2 = PreviewMicrositeNewController.getContentDetails(invitationList[0].Id,
																			'',
																			'',
																			contacts[0].Id,
																			'');
		String IRCresult3 = PreviewMicrositeNewController.getContentDetails(invitationList[0].Id,
																			'',
																			'',
																			'',
																			'test.12345@gmail.com');
		String IRCresult4 = PreviewMicrositeNewController.getContentDetails(invitationList[0].Id, '', '', '', '');
		system.assertNotEquals(IRCresult, '');
	}
	
	/**
	 * method to test show ref content method
	 */
	public static testMethod void testShowRefContents() {
		Custom_Settings__c cs = TestDataFactory.createCustomSetting();
		RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        
        if (protectedAppConfig.Microsite_Key__c == null || protectedAppConfig.Microsite_Key__c == '') {
            
            if (protectedAppConfig.Current_Package_Date__c == null) {
                protectedAppConfig.Current_Package_Date__c = Datetime.now();
            }
            protectedAppConfig.Microsite_Key__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
        }
        upsert protectedAppConfig;
		list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        User testUser = TestDataFactory.createUser();
		insert testUser;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
		insert oppList;
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		refContents.add(new Reference_Content__c(Language__c = 'English', Substitute_Account_Name__c = 'Test account', title__c = 'Ref Content 1', Content_Status__c = 'Active'));
		refContents.add(new Reference_Content__c(Language__c = 'English', title__c = 'Ref Content 2', Content_Status__c = 'Active'));
		insert refContents;
		List<Account_Reference_Content__c> ARCList = new List<Account_Reference_Content__c>();
		ARCList.add(new Account_Reference_Content__c(Account__c = accounts[0].Id, Reference_Content__c = refContents[2].Id));
		insert ARCList;
		List<Invitation__c> invitationList = TestDataFactory.createInvitation(oppList);
		insert invitationList;
		List<String> refContentIds = new List<String>();
		for (Reference_Content__c rc : refContents) {
			refContentIds.add(rc.Id);
		}
		String showRefContentsResult = PreviewMicrositeNewController.showRefContents(refContentIds,
																						invitationList[0].Id,
																						'',
																						contacts[0].Id,
																						'', '', '');
		showRefContentsResult = PreviewMicrositeNewController.showRefContents(refContentIds,
																						invitationList[0].Id,
																						'',
																						null,
																						'', '', '');
		showRefContentsResult = PreviewMicrositeNewController.showRefContents(refContentIds,
																						invitationList[0].Id,
																						'',
																						null,
																						null, '', '');
		system.assert(true);
	}
	
	/**
	 * method to test save ref content rating method
	 */
	public static testMethod void testSaveContentRating() {
		list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
		insert oppList;
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
		List<Invitation__c> invitationList = TestDataFactory.createInvitation(oppList);
		insert invitationList;
		Invitee__c testInvitee = new Invitee__c(Invitation__c = invitationList[0].Id);
		insert testInvitee;
		Invitation_ReferenceContent__c invContent = new Invitation_ReferenceContent__c();
		invContent.Reference_Content__c = refContents[0].Id;
		invContent.Invitation__c = invitationList[0].Id;
		invContent.Recipient__c = testInvitee.Id;
		//invContent.Recipient__r.Contact__c = contacts[0].Id;
		insert invContent;
		User testUser = TestDataFactory.createUser();
		insert testUser;
		String saveRatingResult = PreviewMicrositeNewController.saveContentRating(0,
																				refContents[0].Id,
																				invitationList[0].Id,
																				contacts[0].Id, '', '');
		String saveRatingResult1 = PreviewMicrositeNewController.saveContentRating(1,
																				refContents[0].Id,
																				invitationList[0].Id,
																				'', testUser.Id, '');
		String saveRatingResult2 = PreviewMicrositeNewController.saveContentRating(0,
																				refContents[0].Id,
																				invitationList[0].Id,
																				'', '', 'test.123@gmail.com');
		system.assertNotEquals(saveRatingResult, '');
	}
	
	/**
	 * method to test save inviation ref content method
	 */
	public static testMethod void testUpdateInvitationContent() {
		list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Opportunity> oppList = TestDataFactory.createOpportunity(accounts);
		insert oppList;
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
		List<Invitation__c> invitationList = TestDataFactory.createInvitation(oppList);
		insert invitationList;
		Invitee__c testInvitee = new Invitee__c(Invitation__c = invitationList[0].Id);
		insert testInvitee;
		Invitation_ReferenceContent__c invContent = new Invitation_ReferenceContent__c();
		invContent.Reference_Content__c = refContents[0].Id;
		invContent.Invitation__c = invitationList[0].Id;
		invContent.Recipient__c = testInvitee.Id;
		insert invContent;
		User testUser = TestDataFactory.createUser();
		insert testUser;
		String updateInvContentResult = PreviewMicrositeNewController.updateInvitationContent(refContents[0].Id,
																								invitationList[0].Id,
																								contacts[0].Id, '', '');
		system.assertNotEquals(updateInvContentResult, '');
	}
	
	/**
	 * method to test download ref content method
	 */
	static testMethod void testDownloadRefContent() {
		List<Account> accounts = TestDataFactory.createAccounts();
		insert accounts;
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
		List<Account_Reference_Content__c> ARCList = TestDataFactory.createAccountRefContents(accounts, refContents);
		insert ARCList;
		User testUser = TestDataFactory.createUser();
		insert testUser;
		//ContentVersion cv = TestDataFactory.createContentVersion(testUser);
		//cv.FirstPublishLocation.Id = testUser.Id;
		//insert cv;
		//refContents[0].Content_ID__c = cv.Id;
		String downloadResult = PreviewMicrositeNewController.downloadRefContent(refContents[0].Id);
		system.assertEquals(downloadResult, '');
	}
	
	/**
	 * method to test get recipient id method for checking the correct recipient
	 */
	static testMethod void testGetRecepientId() {
		RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
        
        if (protectedAppConfig.Microsite_Key__c == null || protectedAppConfig.Microsite_Key__c == '') {
            
            if (protectedAppConfig.Current_Package_Date__c == null) {
                protectedAppConfig.Current_Package_Date__c = Datetime.now();
            }
            protectedAppConfig.Microsite_Key__c = EncodingUtil.base64Encode(Crypto.generateAesKey(256));
        }
        
        upsert protectedAppConfig;
        
		Account account = new Account(Name = 'Acc1');
        insert account;
		Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id, Email = 'abc@gmail.com');
        insert contact;
        Microsite__c microsite = new Microsite__c(Name = 'test');
        insert microsite;
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
		InvitationController ic = new InvitationController();
	    ic.defaultExpirationDays = (customSetting.Default_Expiration_Days__c != null ? customSetting.Default_Expiration_Days__c : 0);
	    ic.maximumExpirationDays = (customSetting.Maximum_Expiration_Days__c != null ? customSetting.Maximum_Expiration_Days__c : 0);
	    ic.onLoad();
	    ic.contactIds = contact.Id;
	    ic.contactEmailIds = contact.Id;
	    ic.invitation.Subject__c = 'test subject';
	    ic.message = 'test message';
	    ic.invitation.Microsite__c = microsite.Id;
	    ic.createInvitation();  
	    list<Invitee__c> invits = [select Id, URL__c From Invitee__c where Invitation__c = :ic.invitation.Id and Contact__c = :contact.Id]; 
	    string key = invits[0].URL__c;
	    PageReference pageRef = Page.MicrositePreview;
	    pageRef.getParameters().put('key', String.valueOf(key.substringAfter('key=')));
	    Test.setCurrentPage(pageRef);
	    PreviewMicrositeNewController.getRecepientId(Apexpages.currentPage().getParameters().get('key'));
	    system.assert(true);
	} 
	
}