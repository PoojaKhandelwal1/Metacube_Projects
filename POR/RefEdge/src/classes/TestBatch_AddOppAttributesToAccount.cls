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
public with sharing class TestBatch_AddOppAttributesToAccount {
    //Unit Test method 
    static testMethod void unitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        
        //Account
        list < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        
        //RBIs
        list<Reference_Basic_Information__c> RBIAccList = TestDataFactory.setUpAccountRBI(accounts);
        
        //Attribute mapping
        TestDataFactory.createOpportunityAttributeMapping();
        
        //Get standard pricebook
        string priceBook2Id = Test.getStandardPricebookId();
        
        //Product
        Product2 prod = new Product2(Name = 'Test product', family = 'Test family');
        insert prod;
        
        //PricebookEntry
        PricebookEntry pbe1 = new PricebookEntry (Pricebook2ID = priceBook2Id, Product2ID = prod.id, UnitPrice=500, isActive=true);
        insert pbe1;
        
        list < Opportunity > opportunities = TestDataFactory.createOpportunity(accounts);
        for(Opportunity opp : opportunities){
            opp.CloseDate = system.today()+1;
            opp.Amount = 700;
            opp.Type = 'New Business';
            opp.Pricebook2Id = pbe1.Pricebook2Id;
        }
        insert opportunities;
        
        OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID=opportunities[1].id,PriceBookEntryID=pbe1.id, quantity=4, totalprice=900);
        insert lineItem;
        
        Test.startTest();
            Batch_AddOppAttributesToAccount baoa = new Batch_AddOppAttributesToAccount();
            ID batchprocessid = database.executebatch(baoa);
        Test.stopTest();
        system.assert(true);
    }
}