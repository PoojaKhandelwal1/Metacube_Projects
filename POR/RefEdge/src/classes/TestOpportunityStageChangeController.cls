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
public with sharing class TestOpportunityStageChangeController {
    public static User u;
    public static Profile p;
    
    private static void CreateUser() {
        p = [select id from profile where name like '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                     emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                     localesidkey = 'en_US', profileid = p.Id,
                     timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
    }
    
    public static testMethod void testAccountFunctions() { 
         Custom_Settings__c cs = TestDataFactory.createCustomSetting();  
         ApexPages.StandardController sc = new ApexPages.standardController(cs);
        CreateUser();                
        test.startTest();
        system.runAs(u) {
        	OpportunityStageChangeAlertController oscac = new OpportunityStageChangeAlertController(sc);
            oscac.cs = cs;
            oscac.editForm();
            oscac.cancelForm();
            oscac.saveForm();
            oscac.isAccount = true;
            oscac.currentAccountStage = 'Needs Analysis,Qualification';
            oscac.currentSelectedAccountStage = 'Needs Analysis,Qualification';
            oscac.addToList();
            oscac.removeFromList(); 
            system.assertEquals(true, oscac.isAccount);          
        }
         test.stopTest();
     }

     public static testMethod void testContentFunctions() { 
         Custom_Settings__c cs = TestDataFactory.createCustomSetting();  
         ApexPages.StandardController sc = new ApexPages.standardController(cs);
        CreateUser();                
        test.startTest();
        system.runAs(u) {
        	OpportunityStageChangeAlertController oscac = new OpportunityStageChangeAlertController(sc);
            oscac.cs = cs;
            oscac.editForm();
            oscac.cancelForm();
            oscac.saveForm();           
            oscac.isAccount = false;
            oscac.currentContentStage = 'Prospecting,Proposal/Price Quote,Value Proposition';
            oscac.currentSelectedContentStage = 'Prospecting,Proposal/Price Quote,Value Proposition';
            oscac.addToList();
            oscac.removeFromList();
            system.assertEquals(false, oscac.isAccount);
        }
         test.stopTest();
     }
}