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
trigger OpportunityTrigger on Opportunity (before delete, before insert, before update, after delete, after insert, after undelete, after update) {
    if((UtilityController.getOpportunityTrigger() && UtilityController.isRefedgeUserLicense()) || Test.isRunningTest()){
	    OpportunityTriggerHandler.newOpportunities = trigger.New;
	    OpportunityTriggerHandler.oldOpportunities = trigger.old;
	    OpportunityTriggerHandler.newOpportunityMap = trigger.newMap;
	    OpportunityTriggerHandler.oldOpportunityMap = trigger.oldMap;
	    
	    //Trigger Call After Context
	    if (trigger.isAfter) {
	        //On after Insert
	        if(trigger.isInsert && !(ConstantsController.oppTriggerisInsert)){
	            OpportunityTriggerHandler.onAfterInsert();
				ConstantsController.oppTriggerisInsert = true;
	        }
	        
	        //On after Update
	        if(trigger.isUpdate && !(ConstantsController.oppTriggerisUpdate)){
	            OpportunityTriggerHandler.onAfterUpdate();
				ConstantsController.oppTriggerisUpdate = true;
	        }
	        
	        //On after Delete
	        if (Trigger.isDelete && !(ConstantsController.oppTriggerisDelete)) {
	            OpportunityTriggerHandler.onAfterDelete();
				ConstantsController.oppTriggerisDelete = true;
	        }
	        
	        //On after Undelete
	        if (Trigger.isUndelete && !(ConstantsController.oppTriggerisUndelete)) {
	            OpportunityTriggerHandler.onAfterUndelete();
				ConstantsController.oppTriggerisUndelete = true;
	        }
	    }
    }
}