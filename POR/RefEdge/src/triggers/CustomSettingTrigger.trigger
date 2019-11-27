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
trigger CustomSettingTrigger on Custom_Settings__c(before insert, before update, before delete,after update) {
    //Trigger Call Before Context
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            CustomSettingTriggerHandler.onBeforeInsert(Trigger.New);
        }
        if (Trigger.isUpdate) {
            if(ConstantsController.updateCustomSettingWithValidation)
                CheckEditionInTriggerHandler.validateFieldAccess(Trigger.New, Trigger.oldMap);
            CustomSettingTriggerHandler.onBeforeUpdate(Trigger.New, trigger.oldMap, trigger.newMap);
        }
        if (Trigger.isDelete) {
            CustomSettingTriggerHandler.onBeforeDelete(Trigger.old);
        }
    }
    
    //Trigger Call After Context
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            CustomSettingTriggerHandler.onAfterUpdate(Trigger.New, trigger.oldMap, trigger.newMap);
        }
    }
}