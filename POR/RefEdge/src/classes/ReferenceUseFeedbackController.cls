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
* VF Page: Reference Use Feedback 
* Description: Class used for Reference request feedback.
* Last Modified By: Rajesh @June 1 2017 for #841
*/ 
public with sharing class ReferenceUseFeedbackController extends RefEdgeEditionFeatures {
   /**
	* Properties and variables
	*/
    public Reference_Request_Account_Contact__c refReqAccountContact { get; set; }
    public Reference_Request__c referenceRequest { get; set; }
    private Account account;
    private DateTime oldDeadlineDateValue;
    public String feedbakResponse { get; set; }
    public Boolean isAlreadyFeedback { get; set; }
    public Boolean isRecordDeleted { get; set; }
    private Boolean checkChatterSetting;
    private Boolean checkEmailSetting;
    private Custom_Settings__c cs;
    public Boolean isSubmitted { get; set; }
    public boolean diplayUnsuccessfulPanel { get; set; }
    public boolean diplayNotcompletedPanel { get; set; }
    public boolean isSLDS { get; set; }
    public Id ownerId { get; set; }	
    public Id requesterId { get; set; }	
   /*
	* This field is use to show reward points in disolving alert for sales reward issue to user
	*/
    public transient Decimal rewardPoints { get; set; }
   /*
	* This field is use to show action message in disolving alert for sales reward issue to user
	*/
    public transient String actionMessage { get; set; }
    public Boolean isSLDSSet { get; set; }
    private String refReqAccContactId;
   /**
	* Constructor
	*/
    public ReferenceUseFeedbackController() {
    	refReqAccContactId = ApexPages.currentPage().getParameters().get('id');
        isSLDSSet = false;
        
        // related to #812
        if (Test.isRunningTest()) {
            isSLDS = false;
            reset();
        }  
    }
   
   /**
	* Method to reset in case of SF1 
	* Created By: Rajesh @20 April 2018 related to REF-1531
	*/
	public void initialization() {
        cs = UtilityController.getCustomSettings();
        checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Feedback_Chatter__c);
        checkEmailSetting = cs.Request_Feedback_Email__c;
        diplayUnsuccessfulPanel = false;
        diplayNotcompletedPanel = false;
        feedbakResponse = '';
        isAlreadyFeedback = false;
        rewardPoints = 0;
        actionMessage = '';
        isSubmitted = false; 
        refReqAccContactId = refReqAccContactId.replace('feedbackId', '');
        
        if (refReqAccContactId != null && refReqAccContactId.trim().length() > 0) {
            List<Reference_Request_Account_Contact__c> listRefReqAccountContact = new List<Reference_Request_Account_Contact__c>();
            listRefReqAccountContact = WithoutSharingHelperController.getContactRequests(refReqAccContactId);
            
            if (listRefReqAccountContact.size() > 0 && listRefReqAccountContact[0].Contact__c != null && listRefReqAccountContact[0].Reference_Request_Account__c != null) {
                isRecordDeleted = false;                 
                refReqAccountContact = listRefReqAccountContact[0];
                changeFeedbakOptions(); 
                List<Reference_Request__c> tempList = [SELECT Opportunity__c, OwnerId, Requester__c,Name, Id, Opportunity__r.AccountId
                                                        FROM Reference_Request__c WHERE id = :refReqAccountContact.Reference_Request_Account__r.Reference_Request__c LIMIT 1 ];
                
                if (tempList.size() > 0) {
                    referenceRequest = tempList[0];
                }
                
                // re #213 
                if (referenceRequest.Requester__c != null) {
                    requesterId = referenceRequest.Requester__c;
                }
                
                if (referenceRequest.OwnerId != null) {
                    ownerId = referenceRequest.OwnerId; 
                } else {
                    List<Account> account = [SELECT OwnerId FROM Account WHERE id = :referenceRequest.Opportunity__r.AccountId LIMIT 1];
                    
                    if (account.size() > 0) {
                        ownerId = account[0].OwnerId;
                    }
                }                         
                //get old Deadline date
                Date oldDeadlineDate = (Date) refReqAccountContact.Reference_Request_Account__r.Deadline__c;
                
                if (oldDeadlineDate != null) {
                    oldDeadlineDateValue = DateTime.newInstance(oldDeadlineDate.year(), oldDeadlineDate.month(), oldDeadlineDate.day());
                }
                
                //Is Already feedback provided
                if (refReqAccountContact.Is_Feedback_Received__c) {
                    isAlreadyFeedback = true;
                }
            } else {
                isRecordDeleted = true;
            }               
            
            //re #119     
            List<Reference_Request_Account_Contact__c> rra = [SELECT OwnerId  FROM Reference_Request_Account_Contact__c WHERE id = :refReqAccContactId];
            
            if (rra.size()>0 && rra[0].OwnerId != null) {
                ownerId=rra[0].OwnerId;
            }  
        }  
	}
   /**
	* Method to reset 
	* Created By: Rajesh @9 June 2017 related to #10
	*/
    public PageReference reset() { 
        isSLDSSet = true;
        
        if (!isSLDS) {  
        	initialization();
            return null;
        } else {
            return new PageReference(Page.ReferenceUseFeedbackSLDS.getURL() + '?Id=' + refReqAccContactId);
        }
    }
   /**
	* Method Changes accordance picklist value 
	*/
    public void changeFeedbakOptions() {
        
        if (refReqAccountContact.Feedback_Status__c == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
            diplayUnsuccessfulPanel = true;
            diplayNotcompletedPanel = false;
        } else if (refReqAccountContact.Feedback_Status__c == ConstantsController.FEEDBACK_YET_NOT_COMPLETED) {
            diplayUnsuccessfulPanel = false;
            diplayNotcompletedPanel = true;
        } else {
            diplayUnsuccessfulPanel = false;
            diplayNotcompletedPanel = false;
        }
    }
    
   /**
	* Method to Send Update
	*/
    public PageReference sendUpdate() { 
        Savepoint sp = Database.setSavepoint();
         
        try {
            refReqAccountContact.Is_Feedback_Received__c = true;
            isSubmitted = false;
            
            if (refReqAccountContact.Feedback_Status__c == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
                
                if (feedbakResponse == '' || feedbakResponse == null) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.reason_for_ref_use_unsuccess));
                    return null;
                } 
            }
            
            if (feedbakResponse != '' && feedbakResponse != null) {
                refReqAccountContact.Feedback_Response__c = feedbakResponse;
            }
            
            if (refReqAccountContact.Feedback_Status__c == ConstantsController.FEEDBACK_YET_NOT_COMPLETED) {
                
                if (refReqAccountContact.Reference_Request_Account__r.Deadline__c == null) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.update_when_ref_use_will_occur));
                    return null;
                } else {
                    //checking for deadline date is in Weekend day or not
                    if (UtilityController.isItWeekend(refReqAccountContact.Reference_Request_Account__r.Deadline__c)) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Edit_popup_deadline_date_must_not_fall_Weekend.replace('Deadline', 'Reference Use')));
                        return null;
                    }
                    //checking for deadline date is in Past Date
                    if ((Date.Today()).daysBetween(refReqAccountContact.Reference_Request_Account__r.Deadline__c) < 0) {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Revised_Use_Date_Error));
                        return null;
                    }
                    //For get feedback form Batches
                    refReqAccountContact.Is_Feedback_Notification_Send__c = false;
                    Set<Id> tempSet = new Set<Id>();
                    tempSet.add(refReqAccountContact.Reference_Request_Account__c);
                    List<Reference_Request_Account__c> rraList = WithoutSharingHelperController.getAccountRequests(tempSet);
                    rraList[0].Deadline__c = refReqAccountContact.Reference_Request_Account__r.Deadline__c;
                    WithoutSharingHelperController.updateRRA(rraList); 
                }
            }
            
            if (refReqAccountContact.Feedback_Status__c == 'Use will not occur') {
                ConstantsController.shouldCompleteStatusChange = true;
                refReqAccountContact.Contact_Request_Status__c = ConstantsController.NO_LONGER_NEEDED;
                refReqAccountContact.Activity_Date__c = null;
                Set<Id> tempSet = new Set<Id>();
                tempSet.add(refReqAccountContact.Reference_Request_Account__c);
                List<Reference_Request_Account__c> rraList = WithoutSharingHelperController.getAccountRequests(tempSet);
                rraList[0].Account_Request_Status__c = ConstantsController.NO_LONGER_NEEDED;
                
                if (!cs.Consider_No_longer_needed_a_use__c) {
                    rraList[0].Activity_Date__c = null;
                    refReqAccountContact.Activity_Date__c = null;
                }
                WithoutSharingHelperController.updateRRA(rraList); 
            }
            
            //upsert refReqAccountContact; 
            WithoutSharingHelperController.upsertReqAccountContact(refReqAccountContact);          
            //Call to Update Task
            updateTask();
            isSubmitted = true;           
            
            if (refReqAccountContact.Is_Feedback_Received__c == true  && RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {
                // re #119-Added sales rewards for User 
                List<String> lstUserAction = new List<String>();
                lstUserAction.add(ConstantsController.Reference_Use_Feedback);
                List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);  
                
                //re #583 -Null check for User reward points. 
                if (refType.size() > 0 && refType[0].Sales_Point__c != null) { 
                    List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
                    
                    if (isSubmitted) {				    
                        rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, 
                                                            Transaction__c = ConstantsController.ISSUE, RewardDate__c = Date.Today(), User__c = requesterId));			             
                        
                        //re #591 NEW field Onscreen Notification allow for on/off for onscreen notification.
                        if (cs.User_Reward_Onscreen_Notification__c) {
                            rewardPoints = refType[0].Sales_Point__c;
                            actionMessage = refType[0].Name;
                        }
                        UtilityController.isUserProfileExist(requesterId);				        
                        refType = [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c 
                                   WHERE Visible__c = true AND Id = :refReqAccountContact.Reference_Request_Account__r.Reference_Type_Needed__c ORDER BY Name LIMIT 1];
                        
                        if (ownerId != null && refType.size() > 0 && refType[0].Sales_Point__c != null) { 
                            rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, Transaction__c = ConstantsController.ISSUE, 
                                                                RewardDate__c = Date.Today(), User__c = ownerId));
                            
                            UtilityController.isUserProfileExist(ownerId);   
                        }     				                                  
                    }
                    
                    if (rewardsToBeInsert.size() > 0) {
                        WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
                    } 
                    
                } 
            }
            return null;
        } catch (Exception e) {
            Database.rollback(sp);
            ApexPages.addMessages(e);
            return null;
        }
         
    }
    
   /**
	* Method to Update Task
	*/
    private void updateTask() {

        if (refReqAccountContact.Task_ID__c != null) {
            List<Task> tasks = [SELECT Status, Description FROM Task WHERE id = :refReqAccountContact.Task_ID__c];
            
            if (tasks.size() > 0) {
                tasks[0].Description += '\n\n************************************************************\n\n' +
                    MailChatterController.getFeedbackResponseMessage(refReqAccountContact.Feedback_Status__c, refReqAccountContact, oldDeadlineDateValue, feedbakResponse);
                tasks[0].Status = ConstantsController.COMPLETED;
                
                WithoutSharingHelperController.updateTask(tasks); 
            }
        }
    }
    
   /**
	* Method to return home Page
	*/
    public Pagereference returnHomePage() {
        PageReference ReturnPage = new PageReference('/home/home.jsp');
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
   
   /**
	* Method to check Permissions
	*/
    /*public static Boolean checkPermissions() { 
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
        Boolean isUpsertPermission = false; 
        
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Account_Contact__c', new Set<String> {  
            UtilityController.appNamespace() + 'Is_Feedback_Received__c',
                UtilityController.appNamespace() + 'Feedback_Response__c',
                UtilityController.appNamespace() + 'Is_Feedback_Notification_Send__c',
                UtilityController.appNamespace() + 'Contact_Request_Status__c',
                UtilityController.appNamespace() + 'Activity_Date__c' });
        
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Account__c', new Set<String> {  
            UtilityController.appNamespace() + 'Deadline__c',
                UtilityController.appNamespace() + 'Account_Request_Status__c',
                UtilityController.appNamespace() + 'Activity_Date__c'});  
        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);           
        return isUpsertPermission; 
    }*/
}