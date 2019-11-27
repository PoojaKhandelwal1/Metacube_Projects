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
 * Description: test class for RefProspectorSettingsController
 * Author: Gaurav Saini (21 Nov, 2017)
 */
@isTest(seeAllData = false)
public with sharing class TestRefProspectorSettingsController {
    
    /**
     * method to test constructor and getPermissionsMessage method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void unitTest01() {
    	RefProspectorSettingsController testObj = new RefProspectorSettingsController();
    	String permissionMsg = RefProspectorSettingsController.getPermissionsMessage();
    	system.assert(permissionMsg != null);
    }
    
    /**
     * method to test getRefProspectData method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetRefProspectData() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	String result = RefProspectorSettingsController.getRefProspectData();
    	system.assert(result != null);
    }
    
    /**
     * method to test getRefLeadOwnerOptions method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testGetRefLeadOwnerOptions() {
    	String fieldsListJSON = RefProspectorSettingsController.getRefLeadOwnerOptions();
    	List<RefProspectorSettingsController.OptionWrapper> fieldsList = (List<RefProspectorSettingsController.OptionWrapper>)JSON.deserialize(fieldsListJSON, List<RefProspectorSettingsController.OptionWrapper>.class);
    	system.assert(fieldsList.size() > 2);
    }
    
    /**
     * method to test saveCustomSettings method
     * author: Gaurav Saini (21 Nov, 2017)
     */
    public static testmethod void testSaveCustomSettings() {
    	Custom_Settings__c cs = TestDataFactory.createCustomSetting();
    	String saveResult = RefProspectorSettingsController.saveCustomSettings(RefProspectorSettingsController.getRefProspectData());
    	system.assert(saveResult == 'success');
    	saveResult = RefProspectorSettingsController.saveCustomSettings('test');
    	system.assert(saveResult != 'success');
    }
}