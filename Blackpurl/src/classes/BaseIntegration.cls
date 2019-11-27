public without sharing abstract class BaseIntegration {
    public static List<WebService_Log__c> webServiceLogs;
  
    public static String performCallout(Id childId, String body, list<customHttpHeaderWrapper> headerList) {
        return performCallout(childId, body, headerList, new Map<String, String>());
    }
    
    public static String performCallout(Id childId, String body, list<customHttpHeaderWrapper> headerList, Map<String,String> Parameters) {
        IFW_IntegrationConfigItem__c child = getChild(childId);
	    IFW_IntegrationConfig__c parent = getParent(child.IFW_IntegrationConfig__c);
	    if (IFW_IntegrationConfigItem__c.id == null) throw new applicationException ('Child not found');
	    HttpResponse res = performCallout(parent, child, body, headerList, Parameters);
	    if(webServiceLogs.size() > 0) {
	        insert webServiceLogs;
	    }
	    return res.getBody();
    }
    
    public static HttpResponse performCallout(IFW_IntegrationConfig__c parent, IFW_IntegrationConfigItem__c child, String body, list<customHttpHeaderWrapper> headerList) {
        return performCallout(parent, child, body, headerList, new Map<String, String>());
    }
    
    public static HttpResponse performCallout(IFW_IntegrationConfig__c parent, IFW_IntegrationConfigItem__c child, String body, 
                                                list<customHttpHeaderWrapper> headerList, Map<String,String> Parameters) {
		    Http callout=new Http();
            HttpRequest req=new HttpRequest();
            HttpResponse res=new HttpResponse();
            if (child.timeout__c > 0) req.setTimeout(integer.valueOf(child.timeout__c));
            else req.setTimeout(integer.valueOf(parent.timeout__c));
            for (customHttpHeaderWrapper h: headerList){
                req.Setheader(h.headerType,h.headerValue);
            }
            system.debug('Request Body'+ body);
            String authorizationHeader;
            
            WebService_Log__c wsLog = new WebService_Log__c();
            wsLog.CalloutStartTime__c = double.valueOf(DateTime.now().GetTime());
            wsLog.IFW_IntegrationConfig__c = parent.id;
            wsLog.name = parent.Integration_Name__c + ' ' +string.valueOf(Datetime.now());
        
            switch on parent.Auth_Scheme__c {
                when 'Basic' {       
                    res = BasicAuthUtility.performCallout(parent, child, Body, headerList, Parameters);
                    //system.debug(res.getStatusCode()+':'+res.getStatus()+ ' ' +res.getBody());
                }   
                when 'OAuth1.0' {
                    system.debug(child.HTTP_Method__c);
                    system.debug(body);
                    system.debug(parent.Consumer_Key__c);
                    system.debug(child.Endpoint_URL__c);
                    system.debug(parent.Certificate_Name__c);
                    res = OAuthUtility.executeOauth1Callout(child.HTTP_Method__c, body, parent.Consumer_Key__c, child.Endpoint_URL__c, parent.Certificate_Name__c);
                    system.debug(res.getBody());
                }
                when else {       
                    throw new applicationException ('Unsupported Auth Scheme: '+parent.Auth_Scheme__c);
                }
    
           }
            wsLog.Callout_End_Time__c = double.valueOf(DateTime.now().GetTime());
            wsLog.Request_Body__c = body;
            wslog.Response_Code__c = string.valueOf(res.getStatusCode());
            wsLog.Response_Body__c = res.getBody().abbreviate(32768);
            wslog.Status__c = res.getStatus();
            wsLog.endpoint__c = child.endpoint_URL__c;
            if (wsLog.Response_Code__c != '200') wslog.Response_Description__c = res.getBody().abbreviate(255);
            //insert wsLog;
            if(webServiceLogs != null) {
        	webServiceLogs.add(wsLog);
        } else {
        	webServiceLogs = new List<WebService_Log__c>{wsLog};
        }
            //system.assert(false,res);
            return res;
	  }
    
    public static IFW_IntegrationConfigItem__c getChild(Id cId) {
        return [select    Id,
                          IFW_IntegrationConfig__c,
                          Endpoint_URL__c,
                          HTTP_Method__c,
                          Timeout__c
                          from  IFW_IntegrationConfigItem__c
                          where Id = :cId];
    }
    public static IFW_IntegrationConfig__c getParent(Id pId) {
        return [select   Id,
                  Access_Token__c,
                  Auth_Scheme__c,
                  Bearer_Token__c,
                  Certificate_Name__c,
                  Certifcate_Password__c,
                  Consumer_Key__c,
                  Consumer_Secret__c,
                  Enabled__c,
                  Integration_Name__c,
                  Grant_Type__c,
                  Password__c,
                  Username__c,
                  Refresh_Token__c,
                  Timeout__c,
                  Token_Expiry__c,
                  Token_Type__c
         from IFW_IntegrationConfig__c
         where id = :pId];
    }
    
    //standard salesforce error response structure
    public class SalesforceError {
       public String errorCode;
       public String message;
       public SalesforceError(String errorCode, string message){
          this.errorCode = errorCode;
          this.message = message;
       }
    }

    public class applicationException extends Exception {}
    
}