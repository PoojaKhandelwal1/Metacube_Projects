public with sharing class CustomerOwnedUnitTriggerHelper {
    
     // List to store trigger new list
    public static List<Customer_Owned_Unit__c> customerOwnerUnitNewList = new List<Customer_Owned_Unit__c>();
    
    // List to store trigger old list
    public static List<Customer_Owned_Unit__c> customerOwnerUnitOldList = new List<Customer_Owned_Unit__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Customer_Owned_Unit__c> customerOwnerUnitNewMap = new Map<Id, Customer_Owned_Unit__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Customer_Owned_Unit__c> customerOwnerUnitOldMap = new Map<Id, Customer_Owned_Unit__c>();
    
    private static final String UNIT_TYPE_STOCK = 'STOCK';
    private static final String UNIT_TYPE_COU = 'COU';
    private static final String UNIT_TYPE_ORDU = 'ORDU';
    private static final Integer UNIT_ID_NUMBER_OF_DIGITS = 5;
    
    public static Boolean preventOnAccountingSync = false;
    
    private static BaseIntegrationService integrationRec;
    /**
    * Name: beforeInsertOperations
    * Desc: Run beforeInsertOperations method
    * @param:   
    **/
    public static void beforeInsertOperations(){
        generateCOUId();
        for(Customer_Owned_Unit__c customerOwnerUnitRec : customerOwnerUnitNewList) {
            if(String.isNotBlank(customerOwnerUnitRec.VIN_Number__c) && customerOwnerUnitRec.VIN_Number__c == 'VIN Unknown') {
                customerOwnerUnitRec.VIN_Number__c = null;
            }
        }
    }
    
    /**
    * Name: generateCOUId
    * Desc: Calculate Unit  of COU based on Type Passed
    * @param:   (1)typeOfCOU - String - Type OF COU[COU,STOCK,ORDU] string
    *          
    * @return: Integer - count of COU based on Type Passed
    **/
    private static void generateCOUId(){
        List<Customer_Owned_Unit__c> stockcustomerOwnerUnitList = new List<Customer_Owned_Unit__c>();
        List<Customer_Owned_Unit__c> NonStockcustomerOwnerUnitList = new List<Customer_Owned_Unit__c>();
        List<Customer_Owned_Unit__c> stockUnitWithNoCategoryList = new List<Customer_Owned_Unit__c>();
        
        for(Customer_Owned_Unit__c customerOwnerUnitRec : customerOwnerUnitNewList){
            if(String.isBlank(customerOwnerUnitRec.Unit_Id__c)){
                NonStockcustomerOwnerUnitList.add(customerOwnerUnitRec);
            }
            if(customerOwnerUnitRec.Unit_Type__c == UNIT_TYPE_STOCK && String.isBlank(customerOwnerUnitRec.Stock_Id__c)){
                stockcustomerOwnerUnitList.add(customerOwnerUnitRec);
            }
            if(customerOwnerUnitRec.Unit_Type__c == UNIT_TYPE_STOCK && String.isBlank(customerOwnerUnitRec.Category__c)) {
                stockUnitWithNoCategoryList.add(customerOwnerUnitRec);
            }
        }
        populateUnitId(NonStockcustomerOwnerUnitList);
        populateStockId(stockcustomerOwnerUnitList);
        populateDefaultCategory(stockUnitWithNoCategoryList);
    }
    
    /**
    * Name: generateCount
    * Desc: Calculate count of COU based on Type Passed
    * @param:   (1)typeOfCOU - String - Type OF COU[COU,STOCK,ORDU] string
    *          
    * @return: Integer - count of COU based on Type Passed
    **/
    private static Integer generateCount(Boolean isStock){
        Integer countOfCOU=0;
        List<AggregateResult> maxCountList = new List<AggregateResult>();
        if(isStock){
            maxCountList =  [Select MAX(Max_Stock_Count__c) from Customer_Owned_Unit__c where Unit_Type__c = 'STOCK'];
        } else {
            maxCountList =  [Select MAX(Max_COU_Count__c) from Customer_Owned_Unit__c where Unit_Type__c = 'ORDU' OR Unit_Type__c = 'COU' 
                                                      OR Unit_Type__c = 'STOCK'];
        }
        
        if(maxCountList !=null && maxCountList.size() > 0){
            if(maxCountList[0].get('expr0') != null){   
                countOfCOU = Integer.valueOf(maxCountList[0].get('expr0'));
            }
        }
        return countOfCOU;
    }
    /**
    * Name: trailingZero
    * Desc: Returns the number passed with trailing Zeros 
    * @param:   (1)length - Integer  - Total number of digits possible in number
                (2)numberToAdjust - Number you want to convert
    *          
    * @return: String  - Returns the number passed with trailing Zeros 
    **/
    public static String trailingZero(Integer length,Integer numberToAdjust){
        String trailingZeroString = '';
        String numberAsString = numberToAdjust + '';
        for(Integer i =0 ;i < length - numberAsString.length();i++){
            trailingZeroString += '0';
        }
        return trailingZeroString + numberAsString;
    }
    private static void populateUnitId(List<Customer_Owned_Unit__c> NonStockCustomerOwnerUnitList){
        if(NonStockCustomerOwnerUnitList.size() > 0){
            Integer countValue = generateCount(false) + 1;
            for(Customer_Owned_Unit__c nonStockedCustomerOwnedUnit : NonStockCustomerOwnerUnitList){
                nonStockedCustomerOwnedUnit.Max_COU_Count__c = countValue;
                nonStockedCustomerOwnedUnit.Unit_Id__c = 'UNT-' +  trailingZero(UNIT_ID_NUMBER_OF_DIGITS,countValue).trim();
                countValue++;
            }
        }
        System.debug(NonStockCustomerOwnerUnitList);
    }
    private static void populateStockId(List<Customer_Owned_Unit__c> StockCustomerOwnerUnitList){
        if(StockCustomerOwnerUnitList.size() > 0) {
            Integer countValue = generateCount(true) + 1;
            for(Customer_Owned_Unit__c StockedCustomerOwnedUnit : StockCustomerOwnerUnitList){
                if(String.isBlank(StockedCustomerOwnedUnit.Stock_Id__c)) {
                    StockedCustomerOwnedUnit.Max_Stock_Count__c = countValue;
                    StockedCustomerOwnedUnit.Stock_Id__c = 'SKU-' +  trailingZero(UNIT_ID_NUMBER_OF_DIGITS,countValue).trim();
                    countValue++;
                }
            }
        }   
    }
    
    private static void populateDefaultCategory(List<Customer_Owned_Unit__c> stockUnitWithNoCategoryList) {
        if(stockUnitWithNoCategoryList.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Category__c> categoryList = [Select Id from Category__c where Type__c = 'Unit' AND Default__c = true limit 1];
            if(categoryList.size() > 0) {
                for(Customer_Owned_Unit__c stockUnitRec : stockUnitWithNoCategoryList) {
                    stockUnitRec.Category__c = categoryList[0].Id;
                }
            }
        }
    }
    
    public static void populatesFieldsBeforeUpdate() {
        for(Customer_Owned_Unit__c unitRec : customerOwnerUnitNewList) {
            if(unitRec.Id != null && unitRec.Unit_Type__c == 'STOCK' && unitRec.Status__c != 'Sold' && customerOwnerUnitOldMap.get(unitRec.Id).Category__c != unitRec.Category__c && unitRec.Total_Cost__c != null && unitRec.Total_Cost__c != 0) {
                unitRec.Old_Category__c = customerOwnerUnitOldMap.get(unitRec.Id).Category__c;
            }
            if(String.isNotBlank(unitRec.VIN_Number__c) && unitRec.VIN_Number__c == 'VIN Unknown') {
                unitRec.VIN_Number__c = null;
            }
        }
    }
    
    public static void populatesAccountingSyncFields() {
        if(QBUtil.isQBEnabled()) {
            QBSyncFlagService.manageUnitSyncFlag(customerOwnerUnitNewList);
        } else {
        	 try {
	          	if(integrationRec == null) {
	        	 	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
	        	}
	        	if(integrationRec != null) {
	        		IntegrationSyncFlagService.manageUnitSyncFlag(new List<BaseIntegrationService>{integrationRec}, customerOwnerUnitNewList);
	        	}	
        	 } catch(exception e){
	        }	
        }
    }
    
    public static void setCOUDataForAccountSync() {
        Set<Id> stockUnitIdSet = new Set<Id>();
        for(Customer_Owned_Unit__c stockUnitRec : customerOwnerUnitNewList) {
            if(stockUnitRec.availForQBSync__c) {
                stockUnitIdSet.add(stockUnitRec.Id);
            } else if(integrationRec != null) {
            	if(stockUnitRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.UNIT_INVOICE).Sync_Flag_API_Name__c) != null && 
    	    			Boolean.valueOf(stockUnitRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.UNIT_INVOICE).Sync_Flag_API_Name__c))) {
    	        		stockUnitIdSet.add(stockUnitRec.Id);
            	}
        	}
        }
        if(stockUnitIdSet.size() > 0) {
        	if(QBUtil.isQBEnabled()) {
        		preventOnAccountingSync = true;
        		UnitService.syncCOUs(stockUnitIdSet);
        	} else {
        		if(integrationRec == null) {
        	 		integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        	 	}
        		IntegrationBatchService.initiateBatch(stockUnitIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.UNIT_INVOICE);
        	}
        }
    }
    
    public static void syncInventoryWithDP360() {
        if(GeneralConfiguration.getDP360DealerId() != null) {
            Set<Id> skuIdSet = new Set<Id>();
            for(Customer_Owned_Unit__c stockUnitRec : customerOwnerUnitNewList) {
                if(stockUnitRec.Unit_Type__c == UNIT_TYPE_STOCK && ((trigger.isInsert && String.isBlank(stockUnitRec.DP360_Inventory_Id__c)) || (trigger.isUpdate && 
                    (customerOwnerUnitOldMap.get(stockUnitRec.Id).Status__c != stockUnitRec.Status__c && stockUnitRec.Status__c == 'Sold')))) {
                    skuIdSet.add(stockUnitRec.Id);
                }
            }
            if(skuIdSet.size() > 0) { 
                DP360IntegrationCtrl.upsertInventoryInDP360(skuIdSet);
            }
        } 
        return;
    }
    
    public static void populateCategoryChangeAccountingSyncFields() {
        if(QBUtil.isQBEnabled()) {
            QBSyncFlagService.manageUnitJESyncFlagOnCategoryChange(customerOwnerUnitNewList, customerOwnerUnitOldMap);
        }else {
        	 if(integrationRec == null) {
        	 	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        	 }																										
            if(integrationRec != null) {
                IntegrationSyncFlagService.manageStockUnitCategorySyncFlag(new List<BaseIntegrationService>{integrationRec}, customerOwnerUnitNewList, customerOwnerUnitOldMap);
            }
        }
    }
    
    public static void setUnitDataForCategoryChangeAccountSync() {
        Set<Id> stockUnitIdSet = new Set<Id>();
        for(Customer_Owned_Unit__c stockUnitRec : customerOwnerUnitNewList) {
            if(stockUnitRec.Avail_For_QB_Sync_Category__c) {
                stockUnitIdSet.add(stockUnitRec.Id);
            } else if(integrationRec != null) {
	            if(stockUnitRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.STOCK_UNIT_CATEGORY).Sync_Flag_API_Name__c) != null && 
	                Boolean.valueOf(stockUnitRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.STOCK_UNIT_CATEGORY).Sync_Flag_API_Name__c))) {
	                stockUnitIdSet.add(stockUnitRec.Id);
	            }
	        }
        }
        if(stockUnitIdSet.size() > 0) {
            preventOnAccountingSync = true;
            if(QBUtil.isQBEnabled()) {
                UnitCategoryService.syncUnits(stockUnitIdSet);
            } else {
            	if(integrationRec == null) {
        	 		integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        	 	}	
                IntegrationBatchService.initiateBatch(stockUnitIdSet, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.STOCK_UNIT_CATEGORY);
            }
        }
    }
}