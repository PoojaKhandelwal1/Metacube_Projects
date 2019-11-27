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
 * VF Page: HitListReleaseAction.page
 * Description: 
 * Modified By: Rajesh @JUNE 20 2017  
 */  
@isTest(seeAllData = false)
private class TestHitListReleaseActionController {
    public static List<Referenceability_Type__c> refTypes ;
    public static List<Account> accounts ;
    public static List<Contact> contacts;
    public static List<Opportunity> opps;
    public static List<Reference_Request__c> refReqs;
    public static List<Reference_Request_Account__c> refReqAccs;
    public static List<Unspecified_Request__c> unSpeReqs;
    public static List<Hit_List__c> hitlists; 
    
    /**
     * Test Method of Save for Unspecified
     */
    static testMethod void testSaveForUnspecified() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        TestDataFactory.setUpContactRBI(contacts);
        opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        
        refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        
        refReqs = TestDataFactory.createMoreReferenceRequest();
        insert refReqs;
        
        refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Approve_Deny_Notes__c = 'Approved';
        refReqAccs[0].Approval_Status__c = 'Approved';
        refReqAccs[1].Account_Request_Status__c = 'On Hold';
        insert refReqAccs;
        
        unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        
        hitlists = createHitListRecords();
        insert hitlists;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.HitListReleaseAction;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', hitlists[0].Id);
            ApexPages.currentPage().getParameters().put('retPage', 'RefRequestProject');
            ApexPages.currentPage().getParameters().put('retId', refReqs[0].Id);
            
            HitListReleaseActionController controller = new HitListReleaseActionController();
            controller.hitObject.Disposition__c = 'Agreed';
            controller.showRequestBlock();
            
            for (ReferenceRequestWrapper rraw : controller.allAccountReq) {
                rraw.isSelected = true;
            }
             
            controller.save();
            
            system.assertEquals(1, controller.updateOtherHitLists.size());
            controller.redirectBack();
        //Stop test method
        test.stopTest();
    }
    
    /**
     * Test Method of Save for specified
     */ 
    static testMethod void testSaveForSpecified() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        TestDataFactory.setUpContactRBI(contacts);
        opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        
        refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        
        refReqs = TestDataFactory.createMoreReferenceRequest();
        insert refReqs;
        
        refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        insert refReqAccs;
        
        unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        
        hitlists = createHitListRecords();
        insert hitlists;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.HitListReleaseAction;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', hitlists[1].Id);
            ApexPages.currentPage().getParameters().put('retPage', 'RefRequestProject');
            //ApexPages.currentPage().getParameters().put('retId', refReqs[0].Id);
            HitListReleaseActionController controller = new HitListReleaseActionController();
            controller.hitObject.Disposition__c = 'Agreed';
            controller.showRequestBlock();
            
            controller.allAccountReq[0].isSelected = true;
            controller.allAccountReq[1].isSelected = true;
            controller.save();
            controller.redirectBack();
            system.assertEquals(controller.updateOtherHitLists.size(), 1);
        //Stop test method
        test.stopTest();
    }
    
	/**
	 * Test Method of Save for testSaveForReleasedStatus
	 */ 
   static testMethod void testSaveForReleasedStatus() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
        TestDataFactory.setUpContactRBI(contacts);
        opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        
        refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        
        refReqs = TestDataFactory.createMoreReferenceRequest();
        insert refReqs;
        
        refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        insert refReqAccs;
        
        unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        
        hitlists = createHitListRecords();
        insert hitlists;
        
        //Start test method
        test.startTest();
            PageReference pageRef = Page.HitListReleaseAction;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', hitlists[1].Id);
            ApexPages.currentPage().getParameters().put('retUrl', refReqs[0].Id);
            ApexPages.currentPage().getParameters().put('retId', refReqs[0].Id);
            HitListReleaseActionController controller = new HitListReleaseActionController();
            controller.hitObject.Disposition__c = 'Released: Contact Declined';
            controller.showRequestBlock();
            controller.save();
            system.assertEquals(controller.updateOtherHitLists.size(),1);
            controller.redirectBack();
        //Stop test method    
        test.stopTest();
    }
    
    //Creation of Hit_List records
    private static List<Hit_List__c> createHitListRecords(){
        List<Hit_List__c> tempList = new List<Hit_List__c>();
        tempList.add(new Hit_List__c(note__c = 'test1',Unspecified_Request__c = unSpeReqs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[1].Id,Contact__c = contacts[0].Id));
        tempList.add(new Hit_List__c(note__c = 'test2',Account_Request__c = refReqAccs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[1].Id,Contact__c = contacts[0].Id));
        tempList.add(new Hit_List__c(note__c = 'test3',Unspecified_Request__c = unSpeReqs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
        tempList.add(new Hit_List__c(note__c = 'test3',Account_Request__c = refReqAccs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
        
        return  tempList;
    }
}