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
 * VF Page: SelectAccountsAsRefLeads.page
 * Description: controller for creating reference lead records from the selected accounts
 * author: Gaurav Saini (2 Nov, 2017)
 */
public with sharing class SelectAccountsAsRefLeads extends RefEdgeEditionFeatures {
    
    public Boolean isSLDS { get; set; }
    public Boolean isRefProspectEnabled { get; set; }
    public String refLeadListViewId { get; set; }
    public String refLeadIdPrefix { get; set; }
    public Boolean isFromCustomSettings { get; set; }
    public String nameSpace { get; set; }
    public String defaultFieldsToDisplayJson { get; set; }
    
    public SelectAccountsAsRefLeads(ApexPages.StandardSetController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        nameSpace = UtilityController.appNamespace();
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	isRefProspectEnabled = cs.Ref_Prospector_Enable__c;
    	refLeadListViewId = WithoutSharingHelperController.getListViewId(nameSpace + 'Reference_Lead__c');
    	refLeadIdPrefix = Reference_Lead__c.sObjectType.getDescribe().getKeyPrefix();
    	isFromCustomSettings = ApexPages.currentPage().getParameters().get('isFromCustomSettings') == null ? false : true;
		List<FieldWrapper> defaultFieldsList = new List<FieldWrapper>();
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.Name.getLabel(),
												Schema.SObjectType.Account.fields.Name.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.Name.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.AccountNumber.getLabel(),
												Schema.SObjectType.Account.fields.AccountNumber.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.AccountNumber.getType())));
		defaultFieldsList.add(new FieldWrapper('', System.Label.Account_Owner,
												System.Label.Account_Owner,
												false, ''));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.OwnerId.getLabel(),
												Schema.SObjectType.Account.fields.OwnerId.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.OwnerId.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.Site.getLabel(),
												Schema.SObjectType.Account.fields.Site.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.Site.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.AnnualRevenue.getLabel(),
												Schema.SObjectType.Account.fields.AnnualRevenue.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.AnnualRevenue.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.BillingCountry.getLabel(),
												Schema.SObjectType.Account.fields.BillingCountry.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.BillingCountry.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.Industry.getLabel(),
												Schema.SObjectType.Account.fields.Industry.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.Industry.getType())));
		defaultFieldsList.add(new FieldWrapper('', System.Label.Parent_Account,
												System.Label.Parent_Account,
												false, ''));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.ParentId.getLabel(),
												Schema.SObjectType.Account.fields.ParentId.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.ParentId.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.Sic.getLabel(),
												Schema.SObjectType.Account.fields.Sic.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.Sic.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.Type.getLabel(),
												Schema.SObjectType.Account.fields.Type.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.Type.getType())));
		defaultFieldsList.add(new FieldWrapper('', Schema.SObjectType.Account.fields.Website.getLabel(),
												Schema.SObjectType.Account.fields.Website.getName(),
												false, String.valueOf(Schema.SObjectType.Account.fields.Website.getType())));
		defaultFieldsToDisplayJson = JSON.serialize(defaultFieldsList);
    }
    
    /**
     * method to check permissions
     * author: Gaurav Saini (8 Nov, 2017)
     */
    private static Boolean checkPermissions() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c',
    										new Set<String>{UtilityController.appNamespace() + 'Ref_Prospector_Lead_Count__c',
    											UtilityController.appNamespace() + 'Ref_Prospector_Campaign_Lead_Count__c'});
        Boolean customSettingPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        fieldMap.clear();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Lead__c',
    										new Set<String>{UtilityController.appNamespace() + 'Reference_Lead_Account__c',
    											UtilityController.appNamespace() + 'Reference_Lead_Owner__c',
    											UtilityController.appNamespace() + 'Reference_Lead_Status__c',
    											UtilityController.appNamespace() + 'Ref_Lead_Include_in_Campaign__c'});
        Boolean refLeadPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        return (customSettingPermission && refLeadPermission);
    }
    
    /**
     * method to get permissions message
     * author: Gaurav Saini (8 Nov, 2017)
     */
    @RemoteAction
    public static String getPermissionsMessage() {
    	checkPermissions();
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * method to get account ids for which active reference leads already exist
     * author: Gaurav Saini (11 Dec, 2017) for #959
     */
    @RemoteAction
    public static String getExistingRefLeadAccIds() {
    	List<Reference_Lead__c> existingRefLeads = WithoutSharingHelperController.getExistingRefLeads();
		Set<String> existingRefLeadAccIds = new Set<String>();
		
		for (Reference_Lead__c refLead : existingRefLeads) {
			existingRefLeadAccIds.add(refLead.Reference_Lead_Account__c);
		}
		return JSON.serialize(existingRefLeadAccIds);
    }
    
    /**
     * method to get accounts list for creating new ref leads
     * author: Gaurav Saini (11 Dec, 2017)
     */
    @RemoteAction
    public static String getAccountsList(String accIdsJSON, String fieldsListJson, String listViewId) {
		List<FieldWrapper> fieldsList = (List<FieldWrapper>)JSON.deserialize(fieldsListJson, List<FieldWrapper>.class);
    	List<String> existingRefLeadsAccIds = (List<String>)JSON.deserialize(accIdsJSON, List<String>.class);
    	List<Map<String, String>> resultAccountsList = new List<Map<String, String>>();
		List<User_Mapping__c> userMappingsList = [SELECT Id, Label__c, Field_API_Name__c, Default_Value__c, Order__c
													FROM User_Mapping__c
													WHERE Process__c = 'ListFiltersProspect'
													AND User__c = :UserInfo.getUserId()
													AND Label__c = :listViewId
													ORDER BY Order__c  LIMIT : (Limits.getLimitQueryRows() - Limits.getQueryRows())];
		
		Map<String, List<User_Mapping__c>> objectNameToUserMappingsListMap;
		Set<Id> relatedAccountIdSet;
		if (userMappingsList != null && userMappingsList.size() > 0) {
			objectNameToUserMappingsListMap = getObjectNameToUserMappingsListMap(userMappingsList);
			if(objectNameToUserMappingsListMap != null) {
				relatedAccountIdSet = getRelatedAccountIdSet(objectNameToUserMappingsListMap);
			}
		}
        
		String accountsQuery = 'SELECT Id';

		for (FieldWrapper field : fieldsList) {
			
			if (field.apiName == System.Label.Account_Owner) {
				accountsQuery = accountsQuery + ', Owner.Name';
			} else if (field.apiName == System.Label.Parent_Account) {
				accountsQuery = accountsQuery + ', Parent.Name';
			} else if (field.apiName != 'Id') {
				accountsQuery = accountsQuery + ', ' + field.apiName;
			}
		}
		accountsQuery = accountsQuery + ' FROM Account WHERE Id NOT IN :existingRefLeadsAccIds ';
		
		if (relatedAccountIdSet != null) {
			accountsQuery += ' AND Id IN :relatedAccountIdSet ';
		}
        
        if (objectNameToUserMappingsListMap != null && objectNameToUserMappingsListMap.containsKey('Account')) {
            String whereClause = UtilityController.createDynamicQuery(objectNameToUserMappingsListMap.get('Account'));
            accountsQuery += whereClause;
		}
        
		accountsQuery = accountsQuery + ' ORDER BY Name LIMIT 50';
		List<Account> accountsList = WithoutSharingHelperController.getAccountsForProspect(accountsQuery, existingRefLeadsAccIds, new List<String>(), relatedAccountIdSet);
    	
    	for (Account acc : accountsList) {
    		Map<String, String> tempAccount = new Map<String, String>();

			for (FieldWrapper field : fieldsList) {
				String fieldValue = '';

				if (field.apiName == System.Label.Account_Owner) {
					fieldValue = String.valueOf(acc.getSobject('Owner') != null ? acc.getSobject('Owner').get('Name') : '');
				} else if (field.apiName == System.Label.Parent_Account) {
					fieldValue = String.valueOf(acc.getSobject('Parent') != null ? acc.getSobject('Parent').get('Name') : '');
				} else if (field.fieldType == 'DATE') {
					fieldValue = acc.get(field.apiName) != null ? ((Date)acc.get(field.apiName)).format() : '';
				} else if (field.fieldType == 'DATETIME') {
					fieldValue = acc.get(field.apiName) != null ? ((Datetime)acc.get(field.apiName)).format() : '';
				} else if (field.fieldType == 'MULTIPICKLIST') {
					fieldValue = acc.get(field.apiName) != null ? String.valueOf(acc.get(field.apiName)).replaceAll(';', ', ') : '';
				} else if (field.fieldType != '') {
					fieldValue = acc.get(field.apiName) != null ? String.valueOf(acc.get(field.apiName)) : '';
				}
				tempAccount.put(field.apiName, fieldValue);
			}

			if (!tempAccount.containsKey('Id')) {
				tempAccount.put('Id', String.valueOf(acc.Id));
			}
			tempAccount.put('isSelected', 'false');
			resultAccountsList.add(tempAccount);
    	}
    	return JSON.serialize(resultAccountsList);
    }

	/**
     * method to refresh the accounts list when visible columns are changed
     * author: Gaurav Saini (2 Feb, 2018)
     */
    @RemoteAction
    public static String getAccountsOnColumnsChange(String accIdsJSON, String fieldsListJson) {
		List<FieldWrapper> fieldsList = (List<FieldWrapper>)JSON.deserialize(fieldsListJson, List<FieldWrapper>.class);
    	List<String> alreadyPresentAccIds = (List<String>)JSON.deserialize(accIdsJSON, List<String>.class);
    	List<Map<String, String>> resultAccountsList = new List<Map<String, String>>();
    	String accountsQuery = 'SELECT Id';

		for (FieldWrapper field : fieldsList) {
			
			if (field.apiName == System.Label.Account_Owner) {
				accountsQuery = accountsQuery + ', Owner.Name';
			} else if (field.apiName == System.Label.Parent_Account) {
				accountsQuery = accountsQuery + ', Parent.Name';
			} else if (field.apiName != 'Id') {
				accountsQuery = accountsQuery + ', ' + field.apiName;
			}
		}
		accountsQuery = accountsQuery + ' FROM Account WHERE Id IN :alreadyPresentAccIds ORDER BY Name LIMIT ' + Limits.getLimitQueryRows();
		List<Account> accountsList = WithoutSharingHelperController.getAccountsForProspect(accountsQuery, new List<String>(), alreadyPresentAccIds, null);
    	
    	for (Account acc : accountsList) {
    		Map<String, String> tempAccount = new Map<String, String>();

			for (FieldWrapper field : fieldsList) {
				String fieldValue = '';

				if (field.apiName == System.Label.Account_Owner) {
					fieldValue = String.valueOf(acc.getSobject('Owner') != null ? acc.getSobject('Owner').get('Name') : '');
				} else if (field.apiName == System.Label.Parent_Account) {
					fieldValue = String.valueOf(acc.getSobject('Parent') != null ? acc.getSobject('Parent').get('Name') : '');
				} else if (field.fieldType == 'DATE') {
					fieldValue = acc.get(field.apiName) != null ? ((Date)acc.get(field.apiName)).format() : '';
				} else if (field.fieldType == 'DATETIME') {
					fieldValue = acc.get(field.apiName) != null ? ((Datetime)acc.get(field.apiName)).format() : '';
				} else if (field.fieldType != '') {
					fieldValue = acc.get(field.apiName) != null ? String.valueOf(acc.get(field.apiName)) : '';
				}
				tempAccount.put(field.apiName, fieldValue);
			}

			if (!tempAccount.containsKey('Id')) {
				tempAccount.put('Id', String.valueOf(acc.Id));
			}
			tempAccount.put('isSelected', 'false');
			resultAccountsList.add(tempAccount);
    	}
    	return JSON.serialize(resultAccountsList);
	}
    
    /**
     * method to get accounts list for creating new ref leads
     * author: Gaurav Saini (11 Dec, 2017)
     */
    @RemoteAction
    public static String getMoreAccounts(String refLeadAccIdsJSON, String alreadyPresentAccIdsJSON,
											String searchText, String fieldsListJson, String listViewId) {
		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
		dateFormat = dateFormat != null ? dateFormat : 'yyyy-MM-dd';
		List<String> dateFormatList = new List<String>();
		
		for (String str : dateFormat.split('[./-]')) {
			dateFormatList.add(str.substring(0, 1).toLowerCase());
		}
		List<FieldWrapper> fieldsList = (List<FieldWrapper>)JSON.deserialize(fieldsListJson, List<FieldWrapper>.class);
    	List<String> existingRefLeadsAccIds = (List<String>)JSON.deserialize(refLeadAccIdsJSON, List<String>.class);
    	List<String> alreadyPresentAccIds = (List<String>)JSON.deserialize(alreadyPresentAccIdsJSON, List<String>.class);
    	List<Map<String, String>> resultAccountsList = new List<Map<String, String>>();
    	List<Account> accountsList = new List<Account>();
    	searchText = String.escapeSingleQuotes(searchText);
		List<User_Mapping__c> userMappingsList = [SELECT Id, Label__c, Field_API_Name__c, Default_Value__c, Order__c
													FROM User_Mapping__c
													WHERE Process__c = 'ListFiltersProspect'
													AND User__c = :UserInfo.getUserId()
													AND Label__c = :listViewId
													ORDER BY Order__c];
    	Map<String, String> operatorMap = new Map<String, String>();
		operatorMap.put('equals', ' @@@ = \'###\' ');
		operatorMap.put('not equal to', ' @@@ != \'###\' ');
		operatorMap.put('less than', ' @@@ < \'###\' ');
		operatorMap.put('greater than', ' @@@ > \'###\' ');
		operatorMap.put('less or equal', ' @@@ <= \'###\' ');
		operatorMap.put('greater or equal', ' @@@ >= \'###\' ');
		operatorMap.put('contains', ' @@@ LIKE \'%###%\' ');
		operatorMap.put('does not contain', ' (NOT @@@ LIKE \'%###%\') ');
		operatorMap.put('starts with', ' @@@ LIKE \'###%\' ');
		operatorMap.put('includes', ' @@@ INCLUDES (\'###\') ');
		operatorMap.put('excludes', ' @@@ EXCLUDES (\'###\') ');
    	
    	if (searchText == '' || searchText.trim().length() == 0) {
	    	String accountsQuery = 'SELECT Id';

			for (FieldWrapper field : fieldsList) {
				
				if (field.apiName == System.Label.Account_Owner) {
					accountsQuery = accountsQuery + ', Owner.Name';
				} else if (field.apiName == System.Label.Parent_Account) {
					accountsQuery = accountsQuery + ', Parent.Name';
				} else if (field.apiName != 'Id') {
					accountsQuery = accountsQuery + ', ' + field.apiName;
				}
			}
			accountsQuery = accountsQuery + ' FROM Account WHERE Id NOT IN :existingRefLeadsAccIds '
							+ 'AND Id NOT IN :alreadyPresentAccIds ';

			if (userMappingsList != null && userMappingsList.size() > 0) {

				for (User_Mapping__c um : userMappingsList) {
					
					if (um.Field_API_Name__c != null) {
						String fieldValue = um.Default_Value__c != null ? um.Default_Value__c : '';
						String fieldApiName = um.Field_API_Name__c.split('::')[0];
						String fieldLabel = um.Field_API_Name__c.split('::')[1];
						String fieldType = um.Field_API_Name__c.split('::')[2];
						String operator = um.Field_API_Name__c.split('::')[3];

						if (fieldType == 'PICKLIST') {
							
							if (fieldValue.trim() != '') {
								String picklistClause = '';

								for (String value : fieldValue.split(', ')) {
									picklistClause = picklistClause == '' ? operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value) : picklistClause + (operator == 'not equal to' ? 'AND' : 'OR') + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value); 
								}
								accountsQuery = accountsQuery + 'AND (' + picklistClause + ')';
							} else {
								accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
							}
						} else if (fieldType == 'MULTIPICKLIST') {
							
							if (fieldValue.trim() != '') {
								String joinedValues = fieldValue.replaceAll(', ', '\',\'');
								accountsQuery = operator == 'equals' ? (accountsQuery + 'AND ' + fieldApiName + ' IN (\'' + joinedValues + '\')') : accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', joinedValues);
							} else {
								accountsQuery = operator == 'excludes' ? (accountsQuery + 'AND ' + fieldApiName + ' != null ') : (accountsQuery + 'AND ' + fieldApiName + ' = null ');
							}
						} else if (fieldType == 'DATE') {
							
							if (fieldValue != null && fieldValue.trim() != '') {
								List<String> dateList = fieldValue.split('[./-]');
								Datetime filterDate = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
								accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDate.format('yyyy-MM-dd'));
							} else {
								accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
							}
						} else if (fieldType == 'DATETIME') {
							
							if (fieldValue != null && fieldValue.trim() != '') {
								List<String> dateList = fieldValue.split('[./-]');
								Datetime filterDate = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
								accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\''));
							} else {
								accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
							}
						} else if (fieldType == 'BOOLEAN') {
							accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'false');
						} else if (fieldType == 'DOUBLE' || fieldType == 'INTEGER' || fieldType == 'CURRENCY') {
							accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'null');
						} else {
							accountsQuery = accountsQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', fieldValue != null ? fieldValue : 'null');
						}
					}
				}
			}
			accountsQuery = accountsQuery + ' ORDER BY Name LIMIT 50';
			accountsList = WithoutSharingHelperController.getAccountsForProspect(accountsQuery, existingRefLeadsAccIds, alreadyPresentAccIds, null);
    	} else {
    		String soslQuery = 'FIND \'' + searchText + '*\' IN ALL FIELDS RETURNING Account(Id';
			
			for (FieldWrapper field : fieldsList) {
				
				if (field.apiName == System.Label.Account_Owner) {
					soslQuery = soslQuery + ', Owner.Name';
				} else if (field.apiName == System.Label.Parent_Account) {
					soslQuery = soslQuery + ', Parent.Name';
				} else if (field.apiName != 'Id') {
					soslQuery = soslQuery + ', ' + field.apiName;
				}
			}
			soslQuery = soslQuery + ' WHERE Id NOT IN :existingRefLeadsAccIds '
						+ 'AND Id NOT IN :alreadyPresentAccIds ';
						
			if (userMappingsList != null && userMappingsList.size() > 0) {

				for (User_Mapping__c um : userMappingsList) {
					
					if (um.Field_API_Name__c != null) {
						String fieldValue = um.Default_Value__c != null ? um.Default_Value__c : '';
						String fieldApiName = um.Field_API_Name__c.split('::')[0];
						String fieldLabel = um.Field_API_Name__c.split('::')[1];
						String fieldType = um.Field_API_Name__c.split('::')[2];
						String operator = um.Field_API_Name__c.split('::')[3];

						if (fieldType == 'PICKLIST') {
							
							if (fieldValue.trim() != '') {
								String picklistClause = '';

								for (String value : fieldValue.split(', ')) {
									picklistClause = picklistClause == '' ? operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value) : picklistClause + (operator == 'not equal to' ? 'AND' : 'OR') + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', value); 
								}
								soslQuery = soslQuery + 'AND (' + picklistClause + ')';
							} else {
								soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
							}
						} else if (fieldType == 'MULTIPICKLIST') {
							
							if (fieldValue.trim() != '') {
								String joinedValues = fieldValue.replaceAll(', ', '\',\'');
								soslQuery = operator == 'equals' ? (soslQuery + 'AND ' + fieldApiName + ' IN (\'' + joinedValues + '\')') : soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', joinedValues);
							} else {
								soslQuery = operator == 'excludes' ? (soslQuery + 'AND ' + fieldApiName + ' != null ') : (soslQuery + 'AND ' + fieldApiName + ' = null ');
							}
						} else if (fieldType == 'DATE') {
							
							if (fieldValue != null && fieldValue.trim() != '') {
								List<String> dateList = fieldValue.split('[./-]');
								Datetime filterDate = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
								soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDate.format('yyyy-MM-dd'));
							} else {
								soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
							}
						} else if (fieldType == 'DATETIME') {
							
							if (fieldValue != null && fieldValue.trim() != '') {
								List<String> dateList = fieldValue.split('[./-]');
								Datetime filterDate = Datetime.newInstance(Integer.valueOf(dateList[dateFormatList.indexOf('y')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('m')]),
																			Integer.valueOf(dateList[dateFormatList.indexOf('d')]));
								soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', filterDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\''));
							} else {
								soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', 'null');
							}
						} else if (fieldType == 'BOOLEAN') {
							soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'false');
						} else if (fieldType == 'DOUBLE' || fieldType == 'INTEGER' || fieldType == 'CURRENCY') {
							soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('\'###\'', fieldValue != null ? fieldValue : 'null');
						} else {
							soslQuery = soslQuery + 'AND' + operatorMap.get(operator).replace('@@@', fieldApiName).replace('###', fieldValue != null ? fieldValue : 'null');
						}
					}
				}
			}
			soslQuery = soslQuery + ' ORDER BY Name LIMIT 50)';
    		List<List<sObject>> searchResult = WithoutSharingHelperController.getAccountsUsingSOSL(soslQuery, existingRefLeadsAccIds, alreadyPresentAccIds);
    		accountsList = searchResult[0];
    	}
    	
    	if (accountsList != null && accountsList.size() > 0) {

	    	for (Account acc : accountsList) {
				Map<String, String> tempAccount = new Map<String, String>();

				for (FieldWrapper field : fieldsList) {
					String fieldValue = '';

					if (field.apiName == System.Label.Account_Owner) {
						fieldValue = String.valueOf(acc.getSobject('Owner') != null ? acc.getSobject('Owner').get('Name') : '');
					} else if (field.apiName == System.Label.Parent_Account) {
						fieldValue = String.valueOf(acc.getSobject('Parent') != null ? acc.getSobject('Parent').get('Name') : '');
					} else if (field.fieldType == 'DATE') {
						fieldValue = acc.get(field.apiName) != null ? ((Date)acc.get(field.apiName)).format() : '';
					} else if (field.fieldType == 'DATETIME') {
						fieldValue = acc.get(field.apiName) != null ? ((Datetime)acc.get(field.apiName)).format() : '';
					} else if (field.fieldType != '') {
						fieldValue = acc.get(field.apiName) != null ? String.valueOf(acc.get(field.apiName)) : '';
					}
					tempAccount.put(field.apiName, fieldValue);
				}

				if (!tempAccount.containsKey('Id')) {
					tempAccount.put('Id', String.valueOf(acc.Id));
				}
				tempAccount.put('isSelected', 'false');
				resultAccountsList.add(tempAccount);
			}
    	}
		return JSON.serialize(resultAccountsList);
    }
    
    /**
     * method to create Reference Leads from the selected accounts
     * author: Gaurav Saini (2 Nov, 2017)
     */
    @RemoteAction
    public static String createRefLeads(String accIdsJSON) {
    	Savepoint sp = Database.setSavepoint();
    	String result = '';
    	
    	try {
	    	List<String> accIds = (List<String>)JSON.deserialize(accIdsJSON, List<String>.class);
	    	List<Reference_Lead__c> refLeads = new List<Reference_Lead__c>();
	    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    		String accQuery = 'SELECT Id';
    		
    		if (cs.Ref_Prosepector_Lead_Owner__c != null
    				&& cs.Ref_Prosepector_Lead_Owner__c != ''
    				&& cs.Ref_Prosepector_Lead_Owner__c != 'OwnerId') {
    			accQuery = accQuery + ', ' + cs.Ref_Prosepector_Lead_Owner__c;
    		}
			accQuery = accQuery + ', OwnerId';
    		accQuery = accQuery + ' FROM Account WHERE Id IN :accIds';
    		Map<String, Account> accMap = new Map<String, Account>((List<Account>)Database.query(accQuery));
    		List<Reference_Lead__c> existingRefLeads = WithoutSharingHelperController.getExistingRefLeads();
    		Set<String> existingRefLeadAccIds = new Set<String>();
    		
    		for (Reference_Lead__c refLead : existingRefLeads) {
    			existingRefLeadAccIds.add(refLead.Reference_Lead_Account__c);
    		}
    		
	    	for (String accId : accIds) {
	    		
	    		if (!existingRefLeadAccIds.contains(accId)) {
		    		Reference_Lead__c tempRefLead = new Reference_Lead__c();
		    		tempRefLead.Reference_Lead_Account__c = accId;
		    		tempRefLead.Reference_Lead_Status__c = 'Request Pending';
		    		tempRefLead.Ref_Lead_Include_in_Campaign__c = true;
		    		
		    		if (cs.Ref_Prosepector_Lead_Owner__c != null && cs.Ref_Prosepector_Lead_Owner__c != ''
		    				&& accMap.get(accId).get(cs.Ref_Prosepector_Lead_Owner__c) != null) {
		    			tempRefLead.Reference_Lead_Owner__c = (String)accMap.get(accId).get(cs.Ref_Prosepector_Lead_Owner__c);
		    		} else {
		    			tempRefLead.Reference_Lead_Owner__c = accMap.get(accId).OwnerId;
		    		}
		    		refLeads.add(tempRefLead);
	    		}
	    	}
	    	
	    	if (refLeads.size() > 0) {
		    	WithoutSharingHelperController.insertRefLeads(refLeads);
		    	
		    	if (cs.Ref_Prospector_Lead_Count__c != null && cs.Ref_Prospector_Lead_Count__c != 0) {
		    		cs.Ref_Prospector_Lead_Count__c += refLeads.size();
		    		cs.Ref_Prospector_Campaign_Lead_Count__c += refLeads.size();
		    	} else {
		    		cs.Ref_Prospector_Lead_Count__c = refLeads.size();
		    		cs.Ref_Prospector_Campaign_Lead_Count__c = refLeads.size();
		    	}
		    	update cs;
	    	}
	    	result = 'success-' + refLeads.size();
    	} catch(Exception e) {
    		Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
    	}
    	return result;
    }

	/**
     * method to create list of available fields
     * author: Gaurav Saini (1 Feb, 2018)
     */
    @RemoteAction
    public static String getSelectedFieldsList() {
		List<FieldWrapper> fieldsList = new List<FieldWrapper>();
		Map<String, Schema.SObjectField> accountFieldsMap
				= CRUDAndFLSCheckController.sObjectsMap.get('Account').getDescribe().fields.getMap();
		Set<String> selectedFieldApiNames = new Set<String>();
		List<User_Mapping__c> userMappings = [SELECT Id, Visible__c, Label__c, Field_API_Name__c, Default_Value__c
												FROM User_Mapping__c
												WHERE Process__c = 'ColumnSelectorProspect'
												AND User__c = :UserInfo.getUserId()
												ORDER BY Order__c];

		if (userMappings != null && userMappings.size() > 0) {

			for (User_Mapping__c um : userMappings) {
				fieldsList.add(new FieldWrapper(um.Id, um.Label__c, um.Field_API_Name__c, um.Visible__c, um.Default_Value__c));
				selectedFieldApiNames.add(um.Field_API_Name__c);
			}
		}

		if (!selectedFieldApiNames.contains(System.Label.Account_Owner)) {
			fieldsList.add(new FieldWrapper('', System.Label.Account_Owner, System.Label.Account_Owner, false, ''));
		}

		if (!selectedFieldApiNames.contains(System.Label.Parent_Account)) {
			fieldsList.add(new FieldWrapper('', System.Label.Parent_Account, System.Label.Parent_Account, false, ''));
		}

		for (String apiName : accountFieldsMap.keySet()) {
			Schema.DescribeFieldResult dfr = accountFieldsMap.get(apiName).getDescribe();

			if (!selectedFieldApiNames.contains(dfr.getName())
					&& String.valueOf(dfr.getName()) != 'BillingGeocodeAccuracy'
                    && String.valueOf(dfr.getName()) != 'ShippingGeocodeAccuracy'
					&& String.valueOf(dfr.getType()) != 'ADDRESS') {
				fieldsList.add(new FieldWrapper('', dfr.getLabel(), dfr.getName(), false, String.valueOf(dfr.getType())));
			}
		}
		return JSON.serialize(fieldsList);
	}

	/**
	 * method to save selected columns
	 * author: Gaurav Saini (1 Feb, 2018) for REF-1300
	 */
    @RemoteAction
	public static String saveSelectedFields(String selectedFieldsJson, String oldSelectedFieldsJson) {
		Savepoint sp = Database.setSavepoint();
		String result = '';

		try {
			List<FieldWrapper> fieldsList = (List<FieldWrapper>)JSON.deserialize(selectedFieldsJson, List<FieldWrapper>.class);
			List<FieldWrapper> oldFieldsList = (List<FieldWrapper>)JSON.deserialize(oldSelectedFieldsJson, List<FieldWrapper>.class);
			List<FieldWrapper> resultList = new List<FieldWrapper>();
			List<User_Mapping__c> userMappingsToInsert = new List<User_Mapping__c>();
			List<User_Mapping__c> userMappingsToDelete = new List<User_Mapping__c>();
			Decimal orderNo = 1;

			for (FieldWrapper field : oldFieldsList) {
				
				if (field.userMappingId != '') {
					userMappingsToDelete.add(new User_Mapping__c(Id = field.userMappingId));
				}
			}

			for (FieldWrapper field : fieldsList) {
				User_Mapping__c tempUM = new User_Mapping__c();
				tempUM.Label__c = field.label;
				tempUM.Field_API_Name__c = field.apiName;
				tempUM.Order__c = orderNo;
				tempUM.Visible__c = true;
				tempUM.Process__c = 'ColumnSelectorProspect';
				tempUM.User__c = UserInfo.getUserId();
				tempUM.Default_Value__c = field.fieldType;
				userMappingsToInsert.add(tempUM);
				orderNo += 1;
			}

			if (userMappingsToDelete.size() > 0) {
				delete userMappingsToDelete;
			}

			if (userMappingsToInsert.size() > 0) {
				insert userMappingsToInsert;

				for (User_Mapping__c um : userMappingsToInsert) {
					resultList.add(new FieldWrapper(um.Id, um.Label__c, um.Field_API_Name__c, um.Visible__c, um.Default_Value__c));
				}
			}
			result = 'success--' + JSON.serialize(resultList);
		} catch(Exception e) {
			Database.rollback(sp);
			result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
		}
		return result;
	}

	/**
     * method to get all the list views for the current user
     * author: Gaurav Saini (8 Feb, 2018) for REF-1299
     */
    @RemoteAction
    public static String getListViews() {
		List<ListViewWrapper> listViewWrapperList = new List<ListViewWrapper>();
		List<User_Mapping__c> userMappingsList = [SELECT Id, Field_API_Name__c, Default_Value__c
													FROM User_Mapping__c
													WHERE Process__c = 'ListFiltersProspect'
													AND User__c = :UserInfo.getUserId()
													AND Label__c = null
													ORDER BY Field_API_Name__c];

		if (userMappingsList == null || userMappingsList.size() == 0) {
			User_Mapping__c tempUM = new User_Mapping__c();
			tempUM.Field_API_Name__c = 'All Accounts';
			tempUM.Process__c = 'ListFiltersProspect';
			tempUM.User__c = UserInfo.getUserId();
			insert tempUM;
			listViewWrapperList.add(new ListViewWrapper(tempUM));
		} else {

			for (User_Mapping__c um : userMappingsList) {
				listViewWrapperList.add(new ListViewWrapper(um));
			}
		}
		return JSON.serialize(listViewWrapperList);
	}

	/**
     * method to delete a list view
     * author: Gaurav Saini (15 Feb, 2018) for REF-1299
     */
    @RemoteAction
    public static String deleteUserMapping(String listViewId) {
		List<User_Mapping__c> userMappingsList = [SELECT Id FROM User_Mapping__c
													WHERE Process__c = 'ListFiltersProspect'
													AND User__c = :UserInfo.getUserId()
													AND (Label__c = :listViewId OR Id = :listViewId)];

		if (userMappingsList != null && userMappingsList.size() > 0) {
			delete userMappingsList;
		}
		return 'success';
	}
	
    private static Map<String, List<User_Mapping__c>> getObjectNameToUserMappingsListMap(List<User_Mapping__c> userMappingsList) {
		Map<String, List<User_Mapping__c>> objectNameToUserMappingsListMap = new Map<String, List<User_Mapping__c>>();
		for (User_Mapping__c um : userMappingsList) {
			String objectName = um.Field_API_Name__c != null && um.Field_API_Name__c.split('::').size() > 4 ? um.Field_API_Name__c.split('::')[4] : '';
			if(String.isNotBlank(objectName)) {
				if(!objectNameToUserMappingsListMap.containsKey(objectName)) {
					objectNameToUserMappingsListMap.put(objectName, new List<User_Mapping__c>());
				}
				objectNameToUserMappingsListMap.get(objectName).add(um);
			} 
        }
        return objectNameToUserMappingsListMap;
	}
	
	private static Set<Id> getRelatedAccountIdSet(Map<String, List<User_Mapping__c>> objectNameToUserMappingsListMap) {
		Set<Id> relatedAccountIdSet;
		Set<Id> rbiAccountIdSet;
		Set<Id> oppAccountIdSet;
		Set<Id> oppProductAccountIdSet;
		String namespace = UtilityController.appNamespace();
    	
    	// Get Account id set related to Reference Profiles which meet the given criteria
		if(objectNameToUserMappingsListMap.containsKey(namespace + 'Reference_Basic_Information__c')
        	&& objectNameToUserMappingsListMap.get(namespace + 'Reference_Basic_Information__c').size() > 0) {
			rbiAccountIdSet = new Set<Id>();
			String refProfileQuery = 'SELECT COUNT(Id), Account__c FROM Reference_Basic_Information__c WHERE Account__c != null';
			String refProfileWhereClause = UtilityController.createDynamicQuery(objectNameToUserMappingsListMap.get(namespace + 'Reference_Basic_Information__c'));
        	refProfileQuery = String.isNotBlank(refProfileWhereClause) ? (refProfileQuery + refProfileWhereClause) : refProfileQuery;
        	refProfileQuery += ' GROUP BY Account__c LIMIT ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());
        	
        	for(AggregateResult rbi : Database.query(refProfileQuery)) {
        		rbiAccountIdSet.add((ID)rbi.get(namespace + 'Account__c'));
        	}
		}
		
		// Get Account id set related to Opportunities which meet the given criteria
		if(objectNameToUserMappingsListMap.containsKey('Opportunity') && objectNameToUserMappingsListMap.get('Opportunity').size() > 0) {
			oppAccountIdSet = new Set<Id>();
			String opportunityQuery = 'SELECT COUNT(Id), AccountId FROM Opportunity WHERE AccountId != null';
			
			if(rbiAccountIdSet != null) {  
				opportunityQuery += ' AND AccountId IN :rbiAccountIdSet';
			} 
			
			String opportunityWhereClause = UtilityController.createDynamicQuery(objectNameToUserMappingsListMap.get('Opportunity'));
        	opportunityQuery = String.isNotBlank(opportunityWhereClause) ? (opportunityQuery + opportunityWhereClause) : opportunityQuery;
        	opportunityQuery += ' GROUP BY AccountId LIMIT ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());
        	
        	for(AggregateResult opp : Database.query(opportunityQuery)) {
        		oppAccountIdSet.add((ID)opp.get('AccountId'));
        	}
		}
		
		// Get Account id set related to Opportunity Products which meet the given criteria
		if(objectNameToUserMappingsListMap.containsKey('OpportunityLineItem') && objectNameToUserMappingsListMap.get('OpportunityLineItem').size() > 0) {
			oppProductAccountIdSet = new Set<Id>();
			String oppProductQuery = 'SELECT COUNT(Id), Opportunity.AccountId accountId FROM OpportunityLineItem WHERE Opportunity.AccountId != null';
			
			if(rbiAccountIdSet != null) {  
				oppProductQuery += ' AND Opportunity.AccountId IN :rbiAccountIdSet';
			} 
			
			if(oppAccountIdSet != null) {  
				oppProductQuery += ' AND Opportunity.AccountId IN :oppAccountIdSet';
			} 
			
			String oppProductWhereClause = UtilityController.createDynamicQuery(objectNameToUserMappingsListMap.get('OpportunityLineItem'));
        	oppProductQuery = String.isNotBlank(oppProductWhereClause) ? (oppProductQuery + oppProductWhereClause) : oppProductQuery;
        	oppProductQuery += ' GROUP BY Opportunity.AccountId LIMIT ' + (Limits.getLimitQueryRows() - Limits.getQueryRows());
        	
        	for(AggregateResult oppLI : Database.query(oppProductQuery)) {
        		oppProductAccountIdSet.add((ID)oppLI.get('accountId'));
        	}
		}
		
		if(oppProductAccountIdSet != null) {
			relatedAccountIdSet = oppProductAccountIdSet;
		} else if(oppAccountIdSet != null) {
			relatedAccountIdSet = oppAccountIdSet;
		} else if(rbiAccountIdSet != null) {
			relatedAccountIdSet = rbiAccountIdSet;
		}
	    return relatedAccountIdSet;
	}

	public class FieldWrapper {

		public String userMappingId { get; set; }
		public String label { get; set; }
		public String apiName { get; set; }
		public String fieldType { get; set; }
		public Boolean isSelected { get; set; }

		public FieldWrapper(String userMappingId, String label, String apiName, Boolean isSelected, String fieldType) {
			this.userMappingId = userMappingId;
			this.label = label;
			this.apiName = apiName;
			this.isSelected = isSelected;
			this.fieldType = fieldType;
		}
	}
	
	public class ListViewWrapper {

		public String userMappingId { get; set; }
		public String viewName { get; set; }
		public Boolean isSelected { get; set; }

		public ListViewWrapper(User_Mapping__c um) {
			this.userMappingId = um.Id;
			this.viewName = um.Field_API_Name__c;
			this.isSelected = false;
		}
	}
}