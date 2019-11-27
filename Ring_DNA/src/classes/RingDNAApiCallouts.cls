public class RingDNAApiCallouts {

	private String sessionId;
	private String accountId;
	private String userId;
	private String host; 
	private final String HTTP_METHOD = 'GET';
	private final String BASE_URL = 'api/v2/app';
	private final String ACCOUNT_DETAILS_PATH = 'salesforce/verify';
	private final String CALL_NOTE_TEMPLATES_PATH = 'callNoteTemplates';
	private final String SMS_TEMPLATES_PATH = 'smsTemplates';
	private final String VOICEMAIL_DROPS_PATH = 'voicemailDrops';

	private final String HTTP_METHOD_POST = 'POST';
	private final String BASE_URL_SEQUENCE = 'api/v2/sequence';
	private final String SEND_EMAIL_PATH = 'messages/send';  
	private final String SEND_MASS_EMAIL_PATH = 'messages/sendMultiple';  
	private final String API_KEY ;
	private final String API_SECRET;

	public RingDNAApiCallouts() {
		Map<String, String> dataFromCustomSetting = RingDNAHost.getBaseUri();
		host = dataFromCustomSetting.get('Host');
		API_KEY = dataFromCustomSetting.get('ApiKey');
		API_SECRET = dataFromCustomSetting.get('ApiSecret');
		Map<String, Object> accountDetails = getAccountDetails();
		if(accountDetails != null && !accountDetails.isEmpty()) {
			sessionId = String.valueOf(accountDetails.get('sessionId'));
			accountId = String.valueOf(accountDetails.get('accountId'));
			userId = String.valueOf(accountDetails.get('userId'));
		}	
	} 

	public RingDNAApiCallouts(Boolean isNative) {
		Map<String, String> dataFromCustomSetting = RingDNAHost.getBaseUri();
		host = dataFromCustomSetting.get('Host');
		API_KEY = dataFromCustomSetting.get('ApiKey');
		API_SECRET = dataFromCustomSetting.get('ApiSecret');
	}

	public Map<String, Object> getAccountDetails() {
		String uri = host + '/' + ACCOUNT_DETAILS_PATH;
		String endpoint = uri +
				'?' + 'sfUserId=' + UserInfo.getUserId() +
				'&' + 'sfSessionId='  + getSessionIdFrmVFPg(Page.SessionIdVfPage);

		if(test.isRunningTest()) Test.setMock(HttpCalloutMock.class, new AccountDetailsMockClass());
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, null);
		if(httpResponse == null) {
			return null;
		}
		else{
			Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(httpResponse.getBody());
			return jsonMap;
		}
	}

	public Map<String, String> getCallNoteTemplates() {
		String uri = host + '/' + BASE_URL + '/' + CALL_NOTE_TEMPLATES_PATH;
		String endpoint = uri + '?' + 'accountId=' + accountId;
		if(sessionId == null || host == '') {
			return New Map<String, String>();
		}
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);

		List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		Map<String, String> callTemplatesData = new Map<String, String>();	
		for (Object obj : jsonList) {
			Map<String, Object> objMap = (Map<String, Object>)obj;
			if((Boolean)objMap.get('enabled')) {
				callTemplatesData.put(String.valueOf(objMap.get('id')), String.valueOf(objMap.get('name'))); 	   
			}
		}
		return callTemplatesData;
	}
	public List<Object> getCallNoteTemplatesUpdated() {
		String uri = host + '/' + BASE_URL + '/' + CALL_NOTE_TEMPLATES_PATH;
		String endpoint = uri + '?' + 'accountId=' + accountId;
		if(sessionId == null || host == '') {
			return New List<Object>();
		}
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);
		List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		return jsonList;
	} 

	public Map<String, String> getSMSTemplates() {
		String uri = host + '/' + BASE_URL + '/' + SMS_TEMPLATES_PATH;
		String endpoint = uri + '?' + 'sessionId='+ sessionid + '&' +'accountId=' + accountId;

		if(sessionId == null || host == '') {
			return New Map<String, String>();
		}
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);

		List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		Map<String, String> smsTemplatesData = new Map<String, String>();	
		for (Object obj : jsonList) {
			Map<String, Object> objMap = (Map<String, Object>)obj;
			if((Boolean)objMap.get('enabled')) {
				smsTemplatesData.put(String.valueOf(objMap.get('id')), String.valueOf(objMap.get('name'))); 	   
			} 
		}
		return smsTemplatesData;
	} 
	public List<Object> getSMSTemplatesUpdated() {
		String uri = host + '/' + BASE_URL + '/' + SMS_TEMPLATES_PATH;
		String endpoint = uri + '?' + 'sessionId='+ sessionid + '&' +'accountId=' + accountId;
		if(sessionId == null || host == '') {
			return New List<Object>();
		}
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);
		List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		return jsonList;
	} 

	public Map<String, String> getVoicemailDrops() {

		String uri = host + '/' + BASE_URL + '/' + VOICEMAIL_DROPS_PATH;
		String endpoint = uri + '?' +'accountId=' + accountId;
		if(sessionId == null || host == '') {
			return New Map<String, String>();
		} 
		HTTPResponse httpResponse = getResponse(HTTP_METHOD, endpoint, sessionId);
		List<Object> jsonList = (List<Object>)JSON.deserializeUntyped(httpResponse.getBody());
		Map<String, String> voicemailDropsData = new Map<String, String>();	
		for (Object obj : jsonList) {
			Map<String, Object> objMap = (Map<String, Object>)obj;
			voicemailDropsData.put(String.valueOf(objMap.get('id')), String.valueOf(objMap.get('label'))); 	   
		}
		return voicemailDropsData;
	}

	public HTTPResponse getResponse(String requestType, String endpoint, String sessionId) {
		try {
			Http http = new Http();
			HttpRequest httpRequest = new HttpRequest();
			httpRequest.setMethod(requestType);
			httpRequest.setEndpoint(endpoint);
			if(sessionId != null) {
				httpRequest.setHeader('sessionId', sessionId);    
			}
			return http.send(httpRequest);
		}  catch(Exception e) {
			return null;
		}
	}

	public String getSessionIdFrmVFPg(PageReference vfPageContainSessionId){
		String data ='';
		if(!test.isRunningTest()){
			try{
				data= vfPageContainSessionId.getContent().toString();
			}catch(Exception ex){
				data =  'Session_Id_Start_Here'+userinfo.getSessionId()+'Session_Id_End_Here';
			}
		}else{
			data =  'Session_Id_Start_Here'+userinfo.getSessionId()+'Session_Id_End_Here';
		}
		return data.substring(data.indexOf('Session_Id_Start_Here') + 'Session_Id_Start_Here'.length(), data.indexOf('Session_Id_End_Here'));
	}

	public Map<String, Object> sendNativeEmail(String toEmail, String toName, String body, String actionId, String subject, String userId) {
		String uri = host + '/' + BASE_URL_SEQUENCE + '/' + SEND_EMAIL_PATH;
		toName = toName == null ? '' : toName;
		//Adding parameters in endpoint
		String endpoint = uri 
				+ '?toEmail=' + toEmail 
				+ '&subject=' + EncodingUtil.urlEncode(subject, 'UTF-8') 
				+ '&toName=' + EncodingUtil.urlEncode(toName, 'UTF-8') 
				+ '&apiKey=' + EncodingUtil.urlEncode(API_KEY, 'UTF-8')
				+ '&apiSecret=' + EncodingUtil.urlEncode(API_SECRET, 'UTF-8') 
				+ '&sfOrgId=' + CadenceConstants.ORANIZATION_ID
				+ '&sfUserId=' + userId
				+ '&actionId=' + EncodingUtil.urlEncode(actionId, 'UTF-8');
		if(! Test.isRunningTest() && (host == '' || API_KEY == '' || API_SECRET == '' || (userId == null || (userId != null && userId == ''))) ) {
			return New Map<String, Object>();
		}

		HttpRequest httpRequest = new HttpRequest();        
		httpRequest.setEndpoint(endpoint);
		httpRequest.setBody(body.replaceAll('(\\r|\\n)+', '<br>'));

		HTTPResponse httpResponse = postResponse(httpRequest);
		Map<String, Object> objMap = new Map<String, Object>();
		if (httpResponse != null && httpResponse.getStatusCode() == 200){
			Object obj = JSON.deserializeUntyped(httpResponse.getBody());
			objMap = (Map<String, Object>)obj; 
		}
		return objMap;
	}
	public List<NativeEmailRespose> sendNativeMassEmail(List<NativeEmailMessage> nativeEmailMessageList) {
		List<NativeEmailRespose> nativeEmailResposeList = new List<NativeEmailRespose>();
		String endpoint = host + '/' + BASE_URL_SEQUENCE + '/' + SEND_MASS_EMAIL_PATH;
		if(! Test.isRunningTest() && (host == '' || API_KEY == '' || API_SECRET == '') ) {
			return nativeEmailResposeList;
		}

		HttpRequest httpRequest = new HttpRequest();        
		httpRequest.setEndpoint(endpoint);
		httpRequest.setHeader('Content-Type', 'application/json');
		httpRequest.setHeader('Accept', 'application/json');
		httpRequest.setBody(RingDNAApiCalloutsHelper.getMessageClauseToSentNativeEmail(nativeEmailMessageList,API_KEY, API_SECRET));
		HTTPResponse httpResponse = postResponse(httpRequest);
		if (httpResponse != null && httpResponse.getStatusCode() == 200){
			nativeEmailResposeList = RingDNAApiCalloutsHelper.processApiResponse(httpResponse);
		}
		return nativeEmailResposeList;
	}
	private HTTPResponse postResponse(HttpRequest httpRequest) {
		try {            
			httpRequest.setMethod(HTTP_METHOD_POST);
			return new Http().send(httpRequest);
		}  catch(Exception e) {
			return null;
		}
	}
}