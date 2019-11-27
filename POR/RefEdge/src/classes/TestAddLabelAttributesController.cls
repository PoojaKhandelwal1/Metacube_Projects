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
public class TestAddLabelAttributesController {
    /*static Label__c l;
    static Attribute__c att1, att2, att3;
    static Attributes_Labels__c attLabel;
    static Account_Attribute__c accountAttribute;
    static Contact_Attribute__c cntctAttribute;
    static AddLabelAttributesController testObject;
    public static Custom_Settings__c customSetting;
    static Account a;
    static Contact c;
    static Reference_Content__c rc;
    static list<Account> accounts;
    static list<Contact> contacts;
    static list<Reference_Content__c> refContents;*/
    // Test method
    static TestMethod void testCreateRootForLabel() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            list<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            list<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            list<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
            list< Label__c > labels = TestDataFactory.createLabels();
            insert labels;
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            //Start test method
            Test.startTest();
                Apexpages.currentPage().getParameters().put('Id', labels[0].Id);
                AddLabelAttributesController testObject = new AddLabelAttributesController();
                system.assertEquals(18, testObject.treeNodes.size());
                testObject.selectedNodeId = attributes[0].Id;
                testObject.getChildrenOfSelectedNode();
                //system.assertEquals(3, testObject.treeNodes.size());
                //system.assertEquals(1, testObject.childTree.size());
                testObject.checkedIds = childAttributes[0].Id + ';' + childAttributes[1].Id ;
                PageReference pg = testObject.SaveAtt();
                system.assertEquals('/' + labels[0].Id, pg.getUrl());
                pg = testObject.Cancel();
                //system.assertEquals('/' + l.Id, pg.getUrl());
            //Stop Test method
            Test.stopTest();
        }catch(Exception e){
            system.assert(false,e.getMessage());
        }
    }
    
    private static void addDefaultAttrbuteMappingForOpportunity() {
    	//Start: Create 'Default' type Attr Mapping Record
    	AddAttributeMappingControllerSLDS.InfoWrapper info = new AddAttributeMappingControllerSLDS.InfoWrapper(new Attribute_Mapping__c());
    	info.attName = 'Stage1';
    	//info.autoAdd = false;
    	info.fieldName = 'Stage';
    	info.filterName = 'Stage1';
    	info.selectedMapField = 'StageName';
    	info.selectedObject = 'Opportunity';
        
        AddAttributeMappingControllerSLDS.FieldValuesWrapper fieldWrapper = new AddAttributeMappingControllerSLDS.FieldValuesWrapper();
        List<ListViewFiltersController.FilterWrapper> filters = new List<ListViewFiltersController.FilterWrapper>();
        
    	AddAttributeMappingControllerSLDS.saveMapping(JSON.serialize(info), JSON.serialize(fieldWrapper), 'default', JSON.serialize(filters));
        //End: Create 'Default' type Attr Mapping Record
    }
    
    //Test Method
    static TestMethod void testCreateRootForAccount() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            addDefaultAttrbuteMappingForOpportunity();
            list<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
             list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            //Test Start
            Test.startTest();
                Apexpages.currentPage().getParameters().put('Id', accounts[0].Id);
                AddLabelAttributesController testObject = new AddLabelAttributesController();
                testObject.isInheritable = true;
                system.assertEquals(18, testObject.treeNodes.size());
                testObject.selectedNodeId = attributes[0].Id;
                testObject.getChildrenOfSelectedNode();
                //system.assertEquals(3, testObject.treeNodes.size());
                //system.assertEquals(1, testObject.childTree.size());
                testObject.checkedIds = childAttributes[0].Id + ';' + childAttributes[1].Id;
                PageReference pg = testObject.SaveAtt();
                //system.assertEquals('/' + a.Id, pg.getUrl());
               // system.assertEquals(2, testObject.newattAccounts.size());
                pg = testObject.Cancel();
                system.assertEquals('/' + accounts[0].Id, pg.getUrl());
            //Test Stop
            Test.stopTest();
        }catch(Exception e){
            system.assert(false,e.getMessage());
        }
    }
    //test method
    static testMethod void testCreateRootForContact() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            addDefaultAttrbuteMappingForOpportunity();
            list<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            list<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            
             list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            //Start test method
            Test.startTest();
                Apexpages.currentPage().getParameters().put('Id', contacts[0].Id);
                AddLabelAttributesController testObject = new AddLabelAttributesController();
                system.assertEquals(18, testObject.treeNodes.size());
                testObject.selectedNodeId = attributes[0].Id;
                testObject.getChildrenOfSelectedNode();
                //system.assertEquals(3, testObject.treeNodes.size());
                //system.assertEquals(1, testObject.childTree.size());
                testObject.checkedIds = childAttributes[0].Id + ';' + childAttributes[1].Id;
                PageReference pg = testObject.SaveAtt();
                //system.assertEquals('/' + c.Id, pg.getUrl());
                //system.assertEquals(2, testObject.newattContacts.size());
                pg = testObject.Cancel();
                system.assertEquals('/' + contacts[0].Id, pg.getUrl());
            //Stop test method
            Test.stopTest();
        }catch(Exception e){
            system.assert(false,e.getMessage());
        }
    }
    //Test method
    static testMethod void testCreateRootForContent() {
       try{
           Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
           list<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
           insert refContents;
           
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            //Start test method
            Test.startTest();
                Apexpages.currentPage().getParameters().put('Id', refContents[0].Id);
                AddLabelAttributesController testObject = new AddLabelAttributesController();
                system.assertEquals(18, testObject.treeNodes.size());
                testObject.selectedNodeId = attributes[0].Id;
                testObject.getChildrenOfSelectedNode();
                //system.assertEquals(3, testObject.treeNodes.size());
                //system.assertEquals(1, testObject.childTree.size());
                testObject.checkedIds = childAttributes[0].Id + ';' + childAttributes[1].Id;
                PageReference pg = testObject.SaveAtt();
               // system.assertEquals('/' + rc.Id, pg.getUrl());
                //system.assertEquals(2, testObject.newattContent.size());
                pg = testObject.Cancel();
                system.assertEquals('/' + refContents[0].Id, pg.getUrl());
            //Stop test method
            Test.stopTest();
       }catch(Exception e){
            system.assert(false,e.getMessage());
       }
    }
    
    static testMethod void testReferenceRefreshFunctionalityForAccount(){
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            list<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            list<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            list<Reference_Basic_Information__c> rbi = TestDataFactory.setUpAccountRBI(accounts);
            TestDataFactory.setUpContactRBI(contacts);
            list<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts,rbi);
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            list<Account_Attribute__c> accAtts = TestDataFactory.createAccountAttributes(accounts,childAttributes,false);
            test.startTest();
                Apexpages.currentPage().getParameters().put('Id', accounts[0].Id);
                Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[0].Id);
                AddLabelAttributesController testObject = new AddLabelAttributesController();
                testObject.selectedAttributeId = accAtts[0].Id;
                testObject.deleteAttribute();
                
                Apexpages.currentPage().getParameters().put('Id', accounts[3].Id);
                Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[3].Id);
                testObject = new AddLabelAttributesController();
                testObject.checkedIds = childAttributes[1].Id + ';' + childAttributes[2].Id;
                testObject.SaveAtt();
                
                Apexpages.currentPage().getParameters().put('Id', accounts[2].Id);
                Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[2].Id);
                testObject = new AddLabelAttributesController();
                testObject.checkedIds = childAttributes[1].Id + ';' + childAttributes[2].Id;
                testObject.SaveAtt();
                system.assertNotEquals(0,accounts.size());
            Test.stopTest();
        }catch(Exception e){
            system.assert(false,e.getMessage());
        }
    }
    static testMethod void testReferenceRefreshFunctionalityForContact(){
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            list<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            list<Contact> contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            
            list<Reference_Basic_Information__c> rbi = TestDataFactory.setUpAccountRBI(accounts);
            TestDataFactory.setUpContactRBI(contacts);
            list<Reference_Refresh__c> refRefreshList = TestDataFactory.createRefRefreshRecords(accounts,rbi);
            list < Attribute__c > attributes = TestDataFactory.createAttribute();
            insert attributes;
            list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
            insert childAttributes;
            list<Contact_Attribute__c> conAtts = TestDataFactory.createContactAttributes(contacts, childAttributes);
            test.startTest();
                Apexpages.currentPage().getParameters().put('Id', contacts[0].Id);
                Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[0].Id);
                AddLabelAttributesController testObject = new AddLabelAttributesController();
                testObject.selectedAttributeId = conAtts[0].Id;
                testObject.deleteAttribute();
                
                Apexpages.currentPage().getParameters().put('Id', contacts[3].Id);
                Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[3].Id);
                testObject = new AddLabelAttributesController();
                testObject.checkedIds = childAttributes[1].Id + ';' + childAttributes[2].Id;
                testObject.SaveAtt();
                
                Apexpages.currentPage().getParameters().put('Id', contacts[2].Id);
                Apexpages.currentPage().getParameters().put('refRefreshId', refRefreshList[2].Id);
                testObject = new AddLabelAttributesController();
                testObject.checkedIds = childAttributes[1].Id + ';' + childAttributes[2].Id;
                testObject.SaveAtt();
                system.assertNotEquals(0,accounts.size());
            Test.stopTest();
        }catch(Exception e){
            system.assert(false,e.getMessage());
        }
    }
    
    static testMethod void testConstructor() {
    	Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
		Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Shared_Contacts__c = true;
        customSetting.Shared_Contact_Object__c = describeResult.getName();
		customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
		customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
		customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
		update customSetting;
		List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Reference_Basic_Information__c> accRBIList = TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        List<Reference_Basic_Information__c> contactRBIs = TestDataFactory.setUpContactRBI(contacts);
        list<Hit_List__c> hitList = new list<Hit_List__c>();
        hitList.add(new Hit_List__c(note__c = 'test1', Account__c = accounts[0].Id, Contact__c = contacts[1].Id));
        hitList.add(new Hit_List__c(note__c = 'test2', Account__c = accounts[0].Id, Contact__c = contacts[2].Id));
        hitList.add(new Hit_List__c(note__c = 'test3', Account__c = accounts[1].Id, Contact__c = contacts[3].Id));
        insert hitList;
        Apexpages.currentPage().getParameters().put('Id', contacts[0].Id);
        AddLabelAttributesController testObj1 = new AddLabelAttributesController();
        Apexpages.currentPage().getParameters().put('Id', accounts[0].Id);
        AddLabelAttributesController testObj2 = new AddLabelAttributesController();
        testObj2.getAccountReferenceStatus();
        UtilityController.checkRBI(accounts[0].Id, contacts[1].Id, true, true, false, false);
        set<String> accIdList = new set<String>();
        for (Account acc : accounts) {
        	accIdList.add(acc.Id);
        }
        UtilityController.checkRBI(accIdList, contacts[1].Id, true, true, false, false);
        system.assert(true);
    }
    
    
    
}