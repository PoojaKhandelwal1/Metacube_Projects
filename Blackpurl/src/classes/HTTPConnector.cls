public class HTTPConnector {
    
    public HttpResponse doPost(String endPoint, String requestBody, String contentType) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', contentType); 
        req.setHeader('Accept-Language', 'en-US');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('accept', contentType);
        req.setEndpoint(endPoint);
        req.setBody(requestBody);
        HttpResponse res = h.send(req);
        return res;
    } 
    
    public HttpResponse doGet(String endPoint, Map<String, String> paramNameToParamValueMap, String contentType) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', contentType);
        req.setHeader('Accept-Language', 'en-US');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('accept', contentType);
        for(String paramName : paramNameToParamValueMap.keySet()) {
            req.setHeader(paramName, paramNameToParamValueMap.get(paramName));
        }
        req.setEndpoint(endPoint);
        HttpResponse res;
        if(Test.isRunningTest()) {
        	res = new HttpResponse();
        	if(endPoint.contains(DP360_Configuration__c.getOrgDefaults().End_Point_URL__c)){
        		res.setBody('{"code":200,"data":[{"id":3767376,"first_name":"scott","last_name":"carthey","user_id":232,"company_id":"5000","phone":"156-333-2233","mobile":"7546232125","work_number":"789456123","address":"","email":"scottcarthey@gmail.com","zip":"","city":"","state":"","status":"Negotiate-Floor","lead_status":"Open","sales_step":"6","year":2016,"make":"Forest River","model":"364TS","vin":"1F66F5DY0G0A06626","stock_num":null,"class":"6","created":"2016-10-05T18:50:34+0000","modified":"2016-11-03T09:19:56+0000","crm_lead_url":"https://app.dealershipperformancecrm.com/contacts/leads_main/view/3767376","dealer_id":"5000","dealervu_customer_id":"","dealervu_deal_id":"","dealervu_inventory_id":""}],"message":"Success"}');
        	}
        } else {
        	res = h.send(req);
        }
        return res;
    }
    
    public HttpResponse doGetWithBody(String endPoint, Map<String, String> paramNameToParamValueMap, String contentType, String body) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Content-Type', contentType);
        req.setHeader('Accept-Language', 'en-US');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('accept', contentType);
        req.setBody(body);
        for(String paramName : paramNameToParamValueMap.keySet()) {
            req.setHeader(paramName, paramNameToParamValueMap.get(paramName));
        }
        req.setEndpoint(endPoint);
        HttpResponse res;
        if(Test.isRunningTest()) {
            res = new HttpResponse();
            if(endPoint.contains(DP360_Configuration__c.getOrgDefaults().End_Point_URL__c)){
                res.setBody('{"code":200,"data":[{"id":3767376,"first_name":"scott","last_name":"carthey","user_id":232,"company_id":"5000","phone":"156-333-2233","mobile":"7546232125","work_number":"789456123","address":"","email":"scottcarthey@gmail.com","zip":"","city":"","state":"","status":"Negotiate-Floor","lead_status":"Open","sales_step":"6","year":2016,"make":"Forest River","model":"364TS","vin":"1F66F5DY0G0A06626","stock_num":null,"class":"6","created":"2016-10-05T18:50:34+0000","modified":"2016-11-03T09:19:56+0000","crm_lead_url":"https://app.dealershipperformancecrm.com/contacts/leads_main/view/3767376","dealer_id":"5000","dealervu_customer_id":"","dealervu_deal_id":"","dealervu_inventory_id":""}],"message":"Success"}');
            }
        } else {
            res = h.send(req);
        }
        return res;
    }
    
    public HttpResponse doPostWithParam(String endPoint, String requestBody, String contentType, Map<String, String> paramNameToParamValueMap) {
    	
    	Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type', contentType);
        req.setHeader('Accept-Language', 'en-US');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('accept', contentType);
        req.setEndpoint(endPoint);
        req.setBody(requestBody);
        for(String paramName : paramNameToParamValueMap.keySet()) {
            req.setHeader(paramName, paramNameToParamValueMap.get(paramName));
        }
        HttpResponse response = h.send(req);
        return response;
    }
    
    public HttpResponse doPutWithParam(String endPoint, String requestBody, String contentType, Map<String, String> paramNameToParamValueMap) {
    	
    	Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('PUT');
        req.setHeader('Content-Type', contentType);
        req.setHeader('Accept-Language', 'en-US');
        req.setHeader('Connection', 'Keep-Alive');
        req.setHeader('accept', contentType);
        req.setEndpoint(endPoint);
        req.setBody(requestBody);
        for(String paramName : paramNameToParamValueMap.keySet()) {
            req.setHeader(paramName, paramNameToParamValueMap.get(paramName));
        }
        HttpResponse response = h.send(req);
        return response;
    }
}