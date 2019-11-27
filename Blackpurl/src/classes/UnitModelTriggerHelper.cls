public with sharing class UnitModelTriggerHelper {
	
	public static List<Unit_Model__c> unitModelNewList = new List<Unit_Model__c>();
    public static List<Unit_Model__c> unitModelOldList = new List<Unit_Model__c>();
    public static Map<Id, Unit_Model__c> unitModelNewMap = new Map<Id, Unit_Model__c>();
    public static Map<Id, Unit_Model__c> unitModelOldMap = new Map<Id, Unit_Model__c>();
    
    public static void checkForUniqueModelBasedOnMake() {
    	
    	Map<String, Set<String>> makeIdToModelNameSetMap = new Map<String, Set<String>>();
    	for(Unit_Model__c unitModelRec : unitModelNewList) {
    		if(!makeIdToModelNameSetMap.containsKey(unitModelRec.Unit_Make__c)) {
    			makeIdToModelNameSetMap.put(unitModelRec.Unit_Make__c, new Set<String>{unitModelRec.Name__c});
    		} else if(makeIdToModelNameSetMap.get(unitModelRec.Unit_Make__c).contains(unitModelRec.Name__c)) {
    			unitModelRec.addError('Duplicate model for same make in list');
    		} else {
    			makeIdToModelNameSetMap.get(unitModelRec.Unit_Make__c).add(unitModelRec.Name__c);
    		}
    	}
    	
    	List<Unit_Make__c> makeList = [Select Id, Name, (Select Id, Name__c from Unit_Models__r) from Unit_Make__c where 
    		Id In: makeIdToModelNameSetMap.keySet()];
    	
    	Map<String, Map<String, String>> existingMakeIdToModelNameToIdMap = new Map<String, Map<String, String>>();
    	for(Unit_Make__c unitMakeRec : makeList) {
    		existingMakeIdToModelNameToIdMap.put(unitMakeRec.Id, new Map<String, String>());
    		for(Unit_Model__c unitModelRec : unitMakeRec.Unit_Models__r) {
    			existingMakeIdToModelNameToIdMap.get(unitMakeRec.Id).put((unitModelRec.Name__c).toLowerCase(), unitModelRec.Id);
    		}
    	}
    	
    	Set<String> newMakeNameSet = new Set<String>();
    	for(Unit_Model__c unitModelRec : unitModelNewList) {
    		if(existingMakeIdToModelNameToIdMap.get(unitModelRec.Unit_Make__c).containsKey((unitModelRec.Name__c).toLowerCase()) && (String.isBlank(unitModelRec.Id) || 
    			unitModelRec.Id != existingMakeIdToModelNameToIdMap.get(unitModelRec.Unit_Make__c).get((unitModelRec.Name__c).toLowerCase()))) {
    			unitModelRec.addError('Model name for this make already exists');
    		}
    	}
    }
}