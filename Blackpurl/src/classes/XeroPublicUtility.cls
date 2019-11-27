public class XeroPublicUtility { 

    public static String Consumer_Key; 
    public static String Request_Token_URL = 'https://api.xero.com/oauth/RequestToken';
    public static String Consumer_Secret; 
    public static String Temporary_Token_Secret; 
    public static String OAuth_Token; 
    public static String Access_Token_URL = 'https://api.xero.com/oauth/AccessToken'; 
    public static String OAuth_Token_Secret; 
    public static String End_Point_URL;
    public static String Http_Method;
    public static Integer Request_Timeout_In_MiliSec = Integer.valueOf(5000);


    public static HttpResponse executeOauth1Callout(String method, String requestBody, String ConsumerKey, String ConsumerSecret, String AccessToken, String AccessTokenSecret, String endpoint_URL) {
        HttpResponse res = new HttpResponse();

        Http_Method = method;
        Consumer_Key = ConsumerKey;
        Consumer_Secret = ConsumerSecret;
        OAuth_Token = AccessToken;
        OAuth_Token_Secret = AccessTokenSecret;
        End_Point_URL = endpoint_URL;

        // State: No Access Token
        // Action: Authorize

        // State: Has Access Token
        // Action: Perform Callout
            res=XeroRequest(requestBody);
            // State: 401 Unauthorized
            // Action: Re-Authorize

            // State: Response Code is Not 401
            // Action Return response
            Return res;


    }

    public static String generateHeader(String signature, Map<String,String> parameters) {
        String header = 'OAuth ';
        for (String key : parameters.keySet()) {
            header = header + key + '="'+parameters.get(key)+'", ';
        }
        return header + 'oauth_signature="' + signature + '"';
    }

    public static String generateSignature(HttpRequest req, String consumerSecret, String tokenSecret, Map<String,String> parameters) {
        String s    = createBaseString(req, parameters);         
        String key  = consumerSecret+'&'+tokenSecret;
        Blob sig = Crypto.generateMac('HmacSHA1', Blob.valueOf(s), Blob.valueOf(key));
        String signature = EncodingUtil.urlEncode(EncodingUtil.base64encode(sig), 'UTF-8');
        return signature;
    }


    private static String createBaseString(HttpRequest req, Map<String,String> parameters) {
        Map<String,String> p = parameters.clone();
        String host = req.getEndpoint();
        Integer n = host.indexOf('?');
        if(n>-1) {
            p.putAll(getUrlParams(host.substring(n+1)));
            host = host.substring(0,n);
        }
        List<String> keys = new List<String>();
        keys.addAll(p.keySet());
        keys.sort();
        String s = keys.get(0)+'='+p.get(keys.get(0));
        for(Integer i=1;i<keys.size();i++) {
            s = s + '&' + keys.get(i)+'='+p.get(keys.get(i));
        }
 
        return req.getMethod().toUpperCase()+ '&' +
            EncodingUtil.urlEncode(host, 'UTF-8') + '&' +
            EncodingUtil.urlEncode(s, 'UTF-8');
    }
    
    private static Map<String,String> getUrlParams(String value) {
        Map<String,String> res = new Map<String,String>();
        if(value==null || value=='') {
            return res;
        }
        for(String s : value.split('&')) {
            System.debug('getUrlParams: '+s);
            List<String> kv = s.split('=');
            if(kv.size()>1) {
                // RFC 5849 section 3.4.1.3.1 and 3.4.1.3.2 specify that parameter names 
                // and values are decoded then encoded before being sorted and concatenated
                // Section 3.6 specifies that space must be encoded as %20 and not +
                String encName = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[0], 'UTF-8'), 'UTF-8').replace('+','%20');
                String encValue = EncodingUtil.urlEncode(EncodingUtil.urlDecode(kv[1], 'UTF-8'), 'UTF-8').replace('+','%20');
                System.debug('getUrlParams:  -> '+encName+','+encValue);
                res.put(encName,encValue);
            }
        }
        return res;
    }

    private static Map<String,String> parseResponse(HttpResponse res) {
        Map<String,String> responseMap = new Map<String,String>();
        if(res.getStatusCode() == 200){
            String resParams = res.getBody();
            responseMap.put('responseBody', resParams);
        }else{
            responseMap.put('responseBody', res.getStatus());
        }
        return responseMap;
    }
    
    public static HttpResponse XeroRequest(String requestBody){
        System.debug('***************-------------') ;
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        String APIURL = End_Point_URL; 
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_consumer_key', Consumer_Key);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_token', EncodingUtil.urlEncode(OAuth_Token, 'UTF-8'));
        parameters.put('oauth_version', '1.0');
        
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint(APIURL);
        req.setMethod(Http_Method); 
        req.setTimeout(Request_Timeout_In_MiliSec); 
        if(String.isNotBlank(requestBody)) req.setBody(requestBody);
        
        String signature = generateSignature(req, Consumer_Secret, OAuth_Token_Secret, parameters);
        String header = generateHeader(signature, parameters);
        
        req.setHeader('Authorization', header);
        req.setHeader('Accept', 'application/json');
        req.setHeader('Content-type', 'application/json');
        Http http = new Http();
        res = http.send(req); 
        System.debug('***************' + res.getBody() + '-------------') ;
        return res;
    }
    
    
    public static Map<String,String> getResponseNVP(HttpRequest req){
        
        Http http = new Http();
        HttpResponse res;

        res = http.send(req); 
        String resParams = res.getBody();
            
        Map<String,String> rp = new Map<String,String>();
        
        for(String s : resParams.split('&')) {
            List<String> kv = s.split('=');
            rp.put(kv[0],kv[1]);
        }
        
        return rp;
    }
    
    public static HttpResponse OAuthConnectionStep2(String tokenParm, String tokenVerifier) {
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        
        IFW_IntegrationConfig__c configRec = AccountingIntegrationSettingsService.getIntegrationConfig('Xero');
        Consumer_Key = configRec.Consumer_Key__c;
        Consumer_Secret = configRec.Consumer_Secret__c;
        String tokenParmSecret = configRec.Access_Token_Secret__c;
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Oauth_callback', 'UTF-8'));
        parameters.put('oauth_consumer_key', Consumer_Key);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_token', tokenParm);
        parameters.put('oauth_verifier', tokenVerifier);
        parameters.put('oauth_version', '1.0');
        
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint(Access_Token_URL);
        req.setMethod('POST');
        req.setTimeout(Request_Timeout_In_MiliSec);
        String signature = XeroPublicUtility.generateSignature(req, Consumer_Secret, tokenParmSecret, parameters);
        
        String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Oauth_callback' + '&';
        body += 'oauth_consumer_key=' + Consumer_Key + '&';
        body += 'oauth_nonce=' + nonce + '&';
        body += 'oauth_signature_method=HMAC-SHA1&';
        body += 'oauth_timestamp=' + timestamp + '&';
        body += 'oauth_version=1.0&';
        body += 'oauth_token=' + tokenParm + '&';
        body += 'oauth_verifier=' + tokenVerifier + '&';
        body += 'oauth_signature=' + signature; 
        
        req.setBody(body);
        Http http = new Http();
        res = http.send(req);

        return res;
    }
    
    
    public static HttpResponse OAuthConnection(String ConsumerKey, String ConsumerSecret){
        Consumer_Key = ConsumerKey;
        Consumer_Secret = ConsumerSecret;
        String nonce = String.valueOf(Crypto.getRandomLong());
        String timestamp = string.valueof(dateTime.now().getTime()/1000);
        
        Map<String,String> parameters = new Map<String,String>();
        parameters.put('oauth_callback', EncodingUtil.urlEncode(URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Oauth_callback', 'UTF-8')); 
        parameters.put('oauth_consumer_key', Consumer_Key);
        parameters.put('oauth_nonce', nonce);
        parameters.put('oauth_signature_method', 'HMAC-SHA1');
        parameters.put('oauth_timestamp', timestamp);
        parameters.put('oauth_version', '1.0');
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        req.setEndpoint(Request_Token_URL); 
        req.setMethod('POST'); 
        req.setTimeout(Request_Timeout_In_MiliSec);
        String signature = XeroPublicUtility.generateSignature(req, Consumer_Secret, '', parameters);
        
        String body = 'oauth_callback=' + URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Oauth_callback' + '&';
        body += 'oauth_consumer_key=' + Consumer_Key + '&';
        body += 'oauth_nonce=' + nonce + '&';
        body += 'oauth_signature_method=HMAC-SHA1&';  
        body += 'oauth_timestamp=' + timestamp + '&';
        body += 'oauth_version=1.0&';
        body += 'oauth_signature=' + signature;
        req.setBody(body);
        Http http = new Http();

        res = http.send(req);
        return res;
    }
}