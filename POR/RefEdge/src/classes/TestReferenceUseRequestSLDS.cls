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
 * Class : ReferenceUseRequestSLDS
 * Description :Test class for Reference Use Request
 * Modified by: Rajesh @25 April 2017
 */ 
@isTest(seeAllData = false)
public with sharing class TestReferenceUseRequestSLDS {
	public static List<Account> accounts;
    public static Opportunity opp;
    public static List<Referenceability_Type__c> rfTypes;
    public static Custom_Settings__c customSetting;
    public static List<Reference_Type_Mapping__c> rtmapping;
    public static List<Label__c> labels;
    public static List<Attribute__c> attributes;
    public static List<Attributes_Labels__c> attLabels;
    public static User u;
    
    static testMethod void testSelecteAndUpdate() { 
        try {
            setUpData();
            //Start Test method
            test.startTest();
            	ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
                ApexPages.currentPage().getParameters().put('accountIds', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                ReferenceUseRequestSLDS obj = new ReferenceUseRequestSLDS();
                Custom_Settings__c cs = ReferenceUseRequestSLDS.fetchCS();
                system.assertNotEquals(null, obj.salesRewardMsg);
                
                //REF-2496
            	String accsString = ReferenceUseRequestSLDS.getAccountRquestss(obj.accountIds);
                List<ReferenceUseRequestSLDS.ReferenceUseAccountWrapper> accs = 
                    (List<ReferenceUseRequestSLDS.ReferenceUseAccountWrapper>)JSON.deserialize(accsString, List<ReferenceUseRequestSLDS.ReferenceUseAccountWrapper>.class);
                    
                List<ReferenceUseRequestSLDS.RefTypeWrapper> refs = (List<ReferenceUseRequestSLDS.RefTypeWrapper>)JSON.deserialize(ReferenceUseRequestSLDS.getRefTypes1(String.valueOf(cs.Minimum_Deadline__c)), List<ReferenceUseRequestSLDS.RefTypeWrapper>.class);
                
                Map<String, ReferenceUseRequestSLDS.FieldWrapper> fieldMap = ReferenceUseRequestSLDS.getAddFields();
                ReferenceUseRequestSLDS.DateWrapper d = new ReferenceUseRequestSLDS.DateWrapper();
                d.deadLineDate = date.today();
                d.days = 4;
                Map<Integer, ReferenceUseRequestSLDS.ReferenceUseAccountWrapper> accMap = new map<Integer, ReferenceUseRequestSLDS.ReferenceUseAccountWrapper>();
                
                for (Integer i = 0; i<accs.size(); i++) {
                	accs[i].referenceType = rfTypes[0].Id;
                	accs[i].deadline = date.today();
                	accMap.put(i+1, accs[i]);
                }
                Map<String, ReferenceUseRequestSLDS.RefTypeWrapper> refMap = new Map<String, ReferenceUseRequestSLDS.RefTypeWrapper>();
                
                for (ReferenceUseRequestSLDS.RefTypeWrapper r : refs) {
                	refMap.put(r.ref.id , r);
                }
                Date date1 = ReferenceUseRequestSLDS.calculateDate(JSON.serialize(d));
                String dateResult = ReferenceUseRequestSLDS.checkforWeekend(JSON.serialize(d));
                Set<String> refIds = new Set<String> {rfTypes[0].Id, rfTypes[1].Id};
                String getFiltersResult = ReferenceUseRequestSLDS.getFilters1(JSON.serialize(refIds)+ '@@'+ ''+'@@'+ true);
                Map<String, ReferenceUseRequestSLDS.LabelWrapper> labelW = (Map<string, ReferenceUseRequestSLDS.LabelWrapper>)JSON.deserialize(getFiltersResult, Map<string, ReferenceUseRequestSLDS.LabelWrapper>.class);
                Map<String, ReferenceUseRequestSLDS.RefAddiFieldWrapper> addFields = ReferenceUseRequestSLDS.getRefAddFields(JSON.serialize(fieldMap),JSON.serialize(accMap),JSON.serialize(refIds));
                Map<String, List<ReferenceUseRequestSLDS.AttributesLabelWrapper>> allAtts = (Map<String, List<ReferenceUseRequestSLDS.AttributesLabelWrapper>>)JSON.deserialize(ReferenceUseRequestSLDS.getAllFilterAttributes1(JSON.serialize(new Set<String> {labels[0].Id, labels[1].Id})), Map<String, List<ReferenceUseRequestSLDS.AttributesLabelWrapper>>.class);
                String result = ReferenceUseRequestSLDS.submitRequest(JSON.serialize(accMap), JSON.serialize(addFields), JSON.serialize(labelW), JSON.serialize(refIds), JSON.serialize(refMap), opp.Id, '', 'true');
            	result = ReferenceUseRequestSLDS.submitRequest(JSON.serialize(accMap), JSON.serialize(addFields), JSON.serialize(labelW), JSON.serialize(refIds), JSON.serialize(refMap), opp.Id, '', 'false');
            	
            	system.assertNotEquals('', result);
            //Stop Test method
            test.stopTest();
        } catch(Exception e) {
            system.assert(false, e.getMessage());
        }
    }
    
    static testMethod void testSelecteAndUpdate1() {
        try {
            setUpData();
            List<Case> cases = TestDataFactory.createCases(accounts);
        	insert cases;
        	
            //Start Test method
            test.startTest();
            	ApexPages.currentPage().getParameters().put('caseId', cases[0].Id);
                ReferenceUseRequestSLDS obj = new ReferenceUseRequestSLDS();
                system.assertNotEquals(null, obj.isThisBasic);
                system.assertNotEquals(null, obj.userDateFormat);
                Custom_Settings__c cs = ReferenceUseRequestSLDS.fetchCS();

                //REF-2496
            	String accsString = ReferenceUseRequestSLDS.getAccountRquestss(obj.accountIds);
                List<ReferenceUseRequestSLDS.ReferenceUseAccountWrapper> accs = 
                    (List<ReferenceUseRequestSLDS.ReferenceUseAccountWrapper>)JSON.deserialize(accsString, List<ReferenceUseRequestSLDS.ReferenceUseAccountWrapper>.class);

                List<ReferenceUseRequestSLDS.RefTypeWrapper> refs = (List<ReferenceUseRequestSLDS.RefTypeWrapper>)JSON.deserialize(ReferenceUseRequestSLDS.getRefTypes1(String.valueOf(cs.Minimum_Deadline__c)), List<ReferenceUseRequestSLDS.RefTypeWrapper>.class);
                Map<String, ReferenceUseRequestSLDS.FieldWrapper> fieldMap = ReferenceUseRequestSLDS.getAddFields();
                ReferenceUseRequestSLDS.DateWrapper d = new ReferenceUseRequestSLDS.DateWrapper();
                d.deadLineDate = date.today();
                d.days = 4;
                Map<Integer, ReferenceUseRequestSLDS.ReferenceUseAccountWrapper> accMap = new Map<Integer, ReferenceUseRequestSLDS.ReferenceUseAccountWrapper>();
                
                for (Integer i = 0; i <accs.size(); i++) {
                	accs[i].referenceType = rfTypes[0].Id;
                	accs[i].deadline = date.today();
                	accMap.put(i+1, accs[i]);
                }
                Map<String, ReferenceUseRequestSLDS.RefTypeWrapper> refMap = new Map<String, ReferenceUseRequestSLDS.RefTypeWrapper>();
                
                for (ReferenceUseRequestSLDS.RefTypeWrapper r : refs) {
                	refMap.put(r.ref.id, r);
                }
                Date date1 = ReferenceUseRequestSLDS.calculateDate(JSON.serialize(d));
                String dateResult = ReferenceUseRequestSLDS.checkforWeekend(JSON.serialize(d));
                Set<String> refIds = new Set<String> {rfTypes[0].Id, rfTypes[1].Id};
                String getFiltersResult = ReferenceUseRequestSLDS.getFilters1(JSON.serialize(refIds)+ '@@'+ ''+'@@'+ true);
                Map<String, ReferenceUseRequestSLDS.LabelWrapper> labelW = (Map<string, ReferenceUseRequestSLDS.LabelWrapper>)JSON.deserialize(getFiltersResult, Map<string, ReferenceUseRequestSLDS.LabelWrapper>.class);
                Map<String, ReferenceUseRequestSLDS.RefAddiFieldWrapper> addFields = ReferenceUseRequestSLDS.getRefAddFields(JSON.serialize(fieldMap), JSON.serialize(accMap), JSON.serialize(refIds));
                Map<String, List<ReferenceUseRequestSLDS.AttributesLabelWrapper>> allAtts = (Map<String, List<ReferenceUseRequestSLDS.AttributesLabelWrapper>>)JSON.deserialize(ReferenceUseRequestSLDS.getAllFilterAttributes1(JSON.serialize(new Set<String> {labels[0].Id, labels[1].Id})), Map<String, List<ReferenceUseRequestSLDS.AttributesLabelWrapper>>.class);
                String result = ReferenceUseRequestSLDS.submitRequest(JSON.serialize(accMap), JSON.serialize(addFields), JSON.serialize(labelW), JSON.serialize(refIds), JSON.serialize(refMap), opp.Id, '', 'false');
            	system.assertNotEquals('', result);
            //Stop Test method
            test.stopTest();
        } catch(Exception e) {
            system.assert(false, e.getMessage());
        }
    }
    
    //Data Setup
    static void setUpData() {
        customSetting = TestDataFactory.createCustomSetting();
        //customSetting.Auto_Assign_Sales_Rewards__c = true;
        customSetting.Managed_Request_Opportunity_Threshold__c = 1000;
        customSetting.Request_Peer2Peer_Chatter__c = true;
        customSetting.Request_Peer2Peer_Email__c = true;
        customSetting.Request_Managed_Chatter__c = true;
        customSetting.Request_Managed_Email__c = true;
        update customSetting;
        u = TestDataFactory.createUser();
        accounts = TestDataFactory.createAccounts();
        insert accounts; 
        
        TestDataFactory.setUpAccountRBI(accounts);
        opp = TestDataFactory.createOpportunity(accounts)[0];
        opp.Amount = 1111700;
        insert opp;
        
        rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        
        labels = TestDataFactory.createLabels();
        insert labels;
        
        attributes = TestDataFactory.createAttribute();
        insert attributes;
        
        TestDataFactory.createAttributeLabels(labels, attributes);
        //attLabels = createAttributeLabel();
        //insert attLabels;
        rtmapping = createReferenceTypeMapping();
        insert rtmapping;
    }
    
    //Reference_Type_Mapping Setup
    static List<Reference_Type_Mapping__c> createReferenceTypeMapping() {
        List<Reference_Type_Mapping__c> tempRefMapping = new List<Reference_Type_Mapping__c>();
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Name = 'OwnerId'));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(0).Id));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(1).Id));
        return tempRefMapping;
    }
    
    @isTest static void testGetFilesAssociatedWithReferenceRequest() {
        List<Reference_Request__c> rrList = TestDataFactory.createReferenceRequest();
        insert rrList;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = rrList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        Test.startTest();
        String result = ReferenceUseRequestSLDS.getFilesAssociatedWithReferenceRequest(rrList[0].id);
        Test.stopTest();
        
        System.assert(result != null, 'Got files associated with request.');
    }
}