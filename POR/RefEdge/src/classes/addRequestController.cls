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
 * Page: addRequest
 * Description : Class used to create Account/Unspecified request
 * Modified by: Rekha @Feb 8 2017
 */
public with sharing class addRequestController extends RefEdgeEditionFeatures {
    /**
     * Properties AND variables
     */
    public Reference_Request__c refRequest { get; set; }
    public Account selAccount { get; set; }
    public Reference_Request_Account__c rrA { get; set; }
    public String selRefType { get; set; }
    public Boolean isMessageRender { get; set; }
    public List<SelectOption> referenceabilityTypes { get; set; }
    public String accName { get; set; }
    public Boolean isCandidateRequest { get; set; }
    public List<Account> accountList { get; set; }
    public Boolean isAccountShow { get; set; }
    public String searchText { get; set; }
    public Boolean isNameChanged { get; set; }
    private List<sObject> postFeedItems = new List<sObject>();
    private Map<Id, Id> refTypeAddInfoMap { get; set; }
    
    /**
     * Constructor
     */
    public addRequestController() {
        accName = '';
        isNameChanged = false;
        refRequest = [SELECT Id, Name, Requester__c,
                        (SELECT Id, Reference_Type_Needed__c, Reference_Request_Additional_Info__c FROM Reference_Request_Accounts__r),
                        (SELECT Id, Reference_Type_Needed__c, Reference_Request_Additional_Info__c FROM Unspecified_Requests__r)
                        FROM Reference_Request__c WHERE Id = :ApexPages.currentPage().getParameters().get('id') LIMIT 1];
        isCandidateRequest = false;
        
        if (ApexPages.currentPage().getParameters().get('candidateproject') == 'true') {
            isCandidateRequest = true;
        }
        rrA = new Reference_Request_Account__c();
        referenceabilityTypes = new List<SelectOption>();
        referenceabilityTypes.add(new SelectOption('', '--None--'));
        
        for (Referenceability_Type__c refType : [SELECT Name, Id FROM Referenceability_Type__c WHERE Visible__c = true 
        											AND (Request_type__c = true OR Project_type__c = true)
        											AND Sales_Reward__c = false ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            referenceabilityTypes.add(new SelectOption(refType.Id, refType.Name));
        }
        isAccountShow = false;
        checkPermissions();
        // added for REF-1542 - Gaurav Saini (31 Aug, 2018)
        refTypeAddInfoMap = new Map<Id, Id>();
    }

    /**
     * Method to Save Request
     */
    public void saveRequest() {
    	
    	if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	            isMessageRender = false;
	            Reference_Basic_Information__c rbiAccount;
	            List<Reference_Basic_Information__c> rbiList;
	            
	            if (selRefType == null || rrA.Deadline__c == null) {
	                isMessageRender = true;
	                ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.INFO, System.Label.Edit_popup_all_fields_must_filled));
	            }
	            
	            if (isNameChanged && accName.trim().length() > 0) {
	                String searchValue = String.escapeSingleQuotes(accName);
	                searchValue = '\'' + searchValue + '\'';
	                String soqlQuery = '';
	                
		            if (isCandidateRequest) {
		                soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c ' 
		                				+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.Name = ' + searchValue 
		                				+ ' AND Reference_Program_Candidate__c = true LIMIT 10';
		            } else {
		                soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c ' 
		                				+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.Name = ' + searchValue 
		                				+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
		                				+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
		            }
	                List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRBI(soqlQuery);
	                
	                if (rbi.size() > 1) {
	                	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
	                    isMessageRender = true;
	                } else if (rbi.size() == 1) {
	                	rbiAccount = rbi[0];
	                	rrA.Account__c = rbi[0].Account__c;
	                } else {
		                searchValue = accName.replace('*', '%') + '%';
				        searchValue = String.escapeSingleQuotes(searchValue);
				        searchValue = '\'' + searchValue + '\'';
				        
			            if (isCandidateRequest) {
			                soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c ' 
			                				+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.Name LIKE ' + searchValue 
			                				+ ' AND Reference_Program_Candidate__c = true LIMIT 10';
			            } else {
			                soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c ' 
			                				+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.Name LIKE ' + searchValue 
			                				+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
			                				+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
			            }
		                rbi = WithoutSharingHelperController.getRBI(soqlQuery);
		                
		                if (rbi.size() > 1) {
		                	isMessageRender = true;
		                	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
		                } else if (rbi.size() == 0) {
		                    isMessageRender = true;
		                    ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Account_No_matches_found));
		                } else {
		                    rbiAccount = rbi[0];
		                    rrA.Account__c = rbiAccount.Account__c;
		                }
	                }
	            } else if (accName == '') {
	                rrA.Account__c = null;
	            } else if (rrA.Account__c != null) {
	            	String soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c ' 
	            						+ ' WHERE Contact__c = null AND Account__c = \'' + rrA.Account__c + '\' LIMIT 1';
	                List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRBI(soqlQuery);
	                rbiAccount = rbi[0];
	            }
	            
	            if (rrA.Deadline__c < Date.today()) {
	                isMessageRender = true;
	                ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.INFO, System.Label.ReferenceUse_invalid_past_Deadline_date));
	            }
	            
	            if (!isMessageRender) {
	                List<Community_Invite__c> commInviteList = [SELECT Referenceability_Type__c,Reference_Request__c FROM Community_Invite__c 
	                									WHERE Referenceability_Type__c = :selRefType AND Reference_Request__c = :refRequest.Id];
		        	Id comInviteId;
		        	
		        	if (commInviteList.size() > 0) {
		        		comInviteId = commInviteList[0].Id;
		        	}

                    // added for REF-1542 - Gaurav Saini (1 Sep, 2018)
                    for (Reference_Request_Account__c rra : refRequest.Reference_Request_Accounts__r) {
                        refTypeAddInfoMap.put(rra.Reference_Type_Needed__c, rra.Reference_Request_Additional_Info__c);
                    }

                    for (Unspecified_Request__c ur : refRequest.Unspecified_Requests__r) {
                        refTypeAddInfoMap.put(ur.Reference_Type_Needed__c, ur.Reference_Request_Additional_Info__c);
                    }
		        	
	                if (rrA.Account__c == null) {
	                    Unspecified_Request__c tempObj = new Unspecified_Request__c(Unspecified_Request_Status__c = ConstantsController.NOT_STARTED,
	                        Reference_Request__c = refRequest.id, Reference_Type_Needed__c = selRefType, Deadline__c = rrA.Deadline__c,
	                        Requester__c = refRequest.Requester__c, Community_Invite__c = comInviteId, Community_Participate__c = true,
                            Reference_Request_Additional_Info__c = refTypeAddInfoMap.containsKey(selRefType) ? refTypeAddInfoMap.get(selRefType) : null);
	                    insert tempObj;
	                } else {
	                    Reference_Request_Account__c tempObj = new Reference_Request_Account__c(Account__c = rrA.Account__c, Community_Invite__c = comInviteId,
	                        Reference_Request__c = refRequest.id, Reference_Type_Needed__c = selRefType, Deadline__c = rrA.Deadline__c, Community_Participate__c = true,
	                        Requester__c = refRequest.Requester__c, Managed_Request__c = true, Process__c = ConstantsController.MANAGED,
	                        Account_Request_Status__c = (rbiAccount.Reference_Owner__c == null ? ConstantsController.NOT_STARTED : ConstantsController.IN_PROGRESS),
                            Reference_Request_Additional_Info__c = refTypeAddInfoMap.containsKey(selRefType) ? refTypeAddInfoMap.get(selRefType) : null);
	                    WithoutSharingHelperController.upsertRRA(tempObj);
	                } 
	            }
	        } catch (Exception e) {
	            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, e.getMessage()));
	            database.rollback(sp);
	        }
    	}
    }
    
    /**
     * Method to fetch Accounts
     */
    public void fetchAccounts() {
        searchText = accName;
        search();
        isAccountShow = true;
    }
    
    /**
     * Method to Search Accounts
     */
    public Pagereference search() {
        Set<String> setAccountIds = new Set<String>();
        String soqlQuery = '';
        
        if (searchText != null && searchText.trim().length() > 0) {
            String searchValue = searchText.replace('*', '%') + '%';
            searchValue = String.escapeSingleQuotes(searchValue);
            searchValue = '\'' + searchValue + '\'';
            
            if (isCandidateRequest) {
                soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null AND Account__r.Name LIKE ' 
                				+ searchValue + ' AND Reference_Program_Candidate__c = true ORDER BY Account__r.Name';
            } else {
                soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null AND Account__r.Name LIKE ' 
                				+ searchValue + ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                				+ '\' AND Referenceability_Status__c != \'\') ORDER BY Account__r.Name';
            }
            
            for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBI(soqlQuery)) {
                setAccountIds.add(rbi.Account__c); 
            }
        } else {
			
			if (isCandidateRequest) {
                soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
                				+ ' AND Reference_Program_Candidate__c = true ORDER BY Account__r.Name';
            } else {
                soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
                				+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                				+ '\' AND Referenceability_Status__c != \'\') ORDER BY Account__r.Name';
            }
            
            for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBI(soqlQuery)) {
                setAccountIds.add(rbi.Account__c); 
            }
        }
        accountList = WithoutSharingHelperController.getAccountRecordsforLookup(setAccountIds,201);
        return null;
    }
	
	/**
     * Method to set to Account lookup screen
     */
    public void setAccount() {
        isAccountShow = false;
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'Unspecified_Request__c', new Set<String> {
    									UtilityController.appNamespace() + 'Unspecified_Request_Status__c',
    									UtilityController.appNamespace() + 'Reference_Request__c',
    									UtilityController.appNamespace() + 'Reference_Type_Needed__c',
    									UtilityController.appNamespace() + 'Community_Participate__c',
    									UtilityController.appNamespace() + 'Deadline__c',
    									UtilityController.appNamespace() + 'Community_Invite__c',
    									UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c',  // added for REF-1542 - Gaurav Saini (31 Aug, 2018)
    									UtilityController.appNamespace() + 'Requester__c' });
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
}