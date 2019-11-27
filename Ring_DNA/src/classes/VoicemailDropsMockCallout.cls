@isTest
global class VoicemailDropsMockCallout implements HttpCalloutMock{
	// Implement this interface method
	global HTTPResponse respond(HTTPRequest request) {
		// Create a mock response
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		string str ='[{"isGlobal": true,"id": 6787, "isDeleted": false, "label": "Sumit 1","owner": null,"url": "https://ringdna.s3.amazonaws.com/qa/audio/10000630/automated-voicemail-e8d07de5-df51-4e50-b489-bd019eeae222.wav"},{"isGlobal": true,"id": 6824, "isDeleted": false, "label": "Test","owner": null,"url": "https://ringdna.s3.amazonaws.com/qa/audio/10000630/automated-voicemail-79a21ead-3341-4a6d-a79c-fa04e3576a26.wav"}]';
		response.setBody(str);
		response.setStatusCode(200);
		return response; 
	}

}