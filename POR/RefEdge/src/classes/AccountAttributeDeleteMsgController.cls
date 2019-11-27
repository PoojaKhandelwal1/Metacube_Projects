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
 * Page: AccountAttributeDeleteMsg, AccountAttributeDeleteMsgSLDS
 * Description : Class used to delete related contact/content attributes of an account attribute.
 * Modified by: Rekha @4 May 2017
 */
public with sharing class AccountAttributeDeleteMsgController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Boolean inheritable { get; set; }
    private Account_Attribute__c accAtt;
    public Boolean hasError { get; set; }
    private List<Contact_Attribute__c> contactAtt;
    private List<Content_Attribute__c> contentAtt;
    public Id accountId { get; set; }
    public Id accAttId { get; set; }
    public Boolean isSLDS { get; set; }

    /**
     * Constructor
     */
    public AccountAttributeDeleteMsgController(ApexPages.StandardController controller) {
    	
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        inheritable = false;
        contentAtt = new List<Content_Attribute__c>();
        contactAtt = new List<Contact_Attribute__c>();
        Set<Id> refContentIds = new Set<Id>();
        hasError = false;
        accAtt = (Account_Attribute__c) controller.getRecord();
        List<Account_Attribute__c> accAtts = [SELECT Attribute__c, Inheritable__c, Account__c FROM account_Attribute__c WHERE Id = :accAtt.Id LIMIT 1];
        
        if (accAtts.size() > 0) {
        	accAtt = accAtts[0];
	        accountId = accAtt.Account__c;
	        accAttId = accAtt.Id;
	        
	        if (accAtt.Inheritable__c) {
	            contactAtt = [SELECT Id, Contact__c, Attribute__c FROM Contact_Attribute__c WHERE Attribute__c = :accAtt.Attribute__c 
	            				AND Contact__r.AccountId = :accAtt.Account__c];
	            
	            for (Account_Reference_Content__c arc : [SELECT Reference_Content__c, Account__c FROM Account_Reference_Content__c 
	            				WHERE Account__c = :accAtt.Account__c]) {
	                refContentIds.add(arc.Reference_Content__c);
	            }
	            
	            if (refContentIds.size() > 0) {
		            contentAtt = [SELECT Id, Reference_Content__c FROM Content_Attribute__c WHERE Attribute__c = :accAtt.Attribute__c 
		            				AND Account__c = : accAtt.Account__c AND Reference_Content__c IN :refContentIds];
	            }
	            
	            if (contentAtt.size() > 0 || contactAtt.size() > 0) {
	                inheritable = true;
	            }
	        }
        }
    }

    /**
     * Method to delete attribute
     */
    public pageReference deleteAtt() {
        Savepoint sp = Database.setSavepoint();
        try {
        	
        	if (CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Account_Attribute__c', 
        																		UtilityController.appNamespace() + 'Contact_Attribute__c', 
        																		UtilityController.appNamespace() + 'Content_Attribute__c'})) {
	            
	            if (contactAtt.size() > 0) {
	                delete contactAtt;
	            }
	            
	            if (contentAtt.size() > 0) {
	                delete contentAtt; 
	            }
	            delete accAtt;
	            return new pageReference('/' + accountId);
        	} else {
        		hasError = true;
        		return null;
        	}
        
        } catch (Exception e) {
            hasError = true;
            
            if (!Apexpages.hasMessages()) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
            }
            Database.rollback(sp);
            return null;
        }
    }

    /**
     * Method to cancel the process
     */
    public pageReference cancel() {
        return new pageReference('/' + accountId);
    }
    
    /**
     * Method to delete attribute from SLDS page
     * Created By: Rekha @4 May 2017 related to #676
     */
    @RemoteAction
    public static string deleteAtts(String accAttId) {
        Savepoint sp = Database.setSavepoint();
        
        try {
        	
        	if (CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Account_Attribute__c', 
        																		UtilityController.appNamespace() + 'Contact_Attribute__c', 
        																		UtilityController.appNamespace() + 'Content_Attribute__c'})) {
	            List<Account_Attribute__c> accAtts = [SELECT Attribute__c, Inheritable__c, Account__c FROM account_Attribute__c WHERE Id = :accAttId LIMIT 1];
        
        		if (accAtts.size() > 0) {
        			
        			if (accAtts[0].Inheritable__c) {
			            List<Contact_Attribute__c> contactAtt = [SELECT Id, Contact__c, Attribute__c FROM Contact_Attribute__c 
			            				WHERE Attribute__c = :accAtts[0].Attribute__c 
			            				AND Contact__r.AccountId = :accAtts[0].Account__c];
			            
			            if (contactAtt.size() > 0) {
			                delete contactAtt;
			            }
			            Set<Id> refContentIds = new Set<Id>();
			            
			            for (Account_Reference_Content__c arc : [SELECT Reference_Content__c, Account__c FROM Account_Reference_Content__c 
			            				WHERE Account__c = :accAtts[0].Account__c]) {
			                refContentIds.add(arc.Reference_Content__c);
			            }
			            
			            if (refContentIds.size() > 0) {
			            	List<Content_Attribute__c> contentAtt = [SELECT Id, Reference_Content__c FROM Content_Attribute__c 
			            				WHERE Attribute__c = :accAtts[0].Attribute__c 
			            				AND Account__c = :accAtts[0].Account__c AND Reference_Content__c IN :refContentIds];
			            	if (contentAtt.size() > 0) {
				                delete contentAtt; 
				            }
			            }
        			}    
		            delete accAtts;
        		}
	            return '';
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        
        } catch (Exception e) {
        	
            if (!Apexpages.hasMessages()) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
	            Apexpages.addMessage(message);
            }
            Database.rollback(sp);
            return CRUDAndFLSCheckController.getErrorMsg();
        }
    }
}