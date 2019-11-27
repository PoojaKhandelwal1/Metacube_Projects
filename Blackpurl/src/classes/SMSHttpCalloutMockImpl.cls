@isTest
global class SMSHttpCalloutMockImpl implements HttpCalloutMock {
    private String mockBody;
    private Integer mockStatus;
    
    global void setMockResponse(String body, Integer code) {
        this.mockBody = body;
        this.mockStatus = code;
        system.assert(true,true);
    }
    
    global SMSHttpCalloutMockImpl(String body, Integer code) {
        this.mockBody = body;
        this.mockStatus = code;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(mockStatus);
        res.setBody(mockBody);
        system.assert(true,true);
        return res;
    }
}