/*
    Apex batch class to import supersession part number information and to create alternate part records
*/
global with sharing class ImportSupersessionPart_Batch implements Database.Batchable<sobject>, Database.Stateful {

    public String baseQuery;
    public List<String> partIdList;
    public ImportSupersessionPart_Batch(){
       
    }
    public ImportSupersessionPart_Batch(List<String> partIdList, Integer batchSize){
        ImportSupersessionPart_Batch clsPartBatch = new ImportSupersessionPart_Batch();
        clsPartBatch.partIdList = partIdList;
        Id batchstart = Database.executeBatch(clsPartBatch, batchSize);
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        baseQuery = 'SELECT Id, Part_Number__c, Replaced_By_Part__c, Replaces_Part__c FROM Part__c WHERE Id IN :partIdList';
        return Database.getQueryLocator(baseQuery);
    } 

    global void execute(Database.batchableContext bc, List<Part__c> ImportedPartList) {
    	
    	Map<String, Id> partNumberToPartIdMap = createPartNumberToPartIdMap(ImportedPartList);
    	List<Part_Alternates__c> partsAlternateList = createPartsAlternate(ImportedPartList, partNumberToPartIdMap);
    	//system.assert(false, 'partsAlternate=======' + partsAlternateList);
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Part__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        Database.SaveResult[] insertResult = Database.insert(partsAlternateList, false); 
        
        Integer sucesscount = 0;
        Integer errorcount = 0; 
        for(Database.SaveResult result : insertResult){
             if (result.isSuccess()) {
             	sucesscount++;
             }else{
                errorcount++;   
             }
        }
        
        system.debug('insertResult == ' + insertResult + '\n sucesscount == ' + sucesscount + '\n errorcount == ' + errorcount);
        
    } 
 
    global void finish(Database.batchableContext bc){
    }
    
    global Map<String, Id> createPartNumberToPartIdMap(List<Part__c> ImportedPartList)	{
    	Set<String> supersededPartNumberSet = new Set<String>();
    	for(Part__c partRec: ImportedPartList)	{
    		if(partRec.Replaced_By_Part__c != null)	{
    			supersededPartNumberSet.add(partRec.Replaced_By_Part__c);
    		}
    		
    		if(partRec.Replaces_Part__c != null)	{
    			supersededPartNumberSet.add(partRec.Replaces_Part__c);
    		}
    	}
    	
    	List<Part__c> supersededPartList = [select Id, Part_Number__c from Part__c where Part_Number__c IN: supersededPartNumberSet];
    	
    	Map<String, Id> partNumberToPartIdMap = new Map<String, Id>();
    	for(Part__c partRec: supersededPartList)	{
    		partNumberToPartIdMap.put(partRec.Part_Number__c, partRec.Id);
    	}
    	return partNumberToPartIdMap;
    }
    
    global List<Part_Alternates__c> createPartsAlternate(List<Part__c> ImportedPartList, Map<String, Id> partNumberToPartIdMap)	{
    	List<Part_Alternates__c> partsAlternateList = new List<Part_Alternates__c>();
    	if(partNumberToPartIdMap != null)	{ 
    		for(Part__c partRec: ImportedPartList)	{
    			if(partRec.Replaces_Part__c != null && partNumberToPartIdMap.containsKey(partRec.Replaces_Part__c))	{
	    			partsAlternateList.add(setPartAlternateFields(partRec.Id, 'Replaces', partNumberToPartIdMap.get(partRec.Replaces_Part__c)));
    				partsAlternateList.add(setPartAlternateFields(partNumberToPartIdMap.get(partRec.Replaces_Part__c), 'Replaced By', partRec.Id));
	    		}
                
                if(partRec.Replaced_By_Part__c != null && partNumberToPartIdMap.containsKey(partRec.Replaced_By_Part__c))	{
    				partsAlternateList.add(setPartAlternateFields(partRec.Id, 'Replaced By', partNumberToPartIdMap.get(partRec.Replaced_By_Part__c)));
    				partsAlternateList.add(setPartAlternateFields(partNumberToPartIdMap.get(partRec.Replaced_By_Part__c), 'Replaces', partRec.Id));
	    		}
	    		
	    	}	
    	}
    	return partsAlternateList;
    }
    
    private Part_Alternates__c setPartAlternateFields(String partId, String relation, String alternatePartId) {
    	Part_Alternates__c partAlternateRec = new Part_Alternates__c(); 
    	partAlternateRec.Part_ID__c = partId;
		partAlternateRec.Relation__c = relation;
		partAlternateRec.Alternate_Part_ID__c = alternatePartId;
    	return partAlternateRec;
    }
    
}