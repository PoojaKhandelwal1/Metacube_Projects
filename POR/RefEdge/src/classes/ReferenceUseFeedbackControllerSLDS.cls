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
 * VF Page: Reference Use Feedback in lightning
 * Description: Class used for Reference request feedback in lightning.
 * Last Modified By: Rajesh @April 27 2017 
 */  
public with sharing class ReferenceUseFeedbackControllerSLDS extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */
	public String refReqAccContactId { get; set; }
	 
	/**
     * Constructor
     */
    public ReferenceUseFeedbackControllerSLDS() {
    	
    	if (ApexPages.currentPage().getParameters().get('id') != null) {
            refReqAccContactId = ApexPages.currentPage().getParameters().get('id');
        }     
    }
    
    /**
     * Method to get Date Format #1070
     */
    @RemoteAction
    public static String getDateFormat() {   
    		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
    		return dateFormat;
    }
    
    /**
     * Method to get page value on page load
     */
    @RemoteAction
    public static List<PageInputWrapper> getPageDetails(String refAccContactId) {
    	String refReqId = refAccContactId.replace('feedbackId', '');
       	Boolean isRecordDeleted = false;
       	List<PageInputWrapper> lstInput = new List<PageInputWrapper>(); 
       	Reference_Request__c referenceRequest = new Reference_Request__c(); 
	    	Id requesterId = null;
	    	Id ownerId = null;
	    	Datetime oldDeadlineDateValue = null;
	    	Boolean isAlreadyFeedback = false;
	    	String opportunityAccountName = '';
          
        if (refReqId != null && refReqId.trim().length() > 0) {
            List<Reference_Request_Account_Contact__c> listRefReqAccountContact = new List<Reference_Request_Account_Contact__c>();
            listRefReqAccountContact = WithoutSharingHelperController.getContactRequests(refReqId);
            
            if (listRefReqAccountContact.size() > 0 && listRefReqAccountContact[0].Contact__c != null && listRefReqAccountContact[0].Reference_Request_Account__c != null) {
                isRecordDeleted = false;                  
                Reference_Request_Account_Contact__c refReqAccountContact = listRefReqAccountContact[0];
                
                List<Reference_Request__c> tempList = [SELECT Opportunity__c, Opportunity__r.Name, Opportunity__r.Id,OwnerId, Requester__c,Name, Id, Opportunity__r.AccountId
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
                
                if (referenceRequest.Opportunity__r.AccountId != null) {
                	List<Account> lstAccount =[SELECT Name FROM Account WHERE id = :referenceRequest.Opportunity__r.AccountId];
                	
                	if (lstAccount.size() > 0) {
                		opportunityAccountName = lstAccount[0].Name; 
                	}
                }
                
                lstInput.add(new PageInputWrapper(refReqAccountContact.Reference_Request_Account__r.Account__r.Name, refReqAccountContact.Reference_Request_Account__r.Account__r.Id,
                									refReqAccountContact.Contact__r.Name, refReqAccountContact.Contact__r.Id,
                									opportunityAccountName, referenceRequest.Opportunity__r.AccountId,
                									referenceRequest.Opportunity__r.Name, referenceRequest.Opportunity__r.Id,
                									refReqAccountContact.Reference_Request_Account__r.Reference_Type_Needed__r.Name,
                									refReqAccountContact.Reference_Request_Account__r.Deadline__c, refReqAccountContact.Reference_Request_Account__r.CreatedDate, 
                									requesterId, ownerId, oldDeadlineDateValue, isAlreadyFeedback, isRecordDeleted));
            } else {
            	lstInput.add(new PageInputWrapper(null, null, null, null, null, null,null, null, null, date.today(), date.today(), null, null, date.today(), false, true));                
            }                
            
        }
    	return lstInput;
    } 
    
    /**
     * Method to get Feedback Status value
     */
    @RemoteAction
    public static List<FeedbackStatus> getFeedbackStatus() {
        List<FeedbackStatus> lstFeedbacks = new List<FeedbackStatus>();
        
        try {
        	Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Reference_Request_Account_Contact__c.fields.getMap();
            List<Schema.PicklistEntry> picklistEntries = fldObjMap.get(UtilityController.appNamespace() + 'Feedback_Status__c').getDescribe().getPicklistValues();
            lstFeedbacks.add(new FeedbackStatus('None', 'None'));
             
            for (Schema.PicklistEntry f : picklistEntries) {
            	lstFeedbacks.add(new FeedbackStatus(f.getLabel(), f.getValue())); 
            } 
           
        } catch (Exception e) { 
            ApexPages.addmessages(e);
        }  
        return lstFeedbacks;
    }
    
    /**
     * Method to Send Update
     */
    @RemoteAction
    public static String sendUpdate(String refReqId, String statusMassage, String feedbakResponse, String useDate, String requesterId, String owner) {
        Savepoint sp = Database.setSavepoint();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
       	Decimal rewardPoints = 0;
        String actionMessage = ''; 
        String result = '';
	    String errMsg = 'Error' + ' ';
	     
	   	try {
	   		Date UseDateValue;
	    		if (useDate.trim() != '') {
	    			UseDateValue = Date.valueOf(useDate);
	    		}
	    		
	    		Id refAccContactId = Id.valueOf(refReqId.replace('feedbackId', ''));
	        Id ownerId = Id.valueOf(owner);
	    	List<Reference_Request_Account_Contact__c> listRefReqAccountContact = new List<Reference_Request_Account_Contact__c>();
	    	Reference_Request_Account_Contact__c refReqAccountContact =  new Reference_Request_Account_Contact__c();
	    	
	    	listRefReqAccountContact = WithoutSharingHelperController.getContactRequests(refAccContactId);
	    	 
	    	if (listRefReqAccountContact.size() > 0 && listRefReqAccountContact[0].Contact__c != null && listRefReqAccountContact[0].Reference_Request_Account__c != null) {                                 
	        	refReqAccountContact = listRefReqAccountContact[0];
	    	
	            refReqAccountContact.Is_Feedback_Received__c = true; 
	            refReqAccountContact.Reference_Request_Account__r.Deadline__c = (UseDateValue == null) ? refReqAccountContact.Reference_Request_Account__r.Deadline__c : UseDateValue;
	            
				if (statusMassage == '' || statusMassage == 'None') {
					return errMsg += System.Label.Feedback_Status;
				}
	            
	            if (statusMassage == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
	                
	                if (feedbakResponse == '' || feedbakResponse == null) { 
	                    return errMsg += System.Label.reason_for_ref_use_unsuccess;
	                } 
	            }
	            
	            if (feedbakResponse != '' && feedbakResponse != null) {
	                refReqAccountContact.Feedback_Response__c = feedbakResponse;
	            }
	            refReqAccountContact.Feedback_Status__c = statusMassage;
	          	
	          	if (statusMassage == ConstantsController.FEEDBACK_YET_NOT_COMPLETED) { 
	                
	                if (refReqAccountContact.Reference_Request_Account__r.Deadline__c == null) { 
	                    return errMsg += System.Label.update_when_ref_use_will_occur;
	                } else {
	                    //checking for deadline date is in Weekend day or not
	                    if (UtilityController.isItWeekend(refReqAccountContact.Reference_Request_Account__r.Deadline__c)) { 
	                        return errMsg += System.Label.Edit_popup_deadline_date_must_not_fall_Weekend.replace('Deadline', 'Reference Use');
	                    }
	                    //checking for deadline date is in Past Date
	                    
	                    if ((Date.Today()).daysBetween(refReqAccountContact.Reference_Request_Account__r.Deadline__c) < 0) { 
	                        return errMsg += System.Label.Revised_Use_Date_Error;
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
	           
	            if (statusMassage == 'Use will not occur') {
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
	            updateTask(refReqAccountContact); 
	            
	            if (refReqAccountContact.Is_Feedback_Received__c == true  && RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {		            	 
	             	List<Referenceability_Type__c> refType = [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c WHERE Visible__c = true AND Sales_Reward__c = true AND 
		             											Referenceability_code__c = :ConstantsController.Reference_Use_Feedback ORDER BY Name LIMIT 1];	          
		             
		        	if (refType.size() > 0 && refType[0].Sales_Point__c != null) { 
		        		List<Reward__c> rewardsToBeInsert = new List<Reward__c>(); 
		        		 
				        rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, 
				        								Transaction__c = ConstantsController.ISSUE, RewardDate__c = Date.Today(), User__c = requesterId));			             
			           
		            	if (cs.User_Reward_Onscreen_Notification__c) {
				             rewardPoints = refType[0].Sales_Point__c;
			    			 actionMessage = refType[0].Name;
			    			 result = actionMessage + ',' + rewardPoints;
		            	}
		            	
		            	UtilityController.isUserProfileExist(requesterId);
		            					        
				        refType = [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c 
				        				WHERE Visible__c = true AND Id = :refReqAccountContact.Reference_Request_Account__r.Reference_Type_Needed__c ORDER BY Name LIMIT 1];
				        
				        if (ownerId != null && refType.size() > 0 && refType[0].Sales_Point__c != null) { 
					       	rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, Transaction__c = ConstantsController.ISSUE, 
					                                                 RewardDate__c = Date.Today(), User__c = ownerId));
					                                                 
					         UtilityController.isUserProfileExist(ownerId);   
				        }
				        
				        if (rewardsToBeInsert.size() > 0) {
			             	WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
				        }				             
		        	} 
	            }
	    	}
	    	            	
	        return result;
	    } catch (Exception e) { 
	        Database.rollback(sp);
	        ApexPages.addMessages(e);
	        return 'Error' + ' '+ CRUDAndFLSCheckController.getErrorMsg();
	    }
    }     
	        
    
    /**
     * Method to Update Task
     */
    public static void updateTask(Reference_Request_Account_Contact__c refReqAccountContact) {

        if (refReqAccountContact.Task_ID__c != null) {
            List<Task> tasks = [SELECT Status, Description FROM Task WHERE id = :refReqAccountContact.Task_ID__c];
            Date oldDeadlineDate = (Date) refReqAccountContact.Reference_Request_Account__r.Deadline__c;
            if (tasks.size() > 0) {
                tasks[0].Description += '\n\n************************************************************\n\n' +
                    MailChatterController.getFeedbackResponseMessage(refReqAccountContact.Feedback_Status__c, refReqAccountContact, oldDeadlineDate, refReqAccountContact.Feedback_Response__c);
                tasks[0].Status = ConstantsController.COMPLETED;
                
                WithoutSharingHelperController.updateTask(tasks); 
            }
        }
    } 
    
    /**
     * Method to check Permissions
     */
    /* public static Boolean checkPermissions() { 
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
    
    /**
     * Wrapper class for page inputs
     */
 	public class PageInputWrapper {
        public String accountName { get; set; }
        public Id accountId { get; set; }
        public String contactName { get; set; }
       	public Id contactId { get; set; }    
        public String opportunityAccount { get; set; }
        public Id opportunityAccountId { get; set; }         
        public String opportunityName { get; set; }
        public Id opportunityId { get; set; }
        public String refType { get; set; }
        public String useDate { get; set; }
        public String creationDate { get; set; }
        public Id requesterId { get; set; }
        public Id ownerId { get; set; }
        public String oldDeadlineDateValue { get; set; }
        public Boolean isAlreadyFeedback { get; set; }
        public Boolean isRecordDeleted { get; set; }
        
        
        
        public PageInputWrapper(String accountName, Id accountId, String contactName, Id contactId, String opportunityAccount, 
        							Id opportunityAccountId, String opportunityName, Id opportunityId, String refType, 
        							Date useDate, Datetime creationDate, Id requesterId, Id ownerId, 
        							Datetime oldDeadlineDateValue, Boolean isAlreadyFeedback, Boolean isRecordDeleted) {
        	 							
            this.accountName = accountName;
            this.accountId = accountId;
            this.contactName = contactName;
            this.contactId = contactId;
            this.opportunityAccount = opportunityAccount;
            this.opportunityAccountId = opportunityAccountId;
            this.opportunityName = opportunityName;
            this.opportunityId = opportunityId;
            this.refType = refType;
            this.useDate = DateTime.newInstance(useDate.year(), useDate.month(), useDate.day()).format('yyyy-MM-dd');
            this.creationDate = DateTime.newInstance(creationDate.year(), creationDate.month(), creationDate.day()).format('yyyy-MM-dd'); 
            this.requesterId = requesterId;
            this.ownerId = ownerId; 
            this.oldDeadlineDateValue = DateTime.newInstance(oldDeadlineDateValue.year(), oldDeadlineDateValue.month(), oldDeadlineDateValue.day()).format('yyyy-MM-dd');
            this.isAlreadyFeedback = isAlreadyFeedback;
            this.isRecordDeleted = isRecordDeleted;
        }
    }
    
    /**
     * Wrapper class for feedback status
     */
    public class FeedbackStatus {
        public String apiName { get; set; }
        public String label { get; set; }
        
        public FeedbackStatus(String apiName, String label) {
            this.apiName = apiName;
            this.label = label; 
        }
    }
}