global without sharing class SyncVOReturnBatch extends BaseSyncingBatch {
    
    global override Database.QueryLocator start(Database.BatchableContext bc) {
        Map<String, List<String>> childObjectAPINameToFieldsListMap = new Map<String, List<String>>();
        childObjectAPINameToFieldsListMap.put('Return_VO_Line_Items__r', new List<String>(AccountingVendorReturn.getReturnVOLIFieldList()));
        return Database.getQueryLocator(getBaseQuery('Return_VO_Header__c', new List<String>(AccountingVendorReturn.getReturnVOFieldList()), 
                                                IntegrationUtility.VO_RETURN, childObjectAPINameToFieldsListMap));
    }
    
    global void execute(Database.batchableContext bc, List<Return_VO_Header__c> voReturnList) {
        for(Return_VO_Header__c vendorReturn : voReturnList) {
            String accId = String.valueOf(vendorReturn.get(integrationInstanceList[0].integrationEntityNameToRecMap.get(IntegrationUtility.VO_RETURN).Integration_Id_API_Name__c));
            Map<String, String> integrationEntityNameToActionMap = new Map<String, String>{IntegrationUtility.CREDIT_NOTE => (String.isNotBlank(accId) ? IntegrationUtility.UPDATE_ACTION : IntegrationUtility.CREATE_ACTION)};
            this.webserviceLogs = integrationInstanceList[0].sync(new List<AccountingVendorReturn>{new AccountingVendorReturn(vendorReturn)}, (List<SObject>) sobjctListToUpdate, 
                                        IntegrationUtility.VO_RETURN, integrationEntityNameToActionMap);
        }
    }
    
    global override void finish(Database.batchableContext bc){
        finishAction();
    }
}