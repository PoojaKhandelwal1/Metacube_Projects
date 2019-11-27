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

@isTest
public with sharing class TestDataLoaderSettingController {
    
    public static User u;
    public static Profile p;
    
    private static void CreateUser() {
        p = [select id from profile where name like '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                     emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                     localesidkey = 'en_US', profileid = p.Id,
                     timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
    }

    /*
    * Description: To test the Methods in DataLoaderSettingController related to DataLoaderSetting.page
    * Last Modified By: Dixita Jain (Jan, 2018)
    */
    public static testMethod void testAllFunctions() { 
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();        
        CreateUser();                
        test.startTest();
        system.runAs(u) {
            Test.setCurrentPageReference(Page.DataLoaderSettingPage); 
            System.currentPageReference().getParameters().put('customSettingId', cs.Id);           
            System.currentPageReference().getParameters().put('isDLEnabled', 'true');           
            DataLoaderSettingController dlsc = new DataLoaderSettingController();
            dlsc.cs = cs;
            dlsc.fetchData();
            system.assertNotEquals(0, dlsc.fieldList.size());
            system.assertEquals(null,dlsc.saveSettings());
            system.assertEquals(dlsc.isEdit, false);
            system.assertEquals(null,dlsc.editSettings());
            system.assertEquals(dlsc.isEdit, true);
            system.assertEquals(null,dlsc.returnSettings());
            system.assertEquals(dlsc.isEdit, false);
            system.assertNotEquals(null,dlsc.returnCustomSettings());            
        }
         test.stopTest();
    } 

    /*
    * Description: To test the Methods in DataLoaderSettingController that are related to DMInline.page
    * Last Modified By: Dixita Jain (Jan, 2018) for #1262
    */
    public static testMethod void testAllFunctionsDMInline() { 
    	
        Custom_Settings__c cs = TestDataFactory.createCustomSetting();        
        ApexPages.StandardController sc = new ApexPages.standardController(cs);
        CreateUser();                
        test.startTest();
        system.runAs(u) {
            Test.setCurrentPageReference(Page.DataLoaderSettingPage); 
            cs.Export_Object__c = '';
            cs.Export_Objects__c = 'Attribute__c,Reference_Content__c';
            update cs;
            DataLoaderSettingController dlsc = new DataLoaderSettingController(sc);
            System.assertNotEquals(dlsc.allObjImport.size(),0);
            System.assertNotEquals(dlsc.allObjExport.size(),0);
            System.assertEquals(cs.Import_Object__c,null);
            dlsc.currentAllObjImport = dlsc.allObjImport[0].getValue();
            dlsc.isImport = true;
            dlsc.addToList();
            dlsc.currentAllObjExport = dlsc.allObjExport[0].getValue();
            dlsc.isImport = false;
            dlsc.addToList();
            System.assertNotEquals(dlsc.selectedImportObj.size(),0);
            System.assertNotEquals(dlsc.selectedExportObj.size(),0);
            dlsc.currentSelectedImportObj = dlsc.selectedImportObj[0].getValue();
            dlsc.isImport = true;
            dlsc.removeFromList();
            dlsc.currentSelectedExportObj = dlsc.selectedExportObj[0].getValue();
            dlsc.isImport = false;
            dlsc.removeFromList();
            //System.assertEquals(dlsc.selectedImportObj.size(),0);
            //System.assertEquals(dlsc.selectedExportObj.size(),0);
            dlsc.selectedImportObj = dlsc.allObjImport;
            dlsc.selectedExportObj = dlsc.allObjExport;
            dlsc.saveForm();
            cs = UtilityController.getCustomSettings();
            System.assertNotEquals(cs.Export_Object__c.length(),0);
            System.assertNotEquals(cs.Import_Object__c.length(),0);
            dlsc.editForm();
            dlsc.cancelForm();
            System.assertEquals(dlsc.isEdit,false);
        }
        test.stopTest();
    } 
}