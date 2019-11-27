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
 * VF Page: AccountAttributeEditPage
 * Description: Class used to edit account attribute. 
 * Last Modified By: Rajesh @Feb 13 2017
 */
public with sharing class AccountAttributeEditController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    private String accAttId;
    private String attId;
    private String accId;
    public Boolean showCheckBox { get; set; }
    public Account_Attribute__c attAcc { get; set; }
	public Boolean isSLDS { get; set; }
	
    /**
     * Constructor
     */
    public AccountAttributeEditController(ApexPages.StandardController stdController) {
    	
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        attAcc = (Account_Attribute__c)stdController.getRecord();
	      	checkPermissions(true); 
	        List<Account_Attribute__c> accAtts = [SELECT Account__c, Attribute__c, Inheritable__c, Contact__c, Reference_Content__c 
	        					FROM Account_Attribute__c WHERE Id = :attAcc.Id LIMIT 1];
	        if (accAtts.size() > 0) {
        		attAcc = accAtts[0];
		        attId = attAcc.Attribute__c;
		        accId = attAcc.Account__c;
		        showCheckBox = false;
		        
		        if (attAcc.Contact__c == null && attAcc.Reference_Content__c == null) {
		            showCheckBox = true;
		        }
		        Set<String> oppAttributes = new Set<String>();
		        
		        for (Attribute__c att : [SELECT Id, (SELECT Id FROM Attributes__r) FROM Attribute__c 
		        							WHERE Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY 
		        							AND Attribute_Mapping__r.Field_Api_Name__c = 'StageName']) {
		            
		            for (Attribute__c oppAtt : att.Attributes__r) {
		                oppAttributes.add(oppAtt.Id);
		            }
		        }
		        
		        if (oppAttributes.contains(attId)) {
		            showCheckBox = false;
		        }
	        }
        }
    }

    /**
     * Method to remove attribute
     */
    public pageReference removeAttributes() {
        //initialized variables
        List<Contact_Attribute__c> contactAtt = new List<Contact_Attribute__c>();
        List<Content_Attribute__c> contentAtt = new List<Content_Attribute__c>();
        Map<Id, Set<String>> attribParentMap = new Map<Id, Set<String>>();
        Map<Id, List<Contact_Attribute__c>> contctAttribMap = new Map<Id, List<Contact_Attribute__c>>();
        Map<Id, List<Content_Attribute__c>>contentAttribMap = new Map<Id, List<Content_Attribute__c>>();
        Map<Id, Account_Attribute__c> accountAttribMap = new Map<Id, Account_Attribute__c>();
        List<Account_Attribute__c> updatedAccAtt = new List<Account_Attribute__c>();
        Savepoint sp = Database.setSavepoint();
        
        try {
        	if (checkPermissions(true)) {
        		Custom_Settings__c cs = UtilityController.getCustomSettings();
	        	Set<String> contactIds = new Set<String>();
	        	
	        	//Shared Contact start
	            if (cs.Shared_Contacts__c) {
	                String objectName = cs.Shared_Contact_Object__c;
	                String accountField = cs.Shared_Account_Field__c;
	                String contactField = cs.Shared_Contact_Field__c;
	                
	                if (accountField != null && accountField != '' && contactField != null && contactField != '') {
	                    String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
	                                     + ' WHERE ' + accountField + ' = \'' + accId + '\'';
	                    List<sObject> objectList = Database.query(query);
	                    
	                    if (objectList != null && objectList.size() > 0) {
	                        
	                        for (sObject obj : objectList) {
	                            contactIds.add((String)obj.get(contactField));
	                        }
	                    }
	                }
	            }
	            //Shared Contact end
	            
	            //for contact delete their parents also
	            for (Contact_Attribute__c cntcAtt : [SELECT Contact__r.AccountId, Attribute__c FROM Contact_Attribute__c 
	            										WHERE Contact__r.AccountId = :accId OR Contact__c IN :contactIds]) {
	                
	                if (cntcAtt.Attribute__c == attId) {
	                    contactAtt.add(cntcAtt);
	                } else {
	                    
	                    if (!contctAttribMap.containsKey(cntcAtt.Attribute__c)) {
	                        contctAttribMap.put(cntcAtt.Attribute__c, new List<Contact_Attribute__c> ());
	                    }
	                    contctAttribMap.get(cntcAtt.Attribute__c).add(cntcAtt);
	                    attribParentMap.put(cntcAtt.Attribute__c, new Set<String>());
	                }
	            }
	            
	            for (Attribute__c att : [SELECT ParentIds__c, Id FROM Attribute__c WHERE Id IN :attribParentMap.keySet()]) {
	                
	                if (att.parentIds__c != null) {
		                
		                for (String parentAtt : att.parentIds__c.split(',')) {
		                    attribParentMap.get(att.Id).add(parentAtt);
		                }
	                }
	            }
	          
	            for (Id attribId : attribParentMap.keySet()) {
	                
	                if (attribParentMap.get(attribId).contains(attId)) {
	                    
	                    if (contctAttribMap.get(attribId) != null) {
	                       
	                        for (Contact_Attribute__c ac : contctAttribMap.get(attribId)) {
	                            contactAtt.add(ac);
	                        }
	                    }
	                }
	            }
	        
	            //to uncheck the checkBoxes of child attributes
	            for (Account_Attribute__c accAtt : [SELECT Attribute__c, Inheritable__c FROM Account_Attribute__c WHERE Account__c = :accId 
	            									AND Attribute__c != :attId AND Contact__c = null AND Reference_Content__c = null]) {
	                accountAttribMap.put(accAtt.Attribute__c, accAtt);
	                attribParentMap.put(accAtt.Attribute__c, new Set<String>());
	            }
	        
	            for (Attribute__c att : [SELECT ParentIds__c, Id FROM Attribute__c WHERE Id IN :attribParentMap.keySet()]) {
	                
	                if(att.parentIds__c != null) {
		                
		                for (String parentAtt : att.parentIds__c.split(',')) {
		                    attribParentMap.get(att.Id).add(parentAtt);
		                }
	                }
	            }
	            
	            for (Id attribId : attribParentMap.keySet()) {
	                
	                if (attribParentMap.get(attribId).contains(attId)) {
	                    
	                    if (accountAttribMap.containsKey(attribId)) {
	                        accountAttribMap.get(attribId).Inheritable__c = false;
	                        updatedAccAtt.add(accountAttribMap.get(attribId));
	                    }
	                }
	            }
	            //for Content delete their parents also
	            Set<Id> contentIds = new Set<Id>();
	            
	            for (Account_Reference_Content__c tmpObj : [SELECT Reference_Content__c, Account__c FROM Account_Reference_Content__c 
	            											WHERE Account__c = :accId]) {
	                contentIds.add(tmpObj.Reference_Content__c);
	            }
	            attribParentMap = new Map<Id, Set<String>>();
	            
	            for (Content_Attribute__c cntntAtt : [SELECT Id, Attribute__c FROM Content_Attribute__c WHERE Reference_Content__r.Id IN :contentIds]) {
	                
	                if (cntntAtt.Attribute__c == attId) {
	                    contentAtt.add(cntntAtt);
	                } else {
	                	
	                    if (!contentAttribMap.containsKey(cntntAtt.Attribute__c)) {
	                        contentAttribMap.put(cntntAtt.Attribute__c, new List<Content_Attribute__c>());
	                    }
	                    contentAttribMap.get(cntntAtt.Attribute__c).add(cntntAtt);
	                    attribParentMap.put(cntntAtt.Attribute__c, new Set<String>());
	                }
	            }
	            
	            for (Attribute__c att : [SELECT ParentIds__c, Id FROM Attribute__c WHERE Id IN :attribParentMap.keySet()]) {
	                
	                if (att.parentIds__c != null) {
		                
		                for (String parentAtt : att.parentIds__c.split(',')) {
		                    attribParentMap.get(att.Id).add(parentAtt);
		                }
	                }
	            }
	        
	            for (Id attribId : attribParentMap.keySet()) {
	                
	                if (attribParentMap.get(attribId).contains(attId)) {
	                    
	                    if (contentAttribMap.get(attribId) != null) {
	                        
	                        for (Content_Attribute__c conAtt : contentAttribMap.get(attribId)) {
	                            contentAtt.add(conAtt);
	                        }
	                    }
	                }
	            }
	            
	            if (contactAtt.size() > 0) {
	                delete contactAtt;
	            }
	            
	            if (contentAtt.size() > 0) {
	                delete contentAtt;
	            }
	            
	            if (updatedAccAtt.size() > 0) {
	                update updatedAccAtt;
	            }
	            Save();
	            return new PageReference('/' + accId);
        	} else {
        		return null; 
        	}
        } catch (Exception e) {
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
            Database.rollback(sp);
        }
        return null;
    }
    
    /**
     * Method to save the process
     */
    public pageReference Save() {
        try {
        	
        	if (checkPermissions(false)) {  
	            update attAcc;
	            return new PageReference('/' + accId);
        	} else {
        		return null;
        	}
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
            return null;
        }
    }

    /**
     * Method to cancel the process
     */
    public pageReference Cancel() {
        return new PageReference('/' + accId);
    }
    
    /**
     * Method to check Permissions
     */
     public static Boolean checkPermissions(Boolean isAllowDelete) { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isDeleteContactPermission = false;
    	Boolean isDeleteContentPermission = false;
    	Boolean isUpsertPermission = false; 
    	       		
        fieldMap.put(UtilityController.appNamespace() + 'Account_Attribute__c', new Set<String> {  
        										UtilityController.appNamespace() + 'Inheritable__c'}); 
        if (isAllowDelete) {
	    	isDeleteContactPermission = CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'Contact_Attribute__c' }); 
	    	isDeleteContentPermission = CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'Content_Attribute__c' });
        } else {
        	isDeleteContactPermission = true;
    		isDeleteContentPermission = true;
        }        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true); 
        
        return (isUpsertPermission && isDeleteContactPermission && isDeleteContentPermission); 
    }
    
}