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
public with sharing class AdvancedRoutingTriggerHandler {
    
    public static void onBeforeInsert(List<Advanced_Routing__c> newList) {
    	List<Advanced_Routing__c> existingAdvRoutingList = [SELECT Id, Name, Adv_Routing_Name__c, Adv_Routing_Client_Value__c, Adv_Routing_Attribute__c
    															FROM Advanced_Routing__c LIMIT :Limits.getLimitQueryRows()];
    	Set<String> existingAttributeIds = new Set<String>();
    	Map<String, Set<String>> attributeIdsToCheck = new Map<String, Set<String>>();
    	List<Id> newAttIds =  new List<Id>();
		
		for (Advanced_Routing__c record : newList) {
    		if (record.Adv_Routing_Attribute__c != null) {
	    		newAttIds.add(record.Adv_Routing_Attribute__c);
    		}
    	}

    	for (Advanced_Routing__c arOld : existingAdvRoutingList) {
    		if (arOld.Adv_Routing_Attribute__c != null) {
	    		existingAttributeIds.add(arOld.Adv_Routing_Attribute__c);
    		}
    	}
    	String attQuery = 'SELECT ParentIds__c, Id FROM Attribute__c WHERE Id IN :newAttIds';
    	for (Advanced_Routing__c att : newList) {
    		
    		if (att.Adv_Routing_Attribute__c != null) {
	    		String tempId = '\'%' + String.escapeSingleQuotes(att.Adv_Routing_Attribute__c) + '%\'';
	    		attQuery += ' OR ParentIds__c LIKE ' + tempId;
    		}
    	}
    	List<Attribute__c> tempAttributeList = Database.query(attQuery);
    	for (Attribute__c att : tempAttributeList) {
    		if (!attributeIdsToCheck.containsKey(att.Id) && newAttIds.contains(att.Id)) {
    			attributeIdsToCheck.put(att.Id, new Set<String>());
    		}
    	}
    	for (Attribute__c att : tempAttributeList) {
    		
			if (att.ParentIds__c != null && att.ParentIds__c != '') {
    			for (String parentId : att.ParentIds__c.split(',')) {
	    			if (attributeIdsToCheck.containsKey(att.Id)) {
		    			attributeIdsToCheck.get(att.Id).add(parentId);
	    			}
	    			if (attributeIdsToCheck.containsKey(parentId)) {
	    				attributeIdsToCheck.get(parentId).add(att.Id);
	    			}
	    		}
    		}
    	}
    	
    	for (Advanced_Routing__c arNew : newList) {
    		if (attributeIdsToCheck.containsKey(arNew.Adv_Routing_Attribute__c)) {
    			for (String relatedAttId : attributeIdsToCheck.get(arNew.Adv_Routing_Attribute__c)) {
    				if (existingAttributeIds.contains(relatedAttId)) {
    					arNew.adderror(System.Label.AdvDuplicateAttParent);
    				}
    			}
    		}
    		for (Advanced_Routing__c arOld : existingAdvRoutingList) {
    			if (arNew.Adv_Routing_Attribute__c != null && arNew.Adv_Routing_Attribute__c == arOld.Adv_Routing_Attribute__c) {
    				arNew.adderror(System.Label.AdvDuplicateAtt);
    			}
    		}
    	}
    }
    /*
    public static void onBeforeDelete(List<Advanced_Routing__c> oldList) {
    	//for (Advanced_Routing__c ar : oldList) {
    		//ar.adderror('You cannot delete Advanced Routing records.');
    	//}
    }
    */
    public static void onBeforeUpdate(List<Advanced_Routing__c> newList, Map<Id, Advanced_Routing__c> newMap) {
    	List<Advanced_Routing__c> existingAdvRoutingList = [SELECT Id, Name, Adv_Routing_Name__c, Adv_Routing_Client_Value__c, Adv_Routing_Attribute__c
    															FROM Advanced_Routing__c
    															WHERE Id NOT IN :newMap.keySet()];
    	Set<String> existingAttributeIds = new Set<String>();
    	Map<String, Set<String>> attributeIdsToCheck = new Map<String, Set<String>>();
    	Set<String> newAttIds = new Set<String>();
    	for (Advanced_Routing__c ar : newList) {
    		newAttIds.add(ar.Adv_Routing_Attribute__c);
    	}
    	for (Advanced_Routing__c arOld : existingAdvRoutingList) {
    		if (arOld.Adv_Routing_Attribute__c != null) {
	    		existingAttributeIds.add(arOld.Adv_Routing_Attribute__c);
    		}
    	}
    	String attQuery = 'SELECT ParentIds__c, Id FROM Attribute__c WHERE Id IN :newAttIds';
    	for (Id attId : newMap.keySet()) {
    		//String tempId = '%' + attId + '%';
    		if (newMap.get(attId).Adv_Routing_Attribute__c != null) {
	    		String tempId = '\'%' + String.escapeSingleQuotes(newMap.get(attId).Adv_Routing_Attribute__c) + '%\'';
	    		attQuery += ' OR ParentIds__c LIKE ' + tempId;
    		}
    	}
    	List<Attribute__c> tempAttributeList = Database.query(attQuery);
    	for (Attribute__c att : tempAttributeList) {
    		if (!attributeIdsToCheck.containsKey(att.Id) && newAttIds.contains(att.Id)) {
    			attributeIdsToCheck.put(att.Id, new Set<String>());
    		}
    	}
    	for (Attribute__c att : tempAttributeList) {
    		//system.debug('att-->' + att);
    		//system.debug('newMap-->' + newMap);
    		//system.debug('attributeIdsToCheck-->' + attributeIdsToCheck);
    		if (att.ParentIds__c != null && att.ParentIds__c != '') {
    			for (String parentId : att.ParentIds__c.split(',')) {
	    			if (attributeIdsToCheck.containsKey(att.Id)) {
		    			attributeIdsToCheck.get(att.Id).add(parentId);
	    			}
	    			if (attributeIdsToCheck.containsKey(parentId)) {
	    				attributeIdsToCheck.get(parentId).add(att.Id);
	    			}
	    		}
    		}
    	}
    	//system.assert(false, 'attributeIdsToCheck-->' + attributeIdsToCheck);
    	for (Advanced_Routing__c arNew : newList) {
    		if (attributeIdsToCheck.containsKey(arNew.Adv_Routing_Attribute__c)) {
    			for (String relatedAttId : attributeIdsToCheck.get(arNew.Adv_Routing_Attribute__c)) {
    				if (existingAttributeIds.contains(relatedAttId)) {
    					arNew.adderror(System.Label.AdvDuplicateAttParent);
    				}
    			}
    		}
    		for (Advanced_Routing__c arOld : existingAdvRoutingList) {
    			if (arNew.Adv_Routing_Attribute__c != null && arNew.Adv_Routing_Attribute__c == arOld.Adv_Routing_Attribute__c) {
    				arNew.adderror(System.Label.AdvDuplicateAtt);
    			}
    		}
    	}
    }
}