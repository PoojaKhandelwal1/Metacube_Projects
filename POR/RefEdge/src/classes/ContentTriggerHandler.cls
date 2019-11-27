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
public with sharing class ContentTriggerHandler {
  /**
     * Method called on before insert of ContentVersion
     */
    //flag used to call trigger single time.-#577    
    public static Boolean isAlreadyCalled = false;
    
    public static void onBeforeInsert(List<ContentVersion> contents) {
        Set<String> refContentIds = new Set<String>();
        Map<Id, Reference_Content_Type__c> refContentTypeMap;
        
        for (ContentVersion cv: contents) {
            refContentIds.add(cv.Reference_Content_Type__c);
        }
        
        if (refContentIds.size() > 0) {
            refContentTypeMap = new Map<Id, Reference_Content_Type__c>([SELECT Id, Name__c, Recorded_Reference_Type__c FROM Reference_Content_Type__c 
            													WHERE Id In: refContentIds]);
        }
        
        if (refContentTypeMap != null) {
        	
            for (ContentVersion cv: contents) {
            	
                if (refContentTypeMap.containsKey(cv.Reference_Content_Type__c) && refContentTypeMap.get(cv.Reference_Content_Type__c).Recorded_Reference_Type__c) {
                    cv.addError(System.Label.CANNOT_SELECT_REFERENCE_INTERVIEW);
                }
            }
        }
    }
    
    /**
     * Method called on after insert of ContentVersion
     */
    public static void onAfterInsert(List<ContentVersion> contents) {
    	//re #577 - After insert, call single time for a single instance.  
    	if (!isAlreadyCalled) {    		
    		isAlreadyCalled = true;
	        Set<String> ContentIdSet = new Set<String>();
	        
	        for (ContentVersion cv: contents) {
	            ContentIdSet.add(cv.Id);
	        }
	        
	        List<ContentVersion> tempContents = [SELECT Id, Title, Description, IsLatest, VersionNumber, Language, TagCsv, Content_Status__c, ContentUrl, 
											        ContentDocumentId, Reference_Content_Type__c, Reference_Content_Type__r.Name__c FROM ContentVersion 
											        WHERE Id In: ContentIdSet LIMIT: limits.getLimitQueryRows()];
	        insertContentVersion(tempContents);
    	} 
    }

    /**
     * Method to Insert Refrence Content on insertion of ContentVersion
     */
    static void insertContentVersion(List<ContentVersion> contents) {
        Map<String, String> mapLanguage = UtilityController.mapContentLanguage;
        List <Reference_Content__c> refrenceContents = new List<Reference_Content__c>();
        Set<String> contentIds = new Set<String>();
        Set<String> contentDocumentIds = new Set<String>();
        
        //Get ContentVersion & ContentDocument Ids
        for (ContentVersion content: contents) {
            contentIds.add(content.Id);
            contentDocumentIds.add(content.ContentDocumentId);
        }
        //Create map for ContentVersion & Reference_Content__c
        Map<Id, ContentVersion> contentVersionMap = new Map<Id, ContentVersion>([SELECT Id, Title, TagCsv, Language, ContentDocumentId FROM ContentVersion 
        												WHERE ContentDocumentId IN: contentDocumentIds LIMIT: limits.getLimitQueryRows()]);
        
        Map<String, Reference_Content__c> refContentMap = new Map<String, Reference_Content__c>();
        
        for (Reference_Content__c refContent: [SELECT Title__c, Language__c, Content_ID__c, Search_Terms_keywords__c FROM Reference_Content__c 
        												WHERE Content_Id__c IN: contentVersionMap.keySet() LIMIT: limits.getLimitQueryRows()]) {
            refContentMap.put(contentVersionMap.get(refContent.Content_ID__c).ContentDocumentId, refContent);
        }
        
        Map<String, ContentDocument> contentDocumentMap = new Map<String, ContentDocument >();
        
        for (ContentDocument cd: [SELECT Id, Title, PublishStatus, ParentId, LatestPublishedVersionId FROM ContentDocument 
        												WHERE Id IN : contentDocumentIds LIMIT: limits.getLimitQueryRows()]) {
            contentDocumentMap.put(cd.id, cd);
        }
        Set<String> contentDocumentIdsSet = contentDocumentMap.keySet();
        
        Map<String,String> contentDocumentLinkMap = new Map<String,String> ();
        
        if (contentDocumentIdsSet.size() > 0) {
            for (ContentDocumentLink cdLink : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN : contentDocumentIdsSet  LIMIT: limits.getLimitQueryRows()]) {
                contentDocumentLinkMap.put(cdLink.ContentDocumentId, cdLink.LinkedEntityId);
            }
        }

        //Update Reference_Content__c on Update ContentVersion
        for (ContentVersion cont: contents) {
        	
            if (cont.IsLatest) {
            	
                if (Schema.sObjectType.Reference_Content__c.isCreateable() && cont.Reference_Content_Type__c != null && ConstantsController.createRefContentRecord && !ConstantsController.isRequestFromDM) {
                    Reference_Content__c refContent = (refContentMap.containsKey(cont.ContentDocumentId) ? refContentMap.get(cont.ContentDocumentId): new Reference_Content__c());
                    refContent.Title__c = cont.Title;
                    refContent.Language__c = mapLanguage.get(cont.Language);
                    refContent.Summary__c = cont.Description;
                    refContent.Content_ID__c = cont.id;
                    refContent.Library_ID__c = (contentDocumentMap.containsKey(cont.ContentDocumentId) ? contentDocumentMap.get(cont.ContentDocumentId).ParentId : null);
                    
                    if (contentDocumentLinkMap.containsKey(cont.ContentDocumentId) && refContent.Library_ID__c == null && contentDocumentMap.containsKey(cont.ContentDocumentId)) {
                        refContent.Library_ID__c = contentDocumentLinkMap.get(cont.ContentDocumentId);
                    }
                    refContent.Content_Status__c = cont.Content_Status__c; //ConstantsController.INACTIVE;
                    refContent.Reference_Content_Type__c = cont.Reference_Content_Type__c;
                    
                    if (cont.Reference_Content_Type__c != null) {
                        refContent.Reference_Content_Type_Name__c = cont.Reference_Content_Type__r.Name__c;
                    }
                    refContent.Search_Terms_keywords__c = cont.TagCsv;
                    
                    if (cont.ContentUrl != null) {
                        refContent.Content_URL__c = cont.ContentUrl != null && cont.ContentUrl.length() > 255 ? cont.ContentUrl.substring(0,254) : cont.ContentUrl ;
			            refContent.Content_URL2__c = cont.ContentUrl != null && cont.ContentUrl.length() > 255 ? cont.ContentUrl.substring(255) : '';
                    }
                    refrenceContents.add(refContent);
                }
            }
        }
        
        //Insert new Refrence Content
        if (refrenceContents.size() > 0) {
            upsert refrenceContents;
        }
    }
}