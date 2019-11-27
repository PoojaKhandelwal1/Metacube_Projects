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
* This INfl_Batch_References class is  use to call influitive api handler to get All challenges (AKA Record Reference use in refeddge) from influitive
* and Create Record Reference User for contact if not exist. 
* This class is added as part of influitive integration.

* @Author:- Narender Singh Tanwar
* @Version:- 1.0
* @see 
*/

global with sharing class INfl_Batch_References implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{ 
     
    private Custom_Settings__c cs =null;
    private String fetchCursor = null;
    
    private InflAPIHandler apiHandler =  new InflAPIHandler();
    
    private Map<String,String> refTypeMap = new Map<String,String>();
    private Map<string,string> challengerefTypeMap;
    private Map<string,list<string>> contactAdvocateMap;
    private Map<String,Id> referenceabilityMap = null;
    private Map<String, List<Infl_EventsParser.cls_events>> inflContacEventMap = new Map<String, List<Infl_EventsParser.cls_events>>();
    //Constructor
    global INfl_Batch_References (){
        cs = UtilityController.getCustomSettings();
    }
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        List<Infl_EventsParser.cls_contacts> inflContacts = null;
        Set<String> setInflContactIds = null;
        setInflContactIds = new Set<String>();
        if(cs.Is_Influitive_Integration_Enabled__c != null && cs.Is_Influitive_Integration_Enabled__c){ 
            
            contactAdvocateMap = new map<string,list<string>>();
            challengerefTypeMap = new map<string,string>();
            
            Set<String> eventIds = new set<String>();
            Set<String> inflIdSet = new Set<String>();
            referenceabilityMap = new Map<String,Id> ();
            
            //infl contact id as key and salesforce if as value
            Map<Integer,String> inflContactCRMIDMap = new Map<Integer,String>();
            //CRM id as key and event list as value
              
            //Getting Events that have challenges 
            Infl_EventsParser eventParser = apiHandler.getChallengeEvents();
            List<Infl_EventsParser.cls_events> eventsT  = eventParser.events;
            inflContacts = eventParser.contacts;
            System.debug('Contacts ::: inflContacts :: '+inflContacts+' eventsT :::: '+eventsT.size());
            //Getting inflContact map
            for(Infl_EventsParser.cls_contacts inflContact : inflContacts){
                setInflContactIds.add(String.valueOf(inflContact.crm_contact_id));
                inflContactCRMIDMap.put(inflContact.id,inflContact.crm_contact_id);
            }

            if(eventParser != null && eventParser.events.size() > 0){ 
                eventsT.sort();
                //Getting last fetch event date
                fetchCursor = eventsT.get(eventParser.events.size()-1).created_at;
                
                for(Infl_EventsParser.cls_events event : eventParser.events){
                    if(event.params.challenge != null){
                        eventIds.add(''+event.id);
                    }
                }
                
                // Filtering Events which we have to issue reward 
                List<Reward__c> inflRewards = [Select Contact__c, Influitive_Id__c, Influitive_ID2__c From Reward__c where Influitive_ID2__c IN : eventIds and Contact__c IN : setInflContactIds LIMIT: limits.getLimitQueryRows()];
                for(Reward__c reward : inflRewards){
                    if(reward.Influitive_ID2__c != null){
                        inflIdSet.add(reward.Influitive_ID2__c);
                    }
                }
                for(Infl_EventsParser.cls_events event : eventParser.events){
                    if(!inflIdSet.contains(String.valueOf(event.id))){
                        //Creating map SALESFORCE CONTACT id as key and event list as map
                        String contactCrmId = inflContactCRMIDMap.get(event.contact_id);
                        if(!inflContacEventMap.containsKey(contactCrmId)){
                            inflContacEventMap.put(contactCrmId, new List<Infl_EventsParser.cls_events >());
                        }
                        inflContacEventMap.get(contactCrmId).add(event);
                    }
                }
            }
            //Getting referenceability
            referenceabilityMap = apiHandler.getReferenceability();
        }
        String query = 'Select Id, AccountId from Contact where Id IN : setInflContactIds';
        return Database.getQueryLocator(query);  
    }
    //Execute Method
    global void execute(Database.BatchableContext BC, List<Contact> scope){
        ConstantsController.isInfluitiveNotRunning = false;
        ConstantsController.isfromInfluitiveBatch = true;
        List < Reference_Request_Account_Contact__c > rrAccConts = new List < Reference_Request_Account_Contact__c > ();
        List < Reference_Request_Account__c > rrAccs = new List < Reference_Request_Account__c > ();
        List < Reference_Request__c > refReqList = new List < Reference_Request__c > ();
        //Create ReferenceRequest
        try{
           for(Contact con : scope){
                List<Infl_EventsParser.cls_events> eventList = inflContacEventMap.get(con.Id);
                if(eventList != null){
                    for(Infl_EventsParser.cls_events eventA : eventList){
                        refReqList.add(new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = ConstantsController.COMPLETED,Reference_Use__c = true));
                    }
                }
            }
            insert refReqList;
            integer index = 0;
            //Create ReferenceRequestAccount
            for(Contact con : scope){
                List<Infl_EventsParser.cls_events> eventList = inflContacEventMap.get(con.Id);
                if(eventList != null){
                    for(Infl_EventsParser.cls_events eventA : eventList){
                        String inflChallengeType = eventA.params.challenge.type;
                        String refId = referenceabilityMap.get(inflChallengeType);
                        if(refId == null){
                            refId = referenceabilityMap.get(ConstantsController.NON_REFEDGE_ACTIVITY_EVENT);
                        } 
                        rrAccs.add( new Reference_Request_Account__c(Influitive_Challenge_Data__c = eventA.id+'::'+eventA.points,Reference_Type_Needed__c = refId,Account__c= con.AccountId,Account_Request_Status__c =ConstantsController.COMPLETED,
                                Reference_Request__c = refReqList[index].id,Reference_Use__c = true,Process__c = ConstantsController.MANAGED,Deadline__c = system.today()));
                        index++;
                    }
                }
            }
            rrAccs = WithoutSharingHelperController.insertRRA(rrAccs);
            index = 0;
             
            //Create ReferenceRequstAccountContact 
            for(Contact con : scope){
                List<Infl_EventsParser.cls_events> eventList = inflContacEventMap.get(con.Id);
                if(eventList != null){
                    for(Infl_EventsParser.cls_events eventA : eventList){
                        String inflChallengeId = eventA.params.challenge.id;
                        String inflChallengeType = eventA.params.challenge.type;
                        String refId = referenceabilityMap.get(inflChallengeType);
                        if(refId == null){
                            refId = referenceabilityMap.get(ConstantsController.NON_REFEDGE_ACTIVITY_EVENT);
                        } 
                        rrAccConts.add(new Reference_Request_Account_Contact__c(Influitive_Challenge_Data__c = eventA.id+'::'+eventA.points,Referenceability_Type__c = refId, Reference_Request_Account__c = rrAccs[index].Id, 
                                    Activity_Date__c = system.today(),Reference_Use__c = true,Deadline__c = system.today(),influitiveId__c = inflChallengeId,
                                     Contact__c = con.Id, Contact_Request_Status__c = ConstantsController.COMPLETED));
                        index++;
                    }
                }
            }
            insert rrAccConts; 
        }catch(Exception e){
            fetchCursor = null;
            List<String> errorMessages =  new List<String>();
            System.debug('Error :::::'+e);
            errorMessages.add('Infl Batch Reference error while Creating Contact Requests : <b>line # :'+e.getLineNumber()+' Type : </b>'+ e.getTypeName()+ '<b> Message : </b>'+e.getStackTraceString());
            InflAPIAbstractHandler.sendInflExceptionEmail('INfl_Batch_Events execution error.',errorMessages);
        }
    }
    
    
    //Stop Method
    global void finish(Database.BatchableContext BC){
        if(fetchCursor != null){
            cs.Infl_Reference_Cursor__c = fetchCursor;
            update cs;
        }
    }
    
}