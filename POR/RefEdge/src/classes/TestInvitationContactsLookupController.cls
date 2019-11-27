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
public with sharing class TestInvitationContactsLookupController {
    
    //Test Method for checking of Contact Lookup
    static testMethod void checkContactLookup() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        PageReference pageRef = Page.InvitationContactsLookup;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('strText', '');
        InvitationContactsLookupController  con = new InvitationContactsLookupController();
        con.getWrapperList();
        system.assertEquals(6, con.contactListWrapper.size());
        pageRef.getParameters().put('strText', contacts[0].Id);
        con = new InvitationContactsLookupController();
        con.getWrapperList();
        system.assertEquals(1, con.contactListWrapper.size());
        con.createNewContact();
        con.newContact.LastName = 'Alim12345';
        con.newContact.AccountId = accounts[0].Id;
        con.newContact.Email = 'eeee@khh.hhh';
        con.saveNewContact();
        con.cancelNewContact();
        con.setEmailIds();
        con.searchText = 'Alim';
        con.search();
    }
}