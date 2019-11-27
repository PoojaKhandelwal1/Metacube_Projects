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
 * Object: Content_Collection__c
 * Description: Before insert and update trigger used to apply validation on Content Collection. 	
 * Created By: Rajesh (11 Nov, 2016)
 * Last Modified By: Rajesh (11 Nov, 2016)  
 */
trigger ContentCollectionTrigger on Content_Collection__c (before insert, before update) {
    if (Trigger.isBefore) {
    	if (Trigger.isUpdate) {  
    		ContentCollectionTriggerHandler.onBeforeUpdate(trigger.new, trigger.newMap); 
    	}
    	
    	if (Trigger.isInsert) {
    		ContentCollectionTriggerHandler.onBeforeInsert(trigger.new);
    	}
    }
}