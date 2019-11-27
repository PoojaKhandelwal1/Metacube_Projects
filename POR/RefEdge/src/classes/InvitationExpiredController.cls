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
 * Page: InvitationExpired
 * Description : Class used to expire any invitation.
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class InvitationExpiredController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private string invitationId;

    /**
     * Constructor
     */
    public InvitationExpiredController() {
        invitationId = ApexPages.currentPage().getParameters().get('InvitationId');
    }

    /**
     * Method to update Invitation
     */
    public PageReference updateInvitation() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'Invitation__c', new Set<String> { 
            										UtilityController.appNamespace() + 'Is_Expired__c' });
            										
    	if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
	    	try {
		        Invitation__c inv = [select Is_Expired__c from Invitation__c where Id = : invitationId];
		        inv.Is_Expired__c = true;
		        update inv;
	        	return new PageReference('/' + invitationId);
	        } catch (Exception e) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	            return null;
	        }
    	} else {
    		return null;
    	}
    }
}