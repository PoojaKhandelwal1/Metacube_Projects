/**
 * Author: Richa Mittal
 * Since: May 25, 2018
 * Name: QBSyncFlagService
 * Description: Service class for setting/resetting sync flag value
**/
public with sharing class QBSyncFlagService {
    
    public static void manageAccountSyncFlag(List<Account> accNewList, Map<Id, Account> accOldMap) {
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
                accRec.Claims_for_Service_Work__c != oldRec.Claims_for_Service_Work__c) {
                    
                if(checkForExtraConditionsForCustomer(accRec)) {
                    accRec.availForQBSync__c = true;
                } 
                if(checkForExtraConditionsForVendor(accRec)) {
                    accRec.Vendor_AvailForQBSync__c = true;
                } 
            }
            accRec = (Account) pushUpdatedFieldsForSparseUpdate(accRec, oldRec, new Set<String>{'QB_Updated_Fields__c', 'Vendor_QB_Updated_Fields__c'}, customerFieldListToSync);
        }
    }
    
    private static List<String> customerFieldListToSync = new List<String> {
        'FirstName__c', 'LastName__c', 'Home_Number__c', 'Mobile__c', 'BillingStreet', 'BillingCity', 'BillingCountry', 'BillingState', 'BillingPostalCode',
        'ShippingStreet', 'ShippingCity', 'ShippingCountry', 'ShippingState', 'ShippingPostalCode', 'Active__c',
        'Name', 'Work_Number__c', 'Fax', 'Website', 'AccountNumber', 'Email__c', 'Other_Email__c', 'Work_Email__c'
    };
    
    private static List<String> categoryFieldListToSync = new List<String> {
        'Active__c', 'Name', 'Type__c', 'Description__c', 'Income_GL__c', 'Inventory_GL__c', 'COGS_GL__c'
    };
    
    public static void manageCategorySyncFlag(List<Category__c> categoryNewList) {
        for(Category__c catRec : categoryNewList) {
            if(catRec.Active__c && catRec.Name != null && catRec.Type__c != null && catRec.Description__c != null && 
                (catRec.Income_GL__c != null || catRec.Inventory_GL__c != null || catRec.COGS_GL__c != null)) {
                catRec.availForQBSync__c = true;
            }
        }
    }
    
    public static void manageCategorySyncFlag(List<Category__c> categoryNewList, Map<Id, Category__c> oldMap) {
        for(Category__c catRec : categoryNewList) {
            String changedFieldsString = '';
            Category__c oldRec = oldMap.get(catRec.Id);
            if(catRec.Active__c && 
                    (catRec.Name != oldRec.Name || catRec.Type__c != oldRec.Type__c || catRec.Description__c != oldRec.Description__c || 
                     catRec.Income_GL__c != oldRec.Income_GL__c || catRec.Inventory_GL__c != oldRec.Inventory_GL__c || 
                     catRec.COGS_GL__c != oldRec.COGS_GL__c || catRec.Active__c != oldRec.Active__c)) {
                catRec.availForQBSync__c = true;
            }
            
            if(catRec.AccountingId__c != null) {
            	catRec = (Category__c) pushUpdatedFieldsForSparseUpdate(catRec, oldRec, new Set<String>{'QB_Updated_Fields__c'}, categoryFieldListToSync);
        	}
        }
    }
    
    public static SObject pushUpdatedFieldsForSparseUpdate(SObject updatedRec, SObject oldRec, Set<String> updatedFieldsAPINameSet, List<String> fieldsToSyncList) {
        String changedFieldsString = '';
        for(String fieldName : fieldsToSyncList) {
            if(updatedRec.get(fieldName) != oldRec.get(fieldName)) {
                changedFieldsString += fieldName + ',';
            }
        }
        for(String updatedFieldsAPIName : updatedFieldsAPINameSet) {
            if(String.isNotBlank((String)updatedRec.get(updatedFieldsAPIName))) {
                updatedRec.put(updatedFieldsAPIName,  updatedRec.get(updatedFieldsAPIName)+changedFieldsString);
            } else {
                updatedRec.put(updatedFieldsAPIName, changedFieldsString);
            }
        }
        return updatedRec;
    }
    
    public static void manageVendorInvoiceSyncFlag(List<Vendor_Invoicing_Header__c> newList, Map<Id, Vendor_Invoicing_Header__c> oldMap) {
        for(Vendor_Invoicing_Header__c invoiceRec : newList) {
            Vendor_Invoicing_Header__c oldRec = oldMap.get(invoiceRec.Id);
            if(invoiceRec.Status__c == 'Invoiced' && invoiceRec.Status__c != oldRec.Status__c) {
                invoiceRec.availForQBSync__c = true;
            }
        }
    }
    
    public static void manageVendorReturnSyncFlag(List<Return_VO_Header__c> newList, Map<Id, Return_VO_Header__c> oldMap) {
        for(Return_VO_Header__c returnVOHeader : newList) {
            if(returnVOHeader.Status__c == 'Credited' && returnVOHeader.Status__c != oldMap.get(returnVOHeader.Id).Status__c) {
                returnVOHeader.availForQBSync__c = true;
            }
        }
    }
    
    public static void manageAdjustmentSyncFlag(List<Unit_Price_Cost__c> newList) {
        for(Unit_Price_Cost__c upcRec : newList) {
            if(upcRec.Ref_No__c != null && upcRec.Ref_No__c.startsWith('UA-') && upcRec.Unit_Type__c == 'STOCK' &&
                upcRec.Total_Cost__c != null && upcRec.Total_Cost__c != 0 && upcRec.Type__c != 'Dealer') {
                upcRec.availForQBSync__c = true;
            }
        }
    }
    
    public static void manageStoreCreditSyncFlag(List<Store_Credit__c> newList) {
        for(Store_Credit__c storeCreditRec : newList) {
            if(storeCreditRec.CO_Invoice_Header__c == null && storeCreditRec.CO_Header__c == null) {
                storeCreditRec.availForQBSync__c = true;
            }
        }
    }
    
    public static void manageUnitSyncFlag(List<Customer_Owned_Unit__c> newList) {
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
                        couRec.availForQBSync__c = true;
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
    
    public static List<CO_Invoice_Header__c> manageCOInvoiceSyncFlag(List<CO_Invoice_Header__c> newList, Map<Id, CO_Invoice_Header__c> oldMap) {
        for(CO_Invoice_Header__c coInvoiceRec : newList) {
        	if(checkForExtraConditionsForCOInvoice(coInvoiceRec, oldMap.get(coInvoiceRec.Id))) {
        		coInvoiceRec.availForQBSync__c = true;
        	}
        	if(checkForExtraConditionsForCOInvoiceJE(coInvoiceRec, oldMap.get(coInvoiceRec.Id))) {
        		coInvoiceRec.availForQBJournalEntrySync__c = true;
        	}
        	if(checkForExtraConditionsForCOInvoicePayments(coInvoiceRec, oldMap.get(coInvoiceRec.Id))) {
        		coInvoiceRec.availForQBCOInvoicePayment__c = true;
        	}
        }
		return newList;
    }
    
    private static Boolean checkForExtraConditionsForCOInvoice(CO_Invoice_Header__c newRec, CO_Invoice_Header__c oldRec) {
    	return (newRec.Invoice_Status__c != oldRec.Invoice_Status__c && newRec.Invoice_Status__c == QBUtil.CLOSED && 
    				newRec.Checkout_Type__c != QBUtil.INTERNAL && newRec.Checkout_Type__c != QBUtil.DEAL);
    }
    
    private static Boolean checkForExtraConditionsForCOInvoiceJE(CO_Invoice_Header__c newRec, CO_Invoice_Header__c oldRec) {
    	return (newRec.Invoice_Status__c != oldRec.Invoice_Status__c && newRec.Invoice_Status__c == QBUtil.CLOSED);
    }
    
    private static Boolean checkForExtraConditionsForCOInvoicePayments(CO_Invoice_Header__c newRec, CO_Invoice_Header__c oldRec) {
    	return (newRec.Invoice_Status__c != oldRec.Invoice_Status__c && newRec.Invoice_Status__c == QBUtil.CLOSED && 
    				newRec.Checkout_Type__c != QBUtil.INTERNAL && newRec.Checkout_Type__c != QBUtil.DEAL && newRec.Is_Charge_Account_Payment_Exists__c > 0 
    				&& newRec.Total_Amount_Except_Charge_Account__c > 0);
    }
    
    public static List<CO_Deposit__c> manageCODepositJESyncFlag(List<CO_Deposit__c> newList) {
        for(CO_Deposit__c coDepositRec : newList) {
        	coDepositRec.availForQBJournalEntrySync__c = true;
        }
		return newList;
    }
    
    public static List<CO_Invoice_Payment__c> manageCOInvoicePaymentJESyncFlag(List<CO_Invoice_Payment__c> newList) {
        for(CO_Invoice_Payment__c coInvoicePaymentRec : newList) {
        	if(coInvoicePaymentRec.Payment_Method__c != QBUtil.CHARGE_ACCOUNT) {
        		coInvoicePaymentRec.availForQBJournalEntrySync__c = true;
        	}
        }
		return newList;
    }
    
    public static List<Part_FIFO_Bucket__c> managePartFIFOBucketSyncFlag(List<Part_FIFO_Bucket__c> newList) {
        for(Part_FIFO_Bucket__c partFIFOBucketRec : newList) {
        	if(partFIFOBucketRec.Is_FIFO_Bucket__c && partFIFOBucketRec.Vendor_Receiving_Header__c == null && partFIFOBucketRec.Customer_Return__c == null && 
        		partFIFOBucketRec.Source_Name__c != QBUtil.PART_CREATED && partFIFOBucketRec.Source_Name__c != QBUtil.OVERSOLD) {
        			partFIFOBucketRec.availForQBSync__c = true;
        	}
        }
		return newList;
    }
    
    public static List<Part_FIFO_Bucket_Activity_Line_Item__c> managePartFIFOBucketActivityLISyncFlag(List<Part_FIFO_Bucket_Activity_Line_Item__c> newList) {
        Set<Id> fifoBucketIds = new Set<Id>();
        for(Part_FIFO_Bucket_Activity_Line_Item__c partFIFOBucketActivityLIRec : newList) {
        	fifoBucketIds.add(partFIFOBucketActivityLIRec.Part_FIFO_Bucket__c);
        }
        Map<Id, Part_FIFO_Bucket__c> fifoBucketIdToRecMap;
        if(fifoBucketIds.size() > 0) {
        	fifoBucketIdToRecMap = new Map<Id, Part_FIFO_Bucket__c>([SELECT Id, Is_FIFO_Bucket__c FROM Part_FIFO_Bucket__c WHERE Id IN :fifoBucketIds]);
        }
        for(Part_FIFO_Bucket_Activity_Line_Item__c partFIFOBucketActivityLIRec : newList) {
        	if((fifoBucketIdToRecMap.get(partFIFOBucketActivityLIRec.Part_FIFO_Bucket__c)).Is_FIFO_Bucket__c && partFIFOBucketActivityLIRec.CO_Invoice_Header__c == null) {
        		partFIFOBucketActivityLIRec.availForQBSync__c = true;
        	}
        }
		return newList;
    }
    
    public static List<Vendor_Receiving_Header__c> manageVendorReceivingSyncFlag(List<Vendor_Receiving_Header__c> newList, Map<Id, Vendor_Receiving_Header__c> oldMap) {
        for(Vendor_Receiving_Header__c vendorReceivingRec : newList) {
            if(vendorReceivingRec.Status__c == QBUtil.STOCKED && oldMap.get(vendorReceivingRec.Id).Status__c != QBUtil.STOCKED)  {
                vendorReceivingRec.availForQBJournalEntrySync__c = true;
            }
        }
		return newList;
    }
    
    public static void managePartJESyncFlagOnCategoryChange(List<Part__c> newList, Map<Id, Part__c> oldMap) {
    	Set<Id> categoryIdSet = new Set<Id>();
        for(Part__c partRec : newList) {
        	Id oldCategory = oldMap.get(partRec.Id).Category__c;
        	if(oldCategory != null && oldCategory != partRec.Category__c) {
        		categoryIdSet.add(oldCategory);
	        	categoryIdSet.add(partRec.Category__c);
        	}
        }
        
        Map<Id, Category__c> categoryIdToCategoryRecordMap;
        if(categoryIdSet.size() > 0) {
        	categoryIdToCategoryRecordMap = new Map<Id, Category__c>([SELECT Id, Inventory_GL__c FROM Category__c WHERE Id IN :categoryIdSet]);
        	for(Part__c partRec : newList) {
        		Id oldCategory = oldMap.get(partRec.Id).Category__c;
	            if(partRec.Total_Cost__c != null && partRec.Total_Cost__c != 0 && oldCategory != null && oldCategory != partRec.Category__c && 
	            	categoryIdToCategoryRecordMap.get(oldCategory).Inventory_GL__c != categoryIdToCategoryRecordMap.get(partRec.Category__c).Inventory_GL__c) {
	            		partRec.Avail_For_QB_Sync_Category__c = true;
	            }
	        }
        }
    }
    
    public static void manageUnitJESyncFlagOnCategoryChange(List<Customer_Owned_Unit__c> newList, Map<Id, Customer_Owned_Unit__c> oldMap) {
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
	            		unitRec.Avail_For_QB_Sync_Category__c = true;
	            }
	        }
        }
    }
    
    public static void manageDealItemSyncFlag(List<Deal_Item__c> newList, Map<Id, Deal_Item__c> oldMap) {
    	for(Deal_Item__c dealItemRec : newList) {
            if(dealItemRec.Type__c == QBUtil.DEAL_ITEM_TYPE_TRADE_IN && dealItemRec.Is_Stocked_In__c && !oldMap.get(dealItemRec.Id).Is_Stocked_In__c) {
                dealItemRec.Avail_For_QB_Sync__c = true;
            }
        }
    }
    
    public static void manageLienPayoutSyncFlag(List<Deal__c> newList, Map<Id, Deal__c> oldMap) {
    	Set<Id> dealIdSet = new Set<Id>();
    	for(Deal__c dealRec : newList) {
            if(dealRec.Status__c != oldMap.get(dealRec.Id).Status__c && dealRec.Status__c == Constants.DEAL_STATUS_INVOICED) {
                dealIdSet.add(dealRec.Id);
            }
        }
        
        if(!AccessControl.ifObjectFieldIsAccessible('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Deal_Item__c> dealItemList = [SELECT Id FROM Deal_Item__c WHERE Type__c =: Constants.DEAL_ITEM_TYPE_TRADE_IN AND Lien_Payout__c > 0 AND Deal__c IN: dealIdSet];
        for(Deal_Item__c dealItemRec : dealItemList) {
        	dealItemRec.Lien_Payout_Avail_For_QB_Sync__c = true;
        }
        
        if(!AccessControl.ifObjectFieldIsUpdateable('Deal_Item__c')) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        BPScriptUtility.disbaleTrigger('DealItemTrigger');
        update dealItemList;
        BPScriptUtility.enableTrigger('DealItemTrigger');
    }
}