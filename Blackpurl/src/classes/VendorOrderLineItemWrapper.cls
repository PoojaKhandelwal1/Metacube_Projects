/** 
 * Author: Tarun Khandelwal
 * Since: July 24, 2015
 * Name: VendorOrderLineItemWrapper
 * Description: Apex class to handle JSON related oprations of Wrapper of VO Line Item object.
**/
public with sharing class VendorOrderLineItemWrapper{
    public Integer TotalLineItemGroups;
    public List<VendorOrderLineItemGroup> VendorOrderLineItemGroupList;
     
    public List<VendorOrderLineItemGroup> RecentlyEditedGroupList;
    
    public Integer TotalRequiredForStocks;
    public List<VendorOrderLineItem> VOLineItemRequiredForStock;
    
    public Integer TotalRequiredForCustomers;
    public List<VendorOrderLineItem> VOLineItemRequiredForCustomer;
    
    public Decimal GroupTotalCost;
    public Decimal TotalReceivedCost; // Added by TK  - 17/04/2017
    public Decimal TotalUnreceivedCost; // Added by TK  - 17/04/2017
    
    public static Map<String, String> sortFieldMap;
    
    public VendorOrderHeader VendorOrderHeader;
    
    public String NewLineItemId;
    
    public List<POTypes> OrderTypes;  
    
    public List<VendorOrderStockExcess> StockExcessList;
    
    public List<VRHistory> VRHistoryList;
    
    public VendorOrderLineItemWrapper(  List<Vendor_Order_Line_Item__c> voLineItemsRequiredForStock, 
                                        List<Vendor_Order_Line_Item__c> voLineItemsRequiredForCustomer, 
                                        List<Vendor_Order_Line_Item_Group__c> voliGroupList,
                                        VendorOrderCtrl.PaginationSorting itemsPageSortAttrs,
                                        VendorOrderCtrl.PaginationSorting customersPageSortAttrs,
                                        VendorOrderCtrl.PaginationSorting stocksPageSortAttrs,
                                        Map<String, String> listsSortFieldMap,
                                        VendorOrderHeader vendorOrderHeader,
                                        String newLineItemId,
                                        List<PO_Type__c> poTypesList,
                                        List<Vendor_Order_Line_Item_Group__c> recentlyEditedGroup
                                    ) {
        VendorOrderLineItemGroupList = new List<VendorOrderLineItemGroup>();
        RecentlyEditedGroupList = new List<VendorOrderLineItemGroup>();
        VOLineItemRequiredForStock = new List<VendorOrderLineItem>();
        VOLineItemRequiredForCustomer = new List<VendorOrderLineItem>();
        StockExcessList = new List<VendorOrderStockExcess>();
        OrderTypes = new List<POTypes>();
        VRHistoryList = new List<VRHistory>();
        
        sortFieldMap = listsSortFieldMap;
        GroupTotalCost = 0;
        TotalReceivedCost = 0;
        TotalUnreceivedCost = 0;
        
        for(Vendor_Order_Line_Item_Group__c voliGroupRec : voliGroupList) {
        	VendorOrderLineItemGroup voGroupItem = new VendorOrderLineItemGroup(voliGroupRec, vendorOrderHeader);
            this.VendorOrderLineItemGroupList.add(voGroupItem);
            
            VendorOrderStockExcess vendorOrderStockExcessObj = new VendorOrderStockExcess(voliGroupRec);
            if(vendorOrderStockExcessObj.ExcessQty > 0) {
            	this.StockExcessList.add(new VendorOrderStockExcess(voliGroupRec));	
            }
            /* Start: Richa */
            if(voliGroupRec.Status__c != '' && voliGroupRec.Status__c != null) {
	            if(!((voliGroupRec.Status__c).equalsIgnoreCase('Cancelled'))) {
	            	GroupTotalCost += voGroupItem.Total;
	            }
            } else {
            	GroupTotalCost += voGroupItem.Total;
            }
            /* End: Richa */
            voliGroupRec.Cost__c = (voliGroupRec.Cost__c != null) ? voliGroupRec.Cost__c : 0;
            voliGroupRec.Received_Qty__c = (voliGroupRec.Received_Qty__c != null) ? voliGroupRec.Received_Qty__c : 0;
            
            TotalReceivedCost += (voliGroupRec.Cost__c * voliGroupRec.Received_Qty__c);
        }
		TotalReceivedCost = TotalReceivedCost.setScale(2, RoundingMode.HALF_UP);
        TotalUnreceivedCost = GroupTotalCost - TotalReceivedCost;
        
        if(sortFieldMap.containsKey('Stocks') && String.valueOf(sortFieldMap.get('Stocks')).length() != 0){
        	StockExcessList.sort();
        }

        for(Vendor_Order_Line_Item_Group__c voliGroupRec : recentlyEditedGroup) {
            this.RecentlyEditedGroupList.add(new VendorOrderLineItemGroup(voliGroupRec, vendorOrderHeader));
        }
        
        if(sortFieldMap.containsKey('Items') && String.valueOf(sortFieldMap.get('Items')).length() != 0){
        	VendorOrderLineItemGroupList.sort();
        }
        TotalLineItemGroups = VendorOrderLineItemGroupList.size();
        VendorOrderLineItemGroupList = new List<VendorOrderLineItemGroup>(VendorOrderLineItemGroup.getPaginatedRecords(VendorOrderLineItemGroupList, itemsPageSortAttrs.CurrentPage, itemsPageSortAttrs.PageSize));
        
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequiredForStock) {
        	VendorOrderLineItem voLineItem = new VendorOrderLineItem(voliRec);
        	if(vendorOrderHeader.OrderType != null){
        		voLineItem.NeededBy = BPUtility.getFormatedDateTime(voliRec.CreatedDate.addDays(vendorOrderHeader.OrderType.LeadTime));
        	}
            this.VOLineItemRequiredForStock.add(voLineItem);
        }
        
        if(sortFieldMap.containsKey('Stocks') && String.valueOf(sortFieldMap.get('Stocks')).length() != 0){
        	VOLineItemRequiredForStock.sort();
        }
        TotalRequiredForStocks = VOLineItemRequiredForStock.size();
        //VOLineItemRequiredForStock = new List<VendorOrderLineItem>(VendorOrderLineItem.getPaginatedRecords(VOLineItemRequiredForStock, customersPageSortAttrs.CurrentPage, customersPageSortAttrs.PageSize));
        VOLineItemRequiredForStock = new List<VendorOrderLineItem>(VendorOrderLineItem.getPaginatedRecords(VOLineItemRequiredForStock, stocksPageSortAttrs.CurrentPage, stocksPageSortAttrs.PageSize));
        
        for(Vendor_Order_Line_Item__c voliRec : voLineItemsRequiredForCustomer) {
        	VendorOrderLineItem voLineItem = new VendorOrderLineItem(voliRec);
        	if(vendorOrderHeader.OrderType != null){
        		voLineItem.NeededBy = BPUtility.getFormatedDateTime(voliRec.CreatedDate.addDays(vendorOrderHeader.OrderType.LeadTime));
        	}
            this.VOLineItemRequiredForCustomer.add(voLineItem);
        }
        if(sortFieldMap.containsKey('Customers') && String.valueOf(sortFieldMap.get('Customers')).length() != 0){
        	VOLineItemRequiredForCustomer.sort();
        }
        TotalRequiredForCustomers = VOLineItemRequiredForCustomer.size();
        //VOLineItemRequiredForCustomer = new List<VendorOrderLineItem>(VendorOrderLineItem.getPaginatedRecords(VOLineItemRequiredForCustomer, stocksPageSortAttrs.CurrentPage, stocksPageSortAttrs.PageSize));
        VOLineItemRequiredForCustomer = new List<VendorOrderLineItem>(VendorOrderLineItem.getPaginatedRecords(VOLineItemRequiredForCustomer, customersPageSortAttrs.CurrentPage, customersPageSortAttrs.PageSize));
        
        this.VendorOrderHeader = vendorOrderHeader;
        this.NewLineItemId = newLineItemId;
        
        for(PO_Type__c poTypeRec : poTypesList) {
        	this.OrderTypes.add(new POTypes(poTypeRec));
        }
        populateVRHistoryList(vendorOrderHeader.Id);
    }
    
    
    private void populateVRHistoryList(Id voHeaderId) {
    	voHeaderId = BPUtility.escapeSingleQuotes(voHeaderId);
    	if(AccessControl.ifObjectIsAccessible('In_Progress_VR__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
    	List<In_Progress_VR__c> inProgressVRList = [select Vendor_Receiving_Header__c from In_Progress_VR__c where Vendor_Order_Header__c =: voHeaderId];
    	
    	Set<Id> vrHeaderIdSet = new Set<Id>();
    	for(In_Progress_VR__c inProgressVRRec : inProgressVRList) {
    		vrHeaderIdSet.add(inProgressVRRec.Vendor_Receiving_Header__c);
    	}
    	
    	if(vrHeaderIdSet.size() == 0) {
    		return;
    	}
		
		//Start : Added by Nidhi
    	Map<String, Decimal> vrHeaderIdToTotalCostMap = new Map<String, Decimal>();
    	Map<String, Set<String>> vrHeaderIdToVOGIdsMap = new Map<String, Set<String>>();
    	
    	List<Vendor_Order_Line_Item_Group__c> voliGroupList = SOQLUtil.getVOLIGroupsWithItemsInVO(null, null, voHeaderId);
        for(Vendor_Order_Line_Item_Group__c voligRec : voliGroupList) {
        	for(Vendor_Order_Line_Item__c voliRec : voligRec.Vendor_Order_Line_Items__r) {
		        if(String.isNotBlank(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c)) {
		            	
		        	voliRec.Vendor_Receiving_Group__r.Cost__c = (voliRec.Vendor_Receiving_Group__r.Cost__c != null) ? voliRec.Vendor_Receiving_Group__r.Cost__c : 0;
		        	voliRec.Received__c = (voliRec.Received__c != null) ? voliRec.Received__c : 0;
		        	
		        	if(vrHeaderIdToTotalCostMap.containsKey(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c)) {
		        		Decimal totalCost = vrHeaderIdToTotalCostMap.get(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c);
		        		totalCost += (voliRec.Vendor_Receiving_Group__r.Cost__c * voliRec.Received__c);
		        		vrHeaderIdToTotalCostMap.put(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c, totalCost);
		        	} else {
		        		vrHeaderIdToTotalCostMap.put(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c, voliRec.Vendor_Receiving_Group__r.Cost__c * voliRec.Received__c);
		        	}
		        	
		        	Set<String> voligIdSet = new Set<String>{voligRec.Id};
		        	if(vrHeaderIdToVOGIdsMap.containsKey(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c)) {
		        		voligIdSet.addAll(vrHeaderIdToVOGIdsMap.get(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c));
		        }
		        	
		        	vrHeaderIdToVOGIdsMap.put(voliRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__c, voligIdSet);
		        }
        	}
        }
        //End : Added by Nidhi
            	
    	List<Vendor_Receiving_Header__c> vrHeaderList = Database.query(getQuery(vrHeaderIdSet));
		
		for(Vendor_Receiving_Header__c vrHeaderRec : vrHeaderList) {
			VRHistory vrHistoryObj = new VRHistory(vrHeaderRec);
			//Start : Added by Nidhi
			if(vrHeaderIdToTotalCostMap.containsKey(vrHistoryObj.VRHeaderId)) {
				vrHistoryObj.TotalCost = vrHeaderIdToTotalCostMap.get(vrHistoryObj.VRHeaderId);
    		}
    		
    		if(vrHeaderIdToVOGIdsMap.containsKey(vrHistoryObj.VRHeaderId)) {
				vrHistoryObj.TotalLineItems = (vrHeaderIdToVOGIdsMap.get(vrHistoryObj.VRHeaderId)).size();
    		}
    		//End : Added by Nidhi
			this.VRHistoryList.add(vrHistoryObj);
		}    	
    }
    
    private String getQuery(Set<Id> vrHeaderIdSet) {
    	if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Group__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
    	if(AccessControl.ifObjectIsAccessible('Vendor_Receiving_Header__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
    	String query = '';
    	query += 'SELECT ';
    	
    	for(String fieldName : VendorInvoicingCtrl.voReceivingFieldsList()){
            query += fieldName + ', ';
        } 
        
        // Child Query
        query += '(SELECT '; 
        for(String fieldName : VendorInvoicingCtrl.vrGroupFieldsList()){
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Vendor_Receiving_Groups__r ), In_Progress_VI__r.Invoice_Number__c ';
        
        query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Receiving_Header__c WHERE ID IN : vrHeaderIdSet';
        return query;
    }
    
    public class POTypes {
    	public String Id;
    	public String Name;
    	public Boolean IsDefault;
    	
    	public POTypes(PO_Type__c poTypeRec) {
    		this.Id = poTypeRec.Id;
    		this.Name = poTypeRec.Code__c;
    		this.IsDefault = poTypeRec.IsDefault__c;
    	}
    }
    
    // Wrapper class for Vendor Invoice History Section
    public class VRHistory {
    	
    	public String PackingSlipNumber;
    	public String ReceivedDate;
    	public String ReceivedByName;
    	public String ReceivedById;
    	public String VRHeaderId;
    	public String VIHeaderId;
    	public Decimal TotalLineItems;
    	public Decimal TotalCost;
    	public String Status;
        
        public VRHistory(Vendor_Receiving_Header__c vrHeaderRec) {
        	
        	this.PackingSlipNumber = (vrHeaderRec.Packing_Slip_Number__c != null) ? vrHeaderRec.Packing_Slip_Number__c : vrHeaderRec.Name;
    		if(vrHeaderRec.Finalized_Date__c != null) {
    			this.ReceivedDate = BPUtility.getFormatedDateTime(datetime.newInstance(vrHeaderRec.Finalized_Date__c.year(), vrHeaderRec.Finalized_Date__c.month(), vrHeaderRec.Finalized_Date__c.day()));
    		}
    		this.ReceivedByName = vrHeaderRec.Owner__r.Name;
    		this.ReceivedById = vrHeaderRec.Owner__c;
    		this.VRHeaderId = vrHeaderRec.Id;
    		
    		this.TotalLineItems = 0;
    		this.TotalCost = 0;
    		for(Vendor_Receiving_Group__c vrGroupRec : vrHeaderRec.Vendor_Receiving_Groups__r ) {
    			this.TotalLineItems += 1;
    			vrGroupRec.Recieved__c = (vrGroupRec.Recieved__c != null) ? vrGroupRec.Recieved__c : 0;
    			vrGroupRec.Cost__c = (vrGroupRec.Cost__c != null) ? vrGroupRec.Cost__c : 0;
    			this.TotalCost += (vrGroupRec.Recieved__c * vrGroupRec.Cost__c);
    		}
    		
    		this.VIHeaderId = vrHeaderRec.In_Progress_VI__c;
    		
    		if(vrHeaderRec.In_Progress_VI__c != null) {
    			this.Status = (vrHeaderRec.In_Progress_VI__r.Invoice_Number__c != null) ? vrHeaderRec.In_Progress_VI__r.Invoice_Number__c : vrHeaderRec.In_Progress_VI__r.Name;
    		} else {
    			this.Status = 'Pending Invoice';
    		}
        }
    }
}