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
 * Class: ChangeAllNLNRequestsController
 * Description : class to test and cover ChangeAllNLNRequestsController
 * Modified by: Rekha Jangir @24 August 2017
 */
@isTest(seeAllData = false)
public with sharing class TestChangeAllNLNRequestsController {
	
	/*
     * Method to cover all method and constructor
     * Modified By: Rekha Jangir @24 August 2017
     */
    static testmethod void testUpdateCustomSetting() {
    	//Start test method
        test.startTest();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            ApexPages.StandardController sc = new ApexPages.standardController(customSetting);
            ChangeAllNLNRequestsController obj = new ChangeAllNLNRequestsController(sc);
            obj.cs.Consider_No_longer_needed_a_use__c = true;
            obj.saveChanges();
            obj.edit();
            obj.cancel();
            obj.cs.Consider_No_longer_needed_a_use__c = false;
            obj.saveChanges();
            system.assertEquals(false, obj.cs.Consider_No_longer_needed_a_use__c);
    	//Stop test method
        test.stopTest();
    }
}