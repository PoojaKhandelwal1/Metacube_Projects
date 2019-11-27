@Istest
global class AccountDetailsMockClass implements HttpCalloutMock{
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest request) {
		// Create a mock response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		string str ='{"accountId": 10000630,"sessionId": "2e3dbbe5_8217_48f9_86de_7287a37bd6c2","userId": 3274}' ;
		response.setBody(str);
		response.setStatusCode(200);
		return response; 
	} 
}