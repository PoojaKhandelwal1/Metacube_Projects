/**
 * Author: Gaurav Tak
 * Since: Mar 07, 2019
 * Name: IntegrationMockHttpResponseGenerator 
 * Description: Test class for Base Integration callouts
**/
@isTest
global with sharing class IntegrationMockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{}');
        res.setHeader('Content-Type', 'application/json');
        return res;
    }
}