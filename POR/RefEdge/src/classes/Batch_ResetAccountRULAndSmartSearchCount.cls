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
	* Class: Schedular_ResetAccountRULAndSmartSearchCount
	* Description : This Batch is result of consolidation of following batches :-
	1.	Batch_ResetAccountRUL (Functionality :- To update RUL settings on Account Reference Profiles)
	2.	Batch_SmartSearchCount (Functionality :- To update referenceable Accounts count)
	* Created by : Rajneesh Raj @Jan/23/2018
*/

global with sharing class Batch_ResetAccountRULAndSmartSearchCount implements Database.Batchable <sObject> , Database.stateful {
	/**
		* Properties and variables
	*/
	private String soqlQuery = '';
	private Decimal defaultRULPeriod = UtilityController.getCustomSettings().RUL_Period__c;
	private list<String> listOfFailedRecords = new list<String>();
	private list<String> listOfExceptionInRecords = new list<String>();
	Map<String, Set<String>> attributeMap;
	Set<String> attributeSet;
	Set<String> allActiveProgrmMembers;
	Set<String> allProgrmMembers;
	Map<String, Set<String>> attAccountMap;
	Map<String, Set<String>> attActiveAccountMap;
	List<Attribute__c> rootLevelAttributes;
	Map<String, String> attLabelMap;
	
	/**
		* Constructor
	*/
    global Batch_ResetAccountRULAndSmartSearchCount() {
		Set<String> attMappingsAccount = new Set<String>();
        Set<String> attSet = new Set<String>();
		
        //fetch all attribute mappings of Account
        for (Attribute_Mapping__c attMapping: [SELECT Object__c, Id, Filter_Label_Name__c, Field_Api_Name__c, Field__c, Attribute_Name__c
			FROM Attribute_Mapping__c WHERE Is_Related_Mapping__c = false AND ( Object__c =: ConstantsController.OPPORTUNITY OR Object__c =: ConstantsController.CONTACT OR Object__c =:ConstantsController.ACCOUNT) LIMIT: limits.getLimitQueryRows()
            ]) {
            attMappingsAccount.add(attMapping.Id);
		}
        
        for (Attribute__c att : [SELECT Attribute_Mapping__c FROM Attribute__c WHERE Attribute_Mapping__c != null]) {
			attSet.add(att.Attribute_Mapping__c);
		}
        
        for (Attribute_Mapping__c attMapping: [SELECT Object__c, Related_Object__c, Id, Filter_Label_Name__c, Field_Api_Name__c, Field__c, Attribute_Name__c
			FROM Attribute_Mapping__c WHERE Object__c =: ConstantsController.OPPORTUNITY AND Related_Object__c = :ConstantsController.OPPORTUNITYLINEITEM 
			AND Is_Related_Mapping__c = true AND Id IN :attSet LIMIT: limits.getLimitQueryRows()
            ]) {
            attMappingsAccount.add(attMapping.Id);
		}        
        allProgrmMembers = new Set<String>();
        allActiveProgrmMembers = new Set<String>();
        rootLevelAttributes = new List<Attribute__c>();
        attributeSet = new Set<String>();
        attAccountMap = new Map<String, Set<String>>();
        attActiveAccountMap = new Map<String, Set<String>>();
        attributeMap = new Map<String, Set<String>>();
        Set<String> tempAttributeSet = new Set<String>();
        rootLevelAttributes = new List<Attribute__c>();
        attLabelMap = new Map<String, String>();
        Set<Id> labelIDset = new Set<Id>();
        
        if (attMappingsAccount != null && attMappingsAccount.size() > 0) {
            //fetch all attributes of account attribute mappings
            rootLevelAttributes = [SELECT Level__c, Name, Attribute_Mapping__c, (SELECT Id, Name, Level__c FROM Attributes__r WHERE Level__c = 1) FROM Attribute__c WHERE Level__c =
                0 AND Attribute_Mapping__c IN: attMappingsAccount LIMIT: limits.getLimitQueryRows()
			];
            
            for (Attribute__c att: rootLevelAttributes) {
                tempAttributeSet = new Set<String>();
                
                for (Attribute__c att1: att.Attributes__r) {
                    tempAttributeSet.add(att1.Id);
                    attributeSet.add(att1.Id);
				}
                
                for (String str: tempAttributeSet) {
                    labelIDset.add(str);
                    break;
				}
                attributeMap.put(att.Id, tempAttributeSet);
                attAccountMap.put(att.Id, new Set<String>());
                attActiveAccountMap.put(att.Id, new Set<String>());
			}
		}
        
        //fetch attribute labels
        for (Attributes_Labels__c attLabel: [SELECT Id, Attribute__c, Attribute__r.Parent__c, Label__c FROM Attributes_Labels__c WHERE Attribute__c IN:
			labelIDset
            ]) {
            attLabelMap.put(attLabel.Attribute__r.Parent__c, attLabel.Label__c);
		}
	}
	
	/**
		* Method to get the data to be proceesed START Block 
	*/
    global Database.QueryLocator start(Database.BatchableContext BC) {
		
		soqlQuery = 'SELECT Id, Name, (SELECT Account__c, Attribute__c, Attribute__r.Parent__c ' + 
		'FROM Account_Attributes__r WHERE  Attribute__c IN : attributeSet),';
        soqlQuery += ' (SELECT Id, Account__c, RUL_Activities_will_do__c, RUL_Limit_Reached__c, RUL_Period__c, Account_Level_RUL__c, '+
		'RUL_Last_Activity_Date__c, RUL_Date_Available__c, RUL_Activities_used__c, Is_Contact_Limit_Reached__c, '+ 
		'Default_Period_Completed_Uses__c, Referenceability_Status__c  FROM Reference_Basic_Informations__r ' + 
		'WHERE Account__c != null AND Is_Referenceable__c = true AND Referenceability_Status__c != null AND Contact__c = null),';
		soqlQuery += ' (SELECT Id, Activity_Date__c FROM Reference_Request_Accounts__r WHERE  Account_Request_Status__c = \'' +
		ConstantsController.COMPLETED + '\')';
		
		soqlQuery += ' FROM Account';
        return Database.getQueryLocator(soqlQuery);
	}
	
	/**
		* Method to execute the batch i.e. EXECUTE Block  
	*/
    global void execute(Database.BatchableContext BC, List<Account> scope) {		
		Map<String, list<Reference_Request_Account__c>> rrAccMapForDefaultCompleteUse = new Map<String, list<Reference_Request_Account__c>>();
		List<Reference_Basic_Information__c> rbiAccountList = new List<Reference_Basic_Information__c>();
		
		for (Account acc: scope) {
			
			for (Reference_Request_Account__c tempObj: acc.Reference_Request_Accounts__r) {
				
				if (tempObj.Activity_Date__c != null && (tempObj.Activity_Date__c).daysBetween(date.today()) <= defaultRULPeriod) {
					
					if (!rrAccMapForDefaultCompleteUse.containsKey(acc.Id)) {
						rrAccMapForDefaultCompleteUse.put(acc.Id, new List<Reference_Request_Account__c>());
					}						
					rrAccMapForDefaultCompleteUse.get(acc.Id).add(tempObj);
				}
			}
		}
		
		for (Account a: scope) {
			
			if (a.Reference_Basic_Informations__r.Size() > 0) {
				Reference_Basic_Information__c rbiObj;
				
				for (Reference_Basic_Information__c rbi: a.Reference_Basic_Informations__r) {
					rbiObj = rbi;						
				}
				
				try {
					//find an active reference program account					
					allProgrmMembers.add(a.Id);
					//system.assert(false,rbiObj);
					if (rbiObj.Referenceability_Status__c == ConstantsController.ACTIVE || rbiObj.Referenceability_Status__c == ConstantsController.CAUTION) {
						allActiveProgrmMembers.add(a.Id);
					}
					
					//create a map for all root attributes with all their associated accounts
					if (rbiObj != null) {
						
						for (Account_Attribute__c att: a.Account_Attributes__r) {
							
							if (attAccountMap.containsKey(att.Attribute__r.Parent__c)) {
								attAccountMap.get(att.Attribute__r.Parent__c).add(att.Account__c);
							}
							
							if ((rbiObj.Referenceability_Status__c == ConstantsController.ACTIVE || rbiObj.Referenceability_Status__c == ConstantsController.CAUTION) &&
							attActiveAccountMap.containsKey(att.Attribute__r.Parent__c)) {
								attActiveAccountMap.get(att.Attribute__r.Parent__c).add(att.Account__c);
							}
						}
					}
				} catch(exception ex) {
					listOfExceptionInRecords.add('Exception at Line no. -  '+ ex.getLineNumber() +' : Error - '+ ex.getMessage() + ' : For Record - ' + a.Id +'\n');
				}
				
				try {
					Decimal completedUsesCount = 0;
					
					if (rbiObj != null) {
						
						//Update RUL_Last_Activity_Date__c, RUL_Limit_Reached__c
						if (rbiObj.RUL_Period__c != null) {
							Date baseDate = date.today().addDays(-integer.valueOf(rbiObj.RUL_Period__c));
							
							for (Reference_Request_Account__c rra: a.Reference_Request_Accounts__r) {
								
								if (rra.Activity_Date__c != null && rra.Activity_Date__c > baseDate) {
									completedUsesCount += 1;
									
									if (rbiObj.RUL_Last_Activity_Date__c != null && rra.Activity_Date__c > rbiObj.RUL_Last_Activity_Date__c) {
										rbiObj.RUL_Last_Activity_Date__c = rra.Activity_Date__c;
									}
								}
							}
							//Update RUL_Activities_used__c
							rbiObj.RUL_Activities_used__c = completedUsesCount;
							
							//Update Account_Level_RUL__c
							if (rbiObj.Account_Level_RUL__c) {
								
								if (rbiObj.RUL_Activities_used__c > = rbiObj.RUL_Activities_will_do__c) {
									rbiObj.RUL_Limit_Reached__c = true;
									} else {
									rbiObj.RUL_Limit_Reached__c = false;
								}
								} else {
								
								if (rbiObj.Is_Contact_Limit_Reached__c) {
									rbiObj.RUL_Limit_Reached__c = true;
									} else {
									rbiObj.RUL_Limit_Reached__c = false;
								}
							}
							
							if (rbiObj.RUL_Limit_Reached__c == true) {
								
								if (rbiObj.RUL_Period__c != null && rbiObj.RUL_Last_Activity_Date__c != null) {
									rbiObj.RUL_Date_Available__c = date.valueOf(rbiObj.RUL_Last_Activity_Date__c.addDays(
									integer.valueOf(rbiObj.RUL_Period__c)));
								}								
							}
						}						
						
						//Update Default_Period_Completed_Uses__c
						if (rrAccMapForDefaultCompleteUse.containsKey(a.Id)) {							
							rbiObj.Default_Period_Completed_Uses__c = rrAccMapForDefaultCompleteUse.get(a.Id).size();
							} else {
							rbiObj.Default_Period_Completed_Uses__c = 0;
						}
						rbiAccountList.add(rbiObj);
					}				
				} catch(exception ex) {
					listOfExceptionInRecords.add('Exception at Line no. -  '+ ex.getLineNumber() +' : Error - '+ ex.getMessage() + ' : For Record - ' + a.Id +'\n');
				}			
			}						
		}
		
		//Update account RBI, List of failed records && Send Error Email to Refedge Team
		if (rbiAccountList.size() > 0) {
			ConstantsController.stopTriggerContentAccountOnMerge = true;
			
			Database.SaveResult[] updateAccount = WithoutSharingHelperController.updateRBIFromBatch(rbiAccountList);
			
			for (Integer i = 0; i < updateAccount.size(); i++) {
				
				if (!updateAccount.get(i).isSuccess()) {
					Database.Error error = updateAccount.get(i).getErrors().get(0);
					listOfFailedRecords.add('Account RBI : Error RecordId - ' + rbiAccountList.get(i).Id + '\n');
				}
			}
			ConstantsController.stopTriggerContentAccountOnMerge = false;
		}
	}
	
	/**
		* Method to be called after the excute i.e FINISH Block
	*/
    global void finish(Database.BatchableContext BC) {
		//create a list of all smart search filters
        List<Data_Mapping__c> filterList = new List<Data_Mapping__c>();
        List<Label__c> labelList = [SELECT id, name FROM Label__c ORDER BY Name LIMIT: limits.getLimitQueryRows()];
		
		for (Label__c label: labelList) {
            filterList.add(new Data_Mapping__c(Label__c = label.Name, Field_API_Name__c = label.Id, Object__c = 'SmartSearchFilter'));
		}
		List<Data_Mapping__c> tempList = [SELECT Name, Order__c, Id, Visible__c, Required__c, Label__c, Program_Coverage__c, Ref_Search_Coverage__c,
            Field_API_Name__c FROM Data_Mapping__c WHERE Object__c = 'SmartSearchFilter'
		ORDER BY Order__c, Label__c LIMIT: limits.getLimitQueryRows()];
		
		for (Data_Mapping__c dm: tempList) {
        	
            for (integer index = 0; index < filterList.size(); index++) {
				
				if (filterList[index].Field_API_Name__c == dm.Field_API_Name__c) {
                    string name = filterList[index].Label__c;
                    filterList[index] = dm;
                    filterList[index].Label__c = name;
				}
			}
		}
		
        //put all calculations for refsearch coverage and program coverage
        for (Attribute__c root: rootLevelAttributes) {
            Set<String> accAttList = attAccountMap.get(root.Id);
            Set<String> activeAccAttList = attActiveAccountMap.get(root.Id);
            Decimal accCount1 = allActiveProgrmMembers.size();
            Decimal attCount1 = activeAccAttList.size() * 100;
            Decimal accCount2 = allProgrmMembers.size();
            Decimal attCount2 = accAttList.size() * 100;
            
            for (Data_Mapping__c dm: filterList) {
            	
                if (dm.Field_API_Name__c == attLabelMap.get(root.Id)) {
                    dm.Required__c = true;
                    Decimal value1 = 0;
                    Decimal value2 = 0;
                    
                    if (accCount1 != 0) {
                        value1 = attCount1.divide(accCount1, 2);
					}
					
                    if (accCount2 != 0) {
                        value2 = attCount2.divide(accCount2, 2);
					}
                    dm.Ref_Search_Coverage__c = value1;
                    dm.Program_Coverage__c = value2;
				}
			}
		}
		
        if (filterList.size() > 0) {
            ConstantsController.shouldDataMappingProcessed = true;
            upsert filterList;
		}
        //Send Error Email to Refedge Team
        UtilityController.sendEmailNotification(listOfFailedRecords, 'Batch_ResetAccountRULAndSmartSearchCount : ' + listOfFailedRecords.size());
		
		//Send Exception Email to Refedge Team
		if (listOfExceptionInRecords.Size() > 0) {
			UtilityController.sendExceptionEmailNotification(listOfExceptionInRecords, 'Batch_ResetAccountRULAndSmartSearchCount Having Exception : ' + listOfExceptionInRecords.size());
		}        
	}
}