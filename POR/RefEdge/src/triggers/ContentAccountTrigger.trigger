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
trigger ContentAccountTrigger on Account_Reference_Content__c(after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    ContentAccountTriggerHandler.newRefContents = trigger.New;
    ContentAccountTriggerHandler.oldRefContents = trigger.old;
    ContentAccountTriggerHandler.newRefContentMap = trigger.newMap;
    ContentAccountTriggerHandler.oldRefContentMap = trigger.oldMap;
    if(!ConstantsController.stopTriggerContentAccountOnMerge){
	    if (trigger.isBefore) {
	        if (trigger.isInsert) {
	            ContentAccountTriggerHandler.onBeforeInsert();
	        }
	    }
	    if (trigger.isAfter) {
	        if (trigger.isInsert) {
	            ContentAccountTriggerHandler.onAfterInsert();
	        }
	        if (trigger.isDelete) {
	            ContentAccountTriggerHandler.onAfterDelete();
	        }
	        if (trigger.isUnDelete) {
	            ContentAccountTriggerHandler.onAfterUndelete();
	        } 
	    }
    }
}