/**
 * Author: Hitesh Gupta
 * Since: Dec. 23, 2015
 * Name: ServiceOrderLineItemTriggerHelper
 * Description: Helper class for triggers on SOLI.
**/
public class ServiceOrderLineItemTriggerHelper {
    
    // List to store trigger new list
    public static List<Service_Order_Line_Item__c> soliNewList = new List<Service_Order_Line_Item__c>();
    
    // List to store trigger old list
    public static List<Service_Order_Line_Item__c> soliOldList = new List<Service_Order_Line_Item__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Service_Order_Line_Item__c> soliNewMap = new Map<Id, Service_Order_Line_Item__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Service_Order_Line_Item__c> soliOldMap = new Map<Id, Service_Order_Line_Item__c>();
    
    // Boolean to stop trigger
    public static Boolean isTriggerExecuted = false;
    public static Boolean isUpdateClaimLI = true;
    public static Boolean isVOLIRecToChange = true;
    public static Boolean isActivateQuoteCO = false;
    public static Boolean isVOLIInsertFromVRPage = true;
    public static Boolean shouldTriggerRunStop = false;
    public static Boolean isMoveLineItem = false;
    
    public static String coHeaderId;
    
    public static void beforeInsertCalculation() {
        List<Service_Order_Line_Item__c> soliListHavingSubletAndLabour = new List<Service_Order_Line_Item__c>();
        for(Service_Order_Line_Item__c soliRec : soliNewList) {
            if(soliRec.Service_Order_Kit_Header__c == null && (soliRec.Labour_Code__c != null || soliRec.Sublet__c != null)) {
                soliListHavingSubletAndLabour.add(soliRec);
            }
        }
        
        Set<Id> labourIdSet = new Set<Id>();
        Set<Id> subletIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soliRec : soliListHavingSubletAndLabour) {
            labourIdSet.add(soliRec.Labour_Code__c);
            subletIdSet.add(soliRec.Sublet__c);
        }
        labourIdSet.remove(null);
        subletIdSet.remove(null);
        Map<Id, Labour_Code__c> labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>();
        Map<Id, Product__c> subletIdToSubletRecordMap = new Map<Id, Product__c>();
        
        if(labourIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>([SELECT Rate__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c,
                                                                        Fixed_Rate__c, Code__c, Description__c
                                                                        FROM Labour_Code__c where Id IN: labourIdSet]);
        }
        if(subletIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            subletIdToSubletRecordMap = new Map<Id, Product__c>([SELECT Price__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c,
                                                                        Code__c, Description__c
                                                                        from Product__c where Id IN: subletIdSet]);
        }
        
