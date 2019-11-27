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
 * Page: AddReferenceNote
 * Description : Class used to insert and update Reference Note.
 * Modified by: Rekha @7 June 2017
 */
public with sharing class AddReferenceNoteController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Reference_Note__c refNote { get; set; }
    public String returnId = '';
	public String recordId = '';
	public Boolean isSLDS { get; set; }
	public Boolean isFromRelatedList { get; set; }
	
    /**
     * Constructor
     */
    public AddReferenceNoteController(ApexPages.StandardController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
            
        if (!isSLDS) {
	        refNote = new Reference_Note__c();
	        refNote = (Reference_Note__c)controller.getRecord();
	        isFromRelatedList = false;
	        
	        if (refNote.id != null) {
	            isFromRelatedList = true;
	            refNote = [SELECT Name, Id, Account__c, Contact__c, Reference_Content__c, Reference_Request__c,
	            			Account_Request__c, Unspecified_Request__c,	Note__c, Note_Date__c, Nomination__c
	            			FROM Reference_Note__c WHERE Id = :refNote.id];
	        }
	        returnId = ApexPages.currentPage().getParameters().get('retURL');
			
	        if (refNote.Account__c != null) {
	        	isFromRelatedList = true;
	            recordId = refNote.Account__c;
	        }
	        
	        if (refNote.Contact__c != null) {
	        	isFromRelatedList = true;
	            recordId = refNote.Contact__c;
	        }
	        
	        if (refNote.Reference_Content__c != null) {
	        	isFromRelatedList = true;
	            recordId = refNote.Reference_Content__c;
	        }
	        
	        if (refNote.Reference_Request__c != null) {
	        	isFromRelatedList = true;
	            recordId = refNote.Reference_Request__c;
	        }
	        
	        if (refNote.Account_Request__c != null) {
	        	isFromRelatedList = true;
	            recordId = refNote.Account_Request__c;
	        }
	        
	        if (refNote.Unspecified_Request__c != null) {
	        	isFromRelatedList = true;
	            recordId = refNote.Unspecified_Request__c;
	        }

			if (refNote.Nomination__c != null) {
	        	isFromRelatedList = true;
	            recordId = refNote.Nomination__c;
	        }
	        checkPermissions();
        }
    }

    /**
     * Method to save Reference Notes
     */
    public Pagereference save() {
        try {
        	
        	if (checkPermissions()) {
            	upsert refNote;
        	} else {
        		return null;
        	}
            return cancel();
        } catch (DmlException e) {
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    /**
     * Method to cancel Reference Notes
     */
    public pageReference cancel() {
    	
    	//re #589 Open Redirect Vulnerability-Validate URL and if retURL found blank then redirect to previous/Home page.
    	//changed by Rekha
    	//changes regarding #892
		
        if (recordId != null && recordId != ''
        			&& ((returnId != null && !returnId.contains('RefRequestProject') && !returnId.contains('refrequestproject') && !returnId.contains('RefWorkspaceNominationDetail') && !returnId.contains('refworkspacenominationdetail') && !returnId.contains('ReferenceNoteDetailPage') && !returnId.contains('referencenotedetailpage')) || returnId == null)) {
			return new Pagereference('/' + recordId);
        } else {
			return UtilityController.redirectToSource(returnId);
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		fieldMap.put(UtilityController.appNamespace() + 'Reference_Note__c', new Set<String>());
		
		//re #903
		if (refNote.id != null) {
			return CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
		} else {
        	return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
		}
    }
}