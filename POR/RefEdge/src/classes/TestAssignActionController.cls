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
private class TestAssignActionController {
    //Test Method
    static testMethod void testARForUnspecified() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        integer index = 0;
        for(Reference_Request__c rr : refReqs){
            rr.Opportunity__c = opps[index].Id;
            index++;
            if(index >= opps.size())
                index = 0;
        }
        insert refReqs;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        refReqAccs[0].Managed_Request__c = true;
        refReqAccs[1].Account_Request_Status__c = '';
        insert refReqAccs;
        List < Unspecified_Request__c > unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        
        list<Hit_List__c> hitlists = new list<Hit_List__c>();
        hitlists.add(new Hit_List__c(note__c = 'test1',Unspecified_Request__c = unSpeReqs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[0].Id,Contact__c = contacts[0].Id));
        hitlists.add(new Hit_List__c(note__c = 'test2',Account_Request__c = refReqAccs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[0].Id,Contact__c = contacts[0].Id));
        hitlists.add(new Hit_List__c(note__c = 'test3',Unspecified_Request__c = unSpeReqs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
        hitlists.add(new Hit_List__c(note__c = 'test3',Account_Request__c = refReqAccs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
        insert hitlists;
        //Start Test Method
        test.startTest();
          PageReference pageRef = Page.AssignAction;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('Id', hitlists[0].Id);
          ApexPages.currentPage().getParameters().put('retPage', 'RefRequestProject');
          ApexPages.currentPage().getParameters().put('retId', refReqs[0].Id);
          AssignActionController controller = new AssignActionController ();
          for(ReferenceRequestWrapper rraw : controller.allAccountReq){
            rraw.isSelected = true;
          }
          controller.assignHitRecord();
          controller.cancel();
          system.assertEquals(controller.accReqs.size(),13);
        //Stop test method
        test.stopTest();
    }
    //test method
    static testMethod void testARForSpecified() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Contact > contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        list<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        integer index = 0;
        for(Reference_Request__c rr : refReqs){
            rr.Opportunity__c = opps[index].Id;
            index++;
            if(index >= opps.size())
                index = 0;
        }
        insert refReqs;
        list < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        insert refReqAccs;
        List < Unspecified_Request__c > unSpeReqs = TestDataFactory.createUnspecifiedRequest(refReqs, refTypes);
        insert unSpeReqs;
        
        list<Hit_List__c> hitlists = new list<Hit_List__c>();
        hitlists.add(new Hit_List__c(note__c = 'test1',Unspecified_Request__c = unSpeReqs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[0].Id,Contact__c = contacts[0].Id));
        hitlists.add(new Hit_List__c(note__c = 'test2',Account_Request__c = refReqAccs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[0].Id,Contact__c = contacts[0].Id));
        hitlists.add(new Hit_List__c(note__c = 'test3',Unspecified_Request__c = unSpeReqs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
        hitlists.add(new Hit_List__c(note__c = 'test3',Account_Request__c = refReqAccs[0].Id,referenceability_type__c = refTypes[0].Id,Reference_Request__c = refReqs[0].Id,Deadline__c = system.today(),Account__c = accounts[2].Id));
        insert hitlists;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.AssignAction;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', hitlists[1].Id);
            ApexPages.currentPage().getParameters().put('retPage', 'RefRequestProject');
            AssignActionController controller = new AssignActionController ();
            for(ReferenceRequestWrapper rraw : controller.allAccountReq){
                rraw.isSelected = true;
            }
            controller.assignHitRecord();
            system.assertEquals(controller.accReqs.size(),13);
        //Stop test method
        test.stopTest();
    }
    
    //test method
    static testMethod void testFornullRequest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        list<Hit_List__c> hitlists = new list<Hit_List__c>();
        hitlists.add(new Hit_List__c(note__c = 'test1',Deadline__c = system.today(),Account__c = accounts[0].Id));
        insert hitlists;
        //Start test method
        test.startTest();
            try{
                PageReference pageRef = Page.AssignAction;
                Test.setCurrentPage(pageRef);
                ApexPages.currentPage().getParameters().put('Id', hitlists[0].Id);
                ApexPages.currentPage().getParameters().put('retPage', 'RefRequestProject');
                AssignActionController controller = new AssignActionController ();
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assertEquals(msgs.size(), 1);
            }
        //Stop test method
        test.stopTest();
    }
}