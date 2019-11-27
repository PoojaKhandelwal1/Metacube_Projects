public without sharing class UnitMakeTriggerHelper {
    
    public static List<Unit_Make__c> unitMakeNewList = new List<Unit_Make__c>();
    public static List<Unit_Make__c> unitMakeOldList = new List<Unit_Make__c>();
    public static Map<Id, Unit_Make__c> unitMakeNewMap = new Map<Id, Unit_Make__c>();
    public static Map<Id, Unit_Make__c> unitMakeOldMap = new Map<Id, Unit_Make__c>();
    
    public static void checkForUniqueMake() {
    	Set<String> makeNameSet = new Set<String>();
    	for(Unit_Make__c unitMakeRec : unitMakeNewList) {
    		if(makeNameSet.contains((unitMakeRec.Name).toLowerCase())) {
    			unitMakeRec.addError('Duplicate make in list');
    		} else {
    			makeNameSet.add((unitMakeRec.Name).toLowerCase());
    		}
    	}
    	List<Unit_Make__c> unitMakeList = [Select Id, Name from Unit_Make__c where Name IN: makeNameSet];
    	Map<String, String> existingMakeNameToIdMap = new Map<String, String>();
    	for(Unit_Make__c unitMakeRec : unitMakeList) {
    		existingMakeNameToIdMap.put((unitMakeRec.Name).toLowerCase(), unitMakeRec.Id);
    	}
    	
    	for(Unit_Make__c unitMakeRec : unitMakeNewList) {
    		if(existingMakeNameToIdMap.containsKey((unitMakeRec.Name).toLowerCase()) && 
    				(String.isBlank(unitMakeRec.Id) || (unitMakeRec.Id != existingMakeNameToIdMap.get((unitMakeRec.Name).toLowerCase())))) {
    			unitMakeRec.addError('Make already exists');
    		}
    	}
    }
}