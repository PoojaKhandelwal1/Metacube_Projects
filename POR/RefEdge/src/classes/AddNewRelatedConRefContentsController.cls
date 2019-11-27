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
 * Page: AddNewRelatedConRefContents
 * Description: Class used to add new associated contacts.
 * Modified by: Rekha @24 May 2017
 */
public with sharing class AddNewRelatedConRefContentsController extends RefEdgeEditionFeatures {
    /**
     * Properties AND variables
     */
    public Contact_Reference_Content__c conRefContent { get; set; }
    public String returnUrl { get; set; }
    public String recordId { get; set; }
    public Boolean isFromContact { get; set; }
    public String conName { get; set; }
    public String refConName { get; set; }
    public Boolean isNameChanged { get; set; }
    public Boolean isSLDS { get; set; }
    public String conId { get; set; }
    public String refContentId { get; set; }
    /**
     * Constructor
     */
    public AddNewRelatedConRefContentsController(ApexPages.StandardController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        conName = '';
	        refConName = '';
	        isNameChanged = false;
	        conRefContent = (Contact_Reference_Content__c)controller.getRecord();
	        conId = ApexPages.currentPage().getParameters().get('conId');
	        
	        if (ApexPages.currentPage().getParameters().get('retURL') != null) {
		        returnUrl = ApexPages.currentPage().getParameters().get('retURL'); 
            	refContentId = returnURL.substring(1, returnURL.length()); 
	        } else {
		        recordId = (String)conRefContent.Reference_Content__c != null ? (String) conRefContent.Reference_Content__c : '';
		        refContentId = recordId; 
	        }
	        if (conId != null) {
	            isFromContact = true;
	            conRefContent.Contact__c = conId;
	            recordId = conId;
	        } else {
	            isFromContact = false;
	        }
        }
    }
	
	/**
     * Method to redirect page if request not coming from Contact page - re #619
     */
    public PageReference checkForContentAssociations() { 
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
        } else { 
            isSLDS = false;
        }
        
    	if (String.isBlank(conId) && !isSLDS) { 
			PageReference retURL = new PageReference(Page.AddAssociatedAccountsAndContacts.getUrl() + '?refConId=' + refContentId);
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
        	
            if (!isFromContact) {
            	
                if (isNameChanged && conName.trim().length() > 0) {
                    String searchValue = String.escapeSingleQuotes(conName);
                    searchValue = '\'' + searchValue + '\'';
                    String soqlQuery = 'SELECT Reference_Owner__c, Contact__c FROM Reference_Basic_Information__c ' 
                    					+ ' WHERE Account__c != null AND Contact__c != null AND Contact__r.Name = ' + searchValue 
                    					+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                    					+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
                    List<Reference_Basic_Information__c> rbi = WithoutSharingHelperController.getRBI(soqlQuery);
                    
                    if (rbi.size() > 1) {
                    	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
                        return null;
                    } else if (rbi.size() == 1) {
                    	conRefContent.Contact__c = rbi[0].Contact__c;
                    } else {
	                    searchValue = conName.replace('*', '%') + '%';
				        searchValue = String.escapeSingleQuotes(searchValue);
				        searchValue = '\'' + searchValue + '\'';
				        soqlQuery = 'SELECT Reference_Owner__c, Contact__c FROM Reference_Basic_Information__c ' 
				        			+ ' WHERE Account__c != null AND Contact__c != null AND Contact__r.Name LIKE ' + searchValue 
				        			+ ' AND Is_Referenceable__c = true AND (Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
				        			+ '\' AND Referenceability_Status__c != \'\') LIMIT 10';
	                    rbi = WithoutSharingHelperController.getRBI(soqlQuery);
	                    
	                    if (rbi.size() > 1) {
	                    	ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
	                        return null;
	                    } else if (rbi.size() == 0) {
	                        ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Contact_No_matches_found));
	                        return null;
	                    } else {
	                        conRefContent.Contact__c = rbi[0].Contact__c;
	                    }
                    }
                } else if (conName == '') {
                    conRefContent.Contact__c = null;
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
                    } else if (refConList.size() == 1) {
                    	conRefContent.Reference_Content__c = refConList[0].Id;
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
	                        conRefContent.Reference_Content__c = refConList[0].Id;
	                    }
                    }
                } else if (refConName == '') {
                    conRefContent.Reference_Content__c = null;
                }
            }
            WithoutSharingHelperController.insertContactReferenceContent(new List<Contact_Reference_Content__c>{conRefContent});
            return cancel();
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
    }

    /**
     * Method to cancel the process
     */
    public PageReference cancel() {
    	//re #589 Open Redirect Vulnerability-Validate URL AND if retURL found blank then redirect to previous/Home page
        //changed by Rekha
        if (recordId != null && recordId != '') {
        	return new Pagereference('/' + recordId);
        } else {
			return UtilityController.redirectToSource(returnUrl);
        }
    }
}