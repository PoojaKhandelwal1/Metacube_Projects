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
public with sharing class TestReferenceRefreshSettings {
    static testMethod void testMethod1(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        PageReference pageRef = Page.ReferenceRefreshSettingsPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('customSettingId',customSetting.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(customSetting);
        ReferenceRefreshSettings temp = new ReferenceRefreshSettings(controller);
        temp.editTheSettings();
        temp.customSetting.Manual_Automatic_Launch__c = 'Automatic';
        try{
            temp.customSetting.Launch_Frequency__c = null;
            temp.saveTheSettings();
        }
        catch(exception e){}
        temp.customSetting.Launch_Frequency__c = 'Quarterly';
        temp.customSetting.Next_Refresh_launch_Date__c = system.today().addDays(+30);
        temp.saveTheSettings();
        temp.customSetting.Launch_Frequency__c = 'Monthly';
        temp.saveTheSettings();
        temp.customSetting.Launch_Frequency__c = 'Semi-Annually';
        temp.saveTheSettings();
        temp.customSetting.Launch_Frequency__c = 'Annually';
        temp.saveTheSettings();
        temp.customSetting.Manual_Automatic_Launch__c = 'Manual';
        temp.customSetting.Next_Refresh_launch_Date__c = system.today().addDays(+30);
        temp.saveTheSettings();
        temp.cancel();
        PageReference pg = temp.returnCustomSettings();
        System.assertEquals(pg.getURL(),'/'+customSetting.Id);
        temp.launchReferenceRefresh();
    }
    
}