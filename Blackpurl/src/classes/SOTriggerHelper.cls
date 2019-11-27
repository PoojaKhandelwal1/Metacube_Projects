/**
 * Author: Tarun Khandelwal
 * Since: March 08, 2016
 * Name: SOTriggerHelper
 * Description: Helper class for triggers on SO Header object
**/
public with sharing class SOTriggerHelper {
    
    // List to store trigger new list
    public static List<Service_Order_Header__c> soHeaderNewList = new List<Service_Order_Header__c>();
     
    // List to store trigger old list
    public static List<Service_Order_Header__c> soHeaderOldList = new List<Service_Order_Header__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Service_Order_Header__c> soHeaderNewMap = new Map<Id, Service_Order_Header__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Service_Order_Header__c> soHeaderOldMap = new Map<Id, Service_Order_Header__c>();
    
    public static Boolean isTriggerRun = false;
    public static Boolean refreshTaxExemptions = false;
    
    public static List<Price_Level__c> defaultPriceLevel;
    
    public static String CLAIM_UNSUBMITTED_STATUS = 'Unsubmitted';
    
    public static String COMPLETE_STATUS = 'Complete';
    public static String REVIEWED_STATUS = 'Reviewed';
    public static String SIGNEDOUT_STATUS = 'Signed Out';
    
     /**
     * Name: beforeInsertOperation
     * Desc: Before Insert Method
     * @param:  
     * @return: 
    **/
    public static void beforeInsertOperation() {
        poupulatePriceLevelForDealSO();
        populateOdometerOutAndInValue();
    }
    
    public static void beforeUpdateOperation() {
        if(entryConditionForProviderPriceLevel()) {
            updatePriceLevelFieldsOfProvider();
        }
        if(entryConditionForSOHeaderStatus()) {
            updateStatusFieldForSOHeader();
        }
        updateClaimStatus();
        populateOdometerOutAndInValue();
    }
    
    public static void afterUpdateInsertOperation() {
        if(SOTriggerHelper.refreshTaxExemptions) {
            refreshTaxExemptions();
        } else if(entryConditionForAfterUpdate()) {
        	deleteTaxExemptions();
            populateTaxExemptions(soHeaderNewList);
        }
        updateCOInvoiceItem();
    }
    
    public static void beforeDeleteOperation() {
        deleteRelatedCOForms();
        unassignRelatedAppointments();
    }
    
    private static void deleteRelatedCOForms() {
        Set<Id> soIdSet = new Set<Id>();
        for(Service_Order_Header__c soHeaderRec : soHeaderOldList) {
            soIdSet.add(soHeaderRec.Id);
        }
        soIdSet.remove(null);
        
        COFormService.deleteCOFormUsingSectionId(soIdSet);
    }
    
    /**
     * Name: entryConditionForAfterUpdate
     * Desc: After Update Condition
     * @param: 
     * @return: Boolean is ValidEntry or not
    **/
    private static Boolean entryConditionForAfterUpdate() {
        Boolean isValidEntry = false;
        for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
            if(soHeaderRec.Provider__c != null && soHeaderRec.Provider__c != soHeaderOldMap.get(soHeaderRec.Id).Provider__c) {
                isValidEntry = true;
            }
        }
        return isValidEntry;
    }
    
    //Updating invoice item if it is available to checkout
    private static void updateCOInvoiceItem() {
    	Boolean isUpdateInvItem = false;
    	Set<String> soWithCompleteStatusIdSet = new Set<String>();
    	Set<String> soWithIncompleteStatusIdSet = new Set<String>();
    	for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
	    	if(soHeaderOldMap.get(soHeaderRec.Id).Work_Status__c != COMPLETE_STATUS && soHeaderRec.Work_Status__c == COMPLETE_STATUS) {
	    		isUpdateInvItem = true;
	    		soWithCompleteStatusIdSet.add(soHeaderRec.Id);
		    } else if(soHeaderOldMap.get(soHeaderRec.Id).Work_Status__c == COMPLETE_STATUS && soHeaderRec.Work_Status__c != COMPLETE_STATUS) {
	    		isUpdateInvItem = true;
	    		soWithIncompleteStatusIdSet.add(soHeaderRec.Id);
		    }
    	}
    	if(isUpdateInvItem) {
    		List<CO_Invoice_Item__c> coInvItemList = [Select IsActive__c, Is_Invoiceable__c, Service_Order_Header__c from CO_Invoice_Item__c where (Service_Order_Header__c IN :soWithCompleteStatusIdSet) OR (Service_Order_Header__c IN :soWithIncompleteStatusIdSet)];
    		for(CO_Invoice_Item__c invItem : coInvItemList) {
    			if(soWithCompleteStatusIdSet.contains(invItem.Service_Order_Header__c)) {
    				invItem.isActive__c = invItem.Is_Invoiceable__c = true;
    			} else if(soWithIncompleteStatusIdSet.contains(invItem.Service_Order_Header__c)) {
    				invItem.isActive__c = invItem.Is_Invoiceable__c = false;
    			}
    		}
    		update coInvItemList;
    	}
    }
    
    private static void poupulatePriceLevelForDealSO() {
    	for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
	    	if(soHeaderRec.Job_Type__c == 'Deal') {
		        defaultPriceLevel = getInternalDefaultPriceLevel();
		        if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
	                defaultPriceLevel = getDefaultPriceLevel();
	            } 
	            setPriceLevelRelatedFields(soHeaderRec, (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Discount_Markup__c : 0, 
	                                           (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Part_Price_Base__c : null, 
	                                           (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Labour_Rate__c : null);
		    } else {
		        setPriceLevelRelatedFields(soHeaderRec, null, null, 0);
		    }
    	}
    }
     
    private static void updateClaimStatus() {
    	for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
    		if(soHeaderNewMap.get(soHeaderRec.Id).Provider__c != null && soHeaderOldMap.get(soHeaderRec.Id).Provider__c == null && 
    				soHeaderNewMap.get(soHeaderRec.Id).Claim_Status__c == null) {
    			soHeaderRec.Claim_Status__c = CLAIM_UNSUBMITTED_STATUS;
    		}
    	}
    }
    
    private static Boolean entryConditionForProviderPriceLevel() {
    	Boolean isValidEntry = false;
    	for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
    		if(soHeaderNewMap.get(soHeaderRec.Id).Provider__c != soHeaderOldMap.get(soHeaderRec.Id).Provider__c ||
    		   soHeaderNewMap.get(soHeaderRec.Id).Job_Type__c != soHeaderOldMap.get(soHeaderRec.Id).Job_Type__c) {
    			isValidEntry = true;
    		}
    		
    	}
    	return isValidEntry;
    }
    
    private static Boolean entryConditionForSOHeaderStatus(){
    	Boolean isValidEntry = false;
    	for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
	    	if((soHeaderNewMap.get(soHeaderRec.Id).Work_Status__c != soHeaderOldMap.get(soHeaderRec.Id).Work_Status__c) &&
				 (soHeaderNewMap.get(soHeaderRec.Id).Work_Status__c == COMPLETE_STATUS 
                 || soHeaderNewMap.get(soHeaderRec.Id).Work_Status__c == REVIEWED_STATUS || 
                 soHeaderNewMap.get(soHeaderRec.Id).Work_Status__c == SIGNEDOUT_STATUS )){
				 isValidEntry = true;
	    	}
    	}
    	return isValidEntry;
    }
    
    
    
    private static void updateStatusFieldForSOHeader(){
    	for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
    		if(soHeaderRec.Work_Status__c != null){
    			if(soHeaderRec.Work_Status__c == SIGNEDOUT_STATUS) {
    				soHeaderRec.Status__c = COMPLETE_STATUS ;
    			} else {
    				soHeaderRec.Status__c = soHeaderRec.Work_Status__c;
    			}
    		}
    	}
    }
    
    private static void updatePriceLevelFieldsOfProvider() {
    	updatePLFields(soHeaderNewList);
    }
    
    public static void updatePLFields(List<Service_Order_Header__c> soHeaderList) {
    	List<Id> providerIdList = new List<Id>();
		for(Service_Order_Header__c soHeaderRec : soHeaderList) {
			if(soHeaderRec.Provider__c != null) {
				providerIdList.add(soHeaderRec.Provider__c);
			}
		}
		
		Map<Id, Account> vendorMap = new Map<Id, Account>();
		if(providerIdList.size() > 0) {
			if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
			vendorMap = new Map<Id, Account>([select Price_Level__c, Price_Level__r.Labour_Rate__c, Price_Level__r.Discount_Markup__c, Price_Level__r.Part_Price_Base__c from Account where Id IN : providerIdList]);
		}
		for(Service_Order_Header__c soHeaderRec : soHeaderList) {
			if(soHeaderRec.Provider__c == null) {
			    if(soHeaderRec.Job_Type__c == 'Internal' || soHeaderRec.Job_Type__c == 'Deal') {
			        defaultPriceLevel = getInternalDefaultPriceLevel();
			        if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
	                    defaultPriceLevel = getDefaultPriceLevel();
	                } 
	                setPriceLevelRelatedFields(soHeaderRec, (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Discount_Markup__c : 0, 
	                                               (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Part_Price_Base__c : null, 
	                                               (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Labour_Rate__c : null);
			    } else {
			        setPriceLevelRelatedFields(soHeaderRec, null, null, 0);
			    }
			} else if(vendorMap.containsKey(soHeaderRec.Provider__c) && vendorMap.get(soHeaderRec.Provider__c).Price_Level__c != null) {
			    setPriceLevelRelatedFields(soHeaderRec, vendorMap.get(soHeaderRec.Provider__c).Price_Level__r.Discount_Markup__c, 
                                                   vendorMap.get(soHeaderRec.Provider__c).Price_Level__r.Part_Price_Base__c, 
                                                   vendorMap.get(soHeaderRec.Provider__c).Price_Level__r.Labour_Rate__c);
			} else {
				if(defaultPriceLevel == null) {
					defaultPriceLevel = getDefaultPriceLevel();
				} 
				setPriceLevelRelatedFields(soHeaderRec, (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Discount_Markup__c : 0, 
                                                   (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Part_Price_Base__c : null, 
                                                   (defaultPriceLevel.size() > 0) ? defaultPriceLevel[0].Labour_Rate__c : null);
			}
		}
    }
    
    private static void setPriceLevelRelatedFields(Service_Order_Header__c soHeaderRec, Decimal discount, String baseValue, Decimal laborRate) {
        soHeaderRec.Provider_Discount_Markup__c = discount;
        soHeaderRec.Provider_Part_Price_Base__c = baseValue;
        soHeaderRec.Provider_Labour_Rate__c = laborRate;
    }
    
    /**
     * Name: getDefaultPriceLevel
     * Desc: Method to get Default Price Level In system
     * @param: 
     * @return:  List<Price_Level__c> - List of default price level. Ideally size of list - 1 
    **/
    public static List<Price_Level__c> getDefaultPriceLevel() {
    	if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	defaultPriceLevel = [select Part_Price_Base__c, Discount_Markup__c, Labour_Rate__c from Price_Level__c where Default__c = true];
    	return defaultPriceLevel;
    }
    
    /**
     * Name: getInternalDefaultPriceLevel
     * Desc: Method to get Default Price Level In system
     * @param: 
     * @return:  List<Price_Level__c> - List of default price level. Ideally size of list - 1 
    **/
    public static List<Price_Level__c> getInternalDefaultPriceLevel() {
        String defaultPriceLevelId_Internal = GeneralConfiguration.getDefaultPriceLevelOnInternalService();
        if(String.isNotBlank(defaultPriceLevelId_Internal)) {
            if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Price_Level__c> priceLevelList = [Select Part_Price_Base__c, Discount_Markup__c, Labour_Rate__c from Price_Level__c 
                                                        where Id =: defaultPriceLevelId_Internal];
            return priceLevelList;
        }
        return null;
    }

    /**
     * Name: getDefaultSalesTax
     * Desc: Getting Default Sales Tax
     * @param: (1) getDefaultSalesTax - Sales_Tax__c - Sales Tax Record 
     * @return: 
     **/
    private static Sales_Tax__c getDefaultSalesTax() {
    	if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Sales_Tax__c> salesTaxList = [select Default__c from Sales_Tax__c where Default__c = true];
    	Sales_Tax__c salesTax = new Sales_Tax__c(Labour_Tax__c = 0);
    	if(salesTaxList.size() > 0) {
    		salesTax = salesTaxList[0]; 
    	}
    	return salesTax;
    }
    
    /**
    * Name: unassignRelatedAppointments
    * Desc: Method to unlink appointments from SO and unschedule the appointment(remove technician) when deleting Service Job
    * @param:
    **/
   	private static void unassignRelatedAppointments() {
   		if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
   		List<Event> eventListToUpdate = [SELECT Id FROM Event WHERE Service_Order_Header__c IN: soHeaderOldMap.keySet()];
   		for(Event eventRec: eventListToUpdate) {
   			eventRec.CO_Header__c = null;
   			eventRec.Service_Order_Header__c = null;
   			eventRec.Technician__c = null;
   		}
		if(eventListToUpdate.size() > 0) {
			if(AccessControl.ifObjectFieldIsUpdateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
       		update eventListToUpdate;
		}
   	}
   	
    
    /**
     * Name: refreshTaxExemptions
     * Desc: Refresh TaxExemptions
     * @param: 
     * @return: 
    **/
    private static void refreshTaxExemptions() {
        deleteTaxExemptions();
        populateTaxExemptions(soHeaderNewList);
    }
    
    /**
     * Name: deleteTaxExemptions
     * Desc: Delete TaxExemptions
     * @param: 
     * @return: 
    **/
    private static void deleteTaxExemptions() {
        if(AccessControl.ifObjectFieldIsUpdateable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        
        List<Tax_Exemption__c> taxExemptionsList = [select Id from Tax_Exemption__c where Service_Order_Header__c IN: soHeaderNewList];
        if(taxExemptionsList.size() > 0) {
            delete taxExemptionsList;
        }
    }
    
    /**
     * Name: populateTaxExemptions
     * Desc: Populate TaxExemptions
     * @param: 
     * @return: 
    **/
    public static void populateTaxExemptions(List<Service_Order_Header__c> soHeaderNewList) {
        if(AccessControl.ifObjectFieldIsAccessible('Account') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
        // Step 1 - Get Map vendorId to Account_Type__c based on providerIds.
        Set<Id> providerIdList = new Set<Id>();
        for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
            providerIdList.add(soHeaderRec.Provider__c);
        }
        Map<Id, Account> providerIdToAccountTypeMap = new Map<ID, Account>([SELECT Account_Type__c, Vendor_Account_Type__c from Account Where Id IN : providerIdList]);
        
        // Step 2 - Get list of Tax_Exemption__c based on Account_Type__c ids.
        Set<Id> accountTypeIds = new Set<Id>();
        for (Account account : providerIdToAccountTypeMap.values()) {
            accountTypeIds.add(account.Vendor_Account_Type__c);
        }
        accountTypeIds.remove(null);
        List<Tax_Exemption__c> taxExemptionsList = [SELECT Id, Account_Type__c, Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__c FROM Tax_Exemption__c WHERE Account_Type__c IN :accountTypeIds];

        // Step 3 - Create new Tax_Exemption records and set Service_Order_Header__c on them
        List<Tax_Exemption__c> soHeaderTaxExemptionsList = new List<Tax_Exemption__c>();
        for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
            List<Tax_Exemption__c> taxExemptions = new List<Tax_Exemption__c>();
            for(Tax_Exemption__c taxExemption : taxExemptionsList) {
                if(providerIdToAccountTypeMap.containsKey(soHeaderRec.Provider__c) && providerIdToAccountTypeMap.get(soHeaderRec.Provider__c).Vendor_Account_Type__c == taxExemption.Account_Type__c) {
                    Tax_Exemption__c newTaxExemption = taxExemption.clone(false, false, false, false);
                    newTaxExemption.Service_Order_Header__c = soHeaderRec.Id;
                    newTaxExemption.Account_Type__c = null;
                    soHeaderTaxExemptionsList.add(newTaxExemption);
                }
            }
        }
        
        // Step 4 - Save Tax_Exemption__c records
        if(!soHeaderTaxExemptionsList.isEmpty()) {
            insert soHeaderTaxExemptionsList;
        }
    }
    
    /**
     * Name: populateOdometerOutAndInValue
     * Desc: Method to update populate Odometer OUT and Odometer In value on SO with Mileage value from Unit Record
     * @param:
     * @return:
    **/
    public static void populateOdometerOutAndInValue() {
        Set<String> validUnitIdSet = getValidUnitsForPopulateOdometerOutAndInValue();
        if(validUnitIdSet.size() > 0) {
            if(!AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	        Map<String, Customer_Owned_Unit__c> unitIdToUnitRecMap = new Map<String, Customer_Owned_Unit__c>(
	                           [SELECT Mileage_Value__c FROM Customer_Owned_Unit__c WHERE Id IN: validUnitIdSet]);
	        Decimal unitMileage;
	        for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
                unitMileage = (unitIdToUnitRecMap.get(soHeaderRec.Customer_Owned_Unit__c).Mileage_Value__c != null) ? 
                                    unitIdToUnitRecMap.get(soHeaderRec.Customer_Owned_Unit__c).Mileage_Value__c : 0;
                soHeaderRec.Odometer_on_Arrival__c = unitMileage;
                soHeaderRec.Odometer_on_Departure__c = unitMileage;
            }
    	}
    }
    
    private static Set<String> getValidUnitsForPopulateOdometerOutAndInValue() {
        Set<String> validUnitIdSet = new Set<String>();
        for(Service_Order_Header__c soHeaderRec : soHeaderNewList) {
            if(soHeaderRec.Customer_Owned_Unit__c != null && (soHeaderNewMap == null || soHeaderRec.Customer_Owned_Unit__c != soHeaderOldMap.get(soHeaderRec.Id).Customer_Owned_Unit__c)) {
                validUnitIdSet.add(soHeaderRec.Customer_Owned_Unit__c);
            }
        }
        return validUnitIdSet;
    }
}