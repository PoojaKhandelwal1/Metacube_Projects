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
public with sharing class TestRefedgeCommunityHome {
    //Test Method 
    public static testMethod void unitTest01() {
            UserRole ur = TestDataFactory.createUserRole();
            
            User userWithRole = TestDataFactory.createUserWithRole(ur);
            
            List<Contact> contacts;
            List<Community_Invite__c> cciList;
            
            System.RunAs(userWithRole) {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                
                contacts = TestDataFactory.createContacts(accounts);
                insert contacts;
                
                List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                
                List<Referenceability__c> listReferenceability = TestDataFactory.createReferenceability(accounts, contacts, rfTypes);
                insert listReferenceability;
                
                List<Reference_Request__c> refReqObject = new list<Reference_Request__c>{TestDataFactory.createReferenceRequest()[0]};
                insert refReqObject;
                
                List<Reference_Request_Account__c> rrAccList = TestDataFactory.createAccountRequests(new list<Account>{accounts[0]}, refReqObject, rfTypes);
                insert rrAccList;
                
                List<Reference_Request_Account_Contact__c> rrAccConList = TestDataFactory.createContactRequests(new list<Contact>{contacts[0]}, rrAccList, rfTypes);
                insert rrAccConList;
                
                cciList = TestDataFactory.createCommunityInvite(rrAccList);
                insert cciList;
                
                rrAccList.get(0).Community_Invite__c = cciList.get(0).id;
                update rrAccList;
                Community_Invite_Contact__c cic = new Community_Invite_Contact__c(Community_invite__c = cciList[0].id,Contact__c= contacts[0].id);
                insert cic;
                Community_News__c cnews = new Community_News__c(Name = 'Test',Show_on_Home_Page__c = true);
                insert cnews;
                Test.startTest();
                string contactId = RefedgeCommunityHome.getContactId();
                system.assertEquals('', RefedgeCommunityHome.pageId);
                system.assertEquals('', RefedgeCommunityHome.pageresponse);
                system.assertEquals(date.Today().format(), RefedgeCommunityHome.todayDate.format());
                
                List<RefedgeCommunityHome.CommunityWrapper> communityWrapperList = (List<RefedgeCommunityHome.CommunityWrapper>)JSON.deserialize(RefedgeCommunityHome.getCommunityInvites(contacts.get(0).Id), List<RefedgeCommunityHome.CommunityWrapper>.class);
                system.assertEquals('Analyst Call', communityWrapperList.get(0).refName);
                
                String invitationResponse = RefedgeCommunityHome.acceptRejectinvitation(cciList.get(0).Id, contacts.get(0).Id, 'Yes');
                system.assertEquals('success', invitationResponse);
                
                //String news = RefedgeCommunityHome.getNews();
                //system.assertNotEquals('', news);
                
                boolean isRefEdgeProgramMember = RefedgeCommunityHome.isRefedgeProgramMember(contacts.get(0).Id);
                system.assertEquals(true, isRefEdgeProgramMember);
                
                String contactObjString = RefedgeCommunityHome.getContact(contacts.get(0).Id);
                Contact contactObj = (Contact)JSON.deserialize(contactObjString, Contact.class);
                system.assertEquals('Alon', contactObj.FirstName);
                
                String leftFieldsString = RefedgeCommunityHome.getLeftFields(JSON.serialize(contactObj));
                List<RefedgeCommunityHome.FieldWrapper> leftFields = (List<RefedgeCommunityHome.FieldWrapper>)JSON.deserialize(leftFieldsString, List<RefedgeCommunityHome.FieldWrapper>.class);
                system.assertEquals('Full Name', leftFields.get(0).label);
                
                String rightFieldsString = RefedgeCommunityHome.getRightFields();
                List<RefedgeCommunityHome.FieldWrapper> rightFields = (List<RefedgeCommunityHome.FieldWrapper>)JSON.deserialize(rightFieldsString, List<RefedgeCommunityHome.FieldWrapper>.class);
                system.assertEquals('Mailing Street', rightFields.get(0).label);
                
                String refTypeWrapperString = RefedgeCommunityHome.getRefTypeWrapperList(JSON.serialize(contactObj));
                List<RefedgeCommunityHome.RefTypeWrapper> refTypeWrapperList = (List<RefedgeCommunityHome.RefTypeWrapper>)JSON.deserialize(refTypeWrapperString, List<RefedgeCommunityHome.RefTypeWrapper>.class);
                system.assertEquals('Analyst Call', refTypeWrapperList.get(0).refType.Name);
                
                String birthday = RefedgeCommunityHome.getBirthday(JSON.serialize(contactObj));
                system.assertEquals('', birthday);
                
                //saveContact positive test case
                contactObj.LastName = 'ABC';
                String savedContactString = RefedgeCommunityHome.saveContact(JSON.serialize(contactObj), JSON.serialize(refTypeWrapperList));
                Contact savedContact = (Contact)JSON.deserialize(savedContactString, Contact.class);
                system.assertEquals('ABC', savedContact.LastName);
                
                //saveContact negative test case
                contactObj.LastName = '';
                savedContactString = RefedgeCommunityHome.saveContact(JSON.serialize(contactObj), JSON.serialize(refTypeWrapperList));
                //savedContact = (Contact)JSON.deserialize(savedContactString, Contact.class);
                //system.assertEquals('ABC', savedContact.LastName);
                //
                List<RefedgeCommunityHome.NewsWrapper> newsWrapperList = (List<RefedgeCommunityHome.NewsWrapper>)JSON.deserialize(RefedgeCommunityHome.getNews(), List<RefedgeCommunityHome.NewsWrapper>.class);
                system.assertEquals('Test', newsWrapperList.get(0).newaName);
                
                //system.assert(false,[select Id, Response__c,Community_Invite__c, Contact__c from Community_Invite_Contact__c]);
                
                
                
                String contactReqListString = RefedgeCommunityHome.getContactReqList(contacts.get(0).Id);
                List<RefedgeCommunityHome.ContactReqWrapper> contactReqList = (List<RefedgeCommunityHome.ContactReqWrapper>)JSON.deserialize(contactReqListString, List<RefedgeCommunityHome.ContactReqWrapper>.class);
                //system.assertEquals('', contactReqList.get(0).Name);
                String inviteResponse1 = RefedgeCommunityHome.inviteAcceptedRejected(cciList.get(0).Id, 'Yes', contacts.get(0).Id);
                system.assertEquals('success', inviteResponse1);
                String refRequestMapString = RefedgeCommunityHome.getRefRequestMap(contacts.get(0).Id);
                Map<Id, Reference_Request__c> refRequestMap = (Map<Id, Reference_Request__c>)JSON.deserialize(refRequestMapString, Map<Id, Reference_Request__c>.class);
                //system.assertEquals('', refRequestMap.get(refReqObject.get(0).Id).Name);
                
                String lifetimePoints = RefedgeCommunityHome.getLifetimePoints(contacts.get(0).Id);
                //system.assertEquals('0', lifetimePoints);
                
                String avaliablePoints = RefedgeCommunityHome.getAvailablePoints(contacts.get(0).Id);
                //system.assertEquals('0', avaliablePoints);
                
                Test.stopTest();
            }
    }
    public static testMethod void testGetLifetimePoints() {
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
    	String lifetimePoints = RefedgeCommunityHome.getLifetimePoints(contacts[0].Id);
    	String avaliablePoints = RefedgeCommunityHome.getAvailablePoints(contacts[0].Id);
    	system.assertNotEquals(lifetimePoints, '');
    	system.assertNotEquals(avaliablePoints, '');
    }
    public static testMethod void testGetCommunityInvites() {
    	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
    	
    	List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
    	insert rrList;
    	List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Reference_Request_Account__c > rracList = TestDataFactory.createAccountRequests(accounts, rrList, refTypes);
        insert rracList;
        list < Community_Invite__c > ciList = TestDataFactory.createCommunityInvite(rracList);
    	insert ciList;
    	String communityInvites = RefedgeCommunityHome.getCommunityInvites(contacts[0].Id);
    	system.assertNotEquals(communityInvites, '');
    }
}