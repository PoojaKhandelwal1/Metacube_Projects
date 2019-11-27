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
 * Page: SF1_FindReferences
 * Description : This class called from SF1_FindReferences to get the display theme
 * Modified by: Rekha Jangir @Nov/30/2016
 */
global with sharing class InlinePageNavigationController extends RefEdgeEditionFeatures {
	
	/**
     * Properties and variables
     */
	public Boolean isSLDS { get; set; }
	public Boolean isSF1 { get; set; }
	public Boolean isRequestAllowedFromLead { get; set; }
	public Id accountId { get; set; }
	public Id contactId { get; set; }
	public Boolean isFromRelatedList { get; set; }
	
	/**
     * Constructor for Standard controller
     */
    global InlinePageNavigationController(ApexPages.StandardController controller) {
        getTheme();
        String Id = controller.getRecord().Id;
        isRequestAllowedFromLead = false;
        isFromRelatedList = ApexPages.currentPage().getParameters().get('isFromRelatedList') != null
        					? ApexPages.currentPage().getParameters().get('isFromRelatedList') == 'true' : false;
        String returnUrlParam = ApexPages.currentPage().getParameters().get('retURL') != null
        						? ApexPages.currentPage().getParameters().get('retURL') : '';
        
        if (returnUrlParam.length() >= 15) {
        	isFromRelatedList = true;
        }
        
        if (Id != null) {
        	
        	//Add account Id and Contact Id for Nomination #1170
	        if (Id.substring(0, 3) == '00Q') {
	        	Custom_Settings__c cs = UtilityController.getCustomSettings();
	        	isRequestAllowedFromLead = cs.Request_from_Leads__c;
	        } else if (Id.substring(0, 3) == '001') {
	        	accountId = Id;
	        } else if (Id.substring(0, 3) == '003') {
	        	contactId = Id;
	         	accountId = [SELECT AccountId FROM Contact WHERE Id = :Id].AccountId;
	        }  
        }
        //system.assert(false, '--' + isFromRelatedList);
    }
    
    /**
     * Constructor for custom controller
     */
    global InlinePageNavigationController() {
    	isFromRelatedList = ApexPages.currentPage().getParameters().get('isFromRelatedList') != null
        					? ApexPages.currentPage().getParameters().get('isFromRelatedList') == 'true' : false;
        getTheme();
    }
    
    /**
     * Method to get display theme
     * Author: Rekha
     * Ticket: #582
     */
    public void getTheme() {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d') {
            system.debug('*********SLDS');
            isSLDS = true;
            isSF1 = false;
        } else if (UserInfo.getUiTheme() == 'Theme4t') {
        	system.debug('*********SF1');
        	isSF1 = true;
        	isSLDS = false;
        } else {
            system.debug('********normal');
            isSLDS = false;
            isSF1 = false;
        }
    }
}