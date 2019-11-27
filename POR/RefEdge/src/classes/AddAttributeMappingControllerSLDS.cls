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
 * Page: AddAttributeMappingSLDS
 * Description : this class used to create and update attribute mappings
 * Created by: Rekha @17 August 2017
 */
public with sharing class AddAttributeMappingControllerSLDS extends RefEdgeEditionFeatures {
    
    
    /**
     * Properties and variables
     */
	public String attMapId { get; set; }
	public String parentId { get; set; }
	public String sfBaseUrl { get; set; }
	public String nameSpace {
		get {
			return UtilityController.appNamespace();
		}
		private set;
	}
    public Boolean isSLDS { get; set; }

	/**
     * Constructor
     */
    public AddAttributeMappingControllerSLDS(ApexPages.StandardController controller) {

        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t' || UserInfo.getUiTheme() == 'Theme4u') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        sfBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        Attribute_Mapping__c attributeMapping = (Attribute_Mapping__c)controller.getRecord();
    	parentId = (ApexPages.currentPage().getParameters().get('retURL') != null ? ApexPages.currentPage().getParameters().get('retURL') : '');
    	attMapId = attributeMapping.Id;
    }
    
    /**
     * Remote Action Method to get Attribute mapping
     */
    @RemoteAction
    public static InfoWrapper getAttributeMappingRecord(String attMapId) {
    	
    	List<Attribute_Mapping__c> attributeMappings = [SELECT Id, Name, Object__c, Is_Related_Mapping__c,
	            					Inheritable__c, Auto_add__c, Attribute_Name__c, Filter_Label_Name__c, Field__c,
                                    Field_Api_Name__c, Auto_update__c, Auto_populate__c, Auto_delete__c
	                				FROM Attribute_Mapping__c WHERE Id = :attMapId];

        if (attributeMappings.size() > 0) {
        	return new InfoWrapper(attributeMappings[0]);
        }
        return new InfoWrapper(new Attribute_Mapping__c());
    }

    /**
     * Remote Action Method to get Objects names
     */
    @RemoteAction
    public static String getObjects() {
        Map<String, List<OptionWrapper>> optionMap = new Map<String, List<OptionWrapper>>();
        optionMap.put('default', new List<OptionWrapper>());
        optionMap.put('object', new List<OptionWrapper>());
        optionMap.get('default').add(new OptionWrapper(ConstantsController.ACCOUNT, ConstantsController.ACCOUNT));
        optionMap.get('default').add(new OptionWrapper(ConstantsController.CONTACT, ConstantsController.CONTACT));
        optionMap.get('default').add(new OptionWrapper(ConstantsController.OPPORTUNITY, ConstantsController.OPPORTUNITY));
        optionMap.get('default').add(new OptionWrapper(ConstantsController.REFERENCE_CONTENT, ConstantsController.REFERENCE_CONTENT));
        optionMap.get('default').add(new OptionWrapper(ConstantsController.REFERENCE_PROFILE, ConstantsController.REFERENCE_PROFILE));

        for (Schema.SObjectType obj : CRUDAndFLSCheckController.sObjectsMap.values()) {
            Schema.DescribeSObjectResult objDesc = obj.getDescribe();
            optionMap.get('object').add(new OptionWrapper(objDesc.getName(), objDesc.getLabel()));
        }
        optionMap.get('object').sort();
        return JSON.serialize(optionMap);
    }

    /**
     * Remote Action Method to get fields for an object
     */
    @RemoteAction
    public static FieldValuesWrapper getFields(String objectName) {
    	FieldValuesWrapper returnFields = new FieldValuesWrapper();
    	
        if (objectName == ConstantsController.ACCOUNT) {
            returnFields = getPicklistFields('Account', false);
        } else if (objectName == ConstantsController.CONTACT) {
            returnFields = getPicklistFields('Contact', false);
        } else if (objectName == ConstantsController.OPPORTUNITY) {
            returnFields = getPicklistFields('Opportunity', true);
        } else if (objectName == ConstantsController.REFERENCE_CONTENT) {
            returnFields = getPicklistFields(UtilityController.appNamespace() + 'Reference_Content__c', false);
        } else if (objectName == ConstantsController.REFERENCE_PROFILE) {
            returnFields = getPicklistFields(UtilityController.appNamespace() + 'Reference_Basic_Information__c', false);
        }
        return returnFields;
    }
    
    
    /**
     * Get generic Picklist Fields
     */
    private static FieldValuesWrapper getPicklistFields(String obj, Boolean isOppSelected) {
    	FieldValuesWrapper info = new FieldValuesWrapper();
        info.lookUpFieldOptions = new List<OptionWrapper>();
        info.relatedListOptions = new List<OptionWrapper>();
        info.fieldOptions = new Map<String, String>();
        //isoppRelatedListSelected = false;
        info.relationShipNameObjectNameMap = new Map<String, String>();
        info.relationShipNameFieldName = new Map<String, String>();
        Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType objType = gd.get(obj);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        if (isOppSelected) {
            
            for (Schema.Childrelationship relatedObject : objDescribe.getChildRelationships()) {
                
                if (relatedObject.getRelationshipName() != null && relatedObject.getRelationshipName() == 'OpportunityLineItems') {
                    info.relatedListOptions.add(new OptionWrapper(relatedObject.getRelationshipName(), relatedObject.getChildSObject().getDescribe().getLabel()));
                    info.relationShipNameObjectNameMap.put(relatedObject.getRelationshipName(), relatedObject.getChildSObject().getDescribe().getName());
                    info.relationShipNameFieldName.put(relatedObject.getRelationshipName(), relatedObject.getField().getDescribe().getName());
                }
            }
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
            for (String fieldName : fieldMap.keyset()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                
                if ((fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) 
                			&& fieldDesc.getName() != 'ForecastCategoryName') {
                    info.fieldOptions.put(fieldDesc.getName(), fieldDesc.getLabel());
                }
            }
        } else {
            
            //if Reference profile is selected related #639
            if (obj == UtilityController.appNamespace() + 'Reference_Basic_Information__c') {
	            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
	            
	            for (String fieldName : fieldMap.keyset()) {
	                Schema.SObjectField field = fieldMap.get(fieldName);
	                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
	                
	                if (fieldDesc.getType() == Schema.DisplayType.Reference) {
	                    
	                    if (fieldDesc.isCreateable()) {
	                       	
	                        for (Schema.sObjectType sObj : fieldDesc.getReferenceTo()) {
	                        	
	                        	if (sObj.getDescribe().getName() == 'Account' || sObj.getDescribe().getName() == 'Contact') {
			                        info.lookUpFieldOptions.add(new OptionWrapper(fieldDesc.getName(), fieldDesc.getLabel()));	                        		
		                            info.relationShipNameObjectNameMap.put(fieldDesc.getName(), sObj.getDescribe().getName());
	                        	}
	                        }
	                    }
	                }
	            }
            } else {
            	
	            for (Schema.Childrelationship relatedObject : objDescribe.getChildRelationships()) {
	                
	                //to prevent account contact to be in lookup and related related #639
	                if (relatedObject.getRelationshipName() != null && relatedObject.getChildSObject().getDescribe().getName() != 'Account' 
	                										&& relatedObject.getChildSObject().getDescribe().getName() != 'Contact') {
	                    info.relatedListOptions.add(new OptionWrapper(relatedObject.getRelationshipName(), relatedObject.getChildSObject().getDescribe().getLabel()));
	                    info.relationShipNameObjectNameMap.put(relatedObject.getRelationshipName(), relatedObject.getChildSObject().getDescribe().getName());
	                	info.relationShipNameFieldName.put(relatedObject.getRelationshipName(), relatedObject.getField().getDescribe().getName());
	                }
	            }
	            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
	            
	            for (String fieldName : fieldMap.keyset()) {
	                Schema.SObjectField field = fieldMap.get(fieldName);
	                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
	                
	                if (fieldDesc.getType() == Schema.DisplayType.Reference) {
	                    
	                    if (fieldDesc.isCreateable()) {
	                       	Boolean isAccountContact = false;
	                       	
	                        for (Schema.sObjectType sObj : fieldDesc.getReferenceTo()) {
	                        	
	                        	//to prevent account contact to be in lookup and related list related #639
	                        	if (sObj.getDescribe().getName() == 'Account' || sObj.getDescribe().getName() == 'Contact') {
	                        		isAccountContact = true;
	                        	} else {
	                            	info.relationShipNameObjectNameMap.put(fieldDesc.getName(), sObj.getDescribe().getName());
	                        	}
	                        }
	                        
	                        //to prevent account contact to be in lookup and related related #639
	                        if (!isAccountContact) {
	                        	info.lookUpFieldOptions.add(new OptionWrapper(fieldDesc.getName(), fieldDesc.getLabel()));
	                        }
	                    }
	                }
	                
	                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
	                    info.fieldOptions.put(fieldDesc.getName(), fieldDesc.getLabel());
	                }
	            }
            }
        }
        return info;
    }
    
    
    /**
     * Method to get all fields of lookup object
     */
    @RemoteAction
    public static Map<String, String> lookupSelected(String selectedFieldValue) {
    	Map<String, String> relatedFieldsOptions = new Map<String, String>();
        Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType objType = gd.get(selectedFieldValue);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        for (String fieldName : fieldMap.keyset()) {
            Schema.SObjectField field = fieldMap.get(fieldName);
            Schema.DescribeFieldResult fieldDesc = field.getDescribe();
            Schema.DisplayType fielddataType = fieldDesc.getType();
           
            if (fieldDesc.isCreateable() && (fielddataType == Schema.DisplayType.String || fielddataType == Schema.DisplayType.Email || 
                	fielddataType == Schema.DisplayType.Phone || fielddataType == Schema.DisplayType.Picklist || fielddataType == Schema.DisplayType.MultiPicklist || 
                	fielddataType == Schema.DisplayType.URL)) {
                relatedFieldsOptions.put(fieldDesc.getName(), fieldDesc.getLabel());
            }
        }
        return relatedFieldsOptions;
    }
    
    /**
     * Method to get all fields of relatedlist object
     */
    @RemoteAction
    public static Map<String, String> relatedListSelected(String selectedFieldValue, Boolean isOppSelected, String lineItem) {
    	Map<String, String> relatedFieldsOptions = new Map<String, String>();
       	Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType objType = gd.get(selectedFieldValue);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        
        if (isOppSelected && lineItem == 'OpportunityLineItems') {
            
            for (String fieldName : fieldMap.keyset()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                Schema.DisplayType fielddataType = fieldDesc.getType();
               
                if (fieldDesc.isCreateable() && (fielddataType == Schema.DisplayType.Picklist 
                			|| fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST)) {
                    relatedFieldsOptions.put(fieldDesc.getName(), fieldDesc.getLabel());
                }
            }
            relatedFieldsOptions.put('Product2', 'Product');
        } else {
        	                
            for (String fieldName : fieldMap.keyset()) {
                Schema.SObjectField field = fieldMap.get(fieldName);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                Schema.DisplayType fielddataType = fieldDesc.getType();
                
                if (fieldDesc.isCreateable() && (fielddataType == Schema.DisplayType.String || fielddataType == Schema.DisplayType.Email 
                		|| fielddataType == Schema.DisplayType.Phone || fielddataType == Schema.DisplayType.Picklist 
                		|| fielddataType == Schema.DisplayType.MultiPicklist 
                		|| fielddataType == Schema.DisplayType.URL)) {
                    relatedFieldsOptions.put(fieldDesc.getName(), fieldDesc.getLabel());
                }
            }
        }
        
        return relatedFieldsOptions;
    }
    
    
    /**
     * Remote Action Method to save attributeMapping
     */
    @RemoteAction
    public static String saveMapping(String infoJSON, String dataJSON, String selectedMappingType, String filtersJson) {
        SavePoint sp = Database.setSavepoint();
        
        try {
        	InfoWrapper info = (InfoWrapper)JSON.deserialize(infoJSON, InfoWrapper.class);
        	FieldValuesWrapper allFieldValues = (FieldValuesWrapper)JSON.deserialize(dataJSON, FieldValuesWrapper.class);
        	List<ListViewFiltersController.FilterWrapper> filtersList = (List<ListViewFiltersController.FilterWrapper>)JSON.deserialize(filtersJson, List<ListViewFiltersController.FilterWrapper>.class);
        	//check permission for CRUD FLS
        	if (checkPermissions(info.id != null && info.id != '')) {
        		Attribute_Mapping__c attMap = new Attribute_Mapping__c();
        		
        		if ((info.id == null || info.id == '') && selectedMappingType == 'default') {
        			attMap.Field__c = info.fieldName;
			        attMap.Field_Api_Name__c = info.fieldApiName;
			        attMap.Object__c = info.selectedObject;
			        attMap.Filter_Label_Name__c = info.filterName; 
			        attMap.Attribute_Name__c = info.attName;
			        
			        if (info.isRelatedMapping && allFieldValues.relationShipNameObjectNameMap != null) {
			        	attMap.Is_Related_Mapping__c = info.isRelatedMapping;
			        	
			        	if (info.selectedRelatedField != null && info.selectedRelatedField != '' && allFieldValues.relationShipNameObjectNameMap.containsKey(info.selectedRelatedField)) {
			        		attMap.Mapping_Type__c = 'Child Object';
			        		attMap.Related_Object__c = allFieldValues.relationShipNameObjectNameMap.get(info.selectedRelatedField);
			        		attMap.Child_RelationShipName__c = info.selectedRelatedField;
	                		attMap.RelationShip_Name__c = allFieldValues.relationShipNameFieldName.get(info.selectedRelatedField);
			        	} else if (info.selectedLookupField != null && info.selectedLookupField != '' && allFieldValues.relationShipNameObjectNameMap.containsKey(info.selectedLookupField)) {
			        		attMap.Mapping_Type__c = 'Parent Object';
			        		attMap.Related_Object__c = allFieldValues.relationShipNameObjectNameMap.get(info.selectedLookupField);
			        		attMap.RelationShip_Name__c = info.selectedLookupField;
			        	}
			        	Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
		                Schema.SObjectType objType = gd.get(attMap.Related_Object__c);
		                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
		                Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
		                
		                for (String fieldName : fieldMap.keyset()) {
		                    Schema.SObjectField field = fieldMap.get(fieldName);
		                    Schema.DescribeFieldResult fieldDesc = field.getDescribe();
		                    Schema.DisplayType fielddataType = fieldDesc.getType();
		                    
		                    if (fieldDesc.getName() == attMap.Field_Api_Name__c && (fielddataType == Schema.DisplayType.MultiPicklist)) {
		                        attMap.Is_Related_MultiSelectPicklist__c = true;
		                    }
		                }
			        }
        		} else if (info.id != null && info.id != '' && selectedMappingType == 'default') {
        			attMap.Id = info.id;
        		} else if (selectedMappingType != 'default') {
                    Boolean isDuplicate = false;
                    List<ListViewFiltersController.FilterWrapper> newFilters
                        = (List<ListViewFiltersController.FilterWrapper>)JSON.deserialize(filtersJson, List<ListViewFiltersController.FilterWrapper>.class);
                    String selectedObjectName = '%' + info.selectedObject;
		            selectedObjectName = String.escapeSingleQuotes(selectedObjectName);
		            selectedObjectName = '\'' + selectedObjectName + '\'';
		            String userMappingQuery = 'SELECT Id, Label__c, Default_Value__c, Field_API_Name__c '
                                            + 'FROM User_Mapping__c '
                                            + 'WHERE Process__c = \'AttMappingFilters\' '
                                            + 'AND Field_API_Name__c LIKE ' + selectedObjectName;
                    Map<String, List<User_Mapping__c>> existingMappingFiltersMap = new Map<String, List<User_Mapping__c>>();

                    for (User_Mapping__c um : Database.query(userMappingQuery)) {

                        if (!existingMappingFiltersMap.containsKey(um.Label__c)) {
                            existingMappingFiltersMap.put(um.Label__c, new List<User_Mapping__c>());
                        }
                        existingMappingFiltersMap.get(um.Label__c).add(um);
                    }
                    Integer matchingFiltersCount = 0;

                    for (String attMappingId : existingMappingFiltersMap.keySet()) {
                        matchingFiltersCount = 0;

                        for (User_Mapping__c oldFilter : existingMappingFiltersMap.get(attMappingId)) {

                            for (ListViewFiltersController.FilterWrapper newFilter : newFilters) {
                                String fieldApiName = oldFilter.Field_API_Name__c.split('::')[0];
                                String operator = oldFilter.Field_API_Name__c.split('::')[3];
                                String fieldValue = oldFilter.Default_Value__c;

                                if (fieldApiName == newFilter.fieldApiName
                                        && operator == newFilter.operator
                                        && fieldValue == newFilter.fieldValue) {
                                    matchingFiltersCount += 1;
                                }
                            }
                        }

                        if (newFilters.size() == existingMappingFiltersMap.get(attMappingId).size()
                                && matchingFiltersCount == newFilters.size()) {
                            isDuplicate = true;
                            break;
                        }
                    }

                    if (isDuplicate) {
                        return System.Label.Duplicate_Object_Mapping_Error;
                    } else {
                        attMap.Object__c = info.selectedObject;
                        attMap.Filter_Label_Name__c = info.filterName; 
                        attMap.Attribute_Name__c = info.attName;
                        attMap.Field__c = 'Name';
                    }
                }

                if (info.id != null || info.id != '') {
                    attMap.Id = info.id;
                }
		        attMap.Auto_populate__c = info.autoPopulate; 
		        attMap.Auto_add__c = info.autoAdd; 
		        attMap.Auto_delete__c = info.autoDelete; 
		        attMap.Auto_update__c = info.autoUpdate;
		        attMap.Inheritable__c = info.isInheritable;
	            upsert attMap;

                if (filtersList != null && filtersList.size() > 0) {
                    String saveFiltersResult
                        = ListViewFiltersController.saveUserMappings(false, filtersJson, '', attMap.Id, 'AttMappingFilters', attMap.Object__c);

                    if (saveFiltersResult != 'success') {
                        return saveFiltersResult;
                    }
                }

                if (selectedMappingType != 'default') {
                    Database.executeBatch(new Batch_SyncTaxonomyAttributes());
                }
        		return 'success:' + attMap.Id;
        	} else {
        		return CRUDAndFLSCheckController.getErrorMsg();
        	}
        } catch(Exception e) {
        	Database.rollback(sp);
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
        fieldMap.put(UtilityController.appNamespace() + 'Attribute_Mapping__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Mapping_Type__c',
        										UtilityController.appNamespace() + 'Is_Related_Mapping__c',
        										UtilityController.appNamespace() + 'Child_RelationShipName__c',
        										UtilityController.appNamespace() + 'Filter_Label_Name__c',
        										UtilityController.appNamespace() + 'Field_Api_Name__c',
        										UtilityController.appNamespace() + 'Inheritable__c',
        										UtilityController.appNamespace() + 'Auto_add__c',
        										UtilityController.appNamespace() + 'Auto_delete__c',
        										UtilityController.appNamespace() + 'Auto_populate__c',
        										UtilityController.appNamespace() + 'Auto_update__c',
        										UtilityController.appNamespace() + 'Attribute_Name__c',
        										UtilityController.appNamespace() + 'Field__c',
        										UtilityController.appNamespace() + 'Object__c',
        										UtilityController.appNamespace() + 'Is_Related_MultiSelectPicklist__c',
        										UtilityController.appNamespace() + 'RelationShip_Name__c',
        										UtilityController.appNamespace() + 'Related_Object__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, !isUpdate, isUpdate);
    }
    
    /**
     * Wrapper class
     */
    public class FieldValuesWrapper {
    	public Map<String, String> fieldOptions;
    	public List<OptionWrapper> lookUpFieldOptions;
    	List<OptionWrapper> relatedListOptions;
    	Map<String, String> relationShipNameObjectNameMap;
    	Map<String, String> relationShipNameFieldName;
    }
    
    /**
     * Wrapper class
     */
 	public class OptionWrapper implements Comparable {
 		public String name { get; set; }
 		public String id { get; set; }
 		
 	    public OptionWrapper(String id, String name) {
            this.name = name;
            this.id = id;
	    }

        public Integer compareTo(Object compareTo) {
            OptionWrapper option = (OptionWrapper)compareTo;
            if (name == option.name) return 0;
            if (name > option.name) return 1;
            return -1;
        }
 	}
 	
 	/**
     * Wrapper class for all information
     */
 	public class InfoWrapper {
 		public String selectedObject { get; set; }
 		public String selectedField { get; set; }
 		public String selectedLookupField { get; set; }
 		public String selectedRelatedField { get; set; }
 		public String filterName { get; set; }
 		public String attName { get; set; }
 		public Boolean autoPopulate { get; set; }
 		public Boolean autoAdd { get; set; }
 		public Boolean autoDelete { get; set; }
 		public Boolean autoUpdate { get; set; }
 		public Boolean isInheritable { get; set; }
 		public String selectedMapField { get; set; }
 		public String fieldApiName { get; set; }
 		public String fieldName { get; set; }
 		public Boolean isRelatedMapping { get; set; }
 		public String name { get; set; }
 		public String id { get; set; }
 		
 		public InfoWrapper(Attribute_Mapping__c attMap) {
	 		selectedObject = attMap.Object__c;
	        filterName = attMap.Filter_Label_Name__c; 
	        attName = attMap.Attribute_Name__c;
	        autoPopulate = attMap.Auto_populate__c; 
	        autoAdd = attMap.Auto_add__c; 
	        autoDelete = attMap.Auto_delete__c; 
	        autoUpdate = attMap.Auto_update__c;
	        isInheritable = attMap.Inheritable__c;
	        fieldName = attMap.Field__c;
	        id = attMap.Id;
	        name = attMap.Name;
	        isRelatedMapping = attMap.Is_Related_Mapping__c;
	        selectedMapField = attMap.Field_Api_Name__c;
 		}
 	}
}