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
public with sharing class AttributeTriggerHandler {
    /**
     * Properties and variables
     */
    /*public static list < Attribute__c > newAttributes;
    public static list < Attribute__c > oldAttributes;
    public static map < Id, Attribute__c > newAttributeMap;
    public static map < Id, Attribute__c > oldAttributeMap;*/
    private static list < Attribute__c > updatedAttributes;
    private static map < Id, String > attribLevelParentIds;
    /**
     * Method called on before insert of Attribute
     */
    public static void onBeforeInsert(list < Attribute__c > newAttributes) {
        //set will store the Id of the Parent Attribute of the new Attribute added
        Set < Id > parentId = new set < Id > ();
        for (Attribute__c a: newAttributes) {
            //if the attribute is not a root attribute 
            if (a.Parent__c != null) {
                parentId.add(a.Parent__c);
            }
        }
		// map contains parentid as key and child name as set of string.
		map <id, set <String>> parentChildMap = new map<id, set<String>>();		
        //map to store the parent Attributes details
		map < Id, Attribute__c > attributesMap = new map < Id, Attribute__c >();
		// set if zero level attribute
		set<String> zeroLevelAttributeset = new set<String> ();
		
		// List of attribute including zero level and non zero level which is parent of other.
		list<Attribute__c> attributeList = new list<Attribute__c> ([SELECT id, Name, level__c,Root_Parent__c, ParentIds__c, parent__r.Attribute_Mapping__r.Id, (SELECT Id, Name FROM Attributes__r ) FROM Attribute__c WHERE Id IN: parentId OR level__c = 0 LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
		
		for (integer i = 0; i < attributeList.Size() ; i++) {
			if ( ! parentChildMap.containsKey(attributeList[i].Id) ) 
				parentChildMap.put(attributeList[i].Id, new set<string>());
			
			if ( attributeList[i].Attributes__r.Size() > 0) {				
				for(Attribute__c att : attributeList[i].Attributes__r) {
					parentChildMap.get(attributeList[i].Id).add(att.Name);
				}
			}
			attributesMap.put(attributeList[i].Id, attributeList[i]);
			
			if (attributeList[i].level__c == 0) {
				zeroLevelAttributeset.add(attributeList[i].Name);
			}			
		}
      
        //map will store the updated value like level of the new Attribute
        map < String, String > updatedAttributeMap = new map < String, String > ();
        String levelIds;
        decimal level;
       
        //iterate loop over the trigger.new list
        for (Attribute__c a: newAttributes) {
            if (a.Parent__c != null && attributesMap.containsKey(a.Parent__c) && attributesMap.get(a.Parent__c).parent__r.Attribute_Mapping__r.Id != null)
                a.addError(System.Label.CANNOT_ADD_ATTRIBUTE_FROM_ATT_MAPPING);
            //if the attribute is a root attribute then the level=0
            if (a.Parent__c == null) {
				if(zeroLevelAttributeset.Size() > 0 && zeroLevelAttributeset.contains(a.Name))
					a.addError(System.Label.No_Zero_Level_Attribute_With_Same_Name);	
                a.level__c = 0;

            } else {
				// to check two attribute with same name and their parent is Same
				if (parentChildMap.ContainsKey(a.Parent__c) && parentChildMap.get(a.Parent__c).Size() > 0){
					if(parentChildMap.get(a.Parent__c).contains(a.Name))
					a.addError(System.Label.No_Parent_With_Same_Name_Child_Attribute);
				}
				
                if (attributesMap.containsKey(a.Parent__c) && attributesMap.get(a.Parent__c) != null) {
                    //level of a non root attribute is 1 more then the parent attribute
                    a.level__c = attributesMap.get(a.Parent__c).level__c + 1;
                    if (attributesMap.get(a.Parent__c).ParentIds__c != null) {
                        a.ParentIds__c = attributesMap.get(a.Parent__c).ParentIds__c + ',' + a.Parent__c;
                        a.Root_Parent__c = attributesMap.get(a.Parent__c).Root_Parent__c;
                    } else {
                        a.ParentIds__c = a.Parent__c;
                        a.Root_Parent__c = attributesMap.get(a.Parent__c).Name;
                    }
                } else {
                    a.addError(system.label.Parent_of_this_Attribute_is_not_exist);
                }
            }
        }
    
    }
    /**
     * Method called on before update of Attribute
     */
    public static void onBeforeUpdate(list < Attribute__c > newAttributes,map < Id, Attribute__c > newAttributeMap,map < Id, Attribute__c > oldAttributeMap) {
        Set < Id > parentId = new set < Id > ();
        set < id > updateAttribute = new set < Id > ();
        for (Attribute__c a: newAttributes) {
            if (a.Parent__c != null) {
                parentId.add(a.Parent__c);
            }
            if (oldAttributeMap.get(a.Id).Parent__c != newAttributeMap.get(a.Id).Parent__c) {
                updateAttribute.add(a.Id);
            }
        }
		// map contains parentid as key and child name as set of string.
		map <id, set <String>> parentChildMap = new map<id, set<String>>();		
        //map to store the parent Attributes details
		map < Id, Attribute__c > attributesMap = new map < Id, Attribute__c >();
		// set if zero level attribute
		set<String> zeroLevelAttributeset = new set<String> ();
		
		// List of attribute including zero level and non zero level which is parent of other.
		list<Attribute__c> attributeList = new list<Attribute__c> ([SELECT id, Name, level__c,Root_Parent__c, ParentIds__c, parent__r.Attribute_Mapping__r.Id, (SELECT Id, Name FROM Attributes__r ) FROM Attribute__c WHERE Id IN: parentId OR level__c = 0 LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
		
		for (integer i = 0; i < attributeList.Size() ; i++) {
			if ( ! parentChildMap.containsKey(attributeList[i].Id) ) 
				parentChildMap.put(attributeList[i].Id, new set<string>());
			
			if ( attributeList[i].Attributes__r.Size() > 0) {				
				for(Attribute__c att : attributeList[i].Attributes__r) {
					parentChildMap.get(attributeList[i].Id).add(att.Name);
				}
			}
			attributesMap.put(attributeList[i].Id, attributeList[i]);
			
			if (attributeList[i].level__c == 0) {
				zeroLevelAttributeset.add(attributeList[i].Name);
			}			
		}
		
        if (updateAttribute.size() > 0) {
           // Map < Id, Attribute__c > attributesMap = new map < Id, Attribute__c > ([Select id, level__c,Name, ParentIds__c,Root_Parent__c from Attribute__c where Id IN: parentId]);
            map < String, String > updatedAttributeMap = new map < String, String > ();
            set < String > parentIds;
            for (Attribute__c a: newAttributes) {
                if (a.Parent__c == null) {
					if(zeroLevelAttributeset.Size() > 0 && zeroLevelAttributeset.contains(a.Name) && oldAttributeMap.get(a.Id).Name != newAttributeMap.get(a.Id).Name)
						a.addError(System.Label.No_Zero_Level_Attribute_With_Same_Name);
                    a.level__c = 0;
                    a.ParentIds__c = null;
                } else {
					// to check two attribute with same name and their parent is Same
					if (parentChildMap.ContainsKey(a.Parent__c) && parentChildMap.get(a.Parent__c).Size() > 0 && oldAttributeMap.get(a.Id).Name != newAttributeMap.get(a.Id).Name){
						if(parentChildMap.get(a.Parent__c).contains(a.Name))
							a.addError(System.Label.No_Parent_With_Same_Name_Child_Attribute);
					}
                    if (a.Level__c == 0)
                        a.addError(System.Label.Root_level_Attribute_Reassigned);
                    if (attributesMap.get(a.Parent__c).ParentIds__c != null && (oldAttributeMap.get(a.Id).Parent__c != newAttributeMap.get(a.Id).Parent__c)) {
                        parentIds = new Set < String > (attributesMap.get(a.Parent__c).ParentIds__c.split(','));
                        if (parentIds.contains(a.Id) || (a.Id == a.Parent__c)) {
                            a.addError(System.Label.Attribute_cannot_Assign_same_Hierarchy);
                        } else {
                            a.level__c = attributesMap.get(a.Parent__c).level__c + 1;
                            if (attributesMap.get(a.Parent__c).ParentIds__c != null) {
                                a.ParentIds__c = attributesMap.get(a.Parent__c).ParentIds__c + ',' + a.Parent__c;
                                a.Root_Parent__c = attributesMap.get(a.Parent__c).Root_Parent__c;
                            } else {
                                a.ParentIds__c = a.Parent__c;
                                a.Root_Parent__c = attributesMap.get(a.Parent__c).Name;
                            }
                        }
                    }
                    //this else can be removed after successful data creation
                    else {
                        a.level__c = attributesMap.get(a.Parent__c).level__c + 1;
                        if (attributesMap.get(a.Parent__c).ParentIds__c != null) {
                            a.ParentIds__c = attributesMap.get(a.Parent__c).ParentIds__c + ',' + a.Parent__c;
                            a.Root_Parent__c = attributesMap.get(a.Parent__c).Root_Parent__c;
                        } else {
                            a.ParentIds__c = a.Parent__c;
                            a.Root_Parent__c = attributesMap.get(a.Parent__c).Name;
                        }
                    }
                }
            }
        } else {
			for (Attribute__c a: newAttributes) {
				if (a.Parent__c == null) {
					if(zeroLevelAttributeset.Size() > 0 && zeroLevelAttributeset.contains(a.Name) && oldAttributeMap.get(a.Id).Name != newAttributeMap.get(a.Id).Name)
						a.addError(System.Label.No_Zero_Level_Attribute_With_Same_Name);						                   
                } else {
					// to check two attribute with same name and their parent is Same
					if (parentChildMap.ContainsKey(a.Parent__c) && parentChildMap.get(a.Parent__c).Size() > 0 && oldAttributeMap.get(a.Id).Name != newAttributeMap.get(a.Id).Name){
						if(parentChildMap.get(a.Parent__c).contains(a.Name))
							a.addError(System.Label.No_Parent_With_Same_Name_Child_Attribute);
					}
				}
			}
		}   
    }
    /**
     * Method called on before delete of Attribute
     */
    public static void onBeforeDelete(list < Attribute__c > oldAttributes,map < Id, Attribute__c > oldAttributeMap) {
    		
        for (Attribute__c a: [Select Id, (Select Id from Attributes__r limit 1), (select Id from Reference_Request_Label_Attributes__r), (select Label__c from Attributes_Labels__r), (select Id from Nomination_Label_Attributes__r) from Attribute__c where Id IN: oldAttributes LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
            for (Attribute__c aaa: a.Attributes__r) {
                oldAttributeMap.get(a.Id).addError(System.Label.Attribute_reassign_before_delete);
                break;
            }
            for (Attributes_Labels__c attLabel: a.Attributes_Labels__r) {
                ConstantsController.labelIds.add(attLabel.label__c);
            }
            for (Reference_Request_Label_Attribute__c rrla: a.Reference_Request_Label_Attributes__r) {
                ConstantsController.RRLAIds.add(rrla.Id);
            }
            for (Nomination_Label_Attribute__c nlatt: a.Nomination_Label_Attributes__r) {
                ConstantsController.NMLAIds.add(nlatt.Id);
            }
        }
        
        //	#REF-1274
    	// map of zero level attribute
    	map<Id, Attribute__c> zeroLevelAttributeMap = new map<Id, Attribute__c>([SELECT id, Name FROM Attribute__c WHERE Level__c = 0 LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
        
        // RBI id to Account attribute List map which is going to be deleted along with Attribute
    	map<Id, List<Account_Attribute__c>> rbiIdToDeletedAccountAttributeListMap = new map<Id, List<Account_Attribute__c>>();
    	set<Id> deletedAttributeIdSet = new set<Id>();
    	for(Account_Attribute__c accAttr : [SELECT id, Name, Reference_Basic_Information__c, Attribute__c, 
    											Attribute__r.Name, Attribute__r.ParentIds__c FROM 
    											Account_Attribute__c WHERE Attribute__c in: oldAttributes 
    											LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
    		
    		if(!rbiIdToDeletedAccountAttributeListMap.containsKey(accAttr.Reference_Basic_Information__c)) {
    			rbiIdToDeletedAccountAttributeListMap.put(accAttr.Reference_Basic_Information__c, new List<Account_Attribute__c>());
    		}
    		rbiIdToDeletedAccountAttributeListMap.get(accAttr.Reference_Basic_Information__c).add(accAttr);
    		
    		deletedAttributeIdSet.add(accAttr.Attribute__c);
    	}
    	
    	// RBI id to Contact attribute List map which is going to be deleted along with Attribute
    	map<Id, List<Contact_Attribute__c>> rbiIdToDeletedContactAttributeListMap = new map<Id, List<Contact_Attribute__c>>();
    	for(Contact_Attribute__c contactAttr : [SELECT id, Name, Reference_Basic_Information__c, Attribute__c,
    												Attribute__r.Name, Attribute__r.ParentIds__c  FROM 
    												Contact_Attribute__c WHERE Attribute__c in: oldAttributes 
    												LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
    		
    		if(!rbiIdToDeletedContactAttributeListMap.containsKey(contactAttr.Reference_Basic_Information__c)) {
    			rbiIdToDeletedContactAttributeListMap.put(contactAttr.Reference_Basic_Information__c, new List<Contact_Attribute__c>());
    		}
    		rbiIdToDeletedContactAttributeListMap.get(contactAttr.Reference_Basic_Information__c).add(contactAttr);
    		
    		deletedAttributeIdSet.add(contactAttr.Attribute__c);
    	}
        
    	//	map of Content attribute which is going to be deleted along with Attribute
    	map<Id, Content_Attribute__c> contentAttributeMap = new map<Id, Content_Attribute__c>([SELECT id, Name, Reference_Content__c FROM Content_Attribute__c WHERE Attribute__c in: oldAttributes LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    	
    	// set of RBI Ids
    	set<Id> rbiSet = new set<Id>();
    	rbiSet.addAll(rbiIdToDeletedAccountAttributeListMap.keySet());
    	rbiSet.addAll(rbiIdToDeletedContactAttributeListMap.keySet());
        
        // set of reference Content Ids
    	set<Id> refContentSet = new set<Id>();
        for (Content_Attribute__c cntAtt : contentAttributeMap.values()) {
    		refContentSet.add(cntAtt.Reference_Content__c);
    	}
    	
    	// Map of Attribute Filter
    	map<Id, Attributes_Labels__c> deletedAttributeLabelMap = new map<Id,Attributes_Labels__c>();
    	for (Attributes_Labels__c attLabel : [SELECT id, Name, Attribute__c, Label__c, Label__r.Filter_no__c FROM 
    											Attributes_Labels__c WHERE Attribute__c in : deletedAttributeIdSet 
    											LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
    		deletedAttributeLabelMap.put(attLabel.Attribute__c, attLabel);
    	}
    	
    	list<Reference_Basic_Information__c> rbiList = new list<Reference_Basic_Information__c>();
    	for(Reference_Basic_Information__c rbiRec : [SELECT id, Name, Account__c, Contact__c, Attribute_Count__c, 
    													Attribute_Ids__c, Attributes__c, Parent_Attributes__c, Label_Ids1__c 
    													FROM Reference_Basic_Information__c WHERE Id in: rbiSet 
    													LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
    		
    		List<String> attributeIdsListOnRBI = (rbiRec.Attribute_Ids__c != null) ? rbiRec.Attribute_Ids__c.split(',') : new List<String>();
			List<String> attributeNameListOnRBI = (rbiRec.Attributes__c != null) ? rbiRec.Attributes__c.split(',') : new List<String>();
			List<String> parentAttributeListOnRBI = (rbiRec.Parent_Attributes__c != null) ? rbiRec.Parent_Attributes__c.split(',') : new List<String>();
			List<String> labelIds1ListOnRBI = (rbiRec.Label_Ids1__c != null) ? rbiRec.Label_Ids1__c.split(',') : new List<String>();
			
			if(rbiRec.Contact__c != Null && rbiIdToDeletedContactAttributeListMap.containsKey(rbiRec.Id)) {
				for (Contact_Attribute__c conAtt : rbiIdToDeletedContactAttributeListMap.get(rbiRec.Id)) {
					if(rbiRec.Attribute_Count__c != null) {
						rbiRec.Attribute_Count__c -= 1;
					}
					
					Integer attributeIdIndex = attributeIdsListOnRBI.indexOf(conAtt.Attribute__c);
					if(attributeIdIndex != -1) {
						attributeIdsListOnRBI.remove(attributeIdIndex);
					}
					
					Integer attributeNameIndex = attributeNameListOnRBI.indexOf(conAtt.Attribute__r.Name);
					if(attributeNameIndex != -1) {
						attributeNameListOnRBI.remove(attributeNameIndex);
					}
					
					Integer parentAttributeNameIndex = (conAtt.Attribute__c != null && String.isNotBlank(conAtt.Attribute__r.ParentIds__c)
    															&& zeroLevelAttributeMap.containsKey(conAtt.Attribute__r.ParentIds__c.substringBefore(','))) 
    															? (parentAttributeListOnRBI.indexOf(zeroLevelAttributeMap.get(conAtt.Attribute__r.ParentIds__c.substringBefore(',')).Name))
    															: -1;
					if (parentAttributeNameIndex != -1) {
						parentAttributeListOnRBI.remove(parentAttributeNameIndex);
					}
					
					Integer labelIdIndex = (deletedAttributeLabelMap.containsKey(conAtt.Attribute__c)) 
												? (labelIds1ListOnRBI.indexOf('F'+String.ValueOf(deletedAttributeLabelMap.get(conAtt.Attribute__c).Label__r.Filter_no__c)+'F'))
												: -1;
    					
					if(labelIdIndex != -1) {
						labelIds1ListOnRBI.remove(labelIdIndex);
					}	    					
				}
			} else {
				if(rbiIdToDeletedAccountAttributeListMap.containsKey(rbiRec.Id)) {
    				for (Account_Attribute__c accAtt : rbiIdToDeletedAccountAttributeListMap.get(rbiRec.Id)) {
						if(rbiRec.Attribute_Count__c != null) {
							rbiRec.Attribute_Count__c -= 1;
						}
    					
    					Integer attributeIdIndex = attributeIdsListOnRBI.indexOf(accAtt.Attribute__c);
    					if(attributeIdIndex != -1) {
    						attributeIdsListOnRBI.remove(attributeIdIndex);
    					}
    					
    					Integer attributeNameIndex = attributeNameListOnRBI.indexOf(accAtt.Attribute__r.Name);
    					if(attributeNameIndex != -1) {
    						attributeNameListOnRBI.remove(attributeNameIndex);
    					}
    					
    					Integer parentAttributeNameIndex = (accAtt.Attribute__c != null && String.isNotBlank(accAtt.Attribute__r.ParentIds__c)
    															&& zeroLevelAttributeMap.containsKey(accAtt.Attribute__r.ParentIds__c.substringBefore(','))) 
    															? (parentAttributeListOnRBI.indexOf(zeroLevelAttributeMap.get(accAtt.Attribute__r.ParentIds__c.substringBefore(',')).Name))
    															: -1;
    					if (parentAttributeNameIndex != -1) {
    						parentAttributeListOnRBI.remove(parentAttributeNameIndex);
    					}
    					
    					Integer labelIdIndex = (deletedAttributeLabelMap.containsKey(accAtt.Attribute__c)) 
    												? (labelIds1ListOnRBI.indexOf('F'+String.ValueOf(deletedAttributeLabelMap.get(accAtt.Attribute__c).Label__r.Filter_no__c)+'F'))
    												: -1;
    					if(labelIdIndex != -1) {
    						labelIds1ListOnRBI.remove(labelIdIndex);
    					}	    					
	    			}
    			}
    		}	
			 
			rbiRec.Attribute_Ids__c = String.join(attributeIdsListOnRBI, ',');
			rbiRec.Attributes__c = String.join(attributeNameListOnRBI, ',');
			rbiRec.Parent_Attributes__c = String.join(parentAttributeListOnRBI, ',');
			rbiRec.Label_Ids1__c = String.join(labelIds1ListOnRBI, ',');
			rbiList.add(rbiRec);
		}
    	
    	if(rbiList.size() > 0) {
    		update rbiList;
    	}
    	
		list<Reference_Content__c> refContentList = new list<Reference_Content__c>();
    	for(Reference_Content__c refContentRec : [SELECT id, Name, Attribute_Count__c, Attribute_Ids__c, Attributes__c, 
    												(SELECT id, Name, Attribute__c, Attribute__r.Name FROM Content_Attributes__r) 
    												FROM Reference_Content__c WHERE id in : refContentSet 
    												LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
    		refContentList.add(refContentRec);
    	}
    	
    	if (refContentList.Size() > 0) {
    		for (Integer i = 0; i < refContentList.Size(); i++) {
    			Integer attributeCount = 0;
    			String attributeIds = '';
    			String attributes = '';
    			for (Content_Attribute__c ca : refContentList[i].Content_Attributes__r) {
    				if (!contentAttributeMap.containsKey(ca.id)){
    					attributeCount++;
    					attributeIds += ca.Attribute__c + ',';
	    				attributes += ca.Attribute__r.Name + ',';
    				}    				
    			}
    			refContentList[i].Attribute_Count__c = attributeCount;
    			refContentList[i].Attribute_Ids__c = attributeIds.removeEnd(',');
    			refContentList[i].Attributes__c = attributes.removeEnd(',');
    		}
    		update refContentList;
    	}  
    }
    /**
     * Method called on after delete of Attribute
     */
    public static void onAfterDelete() {
        for (Attributes_Labels__c attLabel: [select Label__c from Attributes_Labels__c where Label__c In: ConstantsController.labelIds]) {
            ConstantsController.labelIds.remove(attLabel.Label__c);
        }
        list < Reference_Type_Mapping__c > rtm = [select Id from Reference_Type_Mapping__c where Label__c In: ConstantsController.labelIds];
        if (rtm.size() > 0)
            delete rtm;
        list < Reference_Request_Label_Attribute__c > rrLAtt = [select id from Reference_Request_Label_Attribute__c where Id In: ConstantsController.RRLAIds];
        if (rrLAtt.size() > 0)
            delete rrLAtt;
        list < Nomination_Label_Attribute__c > nlAtt = [select Id from Nomination_Label_Attribute__c where Id In: ConstantsController.NMLAIds];
        if (nlAtt.size() > 0)
            delete nlAtt;
    }
    /**
     * Rajneesh Raj (Jan 6,2018)
     * Method called on after Undelete of Attribute
     */
    public static void onAfterUndelete(list < Attribute__c > newAttributes) {
    	//	#REF-1274
    	//set will store the Id of the Parent Attribute of the new Attribute added
        Set < Id > parentId = new set < Id > ();
        Set < Id > attIdSet = new set < Id > ();
        for (Attribute__c a: newAttributes) {
        	attIdSet.add(a.id);
            //if the attribute is not a root attribute 
            if (a.Parent__c != null) {
                parentId.add(a.Parent__c);
            }
        }
    	// map contains parentid as key and child name as set of string.
		map <id, set <String>> parentChildMap = new map<id, set<String>>();		
        // set if zero level attribute
		set<String> zeroLevelAttributeset = new set<String> ();
		
		// List of attribute including zero level and non zero level which is parent of other.
		list<Attribute__c> attributeList = new list<Attribute__c> ([SELECT id, Name, level__c,Root_Parent__c, ParentIds__c, parent__r.Attribute_Mapping__r.Id, (SELECT Id, Name FROM Attributes__r ) FROM Attribute__c WHERE Id IN: parentId OR level__c = 0 LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
		
		for (integer i = 0; i < attributeList.Size() ; i++) {
			if (attributeList[i].level__c == 0) {
				if (attIdSet.contains(attributeList[i].id))
				zeroLevelAttributeset.add(attributeList[i].Name);
			} else { 
				if ( ! parentChildMap.containsKey(attributeList[i].Id) ) 
					parentChildMap.put(attributeList[i].Id, new set<string>());
				
				if ( attributeList[i].Attributes__r.Size() > 0) {				
					for(Attribute__c att : attributeList[i].Attributes__r) {
						if (attIdSet.contains(attributeList[i].id))
						parentChildMap.get(attributeList[i].Id).add(att.Name);
					}
				}
			}			
		}
        //iterate loop over the trigger.new list
        for (Attribute__c a: newAttributes) {
			if (a.Parent__c == null) {
				if(zeroLevelAttributeset.Size() > 0 && zeroLevelAttributeset.contains(a.Name))
					a.addError(System.Label.No_Zero_Level_Attribute_With_Same_Name);
            } else {
				// to check two attribute with same name and their parent is Same
				if (parentChildMap.ContainsKey(a.Parent__c) && parentChildMap.get(a.Parent__c).Size() > 0){
					if(parentChildMap.get(a.Parent__c).contains(a.Name)){
						a.addError(System.Label.No_Parent_With_Same_Name_Child_Attribute);
						}
				}
			}
		}
    	// map of zero level attribute
    	map<Id, Attribute__c> zeroLevelAttributeMap = new map<Id, Attribute__c>([SELECT id, Name FROM Attribute__c WHERE Level__c = 0 LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    	//	map of Account attribute which is going to be deleted along with Attribute
    	map<Id, Account_Attribute__c> accountAttributeMap = new map<Id, Account_Attribute__c>([SELECT id, Name, Reference_Basic_Information__c FROM Account_Attribute__c WHERE Attribute__c in: newAttributes LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    	//	map of Contact attribute which is going to be deleted along with Attribute
    	map<Id, Contact_Attribute__c> contactAttributeMap = new map<Id, Contact_Attribute__c>([SELECT id, Name, Reference_Basic_Information__c FROM Contact_Attribute__c WHERE Attribute__c in: newAttributes LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    	//	map of Content attribute which is going to be deleted along with Attribute
    	map<Id, Content_Attribute__c> contentAttributeMap = new map<Id, Content_Attribute__c>([SELECT id, Name, Reference_Content__c FROM Content_Attribute__c WHERE Attribute__c in: newAttributes LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    	
    	// set of RBI
    	set<Id> rbiSet = new set<Id>();
    	// set of reference Content
    	set<Id> refContentSet = new set<Id>();
    	
    	for (Account_Attribute__c aa : accountAttributeMap.values()) {
    		rbiSet.add(aa.Reference_Basic_Information__c);
    	}
    	
    	for (Contact_Attribute__c ca : contactAttributeMap.values()) {
    		rbiSet.add(ca.Reference_Basic_Information__c);
    	}
    	
    	for (Content_Attribute__c cntAtt : contentAttributeMap.values()) {
    		refContentSet.add(cntAtt.Reference_Content__c);
    	}
    	
    	list<Reference_Basic_Information__c> rbiList = new list<Reference_Basic_Information__c>([SELECT id, Name, Account__c, Contact__c, Attribute_Count__c, Attribute_Ids__c, Attributes__c, Parent_Attributes__c,
    														 Label_Ids1__c, (SELECT id, Name, Attribute__c, Attribute__r.Name, Attribute__r.ParentIds__c FROM Account_Attributes__r),
    														 (SELECT id, Name, Attribute__c, Attribute__r.Name, Attribute__r.ParentIds__c FROM Contact_Attributes__r) FROM Reference_Basic_Information__c WHERE Id in: rbiSet LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    	
    	list<Reference_Content__c> refContentList = new list<Reference_Content__c>([SELECT id, Name, Attribute_Count__c, Attribute_Ids__c, Attributes__c, 
    													(SELECT id, Name, Attribute__c, Attribute__r.Name FROM Content_Attributes__r) FROM Reference_Content__c WHERE id in : refContentSet LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]);
    	
    	// To find Label which is to be updated in RBI
    	set<Id> AttributeIdSet = new set<Id>();
    	if (rbiList.Size() > 0) {
    		for (Integer index = 0; index < rbiList.Size(); index++) {
    			if (rbiList[index].Account_Attributes__r.Size() > 0) {
    				for (Account_Attribute__c accAttri : rbiList[index].Account_Attributes__r) {
    					AttributeIdSet.add(accAttri.Attribute__c);
    				}    				
    			}
    			if (rbiList[index].Contact_Attributes__r.Size() > 0) {
    				for (Contact_Attribute__c conAttri : rbiList[index].Contact_Attributes__r) {
    					AttributeIdSet.add(conAttri.Attribute__c);
    				}
    			}
    		}
    	}
    	// Map of Attribute Filter
    	map<id, Attributes_Labels__c> attributeLabelMap = new map<id,Attributes_Labels__c>();
    	for (Attributes_Labels__c attLabel : [SELECT id, Name, Attribute__c, Label__c, Label__r.Filter_no__c FROM Attributes_Labels__c WHERE Attribute__c in : AttributeIdSet LIMIT : Limits.getLimitQueryRows() - Limits.getQueryRows()]) {
    		attributeLabelMap.put(attLabel.Attribute__c, attLabel);
    	}
    	// To update RBI
    	if (rbiList.Size() > 0) {
	    	for( Integer i = 0; i < rbiList.Size(); i++) {
	    		Integer attributeCount = 0;
    			String attributeIds = '';
    			String attributes = '';
    			String parentAttribute = '';
    			String label = '';		
    			
	    		if (rbiList[i].Contact__c != Null){
	    			for (Contact_Attribute__c conAtt : rbiList[i].Contact_Attributes__r) {	    				
    					attributeCount++;
    					attributeIds += conAtt.Attribute__c + ',';
    					attributes += conAtt.Attribute__r.Name + ',';
    					if (zeroLevelAttributeMap.containsKey(conAtt.Attribute__r.ParentIds__c.substringBefore(','))) {
    						if (! parentAttribute.Contains(zeroLevelAttributeMap.get(conAtt.Attribute__r.ParentIds__c.substringBefore(',')).Name))
    						parentAttribute += zeroLevelAttributeMap.get(conAtt.Attribute__r.ParentIds__c.substringBefore(',')).Name +',';
    					}
    					if (attributeLabelMap.containsKey(conAtt.Attribute__c)) {
    						if (! label.Contains('F'+String.ValueOf(attributeLabelMap.get(conAtt.Attribute__c).Label__r.Filter_no__c)+'F'))
    						label += 'F'+String.ValueOf(attributeLabelMap.get(conAtt.Attribute__c).Label__r.Filter_no__c)+'F' +',';
    					}
	    			}	    				    			
	    		} else {
	    			for (Account_Attribute__c accAtt : rbiList[i].Account_Attributes__r) {	    				
    					attributeCount++;
    					attributeIds += accAtt.Attribute__c + ',';
    					attributes += accAtt.Attribute__r.Name + ',';
    					if (zeroLevelAttributeMap.containsKey(accAtt.Attribute__r.ParentIds__c.substringBefore(','))) {
    						if (! parentAttribute.Contains(zeroLevelAttributeMap.get(accAtt.Attribute__r.ParentIds__c.substringBefore(',')).Name))
    						parentAttribute += zeroLevelAttributeMap.get(accAtt.Attribute__r.ParentIds__c.substringBefore(',')).Name +',';
    					}
    					if (attributeLabelMap.containsKey(accAtt.Attribute__c)) {
    						if (! label.Contains('F'+String.ValueOf(attributeLabelMap.get(accAtt.Attribute__c).Label__r.Filter_no__c)+'F'))
    						label += 'F'+String.ValueOf(attributeLabelMap.get(accAtt.Attribute__c).Label__r.Filter_no__c)+'F' +',';
    					}
	    			}
	    		}
	    		rbiList[i].Attribute_Count__c = attributeCount;
    			rbiList[i].Attribute_Ids__c = attributeIds.removeEnd(',');
    			rbiList[i].Attributes__c = attributes.removeEnd(',');
    			rbiList[i].Parent_Attributes__c = parentAttribute.removeEnd(',');
    			rbiList[i].Label_Ids1__c = label.removeEnd(',');
	    	}
	    	update rbiList;
    	}	
    	
    	if (refContentList.Size() > 0) {
    		for (Integer i = 0; i < refContentList.Size(); i++) {
    			Integer attributeCount = 0;
    			String attributeIds = '';
    			String attributes = '';
    			for (Content_Attribute__c ca : refContentList[i].Content_Attributes__r) {    				
					attributeCount++;
					attributeIds += ca.Attribute__c + ',';
    				attributes += ca.Attribute__r.Name + ',';    				    				
    			}
    			refContentList[i].Attribute_Count__c = attributeCount;
    			refContentList[i].Attribute_Ids__c = attributeIds.removeEnd(',');
    			refContentList[i].Attributes__c = attributes.removeEnd(',');
    		}
    		update refContentList;
    	}    
    }
    /**
     * Method called on after update of Attribute
     */
    public static void onAfterUpdate(list < Attribute__c > newAttributes,map < Id, Attribute__c > newAttributeMap,map < Id, Attribute__c > oldAttributeMap) {
        //set to store the Ids of the Attribute whose parents has changed
        try {
            list < Attribute__c > changedAttributesParentPresent = new list < Attribute__c > ();
            set < String > changedAttribIdsParentAbs = new set < String > ();
            set < String > nameChangeAttrib = new set < String > ();
            set < Id > attParentIds = new set < Id > ();
            set < String > parentAttribIds = new set < String > ();
            set < Id > parentToBeAdded = new set < Id > ();
            for (Attribute__c a: newAttributes) {
                if (oldAttributeMap.get(a.Id).Parent__c != newAttributeMap.get(a.Id).Parent__c) {
                    if (newAttributeMap.get(a.Id).Parent__c != null)
                        changedAttributesParentPresent.add(a);
                    else
                        changedAttribIdsParentAbs.add(a.Id);
                    attParentIds.add(a.Id);
                }
                if (oldAttributeMap.get(a.Id).Name != newAttributeMap.get(a.Id).Name) {
                    nameChangeAttrib.add(a.Id);
                }
            }
            for (Attribute__c a: changedAttributesParentPresent) {
                if (a.parentIds__c != null) {
                    parentAttribIds.addAll(a.ParentIds__c.split(','));
                }
            }
            if (parentAttribIds.size() > 0) {
                for (Attribute__c a: [select Id, Level__c from Attribute__c where Id In: parentAttribIds]) {
                    if (a.level__c != 0)
                        parentToBeAdded.add(a.Id);
                }
            }
            if (attParentIds.size() > 0)
                UpdateAttributeHierarchy(attParentIds);
            if (nameChangeAttrib.size() > 0) {
                changeNamesInRelatedList(nameChangeAttrib, oldAttributeMap, newAttributeMap);
            }
            if (changedAttributesParentPresent.size() > 0) {
                //function which add new heirarchy to the account
                addParentAttributeToAccount(changedAttributesParentPresent, parentToBeAdded, oldAttributeMap, newAttributeMap);
                //function which add new heirarchy to the contact
                addParentAttributeToContact(changedAttributesParentPresent, parentToBeAdded, oldAttributeMap, newAttributeMap);
                //function which add new Content to the Content 
                addParentAttributeToContent(changedAttributesParentPresent, parentToBeAdded, oldAttributeMap, newAttributeMap);
            } else if (changedAttribIdsParentAbs.size() > 0) {
                removeRootLevelAttributeFromAccount(changedAttribIdsParentAbs, oldAttributeMap, newAttributeMap);
                removeRootLevelAttributeFromContact(changedAttribIdsParentAbs, oldAttributeMap, newAttributeMap);
                removeRootLevelAttributeFromContent(changedAttribIdsParentAbs, oldAttributeMap, newAttributeMap);
            }
            
        } catch (Exception e) {
            List < Messaging.SingleEmailMessage > listmail = new List < Messaging.SingleEmailMessage > ();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {
                'tejpal.kumawat@metacube.com', 'devendra.natani@metacube.com', 'rekha.jangir@metacube.com'
            };
            mail.setToAddresses(toAddresses);
            mail.setSubject('Issue');

            String body = e.getLineNumber() + '=====' + e.getStackTraceString() + '====' + e.getTypeName() + '====';
            mail.setHtmlBody(body);
            mail.setToAddresses(toAddresses);
            listmail.add(mail);
            if (listmail.size() > 0)
                Messaging.sendEmail(listmail);
        }
    }
    /**
     * Method to change name of attribute
     */
    private static void changeNamesInRelatedList(Set < String > nameChangeAttrib, map < Id, Attribute__c > oldMap, map < Id, Attribute__c > newMap) {
        try {
            set < Id > accIds = new set < Id > ();
            set < Id > cntctIds = new set < Id > ();
            set < Id > refContentIDs = new set < Id > ();
            list < Reference_Basic_Information__c > rbiUpdate = new list < Reference_Basic_Information__c > ();
            list < Reference_Content__c > updateContent = new list < Reference_Content__c > ();
            set < String > attribNames;
            String attributes;
            list < Reference_Content__c > contents = new list < Reference_Content__c > ();
            for (Account_Attribute__c accAtt: WithoutSharingHelperController.accAttInAttributeTriggerHandler(nameChangeAttrib)) {
                accIds.add(accAtt.Account__c);
            }
            for (Contact_Attribute__c cntctatt: WithoutSharingHelperController.conAttInAttributeTriggerHandler(nameChangeAttrib)) {
                cntctIds.add(cntctatt.Contact__c);
            }
            for (Content_Attribute__c contAtt: [select Reference_Content__c from Content_Attribute__c where Attribute__c In: nameChangeAttrib]) {
                refContentIDs.add(contAtt.Reference_Content__c);
            }
            for (Reference_Basic_Information__c rbiAcc: [select Attributes__c from Reference_Basic_Information__c where Account__c In: accIds and Contact__c = null]) {
                attribNames = new set < String > ();
                attributes = '';
                if (rbiAcc.Attributes__c != null && rbiAcc.Attributes__c != '') {
                    for (String attName: rbiAcc.Attributes__c.split(',')) {
                        for (Id attId: nameChangeAttrib) {
                            if (attName.trim() == oldMap.get(attId).Name) {
                                if (attributes == '')
                                    attributes = newMap.get(attId).Name;
                                else
                                    attributes = attributes + ', ' + newMap.get(attId).Name;
                            } else {
                                if (attributes == '')
                                    attributes = attName;
                                else
                                    attributes = attributes + ', ' + attName;
                            }
                        }
                    }
                } else {
                    for (Id attId: nameChangeAttrib) {
                        if (attributes == '')
                            attributes = newMap.get(attId).Name;
                        else
                            attributes = attributes + ', ' + newMap.get(attId).Name;
                    }
                }
                if (attributes != '') {
                    rbiAcc.Attributes__c = attributes;
                    rbiUpdate.add(rbiAcc);
                }
            }

            for (Reference_Basic_Information__c rbiContact: [select Attributes__c from Reference_Basic_Information__c where Contact__c In: cntctIds and Contact__c != null]) {
                attribNames = new set < String > ();
                attributes = '';
                if (rbiContact.Attributes__c != null && rbiContact.Attributes__c != '') {
                    for (String attName: rbiContact.Attributes__c.split(',')) {
                        for (Id attId: nameChangeAttrib) {
                            if (attName.trim() == oldMap.get(attId).Name) {
                                if (attributes == '')
                                    attributes = newMap.get(attId).Name;
                                else
                                    attributes = attributes + ', ' + newMap.get(attId).Name;
                            } else {
                                if (attributes == '')
                                    attributes = attName.trim();
                                else
                                    attributes = attributes + ', ' + attName.trim();
                            }
                        }
                    }
                } else {
                    for (Id attId: nameChangeAttrib) {
                        if (attributes == '')
                            attributes = newMap.get(attId).Name;
                        else
                            attributes = attributes + ', ' + newMap.get(attId).Name;
                    }
                }
                if (attributes != '') {
                    rbiContact.Attributes__c = attributes;
                    rbiUpdate.add(rbiContact);
                }
            }

            for (Reference_Content__c refContent: [select Attributes__c from Reference_Content__c where Id In: refContentIDs]) {
                attribNames = new set < String > ();
                attributes = '';
                if (refContent.Attributes__c != null && refContent.Attributes__c != '') {
                    for (String attName: refContent.Attributes__c.split(',')) {
                        for (Id attId: nameChangeAttrib) {
                            if (attName.trim() == oldMap.get(attId).Name) {
                                if (attributes == '')
                                    attributes = newMap.get(attId).Name;
                                else
                                    attributes = attributes + ', ' + newMap.get(attId).Name;
                            } else {
                                if (attributes == '')
                                    attributes = attName.trim();
                                else
                                    attributes = attributes + ', ' + attName.trim();
                            }
                        }
                    }
                } else {
                    for (Id attId: nameChangeAttrib) {
                        if (attributes == '')
                            attributes = newMap.get(attId).Name;
                        else
                            attributes = attributes + ', ' + newMap.get(attId).Name;
                    }
                }
                if (attributes != '') {
                    refContent.Attributes__c = attributes;
                    updateContent.add(refContent);
                }
            }
            if (rbiUpdate.size() > 0)
                update rbiUpdate;
            if (updateContent.size() > 0)
                update updateContent;
        } catch (Exception e) {
            List < Messaging.SingleEmailMessage > listmail = new List < Messaging.SingleEmailMessage > ();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {
                'tejpal.kumawat@metacube.com', 'devendra.natani@metacube.com', 'rekha.jangir@metacube.com'
            };
            mail.setToAddresses(toAddresses);
            mail.setSubject('Issue');
            String body = e.getLineNumber() + '=====' + e.getStackTraceString() + '====' + e.getTypeName() + '====';
            mail.setHtmlBody(body);
            mail.setToAddresses(toAddresses);
            listmail.add(mail);
            if (listmail.size() > 0)
                Messaging.sendEmail(listmail);
        }
    }
    /**
     * Method to add parent attribute to account
     */
    private static void addParentAttributeToAccount(list < Attribute__c > changedAttributesParentPresent, set < Id > parentToBeAdded, map < Id, Attribute__c > oldMap, map < Id, Attribute__c > newMap) {

        list < Account_Attribute__c > newAccountAttributes = new list < Account_Attribute__c > ();
        Account_Attribute__c tempObject;
        map < Id, Account_Attribute__c > currentAccountAttribts = new map < Id, Account_Attribute__c > ();
        map < Id, set < Id >> accountAttribMap = new map < Id, set < Id >> ();
        map < Id, list < string >> attribParentMap = new map < Id, list < String >> ();
        set < String > AttIdSet = new set < String > ();
        set < String > preventDuplicacy = new set < String > ();
        for (Attribute__c att: changedAttributesParentPresent) {
            AttIdSet.add(att.Id);
        }
        for (Account_Attribute__c aT: WithoutSharingHelperController.getAccountAttribute2(AttIdSet)) {
            if (!accountAttribMap.containsKey(aT.Account__c))
                accountAttribMap.put(aT.Account__c, new set < id > ());
            currentAccountAttribts.put(aT.Id, aT);
        }
        for (Account_Attribute__c aT: WithoutSharingHelperController.getAccountAttribute3(accountAttribMap.keySet())) {
            accountAttribMap.get(aT.Account__c).add(aT.Attribute__c);
        }
        for (Attribute__c a: changedAttributesParentPresent) {
            if (!attribParentMap.containsKey(a.Id))
                attribParentMap.put(a.Id, new list < String > ());
            if (a.parentIds__c != null) {
                attribParentMap.get(a.Id).addAll(a.ParentIds__c.split(','));
            }
        }
        for (Id accAttId: currentAccountAttribts.keySet()) {
            if (currentAccountAttribts.get(accAttId) != null && attribParentMap.get(currentAccountAttribts.get(accAttId).Attribute__c) != null) {
                for (String attId: attribParentMap.get(currentAccountAttribts.get(accAttId).Attribute__c)) {
                    if (parentToBeAdded.contains(attId)) {
                        if (!preventDuplicacy.contains(currentAccountAttribts.get(accAttId).Account__c + '' + attId) && accountAttribMap.get(currentAccountAttribts.get(accAttId).Account__c) != null && !accountAttribMap.get(currentAccountAttribts.get(accAttId).Account__c).contains(attId)) {
                            tempObject = new Account_Attribute__c(Account__c = currentAccountAttribts.get(accAttId).Account__c, Attribute__c = attId, Inheritable__c = currentAccountAttribts.get(accAttId).Inheritable__c);
                            newAccountAttributes.add(tempObject);
                            preventDuplicacy.add(currentAccountAttribts.get(accAttId).Account__c + '' + attId);
                        }
                    }
                }
            }
        }
        if (newAccountAttributes.size() > 0) {
            ConstantsController.addParentToAccount = false;
            ConstantsController.addParentToContact = false;
            insert newAccountAttributes;
        }
    }
    /**
     * Method to add parent attribute to contact
     */
    private static void addParentAttributeToContact(list < Attribute__c > changedAttributesParentPresent, set < Id > parentToBeAdded, map < Id, Attribute__c > oldMap, map < Id, Attribute__c > newMap) {
        list < Contact_Attribute__c > newContactAttributes = new list < Contact_Attribute__c > ();
        Contact_Attribute__c tempObject;
        map < Id, Contact_Attribute__c > currentContactAttribs = new map < Id, Contact_Attribute__c > ();
        map < Id, set < Id >> contactAttribMap = new map < Id, set < Id >> ();
        set < String > preventDuplicacy = new set < String > ();
        map < Id, list < string >> attribParentMap = new map < Id, list < String >> ();
        set < String > AttIdSet = new set < String > ();
        for (Attribute__c att: changedAttributesParentPresent) {
            AttIdSet.add(att.Id);
        }
        for (Contact_Attribute__c aT: WithoutSharingHelperController.getContactAttribute2(AttIdSet)) {
            if (!contactAttribMap.containsKey(aT.Contact__c))
                contactAttribMap.put(aT.Contact__c, new set < id > ());
            currentContactAttribs.put(aT.Id, aT);
        }
        for (Contact_Attribute__c aT: WithoutSharingHelperController.getContactAttribute3(contactAttribMap.keySet())) {
            contactAttribMap.get(aT.Contact__c).add(aT.Attribute__c);
        }

        for (Attribute__c a: changedAttributesParentPresent) {
            if (!attribParentMap.containsKey(a.Id))
                attribParentMap.put(a.Id, new list < String > ());
            if (a.parentIds__c != null) {
                attribParentMap.get(a.Id).addAll(a.ParentIds__c.split(','));
            }
        }
        for (Id accAttId: currentContactAttribs.keySet()) {
            if (currentContactAttribs.get(accAttId) != null && attribParentMap.get(currentContactAttribs.get(accAttId).Attribute__c) != null && attribParentMap.get(currentContactAttribs.get(accAttId).Attribute__c) != null) {
                for (String attId: attribParentMap.get(currentContactAttribs.get(accAttId).Attribute__c)) {
                    if (parentToBeAdded.contains(attId)) {
                        if (!preventDuplicacy.contains(currentContactAttribs.get(accAttId).Contact__c + '' + attId) && contactAttribMap.get(currentContactAttribs.get(accAttId).Contact__c) != null && !contactAttribMap.get(currentContactAttribs.get(accAttId).Contact__c).contains(attId)) {
                            tempObject = new Contact_Attribute__c(Contact__c = currentContactAttribs.get(accAttId).Contact__c, Attribute__c = attId);
                            newContactAttributes.add(tempObject);
                            preventDuplicacy.add(currentContactAttribs.get(accAttId).Contact__c + '' + attId);
                        }
                    }
                }
            }
        }
        if (newContactAttributes.size() > 0) {
            ConstantsController.addParentToContact = false;
            ConstantsController.addParentToAccount = false;
            insert newContactAttributes;
        }
    }
    /**
     * Method to add parent attribute to content
     */
    public static void addParentAttributeToContent(list < Attribute__c > changedAttributesParentPresent, set < Id > parentToBeAdded, map < Id, Attribute__c > oldMap, map < Id, Attribute__c > newMap) {
        list < Content_Attribute__c > newContentAttributes = new list < Content_Attribute__c > ();
        Content_Attribute__c tempObject;
        map < Id, Content_Attribute__c > currentContentAttribs = new map < Id, Content_Attribute__c > ();
        map < Id, set < Id >> contentAttribMap = new map < Id, set < Id >> ();
        set < String > preventDuplicacy = new set < String > ();
        map < Id, list < string >> attribParentMap = new map < Id, list < String >> ();
        set < String > AttIdSet = new set < String > ();
        for (Attribute__c att: changedAttributesParentPresent) {
            AttIdSet.add(att.Id);
        }
        for (Content_Attribute__c aT: [select Reference_Content__c, Attribute__c from Content_Attribute__c where Attribute__c In: AttIdSet]) {
            if (!contentAttribMap.containsKey(aT.Reference_Content__c))
                contentAttribMap.put(aT.Reference_Content__c, new set < id > ());
            currentContentAttribs.put(aT.Id, aT);
        }

        for (Content_Attribute__c aT: [select Reference_Content__c, Attribute__c from Content_Attribute__c where Reference_Content__c In: contentAttribMap.keySet()]) {
            contentAttribMap.get(aT.Reference_Content__c).add(aT.Attribute__c);
        }

        for (Attribute__c a: changedAttributesParentPresent) {
            if (!attribParentMap.containsKey(a.Id))
                attribParentMap.put(a.Id, new list < String > ());
            if (a.parentIds__c != null) {
                attribParentMap.get(a.Id).addAll(a.ParentIds__c.split(','));
            }
        }

        for (Id accAttId: currentContentAttribs.keySet()) {
            if (currentContentAttribs.get(accAttId) != null && attribParentMap.get(currentContentAttribs.get(accAttId).Attribute__c) != null && attribParentMap.get(currentContentAttribs.get(accAttId).Attribute__c) != null) {
                for (String attId: attribParentMap.get(currentContentAttribs.get(accAttId).Attribute__c)) {
                    if (parentToBeAdded.contains(attId)) {
                        if (!preventDuplicacy.contains(currentContentAttribs.get(accAttId).Reference_Content__c + '' + attId) && contentAttribMap.get(currentContentAttribs.get(accAttId).Reference_Content__c) != null && !contentAttribMap.get(currentContentAttribs.get(accAttId).Reference_Content__c).contains(attId)) {
                            tempObject = new Content_Attribute__c(Reference_Content__c = currentContentAttribs.get(accAttId).Reference_Content__c, Attribute__c = attId);
                            newContentAttributes.add(tempObject);
                            preventDuplicacy.add(currentContentAttribs.get(accAttId).Reference_Content__c + '' + attId);
                        }
                    }
                }
            }
        }
        if (newContentAttributes.size() > 0) {
            ConstantsController.addParentToContent = false;
            ConstantsController.addParentToAccount = false;
            insert newContentAttributes;
        }
    }
    /**
     * Method to remove root level attribute from account
     */
    private static void removeRootLevelAttributeFromAccount(set < String > changedAttribIds, map < Id, Attribute__c > oldMap, map < Id, Attribute__c > newMap) {
        list < Account_Attribute__c > accAtt = new list < Account_Attribute__c > ();
        accAtt = WithoutSharingHelperController.accAttInAttributeTriggerHandler(changedAttribIds);
        if (accAtt.size() > 0) {
            ConstantsController.deleteAttributeFromAccount = false;
            ConstantsController.shouldAccountAttributeDeleteOfContact = true;
            ConstantsController.shouldAccountAttributeDeleteOfContent = true;
            delete accAtt;
        }
    }
    /**
     * Method to remove root level attribute from contact
     */
    private static void removeRootLevelAttributeFromContact(set < String > changedAttribIds, map < Id, Attribute__c > oldMap, map < Id, Attribute__c > newMap) {
        list < Contact_Attribute__c > cntctAtt = new list < Contact_Attribute__c > ();
        cntctAtt = WithoutSharingHelperController.conAttInAttributeTriggerHandler(changedAttribIds);
        if (cntctAtt.size() > 0) {
            ConstantsController.deleteAttributFromContact = true;
            delete cntctAtt;
        }

    }
    
    /**
     * Method to remove root level attribute from content
     */
    private static void removeRootLevelAttributeFromContent(set < String > changedAttribIds, map < Id, Attribute__c > oldMap, map < Id, Attribute__c > newMap) {
        list < Content_Attribute__c > contentAttrib = new list < Content_Attribute__c > ();
        contentAttrib = [select Id from Content_Attribute__c where Attribute__c In: changedAttribIds];
        if (contentAttrib.size() > 0) {
            ConstantsController.deleteAttributeFromContent = true;
            delete contentAttrib;
        }
    }
    /**
     * Future Method 
     */
    @future
    public static void UpdateAttributeHierarchy(set < Id > newAttIds) {
        updatedAttributes = new list < Attribute__c > ();
        attribLevelParentIds = new map < Id, String > ();
        set < Id > parentAttribs = new set < Id > ();
        set < Id > newParentAttribs;
        map < Id, list < Attribute__c >> attributesMap = new map < Id, list < Attribute__c >> ();
        for (Attribute__c att: [select name, id, parent__c, level__c, parentIds__c from Attribute__c where Id In: newAttIds]) {
            parentAttribs.add(att.id);
            attribLevelParentIds.put(att.id, att.Level__c + ' ' + att.parentIds__c);
            while (parentAttribs.size() > 0) {
                newParentAttribs = new set < Id > ();
                for (Attribute__c newAtt: [select name, id, parent__c, level__c, parentIds__c from Attribute__c where parent__c In: parentAttribs]) {
                    newAtt.level__c = decimal.valueOf(attribLevelParentIds.get(newAtt.Parent__c).split(' ').get(0)) + 1;
                    if (attribLevelParentIds.get(newAtt.Parent__c).split(' ').get(1) != 'null') {
                        newAtt.parentIds__c = attribLevelParentIds.get(newAtt.Parent__c).split(' ').get(1) + ',' + newAtt.Parent__c;
                    } else
                        newAtt.parentIds__c = newAtt.parent__c;
                    attribLevelParentIds.put(newAtt.Id, newAtt.level__c + ' ' + newAtt.parentIds__c);
                    updatedAttributes.add(newAtt);
                    newParentAttribs.add(newAtt.Id);
                }
                parentAttribs = new set < Id > ();
                if (newParentAttribs.size() > 0)
                    parentAttribs = newParentAttribs;
            }
        }
        if (updatedAttributes.size() > 0)
            update updatedAttributes;
    }
}