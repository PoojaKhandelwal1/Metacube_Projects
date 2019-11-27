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
 * Author :  Narender Singh Tanwar
 * Description:  Classe used to update rewards in respect of influitive.  
 * Last Modified By: Rajesh @Feb 6 2017
 */
public with sharing class Infl_Event {
	/**
     * Creating Handler instance
     */ 
    private static InflAPIHandler handler = new InflAPIHandler();
    public static List<Reward__c> rewardList;
    
    @future(callout=true)
    public static void influitiveEventsCallout(String jsonMapContactString, String jsonMapReferenceabilityTypeString, String jsonNewMapString, String jsonOldMapString, String jsonNewListString) {
        // List of Reward to be updated
        rewardList = new List<Reward__c>();
        //deserialize the JSON to their respective type.
        Map<Id, Contact> mapContact = (Map<Id, Contact>)Json.deserialize(jsonMapContactString, Map<Id, Contact>.class);
        Map<Id, Referenceability_Type__c> mapReferenceabilityType = (Map<Id, Referenceability_Type__c>)Json.deserialize(jsonMapReferenceabilityTypeString, Map<Id, Referenceability_Type__c>.class);
        Map<Id, Reward__c> newMap = (Map<Id, Reward__c>)Json.deserialize(jsonNewMapString, Map<Id, Reward__c>.class);
        Map<Id, Reward__c> oldMap = (Map<Id, Reward__c>)Json.deserialize(jsonOldMapString, Map<Id, Reward__c>.class);        
		List<Reward__c> newList = (List<Reward__c>)Json.deserialize(jsonNewListString, List<Reward__c>.class);
        
        for (Reward__c reward : newList) { 
             
            if (reward.Contact__c != null && mapContact != null && mapContact.size() > 0 && mapContact.containsKey(reward.Contact__c)) {
				// If Stands for After insert and Else Stands for after Update.
                if (mapContact.get(reward.Contact__c).email != null && reward.Amount__c != null && reward.Influitive_Id__c == null 
                                                                            && reward.Influitive_ID2__c == null && oldMap.Size() == 0) {
                	String defaultRefType = 'Non-Reference Activity';
                	                       
                    if (reward.Referenceability_Type__c != null) {

                        //REF-2389
                        if (mapReferenceabilityType.containsKey(reward.Referenceability_Type__c)) {
                            defaultRefType = String.valueOf(mapReferenceabilityType.get(reward.Referenceability_Type__c).Referenceability_code__c);
                        }
                    }
					
                    if(!Test.isRunningTest()) {
                    	handleRBIReward(defaultrefType, mapContact.get(reward.Contact__c).email, 
                    									(reward.Transaction__c == ConstantsController.ISSUE ? String.valueOf(reward.Amount__c) : '-' 
                    									+ String.valueOf(reward.Amount__c)), reward.Contact__c, reward, false);
                    }
                    //REF-2389
                } else if (mapContact.get(reward.Contact__c).email != null && reward.Referenceability_Type__c != null && reward.Amount__c != null && reward.Influitive_Id__c == null
								&& oldMap.Size() > 0 && reward.Influitive_ID2__c == null && mapReferenceabilityType.containskey(reward.Referenceability_Type__c)) {  
                     
                    handleRBIReward(String.valueOf(mapReferenceabilityType.get(reward.Referenceability_Type__c).Referenceability_code__c), 
                    											mapContact.get(reward.Contact__c).email, (reward.Transaction__c == ConstantsController.ISSUE 
                    											? String.valueOf(reward.Amount__c) : '-' + String.valueOf(reward.Amount__c)), reward.Contact__c, 
                    											reward, false);
                } else if (mapContact.get(reward.Contact__c).email != null && reward.Transaction__c == ConstantsController.ISSUE && oldMap.Size() > 0 
                											&& oldMap.get(reward.Id).Expired__c != newMap.get(reward.Id).Expired__c && reward.Expired__c
                                                            && reward.Influitive_Id__c != ConstantsController.ADJUSTMENT_INFL_ID) {
                    handleRBIReward('', mapContact.get(reward.Contact__c).email, '-' + String.valueOf(reward.Expired_Points__c), 
                    									reward.Contact__c, reward, true);
                } else if (mapContact.get(reward.Contact__c).email != null && reward.Transaction__c == ConstantsController.ISSUE && oldMap.Size() > 0 && 
                											oldMap.get(reward.Id).Expired__c != newMap.get(reward.Id).Expired__c && !reward.Expired__c 
                											&& reward.Expired_Points_in_influitive__c != null && reward.Expired_Points_in_influitive__c> 0
                                                            && reward.Influitive_Id__c != ConstantsController.ADJUSTMENT_INFL_ID) { //REF-1618
                    handleRBIReward('', mapContact.get(reward.Contact__c).email, String.valueOf(reward.Expired_Points_in_influitive__c), 
                    										reward.Contact__c, reward, true);
                }
            }
        } 
        
        if (rewardList.Size() > 0) {
        	update rewardList;
        }
    }
    
    /*
		Re #1181
		To handle future call inside loop
		Modified By: Rajneesh Jan 2,2018	
	*/
	public static void handleRBIReward(String reftype, String email, String points, String contactId, Reward__c reward, Boolean isExpired) {
		 
        if (isExpired) {
            reftype = 'expired_rewards';
        }
        
        //constructing Infl_EventJSON object 
        Infl_EventJSON request = new Infl_EventJSON(); 
        request.type = reftype; 
        Infl_EventJSON.cls_contact contact = new Infl_EventJSON.cls_contact();
        contact.crm_contact_id = contactId;//re #190-Added Contact Id
        contact.email = email;
        request.contact = contact;
        request.points = points;
        // Adding response to create events
        InflCreateEventResponse response = handler.createInflEvent(request);
        
        //REF-2300
        if (response != null && response.id == null) {
            request.type = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
            response = new InflCreateEventResponse();
            response = handler.createInflEvent(request);            
        }
         
        if (response != null && reward != null && response.id != null && response.id != '') {
            
            if (!isExpired) {
                reward.Influitive_ID2__c = response.id;
            }
            
            if (isExpired && points.contains('-')) {
                reward.Expired_Points_in_influitive__c = reward.Expired_Points__c;
            } else {
                reward.Expired_Points_in_influitive__c = 0;
            }
            rewardList.add(reward);
        }
	}
    
    /**
     * Method to call apiHandler to create event at influitive
     * REF-1964
     */
    public static String syncRewardAtHub(Reward__c reward, String typeCode) {
        Infl_EventJSON refJSON = new Infl_EventJSON();
        refJSON.type = typeCode;//'ref';
        refJSON.points = String.valueOf(reward.Amount__c);
        Infl_EventJSON.cls_contact cls = new Infl_EventJSON.cls_contact();
        cls.email = reward.Contact__r.Email;
        refJSON.contact = cls;
        InflCreateEventResponse response = handler.createInflEvent(refJSON);
        
        //REF-2300
        if (response != null && response.id == null) {
            refJSON.type = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
            response = new InflCreateEventResponse();
            response = handler.createInflEvent(refJSON);            
        }
        
        if (response != null && response.id != null && response.id != '') {
            return response.id;
        }
        return null;
    }
}