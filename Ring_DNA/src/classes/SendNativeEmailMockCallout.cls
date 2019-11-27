@isTest
global class SendNativeEmailMockCallout implements HttpCalloutMock{
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest request) {
		// Create a mock response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		string str ='{"success": true,"failureReason": null}';
		response.setBody(str);
		response.setStatusCode(200);
		return response; 
	}

}