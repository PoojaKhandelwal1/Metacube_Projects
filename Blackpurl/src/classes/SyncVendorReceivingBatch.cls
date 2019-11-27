global without sharing class SyncVendorReceivingBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        Map<String, List<String>> childObjectAPINameToFieldsList = new Map<String, List<String>>{	'Vendor_Receiving_Groups__r' => new List<String>(AccountingVendorReceiving.objectToFieldMap.get('VORGroup'))
    																							};
        return Database.getQueryLocator(getBaseQuery('Vendor_Receiving_Header__c', new List<String>(AccountingVendorReceiving.objectToFieldMap.get('VORHeader')), IntegrationUtility.VENDOR_RECEIVING, childObjectAPINameToFieldsList));
    }

    global void execute(Database.batchableContext bc, List<Vendor_Receiving_Header__c> listVendorReceivingHeaders) {
        for(Vendor_Receiving_Header__c vendorReceivingHeader : listVendorReceivingHeaders) {
        	String accId = String.valueOf(vendorReceivingHeader.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VENDOR_RECEIVING).Integration_Id_API_Name__c));
    		Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.JOURNAL_ENTRY => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
        	this.webserviceLogs.addAll(integrationInstanceList[0].sync(new List<AccountingVendorReceiving>{new AccountingVendorReceiving(vendorReceivingHeader, vendorReceivingHeader.Vendor_Receiving_Groups__r)}, (List<SObject>) sobjctListToUpdate, 
                                            IntegrationUtility.VENDOR_RECEIVING, integrationEntityNameToActionMap));
        }
    }
 
    global override void finish(Database.batchableContext bc) {
        finishAction();
    }
}