public class SMSRestApi{

    public String AUTH_ID;
    private String AUTH_TOKEN;
    public final String PLIVO_URL = 'https://api.plivo.com';
    public String PLIVO_VERSION = 'v1';
    public String BaseURI;
    HttpRequest req;

    public SMSRestApi(String auth_id, String auth_token, String version1){
        AUTH_ID = auth_id;
        AUTH_TOKEN = auth_token;
        PLIVO_VERSION = version1;
        String baseuri_placeHolder = '{0}/{1}/Account/{2}';
        List<String> baseuri_fillers = new String[]{PLIVO_URL,PLIVO_VERSION,AUTH_ID};
        BaseURI = String.format(baseuri_placeHolder,baseuri_fillers);

        // Create Request
        req = new HttpRequest();

        // Request Authorization
        Blob headerValue = Blob.valueOf(auth_id + ':' + auth_token);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);

        // Set Authorization Header
        req.setHeader('Authorization', authorizationHeader);
    }

    public String request(String method, String resource, Map<String, String> parameters){
        Http http = new Http();
        HTTPResponse res;
        String jsonn = '';
        String final_json = '';
        try {
            String serialized = JSON.serialize(parameters);
            String endpoint = BaseURI + resource;
            req.setMethod(method);
            req.setEndpoint(endpoint);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(serialized);
            res = http.send(req);
        } catch( CalloutException e){
            //throw new PlivoException(e.getStackTraceString());
        }
		
        Integer server_code = res.getStatusCode();
        String code = String.valueOf(server_code);
        String resp = res.getBody();
        String replace = '\"server_code\": "{0}",';
        List<String> replace_with = new String[]{code};
        String replaced = String.format(replace,replace_with);
        String final_replace = '{ ' + replaced;
        jsonn = resp.replaceFirst('\\{', final_replace);
        if (jsonn.contains('limit')){
            jsonn = jsonn.replace('\"limit\": ', '\"limitt\": ');
        }
        if (jsonn.contains('number')){
            jsonn = jsonn.replace('\"number\": ', '\"plivo_number\": ');
        }
        if (jsonn.contains('from')){
            jsonn = jsonn.replace('\"from\": ', '\"from_number\": ');
        }
        // System.debug('final json : ' + jsonn);
        return jsonn;
    }
    
    // Send a Message
    public MessageResponse sendMessage(Map<String, String> parameters){
        // System.debug('inside sendMessage');
        return (MessageResponse)JSON.deserialize(request('POST', '/Message/', parameters), MessageResponse.class);
    }
}