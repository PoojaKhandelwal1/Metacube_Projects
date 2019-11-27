@isTest
global class SendMessageMockTest implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest request){
    	HttpResponse res = new HttpResponse();
    	res.setHeader('Content-Type', 'application/json');
    	MessageResponse messageResponse = new MessageResponse();
        messageResponse.message = 'available';
        messageResponse.message_uuid = new List<String>();
        messageResponse.error = 'error';
        messageResponse.api_id = 'apiid';   
    	res.setBody(json.serialize(messageResponse, true));
    	res.setStatusCode(200);
    	return res;
    }
}