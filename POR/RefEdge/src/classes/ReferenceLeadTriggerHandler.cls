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
public with sharing class ReferenceLeadTriggerHandler {
    
    /**
     * Method called on before update of Reference Lead
     */
    public static void onBeforeUpdate(List<Reference_Lead__c> newRefLeads, Map<Id, Reference_Lead__c> newRefLeadMap,
    			Map<Id, Reference_Lead__c> oldRefLeadMap) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Date todayDate = system.today();
        
        for (Reference_Lead__c refLead : newRefLeads) {
            
            if (newRefLeadMap.get(refLead.Id).Follow_Up_Timeframe__c != oldRefLeadMap.get(refLead.Id).Follow_Up_Timeframe__c
            			&& todayDate.daysBetween(refLead.No_Response_date__c) <= 0) {
                refLead.addError(system.Label.No_Response_Date_is_expired_Error);
            }
            
            if (newRefLeadMap.get(refLead.Id).Follow_Up_Timeframe__c != oldRefLeadMap.get(refLead.Id).Follow_Up_Timeframe__c
            			&& newRefLeadMap.get(refLead.Id).Follow_Up_Timeframe__c != null) {
				if (refLead.Follow_Up_Timeframe__c.contains(' days')) {
					refLead.Follow_up_date__c = todayDate.addDays(Integer.Valueof(refLead.Follow_Up_Timeframe__c.subStringBefore(' days')));
					refLead.No_Response_date__c = todayDate.addDays(Integer.Valueof(refLead.Follow_Up_Timeframe__c.subStringBefore(' days')) + Integer.Valueof(cs.No_Response_days__c));
				} else {
					refLead.Follow_up_date__c = todayDate.addDays(Integer.Valueof(refLead.Follow_Up_Timeframe__c.subStringBefore(' ')));
					refLead.No_Response_date__c = todayDate.addDays(Integer.Valueof(refLead.Follow_Up_Timeframe__c.subStringBefore(' ')) + Integer.Valueof(cs.No_Response_days__c));
				}
            }
        }
    }
    
    /**
     * method called on after update of Reference Lead
     * author: Gaurav Saini (2 Nov, 2017) for #1102
     */
	public static void onAfterUpdate(Map<Id, Reference_Lead__c> newRefLeadMap, Map<Id, Reference_Lead__c> oldRefLeadMap) {
		Custom_Settings__c cs = UtilityController.getCustomSettings();
		Boolean shouldUpdateCS = false;
		
		for (String refLeadId : newRefLeadMap.keySet()) {
			
			// processing only the records created from ref prospector functionality
			if (!newRefLeadMap.get(refLeadId).Ref_Lead_From_Opportunity__c
						&& newRefLeadMap.get(refLeadId).Reference_Lead_Status__c == 'Request Pending') {
				
				// if a lead is updated to be excluded from the campaign
				if (!newRefLeadMap.get(refLeadId).Ref_Lead_Include_in_Campaign__c && oldRefLeadMap.get(refLeadId).Ref_Lead_Include_in_Campaign__c) {
					
					if (cs.Ref_Prospector_Campaign_Lead_Count__c != null) {
						cs.Ref_Prospector_Campaign_Lead_Count__c = cs.Ref_Prospector_Campaign_Lead_Count__c - 1;
						shouldUpdateCS = true;
					}
				}
				
				// if a lead is updated to be included in the campaign
				if (newRefLeadMap.get(refLeadId).Ref_Lead_Include_in_Campaign__c && !oldRefLeadMap.get(refLeadId).Ref_Lead_Include_in_Campaign__c) {
					
					if (cs.Ref_Prospector_Campaign_Lead_Count__c != null) {
						cs.Ref_Prospector_Campaign_Lead_Count__c = cs.Ref_Prospector_Campaign_Lead_Count__c + 1;
						shouldUpdateCS = true;
					}
				}
			}
		}
		
		if (shouldUpdateCS) {
			update cs;
		}
	}
	
	/**
	 * method to update custom settings ref prospector campaign counters
	 * when reference lead records are deleted
	 * author: Gaurav Saini (1 Dec, 2017)
	 */
	public static void onAfterDelete(List<Reference_Lead__c> oldRefLeads) {
		Custom_Settings__c cs = UtilityController.getCustomSettings();
		Decimal prospectorLeadsDeleted = 0;
		Decimal campaignLeadsDeleted = 0;
		
		for (Reference_Lead__c rl : oldRefLeads) {
			
			if (!rl.Ref_Lead_From_Opportunity__c && rl.Reference_Lead_Status__c == 'Request Pending') {
				prospectorLeadsDeleted += 1;
				
				if (rl.Ref_Lead_Include_in_Campaign__c) {
					campaignLeadsDeleted += 1;
				}
			}
		}
		
		if (prospectorLeadsDeleted > 0 || campaignLeadsDeleted > 0) {
			cs.Ref_Prospector_Campaign_Lead_Count__c = cs.Ref_Prospector_Campaign_Lead_Count__c - campaignLeadsDeleted;
			cs.Ref_Prospector_Lead_Count__c = cs.Ref_Prospector_Lead_Count__c - prospectorLeadsDeleted;
			update cs;
		}
	}
}