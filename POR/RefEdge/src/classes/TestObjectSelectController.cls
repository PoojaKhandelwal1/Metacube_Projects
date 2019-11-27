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
 * Class: ObjectSelectController
 * Description : class to test and cover ObjectSelectController
 * Modified by: Rekha Jangir @25 August 2017
 */
@isTest(seeAllData = false)
public with sharing class TestObjectSelectController {
	
	/*
     * Method to cover all method and constructor
     * Modified By: Rekha Jangir @25 August 2017
     */
    static testmethod void testUpdateCustomSetting() {
    	//Start test method
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            ApexPages.StandardController sc = new ApexPages.standardController(customSetting);
            ObjectSelectController obj = new ObjectSelectController(sc);
            obj.editForm();
            obj.saveForm();
            obj.cancelForm();
            obj.selectedObject = 'Contact';
        	obj.populateFieldList();
        	obj.saveForm();
            system.assertEquals(false, obj.cs.Shared_Contacts__c);
    	//Stop test method
        test.stopTest();
    }
}