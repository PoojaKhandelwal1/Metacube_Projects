public class BasicAuthUtility {

  
    public static HttpResponse performCallout(IFW_IntegrationConfig__c Parent, IFW_IntegrationConfigItem__c child, String Body, list<customHttpHeaderWrapper> headerList) {
        HttpResponse ret = performCallout( Parent,  child,  Body,  headerList, null);
        return ret; 
    }
    public static HttpResponse performCallout(IFW_IntegrationConfig__c Parent, IFW_IntegrationConfigItem__c child, String Body, list<customHttpHeaderWrapper> headerList, map<String,String> Params) {
        //system.debug('perform callout');
        Http callout = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

            integer timeout = 6000;
            if (child.timeout__c > 0) timeout=integer.valueOf(child.timeout__c);
            else timeout = integer.valueOf(parent.timeout__c);

            req.setTimeout(timeout);

            for (customHttpHeaderWrapper h: headerList){
                req.Setheader(h.headerType,h.headerValue);
            }

            Blob headerValue = Blob.valueOf(Parent.Username__c + ':' + Parent.Password__c);
            String endpoint = child.endpoint_URL__c;
            Set<String> keyset = params.keyset();
            if (keyset.size()>0) endpoint+='?';
            for (string k: keyset) {
                endpoint+=k+'='+Params.get(k);
            }
            //

            system.debug(endpoint);
            req.setendpoint(endpoint);
            req.setmethod(child.Http_Method__c); 
            if (Body.length()>0) req.setbody(Body);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            //String authorizationHeader = 'Basic QkxBQ0tQVVJMOmJycA==';
            req.setHeader('Authorization', authorizationHeader); 

            if (!Test.isRunningTest()) res = callout.send(req);
        
        return res;
        
    }

        public static customHttpHeaderWrapper buildCustomHttpHeader(String key, String value) {

        return new customHttpHeaderWrapper(key, value);
    }

}