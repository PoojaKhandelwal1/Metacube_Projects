public with sharing class DP360Integration {
    
    public static String endPoint = DP360_Configuration__c.getOrgDefaults().End_Point_URL__c;
    public static String integrationName = 'DP360';
    public static String contentType = 'application/json';
    public static List<String> reservedKeyList = new List<String>{'"class"', '"date"', '"time"','"type"'};
    
    public static String getAuthToken() {
        Credential credentialObj = getAuthCredentials(integrationName);
        if(credentialObj == null) {
            //IntegrationLog.createLog('DP360Integration', 'getAuthToken()', 'Invalid username or password', null, null, null);
            return null;
        }
    	String reqPayload = system.JSON.serialize(credentialObj);
    	String authToken;
    	HttpResponse response = new HTTPConnector().doPost(endPoint + '/vendors/token.json', reqPayload, contentType);
    	if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            Map<String,Object> result = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            Map<String,Object> resultObj = (Map<String,Object>) JSON.deserializeUntyped(system.JSON.serialize(result.get('data')));
           	authToken = (String)resultObj.get('token');
    	} else if(response.getStatusCode() == 401) {
            //IntegrationLog.createLog('DP360Integration', 'searchLead()', 'Invalid username or password', String.valueOf(response.getStatusCode()), null, null);
        }
    	return authToken;
    } 
     
    public static String searchLead(DP360IntegrationCtrl.SearchLeadWrapper searchLeadObj) {
        String endPointUrl = endPoint.replace('/api', '/service');
        String endPointParams = '/contacts/search_lead.json?dealer_id='+searchLeadObj.dealerId;
        endPointParams += (searchLeadObj.startdate != null ? '&date_start=' + searchLeadObj.startdate : '');
        endPointParams += (searchLeadObj.lead_id != null ? '&lead_id=' + searchLeadObj.lead_id : '');
        
        HttpResponse response = new HTTPConnector().doGet(endPointUrl + endPointParams, new Map<String, String>{'Authorization'=>'Bearer ' + getAuthToken()}, contentType);
        if(response.getStatusCode() == 200) {
            return handleHTTPResponse(response);
        } else if(response.getStatusCode() == 401) {
            //IntegrationLog.createLog('DP360Integration', 'searchLead()', 'Invalid Dealer Id OR You do not have access to this dealer id OR Dealer ID is missing', String.valueOf(response.getStatusCode()), null, System.JSON.serialize(searchLeadObj));
        } else if(response.getStatusCode() == 500) {
            //IntegrationLog.createLog('DP360Integration', 'searchLead()', 'Invalid request', String.valueOf(response.getStatusCode()), null, System.JSON.serialize(searchLeadObj));
        }
        return null; 
    }
    
    public static String searchInventory(String dealerId, String id) {
        String endPointURL = endPoint + '/inventory/' + dealerId + '.json' + (id != null ? '?id=' + id : '');
        
        HttpResponse response = new HTTPConnector().doGet(endPointURL, new Map<String, String>{'Authorization'=>'Bearer ' + getAuthToken(), 'DealerId' => '5000'}, contentType);
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
            return handleHTTPResponse(response);
        } else {
        	//IntegrationLog.createLog('DP360Integration', 'searchLead()', 'Invalid request', String.valueOf(response.getStatusCode()), null, System.JSON.serialize(id));
        }
        return null; 
    }
    
    public static String createInventory(List<DP360InventoryWrapper> invObjList) {
        if(invObjList.size() > 0) {
            String endPointURL = endPoint + '/inventory.json';
            String reqBody = system.JSON.serialize(invObjList);
            HttpResponse response = new HTTPConnector().doPostWithParam(endPointURL, reqBody, contentType, 
            					new Map<String, String>{'Authorization' => 'Bearer ' + getAuthToken(), 'DealerId' => '5000'});

            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                return handleHTTPResponse(response);
            } else {
            	//IntegrationLog.createLog('DP360Integration', 'saveInventory()', 'Save Inventory failed', String.valueOf(response.getStatusCode()), null, system.JSON.serialize(invObjList));
            }
            //system.assert(false, response.getStatusCode()+' Nidhi ' + invObjList);	
        }
        return null;
    }
    
    public static String updateInventory(List<DP360InventoryWrapper> invObjList) {
        if(invObjList.size() > 0) {
            String endPointURL = endPoint + '/inventory/5000.json';
            String reqBody = system.JSON.serialize(invObjList);
            HttpResponse response = new HTTPConnector().doPutWithParam(endPointURL, reqBody, contentType, 
            					new Map<String, String>{'Authorization' => 'Bearer ' + getAuthToken(), 'DealerId' => '5000'});
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                return handleHTTPResponse(response);
            } else {
                //IntegrationLog.createLog('DP360Integration', 'saveInventory()', 'Save Inventory failed', String.valueOf(response.getStatusCode()), null, system.JSON.serialize(invObjList));
            }
        }
    	return null; 
    }
    
    public static String saveLead(CreateLeadWrapper leadObj) {
    	String reqBody = replaceReservedKeys(system.JSON.serialize(leadObj), false);
    	
        String endPointURL = endPoint;
        HttpResponse response;
    	if(String.isNotBlank(leadObj.lead.lead_id)) {
            endPointURL += '/leads/' + leadObj.lead.lead_id + '.json';
            response = new HTTPConnector().doPutWithParam(endPointURL, reqBody, contentType, new Map<String, String>{'Authorization'=>'Bearer ' + getAuthToken(), 'DealerId' => '5000'});
        } else {
        	endPointURL += '/leads.json';
        	response = new HTTPConnector().doPostWithParam(endPointURL, reqBody, contentType, new Map<String, String>{'Authorization'=>'Bearer ' + getAuthToken(), 'DealerId' => '5000'});
    	}
        if(response != null && response.getStatusCode() == 200 || response.getStatusCode() == 201) {
    		return handleHTTPResponse(response);
    	} else {
    	    //IntegrationLog.createLog('DP360Integration', 'saveLead()', 'Save Lead failed', String.valueOf(response.getStatusCode()), null, system.JSON.serialize(leadObj));
    	}
    	return null; 
    }
    
    public static String handleHTTPResponse(HttpResponse response) {
    	String reqBody = null;
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
    		reqBody = replaceReservedKeys(response.getBody(), true);
    	}
    	return reqBody;
    }
    
    public static String replaceReservedKeys(String reqStr, Boolean isHttpResponse) {
    	for(String reservedKey : reservedKeyList) {
    		String key = reservedKey.substring(0, reservedKey.length() - 1);
    		if(isHttpResponse) {
    			reqStr = reqStr.replace(reservedKey, key + '_replaceKey"');
    		} else {
    			reqStr = reqStr.replace(key + '_replaceKey"', reservedKey);
    		}
    	}
    	return reqStr;
    }
    
	public static Credential getAuthCredentials(String integrationName) {
    	List<Integration__c> integrationList = [Select Client_Id__c, Client_Secret__c from Integration__c where Integration_Name__c =: integrationName];
    	if(integrationList.size() > 0) {
    		return new Credential(integrationList[0]);
    	}
    	return null;
    }
    
    public class Credential {
    	public String username;
    	public String password;
    	public Credential(Integration__c integrationRec) {
    		this.username = integrationRec.Client_Id__c;
    		this.password = integrationRec.Client_Secret__c;
    	}
    }
    
    public with sharing class DP360ResponseWrapper {
		public Integer code;
		public LeadData data;
		public String message;
    }
    
    public class LeadData {public Integer lead_id; public String AddedVins; public String NotAddedVins;}
}