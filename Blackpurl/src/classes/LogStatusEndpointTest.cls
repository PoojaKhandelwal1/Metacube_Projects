@isTest
private class LogStatusEndpointTest {
  
  
  static testMethod void LogServiceEndpointTest() {
    // Set up a test request
    RestRequest request = new RestRequest();
    // Set request properties
    request.requestUri =
        'https://na75.salesforce.com/services/apexrest/LogStatus/';
    request.httpMethod = 'POST';
    // Set other properties, such as parameters
    String body = '{"startDate":"2013-01-30T07:38:44Z","endDate":"2020-01-30T07:38:44.268Z"}';
    request.requestbody = Blob.valueOf(body);
    // more awesome code here....
    // Finally, assign the request to RestContext if used
    RestContext.request = request;
 	logStatusEndpoint.getLogs();
  }
  
}