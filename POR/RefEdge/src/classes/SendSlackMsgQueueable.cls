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
 * Description: queueable class to send messages to slack
 * Modified by: Gaurav Saini (5 Apr, 2017)
 */
public with sharing class SendSlackMsgQueueable implements Queueable, Database.AllowsCallouts {

    private String msgBody;
    private String slackTeamIds;

    public SendSlackMsgQueueable(String msgBody, String slackTeamIds) {
        this.msgBody = msgBody;
        this.slackTeamIds = slackTeamIds;
    }

    public void execute(QueueableContext context) {
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', slackTeamIds);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());

        List<Map<String, String>> messagesList = new List<Map<String, String>>();
        Map<String, String> tempReqBodyMap = new Map<String, String>();
        tempReqBodyMap.put('text', msgBody);
        messagesList.add(tempReqBodyMap);

        slackReqBody.put('messages', messagesList);
        UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
    }
}