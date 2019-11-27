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
 * Class: ReferenceNoteDetailController
 * Description : class to test and cover ReferenceNoteDetailController
 * Modified by: Rekha Jangir @15 June 2017
 */
@isTest(seeAllData = false)
public class TestReferenceNoteDetailController {
    
    /**
     * Method to test from Account
     */
    static testmethod void testViewReferenceNote() {
        test.startTest();
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Account__c = accounts[0].Id, Note__c = 'test Notes');
            insert referNotes;
            ApexPages.StandardController controller = new ApexPages.StandardController(referNotes);
            ReferenceNoteDetailController refNoteObj = new ReferenceNoteDetailController(controller);
            Pagereference pg = refNoteObj.edit();
            system.assertEquals(Page.AddReferenceNote.getURL() + '?id=' + referNotes.Id + '&retURL=null', pg.getURL());
            
            // save reward
            String result = ReferenceNoteDetailController.editRefNote();
            result = ReferenceNoteDetailController.deleteRefNote(referNotes.Id);
            
            List<Reference_Note__c> notes = [SELECT Id FROM Reference_Note__c WHERE Account__c = :accounts[0].Id];
            system.assertEquals(0, notes.size());
        test.stopTest();
    }
}