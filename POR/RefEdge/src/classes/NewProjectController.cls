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
 * VF Page: NewProject.page
 * Description: controller for creating a new project from the ref workspace
 * Last modified by: Gaurav Saini (13 June, 2017) for #732
 */
public with sharing class NewProjectController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Reference_Request__c refReqObject { get; set; }
    public Reference_Request_Account__c refReqAccountObject { get; set; }
    public Reference_Request_Account_Contact__c refReqAccContactObject { get; set; }
    public Nomination__c tempRef { get; set; }
    public String accName { get; set; }
    public List<SelectOption> referenceabilityTypes { get; set; }
    public List<SelectOption> associatedContacts { get; set; }
    public String status { get; set; }
    public Boolean accountReferenceability { get; set; }
    public Boolean contactReferenceability { get; set; }
    public Boolean accCandidate { get; set; }
    public String selectedAccount { get; set; }
    public String selectedContact { get; set; }
    public Boolean isContactSelected { get; set; }
    public Boolean isAccountSelected { get; set; }
    private Map<Id, Contact> contactMap;
    private Reference_Basic_Information__c account;
    private Custom_Settings__c cs;
    private List<sObject> postFeedItems = new List<sObject>();
    public List<SelectOption> options { get; set; }
    public String projectType { get; set; }
    public String previousRecordName { get; set; }
    public Boolean isLimitExceeded { get; set; }
    //re #922
    public Boolean accountRequired { get; set; }
    public Boolean oppRequired { get; set; }
    public Boolean contactRequired { get; set; }
    public Boolean caseRequired { get; set; }
    public Boolean noteRequired { get; set; }
    public Boolean subjectRequired { get; set; }
    
    /**
     * Constructor
     */
    public NewProjectController() {
    	checkPermissions();
        accountReferenceability = false;
        contactReferenceability = false;
        isContactSelected = false;
        isAccountSelected = false;
        accCandidate = false;
        projectType = 'Member';
        previousRecordName = '';
        isLimitExceeded = false;
        options = new List<SelectOption>();
        options.add(new SelectOption('Member', 'Member'));
        options.add(new SelectOption('Candidate', 'Candidate'));
        cs = UtilityController.getCustomSettings();
        //re #922
        accountRequired = cs.Project_Account_Required__c;
        contactRequired = cs.Project_Contact_Required__c;
        oppRequired = cs.Project_Opportunity_Required__c;
        caseRequired = cs.Project_Case_Required__c;
        noteRequired = cs.Project_Notes_Required__c;
        subjectRequired = cs.Project_Subject_Required__c;
        
        status = ConstantsController.REFERENCE_STATUS_MSG.replace('@@@3', cs.Default_Referenceablity_Status__c);
        status = status.replace('@@@2', System.Label.this_Request);
        refReqObject = new Reference_Request__c();
        refReqAccountObject = new Reference_Request_Account__c();
        refReqAccContactObject = new Reference_Request_Account_Contact__c();
        // reference use to show account field without require  
        tempRef = new Nomination__c();
        // Referenceability Picklist
        referenceabilityTypes = new List<SelectOption>();
        referenceabilityTypes.add(new SelectOption('', '--None--'));
        
        for (Referenceability_Type__c refType : [SELECT Name, Id FROM Referenceability_Type__c
        											WHERE Visible__c = true AND Project_type__c = true
        											AND Sales_Reward__c = false
        											ORDER BY Name
        											LIMIT :limits.getLimitQueryRows()]) {
            referenceabilityTypes.add(new SelectOption(refType.Id, refType.Name));
        }
        associatedContacts = new List<SelectOption>();
        associatedContacts.add(new SelectOption('', '--None--'));
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request__c',
    										new Set<String>{UtilityController.appNamespace() + 'Project_Type__c',
        										UtilityController.appNamespace() + 'Case__c',
        										UtilityController.appNamespace() + 'Opportunity__c',
        										UtilityController.appNamespace() + 'Reference_Request_Status__c',
        										UtilityController.appNamespace() + 'Requester__c'});
        fieldMap.put(UtilityController.appNamespace() + 'Unspecified_Request__c',
    										new Set<String>{UtilityController.appNamespace() + 'Deadline__c',
        										UtilityController.appNamespace() + 'Unspecified_Request_Status__c',
        										UtilityController.appNamespace() + 'Reference_Type_Needed__c',
        										UtilityController.appNamespace() + 'Requester__c',
        										UtilityController.appNamespace() + 'Request_Notes__c',
        										UtilityController.appNamespace() + 'Reference_Request__c'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        return isUpsertPermission;
    }
    
    /**
     * Method to set blank Account and Contacts
     */
    public pageReference setBlankAccountContact() {
        associatedContacts.clear();
        associatedContacts.add(new SelectOption('', '--None--'));
        tempRef.Account__c = null;
        accName = '';
        isAccountSelected = false;
        return null;
    }
    
	/**
     * Method to set AccountId
     */
    public pageReference setAccountID() {
        associatedContacts.clear();
        associatedContacts.add(new SelectOption('', '--None--'));
        String tempId = tempRef.Account__c;
        
        if ((tempId != null && tempId != '') || (accName != null && accName != '')) {
            String accId = getAccount();
            
            if (accId != null && accId != '') {
	            contactMap = new Map<Id, Contact>();
	            
	            // Changes for #366 - getting all contacts (direct + shared) for an account
	            //						and storing in the map
	            for (Contact con : WithoutSharingHelperController.getAccountContacts(accId, cs)) {
	            	
	            	contactMap.put(con.Id, con);
	            }
	            
	            if (contactMap != null && contactMap.size() > 0) {
	                List<Contact> contactList = contactMap.values();
	                contactList.sort();
	                Integer size = 1;
			        
			        for (Contact con : contactList) {
			        	
			        	if (size < 1000) {
			            	if(con.Reference_Basic_Informations__r.size() == 0 
			        			|| (projectType == 'Member' && con.Reference_Basic_Informations__r[0].Is_Referenceable__c)
			        			|| (projectType == 'Candidate' && con.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
			        			associatedContacts.add(new SelectOption(con.Id, con.Name));
			        		}
			        	}
			            size++;
			        }
			        
			        if (contactList.size() > 999) {
        				isLimitExceeded = true;
			        } else {
    					isLimitExceeded = false;
    				}
	            }
	        }
        } else {
            isAccountSelected = false;
        }
        return null;
    }
    
    /**
     * Method to get Account
     */
    private String getAccount() {
    	String accId = '';
        String tempId = tempRef.Account__c;
        List<Reference_Basic_Information__c> rbiList = new List<Reference_Basic_Information__c>();
        
        if (tempId != null && tempId != '') {
            String soqlQuery = 'SELECT Account__r.Name, Account__r.OwnerId, Name, Id, Account__c, Reference_Owner__c, '
            					+ 'Managed_Reference_Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, '
            					+ 'Referenceability_Status__c '
            					+ 'FROM Reference_Basic_Information__c '
            					+ 'WHERE Contact__c = null '
            					+ 'AND Account__c = \'' + tempRef.Account__c
            					+ '\' LIMIT 10';
            rbiList = WithoutSharingHelperController.getRBI(soqlQuery);
        } else {
            String searchValue = String.escapeSingleQuotes(accName);
            searchValue = '\'' + searchValue + '\'';
	        String soqlQuery = '';
	        
	        if (projectType == 'Member') {
	        	soqlQuery = 'SELECT Account__r.Name, Account__r.OwnerId, Name, Id, Account__c, Reference_Owner__c, '
	        					+ 'Managed_Reference_Account__c, Reference_Program_Candidate__c, '
	        					+ 'Is_Referenceable__c, Referenceability_Status__c '
	        					+ 'FROM Reference_Basic_Information__c '
	        					+ 'WHERE Contact__c = null '
	        					+ 'AND Account__r.Name = ' + searchValue
	        					+ ' AND Is_Referenceable__c = true '
	        					+ 'AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE + '\' '
	        						+ 'AND Referenceability_Status__c != \'\') LIMIT 10';
            } else if (projectType == 'Candidate') {
            	soqlQuery = 'SELECT Account__r.Name, Account__r.OwnerId, Name, Id, Account__c, Reference_Owner__c, '
            					+ 'Managed_Reference_Account__c, Reference_Program_Candidate__c, '
            					+ 'Is_Referenceable__c, Referenceability_Status__c '
            					+ 'FROM Reference_Basic_Information__c '
            					+ 'WHERE Contact__c = null '
            					+ 'AND Account__r.Name = ' + searchValue
            					+ ' AND Reference_Program_Candidate__c = true LIMIT 10';
            }
            rbiList = WithoutSharingHelperController.getRBI(soqlQuery);
            
            if (rbiList.size() > 1) {
            	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
                return null;
            } else if (rbiList.size() == 0) {
	            searchValue = accName.replace('*', '%') + '%';
		        searchValue = String.escapeSingleQuotes(searchValue);
		        searchValue = '\'' + searchValue + '\'';
		        soqlQuery = '';
		        
		        if (projectType == 'Member') {
		        	soqlQuery = 'SELECT Account__r.Name, Account__r.OwnerId, Name, Id, Account__c, Reference_Owner__c,'
		        					+ 'Managed_Reference_Account__c, Reference_Program_Candidate__c, '
		        					+ 'Is_Referenceable__c, Referenceability_Status__c '
		        					+ 'FROM Reference_Basic_Information__c '
		        					+ 'WHERE Contact__c = null '
		        					+ 'AND Account__r.Name LIKE ' + searchValue
		        					+ ' AND Is_Referenceable__c = true '
		        					+ 'AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE + '\' '
		        						+ 'AND Referenceability_Status__c != \'\') LIMIT 10';
	            } else if (projectType == 'Candidate') {
	            	soqlQuery = 'SELECT Account__r.Name, Account__r.OwnerId, Name, Id, Account__c, Reference_Owner__c, '
	            					+ 'Managed_Reference_Account__c, Reference_Program_Candidate__c, '
	            					+ 'Is_Referenceable__c, Referenceability_Status__c '
	            					+ 'FROM Reference_Basic_Information__c '
	            					+ 'WHERE Contact__c = null '
	            					+ 'AND Account__r.Name LIKE ' + searchValue
	            					+ ' AND Reference_Program_Candidate__c = true LIMIT 10';
	            }
	            rbiList = WithoutSharingHelperController.getRBI(soqlQuery);
            }
        }
        
        if (rbiList.size() > 1) {
        	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
            return null;
        } else if (rbiList.size() == 0) {
            ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Account_No_matches_found));
            return null;
        } else {
            account = rbiList[0];
            accId = account.Account__c;
            isAccountSelected = true;
            accName = account.Account__r.Name;
            accCandidate = account.Reference_Program_Candidate__c;
            accountReferenceability = account.Is_Referenceable__c;
        }
	    return accId;
    }
    
    /**
     * Method to save Request
     */
    public pageReference saveContent() {
        
        if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        decimal salesReward = 0;
	        
	        try {
	        	/*
	            if (refReqAccountObject.Reference_Type_Needed__c == null) {
	                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.SELECT_REFERENCEABILITY));
	                return null;
	            }
	            
	            if (refReqAccountObject.Deadline__c == null) {
	                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.SELECT_DEADLINE_DATE));
	                return null;
	            }*/

	            //re #922
	            if (refReqAccountObject.Reference_Type_Needed__c == null || refReqAccountObject.Deadline__c == null || 
	            			(refReqObject.Opportunity__c == null && oppRequired && projectType == 'Member') || 
	            			(refReqObject.Case__c == null && caseRequired && projectType == 'Member') || 
	            			(refReqObject.Title__c == null && subjectRequired) || 
	            			(refReqAccountObject.Request_Notes__c == null && noteRequired) || 
	            			//re #945
	            			(((tempRef.Account__c == null) && (accName == null || accName == '')) && accountRequired) || 
	            			(refReqAccContactObject.Contact__c == null && contactRequired)) {
	                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Complete_the_required_fields));
	                
		            if (refReqObject.Title__c == null && subjectRequired) {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request__c.fields.Title__c.label));
		            }
		            
	                if (refReqAccountObject.Reference_Type_Needed__c == null) {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request_Account__c.fields.Reference_Type_Needed__c.label));
		            }
		            
		            if (refReqObject.Opportunity__c == null && oppRequired && projectType == 'Member') {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request__c.fields.Opportunity__c.label));
		            }
		            
		            if (refReqObject.Case__c == null && caseRequired && projectType == 'Member') {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request__c.fields.Case__c.label));
		            }
		            
		            //re #945 
		            if (String.isBlank(tempRef.Account__c) && String.isBlank(accName) && accountRequired) {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request_Account__c.fields.Account__c.label));
		            }
		            
		            if (refReqAccContactObject.Contact__c == null && contactRequired) {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request_Account_Contact__c.fields.Contact__c.label));
		            }
		            
		            if (refReqAccountObject.Request_Notes__c == null && noteRequired) {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request_Account__c.fields.Request_Notes__c.label));
		            }
		            
		            if (refReqAccountObject.Deadline__c == null) {
		                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Schema.SobjectType.Reference_Request_Account__c.fields.Deadline__c.label));
		            }
	                return null;
	            }
	            
	            String tempId = tempRef.Account__c;
	            
	            if ((tempId != null && tempId != '') || (accName != null && accName != '')) {
	            	String accId = getAccount();
	            	
	            	if (accId == null) {
	            		return null;
	            	} else {
	            		tempRef.Account__c = accId;
	            	}
	            }
	            
	            // Check selected Contact Reference Program Candidate
	            if (refReqAccContactObject != null && refReqAccContactObject.Contact__c != null
	            			&& contactMap != null && contactMap.size() > 0 && !accCandidate) {
	            	
	                if (contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r.size() > 0
	                			&& contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r[0].Reference_Program_Candidate__c) {
	                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, ConstantsController.CANDIDATE_CHECKED_CONTACT));
	                    return null;
	                }
	            }
	            
	            if (refReqAccContactObject != null && refReqAccContactObject.Contact__c != null
	            			&& contactMap != null && contactMap.size() > 0 && accCandidate) {
	            	
	                if ((contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r.size() > 0
	                				&& !contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
	                    Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.CANDIDATE_NOT_CHECKED_CONTACT));
	                    return null;
	                }
	            }
	            
	            // Create RR Record
	            if (projectType == 'Candidate') {
	                refReqObject.Opportunity__c = null;
	                refReqObject.Case__c = null;
	            }
	            refReqObject.Reference_Request_Status__c = ConstantsController.IN_PROGRESS;
	            refReqObject.Requester__c = UserInfo.getUserId();
	            
	            if (projectType == 'Member') {
	                refReqObject.Project_Type__c = 'Member';
	            } else {
	                refReqObject.Project_Type__c = 'Candidate';
	            }
	            insert refReqObject;
	            tempId = tempRef.Account__c;
	            
	            // Create RRA Record
	            if (tempId != null && tempId.trim() != '') {
	            	
	                if (!accCandidate) {
	                	
	                    // Check RBI Records Created or not
	                    if (refReqAccContactObject != null && refReqAccContactObject.Contact__c != null) {
	                    	
	                        if (account != null || (contactMap != null && contactMap.size() > 0
	                        			&& contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r.size() <= 0)) {
	                            UtilityController.checkRBI(tempRef.Account__c, refReqAccContactObject.Contact__c, 
	                            							contactMap.get(refReqAccContactObject.Contact__c).AccountId, true);
	                        } else if (contactMap != null && contactMap.size() > 0
	                        			&& contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r.size() > 0
	                        			&& contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r[0].Is_Referenceable__c == false) {
	                            Reference_Basic_Information__c rbi
	                            		= contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r[0];
	                            rbi.Is_Referenceable__c = true;
	                            rbi.Referenceability_Status__c = cs.Default_Referenceablity_Status__c;
	                            WithoutSharingHelperController.upsertRBI(new List<Reference_Basic_Information__c> {rbi});
	                        }
	                    }
	                } else {
	                	if(contactMap != null && contactMap.size() > 0 
	                		&& contactMap.get(refReqAccContactObject.Contact__c).Reference_Basic_Informations__r.size() <= 0) {
	                		
	                		Reference_Basic_Information__c rbi = new Reference_Basic_Information__c();
	                		rbi.Contact__c = refReqAccContactObject.Contact__c;
	                		rbi.Account__c = contactMap.get(refReqAccContactObject.Contact__c).AccountId;
	                		rbi.Reference_Program_Candidate__c = true;
	                		WithoutSharingHelperController.upsertRBI(new List<Reference_Basic_Information__c> {rbi});
	                	}
	                }
	                refReqAccountObject.Account__c = tempRef.Account__c;
	                refReqAccountObject.Reference_Request__c = refReqObject.Id;
	                refReqAccountObject.Deadline__c = refReqAccountObject.Deadline__c;
	                refReqAccountObject.Requester__c = UserInfo.getUserId();
	                refReqAccountObject.Project_Owner__c = UserInfo.getUserId();
	                
	                if (account.Reference_Owner__c != null) {
	                    refReqAccountObject.Reference_Owner__c = account.Reference_Owner__c;
	                } else {
	                    refReqAccountObject.Reference_Owner__c = account.Managed_Reference_Account__c
	                    											? null : account.Account__r.OwnerId;
	                }
	                refReqAccountObject.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
	                refReqAccountObject.Managed_Request__c = true;
	                refReqAccountObject.Process__c = ConstantsController.MANAGED;
	                WithoutSharingHelperController.upsertRRA(refReqAccountObject);
	                
	                // Create RRAC Record
	                if (refReqAccContactObject != null && refReqAccContactObject.Contact__c != null) {
	                    refReqAccContactObject.Reference_Request_Account__c = refReqAccountObject.Id;
	                    refReqAccContactObject.Referenceability_Type__c = refReqAccountObject.Reference_Type_Needed__c;
	                    refReqAccContactObject.Deadline__c = refReqAccountObject.Deadline__c;
	                    refReqAccContactObject.Request_notes__c = refReqAccountObject.Request_Notes__c;
	                    refReqAccContactObject.Contact_Request_Status__c = ConstantsController.IN_PROGRESS;
	                    refReqAccContactObject.Project_Owner__c = UserInfo.getUserId();
	                    WithoutSharingHelperController.upsertRRAC(refReqAccContactObject);
	                }
	            } else {
	                Unspecified_Request__c unspec
	            			= new Unspecified_Request__c(Reference_Type_Needed__c = refReqAccountObject.Reference_Type_Needed__c,
										                    Deadline__c = refReqAccountObject.Deadline__c,
										                    Reference_Request__c = refReqObject.Id,
										                    Requester__c = UserInfo.getUserId(),
										                    Project_Owner__c = UserInfo.getUserId(),
										                    Request_Notes__c = refReqAccountObject.Request_Notes__c,
										                    Unspecified_Request_Status__c = ConstantsController.NOT_STARTED);
	                insert unspec;
	            }
	            String parameters = '?Id=' + refReqObject.Id; 
	            PageReference ReturnPage = new PageReference(Page.RefRequestProject.geturl() + parameters);
	            ReturnPage.setRedirect(true);
	            return ReturnPage;
	        } catch (Exception e) {
	            refReqObject = new Reference_Request__c();
	            Database.rollback(sp);
	            return null;
	        }
        } else {
        	return null;
        }
    }
    
    /**
     * Method to cancel the request
     */
    public PageReference cancel() {
        return page.ReferenceWorkSpace;
    }
    
    /**
     * Method to check reference status
     */
    public void getReferenceStatus() {
    	
        if (selectedContact != null && selectedContact != '' && contactMap != null
        			&& contactMap.get(selectedContact) != null
        			&& contactMap.get(selectedContact).Reference_Basic_Informations__r.size() > 0) {
            contactReferenceability
            		= contactMap.get(selectedContact).Reference_Basic_Informations__r[0].Is_Referenceable__c;
            isContactSelected = true;
        } else {
            isContactSelected = false;
        }
    }
}