trigger PartFIFOBucketTrigger on Part_FIFO_Bucket__c (after insert, after update, before insert, before update) {
	
	PartFIFOBucketTriggerHelper.partFIFOBucketNewList = Trigger.new;
    PartFIFOBucketTriggerHelper.partFIFOBucketOldList = Trigger.old;
    PartFIFOBucketTriggerHelper.partFIFOBucketNewMap = Trigger.newMap;
    PartFIFOBucketTriggerHelper.partFIFOBucketOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('PartFIFOBucketTrigger');
    
    if(Trigger.isAfter && trigger.isInsert && !utilObj.insertDisabled()) {
    	PartFIFOBucketTriggerHelper.populateInStockWhenCreated();
    }
	
    if(system.isBatch()){
        return;
    }
    
    if(Trigger.isBefore) {
        if(trigger.isInsert && !utilObj.insertDisabled()) { //  || Trigger.isUpdate Changed 25/01/2017
            PartFIFOBucketTriggerHelper.populatesAccountingSyncFields();
        }
    }
    
    if(Trigger.isAfter) { 
        if(trigger.isInsert && !utilObj.insertDisabled()) {
	    	PartFIFOBucketTriggerHelper.afterInsertCalculation();
	    	if(!(PartFIFOBucketTriggerHelper.preventOnAccountingSync || System.isFuture())){
		    	PartFIFOBucketTriggerHelper.preventOnAccountingSync = true;
	            PartFIFOBucketTriggerHelper.setPartFIFOBucketDataForAccountSync();
	    	}
	    }
        if(trigger.isUpdate && !utilObj.updateDisabled()) {
	    	PartFIFOBucketTriggerHelper.afterUpdateCalculation();
	    }
    }
}
