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
 * Description:API used to provide features to create Rewards and Nomination directly from Influtive, this API replacing Zaper.
 */
@RestResource(urlMapping='/v1.0/ReferenceEdge/*') 
global with sharing class InflRewardsAndNominationServices {
    /**
     *Static variables for APIs
     */
    public static String REWARDS = 'rewards';
    public static String NOMINATION = 'nominations';    
    public static String MISSING_URL = 'Request action (Rewards/Nominations) missing for the request URL.';
    public static String INTEGRATION_OFF = 'Influitive integration is disabled in Reference Edge.'; 
    public static String MISSING_CON_INFL_ID = 'Crm Contact Id or Influitive Id is missing from the request.';
    public static String CONTACT_NOT_PROGRAM_MEMBER = 'Contact is not a Reference Program Member.';
    public static Integer SUCCESS_CODE = 200;
    public static Integer FAILURE_CODE = 500;
    public static Integer BAD_REQUEST_CODE = 400; 
    public static Integer FORBIDDEN_CODE = 403; 

    /**
     * Post method to create Nomination/Reference Profile/Rewards on the basis of request
     * author: Rajesh (17 Sept, 2018) for #1842
     */
    @HttpPost 
    global static void createNomintaion() {    
        Savepoint sp = Database.setSavepoint();  
        RestResponse res = RestContext.response;
        
        
        Set<String> setContactIds = new Set<String>(); 
        Map<String,String> mapConIdAccId = new Map<String,String>();
        String emailMsg = 'Infuilitive REST API facing Error/Exception during Nomination creation.<br/><br/>Here are the details : <br/>';
        List<Database.UpsertResult> updateResults;
        ResponseWrapper resultWp;
        Integer counter = 0;
        List<NomRBIWrapper> nrw;
        List<RewardsWrapper> rewardsWrap;
 
        try {             
            RestRequest req = RestContext.request;
            String records = req.requestBody.toString();
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            String action = RestContext.request.params.get('action');
            
            if (cs.Is_Influitive_Integration_Enabled__c) {
               ConstantsController.isCallFromInfluitiveAPI = true;
              
                if (!String.isBlank(action)) {
                    try {
                        resultWp = (ResponseWrapper) JSON.deserialize(records, ResponseWrapper.class);
                    } catch (Exception e) {
                        res.responseBody = Blob.valueOf('Incorrect request body'); 
                        res.statusCode = BAD_REQUEST_CODE;
                    }
                    
                    if (action.tolowercase() == NOMINATION) {             
                        nrw = resultWp.nominations;
                        
                        if (nrw == null) {
                            res.responseBody = Blob.valueOf('request body missing for Nomination/RBI'); 
                            res.statusCode = BAD_REQUEST_CODE;
                            return;
                        } 
                    } else if (action.tolowercase() == REWARDS) {
                        rewardsWrap = resultWp.rewards;
                        
                        if (rewardsWrap == null) {
                            res.responseBody = Blob.valueOf('request body missing for Rewards'); 
                            res.statusCode = BAD_REQUEST_CODE;
                            return;
                        } 
                    } else {
                        res.responseBody = Blob.valueOf(MISSING_URL); 
                        res.statusCode = BAD_REQUEST_CODE;
                        return;
                    }
                    
                    if (action.tolowercase() == NOMINATION) {
                        
                        for (NomRBIWrapper rw : nrw) {
                            
                            if (rw.crm_contact_id != null && rw.crm_contact_id != '') {
                                setContactIds.add(rw.crm_contact_id);
                            }
                        }
                        List<Reference_Basic_Information__c> listRBI = new List<Reference_Basic_Information__c>();
                        Map<String,Reference_Basic_Information__c> mapConIdRBI = new Map<String,Reference_Basic_Information__c>();
                        
                        if (setContactIds.size() > 0) {
                            
                            for (Contact con : [SELECT Id, AccountId FROM Contact WHERE Id IN :setContactIds LIMIT :limits.getLimitQueryRows()]) {
                                mapConIdAccId.put(String.valueOf(con.Id).substring(0,15), con.AccountId);
                            }
                            listRBI = [SELECT Id, Lifetime_Points__c, Contact__c, Influitive_Id__c, Current_Available_Balance_Points__c
                                       FROM Reference_Basic_Information__c
                                       WHERE Contact__c IN :setContactIds LIMIT :limits.getLimitQueryRows()];
                        }
                        
                        if (listRBI.size() > 0) {
                            
                            for (Reference_Basic_Information__c rbi : listRBI) {
                                mapConIdRBI.put(rbi.Contact__c,rbi);
                            }
                        }
                        
                        if (!cs.Create_Advocate_Reference_Profile__c) {
                            List<Nomination__c> lstNomination = new List<Nomination__c>();

                            for (NomRBIWrapper rw : nrw) {
                                 
                                if (rw.crm_contact_id != null && rw.crm_contact_id != '' && rw.influitive_Id != null && rw.influitive_Id != '') {
                                    lstNomination.add(new Nomination__c(Account__c = (mapConIdAccId.get(rw.crm_contact_id.substring(0,15)) != null) 
                                                                        ? mapConIdAccId.get(rw.crm_contact_id.substring(0,15)) : null, 
                                                                        Contact__c = rw.crm_contact_id,
                                                                        Influitive_Id__c = rw.influitive_Id, 
                                                                        Status__c = ConstantsController.NOT_STARTED, 
                                                                        Email_Enabled__c = cs.Nomination_Email__c,
                                                                        Note__c = rw.notes));
                                    rw.isSuccess = true;
                                } else {
                                    rw.isSuccess = false;
                                    rw.result_message = MISSING_CON_INFL_ID;
                                }
                            }  

                            if (lstNomination.size() > 0) {
                                updateResults = Database.upsert(lstNomination, false); 
                            }
                            
                            if (updateResults != null) {
                                
                                for (NomRBIWrapper rw : nrw) {
                                    
                                    if (rw.isSuccess) {
                                        rw.salesforce_id = lstNomination[counter].Id; 
                                        rw.crm_account_Id = lstNomination[counter].Account__c;
                                        rw.crm_contact_id = lstNomination[counter].Contact__c;
                                        rw.available_points = mapConIdRBI.containsKey(lstNomination[counter].Contact__c) ? 
                                            (mapConIdRBI.get(lstNomination[counter].Contact__c).Current_Available_Balance_Points__c != null ? 
                                             String.valueOf(mapConIdRBI.get(lstNomination[counter].Contact__c).Current_Available_Balance_Points__c) : '0') : '0';   
                                        rw.influitive_Id = lstNomination[counter].Influitive_Id__c;
                                        rw.notes = lstNomination[counter].Note__c;
                                        rw.isSuccess = updateResults[counter].isSuccess();
                                        rw.result_message = updateResults[counter].isSuccess() ? 'Nomination successfully created. ' : getErrorDetails(updateResults[counter]);
                                        counter ++;
                                    }
                                }
                                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(nrw)));
                                res.statusCode = SUCCESS_CODE;
                            } else {
                                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(nrw)));
                                res.statusCode = BAD_REQUEST_CODE;
                            } 
                            
                        } else {
                            List<Reference_Basic_Information__c> lstRBI = new List<Reference_Basic_Information__c>();
                            
                            for (NomRBIWrapper rw : nrw) {
                                
                                if (rw.crm_contact_id != null && rw.crm_contact_id != '' && rw.influitive_Id != null && rw.influitive_Id != '') {
                                    lstRBI.add(new Reference_Basic_Information__c(Account__c = (mapConIdAccId.get(rw.crm_contact_id.substring(0,15)) != null) 
                                                                                  ? mapConIdAccId.get(rw.crm_contact_id.substring(0,15)) : null,
                                                                                  Contact__c = rw.crm_contact_id,
                                                                                  Influitive_Id__c = rw.influitive_Id,
                                                                                  Ref_Profile_Summary__c = rw.notes,
                                                                                  Is_Referenceable__c = true,
                                                                                  Referenceability_Status__c = 'Active'));
                                    rw.isSuccess = true;
                                } else {
                                    rw.isSuccess = false;
                                    rw.result_message = MISSING_CON_INFL_ID;
                                }
                            }  
                            
                            if (lstRBI.size() > 0) {
                                updateResults = Database.upsert(lstRBI, false); 
                            }
                            
                            if (updateResults != null) {
                                
                                for (NomRBIWrapper rw : nrw) {
                                    
                                    if (rw.isSuccess) {
                                        rw.salesforce_id = lstRBI[counter].Id; 
                                        rw.crm_account_Id = lstRBI[counter].Account__c;
                                        rw.crm_contact_id = lstRBI[counter].Contact__c;
                                        rw.available_points = mapConIdRBI.containsKey(lstRBI[counter].Contact__c) ? 
                                            (mapConIdRBI.get(lstRBI[counter].Contact__c).Current_Available_Balance_Points__c != null ? 
                                             String.valueOf(mapConIdRBI.get(lstRBI[counter].Contact__c).Current_Available_Balance_Points__c) : '0') : '0';   
                                        rw.influitive_Id = lstRBI[counter].Influitive_Id__c;
                                        rw.notes = lstRBI[counter].Ref_Profile_Summary__c;
                                        rw.isSuccess = updateResults[counter].isSuccess();
                                        rw.result_message = updateResults[counter].isSuccess() ? 'Reference Profile successfully created. ' : getErrorDetails(updateResults[counter]);
                                        counter ++;
                                    }
                                }
                                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(nrw)));
                                res.statusCode = SUCCESS_CODE;
                            } else {
                                res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(nrw)));
                                res.statusCode = BAD_REQUEST_CODE;
                            }
                        }
                        
                    } else if (action.tolowercase() == REWARDS) {
                        
                        for (RewardsWrapper rw : rewardsWrap) {
                            
                            if (rw.crm_contact_id != null && rw.crm_contact_id != '') {
                                setContactIds.add(rw.crm_contact_id);
                                rw.crm_contact_id = String.valueOf(rw.crm_contact_id).substring(0,15);
                            }
                        }
                        List<Reference_Basic_Information__c> listRBI = new List<Reference_Basic_Information__c>();
                        Map<String,Reference_Basic_Information__c> mapConIdRBI = new Map<String,Reference_Basic_Information__c>();
                        List<Reference_Basic_Information__c> listRBIToUpdate = new List<Reference_Basic_Information__c>();
                        
                        if (setContactIds.size() > 0) {
                            
                            for (Contact con : [SELECT Id, AccountId FROM Contact WHERE Id IN :setContactIds LIMIT :limits.getLimitQueryRows()]) {
                                mapConIdAccId.put(String.valueOf(con.Id).substring(0,15), con.AccountId);
                            }
                            listRBI = [SELECT Id, Lifetime_Points__c, Contact__c, Influitive_Id__c, Current_Available_Balance_Points__c
                                       FROM Reference_Basic_Information__c
                                       WHERE Contact__c IN :setContactIds LIMIT :limits.getLimitQueryRows()];
                        }
                        
                        if (listRBI.size() > 0) {
                            
                            for (Reference_Basic_Information__c rbi : listRBI) {
                                mapConIdRBI.put(String.valueOf(rbi.Contact__c).substring(0,15),rbi);
                            }
                        }
                        
                        Map<String,String> mapRefCodeRefId = new Map<String,String>();
                        Map<String,String> mapRefIdRefCode = new Map<String,String>();
                        // Get Reftype for ref code
                        List<Referenceability_Type__c> lstReferenceability = [SELECT Name, Id, Referenceability_code__c FROM Referenceability_Type__c 
                                                                            WHERE Referenceability_code__c != null 
                                                                            AND Visible__c = true AND Sales_Reward__c = false 
                                                                            LIMIT :limits.getLimitQueryRows()]; 
                        Boolean nonRefTypeVisibleFlag = false;
                        
                        for (Referenceability_Type__c ref : lstReferenceability) {
                            
                            if (ref.Referenceability_code__c == ConstantsController.NON_REFEDGE_ACTIVITY_EVENT) {
                                nonRefTypeVisibleFlag = true;
                            }
                            mapRefCodeRefId.put(ref.Referenceability_code__c,ref.id);
                            mapRefIdRefCode.put(ref.id,ref.Referenceability_code__c);
                        }
                        
                        if (!nonRefTypeVisibleFlag) {
                           List<Referenceability_Type__c> nonRefType = [SELECT Id, Name, Referenceability_code__c 
                                                                        FROM Referenceability_Type__c 
                                                                        WHERE Referenceability_code__c =: ConstantsController.NON_REFEDGE_ACTIVITY_EVENT];
                            
                            if (nonRefType.size() > 0) {
                                mapRefCodeRefId.put(nonRefType[0].Referenceability_code__c,nonRefType[0].id);
                                mapRefIdRefCode.put(nonRefType[0].id,nonRefType[0].Referenceability_code__c);
                            }
                        }
                        List<Reward__c> lstRewards = new List<Reward__c>();
                        Reward__c reward;
                        
                        List<String> listINFLIds = new List<String>();
                        List<Reward__c> tempListRewards = new List<Reward__c>();
						Map<String,Reward__c> mapINFLIdReward = new Map<String,Reward__c>();
                        
                        //For upserting rewards by influitveId
                        for (RewardsWrapper rw : rewardsWrap) {
                            
                            if (rw.influitive_Id != null && rw.influitive_Id != '') {
                                listINFLIds.add(rw.influitive_Id);
                            }
                        }
                        
                        if (listINFLIds.size() > 0) {
                            tempListRewards = [SELECT Id, Amount__c, Account__c, Contact__c, Transaction__c, Comments__c, Influitive_ID2__c, RewardDate__c
                                               FROM Reward__c
                                               WHERE Influitive_ID2__c IN : listINFLIds];
                        }
                        
                        if (tempListRewards.size() > 0) {
                            
                            for (Reward__c rewardInstance : tempListRewards) {
                                mapINFLIdReward.put(rewardInstance.Influitive_ID2__c,rewardInstance);
                            }
                        }
                        
                        for (RewardsWrapper rw : rewardsWrap) {
                            
                            if (rw.crm_contact_id != null && rw.crm_contact_id != '' && rw.influitive_Id != null && rw.influitive_Id != '') {
                                
                                if (mapConIdRBI.containsKey(rw.crm_contact_id)) {
                                    
                                    if (rw.points != null && rw.points != '') {
                                        try{
                                            reward = new Reward__c();
                                            
                                            //reward update
                                            if (mapINFLIdReward.containsKey(rw.influitive_Id)) {
                                                reward.Id = mapINFLIdReward.get(rw.influitive_Id).Id;
                                                reward.Amount__c = math.abs(Integer.valueOf(rw.points));
                                                reward.Transaction__c = (Decimal.valueOf(rw.points) >= 0) ? 'Issue' : 'Redeem';
                                                
                                                if (reward.Transaction__c == 'Issue') {
                                                    reward.Referenceability_Type__c = (!String.isBlank(rw.type) && mapRefCodeRefId.containsKey(rw.type)) ? 
                                                        mapRefCodeRefId.get(rw.type) : mapRefCodeRefId.get(ConstantsController.NON_REFEDGE_ACTIVITY_EVENT);  
                                                    reward.Available_Points__c = math.abs(Integer.valueOf(reward.Amount__c));
                                                } else {
                                                    reward.Referenceability_Type__c = null;
                                                    reward.Available_Points__c = null;
                                                }
                                                reward.Contact__c = mapINFLIdReward.get(rw.influitive_Id).Contact__c;
                                                reward.Account__c = mapINFLIdReward.get(rw.influitive_Id).Account__c;
                                                reward.Comments__c = (rw.comments != null || rw.comments != '') ?
                                                    rw.comments : mapINFLIdReward.get(rw.influitive_Id).Comments__c;
                                                reward.Influitive_ID2__c = rw.influitive_Id;
                                                reward.RewardDate__c = Date.today();
                                            } else {
                                                reward.Amount__c = math.abs(Integer.valueOf(rw.points));
                                                reward.Transaction__c = (Decimal.valueOf(rw.points) >= 0) ? 'Issue' : 'Redeem';
                                                
                                                if (reward.Transaction__c == 'Issue') {
                                                    reward.Referenceability_Type__c = (!String.isBlank(rw.type) && mapRefCodeRefId.containsKey(rw.type)) ? 
                                                        mapRefCodeRefId.get(rw.type) : mapRefCodeRefId.get(ConstantsController.NON_REFEDGE_ACTIVITY_EVENT);  
                                                    reward.Available_Points__c = math.abs(Integer.valueOf(reward.Amount__c));
                                                }
                                                reward.Account__c = mapConIdAccId.containsKey(rw.crm_contact_id) ? mapConIdAccId.get(rw.crm_contact_id) : null;
                                                reward.Contact__c = rw.crm_contact_id;
                                                reward.Comments__c = rw.comments;
                                                reward.Influitive_ID2__c = rw.influitive_Id;
                                                reward.RewardDate__c = Date.today();
                                            }
                                            lstRewards.add(reward);
                                            rw.isSuccess = true;
                                        } catch (Exception e) {
                                            rw.isSuccess = false;
                                            rw.result_message = 'Bad value for points';
                                        }
                                    } else {
                                        rw.isSuccess = false;
                                        rw.result_message = 'Points is required in the request.';
                                    }    
                                } else { 
                                    rw.isSuccess = false;
                                    rw.result_message = CONTACT_NOT_PROGRAM_MEMBER;
                                }
                            } else {
                                rw.isSuccess = false;
                                rw.result_message = MISSING_CON_INFL_ID;
                            }
                        }
                      
                        if (lstRewards.size() > 0) {
                            updateResults = Database.upsert(lstRewards, false); 
                        }
                        
                        if (updateResults != null) {
                            
                            for (RewardsWrapper rw : rewardsWrap) {
                                
                                if (rw.isSuccess) {
                                    rw.salesforce_id = lstRewards[counter].Id; 
                                    rw.crm_account_Id = lstRewards[counter].Account__c;
                                    rw.crm_contact_id = lstRewards[counter].Contact__c;
                                    rw.influitive_Id = lstRewards[counter].Influitive_ID2__c;
                                    rw.type = mapRefIdRefCode.get(lstRewards[counter].Referenceability_Type__c); 
                                    rw.points = String.valueof(lstRewards[counter].Amount__c);  
                                    rw.comments = lstRewards[counter].Comments__c;
                                    rw.available_points = updateRBIAvailablePoints(lstRewards[counter]);
                                    rw.isSuccess = updateResults[counter].isSuccess();
                                    rw.result_message = !updateResults[counter].isSuccess() ? getErrorDetails(updateResults[counter]) :
                                    (lstRewards[counter].Transaction__c == 'Issue') ? 'Points have been issued successfully' : 'Points have been redeemed successfully';
                                    counter ++;
                                }
                            }
                            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(rewardsWrap)));
                            res.statusCode = SUCCESS_CODE;
                        } else {
                            res.responseBody = Blob.valueOf(JSON.serialize(new ResponseWrapper(rewardsWrap)));
                            res.statusCode = BAD_REQUEST_CODE;
                        }
                    }  
                } else {
                    res.responseBody = Blob.valueOf('Please provide API action in the URL.'); 
                    res.statusCode = BAD_REQUEST_CODE;
                } 
            } else {
                res.responseBody = Blob.valueOf(INTEGRATION_OFF); 
                res.statusCode = FORBIDDEN_CODE;
            }
        } catch(exception ex) {  
            Database.rollback(sp);
            res.responseBody = Blob.valueOf(ex.getMessage());
            res.statusCode = FAILURE_CODE;
            emailMsg = emailMsg + '<br/>Error Message : ' + ex.getMessage() + '<br/>Error Line Number : ' + ex.getLineNumber() 
                                                + '<br/><p> Please do not reply to this mail.</p>'; 
            InflAPIAbstractHandler.sendInflExceptionEmail('RefEdge REST API failed for Influitive.', new List<String>{emailMsg});
        } 
    }
    
    //get error details
    public static String getErrorDetails(Database.UpsertResult error) {
        String errorMsg = '';
         
        for (Database.Error err : error.getErrors()) { 
            errorMsg += 'Error Details : ' + err.getMessage() + ' , Error fields '+ err.getFields(); 
        }
        return errorMsg;
    }
    
    //update available points on RBI
    public static String updateRBIAvailablePoints(Reward__c reward) {
        Decimal currentPoints = 0, lifetimePoints = 0;
        List<Reference_Basic_Information__c> listRBI = [SELECT Id, Lifetime_Points__c, Contact__c, Influitive_Id__c, Current_Available_Balance_Points__c
                                                        FROM Reference_Basic_Information__c
                                                        WHERE Contact__c =: reward.Contact__c LIMIT :limits.getLimitQueryRows()];
        
        if (listRBI.size() > 0) {
            List<Contact> contactWithRewards = [SELECT Id,Name,(SELECT Id, Amount__c, Transaction__c, Influitive_ID2__c FROM Rewards__r WHERE Expired__c = false)
                                                FROM Contact
                                                WHERE Id =: reward.Contact__c];
            
            if (contactWithRewards.size() > 0) {
                
                if (contactWithRewards[0].Rewards__r.size() > 0) {
                    
                    for (Reward__c rewardInstance : contactWithRewards[0].Rewards__r) {
                        
                        if (rewardInstance.Transaction__c == 'Issue') {
                            currentPoints = currentPoints + rewardInstance.Amount__c;
                            lifetimePoints = lifetimePoints + rewardInstance.Amount__c;
                            
                        } else if (rewardInstance.Transaction__c == 'Redeem') {
                            currentPoints = currentPoints - rewardInstance.Amount__c;
                        }
                    }
                }
            }
            listRBI[0].Current_Available_Balance_Points__c = currentPoints;
            listRBI[0].Lifetime_Points__c = lifetimePoints;
            update listRBI;
        }
        return String.valueOf(currentPoints);        
    }

    public class NomRBIWrapper { 
        private String salesforce_id;
        private String crm_account_Id;     
        private String crm_contact_id;
        private String available_points;
        private String influitive_Id;
        private String notes;
        private String result_message;
        private Boolean isSuccess;
        
        private NomRBIWrapper(String salesforce_id, String accountId, String crm_contact_id, String available_points, String influitive_Id,
                               String notes, Boolean isSuccess, String msg) {  
            this.salesforce_id = salesforce_id; 
            this.crm_account_Id = accountId;
            this.crm_contact_id = crm_contact_id;
            this.available_points = available_points;   
            this.influitive_Id = influitive_Id;
            this.notes = notes;
            this.result_message = msg;  
            this.isSuccess = isSuccess;
        }         
    }
    
    public class RewardsWrapper { 
        private String salesforce_id;
        private String crm_account_Id;     
        private String crm_contact_id;
        private String influitive_Id;
        private String points; 
        private String type;
        private String comments;
        private String available_points;
        private String result_message;
        private Boolean isSuccess;
        
        private RewardsWrapper(String salesforce_id, String crm_account_Id, String crm_contact_id, String influitive_Id, String type, 
                               String amount, String comments, boolean isSuccess, String result_message) {
            this.salesforce_id = salesforce_id; 
            this.crm_account_Id = crm_account_Id;   
            this.influitive_Id = influitive_Id;
            this.crm_contact_id = crm_contact_id;
            this.type = type; 
            this.points = amount;  
            this.comments = comments;
            this.result_message = result_message;
            this.isSuccess = isSuccess;
        }         
    } 

    //Response Wrapper class to handle request and response for API Request
    private class ResponseWrapper {
        private List<NomRBIWrapper> nominations;
        private List<RewardsWrapper> rewards;
        
        private ResponseWrapper(List<NomRBIWrapper> record) {
            this.nominations = record;
        }
        
        private ResponseWrapper(List<RewardsWrapper> record) {
            this.rewards = record;
        }
    }
}