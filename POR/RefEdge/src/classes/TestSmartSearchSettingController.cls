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
public with sharing class TestSmartSearchSettingController {
    
    static TestMethod void testSmartSearch(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        insert TestDataFactory.createAccounts();
        TestDataFactory.createAttributeMapping();
        //Start test method
        test.startTest();
            PageReference pageRef = Page.SmartSearchSettingPage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('customSettingId', customSetting.Id);
            SmartSearchSettingController controller = new SmartSearchSettingController();
            controller.editSettings();
            controller.saveSettings();
            controller = new SmartSearchSettingController();
            controller.editSettings();
            controller.saveSettings();
            controller.returnSettings();
            controller.returnCustomSettings();
        //Stop test method
        test.stopTest();
        List <Data_Mapping__c> dataMappingList = [select Id from Data_Mapping__c where Object__c = 'SmartSearchFilter'];
        system.assertEquals(4,dataMappingList.size());
    }
}