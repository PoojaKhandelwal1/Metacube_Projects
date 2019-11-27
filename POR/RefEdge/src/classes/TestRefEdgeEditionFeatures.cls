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
public with sharing class TestRefEdgeEditionFeatures {
    
    //Unit Test method
    static testMethod void checkRefEdgeEditionFeatures() {
        //Start test method
        test.startTest();
            POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
            insert cs;
            RefEdgeEditionFeatures obj = new MultiSelectRefSettingFieldsController();
            PageReference pageRef = Page.MultiSelectReferenceSettingFields;
            Test.setCurrentPage(pageRef);
            system.assertEquals(true, obj.IsPageAccessible);
            system.assertEquals(false, RefEdgeEditionFeatures.isBasic);
            system.assertEquals(true, RefEdgeEditionFeatures.isPro);
            system.assertEquals(false, RefEdgeEditionFeatures.isEnterPrise);
       		system.assertEquals(false, RefEdgeEditionFeatures.isProCom);
        	system.assertEquals(false,RefEdgeEditionFeatures.isEnterpriseCom);
        //Stop test method
        test.stopTest();
    }
}