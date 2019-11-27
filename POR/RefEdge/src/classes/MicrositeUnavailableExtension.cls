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
 * Page: MicrositeUnavailablePage
 * Description : Class used to update/delete the microsite.
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class MicrositeUnavailableExtension extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String micrositeId;
    private String returnUrl;
    public Microsite__c micro { get; set; }

    /**
     * Constructor
     */
    public MicrositeUnavailableExtension(ApexPages.StandardController controller) {
        micrositeId = controller.getId();
        returnUrl = ApexPages.currentPage().getParameters().get('retURL');
    	micro = [SELECT Available_for_Use__c, (SELECT Id FROM Invitations__r) FROM Microsite__c WHERE Id = : micrositeId];
    }

    /**
     * Method to Update Microsite
     */
    public PageReference updateMicrosite() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'Microsite__c', new Set<String> { 
            										UtilityController.appNamespace() + 'Available_for_Use__c' });
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
		Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Microsite__c'});    										
    	
    	if (isUpsertPermission && isDeletePermission) {
	    	try {
		        if (micro.Invitations__r.size() > 0) {
		            micro.Available_for_Use__c = false;
		            update micro; 
		        } else {
		            delete micro; 
		        }
		        //re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous/home page.
		        return UtilityController.redirectToSource(returnUrl);
	        } catch (Exception e) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	            return null;
	        }
    	} else {
    		return null;
    	}
    }

    /**
     * Method to Cancel Url
     */
    public PageReference cancelMicrosite() {
        //re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous/home page.
        return UtilityController.redirectToSource(returnUrl);
    }
}