public without sharing class IntegrationBatchService {
	
	public static Map<String, Type> syncEntityNameToBatchName = new Map<String, Type>{
	               IntegrationUtility.ITEM_CATEGORY => SyncingItemCategoryBatch.class,
	               IntegrationUtility.VENDOR => SyncVendorBatch.class,
	               IntegrationUtility.CO_DEPOSIT => SyncCODepositBatch.class,
	               IntegrationUtility.CO_INVOICE_PAYMENT => SyncCOInvoicePaymentBatch.class,
	               IntegrationUtility.CUSTOMER => SyncCustomerBatch.class,
	               IntegrationUtility.PART_CATEGORY => SyncingPartCategoryBatch.class,
	               IntegrationUtility.PART_FIFO => SyncingPartFifoBucketBatch.class,
	               IntegrationUtility.PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM => SyncingPartFifoBucketActivityLIBatch.class,
	               IntegrationUtility.STORE_CREDIT => SyncStoreCreditBatch.class,
	               IntegrationUtility.UNIT_PRICE_COST => SyncUnitPriceAndCostBatch.class, 
                   IntegrationUtility.STOCK_UNIT_CATEGORY => SyncStockUnitCategoryBatch.class, 
                   IntegrationUtility.VENDOR_RECEIVING => SyncVendorReceivingBatch.class,
                   IntegrationUtility.INVOICE => SyncCOInvoiceBatch.class,
                   IntegrationUtility.STOCK_TRADE_IN => SyncStockTradeInBatch.class,
                   IntegrationUtility.CO_INVOICE_JE => SyncCOInvoiceJEBatch.class,
                   IntegrationUtility.VO_INVOICE => SyncVOInvoiceBatch.class,
                   IntegrationUtility.LIEN_PAYOUT => SyncLienPayoutBatch.class,
                   IntegrationUtility.UNIT_INVOICE => SyncUnitInvoiceBatch.class,
                   IntegrationUtility.VO_RETURN => SyncVOReturnBatch.class
	               };
	
    public static void initiateBatch(Set<Id> idSet, List<BaseIntegrationService> integrationRecList, String syncEntityType) {
        BaseSyncingBatch batchObj = (BaseSyncingBatch)syncEntityNameToBatchName.get(syncEntityType).newInstance();
        batchObj.setIdSet(idSet);
        if(integrationRecList == null) {
            integrationRecList = new List<BaseIntegrationService>();
            integrationRecList.add(IntegrationServiceFactory.getIntegrationServiceInstance('Accounting'));
        }
        batchObj.setIntegrationInstanceList(integrationRecList);
        Database.executeBatch(batchObj, 10);
    }
    
    //TODO: syncFlag to map
    public static String getBaseQuery(String objectAPIName, List<String> fieldsList, String syncFlag) {
        String baseQuery = 'SELECT '; 
        for(String fieldName : fieldsList){
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            baseQuery += fieldName + ', ';
        }
        baseQuery = baseQuery.substring(0, baseQuery.length() - 2);
        baseQuery += ' FROM ' + objectAPIName + ' WHERE ' + syncFlag + ' = true';
        return baseQuery;
    }
}