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
 * Page: AddNewRelatedRefContents
 * Description: Class used to add new associated reference contents.
 * Modified by: Rekha @Feb 6 2017
 */
public with sharing class AddNewRelatedRefContentsController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Account_Reference_Content__c accRefContent { get; set; }
    public String returnUrl { get; set; }
    public Boolean isFromAccount { get; set; }
    public String accName { get; set; }
    public String refConName { get; set; }
    public Boolean isNameChanged { get; set; }
    public Boolean isSLDS { get; set; }
    public String accId { get; set; }
    
    /**
     * Constructor
     */
    public AddNewRelatedRefContentsController(ApexPages.StandardController controller) { 
    	 
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        accName = '';
	        refConName = '';
	        isNameChanged = false;
	        accRefContent = (Account_Reference_Content__c) controller.getRecord();
	        accId = ApexPages.currentPage().getParameters().get('acctId');
	        returnUrl = accRefContent.Reference_Content__c != null ? String.valueOf(accRefContent.Reference_Content__c) : '';
	        
	        if (accId != null) {
	            isFromAccount = true;
	            accRefContent.Account__c = accId;
	            returnUrl = accId;
	        } else {
	            isFromAccount = false;
	        }
        }
    }
    
    /**
     * Method to redirect page if request not coming from Account page - re #619
     */
    public PageReference checkForContentAssociations() { 
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
        } else { 
            isSLDS = false;
        }
        
    	if (String.isBlank(accId) && !isSLDS) {    
			PageReference retURL = new PageReference(Page.AddAssociatedAccountsAndContacts.getUrl() + '?refConId=' + returnUrl);
			retURL.setRedirect(true);
	      	return retURL;
    	} else {
    		return null;
    	} 
 	}

    /**
     * Method to save the Reference Content
     */
    public PageReference save() {
        savePoint sp = Database.setSavepoint();
        try {
        	
            if (!isFromAccount) {
            	
                if (isNameChanged && accName.trim().length() > 0) {
                    String searchValue = String.escapeSingleQuotes(accName);
                    searchValue = '\'' + searchValue + '\'';
                    String soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c '
                    						+ 'WHERE Contact__c = null AND Account__c != null AND Account__r.Name = ' + searchValue 
                    						+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                    						+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
                    List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRBI(soqlQuery);
                    
                    if (rbi.size() > 1) {
                    	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
                        return null;
                    } else if (rbi.size() == 1) {
                    	accRefContent.Account__c = rbi[0].Account__c;
                    } else {
	                    searchValue = accName.replace('*', '%') + '%';
				        searchValue = String.escapeSingleQuotes(searchValue);
				        searchValue = '\'' + searchValue + '\'';
				        soqlQuery = 'SELECT Reference_Owner__c, Account__c FROM Reference_Basic_Information__c '
				        				+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.Name LIKE ' + searchValue 
				        				+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
				        				+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
	                    rbi = WithoutSharingHelperController.getRBI(soqlQuery);
	                    
	                    if (rbi.size() > 1) {
	                    	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
	                        return null;
	                    } else if (rbi.size() == 0) {
	                        ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Account_No_matches_found));
	                        return null;
	                    } else {
	                        accRefContent.Account__c = rbi[0].Account__c;
	                    }
                    }
                } else if (accName == '') {
                    accRefContent.Account__c = null;
                }
            } else {
            	
            	if (isNameChanged && refConName.trim().length() > 0) {
                    String searchValue = String.escapeSingleQuotes(refConName);
                    searchValue = '\'' + searchValue + '\'';
                    String soqlQuery = 'SELECT Id FROM Reference_Content__c WHERE Name = ' + searchValue + ' LIMIT 10';
                    List<Reference_Content__c> refConList = Database.query(soqlQuery);
                    
                    if (refConList.size() > 1) {
                    	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
                        return null;
                    } else if(refConList.size() == 1) {
                    	accRefContent.Reference_Content__c = refConList[0].Id;
                    } else {
	                    searchValue = refConName.replace('*', '%') + '%';
			            searchValue = String.escapeSingleQuotes(searchValue);
			            searchValue = '\'' + searchValue + '\'';
	                    soqlQuery = 'SELECT Id FROM Reference_Content__c WHERE Name LIKE ' + searchValue + ' LIMIT 10';
	                    refConList = Database.query(soqlQuery);
	                    
	                    if (refConList.size() > 1) {
	                    	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
	                        return null;
	                    } else if (refConList.size() == 0) {
	                        ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Reference_Content_No_matches_found));
	                        return null;
	                    } else {
	                        accRefContent.Reference_Content__c = refConList[0].Id;
	                    }
                    }
                } else if (refConName == '') {
                    accRefContent.Reference_Content__c = null;
                }
            }
            WithoutSharingHelperController.insertAccountReferenceContent(new List<Account_Reference_Content__c>{accRefContent});
            return cancel();
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
        return null;
    }

    /**
     * Method to cancel the process
     */
    public PageReference cancel() {
		//re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous/Home page.
        //changed by Rekha
        if (returnUrl != null) {
            return new Pagereference('/' + returnUrl);
        } else {
            return new PageReference(System.URL.getSalesforceBaseURL().toExternalForm());
        }
    }
    
}