        if(soliListHavingSubletAndLabour.size() > 0) {
            applyPriceLevel(soliListHavingSubletAndLabour, labourIdToLabourRecordMap, subletIdToSubletRecordMap);
        }
        populateDescription(labourIdToLabourRecordMap, subletIdToSubletRecordMap);
    }
    
    /**
     * Name: afterInsertCalculation
     * Desc: before update operations
     * @param: 
     * @return: 
    **/
    public static void afterInsertCalculation() {
        if(!isTriggerExecuted) {
            insertCOLIs();
        }
        Set<Id> soHeaderIdSet = new Set<Id>();
        List<Service_Order_Line_Item__c> soliListHavingLabourAndSublet = new List<Service_Order_Line_Item__c>();
        for(Service_Order_Line_Item__c soliRec : soliNewList) {
        	soHeaderIdSet.add(soliRec.Service_Order_Header__c);
            if(soliRec.Service_Order_Kit_Header__c == null && (soliRec.Labour_Code__c != null || soliRec.Sublet__c != null)) {
                soliListHavingLabourAndSublet.add(soliRec);
            }
        }
        if(soliListHavingLabourAndSublet.size() > 0) {
            applySalesTax(soliListHavingLabourAndSublet);
        }
        
        upsertClaimLineItems(soHeaderIdSet);
        
        if(!isMoveLineItem) {
        	upsertVOLineItem();
        }
    }
    
    public static void upsertRelatedClaimLineItems() {
    	Set<Id> soHeaderIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soliRec : soliNewList) {
        	soHeaderIdSet.add(soliRec.Service_Order_Header__c);
        }
        if(isUpdateClaimLI) upsertClaimLineItems(soHeaderIdSet);
    }
    
    public static void upsertClaimLineItems(Set<Id> soHeaderIdSet) {
        if(soHeaderIdSet == null || soHeaderIdSet.size() == 0) {
        	return;
        }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, Service_Order_Line_Item__c> soliIdToRecMap = new Map<Id, Service_Order_Line_Item__c>([Select Id, Service_Order_Header__c, 
        						Service_Order_Header__r.Claim_Status__c, Price_When_Tax_Included__c,
				        		Kit_Price__c, Qty_Needed__c, Tax__c, Item_Code__c, Item_Description__c, Item_Desc__c, (Select Id, Tax_Rate__c from Individual_Taxes__r),  
				        		(Select Id, Claimed_Qty__c, Claimed_Price__c from Claim_Line_Items__r) from Service_Order_Line_Item__c where Id IN: soliNewList AND
				        		Service_Order_Header__r.Transaction_Type__r.Type__c = 'Third-Party']);
		
		if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }       		
		Map<Id, Service_Order_Header__c> soIdToRecMap = new Map<Id, Service_Order_Header__c>([Select Id, Claim_Status__c, (Select Id from Claims__r LIMIT 1), 
							(Select Id from Service_Order_Line_Items__r where Id IN: soliNewList), (Select Id, Claim__c from SO_Payment_Roles__r where RecordType.DeveloperName = 'Third_Party') 
							from Service_Order_Header__c where Id IN: soHeaderIdSet AND Transaction_Type__r.Type__c = 'Third-Party']);
        
        if(soIdToRecMap.size() > 0) {
        	List<SO_Payment_Role__c> soPaymentRoleListToUpdate = new List<SO_Payment_Role__c>();
	        List<Claim_Line_Item__c> claimLIListToUpsert = new List<Claim_Line_Item__c>();
	        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
	        for(Service_Order_Header__c soRec : soIdToRecMap.values()) {
	        	if(soRec.Claims__r.size() == 0 || soRec.Claim_Status__c == 'Approved' || soRec.SO_Payment_Roles__r.size() == 0) {
	        		continue;
	        	}
	        	Decimal TotalAmount = 0;
	        	Decimal TotalTaxamount = 0;
	        	for(Service_Order_Line_Item__c soliRec : soRec.Service_Order_Line_Items__r) {
	        		Service_Order_Line_Item__c soLineItemRec = soliIdToRecMap.get(solirec.Id);
		            Claim_Line_Item__c  claimLineItemRec = (soLineItemRec.Claim_Line_Items__r.size() > 0) ? soLineItemRec.Claim_Line_Items__r[0] : new Claim_Line_Item__c();
		            claimLineItemRec.Claimed_Price__c = claimLineItemRec.Claimed_Price__c != null ? claimLineItemRec.Claimed_Price__c : 0;
		            claimLineItemRec.Claimed_Qty__c = claimLineItemRec.Claimed_Qty__c != null ? claimLineItemRec.Claimed_Qty__c : 0;
		            
		            claimLineItemRec.Service_Order_Line_Item__c = soLineItemRec.Id;
            		claimLineItemRec.SO_Payment_Role__c = soRec.SO_Payment_Roles__r[0].Id;
            		claimLineItemRec.Claim__c = soRec.SO_Payment_Roles__r[0].Claim__c;
            
		            claimLineItemRec.Item_Code__c = soLineItemRec.Item_Code__c ;
		            claimLineItemRec.Item_Description__c = soLineItemRec.Item_Description__c ;
		            claimLineItemRec.Item_Desc__c = soLineItemRec.Item_Desc__c ;
		            
            		Decimal price = (isTaxIncludingPricing ? soLineItemRec.Price_When_Tax_Included__c : soLineItemRec.Kit_Price__c);
            		if(String.isBlank(claimLineItemRec.Id) || claimLineItemRec.Claimed_Qty__c != soLineItemRec.Qty_Needed__c || claimLineItemRec.Claimed_Price__c != price) {
            			claimLineItemRec.Approved_Qty__c = claimLineItemRec.Claimed_Qty__c = soLineItemRec.Qty_Needed__c;
            			claimLineItemRec.Approved_Price__c = claimLineItemRec.Claimed_Price__c = price;
            			
            			Decimal soLineItemRecTaxRate = 0;
			            for(Individual_Tax__c individualTaxItem: soLineItemRec.Individual_Taxes__r) {
			                soLineItemRecTaxRate += individualTaxItem.Tax_Rate__c;
			            }
			            claimLineItemRec.Tax__c = soLineItemRecTaxRate;
			            
			            Decimal totalPrice = (soLineItemRec.Kit_Price__c * claimLineItemRec.Approved_Qty__c);
			            TotalAmount += totalPrice;
			            TotalTaxamount += totalPrice * ((soLineItemRec.Tax__c != null) ? soLineItemRec.Tax__c : 0) / 100;
            		}
		            
		            claimLIListToUpsert.add(claimLineItemRec);
		        }
		        if(soRec.SO_Payment_Roles__r.size() > 0) {
		        	SO_Payment_Role__c soPaymentRoleRec = soRec.SO_Payment_Roles__r[0];
		        	soPaymentRoleRec.Total_Amount__c = TotalAmount;
		            soPaymentRoleRec.Tax_Amount__c = TotalTaxamount;
		            soPaymentRoleListToUpdate.add(soPaymentRoleRec);
		            //system.assert(false, soPaymentRoleRec);
		        }
	        }
	        if(claimLIListToUpsert.size() > 0) {
	        	if(AccessControl.ifObjectFieldIsCreateable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	        	if(AccessControl.ifObjectFieldIsUpdateable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	        	ClaimLineItemTriggerHelper.isUpdateSOLI = false;
	            upsert claimLIListToUpsert;
	            ClaimLineItemTriggerHelper.isUpdateSOLI = true;
	        }
	        
	        if(soPaymentRoleListToUpdate.size() > 0) {
	        	if(AccessControl.ifObjectFieldIsUpdateable('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	            update soPaymentRoleListToUpdate;
	        }
        }
    }
    
    /**
     * Name: beforeUpdateCalculation
     * Desc: before update operations
     * @param: 
     * @return: 
    **/
    public static void beforeUpdateCalculation() {
        if(isVOLIRecToChange) {
            upsertVOLineItem();
            isActivateQuoteCO = false;
        }
        insertCOLIs();
    }
    
    
    /**
     * Name: beforeDeleteCalculation
     * Desc: before update operations
     * @param: 
     * @return: 
    **/
    public static void beforeDeleteCalculation() {
        if(isTriggerExecuted) {
            return;
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Line_Item__c> soliList = [select Id, (select Id from CO_Line_Items__r), (Select Id, SO_Payment_Role__c from Claim_Line_Items__r), 
        		(select Id, Vendor_Order_Header__c, Vendor_Order_Header__r.Status__c from Vendor_Order_Line_Items__r) from Service_Order_Line_Item__c where Id IN: soliOldList];
        List<CO_Line_Item__c> coliListToDelete = new List<CO_Line_Item__c>();
        List<Claim_Line_Item__c> claimLIListToDelete = new List<Claim_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voliList = new List<Vendor_Order_Line_Item__c>();
        
        Set<Id> soPaymentRoleIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soliRec : soliList) {
            if(soliRec.CO_Line_Items__r != null && soliRec.CO_Line_Items__r.size() > 0) {
                coliListToDelete.add(soliRec.CO_Line_Items__r[0]);
            }
            if(soliRec.Claim_Line_Items__r != null && soliRec.Claim_Line_Items__r.size() > 0) {
            	//soPaymentRoleIdSet.add(soliRec.Claim_Line_Items__r[0].SO_Payment_Role__c);
                claimLIListToDelete.addAll(soliRec.Claim_Line_Items__r);
            }
            if(soliRec.Vendor_Order_Line_Items__r != null && soliRec.Vendor_Order_Line_Items__r.size() > 0) {
                voliList.add(soliRec.Vendor_Order_Line_Items__r[0]);
            }
        }
        
        if(coliListToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete coliListToDelete;
        }
        if(claimLIListToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            delete claimLIListToDelete;
        }
        if(soPaymentRoleIdSet.size() > 0) {
        	updateSOPaymentRoleTotal_Future(soPaymentRoleIdSet);
        }
        deleteVollis(voliList);
    }
    
    @future
    public static void updateSOPaymentRoleTotal_Future(Set<Id> soPaymentRoleIdSet) {
    	List<SO_Payment_Role__c>  soPaymentRoleRecList = [select Id, Total_Amount__c, Tax_Amount__c, RecordType.DeveloperName, (select Id, Approved_Qty__c, Approved_Price__c,
    														Tax__c, Variance_Qty__c, Variance_Amount__c, Total_Variance_Amount__c, Service_Order_Line_Item__r.Kit_Price__c
    														from Claim_Line_items__r) From SO_Payment_Role__c where Id IN: soPaymentRoleIdSet];
            
        CustomerOrderCtrl.UpdateSoPaymentTotal(soPaymentRoleRecList);
    }
    
    private static void deleteVollis(List<Vendor_Order_Line_Item__c> voliList) {
        List<Vendor_Order_Line_Item__c> voliListToDel = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voliListToUpdate = new List<Vendor_Order_Line_Item__c>();
        for(Vendor_Order_Line_Item__c voliRec : voliList) {
            if(voliRec.Vendor_Order_Header__c == null || voliRec.Vendor_Order_Header__r.Status__c == 'Open' 
                || voliRec.Vendor_Order_Header__r.Status__c == 'Locked') {
                    voliListToDel.add(voliRec);     
            } else {
                voliRec = convertIntoReuiqredForStock(voliRec);
                voliListToUpdate.add(voliRec);
            }
        }
        
        if(voliListToUpdate.size() > 0 && !isMoveLineItem) {
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            update voliListToUpdate;    
        }
        if(voliListToDel.size() > 0 && !isMoveLineItem) {
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            VendorOrderLineItemTriggerHelper.shouldTriggerRun = true;
            delete voliListToDel;
        }
    } 
    
    /**
     * Name: insertCOLIs
     * Desc: create Coli on create of Soli
     * @param: Set<Id> soliIds
     * @return: 
    **/
    public static void insertCOLIs() {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
        CO_Line_Item__c coli;
        Boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        for(Service_Order_Line_Item__c soli : soliNewList) {
            if(soli.Part__c != null || soli.Fee__c != null) {
                coli = new CO_Line_Item__c(Id = soli.CO_Line_Item__c);
                coli.Service_Order_Line_Item__c = soli.Id;
                coli.Part__c = soli.Part__c;
                coli.Fee__c = soli.Fee__c;
                coli.Deal__c = soli.Deal__c;
                coli.Qty__c = soli.Qty_Needed__c;
                coli.Kit_Header_Line_Item__c = soli.Kit_Header_Line_Item__c;
                coli.Fixed_Price__c = soli.Fixed_Price__c;
                coli.Is_In_Service_Order__c = true;
                coli.Related_Option_And_Fees__c = soli.Option_Fee__c;
                if(String.isNotBlank(soli.Option_Fee__c)) {
                    coli.Price__c = soli.Kit_Price__c;
                }
                if(soli.Qty_Needed__c > 0) {
                    coli.Qty_Committed__c = soli.Qty_Committed__c;
                }                
                if(soli.Service_Order_Kit_Header__c != null) {
                    coli.Price__c = (soli.Kit_Price__c != null ? soli.Kit_Price__c : 0);
                }
                coli.CO_Header__c = soli.CO_Header_Id__c;
                
                if(soli.Fee__c != null) {
                    if(soli.Is_Environmental_Fee__c || soli.Is_Linked_Fee__c || soli.Type__c == Constants.SHOP_SUPPLY) {
                        coli.Is_Environmental_Fee__c = soli.Is_Environmental_Fee__c;
                        coli.Is_Linked_Fee__c = soli.Is_Linked_Fee__c;
                        if(soli.Type__c == Constants.SHOP_SUPPLY) {
                            coli.Type__c = Constants.SHOP_SUPPLY;
                        }
                    }
                    if(IsTaxIncludingPricing) {
                        coli.Price_When_Tax_Included__c = soli.Price_When_Tax_Included__c;
                    } else {
                        coli.Price__c = soli.Kit_Price__c;
                    }
                }
                coliList.add(coli);
            }
        }
        if(coliList.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            upsert coliList;
            if(trigger.isInsert) {
                populateSOLIsField();
            } else if(trigger.IsUpdate) {
                populateSOLIsFieldBeforeUpdate();
            }
        }
        updateCOInvoiceItem(soliNewList);
    }
    
    private static void updateCOInvoiceItem(List<Service_Order_Line_Item__c> soliNewList) {
        List<Id> soHeaderIdList = new List<Id>();
        List<Id> coHeaderIdList = new List<Id>();
        for(Service_Order_Line_Item__c soliRec : soliNewList) {
            if(soliRec.Service_Order_Header__c != null) {
                soHeaderIdList.add(soliRec.Service_Order_Header__c);
                if(soliRec.CO_Header_Id__c != null) {
                    coHeaderIdList.add(soliRec.CO_Header_Id__c);
                }
            }
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Service_Order_Header__c> soHeaderList = [SELECT Id, CO_Header__c,Transaction_Type__r.Type__c, Deal__c, (select isActive__c, Is_Invoiceable__c,SO_Payment_Role__r.recordtype.developername from CO_Invoice_Items__r), 
                                                            (SELECT Qty_To_Order__c, Tax__c, Total__c, Part__c, Part__r.Non_Inventory_Part__c from Service_Order_Line_Items__r) 
                                                            FROM Service_Order_Header__c where Id IN : soHeaderIdList ];
        
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [SELECT Id, Invoice_Status__c, CO_Header__c from CO_Invoice_Header__c where CO_Header__c IN :coHeaderIdList AND Invoice_Status__c = 'Active'];
       
        Map<Id, CO_Invoice_Header__c> coHeaderIdToCOInvoiceHeaderRecMap = new Map<Id, CO_Invoice_Header__c>();
        for(CO_Invoice_Header__c coInvoiceHeaderRec : coInvoiceHeaderList) {
            coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec); 
        }
        Map<Id, CO_Invoice_Item__c> coInvoiceItemMap = new Map<Id,CO_Invoice_Item__c>();
        
        for(Service_Order_Header__c soHeaderRec : soHeaderList) {
            Boolean isInvoiceable = true;
            Decimal taxAmount = 0;
            for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
                if(soliRec.Part__c != null && !soliRec.Part__r.Non_Inventory_Part__c) {
                    if(soliNewMap.containsKey(soliRec.Id)){
                        if((soliNewMap.get(soliRec.Id).Qty_Needed__c - soliNewMap.get(soliRec.Id).Qty_Committed__c) > 0) {
                            isInvoiceable = false;
                        }
                    } else if(soliRec.Qty_To_Order__c > 0){
                        isInvoiceable = false;
                    }
                }
                //taxAmount += (soliRec.Total__c * soliRec.Tax__c) / 100;
            }
            /*if(soHeaderRec.Deal__c == null) {
            soHeaderRec.Tax_Amount__c = taxAmount;
            } else {
                soHeaderRec.Tax_Amount__c = 0;
            }*/
            
            CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c();
            if(soHeaderRec.Transaction_Type__r.Type__c == 'Third-Party') {
                Boolean isNewRecord = true;
                for(CO_Invoice_Item__c coInvoiceRec : soHeaderRec.CO_Invoice_Items__r) {
                    if(coInvoiceRec.SO_Payment_Role__c == null || coInvoiceRec.SO_Payment_Role__r.RecordType.DeveloperName == 'Third Party') {
                        isNewRecord = false;
                    }
                } 
                if(isNewRecord){
                    if(coHeaderIdToCOInvoiceHeaderRecMap.containsKey(soHeaderRec.CO_Header__c)) {
                        coInvoiceItem.CO_Invoice_Header__c = coHeaderIdToCOInvoiceHeaderRecMap.get(soHeaderRec.CO_Header__c).Id;
                    } else {
                        CO_Invoice_Header__c coInvoiceHeaderRec = COLineItemTriggerHelper.insertCOInvoiceHeader(soHeaderRec.CO_Header__c);
                        coInvoiceItem.CO_Invoice_Header__c = coInvoiceHeaderRec.Id;
                        coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec);
                    }
                    coInvoiceItem.isActive__c = true; 
                    coInvoiceItem.Is_Invoiceable__c = isInvoiceable;
                    coInvoiceItem.Service_Order_Header__c = soHeaderRec.Id;
                    coInvoiceItemMap.put(coInvoiceItem.Id, coInvoiceItem);
                }
                
            } else {
                if(soHeaderRec.CO_Invoice_Items__r.size() == 1) {
                    coInvoiceItem.Id = soHeaderRec.CO_Invoice_Items__r[0].Id;
                    coInvoiceItem.Is_Invoiceable__c = isInvoiceable;
                    coInvoiceItem.IsActive__c = true; 
                } else {
                    if(coHeaderIdToCOInvoiceHeaderRecMap.containsKey(soHeaderRec.CO_Header__c) ) {
                        coInvoiceItem.CO_Invoice_Header__c = coHeaderIdToCOInvoiceHeaderRecMap.get(soHeaderRec.CO_Header__c).Id;
                    } else {
                        CO_Invoice_Header__c coInvoiceHeaderRec = COLineItemTriggerHelper.insertCOInvoiceHeader(soHeaderRec.CO_Header__c);
                        coInvoiceItem.CO_Invoice_Header__c = coInvoiceHeaderRec.Id;
                        coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec);
                    }
                    coInvoiceItem.isActive__c = true; 
                    coInvoiceItem.Is_Invoiceable__c = IsInvoiceable;
                    coInvoiceItem.Service_Order_Header__c = soHeaderRec.Id;
                }
                coInvoiceItemMap.put(coInvoiceItem.Id, coInvoiceItem);
            }        
        }
        
        if(soHeaderList.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soHeaderList;
        }
        if(coInvoiceItemMap.size() > 0 ) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            upsert coInvoiceItemMap.values();
        } 
    }
    
    /**
     * Name: populateSOLIsFieldBeforeUpdate
     * Desc: update Soli based on Coli create operations
     * @param: Set<Id> soliIds
     * @return: 
    **/
    public static void populateSOLIsFieldBeforeUpdate() {
        List<Service_Order_Line_Item__c> soliList = [select CO_Line_Item__c, Service_Order_Kit_Header__c, Kit_Price__c, 
                                                        (Select Id, Tax__c, Qty_Committed__c, Price__c from CO_Line_Items__r) 
                                                        from Service_Order_Line_Item__c where Id in: soliNewList];
                                                    
        for(Service_Order_Line_Item__c soliRec : soliList) {
            if(soliRec.CO_Line_Items__r != null && soliRec.CO_Line_Items__r.size() > 0) {
                soliNewMap.get(soliRec.Id).CO_Line_Item__c = soliRec.CO_Line_Items__r[0].Id;
                soliNewMap.get(soliRec.Id).Qty_Committed__c = soliRec.CO_Line_Items__r[0].Qty_Committed__c;
                if(soliRec.Service_Order_Kit_Header__c == null) {
                	soliNewMap.get(soliRec.Id).Tax_Percent__c = (soliRec.CO_Line_Items__r[0].Tax__c != null) ? soliRec.CO_Line_Items__r[0].Tax__c : 0;
                    //soliNewMap.get(soliRec.Id).Kit_Price__c = soliRec.CO_Line_Items__r[0].Price__c;
                    //soliNewMap.get(soliRec.Id).Actual_Kit_Price__c = soliRec.CO_Line_Items__r[0].Price__c;
                }
                system.debug('$$$$$$$$$$'+soliNewMap);
            }
        }
    }
    
    /**
     * Name: populateSOLIsField
     * Desc: update Soli based on Coli create operations
     * @param: Set<Id> soliIds
     * @return: 
    **/
    public static void populateSOLIsField() {
        List<Service_Order_Line_Item__c> soliList = [select CO_Line_Item__c, Kit_Price__c, Service_Order_Kit_Header__c,Actual_Retail_Price__c,
                                                        (Select Id, Tax__c, Qty_Committed__c, Price__c, Actual_Retail_Price__c, Price_When_Tax_Included__c from CO_Line_Items__r) 
                                                        from Service_Order_Line_Item__c where Id in: soliNewList];
        
        Set<Id> coliIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soliRec : soliList) {
            if(soliRec.CO_Line_Items__r != null && soliRec.CO_Line_Items__r.size() > 0) {
                soliRec.CO_Line_Item__c = soliRec.CO_Line_Items__r[0].Id;
                soliRec.Qty_Committed__c = soliRec.CO_Line_Items__r[0].Qty_Committed__c;
                if(soliRec.Service_Order_Kit_Header__c == null) {
                	soliRec.Tax_Percent__c = (soliRec.CO_Line_Items__r[0].Tax__c != null) ? soliRec.CO_Line_Items__r[0].Tax__c : 0;
                    soliRec.Kit_Price__c = soliRec.CO_Line_Items__r[0].Price__c;
                    soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c; 
                    soliRec.Actual_Retail_Price__c = soliRec.CO_Line_Items__r[0].Actual_Retail_Price__c;
                    soliRec.Price_When_Tax_Included__c = soliRec.CO_Line_Items__r[0].Price_When_Tax_Included__c;
                }
                coliIdSet.add(soliRec.CO_Line_Items__r[0].Id);
            }
        }
        
        // To Populate Lookup of SOLI on Individual Tax Record that was missing on Hip cycle on some cases - Added by TK - 01/17/2017
        if(coliIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
            List<CO_Line_Item__c> coliList = [select Id, Service_Order_Line_Item__c, (select Service_Order_Line_Item__c from Individual_Taxes__r) from CO_Line_Item__c
                                                        where Id IN: coliIdSet];
            List<Individual_Tax__c> indiTaxListToUpdate = new List<Individual_Tax__c>();
            for(CO_Line_Item__c coliRec : coliList) {
                for(Individual_Tax__c indiTaxRec : coliRec.Individual_Taxes__r) {
                    if(String.isBlank(indiTaxRec.Service_Order_Line_Item__c)) {
                        indiTaxRec.Service_Order_Line_Item__c = coliRec.Service_Order_Line_Item__c;
                        indiTaxListToUpdate.add(indiTaxRec);
                    }
                }
            }
            if(indiTaxListToUpdate.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update indiTaxListToUpdate;
            }
        }
        
        if(soliList.size() > 0) {
            isTriggerExecuted = true;
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soliList;    
        }
    }
    
    /**
     * Name: processCOInvoiceItem
     * Desc: update CO Invoice Item Accoring to SOLI
     * @param: 
     * @return: 
    **/ 
    public static void processCOInvoiceItem() {
        List<Service_Order_Line_Item__c> soliList = [select Qty_To_Order__c, Service_Order_Header__c, Service_Order_Header__r.CO_Header__c from Service_Order_Line_Item__c where Id IN :soliOldList];
        
        List<Id> soHeaderIdList = new List<Id>();
        List<Id> coHeaderIdList = new List<Id>();
        
        for(Service_Order_Line_Item__c soliRec : soliList) {
            if(soliRec.Service_Order_Header__c != null) {
                soHeaderIdList.add(soliRec.Service_Order_Header__c);
                if(soliRec.Service_Order_Header__r.CO_Header__c != null) {
                    coHeaderIdList.add(soliRec.Service_Order_Header__r.CO_Header__c);
                }
            }
        }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        // Added By subhrant ticket 124
        List<Service_Order_Header__c> soHeaderList = [select Id, CO_Header__c, (select isActive__c, Is_Invoiceable__c,SO_Payment_Role__c, SO_Payment_Role__r.recordtype.developername from CO_Invoice_Items__r), 
                                                                    (select Qty_To_Order__c from Service_Order_Line_Items__r where Id NOT IN: soliList) 
                                                                    from Service_Order_Header__c where Id IN : soHeaderIdList];
        
        List<CO_Invoice_Item__c> coInvoiceItemList = new List<CO_Invoice_Item__c>();
        List<CO_Invoice_Item__c> coInvoiceItemListToDel = new List<CO_Invoice_Item__c>();
        
        for(Service_Order_Header__c soHeaderRec : soHeaderList) {
            Boolean IsInvoiceable = true;
            for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
                if(soliRec.Qty_To_Order__c > 0) {
                    IsInvoiceable = false;
                }
            }
            // Added By subhrant ticket 124
            CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c();
            if(soHeaderRec.Service_Order_Line_Items__r.size() == 0 && soHeaderRec.CO_Invoice_Items__r.size() > 0) {
                for(CO_Invoice_Item__c  coInvoiceRec  :  soHeaderRec.CO_Invoice_Items__r){
                        if( coInvoiceRec.SO_Payment_Role__r.recordtype.developername == 'Third Party' || coInvoiceRec.SO_Payment_Role__c == null)
                        coInvoiceItemListToDel.add(coInvoiceRec);
                }
                
            } else if(soHeaderRec.CO_Invoice_Items__r.size() == 1) {
                coInvoiceItem.Id = soHeaderList[0].CO_Invoice_Items__r[0].Id;
                coInvoiceItem.Is_Invoiceable__c = IsInvoiceable;
                coInvoiceItem.Service_Order_Header__c = soHeaderRec.Id;
                coInvoiceItemList.add(coInvoiceItem);
            } else{
            
            
            }
        }
        
        if(coInvoiceItemListToDel.size() > 0) {
            //if(AccessControl.ifObjectIsDeletable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
           // delete coInvoiceItemListToDel;
        }
        
        if(coInvoiceItemList.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update coInvoiceItemList;
        }
    }
    
    public static List<Service_Order_Line_Item__c> applyPriceLevel(List<Service_Order_Line_Item__c> soliListHavingSubletAndLabour) {
        Set<Id> labourIdSet = new Set<Id>();
        Set<Id> subletIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soliRec : soliListHavingSubletAndLabour) {
            labourIdSet.add(soliRec.Labour_Code__c);
            subletIdSet.add(soliRec.Sublet__c);
        }
        
        labourIdSet.remove(null);
        subletIdSet.remove(null);
        Map<Id, Labour_Code__c> labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>();
        Map<Id, Product__c> subletIdToSubletRecordMap = new Map<Id, Product__c>();
        if(labourIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Labour_Code__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            labourIdToLabourRecordMap = new Map<Id, Labour_Code__c>([select Rate__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c,
                                                                        Fixed_Rate__c
                                                                        from Labour_Code__c where Id IN: labourIdSet]);
        }
        if(subletIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Product__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            subletIdToSubletRecordMap = new Map<Id, Product__c>([select Price__c, Taxable__c, Applicable_Tax__c, Applicable_Tax__r.Rate__c
                                                                        from Product__c where Id IN: subletIdSet]);
        }
        return applyPriceLevel(soliListHavingSubletAndLabour, labourIdToLabourRecordMap, subletIdToSubletRecordMap);
    }
    
    public static List<Service_Order_Line_Item__c> applyPriceLevel(List<Service_Order_Line_Item__c> soliListHavingSubletAndLabour,
                Map<Id, Labour_Code__c> labourIdToLabourRecordMap, Map<Id, Product__c> subletIdToSubletRecordMap) {
        
        Set<Id> soHeaderIdSet = new Set<Id>();
        Boolean isDealItemExists = false;
        for(Service_Order_Line_Item__c soliRec : soliListHavingSubletAndLabour) {
            soHeaderIdSet.add(soliRec.Service_Order_Header__c);
            if(String.isNotBlank(soliRec.Deal__c)) {
                isDealItemExists = true;
            }
        }
        List<Price_Level__c> defaultPriceLevel;
        if(isDealItemExists) {
            defaultPriceLevel = PriceLevelService.getInternalDefaultPriceLevel();
            if(defaultPriceLevel == null || defaultPriceLevel.size() == 0) {
                defaultPriceLevel = PriceLevelService.getDefaultPriceLevel();
            }
        }
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<Id, Service_Order_Header__c> soHeaderIdToSOHeaderRecMap = 
                    new Map<Id, Service_Order_Header__c>([select CO_Header__c, CO_Header__r.Discount_Markup_From_Prive_Level__c, CO_Header__r.Part_Price_Base_From_Price_Level__c,
                                                           CO_Header__r.Labour_Rate_From_Price_Level__c, Job_Type__c, CO_Header__r.CO_Type__c,
                                                           Provider__c, Provider_Part_Price_Base__c, Provider_Discount_Markup__c, Provider_Labour_Rate__c
                                                           from Service_Order_Header__c Where Id IN : soHeaderIdSet]);
        
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        for(Service_Order_Line_Item__c soliRec : soliListHavingSubletAndLabour) {
            Decimal discount;
            Decimal laborRate;
            String partPriceBase;
            if(String.isNotBlank(soliRec.Deal__c) || String.isNotBlank(soliRec.Deal_Item__c)) {
                if(defaultPriceLevel != null && defaultPriceLevel.size() > 0) {
                    discount = defaultPriceLevel[0].Discount_Markup__c; 
                    partPriceBase = defaultPriceLevel[0].Part_Price_Base__c; 
                    laborRate = defaultPriceLevel[0].Labour_Rate__c;
                }
            } else if(soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).Provider__c != null || 
                (soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).Job_Type__c == 'Internal' && 
                soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).CO_Header__r.CO_Type__c != 'Internal Service')) {
                discount = soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).Provider_Discount_Markup__c;
                partPriceBase = soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).Provider_Part_Price_Base__c;
                laborRate = soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).Provider_Labour_Rate__c;
            } else {
                discount = soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).CO_Header__r.Discount_Markup_From_Prive_Level__c;
                partPriceBase = soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).CO_Header__r.Part_Price_Base_From_Price_Level__c;
                laborRate = soHeaderIdToSOHeaderRecMap.get(soliRec.Service_Order_Header__c).CO_Header__r.Labour_Rate_From_Price_Level__c;
            }
            
            Decimal price;
            Decimal appTaxRate;
            if(soliRec.Labour_Code__c != null) {
                if(labourIdToLabourRecordMap.get(soliRec.Labour_Code__c).Fixed_Rate__c) {
                    price = labourIdToLabourRecordMap.get(soliRec.Labour_Code__c).Rate__c;
                } else {
                    if(laborRate == null || laborRate == 0) {
                        price = labourIdToLabourRecordMap.get(soliRec.Labour_Code__c).Rate__c;
                    } else {
                        price = laborRate;
                    }
                }
                appTaxRate = labourIdToLabourRecordMap.get(soliRec.Labour_Code__c).Applicable_Tax__r.Rate__c;
                soliRec.Actual_Retail_Price__c = price;
            } else if(soliRec.Sublet__c != null) {
                price = subletIdToSubletRecordMap.get(soliRec.Sublet__c).Price__c;
                appTaxRate = subletIdToSubletRecordMap.get(soliRec.Sublet__c).Applicable_Tax__r.Rate__c;
            }
            
            if(isTaxIncludingPricing && soliRec.Service_Order_Kit_Header__c == null) {
                if(appTaxRate == null || appTaxRate == -100) { // To handle divide by zero error
                    appTaxRate = 0;
                }
                Decimal preTaxPricing = (price / (1 + (appTaxRate / 100))).setScale(2, RoundingMode.HALF_UP);
                soliRec.Kit_Price__c = preTaxPricing;    
            } else {
                soliRec.Kit_Price__c = price;
            }
            soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c;
        }
        return soliListHavingSubletAndLabour;
    }
    
    public static void applySalesTax(List<Service_Order_Line_Item__c> soliListHavingLabourAndSublet) {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Tax_Exemption__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Service_Order_Line_Item__c> soLineItemList = [SELECT Service_Order_Header__c, Service_Order_Header__r.Job_Type__c, Service_Order_Header__r.CO_Header__r.Customer__c, Service_Order_Header__r.CO_Header__r.CO_Type__c,
                                                                Fee__c, Fee__r.Applicable_Tax__c, Fee__r.Applicable_Tax__r.Rate__c, Kit_Price__c, Service_Order_Header__r.Provider__c,
                                                                Labour_Code__c, Labour_Code__r.Applicable_Tax__c, Labour_Code__r.Applicable_Tax__r.Rate__c, Deal__c,
                                                                Sublet__c, Sublet__r.Applicable_Tax__c, Sublet__r.Applicable_Tax__r.Rate__c
                                                            FROM Service_Order_Line_Item__c where Id IN: soliListHavingLabourAndSublet];
        
        Map<Id, Set<Id>> coHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> soHeaderIdToSalesTaxItemIdsMap = new Map<Id, Set<Id>>();
        
        for(Service_Order_Line_Item__c soliRec : soLineItemList) {
            if(soliRec.Service_Order_Header__c != null) {
                soHeaderIdToSalesTaxItemIdsMap.put(soliRec.Service_Order_Header__c, null);
            }
            if(soliRec.Service_Order_Header__r.CO_Header__c != null) {
                coHeaderIdToSalesTaxItemIdsMap.put(soliRec.Service_Order_Header__r.CO_Header__c, null);
            }
            
        }
        // Get list of Tax Exemptions for given customer/provider ids
        List<Tax_Exemption__c> taxExemptionsList = [SELECT CO_Header__r.Customer__c, Service_Order_Header__r.Provider__c, Sales_Tax_Item__r.Rate__c from Tax_Exemption__c where (CO_Header__c IN: coHeaderIdToSalesTaxItemIdsMap.keySet() OR Service_Order_Header__c IN: soHeaderIdToSalesTaxItemIdsMap.keySet())];

        for(Id coHeaderId : coHeaderIdToSalesTaxItemIdsMap.keySet()) {
            Set<Id> salesTaxItemIdSet = new Set<Id>();
            for(Tax_Exemption__c taxExemptionRec : taxExemptionsList) {
                if(taxExemptionRec.CO_Header__c == coHeaderId) {
                    salesTaxItemIdSet.add(taxExemptionRec.Sales_Tax_Item__c);
                }
            }
            coHeaderIdToSalesTaxItemIdsMap.put(coHeaderId, salesTaxItemIdSet);
        }
        for(Id soHeaderId : soHeaderIdToSalesTaxItemIdsMap.keySet()) {
            Set<Id> salesTaxItemIdSet = new Set<Id>();
            for(Tax_Exemption__c taxExemptionRec : taxExemptionsList) {
                if(taxExemptionRec.Service_Order_Header__c == soHeaderId) {
                    salesTaxItemIdSet.add(taxExemptionRec.Sales_Tax_Item__c);
                }
            }
            soHeaderIdToSalesTaxItemIdsMap.put(soHeaderId, salesTaxItemIdSet);
        }
        
        // Entity Tax Rate
        Set<Id> salesTaxIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soliRec : soLineItemList) {
            String defaultSalesTaxId_InInternalCO;
            if(soliRec.Service_Order_Header__r.Job_Type__c == 'Internal' || soliRec.Service_Order_Header__r.Job_Type__c == 'Deal') {
                defaultSalesTaxId_InInternalCO = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
                if(String.isNotBlank(defaultSalesTaxId_InInternalCO)) {
                    salesTaxIdSet.add(defaultSalesTaxId_InInternalCO);
                }
            }
            if(soliRec.Labour_Code__r.Applicable_Tax__c != null) {
                salesTaxIdSet.add(soliRec.Labour_Code__r.Applicable_Tax__c);
            } 
            if(soliRec.Sublet__r.Applicable_Tax__c != null) {
                salesTaxIdSet.add(soliRec.Sublet__r.Applicable_Tax__c);
            } 
        }
        salesTaxIdSet.remove(null);
        
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Applicable_Taxes__c> applicableTaxList = new List<Applicable_Taxes__c>();
        if(salesTaxIdSet.size() > 0) {
            applicableTaxList = [SELECT Sales_Tax_Item__c, Sales_Tax__c, Sales_Tax_Item__r.Tax_Parts__c, Sales_Tax_Item__r.Name__c, 
                                    Sales_Tax_Item__r.Rate__c 
                                    from Applicable_Taxes__c WHERE Sales_Tax__c IN : salesTaxIdSet];
        }
        
        
        Map<Id, List<Applicable_Taxes__c>> salesTaxIdToAppTaxRecordsMap = new Map<Id, List<Applicable_Taxes__c>>();
        
        for(Applicable_Taxes__c appTax : applicableTaxList) {
            List<Applicable_Taxes__c> appTaxRecordList = new List<Applicable_Taxes__c>();
            if(salesTaxIdToAppTaxRecordsMap.containsKey(appTax.Sales_Tax__c)) {
                appTaxRecordList = salesTaxIdToAppTaxRecordsMap.get(appTax.Sales_Tax__c);
            } 
            appTaxRecordList.add(appTax);
            salesTaxIdToAppTaxRecordsMap.put(appTax.Sales_Tax__c, appTaxRecordList);
        }
        
        Map<Id, Decimal> salesTaxIdToTaxRateMap = new Map<Id, Decimal>();
        for(Id salesTaxId : salesTaxIdToAppTaxRecordsMap.keyset()) {
            Decimal salesTaxRate = 0;
            for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                salesTaxRate += appTax.Sales_Tax_Item__r.Rate__c;
            }
            salesTaxIdToTaxRateMap.put(salesTaxId, salesTaxRate);
        }
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        List<Service_Order_Line_Item__c> soliListToUpdate = new List<Service_Order_Line_Item__c>();
        List<Individual_Tax__c> individualTaxToInsert = new List<Individual_Tax__c>();
        for(Service_Order_Line_Item__c soliRec : soLineItemList) {
            String defaultSalesTaxId_InInternalCO;
            String salesTaxId;
            if(soliRec.Service_Order_Header__r.Job_Type__c == 'Internal' || soliRec.Service_Order_Header__r.Job_Type__c == 'Deal') {
                defaultSalesTaxId_InInternalCO = GeneralConfiguration.getDefaultSalesTaxOnInternalService();
            } 
            if(String.isNotBlank(defaultSalesTaxId_InInternalCO)) {
                salesTaxId = defaultSalesTaxId_InInternalCO;
            } else if(soliRec.Labour_Code__r.Applicable_Tax__c != null) {
                salesTaxId = soliRec.Labour_Code__r.Applicable_Tax__c;
            }  else if(soliRec.Sublet__r.Applicable_Tax__c != null) {
                salesTaxId = soliRec.Sublet__r.Applicable_Tax__c;
            }
             
            if(salesTaxId == null || soliRec.Service_Order_Header__r.Job_Type__c == 'Deal') {
                if(isTaxIncludingPricing && soliRec.Kit_Price__c != null) {
                    soliRec.Price_When_Tax_Included__c = soliRec.Kit_Price__c;
                    soliListToUpdate.add(soliRec);
                }
                continue;
            }
            
            Decimal exemptionRate = 0;
            if(salesTaxIdToAppTaxRecordsMap.containsKey(salesTaxId)) {
                for(Applicable_Taxes__c appTax : salesTaxIdToAppTaxRecordsMap.get(salesTaxId)) {
                    if(soliRec.Service_Order_Header__r.Provider__c != null && 
                            soHeaderIdToSalesTaxItemIdsMap.containsKey(soliRec.Service_Order_Header__c) &&
                            soHeaderIdToSalesTaxItemIdsMap.get(soliRec.Service_Order_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                        
                    } else if(soliRec.Service_Order_Header__r.Job_Type__c != 'Internal' && soliRec.Service_Order_Header__r.Provider__c == null && soliRec.Service_Order_Header__r.CO_Header__r.Customer__c != null 
                        && coHeaderIdToSalesTaxItemIdsMap.containsKey(soliRec.Service_Order_Header__r.CO_Header__c) 
                        && coHeaderIdToSalesTaxItemIdsMap.get(soliRec.Service_Order_Header__r.CO_Header__c).contains(appTax.Sales_Tax_Item__c)) {
                        exemptionRate += appTax.Sales_Tax_Item__r.Rate__c;
                    } else if(soliRec.Service_Order_Header__r.CO_Header__r.Customer__c != null || soliRec.Service_Order_Header__r.CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE){
                        if(soliRec.Deal__c == null) {
                            Individual_Tax__c individualTaxRec = new Individual_Tax__c();
                            individualTaxRec.Service_Order_Line_Item__c = soliRec.Id;
                            individualTaxRec.Sales_Tax_Item_Name__c = appTax.Sales_Tax_Item__r.Name__c;
                            individualTaxRec.Tax_Rate__c = appTax.Sales_Tax_Item__r.Rate__c;
                            individualTaxToInsert.add(individualTaxRec);
                        }
                    }
                } 
            }
            Decimal rate = 0;
            if(String.isNotBlank(defaultSalesTaxId_InInternalCO) && salesTaxIdToTaxRateMap.containsKey(defaultSalesTaxId_InInternalCO)) {
                rate = salesTaxIdToTaxRateMap.get(defaultSalesTaxId_InInternalCO);
            } else if(salesTaxIdToTaxRateMap.containsKey(salesTaxId)) {
                rate = salesTaxIdToTaxRateMap.get(salesTaxId);
            }
            /*if(isTaxIncludingPricing && soliRec.Labour_Code__c != null) {
                Decimal backTrackRate = rate;
                if(soliRec.Service_Order_Header__r.CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE || soliRec.Service_Order_Header__r.Job_Type__c == 'Internal') {
                    if(soliRec.Labour_Code__r.Applicable_Tax__c != null && salesTaxIdToTaxRateMap.containsKey(soliRec.Labour_Code__r.Applicable_Tax__c)) {
                        backTrackRate = salesTaxIdToTaxRateMap.get(soliRec.Labour_Code__r.Applicable_Tax__c);
                    }
                }
                soliRec.Kit_Price__c = (soliRec.Kit_Price__c / (1 + (backTrackRate / 100))).setScale(2, RoundingMode.HALF_UP);
                soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c;
            } else if(isTaxIncludingPricing && soliRec.Sublet__c != null) {
                Decimal backTrackRate = rate;
                if(soliRec.Service_Order_Header__r.CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE || soliRec.Service_Order_Header__r.Job_Type__c == 'Internal') {
                    if(soliRec.Sublet__r.Applicable_Tax__c != null && salesTaxIdToTaxRateMap.containsKey(soliRec.Sublet__r.Applicable_Tax__c)) {
                        backTrackRate = salesTaxIdToTaxRateMap.get(soliRec.Sublet__r.Applicable_Tax__c);
                    }
                }
                soliRec.Kit_Price__c = (soliRec.Kit_Price__c / (1 + (backTrackRate / 100))).setScale(2, RoundingMode.HALF_UP);
                soliRec.Actual_Kit_Price__c = soliRec.Kit_Price__c;
            }*/
            if(soliRec.Deal__c != null) {
                soliRec.Tax_Percent__c = 0;
            } else {
                soliRec.Tax_Percent__c = rate - exemptionRate;
            }
            
            if(isTaxIncludingPricing) {
                if(soliRec.Kit_Price__c != null) {
                    soliRec.Price_When_Tax_Included__c = (soliRec.Kit_Price__c + (soliRec.Kit_Price__c * soliRec.Tax_Percent__c / 100).setScale(2, RoundingMode.HALF_UP));
                }
            }
            
            soliListToUpdate.add(soliRec);
        }
        
        if(individualTaxToInsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            insert individualTaxToInsert;
        }
        
        if(soliListToUpdate.size() > 0) {
            if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            update soliListToUpdate;
        }
    }
    
    private static void populateDescription(Map<Id, Labour_Code__c> labourIdToLabourRecordMap, Map<Id, Product__c> subletIdToSubletRecordMap) {
        Set<Id> partIdSet = new Set<Id>();
        Set<Id> feeIdSet = new Set<Id>();
        
        for(Service_Order_Line_Item__c soliRec : soliNewList) {
            if(soliRec.Part__c != null) {
                partIdSet.add(soliRec.Part__c);
            } else if(soliRec.Fee__c != null) {
                feeIdSet.add(soliRec.Fee__c);
            }
        }
        
        Map<Id, Part__c> partIdToPartRecordMap = new Map<Id, Part__c>();
        Map<Id, Fee__c> feeIdToFeeRecordMap = new Map<Id, Fee__c>();
        if(partIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            partIdToPartRecordMap = new Map<Id, Part__c>([select Part_Number__c, Description__c, Applicable_Tax__c from Part__c where Id IN: partIdSet]); 
        }
        
        if(feeIdSet.size() > 0) {
            if(AccessControl.ifObjectFieldIsAccessible('Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            feeIdToFeeRecordMap = new Map<Id, Fee__c>([select Code__c, Description__c, Applicable_Tax__c from Fee__c where Id IN: feeIdSet]); 
        }
        
        // Populated Applicable Tax Lookup while inserting records.
        for(Service_Order_Line_Item__c soliRec : soliNewList) {
            if(soliRec.Part__c != null && partIdToPartRecordMap.containsKey(soliRec.Part__c)) {
                if(String.isBlank(soliRec.Item_Code__c) && String.isBlank(soliRec.Item_Description__c) && soliRec.Service_Order_Kit_Header__c == null) {
                    soliRec.Item_Code__c = partIdToPartRecordMap.get(soliRec.Part__c).Part_Number__c;
                    soliRec.Item_Description__c = partIdToPartRecordMap.get(soliRec.Part__c).Description__c;
                }
                soliRec.Applicable_Tax__c = partIdToPartRecordMap.get(soliRec.Part__c).Applicable_Tax__c;
            } else if(soliRec.Fee__c != null && feeIdToFeeRecordMap.containsKey(soliRec.Fee__c)) {
                if(String.isBlank(soliRec.Item_Code__c) && String.isBlank(soliRec.Item_Description__c) && soliRec.Service_Order_Kit_Header__c == null) {
                    soliRec.Item_Code__c = feeIdToFeeRecordMap.get(soliRec.Fee__c).Code__c;
                    soliRec.Item_Description__c = feeIdToFeeRecordMap.get(soliRec.Fee__c).Description__c;
                }
                soliRec.Applicable_Tax__c = feeIdToFeeRecordMap.get(soliRec.Fee__c).Applicable_Tax__c;
            } else if(soliRec.Labour_Code__c != null && labourIdToLabourRecordMap.containsKey(soliRec.Labour_Code__c)) {
                if(String.isBlank(soliRec.Item_Code__c) && String.isBlank(soliRec.Item_Description__c) && soliRec.Service_Order_Kit_Header__c == null) {
                    soliRec.Item_Code__c = labourIdToLabourRecordMap.get(soliRec.Labour_Code__c).Code__c;
                    soliRec.Item_Description__c = labourIdToLabourRecordMap.get(soliRec.Labour_Code__c).Description__c;
                }
                soliRec.Applicable_Tax__c = labourIdToLabourRecordMap.get(soliRec.Labour_Code__c).Applicable_Tax__c;
            } else if(soliRec.Sublet__c != null && subletIdToSubletRecordMap.containsKey(soliRec.Sublet__c)) {
                if(String.isBlank(soliRec.Item_Code__c) && String.isBlank(soliRec.Item_Description__c) && soliRec.Service_Order_Kit_Header__c == null) {
                    soliRec.Item_Code__c = subletIdToSubletRecordMap.get(soliRec.Sublet__c).Code__c;
                    soliRec.Item_Description__c = subletIdToSubletRecordMap.get(soliRec.Sublet__c).Description__c;
                }
                soliRec.Applicable_Tax__c = subletIdToSubletRecordMap.get(soliRec.Sublet__c).Applicable_Tax__c;
            }
        }
    }
    
    public static void populateIndividualTax(String soHeaderId) {
        calculateTotals(new Set<Id>{soHeaderId});
    }
    
    public static void populateIndividualTax() {
        List<Service_Order_Line_Item__c> soliList = Trigger.isDelete ? soliOldList : soliNewList;
        Set<Id> soHeaderIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soliRec : soliList) {
            soHeaderIdSet.add(soliRec.Service_Order_Header__c);
        }
        soHeaderIdSet.remove(null);
        
        calculateTotals(soHeaderIdSet);
    } 
    
    private static void calculateTotals(Set<Id> soHeaderIdSet) {
        List<Service_Order_Header__c> soHeaderList = [select CO_Header__c, Total__c, Deal__c, (select Qty_Needed__c, Kit_Price__c, Fee__c, Part__c, Actual_Retail_Price__c, Price_When_Tax_Included__c,
                                                                        Tax_Percent__c, CO_Line_Item__r.Closed_CO_Invoice_link__c, Labour_Code__c, Sublet__c, Type__c from Service_Order_Line_Items__r)
                                                          FROM Service_Order_Header__c where Id IN: soHeaderIdSet];
        Decimal subtotal;
        Decimal taxAmount;
        Decimal partTotal = 0;
        Decimal labourTotal = 0;
        Decimal feeTotal = 0;
        Decimal shopSuppliesTotal = 0;
        Decimal subletTotal = 0;
        Decimal totalDiscount = 0;
        boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        List<String> coHeaderIdList = new List<String>();
        for(Service_Order_Header__c soHeaderRec : soHeaderList) {
            partTotal = 0;
            labourTotal = 0;
            feeTotal = 0;
            shopSuppliesTotal = 0;
            subletTotal = 0;
            totalDiscount = 0;
            
            for(Service_Order_Line_Item__c soli : soHeaderRec.Service_Order_Line_Items__r) {
                soli.Qty_Needed__c = (soli.Qty_Needed__c != null) ? soli.Qty_Needed__c : 0;
                soli.Kit_Price__c = (soli.Kit_Price__c != null) ? soli.Kit_Price__c : 0;
                soli.Actual_Retail_Price__c = (soli.Actual_Retail_Price__c == null) ? 0 : soli.Actual_Retail_Price__c;
                if(!isTaxIncludingPricing || String.isNotBlank(soHeaderRec.Deal__c)) {
                    if(soli.Fee__c != null) {
                        if(soli.Type__c == Constants.SHOP_SUPPLY) {
                            shopSuppliesTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                        } else {
                            feeTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    } else if(soli.Part__c != null) {
                        partTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(soli.Labour_Code__c != null) {
                        labourTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(soli.Sublet__c != null) {
                        subletTotal += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
                    }
                    
                    if((soli.Part__c != null || soli.Labour_Code__c != null) && soli.Qty_Needed__c > 0) {
                        totalDiscount += ((soli.Actual_Retail_Price__c - soli.Kit_Price__c) * soli.Qty_Needed__c);
                    }
                } else {
                    if(soli.Fee__c != null) {
                        if(soli.Type__c == Constants.SHOP_SUPPLY) {
                            shopSuppliesTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                        } else {
                            feeTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    } else if(soli.Part__c != null) {
                        partTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(soli.Labour_Code__c != null) {
                        labourTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(soli.Sublet__c != null) {
                        subletTotal += (soli.Qty_Needed__c * soli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    }
                    
                    if((soli.Part__c != null || soli.Labour_Code__c != null) && soli.Qty_Needed__c > 0) {
                        totalDiscount += ((soli.Actual_Retail_Price__c - soli.Price_When_Tax_Included__c) * soli.Qty_Needed__c);
                    }
                }
            }
            soHeaderRec.Total_Shop_Supplies__c = shopSuppliesTotal.setScale(2, RoundingMode.HALF_UP);
            soHeaderRec.Total_Fees__c = feeTotal.setScale(2, RoundingMode.HALF_UP);
            soHeaderRec.Total_Labor__c = labourTotal.setScale(2, RoundingMode.HALF_UP);
            soHeaderRec.Total_Parts__c = partTotal.setScale(2, RoundingMode.HALF_UP);
            soHeaderRec.Total_Sublet__c = subletTotal.setScale(2, RoundingMode.HALF_UP);
            soHeaderRec.Total__c = soHeaderRec.Total_Fees__c + soHeaderRec.Total_Labor__c + soHeaderRec.Total_Parts__c + soHeaderRec.Total_Sublet__c + 
                                             soHeaderRec.Total_Shop_Supplies__c;
            soHeaderRec.Total__c = soHeaderRec.Total__c.setScale(2, RoundingMode.HALF_UP);
            soHeaderRec.Total_Discount__c = totalDiscount;
            
            coHeaderIdList.add(soHeaderRec.CO_Header__c);
        }
        
        if(soHeaderList.size() > 0) {
            update soHeaderList;
        }
        
        // Update Total on CO Header
        if(coHeaderIdList.size() > 0) {  
            CO_Header__c tempCOHeaderRec = TaxCalculation.populateOrderTotal(coHeaderIdList[0], true);
        }
    }  
    private static Boolean entryConditionForChangingVOLI() {
        Boolean isValidEntry = false;
        for(Service_Order_Line_Item__c soLineItemRec : soliNewList) {
            if(soLineItemRec.CO_Status__c == Constants.CO_STATUS_QUOTE || PartTriggerHelper.isCoToQuoteAction) {
                isValidEntry = false;
                
            } else if(isActivateQuoteCO || (Trigger.isInsert && soLineItemRec.Sublet__c != null && soLineItemRec.Qty_Needed__c > soLineItemRec.Qty_Committed__c)) {
                isValidEntry = true;
            } else if(Trigger.isUpdate && soliNewMap.get(soLineItemRec.Id).Sublet__c != null
                        && (soliNewMap.get(soLineItemRec.Id).Qty_Needed__c != soliOldMap.get(soLineItemRec.Id).Qty_Needed__c ||
                        (soliNewMap.get(soLineItemRec.Id).Qty_Committed__c != soliOldMap.get(soLineItemRec.Id).Qty_Committed__c && 
                        (soliOldMap.get(soLineItemRec.Id).Qty_Committed__c == 0 || soliNewMap.get(soLineItemRec.Id).Qty_Committed__c != 0)))) {
                    isValidEntry = true;
                    if(!isVOLIInsertFromVRPage) {
                        isValidEntry = false;
                    }
            }
        }
        return isValidEntry;
    }
    
    public static void upsertVOLineItem() {
        
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        // Entry Condition
        if(!entryConditionForChangingVOLI()) {
            return;
        }
        Set<Id> subletIdSet = new Set<Id>();
        for(Service_Order_Line_Item__c soLineItemRec : soliNewList) {
            if(soLineItemRec.Sublet__c != null) {
                subletIdSet.add(soLineItemRec.Sublet__c);
            } 
        }
        
        Map<Id, Product__c> subletIdToSubletRecordMap = new Map<Id, Product__c>();
        if(subletIdSet.size() > 0) {
            subletIdToSubletRecordMap = new Map<Id, Product__c>([SELECT Code__c, Cost_Method__c, Cost__c, Applicable_Tax__c, 
                                                                        CreatedDate__c, Deductible__c, 
                                                                        Description__c, Price__c, Product_Unique_Name__c, Status__c, Vendor__r.Name
                                                                        from Product__c where Id IN : subletIdSet]);
        }
        
        List<Vendor_Order_Line_Item__c> voLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> submittedVOLineItemsToUpsert = new List<Vendor_Order_Line_Item__c>();
        List<Vendor_Order_Line_Item__c> voLineItemsToDelete = new List<Vendor_Order_Line_Item__c>();
        
        Map<Id, Vendor_Order_Line_Item__c> existingVOLineItemMap = 
                new Map<Id, Vendor_Order_Line_Item__c>([SELECT Id, Vendor_Order_Header__c, Vendor_Order_Header__r.Status__c, Vendor_Order_Line_Item_Group__c, 
                                                                Service_Order_Line_Item__c, Is_Received__c
                                                             FROM Vendor_Order_Line_Item__c WHERE Service_Order_Line_Item__c IN : soliNewList 
                                                                AND Is_Received__c = false]);

        Map<Id, Id> soLineItemIdToOpenVOLineItemIdMap = new Map<Id, Id>();
        Map<Id, Id> soLineItemIdToSubmittedVOLineItemIdMap = new Map<Id, Id>();
        for(Vendor_Order_Line_Item__c voLineItemRec : existingVOLineItemMap.values()) {
            if(voLineItemRec.Vendor_Order_Header__c == null || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Open' 
                        || voLineItemRec.Vendor_Order_Header__r.Status__c == 'Locked') {
                if(!soLineItemIdToOpenVOLineItemIdMap.containsKey(voLineItemRec.Service_Order_Line_Item__c)) {
                    soLineItemIdToOpenVOLineItemIdMap.put(voLineItemRec.Service_Order_Line_Item__c, voLineItemRec.Id);
                }
            } else {
                if(!soLineItemIdToSubmittedVOLineItemIdMap.containsKey(voLineItemRec.Service_Order_Line_Item__c)) {
                    soLineItemIdToSubmittedVOLineItemIdMap.put(voLineItemRec.Service_Order_Line_Item__c, voLineItemRec.Id);
                }
            }
        }
        Vendor_Order_Line_Item__c voLineItemRec;
        List<Service_Order_Line_Item__c> soLineItemListToUpdate = new List<Service_Order_Line_Item__c>();
        for(Service_Order_Line_Item__c soLineItemRec : soliNewList) {
            voLineItemRec = new Vendor_Order_Line_Item__c();
            if(soLineItemRec.Sublet__c != null && soLineItemRec.Qty_Needed__c > soLineItemRec.Qty_Committed__c) {
                voLineItemRec.CO_Header__c = soLineItemRec.CO_Header_Id__c;
                voLineItemRec.Service_Order_Line_Item__c = soLineItemRec.Id;
                voLineItemRec.Sublet__c = soLineItemRec.Sublet__c;
                voLineItemRec.Qty_Needed__c = soLineItemRec.Qty_Needed__c - soLineItemRec.Qty_Committed__c;
                voLineItemRec.Is_Service__c = true;
                
                if(subletIdToSubletRecordMap.containsKey(soLineItemRec.Sublet__c)) {
                	if(subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost_Method__c == 'Fixed Cost' && subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c != null){
	                    voLineItemRec.Line_Item_Cost__c = subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c.setScale(2, RoundingMode.HALF_UP);
	                } else if(subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost_Method__c == 'Percent Retail' && subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c != null) {
	                    voLineItemRec.Line_Item_Cost__c = ((soLineItemRec.Kit_Price__c *  subletIdToSubletRecordMap.get(voLineItemRec.Sublet__c).Cost__c)/100).setScale(2, RoundingMode.HALF_UP);
	                }
                }
                
                if(soLineItemIdToSubmittedVOLineItemIdMap.containsKey(soLineItemRec.Id)) {
                    voLineItemRec.Id = soLineItemIdToSubmittedVOLineItemIdMap.get(soLineItemRec.Id);
                    if(trigger.isUpdate) {
                        soLineItemRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                    } else if(trigger.isInsert) {
                        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Id = soLineItemRec.Id);
                        soliRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                        soLineItemListToUpdate.add(soliRec);
                    }
                    submittedVOLineItemsToUpsert.add(voLineItemRec);
                
                } else if(soLineItemIdToOpenVOLineItemIdMap.containsKey(soLineItemRec.Id)) {
                    voLineItemRec.Id = soLineItemIdToOpenVOLineItemIdMap.get(soLineItemRec.Id);
                    if(trigger.isUpdate) {
                        soLineItemRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                    } else if(trigger.isInsert) {
                        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Id = soLineItemRec.Id);
                        soliRec.Status__c = (existingVOLineItemMap.get(voLineItemRec.Id).Vendor_Order_Line_Item_Group__c == null) ?
                                                'Required' : 'Ordered';
                        soLineItemListToUpdate.add(soliRec);
                    }
                    voLineItemsToUpsert.add(voLineItemRec);
                }  else {
                    if(trigger.isUpdate) {
                        soLineItemRec.Status__c = 'Required';
                    } else if(trigger.isInsert) {
                        Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Id = soLineItemRec.Id);
                        soliRec.Status__c = 'Required';
                        soLineItemListToUpdate.add(soliRec);
                    }
                    voLineItemsToUpsert.add(voLineItemRec);
                }
            }
        }
        
        if(voLineItemsToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            VendorOrderLineItemTriggerHelper.isUpdateQtyOnGroup = true;
            upsert voLineItemsToUpsert;
        }
        
        if(submittedVOLineItemsToUpsert.size() > 0) {
            if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            VendorOrderLineItemTriggerHelper.isUpdateQtyOnSubmittedGroup = true;
            upsert submittedVOLineItemsToUpsert;
        }
        
        if(voLineItemsToDelete.size() > 0) {
            if(AccessControl.ifObjectIsDeletable('Vendor_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
            VendorOrderLineItemTriggerHelper.shouldTriggerRun = true;
            delete voLineItemsToDelete;
        }
        if(soLineItemListToUpdate.size() > 0) {
            update soLineItemListToUpdate;
        }
    }
    
    private static Vendor_Order_Line_Item__c convertIntoReuiqredForStock(Vendor_Order_Line_Item__c voLineItemRec) {
        voLineItemRec.Is_Service__c = false;
        voLineItemRec.Is_required_For_Customer__c = false;
        voLineItemRec.Service_Order_Line_Item__c = null;
        voLineItemRec.CO_Header__c = null;
        voLineItemRec.Is_Excess__c = true;
        return voLineItemRec;
    }
    
    public static void populateTotalsOnSOHeader() {
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        populateIndividualTax();
    }
    
    public static void hoursLoggedCalculation(){
        if(!Test.isRunningTest() || !system.isFuture()) {
        	Set<Id> soHeaderIdSet = new Set<Id>();
	        for(Service_Order_Line_Item__c soliRec : (Trigger.isDelete ? soliOldList : soliNewList)) {
	            if(soliRec.Labour_Code__c != null && soliRec.Service_Order_Header__c != null) {
	                if(Trigger.isUpdate){
	                    if(soliRec.Qty_Needed__c != soliOldMap.get(soliRec.Id).Qty_Needed__c){
	                        soHeaderIdSet.add(soliRec.Service_Order_Header__c);
	                    }
	                    if(soliRec.Service_Order_Header__c != soliOldMap.get(soliRec.Id).Service_Order_Header__c ){
	                        soHeaderIdSet.add(soliRec.Service_Order_Header__c);
	                        soHeaderIdSet.add(soliOldMap.get(soliRec.Id).Service_Order_Header__c);
	                    }
	                }else{
	                    soHeaderIdSet.add(soliRec.Service_Order_Header__c);
	                } 
	            }
	        }
            hoursLoggedCalculation_future(soHeaderIdSet);
        }
    }

    @future
    public static void hoursLoggedCalculation_future(Set<Id> soHeaderIdSet) {
        CustomerOrderCtrl.calculateTechinicianHours(null, soHeaderIdSet);
    }
}