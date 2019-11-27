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
 
 /*
 * This is trigger on User_Profile__c Object .
 * @Author : Narender
 * @see : UserProfileTriggerHandler
 * @Version : 1.0
 */
trigger UserProfileTrigger on User_Profile__c (before delete,after delete, after insert, after undelete, after update) {
		
    //Trigger Call before Context
    if (Trigger.isBefore) {
       
        //On before Delete
        if (Trigger.isDelete) {
            UserProfileTriggerHandler.onBeforeDelete(trigger.old);
        }
    }
    
     //Trigger Call before Context
    if (Trigger.isAfter) { 
        //On before Delete
        if (Trigger.isDelete) {
            UserProfileTriggerHandler.onAfterDelete(trigger.old); 
        }
    }

}