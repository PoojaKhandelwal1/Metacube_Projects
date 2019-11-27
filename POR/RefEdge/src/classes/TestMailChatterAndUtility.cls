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
public class TestMailChatterAndUtility {
    
    static testMethod void testMailChatterAll(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        insert refReqAccs;
        List<Reference_Request_Account_Contact__c> refReqAccConts = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);
        
        for (Reference_Request_Account_Contact__c rrac : refReqAccConts) {
            rrac.Contact_Title__c = 'test';
            rrac.Contact_Email__c = 'asv@jhxc.com';
            rrac.Contact_Phone__c = '786387463847';
        }
        insert refReqAccConts;
        //Start Test method
        test.startTest();
            Map<Id, string> mapContacts1 = new Map<Id, string>();
            
            for (Contact c : [select Id, Name from Contact]) {
            	mapContacts1.put(c.Id,c.Name);
            }
            MailChatterController.getApproveMessageContactsDetalis(refReqAccConts, mapContacts1);
            MailChatterController.getChatterApproveMessage(accounts[0].name,refReqAccs[0], refReqAccConts, mapContacts1);
            MailChatterController.getChatterDeclineMessage(refReqAccs[0]);
            refReqAccConts = [select Id, Contact__c,Contact_Title__c,Contact_Email__c,Contact_Phone__c, Reference_Request_Account__r.Deadline__c,Reference_Request_Account__r.Reference_Type_Needed__r.Name,Reference_Request_Account__r.Account__r.Name from Reference_Request_Account_Contact__c where Reference_Request_Account__c = :refReqAccs[0].Id];
            MailChatterController.getChatterFeedbackMessage(refReqAccConts[0]);
            MailChatterController.getFeedbackResponseMessage(ConstantsController.FEEDBACK_SUCCESSFUL, refReqAccConts[0], system.today(), 'feedbakResponse');
            MailChatterController.getFeedbackResponseMessage(ConstantsController.FEEDBACK_UNSUCCESSFUL, refReqAccConts[0], system.today(), 'feedbakResponse');
            MailChatterController.getFeedbackResponseMessage(ConstantsController.FEEDBACK_NOT_OCCUR, refReqAccConts[0], system.today(), 'feedbakResponse');
            MailChatterController.getFeedbackResponseMessage(ConstantsController.FEEDBACK_YET_NOT_COMPLETED, refReqAccConts[0], system.today(), 'feedbakResponse');
            MailChatterController.prepareCCEmail('subject', 'toAddress', 'ccAddress', 'htmlBody');
            MailChatterController.prepareCCEmailMessage('subject', 'toAddress', 'ccAddress', 'htmlBody', 'linkUrl');
            MailChatterController.prepareChatterEmailMessage(system.today(), 'accountName', 'referenceTypeName', 'requestNotes');
            MailChatterController.prepareChatterEmailMessageForAccountContact('accountName', 'ownerName', 'contactName','ref');
            MailChatterController.prepareChatterEmailOwnerMessage('RequestName', 'AccountName', 'RefTypeName', 'RequestStatus', system.today(), 'RequestNotes', 'projectOwner','test acc');
            MailChatterController.prepareChatterEmailOwnerStatusMessage('RequestName', 'AccountName', 'RefTypeName', 'RequestStatus', system.today(), 'RequestNotes', 'approveDenyNotes', 'projectOwner','test acc');
            MailChatterController.prepareChatterEmailStatusMessage('RequestName', 'AccountName', 'RefTypeName', 'RequestStatus', system.today(), 'RequestNotes', 'approveDenyNotes','test acc');
            MailChatterController.prepareEmail('subject', accounts[0].Id, 'htmlBody',false);
            MailChatterController.prepareEmailMessage('subject', accounts[0].Id, 'htmlBody', 'linkUrl');
            MailChatterController.preparePost('postTitle', UserInfo.getUserId(), 'postBody', 'linkUrl');
            MailChatterController.prepareTask(UserInfo.getUserId(), accounts[0].Id, system.today(), 'subject', 'taskBody', refReqAccConts[0].Id);
            MailChatterController.prepareChatterProcessMessage('header', 'accountName', 'referenceTypeName', system.today(), 'projectOwner','test acc');
            MailChatterController.prepareChatterEmailMessageForLargeOpp('requester', 'accountRequested', 'requestType', system.today(), 'notes');
            MailChatterController.getApproveMessageContactsDetalis(refReqAccConts, mapContacts1);
            MailChatterController.getApproveMessageContactsDetalis(new List<Reference_Request_Account_Contact__c>(), mapContacts1);
            MailChatterController.prepareBodyForRefRefresh(new set<String>{'test'}, 'ownerName', UserInfo.getUserId(), 'test subject', false);
            MailChatterController.preparechatterForRefRefresh(new set<String>{'test'}, UserInfo.getUserId(), 'text body', 'test title');
            MailChatterController.preparechatterForRefRefreshUpdate('postBody', 'linkUrl', UserInfo.getUserId());
            MailChatterController.prepareChatterEmailMessageForAccountContact('','','','');
        //Stop Test method
        test.stopTest();
        List<Custom_Settings__c> csList = [select Id from Custom_Settings__c];
        system.assert(csList.size() > 0);
    }
    
    static testMethod void testUtilityController(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Attribute_Mapping__c> attMapping = TestDataFactory.createAttributeMapping(); 
        List<Account> accounts = TestDataFactory.createAccounts();
        accounts[0].Industry = 'Banking';
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
        insert childAttributes;
        List< Label__c> labels = new List< Label__c>{TestDataFactory.createLabels()[0]};
        insert labels;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        TestDataFactory.createAccountAttributes(new List<Account>{accounts[0]}, childAttributes,false);
        TestDataFactory.createContactAttributes(new List<Contact>{contacts[0]}, childAttributes);
        
        //Start Test method
        test.startTest();
            system.assert(true, UtilityController.isNativeChatterSetting);
            system.assert(true, UtilityController.mapContentLanguage);
            system.assert(true, UtilityController.mapContentTypeImagePath);
            UtilityController.getCustomSettings();
            UtilityController.appNamespace();
            UtilityController.calculateMinimumDays(system.today().addDays(10), 5);
            customSetting.Include_Weekends__c = false;
            customSetting.Expiration_Timeframe__c = ConstantsController.X_DAYS_FROM_AWARDDATE;
            customSetting.Expire_Rewards__c = true;
            customSetting.Expiration_Days__c = 3;
            update customSetting;
            UtilityController.calculateMinimumDays(system.today().addDays(10), 0);
            ConstantsController.runCheckAttributeMappingEditMethod = true;
            UtilityController.checkAttributeMappingEdit(new set<Id>{attMapping[0].Id}, 'Account');
            UtilityController.checkRBI(accounts[0].Id, Contacts[0].Id, accounts[0].Id, true);
            UtilityController.checkValueOfString(null);
            UtilityController.checkValueOfString('strValue');
            UtilityController.convertCommaSeperatedStringToArray(null);
            UtilityController.convertCommaSeperatedStringToArray('value,test,value2');
            Set<Id>  delAtts = new Set<Id>();
            
            for (Attribute__c att : childAttributes) {
            	delAtts.add(att.Id);
            }
            UtilityController.deleteAttributesInstance(delAtts);
            UtilityController.getGuestUserId();
            UtilityController.getMicrositeTemplete();
            UtilityController.getSiteUrl();
            UtilityController.isItWeekend(system.today());
            
            try {
                UtilityController.sendEmailNotification(new List<String>{'test'}, 'Mode');
            } catch(Exception e) {
                System.debug('Error While Seding Email Message : '+e);
            }
            UtilityController.getCompanyFooter();
            UtilityController.getCompanyLogo();
            UtilityController.rewardsExpritationDate(UtilityController.CustomSettings);
            customSetting.Expiration_Days__c = null;
            customSetting.Expiration_Timeframe__c = 'end of NEXT CY';
            update customSetting;
            UtilityController.rewardsExpritationDate(UtilityController.CustomSettings);
            customSetting.Expiration_Timeframe__c = 'end of current FY';
            update customSetting;
            UtilityController.rewardsExpritationDate(UtilityController.CustomSettings);
            customSetting.Expiration_Timeframe__c = 'end of current CY';
            update customSetting;
            UtilityController.rewardsExpritationDate(UtilityController.CustomSettings);
        //Stop Test method
        test.stopTest();
    }

}