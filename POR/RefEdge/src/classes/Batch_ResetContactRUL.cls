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
 * Class: Schedular_ResetContactRUL
 * Description : This Batch called from Schedular_ResetContactRUL to update RUL settings on Contact Reference Profiles
 * Modified by: Rekha Jangir @Nov/18/2016 
 * Depricated (FOR REF-1912)
 */
global with sharing class Batch_ResetContactRUL implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     
    private Date oneDayAfterDate = Date.Today() - 1;
    private Decimal defaultRULPeriod = UtilityController.getCustomSettings().RUL_Period_Contact__c;
    private Date lastActivityDate = Date.Today() - (defaultRULPeriod != null ? Integer.valueOf(defaultRULPeriod) : 0);
    private list < String > listOfFailedRecords = new list < String > ();
	*/
    /**
     * Constructor
     */
    global Batch_ResetContactRUL() {}

    /**
     * Method to get the data to be proceesed   
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        /*
	    set < string > setContact = new set < string > ();
        
        for (Reference_Basic_Information__c rbiObject: [select Contact__c, RUL_Limit_Reached__c, RUL_Last_Activity_Date__c, RUL_Activities_will_do__c,
                RUL_Period__c, RUL_Date_Available__c, Account_Level_RUL__c, RUL_Activities_used__c, Default_Period_Completed_Uses__c,
                Is_Contact_Limit_Reached__c, Account__c FROM Reference_Basic_Information__c WHERE Is_Referenceable__c = true and Referenceability_Status__c !=
                null and contact__c != null LIMIT: limits.getLimitQueryRows()
            ]) {
            setContact.add(rbiObject.Contact__c);
        }

        //Query for REference Request Accouts
        String soqlQuery =
            'SELECT AccountId, LastName, (SELECT Id, Activity_Date__c FROM Reference_Request_Account_Contacts__r WHERE Contact_Request_Status__c = \'' +
            ConstantsController.COMPLETED + '\') FROM Contact';
        
        if (setContact != null)
            soqlQuery += ' WHERE Id IN : setContact';
			*/
		//Query for REference Request Accouts
        String soqlQuery = 'SELECT Id, Name From Contact LIMIT 0';
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < Contact > scope) {
		/*
        decimal completedUsesCount = 0;
        set < String > setAccount = new set < String > ();
        map < Id, Reference_Basic_Information__c > rbiContact = new map < Id, Reference_Basic_Information__c > ();
        map < Id, Reference_Basic_Information__c > rbiAccount = new map < Id, Reference_Basic_Information__c > ();
        map < String, list < Reference_Request_Account_Contact__c >> rrAccConMapForDefaultCompleteUse = new map < String, list <
            Reference_Request_Account_Contact__c >> ();

        //Create Map for Updatable RBI's
        for (Reference_Basic_Information__c rbiObject: [select Contact__c, RUL_Limit_Reached__c, RUL_Last_Activity_Date__c,
                RUL_Activities_will_do__c, RUL_Period__c, RUL_Date_Available__c, Account_Level_RUL__c,
                RUL_Activities_used__c, Default_Period_Completed_Uses__c, Is_Contact_Limit_Reached__c, Account__c
                FROM Reference_Basic_Information__c
                WHERE Is_Referenceable__c = true and Referenceability_Status__c != null and contact__c != null and Contact__c In: scope
                limit: limits.getLimitQueryRows()
            ]) {

            rbiContact.put(rbiObject.Contact__c, rbiObject);
            setAccount.add(rbiObject.Account__c);
        }

        for (Reference_Basic_Information__c rbiObject: [select Account__c, RUL_Limit_Reached__c, RUL_Period__c, RUL_Activities_will_do__c,
                Account_Level_RUL__c, RUL_Last_Activity_Date__c, RUL_Date_Available__c,
                RUL_Activities_used__c, Is_Contact_Limit_Reached__c, Default_Period_Completed_Uses__c
                FROM Reference_Basic_Information__c WHERE Is_Referenceable__c = true and
                Referenceability_Status__c != null and Contact__c = null
                and Account__c In: setAccount LIMIT: limits.getLimitQueryRows()
            ]) {

            rbiAccount.put(rbiObject.account__c, rbiObject);
        }

        //Create Map with Contact & Reference_Request_Account_Contact__c
        if (rbiContact.size() > 0) {
            
            for (Contact con: scope) {
                
                for (Reference_Request_Account_Contact__c tempObj: con.Reference_Request_Account_Contacts__r) {
                    
                    if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= defaultRULPeriod) {
                        
                        if (!rrAccConMapForDefaultCompleteUse.containsKey(con.Id))
                            rrAccConMapForDefaultCompleteUse.put(con.Id, new list < Reference_Request_Account_Contact__c > ());
                        rrAccConMapForDefaultCompleteUse.get(con.Id).add(tempObj);
                    }
                }
            }
        }

        //Update RBI
        if (rbiContact.size() > 0) {
            
            for (Contact con: scope) {
                completedUsesCount = 0;
                
                if (con.AccountId != null && rbiAccount.containsKey(con.AccountId) && rbiContact.containsKey(con.Id) && rbiContact.get(con.Id).RUL_Period__c !=
                    null) {
                    
                    if (rbiAccount.get(con.AccountId).Account_Level_RUL__c && rbiAccount.get(con.AccountId).RUL_Period__c != null) {
                        date baseDate = date.today().addDays(-Integer.valueOf(rbiAccount.get(con.AccountId).RUL_Period__c));

                        for (Reference_Request_Account_Contact__c rrac: con.Reference_Request_Account_Contacts__r) {
                            
                            if (rrac.Activity_Date__c != null && rrac.Activity_Date__c > baseDate) {
                                completedUsesCount += 1;
                                
                                if (rbiContact.get(con.Id).RUL_Last_Activity_Date__c != null && rrac.Activity_Date__c > rbiContact.get(con.Id).RUL_Last_Activity_Date__c) {
                                    rbiContact.get(con.Id).RUL_Last_Activity_Date__c = rrac.Activity_Date__c;
                                }
                            }
                        }
                        rbiContact.get(con.Id).RUL_Activities_used__c = completedUsesCount;
                        
                        if (rbiContact.get(con.Id).RUL_Activities_used__c >= rbiAccount.get(con.AccountId).RUL_Activities_will_do__c) {
                            rbiContact.get(con.Id).RUL_Limit_Reached__c = true;
                            rbiAccount.get(con.AccountId).Is_Contact_Limit_Reached__c = true;
                        } else {
                            rbiContact.get(con.Id).RUL_Limit_Reached__c = false;
                            rbiAccount.get(con.AccountId).Is_Contact_Limit_Reached__c = false;
                        }
                    } else {
                        date baseDate = date.today().addDays(-Integer.valueOf(rbiContact.get(con.Id).RUL_Period__c));
                        
                        for (Reference_Request_Account_Contact__c rrac: con.Reference_Request_Account_Contacts__r) {
                            
                            if (rrac.Activity_Date__c != null && rrac.Activity_Date__c > baseDate) {
                                completedUsesCount += 1;
                                
                                if (rrac.Activity_Date__c > rbiContact.get(con.Id).RUL_Last_Activity_Date__c) {
                                    rbiContact.get(con.Id).RUL_Last_Activity_Date__c = rrac.Activity_Date__c;
                                }
                            }
                        }
                        rbiContact.get(con.Id).RUL_Activities_used__c = completedUsesCount;
                        
                        if (rbiContact.get(con.Id).RUL_Activities_used__c >= rbiContact.get(con.Id).RUL_Activities_will_do__c) {
                            rbiContact.get(con.Id).RUL_Limit_Reached__c = true;
                            rbiAccount.get(con.AccountId).Is_Contact_Limit_Reached__c = true;
                            
                            if (rbiAccount.get(con.AccountId).Account_Level_RUL__c == false) {
                                rbiAccount.get(con.AccountId).RUL_Limit_Reached__c = true;
                                
                                if (rbiAccount.get(con.AccountId).RUL_Period__c != null && rbiAccount.get(con.AccountId).RUL_Last_Activity_Date__c !=
                                    null)
                                    rbiAccount.get(con.AccountId).RUL_Date_Available__c = date.valueOf(rbiAccount.get(con.AccountId).RUL_Last_Activity_Date__c.addDays(
                                        integer.valueOf(rbiAccount.get(con.AccountId).RUL_Period__c)));
                            }
                        } else {
                            rbiContact.get(con.Id).RUL_Limit_Reached__c = false;
                            rbiAccount.get(con.AccountId).Is_Contact_Limit_Reached__c = false;
                        }
                    }
                    
                    if (rbiContact.get(con.Id).RUL_Limit_Reached__c == true) {
                        
                        if (rbiContact.get(con.Id).RUL_Period__c != null && rbiContact.get(con.Id).RUL_Last_Activity_Date__c != null)
                            rbiContact.get(con.Id).RUL_Date_Available__c = date.valueOf(rbiContact.get(con.Id).RUL_Last_Activity_Date__c.addDays(
                                integer.valueOf(rbiContact.get(con.Id).RUL_Period__c)));
                    }
                }
                
                if (rrAccConMapForDefaultCompleteUse.containsKey(con.Id)) {
                    rbiContact.get(con.Id).Default_Period_Completed_Uses__c = rrAccConMapForDefaultCompleteUse.get(con.Id).size();
                } else {
                    rbiContact.get(con.Id).Default_Period_Completed_Uses__c = 0;
                }
            }

            //Update Contacts RBI
            if (rbiContact.size() > 0) {
                ConstantsController.stopTriggerContentAccountOnMerge = true;
                Database.SaveResult[] updateContact = WithoutSharingHelperController.updateRBIFromBatch(rbiContact.values());
                ConstantsController.stopTriggerContentAccountOnMerge = false;
                
                for (Integer i = 0; i < updateContact.size(); i++) {
                    
                    if (!updateContact.get(i).isSuccess()) {
                        Database.Error error = updateContact.get(i).getErrors().get(0);
                        listOfFailedRecords.add('Contact RBI : Error RecordId - ' + rbiContact.values().get(i).Id + '\n');
                    }
                }
            }

            //Update Accounts RBI
            if (rbiAccount.size() > 0) {
                ConstantsController.stopTriggerContentAccountOnMerge = true;
                Database.SaveResult[] updateAccount = WithoutSharingHelperController.updateRBIFromBatch(rbiAccount.values());
                ConstantsController.stopTriggerContentAccountOnMerge = false;
                
                for (Integer i = 0; i < updateAccount.size(); i++) {
                    
                    if (!updateAccount.get(i).isSuccess()) {
                        Database.Error error = updateAccount.get(i).getErrors().get(0);
                        listOfFailedRecords.add('Account RBI : Error RecordId - ' + rbiAccount.values().get(i).Id + '\n');
                    }
                }
            }
        }
		*/
    }

    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
       	// UtilityController.sendEmailNotification(listOfFailedRecords, 'Batch_ResetContactRUL Failed');
    }
}