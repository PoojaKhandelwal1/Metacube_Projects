/**
 * Author: Richa Mittal
 * Since: Aug 30, 2018
 * Name: PopulateFieldsOnVendorBatch
 * Description: Batch for Populating fields on vendor
**/
global with sharing class PopulateFieldsOnVendorBatch implements Database.Batchable<sobject> {
	global Database.QueryLocator start(Database.BatchableContext bc) {
		BPScriptUtility.disbaleTrigger('CustomerTrigger');
        String strQuery = 'SELECT Part_Category_Default__c, Part_Category_Default__r.Type__c, Merchandise_Category_Default__c, Purchase_Tax__c FROM Account WHERE Is_Vendor__c = true';
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.batchableContext bc, List<Account> vendorList) {
        List<Category__c> defaultCategoryList = [SELECT Id FROM Category__c WHERE Default__c = true AND Type__c = 'Part'];
    	for(Account vendorRec: vendorList) {
			if(String.isBlank(vendorRec.Part_Category_Default__c) || vendorRec.Part_Category_Default__r.Type__c != 'Part') {
				if(defaultCategoryList.size() > 0) {
					vendorRec.Part_Category_Default__c = defaultCategoryList[0].Id;
				}
			}
			vendorRec.Merchandise_Category_Default__c = vendorRec.Part_Category_Default__c;
			if(String.isBlank(vendorRec.Purchase_Tax__c)) {
				vendorRec.Purchase_Tax__c = Configurations__c.getOrgDefaults().Ordering_Tax_Rate__c;
			}
		}
		update vendorList;
    }
    
    global void finish(Database.batchableContext bc) {
		BPScriptUtility.enableTrigger('CustomerTrigger');
    }
}