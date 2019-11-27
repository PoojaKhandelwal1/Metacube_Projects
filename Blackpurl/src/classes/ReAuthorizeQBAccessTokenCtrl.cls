/**
 * Author: Tarun Khandelwal
 * Since: July 20, 2018
 * Name: ReAuthorizeQBAccessTokenCtrl
 * Description: Apex class for regenrating Authorise token used for QB
**/
global without sharing class ReAuthorizeQBAccessTokenCtrl {
    
    public final String RECONNECT_END_POINT = 'https://appcenter.intuit.com/api/v1/connection/reconnect';
    public String InfoMessage {get; set;}
    public Boolean isRefreshButtonShown {get; set;}
    public Date nextRefreshFromDate {get; set;}
    public Date nextRefreshToDate {get; set;}
    
    public ReAuthorizeQBAccessTokenCtrl() {
        isRefreshButtonShown = false;
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        Integer dayDiff;
        if(qbConfig.Access_Token_Generation_Date__c != null) {
            dayDiff = qbConfig.Access_Token_Generation_Date__c.daysBetween(system.today());
        }
        if(dayDiff == null || (dayDiff > 151 && dayDiff < 179)) {
            isRefreshButtonShown = true;
        } else {
            nextRefreshFromDate = qbConfig.Access_Token_Generation_Date__c.addDays(151);
            nextRefreshToDate = qbConfig.Access_Token_Generation_Date__c.addDays(179);
        }
    }
    
    public void checkForAccessToken() {
        InfoMessage = regenerateAccessToken();
    }
    
    public String regenerateAccessToken() {
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        if(String.isBlank(qbConfig.Consumer_Key__c) || String.isBlank(qbConfig.Consumer_Secret__c) || !QBUtil.isQBEnabled()) {
            return 'QB is not enabled';
        }
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_consumer_key', qbConfig.Consumer_Key__c);
        parameters.put('oauth_nonce', String.valueOf(Crypto.getRandomLong()));
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', String.valueOf(dateTime.now().getTime()/1000));
        parameters.put('oauth_token', EncodingUtil.urlEncode(qbConfig.OAuth_Token__c, 'UTF-8'));
        parameters.put('oauth_version', '1.0');
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(RECONNECT_END_POINT);
        req.setMethod('GET'); 
        
        String signature = QuickbookConnector.generateSignature(req, qbConfig.Consumer_Secret__c, qbConfig.OAuth_Token_Secret__c, parameters);
        String header = QuickbookConnector.generateHeader(signature, parameters);
        
        req.setHeader('Authorization', header);
        req.setHeader('Accept', 'application/json'); 
        req.setHeader('Content-type', 'application/json');
        
        Http http = new Http();
        HttpResponse res;
        if(!Test.isRunningTest()){
            res = http.send(req);
        } else {
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"ErrorMessage" : "The OAuth access token has expired", "ErrorCode" : 270, "OAuthToken" : "asdasd", "OAuthTokenSecret" : "sdfsdf"}');
        }
        // Error code 270 — The OAuth access token has expired.
        // Error code 212 — The request is made outside the 30-day window bounds.
        // Error code 22  — The API requires authorization. 
        // Error code 24  — The app is not approved for the API.
        if(res.getStatusCode() == 200) {
            ReconnectWrapper responseObj = (ReconnectWrapper) system.JSON.deserialize(res.getBody(), ReconnectWrapper.class);
            if(responseObj.ErrorCode != 212 && responseObj.ErrorCode != 22 && responseObj.OAuthToken != null && responseObj.OAuthTokenSecret != null) {
                qbConfig.OAuth_Token__c = responseObj.OAuthToken;
                qbConfig.OAuth_Token_Secret__c = responseObj.OAuthTokenSecret;
                qbConfig.Access_Token_Generation_Date__c = system.today();
                upsert qbConfig;
                return 'Access Token regenerated';
            } else {
                return responseObj.ErrorMessage;
            }
        } else {
            return String.valueOf(res.getStatusCode());
        }
    }
    
    private class ReconnectWrapper {
        public String OAuthToken;
        public String OAuthTokenSecret;
        public String ErrorMessage;
        public Integer ErrorCode;
    }
}