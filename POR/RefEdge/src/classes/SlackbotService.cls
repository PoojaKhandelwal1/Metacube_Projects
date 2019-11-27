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
 * Description: API to be called from the bot application to populate slack team data
 * author: Gaurav Saini (1 May, 2019 - REF-2006)
 */
@RestResource(urlMapping='/rebot/*')
global with sharing class SlackbotService {

    @HttpPost
    global static void saveTeamId() {
        RestResponse res = RestContext.response;
        RestRequest req = RestContext.request;

        try {
            Map<String, String> reqBody
                = (Map<String, String>)JSON.deserialize(req.requestBody.toString(), Map<String, String>.class);
            Custom_Settings__c cs = UtilityController.getCustomSettings(); 

            if (reqBody.containsKey('addTeam') && reqBody.get('addTeam') != null) {

                if (cs.Slack_Team_Ids__c == null) {
                    cs.Slack_Team_Ids__c = reqBody.get('addTeam');
                } else if (!cs.Slack_Team_Ids__c.contains(reqBody.get('addTeam'))) {
                    cs.Slack_Team_Ids__c = cs.Slack_Team_Ids__c + ',' + reqBody.get('addTeam');
                }
            }

            if (reqBody.containsKey('removeTeam') && reqBody.get('removeTeam') != null) {
                String newTeamIds = '';

                for (String oldTeamId : cs.Slack_Team_Ids__c.split(',')) {

                    if (oldTeamId != reqBody.get('removeTeam')) {
                        newTeamIds = newTeamIds == '' ? oldTeamId : newTeamIds + ',' + oldTeamId;
                    }
                }
                cs.Slack_Team_Ids__c = newTeamIds;
            }
            update cs;
            res.responseBody = Blob.valueOf('done');
            res.statusCode = 200;
        } catch(Exception e) {
            system.debug('Exception: ' + e.getMessage());
            res.responseBody = Blob.valueOf('Exception: ' + e.getMessage());
            res.statusCode = 500;
        }
    }
}