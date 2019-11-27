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
 * Page: RequestSettingMatrix, ReferenceContentTypeSettingMatrix
 * Description : Class used to manage Reference Request mappings.
 * Modified by: Rekha @Feb 8 2017
 */
public with sharing class RequestSettingMatrixController extends RefEdgeEditionFeatures {
    /**
     * Properties AND variables
     */
    public Map<String, Reference_Request_Field__c> fieldMap { get; set; }
    public List<Referenceability_Type__c> referenceTypes { get; set; }
    public Map<Id, String> refTypeWrapperList { get; set; }
    public List<Label__c> labelList { get; set; }
    public Boolean isEdit { get; set; }
    public Map<String, Reference_Type_Mapping__c> matrixMap { get; set; }
    public List<String> dummyList { get; set; }
    public Custom_Settings__c customSetting { get; set; }
    public List<Reference_Content_Type__c> refContentTypes { get; set; }
    public Map<String,String> contentFieldsMap { get; set; }
    public String  isContentSetting { get; set; }
    public Boolean recordsPresent { get; set; }
    public Set<String> setMatrixId { get; set; }
    public Map<String, Schema.SObjectField> fldObjMap;
    private String customId;
    private List<Reference_Type_Mapping__c> deleteUnwantedMappingsList;
    private List<Reference_Type_Mapping__c> mappingList;
    public Map<String,Boolean> contentRequiredFieldsMap  { get; set; }
    public Map<String,Boolean> infoRequiredFieldsMap  { get; set; }
    
    public List<SelectOption> ReferenceTypesPicklist {
    	get {
    		ReferenceTypesPicklist = new List<SelectOption>();
            
            for(Referenceability_Type__c referenceType : referenceTypes) {
                ReferenceTypesPicklist.add(new SelectOption(referenceType.Id, referenceType.Name));
            }
            return ReferenceTypesPicklist;
        }
        set;
    }
    
    public Id SelectedReferenceTypeId {get; set;}
    
    public List<Referenceability_Type__c> SelectedReferenceTypesList {
    	get {
	        SelectedReferenceTypesList = setSelectedReferenceTypeList();
            return SelectedReferenceTypesList;
        }
        set;
    }        
    
    public void passSelectedReferenceTypeToController() {
	    SelectedReferenceTypesList = setSelectedReferenceTypeList();
	}
	
	private List<Referenceability_Type__c> setSelectedReferenceTypeList() {
		List<Referenceability_Type__c> selectedRefTypesList = new List<Referenceability_Type__c>();
        for(Referenceability_Type__c referenceType : referenceTypes) {
        	if(referenceType.Id == SelectedReferenceTypeId) {
        		selectedRefTypesList.add(referenceType);
        		break;
        	}
        }
        return selectedRefTypesList;
	}
	
	public List<SelectOption> ReferenceContentTypesPicklist {
    	get {
    		ReferenceContentTypesPicklist = new List<SelectOption>();
            
            for(Reference_Content_Type__c referenceContentType : refContentTypes) {
                ReferenceContentTypesPicklist.add(new SelectOption(referenceContentType.Id, referenceContentType.Name__c));
            }
            return ReferenceContentTypesPicklist;
        }
        set;
    }
    
    public Id SelectedReferenceContentTypeId {get; set;}
    
    public List<Reference_Content_Type__c> SelectedReferenceContentTypesList {
    	get {
	        SelectedReferenceContentTypesList = setSelectedReferenceContentTypeList();
            return SelectedReferenceContentTypesList;
        }
        set;
    }        
    
    public void passSelectedReferenceContentTypeToController() {
	    SelectedReferenceContentTypesList = setSelectedReferenceContentTypeList();
	}
	
	private List<Reference_Content_Type__c> setSelectedReferenceContentTypeList() {
		List<Reference_Content_Type__c> selectedRefContentTypesList = new List<Reference_Content_Type__c>();
        for(Reference_Content_Type__c referenceContentType : refContentTypes) {
        	if(referenceContentType.Id == SelectedReferenceContentTypeId) {
        		selectedRefContentTypesList.add(referenceContentType);
        		break;
        	}
        }
        return selectedRefContentTypesList;
	}
    
    /**
     * Constructor
     */
    public RequestSettingMatrixController() {
        isEdit = false;
        refTypeWrapperList = new Map<Id, String>();
        contentRequiredFieldsMap = new Map<String, Boolean>();
        infoRequiredFieldsMap = new Map<String, Boolean>(); 
        customId = apexPages.currentPage().getParameters().get('customSettingId');
        isContentSetting = apexPages.currentPage().getParameters().get('isContentSetting');
        customSetting = [SELECT General_Notes__c, Id FROM Custom_Settings__c LIMIT :limits.getLimitQueryRows()][0];
        dummyList = new List<String> { 'Request Specific Notes' };
        referenceTypes = new List<Referenceability_Type__c>();
        refContentTypes = new List<Reference_Content_Type__c>();
        labelList = new List<Label__c>();
        Set<Id> labelIds = new Set<Id>();
        mappingList = new List<Reference_Type_Mapping__c>();
        
        for (Label__c label : [SELECT Id, Name, (SELECT Id FROM Attributes_Labels__r LIMIT 1) FROM Label__c 
                                ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                                    
            if (!labelIds.contains(label.Id) && label.Attributes_Labels__r.size() > 0) {
                labelList.add(label);
                labelIds.add(label.Id);
            }
        }
        
        if (isContentSetting == 'false') {
            methodForReferenceFields();
        } else if (isContentSetting == 'true') {
            methodForContentFields();
        }
        
        SelectedReferenceTypeId = (referenceTypes.size() > 0) ? referenceTypes[0].Id : null;
        SelectedReferenceContentTypeId = (refContentTypes.size() > 0) ? refContentTypes[0].Id : null;
    }
    
    /**
     * Method to manage Reference fields
     */
    private void methodForReferenceFields() {
      
        if (checkPermissions()) {
            
            mappingList = new List<Reference_Type_Mapping__c>();
            recordsPresent = false;
            deleteUnwantedMappingsList = new List<Reference_Type_Mapping__c >();
            referenceTypes = [SELECT Name, Note__c FROM Referenceability_Type__c WHERE Visible__c = true AND Sales_Reward__c = false 
                                        ORDER BY Name LIMIT :limits.getLimitQueryRows()]; //re #344
            fieldMap = new Map<String, Reference_Request_Field__c>();
            Map<String, Schema.SObjectField> fldObjMap = new Map<String, Schema.SObjectField>();
            
            for (Reference_Request_Field__c field : [SELECT Name, Order__c, Field_API_Name__c FROM Reference_Request_Field__c 
                                                            ORDER BY Order__c LIMIT :limits.getLimitQueryRows()]) {
                fieldMap.put(field.Field_API_Name__c, field); 
                recordsPresent = true;
            }
            fldObjMap = schema.SObjectType.Reference_Request_Additional_Info__c.fields.getMap();
           
            for (String str : fldObjMap.keyset()) {
                Schema.DescribeFieldResult dfr = fldObjMap.get(str).getDescribe();

                if (dfr.isCreateable() && dfr.isCustom()) {  

                    // REF-1798 Creating map for contnet required field values
                    if (!infoRequiredFieldsMap.containsKey(dfr.getName())) {
                        infoRequiredFieldsMap.put(dfr.getName(), String.valueOf(dfr.getType()) == 'BOOLEAN' ? false : !dfr.isNillable());
                    } 
                }
            } 

            if (referenceTypes.size() > 0) {
                recordsPresent = true;
            }
            
            if (labelList.size() > 0) {
                recordsPresent = true;
            }
            mappingList = [SELECT Id, Name, Referenceability_Type__c, Label__c, Label__r.Id, Visible__c, Required__c, Order__c
                                                FROM Reference_Type_Mapping__c WHERE Referenceability_Type__c IN :referenceTypes];
            matrixMap = new Map<String, Reference_Type_Mapping__c>();
           
            for (Reference_Type_Mapping__c ref : mappingList) {
                // re REF-1697 -If Reference Content Type Field is field level required then it should be visible/requied on the form.
                if (infoRequiredFieldsMap.containsKey(ref.Name.trim()) 
                                            && infoRequiredFieldsMap.get(ref.Name.trim()) == true) {                    
                    ref.Required__c = true;
                    ref.Visible__c = true; 
                } 

                if (fieldMap.containsKey(ref.Name.trim())) {
                    matrixMap.put(fieldMap.get(ref.Name).Field_API_Name__c + '' + ref.Referenceability_Type__c, ref);
                } else if (ref.label__c != null) {
                    matrixMap.put(ref.label__r.Id + '' + ref.Referenceability_Type__c, ref);
                } else{
                    deleteUnwantedMappingsList.add(ref); 
                }
            }  
            refTypeWrapperList.clear();
            
            for (Referenceability_Type__c ref : referenceTypes) {
            
                if(ref.Note__c != null) {
                    refTypeWrapperList.put(ref.Id, ref.Note__c);
                } else {
                    refTypeWrapperList.put(ref.Id, '    ');
                }
            } 
            
            for (String fieldName : fieldMap.keySet()) {
                
                for (Referenceability_Type__c ref : referenceTypes) {
                   
                    if (!matrixMap.containsKey(fieldMap.get(fieldName).Field_API_Name__c + '' + ref.Id)) {
                        Reference_Type_Mapping__c mappingObj = new Reference_Type_Mapping__c();
                         // re REF-1798 -If Reference Content Type Field is field level required then it should be visible/requied on the form.
                        if (infoRequiredFieldsMap.containsKey(fieldMap.get(fieldName).Field_API_Name__c) 
                                            && infoRequiredFieldsMap.get(fieldMap.get(fieldName).Field_API_Name__c) == true) { 
                            mappingObj.Required__c = true;
                            mappingObj.Visible__c = true; 
                        }
                        mappingObj.Name = fieldName;
                        mappingObj.Referenceability_Type__c = ref.Id;
                        matrixMap.put(fieldMap.get(fieldName).Field_API_Name__c + '' + ref.Id, mappingObj);
                    }
                }
            }
            
            for (Label__c label : labelList) {
                
                for (Referenceability_Type__c ref : referenceTypes) {
                    
                    if (!matrixMap.containsKey(label.Id + '' + ref.Id)) {
                        Reference_Type_Mapping__c mappingObj = new Reference_Type_Mapping__c();
                        mappingObj.Name = label.Name;
                        mappingObj.Label__c = label.Id;
                        mappingObj.Referenceability_Type__c = ref.Id;
                        matrixMap.put(label.Id + '' + ref.Id, mappingObj);
                    }
                }
            }
        }
    }
    
    /**
     * Method to manage Content type Fields
     */
    private void methodForContentFields() {
 
        if (checkPermissions()) {
            mappingList = new List<Reference_Type_Mapping__c>();
            deleteUnwantedMappingsList = new List<Reference_Type_Mapping__c>();
            fldObjMap = schema.SObjectType.Reference_Content_Type_Field__c.fields.getMap();
            refContentTypes = [SELECT Name__c, Id FROM Reference_Content_Type__c WHERE Recorded_Reference_Type__c = false 
                                        ORDER BY name__c LIMIT :limits.getLimitQueryRows()];
            contentFieldsMap = new Map<String,String>();
            recordsPresent = false; 
            
            for (String str : fldObjMap.keyset()) {
                 
                if (fldObjMap.get(str).getDescribe().isCreateable() && fldObjMap.get(str).getDescribe().isCustom() 
                            && fldObjMap.get(str).getDescribe().getName() != UtilityController.appNamespace() + 'Reference_Content__c') {
                    recordsPresent = true;
                    contentFieldsMap.put(fldObjMap.get(str).getDescribe().getName(), fldObjMap.get(str).getDescribe().getLabel());
                    
                    // REF-1697 Creating map for contnet required field values 
                    if (!contentRequiredFieldsMap.containsKey(fldObjMap.get(str).getDescribe().getName())) {
                        contentRequiredFieldsMap.put(fldObjMap.get(str).getDescribe().getName(),(!fldObjMap.get(str).getDescribe().isNillable()) ? true : false);
                    } 
                }
            } 
             
            if (refContentTypes.size() > 0) {
                recordsPresent = true;
            }
            mappingList = [SELECT Id, Name, Referenceability_Type__c, Label__c, Label__r.Id, Visible__c, Required__c, Reference_Content_Type__c, Order__c
                                FROM Reference_Type_Mapping__c WHERE Reference_Content_Type__c IN :refContentTypes];
            matrixMap = new Map<String, Reference_Type_Mapping__c>();  
            setMatrixId = new Set<String>();  

            for (Reference_Type_Mapping__c ref : mappingList) {
                 
                if (contentFieldsMap.containsKey(ref.Name.trim())) { 
                   
                    // re REF-1697 -If Reference Content Type Field is field level required then it should be visible/requied on the form.
                    if (contentRequiredFieldsMap.containsKey(ref.Name.trim()) 
                                                && contentRequiredFieldsMap.get(ref.Name.trim()) == true) {
                        
                        ref.Required__c = true;
                        ref.Visible__c = true; 
                    } 
                    matrixMap.put(ref.Name.trim() + '' + ref.Reference_Content_Type__c, ref);  
                    setMatrixId.add(ref.Name.trim());                   
                }  else {
                    deleteUnwantedMappingsList.add(ref);
                }
            }

            // re REF-1697 -If Reference Content Type Field is field level required then it should be visible/requied on the form.
            Reference_Type_Mapping__c objRm = new Reference_Type_Mapping__c();
             
            for (String rf :contentRequiredFieldsMap.keyset()) {
                
                for(Reference_Content_Type__c refCont : refContentTypes) {  
                    objRm = new Reference_Type_Mapping__c();
                
                    if (contentRequiredFieldsMap.get(rf.trim()) == true && !matrixMap.containsKey(rf.trim() + '' + refCont.Id)) {  
                        objRm.Required__c = true;
                        objRm.Visible__c = true;
                        objRm.Reference_Content_Type__c = refCont.Id;
                        objRm.Name = rf.trim();
                        matrixMap.put(rf.trim() + '' + objRm.Reference_Content_Type__c, objRm);
                    }

                }
            } 

            for (String fieldName : contentRequiredFieldsMap.keySet()) {
                 Reference_Type_Mapping__c rm = new Reference_Type_Mapping__c();
                 rm.Required__c = true;
                 rm.Visible__c = true; 
                 rm.Name = fieldName.trim();
            } 

            for (String fieldName : contentFieldsMap.keySet()) {
                
                for (Reference_Content_Type__c ref : refContentTypes) {
                    
                    if (!matrixMap.containsKey(fieldName + '' + ref.Id) ) {
                        Reference_Type_Mapping__c mappingObj = new Reference_Type_Mapping__c();
                        mappingObj.Name = fieldName;
                        mappingObj.Reference_Content_Type__c = ref.Id;
                        matrixMap.put(fieldName + '' + ref.Id, mappingObj);
                    }
                }
            }
        }
    }
    
    /**
     * Method to delete Mappings
     */
    public void deleteMappings() {
        
        if (checkPermissions()) {
            Savepoint sp = Database.setSavepoint();
            
            try {
                
                if (mappingList.size() > 0) {
                    
                    if (isContentSetting == 'false') {
                        List<Reference_Type_Mapping__c> deleteUnwantedMAppings = [SELECT Id FROM Reference_Type_Mapping__c 
                                                                WHERE Id NOT IN :mappingList AND Reference_Content_Type__c = null];
                        if (deleteUnwantedMAppings.size() > 0) {
                            delete deleteUnwantedMAppings;
                        }
                    } else if (isContentSetting == 'true') {
                        List<Reference_Type_Mapping__c> deleteUnwantedMAppings = [SELECT Id FROM Reference_Type_Mapping__c 
                                                                WHERE Id NOT IN :mappingList AND Referenceability_Type__c = null];
                        if (deleteUnwantedMAppings.size() > 0) {
                            delete deleteUnwantedMAppings;
                        }
                    }
                }
                
                if (deleteUnwantedMappingsList.size() > 0) {
                    delete deleteUnwantedMappingsList;
                }
            } catch (Exception e) {
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                Database.rollback(sp);
            }
        }
    } 
    
    /**
     * Method to save Mappings
     */
    public pageReference saveMatrix() { 
        
        if (checkPermissions()) {
            Savepoint sp = Database.setSavepoint();
            
            try {
                List<Reference_Type_Mapping__c> upsertMappingList = new List<Reference_Type_Mapping__c>();
                List<Reference_Type_Mapping__c> deleteMappingList = new List<Reference_Type_Mapping__c>();
                 
                for (String key : matrixMap.keySet()) {
                    if (matrixMap.get(key).Required__c || matrixMap.get(key).Visible__c) { 
                        upsertMappingList.add(matrixMap.get(key));
                    } else if ((matrixMap.get(key).Id != null) && !(matrixMap.get(key).Required__c || matrixMap.get(key).Visible__c)) {
                        deleteMappingList.add(matrixMap.get(key));
                    }
                }
                
                if (deleteMappingList.size() > 0) {
                    delete deleteMappingList;
                }
        
                if (upsertMappingList.size() > 0) {
                    upsert upsertMappingList;
                }
                
                for (Referenceability_Type__c ref : referenceTypes) {
                    ref.Note__c = refTypeWrapperList.get(ref.Id).trim();
                }
                
                if (referenceTypes.size() > 0) {
                    upsert referenceTypes;
                }
        
                if (customSetting != null) {
                    update customSetting;
                }
        
                isEdit = false;
            } catch (Exception e) {
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                Database.rollback(sp);
            }
        }
        return null;
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Type_Mapping__c', new Set<String> { 
                                        'Name',
                                        UtilityController.appNamespace() + 'Label__c'});
        if (isContentSetting == 'false') {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Type_Mapping__c').add(UtilityController.appNamespace() + 'Referenceability_Type__c');
        } else if (isContentSetting == 'true') {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Type_Mapping__c').add(UtilityController.appNamespace() + 'Reference_Content_Type__c');
        }
        Boolean isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        
        fieldMap.clear();
        fieldMap.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String>());
        fieldMap.put(UtilityController.appNamespace() + 'Referenceability_Type__c', new Set<String> { 
                                        UtilityController.appNamespace() + 'Note__c' });
        Boolean isUpdatePermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Reference_Type_Mapping__c'});
        return (isDeletePermission && isInsertPermission && isUpdatePermission);
    }
    
    /**
     * Method to cancel edited mappings
     */
    public pageReference cancelMatrix() {

        isEdit = false;
        if (isContentSetting == 'false') {
            methodForReferenceFields();
        } else if (isContentSetting == 'true') {
            methodForContentFields();
        }
        return null;
    }
    
    /**
     * Method to edit mappings
     */
    public pageReference editMatrix() {        
        isEdit = true;
        if (isContentSetting == 'false') {
            methodForReferenceFields();
        } else if (isContentSetting == 'true') {
            methodForContentFields();
        }
        return null;
    }
    
    /**
     * Method to redirect
     */
    public pageReference redirectFieldPage() {        
        PageReference redirectPage = new PageReference(Page.MultiSelectReferenceSettingFields.geturl() + '?customSettingId=' 
                                        + customId + '&isContentSetting=' + isContentSetting);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
    
    /**
     * Method to get back to custom settings
     */
    public pageReference backToCustomSetting() {
        PageReference redirectPage = new PageReference('/' + customId);
        redirectPage.setRedirect(true);
        return redirectPage;
    }
}