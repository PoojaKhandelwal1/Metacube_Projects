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
 * VF Page: CustomLookup.page
 * Description: Controller for the custom lookup page. This class populates the list of records 
 *				in the custom lookup window.
 * Last Modified By: Gaurav Saini (21 Feb, 2017)
 */
public with sharing class CustomLookupController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public string searchText { get; set; }
    public List<sObject> recordsList { get; set; }
    public String objectName { get; set; }
    public Boolean isCandidateRequest { get; set; }
    // added for #382 - picklist values to be shown in lookup window on create new advanced routing object
    public Boolean isAdvancedRouting { get; set; }
    // list of available business groups
    public List<SelectOption> picklistValues { get; set; }
    
    /**
     * Constructor
     */
    public CustomLookupController() {
        searchText = '';
        isAdvancedRouting = false;
        picklistValues = new List<SelectOption>();
        String recordName = ApexPages.currentPage().getParameters().get('strText');
        
        if (ApexPages.currentPage().getParameters().get('obj') != null) {
        	objectName = ApexPages.currentPage().getParameters().get('obj');
        } else {
        	objectName = '';
        	isAdvancedRouting = true;
        }
        searchText = recordName;
    	search();
    }
    
    /**
     * Method to Search Contacts
     */
    public Pagereference search() {
        
        if (!isAdvancedRouting) {
	        
	        if (objectName == 'Reference_Content__c') {
		        
		        if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            searchValue = '\'' + searchValue + '\'';
		            String soqlQuery = 'SELECT Id, Name, Title__c, Reference_Content_Type__c, Attributes__c, ' +
		            					'Reference_Content_Type__r.Name__c, Review_Date__c, Language__c ' +
		            					'FROM Reference_Content__c ' +
		            					'WHERE Title__c LIKE ' + searchValue +
		            					' OR Reference_Content_Type__r.Name__c LIKE ' + searchValue +
		            					' OR Name LIKE ' + searchValue +
		            					' ORDER BY Title__c, Reference_Content_Type__r.Name__c ' +
		            					'LIMIT 201';
		            recordsList = Database.query(soqlQuery);
		        } else {
		            recordsList = [SELECT Id, Name, Title__c, Reference_Content_Type__c, Language__c,
	            						Reference_Content_Type__r.Name__c, Review_Date__c, Attributes__c
	            					FROM Reference_Content__c
	            					ORDER BY Title__c, Reference_Content_Type__r.Name__c
	            					LIMIT 201];
		        }
	        } else if (objectName == 'Content_Collection__c') {
	        	
	        	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            searchValue = '\'' + searchValue + '\'';
		            String soqlQuery = 'SELECT Id, Name, Active__c, Collection__c, Content_Count__c, Description__c ' +
		            						'FROM Content_Collection__c ' +
		            						'WHERE Collection__c LIKE ' + searchValue +
		            						' OR Name LIKE ' + searchValue +
		            						' ORDER BY Collection__c ' +
		            						'LIMIT 201';
		            recordsList = Database.query(soqlQuery);
		        } else {
		            recordsList = [SELECT Id, Name, Active__c, Collection__c, Content_Count__c, Description__c
		            				FROM Content_Collection__c
		            				ORDER BY Collection__c
		            				LIMIT 201];
		        }
	        } else if (objectName == 'User') {
	        	
	        	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            searchValue = '\'' + searchValue + '\'';
		            String soqlQuery = 'SELECT Id, Name, UserRole.Name' +
		            						' FROM User' +
		            						' WHERE UserRole.Name LIKE ' + searchValue +
		            						' OR Name LIKE ' + searchValue +
		            						' ORDER BY Name ' +
		            						'LIMIT 201'; 
		            recordsList = Database.query(soqlQuery);
		        } else {
		            recordsList = [SELECT Id, Name, UserRole.Name
		            				FROM User Where Name!= null
		            				ORDER BY Name
		            				LIMIT 201];
		        }
		        
	        } else if (objectName == 'territory') {
	        	
	        	if (searchText != null && searchText.trim().length() > 0) {
		            String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            searchValue = '\'' + searchValue + '\'';
		            String soqlQuery;
		            
		            if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory2')) {
			            soqlQuery = 'SELECT ParentTerritory2Id, Name, Id ' +
			            				'FROM Territory2 ' +
			            				'WHERE ParentTerritory2Id = null ' +
			            				'AND Name LIKE ' + searchValue +
			            				' ORDER BY Name ' +
			            				'LIMIT 201';
		            	recordsList = Database.query(soqlQuery);
		            } else if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory')) {
		            	soqlQuery = 'SELECT ParentTerritoryId, Name, Id ' +
		            					'FROM Territory ' +
		            					'WHERE ParentTerritoryId = null ' +
		            					'AND Name LIKE ' + searchValue +
		            					' ORDER BY Name ' +
		            					'LIMIT 201';
		            	recordsList = Database.query(soqlQuery);
		            }
		            
		            if (recordsList == null || recordsList.size() == 0) {
		            	recordsList = new List<sObject>();
		            }
		        } else {
		        	String soqlQuery;
		        	
		        	if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory2')) {
			            soqlQuery = 'SELECT ParentTerritory2Id, Name, Id ' +
			            				'FROM Territory2 ' +
			            				'WHERE ParentTerritory2Id = null ' +
			            				'ORDER BY Name LIMIT 201';
		            	recordsList = Database.query(soqlQuery);
		            } else if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory')) {
		            	soqlQuery = 'SELECT ParentTerritoryId, Name, Id ' +
		            					'FROM Territory ' +
		            					'WHERE ParentTerritoryId = null ' +
		            					'ORDER BY Name LIMIT 201';
		            	recordsList = Database.query(soqlQuery);
		            }
		            
		            if (recordsList == null || recordsList.size() == 0) {
		            	recordsList = new List<sObject>();
		            }
		        }
	        } else if (objectName == 'document') {
                
                if (searchText != null && searchText.trim().length() > 0) {
                    String searchValue = searchText.replace('*', '%') + '%';
		            searchValue = String.escapeSingleQuotes(searchValue);
		            searchValue = '\'' + searchValue + '\'';
		            String soqlQuery;
                    soqlQuery = 'SELECT Id, Name, DeveloperName FROM Document ' +
                                    'WHERE ContentType LIKE \'image%\' ' +
                                    'AND Name LIKE ' + searchValue +
                                    ' ORDER BY Name ' +
                                    'LIMIT 201';
                    recordsList = Database.query(soqlQuery);

		            if (recordsList == null || recordsList.size() == 0) {
		            	recordsList = new List<sObject>();
		            }
                } else {
                    recordsList = [SELECT Id, Name, DeveloperName FROM Document
                                    WHERE ContentType LIKE 'image%'
		            				ORDER BY Name
		            				LIMIT 201];
                }
            }
        } else {
        	Custom_Settings__c cs = UtilityController.getCustomSettings();
        	String accTeamObject = '';
        	String routingPicklist = '';
        	
        	if (cs.Adv_Rt_Acct_Team_Object__c != null && cs.Adv_Rt_Acct_Team_Object__c != '') {
				accTeamObject = cs.Adv_Rt_Acct_Team_Object__c;
			}
			
			if (cs.Adv_Rt_Acct_Team_Routeby__c != null && cs.Adv_Rt_Acct_Team_Routeby__c != '') {
				routingPicklist = cs.Adv_Rt_Acct_Team_Routeby__c;
			}
			
			if (accTeamObject != '') {
				Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get(accTeamObject);
				Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
				
				if (routingPicklist != '') {
					Schema.SObjectField field = objDescribe.fields.getMap().get(routingPicklist);
					Schema.DescribeFieldResult dfr = field.getDescribe();
					
					for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
						
						if (searchText != null && searchText.trim().length() > 0) {
							
							if (ple.getValue().contains(searchText)) {
								picklistValues.add(new SelectOption(ple.getValue(), ple.getLabel()));
							}
						} else {
							picklistValues.add(new SelectOption(ple.getValue(), ple.getLabel()));
						}
					}
				}
			}
        }
        return null;
    }
}