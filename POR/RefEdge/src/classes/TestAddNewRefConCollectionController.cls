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
public with sharing class TestAddNewRefConCollectionController {
    //Test method
    static testMethod void testContentCollection() {
        //Start test Method
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
            List < Content_Collection__c > conCollections = TestDataFactory.createContentCollection();
            insert conCollections;
            list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
            insert referObjects;
            referObjects = [select Name from Reference_Content__c where Id IN : referObjects];
            Related_Reference_Content__c conReferObject = new Related_Reference_Content__c();
            Apexpages.currentPage().getParameters().put('colId', conCollections[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(conReferObject);
            AddNewRefConCollectionController testObject = new AddNewRefConCollectionController(controller);
            testObject.isNameChanged = true;
            testObject.refConName = referObjects[0].Name;
            PageReference pg = testObject.save();
            system.assertEquals(pg.getUrl(), '/' + conCollections[0].Id);
            pg = testObject.cancel();
        //Stop test method
        test.stopTest();
    }
    //Test method
    static testMethod void testContentCollection2() {
        //Start test Method
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
            List < Content_Collection__c > conCollections = TestDataFactory.createContentCollection();
            insert conCollections;
            list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
            insert referObjects;
            referObjects = [select Name from Reference_Content__c where Id IN : referObjects];
            Related_Reference_Content__c conReferObject = new Related_Reference_Content__c();
            Apexpages.currentPage().getParameters().put('colId', conCollections[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(conReferObject);
            AddNewRefConCollectionController testObject = new AddNewRefConCollectionController(controller);
            testObject.isNameChanged = true;
            testObject.refConName = '';
            PageReference pg = testObject.save();
            testObject.refConName = 'RC-00';
            pg = testObject.save();
            system.assertEquals(pg.getUrl(), '/' + conCollections[0].Id);
            pg = testObject.cancel();
        //Stop test method
        test.stopTest();
    }
    //Test Method for Cancel
    static testMethod void testReferenceContent() {
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Content_Collection__c > conCollections = TestDataFactory.createContentCollection();
            insert conCollections;
            list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
            insert referObjects;
            Related_Reference_Content__c conReferObject = new Related_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
            conCollections = [select Name from Content_Collection__c where Id IN : conCollections];
            ApexPages.StandardController controller = new ApexPages.StandardController(conReferObject);
            AddNewRefConCollectionController testObject = new AddNewRefConCollectionController(controller);
            testObject.isNameChanged = true;
            testObject.conCollName = conCollections[0].Name;
            PageReference pg = testObject.save();
            conReferObject = [select Id from Related_Reference_Content__c where Content_Collection__c = : conCollections[0].Id];
            system.assertNotEquals(conReferObject, null);
        test.stopTest();
    }
     //Test Method for Cancel
    static testMethod void testReferenceContent2() {
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Content_Collection__c > conCollections = TestDataFactory.createContentCollection();
            insert conCollections;
            list<Reference_Content__c> referObjects = TestDataFactory.createReferenceContent();
            insert referObjects;
            List<Related_Reference_Content__c> conReferObjectList= new List<Related_Reference_Content__c>();
            Related_Reference_Content__c  conReferObject = new Related_Reference_Content__c(Reference_Content__c = referObjects[0].Id);
            conCollections = [select Name from Content_Collection__c where Id IN : conCollections];
            ApexPages.StandardController controller = new ApexPages.StandardController(conReferObject);
            AddNewRefConCollectionController testObject = new AddNewRefConCollectionController(controller);
            testObject.isNameChanged = true;
            testObject.conCollName = '';
            PageReference pg = testObject.save();
            testObject.conCollName = 'CC-00';
            pg = testObject.save();
            system.assertEquals(conCollections.isEmpty(),false);
            conReferObjectList = [select Id from Related_Reference_Content__c where Content_Collection__c = : conCollections[0].Id];
        test.stopTest();
    }
}