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
 * VF Page: ReferenceNoteDetailPage, ReferenceNoteDetailPageSLDS
 * Description: controller for showing the datails of a reference note
 * Modified by: Rekha @15 June 2017
 */
public with sharing class ReferenceNoteDetailController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Reference_Note__c refNote { get; set; }
    public String returnUrl = '';
    public Boolean isSLDS { get; set; }
    public String nameSpace {
		get {
			return UtilityController.appNamespace();
		}
		private set;
	}
    
    /**
     * Constructor
     */
    public ReferenceNoteDetailController(ApexPages.StandardController controller) {
    	
		if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
        } else { 
            isSLDS = false;
        }
        refNote = new Reference_Note__c();
        refNote = (Reference_Note__c)controller.getRecord();
        
        if (refNote.Id != null) {
            refNote = [SELECT Name, Id, Account__c, Contact__c, Reference_Content__c, Reference_Request__c,
            			Account_Request__c, Unspecified_Request__c, Note__c, Note_Date__c, Nomination__c
            			FROM Reference_Note__c
            			WHERE Id = :refNote.id];
        }
        returnUrl = Page.AddReferenceNote.geturl() + '?id=' + refNote.id + '&retURL=' + ApexPages.currentPage().getURL();
    }
    
    /**
     * Method to edit Reference Notes
     */
    public Pagereference edit() {
        return new Pagereference(returnUrl);
    }
    
    /**
     * RemoteAction to delete the ref note
     * Created By: Rekha @15 June 2017 related to #878
     */
    @RemoteAction
    public static String deleteRefNote(String refNoteId) {
        
        try {
        	
        	if (CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'Reference_Note__c'})) {
        		List<Reference_Note__c> refNotes = [SELECT Id FROM Reference_Note__c WHERE Id = :refNoteId];
				delete refNotes;
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        	return '';
        } catch(Exception e) {
        	return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    
    /**
     * RemoteAction to edit the ref note
     * Created By: Rekha @15 June 2017 related to #878
     */
    @RemoteAction
    public static String editRefNote() {
        
        try {
        	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
    		fieldMap.put(UtilityController.appNamespace() + 'Reference_Note__c', new Set<String>()); 
        	
        	if (CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true)) {
        		return '';
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        } catch(Exception e) {
        	return CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
}