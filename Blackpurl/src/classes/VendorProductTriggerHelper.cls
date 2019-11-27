/**
 * Author: Nidhi Sharma
 * Since: June. 15, 2017
 * Name: VendorProductTriggerHelper
 * Description: Helper class for triggers on VendorProduct object
**/
public with sharing class VendorProductTriggerHelper {
	
	// List to store trigger new list
    public static List<Product__c> vendorProductNewList = new List<Product__c>();
    
    // List to store trigger old list
    public static List<Product__c> vendorProductOldList = new List<Product__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Product__c> vendorProductNewMap = new Map<Id, Product__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Product__c> vendorProductOldMap = new Map<Id, Product__c>();
    
    /**
     * Name: afterUpdateOperation 
    **/
    public static void afterUpdateOperation() {
    	//List<SObject> sObjectListToUpdate = new List<SObject>();
    	List<Option_Fee__c> optionAndFeeListToUpdate = new List<Option_Fee__c>();
    	Map<Id, Product__c> productIdToProductRecMap = new Map<Id, Product__c>([Select Id, Code__c, Description__c, (Select Id, Item_Code__c, Item_Description__c from Options_Fees__r where Deal__r.CO_Header__r.Order_status__c != 'Closed'), (Select Id, Item_Description__c from F_I_Products__r where Deal__r.CO_Header__r.Order_status__c != 'Closed') from Product__c where Id IN : vendorProductNewMap.keySet()]);
    	
    	for(Product__c productRec : vendorProductNewList) {
    		if(productIdToProductRecMap.containsKey(productRec.Id)) {
    			for(Option_Fee__c optionAndFeeRec : productIdToProductRecMap.get(productRec.Id).Options_Fees__r) {
    				Boolean isUpdated = false;
    				if((String.isNotBlank(vendorProductOldMap.get(productRec.Id).Code__c) && String.isBlank(productRec.Code__c)) || 
    							(String.isBlank(vendorProductOldMap.get(productRec.Id).Code__c) && String.isNotBlank(productRec.Code__c)) || 
    							(String.isNotBlank(vendorProductOldMap.get(productRec.Id).Code__c) && String.isNotBlank(productRec.Code__c) 
    														&& vendorProductOldMap.get(productRec.Id).Code__c != productRec.Code__c)) {
    					optionAndFeeRec.Item_Code__c = productRec.Code__c;
    					isUpdated = true;
    				}
    				
    				if((String.isNotBlank(vendorProductOldMap.get(productRec.Id).Description__c) && String.isBlank(productRec.Description__c)) || 
    							(String.isBlank(vendorProductOldMap.get(productRec.Id).Description__c) && String.isNotBlank(productRec.Description__c)) || 
    							(String.isNotBlank(vendorProductOldMap.get(productRec.Id).Description__c) && String.isNotBlank(productRec.Description__c) 
    														&& vendorProductOldMap.get(productRec.Id).Description__c != productRec.Description__c)) {
    					optionAndFeeRec.Item_Description__c = productRec.Description__c;
    					isUpdated = true;
    				}
            		
            		if(isUpdated) {
            			optionAndFeeListToUpdate.add(optionAndFeeRec);
            		}
					
    			}
    			/*for(F_I_Product__c fAndIProductRec : productIdToProductRecMap.get(productRec.Id).F_I_Products__r) {
    				Boolean isUpdated = false; 
    				if((String.isNotBlank(vendorProductOldMap.get(productRec.Id).Code__c) && String.isBlank(productRec.Code__c)) || 
    							(String.isBlank(vendorProductOldMap.get(productRec.Id).Code__c) && String.isNotBlank(productRec.Code__c)) || 
    							(String.isNotBlank(vendorProductOldMap.get(productRec.Id).Code__c) && String.isNotBlank(productRec.Code__c) 
    														&& vendorProductOldMap.get(productRec.Id).Code__c != productRec.Code__c)) {
    					fAndIProductRec.Item_Description__c = productRec.Code__c + ' - ' + productRec.Description__c;
    					isUpdated = true;
    				}
    				
    				if(!isUpdated) {
	    				if((String.isNotBlank(vendorProductOldMap.get(productRec.Id).Description__c) && String.isBlank(productRec.Description__c)) || 
	    							(String.isBlank(vendorProductOldMap.get(productRec.Id).Description__c) && String.isNotBlank(productRec.Description__c)) || 
	    							(String.isNotBlank(vendorProductOldMap.get(productRec.Id).Description__c) && String.isNotBlank(productRec.Description__c) 
	    														&& vendorProductOldMap.get(productRec.Id).Description__c != productRec.Description__c)) {
	    					fAndIProductRec.Item_Description__c = productRec.Code__c + ' - ' + productRec.Description__c;
	    					isUpdated = true;
	    				}
    				}
            		if(isUpdated) {
            			sObjectListToUpdate.add(fAndIProductRec);
            		}
    			}*/
    		}
    	}
    	if(optionAndFeeListToUpdate.size() > 0) {
    		if(AccessControl.ifObjectIsUpdateable('Option_Fee__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
    		OptionAndFeeTriggerHelper.isCalculatePriceLevel = false;
    		OptionAndFeeTriggerHelper.isCalculateTotalOnDeal = false;
    		update optionAndFeeListToUpdate;
    	}
    }
}