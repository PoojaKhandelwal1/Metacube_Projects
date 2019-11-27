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
trigger NominationTrigger on Nomination__c (after insert, after update, before insert, before update) {
    NominationTriggerHandler.newNominations = trigger.new;
    NominationTriggerHandler.oldNominations = trigger.old;
    NominationTriggerHandler.newMap = trigger.newMap;
    NominationTriggerHandler.oldMap = trigger.oldMap;
    //Trigger Call Before Context
    if (Trigger.isBefore) {
        if (trigger.isUpdate) {
            NominationTriggerHandler.onBeforeUpdate();
        }
        if (trigger.isInsert) {
            NominationTriggerHandler.onBeforeInsert();
        }
    }
    //Trigger Call After Context
    if (Trigger.isAfter) {
        //On after Update
        if (Trigger.isUpdate) {
            NominationTriggerHandler.onAfterUpdate();
        }
    }
}