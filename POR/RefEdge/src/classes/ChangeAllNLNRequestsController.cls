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
 * VF Page: ChangeAllNLNRequests.page, DefaultReferenceUseLimits.page
 * Description: controller for changing the default use limits
 * Modified by: Rekha Jangir @23 August 2017
 */
public with sharing class ChangeAllNLNRequestsController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Custom_Settings__c cs { get; set; }
    public Boolean updateAllAccount { get; set; }
    public Boolean updateAllContact { get; set; }
    public Boolean isEdit { get; set; }
    public boolean isSLDS { get; set; }
    
    /**
     * Constructor
     */
    public ChangeAllNLNRequestsController(ApexPages.StandardController controller) {

        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
        	cs = (Custom_Settings__c)controller.getRecord();
	        cs = UtilityController.getCustomSettings();
	        updateAllAccount = false;
	        updateAllContact = false;
	        isEdit = false;
        }
    }
    
    /**
     * Method to save custom setting
     */
    public PageReference saveChanges() {
    	
        try {
            ConstantsController.updateExistingAccounts = updateAllAccount;
            ConstantsController.updateExistingContacts = updateAllContact;
            update cs;
            isEdit = false;
        } catch(Exception e) {
            Apexpages.addMessages(e);
        }
        return null;
    }
    
    /**
     * Method to cancel 
     */
    public void cancel() {
        cs = UtilityController.getCustomSettings();
        isEdit = false;
    }
    
    /**
     * Method to edit 
     */
    public void edit() {
        isEdit = true;
    }
}