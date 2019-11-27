/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS-IS" BY POINT OF REFERENCE ("POR"), 
 * WITH NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, 
 * EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR NON-INFRINGEMENT. 
 * POR SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, 
 * MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. POR IS NOT LIABLE FOR, 
 * AND MAKES NO REPRESENTATIONS OR WARRANTIES REGARDING, THE ACTIONS OR OMISSIONS OF 
 * ANY THIRD PARTIES (OR THE PRODUCTS OR SERVICES OFFERED BY ANY THIRD PARTIES) INCLUDING, 
 * WITHOUT LIMIATION, SALESFORCE.COM. COPY, USE OR DISTRIBUTION PROHIBITED WITHOUT EXPRESS 
 * WRITTEN CONSENT FROM COMPANY.
 */  
/**
 * Class: SlackbotService
 * Description: test class for API to connect to slack teams
 * author: Gaurav Saini (3 May, 2019)
 */
@isTest(seeAllData = false)
public with sharing class TestSlackbotService {

    static testmethod void testAddTeamId() {
        User u = TestDataFactory.CreateUser();

        Test.startTest();
            System.runAs(u) {
                Custom_Settings__c cs = TestDataFactory.createCustomSetting();
                String reqBody = '{"addTeam":"test team id 2"}';
                RestRequest req = new RestRequest();
                req.requestURI = String.format('{0}/services/apexrest/rebot', new List<String>{URL.getSalesforceBaseURL().toExternalForm()});
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueof(reqBody);
                RestContext.request = req;
                RestResponse res = new RestResponse();
                RestContext.response = res;
                SlackbotService.saveTeamId();
                system.assert(res.statusCode == 200);
            }
        Test.stopTest();
    }

    static testmethod void testRemoveTeamId() {
        User u = TestDataFactory.CreateUser();

        Test.startTest();
            System.runAs(u) {
                Custom_Settings__c cs = TestDataFactory.createCustomSetting();
                cs.Slack_Team_Ids__c = 'test team id 1,test team id 2';
                update cs;
                String reqBody = '{"removeTeam":"test team id 1"}';
                RestRequest req = new RestRequest();
                req.requestURI = String.format('{0}/services/apexrest/rebot', new List<String>{URL.getSalesforceBaseURL().toExternalForm()});
                req.httpMethod = 'POST';
                req.requestBody = Blob.valueof(reqBody);
                RestContext.request = req;
                RestResponse res = new RestResponse();
                RestContext.response = res;
                SlackbotService.saveTeamId();
                system.assert(res.statusCode == 200);

                String reqBodyError = 'test';
                req.requestBody = Blob.valueof(reqBodyError);
                SlackbotService.saveTeamId();
                system.assertEquals(res.statusCode, 500);
            }
        Test.stopTest();
    }
}