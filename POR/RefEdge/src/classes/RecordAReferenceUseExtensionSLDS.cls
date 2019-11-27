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
 * Page: RecordAReferenceUseSLDS
 * Description: this class is called FROM RecordAReferenceUseSLDS page to record any Account request reference
 * Created by: Rekha @31 August 2017
 */
public with sharing class RecordAReferenceUseExtensionSLDS extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String recordId { get; set; }
    // Populate activiteDate by default #1190 by Dixita
    public String dateString {
	    get {
	            return String.valueOf(Date.today());
	    }
        set;
    }
    /**
     * Constructor
     */
    public RecordAReferenceUseExtensionSLDS() {
    	recordId = ApexPages.currentPage().getParameters().get('Id');
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
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String objId) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	try {
    		Custom_Settings__c cs = UtilityController.getCustomSettings();
    		infoWp.status = ConstantsController.REFERENCE_STATUS_MSG.replace('@@@3', cs.Default_Referenceablity_Status__c);
        	infoWp.status = infoWp.status.replace('@@@2', System.Label.Record_a_Reference);
        	Schema.DescribeFieldResult fieldResult = Reference_Request_Account_Contact__c.Feedback_Status__c.getDescribe();
	        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
	        
	        for (Schema.PicklistEntry f : ple) {
	        		
	            if (f.getValue() == ConstantsController.FEEDBACK_SUCCESSFUL
	            			|| f.getValue() == ConstantsController.FEEDBACK_UNSUCCESSFUL) {
	                infoWp.feedbackOptions.add(new OptionWrapper(f.getValue(), f.getLabel()));
	            }
	        }
	        
	        for (Referenceability_Type__c refType : [SELECT Name, Id FROM Referenceability_Type__c WHERE Request_type__c = true AND Visible__c = true AND Sales_Reward__c = false
	        											ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
	            infoWp.refTypes.add(new OptionWrapper(refType.Id, refType.Name));
	        }
	        //infoWp.selectedContact = new ContactWrapper('', '--No', false, '', '', '', '');
	        
	        // Populate Values from WHERE to Record Use Created
	        if (objId.substring(0, 3) == '001') {
	        	List<Account> tempList = [SELECT Id, Name, (SELECT Name, Contact__r.Name, Contact__c, Reference_Program_Candidate__c, 
	        												Account__c, Is_Referenceable__c, Referenceability_Status__c 
	        												FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
												FROM Account WHERE Id = :objId
	        									LIMIT :limits.getLimitQueryRows()];
	            
	            if (tempList.size() > 0) {
	                infoWp.selectedAccount = new OptionWrapper(tempList[0].Id, tempList[0].Name, 
	                				(tempList[0].Reference_Basic_Informations__r.size() > 0 ? 
	                				tempList[0].Reference_Basic_Informations__r[0].Is_Referenceable__c : false));
	            }
	            infoWp.contacts.add(new ContactWrapper('', '--None--', false, '', '', '', ''));
	            
	            for (Contact con : UtilityController.getAccountContacts(objId, cs)) {
					infoWp.contacts.add(new ContactWrapper(con.Id, con.Name, (con.Reference_Basic_Informations__r.size() > 0 ? 
													con.Reference_Basic_Informations__r[0].Is_Referenceable__c : false), 
													con.AccountId, con.Title, con.Email, con.Phone));
					
	            }
	        } else if (objId.substring(0, 3) == '003') {
	        	List<String> accountsIds = new List<String>();
	        	infoWp.fromContact = true;
	        	
	        	List<Contact> tempList = [SELECT Id, AccountId, Name, Title, Email, Phone,
			            					(SELECT Name, Account__c, Contact__r.Name, Contact__c, Reference_Program_Candidate__c,
			            						Is_Referenceable__c, Referenceability_Status__c
			            						FROM Reference_Basic_Informations__r)
			        						FROM Contact WHERE Id = :objId LIMIT :limits.getLimitQueryRows()];
	        									
	        	if (tempList.size() > 0) {
	                accountsIds.add(tempList[0].AccountId);
	                infoWp.selectedContact = new ContactWrapper(tempList[0].Id, tempList[0].Name, (tempList[0].Reference_Basic_Informations__r.size() > 0 ? 
													tempList[0].Reference_Basic_Informations__r[0].Is_Referenceable__c : false), 
													tempList[0].AccountId, tempList[0].Title, tempList[0].Email, tempList[0].Phone);
	            	Map<String, Set<String>> contactAccountMap
                			= UtilityController.getRelatedAccounts(new Set<String>{tempList[0].Id}, cs);
                	
                	if (contactAccountMap != null && contactAccountMap.size() > 0
		            			&& contactAccountMap.containsKey(tempList[0].Id) && contactAccountMap.get(tempList[0].Id).size() > 0) {
		            	accountsIds.addAll(contactAccountMap.get(tempList[0].Id));
	            	}
	            	
	            	Map<Id, Reference_Basic_Information__c> tempAccountMap = 
	            						new Map<Id, Reference_Basic_Information__c>(WithoutSharingHelperController.getAccountsReferenceProfiles(accountsIds));
	            	
	            	for (Account acc : [SELECT Id, Name FROM Account WHERE Id IN : accountsIds ORDER BY Name]) { 
						
						// to exclude generic account		
		        		if (tempAccountMap != null && (!tempAccountMap.containsKey(acc.Id) 
		        									|| (tempAccountMap.containsKey(acc.Id) && !tempAccountMap.get(acc.Id).Generic_Account__c))) {
		            		
		            		if (acc.Id == tempList[0].AccountId) {
		            			infoWp.selectedAccount = new OptionWrapper(acc.Id, acc.Name, 
	                				(tempAccountMap.containsKey(acc.Id) ? tempAccountMap.get(acc.Id).Is_Referenceable__c : false));
		            		}
		            		infoWp.accounts.add(new OptionWrapper(acc.Id, acc.Name, 
	                				(tempAccountMap.containsKey(acc.Id) ? tempAccountMap.get(acc.Id).Is_Referenceable__c : false)));
	            		}
	            	} 
	            }
	        } else {
	            List<Opportunity> tempOppList = [SELECT Id, Name, AccountId FROM Opportunity WHERE Id = :objId LIMIT 1];
	            
	            if (tempOppList.size() > 0) {
	                Opportunity opp = tempOppList[0];
	                infoWp.selectedOppName = opp.Name;
	                infoWp.selectedOppId = opp.Id;
	                List<Account> tempList = [SELECT Id, Name, (SELECT Name, Account__c,
	            							Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null)
	    									FROM Account WHERE Id = : opp.AccountId LIMIT :limits.getLimitQueryRows()];
		            
		            if (tempList.size() > 0) {
		                infoWp.selectedAccount = new OptionWrapper(tempList[0].Id, tempList[0].Name, 
	                				(tempList[0].Reference_Basic_Informations__r.size() > 0 ? 
	                				tempList[0].Reference_Basic_Informations__r[0].Is_Referenceable__c : false));
		                infoWp.contacts.add(new ContactWrapper('', '--None--', false, '', '', '', ''));
													
		                for (Contact con : [SELECT Id, Name, Title, Email, Phone, (SELECT Name, Account__c, Contact__r.Name, Contact__c,  
		                					Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r) FROM Contact
		            						WHERE AccountId = :opp.AccountId ORDER BY LastName LIMIT :limits.getLimitQueryRows()]) {
		                    infoWp.contacts.add(new ContactWrapper(con.Id, con.Name, (con.Reference_Basic_Informations__r.size() > 0 ? 
													con.Reference_Basic_Informations__r[0].Is_Referenceable__c : false), 
													opp.AccountId, con.Title, con.Email, con.Phone));
		                }
		            }
	            }
	        }
    	} catch(Exception e) {
    		infoWp.error = e.getMessage();
    	}
    	return infoWp;
    }
    /**
     * RemoteAction to submit the nomination
     */
    @RemoteAction
    public static String submit(String infoJson) {
    	Savepoint sp = Database.setSavepoint();
        
        try {
        	InfoWrapper info = (InfoWrapper)JSON.deserialize(infoJson, InfoWrapper.class);
        	Custom_Settings__c cs = UtilityController.getCustomSettings();
        	
        	if (checkPermissions(info.selectedContact != null && info.selectedContact.id != null && info.contacts.size() == 0)) {
        		
        		// Check RBI Records Created or not
		        if (info.selectedContact != null && info.selectedContact.id != null) {
		            UtilityController.checkRBI(info.selectedAccount.id, info.selectedContact.id,
		            							info.selectedContact.contactAccountId, true);
		        } else {
		            UtilityController.checkRBI(info.selectedAccount.id, null, null, true);
		        }
		        // Create RR Record
        		Reference_Request__c refReqObject = new Reference_Request__c(Opportunity__c = info.selectedOppId, Reference_Use__c = true, 
        														Reference_Request_Status__c = ConstantsController.COMPLETED);
	            insert refReqObject;
	            // Create RRA Record
	            Reference_Request_Account__c refReqAccountObject = new Reference_Request_Account__c(Account__c = info.selectedAccount.id, 
	            												Reference_Request__c = refReqObject.Id, Reference_Use__c = true,
	            												Account_Request_Status__c = ConstantsController.COMPLETED,
	            												Reference_Type_Needed__c = info.selectedRefType,
	            												Activity_Date__c = info.activityDate,
	            												Request_Notes__c = info.notes,
	            												Process__c = ConstantsController.MANAGED, Deadline__c = system.today());
	            WithoutSharingHelperController.insertRRA(new List<Reference_Request_Account__c>{refReqAccountObject});
	            
		        // Create RRAC Record
		        if (info.selectedContact != null && info.selectedContact.id != null) {
		        	Reference_Request_Account_Contact__c refReqAccContactObject = new Reference_Request_Account_Contact__c(
		        											Contact__c = info.selectedContact.id,
		        											Reference_Request_Account__c = refReqAccountObject.Id, 
		        											Activity_Date__c = info.activityDate,
		        											Reference_Use__c = true, Deadline__c = system.today(),
		        											Request_notes__c = info.notes,
		        											Referenceability_Type__c = info.selectedRefType,
		        											Contact_Request_Status__c = ConstantsController.COMPLETED,
		        											Is_Feedback_Received__c = true, Contact_Title__c = info.selectedContact.title,
		        											Contact_Phone__c = info.selectedContact.phone, 
		        											Contact_Email__c = info.selectedContact.email,
		        											Feedback_Status__c = info.useFeedback, Feedback_Response__c = info.feedbackReason);
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
					    
		        		if (cs.User_Reward_Onscreen_Notification__c) {
		        			return 'success:' + refType[0].Sales_Point__c + ':' + refType[0].Name;
		        		}
			        }
		       	}
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        	return '';
        } catch(Exception e) {
        	Database.rollback(sp);
        	return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    /**
     * Wrapper class for request and Account request information
     */
 	public class InfoWrapper {
 		public OptionWrapper selectedAccount { get; set; }
 		public ContactWrapper selectedContact { get; set; }
 		public String selectedRefType { get; set; }
 		public String selectedOppId { get; set; }
 		public String selectedOppName { get; set; }
 		public Boolean isLimitExceeded { get; set; }
 		public List<OptionWrapper> accounts { get; set; }
 		public List<ContactWrapper> contacts { get; set; }
 		public List<OptionWrapper> refTypes { get; set; }
 		public List<OptionWrapper> feedbackOptions { get; set; }
 		public String notes { get; set; }
 		public String error { get; set; }
 		public Date activityDate { get; set; }
 		public String useFeedback { get; set; }
 		public String feedbackReason { get; set; }
 		public Boolean showContactPicklist { get; set; }
 		public String status { get; set; }
 		public Boolean fromContact { get; set; }
	    
	    public InfoWrapper() {
            selectedRefType = '';
            notes = '';
            error = '';
            useFeedback = '';
            feedbackReason = '';
            fromContact = false;
            accounts = new List<OptionWrapper>();
            contacts = new List<ContactWrapper>();
            refTypes = new List<OptionWrapper>();
	    		feedbackOptions = new List<OptionWrapper>();
            isLimitExceeded = false;
            showContactPicklist = Schema.sObjectType.Reference_Request_Account_Contact__c.fields.Contact__c.isCreateable();
	    }
 	}
 	
 	/**
     * Wrapper Class
     */
 	public class OptionWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		public Boolean isReferenceable { get; set; }
 		
 		public OptionWrapper(String id, String name) {
 			this.id = id;
 			this.name = name;
 		}
 		
 		public OptionWrapper(String id, String name, Boolean isReferenceable) {
 			this.id = id;
 			this.name = name;
 			this.isReferenceable = isReferenceable;
 		}
 	}
 	
 	/**
     * Wrapper Class
     */
 	public class ContactWrapper {
 		public String id { get; set; }
 		public String name { get; set; }
 		public Boolean isReferenceable { get; set; }
 		public String contactAccountId { get; set; }
 		public String title { get; set; }
 		public String email { get; set; }
 		public String phone { get; set; }
 		
 		public ContactWrapper(String id, String name, Boolean isReferenceable, String contactAccountId, String title, String email, String phone) {
 			this.id = id;
 			this.name = name;
 			this.isReferenceable = isReferenceable;
 			this.contactAccountId = contactAccountId;
 			this.title = title;
 			this.email = email;
 			this.phone = phone;
 		}
 	}
 	
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(Boolean fromContact) {
		checkPermissions(fromContact);
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean fromContact) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request__c',
    										new Set<String>{UtilityController.appNamespace() + 'Reference_Use__c',
        										UtilityController.appNamespace() + 'Reference_Request_Status__c'});

        if (fromContact) {
	        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Account_Contact__c',
	    										new Set<String>{UtilityController.appNamespace() + 'Contact__c'});
        }
        Boolean isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        return isInsertPermission;
    }
}