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
public with sharing class TestNominationSettingsController {
        
    //Unit Test Method
    static testMethod void checkNominationSettings() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list < Attribute__c > attributes = TestDataFactory.createAttribute();
        insert attributes;
        list< Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        TestDataFactory.createAttributeLabels(labels, attributes);
        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        
        POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        insert cs;
        //Start test method
        test.startTest();
            PageReference matrixPage = Page.NominationSettings;
            NominationSettingsController settings = new NominationSettingsController();
            for(string str : settings.nominationHeaderMap.keySet()){
                settings.nominationHeaderMap.get(str).Visible__c = true;
            }
            settings.saveNominationSettings();
            settings.editNominationSettings();        	
            settings.refTypes[0].Visible__c = false;
            settings.saveNominationSettings();
            Referenceability_Type__c ref = [Select Name, Id, Visible__c From Referenceability_Type__c WHERE Id = :settings.refTypes[0].Id];
            system.assertEquals(true, ref.Visible__c);
            settings.cancelNominationSettings();
            settings.redirectFieldPage();
            settings.returnCustomSettings();
        //Stop test method
        test.stopTest();
    }
}