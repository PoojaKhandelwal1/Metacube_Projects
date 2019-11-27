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
public with sharing class TestFilterSettingController {
    
    //Unit Test Method
    static testMethod void testFilterSeting() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Label__c > labels = TestDataFactory.createLabels();
        labels[0].Visible__c = true;
        labels[1].Visible__c = true;
        insert labels;
        TestDataFactory.createAttributeMapping();
        list<Attribute_Mapping__c> attMapping = [select Id,field__c,Field_Api_Name__c,Filter_Label_Name__c from Attribute_Mapping__c];
        attMapping[0].Is_Related_Mapping__c = true;
        update attMapping;
        POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        //Start test method
        test.startTest();
            PageReference pageRef = Page.FilterSettingPage;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('customSettingId', customSetting.Id);
            FilterSettingController controller = new FilterSettingController();
            controller.editSettings();
            controller.saveSettings();
            system.assertEquals(23,controller.filterList.size());
            controller.returnSettings();
            controller.returnCustomSettings();
            controller = new FilterSettingController();
            controller.editSettings();
            controller.filterList = null;
            try{
                controller.saveSettings();
            }
            catch(Exception e){}
        //Stop test method
        test.stopTest();
        List <Custom_Settings__c> csList = [select Id from Custom_Settings__c];
        system.assert(csList.size() > 0);
    }
    
}