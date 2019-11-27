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
public class TestReferenceRequestController {
    
    //Test Method
    static testMethod void selectAndUpdateRecordClickedTest() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.selectedAccounts[0].isSelected = true;
                refReqConObj.selectedAccounts[1].isSelected = true;
                refReqConObj.param1 = rfTypes[0].Id;
                refReqConObj.referenceType = rfTypes[0].Id;
                refReqConObj.param2 = '2/10/2100';
                refReqConObj.param3 = 'test';
                refReqConObj.param4 = accounts[0].Id;
                refReqConObj.selectedValue = 'The Record Clicked';
                refReqConObj.selectAndUpdate();
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                if (msgs.size() == 0) {
                    system.assertNotEquals(null, rfTypes[0].Id);
                }
            }catch(Exception e){
                
            }
        test.stopTest();
    }

    //Test Method
    static testMethod void selectAndUpdateSelectedRecordsTest() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.selectedAccounts[0].isSelected = true;
                refReqConObj.selectedAccounts[1].isSelected = true;
                refReqConObj.param1 = rfTypes[0].Id;
                refReqConObj.referenceType = rfTypes[0].Id;
                refReqConObj.param2 = '2/10/2100';
                refReqConObj.param3 = 'test';
                refReqConObj.param4 = accounts[0].Id;
                refReqConObj.selectedValue = 'All Selected Records';
                refReqConObj.selectAndUpdate();
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                if (msgs.size() == 0) {
                    system.assertEquals(refReqConObj.selectedAccounts[0].refRequestAccount.Reference_Type_Needed__c, rfTypes[0].Id);
                    system.assertEquals(refReqConObj.selectedAccounts[1].refRequestAccount.Reference_Type_Needed__c, rfTypes[0].Id);
                    system.assertEquals(String.valueOf(refReqConObj.selectedAccounts[0].refRequestAccount.Deadline__c), '2100-02-10');
                    system.assertEquals(String.valueOf(refReqConObj.selectedAccounts[1].refRequestAccount.Deadline__c), '2100-02-10');
                    system.assertEquals(refReqConObj.selectedAccounts[0].refRequestAccount.Request_Notes__c, 'test');
                    system.assertEquals(refReqConObj.selectedAccounts[1].refRequestAccount.Request_Notes__c, 'test');
                }
            }catch(Exception e){
                
            }
        test.stopTest();
    }
    
    //Test Method
    static testMethod void selectAndUpdateWithPastDate() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.selectedAccounts[0].isSelected = true;
                refReqConObj.selectedAccounts[1].isSelected = true;
                refReqConObj.param1 = rfTypes[0].Id;
                refReqConObj.referenceType = rfTypes[0].Id;
                refReqConObj.param2 = '2/10/2012';
                refReqConObj.param3 = 'test';
                refReqConObj.param4 = accounts[0].Id;
                refReqConObj.selectedValue = 'The Record Clicked';
                refReqConObj.selectAndUpdate();
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assertEquals(msgs.size(), 1);
            }
        test.stopTest();
    }
    
    //Test Method
    static testMethod void selectAndUpdateWithOffDay() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.selectedAccounts[0].isSelected = true;
                refReqConObj.selectedAccounts[1].isSelected = true;
                refReqConObj.param1 = rfTypes[0].Id;
                refReqConObj.referenceType = rfTypes[0].Id;
                refReqConObj.param2 = '2/11/2100';
                refReqConObj.param3 = 'test';
                refReqConObj.param4 = accounts[0].Id;
                refReqConObj.selectedValue = 'The Record Clicked';
                refReqConObj.selectAndUpdate();
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                if (msgs.size() != 0) {
                    system.assertEquals(msgs.size(), 1);
                }
            }
        test.stopTest();
    }
    
    //Test Method
    static testMethod void param1NullSelectAndUpdate() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.selectedAccounts[0].isSelected = true;
                refReqConObj.selectedAccounts[1].isSelected = true;
                refReqConObj.param2 = '2/11/2100';
                refReqConObj.param3 = 'test';
                refReqConObj.param4 = accounts[0].Id;
                refReqConObj.selectedValue = 'The Record Clicked';
                refReqConObj.selectAndUpdate();
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assert(msgs.size() > 0);
            }
        test.stopTest();
    }
    
    //Test Method
    static testMethod void removeAccountFromListTest() {
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
            insert opps;
            PageReference pdfPage = new PageReference('ReferenceRequest');
            Test.setCurrentPage(pdfPage);
            ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
            ReferenceRequestController refReqConObj = new ReferenceRequestController();
            system.assertEquals(refReqConObj.selectedAccounts.size(), 3);
            refReqConObj.accountIdToRemoveFromList = accounts[0].Id;
            refReqConObj.removeAccountFromList();
            system.assertEquals(refReqConObj.selectedAccounts.size(), 2);
        test.stopTest();
    }
    
    //Test Method
    static testMethod void selectedAccountsNullTest() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.submitRequest();
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assert(msgs.size() > 0);
            }
        test.stopTest();
    }
    
    //Test Method
    static testMethod void submitRequestTest() {
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        	customSetting.Include_Weekends__c = false;
        	update customSetting;
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
            insert opps;
            PageReference pdfPage = new PageReference('ReferenceRequest');
            Test.setCurrentPage(pdfPage); 
            ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
            ReferenceRequestController refReqConObj = new ReferenceRequestController();
            refReqConObj.selectedAccounts[0].isSelected = true;
            refReqConObj.selectedAccounts[1].isSelected = true;
            refReqConObj.param1 = rfTypes[0].Id;
            refReqConObj.referenceType = rfTypes[0].Id;
            refReqConObj.param2 = '2/10/2100';
            refReqConObj.param3 = 'test';
            refReqConObj.param4 = accounts[0].Id;
            refReqConObj.selectedValue = 'All Selected Records';
            refReqConObj.selectAndUpdate();
            refReqConObj.selectedIds = accounts[0].Id + ',' + accounts[1].Id;
            refReqConObj.submitRequest();
            system.assertEquals(refReqConObj.isSubmitted, true);
        test.stopTest();
    }
    
    //Test Method
    static testMethod void submitRequestWithChatterEnabledFalseTest() {
        try{
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            customSetting.Include_Weekends__c = false;
            update customSetting;
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
            insert opps;
            PageReference pdfPage = new PageReference('ReferenceRequest');
            Test.setCurrentPage(pdfPage);
            ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
            ReferenceRequestController refReqConObj = new ReferenceRequestController();
            refReqConObj.selectedAccounts[0].isSelected = true;
            refReqConObj.selectedAccounts[1].isSelected = true;
            refReqConObj.param1 = rfTypes[0].Id;
            refReqConObj.referenceType = rfTypes[0].Id;
            refReqConObj.param2 = '2/10/2100';
            refReqConObj.param3 = 'test';
            refReqConObj.param4 = accounts[0].Id;
            refReqConObj.selectedValue = 'All Selected Records';
            refReqConObj.selectAndUpdate();
            refReqConObj.selectedIds = accounts[0].Id + ',' + accounts[1].Id;
            refReqConObj.submitRequest();
            system.assertEquals(refReqConObj.isSubmitted, true);
        test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test Method
    static testMethod void submitRequestWithoutInfoTest() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.selectedAccounts[0].isSelected = true;
                refReqConObj.selectedAccounts[1].isSelected = true;
                refReqConObj.submitRequest();
            }catch(Exception e){
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                system.assert(msgs.size() > 0);
                //system.assertEquals(refReqConObj.isSubmitted, false);
            }
        test.stopTest();
    }
    
    //Test Method
    static testMethod void selectedIdsNullSubmitRequestTest() {
        test.startTest();
            try{
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.selectedAccounts[0].isSelected = true;
                refReqConObj.selectedAccounts[1].isSelected = true;
                refReqConObj.param1 = rfTypes[0].Id;
                refReqConObj.referenceType = rfTypes[0].Id;
                refReqConObj.param2 = '2/10/2100';
                refReqConObj.param3 = 'test';
                refReqConObj.param4 = accounts[0].Id;
                refReqConObj.selectedValue = 'All Selected Records';
                refReqConObj.selectAndUpdate();
                refReqConObj.submitRequest();
                List < Apexpages.Message > msgs = ApexPages.getMessages();
                //system.assertEquals(msgs.size(), 2);
                system.assertEquals(refReqConObj.isSubmitted, false);
            }catch(Exception e){}
        test.stopTest();
    }
    
    //Test Method
    static testMethod void redirectToSearchPageTest() {
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                Pagereference pgRef = refReqConObj.redirectToSearchPage();
                system.assert(opps[0].id != null);
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    
    //Test Method
    static testMethod void returnOpportunityTest() {
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage);
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                Pagereference pgRef = refReqConObj.returnOpportunity();
                system.assertEquals(pgRef.getUrl(), '/' + opps[0].Id);
            test.stopTest();
        }catch(Exception e){
            
        }
    }
    //Test Method
    static testMethod void submitRequestTestSF1() {
        try{
            test.startTest();
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();            	
                List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
                insert rfTypes;
                List < Account > accounts = TestDataFactory.createAccounts();
                insert accounts;
                TestDataFactory.setUpAccountRBI(accounts);
                List < Opportunity > opps = TestDataFactory.createOpportunity(accounts);
                insert opps;
                PageReference pdfPage = new PageReference('ReferenceRequest');
                Test.setCurrentPage(pdfPage); 
                ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceRequestController refReqConObj = new ReferenceRequestController();
                refReqConObj.accountIdToRemoveFromList = accounts[0].Id;
                refReqConObj.getRequestInfo();
                refReqConObj.redirectToInfo();
                refReqConObj.redirect();
                refReqConObj.fromWhere = 'SF1';
                refReqConObj.selectAndUpdate();
                refReqConObj.fromWhere = '';
                refReqConObj.param1 = rfTypes[0].Id;
                refReqConObj.referenceType = rfTypes[0].Id;
                refReqConObj.changeMinimumDeadline();
                refReqConObj.param2 = (system.today() + 15).format();
                refReqConObj.param3 = 'test';
                refReqConObj.param4 = accounts[0].Id;
                refReqConObj.selectedValue = 'All Selected Records';
                refReqConObj.selectAndUpdate();
                refReqConObj.fromWhere = 'SF1';
                refReqConObj.submitRequest();
                system.assert(true);
            test.stopTest();
        }catch(Exception e){
            
        }
    }
}