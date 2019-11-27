public class PartFIFOBucketTriggerHelper {
	
	public static List<Part_FIFO_Bucket__c> partFIFOBucketNewList = new List<Part_FIFO_Bucket__c>();
    public static List<Part_FIFO_Bucket__c> partFIFOBucketOldList = new List<Part_FIFO_Bucket__c>();
    public static Map<Id, Part_FIFO_Bucket__c> partFIFOBucketNewMap = new Map<Id, Part_FIFO_Bucket__c>();
    public static Map<Id, Part_FIFO_Bucket__c> partFIFOBucketOldMap = new Map<Id, Part_FIFO_Bucket__c>();
    
    // Trigger run boolean: Added by Pooja 9 Jan. 2017 (QB Integration)
    public static Boolean preventOnAccountingSync = false;
    private static BaseIntegrationService integrationRec;
    
    private static Set<Id> partIdSet = new Set<Id>();
    
	public static void afterInsertCalculation() {
		getPartIdListToUpdate(partFIFOBucketNewList);
	}
	
	public static void afterUpdateCalculation() {
		getPartIdListToUpdate(partFIFOBucketNewList);
	}
	
	public static void getPartIdListToUpdate(List<Part_FIFO_Bucket__c> partFIFOBucketList) {
		for(Part_FIFO_Bucket__c partFIFOBucketObj : partFIFOBucketList) {
			//if(partFIFOBucketObj.Source_Name__c != null && partFIFOBucketObj.Source_Name__c == 'Oversold') {
				if(partFIFOBucketObj.Part__c != null) {
					partIdSet.add(partFIFOBucketObj.Part__c);	
				}
				
				if(trigger.isUpdate) {
					Part_FIFO_Bucket__c oldpartFIFOBucket = partFIFOBucketOldMap.get(partFIFOBucketObj.Id);
					if(oldpartFIFOBucket.Part__c != null && oldpartFIFOBucket.Part__c != partFIFOBucketObj.Part__c) {
						partIdSet.add(oldpartFIFOBucket.Part__c);
					}
				}
			//}
		}
		updatePartList();
	}
	
	public static void populateInStockWhenCreated() {
    	Set<String> partIdSet = new Set<String>();
    	for(Part_FIFO_Bucket__c fifoRec : partFIFOBucketNewList) {
    		partIdSet.add(fifoRec.Part__c);
    	}
    	if(system.isBatch() || system.isFuture()) {
    		String partStrQuery = 'SELECT Id, (Select Id, CreatedDate, Cost__c, Qty_In__c, Qty_In_Stock_When_Created__c, Average_Cost_When_Created__c ' +
        	'FROM Part_FIFO_Buckets__r WHERE Is_FIFO_Bucket__c = true Order By CreatedDate ASC) FROM Part__c where Id IN: partIdSet Order By CreatedDate ASC';
	        List<Part__c> partList = Database.query(partStrQuery);
	    	FIFOTransaction.updatePartFIFODetails(partList);
    	} else if(!Test.isRunningTest()) {
    		Database.executeBatch(new SetQtyAndAvgCostOnFIFOBktAndLIBatch(partIdSet), 1);
    	}
    }
    
	public static void updatePartList() {
		//START : Modified by Nidhi - Ticket #1280 - 11-11-2016
		List<Part__c> partList = [Select Id, Oversold_Qty__c, Oversold_Cost__c, Total_Cost__c, Average_Cost__c, (Select id, Qty_In__c, Qty_Out__c, Total__c, Source_Name__c, Remaining_Qty__c from Part_FIFO_Buckets__r) from Part__c where Id In :partIdSet];
		
		/**
		for(Part__c partRec : partList) {
			Decimal oversoldQty = 0;
			Decimal oversoldCost = 0;
			for(Part_FIFO_Bucket__c partFIFOBucketRec : partRec.Part_FIFO_Buckets__r) {
				oversoldQty += ((partFIFOBucketRec.Qty_In__c != null) ? partFIFOBucketRec.Qty_In__c : 0.00) - ((partFIFOBucketRec.Qty_Out__c != null) ? partFIFOBucketRec.Qty_Out__c : 0.00);
				oversoldCost += (partFIFOBucketRec.Total__c != null) ? partFIFOBucketRec.Total__c : 0.00;
			}
			partRec.Oversold_Qty__c = oversoldQty;
			partRec.Oversold_Cost__c = oversoldCost;
		}
		*/
		for(Part__c partRec : partList) {
			Decimal oversoldQty = 0;
			Decimal oversoldCost = 0;
			Decimal TotalCost = 0;
			Decimal QtyInStock = 0;
			for(Part_FIFO_Bucket__c partFIFOBucketRec : partRec.Part_FIFO_Buckets__r) {
				if(!String.isBlank(partFIFOBucketRec.Source_Name__c) && (partFIFOBucketRec.Source_Name__c.equalsIgnoreCase('Oversold') || partFIFOBucketRec.Remaining_Qty__c < 0)){
					oversoldQty += ((partFIFOBucketRec.Qty_In__c != null) ? partFIFOBucketRec.Qty_In__c : 0.00) - ((partFIFOBucketRec.Qty_Out__c != null) ? partFIFOBucketRec.Qty_Out__c : 0.00);
					oversoldCost += (partFIFOBucketRec.Total__c != null) ? partFIFOBucketRec.Total__c : 0.00;
				} else {
	    			TotalCost  += (partFIFOBucketRec.Total__c != null ) ? partFIFOBucketRec.Total__c : 0.00;
	    			QtyInStock += (partFIFOBucketRec.Remaining_Qty__c != null ) ? partFIFOBucketRec.Remaining_Qty__c : 0;
    			}
			}
			//changed by anurag
			//partRec.Oversold_Qty__c = oversoldQty;
			//partRec.Oversold_Cost__c = oversoldCost;
			partRec.Oversold_Qty__c = oversoldQty < 0 ? -(oversoldQty) : oversoldQty;
			partRec.Oversold_Cost__c = oversoldCost < 0 ? -(oversoldCost) : oversoldCost;
			partRec.Total_Cost__c = TotalCost;
			
	        partRec.Average_Cost__c = (QtyInStock > 0) ? (TotalCost / QtyInStock) : 0.00;
		}
		//END : Modified by Nidhi - Ticket #1280 - 11-11-2016
		update partList;
	}
	
	
	// Start: Added by Pooja 9 Jan. 2017 (QB Integration)
    public static void populatesAccountingSyncFields(){
        if(QBUtil.isQBEnabled()) {
			partFIFOBucketNewList = QBSyncFlagService.managePartFIFOBucketSyncFlag(partFIFOBucketNewList);
		} else {
        	integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
        	if(integrationRec != null) {
        		if(trigger.isInsert) {
	                IntegrationSyncFlagService.managePartFIFOBucketSyncFlag(new List<BaseIntegrationService>{integrationRec}, partFIFOBucketNewList);
	            }
        	} 
		}
    }
    
    public static void setPartFIFOBucketDataForAccountSync(){
        Set<Id> setPartFIFOBucketIds = new Set<Id>();
        for(Part_FIFO_Bucket__c partFIFOBucketRec : partFIFOBucketNewList){ 
                if(QBUtil.isQBEnabled()) {
	    	    	if(partFIFOBucketRec.availForQBSync__c) {
	    	        	setPartFIFOBucketIds.add(partFIFOBucketRec.Id);
	    	    	}
	    	    } else if(integrationRec != null) {
	    	    	if(partFIFOBucketRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.PART_FIFO).Sync_Flag_API_Name__c) != null && 
	    	    			Boolean.valueOf(partFIFOBucketRec.get(integrationRec.integrationEntityNameToRecMap.get(IntegrationUtility.PART_FIFO).Sync_Flag_API_Name__c))) {
	    	        	setPartFIFOBucketIds.add(partFIFOBucketRec.Id);
	    	        
	    	    	}
	    	    }
        }
        
        if(setPartFIFOBucketIds.size() > 0) {
            if(QBUtil.isQBEnabled()) {
    			FIFOBucketService.syncPartFIFOBuckets(setPartFIFOBucketIds);
    		} else {
    			IntegrationBatchService.initiateBatch(setPartFIFOBucketIds, new List<BaseIntegrationService>{integrationRec}, IntegrationUtility.PART_FIFO);
    		}
        }
    }
    // End: Added by Pooja 9 Jan. 2017 (QB Integration)
}
