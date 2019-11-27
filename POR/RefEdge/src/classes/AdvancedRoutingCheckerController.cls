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
 * VF Page: AdvancedRoutingChecker.page
 * Description: Controller for advanced routing checker page.
 * Last Modified By: Rajesh @Feb 14 2017 
 */
public with sharing class AdvancedRoutingCheckerController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Custom_Settings__c cs { get; set; }
    public Boolean isAdvRoutingTableComplete { get; set; }
    public Map<String, Label__c> filterMap { get; set; }
    public List<String> currentlyShownFilterIds { get; set; }
    public Boolean showFilterPopup { get; set; }
    public String selectedFilterId { get; set; }
    public Label__c selectedFilterObj { get; set; }
    public List<SelectOption> filterListForModal { get; set; }
    public Boolean isFilterEdit { get; set; }
    public Boolean isError { get; set; }
    public Boolean isGroupError { get; set; }
    public List<SelectOption> advRoutingGroupsList { get; set; }
    public String accTeamObject { get; set; }
    public String routingPicklist { get; set; }
	public String rolePicklist { get; set; }
	public String roleIncludedPicklist { get; set; }
    public String previousRoutingGroup { get; set; }
    public Boolean previousShowInP2P { get; set; }
    public Boolean previousRequiredInP2P { get; set; }
    public Boolean showInP2PValue { get; set; }
    public String selectedRoutingGroupTemp { get; set; }
    public String accTeamObjLabel { get; set; }
    public String routingPicklistLabel { get; set; }
	public String rolePicklistLabel { get; set; }
    public String userFieldLabel { get; set; }
	public String contactFieldLabel { get; set; }
    public Boolean showGroupsPopup { get; set; }
    //Added to get custom object KeyPrefix
    public String objIdPrefix { get; set; }
    // added for #465 - flag to show message to user if save is clicked without selecting a filter
    public Boolean isFilterSelectedBeforeSave { get; set; }
    
    /**
     * Constructor
     */
    public AdvancedRoutingCheckerController() {
        cs = UtilityController.getCustomSettings();
        //Check for User premission
        checkPermissions();
        isAdvRoutingTableComplete = true;
        showFilterPopup = false;
        isFilterEdit = false;
        isError = false;
        isGroupError = false;
        showInP2PValue = true;
        isFilterSelectedBeforeSave = true;
        accTeamObjLabel = '';
        routingPicklistLabel = '';
		rolePicklistLabel = '';
		roleIncludedPicklist = '';
        userFieldLabel = '';
        contactFieldLabel = '';
        showGroupsPopup = false;
        currentlyShownFilterIds = new List<String>();
        advRoutingGroupsList = new List<SelectOption>();
        advRoutingGroupsList.add(new SelectOption('', '--None--'));
        accTeamObject = '';
        routingPicklist = '';
		rolePicklist = '';
        //re 908 - ISSUE - Baxter - Lightning - Advanced Routing
        Schema.DescribeSObjectResult result = Advanced_Routing__c.SObjectType.getDescribe(); 
        objIdPrefix =  result.getKeyPrefix();
        
        // getting all the filters which are currently marked for Advanced Routing P2P requests
        filterMap = new Map<String, Label__c>([SELECT Show_in_P2P__c, Required_in_P2P__c, Name, Id, Adv_Routing_Group__c FROM Label__c
                                               WHERE Show_in_P2P__c = true ORDER BY Name]);
        
        if (filterMap != null && filterMap.keySet().size() > 0) {
            currentlyShownFilterIds.addAll(filterMap.keySet());
        }
        
        if (cs.Adv_Rt_Acct_Team_Object__c != null && cs.Adv_Rt_Acct_Team_Object__c != '') {
            accTeamObject = cs.Adv_Rt_Acct_Team_Object__c;
        }
        
        if (cs.Adv_Rt_Acct_Team_Routeby__c != null && cs.Adv_Rt_Acct_Team_Routeby__c != '') {
            routingPicklist = cs.Adv_Rt_Acct_Team_Routeby__c;
        }

		if (cs.Adv_Rt_Acct_Team_Role_Picklist__c != null && cs.Adv_Rt_Acct_Team_Role_Picklist__c != '') {
            rolePicklist = cs.Adv_Rt_Acct_Team_Role_Picklist__c;
        }

		if (cs.Adv_Rt_Acct_Team_Roles_to_Include__c != null && cs.Adv_Rt_Acct_Team_Roles_to_Include__c != '') {
            roleIncludedPicklist = cs.Adv_Rt_Acct_Team_Roles_to_Include__c;
        }
        
        if (accTeamObject != '') {
            Schema.SObjectType objType = CRUDAndFLSCheckController.sObjectsMap.get(accTeamObject);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            accTeamObjLabel = objDescribe.getLabel();
            
			if (rolePicklist != null && rolePicklist != '') {
				Schema.SObjectField field = objDescribe.fields.getMap().get(rolePicklist);
				Schema.DescribeFieldResult dfr = field.getDescribe();
				rolePicklistLabel = dfr.getLabel();
			}

            if (cs.Adv_Rt_Acct_Team_Contact__c != null && cs.Adv_Rt_Acct_Team_Contact__c != '') {
                Schema.SObjectField field1 = objDescribe.fields.getMap().get(cs.Adv_Rt_Acct_Team_Contact__c);
                Schema.DescribeFieldResult dfr = field1.getDescribe();
                contactFieldLabel = dfr.getLabel();
                Schema.SObjectType objTypeContact = CRUDAndFLSCheckController.sObjectsMap.get('Contact');
                Schema.DescribeSObjectResult objDescribeContact = objTypeContact.getDescribe();
                
                if (cs.Adv_Rt_Acct_Team_User__c != null && cs.Adv_Rt_Acct_Team_User__c != '') {
                    Schema.SObjectField fieldUser = objDescribeContact.fields.getMap().get(cs.Adv_Rt_Acct_Team_User__c);
                    Schema.DescribeFieldResult dfrUser = fieldUser.getDescribe();
                    userFieldLabel = dfrUser.getLabel();
                }
                if (routingPicklist != '') {
                    Schema.SObjectField fieldPicklist = objDescribeContact.fields.getMap().get(routingPicklist);
                    Schema.DescribeFieldResult dfrPicklist = fieldPicklist.getDescribe();
                    routingPicklistLabel = dfrPicklist.getLabel();
                }
            } else {
                if (cs.Adv_Rt_Acct_Team_User__c != null && cs.Adv_Rt_Acct_Team_User__c != '') {
                    Schema.SObjectField field1 = objDescribe.fields.getMap().get(cs.Adv_Rt_Acct_Team_User__c);
                    Schema.DescribeFieldResult dfr = field1.getDescribe();
                    userFieldLabel = dfr.getLabel();
                }
                if (routingPicklist != '') {
                    Schema.SObjectField field = objDescribe.fields.getMap().get(routingPicklist);
                    Schema.DescribeFieldResult dfr = field.getDescribe();
                    routingPicklistLabel = dfr.getLabel();
                }
            }
        }
        
        bindAdvancedRoutingGroup(); 
        
        filterListForModal = new List<SelectOption>();
        filterListForModal.add(new SelectOption('', '--None--'));
        
        // getting the filters to show in the add filter modal
        for (Label__c filter : [SELECT Name, Id FROM Label__c WHERE Id NOT IN :currentlyShownFilterIds]) {
            filterListForModal.add(new SelectOption(filter.Id, filter.Name));
        }
        checkMappingTable();
    }
    
    /**
     * Description: method to populate the routing groups picklist in the add filter modal
     *				with the values from the mapping table records.
     * 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public void bindAdvancedRoutingGroup() {
    	List<Advanced_Routing__c> advRoutingList = [SELECT Id, Adv_Routing_Client_Value__c FROM Advanced_Routing__c WHERE Adv_Routing_Client_Value__c != null
    													ORDER BY Adv_Routing_Client_Value__c LIMIT :limits.getLimitQueryRows()];
		
		if (advRoutingList != null && advRoutingList.size() > 0) {
			advRoutingGroupsList = new List<SelectOption>();
			advRoutingGroupsList.add(new SelectOption('', '--None--'));
			
			for (Advanced_Routing__c ar : advRoutingList) {
				advRoutingGroupsList.add(new SelectOption(ar.Adv_Routing_Client_Value__c, ar.Adv_Routing_Client_Value__c));
			}
		}
	}
	
	/**
     * Description: method to check if the mapping table is complete or not. 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
    public void checkMappingTable() {
    	List<Advanced_Routing__c> advRoutingList = [SELECT Adv_Routing_Attribute__c, Adv_Routing_Client_Value__c
    													FROM Advanced_Routing__c
    													LIMIT :limits.getLimitQueryRows()];
    	
    	if (advRoutingList == null || advRoutingList.size() == 0) {
    		isAdvRoutingTableComplete = false;
    	}
    	
    	if (isAdvRoutingTableComplete) {
	    	
	    	for (Advanced_Routing__c ar : advRoutingList) {
	    		
	    		if (ar.Adv_Routing_Client_Value__c == null
	    					|| ar.Adv_Routing_Client_Value__c == ''
	    					|| ar.Adv_Routing_Attribute__c == null
	    					|| string.valueOf(ar.Adv_Routing_Attribute__c) == '') {
	    			isAdvRoutingTableComplete = false;
	    			break;
	    		}
	    	}
    	}
    }
    
    /**
     * Description: method to close the add filter modal when user clicks on save 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public void closeFilterPopup() {
		
		if (isError && selectedFilterObj != null) {
			selectedFilterObj.Show_in_P2P__c = true;
		}
		
		if (isGroupError && selectedFilterObj != null ) {
			selectedFilterObj.Adv_Routing_Group__c = previousRoutingGroup;
		}
		showFilterPopup = false;
		isError = false;
		isGroupError = false;
		selectedFilterObj = null;
		selectedFilterId = '';
		isFilterSelectedBeforeSave = true;
	}
	
	/**
     * Description: method to close add filter modal when user clicks on cancel 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public void cancelFilterPopup() {
		
		if (selectedFilterObj != null) {
			selectedFilterObj.Show_in_P2P__c = true;
			selectedFilterObj.Adv_Routing_Group__c = previousRoutingGroup;
			
			if (filterMap.containsKey(selectedFilterObj.Id)) {
				Label__c tempFilter = filterMap.get(selectedFilterObj.Id);
				tempFilter.Adv_Routing_Group__c = previousRoutingGroup;
				tempFilter.Show_in_P2P__c = previousShowInP2P;
				tempFilter.Required_in_P2P__c = previousRequiredInP2P;
				filterMap.put(tempFilter.Id, tempFilter);
			}
		}
		showFilterPopup = false;
		isError = false;
		isGroupError = false;
		selectedFilterObj = null;
		selectedFilterId = '';
		isFilterSelectedBeforeSave = true;
	}
	
	/**
     * Description: method to open add filter modal when user clicks on add filter link 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public void addFilter() {
		isError = false;
		isGroupError = false;
		isFilterEdit = false;
		
		if (selectedFilterObj != null
				&& selectedFilterObj.Adv_Routing_Group__c != null
				&& selectedFilterObj.Adv_Routing_Group__c != '') {
			previousRoutingGroup = selectedFilterObj.Adv_Routing_Group__c;
		} else {
			previousRoutingGroup = '';
		}
		showFilterPopup = true;
	}
	
	/**
     * Description: method to open add filter modal when user clicks on a
     *				filter name which is already added to advanced routing 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public void editFilter() {
		isError = false;
		isGroupError = false;
		isFilterEdit = true;
		
		if (selectedFilterId != null && selectedFilterId != '') {
			selectedFilterObj = filterMap.get(selectedFilterId);
		}
		
		if (selectedFilterObj != null) {
			previousRoutingGroup = selectedFilterObj.Adv_Routing_Group__c != null ? selectedFilterObj.Adv_Routing_Group__c : '';
			previousShowInP2P = selectedFilterObj.Show_in_P2P__c;
			previousRequiredInP2P = selectedFilterObj.Required_in_P2P__c;
		} else {
			previousRoutingGroup = '';
			previousRequiredInP2P = false;
			previousShowInP2P = false;
		}
		showFilterPopup = true;
	}
	
	/**
     * Description: method to save the changes made by the user in add filter modal 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public PageReference saveFilterModal() {
		SavePoint sp = Database.setSavepoint();
		
		if (checkPermissions()) { 
			// added for #465 - showing a message to user if save is clicked without selecting a filter
			if (selectedFilterObj == null || selectedFilterId == null) {
				isFilterSelectedBeforeSave = false;
				return null;
			} else {
				isFilterSelectedBeforeSave = true;
			}
			
			try {			
				// user cannot select a routing group if it is already associated to another filter
				if (selectedFilterObj != null
						&& selectedFilterObj.Adv_Routing_Group__c != null
						&& selectedFilterObj.Adv_Routing_Group__c != '') {
					
					for (String filterId : filterMap.keySet()) {
						
						if (selectedFilterObj.Id != filterId
								&& selectedFilterObj.Adv_Routing_Group__c == filterMap.get(filterId).Adv_Routing_Group__c) {
							isGroupError = true;
							return null;
						}
					}
				}
				
				if (!isFilterEdit) {	// adding a new filter to advanced routing
					
					if (selectedFilterObj != null) {
						upsert selectedFilterObj;
						filterMap.put(selectedFilterObj.Id, selectedFilterObj);
						
						for (Integer i = 0; i < filterListForModal.size(); i++) {
							
							if (filterListForModal.get(i).getLabel() == selectedFilterObj.Name) {
								filterListForModal.remove(i);
							}
						}
					}
				} else {	// editing a filter which is already added to advanced routing
					
					if (selectedFilterObj != null) {
						update selectedFilterObj;
						
						if (selectedFilterObj.Show_in_P2P__c) {
							filterMap.put(selectedFilterObj.Id, selectedFilterObj);
						} else {
							filterMap.remove(selectedFilterObj.Id);
						}
					}
				}
				closeFilterPopup();
				selectedFilterId = '';
			} catch(Exception e) {
				Apexpages.addMessages(e);
	            Database.rollback(sp);
	            closeFilterPopup();
			}
			
		} 
		return null;
	}
	//Method is removed for #908
	/**
     * Description: method to open the advanced routing mapping table 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	/*public PageReference openMappingTable() {
		Schema.DescribeSObjectResult result = Advanced_Routing__c.SObjectType.getDescribe();
		PageReference pageRef = new PageReference('/' + result.getKeyPrefix()); 
		pageRef.setRedirect(true);
		return pageRef;
	}*/
	
	/**
     * Description: method to set the currently selected filter as
     *				selected by the user in filters picklist in add filter modal 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public void setSelectedFilter() {
		
		if (selectedFilterId != null && selectedFilterId != '') {
			selectedFilterObj = [SELECT Show_in_P2P__c, Required_in_P2P__c, Name, Id, Adv_Routing_Group__c
									FROM Label__c WHERE Id = :selectedFilterId];
			selectedFilterObj.Show_in_P2P__c = true;
		} else {
			selectedFilterObj = null;
		}
	}
	
	/**
     * Description: method to reset filter values on uncheck of show in P2P checkbox 
     * Last modified by: Gaurav Saini (6 Dec, 2016)
     */
	public void resetFilterValues() {
		
		if (!showInP2PValue && selectedFilterObj != null) {
			selectedFilterObj.Required_in_P2P__c = false;
			selectedFilterObj.Adv_Routing_Group__c = '';
		}
	}
	
	/**
	 * Description: re #560  method used to set show in P2P checked if Required in P2P is checked. 
     * Last modified by: Rajesh (13 Dec, 2016)
     */
	public void checkedShowInP2P() {
		
		if (selectedFilterObj.Required_in_P2P__c) {
			selectedFilterObj.Show_in_P2P__c = true;
		}  
	} 
 
	public void setRoutingGroup() {
		
		if (selectedRoutingGroupTemp != null && selectedRoutingGroupTemp != '') {
			selectedFilterObj.Show_in_P2P__c = true;
		}
	}
	
	public void showRoutingGroupsModal() {
		bindAdvancedRoutingGroup();  
		showGroupsPopup = true;
	}
	
	public void closeRoutingGroupsModal() {
		showGroupsPopup = false;
	}
	
	/**
     * Method to check Permissions
     */
     public static Boolean checkPermissions() { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    	Boolean isUpsertPermission = false; 
    	       		
        fieldMap.put(UtilityController.appNamespace() + 'Label__c', new Set<String> {   
        										UtilityController.appNamespace() + 'Show_in_P2P__c',
        										UtilityController.appNamespace() + 'Required_in_P2P__c',
        										UtilityController.appNamespace() + 'Adv_Routing_Group__c' });  
        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);           
        return isUpsertPermission; 
    }
}