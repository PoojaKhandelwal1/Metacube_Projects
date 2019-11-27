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
 * Page :   
 * Description : 	This Infl_Member class is  use to call influitive api handler to create new member/Nominee (AKA Contact made reference program member in refeddge) 
 					in influitive. This class is added as part of influitive integration and class will called from from RBI Trigger.   
 * Last Modified By: Rajesh @Feb 9 2017
 */
public with sharing class Infl_Member {
    /**
     * Properties and variables
     */
    private static final String NAME = 'name';
    private static final String TITLE = 'title';
    private static final String EMAIL = 'email';
    private static final String SOURCE = 'source';
    private static final String COMPANY = 'company';
    private static final String SALESFORCE_ID = 'salesforce_id';
    private static final String CONTACT_ID = 'crm_contact_id'; //re #190    
    private static InflAPIHandler handler = new InflAPIHandler();
    
	public static list<Reference_Basic_Information__c> rbiList;
	public static list<Reward__c> issueRedeemRewardList;
    /**
     * Method for Influitive Members Callout
     */
    @future(callout=true)
    public static void influitiveMembersCallout(string jsonString) {  
		//deserialize the JSON to the Contact List
		list<Contact> conList = (List<Contact>)Json.deserialize(jsonString,List<Contact>.class);

        rbiList = new list<Reference_Basic_Information__c>();
		issueRedeemRewardList = new list<Reward__c>();
		 
		for (contact con : conList) {
			handleRBIReward(con.email, con.FirstName + ' ' + con.LastName, con.Account.Name, con.title, con.Id, '' + con.AccountId);
		}
		if (rbiList.Size() > 0) {
			WithoutSharingHelperController.upsertRBI(rbiList);
		}
		if (issueRedeemRewardList.Size() > 0) {
			WithoutSharingHelperController.insertRewards(issueRedeemRewardList);
		}
    }
	
	/*
		Re #1181
		To handle future call inside loop
		Modified By: Rajneesh Jan 2,2018	
	*/
	public static void handleRBIReward(String conEmail, String conName, String companyName, String conTitle, String conId, String accountId) {     
        //REF-2524
        Custom_Settings__c cs = UtilityController.getCustomSettings();   
        Boolean flag = false;
        Integer contactId = null;
        Infl_EventsParser eventParser = null;
        Map<String,String> queryParams = new Map<String,String>();
        queryParams.put(EMAIL, conEmail);
        
        //Calling get Events api to check if nominee already exist or not in influitive if exist then assign rewards.
        Infl_MemberParser member = handler.getMember(queryParams);
        
        //Get All Events if member exist in influitive
        if (member != null && member.email == conEmail) {
             eventParser = handler.getEvents(member.id + '');
             flag = true;
             contactId = member.id;
        }
        
        if (flag) {
        	decimal totalAccountPoints = 0;
            decimal totalContactPoints = 0;
            decimal totalAvailablePoints = 0;            
            //Contact exist in influitive and assigning rewards
            List<Reward__c> issueRewards = new List<Reward__c>();
            List<Reward__c> redeemRewards = new List<Reward__c>();             
            Set<String> eventIds = new Set<String>();
            Set<String> inflIdSet = new Set<String>();                        
            //Getting default referenceceability if not found for influitive events
            Map<String, Id> referenceabilityMap = handler.getReferenceability(); 
            Map<String, Infl_EventsParser.cls_events> eventMap = new Map<String, Infl_EventsParser.cls_events>();

            //REF-2412
            Set<String> eventUuids = new Set<String>();
            Map<String, Infl_EventsParser.cls_events> mapUuidEvent = new Map<String, Infl_EventsParser.cls_events>();
            Map<String,String> mapEventIdUuid = new Map<String,String>();
            Map<String,String> mapEventUuidId = new Map<String,String>();
                        
            for (Infl_EventsParser.cls_events event : eventParser.events) {
                eventIds.add('' + event.id);
                eventMap.put('' + event.id, event);
                //REF-2412
                eventUuids.add('' + event.uuid);
                mapUuidEvent.put('' + event.uuid, event);
                mapEventIdUuid.put('' + event.id, '' + event.uuid);
                mapEventUuidId.put('' + event.uuid, '' + event.id);
            }
            // Filtering Events which we have to issue reward 
            List<Reward__c> inflRewards = WithoutSharingHelperController.getRewardsForUpdateRBI(conId, eventIds);

            //REF-2412
            List<Reward__c> infl2Rewards = WithoutSharingHelperController.getRewardsForUpdateRBI(conId, eventUuids);
            inflRewards.addAll(infl2Rewards);
            
            for (Reward__c reward : inflRewards) {

                if (eventMap.containsKey(reward.Influitive_ID2__c)) {
                    eventMap.remove(reward.Influitive_ID2__c);
                    mapUuidEvent.remove(mapEventIdUuid.get(reward.Influitive_ID2__c));

                } else if (mapUuidEvent.containsKey(reward.Influitive_ID2__c)){
                    mapUuidEvent.remove(reward.Influitive_ID2__c);
                    eventMap.remove(mapEventUuidId.get(reward.Influitive_ID2__c));
                }
            }           
            //Constructing Reward list
            List<Infl_EventsParser.cls_events> eventList = eventMap.values();
                        
            if (eventList != null) {
                
                for (Infl_EventsParser.cls_events event : eventList) {
                    String referenceabilityId = referenceabilityMap.get(event.type);
                    
                    if (referenceabilityId == null) {
                        referenceabilityId = referenceabilityMap.get(ConstantsController.NON_REFEDGE_ACTIVITY_EVENT);
                    }
                    
                    if (referenceabilityId != null && referenceabilityId != '' && event.points != null) {
                        String createEventdate = event.created_at;
                        Date createdAt= null;
                        
                        if (createEventdate != null) {
                            createdAt = Date.valueOf(createEventdate);
                        }
                        Reward__c reward = null;
                        
                        if (event.points > 0) {
                            reward = new Reward__c(Account__c = accountId, Contact__c = conId, Transaction__c ='Issue', Amount__c = event.points, 
													Available_Points__c = event.points, Referenceability_Type__c = referenceabilityId, Influitive_ID2__c = '' + event.uuid, 
													RewardDate__c = createdAt); 
                            issueRewards.add(reward);
                        } else if (event.points < 0) {
                            Integer points = Integer.valueOf(event.points) * -1;
                            reward = new Reward__c(Account__c = accountId, Contact__c = conId, Transaction__c = 'Redeem', Amount__c = points, 
                            						Influitive_ID2__c = '' + event.uuid, RewardDate__c = createdAt);
                            redeemRewards.add(reward);
                        }
                    }
                }
            }
            List<Reward__c> rewardList = WithoutSharingHelperController.getContactRewardsForUpdateRBI(conId);
            
            for (Reward__c reward : rewardList) {
            	
            	if (reward.Available_Points__c != null) {
		            
		            if (reward.Transaction__c == ConstantsController.REDEEM) {
		                totalAvailablePoints -= reward.Available_Points__c;
		            } else {
		                totalAvailablePoints += reward.Available_Points__c;
		            }
            	}
                totalAccountPoints += reward.Amount__c;
                
            }
            //updating influitive id on rbi      
            List<Reference_Basic_Information__c> listRBI = WithoutSharingHelperController.getRBIsForUpdateRBI2(conId, accountId);
            
            if (listRBI.size() > 0) {
                
                for (Reference_Basic_Information__c rbi : listRBI) {
                    
                    if (rbi.Contact__c != null && rbi.Contact__c == conId) {
                        rbi.Influitive_Id__c = '' + contactId;
                        rbi.Lifetime_Points__c = totalContactPoints;
                    } else if (rbi.Contact__c == null) {
                        rbi.Lifetime_Points__c = totalAccountPoints;
                        rbi.Current_Available_Balance_Points__c = totalAvailablePoints;
                    }
                }
                rbiList.addAll(listRBI);
            }
            
            if (issueRewards.size() > 0) {
               issueRedeemRewardList.addAll(issueRewards);
            }
            
            if (redeemRewards.size() > 0) {
               issueRedeemRewardList.addAll(redeemRewards);
            }
        } else {
            // Contact does not exist in influitive, REF-2524
            
            if (cs.Create_Nominees__c) {
                Infl_MemberJSON  request = new Infl_MemberJSON();   
                request.add(EMAIL,conEmail);
                request.add(NAME,conName); 
                request.add(SOURCE,companyName);
                
                if (!String.isBlank(conTitle)) {
                    request.add(TITLE,conTitle); 
                }
                request.add(COMPANY,companyName);
                request.add(SALESFORCE_ID,conId);
                request.add(CONTACT_ID,conId); //re #190
                Infl_MemberParser memberParser = handler.createInflNominee(request); 
                //updating influitive id on rbi      
                List<Reference_Basic_Information__c> listRBI = WithoutSharingHelperController.getContactRBIsForUpdateRBI(conId);
                
                if (memberParser != null && listRBI.size() > 0) {
                    listRBI.get(0).Influitive_Id__c = '' + memberParser.Id;
                    rbiList.addAll(listRBI);
                }
            } 
        }
    }
}