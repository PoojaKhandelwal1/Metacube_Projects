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
/**
 * Trigger: LeadTrigger
 * Description : LeadTrigger calls methods from this class
 * Created by: Rekha Jangir @14 April 2017
 */
public with sharing class LeadTriggerHandler {
    
    /**
     * Method called on after update of Lead
     */
    public static void onAfterUpdate(List<Lead> newLeads, List<Lead> oldLeads, Map<Id, Lead> newLeadMap) {
    	Set<String> convertedLeads = new Set<String>();
    	
    	for (Lead lead : newLeads) {
    		
    		if (lead.IsConverted) {
    			convertedLeads.add(lead.Id);
    		}
    	}
    	
    	List<Reference_Request__c> requests = WithoutSharingHelperController.getRefRequestsOfConvertedLead(convertedLeads);
    	
    	for (Reference_Request__c req : requests) {
    		req.Opportunity__c = newLeadMap.get(req.Lead__c).ConvertedOpportunityId;
    	}
    	
    	if (requests.size() > 0) {
    		WithoutSharingHelperController.updateRefRequests(requests);
    	}
    }
}