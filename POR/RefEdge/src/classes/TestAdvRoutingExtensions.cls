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
 * Class: AdvRoutingExtensions
 * Description : class to test and cover AdvRoutingExtensions
 * Modified by: Rekha Jangir @25 August 2017
 */
@isTest(seeAllData = false)
public with sharing class TestAdvRoutingExtensions {
    
     static testMethod void testEditForm() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        customSetting.Adv_Rt_Acct_Team_Object__c='Account';
        upsert customSetting; 
        
        //Start test method
        test.startTest(); 
       PageReference pageRef = Page.AdvRoutingSettings;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(customSetting);
        AdvRoutingExtensions erc = new AdvRoutingExtensions(sc);  
        erc.editForm();
        system.assert(true);
        test.stopTest(); 
        
    }
    
     static testMethod void testSaveForm() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        customSetting.Adv_Rt_Acct_Team_Object__c='Account';
        upsert customSetting; 
        
        //Start test method
        test.startTest(); 
       	PageReference pageRef = Page.AdvRoutingSettings;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(customSetting);
        AdvRoutingExtensions erc = new AdvRoutingExtensions(sc);  
       
        erc.saveForm();
        system.assert(true);
        test.stopTest(); 
        
    }
    
     static testMethod void testCancelForm() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        customSetting.Adv_Rt_Acct_Team_Object__c='Account';
        upsert customSetting; 
        
        //Start test method
        test.startTest(); 
       PageReference pageRef = Page.AdvRoutingSettings;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(customSetting);
        AdvRoutingExtensions erc = new AdvRoutingExtensions(sc);  
        erc.cancelForm();
        system.assert(true);
        test.stopTest(); 
        
    }
      static testMethod void testSavevalidation() {
        try {
           //Start test method
          test.startTest(); 
          Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
          customSetting.Adv_Rt_Acct_Team_Object__c='Account';
     	  customSetting.Adv_Request_Routing__c =true;
          customSetting.Adv_Routing_Default__c=null;
          upsert customSetting; 
        
         
         PageReference pageRef = Page.AdvRoutingSettings;
          Test.setCurrentPage(pageRef);
          ApexPages.StandardController sc = new ApexPages.standardController(customSetting);
          AdvRoutingExtensions erc = new AdvRoutingExtensions(sc);  
         
          erc.saveForm();
          system.assert(true);
          test.stopTest(); 
         }
        catch (DMLException  e) {
         System.assert(e.getMessage().contains('Advanced Routing Default'), 'message=' + e.getMessage());
      }   
    }
    
}