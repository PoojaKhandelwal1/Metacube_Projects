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
 * Description : This tigger is used to update attribute name which are associated to product and when product name is updated 
 * Created by: Rekha Jangir @Dec/9/2016
 * Created regarding Ticket #572
 */
trigger ProductTrigger on Product2 (after update) {
    if((UtilityController.getProductTrigger() && UtilityController.isRefedgeUserLicense()) || Test.isRunningTest()){
    	//Trigger Call After Context
	    if (trigger.isAfter) {
	        if(trigger.isUpdate){
	            ProductTriggerHandler.onAfterUpdate(trigger.New,trigger.old,trigger.newMap,trigger.oldMap);
	        }
	    }
    }
}