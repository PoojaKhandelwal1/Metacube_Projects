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
 * Class: OpportunityProductTriggerHandler
 * Description: class to test AND cover OpportunityProductTriggerHandler
 * Modified By: Rekha Jangir @19 July 2017
 */
@isTest(seeAllData = false)
public with sharing class TestOpportunityProductTrigger {
    
    /**
     * Method to cover opportunity products trigger events
     * Modified By: Rekha Jangir @19 May 2017
     */
    static testMethod void testOpportunityProductEvents() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        //customSetting.RLF_Reminder_Days__c = 1;
        //update customSetting;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        //Creating RBI
        List<Reference_Basic_Information__c> rbiList = new List<Reference_Basic_Information__c>();
        
        for (Account account : accounts) {
            rbiList.add(new Reference_Basic_Information__c(Account__c = account.id,
                                                           Is_Referenceable__c = true,
                                                          Referenceability_Status__c = customSetting.Default_Referenceablity_Status__c));
        }
        
        insert rbiList;
        //Attribute mapping
        TestDataFactory.createOpportunityAttributeMapping();
        
        List<Opportunity> opportunities = TestDataFactory.createOpportunity(accounts);
        
        //Get standard pricebook
        String priceBook2Id = Test.getStandardPricebookId();
        
        //Product
        Product2 prod = new Product2(Name = 'Test product', family = 'Test family');
        insert prod;
        
        //PricebookEntry
        PricebookEntry pbe1 = new PricebookEntry (Pricebook2ID = priceBook2Id, Product2ID = prod.id, UnitPrice=500, isActive=true);
        insert pbe1;

        for (Opportunity opp : opportunities) {
            opp.CloseDate = system.today()+1;
            opp.Amount = 700;
            opp.Type = 'New Business';
            opp.Pricebook2Id = pbe1.Pricebook2Id;
        }
        
        List<Attribute__c> atts = [SELECT Id FROM Attribute__c WHERE Attribute_Mapping__r.Field_Api_Name__c = 'Product2' AND Level__c = 0];
        insert new Attribute__c(name = prod.Name, Parent__c = atts[0].Id, Product_ID__c = prod.Id);
        Test.startTest();
            insert opportunities;
            
            //Creating Opp Line Data
            OpportunityLineItem lineItem = new OpportunityLineItem (OpportunityID = opportunities[1].id, PriceBookEntryID = pbe1.id, quantity = 4, totalprice = 900);
            insert lineItem;
        
            opportunities[1].Amount = 760;
            opportunities[2].StageName = 'Closed Won';
            update opportunities;
            
        Test.stopTest();
        List<Account_Attribute__c> accAtts = [SELECT Id FROM Account_Attribute__c WHERE Account__c = :opportunities[1].AccountId];
        lineItem.totalprice = 1000;
        update lineItem;
        delete lineItem;
        accAtts = [SELECT Id FROM Account_Attribute__c WHERE Account__c = :opportunities[1].AccountId];
        system.assertNotEquals(accAtts,null);
    }
}