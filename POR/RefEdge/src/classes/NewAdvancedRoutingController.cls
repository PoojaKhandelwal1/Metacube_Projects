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
 * VF Page: NewAdvancedRouting.page
 * Description: Controller for creating new advanced routing records or editing existing advanced routing records.
 * Last Modified By: Rajesh @Feb 9 2017
 */
public with sharing class NewAdvancedRoutingController extends RefEdgeEditionFeatures {
	/**
     * Properties and variables
     */  
    public Advanced_Routing__c advRouting { get; set; }     
    public Custom_Settings__c cs { get; set; }   
    public List<SelectOption> pickListValues { get; set; }    
    public String accTeamObject { get; set; }    
    public String routingPicklist { get; set; }    
    public String selectedTerritoryName { get; set; }    
    public String selectedTerritoryId { get; set; }    
    public Boolean isTerritoryEnabled { get; set; }   	
   	public Boolean isEdit { get; set; }
   	
   	/**
     * Constructor
     */
    public NewAdvancedRoutingController(ApexPages.standardController controller) {    	
    	cs = UtilityController.getCustomSettings();
    	// Check user premission.
    	checkPermissions();
    	pickListValues = new List<SelectOption>();
    	advRouting = (Advanced_Routing__c)controller.getRecord();
    	accTeamObject = '';
    	routingPicklist = '';
    	isEdit = false;
    	
    	//if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory') || CRUDAndFLSCheckController.sObjectsMap.containsKey('territory2')) {
    	if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory') || CRUDAndFLSCheckController.sObjectsMap.containsKey('territory2')) {
    		isTerritoryEnabled = true;
    	} else {
    		isTerritoryEnabled = false;
    	}
    	
    	if (advRouting.Id != null) {
    		isEdit = true;
    		advRouting = [SELECT Id, Adv_Routing_Name__c, Territory_Id__c, Territory_Name__c, Adv_Routing_Client_Value__c, Adv_Routing_Attribute__c, Name
    						FROM Advanced_Routing__c WHERE Id = :advRouting.Id];
    	}
    	
    	if (advRouting != null && advRouting.Territory_Name__c != null && advRouting.Territory_Name__c != ''
    				&& advRouting.Territory_Id__c != null && advRouting.Territory_Id__c != '') {
    		selectedTerritoryName = advRouting.Territory_Name__c;
    		selectedTerritoryId = advRouting.Territory_Id__c;
    	}
    	
		if (cs.Adv_Rt_Acct_Team_Object__c != null && cs.Adv_Rt_Acct_Team_Object__c != '') {
			accTeamObject = cs.Adv_Rt_Acct_Team_Object__c;
		}

		if (cs.Adv_Rt_Acct_Team_Contact__c != null && cs.Adv_Rt_Acct_Team_Contact__c != '') {
			accTeamObject = 'Contact';
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
					pickListValues.add(new SelectOption(ple.getValue(), ple.getLabel()));
				}
			}
		}
    }
    
    /**
     * Method to save the advanced routing record
     * author: Gaurav Saini (4 Nov, 2016)
     */
    public PageReference Save() {    	
    	SavePoint sp = Database.setSavepoint();
    	
    	try {
    		if (checkPermissions()) {
	    		// if both selected territory id and name are blank
	    		if ((selectedTerritoryName == null || selectedTerritoryName == '') && (selectedTerritoryId == null || selectedTerritoryId == '')) {    			
	    			advRouting.Territory_Name__c = '';
	    			advRouting.Territory_Id__c = '';
	    		} else if ((selectedTerritoryId != null && selectedTerritoryId != '')
	    				&& (selectedTerritoryName != null && selectedTerritoryName != '')) {	// if both selected territory id and name are not blank
		    		
		    		String tempTerritoryDetails = getTerritoryDetails(selectedTerritoryName);
		    		
		    		if (tempTerritoryDetails.contains('@@@')) {
			    		advRouting.Territory_Name__c = tempTerritoryDetails.split('@@@')[1];
			    		advRouting.Territory_Id__c = tempTerritoryDetails.split('@@@')[0];
		    		} else if (tempTerritoryDetails == 'multiple') {
		    			ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.Label.Multiple_items_found));
	            		return null;
		    		} else if (tempTerritoryDetails == 'zero') {
		    			ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, 'Territory: No matches found'));
	            		return null;
		    		} else if (tempTerritoryDetails == '') {
	                    ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, 'Territory Management not enabled.'));
	            		return null;
	                }
	    		} else if ((selectedTerritoryId != null && selectedTerritoryId != '')
	    				&& (selectedTerritoryName == null || selectedTerritoryName == '')) {	// if only selected territory name is blank
	    			
	    			advRouting.Territory_Name__c = '';
	    			advRouting.Territory_Id__c = '';
	    		} else if ((selectedTerritoryId == null || selectedTerritoryId == '')
	    				&& (selectedTerritoryName != null && selectedTerritoryName != '')) {	// if only selected territory id is blank
	    			
	    			String tempTerritoryDetails = getTerritoryDetails(selectedTerritoryName);
		    		
		    		if (tempTerritoryDetails.contains('@@@')) {
			    		advRouting.Territory_Name__c = tempTerritoryDetails.split('@@@')[1];
			    		advRouting.Territory_Id__c = tempTerritoryDetails.split('@@@')[0];
		    		} else if (tempTerritoryDetails == 'multiple') {
		    			ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, system.Label.Multiple_items_found));
	            		return null;
		    		} else if (tempTerritoryDetails == 'zero') {
		    			ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, 'Territory: No matches found'));
	            		return null;
		    		} else if (tempTerritoryDetails == '') {
	                    ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, 'Territory Management not enabled.'));
	            		return null;
	                }
	    		}
	    		
	    		if (isEdit) {
					upsert advRouting;
	    		} else {
	        		insert advRouting;
				}
				isEdit = false;
	    		String returnURL = apexPages.currentPage().getParameters().get('retURL');
	    		
	    		//re #589 Open Redirect Vulnerability :-Validate URL and if retURL found blank then redirect to previous page.
	    		if (returnURL != null && returnURL != '') { 
					return UtilityController.redirectToSource(returnURL); 
				} else {
					return new Pagereference('/' + advRouting.Id);
				}
    		} else {
    			return null;
    		}
    				
    	} catch(Exception e) {
    		Apexpages.addMessages(e);
            Database.rollback(sp);
            return null;
    	}
    }
    
    /**
     * method to get the territory id based on the specified name
     * author: Gaurav Saini (4 Nov, 2016)
     */
	public String getTerritoryDetails(String territoryName) {
		String SOQLQuery = '';
		List<sObject> territoryList = new List<sObject>();
		String result = '';
		String searchValue = territoryName.replace('*', '%') + '%';
        searchValue = String.escapeSingleQuotes(searchValue);
        searchValue = '\'' + searchValue + '\'';
		
		if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory2')) {
			SOQLQuery = 'SELECT Name, Id ' + 
		        				'FROM Territory2 ' +
		        				'WHERE ParentTerritory2Id = null ' +
		        				'AND Name LIKE ' + searchValue +
		        				' ORDER BY Name ' +
		        				'LIMIT 201';
		} else if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory')) {
			SOQLQuery = 'SELECT Name, Id ' +
		        				'FROM Territory ' +
		        				'WHERE ParentTerritoryId = null ' +
		        				'AND Name LIKE ' + searchValue +
		        				' ORDER BY Name ' +
		        				'LIMIT 201';
		}
		
		if (SOQLQuery != '') {
			territoryList = Database.query(SOQLQuery);
			
			// return the id and name of the territory seperated by @@@ if exactly one record is found
			if (territoryList != null && territoryList.size() == 1) {
				result = (String)territoryList[0].get('Id') + '@@@' + (String)territoryList[0].get('Name');
			} else if (territoryList != null && territoryList.size() > 1) {	// return 'multiple' if more than one record is found
				result = 'multiple';
			} else if (territoryList != null && territoryList.size() == 0) { // return 'zero' if no records are found
				result = 'zero';
			}
		}
		return result;
	}
	
	 /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
        fieldMap.put(UtilityController.appNamespace() + 'Advanced_Routing__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Territory_Name__c',
        										UtilityController.appNamespace() + 'Territory_Id__c'});  
        										
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true); 
        return isUpsertPermission; 
    }
}