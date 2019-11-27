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
 * Description : This Batch called from Schedular_ResetContactRUL to update RUL settings on Contact Reference Profiles And also on Account Reference Profile.
 * Modified by: Rajneesh Raj @Sept/25/2018
 */
 global with sharing class Batch_ResetContactRULWithAccountRBI implements Database.Batchable <sObject>, Database.stateful {
    
    /**
    * Properties and variables
    **/
    private List<String> listOfFailedRecords = new List<String>();
    private Decimal defaultRULperiodvalue = UtilityController.getCustomSettings().RUL_Period_Contact__c; 
    private Custom_Settings__c cs = UtilityController.getCustomSettings();
    private Map<String,Decimal> convertionRates;
    private Boolean convert ;
    global Batch_ResetContactRULWithAccountRBI(){
        Integer activeCount = 0;
        convertionRates = new Map<String,Decimal>();
        convert = false;
        if (Schema.getGlobalDescribe().containsKey('CurrencyType')) {
            String query = 'SELECT Id,IsActive, IsoCode, ConversionRate FROM CurrencyType WHERE ConversionRate != null';
            for (SObject ct : Database.query(query)) {
                convertionRates.put((String)ct.get('IsoCode'),(Decimal)ct.get('ConversionRate'));
                
                if ((Boolean)ct.get('IsActive')) {
                    activeCount++;
                }
            }
            if (activeCount > 1) {
                convert = true;
            }
        }
    }
    /**
    * Method to get the data to be process
    **/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        //Query for Account RBI
        String soqlQuery =  
                'SELECT RUL_Limit_Reached__c, ' + 
                 (convert ? 'CurrencyIsoCode,' : '' ) +
                'RUL_Last_Activity_Date__c,RUL_Activities_will_do__c, ACV_Influenced__c,Referenceability_Status__c,Contact__c,' + 
                'RUL_Period__c, RUL_Date_Available__c, Account_Level_RUL__c, RUL_Activities_used__c, Default_Period_Completed_Uses__c, ' + 
                'Is_Contact_Limit_Reached__c, Account__c FROM Reference_Basic_Information__c WHERE Generic_Account__c = false AND Account__c != null';
                
        return Database.getQueryLocator(soqlQuery);
    }
    
    /**
     * Method to execute the batch
     */
    global void execute(Database.BatchableContext BC, List<Reference_Basic_Information__c> scope) {
        Decimal defaultRULPeriod = UtilityController.getCustomSettings().RUL_Period_Contact__c; 
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        Map<Id,Decimal> accRBItoAmount = new Map<Id,Decimal>();
        Map<Id,Decimal> conRBItoAmount = new Map<Id,Decimal>();
        Map<Id,Set<Id>> accRBItoOpp = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> acctoConRBI = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> conRBItoOpp = new Map<Id,Set<Id>>();
        Decimal toRate = (convert) ? convertionRates.get('USD') : 1.0;
        
        Map<Id, List<Reference_Basic_Information__c>> mapOfAccIdAndConRBIList = new Map<Id, List<Reference_Basic_Information__c>>();
        Map<Id, List<Reference_Request_Account_Contact__c>> rrAccConMap = new Map<Id, List<Reference_Request_Account_Contact__c>>();
        Map<Id,Reference_Basic_Information__c> rbiUpdateList = new Map<Id,Reference_Basic_Information__c>();
        String amtField = cs.ACV_Amount_Field__c == null || cs.ACV_Amount_Field__c == '' ? 'Amount' : cs.ACV_Amount_Field__c; 
        Integer fiscalYearStartMonth = (cs.Organization_FiscalYearStartMonth__c != null && Integer.valueOf(cs.Organization_FiscalYearStartMonth__c) < 13 && Integer.valueOf(cs.Organization_FiscalYearStartMonth__c) > 0
                                        ? Integer.valueOf(cs.Organization_FiscalYearStartMonth__c) : 1);
        Date startDate = (cs.ACV_Basis__c == null || cs.ACV_Basis__c == ConstantsController.CALENDAR_YEAR || fiscalYearStartMonth == 1)
                            ? Date.newInstance(Date.Today().year(), 1, 1)
                            : (Date.Today().month() < fiscalYearStartMonth) ? Date.newInstance(Date.Today().year()-1, fiscalYearStartMonth, 1)
                            : Date.newInstance(Date.Today().year(), fiscalYearStartMonth, 1); 
        // restrict requests created in cs year slot
        //  Loop For Account Ids
        for(Reference_Basic_Information__c rbiRecord : scope) {
            if (rbiRecord.Referenceability_Status__c != ConstantsController.INACTIVE && rbiRecord.Contact__c == null) {
                accountIdSet.add(rbiRecord.Account__c);
            } 
            if (rbiRecord.Contact__c == null) {
                accRBItoOpp.put(rbiRecord.Account__c,new Set<Id>());
                accRBItoAmount.put(rbiRecord.Account__c,0);
            } else {
                conRBItoOpp.put(rbiRecord.Contact__c,new Set<Id>());
                conRBItoAmount.put(rbiRecord.Contact__c,0);
            }
        }
        Set<Id> accRBItoOppKeys = accRBItoOpp.keySet();
        if (accRBItoOppKeys.size() > 0) {

            String accQuery = 'SELECT Id, Account__c,Reference_Request__r.Opportunity__r.' + amtField + ',' +  
            (convert ? ' Reference_Request__r.Opportunity__r.CurrencyIsoCode,' : '' ) +  
            ' Reference_Request__r.Opportunity__c FROM Reference_Request_Account__c ' + 
            ' WHERE Account_Request_Status__c = \'' + ConstantsController.COMPLETED + '\'' +
            ' AND Account__c IN: accRBItoOppKeys' + 
            ' AND Reference_Request__r.Opportunity__c != null ' + 
            ' AND Reference_Request__r.Opportunity__r.CloseDate > :startDate' + 
            ' AND Reference_Request__r.Opportunity__r.StageName =\'' + cs.Opportunity_Closed_Won_Stage__c + '\'' +
            ' AND Reference_Request__r.Opportunity__r.' + amtField + ' > 0';
            for (Reference_Request_Account__c ar : Database.Query(accQuery)) {
                
                if (accRBItoOpp.containsKey(ar.Account__c) && !accRBItoOpp.get(ar.Account__c).contains(ar.Reference_Request__r.Opportunity__c)) {
                    accRBItoOpp.get(ar.Account__c).add(ar.Reference_Request__r.Opportunity__c);
                    Decimal oppAmount = (Decimal) ar.getSobject('Reference_Request__r').getSobject('Opportunity__r').get(amtField);
                    if (!convert || (String) ar.getSobject('Reference_Request__r').getSobject('Opportunity__r').get('CurrencyIsoCode') == 'USD') {
                        accRBItoAmount.put(ar.Account__c,accRBItoAmount.get(ar.Account__c) + oppAmount);
                    } else {
                        // Amount always in USD
                        Decimal fromRate = convertionRates.get((String) ar.getSobject('Reference_Request__r').getSobject('Opportunity__r').get('CurrencyIsoCode'));
                        Decimal rate = toRate/fromRate;
                        Decimal amount = accRBItoAmount.get(ar.Account__c) + (oppAmount * rate);
                        accRBItoAmount.put(ar.Account__c,amount);
                    }
                }
            } 
        }
        Set<Id> conRBItoOppKeys = conRBItoOpp.keySet();
        
        if (conRBItoOppKeys.size() > 0) {
            String conQuery = 'SELECT Id, Contact__c,Reference_Request_Account__r.Reference_Request__r.Opportunity__r.' + amtField + ',' +
                    (convert ? ' Reference_Request_Account__r.Reference_Request__r.Opportunity__r.CurrencyIsoCode, ' : '' ) + 
                    ' Reference_Request_Account__r.Reference_Request__r.Opportunity__c FROM Reference_Request_Account_Contact__c ' +
                    ' WHERE Reference_Request_Account__r.Reference_Request__r.Opportunity__c != null ' + 
                    ' AND Reference_Request_Account__r.Reference_Request__r.Opportunity__r.' + amtField + ' != null' + 
                    ' AND Contact_Request_Status__c = \'' + ConstantsController.COMPLETED + '\'' + 
                    ' AND Reference_Request_Account__r.Reference_Request__r.Opportunity__r.CloseDate > :startDate' + 
                    ' AND Contact__c IN: conRBItoOppKeys ' + 
                    ' AND Reference_Request_Account__r.Reference_Request__r.Opportunity__r.StageName = \'' + cs.Opportunity_Closed_Won_Stage__c + '\'';
            
            for (Reference_Request_Account_Contact__c cr : Database.Query(conQuery)) {
                
                if (conRBItoOpp.containsKey(cr.Contact__c) && !conRBItoOpp.get(cr.Contact__c).contains(cr.Reference_Request_Account__r.Reference_Request__r.Opportunity__c)) {
                    conRBItoOpp.get(cr.Contact__c).add(cr.Reference_Request_Account__r.Reference_Request__r.Opportunity__c);
                    Decimal oppAmount = (Decimal) cr.getSobject('Reference_Request_Account__r').getSobject('Reference_Request__r').getSobject('Opportunity__r').get(amtField);
                    
                    if (!convert || (String) cr.getSobject('Reference_Request_Account__r').getSobject('Reference_Request__r').getSobject('Opportunity__r').get('CurrencyIsoCode') == 'USD') {
                        conRBItoAmount.put(cr.Contact__c,conRBItoAmount.get(cr.Contact__c) + oppAmount);
                    } else {
                        // Amount always in USD
                        String code = (String) cr.getSobject('Reference_Request_Account__r').getSobject('Reference_Request__r').getSobject('Opportunity__r').get('CurrencyIsoCode');
                        Decimal fromRate = convertionRates.get(code);
                        Decimal rate = toRate/fromRate;
                        Decimal amount = conRBItoAmount.get(cr.Contact__c) + (oppAmount * rate);
                        conRBItoAmount.put(cr.Contact__c,amount);
                    }
                }
            }   
        }
        
        // Query for Contact RBIs
        for(Reference_Basic_Information__c conRBI : [SELECT Contact__c, RUL_Limit_Reached__c, RUL_Last_Activity_Date__c, RUL_Activities_will_do__c, RUL_Period__c, 
            RUL_Date_Available__c, Account_Level_RUL__c, RUL_Activities_used__c, Default_Period_Completed_Uses__c, Is_Contact_Limit_Reached__c, Account__c FROM 
            Reference_Basic_Information__c WHERE Is_Referenceable__c = true AND Referenceability_Status__c != null AND 
            Referenceability_Status__c !=: ConstantsController.INACTIVE  AND contact__c != null AND Account__c In: accountIdSet]) {
            
            contactIdSet.add(conRBI.Contact__c);
            
            if(conRBI.RUL_Period__c != null && defaultRULPeriod < conRBI.RUL_Period__c) {
                defaultRULPeriod = conRBI.RUL_Period__c;
            } 
            
            if(!mapOfAccIdAndConRBIList.containsKey(conRBI.Account__c))
                mapOfAccIdAndConRBIList.put(conRBI.Account__c, new List<Reference_Basic_Information__c>());
            mapOfAccIdAndConRBIList.get(conRBI.Account__c).add(conRBI);
        }
        
        // request Associated to Contact RBIs
        Date activityDateActive = date.today().addDays(-Integer.valueOf(defaultRULPeriod)); 
        for(Reference_Request_Account_Contact__c rrac : [SELECT Id, Activity_Date__c, Contact__c FROM Reference_Request_Account_Contact__c WHERE 
                Contact__c In: contactIdSet AND Contact_Request_Status__c =: ConstantsController.COMPLETED AND Activity_Date__c >: activityDateActive 
                LIMIT : (limits.getLimitQueryRows() - limits.getQueryRows())]) {
            
            if(!rrAccConMap.containsKey(rrac.Contact__c))
                rrAccConMap.put(rrac.Contact__c, new List<Reference_Request_Account_Contact__c>());
            rrAccConMap.get(rrac.Contact__c).add(rrac);
        }
        
        // iteration of Account RBI
        for(Reference_Basic_Information__c rbi : scope) {
            
            if (rbi.Referenceability_Status__c != ConstantsController.INACTIVE && rbi.Contact__c == null) {
                if(mapOfAccIdAndConRBIList.containsKey(rbi.Account__c) && mapOfAccIdAndConRBIList.get(rbi.Account__c).size() > 0) {
                    Boolean isContactLimitReach = true;
                    
                    //  Iteration of Contact RBI
                    for(Reference_Basic_Information__c conRBI : mapOfAccIdAndConRBIList.get(rbi.Account__c)) {
                        conRBI = rbiUpdateList.containsKey(conRBI.Id) ? rbiUpdateList.get(conRBI.Id) : conRBI;
                        if(rrAccConMap.containsKey(conRBI.Contact__c) && rrAccConMap.get(conRBI.Contact__c).size() > 0) {
                            Decimal completedUsesCount = 0;
                            Decimal defaultcompletedUsesCount = 0;
                            Date baseDate = Date.today().addDays(-Integer.valueOf(conRBI.RUL_Period__c));
                            
                            for(Reference_Request_Account_Contact__c rrac : rrAccConMap.get(conRBI.Contact__c)) {
                                
                                if (rrac.Activity_Date__c != null && (rrac.Activity_Date__c).daysBetween(Date.today()) <= defaultRULperiodvalue) {
                                    defaultcompletedUsesCount += 1;
                                }
                                
                                if(rrac.Activity_Date__c != null && rrac.Activity_Date__c > baseDate) {
                                    completedUsesCount += 1;
                                    
                                    if(conRBI.RUL_Last_Activity_Date__c != null && rrac.Activity_Date__c > conRBI.RUL_Last_Activity_Date__c) {
                                        conRBI.RUL_Last_Activity_Date__c = rrac.Activity_Date__c;
                                    }
                                }
                            }
                            conRBI.Default_Period_Completed_Uses__c = defaultcompletedUsesCount;
                            conRBI.RUL_Activities_used__c = completedUsesCount;
                        }
                        
                        if (conRBI.RUL_Activities_used__c >= conRBI.RUL_Activities_will_do__c) {
                            conRBI.RUL_Limit_Reached__c = true;
                            
                            if (conRBI.RUL_Period__c != null && conRBI.RUL_Last_Activity_Date__c != null){
                                conRBI.RUL_Date_Available__c = Date.valueOf(conRBI.RUL_Last_Activity_Date__c.addDays(integer.valueOf(conRBI.RUL_Period__c)));
                            }
                        } else {
                            conRBI.RUL_Limit_Reached__c = false;
                            isContactLimitReach = false;                        
                        }
                        rbiUpdateList.put(conRBI.Id,conRBI);
                    }
                    
                    if(isContactLimitReach) {
                        rbi.Is_Contact_Limit_Reached__c = true;
                        
                        if (rbi.Account_Level_RUL__c == false) {
                            rbi.RUL_Limit_Reached__c = true;
                            
                            if (rbi.RUL_Period__c != null && rbi.RUL_Last_Activity_Date__c != null)
                                rbi.RUL_Date_Available__c = Date.valueOf(rbi.RUL_Last_Activity_Date__c.addDays(integer.valueOf(rbi.RUL_Period__c)));
                        }
                    } else {
                        rbi.Is_Contact_Limit_Reached__c = false;
                    }
                    rbiUpdateList.put(rbi.Id,rbi);
                }   
            }
            
            if (rbi.Contact__c != null && conRBItoAmount.containsKey(rbi.Contact__c)) {
                
                
                if (rbiUpdateList.containsKey(rbi.Id)) { 
                    rbi = rbiUpdateList.get(rbi.Id);
                }
                    
                if (convert && (String)rbi.get('CurrencyIsoCode') != null && (String)rbi.get('CurrencyIsoCode') != 'USD') {
                    Decimal fromRate = convertionRates.get((String)rbi.get('CurrencyIsoCode'));
                    Decimal rate = fromRate/toRate;
                    Decimal amount = (conRBItoAmount.get(rbi.Contact__c)) * rate;
                    rbi.ACV_Influenced__c = amount;
                } else {
                    rbi.ACV_Influenced__c = conRBItoAmount.get(rbi.Contact__c);
                }
                rbiUpdateList.put(rbi.Id,rbi);
            } else if (rbi.Contact__c == null && accRBItoAmount.containsKey(rbi.Account__c)) {

                if (rbiUpdateList.containsKey(rbi.Id)) { 
                    rbi = rbiUpdateList.get(rbi.Id);
                }
                if (convert && (String)rbi.get('CurrencyIsoCode') != null && (String)rbi.get('CurrencyIsoCode') != 'USD') {
                    Decimal fromRate = convertionRates.get((String)rbi.get('CurrencyIsoCode'));
                    Decimal rate = fromRate/toRate;
                    Decimal amount = (accRBItoAmount.get(rbi.Account__c)) * rate;
                    rbi.ACV_Influenced__c = amount;
                } else {
                    rbi.ACV_Influenced__c = accRBItoAmount.get(rbi.Account__c);
                }
                rbiUpdateList.put(rbi.Id,rbi);
            }
        }
        
        //Update Contacts RBI 
        if (rbiUpdateList.size() > 0) {
            ConstantsController.stopTriggerContentAccountOnMerge = true;
            Database.SaveResult[] updateRBI = WithoutSharingHelperController.updateRBIFromBatch(rbiUpdateList.values());
            ConstantsController.stopTriggerContentAccountOnMerge = false;
            
            for (Integer i = 0; i<updateRBI.size(); i++) {
                
                if (!updateRBI.get(i).isSuccess()) {
                    Database.Error error = updateRBI.get(i).getErrors().get(0);
                    listOfFailedRecords.add('RBI : Error RecordId - ' + rbiUpdateList.values().get(i).Id + '\n');
                }
            }
        }
    }
    
    /**
     * Method to be called after the excute
     */
    global void finish(Database.BatchableContext BC) {
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Batch_ResetContactRULWithAccountRBI Failed');
    }
}