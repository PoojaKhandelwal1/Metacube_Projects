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
trigger ContactTrigger on Contact(before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if((UtilityController.getContactTrigger() && UtilityController.isRefedgeUserLicense()) || Test.isRunningTest()){
	    //Trigger Call Before Context
	    if(trigger.isBefore){
	    	//On Before Update
	    	if (trigger.isUpdate) {
	    		ContactTriggerHandler.onBeforeUpdate(trigger.new,trigger.old,trigger.oldMap);
	    	}
	    	//On Before Delete
	    	if (trigger.isDelete) {
	    		ContactTriggerHandler.onBeforeDelete(trigger.old,trigger.oldMap);
	    	}
	    }
	    
	    //Trigger Call After Context
	    if (trigger.isAfter) {
	        //On after Update
	        if (trigger.isUpdate) {
	            ContactTriggerHandler.onAfterUpdate(trigger.New,trigger.newMap,trigger.oldMap);
	        }
	        //On after Delete
	        if (trigger.isDelete) {
	    		ContactTriggerHandler.onAfterDelete(trigger.oldMap);
	    	}
	    }
    }
}