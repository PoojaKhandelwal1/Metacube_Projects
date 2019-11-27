public with sharing class COInvoiceJournalEntryService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500; 
    public static Map<Id, List<F_I_Product__c>> dealIdToFIProductsMap = new Map<Id, List<F_I_Product__c>>();
    
    public static void syncCustomerInvoices(Set<Id> customerInvoiceIds){
        AccSync_COInvoiceJournalEntry_Batch.runCustomerInvoicesForSync(customerInvoiceIds, 10);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingCustomerInvoice customerInvoiceRecord, List<CO_Invoice_Header__c> customerInvoiceListToUpdate){
        List<Log__c> errorLogToInsert = new List<Log__c>();
        if(QBUtil.isQBEnabled()){
            errorLogToInsert = syncToQuickBooks(customerInvoiceRecord, customerInvoiceListToUpdate);
        }
        return errorLogToInsert;
    }
    
    public static List<Log__c> syncToQuickBooks(AccountingCustomerInvoice customerInvoiceRecord, List<CO_Invoice_Header__c> customerInvoiceListToUpdate){
        CO_Invoice_Header__c coInvoiceHeader = new CO_Invoice_Header__c();
        coInvoiceHeader.Id = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderId;
        Boolean isAnyLineItemAvailableTOPostJEToQB = true;
        List<Log__c> errorLogList = new List<Log__c>();
        try {
            if(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.JournalEntrySyncToken != null){
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('journalentry', customerInvoiceRecord.AccountingCOInvoiceHeaderRec.JournalEntryAccountingId);
                if(getResponse.getStatusCode() == 200) { 
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry COInvoiceJournalEntryGetResponce = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(getResponse.getBody(), QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    customerInvoiceRecord.AccountingCOInvoiceHeaderRec.JournalEntrySyncToken = COInvoiceJournalEntryGetResponce.JournalEntry.SyncToken;
                } else {
                    errorLogList.add(new LogService().createErrorLog('COInvoiceJournalEntryService', 'syncToQuickBooks() - Get sync token Request From QB', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              customerInvoiceRecord + LogService.METHOD_PARAM_SEPERATOR + customerInvoiceListToUpdate, LogService.QUICKBOOKS,false));
                }
            }
            QBJournalEntryServiceHelper.QuickBooksJournalEntry QCIJE = new QBJournalEntryServiceHelper.QuickBooksJournalEntry(customerInvoiceRecord);
            if(QCIJE.line != null && QCIJE.line.size() == 0) {
                isAnyLineItemAvailableTOPostJEToQB = false;
                coInvoiceHeader.AccountingResponseForJournalEntry__c = QBUtil.CO_INVOICE_NO_JE_MSG;
                coInvoiceHeader.availForQBJournalEntrySync__c = false;
            } else {
                String COInvoiceJournalEntryJSONBody = system.JSON.serialize(QCIJE);
                system.debug('*************'); 
                system.debug(COInvoiceJournalEntryJSONBody);
                String response = COInvoiceJournalEntryJSONBody;
                HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('journalentry', COInvoiceJournalEntryJSONBody);
                System.debug(res);
                if(res.getStatusCode() == 200) { 
                    String resParams = res.getBody();
                    QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry COInvoiceJournalEntryPostResponse = (QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry)System.JSON.deserialize(resParams, QBJournalEntryServiceHelper.ResponseQuickBooksJournalEntry.class);
                    coInvoiceHeader.JournalEntryAccountingId__c = COInvoiceJournalEntryPostResponse.JournalEntry.Id;
                    coInvoiceHeader.SyncTokenForJournalEntry__c = COInvoiceJournalEntryPostResponse.JournalEntry.SyncToken;
                    response += '\n\n'+resParams; 
                    coInvoiceHeader.availForQBJournalEntrySync__c = false;
                    coInvoiceHeader.accountingLastSyncTimeForJE__c = System.now(); 
                } else {
                    response += '\n\n'+res.getBody();
                    response += '\n\n'+res.getStatus();
                    errorLogList.add(new LogService().createErrorLog('COInvoiceJournalEntryService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                                  customerInvoiceRecord + LogService.METHOD_PARAM_SEPERATOR + customerInvoiceListToUpdate, LogService.QUICKBOOKS, false));
                }
                coInvoiceHeader.AccountingResponseForJournalEntry__c = QBUtil.truncateString(response, 131072); 
            }
        } catch(Exception e) {
            if(isAnyLineItemAvailableTOPostJEToQB) {
                coInvoiceHeader.availForQBJournalEntrySync__c = true;
                coInvoiceHeader.AccountingResponseForJournalEntry__c = e.getMessage();
                errorLogList.add(new LogService().createErrorLog('COInvoiceJournalEntryService', 'syncToQuickBooks() - exception', e.getMessage(),LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                                  customerInvoiceRecord + LogService.METHOD_PARAM_SEPERATOR + customerInvoiceListToUpdate, LogService.QUICKBOOKS, false));
            } else {
                coInvoiceHeader.AccountingResponseForJournalEntry__c = QBUtil.CO_INVOICE_NO_JE_MSG;
                coInvoiceHeader.availForQBJournalEntrySync__c = false;
            }
        }
        if(customerInvoiceListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
            AccSync_COInvoiceJournalEntry_Batch.updateCustomerInvoices(customerInvoiceListToUpdate);
            customerInvoiceListToUpdate = new List<CO_Invoice_Header__c>();
        }
        customerInvoiceListToUpdate.add(coInvoiceHeader); 
        
        return errorLogList;
    }
    
    public static List<QuickBooksCustomerInvoiceItemsHelper> getAllAccountingCOInvoiceItemsRecs(AccountingCustomerInvoice customerInvoiceRecord) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Decimal taxInclusiveAmount;
        String itemCategoryAccountingId, itemCategoryName;
        String COGS_GL, Income_GL, Inventory_GL, DealUnit_Inventory_GL;
        Decimal price = 0, cost = 0, total = 0;
        Boolean IsDealMerchOrService = false, IsInternalService = false;
        String entityType;
        Boolean isDealInvoiced;
        List<QuickBooksCustomerInvoiceItemsHelper> itemsList = new List<QuickBooksCustomerInvoiceItemsHelper>();
        
        if(customerInvoiceRecord.AccountingCOInvoiceItemsRecs.size() > 0) {
            List<Id> coliIds = new List<Id>();
            List<Id> sohIds = new List<Id>();
            List<Id> cokhIds = new List<Id>();
            List<Id> dealIds = new List<Id>();
            
            for(AccountingCustomerInvoice.AccountingCOInvoiceItem coInvoiceItem : customerInvoiceRecord.AccountingCOInvoiceItemsRecs) {
                if(coInvoiceItem.COLineItemId != null) {
                    coliIds.add(coInvoiceItem.COLineItemId);
                }
                if(coInvoiceItem.SOHeaderId != null) {
                    sohIds.add(coInvoiceItem.SOHeaderId);
                }
                if(coInvoiceItem.COKitHeaderId != null) {
                    cokhIds.add(coInvoiceItem.COKitHeaderId);
                }
                if(coInvoiceItem.DealId != null) {
                    dealIds.add(coInvoiceItem.DealId);
                }
            }
            system.debug('coliIds '+coliIds + '\n\n' + 'sohIds '+sohIds + '\n\n' + 'cokhIds '+cokhIds);
                
            Id coId = customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COHeaderId;
            List<CO_Header__c> coHeadersList = getCustomerOrderHeaders(new List<Id>{coId}, coliIds);
            List<Service_Order_Header__c> soHeadersList = getServiceOrderHeaders(new List<Id>{coId}, sohIds);
            
            Map<Id, Service_Order_Line_Item__c> soliIdToSOLIRecordMap = new Map<Id, Service_Order_Line_Item__c>();
            if(customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Third-Party' && sohIds.size() > 0) {
            	soliIdToSOLIRecordMap = getSoliIdToSOLIRecordMap(sohIds);
            }
            
            List<CO_Kit_Header__c> coKitHeadersList = getKitHeaders(new List<Id>{coId}, cokhIds);
            List<Deal_Item__c> dealItemList = getDealHeaders(new List<Id>{coId}, dealIds);// Added by kajal 12/08/2016 deal invoice
            List<F_I_Product__c> dealFIProductList = new List<F_I_Product__c>();
            for(Id dealId: dealIds) {
                if(dealIdToFIProductsMap != null && dealIdToFIProductsMap.containsKey(dealId)) {
                    for(F_I_Product__c FIProduct: dealIdToFIProductsMap.get(dealId)) {
                        dealFIProductList.add(FIProduct);
                    }
                }
            }
            
            // This is due to there may be multiple type of Price and Cost options.
            Map<String, List<Unit_Price_Cost__c>> dealItemIdToPriceCostListMap = AccountingUtil.setDealItemIdToPriceCostListMap(dealItemList);
            List<Category__c> defaultCategory = [Select Name, AccountingId__c, COGS_GL__c, Income_GL__c, Inventory_GL__c from Category__c
                                                   where Type__c = 'Unit' AND Active__c = true AND Default__c = true]; 
            for(CO_Header__c coHeaderRec: coHeadersList) {
                for(CO_Line_Item__c coLIRec: coHeaderRec.CO_Line_Items__r) {
                    IsDealMerchOrService = coLIRec.Deal__c != null ? true : false;
                    isDealInvoiced = IsDealMerchOrService ? (coLIRec.Deal__r.Invoice_Number__r != null && coLIRec.Deal__r.Invoice_Number__r.CreatedDate < customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CreatedDate):false;
                    IsInternalService = false;
                    entityType = '';
                    cost = 0;
                    if(isTaxIncludingPricing && !IsDealMerchOrService) { // for deal merch and service we do not have taxes so Price include tax does not matter and only this price is populated so added this
                        price = (coLIRec.Price_When_Tax_Included__c != null ? coLIRec.Price_When_Tax_Included__c : 0);
                    } else {
                        price = (coLIRec.Price__c != null ? coLIRec.Price__c : 0);
                    }
                        
                    if(coLIRec.Part__c != null) {
                        itemCategoryAccountingId = coLIRec.Part__r.Category__r.AccountingId__c;
                        itemCategoryName = coLIRec.Part__r.Category__r.Name;
                        COGS_GL = coLIRec.Part__r.Category__r.COGS_GL__c;
                        Income_GL = coLIRec.Part__r.Category__r.Income_GL__c;
                        Inventory_GL = coLIRec.Part__r.Category__r.Inventory_GL__c;
                        if(coLIRec.Adjusted_Cost_Coli__c == null || coLIRec.Adjusted_Cost_Coli__c == 0) { // coLIRec.Qty__c < 0 || removed for #3186
                            cost = (coLIRec.Part__r.Average_Cost__c != null) ? coLIRec.Part__r.Average_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0 ;
                        } else {
                            cost = (coLIRec.Qty__c != null && coLIRec.Qty__c != 0) ? (coLIRec.Adjusted_Cost_Coli__c/coLIRec.Qty__c).setScale(3) : 0;  // Changed setScale(2) => setcale(3) rounding issue #3187
                        }
                    } else if(coLIRec.Fee__c != null) {
                        entityType = 'Fee';
                        itemCategoryAccountingId = coLIRec.Fee__r.Category__r.AccountingId__c;
                        itemCategoryName = coLIRec.Fee__r.Category__r.Name;
                        COGS_GL = coLIRec.Fee__r.Category__r.COGS_GL__c;
                        Income_GL = coLIRec.Fee__r.Category__r.Income_GL__c;
                        Inventory_GL = coLIRec.Fee__r.Category__r.Inventory_GL__c;
                        Decimal perItemCost = coLIRec.Fee__r.Cost_Rate__c != null ? coLIRec.Fee__r.Cost_Rate__c : 0;
                        if(coLIRec.Fee__r.Cost_Method__c == 'Fixed Cost') {
                            cost = perItemCost;
                        } else if(coLIRec.Fee__r.Cost_Method__c == 'Percent Retail') {
                            cost = (price * perItemCost) /100;
                        }
                    }
                        
                    total = (coLIRec.Qty__c != null ? coLIRec.Qty__c : 0) * price;
                    String ItemCode = (coLIRec.Item_Code__c != null) ? coLIRec.Item_Code__c : '';
                    String ItemDescription = (coLIRec.Item_Description__c != null) ? coLIRec.Item_Description__c : '';
                        
                    String Item = '';
                    String DealUnitDesc = '';
                    if(IsDealMerchOrService) {
                        String Related_Option_And_FeesId = coLIRec.Related_Option_And_Fees__c;
                        
                        List<Option_Fee__c> optionAndFeeList = new List<Option_Fee__c>();
                        if(!String.isBlank(Related_Option_And_FeesId) && Related_Option_And_FeesId != null) {
                            List<String> Related_Option_And_FeesIdList = Related_Option_And_FeesId.split(';');
                            optionAndFeeList = [select Id, Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c, 
                                                        Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c from Option_Fee__c
                                                where Id IN :Related_Option_And_FeesIdList];
                        }
                            
                        if(isDealInvoiced) {
                        	DealUnit_Inventory_GL = AccountingUtil.getChartofAccount('Deal Option Clearing');
                        } else {
                        	if(optionAndFeeList.size() > 0) {
	                            Item += optionAndFeeList[0].Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c + ';';
	                            DealUnit_Inventory_GL = (optionAndFeeList[0].Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) ? 
	                                                        optionAndFeeList[0].Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;
	                        } else {
	                            List<Deal_Item__c> dealItemsList = [select Customer_Owned_Unit__r.Category__r.Inventory_GL__c, 
	                                                                    Customer_Owned_Unit__r.Stock_Id__c from Deal_Item__c
	                                                                    where Deal__c =:coLIRec.Deal__c];
	                            if(dealItemsList.size() > 0) {
	                                Item += dealItemsList[0].Customer_Owned_Unit__r.Stock_Id__c + ';';
	                                DealUnit_Inventory_GL = (dealItemsList[0].Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) ? 
	                                                        dealItemsList[0].Customer_Owned_Unit__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;
	                            } else {
	                                DealUnit_Inventory_GL = defaultCategory[0].Inventory_GL__c;
	                            }
	                        }
                        }
                            
                        Item += 'Deal Merch;';
                        Item += customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber + ';';
                        DealUnitDesc = item;
                    }
                    Item += ItemCode + ' - ' + ItemDescription;
                    QuickBooksCustomerInvoiceItemsHelper invoiceItem = new QuickBooksCustomerInvoiceItemsHelper(Item, DealUnitDesc, cost, price, coLIRec.Qty__c, total, itemCategoryAccountingId, itemCategoryName, COGS_GL, Income_GL, Inventory_GL, IsDealMerchOrService, DealUnit_Inventory_GL, IsInternalService, false, entityType);
                    if(coLIRec.Part__c != null) {
                        itemsList.add(invoiceItem); // Added 07/01/2017
                    }
                }
            } 
                
            for(Service_Order_Header__c soHeaderRec: soHeadersList) {
                if(!(soHeaderRec.Transaction_Type__r.Type__c == 'Third-Party' && customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CheckoutType == 'Customer')) { // It will prevent deductible JE
                    IsDealMerchOrService = soHeaderRec.Deal__c != null ? true : false;
                    isDealInvoiced = IsDealMerchOrService ? (soHeaderRec.Deal__r.Invoice_Number__r != null && soHeaderRec.Deal__r.Invoice_Number__r.CreatedDate < customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CreatedDate):false;
                    IsInternalService = (soHeaderRec.Transaction_Type__r.Type__c != null && (soHeaderRec.Transaction_Type__r.Type__c == 'Internal' || 
                        soHeaderRec.Transaction_Type__r.Type__c == 'Stock Unit')) ? true : false;
                    for(Service_Order_Line_Item__c soLIRec: soHeaderRec.Service_Order_Line_Items__r) {
                        entityType = '';
                        cost = 0;
                        if(isTaxIncludingPricing && !IsDealMerchOrService) { // for deal merch and service we do not have taxes so Price include tax does not matter and only this price is populated so added this
                            price = (soLIRec.Price_When_Tax_Included__c != null ? soLIRec.Price_When_Tax_Included__c : 0);
                        } else {
                            price = (soLIRec.Kit_Price__c != null ? (soLIRec.Kit_Price__c).setScale(2, RoundingMode.HALF_UP) : 0);
                        }
                        total = (soLIRec.Qty_Needed__c != null ? soLIRec.Qty_Needed__c : 0) * price;
                        if(soLIRec.Part__c != null) {
                            itemCategoryAccountingId = !String.isBlank(soHeaderRec.Transaction_Type__r.Part_Category__r.AccountingId__c) ? soHeaderRec.Transaction_Type__r.Part_Category__r.AccountingId__c : soLIRec.Part__r.Category__r.AccountingId__c;
                            itemCategoryName = !String.isBlank(soHeaderRec.Transaction_Type__r.Part_Category__r.Name) ? soHeaderRec.Transaction_Type__r.Part_Category__r.Name : soLIRec.Part__r.Category__r.Name;
                            COGS_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Part_Category__r.COGS_GL__c) ? soHeaderRec.Transaction_Type__r.Part_Category__r.COGS_GL__c : soLIRec.Part__r.Category__r.COGS_GL__c;
                            Income_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Part_Category__r.Income_GL__c) ? soHeaderRec.Transaction_Type__r.Part_Category__r.Income_GL__c : soLIRec.Part__r.Category__r.Income_GL__c;
                            Inventory_GL = soLIRec.Part__r.Category__r.Inventory_GL__c;
                            if(soLIRec.CO_Line_Item__r.Adjusted_Cost_Coli__c == null || soLIRec.CO_Line_Item__r.Adjusted_Cost_Coli__c == 0) { // soLIRec.Qty_Needed__c < 0 || removed for #3186
                                cost = (soLIRec.CO_Line_Item__r.Part__r.Average_Cost__c != null) ? soLIRec.CO_Line_Item__r.Part__r.Average_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0 ;
                            } else {
                                cost = (soLIRec.Qty_Needed__c != null && soLIRec.Qty_Needed__c != 0) ? (soLIRec.CO_Line_Item__r.Adjusted_Cost_Coli__c/soLIRec.Qty_Needed__c).setScale(3) : 0;  // Changed setScale(2) => setcale(3) rounding issue #3187
                            }
                        } else if(soLIRec.Fee__c != null) {
                            entityType = 'Fee';
                            itemCategoryAccountingId = soLIRec.Fee__r.Category__r.AccountingId__c;
                            itemCategoryName = soLIRec.Fee__r.Category__r.Name;
                            COGS_GL = soLIRec.Fee__r.Category__r.COGS_GL__c;
                            Income_GL = soLIRec.Fee__r.Category__r.Income_GL__c;
                            Inventory_GL = soLIRec.Fee__r.Category__r.Inventory_GL__c;
                            Decimal perItemCost = soLIRec.Fee__r.Cost_Rate__c != null ? soLIRec.Fee__r.Cost_Rate__c : 0;
                            if(soLIRec.Fee__r.Cost_Method__c == 'Fixed Cost') {
                                cost = perItemCost;
                            } else if(soLIRec.Fee__r.Cost_Method__c == 'Percent Retail') {
                                cost = (price * perItemCost)/100;
                            }
                        } else if(soLIRec.Labour_Code__c != null) {
                            itemCategoryAccountingId = !String.isBlank(soHeaderRec.Transaction_Type__r.Labour_Category__r.AccountingId__c) ? soHeaderRec.Transaction_Type__r.Labour_Category__r.AccountingId__c : soLIRec.Labour_Code__r.Category__r.AccountingId__c;
                            itemCategoryName = !String.isBlank(soHeaderRec.Transaction_Type__r.Labour_Category__r.Name) ? soHeaderRec.Transaction_Type__r.Labour_Category__r.Name : soLIRec.Labour_Code__r.Category__r.Name;
                            COGS_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Labour_Category__r.COGS_GL__c) ? soHeaderRec.Transaction_Type__r.Labour_Category__r.COGS_GL__c : soLIRec.Labour_Code__r.Category__r.COGS_GL__c;
                            Income_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Labour_Category__r.Income_GL__c) ? soHeaderRec.Transaction_Type__r.Labour_Category__r.Income_GL__c : soLIRec.Labour_Code__r.Category__r.Income_GL__c;
                            Inventory_GL = soLIRec.Labour_Code__r.Category__r.Inventory_GL__c;
                            Decimal perItemCost = soLIRec.Labour_Code__r.Cost_Rate__c != null ? soLIRec.Labour_Code__r.Cost_Rate__c : 0;
                            if(soLIRec.Labour_Code__r.Cost_Method__c == 'Fixed Cost') {
                                cost = perItemCost;
                            } else if(soLIRec.Labour_Code__r.Cost_Method__c == 'Percent Retail') {
                                cost = (price * perItemCost)/100;
                            }
                        } else if(soLIRec.Sublet__c != null) {
                            itemCategoryAccountingId = soLIRec.Sublet__r.Category__r.AccountingId__c;
                            itemCategoryName = soLIRec.Sublet__r.Category__r.Name;
                            COGS_GL = soLIRec.Sublet__r.Category__r.COGS_GL__c;
                            Income_GL = soLIRec.Sublet__r.Category__r.Income_GL__c;
                            Inventory_GL = soLIRec.Sublet__r.Category__r.Inventory_GL__c;
                            Decimal perItemCost = 0;
                            if(soLIRec.Cost__c != null) {
                                perItemCost = soLIRec.Cost__c;
                                cost = perItemCost;
                            } else {
                                perItemCost = soLIRec.Sublet__r.Cost__c != null ? soLIRec.Sublet__r.Cost__c : 0;
                                if(soLIRec.Sublet__r.Cost_Method__c == 'Fixed Cost') {
                                    cost = perItemCost;
                                } else if(soLIRec.Sublet__r.Cost_Method__c == 'Percent Retail') {
                                    cost = (price * perItemCost)/100;
                                }
                            }
                        }
                        String ItemCode = (soLIRec.Item_Code__c != null) ? soLIRec.Item_Code__c : '';
                        String ItemDescription = (soLIRec.Item_Description__c != null) ? soLIRec.Item_Description__c : '';
                        String Item = '';
                        String DealUnitDesc = '';
                        if(IsDealMerchOrService) {
                            Item += soLIRec.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c + ';Deal Service;';
                            Item += customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber + ';';
                            if(isDealInvoiced) {
	                        	DealUnit_Inventory_GL = AccountingUtil.getChartofAccount('Deal Option Clearing');
	                        } else {
	                        	DealUnit_Inventory_GL = soLIRec.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? soLIRec.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;
	                        }
                            DealUnitDesc = item;
                        }
                        if(IsInternalService) {
                            if(soHeaderRec.Customer_Owned_Unit__r.Stock_Id__c != null) {
                                Item += soHeaderRec.Customer_Owned_Unit__r.Stock_Id__c + ';';
                            } else if(soHeaderRec.Customer_Owned_Unit__r.Unit_Id__c != null) {
                                Item += soHeaderRec.Customer_Owned_Unit__r.Unit_Id__c + ';';
                            } else {
                                Item += '';
                            }
                            Item += 'Internal Service;';
                            Item += customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber + ';';
                            DealUnitDesc = Item;
                            if(soHeaderRec.SO_Type__c != null && soHeaderRec.SO_Type__c == 'Internal Service') {
                                DealUnit_Inventory_GL = soHeaderRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? soHeaderRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;
                            } else if(soHeaderRec.Transaction_Type__r.Type__c != null && (soHeaderRec.Transaction_Type__r.Type__c == 'Internal' || 
                                    soHeaderRec.Transaction_Type__r.Type__c == 'Stock Unit')) {
                                DealUnit_Inventory_GL = soHeaderRec.Category__r.Income_GL__c != null ? soHeaderRec.Category__r.Income_GL__c : defaultCategory[0].Income_GL__c;
                            }
                        }
                        Item += ItemCode + ' - ' + ItemDescription;
                        QuickBooksCustomerInvoiceItemsHelper invoiceItem = new QuickBooksCustomerInvoiceItemsHelper(Item, DealUnitDesc, cost, price, soLIRec.Qty_Needed__c, total, itemCategoryAccountingId, itemCategoryName, COGS_GL, Income_GL, Inventory_GL, IsDealMerchOrService, DealUnit_Inventory_GL, IsInternalService, false, entityType);
                        if(soLIRec.Part__c != null || soLIRec.Labour_Code__c != null || (IsInternalService && soLIRec.Fee__c != null) || soLIRec.Sublet__c != null || (IsDealMerchOrService &&  soLIRec.Fee__c != null)) {
                            itemsList.add(invoiceItem);
                        }
                        
                        /** Third Party  Claim varinace Line Entry For Bill to Intenral 
                          * Credit -> SOLI income GL
                          * Debit ->  Category selected in the variance disposition. 
                          * Amount -> Total Variance amount
                          * Desc -> <Third Party vendor>;<CO-Number>;'Claim Variance';<SOLI Desc>
                          */
                        if(soHeaderRec.Transaction_Type__r.Type__c == 'Third-Party' && soliIdToSOLIRecordMap.containsKey(soLIRec.Id) 
                        	&& soliIdToSOLIRecordMap.get(soLIRec.Id).Claim_Line_Items__r.size() > 0) {
                        	for(Claim_Line_Item__c billToInternalClaimLI : soliIdToSOLIRecordMap.get(soLIRec.Id).Claim_Line_Items__r) {
	                        	Item = soliIdToSOLIRecordMap.get(soLIRec.Id).Service_Order_Header__r.Provider__r.Name + ';' 
	                        			+ soliIdToSOLIRecordMap.get(soLIRec.Id).Service_Order_Header__r.CO_Header__r.Name + ';Claim Variance;' + Item;
	                        			
	                        	cost = billToInternalClaimLI.Total_Variance_Amount__c != null ? billToInternalClaimLI.Total_Variance_Amount__c : 0;
	                        	price = billToInternalClaimLI.Total_Variance_Amount__c != null ? billToInternalClaimLI.Total_Variance_Amount__c : 0;
		                        
	                        	//Credit
	                        	if(soLIRec.Part__c != null) {
		                            COGS_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Part_Category__r.COGS_GL__c) ? soHeaderRec.Transaction_Type__r.Part_Category__r.COGS_GL__c : soLIRec.Part__r.Category__r.COGS_GL__c;
		                            Income_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Part_Category__r.Income_GL__c) ? soHeaderRec.Transaction_Type__r.Part_Category__r.Income_GL__c : soLIRec.Part__r.Category__r.Income_GL__c;
		                            Inventory_GL = soLIRec.Part__r.Category__r.Inventory_GL__c;
		                        } else if(soLIRec.Fee__c != null) {
		                            COGS_GL = soLIRec.Fee__r.Category__r.COGS_GL__c;
		                            Income_GL = soLIRec.Fee__r.Category__r.Income_GL__c;
		                            Inventory_GL = soLIRec.Fee__r.Category__r.Inventory_GL__c;
		                        } else if(soLIRec.Labour_Code__c != null) {
		                            COGS_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Labour_Category__r.COGS_GL__c) ? soHeaderRec.Transaction_Type__r.Labour_Category__r.COGS_GL__c : soLIRec.Labour_Code__r.Category__r.COGS_GL__c;
		                            Income_GL = !String.isBlank(soHeaderRec.Transaction_Type__r.Labour_Category__r.Income_GL__c) ? soHeaderRec.Transaction_Type__r.Labour_Category__r.Income_GL__c : soLIRec.Labour_Code__r.Category__r.Income_GL__c;
		                            Inventory_GL = soLIRec.Labour_Code__r.Category__r.Inventory_GL__c;
		                        } else if(soLIRec.Sublet__c != null) {
		                            COGS_GL = soLIRec.Sublet__r.Category__r.COGS_GL__c;
		                            Income_GL = soLIRec.Sublet__r.Category__r.Income_GL__c;
		                            Inventory_GL = soLIRec.Sublet__r.Category__r.Inventory_GL__c;
		                        }
		                        itemsList.add(new QuickBooksCustomerInvoiceItemsHelper(Item, cost, price, 1, COGS_GL, Income_GL, Inventory_GL, false, false, false, true, 'Credit'));
            
	                        	//Debit
	                        	COGS_GL = billToInternalClaimLI.Category__r.COGS_GL__c;
	                            Income_GL = billToInternalClaimLI.Category__r.Income_GL__c;
	                            Inventory_GL = billToInternalClaimLI.Category__r.Inventory_GL__c;
		                        itemsList.add(new QuickBooksCustomerInvoiceItemsHelper(Item, cost, price, 1, COGS_GL, Income_GL, Inventory_GL, false, false, false, true, 'Debit'));
	                        }
                        }
                    }
                    if(IsInternalService) {
                        List<AccountingSalesTax> salesTaxList = getSalesTaxList(soHeaderRec.Id);
                        Boolean isInternalServiceTax;
                        String UnitDesc = '';
                        if(salesTaxList.size() > 0) {
                            isInternalServiceTax = true;
                            if(soHeaderRec.Customer_Owned_Unit__r.Stock_Id__c != null) {
                                UnitDesc += soHeaderRec.Customer_Owned_Unit__r.Stock_Id__c + ';';
                            } else if(soHeaderRec.Customer_Owned_Unit__r.Unit_Id__c != null) {
                                UnitDesc += soHeaderRec.Customer_Owned_Unit__r.Unit_Id__c + ';';
                            } else {
                                UnitDesc += '';
                            }
                            UnitDesc += 'Internal Service;';
                            UnitDesc += customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber + ';';
                            if(soHeaderRec.SO_Type__c != null && soHeaderRec.SO_Type__c == 'Internal Service') {
                                DealUnit_Inventory_GL = soHeaderRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? soHeaderRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;
                            } else if(soHeaderRec.Transaction_Type__r.Type__c != null && (soHeaderRec.Transaction_Type__r.Type__c == 'Internal' || 
                                    soHeaderRec.Transaction_Type__r.Type__c == 'Stock Unit')) {
                                DealUnit_Inventory_GL = soHeaderRec.Category__r.Income_GL__c != null ? soHeaderRec.Category__r.Income_GL__c : defaultCategory[0].Income_GL__c;
                            }
                        }
                        for(AccountingSalesTax salesTax: salesTaxList) {
                            entityType = '';
                            QuickBooksCustomerInvoiceItemsHelper invoiceItemForTax = new QuickBooksCustomerInvoiceItemsHelper(salesTax.SalesTaxName, UnitDesc, 0, salesTax.SalesTaxAmount, 0, salesTax.SalesTaxAmount, '', '', '', salesTax.CategoyRef, '', false, DealUnit_Inventory_GL, IsInternalService, isInternalServiceTax, entityType);
                            itemsList.add(invoiceItemForTax);
                        }
                    }
                }
                
            }
                
            for(CO_Kit_Header__c coKitHeaderRec: coKitHeadersList) {
                for(CO_Line_Item__c coKitHeaderLIRec: coKitHeaderRec.CO_Line_Items__r) {
                    IsDealMerchOrService = coKitHeaderLIRec.Deal__c != null ? true : false;
                    isDealInvoiced = IsDealMerchOrService ? (coKitHeaderLIRec.Deal__r.Invoice_Number__r != null && coKitHeaderLIRec.Deal__r.Invoice_Number__r.CreatedDate < customerInvoiceRecord.AccountingCOInvoiceHeaderRec.CreatedDate):false;
                    IsInternalService = false;
                    entityType = '';
                    cost = 0;
                    if(isTaxIncludingPricing && !IsDealMerchOrService) { // for deal merch and service we do not have taxes so Price include tax does not matter and only this price is populated so added this
                        price = (coKitHeaderLIRec.Price_When_Tax_Included__c != null ? coKitHeaderLIRec.Price_When_Tax_Included__c : 0);
                    } else {
                        price = (coKitHeaderLIRec.Price__c != null ? coKitHeaderLIRec.Price__c : 0);
                    }
                        
                    if(coKitHeaderLIRec.Part__c != null) {
                        itemCategoryAccountingId = coKitHeaderLIRec.Part__r.Category__r.AccountingId__c;
                        itemCategoryName = coKitHeaderLIRec.Part__r.Category__r.Name;
                        COGS_GL = coKitHeaderLIRec.Part__r.Category__r.COGS_GL__c;
                        Income_GL = coKitHeaderLIRec.Part__r.Category__r.Income_GL__c;
                        Inventory_GL = coKitHeaderLIRec.Part__r.Category__r.Inventory_GL__c;
                        //cost = (coKitHeaderLIRec.Adjusted_Cost_Coli__c != null) ? (coKitHeaderLIRec.Adjusted_Cost_Coli__c/coKitHeaderLIRec.Qty__c).setScale(2, RoundingMode.HALF_UP) : 0 ;
                        if(coKitHeaderLIRec.Adjusted_Cost_Coli__c == null || coKitHeaderLIRec.Adjusted_Cost_Coli__c == 0) { // coKitHeaderLIRec.Qty__c < 0 || removed for #3186
                            cost = (coKitHeaderLIRec.Part__r.Average_Cost__c != null) ? coKitHeaderLIRec.Part__r.Average_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0 ;
                        } else {
                            cost = (coKitHeaderLIRec.Qty__c != null && coKitHeaderLIRec.Qty__c != 0) ? (coKitHeaderLIRec.Adjusted_Cost_Coli__c/coKitHeaderLIRec.Qty__c).setScale(3) : 0; // Changed setScale(2) => setcale(3) rounding issue #3187
                        }
                    } else if(coKitHeaderLIRec.Fee__c != null) {
                        entityType = 'Fee';
                        itemCategoryAccountingId = coKitHeaderLIRec.Fee__r.Category__r.AccountingId__c;
                        itemCategoryName = coKitHeaderLIRec.Fee__r.Category__r.Name;
                        COGS_GL = coKitHeaderLIRec.Fee__r.Category__r.COGS_GL__c;
                        Income_GL = coKitHeaderLIRec.Fee__r.Category__r.Income_GL__c;
                        Inventory_GL = coKitHeaderLIRec.Fee__r.Category__r.Inventory_GL__c;
                        Decimal perItemCost = coKitHeaderLIRec.Fee__r.Cost_Rate__c != null ? coKitHeaderLIRec.Fee__r.Cost_Rate__c : 0;
                        if(coKitHeaderLIRec.Fee__r.Cost_Method__c == 'Fixed Cost') {
                            cost = perItemCost;
                        } else if(coKitHeaderLIRec.Fee__r.Cost_Method__c == 'Percent Retail') {
                            cost = (price * perItemCost) /100;
                        }
                    }
                        
                    total = (coKitHeaderLIRec.Qty__c != null ? coKitHeaderLIRec.Qty__c : 0) * price;
                    String ItemCode = (coKitHeaderLIRec.Item_Code__c != null) ? coKitHeaderLIRec.Item_Code__c : '';
                    String ItemDescription = (coKitHeaderLIRec.Item_Description__c != null) ? coKitHeaderLIRec.Item_Description__c : '';
                        
                    String Item = '';
                    String DealUnitDesc = '';
                    if(IsDealMerchOrService) {
                        String Related_Option_And_FeesId = coKitHeaderLIRec.Related_Option_And_Fees__c;
                        
                        List<Option_Fee__c> optionAndFeeList = new List<Option_Fee__c>();
                        if(!String.isBlank(Related_Option_And_FeesId) && Related_Option_And_FeesId != null) {
                            List<String> Related_Option_And_FeesIdList = Related_Option_And_FeesId.split(';');
                            optionAndFeeList = [SELECT Id, Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c, 
                                                        Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c from Option_Fee__c
                                                where Id IN :Related_Option_And_FeesIdList];
                        }
                            
                        Item += (optionAndFeeList.size() > 0) ? optionAndFeeList[0].Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c + ';' : '';
                        Item += 'Deal Merch;';
                        Item += customerInvoiceRecord.AccountingCOInvoiceHeaderRec.COInvoiceHeaderNumber + ';';
                        DealUnitDesc = Item;
                        if(isDealInvoiced) {
                        	DealUnit_Inventory_GL = AccountingUtil.getChartofAccount('Deal Option Clearing');
                        } else {
                        	if(optionAndFeeList.size() > 0 && optionAndFeeList[0].Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
	                            DealUnit_Inventory_GL = optionAndFeeList[0].Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
	                        } else {
	                            DealUnit_Inventory_GL = defaultCategory[0].Inventory_GL__c;
	                        }
                        }
                    }
                    Item += ItemCode + ' - ' + ItemDescription;
                    QuickBooksCustomerInvoiceItemsHelper invoiceItem = new QuickBooksCustomerInvoiceItemsHelper(Item, DealUnitDesc, cost, price, coKitHeaderLIRec.Qty__c, total, itemCategoryAccountingId, itemCategoryName, COGS_GL, Income_GL, Inventory_GL, IsDealMerchOrService, DealUnit_Inventory_GL, IsInternalService, false, entityType);
                    
                    if(coKitHeaderLIRec.Part__c != null || (IsDealMerchOrService && coKitHeaderLIRec.Fee__c != null)) {
                        itemsList.add(invoiceItem);
                    }
                }
            }        
                
                
            for(Deal_Item__c dealItem : dealItemList) {
                IsDealMerchOrService = false;
                IsInternalService = false;
                for(Option_Fee__c optionAndFee : dealItem.Options_Fees__r) {
                    entityType = '';
                    cost = 0;
                    if(isTaxIncludingPricing) {
                        price = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
                    } else {
                        price = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
                    }
                        
                    COGS_GL = optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.COGS_GL__c != null ? optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.COGS_GL__c : defaultCategory[0].COGS_GL__c;
                    Income_GL = optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Income_GL__c != null ? optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Income_GL__c : defaultCategory[0].Income_GL__c;
                    if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
                        Inventory_GL = optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? optionAndFee.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;    
                    } else {
                        Inventory_GL = AccountingUtil.getChartofAccount('Deal Option Clearing');
                    }
                        
                    if(optionAndFee.Part__c != null) {
                        itemCategoryAccountingId = optionAndFee.Part__r.Category__r.AccountingId__c;
                        itemCategoryName = optionAndFee.Part__r.Category__r.Name;
                        if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
                            cost = (optionAndFee.Per_Item_Cost__c != null ? optionAndFee.Per_Item_Cost__c : 0);
                        } else {
                            if(isTaxIncludingPricing) {
		                        cost = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
		                    } else {
		                        cost = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
		                    }
                        }
                    } else if(optionAndFee.Fee__c != null) {
                        entityType = 'Fee';
                        itemCategoryAccountingId = optionAndFee.Fee__r.Category__r.AccountingId__c;
                        itemCategoryName = optionAndFee.Fee__r.Category__r.Name;
                        COGS_GL = optionAndFee.Fee__r.Category__r.COGS_GL__c;
                        Income_GL = optionAndFee.Fee__r.Category__r.Income_GL__c;
                        Inventory_GL = optionAndFee.Fee__r.Category__r.Inventory_GL__c;
                        Decimal perItemCost = optionAndFee.Fee__r.Cost_Rate__c != null ? optionAndFee.Fee__r.Cost_Rate__c : 0;
                        if(optionAndFee.Fee__r.Cost_Method__c == 'Fixed Cost') {
                            cost = perItemCost;
                        } else if(optionAndFee.Fee__r.Cost_Method__c == 'Percent Retail') {
                            cost = (price * perItemCost)/100;
                        }
                    } else if(optionAndFee.Labour_Code__c != null) {
                        itemCategoryAccountingId = optionAndFee.Labour_Code__r.Category__r.AccountingId__c;
                        itemCategoryName = optionAndFee.Labour_Code__r.Category__r.Name;
                        if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
                            cost = (optionAndFee.Per_Item_Cost__c != null ? optionAndFee.Per_Item_Cost__c : 0);
                        } else {
                            if(isTaxIncludingPricing) {
                                cost = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
                            } else {
                                cost = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
                            }
                        }
                    } else if(optionAndFee.Product__c != null) {
                        if(optionAndFee.Product__r.Type__c == Constants.SUBLET) {
                            if(optionAndFee.Deal__r.Is_Deal_Fulfilled__c) {
	                            cost = (optionAndFee.Per_Item_Cost__c != null ? optionAndFee.Per_Item_Cost__c : 0);
	                        } else {
	                            if(isTaxIncludingPricing) {
	                                cost = (optionAndFee.Price_When_Tax_Included__c != null ? optionAndFee.Price_When_Tax_Included__c : 0);
	                            } else {
	                                cost = (optionAndFee.Price__c != null ? optionAndFee.Price__c : 0);
	                            }
	                        }
                        } else {
                            COGS_GL = optionAndFee.Product__r.Category__r.COGS_GL__c;
                            Income_GL = optionAndFee.Product__r.Category__r.Income_GL__c;
                            Inventory_GL = optionAndFee.Product__r.Category__r.Inventory_GL__c;
                            Decimal perItemCost = optionAndFee.Product__r.Cost__c != null ? optionAndFee.Product__r.Cost__c : 0;
                            if(optionAndFee.Product__r.Cost_Method__c == 'Fixed Cost') {
                                cost = perItemCost;
                            } else if(optionAndFee.Product__r.Cost_Method__c == 'Percent Retail') {
                                cost = (price * perItemCost)/100;
                            }
                        }
                        itemCategoryAccountingId = optionAndFee.Product__r.Category__r.AccountingId__c;
                        itemCategoryName = optionAndFee.Product__r.Category__r.Name;
                    }
                        
                    DealUnit_Inventory_GL = '';
                    String ItemCode = (optionAndFee.Item_Code__c != null) ? optionAndFee.Item_Code__c : '';
                    String ItemDescription = (optionAndFee.Item_Description__c != null) ? optionAndFee.Item_Description__c : '';
                    String Item = ItemCode + ' - ' + ItemDescription;
                    
                    total = (optionAndFee.Qty__c != null ? optionAndFee.Qty__c : 0) * price;
                    QuickBooksCustomerInvoiceItemsHelper invoiceItem = new QuickBooksCustomerInvoiceItemsHelper(Item, '', cost, price, optionAndFee.Qty__c, total, itemCategoryAccountingId, itemCategoryName, COGS_GL, Income_GL, Inventory_GL, IsDealMerchOrService, DealUnit_Inventory_GL, IsInternalService, false, entityType);
                    if(optionAndFee.Part__c != null || optionAndFee.Labour_Code__c != null || optionAndFee.Product__c != null) {
                        itemsList.add(invoiceItem);
                    }
                }
                    
                itemCategoryAccountingId = dealItem.Customer_Owned_Unit__r.Category__r.AccountingId__c != null ? dealItem.Customer_Owned_Unit__r.Category__r.AccountingId__c : defaultCategory[0].AccountingId__c;
                itemCategoryName = dealItem.Customer_Owned_Unit__r.Category__r.Name != null ? dealItem.Customer_Owned_Unit__r.Category__r.Name : defaultCategory[0].Name;
                COGS_GL = dealItem.Customer_Owned_Unit__r.Category__r.COGS_GL__c != null ? dealItem.Customer_Owned_Unit__r.Category__r.COGS_GL__c : defaultCategory[0].COGS_GL__c;
                Income_GL = dealItem.Customer_Owned_Unit__r.Category__r.Income_GL__c != null ? dealItem.Customer_Owned_Unit__r.Category__r.Income_GL__c : defaultCategory[0].Income_GL__c;
                Inventory_GL = dealItem.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null ? dealItem.Customer_Owned_Unit__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;
                String Item = getDealUnitName(dealItem);
                for(Unit_Price_Cost__c unitPriceCostRec : dealItemIdToPriceCostListMap.get(dealItem.Id)) {
                    entityType = '';
                    Decimal qty = (unitPriceCostRec.Qty__c != null && unitPriceCostRec.Qty__c != 0) ? unitPriceCostRec.Qty__c : 1;
                    unitPriceCostRec.Total_Cost__c = unitPriceCostRec.Total_Cost__c != null ? unitPriceCostRec.Total_Cost__c : 0;
                    unitPriceCostRec.Total_Price__c = unitPriceCostRec.Total_Price__c != null ? unitPriceCostRec.Total_Price__c : 0;
                    cost = (unitPriceCostRec.Cost__c != null) ? unitPriceCostRec.Cost__c : (unitPriceCostRec.Total_Cost__c/qty);
                    price = (unitPriceCostRec.Price__c != null) ? unitPriceCostRec.Price__c : (unitPriceCostRec.Total_Price__c/qty);
                    total = qty * cost;
                    String itemDesc = Item + (unitPriceCostRec.Type__c == 'Base' ? 'Base cost;' : unitPriceCostRec.Type__c + ' option;');
                    QuickBooksCustomerInvoiceItemsHelper invoiceItem = new QuickBooksCustomerInvoiceItemsHelper(itemDesc, '', cost, price, qty, total, itemCategoryAccountingId, itemCategoryName, COGS_GL, Income_GL, Inventory_GL, IsDealMerchOrService, DealUnit_Inventory_GL, IsInternalService, false, entityType);
                    itemsList.add(invoiceItem);
                }
            }
            
            for(F_I_Product__c FIProduct : dealFIProductList) {
                entityType = '';
                itemCategoryAccountingId = FIProduct.Vendor_Product__r.Category__r.AccountingId__c != null ? FIProduct.Vendor_Product__r.Category__r.AccountingId__c : defaultCategory[0].AccountingId__c;
                itemCategoryName = FIProduct.Vendor_Product__r.Category__r.Name != null ? FIProduct.Vendor_Product__r.Category__r.Name : defaultCategory[0].Name;
                COGS_GL = FIProduct.Vendor_Product__r.Category__r.COGS_GL__c != null ? FIProduct.Vendor_Product__r.Category__r.COGS_GL__c : defaultCategory[0].COGS_GL__c;
                Income_GL = FIProduct.Vendor_Product__r.Category__r.Income_GL__c != null ? FIProduct.Vendor_Product__r.Category__r.Income_GL__c : defaultCategory[0].Income_GL__c;
                Inventory_GL = FIProduct.Vendor_Product__r.Category__r.Inventory_GL__c != null ? FIProduct.Vendor_Product__r.Category__r.Inventory_GL__c : defaultCategory[0].Inventory_GL__c;
                String itemDesc = FIProduct.Item_Description__c;
                price = (FIProduct.Price__c != null ? FIProduct.Price__c : 0);
                cost = 0;
                Decimal perItemCost = FIProduct.Vendor_Product__r.Cost__c != null ? FIProduct.Vendor_Product__r.Cost__c : 0;
                if(FIProduct.Vendor_Product__r.Cost_Method__c == 'Fixed Cost') {
                    cost = perItemCost;
                } else if(FIProduct.Vendor_Product__r.Cost_Method__c == 'Percent Retail') {
                    cost = (price * perItemCost)/100;
                }
                total = (FIProduct.Total__c != null ? FIProduct.Total__c : 0);
                QuickBooksCustomerInvoiceItemsHelper invoiceItem = new QuickBooksCustomerInvoiceItemsHelper(itemDesc, '', cost, price, 1, total, itemCategoryAccountingId, itemCategoryName, COGS_GL, Income_GL, Inventory_GL, IsDealMerchOrService, DealUnit_Inventory_GL, IsInternalService, false, entityType);
                itemsList.add(invoiceItem);
            }
        }
        return itemsList;
    }
    
    private static List<AccountingSalesTax> getSalesTaxList(String soHeaderId){
        Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>(); 
        Map<String, Sales_Tax_Item__c> salesTaxNameToSalesTax = new Map<String, Sales_Tax_Item__c>();  
        List<Sales_Tax_Item__c> salesTaxList = [SELECT AccountingId__c, Name__c, Category__r.Income_GL__c
                                                FROM Sales_Tax_Item__c where Active__c = true];
        
        for(Sales_Tax_Item__c STI : salesTaxList){
            salesTaxNameToSalesTax.put(STI.Name__c, STI);
        }
        List<Individual_Tax__c> individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Sales_Tax_Item_Name__c, 
                                                        Taxable_Amount__c, Tax_Amount__c,
                                                        Applicable_Tax__c, List_Tax_items_on_forms__c
                                                        from Individual_Tax__c where Service_Order_Line_Item__r.Service_Order_Header__c = :soHeaderId];
        
        salesTaxNameToTaxValue = TaxCalculation.getTaxAmount(individualItemsList);  
        List<AccountingSalesTax> taxDetails = new List<AccountingSalesTax>();
        for(String salesTaxName : salesTaxNameToTaxValue.keyset()){
            taxDetails.add(new AccountingSalesTax(salesTaxName, salesTaxNameToTaxValue.get(salesTaxName), salesTaxNameToSalesTax.get(salesTaxName).Category__r.Income_GL__c));
        }
        
        return taxDetails;
    }
       
    private static String getDealUnitName(Deal_Item__c dealItem){
        String Item = '';
        if(dealItem.Customer_Owned_Unit__c != null) {
            if(dealItem.Customer_Owned_Unit__r.Stock_Id__c != null){
                Item += dealItem.Customer_Owned_Unit__r.Stock_Id__c + ';';
            }
            if(dealItem.Customer_Owned_Unit__r.VIN_Number__c != null){
                Item += dealItem.Customer_Owned_Unit__r.VIN_Number__c + ';';
            }           
        }
        return Item;
    }
    
    private static List<CO_Header__c> getCustomerOrderHeaders(List<Id> coIdsList, List<Id> coliIds) {
        List<CO_Header__c> coHeadersList = new List<CO_Header__c>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(coIdsList != null && coIdsList.size() > 0) {
            String query = 'SELECT ';
            for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('COHeader')){
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';
            }
            
            query += '(SELECT ';
            for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('COLineItem')){
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';
            }
            query = query.substring(0, query.length()-2);
            query += ' FROM CO_Line_Items__r WHERE Is_In_Service_Order__c = false AND Id IN: coliIds) FROM CO_Header__c WHERE Id IN: coIdsList';
            system.debug('query ' + query);
            coHeadersList = Database.query(query);
        }
        return coHeadersList;
    }
    
    private static List<Service_Order_Header__c> getServiceOrderHeaders(List<Id> coIdsList, List<Id> sohIds) {
        List<Service_Order_Header__c> soHeadersList = new List<Service_Order_Header__c>();
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(coIdsList != null && coIdsList.size() > 0) {
            soHeadersList = [SELECT Name__c, Total__c, Correction__c, Cause__c, Concern__c, Customer_Owned_Unit__c, Customer_Owned_Unit__r.VIN_Number__c,
                                    Customer_Owned_Unit__r.Unit_Make__r.Name, Customer_Owned_Unit__r.Unit_Model__r.Name__c, Customer_Owned_Unit__r.Year__c,
                                    Odometer_on_Arrival__c, Odometer_on_Departure__c, CO_Header__c, CO_Header__r.CO_Type__c, Notes_For_Customer__c,
                                    Deal__c, Transaction_Type__r.Type__c, Transaction_Type__r.Part_Category__r.COGS_GL__c,
                                    Transaction_Type__r.Part_Category__r.Income_GL__c, Transaction_Type__r.Labour_Category__r.COGS_GL__c,
                                    Transaction_Type__r.Labour_Category__r.Income_GL__c, Transaction_Type__r.Part_Category__r.AccountingId__c, 
                                    Transaction_Type__r.Part_Category__r.Name, Transaction_Type__r.Labour_Category__r.AccountingId__c, 
                                    Transaction_Type__r.Labour_Category__r.Name, Category__r.Income_GL__c, Customer_Owned_Unit__r.Category__r.Inventory_GL__c,
                                    Customer_Owned_Unit__r.Unit_Id__c, Customer_Owned_Unit__r.Stock_Id__c, SO_Type__c,
                                    Deal__r.Invoice_Number__r.CreatedDate,
                                    (SELECT Item_Code__c, Item_Description__c, Item_Desc__c, Kit_Price__c, Labour_Code__c, Part__c, Qty_Needed__c, 
                                            Total__c, Fee__c, Tax_Percent__c, Tax_Amount__c, Price_When_Tax_Included__c,
                                            Part__r.Category__c, Part__r.Category__r.AccountingId__c, Part__r.Category__r.Name, Part__r.Category__r.COGS_GL__c,
                                            Part__r.Category__r.Income_GL__c, Part__r.Category__r.Inventory_GL__c,
                                            Fee__r.Category__c, Fee__r.Category__r.AccountingId__c, Fee__r.Category__r.Name, Fee__r.Category__r.COGS_GL__c,
                                            Fee__r.Category__r.Income_GL__c, Fee__r.Category__r.Inventory_GL__c, Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c,
                                            Labour_Code__r.Category__c, Labour_Code__r.Category__r.AccountingId__c, Labour_Code__r.Category__r.Name,
                                            Labour_Code__r.Category__r.COGS_GL__c, Labour_Code__r.Category__r.Income_GL__c, Labour_Code__r.Category__r.Inventory_GL__c,
                                            Labour_Code__r.Cost_Method__c, Labour_Code__r.Cost_Rate__c,
                                            Sublet__c, Sublet__r.Category__c, Sublet__r.Category__r.AccountingId__c, Sublet__r.Category__r.Name,
                                            Sublet__r.Category__r.COGS_GL__c, Sublet__r.Category__r.Income_GL__c, Sublet__r.Category__r.Inventory_GL__c,
                                            Sublet__r.Cost_Method__c, Sublet__r.Cost__c, Cost__c,
                                            Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c, Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c,
                                            CO_Line_Item__r.Adjusted_Cost_Coli__c, CO_Line_Item__r.Avg_Cost__c, CO_Line_Item__r.Part__r.Average_Cost__c
                                            FROM Service_Order_Line_Items__r)
                                    FROM Service_Order_Header__c WHERE Id IN: sohIds ];
        }
        return soHeadersList;
    }
    
    private static Map<Id, Service_Order_Line_Item__c> getSoliIdToSOLIRecordMap(List<Id> sohIds) { 
    	Map<ID, Service_Order_Line_Item__c> soliIdToSOLIRecordMap = new Map<ID, Service_Order_Line_Item__c>([SELECT Id, Service_Order_Header__r.Provider__r.Name, 
    																	Service_Order_Header__r.CO_Header__r.Name, (SELECT Total_Variance_Amount__c, Category__r.COGS_GL__c, 
    																	Category__r.Income_GL__c, Category__r.Inventory_GL__c FROM Claim_Line_Items__r 
    																	WHERE SO_Payment_Role__r.RecordType.DeveloperName = 'Internal') FROM Service_Order_Line_Item__c WHERE Service_Order_Header__c IN: sohIds]);
    	return soliIdToSOLIRecordMap;
    }
      
    private static List<CO_Kit_Header__c> getKitHeaders(List<Id> coIdsList, List<Id> cokhIds) {
        List<CO_Kit_Header__c> coKitHeadersList = new List<CO_Kit_Header__c>();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Kit_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        if(coIdsList != null && cokhIds.size() > 0) {
            coKitHeadersList = [SELECT CO_Header__c, Kit_Header__c, Price__c, Tax_Amount__c, Actual_Kit_Price__c, CreatedDate, Kit_Header__r.Kit_Unique_Name__c,
                                    Can_Split__c, Service_Kit__c, Fixed_Price_Flag__c, CO_Fixed_KitHeader__c,
                                    (SELECT Name, Item_ID__c, CO_Header__c, CO_Header__r.Name, CO_Header__r.Customer__c, CO_Header__r.Customer__r.Name,
                                            CO_Header__r.Owner__c, CO_Header__r.Owner__r.Name, CO_Header__r.Order_status__c, Qty__c, Qty_Committed__c,
                                            Item_Code__c, Item_Description__c, Price__c, Part__r.Name, Part__r.Part_Id__c, Part__r.Part_Number__c,
                                            Part__r.Description__c, Part__r.AvailableParts__c, Part__r.Vendor__c, Part__r.Average_Cost__c,
                                            Special_Order__c, Tax__c, Retail__c, Closed_CO_Invoice_link__c, VO_Number__c, VO_Status__c,
                                            Expected_Delivery_Date__c, CreatedDate, Fee__c, Fee__r.Fee_Unique_Name__c, Fixed_Price__c, CO_Fixed_KitLineItem__c,
                                            Price_When_Tax_Included__c, Actual_Kit_Price__c, Kit_Price_With_Price_Level__c, CO_Kit_Header__r.Id,
                                            Sub_Total_With_Tax__c, Sub_Total_Without_Tax__c, Tax_Amount__c, Oversold_Qty__c, Is_Temporary__c,
                                            Part__r.Category__c, Part__r.Category__r.AccountingId__c, Part__r.Category__r.Name, Part__r.Category__r.COGS_GL__c,
                                            Part__r.Category__r.Income_GL__c, Part__r.Category__r.Inventory_GL__c, Fee__r.Category__c,
                                            Fee__r.Category__r.AccountingId__c, Fee__r.Category__r.Name, Fee__r.Category__r.COGS_GL__c,
                                            Fee__r.Category__r.Income_GL__c, Fee__r.Category__r.Inventory_GL__c, Fee__r.Cost_Method__c, Fee__r.Cost_Rate__c,
                                            Deal__c, Related_Option_And_Fees__c, Adjusted_Cost_Coli__c, Avg_Cost__c,
                                            Deal__r.Invoice_Number__r.CreatedDate
                                            FROM CO_Line_Items__r  WHERE Is_In_Service_Order__c = false )
                                    FROM CO_Kit_Header__c WHERE Id IN: cokhIds ];
        }
        return coKitHeadersList;
    }
    
    private static List<Deal_Item__c> getDealHeaders(List<Id> coIdsList, List<Id> dealIds) {
        List<Deal_Item__c> dealItemList = new List<Deal_Item__c>();
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(dealIds != null && dealIds.size() > 0) {
            String query = 'SELECT Id, (SELECT Id FROM Deal_Items__r), ';
            // Child Query For Deal F&I Products
            query += '(SELECT ';
            for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('DealFIProduct')){
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';
            }
            query = query.substring(0, query.length()-2);
            query += ' FROM F_I_Products__r) FROM Deal__c WHERE Id IN: dealIds';
    
            List<Deal__c> dealList = Database.query(query);
            
            if(dealList.size() > 0) {
                Set<String> dealItemId = new Set<String>();
                for(Deal__c dealRec : dealList) {
                    for(Deal_Item__c dealItemRec : dealRec.Deal_Items__r) {
                        dealItemId.add(dealItemRec.Id);
                    }
                    
                    if(dealIdToFIProductsMap != null) {
                        dealIdToFIProductsMap.put(dealRec.Id, dealRec.F_I_Products__r);
                    }
                }
                
                query = 'SELECT ';
                for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('DealItems')){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                query += '(SELECT ';
                for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('OptionAndFees')){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                query = query.substring(0, query.length()-2);
                query += ' FROM Options_Fees__r), ';
                
                query += '(SELECT ';
                for(String fieldsName : AccountingCustomerInvoice.objectToFieldMap.get('DealUnitPriceCost')){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                query = query.substring(0, query.length()-2);
                query += ' FROM Deal_Unit_Prices_Costs__r) FROM Deal_Item__c WHERE Id IN: dealItemId';
                dealItemList = Database.query(query);
            }
        }
        return dealItemList;
    }
     
    public class QuickBooksCustomerInvoiceItemsHelper {
        public String Description;
        public String DealUnitDescription;
        public Decimal UnitCost;
        public Decimal UnitPrice;
        public Decimal Qty;
        public Decimal TaxInclusiveAmt;
        public String ItemCategoryAccountingId;
        public String ItemCategoryName;
        public String COGS_GL;
        public String Income_GL;
        public String Inventory_GL;
        public Boolean IsDealMerchOrService;
        public String DealUnit_Inventory_GL;
        public Boolean IsInternalService;
        public Boolean IsInternalServiceTax;
        public String EntityType;
        public Boolean IsBillToInternalClaimLI;
        public String PostingType;
        
        public QuickBooksCustomerInvoiceItemsHelper(String Description, String DealUnitDescription, Decimal UnitCost, Decimal UnitPrice, Decimal Qty, Decimal TaxInclusiveAmt, String ItemCategoryAccountingId, String ItemCategoryName, String COGS_GL, String Income_GL, String Inventory_GL, Boolean IsDealMerchOrService, String DealUnit_Inventory_GL, Boolean IsInternalService, Boolean IsInternalServiceTax, String entityType) {
            this.Description = Description;
            this.DealUnitDescription = DealUnitDescription;
            this.UnitCost = UnitCost;
            this.UnitPrice = UnitPrice;
            this.Qty = Qty;
            this.TaxInclusiveAmt = TaxInclusiveAmt;
            this.ItemCategoryAccountingId = ItemCategoryAccountingId;
            this.ItemCategoryName = ItemCategoryName;
            this.COGS_GL = COGS_GL;
            this.Income_GL = Income_GL;
            this.Inventory_GL = Inventory_GL;
            this.IsDealMerchOrService = IsDealMerchOrService;
            this.DealUnit_Inventory_GL = DealUnit_Inventory_GL;
            this.IsInternalService = IsInternalService;
            this.IsInternalServiceTax = IsInternalServiceTax;
            this.EntityType = entityType != null ? entityType : '';
            this.IsBillToInternalClaimLI = false;
        }        
        
        public QuickBooksCustomerInvoiceItemsHelper(String description, Decimal unitCost, Decimal unitPrice, Decimal qty, String COGS_GL, String Income_GL, String Inventory_GL, Boolean IsDealMerchOrService, Boolean IsInternalService, Boolean IsInternalServiceTax, Boolean isBillToInternalVariance, String postingType) {
            this.Description = description;
            this.UnitCost = unitCost;
            this.UnitPrice = unitPrice;
            this.Qty = qty;
            this.COGS_GL = COGS_GL;
            this.Income_GL = Income_GL;
            this.Inventory_GL = Inventory_GL;
            this.IsDealMerchOrService = IsDealMerchOrService;
            this.IsInternalService = IsInternalService;
            this.IsInternalServiceTax = IsInternalServiceTax;
            this.IsBillToInternalClaimLI = isBillToInternalVariance;
            this.PostingType = postingType != null ? postingType : '';
        }        
     }
     
     public class AccountingSalesTax {
        public String SalesTaxName {get; set;}        
        public Decimal SalesTaxAmount {get; set;}       
        public String CategoyRef {get; set;}
        
        // Constructor
        public AccountingSalesTax(String SalesTaxName, Decimal SalesTaxAmount, String CategoyRef) { 
            this.SalesTaxName = SalesTaxName;
            this.SalesTaxAmount = SalesTaxAmount;
            this.CategoyRef = CategoyRef;
        }
    }
}