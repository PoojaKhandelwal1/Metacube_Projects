/** 
* Author: Hitesh Gupta
* Since: Aug 29, 2017 
* Name: LinkedFeeController 
* Description: Apex class which contains all remoted methods related to Linked Fee Page.
**/
global with sharing class LinkedFeeController {
	
	global LinkedFeeController (NewHomePageCtrl controller){}
	public LinkedFeeController() {}
	 
	@RemoteAction
    global static String getLinkedFeeList(String FeeType){
    	FeeType = BPUtility.getDecodedString(FeeType);
    	
    	List<Linked_Fee__c> linkedFeeList = SOQLUtil.getLinkedFeeList(new Map<String, String>{'Related_To__c' => FeeType});
    	List<LinkedFeeWrapper> linkedFeeWrapperList = new List<LinkedFeeWrapper>();
    	for(Linked_Fee__c linkfee : linkedFeeList){
    		linkedFeeWrapperList.add(new LinkedFeeWrapper(linkfee)); 
    	}
    	return BPUtility.getEncodedString(System.JSON.serialize(linkedFeeWrapperList));
    }
    
    
     @RemoteAction
    global static String getOverViewDetails(){
    	Map<String, Integer> sectionNameToRecordsCountMap = new Map<String, Integer>{
    																'Deal' => 0, 
    																'Service Job' => 0, 
    																'Merchandise' => 0};
    	AggregateResult[] groupedResults = [select Related_To__c relatedTo, count(Id)
											from Linked_Fee__c 
											group by Related_To__c ];
		List<LinkedFeeWrapper.LinkedFeeOverviewWrapper> overViewList = new 	List<LinkedFeeWrapper.LinkedFeeOverviewWrapper>();	
		
		for(AggregateResult ar : groupedResults){
			sectionNameToRecordsCountMap.put(String.valueOf(ar.get('relatedTo')), Integer.valueOf(ar.get('expr0')));
		}	
		for(String sectionName : sectionNameToRecordsCountMap.keySet()){
			overViewList.add(new LinkedFeeWrapper.LinkedFeeOverviewWrapper(sectionName,
    																		sectionNameToRecordsCountMap.get(sectionName)));
		}				
    	return BPUtility.getEncodedString(System.JSON.serialize(overViewList));
    }
    
    @RemoteAction
    global static String saveLinkedFee(String linkedFeeJSON){
    	linkedFeeJSON = BPUtility.getDecodedString(linkedFeeJSON);
    	LinkedFeeWrapper linkedFeeWrapperObj = (LinkedFeeWrapper) System.JSON.deserialize(linkedFeeJSON, LinkedFeeWrapper.class);
        
        if(String.isNotBlank(linkedFeeWrapperObj.FeeId)){
        	Fee__c feeRecord = [select Id, Code__c, Description__c, Price__c 
        							from Fee__c 
        							where Id = :linkedFeeWrapperObj.FeeId];
        	
        	Linked_Fee__c oldLinkedFeeRec;
        	Linked_Fee__c linkedFeeObj = new Linked_Fee__c();
        	linkedFeeObj.Fee__c = linkedFeeWrapperObj.FeeId;
	        linkedFeeObj.Description__c = linkedFeeWrapperObj.FeeDescription;
	        linkedFeeObj.Price__c = linkedFeeWrapperObj.Price;
	        linkedFeeObj.Related_To__c = linkedFeeWrapperObj.RelatedTo;
	        
        	if(String.isNotBlank(linkedFeeWrapperObj.Id)){
        		oldLinkedFeeRec = [select Description__c, Price__c 
        											from Linked_Fee__c 
        											where Id = :linkedFeeWrapperObj.Id];
        											
        		linkedFeeObj.Id = linkedFeeWrapperObj.Id;
        		if(oldLinkedFeeRec == null && feeRecord.Description__c == linkedFeeWrapperObj.FeeDescription){
	        		linkedFeeObj.Description__c = null;
	        	}
	        	if(oldLinkedFeeRec == null && feeRecord.Price__c == linkedFeeWrapperObj.Price){
	        		linkedFeeObj.Price__c = null;
	        	}
        	}else{
	        	if(feeRecord != null){
		        	if(feeRecord.Description__c == linkedFeeWrapperObj.FeeDescription){
		        		linkedFeeObj.Description__c = null;
		        	}
		        	if(feeRecord.Price__c == linkedFeeWrapperObj.Price){
		        		linkedFeeObj.Price__c = null;
		        	}
		        }
        	}
	        upsert linkedFeeObj;
        }
        
    	return getLinkedFeeList(BPUtility.getEncodedString(linkedFeeWrapperObj.RelatedTo));
    }
    
    
    
    @RemoteAction
    global static String deleteLinkedFee(String linkedFeeId, String FeeType){
    	linkedFeeId = BPUtility.getDecodedString(linkedFeeId);
    	FeeType = BPUtility.getDecodedString(FeeType);
    	if(String.isNotBlank(linkedFeeId)){
    		Linked_Fee__c linkedFeeObj = new Linked_Fee__c();
    		linkedFeeObj.Id = linkedFeeId;
    		delete linkedFeeObj;
    	}
    	return getLinkedFeeList(BPUtility.getEncodedString(FeeType));
    }
    
    
    @RemoteAction
    global static String getFeeList(){
    	return BPUtility.getEncodedString(ViewFeeCtrl.getActiveFeeList('Linked Fee'));
    }
    
    
}