/**
 * Author: Ashish Garg
 * Since: Dec. 1, 2015
 * Name: KitLineItemtriggerHelper
 * Description: Helper class for triggers on Kit Header Line Item object
**/
global with sharing class KitLineItemtriggerHelper {
	// List to store trigger new list
    public static List<Kit_Header_Line_Item__c> newList = new List<Kit_Header_Line_Item__c>();
    
    // List to store trigger old list
    public static List<Kit_Header_Line_Item__c> oldList = new List<Kit_Header_Line_Item__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Kit_Header_Line_Item__c> newMap = new Map<Id, Kit_Header_Line_Item__c>();

    // Map to store Old Trigger Map
    public static Map<Id, Kit_Header_Line_Item__c> oldMap = new Map<Id, Kit_Header_Line_Item__c>();
    
    // Static variables to handle trigger execution
    public static boolean PermitRun_BeforeInsert = true;
    public static boolean PermitRun_BeforeUpdate = true;
    public static boolean PermitRun_BeforeDelete = true;
    
    /**
     * Name: processBeforeInsert
     * Desc: Process before insert trigger execution
     * @param: 
     * @return: 
    **/
    public static void processBeforeInsert() {
    	if(PermitRun_BeforeInsert) {
    		KitHeaderTriggerHelper.PermitRun_BeforeUpdate = false;
    		PermitRun_BeforeInsert = false;
    		PermitRun_BeforeUpdate = false;		// Prevent update of line items so as to prevent re-assignment of kit price for line items being updated in the process
    		
    		setRetailPriceBasedOnDefaultPriceLevel(newList);
    		
    		// Assign default Kit Price
    		for(Kit_Header_Line_Item__c khli : newList){
    			if(!khli.Is_Environmental_Fee__c) {
    				khli.Kit_Price__c = khli.Retail__c;
    			}
	    	}
    		
    		// Distribute the price in all line items according to header price
    		distributePriceOnLineItems(newList);
    	}
    }
    
    /**
     * Name: processBeforeUpdate
     * Desc: Process before update trigger execution
     * @param: 
     * @return: 
    **/
    public static void processBeforeUpdate() {
    	if(PermitRun_BeforeUpdate) {
    		KitHeaderTriggerHelper.PermitRun_BeforeUpdate = false;
    		PermitRun_BeforeUpdate = false;
    		
    		// Distribute the price in all line items according to header price
    		distributePriceOnLineItems(newList);
    	}
    }
    
    /**
     * Name: processBeforeDelete
     * Desc: Process before delete trigger execution
     * @param: 
     * @return: 
    **/
    public static void processBeforeDelete() {
    	if(PermitRun_BeforeDelete) {
    		KitHeaderTriggerHelper.PermitRun_BeforeUpdate = false;
    		PermitRun_BeforeDelete = false;
    		PermitRun_BeforeUpdate = false;		// Prevent update of line items so as to prevent re-assignment of kit price for line items being updated in the process
    		
    		// Distribute the price in all line items according to header price
    		distributePriceOnLineItems(oldList);
    	}
    }
    
    /**
     * Name: distributePriceOnLineItems
     * Desc: Method used to distribute kit header price on all line items. Cases are to be considered: insert, update, delete
     * @param: List<Kit_Header_Line_Item__c> khlisList
     * @return: 
    **/
    private static void distributePriceOnLineItems(List<Kit_Header_Line_Item__c> khlisList) {
    	if(AccessControl.ifObjectFieldIsUpdateable('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	Map<Id, List<Kit_Header_Line_Item__c>> kitHeaderToLineItemsMap = new Map<Id, List<Kit_Header_Line_Item__c>>();
		Map<Id, Double> kitHeaderToNewFixedTotal = new Map<Id, Double>();
		Map<Id, Double> kitHeaderToNewUnfixedTotal = new Map<Id, Double>();
		
		for(Kit_Header_Line_Item__c khli : khlisList){
			// Fixed price line item
			if(khli.Fixed_Price__c == true){
				// make the kit price to default price for fixed line item record
				if(khli.Kit_Price__c == null || (Trigger.isUpdate && !oldMap.get(khli.Id).Fixed_Price__c)) {
					khli.Kit_Price__c = khli.Retail__c;
				}
    			Double fixedTotal = (kitHeaderToNewFixedTotal.containsKey(khli.Kit_Header__c)) ? kitHeaderToNewFixedTotal.get(khli.Kit_Header__c) : 0;
    			fixedTotal += khli.Qty_Needed__c * khli.Kit_Price__c;
    			kitHeaderToNewFixedTotal.put(khli.Kit_Header__c, fixedTotal);
			}
			
			// unfixed price line item
			if(khli.Fixed_Price__c == false){
				// make the kit price to default price for unfixed line item record
    			if(!Trigger.isDelete) {
    				khli.Kit_Price__c = khli.Retail__c;
    			}
    			
    			Double unfixedTotal = (kitHeaderToNewUnfixedTotal.containsKey(khli.Kit_Header__c)) ? kitHeaderToNewUnfixedTotal.get(khli.Kit_Header__c) : 0;
    			unfixedTotal += khli.Qty_Needed__c * khli.Retail__c;
    			kitHeaderToNewUnfixedTotal.put(khli.Kit_Header__c, unfixedTotal);
			}
			
			// Create map for header kits
			List<Kit_Header_Line_Item__c> khlis = (kitHeaderToLineItemsMap.containsKey(khli.Kit_Header__c)) ? kitHeaderToLineItemsMap.get(khli.Kit_Header__c) : new List<Kit_Header_Line_Item__c>();
			khlis.add(khli);
			kitHeaderToLineItemsMap.put(khli.Kit_Header__c, khlis);
		}
	
		// Now get Kit Header records for new list khlis
		if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		Map<Id, Kit_Header__c> kitHeadersMap = new Map<Id, Kit_Header__c>([	SELECT Id, 
						    												 Fixed_Price__c, 
						    												 Fixed_Price_Flag__c,
						    												 (SELECT Id, 
						    												 		 Fixed_Price__c, 
						    												 		 Kit_Price__c,
						    												 		 Retail__c,
						    												 		 Qty_Needed__c,
						    												 		 Total__c
						    												 		 FROM Kit_Header_Line_Items__r
						    												 		 WHERE Qty_Needed__c > 0
						    												 		 AND Id NOT IN: khlisList
						    												 )
						    												 FROM  Kit_Header__c
						    												 WHERE Id IN: kitHeaderToLineItemsMap.keySet()
						    											]);
		
		List<Kit_Header__c> kitHeadersToUpdate = new List<Kit_Header__c>();
		List<Kit_Header_Line_Item__c> klisToUpdate = new List<Kit_Header_Line_Item__c>();
		
		// Loop through all Kit header records and check:
		// If Kit Header is of fixed price, then distribute the all unfixed amount line items amount as per calculation logic
		// Else, Kit header is of unfixed price, then add the new line item amount in kit header price
		for(Kit_Header__c kitHeader : kitHeadersMap.values()){
			Double fixedTotal = (kitHeaderToNewFixedTotal.containsKey(kitHeader.Id)) ? kitHeaderToNewFixedTotal.get(kitHeader.Id) : 0;
			Double unfixedTotal = (kitHeaderToNewUnfixedTotal.containsKey(kitHeader.Id)) ? kitHeaderToNewUnfixedTotal.get(kitHeader.Id) : 0;
			
			// In case of delete, set amounts to be negative
			if(Trigger.isDelete){
				fixedTotal = fixedTotal * -1;
				unfixedTotal = unfixedTotal * -1;
			}
			
			if(kitHeader.Fixed_Price_Flag__c){
				List<Kit_Header_Line_Item__c> khLineItems = (kitHeader.Kit_Header_Line_Items__r != null) ? kitHeader.Kit_Header_Line_Items__r : new List<Kit_Header_Line_Item__c>();
				kitHeader.Fixed_Price__c = (kitHeader.Fixed_Price__c != null) ? kitHeader.Fixed_Price__c : 0;
				
				// Assign new effective price on kit header record as per opration mode
				// Add/remove/update kit line items from kit line items list as per operation mode
				if(Trigger.isInsert || Trigger.isUpdate){
					if(kitHeaderToLineItemsMap.containsKey(kitHeader.Id)){
						khLineItems.addAll( kitHeaderToLineItemsMap.get(kitHeader.Id) );
					}
				} else if(Trigger.isDelete){
					// Do not alter line items list as the same header price needs to be distributed among all line items
				}
				
				// Distribute the amount of all remaining line items as per calculation logic
				klisToUpdate.addAll( KitHeaderTriggerHelper.assignPriceForHeaderAndLineItems(kitHeader, khLineItems) );
			} else {
				// Add the new line item amount in Kit header price
				kitHeader.Fixed_Price__c = 0;
				for(Kit_Header_Line_Item__c khli : kitHeader.Kit_Header_Line_Items__r){
					kitHeader.Fixed_Price__c += khli.Total__c;
				}
				
				// If Trigger is in delete mode, 
				// then do not add/update fixed and unfixed amount in header price since these amount are automatically removed from header price calculation
				if(Trigger.isDelete == false){
					kitHeader.Fixed_Price__c += fixedTotal + unfixedTotal;
				}
				kitHeadersToUpdate.add(kitHeader);
			}
		}
		if(kitHeadersToUpdate.size() > 0){
			update kitHeadersToUpdate;
		}
		
		if(klisToUpdate.size() > 0){
			update klisToUpdate;
		}
    }
    
    /**
     * Name: setDefaultFields
     * Desc: set Default fields of Kit Header in case of After Insert/Before Delete
     * @param: 
     * @return: 
    **/
    public static void setDefaultFields() {
    	Set<Id> kitHeaderIdSet = new Set<Id>();
    	List<Kit_Header_Line_Item__c> kitLineItems = (Trigger.isDelete) ? oldList : newList;
    	for(Kit_Header_Line_Item__c kitLitneItemRec : kitLineItems) {
    		kitHeaderIdSet.add(kitLitneItemRec.Kit_Header__c);
    	} 
    	if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Kit_Header__c> kitHeaders = [select Number_of_Labours__c, Service_Kit__c, (select Id from Kit_Header_Line_Items__r WHERE Labour_Code__c != null) 
    											from Kit_Header__c WHERE Id IN : kitHeaderIdSet];
    											
    	for(Kit_Header__c kitHeaderRec : kitHeaders) {										
    		kitHeaderRec.Number_of_Labours__c = kitHeaderRec.Kit_Header_Line_Items__r.size();
    		if(kitHeaderRec.Number_of_Labours__c > 0) {
    			kitHeaderRec.Service_Kit__c = true;
    		}
    	}
    	
    	if(kitHeaders.size() > 0) {
    		if(AccessControl.ifObjectFieldIsUpdateable('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    		update kitHeaders;
    	}
    }
    
    
    /**
     * Name: updateKitLineItems
     * Desc: Update Kit Line Item if Retail Price of Part is changed.
     * @param: 
     * @return: 
    **/
    @future
    global static void updateRetailofKitLineItems(String objectName, List<Id> recordsId) {
    	String query = '';
    	if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsAccessible('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	query = 'SELECT Id, (SELECT Retail__c FROM Kit_Header_Line_Items__r) FROM ' + objectName + ' WHERE Id IN : recordsId';
    	List<Sobject> sobjList = Database.query(query);
    	//system.assert(false, sobjList);
    	
    	List<Kit_Header_Line_Item__c> kitLineItems = new List<Kit_Header_Line_Item__c>();
    	for(Sobject sobj : sobjList) {
    		for(Kit_Header_Line_Item__c kitLineItemRec : sobj.getSobjects('Kit_Header_Line_Items__r')) {
    			kitLineItems.add(kitLineItemRec);
    		}
    	}
    	system.debug('kitLineItems : ->' + kitLineItems);
    	
    	if(kitLineItems.size() > 0) {
    		if(AccessControl.ifObjectFieldIsUpdateable('Kit_Header_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    		update kitLineItems;
    	}
    }
    
    public static void setRetailPriceBasedOnDefaultPriceLevel(List<Kit_Header_Line_Item__c> newList) {
        Set<Id> partIdSet = new Set<Id>();
        Set<Id> labourIdSet = new Set<Id>();
        for(Kit_Header_Line_Item__c khliRec : newList) {
            if(khliRec.Part__c != null) {
                partIdSet.add(khliRec.Part__c);
            } else if(khliRec.Labour_Code__c != null) {
                labourIdSet.add(khliRec.Labour_Code__c);
            } else if(khliRec.Fee__c != null) {
                khliRec.Retail__c = khliRec.Retail_Price__c;
            }
        }
        partIdSet.remove(null);
        labourIdSet.remove(null);
        
        if(partIdSet.size() == 0 && labourIdSet.size() == 0) {
            return;
        }
        
        Map<Id, Part__c> partIdToPartRecordMap = new Map<Id, Part__c>();
        Map<Id, Labour_Code__c> labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>();
        if(partIdSet.size() > 0) {
            partIdToPartRecordMap = new Map<Id, Part__c>([SELECT Average_Cost__c, Last_Cost__c, MSRP__c, Retail_Price__c  
                                                                        FROM Part__c WHERE Id IN : partIdSet]);
        }
        if(labourIdSet.size() > 0) {
            labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>([SELECT Fixed_Rate__c, Rate__c FROM Labour_Code__c WHERE Id IN : labourIdSet]);
        }
        
        List<Price_Level__c> defaultPriceLevelList = SOTriggerHelper.getDefaultPriceLevel();
        String priceLevel_baseValue = (defaultPriceLevelList.size() > 0) ? defaultPriceLevelList[0].Part_Price_Base__c : '';
        Decimal priceLevel_discount = (defaultPriceLevelList.size() > 0) ? defaultPriceLevelList[0].Discount_Markup__c : 0;
        Decimal priceLevel_labourRate = (defaultPriceLevelList.size() > 0) ? defaultPriceLevelList[0].Labour_Rate__c : null;
        
        for(Kit_Header_Line_Item__c khliRec : newList) {
            if(khliRec.Part__c != null) {
                khliRec.Retail__c = applyPriceLevel(khliRec, partIdToPartRecordMap.get(khliRec.Part__c), priceLevel_baseValue, priceLevel_discount);
            } else if(khliRec.Labour_Code__c != null) {
                khliRec.Retail__c = applyPriceLevel(khliRec, labourIdToLabourRecordMap.get(khliRec.Labour_Code__c), priceLevel_labourRate);
            }
        }
        //return newList;
    }
    
    private static Map<String, String> priceLevelFieldToPartFieldAPINameMap = new Map<String, String> {
        'Price' => 'Retail_Price__c',
        'MSRP' => 'MSRP__c',
        'Cost' => 'Last_Cost__c',
        'Average Cost' => 'Average_Cost__c'
    };
    
    private static Decimal applyPriceLevel(Kit_Header_Line_Item__c khliRec, Part__c partRec, String priceLevel_baseValue, Decimal priceLevel_discount) {
        Decimal retailPrice = khliRec.Retail_Price__c;
        if(priceLevelFieldToPartFieldAPINameMap.containsKey(priceLevel_baseValue)) {
            Decimal baseValue;
            if(partRec.get(priceLevelFieldToPartFieldAPINameMap.get(priceLevel_baseValue)) == null) {
                baseValue = 0;
            } else {
                baseValue = Decimal.valueOf(String.valueOf(partRec.get(priceLevelFieldToPartFieldAPINameMap.get(priceLevel_baseValue))));
                priceLevel_discount = (priceLevel_discount != null) ? priceLevel_discount : 0;
                retailPrice = baseValue + (baseValue * priceLevel_discount / 100);
            }
        }
        return retailPrice;
    }
    
    private static Decimal applyPriceLevel(Kit_Header_Line_Item__c khliRec, Labour_Code__c labourRec, Decimal priceLevel_labourRate) {
        Decimal retailPrice = khliRec.Retail_Price__c;
        if(!labourRec.Fixed_Rate__c && priceLevel_labourRate != null) {
            retailPrice = priceLevel_labourRate;
        } else if(labourRec.Fixed_Rate__c) {
            retailPrice = labourRec.Rate__c;
        }
        return retailPrice;
    }
}