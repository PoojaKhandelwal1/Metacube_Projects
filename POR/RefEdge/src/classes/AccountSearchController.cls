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
 * Class: RFSearchController
 * Description : class called from RFSearchController to manage account section filtering
 * Last Modified by: Gaurav Saini (21 Feb, 2017)
 */
public with sharing class AccountSearchController {
    
    /**
     * Properties and variables
     */
    public Set<String> selectedAccountIdSet;
    public Boolean isAccountSelected { get; set; }
    public String inputTextValue;
    private transient AttributeWrapper attributeWrapper;
    private transient ReferenceabilityWrapper referenceabilityWrapper;
    public Integer LAST_PAGE = 0;
    public Map<Integer, Set<Id>> mapAccount { get; set; }
    public Integer pageLimit { get; set; }
    public Integer accountSize { get; set; }
    // done for #234
    public Set<String> searchedAccountIdSet { get; set; }
    public Integer pageIndex { get; set; }
    public Boolean isNextRender { get; set; }
    public String reqId { get; set; }
    public Set<String> accountIds { get; set; }
    // getter for default page size
    public Integer PAGE_SIZE {
        get {
            
            if (PAGE_SIZE == null) {
                PAGE_SIZE = 5;
            }
            return PAGE_SIZE;
        }
        set;
    }
    // getter for show more page size
    public Integer SHOWMORE_PAGE_SIZE {
        get {
        	
            if (SHOWMORE_PAGE_SIZE == null) {
                SHOWMORE_PAGE_SIZE = 25;
            }
            return SHOWMORE_PAGE_SIZE;
        }
        set;
    }
    // getter to Account Page Block Limit Exceed
    public Boolean isAccountLimitExceed {
        get {
            
            if (isAccountLimitExceed == null) {
                isAccountLimitExceed = false;
            }
            return isAccountLimitExceed;
        }
        set;
    }
    // getter to show More Account Records
    public Boolean showMoreAccountRecords {
        get {
        	
            if (showMoreAccountRecords == null) {
                showMoreAccountRecords = false;
            }
            return showMoreAccountRecords;
        }
        set;
    }
    transient Set<String> rbiIds = new Set<String>();
    // for "Allow for candidates to be included on projects" by Rekha
    public String selectedType { get ;
        set {
            selectedType = value == null ? selectedType : value;
        }
    }
    public Map<String, String> filterLogic { get; set; }
    public String betweenFilterLogic { get; set; }
    public String stageLabelId { get; set; }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Active', 'Active'));
        options.add(new SelectOption('Inactive', 'Inactive'));
        return options;
    }
    
    // added for #1135 - Gaurav Saini (2 Dec, 2017)
    public transient Set<String> allAccountIds { get; set; }
    
    /**
     * Constructor
     */
    public AccountSearchController() {
        inputTextValue = '';
        isAccountSelected = false;
        selectedAccountIdSet = new Set<String>();
        searchedAccountIdSet = new Set<String>();	// done for #234
        stageLabelId = '';
        // for "Allow for candidates to be included on projects"   by Rekha
        selectedType = 'Active';
        // end
        reset();
    }
    
    /**
     * Method to RESET values
     */
    public void reset() {
    	allAccountIds = new Set<String>();
        isAccountSelected = false;
        filterLogic = new Map<String, String>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        //betweenFilterLogic = cs.RefSearch_Filters_Default__c ? 'And' : 'Or';
        betweenFilterLogic = 'And';
        accountSize = 0;
        isNextRender = true;
        pageIndex = 1;
        pageLimit = PAGE_SIZE;
        LAST_PAGE = 0;
        searchedAccountIdSet = new Set<String>();	// done for #234
        accountIds = new Set<String>();
        mapAccount = new Map<Integer, Set<Id>>();
    }
    
	private List<AccountWrapper> getPreviousAccounts(Set<Id> idSet) {
		System.debug('getPreviousAccounts :::::: ');
		List<AccountWrapper> accWrapList = new List<AccountWrapper>();
		List<Reference_Basic_Information__c> listAccount = WithoutSharingHelperController.getAccountRBIsForRefSearch(idSet);
        Map<Id, Account> accounts = new Map<Id, Account>(WithoutSharingHelperController.getAccountsForRefSearch(idSet));
        
        // Add account in list
        for (Reference_Basic_Information__c acc: listAccount) {
        	Integer hitSize = 0;
            Boolean isAlreadyHit = false;
            Integer refContentCount = 0;
           	
           	 // re #906-Null Check for ISSUE - R20.89- Proact IT - Search Refs Tab Error
            if (accounts.containsKey(acc.Account__c) != false) {
                 
	            for (Hit_List__c hit : accounts.get(acc.Account__c).Hit_Lists__r) {
	            	
	            	if (!hit.Released__c) {
	            		hitSize += 1;
	            	}
	        		
	        		if (hit.Reference_Request__c == reqId) {
	        			isAlreadyHit = true;
	        		}
	            }
	            
	            if (accounts.get(acc.Account__c).Account_Reference_Contents__r.size() > 0) {
                	refContentCount = accounts.get(acc.Account__c).Account_Reference_Contents__r.size();
                }
	                 
	            if (accounts.get(acc.Account__c).Reference_Request_Accounts__r.size() > 0) {
	                accWrapList.add(new AccountWrapper(acc, accounts.get(acc.Account__c).Reference_Request_Accounts__r.size(), hitSize,isAlreadyHit, refContentCount));
	            } else {
	                accWrapList.add(new AccountWrapper(acc, hitSize,isAlreadyHit, refContentCount));
	            }
            }
        }
        return accWrapList;
	}
	
    /**
     * Method to return list of accounts to RE Search Page
     */
    public List<AccountWrapper> listAccounts(String searchTextValue, AttributeWrapper attriWrappController,
											ReferenceabilityWrapper refeWrappController, Set<String> relatedAccountIds,
											Boolean mappingSelected, Boolean isExportClicked) {
        
        List<AccountWrapper> listData = new List<AccountWrapper>();
        inputTextValue = searchTextValue;
        attributeWrapper = attriWrappController;
        referenceabilityWrapper = refeWrappController;
        System.debug('listAccounts :::::: ');    
        
        try {
            
            if (isExportClicked) {
            	listData = searchAccounts(relatedAccountIds, mappingSelected, isExportClicked);
            } else {
            	
	            // Check if map contains values
	            if (mapAccount.containsKey(pageIndex) && pageIndex != 1) {
	            	
	                if (mapAccount.get(pageIndex).size() < pageLimit) {
	                    isNextRender = false;
	                    isAccountLimitExceed = false;
	                } else {
	                    isAccountLimitExceed = true;
	                }
	                listData = getPreviousAccounts(mapAccount.get(pageIndex));
	            } else {
	            	listData = searchAccounts(relatedAccountIds, mappingSelected, isExportClicked);
	            	
	            	if (listData.isEmpty()) {
	            		 listData = getPreviousAccounts(mapAccount.get(pageIndex));
	            	}
	            }
            }
            return listData;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    /**
     * Method to Search Accounts
     */
    public List<AccountWrapper> searchAccounts(Set<String> relatedAccountIds, Boolean mappingSelected, Boolean isExportClicked) {
    	System.debug('searchAccounts :::::: ');
        List<Reference_Basic_Information__c> listAccount = new List<Reference_Basic_Information__c>();
        List<AccountWrapper> accWrapList = new List<AccountWrapper>();
        Set<Id> tempAccountIds = new Set<Id>();
        
        if (!showMoreAccountRecords) {
            pageLimit = PAGE_SIZE;
        }
        
        if (showMoreAccountRecords && pageIndex == 1) {
            pageLimit = SHOWMORE_PAGE_SIZE;
        }
        
        if (!mapAccount.containsKey(pageIndex) || isExportClicked) {
        	
            if (inputTextValue.trim().length() == 0 && !isAttributeSelected()
            			&& referenceabilityWrapper.selectedReferenceabilityTypes.size() == 0 && !mappingSelected) {
            	
                // changes for #1135 - Gaurav Saini (4 Dec, 2017)
                if (isExportClicked) {
                	listAccount = WithoutSharingHelperController.getAccountRBIsForRefSearchExport(accountIds);
                } else {
	                // for "Allow for candidates to be included on projects" by Rekha
	                listAccount = WithoutSharingHelperController.getAccountRBIsForRefSearch(accountIds, selectedType);
                }
            } else {
                Map<String, Set<String>> tempAccIdsMap = new Map<String, Set<String>>();	//done for #234
                Set<String> commonFilterIds = new Set<String>();
                
                if (inputTextValue.trim().length() > 1) {
                    tempAccIdsMap = filterAccountsBySearchText(relatedAccountIds);
                    //commonFilterIds = filterAccountsBySearchText(relatedAccountIds);
                    commonFilterIds = tempAccIdsMap.get('allIds');
                    
                    for (String accId : tempAccIdsMap.get('nameBasedIds')) {	// done for #234
		            	searchedAccountIdSet.add(accId);
		            }
		            
                    if (commonFilterIds.size() > 0) {
                    	// changes for #642 - added parameter mappingSelected for
                    	//						checking if filter is already applied on refsearch page
                    	// changes for #687 - setting the mappingSelected parameter to true if
                    	//						any account is present in previous results (16 Jan, 2017)
                        commonFilterIds = filteredAccountIds(commonFilterIds, true);
                    }
                } else {
                    commonFilterIds.addAll(relatedAccountIds);
                    
                    if (!mappingSelected || commonFilterIds.size() > 0) {
                    	commonFilterIds = filteredAccountIds(commonFilterIds, mappingSelected);
                    }
                }
                
                // changes for #1135 - Gaurav Saini (4 Dec, 2017)
                if (isExportClicked) {
                	listAccount = WithoutSharingHelperController.getAccountRBIsForRefSearchExport(accountIds, commonFilterIds);
                } else {
	                // Resultant Accounts
	                listAccount = WithoutSharingHelperController.getAccountRBIsForRefSearch(accountIds, selectedType, commonFilterIds); 
                }
            }
            
            // added for #1135 - Gaurav Saini (2 Dec, 2017)
            if (isExportClicked) {
	            allAccountIds = new Set<String>();
	            
	            for (Reference_Basic_Information__c accRBI : listAccount) {
	            	allAccountIds.add(accRBI.Account__c);
	            }
	            allAccountIds.addAll(accountIds);
            }
            
            if (pageIndex == 1) {
                accountSize = listAccount.size();
            }
            
            if (listAccount.size() == pageLimit) {
                isNextRender = false;
                LAST_PAGE = pageIndex;
            }
            
            // set Ids
            for (Reference_Basic_Information__c rbiAcc : listAccount) {
                
                if (tempAccountIds.size() < pageLimit) {
                    accountIds.add(rbiAcc.Account__c);
                    tempAccountIds.add(rbiAcc.Account__c);
                } else {
                    break;
                }
            }
            isAccountLimitExceed = false;
            
            if (!mapAccount.containskey(pageIndex)) {
                mapAccount.put(pageIndex, new Set<Id>());
            }
            Map<Id, Account> accounts = new Map<Id, Account>(WithoutSharingHelperController.getAccountsForRefSearch(tempAccountIds));
            
            // Add account in list
            for (Reference_Basic_Information__c acc : listAccount) {
                
                if (mapAccount.get(pageIndex).size() == pageLimit) {
                    isAccountLimitExceed = true;
                    break;
                }
                Integer hitSize = 0;
                Boolean isAlreadyHit = false;
                Integer refContentCount = 0;
                
                // re #906-Null Check for ISSUE - R20.89- Proact IT - Search Refs Tab Error
                if (accounts.containsKey(acc.Account__c) != false) {
                
	                for (Hit_List__c hit : accounts.get(acc.Account__c).Hit_Lists__r) {
	                	
	                	if (!hit.Released__c) {
	                		hitSize += 1;
	                	}
	                	 
	            		if (hit.Reference_Request__c == reqId) {
	            			isAlreadyHit = true;
	            		}
	                }
	                
	                if (accounts.get(acc.Account__c).Account_Reference_Contents__r.size() > 0) {
	                	refContentCount = accounts.get(acc.Account__c).Account_Reference_Contents__r.size();
	                }
                	 
	                if (accounts.get(acc.Account__c).Reference_Request_Accounts__r.size() > 0) {
	                    mapAccount.get(pageIndex).add(acc.Account__c);
	                    accWrapList.add(new AccountWrapper(acc, accounts.get(acc.Account__c).Reference_Request_Accounts__r.size(), hitSize,isAlreadyHit, refContentCount));
	                } else {
	                    mapAccount.get(pageIndex).add(acc.Account__c);
	                    accWrapList.add(new AccountWrapper(acc, hitSize,isAlreadyHit, refContentCount));
                	}
                }
            }
            
            // Set last Page && render
            if (showMoreAccountRecords && mapAccount.get(pageIndex).size() < pageLimit) {
                isNextRender = false;
                LAST_PAGE = pageIndex;
            }
        }
        
        if (accWrapList != null && accWrapList.size() > 0) {
        	return accWrapList;
        } else {
        	return new List<AccountWrapper>();
        }
    }
    
    /**
     * Chk list in map "mapAttributesLabels" Null or not
     */
    private Boolean isAttributeSelected() {
    	System.debug('isAttributeSelected :::::: ');
        Boolean attributeSelected = false;
        
        for (String labelId: attributeWrapper.mapAttributesLabels.keyset()) {
        	
            if ((stageLabelId == null || stageLabelId == '') || (stageLabelId != '' && labelId != stageLabelId)) {
            	
	            if (attributeWrapper.mapAttributesLabels.get(labelId).size() > 0) {
	                attributeSelected = true;
	                break;
	            }
            }
        }
        return attributeSelected;
    }
    
    /**
     * Method to return Account Ids for Text
     */
    // return type changed from set to map for #234
    public Map<String, Set<String>> filterAccountsBySearchText(Set<String> relatedAccountIds) {
        Set<String> rbiAccountIds = new Set<String>();
        Set<String> searchedAccountIds = new Set<String>();
        Map<String, Set<String>> searchedAccountIdsMap = new Map<String, Set<String>>();	//this map contains account ids of all
        searchedAccountIdsMap.put('allIds', new Set<String>());								//accounts as one entry and the second entry
        searchedAccountIdsMap.put('nameBasedIds', new Set<String>());						//contains ids of accounts for which any field
        rbiIds = new Set<String>();														//on account object contains the searched text
        
        if (relatedAccountIds.size() == 0) {
        	
            for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountRBIsForRefSearch(selectedType)) {
                rbiIds.add(rbi.Account__c);
            }
        } else {
            rbiIds.addAll(relatedAccountIds);
        }
        // RBI Search Results
        List<List<SObject>> searchRBIList
        			= WithoutSharingHelperController.getAccountRBIsForRefSearchUsingSOSL(selectedType, inputTextValue,
        																					rbiIds, accountIds);
        
        for (Reference_Basic_Information__c acc : (List<Reference_Basic_Information__c>)searchRBIList[0]) {
            searchedAccountIds.add(acc.Account__c);
            searchedAccountIdsMap.get('allIds').add(acc.Account__c);
        }
        // Account Search Results
        List<List<SObject>> searchAccountList = WithoutSharingHelperController.getAccountsForRefsearchUsingSOSL(inputTextValue, rbiIds, accountIds, searchedAccountIds);
        
        for (Account acc : (List<Account>)searchAccountList[0]) {
            searchedAccountIds.add(acc.Id);
            searchedAccountIdsMap.get('allIds').add(acc.Id);
            searchedAccountIdsMap.get('nameBasedIds').add(acc.Id);
        }
        //return searchedAccountIds;	//commented for #234
        return searchedAccountIdsMap;
    }
    
    /**
     * Method to return final Account ids(Text, Referenceability & Attribute)
     * Last modified for #642 - added parameter mappingSelected for checking
     *							if filter is already applied on refsearch page
     */
    public Set<String> filteredAccountIds(Set<String> commonFilterIds, Boolean mappingSelected) {
        Set<String> setAccountIds = new Set<String>();
        Set<String> setLabelIds = new Set<String>();
        String labelClause = '';
        
        for (Label__c label : attributeWrapper.getAttributeLabels()) {
        	
            if ((stageLabelId == null || stageLabelId == '') || (stageLabelId != '' && label.Id != stageLabelId)) {
            	
	        	if (attributeWrapper.mapAttributesLabels.get(label.Id).size() > 0) {
	                String labelNo = String.escapeSingleQuotes((label.Filter_no__c != null ? 'F' + String.valueOf(label.Filter_no__c) + 'F' : ''));
	                
	                if (betweenFilterLogic == 'And') {
	                    
	                    if (labelClause == '') {
	                        labelClause = ' (Label_Ids1__c LIKE \'%' + labelNo
	                        				+ '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
	                    } else {
	                        labelClause += ' AND (Label_Ids1__c LIKE \'%' + labelNo
	                        				+ '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
	                    }
	                } else {
	                	
	                    if (labelClause == '') {
	                        labelClause = ' Label_Ids1__c LIKE \'%' + labelNo
	                        				+ '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\'';
	                    } else {
	                        labelClause += ' OR Label_Ids1__c LIKE \'%' + labelNo
	                        				+ '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\'';
	                    }
	                }
	                setLabelIds.add(label.Id);
	            }
            }
        }
        // Selected Referenceability Types
        String refTypesClause = '';
        
        if (filterLogic.containsKey('Referenceability') && filterLogic.get('Referenceability') == 'And') {
        	
            for (referenceabilityWrapper.ReferenceabilityTypeWrapper rtw : referenceabilityWrapper.selectedReferenceabilityTypes) {
                String refnumber = String.escapeSingleQuotes((rtw.refType.Referenceability_no__c != null
            							? 'R' + String.valueOf(rtw.refType.Referenceability_no__c) + 'R' : ''));
            	
                if (refTypesClause == '') {
                    refTypesClause = ' (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                    					+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                } else {
                    refTypesClause += ' AND (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                    					+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                }
            }
        } else {
            
            for (referenceabilityWrapper.ReferenceabilityTypeWrapper rtw : referenceabilityWrapper.selectedReferenceabilityTypes) {
                String refnumber = String.escapeSingleQuotes((rtw.refType.Referenceability_no__c != null
            							? 'R' + String.valueOf(rtw.refType.Referenceability_no__c) + 'R' : ''));
                
                if (refTypesClause == '') {
                    refTypesClause = ' ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                    					+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                } else {
                    refTypesClause += ' OR ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                						+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                }
            }
        }
        
        // If Labels & Referenceability Types are not selected
        if (labelClause == '' && refTypesClause == '') {
            return commonFilterIds;
        }
        //Create final dynamic Query
        String dynamicSOQL = '';
        String finalClause = '';
        
        if (betweenFilterLogic == 'And') {
        	
            if (labelClause != '') {
                finalClause += ' AND (' + labelClause + ')';
            }
            
            if (refTypesClause != '') {
                finalClause += ' AND (' + refTypesClause + ')';
            }
        } else {
        	
            if (refTypesClause != '' && labelClause != '') {
                finalClause = ' AND ((' + refTypesClause + ') OR (' + labelClause + '))';
            }
            
            if (labelClause != '') {
                finalClause += ' AND (' + labelClause + ')';
            }
            
            if (refTypesClause != '') {
                finalClause += ' AND (' + refTypesClause + ')';
            }
        }
        
        if (selectedType == 'Active') {
            finalClause += ' AND Account__c NOT IN :accountIds '
            				+ 'AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE
            				+ '\' AND Referenceability_Status__c != null '
            				+ 'ORDER BY Account__r.Name';
        } else if (selectedType == 'Inactive') {
            finalClause += ' AND Account__c NOT IN :accountIds '
            				+ 'AND Referenceability_Status__c = \'' + ConstantsController.INACTIVE
            				+ '\' ORDER BY Account__r.Name';
        } else if (selectedType == 'Candidate') {
            finalClause += ' AND Account__c NOT IN :accountIds '
            				+ 'AND Reference_Program_Candidate__c = true '
            				+ 'ORDER BY Account__r.Name';
        }
        
        // changes for #642 - checking if any related mapping filter is already applied or not
        if (mappingSelected) {
            dynamicSOQL = 'SELECT Account__c, Attribute_Ids__c, ReferenceabilityType_Ids1__c, '
            				+ 'ReferenceabilityType_Ids2__c, Account__r.Name '
            				+ 'FROM Reference_Basic_Information__c '
            				+ 'WHERE Contact__c = null '
            				+ 'AND Account__c != null '
            				+ 'AND Account__c IN :commonFilterIds ' + finalClause;
        } else {
            dynamicSOQL = 'SELECT Account__c, Attribute_Ids__c, ReferenceabilityType_Ids1__c, '
        					+ 'ReferenceabilityType_Ids2__c, Account__r.Name '
        					+ 'FROM Reference_Basic_Information__c '
        					+ 'WHERE Contact__c = null '
        					+ 'AND Account__c != null ' + finalClause;
        }
        
        // Iterate Final Reference profiles
        List<Reference_Basic_Information__c> referenceProfiles
    				= WithoutSharingHelperController.getAccountRBIsUsingDynamicSOQL(dynamicSOQL, accountIds, commonFilterIds);
        Map<String, Boolean> labelLogicMap = new Map<String, Boolean>();
        
        for (Reference_Basic_Information__c rbi : referenceProfiles) {
        	
            if (setLabelIds.size() > 0) {
            	
                if (rbi.Attribute_Ids__c != null && rbi.Attribute_Ids__c != '') {
                    Set<String> setAttribute = new Set<String>();
                    setAttribute.addAll(rbi.Attribute_Ids__c.split(','));
                    Integer selectedlabelCount = 0;
                    Integer recordMatchCount = 0;
                    
                    for (String labelId : setLabelIds) {
                        labelLogicMap.put(labelId, false);
                        selectedlabelCount++;
                        
                        // if advance filter has AND logic
                        if (filterLogic.containsKey(labelId) && filterLogic.get(labelId) == 'And') {
                            Boolean notMatched = false;
                            
                            for (attributeWrapper.AttributesLabelWrapper atw : attributeWrapper.mapAttributesLabels.get(labelId)) {
                            	
                                if (!setAttribute.contains(atw.attributeLabel.Attribute__c)) {
                                    notMatched = true;
                                    break;
                                }
                            }
                            
                            if (!notMatched) {
                                recordMatchCount++;
                                labelLogicMap.put(labelId, true);
                            }
                        } else {	// if advance filter has OR logic
                        	
                            for (attributeWrapper.AttributesLabelWrapper atw : attributeWrapper.mapAttributesLabels.get(labelId)) {
                            	
                                if (setAttribute.contains(atw.attributeLabel.Attribute__c)) {
                                    recordMatchCount++;
                                    labelLogicMap.put(labelId, true);
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (selectedlabelCount != 0) {
                    	
                        // if advance filter has AND logic
                        if (betweenFilterLogic == 'And') {
                            Boolean checkResult = true;
                            
                            for (Boolean flag : labelLogicMap.values()) {
                                checkResult = (checkResult && flag);
                            }
                            
                            if (checkResult) {
                                setAccountIds.add(rbi.Account__c);
                            }
                        } else {	// if advance filter has OR logic
                            Boolean checkResult = false;
                            
                            for (Boolean flag : labelLogicMap.values()) {
                                checkResult = (checkResult || flag);
                            }
                            
                            if (checkResult) {
                                setAccountIds.add(rbi.Account__c);
                            }
                        }
                    }
                }
            } else {
                setAccountIds.add(rbi.Account__c);
            }
        }
        return setAccountIds;
    }
    
    /**
     * Method to previous Link
     */
    public Pagereference previous() {
    	
        if (pageIndex != 1) {
            pageIndex = pageIndex - 1;
            isNextRender = true;
        }
        return null;
    }

    /**
     * Method to next Link
     */
    public Pagereference next() {
    	
        if (pageIndex != LAST_PAGE) {
            pageIndex = pageIndex + 1;
        } else {
            isNextRender = false;
        }
        return null;
    }
}