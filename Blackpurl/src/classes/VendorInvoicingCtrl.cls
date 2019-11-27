/**
 * Author: Tarun Khandelwal
 * Since: Sept 4, 2015
 * Name: VendorInvoicingCtrl
 * Description: Apex class to handle all operations related to Vendor Invoicing Page.
**/
global with sharing class VendorInvoicingCtrl {
	
	
	public Decimal Related_List_Page_Size { get{return GeneralConfiguration.getRelatedListPageSize();} private set;}
	
	global VendorInvoicingCtrl (NewHomePageCtrl controller){}
    public VendorInvoicingCtrl() {}
	
	/**
     * Name: addVendor
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param:  (1) vendorId - Id - Vendor Id
     *			(2) viHeaderId - Id -  VI Header Id
     * 			(3) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(4) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String - Vendor_Receiving_Header__c Id if successfully selected
    **/
    @RemoteAction
    global static String addVendor(String vendorId, String viHeaderId, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		vendorId = BPUtility.getDecodedString(vendorId);
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
	    	Vendor_Invoicing_Header__c viHeaderRec = new Vendor_Invoicing_Header__c();
	    	if(!String.isBlank(viHeaderId)){
	    		viHeaderRec.Id = viHeaderId;
	    	}
	    	viHeaderRec.Vendor__c = vendorId;
	    	viHeaderRec.Owner__c = UserInfo.getUserId(); 
	    	viHeaderRec.Status__c = 'In Progress';
	    	//Added by nidhi - To avoid duplicate vendor invoice number for same vendor
	    	viHeaderRec.Invoice_Number__c = '';
	    	
	    	try{
	    		if(AccessControl.ifObjectFieldIsCreateable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
				if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    		upsert viHeaderRec;
	    		
	    		// After update, recalculate invoicing group total amount with new purchase order tax amount
	    		
	    		if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    		List<Vendor_Invoicing_Group__c> vigList = [Select Id, VI_Qty__c, VI_Cost__c, VI_Discount__c, VI_SubTotal__c, Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c FROM Vendor_Invoicing_Group__c WHERE Vendor_Invoicing_Header__c =: viHeaderRec.Id];
	    		for(Vendor_Invoicing_Group__c vig : vigList){
	    			vig.VI_SubTotal__c = (vig.VI_Qty__c * vig.VI_Cost__c) - (vig.VI_Qty__c * vig.VI_Cost__c * vig.VI_Discount__c / 100);
	    			vig.VI_SubTotal__c = (vig.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c != null) ? (vig.VI_SubTotal__c + vig.VI_SubTotal__c * vig.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c / 100) : vig.VI_SubTotal__c;
	    		}
	    		if(vigList.size() > 0){
	    			if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    			update vigList;
	    		}
	    		updateVendorInvoicingTotal(viHeaderRec.Id);
	    		// After Insert, Update all Vendor Order Header for the vendor which are received
	    		//updateVendorOrdersReceiving(vrHeader.Id, true);
	    	} catch(Exception e){
	    		return BPUtility.getEncodedString(null);
	    	}
	    	if(String.isBlank(viHeaderId)) {
	    		return BPUtility.getEncodedString(viHeaderRec.Id);
	    	} else {
	    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    		PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderRec.Id), BPUtility.getEncodedString(null), 
	    										BPUtility.getEncodedString(receivingPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
	    	}
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return null;
    }
    
	/**
     * Name: getVendorInvoicingDetails
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param:  (1) viHeaderId - Id -  VI Header Id
     			(2) vrHeaderId - String - Vendor Order Receiving Id
     * 			(3) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(4) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String -  Vendor Invoice Details
    **/
    @RemoteAction
    global static String getVendorInvoicingDetails(String viHeaderId, String vrHeaderId, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	
    	try{
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    	PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
	    	
	    	List<Vendor_Invoicing_Header__c> viHeaderList = new List<Vendor_Invoicing_Header__c>();
	    	List<Vendor_Receiving_Header__c> vrHeaderList = new List<Vendor_Receiving_Header__c>();
	    	List<Vendor_Invoicing_Group__c> viGroupList = new List<Vendor_Invoicing_Group__c>();
	    	List<Other_Charges__c> otherChargesList = new List<Other_Charges__c>(); 
	    	
	    	if(viHeaderId != null) {
	    		viHeaderList =  SOQLUtil.getVIHeaderByFieldName(new Map<String, String>{'Id' => viHeaderId});
	    	}
	    	
	    	if(viHeaderList.size() > 0 && viHeaderList[0].Vendor__c != null) {
	    		Map<String, String> sortFieldMap = new Map<String, String>();
		    	if(receivingPageSortAttrs.sorting != null && receivingPageSortAttrs.sorting[0].sortDirection.length() != 0){
		    		sortFieldMap.put('Packing_Slip_Number__c', receivingPageSortAttrs.sorting[0].sortDirection);
		    	}
		    	
	    		vrHeaderList = SOQLUtil.getVRByVendorId(viHeaderList[0].Vendor__c, viHeaderId, sortFieldMap);
	    	} 
	    	
	    	if(viHeaderList.size() > 0 && viHeaderList[0].Vendor_Receiving_Headers__r.size() > 0) {
	    		Map<String, String> sortFieldMap = new Map<String, String>();
		    	if(groupItemsPageSortAttrs.sorting != null && groupItemsPageSortAttrs.sorting[0].sortDirection.length() != 0){
		    		sortFieldMap.put('Vendor_Receiving_Group__r.Part__r.Part_ID__c', groupItemsPageSortAttrs.sorting[0].sortDirection);
		    		sortFieldMap.put('Vendor_Receiving_Group__r.Part__r.Description__c', groupItemsPageSortAttrs.sorting[0].sortDirection);
		    		sortFieldMap.put('Vendor_Receiving_Group__r.Sublet__r.Code__c', groupItemsPageSortAttrs.sorting[0].sortDirection);
		    		sortFieldMap.put('Vendor_Receiving_Group__r.Sublet__r.Description__c', groupItemsPageSortAttrs.sorting[0].sortDirection);
		    	}
		    	
	    		List<Id> InProgressReceivingHeadersIdList = new List<Id>();
	    		for(Vendor_Receiving_Header__c vrHeaderRec: viHeaderList[0].Vendor_Receiving_Headers__r) {
	    			InProgressReceivingHeadersIdList.add(vrHeaderRec.Id);
	    		}
	    		viGroupList = SOQLUtil.getVIGroupByFieldName('Vendor_Receiving_Group__r.Vendor_Receiving_Header__c', InProgressReceivingHeadersIdList, sortFieldMap);
	    	}
	    	if(viHeaderList.size() > 0){
	    		otherChargesList = SOQLUtil.getOtherChargesByFieldName(new Map<String, String>{'Vendor_Invoicing_Header__c' => viHeaderList[0].Id});
	    	}
	    	VendorInvoicingCtrl.VIHeaderWrapper viHeaderWrapperObj = new VendorInvoicingCtrl.VIHeaderWrapper(viHeaderList, vrHeaderList, viGroupList, otherChargesList, receivingPageSortAttrs, groupItemsPageSortAttrs);//Added by ayushi on 4/09/2017
	    	return BPUtility.getEncodedString(System.JSON.serialize(viHeaderWrapperObj));
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return null;
    }
    
    /**
     * Name: updateVIGroup
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param: 	(1) viHeaderId - Id -  VI Header Id
     			(2) vrHeaderId - String - Vendor Order Receiving Id
     			(3)jsonString  - String  -  JSON String
     * 			(4) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(5) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String -  Vendor Invoice Details
    **/
    @RemoteAction
    global static String updateVIGroup(String viHeaderId, String vrHeaderId, String jsonString, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
    		jsonString = BPUtility.getDecodedString(jsonString);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    	PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
	    	
	    	VendorInvoicingCtrl.VIGroup viGroupObj = (VendorInvoicingCtrl.VIGroup) System.JSON.deserialize(jsonString, VendorInvoicingCtrl.VIGroup.class);
	    	
	    	if(viGroupObj.VIGroupId == null) {
	    		return getVendorInvoicingDetails(viHeaderId, null, receivingPageSortAttrsJSON, groupItemsPageSortAttrsJSON);
	    	}
	    	String viGroupId = viGroupObj.VIGroupId;
	    	
			viGroupId = BPUtility.escapeSingleQuotes(viGroupId);
	    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    	List<Vendor_Invoicing_Group__c> viGroupList = [select Vendor_Receiving_Group__r.Part__r.Packaged_Part__c, Vendor_Receiving_Group__r.Part__r.Package_Qty__c, VI_Qty__c, VI_Cost__c, VI_Discount__c, VI_SubTotal__c from Vendor_Invoicing_Group__c Where Id =: viGroupId];
	    	if(viGroupList.size() > 0) {
	    		Vendor_Invoicing_Group__c viGroupRec = viGroupList[0];
	    		viGroupRec.VI_Cost__c = viGroupObj.InvoiceCost;
	    		if(viGroupList[0].Vendor_Receiving_Group__r.Part__c != null && viGroupList[0].Vendor_Receiving_Group__r.Part__r.Packaged_Part__c) {
	    			viGroupRec.VI_Cost__c = viGroupRec.VI_Cost__c / viGroupList[0].Vendor_Receiving_Group__r.Part__r.Package_Qty__c;// Added on 02/08/2017
	    		}
	    		
	    		viGroupRec.VI_Discount__c = viGroupObj.Discount;
	    		viGroupRec.VI_SubTotal__c = viGroupRec.VI_Qty__c * viGroupRec.VI_Cost__c * (1 - (viGroupRec.VI_Discount__c / 100 ));
	    		//viGroupRec.VI_SubTotal__c = (viGroupRec.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c != null) ? (viGroupRec.VI_SubTotal__c + viGroupRec.VI_SubTotal__c * viGroupRec.Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c / 100) : viGroupRec.VI_SubTotal__c;
	    		viGroupList[0] = viGroupRec;// Added on 02/08/2017
	    		//system.assert(false, viGroupList);
	    		if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    		update viGroupList;
	    	}
	    	updateVendorInvoicingTotal(viHeaderId);
	    	
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(vrHeaderId), 
	    										BPUtility.getEncodedString(receivingPageSortAttrsJSON), 
	    										BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return null;
    }
    
    /**
     * Name: UpdateOtherCharges
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param: 	(1) viHeaderId - Id -  VI Header Id
     			(2) vrHeaderId - String - Vendor Order Receiving Id
     			(3)jsonString  - String  -  JSON String
     * @return: String -  Vendor Invoice Details
    **/
    @RemoteAction
    global static String updateOtherCharges(String viHeaderId, String jsonString, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		jsonString = BPUtility.getDecodedString(jsonString);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    	PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
    		
	    	VendorInvoicingCtrl.OtherChargesWrapper otherChargesObj = (VendorInvoicingCtrl.OtherChargesWrapper) System.JSON.deserialize(jsonString, VendorInvoicingCtrl.OtherChargesWrapper.class);
	    	
	    	if(otherChargesObj.Id == null) {
	    		return getVendorInvoicingDetails(viHeaderId, null, receivingPageSortAttrsJSON, groupItemsPageSortAttrsJSON);
	    	}
	    	if(AccessControl.ifObjectFieldIsUpdateable('Other_Charges__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    	Other_Charges__c otherChargesRec = new Other_Charges__c(Id = otherChargesObj.Id);
	    	otherChargesRec.Item_Description__c = otherChargesObj.Description;
    		otherChargesRec.Notes__c = otherChargesObj.Notes;
    		otherChargesRec.Cost__c = otherChargesObj.Cost;
    		update otherChargesRec;
	    	
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderId), null, 
	    										BPUtility.getEncodedString(receivingPageSortAttrsJSON), 
	    										BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return null;
    }
    
    /**
     * Name: UpdateOtherCharges
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param: 	(1) viHeaderId - Id -  VI Header Id
     			(2) vrHeaderId - String - Vendor Order Receiving Id
     			(3)jsonString  - String  -  JSON String
     * @return: String -  Vendor Invoice Details
    **/
    @RemoteAction
    global static String deleteOtherCharges(String viHeaderId, String otherChargesId, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		otherChargesId = BPUtility.getDecodedString(otherChargesId);
    		
	    	if(String.isNotBlank(otherChargesId)) {
	    		if(AccessControl.ifObjectIsDeletable('Other_Charges__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
		    	Other_Charges__c otherChargesRec = new Other_Charges__c(Id = otherChargesId);
	    		delete otherChargesRec;
	    	}
	    	return getVendorInvoicingDetails(viHeaderId, null, 
	    										receivingPageSortAttrsJSON, 
	    										groupItemsPageSortAttrsJSON);
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return null;
    }
    
    /**
     * Name: updateVendorInvoicingTotal
     * Desc: Method to update total to vendor Invoicing order
     * @param: 	(1) viHeaderId - Id -  VI Header Id
     * @return: 
    **/
    private static void updateVendorInvoicingTotal(String viHeaderId) {
    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
    	viHeaderId = BPUtility.escapeSingleQuotes(viHeaderId);
    	List<Vendor_Invoicing_Group__c> viGroupList = [SELECT VI_SubTotal__c, Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__c,
    																Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c
    													FROM Vendor_Invoicing_Group__c Where Vendor_Invoicing_Header__c =: viHeaderId];
		Decimal total = 0;
		Decimal tax = 0;
    	if(viGroupList.size() > 0) {
    	    String purchaseTaxId = viGroupList[0].Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__c;
    	    Map<Id, List<Decimal>> purchaseTaxIdToTaxLineRateMap = new Map<Id, List<Decimal>>();
    	    if(purchaseTaxId != null) {
    	        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	        List<Applicable_Taxes__c> applicableTaxList = [Select Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c from Applicable_Taxes__c
                                                              Where Sales_Tax__c =: purchaseTaxId];
                for(Applicable_Taxes__c appTaxRec : applicableTaxList) {
                    if(appTaxRec.Sales_Tax_Item__r.Rate__c != null && appTaxRec.Sales_Tax_Item__r.Rate__c != 0) {
                        if(!purchaseTaxIdToTaxLineRateMap.containsKey(purchaseTaxId)) {
                            purchaseTaxIdToTaxLineRateMap.put(purchaseTaxId, new List<Decimal>());
                        }
                        purchaseTaxIdToTaxLineRateMap.get(purchaseTaxId).add(appTaxRec.Sales_Tax_Item__r.Rate__c);
                    }
                }
    	    }
    		for(Vendor_Invoicing_Group__c viGroupRec : viGroupList) {
                viGroupRec.VI_SubTotal__c = (viGroupRec.VI_SubTotal__c == null) ? 0 : viGroupRec.VI_SubTotal__c;
                total += (viGroupRec.VI_SubTotal__c.setScale(2, RoundingMode.HALF_UP));
            }
            
            if(purchaseTaxIdToTaxLineRateMap.containsKey(purchaseTaxId)) {
            	for(Decimal taxRate : purchaseTaxIdToTaxLineRateMap.get(purchaseTaxId)) {
	                tax += (((total * taxRate) / 100).setScale(2, RoundingMode.HALF_UP));
	            }
            }
    	}
    		
    	Vendor_Invoicing_Header__c vendorInvoicingRec = new Vendor_Invoicing_Header__c(Id = viHeaderId, Total__c = total, Tax_Amount__c = tax);
		update vendorInvoicingRec;
	}
    
    /**
     * Name: updateVIHeader
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param:  (1) viHeaderId - Id -  VI Header Id
     			(2) InvoiceNumber - String - Invoice Number
     			(3)InvoiceDateString  - String  -  Invoice Date String
     * 			(4) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(5) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String - Vendor Invoice Details
    **/
    @RemoteAction
    global static String updateVIHeader(String viHeaderId, String InvoiceNumber, String InvoiceDateString, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		InvoiceNumber = BPUtility.getDecodedString(InvoiceNumber);
    		InvoiceDateString = BPUtility.getDecodedString(InvoiceDateString);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    	PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
	    	
	    	Vendor_Invoicing_Header__c viHeaderRec = new Vendor_Invoicing_Header__c();
	    	if(viHeaderId != null){
	    		viHeaderRec.Id = viHeaderId;
	    	}
	    	
	    	if(InvoiceDateString != null) {
	    		viHeaderRec.Invoice_Date__c = Date.parse(InvoiceDateString);
	    	} else {
	    		viHeaderRec.Invoice_Date__c = null;
	    	}
            
	    	if(String.isBlank(InvoiceNumber) || !isSimilarInvoiceNumberExists(viHeaderId, InvoiceNumber)) {
	    		viHeaderRec.Invoice_Number__c = InvoiceNumber;
    		}
	    	if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    	
            update viHeaderRec;
	    	
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(null), 
	    										BPUtility.getEncodedString(receivingPageSortAttrsJSON), 
	    										BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return null;
    }
    
    private static Boolean isSimilarInvoiceNumberExists(String viHeaderId, String invoiceNumber) {
		if(AccessControl.ifObjectIsAccessible('Vendor_Invoicing_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
		List<Vendor_Invoicing_Header__c> viList = [Select Vendor__c from Vendor_Invoicing_Header__c where Id = :viHeaderId];
		if(viList.size() > 0) {
			List<Vendor_Invoicing_Header__c> similarVendorVIList = [Select Id, Invoice_Number__c from Vendor_Invoicing_Header__c where Vendor__c =: viList[0].Vendor__c AND Invoice_Number__c =: invoiceNumber LIMIT 1];
			if(similarVendorVIList.size() > 0) {
				return true;
			}
		}
		return false;
	}
	
    /**
     * Name: getPartByPartId
     * Desc: Method which give JSON string of part Record related to given part Id.
     * @param:  (1) partId - String - Part record Id
     * @return: String - JSON String of part Record.
    **/
    @RemoteAction
    global static String getPartByPartId(String partId){
    	try{
        	return ViewPartCtrl.getPartInfo(partId);
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: getVRDetailForPopUp
     * Desc: Method which give JSON string of VR Header Record related to given VR Header Record Id.
     * @param:  (1) vrHeaderId - String - VR Header Record Id
     * @return: String - JSON String of VR Header Record.
    **/
    @RemoteAction
    global static String getVRDetailForPopUp(String vrHeaderId){
    	try{
    		vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
	        List<Vendor_Receiving_Header__c> vrHeaderList = SOQLUtil.getVRHeaderList(vrHeaderId);
	        String jsonString;
	        if(vrHeaderList.size() == 0) {
	        	jsonString = '{}';
	        } else {
	        	jsonString = System.JSON.serialize(new VendorInvoicingCtrl.VRInPopUp(vrHeaderList[0]));
	        }
	        return BPUtility.getEncodedString(jsonString);
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: addToItemsSubsection
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param:  (1) viHeaderId - Id -  VI Header Id
     			(2) vrHeaderId - String - Vendor Order Receiving Id
     * 			(3) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(4) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String -  Vendor Invoice Details
    **/
    @RemoteAction
    global static String addToItemsSubsection(String viHeaderId, String vrHeaderId, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
    		vrHeaderId = BPUtility.escapeSingleQuotes(vrHeaderId);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    	PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
	    	
	    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    	//List<Vendor_Order_Header__c> voHeaderList = [select Purchase_Order_Type__c, Purchase_Order_Type__r.Discount__c from Vendor_Order_Header__c Where In_Progress_VR__c =: vrHeaderId];
	    	// START: Added on 02/08/2017
	    	if(AccessControl.ifObjectIsAccessible('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	        List<In_Progress_VR__c> ipvrList = [select Vendor_Order_Header__c, Vendor_Order_Header__r.Purchase_Order_Type__c, Vendor_Order_Header__r.Purchase_Order_Type__r.Discount__c from In_Progress_VR__c Where Vendor_Receiving_Header__c =: vrHeaderId];
	    	// END: Added on 02/08/2017
	    	String poTypeId;
	    	Decimal poTypeDiscount = 0;
	    	if((ipvrList.size() > 0) && (ipvrList[0].Vendor_Order_Header__c != null)) {
	    		poTypeId = ipvrList[0].Vendor_Order_Header__r.Purchase_Order_Type__c;
	    		poTypeDiscount = (ipvrList[0].Vendor_Order_Header__r.Purchase_Order_Type__r.Discount__c != null) ? ipvrList[0].Vendor_Order_Header__r.Purchase_Order_Type__r.Discount__c : 0;
	    	}

	    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    	List<Vendor_Receiving_Header__c> vrHeaderList = [select In_Progress_VI__c from Vendor_Receiving_Header__c Where Id =: vrHeaderId];
	    	if(vrHeaderList.size() > 0) {
	    		if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    		vrHeaderList[0].In_Progress_VI__c = viHeaderId;
	    		update vrHeaderList[0];
	    	}
	    	
	     	List<Vendor_Receiving_Group__c> vrGroupList = SOQLUtil.getVORGroupsWithItems('Vendor_Receiving_Header__c', vrHeaderId);
	    	List<Vendor_Invoicing_Group__c> viGroupListToInsert = new List<Vendor_Invoicing_Group__c>();
	    	Vendor_Invoicing_Group__c viGroupRec;
	    	for(Vendor_Receiving_Group__c vrGroupRec : vrGroupList) {
	    		viGroupRec = new Vendor_Invoicing_Group__c();
		    	viGroupRec.Vendor_Invoicing_Header__c = viHeaderId;
		    	viGroupRec.Vendor_Receiving_Group__c = vrGroupRec.Id;	
		    	
		    	if(vrGroupRec.Cost__c == null) {
		    		vrGroupRec.Cost__c = 0;
		    	}
		    	viGroupRec.VI_Cost__c = vrGroupRec.Cost__c;
		    	viGroupRec.VI_Qty__c = vrGroupRec.Recieved__c;
		    	viGroupRec.Packaged_Unit__c = (vrGroupRec.Part__c != null ? vrGroupRec.Part__r.Package_Unit__c : 'EA');
		    	viGroupRec.PO_Type__c = poTypeId;
		    	viGroupRec.VI_Discount__c = poTypeDiscount;
		    	viGroupRec.VI_SubTotal__c = vrGroupRec.Recieved__c * vrGroupRec.Cost__c * (1 - (poTypeDiscount / 100 ));
		    	
                //viGroupRec.VI_SubTotal__c = (vrGroupRec.Vendor_Receiving_Header__r.Vendor__r.Purchase_Tax__r.Rate__c != null) ? (viGroupRec.VI_SubTotal__c + viGroupRec.VI_SubTotal__c * vrGroupRec.Vendor_Receiving_Header__r.Vendor__r.Purchase_Tax__r.Rate__c / 100) : viGroupRec.VI_SubTotal__c;
		    	//Added 02/08/2017
		    	/*if(viGroupRec.Vendor_Receiving_Group__r.Part__r.Packaged_Part__c) {
		            viGroupRec.ReceivingCost = viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c * viGroupRec.Vendor_Receiving_Group__r.Cost__c;
					viGroupRec.InvoiceCost = viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c * viGroupRec.VI_Cost__c;
		            viGroupRec.ReceivingQty = this.ReceivingQty / viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c;
		        } else {
		            viGroupRec.ReceivingCost = (viGroupRec.Vendor_Receiving_Group__r.Cost__c != null) ? (this.ReceivingQty * viGroupRec.Vendor_Receiving_Group__r.Cost__c).setScale(2, RoundingMode.HALF_UP) : 0.00;
					viGroupRec.InvoiceCost = (viGroupRec.VI_Cost__c != null) ? (this.ReceivingQty * viGroupRec.VI_Cost__c).setScale(2, RoundingMode.HALF_UP) : 0.00;
		        }*/
		    	//Added 02/08/2017
		    	viGroupListToInsert.add(viGroupRec);
	    	}
	    	
	    	if(viGroupListToInsert.size() > 0) {
	    		if(AccessControl.ifObjectFieldIsCreateable('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	    		insert viGroupListToInsert;
	    	}
	    	updateVendorInvoicingTotal(viHeaderId);
	    	
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(vrHeaderId), 
	    										BPUtility.getEncodedString(receivingPageSortAttrsJSON), 
	    										BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: addToItemsSubsection
     * Desc: Method to add selected vendor to vendor Invoicing order
     * @param:  (1) viHeaderId - Id -  VI Header Id
     			(2) vrHeaderId - String - Vendor Order Receiving Id
     * 			(3) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(4) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String -  Vendor Invoice Details
    **/
    @RemoteAction
    global static String addOtherCharges(String viHeaderId, String feeId, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		feeId = BPUtility.getDecodedString(feeId);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    
    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    	PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
	    	
	    	if(AccessControl.ifObjectIsAccessible('Fee__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	        List<Fee__c> feeList = [select Code__c, Description__c, Price__c from Fee__c WHERE Id =: feeId];
	    	if(feeList.size() == 0) {
	    		return null;
	    	}
	    	
	    	Other_Charges__c otherChargesRec = new Other_Charges__c(Fee__c = feeList[0].Id);
	    	otherChargesRec.Cost__c = feeList[0].Price__c;
	    	otherChargesRec.Item_Code__c = feeList[0].Code__c;
	    	otherChargesRec.Item_Description__c = feeList[0].Description__c;
	    	otherChargesRec.Vendor_Invoicing_Header__c = viHeaderId;
	    	insert otherChargesRec;
	    	
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(null), 
	    										BPUtility.getEncodedString(receivingPageSortAttrsJSON), 
	    										BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: removeFromItemSubSection
     * Desc: Method to remove selected vendor to vendor Invoicing order
     * @param:  (1) viHeaderId - Id -  VI Header Id
     			(2) vrHeaderId - String - Vendor Order Receiving Id
     * 			(3) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(4) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String - Vendor Invoice Details
    **/
    @RemoteAction
    global static String removeFromItemSubSection(String viHeaderId, String vrHeaderId, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	try{
    		if(AccessControl.ifObjectIsDeletable('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    		
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		vrHeaderId = BPUtility.getDecodedString(vrHeaderId);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
    		PaginationSorting receivingPageSortAttrs = PaginationSorting.parsePageAttrs(receivingPageSortAttrsJSON);
	    	PaginationSorting groupItemsPageSortAttrs = PaginationSorting.parsePageAttrs(groupItemsPageSortAttrsJSON);
	    	viHeaderId = BPUtility.escapeSingleQuotes(viHeaderId);
	    	vrHeaderId = BPUtility.escapeSingleQuotes(vrHeaderId);
	    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    	List<Vendor_Invoicing_Group__c> viGroupList = [select Id from Vendor_Invoicing_Group__c Where Vendor_Invoicing_Header__c =: viHeaderId
	    																AND Vendor_Receiving_Group__r.Vendor_Receiving_Header__c =: vrHeaderId];
	    	if(viGroupList.size() > 0) {
	    		delete viGroupList;
	    	}															
	    	
	    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
	    	List<Vendor_Receiving_Header__c> vrHeaderList = [select In_Progress_VI__c from Vendor_Receiving_Header__c Where Id =: vrHeaderId];
	    	if(vrHeaderList.size() > 0) {
	    		if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    		vrHeaderList[0].In_Progress_VI__c = null;
	    		update vrHeaderList[0];
	    	}
	    	updateVendorInvoicingTotal(viHeaderId);
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(vrHeaderId), 
	    										BPUtility.getEncodedString(receivingPageSortAttrsJSON), 
	    										BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
    	}catch(Exception e){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return BPUtility.getEncodedString(null);
    }
    
    /**
     * Name: validateUniqueInvoiceNumber
     * Desc: Method to validate Unique Invoice Number For QB
     * @param:  (1) viHeaderId - Id -  VI Header Id
     * 			(2) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(3) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String - Vendor Invoice Details
    **/
    @RemoteAction
    global static String validateUniqueInvoiceNumberForQB(String entityValue){
    	entityValue = BPUtility.getDecodedString(entityValue); 
    	entityValue = '\'' + entityValue + '\'';
    	return  BPUtility.getEncodedString(QuickBookQueryService.validateUniqueEntityValue('Bill', 'DocNumber', entityValue, '='));
    }
    
    /**
     * Name: finalizeInvoiceAction
     * Desc: Method to Finalize Invoice Action
     * @param:  (1) viHeaderId - Id -  VI Header Id
     * 			(2) receivingPageSortAttrsJSON - String  - page sort attribute 
     * 			(3) groupItemsPageSortAttrsJSON -String  - page sort attribute group items
     * @return: String - Vendor Invoice Details
    **/
    @RemoteAction
    global static String finalizeInvoiceAction(String viHeaderId, String receivingPageSortAttrsJSON, String groupItemsPageSortAttrsJSON){
    	Savepoint sp = Database.setSavepoint();
    	try{
			viHeaderId = BPUtility.escapeSingleQuotes(viHeaderId);
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		receivingPageSortAttrsJSON = BPUtility.getDecodedString(receivingPageSortAttrsJSON);
    		groupItemsPageSortAttrsJSON = BPUtility.getDecodedString(groupItemsPageSortAttrsJSON);
    		
    		if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    		if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    		List<Vendor_Invoicing_Header__c> viHeaderList = 
                [SELECT Vendor__c, Status__c, Invoice_Number__c, Vendor__r.Purchase_Tax__r.Name__c,
                    (SELECT VI_Qty__c, VI_Discount__c, Vendor_Receiving_Group__r.Sublet__c, Vendor_Receiving_Group__r.Part__c, 
                        Vendor_Receiving_Group__r.Vendor_Receiving_Header__c, Vendor_Receiving_Group__r.Part__r.Qty_In_Stock__c, 
    			        Vendor_Receiving_Group__r.Part__r.Average_Cost__c, VI_Cost__c 
    			        FROM Vendor_Invoicing_Groups__r) 
    			 FROM Vendor_Invoicing_Header__c Where Id =: viHeaderId];
                 
	    	Map<Id, Decimal> partIdToCostMap = new Map<Id, Decimal>();
	    	Map<Id, Decimal> partIdToTotalQtyMap = new Map<Id, Decimal>();
	    	Map<Id, Decimal> partIdToQtyMap = new Map<Id, Decimal>();
	    	Map<Id, Decimal> partIdToAvgCostMap = new Map<Id, Decimal>();
	    	Map<Id, List<Part__c>> vendorReceivingHeaderToPartMap = new Map<Id, List<Part__c>>();
	    	String vendorId;
	    	
	    	Map<Id, Decimal> vrgIdToCostMap = new Map<Id, Decimal>();
	    	if(viHeaderList.size() > 0) {															
		    	Vendor_Invoicing_Header__c viHeaderRec = viHeaderList[0];
		    	vendorId = viHeaderRec.Vendor__c;
		    	viHeaderRec.Status__c = 'Invoiced';
		    	viHeaderRec.Applicable_Purchase_Tax_Name__c = viHeaderList[0].Vendor__r.Purchase_Tax__r.Name__c;
		    	for(Vendor_Invoicing_Group__c viGroupRec : viHeaderRec.Vendor_Invoicing_Groups__r) {
		    		Part__c bucketPart;
		    		viGroupRec.VI_Cost__c = (viGroupRec.VI_Cost__c != null) ? viGroupRec.VI_Cost__c : 0;
		    		if(viGroupRec.Vendor_Receiving_Group__r.Part__c != null) {
		    			
		    			if(!partIdToCostMap.containsKey(viGroupRec.Vendor_Receiving_Group__r.Part__c)) {
			    			partIdToCostMap.put(viGroupRec.Vendor_Receiving_Group__r.Part__c, viGroupRec.VI_Cost__c);
		    			}
		    			if(!partIdToTotalQtyMap.containsKey(viGroupRec.Vendor_Receiving_Group__r.Part__c)) {
			    			if(viGroupRec.Vendor_Receiving_Group__r.Part__r.Qty_In_Stock__c == null) {
			    				viGroupRec.Vendor_Receiving_Group__r.Part__r.Qty_In_Stock__c = 0;
			    			}
			    			partIdToTotalQtyMap.put(viGroupRec.Vendor_Receiving_Group__r.Part__c, viGroupRec.Vendor_Receiving_Group__r.Part__r.Qty_In_Stock__c);
			    		}
			    		decimal qty = (partIdToQtyMap.containsKey(viGroupRec.Vendor_Receiving_Group__r.Part__c)) ? partIdToQtyMap.get(viGroupRec.Vendor_Receiving_Group__r.Part__c) : 0;
			    		qty += viGroupRec.VI_Qty__c;
			    		partIdToQtyMap.put(viGroupRec.Vendor_Receiving_Group__r.Part__c, qty);
			    		
			    		if(!partIdToAvgCostMap.containsKey(viGroupRec.Vendor_Receiving_Group__r.Part__c)) {
			    			if(viGroupRec.Vendor_Receiving_Group__r.Part__r.Average_Cost__c == null) {
			    				viGroupRec.Vendor_Receiving_Group__r.Part__r.Average_Cost__c = 0;
			    			}
			    			partIdToAvgCostMap.put(viGroupRec.Vendor_Receiving_Group__r.Part__c, viGroupRec.Vendor_Receiving_Group__r.Part__r.Average_Cost__c);
			    		}
			    		bucketPart = new Part__c(Id = viGroupRec.Vendor_Receiving_Group__r.Part__c);
		    		}
		    		
		    		// creating part list for fifo bucket
		    		Decimal viLastCost = viGroupRec.VI_Cost__c;
		    		if(viGroupRec.VI_Discount__c != null) {
		    			viLastCost = (viLastCost - (viLastCost * viGroupRec.VI_Discount__c / 100)).setScale(2, RoundingMode.HALF_UP);
		    		}
		    		if(bucketPart != null) {
		    			bucketPart.Last_Cost__c = viLastCost;
		    			
		    			if(!vendorReceivingHeaderToPartMap.containsKey(viGroupRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c)){
			    			vendorReceivingHeaderToPartMap.put(viGroupRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c, new List<Part__c>());
			    		}
			    		vendorReceivingHeaderToPartMap.get(viGroupRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c).add(bucketPart);
		    		} else if(viGroupRec.Vendor_Receiving_Group__r.Sublet__c != null && !vrgIdToCostMap.containsKey(viGroupRec.Vendor_Receiving_Group__c)) {
		    			vrgIdToCostMap.put(viGroupRec.Vendor_Receiving_Group__c, viLastCost);
		    		}
		    	}
		    	if(AccessControl.ifObjectFieldIsUpdateable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
		    	update viHeaderRec; 
	    	}
	    	
	    	if(vendorReceivingHeaderToPartMap.size() > 0){
	    		FIFOTransaction.updateFIFOBucketForVendorInvoicing(vendorReceivingHeaderToPartMap, viHeaderId);
	    	}
	    	if(vrgIdToCostMap.size() > 0) {
	    		List<Vendor_Receiving_Group__c> vrgList = [Select Id, (Select Id, Service_Order_Line_Item__c from Vendor_Order_Line_Items__r where 
	    			Service_Order_Line_Item__r.Service_Order_Header__r.Work_Status__c != 'Invoiced') from Vendor_Receiving_Group__c 
	    			where Id In: vrgIdToCostMap.keySet()];
	    			
    			List<Service_Order_Line_Item__c> soliToUpdate = new List<Service_Order_Line_Item__c>();
    			for(Vendor_Receiving_Group__c vrgRec : vrgList) {
    				if(vrgRec.Vendor_Order_Line_Items__r.size() > 0 && vrgRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__c != null) {
    					soliToUpdate.add(new Service_Order_Line_Item__c(Id = vrgRec.Vendor_Order_Line_Items__r[0].Service_Order_Line_Item__c, 
    						Cost__c = vrgIdToCostMap.get(vrgRec.Id)));
    				}
    			}
	    		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = true;
	    		update soliToUpdate;
	    		ServiceOrderLineItemTriggerHelper.isTriggerExecuted = false;
	    	}
	    	
	    	if(partIdToCostMap.size() > 0) {
	    		List<Part__c> partList = new List<Part__c>();
	    		for(Id partId : partIdToCostMap.keySet()) {
	    			Part__c partRec = new Part__c();
	    			partRec.Id = partId;
	    			partRec.Last_Cost__c = partIdToCostMap.get(partRec.Id);
	    			
	    			// Update logic for average cost
	    			/*partRec.Average_Cost__c = ( (partIdToAvgCostMap.get(partRec.Id) * (partIdToTotalQtyMap.get(partRec.Id) - partIdToQtyMap.get(partRec.Id)))
	    									  + (partIdToCostMap.get(partRec.Id) * partIdToQtyMap.get(partRec.Id)) )
	    									  / partIdToTotalQtyMap.get(partRec.Id);*/
	    			
	    			partList.add(partRec);
	    		}
	    		if(partList.size() > 0) {
	    			if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    			update partList;
	    		} 
	    	}
	    	updateVendorInvoicingTotal(viHeaderId);
	    	changeStatusOfRelatedVendorReceivings(viHeaderId);
            
	    	// Create Activity History.
	    	if(!Test.isRunningTest()) {
	    		populateIndividualTaxesOnVendorInvoices(new Set<Id>{viHeaderId});
    			ActivityHistory.createActivityHistory('Finalize Vendor Invoicing', 'Vendor Invoicing', viHeaderId, 'Vendor', vendorId, null);
	    	}
	    	
	    	return getVendorInvoicingDetails(BPUtility.getEncodedString(viHeaderId), BPUtility.getEncodedString(null), 
	    									BPUtility.getEncodedString(receivingPageSortAttrsJSON), BPUtility.getEncodedString(groupItemsPageSortAttrsJSON));
    	}catch(Exception e){
    		Database.rollback( sp );
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    	return BPUtility.getEncodedString(null);
    }
    
    // Created By Anurag
    /**
     * Name: deleteVendorOrderInvoicing
     * Desc: Method to delete Vendor Order Invoicing
     * @param:  (1) viHeaderId - Id -  VI Header Id
     * @return: 
    **/
    @RemoteAction
    global static String deleteVendorOrderInvoicing(String viHeaderId){
    	try{
    		
    		viHeaderId = BPUtility.getDecodedString(viHeaderId);
    		viHeaderId = BPUtility.escapeSingleQuotes(viHeaderId);
    		if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    		if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    		List<Vendor_Invoicing_Header__c> viHeaderList = [Select (Select Id From Vendor_Invoicing_Groups__r) From Vendor_Invoicing_Header__c   where ID =: viHeaderId ];
    		
    		String response = 'Error';
    		if(viHeaderList.size() > 0 && viHeaderList[0].Vendor_Invoicing_Groups__r.size() == 0){
    			Vendor_Invoicing_Header__c viHeader = new Vendor_Invoicing_Header__c(Id = viHeaderId);

    			if(AccessControl.ifObjectIsDeletable('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
    			delete viHeader;
    			response = 'Success';
    		}
    		return BPUtility.getEncodedString(response);
		}catch(Exception e){
			throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
    	}
    }
    	
    
    
    
    public static List<String> viHeaderFieldsList() {
		List<String> viHeaderFields = new List<String>{ 'Id',
														'Name',
                                                        'Vendor__r.Name',
                                                        'Vendor__c',
                                                        'Owner__c',
                                                        'Owner__r.Name',
                                                        'Invoice_Number__c',
                                                        'Status__c',
                                                        'Invoice_Date__c',
                                                        'Vendor__r.Purchase_Tax__r.Rate__c',
                                                        'Tax_Amount__c',
                                                        'Tax_Amount_For_Other_Charges__c',
	                                                    'Total_Other_Charges__c',
	                                                    'Total_With_Tax__c'
                                            };
    	return viHeaderFields;
	}
	
	public static List<String> otherChargesFieldsList() {
		List<String> otherChargesFields = new List<String>{ 'Name',
	                                                        'Cost__c',
	                                                        'Fee__c',
	                                                        'Item_Desc__c',
	                                                        'Item_Code__c',
	                                                        'Item_Description__c',
	                                                        'Notes__c',
	                                                        'Tax_Percent__c',
	                                                        'Is_Taxable__c',
	                                                        'Vendor_Invoicing_Header__c'
                                            };
    	return otherChargesFields;
	}
	
	public static List<String> viGroupFieldsList() {
		List<String> viGroupFields = new List<String>{ 'Id',
                                                        'Vendor_Invoicing_Header__c',
                                                        'Vendor_Receiving_Group__c',
                                                        'Vendor_Receiving_Group__r.Part__c',
                                                        'Vendor_Receiving_Group__r.Sublet__c',
                                                        'Vendor_Receiving_Group__r.Sublet__r.Code__c',
                                                        'Vendor_Receiving_Group__r.Sublet__r.Description__c',
                                                        'Vendor_Receiving_Group__r.Part__r.Part_ID__c',
                                                        'Vendor_Receiving_Group__r.Part__r.Packaged_Part__c',
                                                        'Vendor_Receiving_Group__r.Part__r.Package_Qty__c',
                                                        'Vendor_Receiving_Group__r.Part__r.Package_Unit__c',
                                                        'Vendor_Receiving_Group__r.Part__r.Order_Lots__c',
                                                        'Vendor_Receiving_Group__r.Part__r.Part_Number__c',
                                                        'Vendor_Receiving_Group__r.Part__r.Description__c',
                                                        'Vendor_Receiving_Group__r.Vendor_Receiving_Header__r.Packing_Slip_Number__c',
                                                        'Vendor_Receiving_Group__r.Recieved__c',
                                                        'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Code__c',
                                                        'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Description__c',
                                                        'Vendor_Receiving_Group__r.Cost__c',
                                                        'VI_Cost__c',
                                                        'VI_Discount__c',
                                                        'VI_Qty__c',
                                                        'VI_SubTotal__c',
                                                        'PO_Type__c',
                                                        'PO_Type__r.Landed_Cost_Adjustment__c',
                                                        'Packaged_Unit__c'
                                            };
    	return viGroupFields;
	}
    
    public static List<String> voReceivingFieldsList() {
		List<String> voReceivingFields = new List<String>{ 	'Id',
															'Packing_Slip_Number__c',
	                                                        'Status__c',
	                                                        'Finalized_Date__c',
	                                                        'In_Progress_VI__c',
	                                                        'In_Progress_VI__r.Name',
	                                                        'Owner__c',
	                                                        'Owner__r.Name',
	                                                        'Name'
                                            };
    	return voReceivingFields;
	}
    
    public static List<String> vrGroupFieldsList() {
		List<String> vrGroupFields = new List<String>{ 	'Id',
														'Cost__c',
                                                        'Recieved__c',
                                                        'Total__c',
                                                        'Part__c',
                                                        'Order__c',
														'Part__r.Part_Id__c',
														'Part__r.Description__c',
														'Part__r.Packaged_Part__c',
														'Part__r.Package_Qty__c'
                                            };
    	return vrGroupFields;
	}
	
	public static List<String> voHeaderFieldsList() {
		List<String> voHeaderFields = new List<String>{ 'Id',
														'Name',
                                                        'In_Progress_VR__c'
                                            };
    	return voHeaderFields;
	}
    
	/**
	 * Name: VIHeader
	 * Description: Vendor Invoice Header  class
	**/
    public class VIHeader {
    	
    	public String VendorName;
    	public String VendorId;
    	public String OwnerName;
    	public String OwnerId;
    	public String Status;
    	public String InvoiceNumber;
    	public String InvoiceDate;
    	public String VIHeaderId;
    	public String VIHeaderNumber;
    	
    	 /**
	     * Name: VIHeader
	     * Desc: Constructor
	     * @param:  (1) viHeaderRec - Vendor_Invoicing_Header__c -  Vendor Invoice Header Record
	     * @return: 
	     **/
    	public VIHeader(Vendor_Invoicing_Header__c viHeaderRec) {
    		
    		this.VendorName = viHeaderRec.Vendor__r.Name;
    		this.VendorId = viHeaderRec.Vendor__c;
    		this.OwnerName = viHeaderRec.Owner__r.Name;
    		this.OwnerId = viHeaderRec.Owner__c;
    		this.Status = viHeaderRec.Status__c;
    		this.InvoiceNumber = viHeaderRec.Invoice_Number__c;
    		if(viHeaderRec.Invoice_Date__c != null) {
    			this.InvoiceDate = BPUtility.getFormatedDateTime(datetime.newInstance(viHeaderRec.Invoice_Date__c.year(), viHeaderRec.Invoice_Date__c.month(), viHeaderRec.Invoice_Date__c.day()));
    		}
    		this.VIHeaderId = viHeaderRec.Id;
    		this.VIHeaderNumber = viHeaderRec.Name;
    	}
    }
    
    /**
	 * Name: VRHeader
	 * Description: Vendor Order Receiving Header  Class
	**/
    public class VRHeader {
    	
    	public String PackingSlipNumber;
    	public String OrderType;
    	public String FinalizeDate;
    	public Decimal TotalNumberOfLineItems;
    	public Decimal TotalCost;
    	public String ReceivedById;
    	public String ReceivedByName;
    	public String VRHeaderId;
    	public String InProgressVIHeaderId;
    	
    	 /**
	     * Name: VRHeader
	     * Desc: Constructor
	     * @param:  (1) vrHeaderRec - Vendor_Receiving_Header__c -  Vendor Receiving Header Record
	     * @return: 
	     **/
    	public VRHeader(Vendor_Receiving_Header__c vrHeaderRec) {
    		
    		this.PackingSlipNumber = vrHeaderRec.Packing_Slip_Number__c;
    		if(vrHeaderRec.Finalized_Date__c != null) {
    			this.FinalizeDate = BPUtility.getExtendedDateFormatWithoutTime(datetime.newInstance(vrHeaderRec.Finalized_Date__c.year(), vrHeaderRec.Finalized_Date__c.month(), vrHeaderRec.Finalized_Date__c.day()));
    		} else {
    			this.FinalizeDate = '';
    		}
    		this.ReceivedByName = vrHeaderRec.Owner__r.Name;
    		this.ReceivedById = vrHeaderRec.Owner__c;
    		
    		this.TotalNumberOfLineItems = 0;
    		this.TotalCost = 0;
    		for(Vendor_Receiving_Group__c vrGroupRec : vrHeaderRec.Vendor_Receiving_Groups__r) {
    			this.TotalNumberOfLineItems += 1;
    			if(vrGroupRec.Cost__c != null && vrGroupRec.Recieved__c != null) {
    				/*if(vrGroupRec.Part__r.Packaged_Part__c != null && vrGroupRec.Part__r.Packaged_Part__c) {
    					this.TotalCost += (vrGroupRec.Cost__c * vrGroupRec.Recieved__c * vrGroupRec.Part__r.Package_Qty__c);
    				} else {
    					this.TotalCost += vrGroupRec.Cost__c * vrGroupRec.Recieved__c;
    				}*/
    				this.TotalCost += (vrGroupRec.Cost__c * vrGroupRec.Recieved__c);
    			}
    		}
    		this.TotalCost = this.TotalCost.setScale(2, RoundingMode.HALF_UP);
    		if(vrHeaderRec.In_Progress_VRs__r != null && vrHeaderRec.In_Progress_VRs__r.size() == 1) {
    			this.OrderType = vrHeaderRec.In_Progress_VRs__r[0].Vendor_Order_Header__r.Name;
    		} else if(vrHeaderRec.In_Progress_VRs__r != null && vrHeaderRec.In_Progress_VRs__r.size() > 1) {
    			this.OrderType = 'Multiple Orders';
    		}
    		
    		this.VRHeaderId = vrHeaderRec.Id;
    		this.InProgressVIHeaderId = vrHeaderRec.In_Progress_VI__c;
    	}
    }
    
     /**
	 * Name: VIGroup
	 * Description: Vendor Invoice Group Class
	**/
    public class VIGroup {
    	
    	public String Item;
    	public String PackingNumber;
    	public Decimal ReceivingQty;
    	public Decimal ReceivingCost;
    	public Decimal InvoiceQty;
    	public Decimal InvoiceCost;
    	public Decimal Discount;
    	public Decimal SubTotal;
    	public String VIGroupId;
    	public String OrderType;
    	public String PackageUnit;
    	public Decimal PackageQty;
    	public Decimal DiscountAmout;
    	public Decimal LcaAmount;
    	public String PartId;
    	public String SubletId;
    	
    	
    	 /**
	     * Name: VIGroup
	     * Desc: Constructor
	     * @param:  (1) viGroupRec - Vendor_Invoicing_Group__c -  Vendor Invoice Group Record
	     * @return: 
	     **/
    	public VIGroup(Vendor_Invoicing_Group__c viGroupRec) {
    		if(viGroupRec.Vendor_Receiving_Group__r.Part__c != null) {
    			this.Item = viGroupRec.Vendor_Receiving_Group__r.Part__r.Part_Number__c + ' - ' + viGroupRec.Vendor_Receiving_Group__r.Part__r.Description__c;
    		} else if(viGroupRec.Vendor_Receiving_Group__r.Sublet__c != null) {
    			String itemDesc = (viGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Code__c != null) ? viGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Code__c : '';
	        	itemDesc += (viGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Description__c != null) ? 
	        		((itemDesc.length() > 0 ? ' - ' : '' ) + viGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Description__c) : '';
	        	this.Item = itemDesc;
    		}
    		this.PackingNumber = viGroupRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__r.Packing_Slip_Number__c;
    		
    		if(viGroupRec.Vendor_Receiving_Group__r.Recieved__c == null) {
    			viGroupRec.Vendor_Receiving_Group__r.Recieved__c = 0;
    		}
    		
    		if(viGroupRec.Vendor_Receiving_Group__r.Part__c != null && viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c == null) {
				viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c = 0;
			}
			if(viGroupRec.Vendor_Receiving_Group__r.Cost__c == null) {
				viGroupRec.Vendor_Receiving_Group__r.Cost__c = 0;
			}
			if(viGroupRec.VI_Cost__c == null) {
				viGroupRec.VI_Cost__c = 0;
			}
			this.ReceivingQty = viGroupRec.Vendor_Receiving_Group__r.Recieved__c;
			
    		this.Discount = viGroupRec.VI_Discount__c;
    		this.SubTotal = (viGroupRec.VI_SubTotal__c != null) ? viGroupRec.VI_SubTotal__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
    		this.VIGroupId = viGroupRec.Id;
    		/*if(viGroupRec.VI_Cost__c == null || this.ReceivingQty == null || this.Discount == null) {
    			this.DiscountAmout = 0.00;
    		} else {
    			this.DiscountAmout = ((viGroupRec.VI_Cost__c * this.ReceivingQty * this.Discount) / 100).setScale(2, RoundingMode.HALF_UP);
    		}*/
    		
    		this.OrderType = '';
    		
	        if(viGroupRec.Vendor_Receiving_Group__r.Part__c != null && viGroupRec.Vendor_Receiving_Group__r.Part__r.Packaged_Part__c) {
	        	//Added 02/08/2017
	        	this.ReceivingCost = viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c * viGroupRec.Vendor_Receiving_Group__r.Cost__c;
				this.InvoiceCost = viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c * viGroupRec.VI_Cost__c;
	            //Added 02/08/2017
	            this.ReceivingQty = this.ReceivingQty / viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c;
	            //this.InvoiceCost = this.ReceivingQty * viGroupRec.VI_Cost__c;//Added 02/08/2017
	            this.OrderType = 'Ordered as ' + viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c + '/' + viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Unit__c;
	            if(viGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c > 1) {
	                this.OrderType += ' in Lots of ' + viGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c;
	            }
	        } else {
		        if(viGroupRec.Vendor_Receiving_Group__r.Part__c != null && viGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c > 1) {
		            this.OrderType += 'Ordered as in Lots of ' + viGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c;
		        }
		        //Added 02/08/2017
	            this.ReceivingCost = (viGroupRec.Vendor_Receiving_Group__r.Cost__c != null) ? (viGroupRec.Vendor_Receiving_Group__r.Cost__c).setScale(2, RoundingMode.HALF_UP) : 0.00;
				this.InvoiceCost = (viGroupRec.VI_Cost__c != null) ? (viGroupRec.VI_Cost__c).setScale(2, RoundingMode.HALF_UP) : 0.00;
				//Added 02/08/2017
	        }
	        this.InvoiceQty = this.ReceivingQty;
	        this.PackageUnit = (viGroupRec.Vendor_Receiving_Group__r.Part__c != null) ? viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Unit__c : 'EA';
	        this.PackageQty = (viGroupRec.Vendor_Receiving_Group__r.Part__c != null) ? viGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c : 1;
	        
            if(viGroupRec.VI_Cost__c == null || this.ReceivingQty == null || this.Discount == null) {
    			this.DiscountAmout = 0.00;
    		} else {
    			this.DiscountAmout = ((this.InvoiceCost  *  this.Discount) / 100).setScale(2, RoundingMode.HALF_UP);
    		}
            if(viGroupRec.PO_Type__r != null) {
	        	if(viGroupRec.PO_Type__r.Landed_Cost_Adjustment__c == null) {
	        		viGroupRec.PO_Type__r.Landed_Cost_Adjustment__c = 0;
	        	}
	        	this.LcaAmount = (((this.InvoiceCost - this.DiscountAmout) * viGroupRec.PO_Type__r.Landed_Cost_Adjustment__c) / 100).setScale(2, RoundingMode.HALF_UP);//viGroupRec.PO_Type__r.Landed_Cost_Adjustment__c;// by kv 02/28/2017
	        }
	        this.PartId = viGroupRec.Vendor_Receiving_Group__r.Part__c;
	        this.SubletId = viGroupRec.Vendor_Receiving_Group__r.Sublet__c;
    	}
    }
    
    /**
	 * Name: VIHeaderWrapper
	 * Description: Vendor Invoice Header Wrapper Class
	**/
    public class VIHeaderWrapper {
    	
    	public List<VendorInvoicingCtrl.VIHeader> VIHeaderRec;
    	public List<VendorInvoicingCtrl.VRHeader> VRHeaderList;
    	public List<VendorInvoicingCtrl.VIGroup> VIGroupList;
    	public List<VendorInvoicingCtrl.OtherChargesWrapper> OtherChargesList;
    	public Decimal ItemsTotal;
    	public Decimal Total;
    	public Decimal TotalOtherCharges;
    	public Decimal Taxes;
    	public Decimal TotalWithTax;
    	
    	public Integer totalOtherChargesRec;
    	public Integer totalVendorOrderInvoicing;
    	public Integer totalGroupItems;
		
		 /**
	     * Name: VIHeaderWrapper
	     * Desc: Constructor
	     * @param:  (1) viHeaderList - List<Vendor_Invoicing_Header__c> -  Vendor Invoice Group Record
	     *			(2)vrHeaderList - List<Vendor_Receiving_Header__c> - List of Vendor Receiving Header Record
	     *			(3)viGroupList - List<Vendor_Invoicing_Group__c> - List of Vendor Receiving Group Record
	     *			(4)receivingPageSortAttrs - PaginationSorting - Page Sort Attributes
	     *			(5)groupItemsPageSortAttrs - PaginationSorting - Group Item Page Sort Attributes
	     * @return: 
	     **/
    	public VIHeaderWrapper(	List<Vendor_Invoicing_Header__c> viHeaderList, 
    							List<Vendor_Receiving_Header__c> vrHeaderList, 
    							List<Vendor_Invoicing_Group__c> viGroupList,
    							List<Other_Charges__c> OtherChargesList,
    							PaginationSorting receivingPageSortAttrs,
    							PaginationSorting groupItemsPageSortAttrs
    						) {
    		this.VIHeaderRec = new List<VendorInvoicingCtrl.VIHeader>();
    		this.VRHeaderList = new List<VendorInvoicingCtrl.VRHeader>();
    		this.VIGroupList = new List<VendorInvoicingCtrl.VIGroup>();
    		this.OtherChargesList = new List<VendorInvoicingCtrl.OtherChargesWrapper>();
    		this.ItemsTotal = 0;
    		this.Total = 0;
    		this.TotalOtherCharges = 0;
    		this.Taxes = 0;
    		this.totalOtherChargesRec = OtherChargesList.size();
    		this.totalVendorOrderInvoicing = vrHeaderList.size();
    		this.totalGroupItems = viGroupList.size();
    		
    		for(Vendor_Invoicing_Header__c vihRec : viHeaderList) {
    			this.VIHeaderRec.add(new VendorInvoicingCtrl.VIHeader(vihRec));
    		}
    		
    		for(Vendor_Receiving_Header__c vrhRec : vrHeaderList) {
    			this.VRHeaderList.add(new VendorInvoicingCtrl.VRHeader(vrhRec));
    		}
    		this.VRHeaderList = getReceivingPaginatedRecords(this.VRHeaderList, receivingPageSortAttrs.CurrentPage, receivingPageSortAttrs.PageSize);
    		
    		for(Vendor_Invoicing_Group__c viGroupRec : viGroupList) {
    			VendorInvoicingCtrl.VIGroup viGroupObj = new VendorInvoicingCtrl.VIGroup(viGroupRec);
    			this.VIGroupList.add(viGroupObj);
    			this.ItemsTotal += viGroupObj.SubTotal;
    		}
    		this.ItemsTotal = this.ItemsTotal.setScale(2, RoundingMode.HALF_UP);
    		this.VIGroupList = getGroupPaginatedRecords(this.VIGroupList, groupItemsPageSortAttrs.CurrentPage, groupItemsPageSortAttrs.PageSize);
    		
    		for(Other_Charges__c otherChargesRec : OtherChargesList) {
    			VendorInvoicingCtrl.OtherChargesWrapper OtherChargesObj = new VendorInvoicingCtrl.OtherChargesWrapper(OtherChargesRec);
    			this.OtherChargesList.add(OtherChargesObj);
    		}
    		
    		if(viHeaderList.size() > 0) {
    			Vendor_Invoicing_Header__c vihRec = viHeaderList[0];
    			Decimal purchaseTax = 0;
    			if(vihRec.Vendor__r.Purchase_Tax__r.Rate__c != null) {
    				purchaseTax = (vihRec.Tax_Amount__c != null) ? vihRec.Tax_Amount__c : 0;
    			}
				this.TotalOtherCharges = (vihRec.Total_Other_Charges__c != null) ? vihRec.Total_Other_Charges__c.setScale(2, RoundingMode.HALF_UP) : 0;
				Decimal taxAmountForOtherCharges = (vihRec.Tax_Amount_For_Other_Charges__c != null) ? 
    																	vihRec.Tax_Amount_For_Other_Charges__c.setScale(2, RoundingMode.HALF_UP) : 0;
    			this.Taxes = (purchaseTax + taxAmountForOtherCharges).setScale(2, RoundingMode.HALF_UP);
    			this.Total = (this.ItemsTotal + this.TotalOtherCharges).setScale(2, RoundingMode.HALF_UP);
    			this.TotalWithTax = (vihRec.Total_With_Tax__c != null) ? vihRec.Total_With_Tax__c : 0;
    		}
    	}
    	
    	/**
	     * Name: getReceivingPaginatedRecords
	     * Desc: Method to paginate entity records list
	     * @param:  (1) allrecords - List<VendorInvoicingCtrl.VRHeader> - Vendor Receiving Header Records
	     *			(2) currentPage - Integer - Page Number
	     *			(3) pageSize - Integer - No of Record in a page
	     * @return: List of Vendor Receiving Header Record
	    **/
	    private List<VendorInvoicingCtrl.VRHeader> getReceivingPaginatedRecords(List<VendorInvoicingCtrl.VRHeader> allrecords, Integer currentPage, integer pageSize) {
	    	List<VendorInvoicingCtrl.VRHeader> objRecords = new List<VendorInvoicingCtrl.VRHeader>();
	    	if(currentPage == null || currentPage == 0){
	    		currentPage = 1;
	    	}
	    	if(pageSize == null || pageSize == 0){
	    		pageSize = (Integer) General_Configurations__c.getInstance().Related_List_Page_Size__c;
	    	}
	    	
	    	for(Integer i = (currentPage * pageSize - pageSize); i < (currentPage * pageSize); i++){
	    		if(allrecords.size() > i){
	    			objRecords.add(allrecords.get(i));
	    		}
	    	}
	    	return objRecords;
	    }
	    
    	/**
	     * Name: getGroupPaginatedRecords
	     * Desc: Method to paginate entity records list
	     * @param:  (1) allrecords - List<VendorInvoicingCtrl.VIGroup> - Vendor Invoice Group Records
	     *			(2) currentPage - Integer - Page Number
	     *			(3) pageSize - Integer - No of Record in a page
	     * @return: List of Vendor Invoice Group  Record
	    **/
	    private List<VendorInvoicingCtrl.VIGroup> getGroupPaginatedRecords(List<VendorInvoicingCtrl.VIGroup> allrecords, Integer currentPage, integer pageSize) {
	    	List<VendorInvoicingCtrl.VIGroup> objRecords = new List<VendorInvoicingCtrl.VIGroup>();
	    	if(currentPage == null || currentPage == 0){
	    		currentPage = 1;
	    	}
	    	if(pageSize == null || pageSize == 0){
	    		pageSize = (Integer) General_Configurations__c.getInstance().Related_List_Page_Size__c;
	    	}
	    	
	    	for(Integer i = (currentPage * pageSize - pageSize); i < (currentPage * pageSize); i++){
	    		if(allrecords.size() > i){
	    			objRecords.add(allrecords.get(i));
	    		}
	    	}
	    	return objRecords;
	    }
    }
    
    public static void changeStatusOfRelatedVendorReceivings(String viHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Receiving_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Vendor_Receiving_Header__c> vrHeaderList = [SELECT Id from Vendor_Receiving_Header__c WHERE In_Progress_VI__c =: viHeaderId];
        for(Vendor_Receiving_Header__c vrHeaderRec : vrHeaderList) {
            vrHeaderRec.Status__c = 'Invoiced';
        }
        
        if(vrHeaderList.size() > 0) {
        	update vrHeaderList;
        }
    }
    
    @future
    public static void populateIndividualTaxesOnVendorInvoices(Set<Id> vendorInvoicingHeaderIdSet) {
        
        if(AccessControl.ifObjectFieldIsCreateable('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Invoicing_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        
        List<Vendor_Invoicing_Header__c> vendorInvoicingHeaderList = [SELECT Vendor__r.Purchase_Tax__c FROM Vendor_Invoicing_Header__c WHERE Id IN: vendorInvoicingHeaderIdSet];
        Set<Id> purchaseTaxNameSet = new Set<Id>();
        for(Vendor_Invoicing_Header__c vendorInvoicingHeaderRec : vendorInvoicingHeaderList) {
            purchaseTaxNameSet.add(vendorInvoicingHeaderRec.Vendor__r.Purchase_Tax__c);
        }
        purchaseTaxNameSet.remove(null);
        
        Map<String, Set<Sales_Tax_Item__c>> purchaseTaxesToTaxItemMap = new Map<String, Set<Sales_Tax_Item__c>>();
        List<Applicable_Taxes__c> applicableTaxJunctions = [SELECT Sales_Tax__c, Sales_Tax_Item__c, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c FROM Applicable_Taxes__c WHERE Sales_Tax__c IN: purchaseTaxNameSet];
        for(Applicable_Taxes__c applicableTax : applicableTaxJunctions) {
            if(!purchaseTaxesToTaxItemMap.containsKey(applicableTax.Sales_Tax__c)) {
                purchaseTaxesToTaxItemMap.put(applicableTax.Sales_Tax__c, new Set<Sales_Tax_Item__c>());
            }
            purchaseTaxesToTaxItemMap.get(applicableTax.Sales_Tax__c).add((Sales_Tax_Item__c)applicableTax.getSObject(Constants.NAMESPACE +'Sales_Tax_Item__r'));
        }
        
        List<Individual_Tax__c> individualTaxListToInsert = new List<Individual_Tax__c>();
        for(Vendor_Invoicing_Header__c vendorInvoicingHeaderRec : vendorInvoicingHeaderList) {
            if(vendorInvoicingHeaderRec.Vendor__r.Purchase_Tax__c != null 
            	&& purchaseTaxesToTaxItemMap.containsKey(vendorInvoicingHeaderRec.Vendor__r.Purchase_Tax__c)) {
                for(Sales_Tax_Item__c salesTaxItem : purchaseTaxesToTaxItemMap.get(vendorInvoicingHeaderRec.Vendor__r.Purchase_Tax__c)) {
                    individualTaxListToInsert.add(
	                    new Individual_Tax__c( 
	                        Vendor_Invoicing_Header__c = vendorInvoicingHeaderRec.Id, 
	                        Tax_Rate__c = salesTaxItem.Rate__c, 
	                        Sales_Tax_Item_Name__c = salesTaxItem.Name__c
	                    ));
                }
            }
        }
        
        if(individualTaxListToInsert.size() > 0) {
			insert individualTaxListToInsert;        	
        }
    }
    
     /**
	 * Name: VRInPopUp
	 * Description: Vendor Receiving Header Pop up Class
	**/
    public class VRInPopUp {
    	
    	public String Id;
    	public String InvoiceDate;
    	public String PackingNumber;
    	public String PrintDate;
    	public String Status;
    	public List<VRGroupInPopUp> VRGroupList;
    	public Decimal SubTotal;
    	public Decimal Tax;
    	public Decimal Total;
    	
    	/**
	     * Name: VRInPopUp
	     * Desc: Constructor
	     * @param:  (1)vrHeaderRec - Vendor_Receiving_Header__c  - Vendor Receiving Header Record
	     * @return: 
	    **/
    	public VRInPopUp(Vendor_Receiving_Header__c vrHeaderRec) {
    		this.Id = vrHeaderRec.Id;
    		if(vrHeaderRec.Finalized_Date__c != null) {
    			this.InvoiceDate = BPUtility.getFormatedDateTime(datetime.newInstance(vrHeaderRec.Finalized_Date__c.year(), vrHeaderRec.Finalized_Date__c.month(), vrHeaderRec.Finalized_Date__c.day()));
    		} else {
    			this.InvoiceDate = null;
    		}
    		this.PackingNumber = vrHeaderRec.Packing_Slip_Number__c;
    		this.PrintDate = this.InvoiceDate;
    		this.Status = vrHeaderRec.Status__c;
    		this.VRGroupList = new List<VRGroupInPopUp>();
    		for(Vendor_Receiving_Group__c vrg : vrHeaderRec.Vendor_Receiving_Groups__r) {
    			this.VRGroupList.add(new VRGroupInPopUp(vrg));
    		}
    		
    		this.SubTotal = 0;
    		this.Tax = 0;
    		 
    		for(VRGroupInPopUp vrGroupObj : VRGroupList) {
    			this.SubTotal += vrGroupObj.Total;
    			this.Tax += vrGroupObj.TaxAmount;
    		}
    		this.SubTotal = this.SubTotal.setScale(2, RoundingMode.HALF_UP);
    		this.Tax = this.Tax.setScale(2, RoundingMode.HALF_UP);
    		this.Total = this.SubTotal + this.Tax;
    	}
    }
    
     /**
	 * Name: VRGroupInPopUp
	 * Description: Vendor Receiving Group Pop up Class
	**/
    public class VRGroupInPopUp {
    	
    	public String Item;
    	public String Id;
    	public Decimal QtyOrdered;
    	public Decimal QtyReceived;
    	public Decimal Price;
    	public Decimal TaxAmount;
    	public Decimal Total;
    	
    	/**
	     * Name: VRGroupInPopUp
	     * Desc: Constructor
	     * @param:  (1)vrGroupRec - Vendor_Receiving_Group__c  - Vendor Receiving Group Record
	     * @return: 
	    **/
    	public VRGroupInPopUp(Vendor_Receiving_Group__c vrGroupRec) {
    		this.Item = vrGroupRec.Part__r.Part_Id__c + ' - ' + vrGroupRec.Part__r.Description__c;
    		this.Id = vrGroupRec.Id;
    		this.QtyOrdered = vrGroupRec.Order__c;
    		this.QtyReceived = vrGroupRec.Recieved__c;
    		this.Price = (vrGroupRec.Cost__c != null) ? vrGroupRec.Cost__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
    		this.TaxAmount = 0;
    		this.Total = (this.Price * this.QtyReceived).setScale(2, RoundingMode.HALF_UP);
    	}
    }
    
    public class OtherChargesWrapper {
    	public String Name;
    	public String Id;
    	public String ItemDesc;
    	public String Code;
    	public String Fee;
    	public String Description;
    	public String Notes;
    	public Decimal Cost;
    	public Decimal TaxPercent;
    	
    	/**
	     * Name: OtherChargesWrapper
	     * Desc: Constructor
	     * @param:  (1)vrGroupRec - Vendor_Receiving_Group__c  - Vendor Receiving Group Record
	     * @return: 
	    **/
    	public OtherChargesWrapper(Other_Charges__c otherChargesRec) {
    		this.Name = otherChargesRec.Name;
    		this.Id = otherChargesRec.Id;
    		this.ItemDesc = (otherChargesRec.Item_Desc__c != null) ? otherChargesRec.Item_Desc__c : '';
    		this.Code = (otherChargesRec.Item_Code__c != null) ? otherChargesRec.Item_Code__c : '';
    		this.Fee = (otherChargesRec.Fee__c != null) ? otherChargesRec.Fee__c : '';
    		this.Description = (otherChargesRec.Item_Description__c != null) ? otherChargesRec.Item_Description__c : '';
    		this.Notes = (otherChargesRec.Notes__c != null) ? otherChargesRec.Notes__c : '';
    		this.Cost = (otherChargesRec.Cost__c != null) ? otherChargesRec.Cost__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
    		this.TaxPercent = (otherChargesRec.Tax_Percent__c != null) ? otherChargesRec.Tax_Percent__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
    	}
    }
}