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
 * This InflAPIAbstractHandler class is  base class for InflAPIHandler.
 * This class is added as part of influitive integration
 * Created By: Narender Singh Tanwar
 * Modified by: Rekha @Feb 6 2017
 */
public with sharing abstract class InflAPIAbstractHandler {
	
    protected String apiURL = null;
    private String apiToken = null;
    protected final String HTTP_GET = 'GET';
    protected final String HTTP_POST = 'POST';
    private static final String API_AUTH_TOKEN ='API_AUTH_TOKEN';
    private static final String API_CONTENT_TYPE ='API_CONTENT_TYPE';
    private static final String API_ACCEPT_TYPE ='API_ACCEPT_TYPE';
    protected final String API_URL ='API_URL';
    private static final String API_METHOD ='API_METHOD';
    private static final String REQUEST_BODY ='REQUEST_BODY';
    protected final String API_TYPE = 'API_TYPE';
    
    private static final String CONTENT_TYPE = 'Content-Type';
    private static final String ACCEPT_TYPE = 'Accept';
    private static final String CONTENT_TYPE_VALUE = 'application/json';
    private static final String ACCEPT_TYPE_VALUE = 'application/json';
    private static final String AUTHORIZATION = 'Authorization';
    protected final String MEMBER_URI = '/api/members';
    protected final String CONTACT_URI = '/api/contacts';
    protected final String EVENT_URI = '/api/events';
    protected final String REFERENCE_URI = '/api/references';
    protected final String CHALLENGE_URI = '/api/challenges';
    protected final String PUBLISH_URI = '/publish';
    protected final String UNPUBLISH_URI = '/unpublish';
    protected final String ARCHIVE_URI = '/archive';
    protected final String UNARCHIVE_URI = '/unarchive';
    protected final String DETAILS_URI = '/details';
    
    protected final String CREATE_EVENT = 'CREATE_EVENT';
    protected final String GET_EVENT = 'GET_EVENT';
    protected final String CREATE_REFERENCE = 'CREATE_REFERENCE';
    protected final String GET_REFERENCE = 'GET_REFERENCE';
    protected final String GET_CONTACT = 'GET_CONTACT';
    protected final String CREATE_MEMBER = 'CREATE_MEMBER';
    protected final String GET_MEMBER = 'GET_MEMBER';
    
    private static final String CREATE_EVENT_RESPONSE = '{"id":1597,"event_type_code":"refedge_form","points":200,"contact":{"id":107,"email":"nstane88@gmail.com","first_name":"N","last_name":"Ssss","lifetime_points":93802,"current_points":93802,"type":"Advocate","salesforce_id":"003i000003IggeJAAR","source":"Email Invite","thumb":"https://d3rnld1uo6kgq2.cloudfront.net/assets/contacts/thumb/missing-3c71b5cae9b3d972664ad248823fbdc3.png","name":"N Ssss"},"parameters":{}}';
    public static final String GET_EVENT_RESPONSE = '{"events":[{"id":1587,"type":"Non-Reference Activity","created_at":"2015-12-22T10:56:49Z","contact_id":190,"points":75,"params":{"challenge":{"id":98,"type":"Non-Reference Activity"}}},{"id":1588,"type":"Non-Reference Activity","created_at":"2015-12-22T10:56:49Z","contact_id":190,"points":75,"params":{}},{"id":15890,"type":"Non-Reference Activity","created_at":"2015-12-22T10:56:49Z","contact_id":190,"points":0,"params":{}},{"id":15891,"type":"Non-Reference Activity","created_at":"2015-12-22T10:56:49Z","contact_id":190,"points":-34,"params":{}},{"id":15892,"type":"Non-Reference Activity","created_at":"2015-12-22T10:56:49Z","contact_id":190,"points":34,"params":{}}],"contacts":[{"id":190,"name":"Eylse Shuter","first_name":"Eylse","last_name":"Shuter","email":"metacube.narendra@gmail.com","title":"","company":"Test Acount 16 Dec 2015","type":"Advocate","created_at":"2015-12-17T11:17:37.588Z","joined_at":"2015-12-17T11:19:12.766Z","nps_score":null,"current_points":24499,"lifetime_points":24499,"crm_contact_id":"003i000003Lyfqb","level":{"id":4,"name":"Rockstar"}}],"links":{"self":"https://pointofreference.influitive.com/api/events","next":"https://pointofreference.influitive.com/api/events?cursor=1047"}}';
    private static final String CREATE_REFERENCE_RESPONSE = '{"id":290,"name":"Reference for Test challenge","headline":"Will you speak to  from ","description":""}';
    private static final String CREATE_MEMBER_RESPONSE = '{"id": 197,"email": "np@np.com","first_name": "NP","last_name": "","lifetime_points": 0,"current_points": 0,"type": "Nominee","salesforce_id": null,"source": "np","thumb": "https://d3rnld1uo6kgq2.cloudfront.net/assets/contacts/thumb/missing-3c71b5cae9b3d972664ad248823fbdc3.png","name": "NP"}';
    private static final String GET_MEMBER_RESPONSE = '[{"id": 107,"email": "metacube.narendra@gmail.com","first_name": "N","last_name": "Ssss","lifetime_points": 95202,"current_points": 95202,"type": "Advocate","salesforce_id": "003i000003IgltiAAB","source": "Email Invite","thumb": "https://d3rnld1uo6kgq2.cloudfront.net/assets/contacts/thumb/missing-3c71b5cae9b3d972664ad248823fbdc3.png","name": "N Ssss"}]';
    protected final Custom_Settings__c cs = UtilityController.getCustomSettings();
    
    public InflAPIAbstractHandler() {
        apiURL = cs.Influitive_API_URL__c; 
        apiToken = cs.Influitive_Auth_Token__c;
    }
    
    /* This method add http headers,mthod, api URI to map and return map before call influitive rest api.
    * @param {String} apiURI
    * @param {String} httpMethod
    * @param {String} requestBody
    * return {Map<String,String>}
    **/
    protected Map<String, String> generateRequestParams(String apiURI, String httpMethod, String requestBody) {
        Map<String, String> params = new Map<String, String>();
        params.put(API_AUTH_TOKEN, 'Token "' + apiToken +'"');
        params.put(API_CONTENT_TYPE, CONTENT_TYPE_VALUE);
        params.put(API_ACCEPT_TYPE, ACCEPT_TYPE_VALUE);
        params.put(API_URL, apiURI);
        params.put(API_METHOD, httpMethod);
        
        if (httpMethod == HTTP_POST) {
            params.put(REQUEST_BODY, requestBody);
        }
        return params;
    }
    
    /**
     * Execute method will execute rest api based on parameter are send to this method
     * @param {Map<String,String} paramMap
     * @return {String} apiResponse
     */
    protected String execute(Map<String, String> paramMap) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(paramMap.get(API_URL));
        req.setHeader(AUTHORIZATION, paramMap.get(API_AUTH_TOKEN));
        req.setHeader(CONTENT_TYPE, paramMap.get(API_CONTENT_TYPE));
        req.setHeader(ACCEPT_TYPE, paramMap.get(API_ACCEPT_TYPE));
        //REF-1964
       // req.setHeader('X_ORG_ID', '04bea17a-3472-4242-a83c-61aa934056b4');

        String requestBody = paramMap.get(REQUEST_BODY);
        
        if (requestBody != null) {
            req.setBody(requestBody);
        }
        req.setMethod(paramMap.get(API_METHOD));
        HttpResponse res = new HttpResponse();
        Http http = new Http();
        String response = null;
        if (Test.isRunningTest()) {
            String type = paramMap.get(API_TYPE);
            response = getMocResponse(type);
        } else {
            res = http.send(req);
            
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                response = res.getBody();
            //REF-2300    
            } else if ((paramMap.get(API_URL) == (apiURL + REFERENCE_URI) || paramMap.get(API_TYPE) == CREATE_EVENT) && (res.getStatusCode() == 400 || res.getStatusCode() == 422)) {
                response = res.getBody();
            } else {
                String message = 'Error for calling influitive <b>API URl:</b>' + paramMap.get(API_URL) + 
                				' <b>Status Code: </b>' + res.getStatusCode() + '<b> Error Message: </b>' + res.getStatus() + ' for request:' + requestBody;
                response = message;
            }
        }
        return response;
    }
    /*
    * This method for test classes
    */
    private String getMocResponse(String requestType) {
        String response = null;
        
        if (requestType == CREATE_EVENT) {
            response = CREATE_EVENT_RESPONSE;
        }
        
        if (requestType == GET_EVENT) {
            response = GET_EVENT_RESPONSE;
        }
        
        if (requestType == CREATE_REFERENCE) {
            response = CREATE_REFERENCE_RESPONSE;
        }
        
        if (requestType == CREATE_MEMBER) {
            response = CREATE_MEMBER_RESPONSE;
        }
        
        if (requestType == GET_MEMBER) {
            response = GET_MEMBER_RESPONSE;
        }
        return response;
    
    } 
    
    public abstract Infl_EventsParser getInflEvents(Map<String, String> queryParams);
    
    public abstract InflCreateEventResponse createInflEvent(Infl_EventJSON inflEventRequest);
        
    public abstract Infl_CreateReferenceResponse createInflReference(Infl_ReferenceJSON inflReferenceRequest);

    //REF-1964
    public abstract Infl_CreateReferenceResponse changeInflReferenceChallengeStatus(String status, String challengeId, String publishRequestString);
        
    public abstract Infl_MemberParser createInflNominee(Infl_MemberJSON inflMemberRequest);
    
    public abstract Infl_MemberParser getMember(Map<String, String> queryParams);
    
    /**
     * Send Mail when any error happen in influitive api call or reward updation
     */
    public static void sendInflExceptionEmail(String subject, List<String> errorMessages) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'referenceedge@point-of-reference.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject(subject);
        String body = '';
        
        for(String errorMessage : errorMessages) {
            body = (body == '' ? errorMessage : body + '<br/>' + errorMessage);
        }
        
        try {
            mail.setToAddresses(toAddresses);
            mail.setHtmlBody(body);
            mailList.add(mail);
            
            if (!mailList.isEmpty()) {
                Messaging.sendEmail(mailList);
            }
        } catch(Exception e){
            System.debug('Error whhile seding email: ' + e.getLineNumber() + ' Message: ' + e.getMessage());
        }
    }
}