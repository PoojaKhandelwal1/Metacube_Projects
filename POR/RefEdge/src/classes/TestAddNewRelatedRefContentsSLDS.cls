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
 * Class: AddNewRelatedRefContentsControllerSLDS
 * Description: class to Test AND cover AddNewRelatedRefContentsControllerSLDS
 * Modified by: Rekha Jangir @24 May 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAddNewRelatedRefContentsSLDS {
    
    /**
     * Method to cover save method from Account
     * Modified By: Rekha Jangir @24 May 2017
     */
    static testMethod void testFromAccount() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Content__c> referObjects = TestDataFactory.createMultipleReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            referObjects = [SELECT Name FROM Reference_Content__c WHERE Id IN :referObjects];
            PageReference pageRef = Page.AddNewRelatedRefContents;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('acctId', accounts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(new Account_Reference_Content__c());
            AddNewRelatedRefContentsControllerSLDS testObject = new AddNewRelatedRefContentsControllerSLDS(controller);
            
            //fetch all required information
            AddNewRelatedRefContentsControllerSLDS.InfoWrapper info = AddNewRelatedRefContentsControllerSLDS.fetchInfo(testObject.accountId, testObject.returnUrl);
            
            // set all data 
            info.refConId = referObjects[0].Id;
            // save
            String result = AddNewRelatedRefContentsControllerSLDS.submit(JSON.serialize(info));
            List<Account_Reference_Content__c> accReferObjects = [SELECT Id FROM Account_Reference_Content__c WHERE Account__c = :accounts[0].Id];
            system.assertEquals(1, accReferObjects.size());
            
            //for exception
            result = AddNewRelatedRefContentsControllerSLDS.submit(JSON.serialize(info));
        //Stop Test method
        Test.stopTest();
    }
    
    
    /**
     * Method to cover save method from Reference Content
     * Modified By: Rekha Jangir @24 May 2017
     */
    static testMethod void testFromReferenceContent() {
    	//insert Test Data
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        TestDataFactory.setUpAccountRBI(accounts);
        List<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
        insert referObjects;
        
        //Start Test Method
        Test.startTest();
            Account_Reference_Content__c accReferObject = new Account_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(accReferObject);
            AddNewRelatedRefContentsControllerSLDS testObject = new AddNewRelatedRefContentsControllerSLDS(controller);
            
            //fetch all required information
            AddNewRelatedRefContentsControllerSLDS.InfoWrapper info = AddNewRelatedRefContentsControllerSLDS.fetchInfo(testObject.accountId, testObject.returnUrl);
            
            // set all data 
            info.accountId = accounts[0].Id;
            // save
            String result = AddNewRelatedRefContentsControllerSLDS.submit(JSON.serialize(info));
            List<Account_Reference_Content__c> accReferObjects = [SELECT Id FROM Account_Reference_Content__c WHERE Reference_Content__c = :referObjects[0].Id];
            system.assertEquals(1, accReferObjects.size());
        //Stop Test method
        Test.stopTest();
    }
}