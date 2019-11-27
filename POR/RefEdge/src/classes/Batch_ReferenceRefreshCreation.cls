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
 * Class: Schedular_ReferenceRefresh, ReferenceRefreshSettings
 * Description : This Batch called from Schedular_ReferenceRefresh, ReferenceRefreshSettings to generate Profile Updates
 * Modified by: Gaurav Saini (16 June, 2017) for #764
 */
global with sharing class Batch_ReferenceRefreshCreation implements Database.Batchable<sObject>, Database.stateful, Database.AllowsCallouts {
    /**
     * Properties and variables
     */
    private Boolean fromGenerateLink = false;
    private String soqlQuery = '';
    private Set<String> ownerIds;
    private Custom_Settings__c cs;
    private List<Reference_Refresh__c> insertedRefRefresh;
    private Date todayDate = Date.Today();
    private Boolean checkChatterSetting;
    private Boolean checkEmailSetting;
    private Boolean checkSlackSetting;
	
    /**
     * Constructor
     */
    global Batch_ReferenceRefreshCreation() {
        ownerIds = new Set<String>();
        insertedRefRefresh = new List<Reference_Refresh__c>();
    }
	
    /**
     * Constructor 2
     */
    global Batch_ReferenceRefreshCreation(Boolean linkBoolean) {
        fromGenerateLink = linkBoolean;
        ownerIds = new Set<String>();
        insertedRefRefresh = new List<Reference_Refresh__c>();
    }
	
    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        cs = UtilityController.getCustomSettings();
        checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Reference_Update_Chatter__c);
        checkEmailSetting = cs.Reference_Update_Email__c;
        checkSlackSetting = cs.Enable_Slack_Integration__c && cs.Reference_Update_Slack__c;
        // query changed for #764 - retrieving inactive program member accounts as well
        soqlQuery = 'SELECT Account__c, Account__r.Name, Att_Ref_Last_Update_By__c, Account__r.OwnerId, '
    				+ 'Account__r.Owner.Email, Last_Refresh_Date__c, Last_Refresh_By__c, Owner.Id, '
    				+ 'Managed_Reference_Account__c, Profile_Update_Owner__c, Reference_Owner__c, Reference_Owner__r.Id, '
    				+ 'Reference_Owner__r.Email, Last_Refresh_Sent__c, Last_Att_Ref_Update__c, CreatedDate, '
    				+ 'Refresh_Ageing__c, (SELECT Id, Reference_Refresh_Status__c, Is_Active__c, Quarantined__c '
										+ 'FROM Reference_Refreshs__r WHERE Is_Active__c = true) '
    				+ 'FROM Reference_Basic_Information__c WHERE Contact__c = null '
    				+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'\'';
        return Database.getQueryLocator(soqlQuery);
    }
	
    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Reference_Basic_Information__c> scope) {
        List<Reference_Basic_Information__c> updateRBI = new List<Reference_Basic_Information__c>();
        List<Reference_Refresh__c> insertRefRefresh = new List<Reference_Refresh__c>();
        List<Reference_Refresh__c> insertPendingRefRefresh = new List<Reference_Refresh__c>();
		
        if (cs.Refresh_Wait_Days__c != null && cs.Enable_Reference_Refresh__c) {
            List<Reference_Refresh__c> updateRefRefresh = new List<Reference_Refresh__c>();
            
            for (Reference_Basic_Information__c rbi : scope) {
                
                if (!rbi.Managed_Reference_Account__c
                		|| (rbi.Managed_Reference_Account__c && rbi.Profile_Update_Owner__c != null)) {
                    Boolean isMatched = false;
                    
                    if ((rbi.Last_Refresh_Date__c != null
                    			&& rbi.Last_Refresh_Date__c.dateGMT().daysBetween(todayDate) >= cs.Refresh_Wait_Days__c)
                			&& (rbi.Last_Refresh_Sent__c == null
                				|| (rbi.Last_Refresh_Sent__c != null
                					&& rbi.Last_Refresh_Sent__c.dateGMT().daysBetween(todayDate) >= cs.Refresh_Wait_Days__c))) {
                        isMatched = true;
                    }
                    
                    // Check Request Pending profile Updates
                    if (!isMatched && rbi.Reference_Refreshs__r.size() > 0
                			&& rbi.Reference_Refreshs__r.get(0).Reference_Refresh_Status__c == 'Request Pending') {
                        isMatched = true;
        			}
                    
                    if (rbi.Reference_Refreshs__r.size() > 0 && rbi.Reference_Refreshs__r.get(0).Quarantined__c
                    		&& (rbi.Reference_Refreshs__r.get(0).Reference_Refresh_Status__c == 'Profile Updated'
                    			|| rbi.Reference_Refreshs__r.get(0).Reference_Refresh_Status__c == 'Pending Approval')) {
                        isMatched = false;
                    }
                    
                    if (isMatched) {
                    	
                        for (Reference_Refresh__c rr : rbi.Reference_Refreshs__r) {
                        	
                            if (rr.Reference_Refresh_Status__c != 'Request Pending') {
                                rr.Is_Active__c = false;
                                updateRefRefresh.add(rr);
                            }
                        }
                        Reference_Refresh__c tempRR = (rbi.Reference_Refreshs__r.size() > 0
                        									&& rbi.Reference_Refreshs__r.get(0).Reference_Refresh_Status__c == 'Request Pending'
                    									? rbi.Reference_Refreshs__r.get(0)
                    									: new Reference_Refresh__c(Reference_Account__c = rbi.Account__c));
                        tempRR.Is_Active__c = true;
                        tempRR.Reference_Refresh_Owner__c = (rbi.Profile_Update_Owner__c == null
                    											? (rbi.Reference_Owner__c != null
                    												? rbi.Reference_Owner__r.Id
                    												: rbi.Account__r.Owner.Id)
                												: rbi.Profile_Update_Owner__c);
                        tempRR.Reference_Profile__c = rbi.Id;
                        tempRR.Quarantined__c = cs.Quarantine_updates__c;
                        
                        if (cs.Manual_Automatic_Launch__c == 'Manual' && fromGenerateLink) {
                            tempRR.Reference_Refresh_Status__c = 'Request Pending';
                            insertPendingRefRefresh.add(tempRR);
                        } else {
                            tempRR.Reference_Refresh_Status__c = 'Request Sent';
                            insertRefRefresh.add(tempRR);
                        }
                        rbi.Last_Refresh_Sent__c = date.today();
                        updateRBI.add(rbi);
                    }
                }
            }
            
            if (updateRBI.size() > 0) {
                update updateRBI;
            }
			
            if (updateRefRefresh.size() > 0) {
                update updateRefRefresh;
            }
			
            if (insertRefRefresh.size() > 0) {
                upsert insertRefRefresh;
                insertedRefRefresh.addAll(insertRefRefresh);
            }
			
            if (insertPendingRefRefresh.size() > 0) {
                upsert insertPendingRefRefresh;
            }
        }
    }
	
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
    	
        if (insertedRefRefresh.size() > 0) {
            List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
            List<sobject> postFeedItems = new List<sobject>();
            Set<String> ownerPresent = new Set<String>();
            Map<String, String> ownerEmailId = new Map<String, String>();
            Map<String, Set<String>> ownerAccounts = new Map<String, Set<String>>();
            Map<String, String> ownerName = new Map<String, String>();
            String headerDocId = '';
            String footerDocId = '';
            Data_Mapping__c profileUpdateNotification = new Data_Mapping__c();
            Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Reference_Update_Email__c'};

            for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = 'Notification'
                                        AND (Field_API_Name__c IN :notificationFieldNames
                                            OR Section_Name__c = 'email header doc'
                                            OR Section_Name__c = 'email footer doc')]) {

                if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Reference_Update_Email__c') {
                    profileUpdateNotification = dm;
                } else if (dm.Section_Name__c == 'email header doc') {
                    headerDocId = dm.Field_API_Name__c;
                } else if (dm.Section_Name__c == 'email footer doc') {
                    footerDocId = dm.Field_API_Name__c;
                }
            }
            Map<String, Object> slackReqBody = new Map<String, Object>();
            slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
            slackReqBody.put('orgId', UserInfo.getOrganizationId());
            List<Map<String, String>> messagesList = new List<Map<String, String>>();
            
            for (Reference_Refresh__c rr : [SELECT Reference_Refresh_Owner__c, Reference_Refresh_Owner__r.FirstName,
            								Reference_Account__r.Name, Reference_Refresh_Owner__r.Email
            								FROM Reference_Refresh__c
            								WHERE Id IN :insertedRefRefresh
            								AND Is_Active__c = true]) {
            	
                if (!ownerEmailId.containsKey(rr.Reference_Refresh_Owner__c)) {
                    ownerEmailId.put(rr.Reference_Refresh_Owner__c, rr.Reference_Refresh_Owner__r.Email);
                    ownerAccounts.put(rr.Reference_Refresh_Owner__c, new Set<String> ());
                    ownerName.put(rr.Reference_Refresh_Owner__c, rr.Reference_Refresh_Owner__r.FirstName);
                }
                ownerAccounts.get(rr.Reference_Refresh_Owner__c).add(rr.Reference_Account__r.Name);
            }
            String notificationBody = profileUpdateNotification.DC_Message__c + '\n\n';
            
            if (checkEmailSetting) {
            	
                for (String ownerId : ownerEmailId.keySet()) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    String[] toAddresses = new String[]{ownerEmailId.get(ownerId)};
                    mail.setToAddresses(toAddresses);
                    mail.setSubject(profileUpdateNotification.Section_Name__c);
                    String body = MailChatterController.prepareBodyForRefRefresh(ownerAccounts.get(ownerId), notificationBody, ownerId, profileUpdateNotification.Section_Name__c, false);
                    mail.setHtmlBody(MailChatterController.setHtmlEmailBody(body, headerDocId, footerDocId));
                    listmail.add(mail);
                }
            }
            
            if (checkSlackSetting) {
            	
                for (String ownerId : ownerEmailId.keySet()) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('userEmail', ownerEmailId.get(ownerId));
                    tempReqBodyMap.put('text', MailChatterController.prepareBodyForRefRefresh(ownerAccounts.get(ownerId), notificationBody, ownerId, profileUpdateNotification.Section_Name__c, true));
                    messagesList.add(tempReqBodyMap);
                }
            }
            
            if (checkChatterSetting) {
            	
                for (String ownerId : ownerEmailId.keySet()) {
                    postFeedItems.add(MailChatterController.preparechatterForRefRefresh(ownerAccounts.get(ownerId), ownerId, notificationBody, profileUpdateNotification.Section_Name__c));
                }
            }
            
            if (messagesList != null && messagesList.size() > 0) {
            	slackReqBody.put('messages', messagesList);
            	UtilityController.postMsgToSlackSync(JSON.serialize(slackReqBody));
            }

            if (listmail.size() > 0) {
                Messaging.sendEmail(listmail);
            }
            
            // Insert list of postFeedItems
            if (postFeedItems.size() > 0) {
                Database.SaveResult[] postItems = database.insert(postFeedItems, false);
            }
        }
        
        if (cs != null) {
            List<CronTrigger> listCronTrigger = [SELECT NextFireTime FROM CronTrigger
	        										WHERE Id = :cs.cloneTriggerId__c
	        										LIMIT :limits.getLimitQueryRows()];
            cs.Last_Refresh_Date__c = Date.today();
            cs.Next_Refresh_launch_Date__c = (listCronTrigger.size() > 0
            									? Date.valueOf(listCronTrigger.get(0).NextFireTime)
            									: null);
            update cs;
        }
    }
}