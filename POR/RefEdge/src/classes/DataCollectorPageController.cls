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
    * VF Page: DataCollectorPage
    * Description: Class to get feedback(Classic Environment).
    * Created By: Rajneesh (may 25, 2018)
*/
public with sharing class DataCollectorPageController {

    /**
        * Properties and variables
    */
    public String formName { get; set; }
    public String formHeader { get; set; }
    public String formSubHeader { get; set; }
    public String sectionInfo { get; set; }
    public Reference_Content_Type_Field__c refContent { get; set; }
    public list<SectionWrapper> secWrapList { get; set; }
    public Boolean isSLDS { get; set; }
    public Boolean isError { get; set; }
    public Reference_Content__c referenceRecord { get; set; }
    //  To get FormName wise message
    private Map<String, Data_Mapping__c> dmMap = new Map<String, Data_Mapping__c>();
    private id currentLoggedUser;   
    public Boolean refContentSec { get; set; }
    public Boolean isPreview { get; set; }
    private Set<id> userIdSet = new Set<id>();
    public Boolean checkLightnig { get; set; }
    public String contentId { get; set; }
    public Boolean isGreetSec { get; set; }
	public Boolean isSave { get; set; }
    public Map<String,SectionItemWrapper> labelMap { get; set; }
    
    /*
     * This field is use to show reward points in disolving alert for sales reward issue to user
     */
    public transient Decimal rewardPoints { get; set; }
    /*
     * This field is use to show action message in disolving alert for sales reward issue to user
     */
    public transient String actionMessage { get; set; }
    
    // Constructor
    public DataCollectorPageController() {
        currentLoggedUser = UserInfo.getUserId();
        refContentSec = false;
        isPreview = false;
        isError = false;
        checkLightnig = false;
        isGreetSec = false;
        rewardPoints = 0;
        actionMessage = '';
        
        //    Check theme(Lightning or classic)
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
            } else { 
            isSLDS = false;
        }
        // get reference content Record Id from URL
        contentId = ApexPages.currentPage().getParameters().get('id') != null ? ApexPages.currentPage().getParameters().get('id') : ''; 

        if(!isSLDS) {
            formName = '';
			isSave = false;
            formHeader = '';
            formSubHeader = '';
            referenceRecord = new Reference_Content__c();
            refContent = new Reference_Content_Type_Field__c();
            secWrapList = new list<SectionWrapper>(); 
            // Get Reference Content Id from url
            labelMap = new Map<String,SectionItemWrapper>();

            for (String field: Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap().keySet()) {
                Schema.DescribeFieldResult dfr= Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap().get(field).getDescribe();
                labelMap.put(dfr.getName(),new SectionItemWrapper(dfr.getName(), dfr.getInlineHelpText(), dfr.getLabel()));
            }
            
            String dmRecordId = ApexPages.currentPage().getParameters().get('customFormId') != null
            ? ApexPages.currentPage().getParameters().get('customFormId').substringBefore('?') : '';               
            
            String soqlQuery = 'SELECT id, ';
            
            //Set for CRP team member
            for(user usr :  UtilityController.getCustomerReferenceTeam()) {
                userIdSet.add(usr.Id);
            }
			
			//	Check whether loggedIn user is part of crp team
			if(userIdSet.contains(currentLoggedUser)) {
				isSave = true;
			}
            List<Reference_Content__c> refContentList = new List<Reference_Content__c>();
            
            if(contentId != '' || dmRecordId != '') {
                
                if (contentId != ''){
                    
                    refContentList = [SELECT Id, Name, Opportunity__c, Title__c, Data_Collector_Name__c, Opportunity__r.ownerId, Opportunity__r.Name, Opportunity__r.Owner.ManagerId, Opportunity__r.StageName, Content_Status__c, Internal_Use__c,
                                     Data_Collector_Status__c, opportunity__r.AccountId, Opportunity__r.owner.Name, opportunity__r.Account.Name FROM Reference_Content__c WHERE id =: String.escapeSingleQuotes(contentId)];
                    
                    if(refContentList.size() > 0) {
                        referenceRecord = refContentList[0];
                    } else {
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, label.Reference_Content_Deleted));
                         isError = true;
                    }
                    
                    if(referenceRecord.Opportunity__r.Owner.ManagerId == currentLoggedUser && !userIdSet.contains(currentLoggedUser)) {
                        refContentSec = true;
                    }                    
                }
                               
                String strValue = '';
                
                if (contentId != '' && refContentList.size() > 0) {
                    strValue = referenceRecord.Data_Collector_Name__c;
                    } else if(dmRecordId != ''){
                    isPreview = true;
                    strValue = [SELECT id, Data_Collector_Name__c FROM Data_Mapping__c WHERE id =: String.escapeSingleQuotes(dmRecordId)].Data_Collector_Name__c;                    
                }
                
                // map for section id and list of field
                Map<string, List<Data_Mapping__c>> fieldMap = new Map<String, List<Data_Mapping__c>>();
                list<Data_Mapping__c>  dmList = [SELECT Field_API_Name__c, Label__c, DC_Message__c, Section_Name__c, Data_Collector_Name__c, Order__c, Section_Position__c FROM Data_Mapping__c WHERE Data_Collector_Name__c =: strValue ORDER BY Section_Position__c];
                
                //    Check whether any record with the passes name is or not
                if(dmList.Size() > 0) {
                    
                    // Iterate the list 
                    for(Data_Mapping__c dm : dmList) {
                        
                        //    for Form Name, Header and Sub Header                        
                        if(dm.Order__c == null && dm.Section_Position__c == null && dm.Section_Name__c == ConstantsController.DC_FORM_IDENTIFY ){
                            formName = dm.Data_Collector_Name__c;
                            formHeader = dm.Label__c;
                            formSubHeader = dm.Field_API_Name__c;
                        }
                        
                        //    To populate map                        
                        if(dm.Order__c == null && dm.Section_Position__c == null && (dm.Section_Name__c == ConstantsController.DC_MANAGER_REVIEW  || dm.Section_Name__c == ConstantsController.DC_CRP_TEAM_REVIEW )){
                            dmMap.put(dm.Section_Name__c, dm);
                        }
                        
                        //    for section information
                        if(dm.Section_Position__c != null && dm.Order__c == null) {
                            secWrapList.add(new SectionWrapper(dm.Field_API_Name__c,Integer.valueOf(dm.Section_Position__c)));
                        }
                        
                        //    for field Information
                        if(dm.Section_Position__c != null && dm.Order__c != null) {
                            
                            if(!fieldMap.containsKey(String.valueOf(dm.Section_Position__c))) {
                                fieldMap.put(String.valueOf(dm.Section_Position__c), new List<Data_Mapping__c>());
                            }
                            fieldMap.get(String.valueOf(dm.Section_Position__c)).add(dm);
                        }
                    }                    
                    
                    
                     //  Set contains all the fields of Reference_Content_Type_Field__c
                     Set<String> RCTFIeldsSet = new Set<String>();
                  
                      for(String fldApi : Reference_Content_Type_Field__c.SObjectType.getDescribe().fields.getMap().keySet()) {
                          
                          if(fldApi.contains('__c')){
                              RCTFIeldsSet.add(fldApi.toLowerCase());                      
                          }
                      }
                    
                    //    populate field information for each section
                    for(SectionWrapper sw : secWrapList) {
                        
                        if(fieldMap.containsKey(sw.id)) {
                            
                            for(Data_Mapping__c dmfld : fieldMap.get(sw.id)) {
                            
                                //  Check whether field is deleted or not " From the object"
                                if(RCTFIeldsSet.contains(dmfld.Field_API_Name__c.toLowerCase())) {
                                    sw.Field.add(new SectionItemWrapper(dmfld.Field_API_Name__c, String.valueOf(dmfld.Order__c),dmfld.Label__c));
                                    soqlQuery +=  dmfld.Field_API_Name__c +', ';    
                                }                          
                            }
                        }
                    }
                    soqlQuery = soqlQuery.removeEnd(', ');
                    
                    if (contentId != '' && referenceRecord.Id != null) {
                        soqlQuery += ' FROM Reference_Content_Type_Field__c WHERE Reference_Content__c = \''+referenceRecord.Id+'\' ORDER By createddate LIMIT 1';
                    }
                    //   system.assert(false,soqlQuery);
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, label.DC_Form_Deleted_Message));
                    isError = true;
                }
                
                if(contentId != '' && refContentList.size() > 0) {
                    
                    if(referenceRecord.Data_Collector_Status__c == 'New' && referenceRecord.id != null) {
                        refContent.Reference_Content__c = referenceRecord.id;
                        } else {
                        refContent = database.query(soqlQuery);
                    }
                }                
            }
        }        
    }
    
    public PageReference reset() {
  
        if (isSLDS && contentId != '') {      
            checkLightnig = false;            
            return new PageReference(Page.DataCollectorPageSLDS.getURL() + '?id=' + contentId);
        } else {    
            checkLightnig = true;         
            return null;
        }
    }
    
    //    To Update the record
    public PageReference updateContent() {
        try{
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            if(referenceRecord.Data_Collector_Status__c != null && referenceRecord.Data_Collector_Status__c == 'New') {
                referenceRecord.Data_Collector_Status__c = 'In Progress';
                
				RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
				List<sObject> postFeedItems = new List<sObject>();
				List<MailChatterController.EmailMessage> emailstoSentList = new List<MailChatterController.EmailMessage>();
				String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.DataCollectorPage.getURL() + '?id=';
				List<Map<String, String>> messagesList = new List<Map<String, String>>();
				
                // Set userEmailMap for users - whom we want to send 'Slack' notifications
	    		Map<Id, String> userEmailMap = UtilityController.getUserEmailMapForSlackNotification(cs, new List<Reference_Content__c>{referenceRecord}, ConstantsController.DC_MANAGER_REVIEW);
	    		
                // REF-1893	
				if(referenceRecord.Opportunity__r.Owner.ManagerId != null && !cs.All_Reviews_to_CRP_Team__c && (cs.DC_Manager_Review_Email__c 
						|| cs.DC_Manager_Review_Chatter__c || cs.DC_Manager_Review_Slack__c)) {
					DCManagerReviewNotification(cs, postFeedItems, emailstoSentList, messagesList, userEmailMap, LINK_URL, protectedAppConfig);
				
                } else if(cs.DC_CRP_Team_Review_Email__c || cs.DC_CRP_Team_Review_Chatter__c || cs.DC_CRP_Team_Review_Slack__c) {
					DCCRPTeamReviewNotification(cs, postFeedItems, emailstoSentList, messagesList, LINK_URL, protectedAppConfig);
				}
				
				//Send List of emails
				if(emailstoSentList.Size() > 0) {                    
					List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
					
					for(MailChatterController.EmailMessage mem : emailstoSentList) {
						listmail.add(MailChatterController.prepareEmail(mem.subject, mem.targetObjectId, mem.body, true));
					}
					
					if(listmail.size() > 0) {
						Messaging.sendEmail(listmail);
					}
				}
				
				//Insert list of postFeedItems
				if (postFeedItems.size() > 0) {
					insert postFeedItems;
				}                
                
				//Send List of slack notifications
	            if (messagesList.size() > 0) {
	                Map<String, Object> slackReqBody = new Map<String, Object>();
		            slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
		            slackReqBody.put('orgId', UserInfo.getOrganizationId());
		            slackReqBody.put('messages', messagesList);
		            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
	            }
            } else if(referenceRecord.Data_Collector_Status__c != null && referenceRecord.Data_Collector_Status__c == 'In Progress' && (referenceRecord.Opportunity__r.Owner.ManagerId == currentLoggedUser || userIdSet.contains(currentLoggedUser))) {
                referenceRecord.Data_Collector_Status__c = 'Reviewed';
            }

            // update reference content and Reference Content Type Field to the database. 
            WithoutSharingHelperController.upsertReferenceConTypeFields(new List<Reference_Content_Type_Field__c> { refContent });            
            WithoutSharingHelperController.upsertRefContentList(new List<Reference_Content__c> { referenceRecord });
            
            // Start: Add sales rewards for User
            if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c) {
	            List<String> lstUserAction = new List<String>();
	            lstUserAction.add(ConstantsController.REFERENCE_CONTENT_TYPE);
	            List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);  
	            
	            // Null check for User reward points. 
	            if (refType.size() > 0 && refType[0].Sales_Point__c != null) { 
	                List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
	                
                    rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, Transaction__c = ConstantsController.ISSUE, 
                                                        RewardDate__c = Date.Today(), User__c = UserInfo.getUserId()));
                    UtilityController.isUserProfileExist(UserInfo.getUserId()); 
	                
	                if (rewardsToBeInsert.size() > 0) { 
	                    WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
	                    // NEW field Onscreen Notification allow for on/off for onscreen notification.
	                    if (cs.User_Reward_Onscreen_Notification__c) {
	                        rewardPoints = refType[0].Sales_Point__c; 
	                        actionMessage = refType[0].Name; 
	                    }
	                }
            	} 
            }
            // End: Add sales rewards for User
           
            return null;
        } catch(exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }        
    }

	public PageReference cancelNotificationPanel() { 
		if(isSave) {
            PageReference nextPage = new PageReference('/' + contentId);
            return nextPage;
        } else {
            isGreetSec = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, label.Thank_you_Note));
            return null;
        }
	}
	
    private void DCManagerReviewNotification(Custom_Settings__c cs, List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList, 
    											List<Map<String, String>> messagesList, Map<Id, String> userEmailMap,
    											String LINK_URL, RefEdge_Configuration_Protected__c protectedAppConfig) {
    	String notificationSubject = dmMap.get(ConstantsController.DC_MANAGER_REVIEW).Field_API_Name__c != null ? dmMap.get(ConstantsController.DC_MANAGER_REVIEW).Field_API_Name__c : ConstantsController.DC_MANAGER_REVIEWSUB;      
    	String targetObjectId = referenceRecord.Opportunity__r.Owner.ManagerId;
    	String notificationBody = (dmMap.get(ConstantsController.DC_MANAGER_REVIEW).DC_Message__c != null ? dmMap.get(ConstantsController.DC_MANAGER_REVIEW).DC_Message__c : ConstantsController.DC_MANAGER_REVIEWMSG)+ 
										MailChatterController.prepareChatterEmailRFContentMessage(referenceRecord.Opportunity__r.Name, referenceRecord.Opportunity__r.StageName);

		// for chatter Notification
		if(UtilityController.isNativeChatterSetting &&  cs.DC_Manager_Review_Chatter__c) { 
			postFeedItems.add(MailChatterController.preparePostForRefedgeUser(notificationSubject, targetObjectId, 
								notificationBody, LINK_URL+referenceRecord.Id, protectedAppConfig.User_Id__c));
		}
					
		// for email Notification
		if(cs.DC_Manager_Review_Email__c) {
			MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(notificationSubject, targetObjectId, 
															notificationBody, 'Link : ' + '<a href="' + LINK_URL +referenceRecord.Id+ '">' 
															+ LINK_URL +referenceRecord.Id + '</a>'  ); 
			emailstoSentList.add(email);
		}
		
		// for slack Notification
        if (cs.DC_Manager_Review_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
            Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL +referenceRecord.Id + '|' + notificationSubject + '>');
            tempReqBodyMap.put('userEmail', userEmailMap.get(targetObjectId));
            messagesList.add(tempReqBodyMap);
        }
    }
    
    private void DCCRPTeamReviewNotification(Custom_Settings__c cs, List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList, 
    											List<Map<String, String>> messagesList,
    											String LINK_URL, RefEdge_Configuration_Protected__c protectedAppConfig) {
    	// Create reference Note in absence of Opportunity owner manager
		List<Reference_Note__c> refNote = new List<Reference_Note__c>();
		
		for(Reference_Note__c rfn : [SELECT Id, Note__c FROM Reference_Note__c WHERE Reference_Content__c =: referenceRecord.Id]) {
			
			if(rfn.Note__c.contains(label.No_Manager_Message)) {
				refNote.add(rfn);
			}
		}
		
		if(refNote.size() == 0) {
			Reference_Note__c refRec = new Reference_Note__c();
			refRec.Note__c = label.No_Manager_Message;
			refRec.Reference_Content__c = referenceRecord.Id;
			WithoutSharingHelperController.insertReferenceNotes(new List<Reference_Note__c> { refRec });
		}
		
		if(userIdSet.size() > 0) {
			String notificationSubject = dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).Field_API_Name__c != null ? dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).Field_API_Name__c : ConstantsController.DC_CRP_TEAM_REVIEWSUB;      
	        String notificationBody = (dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).DC_Message__c != null ? dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).DC_Message__c : ConstantsController.DC_CRP_TEAM_REVIEWMSG)+ 
											MailChatterController.prepareChatterEmailRFContentMessage(referenceRecord.Opportunity__r.Name, referenceRecord.Opportunity__r.StageName);
	        
			for(Id userId : userIdSet) { 
				// for chatter Notification
				if(UtilityController.isNativeChatterSetting && cs.DC_CRP_Team_Review_Chatter__c) {
					postFeedItems.add(MailChatterController.preparePostForRefedgeUser(notificationSubject, userId, 
											notificationBody, LINK_URL+referenceRecord.Id, protectedAppConfig.User_Id__c));
				}
				
				// for email Notification
				if(cs.DC_CRP_Team_Review_Email__c) {
					MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(notificationSubject, userId, 
																	notificationBody, 'Link : ' + '<a href="' + LINK_URL +referenceRecord.Id+ '">' 
																	+ LINK_URL +referenceRecord.Id + '</a>'  ); 
					emailstoSentList.add(email);
				}
			}
			
			// for slack Notification
            if (cs.DC_CRP_Team_Review_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
	            Map<String, String> tempReqBodyMap = new Map<String, String>();
                tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL +referenceRecord.Id + '|' + notificationSubject + '>');
	            messagesList.add(tempReqBodyMap);
	        }
		}  
    }
    
    //    Redirect to home page
    public PageReference cancel() {         
        // Send the user to home page.        
        PageReference refPage = new PageReference('/home/home.jsp');
        refPage.setRedirect(true);
        return refPage;
    }
    
    /**
        * Method to redirect to DataCollectorManagePage
    */
    public PageReference goBack() {  
        String linkUrl = '';  
        String customSettingId = ApexPages.currentPage().getParameters().get('customSettingId') != null
            ? ApexPages.currentPage().getParameters().get('customSettingId').substringBefore('?') : '';

        if (customSettingId != null && customSettingId != '' ) {
            
            linkUrl = Page.DataCollectorManagePage.geturl() + '?customSettingId=' + customSettingId;
        }
        
        if (linkUrl != null && linkUrl != '') {
            
            PageReference refPage = new PageReference(linkUrl);
            refPage.setRedirect(true);
            return refPage; 
        } else {
            return null;
        }
            
    }
    
    public class SectionWrapper {
        public String Name { get; set; }
        public String id { get; set; } 
        public List<SectionItemWrapper> Field { get; set; }
        
        public SectionWrapper(string nam, Integer secId) {
            Name = nam;
            id = String.valueOf(secId);
            Field = new List<SectionItemWrapper>();
        }
    }
    
    public class SectionItemWrapper {
        public String fieldAPIName { get; set; }   
        public String fieldId { get; set; }
        public String fieldLabel { get; set; }
        
        public SectionItemWrapper(String clApiName, string clId, String clLabel) {
            fieldAPIName = clApiName;
            fieldId = String.valueOf(clId);
            fieldLabel = clLabel;
        }
    }
}