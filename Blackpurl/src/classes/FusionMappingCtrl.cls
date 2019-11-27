/**
 * Author: Tarun Khandelwal
 * Since: August 16, 2018
 * Name: FusionMappingCtrl
 * Description: Ctrl class for Fusion Mapping Page
**/
global without sharing class FusionMappingCtrl {
    
    global FusionMappingCtrl(NewHomePageCtrl controller){} 
    public FusionMappingCtrl() {}
    
    @RemoteAction
    global static String getFusionLineItems() {
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(FusionMappingService.getFusionLineItems(), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getGeneralAccounts() {
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(FusionMappingService.getGeneralAccounts()));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveFusionLineItem(String fusionLineItemId, String jsonStr) {
        fusionLineItemId = BPUtility.getDecodedString(fusionLineItemId);
        jsonStr = BPUtility.getDecodedString(jsonStr);
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(FusionMappingService.saveFusionLineItem(fusionLineItemId, jsonStr), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}