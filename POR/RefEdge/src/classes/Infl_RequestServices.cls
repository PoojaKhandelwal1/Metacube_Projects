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
@RestResource(urlMapping='/v1.0/ReferenceEdge/Request/*') 
global class Infl_RequestServices {
    
	public static String ADVOCATE_RESPONSE = 'response';
    public static String CHALLENGE_STATUS = 'status';    
    public static String MISSING_URL = 'Request action (response/status) missing for the request URL.';
    public static String INTEGRATION_OFF = 'Influitive integration is disabled in Reference Edge.'; 
    public static Integer SUCCESS_CODE = 200;
    public static Integer SUCCESS_CODE_NO_RESPONSE = 204;
    public static Integer FAILURE_CODE = 500;
    public static Integer BAD_REQUEST_CODE = 400; 
    public static Integer FORBIDDEN_CODE = 403; 
    
    @HttpPatch
    global static void updateAdvocateResponseChallengeStatus() {
        Savepoint sp = Database.setSavepoint();  
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        String emailMsg = 'Infuilitive REST API facing Error/Exception.<br/><br/>Here are the details : <br/>';
        List<Database.UpsertResult> updateResults = new List<Database.UpsertResult>();
        RequestWrapper resultWp; 
        
        try {
            
            if (cs.Is_Influitive_Integration_Enabled__c) {
                ConstantsController.isCallFromInfluitiveAPI = true;
                ConstantsController.isCallToInfluitiveAPI = true;
                String action = req.params.get('action');
                
                
                if (!String.isBlank(action)) {
                    
                    if (action.tolowercase() == ADVOCATE_RESPONSE) {    
                        String records = '';
                        AdvocateResponseWrapper advocateResponseWrap;
                        ResponseWrapper statusResponse;
                        List<Community_Invite_Contact__c> listCIC = new List<Community_Invite_Contact__c>();
                        List<Unspecified_Request__c> listOfUR = new List<Unspecified_Request__c>();
                        List<Contact> listOfContact = new List<Contact>();
                        
                        if (!String.isBlank(req.requestBody.toString())) {
                           records = req.requestBody.toString(); 
                        }
                        
                        if (!String.isBlank(records)) {
                            try {
                                resultWp = (RequestWrapper) JSON.deserialize(records, RequestWrapper.class);
                            } catch (Exception e) {
                                res.responseBody = Blob.valueOf('Incorrect request body'); 
                            	res.statusCode = BAD_REQUEST_CODE;
                            }
                        }
                        
                        if (resultWp != null) {
                           advocateResponseWrap = resultWp.response; 
                        }
                        
                        if (advocateResponseWrap != null) {
                            
                            if (advocateResponseWrap.crm_contact_id != null && advocateResponseWrap.crm_contact_id != '' 
                                && !(advocateResponseWrap.crm_contact_id.length() < 15) && advocateResponseWrap.challenge_Id != null 
                                && advocateResponseWrap.challenge_Id != '') {
                                    
                                    listCIC = [SELECT Id,Response__c,Contact__c,Challenge_Id__c
                                       		   FROM Community_Invite_Contact__c
                                       		   WHERE Challenge_Id__c =: advocateResponseWrap.challenge_Id AND 
                                               Contact__c =: String.valueOf(advocateResponseWrap.crm_contact_id).substring(0,15)];
                                    
                                    if (listCIC.size() > 0) {
                                        listCIC[0].Response__c = 'Yes';
                                    } else {
                                        listOfUR = [SELECT Id, Community_Invite__c, Influitive_Challenge_Id__c, Unspecified_Request_Status__c
                                                    FROM Unspecified_Request__c
                                                    WHERE Influitive_Challenge_Id__c =: advocateResponseWrap.challenge_Id 
                                                    AND Unspecified_Request_Status__c = 'In Progress'];
                                        
                                        if (listOfUR.size() > 0) {
                                            listOfContact = [SELECT Id FROM Contact WHERE Id =: advocateResponseWrap.crm_contact_id];
                                            
                                            if (listOfContact.size() > 0) {
                                                listCIC = createCICRecord(listOfUR[0],listOfContact[0]);
                                            }
                                        } 
                                    }
                                    
                                    if (listCIC.size() > 0) {
                                        updateResults = Database.upsert(listCIC, false);
                                        
                                        if (updateResults.size() > 0) {
                                            statusResponse = new ResponseWrapper(updateResults[0].isSuccess(), (!updateResults[0].isSuccess()) ? 
                                                                                 getErrorDetails(updateResults[0]) : 'Response successfull');
                                        }
                                        res.responseBody = Blob.valueOf(JSON.serialize(statusResponse));
                                        res.statusCode = SUCCESS_CODE;
                                    } else {
                                        res.responseBody = Blob.valueOf(JSON.serialize(statusResponse));
                                        res.statusCode = SUCCESS_CODE_NO_RESPONSE;
                                    }
                                } else {
                                    res.responseBody = Blob.valueOf('challenge_Id or crm_contact_id is missing or invalid in request body'); 
                                    res.statusCode = BAD_REQUEST_CODE;
                                }
                        } else {
                            
                            if (res.responseBody == null) {
                                res.responseBody = Blob.valueOf('request body missing for response'); 
                                res.statusCode = BAD_REQUEST_CODE;                                
                            }
                        }
                    } else if (action.tolowercase() == CHALLENGE_STATUS) {
                        String records = '';
                        List<Unspecified_Request__c> listUR = new List<Unspecified_Request__c>();
                        ChallengeStatusWrapper challengeStatusWrap; 
                        ResponseWrapper statusResponse;
                        
                        if (!String.isBlank(req.requestBody.toString())) {
                           records = req.requestBody.toString(); 
                        }
                        
                        if (!String.isBlank(records)) {
                            try {
                                resultWp = (RequestWrapper) JSON.deserialize(records, RequestWrapper.class);
                            } catch (Exception e) {
                                res.responseBody = Blob.valueOf('Incorrect request body'); 
                            	res.statusCode = BAD_REQUEST_CODE;
                            }
                        }
                        
                        if (resultWp != null) {
                           challengeStatusWrap = resultWp.status; 
                        }
                        
                        if (challengeStatusWrap != null) {
                            
                            if (challengeStatusWrap.challenge_Id != null && challengeStatusWrap.challenge_Id != '' 
                                && challengeStatusWrap.status != null && challengeStatusWrap.status != '') {
                                    
                                    listUR = [SELECT Id, Influitive_Challenge_Id__c, Influitive_Challenge_Status__c
                                              FROM Unspecified_Request__c
                                              WHERE Influitive_Challenge_Id__c =: challengeStatusWrap.challenge_Id]; 
                                    
                                    if (listUR.size() > 0) {
                                        listUR[0].Influitive_Challenge_Status__c = challengeStatusWrap.status;
                                        updateResults = Database.upsert(listUR, false); 
                                        
                                        if (updateResults.size() > 0) {
                                            statusResponse = new ResponseWrapper(updateResults[0].isSuccess(), 
                                                                                  (!updateResults[0].isSuccess()) ? getErrorDetails(updateResults[0]) : 'Status changed');
                                        }
                                        res.responseBody = Blob.valueOf(JSON.serialize(statusResponse));
                                        
                                        if (!updateResults[0].isSuccess()) {
                                            res.statusCode = BAD_REQUEST_CODE;
                                        } else {
                                            res.statusCode = SUCCESS_CODE;
                                        }
                                    } else {
                                        res.responseBody = Blob.valueOf(JSON.serialize(statusResponse));
                                        res.statusCode = SUCCESS_CODE_NO_RESPONSE;
                                    }
                                } else {
                                    res.responseBody = Blob.valueOf('challenge_Id or status missing in request body'); 
                                    res.statusCode = BAD_REQUEST_CODE;
                                }
                        } else {
                            
                            if (res.responseBody == null) {
                                res.responseBody = Blob.valueOf('request body missing for status'); 
                                res.statusCode = BAD_REQUEST_CODE;
                            }
                        }
                    } else {
                        res.responseBody = Blob.valueOf(MISSING_URL); 
                        res.statusCode = BAD_REQUEST_CODE;
                        return;
                    }
                } else {
                    res.responseBody = Blob.valueOf('Please provide API action in the URL.'); 
                    res.statusCode = BAD_REQUEST_CODE;
                }
            } else {
                res.responseBody = Blob.valueOf(INTEGRATION_OFF); 
                res.statusCode = FORBIDDEN_CODE;
            } 
            
        } catch (Exception ex) {
            Database.rollback(sp);
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = FAILURE_CODE;
            emailMsg = emailMsg + '<br/>Error Message : ' + ex.getMessage() + '<br/>Error Line Number : ' + ex.getLineNumber() 
                + '<br/><p> Please do not reply to this mail.</p>'; 
            InflAPIAbstractHandler.sendInflExceptionEmail('RefEdge REST API failed for Influitive.', new List<String>{emailMsg}); 
        }
    }
    
    public static String getErrorDetails(Database.UpsertResult error) {
        String errorMsg = '';
         
        for (Database.Error err : error.getErrors()) { 
            errorMsg += 'Error Details : ' + err.getMessage() + ' , Error fields '+ err.getFields(); 
        }
        return errorMsg;
    }
    
    //create cic with yes response if ur is present with challenge id
    public static List<Community_Invite_Contact__c> createCICRecord(Unspecified_Request__c ur, Contact con) {
        List<Community_Invite_Contact__c> tempCIC = new List<Community_Invite_Contact__c>();
        
        if (ur != null && con != null) {
            Community_Invite_Contact__c newCIC = new Community_Invite_Contact__c();
            newCIC.Community_Invite__c = ur.Community_Invite__c;
            newCIC.Contact__c = con.Id;
            newCIC.Response__c = 'Yes';
            newCIC.Challenge_Id__c = ur.Influitive_Challenge_Id__c;
            tempCIC.add(newCIC);
        }
        return tempCIC;
    }
    
    //Wrapper for advocate's response
    public class AdvocateResponseWrapper {     
        private String crm_contact_id; 
        private String challenge_Id;
        
        private AdvocateResponseWrapper(String crm_contact_id, String challenge_Id) {  
            this.crm_contact_id = crm_contact_id; 
            this.challenge_Id = challenge_Id;
        }
    }
    
    //Wrapper for challenge status
    public class ChallengeStatusWrapper {     
        private String challenge_Id;
        private String status;
        
        private ChallengeStatusWrapper(String challenge_Id, String status) {
            this.challenge_Id = challenge_Id; 
            this.status = status;  
        }
    }
    
    public class RequestWrapper {
        private AdvocateResponseWrapper response;
        private ChallengeStatusWrapper status;

        private RequestWrapper(AdvocateResponseWrapper record) {
            this.response = record;
        }

        private RequestWrapper(ChallengeStatusWrapper record) {
            this.status = record;
        }
    } 
    
    public class ResponseWrapper {
        private Boolean isSuccess;
        private String result_message;
        
        private ResponseWrapper(Boolean isSuccess, String result_message) {
            this.isSuccess = isSuccess;  
            this.result_message = result_message;  
        }
    }
}