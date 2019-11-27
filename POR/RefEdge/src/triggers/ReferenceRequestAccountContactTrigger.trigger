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
trigger ReferenceRequestAccountContactTrigger on Reference_Request_Account_Contact__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    //Trigger Call Before Context
    if (trigger.isBefore) {
        //On After Insert
        if (trigger.isInsert) {
            CheckEditionInTriggerHandler.validateFieldAccess(trigger.New, null);
            RRAccountContactTriggerHandler.onBeforeInsert(trigger.New);
        }
        //On before Update
        if (trigger.isUpdate) {
            CheckEditionInTriggerHandler.validateFieldAccess(trigger.New, null);
            RRAccountContactTriggerHandler.onBeforeUpdate(trigger.New, trigger.oldMap, trigger.newMap);
        }
        if (trigger.isDelete) {
            RRAccountContactTriggerHandler.onBeforeDelete(trigger.oldMap.keySet());
        }
    }
    //Trigger Call After Context
    if (trigger.isAfter) {
        //On After Insert
        if (trigger.isInsert) {
            RRAccountContactTriggerHandler.onAfterInsert(trigger.new);
        }
        //On After Update
        if (trigger.isUpdate) {
            RRAccountContactTriggerHandler.onAfterUpdate(trigger.New, trigger.oldMap, trigger.newMap);
        }
        if (trigger.isDelete) {
            RRAccountContactTriggerHandler.onAfterDelete(trigger.old);
        }
        if (trigger.isUndelete) {
            RRAccountContactTriggerHandler.onAfterUnDelete(trigger.new);
        }
    }
}