/**
 * Author: Nidhi Sharma
 * Since: Sep. 05, 2018
 * Name: MYOBSalesInvoice
 * Description: Class is used for migration of Sales Invoice (Customer Order Invoice) records to  Accounting Software
**/
global with sharing class MYOBSalesInvoice implements Database.batchable<sObject>,Database.Stateful {
    
    global MYOBSalesInvoice() {}
    global MYOBSalesInvoice(List<Id> recordIds, boolean exportAllData) {}
    global MYOBSalesInvoice(List<Id> recordIds, boolean exportAllData, String timePeriod, DateTime fromDate, DateTime toDate) {}
    
    private static final Integer BATCH_SIZE = 200; 
    private String objName = 'CO_Invoice_Item__c';
    
    // For Sales Invoice exporatble data
    private String miscSalesExportTextData = '';
    private integer miscSalesIndexVal = 0;
    private Integer recordCountMiscSales = 0;
    
    private String invoicePaymentExportTextData = '';
    private Integer invoicePaymentIndexVal = 1;
    
    private String inventoryGLExportTextData = '';
    private Integer inventoryGLIndexVal = 0;
    private Integer recordCountInventoryGL = 0;
    
    private string query;
    private DateTime Last_Synched_Date;
    private String timePeriodForFilter;
    private DateTime From_Date;
    private DateTime To_Date;
    private Accounting_Data_Migration__c dataMigration;
    
    private Map<String, Map<String, String>> entityNameToDefaultAccTypeToAccNumberMap;
    private String defaultUnitTaxName = '';
    
    private Map<String, Sales_Tax_Item__c> salesTaxNameToSalesTaxItemRecMap;
    private static String cashCustomerId = AccountingUtil.getChartofAccount('Cash Sale Customer');
    private static String internalServiceCustomerId = AccountingUtil.getChartofAccount('Internal Service Customer');
    
    /**
     * Name: MYOBSalesInvoice
     * Desc: Constructor to start the batch for data export
    **/
    global MYOBSalesInvoice(List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
        if(AccessControl.ifObjectFieldIsAccessible('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        this.objName = (Constants.exportDisplayObjectNameToObjectNameMap.containsKey(objNameToExport)) ? Constants.exportDisplayObjectNameToObjectNameMap.get(objNameToExport) : objName;
        this.timePeriodForFilter = timePeriod;
        this.From_Date = fromDate;
        this.To_Date = toDate;
        
        dataMigration = DataExportUtil.getAccountingDataMigrationRec(objNameToExport);
        Last_Synched_Date = dataMigration.Last_Synched_Date__c;
        dataMigration.Last_Synched_Date__c = Datetime.now();
        upsert dataMigration;
        
        initEntityNameToDefaultAccTypeToAccNumberMap();
        Set<String> tradeInTaxCategoryIdSet = new Set<String>();
        if(GeneralConfiguration.isAccruTradeTaxUntilUnitSold()) {
            tradeInTaxCategoryIdSet.add(GeneralConfiguration.getTradeTaxExpenseCategory());
            tradeInTaxCategoryIdSet.add(GeneralConfiguration.getTradeTaxLiabilityCategory());
            tradeInTaxCategoryIdSet.add(GeneralConfiguration.getTradeTaxPendingSaleCategory());
            
        }
        Map<String, Category__c> categoryIdToRecMap = new Map<String, Category__c>([Select Id, Type__c, Default__c, Active__c, Income_GL__c, Inventory_GL__c, COGS_GL__c from Category__c where (Default__c = true AND Active__c = true) OR Id IN: tradeInTaxCategoryIdSet]);
        for(Category__c categoryRec : categoryIdToRecMap.values()) {
            if(categoryRec.Default__c && categoryRec.Active__c) {
                if(categoryRec.Type__c != null && entityNameToDefaultAccTypeToAccNumberMap.containsKey(categoryRec.Type__c)) {
                    Map<String, String> glAccNameToAccNumberMap = entityNameToDefaultAccTypeToAccNumberMap.get(categoryRec.Type__c);
                    if(String.isNotBlank(categoryRec.Income_GL__c)) {
                        glAccNameToAccNumberMap.put('Income GL', categoryRec.Income_GL__c);
                    }
                    if(String.isNotBlank(categoryRec.Inventory_GL__c)) {
                        glAccNameToAccNumberMap.put('Inventory GL', categoryRec.Inventory_GL__c);
                    }
                    if(String.isNotBlank(categoryRec.COGS_GL__c)) {
                        glAccNameToAccNumberMap.put('COGS GL', categoryRec.COGS_GL__c);
                    }
                    entityNameToDefaultAccTypeToAccNumberMap.put(categoryRec.Type__c, glAccNameToAccNumberMap);
                }
            }
        }
        Map<String, String> glAccNameToAccNumberMap = new Map<String, String>();
        if(GeneralConfiguration.getTradeTaxExpenseCategory() != null && categoryIdToRecMap.containsKey(GeneralConfiguration.getTradeTaxExpenseCategory())) {
            glAccNameToAccNumberMap.put('Trade tax expense', categoryIdToRecMap.get(GeneralConfiguration.getTradeTaxExpenseCategory()).Income_GL__c);
        }
        if(GeneralConfiguration.getTradeTaxLiabilityCategory() != null && categoryIdToRecMap.containsKey(GeneralConfiguration.getTradeTaxLiabilityCategory())) {
            glAccNameToAccNumberMap.put('Trade tax liability', categoryIdToRecMap.get(GeneralConfiguration.getTradeTaxLiabilityCategory()).Income_GL__c);
        }
        if(GeneralConfiguration.getTradeTaxPendingSaleCategory() != null && categoryIdToRecMap.containsKey(GeneralConfiguration.getTradeTaxPendingSaleCategory())) {
            glAccNameToAccNumberMap.put('Trade tax pending sale', categoryIdToRecMap.get(GeneralConfiguration.getTradeTaxPendingSaleCategory()).Income_GL__c);
        }
        entityNameToDefaultAccTypeToAccNumberMap.put('Trade In', glAccNameToAccNumberMap);
        tradeInTaxCategoryIdSet = null;

        String defaultUnitSalesTaxId = Configurations__c.getInstance().Default_Tax_on_Unit__c;
        if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sales_Tax__c> salesTaxList = [Select Id, Name__c from Sales_Tax__c where Id = :defaultUnitSalesTaxId];
        if(salesTaxList.size() > 0) {
            defaultUnitTaxName = salesTaxList[0].Name__c;
        }
        
        List<Sales_Tax_Item__c> salesTaxItemList = [select Name__c, Rate__c, Forms_Label__c, Category__c, Category__r.Income_GL__c from Sales_Tax_Item__c where Active__c = true];
        salesTaxNameToSalesTaxItemRecMap = new Map<String, Sales_Tax_Item__c>();
        for(Sales_Tax_Item__c salesTaxItemRec : salesTaxItemList) {
            salesTaxNameToSalesTaxItemRecMap.put(salesTaxItemRec.Name__c, salesTaxItemRec);
        }
        
        dataMigration = DataExportUtil.getDateRange(this.timePeriodForFilter, Last_Synched_Date, From_Date, toDate, new List<Accounting_Data_Migration__c>{dataMigration});
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        query = DataExportUtil.createQuery(recordIds, 'Id', this.timePeriodForFilter, Last_Synched_Date, From_Date, toDate, 'CO_Invoice_Item__c');
    }
    
    private Map<Id, List<Individual_Tax__c>> childLineItemIdToIndividualTaxRecListMap;
    private void initEntityNameToDefaultAccTypeToAccNumberMap() {
        entityNameToDefaultAccTypeToAccNumberMap = new Map<String, Map<String, String>>{
                                                                            'Part' => new Map<String, String>{
                                                                                    'Income GL' => '',
                                                                                    'Inventory GL'=> '',
                                                                                    'COGS GL'   =>''},
                                                                            'Fee' => new Map<String, String>{
                                                                                    'Income GL' =>'',
                                                                                    'Inventory GL'  =>'',
                                                                                    'COGS GL'   =>''},
                                                                            'Labour' => new Map<String, String>{
                                                                                    'Income GL' =>'',
                                                                                    'Inventory GL' =>'',
                                                                                    'COGS GL' => ''},
                                                                            'Unit' => new Map<String, String>{
                                                                                    'Income GL' => '',
                                                                                    'Inventory GL'=> '',
                                                                                    'COGS GL'   => ''},
                                                                            'Sublet' => new Map<String, String>{
                                                                                    'Income GL' => '',
                                                                                    'Inventory GL'=> '',
                                                                                    'COGS GL'   => ''},
                                                                            'Tax' => new Map<String, String>{
                                                                                    'Income GL' =>'',
                                                                                    'Inventory GL'  =>'',
                                                                                    'COGS GL'   =>''},
                                                                            'Stamp Duty' => new Map<String, String>{
                                                                                    'Income GL' =>(AccountingUtil.getChartofAccount('Stamp Duty Accrual')),
                                                                                    'Inventory GL'  =>'',
                                                                                    'COGS GL'   =>''},
                                                                            'Deductible' => new Map<String, String>{
                                                                                    'Income GL' =>'',
                                                                                    'Inventory GL'  =>'',
                                                                                    'COGS GL'   =>''},
                                                                            'Lien Payout' => new Map<String, String>{
                                                                                    'Income GL' =>'',
                                                                                    'Inventory GL'  =>'',
                                                                                    'COGS GL'   =>''},
                                                                            'Trade In' => new Map<String, String>{
                                                                                    'Trade tax pending sale'    =>'',
                                                                                    'Trade tax liability'   =>'',
                                                                                    'Trade tax expense' =>''}
                                                                        };
    }
    /**
     * Name: executeDataMigrationBatch
     * Desc: Method to initiate the coInvoiceItems export
     * @param: 
     * @return: Id
    **/
    public static Id executeDataMigrationBatch(Integer batchSize, List<Id> recordIds, String timePeriod, DateTime fromDate, DateTime toDate, String objNameToExport) {
        Id batchId = Database.executeBatch(new MYOBSalesInvoice(recordIds, timePeriod, fromDate, toDate, objNameToExport), batchSize);
        return batchId;
    }
    
    /**
     * Name: start
     * Desc: Batch start method - Create query and execute query locator
     * @param: 
     * @return: Database.QueryLocator
    **/
    global Iterable<Sobject> start(Database.BatchableContext BC) {
        String stockedInTradeUnit = DataExportUtil.createQuery(null, 'Deal__c', null, null, null, null, 'StockInTradedUnit');
        return getRecords(new List<String>{query, stockedInTradeUnit});
    }
    
    private List<Sobject> getRecords(List<String> queryList) {
        List<SObject> sObjectList = new List<SObject>();
        for(String query : queryList) {
            List<sObject> resultList = Database.query(query);
            if(resultList.size() > 0) {
                sObjectList.addAll(resultList);
            }
        }
        return sObjectList;
    }
    
    /**
     * Name: execute
     * Desc: Batch execute method to process the exported data records
     * @param:  1. Database.BatchableContext BC
     *          2. List<sObject> scope
     * @return:
    **/
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0) {
            List<CO_Invoice_Item__c> coInvoiceItemsList = new List<CO_Invoice_Item__c>();
            
            List<Id> soHeaderIdList = new List<Id>();
            List<Id> cokitHeaderIdList = new List<Id>();
            List<Id> dealIdList = new List<Id>();
            Map<Id, Set<Id>> coInvoiceHeaderIdToRelatedLineItemIdSet = new Map<Id, Set<Id>>();
            Map<String, Deal_Item__c> stockedTradeInIdToRecMap = new Map<String, Deal_Item__c>();
            for(Sobject sobj : scope) {
                Id recordId = String.valueOf(sobj.get('Id'));
                if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'CO_Invoice_Item__c') {
                    CO_Invoice_Item__c coInvoiceItem = (CO_Invoice_Item__c)sobj;
                    coInvoiceItemsList.add(coInvoiceItem);
                    if(coInvoiceItem.CO_Line_Item__c == null && coInvoiceItem.Service_Order_Header__c != null) {
                        soHeaderIdList.add(coInvoiceItem.Service_Order_Header__c);
                        if(coInvoiceItem.Service_Order_Header__r.Deal_Item__c != null) {
                            dealIdList.add(coInvoiceItem.Service_Order_Header__r.Deal_Item__r.Deal__c);
                        }
                    } else if(coInvoiceItem.Deal__c != null) {
                        dealIdList.add(coInvoiceItem.Deal__c);
                    } else if(coInvoiceItem.CO_Kit_Header__c != null) {
                        cokitHeaderIdList.add(coInvoiceItem.CO_Kit_Header__c);
                        if(coInvoiceItem.CO_Kit_Header__r.Deal__c != null) {
                            dealIdList.add(coInvoiceItem.CO_Kit_Header__r.Deal__c);
                        }
                    } else if(coInvoiceItem.CO_Line_Item__r.Deal__c != null) {
                        dealIdList.add(coInvoiceItem.CO_Line_Item__r.Deal__c);
                    }
                    
                    // Added by TK.
                    if(!coInvoiceHeaderIdToRelatedLineItemIdSet.containsKey(coInvoiceItem.CO_Invoice_Header__c)) {
                        coInvoiceHeaderIdToRelatedLineItemIdSet.put(coInvoiceItem.CO_Invoice_Header__c, new Set<Id>{});
                    }
                    String relatedlineItemId;
                    if(coInvoiceItem.CO_Line_Item__c != null && coInvoiceItem.CO_Line_Item__r.Deal__c == null) {
                        relatedlineItemId = coInvoiceItem.CO_Line_Item__c;
                    } else if(coInvoiceItem.Service_Order_Header__c != null && coInvoiceItem.Service_Order_Header__r.Deal_Item__c == null && (coInvoiceItem.SO_Payment_Role__c == null || coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName != 'Deductible')) {
                        relatedlineItemId = coInvoiceItem.Service_Order_Header__c;
                    } else if(coInvoiceItem.Deal__c != null) {
                        relatedlineItemId = coInvoiceItem.Deal__c;
                    } else if(coInvoiceItem.CO_Kit_Header__c != null && coInvoiceItem.CO_Kit_Header__r.Deal__c == null) {
                        relatedlineItemId = coInvoiceItem.CO_Kit_Header__c;
                    }
                    if(String.isNotBlank(relatedlineItemId)) {
                        coInvoiceHeaderIdToRelatedLineItemIdSet.get(coInvoiceItem.CO_Invoice_Header__c).add(relatedlineItemId);
                    }
                } else if(recordId.getSObjectType().getDescribe().getName() == Constants.Namespace + 'Deal_Item__c') {
                    Deal_Item__c dealItemRec = (Deal_Item__c)sobj;
                    stockedTradeInIdToRecMap.put(dealItemRec.Id, dealItemRec);
                }
            }
            
            Map<Integer, Map<String,String>> coDepositRecords = new Map<Integer, Map<String, String>>(); 
            
            Map<String, String> miscellaneousSalesSFFieldToAccountingFieldsMap = createMiscellaneousSalesSFFieldToAccountingFieldsMap();
            Map<String, String> invoicePaymentSFFieldToAccountingFieldsMap = createInvoicePaymentSFFieldToAccountingFieldsMap();
            Map<String, String> SFFieldToAccountingFieldsMap = createGLSFFieldToAccountingFieldsMap();
            
            Set<Id> idSet = new Set<Id>();
            for(Id idRec: coInvoiceHeaderIdToRelatedLineItemIdSet.keySet()) {
                idSet.addAll(coInvoiceHeaderIdToRelatedLineItemIdSet.get(idRec));
            }
            
            //CoInvoiceHeaderId To Individual Tax List Creation
            String queryStr = 'SELECT Sales_Tax_Item_Name__c, Tax_Amount__c, Taxable_Amount__c '; 
            if(DataExportUtil.objNameToStandardFieldsMap.containsKey('Individual_Tax__c')) {
                queryStr += ', ' + (DataExportUtil.objNameToStandardFieldsMap.get('Individual_Tax__c'));
            }
            queryStr += ' FROM Individual_Tax__c';
            queryStr += ' Where CO_Line_Item__c IN :idSet OR CO_Line_Item__r.CO_Kit_Header__c IN :idSet OR ' +
                        'Service_Order_Line_Item__r.Service_Order_Header__c IN :idSet OR Option_Fee__r.Deal__c IN :idSet OR '+
                        'Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN :idSet '+
                        'OR Deal_Item__r.Deal__c IN :idSet OR F_I_Product__r.Deal__c IN :idSet ';
                        
            List<Individual_Tax__c> individualTaxList = Database.query(queryStr);
            
            Map<Id, Set<Individual_Tax__c>> lineItemIdToIndividualTaxIdSetMap = new Map<Id, Set<Individual_Tax__c>>();
            childLineItemIdToIndividualTaxRecListMap = new Map<Id, List<Individual_Tax__c>>();
            for(Individual_Tax__c individualTaxRec : individualTaxList) {
                //if(individualTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__r.Is_Stocked_In__c == null || !individualTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__r.Is_Stocked_In__c) {
                    Id lineItemId = individualTaxRec.Service_Order_Line_Item__r.Service_Order_Header__c != null ? 
                                        individualTaxRec.Service_Order_Line_Item__r.Service_Order_Header__c : 
                                        (individualTaxRec.CO_Line_Item__r.CO_Kit_Header__c != null ? individualTaxRec.CO_Line_Item__r.CO_Kit_Header__c :
                                        (individualTaxRec.CO_Line_Item__c != null ? individualTaxRec.CO_Line_Item__c :
                                        (individualTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c != null ? individualTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c :
                                        (individualTaxRec.Option_Fee__r.Deal__c != null ? individualTaxRec.Option_Fee__r.Deal__c : 
                                        (individualTaxRec.Deal_Item__r.Deal__c != null ? individualTaxRec.Deal_Item__r.Deal__c : 
                                        (individualTaxRec.F_I_Product__r.Deal__c != null ? individualTaxRec.F_I_Product__r.Deal__c : null))))));
                    if(lineItemId != null) {
                        if(!lineItemIdToIndividualTaxIdSetMap.containsKey(lineItemId)) {
                            lineItemIdToIndividualTaxIdSetMap.put(lineItemId, new Set<Individual_Tax__c>());
                        }
                        lineItemIdToIndividualTaxIdSetMap.get(lineItemId).add(individualTaxRec);
                    }
                    
                    Id childLineItemId = individualTaxRec.Service_Order_Line_Item__c != null ? 
                                            individualTaxRec.Service_Order_Line_Item__c : 
                                            (individualTaxRec.CO_Line_Item__c != null ? individualTaxRec.CO_Line_Item__c :
                                                (individualTaxRec.Deal_Unit_Price_Cost__c != null ? individualTaxRec.Deal_Unit_Price_Cost__c :
                                                    (individualTaxRec.Option_Fee__c != null ? individualTaxRec.Option_Fee__c : 
                                                        (individualTaxRec.Deal_Item__c != null ? individualTaxRec.Deal_Item__c : 
                                                            (individualTaxRec.F_I_Product__c != null ? individualTaxRec.F_I_Product__c : null)))));
                    if(childLineItemId != null) {
                        if(!childLineItemIdToIndividualTaxRecListMap.containsKey(childLineItemId)) {
                            childLineItemIdToIndividualTaxRecListMap.put(childLineItemId, new List<Individual_Tax__c>());
                        }
                        childLineItemIdToIndividualTaxRecListMap.get(childLineItemId).add(individualTaxRec);
                    }
                //}
            }            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            Map<Id, Map<String, Decimal>> coHeaderIdToIndividualTaxNameToAmountMap = new Map<Id, Map<String, Decimal>>();
            
            Map<String, Decimal> unitIdToTaxAmountMap = new Map<String, Decimal>();
            
            for(Id coInvHeaderId : coInvoiceHeaderIdToRelatedLineItemIdSet.keySet()) {
                Map<String, Decimal> taxNameToTaxAmountMap = new Map<String, Decimal>();
                
                for(Id lineItemId : coInvoiceHeaderIdToRelatedLineItemIdSet.get(coInvHeaderId)) {
                    if(lineItemIdToIndividualTaxIdSetMap.containsKey(lineItemId)) {
                        for(Individual_Tax__c indvTaxRec : lineItemIdToIndividualTaxIdSetMap.get(lineItemId)) {
                            if(!taxNameToTaxAmountMap.containsKey(indvTaxRec.Sales_Tax_Item_Name__c)) {
                                taxNameToTaxAmountMap.put(indvTaxRec.Sales_Tax_Item_Name__c, 0.00);
                            }
                            Decimal taxAmount = 0;
                            if(isTaxIncludingPricing) {
                                taxAmount = ((indvTaxRec.Tax_Amount__c != null) ? indvTaxRec.Tax_Amount__c : 0);
                            } else if(salesTaxNameToSalesTaxItemRecMap.containsKey(indvTaxRec.Sales_Tax_Item_Name__c) && 
                                    salesTaxNameToSalesTaxItemRecMap.get(indvTaxRec.Sales_Tax_Item_Name__c).Rate__c != null) {
                                taxAmount = ((salesTaxNameToSalesTaxItemRecMap.get(indvTaxRec.Sales_Tax_Item_Name__c).Rate__c * indvTaxRec.Taxable_Amount__c)/100) ;
                            }
                            if(String.isNotBlank(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c)) {
                                if(!unitIdToTaxAmountMap.containsKey(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c)) {
                                    unitIdToTaxAmountMap.put(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c, 0);
                                }
                                unitIdToTaxAmountMap.put(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c, unitIdToTaxAmountMap.get(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c) + taxAmount);
                            }
                            taxAmount += taxNameToTaxAmountMap.get(indvTaxRec.Sales_Tax_Item_Name__c);
                            taxNameToTaxAmountMap.put(indvTaxRec.Sales_Tax_Item_Name__c, taxAmount);
                        }
                    }
                }
                coHeaderIdToIndividualTaxNameToAmountMap.put(coInvHeaderId, taxNameToTaxAmountMap);
            }
            
            List<Service_Order_Header__c> soHeaderList = new List<Service_Order_Header__c>();
            List<CO_Line_Item__c> cokliRecList = new List<CO_Line_Item__c>();
            List<Service_Order_Line_Item__c> soliRecList = new List<Service_Order_Line_Item__c>();
            List<Deal_Item__c> dealItemRecList = new List<Deal_Item__c>();
            List<F_I_Product__c> fandIproductRecList = new List<F_I_Product__c>();
            
            if(soHeaderIdList.size() > 0) {
                soHeaderList = Database.query(DataExportUtil.createQuery(soHeaderIdList, 'Id', null, null, null, null, 'Service_Order_Header__c'));
            }
            if(cokitHeaderIdList.size() > 0) {
                cokliRecList = Database.query(DataExportUtil.createQuery(cokitHeaderIdList, 'CO_Kit_Header__c', null, null, null, null, 'CO_KLI'));
            }
            if(soHeaderIdList.size() > 0) {
                soliRecList = Database.query(DataExportUtil.createQuery(soHeaderIdList, 'Service_Order_Header__c', null, null, null, null, 'Service_Order_Line_Item__c'));
            }
            Map<String, List<F_I_Product__c>> dealIdToFAndIProductListMap = new Map<String, List<F_I_Product__c>>();
            if(dealIdList.size() > 0) {
                dealItemRecList = Database.query(DataExportUtil.createQuery(dealIdList, 'Deal__c', null, null, null, null, 'Deal_Item__c'));
                fandIproductRecList = Database.query(DataExportUtil.createQuery(dealIdList, 'Deal__c', null, null, null, null, 'F_I_Product__c'));
                for(F_I_Product__c fAndIProductRec : fandIproductRecList) {
                    if(!dealIdToFAndIProductListMap.containsKey(fAndIProductRec.Deal__c)) {
                        dealIdToFAndIProductListMap.put(fAndIProductRec.Deal__c, new List<F_I_Product__c>());
                    }
                    dealIdToFAndIProductListMap.get(fAndIProductRec.Deal__c).add(fAndIProductRec);
                }
            }
            
            Map<String, List<Deal_Item__c>> dealIdToDealItemListMap = new Map<String, List<Deal_Item__c>>();
            Map<String, List<Deal_Item__c>> dealIdToTradeInListMap = new Map<String, List<Deal_Item__c>>();
            
            Map<Id, Deal_Item__c> dealItemRecMap = new Map<Id, Deal_Item__c>();
            Map<String, Decimal> unitIdToSellingPriceMap = new Map<String, Decimal>();
            for(Deal_Item__c dealItemRec : dealItemRecList) {
                if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
                    if(!dealIdToTradeInListMap.containsKey(dealItemRec.Deal__c)){
                        dealIdToTradeInListMap.put(dealItemRec.Deal__c, new List<Deal_Item__c>());
                    }
                    dealIdToTradeInListMap.get(dealItemRec.Deal__c).add(dealItemRec);
                    
                } else if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT) {
                    if(!dealIdToDealItemListMap.containsKey(dealItemRec.Deal__c)) {
                        dealIdToDealItemListMap.put(dealItemRec.Deal__c, new List<Deal_Item__c>());
                    }
                    dealIdToDealItemListMap.get(dealItemRec.Deal__c).add(dealItemRec);
                    dealItemRecMap.put(dealItemRec.Id, dealItemRec);
                    
                    Decimal unitPreTaxTotal = 0;
                    for(Deal_Unit_Price_Cost__c dupcRec : dealItemRec.Deal_Unit_Prices_Costs__r) {
                        dupcRec.Price__c = (dupcRec.Price__c != null) ? dupcRec.Price__c : 0;
                        dupcRec.Price_When_Tax_Included__c = (dupcRec.Price_When_Tax_Included__c != null) ? dupcRec.Price_When_Tax_Included__c : 0;
                        dupcRec.Qty__c = (dupcRec.Qty__c != null) ? dupcRec.Qty__c : 1;
                        dupcRec.Sales_Tax_Percentage__c = (dupcRec.Sales_Tax_Percentage__c != null) ? dupcRec.Sales_Tax_Percentage__c : 0;
                        
                        if(!isTaxIncludingPricing) {
                            unitPreTaxTotal += (dupcRec.Price__c * dupcRec.Qty__c).setScale(2, RoundingMode.HALF_UP);
                        } else {
                            unitPreTaxTotal += (dupcRec.Price_When_Tax_Included__c != null) ? (dupcRec.Price_When_Tax_Included__c / (1 + dupcRec.Sales_Tax_Percentage__c/100)).setScale(2, RoundingMode.HALF_UP) : 
                                (dupcRec.Price__c * dupcRec.Qty__c).setScale(2, RoundingMode.HALF_UP);
                        }
                    }
                    unitIdToSellingPriceMap.put(dealItemRec.Id, unitPreTaxTotal);
                }
            }
            dealItemRecList = null;
            Map<String, Service_Order_Header__c> soIdToSORecMap = new Map<String, Service_Order_Header__c>();
            for(Service_Order_Header__c soHeadRec : soHeaderList) {
                soIdToSORecMap.put(soHeadRec.Id, soHeadRec);
            }
            
            Map<String, List<Service_Order_Line_Item__c>> soHeaderIdToSOLIListMap = new Map<String, List<Service_Order_Line_Item__c>>();
            for(Service_Order_Line_Item__c soLineItemRec : soliRecList) {
                if(!soHeaderIdToSOLIListMap.containsKey(soLineItemRec.Service_Order_Header__c)){
                    soHeaderIdToSOLIListMap.put(soLineItemRec.Service_Order_Header__c, new List<Service_Order_Line_Item__c>());
                    
                }
                soHeaderIdToSOLIListMap.get(soLineItemRec.Service_Order_Header__c).add(soLineItemRec);
            }
            Map<String, List<CO_Line_Item__c>> coKitHeaderIdToCOKLIListMap = new Map<String, List<CO_Line_Item__c>>();
            for(CO_Line_Item__c cokliLineItemRec : cokliRecList) {
                if(!coKitHeaderIdToCOKLIListMap.containsKey(cokliLineItemRec.CO_Kit_Header__c)){
                    coKitHeaderIdToCOKLIListMap.put(cokliLineItemRec.CO_Kit_Header__c, new List<CO_Line_Item__c>());
                    
                }
                coKitHeaderIdToCOKLIListMap.get(cokliLineItemRec.CO_Kit_Header__c).add(cokliLineItemRec);
            }
            
            Integer loopIndex = 0;
            String lastInvoiceWithGLEntry = '';
            //Decimal totalInvoicePaymentForSingleInvoiceHeader = 0;
            Set<String> coInvoiceHeaderName = new Set<String>();
            for(CO_Invoice_Item__c coInvoiceItem : coInvoiceItemsList) {
                String prevInvoiceHeaderName = ((loopIndex - 1) >= 0) ? coInvoiceItemsList[loopIndex - 1].CO_Invoice_Header__r.Name : '';
                loopIndex++;
                
                //Creating Header Entry for new CO Invoice Header
                String miscSalesExport = miscSalesExportTextData;
                if(prevInvoiceHeaderName != coInvoiceItem.CO_Invoice_Header__r.Name) {
                    miscSalesIndexVal++;
                    miscSalesExportTextData += '\n';
                }
                Boolean createTaxLine = true;
                //Creating CO Invoice Item Entry (Misc Sales)
                if(coInvoiceItem.CO_Line_Item__c != null && coInvoiceItem.CO_Line_Item__r.Deal__c == null) {
                    recordCountMiscSales++;
                    miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                                    createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, null, null, false),
                                                                                    miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c'
                                                                                );
                } else if(coInvoiceItem.Service_Order_Header__c != null && (coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Customer' || 
                    coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Third-Party') && 
                    coInvoiceItem.Service_Order_Header__r.Deal_Item__c == null && soHeaderIdToSOLIListMap.containsKey(coInvoiceItem.Service_Order_Header__c)) {
                    if(coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName != 'Internal') {
                        recordCountMiscSales++;
						if(coInvoiceItem.Service_Order_Header__r.Transaction_Type__r.Type__c != 'Third-Party' || (coInvoiceItem.SO_Payment_Role__c != null && coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName != 'Deductible')) {
                            for(Service_Order_Line_Item__c soLineItemRec : soHeaderIdToSOLIListMap.get(coInvoiceItem.Service_Order_Header__c)) {                                
                                if(coInvoiceItem.SO_Payment_Role__c != null && coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Third_Party') {
                                    miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                    createThirdPartyMiscSalesRecFromInvItem(coInvoiceItem, soLineItemRec, soIdToSORecMap.get(coInvoiceItem.Service_Order_Header__c)), miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                } else {
                                    miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                    createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, soLineItemRec, null, null, null, null, false), miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                }
                            }
                        }
                        
                        if(coInvoiceItem.SO_Payment_Role__c != null && (coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Deductible' || (coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Third_Party' && 
                            soIdToSORecMap.get(coInvoiceItem.Service_Order_Header__c).SO_Payment_Roles__r.size() > 0))) {
                            miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                createDeductibleMiscSalesRecFromInvItem(coInvoiceItem, soIdToSORecMap.get(coInvoiceItem.Service_Order_Header__c)), miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                        }
                    }
                    
                } else if(coInvoiceItem.CO_Kit_Header__c != null && coInvoiceItem.CO_Kit_Header__r.Deal__c == null && coKitHeaderIdToCOKLIListMap.containsKey(coInvoiceItem.CO_Kit_Header__c)) {
                    for(CO_Line_Item__c cokliRec : coKitHeaderIdToCOKLIListMap.get(coInvoiceItem.CO_Kit_Header__c)) {
                        recordCountMiscSales++;
                        miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                            createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, cokliRec, null, null, null, null, null, false), miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                    }
                } else if(coInvoiceItem.Deal__c != null && (dealIdToDealItemListMap.containsKey(coInvoiceItem.Deal__c) || dealIdToTradeInListMap.containsKey(coInvoiceItem.Deal__c))) {
                    if(dealIdToDealItemListMap.containsKey(coInvoiceItem.Deal__c)) {
                        for(Deal_Item__c dealItemRec : dealIdToDealItemListMap.get(coInvoiceItem.Deal__c)) {
                            if(GeneralConfiguration.isAccruTradeTaxUntilUnitSold() && dealItemRec.Customer_Owned_Unit__r.Trade_In_Value__c != null && dealItemRec.Customer_Owned_Unit__r.Trade_In_Value__c != 0) {
                                //#4880 - Australia - Tax Accrual on Trade-ins
                                recordCountMiscSales++;
                                dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c = dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c != null ? dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c : 0;
                                if(dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c != 0) {
                                    miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++,
                                                                        createMiscRecordForUnitTradeTax(coInvoiceItem, dealItemRec, false, dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c), 
                                                                        miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                                                        
                                }
                                Decimal sellingPrice = unitIdToSellingPriceMap.containsKey(dealItemRec.Id) ? unitIdToSellingPriceMap.get(dealItemRec.Id) : 0;
                                if(sellingPrice >= dealItemRec.Customer_Owned_Unit__r.Trade_In_Value__c) {
                                    if(dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c != 0) {
                                        recordCountMiscSales++;
                                        miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                            createMiscRecordForUnitTradeTax(coInvoiceItem, dealItemRec, true, dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c), 
                                                                            miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                    }
                                } else {
                                    if(unitIdToTaxAmountMap.containskey(dealItemRec.Id) && unitIdToTaxAmountMap.get(dealItemRec.Id) != 0) {
                                        recordCountMiscSales++;
                                        miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                            createMiscRecordForUnitTradeTax(coInvoiceItem, dealItemRec, true, unitIdToTaxAmountMap.get(dealItemRec.Id)), 
                                                                            miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                    }
                                    Decimal diffTaxAmount = (!unitIdToTaxAmountMap.containskey(dealItemRec.Id)) ? dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c :
                                                                    (dealItemRec.Customer_Owned_Unit__r.Sales_Tax_Credit__c - unitIdToTaxAmountMap.get(dealItemRec.Id));
                                    if(diffTaxAmount != null && diffTaxAmount != 0) {
                                        recordCountMiscSales++;
                                        miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                            createMiscSalesRecordForTradeInVariance(coInvoiceItem, dealItemRec, diffTaxAmount), 
                                                                            miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                    }
                                }
                            }
                            if(dealItemRec.Deal_Unit_Prices_Costs__r.size() > 0) {
                                for(Deal_Unit_Price_Cost__c dealUnitPriceCostRec : dealItemRec.Deal_Unit_Prices_Costs__r) {
                                    recordCountMiscSales++;
                                    miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                        createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, null, dealUnitPriceCostRec, null,
                                                                         dealItemRec, null, false), miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                }
                            }
                            if(dealItemRec.Stamp_Duty_Total__c > 0) {
                                recordCountMiscSales++;
                                miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                    createMiscSalesRecordForStampDuty(coInvoiceItem, dealItemRec), miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                            }
                            
                            if(dealItemRec.Options_Fees__r.size() > 0) {
                                for(Option_Fee__c optionAndFeeRec : dealItemRec.Options_Fees__r) {
                                    recordCountMiscSales++;
                                    miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                        createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, null, null, optionAndFeeRec, dealItemRec, null, false), 
                                                                        miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                }
                            }
                        }
                    }
                    
                    if(dealIdToFAndIProductListMap.containsKey(coInvoiceItem.Deal__c)) {
                        for(F_I_Product__c fAndIProductRec : dealIdToFAndIProductListMap.get(coInvoiceItem.Deal__c)) {
                            recordCountMiscSales++;
                            //system.assert(false, createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, null, fAndIProductRec));
                            miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, null, fAndIProductRec, false), 
                                                                miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                        }
                    }
                    
                    if(dealIdToTradeInListMap.containsKey(coInvoiceItem.Deal__c)) {
                        for(Deal_Item__c dealItemRec : dealIdToTradeInListMap.get(coInvoiceItem.Deal__c)) {
                            recordCountMiscSales++;
                            
                            //Sales
                            miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, dealItemRec, null, false), 
                                                                miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                            if(dealItemRec.Lien_Payout__c != null && dealItemRec.Lien_Payout__c != 0) {
                                miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                createMiscellaneousSalesRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, dealItemRec, null, true), 
                                                                miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                            }
                            
                            dealItemRec.Agreed_Value__c = dealItemRec.Agreed_Value__c != null ? dealItemRec.Agreed_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
                            dealItemRec.Actual_Cash_Value__c = dealItemRec.Actual_Cash_Value__c != null ? dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
                            dealItemRec.Default_Unit_Sales_Tax_Percentage__c = (dealItemRec.Default_Unit_Sales_Tax_Percentage__c != null) ? dealItemRec.Default_Unit_Sales_Tax_Percentage__c : 0;
                                
                            Decimal preTaxAgreedValue = (isTaxIncludingPricing ? (dealItemRec.Agreed_Value__c / (1 + dealItemRec.Default_Unit_Sales_Tax_Percentage__c/100)) : dealItemRec.Agreed_Value__c);                             
                            Decimal variance = preTaxAgreedValue - dealItemRec.Actual_Cash_Value__c;
                            if(variance != 0) {
                                //variance
                                miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                createMiscSalesRecordForTradeInVariance(coInvoiceItem, dealItemRec, variance), 
                                                                miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                                
                            }
                            if(GeneralConfiguration.isAccruTradeTaxUntilUnitSold() && (dealItemRec.Stocked_In_Unit__r.Sales_Tax_Credit__c != null && 
                                dealItemRec.Stocked_In_Unit__r.Sales_Tax_Credit__c != 0)) {
                                miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                createMiscRecordForUnitTradeTax(coInvoiceItem, dealItemRec, false, dealItemRec.Stocked_In_Unit__r.Sales_Tax_Credit__c), 
                                                                miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                            
                                miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                createMiscRecordForUnitTradeTax(coInvoiceItem, dealItemRec, true, dealItemRec.Stocked_In_Unit__r.Sales_Tax_Credit__c), 
                                                                miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                            
                                /*Map<String, String> invGLRecord = null;
                                invGLRecord = createJEForTradeInTax(coInvoiceItem, dealItemRec, true);
                                if(invGLRecord != null) {
                                    recordCountInventoryGL++;
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                }
                                invGLRecord = createJEForTradeInTax(coInvoiceItem, dealItemRec, false);
                                if(invGLRecord != null) {
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                }*/
                            }
                        }
                    }
                    
                    
                } else {
                    createTaxLine = false;
                    miscSalesExportTextData = miscSalesExport;
                    miscSalesIndexVal--;
                }
                
                if(!isTaxIncludingPricing && createTaxLine && coInvoiceItem.CO_Invoice_Header__r.SalesTax_Total__c != 0 && ((coInvoiceItemsList.size() == loopIndex) || 
                        (coInvoiceItemsList.size() > loopIndex && (coInvoiceItem.CO_Invoice_Header__r.Name != coInvoiceItemsList[loopIndex].CO_Invoice_Header__r.Name)))) {
                    if(coHeaderIdToIndividualTaxNameToAmountMap.containsKey(coInvoiceItem.CO_Invoice_Header__c)) {
                        Map<String, Decimal> taxNameToTaxAmountMap = coHeaderIdToIndividualTaxNameToAmountMap.get(coInvoiceItem.CO_Invoice_Header__c);
                        for(String taxName : taxNameToTaxAmountMap.keySet()) {
                            miscSalesExportTextData += DataExportUtil.createImportableTextForInvoice(miscSalesIndexVal++, 
                                                                            createTaxRecordEntry(coInvoiceItem, soIdToSORecMap.get(coInvoiceItem.Service_Order_Header__c), 
                                                                            taxName, taxNameToTaxAmountMap.get(taxName), true),
                                                                            miscellaneousSalesSFFieldToAccountingFieldsMap, 'CO_Invoice_Item__c');
                        }
                    }
                }
                
                //Payment Text Generation
                if(!coInvoiceHeaderName.contains(coInvoiceItem.CO_Invoice_Header__r.Name) && coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Customer' && 
                    (coInvoiceItem.CO_Invoice_Header__r.Total_Amount_Except_Charge_Account__c != 0)) {
                    if((coInvoiceItem.Deal__c != null) || (coInvoiceItem.CO_Line_Item__c != null && coInvoiceItem.CO_Line_Item__r.Deal__c == null) || 
                            (coInvoiceItem.CO_Kit_Header__c != null && coInvoiceItem.CO_Kit_Header__r.Deal__c == null) || 
                            (coInvoiceItem.Service_Order_Header__c != null && coInvoiceItem.Service_Order_Header__r.Deal_Item__c == null && 
                                coInvoiceItem.Service_Order_Header__r.Deal__c == null)) {
                        invoicePaymentExportTextData += DataExportUtil.createImportableTextForInvoice(invoicePaymentIndexVal++, 
                                                createInvoicePaymentRecordFromInvoiceItem(coInvoiceItem, coInvoiceItem.CO_Invoice_Header__r.Total_Amount_Except_Charge_Account__c),
                                                                                    invoicePaymentSFFieldToAccountingFieldsMap, 'Customer Sales Invoice Payment') + '\n';
                                                                                    
                    }
                    coInvoiceHeaderName.add(coInvoiceItem.CO_Invoice_Header__r.Name);
                }
                
                //String lastValue = inventoryGLExportTextData;
                //Process to include new line (Blank Line) for new invoice included
                String glTextEntry = '';
                if(prevInvoiceHeaderName != coInvoiceItem.CO_Invoice_Header__r.Name){
                    inventoryGLIndexVal++;
                    glTextEntry += '\n';
                }
                //GL Entry for COLI (Part)
                
                if(coInvoiceItem.CO_Line_Item__c != null) {
                    Deal_Item__c dealItemRec;
                    if(coInvoiceItem.CO_Line_Item__r.Deal__c != null) {
                        dealItemRec = new Deal_Item__c();
                        if(dealIdToDealItemListMap.containsKey(coInvoiceItem.CO_Line_Item__r.Deal__c)) {
                            dealItemRec = dealIdToDealItemListMap.get(coInvoiceItem.CO_Line_Item__r.Deal__c)[0];
                        }
                        Map<String, String> invGLRecord =createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, dealItemRec, null, true, false);
                        if(invGLRecord != null) {
                            glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                    invGLRecord, 
                                                    SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                        
                        }
                        Map<String, String> invGLRecordForNI =createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, dealItemRec, null, true, true);
                        if(invGLRecordForNI != null) {
                            glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                    invGLRecordForNI, 
                                                    SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                        }
                    }
                    
                    //Creating Inventory GL Entry
                    if(coInvoiceItem.CO_Line_Item__r.Fee__c == null) {
                        Map<String, String> invGLRecord = null;
                        invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, dealItemRec, null, false, true);
                        if(invGLRecord != null) {
                            recordCountInventoryGL++;
                            glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                        invGLRecord,
                                                        SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                        }
                        invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, dealItemRec, null, false, false);
                        if(invGLRecord != null) {
                            glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                        invGLRecord,
                                                        SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                        }
                    }                                                           
                } else if(coInvoiceItem.CO_Kit_Header__c != null) {
                    if(coKitHeaderIdToCOKLIListMap.containsKey(coInvoiceItem.CO_Kit_Header__c)) {
                        
                        for(CO_Line_Item__c cokliRec : coKitHeaderIdToCOKLIListMap.get(coInvoiceItem.CO_Kit_Header__c)) {
                            //Creating Inventory GL Entry
                            Deal_Item__c dealItemRec;
                            if(coInvoiceItem.CO_Kit_Header__r.Deal__c != null) {
                                dealItemRec = new Deal_Item__c();
                                if(dealIdToDealItemListMap.containsKey(coInvoiceItem.CO_Kit_Header__r.Deal__c)) {
                                    dealItemRec = dealIdToDealItemListMap.get(coInvoiceItem.CO_Kit_Header__r.Deal__c)[0];
                                }
                                glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                    createGLRecordFromInvoiceItem(coInvoiceItem, cokliRec, null, null, null, dealItemRec, null, true, false), 
                                                    SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                    createGLRecordFromInvoiceItem(coInvoiceItem, cokliRec, null, null, null, dealItemRec, null, true, true), 
                                                    SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                            }
                            
                            if(cokliRec.Fee__c == null) {
                                Map<String, String> invGLRecord = null;
                                invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, cokliRec, null, null, null, dealItemRec, null, false, true);
                                if(invGLRecord != null) {
                                    recordCountInventoryGL++;
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                }
                                invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, cokliRec, null, null, null, dealItemRec, null, false, false);
                                if(invGLRecord != null) {
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                }
                            }
                        }
                    }
                } else if(coInvoiceItem.Service_Order_Header__c != null && (coInvoiceItem.SO_Payment_Role__c == null || coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName != 'Deductible')) {
                    if(soHeaderIdToSOLIListMap.containsKey(coInvoiceItem.Service_Order_Header__c)) {
                        
                        for(Service_Order_Line_Item__c soLineItemRec : soHeaderIdToSOLIListMap.get(coInvoiceItem.Service_Order_Header__c)) {
                            //Creating Inventory GL Entry
                            Deal_Item__c dealItemRec;
                            if(coInvoiceItem.Service_Order_Header__r.Deal_Item__c != null) {
                                dealItemRec = new Deal_Item__c();
                                Map<String, String> invGLRecord = null;
                                if(dealItemRecMap.containsKey(coInvoiceItem.Service_Order_Header__r.Deal_Item__c)) {
                                    dealItemRec = dealItemRecMap.get(coInvoiceItem.Service_Order_Header__r.Deal_Item__c);
                                }
                                invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, soLineItemRec, null, null, dealItemRec, null, true, false);
                                if(invGLRecord != null) {
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                            invGLRecord, 
                                                            SFFieldToAccountingFieldsMap, 'Customer Sales GL'); 
                                }
                                invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, soLineItemRec, null, null, dealItemRec, null, true, true);
                                if(invGLRecord != null) {
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                            invGLRecord, 
                                                            SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                }
                            }
                                
					    	if(soLineItemRec.Fee__c == null && (coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c != 'Third-Party' || 
					    		(coInvoiceItem.SO_Payment_Role__c != null && coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName != 'Internal'))) {
                                Map<String, String> invGLRecord = null;
                                invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, soLineItemRec, null, null, dealItemRec, null, false, true);
                                if(invGLRecord != null) {
                                    recordCountInventoryGL++;
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                }
                                invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, soLineItemRec, null, null, dealItemRec, null, false, false);
                                if(invGLRecord != null) {
                                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                }
                            }
			    			
			    			
			    			/** Third Party  Claim varinace Line Entry For Bill to Intenral 
	                          * Credit -> SOLI income GL
	                          * Debit ->  Category selected in the variance disposition. 
	                          * Amount -> Total Variance amount
	                          * Desc -> <Third Party vendor>;<CO-Number>;'Claim Variance';<SOLI Desc>
	                          */
	                        if(coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Third-Party' && coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Internal' && soLineItemRec.Claim_Line_Items__r.size() > 0) { //soliIdToBillToInternalClaimLIListMap.containsKey(soLineItemRec.Id
	                        	Map<String, String> invGLRecordForBillToInternalClaimLI;
	                        	for(Claim_Line_Item__c billToInternalClaimLI : soLineItemRec.Claim_Line_Items__r) {
	                        		if(billToInternalClaimLI.Total_Variance_Amount__c != null && billToInternalClaimLI.Total_Variance_Amount__c != 0) {
	                        			invGLRecordForBillToInternalClaimLI = createGLRecordFromInvoiceItem(coInvoiceItem, soLineItemRec, billToInternalClaimLI, true);
		                        		if(invGLRecordForBillToInternalClaimLI != null) {
					    					glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, invGLRecordForBillToInternalClaimLI, 
					    										SFFieldToAccountingFieldsMap, 'Customer Sales GL');
						    			}
						    			
						    			invGLRecordForBillToInternalClaimLI = createGLRecordFromInvoiceItem(coInvoiceItem, soLineItemRec, billToInternalClaimLI, false);
		                        		if(invGLRecordForBillToInternalClaimLI != null) {
					    					glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, invGLRecordForBillToInternalClaimLI, 
					    										SFFieldToAccountingFieldsMap, 'Customer Sales GL');
						    			}
	                        		}
	                        	}
	                        }
                        }
                        
                        if(coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Internal' ||
				    				coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Third-Party') {
				    		if(!isTaxIncludingPricing && coHeaderIdToIndividualTaxNameToAmountMap.containsKey(coInvoiceItem.CO_Invoice_Header__c)) {
		    					Map<String, Decimal> taxNameToTaxAmountMap = coHeaderIdToIndividualTaxNameToAmountMap.get(coInvoiceItem.CO_Invoice_Header__c);
		    					for(String taxName : taxNameToTaxAmountMap.keySet()) {
		    						if(taxNameToTaxAmountMap.get(taxName) != 0) {
		    							glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
																					createTaxRecordEntry(coInvoiceItem, soIdToSORecMap.get(coInvoiceItem.Service_Order_Header__c),
																					taxName, taxNameToTaxAmountMap.get(taxName), false),
																					SFFieldToAccountingFieldsMap, 'Customer Sales GL');
		    						}
		    					}
				    		}
				    		
				    		//Total Internal Service
				    		if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service' && 
				    			coInvoiceItem.Service_Order_Header__r.Job_Type__c == 'Internal') {
								Map<String,String> invoiceItemRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, null, null, true, true);
					    		if(invoiceItemRecord != null) {
					    			glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
					    										invoiceItemRecord, 
					    										SFFieldToAccountingFieldsMap, 'Customer Sales GL');
					    		}
							}
	    				}
	    			}
                    
                } else if(coInvoiceItem.Deal__c != null && dealIdToDealItemListMap.containsKey(coInvoiceItem.Deal__c)) {
                    Map<String, List<Unit_Price_Cost__c>> dealItemIdToPriceCostListMap = AccountingUtil.setDealItemIdToPriceCostListMap(dealIdToDealItemListMap.get(coInvoiceItem.Deal__c));
                    for(Deal_Item__c dealItemRec : dealIdToDealItemListMap.get(coInvoiceItem.Deal__c)) {
                        Map<String, String> invGLRecord = null;
                        for(Unit_Price_Cost__c unitPriceCostRec : dealItemIdToPriceCostListMap.get(dealItemRec.Id)) {
                            invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, unitPriceCostRec, null, dealItemRec, null, false, true);
                            if(invGLRecord != null) {
                                recordCountInventoryGL++;
                                glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                            invGLRecord,
                                                            SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                            }
                            invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, unitPriceCostRec, null, dealItemRec, null, false, false);                                
                            if(invGLRecord != null) {
                                glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                            }
                        }
                        
                        if(dealItemRec.Options_Fees__r.size() > 0) {
                            for(Option_Fee__c optionAndFeeRec : dealItemRec.Options_Fees__r) {
                                if(optionAndFeeRec.Fee__c == null) {
                                    invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, optionAndFeeRec, dealItemRec, null, false, true);
                                    if(invGLRecord != null) {
                                        recordCountInventoryGL++;
                                        glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                    invGLRecord,
                                                                    SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                    }
                                    invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, optionAndFeeRec, dealItemRec, null, false, false);
                                    if(invGLRecord != null) {
                                        glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                    invGLRecord,
                                                                    SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                                    }
                                }
                            }
                        }
                    }
                    if(dealIdToFAndIProductListMap.containsKey(coInvoiceItem.Deal__c)) {
                        for(F_I_Product__c fAndIProductRec : dealIdToFAndIProductListMap.get(coInvoiceItem.Deal__c)) {
                            Map<String, String> invGLRecord = null;
                            invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, null, fAndIProductRec, false, true);
                            if(invGLRecord != null) {
                                recordCountInventoryGL++;
                                glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                            invGLRecord,
                                                            SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                            }
                            invGLRecord = createGLRecordFromInvoiceItem(coInvoiceItem, null, null, null, null, null, fAndIProductRec, false, false);                                
                            if(invGLRecord != null) {
                                glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                                invGLRecord,
                                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                            }
                        }
                    }
                } /*else {
                    inventoryGLIndexVal--;
                    //inventoryGLExportTextData = lastValue;
                }*/
                if(glTextEntry.replace(' ', '').replace('\n', '').length() > 0) {
                    if(lastInvoiceWithGLEntry != prevInvoiceHeaderName && prevInvoiceHeaderName == coInvoiceItem.CO_Invoice_Header__r.Name) {
                        inventoryGLExportTextData += '\n';
                    }
                    inventoryGLExportTextData += glTextEntry;
                    lastInvoiceWithGLEntry = coInvoiceItem.CO_Invoice_Header__r.Name;
                } else {
                    inventoryGLIndexVal--;
                }
            }
            
            loopIndex = 0;
            for(Deal_Item__c stockedUnitRec : stockedTradeInIdToRecMap.values()) {
                String prevInvoiceHeaderName = ((loopIndex - 1) >= 0) ? stockedTradeInIdToRecMap.values()[loopIndex - 1].Deal__r.CO_Header__r.Name : '';
                loopIndex++;
                
                String glTextEntry = '';
                if(prevInvoiceHeaderName != stockedUnitRec.Deal__r.CO_Header__r.Name){
                    inventoryGLIndexVal++;
                    glTextEntry += '\n';
                }
                
                Map<String, String> invGLRecord = createJEForStockedInTradeUnit(stockedUnitRec, true);
                if(invGLRecord != null) {
                    recordCountInventoryGL++;
                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                invGLRecord,
                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                }
                invGLRecord = createJEForStockedInTradeUnit(stockedUnitRec, false);
                if(invGLRecord != null) {
                    glTextEntry += DataExportUtil.createImportableTextForInvoice(inventoryGLIndexVal++, 
                                                invGLRecord,
                                                SFFieldToAccountingFieldsMap, 'Customer Sales GL');
                }
                
                if(glTextEntry.replace(' ', '').replace('\n', '').length() > 0) {
                    if(lastInvoiceWithGLEntry != prevInvoiceHeaderName && prevInvoiceHeaderName == stockedUnitRec.Deal__r.CO_Header__r.Name) {
                        inventoryGLExportTextData += '\n';
                    }
                    inventoryGLExportTextData += glTextEntry;
                    lastInvoiceWithGLEntry = stockedUnitRec.Deal__r.CO_Header__r.Name;
                } else {
                    inventoryGLIndexVal--;
                }
            }

            miscSalesExportTextData = (miscSalesExportTextData.indexOf('{') != -1) ? miscSalesExportTextData.subString(miscSalesExportTextData.indexOf('{')) : miscSalesExportTextData;
            invoicePaymentExportTextData = (invoicePaymentExportTextData.indexOf('{') != -1) ? invoicePaymentExportTextData.subString(invoicePaymentExportTextData.indexOf('{')) : invoicePaymentExportTextData;
            inventoryGLExportTextData = (inventoryGLExportTextData.indexOf('{') != -1) ? inventoryGLExportTextData.subString(inventoryGLExportTextData.indexOf('{')) : inventoryGLExportTextData;
        }
    }
    
    /**
     * Name: finish
     * Desc: Batch finish method to insert a attachment for exported data in text file
     * @param:  1. Database.BatchableContext BC
     * @return:
    **/
    global void finish(Database.BatchableContext BC) {
        if(AccessControl.ifObjectFieldIsCreateable('Attachment') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Accounting_Data_Migration__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        
        dataMigration.Records_Processed__c = recordCountMiscSales;
        upsert dataMigration;
        
        List<Attachment> attachmentsList = new List<Attachment>();
        if(dataMigration.Records_Processed__c > 0) {
            attachmentsList.add(DataExportUtil.createAttachment(miscSalesExportTextData, 'MISCSALE_', dataMigration, recordCountMiscSales));
        }
        if(invoicePaymentIndexVal-1 > 0) {
            attachmentsList.add(DataExportUtil.createAttachment(invoicePaymentExportTextData, 'INVOICE_PAYMENT_', dataMigration, invoicePaymentIndexVal-1));
        }
        if(recordCountInventoryGL > 0 ) {
            attachmentsList.add(DataExportUtil.createAttachment(inventoryGLExportTextData, 'INVENTORY_GL_', dataMigration, recordCountInventoryGL));
        }
        
        if(attachmentsList.size() > 0) {
            insert attachmentsList;
        }
    }
    
    /** 
     * Name: createMiscellaneousSalesSFFieldToAccountingFieldsMap
     * Desc: Method to create a map of MiscellaneousSales Salesforce fields to Accounting field map so as to map in generated TXT file
     * @param: 
     * @return: Map<String, String>
    **/
    private static Map<String, String> createMiscellaneousSalesSFFieldToAccountingFieldsMap() {
        Map<String, String> miscellaneousSalesSFFieldToAccountingFieldsMap = new Map<String, String>{'Last_Name__c'         =>  'Co./Last Name',
                                                                                                     'First_Name__c'        =>  'First Name',
                                                                                                     'Invoice_No__c'        =>  'Invoice No.',
                                                                                                     'Date__c'              =>  'Date',
                                                                                                     'Inclusive__c'         =>  'Inclusive',
                                                                                                     'Memo__c'              =>  'Memo',
                                                                                                     'Description__c'       =>  'Description',
                                                                                                     'Account_No__c'        =>  'Account No.',
                                                                                                     'Amount__c'            =>  'Amount',
                                                                                                     'Tax_Code__c'          =>  'Tax Code',
                                                                                                     'Tax_Amount__c'        =>  'Tax Amount',
                                                                                                     'Card_ID__c'           =>  'Card ID'
                                                                                                };
        
        return miscellaneousSalesSFFieldToAccountingFieldsMap;
    }
    
    private Map<String, String> createTaxRecordEntry(CO_Invoice_Item__c coInvoiceItem, Service_Order_Header__c soRec, String taxName, Decimal taxAmount, Boolean isMiscSalesTaxEntry) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> exportFilefieldNameToValueMap = new Map<String, String>{'Date__c'   =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                'Inclusive__c'      =>  isMiscSalesTaxEntry ? (isTaxIncludingPricing ? 'Yes' : 'No') : 'X',
                                                                'Tax_Amount__c'     =>  String.valueOf(taxAmount.setScale(2, RoundingMode.HALF_UP)),
                                                                'Description__c'    =>  taxName,
                                                                'Tax_Code__c'       =>  'N-T',
                                                                'Amount__c'     =>  '$' + String.valueOf(taxAmount.setScale(2, RoundingMode.HALF_UP))
                                                            };
        if(isMiscSalesTaxEntry) {
            exportFilefieldNameToValueMap.put('Invoice_No__c', (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''));
            exportFilefieldNameToValueMap.put('Memo__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + 
                                    coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';' + coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c + ';Invoice');
            if(soRec != null && soRec.Claims__r.size() > 0 && soRec.Claims__r[0].Provider_Claim_Number__c != null) {
                exportFilefieldNameToValueMap.put('Memo__c', exportFilefieldNameToValueMap.get('Memo__c') + ';Claim ' +soRec.Claims__r[0].Provider_Claim_Number__c);
            }   
            if(coInvoiceItem.Service_Order_Header__r.Provider__c != null) {
                exportFilefieldNameToValueMap.put('First_Name__c', '');
                exportFilefieldNameToValueMap.put('Last_Name__c',coInvoiceItem.Service_Order_Header__r.Provider__r.Name);
                exportFilefieldNameToValueMap.put('Card_ID__c', coInvoiceItem.Service_Order_Header__r.Provider__r.Vendor_Code__c);
            } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
                if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual'){
                    exportFilefieldNameToValueMap.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                    exportFilefieldNameToValueMap.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
                } else {
                    exportFilefieldNameToValueMap.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
                }
                exportFilefieldNameToValueMap.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
            } else {
                if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Cash Sale') {
                    exportFilefieldNameToValueMap.put('Last_Name__c', 'CASH SALE');
                    exportFilefieldNameToValueMap.put('Card_ID__c', cashCustomerId);
                } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service') {
                    exportFilefieldNameToValueMap.put('Last_Name__c', 'UNIT INVENTORY');
                    exportFilefieldNameToValueMap.put('Card_ID__c', internalServiceCustomerId);
                }
            }
        } else if(coInvoiceItem.Service_Order_Header__c != null && (coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Internal' ||
                                    coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Third-Party')) {
            String memo = 'UNIT INVENTORY;' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';Internal Service';
            exportFilefieldNameToValueMap.put('Memo__c', memo);
            
            exportFilefieldNameToValueMap.put('Journal_Number__c', (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''));
            exportFilefieldNameToValueMap.put('Reporting__c', 'S');
            exportFilefieldNameToValueMap.put('Account_No__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
            exportFilefieldNameToValueMap.put('Is_Credit__c', 'Y');
            exportFilefieldNameToValueMap.put('Allocation_Memo__c', taxName);
        }
        
        if(salesTaxNameToSalesTaxItemRecMap.containsKey(taxName) && String.isNotBlank(salesTaxNameToSalesTaxItemRecMap.get(taxName).Category__r.Income_GL__c)) {
            exportFilefieldNameToValueMap.put('Account_No__c', salesTaxNameToSalesTaxItemRecMap.get(taxName).Category__r.Income_GL__c);
        } else {
            exportFilefieldNameToValueMap.put('Account_No__c', entityNameToDefaultAccTypeToAccNumberMap.get('Tax').get('Income GL'));
        }
        return exportFilefieldNameToValueMap;
    }
    
    private Map<String, String> createMiscSalesRecordForStampDuty(CO_Invoice_Item__c coInvoiceItem, Deal_Item__c dealItemRec) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> miscSales = new Map<String, String>{'Invoice_No__c'     =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                'Inclusive__c'      =>  isTaxIncludingPricing ? 'Yes' : 'No',
                                                                'Memo__c'           =>  coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + 
                                                                                        ';'+coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c +';Invoice',
                                                                'Tax_Amount__c'     => '0'
                                                            };
        if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual') {
                miscSales.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
            } else {
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
            }
            miscSales.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
        } else {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Cash Sale') {
                miscSales.put('Last_Name__c', 'CASH SALE');
                miscSales.put('Card_ID__c', cashCustomerId);
            } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service') {
                miscSales.put('Last_Name__c', 'UNIT INVENTORY');
                miscSales.put('Card_ID__c', internalServiceCustomerId);
            }
        }
        if(dealItemRec != null) {
            miscSales.put('Account_No__c', entityNameToDefaultAccTypeToAccNumberMap.get('Stamp Duty').get('Income GL'));
            Decimal stampDutyTotal = (dealItemRec.Stamp_Duty_Total__c != null) ? dealItemRec.Stamp_Duty_Total__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            miscSales.put('Amount__c',  ((stampDutyTotal < 0) ? '-': '') + '$' + ((stampDutyTotal < 0) ? 
                                    (-1 * stampDutyTotal).setScale(2, RoundingMode.HALF_UP) : stampDutyTotal.setScale(2, RoundingMode.HALF_UP)));
            
            String description = (dealItemRec.Customer_Owned_Unit__c != null) ? dealItemRec.Customer_Owned_Unit__r.Stock_Id__c + '-' : '';
            description += DataExportUtil.getUnitDescription(dealItemRec);
            description += '-Stamp Duty Rate ' + '@$'+ stampDutyTotal;
            miscSales.put('Description__c', description);
            
            miscSales.put('Tax_Code__c', 'N-T');    
        }
        return miscSales;
    }
    
    private Map<String, String> createDeductibleMiscSalesRecFromInvItem(CO_Invoice_Item__c coInvoiceItem, Service_Order_Header__c soHeaderRec) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> miscSales = new Map<String, String>{'Invoice_No__c'     =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                'Inclusive__c'      =>  isTaxIncludingPricing ? 'Yes' : 'No',
                                                                'Memo__c'           =>  coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + 
                                                                                        ';'+coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c +';Invoice',
                                                                'Tax_Amount__c'     => '0'
                                                            };
        
        if(soHeaderRec != null && soHeaderRec.Claims__r.size() > 0 && soHeaderRec.Claims__r[0].Provider_Claim_Number__c != null) {
            miscSales.put('Memo__c', miscSales.get('Memo__c') + ';Claim ' +soHeaderRec.Claims__r[0].Provider_Claim_Number__c);
        }
        
        if(coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Deductible') {     
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual') {
                miscSales.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
            } else {
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
            }
            miscSales.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
            
            miscSales.put('Amount__c',  ((coInvoiceItem.SO_Payment_Role__r.Total_Amount__c < 0) ? '-': '') + '$' + ((coInvoiceItem.SO_Payment_Role__r.Total_Amount__c < 0) ? 
                                (coInvoiceItem.SO_Payment_Role__r.Total_Amount__c * -1).setScale(2, RoundingMode.HALF_UP) : (coInvoiceItem.SO_Payment_Role__r.Total_Amount__c).setScale(2, RoundingMode.HALF_UP)));
        } else if(soHeaderRec.SO_Payment_Roles__r.size() > 0 && soHeaderRec.SO_Payment_Roles__r[0].RecordType.DeveloperName == 'Deductible' && soHeaderRec.SO_Payment_Roles__r[0].Total_Amount__c != null) {
            miscSales.put('First_Name__c', '');
          miscSales.put('Last_Name__c',coInvoiceItem.Service_Order_Header__r.Provider__r.Name);
          miscSales.put('Card_ID__c', coInvoiceItem.Service_Order_Header__r.Provider__r.Vendor_Code__c);
        
        miscSales.put('Amount__c',  ((soHeaderRec.SO_Payment_Roles__r[0].Total_Amount__c > 0) ? '-': '') + '$' + ((soHeaderRec.SO_Payment_Roles__r[0].Total_Amount__c > 0) ? 
                                (soHeaderRec.SO_Payment_Roles__r[0].Total_Amount__c).setScale(2, RoundingMode.HALF_UP) : (soHeaderRec.SO_Payment_Roles__r[0].Total_Amount__c * -1).setScale(2, RoundingMode.HALF_UP)));
        }   
        
        miscSales.put('Description__c', 'Claim deductible');
            
        miscSales.put('Account_No__c', entityNameToDefaultAccTypeToAccNumberMap.get('Deductible').get('Income GL'));
            
        miscSales.put('Tax_Code__c', 'N-T');        

        return miscSales;
    }
    
   private Map<String, String> createThirdPartyMiscSalesRecFromInvItem(CO_Invoice_Item__c coInvoiceItem, Service_Order_Line_Item__c soliRec, Service_Order_Header__c soRec) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> miscSales = new Map<String, String>();
        if(soliRec != null) {
            miscSales = createMiscSOLIEntry(soliRec);
        } 
        
        miscSales.put('Invoice_No__c', (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''));
        miscSales.put('Date__c', coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat));
        miscSales.put('Inclusive__c', isTaxIncludingPricing ? 'Yes' : 'No');
        miscSales.put('Tax_Amount__c', '0');
        miscSales.put('Memo__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + 
                                                                                        ';'+coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c +';Invoice');
        
        if(soRec != null && soRec.Claims__r.size() > 0 && soRec.Claims__r[0].Provider_Claim_Number__c != null) {
            miscSales.put('Memo__c', miscSales.get('Memo__c') + ';Claim ' + soRec.Claims__r[0].Provider_Claim_Number__c);
        }
            
        if(coInvoiceItem.Service_Order_Header__r.Provider__c != null) {
            miscSales.put('First_Name__c', '');
            miscSales.put('Last_Name__c',coInvoiceItem.Service_Order_Header__r.Provider__r.Name);
            miscSales.put('Card_ID__c', coInvoiceItem.Service_Order_Header__r.Provider__r.Vendor_Code__c);
        } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual') {
                miscSales.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
            } else {
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
            }
            miscSales.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
        }
        
        return miscSales;
    }
    
     private Map<String, String> createMiscSOLIEntry(Service_Order_Line_Item__c soliRec) {
        Map<String, String> miscSales = new Map<String, String>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            
            Decimal kitPrice = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c.setScale(2, RoundingMode.HALF_UP) : soliRec.Kit_Price__c;
            if(isTaxIncludingPricing && String.isBlank(soliRec.Deal__c)) {
                Decimal taxAmount = getTaxAmountWhenTaxIncluded(soliRec.Id);
                miscSales.put('Tax_Amount__c', String.valueOf(taxAmount));
                if(soliRec.Price_When_Tax_Included__c != null) {
                    kitPrice = soliRec.Price_When_Tax_Included__c - ((taxAmount / soliRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP));
                }
            }
            miscSales.put('Amount__c',  ((kitPrice < 0) ? '-': '') + '$' + ((kitPrice < 0) ? 
                                    (kitPrice * -1 * soliRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP) : (kitPrice * soliRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP)));
                                    
            kitPrice = (kitPrice != null) ? kitPrice.setScale(2, RoundingMode.HALF_UP) : 0;

            if(soliRec.Part__c != null) {
            miscSales.put('Description__c', soliRec.Part__r.Part_Number__c + '-' + soliRec.Part__r.Description__c + ' ' + 
                soliRec.Qty_Needed__c + '@$'+kitPrice + ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
            
            String incomeGLNumber = (soliRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c != null ? 
                soliRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c : ((soliRec.Part__r.Category__r.Income_GL__c != null) ? 
                soliRec.Part__r.Category__r.Income_GL__c : entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Income GL')));
            
            miscSales.put('Account_No__c', incomeGLNumber);
            
            miscSales.put('Tax_Code__c', (soliRec.Part__r.Applicable_Tax__c != null) ? soliRec.Part__r.Applicable_Tax__r.Name__c : 'N-T');      
        } else if(soliRec.Fee__c != null) {
            if(soliRec.Type__c == 'Shop Supply') {
                miscSales.put('Description__c', soliRec.Item_Code__c + '-' + soliRec.Item_Description__c + ' ' + soliRec.Qty_Needed__c + '@$'+kitPrice + ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
            } else {
                miscSales.put('Description__c', soliRec.Fee__r.Code__c + '-' + soliRec.Fee__r.Description__c + ' ' + soliRec.Qty_Needed__c + '@$'+kitPrice + ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
            }
            
            miscSales.put('Account_No__c', (soliRec.Fee__r.Category__c != null &&  soliRec.Fee__r.Category__r.Income_GL__c != null) ? soliRec.Fee__r.Category__r.Income_GL__c : 
                                                                            entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL'));
            
            miscSales.put('Tax_Code__c', (soliRec.Fee__r.Applicable_Tax__c != null) ? soliRec.Fee__r.Applicable_Tax__r.Name__c : 'N-T');        
        } else if(soliRec.Labour_Code__c != null) {
            miscSales.put('Description__c', soliRec.Labour_Code__r.Code__c + '-' + soliRec.Labour_Code__r.Description__c + ' ' + soliRec.Qty_Needed__c + '@$'+kitPrice + ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
            
            String incomeGLNumber = (soliRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c != null ? 
                soliRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c : ((soliRec.Labour_Code__r.Category__r.Income_GL__c != null) ? 
                soliRec.Labour_Code__r.Category__r.Income_GL__c : entityNameToDefaultAccTypeToAccNumberMap.get('Labour').get('Income GL')));
            
            miscSales.put('Account_No__c', incomeGLNumber);
            
            miscSales.put('Tax_Code__c', (soliRec.Labour_Code__r.Applicable_Tax__c != null) ? soliRec.Labour_Code__r.Applicable_Tax__r.Name__c : 'N-T');        
        } else if(soliRec.Sublet__c != null) {
            String subletDesc = (soliRec.Item_Code__c != null) ? soliRec.Item_Code__c : '';
			subletDesc += (soliRec.Item_Description__c != null) ? ((subletDesc.length() > 0 ? ' - ' : '' ) + soliRec.Item_Description__c) : '';
			miscSales.put('Description__c', subletDesc + ' ' + soliRec.Qty_Needed__c + '@$'+kitPrice + ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
            
            miscSales.put('Account_No__c', (soliRec.Sublet__r.Category__c != null && 
                    soliRec.Sublet__r.Category__r.Income_GL__c != null) ? soliRec.Sublet__r.Category__r.Income_GL__c : entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('Income GL'));
            
            miscSales.put('Tax_Code__c', (soliRec.Sublet__r.Applicable_Tax__c != null) ? soliRec.Sublet__r.Applicable_Tax__r.Name__c : 'N-T');  
        }
        
        return miscSales;
    }
    
    private Map<String, String> createMiscFAndIProductEntry(F_I_product__c fAndIProductRec) {
        Map<String, String> miscSales = new Map<String, String>();
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            
        fAndIProductRec.Price__c =  (fAndIProductRec.Price__c != null ? fAndIProductRec.Price__c : 0);
        if(isTaxIncludingPricing) {
            Decimal taxAmount = getTaxAmountWhenTaxIncluded(fAndIProductRec.Id);
            miscSales.put('Tax_Amount__c', String.valueOf(taxAmount));
        }
        miscSales.put('Amount__c',  ((fAndIProductRec.Price__c < 0) ? '-': '') + '$' + ((fAndIProductRec.Price__c < 0) ? 
                                (fAndIProductRec.Price__c * -1).setScale(2, RoundingMode.HALF_UP) : (fAndIProductRec.Price__c).setScale(2, RoundingMode.HALF_UP)));
                                    
        fAndIProductRec.Price__c = (fAndIProductRec.Price__c != null) ? fAndIProductRec.Price__c.setScale(2, RoundingMode.HALF_UP) : 0;

        miscSales.put('Description__c', fAndIProductRec.Item_Description__c + ' ' + 1.000 + '@$'+ fAndIProductRec.Price__c);
            
        miscSales.put('Account_No__c', (fAndIProductRec.Vendor_Product__r.Category__r.Income_GL__c != null) ? 
            fAndIProductRec.Vendor_Product__r.Category__r.Income_GL__c : entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Income GL'));
            
        miscSales.put('Tax_Code__c', (fAndIProductRec.Vendor_Product__r.Applicable_Tax__c != null) ? fAndIProductRec.Vendor_Product__r.Applicable_Tax__r.Name__c : 'N-T');      
        return miscSales;
    }
    
    private Map<String, String> createMiscSalesRecordForTradeInVariance(CO_Invoice_Item__c coInvoiceItem, Deal_Item__c dealItemRec, Decimal amount) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> miscSales = new Map<String, String>{'Invoice_No__c'     =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                'Inclusive__c'      =>  isTaxIncludingPricing ? 'Yes' : 'No',
                                                                'Memo__c'           =>  coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + 
                                                                                        ';'+coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c +';Invoice',
                                                                'Tax_Amount__c'     => '0'
                                                            };
                                                            
        if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual') {
                miscSales.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
            } else {
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
            }
            miscSales.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
        } else {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Cash Sale') {
                miscSales.put('Last_Name__c', 'CASH SALE');
                miscSales.put('Card_ID__c', cashCustomerId);
            } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service') {
                miscSales.put('Last_Name__c', 'UNIT INVENTORY');
                miscSales.put('Card_ID__c', internalServiceCustomerId);
            }
        }
        amount = (amount != null ? amount.setScale(2, RoundingMode.HALF_UP) : 0);
        String amountValue = ((amount > 0) ? '-$' + amount : '$' + (-1 * amount));
        miscSales.put('Amount__c',  amountValue);   
        if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
            miscSales.put('Account_No__c', (dealItemRec.Customer_Owned_Unit__r.Category__r.Income_GL__c != null) ? dealItemRec.Customer_Owned_Unit__r.Category__r.Income_GL__c : 
                                                                                                    entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Income GL'));
            miscSales.put('Description__c', ('Trade In-' + DataExportUtil.getUnitDescription(dealItemRec) + '-Variance ' + amountValue));
        } else if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT){
            miscSales.put('Account_No__c', entityNameToDefaultAccTypeToAccNumberMap.get('Trade In').get('Trade tax expense'));
            miscSales.put('Description__c', ('Stock Unit-' + DataExportUtil.getUnitDescription(dealItemRec) + '-Tax Variance ' + amountValue));
        }
        miscSales.put('Tax_Code__c', defaultUnitTaxName);
        return miscSales;
    }
    
    /**
     * Name: createMiscellaneousSalesRecordFromInvoiceItem
     * Desc: Method to create a MiscellaneousSales record by cocoInvoiceItem record. MiscellaneousSales record is a map of field name to equivalent value for field
     * @param: CO_Invoice_Item__c coInvoiceItem
     * @return: Map<String, String>
    **/
    private Map<String, String> createMiscellaneousSalesRecordFromInvoiceItem(CO_Invoice_Item__c coInvoiceItem, CO_Line_Item__c cokliRec, 
                                                    Service_Order_Line_Item__c soliRec, 
                                                    Deal_Unit_Price_Cost__c dealUnitPriceCostRec, Option_Fee__c optionAndFeeRec, 
                                                    Deal_Item__c dealItemRec, F_I_Product__c fAndIProductRec, Boolean isLienPayoutLine) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> miscSales = new Map<String, String>{'Invoice_No__c'     =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                'Inclusive__c'      =>  isTaxIncludingPricing ? 'Yes' : 'No',
                                                                'Memo__c'           =>  coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + 
                                                                                        ';'+coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c +';Invoice',
                                                                'Tax_Amount__c'     => '0'
                                                            };
                                                            
        if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual') {
                miscSales.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
            } else {
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
            }
            miscSales.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
        } else {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Cash Sale') {
                miscSales.put('Last_Name__c', 'CASH SALE');
                miscSales.put('Card_ID__c', cashCustomerId);
            } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service') {
                miscSales.put('Last_Name__c', 'UNIT INVENTORY');
                miscSales.put('Card_ID__c', internalServiceCustomerId);
            }
        }
        
        if(dealItemRec != null) {
            miscSales.put('Account_No__c', (dealItemRec.Customer_Owned_Unit__r.Category__c != null && 
                            dealItemRec.Customer_Owned_Unit__r.Category__r.Income_GL__c != null) ? dealItemRec.Customer_Owned_Unit__r.Category__r.Income_GL__c : 
                                                                                                entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Income GL'));
        }
                
        if(soliRec != null) {
            miscSales.putAll(createMiscSOLIEntry(soliRec));
        } else if(fAndIProductRec != null) {
            miscSales.putAll(createMiscFAndIProductEntry(fAndIProductRec));
        } else if(dealUnitPriceCostRec != null) {
        
            Decimal price = (dealUnitPriceCostRec.Price__c != null) ? dealUnitPriceCostRec.Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            dealUnitPriceCostRec.Qty__c = (dealUnitPriceCostRec.Qty__c != null && dealUnitPriceCostRec.Qty__c != 0) ? dealUnitPriceCostRec.Qty__c : 1;
            if(isTaxIncludingPricing) {
                Decimal taxAmount = getTaxAmountWhenTaxIncluded(dealUnitPriceCostRec.Id);
                miscSales.put('Tax_Amount__c', String.valueOf(taxAmount));
                if(dealUnitPriceCostRec.Price_When_Tax_Included__c != null) {
                    price = dealUnitPriceCostRec.Price_When_Tax_Included__c - (taxAmount / dealUnitPriceCostRec.Qty__c);
                }
            }
            miscSales.put('Amount__c',  ((price < 0) ? '-': '') + '$' + ((price < 0) ? 
                                    (-1 * price * dealUnitPriceCostRec.Qty__c).setScale(2, RoundingMode.HALF_UP) : (price * dealUnitPriceCostRec.Qty__c).setScale(2, RoundingMode.HALF_UP)));
            
            String description = (dealItemRec.Customer_Owned_Unit__c != null) ? dealItemRec.Customer_Owned_Unit__r.Stock_Id__c + '-' : '';
            description += DataExportUtil.getUnitDescription(dealItemRec);
            if(dealUnitPriceCostRec.Type__c == 'Base') {
                description += '-Base Price $'+ price;
            } else if(dealUnitPriceCostRec.Type__c == 'Factory') {
                description += '-Factory Option Price ' + dealUnitPriceCostRec.Qty__c + '@$'+ price;
            } else if(dealUnitPriceCostRec.Type__c == 'Dealer') {
                description += '-Dealer Option Price' + dealUnitPriceCostRec.Qty__c + '@$'+ price;
            }
            miscSales.put('Description__c', description + ((dealUnitPriceCostRec.Qty__c < 0) ? ' RETURN' : ''));
            
            miscSales.put('Tax_Code__c', (dealUnitPriceCostRec.Applicable_Tax__c != null) ? 
                                                dealUnitPriceCostRec.Applicable_Tax__r.Name__c : 'N-T');        
        } else if(optionAndFeeRec != null) {
            Decimal price = (optionAndFeeRec.Price__c != null) ? optionAndFeeRec.Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            if(isTaxIncludingPricing) {
                Decimal taxAmount = getTaxAmountWhenTaxIncluded(optionAndFeeRec.Id);
                miscSales.put('Tax_Amount__c', String.valueOf(taxAmount));
                if(optionAndFeeRec.Price_When_Tax_Included__c != null) {
                    price = optionAndFeeRec.Price_When_Tax_Included__c - (taxAmount / optionAndFeeRec.Qty__c);
            	}
            }
            miscSales.put('Amount__c',  ((price < 0) ? '-': '') + '$' + ((price < 0) ? 
                                    (price * -1 * optionAndFeeRec.Qty__c).setScale(2, RoundingMode.HALF_UP) : (price * optionAndFeeRec.Qty__c).setScale(2, RoundingMode.HALF_UP)));     
            
            miscSales.put('Description__c', optionAndFeeRec.Item_Code__c + '-' + optionAndFeeRec.Item_Description__c + ' ' + 
                                                                            optionAndFeeRec.Qty__c + '@$'+ price + 
                                                                            ((optionAndFeeRec.Qty__c < 0) ? ' RETURN' : ''));
            if(optionAndFeeRec.Part__c != null) {
                miscSales.put('Tax_Code__c', (optionAndFeeRec.Part__r.Applicable_Tax__c != null) ? 
                                                                                optionAndFeeRec.Part__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(optionAndFeeRec.Labour_Code__c != null) {
                miscSales.put('Tax_Code__c', (optionAndFeeRec.Labour_Code__r.Applicable_Tax__c != null) ? 
                                                                                optionAndFeeRec.Labour_Code__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(optionAndFeeRec.Fee__c != null) {
                miscSales.put('Account_No__c', (optionAndFeeRec.Fee__r.Category__c != null && 
                            optionAndFeeRec.Fee__r.Category__r.Income_GL__c != null) ? optionAndFeeRec.Fee__r.Category__r.Income_GL__c : 
                                    entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL'));
                            
                miscSales.put('Tax_Code__c', (optionAndFeeRec.Fee__r.Applicable_Tax__c != null) ? 
                                                                                optionAndFeeRec.Fee__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(optionAndFeeRec.Product__c != null) {
                miscSales.put('Account_No__c', (optionAndFeeRec.Product__r.Category__c != null && 
                            optionAndFeeRec.Product__r.Category__r.Income_GL__c != null) ? optionAndFeeRec.Product__r.Category__r.Income_GL__c : 
                                        entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('Income GL'));
                            
                miscSales.put('Tax_Code__c', (optionAndFeeRec.Product__r.Applicable_Tax__c != null) ? 
                                                                                optionAndFeeRec.Product__r.Applicable_Tax__r.Name__c : 'N-T');
            }
                                                        
        } else if(dealItemRec != null) {
            dealItemRec.Agreed_Value__c = (dealItemRec.Agreed_Value__c != null) ? dealItemRec.Agreed_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
            dealItemRec.Actual_Cash_Value__c = (dealItemRec.Actual_Cash_Value__c != null) ? dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
            if(isTaxIncludingPricing && dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
                Decimal taxAmount = getTaxAmountWhenTaxIncluded(dealItemRec.Id);
                String taxAmountValue = ((taxAmount > 0) ? '-': '') + '$' + String.valueOf((taxAmount).setScale(2, RoundingMode.HALF_UP));
                miscSales.put('Tax_Amount__c', taxAmountValue);
                
                //dealItemRec.Agreed_Value__c = dealItemRec.Agreed_Value__c - taxAmount;
            }
            //String amount = ((dealItemRec.Agreed_Value__c > 0) ? '-': '') + '$' + (dealItemRec.Agreed_Value__c).setScale(2, RoundingMode.HALF_UP);
            String amount = ((dealItemRec.Actual_Cash_Value__c > 0) ? '-$' + dealItemRec.Actual_Cash_Value__c : '$' + (-1 * dealItemRec.Actual_Cash_Value__c));
            if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN && (dealItemRec.Is_Stocked_In__c != null && dealItemRec.Is_Stocked_In__c)) {
                if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Category__c> defaultStockedTradeCategoryList = [SELECT Income_GL__c FROM Category__c WHERE Type__c = 'Stocked Trade' AND Default__c = true AND Active__c = true];
                miscSales.put('Account_No__c', defaultStockedTradeCategoryList.size() > 0 ? defaultStockedTradeCategoryList[0].Income_GL__c : '');
            } else {
                if(dealItemRec.Customer_Owned_Unit__r.Category__r.Income_Gl__c != null) {
                    miscSales.put('Account_No__c', dealItemRec.Customer_Owned_Unit__r.Category__r.Income_Gl__c);
                } else {
                    miscSales.put('Account_No__c', entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL'));
                }
            }
            miscSales.put('Description__c', ('Trade In-' + DataExportUtil.getUnitDescription(dealItemRec) + '-Trade Value ' + amount));
            miscSales.put('Amount__c',  amount);        
            miscSales.put('Tax_Code__c', defaultUnitTaxName);
            
            if(isLienPayoutLine) {
                String vinNumber = (dealItemRec.Customer_Owned_Unit__c != null) ? dealItemRec.Customer_Owned_Unit__r.VIN_Number__c : '';
                miscSales.put('Description__c', ('Lien payout: ' + vinNumber + ' ' + dealItemRec.Finance_Company__r.Name));
                miscSales.put('Amount__c', ((dealItemRec.Lien_Payout__c < 0) ? '-': '') + '$' + (dealItemRec.Lien_Payout__c).setScale(2, RoundingMode.HALF_UP));
                miscSales.put('Tax_Code__c', 'N-T');
                miscSales.put('Account_No__c', entityNameToDefaultAccTypeToAccNumberMap.get('Lien Payout').get('Income GL'));
                miscSales.put('Tax_Amount__c', '0');
            }
            
        } else if(cokliRec != null) {
            Decimal price = (cokliRec.Price__c != null) ? cokliRec.Price__c.setScale(2, RoundingMode.HALF_UP) : 0;
            if(isTaxIncludingPricing && String.isBlank(cokliRec.CO_Kit_Header__r.Deal__c)) {
                Decimal taxAmount = getTaxAmountWhenTaxIncluded(cokliRec.Id);
                miscSales.put('Tax_Amount__c', String.valueOf(taxAmount));
                if(cokliRec.Price_When_Tax_Included__c != null) {
                    price = cokliRec.Price_When_Tax_Included__c - (taxAmount / cokliRec.Qty__c);
                }
            }
            miscSales.put('Amount__c',  ((price < 0) ? '-': '') + '$' + ((price < 0) ? 
                                    (price * -1 * cokliRec.Qty__c).setScale(2, RoundingMode.HALF_UP) : (price * cokliRec.Qty__c).setScale(2, RoundingMode.HALF_UP)));
                                    
            price = (price != null) ? price.setScale(2, RoundingMode.HALF_UP) : 0;
        
            if(cokliRec.Part__c != null) {
                miscSales.put('Description__c', cokliRec.Part__r.Part_Number__c + '-' + cokliRec.Part__r.Description__c + ' ' + 
                                                                            cokliRec.Qty__c + '@$'+ price + 
                                                                            ((cokliRec.Qty__c < 0) ? ' RETURN' : ''));
                
                miscSales.put('Account_No__c', (cokliRec.Part__r.Category__c != null && 
                        cokliRec.Part__r.Category__r.Income_GL__c != null) ? cokliRec.Part__r.Category__r.Income_GL__c : 
                                entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Income GL'));
                
                miscSales.put('Tax_Code__c', (cokliRec.Part__r.Applicable_Tax__c != null) ? 
                                                cokliRec.Part__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(cokliRec.Fee__c != null) {
                miscSales.put('Description__c', cokliRec.Fee__r.Code__c + '-' + cokliRec.Fee__r.Description__c + ' ' + 
                                                                            cokliRec.Qty__c + '@$'+price + 
                                                                            ((cokliRec.Qty__c < 0) ? ' RETURN' : ''));
                
                miscSales.put('Account_No__c', (cokliRec.Fee__r.Category__c != null && 
                        cokliRec.Fee__r.Category__r.Income_GL__c != null) ? cokliRec.Fee__r.Category__r.Income_GL__c : 
                                entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL'));
                
                miscSales.put('Tax_Code__c', (cokliRec.Fee__r.Applicable_Tax__c != null) ? 
                                                cokliRec.Fee__r.Applicable_Tax__r.Name__c : 'N-T');     
            }
            
        } else if(coInvoiceItem.CO_Line_Item__c != null) {
            Decimal price = (coInvoiceItem.CO_Line_Item__r.Price__c != null) ? coInvoiceItem.CO_Line_Item__r.Price__c.setScale(2, RoundingMode.HALF_UP) : 0;
            if(isTaxIncludingPricing && String.isBlank(coInvoiceItem.CO_Line_Item__r.Deal__c)) {
                Decimal taxAmount = getTaxAmountWhenTaxIncluded(coInvoiceItem.CO_Line_Item__c);
                miscSales.put('Tax_Amount__c', String.valueOf(taxAmount));
                if(coInvoiceItem.CO_Line_Item__r.Price_When_Tax_Included__c != null) {
                    price = coInvoiceItem.CO_Line_Item__r.Price_When_Tax_Included__c - (taxAmount / coInvoiceItem.CO_Line_Item__r.Qty__c);
            }
            }
            miscSales.put('Amount__c',  ((price < 0) ? '-': '') + '$' + ((price < 0) ? 
                                    (price * -1 * coInvoiceItem.CO_Line_Item__r.Qty__c).setScale(2, RoundingMode.HALF_UP) : (price * coInvoiceItem.CO_Line_Item__r.Qty__c).setScale(2, RoundingMode.HALF_UP)));
                                    
            price = (price != null) ? price.setScale(2, RoundingMode.HALF_UP) : 0;
        
            if(coInvoiceItem.CO_Line_Item__r.Part__c != null) {
                miscSales.put('Description__c', coInvoiceItem.CO_Line_Item__r.Part__r.Part_Number__c + '-' + coInvoiceItem.CO_Line_Item__r.Part__r.Description__c + ' ' + 
                                                                            coInvoiceItem.CO_Line_Item__r.Qty__c + '@$'+price + 
                                                                            ((coInvoiceItem.CO_Line_Item__r.Qty__c < 0) ? ' RETURN' : ''));
                
                miscSales.put('Account_No__c', (coInvoiceItem.CO_Line_Item__r.Part__r.Category__c != null && 
                        coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.Income_GL__c != null) ? coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.Income_GL__c : 
                                entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Income GL'));
                
                miscSales.put('Tax_Code__c', (coInvoiceItem.CO_Line_Item__r.Part__r.Applicable_Tax__c != null) ? 
                                                coInvoiceItem.CO_Line_Item__r.Part__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(coInvoiceItem.CO_Line_Item__r.Fee__c != null) {
                miscSales.put('Description__c', coInvoiceItem.CO_Line_Item__r.Fee__r.Code__c + '-' + coInvoiceItem.CO_Line_Item__r.Fee__r.Description__c + ' ' + 
                                                                            coInvoiceItem.CO_Line_Item__r.Qty__c + '@$'+price + 
                                                                            ((coInvoiceItem.CO_Line_Item__r.Qty__c < 0) ? ' RETURN' : ''));
                
                miscSales.put('Account_No__c', (coInvoiceItem.CO_Line_Item__r.Fee__r.Category__c != null && 
                        coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.Income_GL__c != null) ? coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.Income_GL__c : 
                                entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL'));
                
                miscSales.put('Tax_Code__c', (coInvoiceItem.CO_Line_Item__r.Fee__r.Applicable_Tax__c != null) ? 
                                                coInvoiceItem.CO_Line_Item__r.Fee__r.Applicable_Tax__r.Name__c : 'N-T');        
            }
            
        }
        return miscSales;
    }
    
    /**
     * Name: createInvoicePaymentSFFieldToAccountingFieldsMap
     * Desc: Method to create a map of Invoice Payment Salesforce fields to Accounting field map so as to map in generated TXT file
     * @param: 
     * @return: Map<String, String>
    **/
    private static Map<String, String> createInvoicePaymentSFFieldToAccountingFieldsMap() {
        Map<String, String> invoicePaymentSFFieldToAccountingFieldsMap = new Map<String, String>{'Last_Name__c'         =>  'Co./Last Name',
                                                                                                 'First_Name__c'        =>  'First Name',
                                                                                                 'Account_No__c'        =>  'Deposit Account No.',
                                                                                                 'Id_No__c'             =>  'ID No.',
                                                                                                 'Date__c'              =>  'Receipt Date',
                                                                                                 'Invoice_No__c'        =>  'Invoice No.',
                                                                                                 'Amount__c'            =>  'Amount Applied',
                                                                                                 'Memo__c'              =>  'Memo',
                                                                                                 'Card_ID__c'           =>  'Card ID'
                                                                                                };
        
        return invoicePaymentSFFieldToAccountingFieldsMap;
    }
    
    /**
     * Name: createInvoicePaymentRecordFromInvoiceItem
     * Desc: Method to create a Invoice Payment record by cocoInvoiceItem record. Invoice Payment record is a map of field name to equivalent value for field
     * @param: CO_Invoice_Item__c coInvoiceItem, Map<String, String> GLAccTypeToGLAccNumberMap
     * @return: Map<String, String>
    **/
    private static Map<String, String> createInvoicePaymentRecordFromInvoiceItem(CO_Invoice_Item__c coInvoiceItem, 
                                                                                 decimal amount
                                                                                ) {
        Map<String, String> invoicePaymentRecord = new Map<String, String>{ 'Account_No__c'     =>  Accounting_Default_Accounts__c.getOrgDefaults().Customer_Deposits__c,
                                                                    'Id_No__c'          =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                    'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                    'Invoice_No__c'     =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                    'Amount__c'         =>  ((amount < 0) ? '-': '') + '$' + ((amount < 0) ? (amount * -1).setScale(2, RoundingMode.HALF_UP) : amount.setScale(2, RoundingMode.HALF_UP)),
                                                                    'Memo__c'           =>  coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c + ';Payment'
                                                                };
        if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual'){
                invoicePaymentRecord.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                invoicePaymentRecord.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
            } else {
                invoicePaymentRecord.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
            }
            invoicePaymentRecord.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
        } else {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Cash Sale') {
                invoicePaymentRecord.put('Last_Name__c', 'CASH SALE');
                invoicePaymentRecord.put('Card_ID__c', cashCustomerId);
            } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service') {
                invoicePaymentRecord.put('Last_Name__c', 'UNIT INVENTORY');
                invoicePaymentRecord.put('Card_ID__c', internalServiceCustomerId);
            }
        }
        return invoicePaymentRecord;
    }
    
    private Decimal getTaxAmountWhenTaxIncluded(Id childLineItemId) {
        Decimal taxAmount = 0;
        if(childLineItemIdToIndividualTaxRecListMap.containsKey(childLineItemId)) {
            for(Individual_Tax__c indiTaxRec : childLineItemIdToIndividualTaxRecListMap.get(childLineItemId)) {
                taxAmount += (indiTaxRec.Tax_Amount__c != null ? indiTaxRec.Tax_Amount__c : 0);
            }
        }
        return taxAmount;
    }
    
    /**
     * Name: createGLSFFieldToAccountingFieldsMap
     * Desc: Method to create a map of Inventory GL Salesforce fields to Accounting field map so as to map in generated TXT file
     * @param: 
     * @return: Map<String, String>
    **/
    private static Map<String, String> createGLSFFieldToAccountingFieldsMap() {
        Map<String, String> GLSFFieldToAccountingFieldsMap = new Map<String, String>{'Journal_Number__c'    =>  'Journal Number',
                                                                                              'Date__c'             =>  'Date',
                                                                                              'Memo__c'             =>  'Memo',
                                                                                              'Reporting__c'        =>  'GST (BAS) Reporting',
                                                                                              'Inclusive__c'        =>  'Inclusive',
                                                                                              'Account_No__c'       =>  'Account Number',
                                                                                              'Amount__c'           =>  'Amount',
                                                                                              'Is_Credit__c'        =>  'Is Credit',
                                                                                              'Tax_Code__c'         =>  'Tax Code',
                                                                                              'Allocation_Memo__c'  =>  'Allocation Memo'
                                                                                            };
        
        return GLSFFieldToAccountingFieldsMap;
    }
    
    private Map<String, String> createJEForStockedInTradeUnit(Deal_Item__c dealItemRec, Boolean isInventoryLine) {
        Map<String, String> inventoryGLRecord = new Map<String, String>{'Journal_Number__c' =>  (dealItemRec.Deal__r.CO_Header__r.Name).replace('CO-', ''),
                                                                        'Date__c'           =>  (dealItemRec.Stocked_In_Unit__r.CreatedDate != null) ?
                                                                                        dealItemRec.Stocked_In_Unit__r.CreatedDate.format(DataExportService.dateFormat) :
                                                                                        dealItemRec.CreatedDate.format(DataExportService.dateFormat),
                                                                        'Memo__c'   =>  dealItemRec.Deal__r.CO_Header__r.Customer_Name__c
                                                                                        + ';' + dealItemRec.Deal__r.CO_Header__r.Name + ';Stocked Trade In',
                                                                        'Reporting__c'      =>  'S',
                                                                        'Inclusive__c'      =>  'X'
                                                                    };
        String accountNumber = '';
        if(isInventoryLine) {
            inventoryGLRecord.put('Is_Credit__c', 'N');
            if(dealItemRec.Stocked_In_Unit__r.Category__r.Inventory_GL__c != null) { 
                accountNumber = dealItemRec.Stocked_In_Unit__r.Category__r.Inventory_GL__c;
            } else {
                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
            }
        } else {
            inventoryGLRecord.put('Is_Credit__c', 'Y');
            if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            List<Category__c> defaultStockedTradeCategoryList = [SELECT Income_GL__c FROM Category__c WHERE Type__c = 'Stocked Trade' AND Default__c = true AND Active__c = true];
            accountNumber = defaultStockedTradeCategoryList.size() > 0 ? defaultStockedTradeCategoryList[0].Income_GL__c : '';
        }
        dealItemRec.Actual_Cash_Value__c = dealItemRec.Actual_Cash_Value__c != null ? dealItemRec.Actual_Cash_Value__c.setScale(2, RoundingMode.HALF_UP) : 0;
        if(dealItemRec.Actual_Cash_Value__c == 0) {
            return null;
        }
        inventoryGLRecord.put('Allocation_Memo__c', ('Trade In-' + DataExportUtil.getUnitDescription(dealItemRec) + '-Trade Value @$' + dealItemRec.Actual_Cash_Value__c));
        //inventoryGLRecord.put('Tax_Code__c', '');
        inventoryGLRecord.put('Account_No__c', accountNumber);
        inventoryGLRecord.put('Amount__c',  '$' + dealItemRec.Actual_Cash_Value__c);
        return inventoryGLRecord;
    }
    
    /**
     * Name: createGLRecordFromInvoiceItem
     * Desc: Method to create a Inventory GL record by cocoInvoiceItem record - Bill To Internal Claim Variance Line Items
     * @param: CO_Invoice_Item__c coInvoiceItem, Service_Order_Line_Item__c soLineItemRec, Claim_Line_Item__c billToInternalClaimLI, Boolean isCredit
     * @return: Map<String, String>
    **/
    private Map<String, String> createGLRecordFromInvoiceItem(CO_Invoice_Item__c coInvoiceItem, Service_Order_Line_Item__c soLineItemRec, 
    															Claim_Line_Item__c billToInternalClaimLI, Boolean isCredit) {
    	String memo = coInvoiceItem.Service_Order_Header__r.Provider__r.Name + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';Claim Variance';
    	String itemCode = (soLineItemRec.Item_Code__c != null) ? soLineItemRec.Item_Code__c : '';
		String itemDescription = (soLineItemRec.Item_Description__c != null) ? soLineItemRec.Item_Description__c : '';
		
    	String varianceLIMemo = coInvoiceItem.Service_Order_Header__r.Provider__r.Name + ';' 
    			+ coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';Claim Variance;' + (itemCode + ' - ' + itemDescription);
    	
    	String accountNumber = '';
    	if(isCredit) {
    		if(soLineItemRec.Part__c != null) {
				if(soLineItemRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c != null) {
					accountNumber = soLineItemRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c;
				} else if(soLineItemRec.Part__r.Category__c != null && soLineItemRec.Part__r.Category__r.Income_GL__c != null) {
					accountNumber = soLineItemRec.Part__r.Category__r.Income_GL__c;
				} else {
					accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Income GL');
				}
			} else if(soLineItemRec.Fee__c != null) {
				if(soLineItemRec.Fee__r.Category__c != null && soLineItemRec.Fee__r.Category__r.Income_GL__c != null) {
					accountNumber = soLineItemRec.Fee__r.Category__r.Income_GL__c;
				} else {
					accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL');
				}
			} else if(soLineItemRec.Labour_Code__c != null) {
				if(soLineItemRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c != null) {
					accountNumber = soLineItemRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c;
				} else if(soLineItemRec.Labour_Code__r.Category__c != null && soLineItemRec.Labour_Code__r.Category__r.Income_GL__c != null) {
					accountNumber = soLineItemRec.Labour_Code__r.Category__r.Income_GL__c;
				} else {
					accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Labour').get('Income GL');
				}
			} else if(soLineItemRec.Sublet__c != null) {
				if(soLineItemRec.Sublet__r.Category__c != null && soLineItemRec.Sublet__r.Category__r.Income_GL__c != null) {
					accountNumber = soLineItemRec.Sublet__r.Category__r.Income_GL__c;
				} else {
					accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('Income GL');
				}
			}
    	} else {
    		accountNumber = billToInternalClaimLI.Category__r.Income_GL__c;
    	}
			
    	Map<String, String> inventoryGLRecord = new Map<String, String>{'Journal_Number__c'	=>	(coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
											'Date__c'			=>	coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
											'Memo__c'	=>	memo,
											'Reporting__c'		=>	'S',
											'Inclusive__c'		=>	'X',
											'Account_No__c'     =>   accountNumber,
											'Amount__c'         =>   '$' + (billToInternalClaimLI.Total_Variance_Amount__c != null ? billToInternalClaimLI.Total_Variance_Amount__c : 0).setScale(2, RoundingMode.HALF_UP),
											'Is_Credit__c'      =>   isCredit ? 'Y' : 'N',
											'Tax_Code__c'       =>   'N-T',
											 'Allocation_Memo__c'=>  varianceLIMemo
										};
                
    	return inventoryGLRecord;
    }
    
    /**
     * Name: createGLRecordFromInvoiceItem
     * Desc: Method to create a Inventory GL record by cocoInvoiceItem record. Invoice Payment record is a map of field name to equivalent value for field
     * @param: CO_Invoice_Item__c coInvoiceItem
     * @return: Map<String, String>
    **/
    private Map<String, String> createGLRecordFromInvoiceItem(CO_Invoice_Item__c coInvoiceItem, CO_Line_Item__c cokliRec, Service_Order_Line_Item__c soliRec, 
                                                Unit_Price_Cost__c unitPriceCostRec, Option_Fee__c optionAndFeeRec, Deal_Item__c dealItemRec, F_I_Product__c fAndIProductRec, Boolean isSales, Boolean isInventoryLine) {
        Map<String, String> inventoryGLRecord = new Map<String, String>{'Journal_Number__c' =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                        'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
    																	'Memo__c'	=>	(coInvoiceItem.Service_Order_Header__r.Job_Type__c == 'Third-Party') ? 
    																	coInvoiceItem.Service_Order_Header__r.Provider__r.Name
    																					+ ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';Costing' : 
    																	coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c
                                                                                        + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';Costing',
                                                                        'Reporting__c'      =>  'S',
                                                                        'Inclusive__c'      =>  'X'
                                                                    };
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        String accountNumber = '';
        
        if(dealItemRec != null) {
            String memo = coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + 
                                                coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name;
            memo += (dealItemRec.Customer_Owned_Unit__c != null) ? ';'+ dealItemRec.Customer_Owned_Unit__r.Stock_Id__c : '';
            memo += (isSales ? ((coInvoiceItem.CO_Line_Item__c != null) ? ';Deal Merch' : (coInvoiceItem.Service_Order_Header__c != null) ? 
                                                                            ';Deal Service' : '') : ';Costing');
            inventoryGLRecord.put('Memo__c', memo);
        }
        
        Decimal cost = 0;
        if(soliRec != null) {
            if((coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Internal' ||
                                    coInvoiceItem.CO_Invoice_Header__r.Checkout_Type__c == 'Third-Party') && isSales && !isInventoryLine) {
                String memo = coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c
                                                                                            + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';Internal Service';
                inventoryGLRecord.put('Memo__c', memo);
            }
            if(soliRec.Part__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                         if(soliRec.Service_Order_Header__r.Deal__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__r.CreatedDate < soliRec.Service_Order_Header__r.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                         } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                            accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            }
                        }
                    } else {
                        if(soliRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c != null) {
                            accountNumber = soliRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c;
                        } else if(soliRec.Part__r.Category__c != null && soliRec.Part__r.Category__r.Income_GL__c != null) {
                            accountNumber = soliRec.Part__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Income GL');
                        }
                    }
                    if(soliRec.Kit_Price__c == 0) {
                        return null;
                    }
                    cost = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c.setScale(2, RoundingMode.HALF_UP) : 0;
                } else {
                    if(isInventoryLine) {
                        if(soliRec.Part__r.Category__c != null && soliRec.Part__r.Category__r.Inventory_GL__c != null) {
                        accountNumber = soliRec.Part__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Inventory GL');
                    }
                    } else {
                        if(soliRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.COGS_GL__c != null) {
                            accountNumber = soliRec.Service_Order_Header__r.Transaction_Type__r.Part_Category__r.COGS_GL__c;
                        } else if(soliRec.Part__r.Category__c != null && soliRec.Part__r.Category__r.COGS_GL__c != null) {
                            accountNumber = soliRec.Part__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('COGS GL');
                        }
                    }
                    
                    for(CO_Line_Item__c coliRec : soliRec.CO_Line_Items__r) {
                        if(coliRec.Adjusted_Cost_Coli__c == null || coliRec.Adjusted_Cost_Coli__c == 0) {
                            cost += (coliRec.Avg_Cost__c != null) ? coliRec.Avg_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0;
                        } else {
                            cost += (coliRec.Adjusted_Cost_Coli__c / soliRec.Qty_Needed__c).setScale(2, RoundingMode.HALF_UP);
                        }
                        
                    }
                }
                
                inventoryGLRecord.put('Allocation_Memo__c', soliRec.Part__r.Part_Number__c + '-' + 
                                                                    soliRec.Part__r.Description__c + ' ' + 
                                                                            soliRec.Qty_Needed__c + '@$' + cost + 
                                                                            ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
                //inventoryGLRecord.put('Tax_Code__c', (soliRec.Part__r.Applicable_Tax__c != null) ? soliRec.Part__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(soliRec.Fee__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                        if(soliRec.Service_Order_Header__r.Deal__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__r.CreatedDate < soliRec.Service_Order_Header__r.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                         } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                              accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            }
                        }
                    } else {
                        if(soliRec.Fee__r.Category__c != null && soliRec.Fee__r.Category__r.Income_GL__c != null) {
                            accountNumber = soliRec.Fee__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL');
                    }
                    }
                    if(soliRec.Kit_Price__c == 0) {
                        return null;
                    }
                    cost = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
                } else {
                    if(isInventoryLine) {
                        if(soliRec.Fee__r.Category__c != null && soliRec.Fee__r.Category__r.Inventory_GL__c != null) {
                            accountNumber = soliRec.Fee__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Inventory GL');
                        }
                    } else {
                        if(soliRec.Fee__r.Category__c != null && soliRec.Fee__r.Category__r.COGS_GL__c != null) {
                            accountNumber = soliRec.Fee__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('COGS GL');
                        }
                    }
                    
                    if(soliRec.Fee__r.Cost_Method__c == 'Fixed Cost' && soliRec.Fee__r.Cost_Rate__c !=null && soliRec.Qty_Needed__c != null) {
                        cost += soliRec.Fee__r.Cost_Rate__c.setScale(2, RoundingMode.HALF_UP);
                    } else if(soliRec.Fee__r.Cost_Method__c == 'Percent Retail'  && soliRec.Fee__r.Cost_Rate__c !=null &&  soliRec.Qty_Needed__c !=null ){
                        cost += ((soliRec.Kit_Price__c *  soliRec.Fee__r.Cost_Rate__c)/100).setScale(2, RoundingMode.HALF_UP);
                    }
                    
                }
                cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
                inventoryGLRecord.put('Allocation_Memo__c', soliRec.Fee__r.Code__c + '-' +  soliRec.Fee__r.Description__c + ' ' + 
                                                                            soliRec.Qty_Needed__c + '@$' + cost + 
                                                                            ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
                                                                            
                //inventoryGLRecord.put('Tax_Code__c', (soliRec.Fee__r.Applicable_Tax__c != null) ? soliRec.Fee__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(soliRec.Labour_Code__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                        if(soliRec.Service_Order_Header__r.Deal__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__r.CreatedDate < soliRec.Service_Order_Header__r.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                         } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                            accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            }
                        }
                    } else {
                        if(soliRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c != null) {
                            accountNumber = soliRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c;
                        } else if(soliRec.Labour_Code__r.Category__c != null && soliRec.Labour_Code__r.Category__r.Income_GL__c != null) {
                            accountNumber = soliRec.Labour_Code__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Labour').get('Income GL');
                        }
                    }
                    if(soliRec.Kit_Price__c == 0) {
                        return null;
                    }
                    cost = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
                } else {
                    if(isInventoryLine) {
                        if(soliRec.Labour_Code__r.Category__c != null && soliRec.Labour_Code__r.Category__r.Inventory_GL__c != null) {
                            accountNumber = soliRec.Labour_Code__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Labour').get('Inventory GL');
                        }
                    } else {
                        if(soliRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.COGS_GL__c != null) {
                            accountNumber = soliRec.Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.COGS_GL__c;
                        } else if(soliRec.Labour_Code__r.Category__c != null && soliRec.Labour_Code__r.Category__r.COGS_GL__c != null) {
                            accountNumber = soliRec.Labour_Code__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Labour').get('COGS GL');
                        }
                    }
                    
                    if(soliRec.Labour_Code__r.Cost_Method__c == 'Fixed Cost' && soliRec.Labour_Code__r.Cost_Rate__c != null && soliRec.Qty_Needed__c !=null){
                        cost = (soliRec.Labour_Code__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(soliRec.Labour_Code__r.Cost_Method__c == 'Percent Retail' && soliRec.Labour_Code__r.Cost_Rate__c !=null && soliRec.Qty_Needed__c !=null ){
                        cost = ((soliRec.Kit_Price__c *  soliRec.Labour_Code__r.Cost_Rate__c)/100).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
                inventoryGLRecord.put('Allocation_Memo__c', soliRec.Labour_Code__r.Code__c + '-' + soliRec.Labour_Code__r.Description__c + ' ' + 
                                                                            soliRec.Qty_Needed__c + '@$' + cost + 
                                                                            ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));
                                                                            
                //inventoryGLRecord.put('Tax_Code__c', (soliRec.Labour_Code__r.Applicable_Tax__c != null) ? soliRec.Labour_Code__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(soliRec.Sublet__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                        if(soliRec.Service_Order_Header__r.Deal__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Invoice_Number__c != null && soliRec.Service_Order_Header__r.Deal__r.Invoice_Number__r.CreatedDate < soliRec.Service_Order_Header__r.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                         } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                                 accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            }
                        }
                    } else {
                        if(soliRec.Sublet__r.Category__c != null && soliRec.Sublet__r.Category__r.Income_GL__c != null) {
                            accountNumber = soliRec.Sublet__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('Income GL');
                    }
                    }
                    if(soliRec.Kit_Price__c == 0) {
                        return null;
                    }
                    cost = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c : 0;
                } else {
                    if(isInventoryLine) {
                        if(soliRec.Sublet__r.Category__c != null && soliRec.Sublet__r.Category__r.Inventory_GL__c != null) {
                        accountNumber = soliRec.Sublet__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('Inventory GL');
                    }
                    } else {
                        if(soliRec.Sublet__r.Category__c != null && soliRec.Sublet__r.Category__r.COGS_GL__c != null) {
                            accountNumber = soliRec.Sublet__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('COGS GL');
                        }
                    }
                    if(soliRec.Cost__c != null) {
                        cost = (soliRec.Cost__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(soliRec.Sublet__r.Cost_Method__c == 'Fixed Cost' && soliRec.Sublet__r.Cost__c != null && soliRec.Qty_Needed__c !=null){
                        cost = (soliRec.Sublet__r.Cost__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(soliRec.Sublet__r.Cost_Method__c == 'Percent Retail' && soliRec.Sublet__r.Cost__c !=null && soliRec.Qty_Needed__c !=null ){
                        cost = ((soliRec.Kit_Price__c *  soliRec.Sublet__r.Cost__c)/100).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
                String subletDesc = (soliRec.Item_Code__c != null) ? soliRec.Item_Code__c : '';
				subletDesc += (soliRec.Item_Description__c != null) ? ((subletDesc.length() > 0 ? ' - ' : '' ) + soliRec.Item_Description__c) : '';
				inventoryGLRecord.put('Allocation_Memo__c', subletDesc + ' ' + 
                                                                            soliRec.Qty_Needed__c + '@$' + cost + 
                                                                            ((soliRec.Qty_Needed__c < 0) ? ' RETURN' : ''));                                                                            
            }
            Decimal amount = ((soliRec.Qty_Needed__c * cost) < 0 ? -1 * (soliRec.Qty_Needed__c * cost) : (soliRec.Qty_Needed__c * cost));
            inventoryGLRecord.put('Amount__c',  '$' + amount.setScale(2, RoundingMode.HALF_UP));
            if(isSales) {
                inventoryGLRecord.put('Is_Credit__c',(isInventoryLine ? ((soliRec.Qty_Needed__c > 0) ? 'N' : 'Y') : ((soliRec.Qty_Needed__c > 0) ? 'Y' : 'N')));
            } else {
                inventoryGLRecord.put('Is_Credit__c',(isInventoryLine ? ((soliRec.Qty_Needed__c > 0) ? 'Y' : 'N') : ((soliRec.Qty_Needed__c > 0) ? 'N' : 'Y')));
            }
        }  else if(unitPriceCostRec != null) {
            if(isInventoryLine) {
                if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                } else {
                    accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                }
            } else {
                if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.COGS_GL__c != null) {
                accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.COGS_GL__c;
                } else {
                    accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('COGS GL');
                }
            }
                
            Decimal qty = (unitPriceCostRec.Qty__c != null && unitPriceCostRec.Qty__c != 0) ? unitPriceCostRec.Qty__c : 1.00;
            cost = (unitPriceCostRec.Total_Cost__c != null) ? (unitPriceCostRec.Total_Cost__c / qty).setScale(2, RoundingMode.HALF_UP) : 0;
            
            if(unitPriceCostRec.Type__c == 'Base') {
                inventoryGLRecord.put('Allocation_Memo__c', DataExportUtil.getUnitDescription(dealItemRec) + '- Base Cost ' + qty + '@$'+ cost);
            } else if(unitPriceCostRec.Type__c == 'Factory') {
                //inventoryGLRecord.put('Allocation_Memo__c', dealUnitPriceCostRec.Item_Description__c + ' ' + qty + '@$'+ cost);
                inventoryGLRecord.put('Allocation_Memo__c', DataExportUtil.getUnitDescription(dealItemRec) + '- Factory Cost ' + qty + '@$'+ cost);
            } else if(unitPriceCostRec.Type__c == 'Dealer') {
                //inventoryGLRecord.put('Allocation_Memo__c', dealUnitPriceCostRec.Item_Description__c + ' ' + qty + '@$'+ cost);
                inventoryGLRecord.put('Allocation_Memo__c', DataExportUtil.getUnitDescription(dealItemRec) + '- Dealer Option Cost ' + qty + '@$'+ cost + 
                                                                            ((qty < 0) ? ' RETURN' : ''));
            }
            //inventoryGLRecord.put('Tax_Code__c', (dealUnitPriceCostRec.Applicable_Tax__c != null) ? dealUnitPriceCostRec.Applicable_Tax__r.Name__c : 'N-T');
            Decimal amount = ((qty * cost) < 0 ? -1 * (qty * cost) : (qty * cost));
            inventoryGLRecord.put('Amount__c',  '$' + amount.setScale(2, RoundingMode.HALF_UP));          
            inventoryGLRecord.put('Is_Credit__c',(!isInventoryLine ? ((unitPriceCostRec.Qty__c > 0) ? 'N' : 'Y') : ((unitPriceCostRec.Qty__c > 0) ? 'Y' : 'N')));                                   
        } else if(fAndIProductRec != null) {
            if(isInventoryLine) {
                if(fAndIProductRec.Vendor_Product__r.Category__r.Inventory_GL__c != null) {
                    accountNumber = fAndIProductRec.Vendor_Product__r.Category__r.Inventory_GL__c;
                } else {
                    accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                }
            } else {
                if(fAndIProductRec.Vendor_Product__r.Category__r.COGS_GL__c != null) {
                    accountNumber = fAndIProductRec.Vendor_Product__r.Category__r.COGS_GL__c;
                } else {
                    accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('COGS GL');
                }
            }
                
            Decimal qty = 1.00;
            fAndIProductRec.Price__c = (fAndIProductRec.Price__c != null ? fAndIProductRec.Price__c : 0);
            Decimal perItemCost = fAndIProductRec.Vendor_Product__r.Cost__c != null ? fAndIProductRec.Vendor_Product__r.Cost__c : 0;
            if(fAndIProductRec.Vendor_Product__r.Cost_Method__c == 'Fixed Cost') {
                cost = perItemCost;
            } else if(fAndIProductRec.Vendor_Product__r.Cost_Method__c == 'Percent Retail') {
                cost = (fAndIProductRec.Price__c * perItemCost) / 100;
            }
            
            inventoryGLRecord.put('Allocation_Memo__c', fAndIProductRec.Item_Description__c + 1.00 + '@$'+ cost);
            Decimal amount = (cost < 0 ? (-1 * cost) : cost);
            inventoryGLRecord.put('Amount__c',  '$' + amount.setScale(2, RoundingMode.HALF_UP));          
            inventoryGLRecord.put('Is_Credit__c',(!isInventoryLine ? 'N' : 'Y'));                                   
        } else if(optionAndFeeRec != null) {
            if(isInventoryLine) {
            	if(dealItemRec.Deal__r.Is_Deal_Fulfilled__c) {
	                if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
	                    accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
	                } else {
	                    accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
	                }
            	} else {
            		accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
            	}
            } else {
                if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.COGS_GL__c != null) {
                    accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.COGS_GL__c;
                } else {
                    accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('COGS GL');
                }
            }
            
            if(optionAndFeeRec.Product__c != null && optionAndFeeRec.Product__r.Type__c != Constants.SUBLET) {
                Decimal perItemCost = optionAndFeeRec.Product__r.Cost__c != null ? optionAndFeeRec.Product__r.Cost__c : 0;
                if(optionAndFeeRec.Product__r.Cost_Method__c == 'Fixed Cost') {
                    cost = perItemCost;
                } else if(optionAndFeeRec.Product__r.Cost_Method__c == 'Percent Retail') {
                    //Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
                    Decimal price = (isTaxIncludingPricing ? optionAndFeeRec.Price_When_Tax_Included__c : optionAndFeeRec.Price__c);
                    cost = (price * perItemCost) / 100;
                }
            } else {
                cost = (optionAndFeeRec.Per_Item_Cost__c != null ? optionAndFeeRec.Per_Item_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0);
            }
            
            
            if(optionAndFeeRec.Deal__r.Is_Deal_Fulfilled__c) {
                cost = (optionAndFeeRec.Per_Item_Cost__c != null ? optionAndFeeRec.Per_Item_Cost__c : 0);
            } else {
                if(isTaxIncludingPricing) {
                    cost = (optionAndFeeRec.Price_When_Tax_Included__c != null ? optionAndFeeRec.Price_When_Tax_Included__c : 0);
                } else {
                    cost = (optionAndFeeRec.Price__c != null ? optionAndFeeRec.Price__c : 0);
                }
            }
            cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
            inventoryGLRecord.put('Allocation_Memo__c', optionAndFeeRec.Item_Code__c + '-' + optionAndFeeRec.Item_Description__c + ' ' + 
                                                                            optionAndFeeRec.Qty__c + '@$'+ cost + 
                                                                            ((optionAndFeeRec.Qty__c < 0) ? ' RETURN' : ''));
            if(optionAndFeeRec.Part__c != null) {
                //inventoryGLRecord.put('Tax_Code__c', (optionAndFeeRec.Part__r.Applicable_Tax__c != null) ? optionAndFeeRec.Part__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(optionAndFeeRec.Labour_Code__c != null) {
                //inventoryGLRecord.put('Tax_Code__c', (optionAndFeeRec.Labour_Code__r.Applicable_Tax__c != null) ? optionAndFeeRec.Labour_Code__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(optionAndFeeRec.Fee__c != null) {
                if(isInventoryLine) {
                    if(optionAndFeeRec.Fee__r.Category__c != null && optionAndFeeRec.Fee__r.Category__r.Inventory_GL__c != null) {
                    accountNumber = optionAndFeeRec.Fee__r.Category__r.Inventory_GL__c;
                    } else {
                        accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Inventory GL');
                    }
                } else {
                    if(optionAndFeeRec.Fee__r.Category__c != null && optionAndFeeRec.Fee__r.Category__r.COGS_GL__c != null) {
                        accountNumber = optionAndFeeRec.Fee__r.Category__r.COGS_GL__c;
                    } else {
                        accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('COGS GL');
                    }
                }
                
                //inventoryGLRecord.put('Tax_Code__c', (optionAndFeeRec.Fee__r.Applicable_Tax__c != null) ? optionAndFeeRec.Fee__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(optionAndFeeRec.Product__c != null) {
                if(isInventoryLine) {
                    if(optionAndFeeRec.Product__r.Category__c != null && optionAndFeeRec.Product__r.Category__r.Inventory_GL__c != null) {
                    accountNumber = optionAndFeeRec.Product__r.Category__r.Inventory_GL__c;
                    } else {
                        accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('Inventory GL');
                    }
                } else {
                    if(optionAndFeeRec.Product__r.Category__c != null && optionAndFeeRec.Product__r.Category__r.COGS_GL__c != null) {
                        accountNumber = optionAndFeeRec.Product__r.Category__r.COGS_GL__c;
                    } else {
                        accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Sublet').get('COGS GL');
                    }
                }
                //inventoryGLRecord.put('Tax_Code__c', (optionAndFeeRec.Product__r.Applicable_Tax__c != null) ? optionAndFeeRec.Product__r.Applicable_Tax__r.Name__c : 'N-T');
            }
            Decimal amount = ((optionAndFeeRec.Qty__c * cost) < 0 ? -1 * (optionAndFeeRec.Qty__c * cost) : 
                                                            (optionAndFeeRec.Qty__c * cost));
            inventoryGLRecord.put('Amount__c',  '$' + amount.setScale(2, RoundingMode.HALF_UP));
            inventoryGLRecord.put('Is_Credit__c',(!isInventoryLine ? ((optionAndFeeRec.Qty__c > 0) ? 'N' : 'Y') : ((optionAndFeeRec.Qty__c > 0) ? 'Y' : 'N'))); 
            //cost = optionAndFeeRec.Per_Item_Cost__c;                              
        } else if(cokliRec != null) {
            if(cokliRec.Part__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                        //add condition here for deal option clearing
                        if(cokliRec.Deal__c != null && cokliRec.Deal__r.Invoice_Number__c != null && cokliRec.Invoice_Number__c != null && cokliRec.Deal__r.Invoice_Number__r.CreatedDate < cokliRec.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                        } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                                accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            }
                        }
                    } else {
                        if(cokliRec.Part__r.Category__c != null && cokliRec.Part__r.Category__r.Income_GL__c != null) {
                            accountNumber = cokliRec.Part__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Income GL');
                        }
                    }
                    cost  = (cokliRec.Price__c != null) ? cokliRec.Price__c : 0;
                } else {
                    if(isInventoryLine) {
                        if(cokliRec.Part__r.Category__c != null && cokliRec.Part__r.Category__r.Inventory_GL__c != null) {
                        accountNumber = cokliRec.Part__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Inventory GL');
                    }
                    } else {
                        if(cokliRec.Part__r.Category__c != null && cokliRec.Part__r.Category__r.COGS_GL__c != null) {
                            accountNumber = cokliRec.Part__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('COGS GL');
                        }
                    }
                    if(cokliRec.Adjusted_Cost_Coli__c == null || cokliRec.Adjusted_Cost_Coli__c == 0) {
                        cost = (cokliRec.Avg_Cost__c != null) ? cokliRec.Avg_Cost__c : 0;
                    } else {
                        cost = (cokliRec.Adjusted_Cost_Coli__c / cokliRec.Qty__c);
                    }
                }
                cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
                inventoryGLRecord.put('Allocation_Memo__c', cokliRec.Part__r.Part_Number__c + '-' + 
                                                                    cokliRec.Part__r.Description__c + ' ' + 
                                                                            cokliRec.Qty__c + '@$' + cost + 
                                                                            ((cokliRec.Qty__c < 0) ? ' RETURN' : ''));
                
                //inventoryGLRecord.put('Tax_Code__c', (cokliRec.Part__r.Applicable_Tax__c != null) ? cokliRec.Part__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(cokliRec.Fee__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                        if(cokliRec.Deal__c != null && cokliRec.Deal__r.Invoice_Number__c != null && cokliRec.Invoice_Number__c != null && cokliRec.Deal__r.Invoice_Number__r.CreatedDate < cokliRec.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                        } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                                accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            }
                        }
                    } else {
                        if(cokliRec.Fee__r.Category__c != null && cokliRec.Fee__r.Category__r.Income_GL__c != null) {
                        accountNumber = cokliRec.Fee__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL');
                        }
                    }
                    cost  = (cokliRec.Price__c != null) ? cokliRec.Price__c : 0;
                } else {
                    if(isInventoryLine) {
                        if(cokliRec.Fee__r.Category__c != null && cokliRec.Fee__r.Category__r.Inventory_GL__c != null) {
                            accountNumber = cokliRec.Fee__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Inventory GL');
                    }
                    } else {
                        if(cokliRec.Fee__r.Category__c != null && cokliRec.Fee__r.Category__r.COGS_GL__c != null) {
                            accountNumber = cokliRec.Fee__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('COGS GL');
                        }
                    }
                    if(cokliRec.Fee__r.Cost_Method__c == 'Fixed Cost' && cokliRec.Fee__r.Cost_Rate__c != null) {
                        cost  = (cokliRec.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(cokliRec.Fee__r.Cost_Method__c == 'Percent Retail' && cokliRec.Fee__r.Cost_Rate__c != null) {
                        cost  = ((cokliRec.Price__c * cokliRec.Fee__r.Cost_Rate__c) / 100).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
                inventoryGLRecord.put('Allocation_Memo__c', cokliRec.Fee__r.Code__c + '-' + 
                                                                    cokliRec.Fee__r.Description__c + ' ' + 
                                                                            cokliRec.Qty__c + '@$' + cost + 
                                                                            ((cokliRec.Qty__c < 0) ? ' RETURN' : ''));
                                                                            
                //inventoryGLRecord.put('Tax_Code__c', (cokliRec.Fee__r.Applicable_Tax__c != null) ? cokliRec.Fee__r.Applicable_Tax__r.Name__c : 'N-T');
            }
            Decimal amount = ((cokliRec.Qty__c * cost) < 0 ? -1 * (cokliRec.Qty__c * cost) : (cokliRec.Qty__c * cost));
            inventoryGLRecord.put('Amount__c',  '$' + amount.setScale(2, RoundingMode.HALF_UP));
            if(isSales) {
                inventoryGLRecord.put('Is_Credit__c',(isInventoryLine ? ((cokliRec.Qty__c > 0) ? 'N' : 'Y') : ((cokliRec.Qty__c > 0) ? 'Y' : 'N')));
            } else {
                inventoryGLRecord.put('Is_Credit__c',(isInventoryLine ? ((cokliRec.Qty__c > 0) ? 'Y' : 'N') : ((cokliRec.Qty__c > 0) ? 'N' : 'Y')));
            }
        } else if(coInvoiceItem.CO_Line_Item__c != null) {
            if(coInvoiceItem.CO_Line_Item__r.Part__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                        if(coInvoiceItem.CO_Line_Item__r.Deal__c != null && coInvoiceItem.CO_Line_Item__r.Deal__r.Invoice_Number__c != null && coInvoiceItem.CO_Line_Item__r.Invoice_Number__c != null && coInvoiceItem.CO_Line_Item__r.Deal__r.Invoice_Number__r.CreatedDate < coInvoiceItem.CO_Line_Item__r.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                         } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                                 accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            }
                        }
                    } else {
                        if(coInvoiceItem.CO_Line_Item__r.Part__r.Category__c != null && coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.Income_GL__c != null) {
                            accountNumber = coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Income GL');
                        }
                    }
                    if(coInvoiceItem.CO_Line_Item__r.Price__c == 0 && isSales) {
                        return null;
                    }
                    cost  = (coInvoiceItem.CO_Line_Item__r.Price__c != null) ? coInvoiceItem.CO_Line_Item__r.Price__c : 0;
                } else {
                    if(isInventoryLine) {
                        if(coInvoiceItem.CO_Line_Item__r.Part__r.Category__c != null && coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.Inventory_GL__c != null) {
                        accountNumber = coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('Inventory GL');
                    }
                    } else {
                        if(coInvoiceItem.CO_Line_Item__r.Part__r.Category__c != null && coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.COGS_GL__c != null) {
                            accountNumber = coInvoiceItem.CO_Line_Item__r.Part__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Part').get('COGS GL');
                        }
                    }
                    if(coInvoiceItem.CO_Line_Item__r.Adjusted_Cost_Coli__c == null || coInvoiceItem.CO_Line_Item__r.Adjusted_Cost_Coli__c == 0) {
                        cost = (coInvoiceItem.CO_Line_Item__r.Avg_Cost__c != null) ? coInvoiceItem.CO_Line_Item__r.Avg_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0;
                    } else {
                        cost = (coInvoiceItem.CO_Line_Item__r.Adjusted_Cost_Coli__c / coInvoiceItem.CO_Line_Item__r.Qty__c).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
                inventoryGLRecord.put('Allocation_Memo__c', coInvoiceItem.CO_Line_Item__r.Part__r.Part_Number__c + '-' + 
                                                                    coInvoiceItem.CO_Line_Item__r.Part__r.Description__c + ' ' + 
                                                                            coInvoiceItem.CO_Line_Item__r.Qty__c + '@$' + cost + 
                                                                            ((coInvoiceItem.CO_Line_Item__r.Qty__c < 0) ? ' RETURN' : ''));
                
                //inventoryGLRecord.put('Tax_Code__c', (coInvoiceItem.CO_Line_Item__r.Part__r.Applicable_Tax__c != null) ? coInvoiceItem.CO_Line_Item__r.Part__r.Applicable_Tax__r.Name__c : 'N-T');
            } else if(coInvoiceItem.CO_Line_Item__r.Fee__c != null) {
                if(isSales) {
                    if(isInventoryLine) {
                        if(coInvoiceItem.CO_Line_Item__r.Deal__c != null && coInvoiceItem.CO_Line_Item__r.Deal__r.Invoice_Number__c != null && coInvoiceItem.CO_Line_Item__r.Invoice_Number__c != null && coInvoiceItem.CO_Line_Item__r.Deal__r.Invoice_Number__r.CreatedDate < coInvoiceItem.CO_Line_Item__r.Invoice_Number__r.CreatedDate ) {
                            accountNumber = AccountingUtil.getChartofAccount('Deal Option Clearing');
                         } else {
                            if(dealItemRec.Customer_Owned_Unit__r.Category__c != null && dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) {
                                accountNumber = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
                            } else {
                                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
                            } 
                        }
                    } else {
                        if(coInvoiceItem.CO_Line_Item__r.Fee__r.Category__c != null && coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.Income_GL__c != null) {
                            accountNumber = coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.Income_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Income GL');
                        }
                    }
                    cost  = (coInvoiceItem.CO_Line_Item__r.Price__c != null) ? coInvoiceItem.CO_Line_Item__r.Price__c : 0;
                } else {
                    if(isInventoryLine) {
                        if(coInvoiceItem.CO_Line_Item__r.Fee__r.Category__c != null && coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.Inventory_GL__c != null) {
                            accountNumber = coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.Inventory_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('Inventory GL');
                        }
                    } else {
                        if(coInvoiceItem.CO_Line_Item__r.Fee__r.Category__c != null && coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.COGS_GL__c != null) {
                            accountNumber = coInvoiceItem.CO_Line_Item__r.Fee__r.Category__r.COGS_GL__c;
                        } else {
                            accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Fee').get('COGS GL');
                        }
                    }
                    if(coInvoiceItem.CO_Line_Item__r.Fee__r.Cost_Method__c == 'Fixed Cost' && coInvoiceItem.CO_Line_Item__r.Fee__r.Cost_Rate__c != null) {
                        cost  = (coInvoiceItem.CO_Line_Item__r.Fee__r.Cost_Rate__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(coInvoiceItem.CO_Line_Item__r.Fee__r.Cost_Method__c == 'Percent Retail' && coInvoiceItem.CO_Line_Item__r.Fee__r.Cost_Rate__c != null) {
                        cost  = ((coInvoiceItem.CO_Line_Item__r.Price__c * coInvoiceItem.CO_Line_Item__r.Fee__r.Cost_Rate__c) / 100).setScale(2, RoundingMode.HALF_UP);
                    }
                }
                cost = (cost != null) ? cost.setScale(2, RoundingMode.HALF_UP) : 0;
                inventoryGLRecord.put('Allocation_Memo__c', coInvoiceItem.CO_Line_Item__r.Fee__r.Code__c + '-' + 
                                                                    coInvoiceItem.CO_Line_Item__r.Fee__r.Description__c + ' ' + 
                                                                            coInvoiceItem.CO_Line_Item__r.Qty__c + '@$' + cost + 
                                                                            ((coInvoiceItem.CO_Line_Item__r.Qty__c < 0) ? ' RETURN' : ''));
                                                                            
                //inventoryGLRecord.put('Tax_Code__c', (coInvoiceItem.CO_Line_Item__r.Fee__r.Applicable_Tax__c != null) ? coInvoiceItem.CO_Line_Item__r.Fee__r.Applicable_Tax__r.Name__c : 'N-T');
            }
            Decimal qty = (coInvoiceItem.CO_Line_Item__r.Qty__c != null) ? coInvoiceItem.CO_Line_Item__r.Qty__c.setScale(2, RoundingMode.HALF_UP) : 1;
            Decimal amount = ((qty * cost) < 0 ? -1 * (qty * cost) : (qty * cost));
            inventoryGLRecord.put('Amount__c',  '$' + amount.setScale(2, RoundingMode.HALF_UP));
            if(isSales) {
                inventoryGLRecord.put('Is_Credit__c',(isInventoryLine ? ((qty > 0) ? 'N' : 'Y') : ((qty > 0) ? 'Y' : 'N')));
            } else {
                inventoryGLRecord.put('Is_Credit__c',(isInventoryLine ? ((qty > 0) ? 'Y' : 'N') : ((qty > 0) ? 'N' : 'Y')));
            }   
        } else if(coInvoiceItem.Service_Order_Header__c != null && isSales && isInventoryLine) {
            if(coInvoiceItem.Service_Order_Header__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c != null) { 
                accountNumber = coInvoiceItem.Service_Order_Header__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
            } else {
                accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Unit').get('Inventory GL');
            }
            inventoryGLRecord.put('Memo__c', 'UNIT INVENTORY;' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + ';Internal Service');
            inventoryGLRecord.put('Allocation_Memo__c', 'Total Internal Service');
            //inventoryGLRecord.put('Tax_Code__c', '');
            inventoryGLRecord.put('Amount__c',  '$' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Order_Total__c.setScale(2, RoundingMode.HALF_UP));
            inventoryGLRecord.put('Is_Credit__c', 'N');
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Order_Total__c == 0) {
                return null;
            }
        }
        inventoryGLRecord.put('Tax_Code__c', 'N-T');
        inventoryGLRecord.put('Account_No__c', accountNumber);
        
        if(!isSales && cost == 0) {
            return null;
        }
        return inventoryGLRecord;
    }
    
    private Map<String, String> createJEForStockUnitTax(CO_Invoice_Item__c coInvoiceItem, Deal_Item__c dealItemRec, Decimal cost, String accType, Boolean isInventoryLine) {
        if(cost == 0) {
            return null;
        }
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> inventoryGLRecord = new Map<String, String>{'Journal_Number__c' =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                        'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                        'Memo__c'   =>  dealItemRec.Deal__r.CO_Header__r.Customer_Name__c + ';'
                                                                                            + ';' + dealItemRec.Deal__r.CO_Header__r.Name + ';Costing',
                                                                        'Reporting__c'      =>  'S',
                                                                        'Inclusive__c'      =>  'X'
                                                                        };
        String accountNumber = entityNameToDefaultAccTypeToAccNumberMap.get('Trade In').get(accType);
        inventoryGLRecord.put('Account_No__c', accountNumber);
        
        cost = (cost < 0 ? (-1 *  cost) : cost);
        inventoryGLRecord.put('Amount__c',  '$' + cost.setScale(2, RoundingMode.HALF_UP));
        inventoryGLRecord.put('Is_Credit__c', isInventoryLine ? 'Y' : 'N');
        inventoryGLRecord.put('Allocation_Memo__c', ('Trade In-' + DataExportUtil.getUnitDescription(dealItemRec) + '-Stock Unit Tax @$' + cost));
        inventoryGLRecord.put('Tax_Code__c', 'N-T');
        
        return inventoryGLRecord;
    }
    
    private Map<String, String> createMiscRecordForUnitTradeTax(CO_Invoice_Item__c coInvoiceItem, Deal_Item__c dealItemRec, Boolean isInventoryLine, Decimal amount) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        Map<String, String> miscSales = new Map<String, String>{'Invoice_No__c'     =>  (coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c).replace('INV-', ''),
                                                                'Date__c'           =>  coInvoiceItem.CO_Invoice_Header__r.Invoice_Date__c.format(DataExportService.dateFormat),
                                                                'Inclusive__c'      =>  isTaxIncludingPricing ? 'Yes' : 'No',
                                                                'Memo__c'           =>  coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer_Name__c + ';' + coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Name + 
                                                                                        ';'+coInvoiceItem.CO_Invoice_Header__r.Invoice_Number__c +';Invoice',
                                                                'Tax_Amount__c'     => '0'
                                                            };
                                                            
        if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__c != null) {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c == 'Individual') {
                miscSales.put('First_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c);
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c);
            } else {
                miscSales.put('Last_Name__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name);
            }
            miscSales.put('Card_ID__c', coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c);
        } else {
            if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Cash Sale') {
                miscSales.put('Last_Name__c', 'CASH SALE');
                miscSales.put('Card_ID__c', cashCustomerId);
            } else if(coInvoiceItem.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == 'Internal Service') {
                miscSales.put('Last_Name__c', 'UNIT INVENTORY');
                miscSales.put('Card_ID__c', internalServiceCustomerId);
            }
        }
        amount = (amount != null) ? amount.setScale(2, RoundingMode.HALF_UP) : 0;
        String amountStr = ((isInventoryLine) ? ((amount > 0) ? '-$' + amount : '$' + (-1 * amount)) : ((amount > 0) ? '$' + amount : '-$' + (-1 * amount)));
        if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
            miscSales.put('Account_No__c', (isInventoryLine) ? entityNameToDefaultAccTypeToAccNumberMap.get('Trade In').get('Trade tax pending sale') : 
                                                    entityNameToDefaultAccTypeToAccNumberMap.get('Tax').get('Income GL'));
        
            miscSales.put('Description__c', ('Trade In-' + DataExportUtil.getUnitDescription(dealItemRec) + '-Trade Tax Value ' + amountStr));
            
        } else if(dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT) {
            miscSales.put('Account_No__c', (isInventoryLine) ? entityNameToDefaultAccTypeToAccNumberMap.get('Trade In').get('Trade tax liability') : 
                entityNameToDefaultAccTypeToAccNumberMap.get('Trade In').get('Trade tax pending sale'));
            
            miscSales.put('Description__c', ('Stock Unit-' + DataExportUtil.getUnitDescription(dealItemRec) + '-Unit Tax Value ' + amountStr));
        }
        miscSales.put('Amount__c',  amountStr);
        miscSales.put('Tax_Code__c', defaultUnitTaxName);
            
        return miscSales;
    }
}