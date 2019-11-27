public without sharing class IntegrationSyncFlagService {
																											
    /* Disable category syncing in Xero
    public static void manageCategorySyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Category__c> categoryNewList) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.ITEM_CATEGORY);
    	
        for(Category__c catRec : categoryNewList) {
        	if(catRec.QB_Updated_Fields__c != null && catRec.Id != null) {
        		catRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.ITEM_CATEGORY).Sync_Flag_API_Name__c, true);
        	} else if(catRec.Id == null && catRec.Active__c && catRec.Name != null && catRec.Type__c != null && catRec.Description__c != null && 
                (catRec.Income_GL__c != null || catRec.Inventory_GL__c != null || catRec.COGS_GL__c != null)) {
                catRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.ITEM_CATEGORY).Sync_Flag_API_Name__c, true);
            }
        }
    } */
    
    private static List<String> categoryFieldListToSync = new List<String> {
        'Active__c', 'Name', 'Type__c', 'Description__c', 'Income_GL__c', 'Inventory_GL__c', 'COGS_GL__c'
    };
    
    public static void setUpdatedFieldsForSparse(List<BaseIntegrationService> baseIntegrationServiceList, List<Sobject> newList, Map<Id, Sobject> oldMap) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.ITEM_CATEGORY);
    	
    	for(Sobject rec : newList) {
            String changedFieldsString = '';
            Sobject oldRec = oldMap.get(rec.Id);
            if(rec.get(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.ITEM_CATEGORY).Integration_Id_API_Name__c) != null) {
            	rec = updateSparseFieldForTheRecord(rec, oldRec, new Set<String>{'QB_Updated_Fields__c'}, categoryFieldListToSync);
        	}
        }
    }
    
    private static Sobject updateSparseFieldForTheRecord(SObject newRec, SObject oldRec, Set<String> updatedFieldsAPINameSet, List<String> fieldsToSyncList) {
        String changedFieldsString = '';
        for(String fieldName : fieldsToSyncList) {
            if(newRec.get(fieldName) != oldRec.get(fieldName)) {
                changedFieldsString += fieldName + ',';
            }
        }
        for(String updatedFieldsAPIName : updatedFieldsAPINameSet) {
            if(String.isNotBlank((String)newRec.get(updatedFieldsAPIName))) {
                newRec.put(updatedFieldsAPIName, newRec.get(updatedFieldsAPIName) + changedFieldsString);
            } else {
                newRec.put(updatedFieldsAPIName, changedFieldsString);
            }
        }
        return newRec;
    }
    
    public static void managePartFIFOBucketSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Part_FIFO_Bucket__c> newList) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.PART_FIFO);
    																	
        for(Part_FIFO_Bucket__c partFIFOBucketRec : newList) {
        	if(partFIFOBucketRec.Is_FIFO_Bucket__c && partFIFOBucketRec.Vendor_Receiving_Header__c == null && partFIFOBucketRec.Customer_Return__c == null && 
        		partFIFOBucketRec.Source_Name__c != QBUtil.PART_CREATED && partFIFOBucketRec.Source_Name__c != QBUtil.OVERSOLD) {
        			partFIFOBucketRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.PART_FIFO).Sync_Flag_API_Name__c, true);
        	}
        }
    }
    
    public static void managePartFIFOBucketLISyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Part_FIFO_Bucket_Activity_Line_Item__c> fifoActivityLIList) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM);
    																	
        Set<Id> fifoBucketIds = new Set<Id>();
        for(Part_FIFO_Bucket_Activity_Line_Item__c partFIFOBucketActivityLIRec : fifoActivityLIList) {
        	fifoBucketIds.add(partFIFOBucketActivityLIRec.Part_FIFO_Bucket__c);
        }
        if(fifoBucketIds.size() > 0) {
        	Map<Id, Part_FIFO_Bucket__c> fifoBucketIdToRecMap = 
        						new Map<Id, Part_FIFO_Bucket__c>([SELECT Id FROM Part_FIFO_Bucket__c WHERE Id IN :fifoBucketIds AND Is_FIFO_Bucket__c = true]);
        	
        	for(Part_FIFO_Bucket_Activity_Line_Item__c partFIFOBucketActivityLIRec : fifoActivityLIList) {
	        	if(fifoBucketIdToRecMap.containsKey(partFIFOBucketActivityLIRec.Part_FIFO_Bucket__c) && partFIFOBucketActivityLIRec.CO_Invoice_Header__c == null) {
	        		partFIFOBucketActivityLIRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM).Sync_Flag_API_Name__c, true);
	        	}
	        }
        }
    }
    
    public static void manageCOInvoicePaymentSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<CO_Invoice_Payment__c> newList) {
        new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.CO_INVOICE_PAYMENT);
        for(CO_Invoice_Payment__c coInvoicePaymentRec : newList) {
            if(coInvoicePaymentRec.Payment_Method__c != QBUtil.CHARGE_ACCOUNT) {
                coInvoicePaymentRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_PAYMENT).Sync_Flag_API_Name__c, true);
            }
        }
    }
    
    public static void manageStockUnitCategorySyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Customer_Owned_Unit__c> newList, Map<Id, Customer_Owned_Unit__c> oldMap) {
        new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.STOCK_UNIT_CATEGORY);
        Set<Id> categoryIdSet = new Set<Id>();
        for(Customer_Owned_Unit__c unitRec : newList) {
            Id oldCategory = oldMap.get(unitRec.Id).Category__c;
            if(unitRec.Unit_Type__c == 'STOCK' && unitRec.Status__c != 'Sold' && oldCategory != null && oldCategory != unitRec.Category__c) {
                categoryIdSet.add(oldCategory);
                categoryIdSet.add(unitRec.Category__c);
            }
        }
        Map<Id, Category__c> categoryIdToCategoryRecordMap;
        if(categoryIdSet.size() > 0) {
            categoryIdToCategoryRecordMap = new Map<Id, Category__c>([SELECT Id, Inventory_GL__c FROM Category__c WHERE Id IN :categoryIdSet]);
            for(Customer_Owned_Unit__c unitRec : newList) {
                Id oldCategory = oldMap.get(unitRec.Id).Category__c;
                if(unitRec.Unit_Type__c == 'STOCK' && unitRec.Status__c != 'Sold' && unitRec.Total_Cost__c != null && unitRec.Total_Cost__c != 0 && oldCategory != null && oldCategory != unitRec.Category__c && 
                    categoryIdToCategoryRecordMap.get(oldCategory).Inventory_GL__c != categoryIdToCategoryRecordMap.get(unitRec.Category__c).Inventory_GL__c) {
                        unitRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.STOCK_UNIT_CATEGORY).Sync_Flag_API_Name__c, true);
                }
            }
        }
    }
    
    public static void managePartCategorySyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Part__c> partNewList, Map<Id, Part__c> oldMap) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.PART_CATEGORY);
        Set<Id> categoryIdSet = new Set<Id>();
        for(Part__c partRec : partNewList) {
        	Id oldCategory = oldMap.get(partRec.Id).Category__c;
        	if(oldCategory != null && oldCategory != partRec.Category__c) {
        		categoryIdSet.add(oldCategory);
	        	categoryIdSet.add(partRec.Category__c);
        	}
        }
        
        Map<Id, Category__c> categoryIdToCategoryRecordMap;
        if(categoryIdSet.size() > 0) {
        	categoryIdToCategoryRecordMap = new Map<Id, Category__c>([SELECT Id, Inventory_GL__c FROM Category__c WHERE Id IN :categoryIdSet]);
        	for(Part__c partRec : partNewList) {
        		Id oldCategory = oldMap.get(partRec.Id).Category__c;
	            if(partRec.Total_Cost__c != null && partRec.Total_Cost__c != 0 && oldCategory != null && oldCategory != partRec.Category__c && 
	            	categoryIdToCategoryRecordMap.get(oldCategory).Inventory_GL__c != categoryIdToCategoryRecordMap.get(partRec.Category__c).Inventory_GL__c) {
	            		partRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.PART_CATEGORY).Sync_Flag_API_Name__c, true);
	            }
	        }
        }
    }
    
    public static void manageCODepositSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<CO_Deposit__c> newList) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.CO_DEPOSIT);
    	
    	for(CO_Deposit__c coDepositRec : newList) {
        	coDepositRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CO_DEPOSIT).Sync_Flag_API_Name__c, true);
        }
    }
    
    public static void manageDealItemSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Deal_Item__c> newList, Map<Id, Deal_Item__c> oldMap) {
        new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.STOCK_TRADE_IN);
        for(Deal_Item__c dealItemRec : newList) {
            if(dealItemRec.Type__c == QBUtil.DEAL_ITEM_TYPE_TRADE_IN && dealItemRec.Is_Stocked_In__c && !oldMap.get(dealItemRec.Id).Is_Stocked_In__c) {
                dealItemRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.STOCK_TRADE_IN).Sync_Flag_API_Name__c, true);
            }
        }
    }
    
    public static void manageCOInvoiceSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<CO_Invoice_Header__c> newList, Map<Id, CO_Invoice_Header__c> oldMap) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, new List<String>{IntegrationUtility.INVOICE, IntegrationUtility.CO_INVOICE_JE, IntegrationUtility.INVOICE_PAYMENT});
    	for(CO_Invoice_Header__c coInvoiceRec : newList) {
    		if(checkForExtraConditionsForCOInvoice(coInvoiceRec, oldMap.get(coInvoiceRec.Id))) {
    			coInvoiceRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.INVOICE).Sync_Flag_API_Name__c, true);
    		}
    		if(checkForExtraConditionsForCOInvoiceJE(coInvoiceRec, oldMap.get(coInvoiceRec.Id))) {
        		coInvoiceRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CO_INVOICE_JE).Sync_Flag_API_Name__c, true);
        	}
        	if(checkForExtraConditionsForCOInvoicePayments(coInvoiceRec, oldMap.get(coInvoiceRec.Id))) {
        		coInvoiceRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.INVOICE_PAYMENT).Sync_Flag_API_Name__c, true);
        	}
        }
    }
    
    public static void manageVOInvoiceSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Vendor_Invoicing_Header__c> newList, 
                                                                        Map<Id, Vendor_Invoicing_Header__c> oldMap) {
        new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.VO_INVOICE);
        
        for(Vendor_Invoicing_Header__c voInvoiceRec : newList) {
            if(checkForExtraConditionsForVOInvoice(voInvoiceRec, oldMap.get(voInvoiceRec.Id))) {
                voInvoiceRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VO_INVOICE).Sync_Flag_API_Name__c, true);
            }
        }
    }
    
    public static void manageVOReturnSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Return_VO_Header__c> newList, 
                                                                        Map<Id, Return_VO_Header__c> oldMap) {
        new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.VO_RETURN);
        
        for(Return_VO_Header__c returnVOHeader : newList) {
            if(returnVOHeader.Status__c == 'Credited' && returnVOHeader.Status__c != oldMap.get(returnVOHeader.Id).Status__c) {
                returnVOHeader.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VO_RETURN).Sync_Flag_API_Name__c, true);
            }
        }
    }
    
    private static Boolean checkForExtraConditionsForVOInvoice(Vendor_Invoicing_Header__c newRec, Vendor_Invoicing_Header__c oldRec) {
        return (newRec.Status__c != oldRec.Status__c && newRec.Status__c == IntegrationUtility.INVOICED);
    }
    
    public static void manageAccountSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList,List<Account> accNewList, Map<Id, Account> accOldMap) {
        if(accNewList.size() > 0) {
            new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, new List<String>{IntegrationUtility.CUSTOMER, IntegrationUtility.VENDOR});
        }
        for(Account accRec : accNewList) {
            Account oldRec = accOldMap.get(accRec.Id);
            String changedFieldsString = '';
            if(accRec.FirstName__c != oldRec.FirstName__c || accRec.LastName__c != oldRec.LastName__c || accRec.Type__c != oldRec.Type__c || 
                accRec.Name != oldRec.Name || accRec.Customer_Number__c != oldRec.Customer_Number__c || accRec.Active__c != oldRec.Active__c ||
                accRec.Home_Number__c != oldRec.Home_Number__c || accRec.Mobile__c != oldRec.Mobile__c || accRec.Work_Number__c != oldRec.Work_Number__c ||
                accRec.Email__c != oldRec.Email__c || accRec.Other_Email__c != oldRec.Other_Email__c || accRec.Work_Email__c != oldRec.Work_Email__c || 
                accRec.BillingStreet != oldRec.BillingStreet || accRec.BillingCity != oldRec.BillingCity || accRec.BillingState != oldRec.BillingState ||
                accRec.BillingCountry != oldRec.BillingCountry || accRec.BillingPostalCode != oldRec.BillingPostalCode ||
                accRec.ShippingStreet != oldRec.ShippingStreet || accRec.ShippingCity != oldRec.ShippingCity || accRec.ShippingState != oldRec.ShippingState ||
                accRec.ShippingCountry != oldRec.ShippingCountry || accRec.ShippingPostalCode != oldRec.ShippingPostalCode ||
                accRec.Vendor_Code__c != oldRec.Vendor_Code__c || accRec.Is_Vendor__c != oldRec.Is_Vendor__c || 
                accRec.Claims_for_Service_Work__c != oldRec.Claims_for_Service_Work__c  || 
                accRec.Website != oldRec.Website  || 
                accRec.Preferred_Email__c != oldRec.Preferred_Email__c || 
                accRec.Vendor_Tax_Id__c != oldRec.Vendor_Tax_Id__c ||
                accRec.AccountNumber != oldRec.AccountNumber ||
                accRec.Vendor_Number__c != oldRec.Vendor_Number__c ) {
                    
                if(checkForExtraConditionsForCustomer(accRec)) {
                    accRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CUSTOMER).Sync_Flag_API_Name__c, true);
                } 
                if(checkForExtraConditionsForVendor(accRec)) {
                   accRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VENDOR).Sync_Flag_API_Name__c, true);
                } 
            }
            if((accRec.Is_Customer__c || (accRec.Is_Vendor__c && accRec.Claims_for_Service_Work__c)) &&
             accRec.get(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.CUSTOMER).Integration_Id_API_Name__c) != null) {
    	        	accRec = (Account) updateSparseFieldForTheRecord(accRec, oldRec, new Set<String>{'QB_Updated_Fields__c', 'Vendor_QB_Updated_Fields__c'}, customerFieldListToSync);
	    	} else if(accRec.Is_Vendor__c && accRec.get(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VENDOR).Integration_Id_API_Name__c) != null) {
	    		accRec = (Account) updateSparseFieldForTheRecord(accRec, oldRec, new Set<String>{'QB_Updated_Fields__c', 'Vendor_QB_Updated_Fields__c'}, customerFieldListToSync);
	    	}
        }
    }
    
     public static void manageStoreCreditSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Store_Credit__c> newList) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.STORE_CREDIT);
    	 for(Store_Credit__c storeCreditRec : newList) {
            if(storeCreditRec.CO_Invoice_Header__c == null && storeCreditRec.CO_Header__c == null) {
                storeCreditRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.STORE_CREDIT).Sync_Flag_API_Name__c, true);
            }
        }
    								  									
    }
    
    public static void manageAdjustmentSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Unit_Price_Cost__c> newList) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.UNIT_PRICE_COST);
			for(Unit_Price_Cost__c upcRec : newList) {
	        if(upcRec.Ref_No__c != null && upcRec.Ref_No__c.startsWith('UA-') && upcRec.Unit_Type__c == 'STOCK' &&
	            upcRec.Total_Cost__c != null && upcRec.Total_Cost__c != 0 && upcRec.Type__c != 'Dealer') {
	            upcRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.UNIT_PRICE_COST).Sync_Flag_API_Name__c, true);
	        }
	    }    								  									
    }
    
    public static void manageVendorReceivingSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Vendor_Receiving_Header__c> receivingNewList,Map<Id, Vendor_Receiving_Header__c> receivingOldMap) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.VENDOR_RECEIVING);
    	for(Vendor_Receiving_Header__c vendorReceivingRec : receivingNewList) {
            if(vendorReceivingRec.Status__c == IntegrationUtility.STOCKED && receivingOldMap.get(vendorReceivingRec.Id).Status__c != IntegrationUtility.STOCKED)  {
                vendorReceivingRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VENDOR_RECEIVING).Sync_Flag_API_Name__c, true);
            }
        }
    }
    
    public static void manageLienPayoutSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Deal__c> newList, Map<Id, Deal__c> oldMap) {
    	new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.LIEN_PAYOUT);
        Set<Id> dealIdSet = new Set<Id>();
    	for(Deal__c dealRec : newList) {
            if(dealRec.Status__c != oldMap.get(dealRec.Id).Status__c && dealRec.Status__c == Constants.DEAL_STATUS_INVOICED) {
                dealIdSet.add(dealRec.Id);
            }
        }
        //system.assert(false, newList + '  oldMap   ' + oldMap);
        if(!AccessControl.ifObjectFieldIsAccessible('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = [SELECT Id FROM Deal_Item__c WHERE Type__c =: Constants.DEAL_ITEM_TYPE_TRADE_IN AND Lien_Payout__c > 0 AND Deal__c IN: dealIdSet];
        for(Deal_Item__c dealItemRec : dealItemList) {
        	dealItemRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.LIEN_PAYOUT).Sync_Flag_API_Name__c, true);
        }
        
        if(!AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        BPScriptUtility.disbaleTrigger('DealItemTrigger');
        update dealItemList;
        BPScriptUtility.enableTrigger('DealItemTrigger');
        //system.assert(false, dealItemList);
    }
    public static void manageUnitSyncFlag(List<BaseIntegrationService> baseIntegrationServiceList, List<Customer_Owned_Unit__c> newList) {
        new IntegrationUtility().getIntegrationEntityMetadata(baseIntegrationServiceList, IntegrationUtility.UNIT_INVOICE);
        Set<Id> orderedUnitIdSet = new Set<Id>();
        for(Customer_Owned_Unit__c couRec : newList) {
            if(couRec.Unit_Type__c == 'STOCK' && couRec.Referenced_Unit__c != null) {
                orderedUnitIdSet.add(couRec.Referenced_Unit__c);
            }
        }
        if(orderedUnitIdSet.size() > 0) {
            Map<Id, Customer_Owned_Unit__c> orderedUnitIdToOrderedUnitRecMap = 
                new Map<Id, Customer_Owned_Unit__c>([SELECT Unit_Type__c, Status__c, Total_Cost__c From Customer_Owned_Unit__c WHERE Id IN: orderedUnitIdSet
                                                            AND Total_Cost__c != null]);
            for(Customer_Owned_Unit__c couRec : newList) {
                if(orderedUnitIdToOrderedUnitRecMap.containsKey(couRec.Referenced_Unit__c)) {
                    Customer_Owned_Unit__c orderedUnit = orderedUnitIdToOrderedUnitRecMap.get(couRec.Referenced_Unit__c);
                    if(orderedUnit.Unit_Type__c == 'ORDU' && orderedUnit.Status__c == 'Received' && orderedUnit.Total_Cost__c != 0) {
                       couRec.put(baseIntegrationServiceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.UNIT_INVOICE).Sync_Flag_API_Name__c, true);
                    }
                }
            }
        }
    }
    
    private static Boolean checkForExtraConditionsForCustomer(Account customerRec) {
    	return (customerRec.Is_Customer__c || (customerRec.Is_Vendor__c && customerRec.Claims_for_Service_Work__c));
    }
    
    private static Boolean checkForExtraConditionsForVendor(Account vendorRec) {
    	return (vendorRec.Is_Vendor__c);
    }
    
    private static List<String> customerFieldListToSync = new List<String> {
        'FirstName__c', 'LastName__c', 'Home_Number__c', 'Mobile__c', 'BillingStreet', 'BillingCity', 'BillingCountry', 'BillingState', 'BillingPostalCode',
        'ShippingStreet', 'ShippingCity', 'ShippingCountry', 'ShippingState', 'ShippingPostalCode', 'Active__c',
        'Name', 'Work_Number__c', 'Fax', 'Website', 'AccountNumber', 'Email__c', 'Other_Email__c', 'Work_Email__c','Preferred_Email__c', 'Vendor_Number__c', 'Vendor_Tax_Id__c'
    };
    
    private static Boolean checkForExtraConditionsForCOInvoice(CO_Invoice_Header__c newRec, CO_Invoice_Header__c oldRec) {
    	return (newRec.Invoice_Status__c != oldRec.Invoice_Status__c && newRec.Invoice_Status__c == IntegrationUtility.CLOSED && 
    				newRec.Checkout_Type__c != IntegrationUtility.INTERNAL && newRec.Checkout_Type__c != IntegrationUtility.DEAL);
    }
    
    private static Boolean checkForExtraConditionsForCOInvoiceJE(CO_Invoice_Header__c newRec, CO_Invoice_Header__c oldRec) {
    	return (newRec.Invoice_Status__c != oldRec.Invoice_Status__c && newRec.Invoice_Status__c == IntegrationUtility.CLOSED);
    }
    
    private static Boolean checkForExtraConditionsForCOInvoicePayments(CO_Invoice_Header__c newRec, CO_Invoice_Header__c oldRec) {
    	return (newRec.Invoice_Status__c != oldRec.Invoice_Status__c && newRec.Invoice_Status__c == QBUtil.CLOSED && 
    				newRec.Checkout_Type__c != QBUtil.INTERNAL && newRec.Checkout_Type__c != QBUtil.DEAL
    				&& newRec.Total_Amount_Except_Charge_Account__c != 0);
    }
}