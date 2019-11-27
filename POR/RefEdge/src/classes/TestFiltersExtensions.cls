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
 * Page: Filters
 * Description: Class to update and delete Hit List
 * Modified by: Rekha @Feb 4 2017
 */
@isTest(seeAllData = false)
public with sharing class TestFiltersExtensions {
    
   //Unit Test Method
   static testMethod void testFilter01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        customSetting.Adv_Rt_Acct_Team_Object__c='Account';
        upsert customSetting; 
        Label__c labels = new Label__c(Visible__c = true, Name = '', Adv_Routing_Group__c = 'Group 1', 
        					Required_in_P2P__c = false, Show_in_P2P__c = true);
   		insert labels; 
        //Start test method
        test.startTest(); 
   		PageReference pageRef = Page.Filters;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(labels);
        FiltersExtensions erc = new FiltersExtensions(sc); 
        PageReference pg = erc.saveForm();
        system.assert(true);
        //Stop test method
        test.stopTest(); 
    }
    
    static testMethod void testFilter02() {
        
        Label__c labels = new Label__c(Visible__c = true, Adv_Routing_Group__c = 'Group 1', 
        					Required_in_P2P__c = true, Show_in_P2P__c = true);
   		insert labels; 
        //Start test method
        test.startTest(); 
   		PageReference pageRef = Page.Filters;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(labels);
        FiltersExtensions erc = new FiltersExtensions(sc);
        erc.isOnlySave = false; 
        PageReference pg = erc.saveForm();
        erc.isEdit = false;
        pg = erc.saveForm();
        system.assert(true);
        //Stop test method
        test.stopTest(); 
    }
    
    
    static testMethod void testFilter03() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting(); 
        Label__c labels = new Label__c(Name = '', Visible__c = true, Adv_Routing_Group__c = 'Group 1',
        					Required_in_P2P__c = true, Show_in_P2P__c = true);
   		insert labels; 
        //Start test method
        test.startTest(); 
   		PageReference pageRef = Page.Filters;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(labels);
        FiltersExtensions erc = new FiltersExtensions(sc); 
        erc.selectedGroup = 'TEST';
        erc.selectP2P();
        system.assert(true);
        //Stop test method
        erc.cancelForm() ;
        test.stopTest(); 
    }
    
    static testMethod void testFilter04() { 
        Label__c labels = new Label__c(Visible__c = true, Adv_Routing_Group__c = 'Group 1', 
        					Required_in_P2P__c = true, Show_in_P2P__c = false);
   		insert labels; 
        //Start test method
        test.startTest(); 
   		PageReference pageRef = Page.Filters;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(labels);
        FiltersExtensions erc = new FiltersExtensions(sc); 
        erc.selectedGroup = 'TEST';
        PageReference pg = erc.saveForm();
        system.assert(true);
        test.stopTest(); 
    }
   	static testMethod void testFilter05() { 
        Label__c labels = new Label__c(Visible__c = true, Adv_Routing_Group__c = 'Group 1',
        					Required_in_P2P__c = true, Show_in_P2P__c = false);
        labels.Name = null;
   		insert labels; 
        //Start test method
        test.startTest(); 
   		PageReference pageRef = Page.Filters;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.standardController(labels);
        FiltersExtensions erc = new FiltersExtensions(sc); 
        PageReference pg = erc.saveForm();
        system.assert(true);
        test.stopTest(); 
    }
}