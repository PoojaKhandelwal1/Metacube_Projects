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
trigger ReferenceRequestAccountTrigger on Reference_Request_Account__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    RRAccountTriggerHandler.newList = trigger.new;
    RRAccountTriggerHandler.newMap = trigger.newMap;
    RRAccountTriggerHandler.oldList = trigger.old;
    RRAccountTriggerHandler.oldMap = trigger.oldMap;
    //Trigger Call Before Context
    if (trigger.isBefore) {
        //On before Insert
        if (trigger.isInsert) {
            CheckEditionInTriggerHandler.validateFieldAccess(trigger.new, null);
            RRAccountTriggerHandler.onBeforeInsert();
        }
        //On before Update
        if (trigger.isUpdate) {
            CheckEditionInTriggerHandler.validateFieldAccess(trigger.new, trigger.oldMap);
            RRAccountTriggerHandler.onBeforeUpdate();
        }
        if (trigger.isDelete) {
            RRAccountTriggerHandler.onBeforeDelete();
        }
    }

    //Trigger Call After Context
    if (trigger.isAfter) {
        //On after insert
        if (trigger.isInsert) {
            RRAccountTriggerHandler.onAfterInsert();
        }
        //On after Update
        if (trigger.isUpdate) {
            RRAccountTriggerHandler.onAfterUpdate();
        }
        if (trigger.isDelete) {
            RRAccountTriggerHandler.onAfterDelete();
        }
        if (trigger.isUnDelete) {
            RRAccountTriggerHandler.onAfterUnDelete();
        }
    }
}