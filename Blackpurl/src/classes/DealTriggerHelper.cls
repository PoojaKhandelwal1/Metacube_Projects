public with sharing class DealTriggerHelper {
	// List to store trigger new list
    public static List<Deal__c> dealNewList = new List<Deal__c>();
    
    // List to store trigger old list
    public static List<Deal__c> dealOldList = new List<Deal__c>();
    
    // Map to store new Trigger Map
    public static Map<Id, Deal__c> dealNewMap = new Map<Id, Deal__c>();
    
    // Map to store Old Trigger Map
    public static Map<Id, Deal__c> dealOldMap = new Map<Id, Deal__c>();
    
    // Accounting boolean
    public static Boolean preventOnAccountingSync = false;
    

    private static BaseIntegrationService integrationRec;

	public static void beforeInsertOperation() {
    	validateDealInsertion();
    }
    
    public static void validateDealInsertion() {
    	Set<String> coHeaderIdSet = new Set<String>();
    	for(Deal__c dealRec : dealNewList) {
    		coHeaderIdSet.add(dealRec.CO_Header__c);
    	}
    	coHeaderIdSet.remove(null);
    	Map<String, CO_Header__c> coHeaderIdToRecMap = new Map<String, CO_Header__c>([Select Id from CO_Header__c where Id IN :coHeaderIdSet 
    																AND Id IN (Select CO_Header__c from Deal__c where CO_Header__c IN : coHeaderIdSet)]);
    	for(Deal__c dealRec : dealNewList) {
    		if(String.isNotBlank(dealRec.CO_Header__c) && coHeaderIdToRecMap.containsKey(dealRec.CO_Header__c)) {
    			dealRec.addError('Deal already exists for this order');
    		}
    	}
    }
    
    public static void populatesAccountingSyncFields() {
        if(QBUtil.isQBEnabled()) {
            QBSyncFlagService.manageLienPayoutSyncFlag(dealNewList, dealOldMap);
        } else {
            try {
               integrationRec = IntegrationServiceFactory.getIntegrationServiceInstance('Accounting');
               IntegrationSyncFlagService.manageLienPayoutSyncFlag(new List<BaseIntegrationService>{integrationRec}, dealNewList, dealOldMap);
            } catch(Exception e) {
            }
        }
    }
    
    public static void populateDealCountFieldOnCO() {
    	
    	Set<Id> coHeaderIdSet = new Set<Id>();
    	
    	for(Deal__c dealRec: dealNewList) {
    		coHeaderIdSet.add(dealRec.CO_Header__c);
    	}
    	
    	//List<AggregateResult> abc = [select CO_Header__c, COUNT(Id) total from Deal__c where CO_Header__c IN :coHeaderIdSet group by CO_Header__c ];
    	//system.assert(false, abc);
    	if(coHeaderIdSet.size() > 0) {
	    	Map<Id, AggregateResult> COHeaderIdToDealCountMap = new Map<Id, AggregateResult>([select CO_Header__c Id, COUNT(Id) total from Deal__c where CO_Header__c IN :coHeaderIdSet group by CO_Header__c ]);
	    	//system.assert(false, COHeaderIdToDealCountMap);
	    	List<CO_Header__c> coHeaderListToUpdate = new List<CO_Header__c>();
	    	
	    	for(Id coHeaderId: COHeaderIdToDealCountMap.keySet()) {
	    		CO_Header__c coHeaderRec = new CO_Header__c();
	    		coHeaderRec.Id = coHeaderId;
	    		coHeaderRec.NumberOfDeals__c = (Decimal)(COHeaderIdToDealCountMap.get(coHeaderId).get('total'));
	    		coHeaderListToUpdate.add(coHeaderRec);
	    	}
	    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    	update coHeaderListToUpdate;
    	}
    }
    
    public static void populateDealCountFieldOnCOOnDelete() {
    	
    	Set<Id> coHeaderIdSet = new Set<Id>();
    	Map<Id, Integer> coHeaderToDeletedDealCountMap = new Map<Id, Integer>();
    	Integer NumberOfDeletedDeals = 1;
    	
    	for(Deal__c dealRec: dealOldList) {
    		coHeaderIdSet.add(dealRec.CO_Header__c);
    		if(coHeaderToDeletedDealCountMap.containsKey(dealRec.CO_Header__c)) {
    			Integer dealCount = coHeaderToDeletedDealCountMap.get(dealRec.CO_Header__c) + 1;
    			coHeaderToDeletedDealCountMap.put(dealRec.CO_Header__c, dealCount);
    		} else {
    			coHeaderToDeletedDealCountMap.put(dealRec.CO_Header__c, NumberOfDeletedDeals);
    		}
    	}
    	//system.assert(false, coHeaderToDeletedDealCountMap);
    	
    	//List<AggregateResult> abc = [select CO_Header__c, COUNT(Id) total from Deal__c where CO_Header__c IN :coHeaderIdSet group by CO_Header__c ];
    	//system.assert(false, abc);
    	if(coHeaderIdSet.size() > 0) {
    		Map<Id, AggregateResult> COHeaderIdToDealCountMap = new Map<Id, AggregateResult>([select CO_Header__c Id, COUNT(Id) total from Deal__c where CO_Header__c IN :coHeaderIdSet group by CO_Header__c ]);
	    	//system.assert(false, COHeaderIdToDealCountMap);
	    	List<CO_Header__c> coHeaderListToUpdate = new List<CO_Header__c>();
	    	
	    	for(Id coHeaderId: COHeaderIdToDealCountMap.keySet()) {
	    		Integer NumberOfDeletedDealsforCOHeader = coHeaderToDeletedDealCountMap.get(coHeaderId);
	    		CO_Header__c coHeaderRec = new CO_Header__c();
	    		coHeaderRec.Id = coHeaderId;
	    		coHeaderRec.NumberOfDeals__c = ((Decimal)(COHeaderIdToDealCountMap.get(coHeaderId).get('total')) - NumberOfDeletedDealsforCOHeader);
	    		coHeaderListToUpdate.add(coHeaderRec);
	    	}
	    	if(AccessControl.ifObjectFieldIsUpdateable('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
	    	update coHeaderListToUpdate;
    	}
    	
    	deleteRelatedCOForms();
    }
    
    private static void deleteRelatedCOForms() {
        Set<Id> dealIdSet = new Set<Id>();
        for(Deal__c dealRec : dealOldList) {
            dealIdSet.add(dealRec.Id);
        }
        dealIdSet.remove(null);
        
        COFormService.deleteCOFormUsingSectionId(dealIdSet);
    }
}
