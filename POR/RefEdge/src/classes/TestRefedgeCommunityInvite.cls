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
public with sharing class TestRefedgeCommunityInvite {
    
    //Test Method to check Community Process(Positive Case)
    static testMethod void unitTest01(){
        UserRole ur = TestDataFactory.createUserRole();
        
        User userWithRole = TestDataFactory.createUserWithRole(ur);
        
        System.RunAs(userWithRole) {
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
        }
        
        Test.startTest();
            RefedgeCommunityInvite rci = new RefedgeCommunityInvite();
            rci.next();
            rci.previous();
            rci.contactRBIs.get(0).isSelected = true;
            rci.selectAndContinue();
            rci.back();
            rci.inviteContactRBIs();
            system.assertEquals(rci.selectedContacts.size(),1);
        Test.stopTest();
    }
    
    //Test Method to check Community Process(Negative Case without selecting contact)
    static testMethod void unitTest02(){
        UserRole ur = TestDataFactory.createUserRole();
        
        User userWithRole = TestDataFactory.createUserWithRole(ur);
        
        System.RunAs(userWithRole) {
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
        }
        
        Test.startTest();
            RefedgeCommunityInvite rci = new RefedgeCommunityInvite();
            rci.recordlimits = 1;
            rci.selectAndContinue();
            system.assert(ApexPages.getMessages().size() > 0);
        Test.stopTest();
    }
    
    //Test Method to check Community Process(Negative Case with same email id of contact)
    static testMethod void unitTest03(){
        UserRole ur = TestDataFactory.createUserRole();
        
        User userWithRole = TestDataFactory.createUserWithRole(ur);
        
        System.RunAs(userWithRole) {
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            
            TestDataFactory.setUpAccountRBI(accounts);
            
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            
            contacts.get(0).Email = 'test@test.test';
            contacts.get(1).Email = 'test@test.test';
            update contacts;
            
            TestDataFactory.setUpContactRBI(contacts);
        }
        
        Test.startTest();
            RefedgeCommunityInvite rci = new RefedgeCommunityInvite();
            rci.contactRBIs.get(0).isSelected = true;
            rci.contactRBIs.get(1).isSelected = true;
            rci.selectAndContinue();
            rci.inviteContactRBIs(); 
            system.assertNotEquals(5, ApexPages.getMessages().size());
        Test.stopTest();
    }
}