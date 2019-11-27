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
 * Page: AddRequestAccountLookup 
 * Description: Class to display accounts on custom lookup 
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class AddRequestAccountLookupController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String searchText { get; set; }
    public List<Account> accountList { get; set; }
    public Boolean isCandidateRequest { get; set; }
    public Boolean isMultiSelect { get; set; }
    public List<AccountWrapper> accountListWrapper { get; set; }
    private Set<String> accIdSet; 
    private Set<String> existingAccIdSet;
    private List<String> accId;
    //REF 2213
    public Boolean showAllAccounts { get; set; }
    
    /**
     * Constructor
     */
    public AddRequestAccountLookupController() {
        searchText = '';
        isCandidateRequest = false; 
        accountListWrapper = new List<AccountWrapper>();
        accIdSet = new Set<String>();
        existingAccIdSet = new Set<String>();
        accId = new List<String>();
        String accountName = ApexPages.currentPage().getParameters().get('strText');
        accountList = new List<Account>(); 
        showAllAccounts = false;
        
        if (ApexPages.currentPage().getParameters().get('all') != null) {
            showAllAccounts = ApexPages.currentPage().getParameters().get('all') == 'true';  
        }
         
        if (ApexPages.currentPage().getParameters().get('type') != null && ApexPages.currentPage().getParameters().get('type') != '' 
        		&& ApexPages.currentPage().getParameters().get('type') == 'candidate') {
            isCandidateRequest = true;
        }
        
        if (ApexPages.currentPage().getParameters().get('multiSelect') != null && ApexPages.currentPage().getParameters().get('multiSelect') == 'true') {
            isMultiSelect = true; 
            
            if (ApexPages.currentPage().getParameters().get('selectedAccounts') != null) {
            	accId = ApexPages.currentPage().getParameters().get('selectedAccounts').split(',');  
            	accIdSet = new Set<String> (accId);
            }  
            
             if (ApexPages.currentPage().getParameters().get('existingAccounts') != null) {
                accId = ApexPages.currentPage().getParameters().get('existingAccounts').split(',');  
                existingAccIdSet = new Set<String>(accId);
            }
        } else {
        	isMultiSelect = false;        	
        }
        searchText = accountName;
        search();
    }

    /**
     * Method to Search Accounts
     */
    public Pagereference search() {
        Set<String> setAccountIds = new Set<String>();
        String soqlQuery = '';
        AccountWrapper AW;
        if (showAllAccounts) {
            if (searchText != null && searchText.trim().length() > 0) {
                String searchValue = searchText.replace('*', '%') + '%';
                searchValue = String.escapeSingleQuotes(searchValue);
                searchValue = '\'' + searchValue + '\'';
                
                soqlQuery = 'SELECT Name, Site, Type,OwnerId FROM Account WHERE Name != null AND Name LIKE ' + searchValue
            				+ ' ORDER BY Name LIMIT 201';
            } else {
                soqlQuery = 'SELECT Name, Site, Type,OwnerId FROM Account '
            				+ ' ORDER BY Name LIMIT 201';
            }
            if (!isMultiSelect) {
                accountList = WithoutSharingHelperController.getAccountUsingDynamicSOQL(soqlQuery);
            } else if (accIdSet.size() > 0) {
                accountListWrapper.clear();
                
                for (Account acc : WithoutSharingHelperController.getAccountUsingDynamicSOQL(soqlQuery)) {
                    
                    if (accIdSet.contains(acc.Id) || existingAccIdSet.contains(acc.Id)) {
                        
                        if (existingAccIdSet.contains(acc.Id)) {
                            AW = new AccountWrapper(acc, true, true);
                        } else {
                            AW = new AccountWrapper(acc, true, false);
                        }
                    } else {
                        AW = new AccountWrapper(acc, false, false);
                    }
                    accountListWrapper.add(AW);	
                } 
            }  
        } else {
            if (searchText != null && searchText.trim().length() > 0) {
                String searchValue = searchText.replace('*', '%') + '%';
                searchValue = String.escapeSingleQuotes(searchValue);
                searchValue = '\'' + searchValue + '\'';
                
                if (isCandidateRequest) {
                    soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null '
                                + 'AND Account__r.Name LIKE ' + searchValue + ' AND Reference_Program_Candidate__c = true ORDER BY Account__r.Name';
                } else {
                    soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
                                + 'AND Account__r.Name LIKE ' + searchValue + ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' 
                                + ConstantsController.INACTIVE + '\' AND Referenceability_Status__c != \'\') ORDER BY Account__r.Name';
                }
                
                for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBI(soqlQuery)) {
                    setAccountIds.add(rbi.Account__c);
                }
            } else {
                
                if (isCandidateRequest) {
                    soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null '
                                + 'AND Reference_Program_Candidate__c = true ORDER BY Account__r.Name';
                } else {
                    soqlQuery = 'SELECT Account__c FROM Reference_Basic_Information__c WHERE Account__c != null AND contact__c = null ' 
                                + 'AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' 
                                + ConstantsController.INACTIVE + '\' AND Referenceability_Status__c != \'\') ORDER BY Account__r.Name';
                }
                
                for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getRBI(soqlQuery)) {
                    setAccountIds.add(rbi.Account__c);
                }
            }
            
            if (!isMultiSelect) {
                accountList = WithoutSharingHelperController.getAccountRecordsforLookup(setAccountIds,201);
            } else if (accIdSet.size() > 0) {
                accountListWrapper.clear();
                
                for (Account acc : WithoutSharingHelperController.getAccountRecordsforLookup(setAccountIds,201)) {
                    
                    if (accIdSet.contains(acc.Id) || existingAccIdSet.contains(acc.Id)) {
                        
                        if (existingAccIdSet.contains(acc.Id)) {
                            AW = new AccountWrapper(acc, true, true);
                        } else {
                            AW = new AccountWrapper(acc, true, false);
                        }
                    } else {
                        AW = new AccountWrapper(acc, false, false);
                    }
                    accountListWrapper.add(AW);	
                } 
            }   
        }
        return null;
    }
    
    /**
     * Wrapper Class
     */
    public class AccountWrapper {
        public Boolean isSelected { get; set; }
        public Account account { get; set; }
        public Boolean isExistingAccount { get; set; }
        
        public AccountWrapper(Account acc, boolean isSelected, boolean isExistingAccount) {
            this.isSelected = isSelected;
            this.account = acc;
            this.isExistingAccount = isExistingAccount;
        }
    }
}