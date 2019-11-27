/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */ 
/**
 * This InflAPIHandler class is  use to call influitive api from rest client.
 * This class is added as part of influitive integration
 * Created By: Narender Singh Tanwar
 * Modified by: Rekha @Feb 6 2017
 */
public with sharing class InflAPIHandler extends InflAPIAbstractHandler {
    
    private static final String CONTACT_ID = 'contact_id';
    private static final String STARTED_AT = 'start_at';
    private static final String CURSOR = 'cursor';
    public enum APIType { EVENT, REFERENCE }
    
    public InflAPIHandler() {   
        super();        
    }
    
   	/** 
   	 * This method is use to get Influitive Event(Aka Issue Reward in RefEdge) add them in Refedge if not exist 
     */
    public override Infl_EventsParser getInflEvents(Map<String, String> queryParams) {
        String apiURI = apiURL + EVENT_URI;
        Map<String, String> params = generateRequestParams(apiURI, HTTP_GET, null);
        params = setQueryParams(params, queryParams);
        
        if (Test.isRunningTest()) {
            params.put(API_TYPE, GET_EVENT);
        }
        String responseJson = execute(params);
        Infl_EventsParser response = null;
        
        try {
            response  = Infl_EventsParser.parse(responseJson);
        } catch(Exception e) {
            List<String> errorMessages = new List<String>();
            errorMessages.add('<b>LineNumber:'+e.getLineNumber() + ' Type: </b>' + e.getTypeName() + '<b> Message: </b>' + e.getStackTraceString());
            errorMessages.add('<br/><p><b>Root Cause: </b>' + responseJson + '</p>');
            sendInflExceptionEmail('Influitive API call getInflEvents error.', errorMessages);
        }
        return response;
    }
    
    /** 
   	 * This method is use to Create Influitive Event in influitive side when an reward will issue to contact in refedge.
     */
    public override InflCreateEventResponse createInflEvent(Infl_EventJSON inflEventRequest) {
        String request = Infl_EventJSON.serialize(inflEventRequest);
        String apiURI = apiURL + EVENT_URI;
        Map<String, String> params = generateRequestParams(apiURI, HTTP_POST, request);
        //REF-2300
        params.put(API_TYPE, CREATE_EVENT);
        String responseJson = execute(params);
        InflCreateEventResponse response = null;
        
        try {
        	response = InflCreateEventResponse.parse(responseJson);
        } catch(Exception e) {
        	
            if (!system.isBatch() && !system.isFuture()) {
                List<String> errorMessages = new List<String>();
                errorMessages.add('<b>LineNumber:' + e.getLineNumber() + ' Type: </b>' + e.getTypeName() + '<b> Message: </b>' + e.getStackTraceString());
                errorMessages.add('<br/><p><b>Root Cause: </b>' + responseJson + '</p>');
                sendInflExceptionEmail('Influitive API call createInflEvent  error.', errorMessages);
            }
        }
        return response;
    }

    /** 
   	 * This method is use to create Influitive Reference/Challenge in Influitive this will be called 
     * when a request complet or record referenc use created from Refedge. 
     */
    public override Infl_CreateReferenceResponse createInflReference(Infl_ReferenceJSON inflReferenceRequest) {
        String apiURI = apiURL + REFERENCE_URI;
        String request = Infl_ReferenceJSON.serialize(inflReferenceRequest);
        Map<String, String> params = generateRequestParams(apiURI, HTTP_POST, request);
        
        if (Test.isRunningTest()) {
            params.put(API_TYPE, CREATE_REFERENCE);
        }
        String responseJson = execute(params);
        Infl_CreateReferenceResponse response = null;
        
        try {
            response = Infl_CreateReferenceResponse.parse(responseJson);
       	} catch(Exception e) {
            List<String> errorMessages = new List<String>();
            errorMessages.add('<b>LineNumber:' + e.getLineNumber() + ' Type: </b>' + e.getTypeName() + '<b> Message: </b>' + e.getStackTraceString());
            errorMessages.add('<br/><p><b>Root Cause: </b>'+ responseJson + '</p>');
            sendInflExceptionEmail('Influitive API call createInflReference  error.', errorMessages);
        }
        return response;
    }
    
    //REF-1964
    public override Infl_CreateReferenceResponse changeInflReferenceChallengeStatus(String status, String challengeId, String publishRequestString) {
        String request = null;
        
        if (status == 'Publish') {
            status = PUBLISH_URI;
            
            if (publishRequestString != null) {
                request = publishRequestString;                
            }
        } else if (status == 'Unpublish') {
            status = UNPUBLISH_URI;
        } else if (status == 'Archive') {
            status = ARCHIVE_URI;
        } else if (status == 'Unarchive') {
            status = UNARCHIVE_URI;
        } 
        String apiURI = apiURL + CHALLENGE_URI + '/' + ChallengeId + status;
        Map<String,String> params = generateRequestParams(apiURI, HTTP_POST, request);
        String responseJson = execute(params);
        Infl_CreateReferenceResponse response = null;
        
        try {
            response = Infl_CreateReferenceResponse.parse(responseJson);
       	} catch(Exception e) {
            List<String> errorMessages = new List<String>();
            errorMessages.add('<b>LineNumber:' + e.getLineNumber() + ' Type: </b>' + e.getTypeName() + '<b> Message: </b>' + e.getStackTraceString());
            errorMessages.add('<br/><p><b>Root Cause: </b>'+ responseJson + '</p>');
            sendInflExceptionEmail('Influitive API call createInflReference  error.', errorMessages);
        }
        return response;
    }
    
    public Infl_CreateReferenceResponse getChallengeDetails(String ChallengeId) {
        String apiURI = apiURL + CHALLENGE_URI + '/' + ChallengeId + DETAILS_URI;
        Map<String,String> params = generateRequestParams(apiURI, HTTP_GET, null);
        String responseJson = execute(params);
        Infl_CreateReferenceResponse response = null;
        
        try {
            response = Infl_CreateReferenceResponse.parse(responseJson);
       	} catch(Exception e) {
            List<String> errorMessages = new List<String>();
            errorMessages.add('<b>LineNumber:' + e.getLineNumber() + ' Type: </b>' + e.getTypeName() + '<b> Message: </b>' + e.getStackTraceString());
            errorMessages.add('<br/><p><b>Root Cause: </b>'+ responseJson + '</p>');
            sendInflExceptionEmail('Influitive API call createInflReference  error.', errorMessages);
        }
        return response;  
    }
    
    /** 
   	 * This method is use to get Member information from Influitive.
     */
    public override Infl_MemberParser getMember(Map<String, String> queryParams) {
        String apiURI = apiURL + MEMBER_URI;
        Map<String, String> params = generateRequestParams(apiURI, HTTP_GET, null);
        params = setQueryParams(params, queryParams);
        
        if (Test.isRunningTest()) {
            params.put(API_TYPE, GET_MEMBER);
        }
        String responseJson = execute(params);
        List<Infl_MemberParser> response = null;
        
        try { 
            response = (List<Infl_MemberParser>) System.JSON.deserialize(responseJson, List<Infl_MemberParser>.class);
        } catch(Exception e) {
        	System.debug('Error while getting member infl: ' + e.getLineNumber() + ' Type: </b>' + e.getTypeName() 
        					+ '<b> Message: </b>' + e.getStackTraceString());
        }
        return ((response == null)?null:((response.isEmpty())?null:response.get(0)));
    }
   
    /** 
   	 * This method is use to create Nominee/Member in influitive
     * This will be called when a contact will be made Reference program member.
     */
    public override Infl_MemberParser createInflNominee(Infl_MemberJSON inflMemberRequest) {
        String apiURI = apiURL + MEMBER_URI;
        String request = inflMemberRequest.serialize();
        Map<String, String> params = generateRequestParams(apiURI, HTTP_POST, request);
        
        if (Test.isRunningTest()) {
            params.put(API_TYPE, CREATE_MEMBER);
        }
        String responseJson = execute(params);
        Infl_MemberParser response = null;
        
        try {
        	response = Infl_MemberParser.parse(responseJson);
        } catch(Exception e) {
        	System.debug('Error while create member in influitive: ' + e.getLineNumber() + ' Type: </b>' + e.getTypeName() 
        						+ '<b> Message: </b>' + e.getStackTraceString());	
        }
        return response;
    }
    
    /** 
   	 * This method is use to set parameters
     */
    private Map<String, String> setQueryParams(Map<String, String> params, Map<String, String> queryParams) {
    	
        if (queryParams != null) {
            String uri = params.get(API_URL);
            
            for (String key : queryParams.keySet()) {
                uri = (uri.contains('?')) ? uri + '&' + key + '=' + queryParams.get(key) : uri + '?' + key + '=' + queryParams.get(key);
            }            
            params.put(API_URL, uri);
        }
        return params;
    }
    
    /** 
   	 * This method is use to getAll events from influitive cummulate all events and contacts and return .
     * This method is called from Infl_Batch_Events and Infl_Member class
     */
    public Infl_EventsParser getEventList(String contactId, APIType type) {
        Infl_EventsParser eventParser = null;
        String next = '';
        List<Infl_EventsParser.cls_events> allEvent = new List<Infl_EventsParser.cls_events>();
        List<Infl_EventsParser.cls_contacts> allContact = new List<Infl_EventsParser.cls_contacts>();
        Map<String, String> queryParams = new Map<String, String>();
        
        //contactId null Means calling from Batch 
        if (contactId != null) {
            queryParams.put(CONTACT_ID, contactId);
        } else {
            String lastFetch = null;
            
            if (type == APIType.EVENT) {
                lastFetch = cs.Infl_Event_Fetch_DateTime__c;//Event
            } else if (type == APIType.REFERENCE) {
                lastFetch = cs.Infl_Reference_Cursor__c;//Reference 
            }
            
            if (lastFetch != null && lastFetch != '') {
                queryParams.put(STARTED_AT, lastFetch);
            }
        }
        Set<Integer> conIds = new Set<Integer>();
        Map<Integer, String> contactMap = new Map<Integer, String>();
        //This field use to monitor that how many api call we have already made to influitive
        Integer apiCalls =0;
        
        //Summing All events and contacts getting from influitive
        while (next != null) {
            eventParser = getInflEvents(queryParams);
            apiCalls++;
            
            for (Infl_EventsParser.cls_contacts con : eventParser.contacts) {
                
                if (conIds.add(con.id) && con.crm_contact_id != null && con.crm_contact_id != '') {
                    allContact.add(con); 
                    contactMap.put(con.id, con.crm_contact_id);
                }
            }
            
            if (type == APIType.EVENT) {
            	
                for (Infl_EventsParser.cls_events eventI : eventParser.events) {
                	
                    if (eventI.points == 0) {
                        continue;
                    }  
                    
                    if (contactMap.get(eventI.contact_id) != null && contactMap.get(eventI.contact_id) != '') {
                        allEvent.add(eventI);
                    }
                }  
            } else if (type == APITYpe.REFERENCE) {
            	
                for (Infl_EventsParser.cls_events eventI : eventParser.events) {
                	
                    if (eventI.points > 0 && eventI.params != null && eventI.params.challenge != null 
                    			&& contactMap.get(eventI.contact_id) != null && contactMap.get(eventI.contact_id) != '') {
                        allEvent.add(eventI);
                    }
                }
            }
            next = eventParser.links.next;
            
            //Setting curson for next fetch
            if (next != null) {
                System.PageReference pageReference = new System.PageReference(next);
                Map<String, String> parameters = pageReference.getParameters();
                queryParams.put(CURSOR, parameters.get(CURSOR));
            }
            
            if (Test.isRunningTest()) {
            	next = null;
            }
        }   
        eventParser.events = allEvent;
        eventParser.contacts = allContact;
        eventParser.apiCalls = apiCalls;
        return eventParser;
    }
    
    /** 
   	 * This method is use to get all events based on pagination which are not part of change complete
     */
    public Infl_EventsParser getEvents(String contactId) {
        return getEventList(contactId, APIType.EVENT);
    }
    
    /** 
   	 * This method is use to get all events based on pagination which are part of change complete
     */
    public Infl_EventsParser getChallengeEvents() {
        return getEventList(null, APIType.REFERENCE);
    }
    
    public Map<String, String> getReferenceability() {
    	
    	//Getting default referenceceability if not found for influitive events
        List<Referenceability_Type__c> refceabilitys = [SELECT Id,Referenceability_code__c FROM Referenceability_Type__c LIMIT: limits.getLimitQueryRows()];
        Map<String, Id> referenceabilityMap = new Map<String, Id>();
        
        for (Referenceability_Type__c refceability : refceabilitys) {
           
            if (refceability.Referenceability_code__c != null) {
               referenceabilityMap.put(refceability.Referenceability_code__c, refceability.Id);
            }
        }
        return referenceabilityMap;
    }
}