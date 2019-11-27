public without sharing class BRPUtility {
    
    public static String contentType = 'application/xml';
    
    public static String generateBodId() {
        String h = EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128));
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        return guid;
    }
    
    public static String creationDateTimeString() {
        return DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss-04:00');
    }
    
    public static Id getIFWConfigItemByEntityName(String entityName, String methodType, String integrationName) {
        if(AccessControl.ifObjectIsAccessible('IFW_IntegrationConfigItem__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
        List<IFW_IntegrationConfigItem__c> configItemList = 
                [SELECT Id from IFW_IntegrationConfigItem__c WHERE Entity_Name__c =: entityName AND HTTP_Method__c =: methodType
                    AND IFW_IntegrationConfig__r.Integration_Name__c =: integrationName];
        Id returnId;
        if(configItemList.size() > 0) {
            returnId = configItemList[0].Id;
        }
        return returnId;
    }
    
    public static Id getIdByURL(String URL, String method) {
        if(AccessControl.ifObjectIsAccessible('IFW_IntegrationConfigItem__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); } 
        List<IFW_IntegrationConfigItem__c> configItemList = [SELECT Id from IFW_IntegrationConfigItem__c 
                                                                WHERE Endpoint_URL__c =: URL and HTTP_Method__c =: method];
        Id returnId;
        if(configItemList.size() > 0) {
            returnId = configItemList[0].Id;
        }
        return returnId;
    }
    
    public static CustomHttpHeaderWrapper buildCustomHttpHeader(String key, String value) {
        return new CustomHttpHeaderWrapper(key, value);
    }
    
    public static String getDealerId() {
        return BRP_Settings__c.getOrgDefaults().Dealer_Id__c;
    }
    
    public static String getEndpoint() {
        return BRP_Settings__c.getOrgDefaults().Endpoint__c;
    }
    
    public static String getDealerRadius() {
        return (BRP_Settings__c.getOrgDefaults().Radius__c != null) ? String.valueOf(BRP_Settings__c.getOrgDefaults().Radius__c) : null;
    }
    
    public static String getDealerRadiusMeasure() {
        return BRP_Settings__c.getOrgDefaults().Radius_Measure__c;
    }
    
    public static Set<String> getAllBRPVendorsIdSet() {
        return BRP_Vendors_List__c.getAll().keyset();
    }
}