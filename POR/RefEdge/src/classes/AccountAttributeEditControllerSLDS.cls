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
 * VF Page: AccountAttributeEditPageSLDS
 * Description: Class used to edit account attribute. 
 * Created By: Rekha @5 May 2017
 */
public with sharing class AccountAttributeEditControllerSLDS extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Id accAttId { get; set; }
    
    /**
     * Constructor
     */
    public AccountAttributeEditControllerSLDS(ApexPages.StandardController stdController) {
    	Account_Attribute__c attAcc = (Account_Attribute__c) stdController.getRecord();
    	accAttId = attAcc.Id;
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static AccountAttributeWrapper fetchInfo(String accAttId) {
    	AccountAttributeWrapper attWp = new AccountAttributeWrapper();
    	
    	if (accAttId != null && accAttId != '') {
    		List<Account_Attribute__c> accAtts = [SELECT Account__c, Account__r.Name, Attribute__c, Attribute__r.Name, 
    					Inheritable__c, Contact__c, Reference_Content__c 
    					FROM Account_Attribute__c WHERE Id = :accAttId LIMIT 1];
    		
    		if (accAtts.size() > 0) {
    			attWp.attId = accAtts[0].Attribute__c;
	        	attWp.accountId = accAtts[0].Account__c;
	        	attWp.attName = accAtts[0].Attribute__r.Name;
	        	attWp.accountName = accAtts[0].Account__r.Name;
	        	attWp.id = accAtts[0].Id;
	        	attWp.isInheritableNew = accAtts[0].Inheritable__c;
	        	
	        	if (accAtts[0].Contact__c == null && accAtts[0].Reference_Content__c == null) {
		            attWp.isInheritableDisabled = false;
		        }
		        
		        Set<String> oppAttributes = new Set<String>();
		        
		        for (Attribute__c att : [SELECT Id, (SELECT Id FROM Attributes__r) FROM Attribute__c 
		        						WHERE Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY 
		        							AND Attribute_Mapping__r.Field_Api_Name__c = 'StageName']) {
		            
		            for (Attribute__c oppAtt : att.Attributes__r) {
		                oppAttributes.add(oppAtt.Id);
		            }
		        }
		        
		        if (oppAttributes.contains(attWp.attId)) {
		            attWp.isInheritableDisabled = true;
		        }
    		}
    	}
    	
    	return attWp;
    }
    
    /**
     * Method to remove attribute
     */
    @RemoteAction
    public static String removeAttributes(String infoWpJSON) {
        //initialized variables
        List<Contact_Attribute__c> contactAtt = new List<Contact_Attribute__c>();
        List<Content_Attribute__c> contentAtt = new List<Content_Attribute__c>();
        Map<Id, Set<String>> attribParentMap = new Map<Id, Set<String>>();
        Map<Id, List<Contact_Attribute__c>> contctAttribMap = new Map<Id, List<Contact_Attribute__c>>();
        Map<Id, List<Content_Attribute__c>> contentAttribMap = new Map<Id, List<Content_Attribute__c>>();
        Map<Id, Account_Attribute__c> accountAttribMap = new Map<Id, Account_Attribute__c>();
        List<Account_Attribute__c> updatedAccAtt = new List<Account_Attribute__c>();
        Savepoint sp = Database.setSavepoint();
        
        try {
        	if (checkPermissions(true)) {
        		AccountAttributeWrapper infoWp = (AccountAttributeWrapper)JSON.deserialize(infoWpJSON, AccountAttributeWrapper.class);
        		Custom_Settings__c cs = UtilityController.getCustomSettings();
	        	Set<String> contactIds = new Set<String>();
	        	
	        	//Shared Contact start
	            if (cs.Shared_Contacts__c) {
	                String objectName = cs.Shared_Contact_Object__c;
	                String accountField = cs.Shared_Account_Field__c;
	                String contactField = cs.Shared_Contact_Field__c;
	                
	                if (accountField != null && accountField != '' && contactField != null && contactField != '') {
	                    String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
	                                     + ' WHERE ' + accountField + ' = \'' + infoWp.accountId + '\'';
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
	            										WHERE Contact__r.AccountId = :infoWp.accountId OR Contact__c IN :contactIds]) {
	                
	                if (cntcAtt.Attribute__c == infoWp.attId) {
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
	                
	                if (attribParentMap.get(attribId).contains(infoWp.attId)) {
	                    
	                    if (contctAttribMap.get(attribId) != null) {
	                       
	                        for (Contact_Attribute__c ac : contctAttribMap.get(attribId)) {
	                            contactAtt.add(ac);
	                        }
	                    }
	                }
	            }
	        
	            //to uncheck the checkBoxes of child attributes
	            for (Account_Attribute__c accAtt : [SELECT Attribute__c, Inheritable__c FROM Account_Attribute__c WHERE Account__c = :infoWp.accountId 
	            									AND Attribute__c != :infoWp.attId AND Contact__c = null AND Reference_Content__c = null]) {
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
	                
	                if (attribParentMap.get(attribId).contains(infoWp.attId)) {
	                    
	                    if (accountAttribMap.containsKey(attribId)) {
	                        accountAttribMap.get(attribId).Inheritable__c = false;
	                        updatedAccAtt.add(accountAttribMap.get(attribId));
	                    }
	                }
	            }
	            //for Content delete their parents also
	            Set<Id> contentIds = new Set<Id>();
	            
	            for (Account_Reference_Content__c tmpObj : [SELECT Reference_Content__c, Account__c FROM Account_Reference_Content__c 
	            											WHERE Account__c = :infoWp.accountId]) {
	                contentIds.add(tmpObj.Reference_Content__c);
	            }
	            attribParentMap = new Map<Id, Set<String>>();
	            
	            for (Content_Attribute__c cntntAtt : [SELECT Id, Attribute__c FROM Content_Attribute__c WHERE Reference_Content__r.Id IN :contentIds]) {
	                
	                if (cntntAtt.Attribute__c == infoWp.attId) {
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
	                
	                if (attribParentMap.get(attribId).contains(infoWp.attId)) {
	                    
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
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        } catch (Exception e) {
            database.rollback(sp);
            return 'Error: ' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
        return '';
    }
    
    /**
     * Method to save the process
     */
    @RemoteAction
    public static String save(String infoWpJSON) {
    	Savepoint sp = Database.setSavepoint();
    	
        try {
        	AccountAttributeWrapper infoWp = (AccountAttributeWrapper)JSON.deserialize(infoWpJSON, AccountAttributeWrapper.class);
        	
        	if (checkPermissions(false)) {  
        		Account_Attribute__c accAtt = new Account_Attribute__c();
        		accAtt.Inheritable__c = infoWp.isInheritableNew;
        		accAtt.Id = infoWp.id;
	            update accAtt;
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        } catch (Exception e) {
            database.rollback(sp);
            return 'Error: ' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
        return '';
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage() {
		checkPermissions(true);
    	
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions(Boolean isAllowDelete) { 
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
    
    /**
     * Wrapper class for all information
     */
 	public class AccountAttributeWrapper {
 		public Boolean isInheritableNew { get; set; }
 		public Boolean isInheritableOld { get; set; }
 		public Boolean isInheritableDisabled { get; set; }
 		public String attName { get; set; }
 		public String attId { get; set; }
 		public String accountId { get; set; }
 		public String accountName { get; set; }
 		public String id { get; set; }
 		
 	    public AccountAttributeWrapper() {
            isInheritableNew = false;
            isInheritableOld = false;
            isInheritableDisabled = true;
            attName = '';
            attId = '';
            accountId = '';
            accountName = '';
            id = '';
	    }
 	}
}