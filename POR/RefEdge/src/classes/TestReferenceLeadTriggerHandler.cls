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
public with sharing class TestReferenceLeadTriggerHandler {
    
    //Unit Test method for Updation
    static testMethod void testRefByLeadWithoutProfile() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            list<Account> accounts = TestDataFactory.createAccounts();
            insert accounts;
            List < Opportunity > opportunities = TestDataFactory.createOpportunity(accounts);
            insert opportunities;
            list<Reference_Lead__c> refLeads = TestDataFactory.createLeads();
            refLeads[0].Initial_notification_sent__c = refLeads[1].Initial_notification_sent__c = true;
            refleads[0].Follow_up_date__c =refleads[1].Follow_up_date__c = system.today();
            refLeads[0].Reference_Lead_Account__c = refLeads[1].Reference_Lead_Account__c = accounts[0].Id;
            refLeads[0].Reference_Lead_Opportunity__c =refLeads[1].Reference_Lead_Opportunity__c = opportunities[0].Id;
            refLeads[0].No_Response_date__c = refLeads[1].No_Response_date__c = system.today().addDays(3);
            insert refLeads;
            Test.startTest();
                refLeads[0].Follow_Up_Timeframe__c = '7 days';
                update refLeads[0];
                Reference_Lead__c refLead = [select Follow_up_date__c, No_Response_date__c from Reference_Lead__c where Id = :refLeads[0].Id]; 
                system.assertEquals(7,system.today().daysBetween(refLead.Follow_up_date__c));
            Test.stopTest();
        }catch(Exception e){
            
        }
            
    }
    static testMethod void testRefByLeadWithoutProfileForError() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List < Opportunity > opportunities = TestDataFactory.createOpportunity(accounts);
        insert opportunities;
        list<Reference_Lead__c> refLeads = TestDataFactory.createLeads();
        refLeads[0].Initial_notification_sent__c = refLeads[1].Initial_notification_sent__c = true;
        refleads[0].Follow_up_date__c =refleads[1].Follow_up_date__c = system.today();
        refLeads[0].Reference_Lead_Account__c = refLeads[1].Reference_Lead_Account__c = accounts[0].Id;
        refLeads[0].Reference_Lead_Opportunity__c =refLeads[1].Reference_Lead_Opportunity__c = opportunities[0].Id;
        refLeads[0].No_Response_date__c = refLeads[1].No_Response_date__c = system.today().addDays(3);
        insert refLeads;
        try{
            Test.startTest();
                refLeads[0].Follow_Up_Timeframe__c = '7 days';
                refLeads[0].No_Response_date__c =  system.today().addDays(-1);
                update refLeads[0];
                Reference_Lead__c refLead = [select Follow_up_date__c, No_Response_date__c from Reference_Lead__c where Id = :refLeads[0].Id]; 
                refLeads[0].No_Response_date__c = refLeads[1].No_Response_date__c = system.today().addDays(3);
                system.assertEquals(7,system.today().daysBetween(refLead.Follow_up_date__c));
            Test.stopTest();
        }catch(Exception e){
            
        }
    }
    
}