/**
 * Author: Hitesh Gupta
 * Since: Oct 16, 2017
 * Name: PartAlternateTriggerHelper
 * Description: Helper class for triggers on Part Alternate object
**/
public with sharing class PartAlternateTriggerHelper {
    
    // List to store trigger new list
    public static List<Part_Alternates__c> PartAlternateNewList = new List<Part_Alternates__c>();
    
    // List to store trigger old list
    public static List<Part_Alternates__c> PartAlternateOldList = new List<Part_Alternates__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Part_Alternates__c> PartAlternateNewMap = new Map<Id, Part_Alternates__c>();

    // Map to store Old Trigger Map
    public static Map<Id, Part_Alternates__c> PartAlternateOldMap = new Map<Id, Part_Alternates__c>();
    
     /**
     * Name: populatePartRelationUniqueCheck
     * Desc: When Part Alternate record is inserted or updated this method executes 
     * @param: 
     * @return: 
    **/
    public static void validatiePartSelfRelation() {
    	for(Part_Alternates__c partAlternate : PartAlternateNewList){
    		if(partAlternate.Part_ID__c == partAlternate.Alternate_Part_ID__c){
    			partAlternate.addError('Part itself cannot have relation');
    		}
    	}
    }
    
    public static void populatePartRelationUniqueCheck() {
    	for(Part_Alternates__c partAlternate : PartAlternateNewList){
    		partAlternate.Part_Relation_Unique_Check__c = partAlternate.Part_ID__c + ' - ' +partAlternate.Alternate_Part_ID__c;
    	}
    }
    
    
    
    /**
     * Name: populateAlternatePartsCounter
     * Desc: Populate the couner of the alternate part of the package Part.
     * @param: 
     * @return: 
    **/
    /*
    public static void populateAlternateValidation(){
    	Set<Id> partAlternatePartIds = new Set<Id>();
    	for(Part_Alternates__c partAlternate : PartAlternateNewList){
    		partAlternatePartIds.add(partAlternate.Part_ID__c);
    	}
    	List<Part_Alternates__c> partAlternateList = [select Part_ID__c, Alternate_Part_ID__c, Relation__c	
    													from Part_Alternates__c
    													where Part_ID__c = :partAlternatePartIds];
    													
    	Map<Id, List<Part_Alternates__c>> partIdToAlternatePartsMap = new Map<Id, List<Part_Alternates__c>>();
    	for(Part_Alternates__c p : partAlternateList){
    		if(!partIdToAlternatePartsMap.containsKey(p.Part_ID__c)){
    			partIdToAlternatePartsMap.put(p.Part_ID__c, new List<Part_Alternates__c>());
    		}
    		partIdToAlternatePartsMap.get(p.Part_ID__c).add(p);
    	}
    	for(Part_Alternates__c partAlternate : PartAlternateNewList){
    		if(partAlternate.Part_ID__c == partAlternate.Alternate_Part_ID__c){
    			partAlternate.addError('Part itself cannot have the relation');
    		}else if(partIdToAlternatePartsMap.containsKey(partAlternate.Part_ID__c)){
    			for(Part_Alternates__c p : partIdToAlternatePartsMap.get(partAlternate.Part_ID__c)){
    				if(partAlternate.Alternate_Part_ID__c == p.Alternate_Part_ID__c){
    						partAlternate.addError('Part Relation already Exist');
    						break;
    				}
    			}
    		}
    	}
    }
    */
}