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
 * Page: NewAttribute
 * Description : this class used to create and update attributes
 * Modified by: Rekha @26 April 2017
 */
public with sharing class NewAttributeController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public Attribute__c att { get; set; }
    public Boolean isInheritable { get; set; }
    public Boolean answer { get; set; }
    public String parentId { get; set; }
    public Boolean isMapped { get; set; }
    private Boolean ischanged;
    private String attName;
	public Boolean isSLDS { get; set; }
	
	/**
     * Method to check Permissions
     */
    public Boolean checkPermissions(Boolean isUpdate) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Attribute__c',
    										new Set<String>{'Name', UtilityController.appNamespace() + 'Inheritable__c',
												UtilityController.appNamespace() + 'Ref_Limit_to_Acct_or_Cntct__c',
    											UtilityController.appNamespace() + 'Parent__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, !isUpdate, isUpdate);
    }
	
	/**
     * Constructor
     */
    public NewAttributeController(ApexPages.StandardController controller) {
    	
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        
        if (!isSLDS) {
	        att = (Attribute__c)controller.getRecord();
	        answer = false;
	        isMapped = false;
	        isInheritable = false;
	        ischanged = false;
	        attName = '';
	        
	        if (att.Id != null) {
	            att = [SELECT Parent__c, Name, Inheritable__c, ParentIds__c, Id, Attribute_Mapping__c, Parent__r.Attribute_Mapping__c,
	            		Ref_Limit_to_Acct_or_Cntct__c FROM Attribute__c WHERE Id = :att.Id LIMIT 1];
	            parentId = att.Parent__c;
	            attName = att.Name;
	            isInheritable = att.Inheritable__c;
	            ischanged = true;
	            
	            if (att.Attribute_Mapping__c != null) {
	            	isMapped = true;
	            }
	        } else {
	            parentId = (ApexPages.currentPage().getParameters().get('retURL') != null ? ApexPages.currentPage().getParameters().get('retURL') : '');
	            att = new Attribute__c();
	            
	            if (parentId.length() <= 19 && parentId.length() >= 15) {
	                att.Parent__c = ParentId.replace('/', '');
	            }
	        }
	        checkPermissions(att.Id != null);
        }
    }
    
	/**
     * Method to save Attribute
     */
    public pageReference saveAttribute() {
    	Savepoint sp = Database.setSavepoint();
        try {
        	
        	if (checkPermissions(att.Id != null)) {
	            
	            if (att.parent__c != null && att.Inheritable__c) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Level_Inheritable_Condition);
	                Apexpages.addMessage(message);
	                return null;
	            }
	            
	            if (attName != att.Name && att.Parent__r.Attribute_Mapping__c != null) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Attribute_Cannot_be_editied);
	                Apexpages.addMessage(message);
	                return null;
	            }
	            
	            if (isMapped) {
	            	att.Inheritable__c = isInheritable;
	            }
	            
	            //to hide limit account contact field for child attribute #570
	            if (att.parent__c != null) {
	            	att.Ref_Limit_to_Acct_or_Cntct__c = null;
	            }
	            upsert att;
	            
	            if (ischanged && isInheritable != att.Inheritable__c && att.parent__c == null && att.Id != null) {
	            	
	            	if (!att.Inheritable__c || (att.Inheritable__c && answer)) {
	            		changeInheritance(att, answer, '');
	            	}
	            } else if (ischanged && att.parent__c != null && parentId != att.parent__c && att.Id != null) {
	            	List<Attribute__c> attr = [SELECT Parent__c, Name, Inheritable__c, ParentIds__c, Level__c, Id, Attribute_Mapping__c
	            							FROM Attribute__c WHERE Id = :att.parent__c LIMIT 1];
	            	
	            	if (attr.size() > 0) {
	            		
		            	if (attr[0].Level__c == 0) {
		            		changeInheritance(attr[0], true, att.Id);
		            	} else {
			            	Set<String> attSet = new Set<String>();
			            	
			            	if (attr[0].ParentIds__c != null) {
				            	
				            	for (String id : attr[0].ParentIds__c.split(',')) {
				            		attSet.add(id.trim());
				            	}
			            	}
			            	Attribute__c parent = [SELECT Parent__c, Name, Inheritable__c, ParentIds__c, Id, Attribute_Mapping__c
			            							FROM Attribute__c WHERE Id IN :attSet AND Level__c = 0 LIMIT 1];
			            	changeInheritance(parent, true, att.Id);
		            	}
	            	}
	            }
	            return new PageReference('/' + att.Id);
        	} 
        	return null;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            database.rollback(sp);
            return null;
        }
    }
    
	/**
     * Method to save and new 
     */
    public pageReference saveAndNew() {
    	
        try {
        	
        	if (checkPermissions(att.Id != null)) {
	        	
	            if (att.parent__c != null && att.Inheritable__c) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Level_Inheritable_Condition);
	                Apexpages.addMessage(message);
	                return null;
	            }
	            
	            if (attName != att.Name && att.Parent__r.Attribute_Mapping__c != null) {
	                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Attribute_Cannot_be_editied);
	                Apexpages.addMessage(message);
	                return null;
	            }
	            
	            if (isMapped) {
	            	att.Inheritable__c = isInheritable;
	            }
	            
	            //to hide limit account contact field for child attribute #570
	            if (att.parent__c != null) {
	            	att.Ref_Limit_to_Acct_or_Cntct__c = null;
	            }
	            upsert att;
	            
	            if (ischanged && isInheritable != att.Inheritable__c && att.parent__c == null && att.Id != null) {
	            	
	            	if (!att.Inheritable__c || (att.Inheritable__c && answer)) {
	            		changeInheritance(att, answer, '');
	            	}
	            } else if (ischanged && parentId != att.parent__c && att.Id != null) {
	            	Attribute__c attr = [SELECT Parent__c, Name, Inheritable__c, ParentIds__c, Level__c, Id, Attribute_Mapping__c
	        								FROM Attribute__c
	        								WHERE Id = :att.parent__c LIMIT 1];
	            	if (attr.Level__c == 0) {
	            		changeInheritance(attr, true, att.Id);
	            	} else {
		            	Set<String> attSet = new Set<String>();
		            	
		            	if (attr.ParentIds__c != null) {
			            	
			            	for (String id : attr.ParentIds__c.split(',')) {
			            		attSet.add(id.trim());
			            	}
		            	}
		            	Attribute__c parent = [SELECT Parent__c, Name, Inheritable__c, ParentIds__c, Id, Attribute_Mapping__c
		            							FROM Attribute__c
		            							WHERE Id IN :attSet
		            							AND Level__c = 0 LIMIT 1];
		            	changeInheritance(parent, true, att.Id);
	            	}
	            }
	            att = new Attribute__c();
	            
	            if (parentId != null && parentId.length() <= 19 && parentId.length() >= 15) {
	                att.Parent__c = ParentId.replace('/', '');
	            }
        	}
            return null;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            return null;
        }
    }
    
    /**
     * Method to cancel
     */
    public pageReference Cancel() {
        
        if (att.Id != null) {
            return new PageReference('/' + att.Id);
        } else if (ParentId != null) {
            return new PageReference(ParentId);
        } else {
        	Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Attribute__c'); //From the Object Api name retrieving the SObject
	        Sobject Object_name = targetType.newSObject();
	        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
	        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
	        return new PageReference('/' + sobject_describe.getKeyPrefix());
        }
    }
    
    /**
     * Method to run batch for change in inheritance
     */
    public void changeInheritance(Attribute__c attr, Boolean answer, String attId) {
        
        try {
        	ConstantsController.attributeId = attId;
        	Batch_ChangeAttributeInheritance newBatch = new Batch_ChangeAttributeInheritance(attr, answer);
            DataBase.executeBatch(newBatch);
        } catch (Exception e) {
            Apexpages.addMessages(e);
        }
    }
}