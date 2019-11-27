/**
 * Author: Hitesh Gupta
 * Since: Aug. 31, 2015
 * Name: BPGlobalHeaderCtrl
 * Description: Apex class which contains all remoted methods of global header.
**/ 
global with sharing class BPGlobalHeaderCtrl {
    
	public boolean Load_New_UI {get{return GeneralConfiguration.isLoadNewUI();} private set;}
	
	public Boolean IsTrialOrg { get{return GeneralConfiguration.isTrialOrg();} private set;}
	
	public boolean Load_Customer_Order_V2 {get{return GeneralConfiguration.isLoadNewCustomerOrder();} private set;}
 	public static Set<String> customerTypeSellingGroupSet = new Set<String> {'Part Sale', 'Service Order', 'Unit Deal'}; 
    public static Set<String> serviceSellingGroupSet = new Set<String> {'Service Order', 'Internal Service'};
    public static Set<String> dealSellingGroupSet = new Set<String> {'Unit Deal'};
    
    /**
     * Name: getCurrentUserImageURL
     * Desc: Method used to get user image url for current user
     * @param:  
     * @return: String - string url for user image
    **/  
    public String getCurrentUserImageURL(){
        return UsersUtility.getUserImageURL(UserInfo.getUserId());
    }
    
    /**
     * Name: createCustomerOrder
     * Desc: Method which creates a customer order header record
     * @param:  
     * @return: String - inserted customer order header record Id
    **/
    @RemoteAction
    global static String createCustomerOrder(){
    	if(AccessControl.ifObjectFieldIsCreateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        CO_Header__c coHeaderToInsert = new CO_Header__c();
        coHeaderToInsert.Order_status__c = 'Open';
        coHeaderToInsert.CO_Type__c = 'Cash Sale';
        coHeaderToInsert.Selling_Group__c = 'Cash Sale';
    	coHeaderToInsert.Owner__c = UserInfo.getUserId();
    	
    	
        insert coHeaderToInsert;
        return BPUtility.getEncodedString(String.valueOf(coHeaderToInsert.Id));
    }
    
    global static String createNewCO(String customerId, String sellingGroup, Boolean isPreventMerchSectionCreation) {
    	customerId = BPUtility.getDecodedString(customerId);
		sellingGroup = BPUtility.getDecodedString(sellingGroup);
		
		CO_Header__c coHeaderToInsert  = createCORec(customerId, sellingGroup);
		String coHeaderId = createSection(new List<CO_Header__c> {coHeaderToInsert}, sellingGroup, isPreventMerchSectionCreation);
		return coHeaderId;
	}
	
	@RemoteAction
	global static String createNewCustomerOrder(String customerId, String sellingGroup) {
		customerId = BPUtility.getDecodedString(customerId);
		sellingGroup = BPUtility.getDecodedString(sellingGroup);
		
		CO_Header__c coHeaderToInsert  = createCORec(customerId, sellingGroup);
		String coHeaderId = createSection(new List<CO_Header__c> {coHeaderToInsert}, sellingGroup, false);
		return coHeaderId;
	}
	
	private static CO_Header__c createCORec(String customerId, String sellingGroup){
		CO_Header__c coHeaderToInsert = new CO_Header__c();
		coHeaderToInsert.Order_status__c = 'Open';
		coHeaderToInsert.Owner__c = UserInfo.getUserId();
		coHeaderToInsert.Selling_Group__c = sellingGroup;
		if(customerTypeSellingGroupSet.contains(sellingGroup)) {
			coHeaderToInsert.CO_Type__c = 'Customer';
		} else {
			coHeaderToInsert.CO_Type__c = sellingGroup;
		}
		
		if(AccessControl.ifObjectFieldIsCreateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
		insert coHeaderToInsert;
		
		if(String.isNotBlank(customerId)) {
			updateCustomerOrderInfo(coHeaderToInsert.Id, customerId);
		}
		
		return coHeaderToInsert;
	}
	
	private static String createSection(List<CO_Header__c> coHeaderToInsert, String sellingGroup, Boolean isPreventMerchSectionCreation){
		if(coHeaderToInsert == null || coHeaderToInsert.size() == 0) {
			return null;
		}
		if(sellingGroup == 'Part Sale' && !isPreventMerchSectionCreation) {
			List<SObject> sObjectListToInsert = CustomerOrderCtrl.addLinkedFee(coHeaderToInsert[0].Id, null, 'Merchandise');
			if(sObjectListToInsert != null) {
				insert sObjectListToInsert;
			}
		}
		if(serviceSellingGroupSet.contains(sellingGroup)) {
			CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderToInsert[0].Id));
		}
		if(dealSellingGroupSet.contains(sellingGroup)) {
			CustomerOrderCtrl.createDealHeader(coHeaderToInsert[0].Id);
		}
		return BPUtility.getEncodedString(String.valueOf(coHeaderToInsert[0].Id));
	}

    /**@RemoteAction
	global static String createNewCustomerOrder(String customerId, String sellingGroup) {
		customerId = BPUtility.getDecodedString(customerId);
		sellingGroup = BPUtility.getDecodedString(sellingGroup);
		
		CO_Header__c coHeaderToInsert = new CO_Header__c();
        coHeaderToInsert.Order_status__c = 'Open';
    	coHeaderToInsert.Owner__c = UserInfo.getUserId();
		coHeaderToInsert.Selling_Group__c = sellingGroup;
		if(customerTypeSellingGroupSet.contains(sellingGroup)) {
			coHeaderToInsert.CO_Type__c = 'Customer';
		} else {
			coHeaderToInsert.CO_Type__c = sellingGroup;
		}
		
		if(AccessControl.ifObjectFieldIsCreateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert coHeaderToInsert;
		
		if(String.isNotBlank(customerId)) {
    		//CustomerOrderCtrl.addCustomer(BPUtility.getEncodedString(coHeaderToInsert.Id), BPUtility.getEncodedString(customerId));
			updateCustomerOrderInfo(coHeaderToInsert.Id, customerId);
		}
		if(sellingGroup == 'Part Sale') {
			List<SObject> sObjectListToInsert = CustomerOrderCtrl.addLinkedFee(coHeaderToInsert.Id, null, 'Merchandise');
	        if(sObjectListToInsert != null) {
	        	insert sObjectListToInsert;
	        }
		}
		if(serviceSellingGroupSet.contains(sellingGroup)) {
			CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeaderToInsert.Id));
		}
		if(dealSellingGroupSet.contains(sellingGroup)) {
			createDeal(BPUtility.getEncodedString(coHeaderToInsert.Id));
		}
		return BPUtility.getEncodedString(String.valueOf(coHeaderToInsert.Id));
	}*/
    
    private static void updateCustomerOrderInfo(String coHeaderId, String customerId) {
    	update new CO_Header__c(Id = coHeaderId, Customer__c = customerId, CO_Type__c = 'Customer');
    }

    /**
     * Name: createNewVendorOrder
     * Desc: Method which creates a Vendor order header record
     * @param:  
     * @return: String - inserted Vendor order header record Id
    **/
    @RemoteAction
	global static String createNewVendorOrder(String vendorId) {
		vendorId = BPUtility.getDecodedString(vendorId);
		
		Vendor_Order_Header__c voHeaderToInsert = new Vendor_Order_Header__c();
        voHeaderToInsert.Owner__c = UserInfo.getUserId();
        voHeaderToInsert.Vendor__c = vendorId;
        voHeaderToInsert.Status__c = 'Open';
        
        if(AccessControl.ifObjectFieldIsAccessible('PO_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<PO_Type__c> vendorStandardPOTypes = [Select Id from PO_Type__c where IsDefault__c = true AND Vendor__c =: vendorId];
		if(vendorStandardPOTypes.size() > 0){
            voHeaderToInsert.Purchase_Order_Type__c = vendorStandardPOTypes[0].Id;
        }
        
		if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert voHeaderToInsert;
		
		return BPUtility.getEncodedString(String.valueOf(voHeaderToInsert.Id));
	}
	/**
     * Name: createNewVendorReceiving
     * Desc: Method which creates a Vendor Receiving header record
     * @param:  
     * @return: String - inserted Vendor Receiving header record Id
    **/
	@RemoteAction
	global static String createNewVendorReceiving(String vendorId){
		return VendorOrderReceivingCtrl.addVendor(vendorId, null);
	}
	//#1762 kajal 28th march 2017
	
	@RemoteAction
	global static String createNewVendorInvoicing(String vendorId){
        return VendorInvoicingCtrl.addVendor(vendorId, null, null, null);
	}
	
	
	@RemoteAction
	global static String createNewReturnVO(String vendorId){
        return ReturnVOCtrl.addVendor(vendorId, null);
	}
	
    /**
     * Name: createVendorOrder
     * Desc: Method which creates a Vendor order header record
     * @param:  
     * @return: String - inserted Vendor order header record Id
    **/
    @RemoteAction
    global static String createVendorOrder(){
        
        Vendor_Order_Header__c voHeaderToInsert = new Vendor_Order_Header__c();
        voHeaderToInsert.Owner__c = UserInfo.getUserId();
        voHeaderToInsert.Status__c = 'Open';
        
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert voHeaderToInsert;
        return BPUtility.getEncodedString(String.valueOf(voHeaderToInsert.Id));
        // return null;
    }
    
    
    /**
     * Name: createVendorOrder
     * Desc: Method which creates a Vendor order header record
     * @param:  
     * @return: String - inserted Vendor order header record Id
    **/
    @RemoteAction
    global static String createVOReceiving(){
        
        Vendor_Receiving_Header__c voHeaderReceivingToInsert = new Vendor_Receiving_Header__c();
        voHeaderReceivingToInsert.Owner__c = UserInfo.getUserId();
        voHeaderReceivingToInsert.Status__c = 'In Progress';
        
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert voHeaderReceivingToInsert;
        return BPUtility.getEncodedString(String.valueOf(voHeaderReceivingToInsert.Id));
        
        //return null;
    }
    
    /**
     * Name: createVOInvoicing
     * Desc: Method which creates a Vendor order header record
     * @param:  
     * @return: String - inserted Vendor order header record Id
    **/
    @RemoteAction
    global static String createVOInvoicing(){
        Vendor_Invoicing_Header__c viHeaderToInsert = new Vendor_Invoicing_Header__c();
        viHeaderToInsert.Owner__c = UserInfo.getUserId();
        viHeaderToInsert.Status__c = 'In Progress';
        
        if(AccessControl.ifObjectFieldIsCreateable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        insert viHeaderToInsert;
        return BPUtility.getEncodedString(String.valueOf(viHeaderToInsert.Id));
    }
    
    //START: added by kv 01/20/2017
    /**
     * Name: getActiveCustomerOrdersById
     * Desc: Method which returns active orders of customer by its id
     * @param: String - customerId
     * @return: String - active orders of customer
    **/
    @RemoteAction
    global static String getActiveCustomerOrdersById(String customerId) {
        customerId = BPUtility.getDecodedString(customerId);
        //List<Sobject> ActiveSalesOrdersList = SOQLUtil.getCOHeaderDetailsForCustomer(customerId, null);
        String query;   
        String statusValue = 'Closed';
        query = 'SELECT '; 
        for(String fieldsName : COHeader.fieldsList()){
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', '; 
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM ' + Constants.NAMESPACE + 'CO_Header__c ';
        if(customerId != null) {
            query += 'WHERE Customer__c =: customerId AND Order_Status__c !=: statusValue';
        }
        // Order by clause
        query += ' ORDER BY LastModifiedDate Desc';
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Sobject> ActiveSalesOrdersList = Database.query(query);
        
    	GlobalSearchResultsWrapper globalSearchResults = new GlobalSearchResultsWrapper(ActiveSalesOrdersList.size(), ActiveSalesOrdersList);
    	return BPUtility.getEncodedString(System.JSON.serialize(globalSearchResults));
    }
    //END: added by kv 01/20/2017
    
    //START: Added By Pooja 3 Aug 2017
    /**
     * Name: addServiceJobForJobScheduling
     * Desc: Method which populates CoHeader to Event record
     * @param: String - eventJson
    **/
    @RemoteAction
    global static void addServiceJobForJobScheduling(String eventJson) {
    	//system.assert(false, 'BPCtrl');
    	JobSchedulingCtrl.addServiceJobForJobScheduling(eventJson);
    }
    //End: Added By Pooja 3 Aug 2017 
}