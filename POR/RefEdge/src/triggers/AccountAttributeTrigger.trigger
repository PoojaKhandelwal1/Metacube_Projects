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
trigger AccountAttributeTrigger on Account_Attribute__c(after delete, before delete, before insert, before update, after insert, after undelete, after update) {
    if (!ConstantsController.stopAccAttributeTrigger) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        if (cs.Shared_Contacts__c) {
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    AccountAttributeSharedTriggerHandler.onBeforeInsert(trigger.New);
                }
                if (Trigger.isDelete) {
                    AccountAttributeSharedTriggerHandler.onBeforeDelete(trigger.old, trigger.oldMap);
                }
            } else if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    AccountAttributeSharedTriggerHandler.onAfterInsert(trigger.New, trigger.newMap);
                }
                if (Trigger.isUndelete) {
                    AccountAttributeSharedTriggerHandler.onAfterUndelete(trigger.New);
                }
                if (Trigger.isDelete) {
                    AccountAttributeSharedTriggerHandler.onAfterDelete(trigger.old);
                }
                if (trigger.isUpdate) {
                    AccountAttributeSharedTriggerHandler.onAfterUpdate(trigger.New, trigger.newMap, trigger.oldMap);
                }
            }
        } else {
            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    AccountAttributeTriggerHandler.onBeforeInsert(trigger.New);
                }
                if (Trigger.isDelete) {
                    AccountAttributeTriggerHandler.onBeforeDelete(trigger.old, trigger.oldMap);
                }
            } else if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    AccountAttributeTriggerHandler.onAfterInsert(trigger.New, trigger.newMap);
                }
                if (Trigger.isUndelete) {
                    AccountAttributeTriggerHandler.onAfterUndelete(trigger.New);
                }
                if (Trigger.isDelete) {
                    AccountAttributeTriggerHandler.onAfterDelete(trigger.old);
                }
                if (trigger.isUpdate) {
                    AccountAttributeTriggerHandler.onAfterUpdate(trigger.New, trigger.newMap, trigger.oldMap);
                }
            }
        }
    }
}