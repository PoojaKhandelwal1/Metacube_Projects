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
public with sharing class ContentDocumentTriggerHandler {
	
	/**
     * Method called on after update of Content Document
     */
    public static void onAfterUpdate(Map<Id, ContentDocument> oldMap, Map<Id, ContentDocument> newMap) {
    	Set<String> archivedDocIds = new Set<String>();
    	Set<String> unarchivedDocIds = new Set<String>();
    	List<Reference_Note__c> refNotesToInsert = new List<Reference_Note__c>();
    	List<Reference_Content__c> refContentToUpdate = new List<Reference_Content__c>();
    	
    	for (Id docId : oldMap.keySet()) {
    		
	    	if (!oldMap.get(docId).IsArchived && newMap.get(docId).IsArchived) {
		        archivedDocIds.add(oldMap.get(docId).LatestPublishedVersionId);
	    	}
	    	
	    	if (oldMap.get(docId).IsArchived && !newMap.get(docId).IsArchived) {
		        unarchivedDocIds.add(oldMap.get(docId).LatestPublishedVersionId);
	    	}
    	}
    	
    	for (Reference_Content__c refContent : [SELECT Id, Content_Status__c, Content_Id__c FROM Reference_Content__c
        										WHERE (Content_Id__c IN :archivedDocIds
        											OR Content_Id__c IN :unarchivedDocIds)
        										AND Content_Id__c != null]) {
            
            if (archivedDocIds.contains(refContent.Content_Id__c)) {
	            refContent.Content_Status__c = 'Inactive';
	            refContentToUpdate.add(refContent);
	            Reference_Note__c tempNote = new Reference_Note__c();
	            tempNote.Note__c = System.Label.Content_Archive_Note;
	            tempNote.Reference_Content__c = refContent.Id;
	            refNotesToInsert.add(tempNote);
            } else if (unarchivedDocIds.contains(refContent.Content_Id__c)) {
            	refContent.Content_Status__c = 'Active';
	            refContentToUpdate.add(refContent);
	            Reference_Note__c tempNote = new Reference_Note__c();
	            tempNote.Note__c = System.Label.Content_Restore_From_Archive_Note;
	            tempNote.Reference_Content__c = refContent.Id;
	            refNotesToInsert.add(tempNote);
            }
        }
        
        if (refContentToUpdate.size() > 0) {
        	update refContentToUpdate;
        }
        
        if (refNotesToInsert.size() > 0) {
        	insert refNotesToInsert;
        }
    }
	
    /**
     * Method called on after delete of Content Document
     */
    public static void onAfterDelete(List<ContentDocument> oldContentDocuments) {
        deleteContentDocument(oldContentDocuments);
    }
	
    /**
     * Method to delete Reference Content on delete ContentVersion
     */
    static void deleteContentDocument(List<ContentDocument> oldContentDocuments) {
        List<Reference_Content__c> refrenceContents = new List<Reference_Content__c>();
        Set<String> contentIds = new Set<String>();
        
        //Get Content Ids
        for (ContentDocument cd : oldContentDocuments) {
            contentIds.add(cd.LatestPublishedVersionId);
        }
        
        //Get Contents to be deleted
        //changes regarding ticket #156
        for (Reference_Content__c refContent : [SELECT Title__c, Language__c, Content_ID__c, Search_Terms_keywords__c, Content_Status__c
        										FROM Reference_Content__c
        										WHERE Content_Id__c IN :contentIds AND Content_Id__c != null]) {
            refContent.Content_Status__c = 'Inactive';
            refContent.Content_ID__c = '';                                
            refrenceContents.add(refContent);
        }
        
        //If Reference Contents size greater than 'ZERO'
        if (refrenceContents.size() > 0) {
            Custom_Settings__c cs = UtilityController.getCustomSettings();
        
            if (cs != null && cs.Auto_create_delete_Reference_Content__c) {
                delete refrenceContents;
            } else {
                update refrenceContents;
            }
        }
    }
}