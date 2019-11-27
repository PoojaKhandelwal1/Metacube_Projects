public without sharing class IntegrationUtility {
    
    public static final String ITEM_CATEGORY = 'Item_Category';
    public static final String PART_FIFO = 'Part_FIFO';
    public static final String PART_FIFO_BUCKET_ACTIVITY_LINE_ITEM = 'Part_FIFO_Bucket_Activity_Line_Item';
    public static final String VENDOR = 'Vendor';
    public static final String CUSTOMER = 'Customer';
    public static final String STORE_CREDIT = 'Store_Credit';
    public static final String UNIT_PRICE_COST = 'Unit_Price_Cost';
    
    public static final String CREATE_ACTION = 'CREATE';
    public static final String UPDATE_ACTION = 'UPDATE';
    
    public static final String ITEM = 'Item';
    public static final String JOURNAL_ENTRY = 'Journal Entry';
    public static List<Integration_Entity__mdt> integrationEntityMetadataList;
    
    public static final String PART_CATEGORY = 'Part_Category';
    public static final String CO_DEPOSIT = 'CO_Deposit';
    public static final String CO_INVOICE_PAYMENT = 'CO_Invoice_Payment';
    public static final String CONTACTS = 'Contacts';
    public static final STring ORGANISATION = 'Organisation';
    public static final STring ACCOUNT = 'Account';
    public static final STring TAX_RATE = 'Tax Rate';
    public static final String VENDOR_RECEIVING = 'Vendor_Receiving';
    public static final String STOCK_UNIT_CATEGORY = 'Stock_Unit_Category';
    public static final String STOCKED = 'Stocked';
    public static final String INVOICE = 'Invoice';
    public static final String CREDIT_NOTE = 'Credit Note';
    public final static String INTERNAL = 'Internal';
    public final static String CLOSED = 'Closed';
    public final static String DEAL = 'Deal'; 
    public final static String STOCK_TRADE_IN = 'Stock_Trade_In';
    
    public static final String VO_INVOICE = 'VO_Invoice';
    public final static String INVOICED = 'Invoiced';
    public static final String CO_INVOICE_JE = 'CO_Invoice_JE';
    public static final String LIEN_PAYOUT = 'Lien_Payout';
    public static final String INVOICE_PAYMENT = 'Invoice_Payment';
    public static final String UNIT_INVOICE = 'Unit_Invoice';
    public static final String VO_RETURN = 'VO_Return';
    
    public void getIntegrationEntityMetadata(List<BaseIntegrationService> baseIntegrationServiceList, String entityName) {
        getIntegrationEntityMetadata(baseIntegrationServiceList, new List<String>{entityName});
    }
    
    public void getIntegrationEntityMetadata(List<BaseIntegrationService> baseIntegrationServiceList, List<String> entityNameList) {
        List<Integration_Entity__mdt> intEntityMetadataList = 
                [Select DeveloperName, Sync_Flag_API_Name__c, Integration_Id_API_Name__c FROM Integration_Entity__mdt 
                    WHERE MasterLabel =: baseIntegrationServiceList[0].integrationName AND DeveloperName IN: entityNameList];
        if(intEntityMetadataList.size() == 0) throw new BlackpurlException('No Sync flag specified.');
        baseIntegrationServiceList[0].integrationEntityNameToRecMap = new Map<String, Integration_Entity__mdt>();
        for(Integration_Entity__mdt intEntityMetadataRec : intEntityMetadataList) {
            baseIntegrationServiceList[0].integrationEntityNameToRecMap.put(intEntityMetadataRec.DeveloperName, intEntityMetadataRec);
        }
    }
}