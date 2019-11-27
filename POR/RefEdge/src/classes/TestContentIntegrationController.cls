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
 * Class: ContentIntegrationController
 * Description: class to Test AND cover ContentIntegrationController
 * Modified by: Rajesh @26 Sept 2018
 */
@isTest
public class TestContentIntegrationController {
    
    @testSetup static void testDataSetup() {
        TestDataFactory.createContentTypes();
    }
    
    private static ContentIntegrationController getControllerInstance() {
        Custom_Settings__c cs = new Custom_Settings__c();
        ApexPages.StandardController csController = new ApexPages.StandardController(cs);
        ContentIntegrationController instance = new ContentIntegrationController(csController);
        return instance;
    }
    
    @isTest static void testCheckPermissions() {
        
        Test.startTest();
            Boolean result = getControllerInstance().checkPermissions();
        Test.stopTest();

        System.assertEquals(true, result, 'Permission checked');
    }
    
    @isTest static void testEditForm() {
        
        Test.startTest();
            PageReference result = getControllerInstance().editForm();
        Test.stopTest();

        System.assertEquals(null, result, 'Form in edit mode');
    }
    
    @isTest static void testSaveForm() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        ApexPages.StandardController csController = new ApexPages.StandardController(customSetting);
        ContentIntegrationController instance = new ContentIntegrationController(csController);
        instance.selectedLibrary = 'test library';
        instance.selectedRefContnetType = 'test content type';
        
        Test.startTest();
            PageReference result = instance.saveForm();
        Test.stopTest();

        System.assertEquals(null, result, 'Form saved');
    }
    
    @isTest static void testSaveFormWithException() {
        ContentIntegrationController instance = getControllerInstance();
        instance.selectedLibrary = 'test library';
        instance.selectedRefContnetType = 'test content type';
        
        Test.startTest();
            PageReference result = instance.saveForm();
        Test.stopTest();

        System.assertEquals(null, result, 'Form with exception on save');
    }
    
    @isTest static void testCancelForm() {
        
        Test.startTest();
            PageReference result = getControllerInstance().cancelForm();
        Test.stopTest();

        System.assertEquals(null, result, 'Form cancelled');
    }
    
    @isTest static void testValidate() {
        
        Test.startTest();
            Boolean result = getControllerInstance().validate();
        Test.stopTest();

        System.assertEquals(false, result, 'Validation successfull');
    }

}