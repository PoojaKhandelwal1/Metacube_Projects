global without sharing class COService { 
    
    public static String getCOHeaderDetailsByGridName(String coHeaderId, String gridName) {
        try{ 
            List<CO_Header__c> coHeaderRec = new List<CO_Header__c>();
            coHeaderRec = SOQLUtility.getCOHeaderDetails(coHeaderId, 2); 
            List<CO_Invoice_Header__c> closedCOInvoiceHeaders = new List<CO_Invoice_Header__c>();
            List<CO_Line_Item__c> coLineItems = new List<CO_Line_Item__c>();
            List<CO_Kit_Header__c> coKitHeaders = new List<CO_Kit_Header__c>();
            List<Price_Level__c> priceLevelList = new List<Price_Level__c>();
            List<CO_Deposit__c> coDeposits = new List<CO_Deposit__c>();
            List<CO_Invoice_Payment__c> coInvoicePayments = new List<CO_Invoice_Payment__c>();
            
            List<Account> customerRecords = new List<Account>(); 
            if(String.isNotBlank(coHeaderRec[0].Customer__c)) {
                customerRecords = SOQLUtil.getCardDetails(new Map<String, String>{'Id' => coHeaderRec[0].Customer__c}); 
            } else if(coHeaderRec[0].CO_Type__c == 'Cash Sale'){
                priceLevelList = SOQLUtil.getCardDetailsForCO(null);     
            } else if(coHeaderRec[0].CO_Type__c == 'Internal Service') {
                String defaultPriceLevelId = GeneralConfiguration.getDefaultPriceLevelOnInternalService();
                priceLevelList = SOQLUtil.getCardDetailsForCO(defaultPriceLevelId);    
            }
            if(gridName == null ||  gridName.contains('coDeposit')) {
                List<CO_Invoice_Header__c> coInvoiceHeaders = SOQLUtil.getCOInvoiceHeaderByCOHeaderId(coHeaderId);   
                coDeposits = SOQLUtil.getCODepositByCOHeaderId(coHeaderId);
                if(coInvoiceHeaders.size() > 0) {
                    coInvoicePayments = SOQLUtil.getCOInvoicePaymentsByCOInvoiceHeaderId(coInvoiceHeaders[0].Id);
                }
            }
            if(gridName == null || gridName.contains('closedCOInvoiceHeader')) {
                closedCOInvoiceHeaders = SOQLUtil.getInvoiceHistory(coHeaderId);
            }
            
            if(gridName == null || gridName.contains('coLineItem')) {
                coLineItems = SOQLUtil.getCOLineItemByCOHeaderId(coHeaderId);
                coKitHeaders = SOQLUtil.getCOKHByCOHeaderId(coHeaderId);
            }
            
            CustomerOrderWrapper.COHeaderWrapper coHeaderWrapperObj;
            if(coHeaderRec.size() > 0) {  
                coHeaderWrapperObj = new CustomerOrderWrapper.COHeaderWrapper(coHeaderRec[0], customerRecords, coLineItems, coKitHeaders, closedCOInvoiceHeaders, priceLevelList, 
                                                    coDeposits, coInvoicePayments);
            } else {
                coHeaderWrapperObj = new CustomerOrderWrapper.COHeaderWrapper(null, customerRecords, coLineItems, coKitHeaders, closedCOInvoiceHeaders, priceLevelList, 
                                                    coDeposits, coInvoicePayments);
            } 
            return BPUtility.getEncodedString(System.JSON.serialize(coHeaderWrapperObj, true));
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString(''); 
    }
    
    public static void addPayment(List<COInvoicePayment> coInvoicePaymentsObjList, String coId){
        try{
            List<CO_Invoice_Payment__c> coInvoicePaymentListToUpdate = new List<CO_Invoice_Payment__c>();
            List<Id> reversePaymentIds = new List<Id>();
            
            List<CO_Invoice_Header__c> coInvHeaderList = new List<CO_Invoice_Header__c>();
            List<CO_Deposit__c> coDepositsListToInsert = new List<CO_Deposit__c>();
            for(COInvoicePayment coInvoicePaymentObj : coInvoicePaymentsObjList) {
                if(coInvoicePaymentObj.PaymentMethod != null && (coInvoicePaymentObj.PaymentMethod == Constants.USE_DEPOSIT || coInvoicePaymentObj.PaymentMethod =='Use Deal Deposit')) {
                    CO_Deposit__c coDepositRec = new CO_Deposit__c();
                    coDepositRec.Payment_Method__c = 'Invoice';
                    coDepositRec.CO_Invoice_Header__c = coInvoicePaymentObj.COInvoiceHeaderId;
                    coDepositRec.CO_Header__c = coId;
                    coDepositRec.Cash_Drawer__c  = coInvoicePaymentObj.CashDrawerId;
                    coDepositRec.Amount__c = -1 * coInvoicePaymentObj.Amount;
                    DateTime dtValue = HomeSearchFilterInterface.getDateFromString(coInvoicePaymentObj.PaymentDate);
                	coDepositRec.Payment_Date__c = (coInvoicePaymentObj.PaymentDate != null) ? Date.newInstance(dtValue.year(), dtValue.month(), dtValue.day()) : date.today();
                    
                    if(String.isNotBlank(coInvoicePaymentObj.DealId)) {
                        coDepositRec.Deal__c =coInvoicePaymentObj.DealId; 
                    }
                    coDepositsListToInsert.add(coDepositRec);
                }
            }
            if(coDepositsListToInsert.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                insert coDepositsListToInsert;
            }
             
            for(COInvoicePayment coInvoicePaymentObj : coInvoicePaymentsObjList) {
                if(coInvoicePaymentObj.PaymentMethod != 'Cash Rounding') {
                    CO_Invoice_Payment__c coInvoicePaymentRec = COPaymentService.createCOPaymentRecord(coInvoicePaymentObj);
                    if(coInvoicePaymentObj.ReverseLink != null) {
                        reversePaymentIds.add(coInvoicePaymentObj.ReverseLink);
                    }
                    coInvoicePaymentListToUpdate.add(coInvoicePaymentRec);
                }
            }
            
            if(coInvoicePaymentListToUpdate.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                upsert coInvoicePaymentListToUpdate;
            }
            if(reversePaymentIds.size() > 0) {
                List<CO_Invoice_Payment__c> roundingPaymentList = [select Id, Amount__c, Cash_Rounding_Payment__c,
                                                                     CO_Invoice_Header__c, Is_Reverse__c, Cash_Drawer__c, 
                                                                     Payment_Method__c, Reverse_Link__c, 
                                                                     Reverse_Payment_From__c,Payment_Date__c  from CO_Invoice_Payment__c 
                                                                     where Cash_Rounding_Payment__c IN :reversePaymentIds];
                if(roundingPaymentList.size() > 0){
                    CO_Invoice_Payment__c clonedRoundingPayment = roundingPaymentList[0].clone(false, true);
                    clonedRoundingPayment.Is_Reverse__c = true;
                    clonedRoundingPayment.Reverse_Link__c = roundingPaymentList[0].Id;  
                    clonedRoundingPayment.Reverse_Payment_From__c = roundingPaymentList[0].Id;
                    if(roundingPaymentList[0].Amount__c != null){
                        clonedRoundingPayment.Amount__c = -1 * roundingPaymentList[0].Amount__c;    
                    }
                    insert clonedRoundingPayment;   
                    roundingPaymentList[0].Reverse_Link__c = clonedRoundingPayment.Id;
                    roundingPaymentList[0].Reverse_Payment_From__c = clonedRoundingPayment.Id;
                    update roundingPaymentList;
                }   
                
            }
            
            List<CO_Invoice_Payment__c> coInvoicePaymentListForRounding = new List<CO_Invoice_Payment__c>();
            for(COInvoicePayment coInvoicePaymentObj : coInvoicePaymentsObjList) {
                if(coInvoicePaymentObj.PaymentMethod == 'Cash Rounding' && coInvoicePaymentObj.Amount != 0) {
                    CO_Invoice_Payment__c coInvoicePaymentRec = COPaymentService.createCOPaymentRecord(coInvoicePaymentObj);
                    if(coInvoicePaymentObj.ReverseLink != null) {
                        reversePaymentIds.add(coInvoicePaymentObj.ReverseLink);
                    }
                    coInvoicePaymentRec.Cash_Rounding_Payment__c = coInvoicePaymentListToUpdate[0].Id;
                    coInvoicePaymentListForRounding.add(coInvoicePaymentRec);
                }
            }
            if(coInvoicePaymentListForRounding.size() > 0){
                upsert coInvoicePaymentListForRounding;
            }
            
            if(reversePaymentIds.size() > 0) {
                if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<CO_Invoice_Payment__c> COInvoicePaymentsToBeReversed = [select Id, Reverse_Link__c from CO_Invoice_Payment__c where Id IN :reversePaymentIds];
                for(CO_Invoice_Payment__c coInvoicePaymentRec : COInvoicePaymentsToBeReversed) {
                    coInvoicePaymentRec.Reverse_Link__c = coInvoicePaymentListToUpdate[0].Id;
                    coInvoicePaymentRec.Reverse_Payment_From__c = coInvoicePaymentListToUpdate[0].Id;
                }
                if(COInvoicePaymentsToBeReversed.size() > 0) {
                    if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update COInvoicePaymentsToBeReversed;
                }
            }           
            /*String COInvoiceHeaderId;
            if(coInvoicePaymentsObjList.size() > 0) {
                COInvoiceHeaderId = coInvoicePaymentsObjList[0].COInvoiceHeaderId;
            } else {
                COInvoiceHeaderId = null;
            }
            //Send chexkout related Json
            return getCOHeaderDetailsByGridName(coId, null);*/
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static void updateMerchSectionToDisplay(String coHeaderId, Boolean flag){
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        CO_Header__c coHeaderRec = new CO_Header__c(Id = coHeaderId, Hide_Merchandise_Section__c = flag);
        COTriggerHelper.isTriggerExecute = true;
        update coHeaderRec;
    }
    
    public static CO_Line_Item__c createEnvFeeLineItem(String partId, String coHeaderId) {
        CO_Line_Item__c envFeeLineItemRec = new CO_Line_Item__c();
        List<Part__c> partList = [select Part_Number__c, Enviro_Fee__c, Enviro_Fee_Code__c, Enviro_Fee_Code__r.Code__c, 
                                        Enviro_Fee_Code__r.Description__c from Part__c where Id =: partId];
        if(partList.size() > 0 && partList[0].Enviro_Fee__c != null && partList[0].Enviro_Fee_Code__c != null) {
            envFeeLineItemRec.Fee__c = partList[0].Enviro_Fee_Code__c;
            envFeeLineItemRec.Item_Code__c = partList[0].Enviro_Fee_Code__r.Code__c;
            envFeeLineItemRec.Item_Description__c = partList[0].Part_Number__c + ' ' + partList[0].Enviro_Fee_Code__r.Description__c;
            envFeeLineItemRec.CO_Header__c = coHeaderId;
            envFeeLineItemRec.Price__c = partList[0].Enviro_Fee__c;
            envFeeLineItemRec.Qty__c = envFeeLineItemRec.Qty_Committed__c = 1;
            if(GeneralConfiguration.getTaxIncludingPricing()) {
                envFeeLineItemRec.Price_When_Tax_Included__c = partList[0].Enviro_Fee__c;
            }
            envFeeLineItemRec.Is_Environmental_Fee__c = true;
        }
        return envFeeLineItemRec;
    }
    
    public static List<Sobject> addLinkedFee(String recordId, String dealId, String objectType) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        if(String.isNotBlank(objectType)){
            List<Linked_Fee__c> linkedFeeList = SOQLUtil.getLinkedFeeList(new Map<String, String>{'Related_To__c' => objectType});
            if(linkedFeeList.size() == 0) {
                return null;
            }
            if(objectType == 'Merchandise') {
                List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
                CO_Line_Item__c coLineItemRec;
                for(Linked_Fee__c linkFee : linkedFeeList){
                    coLineItemRec = new CO_Line_Item__c();
                    coLineItemRec.Qty__c = 1 ;
                    coLineItemRec.Qty_Committed__c = 1;
                    if(isTaxIncludingPricing){
                        coLineItemRec.Price_When_Tax_Included__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    } else {
                        coLineItemRec.Price__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    }
                    coLineItemRec.CO_Header__c = recordId;
                    coLineItemRec.Fee__c = linkFee.Fee__c;
                    coLineItemRec.Item_Description__c = linkfee.Description__c == null ? linkfee.Fee__r.Description__c : linkfee.Description__c;
                    coLineItemRec.Is_Linked_Fee__c = true;
                    coliList.add(coLineItemRec);
                }
                if(coliList.size() > 0){
                    return coliList;
                }
            } else if(objectType == 'Service Job') {
                List<Service_Order_Line_Item__c> soliList = new List<Service_Order_Line_Item__c>();
                Service_Order_Line_Item__c soliRec;
                for(Linked_Fee__c linkFee : linkedFeeList){
                    soliRec = new Service_Order_Line_Item__c();
                    soliRec.Service_Order_Header__c = recordId;
                    soliRec.Fee__c = linkFee.Fee__c;
                    soliRec.Item_Code__c = linkFee.Fee__r.Code__c;
                    soliRec.Item_Description__c = linkfee.Description__c == null ? linkfee.Fee__r.Description__c : linkfee.Description__c;
                    soliRec.Qty_Needed__c = 1;
                    soliRec.Qty_Committed__c = 1;
                    if(isTaxIncludingPricing){
                        soliRec.Price_When_Tax_Included__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    } else {
                        soliRec.Kit_Price__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    }
                    soliRec.Actual_Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
                    soliRec.Is_Linked_Fee__c = true;
                    soliList.add(soliRec);
                }
                if(soliList.size() > 0){
                    return soliList;
                }
            } else if(objectType == 'Deal') {
                List<Option_Fee__c> optionAndFeeRecList = new List<Option_Fee__c>();
                Option_Fee__c optionAndFeeRec;
                for(Linked_Fee__c linkFee : linkedFeeList){
                    optionAndFeeRec = new Option_Fee__c();
                    optionAndFeeRec.Deal__c = dealId;
                    optionAndFeeRec.Deal_Item__c = recordId;
                    optionAndFeeRec.Fee__c = linkFee.Fee__c;
                    optionAndFeeRec.Item_Code__c = linkFee.Fee__r.Code__c;
                    optionAndFeeRec.Item_Description__c = linkfee.Description__c == null ? linkfee.Fee__r.Description__c : linkfee.Description__c;
                    optionAndFeeRec.Qty__c = 1;
                    if(isTaxIncludingPricing){
                        optionAndFeeRec.Price_When_Tax_Included__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    } else {
                        optionAndFeeRec.Price__c = linkfee.Price__c == null ? linkfee.Fee__r.Price__c : linkfee.Price__c;
                    }
                    optionAndFeeRecList.add(optionAndFeeRec);
                    optionAndFeeRec.Is_Linked_Fee__c = true;
                } 
                if(optionAndFeeRecList.size() > 0){
                    return optionAndFeeRecList;
                }
            }
        }
            
        return null;
    }
    
    /**
    * Name: saveCustomerApproval
    * Desc: Save CustomerApproval Information to CustomerApproval__c
    * @param:  (1) coHeaderId - String - Id of CO Header Record
    * @param:  (2) List<CustomerApproval> - custApprovalObjList to save
    * @return: Updated JSON data of Customer Approvals
    **/
    public static String saveCustomerApproval(String soHeaderId, List<CustomerApproval> custApprovalObjList) {

        List<CustomerApproval__c> custApprovalList = new List<CustomerApproval__c>();
        Decimal approvalCount;
        for(CustomerApproval custApprovalObj : custApprovalObjList) {
            if(custApprovalObj.ApprovalCount != null) {
                approvalCount = custApprovalObj.ApprovalCount;
            }   
        }
        List<CustomerApproval__c> existingApprovalList;
        if(approvalCount == null) {
            existingApprovalList = [SELECT Id, Approval_Count__c FROM CustomerApproval__c 
                                    WHERE Service_Order_Header__c =: soHeaderId AND Section_key__c = 'Get_Approval' 
                                    Order By Approval_Count__c DESC nulls last];
            approvalCount = (existingApprovalList.size() == 0) ? 1 : (existingApprovalList[0].Approval_Count__c + 1);                                                      
        }
        
        existingApprovalList = [SELECT Id, Section_key__c, ApprovalType__c, Approval_Count__c FROM CustomerApproval__c 
                                WHERE Service_Order_Header__c =: soHeaderId AND Approval_Count__c =: approvalCount]; 
        
        Map<String, CustomerApproval__c> approvalTypeToApprovalRecordMap = new Map<String, CustomerApproval__c>();
        for(CustomerApproval__c custApprovalRec : existingApprovalList) {
            approvalTypeToApprovalRecordMap.put(custApprovalRec.ApprovalType__c, custApprovalRec);
        }                                                   
        
        List<CustomerApproval__c> approvalListToUpsert = new List<CustomerApproval__c>();
        for(CustomerApproval custApprovalObj : custApprovalObjList) {
            CustomerApproval__c custApprovalRec = new CustomerApproval__c();
            custApprovalRec.Service_Order_Header__c = soHeaderId;
            custApprovalRec.Section_key__c = 'Get_Approval';
            custApprovalRec.Section_Name__c = 'Get-Approval';
            
            if(custApprovalObj.IsApprovalObtained != null && custApprovalObj.IsApprovalObtained) {
                custApprovalRec.Status__c = 'Approved';
            } else {
                custApprovalRec.Status__c = 'Pending';
            }
            custApprovalRec.Notes__c = custApprovalObj.Notes;
            custApprovalRec.ApprovalType__c = custApprovalObj.ApprovalType;
            custApprovalRec.Approval_Count__c = approvalCount;
            if(approvalTypeToApprovalRecordMap.containsKey(custApprovalObj.ApprovalType)) {
                custApprovalRec.Id = approvalTypeToApprovalRecordMap.get(custApprovalObj.ApprovalType).Id;
                approvalTypeToApprovalRecordMap.remove(custApprovalObj.ApprovalType);
            } 
            approvalListToUpsert.add(custApprovalRec);
        }
        
        if(approvalListToUpsert.size() > 0) {
            upsert approvalListToUpsert;
        }
        if(approvalTypeToApprovalRecordMap.values().size() > 0) {
            delete approvalTypeToApprovalRecordMap.values();
        }
        
        return getCustomerApprovals(soHeaderId, 'Get_Approval', approvalCount);
    }

    /**
    * Name: getCustomerApprovals
    * Desc: Get all CustomerApprovals for a Service Order
    * @param: (1) soHeaderId - String - Id of SO Header Record
    * @param: (2) sectionKey
    * @param: (3) approvalCount
    * @return: JSON data for customer approvals
    **/
    public static String getCustomerApprovals(String soHeaderId, String sectionKey, Decimal approvalCount) {
        List<CustomerApproval> custApprovalList = new List<CustomerApproval>();
        List<CustomerApproval__c> customerApprovalList = new List<CustomerApproval__c>();
        
        if(sectionKey == 'Get_Approval' && approvalCount != null) {
            customerApprovalList = [select Approval_Count__c, ApprovalDetailJson__c, ApprovalType__c, Notes__c, Section_key__c, Name, LastModifiedDate,
                                                Section_Name__c, Service_Order_Header__c, Status__c from CustomerApproval__c
                                                where Service_Order_Header__c =: soHeaderId AND Approval_Count__c = :approvalCount];
        
        } else if(sectionKey != 'Get_Approval') {
            customerApprovalList = [select Approval_Count__c, ApprovalDetailJson__c, ApprovalType__c, Notes__c, Section_key__c, Name, LastModifiedDate,
                                                Section_Name__c, Service_Order_Header__c, Status__c from CustomerApproval__c 
                                                where Service_Order_Header__c =: soHeaderId AND Section_key__c =: sectionKey];
        } 
        
        for(CustomerApproval__c custApproval : customerApprovalList) {
            custApprovalList.add(new CustomerApproval(custApproval));
        }
        return BPUtility.getEncodedString(System.JSON.serialize(custApprovalList));
    }
    
    public static void createMerchSectionIfNotExist(String coHeaderId) {
        try{
            List<CO_Header__c> coHeaderList = [Select id, Hide_Merchandise_Section__c, Customer__c,
                                                    (Select id from CO_Line_Items__r where Is_In_Merch_Section__c = true) from CO_Header__c where Id =: coHeaderId];
                                                    
            if(coHeaderList.size() > 0 && coHeaderList[0].Hide_Merchandise_Section__c) { // && coHeaderList[0].Customer__c != null
                if(coHeaderList[0].CO_Line_Items__r.size() == 0) {
                    List<SObject> sObjectListToInsert = COService.addLinkedFee(coHeaderId, null, 'Merchandise');
                    if(sObjectListToInsert != null) {
                        insert sObjectListToInsert;
                    }
                }
                updateMerchSectionToDisplay(coHeaderId, false);
            }
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        } 
    }
    
    public static String finalizeInvoice(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType){
        String currentFormattedDate = BPutility.getFormatedDateTime(datetime.newinstance(System.now().date(), System.now().time()));
        return finalizeInvoice(coInvoiceItemsJsonString, coHeaderId, currentCheckoutType,currentFormattedDate);
    }
    
    public static String finalizeInvoice(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType, String invoiceDateStr) {
        Savepoint sp = Database.setSavepoint();
        try{    
            coInvoiceItemsJsonString = BPUtility.getDecodedString(coInvoiceItemsJsonString);
            coHeaderId = BPUtility.getDecodedString(coHeaderId);
            currentCheckoutType = BPUtility.getDecodedString(currentCheckoutType);
            if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            
            List<COInvoiceItem> coInvoiceItemObjList = (List<COInvoiceItem>) System.JSON.deserialize(coInvoiceItemsJsonString, List<COInvoiceItem>.class);
            Set<Id> coLineItemIdSet = new Set<Id>();
            Set<Id> returnCOLineItemIdSet = new Set<Id>(); 
            Boolean isDisplayDiscountAmountOnPrint = false;
            for(COInvoiceItem coInvoiceItemObj : coInvoiceItemObjList) {
                if(coInvoiceItemObj.COLineItemId != null && coInvoiceItemObj.IsActive && coInvoiceItemObj.QtyRequired > coInvoiceItemObj.Qty && coInvoiceItemObj.Qty != 0 )  {
                    coLineItemIdSet.add(coInvoiceItemObj.COLineItemId);
                } else if(coInvoiceItemObj.COLineItemId != null && coInvoiceItemObj.QtyRequired < 0){
                    
                }
                if(coInvoiceItemObj.IsActive && coInvoiceItemObj.IsDisplayDiscountAmount != null && !isDisplayDiscountAmountOnPrint) {
                    isDisplayDiscountAmountOnPrint = coInvoiceItemObj.IsDisplayDiscountAmount;
                }
            }
            List<CO_Line_Item__c> coLineItemRecList = [select Qty__c, Qty_Committed__c, Part__c, CO_Header__c, Price__c, Tax__c from CO_Line_Item__c where Id IN : coLineItemIdSet ];
            List<CO_Line_Item__c> coLineItemRecToUpdated = new List<CO_Line_Item__c>();
            List<CO_Line_Item__c> coLineItemRecToInserted = new List<CO_Line_Item__c>();
            
            for(CO_Line_Item__c coLineItemRec : coLineItemRecList) {
                if(coLineItemRec.Qty__c > coLineItemRec.Qty_Committed__c) {
                    CO_Line_Item__c coLineItemDuplicate = new CO_Line_Item__c();
                    coLineItemDuplicate = coLineItemRec.clone(false, true, false, false);
                    coLineItemDuplicate.Qty__c = coLineItemRec.Qty_Committed__c;
                    coLineItemRec.Qty__c = coLineItemRec.Qty__c - coLineItemRec.Qty_Committed__c;
                    coLineItemRec.Qty_Committed__c = 0;
                    coLineItemRecToUpdated.add(coLineItemRec);
                    coLineItemRecToInserted.add(coLineItemDuplicate);  
                }
            }
            if(coLineItemRecToUpdated.size() > 0) {
                update coLineItemRecToUpdated;
            }
            if(coLineItemRecToInserted.size() > 0) {
                insert coLineItemRecToInserted;
            }
            for(Integer i=0 ; i < coLineItemRecToInserted.size() ; i++ ) {
                coLineItemRecToInserted[i].price__c = coLineItemRecToUpdated[i].price__c;
            }
            if(coLineItemRecToInserted.size() > 0) {
                update coLineItemRecToInserted;
            }
            
            Set<Id> newInsertedCOLineItemIdSet = new Set<Id>();
            for(CO_Line_Item__c coLineItemRec : coLineItemRecToInserted) {
                newInsertedCOLineItemIdSet.add(coLineItemRec.Id); 
            }
            
            // Close Invoice Header
            String activeCOInvoiceHeaderId = '';
            String closedCOInvoiceHeaderId = '';
            if(coInvoiceItemObjList.size() == 0) {
                return null;
            }
            DateTime invoiceDate = (invoiceDateStr != null) ? HomeSearchFilterInterface.getDateFromString(invoiceDateStr) : date.today();
            activeCOInvoiceHeaderId = coInvoiceItemObjList[0].COInvoiceHeaderId;
            List<CO_Invoice_Header__c> coInvoiceHeaderRecToUpdate = new List<CO_Invoice_Header__c>();
            activeCOInvoiceHeaderId = BPUtility.escapeSingleQuotes(activeCOInvoiceHeaderId);
            CO_Invoice_Header__c coInvoiceHeaderRec = [select CO_Header__r.Customer__c, Invoice_Status__c from CO_Invoice_Header__c where Id = :activeCOInvoiceHeaderId];
            coInvoiceHeaderRec.Invoice_Status__c = 'Closed';
            coInvoiceHeaderRec.Closed_Invoice_Date__c = system.now();
            coInvoiceHeaderRec.Checkout_Type__c = currentCheckoutType;
            coInvoiceHeaderRec.Invoice_Date__c = invoiceDate; 
            coInvoiceHeaderRecToUpdate.add(coInvoiceHeaderRec);
            closedCOInvoiceHeaderId = activeCOInvoiceHeaderId;
            String customerId = coInvoiceHeaderRec.CO_Header__r.Customer__c;
            
            CO_Invoice_Header__c coInvoiceHeaderRecToInsert = new CO_Invoice_Header__c();
            coInvoiceHeaderRecToInsert.Invoice_Status__c = 'Active';
            coInvoiceHeaderRecToInsert.CO_Header__c = coHeaderId; 
            coInvoiceHeaderRecToUpdate.add(coInvoiceHeaderRecToInsert);
            
            if(coInvoiceHeaderRecToUpdate.size() > 0) {
                map<Id,AutoNumberHolder__c>  InvoiceToAutoNumbermap =new  map<Id,AutoNumberHolder__c>();
                for(CO_Invoice_Header__c coInvoiceHeaderRecNew :   coInvoiceHeaderRecToUpdate){
                    if(coInvoiceHeaderRecNew.Invoice_Status__c == 'Closed'){
                        AutoNumberHolder__c objnewAutonumber = new AutoNumberHolder__c();
                        InvoiceToAutoNumbermap.put(coInvoiceHeaderRecNew.Id,objnewAutonumber);
                    } 
                }
                if(InvoiceToAutoNumbermap.size() > 0){
                    if(AccessControl.ifObjectFieldIsCreateable('AutoNumberHolder__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert InvoiceToAutoNumbermap.values();
                    for(CO_Invoice_Header__c coInvoiceHeaderRecNew :   coInvoiceHeaderRecToUpdate){
                        if(coInvoiceHeaderRecNew.Invoice_Status__c == 'Closed'){
                            AutoNumberHolder__c objnewAutonumber =InvoiceToAutoNumbermap.get(coInvoiceHeaderRecNew.Id);
                            coInvoiceHeaderRecNew.AutoNumberHolder__c = objnewAutonumber.Id;
                        }
                    }   
                }
                upsert coInvoiceHeaderRecToUpdate;
            } 
             
            String activeInvoiceHeaderId;
            for(CO_Invoice_Header__c coInvoiceHeader : coInvoiceHeaderRecToUpdate) {
                if(coInvoiceHeader.Invoice_Status__c == 'Active') {
                    activeInvoiceHeaderId = coInvoiceHeader.Id;
                }
            }
            closedCOInvoiceHeaderId = BPUtility.escapeSingleQuotes(closedCOInvoiceHeaderId);
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<CO_Invoice_Item__c> coInvoiceItems = [select isActive__c, CO_Invoice_Header__c, CO_Kit_Header__c,Service_Order_Header__c,CO_Line_Item__c,CO_Line_Item__r.Closed_CO_Invoice_link__c, CO_Invoice_Header__r.Name,
                                                            Deal_Finance__c,Deal__c from CO_Invoice_Item__c 
                                                            where (CO_Invoice_Header__c = :closedCOInvoiceHeaderId AND isActive__c = false) 
                                                                        OR CO_Line_Item__c IN : coLineItemIdSet];
            for(CO_Invoice_Item__c coInvoiceItemRec : coInvoiceItems) {
                if(coInvoiceItemRec.CO_Line_Item__c == null) {
                     coInvoiceItemRec.CO_Invoice_Header__c = activeInvoiceHeaderId;
                     coInvoiceItemRec.isActive__c = (coInvoiceItemRec.Deal__c != null ? true : coInvoiceItemRec.isActive__c);
                     continue;
                }
                if(newInsertedCOLineItemIdSet.contains(coInvoiceItemRec.CO_Line_Item__c)) {  
                    coInvoiceItemRec.isActive__c = true;
                } else {
                    coInvoiceItemRec.isActive__c = false;  
                    coInvoiceItemRec.CO_Invoice_Header__c = activeInvoiceHeaderId;
                }
            }
            if(coInvoiceItems.size() > 0) { 
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update coInvoiceItems;
            }
            
            Map<String,List<CO_Invoice_Item__c>> coInvoiceTypeToLineItemMap =  new Map<String,List<CO_Invoice_Item__c>>();
            closedCOInvoiceHeaderId = BPUtility.escapeSingleQuotes(closedCOInvoiceHeaderId);
            List<CO_Invoice_Item__c> closedCOInvoicItemList = [select   CO_Invoice_Header__c,SO_Payment_Role__c, CO_Kit_Header__c,Service_Order_Header__c,CO_Line_Item__c,CO_Line_Item__r.Closed_CO_Invoice_link__c, CO_Invoice_Header__r.Name, Deal__c, Deal_Finance__c from CO_Invoice_Item__c where CO_Invoice_Header__c = :closedCOInvoiceHeaderId];
            List<CO_Line_Item__c> coLineItemsToUpdated = new List<CO_Line_Item__c>();
            List<Service_Order_Line_Item__c> soLineItemInternalservice = new List<Service_Order_Line_Item__c>();
            List<Service_Order_Line_Item__c> soLineItemDealservice = new List<Service_Order_Line_Item__c>();
            List<CO_Line_Item__c> coLineItemDealservice = new List<CO_Line_Item__c>();
            
            Map<Id,CO_Invoice_Item__c> invoicedServiceOrderHeaderMap =new  Map<Id,CO_Invoice_Item__c>();
            Map<Id, CO_Invoice_Item__c > invoicedCoLineItemMap = new Map<Id, CO_Invoice_Item__c >();
            Map<Id, CO_Invoice_Item__c > invoicedCOKHMap = new Map<Id, CO_Invoice_Item__c >();
            Map<Id, CO_Invoice_Item__c > invoicedSoPaymentMap = new Map<Id, CO_Invoice_Item__c >();
            Map<Id, CO_Invoice_Item__c > invoicedDealFinanceMap = new Map<Id, CO_Invoice_Item__c >();
            Map<Id, CO_Invoice_Item__c > invoicedDealMap = new Map<Id, CO_Invoice_Item__c >();
            //system.assert(false, closedCOInvoicItemList);
            List<Part__c> PartForPartReturnBuckets = new  List<Part__c>();
            for(CO_Invoice_Item__c coInoiceItemRec : closedCOInvoicItemList) {
                if(coInoiceItemRec.CO_Line_Item__c != null) {
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('ColiInvoice')) {
                        coInvoiceTypeToLineItemMap.Put('ColiInvoice',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('ColiInvoice').add(coInoiceItemRec);
                    invoicedCoLineItemMap.Put(coInoiceItemRec.CO_Line_Item__c,coInoiceItemRec );
                } else if( coInoiceItemRec.CO_Kit_Header__c !=null){
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('CoKitInvoice')) {
                        coInvoiceTypeToLineItemMap.Put('CoKitInvoice',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('CoKitInvoice').add(coInoiceItemRec);
                    invoicedCOKHMap.Put(coInoiceItemRec.CO_Kit_Header__c,coInoiceItemRec );
                
                } else if( coInoiceItemRec.Service_Order_Header__c !=null && coInoiceItemRec.SO_Payment_Role__c ==null){
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('SoKitInvoice')) {
                        coInvoiceTypeToLineItemMap.Put('SoKitInvoice',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('SoKitInvoice').add(coInoiceItemRec);
                    invoicedServiceOrderHeaderMap.Put(coInoiceItemRec.Service_Order_Header__c,coInoiceItemRec );
                } else if( coInoiceItemRec.SO_Payment_Role__c !=null){
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('SoPayment')) {
                        coInvoiceTypeToLineItemMap.Put('SoPayment',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('SoPayment').add(coInoiceItemRec);
                    invoicedSoPaymentMap.Put(coInoiceItemRec.SO_Payment_Role__c , coInoiceItemRec );
                } else if( coInoiceItemRec.Deal__c !=null){
                     if( coInoiceItemRec.Deal_Finance__c != null) {
                        invoicedDealFinanceMap.Put(coInoiceItemRec.Deal_Finance__c , coInoiceItemRec );
                     } else {
                        invoicedDealMap.Put(coInoiceItemRec.Deal__c , coInoiceItemRec );
                     }
                }
            }
            
            List<Option_Fee__c> optionAndFeeRecListWithDoNotInvOption = new List<Option_Fee__c>();
            // for Service order records 
            Set<String> dealKHIdSet = new Set<String>();
			if(coInvoiceTypeToLineItemMap.containsKey('SoKitInvoice')) {
				if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	            if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	           	if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

               	List<Service_Order_Line_Item__c> serviceOrderLineItemFromInvoiceList  = new List<Service_Order_Line_Item__c>([Select Service_Order_Header__c,
																	Service_Order_Kit_Header__c, Service_Order_Kit_Header__r.Deal_Kit_Header__c,
																	
																	(Select Qty__c, Qty_Committed__c, Status__c, Price__c, part__c,part__r.Qty_In_Stock__c,
                                                                    part__r.Qty_Committed__c,part__r.Last_Cost__c, Closed_CO_Invoice_link__c,Oversold_Qty__c 
                                                                    From CO_Line_Items__r),
                                                                    
                                                                    (Select Id, CO_Line_Item__r.Price__c, Service_Order_Line_Item__r.Kit_Price__c from Options_Fees__r
                                                                    where Do_Not_Invoice__c = true), 
                                                                    
                                                                    Option_Fee__c, Labour_Code__r.Description__c,Fee__r.Description__c, 
                                                                    Part__r.Description__c, Qty_Needed__c,Retail_Price__c,Kit_Price__c,CO_Line_Item__c,
                                                                    Service_Order_Header__r.Customer_Owned_Unit__c,Service_Order_Header__r.SO_Type__c,
                                                                    Item_Code__c, Item_Description__c, Service_Order_Header__r.Transaction_Type__r.Type__c
                                                                    From Service_Order_Line_Item__c where Service_Order_Header__c  =: invoicedServiceOrderHeaderMap.KeySet()]);
                                                                                                                                  
                for(Service_Order_Line_Item__c serviceOrderLineItemFromInvoiceRec : serviceOrderLineItemFromInvoiceList) {
                    if(invoicedServiceOrderHeaderMap.containsKey(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__c)) {
                        CO_Invoice_Item__c   closedCOInvoiceItem =  invoicedServiceOrderHeaderMap.get(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__c);
                        if(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__r.SO_Type__c =='Internal Service'){
                            soLineItemInternalservice.add(serviceOrderLineItemFromInvoiceRec);
                        } else if(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Deal Service' ) {
                            soLineItemDealservice.add(serviceOrderLineItemFromInvoiceRec);
                            if(String.isNotBlank(serviceOrderLineItemFromInvoiceRec.Service_Order_Kit_Header__c) &&
                                    String.isNotBlank(serviceOrderLineItemFromInvoiceRec.Service_Order_Kit_Header__r.Deal_Kit_Header__c)) {
                                dealKHIdSet.add(serviceOrderLineItemFromInvoiceRec.Service_Order_Kit_Header__r.Deal_Kit_Header__c);
                            } else {
                        		optionAndFeeRecListWithDoNotInvOption.addAll(serviceOrderLineItemFromInvoiceRec.Options_Fees__r);
                        	}
                        }
                            
                        List<CO_Line_Item__c> coliUpdateFromServiceOrderInvoiceList = new   List<CO_Line_Item__c>(serviceOrderLineItemFromInvoiceRec.CO_Line_Items__r);
                        for(CO_Line_Item__c colirec : coliUpdateFromServiceOrderInvoiceList ){
                            colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                            colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                            coLineItemsToUpdated.add(colirec);
                        }
                    }
                }
            }
                
            if(coInvoiceTypeToLineItemMap.containsKey('ColiInvoice')) {
                if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                
                List<CO_Line_Item__c> ColiFromInvoiceList = new   List<CO_Line_Item__c>([Select Qty__c, Qty_Committed__c, Price__c, Status__c,part__c,part__r.Qty_In_Stock__c,Related_Option_And_Fees__c,
						(Select Id, CO_Line_Item__r.Price__c, Service_Order_Line_Item__r.Kit_Price__c from Options_Fees__r where Do_Not_Invoice__c = true), 
                        part__r.Qty_Committed__c,part__r.Last_Cost__c,closed_CO_Invoice_link__c,Oversold_Qty__c From CO_Line_Item__c where Id =: invoicedCoLineItemMap.KeySet()]);
                for(CO_Line_Item__c colirec : ColiFromInvoiceList) {
                    CO_Invoice_Item__c   closedCOInvoiceItem = invoicedCoLineItemMap.get(colirec.Id);
                    colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                    colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                    coLineItemsToUpdated.add(colirec);
                    if(String.isNotBlank(colirec.Related_Option_And_Fees__c)){
                        coLineItemDealservice.add(colirec);
                    }
                    optionAndFeeRecListWithDoNotInvOption.addAll(colirec.Options_Fees__r);
                }
             }   
             if(coInvoiceTypeToLineItemMap.containsKey('CoKitInvoice')) {
                if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

                List<CO_Kit_Header__c> ColiFromInvoiceList = new   List<CO_Kit_Header__c>([Select Id, Deal_Kit_Header__c, (Select Qty__c, Qty_Committed__c, Price__c, Status__c,part__c,part__r.Qty_In_Stock__c,Related_Option_And_Fees__c,
                                                                                        part__r.Qty_Committed__c,part__r.Last_Cost__c, Closed_CO_Invoice_link__c,Oversold_Qty__c From CO_Line_Items__r)
                                                                                        From CO_Kit_Header__c where  Id =: invoicedCOKHMap.KeySet()]);
                                                                                        
                for(CO_Kit_Header__c coKitHeaderFromInvoiceRec : ColiFromInvoiceList) {
                    if(String.isNotBlank(coKitHeaderFromInvoiceRec.Deal_Kit_Header__c)) {
                        dealKHIdSet.add(coKitHeaderFromInvoiceRec.Deal_Kit_Header__c);
                    }
                }

                for(CO_Kit_Header__c coKitHeaderFromInvoiceRec : ColiFromInvoiceList) {
                    if(invoicedCOKHMap.containsKey(coKitHeaderFromInvoiceRec.Id)){
                        CO_Invoice_Item__c   closedCOInvoiceItem =  invoicedCOKHMap.get(coKitHeaderFromInvoiceRec.Id);
                        List<CO_Line_Item__c> coliUpdateFromServiceOrderInvoiceList = new   List<CO_Line_Item__c>(coKitHeaderFromInvoiceRec.CO_Line_Items__r);
                        for(CO_Line_Item__c colirec : coliUpdateFromServiceOrderInvoiceList ){
                            colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                            colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                            coLineItemsToUpdated.add(colirec);
                            if(String.isNotBlank(colirec.Related_Option_And_Fees__c)) {                                         
                                coLineItemDealservice.add(colirec);
                            }
                        }
                    }
                }
            }
            
            Map<Id,Part__c> updateStockedMap = new Map<Id,Part__c>();
            Map<Id,Part__c> updateStockBucketMap = new Map<Id,Part__c>();
            Set<Id> invoiceableSOIdSet = new Set<Id>();
            List<So_Payment_Role__c> SoPaymentRoleList  = new List<So_Payment_Role__c>();
            Map<String, CO_Line_Item__c> coliIdTocoliRecRelatedToThirdPartyMap = new Map<String, CO_Line_Item__c>();
            if(coInvoiceTypeToLineItemMap.containsKey('SoPayment')){  
                if(AccessControl.ifObjectFieldIsAccessible('So_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

                SoPaymentRoleList  = new List<So_Payment_Role__c>([Select Id,RecordType.DeveloperName, Service_Order_Header__c, (select Id,Is_Variance__c,Approved_Qty__c, 
                                                                        Variance_Qty__c,Service_Order_Line_Item__c,Approved_Price__c, Service_Order_Line_Item__r.part__c, 
                                                                        Service_Order_Line_Item__r.part__r.Qty_In_Stock__c,
                                                                        Service_Order_Line_Item__r.part__r.last_cost__c,Service_Order_Line_Item__r.part__r.Qty_Committed__c ,
                                                                        Service_Order_Line_Item__r.CO_Line_Item__c, 
                                                                        Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c, 
                                                                        Service_Order_Line_Item__r.Fee__c,
                                                                        Service_Order_Line_Item__r.Qty_Needed__c,
                                                                        Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c  From Claim_Line_Items__r)
                                                                        From So_Payment_Role__c  where  Id  IN : invoicedSoPaymentMap.KeySet()]);
                     
                for(So_Payment_Role__c SoPaymentRec : SoPaymentRoleList){
                    
                    CO_Invoice_Item__c closedCOInvoiceItem = invoicedSoPaymentMap.get(SoPaymentRec.Id);
                    
                    if(SoPaymentRec.RecordType.DeveloperName == 'Third_Party' ){
                        for(Claim_Line_Item__c ClaimLineItemrec : SoPaymentRec.Claim_Line_Items__r ){
                            if(ClaimLineItemrec.Service_Order_Line_Item__r.part__c!=null){
                                Part__c partRec = new part__c();
                                partRec.Id =  ClaimLineItemrec.Service_Order_Line_Item__r.part__c;
                                partRec.Qty_In_Stock__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_In_Stock__c;
                                partRec.Qty_Committed__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_Committed__c;
                                Decimal qtyNeed = ClaimLineItemrec.Approved_Qty__c;
                                Decimal quantityComitted = ClaimLineItemrec.Approved_Qty__c;
                                Decimal qtyOverSold = 0;
                                Decimal ReturnCost = ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c !=null ?  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c : 0 ; 

                                CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,updateStockBucketMap,qtyNeed,quantityComitted,partRec, PartForPartReturnBuckets, ReturnCost,qtyOverSold );
                            }
                            
                            if(String.isNotBlank(ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c)) {
                                CO_Line_Item__c colirec = new CO_Line_Item__c(Id = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c);
                                colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                                colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                                colirec.Part__c = ClaimLineItemrec.Service_Order_Line_Item__r.Part__c;
                                colirec.Fee__c = ClaimLineItemrec.Service_Order_Line_Item__r.Fee__c;
                                colirec.Oversold_Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c;
                                colirec.Qty_Committed__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c;
                                colirec.Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.Qty_Needed__c;
                                coliIdTocoliRecRelatedToThirdPartyMap.put(colirec.Id, colirec);
                            }
                        }
                        SoPaymentRec.Status__c   = 'Invoiced';
                        invoiceableSOIdSet.add(SoPaymentRec.Service_Order_Header__c); 
                    } else if(SoPaymentRec.RecordType.DeveloperName == 'Customer' ){
                        for(Claim_Line_Item__c ClaimLineItemrec : SoPaymentRec.Claim_Line_Items__r ){
                            if(ClaimLineItemrec.Service_Order_Line_Item__r.part__c!=null){
                                Part__c partRec = new part__c();
                                partRec.Id =  ClaimLineItemrec.Service_Order_Line_Item__r.part__c;
                                partRec.Qty_In_Stock__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_In_Stock__c;
                                partRec.Qty_Committed__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_Committed__c;
                                Decimal qtyNeed = ClaimLineItemrec.Variance_Qty__c;
                                Decimal quantityComitted = ClaimLineItemrec.Variance_Qty__c;
                                Decimal qtyOverSold = 0;
                                Decimal ReturnCost = ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c !=null ?  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c : 0 ;

                                CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,updateStockBucketMap,qtyNeed,quantityComitted,partRec, PartForPartReturnBuckets, ClaimLineItemrec.Approved_Price__c,qtyOverSold );
                                
                            }
                            if(String.isNotBlank(ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c)) {
                                CO_Line_Item__c colirec = new CO_Line_Item__c(Id = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c);
                                colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                                colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                                colirec.Part__c = ClaimLineItemrec.Service_Order_Line_Item__r.Part__c;
                                colirec.Fee__c = ClaimLineItemrec.Service_Order_Line_Item__r.Fee__c;
                                colirec.Oversold_Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c;
                                colirec.Qty_Committed__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c;
                                colirec.Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.Qty_Needed__c;
                                coliIdTocoliRecRelatedToThirdPartyMap.put(colirec.Id, colirec);
                            }
                        }
                        SoPaymentRec.Status__c = 'Invoiced';    
                    }else if(SoPaymentRec.RecordType.DeveloperName == 'Internal'){
                        for(Claim_Line_Item__c ClaimLineItemrec : SoPaymentRec.Claim_Line_Items__r ){
                            if(ClaimLineItemrec.Service_Order_Line_Item__r.part__c!=null){
                                Part__c partRec = new part__c();
                                partRec.Id =  ClaimLineItemrec.Service_Order_Line_Item__r.part__c;
                                partRec.Qty_In_Stock__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_In_Stock__c;
                                partRec.Qty_Committed__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_Committed__c;
                                Decimal qtyNeed = ClaimLineItemrec.Variance_Qty__c;
                                Decimal quantityComitted = ClaimLineItemrec.Variance_Qty__c;
                                Decimal qtyOverSold = 0;
                                Decimal ReturnCost = ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c !=null ?  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c : 0 ;

                                CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,updateStockBucketMap,qtyNeed,quantityComitted,partRec, PartForPartReturnBuckets,ReturnCost,qtyOverSold );
                            }
                            if(String.isNotBlank(ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c)) {
                                CO_Line_Item__c colirec = new CO_Line_Item__c(Id = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c);
                                colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                                colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                                colirec.Part__c = ClaimLineItemrec.Service_Order_Line_Item__r.Part__c;
                                colirec.Fee__c = ClaimLineItemrec.Service_Order_Line_Item__r.Fee__c;
                                colirec.Oversold_Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c;
                                colirec.Qty_Committed__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c;
                                colirec.Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.Qty_Needed__c;
                                coliIdTocoliRecRelatedToThirdPartyMap.put(colirec.Id, colirec);
                            }
                        }
                        SoPaymentRec.Status__c = 'Invoiced'; 
                    }

                    else if(SoPaymentRec.RecordType.DeveloperName == 'deductible'){
                        SoPaymentRec.Deductible_Status__c = 'Paid';
                        SoPaymentRec.Status__c = 'Invoiced'; 
                    } 
                }    
                
            }
            Map<Id, Part__c> partIdToPartRecMap = new Map<Id, Part__c>(); 
            for(CO_Line_Item__c coLineItemsToUpdatedRec : coLineItemsToUpdated){
                if(coLineItemsToUpdatedRec.Part__c != null){
                    Decimal quantityComitted = coLineItemsToUpdatedRec.Qty_Committed__c  ==null ? 0 :coLineItemsToUpdatedRec.Qty_Committed__c;
                    Decimal qtyNeed = coLineItemsToUpdatedRec.Qty__c  ==null ? 0 :coLineItemsToUpdatedRec.Qty__c;
                    Decimal qtyOverSold = coLineItemsToUpdatedRec.Oversold_Qty__c;
                    Decimal ReturnCost = coLineItemsToUpdatedRec.part__r.last_cost__c !=null ?  coLineItemsToUpdatedRec.part__r.last_cost__c : 0 ;
                    CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,  updateStockBucketMap,qtyNeed,quantityComitted,coLineItemsToUpdatedRec.part__r,
                             PartForPartReturnBuckets,ReturnCost,qtyOverSold);
                    
                    partIdToPartRecMap.put(coLineItemsToUpdatedRec.Part__c, new Part__c(Id = coLineItemsToUpdatedRec.Part__c, Last_Sold__c = system.Now()));
                }
            }
            
            if(partIdToPartRecMap.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update partIdToPartRecMap.values();
            }
              
            if(PartForPartReturnBuckets.size() > 0){
                FIFOTransaction.createFIFOBucketForCustomerReturn(PartForPartReturnBuckets, activeCOInvoiceHeaderId,coLineItemsToUpdated);
            } 
              
            List<Part_FIFO_Bucket__c>  PartFifoList=  SOQLUtil.getPartFIFOBucketByPartList(updateStockedMap.keySet());
            Map<Id,List<Part_FIFO_Bucket__c>> PartToFIFOBucketMap   = new Map<Id,List<Part_FIFO_Bucket__c>>();
            for(Part_FIFO_Bucket__c partFifoRec : PartFifoList){
                if(PartToFIFOBucketMap.containsKey(partFifoRec.part__c)){
                    PartToFIFOBucketMap.get(partFifoRec.part__c).add(partFifoRec);
                }else{ 
                    List<Part_FIFO_Bucket__c> listpartFifo  = new List<Part_FIFO_Bucket__c>();
                    listpartFifo.add(partFifoRec);
                    PartToFIFOBucketMap.put(partFifoRec.part__c, listpartFifo);
                } 
            } 
            
            for(CO_Line_Item__c coliRec : coLineItemsToUpdated) {
                if(coliIdTocoliRecRelatedToThirdPartyMap.containskey(coliRec.Id)) {
                    coliIdTocoliRecRelatedToThirdPartyMap.remove(coliRec.Id);
                }
            }
            coLineItemsToUpdated.addAll(coliIdTocoliRecRelatedToThirdPartyMap.values());
            List<Part__c> partFifoBucketValueToUpdate = new List<Part__c>(); 
            if(updateStockBucketMap.size()> 0){
                String Result = FIFOTransaction.CreateFiFoBucketActivityForInvoice(PartToFIFOBucketMap, closedCOInvoiceHeaderId,updateStockBucketMap.values(),updateStockedMap, coLineItemsToUpdated);
            }
            
            if(coLineItemsToUpdated.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update coLineItemsToUpdated; 
            }  
            if(SoPaymentRoleList.Size()>0){
                if(AccessControl.ifObjectFieldIsUpdateable('So_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update SoPaymentRoleList;
            }
             
            if(invoicedDealFinanceMap.size() > 0 ){
                String dealFinanceId = '';
                for(String  Str : invoicedDealFinanceMap.Keyset()){
                    dealFinanceId = Str;
                    break;
                }
                if(String.isNotBlank(dealFinanceId)) {
                    if(AccessControl.ifObjectFieldIsUpdateable('Deal_Finance__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update new Deal_Finance__c(Id = dealFinanceId, Status__c = 'Paid');
                }
                CustomerOrderCtrl.UpdateOptionFeeStatus(coHeaderId);
            }
            if(invoicedDealMap.size() > 0 ){
                String dealId = '';
                for(String  Str : invoicedDealMap.Keyset()){
                    dealId = Str;
                    break;
                }                       
                CustomerOrderCtrl.finalizeDeal( dealId, activeCOInvoiceHeaderId, invoiceDate);
            }
            if(soLineItemInternalservice.size()>0){
                string UnitID = soLineItemInternalservice[0].Service_Order_Header__r.Customer_Owned_Unit__c;
                list<Unit_Price_Cost__c> listUnitPriceCostToInsert = CustomerOrderCtrl.createPriceAndCostLineItem(UnitID, soLineItemInternalservice,closedCOInvoiceHeaderId);
                if(listUnitPriceCostToInsert.size() > 0){
                    if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                        insert listUnitPriceCostToInsert;
                }                       
            }
               
            //Invoicing Deal Item Adding cost to option fee
            if(coLineItemDealservice.size() > 0 || soLineItemDealservice.size() > 0 || optionAndFeeRecListWithDoNotInvOption.size() > 0){
                List<Option_Fee__c> optionFeeListToUpdate = CustomerOrderCtrl.UpdateOptionFeeInvoice(coLineItemDealservice,soLineItemDealservice, optionAndFeeRecListWithDoNotInvOption);
                if(optionFeeListToUpdate.size() > 0 ){
                    if(AccessControl.ifObjectFieldIsUpdateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update optionFeeListToUpdate;
                    CustomerOrderCtrl.UpdateOptionFeeStatus(coHeaderId); 
                }
            }
             // Reverse Entry of Payment in Deposit if Payment is done from deposits.
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

            List<CO_Invoice_Payment__c> coInvoicePayments = new List<CO_Invoice_Payment__c>();
            closedCOInvoiceHeaderId = BPUtility.escapeSingleQuotes(closedCOInvoiceHeaderId);
            
            CO_Invoice_Header__c invoiceRec = calculateIndividualsTotalsForInvoice(closedCOInvoiceHeaderId);
            
            // Future Mathod to populate some Invoicing Fields
            if(!system.isFuture()) {
                populateFieldsOnInvoice_future(closedCOInvoiceHeaderId);
            }
            
            invoiceRec.Is_Discount_Shown__c = isDisplayDiscountAmountOnPrint;
            Set<Id> soheaderInvoiceIdSet = new Set<Id>(invoicedServiceOrderHeaderMap.keyset());
            soheaderInvoiceIdSet.addAll(invoiceableSOIdSet);
            
            CustomerOrderCtrl.updateSOHeaderList(soheaderInvoiceIdSet, closedCOInvoiceHeaderId);
            update invoiceRec;
            // Populate Totals.
            TaxCalculation.populateOrderTotal(coHeaderId);
            
            // Create Activity History.
            if(!Test.isRunningTest()) {
                ActivityHistory.createActivityHistory('Finalize Customer Invoice', 'Customer Invoice', closedCOInvoiceHeaderId, 'Customer', customerId, coHeaderId);
            }
             if(!Test.isRunningTest()) {
                CustomerOrderCtrl.calculateInvoiceCost(closedCOInvoiceHeaderId);
                populateIndividualsCostTotalsAfterFinalize(closedCOInvoiceHeaderId);
             }
             return 'Success';
        }catch(Exception e){
            Database.rollback(sp);
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));           
        }
    }
    public static void finalizeOrder(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType) {
        String currentFormattedDate = BPutility.getFormatedDateTime(datetime.newinstance(System.now().date(), System.now().time()));
        finalizeOrder(coInvoiceItemsJsonString, coHeaderId, currentCheckoutType, currentFormattedDate);
    }
    public static void finalizeOrder(String coInvoiceItemsJsonString, String coHeaderId, String currentCheckoutType, String invoiceDateStr) {
        Savepoint sp = Database.setSavepoint();
        try{
            DateTime invoiceDate = (invoiceDateStr != null) ? HomeSearchFilterInterface.getDateFromString(invoiceDateStr) : date.today();
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
            if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            
            coInvoiceItemsJsonString = BPUtility.getDecodedString(coInvoiceItemsJsonString);
            coHeaderId = BPUtility.getDecodedString(coHeaderId);
            currentCheckoutType = BPUtility.getDecodedString(currentCheckoutType);
        
            List<COInvoiceItem> coInvoiceItemObjList = (List<COInvoiceItem>) System.JSON.deserialize(coInvoiceItemsJsonString, List<COInvoiceItem>.class);
            Set<Id> coLineItemIdSet = new Set<Id>();
            Boolean isDisplayDiscountAmountOnPrint = false;
                
            for(COInvoiceItem coInvoiceItemObj : coInvoiceItemObjList) {
               coLineItemIdSet.add(coInvoiceItemObj.COLineItemId);
                if(coInvoiceItemObj.IsActive && coInvoiceItemObj.IsDisplayDiscountAmount != null && !isDisplayDiscountAmountOnPrint) {
                    isDisplayDiscountAmountOnPrint = coInvoiceItemObj.IsDisplayDiscountAmount;
                }
            }

            String activeCOInvoiceHeaderId = coInvoiceItemObjList[0].COInvoiceHeaderId;
            activeCOInvoiceHeaderId = BPUtility.escapeSingleQuotes(activeCOInvoiceHeaderId);
            if(activeCOInvoiceHeaderId == null ||  activeCOInvoiceHeaderId == ''){
                return; 
            }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            Map<String,List<CO_Invoice_Item__c>> coInvoiceTypeToLineItemMap =  new Map<String,List<CO_Invoice_Item__c>>();
            List<CO_Invoice_Item__c> closedCOInvoicItemList = [select   CO_Invoice_Header__c,SO_Payment_Role__c,Deal__c, CO_Kit_Header__c,Service_Order_Header__c,CO_Line_Item__c,CO_Line_Item__r.Closed_CO_Invoice_link__c, CO_Invoice_Header__r.Name from CO_Invoice_Item__c where CO_Invoice_Header__c = :activeCOInvoiceHeaderId];
            List<CO_Line_Item__c> coLineItemsToUpdated = new List<CO_Line_Item__c>();
            List<Service_Order_Line_Item__c> soLineItemInternalservice = new List<Service_Order_Line_Item__c>();
            Map<Id,CO_Invoice_Item__c> invoicedServiceOrderHeaderMap =new  Map<Id,CO_Invoice_Item__c>();
            Map<Id, CO_Invoice_Item__c > invoicedCoLineItemMap = new Map<Id, CO_Invoice_Item__c >();
            Map<Id, CO_Invoice_Item__c > invoicedCOKHMap = new Map<Id, CO_Invoice_Item__c >();
            Map<Id, CO_Invoice_Item__c > invoicedSoPaymentMap = new Map<Id, CO_Invoice_Item__c >();
            Map<Id, CO_Invoice_Item__c > invoicedDealMap = new Map<Id, CO_Invoice_Item__c >();
             
            List<Part__c> PartForPartReturnBuckets = new  List<Part__c>();
            for(CO_Invoice_Item__c coInoiceItemRec : closedCOInvoicItemList) {
                if(coInoiceItemRec.CO_Line_Item__c != null) {
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('ColiInvoice')) {
                        coInvoiceTypeToLineItemMap.Put('ColiInvoice',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('ColiInvoice').add(coInoiceItemRec);
                    invoicedCoLineItemMap.Put(coInoiceItemRec.CO_Line_Item__c,coInoiceItemRec );
                } else if(coInoiceItemRec.CO_Kit_Header__c !=null){
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('CoKitInvoice')) {
                        coInvoiceTypeToLineItemMap.Put('CoKitInvoice',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('CoKitInvoice').add(coInoiceItemRec);
                    invoicedCOKHMap.Put(coInoiceItemRec.CO_Kit_Header__c,coInoiceItemRec );
                } else if(coInoiceItemRec.Service_Order_Header__c !=null && coInoiceItemRec.SO_Payment_Role__c ==null){
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('SoKitInvoice')) {
                        coInvoiceTypeToLineItemMap.Put('SoKitInvoice',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('SoKitInvoice').add(coInoiceItemRec);
                    invoicedServiceOrderHeaderMap.Put(coInoiceItemRec.Service_Order_Header__c,coInoiceItemRec );
               } else if( coInoiceItemRec.SO_Payment_Role__c !=null) {
                    if(!coInvoiceTypeToLineItemMap.ContainsKey('SoPayment')) {
                        coInvoiceTypeToLineItemMap.Put('SoPayment',new List<CO_Invoice_Item__c>{ coInoiceItemRec});
                    }
                    coInvoiceTypeToLineItemMap.get('SoPayment').add(coInoiceItemRec);
                    invoicedSoPaymentMap.Put(coInoiceItemRec.SO_Payment_Role__c , coInoiceItemRec);
                } else if(coInoiceItemRec.Deal__c !=null){
                    invoicedDealMap.Put(coInoiceItemRec.Deal__c , coInoiceItemRec );
                }
            }                        
            
            List<CO_Line_Item__c> coLineItemDealservice = new List<CO_Line_Item__c>();
            List<Service_Order_Line_Item__c> soLineItemDealservice = new List<Service_Order_Line_Item__c>();
            List<Option_Fee__c> optionAndFeeRecListWithDoNotInvOption = new List<Option_Fee__c>();
            
            if(coInvoiceTypeToLineItemMap.containsKey('SoKitInvoice') ){
                if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }                
                List<Service_Order_Line_Item__c> serviceOrderLineItemFromInvoiceList  = new List<Service_Order_Line_Item__c>([Select Service_Order_Header__c,(Select Qty__c, Qty_Committed__c, Status__c, Price__c, part__c,part__r.Qty_In_Stock__c,
                                                                                                                        part__r.Qty_Committed__c,part__r.Last_Cost__c, Closed_CO_Invoice_link__c,Oversold_Qty__c From CO_Line_Items__r),
                                                                                                                        
                                                                                                                        (Select Id, CO_Line_Item__r.Price__c, Service_Order_Line_Item__r.Kit_Price__c from Options_Fees__r
                                                                                                                            where Do_Not_Invoice__c = true), 
                                                                    
                                                                                                                        Labour_Code__r.Description__c,Fee__r.Description__c, Part__r.Description__c, Qty_Needed__c,Retail_Price__c,Kit_Price__c,CO_Line_Item__c,Service_Order_Header__r.Customer_Owned_Unit__c,Service_Order_Header__r.SO_Type__c,
                                                                                                                        Item_Code__c, Item_Description__c, Service_Order_Header__r.Transaction_Type__r.Type__c,
                                                                                                                        Service_Order_Kit_Header__c, Service_Order_Kit_Header__r.Deal_Kit_Header__c, Option_Fee__c
                                                                                                                        
                                                                                                                        From Service_Order_Line_Item__c  where  Service_Order_Header__c  =: invoicedServiceOrderHeaderMap.KeySet()]);
                for( Service_Order_Line_Item__c serviceOrderLineItemFromInvoiceRec : serviceOrderLineItemFromInvoiceList  ){
                    if(invoicedServiceOrderHeaderMap.containsKey(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__c)){
                        CO_Invoice_Item__c   closedCOInvoiceItem =  invoicedServiceOrderHeaderMap.get(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__c);
                        if(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__r.SO_Type__c =='Internal Service'){
                            soLineItemInternalservice.add(serviceOrderLineItemFromInvoiceRec);
                        } else if(serviceOrderLineItemFromInvoiceRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Deal Service' ) {
                            soLineItemDealservice.add(serviceOrderLineItemFromInvoiceRec);
                            if(String.isNotBlank(serviceOrderLineItemFromInvoiceRec.Service_Order_Kit_Header__c) &&
                                    String.isNotBlank(serviceOrderLineItemFromInvoiceRec.Service_Order_Kit_Header__r.Deal_Kit_Header__c)) {
                                //dealKHIdSet.add(serviceOrderLineItemFromInvoiceRec.Service_Order_Kit_Header__r.Deal_Kit_Header__c);
                            } else {
                                optionAndFeeRecListWithDoNotInvOption.addAll(serviceOrderLineItemFromInvoiceRec.Options_Fees__r);
                            }
                        }
                        
                        List<CO_Line_Item__c> coliUpdateFromServiceOrderInvoiceList = new   List<CO_Line_Item__c>(serviceOrderLineItemFromInvoiceRec.CO_Line_Items__r);
                        for(CO_Line_Item__c colirec : coliUpdateFromServiceOrderInvoiceList ){
                            colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                            colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                            coLineItemsToUpdated.add(colirec);
                        }
                    }
                }
            }
                    
            if(coInvoiceTypeToLineItemMap.containsKey('ColiInvoice')) {
                if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }                    
                List<CO_Line_Item__c> ColiFromInvoiceList = [SELECT Qty__c, Qty_Committed__c, Price__c, Status__c,part__c,part__r.Qty_In_Stock__c, Related_Option_And_Fees__c,
                                                    (Select Id, CO_Line_Item__r.Price__c, Service_Order_Line_Item__r.Kit_Price__c from Options_Fees__r where Do_Not_Invoice__c = true),
                                                        Part__r.Qty_Committed__c,part__r.Last_Cost__c,closed_CO_Invoice_link__c,Oversold_Qty__c 
                                                        From CO_Line_Item__c where  Id =: invoicedCoLineItemMap.keySet()];
                for(CO_Line_Item__c colirec : ColiFromInvoiceList ){
                    CO_Invoice_Item__c closedCOInvoiceItem = invoicedCoLineItemMap.get(colirec.Id);
                    colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                    colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                    coLineItemsToUpdated.add(colirec);
                    if(String.isNotBlank(colirec.Related_Option_And_Fees__c)){
                        coLineItemDealservice.add(colirec);
                    }
                    optionAndFeeRecListWithDoNotInvOption.addAll(colirec.Options_Fees__r);
                 }
             }    

                 if(coInvoiceTypeToLineItemMap.containsKey('CoKitInvoice')){
                    if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    

                    List<CO_Kit_Header__c> ColiFromInvoiceList = [Select Id,(Select Qty__c, Qty_Committed__c, Price__c, Status__c,part__c,part__r.Qty_In_Stock__c, Related_Option_And_Fees__c,
                                                                    part__r.Qty_Committed__c,part__r.Last_Cost__c, Closed_CO_Invoice_link__c,Oversold_Qty__c From CO_Line_Items__r)
                                                                    From CO_Kit_Header__c where  Id =: invoicedCOKHMap.KeySet()];
                                                                                            
                    for( CO_Kit_Header__c coKitHeaderFromInvoiceRec : ColiFromInvoiceList ){
                        if(invoicedCOKHMap.containsKey(coKitHeaderFromInvoiceRec.Id)){
                            CO_Invoice_Item__c   closedCOInvoiceItem =  invoicedCOKHMap.get(coKitHeaderFromInvoiceRec.Id);
                            List<CO_Line_Item__c> coliUpdateFromServiceOrderInvoiceList = new   List<CO_Line_Item__c>(coKitHeaderFromInvoiceRec.CO_Line_Items__r);
                            for(CO_Line_Item__c colirec : coliUpdateFromServiceOrderInvoiceList ){
                                colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                                colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                                coLineItemsToUpdated.add(colirec);
                                if(String.isNotBlank(colirec.Related_Option_And_Fees__c)) {                                         
                                    coLineItemDealservice.add(colirec);
                                }
                            }
                        }
                    }
                }   

            Map<Id,Part__c> updateStockedMap = new Map<Id,Part__c>();
            Map<Id,Part__c> updateStockBucketMap = new Map<Id,Part__c>();
            Set<Id> invoiceableSOIdSet = new Set<Id>();
            List<So_Payment_Role__c> SoPaymentRoleList  = new List<So_Payment_Role__c>();
            Map<String, CO_Line_Item__c> coliIdTocoliRecRelatedToThirdPartyMap = new Map<String, CO_Line_Item__c>();
            if(coInvoiceTypeToLineItemMap.containsKey('SoPayment')) {  
                if(AccessControl.ifObjectFieldIsAccessible('So_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                if(AccessControl.ifObjectFieldIsAccessible('Claim_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

                SoPaymentRoleList  = new List<So_Payment_Role__c>([Select Id,RecordType.DeveloperName, Service_Order_Header__c, (select Id,Is_Variance__c,Approved_Qty__c,
                                                            Variance_Qty__c,Service_Order_Line_Item__c,Approved_Price__c, Service_Order_Line_Item__r.part__c,
                                                            Service_Order_Line_Item__r.part__r.Qty_In_Stock__c, Service_Order_Line_Item__r.part__r.Qty_Committed__c,
                                                            Service_Order_Line_Item__r.CO_Line_Item__c, 
                                                            Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c, 
                                                            Service_Order_Line_Item__r.Fee__c,
                                                            Service_Order_Line_Item__r.Qty_Needed__c,
                                                            Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c,Service_Order_Line_Item__r.part__r.Last_Cost__c 
                                                            From Claim_Line_Items__r) From So_Payment_Role__c  where  Id  IN : invoicedSoPaymentMap.KeySet()]);
                         
                for(So_Payment_Role__c SoPaymentRec: SoPaymentRoleList){
                    
                    CO_Invoice_Item__c closedCOInvoiceItem = invoicedSoPaymentMap.get(SoPaymentRec.Id);
                    
                    if(SoPaymentRec.RecordType.DeveloperName == 'Third_Party' ){
                        for(Claim_Line_Item__c ClaimLineItemrec : SoPaymentRec.Claim_Line_Items__r ){
                            if(ClaimLineItemrec.Service_Order_Line_Item__r.part__c!=null){
                                Part__c partRec = new part__c();
                                partRec.Id =  ClaimLineItemrec.Service_Order_Line_Item__r.part__c;
                                partRec.Qty_In_Stock__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_In_Stock__c;
                                partRec.Qty_Committed__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_Committed__c;
                                Decimal qtyNeed = ClaimLineItemrec.Approved_Qty__c;
                                Decimal quantityComitted = ClaimLineItemrec.Approved_Qty__c;
                                Decimal qtyOverSold = 0;
                                Decimal ReturnCost = ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c !=null ?  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c : 0 ; 
                                CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,updateStockBucketMap,qtyNeed,quantityComitted,partRec, PartForPartReturnBuckets, ReturnCost,qtyOverSold );
                            }
                            
                            if(String.isNotBlank(ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c)) {
                                CO_Line_Item__c colirec = new CO_Line_Item__c(Id = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c);
                                colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                                colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                                colirec.Part__c = ClaimLineItemrec.Service_Order_Line_Item__r.Part__c;
                                colirec.Fee__c = ClaimLineItemrec.Service_Order_Line_Item__r.Fee__c;
                                colirec.Oversold_Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c;
                                colirec.Qty_Committed__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c;
                                colirec.Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.Qty_Needed__c;
                                coliIdTocoliRecRelatedToThirdPartyMap.put(colirec.Id, colirec);
                            }
                        }
                        SoPaymentRec.Status__c = 'Invoiced';
                        invoiceableSOIdSet.add(SoPaymentRec.Service_Order_Header__c);
                    } else if(SoPaymentRec.RecordType.DeveloperName == 'Customer' ){
                        for(Claim_Line_Item__c ClaimLineItemrec : SoPaymentRec.Claim_Line_Items__r ){
                            if(ClaimLineItemrec.Service_Order_Line_Item__r.part__c!=null){
                                Part__c partRec = new part__c();
                                partRec.Id =  ClaimLineItemrec.Service_Order_Line_Item__r.part__c;
                                partRec.Qty_In_Stock__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_In_Stock__c;
                                partRec.Qty_Committed__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_Committed__c;
                                Decimal qtyNeed = ClaimLineItemrec.Variance_Qty__c;
                                Decimal quantityComitted = ClaimLineItemrec.Variance_Qty__c;
                                Decimal qtyOverSold = 0;
                                Decimal ReturnCost = ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c !=null ?  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c : 0 ; 
                                CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,updateStockBucketMap,qtyNeed,quantityComitted,partRec, PartForPartReturnBuckets, ReturnCost,qtyOverSold );
                            }
                            
                            if(String.isNotBlank(ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c)) {
                                CO_Line_Item__c colirec = new CO_Line_Item__c(Id = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c);
                                colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                                colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                                colirec.Part__c = ClaimLineItemrec.Service_Order_Line_Item__r.Part__c;
                                colirec.Fee__c = ClaimLineItemrec.Service_Order_Line_Item__r.Fee__c;
                                colirec.Oversold_Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c;
                                colirec.Qty_Committed__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c;
                                colirec.Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.Qty_Needed__c;
                                coliIdTocoliRecRelatedToThirdPartyMap.put(colirec.Id, colirec);
                            }
                        }
                        SoPaymentRec.Status__c = 'Invoiced';    
                    }else if(SoPaymentRec.RecordType.DeveloperName == 'Internal'){
                        for(Claim_Line_Item__c ClaimLineItemrec : SoPaymentRec.Claim_Line_Items__r ){
                            if(ClaimLineItemrec.Service_Order_Line_Item__r.part__c!=null){
                                Part__c partRec = new part__c();
                                partRec.Id =  ClaimLineItemrec.Service_Order_Line_Item__r.part__c;
                                partRec.Qty_In_Stock__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_In_Stock__c;
                                partRec.Qty_Committed__c =  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.Qty_Committed__c;
                                Decimal qtyNeed = ClaimLineItemrec.Variance_Qty__c;
                                Decimal quantityComitted = ClaimLineItemrec.Variance_Qty__c;
                                Decimal qtyOverSold = 0;
                                Decimal ReturnCost = ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c !=null ?  ClaimLineItemrec.Service_Order_Line_Item__r.part__r.last_cost__c : 0 ; 
                                CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,updateStockBucketMap,qtyNeed,quantityComitted,partRec, PartForPartReturnBuckets, ClaimLineItemrec.Approved_Price__c,qtyOverSold );
                            }
                            
                            if(String.isNotBlank(ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c)) {
                                CO_Line_Item__c colirec = new CO_Line_Item__c(Id = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__c);
                                colirec.Closed_CO_Invoice_link__c = closedCOInvoiceItem.CO_Invoice_Header__r.Name;
                                colirec.Invoice_Number__c = closedCOInvoiceItem.CO_Invoice_Header__c;
                                colirec.Part__c = ClaimLineItemrec.Service_Order_Line_Item__r.Part__c;
                                colirec.Fee__c = ClaimLineItemrec.Service_Order_Line_Item__r.Fee__c;
                                colirec.Oversold_Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Oversold_Qty__c;
                                colirec.Qty_Committed__c = ClaimLineItemrec.Service_Order_Line_Item__r.CO_Line_Item__r.Qty_Committed__c;
                                colirec.Qty__c = ClaimLineItemrec.Service_Order_Line_Item__r.Qty_Needed__c;
                                coliIdTocoliRecRelatedToThirdPartyMap.put(colirec.Id, colirec);
                            }
                        }
                        SoPaymentRec.Status__c = 'Invoiced'; 
                    }
                    else if(SoPaymentRec.RecordType.DeveloperName == 'deductible'){
                        SoPaymentRec.Deductible_Status__c = 'Paid';
                        SoPaymentRec.Status__c = 'Invoiced'; 
                    } 
                }                                                                                                    
            }
                
            Map<Id, Part__c> partIdToPartRecMap = new Map<Id, Part__c>(); 
            for(CO_Line_Item__c coLineItemsToUpdatedRec : coLineItemsToUpdated){
                if(coLineItemsToUpdatedRec.part__c !=null){
                    Decimal quantityComitted = coLineItemsToUpdatedRec.Qty_Committed__c  ==null ? 0 :coLineItemsToUpdatedRec.Qty_Committed__c;
                    Decimal qtyNeed = coLineItemsToUpdatedRec.Qty__c  ==null ? 0 :coLineItemsToUpdatedRec.Qty__c;
                    Decimal qtyOverSold = coLineItemsToUpdatedRec.Oversold_Qty__c;
                    Part__c  ObjPart = coLineItemsToUpdatedRec.part__r;
                    Decimal ReturnCost = coLineItemsToUpdatedRec.part__r.last_cost__c !=null ?  coLineItemsToUpdatedRec.part__r.last_cost__c : 0 ;
                    CustomerOrderCtrl.AddPartToPartMap(updateStockedMap,  updateStockBucketMap,qtyNeed,quantityComitted,ObjPart,
                             PartForPartReturnBuckets,ReturnCost,qtyOverSold);
                    partIdToPartRecMap.put(coLineItemsToUpdatedRec.Part__c, new Part__c(Id = coLineItemsToUpdatedRec.Part__c, Last_Sold__c = system.Now()));
                }
            }
            if(partIdToPartRecMap.size() > 0) { 
                if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update partIdToPartRecMap.values();
            }
                
            if(PartForPartReturnBuckets.size() > 0){
                FIFOTransaction.createFIFOBucketForCustomerReturn(PartForPartReturnBuckets, activeCOInvoiceHeaderId,coLineItemsToUpdated);
            } 
            List<Part_FIFO_Bucket__c>  PartFifoList=  SOQLUtil.getPartFIFOBucketByPartList(updateStockedMap.keySet());
            Map<Id,List<Part_FIFO_Bucket__c>> PartToFIFOBucketMap   = new Map<Id,List<Part_FIFO_Bucket__c>>();
            for(Part_FIFO_Bucket__c partFifoRec : PartFifoList){
                if(PartToFIFOBucketMap.containsKey(partFifoRec.part__c)){
                        PartToFIFOBucketMap.get(partFifoRec.part__c).add(partFifoRec);
                }else{ 
                    List<Part_FIFO_Bucket__c> listpartFifo  = new List<Part_FIFO_Bucket__c>();
                    listpartFifo.add(partFifoRec);
                    PartToFIFOBucketMap.put(partFifoRec.part__c, listpartFifo);
                } 
            }
            
            for(CO_Line_Item__c coliRec : coLineItemsToUpdated) {
                if(coliIdTocoliRecRelatedToThirdPartyMap.containskey(coliRec.Id)) {
                    coliIdTocoliRecRelatedToThirdPartyMap.remove(coliRec.Id);
                }
            }
            coLineItemsToUpdated.addAll(coliIdTocoliRecRelatedToThirdPartyMap.values());        
            List<Part__c> partFifoBucketValueToUpdate = new List<Part__c>(); 
            if(updateStockBucketMap.size()> 0){
                String Result =  FIFOTransaction.CreateFiFoBucketActivityForInvoice(PartToFIFOBucketMap, activeCOInvoiceHeaderId,updateStockBucketMap.values(),updateStockedMap, coLineItemsToUpdated);
            }
            
            if(coLineItemsToUpdated.size() > 0) {
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update coLineItemsToUpdated; 
            } 
            
            if(invoicedDealMap.size() > 0 ){
                    String dealId = '';
                    for(String  Str : invoicedDealMap.Keyset()){
                        dealId = Str;
                        break;
                    }                       
                    CustomerOrderCtrl.finalizeDeal( dealId, activeCOInvoiceHeaderId, invoiceDate);
            } 
            if(SoPaymentRoleList.Size()>0){
                if(AccessControl.ifObjectFieldIsUpdateable('So_Payment_Role__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                update SoPaymentRoleList;
            }
            if(soLineItemInternalservice.size()>0){
                string UnitID = soLineItemInternalservice[0].Service_Order_Header__r.Customer_Owned_Unit__c;
                list<Unit_Price_Cost__c> listUnitPriceCostToInsert = CustomerOrderCtrl.createPriceAndCostLineItem(UnitID, soLineItemInternalservice,activeCOInvoiceHeaderId);
                if(listUnitPriceCostToInsert.size() > 0){
                    if(AccessControl.ifObjectFieldIsCreateable('Unit_Price_Cost__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                    insert listUnitPriceCostToInsert;
                }           
            }

            
            //Invoicing Deal Item Adding cost to option fee
            if(coLineItemDealservice.size() > 0 || soLineItemDealservice.size() > 0 || optionAndFeeRecListWithDoNotInvOption.size() > 0){
                List<Option_Fee__c> optionFeeListToUpdate = CustomerOrderCtrl.UpdateOptionFeeInvoice(coLineItemDealservice,soLineItemDealservice, optionAndFeeRecListWithDoNotInvOption);
                if(optionFeeListToUpdate.size() > 0 ){
                    if(AccessControl.ifObjectFieldIsUpdateable('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update optionFeeListToUpdate;
                    CustomerOrderCtrl.updateOptionFeeStatusAndDealStatus(coHeaderId); 
                }
            }
            
            
            List<CO_Invoice_Payment__c> coInvoicePayments = new List<CO_Invoice_Payment__c>();
            activeCOInvoiceHeaderId = BPUtility.escapeSingleQuotes(activeCOInvoiceHeaderId);
            
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Payment__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            coHeaderId = BPUtility.escapeSingleQuotes(coHeaderId);
            activeCOInvoiceHeaderId = BPUtility.escapeSingleQuotes(activeCOInvoiceHeaderId);
            if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            CO_Header__c coHeaderRec =[select CO_Type__c, Customer__c, Order_status__c  from CO_Header__c  where Id = :coHeaderId ];
            CO_Invoice_Header__c coInvoiceHeaderRec = [select Invoice_Status__c from CO_Invoice_Header__c where Id = :activeCOInvoiceHeaderId];

            if(coInvoiceHeaderRec !=null &&  coHeaderRec != null ){
                if(AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                if(AccessControl.ifObjectFieldIsCreateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                

                coInvoiceHeaderRec.Invoice_Status__c = 'Closed';
                coInvoiceHeaderRec.Closed_Invoice_Date__c = system.now();
                coInvoiceHeaderRec.Checkout_Type__c = currentCheckoutType;
                coInvoiceHeaderRec.Invoice_Date__c = invoiceDate;
                coHeaderRec.Order_status__c='Closed';
                if(AccessControl.ifObjectIsCreateable('AutoNumberHolder__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
                AutoNumberHolder__c AutonumberRec = new AutoNumberHolder__c();
                insert AutonumberRec;
                if(AutonumberRec.Id !=null){
                    coInvoiceHeaderRec.AutoNumberHolder__c = AutonumberRec.Id;
                    if(AccessControl.ifObjectFieldIsUpdateable('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                    update coInvoiceHeaderRec;
                    update coHeaderRec;  

                }
                else{
                      throw new BlackPurlException('Unable to generate Invoice');
                }
            }           
            List<CO_Invoice_Header__c> invoiceRec = new List<CO_Invoice_Header__c>();
            invoiceRec.add(calculateIndividualsTotalsForInvoice(coInvoiceHeaderRec.Id));
            
            // Future Mathod to populate some Invoicing Fields
            if(!system.isFuture()) {
                populateFieldsOnInvoice_future(coInvoiceHeaderRec.Id);
            }
            
            if(invoiceRec.size()>0) {
                invoiceRec[0].Is_Discount_Shown__c = isDisplayDiscountAmountOnPrint;
            }
            Set<Id> soheaderInvoiceIdSet = new Set<Id>(invoicedServiceOrderHeaderMap.keyset());
            soheaderInvoiceIdSet.addAll(invoiceableSOIdSet);
            CustomerOrderCtrl.updateSOHeaderList(soheaderInvoiceIdSet, coInvoiceHeaderRec.Id);
            update invoiceRec;
            
            // Populate Totals.
            TaxCalculation.populateOrderTotal(coHeaderId);
            
            String customerId = coHeaderRec.Customer__c;
            // Create Activity History.
            if(!Test.isRunningTest()) {
                ActivityHistory.createActivityHistory('Finalize Customer Invoice', 'Customer Invoice', coInvoiceHeaderRec.Id, 'Customer', customerId, coHeaderId);
            }
            if(!Test.isRunningTest()){
                CustomerOrderCtrl.calculateInvoiceCost(coInvoiceHeaderRec.Id);
                populateIndividualsCostTotalsAfterFinalize(coInvoiceHeaderRec.Id);
            }
        }catch(Exception e){
            Database.rollback(sp);
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));           
        }
    }
    
    public static String saveCODeposit(String jsonString){
        try{
            List<CODeposit> coDepositObjList = CODeposit.parse(jsonString);
            List<CO_Deposit__c> coDepositListToUpdate = new List<CO_Deposit__c>();
            for(CODeposit coDepositObj : coDepositObjList) {
                CO_Deposit__c coDepositRec = new CO_Deposit__c();
                coDepositRec.Amount__c = coDepositObj.Amount ;
                coDepositRec.Payment_Method__c = coDepositObj.PaymentMethod ;
                coDepositRec.CO_Header__c = coDepositObj.coHeaderId;
                coDepositRec.Deal__c = coDepositObj.Deal;
                coDepositRec.Reverse_Link__c = coDepositObj.ReverseLink; 
                coDepositRec.Cash_Drawer__c = coDepositObj.CashDrawerId;
                DateTime dtValue = HomeSearchFilterInterface.getDateFromString(coDepositObj.PaymentDate);
            	coDepositRec.Payment_Date__c = (coDepositObj.PaymentDate !=null) ? Date.newInstance(dtValue.year(), dtValue.month(), dtValue.day()) : date.today();
                if( coDepositRec.Deal__c != null){
                    coDepositRec.Recorded_From__c = 'Customer';
                }
                if(coDepositObj.CODepositId != null) {
                    coDepositRec.Id = coDepositObj.CODepositId ;
                }
                coDepositListToUpdate.add(coDepositRec);
            }
            if(coDepositListToUpdate.size() > 0) {
                if(AccessControl.ifObjectFieldIsCreateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                if(AccessControl.ifObjectFieldIsUpdateable('CO_Deposit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }               
                upsert coDepositListToUpdate;
                List<Id> coDepositIdList = new List<Id>();
                for(CO_Deposit__c deposit: coDepositListToUpdate) {
                    coDepositIdList.add(deposit.Id);
                    
                } 
                CustomerOrderCtrl.createStoreCredit(coDepositIdList);
                if(String.isNotBlank(coDepositListToUpdate[0].Reverse_Link__c)) {
                    CO_Deposit__c coDepositRec = new CO_Deposit__c(Id = coDepositListToUpdate[0].Reverse_Link__c);
                    coDepositRec.Reverse_Link__c = coDepositListToUpdate[0].Id;
                    update coDepositRec;
                }
            }
            String coHeaderId;
            if(coDepositObjList.size() > 0) {
                coHeaderId = coDepositObjList[0].COHeaderId;
            } else {
                COHeaderId = null;
            }
            return COHeaderId;
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return BPUtility.getEncodedString('');
    }
    
    /*
    *   Method to calculate Part, Labour, fee sublet and Tax total on closed Invoice.
    */
    public static CO_Invoice_Header__c calculateIndividualsTotalsForInvoice(String coInvoiceId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        CO_Invoice_Header__c coInvoice = [SELECT Name, Total_Payment__c, CO_Header__r.Customer__r.Total_Store_Credit__c, Invoice_Status__c, CO_Header__r.Order_Status__c,
                                            (SELECT CO_Line_Item__c, Service_Order_Header__c, CO_Kit_Header__c, Deal__c,
                                            SO_Payment_Role__c, SO_Payment_Role__r.RecordType.DeveloperName, isActive__c 
                                            FROM CO_Invoice_Items__r)
                                            FROM CO_Invoice_Header__c WHERE Id =: coInvoiceId ];
        
        return calculateInvoiceTotals(new List<CO_Invoice_Header__c>{coInvoice});                                        
    }
    
    @future
    global static void populateIndividualsCostTotalsAfterFinalize(String coInvoiceId) {
    	DealService.populateDealIndividualsCostTotalsAfterFinalize(coInvoiceId); // Deal Totals
        ServiceJobService.populateSOIndividualsCostTotalsAfterFinalize(coInvoiceId); // Service Job/Deal Service Totals 
        MerchandiseService.populateMerchIndividualsCostTotalsAfterFinalize(coInvoiceId); // Merchandise /Deal Merchandise Totals
                                           
    } 
    
    public static CO_Invoice_Header__c calculateInvoiceTotals(List<CO_Invoice_Header__c> coInvoiceList) {
        
        if(coInvoiceList.size() == 0) {
            return new CO_Invoice_Header__c();
        }
        CO_Invoice_Header__c coInvoice = coInvoiceList[0]; 
        
        List<Id> coliIds = new List<Id>();  
        List<Id> sohIds = new List<Id>();
        List<Id> soPaymentRoleIds = new List<Id>();
        List<Id> cokhIds = new List<Id>();
        List<Id> dealIds = new List<Id>();      
                                                  
        for(CO_Invoice_Item__c coInvoiceItem : coInvoice.CO_Invoice_Items__r) {
            if(coInvoice.CO_Header__r.Order_Status__c == 'Quote' || (coInvoice.CO_Header__r.Order_Status__c != 'Quote' && coInvoiceItem.isActive__c)) {
                if(coInvoiceItem.CO_Line_Item__c != null) { 
                    coliIds.add(coInvoiceItem.CO_Line_Item__c);
                } else if(coInvoiceItem.Service_Order_Header__c != null) {
                    if(coInvoiceItem.SO_Payment_Role__c != null && coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Deductible') {
                        soPaymentRoleIds.add(coInvoiceItem.SO_Payment_Role__c);
                    } else {
                        sohIds.add(coInvoiceItem.Service_Order_Header__c);
                    }
                } else if(coInvoiceItem.Deal__c != null) {
                    dealIds.add(coInvoiceItem.Deal__c);
                } else if(coInvoiceItem.CO_Kit_Header__c != null) {
                    cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
                }
            }
         }
        
        List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
        List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
        List<SO_Payment_Role__c> soPaymentRoleList = new List<SO_Payment_Role__c>();
        List<CO_Kit_Header__c> coKitHeaderList = new List<CO_Kit_Header__c>();
        List<Deal__c> dealList = new List<Deal__c>();
        
        if(coliIds.size() > 0) {
            coliList = [SELECT Item_ID__c, Part__c, Fee__c, Qty__c, Qty_Committed__c, Price__c, Deal__c, Price_When_Tax_Included__c, Actual_Retail_Price__c, 
                             CO_Header__r.Order_status__c FROM CO_Line_Item__c WHERE Service_Order_Line_Item__c = null AND Id IN: coliIds];
        }
                                             
        if(sohIds.size() > 0) {                                   
            soHeaderList =  [select Total_Parts__c, Total_Fees__c, Total_Labor__c, Total_Sublet__c, Total_Shop_Supplies__c, Total_Discount__c,Transaction_Type__r.Type__c, (SELECT Id, Kit_Price__c, Labour_Code__c, 
                                      Part__c, Sublet__c, Qty_Needed__c, Total__c, Fee__c, Tax_Percent__c, Tax_Amount__c FROM Service_Order_Line_Items__r), (SELECT Id, RecordType.DeveloperName, Total_Amount__c FROM SO_Payment_Roles__r where RecordType.DeveloperName = 'Deductible') 
                                FROM Service_Order_Header__c WHERE Id IN: sohIds];
        }
        
        if(soPaymentRoleIds.size() > 0) {
            soPaymentRoleList =  [SELECT Id, Service_Order_Header__c, RecordType.DeveloperName, Total_Amount__c FROM SO_Payment_Role__c WHERE Id IN: soPaymentRoleIds];
        }
                                                                          
        if(cokhIds.size() > 0) {                                   
            coKitHeaderList =  [select Id, Total_Discount__c, Deal__c, Price__c, Tax_Amount__c, (SELECT Id, Part__c, Fee__c, Qty__c, Price__c, 
                                        Deal__c, Sub_Total_Without_Tax__c, Price_When_Tax_Included__c, Tax__c, Sub_Total_With_Tax__c
                                        FROM CO_Line_Items__r)  FROM CO_Kit_Header__c WHERE Id IN: cokhIds];
        }
        
        if(dealIds.size() > 0) {                                   
            dealList =  [select Id, Part_Total__c, Labour_Total__c, Fee_Total__c, Lien_Payout_Total__c, Warranty_Product_Total__c, Sublet_Total__c, 
                            Other_Product_Total__c, Trade_In_Total__c, Unit_Price_And_Cost_Total__c, Type__c, F_I_Total__c, F_I_Tax_Total__c, 
                            Product_Total__c, Stamp_Duty_Total__c, Deal_Commission__c, Salesperson__r.Technician_Name__c
                            FROM Deal__c 
                            WHERE Id IN: dealIds];
        }
                                                                        
        boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Decimal partTotal = 0;
        Decimal labourTotal = 0;
        Decimal feeTotal = 0;
        Decimal lienPayoutTotal = 0;
        Decimal subletTotal = 0;
        Decimal unitTotal = 0;
        Decimal tradeInsTotal = 0;
        Decimal warrantyProductTotal = 0;
        Decimal stampDutyTotal = 0;
        Decimal otherProductTotal = 0;
        Decimal productTotal = 0;
        Decimal shopSupplyTotal = 0;
        Decimal salesTaxTotal = 0;
        Decimal totalDiscount = 0;
        Decimal deductibleTotal = 0;
        Decimal fandIProductTotal = 0;
        Decimal dealCommission = 0;
        String salesperson = '';
        
        for(CO_Line_Item__c coli : coliList) {
            coli.Price__c = (coli.Price__c != null) ? coli.Price__c : 0;
            coli.Qty__c = (coli.Qty__c != null) ? coli.Qty__c : 0;
            coli.Actual_Retail_Price__c = (coli.Actual_Retail_Price__c != null) ? coli.Actual_Retail_Price__c : 0;
            Decimal discount = 0;
            if(coli.Part__c != null) {
                coli.Qty_Committed__c = (coli.Qty_Committed__c != null) ? coli.Qty_Committed__c : 0;
                Decimal qty = (!coli.Part__r.Non_Inventory_Part__c && coli.Qty__c > 0 && coli.CO_Header__r.Order_status__c != 'Quote') ? coli.Qty_Committed__c : coli.Qty__c;
                
                if(!isTaxIncludingPricing || String.isNotBlank(coli.Deal__c)) {
                    partTotal += (qty * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
                    if(qty > 0) {
                        discount = (coli.Actual_Retail_Price__c - coli.Price__c) * qty;
                    }
                } else {
                    if(coli.Price_When_Tax_Included__c == null) {
                        coli.Price_When_Tax_Included__c = 0;
                    }
                    partTotal += (qty * coli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    if(qty > 0) {
                        discount = (coli.Actual_Retail_Price__c - coli.Price_When_Tax_Included__c) * qty;
                    }
                }
                totalDiscount += (discount > 0) ? discount : 0;
            
            } else if(coli.Fee__c != null) {
                if(!isTaxIncludingPricing) {
                    feeTotal += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
                } else {
                    feeTotal += (coli.Qty__c * coli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                }
            }
        }
        
        Set<Id> soIdsToIncludeTax = new Set<Id>();
        
        for(SO_Payment_Role__c soPaymentRoleRec : soPaymentRoleList) {
            deductibleTotal += (soPaymentRoleRec.Total_Amount__c != null) ? soPaymentRoleRec.Total_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0;
            if(soPaymentRoleRec.RecordType.DeveloperName != 'Deductible' ) {
                soIdsToIncludeTax.add(soPaymentRoleRec.Service_Order_Header__c);
            }
        }
        
        for(Service_Order_Header__c soHeaderRec : soHeaderList) {
            soIdsToIncludeTax.add(soHeaderRec.Id);
            partTotal += (soHeaderRec.Total_Parts__c != null) ? soHeaderRec.Total_Parts__c.setScale(2, RoundingMode.HALF_UP) : 0;
            feeTotal += (soHeaderRec.Total_Fees__c != null) ? soHeaderRec.Total_Fees__c.setScale(2, RoundingMode.HALF_UP) : 0;
            labourTotal += (soHeaderRec.Total_Labor__c != null) ? soHeaderRec.Total_Labor__c.setScale(2, RoundingMode.HALF_UP) : 0;
            subletTotal += (soHeaderRec.Total_Sublet__c != null) ? soHeaderRec.Total_Sublet__c.setScale(2, RoundingMode.HALF_UP) : 0;
            productTotal += (soHeaderRec.Total_Sublet__c != null) ? soHeaderRec.Total_Sublet__c.setScale(2, RoundingMode.HALF_UP) : 0;
            shopSupplyTotal += (soHeaderRec.Total_Shop_Supplies__c != null) ? soHeaderRec.Total_Shop_Supplies__c.setScale(2, RoundingMode.HALF_UP) : 0;
            totalDiscount += ((soHeaderRec.Total_Discount__c != null) && (soHeaderRec.Total_Discount__c > 0)) ? soHeaderRec.Total_Discount__c : 0;
            if(soHeaderRec.Transaction_Type__r.Type__c == 'Third-Party' && soHeaderRec.SO_Payment_Roles__r.size() > 0) {
                deductibleTotal += (soHeaderRec.SO_Payment_Roles__r[0].Total_Amount__c != null) ? -1 * (soHeaderRec.SO_Payment_Roles__r[0].Total_Amount__c.setScale(2, RoundingMode.HALF_UP)) : 0;
            }
        }
                
        for(CO_Kit_Header__c coKitHeader : coKitHeaderList) {
            for(CO_Line_Item__c coli : coKitHeader.CO_Line_Items__r){
                if(coli.Part__c != null && coli.Qty__c != null && coli.Price__c != null){
                    if(!isTaxIncludingPricing || (isTaxIncludingPricing && coKitHeader.Deal__c != null)) {
                        partTotal += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
                    }else if(coli.Sub_Total_With_Tax__c != null) {
                        partTotal += (coli.Qty__c * coli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    }
                } else if(coli.Fee__c != null && coli.Qty__c != null && coli.Price__c != null){
                    if(!isTaxIncludingPricing || (isTaxIncludingPricing && coKitHeader.Deal__c != null)) {
                        feeTotal += (coli.Qty__c * coli.Price__c).setScale(2, RoundingMode.HALF_UP);
                    }else if(coli.Sub_Total_With_Tax__c != null){
                        feeTotal += (coli.Qty__c * coli.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            }
            totalDiscount += ((coKitHeader.Total_Discount__c != null) && (coKitHeader.Total_Discount__c > 0)) ? coKitHeader.Total_Discount__c : 0;
        }
        
        for(Deal__c dealRec : dealList) {
            unitTotal += (dealRec.Unit_Price_And_Cost_Total__c != null) ? dealRec.Unit_Price_And_Cost_Total__c : 0;
            partTotal += (dealRec.Part_Total__c != null) ? dealRec.Part_Total__c : 0;
            feeTotal += (dealRec.Fee_Total__c != null) ? dealRec.Fee_Total__c : 0;
            lienPayoutTotal += (dealRec.Lien_Payout_Total__c != null) ? dealRec.Lien_Payout_Total__c : 0;
            labourTotal += (dealRec.Labour_Total__c != null) ? dealRec.Labour_Total__c : 0;
            tradeInsTotal += (dealRec.Trade_In_Total__c != null) ? dealRec.Trade_In_Total__c : 0;
            warrantyProductTotal += (dealRec.Warranty_Product_Total__c != null) ? dealRec.Warranty_Product_Total__c : 0;
            subletTotal += (dealRec.Sublet_Total__c != null) ? dealRec.Sublet_Total__c : 0;
            otherProductTotal += (dealRec.Other_Product_Total__c != null) ? dealRec.Other_Product_Total__c : 0;
            productTotal += (dealRec.Product_Total__c != null) ? dealRec.Product_Total__c : 0;
            stampDutyTotal += (dealRec.Stamp_Duty_Total__c != null) ? dealRec.Stamp_Duty_Total__c : 0;
            dealCommission = (dealRec.Deal_Commission__c != null) ? dealRec.Deal_Commission__c : 0;
            salesperson = (dealRec.Salesperson__r.Technician_Name__c != null) ? dealRec.Salesperson__r.Technician_Name__c : '';
            
            if(dealRec.Type__c == Constants.FINANCED) {
                fandIProductTotal += (dealRec.F_I_Total__c != null) ? dealRec.F_I_Total__c : 0;
                if(isTaxIncludingPricing) {
                    fandIProductTotal += (dealRec.F_I_Tax_Total__c != null) ? dealRec.F_I_Tax_Total__c : 0;
                }
            }
        }
        
        TaxCalculation.isInvoiced = (coInvoice.Invoice_Status__c == 'Active') ? false : true;
        List<Individual_Tax__c> individualItemsList = getConditionalIndividualTaxList(isTaxIncludingPricing, TaxCalculation.isInvoiced, coliIds, cokhIds, 
                                                                    soIdsToIncludeTax, dealIds);
        /*if(isTaxIncludingPricing) {
            individualItemsList = getConditionalIndividualTaxList(isTaxIncludingPricing, TaxCalculation.isInvoiced, coliIds, cokhIds, 
                                                                    soIdsToIncludeTax, dealIds);
        } else {
            individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, Taxable_Amount_To_Invoice__c,
                                                        Taxable_Amount__c, Applicable_Tax__c, List_Tax_items_on_forms__c
                                                        from Individual_Tax__c where CO_Line_Item__c IN : coliIds
                                                            OR CO_Line_Item__r.CO_Kit_Header__c IN :cokhIds
                                                            OR (Service_Order_Line_Item__r.Service_Order_Header__c IN :soIdsToIncludeTax)
                                                            OR Option_Fee__r.Deal__c IN: dealIds
                                                            OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealIds
                                                            OR F_I_Product__r.Deal_Finance__r.Deal__c IN: dealIds
                                                            OR (Deal_Item__r.Deal__c IN: dealIds AND Deal_Item__r.Type__c = 'Trade In')];
        }*/
        
        Map<String, Decimal> salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);
        TaxCalculation.isInvoiced = true;
        for(String taxName : salesTaxNameToTaxValue.keySet()) {
            salesTaxTotal += salesTaxNameToTaxValue.get(taxName); 
        }
                                             
        coInvoice.Part_Total__c = partTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Labour_Total__c = labourTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Fee_Total__c = feeTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Lien_Payout_Total__c = lienPayoutTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Sublet_Total__c = subletTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Stamp_Duty_Total__c = stampDutyTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Unit_Total__c = unitTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Shop_Supplies_Total__c = shopSupplyTotal.setScale(2, RoundingMode.HALF_UP);
        
        coInvoice.Trade_In_Total__c = tradeInsTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Warranty_Product_Total__c = warrantyProductTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Other_Product_Total__c = otherProductTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Product_Total__c = productTotal.setScale(2, RoundingMode.HALF_UP);
        
        coInvoice.SalesTax_Total__c = salesTaxTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Discount_Amount__c = totalDiscount.setScale(2, RoundingMode.HALF_UP);
        coInvoice.F_I_Total__c = fandIProductTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Deductible_Total__c = deductibleTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Deal_Commission__c = dealCommission.setScale(2, RoundingMode.HALF_UP);
        coInvoice.Salesperson__c = String.isNotBlank(salesperson) ? salesperson : UserInfo.getName(); 
        // Added by TK : Update Total Variable on Invoice Header when Finalise Invoice/Order.
        coInvoice.Total__c = coInvoice.Part_Total__c + coInvoice.Labour_Total__c + coInvoice.Fee_Total__c + coInvoice.Lien_Payout_Total__c 
        								+ unitTotal + coInvoice.Trade_In_Total__c + coInvoice.Product_Total__c + coInvoice.Stamp_Duty_Total__c 
                                        + coInvoice.Shop_Supplies_Total__c + coInvoice.Deductible_Total__c + coInvoice.F_I_Total__c;
        if(!isTaxIncludingPricing){
            coInvoice.Total__c += coInvoice.SalesTax_Total__c;
        }
        return coInvoice;
    }
    
    // This method can be used if want to TO do calling for - TaxCalculation.getTaxAmountWithFormLabel()
    public static List<Individual_Tax__c> getConditionalIndividualTaxList(Boolean isTaxIncludingPricing, Boolean isInvoiced, 
                                                    List<Id> coliIds, List<Id> cokhIds,
                                                    Set<Id> soIdsToIncludeTax, List<Id> dealIds) {
        
        String query = 'SELECT CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, ';
        if(isTaxIncludingPricing) {
            query += (isInvoiced) ? 'Tax_Amount__c, ' : 'Tax_Amount_To_Invoice__c, ';
        } else {
            query += (isInvoiced) ? 'Taxable_Amount__c, ' : 'Taxable_Amount_To_Invoice__c, ';
        }
        query += 'Applicable_Tax__c, List_Tax_items_on_forms__c from Individual_Tax__c' + 
                 ' WHERE CO_Line_Item__c IN : coliIds OR CO_Line_Item__r.CO_Kit_Header__c IN :cokhIds OR ' +
                        'Service_Order_Line_Item__r.Service_Order_Header__c IN :soIdsToIncludeTax OR Option_Fee__r.Deal__c IN: dealIds OR ' +
                        'Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealIds OR F_I_Product__r.Deal_Finance__r.Deal__c IN: dealIds '+
                        'OR (Deal_Item__r.Deal__c IN: dealIds AND Deal_Item__r.Type__c = \'Trade In\')';
            
        return Database.query(query);
    }
    
    public static CO_Invoice_Header__c populateFieldsOnInvoice(Id coInvoiceId) {
        boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        CO_Invoice_Header__c coInvoice = [SELECT Name, Total_Payment__c, CO_Header__r.Customer__r.Total_Store_Credit__c, Invoice_Status__c, 
                                            (SELECT CO_Line_Item__c, Service_Order_Header__c, CO_Kit_Header__c, Deal__c,
                                            SO_Payment_Role__c, SO_Payment_Role__r.RecordType.DeveloperName 
                                            FROM CO_Invoice_Items__r)
                                            FROM CO_Invoice_Header__c WHERE Id =: coInvoiceId ];
        
        List<Id> coliIds = new List<Id>();  
        List<Id> sohIds = new List<Id>();
        List<Id> soPaymentRoleIds = new List<Id>();
        List<Id> cokhIds = new List<Id>();
        List<Id> dealIds = new List<Id>();                                                
        for(CO_Invoice_Item__c coInvoiceItem : coInvoice.CO_Invoice_Items__r) {
            if(coInvoiceItem.CO_Line_Item__c != null) { 
                coliIds.add(coInvoiceItem.CO_Line_Item__c);
            } else if(coInvoiceItem.CO_Kit_Header__c != null) {
                cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
            } else if(coInvoiceItem.Service_Order_Header__c != null) {
            	if(coInvoiceItem.SO_Payment_Role__c == null || coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName != 'Deductible') {
                    sohIds.add(coInvoiceItem.Service_Order_Header__c);
                }
            } else if(coInvoiceItem.Deal__c != null) {
                dealIds.add(coInvoiceItem.Deal__c);
            }
        }
        
        List<CO_Line_Item__c> coliList = new List<CO_Line_Item__c>();
        List<Service_Order_Line_Item__c> soliList = new List<Service_Order_Line_Item__c>();
        List<Option_Fee__c> optionFeeList = new List<Option_Fee__c>();
        List<Deal_Item__c> tradeInList = new List<Deal_Item__c>();
        List<Deal_Unit_Price_Cost__c> dealUnitPriceAndCostList = new List<Deal_Unit_Price_Cost__c>();
        List<F_I_Product__c> fAndIProductList = new List<F_I_Product__c>();
        if(coliIds.size() > 0 || cokhIds.size() > 0) {
            coliList = [SELECT Qty__c, Qty_Committed__c, Part__r.Non_Inventory_Part__c, Price__c, Deal__c, Price_When_Tax_Included__c, Actual_Retail_Price__c, Part__c, Fee__c, 
                            (Select Id from Individual_Taxes__r WHERE Tax_Rate__c > 0)
                           FROM CO_Line_Item__c WHERE Service_Order_Line_Item__c = null AND (Id IN: coliIds OR CO_Kit_Header__c IN: cokhIds)];
        }
                                             
        if(sohIds.size() > 0) {
            soliList = [SELECT Kit_Price__c, Qty_Needed__c, Part__c, Fee__c, Labour_Code__c, Sublet__c, (Select Id from Individual_Taxes__r WHERE Tax_Rate__c > 0)
                                FROM Service_Order_Line_Item__c where Service_Order_Header__c IN: sohIds];
        }
                                                                          
        if(dealIds.size() > 0) {
            optionFeeList = [SELECT Price__c, Qty__c, Part__c, Fee__c, Labour_Code__c, Product__c, Product__r.Type__c, (Select Id from Individual_Taxes__r WHERE Tax_Rate__c > 0) 
                                from Option_Fee__c where Deal__c IN: dealIds];
            tradeInList = [SELECT Agreed_Value__c, Default_Unit_Sales_Tax_Percentage__c, (Select Id from Individual_Taxes__r WHERE Tax_Rate__c > 0)
                                from Deal_Item__c WHERE Type__c = 'Trade In' AND Deal__c IN: dealIds];
            
            dealUnitPriceAndCostList = [Select Qty__c, Price__c, (Select Id from Individual_Taxes__r WHERE Tax_Rate__c > 0) 
                            from Deal_Unit_Price_Cost__c where Deal_Item__r.Deal__c IN: dealIds];
                            
            fAndIProductList = [Select Price__c, Sales_Tax__c, (Select Id from Individual_Taxes__r WHERE Tax_Rate__c > 0) 
                            from F_I_Product__c where Deal__c IN: dealIds OR Deal_Finance__r.Deal__c IN: dealIds];
        }
        
        Decimal taxableAmount = 0, nonTaxableAmount = 0;
        //Pre Tax Totals
        Decimal preTaxPartTotal = 0, preTaxLabourTotal = 0, preTaxFeeTotal = 0, preTaxSubletTotal = 0, preTaxUnitTotal = 0, preTaxTradeInsTotal = 0;
        Decimal preTaxWarrantyProductTotal = 0, preTaxOtherProductTotal = 0, preTaxShopSupplyTotal = 0;

        for(CO_Line_Item__c coliRec : coliList) {
            coliRec.Price__c = (coliRec.Price__c != null) ? coliRec.Price__c : 0;
            coliRec.Qty__c = (coliRec.Qty__c != null) ? coliRec.Qty__c : 0;
            if(coliRec.Individual_Taxes__r.size() > 0) {
                taxableAmount += (coliRec.Price__c * coliRec.Qty__c);
            } else {
                nonTaxableAmount += (coliRec.Price__c * coliRec.Qty__c);
            }
            
            if(coliRec.Part__c != null) {
                coliRec.Qty_Committed__c = (coliRec.Qty_Committed__c != null) ? coliRec.Qty_Committed__c : 0;
                Decimal qty = (!coliRec.Part__r.Non_Inventory_Part__c && coliRec.Qty__c > 0 ? coliRec.Qty_Committed__c : coliRec.Qty__c);
                preTaxPartTotal += (qty * coliRec.Price__c).setScale(2, RoundingMode.HALF_UP);
            } else if(coliRec.Fee__c != null) {
                preTaxFeeTotal += (coliRec.Qty__c * coliRec.Price__c).setScale(2, RoundingMode.HALF_UP);
            }
        }
        
        for(Service_Order_Line_Item__c soliRec : soliList) {
            soliRec.Kit_Price__c = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c.setScale(2, RoundingMode.HALF_UP) : 0;
            soliRec.Qty_Needed__c = (soliRec.Qty_Needed__c != null) ? soliRec.Qty_Needed__c : 0;
            if(soliRec.Individual_Taxes__r.size() > 0) {
                taxableAmount += (soliRec.Kit_Price__c * soliRec.Qty_Needed__c);
            } else {
                nonTaxableAmount += (soliRec.Kit_Price__c * soliRec.Qty_Needed__c);
            }
            
            Decimal total = (soliRec.Qty_Needed__c * soliRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP);
            if(soliRec.Fee__c != null) {
                if(soliRec.Type__c == Constants.SHOP_SUPPLY) {
                    preTaxShopSupplyTotal += total;
                } else {
                    preTaxfeeTotal += total;
                }
            } else if(soliRec.Part__c != null) {
                preTaxPartTotal += total;
            } else if(soliRec.Labour_Code__c != null) {
                preTaxLabourTotal += total;
            } else if(soliRec.Sublet__c != null) {
                preTaxSubletTotal += total;
            }
        }
        
        for(Option_Fee__c optionFeeRec : optionFeeList) {
            optionFeeRec.Price__c = (optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0;
            optionFeeRec.Qty__c = (optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0;
            if(optionFeeRec.Individual_Taxes__r.size() > 0) {
                taxableAmount += (optionFeeRec.Price__c * optionFeeRec.Qty__c);
            } else {
                nonTaxableAmount += (optionFeeRec.Price__c * optionFeeRec.Qty__c);
            }
            
            Decimal total = (optionFeeRec.Qty__c * optionFeeRec.Price__c).setScale(2, RoundingMode.HALF_UP);
            if(optionFeeRec.Part__c != null) {
                preTaxPartTotal += total;
            } else if(optionFeeRec.Labour_Code__c != null) {
                preTaxLabourTotal += total;
            } else if(optionFeeRec.Fee__c != null) {
                preTaxFeeTotal += total;
            } else if(optionFeeRec.Product__c != null) {
                if(optionFeeRec.Product__r.Type__c == Constants.WARRANTY_PLAN) {
                    preTaxWarrantyProductTotal += total;
                } else if(optionFeeRec.Product__r.Type__c == Constants.SUBLET) {
                    preTaxSubletTotal += total;
                } else {
                    preTaxOtherProductTotal += total;
                }
            }
        }
        
        for(Deal_Item__c trandeInRec : tradeInList) {
            
            trandeInRec.Agreed_Value__c = (trandeInRec.Agreed_Value__c != null) ? trandeInRec.Agreed_Value__c : 0;
            if(trandeInRec.Individual_Taxes__r.size() > 0) {
                taxableAmount -= trandeInRec.Agreed_Value__c;
            } else {
                nonTaxableAmount -= trandeInRec.Agreed_Value__c;
            }
            
            trandeInRec.Agreed_Value__c = trandeInRec.Agreed_Value__c.setScale(2, RoundingMode.HALF_UP);
            trandeInRec.Default_Unit_Sales_Tax_Percentage__c = (trandeInRec.Default_Unit_Sales_Tax_Percentage__c != null) ? trandeInRec.Default_Unit_Sales_Tax_Percentage__c : 0;
            preTaxTradeInsTotal -= (trandeInRec.Agreed_Value__c / (1 + trandeInRec.Default_Unit_Sales_Tax_Percentage__c/100)).setScale(2, RoundingMode.HALF_UP);
        }
        
        for(Deal_Unit_Price_Cost__c dupcRec : dealUnitPriceAndCostList) {
            dupcRec.Qty__c = (dupcRec.Qty__c != null) ? dupcRec.Qty__c : 0;
            dupcRec.Price__c = (dupcRec.Price__c != null) ? dupcRec.Price__c : 0;
            if(dupcRec.Individual_Taxes__r.size() > 0) {
                taxableAmount += (dupcRec.Price__c * dupcRec.Qty__c);
            } else {
                nonTaxableAmount += (dupcRec.Price__c * dupcRec.Qty__c);
            }
            preTaxUnitTotal += (dupcRec.Price__c * dupcRec.Qty__c).setScale(2, RoundingMode.HALF_UP);
        }
         
        for(F_I_Product__c fAndIProductRec : fAndIProductList) {
            fAndIProductRec.Price__c = (fAndIProductRec.Price__c != null) ? fAndIProductRec.Price__c : 0;
            
            if(fAndIProductRec.Individual_Taxes__r.size() > 0) { 
                taxableAmount += fAndIProductRec.Price__c;
            } else {
                nonTaxableAmount += fAndIProductRec.Price__c;
            }
        }
        
        CO_Invoice_Header__c coInvoiceRec = new CO_Invoice_Header__c(Id = coInvoiceId);
        coInvoiceRec.Taxable_Total__c = taxableAmount;
        coInvoiceRec.Non_Taxable_Total__c = nonTaxableAmount;
        
        //Pre Tax totals
        coInvoiceRec.Pre_Tax_Part_Total__c = preTaxPartTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoiceRec.Pre_Tax_Labour_Total__c = preTaxLabourTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoiceRec.Pre_Tax_Fee_Total__c = preTaxFeeTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoiceRec.Pre_Tax_Sublet_Total__c = preTaxSubletTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoiceRec.Pre_Tax_Unit_Total__c = preTaxUnitTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoiceRec.Pre_Tax_Shop_Supplies_Total__c = preTaxShopSupplyTotal.setScale(2, RoundingMode.HALF_UP);
        
        coInvoiceRec.Pre_Tax_Trade_In_Total__c = preTaxTradeInsTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoiceRec.Pre_Tax_Warranty_Product_Total__c = preTaxWarrantyProductTotal.setScale(2, RoundingMode.HALF_UP);
        coInvoiceRec.Pre_Tax_Other_Product_Total__c = preTaxOtherProductTotal.setScale(2, RoundingMode.HALF_UP);
        return coInvoiceRec;
    }
    
    @future
    public static void populateFieldsOnInvoice_future(Id coInvoiceId) {
        update populateFieldsOnInvoice(coInvoiceId);
    }
    
    public static void updateCOPricingAndTaxOnKit(String coHeaderId, String customerId) {
        if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        try{
            COLineItemTriggerHelper.isTotalCalculated = false;
            COKH_Recalcualtion.changePriceWhenCustomerIsChanged(coHeaderId);
            //COKH_Recalcualtion.AddCustomerCoForKititemUpdate(customerId, coHeaderId);
            //SO_KLI_Recalculation.SOPriceCalcultaionByPriceLevel(customerId, coHeaderId);
            SO_KLI_Recalculation.changePriceWhenCustomerIsChanged( new Set<Id>(), coHeaderId);
            DealKH_Recalculation.changePriceWhenCustomerIsChanged(customerId, coHeaderId);
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static void moveLineItem(String sectionFrom, String sectionTo, String idToMove, String coHeaderId) {
        sectionFrom = BPUtility.getDecodedString(sectionFrom);
        sectionTo = BPUtility.getDecodedString(sectionTo);
        idToMove = BPUtility.getDecodedString(idToMove);
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        
        // set Swap Flag
        String objectAPIName = Id.valueOf(idToMove).getSObjectType().getDescribe().getName();
        if(sectionFrom == 'Merchandise') { 
            if(objectAPIName == CONSTANTS.NAMESPACE + 'CO_Line_Item__c'){
                String result = CustomerOrderCtrl.MoveFromColiToSoli(idToMove, sectionTo);
            } else if(objectAPIName == CONSTANTS.NAMESPACE + 'CO_Kit_Header__c' ){
                String result = CustomerOrderCtrl.MoveFromCokhSokh(idToMove, sectionTo);
            }
        } else if(sectionTo == 'Merchandise') {
            if(objectAPIName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c') {
                String result = CustomerOrderCtrl.MoveFromSoliToColi(idToMove, null);
            }else if ( objectAPIName == CONSTANTS.NAMESPACE + 'Service_Order_Kit_Header__c'){
                String result = CustomerOrderCtrl.MoveFromSokhCOKH(idToMove, null, coHeaderId);
            }
            
            List<CO_Header__c> coHeaderList = [Select Hide_Merchandise_Section__c, (Select Id from CO_Line_Items__r where Service_Order_Line_Item__c = null), (Select Id from CO_Kit_Headers__r) 
                                                    from CO_Header__c where Id =: coHeaderId];
            if((coHeaderList.size() > 0) && coHeaderList[0].Hide_Merchandise_Section__c && ((coHeaderList[0].CO_Line_Items__r.size() > 0) || (coHeaderList[0].CO_Kit_Headers__r.size() > 0))) {
                updateMerchSectionToDisplay(CoHeaderId, false);
            }
        
        } else {
            if(objectAPIName == CONSTANTS.NAMESPACE + 'Service_Order_Line_Item__c') {
                String result = CustomerOrderCtrl.MoveFromSoliToColi(idToMove, sectionTo);
            }else if (objectAPIName == CONSTANTS.NAMESPACE + 'Service_Order_Kit_Header__c') {
                String result = CustomerOrderCtrl.MoveFromSokhCOKH(idToMove,sectionTo,CoheaderId);
            }
        }
    }
       
    public static String addRelatedPartInSO(String partIdsString, String soHeaderId) {
    	try{
    		if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        if(AccessControl.ifObjectFieldIsCreateable('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	        
	        List<String> partIds = (List<String>) System.JSON.deserialize(partIdsString, List<String>.class);
	        List<COService.SearchPartDetailWrapper> partToInsertList = new List<COService.SearchPartDetailWrapper>();
            for(String partId : partIds) {
            	COService.SearchPartDetailWrapper partObj = new COService.SearchPartDetailWrapper();
            	partObj.PartId = partId;
            	partObj.Qty = 1;
            	partToInsertList.add(partObj);
            }
            return ServiceJobService.addMultiplePartsInServiceJob(partToInsertList, soHeaderId);
            
        }catch(Exception e){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return null;
    }
    
    public static String closeCustomerOrder(String coHeaderId) {
        try {
            CO_Header__c coHeaderRec =[select CO_Type__c, Customer__c, Order_status__c  from CO_Header__c  where Id = :coHeaderId ];
            coHeaderRec.Order_status__c = 'Closed';
            update coHeaderRec;
            return BPUtility.getEncodedString('SUCCESS');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static List<Id> getUnitIdList(Id recordId) {
        try {
            List<Id> unitIdList = new List<Id>();
            if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'CO_Header__c') {
                List<Service_Order_Header__c> soHeadersList = [select Id, Customer_Owned_Unit__c from Service_Order_Header__c where CO_Header__c =: recordId];
                List<Deal__c> dealList = [select Id, (select Id, Customer_Owned_Unit__c from Deal_Items__r) from Deal__c where CO_Header__c =: recordId];
                
                for(Service_Order_Header__c soHeaderRec : soHeadersList) {
                    if(soHeaderRec.Customer_Owned_Unit__c != null) {
                        unitIdList.add(soHeaderRec.Customer_Owned_Unit__c);
                    }
                }
                if(dealList.size() > 0) {
                    for(Deal_Item__c dealItemRec : dealList[0].Deal_Items__r) {
                        if(dealItemRec.Customer_Owned_Unit__c != null) {
                            unitIdList.add(dealItemRec.Customer_Owned_Unit__c);
                        }
                    }
                }
            } else if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'Customer_Owned_Unit__c') {
                unitIdList.add(recordId);
            }
            return unitIdList;
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    public static List<UnitWrapper.Documents> getUnitImages(String unitId, Boolean isPrimary) {
        List<UnitWrapper.Documents> imageList = new List<UnitWrapper.Documents>();
        if(AccessControl.ifObjectFieldIsAccessible('Document__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Document__c> docList = [select Id, Is_Primary__c, 
                                        (select Id, Name from Attachments) from Document__c where Unit__c = :unitId order By CreatedDate ASC];
        
        for(Document__c doc : docList) {
            if(isPrimary) {
                if(doc.Is_Primary__c) {
                    imageList.add(new UnitWrapper.Documents(doc));
                    break;
                }
            } else {
                imageList.add(new UnitWrapper.Documents(doc));
            }
        }
        return imageList;
    }
       
    public static Map<String, List<SearchPartDetailWrapper>> addPartsSmartItems(String partsInfoJson, String sectionName, String sectionHeaderId) {
    	List<SearchPartDetailWrapper> searchPartsDetailObjList = (List<SearchPartDetailWrapper>) System.JSON.deserialize(partsInfoJson, List<SearchPartDetailWrapper>.class);
    	
    	//Get DealerVu to BP Vendor code mapping records
    	List<Partsmart_To_BP_Vendor_Code_Mapping__c> vendorCodeMappingList = [SELECT Id, Name, BP_Vendor_Code__c FROM Partsmart_To_BP_Vendor_Code_Mapping__c limit :SOQLUtil.getAvailableQueryRowsLimit()];
    	Map<String, String> partsmartToBPVendorCodeMap = new Map<String, String>();
    	for(Partsmart_To_BP_Vendor_Code_Mapping__c vendorCodeObj : vendorCodeMappingList) {
    		partsmartToBPVendorCodeMap.put(vendorCodeObj.Name, vendorCodeObj.BP_Vendor_Code__c);
    	}
    	
    	Set<String> partNumberSet = new Set<String>();
    	for(SearchPartDetailWrapper partInfoObj : searchPartsDetailObjList) {
    		if(partsmartToBPVendorCodeMap.containsKey(partInfoObj.Manufacturer)) {
    			partNumberSet.add(partInfoObj.PartNumber + partsmartToBPVendorCodeMap.get(partInfoObj.Manufacturer));
    		}
    	}
    	Map<Id, Part__c> partIdToRecMap = new Map<Id, Part__c>();
    	//Query Part
    	if(partNumberSet.size() > 0) {
    		String query = 'Select Id, AvailableParts__c, Retail_Price__c, Part_Id__c, Item_Description__c, Non_Inventory_Part__c from Part__c where Part_Id__c IN: partNumberSet';
	    	partIdToRecMap = new Map<Id, Part__c>((List<Part__c>)Database.query(query));
    	}
    	List<SearchPartDetailWrapper> partNotInSystemList = new List<SearchPartDetailWrapper>();
    	List<SearchPartDetailWrapper> partToInsertList = new List<SearchPartDetailWrapper>();
    	List<SearchPartDetailWrapper> outOfStockPartList = (sectionName == Constants.CASH_SALE) ? new List<SearchPartDetailWrapper>() : null;
    	for(SearchPartDetailWrapper partInfoObj : searchPartsDetailObjList) {
    		Boolean isPartFound = false;
    		for(Part__c partRec : partIdToRecMap.values()) {
	    		if(partRec.Part_Id__c == (partInfoObj.PartNumber + partsmartToBPVendorCodeMap.get(partInfoObj.Manufacturer))) {
		    		partInfoObj.PartId = partRec.Id;
		    		partInfoObj.Price = partRec.Retail_Price__c;
		    		if(!partRec.Non_Inventory_Part__c && sectionName == Constants.CASH_SALE && partRec.AvailableParts__c < partInfoObj.Qty) {
		    			partInfoObj.AvailableParts = partRec.AvailableParts__c;
		    			partInfoObj.Item = partRec.Item_Description__c;
		    			outOfStockPartList.add(partInfoObj);
		    		} else {
		    			partToInsertList.add(partInfoObj);
		    		}
	    			isPartFound = true;
	    			break;
	    		}
	    	}
	    	if(!isPartFound) {
	    		partNotInSystemList.add(partInfoObj);
	    	}
    	}
    	if(partToInsertList.size() > 0) {
    		addPartsInRespectiveSections(partToInsertList, sectionName, sectionHeaderId);
    	}
    	return new Map<String, List<SearchPartDetailWrapper>>{'Out of stock parts' => outOfStockPartList, 
    														'In stock parts' => partToInsertList, 
    														'Parts not found' => partNotInSystemList};
    }
    
    /*
    *   
    */
    public static CustomerDetail.Company getBussinessProfileData() {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
		List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
		CustomerDetail.Company CompanyInfo;
		if(businessProfileList.size() > 0) {
			CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
		} else {
			CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
		}
		return CompanyInfo;
    }
    
    public static void addPartsInRespectiveSections(List<SearchPartDetailWrapper> partToInsertList, String sectionName, String sectionHeaderId) {
    	if(sectionName == 'Merchandise' || sectionName == 'Deal Merchandise') {
    		List<COLIWrapper> coliListToInsert = new List<COLIWrapper>();
    		for(SearchPartDetailWrapper partInfoObj : partToInsertList) {
	    		COLIWrapper coliObj = new COLIWrapper(new CO_Line_Item__c(Part__c = partInfoObj.PartId));
	    		coliObj.Qty = partInfoObj.Qty;
	    		coliObj.Price = partInfoObj.Price;
	    		coliObj.DealId = partInfoObj.DealId;
	    		coliListToInsert.add(coliObj);
    		}
    		CustomerOrderCtrl_V2.saveCOLineItem(BPUtility.getEncodedString(sectionHeaderId), BPUtility.getEncodedString(System.JSON.serialize(coliListToInsert)), null);
    		
    	} else {
    		if(sectionName == 'Service Job' || sectionName == 'Deal Service Job') {
	    		ServiceJobService.addMultiplePartsInServiceJob(partToInsertList, sectionHeaderId); 
	    	} else if(sectionName == 'Deal') {
	    		DealService.addMultiplePartsInDeal(partToInsertList, sectionHeaderId);
	    	}
    	}
    }
    
    public class SearchPartDetailWrapper {
    	public String PartNumber;
    	public String Manufacturer;
    	public Decimal Qty;
    	public String PartId;
    	public Decimal Price;
    	public String DealId;
    	public Decimal AvailableParts;
    	public String Item;
    }
    
    public static ProfitabilityWrapper getCOProfitability(String coId) {
    	
    	List<ProfitabilityWrapper.SectionProfitabilityWrapper> profitabilityWrapperList = new List<ProfitabilityWrapper.SectionProfitabilityWrapper>();
    	profitabilityWrapperList.addAll(DealService.getDealProfitability(coId));
    	
    	Map<String, List<ProfitabilityWrapper.SectionProfitabilityWrapper>> sectionTypeToProfitabilityWrapperMap = new Map<String, List<ProfitabilityWrapper.SectionProfitabilityWrapper>>();
    	sectionTypeToProfitabilityWrapperMap.putAll(ServiceJobService.getServiceJobProfitability(coId));
    	Map<String, ProfitabilityWrapper.SectionProfitabilityWrapper> merchTypeToProfitabilityWrapperMap = MerchandiseService.getMerchAndDealMerchProfitability(coId);
    	
    	if(sectionTypeToProfitabilityWrapperMap.containsKey('Service Job')) {
    		profitabilityWrapperList.addAll(sectionTypeToProfitabilityWrapperMap.get('Service Job'));
    	}
    	if(merchTypeToProfitabilityWrapperMap != null && merchTypeToProfitabilityWrapperMap.containsKey('Parts & Accessories')) {
    		profitabilityWrapperList.add(merchTypeToProfitabilityWrapperMap.get('Parts & Accessories'));
    	}
    	if(sectionTypeToProfitabilityWrapperMap.containsKey('Deal Service Job')) {
    		profitabilityWrapperList.addAll(sectionTypeToProfitabilityWrapperMap.get('Deal Service Job'));
    	}
    	if(merchTypeToProfitabilityWrapperMap != null && merchTypeToProfitabilityWrapperMap.containsKey('Deal Merchandise')) {
    		profitabilityWrapperList.add(merchTypeToProfitabilityWrapperMap.get('Deal Merchandise'));
    	}    	
    	ProfitabilityWrapper coProfitabilityObj = new ProfitabilityWrapper(profitabilityWrapperList);
       	return coProfitabilityObj;
    }
    
    /**
     * Name: updateMileageOnUnitsWithSoOdometerOut
     * Desc: Method to update Mileage value on unit records with the Odometer OUT value from the service job; when service jobs are invoiced.
     * @param: soHeaderIdSet - String - Id set of SO headers
     * @return:
    **/
    public static void updateMileageOnUnitsWithSoOdometerOut(Set<Id> soHeaderIdSet) { 	
	 	if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	 	List<Service_Order_Header__c> soHeaderList = [SELECT Id, Odometer_on_Departure__c, Customer_Owned_Unit__c FROM Service_Order_Header__c 
	 														WHERE Id IN: soHeaderIdSet AND Customer_Owned_Unit__c != null];
	 	
	 	if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	 	Map<String, Customer_Owned_Unit__c> couIdToCOURecMap = new Map<String, Customer_Owned_Unit__c>(); 												
	 	for(Service_Order_Header__c soHeaderRec : soHeaderList) {
            if(!couIdToCOURecMap.containsKey(soHeaderRec.Customer_Owned_Unit__c)) {
                couIdToCOURecMap.put(soHeaderRec.Customer_Owned_Unit__c, 
									  new Customer_Owned_Unit__c(Id = soHeaderRec.Customer_Owned_Unit__c, Mileage_Value__c = soHeaderRec.Odometer_on_Departure__c));
            } else if(soHeaderRec.Odometer_on_Departure__c > couIdToCOURecMap.get(soHeaderRec.Customer_Owned_Unit__c).Mileage_Value__c) {
            	couIdToCOURecMap.get(soHeaderRec.Customer_Owned_Unit__c).Mileage_Value__c = soHeaderRec.Odometer_on_Departure__c;
            }
	 	}
	 	
	 	if(couIdToCOURecMap.size() > 0)	{
	 		if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	 		update couIdToCOURecMap.values();
	 	}									
	 }
	 
	 /**
     * Name: closeCO when last CO item is deleted
     * Desc: Method to closeCO when last CO item is deleted.
     * @param: CoHeaderId - String - Id of Co Header
     * @return:
    **/
    public static String validateAndCloseCO(String coHeaderId) {   
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Invoice_Header__c> coInvoiceHeaderList = [SELECT CO_Header__r.Order_status__c, Invoice_Status__c, (Select Id from CO_Invoice_Items__r) FROM CO_Invoice_Header__c 
                                                            WHERE CO_Header__c =: coHeaderId Order by CreatedDate Desc limit 2];
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        Map<String, CO_Header__c> coHeaderIdToRecMap = new Map<String, CO_Header__c>();
        if(coInvoiceHeaderList.size() == 0 || (coInvoiceHeaderList.size() == 1 && coInvoiceHeaderList[0].Invoice_Status__c != 'Active')) {
    		return coInvoiceHeaderList.size() > 0 ? coInvoiceHeaderList[0].CO_Header__r.Order_status__c : 'Open';
        } else if(coInvoiceHeaderList.size() > 1) {
        	for(CO_Invoice_Header__c coInvRec : coInvoiceHeaderList) {
        		if(coInvRec.Invoice_Status__c == 'Active' && coInvRec.CO_Invoice_Items__r.size() == 0 ) {
        			coHeaderIdToRecMap.put(coHeaderId, new CO_Header__c(Id= coHeaderId, Order_status__c = 'Closed'));
        		}
        	}
        }
        List<CO_Header__c> coHeaderList = [SELECT (Select Status__c from Deals__r) FROM CO_Header__c WHERE Id =: coHeaderId ];
        if(coHeaderList.size() > 0 ) {
        	for(CO_Header__c coHeaderRec : coHeaderList) {
        		if(coHeaderRec.Deals__r.size() > 0 && coHeaderRec.Deals__r[0].Status__c != 'Invoiced' && coHeaderIdToRecMap.size() > 0 && coHeaderIdToRecMap.containsKey(coHeaderRec.Id)) {
        			coHeaderIdToRecMap.get(coHeaderRec.Id).Order_status__c = 'Open';
        		}
        	}
        }
        if(coHeaderIdToRecMap.size() > 0) {
        	update coHeaderIdToRecMap.Values();
        	return coHeaderIdToRecMap.get(coHeaderId).Order_status__c;
        }
        return coInvoiceHeaderList.size() > 0 ? coInvoiceHeaderList[0].CO_Header__r.Order_status__c : 'Open';
     }
}
