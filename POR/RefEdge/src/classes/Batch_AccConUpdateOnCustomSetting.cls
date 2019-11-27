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
 * Class: CustomSettingTriggerHandler
 * Description : This Batch called from CustomSettingTriggerHandler to update Account/Contact RBI when RUL period changed 
 * Modified by: Rekha Jangir @Nov/16/2016
 */
global with sharing class Batch_AccConUpdateOnCustomSetting implements Database.Batchable < sObject > , Database.stateful {
    /**
     * Properties and variables
     */
    private string soqlQuery = '';
    private Decimal newRULPeriod;
    private Decimal newRULPeriodContact;
    private Decimal newRULActivitiesUpdate, newRULActivitiesUpdateContact;

    /**
     * Constructor
     */
    global Batch_AccConUpdateOnCustomSetting(Decimal oldRULPeriod, Decimal newRULPeriod, Decimal oldRULPeriodContact, Decimal newRULPeriodContact, Boolean isRULPeriodChanged,
        Boolean isRULPeriodChangedContact, Decimal newRULActivitiesUpdate, Decimal newRULActivitiesUpdateContact) {
        this.newRULPeriod = newRULPeriod;
        this.newRULPeriodContact = newRULPeriodContact;
        this.newRULActivitiesUpdate = newRULActivitiesUpdate;
        this.newRULActivitiesUpdateContact = newRULActivitiesUpdateContact;
        
        if (isRULPeriodChanged && isRULPeriodChangedContact) {
            soqlQuery =
            'select RUL_Period__c,Account__c,Contact__c,RUL_Activities_will_do__c, Default_Period_Completed_Uses__c from Reference_Basic_Information__c where Account__c != null and (RUL_Period__c = ' +
            oldRULPeriod + ' Or RUL_Period__c =' + oldRULPeriodContact + ' ) and Is_Referenceable__c = true and (Referenceability_Status__c = \'' +
            ConstantsController.ACTIVE + '\' or Referenceability_Status__c = \'' + ConstantsController.CAUTION + '\')';
        } else if (isRULPeriodChanged) {
            soqlQuery =
                'select RUL_Period__c,Account__c,Contact__c,RUL_Activities_will_do__c, Default_Period_Completed_Uses__c from Reference_Basic_Information__c where Account__c != null and Contact__c = null and RUL_Period__c = ' +
                oldRULPeriod + ' and Is_Referenceable__c = true and (Referenceability_Status__c = \'' + ConstantsController.ACTIVE +
                '\' or Referenceability_Status__c = \'' + ConstantsController.CAUTION + '\')';
        } else if (isRULPeriodChangedContact) {
            soqlQuery =
                'select RUL_Period__c,Account__c,Contact__c,RUL_Activities_will_do__c, Default_Period_Completed_Uses__c from Reference_Basic_Information__c where Account__c != null and Contact__c != null and RUL_Period__c = ' +
                oldRULPeriodContact + ' and Is_Referenceable__c = true and (Referenceability_Status__c = \'' + ConstantsController.ACTIVE +
                '\' or Referenceability_Status__c = \'' + ConstantsController.CAUTION + '\')';
        }
    }

    /**
     * Constructor can't be deleted from Managed package
     */
    global Batch_AccConUpdateOnCustomSetting(Decimal oldRULPeriod, Decimal newRULPeriod, Decimal oldRULPeriodContact, Decimal newRULPeriodContact, Boolean isRULPeriodChanged,
        Boolean isRULPeriodChangedContact) {
        //Constructor Depricated    
    }

    /**
     * Method to get the data to be proceesed 
     */
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(soqlQuery);
    }

    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List < Reference_Basic_Information__c > scope) {

        Set < String > accountIds = new Set < String > ();
        Set < String > contactIds = new Set < String > ();
        Date lastActivityDate, lastActivityDateContact;
        
        if (newRULPeriod != null)
            lastActivityDate = Date.Today() - Integer.valueOf(newRULPeriod);
        
        if (newRULPeriodContact != null)
            lastActivityDateContact = Date.Today() - Integer.valueOf(newRULPeriodContact);
        List < Reference_Basic_Information__c > listRBI = new List < Reference_Basic_Information__c > ();
        
        for (Reference_Basic_Information__c rbiId: scope) {
            
            if (rbiId.Account__c != null && rbiId.Contact__c != null)
                contactIds.add(rbiId.Contact__c);
            
            if (rbiId.Account__c != null && rbiId.Contact__c == null)
                accountIds.add(rbiId.Account__c);
        }
        map < Id, Account > accountMap = new map < Id, Account > ([Select Id, (Select Id, Activity_Date__c From Reference_Request_Accounts__r where 
        	CreatedDate > : lastActivityDate) from Account where Id IN: accountIds LIMIT: limits.getLimitQueryRows()]);
        map < Id, Contact > contactMap = new map < Id, Contact > ([Select Id, (Select Id, Activity_Date__c From Reference_Request_Account_Contacts__r where 
        	CreatedDate > : lastActivityDateContact) from Contact where Id IN: contactIds LIMIT: limits.getLimitQueryRows()]);
        map < String, list < Reference_Request_Account__c >> rrAccMapForDefaultCompleteUse = new map < String, list < Reference_Request_Account__c >> ();
        map < String, list < Reference_Request_Account_Contact__c >> rrAccConMapForDefaultCompleteUse = new map < String, list < Reference_Request_Account_Contact__c >> ();
        
        for (Id accId: accountMap.keySet()) {
            
            for (Reference_Request_Account__c tempObj: accountMap.get(accId).Reference_Request_Accounts__r) {
                
                if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= newRULPeriod) {
                    
                    if (!rrAccMapForDefaultCompleteUse.containsKey(accId))
                        rrAccMapForDefaultCompleteUse.put(accId, new list < Reference_Request_Account__c > ());
                    rrAccMapForDefaultCompleteUse.get(accId).add(tempObj);
                }
            }
        }
        
        for (Id conId: contactMap.keySet()) {
            
            for (Reference_Request_Account_Contact__c tempObj: contactMap.get(conId).Reference_Request_Account_Contacts__r) {
                
                if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= newRULPeriodContact) {
                    
                    if (!rrAccConMapForDefaultCompleteUse.containsKey(conId))
                        rrAccConMapForDefaultCompleteUse.put(conId, new list < Reference_Request_Account_Contact__c > ());
                    rrAccConMapForDefaultCompleteUse.get(conId).add(tempObj);
                }
            }
        }
        
        for (Reference_Basic_Information__c rbiId: scope) {
            
            if (rbiId.Account__c != null && rbiId.Contact__c != null && newRULPeriodContact != null) {
                rbiId.RUL_Period__c = newRULPeriodContact;
                rbiId.RUL_Activities_will_do__c = newRULActivitiesUpdateContact;
                
                if (rrAccConMapForDefaultCompleteUse.containsKey(rbiId.Contact__c)) {
                    rbiId.Default_Period_Completed_Uses__c = rrAccConMapForDefaultCompleteUse.get(rbiId.Contact__c).size();
                } else {
                    rbiId.Default_Period_Completed_Uses__c = 0;
                }
                listRBI.add(rbiId);
            } else if (rbiId.Account__c != null && rbiId.Contact__c == null && newRULPeriod != null) {
                rbiId.RUL_Period__c = newRULPeriod;
                rbiId.RUL_Activities_will_do__c = newRULActivitiesUpdate;
                
                if (rrAccMapForDefaultCompleteUse.containsKey(rbiId.Account__c)) {
                    rbiId.Default_Period_Completed_Uses__c = rrAccMapForDefaultCompleteUse.get(rbiId.Account__c).size();
                } else {
                    rbiId.Default_Period_Completed_Uses__c = 0;
                }
                listRBI.add(rbiId);
            }
        }
        
        if (listRBI.size() > 0)
            update listRBI;
    }

    /**
     * Method to be called after the execute
     */
    global void finish(Database.BatchableContext BC) {}
}