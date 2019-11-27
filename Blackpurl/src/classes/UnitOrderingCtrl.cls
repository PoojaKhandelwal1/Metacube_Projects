/** 
* Author: Hitesh Gupta
* Since: Nov 3, 2017 
* Name: UnitOrderingCtrl 
* Description: Apex class which contains all remoted methods related to Unit Ordering Page.
**/
global with sharing class UnitOrderingCtrl {
    global UnitOrderingCtrl (NewHomePageCtrl controller){}
    public UnitOrderingCtrl() {}
    
    @RemoteAction
    global static String getVendorsList() {
        List<UnitOrderingWrapper.VendorWrapper> vendorList = UnitOrderingService.getVendorsList();
        return BPUtility.getEncodedString(system.JSON.serialize(vendorList));
    }
    
    @RemoteAction
    global static String getUnitCategoryList() {
        return BPUtility.getEncodedString(system.JSON.serialize(UnitOrderingService.getUnitCategoryList()));
    }
    
    @RemoteAction
    global static String getVendorDetails(String vendorId){
        vendorId = BPUtility.getDecodedString(vendorId);
        UnitOrderingWrapper.VendorWrapper vendorObj = UnitOrderingService.getVendorDetailsById(vendorId);
        return BPUtility.getEncodedString(system.JSON.serialize(vendorObj));
        
    }
    
    @RemoteAction
    global static String SetUnitPurchaseFlagForVendor(String vendorId){
        vendorId = BPUtility.getDecodedString(vendorId);
        UnitOrderingService.SetUnitPurchaseFlagForVendor(vendorId);
        return getVendorsList();
    }
    
    @RemoteAction
    global static String getActiveOrderList(String vendorId){
        vendorId = BPUtility.getDecodedString(vendorId);
        List<UnitOrderingWrapper.UnitOrderWrapper> unitList = UnitOrderingService.getActiveOrderList(vendorId);
        return BPUtility.getEncodedString(system.JSON.serialize(unitList));
    }
    
    @RemoteAction
    global static String applySortingOnActiveOrderList(String vendorId, String jSONString){
        vendorId = BPUtility.getDecodedString(vendorId);
        jSONString = BPUtility.getDecodedString(jSONString);
        
        List<UnitOrderingWrapper.UnitOrderWrapper> unitList = UnitOrderingService.getActiveOrderList(vendorId, jSONString);
        return BPUtility.getEncodedString(system.JSON.serialize(unitList));
    }
    
    @RemoteAction
    global static String removeOrderUnit(String unitId, String vendorId){
        unitId = BPUtility.getDecodedString(unitId);
        UnitOrderingService.cancelOrderedUnit(unitId);
        return getActiveOrderList(vendorId); 
    }
    
    @RemoteAction
    global static String getOrderHistoryList(String vendorId){
        vendorId = BPUtility.getDecodedString(vendorId);
        List<UnitOrderingWrapper.UnitOrderWrapper> unitList = UnitOrderingService.getOrderHistoryList(vendorId);
        return BPUtility.getEncodedString(system.JSON.serialize(unitList));
    }
    
    @RemoteAction
    global static String applySortingOnOrderHistoryList(String vendorId, String jSONString){
        vendorId = BPUtility.getDecodedString(vendorId);
        jSONString = BPUtility.getDecodedString(jSONString);
        
        List<UnitOrderingWrapper.UnitOrderWrapper> unitList = UnitOrderingService.getOrderHistoryList(vendorId, jSONString);
        return BPUtility.getEncodedString(system.JSON.serialize(unitList));
    }
    
    @RemoteAction
    global static String getUnitDetails(String unitId){
        unitId = BPUtility.getDecodedString(unitId);
        List<UnitOrderingWrapper.UnitDetailsWrapper> couObjList = UnitOrderingService.getUnitDetails(unitId);
        return BPUtility.getEncodedString(system.JSON.serialize(couObjList));
    }
    
    
    @RemoteAction
    global static String saveUnitDetails(String jSONString) {
        jSONString = BPUtility.getDecodedString(jSONString);
        if(AccessControl.ifObjectFieldIsUpdateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        String unitId = UnitOrderingService.saveUnitDetails(jSONString);
        if(unitId == 'Duplicate Stock Number') {
            return BPUtility.getEncodedString('{"HasError" : true, "ErrorMessage" : "Duplicate Stock Number"}');   
        } else if(unitId == 'Duplicate VIN Number') {
            return BPUtility.getEncodedString('{"HasError" : true, "ErrorMessage" : "Duplicate VIN Number"}');   
        } else {
            return getUnitDetails(BPUtility.getEncodedString(unitId));
        }
    }
    
    /**
    * Name: savePriceAndCost
    * Desc: Method to save unit price and cost in Database 
    * @param:(1) jSONString - String - Unit price and cost JSON string
    * @return: String - json result string
    **/
    @RemoteAction
    global static String savePriceAndCost(String unitId, String jSONString) {
        jSONString = BPUtility.getDecodedString(jSONString);
        UnitOrderingService.savePriceAndCost(jSONString);
        return getUnitDetails(unitId);
    }
    
    @RemoteAction
    global static String validateUnitInvoiceNumberForQB(String jsonUnits) {
        jsonUnits = BPUtility.getDecodedString(jsonUnits);
        List<UnitOrderingWrapper.UnitOrderWrapper> orderedUnits = (List<UnitOrderingWrapper.UnitOrderWrapper>) System.JSON.deserialize(jsonUnits, List<UnitOrderingWrapper.UnitOrderWrapper>.class);
        String values = ' (';
        
        for(UnitOrderingWrapper.UnitOrderWrapper unit : orderedUnits) {
            values += ' \'' + unit.InvoiceNumber + '\', ' ;
        }
        
        values = values.substring(0, values.length()-2);
        values += ' )';
        
        return BPUtility.getEncodedString(QuickBookQueryService.validateUniqueEntityValue('Bill', 'DocNumber', values, 'IN'));
    }
    
    /**
     * Name: removeCOURecord
     * Desc: Remove Record with given Id
     * @param: (1) customerId - String - Id of Customer 
     * @return: String - JSON string of Customer info. 
    **/
    @RemoteAction
    global static String removePriceAndCost(String unitId, String recordId) {
        recordId = BPUtility.getDecodedString(recordId);
        UnitOrderingService.removePriceAndCost(recordId);
        return getUnitDetails(unitId);
    }
    
    @RemoteAction
    global static String saveUnitReceiving() {
        //TODO add implementation
        return 'SUCCESS'; 
    }
    
    /**
     * Name: saveUnitReceiving
     * Desc: Receive Ordered Units, and create Stock Units
     * @param: (1) jSONString - String - List of Units to be Received
     * @return: String 
    **/
    @RemoteAction
    global static String receiveUnit(String jSONString) {
        return UnitOrderingService.receiveUnits(BPUtility.getDecodedString(jSONString));
    }
    
    @RemoteAction
    global static String checkDuplicateVIN(String vin) {
        return BPUtility.getEncodedString(UnitOrderingService.checkDuplicateVIN(BPUtility.getDecodedString(vin)));
    }
	
	@RemoteAction 
    global static String getVehicleSpecification(String vin) {
    	try {
            return BPUtility.getEncodedString(BRPVehicleIntegration.getVehicleSpecification(BPUtility.getDecodedString(vin)));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return 'success';
    }
}