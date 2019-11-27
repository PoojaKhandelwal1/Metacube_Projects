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
 * Trigger: ContentAttribute
 * Description: Handler class for DML operations on Content_Attribute__c object.
 * Last Modified By: Rajneesh Raj @11 Dec 2017
 */
public with sharing class ContentAttributeTriggerHandler {
    
    /**
     * Method called on before insert of Content Attribute
     */
    public static void onBeforeInsert(List<Content_Attribute__c> newContentAttributes) {
        Set<Id> ContentIds = new Set<Id>();
        Set<Id> AttribIds = new Set<Id>();
        // map which store the contactId as the key AND the already associated attributes with that contact
        Map<Id, Set<Id>> oldContentAttrib = new Map<Id, Set<Id>>();
        
        // iterate over the trigger.new List to get associated content Ids
        for (Content_Attribute__c att : newContentAttributes) {
            
            if (att.Reference_Content__c != null) {
                ContentIds.add(att.Reference_Content__c);
            }
            
            if (att.Account__c != null) {
            	att.From_Account__c = true;
            } else {
            	att.From_Account__c = false;
            }
        }
        
        if (ContentIds.size() != 0) {
            
            // get the attributes already associated with the content AND store them
            for (Content_Attribute__c a : WithoutSharingHelperController.getContentAttributesForUpdateRBI2(ContentIds)) {
            	
                if (oldContentAttrib.get(a.Reference_Content__c) == null) {
                    oldContentAttrib.put(a.Reference_Content__c, new Set<Id>());
                }
                oldContentAttrib.get(a.Reference_Content__c).add(a.Attribute__c);
            }
            
            // check if the attribute is already associated with the contact then report an error
            for (Content_Attribute__c a : newContentAttributes) {
                
                if (oldContentAttrib.get(a.Reference_Content__c) != null
                			&& oldContentAttrib.get(a.Reference_Content__c).contains(a.Attribute__c)) {
                    a.addError(System.Label.Content_Attribute);
                }
            }
        }
    }
    
    /**
     * Method called on after insert of Content Attribute
     */
    public static void onAfterInsert(List<Content_Attribute__c> newContentAttributes,
    									Map<Id, Content_Attribute__c> newContentAttributeMap) {
        
        Set<Id> contentIds = new Set<Id>();
        Set<String> attribNames = new Set<String>();
        Set<Id> refContentIds = new Set<Id>();
        Map<Id, Reference_Content__c> Contents = new Map<Id, Reference_Content__c>();
        List<Account_Reference_Content__c> accountRefContents = new List<Account_Reference_Content__c>();
        Map<Id, List<Content_Attribute__c>> ContentAttrib = new Map<Id, List<Content_Attribute__c>>();
        
        // store the contactIds
        for (Content_Attribute__c a : newContentAttributes) {
            
            if (a.Reference_Content__c != null) {
                contentIds.add(a.Reference_Content__c);
            }
            
            if (a.Account__c == null) {
                refContentIds.add(a.Reference_Content__c);
            }
        }
        
        // map to store the contents
        for (Reference_Content__c rc : WithoutSharingHelperController.getRefContentList(contentIds)) {
            Contents.put(rc.Id, rc);
            accountRefContents.addAll(rc.Account_Reference_Contents__r);
            
            for (Content_Attribute__c ca : rc.Content_Attributes__r) {
                
                if (!ContentAttrib.containsKey(rc.Id)) {
                    ContentAttrib.put(rc.Id, new List<Content_Attribute__c>());
                }
                ContentAttrib.get(rc.Id).add(ca);
            }
        }
        
        //	Re #1185
        // "Attributes" and "Attribute Ids" field of Reference Content populated through Content Attribute record.
        // On the basis of unique Attribute Id 
        for (Id ContentId : ContentAttrib.keySet()) {
            String attributes = '';
			String attributeIds = '';
            attribNames = new Set<String>();
            
            if (ContentAttrib.get(ContentId) != null) {
                
                for (Content_Attribute__c att : ContentAttrib.get(ContentId)) {
                	
					if (attributeIds == '' || attributeIds == null) {
						attributes = att.Attribute__r.Name;
						attributeIds = att.Attribute__c;
					} else {
						if( !attributeIds.contains(att.Attribute__c)) {
							attributes += ','+att.Attribute__r.Name;
							attributeIds += ','+att.Attribute__c;
						}						
					}
                    /* if (attributes == '' || attributes == null) {
                        attributes = att.Attribute__r.Name;
                        attribNames.add(att.Attribute__r.Name);
                    } else {
                        
                        if (!attribNames.contains(att.Attribute__r.Name)) {
                            attributes = attributes + ', ' + att.Attribute__r.Name;
                            attribNames.add(att.Attribute__r.Name);
                        }
                    } */
                }
                Contents.get(ContentId).Attributes__c = attributes;
				Contents.get(ContentId).Attribute_Ids__c = attributeIds;
                //added regarding ticket #623
                Contents.get(ContentId).Attribute_Count__c = ContentAttrib.get(ContentId).size();
                
                if (Contents.get(ContentId).Content_Status__c == null) {
                    Contents.get(ContentId).Content_Status__c = ConstantsController.INACTIVE;
                }
            }
        }
        
        if (Contents.values() != null) {
            WithoutSharingHelperController.upsertRefContentList(Contents.values());
        }
        
        if (!ConstantsController.fromAccountToContent) {
            addAttributeToAccount(refContentIds, ContentAttrib, accountRefContents);
        }
        
        if (ConstantsController.addParentToContent) {
            addParentAttribToContent(newContentAttributes, newContentAttributeMap, ContentAttrib);
        }
    }
    
    /**
     * Method to add Attributes to Account
     */
    private static void addAttributeToAccount(Set<Id> contentIds, Map<Id, List<Content_Attribute__c>> ContentAttribMap,
    											List<Account_Reference_Content__c> accRefContents) {

        //map to map the contentId with the accountId
        Map<Id, Set<Id>> contentAccountMap = new Map<Id, Set<Id>>();
        //List to insert the new Account_Attribute__c records
        List<Account_Attribute__c> newAccountAttrib = new List<Account_Attribute__c>();
        //map which maps the already existing attributes on the account
        Map<Id, Set<Id>> accountAttrib = new Map<Id, Set<Id>>();
        Set<Id> accountIds = new Set<Id>();
        Account_Attribute__c tempObj;
        Map<Id, Reference_Basic_Information__c> accountRBI = new Map<Id, Reference_Basic_Information__c>();
        
        for (Account_Reference_Content__c tempObj1 : accRefContents) {
            
            if (contentIds.contains(tempObj1.Reference_Content__c)) {
                
                if (!contentAccountMap.containsKey(tempObj1.Reference_Content__c)) {
                    contentAccountMap.put(tempObj1.Reference_Content__c, new Set<Id>());
                }
                contentAccountMap.get(tempObj1.Reference_Content__c).add(tempObj1.Account__c);
                accountIds.add(tempObj1.Account__c);
            }
        }
        Set<String> oppAttributes = new Set<String>();
        
        for (Attribute__c att : WithoutSharingHelperController.getAttributesForUpdateRBI()) {
            
            for (Attribute__c att1 : att.Attributes__r) {
                oppAttributes.add(att1.Id);
            }
        }
        
        for (Account acc : WithoutSharingHelperController.getAccountsList(contentAccountMap.keySet(), accountIds)) {
        	
            for (Account_Attribute__c tempObj1 : acc.Account_Attributes__r) {
                
                if (!accountAttrib.containsKey(tempObj1.Account__c)) {
                    accountAttrib.put(tempObj1.Account__c, new Set<Id>());
                }
                accountAttrib.get(tempObj1.Account__c).add(tempObj1.Attribute__c);
            }
            
            if (acc.Reference_Basic_Informations__r.size() > 0) {
                accountRBI.put(acc.Id, acc.Reference_Basic_Informations__r[0]);
            }
        }
        for (Id contentId : contentAccountMap.keySet()) {
        	
            if (ContentAttribMap.get(contentId) != null) {
                
                for (Content_Attribute__c cA : ContentAttribMap.get(contentId)) {
                    
                    if (cA.Account__c == null && !oppAttributes.contains(cA.Attribute__c)) {
                        
                        if (contentAccountMap.get(contentId) != null) {
                            
                            for (Id accId : contentAccountMap.get(contentId)) {
                                
                                if (accountRBI.containsKey(accId)
                            				&& accountRBI.get(accId).Is_Referenceable__c
                            				&& accountAttrib.get(accId) != null) {
                                    
                                    if (!accountAttrib.get(accId).contains(cA.Attribute__c)) {
                                        tempObj = new Account_Attribute__c();
                                        tempObj.Account__c = accId;
                                        tempObj.Attribute__c = cA.Attribute__c;
                                        tempObj.Reference_Content__c = contentId;
                                        newAccountAttrib.add(tempObj);
                                    }
                                } else if (accountRBI.containsKey(accId)
                                			&& accountRBI.get(accId).Is_Referenceable__c) {
                                    
                                    tempObj = new Account_Attribute__c();
                                    tempObj.Account__c = accId;
                                    tempObj.Attribute__c = cA.Attribute__c;
                                    tempObj.Reference_Content__c = contentId;
                                    newAccountAttrib.add(tempObj);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if (newAccountAttrib.size() > 0) {
            ConstantsController.addAttributesToContact = false;
            ConstantsController.addAttributesToContent = false;
            WithoutSharingHelperController.upsertAccountAttributes(newAccountAttrib);
        }
    }
    
    /**
     * Method to add parent Attributes to Contact
     */
    private static void addParentAttribToContent(List<Content_Attribute__c> ContentAttributes,
    						Map<Id, Content_Attribute__c> newMap, Map<Id, List<Content_Attribute__c>> ContentAttrib) {
        
        Set<String> attribIds = new Set<String>();
        List<Content_Attribute__c> newContentAttrib = new List<Content_Attribute__c>();
        Content_Attribute__c tempObj;
        Map<Id, List<String>> attribParentMap = new Map<Id, List<String>>();
        Map<Id, Set<Id>> ContentAttribMap = new Map<Id, Set<Id>>();
        Set<String> ContentAttribDuplicacy = new Set<String>();
        Set<String> parentAttribIds = new Set<String>();
        Set<Id> parentToBeAdded = new Set<Id>();
        
        for (Content_Attribute__c aT : ContentAttributes) {
            attribIds.add(aT.Attribute__c);
            ContentAttribMap.put(aT.Reference_Content__c, new Set<Id>());
        }
        
        for (Attribute__c a : WithoutSharingHelperController.getAttributesList(attribIds)) {
            
            if (a.ParentIds__c != null) {
                
                if (!attribParentMap.containsKey(a.Id)) {
                    attribParentMap.put(a.Id, new List<String>());
                }
                attribParentMap.get(a.Id).addAll(a.ParentIds__c.split(','));
                parentAttribIds.addAll(a.ParentIds__c.split(','));
            }
        }
        
        for (Attribute__c a : WithoutSharingHelperController.getAttributesList(parentAttribIds)) {
            
            if (a.level__c != 0) {
                parentToBeAdded.add(a.Id);
            }
        }
        
        for (Id cntentId : ContentAttrib.keySet()) {
            
            for (Content_Attribute__c aT : ContentAttrib.get(cntentId)) {
                
                if (ContentAttribMap.containsKey(aT.Reference_Content__c)) {
                    ContentAttribMap.get(aT.Reference_Content__c).add(aT.Attribute__c);
                }
            }
        }
        
        for (Id accAttId : newMap.keySet()) {
            
            if (attribParentMap.get(newMap.get(accAttId).Attribute__c) != null) {
                
                for (String attId : attribParentMap.get(newMap.get(accAttId).Attribute__c)) {
                    
                    if (parentToBeAdded.contains(attId)) {
                        
                        if (ContentAttribMap.get(newMap.get(accAttId).Reference_Content__c) != null
                    			&& !ContentAttribMap.get(newMap.get(accAttId).Reference_Content__c).contains(attId)
                    			&& !ContentAttribDuplicacy.contains(newMap.get(accAttId).Reference_Content__c + ' ' + attId)) {
                            
                            tempObj = new Content_Attribute__c();
                            tempObj.Reference_Content__c = newMap.get(accAttId).Reference_Content__c;
                            tempObj.Attribute__c = attId;
                            tempObj.Account__c = newMap.get(accAttId).Account__c;
                            newContentAttrib.add(tempObj);
                            ContentAttribDuplicacy.add(newMap.get(accAttId).Reference_Content__c + ' ' + attId);
                        }
                    }
                }
            }
        }
        
        if (newContentAttrib.size() > 0) {
            ConstantsController.addParentToContent = false;
            WithoutSharingHelperController.upsertContentAtt(newContentAttrib);
        }
    }
    
    /**
     * Method called on after undelete of Content Attribute
     */
    public static void onAfterUndelete(List<Content_Attribute__c> newContentAttributes) {
        Set<Id> contentIds = new Set<Id>();
        
        for (Content_Attribute__c a : newContentAttributes) {
            
            if (a.Is_fromMapping__c) {
                a.addError(system.Label.Content_Attribute_Undelete_Error);
            } else if (a.Reference_Content__c != null) {
                contentIds.add(a.Reference_Content__c);
            }
        }
        // map to store the contacts
        Map<Id, Reference_Content__c> Contents = WithoutSharingHelperController.getRefContentMap(contentIds);
        // map to map the contactId with the Contact_Attribute__c record
        Map<Id, List<Content_Attribute__c>> ContentAttrib = new Map<Id, List<Content_Attribute__c>>();
        
        for (Content_Attribute__c a : [SELECT Reference_Content__c, Attribute__r.Name FROM Content_Attribute__c WHERE Reference_Content__c IN : contentIds]) {
            
            if (ContentAttrib.get(a.Reference_Content__c) == null) {
                ContentAttrib.put(a.Reference_Content__c, new List<Content_Attribute__c>());
            }
            ContentAttrib.get(a.Reference_Content__c).add(a);
        }
        
        //	Re #1185
        // "Attributes" and "Attribute Ids" field of Reference Content populated through Content Attribute record.
        // On the basis of unique Attribute Id 
         for (Id ContentId : ContentAttrib.keySet()) {
            String attributes = '';
            String attributeIds = '';
            if (ContentAttrib.get(ContentId) != null) {
            	
                for (Content_Attribute__c att: ContentAttrib.get(ContentId)) {
                	
					if (attributeIds == '' || attributeIds == null) {
						attributes = att.Attribute__r.Name;
						attributeIds = att.Attribute__c;
					} else {
						if (!attributeIds.contains(att.Attribute__c)) {
							attributes += ','+att.Attribute__r.Name;
							attributeIds += ','+att.Attribute__c;
						}						
					}
                    /* if (attributes == '') {
                        attributes = att.Attribute__r.Name;
                    } else {
                        attributes = attributes + ', ' + att.Attribute__r.Name;
                    } */
                }
                Contents.get(ContentId).Attributes__c = attributes;
				Contents.get(ContentId).Attribute_Ids__c = attributeIds;
                //added regarding ticket #623
                Contents.get(ContentId).Attribute_Count__c = ContentAttrib.get(ContentId).size();
            }
        }
        
        if (Contents.values() != null) {
            upsert Contents.values();
        }
    }

    /**
     * Method called on after delete of Content Attribute
     */
    public static void onAfterDelete(List<Content_Attribute__c> oldContentAttributes) {
        
        Set<String> ContentIds = new Set<String>();
        Set<String> attribIds = new Set<String>();
       /*  Map<Id, Set<String>> oldContentAttrib = new Map<Id, Set<String>>(); */
	    Map<Id, list<Content_Attribute__c>> oldContentAttrib = new Map<Id, list<Content_Attribute__c>>();
        
        for (Content_Attribute__c a : oldContentAttributes) {
        	
            if (a.Reference_Content__c != null) {
                ContentIds.add(a.Reference_Content__c);
                oldContentAttrib.put(a.Reference_Content__c, new list<Content_Attribute__c>());
            }
            attribIds.add(a.Attribute__c);
        }
        Map<Id, Reference_Content__c> Contents = new Map<Id, Reference_Content__c>([SELECT Id, Attributes__c , Attribute_Ids__c
        											FROM Reference_Content__c WHERE Id IN :ContentIds]);
        
        if (ContentIds.size() != 0) {
        	
            for (Content_Attribute__c a : [SELECT Reference_Content__c, Attribute__c, Attribute__r.Name FROM Content_Attribute__c 
            								WHERE Reference_Content__c IN : ContentIds]) {
                oldContentAttrib.get(a.Reference_Content__c).add(a);
            }
            
        //	Re #1185
        // "Attributes" and "Attribute Ids" field of Reference Content populated through Content Attribute record.
        // On the basis of unique Attribute Id 
            for (Id ContentId : oldContentAttrib.keySet()) {
                String attributes = '';
                String attributeIds = '';
				
                if (oldContentAttrib.get(ContentId).size() > 0) {
                	
                     for (Content_Attribute__c s : oldContentAttrib.get(ContentId)) {
						 
						if (attributeIds == '' || attributeIds == null) {
							attributes = s.Attribute__r.Name;
							attributeIds = s.Attribute__c;
						} else {
							if( !attributeIds.contains(s.Attribute__c)) {
								attributes += ','+s.Attribute__r.Name;
								attributeIds += ','+s.Attribute__c;
							}						
						}
                        /* if (attributes == '') {
                            attributes = s;
                        } else {
                            attributes = attributes + ', ' + s;
                        } */
                    } 
                }
                Contents.get(ContentId).Attributes__c = attributes;
				Contents.get(ContentId).Attribute_Ids__c = attributeIds;
                //added regarding ticket #623
                Contents.get(ContentId).Attribute_Count__c = oldContentAttrib.get(ContentId).size();
            }
            
            upsert Contents.values();
            deleteAttributeFrmAccount(ContentIds, attribIds);
        }
    }
    /**
     * Method to delete Attributes FROM Account
     */
    private static void deleteAttributeFrmAccount(Set<String> ContentIds, Set<String> attribIds) {
        List<Account_Attribute__c> accuntAttribDelete = new List<Account_Attribute__c>([SELECT Id, Account__c FROM Account_Attribute__c 
        														WHERE Attribute__c IN: attribIds AND Account__c != :ConstantsController.mergeAccountId 
        														AND Reference_Content__c IN: ContentIds]);
        
        if (accuntAttribDelete.size() > 0) {
            ConstantsController.shouldAccountAttributeDeleteOfContent = true;
            WithoutSharingHelperController.deleteAccountAttributes(accuntAttribDelete);
        }
    }
    /**
     * Method called on before delete of Content Attribute
     */
    public static void onbeforeDelete(List<Content_Attribute__c> oldContentAttributes) {
    	
        if (!ConstantsController.shouldAttributesOfContentDelete) {
            Map<Id, Set<Id>> contentAttribMap = new Map<Id, Set<Id>>();
            Map<Id, Set<Id>> attributeParentChildMap = new Map<Id, Set<Id>>();
            Set<Id> contentIds = new Set<Id>();
            Set<Id> attribIds = new Set<Id>();
            
            for (Content_Attribute__c cA : oldContentAttributes) {
                contentIds.add(cA.Reference_Content__c);
                attribIds.add(cA.Attribute__c);
                contentAttribMap.put(cA.Reference_Content__c, new Set<id>());
                attributeParentChildMap.put(cA.Attribute__c, new Set<Id>());
            }
            
            for (Attribute__c a : [SELECT Id, Parent__c FROM Attribute__c WHERE Parent__c IN: attribIds]) {
                attributeParentChildMap.get(a.Parent__c).add(a.Id);
            }
            
            for (Content_Attribute__c cA : [SELECT Id, Reference_Content__c, Attribute__c FROM Content_Attribute__c 
            								WHERE Id NOT IN: oldContentAttributes AND Reference_Content__c IN: contentIds]) {
                contentAttribMap.get(cA.Reference_Content__c).add(cA.Attribute__c);
            }
            
            for (Content_Attribute__c cA : oldContentAttributes) {
            	
                for (Id attribId : attributeParentChildMap.get(cA.Attribute__c)) {
                	
                    if (contentAttribMap.get(cA.Reference_Content__c).contains(attribId) && !ConstantsController.deleteAttributeFromContent) {
                        cA.addError(System.Label.Attribute_removal_to_associated_RefContent_with_Child_Attr_Msg);
                    }
                }
            }
        }
    }
}