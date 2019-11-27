/**
 * Author: Gourav Goyal
 * Since: Dec 27, 2017
 * Name: PartSyncAgeBatch_Schedular
 * Description: Apex class to schedule PartSyncAgeBatch_Schedular .
**/

global with sharing class PartSyncAgeBatch_Schedular implements Database.Batchable<sobject>, Database.Stateful, Schedulable {
	public List<Part__c> partListToUpdate;
	public String strQuery;
	private List<String> partAgingConfigFieldList = new List<String> {'Period_1__c', 'Period_2__c', 'Period_3__c', 'Period_4__c'};
    private List<String> partAgingQtyFieldList = new List<String> {'PRD1Qty__c', 'PRD2Qty__c', 'PRD3Qty__c', 'PRD4Qty__c'};
    private List<String> partAgingCostFieldList = new List<String> {'PRD1Cost__c', 'PRD2Cost__c', 'PRD3Cost__c', 'PRD4Cost__c'};
	
	
	public static String getBaseQuery(){
        String baseQuery = 'SELECT Id, (SELECT Age__c,Total__c, Remaining_Qty__c FROM Part_FIFO_Buckets__r where Remaining_Qty__c > 0) from part__c where Id IN (Select Part__c from Part_FIFO_Bucket__c where Remaining_Qty__c > 0)'; 
        return baseQuery;
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc){
		partListToUpdate = new List<Part__c>();
    	if(String.isBlank(strQuery)){
	    	strQuery = getBaseQuery();
    	}
        return Database.getQueryLocator(strQuery); 
    }
    
    global void execute(Database.batchableContext bc, List<Part__c> listParts) {
    	Part_Aging_Period__c partAgingConfigObj = Part_Aging_Period__c.getOrgDefaults();
    	Map<Integer, List<Decimal>> periodToAgingValuesMap = new Map<Integer, List<Decimal>>();
        
        for(Part__c part : listParts) {
        	for(Integer counter = 0; counter < partAgingConfigFieldList.size() ; counter++) {
        		periodToAgingValuesMap.put(counter+1, new List<Decimal>{0, 0, 0});
        	}
	    	
        	for(Part_FIFO_Bucket__c partFifoBucket : part.Part_FIFO_Buckets__r) {
        		//system.assert(false,partFifoBucket);
        		for(Integer i = 0; i < partAgingConfigFieldList.size(); i++) {
    				if(partFifoBucket.Age__c != null && partAgingConfigObj.get(partAgingConfigFieldList[i]) != null && 
    					(i == partAgingConfigFieldList.size() - 1 || partFifoBucket.Age__c <= Decimal.valueOf(String.valueOf(partAgingConfigObj.get(partAgingConfigFieldList[i]))))) {
	        			List<Decimal> agingValueList = periodToAgingValuesMap.get(i+1);
	        			agingValueList[0] += partFifoBucket.Remaining_Qty__c;
	        			agingValueList[1] += (partFifoBucket.Total__c);
	        			//system.assert(false,agingValueList);
	        			break;
        			}
    			}
        	}
        	
        	for(Integer periodValue : periodToAgingValuesMap.keyset()) {
        		List<Decimal> agingValueList = periodToAgingValuesMap.get(periodValue);
        		part.put(partAgingQtyFieldList[periodValue - 1], agingValueList[0]);
        		part.put(partAgingCostFieldList[periodValue - 1], agingValueList[1]);
        	}
        	partListToUpdate.add(part);
        }
    } 
    
    global void finish(Database.batchableContext bc){
    	if(partListToUpdate.size() > 0){
    		update partListToUpdate;
    	}
    }
    
    global void execute(SchedulableContext SC) {
		Database.executeBatch(new PartSyncAgeBatch_Schedular(), 200);
		
	}
}