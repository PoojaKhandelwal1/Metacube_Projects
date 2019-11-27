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
 * Class: RFSearchController
 * Description: class called FROM RFSearchController to filter for all related mapping
 * Modified by: Rajesh @May 11 2017
 */
public with sharing class SearchRelatedMappingRecorsController {
	
    /**
     * Properties AND variables
     */
    public List<SearchClass> searchResults { get; set; }
    public String inputTextValue { get; set; }
    public String tempTextValue { get; set; }
    public Set<String> selectedValues;
    public List<SelectOption> pickListValue { get; set; }
    public Boolean isFieldPicklistType { get; set; }
    public List<String> alphabets { get; set; }
    public String attributeMappingId { get; set; }
    public Attribute_Mapping__c attMapping;
    //changes related to #864
    //public String pageName { get; set; }
    public String fieldName, ObjectName, relationShipName;
    public Map<String, List<String>> mappingSelectedValues { get; set; }
    public Map<String, List<String>> mappingSelectedValuesLabel { get; set; }
    public Boolean hasBulkRecords { get; set; }
    public Boolean showSearchBox { get; set; }
    public String selectedFilterName { get; set; }
    public String character { get; set; } 
    public Map<String, Set<String>> mappingRelatedContentIds, mappingRelatedAccountIds, mappingAccountIds, mappingRelatedContactIds, mappingContactIds;
	//REF-2114
    public Boolean isSearchedRecords { get; set; }
    public Boolean isAttributeSelected { get; set; }
    
	//	REF-2124
	public Boolean isHelpoverlay { get; set; }
    /**
     * Constructor
     */
    public SearchRelatedMappingRecorsController() {
        selectedValues = new Set<String>();
        searchResults = new List<SearchClass>();
        mappingSelectedValues = new Map<String, List<String>>();
        mappingSelectedValuesLabel = new Map<String, List<String>>();
        mappingRelatedContentIds = new Map<String, Set<String>>();
        mappingRelatedAccountIds = new Map<String, Set<String>>();
        mappingRelatedContactIds = new Map<String, Set<String>>();
        mappingAccountIds = new Map<String, Set<String>>();
        mappingContactIds = new Map<String, Set<String>>();
        alphabets = new List<String> {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', System.Label.All
        };
		isHelpoverlay = false;
    }
    
    /**
     * Method to show result according to selected alphabet
     */
    public void showResultAlphabet() {
    	
        if (character.trim().length() != 0) {
            searchResults = new List<SearchClass>();
            String query;
            character = String.escapeSingleQuotes(character);
            
            if (character != System.Label.All) {
                query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c 
                			+ ' WHERE ' + attMapping.Field_Api_Name__c + ' like \'' + String.escapeSingleQuotes(character) 
                			+ '%\' ORDER BY ' + attMapping.Field_Api_Name__c + ' LIMIT 201 ';
            } else {
                query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c 
	                		+ ' WHERE ' + attMapping.Field_Api_Name__c + ' != null  ORDER BY ' + attMapping.Field_Api_Name__c 
	                		+ ' LIMIT 5000';// + limits.getLimitQueryRows();//changes regarding #722
            }
            hasBulkRecords = false;
            showSearchBox = false;
            Set<String> duplicateCheck = new Set<String>();
            
            //changes related to #871
            if (attMapping.Object__c == ConstantsController.REFERENCE_PROFILE) {
        	
            	if (attMapping.Related_Object__c == 'Account') {
		            		
		            if (character != System.Label.All) {
		                query = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
	            			+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.' + attMapping.Field_Api_Name__c + ' like \'' 
	            			+ String.escapeSingleQuotes(character) + '%\' '
	            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
            				+ '\' AND Referenceability_Status__c != null LIMIT ' + limits.getLimitQueryRows();
		            } else {
		                query = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
	            			+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.' + attMapping.Field_Api_Name__c + ' != null '
	            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
            				+ '\' AND Referenceability_Status__c != null LIMIT ' + limits.getLimitQueryRows();
		            }
	        		
	                for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, new Set<String>())) {
		            	
		                if (!duplicateCheck.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase()) 
		                			&& !selectedValues.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
		                    duplicateCheck.add(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
		                    SearchClass sc = new SearchClass(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)), 
		                    									String.valueOf(so.get('Account__c')));
		                    searchResults.add(sc);
		                } else if (selectedValues.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase()) 
		                			&& !duplicateCheck.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
		                    SearchClass sc = new SearchClass(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)), 
		                    									String.valueOf(so.get('Account__c')));
		                    sc.isSelected = true;
		                    duplicateCheck.add(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
		                    searchResults.add(sc);
		                }
		                
		                if (searchResults.size() == 201) {
		                    showSearchBox = true;
		                    hasBulkRecords = true;
		                    break;
		                }
		            }
	        	} else if (attMapping.Related_Object__c == 'Contact') {
	        		
	        		if (character != System.Label.All) {
		                query = 'SELECT Id, Contact__c, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
	            			+ ' WHERE Contact__c != null AND Account__c != null AND Contact__r.' + attMapping.Field_Api_Name__c + ' like \'' 
	            			+ String.escapeSingleQuotes(character) + '%\' '
	            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
            				+ '\' AND Referenceability_Status__c != null LIMIT ' + limits.getLimitQueryRows();
		            } else {
		                query = 'SELECT Id, Contact__c, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
	            			+ ' WHERE Contact__c != null AND Account__c != null AND Contact__r.' + attMapping.Field_Api_Name__c + ' != null '
	            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
            				+ '\' AND Referenceability_Status__c != null LIMIT ' + limits.getLimitQueryRows();
		            }
		            
	                for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, new Set<String>())) {
		            	
		                if (!duplicateCheck.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase()) 
		                			&& !selectedValues.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
		                    duplicateCheck.add(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
		                    SearchClass sc = new SearchClass(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)), 
		                    									String.valueOf(so.get('Contact__c')));
		                    searchResults.add(sc);
		                } else if (selectedValues.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase()) 
		                			&& !duplicateCheck.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
		                    SearchClass sc = new SearchClass(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)), 
		                    									String.valueOf(so.get('Contact__c')));
		                    sc.isSelected = true;
		                    duplicateCheck.add(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
		                    searchResults.add(sc);
		                }
		                
		                if (searchResults.size() == 201) {
		                    showSearchBox = true;
		                    hasBulkRecords = true;
		                    break;
		                }
		            }
	        	}
            } else {
        	
	            if (character != System.Label.All) {
	                query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c 
	                			+ ' WHERE ' + attMapping.Field_Api_Name__c + ' like \'' + String.escapeSingleQuotes(character) 
	                			+ '%\' ORDER BY ' + attMapping.Field_Api_Name__c + ' LIMIT 201 ';
	            } else {
	                query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c 
		                		+ ' WHERE ' + attMapping.Field_Api_Name__c + ' != null  ORDER BY ' + attMapping.Field_Api_Name__c 
		                		+ ' LIMIT 5000';// + limits.getLimitQueryRows();//changes regarding #722
	            }
	            //changes regarding #722
	            for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, new Set<String>())) {
	            	
	                if (!duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase()) 
	                			&& !selectedValues.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
	                    duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
	                    SearchClass sc = new SearchClass(String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')));
	                    searchResults.add(sc);
	                } else if (selectedValues.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase()) 
	                			&& !duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
	                    SearchClass sc = new SearchClass(String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')));
	                    sc.isSelected = true;
	                    duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
	                    searchResults.add(sc);
	                }
	                
	                if (searchResults.size() == 201) {
	                    showSearchBox = true;
	                    hasBulkRecords = true;
	                    break;
	                }
	            }
            }
            
            if (searchResults.size() > 200) {
                searchResults.remove(200);
                hasBulkRecords = true;
                showSearchBox = true;
            }
            searchResults.sort();
        }
    }
    
    /**
     * Method to redirect on Ref Search page
     */
    public pageReference getAllTheResults() {
    	//changes related to #864
        /*if (pageName == 'lead') {
            return Page.RfSearchPageLead;
        }*/
		//REF-2114
        isSearchedRecords = false;
        isAttributeSelected = false;
		isHelpoverlay = true;
        return Page.RfSearchPage;
    }
    
    /**
     * Method to get the result
     */
    public void getTheResults() {
    	tempTextValue = '';
        String query;
        String values = '';
        
        if (attMapping.Is_Related_MultiSelectPicklist__c) {
        	values = '';
            
            for (String selected : selectedValues) {
            	
                if (values == '') {
                    values += '\'' + String.escapeSingleQuotes(selected) + '\'';
                } else {
                    values += ',\'' + String.escapeSingleQuotes(selected) + '\'';
                }
            }
        }
        
        //if attribute mapping from reference profile related #639
        if (attMapping.Object__c == ConstantsController.REFERENCE_PROFILE) {
        	
        	if (attMapping.Related_Object__c == 'Account') {
        		query = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
            			+ ' WHERE Contact__c = null AND Account__c != null '
            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
        				+ '\' AND Referenceability_Status__c != null ';
        	} else if (attMapping.Related_Object__c == 'Contact') {
        		query = 'SELECT Id, Contact__c, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
            			+ ' WHERE Contact__c != null AND Account__c != null '
            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
        				+ '\' AND Referenceability_Status__c != null ';
        	}
        	
        	if (!attMapping.Is_Related_MultiSelectPicklist__c) {
        		
        		if (attMapping.Related_Object__c == 'Account') {
	        		query += 'AND Account__r.' + attMapping.Field_Api_Name__c + ' IN :selectedValues LIMIT ' + limits.getLimitQueryRows();
	        	} else if (attMapping.Related_Object__c == 'Contact') {
	        		query += 'AND Contact__r.' + attMapping.Field_Api_Name__c + ' IN :selectedValues LIMIT ' + limits.getLimitQueryRows();
	        	}
	        } else {
	            
	            //the reference profile is queried directly 
	            if (attMapping.Related_Object__c == 'Account') {
	        		query += 'AND Account__r.' + attMapping.Field_Api_Name__c + ' INCLUDES (' + values + ' ) LIMIT ' + limits.getLimitQueryRows();
	        	} else if (attMapping.Related_Object__c == 'Contact') {
	        		query += 'AND Contact__r.' + attMapping.Field_Api_Name__c + ' INCLUDES (' + values + ' ) LIMIT ' + limits.getLimitQueryRows();
	        	}
	        }
	        Set<String> relatedObjectIds = new Set<String>();
	        
	        for (sObject so : WithoutSharingHelperController.filterRecords(query, attMapping, values, selectedValues)) {
		        	
	        	if (attMapping.Related_Object__c == 'Account') {
	        		relatedObjectIds.add(String.valueOf(so.get('Account__c')));
	        	} else if (attMapping.Related_Object__c == 'Contact') {
	        		relatedObjectIds.add(String.valueOf(so.get('Contact__c')));
	        	}
	        }
	        
	        if (attMapping.Related_Object__c == 'Account') {
        		mappingAccountIds.put(attMapping.Id, relatedObjectIds);
        	} else if (attMapping.Related_Object__c == 'Contact') {
        		mappingContactIds.put(attMapping.Id, relatedObjectIds);
        	}
        } else {
        	Set<String> relatedAccIds, relatedContactIds, relatedContentIds;
        	query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c 
	            			+ ' WHERE ' + attMapping.Field_Api_Name__c;
	        if (!attMapping.Is_Related_MultiSelectPicklist__c) {
	            query += ' IN :selectedValues LIMIT 2001';
	        } else {
	            query += ' INCLUDES (' + values + ' ) LIMIT 2001';
	        }
	        Set<String> relatedObjectIds = new Set<String>();
	        
	        for (sObject so : WithoutSharingHelperController.filterRecords(query, attMapping, values, selectedValues)) {
	        	relatedObjectIds.add(String.valueOf(so.get('Id')));
	        }
	        
	        if (attMapping.Mapping_Type__c == 'Parent Object') {
	        	
	            if (attMapping.Object__c == 'Reference Content') {
	                query = 'SELECT Id FROM Reference_Content__c WHERE ' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds';
	                relatedContentIds = new Set<String>();
	                
	                for (sObject rc : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, relatedObjectIds)) {
	                    relatedContentIds.add(String.valueOf(rc.get('Id')));
	                }
	                mappingRelatedContentIds.put(attMapping.Id, relatedContentIds);
	            }
	            
	            if (attMapping.Object__c == 'Account') {
	                relatedAccIds = new Set<String>();
	                //related to #828
	                query = 'SELECT Id, Account__c FROM Reference_Basic_Information__c '
	            			+ ' WHERE Contact__c = null AND Account__c != null '
	            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
	        				+ '\' AND Referenceability_Status__c != null '
	        				+ 'AND Account__r.' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds LIMIT ' + limits.getLimitQueryRows();
	                //query = 'SELECT Id FROM Account WHERE ' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds';
	                
	                for (sObject rc : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, relatedObjectIds)) {
	                    relatedAccIds.add(String.valueOf(rc.get('Account__c')));
	                }
	                mappingRelatedAccountIds.put(attMapping.Id, relatedAccIds);
	            }
	            
	            if (attMapping.Object__c == 'Contact') {
	                relatedContactIds = new Set<String>();
	                //related to #828
	                query = 'SELECT Id, Contact__c FROM Reference_Basic_Information__c '
	            			+ ' WHERE Contact__c != null AND Account__c != null '
	            			+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
	        				+ '\' AND Referenceability_Status__c != null '
	        				+ 'AND Contact__r.' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds LIMIT ' + limits.getLimitQueryRows();
	                //query = 'SELECT Id FROM Contact WHERE ' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds';
	                
	                for (sObject rc : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, relatedObjectIds)) {
	                    relatedContactIds.add(String.valueOf(rc.get('Contact__c')));
	                }
	                mappingRelatedContactIds.put(attMapping.Id, relatedContactIds);
	            }
	        } else if (attMapping.Mapping_Type__c == 'Child Object') {
	        	
	            if (attMapping.Object__c == 'Contact') {
	                relatedContactIds = new Set<String>();
	                query = 'SELECT Id,' + attMapping.RelationShip_Name__c + ' FROM ' + attMapping.Related_Object__c 
	                				+ ' WHERE Id  IN :relatedObjectIds AND ' + attMapping.RelationShip_Name__c + ' != null';
	                
	                for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, relatedObjectIds)) {
	                    relatedContactIds.add(String.valueOf(so.get(attMapping.RelationShip_Name__c)));
	                }
	                mappingRelatedContactIds.put(attMapping.Id, relatedContactIds);
	            }
	            
	            if (attMapping.Object__c == 'Reference Content') {
	                relatedContentIds = new Set<String>();
	                query = 'SELECT Id,' + attMapping.RelationShip_Name__c + ' FROM ' + attMapping.Related_Object__c 
	                				+ ' WHERE Id  IN :relatedObjectIds AND ' + attMapping.RelationShip_Name__c + ' != null';
	                
	                for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, relatedObjectIds)) {
	                    relatedContentIds.add(String.valueOf(so.get(attMapping.RelationShip_Name__c)));
	                }
	                mappingRelatedContentIds.put(attMapping.Id, relatedContentIds);
	            }
	            
	            if (attMapping.Object__c == 'Account') {
	                relatedAccIds = new Set<String>();
	                query = 'SELECT Id,' + attMapping.RelationShip_Name__c + ' FROM  ' + attMapping.Related_Object__c 
	                				+ ' WHERE Id  IN :relatedObjectIds AND ' + attMapping.RelationShip_Name__c + ' != null';
	                
	                for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, relatedObjectIds)) {
	                    relatedAccIds.add(String.valueOf(so.get(attMapping.RelationShip_Name__c)));
	                }
	                mappingRelatedAccountIds.put(attMapping.Id, relatedAccIds);
	            }
	        }
        }
        
        if (mappingSelectedValues != null && mappingSelectedValues.containsKey(attMapping.Id) && mappingSelectedValues.get(attMapping.Id).size() == 0) {
            mappingRelatedAccountIds.remove(attMapping.Id);
            mappingRelatedContactIds.remove(attMapping.Id);
            mappingRelatedContentIds.remove(attMapping.Id);
            //related #639
            mappingAccountIds.remove(attMapping.Id);
            mappingContactIds.remove(attMapping.Id);
        }
    }
    
    /**
     * Method to search the record
     */
    public void searchRecords() {
        searchResults = new List<SearchClass>();
        inputTextValue = String.escapeSingleQuotes(inputTextValue);
		
		if (attMapping.Object__c == ConstantsController.REFERENCE_PROFILE) {
                    
			if (attMapping.Related_Object__c == 'Account') {
				String dynamicQuery = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
						+ ' WHERE Contact__c = null AND Account__c != null AND Account__r.' + attMapping.Field_Api_Name__c + ' != null '
						+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
						+ '\' AND Referenceability_Status__c != null '
						+ ' AND Account__r.' + attMapping.Field_Api_Name__c + ' like \'%' + String.escapeSingleQuotes(inputTextValue) 
						+ '%\' ORDER BY Account__r.' + attMapping.Field_Api_Name__c + ' limit 201 ';
				Set<String> duplicateCheck = new Set<String>();
				
				for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(dynamicQuery)) {
					
					if (!duplicateCheck.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
						duplicateCheck.add(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
						SearchClass sc = new SearchClass(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)), 
		                    									String.valueOf(so.get('Account__c')));
						searchResults.add(sc);
					}
					
					if (searchResults.size() >= 200) {
						break;
					}
				}
			} else if (attMapping.Related_Object__c == 'Contact') {
				String dynamicQuery = 'SELECT Id, Contact__c, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
						+ ' WHERE Contact__c != null AND Account__c != null AND Contact__r.' + attMapping.Field_Api_Name__c + ' != null '
						+ 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
						+ '\' AND Referenceability_Status__c != null '
						+ ' AND Contact__r.' + attMapping.Field_Api_Name__c + ' like \'%' + String.escapeSingleQuotes(inputTextValue) 
						+ '%\' ORDER BY Contact__r.' + attMapping.Field_Api_Name__c + ' limit 201 ';
				Set<String> duplicateCheck = new Set<String>();

				for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(dynamicQuery)) {
				
					if (!duplicateCheck.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
						duplicateCheck.add(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
						SearchClass sc = new SearchClass(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)), 
		                    									String.valueOf(so.get('Contact__c')));
						searchResults.add(sc);
					}
					
					if (searchResults.size() >= 200) {
						break;
					}
				}
			}
		} else {
			String query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c + ' WHERE ' 
								+ attMapping.Field_Api_Name__c + ' like \'%' + String.escapeSingleQuotes(inputTextValue) 
								+ '%\' ORDER BY ' + attMapping.Field_Api_Name__c + ' LIMIT 201 ';
			hasBulkRecords = false;
			Set<String> duplicateCheck = new Set<String>();
			
			//changes regarding #722
			for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, new Set<String>())) {
				
				if (!duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase()) 
						&& !selectedValues.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
					duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
					SearchClass sc = new SearchClass(String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')));
					searchResults.add(sc);
				} else if (selectedValues.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase()) 
						&& !duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
					SearchClass sc = new SearchClass(String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')));
					sc.isSelected = true;
					duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
					searchResults.add(sc);
				}
			}
		}
		//REF-2114
		isSearchedRecords = true;

        if (searchResults.size() > 200) {
            searchResults.remove(200);
            hasBulkRecords = true;
        }
        searchResults.sort();
    }
    
    /**
     * Method to save the selected attribute
     */
    public void saveTheSelected() {
    	
        for (SearchClass sc : searchResults) {
        	
            if (sc.label == inputTextValue) {
            	
                if (sc.isSelected) {
                    sc.isSelected = false;
                    
                    if (isFieldPicklistType) {
                    	selectedValues.remove(sc.recId.trim().tolowerCase());
                    } else {
                    	selectedValues.remove(sc.label.trim().tolowerCase());
                    }
                    List<String> tempList = new List<String>();
                    List<String> tempList1 = new List<String>();
                    
                    for (String str : mappingSelectedValues.get(attMapping.Id)) {
                    	
                        if ((isFieldPicklistType && str != sc.recId) || (!isFieldPicklistType && str != sc.label)) {
                        	tempList.add(str.trim());
                        }
                    }
                    
                    for (String str : mappingSelectedValuesLabel.get(attMapping.Id)) {
                    	
                        if (str != sc.label) {
                        	tempList1.add(str.trim());
                        }
                    }
					mappingSelectedValuesLabel.put(attMapping.Id, tempList1);
                    mappingSelectedValues.put(attMapping.Id, tempList);
                    
                } else {
                    sc.isSelected = true;
                    
					if (isFieldPicklistType) {
						mappingSelectedValues.get(attMapping.Id).add(sc.recId.trim());
						mappingSelectedValuesLabel.get(attMapping.Id).add(sc.label.trim());
						//changes regarding #657 
	                    selectedValues.add(sc.recId.tolowerCase());
					} else {
	                    mappingSelectedValues.get(attMapping.Id).add(sc.label.trim());
	                    mappingSelectedValuesLabel.get(attMapping.Id).add(sc.label.trim());
	                    //changes regarding #657 
	                    selectedValues.add(sc.label.tolowerCase());
					}
                }
            }
        }
        List<String> tempList = mappingSelectedValues.get(attMapping.Id);
        
        if (tempList.size() > 0) {
            List<String> tempList1 = new List<String>();
            
            for (String str : tempList) {
                tempList1.add(str.tolowerCase());
            }
            tempList1.sort();
            mappingSelectedValues.put(attMapping.Id, tempList1);
        }
        tempList = mappingSelectedValuesLabel.get(attMapping.Id);
        
        if (tempList.size() > 0) {
            List<String> tempList1 = new List<String>();
            
            for (String str : tempList) {
                tempList1.add(str);
            }
            tempList1.sort();
            mappingSelectedValuesLabel.put(attMapping.Id, tempList1);
        }
        getTheResults();
    }
    
    /**
     * Wrapper Class
     */
    public class SearchClass implements Comparable{
        public String label { get; set; }
        public String recId { get; set; }
        public Boolean isSelected { get; set; }
        
        public SearchClass(String label, String recId) {
            this.label = label;
            this.recId = recId;
            isSelected = false;
        }
        public Integer compareTo(Object obj) {
		    SearchClass searchObject = (SearchClass)(obj);
		
		    if (this.label.compareTo(searchObject.label) > 0) {
		        return 1;
		    }
		
		    if (this.label.compareTo(searchObject.label) == 0) {
		        return 0;
		    }
		
		    return -1;
		}
    }
}