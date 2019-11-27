public with sharing class DP360IntegrationCtrl {
    
    //Single Deal Update
    public static String upsertLead(List<String> dealIdList) {
    	Map<Id, SObject> dealIdToDealRecMap = SOQLUtil.getOpenDealByDealId(new Map<String, List<String>>{'Id' => dealIdList}, true);
        String dealerId = GeneralConfiguration.getDP360DealerId();
        if(dealIdToDealRecMap.size() > 0) {
            List<Deal__c> dealListToUpdate = new List<Deal__c>();
            List<CreateLeadWrapper> leadObjList = new List<CreateLeadWrapper>();
            for(Deal__c dealRec : (List<Deal__c>) dealIdToDealRecMap.values()) {
                List<Customer_Owned_Unit__c> unitRecs = new List<Customer_Owned_Unit__c>();
                List<Customer_Owned_Unit__c> tradeIns = new List<Customer_Owned_Unit__c>();
                for(Deal_Item__c dealItemRec : dealRec.Deal_Items__r) {
                    if(dealItemRec.Type__c == 'Unit') {
                        unitRecs.add((Customer_Owned_Unit__c)dealItemRec.getSObject('Customer_Owned_Unit__r'));
                    } else if(dealItemRec.Type__c == 'Trade In') {
                        tradeIns.add((Customer_Owned_Unit__c)dealItemRec.getSObject('Customer_Owned_Unit__r'));
	                }
	            }
                CreateLeadWrapper leadObj = new CreateLeadWrapper(dealerId, dealRec.Id, dealRec.DP360_Lead_Id__c, dealRec.CO_Header__r.Customer__r, unitRecs, tradeIns);
                leadObjList.add(leadObj);
            }
            for(CreateLeadWrapper leadObj : leadObjList) {
                String leadId = saveLead(leadObj);
                dealListToUpdate.add(new Deal__c(Id = leadObj.dealer_deal_id, DP360_Lead_Id__c = leadId));
            }
            update dealListToUpdate;
        }
        return 'Success';
    } 
    
    @future(callout=true)
    public static void upsertInventoryInDP360(Set<Id> unitIdSet) {
    	List<Customer_Owned_Unit__c> unitList;
    	if(unitIdSet != null) {
    		unitList = SOQLUtil.getStockUnitDetails(unitIdSet, false);
    	} else {
    		unitList = SOQLUtil.getStockUnitDetails(null, true);
    	}
        String dealerId = GeneralConfiguration.getDP360DealerId();
        Map<Integer, List<DP360InventoryWrapper>> callCountToUpdateInventoryObjListMap = new Map<Integer, List<DP360InventoryWrapper>>();
        Map<Integer, List<DP360InventoryWrapper>> callCountToCreateInventoryObjListMap = new Map<Integer, List<DP360InventoryWrapper>>();
        List<DP360InventoryWrapper> createInventoryObjList = new List<DP360InventoryWrapper>();
        List<DP360InventoryWrapper> updateInventoryObjList = new List<DP360InventoryWrapper>();
        
        Map<String, String> vinNumberToUnitIdMap = new Map<String, String>();
        for(Customer_Owned_Unit__c unitRec : unitList) {
            DP360InventoryWrapper invObj = new DP360InventoryWrapper(unitRec);
            if(invObj.id != null) {
            	if(callCountToUpdateInventoryObjListMap.size() > 0) {
            		Integer lastKey = (new List<Integer>(callCountToUpdateInventoryObjListMap.keySet()))[callCountToUpdateInventoryObjListMap.size() - 1];
            		if(callCountToUpdateInventoryObjListMap.get(lastKey).size() == 100) {
	            		callCountToUpdateInventoryObjListMap.put(lastKey + 1, new List<DP360InventoryWrapper>{invObj});
	            	} else {
	            		callCountToUpdateInventoryObjListMap.get(lastKey).add(invObj);
	            	}
            	} else {
            		callCountToUpdateInventoryObjListMap.put(1, new List<DP360InventoryWrapper>{invObj});
            	}
                //updateInventoryObjList.add(invObj);
            } else {
            	if(callCountToCreateInventoryObjListMap.size() > 0) {
            		Integer lastKey = (new List<Integer>(callCountToCreateInventoryObjListMap.keySet()))[callCountToCreateInventoryObjListMap.size() - 1];
            		if(callCountToCreateInventoryObjListMap.get(lastKey).size() == 100) {
	            		callCountToCreateInventoryObjListMap.put(lastKey + 1, new List<DP360InventoryWrapper>{invObj});
	            	} else {
	            		callCountToCreateInventoryObjListMap.get(lastKey).add(invObj);
	            	}
            	} else {
            		callCountToCreateInventoryObjListMap.put(1, new List<DP360InventoryWrapper>{invObj});
            	}
                //createInventoryObjList.add(invObj);
                vinNumberToUnitIdMap.put(unitRec.Vin_Number__c, unitRec.Id);
            }
        }
        String response;
        if(callCountToUpdateInventoryObjListMap.size() > 0) {
    		for(Integer key : callCountToUpdateInventoryObjListMap.keySet()) {
    			response = DP360Integration.updateInventory(callCountToUpdateInventoryObjListMap.get(key));
    		}
        }
        if(callCountToCreateInventoryObjListMap.size() > 0) {
        	List<Customer_Owned_Unit__c> skuList = new List<Customer_Owned_Unit__c>();
        	for(Integer callCount : callCountToCreateInventoryObjListMap.keySet()) {
    			response = DP360Integration.createInventory(callCountToCreateInventoryObjListMap.get(callCount));
    			
    			if(response != null) {
					Map<String, Object> b = (Map<String, Object>) JSON.deserializeUntyped(response);
					Map<String, Object> c = (Map<String, Object>) JSON.deserializeUntyped(system.Json.serialize(b.get('data')));
					
					Map<String, Object>  d = (Map<String, Object>) JSON.deserializeUntyped(system.Json.serialize(c.get('AddedVins')));
					for(String key : d.keySet()) {
						skuList.add(new Customer_Owned_Unit__c(Id = vinNumberToUnitIdMap.get(String.valueOf(d.get(key))), DP360_Inventory_Id__c = key));
					}
	            }
    		}
    		if(skuList.size() > 0) {
    			update skuList;
    		}
        }
    }
    
    //To be called from global sync
    @future(callout=true)
    public static void upsertLeadInDP360(List<Id> recIdList) {
    	List<String> dealIdList = (List<String>) recIdList;
        upsertLead(dealIdList);
    }
    
    @future(callout=true)
    public static void createInventoryInBlackpurl() {
    	String response = DP360Integration.searchInventory(GeneralConfiguration.getDP360DealerId(), null);
    	if(response != null) {
    		Map<String, Object> b = (Map<String, Object>) JSON.deserializeUntyped(response);
    		//system.assert(false, system.Json.serialize(b.get('data')));
        	List<DP360InventoryWrapper> invObjList = (List<DP360InventoryWrapper>) System.JSON.deserialize(system.Json.serialize(b.get('data')), List<DP360InventoryWrapper>.class);
        	createStockUnitInBP(invObjList);
        }
    }
    
    private static void createStockUnitInBP(List<DP360InventoryWrapper> invObjList) {
        Set<String> vinNumberSet = new Set<String>();
        Set<String> makeSet = new Set<String>();
        Set<String> modelSet = new Set<String>();
        
        for(DP360InventoryWrapper invObj : invObjList) {
            if(invObj.vin != null) {
                vinNumberSet.add(invObj.vin);
            }
            if(invObj.make != null) {
                makeSet.add(invObj.make);
            }
            if(invObj.model != null) {
                modelSet.add(invObj.model);
            }
        }
        
        Map<String, Customer_Owned_Unit__c> vinNumberToUnitRecMap = getVINNumberToUnitRecMap(vinNumberSet);
        Map<String, Unit_Make__c> makeNameToMakeRecMap = getMakeNameToMakeRecMap(makeSet);
        
        Map<String, Map<String, Unit_Model__c>> makeNameToModelNameToModelRecMap = new Map<String, Map<String, Unit_Model__c>>();
        for(String makeName : makeNameToMakeRecMap.keySet()) {
        	Map<String, Unit_Model__c> modelNameToRecMap = new Map<String, Unit_Model__c>();
        	for(Unit_Model__c modelRec : makeNameToMakeRecMap.get(makeName).Unit_Models__r) {
        		modelNameToRecMap.put(modelRec.Name__c, modelRec);
        	}
        	makeNameToModelNameToModelRecMap.put(makeName, modelNameToRecMap);
        }
		
		List<Unit_Make__c> makeListToInsert = new List<Unit_Make__c>();
		List<Unit_Model__c> modelListToInsert = new List<Unit_Model__c>();
		
		Map<Id, String> makeIdToMakeNameMap = new Map<Id, String>();
		
		for(DP360InventoryWrapper invObj : invObjList) {
			if(!vinNumberToUnitRecMap.containsKey(invObj.vin)) {
				if(String.isNotBlank(invObj.make) && makeNameToMakeRecMap.containsKey(invObj.make)) {
					makeIdToMakeNameMap.put(makeNameToMakeRecMap.get(invObj.make).Id, invObj.make);
					
	            	if(!makeNameToModelNameToModelRecMap.get(invObj.make).containsKey(invObj.model)) {
	            		Unit_Model__c modelRec = new Unit_Model__c(Name__c = invObj.model, Unit_Make__c = makeNameToMakeRecMap.get(invObj.make).Id);
			        	modelListToInsert.add(modelRec);
	            	}
	            } else {
	                //make and model not exists
		        	Unit_Make__c makeRec = new Unit_Make__c(Name = invObj.make);
		        	makeListToInsert.add(makeRec);
	            }
			}
		}
		
		insert makeListToInsert;
		insert modelListToInsert;
		for(Unit_Make__c makeRec : makeListToInsert) {
			makeNameToMakeRecMap.put(makeRec.Name, makeRec);
			makeNameToModelNameToModelRecMap.put(makeRec.Name, new Map<String, Unit_Model__c>());
			makeIdToMakeNameMap.put(makeRec.Id, makeRec.Name);
		}
		
		makeListToInsert = new List<Unit_Make__c>();
		
		for(Unit_Model__c modelRec : modelListToInsert) {
			if(makeIdToMakeNameMap.containsKey(modelRec.Unit_Make__c)) {
				String makeName = makeIdToMakeNameMap.get(modelRec.Unit_Make__c);
				makeNameToModelNameToModelRecMap.get(makeName).put(modelRec.Name__c, modelRec);
			}
		}
		modelListToInsert = new List<Unit_Model__c>();
		
		for(DP360InventoryWrapper invObj : invObjList) {
			if(!vinNumberToUnitRecMap.containsKey(invObj.vin)) {
				makeIdToMakeNameMap.put(makeNameToMakeRecMap.get(invObj.make).Id, invObj.make);
				
	        	if(!makeNameToModelNameToModelRecMap.get(invObj.make).containsKey(invObj.model)) {
	        		Unit_Model__c modelRec = new Unit_Model__c(Name__c = invObj.model, Unit_Make__c = makeNameToMakeRecMap.get(invObj.make).Id);
		        	modelListToInsert.add(modelRec);
	        	}
			}
		}
		
		insert modelListToInsert;
		
		for(Unit_Model__c modelRec : modelListToInsert) {
			if(makeIdToMakeNameMap.containsKey(modelRec.Unit_Make__c)) {
				String makeName = makeIdToMakeNameMap.get(modelRec.Unit_Make__c);
				makeNameToModelNameToModelRecMap.get(makeName).put(modelRec.Name__c, modelRec);
			}
		}
		modelListToInsert = new List<Unit_Model__c>();
		
        List<Customer_Owned_Unit__c> skuListToUpsert = new List<Customer_Owned_Unit__c>();
        for(DP360InventoryWrapper invObj : invObjList) {
        	Customer_Owned_Unit__c skuRec = new Customer_Owned_Unit__c(Vin_Number__c = invObj.vin, DP360_Inventory_Id__c = invObj.Id, 
        		Unit_Type__c = 'STOCK', Status__c = 'Available');
            if(String.isNotBlank(invObj.vin) && vinNumberToUnitRecMap.containsKey(invObj.vin)) {
            	skuRec.Id = vinNumberToUnitRecMap.get(invObj.vin).Id;
            } else if(String.isNotBlank(invObj.make) && makeNameToMakeRecMap.containsKey(invObj.make)) {
            	skuRec.Unit_Make__c = makeNameToMakeRecMap.get(invObj.make).Id;
            	if(makeNameToModelNameToModelRecMap.containsKey(invObj.make) && makeNameToModelNameToModelRecMap.get(invObj.make).containsKey(invObj.model)) {
            		skuRec.Unit_Model__c = makeNameToModelNameToModelRecMap.get(invObj.make).get(invObj.model).Id;
            		//make and model both exists
            	}
            }
            skuListToUpsert.add(skuRec);
        }
        if(skuListToUpsert.size() > 0) {
        	if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        	upsert skuListToUpsert;
        }
    }
    
    public static String saveLead(CreateLeadWrapper saveLeadObj) {
        String response = DP360Integration.saveLead(saveLeadObj);
        
        if(response != null) {
            DP360Integration.DP360ResponseWrapper saveLeadResponse = (DP360Integration.DP360ResponseWrapper) System.JSON.deserialize(response, DP360Integration.DP360ResponseWrapper.class);
            if(saveLeadResponse.data.lead_id != null) {
                return String.valueOf(saveLeadResponse.data.lead_id);
            }
        }
        return null;
    }
    
    public static SearchLeadResultWrapper getLead(SearchLeadWrapper searchLeadObj) {
        String response = DP360Integration.searchLead(searchLeadObj);
        if(response != null) {
            SearchLeadResultWrapper searchLeadResponse = SearchLeadResultWrapper.parse(response);
            if(searchLeadResponse.code == 200) {
                return searchLeadResponse;
            }
        }
        return null;
    }
    
    public static String getLeadUrlByLeadId(String leadId) {
        String dealerId = GeneralConfiguration.getDP360DealerId();
        SearchLeadWrapper searchLeadObj = new SearchLeadWrapper(dealerId, null, leadId);
        SearchLeadResultWrapper searchLeadResponse = getLead(searchLeadObj);
        if(searchLeadResponse != null && searchLeadResponse.data != null && searchLeadResponse.data.size() > 0) {
            return searchLeadResponse.data[0].crm_lead_url;
        }
        return null;
    }
    
    public static void createLeadInBlackpurl() {
        String dealerId = GeneralConfiguration.getDP360DealerId(); // TODo - Create new class for dealer Id
        DateTime lastSyncDate = GeneralConfiguration.getDP360LastSynchedDate(); // TODo - Create new class
        SearchLeadWrapper searchLeadObj = new SearchLeadWrapper(dealerId, lastSyncDate, null);
        
        SearchLeadResultWrapper searchLeadResponse = getLead(searchLeadObj);
        
        if(searchLeadResponse != null && searchLeadResponse.data != null) {
        	createLeadInBP(searchLeadResponse.data);
        }
    }
    
    private static void createLeadInBP(List<SearchLeadResultWrapper.LeadWrapper> leadObjList) {
        if(leadObjList != null) {
            Map<String, SearchLeadResultWrapper.LeadWrapper> leadIdToLeadObjToInsertDealMap = new Map<String, SearchLeadResultWrapper.LeadWrapper>();
            //Lead Id to lead Obj map
            for(SearchLeadResultWrapper.LeadWrapper leadObj : leadObjList) {
                leadIdToLeadObjToInsertDealMap.put(String.valueOf(leadObj.id), leadObj);
            }
            
            Map<Id, SObject> dealIdToDealRecMap = new Map<Id, SObject>(SOQLUtil.getOpenDealByDealId(new Map<String, List<String>>{'DP360_Lead_Id__c' => new List<String>(leadIdToLeadObjToInsertDealMap.keySet())}, false));
            Map<String, SearchLeadResultWrapper.LeadWrapper> leadIdToLeadObjToUpdateDealMap = new Map<String, SearchLeadResultWrapper.LeadWrapper>();
            for(Id dealId : dealIdToDealRecMap.keySet()) {
            	Deal__c dealRec = (Deal__c) dealIdToDealRecMap.get(dealId);
                leadIdToLeadObjToUpdateDealMap.put(dealRec.DP360_Lead_Id__c, leadIdToLeadObjToInsertDealMap.get(dealRec.DP360_Lead_Id__c));
                leadIdToLeadObjToInsertDealMap.remove(dealRec.DP360_Lead_Id__c);
            }
            
            
            Map<String, SearchLeadResultWrapper.LeadWrapper> vinNumberToLeadRecMap = new Map<String,SearchLeadResultWrapper.LeadWrapper>();
            SearchLeadResultWrapper.LeadWrapper leadObject;
            Set<String> emailList = new Set<String>();
            for(String leadObjId : leadIdToLeadObjToInsertDealMap.keySet()) {
                leadObject = leadIdToLeadObjToInsertDealMap.get(leadObjId);
                vinNumberToLeadRecMap.put(leadObject.vin, leadObject);
                if(String.isNotBlank(leadObject.email)){emailList.add(leadObject.email);}
            }
            
            List<Deal__c> updateDealRecsList = new List<Deal__c>();
            Map<Id, SObject> dealItemIdToDealItemRecMap = new Map<Id, SObject>(SOQLUtil.getDealItemForCOU(new Map<String, List<String>>{'Customer_Owned_Unit__r.VIN_Number__c' => new List<String>(vinNumberToLeadRecMap.keySet()), 'Customer_Owned_Unit__r.Unit_Type__c' => new List<String>{'STOCK'}, 'Deal__r.CO_Header__r.Customer__r.Email__c' => new List<String>(emailList) }));
            for(String dealItemId : dealItemIdToDealItemRecMap.keySet()) {
                Deal_Item__c dealItemRec = (Deal_Item__c) dealItemIdToDealItemRecMap.get(dealItemId);
                leadObject = vinNumberToLeadRecMap.get(dealItemRec.Customer_Owned_Unit__r.VIN_Number__c);
                if(leadObject!= null && (dealItemRec.Customer_Owned_Unit__r.VIN_Number__c)!= null && (dealItemRec.Customer_Owned_Unit__r.VIN_Number__c).equalsIgnoreCase(leadObject.vin) && (dealItemRec.Deal__r.CO_Header__r.Customer__r.Email__c)!= null && (dealItemRec.Deal__r.CO_Header__r.Customer__r.Email__c).equalsIgnoreCase(leadObject.email)) {
                    updateDealRecsList.add(new Deal__c (Id = dealItemRec.Deal__c, DP360_Lead_Id__c = String.valueOf(leadObject.id)));
                    leadIdToLeadObjToInsertDealMap.remove(String.valueOf(leadObject.id));
                }
            }
            upsert updateDealRecsList;
            
            //Update Deal
            upsertLeadInDP360(new List<Id>(dealIdToDealRecMap.keySet()));
            
            createNewDeals(leadIdToLeadObjToInsertDealMap);
        }
    }
	
    private static void createNewDeals(Map<String, SearchLeadResultWrapper.LeadWrapper> leadIdToLeadObjMap) {
        //Create Customer or unit if not exists
        Map<String, Customer_Owned_Unit__c> vinNumberToUnitRecMap = createCustomerAndUnit(leadIdToLeadObjMap);
        
        //Create New CO
        Map<String, CO_Header__c> leadIdToRelatedCOHeaderRecMap = new Map<String, CO_Header__c>();
        for(String leadId : leadIdToLeadObjMap.keySet()) {
            leadIdToRelatedCOHeaderRecMap.put(leadId, getCORecByLeadObj(leadIdToLeadObjMap.get(leadId).dealervu_customer_id));
        }
        insert leadIdToRelatedCOHeaderRecMap.values();
        
        //Create New Deal
        Map<String, Deal__c> leadIdToRelatedDealRecMap = new Map<String, Deal__c>();
        for(String leadId : leadIdToLeadObjMap.keySet()) {
            leadIdToRelatedDealRecMap.put(leadId, getDealRecByLeadObj(leadId, leadIdToRelatedCOHeaderRecMap.get(leadId).Id));
        }
        insert leadIdToRelatedDealRecMap.values();
        
        //Create Deal Item with dealervu_inventory_id
        Map<String, Deal_Item__c> leadIdToRelatedDealItemRecMap = new Map<String, Deal_Item__c>();
        for(String leadId : leadIdToLeadObjMap.keySet()) {
            leadIdToRelatedDealItemRecMap.put(leadId, getDealItemRecByLeadObj(leadIdToLeadObjMap.get(leadId), leadIdToRelatedDealRecMap.get(leadId).Id));
        }
        if(AccessControl.ifObjectFieldIsCreateable('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        disabletrigger('DealItemTrigger', true);
        insert leadIdToRelatedDealItemRecMap.values();
        disabletrigger('DealItemTrigger', false);
        
        Set<Id> dealItemIdSet = new Set<Id>();
        for(Deal_Item__c dealItemRec : leadIdToRelatedDealItemRecMap.values()) {
            dealItemIdSet.add(dealItemRec.Id);
        }
        //Create Linked fees and deal unit price and cost
        createDealItemRelatedRecords(dealItemIdSet);
        // Create Activity History in case of Insert.
        
        //system.assert(false, 'Nidhi');
        
        if(!Test.isRunningTest()) {
            for(String leadId : leadIdToRelatedCOHeaderRecMap.keySet()) {
                Id coHeaderId = leadIdToRelatedCOHeaderRecMap.get(leadId).Id;
                Id customerId = leadIdToRelatedCOHeaderRecMap.get(leadId).Customer__c;
                ActivityHistory.createActivityHistory('DP360 Deal Create', 'Customer Order', coHeaderId, 'Customer', customerId, coHeaderId);
            }
        } 
        
        /*
        //Update DealerVu_Deal_Id in DP360
        List<String> dealIdList = new List<String>();
        for(Deal__c dealRec : leadIdToRelatedDealRecMap.values()) {
            dealIdList.add(dealRec.Id);
        }
        upsertLeadInDP360(dealIdList);*/
    }
    
    
    @future
    private static void createDealItemRelatedRecords(Set<Id> dealItemIdSet) {
        //Get Customer_Owned_Unit and deal Id
        List<Deal_Item__c> dealItemRecList = [Select Id, Deal__c, Customer_Owned_Unit__c from Deal_Item__c where Id In : dealItemIdSet];
        
        Set<String> unitIdSet = new Set<String>();
        for(Deal_Item__c dealItemRec : dealItemRecList) {
            if(String.isNotBlank(dealItemRec.Customer_Owned_Unit__c)) {
                unitIdSet.add(dealItemRec.Customer_Owned_Unit__c);
            }
        }
        
        Map<String, Customer_Owned_Unit__c> unitIdToUnitRecMap = new Map<String, Customer_Owned_Unit__c>([Select Id, VIN_Number__c, Unit_Type__c, 
            (Select Id, Type__c, Ref_No__c, Item_Description__c, Qty__c, Price__c,Total_Price__c,Total_Cost__c,Profit_Amount__c,Profit_Percentage__c,Customer_Owned_Unit__c,
            CO_Invoice_Header__c,CO_Invoice_Header__r.Invoice_Number__c,CO_Invoice_Header__r.CO_Header__c from Unit_Prices_Costs__r ORDER BY Type__c ASC) from Customer_Owned_Unit__c where Id In : unitIdSet]);
            
        List<SObject> sObjectListToInsert = new List<SObject>();
        for(Deal_Item__c dealItemRec : dealItemRecList) {
        	if(String.isNotBlank(dealItemRec.Customer_Owned_Unit__c)) {
	            List<SObject> linkedFeeList = CustomerOrderCtrl.addLinkedFee(dealItemRec.Id, dealItemRec.Deal__c, 'Deal');
	            if(linkedFeeList != null) {
	                sObjectListToInsert.addAll(linkedFeeList);
	            }
	            
                Map<String, List<Deal_Unit_Price_Cost__c>> DealUnitPriceCostMap = new Map<String, List<Deal_Unit_Price_Cost__c>>();
                for(Unit_Price_Cost__c UnitPriceRec : unitIdToUnitRecMap.get(dealItemRec.Customer_Owned_Unit__c).Unit_Prices_Costs__r){
                    if(UnitPriceRec.Type__c != 'Base' || !DealUnitPriceCostMap.containsKey('Base')) {
                        Deal_Unit_Price_Cost__c DealUnitPriceCostItem = new Deal_Unit_Price_Cost__c();
                        DealUnitPriceCostItem.Item_Description__c = UnitPriceRec.Item_Description__c;
                        DealUnitPriceCostItem.Price__c = UnitPriceRec.Price__c;
                        DealUnitPriceCostItem.Type__c= UnitPriceRec.Type__c;
                        if(DealUnitPriceCostItem.Type__c == 'Dealer') {
                            DealUnitPriceCostItem.Qty__c= UnitPriceRec.Qty__c;
                        }else {
                            DealUnitPriceCostItem.Qty__c = 1;
                        }
                        
                        if(DealUnitPriceCostItem.Type__c == 'Factory' || DealUnitPriceCostItem.Type__c == 'Base') {
                            DealUnitPriceCostItem.Price__c = (UnitPriceRec.Total_Price__c != null ? UnitPriceRec.Total_Price__c : 0);
                        }
                        DealUnitPriceCostItem.Deal_Item__c =  dealItemRec.Id;
                        DealUnitPriceCostItem.Unit_Price_Cost__c = UnitPriceRec.Id;
                        if(!DealUnitPriceCostMap.containsKey(DealUnitPriceCostItem.Type__c)) {
                            DealUnitPriceCostMap.put(DealUnitPriceCostItem.Type__c, new List<Deal_Unit_Price_Cost__c>{DealUnitPriceCostItem});
                        } else {
                            DealUnitPriceCostMap.get(DealUnitPriceCostItem.Type__c).add(DealUnitPriceCostItem);
                        }
                    } else {
                        DealUnitPriceCostMap.get('Base')[0].Price__c += (UnitPriceRec.Total_Price__c != null ? UnitPriceRec.Total_Price__c : 0);
                    }
                }
                for(String unitPriceAndCostType : DealUnitPriceCostMap.keySet()) {
                    sObjectListToInsert.addAll((List<SObject>) DealUnitPriceCostMap.get(unitPriceAndCostType));
                }
            }
        }
        
        if(AccessControl.ifObjectFieldIsCreateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Deal_Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert sObjectListToInsert;
        
    }
    
    private static void disableTrigger(String triggerName, Boolean isEnable) {
        List<Trigger_Soft_Disable__c> triggerSoFtDisableConfig = [Select Id from Trigger_Soft_Disable__c where Name =: triggerName];
        if(triggerSoFtDisableConfig.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Trigger_Soft_Disable__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete triggerSoFtDisableConfig ;
        }
        
        Trigger_Soft_Disable__c triggerSoftDisable = new Trigger_Soft_Disable__c(Name = triggerName);
        triggerSoftDisable.Disable_Insert__c = isEnable;
        triggerSoftDisable.Disable_Update__c = isEnable;
        triggerSoftDisable.Disable_Delete__c = isEnable;
        triggerSoftDisable.Disable_Undelete__c = isEnable;
        insert triggerSoftDisable;
    }
     private static Map<String, Customer_Owned_Unit__c> createCustomerAndUnit(Map<String, SearchLeadResultWrapper.LeadWrapper> leadIdToLeadObjMap) {
        //Create Customer or unit if not exists
        List<String> emailList = new List<String>();
        Set<String> vinNumberSet = new Set<String>();
        
        Set<String> makeSet = new Set<String>();
        List<String> modelList = new List<String>();
        for(String leadId : leadIdToLeadObjMap.keySet()) {
            if(String.isNotBlank(leadIdToLeadObjMap.get(leadId).email)) {
                emailList.add(leadIdToLeadObjMap.get(leadId).email);
            }
            if(leadIdToLeadObjMap.get(leadId).vin != null) {
                vinNumberSet.add(leadIdToLeadObjMap.get(leadId).vin);
            }
            if(leadIdToLeadObjMap.get(leadId).make != null) {
                makeSet.add(leadIdToLeadObjMap.get(leadId).make);
            }
            if(leadIdToLeadObjMap.get(leadId).model != null) {
                modelList.add(leadIdToLeadObjMap.get(leadId).model);
            }
        }
        
        Map<String, Customer_Owned_Unit__c> vinNumberToUnitRecMap = getVINNumberToUnitRecMap(vinNumberSet);
        Map<String, String> emailToCustIdMap = getEmailToCustIdMap(emailList);
        Map<String, Unit_Make__c> makeNameToMakeRecMap = getMakeNameToMakeRecMap(makeSet);
         
        /*Map<String, Account> leadIdToCustRecMapToInsert = new Map<String, Account>();
        Map<String, Customer_Owned_Unit__c> leadIdToUnitRecMapToInsert = new Map<String, Customer_Owned_Unit__c>();
        Map<String, Customer_Owned_Unit__c> leadIdToMakeRecMapToInsert = new Map<String, Customer_Owned_Unit__c>();*/
        
        for(String leadId : leadIdToLeadObjMap.keySet()) {
            // Customer
            if(String.isNotBlank(leadIdToLeadObjMap.get(leadId).email) && emailToCustIdMap.containsKey(leadIdToLeadObjMap.get(leadId).email)) {
                SearchLeadResultWrapper.LeadWrapper leadObj = leadIdToLeadObjMap.get(leadId);
                leadObj.dealervu_customer_id = emailToCustIdMap.get(leadIdToLeadObjMap.get(leadId).email);
                leadIdToLeadObjMap.put(leadId, leadObj);
            } else {
                //leadIdToCustRecMapToInsert.put(leadId, getCustomerRecByLeadObj(leadIdToLeadObjMap.get(leadId)));
            }
            
            // Make
            if(String.isNotBlank(leadIdToLeadObjMap.get(leadId).make) && makeNameToMakeRecMap.containsKey(leadIdToLeadObjMap.get(leadId).make)) {
                SearchLeadResultWrapper.LeadWrapper leadObj = leadIdToLeadObjMap.get(leadId);
                leadObj.makeId = makeNameToMakeRecMap.get(leadIdToLeadObjMap.get(leadId).make).Id;
                leadIdToLeadObjMap.put(leadId, leadObj);
                
                for(Unit_Model__c modelRec : (makeNameToMakeRecMap.get(leadIdToLeadObjMap.get(leadId).make)).Unit_Models__r) {
                    if(leadIdToLeadObjMap.get(leadId).model == modelRec.Name__c) {
                        leadIdToLeadObjMap.get(leadId).modelId = modelRec.Id;
                        break;
                    }
                }
                
                /*if(String.isBlank(leadIdToLeadObjMap.get(leadId).modelId)) {
                    //Create Model
                }*/
            } else {
                //Create Make and related model
            }
            
            //Unit
            if(String.isNotBlank(leadIdToLeadObjMap.get(leadId).vin) && vinNumberToUnitRecMap.containsKey(leadIdToLeadObjMap.get(leadId).vin)) {
                SearchLeadResultWrapper.LeadWrapper leadObj = leadIdToLeadObjMap.get(leadId);
                leadObj.dealervu_inventory_id = vinNumberToUnitRecMap.get(leadIdToLeadObjMap.get(leadId).vin).Id;
                leadIdToLeadObjMap.put(leadId, leadObj);
            } else {
                //leadIdToUnitRecMapToInsert.put(leadId, getUnitRecByLeadObj(leadIdToLeadObjMap.get(leadId)));
            }
        }
        return vinNumberToUnitRecMap;
        /*insert leadIdToCustRecMapToInsert.values();
        insert leadIdToUnitRecMapToInsert.values();
        
        for(String leadId : leadIdToLeadObjMap.keySet()) {
            if(String.isBlank(leadIdToLeadObjMap.get(leadId).dealervu_customer_id) || String.isBlank(leadIdToLeadObjMap.get(leadId).dealervu_inventory_id)) {
                SearchLeadResultWrapper.LeadWrapper leadObj = leadIdToLeadObjMap.get(leadId);
                if(leadIdToCustRecMapToInsert.containsKey(leadId)) {
                    leadObj.dealervu_customer_id = leadIdToCustRecMapToInsert.get(leadId).Id;
                }
                if(leadIdToUnitRecMapToInsert.containsKey(leadId)) {
                    leadObj.dealervu_inventory_id = leadIdToUnitRecMapToInsert.get(leadId).Id;
                }
            }
        }*/
        
     }
    
    private static Map<String, Customer_Owned_Unit__c> getVINNumberToUnitRecMap(Set<String> vinNumberSet) {
        Map<String, Customer_Owned_Unit__c> unitIdToUnitRecMap = new Map<String, Customer_Owned_Unit__c>([Select Id, VIN_Number__c, Unit_Type__c from Customer_Owned_Unit__c where Unit_Type__c = 'STOCK' AND VIN_Number__c IN : vinNumberSet]);
        Map<String, Customer_Owned_Unit__c> vinNumberToUnitRecMap = new Map<String, Customer_Owned_Unit__c>();
        for(String unitId : unitIdToUnitRecMap.keySet()) {
            if(String.isNotBlank(unitIdToUnitRecMap.get(unitId).VIN_Number__c)) {
                vinNumberToUnitRecMap.put(unitIdToUnitRecMap.get(unitId).VIN_Number__c, unitIdToUnitRecMap.get(unitId));
            }
        }
        return vinNumberToUnitRecMap;
    }
    
    private static Map<String, String> getEmailToCustIdMap(List<String> emailList) {
        Map<String, Account> accIdToAccRecMap = new Map<String, Account>([Select Id, Email__c, Preferred_Email__c, Other_Email__c from Account where Is_Customer__c = true AND (Email__c IN :emailList OR Preferred_Email__c IN :emailList OR Other_Email__c IN :emailList)]);
        Map<String, String> emailToCustIdMap = new Map<String, String>();
        for(String accId : accIdToAccRecMap.keySet()) {
            if(String.isNotBlank(accIdToAccRecMap.get(accId).Preferred_Email__c)) {
                emailToCustIdMap.put(accIdToAccRecMap.get(accId).Preferred_Email__c, accId);
            }
            if(String.isNotBlank(accIdToAccRecMap.get(accId).Email__c) && (String.isBlank(accIdToAccRecMap.get(accId).Preferred_Email__c) || accIdToAccRecMap.get(accId).Preferred_Email__c != accIdToAccRecMap.get(accId).Email__c)) {
                emailToCustIdMap.put(accIdToAccRecMap.get(accId).Email__c, accId);
            }
            if(String.isNotBlank(accIdToAccRecMap.get(accId).Other_Email__c) && ((String.isBlank(accIdToAccRecMap.get(accId).Preferred_Email__c) || accIdToAccRecMap.get(accId).Preferred_Email__c != accIdToAccRecMap.get(accId).Other_Email__c) && 
                (String.isBlank(accIdToAccRecMap.get(accId).Email__c) || accIdToAccRecMap.get(accId).Email__c != accIdToAccRecMap.get(accId).Other_Email__c))) {
                emailToCustIdMap.put(accIdToAccRecMap.get(accId).Other_Email__c, accId);
            }
        }
        return emailToCustIdMap;
    }
    
    private static Map<String, Unit_Make__c> getMakeNameToMakeRecMap(Set<String> makeNameSet) {
        List<Unit_Make__c> makeList = new List<Unit_Make__c>((List<Unit_Make__c>) SOQLUtil.getUnitMakeWrapper());
        Map<String, Unit_Make__c> makeNameToMakeRecMap = new Map<String, Unit_Make__c>();
        for(Unit_make__c makeRec : makeList) {
            if(String.isNotBlank(makeRec.Name)) {
                makeNameToMakeRecMap.put(makeRec.Name, makeRec);
            }
        }
        return makeNameToMakeRecMap;
    }
    
    private static Account getCustomerRecByLeadObj(SearchLeadResultWrapper.LeadWrapper leadObj) {
        Account customerRec = new Account();
        //DP360_Lead_Id__c = String.valueOf(leadObj.id)
        customerRec.FirstName__c = leadObj.first_name;
        customerRec.LastName__c = leadObj.last_name;
        customerRec.Name = customerRec.FirstName__c + ' ' + customerRec.LastName__c;
        
        customerRec.Home_number__c = leadObj.phone;
        customerRec.Work_Number__c = leadObj.work_number;
        customerRec.Mobile__c = leadObj.mobile;
        customerRec.Email__c = leadObj.email;
        
        customerRec.BillingStreet = leadObj.address;
        customerRec.BillingCity = leadObj.city;
        customerRec.BillingState = leadObj.state;
        //customerRec.BillingCountry = leadObj.country;
        customerRec.BillingPostalCode = leadObj.zip;
        return customerRec;
    }
    
    private static CO_Header__c getCORecByLeadObj(String custId) {
        CO_Header__c coRec = new CO_Header__c();
        coRec.CO_Type__c = 'Customer';
        coRec.Customer__c = custId;
        coRec.Selling_Group__c = 'Unit Deal';
        coRec.Order_status__c = 'Open';
        coRec.Hide_Merchandise_Section__c = true;
        coRec.Owner__c = UserInfo.getUserId();
        return coRec;
    }
    
    private static Deal__c getDealRecByLeadObj(String leadId, String coHeaderId) {
        Deal__c dealRec = new Deal__c();
        dealRec.CO_Header__c = coHeaderId;
        dealRec.Status__c = 'Quotation';
        dealRec.Type__c = 'Cash Deal';
        dealRec.Unit_Status__c = 'Temporary';
        dealRec.DP360_Lead_Id__c = leadId;
        return dealRec;
    }
    
     private static Deal_Item__c getDealItemRecByLeadObj(SearchLeadResultWrapper.LeadWrapper leadObj, String dealId) {
        Deal_Item__c dealItemRec = new Deal_Item__c();
    	dealItemRec.Customer_Owned_Unit__c = leadObj.dealervu_inventory_id;
        dealItemRec.Deal__c = dealId;
        dealItemRec.Type__c = Constants.DEAL_ITEM_TYPE_UNIT;
        dealItemRec.Option_And_Fee_Status__c = Constants.UNCOMIITTED;
        dealItemRec.Name__c = 'Unit 1'; 
        return dealItemRec;
    }
    
    private static Customer_Owned_Unit__c getUnitRecByLeadObj(SearchLeadResultWrapper.LeadWrapper leadObj) {
        Customer_Owned_Unit__c unitRec = new Customer_Owned_Unit__c();
        //DP360_Inventory_Id__c = String.valueOf(leadObj.id)
        unitRec.Year__c = leadObj.year;
        unitRec.Unit_Make__c = leadObj.makeId;
        unitRec.Unit_Model__c = leadObj.modelId;
        unitRec.VIN_Number__c = leadObj.vin;
        unitRec.Unit_Type__c = 'STOCK';
        unitRec.Stock_Id__c = leadObj.stock_num;
        
        return unitRec;
    }
    
    public class SearchLeadWrapper {
    	public String dealerId {get; set;}
	   	public DateTime startDate {get; set;}
	   	public String lead_id {get; set;}
	   	
	   	public SearchLeadWrapper(String dealerId, DateTime startDate, String leadId) {
	   		this.dealerId = (dealerId != null) ? dealerId : '5000';
	    	this.startDate = startDate;
	    	this.lead_id = leadId;
	   	}
    }
}