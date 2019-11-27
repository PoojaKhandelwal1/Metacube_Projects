global with sharing class Quickbooks_oauth_callbackController {
    
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    
    public Quickbooks_oauth_callbackController(){
    	
    	Application = GlobalController.GetResourceURL('Application');
    	Application_Images = GlobalController.GetResourceURL('Application_Images');
    	Assests = GlobalController.GetResourceURL('Assests');
    	
    }
    /**
	 * Name: getFilterObjectTypes
	 * Description: Method to get the object labels which can be filtered on home search screen filter diaplog box
	 * @Param:	
	 * @Return:	String - JSON Sting
	 * 
	**/
	@RemoteAction   
    global static String saveAccessSecretsKeys(String oauth_token, String oauth_verifier, String realmId) {
    	oauth_token = BPUtility.getDecodedString(oauth_token);
    	oauth_verifier = BPUtility.getDecodedString(oauth_verifier);
    	realmId = BPUtility.getDecodedString(realmId);
    	String returnRespose = '';
    	try {
	    	HttpResponse apiResponse = QuickbookConnector.OAuthConnectionStep2(oauth_token, oauth_verifier);
	    	if(apiResponse.getStatusCode() == 200){
	    		Map<String,String> responseItems = new Map<String, String>();
		        for(String s : apiResponse.getBody().split('&')) {
		            List<String> kv = s.split('=');
		            responseItems.put(kv[0],kv[1]);
		        }
		        
		        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
		        qbConfig.OAuth_Token__c = responseItems.get('oauth_token');
	        	qbConfig.OAuth_Token_Secret__c = responseItems.get('oauth_token_secret');
		        qbConfig.Company_Id__c = realmId;
		        update qbConfig;
		        returnRespose = 'success';
		        
	    	}else{
	    		returnRespose = apiResponse.getBody();
	    	}
	    } catch(Exception e) {
            returnRespose = e.getMessage();       
        }
    	returnRespose = BPUtility.getEncodedString(returnRespose);
    	return returnRespose;
    }
}