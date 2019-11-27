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
 * Page: AddNewRelatedConRefContentsSLDS
 * Description: Class used to add new associated reference contents.
 * Created by: Rekha @24 May 2017
 */
public with sharing class AddNewRelatedConRefContentControllerSLDS extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public String returnUrl { get; set; }
    public String contactId { get; set; }
    
    /**
     * Constructor
     */
    public AddNewRelatedConRefContentControllerSLDS(ApexPages.StandardController controller) {
    	Contact_Reference_Content__c conRefContent = (Contact_Reference_Content__c)controller.getRecord();
        contactId = ApexPages.currentPage().getParameters().get('conId');
        returnUrl = conRefContent.Reference_Content__c != null ? String.valueOf(conRefContent.Reference_Content__c) : '';
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static InfoWrapper fetchInfo(String contactId, String returnUrl) {
    	InfoWrapper infoWp = new InfoWrapper();
    	
    	//get account details
    	if (contactId != null && contactId != '') {
    		infoWp.isFromContact = true;
			List<Contact> contacts = [SELECT Name, Id FROM Contact WHERE Id = :contactId];
			
			if (contacts.size() > 0) {
				infoWp.contactName = contacts[0].Name;
				infoWp.contactId = contacts[0].Id;
			}
		//get reference content details
    	} else {
    		infoWp.isFromContact = false;
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
        	Contact_Reference_Content__c conRefContent = new Contact_Reference_Content__c(Contact__c = infoWp.contactId, Reference_Content__c = infoWp.refConId);
        	WithoutSharingHelperController.insertContactReferenceContent(new List<Contact_Reference_Content__c>{conRefContent});
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
 		public String contactId { get; set; }
 		public String contactName { get; set; }
 		public String refConId { get; set; }
 		public String refConName { get; set; }
 		public Boolean isFromContact { get; set; }
	    
	    public InfoWrapper() {
            contactId = '';
            contactName = '';
            refConId = '';
            refConName = '';
            isFromContact = false;
	    }
 	}
}