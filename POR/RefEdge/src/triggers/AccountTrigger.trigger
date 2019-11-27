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
trigger AccountTrigger on Account(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    if ((UtilityController.getAccountTrigger() && UtilityController.isRefedgeUserLicense()) || Test.isRunningTest()) {
        
        //Trigger Call before Context
        if (trigger.isBefore) {
            
            if (trigger.isDelete) {
                AccountTriggerHandler.onBeforeDelete(trigger.old, trigger.oldMap);
            }
            
            if (trigger.isUpdate) {
                AccountTriggerHandler.onBeforeUpdate(trigger.new, trigger.old, trigger.oldMap);
            }
        }
        
        //Trigger Call After Context
        if (trigger.isAfter) {
            
            if (trigger.isDelete) {
                AccountTriggerHandler.onAfterDelete(trigger.old, trigger.oldMap);
            }
            
            if (trigger.isUpdate) {
                AccountTriggerHandler.onAfterUpdate(trigger.New, trigger.old, trigger.newMap, trigger.oldMap);
            }
        }
    }
}