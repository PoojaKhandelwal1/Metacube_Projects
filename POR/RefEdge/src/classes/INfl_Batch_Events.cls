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
* Description: This INfl_Batch_Events class is  use to call influitive api handler to get All Events (AKA Rewards in refeddge) from influitive
* and issue reward to contact if not exist. 
* This class is added as part of influitive integration.
* Created By: Narender Singh Tanwar
*/
global with sharing class INfl_Batch_Events implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts { 
    private Map<String, String> contactEventMap;
    private Map<Integer, String> contactMap;
    private Map<String, String> refTypeMap = new Map<String, String>();
    private Map<String, String> reverseRefTypeMap = new Map<String, String>();
    private Map<String, List<Infl_EventsParser.cls_events>> mapIds = new Map<String, List<Infl_EventsParser.cls_events>>();
    
    /* This set contains rewards which failed to post in influitive*/
    private Set<String> rewardFailedToPost = null;
    private Set<String> setContactId ;
    
    private List<Infl_EventsParser.cls_events> issueEvents =  null;
    private List<String> errorMessages = null;
    
    private Integer totalRewardsToPost = 0;
    private Integer postedRewards = 0;
    
    private String lastFetchEventTimeStamp = '';
    
    private Custom_Settings__c cs = null;
    
    private final InflAPIHandler apiHandler = new InflAPIHandler();
    private Set<String> infDiscardlIds;
    
    /*
     * Constructor
     */
    public INfl_Batch_Events () {
        cs = UtilityController.getCustomSettings();
        errorMessages = new List<String>();
    }
    
    /*
     * Start Method
     */
    public Database.QueryLocator start(Database.BatchableContext BC) {
        setContactId = new Set<String>();
        infDiscardlIds = new Set<String>();
        infDiscardlIds.add(ConstantsController.ADJUSTMENT_INFL_ID);

        if (cs.Is_Influitive_Integration_Enabled__c != null && cs.Is_Influitive_Integration_Enabled__c) {
            
            try {  
                Infl_EventsParser eventParser = apiHandler.getEvents(null);
                Set<String> eventIds = new Set<String>();
    
                if (eventParser != null && !eventParser.events.isEmpty()) {       
                	postedRewards += eventParser.apiCalls;
                    List<Infl_EventsParser.cls_events> eventsT  = eventParser.events;
                    eventsT.sort();
                    lastFetchEventTimeStamp = eventsT.get(eventParser.events.size()-1).created_at;
                    contactMap = new Map<Integer,String>();
                    
                    for (Infl_EventsParser.cls_contacts con : eventParser.contacts) {
                        
                        if (con.crm_contact_id != null && con.crm_contact_id != '') {
                            contactMap.put(con.id, con.crm_contact_id);
                            setContactId.add(con.crm_contact_id);
                        }
                    }
                    
                    for (Infl_EventsParser.cls_events event : eventParser.events) {
                        eventIds.add(''+event.id);
                    }
                    List<Referenceability_Type__c> refceabilitys = [SELECT Name, Id, Referenceability_code__c 
                                                    FROM Referenceability_Type__c LIMIT :limits.getLimitQueryRows()];
                    
                    for (Referenceability_Type__c refceability : refceabilitys) {
                        refTypeMap.put(refceability.id,refceability.Referenceability_code__c);
                        reverseRefTypeMap.put(refceability.Referenceability_code__c, refceability.id);
                    }
                    Set<String> inflIdSet = new Set<String>();
                    // Filtering Events which we have to issue reward 
                    List<Reward__c> inflRewards = [SELECT Contact__c, Influitive_Id__c, Influitive_ID2__c FROM Reward__c WHERE Influitive_ID2__c IN :eventIds 
                                                  AND Contact__c IN : setContactId LIMIT :limits.getLimitQueryRows()];
                    
                    for (Reward__c reward : inflRewards) {
                        
                        if (reward.Influitive_ID2__c != null) {
                            inflIdSet.add(reward.Influitive_ID2__c);
                        }
                    }
                    
                    for (Infl_EventsParser.cls_events event : eventParser.events) {
                        
                        if (!inflIdSet.contains(String.valueOf(event.id)) && event.type != ConstantsController.EXPIRED_REWARD_EVENT && event.points != 0) {
                            String contactCrmId = contactMap.get(event.contact_id);
                            
                            // checking if contact exist in salesforce
                            if (contactCrmId != '') {
                                
                                if (!mapIds.containsKey(contactCrmId)) {
                                    mapIds.put(contactCrmId, new List<Infl_EventsParser.cls_events>());
                                }
                                mapIds.get(contactCrmId).add(event);
                            }
                        }
                    }
                }   
             
            } catch(Exception e) {
                System.debug('Error : ' + e.getMessage() + ' Error on Line : ' + e.getLineNumber());
                errorMessages.add('Infl Batch Event error while Getting Batch Data : <b>line # :' + e.getLineNumber() + ' Type : </b>' 
                                + e.getTypeName() + '<b> Message : </b>' + e.getStackTraceString());
            }        
        }
      
        
       
        String query = 'SELECT Id, Email, AccountId, (SELECT Influitive_Id__c, Influitive_ID2__c, Available_Points__c, Expired_Points_in_influitive__c, Transaction__c, ' 
                            + 'Referenceability_Type__c, Expired_Points__c, Expired__c, Contact__c, Id, Amount__c FROM Rewards__r WHERE ' 
                            + ' (Expired__c = true OR Influitive_ID2__c = null OR Expired_Points_in_Influitive__c > 0) AND Influitive_ID2__c NOT IN :infDiscardlIds  LIMIT 150 ) '
                            + 'FROM Contact WHERE Id IN : setContactId LIMIT 150';

        return Database.getQueryLocator(query);  
    }
    
    /*
     * Execute Method
     */
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
        List<Reward__c> issueRewards = new List<Reward__c>();
        List<Reward__c> redeemRewards = new List<Reward__c>();
        try {
            contactEventMap = new Map<String, String>();
            
            //Insert reward to refedge for events we get from Influitive.
            for (Contact contact : scope) {
                
                if (contact.email != null) {
                    contactEventMap.put(contact.id, contact.email);
                }
               
                if (setContactId.contains(contact.Id)) {
                    
                    if (mapIds != null && mapIds.size() > 0 && mapIds.containsKey(contact.Id)) {
                        
                        //Adding rewards to refedge   
                        for (Infl_EventsParser.cls_events event : mapIds.get(contact.Id)) {
                            //Getting Referenceability_Type__c id
                            String accountId = contact.AccountId;
                            String referenceabilityId =  reverseRefTypeMap.get(event.type);  
                            
                            if (referenceabilityId == null && accountId != null) {
                                referenceabilityId = reverseRefTypeMap.get(ConstantsController.NON_REFEDGE_ACTIVITY_EVENT);
                            }
                            
                            if (referenceabilityId!= null && referenceabilityId != '' && event.points != null) {
                                String createEventdate = event.created_at;
                                Date createdAt= null;
                                
                                if (createEventdate != null) {
                                    createdAt = Date.valueOf(createEventdate);
                                }
                                String crmContactId = contactMap.get(event.contact_id);
                                Reward__c reward = null;
                               
                                if (event.points > 0) { 
                                    reward = new Reward__c(Account__c = accountId, Contact__c = crmContactId,
                                                           Transaction__c ='Issue', Amount__c = event.points, 
                                                           Available_Points__c = event.points, Referenceability_Type__c = referenceabilityId,
                                                           Influitive_ID2__c = '' + event.id, RewardDate__c = createdAt); 
                                    issueRewards.add(reward);
                                } else if (event.points < 0) {
                                    Integer points = Integer.valueOf(event.points)*-1;
                                    reward = new Reward__c(Account__c = accountId, Contact__c = crmContactId, Transaction__c = 'Redeem', 
                                                            Amount__c = points, Influitive_ID2__c = '' + event.id, RewardDate__c = createdAt);
                                    redeemRewards.add(reward);
                                }
                            }
                        }
                    }
                }
            }
            
            if (issueRewards.size() > 0) {
                insert issueRewards;
            }
            
            if (redeemRewards.size() > 0) {
                insert redeemRewards;        
            }
             
        } catch(Exception e) {
            System.debug('Infl Batch Event error while insert infl events as reward in refedge :' + e.getMessage() + ' Error on Line : ' +  e.getMessage());
            errorMessages.add('Infl_Batch_Events error while insert infl events as reward in refedge : <b>line # :' + e.getLineNumber() 
                                        + ' Type : </b>' + e.getTypeName() + '<b> Message : </b>' + e.getMessage());
        }
        //post reward to influitive
        
        try {
            List<Reward__c> inflRewards = postToInfluitive(scope);
            
            //updating rewards
            if (inflRewards != null && !inflRewards.isEmpty()) {
                update inflRewards;
            }
            
        } catch(Exception e) {
            System.debug('Infl Batch Event error while posting reward to infuitive : ' + e.getMessage() + ' Error on Line : ' + e.getLineNumber());
            errorMessages.add('Infl_Batch_Events error while posting reward to infuitive : <b>ERROR :</b>' + e.getMessage());
        }
        
        ConstantsController.isInfluitiveNotRunning = false;
    }

    /*
     * Finish Method
     */
    public void finish(Database.BatchableContext BC) {  
        //sending email if any error appear while execution
        sendErrorEmail();
        Integer rewardNeedToPost = totalRewardsToPost - postedRewards;
        cs.Infl_Event_Fetch_DateTime__c = lastFetchEventTimeStamp;
        update cs; 
        
        //Checking if any reward are left for post to influitive, if any records are found execute same batch again.
        if ((rewardFailedToPost != null && rewardFailedToPost.isEmpty()) || rewardNeedToPost > 0) {
            Boolean isRunAgain = false;
            List<Contact> scope = Database.query('SELECT Id, Email, AccountId, (SELECT Influitive_Id__c, Influitive_ID2__c Available_Points__c, Expired_Points_in_influitive__c,'
                                                + 'Transaction__c, Referenceability_Type__c, Expired_Points__c, Expired__c, Contact__c, Id, Amount__c ' 
                                                + 'FROM Rewards__r WHERE (Expired__c = true OR Influitive_ID2__c = null OR Expired_Points_in_Influitive__c > 0) ' 
                                                + 'AND ID NOT IN : rewardFailedToPost ) FROM Contact WHERE Id IN : setContactId');
            
            for (Contact contact : scope) {
                
                if (contact.Rewards__r.size() > 0) {
                    
                    for (Reward__c reward : contact.Rewards__r) {
                        isRunAgain = true;
                        break;
                    }
                }
            }
            
            if (isRunAgain) {
                Database.executebatch(new INfl_Batch_Events(),1);
            }
        }
        
    }
    
    /*
     * This method is use to post reward to influitive which are not exist in there.
     */
    private List<Reward__c> postToInfluitive(List<Contact> scope) { 
        List<Reward__c> inflRewards = new List<Reward__c>();
        rewardFailedToPost = new Set<String>();
        Integer callOuts = 0;
        
        for (Contact contact : scope) {
            List<Reward__c> rewards = contact.Rewards__r;
            
            if (!rewards.isEmpty()) {
                
                for (Reward__c reward : rewards) {
                    String refType = refTypeMap.get(reward.Referenceability_Type__c);
                    
                    if (refType != null) {
                       totalRewardsToPost++; 
                    }
                }
             }
        }
        
        for (Contact contact : scope) {
            
            if (postedRewards == 99) {
                break;
            }
            List<Reward__c> rewards = contact.Rewards__r;
            
            if (rewards != null && !rewards.isEmpty()) {
                
                for (Reward__c reward : rewards) { 
                    postedRewards++;
                    
                    if (postedRewards == 99) {
                        break;
                    }
                    String refType = refTypeMap.get(reward.Referenceability_Type__c);
                    boolean expireInfl  = (reward.Expired_Points_in_influitive__c != null && reward.Expired_Points_in_influitive__c > 0) ? true : false;
                    
                    //in case redeem refType will come null so adding default Non-Reference Activity ref type.
                    if (reward.Transaction__c == ConstantsController.REDEEM) {
                        refType = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
                    }
                    String contactId = reward.Contact__c;
                    String rewardId = reward.Id;
                    //checking if reward are expired in both refedge and influitive side then no need to post event.
                    boolean flag = !((expireInfl == true || reward.Expired__c == true) && (expireInfl == true && reward.Expired__c == true));
                    
                    //Ignore reward which have no referenceability_code mapped to referenceability
                    if (refType == null) {
                        rewardFailedToPost.add(reward.id);
                    }
                    
                    if (refType != null && flag) {
                        //Constructing Infl_EventJSON object
                        Infl_EventJSON request = new Infl_EventJSON(); 
                        request.type = refType;
                        //Contact
                        Infl_EventJSON.cls_contact inflcontact = new Infl_EventJSON.cls_contact ();
                        inflcontact.email = contactEventMap.get(contactId);
                        inflcontact.crm_contact_id = contactId;//re #190 
                        request.contact = inflcontact;
                        InflCreateEventResponse response = null;
                        
                        if (reward.Transaction__c == ConstantsController.ISSUE && reward.Influitive_ID2__c == null) {
                            //if no influitive id
                            request.points = String.valueOf(reward.Amount__c);
                            response = apiHandler.createInflEvent(request);
                            
                            //REF-2300
                            if (response != null && response.id == null) {
                                request.type = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
                                response = new InflCreateEventResponse();
                                response = apiHandler.createInflEvent(request);            
                            }
                            
                            if (reward.Expired__c) {
                                refType = ConstantsController.EXPIRED_REWARD_EVENT;
                                request.type = refType;
                                request.points = '-' + String.valueOf(reward.Expired_Points__c );
                                apiHandler.createInflEvent(request); 
                            }
                        } else if (reward.Transaction__c == ConstantsController.REDEEM) {
                            request.points = '-' + String.valueOf(reward.Amount__c );
                            response = apiHandler.createInflEvent(request); 
                        } else if (reward.Expired__c) {
                            refType = ConstantsController.EXPIRED_REWARD_EVENT;
                            request.type = refType;
                            //if reward was expired so reedeem this reward in influitive and posting negative event
                            request.points = '-' + String.valueOf(reward.Expired_Points__c );
                            response = apiHandler.createInflEvent(request); 
                        } else if (!reward.Expired__c && expireInfl) {
                            refType = ConstantsController.EXPIRED_REWARD_EVENT;
                            request.type = refType;
                            //if reward not expired but expired on influitive
                            request.points = String.valueOf(reward.Expired_Points_in_influitive__c);
                            response = apiHandler.createInflEvent(request); 
                        } else if (!reward.Expired__c) {
                            //if reward not expired
                            request.points = String.valueOf(reward.Available_Points__c);
                            response = apiHandler.createInflEvent(request);
                            
                            //REF-2300
                            if (response != null && response.id == null) {
                                request.type = ConstantsController.NON_REFEDGE_ACTIVITY_EVENT;
                                response = new InflCreateEventResponse();
                                response = apiHandler.createInflEvent(request);           
                            }
                        }
                        
                        //Checking if any reward get failed to post in influitive REF-2300
                        if (response == null && (response.id == null || response.id == '')) {
                            rewardFailedToPost.add(reward.id);
                        }
                        
                        //Update influitive id on reward if reward expired no need to update
                        if (response != null && response.id != null && response.id != '') {
                            
                            if (reward.Influitive_ID2__c == null) {
                                reward.Influitive_ID2__c = response.id;
                            }
                            
                            if (reward.Expired__c == true) {
                                reward.Expired_Points_in_influitive__c = reward.Expired_Points__c ;
                            } else {
                                reward.Expired_Points_in_influitive__c = 0;
                            }
                            inflRewards.add(reward);
                        }
                    }
                } 
            }
        } 
        return inflRewards;
    }
    /**
     * Send Mail when any error happen while posting event in influitive or while insert reward in refedge
     */
    private void sendErrorEmail() {
        
        if (errorMessages != null && !errorMessages.isEmpty()) { 
            InflAPIAbstractHandler.sendInflExceptionEmail('INfl_Batch_Events execution error.', errorMessages);
        } else { 
        	List<String> errorMessages =  new List<String>();  
        	InflAPIAbstractHandler.sendInflExceptionEmail('INfl_Batch_Events Successfully Executed.', errorMessages);
        }
    }
}