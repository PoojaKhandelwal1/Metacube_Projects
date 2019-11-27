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
public with sharing class ReferenceRequestTriggerHandler {
    /**
     * Properties and variables
     */
    public static list < Reference_Request__c > newReferenceRequests;
    public static list < Reference_Request__c > oldReferenceRequests;
    public static map < Id, Reference_Request__c > newReferenceRequestMap;
    public static map < Id, Reference_Request__c > oldReferenceRequestMap;
    /**
     * Method called on before insert of Reference Request
     */
    public static void onBeforeInsert() {
        
        for (Reference_Request__c refReq : newReferenceRequests) {
            
            if (refReq.Requester__c == null) {
                refReq.Requester__c = Userinfo.getUserId();
            }
        }
    }
    
    /**
     * Method called on before delete of Reference Request
     */
    public static void onBeforeDelete() {
        
        for (Reference_Request_Account__c rra : WithoutSharingHelperController.getAccountRequests2(oldReferenceRequestMap)) {
            
            for (Reward__c reward : rra.Rewards__r) {
                ConstantsController.RewardIds.add(reward.Id);
            }
            
            for (Hit_List__c hitId : rra.Hit_Lists__r) {
                ConstantsController.HitIdSet.add(hitId);
            }
        }
    }

    /**
     * Method called on after insert of Reference Request
     */
    public static void onAfterInsert() {
        list < Reference_Requests_and_Invitations__c > listNewRRI = new list < Reference_Requests_and_Invitations__c > ();
        
        for (Reference_Request__c rr : newReferenceRequests) {
            
            if (rr.Opportunity__c != null) {
                listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = rr.Opportunity__c,
                																Reference_Request__c = rr.Id));
            }
        }
        
        //Insert New RRI
        if (listNewRRI.size() > 0) {
            WithoutSharingHelperController.insertRefRequestInvi(listNewRRI);
        }
    }
    
    /**
     * Method called on after update of Reference Request
     */
    public static void onAfterUpdate() {
        list < Reference_Request_Account__c > updatedAccountRequest = new list < Reference_Request_Account__c > ();
        list < Unspecified_Request__c > updatedUnspecifiedRequest = new list < Unspecified_Request__c > ();
        
        if (ConstantsController.shouldArAndUrUpdate) {
            
            for (Reference_Request__c rrObj : WithoutSharingHelperController.getReferenceRequests1(newReferenceRequests)) {
                
                if (oldReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c != newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c) {
                    
                    if (newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == ConstantsController.IN_PROGRESS) {
                        
                        for (Reference_Request_Account__c rraObj: rrObj.Reference_Request_Accounts__r) {
                            
                            if (rraObj.Account_Request_Status__c == null
                            			|| rraObj.Account_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| rraObj.Account_Request_Status__c == ConstantsController.ONHOLD) {
                                
                                rraObj.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                                updatedAccountRequest.add(rraObj);
                            }
                        }
                        
                        for (Unspecified_Request__c urObj : rrObj.Unspecified_Requests__r) {
                            
                            if (urObj.Unspecified_Request_Status__c == null
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.ONHOLD) {
                                
                                urObj.Unspecified_Request_Status__c = ConstantsController.IN_PROGRESS;
                                updatedUnspecifiedRequest.add(urObj);
                            }
                        }
                    } else if (newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == ConstantsController.ONHOLD) {
                        
                        for (Reference_Request_Account__c rraObj : rrObj.Reference_Request_Accounts__r) {
                            
                            if (rraObj.Account_Request_Status__c == null
                            			|| rraObj.Account_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| rraObj.Account_Request_Status__c == ConstantsController.IN_PROGRESS) {
                                
                                rraObj.Account_Request_Status__c = ConstantsController.ONHOLD;
                                updatedAccountRequest.add(rraObj);
                            }
                        }
                        
                        for (Unspecified_Request__c urObj : rrObj.Unspecified_Requests__r) {
                            
                            if (urObj.Unspecified_Request_Status__c == null
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.IN_PROGRESS) {
                                
                                urObj.Unspecified_Request_Status__c = ConstantsController.ONHOLD;
                                updatedUnspecifiedRequest.add(urObj);
                            }
                        }
                    } else if (newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == 'Give Up - Legal Won\'t Approve'
                    			|| newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == 'Give Up - Service Issues'
                    			|| newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == 'Give Up - Contact Left Company'
                    			|| newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == 'Give Up - Contact Unresponsive') {
                        
                        for (Reference_Request_Account__c rraObj : rrObj.Reference_Request_Accounts__r) {
                            
                            if (rraObj.Account_Request_Status__c == ConstantsController.COMPLETED) {
                                newReferenceRequestMap.get(rrObj.Id).addError(System.Label.CANNOT_SET_COMPLETED_REQUEST_TO_GIVEUP);
                            } else if (rraObj.Account_Request_Status__c == null
                            			|| rraObj.Account_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| rraObj.Account_Request_Status__c == ConstantsController.IN_PROGRESS
                            			|| rraObj.Account_Request_Status__c == ConstantsController.ONHOLD) {
                                
                                rraObj.Account_Request_Status__c = newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c;
                                rraObj.Project_Owner__c = UserInfo.getUserId();
                                updatedAccountRequest.add(rraObj);
                            }
                        }
                        
                        for (Unspecified_Request__c urObj : rrObj.Unspecified_Requests__r) {
                            
                            if (urObj.Unspecified_Request_Status__c == null
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.IN_PROGRESS
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.ONHOLD) {
                                
                                urObj.Unspecified_Request_Status__c = ConstantsController.NO_LONGER_NEEDED;
                                urObj.Project_Owner__c = UserInfo.getUserId();
                                updatedUnspecifiedRequest.add(urObj);
                            }
                        }
                    } else if (newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == ConstantsController.COMPLETED) {
                        
                        for (Reference_Request_Account__c rraObj : rrObj.Reference_Request_Accounts__r) {
                            
                            if (rraObj.Account_Request_Status__c == null
                            			|| rraObj.Account_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| rraObj.Account_Request_Status__c == ConstantsController.IN_PROGRESS
                            			|| rraObj.Account_Request_Status__c == ConstantsController.ONHOLD) {
                                
                                rraObj.Account_Request_Status__c = ConstantsController.COMPLETED;
                                rraObj.Project_Owner__c = UserInfo.getUserId();
                                updatedAccountRequest.add(rraObj);
                            }
                        }
                        
                        for (Unspecified_Request__c urObj : rrObj.Unspecified_Requests__r) {
                            
                            if (urObj.Unspecified_Request_Status__c == null
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.IN_PROGRESS
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.ONHOLD) {
                                
                                urObj.Unspecified_Request_Status__c = ConstantsController.NO_LONGER_NEEDED;
                                urObj.Project_Owner__c = UserInfo.getUserId();
                                updatedUnspecifiedRequest.add(urObj);
                            }
                        }
                    } else if (newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c == ConstantsController.NO_LONGER_NEEDED) {
                        
                        for (Reference_Request_Account__c rraObj : rrObj.Reference_Request_Accounts__r) {
                            
                            if (rraObj.Account_Request_Status__c == null
                            			|| rraObj.Account_Request_Status__c == ConstantsController.COMPLETED
                            			|| rraObj.Account_Request_Status__c == 'Give Up - Legal Won\'t Approve'
                            			|| rraObj.Account_Request_Status__c == 'Give Up - Service Issues'
                            			|| rraObj.Account_Request_Status__c == 'Give Up - Contact Left Company'
                            			|| rraObj.Account_Request_Status__c == 'Give Up - Contact Unresponsive') {
                                
                                newReferenceRequestMap.get(rrObj.Id).addError(System.Label.CANNOT_SET_COMPLETED_REQUEST_TO_NO_LONGER_NEEDED);
                            } else if (rraObj.Account_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| rraObj.Account_Request_Status__c == ConstantsController.IN_PROGRESS
                            			|| rraObj.Account_Request_Status__c == ConstantsController.ONHOLD) {
                				
                                rraObj.Account_Request_Status__c = newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c;
                                rraObj.Project_Owner__c = UserInfo.getUserId();
                                updatedAccountRequest.add(rraObj);
                            }
                        }
                        
                        for (Unspecified_Request__c urObj : rrObj.Unspecified_Requests__r) {
                            
                            if (urObj.Unspecified_Request_Status__c == null
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.NOT_STARTED
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.IN_PROGRESS
                            			|| urObj.Unspecified_Request_Status__c == ConstantsController.ONHOLD) {
                                
                                urObj.Unspecified_Request_Status__c = newReferenceRequestMap.get(rrObj.Id).Reference_Request_Status__c;
                                urObj.Project_Owner__c = UserInfo.getUserId();
                                updatedUnspecifiedRequest.add(urObj);
                            }
                        }
                    }
                }
            }
            
            if (updatedAccountRequest.size() > 0) {
                WithoutSharingHelperController.updateRRA(updatedAccountRequest);
            }
            
            if (updatedUnspecifiedRequest.size() > 0) {
                WithoutSharingHelperController.updateUnspecified(updatedUnspecifiedRequest);
            }
        }

        /** New RR & Invitaion Combined Object : 09 June**/
        list<Reference_Requests_and_Invitations__c> listNewRRI = new list<Reference_Requests_and_Invitations__c>();
        set<Id> oldInvitationIds = new set<Id>();
        
        for (Reference_Request__c rr : newReferenceRequests) {
            
            if (newReferenceRequestMap.get(rr.Id).Opportunity__c != oldReferenceRequestMap.get(rr.Id).Opportunity__c) {
                
                if (newReferenceRequestMap.get(rr.Id).Opportunity__c != null) {
                    listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = rr.Opportunity__c,
                    																Reference_Request__c = rr.Id));
                }
                
                if (oldReferenceRequestMap.get(rr.Id).Opportunity__c != null) {
                    oldInvitationIds.add(rr.Id);
                }
            }
        }
        
        //Delete old RRI    
        list<Reference_Requests_and_Invitations__c> listOldRRI = WithoutSharingHelperController.getRefRequestInvitations(oldInvitationIds);
        
        if (listOldRRI.size() > 0) {
            WithoutSharingHelperController.deleteRefRequestInvitations(listOldRRI);
        }

        //Insert New RRI
        if (listNewRRI.size() > 0) {
            WithoutSharingHelperController.insertRefRequestInvi(listNewRRI);
        }
    }
    
    /**
     * Method called on after delete of Reference Request
     */
    public static void onAfterDelete() {
        
        if (ConstantsController.RewardIds != null && ConstantsController.RewardIds.size() > 0) {
            list < Reward__c > deleteRewardList = WithoutSharingHelperController.getRewardList(ConstantsController.RewardIds);
            
            if (deleteRewardList != null && deleteRewardList.size() > 0) {
                WithoutSharingHelperController.deleteRewards(deleteRewardList); 
            }
        }
        
        if (ConstantsController.HitIdSet != null && ConstantsController.HitIdSet.size() > 0) {
            list<Hit_List__c> deleteHitList = WithoutSharingHelperController.getHitLists(ConstantsController.HitIdSet);
            
            if (deleteHitList != null && deleteHitList.size() > 0) {
                WithoutSharingHelperController.deleteHitListsForUpdateRBI(deleteHitList);
            }
        }
        
        //Delete old RRI
        List<Reference_Requests_and_Invitations__c> listOldRRI = WithoutSharingHelperController.getRRIList();
        
        if (listOldRRI.size() > 0) {
            WithoutSharingHelperController.deleteRefRequestInvitations(listOldRRI);
        }
    }
    
    /**
     * Method called on after undelete of Reference Request
     */
    public static void onAfterUndelete() {
        list < Reference_Requests_and_Invitations__c > listNewRRI = new list < Reference_Requests_and_Invitations__c > ();
        list < Reference_Requests_and_Invitations__c > deleteRRI = new list < Reference_Requests_and_Invitations__c > ();
        set < Id > rrIds = new set < Id > ();
        for (Reference_Request__c rr: newReferenceRequests) {
            if (rr.Opportunity__c != null) {
                rrIds.add(rr.Id);
            }
        }

        for (Reference_Request__c rr: [SELECT Id, Opportunity__c, (Select Id, Opportunity__c From Reference_Requests_and_Invitations__r order by CreatedDate DESC) FROM Reference_Request__c WHERE Id IN: rrIds]) {
            Integer countRRI = 0;
            for (Reference_Requests_and_Invitations__c rri: rr.Reference_Requests_and_Invitations__r) {
                countRRI++;
                if (countRRI != 1) {
                    deleteRRI.add(rri);
                }
            }
            if (countRRI == 0)
                listNewRRI.add(new Reference_Requests_and_Invitations__c(Opportunity__c = rr.Opportunity__c, Reference_Request__c = rr.Id));
        }

        //Insert New RRI
        if (listNewRRI.size() > 0)
            insert listNewRRI;

        //Delete RRI
        if (deleteRRI.size() > 0)
            delete deleteRRI;
    }
}