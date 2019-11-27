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
* Class: NewAttributeControllerSLDS
* Description : class to test and cover NewAttributeControllerSLDS 
* Modified by: Rekha Jangir @19 April 2017
*/
@isTest(seeAllData = false)
public with sharing class TestNewAttributeControllerSLDS {
    
    /*
     * Method to cover create new root attribute functionality
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testCreateRootAttributeFunctionality() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	
        //Start test method
        Test.startTest();
            NewAttributeControllerSLDS testObject = new NewAttributeControllerSLDS(new ApexPages.standardController(new Attribute__c()));
            //get all related informations 
            NewAttributeControllerSLDS.AttributeWrapper info = NewAttributeControllerSLDS.fetchInfo('', '');
            system.assertEquals('', info.attId);
            info.attName = 'Test Root Att';
            info.limitToAccCon = 'Account';
            
            //save this new attribute
        	String result = NewAttributeControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals(result.contains('success:'), true);
        	
        	List<String> options = NewAttributeControllerSLDS.getPickList();
        	system.assertEquals(true, options.size() > 1);
        	
        	List<Attribute__c> atts = [SELECT Id, Name, Level__c FROM Attribute__c WHERE Name = 'Test Root Att'];
        	system.assertEquals(1, atts.size());
        	system.assertEquals(0, atts[0].Level__c);
        	
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover edit root attribute functionality
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testEditRootAttributeFunctionality() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create root attribute
    	Attribute__c root = new Attribute__c(Name = 'Color', Ref_Limit_to_Acct_or_Cntct__c = 'Account');
    	insert root;
    	
        //Start test method
        Test.startTest();
            NewAttributeControllerSLDS testObject = new NewAttributeControllerSLDS(new ApexPages.standardController(root));
            //get all related informations 
            NewAttributeControllerSLDS.AttributeWrapper info = NewAttributeControllerSLDS.fetchInfo(testObject.attId, '');
            system.assertEquals(root.Id, info.attId);
            info.isInheritableNew = true;
            info.isAddDeleteAttributes = true;
            
            //save this new attribute
        	String result = NewAttributeControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals(result.contains('success:'), true);
        	
        	List<Attribute__c> atts = [SELECT Id, Name, Inheritable__c FROM Attribute__c WHERE Name = 'Color'];
        	system.assertEquals(1, atts.size());
        	system.assertEquals(true, atts[0].Inheritable__c);
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover create new child attribute functionality
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testCreateChildAttributeFunctionality() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create root attribute
    	Attribute__c root = new Attribute__c(Name = 'Color');
    	insert root;
        //Start test method
        Test.startTest();
            NewAttributeControllerSLDS testObject = new NewAttributeControllerSLDS(new ApexPages.standardController(new Attribute__c(Parent__c = root.Id)));
            //get all related informations 
            NewAttributeControllerSLDS.AttributeWrapper info = NewAttributeControllerSLDS.fetchInfo('', testObject.parentId);
            system.assertEquals(root.Id, info.parentId);
            info.attName = 'Test Child Att';
            
            //save this new attribute
        	String result = NewAttributeControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals(result.contains('success:'), true);
        	
        	List<Attribute__c> atts = [SELECT Id, Name, Level__c FROM Attribute__c WHERE Name = 'Test Child Att'];
        	system.assertEquals(1, atts.size());
        	system.assertEquals(1, atts[0].Level__c);
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover edit child attribute functionality
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testEditFirstChildAttributeFunctionality() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create root attribute
    	Attribute__c root = new Attribute__c(Name = 'Color');
    	insert root;
    	//create root attribute
    	Attribute__c anotherRoot = new Attribute__c(Name = 'Fruit');
    	insert anotherRoot;
    	//create child attribute
    	Attribute__c child = new Attribute__c(Name = 'Red', Parent__c = root.Id);
    	insert child;
        //Start test method
        Test.startTest();
            NewAttributeControllerSLDS testObject = new NewAttributeControllerSLDS(new ApexPages.standardController(child));
            //get all related informations 
            NewAttributeControllerSLDS.AttributeWrapper info = NewAttributeControllerSLDS.fetchInfo(testObject.attId, testObject.parentId);
            system.assertEquals(child.Id, info.attId);
            info.attName = 'Apple';
            info.parentId = anotherRoot.Id;
            
            //save this new attribute
        	String result = NewAttributeControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals(result.contains('success:'), true);
        	
        	List<Attribute__c> atts = [SELECT Id, Name, Parent__c FROM Attribute__c WHERE Name = 'Apple'];
        	system.assertEquals(1, atts.size());
        	system.assertEquals(anotherRoot.Id, atts[0].Parent__c);
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover edit child attribute functionality
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testEditSecondChildAttributeFunctionality() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create root attribute
    	Attribute__c root = new Attribute__c(Name = 'Color');
    	insert root;
    	//create root attribute
    	Attribute__c anotherRoot = new Attribute__c(Name = 'Fruit');
    	insert anotherRoot;
    	//create child attribute
    	Attribute__c child = new Attribute__c(Name = 'Red', Parent__c = root.Id);
    	insert child;
    	//create next level child attribute
    	Attribute__c secondChild = new Attribute__c(Name = 'Apple', Parent__c = anotherRoot.Id);
    	insert secondChild;
    	
        //Start test method
        Test.startTest();
            NewAttributeControllerSLDS testObject = new NewAttributeControllerSLDS(new ApexPages.standardController(secondChild));
            //get all related informations 
            NewAttributeControllerSLDS.AttributeWrapper info = NewAttributeControllerSLDS.fetchInfo(testObject.attId, testObject.parentId);
            system.assertEquals(secondChild.Id, info.attId);
            info.attName = 'Pink';
            info.parentId = child.Id;
            
            //save this new attribute
        	String result = NewAttributeControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertEquals(result.contains('success:'), true);
        	
        	List<Attribute__c> atts = [SELECT Id, Name, Parent__c FROM Attribute__c WHERE Name = 'Pink'];
        	system.assertEquals(1, atts.size());
        	system.assertEquals(child.Id, atts[0].Parent__c);
        //Stop Test method
        Test.stopTest();
    }
    
    /*
     * Method to cover extra code like exceptions
     * Created : Rekha Jangir @19 April 2017
     */
    public static testMethod void testExceptions() {
    	//create test data
    	Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    	//create root attribute
    	Attribute__c root = new Attribute__c(Name = 'Color');
    	insert root;
    	//create root attribute
    	Attribute__c anotherRoot = new Attribute__c(Name = 'Fruit');
    	insert anotherRoot;
    	//create child attribute
    	Attribute__c child = new Attribute__c(Name = 'Red', Parent__c = root.Id);
    	insert child;
    	
        //Start test method
        Test.startTest();
            NewAttributeControllerSLDS testObject = new NewAttributeControllerSLDS(new ApexPages.standardController(root));
            //get all related informations 
            NewAttributeControllerSLDS.AttributeWrapper info = NewAttributeControllerSLDS.fetchInfo(testObject.attId, '');
            system.assertEquals(root.Id, info.attId);
            info.parentId = child.Id;
            
            //save this new attribute
        	String result = NewAttributeControllerSLDS.saveAttributes(JSON.serialize(info));
        	system.assertNotEquals(result.contains('success:'), true);
        	
        	String permission = NewAttributeControllerSLDS.getPermissionsMessage(true);
        	system.assertNotEquals(null, testObject.nameSpace);
        	
        //Stop Test method
        Test.stopTest();
    }
}