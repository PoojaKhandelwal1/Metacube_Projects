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
 * VF Page: DataLoaderSettingPage.page
 * Description: controller for specifying the fields to be included in the data exported from RefedgeDM
 * Last Modified By: Rajesh @Feb 8 2018 REF-1333
 */
 public with sharing class DataLoaderSettingController extends RefEdgeEditionFeatures {
    
    /**
     * Properties and variables
     */
    public String customSettingId { get; set; }
    public Boolean isEdit { get; set; }
	public Boolean isSLDS { get; set; }
    public Boolean isImport { get; set; }
    public List<Data_Mapping__c> fieldList { get; set; }
    public Custom_Settings__c cs { get; set; }
    public String objectType { get; set; }
    public List<SelectOption> allObjects { get; set; }
    public String currentAllObjImport { get; set; }
    public String currentSelectedImportObj { get; set; }
    public String currentAllObjExport { get; set; }
    public String currentSelectedExportObj { get; set; }
    public String importObjectString { get; set; }
    public String exportObjectString { get; set; }
    public List<SelectOption> allObjImport { get; set; }
    public List<SelectOption> allObjExport { get; set; }
    public List<SelectOption> selectedImportObj { get; set; }
    public List<SelectOption> selectedExportObj { get; set; }
    public Map<String, Map<String, String>> objects { get; set; }
    /**
     * Constructor : DMInline
     */
    public DataLoaderSettingController(ApexPages.StandardController controller) {
		cs = UtilityController.getCustomSettings();
		if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
        getData();
    }
    
    /**
     * Method used to get import & export objects : DMInline
     */
    public void getData() {
    	
		objects = UtilityController.getAvailableObjects();
		customSettingId = cs.Id;
        allObjImport = new List<SelectOption>();
        allObjExport = new List<SelectOption>();
        selectedExportObj = new List<SelectOption>();
        selectedImportObj = new List<SelectOption>();
		importObjectString = '';
        exportObjectString = '';
        
        if (cs.Export_Object__c == null || cs.Export_Object__c == '') {
			cs.Export_Object__c = '';
 		} else {
            cs.Export_Object__c += ',' ;
        }
		
		if (cs.Export_Objects__c != null && cs.Export_Objects__c != '') {
			List<String> existingVal = new List<String>();
			if (cs.Export_Objects__c.contains(';')) {
				existingVal = cs.Export_Objects__c.split(';');
			} else {
				existingVal = cs.Export_Objects__c.split(',');
			}
			
			for (String val : existingVal) {
				cs.Export_Object__c = cs.Export_Object__c + val + ',';
			}
			cs.Export_Objects__c = '';
		}
 		cs.Export_Object__c = cs.Export_Object__c.removeEnd(',');
 		
 		if (cs.Import_Object__c == null || cs.Import_Object__c == '') {
    	 		cs.Import_Object__c = '';
    	 		
    	 		if (cs.Import_Objects__c != null && cs.Import_Objects__c != '') {
    	 			List<String> existingVal = cs.Import_Objects__c.split(';'); 
    	 			
    	 			for (String val : existingVal) {
    	 				cs.Import_Object__c = cs.Import_Object__c + val + ',';
    	 			}
        			cs.Import_Objects__c = '';
 			}
 		}
 		cs.Import_Object__c.removeEnd(',');
 		
 		if (cs.Export_Object__c != null && cs.Export_Object__c != '') {
	        
	        for (String obj : cs.Export_Object__c.split(',')) {
				selectedExportObj.add(new SelectOption(obj, objects.get('export').get(obj)));
				exportObjectString = exportObjectString + objects.get('export').get(obj) + ',';
	        }
 		}

        if (cs.Import_Object__c != null && cs.Import_Object__c != '') {
	      
	        for (String obj : cs.Import_Object__c.split(',')) {
				selectedImportObj.add(new SelectOption(obj, objects.get('import').get(obj)));
				importObjectString = importObjectString + objects.get('import').get(obj) + ',';
	        } 
        }
        exportObjectString = exportObjectString.removeEnd(',');
        importObjectString = importObjectString.removeEnd(',');
        
        for (String obj : objects.get('import').keySet()) {
        	
			if (!(new Set<String>(cs.Import_Object__c.split(',')).contains(obj))){
				allObjImport.add(new SelectOption(obj, objects.get('import').get(obj)));
			}
		}
		
		for (String obj : objects.get('export').keySet()) {
			
			if (!(new Set<String>(cs.Export_Object__c.split(',')).contains(obj))){
				allObjExport.add(new SelectOption(obj, objects.get('export').get(obj)));
			}
		}
    
    }
    
    /**
     * Method used to edit fields on the form : DMInline
     */
    public PageReference editForm() {
        isEdit = true; 
        return null;
    }
    
    /**
     * Method used cancel : DMInline
     */
    public PageReference cancelForm() {
		cs = UtilityController.getCustomSettings();
        isEdit = false;
        getData();
        return null;
    }
    
    /**
     * Method used to save fields on the form : DMInline
     */
    public PageReference saveForm() {
        Savepoint sp = Database.setSavepoint();
        try {
    	 		cs.Export_Object__c = '';
    	 		cs.Import_Object__c = '';
				cs.Export_Objects__c = '';
    	 		exportObjectString = '';
    	 		importObjectString = '';
				 
    	 		for (SelectOption val : selectedExportObj) {
					Boolean isStringTooLong = cs.Export_Object__c.length() + val.getValue().length() > 255;
 					cs.Export_Object__c = isStringTooLong ? cs.Export_Object__c : cs.Export_Object__c + val.getValue() + ',' ;
					cs.Export_Objects__c = isStringTooLong ? cs.Export_Objects__c + val.getValue() + ',' : cs.Export_Objects__c;
					exportObjectString = exportObjectString + val.getLabel() + ',';
 				}
 				cs.Export_Object__c = cs.Export_Object__c.removeEnd(',');
				cs.Export_Objects__c = cs.Export_Objects__c.removeEnd(',');
    	 		exportObjectString = exportObjectString.removeEnd(',');
    	 		
    	 		for (SelectOption val : selectedImportObj) {
 					cs.Import_Object__c = cs.Import_Object__c + val.getValue() + ',' ;
 					importObjectString = importObjectString + val.getLabel() + ',';
 				}
				cs.Import_Object__c = cs.Import_Object__c.removeEnd(',');
				importObjectString = importObjectString.removeEnd(',');
 			
	        	if (checkPermissions(false)) {
		        	upsert cs;
	            	isEdit = false;
	        	}
	        	
        } catch(Exception e) {
			Apexpages.addMessages(e);
			Database.rollback(sp);
        }
        return null;
    }
    
    /**
     * Method used to update the object Lists : DMInline
     */
    public void addToList() {
    		
    		if (isImport) {
    			
    			if (currentAllObjImport != null && currentAllObjImport != '') {
					currentAllObjImport = currentAllObjImport.replace('[', '').replace(']', '');
					String[] listofGroups = currentAllObjImport.split(',');   
		        
					if (listofGroups.size() > 0 && currentAllObjImport != '') {
						
						for (Integer i = 0; i < listofGroups.size(); i++) {
							selectedImportObj.add(new SelectOption(listofGroups[i].trim(), objects.get('import').get(listofGroups[i].trim())));
							
							for (integer j = 0; j < allObjImport.size(); j++) {
								
								if (allObjImport[j].getValue().trim() == listofGroups[i].trim()) {
									allObjImport.remove(j);
								}
							}
						}
		        	}
	        	}
    		} else {
    			
    			if (currentAllObjExport != null && currentAllObjExport != '') {
	    			currentAllObjExport = currentAllObjExport.replace('[',  '').replace(']',  '');
		        	List<String> listofGroups = currentAllObjExport.split(',');   
		        
					if (listofGroups.size() > 0 && currentAllObjExport != '') {
						
						for (Integer i = 0; i < listofGroups.size(); i++) {
							selectedExportObj.add(new SelectOption(listofGroups[i].trim(), objects.get('export').get(listofGroups[i].trim())));
							
							for (integer j = 0; j < allObjExport.size(); j++) {
								
								if (allObjExport[j].getValue().trim() == listofGroups[i].trim()) {
									allObjExport.remove(j);
								}
							}
						}
					}
	        	}
    		}
    }
    
    /**
     * Method used to update the object Lists : DMInline
     */
    public void removeFromList() {
    	
    	    if (isImport) {
    			
    			if (currentSelectedImportObj != null && currentSelectedImportObj != '') {
					currentSelectedImportObj = currentSelectedImportObj.replace('[',  '').replace(']',  '');
					String[] listofGroups = currentSelectedImportObj.split(',');   
		        
					if (listofGroups.size() > 0 && currentSelectedImportObj != '') {
						
						for (Integer i = 0; i < listofGroups.size(); i++) {
							allObjImport.add(new SelectOption(listofGroups[i].trim(), objects.get('import').get(listofGroups[i].trim())));
							
							for (integer j = 0; j < selectedImportObj.size(); j++) {
								
								if (selectedImportObj[j].getValue().trim() == listofGroups[i].trim()) {
									selectedImportObj.remove(j);
								}
							}
						}
					}
	        	}
    		} else {
    			
    			if (currentSelectedExportObj != null && currentSelectedExportObj != '') {
	    			currentSelectedExportObj = currentSelectedExportObj.replace('[',  '').replace(']',  '');
	    			List<String> listofGroups = currentSelectedExportObj.split(',');   
		        
					if (listofGroups.size() > 0 && currentSelectedExportObj != '') {
						
						for (Integer i = 0; i < listofGroups.size(); i++) {
							allObjExport.add(new SelectOption(listofGroups[i].trim(), objects.get('export').get(listofGroups[i].trim())));
							
							for (integer j = 0; j < selectedExportObj.size(); j++) {
								
								if (selectedExportObj[j].getValue().trim() == listofGroups[i].trim()) {
									selectedExportObj.remove(j);
								}
							}
						}
					}
				}
    		}

    }
    
    /**
     * Constructor
     */
    public DataLoaderSettingController() {
        customSettingId = apexPages.currentPage().getParameters().get('customSettingId');
        // Check permission for objects
        checkPermissions(true);
        getAllObjects();
        isEdit = false;
    }
    
    public void getAllObjects() {
		Custom_Settings__c cs = UtilityController.getCustomSettings();
		Map<String, Map<String, String>> allObjectsMap = UtilityController.getAvailableObjects();
		Set<SelectOption> allObjectSet = new Set<SelectOption>();
		
		for (String objects : allObjectsMap.get('import').keySet()) {

			if (!objects.contains('with_Attributes__c') && objects.indexOf('__c') >= 0) {
				allObjectSet.add(new SelectOption(objects, allObjectsMap.get('import').get(objects)));
			}
		}
		for (String objects : allObjectsMap.get('export').keySet()) {
			objects = objects.contains('Library__c') ? 'ContentWorkspace' : objects;

			if (!objects.contains('with_Attributes__c') && objects.indexOf('__c') >= 0) {
				allObjectSet.add(new SelectOption(objects, allObjectsMap.get('export').get(objects)));
			}
		}
        allObjects = new List<SelectOption>(allObjectSet);
		allObjects.sort();
        objectType = (allObjects.size() > 0 ) ? allObjects.get(0).getValue() : '';
		objectType = String.escapeSingleQuotes(objectType);
    }
    
    /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used fetch data from data mapping  
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning List<FieldDetailsWrapper> having details with object data mapping records.
    *   @Modified By: Rajesh @Feb 8 2018 REF-1333
​ ​ ​ ​ ​**/
    public void fetchData() {
		if (objectType != null && objectType.trim() != '') {
			fieldList = UtilityController.fetchData(objectType);
		}
	}
    
    /**
     * Method to save the DataLoadersetting
     */
    public PageReference saveSettings() {
    	
        if (checkPermissions(true)) {
            ConstantsController.shouldDataMappingProcessed = true;
            Database.upsert(fieldList, true);
            fetchData();
            isEdit = false;
        }
        return null;
    }
    
    /**
     * Method used to validate Order for datamapping records that validate Order for each records should be unique. // REF-1592 Allow Duplicate Order no
     
    public Boolean validateOrder(List<Data_Mapping__c> dmList) {
    	Boolean result = true;
    	Integer maxOrderNo = 0;
    	
    	for (Data_Mapping__c dm : dmList) {
 			
 			if (dm.Order__c != null) {
 				 
				if (maxOrderNo >= Integer.valueOf(dm.Order__c)) { 
					Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.Error,'Order should be unique for all the Template Fields.'));
					result = false;
				} else {
					maxOrderNo = Integer.valueOf(dm.Order__c);
				}
 			}
    	}        
        return result;
    } */
    
    /**
     * Method to edit the DataLoadersetting
     */
    public PageReference editSettings() {
        isEdit = true;
        return null;
    }
	
    /**
     * Method to return Custom Setting 
     */
    public PageReference returnCustomSettings() {
        PageReference returnPage = new PageReference('/' + customSettingId);
        returnPage.setRedirect(true);
        return returnPage;
    }
    
    /**
     * Method to return Setting
     */
    public PageReference returnSettings() {
        
        fetchData();
        isEdit = false;
        return null;
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isDataMapping) {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
		Map<String, Set<String>> fieldMapCS = new Map<String, Set<String>>();
        Boolean isUpsertPermission = false;
		
		if (isDataMapping) {
			fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> {
                                                UtilityController.appNamespace() + 'Required__c',
                                                UtilityController.appNamespace() + 'Label__c',
                                                UtilityController.appNamespace() + 'Field_API_Name__c',
                                                UtilityController.appNamespace() + 'Object__c',
                                                UtilityController.appNamespace() + 'Visible__c',
                                                UtilityController.appNamespace() + 'From_Mapping__c'});
		} else {
			fieldMapCS.put(UtilityController.appNamespace() + 'Custom_Settings__c', new Set<String> {
                                                UtilityController.appNamespace() + 'Export_Object__c',
                                                UtilityController.appNamespace() + 'Export_Objects__c',
                                                UtilityController.appNamespace() + 'Import_Object__c',
                                                UtilityController.appNamespace() + 'Import_Objects__c'}); 
		}
		isUpsertPermission = (!isDataMapping ||CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Data_Mapping__c'})) && CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true) && CRUDAndFLSCheckController.isUpsertable(fieldMapCS, false, true);
        return isUpsertPermission;
    }
}