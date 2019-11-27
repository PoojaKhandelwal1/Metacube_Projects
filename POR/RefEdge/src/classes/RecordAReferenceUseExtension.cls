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
 * VF Page: RecordAReferenceUse.page
 * Description: Class used to create account/contact request.
 * Modified by: Rajesh for ticket #841
 */
public with sharing class RecordAReferenceUseExtension extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Boolean fromAccount { get; set; }
    public Boolean fromContact { get; set; }
    public Boolean fromOpportunity { get; set; }
    public Reference_Request__c refReqObject { get; set; }
    public Reference_Request_Account__c refReqAccountObject { get; set; }
    public Reference_Request_Account_Contact__c refReqAccContactObject { get; set; }
    public List<SelectOption> referenceabilityTypes { get; set; }
    public List<SelectOption> associatedContacts { get; set; }
    public List<SelectOption> accounts { get; set; }
    public List<SelectOption> feedbackOption { get; set; }
    public String status { get; set; }
    public Boolean accountReferenceability { get; set; }
    public Boolean contactReferenceability { get; set; }
    public String feedbackSelected { get; set; }
    public String selectedContact { get; set; }
    public String selectedAccount { get; set; }
    public Boolean isContactSelected { get; set; }
    private Map<Id, Contact> contactMap;
    private Map<Id, Account> accountMap;
    private Custom_Settings__c cs;
    private String objId;
    public String useCompleted { get; set; }
    public Boolean isLimitExceeded { get; set; }
    public String useCompleted_Success { get; set; }
    private List<sObject> postFeedItems = new List<sObject>();
    // This field is use to show reward points in disolving alert for sales reward issue to user
    public transient Decimal rewardPoints { get; set; }
    // This field is use to show action message in disolving alert for sales reward issue to user
    public transient String actionMessage { get; set; }
    public Boolean isError { get; set; }
    // added for #901 - to control the visibility of contact picklist on the page
    public Boolean showContactPicklist { get; set; }
    public Boolean isSLDS { get; set; }
    public String returnUrl { get; set; } 
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'Reference_Request__c',
    										new Set<String>{UtilityController.appNamespace() + 'Reference_Use__c',
												UtilityController.appNamespace() + 'Reference_Request_Status__c'});

        if (fromContact) {
			fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Account_Contact__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Contact__c',
												UtilityController.appNamespace() + 'Reference_Use__c',
												UtilityController.appNamespace() + 'Is_Feedback_Received__c',
												UtilityController.appNamespace() + 'Activity_Date__c',
												UtilityController.appNamespace() + 'Contact_Title__c'});
        }
        Boolean isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        return isInsertPermission;
    }
    
    /**
     * Constructor
     */
    public RecordAReferenceUseExtension() {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }

        if (!isSLDS) { 
	    	showContactPicklist = Schema.sObjectType.Reference_Request_Account_Contact__c.fields.Contact__c.isCreateable();
	        objId = ApexPages.currentPage().getParameters().get('Id');
	        
	         // re REF-1522 - check and get return URL 
	        if (objId != null && (objId.startsWith('001') || objId.startsWith('003'))) {
		        returnUrl = '/' + objId;
	        } else {
		        returnUrl = System.URL.getSalesforceBaseURL().toExternalForm();  
	        }
	        feedbackSelected = '';
	        fromAccount = false;
	        fromContact = false;
	        fromOpportunity = false;
	        accountReferenceability = false;
	        contactReferenceability = false;
	        isContactSelected = false;
	        rewardPoints = 0;
	        actionMessage = '';
	        isLimitExceeded = false;
	        Account account;
	        Opportunity opp;
	        cs = UtilityController.getCustomSettings();
	        status = ConstantsController.REFERENCE_STATUS_MSG.replace('@@@3', cs.Default_Referenceablity_Status__c);
	        status = status.replace('@@@2', System.Label.Record_a_Reference);
	        refReqObject = new Reference_Request__c();
	        refReqAccountObject = new Reference_Request_Account__c();
	        refReqAccContactObject = new Reference_Request_Account_Contact__c();
	        feedbackOption = new List<SelectOption>();
	        feedbackOption.add(new SelectOption('', '--None--'));
	        isError = false;
	        useCompleted_Success = ConstantsController.FEEDBACK_SUCCESSFUL;
	        useCompleted = ConstantsController.FEEDBACK_UNSUCCESSFUL;
	        Schema.DescribeFieldResult fieldResult = Reference_Request_Account_Contact__c.Feedback_Status__c.getDescribe();
	        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	        for (Schema.PicklistEntry f : ple) {
	        	
	            if (f.getValue() == ConstantsController.FEEDBACK_SUCCESSFUL
	            			|| f.getValue() == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
	                feedbackOption.add(new SelectOption(f.getLabel(), f.getValue()));
	            }
	        }
	        // Referenceability Picklist
	        referenceabilityTypes = new List<SelectOption>();
	        referenceabilityTypes.add(new SelectOption('', '--None--'));
	        
	        for (Referenceability_Type__c refType : [SELECT Name, Id FROM Referenceability_Type__c WHERE Visible__c = true AND Request_type__c = true 
	        											AND Sales_Reward__c = false ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
	            referenceabilityTypes.add(new SelectOption(refType.Id, refType.Name));
	        }
	        
	        // Associated Contact Picklist
	        associatedContacts = new List<SelectOption>();
	        accounts = new List<SelectOption>();
	        contactMap = new Map<Id, Contact>();
			accountMap = new Map<Id, Account>();
			
	        // Populate Values from WHERE to Record Use Created
	        if (objId.substring(0, 3) == '001') {
	            fromAccount = true;
	            refReqAccountObject.Account__c = objId;
	            List<Account> tempList = [SELECT Id, Name, (SELECT Name, Contact__r.Name, Contact__c, Reference_Program_Candidate__c, Account__c, Is_Referenceable__c, 
	            								Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) FROM Account WHERE Id = :objId
	        									LIMIT :limits.getLimitQueryRows()];
	            
	            if (tempList.size() > 0) {
	                account = tempList[0];
	                
	                if (account.Reference_Basic_Informations__r.size() > 0) {
	                    accountReferenceability = account.Reference_Basic_Informations__r[0].Is_Referenceable__c;
	                }
	            }
	            Integer size = 1;
	            associatedContacts.add(new SelectOption('', '--None--'));
	            
	            for (Contact con : UtilityController.getAccountContacts(objId, cs)) {
	            	
	                if (size < 1000) {
	                	associatedContacts.add(new SelectOption(con.Id, con.Name));
	                }
	                size++;
	                contactMap.put(con.Id, con);
	            }
	        } else if (objId.substring(0, 3) == '003') {
	            fromContact = true;
	            
	            for (Contact con : [SELECT Id, AccountId, Name, Title, Email, Phone,
	            					(SELECT Name, Account__c, Contact__r.Name, Contact__c, Reference_Program_Candidate__c,
	            						Is_Referenceable__c, Referenceability_Status__c
	            						FROM Reference_Basic_Informations__r)
	        						FROM Contact WHERE Id = :objId LIMIT :limits.getLimitQueryRows()]) {
	                contactMap.put(con.Id, con);
	                objId = con.Id;
	            }
	            
	            if (contactMap != null && contactMap.containsKey(objId)) {
	            	
	                if (contactMap.get(objId).Reference_Basic_Informations__r.size() > 0) {
	                    contactReferenceability = contactMap.get(objId).Reference_Basic_Informations__r[0].Is_Referenceable__c;
	                }
	                List<String> accountsIds = new List<String>();
	                accountsIds.add(contactMap.get(objId).AccountId);
	                Map<String, Set<String>> contactAccountMap
	                			= UtilityController.getRelatedAccounts(new Set<String>{objId}, cs);
	                
		            if (contactAccountMap != null && contactAccountMap.size() > 0
		            			&& contactAccountMap.containsKey(objId) && contactAccountMap.get(objId).size() > 0) {
		            	accountsIds.addAll(contactAccountMap.get(objId));
	            	}
	            	Integer size = 0; 
		            // changes for #732/#768 - Rajesh (03 Feb, 2017)
	            	Map<Id, Account> tempAccountMap = new Map<Id, Account>(WithoutSharingHelperController.getRelatedAccountsRefContent(accountsIds));		
		            
		            for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN :accountsIds ORDER BY Name]) { 
						
						// to exclude generic account		
		        		if (tempAccountMap.get(acc.Id).Reference_Basic_Informations__r.size() == 0
	        					|| (tempAccountMap.get(acc.Id).Reference_Basic_Informations__r.size() > 0
	    							&& !tempAccountMap.get(acc.Id).Reference_Basic_Informations__r[0].Generic_Account__c)) {
		            		
		            		if (size < 1000) {
		            			accounts.add(new SelectOption(acc.Id, acc.Name));
		            		}
		            		size++;	            		 
		            		accountMap.put(acc.Id, tempAccountMap.get(acc.Id));
		            		
		            		if (account == null) {
		            			account = acc;	            			
		            			
			                    if (tempAccountMap.get(acc.Id).Reference_Basic_Informations__r.size() > 0) {
			                        accountReferenceability = tempAccountMap.get(acc.Id).Reference_Basic_Informations__r[0].Is_Referenceable__c;
			                    }
			                    refReqAccountObject.Account__c = account.Id;
		            		}
		            		
		            		if (contactMap.get(objId).AccountId == acc.Id) {
		            			refReqAccountObject.Account__c = acc.Id;
		            		}
	            		}
	            	} 
	            }
	            isContactSelected = true;
	            refReqAccContactObject.Contact__c = objId;
	            selectedContact = objId;
	        } else {
	            fromOpportunity = true;
	            refReqObject.Opportunity__c = objId;
	            List<Opportunity> tempOppList = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :objId LIMIT 1];
	            
	            if (tempOppList.size() > 0) {
	                opp = tempOppList[0];
	            }
	            refReqAccountObject.Account__c = opp.AccountId;
	            List<Account> tempList = [SELECT Id, Name, (SELECT Name, Account__c, Contact__r.Name, Contact__c, Reference_Program_Candidate__c, 
	            							Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null)
	    									FROM Account WHERE Id = : opp.AccountId LIMIT :limits.getLimitQueryRows()];
	            contactMap = new Map<Id, Contact>();
	            associatedContacts.add(new SelectOption('', '--None--'));
	            
	            if (tempList.size() > 0) {
	                account = tempList[0];
	                
	                for (Contact con : [SELECT Id, Name, Title, Email, Phone, AccountId, (SELECT Name, Account__c, Contact__r.Name, Contact__c, Reference_Program_Candidate__c, 
	                					Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r) FROM Contact
	            						WHERE AccountId = : opp.AccountId ORDER BY LastName LIMIT : limits.getLimitQueryRows()]) {
	                    associatedContacts.add(new SelectOption(con.Id, con.Name));
	                    contactMap.put(con.Id, con);
	                }
	                
	                if (account.Reference_Basic_Informations__r.size() > 0) {
	                    accountReferenceability = account.Reference_Basic_Informations__r[0].Is_Referenceable__c;
	                }
	            }
	        }
	        
	        if (associatedContacts.size() > 999 || accountMap.size() > 1000) {
	        	isLimitExceeded = true;
	        }
	        checkPermissions();
        }
    }
    
    /**
     * Method to save Record Reference Use Request 
     */
    public pageReference saveContent() {
    	
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	        	isError = false;
	            
	            // Check selected Contact Reference Program Candidate
	            if (refReqAccContactObject != null && refReqAccContactObject.Contact__c != null
	            			&& contactMap != null && contactMap.size() > 0) {
	            	
	                if (refReqAccContactObject.Feedback_Status__c == null || refReqAccContactObject.Feedback_Status__c == '') {
	                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.SELECT_FEEDBACK));
	                    isError = true;
	                    return null;
	                }
	                
	                if (refReqAccContactObject.Feedback_Status__c == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
	                	
	                    if (refReqAccContactObject.Feedback_Response__c == ''
	                    			|| refReqAccContactObject.Feedback_Response__c == null) {
	                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.reason_for_ref_use_unsuccess));
	                        isError = true;
	                        return null;
	                    }
	                }
	            }
	            createRefRequestAccount();
	        } catch (Exception e) {
	            refReqObject = new Reference_Request__c();
	            isError = true;
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	            Database.rollback(sp);
	        }
	        return null;
    	} else {
    		isError = true;
    		return null;
    	}
    }
    
    /**
     * Method to cancel
     */
    public PageReference cancel() {
    	
        if (isSaveNew) {
        	PageReference returnPage = new PageReference(Page.RecordAReferenceUse.getUrl() + '?Id=' + objId);
        	returnPage.setRedirect(true);
        	return returnPage;
        } else {
        	return new PageReference('/' + objId);
        }
    }
    
    private Boolean isSaveNew = false;
    
    /**
     * Method to save and new
     */
    public pageReference saveAndNew() {
    	
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	        	
	            // Check selected Contact Reference Program Candidate
	            if (refReqAccContactObject != null && refReqAccContactObject.Contact__c != null
	            			&& contactMap != null && contactMap.size() > 0) {
	                
	                if (refReqAccContactObject.Feedback_Status__c == null || refReqAccContactObject.Feedback_Status__c == '') {
	                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.SELECT_FEEDBACK));
	                    return null;
	                }
	                
	                if (refReqAccContactObject.Feedback_Status__c == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
	                	
	                    if (refReqAccContactObject.Feedback_Response__c == ''
	                    			|| refReqAccContactObject.Feedback_Response__c == null) {
	                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.reason_for_ref_use_unsuccess));
	                        return null;
	                    }
	                }
	            }
	            createRefRequestAccount();
	            String accId, conId, OppId;
	            accId = refReqAccountObject.Account__c;
	            OppId = refReqObject.Opportunity__c;
	            conId = refReqAccContactObject.Contact__c;
	            refReqObject = new Reference_Request__c();
	            refReqAccountObject = new Reference_Request_Account__c();
	            refReqAccContactObject = new Reference_Request_Account_Contact__c();
	            
	            if (objId.substring(0, 3) == '001') {
	                refReqAccountObject.Account__c = accId;
	            } else if (objId.substring(0, 3) == '003') {
	                refReqAccountObject.Account__c = accId;
	                refReqAccContactObject.Contact__c = conId;
	            } else {
	                refReqObject.Opportunity__c = OppId;
	                refReqAccountObject.Account__c = accId;
	            }
	            isSaveNew = true;
	            return null;
	        } catch (Exception e) {
	            refReqObject = new Reference_Request__c();
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	            Database.rollback(sp);
	            return null;
	        }
	        return null;
    	} else {
    		return null;
    	}
    }
    
    /**
     * method to create reference request account/contact (called from save and saveAndNew method)
     * author: Gaurav Saini (16 Feb, 2017)
     */
    public void createRefRequestAccount() {
    	
    	// Check RBI Records Created or not
        if (refReqAccContactObject != null && refReqAccContactObject.Contact__c != null) {
            UtilityController.checkRBI(refReqAccountObject.Account__c, refReqAccContactObject.Contact__c,
            							contactMap.get(refReqAccContactObject.Contact__c).AccountId, true);
        } else {
            UtilityController.checkRBI(refReqAccountObject.Account__c, null, null, true);
        }
        // Create RR Record
        refReqObject.Reference_Use__c = true;
        refReqObject.Reference_Request_Status__c = ConstantsController.COMPLETED;
        insert refReqObject;
        // Create RRA Record
        refReqAccountObject.Reference_Request__c = refReqObject.Id;
        refReqAccountObject.Reference_Use__c = true;
        refReqAccountObject.Account_Request_Status__c = ConstantsController.COMPLETED;
        refReqAccountObject.Process__c = ConstantsController.MANAGED;
        refReqAccountObject.Deadline__c = system.today();
        // changes for #901 - Gaurav Saini (30 June, 2017)
        WithoutSharingHelperController.insertRRA(new List<Reference_Request_Account__c>{refReqAccountObject});
        
        // Create RRAC Record
        if (refReqAccContactObject.Contact__c != null) {
            refReqAccContactObject.Reference_Request_Account__c = refReqAccountObject.Id;
            refReqAccContactObject.Activity_Date__c = refReqAccountObject.Activity_Date__c;
            refReqAccContactObject.Reference_Use__c = true;
            refReqAccContactObject.Deadline__c = system.today();
            refReqAccContactObject.Request_notes__c = refReqAccountObject.Request_Notes__c;
            refReqAccContactObject.Referenceability_Type__c = refReqAccountObject.Reference_Type_Needed__c;
            refReqAccContactObject.Contact_Request_Status__c = ConstantsController.COMPLETED;
            refReqAccContactObject.Is_Feedback_Received__c = true;
            refReqAccContactObject.Contact_Title__c = contactMap.get(refReqAccContactObject.Contact__c).Title;
            refReqAccContactObject.Contact_Phone__c = contactMap.get(refReqAccContactObject.Contact__c).Phone;
            refReqAccContactObject.Contact_Email__c = contactMap.get(refReqAccContactObject.Contact__c).Email;
            // changes for #901 - moved DML to w/o sharing
            WithoutSharingHelperController.upsertRRAC(refReqAccContactObject);
        }
        
        if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c ==  true) {        	
	       	List<String> lstUserAction = new List<String>();
        	lstUserAction.add(ConstantsController.REFERANCE_USE);
	        // Get Sales reward Referenceability  
	        List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);
	        
	        if (refType.size() > 0) { 
		        List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
		        rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
	        										Referenceability_Type__c = refType[0].Id,
	        										Transaction__c = ConstantsController.ISSUE, 
	                                                RewardDate__c = Date.Today(),
	                                                User__c = UserInfo.getUserId())); 
			  	
			  	if (rewardsToBeInsert.size() > 0) {
			  		UtilityController.isUserProfileExist(Userinfo.getUserId());
	    	        WithoutSharingHelperController.insertRewards(rewardsToBeInsert);  
			    }
			    
			    // re #591 NEW field Onscreen Notification allow for on/off for onscreen notification.
        		if (cs.User_Reward_Onscreen_Notification__c) {
				    rewardPoints = refType[0].Sales_Point__c;
			    	actionMessage = refType[0].Name;
        		}
	        }
       	}
    }
    
    /**
     * Method to check Reference status
     */
    public void getAccountReferenceStatus() {
    	
        if (selectedAccount != null
        			&& selectedAccount != ''
        			&& accountMap.get(selectedAccount) != null
        			&& accountMap.get(selectedAccount).Reference_Basic_Informations__r.size() > 0) {
            accountReferenceability
            			= accountMap.get(selectedAccount).Reference_Basic_Informations__r[0].Is_Referenceable__c;
        } 
    }
    
    /**
     * Method to check Reference status
     */
    public void getReferenceStatus() {
        
        if (selectedContact != null && selectedContact != '') {
        	
            if (contactMap.get(selectedContact) != null
            			&& contactMap.get(selectedContact).Reference_Basic_Informations__r.size() > 0) {
            	contactReferenceability
            				= contactMap.get(selectedContact).Reference_Basic_Informations__r[0].Is_Referenceable__c;
			} else {
            	contactReferenceability = false;
			}
            isContactSelected = true;
        } else {
            isContactSelected = false;
        }
    }
}