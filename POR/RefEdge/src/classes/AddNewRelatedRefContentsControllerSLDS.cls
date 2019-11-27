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
 * Page: AddNewRelatedRefContentsSLDS
 * Description: Class used to add new associated reference contents.
 * Modified by: Rekha @23 May 2017
 */
public with sharing class AddNewRelatedRefContentsControllerSLDS extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String returnUrl { get; set; }
    public String accountId { get; set; }
    
    /**
     * Constructor
     */
    public AddNewRelatedRefContentsControllerSLDS(ApexPages.StandardController controller) {
    	Account_Reference_Content__c accRefContent = (Account_Reference_Content__c) controller.getRecord();
        accountId = ApexPages.currentPage().getParameters().get('acctId');
        returnUrl = accRefContent.Reference_Content__c != null ? String.valueOf(accRefContent.Reference_Content__c) : '';
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String accountId, String returnUrl) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	//get account details
    	if (accountId != null && accountId != '') {
    		infoWp.isFromAccount = true;
			List<Account> accounts = [SELECT Name, Id FROM Account WHERE Id = :accountId];
			
			if (accounts.size() > 0) {
				infoWp.accountName = accounts[0].Name;
				infoWp.accountId = accounts[0].Id;
			}
		//get reference content details
    	} else {
    		infoWp.isFromAccount = false;
    		List<Reference_Content__c> refConts = [SELECT Name, Id FROM Reference_Content__c WHERE Id = :returnUrl];
			
			if (refConts.size() > 0) {
				infoWp.refConName = refConts[0].Name;
				infoWp.refConId = refConts[0].Id;
			}
    	}
    	return infoWp;
    }
    
    /**
     * RemoteAction to save Account Reference Content
     */
    @RemoteAction
    public static String submit(String infoWpJSON) {
    	Savepoint sp = Database.setSavepoint();
    	
        try {
        	InfoWrapper infoWp = (InfoWrapper)JSON.deserialize(infoWpJSON, InfoWrapper.class);
        	Account_Reference_Content__c accRefContent = new Account_Reference_Content__c(Account__c = infoWp.accountId, Reference_Content__c = infoWp.refConId);
        	WithoutSharingHelperController.insertAccountReferenceContent(new List<Account_Reference_Content__c>{accRefContent});
        } catch (Exception e) {
            database.rollback(sp);
            return 'Error: ' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
        return '';
    }
    
    /**
     * Wrapper class for Account Reference Content
     */
 	public class InfoWrapper {
 		public String accountId { get; set; }
 		public String accountName { get; set; }
 		public String refConId { get; set; }
 		public String refConName { get; set; }
 		public Boolean isFromAccount { get; set; }
	    
	    public InfoWrapper() {
            accountId = '';
            accountName = '';
            refConId = '';
            refConName = '';
            isFromAccount = false;
	    }
 	}
}