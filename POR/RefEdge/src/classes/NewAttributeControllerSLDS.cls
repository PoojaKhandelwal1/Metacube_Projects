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
 * Page: NewAttributeSLDS
 * Description : this class used to create and update attributes
 * Created by: Rekha @12 April 2017
 */
public with sharing class NewAttributeControllerSLDS extends RefEdgeEditionFeatures {
	
    /**
     * Properties and variables
     */
	public String attId { get; set; }
	public String parentId { get; set; }
	public String nameSpace {
		get {
			return UtilityController.appNamespace();
		}
		private set;
	}
	
	/**
     * Constructor
     */
    public NewAttributeControllerSLDS(ApexPages.StandardController controller) {
    	Attribute__c att = (Attribute__c)controller.getRecord();
    	parentId = (ApexPages.currentPage().getParameters().get('retURL') != null ? ApexPages.currentPage().getParameters().get('retURL') : '');
    	if (att.Id != null) {
    		attId = att.Id;
		// to fix issue #842
    	} else if (att.Parent__c != null) {
    		parentId = att.Parent__c;
    	} else if (parentId != null && parentId != '') {
    		parentId = parentId.substringAfterLast('/');
    	}
    }
    
    /**
     * RemoteAction to get all intial information
     */
    @RemoteAction
    public static AttributeWrapper fetchInfo(String attId, String parentId) {
    	AttributeWrapper attWp = new AttributeWrapper();
    	
    	//in edit case
        if (attId != null && attId != '') {
            List<Attribute__c> atts = [SELECT Parent__c, Parent__r.Name, Name, Inheritable__c, ParentIds__c, Id, Attribute_Mapping__c, 
            							Parent__r.Attribute_Mapping__c, Ref_Limit_to_Acct_or_Cntct__c
            							FROM Attribute__c WHERE Id = :attId LIMIT 1];
            
            if (atts.size() > 0) {
	            attWp.parentId = atts[0].Parent__c;
	            attWp.parentIdOld = atts[0].Parent__c;
	            attWp.attName = atts[0].Name;
	            attWp.isInheritableOld = atts[0].Inheritable__c;
	            attWp.isInheritableNew = atts[0].Inheritable__c;
	            attWp.ischanged = true;
	            attWp.attId = atts[0].Id;
	            attWp.parentName = atts[0].Parent__r.Name;
	            
	            if (atts[0].Ref_Limit_to_Acct_or_Cntct__c != null) {
	            	attWp.limitToAccCon = atts[0].Ref_Limit_to_Acct_or_Cntct__c;
	            }
	            
	            if (atts[0].Attribute_Mapping__c != null) {
	            	attWp.isMapped = true;
	            }
            }
        //in new attribute case
        } else {
            
            if (parentId != null && parentId != '') {
				//fix for #827
                List<Attribute__c> atts = [SELECT Name FROM Attribute__c WHERE Id = :parentId LIMIT 1];
            
	            if (atts.size() > 0) {
					attWp.parentId = parentId;
	                attWp.parentName = atts[0].Name;
	            } 
            }
        }
        return attWp;
    }
    
    /**
     * RemoteAction to save attributes
     */
    @RemoteAction
    public static String saveAttributes(String infoWpJSON) {
    	Savepoint sp = Database.setSavepoint();
    	
        try {
        	AttributeWrapper infoWp = (AttributeWrapper)JSON.deserialize(infoWpJSON, AttributeWrapper.class);
        	
        	//check permission for CRUD FLS
        	if (checkPermissions(infoWp.attId != null && infoWp.attId != '')) {
	        	Attribute__c att = new Attribute__c();
	        	
	        	if (infoWp.attId != null && infoWp.attId != '') {
	        		List<Attribute__c> atts = [SELECT Id FROM Attribute__c WHERE Id = :infoWp.attId LIMIT 1];
            		
            		if (atts.size() > 0) {
            			att = atts[0];
            		}
	        	}
	        	
	        	att.Name = infoWp.attName;
	        	att.Inheritable__c = infoWp.isInheritableNew;
	        	//to hide limit account contact field for child attribute #570
	        	att.Ref_Limit_to_Acct_or_Cntct__c = (infoWp.parentId != null && infoWp.parentId != '' ? null : infoWp.limitToAccCon);
	        	//changes related to #839
	        	att.Parent__c = (infoWp.parentId != '' ? infoWp.parentId : null);
	        	
	        	upsert att;
		        
		        //check for inheritable change, in case of change inheritance notification is needed.
	            if (infoWp.ischanged && infoWp.isInheritableOld != att.Inheritable__c && att.parent__c == null && att.Id != null) {
	            	
	            	if (!att.Inheritable__c || (att.Inheritable__c && infoWp.isAddDeleteAttributes)) {
	            		changeInheritance(att, infoWp.isAddDeleteAttributes, '');
	            	}
	            //check for parent change, in case of change inheritance notification is needed.
	            } else if (infoWp.ischanged && infoWp.parentIdOld != att.parent__c && att.Id != null) {
	            	List<Attribute__c> attr = [SELECT Parent__c, Name, Inheritable__c, ParentIds__c, Level__c, Id, Attribute_Mapping__c
	            							FROM Attribute__c WHERE Id = :att.parent__c LIMIT 1];
	            	
	            	if (attr.size() > 0) {
	            		
	            		//if attribute is made the root attribute
		            	if (attr[0].Level__c == 0) {
		            		changeInheritance(attr[0], true, att.Id);
		            	//if parent is changed
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
	            //changes related to #838
	            return 'success:'+att.Id;
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        } catch (Exception e) {
            database.rollback(sp);
            return 'Error: ' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
        return '';
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage(Boolean isUpdate) {
		checkPermissions(isUpdate);
    	
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * Method to check Permissions
     */
    private static Boolean checkPermissions(Boolean isUpdate) {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Attribute__c',
    										new Set<String>{'Name', UtilityController.appNamespace() + 'Inheritable__c',
    											UtilityController.appNamespace() + 'Parent__c'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, !isUpdate, isUpdate);
        return isUpsertPermission;
    }
    
    /**
     * Method to run batch for change in inheritance
     */
    private static void changeInheritance(Attribute__c attr, Boolean answer, String attId) {
    	ConstantsController.attributeId = attId;
    	Batch_ChangeAttributeInheritance newBatch = new Batch_ChangeAttributeInheritance(attr, answer);
        DataBase.executeBatch(newBatch);
    }
    
    /**
     * Remote Action Method to get Limit to Account Contact picklist values
     */
    @RemoteAction
    public static List<String> getPickList() {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult dfr = Schema.sObjectType.Attribute__c.fields.getMap().get(UtilityController.appNamespace() 
																							+ 'Ref_Limit_to_Acct_or_Cntct__c').getDescribe();
        List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
        
        for (Schema.PicklistEntry fieldValue : ple) {
            options.add(String.valueOf(fieldValue.value));
        }
        return options;
    }
    
    /**
     * Wrapper class for all information
     */
 	public class AttributeWrapper {
 		public Boolean isMapped { get; set; }
 		public Boolean isInheritableNew { get; set; }
 		public Boolean isInheritableOld { get; set; }
 		public Boolean isAddDeleteAttributes { get; set; }
 		public Boolean ischanged { get; set; }
 		public String attName { get; set; }
 		public String attId { get; set; }
 		public String parentId { get; set; }
 		public String parentName { get; set; }
 		public String parentIdOld { get; set; }
 		public String limitToAccCon { get; set; }
 		
 	    public AttributeWrapper() {
	    	isMapped = false;
            isInheritableNew = false;
            isInheritableOld = false;
            ischanged = false;
            isAddDeleteAttributes = false;
            attName = '';
            attId = '';
            parentId = '';
            parentIdOld = '';
            parentName = '';
            limitToAccCon = '';
	    }
 	}
}