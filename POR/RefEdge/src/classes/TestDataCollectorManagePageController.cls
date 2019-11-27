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
 public with sharing class TestDataCollectorManagePageController {
 
      static testmethod void myUnitTest01() {
         //Start test Method
         test.startTest();
         Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
         List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
         Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);       
         DataCollectorManagePageController testObject = new DataCollectorManagePageController();
         testObject.dmRecordId  = dmList[2].id;
         testObject.showPopup();
         testObject.preview = 'Preview';
         testObject.showPopup();
         testObject.closePopup();
         testObject.save();
         PageReference pgeditView = testObject.editAndViewPageRedirect();
         PageReference pgredForm = testObject.redirectFormPage();
         PageReference pgcust = testObject.returnCustomSettings();
         system.assertEquals(pgcust.getUrl(), '/' + customSetting.Id);
       //Stop test method
        test.stopTest();
      }

      static testmethod void myUnitTest02() {
         //Start test Method
         test.startTest();
         Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
         List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
         Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);       
         DataCollectorManagePageController testObject = new DataCollectorManagePageController();
         testObject.dmRecordId  = dmList[2].id;
         testObject.showPopup();
         testObject.preview = 'Preview';
         testObject.showPopup();
         testObject.closePopup();
         testObject.save();
         testObject.deleteForm();  
         testObject.dmRecordId  = dmList[9].id;   
         testObject.deleteForm();   
         PageReference pgeditView = testObject.editAndViewPageRedirect();
         PageReference pgredForm = testObject.redirectFormPage();
         PageReference pgcust = testObject.returnCustomSettings();
         system.assertEquals(pgcust.getUrl(), '/' + customSetting.Id);
       //Stop test method
        test.stopTest();
      }
 }