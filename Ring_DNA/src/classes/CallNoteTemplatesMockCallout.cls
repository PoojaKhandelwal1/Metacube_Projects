@Istest
global class CallNoteTemplatesMockCallout implements HttpCalloutMock{
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest request) {
		// Create a mock response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		string str ='[{"enabled":true,"groups":[],"id":461,"name":"Sumit Call Notes","template":"Implementing it in cadence"}]' ;
		response.setBody(str);
		response.setStatusCode(200);
		return response; 
	} 
}