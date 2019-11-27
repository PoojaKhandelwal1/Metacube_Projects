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
 * Trigger for insert, delete, update operations on Unspecified Request Object
 * 
 * Last Modified: Gaurav Saini (17 Nov, 2016)
 */
trigger UnspecifiedRequestTrigger on Unspecified_Request__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    //Trigger Call Before Context
    if (trigger.isBefore) {
        
        //On before Insert
        if (trigger.isInsert || Trigger.isUpdate) {
            CheckEditionInTriggerHandler.validateObjectAccess(trigger.new);
        }
        
        //On before Update
        if (trigger.isUpdate) {
            UnspecifiedRequestTriggerHandler.onBeforeUpdate(trigger.old, trigger.oldMap, trigger.new, trigger.newMap);
        }
    }
    
    //Trigger Call After Context
    if (trigger.isAfter) {
        
        //On after Update
        if (trigger.isUpdate) {
            UnspecifiedRequestTriggerHandler.onAfterUpdate(trigger.old, trigger.oldMap, trigger.new, trigger.newMap);
        }
    }
}