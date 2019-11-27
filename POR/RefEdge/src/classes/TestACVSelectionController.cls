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
public class TestACVSelectionController {
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
            Test.setCurrentPageReference(Page.ACVSelectionPage); 
            System.currentPageReference().getParameters().put('customSettingId', cs.Id);  
            ApexPages.StandardController sc = new ApexPages.standardController(cs);      
            ACVSelectionController dlsc = new ACVSelectionController(sc);
            system.assertNotEquals(null, ACVSelectionController.getFields()); 
            system.assertNotEquals(null, ACVSelectionController.saveCS('Amount','Calender Year'));         
        }
         test.stopTest();
    } 
}