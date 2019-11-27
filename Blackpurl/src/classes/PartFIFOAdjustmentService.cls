global with sharing class PartFIFOAdjustmentService {
	
    public static List<Part_FIFO_Bucket__c> adjustPartQty(Map<Id, PartCountAjustmentWrapper> partIdToCountAjustmentWrapperMap) {
    	if(AccessControl.ifObjectIsAccessible('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
 	 	if(AccessControl.ifObjectIsAccessible('Part__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE);}
    	if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
   		if(AccessControl.ifObjectIsCreateable('Part_FIFO_Bucket_Activity_Line_Item__c') == false ){throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
 	  		
   		
		Map<String, Part__c> partIdToRecMap = new Map<String, Part__c>([Select Id, Qty_In_Stock__c from Part__c where Id In: partIdToCountAjustmentWrapperMap.keySet()]);
		
		List<PartCountAjustmentWrapper> partIncreaseCountAjustmentWrapperList = new List<PartCountAjustmentWrapper>();
		Map<Id, PartCountAjustmentWrapper> partIdToDecreaseCountAjustmentWrapperMap = new Map<Id, PartCountAjustmentWrapper>();
		
		for(PartCountAjustmentWrapper partCountAjustmentWrapperObj : partIdToCountAjustmentWrapperMap.values()) {
			if(partCountAjustmentWrapperObj.Qty > partIdToRecMap.get(partCountAjustmentWrapperObj.Id).Qty_In_Stock__c) {
 	 			partIdToDecreaseCountAjustmentWrapperMap.put(partCountAjustmentWrapperObj.Id, partCountAjustmentWrapperObj);
 	 		} else if(partCountAjustmentWrapperObj.Qty < partIdToRecMap.get(partCountAjustmentWrapperObj.Id).Qty_In_Stock__c){
 	 			partIncreaseCountAjustmentWrapperList.add(partCountAjustmentWrapperObj);
 	 		}
		}
		
 	 	Decimal maxPartAdjustCount = getMaxPartAdjustCount();
 	 	
        //Increased Qty FIFO creation
 	  	Set<String> partIdSet = new Set<String>();
 	  	List<Part_FIFO_Bucket__c> partFIFOBucketForIncreasedQtyList = new List<Part_FIFO_Bucket__c>();
   		for(PartCountAjustmentWrapper partObj : partIncreaseCountAjustmentWrapperList) {
   			maxPartAdjustCount += 1;
   			partIdSet.add(partObj.Id);
   			Decimal qtyToIncrease = partIdToRecMap.get(partObj.Id).Qty_In_Stock__c - partObj.Qty;
   			partFIFOBucketForIncreasedQtyList.add(setBucketFields(partObj.Id, qtyToIncrease, partObj.Cost, maxPartAdjustCount, true, 'Stock Count', 'Count Adjustment'));
   		}
        
		//Decreased Qty get FIFO buckets
   		Map<Id, List<Part_FIFO_Bucket__c>> partIdToFIFOBucketListMap = new Map<Id, List<Part_FIFO_Bucket__c>>();
   		if(partIdToDecreaseCountAjustmentWrapperMap.size() > 0) {
   			List<Part_FIFO_Bucket__c> partFIFOBucketToUpdateList = SOQLUtil.getPartFIFOBucketByPartList(partIdToDecreaseCountAjustmentWrapperMap.keySet());
   			for(Part_FIFO_Bucket__c partFIFOBucketRec : partFIFOBucketToUpdateList) {
   				if(!partIdToFIFOBucketListMap.containsKey(partFIFOBucketRec.Part__c)) {
   					partIdToFIFOBucketListMap.put(partFIFOBucketRec.Part__c, new List<Part_FIFO_Bucket__c>());
   				}
   				partIdToFIFOBucketListMap.get(partFIFOBucketRec.Part__c).add(partFIFOBucketRec);
   			}
   		}
   		//Decreased Qty FIFO creation
   		Map<Id, Part_FIFO_Bucket__c> partIdToDecreasedFIFOBucketRecMap = new Map<Id, Part_FIFO_Bucket__c>();
   		for(PartCountAjustmentWrapper partObj : partIdToDecreaseCountAjustmentWrapperMap.values()) {
   			if(partIdToFIFOBucketListMap.containsKey(partObj.Id)) {
   				maxPartAdjustCount += 1;
	   			partIdSet.add(partObj.Id);
	   			partIdToDecreasedFIFOBucketRecMap.put(partObj.Id, setBucketFields(partObj.Id, 0, 0, maxPartAdjustCount, false, 'Stock Adjust', 'Stock Adjustment'));
   			}
   		}
   		
   		List<Part_FIFO_Bucket__c> partFIFOBucketList = new List<Part_FIFO_Bucket__c>(partFIFOBucketForIncreasedQtyList);
   		if(partIdToDecreasedFIFOBucketRecMap.values().size() > 0) {
   			partFIFOBucketList.addAll(partIdToDecreasedFIFOBucketRecMap.values());
   		}
 	  	if(partFIFOBucketList.size() > 0) {
   			insert partFIFOBucketList;
   		}
		
        //Decreased Qty FIFO Bucket LI creation
		List<Part_FIFO_Bucket_Activity_Line_Item__c> fifoActivityLIList = new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
		for(PartCountAjustmentWrapper partObj : partIdToDecreaseCountAjustmentWrapperMap.values()) {
   			if(partIdToFIFOBucketListMap.containsKey(partObj.Id)) {
   				if(partIdToDecreasedFIFOBucketRecMap.containsKey(partObj.Id)) {
   					Decimal qtyToDecrease = partObj.Qty - partIdToRecMap.get(partObj.Id).Qty_In_Stock__c;
	   				List<Part_FIFO_Bucket_Activity_Line_Item__c> bucketActivityLIList = decreaseAdjustInStock(partObj.Id, qtyToDecrease, partIdToDecreasedFIFOBucketRecMap.get(partObj.Id).Id, partIdToFIFOBucketListMap.get(partObj.Id));
   				
   					if(bucketActivityLIList.size() > 0) {
   						fifoActivityLIList.addAll(bucketActivityLIList);
			 	  	}
   				}
   			}
   		}
		
		if(fifoActivityLIList.size() > 0) {
			insert fifoActivityLIList;
 	  	}
 	  	//To prevent trigger from rerun
 	  	PartTriggerHelper.isPreventOnDataLoad = true;
   		FIFOTransaction.updatePartInStock(new List<String>(partIdSet));
   		return partFIFOBucketList;
    }
    
    public static Part_FIFO_Bucket__c setBucketFields(String partId, Decimal qtyIn, Decimal cost, Decimal adjustmentNumber, Boolean isBucket, String sourceName, String reference) {
 	  	Part_FIFO_Bucket__c partBucketRec = new Part_FIFO_Bucket__c();
 	  	partBucketRec.Source_Name__c = sourceName;			
 	  	partBucketRec.Part_Adjust_Number__c = adjustmentNumber;
 	  	partBucketRec.Reference__c = reference;
 	  	partBucketRec.Qty_In__c = qtyIn;
 	  	partBucketRec.Cost__c = cost;
		partBucketRec.VRCost__c = cost;
 	  	partBucketRec.Part__c = partId;
 	  	partBucketRec.Is_FIFO_Bucket__c = isBucket;
 	  	return partBucketRec;
   	}
   
   	public static Decimal getMaxPartAdjustCount() {
   		Decimal maxPartAdjustCount = 0;
 		List<Part_FIFO_Bucket__c> existingPartBucketList = [select Part_Adjust_Number__c from Part_FIFO_Bucket__c order by Part_Adjust_Number__c DESC NULLS LAST limit 1];
 	  	if(existingPartBucketList.size() > 0) {
 	  		maxPartAdjustCount = (existingPartBucketList[0].Part_Adjust_Number__c != null) ? existingPartBucketList[0].Part_Adjust_Number__c : 0;
 	  	}
 	  	return maxPartAdjustCount;
   	}
   	
   	public static List<Part_FIFO_Bucket_Activity_Line_Item__c> decreaseAdjustInStock(String partId, Decimal qty, Id fifoBucketId, List<Part_FIFO_Bucket__c> partFIFORecList) {
   		List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketLineItemList =  new List<Part_FIFO_Bucket_Activity_Line_Item__c>();
   		
   		for(Part_FIFO_Bucket__c partBucketRec : partFIFORecList) {
 	  		if(qty > 0) {
	 	  		Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineItemRec = new Part_FIFO_Bucket_Activity_Line_Item__c();
	 	  		partActivityLineItemRec.Part_Adjustment__c = fifoBucketId;
	 	  		partActivityLineItemRec.Part_FIFO_Bucket__c = partBucketRec.Id;
	 	  		partActivityLineItemRec.Reference__c = 'Count Adjustment';
 	  			if((qty - partBucketRec.Remaining_Qty__c) > 0) {
 	  				partActivityLineItemRec.Qty_Out__c = partBucketRec.Remaining_Qty__c;
 	  			} else {
 	  				partActivityLineItemRec.Qty_Out__c = qty;
 	  			}
 	  			qty -= partActivityLineItemRec.Qty_Out__c;
 	  			partFIFOBucketLineItemList.add(partActivityLineItemRec);
 	  		} 
 	  	}
 	  	return partFIFOBucketLineItemList;
   	}
   	
   	public class PartCountAjustmentWrapper {
   		public String Id;
   		public Decimal Qty;
   		public Decimal Cost;
   		
   		public PartCountAjustmentWrapper(String partId, Decimal qtyIn, Decimal cost) {
   			this.Id = partId;
   			this.Qty = qtyIn;
   			this.Cost = cost;
   		}
   	}
}