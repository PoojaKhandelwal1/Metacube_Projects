public with sharing class ServiceJobService {
    
    public static ServiceOrderWrapper.SOMasterData getServiceJobMasterData(String coHeaderId) {
    	
    	List<Account> providerList = SOQLUtil.getProviderList();
        List<Customer_Owned_Unit__c> couRecords = new List<Customer_Owned_Unit__c>();
        
    	List<CO_Header__c> coHeaderRec = SOQLUtil.getCOHeaderDetails(coHeaderId);
        if(coHeaderRec.size() > 0 && coHeaderRec[0].Customer__c != null) {
            String query;    
            query = 'SELECT '; 
            for(String field : CustomerOwnedUnit.fieldsList()){
                field = BPUtility.escapeSingleQuotes(field);
                query += field + ', ';
            }
            query = query.substring(0, query.length()-2);
            
            query += ' FROM Customer_Owned_Unit__c WHERE Account__c = \'' + coHeaderRec[0].Customer__c + '\' AND Status__c = \'Active\' ORDER BY LastModifiedDate DESC';
            if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            couRecords = Database.query(query);
        }
        List<Transaction_Type__c> ttList = SOQLUtil.getTransactionTypesWithProvider(new List<Id>());
        ttList = ServiceJobTypeService.sortJobTypes(ttList);
        ServiceOrderWrapper.SOMasterData masterDataObj = new ServiceOrderWrapper.SOMasterData(ttList, couRecords, providerList);
        return masterDataObj;
    }
    
    public static void deleteDeductibleRecord(String deductibleId) {
    	List<SO_Payment_Role__c> soPaymentList = [Select Id,(Select Id From CO_Invoice_Items__r) From SO_Payment_Role__c where Id=:deductibleId];
    	if(soPaymentList.size() > 0) {
    		delete new List<SObject>{soPaymentList[0]};
    	} 
    }
    
    public static String saveDeductibleAmount(SOHeaderWrapper.Deductible soPaymentWrapperObj) {
        
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('SO_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(soPaymentWrapperObj.DeductibleId != null && soPaymentWrapperObj.DeductibleAmount == 0) {
        	deleteDeductibleRecord(soPaymentWrapperObj.DeductibleId);
        } else {
	        List<RecordType> deductibleRecordTypeIdList =  SOQLUtil.getRecordTypeId(Constants.NAMESPACE + 'SO_Payment_Role__c', 'Deductible');
	        String RecordTypeDeductible = deductibleRecordTypeIdList[0].Id;
	        Integer nullStatusDeductibleRec = 0;
	        Integer OwingStatusDeductibleRec = 0;
	         
	        List<SO_Payment_Role__c> soPaymentRoleRecList = SOQLUtil.getSOPaymentWrapperById(soPaymentWrapperObj.SoHeaderId, null);
	        for(SO_Payment_Role__c soPaymentRec: soPaymentRoleRecList ){
	            if(soPaymentRec.Deductible_Status__c == null && soPaymentRec.RecordTypeId == RecordTypeDeductible){
	                nullStatusDeductibleRec += 1;
	                break;
	            } else if(soPaymentRec.Deductible_Status__c == 'Owing' && soPaymentRec.RecordTypeId == RecordTypeDeductible){
	                OwingStatusDeductibleRec += 1;
	                break;
	            }
	        }
	        
	        List<CO_Invoice_Header__c> coInvoiceHeaderList = [Select Id  From CO_Invoice_Header__c where CO_Header__c =:soPaymentWrapperObj.CoHeaderId and Status__c = 'Active'];
	        SO_Payment_Role__c soPaymentRoleRec = new SO_Payment_Role__c();
	        soPaymentRoleRec.Total_Amount__c = soPaymentWrapperObj.DeductibleAmount;
	        soPaymentRoleRec.RecordTypeId =deductibleRecordTypeIdList[0].Id;
	        soPaymentRoleRec.Service_Order_Header__c = soPaymentWrapperObj.SoHeaderId;
	        String coInvoiceHeaderId = '';
	        if(nullStatusDeductibleRec > 0 && soPaymentWrapperObj.DeductibleStatus == null ){
	            soPaymentRoleRec.Id = soPaymentWrapperObj.DeductibleId;
	            update soPaymentRoleRec;
	        } else if((OwingStatusDeductibleRec > 0) && ((soPaymentWrapperObj.DeductibleStatus == 'Adjust') || (soPaymentWrapperObj.DeductibleStatus == 'Owing') )){
	            soPaymentRoleRec.Id = soPaymentWrapperObj.DeductibleId;  
	            if(soPaymentWrapperObj.DeductibleStatus == 'Adjust'){
	                soPaymentRoleRec.Deductible_Status__c = 'Owing';
	            }
	            update soPaymentRoleRec;
	            
	        } else {
	            if(soPaymentWrapperObj.DeductibleStatus == 'Adjust'){
	                soPaymentRoleRec.Deductible_Status__c = 'Owing';   
	            } else {
	                soPaymentRoleRec.Deductible_Status__c = soPaymentWrapperObj.DeductibleStatus;
	            }
	            insert soPaymentRoleRec;
	        }
	        return soPaymentRoleRec.Id;
	    }
        return null;
    }
    
    public static List<ServiceOrderWrapper.SOWrapper> getServiceJobDetails(String recordId, String gridName) {
    	try {
	    	List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
	        List<Service_Order_Kit_Header__c> soKitHeaderList = new List<Service_Order_Kit_Header__c>();
	        Map<Id, List<Service_Order_Line_Item__c>> soHeaderIdToSOLIListMap = new Map<Id, List<Service_Order_Line_Item__c>>();
	        
	        String objectName = (Id.valueOf(recordId)).getSObjectType().getDescribe().getName();
	        
	        if(gridName == null || gridName.contains('soHeader')) {
	            if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
	                soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'CO_Header__c' => recordId});
	            } else if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
	                soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => recordId});
	            }
	        }
	        
	        Map<Id, List<Service_Order_Kit_Header__c>> soHeaderIdToSOKIListMap = new Map<Id, List<Service_Order_Kit_Header__c>>();
	        Map<Id, Service_Order_Line_Item__c> soliIdToRecMap = new Map<Id, Service_Order_Line_Item__c>();
	        if(gridName == null || gridName.contains('Grid Items')) {
	            if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
	                soKitHeaderList = SOQLUtil.getSOKitHeaderByFieldName(new Map<String, String>{'Service_Order_Header__r.CO_Header__c' => recordId});
	                soliIdToRecMap = new Map<Id, Service_Order_Line_Item__c>([Select Id, 
                    	(Select Id, Variance__c from Claim_Line_Items__r where Is_Variance__c = false AND Variance__c != 0) 
                    	from Service_Order_Line_Item__c where Service_Order_Header__r.CO_Header__c =: recordId]);
	            } else if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
	                soKitHeaderList = SOQLUtil.getSOKitHeaderByFieldName(new Map<String, String>{'Service_Order_Header__c' => recordId});
	                soliIdToRecMap = new Map<Id, Service_Order_Line_Item__c>([Select Id, 
                    	(Select Id, Variance__c from Claim_Line_Items__r where Is_Variance__c = false AND Variance__c != 0) 
                    	from Service_Order_Line_Item__c where Service_Order_Header__c =: recordId]);
	            }
	            for(Service_Order_Kit_Header__c soKitHeaderRec : soKitHeaderList) {
	                List<Service_Order_Kit_Header__c> sokhList;
	                if(!soHeaderIdToSOKIListMap.containsKey(soKitHeaderRec.Service_Order_Header__c)) {
	                    sokhList = new List<Service_Order_Kit_Header__c>();
	                } else {
	                    sokhList = soHeaderIdToSOKIListMap.get(soKitHeaderRec.Service_Order_Header__c);
	                }
	                sokhList.add(soKitHeaderRec);
	                soHeaderIdToSOKIListMap.put(soKitHeaderRec.Service_Order_Header__c, sokhList);
	            }
	        }
	        
	        List<ServiceOrderWrapper.SOWrapper> soWrapperList = new List<ServiceOrderWrapper.SOWrapper>();
	        for(Service_Order_Header__c soRec : soHeaderList) {
	        	if(soHeaderIdToSOKIListMap.containsKey(soRec.Id)) {
					soWrapperList.add(new ServiceOrderWrapper.SOWrapper(soRec, soHeaderIdToSOKIListMap.get(soRec.Id)));
				} else {
					soWrapperList.add(new ServiceOrderWrapper.SOWrapper(soRec, new List<Service_Order_Kit_Header__c>()));
				}
	        }
	        
            for(ServiceOrderWrapper.SOWrapper soObj : soWrapperList) {
             	for(SOHeaderWrapper.SOKitHeader soGridObj : soObj.SOGridItems) {
             		for(SOHeaderWrapper.SOLineItem soliObj : soGridObj.SOLIList) {
             			if(soliIdToRecMap.containsKey(soliObj.Id) && soliIdToRecMap.get(soliObj.Id).Claim_Line_Items__r.size() > 0) {
			    			soliObj.IsVariance = true;
			    		}
             		}
             	}
             	
            }
	        return soWrapperList;
    	} catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static Map<String, List<CustomerApproval>> getCustomerApprovalList(String recordId) {
    	String objectName = (Id.valueOf(recordId)).getSObjectType().getDescribe().getName();
        List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
        
        if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
            soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'CO_Header__c' => recordId});
        } else if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
            soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => recordId});
        }
	        
    	Set<String> customerApprovalIdSet = new Set<String>();
        Map<String, Set<String>> soIdToCustomerApprovalIdSetMap = new Map<String, Set<String>>();
        for(Service_Order_Header__c soRec : soHeaderList) {
        	for(Service_Job_To_Customer_Approval__c junctionObjRec : soRec.Service_Jobs_To_Customer_Approvals__r) { 
        		if(!soIdToCustomerApprovalIdSetMap.containsKey(soRec.Id)) {
        			soIdToCustomerApprovalIdSetMap.put(soRec.Id, new Set<String>());
        		}
        		soIdToCustomerApprovalIdSetMap.get(soRec.Id).add(junctionObjRec.Customer_Approval__c);
        		customerApprovalIdSet.add(junctionObjRec.Customer_Approval__c);
        	}
        }
        
        Map<String, CustomerApproval__c> customerApprovalIdToRecMap = SOQLUtil.getCustomerApprovalsById(customerApprovalIdSet);
        Map<String, List<CustomerApproval>> soIdToCustomerApprovalRecListMap = new Map<String, List<CustomerApproval>>();
        for(String soId : soIdToCustomerApprovalIdSetMap.keySet()) {
        	for(String customerApprovalId : soIdToCustomerApprovalIdSetMap.get(soId)) {
        		if(!soIdToCustomerApprovalRecListMap.containsKey(soId)) {
        			soIdToCustomerApprovalRecListMap.put(soId, new List<CustomerApproval>());
        		}
        		soIdToCustomerApprovalRecListMap.get(soId).add(new CustomerApproval(customerApprovalIdToRecMap.get(customerApprovalId)));
        	}
        }
        
        return soIdToCustomerApprovalRecListMap;
    }
    
    public static String createServiceJobWithSpecificFields(String coHeaderId, String couId, List<String> concernList, Boolean isAddLinkedFee) {
    	try{
	    	if(AccessControl.ifObjectFieldIsAccessible('AggregateResult') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectFieldIsAccessible('Transaction_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        
	        coHeaderId = BPUtility.escapeSingleQuotes(coHeaderId);
	        List<CO_Header__c> coHeaderList = [Select CO_Type__c, Customer__c, Order_Status__c, Selling_Group__c,
	        		(select Id, Invoice_Status__c, CO_Header__c from CO_Invoice_Headers__r where Invoice_Status__c = 'Active'), 
	        		(select Name__c from Service_Order_Headers__r where Deal__c = null) from CO_Header__c where Id = :coHeaderId];
	        
	        if(coHeaderList.size() == 0) {
	        	return null;
	        }
	        Integer totalSO = coHeaderList[0].Service_Order_Headers__r.size();
	        
	        Service_Order_Header__c soHeaderToInsert = new Service_Order_Header__c();
	        Boolean isSoHeaderNameAlreadyExist = false;
	        String soHeaderName = 'Service Job ' + (totalSO + 1);
	        for(Service_Order_Header__c soHeaderRec : coHeaderList[0].Service_Order_Headers__r) {
	            if(soHeaderRec.Name__c == soHeaderName) {
	                isSoHeaderNameAlreadyExist = true;
	                break;
	            }
	        }
	        if(isSoHeaderNameAlreadyExist) {  
	            soHeaderToInsert.Name__c = 'Service Job ' + (totalSO + 2);
	        } else {
	            soHeaderToInsert.Name__c = 'Service Job ' + (totalSO + 1);
	        }
	        //soHeaderToInsert.Name__c = 'Service Job ' + (totalSO + 1);
	        soHeaderToInsert.CO_Header__c = coHeaderId;
	        soHeaderToInsert.Status__c = 'New';
	        soHeaderToInsert.Work_Status__c = 'New';
	        if(concernList != null && concernList.size() > 0) {
	        	soHeaderToInsert.SO_Concern__c = '';
		        for(String concernStr : concernList) {
	                concernStr = (concernStr.contains('\n')) ? concernStr.replaceAll('\n', '') : concernStr;
	                soHeaderToInsert.SO_Concern__c += concernStr + '\n';
	            }
	        } 
            
	        if(coHeaderList.size() > 0){
	            soHeaderToInsert.SO_Type__c = coHeaderList[0].CO_Type__c;
	            String transactionType;
	            if(coHeaderList[0].CO_Type__c == 'Customer' && String.isNotBlank(coHeaderList[0].Order_Status__c) && (coHeaderList[0].Order_Status__c == 'Quote')) {
	                transactionType = 'Quote';
	                soHeaderToInsert.Work_Status__c = 'Estimate';
	            } else if(coHeaderList[0].CO_Type__c == 'Internal Service') {
	                transactionType = 'Stock Unit';
	                List<Category__c> categoryList = [select Id, Name, Default__c from Category__c where Type__c = 'Internal Expense' AND Default__c = true
	                                                                        AND Active__c = true];
			        if(categoryList.size() > 0) {
			        	soHeaderToInsert.Category__c = categoryList[0].Id;
			        }
	            } else {
	                transactionType = 'Customer';
	            }
	            
	            if(String.isNotBlank(transactionType)) {
	                List<Transaction_Type__c> transactionTypeList = [select Id from Transaction_Type__c where Type__c = :transactionType AND Default__c = true];
	                if(transactionTypeList.size() > 0) {
	                    soHeaderToInsert.Transaction_Type__c = transactionTypeList[0].Id;
	                }
	            }
	            //Check for Single Unit
	            if(String.isNotBlank(couId)) {
	            	soHeaderToInsert.Customer_Owned_Unit__c = couId;
	            } else {
	            	List<Account> customerList = [Select Id, (Select Id from Customer_Owned_Units__r WHERE Status__c = 'Active') from Account where Id =: coHeaderList[0].Customer__c];
		            if(customerList.size() > 0 && customerList[0].Customer_Owned_Units__r.size() == 1) {
		                soHeaderToInsert.Customer_Owned_Unit__c = customerList[0].Customer_Owned_Units__r[0].Id;
		            }
	            }
	        }
	        insert soHeaderToInsert;
	        
	        if(soHeaderToInsert.Id != null) {
	        	
		        Map<Id, CO_Invoice_Header__c> coHeaderIdToCOInvoiceHeaderRecMap = new Map<Id, CO_Invoice_Header__c>();
		        for(CO_Invoice_Header__c coInvoiceHeaderRec : coHeaderList[0].CO_Invoice_Headers__r) {
		            coHeaderIdToCOInvoiceHeaderRecMap.put(coInvoiceHeaderRec.CO_Header__c, coInvoiceHeaderRec); 
		        }
		        
	            CO_Invoice_Item__c coInvoiceItem = new CO_Invoice_Item__c();
	            coInvoiceItem.Is_Invoiceable__c = false;
	            coInvoiceItem.isActive__c = false;
	            coInvoiceItem.Service_Order_Header__c = soHeaderToInsert.Id;
	            if(coHeaderIdToCOInvoiceHeaderRecMap.containsKey(coHeaderId) ) {
	                coInvoiceItem.CO_Invoice_Header__c = coHeaderIdToCOInvoiceHeaderRecMap.get(coHeaderId).Id;
	            } else { 
	                CO_Invoice_Header__c coInvoiceHeaderRec = COLineItemTriggerHelper.insertCOInvoiceHeader(coHeaderId);
	                coInvoiceItem.CO_Invoice_Header__c = coInvoiceHeaderRec.Id;
	                coHeaderIdToCOInvoiceHeaderRecMap.put(coHeaderId, coInvoiceHeaderRec);
	            }
	            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	            insert coInvoiceItem;
	        }   
	        
	        if(isAddLinkedFee) {
	        	List<SObject> sObjectListToInsert = COService.addLinkedFee(soHeaderToInsert.Id, null, 'Service Job');
		        if(sObjectListToInsert != null) {
		            insert sObjectListToInsert;
		        }
	        }
	        
	        return soHeaderToInsert.Id;
    	} catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    }
    
    public static void createServiceJob(String coHeaderId) {
		createServiceJobWithSpecificFields(coHeaderId, null, null, true);
    }
    
    public static SO_KLI_Recalculation.Errorhandler error;
    public static String updateSOLIRec(String lineItemJSON, String soHeaderId) {
    	Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
    	
    	if(AccessControl.ifObjectFieldIsUpdateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

            SOHeaderWrapper.SOLineItem soHeaderObj = (SOHeaderWrapper.SOLineItem) System.JSON.deserialize(lineItemJSON, SOHeaderWrapper.SOLineItem.class);
            if(soHeaderObj.Id == null) {
            	return null;
                //return CustomerOrderCtrl_V2.getSOHeaderDetails(BPUtility.getEncodedString(soHeaderId), BPUtility.getEncodedString('soHeader,Grid Items'));
            } 
            
            error = SO_KLI_Recalculation.updateSOKitLineItem(soHeaderObj);
            if(error == null || error.ResponseCode == '200') {
                Service_Order_Line_Item__c soliToUpdate = new Service_Order_Line_Item__c();
                soliToUpdate.Id = soHeaderObj.Id;
                if(String.isNotBlank(soHeaderObj.Id) && soHeaderObj.IsSublet != null && soHeaderObj.IsSublet) {
                	List<Vendor_Order_Line_Item__c> subletVOLIList = [Select Id, Service_Order_Line_Item__r.Qty_Needed__c from Vendor_Order_Line_Item__c 
										where Service_Order_Line_Item__c =: soHeaderObj.Id AND Sublet__c != null 
										AND Vendor_Order_Line_Item_Group__c != null AND Vendor_Order_Header__r.Status__c != 'Open' AND 
										Vendor_Order_Header__r.Status__c != 'Locked'];
                	if(subletVOLIList.size() > 0 && subletVOLIList[0].Service_Order_Line_Item__r.Qty_Needed__c != soHeaderObj.QtyNeeded) {
                		throw new BlackpurlException('{"HasError" : true, "ErrorMsg" : "Can not update qty on ordered sublet"}');
                	}
                }
                soliToUpdate.Qty_Needed__c = soHeaderObj.QtyNeeded;
                if(soHeaderObj.IsFee || soHeaderObj.IsLabour || soHeaderObj.IsSublet) {
                    soliToUpdate.Item_Description__c = soHeaderObj.ItemDescription;
                }
                if(soHeaderObj.StockCommited > soHeaderObj.QtyNeeded) {
                    soliToUpdate.Qty_Committed__c = soHeaderObj.QtyNeeded;
                } else {  
                    soliToUpdate.Qty_Committed__c = soHeaderObj.StockCommited;
                }
                if(isTaxIncludingPricing && String.isBlank(soHeaderObj.DealId)) {
                    if(soHeaderObj.Tax == -100) {
                        soHeaderObj.Tax = 0;
                    }                    
                    soliToUpdate.Price_When_Tax_Included__c = soHeaderObj.KitPrice;
                    soliToUpdate.kit_Price__c = (soHeaderObj.KitPrice / (1 + soHeaderObj.Tax / 100 ));
                } else {
                    soliToUpdate.kit_Price__c = soHeaderObj.KitPrice;
                }
                
                List<Service_Order_Line_Item__c> soliList = [SELECT Service_Order_Header__r.Deal__c, Qty_Needed__c, Service_Order_Header__c,
                                                            Labour_Code__c, Labour_Code__r.Calculate_Supplies__c, Service_Order_Header__r.CO_Header__c 
                                                            FROM Service_Order_Line_Item__c WHERE Id =: soliToUpdate.Id];
                update soliToUpdate;
                
                if(soliList.size() > 0 && soliList[0].Labour_Code__c != null && soliList[0].Labour_Code__r.Calculate_Supplies__c) {
                    ShopSuppliesService.shopSuppliesCalculation(soliList[0].Service_Order_Header__c);
                }

                if(soliList.size() > 0) {
                    Decimal previousQty = soliList[0].Qty_Needed__c;               
                    if(String.isNotBlank(soliList[0].Service_Order_Header__r.Deal__c)) {
                        if(previousQty != soHeaderObj.QtyNeeded) {
                            CustomerOrderCtrl.createDealUnresolvedFulfillment(new List<String>{soliToUpdate.Id}, soHeaderObj.DealId, Constants.UNRESOLVED_FULFILLMENT_TYPE_UPDATED);
                        }
                        /*return CustomerOrderCtrl.getDealDetails(BPUtility.getEncodedString(soliList[0].Service_Order_Header__r.CO_Header__c), 
                                                                                            BPUtility.getEncodedString('dealUnresolvedFulfillmentSection'));*/
                    }
                }                
            }
        
        return null;
    }
    
    public static List<SOPaymentWrapper> getSoPaymentRoleById(String recId, String status) {
        List<SO_Payment_Role__c> soPaymentRoleRecList = SOQLUtil.getSOPaymentWrapperById(recId , status);
        List<SOPaymentWrapper> soPaymentRoleObjList = new List<SOPaymentWrapper>();
        for(SO_Payment_Role__c soPaymentRoleRec : soPaymentRoleRecList) {
            soPaymentRoleObjList.add(new SOPaymentWrapper(soPaymentRoleRec));
        }
        return soPaymentRoleObjList;
    }
    
    public static void splitSOKHItem(String lineItemId) {
    	try {
	    	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
	        if(AccessControl.ifObjectIsDeletable('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
	        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	
	        lineItemId = BPUtility.escapeSingleQuotes(lineItemId);
	        List<Service_Order_Kit_Header__c> sokhList = [select Id,
	                                                         (select Actual_Kit_Price__c, Kit_Price__c, Price_When_Tax_Included__c, Labour_Code__c, Fee__c, Part__c, Qty_Needed__c, Service_Order_Header__c from Service_Order_Line_Items__r)
	                                                         from Service_Order_Kit_Header__c where Id =: lineItemId];
	                                                             
	        List<Service_Order_Line_Item__c> soLineItemListToInsert = new List<Service_Order_Line_Item__c>();
	        List<Service_Order_Line_Item__c> soLineItemListToDelete = new List<Service_Order_Line_Item__c>();
	            
	        for(Service_Order_Kit_Header__c sokhRec : sokhList) {
	            for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
	                Service_Order_Line_Item__c newSOLIRec = new Service_Order_Line_Item__c();
	                newSOLIRec.Service_Order_Header__c = soliRec.Service_Order_Header__c;
	                
	                newSOLIRec.Labour_Code__c = soliRec.Labour_Code__c;
	                newSOLIRec.Fee__c = soliRec.Fee__c;
	                newSOLIRec.Part__c = soliRec.Part__c;
	                newSOLIRec.Qty_Needed__c = soliRec.Qty_Needed__c;
	                if(newSOLIRec.Labour_Code__c != null) {
	                    newSOLIRec.Kit_Price__c = soliRec.Actual_Kit_Price__c;
	                    newSOLIRec.Price_When_Tax_Included__c = soliRec.Price_When_Tax_Included__c;
	                    newSOLIRec.Actual_Kit_Price__c = soliRec.Actual_Kit_Price__c;
	                }
	                //CO_Line_Item__c newCOLIRec = coliRec.clone(false, true, false, false);
	                soLineItemListToInsert.add(newSOLIRec);
	                soLineItemListToDelete.add(soliRec);
	            }
	        }
	            
	        if(soLineItemListToDelete.size() > 0) {
	            delete soLineItemListToDelete;
	        }
	                                                         
	        if(sokhList.size() > 0) {
	            delete sokhList;
	        }
	        
	        if(soLineItemListToInsert.size() > 0) {
	            insert soLineItemListToInsert;
	        }
    	} catch(Exception e) {
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	} 
    }
    
    public static List<SOHeaderWrapper.HoursLogged> getHoursLogged(String soHeaderId) {
        try{
        	List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderId});

	        List<SOHeaderWrapper.HoursLogged> hoursLoggedList = new List<SOHeaderWrapper.HoursLogged>();
	        for(Hours_Logged__c hourLoggedRec : soHeaderRecList[0].Hours_Logged__r) {
	            hoursLoggedList.add(new SOHeaderWrapper.HoursLogged(hourLoggedRec));
	        }
	    
	        return hoursLoggedList; 
        }catch(Exception e) {
        	throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    /**
    * Method to load Category list based on category type
    **/
    public static ServiceOrderWrapper.SOMasterData getServiceJobCategories(Map<String, String> searchFields) {
        return new ServiceOrderWrapper.SOMasterData(SOQLUtil.getCategories(searchFields));
    }
    
    public static void refreshSOPricingAndTax(List<String> soHeaderIdList) {
    	List<Service_Order_Header__c> soList = [Select Id, Provider__c, Job_Type__c from Service_Order_Header__c where Id IN: soHeaderIdList AND Invoice_Number__c = null];
    	if(soList.size() > 0) {
    		SOTriggerHelper.updatePLFields(soList);
    		SOTriggerHelper.refreshTaxExemptions = true;
    		update soList;
    	}
    }
    
    public static void refreshSOLIPricingAndTax(String coHeaderId, String soHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<CO_Header__c> coHeaderList = [select Customer__c, Discount_Markup_From_Prive_Level__c, Part_Price_Base_From_Price_Level__c,
                                                (select Part__c, CO_Kit_Header__c, Kit_Header_Line_Item__c, Id, Deal__c, Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c, 
                                                Service_Order_Line_Item__r.Service_Order_Header__r.Provider__c, Service_Order_Line_Item__r.Service_Order_Header__r.Provider__r.Price_Level__r.Discount_Markup__c, 
                                                Service_Order_Line_Item__r.Service_Order_Header__r.Provider__r.Price_Level__r.Part_Price_Base__c from CO_Line_Items__r where 
                                                Invoice_Number__c = null AND CO_Kit_Header__c = null AND Service_Order_Line_Item__r.Service_Order_Kit_Header__c = null 
                                                AND Service_Order_Line_Item__r.Service_Order_Header__c =: soHeaderId) 
                                                from CO_Header__c where Id =: coHeaderId];
                                               // AND (Service_Order_Line_Item__r.Service_Order_Header__r.Job_Type__c != 'Internal' OR Service_Order_Line_Item__r.Service_Order_Header__r.CO_Header__r.CO_Type__c = 'Internal Service')
        COTriggerHelper.setPLforCOLIs(coHeaderList);
        COTriggerHelper.salesTaxCalculation(soHeaderId);
        COTriggerHelper.setPriceLevelAndSalesTaxForLabourInServiceOrder(soHeaderId);
        CustomerOrderCtrl_V2.isRefreshCOKit = true;
        SO_KLI_Recalculation.changePriceWhenCustomerIsChanged(new Set<Id>{soHeaderId}, coHeaderId);
    }
    
    public static String saveCustomerApproval(String customerApprovalObj, String soHeaderIds)  {
    	//try {
	        if(AccessControl.ifObjectFieldIsCreateable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	        if(AccessControl.ifObjectFieldIsUpdateable('CustomerApproval__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }

        	CustomerApproval custApprovalObj = (CustomerApproval)System.JSON.deserialize(customerApprovalObj, CustomerApproval.class);
        	
        	List<CustomerApproval__c> approvalListToUpsert = new List<CustomerApproval__c>();
			
			CustomerApproval__c custApprovalRec = new CustomerApproval__c();
			custApprovalRec.Status__c = 'Approved';
			
			custApprovalRec.ApprovalDate__c = date.today();
			
			custApprovalRec.ApprovalType__c = custApprovalObj.ApprovalType;
			custApprovalRec.ApprovalDetailJson__c = custApprovalObj.ApprovalDetailJson;
			approvalListToUpsert.add(custApprovalRec);
			 
    		insert approvalListToUpsert;
    		List<Service_Job_To_Customer_Approval__c> serviceJobToCustomerApprovalList = new List<Service_Job_To_Customer_Approval__c>();
    		List<String> soHeaderIdList = new List<String>();
			soHeaderIdList = soHeaderIds.split(',');
    		for(integer i=0; i < soHeaderIdList.size() ; i++){
    			Service_Job_To_Customer_Approval__c serviceJobToCustomerApproval = new Service_Job_To_Customer_Approval__c();
    			serviceJobToCustomerApproval.Service_Order_Header__c = soHeaderIdList[i];
    			serviceJobToCustomerApproval.Customer_Approval__c = approvalListToUpsert[0].Id;
    			serviceJobToCustomerApprovalList.add(serviceJobToCustomerApproval);
    		}
    		if(String.isNotBlank(custApprovalObj.signatureBlobValue)) {
    			List<String> base64 = new List<String>();
    			base64 = custApprovalObj.signatureBlobValue.split(',');
            	Blob actualdata = EncodingUtil.base64Decode(base64[1]);
    			List<Attachment> attachmentToBeInserted = new List<Attachment>();
				Attachment att = new Attachment(ParentId = approvalListToUpsert[0].Id, Body = actualdata);
	            att.Name = 'Customer Signature.png'; 
	            if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		        attachmentToBeInserted.add(att);
	    		if(attachmentToBeInserted.size() > 0) {
    			insert attachmentToBeInserted;
    			}
    		}
            
    		if(serviceJobToCustomerApprovalList.size() > 0) {
    			insert serviceJobToCustomerApprovalList;
    		}
    		  
    		
    		return 'Success';
    	//} catch (Exception e) {
    	//	throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	//}
    }
    
    public static String addMultiplePartsInServiceJob(List<COService.SearchPartDetailWrapper> partToInsertList, String soHeaderId) {
    	Map<String, Decimal> partIdTQtyToInsertMap = new Map<String, Decimal>();
		for(COService.SearchPartDetailWrapper partInfoObj : partToInsertList) {
    		partIdTQtyToInsertMap.put(partInfoObj.PartId, partInfoObj.Qty);
		}
    	Map<Id, Part__c> partIdToPartRecMap = new Map<Id, Part__c>([select Part_Number__c, Enviro_Fee__c, 
                                                                    Enviro_Fee_Code__c, 
                                                                    Enviro_Fee_Code__r.Code__c, 
                                                                    Enviro_Fee_Code__r.Description__c 
                                                                    from Part__c 
                                                                    where Id =: partIdTQtyToInsertMap.keySet()]);
        if(partIdToPartRecMap.keySet().size() == 0) {
            return null;
        }
            
    	List<Service_Order_Header__c> serviceOrderHeaderList = [Select Deal__c, Deal_Item__c, CO_Header__c from Service_Order_Header__c where Id = :soHeaderId];
        List<Service_Order_Line_Item__c> soliListToInsert = new List<Service_Order_Line_Item__c>();
        Service_Order_Line_Item__c relatedEnvFeeRec;
        Service_Order_Line_Item__c soliRec;
        
        for(COService.SearchPartDetailWrapper partInfoObj : partToInsertList) {
            soliRec = new Service_Order_Line_Item__c();
            soliRec.Service_Order_Header__c = soHeaderId;
            soliRec.Part__c = partInfoObj.PartId;
            soliRec.Qty_Needed__c = (partInfoObj.Qty != null && partInfoObj.Qty != 0) ? partInfoObj.Qty : 1;
            if(serviceOrderHeaderList.size() > 0) {
                soliRec.Deal__c = serviceOrderHeaderList[0].Deal__c;
                soliRec.Deal_Item__c = serviceOrderHeaderList[0].Deal_Item__c;
            }
            soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c == null) ? 0 : soliRec.Kit_Price__c;
            soliListToInsert.add(soliRec);
            if(partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee__c != null && partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee_Code__c != null) {
                relatedEnvFeeRec = new Service_Order_Line_Item__c();
                relatedEnvFeeRec = CustomerOrderCtrl.insertFeeInGrid(partIdToPartRecMap.get(partInfoObj.PartId).Enviro_Fee_Code__c, soHeaderId, true, partIdToPartRecMap.get(partInfoObj.PartId), 1);
                soliListToInsert.add(relatedEnvFeeRec);
            }  
        }
        insert soliListToInsert;
        Set<String> soliIdSet = new Set<String>();
        for(Service_Order_Line_Item__c solineItemRec : soliListToInsert) {
            soliIdSet.add(solineItemRec.Id);
        }
        CustomerOrderCtrl.createDealUnresolvedFulfillment(new List<String>(soliIdSet), serviceOrderHeaderList[0].Deal__c, Constants.UNRESOLVED_FULFILLMENT_TYPE_ADDED);
    
        return serviceOrderHeaderList[0].CO_Header__c;
    }
    
    public static Map<String, List<ProfitabilityWrapper.SectionProfitabilityWrapper>> getServiceJobProfitability(String coId) {
    	Map<String, List<ProfitabilityWrapper.SectionProfitabilityWrapper>> sectionTypeToProfitabilityWrapperMap = 
    		new Map<String, List<ProfitabilityWrapper.SectionProfitabilityWrapper>>();
    		
    	List<ProfitabilityWrapper.SectionProfitabilityWrapper> profitabilityWrapperList = new List<ProfitabilityWrapper.SectionProfitabilityWrapper>();
    	
    	List<Service_Order_Line_Item__c> soLineItemList = [SELECT Service_Order_Header__c, Service_Order_Header__r.Work_Status__c, Service_Order_Header__r.Invoice_Number__c, Service_Order_Header__r.Name__c, Service_Order_Header__r.Deal__c, Labour_Code__c, Part__c, Part__r.Part_Type__c, Fee__c, 
    		Service_Order_Header__r.Total_Labour_Cost__c, Service_Order_Header__r.Total_Fee_Cost__c, Service_Order_Header__r.Total_Shop_Supplies_Cost__c, Service_Order_Header__r.Total_Related_Sublet_Cost__c, 
    		Type__c, Sublet__c, Kit_Price__c, Price_When_Tax_Included__c, Tax_Percent__c, Qty_Needed__c, Fee__r.Cost_Method__c, Fee__r.Is_Include_In_Profit_Calculation__c, Fee__r.Cost_Rate__c, Labour_Code__r.Cost_Method__c, Labour_Code__r.Cost_Rate__c, 
    		Sublet__r.Cost_Method__c, Cost__c, Sublet__r.Cost__c, (select Adjusted_Cost_Coli__c, Qty__c, Part__r.Average_Cost__c from CO_Line_Items__r) FROM Service_Order_Line_Item__c WHERE Service_Order_Header__r.CO_Header__c =: coId Order By Service_Order_Header__r.Deal__c NULLS First, Service_Order_Header__r.CreatedDate ASC];
                                    
       
       	if(soLineItemList.size() > 0) {
       		Map<String, List<Service_Order_Line_Item__c>> soIdToSOLIListMap = new Map<String, List<Service_Order_Line_Item__c>>();
       		Map<String, Service_Order_Header__c> soIdToSORecMap = new Map<String, Service_Order_Header__c>();
       		for(Service_Order_Line_Item__c soliRec : soLineItemList) {
       			if(!soIdToSOLIListMap.containsKey(soliRec.Service_Order_Header__c)) {
       				soIdToSOLIListMap.put(soliRec.Service_Order_Header__c, new List<Service_Order_Line_Item__c>());
       			}
       			soIdToSOLIListMap.get(soliRec.Service_Order_Header__c).add(soliRec);
       			
       			if(!soIdToSORecMap.containsKey(soliRec.Service_Order_Header__c)) {
       				soIdToSORecMap.put(soliRec.Service_Order_Header__c, soliRec.Service_Order_Header__r);
       			}
       		}
       		//Boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
	    	Decimal partSales, merchSales, labourSales, feeSales, shopSuppliesSales, subletSales;
			Decimal partCost, merchCost, labourCost, feeCost, shopSuppliesCost, subletCost;
			
			List<String> coHeaderIdList = new List<String>();
			
	    	for(String soId : soIdToSOLIListMap.keySet()) {
	    		partSales = merchSales = labourSales = feeSales = shopSuppliesSales = subletSales = null;
				partCost = merchCost = labourCost = feeCost = shopSuppliesCost =subletCost = 0;
				
				Boolean isDealService = false;
	    		for(Service_Order_Line_Item__c soli : soIdToSOLIListMap.get(soId)) {
	    			isDealService = String.isNotBlank(soli.Service_Order_Header__r.Deal__c) ? true : false;
	    			
		        	soli.Qty_Needed__c = (soli.Qty_Needed__c != null) ? soli.Qty_Needed__c : 0;
		        	soli.Kit_Price__c = (soli.Kit_Price__c != null) ? soli.Kit_Price__c : 0;
	        		if(soli.Fee__c != null && soli.Fee__r.Is_Include_In_Profit_Calculation__c) {
	        			Decimal cost = 0;
	        			if(soli.Fee__r.Cost_Method__c == 'Fixed Cost' && soli.Fee__r.Cost_Rate__c !=null && soli.Qty_Needed__c != null) {
		                    cost = (soli.Qty_Needed__c * soli.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
		                } else if(soli.Fee__r.Cost_Method__c == 'Percent Retail'  && soli.Fee__r.Cost_Rate__c !=null &&  soli.Qty_Needed__c !=null ){
		                    cost = (soli.Qty_Needed__c * ((soli.Kit_Price__c *  soli.Fee__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
		                }
	                	if(soli.Type__c == Constants.SHOP_SUPPLY) {
	                		soli.Tax_Percent__c = soli.Tax_Percent__c != null ? soli.Tax_Percent__c : 0;
	                		shopSuppliesSales = (shopSuppliesSales != null) ? shopSuppliesSales : 0;
	                		soli.Kit_Price__c = (GeneralConfiguration.getTaxIncludingPricing() && soli.Price_When_Tax_Included__c != null) ? 
	                			(soli.Price_When_Tax_Included__c / (1 + soli.Tax_Percent__c / 100)) : soli.Kit_Price__c;
	        		        shopSuppliesSales += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
	        		        shopSuppliesCost += cost;
	        		    } else {
	        		    	feeSales = (feeSales != null) ? feeSales : 0;
	                	    feeSales += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
	                	    feeCost += cost;
	        		    }
	        		    //cost = null;
	        		} else if(soli.Part__c != null) {
	        			if(String.isNotBlank(soli.Part__r.Part_Type__c) && soli.Part__r.Part_Type__c == 'Merchandise') {
	        				merchSales = (merchSales != null) ? merchSales : 0;
	        				merchSales += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
	        				for(CO_Line_Item__c coli : soli.CO_Line_Items__r) {
			                    merchCost += (soli.Service_Order_Header__r.Invoice_Number__c != null ? ((coli.Adjusted_Cost_Coli__c != null) ? coli.Adjusted_Cost_Coli__c : 0) :
			                    	((coli.Part__r.Average_Cost__c != null) ? (coli.Part__r.Average_Cost__c * coli.Qty__c) : 0));
			                }
	        			} else {
	        				partSales = (partSales != null) ? partSales : 0;
	        				partSales += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
	        				for(CO_Line_Item__c coli : soli.CO_Line_Items__r) {
			                    partCost += (soli.Service_Order_Header__r.Invoice_Number__c != null ? ((coli.Adjusted_Cost_Coli__c != null) ? coli.Adjusted_Cost_Coli__c : 0) :
			                    	((coli.Part__r.Average_Cost__c != null) ? (coli.Part__r.Average_Cost__c * coli.Qty__c) : 0));
			                }
	        			}
	        		} else if(soli.Labour_Code__c != null) {
	        			labourSales = (labourSales != null) ? labourSales : 0;
	        			labourSales += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
	        			if(soli.Labour_Code__r.Cost_Method__c == 'Fixed Cost' && soli.Labour_Code__r.Cost_Rate__c != null && soli.Qty_Needed__c !=null){
		                    labourCost += (soli.Qty_Needed__c * soli.Labour_Code__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
		                } else if(soli.Labour_Code__r.Cost_Method__c == 'Percent Retail' && soli.Labour_Code__r.Cost_Rate__c !=null && soli.Qty_Needed__c !=null ){
		                    labourCost += (soli.Qty_Needed__c * ((soli.Kit_Price__c *  soli.Labour_Code__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
		                }
	        		} else if(soli.Sublet__c != null) {
	        			subletSales = (subletSales != null) ? subletSales : 0;
	        			subletSales += (soli.Qty_Needed__c * soli.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
	        			if(soli.Cost__c != null) {
	        				subletCost += (soli.Cost__c).setScale(2, RoundingMode.HALF_UP);
	        			} else if(soli.Sublet__r.Cost_Method__c == 'Fixed Cost' && soli.Sublet__r.Cost__c != null && soli.Qty_Needed__c !=null){
		                    subletCost += (soli.Qty_Needed__c * soli.Sublet__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
		                } else if(soli.Sublet__r.Cost_Method__c == 'Percent Retail' && soli.Sublet__r.Cost__c !=null && soli.Qty_Needed__c !=null ){
		                    subletCost += (soli.Qty_Needed__c * ((soli.Kit_Price__c *  soli.Sublet__r.Cost__c)/100)).setScale(2, RoundingMode.HALF_UP);
		                }
	        		}
	    		}
	    		
	    		if(soIdToSORecMap.get(soId).Invoice_Number__c != null && soIdToSORecMap.get(soId).Work_Status__c == 'Invoiced') {
					labourCost = soIdToSORecMap.get(soId).Total_Labour_Cost__c;
					feeCost = soIdToSORecMap.get(soId).Total_Fee_Cost__c;
					shopSuppliesCost = soIdToSORecMap.get(soId).Total_Shop_Supplies_Cost__c;
					subletCost = soIdToSORecMap.get(soId).Total_Related_Sublet_Cost__c;
				}
                
	    		List<ProfitabilityWrapper.ProductProfitabilityWrapper> soProfitabilityObjList = new List<ProfitabilityWrapper.ProductProfitabilityWrapper>();
				
				if(partSales != null) {
					soProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Parts', partSales, partCost));
				}
				if(merchSales != null) {
					soProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Merchandise', merchSales, merchCost));
				}
				if(labourSales != null) {
					soProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Labor', labourSales, labourCost));
				}
				if(subletSales != null) {
					soProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Sublet', subletSales, subletCost));
				}
				if(shopSuppliesSales != null) { 
					soProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Shop Supplies', shopSuppliesSales, shopSuppliesCost));
				}
	       		if(feeSales != null) {
					soProfitabilityObjList.add(new ProfitabilityWrapper.ProductProfitabilityWrapper('Fees', feeSales, feeCost));
				}
	       		
	       		if(soProfitabilityObjList.size() > 0) {
	       			if(soIdToSORecMap.containsKey(soId)) {
	       				//profitabilityWrapperList.add(new ProfitabilityWrapper.SectionProfitabilityWrapper(soIdToSORecMap.get(soId).Name__c, soProfitabilityObjList));
	       				if(String.isNotBlank(soIdToSORecMap.get(soId).Deal__c)) {
	       					if(!sectionTypeToProfitabilityWrapperMap.containsKey('Deal Service Job')) {
	       						sectionTypeToProfitabilityWrapperMap.put('Deal Service Job', new List<ProfitabilityWrapper.SectionProfitabilityWrapper>());
	       					}
	       					sectionTypeToProfitabilityWrapperMap.get('Deal Service Job').add(new ProfitabilityWrapper.SectionProfitabilityWrapper(soIdToSORecMap.get(soId).Name__c, soProfitabilityObjList));
	       				} else {
	       					if(!sectionTypeToProfitabilityWrapperMap.containsKey('Service Job')) {
	       						sectionTypeToProfitabilityWrapperMap.put('Service Job', new List<ProfitabilityWrapper.SectionProfitabilityWrapper>());
	       					}
	       					sectionTypeToProfitabilityWrapperMap.get('Service Job').add(new ProfitabilityWrapper.SectionProfitabilityWrapper(soIdToSORecMap.get(soId).Name__c, soProfitabilityObjList));
	       				}
	       			}
	       		}
	    	}
       	}
       	return sectionTypeToProfitabilityWrapperMap;
    }
    
    /**
    * Method to get all customer units which are having status 'Active'
    **/
    public static List<ServiceOrderWrapper.Unit> getActiveCOUList(String customerId) { 
        List<Customer_Owned_Unit__c> couRecords = SOQLUtil.geCOUList(customerId, new Map<String, String>{'Status__c' => 'Active'});
        List<ServiceOrderWrapper.Unit> couList = new List<ServiceOrderWrapper.Unit>();
        for(Customer_Owned_Unit__c couRec : couRecords) {
        	couList.add(new ServiceOrderWrapper.Unit(couRec));
        }
        return couList;
    }
        
    public static void populateSOIndividualsCostTotalsAfterFinalize(String coInvoiceId) {
    	List<Service_Order_Line_Item__c> soLineItemList = [SELECT Service_Order_Header__c, Service_Order_Header__r.Deal__c, Labour_Code__c, Part__c, Fee__c, 
    		Type__c, Sublet__c, Kit_Price__c, Price_When_Tax_Included__c, Tax_Percent__c, Qty_Needed__c, Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c, Fee__r.Is_Include_In_Profit_Calculation__c,
    		Labour_Code__r.Cost_Method__c, Labour_Code__r.Cost_Rate__c, Sublet__r.Cost_Method__c, Cost__c, Sublet__r.Cost__c FROM Service_Order_Line_Item__c 
    		WHERE Service_Order_Header__r.Invoice_Number__c =: coInvoiceId AND Service_Order_Header__r.Work_Status__c = 'Invoiced' Order By Service_Order_Header__r.Deal__c NULLS First, Service_Order_Header__r.CreatedDate ASC];
                                    
       
       	if(soLineItemList.size() > 0) {
       		List<Service_Order_Header__c> soListToUpdate = new List<Service_Order_Header__c>();
       		Decimal partCost, merchCost, labourCost, feeCost, shopSuppliesCost, subletCost;
       		
       		Map<String, List<Service_Order_Line_Item__c>> soIdToSOLIListMap = new Map<String, List<Service_Order_Line_Item__c>>();
       		Map<String, Service_Order_Header__c> soIdToSORecMap = new Map<String, Service_Order_Header__c>();
       		for(Service_Order_Line_Item__c soliRec : soLineItemList) {
       			if(!soIdToSOLIListMap.containsKey(soliRec.Service_Order_Header__c)) {
       				soIdToSOLIListMap.put(soliRec.Service_Order_Header__c, new List<Service_Order_Line_Item__c>());
       			}
       			soIdToSOLIListMap.get(soliRec.Service_Order_Header__c).add(soliRec);
       			
       			if(!soIdToSORecMap.containsKey(soliRec.Service_Order_Header__c)) {
       				soIdToSORecMap.put(soliRec.Service_Order_Header__c, soliRec.Service_Order_Header__r);
       			}
       		}
			
			List<String> coHeaderIdList = new List<String>();
			
	    	for(String soId : soIdToSOLIListMap.keySet()) {
	    		Service_Order_Header__c soRec = new Service_Order_Header__c(Id = soId); 
				partCost = merchCost = labourCost = feeCost = shopSuppliesCost = subletCost = 0;
				
				for(Service_Order_Line_Item__c soli : soIdToSOLIListMap.get(soId)) {
	    			soli.Qty_Needed__c = (soli.Qty_Needed__c != null) ? soli.Qty_Needed__c : 0;
		        	soli.Kit_Price__c = (soli.Kit_Price__c != null) ? soli.Kit_Price__c : 0;
	        		if(soli.Fee__c != null && soli.Fee__r.Is_Include_In_Profit_Calculation__c) {
	        			//FEE & SHOP SUPPLIES COST
	        			Decimal cost = 0;
	        			if(soli.Fee__r.Cost_Method__c == 'Fixed Cost' && soli.Fee__r.Cost_Rate__c != null && soli.Qty_Needed__c != null) {
		                    cost = (soli.Qty_Needed__c * soli.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
		                } else if(soli.Fee__r.Cost_Method__c == 'Percent Retail'  && soli.Fee__r.Cost_Rate__c !=null &&  soli.Qty_Needed__c !=null ){
		                    cost = (soli.Qty_Needed__c * ((soli.Kit_Price__c * soli.Fee__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
		                }
	                	if(soli.Type__c == Constants.SHOP_SUPPLY) {
	        		        shopSuppliesCost += cost;
	        		    } else {
	                	    feeCost += cost;
	        		    }
	        		    //cost = null;
	        		} else if(soli.Labour_Code__c != null) {
	        			// LABOUR COST
	        			if(soli.Labour_Code__r.Cost_Method__c == 'Fixed Cost' && soli.Labour_Code__r.Cost_Rate__c != null && soli.Qty_Needed__c !=null){
		                    labourCost += (soli.Qty_Needed__c * soli.Labour_Code__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
		                } else if(soli.Labour_Code__r.Cost_Method__c == 'Percent Retail' && soli.Labour_Code__r.Cost_Rate__c !=null && soli.Qty_Needed__c !=null ){
		                    labourCost += (soli.Qty_Needed__c * ((soli.Kit_Price__c *  soli.Labour_Code__r.Cost_Rate__c)/100)).setScale(2, RoundingMode.HALF_UP);
		                }
	        		} else if(soli.Sublet__c != null) {
	        			// SUBLET COST
	        			if(soli.Cost__c != null) {
	        				subletCost += (soli.Cost__c).setScale(2, RoundingMode.HALF_UP);
	        			} else if(soli.Sublet__r.Cost_Method__c == 'Fixed Cost' && soli.Sublet__r.Cost__c != null && soli.Qty_Needed__c !=null){
		                    subletCost += (soli.Qty_Needed__c * soli.Sublet__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
		                } else if(soli.Sublet__r.Cost_Method__c == 'Percent Retail' && soli.Sublet__r.Cost__c !=null && soli.Qty_Needed__c !=null ){
		                    subletCost += (soli.Qty_Needed__c * ((soli.Kit_Price__c *  soli.Sublet__r.Cost__c)/100)).setScale(2, RoundingMode.HALF_UP);
		                }
	        		}
	    		}
	       		
	       		soRec.Total_Labour_Cost__c = labourCost.setScale(2, RoundingMode.HALF_UP);
	       		soRec.Total_Fee_Cost__c = feeCost.setScale(2, RoundingMode.HALF_UP);
	       		soRec.Total_Shop_Supplies_Cost__c = shopSuppliesCost.setScale(2, RoundingMode.HALF_UP);
	       		soRec.Total_Related_Sublet_Cost__c = subletCost.setScale(2, RoundingMode.HALF_UP);
                soListToUpdate.add(soRec);
	    	}
            update soListToUpdate;
       	}
    }
    
	public static void handleBillToCustomerVariance(Map<Id, Claim_Line_Item__c> IdToClaimLineItemMap, Map<Id, Claim_Line_Item__c> claimLineOldmap, String coHeaderId, String couId) {
		
        String customerPaySOId = createServiceJobWithSpecificFields(coHeaderId, couId, new List<String>{'Claim variances billed to the customer'}, false);
        
        List<Service_Order_Line_Item__c>  soliListToInsert = new List<Service_Order_Line_Item__c>();
        Set<Id> soliIdSet = new Set<Id>();    
        List<SObject> sObjectListToInsert = COService.addLinkedFee(customerPaySOId, null, 'Service Job');
        if(sObjectListToInsert != null) {
            soliListToInsert.addAll((List<Service_Order_Line_Item__c>) sObjectListToInsert);
        }                                               
        for(String claimLIId : IdToClaimLineItemMap.KeySet()) {
        	Claim_Line_Item__c claimLineItemRec = claimLineOldmap.get(claimLIId);
        	Service_Order_Line_Item__c soliRec = new Service_Order_Line_Item__c(Service_Order_Header__c = customerPaySOId);
    		soliRec.Qty_Needed__c = (IdToClaimLineItemMap.get(claimLIId).Variance_Qty__c != null && IdToClaimLineItemMap.get(claimLIId).Variance_Qty__c != 0) ? 
    							IdToClaimLineItemMap.get(claimLIId).Variance_Qty__c : 1;
    		soliRec.Price_When_Tax_Included__c = soliRec.Kit_Price__c = soliRec.Actual_Kit_Price__c = claimLineItemRec.Service_Order_Line_Item__r.Actual_Kit_Price__c;
        	if(claimLineItemRec.Service_Order_Line_Item__r.Part__c != null) {
        		soliRec.Part__c = claimLineItemRec.Service_Order_Line_Item__r.Part__c;        		
        	} else if(claimLineItemRec.Service_Order_Line_Item__r.Fee__c != null) {
        		soliRec.Fee__c = claimLineItemRec.Service_Order_Line_Item__r.Fee__c;
        	} else if(claimLineItemRec.Service_Order_Line_Item__r.Labour_Code__c != null) {
        		soliRec.Labour_Code__c = claimLineItemRec.Service_Order_Line_Item__r.Labour_Code__c;
        	} else if(claimLineItemRec.Service_Order_Line_Item__r.Sublet__c != null) {
        		soliRec.Sublet__c = claimLineItemRec.Service_Order_Line_Item__r.Sublet__c;
        	}
        	soliIdSet.add(claimLineItemRec.Service_Order_Line_Item__c);
        	soliListToInsert.add(soliRec);
        }
        
        insert soliListToInsert;
        delete IdToClaimLineItemMap.values();
        updateVarianceClaimLineItems(soliIdSet);
    }
    
    public static void updateVarianceClaimLineItems(Set<Id> soliIdSet) {
		if(AccessControl.ifObjectFieldIsAccessible('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		List<Claim_Line_Item__c> claimLIList = [Select Id, Service_Order_Line_Item__c, Tax__c, Approved_Price__c, Approved_Qty__c, Claimed_Price__c, Claimed_Qty__c from 
			Claim_Line_Item__c where Service_Order_Line_Item__c IN: soliIdSet AND Is_Variance__c = false];
		
		List<Claim_Line_Item__c> claimLIListToUpdate = new List<Claim_Line_Item__c>();
		List<Service_Order_Line_Item__c> soliListToDelete = new List<Service_Order_Line_Item__c>();
		for(Claim_Line_Item__c claimLIRec : claimLIList) {
			if(claimLIRec.Approved_Qty__c == 0) {
				soliListToDelete.add(new Service_Order_Line_Item__c(Id = claimLIRec.Service_Order_Line_Item__c));
				continue;
			}
            claimLIRec.Claimed_Qty__c = claimLIRec.Approved_Qty__c;
            claimLIRec.Claimed_Price__c = claimLIRec.Approved_Price__c;
            claimLIListToUpdate.add(claimLIRec);
        }

		if(soliListToDelete.size() > 0) {
	        if(AccessControl.ifObjectIsDeletable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
	        Boolean isTriggerExecute = ServiceOrderLineItemTriggerHelper.isTriggerExecuted;
    		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
	        delete soliListToDelete;
	        ServiceOrderLineItemTriggerHelper.isTriggerExecuted = isTriggerExecute;
		}
		if(claimLIListToUpdate.size() > 0) {
        if(AccessControl.ifObjectFieldIsUpdateable('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	        update claimLIListToUpdate;
		}
	}
	
}