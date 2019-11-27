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
trigger ContactAttributesTrigger on Contact_Attribute__c(after delete, before delete, before insert, before update, after insert, after undelete) {
    if(!ConstantsController.stopConAttributeTrigger){
        /*ContactAttributeTriggerHandler.newContactAttributes = trigger.New;
        ContactAttributeTriggerHandler.oldContactAttributes = trigger.old;
        ContactAttributeTriggerHandler.newContactAttributeMap = trigger.newMap;
        ContactAttributeTriggerHandler.oldContactAttributeMap = trigger.oldMap;*/
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        //system.assert(false, 'in tigger   '+ConstantsController.selectedAccounts);
        if (cs.Shared_Contacts__c && !ConstantsController.isAccountSelectedfromContact) {
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    ContactAttributeSharedTriggerHandler.onBeforeInsert(trigger.new);
                }
                if (trigger.isDelete) {
                    ContactAttributeSharedTriggerHandler.onBeforeDelete(trigger.old, trigger.oldMap);
                }
            }
            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    ContactAttributeSharedTriggerHandler.onAfterInsert(trigger.new, trigger.newMap);
                }
                if (trigger.isUnDelete) {
                    ContactAttributeSharedTriggerHandler.onAfterUndelete(trigger.new, trigger.newMap);
                }
                if (Trigger.isDelete) {
                    ContactAttributeSharedTriggerHandler.onAfterDelete(trigger.old);
                }
            }
        } else if(!cs.Shared_Contacts__c || ConstantsController.isAccountSelectedfromContact){
        	if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    ContactAttributeTriggerHandler.onBeforeInsert(trigger.new);
                }
                if (trigger.isDelete) {
                    ContactAttributeTriggerHandler.onBeforeDelete(trigger.old, trigger.oldMap);
                }
            }
            if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    ContactAttributeTriggerHandler.onAfterInsert(trigger.new, trigger.newMap);
                }
                if (trigger.isUnDelete) {
                    ContactAttributeTriggerHandler.onAfterUndelete(trigger.new, trigger.newMap);
                }
                if (Trigger.isDelete) {
                    ContactAttributeTriggerHandler.onAfterDelete(trigger.old);
                }
            }
        }
    }
}