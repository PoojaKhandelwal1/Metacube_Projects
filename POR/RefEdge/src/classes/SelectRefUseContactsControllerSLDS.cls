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
 * Page: SelectReferenceUseContactsSLDS
 * Description: Class used to create Contact request and approve/decline account request
 * Modified by: Gaurav Saini (5 Apr, 2017) for #693
 */
public with sharing class SelectRefUseContactsControllerSLDS extends RefEdgeEditionFeatures {
	/**
     * Constant
     */
    public static String SELF_SERVICE_APPROVED_SUBJECT = 'Reference Use Request Approved';
    public static String SELF_SERVICE_DECLINED_SUBJECT = 'Reference Use Request Declined';
	/**
     * Properties and variables
     */
    public String refReqAccId { get; set; }
	public Boolean isBasic { get; set; }
    public Boolean isAdvRouting { get; set; }
    public String currentUser {
        get {
        	return UserInfo.getName();
        }
        set;
    }
    
	/**
     * Constructor
     */
    public SelectRefUseContactsControllerSLDS() {
        refReqAccId = ApexPages.currentPage().getParameters().get('Id');
        isBasic = RefEdgeEditionFeatures.isBasic;
        Custom_Settings__c cs = UtilityController.getCustomSettings(); 
        isAdvRouting = cs.Adv_Request_Routing__c;
    }
    
    /**
     * Constructor
     */
    public SelectRefUseContactsControllerSLDS(ApexPages.standardController con) {
        refReqAccId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    public static void prepareChatterEmailMessages(Reference_Request_Account__c refReqAccount, CustomSettingWrapper cs, String action,
                List<Reference_Request_Account_Contact__c> lstRRAC, ContactWrapper cwObj) {
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c approveDeclineNotification = new Data_Mapping__c();
        Data_Mapping__c confirmationNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Request_Approval_Decline_Email__c', UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Email__c'};
        List<sObject> feedCommentList = new List<sObject>();
    	Map<Integer, String> monthMap = new Map<Integer, String>();
    	RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
    	monthMap.put(1, 'January');
    	monthMap.put(2, 'February');
    	monthMap.put(3, 'March');
    	monthMap.put(4, 'April');
    	monthMap.put(5, 'May');
    	monthMap.put(6, 'June');
    	monthMap.put(7, 'July');
    	monthMap.put(8, 'August');
    	monthMap.put(9, 'September');
    	monthMap.put(10, 'October');
    	monthMap.put(11, 'November');
    	monthMap.put(12, 'December');
        List<Messaging.SingleEmailMessage> listMail = new List<Messaging.SingleEmailMessage>();

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Approval_Decline_Email__c') {
                approveDeclineNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Approve_Decline_Confirmation_Email__c') {
                confirmationNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.slackTeamIds);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();

        String notificationBody = approveDeclineNotification.DC_Message__c + '\n\n' + approveDeclineNotification.Default__c;
        String slackMsgBody;
        
        if (action == 'Declined') {
            slackMsgBody = notificationBody.replace('[Disposition]', action)
                                .replace('[Request Type]', refReqAccount.Reference_Type_Needed_f__c)
                                .replace('[Requested Account]', refReqAccount.Account_f__c)
                                .replace('Contact: [Contact Name]\n', '')
                                .replace('Title: [Contact Title]\n', '')
                                .replace('Email: [Contact Email]\n', '')
                                .replace('Phone: [Contact Phone]\n', '')
                                .replace('[User Name]', UserInfo.getName())
                                .replace('[Approve/Decline Notes]', refReqAccount.Approve_Deny_Notes__c)
                                .replace('[Opportunity Account]', refReqAccount.Reference_Request__r.Opportunity__c != null ? refReqAccount.Reference_Request__r.Opportunity__r.Account.Name : 'None');
            notificationBody = notificationBody.replace('[Disposition]', action)
                                .replace('[Request Type]', refReqAccount.Reference_Type_Needed_f__c)
                                .replace('[Requested Account]', refReqAccount.Account_f__c)
                                .replace('Contact: [Contact Name]\n', '')
                                .replace('Title: [Contact Title]\n', '')
                                .replace('Email: [Contact Email]\n', '')
                                .replace('Phone: [Contact Phone]\n', '')
                                .replace('Dispositioned By: [User Name]\n', UserInfo.getName())
                                .replace('[Approve/Decline Notes]', refReqAccount.Approve_Deny_Notes__c)
                                .replace('[Opportunity Account]', refReqAccount.Reference_Request__r.Opportunity__c != null ? refReqAccount.Reference_Request__r.Opportunity__r.Account.Name : 'None');
        } else {
            slackMsgBody = notificationBody.replace('[Disposition]', action)
                                .replace('[Request Type]', refReqAccount.Reference_Type_Needed_f__c)
                                .replace('[Requested Account]', refReqAccount.Account_f__c)
                                .replace('[Contact Name]', cwObj.name)
                                .replace('[Contact Title]', lstRRAC[0].Contact_Title__c)
                                .replace('[Contact Email]', lstRRAC[0].Contact_Email__c)
                                .replace('[Contact Phone]', lstRRAC[0].Contact_Phone__c)
                                .replace('[User Name]', UserInfo.getName())
                                .replace('[Approve/Decline Notes]', refReqAccount.Approve_Deny_Notes__c)
                                .replace('[Opportunity Account]', refReqAccount.Reference_Request__r.Opportunity__c != null ? refReqAccount.Reference_Request__r.Opportunity__r.Account.Name : 'None');
            notificationBody = notificationBody.replace('[Disposition]', action)
                                .replace('[Request Type]', refReqAccount.Reference_Type_Needed_f__c)
                                .replace('[Requested Account]', refReqAccount.Account_f__c)
                                .replace('[Contact Name]', cwObj.name)
                                .replace('[Contact Title]', lstRRAC[0].Contact_Title__c)
                                .replace('[Contact Email]', lstRRAC[0].Contact_Email__c)
                                .replace('[Contact Phone]', lstRRAC[0].Contact_Phone__c)
                                .replace('Dispositioned By: [User Name]\n', UserInfo.getName())
                                .replace('[Approve/Decline Notes]', refReqAccount.Approve_Deny_Notes__c)
                                .replace('[Opportunity Account]', refReqAccount.Reference_Request__r.Opportunity__c != null ? refReqAccount.Reference_Request__r.Opportunity__r.Account.Name : 'None');
        }

        // Declined Post on Chatter
        if (cs.checkChatterSetting) {
            WithoutSharingHelperController.insertPostFeedItems(new List<sObject> {MailChatterController.preparePost('', refReqAccount.Requester__c, notificationBody, '')});
        }
        
        if (cs.checkEmailSetting) {
            listMail.add(MailChatterController.prepareEmail(approveDeclineNotification.Section_Name__c.replace('[Disposition]', action), refReqAccount.Requester__c,
                    notificationBody, false, headerDocId, footerDocId));
        }
        
        if (cs.checkSlackSetting) {
            Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('userEmail', refReqAccount.Requester__r.Email);
            tempReqBodyMap.put('text', '*' + approveDeclineNotification.Section_Name__c.replace('[Disposition]', action) + '*\n' + slackMsgBody);
            messagesList.add(tempReqBodyMap);
        }

        // added for #693 - posting a confirmation comment to the original request chatter post
        if (UtilityController.isNativeChatterSetting && cs.approveDeclineConfirmationChatter) {
            
            if (refReqAccount.Related_Feed_Item_Ids__c != null && refReqAccount.Related_Feed_Item_Ids__c != '') {
                String dispositionDate = monthMap.get(Date.today().month()) + ' ' + Date.today().day() + ', ' + Date.today().year();
                String confirmationBody = confirmationNotification.DC_Message__c + '\n\n';
                confirmationBody = confirmationBody.replace('[Disposition]', action)
                                                    .replace('[You/Approver Name]', refReqAccount.Reference_Owner__c != null ? 'You' : UserInfo.getName())
                                                    .replace('[Requested Account]', refReqAccount.Account_f__c)
                                                    .replace('[Disposition Date]', dispositionDate);
                
                for (String feedItemId : refReqAccount.Related_Feed_Item_Ids__c.split(',')) {
                    FeedComment fc = new FeedComment();
                    fc.CommentBody = confirmationBody;
                    fc.FeedItemId = feedItemId;
                    
                    if (protectedAppConfig.User_Id__c != null && protectedAppConfig.User_Id__c != '') {
                        fc.put('CreatedById', protectedAppConfig.User_Id__c);
                    }
                    feedCommentList.add(fc);
                }
            }
            
            if (feedCommentList != null && feedCommentList.size() > 0) {
                WithoutSharingHelperController.insertFeedComments(feedCommentList);
            }
        }
        
        // added for #693 - sending a confirmation mail to the recipient of the request
        if (cs.approveDeclineConfirmationEmail) {
            
            if (refReqAccount.Reference_Owner__c != null) {
		    	String dispositionDate = monthMap.get(Date.today().month()) + ' ' + Date.today().day() + ', ' + Date.today().year();
                String confirmationBody = confirmationNotification.DC_Message__c + '\n\n';
                confirmationBody = confirmationBody.replace('[Disposition]', action)
                                                    .replace('[You/Approver Name]', 'You')
                                                    .replace('[Requested Account]', refReqAccount.Account_f__c)
                                                    .replace('[Disposition Date]', dispositionDate);
                listMail.add(MailChatterController.prepareEmail(confirmationNotification.Section_Name__c.replace('[Disposition]', action),
                                            refReqAccount.Reference_Owner__c, confirmationBody, true, headerDocId, footerDocId));
    		} else if (refReqAccount.Related_Feed_Item_Ids__c != null
    						&& refReqAccount.Related_Feed_Item_Ids__c != '') {
    			
    			for (FeedItem fi : WithoutSharingHelperController.getFeedItems(refReqAccount.Related_Feed_Item_Ids__c.split(','))) {
    				
					if (fi.ParentId != null) {
						String dispositionDate = monthMap.get(Date.today().month()) + ' ' + Date.today().day() + ', ' + Date.today().year();
                        String confirmationBody = confirmationNotification.DC_Message__c + '\n\n';
                        confirmationBody = confirmationBody.replace('[Disposition]', action)
                                                            .replace('[You/Approver Name]', UserInfo.getName())
                                                            .replace('[Requested Account]', refReqAccount.Account_f__c)
                                                            .replace('[Disposition Date]', dispositionDate);
                        listMail.add(MailChatterController.prepareEmail(confirmationNotification.Section_Name__c.replace('[Disposition]', action),
																		fi.ParentId, confirmationBody, true, headerDocId, footerDocId));
					}
    			}
    		}
        }
        
        if (cs.approveDeclineConfirmationSlack) {
            String dispositionDate = monthMap.get(Date.today().month()) + ' ' + Date.today().day() + ', ' + Date.today().year();
            String confirmationBody = confirmationNotification.DC_Message__c + '\n\n';
            confirmationBody = confirmationBody.replace('[Disposition]', action)
                                                .replace('[You/Approver Name]', refReqAccount.Reference_Owner__c != null ? 'You' : UserInfo.getName())
                                                .replace('[Requested Account]', refReqAccount.Account_f__c)
                                                .replace('[Disposition Date]', dispositionDate);
            Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('text', '*' + confirmationNotification.Section_Name__c.replace('[Disposition]', action) + '*\n' + confirmationBody);
            
            if (refReqAccount.Reference_Owner__c != null) {
                tempReqBodyMap.put('userEmail', refReqAccount.Reference_Owner__r.Email);
    		}
            messagesList.add(tempReqBodyMap);
        }

        if (listMail != null && listMail.size() > 0) {
    		Messaging.sendEmail(listmail);
    	}

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
        }
    }

    /**
     * Method to Decline Request
     */
    @RemoteAction
    public static String decline(String refReqAccId, CustomSettingWrapper cs, String notes) {
        String error = '';
        Savepoint sp = Database.setSavepoint();
        // changes for #693 - Gaurav Saini (5 Apr, 2017)
        List<Reference_Request_Account__c> currentRRAList = new List<Reference_Request_Account__c>();
        
        try {
            List<Reference_Request_Account__c> listRefReqAccount
            			= WithoutSharingHelperController.getAccountRequests(new Set<Id> { Id.valueOf(refReqAccId) });
            Reference_Request_Account__c refReqAccount = new Reference_Request_Account__c();
            
            if (listRefReqAccount.size() > 0) {
            	refReqAccount = listRefReqAccount[0];
            	// changes for #693 - Gaurav Saini (5 Apr, 2017)
            	currentRRAList.addAll(listRefReqAccount);
            }
            
            if (refReqAccount.Account_Request_Status__c == ConstantsController.UNAVAILABLE) {
                error = System.Label.REQUEST_EXPIRED_NO_NEED_TO_RESPOND;
                return error;
            }
            // Update Reference Request Account Object Fields
            refReqAccount.Approval_Status__c = ConstantsController.DECLINED;
            refReqAccount.Approve_Deny_Notes__c = notes;
            refReqAccount.Account_Request_Status__c = ConstantsController.COMPLETED;
            refReqAccount = WithoutSharingHelperController.upsertRRA(refReqAccount);
            // Call Method to Update Task
            updateTask(ConstantsController.DECLINED, refReqAccount, new List<Reference_Request_Account_Contact__c>(), new Map<Id, String>());
            prepareChatterEmailMessages(refReqAccount, cs, ConstantsController.DECLINED, null, null);
        } catch (Exception e) {
            Database.rollback(sp);
            error = e.getMessage();
        }
        return error;
    }
    
    /**
     * RemoteAction to approve Request
     */
 	@RemoteAction
    public static String approve(String refReqAccId, String oppAccName, String notes, String contactWpsJSON,
											CustomSettingWrapper cs, String selectedContactId, Boolean isUpdateContact) {
        Savepoint sp = Database.setSavepoint();
        String error = '';
        // changes for #693 - Gaurav Saini (5 Apr, 2017)
        List<Reference_Request_Account__c> currentRRAList = new List<Reference_Request_Account__c>();
        
        try {
        	Map<Id, String> mapContacts = new Map<Id, String>();
        	List<ContactWrapper> contactWps
        				= (List<ContactWrapper>)JSON.deserialize(contactWpsJSON, List<ContactWrapper>.class);
        	List<Reference_Request_Account__c> listRefReqAccount
        				= WithoutSharingHelperController.getAccountRequests(new Set<Id> { Id.valueOf(refReqAccId) });
            Reference_Request_Account__c refReqAccount = new Reference_Request_Account__c();
            
            Set<Id> requestedContactIdSet = new Set<Id>();
			Set<Id> selectedReferenceabilityTypeIdSet = new Set<Id>();
			
            if (listRefReqAccount.size() > 0) {
            	refReqAccount = listRefReqAccount[0];
            	// changes for #693 - Gaurav Saini (5 Apr, 2017)
            	currentRRAList.addAll(listRefReqAccount);
            }
            List<Reference_Request_Account_Contact__c> lstRRAC = new List<Reference_Request_Account_Contact__c>();
            
            if (refReqAccount.Account_Request_Status__c == ConstantsController.UNAVAILABLE) {
                error = System.Label.REQUEST_EXPIRED_NO_NEED_TO_RESPOND;
                return error;
            }
            ContactWrapper cwObj = new ContactWrapper();
            
            for (ContactWrapper cw : contactWps) {
            	mapContacts.put((Id)cw.id,cw.name);
            	
            	if (cw.id == selectedContactId) {
            		cwObj = cw;
            	}
            }
            List<Contact> contacts = WithoutSharingHelperController.getContact(new Set<String> {selectedContactId} );
            
            for (Contact con : contacts) {
            	con.Email = cwObj.email;
            	con.Phone = cwObj.phone;
            	con.Title = cwObj.title;
            }
            Boolean isContactActive = true;
            
            if (cs.isShowInactive && selectedContactId != null && selectedContactId != '' && (!cwObj.isMember || !cwObj.active)) {
                isContactActive = false;
            }
            
            if (selectedContactId != null && selectedContactId.trim().length() > 0) {
                List<Reference_Request_Account_Contact__c > oldrrac
                			= WithoutSharingHelperController.getAccountContactRequests(new Set<String> { refReqAccId });
                
                if (cwObj != null) {
                    Reference_Request_Account_Contact__c newRRAC = new Reference_Request_Account_Contact__c();
                    
                    if (oldrrac.size() > 0) {
                        newRRAC = oldrrac[0];
                    }
                    newRRAC.Contact__c = cwObj.id;
                    newRRAC.Contact_Email__c = UtilityController.checkValueOfString(cwObj.Email);
                    newRRAC.Contact_Phone__c = UtilityController.checkValueOfString(cwObj.Phone);
                    newRRAC.Contact_Title__c = UtilityController.checkValueOfString(cwObj.Title);
                    newRRAC.Reference_Request_Account__c = refReqAccount.Id;
                    newRRAC.Referenceability_Type__c = refReqAccount.Reference_Type_Needed__c;
                    newRRAC.Approval_Status__c = ConstantsController.APPROVED;
                    newRRAC.Activity_Date__c = date.today();
                    newRRAC.deadline__c = refReqAccount.Deadline__c;
                    newRRAC.Approve_Deny_Notes__c = notes;
                    newRRAC.Is_Reminder_to_Owner__c = refReqAccount.Is_Reminder_to_Owner__c;
                    newRRAC.Is_Escalation_to_Owner_Manager__c = refReqAccount.Is_Escalation_to_Owner_Manager__c;
                    newRRAC.Request_notes__c = refReqAccount.Request_Notes__c;
                    newRRAC.Is_No_Response__c = refReqAccount.Is_No_Response__c;
                    newRRAC.Contact_Request_Status__c = ConstantsController.COMPLETED;
                    lstRRAC.add(newRRAC);
                    requestedContactIdSet.add(newRRAC.Contact__c);
                    selectedReferenceabilityTypeIdSet.add(newRRAC.Referenceability_Type__c);
                }
            }
            
            if (lstRRAC.size() > 0 && isContactActive) {
                lstRRAC = WithoutSharingHelperController.upsertRRACList(lstRRAC);
                
                if(cs.isAddReferenceabilityOnP2PUse) {
                	List<Referenceability__c> contactExistingReferenceabilityList = [SELECT Id, Contact__c, Referenceability_Type__c FROM Referenceability__c 
                																	WHERE Contact__c IN: requestedContactIdSet AND 
                																	Referenceability_Type__c IN: selectedReferenceabilityTypeIdSet];
                
	                Map<Id, Set<Id>> requestedContIdToExistingReferenceabilityTypeIdSet = new Map<Id, Set<Id>>();
	                for(Referenceability__c referenceability : contactExistingReferenceabilityList) {
	                	if(!requestedContIdToExistingReferenceabilityTypeIdSet.containsKey(referenceability.Contact__c)) {
	                		requestedContIdToExistingReferenceabilityTypeIdSet.put(referenceability.Contact__c, new Set<Id>());
	                	}
	                	requestedContIdToExistingReferenceabilityTypeIdSet.get(referenceability.Contact__c).add(referenceability.Referenceability_Type__c);
	                }
	                
	                List<Referenceability__c> contactReferenceabilityListToInsert = new List<Referenceability__c>();
	                for(Reference_Request_Account_Contact__c refReqAccContact : lstRRAC) {
	                	if(!requestedContIdToExistingReferenceabilityTypeIdSet.containsKey(refReqAccContact.Contact__c) 
	                		|| !requestedContIdToExistingReferenceabilityTypeIdSet.get(refReqAccContact.Contact__c).contains(refReqAccContact.Referenceability_Type__c)) {
	                		contactReferenceabilityListToInsert.add(new Referenceability__c(Contact__c = refReqAccContact.Contact__c, Referenceability_Type__c = refReqAccContact.Referenceability_Type__c,
	                																		Account__c = refReqAccount.Account__c));
	                	} 
	                } 
	                
	                if(contactReferenceabilityListToInsert != null && contactReferenceabilityListToInsert.size() > 0) {
	                	insert contactReferenceabilityListToInsert;
	                } 
                } 
            }
            // Update Reference Request Account Object Fields
            refReqAccount.Approve_Deny_Notes__c = notes;
            refReqAccount.Approval_Status__c = ConstantsController.APPROVED;
            refReqAccount.Account_Request_Status__c = ConstantsController.COMPLETED;
            refReqAccount = WithoutSharingHelperController.upsertRRA(refReqAccount);
            
            if (isUpdateContact) {
                contacts = WithoutSharingHelperController.upsertContacts(contacts);
            }
            // Call Method to Update Task
            updateTask(ConstantsController.APPROVED, refReqAccount, lstRRAC, mapContacts);
            prepareChatterEmailMessages(refReqAccount, cs, ConstantsController.APPROVED, lstRRAC, cwObj);
            
            if (cs.autoAssignReward && RefEdgeEditionFeatures.isBasic == false 
            								&& refReqAccount.Approval_Status__c == ConstantsController.APPROVED 
            								&& cs.enableSalesRewardNotifiation ==  true) {
        		List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
        		List<Referenceability_Type__c> refType = [SELECT Name, Id, Sales_Point__c
        													FROM Referenceability_Type__c 
        													WHERE Visible__c = true AND Id = :refReqAccount.Reference_Type_Needed__c
        													ORDER BY Name LIMIT 1];
        	 	
        	 	if (refType.size() > 0) {   
        	 		
        			if (refType[0].Sales_Point__c != null) {
				        rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
				        									Referenceability_Type__c = refType[0].Id, 
		        											Transaction__c = ConstantsController.ISSUE, 
		                                                 	RewardDate__c = Date.Today(),
		                                                 	User__c = UserInfo.getUserId()));
        	 		}
				  	
			       	// re #591 NEW field Onscreen Notification allow for on/off for onscreen notification.
		            if (cs.onscreenNotification) {                                          
          				error = 'success:' + refType[0].Sales_Point__c;    
		            }                 
			    }  
			    
			    if (rewardsToBeInsert.size() > 0)  {
                    UtilityController.isUserProfileExist(Userinfo.getUserId());
		            WithoutSharingHelperController.insertRewards(rewardsToBeInsert); 
			    }
        	}
        } catch (Exception e) {
            Database.rollback(sp);
            error = e.getMessage();
        }
        return error;
    }
    
    /**
     * Method to Update Task on Approve & decline 
     */
    public static void updateTask(String updateType, Reference_Request_Account__c refReqAccount, 
    								List<Reference_Request_Account_Contact__c> lstRRAC, Map<Id, String> mapContacts) {
        Date d = (Date) refReqAccount.Deadline__c;
        DateTime dtValue = DateTime.newInstance(d.year(), d.month(), d.day());
        List<Task> task = WithoutSharingHelperController.fetchTask(refReqAccount.Task_Id__c);
        
        if (task.size() > 0) {
            // Start Description Body contents for Task
            String txt = '\n\n************************************************************\n\n';
            
            if (updateType == ConstantsController.DECLINED) {
                txt += UserInfo.getName() + ' has declined the ' + refReqAccount.Reference_Type_Needed_f__c 
                					+ ' reference use for ' + refReqAccount.Account_f__c + ' that was scheduled for ' 
                					+ dtValue.format('EEE, MMMM d, yyyy') + '.\n\n';
            } else {
                txt += UserInfo.getName() + ' has approved the ' + refReqAccount.Reference_Type_Needed_f__c 
                					+ ' reference use for ' + refReqAccount.Account_f__c + ' that was scheduled for ' 
                					+ dtValue.format('EEE, MMMM d, yyyy') + '.\n\n  Contact Details:\n' +
                    				MailChatterController.getApproveMessageContactsDetalis(lstRRAC, mapContacts);
            }
            txt += ' Request Notes: ' + refReqAccount.Approve_Deny_Notes__c;
            task[0].Description += txt;
            task[0].Status = ConstantsController.COMPLETED;
            WithoutSharingHelperController.updateTask(task);
        }
    }
    
    /**
     * RemoteAction to get intial information
     */
    @RemoteAction
    public static String fetchInfo(String refReqAccId) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	if (refReqAccId != null && refReqAccId.trim().length() > 0) {
            List<Reference_Request_Account__c> listRefReqAccount
            			= WithoutSharingHelperController.getAccountRequests(new Set<Id> { Id.valueOf(refReqAccId) });
            if (listRefReqAccount.size() > 0) {
                Reference_Request_Account__c refReqAccount = listRefReqAccount[0];
                infoWp.rraAccountId = refReqAccount.Account__c;
		    	infoWp.rraAccountName = refReqAccount.Account__r.Name;
		    	infoWp.rraRefType = refReqAccount.Reference_Type_Needed__c;
		    	infoWp.rraRefTypeName = refReqAccount.Reference_Type_Needed_f__c;
		    	infoWp.rraRequester = refReqAccount.Requester__c;
		    	infoWp.rraRequesterName = refReqAccount.Requester__r.Name;
		    	infoWp.requesterNotes = refReqAccount.Request_Notes__c;
		    	infoWp.routingCriteria = refReqAccount.Adv_Routing_Criteria__c;
		    	infoWp.requestCreationDate = refReqAccount.CreatedDate.format('EEE MMMM d, YYYY');
		    	
                if (checkForCorrectApprover(listRefReqAccount)) {
                	
                    if (refReqAccount.Approval_Status__c != null) {
                        infoWp.isAnyError = true;
                		infoWp.info = system.Label.Approve_Decline_already;
                    } else {
                        Boolean chkManagedRequest = (refReqAccount.Managed_Request__c ? checkRRAProcess(refReqAccount.Id) : false);
                        
                        if (chkManagedRequest) {
                        	infoWp.isAnyError = true;
                			infoWp.info = system.Label.NO_NEED_TO_RESPOND;
                        } else {
                        	
                        	if (refReqAccount.Account_Request_Status__c == 'Unavailable') {
                        		infoWp.isAnyError = true;
                				infoWp.info = system.Label.REQUEST_EXPIRED_NO_NEED_TO_RESPOND;
                        	} else {
		                        List<Reference_Request__c> tempList = WithoutSharingHelperController.getReferenceReqDetails(refReqAccount.Reference_Request__c);
		                        
		                        if (tempList.size() > 0) {
		                            Reference_Request__c refRequest = tempList[0];
		                            infoWp.oppName = (tempList[0].Opportunity__c != null ? tempList[0].Opportunity__r.Name : '');
							    	infoWp.oppAccName = (tempList[0].Opportunity__c != null ? tempList[0].Opportunity__r.Account.Name : '');
							    	infoWp.caseName = (tempList[0].Case__c != null ? tempList[0].Case__r.CaseNumber : '');
							    	infoWp.caseAccName = (tempList[0].Case__c != null ? tempList[0].Case__r.Account.Name : '');
							    	infoWp.opportunityId = tempList[0].Opportunity__c;
							    	infoWp.caseId = tempList[0].Case__c;
							    	infoWp.opportunityId = (infoWp.opportunityId != null ? infoWp.opportunityId : '');
							    	infoWp.caseId = (infoWp.caseId != null ? infoWp.caseId : '');
							    	//regarding ticket #809
							    	infoWp.leadName = (tempList[0].Lead__c != null ? tempList[0].Lead__r.Name : '');
							    	infoWp.leadCompany = (tempList[0].Lead__c != null ? tempList[0].Lead__r.Company : '');
							    	infoWp.leadId = tempList[0].Lead__c;
							    	infoWp.leadId = (infoWp.leadId != null ? infoWp.leadId : '');
		                        }
                        	}
                        }
                    }
                } else {
                	infoWp.isAnyError = true;
                	infoWp.info = system.Label.Incorrect_Owner;
                }
            } else {
                infoWp.isAnyError = true;
                infoWp.info = system.Label.Record_Deleted;
            }
        }
        return JSON.serialize(infoWp);
    }
    
    /**
     * RemoteAction to get Custom setting
     */
    @RemoteAction
    public static CustomSettingWrapper fetchCS() {
        return new CustomSettingWrapper(UtilityController.getCustomSettings());
    }
    
    /**
     * Method to check for correct approver
     */
    private static Boolean checkForCorrectApprover(List<Reference_Request_Account__c> listRefReqAccount) {
        Set<String> accIds = new Set<String>();
        Boolean showPage = true;
        
        for (Reference_Request_Account__c rra : listRefReqAccount) {
            accIds.add(rra.account__c);
        }
        String requestApprover = '';
        
        for (Account acc : WithoutSharingHelperController.getAccountRecords(accIds)) {
        	
            if (acc.Reference_Basic_Informations__r.size() > 0) {
            	
                if (acc.Reference_Basic_Informations__r[0].Reference_Owner__c != null) {
                    requestApprover = acc.Reference_Basic_Informations__r[0].Reference_Owner__c;
                } else {
                    requestApprover = acc.OwnerId;
                }
            }
        }
        User u = WithoutSharingHelperController.getUser(requestApprover);
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        
        if (requestApprover == Userinfo.getUserId() || u.ManagerId == Userinfo.getUserId() || cs.Adv_Request_Routing__c) {
            showPage = true;
        } else {
            showPage = false;
        }
        return showPage;
    }
    
    /**
     * RemoteAction to get Contacts associated to requested account
     */
    @RemoteAction
    public static String fetchContacts(String accountId){
    	List<ContactWrapper> contacts = new List<ContactWrapper>();
    	List<Contact> c1 = new List<Contact>();
    	List<Contact> c2 = new List<Contact>();
    	
    	for (Contact con : WithoutSharingHelperController.getAccountContacts(accountId, UtilityController.getCustomSettings())) {
    		
    		if (con.Reference_Basic_Informations__r.size() > 0) {
    			
                for (Reference_Basic_Information__c rbi : con.Reference_Basic_Informations__r) {
                	
                	if (rbi.Is_Referenceable__c && (rbi.Referenceability_Status__c != ConstantsController.INACTIVE 
                												&& rbi.Referenceability_Status__c != '')) {
    					c1.add(con);
                	} else {
                		c2.add(con);
                	}
                }
    		} else {
    			c2.add(con);
    		}
    	}
    	
    	for (Contact con : c1) {
    		contacts.add(new ContactWrapper(con));
    	}
    	
    	for (Contact con : c2) {
    		contacts.add(new ContactWrapper(con));
    	}
        return JSON.serialize(contacts);
    }
    
    /**
     * RemoteAction to activate the selected contact
     */
    @RemoteAction
    public static String activateContact(String contactId, Boolean checkProfileCreatedEmail,
            Boolean checkProfileCreatedChatter, Boolean checkProfileCreatedSlack, String slackTeamIds) {

    	try {
            ContactWrapper contact = new ContactWrapper();
    		List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRefProfiles('', contactId);
            String accName;
            String conName;
            String contactRbiId = '';
            
            if (rbi.size() > 0) {
                accName = rbi[0].Account__c != null ? rbi[0].Account__r.Name : '';
                conName = rbi[0].Contact__c != null ? rbi[0].Contact__r.Name : '';
                contactRbiId = rbi[0].Id;
                rbi[0].Is_Referenceable__c = true;
                rbi[0].Referenceability_Status__c = ConstantsController.ACTIVE;
                rbi[0].Reference_Program_Candidate__c = false;
                update rbi;
            } else {
                List<Contact> con = WithoutSharingHelperController.getContact(new Set<String> { contactId });
                conName = con[0].Name;
                accName = con[0].AccountId != null ? con[0].Account.Name : '';
				Reference_Basic_Information__c newrbi = new Reference_Basic_Information__c(Contact__c = con[0].Id, Account__c = con[0].AccountId,
									Is_Referenceable__c = true, Referenceability_Status__c = ConstantsController.ACTIVE);
				newrbi = WithoutSharingHelperController.insertContactRBI(newrbi);
                contactRbiId = newrbi.Id;
            }
            
	    	for (Contact con : WithoutSharingHelperController.getContact(contactId)) {
	    		contact = new ContactWrapper(con);
	    	}
            List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();
            List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
            List<sObject> postFeedItems = new List<sObject>();
            String headerDocId = '';
            String footerDocId = '';
            Data_Mapping__c profileCreatedNotification = new Data_Mapping__c();
            Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Profile_Created_Email__c'};

            for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = 'Notification'
                                        AND (Field_API_Name__c IN :notificationFieldNames
                                            OR Section_Name__c = 'email header doc'
                                            OR Section_Name__c = 'email footer doc')]) {

                if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Profile_Created_Email__c') {
                    profileCreatedNotification = dm;
                } else if (dm.Section_Name__c == 'email header doc') {
                    headerDocId = dm.Field_API_Name__c;
                } else if (dm.Section_Name__c == 'email footer doc') {
                    footerDocId = dm.Field_API_Name__c;
                }
            }
            String sfBaseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/';
            Map<String, Object> slackReqBody = new Map<String, Object>();
            slackReqBody.put('teamId', slackTeamIds);
            slackReqBody.put('orgId', UserInfo.getOrganizationId());
            List<Map<String, String>> messagesList = new List<Map<String, String>>();
            String body = profileCreatedNotification.DC_Message__c + '\n\n' + profileCreatedNotification.Default__c;
            body = body.replace('[Account Name]', accName)
                        .replace('[Creator Name]', Userinfo.getName())
                        .replace('[Contact Name]', conName);

            if (UtilityController.isNativeChatterSetting && checkProfileCreatedChatter) {

                for (User gm : publicGroupMembers) {
                    String userId = gm.Id;
                    
                    if (userId.startsWith('005')) {
                        postFeedItems.add(MailChatterController.preparePost(profileCreatedNotification.Section_Name__c, userId, body, sfBaseUrl + contactRbiId));
                    }
                }
            }
            
            if (checkProfileCreatedEmail) {

                for (User gm : publicGroupMembers) {
                    String userId = gm.Id;
                    
                    if (userId.startsWith('005')) {
                        listmail.add(MailChatterController.prepareEmail(profileCreatedNotification.Section_Name__c, userId, body + '\n\n' + profileCreatedNotification.Section_Name__c + ' <a href="' + sfBaseUrl + contactRbiId + '">' + sfBaseUrl + contactRbiId + '</a>', false, headerDocId, footerDocId));
                    }
                }
            }
            
            if (checkProfileCreatedSlack) {
                Map<String, String> tempReqBodyMap = new Map<String, String>();
                tempReqBodyMap.put('text', body
                        + '\n<' + sfBaseUrl + contactRbiId + '|'
                        + profileCreatedNotification.Section_Name__c + '>');
                messagesList.add(tempReqBodyMap);
            }
            
            if (postFeedItems.size() > 0) {
                postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
            }
            
            if (listmail.size() > 0) {
                Messaging.sendEmail(listmail);
            }

            if (messagesList.size() > 0) {
                slackReqBody.put('messages', messagesList);
                UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
            }
	        return JSON.serialize(contact);
        } catch (DMLException e) {
            ApexPages.addMessages(e);
            return JSON.serialize(new ContactWrapper());
        }
    }
    
    /**
     * RemoteAction to create a new contact
     */
    @RemoteAction
    public static String createContact(String contactJSON, String accountId) {
    	String result = '';

    	try {
			ContactWrapper contact = (ContactWrapper)JSON.deserialize(contactJSON, ContactWrapper.class);
    		Contact con = new Contact(LastName = contact.id, FirstName = contact.name, Email = contact.email,
    									Phone = contact.phone, Title = contact.title, AccountId = accountId);
        	insert con;
        	result = '';
        } catch (system.DMLException e) {
            
			for (Integer i = 0; i < e.getNumDml(); i++) {
				result = e.getDmlMessage(i);
			}
        }
		return result;
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage() {
		checkPermissions();
		return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put('Contact', new Set<String>{'LastName', 'FirstName', 'Email', 'Phone', 'Title', 'AccountId'});
        
        fieldMap.put(UtilityController.appNamespace() + 'Referenceability__c', new Set<String> { 
		        									UtilityController.appNamespace() + 'Account__c',
		        									UtilityController.appNamespace() + 'Contact__c',
		        									UtilityController.appNamespace() + 'Comment__c',
		        									UtilityController.appNamespace() + 'Status__c',
		        									UtilityController.appNamespace() + 'Verified__c',
		        									UtilityController.appNamespace() + 'Referenceability_Type__c' });
		
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        return isUpsertPermission;
    }
    
    /**
     * Method to Check is RRA converted into Rep2Rep to Managed
     */
    public static Boolean checkRRAProcess(String refReqAccId) {
        List<Reference_Request_Account__History> rraHistory = WithoutSharingHelperController.getRRAHistory(refReqAccId);
        
        if (!rraHistory.isEmpty()) {
        	
            if (rraHistory[0].OldValue != rraHistory[0].NewValue) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * Wrapper class for request and Account request information
     */
 	public class InfoWrapper {
 		public String info { get; set; }
	    public Boolean isAnyError { get; set; }
	    public String oppName { get; set; }
	    public String oppAccName { get; set; }
	    public String caseName { get; set; }
	    public String caseAccName { get; set; }
	    public String accId { get; set; }
	    public String opportunityId { get; set; }
	    public String caseId { get; set; }
	    public String rraAccountId { get; set; }
	    public String rraAccountName { get; set; }
	    public String rraRefType { get; set; }
	    public String rraRefTypeName { get; set; }
	    public String rraRequester { get; set; }
	    public String rraRequesterName { get; set; }
	    public String notes { get; set; }
	    public String requesterNotes { get; set; }
	    public String routingCriteria { get; set; }
	    //regarding ticket #809
	    public String leadId { get; set; }
	    public String leadName { get; set; }
	    public String leadCompany { get; set; }
	    public String requestCreationDate { get; set; }
	    public InfoWrapper() {
	    	info = '';
	    	isAnyError = false;
	    	oppName = '';
	    	oppAccName = '';
	    	caseName = '';
	    	caseAccName = '';
	    	accId = '';
	    	opportunityId = '';
	    	caseId = '';
	    	//regarding ticket #809
	    	leadId = '';
	    	leadName = '';
	    	leadCompany = '';
	    	rraAccountId = '';
	    	rraAccountName = '';
	    	rraRefType = '';
	    	rraRefTypeName = '';
	    	rraRequester = '';
	    	rraRequesterName = '';
	    	notes = '';
	    	requesterNotes = '';
	    	routingCriteria = '';
			requestCreationDate = '';
	    }
 	}
 	
 	/**
     * Wrapper class for Contacts
     */
 	public class ContactWrapper {
 		public String status { get; set; }
	    public Boolean active { get; set; }
	    public String id { get; set; }
	    public String name { get; set; }
	    public Boolean isMember { get; set; }
	    public String title { get; set; }
	    public String email { get; set; }
	    public String phone { get; set; }
	    public String lastUsedDate { get; set; }
	    public Boolean isEmailEdit { get; set; }
	    public Boolean isPhoneEdit { get; set; }
	    public Boolean isTitleEdit { get; set; }
	    public Boolean isEmailEdited { get; set; }
	    public Boolean isPhoneEdited { get; set; }
	    public Boolean isTitleEdited { get; set; }
        //REF-2320
        public String attributes { get; set; }
        public String referenceabilities { get; set; }
        public String accountId { get; set; }
	    
	    public ContactWrapper() {}
	    
 		public ContactWrapper(Contact con) {
 			id = con.Id;
	    	name = con.Name;
	    	email = con.Email;
	    	phone = con.Phone;
	    	title = con.Title;
	    	isEmailEdit = false;
	    	isPhoneEdit = false;
	    	isTitleEdit = false;
	    	isEmailEdited = false;
	    	isPhoneEdited = false;
	    	isTitleEdited = false;
            //REF-2320
            attributes = '';
            referenceabilities = '';
            accountId = con.AccountId;
	    	
	    	if (con.Reference_Basic_Informations__r.size() > 0) {
	    		
	    		for (Reference_Basic_Information__c rbi : con.Reference_Basic_Informations__r) {
                    
                    //REF-2320
                    Map<String, Object> rbiFieldsToValue = rbi.getPopulatedFieldsAsMap();
                    if (rbiFieldsToValue.containsKey(UtilityController.appNamespace() + 'Attributes__c') && !String.isBlank(rbi.Attributes__c)) {
                        attributes = rbi.Attributes__c;
                    }
                    
                    if (rbiFieldsToValue.containsKey(UtilityController.appNamespace() + 'Referenceability__c') && !String.isBlank(rbi.Referenceability__c)) {
                        referenceabilities = rbi.Referenceability__c;
                    }
	    			
	    			if (rbi.Is_Referenceable__c && (rbi.Referenceability_Status__c != ConstantsController.INACTIVE && rbi.Referenceability_Status__c != '')) {
	    				status = rbi.Referenceability_Status__c;
				    	active = true;
				    	isMember = true;
				    	lastUsedDate = (rbi.RUL_Last_Activity_Date__c != null ? rbi.RUL_Last_Activity_Date__c.format() : '');
	    			} else {
	    				status = rbi.Referenceability_Status__c;
				    	active = false;
				    	isMember = rbi.Is_Referenceable__c;
				    	lastUsedDate = (rbi.RUL_Last_Activity_Date__c != null ? rbi.RUL_Last_Activity_Date__c.format() : '');
	    			}
	    			break;
	    		}
	    	} else {
		    	status = '';
		    	active = false;
		    	isMember = false;
		    	lastUsedDate = '';
	    	}
 		}
 	}
 	
 	/**
     * Wrapper Class 
     */
 	public class CustomSettingWrapper {
 		public String name { get; set; }
 		public Boolean isShowInactive { get; set; }
 		public Boolean checkChatterSetting { get; set; }
 		public Boolean checkEmailSetting { get; set; }
 		public Boolean checkSlackSetting { get; set; }
 		public Boolean approveWithoutContact { get; set; }
 		public Boolean autoAssignReward { get; set; }
 		public Boolean enableSalesRewardNotifiation { get; set; }
 		public Boolean onscreenNotification { get; set; }
 		public Boolean approveDeclineConfirmationChatter { get; set; }
 		public Boolean approveDeclineConfirmationEmail { get; set; }
 		public Boolean approveDeclineConfirmationSlack { get; set; }
 		public String slackTeamIds { get; set; }
        public Boolean isAddReferenceabilityOnP2PUse { get; set; } // Start: Ref-2129 
        public Boolean checkProfileCreatedEmail { get; set; } 
        public Boolean checkProfileCreatedChatter { get; set; } 
        public Boolean checkProfileCreatedSlack { get; set; } 
 		
 		public CustomSettingWrapper(Custom_Settings__c cs) {
 			this.name = cs.name;
 			this.checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Approval_Decline_Chatter__c);
	        this.checkEmailSetting = cs.Request_Approval_Decline_Email__c;
	        this.checkSlackSetting = cs.Request_Approval_Decline_Slack__c;
	        this.isShowInactive = cs.P2P_Select_Inactive_Contacts__c;
	        this.approveWithoutContact = cs.P2P_Approve_Without_Contact__c;	
	        this.autoAssignReward = cs.Auto_Assign_Sales_Rewards__c;
	        this.enableSalesRewardNotifiation = cs.Enable_Sales_Rewards_Notification__c;
	        this.onscreenNotification = cs.User_Reward_Onscreen_Notification__c;
	        this.approveDeclineConfirmationChatter = cs.Approve_Decline_Confirmation_Chatter__c;
	        this.approveDeclineConfirmationEmail = cs.Approve_Decline_Confirmation_Email__c;
	        this.approveDeclineConfirmationSlack = cs.Enable_Slack_Integration__c && cs.Approve_Decline_Confirmation_Slack__c;
            this.slackTeamIds = cs.Slack_Team_Ids__c != null ? cs.Slack_Team_Ids__c : '';
            this.isAddReferenceabilityOnP2PUse = cs.Refedge_P2P_Use_Adds_Ref__c; // Start: Ref-2129
            this.checkProfileCreatedEmail = cs.Profile_Created_Email__c;
            this.checkProfileCreatedChatter = cs.Profile_Created_Chatter__c;
            this.checkProfileCreatedSlack = cs.Enable_Slack_Integration__c && cs.Profile_Created_Slack__c;
 		}
 	}
    
    //REF-2320
    @RemoteAction
    public static String rollUpAttribute(String recordInfo, Boolean isAccount, String accountId) {        
        String attributes = '';

        if(recordInfo != '' && recordInfo != null && isAccount){
            attributes = UtilityController.rollUpAttributeMappingRBI(Id.valueOf(recordInfo), true, null);
        } else if(recordInfo != '' && recordInfo != null && !isAccount) {
            attributes = UtilityController.rollUpAttributeMappingRBI(Id.valueOf(recordInfo), false, Id.valueOf(accountId));
        }
        return attributes.removeEnd(', ');
    }
}