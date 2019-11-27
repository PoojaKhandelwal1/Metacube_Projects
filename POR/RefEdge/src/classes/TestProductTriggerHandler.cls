/**
* Class: ProductTriggerHandler
* Description : class to test and cover ProductTriggerHandler 
* Created by: Rekha Jangir @Dec/9/2016
*/
@isTest(seeAllData = false)
public with sharing class TestProductTriggerHandler {
    /*
     * Method to cover Product trigger
     * Created : Rekha Jangir @09/9/2016
     */
 	public static testMethod void testAfterUpdateOfProductTrigger(){
 		//Product
        Product2 prod = new Product2(Name = 'Test product', family = 'Test family');
		insert prod;
		list < Attribute__c > attributes = TestDataFactory.createAttribute();
		
		for (Attribute__c att : attributes) {
			att.Product_ID__c = prod.Id;
			break;
		}
        insert attributes;
        
        prod.Name = 'Test New product';
        update prod;
        
        List<Attribute__c> atts = [select Id, Name from Attribute__c where Product_ID__c = :prod.Id];
        system.assertEquals('Test New product', atts[0].Name);
 	}
}