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
 * VF Page: ReferenceByLeadSLDS.page
 * Description: Class to manage reference lead request
 * Author: Gaurav Saini (18 April, 2017)
 * Last modified by: Gaurav Saini (18 April, 2017)
 */
public with sharing class ReferenceByLeadControllerSLDS extends RefEdgeEditionFeatures {
    
    public String refLeadId { get; set; }
    public String followUpDaysListJSON { get; set; }
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.referencebylead.getURL() + '?id=';
    //  REF-2008    To check whether to show notification on screen or not
	public Boolean isScreenNotification{ get; set; }

    /**
     * constructor to use this as an extension on RefProspectorResponsePage
     * author: Gaurav Saini (16 Nov, 2017) #1104
     */
    public ReferenceByLeadControllerSLDS(RefProspectorResponseController controller) {}
    
    public ReferenceByLeadControllerSLDS(ApexPages.StandardController controller) {
    	refLeadId = '';
    	List<String> followUpDaysList = new List<String>();
    	
    	if (ApexPages.currentPage().getParameters().get('Id') != null) {
	    	refLeadId = ApexPages.currentPage().getParameters().get('Id');
    	}
    	Schema.DescribeFieldResult dfr
    			= Schema.sObjectType.Reference_Lead__c.fields.getMap().get(UtilityController.appNamespace() + 'Follow_Up_Timeframe__c').getDescribe();
        
        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            followUpDaysList.add(String.valueOf(ple.getValue()));
        }
        followUpDaysListJSON = JSON.serialize(followUpDaysList);
        isScreenNotification = cs.User_Reward_Onscreen_Notification__c;
    }
    
    /**
     * method to get the reference lead object
     * author: Gaurav Saini (18 April, 2017) for #5
     */
    @RemoteAction
    public static String getRefLead(String refLeadId) {
    	List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getReferenceLead(refLeadId);
    	List<RefLeadWrapper> refLeadWrapperList = new List<RefLeadWrapper>();
    	
    	if (refLeads != null && refLeads.size() > 0) {
    		refLeadWrapperList.add(new RefLeadWrapper(refLeads[0]));
    		return JSON.serialize(refLeadWrapperList);
    	} else {
    		return '';
    	}
    }
    
    /**
     * method to get the account referenceable status
     * author: Gaurav Saini (18 April, 2017) for #5
     */
    @RemoteAction
    public static Boolean isAccountReferenceable(String accountId) {
    	List<Reference_Basic_Information__c> accRBIList
    				= WithoutSharingHelperController.getRBIReferenceable((Id)accountId);
		
		if (accRBIList != null && accRBIList.size() > 0) {
			return accRBIList[0].Is_Referenceable__c;
		} else {
			return false;
		}
    }
    
    /**
     * method to save the ref lead object
     * author: Gaurav Saini (24 April, 2017) for #5
     */
    @RemoteAction
    public static String saveRefLead(String refLeadJSON, Boolean isFromRefProspect) {
    	String result = '';
    	Savepoint sp = Database.setSavepoint();
    	
    	try {
    		RefLeadWrapper refLeadWrapperObj = (RefLeadWrapper)JSON.deserialize(refLeadJSON, RefLeadWrapper.class);
	    	List<Reference_Lead__c> refLeads = WithoutSharingHelperController.getReferenceLead(refLeadWrapperObj.refLeadId);
	    	List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
	        List<sObject> postFeedItems = new List<sObject>();
	        String previousOwnerName = refLeadWrapperObj.refLeadOwnerName;
	        // added for #959
	        String prospectPageURL = URL.getSalesforceBaseUrl().toExternalForm() + Page.RefProspectorResponsePage.getURL();
            String headerDocId = '';
            String footerDocId = '';
            Data_Mapping__c checkBackNotification = new Data_Mapping__c();
            Data_Mapping__c ownerUpdateNotification = new Data_Mapping__c();
            Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Check_back_in_Email__c', UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Email__c'};

            for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = 'Notification'
                                        AND (Field_API_Name__c IN :notificationFieldNames
                                            OR Section_Name__c = 'email header doc'
                                            OR Section_Name__c = 'email footer doc')]) {

                if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Check_back_in_Email__c') {
                    checkBackNotification = dm;
                } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Ref_Lead_Owner_Update_Email__c') {
                    ownerUpdateNotification = dm;
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
	    	
	    	if (refLeads != null && refLeads.size() > 0) {
	    		Reference_Lead__c tempRefLead = refLeads[0];
	    		
		    	if (refLeadWrapperObj.followUpTimeFrame != '' && refLeadWrapperObj.refLeadOwnerId == '') {
		    		String mailBody = checkBackNotification.DC_Message__c;
                    mailBody = mailBody.replace('[Opportunity Account]', refLeadWrapperObj.accountName)
                                        .replace('[Specified Timeframe]', refLeadWrapperObj.followUpTimeFrame);
	                String days = refLeadWrapperObj.followUpTimeFrame.split(' ')[0];
	                tempRefLead.Response_received__c = true;
	                tempRefLead.Notification_response__c = 'Check back with me later';
	                tempRefLead.Follow_up_date__c = date.today() + Integer.valueOf(days);
	                tempRefLead.Reminder_Date__c = (cs.RLF_Reminder_Days__c != null
	                									? date.today().addDays(Integer.valueOf(days)
	                												+ Integer.Valueof(cs.RLF_Reminder_Days__c)) : null);
	                tempRefLead.Reference_Lead_Status__c = 'Follow up';
	                
	                if (cs.No_Response_days__c != null) {
	                    tempRefLead.No_Response_Date__c
	                    		= tempRefLead.Follow_up_date__c.addDays(Integer.valueOf(cs.No_Response_days__c));
	                }
	                tempRefLead = WithoutSharingHelperController.updateRefLead(tempRefLead);
			    	result = 'success';
	                
	                if (cs.Check_back_in_Chatter__c && UtilityController.isNativeChatterSetting) {
	                    postFeedItems.add(MailChatterController.preparePost(checkBackNotification.Section_Name__c.replace('[Opportunity Account]', refLeadWrapperObj.accountName),
                                                                            tempRefLead.Reference_Lead_Owner__c, mailBody, ''));
	                }
	                
	                if (cs.Check_back_in_Email__c) {
	                    listmail.add(MailChatterController.prepareEmail(checkBackNotification.Section_Name__c.replace('[Opportunity Account]', refLeadWrapperObj.accountName),
                                                                        tempRefLead.Reference_Lead_Owner__c, mailBody, true, headerDocId, footerDocId));
	                }
	                
	                if (cs.Enable_Slack_Integration__c && cs.Check_back_in_Slack__c) {
                        Map<String, String> tempReqBodyMap = new Map<String, String>();
                        tempReqBodyMap.put('userEmail', refLeadWrapperObj.refLeadOwnerEmail);
                        tempReqBodyMap.put('text', '*' + checkBackNotification.Section_Name__c.replace('[Opportunity Account]', refLeadWrapperObj.accountName) + '*\n' + mailBody);
                        messagesList.add(tempReqBodyMap);
	                }
		    	} else if (refLeadWrapperObj.followUpTimeFrame == '' && refLeadWrapperObj.refLeadOwnerId != '') {
		    		tempRefLead.Response_received__c = true;
	                tempRefLead.Notification_response__c = 'I don\'t know, I\'m not the right person to ask';
	                tempRefLead.Reference_Lead_Owner__c = refLeadWrapperObj.refLeadOwnerId;
	                tempRefLead = WithoutSharingHelperController.updateRefLead(tempRefLead);
	                result = 'success';
	                String mailBody = '';
	                
	                if (isFromRefProspect) {
	                	mailBody = refLeadWrapperObj.refLeadOwnerName + ',\n\n'
        								+ (cs.Ref_Prospector_Body__c != null
        									? cs.Ref_Prospector_Body__c
        									: 'The customer reference team is always seeking new ways to showcase client success. Accounts including the ones below have been identified as owned by you and potential candidates for the customer reference program. Do you think they would act as a reference at this time?')
    									+ '\n\n' + 'Accounts requiring your review include:\n'
    									+ refLeadWrapperObj.accountName;
	                	
	                	if (UtilityController.isNativeChatterSetting) {
	                		postFeedItems.add(MailChatterController.preparePost((cs.Ref_Prospector_Subject__c != null
																					? cs.Ref_Prospector_Subject__c
																					: 'Potential Reference Accounts'),
	                    														tempRefLead.Reference_Lead_Owner__c,
	                    														mailBody,
	                    														prospectPageURL));
	                	}
	                	listmail.add(MailChatterController.prepareEmail((cs.Ref_Prospector_Subject__c != null
																			? cs.Ref_Prospector_Subject__c
																			: 'Potential Reference Accounts'),
																		tempRefLead.Reference_Lead_Owner__c,
																		mailBody + '\n\n' + prospectPageURL,
																		true));
                        
                        if (cs.Enable_Slack_Integration__c) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', refLeadWrapperObj.refLeadOwnerEmail);
                            tempReqBodyMap.put('text', mailBody + '\n<' + prospectPageURL + '|'
                                    + (cs.Ref_Prospector_Subject__c != null ? cs.Ref_Prospector_Subject__c : 'Potential Reference Accounts') + '>');
                            messagesList.add(tempReqBodyMap);
                        }
	                } else {
		                mailBody = ownerUpdateNotification.DC_Message__c;
                        mailBody = mailBody.replace('[Opportunity Account]', refLeadWrapperObj.accountName)
                                            .replace('[Opportunity Owner]', previousOwnerName)
                                            .replace('[Opportunity Name]', refLeadWrapperObj.oppName);
		                
		                if (cs.Ref_Lead_Owner_Update_Chatter__c && UtilityController.isNativeChatterSetting) {
		                    postFeedItems.add(MailChatterController.preparePost(ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', refLeadWrapperObj.accountName),
                                                                                tempRefLead.Reference_Lead_Owner__c, mailBody, LINK_URL + tempRefLead.Id));
		                }
		                
		                if (cs.Ref_Lead_Owner_Update_Email__c) {
		                    listmail.add(MailChatterController.prepareEmail(ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', refLeadWrapperObj.accountName),
                                                                            tempRefLead.Reference_Lead_Owner__c, mailBody + '\n\n' + ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', refLeadWrapperObj.accountName)
                                                                            + ': <a href="' + LINK_URL + tempRefLead.Id + '">' + LINK_URL + tempRefLead.Id + '</a>', true, headerDocId, footerDocId));
		                }

                        if (cs.Enable_Slack_Integration__c && cs.Ref_Lead_Owner_Update_Slack__c) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', refLeadWrapperObj.refLeadOwnerEmail);
                            tempReqBodyMap.put('text', mailBody + '\n<' + LINK_URL + tempRefLead.Id + '|'
                                    + ownerUpdateNotification.Section_Name__c.replace('[Opportunity Account]', refLeadWrapperObj.accountName) + '>');
                            messagesList.add(tempReqBodyMap);
                        }
	                }
	                
	                // re #119 - Added sales rewards for User  
	                if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {
		                List<Referenceability_Type__c> refType = [SELECT Name, Id, Sales_Point__c
		                											FROM Referenceability_Type__c
		                											WHERE Visible__c = true AND Sales_Reward__c = true
		                											AND Referenceability_code__c = :ConstantsController.RLF_REFERRED
		                											ORDER BY Referenceability_code__c LIMIT 1];
		                
		                // re #633 - Check null value for Sales point 
		                if (refType.size() > 0 && refType[0].Sales_Point__c != null) {
		                    List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
		                    
		                    if (tempRefLead.Response_Received__c == true ) {
		                        Reference_Lead__c refId = [SELECT OwnerId FROM Reference_Lead__c
		                        							WHERE Id = :tempRefLead.Id LIMIT 1];
		                        rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
		                        									Referenceability_Type__c = refType[0].Id,
		                        									Transaction__c = ConstantsController.ISSUE,
		                        									RewardDate__c = Date.Today(),
		                        									User__c = UserInfo.getUserId()));	// re #240
		                        UtilityController.isUserProfileExist(refId.OwnerId);
		                        String rewardPoints = String.valueOf(refType[0].Sales_Point__c);
		                        String actionMessage =  refType[0].Name;
		                        result += '***' + rewardPoints + '***' + actionMessage;
		                    }
		                    
		                    if (rewardsToBeInsert.size() > 0) {
		                        WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
		                    }
						}
					}
		    	} else if (refLeadWrapperObj.followUpTimeFrame == '' && refLeadWrapperObj.refLeadOwnerId == '') {
		    		tempRefLead.Response_received__c = true;
		    		tempRefLead.Reference_Lead_Status__c = 'No Updates';
	                tempRefLead = WithoutSharingHelperController.updateRefLead(tempRefLead);
	                result = 'success';
		    	}
	    	}
			
	        if (listmail.size() > 0) {
	            Messaging.sendEmail(listmail);
	        }
	        
	        if (postFeedItems.size() > 0) {
	            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
	        }

            if (messagesList != null && messagesList.size() > 0) {
            	slackReqBody.put('messages', messagesList);
            	UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
            }
    	} catch(Exception e) {
    		Database.rollback(sp);
    		result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return result;
    }
    
    /**
	 * Wrapper Class for reference lead object
	 */
    public class RefLeadWrapper {
    	public String refLeadId { get; set; }
    	public String status { get; set; }
    	public String refProfileId { get; set; }
    	public String accountId { get; set; }
    	public String accountName { get; set; }
    	public String nominationId { get; set; }
    	public String oppId { get; set; }
    	public String oppName { get; set; }
    	public String refLeadOwnerName { get; set; }
    	public String refLeadOwnerId { get; set; }
    	public String refLeadOwnerEmail { get; set; }
    	public String followUpTimeFrame { get; set; }
    	public Boolean createNomination { get; set; }
    	
    	public RefLeadWrapper(Reference_Lead__c refLead) {
    		this.refLeadId = refLead.Id;
    		this.status = refLead.Reference_Lead_Status__c;
	    	this.refProfileId = refLead.Reference_Profile__c;
	    	this.accountId = refLead.Reference_Lead_Account__c;
	    	this.accountName = refLead.Reference_Lead_Account__r.Name;
	    	this.nominationId = refLead.Nomination__c;
	    	this.oppId = refLead.Reference_Lead_Opportunity__c;
	    	this.oppName = refLead.Reference_Lead_Opportunity__r.Name;
	    	this.refLeadOwnerName = refLead.Reference_Lead_Owner__r.Name;
	    	this.refLeadOwnerEmail = refLead.Reference_Lead_Owner__r.Email;
	    	this.refLeadOwnerId = '';
	    	this.followUpTimeFrame = '';
	    	this.createNomination = cs.Create_Nomination__c;
    	}
    }
}