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
* Page: AccountLevelRULPageSLDS
* Description : Class used to provide information about account reference profile.
* Modified by: Rajesh @June 06 2017
*/
global with sharing class SLDSAccountLevelRULController extends RefEdgeEditionFeatures {
   /**
	* Properties and variables
	*/
    //to resolve namespace issue on package creation
    public String nameSpace {
        get {
            return UtilityController.appNamespace();
        }
        private set;
    }
    public String currencyIsoCode {
        get {
            return UserInfo.getDefaultCurrency();
        }
        private set;
    }
    
    public SLDSAccountLevelRULController(ApexPages.standardController controller) {}
    public SLDSAccountLevelRULController() {}
    /**
	* Remote Action Method to get Reference Profile : DEPRECATED
	*/   
    @RemoteAction
    global static Reference_Basic_Information__c getRBI(String accountId) {
        return null;
    }
   /**
	* Remote Action Method to get Reference Profile
	*/    
    @RemoteAction
    global static String getRBI1(String accountId) {
        Reference_Basic_Information__c RBI =  new Reference_Basic_Information__c();
        
        List<Schema.FieldSetMember> lastfieldListLeft = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountLeft.getFields();
        List<Schema.FieldSetMember> lastfieldListRight = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountRight.getFields();
        
        Set<String> fieldSet = new Set<String>{'Total_Reference_Use_f__c', 'Reference_Program_Candidate__c', 'Total_Reference_Use__c', 
            'Referenceability__c', 'Referenceability_Status__c', 'Reference_Owner__c', 'RUL_Period__c', 
            'RUL_Limit_Reached__c', 'RUL_Last_Updated_By__c', 'RUL_Last_Activity_Date__c', 'RUL_Date_Available_f__c', 
            'RUL_Date_Available__c', 'RUL_Activities_will_do__c', 'RUL_Activities_used__c', 
            'RUL_Activities_available__c', 'Managed_Reference_Account__c', 'Lifetime_Points__c','ACV_Influenced__c', 
            'Joined_Reference_Program__c', 'Is_Referenceable_f__c', 'Is_Referenceable__c', 
            'Is_Contact_Limit_Reached__c', 'Id', 'Default_Period_Completed_Uses__c', 'Ref_Profile_Summary__c',
            'Current_Available_Balance_Points__c', 'Attributes__c', 'Account__c', 'Account_Level_RUL__c', 'Generic_Account__c'};
                
        Set<String> newFieldSet = new Set<String>();
        String query = 'SELECT ';
        
        for (Schema.FieldSetMember f : lastfieldListLeft) {
            query += f.getFieldPath().toLowerCase() + ', ';
            newFieldSet.add(f.getFieldPath().toLowerCase());
        }
        
        for (Schema.FieldSetMember f : lastfieldListRight) {
            
            if (!newFieldSet.contains(f.getFieldPath().toLowerCase())) {
                query += f.getFieldPath().toLowerCase() + ', ';
            }
            newFieldSet.add(f.getFieldPath().toLowerCase());
        }
        
        for (String field : fieldSet) {
            
            if (!newFieldSet.contains(field.toLowerCase()) && !newFieldSet.contains('refedge__'+field.toLowerCase())) {
                query += field.toLowerCase() + ', ';
            }
        }
        
        //re #826
        if (!newFieldSet.contains('inactive_reason__c') && !newFieldSet.contains('refedge__inactive_reason__c')) {
            query += 'Inactive_Reason__c,';	 
        } 
        
        accountId = String.escapeSingleQuotes(accountId);
        if (Schema.getGlobalDescribe().containsKey('CurrencyType')) {
            query += ' CurrencyIsoCode, ';
        }
        query += ' Name, Account__r.Name, Reference_Owner__r.Name From Reference_Basic_Information__c r where Contact__c = null and Account__c = \'' 
            + accountId + '\' limit 1';
        List<Reference_Basic_Information__c> RBIList = WithoutSharingHelperController.getRBI(query);
        
        if (RBIList.size() > 0) {
            RBI = RBIList[0];
            
            if (RBI.Reference_Owner__c != null) {
                String ownerId = RBI.Reference_Owner__c;
                String ownerName = RBI.Reference_Owner__r.Name;
            }
        } else {
            RBI = new Reference_Basic_Information__c(Account__c = accountId);
        }  
        return JSON.serialize(RBI);
    }
    
   /**
	* Method to get Reference Profile Field Map
	*/
    global static Map<String, FieldWrapper> getFieldMap(String accountId) {
        Set<String> fieldSet = new Set<String>{'Total_Reference_Use_f__c', 'Reference_Program_Candidate__c', 'Total_Reference_Use__c', 
            'Referenceability__c', 'Referenceability_Status__c', 'Reference_Owner__c', 'RUL_Period__c', 
            'RUL_Limit_Reached__c', 'RUL_Last_Updated_By__c', 'RUL_Last_Activity_Date__c', 'RUL_Date_Available_f__c', 
            'RUL_Date_Available__c', 'RUL_Activities_will_do__c', 'RUL_Activities_used__c', 'RUL_Activities_available__c', 'ACV_Influenced__c',
            'Managed_Reference_Account__c', 'Lifetime_Points__c', 'Joined_Reference_Program__c', 'Is_Referenceable_f__c', 
            'Is_Referenceable__c', 'Is_Contact_Limit_Reached__c', 'Id', 'Default_Period_Completed_Uses__c', 
            'Current_Available_Balance_Points__c', 'Attributes__c', 'Account__c', 'Account_Level_RUL__c', 'Generic_Account__c', 'Inactive_Reason__c'};
                
        Map<String, FieldWrapper> fieldMap = new Map<String, FieldWrapper>();
        Map<String, Schema.SObjectField> fieldMapFromDescribe = Schema.sObjectType.Reference_Basic_Information__c.fields.getMap();
        Reference_Basic_Information__c RBI = (Reference_Basic_Information__c)JSON.deserialize(getRBI1(accountId), Reference_Basic_Information__c.class);
        
        for (String field : fieldSet) {
            Schema.DescribeFieldResult dfr = fieldMapFromDescribe.get(UtilityController.appNamespace() + field.toLowerCase()).getDescribe();
            
            if (String.valueOf(dfr.getType()) == 'DATE') {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((date)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
            } else if (String.valueOf(dfr.getType()) == 'REFERENCE') {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), String.valueOf(dfr.getReferenceTo()), 
                                                     String.valueOf(dfr.isAccessible()), '', (String)(RBI.getSobject(dfr.getRelationshipName()) != null ? 
                                                                                                      RBI.getSobject(dfr.getRelationshipName()).get('Name') : ''), dfr.getInlineHelpText(),null));
            } else if (String.valueOf(dfr.getType()) == 'DATETIME') {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((datetime)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
            } else {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),null));
            }
        } 
        return fieldMap;
    }
    
   /**
	* Remote Action Method to get Reference Profile Information Section
	*/
    @RemoteAction
    global static String getInfoFields(String accountId) {
        List<FieldWrapper> informationFields = new List<FieldWrapper>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        List<String> leftFields = new List<String>();
        List<String> rightFields = new List<String>(); 
        leftFields.add('Reference_Program_Candidate__c');
        leftFields.add('Is_Referenceable__c');
        leftFields.add('Referenceability_Status__c');
        leftFields.add('Managed_Reference_Account__c');
        leftFields.add('ACV_Influenced__c');
        leftFields.add('Inactive_Reason__c');
        rightFields.add('Total_Reference_Use__c');
        rightFields.add('Referenceability__c');
        rightFields.add('Attributes__c');
        rightFields.add('Reference_Owner__c');
        rightFields.add('Joined_Reference_Program__c');
        rightFields.add((cs.Shared_Contacts__c ? 'Generic_Account__c' : ''));
        
        Map<String, FieldWrapper> fieldMap = getFieldMap(accountId);
        
        Integer col = 0;
        
        for (Integer index = 0; index < leftFields.size() + rightFields.size(); index++) {
            informationFields.add(new FieldWrapper('', '', '', '', '', '', '', '',null));
        }
        
        for (String field : leftFields) {
            
            if (field != '' && fieldMap.get(field).isAccessible == 'true') {
                informationFields[col] = fieldMap.get(field);
                col = col + 2;
            }
        }
        col = 1;
        
        for (String field : rightFields) {
            
            if (field != '' && fieldMap.get(field).isAccessible == 'true') {
                informationFields[col] = fieldMap.get(field);
                col = col + 2;
            }
        }
        
        for (Integer index = leftFields.size() + rightFields.size() - 1; index >= 0; index--) {
            
            if (informationFields[index].apiName == '') {
                informationFields.remove(index);
            } else {
                break;
            }
        }  
        return JSON.serialize(informationFields);
    }
    
   /**
	* Remote Action Method to get Reference Profile Reference Use Limit Section
	*/
    @RemoteAction
    global static String getLimitFields(String accountId) {
        List<FieldWrapper> limitFields = new List<FieldWrapper>();
        List<String> leftFields = new List<String>();
        List<String> rightFields = new List<String>();
        
        leftFields.add('RUL_Limit_Reached__c');
        leftFields.add('Is_Contact_Limit_Reached__c');
        leftFields.add('RUL_Last_Activity_Date__c');
        leftFields.add('RUL_Date_Available_f__c');
        leftFields.add('RUL_Last_Updated_By__c');
        rightFields.add('RUL_Period__c');
        rightFields.add('RUL_Activities_will_do__c');
        rightFields.add('RUL_Activities_used__c');
        rightFields.add('RUL_Activities_available__c');
        rightFields.add('Account_Level_RUL__c');
        
        Map<String, FieldWrapper> fieldMap = getFieldMap(accountId);
        
        Integer col = 0;
        
        for (Integer index = 0; index < leftFields.size() + rightFields.size(); index++) {
            limitFields.add(new FieldWrapper('', '', '', '', '', '', '', '',null));
        }
        
        for (String field : leftFields) {
            
            if (field != '' && fieldMap.get(field).isAccessible == 'true') {
                limitFields[col] = fieldMap.get(field);
                col = col + 2;
            }
        }
        col = 1;
        
        for (String field : rightFields) {
            
            if (fieldMap.get(field).isAccessible == 'true') {
                limitFields[col] = fieldMap.get(field);
                col = col + 2;
            }
        }
        
        for (Integer index = leftFields.size() + rightFields.size() - 1; index >= 0; index--) {
            
            if (limitFields[index].apiName == '') {
                limitFields.remove(index);
            } else {
                break;
            }
        }
        return JSON.serialize(limitFields);
    }
   /**
	* Remote Action Method to getaccountId for Case
	*/
    @RemoteAction
    global static String getAccountId(String caseId) {
		String accId;
		
		if (caseId.startsWith('500')) {  //for case layout
            Case caseObj = [SELECT Id, AccountId FROM Case WHERE Id = :caseId];
            accId = caseObj.AccountId;
        }
        return accId;
    }
    
   /**
	* Remote Action Method to get Reference Profile Reward status Section
	*/
    @RemoteAction
    global static String getRewardFields(String accountId) {
        List<FieldWrapper> rewardFields = new List<FieldWrapper>();
        List<String> leftFields = new List<String>();
        List<String> rightFields = new List<String>();
        boolean isRewardSection = false;
        
        Map<String, FieldWrapper> fieldMap = getFieldMap(accountId);
        
        if (fieldMap.get('Lifetime_Points__c').isAccessible == 'true') {
            rewardFields.add(fieldMap.get('Lifetime_Points__c'));
            isRewardSection = true;
        } else {
            rewardFields.add(new FieldWrapper('', '', '', '', '', '', '', '',null));
        }
        
        if (fieldMap.get('Current_Available_Balance_Points__c').isAccessible == 'true') {
            rewardFields.add(fieldMap.get('Current_Available_Balance_Points__c'));
            isRewardSection = true;
        } else {
            rewardFields.add(new FieldWrapper('', '', '', '', '', '', '', '',null));
        }
        return JSON.serialize(rewardFields);
    }
    
   /**
	* Remote Action Method to get Reference Profile Extra Section
	*/
    @RemoteAction
    global static String getExtraFields(String accountId) {
        List<FieldWrapper> extraFields = new List<FieldWrapper>();
        List<String> leftFields = new List<String>();
        List<String> rightFields = new List<String>();
        Map<String, FieldWrapper> fieldMap = getFieldMap(accountId);
        Map<String, Schema.SObjectField> fieldMapFromDescribe = Schema.sObjectType.Reference_Basic_Information__c.fields.getMap();
        Reference_Basic_Information__c RBI = (Reference_Basic_Information__c)JSON.deserialize(getRBI1(accountId), Reference_Basic_Information__c.class);
        Map<String, FieldWrapper> newfieldMap = new Map<String, FieldWrapper>();
        
        List<Schema.FieldSetMember> lastFieldsLeft = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountLeft.getFields();
        List<Schema.FieldSetMember> lastFieldsRight = SObjectType.Reference_Basic_Information__c.FieldSets.ReferenceProfileAccountRight.getFields();
        
        for (Schema.FieldSetMember field1 : lastFieldsLeft) {
            String field = field1.getFieldPath();
            leftFields.add(field);
            Schema.DescribeFieldResult dfr = fieldMapFromDescribe.get(field.toLowerCase()).getDescribe();
            
            if (String.valueOf(dfr.getType()) == 'DATE') {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((date)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
            } else if (String.valueOf(dfr.getType()) == 'DATETIME') {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((datetime)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
            } else if (String.valueOf(dfr.getType()) == 'PICKLIST' || String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {
                List<MultiPicklistWrapper> picklistMap = new List<MultiPicklistWrapper>();
                
                for (Schema.PicklistEntry f : dfr.getPicklistValues()) {
                    picklistMap.add(new MultiPicklistWrapper(String.valueOf(f.getLabel()),String.valueOf(f.getValue())));
                }
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),picklistMap));
            } else {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),null));
            }
        }
        
        for (Schema.FieldSetMember field1 : lastFieldsRight) {
            String field = field1.getFieldPath();
            rightFields.add(field);
            Schema.DescribeFieldResult dfr = fieldMapFromDescribe.get(field.toLowerCase()).getDescribe();
            
            if (String.valueOf(dfr.getType()) == 'DATE') {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((date)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
            } else if (String.valueOf(dfr.getType()) == 'DATETIME') {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((datetime)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
            } else if (String.valueOf(dfr.getType()) == 'PICKLIST' || String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {
                List<MultiPicklistWrapper> picklistMap = new List<MultiPicklistWrapper>();
                
                for (Schema.PicklistEntry f : dfr.getPicklistValues()) {
                    picklistMap.add(new MultiPicklistWrapper(String.valueOf(f.getLabel()),String.valueOf(f.getValue())));
                }
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                     String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),picklistMap));
            } else {
                fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),null));
            }
        }
        
        if (leftFields.size() > rightFields.size()) {
            integer difference = (leftFields.size() - rightFields.size());
            
            for (integer i = 0; i < difference; i++) {
                rightFields.add('');
            }
        } else if (rightFields.size() > leftFields.size()) {
            integer difference = (rightFields.size() - leftFields.size());
            
            for (integer i = 0; i < difference; i++) {
                leftFields.add('');
            }
        }
        
        for (Integer index = 0; index < leftFields.size() + rightFields.size(); index++) {
            extraFields.add(new FieldWrapper('', '', '', '', '', '', '', '',null));
        }
        
        Integer col = 0;
        
        for (String field : leftFields) {
            
            if (field != '') {
                String objectName = '';
                Schema.DescribeFieldResult dfr = fieldMapFromDescribe.get(field.toLowerCase()).getDescribe();
                
                if (dfr.isAccessible()) {
                    
                    if (String.valueOf(dfr.getType()) == 'REFERENCE') {
                        objectName = String.valueOf(dfr.getReferenceTo());
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), objectName, 
                                                             String.valueOf(dfr.isAccessible()), '', (String)(RBI.getSobject(dfr.getRelationshipName()) != null 
                                                                                                              ? RBI.getSobject(dfr.getRelationshipName()).get('Name') : ''), dfr.getInlineHelpText(),null));
                    } else if (String.valueOf(dfr.getType()) == 'DATE') {
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                            String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((date)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
                    } else if (String.valueOf(dfr.getType()) == 'DATETIME') {
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                            String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((datetime)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
                    } else if (String.valueOf(dfr.getType()) == 'PICKLIST' || String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {
                        List<MultiPicklistWrapper> picklistMap = new List<MultiPicklistWrapper>();
                
                        for (Schema.PicklistEntry f : dfr.getPicklistValues()) {
                            picklistMap.add(new MultiPicklistWrapper(String.valueOf(f.getLabel()),String.valueOf(f.getValue())));
                        }
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                            String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),picklistMap));
                    } else {
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), objectName, 
                                                             String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),null));
                    }
                    extraFields[col] = fieldMap.get(field);
                    col = col + 2;
                }
            }
        }
        
        col = 1;
        
        for (String field : rightFields) {
            
            if (field != '') {
                String objectName = '';
                Schema.DescribeFieldResult dfr = fieldMapFromDescribe.get(field.toLowerCase()).getDescribe();
                
                if (dfr.isAccessible()) {
                    
                    if (String.valueOf(dfr.getType()) == 'REFERENCE') {
                        objectName = String.valueOf(dfr.getReferenceTo());
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), objectName, 
                                                             String.valueOf(dfr.isAccessible()), '', (String)(RBI.getSobject(dfr.getRelationshipName()) != null 
                                                                                                              ? RBI.getSobject(dfr.getRelationshipName()).get('Name') : ''), dfr.getInlineHelpText(),null));
                    } else if (String.valueOf(dfr.getType()) == 'DATE') {
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                            String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((date)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
                    } else if (String.valueOf(dfr.getType()) == 'DATETIME') {
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                            String.valueOf(dfr.isAccessible()), (RBI.get(field) != null ? ((datetime)RBI.get(field)).format() : ''), '', dfr.getInlineHelpText(),null));
                    } else if (String.valueOf(dfr.getType()) == 'PICKLIST' || String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {
                        List<MultiPicklistWrapper> picklistMap = new List<MultiPicklistWrapper>();
                
                        for (Schema.PicklistEntry f : dfr.getPicklistValues()) {
                            picklistMap.add(new MultiPicklistWrapper(String.valueOf(f.getLabel()),String.valueOf(f.getValue())));
                        }
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), '', 
                                                            String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),picklistMap));
                    } else {
                        fieldMap.put(field, new FieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), objectName, 
                                                             String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),null));
                    }
                    extraFields[col] = fieldMap.get(field);
                    col = col + 2;
                }
            }
        }
        
        for (Integer index = leftFields.size() + rightFields.size() - 1; index >= 0; index--) {
            
            if (extraFields[index].apiName == '') {
                extraFields.remove(index);
            } else {
                break;
            }
        }
        return JSON.serialize(extraFields);
    }
    
   /**
	* Remote Action Method to get Reference status picklist values
	*/
    @RemoteAction
    global static String getPickList() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(UtilityController.appNamespace() 
                                                                                                               + 'Referenceability_Status__c').getDescribe();
        List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            options.add(String.valueOf(f.value));
        }
        return JSON.serialize(options);
    }
    
    /**
     * Method to get Date Format #1070 by Dixita 11/2017
     */
    @RemoteAction
    public static String getDateFormat() {   
    		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
    		return dateFormat; 
    }
    
    
    /**
	* Remote Action Method to get Reference Profile Summary field
	*/
    @RemoteAction
    global static String getSummaryFields() {
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
        Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Basic_Information__c.fields.getMap().get(UtilityController.appNamespace() 
                                                                                                              + 'Ref_Profile_Summary__c').getDescribe();
        FieldWrapper summaryField = new FieldWrapper(dfr.getLabel(), 'Ref_Profile_Summary__c', String.valueOf(dfr.getType()), '', String.valueOf(dfr.isAccessible()), '', '', dfr.getInlineHelpText(),null);
        
        if (!cs.Show_Summary__c) {
        	return null;
        }
        return JSON.serialize(summaryField);
    }
    
   /**
	* Remote Action Method to get Section header
	*/
    @RemoteAction
    global static String getLastSectionHeader() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        String lastSectionHeader = (cs.Reference_Profile_Section_Header__c != null ? cs.Reference_Profile_Section_Header__c : 'Client-configured Section Heading');
        return lastSectionHeader;
    }
    
   /**
	* Test Method to get lookup data.
	*/
    @RemoteAction
    global static List<sObject> getLookupDataByObjectAndName(String objectName) {
        List<sObject> returnObjectList;
        String query = 'SELECT Id, Name FROM ' + objectName;
        returnObjectList = DataBase.query(query);
        return returnObjectList;
    }
    
   /**
	* Remote Action Method to save Reference Profile- Deprecated Method
	*/
    @RemoteAction
    global static String saveRBI(String RBIValues) { 
        return '';
    }
    
   /**
	* Remote Action Method to save Reference Profile
	*/
    @RemoteAction
    global static String saveRBIRecords(String RBIValues, String oldInactiveReason, String status) {
        Reference_Basic_Information__c RBI = (Reference_Basic_Information__c)JSON.deserialize(RBIValues, Reference_Basic_Information__c.class);
        
        if (CRUDAndFLSCheckController.checkPermissionsforAccountRBI(RBI.Id != null)) {
            Savepoint sp = Database.setSavepoint();
            String errMsg = 'Error' + ' ';
            
            try {
                RBI.ACV_Influenced__c = (RBI.ACV_Influenced__c == null) ? 0 : RBI.ACV_Influenced__c;
                upsert RBI; 
                //re #615 - Ref note created when referenceability status is set to inactive.
                if (checkPermissionsforRefNotes()) {
                	
		           	if (status != RBI.Referenceability_Status__c && RBI.Referenceability_Status__c == 'Inactive') { 
		            	createReferenceNote(false, RBI); 
		            } else  if (oldInactiveReason != RBI.Inactive_Reason__c) { 
		            	createReferenceNote(true, RBI); 
		            }  
	           	}
                
                return JSON.serialize(RBI);
                
            } catch (DMLException e) {
                errMsg += e.getDmlMessage(0);
                Database.rollback(sp);
                return errMsg;
            } catch (Exception e) {
                errMsg += e.getMessage();
                Database.rollback(sp);
                return errMsg;
            }
        } else {
            return CRUDAndFLSCheckController.getErrorMsg();
        }
        return null;
    }
    
   /**
	* RemoteAction to get insufficient permmission message
	*/
    @RemoteAction
    public static String getPermissionsMessage(Boolean isUpdate) { 
        CRUDAndFLSCheckController.checkPermissionsforAccountRBI(isUpdate); 
        
        return  CRUDAndFLSCheckController.getErrorMsg();
    }
    
   /**
	* Method to check Permissions for Reference Notes
	*/
    public static Boolean checkPermissionsforRefNotes() {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Note__c', new Set<String>{ 
            UtilityController.appNamespace() + 'Account__c', UtilityController.appNamespace() + 'Note__c' });
        
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true); 
    }
    
     /**
     * Method to add/update Reference Note
     */
    public static void createReferenceNote(Boolean isUpdate, Reference_Basic_Information__c RBI) {
    	
    	if (isUpdate) {
    		List<Reference_Note__c> lstSelecedRefNotes = new List<Reference_Note__c>();
    		List<Reference_Note__c> lstRefNotes = [SELECT Id, Note__c FROM Reference_Note__c WHERE Account__c = :RBI.Account__c ORDER BY LastModifiedDate DESC LIMIT 1];
    		
    		if (lstRefNotes.size() > 0) {
	    		
	    		for (Reference_Note__c notes : lstRefNotes) {
	    			
	    			if (notes.Note__c.contains(System.Label.Reason_For_Inactive)) {
	    				lstSelecedRefNotes.add(notes);
	    				break;
	    			} 
	    		}
	    		
	    		if (lstSelecedRefNotes.size() > 0) {
	    			
	    			for (Reference_Note__c selectedNotes : lstSelecedRefNotes) {	    			 
		    			selectedNotes.Note__c = System.Label.Reason_For_Inactive + ' ';
		    			selectedNotes.Note__c += (RBI.inactive_reason__c != null) ? RBI.inactive_reason__c : '';
	    			}
	    		} 
	    		
	    		update lstSelecedRefNotes; 
    		} else if(RBI.inactive_reason__c != null && RBI.Referenceability_Status__c == 'Inactive') { 
    			insertReferenceNote(RBI); 
    		} else if(RBI.inactive_reason__c != null && RBI.Referenceability_Status__c == 'Inactive') { 
    			insertReferenceNote(RBI);
    		}  	
    	} else {
    		 
    		if (RBI.Inactive_Reason__c != null && RBI.Referenceability_Status__c == 'Inactive') {
	    		insertReferenceNote(RBI);
    		}
    	}
    }
  
    /**
     * Method to add Reference Note
     */
    public static void insertReferenceNote(Reference_Basic_Information__c RBI) { 
    	Reference_Note__c note = new Reference_Note__c();          
	 	note.Account__c = RBI.Account__c;
	 	note.Note__c = System.Label.Reason_For_Inactive + ' '+ RBI.inactive_reason__c;
		insert note; 
    }    
    
    /**
     * Method to return total reference uses for this account
     * Created By: Rekha @16 August 2017 re #947
     */
    @RemoteAction
    public static List<RefTypeWrapper> showTotalReferenceUses(String accountId) { 
    	List<RefTypeWrapper> refTypes = new List<RefTypeWrapper>();
    	Map<Id, RefTypeWrapper> refTypeMap = new Map<Id, RefTypeWrapper>();
    	
    	for (Reference_Request_Account__c tempObj : [SELECT Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Account__c 
    												FROM Reference_Request_Account__c 
    												WHERE Account__c = :accountId AND Account_Request_Status__c = 'Completed']) {
            
            if (!refTypeMap.containskey(tempObj.Reference_Type_Needed__c)) {
                refTypeMap.put(tempObj.Reference_Type_Needed__c, new RefTypeWrapper(tempObj.Reference_Type_Needed__c, tempObj.Reference_Type_Needed__r.Name));
            }
            RefTypeWrapper obj = refTypeMap.get(tempObj.Reference_Type_Needed__c);
            obj.refCount += 1;
            refTypeMap.put(tempObj.Reference_Type_Needed__c, obj);
        }
        refTypes.addAll(refTypeMap.values());
    	return refTypes;
    }	
    	
    global class FieldWrapper {
        public String label { get; set; }
        public String apiName { get; set; }
        public String fieldType { get; set; }
        public String objectName { get; set; }
        public String isAccessible { get; set; }
        public String dateValue { get; set; }
        public String referenceValue { get; set; }
        public String inlineHelpText { get; set; }
        public List<MultiPicklistWrapper> picklistEntries { get; set; }
        public List<MultiPicklistWrapper> picklistEntriesSelected { get; set; }
        
        public FieldWrapper(String label, String apiName, String fieldType, String objectName, String isAccessible, String dateValue, String referenceValue, String inlineHelpText, List<MultiPicklistWrapper> picklistEntries) {
            this.label = label;
            this.apiName = apiName;
            this.fieldType = fieldType;
            this.objectName = objectName;
            this.isAccessible = isAccessible;
            this.dateValue = dateValue;
            this.referenceValue = referenceValue;
            this.inlineHelpText = inlineHelpText;
            this.picklistEntries = picklistEntries;
			this.picklistEntriesSelected = new List<MultiPicklistWrapper>();
        }
    } 
    
    //re #947
    public class RefTypeWrapper {
    	public String id { get; set; }
        public String name { get; set; }
        public Integer refCount { get; set; }
        
        public RefTypeWrapper(String id, String name) {
        	this.id = id;
        	this.name = name;
        	this.refCount = 0;
        }
    }
    
    //#REF-2091
    public class MultiPicklistWrapper { 
        String value { get; set; }
        String name { get; set; }
        
        public MultiPicklistWrapper(string name,String value) { 
            this.name = name; 
            this.value = value;   
        }
    }

    @RemoteAction
    public static String rollUpAttribute(String recordInfo) {        
        String attributes = '';

        if(recordInfo != '' && recordInfo != null) {
            attributes = UtilityController.rollUpAttributeMappingRBI(Id.valueOf(recordInfo), true, null);
        }
        return attributes.removeEnd(', ');
    }
}