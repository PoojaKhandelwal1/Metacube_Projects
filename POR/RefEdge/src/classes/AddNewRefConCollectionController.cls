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
 * Class: AddNewRefConCollectionController
 * Description: Class used to manage reference collection.
 * Last modified by: Gaurav Saini (21 Feb, 2017) for #732
 */
public with sharing class AddNewRefConCollectionController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Related_Reference_Content__c collRefContent { get; set; }
    public String returnUrl { get; set; }
    public String recordId { get; set; }
    public Boolean isFromCollection { get; set; }
    public String refConName { get; set; }
    public String conCollName { get; set; }
    public Boolean isNameChanged { get; set; }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Related_Reference_Content__c',
    										new Set<String>{UtilityController.appNamespace() + 'Content_Collection__c',
    											UtilityController.appNamespace() + 'Reference_Content__c'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        return isUpsertPermission;
    }
    
    /**
     * Constructor
     */
    public AddNewRefConCollectionController(ApexPages.StandardController controller) {
        checkPermissions();
        refConName = '';
        conCollName = '';
        isNameChanged = false;
        collRefContent = (Related_Reference_Content__c)controller.getRecord();
        String colId = ApexPages.currentPage().getParameters().get('colId');
        returnUrl = ApexPages.currentPage().getParameters().get('retURL');
        
        if (colId != null) {
            isFromCollection = true;
            collRefContent.Content_Collection__c = colId;
            recordId = colId;
        } else {
            isFromCollection = false;
        }
    }
    
    /**
     * Method to save the Reference Content
     */
    public PageReference save() {
    	
    	if (checkPermissions()) {
	        SavePoint sp = Database.setSavepoint();
	        
	        try {
	        	
	            if (isFromCollection) {
	            	
	                if (isNameChanged && refConName.trim().length() > 0) {
	                    String searchValue = String.escapeSingleQuotes(refConName);
	                    searchValue = '\'' + searchValue + '\'';
	                    String soqlQuery = 'SELECT Id FROM Reference_Content__c WHERE Name = ' + searchValue + ' LIMIT 10';
	                    List<Reference_Content__c> refConList = Database.query(soqlQuery);
	                    
	                    if (refConList.size() > 1) {
	                        ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
	                        return null;
	                    } else if (refConList.size() == 1) {
	                        collRefContent.Reference_Content__c = refConList[0].Id;
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
	                            collRefContent.Reference_Content__c = refConList[0].Id;
	                        }
	                    }
	                } else if (refConName == '') {
	                    collRefContent.Reference_Content__c = null;
	                }
	            } else {
	            	
	                if (isNameChanged && conCollName.trim().length() > 0) {
	                    String searchValue = String.escapeSingleQuotes(conCollName);
	                    searchValue = '\'' + searchValue + '\'';
	                    String soqlQuery = 'SELECT Id FROM Content_Collection__c WHERE Name = ' + searchValue + ' LIMIT 10';
	                    List<Content_Collection__c> refConList = Database.query(soqlQuery);
	                    
	                    if (refConList.size() > 1) {
	                        ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
	                        return null;
	                    } else if (refConList.size() == 1) {
	                        collRefContent.Content_Collection__c = refConList[0].Id;
	                    } else {
	                        searchValue = conCollName.replace('*', '%') + '%';
	                        searchValue = String.escapeSingleQuotes(searchValue);
	                        searchValue = '\'' + searchValue + '\'';
	                        soqlQuery = 'SELECT Id FROM Content_Collection__c WHERE Name LIKE ' + searchValue + ' LIMIT 10';
	                        refConList = Database.query(soqlQuery);
	                        
	                        if (refConList.size() > 1) {
	                            ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Multiple_items_found));
	                            return null;
	                        } else if (refConList.size() == 0) {
	                            ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.label.Reference_Content_No_matches_found));
	                            return null;
	                        } else {
	                            collRefContent.Content_Collection__c = refConList[0].Id;
	                        }
	                    }
	                } else if (conCollName == '') {
	                    collRefContent.Content_Collection__c = null;
	                }
	            }
	            insert collRefContent;
	            
	            // re #589 Open Redirect Vulnerability - Validate URL and if retURL found blank then redirect to previous/Home page
	            // changed by Rekha
	            if (recordId != null && recordId != '') {
	            	return new Pagereference('/' + recordId);
	            } else {
	    			return UtilityController.redirectToSource(returnUrl);
	            }
	        } catch (Exception e) {
	            Apexpages.addMessages(e);
	            Database.rollback(sp);
	            return null;
	        }
    	} else {
    		return null;
    	}
    }
    
    /**
     * Method to cancel the process
     */
    public PageReference cancel() { 
    	
    	// re #589 Open Redirect Vulnerability - Validate URL and if retURL found blank then redirect to previous/Home page
        // changed by Rekha
        if (recordId != null && recordId != '') {
        	return new Pagereference('/' + recordId);
        } else {
			return UtilityController.redirectToSource(returnUrl);
        }
    }
}