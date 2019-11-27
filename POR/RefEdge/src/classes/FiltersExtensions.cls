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
 * Page: Filters
 * Description: Class to update and delete Hit List
 * Modified by: Rekha @24 April 2017
 */
public with sharing class FiltersExtensions extends RefEdgeEditionFeatures { 
	/**
     * Properties and variables
     */
	public List<SelectOption> advRoutingGroup { get; set; }
    public String advancedRoutingGroup { get; set; } 
    public Boolean isEdit { get; set; }
    public Label__c label { get; set; }
    public Custom_Settings__c cs { get; set; } 
    public String selectedGroup { get; set; } 
    public Boolean isShowinP2PChanged { get; set; }
    public Boolean isChanged  { get; set; }
    public Boolean ownerName  { get; set; }
    public Boolean isAdvanceRouting { get; set; }
    private String returnId;
    public Boolean isOnlySave { get; set; }
    public Boolean isthisBasic {
        get { 
        	return isBasic;
    	}
        set;
    }
    
    /**
     * Constructor
     */
    public FiltersExtensions(ApexPages.StandardController controller) {
    	
        cs = UtilityController.getCustomSettings();
        isChanged = false;
        isAdvanceRouting = cs.Adv_Request_Routing__c;
        label = new Label__c();
        isEdit = false;
        isOnlySave = true;
        label = (Label__c) controller.getRecord();
        returnId = ApexPages.currentPage().getParameters().get('retURL');
        
        if (label.id != null) {
        	isEdit = true; 
        	//added a field regarding #570 
            List<Label__c> labels = [SELECT Name, Id, Visible__c, Show_in_P2P__c, Required_in_P2P__c, Required__c, Owner.Name, Ref_Limit_to_Acct_or_Cntct__c, 
            			Filter_RefSearch_Visible__c, Description__c, BasicSearchView__c, Adv_Routing_Group__c FROM Label__c WHERE Id = : label.id];
            if (labels.size() > 0) {
            	label = labels[0];
            	selectedGroup = label.Adv_Routing_Group__c;
            }
        }
        advRoutingGroup = new List<SelectOption>();
        advRoutingGroup.add(new SelectOption('', '--None--'));  
        
        for (Advanced_Routing__c advRouting : [SELECT Adv_Routing_Client_Value__c FROM Advanced_Routing__c 
        										WHERE Adv_Routing_Client_Value__c != null LIMIT : limits.getLimitQueryRows()]) {
             advRoutingGroup.add(new SelectOption(advRouting.Adv_Routing_Client_Value__c.trim(), advRouting.Adv_Routing_Client_Value__c.trim()));
        }  
        checkPermissions();
    }
    
    /**
     * Method used to set Show in P2P in case of selection Advance routing group
     */
    public void selectP2P() {  
    	 
		if (selectedGroup != null) {
			label.Show_in_P2P__c = true;   
		}
    	
     	if (label.Required_in_P2P__c) {
     		label.Show_in_P2P__c = true;
     	}	
    }
    
    /**
     * Method used to set Values
     */
    public void reSetP2PValues() {  
    	
	 	if (!label.Show_in_P2P__c) {
			selectedGroup = null;
			label.Required_in_P2P__c = false;
	 	}   
	 	isChanged = true;
 	}
 	
    /**
     * Method used to Save the filter records
     */
	public PageReference saveForm() { 
		
		if (checkPermissions()) {
	        Savepoint sp = Database.setSavepoint();
	        try {   
	        	
	        	if (validateRecords()) {
					label.Adv_Routing_Group__c = selectedGroup;
					
					if (isEdit) {
						 update label; 
					} else {
		        		insert label; 
					}   
					
					if (isOnlySave) {
						return new Pagereference('/' + label.id);
					} else {
						PageReference returnPage = new Pagereference(Page.Filters.getUrl() + '?returl=' + returnId);
			    		returnPage.setRedirect(true);
			        	return returnPage;
					}
	          	} else { 
	        	  	return null;
	    		}
	        } catch(Exception e) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
	            Database.rollback(sp);
	        	return null;
	        } 
		} else {
			return null;
		}
    } 
    
    /**
     * Method use to validate records
     */
	public boolean validateRecords() {   
    	
    	if (selectedGroup != null && label.Show_in_P2P__c == false) {
		   	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.Show_in_P2P_Mandatory)); 
    		return false;
    	} else if (label.Name == null || label.Name == '') {
    	 	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, System.Label.REQUIRED_VALUES)); 
    		return false;
    	} else {
			return true;
    	}
    }
    
    /**
     * Method to cancel from
     */
    public PageReference cancelForm() { 
    	
    	if (isOnlySave && returnId != '') {
    		PageReference returnPage = UtilityController.redirectToSource(returnId);
    		returnPage.setRedirect(true);
        	return returnPage;
    	} else if (label.id != null) {
    		PageReference returnPage = UtilityController.redirectToSource(label.id);
    		returnPage.setRedirect(true);
        	return returnPage;
    	} else {
    		Schema.DescribeSObjectResult describeResult = label.getSObjectType().getDescribe();
			return new PageReference('/' + describeResult.getKeyPrefix() + '/o');
    	}
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	
        try {
        	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    		fieldMap.put(UtilityController.appNamespace() + 'Label__c', new Set<String> { 
        									UtilityController.appNamespace() + 'Show_in_P2P__c',
        									UtilityController.appNamespace() + 'Adv_Routing_Group__c',
        									UtilityController.appNamespace() + 'Required_in_P2P__c' });
            return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
            return false;
        }
    }
}