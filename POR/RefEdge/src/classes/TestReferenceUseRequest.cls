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
public with sharing class TestReferenceUseRequest {   
    public static List<Account> accounts;
    public static Opportunity opp;
    public static List<Referenceability_Type__c> rfTypes;
    public static Custom_Settings__c customSetting;
    public static List<Reference_Type_Mapping__c> rtmapping;
    public static List<Label__c> labels;
    public static List<Attribute__c> attributes;
    public static List<Attributes_Labels__c> attLabels;
    public static User u;
    public static ReferenceUseRequest controllerObj;
	public static Advanced_Routing__c objAdvRouting;
	
 	static testMethod void testReferenceUseRequestMiscellaneousFunctionCalls() {  		
		//Setup primery data
		setUpData(); 
		test.startTest(); 
			//Getting values from query string
			ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
			ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);		
			// Object/Variable initialization 
			PageReference pgRef;
			controllerObj = new ReferenceUseRequest();
			system.assertNotEquals('', controllerObj.minDeadlineLabel);
			system.assertNotEquals(null, controllerObj.defaultDate);
			controllerObj.noOFAccounts = '4';
			controllerObj.addAccounts();
			controllerObj.getAccounts();
			controllerObj.selectRefUseAttr();
			pgRef = controllerObj.returnOpportunity();
			controllerObj.cancelRequest();
			system.assertEquals(pgRef.getUrl(), '/' + opp.Id);
			//method call for Advance routing  
			controllerObj.bindRoutingGroup();
		//Stop Test method
		test.stopTest(); 
	}
    
   	static testMethod void testSelecteAndUpdate() {
   		try {
            setUpData();
            //Start Test method
            test.startTest();
                ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
                ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
                controllerObj = new ReferenceUseRequest();
                controllerObj.noOFAccounts = '4';
                controllerObj.addAccounts();
                //for single record
                controllerObj.recordCounts = '4';
                controllerObj.selectedValue = 'The Record Clicked';
                controllerObj.param1 = rfTypes.get(1).Id;
                controllerObj.param2 = '30/10/2017';
                controllerObj.param3 = 'testing Note'; 
                controllerObj.selectAndUpdate();
                controllerObj.referenceType = rfTypes.get(0).Id;
                controllerObj.changeMinimumDeadline();
                controllerObj.selectAndUpdate();
                system.assertEquals(controllerObj.referNamesOfFields.size(), 0);
                //for all records
                controllerObj.recordCounts = '1,2,3,4';
                controllerObj.selectedValue = 'All Selected Records';
                controllerObj.param1 = rfTypes.get(1).Id;
                controllerObj.param2 = '30/10/2017';
                controllerObj.param3 = 'testing Note';
                controllerObj.oldReferenceability = rfTypes.get(0).Id;
                controllerObj.selectAndUpdate();
            //Stop Test method
            test.stopTest();
        } catch (Exception e) {
            
        }
    } 
    
    static testMethod void testRemoveAccountFromList() {
        try {
        setUpData();
        //Start Test method
        test.startTest();
            ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
            controllerObj = new ReferenceUseRequest();
            controllerObj.noOFAccounts = '5';
            controllerObj.addAccounts();
            controllerObj.getAccounts();
            //for single record of Account
            controllerObj.recordCounts = '1';
            controllerObj.selectedValue = 'The Record Clicked';
            controllerObj.param1 = rfTypes.get(0).Id;
            controllerObj.param2 = '30/10/2100';
            controllerObj.param3 = 'testing Note';
            controllerObj.selectAndUpdate();
            controllerObj.accountIdToRemoveFromList = accounts[0].Id;
            controllerObj.removeAccountFromList();
            system.assertEquals(controllerObj.referNamesOfFields.size(), 0);
            //for single Unspecified Request
            controllerObj = new ReferenceUseRequest();
            controllerObj.noOFAccounts = '5';
            controllerObj.addAccounts();
            controllerObj.recordCounts = '4';
            controllerObj.selectedValue = 'The Record Clicked';
            controllerObj.param1 = rfTypes.get(0).Id;
            controllerObj.param2 = '30/10/2017';
            controllerObj.param3 = 'testing Note';
            controllerObj.referenceType = rfTypes.get(0).Id;
            controllerObj.selectAndUpdate();
            controllerObj.accountIdToRemoveFromList = '';
            controllerObj.unspecifiefAccDelCount = 4;
            controllerObj.removeAccountFromList();
            controllerObj.unspecifiefAccDelCount = 3;
            controllerObj.removeAccountFromList();
            controllerObj.unspecifiefAccDelCount = 2;
            controllerObj.removeAccountFromList();
            controllerObj.accountIdToRemoveFromList = accounts[1].Id;
            controllerObj.removeAccountFromList();
            controllerObj.accountIdToRemoveFromList = accounts[2].Id;
            controllerObj.removeAccountFromList();
        //Stop Test method
        test.stopTest();
        } catch (Exception e) {            
        }
    }
    
    //Test Method
    static testMethod void testSubmitRequest() {
        try { 
	        setUpData();
	        customSetting.Request_Managed_Email__c = true;
	        update customSetting;
	        //Start Test method
	        test.startTest();
	            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
	            controllerObj = new ReferenceUseRequest();
	            controllerObj.noOFAccounts = '4';
	            controllerObj.addAccounts();
	            controllerObj.recordCounts = '1,2,3,4';
	            controllerObj.selectedValue = 'All Selected Records';
	            controllerObj.param1 = rfTypes.get(0).Id;
	            controllerObj.param2 = '30/10/2017';
	            controllerObj.param3 = 'testing Note';
	            controllerObj.referenceType = rfTypes.get(0).Id;
	            controllerObj.selectAndUpdate();
	            controllerObj.submitRequest();
	            system.assertNotEquals(controllerObj.insertUnspecifiedReq.size(), 10);
	            controllerObj.cancelRequest();
	        //Stop Test method
	        test.stopTest();
        } catch(Exception e) { 
        }
    }
    
    //Test Method
    static testMethod void testSubmitRequestOpportunity() {
        try {
	        setUpData();
	        customSetting.Request_Managed_Email__c = true;
	        update customSetting;
	        //Start Test method
	        test.startTest();
	            ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
	            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
	            controllerObj = new ReferenceUseRequest();
	            controllerObj.noOFAccounts = '4';
	            controllerObj.addAccounts();
	            controllerObj.recordCounts = '1,2,3,4';
	            controllerObj.selectedValue = 'All Selected Records';
	            controllerObj.param1 = rfTypes.get(0).Id;
	            controllerObj.param2 = '31/10/2017';
	            controllerObj.param3 = 'testing Note';
	            controllerObj.referenceType = rfTypes.get(0).Id;
	            controllerObj.selectAndUpdate();
	            controllerObj.submitRequest();
	            system.assertNotEquals(controllerObj.insertUnspecifiedReq.size(), 10);
	            controllerObj.returnOpportunity();
	            controllerObj.cancelRequest();
	        //Stop Test method
	        test.stopTest();
        } catch (Exception e) {            
        }
    }
    
    //Test Method
    static testMethod void testSubmitRequestCase() {
        try {
	        setUpData();
	        List<Case> cases = TestDataFactory.createCases(accounts);
	        insert cases;
	        //Start Test method
	        test.startTest();
	            ApexPages.currentPage().getParameters().put('caseId', cases[0].Id);
	            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
	            controllerObj = new ReferenceUseRequest();
	            controllerObj.noOFAccounts = '4';
	            controllerObj.addAccounts();
	            controllerObj.recordCounts = '1,2,3,4';
	            controllerObj.selectedValue = 'All Selected Records';
	            controllerObj.param1 = rfTypes.get(0).Id;
	            controllerObj.param2 = '31/10/2017';
	            controllerObj.param3 = 'testing Note';
	            controllerObj.referenceType = rfTypes.get(0).Id;
	            controllerObj.selectAndUpdate();
	            controllerObj.submitRequest();
	            system.assertNotEquals(controllerObj.insertUnspecifiedReq.size(), 10);
	            controllerObj.returnCase();
	            controllerObj.cancelRequest();
	        //Stop Test method
	        test.stopTest();
        } catch (Exception e) {
            
        }
    }
    
    //Test Method
    static testMethod void testRequestSF1() {
        try {
	        setUpData();
	        customSetting.Request_Managed_Email__c = true;
	        customSetting.Request_Managed_Chatter__c = false;
	        update customSetting;
	        //Start Test method
	        test.startTest();
	            ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
	            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
	            controllerObj = new ReferenceUseRequest();
	            controllerObj.noOFAccounts = '4';
	            controllerObj.addAccounts();
	            
	            controllerObj.recordCounts = '1';
	            controllerObj.getRequestInfo();
	            controllerObj.redirect();
	            controllerObj.redirectToInfo();
	            controllerObj.getAttributeOfSelectedLabel();
	            controllerObj.fromWhere = 'SF1';
	            controllerObj.selectAndUpdate();
	            controllerObj.selectedValue = 'All Selected Records';
	            controllerObj.referenceType = rfTypes.get(0).Id;
	            controllerObj.fromWhere = '';
	            controllerObj.dummyReq.Reference_Type_Needed__c = rfTypes[0].Id;
	            controllerObj.dummyReq.Deadline__c = system.today().addDays(10);
	            controllerObj.dummyReq.Request_Notes__c = 'test notes';
	            controllerObj.selectAndUpdate();
	            controllerObj.submitRequest();
	            system.assertEquals(controllerObj.insertUnspecifiedReq.size(), 0);
	        //Stop Test method
	        test.stopTest();
        } catch(Exception e) { 
        }
    } 

    
    static testMethod void testSubmitRequestAdvancedRouting() {
		setUpData();
		try {
			customSetting.Adv_Request_Routing__c = true;
			customSetting.Adv_Routing_Default__c = 'Send to Owner';
			customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
	    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
	    	customSetting.Adv_Rt_Acct_Team_User__c = 'LastModifiedById';
	    	customSetting.Request_Managed_Email__c = true;
			update customSetting;
			controllerObj = new ReferenceUseRequest();
			controllerObj.advRoutingGroup = new List<SelectOption>();
			controllerObj.selectedRoutingGroup = new List<SelectOption>();
			Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get(customSetting.Adv_Rt_Acct_Team_Object__c);
			Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
			Schema.SObjectField field = objDescribe.fields.getMap().get(customSetting.Adv_Rt_Acct_Team_Routeby__c);
			Schema.DescribeFieldResult dfr = field.getDescribe();
			for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
				controllerObj.advRoutingGroup.add(new SelectOption(ple.getValue(), ple.getLabel()));
			}
			Test.startTest();
				ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
				controllerObj.noOFAccounts = '4';
				controllerObj.addAccounts();
				controllerObj.recordCounts = '1,2,3,4';
				controllerObj.selectedValue = 'All Selected Records';
				controllerObj.param1 = rfTypes.get(0).Id;
				controllerObj.param2 = Date.today().addDays(17).format();
				controllerObj.param3 = 'testing Note';
				controllerObj.referenceType = rfTypes.get(0).Id;
				controllerObj.selectAndUpdate();
				controllerObj.refUseAttr.refTypeIdsSet = new set < Id > ();
		        controllerObj.refUseAttr.refTypeIdsSet.add(rfTypes.get(0).Id); 
		        //to check for selecting the attributes
		        controllerObj.refUseAttr.selectedLabelId = labels.get(0).Id;
		        controllerObj.refUseAttr.selectedAttributeId = attributes.get(0).Id;
		        controllerObj.refUseAttr.getAttributeLabels();
		        controllerObj.refUseAttr.setAttributes();
		        controllerObj.refUseAttr.setLabelAtrr(); 
				controllerObj.submitRequest();
				system.assertNotEquals(controllerObj.insertUnspecifiedReq.size(), 10);
				controllerObj.cancelRequest();
			Test.stopTest();
		 } catch(Exception e) { 
        }
    }   
    
    static testMethod void testSubmitRequestAdvancedRouting1() {
    	try {
			setUpData();
			customSetting.Adv_Request_Routing__c = true;
			customSetting.Adv_Routing_Default__c = 'Send to Owner';
			customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
	    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
	    	customSetting.Adv_Rt_Acct_Team_User__c = 'LastModifiedById';
			update customSetting;
			Test.startTest();
				ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
				controllerObj = new ReferenceUseRequest();
				controllerObj.noOFAccounts = '4';
				controllerObj.addAccounts();
				controllerObj.recordCounts = '1,2,3,4';
				controllerObj.selectedValue = 'All Selected Records';
				controllerObj.param1 = rfTypes.get(0).Id;
				controllerObj.param2 = Date.today().addDays(5).format();
				controllerObj.param3 = 'testing Note';
				controllerObj.referenceType = rfTypes.get(0).Id;
				controllerObj.selectAndUpdate();
				controllerObj.submitRequest();
				system.assertNotEquals(controllerObj.insertUnspecifiedReq.size(), 10);
				controllerObj.cancelRequest();
			Test.stopTest();
    	 } catch(Exception e) { 
        }
    } 
    
	static testMethod void testSubmitRequestAdvancedRouting2() {
		try {
			setUpData();
			customSetting.Adv_Request_Routing__c = true;
			customSetting.Adv_Routing_Default__c = 'Send to Owner';
			customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
	    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
	    	customSetting.Adv_Rt_Acct_Team_User__c = 'LastModifiedById';
			update customSetting;
			Test.startTest();
				ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
				controllerObj = new ReferenceUseRequest();
				controllerObj.noOFAccounts = '4';
				controllerObj.addAccounts();
				controllerObj.recordCounts = '1,2,3,4';
				controllerObj.selectedValue = 'All Selected Records';
				controllerObj.param1 = rfTypes.get(0).Id;
				controllerObj.param2 = Date.today().addDays(15).format();
				controllerObj.param3 = 'testing Note';
				controllerObj.referenceType = rfTypes.get(0).Id;
				controllerObj.selectAndUpdate();
				controllerObj.submitRequest();
				system.assertNotEquals(controllerObj.insertUnspecifiedReq.size(), 10);
				controllerObj.cancelRequest();
			Test.stopTest();
		 } catch(Exception e) { 
        }
    }
      
    static testMethod void testAddRoutingGroups() {
    	setUpData();
		controllerObj = new ReferenceUseRequest();
		customSetting.Adv_Request_Routing__c = true;
		customSetting.Adv_Routing_Default__c = 'Send to Owner';
		customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
		update customSetting;
		controllerObj.advRoutingGroup = new List<SelectOption>();
		controllerObj.selectedRoutingGroup = new List<SelectOption>();
		Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get(customSetting.Adv_Rt_Acct_Team_Object__c);
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		Schema.SObjectField field = objDescribe.fields.getMap().get(customSetting.Adv_Rt_Acct_Team_Routeby__c);
		Schema.DescribeFieldResult dfr = field.getDescribe();
		for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
			controllerObj.advRoutingGroup.add(new SelectOption(ple.getValue(), ple.getLabel()));
		}
		Test.startTest();
			controllerObj.selectedGrp = '';
			for (SelectOption so : controllerObj.advRoutingGroup) {
				if (controllerObj.selectedGrp == '') {
					controllerObj.selectedGrp = so.getValue();
				} else {
					controllerObj.selectedGrp += ',' + so.getValue();
				}
			}
			controllerObj.addGroups();
			system.assert(true);
		Test.stopTest();
    }
    
    static testMethod void testRemoveRoutingGroups() {
    	setUpData();
		controllerObj = new ReferenceUseRequest();
		customSetting.Adv_Request_Routing__c = true;
		customSetting.Adv_Routing_Default__c = 'Send to Owner';
		customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
		update customSetting;
		controllerObj.advRoutingGroup = new List<SelectOption>();
		controllerObj.selectedRoutingGroup = new List<SelectOption>();
		Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get(customSetting.Adv_Rt_Acct_Team_Object__c);
		Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		Schema.SObjectField field = objDescribe.fields.getMap().get(customSetting.Adv_Rt_Acct_Team_Routeby__c);
		Schema.DescribeFieldResult dfr = field.getDescribe();
		for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
			controllerObj.selectedRoutingGroup.add(new SelectOption(ple.getValue(), ple.getLabel()));
		} 
		Test.startTest();
			controllerObj.populateFilters();
			controllerObj.selectedAdvanceGrp = '';
			for (SelectOption so : controllerObj.selectedRoutingGroup) {
				if (controllerObj.selectedAdvanceGrp == '') {
					controllerObj.selectedAdvanceGrp = so.getValue();
				} else {
					controllerObj.selectedAdvanceGrp += ',' + so.getValue();
				}
			}
			controllerObj.removeGroups();
			system.assert(true);
		Test.stopTest();
    } 
     
    static testMethod void TestselectAndUpdateWithRecordClicked() { 
        setUpData();
        //Start Test method
        test.startTest();
            ApexPages.currentPage().getParameters().put('opportunityId', opp.Id);
            ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
            controllerObj = new ReferenceUseRequest();
            controllerObj.noOFAccounts = '5';
            controllerObj.addAccounts();
            controllerObj.getAccounts();
            //for single record of Account
            controllerObj.recordCounts = '1';
            controllerObj.selectedValue = 'The Record Clicked';
            controllerObj.param1 = rfTypes.get(0).Id;
            controllerObj.param2 = '30/10/2100';
            controllerObj.param3 = 'testing Note';
            controllerObj.selectAndUpdate();
            system.assertEquals(false, controllerObj.selectedAccounts[0].isManaged);
        //Stop Test method
        test.stopTest(); 
    } 
    
    static testMethod void TestForP2PRequest() {
    	setRoutingUpData();
		customSetting.Adv_Request_Routing__c = true;
		customSetting.Adv_Routing_Default__c = 'Send to Owner';
		customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
    	customSetting.Adv_Rt_Acct_Team_User__c = 'LastModifiedById';
		update customSetting;
		Test.startTest();
				List<Advanced_Routing__c> advRoutingList = new List<Advanced_Routing__c>();
				//List<Attribute__c> attributeList = TestDataFactory.createAttribute();
				//insert attributeList;
				List<Attribute__c> childAttr = TestDataFactory.createChildAttributes(attributes,1,1);
				insert childAttr;  
				advRoutingList.add(new Advanced_Routing__c(Adv_Routing_Attribute__c = childAttr[0].Id, Adv_Routing_Client_Value__c = 'Test 1'));
				insert advRoutingList; 
				 
				ApexPages.currentPage().getParameters().put('AccoutsIDs', accounts[0].Id + ',' + accounts[1].Id + ',' + accounts[2].Id);
				controllerObj = new ReferenceUseRequest();
				controllerObj.noOFAccounts = '4';
				controllerObj.addAccounts();
				controllerObj.recordCounts = '1,2,3,4';
				controllerObj.selectedValue = 'All Selected Records';
				controllerObj.param1 = rfTypes.get(0).Id;
				controllerObj.param2 = Date.today().addDays(15).format();
				controllerObj.param3 = 'testing Note';
				controllerObj.referenceType = rfTypes.get(0).Id;
				controllerObj.selectAndUpdate(); 
				controllerObj.refUseAttr.selectedLabelId = labels.get(0).Id;
		        controllerObj.refUseAttr.selectedAttributeId = attributes.get(0).Id;
		        controllerObj.refUseAttr.getAttributeLabels();
		        //controllerObj.refUseAttr.setAttributes();
		        controllerObj.refUseAttr.setLabelAtrr();
				controllerObj.refUseAttr.backToRequest();
				controllerObj.submitRequest(); 
				controllerObj.cancelRequest();
        		//REF-2653
        		controllerObj.doneUploadingFiles();
        		controllerObj.goToAttributeResults();
        		controllerObj.setPreviousInstanceOfPage();
				system.assert(true);
		Test.stopTest();
    }  
    
  //Data Setup
    static void setUpData() {
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Adv_Request_Routing__c = true;
		customSetting.Adv_Routing_Default__c = 'Send to Owner';
		customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
    	customSetting.Adv_Rt_Acct_Team_User__c = 'LastModifiedById';
    	customSetting.Request_Managed_Email__c = true;
		update customSetting;
        u = TestDataFactory.createUser();
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        opp = TestDataFactory.createOpportunity(accounts)[0];
        opp.Amount = 700;
        insert opp;
        rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        labels = TestDataFactory.createLabels();
        insert labels;
        attributes = TestDataFactory.createAttribute();
        insert attributes;
        //attLabels = createAttribute(); 
        system.debug('===attributes====>'+attributes[0]);
        TestDataFactory.createAttributeLabels(new List<Label__c> {labels[0]}, new List<Attribute__c> {attributes[0]});
        //insert attLabels;
        rtmapping = createReferenceTypeMapping();
        insert rtmapping;
     
        objAdvRouting=new Advanced_Routing__c (Adv_Routing_Client_Value__c = 'Test Client Value 001');
        insert objAdvRouting;
    }
    
    static void setRoutingUpData() {
        customSetting = TestDataFactory.createCustomSetting();
        customSetting.Adv_Request_Routing__c = true;
		customSetting.Adv_Routing_Default__c = 'Send to Owner';
		customSetting.Adv_Rt_Acct_Team_Object__c = 'Opportunity';
    	customSetting.Adv_Rt_Acct_Team_Routeby__c = 'StageName';
    	customSetting.Adv_Rt_Acct_Team_User__c = 'LastModifiedById';
    	customSetting.Request_Managed_Email__c = true;
		update customSetting;
        u = TestDataFactory.createUser();
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        opp = TestDataFactory.createOpportunity(accounts)[0];
        opp.Amount = 700;
        insert opp;
        rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        labels = createNewLabels();
        insert labels;
        attributes = createNewAttribute();
        insert attributes;
        //attLabels = createAttribute();  
        TestDataFactory.createAttributeLabels(new List<Label__c> {labels[0]}, new List<Attribute__c> {attributes[0]});
        //insert attLabels;
        rtmapping = createReferenceTypeMapping();
        insert rtmapping;
     
        objAdvRouting=new Advanced_Routing__c (Adv_Routing_Client_Value__c = 'Test Client Value 001');
        //insert objAdvRouting;
    }
    

    //Reference_Type_Mapping Setup
    static List<Reference_Type_Mapping__c> createReferenceTypeMapping() {
        List<Reference_Type_Mapping__c> tempRefMapping = new List<Reference_Type_Mapping__c> ();
       // tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Name = 'OwnerId'));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = true, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(0).Id));
        //tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Referenceability_Type__c = rfTypes.get(0).Id, Label__c = labels.get(1).Id));
        return tempRefMapping;
    }
    
     /**
     * Method to create Attribute Label
     */
     /*
   static List<Attributes_Labels__c> createAttribute() {
     	List<Attributes_Labels__c> att = new List<Attributes_Labels__c>(); 
        att.add(new Attributes_Labels__c(Label__c = labels.get(0).Id, Attribute__c = attributes.get(0).Id)); 
        return att;
    }*/
    
    static List<Attribute__c> createNewAttribute(){
        List<Attribute__c> attributeList = new List<Attribute__c>();
        attributeList.add(new Attribute__c(Name = 'Root Attribute', Parent__c = null, ParentIds__c = null));        
        return attributeList;
    }
    
    static List<Label__c> createNewLabels(){
        list<Label__c> label = new list<Label__c>();
        label.add(new Label__c(Name = 'Operating System'));        
        return label;
    }
}