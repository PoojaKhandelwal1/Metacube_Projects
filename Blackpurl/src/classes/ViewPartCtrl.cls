/**
 * Author: Tarun Khandelwal
 * Since: June 17, 2015
 * Name: ViewPartCtrl
 * Description: Controller Class of Part Detail Page.
**/
global with sharing class ViewPartCtrl {
	
	
	global ViewPartCtrl (NewHomePageCtrl controller){}
    public ViewPartCtrl() {}
	
	/**
     * Name: getPartInfo
     * Desc: To get Part Inforamtion used in View Part Page
     * @param: (1) partId - String - Id of Part
     * @return: String - JSON string of Part Info. 
    **/
   	@RemoteAction
    global static String getPartInfo(String partId) {
    	try{
    		partId = BPUtility.getDecodedString(partId);
	    	boolean previewMode =  false;
	        List<Part__c> parts = SOQLUtil.getPartDetailRecordsByFieldName('Id', partId);
	        
	        Map<String, String> fieldNameToFieldValueMap = new  Map<String, String>();
	        fieldNameToFieldValueMap.put('Part__c', partId);
	        
	        List<Part_FIFO_Bucket__c> partFIFOBucketList = SOQLUtil.getPartFIFOBucketByPartID(fieldNameToFieldValueMap, previewMode);
	        List<Part_FIFO_Bucket__c> partFIFOBucketTotalPartList = SOQLUtil.getPartFIFOBucketByPartID(fieldNameToFieldValueMap, true);
	        String JSONString = '{}';
	        if(parts.size() > 0) {
	           JSONString = System.JSON.serialize(new PartDetailWrapper(parts[0], getStatisticsCalculation(partId), partFIFOBucketList, partFIFOBucketTotalPartList.size()));
	        }
	        return BPUtility.getEncodedString(JSONString);  
    	}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return BPUtility.getEncodedString('');
    	} 
    }  
 
 	/**
     * Name: getStatisticsCalculation
     * Desc:  
     * @param: (1) partId - String - Id of Part
     * @return: List<String> 
    **/
 	public static List<String> getStatisticsCalculation(String partId) {
 		List<String> calculatedValuesList = new List<String>();
 		try{
	 		partId = BPUtility.escapeSingleQuotes(partId);
	 		
	 		String query = 'SELECT Id, Non_Inventory_Part__c, Last_Sold__c, ' +
	 						  '(SELECT Qty__c, Qty_Committed__c, Price__c FROM CO_Line_Items__r WHERE Closed_CO_Invoice_link__c != null), ' +
							  '(SELECT Qty_Needed__c, Received__c FROM Vendor_Order_Line_Items__r WHERE Is_required_For_Customer__c = true OR Is_Service__c = true), ' +
							  '(SELECT CreatedDate FROM Vendor_Order_Line_Item_Groups__r ORDER BY CreatedDate DESC LIMIT 1) ' +
						   'FROM Part__c WHERE Id =: partId ';
	 		
	 		if(AccessControl.ifObjectIsAccessible('Part__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 		List<Part__c> partList = Database.query(query);
	 		
	 		DateTime lastSoldDate = system.now();
	 		Decimal soldLifeTimeQty = 0; 
	 		Decimal revenueLifetime = 0;
	 		Decimal totalQtyNeeded = 0;
 			Decimal totalQtyReceived = 0;
 			DateTime lastOrderDate = system.now();
 			
	 		if(partList.size() > 0) {
	 			lastSoldDate = partList[0].Last_Sold__c;
	 			
	 			// Sold life time and Revenue life time.
	 			for(CO_Line_Item__c coLineItemRec : partList[0].CO_Line_Items__r) {
	 				Decimal QtyUsed = 0;
	 				if(partList[0].Non_Inventory_Part__c) {
	 					QtyUsed = (coLineItemRec.Qty__c != null) ? coLineItemRec.Qty__c : 0;
	 				} else {
	 					QtyUsed = (coLineItemRec.Qty_Committed__c != null) ? coLineItemRec.Qty_Committed__c : 0;
	 				}
	 				soldLifeTimeQty += (QtyUsed != null) ? QtyUsed : 0;
 					revenueLifetime += (coLineItemRec.Price__c != null) ? (QtyUsed * coLineItemRec.Price__c).setScale(2, RoundingMode.HALF_UP) : 0;
	 			}
	 			
	 			// Special Order Received Percentage
	 			for(Vendor_Order_Line_item__c voLineItemRec : partList[0].Vendor_Order_Line_Items__r) {
		 			totalQtyNeeded += (voLineItemRec.Qty_Needed__c != null) ? voLineItemRec.Qty_Needed__c : 0;
	 				totalQtyReceived += (voLineItemRec.Received__c != null) ? voLineItemRec.Received__c : 0;
	 			}
	 			
	 			// Last Order Date
	 			if(partList[0].Vendor_Order_Line_Item_Groups__r.size() == 1) {
	 				lastOrderDate = partList[0].Vendor_Order_Line_Item_Groups__r[0].CreatedDate;
	 			}
	 		}
	 		
	 		totalQtyNeeded = (totalQtyNeeded == 0) ? 1 : totalQtyNeeded;
	 		Decimal specialOrderReceivedPaercentage = ((totalQtyReceived  * 100)/ totalQtyNeeded).setScale(2, RoundingMode.HALF_UP);
 			
	 		calculatedValuesList.add(String.valueOf(soldLifeTimeQty));
	    	calculatedValuesList.add(String.valueOf(revenueLifetime));
	    	calculatedValuesList.add(String.valueOf(specialOrderReceivedPaercentage));
	    	calculatedValuesList.add(convertIntoLastDuration(lastSoldDate));
	    	calculatedValuesList.add(convertIntoLastDuration(lastOrderDate));
	    	
	    	return calculatedValuesList;
 		}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return calculatedValuesList;
    	}
 	}  
 	
    private static String convertIntoLastDuration(DateTime dateTimeToChange) {
 		String lastDurationTime = '';
 		if(dateTimeToChange == null) {
			dateTimeToChange = system.now();
		}
 		Long dateValue = dateTimeToChange.getTime();
    	Long currentDateValue = system.now().getTime();
    	lastDurationTime = String.valueOf(Integer.valueOf(((currentDateValue - dateValue)/ (1000 * 60 * 60 * 24)) / 30 )) + 'm ';
    	lastDurationTime += String.valueOf(Integer.valueOf( Math.mod(((currentDateValue - dateValue)/ (1000 * 60 * 60 * 24)), 30))) + 'd ';
    	lastDurationTime += String.valueOf(Integer.valueOf( Math.mod(((currentDateValue - dateValue)/ (1000 * 60 * 60)), 24))) + 'h ';
    	//lastDurationTime += String.valueOf(Integer.valueOf( Math.mod(((currentDateValue - dateValue)/ (1000 * 60 )), 60))) + 'min';
    	return lastDurationTime;
 	}
    
   	/**
     * Name: increaseAdjustInStock
     * Desc: To get Part Inforamtion used in View Part Page
     * @param: (1) partId - String - Id of Part 
     * @return: String - JSON string of Part Info. 
   	**/
   	@RemoteAction
   	global static String increaseAdjustInStock(String partId, Decimal qtyIn, Decimal cost) {
   		try{
   			partId = BPUtility.getDecodedString(partId);
   			
   			
	   		Decimal maxPartAdjustCount = 0;
	   		if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	 	List<Part_FIFO_Bucket__c> existingPartBucketList = [select Part_Adjust_Number__c from Part_FIFO_Bucket__c order by Part_Adjust_Number__c DESC NULLS LAST limit 1];
	 	  	if(existingPartBucketList.size() > 0) {
	 	  		maxPartAdjustCount = (existingPartBucketList[0].Part_Adjust_Number__c != null) ? existingPartBucketList[0].Part_Adjust_Number__c : 0;
	 	  	}
	 	  	Part_FIFO_Bucket__c partBucketRec = new Part_FIFO_Bucket__c();
	 	  	partBucketRec.Source_Name__c = 'Stock Count';			
	 	  	partBucketRec.Part_Adjust_Number__c = maxPartAdjustCount + 1;
	 	  	partBucketRec.Reference__c = 'Count Adjustment';
	 	  	partBucketRec.Qty_In__c = qtyIn;
	 	  	partBucketRec.Cost__c = cost;
			partBucketRec.VRCost__c = cost;
	 	  	partBucketRec.Part__c = partId;
	 	  	partBucketRec.Is_FIFO_Bucket__c = true;
	 	  	if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  	insert partBucketRec;
	        FIFOTransaction.updatePartInStock(new List<String>{partId});
	        
	      	return getPartInfo(BPUtility.getEncodedString(partId));
	      	
   		}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return BPUtility.getEncodedString('');
    	}
   	}
   	
   	/**
     * Name: increaseAdjustInStock
     * Desc: To get Part Inforamtion used in View Part Page
     * @param: (1) partId - String - Id of Part 
     * @return: String - JSON string of Part Info. 
   	**/
   	@RemoteAction
   	global static String decreaseAdjustInStock(String partId, Decimal qty, String FIFOBucketJSONString) {
   		try{
   			partId = BPUtility.getDecodedString(partId);
   			FIFOBucketJSONString = BPUtility.getDecodedString(FIFOBucketJSONString);
   			
	   		List<PartFifoBucket> partFIFOObjList = (List<PartFifoBucket>)System.JSON.deserialize(FIFOBucketJSONString, List<PartFifoBucket>.class);
	   		List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketLineItemList =  new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
	   		
	   		Decimal maxPartAdjustCount = 0;
	   		if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	 	List<Part_FIFO_Bucket__c> existingPartBucketList = [select Part_Adjust_Number__c from Part_FIFO_Bucket__c order by Part_Adjust_Number__c DESC  NULLS LAST limit 1];
	 	  	if(existingPartBucketList.size() > 0) {
	 	  		maxPartAdjustCount = (existingPartBucketList[0].Part_Adjust_Number__c != null) ? existingPartBucketList[0].Part_Adjust_Number__c : 0;
	 	  	}
	 	  	
	 	  	Part_FIFO_Bucket__c partBucketRec = new Part_FIFO_Bucket__c();
	 	  	partBucketRec.Source_Name__c = 'Stock Adjust';			
	 	  	partBucketRec.Part_Adjust_Number__c = maxPartAdjustCount + 1;
	 	  	partBucketRec.Reference__c = 'Stock Adjustment';
	 	  	partBucketRec.Qty_In__c = 0;
	 	  	partBucketRec.Cost__c = 0;
			partBucketRec.VRCost__c = 0;
	 	  	partBucketRec.Part__c = partId;
	 	  	partBucketRec.Is_FIFO_Bucket__c = false;
	 	  	if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  	insert partBucketRec;
	   		
	   		for(PartFifoBucket partBucketObj : PartFifoObjList) {
	 	  		if(qty > 0) {
		 	  		Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
		 	  		partActivityLineItemRec.Part_Adjustment__c = partBucketRec.Id;
		 	  		partActivityLineItemRec.Part_FIFO_Bucket__c = partBucketObj.FIFOBucketId;
		 	  		partActivityLineItemRec.Reference__c = 'Count Adjustment';
	 	  		
	 	  			if((qty - partBucketObj.RemainingQty) > 0) {
	 	  				partActivityLineItemRec.Qty_Out__c = partBucketObj.RemainingQty;
	 	  			} else {
	 	  				partActivityLineItemRec.Qty_Out__c = qty;
	 	  			}
	 	  			qty -= partActivityLineItemRec.Qty_Out__c;
	 	  			partFIFOBucketLineItemList.add(partActivityLineItemRec);
	 	  		} 
	 	  	}
	 	  	
	 	  	if(partFIFOBucketLineItemList.size() > 0) {
	 	  		if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	  		if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  		insert partFIFOBucketLineItemList;
	 	  	}
	 	  	FIFOTransaction.updatePartInStock(new List<String>{partId});
	      	return getPartInfo(BPUtility.getEncodedString(partId));
   		}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return BPUtility.getEncodedString('');
    	} 	
   	}
   	
   
   	@RemoteAction
   	global static String modifyCostSummary(String FIFOBucketJSONString, Decimal newCost) {
   		try{
   			FIFOBucketJSONString = BPUtility.getDecodedString(FIFOBucketJSONString);
   			
	 	  	List<PartFifoBucket> PartFifoObjList = (List<PartFifoBucket>)System.JSON.deserialize(FIFOBucketJSONString, List<PartFifoBucket>.class); 	
			List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketLineItemList =  new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
	 	  	Decimal totalQtyRemaining = 0;
	 	  	String partId;
	 	  	for(PartFifoBucket partBucketObj : PartFifoObjList) {
	 	  		totalQtyRemaining += partBucketObj.RemainingQty;
	 	  		if(partId == null) {
	 	  			partId = partBucketObj.PartId;
	 	  		}
	 	  	}
	 	  	
	 	  	Decimal maxPartAdjustCount = 0;
	 	  	if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	 	List<Part_FIFO_Bucket__c> existingPartBucketList = [select Part_Adjust_Number__c from Part_FIFO_Bucket__c order by Part_Adjust_Number__c DESC  NULLS LAST limit 1];
	 	  	if(existingPartBucketList.size() > 0) {
	 	  		maxPartAdjustCount = (existingPartBucketList[0].Part_Adjust_Number__c != null) ? existingPartBucketList[0].Part_Adjust_Number__c : 0;
	 	  	}
	 	  	
	 	  	
	 	  	Part_FIFO_Bucket__c partBucketRec = new Part_FIFO_Bucket__c();
	 	  	partBucketRec.Source_Name__c = 'Cost Adjust';			
	 	  	partBucketRec.Part_Adjust_Number__c = maxPartAdjustCount + 1;
	 	  	partBucketRec.Reference__c = 'Cost Adjustment';
	 	  	partBucketRec.Qty_In__c = totalQtyRemaining;
	 	  	partBucketRec.Cost__c = newCost;
			partBucketRec.VRCost__c = newCost;
	 	  	partBucketRec.Part__c = partId;
	 	  	partBucketRec.Is_FIFO_Bucket__c = true;
	 	  	if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
 	  		insert partBucketRec;
	 	  	for(PartFifoBucket partBucketObj : PartFifoObjList) {
	 	  		Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
	 	  		partActivityLineItemRec.Part_Adjustment__c = partBucketRec.Id;
	 	  		partActivityLineItemRec.Part_FIFO_Bucket__c = partBucketObj.FIFOBucketId;
	 	  		partActivityLineItemRec.Reference__c = 'Cost Adjustment';
	 	  		partActivityLineItemRec.Qty_Out__c = partBucketObj.RemainingQty;
	 	  		partBucketObj.PartFIFOActivityLineItemList.add(new PartFifoBucket.PartFIFOActivityLineItem(partActivityLineItemRec));
	 	  		partFIFOBucketLineItemList.add(partActivityLineItemRec);
	 	  	}
	 	  	
	 	  	//PartFifoObjList.add(new PartFifoBucket(partBucketRec));
	 	  	if(partFIFOBucketLineItemList.size() > 0) {
	 	  			if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	  			if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  			
	 	  			if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  		insert partFIFOBucketLineItemList;
	 	  	}
	 	  	FIFOTransaction.updatePartInStock(new List<String>{partId});
	      	return getPartInfo(BPUtility.getEncodedString(partId));
   		}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return BPUtility.getEncodedString('');
    	}	
   	}
   	
   	@RemoteAction
	global static String saveAdjustedCostDetails(String costDetailsJson,Decimal newCost,Boolean isAdjustedRemaining) {
		try{
			costDetailsJson = BPUtility.getDecodedString(costDetailsJson);
			
	 	  	PartFifoBucket PartFifoBucketobj = (PartFifoBucket)System.JSON.deserialize(costDetailsJson,PartFifoBucket.class);
			List<PartFifoBucket> PartFifoObjList = new List<PartFifoBucket>(); 
			List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketLineItemList =  new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
			List<Coli_Fifo_Line_Item_Junction__c> ColiFifoItemListToUpdate = new List<Coli_Fifo_Line_Item_Junction__c>();
			map<Id,Decimal> FIFOIdToCostMap = new map<Id,Decimal>();
	 	  	FIFOTransaction fifoTransactionObject = new FIFOTransaction();
			String partId;
			partId = PartFifoBucketobj.PartId;
	 	  	Decimal totalQtyRemaining = 0;
	 	 	Decimal maxPartAdjustCount = 0;
	 	 	if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	 	List<Part_FIFO_Bucket__c> existingPartBucketList = [select Part_Adjust_Number__c from Part_FIFO_Bucket__c order by Part_Adjust_Number__c DESC  NULLS LAST limit 1];
	 	  	if(existingPartBucketList.size() > 0) {
	 	  		maxPartAdjustCount = (existingPartBucketList[0].Part_Adjust_Number__c != null) ? existingPartBucketList[0].Part_Adjust_Number__c : 0;
	 	  	}
	 	  	
	 	  	Part_FIFO_Bucket__c partBucketRec = new Part_FIFO_Bucket__c();
	 	  	partBucketRec.Source_Name__c = 'Cost Adjust';			
	 	  	partBucketRec.Reference__c =  'Re:' + PartFifoBucketobj.UniqueId;
	 	  	partBucketRec.Part__c = partId;
	 	  	partBucketRec.Part_Adjust_Number__c = maxPartAdjustCount + 1;
	 	  	if(isAdjustedRemaining){
	 	  		partBucketRec.Qty_In__c = PartFifoBucketobj.RemainingQty;
	 	  	}
	 	  	else{
	 	  		partBucketRec.Qty_In__c = PartFifoBucketobj.QtyIn;partBucketRec.VRCost__c = newCost;
	 	  	}
	 	  	partBucketRec.Cost__c = newCost;
			partBucketRec.VRCost__c = newCost;
	 	  	partBucketRec.Is_FIFO_Bucket__c = true;
	 	  	if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  	insert partBucketRec;
	 	  	if(!isAdjustedRemaining){
	 	  		
	 	  		if(PartFifoBucketobj.SourceName == 'Cost Adjust'){
	 	  			// Getting  last cost adjusted bucket 
		 	  			List<Coli_Fifo_Line_Item_Junction__c>	colIFifoLineItemForCostAdjustList = [select Part_FIFO_Bucket_Activity_Line_Item__r.Part_FIFO_Bucket__c,Part_FIFO_Bucket_Activity_Line_Item__c from Coli_Fifo_Line_Item_Junction__c where Part_FIFO_Bucket__c =: PartFifoBucketobj.FIFOBucketId ];
		 	  			set<Id>	fifobucketAdjustSet= new Set<Id>();
		 	  			
		 	  			for(Coli_Fifo_Line_Item_Junction__c colififoitem : colIFifoLineItemForCostAdjustList){
		 	  				if(colififoitem.Part_FIFO_Bucket_Activity_Line_Item__c !=null){
		 	  					fifobucketAdjustSet.add(colififoitem.Part_FIFO_Bucket_Activity_Line_Item__r.Part_FIFO_Bucket__c);
		 	  				}
		 	  				
		 	  			}
		 	  			
		 	  			List<Part_FIFO_Bucket_Activity_Line_Item__c> FifoActivityBucketListFromJunction =  [select Id from Part_FIFO_Bucket_Activity_Line_Item__c where Part_FIFO_Bucket__c IN : fifobucketAdjustSet ];
			 	  		
			 	  		for(Part_FIFO_Bucket_Activity_Line_Item__c FifoActivityBucketItem : FifoActivityBucketListFromJunction)	{
			 	  			FIFOIdToCostMap.put(FifoActivityBucketItem.Id ,newCost);
			 	  		}
	 	  			}	
		 	  	
		 	  		List<Part_FIFO_Bucket_Activity_Line_Item__c> FifoActivityBucketList =  [select Id from Part_FIFO_Bucket_Activity_Line_Item__c where Part_FIFO_Bucket__c =: PartFifoBucketobj.FIFOBucketId ];
		 	  		for(Part_FIFO_Bucket_Activity_Line_Item__c FifoActivityBucketItem : FifoActivityBucketList)	{
		 	  			FIFOIdToCostMap.put(FifoActivityBucketItem.Id ,newCost);
		 	  		}
		 	  		
		 	  		ColiFifoItemListToUpdate = FIFOTransaction.updateInvoiceParts(FIFOIdToCostMap);
			 	  	 for(Coli_Fifo_Line_Item_Junction__c colififItem :  ColiFifoItemListToUpdate){
				 	  			colififItem.Part_FIFO_Bucket__c = partBucketRec.Id;
				 	 }	
	 	  		
	 	  		Part_FIFO_Bucket_Activity_Line_Item__c partpresoldActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
		 	  	partpresoldActivityLineItemRec.Part_Adjustment__c = partBucketRec.Id;
		 	  	partpresoldActivityLineItemRec.Part_FIFO_Bucket__c = partBucketRec.Id;
		 	  	partpresoldActivityLineItemRec.Reference__c = 'Presold on' + PartFifoBucketobj.UniqueId;
		 	  	partpresoldActivityLineItemRec.Qty_Out__c = PartFifoBucketobj.QtyOut;
		 	  	partpresoldActivityLineItemRec.Cost__c = newCost;
		 	  	PartFifoBucketobj.PartFIFOActivityLineItemList.add(new PartFifoBucket.PartFIFOActivityLineItem(partpresoldActivityLineItemRec));
		 	  	partFIFOBucketLineItemList.add(partpresoldActivityLineItemRec);
		 	  	PartFifoObjList.add(new PartFifoBucket(partBucketRec));
	 	  	}  	
	 	  	Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
		 	partActivityLineItemRec.Part_Adjustment__c = partBucketRec.Id;
		 	partActivityLineItemRec.Part_FIFO_Bucket__c = PartFifoBucketobj.FIFOBucketId;
		 	partActivityLineItemRec.Reference__c = 'Cost Adjustment';
		 	partActivityLineItemRec.Qty_Out__c = PartFifoBucketobj.RemainingQty;
	 	  	PartFifoBucketobj.PartFIFOActivityLineItemList.add(new PartFifoBucket.PartFIFOActivityLineItem(partActivityLineItemRec));
	 	  	partFIFOBucketLineItemList.add(partActivityLineItemRec);
	 	  	PartFifoObjList.add(new PartFifoBucket(partBucketRec));
	 	  	if(partFIFOBucketLineItemList.size()>0)
	 	  	{
	 	  		if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	  		if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  		insert partFIFOBucketLineItemList;
	 	  	}
	 	  	
	 	  	if(ColiFifoItemListToUpdate.size() > 0){
	 	  		update ColiFifoItemListToUpdate;
	 	  	}
	 	  	set<String> coliFifoSet = new set<String>();
	 	  	for(Coli_Fifo_Line_Item_Junction__c   ColififoRec : ColiFifoItemListToUpdate){
	 	  		
				coliFifoSet.add(ColififoRec.Id);
			}
			if( coliFifoSet.size() > 0 && !Test.isRunningTest()){
				system.debug('!!!!!!!!1' + coliFifoSet);
				FIFOTransaction.ajdustPartCost(coliFifoSet);
			}
	 	  	FIFOTransaction.updatePartInStock(new List<String>{partId});
	 	  	
	  		return getPartInfo(BPUtility.getEncodedString(partId));
		}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return BPUtility.getEncodedString('');
    	}	
   	}
	  
	  
	@RemoteAction
	global static String resolveOversoldInStock(String FIFOBucketJSONString) {
		try{
			
	 	  	if(AccessControl.ifObjectFieldIsCreateable('Part_FIFO_Bucket__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
	 	  	
			FIFOBucketJSONString = BPUtility.getDecodedString(FIFOBucketJSONString);
				
	 	  	List<PartFifoBucket> PartFifoObjList = (List<PartFifoBucket>)System.JSON.deserialize(FIFOBucketJSONString, List<PartFifoBucket>.class); 	
	 	  	List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketLineItemList =  new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
	 	  	String partId;
	 	  	for(PartFifoBucket partBucketObj : PartFifoObjList) {
	 	  		if(partId == null) {  
	 	  			partId = partBucketObj.PartId;
	 	  		}
	 	  	}
	 	  	
	 	  	Decimal maxPartAdjustCount = 0;
	 	  	if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	  	List<Part_FIFO_Bucket__c> existingPartBucketList = [select Part_Adjust_Number__c from Part_FIFO_Bucket__c order by Part_Adjust_Number__c DESC NULLS LAST limit 1];
	 	  	if(existingPartBucketList.size() > 0) {
	 	  		maxPartAdjustCount = (existingPartBucketList[0].Part_Adjust_Number__c != null) ? existingPartBucketList[0].Part_Adjust_Number__c : 0;
	 	  	}
	 	  	
	 	  	Part_FIFO_Bucket__c partBucketRec = new Part_FIFO_Bucket__c();
	 	  	partBucketRec.Source_Name__c = 'Count Adjust';			
	 	  	partBucketRec.Reference__c = 'Count Adjustment';
	 	  	partBucketRec.Part__c = partId;
	 	  	partBucketRec.Part_Adjust_Number__c = maxPartAdjustCount + 1;
	 	  	insert partBucketRec;
	 	  	
	 	  	for(PartFifoBucket partBucketObj : PartFifoObjList) {
	 	  		
	 	  		Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
	 	  		partActivityLineItemRec.Part_Adjustment__c = partBucketRec.Id;
	 	  		partActivityLineItemRec.Part_FIFO_Bucket__c = partBucketObj.FIFOBucketId;
	 	  		partActivityLineItemRec.Reference__c = 'Count Adjustment';
	 	  		partActivityLineItemRec.Qty_Out__c = partBucketObj.RemainingQty;
	 	  		partBucketObj.PartFIFOActivityLineItemList.add(new PartFifoBucket.PartFIFOActivityLineItem(partActivityLineItemRec));
	 	  		partFIFOBucketLineItemList.add(partActivityLineItemRec);
	 	  		
	 	  	}
	 	  	if(partFIFOBucketLineItemList.size()>0)
	 	  	{
	 	  		if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
	 	  		if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
	 	  		insert partFIFOBucketLineItemList;
	 	  	}
	 	  	//PartFifoObjList.add(new PartFifoBucket(partBucketRec));
	 	  	//FIFOTransaction.updatePartInStock(new List<String>{partId});
	      	return getPartInfo(BPUtility.getEncodedString(partId));
		}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return BPUtility.getEncodedString('');
    	}
   	}
   
   @RemoteAction   
	global static String getHistoryRecords(String PartId, boolean previewMode ) {
		try{
			PartId = BPUtility.getDecodedString(PartId);
			
			Map<String, String> fieldNameToFieldValueMap = new  Map<String, String>();
	        fieldNameToFieldValueMap.put('Part__c', partId);
	        List<Part_FIFO_Bucket__c> partFIFOBucketRecList = SOQLUtil.getPartFIFOBucketByPartID(fieldNameToFieldValueMap, previewMode);
	        
	        
	        List<PartFifoBucket> partFIFOBucketList = new List<PartFifoBucket>();
	        for(Part_FIFO_Bucket__c partFIFOBucketRec : partFIFOBucketRecList) {
	            partFIFOBucketList.add(new PartFifoBucket(partFIFOBucketRec));
	        }
	        return BPUtility.getEncodedString(System.JSON.serialize(partFIFOBucketList));  
		}catch(exception ex){
    		throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
    		return BPUtility.getEncodedString('');
    	}  
	}
	
	@RemoteAction 
    global static String getPartsLocator(String partId, Integer quantity, String searchType) {
    	try {
    		partId = BPUtility.getDecodedString(partId);
    		searchType = BPUtility.getDecodedString(searchType);
            return BPUtility.getEncodedString(BRPPartsIntegration.getPartsLocator(partId, quantity, searchType));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
        return 'success';
    }
    
    /**
     * Name: calculatePartRetailPriceOnUpsert
     * Desc: calculate retail price of part record of a vendor
     * @param: 
     * @return: 
    **/
    public static void calculatePartRetailPriceOnUpsert(Part__c partRecToUpsert, Account vendorRec) {
    	Decimal BaseValue;
    	if(vendorRec.Retail_Base_Value__c == 'Item Cost')	{
    		BaseValue = (partRecToUpsert.Last_Cost__c != null) ? partRecToUpsert.Last_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0.00;//Item Cost
    	}else	{
    		BaseValue = (partRecToUpsert.MSRP__c != null) ? partRecToUpsert.MSRP__c.setScale(2, RoundingMode.HALF_UP) : 0.00;//MSRP
    	}
    	
    	Decimal calculatedRetailPrice = BaseValue + (BaseValue * (vendorRec.Retail_Rate__c/100));
    	calculatedRetailPrice = calculatedRetailPrice.setScale(2, RoundingMode.HALF_UP);
    	if(vendorRec.Retail_Rounding__c)	{
    		calculatedRetailPrice = applyRoundingToCalculatedRetailPrice(vendorRec.Retail_Round_To__c, calculatedRetailPrice);
    	}
    	system.debug('calculatedRetailPrice==' + calculatedRetailPrice);
    	partRecToUpsert.Retail_Price__c = calculatedRetailPrice;
    }
    
    /**
     * Name: calculatePartsRetailPrice
     * Desc: calculate retail price of part record of a vendor
     * @param: 
     * @return: 
    **/
    public static void calculatePartRetailPrice(Part__c partRecToUpdate) {
    	/**Decimal BaseValue;
    	if(partRecToUpdate.Vendor__r.Retail_Base_Value__c == 'Item Cost')	{
    		BaseValue = (partRecToUpdate.Last_Cost__c != null) ? partRecToUpdate.Last_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0.00;//Item Cost
    	}else	{
    		BaseValue = (partRecToUpdate.MSRP__c != null) ? partRecToUpdate.MSRP__c.setScale(2, RoundingMode.HALF_UP) : 0.00;//MSRP
    	}
    	
    	Decimal calculatedRetailPrice = BaseValue + (BaseValue * (partRecToUpdate.Vendor__r.Retail_Rate__c/100));
    	calculatedRetailPrice = calculatedRetailPrice.setScale(2, RoundingMode.HALF_UP);
    	if(partRecToUpdate.Vendor__r.Retail_Rounding__c)	{
    		calculatedRetailPrice = applyRoundingToCalculatedRetailPrice(partRecToUpdate.Vendor__r.Retail_Round_To__c, calculatedRetailPrice);
    	}
    	system.debug('calculatedRetailPrice==' + calculatedRetailPrice);
    	partRecToUpdate.Retail_Price__c = calculatedRetailPrice;*/
        if(partRecToUpdate.Vendor__r.Is_Calculate_Part_Retail_Price__c) {
    		calculatePartRetailPriceOnUpsert(partRecToUpdate, partRecToUpdate.Vendor__r);
    	} else {
    		partRecToUpdate.Retail_Price__c = partRecToUpdate.MSRP__c;
    	}
    }
    
    private static Decimal applyRoundingToCalculatedRetailPrice(Decimal RetailRoundingCentValue, Decimal RetailPriceValue) {
    	Decimal RoundingValue = RetailRoundingCentValue/100;
    	Integer RetailPriceIntegerValue = Integer.valueOf(Math.floor(RetailPriceValue)); 
    	system.debug('RetailRoundingCentValue==' + RetailRoundingCentValue + 'RetailPriceValue ==' + RetailPriceValue + 'RoundingValue==' +RoundingValue + 'RetailPriceIntegerValue==' + RetailPriceIntegerValue + 'diff==' + (RetailPriceValue - Decimal.valueOf(RetailPriceIntegerValue)));
    	if((RetailPriceValue - Decimal.valueOf(RetailPriceIntegerValue)) > RoundingValue)	{
    		RetailPriceIntegerValue = RetailPriceIntegerValue + 1;
    	}
	    Decimal roundedRetailPriceValue = Decimal.valueOf(RetailPriceIntegerValue) + RoundingValue;
	    system.debug('RetailPriceIntegerValue==' + RetailPriceIntegerValue + 'roundedRetailPriceValue==' + roundedRetailPriceValue);
    	return roundedRetailPriceValue;
	}
}