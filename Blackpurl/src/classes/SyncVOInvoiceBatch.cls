global without sharing class SyncVOInvoiceBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        Map<String, List<String>> childObjectAPINameToFieldsListMap = new Map<String, List<String>>();
        childObjectAPINameToFieldsListMap.put('Vendor_Invoicing_Groups__r', new List<String>(AccountingVendorInvoice.objectToFieldMap.get('VIGroup')));
        childObjectAPINameToFieldsListMap.put('Other_Charges__r', new List<String>(AccountingVendorInvoice.objectToFieldMap.get('OtherCharges')));
        childObjectAPINameToFieldsListMap.put('Part_FIFO_Buckets__r', new List<String>(AccountingFIFOBucket.fieldsList()));
        return Database.getQueryLocator(getBaseQuery('Vendor_Invoicing_Header__c', new List<String>(AccountingVendorInvoice.objectToFieldMap.get('VIHeader')), 
                                                IntegrationUtility.VO_INVOICE, childObjectAPINameToFieldsListMap));
    }
    
    global void execute(Database.batchableContext bc, List<Vendor_Invoicing_Header__c> voInvoiceList) {
        for(Vendor_Invoicing_Header__c vendorInvoice : voInvoiceList) {
            String accId = String.valueOf(vendorInvoice.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VO_INVOICE).Integration_Id_API_Name__c));
            Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.INVOICE => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
            this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingVendorInvoice>{new AccountingVendorInvoice(vendorInvoice, 
                            vendorInvoice.Vendor_Invoicing_Groups__r, vendorInvoice.Part_FIFO_Buckets__r)}, (List<SObject>) sobjctListToUpdate, 
                                        IntegrationUtility.VO_INVOICE, integrationEntityNameToActionMap));
        }
    }
    
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}