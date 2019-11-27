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
trigger RefrenceContentTrigger on Reference_Content__c(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    RefrenceContentTriggerHandler.newReferenceContents = trigger.new;
    RefrenceContentTriggerHandler.newReferenceContentMap = trigger.newMap;
    RefrenceContentTriggerHandler.oldReferenceContentMap = trigger.oldMap;
    RefrenceContentTriggerHandler.oldReferenceContents = trigger.old;
    //After trigger context
    if (trigger.isAfter) {
        //On Delete
        if (trigger.isDelete) {
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            if (cs.Auto_create_delete_Reference_Content__c || ConstantsController.isCallFromInfluitiveAPI) {
                RefrenceContentTriggerHandler.onAfterDelete();
            }
        }
        if (trigger.isUpdate) {
            RefrenceContentTriggerHandler.onAfterUpdate();
        }
        if(trigger.isInsert){
            RefrenceContentTriggerHandler.onAfterInsert();
        }
    }
    if(trigger.isBefore){
        if(trigger.isDelete){
            RefrenceContentTriggerHandler.onBeforeDelete();
        }
        if(trigger.isUpdate){
            RefrenceContentTriggerHandler.onBeforeUpdate();
        }
        
        if (trigger.isInsert) {
            
            if (ConstantsController.isCallFromInfluitiveAPI) {
                
                RefrenceContentTriggerHandler.onBeforeInsert();
            }
        }
    }
}