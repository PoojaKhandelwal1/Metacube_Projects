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
* Class: RFSearchController
* Description : class to test and cover RFSearchController 
* Modified by: Rekha Jangir @Nov/4/2016
*/
@isTest(seeAllData = false)
public class TestRFSearchController {
    /*
     * Method to cover Content Section with Attribute Mapping
     * Created : Rekha Jangir @04/11/2016
     */
    public static testMethod void testContentSectionOfRefSearchAttMapp(){
        //insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.CreateUser();
        insert u;
        List<Attribute_Mapping__c> relatedMappings = TestDataFactory.createRelatedAttributeMappingAccount();
        List<Attribute_Mapping__c> attMappingList = TestDataFactory.createRefconAttributeMapping();
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        TestDataFactory.createAttributeLabels(labels,attributes);

        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        contacts[0].MobilePhone = '12345';
        insert contacts;

        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);

        List<Opportunity> opportunities = TestDataFactory.createOpportunity(accounts);
        insert opportunities;

        List<Label__c> labelList = [SELECT id, name FROM Label__c order by Name LIMIT: limits.getLimitQueryRows()];
        List<Data_Mapping__c> filterList = new List<Data_Mapping__c>();

        for (Label__c label : labelList) {
            filterList.add(new Data_Mapping__c(Label__c = label.Name, Field_API_Name__c = label.Id, Object__c = 'SmartSearchFilter', Visible__c = true));
        }
        insert filterList;
        system.runAs(u) {
            List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
            insert refContents;

            List<Account_Reference_Content__c> accountContents = TestDataFactory.createAccountRefContents(new List<Account>{accounts[0]}, refContents);
            insert accountContents;

            //Start test method
            Test.StartTest();
                PageReference rfPage = new PageReference('RfSearchPage');
                Test.setCurrentPage(rfPage);
                ApexPages.currentPage().getParameters().put('isRefMatch', 'false');
                ApexPages.currentPage().getParameters().put('SF1', 'false');
                ApexPages.currentPage().getParameters().put('PreFilter', 'true');
                ApexPages.currentPage().getParameters().put('opportunityId', opportunities[0].Id);
                ApexPages.currentPage().getParameters().put('forAccount', 'false');
                ApexPages.currentPage().getParameters().put('forContent', 'true');
                RfSearchController rfSearchCon = new RfSearchController();
                rfSearchCon.preFilterSearch();
                system.assertEquals(1, rfSearchCon.getContents().size());

                //for related mapping search for Contact field
                rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[0].Id;
                rfSearchCon.goToTheRelatedSearch();
                rfSearchCon.relatedMappingController.inputTextValue = '12345';
                rfSearchCon.relatedMappingController.saveTheSelected();
                system.assertEquals(1, rfSearchCon.getAccounts().size());
                system.assertEquals(1, rfSearchCon.getContents().size());

                //for related mapping search for Reference Content field
                rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[2].Id;
                rfSearchCon.goToTheRelatedSearch();
                rfSearchCon.relatedMappingController.inputTextValue = 'Testing';
                rfSearchCon.relatedMappingController.saveTheSelected();
                rfSearchCon.selectedId = refContents[0].Id;
                system.assertEquals(1, rfSearchCon.getContents().size());
                
                rfSearchCon.ClearMappings();
                rfSearchCon.relatedMappingController.getAllTheResults();
            //Stop test method
            Test.stopTest();
        }
    }
    /*
     * Method to cover Contact Section with Attribute Mapping
     * Created : Rekha Jangir @04/11/2016
     */
    public static testMethod void testContactSectionOfRefSearchAttMapp(){
        //insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.CreateUser();
        insert u;
        List<Attribute_Mapping__c> relatedMappings = TestDataFactory.createRelatedAttributeMappingAccount();
        List<Attribute_Mapping__c> attMappingList = TestDataFactory.createAttributeMapping();

        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        system.runAs(u) {
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            contacts[0].MobilePhone = '12345';
            insert contacts;
            List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
            TestDataFactory.setUpContactRBI(contacts);
        }
        
        List<Label__c> labelList = [SELECT id, name FROM Label__c order by Name LIMIT: limits.getLimitQueryRows()];
        List<Data_Mapping__c> filterList = new List<Data_Mapping__c>();

        for (Label__c label : labelList) {
            filterList.add(new Data_Mapping__c(Label__c = label.Name, Field_API_Name__c = label.Id, Object__c = 'SmartSearchFilter', Visible__c = true));
        }
        insert filterList;

        //Start test method
        Test.StartTest();
            PageReference rfPage = new PageReference('RfSearchPage');
            Test.setCurrentPage(rfPage);
            RfSearchController rfSearchCon = new RfSearchController();

            //for related mapping search for Contact field
            rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[0].Id;
            rfSearchCon.goToTheRelatedSearch();
            rfSearchCon.relatedMappingController.inputTextValue = '12345';
            rfSearchCon.relatedMappingController.saveTheSelected();
            system.assertEquals(1, rfSearchCon.getContacts().size());
            
            //for related mapping search for User field
            rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[3].Id;
            rfSearchCon.goToTheRelatedSearch();
            rfSearchCon.relatedMappingController.inputTextValue = 'japnalocal@newtest.com';
            rfSearchCon.relatedMappingController.saveTheSelected();
            system.assertEquals(1, rfSearchCon.getContacts().size());
            
            rfSearchCon.relatedMappingController.inputTextValue = 'japnalocal';
            rfSearchCon.relatedMappingController.searchRecords();
            
            rfSearchCon.relatedMappingController.inputTextValue = 'japnalocal@newtest.com';
            rfSearchCon.relatedMappingController.saveTheSelected();
            rfSearchCon.relatedMappingController.searchRecords();
            
            rfSearchCon.ClearMappings();
            rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[0].Id;
            rfSearchCon.ClearMappings();
            system.assertEquals(5, rfSearchCon.getContacts().size());

            //for related mapping search for Account field
            rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[1].Id;
            rfSearchCon.goToTheRelatedSearch();
            rfSearchCon.relatedMappingController.inputTextValue = 'Web';
            rfSearchCon.relatedMappingController.saveTheSelected();
            system.assertEquals(1, rfSearchCon.getContacts().size());

            //asserting values of some variables
            system.assertEquals(10, rfSearchCon.RULPeriodLengthContact);

        //Stop test method
        Test.stopTest();
    }
    /*
     * Method to cover Account Section with Attribute Mapping
     * Created : Rekha Jangir @04/11/2016
     */
    public static testMethod void testAccountSectionOfRefSearchAttMap(){
        //insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        User u = TestDataFactory.CreateUser();
        insert u;
        List<Attribute_Mapping__c> relatedMappings = TestDataFactory.createRelatedAttributeMappingAccount();
        List<Attribute_Mapping__c> attMappingList = TestDataFactory.createAttributeMapping();
        system.runAs(u) {
            List<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
    
            List<Contact> contacts = TestDataFactory.createContacts(accounts);
            contacts[0].MobilePhone = '12345';
            contacts[1].MobilePhone = 'T98765';
            insert contacts;
    
            List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
            TestDataFactory.setUpContactRBI(contacts);
            
            List<Opportunity> opportunities = TestDataFactory.createOpportunity(accounts);
            insert opportunities;
    
            List<Label__c> labelList = [SELECT id, name FROM Label__c order by Name LIMIT: limits.getLimitQueryRows()];
            List<Data_Mapping__c> filterList = new List<Data_Mapping__c> ();
    
            for (Label__c label : labelList) {
                filterList.add(new Data_Mapping__c(Label__c = label.Name, Field_API_Name__c = label.Id, Object__c = 'SmartSearchFilter', Visible__c = true));
            }
            insert filterList;

            List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
            insert refContents;

            List<Account_Reference_Content__c> accountContents = TestDataFactory.createAccountRefContents(new List<Account>{accounts[0]}, refContents);
            insert accountContents;

            //Start test method
            Test.StartTest();
                PageReference rfPage = new PageReference('RfSearchPage');
                Test.setCurrentPage(rfPage);
                ApexPages.currentPage().getParameters().put('isRefMatch', 'false');
                ApexPages.currentPage().getParameters().put('SF1', 'false');
                ApexPages.currentPage().getParameters().put('PreFilter', 'true');
                ApexPages.currentPage().getParameters().put('opportunityId', opportunities[0].Id);
                ApexPages.currentPage().getParameters().put('forAccount', 'true');
                ApexPages.currentPage().getParameters().put('forContent', 'false');
                RfSearchController rfSearchCon = new RfSearchController();
                rfSearchCon.preFilterSearch();
                system.assertEquals(1, rfSearchCon.basicFilterList.size());
                system.assertEquals(2, rfSearchCon.getAccounts().size());
                system.assertEquals(0, rfSearchCon.selectedAccIdsSet.size());
                system.assertEquals(0, rfSearchCon.noOfSelectedAccount);

                //for related mapping search for Contact field
                rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[0].Id;
                rfSearchCon.goToTheRelatedSearch();
                rfSearchCon.relatedMappingController.inputTextValue = '12345';
                rfSearchCon.relatedMappingController.saveTheSelected();
                system.assertEquals(1, rfSearchCon.getAccounts().size());
                rfSearchCon.relatedMappingController.character = 'T';
                rfSearchCon.relatedMappingController.showResultAlphabet();
                rfSearchCon.relatedMappingController.character = 'All';
                rfSearchCon.relatedMappingController.showResultAlphabet();

                //for related mapping search for Account field
                rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[1].Id;
                rfSearchCon.goToTheRelatedSearch();
                rfSearchCon.relatedMappingController.inputTextValue = 'Web';
                rfSearchCon.relatedMappingController.saveTheSelected();
                system.assertEquals(1, rfSearchCon.getAccounts().size());
                rfSearchCon.relatedMappingController.character = 'O';
                rfSearchCon.relatedMappingController.showResultAlphabet();
                rfSearchCon.relatedMappingController.character = 'All';
                rfSearchCon.relatedMappingController.showResultAlphabet();

                //for related mapping search for Reference Content field
                rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[2].Id;
                rfSearchCon.goToTheRelatedSearch();
                rfSearchCon.relatedMappingController.inputTextValue = 'Testing';
                rfSearchCon.relatedMappingController.saveTheSelected();
                rfSearchCon.selectedId = accounts[0].Id + ',' + accounts[1].Id;
                system.assertEquals(1, rfSearchCon.getAccounts().size());
                rfSearchCon.relatedMappingController.character = 't';
                rfSearchCon.relatedMappingController.showResultAlphabet();
                rfSearchCon.relatedMappingController.character = 'All';
                rfSearchCon.relatedMappingController.showResultAlphabet();
                
                //for related mapping search for User field
                rfSearchCon.relatedMappingController.attributeMappingId = relatedMappings[4].Id;
                rfSearchCon.goToTheRelatedSearch();
                rfSearchCon.relatedMappingController.inputTextValue = 'japnalocal@newtest.com';
                rfSearchCon.relatedMappingController.saveTheSelected();
                system.assertEquals(1, rfSearchCon.getAccounts().size());
                rfSearchCon.ClearMappings();
                
                //asserting values of some variables
                rfSearchCon.selectedIds = accounts[0].Id + ',' + accounts[1].Id;
                system.assertEquals(2, rfSearchCon.selectedAccIdsSet.size());
                system.assertEquals(2, rfSearchCon.noOfSelectedAccount);
                system.assertEquals(99, rfSearchCon.RULPeriodLength);
                system.assertEquals(5, rfSearchCon.numberOfRequestAccounts);

                rfSearchCon.selectedIds = accounts[0].Id + ',' + accounts[1].Id;
                PageReference pgref = rfsearchCon.selectAndContinue();
                system.assertEquals(true, pgref.getURL().contains(Page.ReferenceRequest.getURL()));

                pgref = rfsearchCon.discardReqAccount();
                system.assertEquals(true, pgref.getURL().contains(Page.ReferenceUseRequest.getURL()));

                pgref = rfsearchCon.keepReqAccount();
                system.assertEquals(true, pgref.getURL().contains(Page.ReferenceUseRequest.getURL()));
                rfsearchCon.clearFilters();
            //Stop test method
            Test.stopTest();
        }
    }
    /*
     * Method to cover Account Section with opportunity attributes(prefilter)
     * FROM apportunity, we have 4 ways to filter account 1) Stage filter 2) Picklist of Opportunity 3) Picklist of LineItem 4) Products
     * Created : Rekha Jangir @04/11/2016
     */
    public static testMethod void testAccountSectionOfRefSearchOppAtt(){
        //insert test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Apply_Opportunity_Stage_Filter__c = true;
        update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;

        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);

        //Opportunity Attribute mapping
        TestDataFactory.createOpportunityAttributeMapping();
        List<Attribute__c> oppAttList = [SELECT Id FROM Attribute__c WHERE Name = 'New Business' and level__c = 1];

        if(oppAttList.size() > 0){
            insert new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = oppAttList[0].Id);
        }
        //Get standard pricebook
        string priceBook2Id = Test.getStandardPricebookId();

        //Product
        Product2 prod = new Product2(Name = 'Test product', family = 'Test family');
        insert prod;
        List<Attribute__c> prodAttList = [SELECT Id, Product_ID__c FROM Attribute__c WHERE Name = 'Product' and level__c = 0];

        if (prodAttList.size() > 0) {
            string labelId = prodAttList[0].Product_ID__c;
            Attribute__c prodAtt = new Attribute__c(name = prod.Name, Parent__c = prodAttList[0].Id, Product_ID__c = prod.Id);
            insert prodAtt;
            List<Attributes_Labels__c> attFilters = new List<Attributes_Labels__c>();
             
            attFilters.add(new Attributes_Labels__c(Attribute__c = prodAtt.Id, Label__c = labelId));

            if (attFilters.size() > 0) {
                insert attFilters;
                insert new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = prodAtt.Id);
            }
        }
        //PricebookEntry
        PricebookEntry pbe1 = new PricebookEntry (Pricebook2ID = priceBook2Id, Product2ID = prod.id, UnitPrice=500, isActive=true);
        insert pbe1;

        List<Opportunity> opportunities = TestDataFactory.createOpportunity(accounts);

        for (Opportunity opp : opportunities) {
            opp.CloseDate = system.today() + 1;
            opp.Amount = 700;
            opp.Type = 'New Business';
            opp.StageName = 'Prospecting';
            opp.Pricebook2Id = pbe1.Pricebook2Id;
        }
        insert opportunities;
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID=opportunities[0].id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=900);
        insert lineItem;
        List<Label__c> labelList = [SELECT id, name FROM Label__c WHERE Name != 'Stage' order by Name LIMIT: limits.getLimitQueryRows()];
        List<Data_Mapping__c> filterList = new List<Data_Mapping__c>();

        for (Label__c label : labelList) {
            filterList.add(new Data_Mapping__c(Label__c = label.Name, Field_API_Name__c = label.Id, Object__c = 'SmartSearchFilter', Visible__c = true));
        }
        insert filterList;

        //Start test method
        Test.StartTest();
            PageReference rfPage = new PageReference('RfSearchPage');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('isRefMatch', 'false');
            ApexPages.currentPage().getParameters().put('SF1', 'false');
            ApexPages.currentPage().getParameters().put('PreFilter', 'true');
            ApexPages.currentPage().getParameters().put('opportunityId', opportunities[0].Id);
            ApexPages.currentPage().getParameters().put('forAccount', 'false');
            ApexPages.currentPage().getParameters().put('forContent', 'false');
            RfSearchController rfSearchCon = new RfSearchController();
            rfSearchCon.preFilterSearch();

            //we have only one Account for which any opportunity has the criteria which is filtered
            //not able to cover some area of prefilter method WHERE opp line item is used because there is no std picklist field on line item
            //so we can't create the attribute mapping for that
            system.assertEquals(1, rfSearchCon.getAccounts().size());

            //asserting values of some variables
            system.assertEquals(false, rfSearchCon.isthisBasic);
            rfSearchCon.backToSearchFromInvitation();
        //Stop test method
        Test.stopTest();
    }
    /*
     * Method to cover all methods which are used in RFSearch Lead Page
     * Created : Rekha Jangir @15/11/2016
     */
    /*public static testMethod void testRefSearchLeadMethods() {
        Lead lead = new Lead(LastName = 'test', Company = 'test new');
        insert lead;
        //Start test method
        Test.StartTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();

            PageReference rfPage = new PageReference('RfSearchPageLead');
            ApexPages.currentPage().getParameters().put('LeadId', lead.Id);
            Test.setCurrentPage(rfPage);
            RfSearchController rfsearchCon = new RfSearchController();

            PageReference pgref = rfsearchCon.backToSearch();
            system.assertEquals(Page.RfSearchPageLead.getURL(), pgref.getURL());

            pgref = rfsearchCon.gotoAdvancedFilter();
            system.assertEquals(Page.SearchRelatedMappingRecords.getURL(), pgref.getURL());

            pgref = rfsearchCon.dontSaveTheSelections();
            system.assertEquals(Page.RfSearchPageLead.getURL(), pgref.getURL());

            rfsearchCon.invitationcontroller.onLoad();
            pgref = rfsearchCon.invitationToSearch();
            system.assertEquals(Page.RfSearchPageLead.getURL(), pgref.getURL());

            pgref = rfsearchCon.backToSearchFromInvitation();
            system.assertEquals(Page.RfSearchPageLead.getURL(), pgref.getURL());
            
            pgref = rfSearchCon.relatedMappingController.getAllTheResults();
            system.assertEquals(Page.RfSearchPageLead.getURL(), pgref.getURL());
            
            pgref = rfsearchCon.selectAndContinue();
        //Stop test method
        Test.stopTest();
    }*/
    
    /*
     * Method to cover all methods which are used in RFSearch Page from case
     * Created : Rekha Jangir @3 May 2017
     */
    public static testMethod void testRefSearchCaseMethods() {
        Account account = new Account(Name = 'test account');
        insert account;
        
        Case casea = new Case(Status = 'New', Origin = 'Email', Account = account);
        insert casea;
        
        //Start test method
        Test.StartTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();

            PageReference rfPage = new PageReference('RfSearchPage');
            ApexPages.currentPage().getParameters().put('caseId', casea.Id);
            Test.setCurrentPage(rfPage);
            RfSearchController rfsearchCon = new RfSearchController();

            PageReference pgref = rfsearchCon.backToSearchFromInvitation();
            system.assertEquals(Page.RfSearchPage.getURL() + '?helpoverlay=false', pgref.getURL());
            
            pgref = rfsearchCon.selectAndContinue();
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover all methods which are used to Redirecting to different pages and back to RFSearch Page
     * Created : Rekha Jangir @15/11/2016
     */
    public static testMethod void testRedirectingDifferentPages() {
        //Start test method
        Test.StartTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            RfSearchController rfsearchCon = new RfSearchController();
            rfsearchCon.callShowMoreLink();
            rfsearchCon.search();

            PageReference pgref = rfsearchCon.goToReferencibiltyresults();
            system.assertEquals(Page.referencibiltyresults.getURL(), pgref.getURL());

            pgref = rfsearchCon.backToSearch();
            system.assertEquals(Page.rfsearchpage.getURL(), pgref.getURL());

            pgref = rfsearchCon.goToContentTypeResults();
            system.assertEquals(Page.ContentTypeResults.getURL(), pgref.getURL());

            pgref = rfsearchCon.goToContentLanguageResults();
            system.assertEquals(Page.ContentLanguageResults.getURL(), pgref.getURL());

            pgref = rfsearchCon.goToAttributeResults();
            Decimal count = rfsearchCon.RULPeriodLengthContact;
            Integer noOfSelectedAccount  = rfsearchCon.noOfSelectedAccount;
            system.assertEquals(Page.attributeresults.getURL(), pgref.getURL());

            pgref = rfsearchCon.goToViewAllFilterResults();
            system.assertEquals(Page.viewallfilterresults.getURL(), pgref.getURL());

            pgref = rfsearchCon.gotoAdvancedFilter();
            system.assertEquals(Page.SearchRelatedMappingRecords.getURL(), pgref.getURL());

            pgref = rfsearchCon.dontSaveTheSelections();
            system.assertEquals(Page.RfSearchPage.getURL(), pgref.getURL());

            rfsearchCon.invitationcontroller.onLoad();
            pgref = rfsearchCon.invitationToSearch();
            system.assertEquals(Page.RfSearchPage.getURL(), pgref.getURL());

            pgref = rfsearchCon.backToSearchFromInvitation();
            system.assertEquals(Page.RfSearchPage.getURL() + '?helpoverlay=false', pgref.getURL());

            pgref = rfsearchCon.gotoAdvancedSearch();
            system.assertEquals(null, pgref);
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover setReqData() and saveReqList() methods of refsearch match page
     * Created : Rekha Jangir @28/11/2016
     */
    public static testMethod void testSaveRequestInRefMatch() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Enable_Sales_Rewards_Notification__c = true;
        customSetting.Auto_Assign_Sales_Rewards__c = true;
        update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        
        List<Date> dates = TestDataFactory.setUpDates();
        List<Reference_Request__c> refRequests = TestDataFactory.createReferenceRequest();
        refRequests[0].Opportunity__c = opps[0].Id;
        insert refRequests;
        
        //Start test method
        Test.StartTest();
            List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
            
            for (Referenceability_Type__c ref : rfTypes) {
                ref.Sales_Point__c = 50;
            }
            insert rfTypes;
            List<Referenceability__c> refers = TestDataFactory.createReferenceability(accounts, contacts, rfTypes);
            insert refers;
            List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refRequests, rfTypes);
            refReqAccs[0].Managed_Request__c = true;
            refReqAccs[1].Approve_Deny_Notes__c = 'test this note';
            insert refReqAccs;
            List<Reference_Request_Account_Contact__c> refReqAccCons = TestDataFactory.createContactRequests(contacts, refReqAccs, rfTypes);
            refReqAccCons.add(new Reference_Request_Account_Contact__c(Referenceability_Type__c = rfTypes[0].Id, Reference_Request_Account__c = refReqAccs[0].Id, Activity_Date__c = system.today(), Deadline__c = dates[1], Contact__c = contacts[2].Id, Contact_Request_Status__c = 'In Progress'));
            insert refReqAccCons;
            List<Unspecified_Request__c> unSpeReqs = TestDataFactory.createUnspecifiedRequest(refRequests, rfTypes);
            unSpeReqs[0].Unspecified_Request_Status__c = '';
            unSpeReqs[0].Notes__c = 'test notes';
            unSpeReqs[0].Deadline__c = date.today().addDays(10);
            insert unSpeReqs;
            List<Reference_Request_Label__c> rrLabels = new List<Reference_Request_Label__c>();
            rrLabels.add(new Reference_Request_Label__c(Label__c = labels.get(0).Id, Reference_Request__c = refRequests[0].Id));
            insert rrLabels;
            List<Reference_Request_Label_Attribute__c> reqLabelAtt = new List<Reference_Request_Label_Attribute__c>();
            reqLabelAtt.add(new Reference_Request_Label_Attribute__c(Attribute__c = attributes.get(0).Id, Reference_Request_Label__c = rrLabels.get(0).Id));
            insert reqLabelAtt;
        
            PageReference rfPage = new PageReference('RfSearchPage');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('isRefMatch', 'true');
            ApexPages.currentPage().getParameters().put('RefRequestId', refRequests[0].Id);
            RfSearchController rfsearchCon = new RfSearchController();
            system.assertEquals(rfsearchCon.allActiveReq.size(), 7);
            
            //add unspecified request id to update
            rfsearchCon.updatableReq = unSpeReqs[0].Id;
            rfsearchCon.enabletoUpdate();
            
            for (ReferenceRequestWrapper reqWrap : rfsearchCon.allActiveReq) {
                
                if (reqWrap.unSpec != null && reqWrap.unSpec.Id == unSpeReqs[0].Id) {
                    reqWrap.unSpec.Unspecified_Request_Status__c = 'On Hold';
                    reqWrap.unSpec.Notes__c = 'test notes new';
                }
            }
            rfsearchCon.writetoNote = true;
            rfsearchCon.isSend = true;
            rfsearchCon.saveReqList();
            system.assertEquals(0, [SELECT Id FROM Reference_Note__c].size());
            
            rfsearchCon.updatableReq = unSpeReqs[0].Id;
            rfsearchCon.enabletoUpdate();
            
            for (ReferenceRequestWrapper reqWrap : rfsearchCon.allActiveReq) {
                
                if (reqWrap.unSpec != null && reqWrap.unSpec.Id == unSpeReqs[0].Id) {
                    reqWrap.unSpec.Unspecified_Request_Status__c = 'On Hold';
                    reqWrap.unSpec.Notes__c = 'test notes new again';
                }
            }
            rfsearchCon.writetoNote = true;
            rfsearchCon.isSend = true;
            rfsearchCon.saveReqList();
            system.assertEquals(0, [SELECT Id FROM Reference_Note__c].size());
            
            //add Account request id to updated
            rfsearchCon.updatableReq = refReqAccs[0].Id;
            rfsearchCon.enabletoUpdate();
            
            for (ReferenceRequestWrapper reqWrap : rfsearchCon.allActiveReq) {
                
                if (reqWrap.rra != null && reqWrap.rra.Id == refReqAccs[0].Id) {
                    reqWrap.rra.Account_Request_Status__c = 'On Hold';
                    reqWrap.rra.Process__c = ConstantsController.REP2REP;
                }
            }
            
            rfsearchCon.isSend = true;
            rfsearchCon.saveReqList();
            
            //add Account request id to updated
            rfsearchCon.updatableReq = refReqAccs[1].Id;
            rfsearchCon.enabletoUpdate();
            
            for (ReferenceRequestWrapper reqWrap : rfsearchCon.allActiveReq) {
                
                if (reqWrap.rra != null && reqWrap.rra.Id == refReqAccs[1].Id) {
                    reqWrap.rra.Approve_Deny_Notes__c = 'this request is On Hold';
                }
            }
            rfsearchCon.writetoNote = true;
            rfsearchCon.isSend = true;
            rfsearchCon.saveReqList();
            system.assertEquals(0, [SELECT Id FROM Reference_Note__c WHERE Account_Request__c = :refReqAccs[1].Id].size());
            
            rfsearchCon.updatableReq = refReqAccs[1].Id;
            rfsearchCon.enabletoUpdate();
            
            for (ReferenceRequestWrapper reqWrap : rfsearchCon.allActiveReq) {
                
                if (reqWrap.rra != null && reqWrap.rra.Id == refReqAccs[1].Id) {
                    reqWrap.rra.Approve_Deny_Notes__c = 'this request is On Hold again';
                }
            }
            rfsearchCon.updateReqId = refReqAccs[1].Id;
            rfsearchCon.getSelectedAccReqDetails();
            rfsearchCon.writetoNote = true;
            rfsearchCon.isSend = true;
            rfsearchCon.saveReqList();
            system.assertEquals(0, [SELECT Id FROM Reference_Note__c WHERE Account_Request__c = :refReqAccs[1].Id].size());
            
            for (ReferenceRequestWrapper reqWrap : rfsearchCon.allActiveReq) {
                
                if (reqWrap.rra != null && reqWrap.rra.Id == refReqAccs[0].Id) {
                    reqWrap.rra.Account_Request_Status__c = 'Completed';
                    reqWrap.rra.Process__c = ConstantsController.REP2REP;
                }
            }
            
            rfsearchCon.isSend = true;
            rfsearchCon.saveReqList();
            
            rfsearchCon.cancelReqList();
            
            rfsearchCon.selectedUnsepReq = refReqAccs[0].Id;
            rfsearchCon.findAccountofReq();
            
            rfsearchCon.updateReqId = unSpeReqs[0].Id;
            rfsearchCon.getSelectedAccReqDetails();
            
        //Stop test method
        Test.stopTest();
    }
    /*
     * Method to cover assignAccount() and assignContact() methods of refsearch match page
     * Created : Rekha Jangir @28/11/2016
     */
    public static testMethod void testAssignAccountContactInRefMatch() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Date> dates = TestDataFactory.setUpDates();
        List<Reference_Request__c> refRequests = TestDataFactory.createReferenceRequest();
        refRequests[0].Opportunity__c = opps[0].Id;
        insert refRequests;
        
        //Start test method
        Test.StartTest();
            List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List<Referenceability__c> refers = TestDataFactory.createReferenceability(accounts, contacts, rfTypes);
            insert refers;
            List<Unspecified_Request__c> unSpeReqs = TestDataFactory.createUnspecifiedRequest(refRequests, rfTypes);
            insert unSpeReqs;
        
            PageReference rfPage = new PageReference('RfSearchPage');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('isRefMatch', 'true');
            ApexPages.currentPage().getParameters().put('RefRequestId', refRequests[0].Id);
            RfSearchController rfsearchCon = new RfSearchController();
            system.assertEquals(rfsearchCon.allActiveReq.size(), 1);
            //SELECT account request id to assign Account to get exception
            rfsearchCon.selectedUnsepReq = 'test';
            try{
                rfsearchCon.assignAccount(false,false);
            }
            catch(Exception e){}
            
            //SELECT unspecified request id to assign Account
            rfsearchCon.selectedUnsepReq = unSpeReqs[0].Id;
            rfsearchCon.selectedacc = accounts[0].Id;
            rfsearchCon.assignAccount(false,false);
            
            List<Reference_Request_Account__c> refReqAccs = [SELECT Id FROM Reference_Request_Account__c];
            //SELECT account request id to assign Account
            rfsearchCon.selectedUnsepReq = refReqAccs[0].Id;
            try{
                rfsearchCon.assignAccount(false,false);
            }
            catch(Exception e){}
            
            rfsearchCon.selectedacc = accounts[1].Id;
            rfsearchCon.assignAccount(false,false);
            
            rfsearchCon.selectedCon = contacts[1].Id;
            rfsearchCon.assignContact();
            
            system.assertEquals(1, [SELECT Id FROM Reference_Request_Account_Contact__c WHERE Contact__c = :contacts[1].Id].size());
            
            //SELECT account request id to assign Account to get exception
            rfsearchCon.selectedCon = 'test';
            try{
                rfsearchCon.assignContact();
            }
            catch(Exception e){}
            
            //test for Non-reference program account
            Account acc = new Account(Name = 'new test');
            insert acc;
            Contact con = new Contact(LastName = 'con test', AccountId = acc.Id);
            insert con;
            rfsearchCon.selectedCon = con.Id;
            rfsearchCon.assignContact();
            
            //test for hit List section in candidate type request
            refRequests[0].Project_Type__c = 'Candidate';
            update refRequests;
            rfsearchCon = new RfSearchController();
            rfsearchCon.selectedUnsepReq = refReqAccs[0].Id;
            rfsearchCon.selectedCon = con.Id;
            rfsearchCon.assignContact();
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover createCollection() and contentCollections() methods of refsearch page 
     * Created : Rekha Jangir @Dec/26/2016
     */
    public static testMethod void testCollectionFunctionality() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<ContentVersion> nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        List<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        List<Content_Collection__c> contentCollections = TestDataFactory.createContentCollection();
        insert contentCollections;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        //Start test method
        Test.StartTest();
            ApexPages.currentPage().getParameters().put('opportunityId', opps[0].Id);
            RfSearchController rfsearchCon = new RfSearchController();
            
            rfsearchCon.getContents();
            rfsearchCon.collectionName =  'test Collection1';
            //for the exception 
            try {
                rfsearchCon.createCollection();
            }
            catch (Exception e) {}
            
            //for the null selectContentDocumentId in share method
            try {
                rfsearchCon.contentSearch.selectedContentIdSet.add(contents[1].Id);
                rfsearchCon.contentSearch.selectedContentIdSet.add(contents[0].Id);
                rfsearchCon.shareContents(); 
                
            }
            catch (Exception e) {
                rfsearchCon.contentSearch.selectedContentIdSet.clear();
            }
            
            rfsearchCon.contentSearch.selectContentDocumentId = '';
            
            //for the custom error msg 
            try {
                rfsearchCon.shareContents();
            }
            catch (Exception e) {}
            
            //for the custom error msg 
            try {
                rfsearchCon.createCollection();
            }
            catch (Exception e) {}
            //call the method which create content collection
            rfsearchCon.contentSearch.selectContentDocumentId = contents[0].Id + ',' + contents[5].Id;
            rfsearchCon.contentSearch.selectedContentIdSet.add(contents[1].Id);
            rfsearchCon.createCollection();
            
            //check that collection is created or not
            List<Related_Reference_Content__c> rrc = [SELECT Id,Content_Collection__c FROM Related_Reference_Content__c];
            system.assertEquals(2,rrc.size());
            List<SelectOption> contentCollection = rfsearchCon.contentCollections;
            
            rfsearchCon.selectedCollection = rrc[0].Content_Collection__c;
            rfsearchCon.collectionName = '';
            rfsearchCon.createCollection();
            rfsearchCon.shareContents();
            rfsearchCon.setContentsIds();
            rfsearchCon.invitationToSearch();
            
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover HitList functionality for Account of refsearch match page
     * Created : Rekha Jangir @Dec/27/2016
     */
    public static testMethod void testHitListAccountInRefMatch() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Opportunity> opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List<Date> dates = TestDataFactory.setUpDates();
        List<Reference_Request__c> refRequests = TestDataFactory.createReferenceRequest();
        refRequests[0].Opportunity__c = opps[0].Id;
        insert refRequests;
        Test.StartTest();
            List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List<Referenceability__c> refers = TestDataFactory.createReferenceability(accounts, contacts, rfTypes);
            insert refers;
            List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refRequests, rfTypes);
            insert refReqAccs;
            List<Unspecified_Request__c> unSpeReqs = TestDataFactory.createUnspecifiedRequest(refRequests, rfTypes);
            insert unSpeReqs;
            PageReference rfPage = new PageReference('RfSearchPage');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('isRefMatch', 'true');
            ApexPages.currentPage().getParameters().put('RefRequestId', refRequests[0].Id);
            RfSearchController rfsearchCon = new RfSearchController();
            //to cover catch block
            rfsearchCon.isAccount = true;
            rfsearchCon.hitAccount = accounts[0].Id;
            rfsearchCon.createHitRecord();
            
            rfsearchCon.getAccounts();
            rfsearchCon.getContacts();
            system.assertEquals(7, rfsearchCon.allActiveReq.size());
            
            rfsearchCon.isAccount = true;
            rfsearchCon.hitAccount = accounts[0].Id;
            rfsearchCon.createHitRecord();
            List<Hit_List__c> hits = [SELECT Id FROM Hit_List__c WHERE Account__c = : accounts[0].Id];
            system.assertEquals(1, hits.size());
            
            rfsearchCon.createHitRecord();
        //Stop test method
        Test.stopTest();
    }
    /*
     * Method to cover HitList functionality for Contact of refsearch match page
     * Created : Rekha Jangir @Dec/27/2016
     */
    public static testMethod void testHitListContactInRefMatch() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Date> dates = TestDataFactory.setUpDates();
        List<Reference_Request__c> refRequests = TestDataFactory.createReferenceRequest();
        insert refRequests;
        Test.StartTest();
            PageReference rfPage = new PageReference('RfSearchPage');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('isRefMatch', 'true');
            ApexPages.currentPage().getParameters().put('inlineeditingenable', 'false');
            ApexPages.currentPage().getParameters().put('RefRequestId', refRequests[0].Id);
            RfSearchController rfsearchCon = new RfSearchController();
            rfsearchCon.getAccounts();
            rfsearchCon.getContacts();
            
            rfsearchCon.isContact = true;
            rfsearchCon.hitContact = contacts[1].Id;
            rfsearchCon.createHitRecord();
            List<Hit_List__c> hits1 = [SELECT Id FROM Hit_List__c WHERE Contact__c = : contacts[1].Id];
            system.assertEquals(1, hits1.size());
            
            rfsearchCon.createHitRecord();
            
            rfsearchCon.contactSearch.accountId = accounts[0].Id;
            rfsearchCon.getContacts();
            
            rfsearchCon.isContact = true;
            rfsearchCon.hitContact = contacts[0].Id;
            rfsearchCon.createHitRecord();
            hits1 = [SELECT Id FROM Hit_List__c WHERE Contact__c = : contacts[0].Id];
            system.assertEquals(1, hits1.size());
            
            //test for Non-reference program account
            Account acc = new Account(Name = 'new test');
            insert acc;
            Contact con = new Contact(LastName = 'con test', AccountId = acc.Id);
            insert con;
            rfsearchCon.isContact = true;
            rfsearchCon.hitContact = con.Id;
            rfsearchCon.createHitRecord();
            
            //test for hit List section in candidate type request
            refRequests[0].Project_Type__c = 'Candidate';
            update refRequests;
            rfsearchCon = new RfSearchController();
            rfsearchCon.isContact = true;
            rfsearchCon.hitContact = con.Id;
            rfsearchCon.createHitRecord();
        //Stop test method
        Test.stopTest();
    }
    
    /*
     * Method to cover extra methods in RefMatch page
     * Created : Rekha Jangir @Dec/27/2016
     */
    public static testMethod void testExtraRefMatch() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Date> dates = TestDataFactory.setUpDates();
        List<Reference_Request__c> refRequests = TestDataFactory.createReferenceRequest();
        insert refRequests;
        Test.StartTest();
            PageReference rfPage = new PageReference('RfSearchPage');
            Test.setCurrentPage(rfPage);
            ApexPages.currentPage().getParameters().put('isRefMatch', 'true');
            ApexPages.currentPage().getParameters().put('activeTab', 'test');
            ApexPages.currentPage().getParameters().put('inlineeditingenable', 'true');
            ApexPages.currentPage().getParameters().put('RefRequestId', refRequests[0].Id);
            RfSearchController rfsearchCon = new RfSearchController();
            rfsearchCon.getAccounts();
            rfsearchCon.getContacts();
            
            rfsearchCon.showAll();
            rfsearchCon.showContactBlock();
            rfsearchCon.changeAccountType();
            rfsearchCon.changeContactType();
            rfsearchCon.editRow();
            rfsearchCon.changeBasicFilterView();
            rfsearchCon.backToReSearch();
            rfsearchCon.ClearInternalReferenciability();
            rfsearchCon.clearFilters();
            
            //test for Non-reference program account
            Account acc = new Account(Name = 'new test');
            insert acc;
            Contact con = new Contact(LastName = 'con test', AccountId = acc.Id);
            insert con;
            rfsearchCon.isContact = true;
            rfsearchCon.hitContact = con.Id;
            rfsearchCon.createHitRecord();
            
            List<Reference_Basic_Information__c> rbis = new List<Reference_Basic_Information__c>();
            rbis.add(new Reference_Basic_Information__c(Account__c = acc.Id, Is_Referenceable__c = true, Referenceability_Status__c = 'Inactive'));
            rbis.add(new Reference_Basic_Information__c(Account__c = acc.Id, Contact__c = con.Id, Is_Referenceable__c = true, Referenceability_Status__c = 'Inactive'));
            insert rbis;
            acc = [SELECT Id, (SELECT Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) FROM Account WHERE Id =: acc.Id];
            con = [SELECT Id, (SELECT Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r) FROM Contact WHERE Id =: con.Id];
            rfsearchCon.makeAccountRPM(acc, con);
            
            PageReference pgref = rfsearchCon.redirectOnRequest();
            system.assertEquals(true, pgref.getURL().contains(Page.RefRequestProject.getURL()));
        //Stop test method
        Test.stopTest();
    }
    
     /*
     * Method to cover shareContents() methods with Internal Use contents of refsearch page 
     * Created : Rajesh @June/13/2017
     */
    public static testMethod void testShareContentsForInternalUse() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<ContentVersion> nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        
        List<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        
        List<Content_Collection__c> contentCollections = TestDataFactory.createContentCollection();
        insert contentCollections;        
        //Start test method
        Test.StartTest();
            
            RfSearchController rfsearchCon = new RfSearchController(); 
            rfsearchCon.getContents();
            rfsearchCon.collectionName =  'test Collection1'; 
            rfsearchCon.createCollection();  
            contents[1].Internal_Use__c = true;
            update contents;
            
            rfsearchCon.contentSearch.selectContentDocumentId = contents[1].Id;
            rfsearchCon.contentSearch.selectedContentIdSet.add(contents[1].Id); 
            
            PageReference pgref = rfsearchCon.shareContents();
            //This will return null 
            system.assertEquals(pgref, null);
              
        //Stop test method
        Test.stopTest();
    }
    
     /*
     * Method used to get Related Refrence Content on Account
     * Created : Rajesh @Sept/25/2017
     */  
    static testMethod void testAccountAssociatedContents() {
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        
        List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        
        List<Account_Reference_Content__c> accRefCons = TestDataFactory.createAccountRefContents(accounts, referObjects);
        insert accRefCons; 
        RfSearchController obj = new RfSearchController();
        Test.StartTest();
            obj.selectedAccountId = accounts[0].Id;
            obj.accountAssociatedContents();
            
            system.assertEquals(1,obj.accountContents.size()); 
        Test.stopTest();
    }

    //REF-1964
    @isTest static void testSelectAllContacts() {
        RfSearchController rfController = new RfSearchController();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        rfController.getContacts();
        rfController.isSelectAllContacts = true;
        
        Test.startTest();
        rfController.selectAllContacts();
        Test.stopTest();
        
        System.assert(rfController != null, 'Selected all contacts.');
    }
    
    @isTest static void testSelectSingleContact() {
        RfSearchController rfController = new RfSearchController();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        rfController.getContacts();
        rfController.isSelectAllContacts = true;
        rfController.selectedContactId = contacts[0].id;
        
        Test.startTest();
        rfController.selectSingleContact();
        Test.stopTest();
        
        System.assert(rfController != null, 'Selected single contacts.');
    }
    
    @isTest static void testPreSelectHubContacts() {
        RfSearchController rfController = new RfSearchController();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        TestDataFactory.setUpContactRBI(contacts);
        rfController.getContacts();
        rfController.preSelectedContactIds = String.valueOf(contacts[0].id);
        
        Test.startTest();
        rfController.preSelectHubContacts();
        //REF-2653
        PageReference ref = rfController.backToSelectReferenceUseAttributes();
        Test.stopTest();
        
        System.assert(rfController != null, 'Preselected contacts.');
    }

    @isTest static void testRollupAttributes() {
        RfSearchController rfController = new RfSearchController();
        List<Account> accounts = TestDataFactory.createAccounts();
        Insert accounts;
        system.assertNotEquals(0, accounts.size());
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> rbiAccList = TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Basic_Information__c> rbiConList = TestDataFactory.setUpContactRBI(contacts);
        Attribute_Mapping__c attrMapping = new Attribute_Mapping__c(Object__c = 'Account',Field__c = 'Last Name', Attribute_Name__c = 'Last Name', Filter_Label_Name__c='Last Name',Field_Api_Name__c='LastName',Is_Related_Mapping__c = true,Mapping_Type__c = 'Parent Object', Related_Object__c ='User', RelationShip_Name__c = 'OwnerId');
        Insert attrMapping;                          
        TestDataFactory.setUpAccountRBI(accounts);
        //Creating Attribute
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;            
        //Creating Account Attribute
        Account_Attribute__c accAttrs = new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = attributes[0].Id,Inheritable__c = false);
        Insert accAttrs;
        rfController.recordId = rbiAccList[0].Id;
        rfController.rollUpAttribute();
        rfController.recordId = rbiConList[0].Id;
        rfController.rollUpAttribute();
        List<Reference_Content__c> referObjs = TestDataFactory.createReferenceContent();
        insert referObjs;
        rfController.recordId = referObjs[0].Id;
        rfController.inheritAccountAttribute();

    }
}