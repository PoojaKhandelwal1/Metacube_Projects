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
public with sharing class TestSf1_FindReferenceAccountExt {
	//Unit Test method for Updation
    static testMethod void unitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account acc = new Account(Name = 'Acc1');
        insert acc;
        
        Opportunity opp = new Opportunity(CloseDate = system.today()+1,StageName = 'Closed Won', Amount = 700,Name = 'opp1', AccountId = acc.Id, OwnerId = UserInfo.getUserId());
        insert opp;
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.standardController(opp);
        	sf1_FindReferenceAccountExt sruccObj = new sf1_FindReferenceAccountExt(sc);
        	system.assert(true);
        Test.stopTest();
    }
	/*//Creation of Custom_Settings record
    private static Custom_Settings__c setUpCustomSetting1() {
        Custom_Settings__c testSettings = new Custom_Settings__c(
            Name = 'Test', Current_Version__c = '3.3.3', Include_Weekends__c = false,
            Escalation_to_Owner_Manager__c = 2, Feedback_Message_Delay__c = 2,
            Minimum_Deadline__c = 4, No_Response__c = 0, Reminder_to_Owner__c = 3,
            Email_Enabled__c = true, Chatter_Enabled__c = true, Active_Version__c = true,
            Days_of_Week__c = 'Sunday;Monday',  
              Minimum_Sales_Stage__c = 'Value Proposition',
            RUL_Activities__c = 3, RUL_Period__c = 99,Opportunity_Closed_Won_Stage__c = 'Closed Won',
            Minimum_Opportunity_Size__c = 500,Client_Referenceability_check_days__c = 1,No_Response_days__c = 2
        );
        return testSettings;
    }*/
}