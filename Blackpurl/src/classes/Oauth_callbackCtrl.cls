global without sharing class Oauth_callbackCtrl {
    
    public static String Application {get;}
    public static String Assests {get;}
    
    public Oauth_callbackCtrl() {
        Application = GlobalController.GetResourceURL('Application');
        Assests = GlobalController.GetResourceURL('Assests');
    }
    
    @RemoteAction
    global static String saveAccessSecretKeys(String urlParams) {
        urlParams = BPUtility.getDecodedString(urlParams);
        oAuthWrapper urlParamObj = (oAuthWrapper) system.JSON.deserialize(urlParams, oAuthWrapper.class);
        String returnRespose = '';
        try {
            HttpResponse response = XeroPublicUtility.OAuthConnectionStep2(urlParamObj.oauth_token, urlParamObj.oauth_verifier);
            if(response.getStatusCode() == 200) {
                Map<String, String> responseItemMap = AccountingIntegrationSettingsService.parseOAuthStep1Response(response.getBody());
                AccountingIntegrationSettingsService.saveOauthTokenSecret(responseItemMap.get('oauth_token'), responseItemMap.get('oauth_token_secret'), 'Xero');
                returnRespose = 'success';
            } else {
            	IFW_IntegrationConfig__c configRec = AccountingIntegrationSettingsService.getIntegrationConfig('Xero');
	        	configRec.Access_Token_Secret__c = null;
	        	update configRec;
                returnRespose = response.getBody();
            }
        } catch(Exception e) {
        	IFW_IntegrationConfig__c configRec = AccountingIntegrationSettingsService.getIntegrationConfig('Xero');
        	configRec.Access_Token__c = null;
        	update configRec;
            returnRespose = e.getMessage();       
        }
        returnRespose = BPUtility.getEncodedString(returnRespose);
        return returnRespose;
    }
    
    public class oAuthWrapper {
        public String oauth_token;
        public String oauth_verifier;
        public String org;
    }
}