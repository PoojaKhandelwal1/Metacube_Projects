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
 * VF Page: LaunchRefProspectorCampaignPage.page
 * Description: controller for launching the reference prospector campaign
 * Author: Gaurav Saini (6 Nov, 2017)
 */
public with sharing class LaunchRefProspectorCampaignController extends RefEdgeEditionFeatures {
    
    public Boolean isSLDS { get; set; }
    public Boolean isFromCustomSettings { get; set; }
    public String refLeadListViewId { get; set; }
	public String refLeadIdPrefix { get; set; }
	public String nameSpace { get; set; }
    
    public LaunchRefProspectorCampaignController(ApexPages.StandardSetController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        isFromCustomSettings = ApexPages.currentPage().getParameters().get('isFromCustomSettings') != null
        						? ApexPages.currentPage().getParameters().get('isFromCustomSettings') == 'true' : false;
    	nameSpace = UtilityController.appNamespace();
    	String objName = nameSpace + 'Reference_Lead__c';
    	refLeadListViewId = WithoutSharingHelperController.getListViewId(objName);
    	refLeadIdPrefix = Reference_Lead__c.sObjectType.getDescribe().getKeyPrefix();
    }
    
    /**
     * method to check permissions
     * author: Gaurav Saini (8 Nov, 2017)
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c',
    										new Set<String>{UtilityController.appNamespace() + 'Ref_Prospector_Lead_Count__c',
    											UtilityController.appNamespace() + 'Ref_Prospector_Campaign_Lead_Count__c'});
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Lead__c',
    										new Set<String>{UtilityController.appNamespace() + 'Initial_Notification_Sent__c',
    											UtilityController.appNamespace() + 'Initial_Notification_Date__c',
    											UtilityController.appNamespace() + 'Reference_Lead_Status__c',
    											UtilityController.appNamespace() + 'Reminder_Date__c',
    											UtilityController.appNamespace() + 'No_Response_Date__c',
    											UtilityController.appNamespace() + 'Ref_Lead_Campaign_Name__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
    }
    
    /**
     * method to get permissions message
     * author: Gaurav Saini (8 Nov, 2017)
     */
    @RemoteAction
    public static String getPermissionsMessage() {
    	checkPermissions();
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * method to get custom settings
     * author: Gaurav Saini (6 Nov, 2017)
     */
    @RemoteAction
    public static String getCustomSettings() {
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	CustomSettingWrapper csWrapper = new CustomSettingWrapper(cs);
    	return JSON.serialize(csWrapper);
    }
    
    /**
     * method to launch the campaign and send ref lead notifications
     * author: Gaurav Saini (6 Nov, 2017)
     */
    @RemoteAction
    public static String launchCampaign(String customSettingWrapperJSON) {
    	String result = '';
    	Savepoint sp = Database.setSavepoint();
    	
    	try {
	    	CustomSettingWrapper csWrapper = (CustomSettingWrapper)JSON.deserialize(customSettingWrapperJSON, CustomSettingWrapper.class);
    		List<Reference_Lead__c> existingRefLeads = WithoutSharingHelperController.getRefLeadsForLaunchCampaign();
    		List<Reference_Lead__c> refLeadsToUpdate = new List<Reference_Lead__c>();
    		List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
    		List<sObject> postFeedItems = new List<sObject>();
    		String emailBody = csWrapper.salutation + '$$$$,\n\n' + csWrapper.body;
    		Map<String, List<String>> userAccountMap = new Map<String, List<String>>();
    		RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
    		String refedgeUserId = protectedAppConfig.User_Id__c;
			String pageURL = URL.getSalesforceBaseUrl().toExternalForm() + Page.RefProspectorResponsePage.getURL();
			Custom_Settings__c cs = UtilityController.getCustomSettings();
			Set<String> alreadyNotifiedUsers = new Set<String>();
    		
    		for (Reference_Lead__c refLead : existingRefLeads) {
    			
    			if (refLead.Ref_Lead_Include_in_Campaign__c) {
    				refLead.Initial_Notification_Sent__c = true;
    				refLead.Initial_Notification_Date__c = Date.today();
    				refLead.Reference_Lead_Status__c = 'Initial Notification Sent';
    				refLead.Reminder_Date__c = cs.RLF_Reminder_Days__c != null
    											? Date.today().addDays(Integer.valueOf(cs.RLF_Reminder_Days__c)) : null;
    				refLead.No_Response_Date__c = cs.No_Response_days__c != null
    											? Date.today().addDays(Integer.valueOf(cs.No_Response_days__c)) : null;
    				refLead.Ref_Lead_Campaign_Name__c = csWrapper.campaignName;
    				refLeadsToUpdate.add(refLead);
    				
    				if (!userAccountMap.containsKey(refLead.Reference_Lead_Owner__c)) {
	    				userAccountMap.put(refLead.Reference_Lead_Owner__c, new List<String>());
    				}
    				userAccountMap.get(refLead.Reference_Lead_Owner__c).add(refLead.Reference_Lead_Account__r.Name);
    				
    			}
    		}
    		
    		for (Reference_Lead__c refLead : refLeadsToUpdate) {
    			
    			if (!alreadyNotifiedUsers.contains(refLead.Reference_Lead_Owner__c)) {
	    			String tempEmailBody = emailBody + '\n\n' + 'Accounts requiring your review include:';
	    			
	    			if (userAccountMap.containsKey(refLead.Reference_Lead_Owner__c)
	    					&& userAccountMap.get(refLead.Reference_Lead_Owner__c).size() > 3) {
	    				tempEmailBody = tempEmailBody + '\n' + userAccountMap.get(refLead.Reference_Lead_Owner__c)[0]
	    							+ '\n' + userAccountMap.get(refLead.Reference_Lead_Owner__c)[1]
	    							+ '\n' + userAccountMap.get(refLead.Reference_Lead_Owner__c)[2]
	    							+ '\n' + 'and more...';
	    				userAccountMap.remove(refLead.Reference_Lead_Owner__c);
	    			} else if (userAccountMap.containsKey(refLead.Reference_Lead_Owner__c)
	    					&& userAccountMap.get(refLead.Reference_Lead_Owner__c).size() <= 3) {
	    				
	    				for (String accName : userAccountMap.get(refLead.Reference_Lead_Owner__c)) {
	    					tempEmailBody = tempEmailBody + '\n' + accName;
	    				}
		    			userAccountMap.remove(refLead.Reference_Lead_Owner__c);
	    			}
					postFeedItems.add(MailChatterController.preparePostForRefedgeUser(csWrapper.subject,
																refLead.Reference_Lead_Owner__c,
																tempEmailBody.replace('$$$$', refLead.Reference_Lead_Owner__r.FirstName),
																pageURL,
																refedgeUserId));
					listmail.add(MailChatterController.prepareEmail(csWrapper.subject,
														refLead.Reference_Lead_Owner__c,
														tempEmailBody.replace('$$$$', ' ' + refLead.Reference_Lead_Owner__r.FirstName) + '\n\n' + pageURL,
														true));
					alreadyNotifiedUsers.add(refLead.Reference_Lead_Owner__c);
    			}
    		}
    		
    		if (listmail.size() > 0) {
    			Messaging.sendEmail(listmail);
    		}
    		
    		if (postFeedItems.size() > 0) {
    			WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
    		}
    		
    		if (refLeadsToUpdate.size() > 0) {
    			update refLeadsToUpdate;
    			cs.Ref_Prospector_Campaign_Lead_Count__c = 0;
    			cs.Ref_Prospector_Lead_Count__c = csWrapper.refLeadCount - refLeadsToUpdate.size();
    			update cs;
    		}
    		result = 'success';
    	} catch (Exception e) {
    		system.debug(e.getLineNumber() + '--');
    		Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return result;
    }
    
    public class CustomSettingWrapper {
    	public String csId { get; set; }
    	public String subject { get; set; }
    	public String body { get; set; }
    	public Decimal refLeadCount { get; set; }
    	public Decimal refLeadCampaignCount { get; set; }
    	public String salutation { get; set; }
    	public String campaignName { get; set; }
    	public Boolean isRefProspectEnabled { get; set; }
    	
    	public CustomSettingWrapper(Custom_Settings__c cs) {
    		this.csId = cs.Id;
    		this.subject = cs.Ref_Prospector_Subject__c != null
    						? cs.Ref_Prospector_Subject__c
    						: 'Potential Reference Accounts';
    		this.body = cs.Ref_Prospector_Body__c != null
    						? cs.Ref_Prospector_Body__c
    						: 'The customer reference team is always seeking new ways to showcase client success. Accounts including the ones below have been identified as owned by you and potential candidates for the customer reference program. Do you think they would act as a reference at this time?';
    		this.refLeadCount = cs.Ref_Prospector_Lead_Count__c != null ? cs.Ref_Prospector_Lead_Count__c : 0;
    		this.refLeadCampaignCount = cs.Ref_Prospector_Campaign_Lead_Count__c != null ? cs.Ref_Prospector_Campaign_Lead_Count__c : 0;
    		this.salutation = '';
    		this.campaignName = 'Campaign ' + date.today().format();
    		this.isRefProspectEnabled = cs.Ref_Prospector_Enable__c;
    	}
    }
}