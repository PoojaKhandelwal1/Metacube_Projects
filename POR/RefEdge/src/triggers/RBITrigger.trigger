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
trigger RBITrigger on Reference_Basic_Information__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    if(!ConstantsController.stopTriggerContentAccountOnMerge && !ConstantsController.isCopyNominationDetailProcess){
        if (Trigger.isBefore) {
            //On before insert
            if (trigger.isInsert) {
                CheckEditionInTriggerHandler.validateFieldAccess(Trigger.new, null);
                RBITriggerHandler.onBeforeInsert(Trigger.new);
            }
            //On before delete
            if (trigger.isDelete) {
                RBITriggerHandler.onBeforeDelete(Trigger.old);
            }
            //On before Update
            if (trigger.isUpdate) {
                CheckEditionInTriggerHandler.validateFieldAccess(Trigger.new, trigger.oldMap);
                RBITriggerHandler.onBeforeUpdate(trigger.new,trigger.oldMap,trigger.newMap);
            }
        }
        //Trigger Call After Context
        if (trigger.isAfter) {
            //On after insert
            if (trigger.isInsert && !ConstantsController.stopAfterInsertRBI) {
                RBITriggerHandler.onAfterInsert(Trigger.new);
            }
            //On after Update
            if (trigger.isUpdate && !ConstantsController.stopAfterInsertRBI) {
                RBITriggerHandler.onAfterUpdate(trigger.new,trigger.oldMap,trigger.newMap);
            }
            //On after delete
            if (trigger.isDelete) {
                RBITriggerHandler.onAfterDelete(Trigger.old);
            }
        }
    }
}