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
trigger ContentDocumentTrigger on ContentDocument(after delete, after update) {
    
    if ((UtilityController.getContentTrigger() && UtilityController.isRefedgeUserLicense()) || Test.isRunningTest()) {
	    
	    // After trigger context
	    if (trigger.isAfter) {
	        
	        // On Delete
	        if (trigger.isDelete) {
				ContentDocumentTriggerHandler.onAfterDelete(trigger.old);
	        }
	        
	        // added for #1186 - Gaurav Saini (8 Dec, 2017)
	        if (trigger.isUpdate) {
	        	ContentDocumentTriggerHandler.onAfterUpdate(trigger.oldMap, trigger.newMap);
	        }
	    }
    }
}