public with sharing class ReturnVOLITriggerHelper {
    // List to store trigger new list
    public static List<Return_VO_Line_Item__c> returnVOLINewList = new List<Return_VO_Line_Item__c>();
    
    // List to store trigger old list
    public static List<Return_VO_Line_Item__c> returnVOLIOldList = new List<Return_VO_Line_Item__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Return_VO_Line_Item__c> returnVOLINewMap = new Map<Id, Return_VO_Line_Item__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Return_VO_Line_Item__c> returnVOLIOldMap = new Map<Id, Return_VO_Line_Item__c>();
    
    public static void beforeUpdateOperation(){
    	validatePartAvailableQty();
    }
    
    public static void afterUpdateOperation(){
    	calculateVOLITotal(returnVOLINewList);
    	applyCommitLogic(returnVOLINewList);
    }
    
    public static void beforeDeleteOperation(){
    	calculateVOLITotal(returnVOLIOldList);
    	applyCommitLogic(returnVOLIOldList);
    }
    
    
    
    public static void validatePartAvailableQty(){
    	Set<Id> partIds = new Set<Id>();
    	for(Return_VO_Line_Item__c returnVOLIRec : returnVOLINewList){
    		partIds.add(returnVOLIRec.Part__c);
    	}
    	Map<Id, Part__c> partIdToPartMap = new Map<Id, Part__c>([select Id, AvailableParts__c from Part__c
    																where Id IN : partIds]);
    	Part__c partRec;
    	for(Return_VO_Line_Item__c returnVOLIRec : returnVOLINewList){
    		if(partIdToPartMap.containsKey(returnVOLIRec.Part__c)){
    			partRec = partIdToPartMap.get(returnVOLIRec.Part__c);
    			if(returnVOLIRec.Return_Qty__c == null){
    				returnVOLIRec.Return_Qty__c = 0;
    			}
    			Decimal qtyDiff = 0;
    			if(returnVOLIRec.Return_Qty__c != null){
    				qtyDiff = returnVOLIRec.Return_Qty__c;
    			}
    			if(Trigger.isUpdate){
    				qtyDiff = returnVOLIRec.Return_Qty__c - returnVOLIOldMap.get(returnVOLIRec.Id).Return_Qty__c; 
    			}
    			if(qtyDiff > partRec.AvailableParts__c){
    				returnVOLIRec.Return_Qty__c = returnVOLIOldMap.get(returnVOLIRec.Id).Return_Qty__c + partRec.AvailableParts__c;
    			}
    		} 
    	}
    }
    
    public static void calculateVOLITotal(List<Return_VO_Line_Item__c> updatedVOLI){
    	Set<String> returnVOIdSet = new  Set<String>();
    	for(Return_VO_Line_Item__c returnVOLIRec : updatedVOLI){
    		returnVOIdSet.add(returnVOLIRec.Return_VO_Header__c);
    	}
    	List<Return_VO_Header__c> returnVORecList =  [ Select Id, SubTotal__c, Vendor__r.Purchase_Tax__r.Rate__c,
    													 (Select Id, Item_Cost__c, Return_Qty__c FROM Return_VO_Line_Items__r )
    													 FROM Return_VO_Header__c where Id IN :  returnVOIdSet];
    	//system.assert(false,returnVORecList);
    	for(Return_VO_Header__c returnVOHRec : returnVORecList){
    		returnVOHRec.SubTotal__c = 0;
    		for(Return_VO_Line_Item__c returnVOLIRec : returnVOHRec.Return_VO_Line_Items__r){
				if(returnVOLIRec.Item_Cost__c == null ){
					returnVOLIRec.Item_Cost__c = 0;
				}
				if(returnVOLIRec.Return_Qty__c == null){
					returnVOLIRec.Return_Qty__c = 0 ;
				}
    			returnVOHRec.SubTotal__c +=  (returnVOLIRec.Item_Cost__c * returnVOLIRec.Return_Qty__c);
    		}
    		returnVOHRec.Tax__c = 0;
    		if(returnVOHRec.Vendor__r.Purchase_Tax__r.Rate__c != null){
    			returnVOHRec.Tax__c = (returnVOHRec.SubTotal__c * returnVOHRec.Vendor__r.Purchase_Tax__r.Rate__c)/100;
    		}
    		returnVOHRec.Total__c = -1*(returnVOHRec.SubTotal__c + returnVOHRec.Tax__c);
    	}
    	if(returnVORecList.size() > 0){
    		update returnVORecList;
    	}
    }
    
    
    public static void applyCommitLogic(List<Return_VO_Line_Item__c> updatedVOLI){
    	Set<Id> partIds = new Set<Id>();
    	for(Return_VO_Line_Item__c returnVOLIRec : updatedVOLI){
    		partIds.add(returnVOLIRec.Part__c);
    	}
    	Map<Id, Part__c> partIdToPartMap = new Map<Id, Part__c>([select Id, AvailableParts__c, Qty_Committed__c from Part__c
    																where Id IN : partIds]);
    	Part__c partRec;
    	for(Return_VO_Line_Item__c returnVOLIRec : updatedVOLI){
    		if(partIdToPartMap.containsKey(returnVOLIRec.Part__c)){
    			partRec = partIdToPartMap.get(returnVOLIRec.Part__c);
    			Decimal commitDifference = 0;
    			if(returnVOLIRec.Return_Qty__c != null){
    				commitDifference = returnVOLIRec.Return_Qty__c;
    			}
    			if(Trigger.isUpdate){
    				commitDifference = returnVOLIRec.Return_Qty__c - returnVOLIOldMap.get(returnVOLIRec.Id).Return_Qty__c; 
    			}
    			if(Trigger.isDelete){
    				commitDifference = -1 * commitDifference; 
    			}
    			if(partRec.Qty_Committed__c == null){
    				partRec.Qty_Committed__c = 0;
    			}
    			partRec.Qty_Committed__c += commitDifference; 
    		} 
    	}
    	if(partIdToPartMap.values().size() > 0){
    		upsert partIdToPartMap.values();
    	}
    	
    }
}