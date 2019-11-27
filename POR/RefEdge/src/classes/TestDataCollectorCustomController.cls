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
public with sharing class TestDataCollectorCustomController { 
 
    static testmethod void myUnitTest01() {
        //Start test Method
        test.startTest();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
        system.assertNotEquals(0, dmList.size());
        Reference_Content_Type__c refCon = TestDataFactory.createContentType();
        refCon.Name__c = ConstantsController.REFERENCE_CONTENT_TYPE;
        insert refCon;
        Reference_Type_Mapping__c rtm = new Reference_Type_Mapping__c();
        rtm.Visible__c = true;
        rtm.Required__c = false;
        rtm.Reference_Content_Type__c = refCon.Id;
        rtm.Name = 'Name';
        insert rtm;
        Reference_Type_Mapping__c rtmReq = new Reference_Type_Mapping__c();
        rtmReq.Visible__c = true;
        rtmReq.Required__c = true;
        rtmReq.Reference_Content_Type__c = refCon.Id;
        rtmReq.Name = 'CreatedDate';
        insert rtmReq;
        Apexpages.currentPage().getParameters().put('customFormId', dmList[0].Id);  
        Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);       
        DataCollectorCustomController testObject = new DataCollectorCustomController();
        DataCollectorCustomController.getPermissionsMessage();   
        dmList[0].DC_Message__c = 'Need to Delete';
        update dmList;
        
        String resultValue = DataCollectorCustomController.saveResult('', 'FormName', 'FormHeader', 'FormSubHeader', JSON.serialize(dmList));
        //Stop test method
        test.stopTest();
    }

    static testmethod void myUnitTest02() {
        //Start test Method
        test.startTest();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Data_Mapping__c> dmList = TestDataFactory.createDataCollectorForm();
        system.assertNotEquals(0, dmList.size());
        Reference_Content_Type__c refCon = TestDataFactory.createContentType();
        refCon.Name__c = ConstantsController.REFERENCE_CONTENT_TYPE;
        insert refCon;
        Reference_Type_Mapping__c rtm = new Reference_Type_Mapping__c();
        rtm.Visible__c = true;
        rtm.Required__c = false;
        rtm.Reference_Content_Type__c = refCon.Id;
        rtm.Name = 'Name';
        insert rtm;
        Reference_Type_Mapping__c rtmReq = new Reference_Type_Mapping__c();
        rtmReq.Visible__c = true;
        rtmReq.Required__c = true;
        rtmReq.Reference_Content_Type__c = refCon.Id;
        rtmReq.Name = 'CreatedDate';
        insert rtmReq;     
        Apexpages.currentPage().getParameters().put('customSettingId', customSetting.Id);       
        DataCollectorCustomController testObject = new DataCollectorCustomController();
        DataCollectorCustomController.getPermissionsMessage();   
        String resultValue = DataCollectorCustomController.saveResult('', 'FormName', 'FormHeader', 'FormSubHeader', '');      
        //Stop test method
        test.stopTest();
    }
}