/** 
* Author: Hitesh Gupta
* Since: Nov 3, 2017 
* Name: UnitOrderingService 
* Description: Apex class which contains all service methods related to Unit Ordering Page.
**/
public with sharing class UnitOrderingService {
    
    public static List<UnitOrderingWrapper.VendorWrapper> getVendorsList(){
        List<Account> vendorsList = [select Id, Name, 
                                        (select Id from Customer_Owned_Units1__r where Unit_Type__c = 'ORDU' AND Status__c = 'On Order')
                                        from Account 
                                        where Is_Vendor__c = true
                                            AND Unit_Purchases__c = true]; 
                                        
        List<UnitOrderingWrapper.VendorWrapper> vendorList = new UnitOrderingWrapper.VendorWrapper().convertToWrapperList(vendorsList);
        return vendorList;
    }
    
    public static UnitOrderingWrapper.VendorWrapper getVendorDetailsById(String vendorId){
        List<Account> vendorsList = [select Id, Name 
                                        from Account 
                                        where Is_Vendor__c = true
                                            AND Id = :vendorId]; 
        UnitOrderingWrapper.VendorWrapper vendorObj = new UnitOrderingWrapper.VendorWrapper(vendorsList[0]);
        return vendorObj;                                   
    }
    
    public static List<CategoryService.CategoryWrapper> getUnitCategoryList() {
        return CategoryService.getFilteredCategoryWrapperList(new Map<String, String>{'Type__c' => 'Unit'});
    }
    
    public static void SetUnitPurchaseFlagForVendor(String vendorId){
        Account acc = new Account();
        acc.Id = vendorId;
        acc.Unit_Purchases__c = true;
        update acc;
    }   
    
    public static List<UnitOrderingWrapper.UnitOrderWrapper> getActiveOrderList(String vendorId) {
        return getActiveOrderList(vendorId, new Map<String, String>{'Unit_Number__c' => 'ASC'});
    }
    
    public static List<UnitOrderingWrapper.UnitOrderWrapper> getActiveOrderList(String vendorId, String JSONString) {
        UnitOrderingWrapper.SortingAttrs sortAttrs = (UnitOrderingWrapper.SortingAttrs) System.JSON.deserialize(jSONString, UnitOrderingWrapper.SortingAttrs.class);
        
        Map<String, String> fieldNameToSortOrderMap = new Map<String, String>();
        if(UnitOrderingWrapper.fieldLabelToFieldAPINameMap.containsKey(sortAttrs.FieldLabel)) {
            fieldNameToSortOrderMap.put(UnitOrderingWrapper.fieldLabelToFieldAPINameMap.get(sortAttrs.FieldLabel), sortAttrs.SortingOrder);
        }
        return getActiveOrderList(vendorId, fieldNameToSortOrderMap);
    }
    
    public static List<UnitOrderingWrapper.UnitOrderWrapper> getActiveOrderList(String vendorId, Map<String, String> fieldNameToSortOrderMap){
        String query = 'SELECT Id, Name, Unit_Number__c, Stock_Id__c, Year__c, Cylinders__c, Tax_Amount__c, Make_Name__c, Colour__c,Model_Name__c, Sub_Model__c, Model_Detail__c, Status__c, Factory_Order_No__c,CreatedDate, Total_Cost__c, VIN_Number__c, Vendor__r.Purchase_Tax__r.Rate__c, Invoice_Number__c, Stocked_In_DateTime__c, Unit_Model__c, Unit_Model__r.Name__c, Sub_Model__r.Sub_Model_Name__c, Compliance_Date__c, Registration_Serial__c, Year_Of_1st_Rego__c';
        query += ', (SELECT Id, Name, Deal__r.CO_Header__r.Name FROM Deals_Units_Junction__r)';
        query += ' FROM Customer_Owned_Unit__c';
        query += ' WHERE Vendor__c = :vendorId AND Unit_Type__c = \'ORDU\' AND Status__c = \'On Order\' Order BY ';
        
        String orderByClause = '';
        for(String fieldName : fieldNameToSortOrderMap.keySet()) {
            orderByClause += fieldName + ' ' + fieldNameToSortOrderMap.get(fieldName) + ', '; 
        }
        if(orderByClause.length() > 0) {
            orderByClause = orderByClause.subString(0, orderByClause.length() - 2);
            query += orderByClause;
        } else {
            query += 'Unit_Number__c ASC';
        }
        
        List<Customer_Owned_Unit__c> couList = Database.query(query);                                       
        List<UnitOrderingWrapper.UnitOrderWrapper> unitList = new UnitOrderingWrapper.UnitOrderWrapper().convertToWrapperList(couList);
        return unitList;
    }
        
    public static void cancelOrderedUnit(String unitId) {
        Customer_Owned_Unit__c unitRec = new Customer_Owned_Unit__c(Id = unitId);
        unitRec.Status__c = 'Cancelled';
        unitRec.Stocked_In_DateTime__c = system.now();
        if(String.isNotBlank(unitRec.Id)) {
            update unitRec;
        }
    }
    
    public static void savePriceAndCost(String jSONString) {
        UnitWrapper.PriceAndCostTrackingWrapper unitPriceAndCostObj = (UnitWrapper.PriceAndCostTrackingWrapper) System.JSON.deserialize(jSONString, UnitWrapper.PriceAndCostTrackingWrapper.class);
        Unit_Price_Cost__c unitPriceAndCostRec = setUnitPriceAndCostFields(unitPriceAndCostObj); 
        if(String.isNotBlank(unitPriceAndCostObj.Id)) {
            if(AccessControl.ifObjectFieldIsUpdateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update unitPriceAndCostRec;
        } else {
            if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert unitPriceAndCostRec;
        }
    }
    
    public static void removePriceAndCost(String recordId) {
        if(AccessControl.ifObjectIsDeletable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        delete new Unit_Price_Cost__c(Id = recordId);
    } 
    
    public static Unit_Price_Cost__c setUnitPriceAndCostFields(UnitWrapper.PriceAndCostTrackingWrapper unitPriceAndCostObj) {
        
        Unit_Price_Cost__c unitPriceAndCostRec = new Unit_Price_Cost__c();

        unitPriceAndCostRec.Id = unitPriceAndCostObj.Id;
        unitPriceAndCostRec.Type__c = unitPriceAndCostObj.Type;
        unitPriceAndCostRec.Item_Description__c = unitPriceAndCostObj.ItemDescription;
        unitPriceAndCostRec.Qty__c = unitPriceAndCostObj.Quantity;
        unitPriceAndCostRec.Price__c = unitPriceAndCostObj.Price;
        if(unitPriceAndCostRec.Type__c == 'Factory' || unitPriceAndCostRec.Type__c == 'Base') {
            unitPriceAndCostRec.Price__c = unitPriceAndCostObj.TotalPrice;
        }
        unitPriceAndCostRec.Total_Price__c = unitPriceAndCostObj.TotalPrice; 
        unitPriceAndCostRec.Total_Cost__c = unitPriceAndCostObj.TotalCost;
        unitPriceAndCostRec.Customer_Owned_Unit__c = unitPriceAndCostObj.UnitId; 
        return unitPriceAndCostRec;
    }
    
    public static List<UnitOrderingWrapper.UnitOrderWrapper> getOrderHistoryList(String vendorId) {
        return getOrderHistoryList(vendorId, new Map<String, String>{'Stocked_In_DateTime__c' => 'DESC'});
    }
    
    public static List<UnitOrderingWrapper.UnitOrderWrapper> getOrderHistoryList(String vendorId, String JSONString) {
        UnitOrderingWrapper.SortingAttrs sortAttrs = (UnitOrderingWrapper.SortingAttrs) System.JSON.deserialize(jSONString, UnitOrderingWrapper.SortingAttrs.class);
        
        Map<String, String> fieldNameToSortOrderMap = new Map<String, String>();
        if(UnitOrderingWrapper.fieldLabelToFieldAPINameMap.containsKey(sortAttrs.FieldLabel)) {
            fieldNameToSortOrderMap.put(UnitOrderingWrapper.fieldLabelToFieldAPINameMap.get(sortAttrs.FieldLabel), sortAttrs.SortingOrder);
        }
        return getOrderHistoryList(vendorId, fieldNameToSortOrderMap);
    }
     
    public static List<UnitOrderingWrapper.UnitOrderWrapper> getOrderHistoryList(String vendorId, Map<String, String> fieldNameToSortOrderMap){
        String query = 'SELECT Id, Name, Unit_Number__c, Stock_Id__c, Year__c, Cylinders__c, Tax_Amount__c, Make_Name__c, Colour__c, Model_Name__c, Sub_Model__c, Model_Detail__c, Status__c, Factory_Order_No__c, CreatedDate, Total_Cost__c, VIN_Number__c, Vendor__r.Purchase_Tax__r.Rate__c, Invoice_Number__c, Stocked_In_DateTime__c, Unit_Model__c, Unit_Model__r.Name__c, Sub_Model__r.Sub_Model_Name__c, Compliance_Date__c, Registration_Serial__c, Year_Of_1st_Rego__c';
        query += ' FROM Customer_Owned_Unit__c';
        query += ' WHERE Vendor__c = :vendorId AND Unit_Type__c = \'ORDU\' AND (Status__c = \'Cancelled\' OR Status__c = \'Received\') ORDER BY ';
        
        String orderByClause = '';
        for(String fieldName : fieldNameToSortOrderMap.keySet()) {
            orderByClause += fieldName + ' ' + fieldNameToSortOrderMap.get(fieldName) + ', '; 
        }
        if(orderByClause.length() > 0) {
            orderByClause = orderByClause.subString(0, orderByClause.length() - 2);
            query += orderByClause;
        } else {
            query += 'CreatedDate DESC';
        }
        
        List<Customer_Owned_Unit__c> couList = Database.query(query);                   
        
        List<UnitOrderingWrapper.UnitOrderWrapper> unitList = new UnitOrderingWrapper.UnitOrderWrapper().convertToWrapperList(couList);
        return unitList;
    }
    
    
    public static List<UnitOrderingWrapper.UnitDetailsWrapper> getUnitDetails(String unitId){
        List<Customer_Owned_Unit__c> COUList = SOQLUtil.getUnitByFieldName(new Map<String, String>{'Id' => unitId});
        List<UnitOrderingWrapper.UnitDetailsWrapper> couWrapperRec = new List<UnitOrderingWrapper.UnitDetailsWrapper>();
        for(Customer_Owned_Unit__c couRec : COUList) {
            couWrapperRec.add(new UnitOrderingWrapper.UnitDetailsWrapper(couRec));
        }  
        return couWrapperRec;
        
    }
    
    
    public static String saveUnitDetails(String jSONString){
        UnitOrderingWrapper.UnitDetailsWrapper unitObj = (UnitOrderingWrapper.UnitDetailsWrapper) System.JSON.deserialize(jSONString, UnitOrderingWrapper.UnitDetailsWrapper.class);
        Customer_Owned_Unit__c unitRec = ViewUnitCtrl.setUnitFields(unitObj.UnitInfo); 
        
        if(unitObj.UnitInfo.Make == null) {
        	List<Unit_Make__c> makeList = [Select Name from Unit_Make__c where Name =: unitObj.UnitInfo.MakeName];
        	if(makeList.size() == 0) {
        		Unit_Make__c makeRec = new Unit_Make__c(Name = unitObj.UnitInfo.MakeName);
        		insert makeRec;
        		unitRec.Unit_Make__c = makeRec.Id;
        	} else {
        		unitRec.Unit_Make__c = makeList[0].Id;
        	}
        	
        	
        }
        if(unitObj.UnitInfo.Model == null) {
        	List<Unit_Model__c> modelList = [Select Name__c, Unit_Make__c from Unit_Model__c where Name__c =: unitObj.UnitInfo.ModelName AND Unit_Make__c =: unitRec.Unit_Make__c];
        	if(modelList.size() == 0) {
        		Unit_Model__c modelRec = new Unit_Model__c(Name__c = unitObj.UnitInfo.ModelName, Unit_Make__c = unitRec.Unit_Make__c);
	        	insert modelRec;
	        	unitRec.Unit_Model__c = modelRec.Id;
        	} else {
        		unitRec.Unit_Model__c = modelList[0].Id;
        	}
        }
        if(unitObj.UnitInfo.SubModel == null && String.isNotBlank(unitObj.UnitInfo.SubModelName)) { 
        	List<Unit_Sub_Model__c> subModelList = [Select Sub_Model_Name__c, Unit_Model__c from Unit_Sub_Model__c where Sub_Model_Name__c =: unitObj.UnitInfo.SubModelName AND Unit_Model__c =: unitRec.Unit_Model__c];
	    	if(subModelList.size() == 0) {
	    		Unit_Sub_Model__c subModelRec = new Unit_Sub_Model__c(Sub_Model_Name__c = unitObj.UnitInfo.SubModelName, Unit_Model__c = unitRec.Unit_Model__c);
	        	insert subModelRec;
	        	unitRec.Sub_Model__c = subModelRec.Id;
	    	} else {
	    		unitRec.Sub_Model__c = subModelList[0].Id;
	    	}
        	
        }
        
        unitRec.Factory_Order_No__c = unitObj.UnitInfo.FactoryOrderNo;
        unitRec.Unit_Id__c = unitObj.UnitInfo.UnitId;
        
        List<Customer_Owned_Unit__c> unitList = [Select Id from Customer_Owned_Unit__c where Unit_Id__c =: unitObj.UnitInfo.UnitId];
        if(unitList.size() > 0 && unitList[0].Id != unitObj.UnitInfo.Id && String.isNotBlank(unitObj.UnitInfo.UnitId)) {
            return 'Duplicate Stock Number';
        }
        
        if(String.isNotBlank(unitObj.UnitInfo.VIN) && unitObj.UnitInfo.VIN != 'VIN Unknown') {
            List<Customer_Owned_Unit__c> similarVINUnitList = SOQLUtil.getSimilarCOUs(unitObj.UnitInfo.VIN);
            if(similarVINUnitList.size() > 0 && (String.isBlank(unitObj.UnitInfo.Id) || (similarVINUnitList[0].Id != unitObj.UnitInfo.Id))) {
                return 'Duplicate VIN Number';
            }
        }
        
        if(unitObj.UnitInfo.Id != null) {
            unitRec.Id = unitObj.UnitInfo.Id;
        }
        
        // Save Tags for units 
        if(unitObj.UnitInfo.AssignedTags != null && unitObj.UnitInfo.AssignedTags.size() > 0) {
            List<String> tagStrListForFields = TagUtil.convertTagListIntoTagString(unitObj.UnitInfo.AssignedTags);
            if(tagStrListForFields.size() == 2) {
                unitRec.Assigned_Tag_1__c = tagStrListForFields[0];
                unitRec.Assigned_Tag_2__c = tagStrListForFields[1];
            }
        } else {
            unitRec.Assigned_Tag_1__c = unitRec.Assigned_Tag_2__c = '';
        }
        upsert unitRec;
        return unitRec.Id;
    }
    
    public static String receiveUnits(String jSONString) {
        
        List<UnitOrderingWrapper.UnitOrderWrapper> orderedUnits = (List<UnitOrderingWrapper.UnitOrderWrapper>) System.JSON.deserialize(jSONString, List<UnitOrderingWrapper.UnitOrderWrapper>.class);
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        
		orderedUnits = upsertMakeModelSubModelForUnit(orderedUnits);
		
        Map<String, Customer_Owned_Unit__c> orderedUnitsIdToReceivedUnitMap = new Map<String, Customer_Owned_Unit__c>();
        List<String> invoiceNumbers = new List<String>();
        for(UnitOrderingWrapper.UnitOrderWrapper unit : orderedUnits) {
            invoiceNumbers.add(unit.InvoiceNumber); // List to validate InvoiceNumber(s) Duplicacy
            
            Customer_Owned_Unit__c cou = new Customer_Owned_Unit__c();
            cou.Id = unit.UnitId;
            cou.VIN_Number__c = unit.VIN;
            cou.Invoice_Number__c = unit.InvoiceNumber;
            cou.Status__c = 'Received';
            cou.ORDU_Stock_Id__c = unit.StockNumber;
            cou.Stock_Id__c = null;
            cou.Stocked_In_DateTime__c = String.isNotBlank(unit.StockedInDateTime) ? HomeSearchFilterInterface.getDateFromString(unit.StockedInDateTime) : system.now();
            cou.Is_Ordered_Unit_Added_To_Deal__c = false;
            cou.Total_Cost__c = unit.TotalCost;
            cou.Unit_Make__c = unit.MakeId;
            cou.Unit_Model__c = unit.ModelId;
            cou.Sub_Model__c = unit.SubModelId;
            cou.Year__c = unit.Year;
            cou.Cylinders__c = unit.Cylinders; 
            orderedUnitsIdToReceivedUnitMap.put(unit.UnitId, cou);
        }
        
        List<Customer_Owned_Unit__c> alreadyReceivedCOUs = [SELECT Id FROM Customer_Owned_Unit__c WHERE Status__c = 'Received' AND Id In :orderedUnitsIdToReceivedUnitMap.keySet()];
        List<Customer_Owned_Unit__c> duplicateCOUs = [SELECT Id, Invoice_Number__c FROM Customer_Owned_Unit__c WHERE Unit_Type__c = 'ORDU' AND Status__c = 'Received' AND Invoice_Number__c In :invoiceNumbers];
        if(duplicateCOUs.isEmpty() && alreadyReceivedCOUs.isEmpty()) {
            Savepoint sp = Database.setSavepoint();
            try {
                Map<String, Customer_Owned_Unit__c> orderedUnitsIdToStockUnitMap = new Map<String, Customer_Owned_Unit__c>();
                
                //Step 1: Update Customer_Owned_Unit__c with VIN, InoviceNumber, status as “Received” 
                
                if(!orderedUnitsIdToReceivedUnitMap.isEmpty()) {
                    update orderedUnitsIdToReceivedUnitMap.values();
                    // put all code here
                }
                
                /* Step 2: This of course would carry across all of the Price & Cost line items 
                   as well which will have the invoice# used for the REF# field in the line items on the Stock Unit record. */
                // 2.1: Load DO Customer_Owned_Unit__c for selected Ids
                List<Customer_Owned_Unit__c> receivedUnitsList = null;
                if(!orderedUnitsIdToReceivedUnitMap.isEmpty()) {
                    String query = 'Select ';
                    for(String fieldName : CustomerOwnedUnit.fieldsList()) {
                        query += fieldName + ', ';
                    }
                    query += 'Total_Cost__c, Invoice_Number__c, (SELECT Id, Deal__r.Status__c FROM Deals_Units_Junction__r) ';
                    Set<String> params = orderedUnitsIdToReceivedUnitMap.keySet();
                    query += ' from Customer_Owned_Unit__c where Id In :params';
                    receivedUnitsList = Database.query(query);
                    
                    //Step 2.2: Cloning & Creating as Stock Units with an “Available” status and “STOCK” type
                    String defaultUnitSalesTaxId = Configurations__c.getInstance().Default_Tax_on_Unit__c;
                    Map<String, Customer_Owned_Unit__c> receivedUnitIdToStockUnitsMap = new Map<String, Customer_Owned_Unit__c>();
                    for(Customer_Owned_Unit__c receivedUnit : receivedUnitsList) {
                        SObject stockUnit = receivedUnit.clone(false, false, false, false);
                        stockUnit.put('Id',null);
                        stockUnit.put('Unit_Type__c','Stock');
                        if(receivedUnit.Deals_Units_Junction__r.size() > 0 && receivedUnit.Deals_Units_Junction__r[0].Deal__r.Status__c == 'In Progress') {
                        	stockUnit.put('Status__c','Reserved');
                        } else {
                        	stockUnit.put('Status__c','Available');
                        }
                        stockUnit.put('Stock_Id__c', receivedUnit.ORDU_Stock_Id__c);
                        stockUnit.put('ORDU_Stock_Id__c', null);
                        stockUnit.put('Unit_Id__c',null);
                        stockUnit.put('Date_Stocked_In__c', receivedUnit.Stocked_In_DateTime__c != null ? receivedUnit.Stocked_In_DateTime__c.date(): Date.today());
                        stockUnit.put('Referenced_Unit__c', receivedUnit.Id);
                        stockUnit.put('Total_Cost__c', receivedUnit.Total_Cost__c);
                        receivedUnitIdToStockUnitsMap.put(receivedUnit.Id, (Customer_Owned_Unit__c) stockUnit);
                    }
                    if(!receivedUnitIdToStockUnitsMap.isEmpty()) {
                        insert receivedUnitIdToStockUnitsMap.values();
                    }

                    // Step 2.3: Pull Unit_Price_Cost__c records of OrderedUnits received - clone/create new Unit_Price_Cost__c records under StockeUnits and save them
                    query = 'Select ';
                    for(String fieldName : UnitWrapper.fieldsListForUnitPriceAndCostTracking()) {
                        query += fieldName + ', ';
                    }
                    query = query.substring(0, query.length()-2);
                    query += ', ' + '(Select Id FROM Unit_Prices_Costs__r) ';
                    query += ' from Unit_Price_Cost__c where Customer_Owned_Unit__c In :params';
                    List<Unit_Price_Cost__c> unitPriceCostItemsOfOrderedUnits = Database.query(query);
                    
                    List<Unit_Price_Cost__c> newUnitPriceCostItems = new List<Unit_Price_Cost__c>();
                    for(Unit_Price_Cost__c upc : unitPriceCostItemsOfOrderedUnits) {
                        SObject upcItem = upc.clone(false, false, false, false);
                        upcItem.put('Customer_Owned_Unit__c', receivedUnitIdToStockUnitsMap.get(upc.Customer_Owned_Unit__c).Id);
                        upcItem.put('Ref_No__c', orderedUnitsIdToReceivedUnitMap.get(upc.Customer_Owned_Unit__c).Invoice_Number__c);
                    	upcItem.put('Related_Ordered_Unit_Price_Cost__c', upc.Id);
                        newUnitPriceCostItems.add((Unit_Price_Cost__c) upcItem);
                    }
                    if(!newUnitPriceCostItems.isEmpty()) {
                        insert newUnitPriceCostItems;
                    }
                    
                    updateDealItems(newUnitPriceCostItems, unitPriceCostItemsOfOrderedUnits, receivedUnitsList, receivedUnitIdToStockUnitsMap);
                    updateDealServiceUnits(receivedUnitIdToStockUnitsMap);
                }
            } catch(Exception e) {
                Database.rollback(sp);
                throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
            }
        } else {
            String duplicateInvoiceNumbers = '';
            if(duplicateCOUs.size() > 0) {
                for(Customer_Owned_Unit__c units : duplicateCOUs) {
                    duplicateInvoiceNumbers += units.Invoice_Number__c + ' ';
                }
            }
            return BPUtility.getEncodedString('{"DuplicateInvoiceNumbers" : "'+ duplicateInvoiceNumbers +'","HasError" : true, "ErrorMessage" : "' + (alreadyReceivedCOUs.isEmpty()? Label.Duplicate_Invoice_Number_Error_Msg : Label.Unit_Already_Received_Error_Msg) + '"}');
        }
        return 'SUCCESS';
    }
    
    public static List<UnitOrderingWrapper.UnitOrderWrapper> upsertMakeModelSubModelForUnit(List<UnitOrderingWrapper.UnitOrderWrapper> orderedUnits) {
    	Map<String, UnitOrderingWrapper.UnitOrderWrapper> makeNameToUnitMap = new Map<String, UnitOrderingWrapper.UnitOrderWrapper>();
    	Map<String, Map<String, String>> makeIdToModelNameToModelIdMap = new Map<String, Map<String, String>>();
    	Map<String, UnitOrderingWrapper.UnitOrderWrapper> subModelNameToUnitMap = new Map<String, UnitOrderingWrapper.UnitOrderWrapper>();
        
        Map<String, String> makeNameToMakeIdMap = new Map<String, String>();
        for(UnitOrderingWrapper.UnitOrderWrapper unit : orderedUnits) {
        	makeNameToMakeIdMap.put(unit.MakeName, null);
        }
        List<Unit_Make__c> makeList = [Select Name from Unit_Make__c where Name IN: makeNameToMakeIdMap.keySet()];
        
		for(Unit_Make__c make : makeList) {
			makeNameToMakeIdMap.put(make.Name, make.Id);
		}
        Map<String, Unit_Make__c> makeNameToRecInsertMap = new Map<String, Unit_Make__c>();
        for(String makeName : makeNameToMakeIdMap.keySet()) {
        	if(String.isBlank(makeNameToMakeIdMap.get(makeName))) {
        		makeNameToRecInsertMap.put(makeName, new Unit_Make__c(Name = makeName));
        	}
        }
        //All make inserted
        if(makeNameToRecInsertMap.size() > 0) {
        	insert makeNameToRecInsertMap.values();
        }
        
        Set<String> modelNameSet = new Set<String>();
	    for(UnitOrderingWrapper.UnitOrderWrapper unit : orderedUnits) {
	     	if(makeNameToRecInsertMap.containsKey(unit.MakeName)) {
	     		unit.MakeId = makeNameToRecInsertMap.get(unit.MakeName).Id;
	     	} else {
	     		unit.MakeId = makeNameToMakeIdMap.get(unit.MakeName);
	     	}
	     	makeIdToModelNameToModelIdMap.put(unit.MakeId, new Map<String, String>{unit.ModelName => null});
	     	modelNameSet.add(unit.ModelName);
	    }
        
        List<Unit_Model__c> modelList = [Select Name__c, Unit_Make__c from Unit_Model__c where Name__c IN: modelNameSet];
        
        for(Unit_Model__c model : modelList) {
        	if(makeIdToModelNameToModelIdMap.containsKey(model.Unit_Make__c)) {
        		makeIdToModelNameToModelIdMap.get(model.Unit_Make__c).put(model.Name__c, model.Id);
        	}
		}
		
		Map<String, Map<String , Unit_Model__c>> makeIdTomodelNameToUnitModelInsertMap = new Map<String, Map<String , Unit_Model__c>>();
        List<Unit_Model__c> modelToInsertList = new List<Unit_Model__c>();
        
        for(String makeId : makeIdToModelNameToModelIdMap.keySet()) {
        	for(String modelName : makeIdToModelNameToModelIdMap.get(makeId).keySet()) {
        		if(String.isBlank(makeIdToModelNameToModelIdMap.get(makeId).get(modelName))) {
        			modelToInsertList.add( new Unit_Model__c(Name__c = modelName, Unit_Make__c = makeId));
        		}
	        }
        }
        
        //Inserted all models
        if(modelToInsertList.size() > 0) {
        	insert modelToInsertList;
        }
        
        for(Unit_Model__c unitModel : modelToInsertList) {
        	if(makeIdToModelNameToModelIdMap.containsKey(unitModel.Unit_Make__c) && String.isBlank(makeIdToModelNameToModelIdMap.get(unitModel.Unit_Make__c).get(unitModel.Name__c))) {
        		makeIdToModelNameToModelIdMap.get(unitModel.Unit_Make__c).put(unitModel.Name__c, unitModel.Id);
        	}
        }
        
        //Set all model ids
        for(UnitOrderingWrapper.UnitOrderWrapper unit : orderedUnits) {
	     	if(String.isBlank(unit.ModelId) && makeIdToModelNameToModelIdMap.containsKey(unit.MakeId) && (makeIdToModelNameToModelIdMap.get(unit.MakeId)).containsKey(unit.ModelName)) {
	     		unit.ModelId = makeIdToModelNameToModelIdMap.get(unit.MakeId).get(unit.ModelName);
	     	}
	     	subModelNameToUnitMap.put(unit.SubModelName, unit);
	    }
	    
	    List<Unit_Sub_Model__c> subModelList = [Select Sub_Model_Name__c, Unit_Model__c from Unit_Sub_Model__c where Sub_Model_Name__c IN: subModelNameToUnitMap.keySet()];
	    Map<String, String> subModelNameToSubModelIdMap = new Map<String, String>();
	    Map<String, String> subModelNameToModelIdMap = new Map<String, String>();
	    for(Unit_Sub_Model__c subModel : subModelList) {
			subModelNameToSubModelIdMap.put(subModel.Sub_Model_Name__c ,subModel.Id);
			subModelNameToModelIdMap.put(subModel.Sub_Model_Name__c, subModel.Unit_Model__c);
		}
		Map<String, Unit_Sub_Model__c> subModelNameToUnitSubModelInsertMap = new Map<String, Unit_Sub_Model__c>();
		for(String subModelName : subModelNameToUnitMap.keySet()) {
        	if(subModelNameToSubModelIdMap.containsKey(subModelName) &&  subModelNameToUnitMap.get(subModelName).ModelId == subModelNameToModelIdMap.get(subModelName)) {
        		subModelNameToUnitMap.get(subModelName).SubModelId = subModelNameToSubModelIdMap.get(subModelName);
        	} else {
        		subModelNameToUnitSubModelInsertMap.put(subModelName, new Unit_Sub_Model__c(Sub_Model_Name__c = subModelName, Unit_Model__c = subModelNameToUnitMap.get(subModelName).ModelId));
        	}
        }
        if(subModelNameToUnitSubModelInsertMap.size() > 0) {
        	insert subModelNameToUnitSubModelInsertMap.values();
        }
        for(UnitOrderingWrapper.UnitOrderWrapper unit : orderedUnits) {
	     	if(subModelNameToUnitSubModelInsertMap.containsKey(unit.SubModelName)) {
	     		unit.SubModelId = subModelNameToUnitSubModelInsertMap.get(unit.SubModelName).Id;
	     	} else {
	     		unit.SubModelId = subModelNameToUnitMap.get(unit.SubModelName).SubModelId;
	     	}
	    }
        return orderedUnits;
    }
    
    private static void updateDealItems(List<Unit_Price_Cost__c> skuPriceCostItems, List<Unit_Price_Cost__c> unitPriceCostItemsOfOrderedUnits,List<Customer_Owned_Unit__c> ordUnitList, Map<String, Customer_Owned_Unit__c> receivedUnitIdToStockUnitsMap) {
    	List<Deal_Item__c> dealItemListToUpdate = new List<Deal_Item__c>();
        for(Customer_Owned_Unit__c ordUnit : ordUnitList) {
        	if(ordUnit.Deals_Units_Junction__r.size() > 0 && receivedUnitIdToStockUnitsMap.containsKey(ordUnit.Id) ) {
            	Deal_Item__c dealItemRec = new Deal_Item__c(Id = ordUnit.Deals_Units_Junction__r[0].Id, Customer_Owned_Unit__c = receivedUnitIdToStockUnitsMap.get(ordUnit.Id).Id);
            	dealItemListToUpdate.add(dealItemRec);
            }
        }
        
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(dealItemListToUpdate.size() > 0) {
        	update dealItemListToUpdate;
        }
        updateUnitCostAndPrice(dealItemListToUpdate);
    }
    
    private static void updateUnitCostAndPrice(List<Deal_Item__c> dealItemRecList) {
		if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsAccessible('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		if(AccessControl.ifObjectFieldIsAccessible('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		
        List<Deal_Unit_Price_Cost__c> dealUnitPriceCostList = [Select Id, Name, Unit_Price_Cost__c from Deal_Unit_Price_Cost__c where Deal_Item__c IN: dealItemRecList];
        Set<Id> unitCostPriceIdSet = new Set<Id>();
    	for(Deal_Unit_Price_Cost__c dupc : dealUnitPriceCostList) {
    		if(String.isNotBlank(dupc.Unit_Price_Cost__c)) {
    			unitCostPriceIdSet.add(dupc.Unit_Price_Cost__c);
    		}
		}
        Map<Id, Unit_Price_Cost__c> unitPriceCostIdToRecMap = new Map<Id, Unit_Price_Cost__c>([Select Id, (Select Id from Unit_Prices_Costs__r) FROM Unit_Price_Cost__c where Id IN: unitCostPriceIdSet]);
        List<Deal_Unit_Price_Cost__c> dealUnitPriceCostUpdateList = new List<Deal_Unit_Price_Cost__c>();
		for(Deal_Unit_Price_Cost__c dupc : dealUnitPriceCostList) {
			if(dupc.Unit_Price_Cost__c != null && unitPriceCostIdToRecMap.containsKey(dupc.Unit_Price_Cost__c) && unitPriceCostIdToRecMap.get(dupc.Unit_Price_Cost__c).Unit_Prices_Costs__r.size() > 0) {
				dupc.Unit_Price_Cost__c = (unitPriceCostIdToRecMap.get(dupc.Unit_Price_Cost__c).Unit_Prices_Costs__r[0].Id);
				dealUnitPriceCostUpdateList.add(dupc);
			}
		}
		
        if(AccessControl.ifObjectFieldIsUpdateable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(dealUnitPriceCostUpdateList.size() > 0) {
        	update dealUnitPriceCostUpdateList;
        }
    }
    
    public static void updateDealServiceUnits(Map<String, Customer_Owned_Unit__c> orduIdToSkUnitMap) {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Header__c> soHeaderList = [Select Customer_Owned_Unit__c from Service_Order_Header__c where Customer_Owned_Unit__c IN: orduIdToSkUnitMap.keySet()];
    	
		for(Service_Order_Header__c soHeaderRec : soHeaderList) {
			if(orduIdToSkUnitMap.containsKey(soHeaderRec.Customer_Owned_Unit__c)) {
				soHeaderRec.Customer_Owned_Unit__c = orduIdToSkUnitMap.get(soHeaderRec.Customer_Owned_Unit__c).Id; 
			}
		}
		
		if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		if(soHeaderList.size() > 0 ) {
			update soHeaderList;
		}
    }
    
    public static String checkDuplicateVIN(String vin) {
        if(String.isNotBlank(vin)) {
            List<Customer_Owned_Unit__c> similarVINUnitList = SOQLUtil.getSimilarCOUs(vin);
            if(similarVINUnitList.size() > 0) {
                return '{"HasError" : true, "ErrorMessage" : "Duplicate VIN Number"}';
            }
            return 'SUCCESS';
        }
        return '{"HasError" : true, "ErrorMessage" : "VIN Number is required"}';
    }
}