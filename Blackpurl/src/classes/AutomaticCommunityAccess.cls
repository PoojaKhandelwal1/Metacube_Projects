public without sharing class AutomaticCommunityAccess {
    
    @future(callout=true)
    public static void grantCommnunityAccess(List<Id> userIdList) {
        OAuth2 objAuthenticationInfo = getAccessToken();
        if(String.isNotBlank(objAuthenticationInfo.access_token)) {
            List<User> userList = [SELECT FirstName, LastName, Email FROM User Where Id IN: userIdList];
            List<UserDetailWrapper> userDetailWrapperList = new List<UserDetailWrapper>();
            for(User userRec : userList) {
                userDetailWrapperList.add(new UserDetailWrapper(userRec.FirstName, userRec.LastName, userRec.Email, UserInfo.getOrganizationId()));
            }
            HttpResponse response;
            if(!Test.isRunningTest()) {
                response = sendRequestForCreatePortalUser(userDetailWrapperList[0], objAuthenticationInfo);
            } else {
                response = new HttpResponse();
                response.setBody(EncodingUtil.base64Encode(Blob.valueOf('{"FedId":"testingmetacube123.admin12@bp.community.fedid"}')));
            }
            if(Test.isRunningTest() || (response.getStatusCode() == 200 && response.getBody() != null)) {
                String fedIdJSONStr = response.getBody().replaceAll('\"', '');
                fedIdJSONStr = EncodingUtil.base64Decode(fedIdJSONStr).toString();
                UserFedIdWrapper userFedIdObj = (UserFedIdWrapper) system.JSON.deserialize(fedIdJSONStr, UserFedIdWrapper.class);
                userList[0].FederationIdentifier = userFedIdObj.FedId;
                update userList[0];
            }
        }
    }
    
    private static HttpResponse sendRequestForCreatePortalUser(UserDetailWrapper userObj, OAuth2 objAuthenticationInfo) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + objAuthenticationInfo.access_token);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('accept', 'application/json');
        req.setMethod('POST');
        req.setEndpoint(objAuthenticationInfo.instance_url+'/services/apexrest/AutomaticCommunityAccess');
        req.setBody(system.JSON.serialize(userObj));
        HttpResponse res = h.send(req);
        return res;
    }
    
    private static OAuth2 getAccessToken() {
        String SERVER_URL = LMA_Config__c.getOrgDefaults().End_Point__c; //'https://login.salesforce.com';
        String USERNAME = BPUtility.getDecodedString(LMA_Config__c.getOrgDefaults().Username__c);//'mcube_admin@blackpurl.com';
        String PASSWORD = BPUtility.getDecodedString(LMA_Config__c.getOrgDefaults().Password__c); //'Welcome@12345#';
        String SECURITY_TOKEN = LMA_Config__c.getOrgDefaults().Security_Token__c; //'5nmSgKRcaWa8COTv0bowXJFas';
        String CLIENT_ID = LMA_Config__c.getOrgDefaults().Client_Id__c; //'3MVG9szVa2RxsqBbM1uD0dFuYZ3UKKmTwYlJPav.G5vkeMwf1FzozCajgwn7zCRz.F9htQenvGWQ3IiwRMuTj';
        String CLIENT_SECRET = LMA_Config__c.getOrgDefaults().Client_Secret__c; //'1813374359520083531';
        
        return getAccessToken(CLIENT_ID, CLIENT_SECRET, USERNAME, PASSWORD + SECURITY_TOKEN, SERVER_URL);
    }
    
    private static OAuth2 getAccessToken(String clientId, String clientSecret, String userName, String passwordWithToken, String serverURL) {
        String reqbody = 'grant_type=password&client_id='+clientId+'&client_secret='+clientSecret+'&username='+userName+'&password='+passwordWithToken;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setBody(reqbody);
        req.setMethod('POST');
        req.setEndpoint(serverURL + '/services/oauth2/token');
        HttpResponse res;
        if(!Test.isRunningTest()) {
            res = h.send(req);
            //system.assert(false, res.getbody());
        } else {
            res = new HttpResponse();
            res.setBody('{"access_token":"SESSION_ID_REMOVED","instance_url":"https://cs19.salesforce.com","id":"https://test.salesforce.com/id/00D29000000DNQ2EAO/00541000000Q9RQAA0","token_type":"Bearer","issued_at":"1549878853633","signature":"YeB5e+1veVl4CG27qxxTxloCokn6ZOd4fGryt/+dXSc="}');
        }
        
        OAuth2 objAuthenticationInfo = (OAuth2)JSON.deserialize(res.getbody(), OAuth2.class);
        return objAuthenticationInfo;
    }
    
    // To get aouthentication detail Wrapper
    private class OAuth2 {
        private String id;
        private String issued_at;
        private String instance_url;
        private String signature;
        private String access_token;    
    }
    
    private class UserDetailWrapper {
        public String UserDetails;
        public UserDetailWrapper(String firstName, String lastName, String email, String orgId) {
            this.UserDetails = system.JSON.serialize(new UserDetail(firstName, lastName, email, orgId));
        }
    }
    
    private class UserDetail {
        public String FirstName;
        public String LastName;
        public String OrgId;
        public String Email;
        
        private UserDetail(String firstName, String lastName, String email, String orgId) {
            this.FirstName = firstName;
            this.LastName = lastName;
            this.Email = email;
            this.OrgId = orgId;
        }
    }
    
    private class UserFedIdWrapper {
        public String FedId;
    }
}