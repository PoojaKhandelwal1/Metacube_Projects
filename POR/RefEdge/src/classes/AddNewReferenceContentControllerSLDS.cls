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
 * VF Page: AddNewReferenceContentSLDS.page
 * Description: Controller for creating new reference records or editing existing records.
 * Modified by: Rajesh @Sept 12 2017
 */
public with sharing class AddNewReferenceContentControllerSLDS extends RefEdgeEditionFeatures { 
	/**
     * Properties and variables
     */  
	public static Boolean allowAssociation { get; set; } 
	public String newFileName { get; set; }
	public Boolean isNewRecord { get; set; }
	public Boolean isError { get; set; }
	public String errorMsg { get; set; }
    public transient blob newfile { get; set; } 
    public Id refContentId { get; set; } 
    public Boolean isReferenceContentClone { get; set; }
    public Reference_Content__c referContent { get; set; }
    public String contentURL { get; set; }
    public String selectedExistingTitle { get; set; }
    public List<String> contentVersionFieldApiNames { get; set; }
    private Set<String> fieldMappingsDelete;
    private Set<String> fieldsPresentOnRefContentType;
    public ContentVersion tempContentVersion { get; set; }
    public Map<String, Boolean> customContentTypeFieldsMap { get; set; }
    public Reference_Content_Type_Field__c refContentField { get; set; }
    public List<String> customContentTypeFields { get; set; } 
    public String contentVersionFields { get; set; } 
    public Boolean allowContnetVersionField { get; set; } 
    public String dateString {
	    get {
	            return String.valueOf(Date.today());
	    }
        set;
    }	
    		
    public String nameSpace {
		get {
			return UtilityController.appNamespace();
		}
		private set;
	}
    
	/**
     * Constructor
     */
    public AddNewReferenceContentControllerSLDS(ApexPages.StandardController controller) {
    	Reference_Content__c refContent = (Reference_Content__c)controller.getRecord();
    	
    	if (refContent.Id != null) { 
    		refContentId = refContent.Id;
    		isNewRecord = false; 
    	} else {
    		isNewRecord = true;
    	} 
    	isReferenceContentClone = (Apexpages.Currentpage().getparameters().get('clone') != null && Apexpages.Currentpage().getparameters().get('clone') == '1') ? true : false;  
    	allowAssociation = (Apexpages.Currentpage().getparameters().get('allowAssociation') != null && Apexpages.Currentpage().getparameters().get('allowAssociation') == 'true') ? true : false;
    	
    	if (Apexpages.Currentpage().getparameters().get('refConId') != null) {
    		refContentId = Id.valueOf(Apexpages.Currentpage().getparameters().get('refConId'));   
    	} 
    	
    	if (Apexpages.Currentpage().getparameters().get('error') != null) { 
    		isError = true;
			errorMsg = Apexpages.Currentpage().getparameters().get('error');
    	} else {
    		isError = false;
    	}
    	contentVersionFieldApiNames = new List<String>();
    	refContentField = new Reference_Content_Type_Field__c();
    	customContentTypeFields = new List<String>();
    	fieldsPresentOnRefContentType = new Set<String>();
    	pageSetup(); 
    }
    
    /**
     * Setup method to buildup initial values
     */
    public void pageSetup() {
    	Custom_Settings__c cs = UtilityController.getCustomSettings(); 
    	
    	if (cs.Manage_ContentVersion_Custom_Fields__c != null) {
            
            for (String str : cs.Manage_ContentVersion_Custom_Fields__c.split(',')) {
                allowContnetVersionField = true; 
                break;
            }
        } 
         
        //FROM the Object Api name retrieving the SObject
        Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace().tolowerCase()
        									+ 'reference_content_type_field__c');
        Sobject Object_name = targetType.newSObject();
        //grab the sobject that was passed
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        //describe the sobject
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        
        for (String str : sobject_describe.fields.getMap().keyset()) {
            Schema.DescribeFieldResult sField = sobject_describe.fields.getMap().get(str).getDescribe();
            
            if (sField.isCreateable() && sField.isCustom()
            			&& sField.getName() != UtilityController.appNamespace() + 'Reference_Content__c') {
                fieldsPresentOnRefContentType.add(sField.getName());
            }
        } 
        customContentTypeFieldsMap = new Map<String, Boolean>();
        
        if (refContentId != null) {        
        	List<Reference_Content__c>  referContent = [SELECT Reference_Content_Type__c, Content_URL__c, Content_URL2__c FROM Reference_Content__c WHERE Id = :refContentId LIMIT 1];
        	
        	if (referContent.size() > 0) {
	        
		        for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Order__c, Required__c, Reference_Content_Type__c, Name
		        										FROM Reference_Type_Mapping__c
		        										WHERE Reference_Content_Type__c = :referContent[0].Reference_Content_Type__c
		        										AND Visible__c = true
		        										ORDER BY Order__c NULLS LAST, Name]) {
		            
		            if (rtm.Required__c) {
		                customContentTypeFieldsMap.put(rtm.Name, true);
		            } else {
		                customContentTypeFieldsMap.put(rtm.Name, false);
		            }
		            customContentTypeFields.add(rtm.Name);
		        } 
		        referContent[0].Content_URL2__c = referContent[0].Content_URL2__c == null ? '' : referContent[0].Content_URL2__c;
		        contentURL = referContent[0].Content_URL__c != null ? referContent[0].Content_URL__c + referContent[0].Content_URL2__c : referContent[0].Content_URL__c;
				
                //REF-2289
                if (contentURL == 'null') {
                    contentURL = null;
                }
        	}      
        }
        String query = 'SELECT Id, Reference_Content__c ';
        fieldMappingsDelete = new Set<String>();
        
        for (String fieldName : customContentTypeFieldsMap.keySet()) {
        	
            if (!fieldsPresentOnRefContentType.contains(fieldName)) {
                fieldMappingsDelete.add(fieldName);
            }
        }
        
        for (String fieldName : fieldsPresentOnRefContentType) {
            query += ', ' + fieldName;
        }
        
        for (String fieldName : fieldMappingsDelete) {
            customContentTypeFieldsMap.remove(fieldName);
            integer listCount = 0;
            integer position = 0;
            
            for (String field : customContentTypeFields) {
            	
                if (field == fieldName) {
                    position = listCount;
                    break;
                }
                ++listCount;
            }
            customContentTypeFields.remove(position);
        }
        query += ' FROM ' + UtilityController.appNamespace() + 'Reference_Content_Type_Field__c '
        			+ 'WHERE Reference_Content__c = :refContentId';
        List<Reference_Content_Type_Field__c> rctfTemp = database.query(query);
        
        if (rctfTemp.size() > 0) {
            refContentField = rctfTemp[0];
        }  
    }
    
    @RemoteAction
    public static String getCustomContent(String refContentId, String RefTypeId) {  
    	Map<String, Boolean> customContentTypeFieldsMap = new Map<String, Boolean>();
    	List<String> customContentTypeFields = new List<String>();
    	Set<String> fieldsPresentOnRefContentType = new Set<String>();
    	Reference_Content_Type_Field__c refContentField = new Reference_Content_Type_Field__c();
    	List<CustomFieldWrapper> lstCustomFields = new List<CustomFieldWrapper>();
    	
    	Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace().tolowerCase()
	        									+ 'reference_content_type_field__c');
        Sobject Object_name = targetType.newSObject();
        //grab the sobject that was passed
        Schema.sObjectType sobject_type = Object_name.getSObjectType();
        //describe the sobject
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        
        for (String str : sobject_describe.fields.getMap().keyset()) {
            Schema.DescribeFieldResult sField = sobject_describe.fields.getMap().get(str).getDescribe();
            
            if (sField.isCreateable() && sField.isCustom()
            			&& sField.getName() != UtilityController.appNamespace() + 'Reference_Content__c') {
                fieldsPresentOnRefContentType.add(sField.getName());
            }
        } 
        customContentTypeFieldsMap = new Map<String, Boolean>();
       
        if (!String.isBlank(refContentId)) {  
	           
        	List<Reference_Content__c>  referContent = [SELECT Reference_Content_Type__c, Content_URL__c, Content_URL2__c FROM Reference_Content__c WHERE Id = :refContentId LIMIT 1];
        	
        	if (referContent.size() > 0) {
	        
		        for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Order__c, Required__c, Reference_Content_Type__c, Name
		        										FROM Reference_Type_Mapping__c
		        										WHERE Reference_Content_Type__c = :referContent[0].Reference_Content_Type__c
		        										AND Visible__c = true
		        										ORDER BY Order__c NULLS LAST, Name]) {
		            
		            if (rtm.Required__c) {
		                customContentTypeFieldsMap.put(rtm.Name, true);
		            } else {
		                customContentTypeFieldsMap.put(rtm.Name, false);
		            }
		            customContentTypeFields.add(rtm.Name);
		        }  
        	}      
	        
	       String query = 'SELECT Id, Reference_Content__c ';
	       Set<String> fieldMappingsDelete = new Set<String>();
	        
	       for (String fieldName : customContentTypeFieldsMap.keySet()) {
	        	
	            if (!fieldsPresentOnRefContentType.contains(fieldName)) {
	                fieldMappingsDelete.add(fieldName);
	            }
	        }
	        
	        for (String fieldName : fieldsPresentOnRefContentType) {
				Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap().get(UtilityController.appNamespace() + fieldName.toLowerCase()).getDescribe();
				//system.debug('@@##'+String.valueOf(dfr.getType()));
				if(String.valueOf(dfr.getType()) == 'REFERENCE') {					
					query += ', ' + fieldName.replace('__c','__r') +'.Name ';
				}
	            query += ', ' + fieldName;
	        }
	        
	        for (String fieldName : fieldMappingsDelete) {
	            customContentTypeFieldsMap.remove(fieldName);
	            integer listCount = 0;
	            integer position = 0;
	            
	            for (String field : customContentTypeFields) {
	            	
	                if (field == fieldName) {
	                    position = listCount;
	                    break;
	                }
	                ++listCount;
	            }
	            customContentTypeFields.remove(position);
	        }
	        query += ' FROM ' + UtilityController.appNamespace() + 'Reference_Content_Type_Field__c '
	        			+ 'WHERE Reference_Content__c = :refContentId LIMIT 1';
						
	        List<Reference_Content_Type_Field__c> rctfTemp = database.query(query);
	        
	        if (rctfTemp.size() > 0) {
	            refContentField = rctfTemp[0];   
	        	Map<String, Schema.SObjectField> fieldMapFromDescribe = Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap();
	        
				for (String field : customContentTypeFields) {
 	 
				    Schema.DescribeFieldResult dfr = fieldMapFromDescribe.get(UtilityController.appNamespace() + field.toLowerCase()).getDescribe();
				    
				    if (String.valueOf(dfr.getType()) == 'DATE') {
				       lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), 
				                                             String.valueOf(dfr.isAccessible()), '', null,String.valueOf(refContentField.get(field)),customContentTypeFieldsMap.get(field), '', '', null, null));
				    } else if (String.valueOf(dfr.getType()) == 'PICKLIST') {
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), 
				                                             String.valueOf(dfr.isAccessible()), '', getPickList(field),String.valueOf(refContentField.get(field)),customContentTypeFieldsMap.get(field), '', '', null, null));
				    } else if (String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {
						List<MultiPicklistWrapper> mploptions = new List<MultiPicklistWrapper>();

						for(String opt : getPickList(field)) {
							mploptions.add(new MultiPicklistWrapper(opt, opt));
						}
						
						List<MultiPicklistWrapper> mplAvailoptions = new List<MultiPicklistWrapper>();
						if(String.valueOf(refContentField.get(field)) != null) {

							if(String.valueOf(refContentField.get(field)).contains(';')) {
								
								for(String pickVal : String.valueOf(refContentField.get(field)).split(';')) {
									mplAvailoptions.add(new MultiPicklistWrapper(pickval.trim(), pickval.trim()));
								}
							} else {
								mplAvailoptions.add(new MultiPicklistWrapper(String.valueOf(refContentField.get(field)).trim(), String.valueOf(refContentField.get(field)).trim()));
							}
						}
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), 
				                                             String.valueOf(dfr.isAccessible()), '', null,'',customContentTypeFieldsMap.get(field), '', '', mploptions, mplAvailoptions));
				    } else if (String.valueOf(dfr.getType()) == 'DATETIME') {
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()),
				                                             String.valueOf(dfr.isAccessible()), '', null,String.valueOf(refContentField.get(field)),customContentTypeFieldsMap.get(field), '', '', null, null));
				    } else if(String.valueOf(dfr.getType()) == 'REFERENCE') {
						
						if(String.valueOf(refContentField.get(field)) != null) { 
							Sobject	relObjChild1 = refContentField.getSObject(field.replace('__c', '__r')); 
							lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()),String.valueOf(dfr.isAccessible()), String.valueOf(relObjChild1.get('Name')) , null,
																String.valueOf(refContentField.get(field)),customContentTypeFieldsMap.get(field), string.valueOf(dfr.getReferenceTo()[0].getDescribe().getName()), string.valueOf(dfr.getReferenceTo()[0].getDescribe().getLabel()), null, null));
						} else {
							lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()),String.valueOf(dfr.isAccessible()), '' , null,
																String.valueOf(refContentField.get(field)),customContentTypeFieldsMap.get(field), string.valueOf(dfr.getReferenceTo()[0].getDescribe().getName()), string.valueOf(dfr.getReferenceTo()[0].getDescribe().getLabel()), null, null));
						}
					} else {     
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()),String.valueOf(dfr.isAccessible()), '', null,
				        									String.valueOf(refContentField.get(field)),customContentTypeFieldsMap.get(field), '', '', null, null));
				    } 
				}  
     		}
    	} else if (!String.isBlank(RefTypeId)) {
	        
		        for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Order__c, Required__c, Reference_Content_Type__c, Name
		        										FROM Reference_Type_Mapping__c
		        										WHERE Reference_Content_Type__c = :RefTypeId
		        										AND Visible__c = true
		        										ORDER BY Order__c NULLS LAST, Name]) {  
		            if (rtm.Required__c) {
		                customContentTypeFieldsMap.put(rtm.Name, true);
		            } else {
		                customContentTypeFieldsMap.put(rtm.Name, false);
		            }
		            customContentTypeFields.add(rtm.Name);
		        }
		        
		        Map<String, Schema.SObjectField> fieldMapFromDescribe = Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap();
	        
				for (String field : customContentTypeFields) {
 	 
				    Schema.DescribeFieldResult dfr = fieldMapFromDescribe.get(UtilityController.appNamespace() + field.toLowerCase()).getDescribe();
				    
				    if (String.valueOf(dfr.getType()) == 'DATE') {
				       lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), 
				                                             String.valueOf(dfr.isAccessible()), '', null,'',customContentTypeFieldsMap.get(field), '', '', null, null));
				    } else if (String.valueOf(dfr.getType()) == 'PICKLIST') {
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), 
				                                             String.valueOf(dfr.isAccessible()), '', getPickList(field),'',customContentTypeFieldsMap.get(field), '', '', null, null));
				    } else if (String.valueOf(dfr.getType()) == 'MULTIPICKLIST') {
						List<MultiPicklistWrapper> mploptions = new List<MultiPicklistWrapper>();

						for(String opt : getPickList(field)) {
							mploptions.add(new MultiPicklistWrapper(opt, opt));
						}
						
						List<MultiPicklistWrapper> mplAvailoptions = new List<MultiPicklistWrapper>();
						if(String.valueOf(refContentField.get(field)) != null) {

							if(String.valueOf(refContentField.get(field)).contains(';')) {
								
								for(String pickVal : String.valueOf(refContentField.get(field)).split(';')) {
									mplAvailoptions.add(new MultiPicklistWrapper(pickval.trim(), pickval.trim()));
								}
							} else {
								mplAvailoptions.add(new MultiPicklistWrapper(String.valueOf(refContentField.get(field)).trim(), String.valueOf(refContentField.get(field)).trim()));
							}
						}
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()), 
				                                             String.valueOf(dfr.isAccessible()), '', null,'',customContentTypeFieldsMap.get(field), '', '', mploptions, mplAvailoptions));
				    } else if (String.valueOf(dfr.getType()) == 'DATETIME') {
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()),
				                                             String.valueOf(dfr.isAccessible()), '', null,'',customContentTypeFieldsMap.get(field), '', '', null, null));
				    } else if(String.valueOf(dfr.getType()) == 'REFERENCE') {
						lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()),String.valueOf(dfr.isAccessible()), field.replace('__c','__r'), null,
				        									String.valueOf(refContentField.get(field)),customContentTypeFieldsMap.get(field), string.valueOf(dfr.getReferenceTo()[0].getDescribe().getName()), string.valueOf(dfr.getReferenceTo()[0].getDescribe().getLabel()), null, null));
					} else {     
				        lstCustomFields.add(new CustomFieldWrapper(dfr.getLabel(), field, String.valueOf(dfr.getType()),String.valueOf(dfr.isAccessible()), '', null,
				        									'',customContentTypeFieldsMap.get(field), '', '', null, null));
				    } 
				}   
        	} 
           
    	return JSON.serialize(lstCustomFields); 
    }
    
    @RemoteAction
    public static String getContentVersionDetails(String ContentID) {    
    	List<ContentVersionFieldWrapper> lstCustomFields = new List<ContentVersionFieldWrapper>();    	 
    	Custom_Settings__c cs = UtilityController.getCustomSettings();
    	Set<String> setContentFields = new Set<String>();
    	
    	ContentVersion tempContentVersion = new ContentVersion();  
    	
    	if (cs.Manage_ContentVersion_Custom_Fields__c != null) {
            
            for (String str : cs.Manage_ContentVersion_Custom_Fields__c.split(',')) {
                setContentFields.add(str.trim());
            }
        }
        // FROM the Object API name retrieving the sObject
        Schema.SObjectType targetTypes = CRUDAndFLSCheckController.sObjectsMap.get('ContentVersion');
        Sobject Object_names = targetTypes.newSObject();
        // grab the sobject that was passed
        Schema.sObjectType sobject_types = Object_names.getSObjectType();
        Schema.DescribeSObjectResult sobject_describes = sobject_types.getDescribe();
        
        if (!String.isEmpty(ContentID)) {
    		String query = 'SELECT ';
	                
            for (String str : sobject_describes.fields.getMap().keyset()) {
            	Schema.DescribeFieldResult sField = sobject_describes.fields.getMap().get(str).getDescribe();
                query += sField.getName() +', ';
            }
            query = query.removeEnd(', ');
            query += ' FROM ContentVersion WHERE Id = \'' + String.escapeSingleQuotes(ContentID) + '\'';
           
            for (ContentVersion cv : database.query(query)) {
                tempContentVersion = cv;
            } 
    	} 
    	 
        for (String str : sobject_describes.fields.getMap().keyset()) {
            Schema.DescribeFieldResult sField = sobject_describes.fields.getMap().get(str).getDescribe();
            
            if (sField.isCreateable() && sField.isCustom()
	                && sField.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c'
	                && sField.getName() != UtilityController.appNamespace() + 'Content_Status__c') {
                
                if ((sField.isCreateable() && !sField.isNillable() && !sField.isDefaultedOnCreate()) || setContentFields.contains(sField.getName())) {
                	
                	if (!String.isEmpty(ContentID) && tempContentVersion != null) {
                		
                		if (String.valueOf(sField.getType()) == 'PICKLIST') {
                			lstCustomFields.add(new ContentVersionFieldWrapper(sField.getLabel(),sField.getName(), String.valueOf(sField.getType()), '', String.valueOf(tempContentVersion.get(sField.getName())).trim(), getPickListForContnetField(sField.getName()), (sField.isCreateable() && !sField.isNillable() && !sField.isDefaultedOnCreate())));
                		} else if (String.valueOf(sField.getType()) == 'DATE' || String.valueOf(sField.getType()) == 'DATETIME') {
                			Date dateValue = Date.valueOf(tempContentVersion.get(sField.getName()));
                			lstCustomFields.add(new ContentVersionFieldWrapper(sField.getLabel(),sField.getName(), String.valueOf(sField.getType()), '', String.valueOf(dateValue), 
                					  null, (sField.isCreateable() && !sField.isNillable() && !sField.isDefaultedOnCreate())));
                		} else { 
                			lstCustomFields.add(new ContentVersionFieldWrapper(sField.getLabel(),sField.getName(), String.valueOf(sField.getType()), '', (tempContentVersion.get(sField.getName()) != null) ? String.valueOf(tempContentVersion.get(sField.getName())).trim() : '', null, (sField.isCreateable() && !sField.isNillable() && !sField.isDefaultedOnCreate())));
                		}
                    } else {
                    	
                    	if (String.valueOf(sField.getType()) == 'PICKLIST') {
                			lstCustomFields.add(new ContentVersionFieldWrapper(sField.getLabel(), sField.getName(), String.valueOf(sField.getType()), '', '', getPickListForContnetField(sField.getName()), (sField.isCreateable() && !sField.isNillable() && !sField.isDefaultedOnCreate())));
                    	} else {
                    		lstCustomFields.add(new ContentVersionFieldWrapper(sField.getLabel(), sField.getName(), String.valueOf(sField.getType()), '', '', null, (sField.isCreateable() && !sField.isNillable() && !sField.isDefaultedOnCreate())));
                    	} 
                	 }
                                       
    			}
            }
        }  
    	return JSON.serialize(lstCustomFields); 
    }
    
     public static List<String> getPickList(String field) {
        List<String> options = new List<String>();
        Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap().get(UtilityController.appNamespace() 
                                                                                                               +  field).getDescribe();
        List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            options.add(String.valueOf(f.value));
        }
        return options;
    }
    
    public static List<String> getPickListForContnetField(String field) {
        List<String> options = new List<String>();
        Schema.SObjectType targetTypes = CRUDAndFLSCheckController.sObjectsMap.get('ContentVersion');
        Sobject Object_names = targetTypes.newSObject();
        // grab the sobject that was passed
        Schema.sObjectType sobject_types = Object_names.getSObjectType();
        Schema.DescribeSObjectResult sobject_describes = sobject_types.getDescribe(); 
        
        Schema.DescribeFieldResult dfr = sobject_describes.fields.getMap().get(UtilityController.appNamespace() +  field).getDescribe();
        List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) {
            options.add(String.valueOf(f.value));
        }
        return options;
    }
    
    /**
     * Method to get page records in case of edit
     */ 
    @RemoteAction
    public static List<PageParameterWrapper> getPageRecords(String referenceContentId, Boolean isClone) {    
        List<PageParameterWrapper> refContentRecords = new List<PageParameterWrapper>();
       
        if (!String.isBlank(referenceContentId) || isClone) {  
	        //Id referContentId = Id.valueOf(referenceContentId);
	        Reference_Content__c referContent; 
	        Boolean isReferenceType = false;
	        
	        try {
	        	 referContent = [SELECT Allow_Social_Sharing__c, Featured_Content__c, Substitute_Account_Name__c, Reference_Content_Type_Name__c, Custom_Reference_Content__c, 
	        	 					Reference_Content_Type__c, Reference_Content_Type__r.Recorded_Reference_Type__c, Reference_Content_Type__r.Name__c,
	            					Internal_Use__c, Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c, Publish_date__c, Publication_name__c, Library_ID__c, 
	            					Language__c, Expiration_Date__c, Created_User_Name__c, Content_URL__c, Content_URL2__c, Content_Status__c,
	            					Content_ID__c, Author__c, Article_publication_date__c, External_Summary__c FROM Reference_Content__c WHERE Id = :referenceContentId LIMIT 1]; 
	        	  
	        	if (referContent != null) {  
	        		isReferenceType = referContent.Reference_Content_Type__r.Recorded_Reference_Type__c; 
	        		
	        		refContentRecords.add(new PageParameterWrapper(referContent.Title__c, referContent.Library_ID__c, referContent.Content_Status__c, referContent.Language__c,
			        		referContent.Reference_Content_Type__c, referContent.Content_URL__c + (referContent.Content_URL2__c == null ? '' : referContent.Content_URL2__c), referContent.Custom_Reference_Content__c, referContent.Substitute_Account_Name__c,
			        		referContent.Internal_Use__c, referContent.Allow_Social_Sharing__c, referContent.Featured_Content__c, referContent.Publish_date__c, referContent.Review_Date__c,
			        		referContent.Expiration_Date__c, referContent.Publication_name__c, referContent.Author__c, referContent.Article_publication_date__c, 
			        		referContent.Search_Terms_keywords__c, referContent.Summary__c, referContent.External_Summary__c, isReferenceType, referContent.Content_ID__c));
	        	 } 
	        } catch (Exception e) {
	            ApexPages.addmessages(e); 
	        }  
        } else { 
        	 refContentRecords.add(new PageParameterWrapper('--None--', '--None--', '--None--', '--None--'));
        }
        return refContentRecords; 
    } 
    
   
    /**
     * Method to get Reference Content Type
     */
    @RemoteAction
    public static List<ReferenceContentTypeWrapper> getReferenceContentType() { 
        List<ReferenceContentTypeWrapper> refContent; 
        
        try { 
            refContent = new List<ReferenceContentTypeWrapper>();
            refContent.add(new ReferenceContentTypeWrapper('--None--', '--None--', false));
            
            for (Reference_Content_Type__c rc : [SELECT Id, Name__c, Active__c, Recorded_Reference_Type__c FROM Reference_Content_Type__c
            										WHERE Active__c = true ORDER BY Name__c LIMIT :limits.getLimitQueryRows()]) {
                refContent.add(new ReferenceContentTypeWrapper(rc.Id, rc.Name__c, rc.Recorded_Reference_Type__c));
            }  
        } catch (Exception e) {
            ApexPages.addmessages(e);
        } 
        return refContent;
    }
    
    /**
     * Method get Associated Accounts List
     */
	@RemoteAction
    public static List<AccountWrapper> getAssociatedAccounts(String contentId) { 
        List<AccountWrapper> acc;
        
        try {        	 
            acc = new List<AccountWrapper>(); 
                        
           	for (Account_Reference_Content__c rc : [SELECT Account__c, Account__r.Name FROM Account_Reference_Content__c 
	        												WHERE Reference_Content__c = :contentId ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            	acc.add(new AccountWrapper(rc.Account__c, rc.Account__r.Name, false));
        	}
        } catch (Exception e) {
            ApexPages.addmessages(e);
        }
        return acc;
    }
    
    /**
     * Method get Associated Contact List
     */
    @RemoteAction
    public static List<ContactWrapper> getAssociatedContacts(String contentId) { 
        List<ContactWrapper> con; 
        
        try { 
            con = new List<ContactWrapper>(); 
                        
          	for (Contact_Reference_Content__c rc : [SELECT Contact__c, Contact__r.Name, Contact__r.Account.Name FROM Contact_Reference_Content__c 
	        												WHERE Reference_Content__c = :contentId ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            	con.add(new ContactWrapper(rc.Contact__c, rc.Contact__r.Name, rc.Contact__r.Account.Name, false));
        	}
        } catch (Exception e) {
            ApexPages.addmessages(e);
        }
        return con;
    }
    
    /**
     * Method Save Associations
     */
    @RemoteAction
    public static String saveAssociations(String accountIds, String contactIds, String contentId) { 
       	String errMsg = 'Error' + ' ';
       	Savepoint sp = Database.setSavepoint();
       
        try {  
             // Add Accounts with premissions
        	if (!String.isEmpty(accountIds)) {
	        	List<String> lstAcc = accountIds.split(',');
	        	    
	        	if (lstAcc.size() > 0) {
	        		List<Account_Reference_Content__c> associateAccount = new List<Account_Reference_Content__c>();
	        		 
	        		for (String ids : lstAcc) {   
        				associateAccount.add(new Account_Reference_Content__c(Account__c = Id.valueOf(ids), Reference_Content__c = Id.valueOf(contentId)));
	        		}
	        		 
	        		insert  associateAccount; 
	        	}
        	}
        	
        	// Add Contact  with premissions
        	if (!String.isEmpty(contactIds)) {
	        	List<String> lstCon = contactIds.split(',');
	        	 
	        	if (lstCon.size() > 0) {
	        		List<Contact_Reference_Content__c> associateContact = new List<Contact_Reference_Content__c>(); 
	        		 
	        		for (String ids : lstCon) {
	        			associateContact.add(new Contact_Reference_Content__c(Contact__c = Id.valueOf(ids), Reference_Content__c = Id.valueOf(contentId)));
	        		}
	        		 
	        		insert associateContact;        		
	        	}
        	} 
 			
        } catch (Exception e) { 
            errMsg += CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
            Database.rollback(sp);	 
            return errMsg;
        }
        return 'Success'; 
    }
    
    /**
     * Method to validate that native content type already used in reference content
     */
    @RemoteAction
    public static Boolean isContentAlreadyExist(String nativeContentId) {   
    	Integer recordCount = database.countQuery('SELECT count() FROM Reference_Content__c WHERE Content_ID__c = : nativeContentId'); 
    	return (recordCount > 0) ? true : false; 
    }
    
    /**
     * Method to get Date Format
     */
    @RemoteAction
    public static String getDateFormat() {   
    		String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
    		return dateFormat;
    }
    
    /**
     * Method to validate that interview content is exist before activate Interview Type ref content
     */
    @RemoteAction
    public static Boolean checkInterviewTopics(String referContentId) { 	   
    	List<Reference_Interview__c> tempRefInterviewList = [SELECT Id, Reference_Content__c, (SELECT Id, Reference_Interview__c, Video_Url_Embed__c FROM Interview_Topics__r)
	    											FROM Reference_Interview__c WHERE Reference_Content__c = :referContentId];
		
		if (tempRefInterviewList != null && tempRefInterviewList.size() > 0) {
			Reference_Interview__c tempRefInterview = tempRefInterviewList[0];
			
			if (tempRefInterview.Interview_Topics__r != null && tempRefInterview.Interview_Topics__r.size() > 0) {
				
				for (Interview_Topic__c it : tempRefInterview.Interview_Topics__r) {
					
					if (it.Video_Url_Embed__c != null && it.Video_Url_Embed__c != '') {  
						return true;
					}
				}
			}
		}
		return false;	        	 
    }
    
    /**
     * Method to save Reference Content
     */
   	@RemoteAction
    public static String saveReferenceContent(String info, Boolean isClone, String refContentId, String refContentTypeName, Boolean isFileUploaded, String customFields) {      
    	Reference_Content__c referContent = new Reference_Content__c(); 
    	List<Reference_Note__c> referenceNotes = new List<Reference_Note__c>();
	    List<Account_Reference_Content__c> associatedAccounts = new List<Account_Reference_Content__c>();
	    List<Contact_Reference_Content__c> associatedContacts = new List<Contact_Reference_Content__c>();
	    List<Content_Attribute__c> contentAttributes = new List<Content_Attribute__c>();
	    List<Reference_Interview__c> referenceInterviews = new List<Reference_Interview__c>();
	    List<Interview_Topic__c> interviewTopics = new List<Interview_Topic__c>();
	  	Savepoint sp = Database.setSavepoint();
	  	
    	try {   
			PageParameterWrapper infoWp = (PageParameterWrapper)JSON.deserialize(info, PageParameterWrapper.class);   
			 
			referContent.Allow_Social_Sharing__c = (infoWp.IsAllowingSharing == null) ? false :infoWp.IsAllowingSharing;
			referContent.Featured_Content__c =  (infoWp.IsFeatureContent == null) ? false :infoWp.IsFeatureContent; 
			referContent.Substitute_Account_Name__c = infoWp.SubAccount;
			referContent.Reference_Content_Type_Name__c = refContentTypeName;  
			referContent.Reference_Content_Type__c = infoWp.ContentType; 
			referContent.Internal_Use__c = (infoWp.IsInternalUse == null) ? false :infoWp.IsInternalUse;
			referContent.Custom_Reference_Content__c = (infoWp.IsCustomContentType == null) ? false : infoWp.IsCustomContentType;
			referContent.Title__c = infoWp.Title;
			referContent.Summary__c = infoWp.Summery;
			referContent.Search_Terms_keywords__c = infoWp.SearchItem;
			referContent.Review_Date__c = (!String.isBlank(infoWp.ReviewDate)) ? Date.valueOf(infoWp.ReviewDate) : null;
			referContent.Publish_date__c = (!String.isBlank(infoWp.PublishedDate)) ? Date.valueOf(infoWp.PublishedDate) : null; 
			referContent.Publication_name__c = infoWp.PublicationName; 
			referContent.Library_ID__c = infoWp.LibraryID;
			referContent.Language__c = infoWp.Language;
			referContent.Expiration_Date__c = (!String.isBlank(infoWp.ExpirationDate)) ? Date.valueOf(infoWp.ExpirationDate) : null;  
			referContent.Content_URL__c = infoWp.ContentURL != null && infoWp.ContentURL.length() > 255 ? infoWp.ContentURL.substring(0,254) : infoWp.ContentURL;
			referContent.Content_URL2__c = infoWp.ContentURL != null && infoWp.ContentURL.length() > 255 ? infoWp.ContentURL.substring(255) : '';
			referContent.Content_Status__c = infoWp.ContentStatus;
			referContent.Content_ID__c = infoWp.NativeContentType;
			referContent.Author__c = infoWp.Author; 
			referContent.Article_publication_date__c = (!String.isBlank(infoWp.ArticalPublishDate)) ? Date.valueOf(infoWp.ArticalPublishDate) : null;
			referContent.External_Summary__c = infoWp.ExternalSummery; 
		 	referContent.Is_File_Changed__c = true; 
	      	
	      	if (!String.isBlank(refContentId) && !isClone) { 
	      		referContent.id = Id.valueOf(refContentId);
	      	} else {
	      		referContent.id = null;
	      	}
	      	upsert referContent;   
    		
    		// Insert custom fields
    		List<Reference_Content_Type_Field__c> refContentField = new List<Reference_Content_Type_Field__c>();   
    		
    		if (referContent.Custom_Reference_Content__c && !String.isBlank(customFields)) {
    			List<CustomFieldWrapper> lstCustom  = (List<CustomFieldWrapper>)JSON.deserialize(customFields, List<CustomFieldWrapper>.class); 
    			
    			if (lstCustom.size() > 0) { 
    				Reference_Content_Type_Field__c field = new Reference_Content_Type_Field__c();
    				
    				if (!String.isBlank(refContentId)) { 
    					field = [SELECT Id FROM Reference_Content_Type_Field__c WHERE Reference_Content__c = : Id.valueOf(refContentId) LIMIT 1];
    				} 
    				Reference_Content_Type_Field__c obj = new Reference_Content_Type_Field__c();
	    		 
	    			for (CustomFieldWrapper lst : lstCustom) {
	    				
	    				if (lst.fieldType == 'BOOLEAN') {
	    					obj.put(lst.apiName, Boolean.valueof(lst.fieldValue));
	    				} else if (lst.fieldType == 'DATE' || lst.fieldType == 'DATETIME') {  
	    					
	    					if (!String.isBlank(lst.fieldValue)) { 
	    						obj.put(lst.apiName, Date.valueof(lst.fieldValue));
	    					}
	    				} else if(lst.fieldType == 'CURRENCY' || lst.fieldType == 'DOUBLE' || lst.fieldType == 'PERCENT') {

							if (!String.isBlank(lst.fieldValue)) { 
								obj.put(lst.apiName, Decimal.valueof(lst.fieldValue));
							}
						} else if(lst.fieldType == 'MULTIPICKLIST') {

							String mplVal = '';
							if(lst.multiPickAvailOptions.size() > 0) {

								for(MultiPicklistWrapper picVal : lst.multiPickAvailOptions) {
									mplVal += picVal.name+ ';';
								}
								mplVal.removeEnd(';');
							}
							obj.put(lst.apiName, mplVal);	
						} else {
	    					obj.put(lst.apiName, String.valueof(lst.fieldValue));
	    				} 
	    			}
	    			obj.put('Reference_Content__c' ,referContent.id);
	    			 
	    			if (!String.isBlank(refContentId) && field != null) {  
	    				obj.put('Id' , Id.valueOf(field.Id));
    				}
					refContentField.add(obj); 
    			}
    			upsert refContentField;
    			 
    		}
    		
    		if (isClone) {	            	
            	// Clone reference notes
            	for(Reference_Note__c rn : [SELECT Note__c, Note_Date__c, Reference_Content__c FROM Reference_Note__c
            								WHERE Reference_Content__c = :refContentId]) { 
        									
            		referenceNotes.add(rn.clone(false, true));
            	}           
            	 	
            	 //Insert reference notes
                for (Reference_Note__c record : referenceNotes) {
					record.Reference_Content__c = referContent.id;
				}
				insert referenceNotes;
            	
            	// Clone associated accounts
            	for(Account_Reference_Content__c arc : [SELECT Account__c, Reference_Content__c FROM Account_Reference_Content__c
            											WHERE Reference_Content__c = :refContentId]) { 
            		associatedAccounts.add(arc.clone(false, true));
            	}
            	
            	//Insert associated accounts
				for (Account_Reference_Content__c record : associatedAccounts) {
					record.Reference_Content__c = referContent.id;
				}
				insert associatedAccounts;
            	
            	// Clone associated contacts
            	for(Contact_Reference_Content__c crc : [SELECT Contact__c, Reference_Content__c FROM Contact_Reference_Content__c
            											WHERE Reference_Content__c = :refContentId]) { 
            		associatedContacts.add(crc.clone(false, true));
            	}
            	
            	//Insert associated contacts
				for (Contact_Reference_Content__c record : associatedContacts) {
					record.Reference_Content__c = referContent.id;
				}
				insert associatedContacts;
            	
            	// Clone Content Attribute
            	for(Content_Attribute__c ca : [SELECT Account__c, Attribute__c, From_Account__c, Is_fromMapping__c, Reference_Content__c
            									FROM Content_Attribute__c
            									WHERE Reference_Content__c = :refContentId
            									AND Is_fromMapping__c = false
            									AND From_Account__c = false]) { 
            		contentAttributes.add(ca.clone(false, true));
            	}
            	//Insert content attributes
				for (Content_Attribute__c record : contentAttributes) {
					record.Reference_Content__c = referContent.id;
				}
				insert contentAttributes;
            	
            	// Clone Reference Interview
            	for(Reference_Interview__c ri : [SELECT Transcript__c, Transcript_Content_Id__c, SystemModstamp, Speaker_info__c, Reference_Content__c, Photograph__c, 
            										Org_website__c, Org_description__c, Name, (SELECT Question__c, Transcript__c, Order__c, Content_Id__c, Content_File__c,
    												Active__c, Language__c, Length__c, Reference_Interview__c, Interview_Question__c, Video_URL__c, Video_Url_Embed__c
    												FROM Interview_Topics__r) FROM Reference_Interview__c WHERE Reference_Content__c = :refContentId]) {
					 
            		referenceInterviews.add(ri.clone(false, true));
            		
            		for (Interview_Topic__c it : ri.Interview_Topics__r) { 
            			interviewTopics.add(it.clone(false, true));
            		}
            	}
            	upsert referenceInterviews;
            	
            	//Insert interview topics
				for (Interview_Topic__c record : interviewTopics) {
					record.Reference_Interview__c = referenceInterviews.get(0).id;
				}				
				upsert interviewTopics; 
				
				//Insert reference interviews
				if (referenceInterviews.size() > 0) {
					
					for (Reference_Interview__c record : referenceInterviews) {
						record.Reference_Content__c = referContent.id;
					}
					insert referenceInterviews;
					
					//Insert interview topics
					for (Interview_Topic__c record : interviewTopics) {
						record.Reference_Interview__c = referenceInterviews.get(0).id;
					}
					insert interviewTopics;
				}           	 
            }   
    	} catch (Exception e) {  
        	ApexPages.addmessages(e);  
        	Database.rollback(sp);	
			return 'Error @@'+ CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        } 
        return String.valueOf(referContent.Id);
    }
   	
   	/**
     * Method to create ContentVersion 
     */ 
	public PageReference createContentVersion() {  
     	Savepoint sp = Database.setSavepoint();  
     	PageReference pageRef = new PageReference(Page.AddNewReferenceContentSLDS.getUrl());
     	
     	try {
     		
     		if (refContentId != null) { 
	     		List<ContentVersion> contentObject = new List<ContentVersion>();
	     		referContent = new Reference_Content__c();
	     		String versionId;  
	     		referContent.Id = refContentId; 
            	List<Attachment> attachmentsList = [SELECT ParentId, Name, Id, Body FROM Attachment
													WHERE Name = 'documentThumbnail.jpg' AND ParentId = :referContent.Id];
				if (attachmentsList != null && attachmentsList.size() > 0) {
					delete attachmentsList;
				}   
	     		referContent = [SELECT Allow_Social_Sharing__c, Featured_Content__c, Substitute_Account_Name__c,
	            					Reference_Content_Type_Name__c, Custom_Reference_Content__c, Reference_Content_Type__c,
	            					Reference_Content_Type__r.Recorded_Reference_Type__c, Reference_Content_Type__r.Name__c,
	            					Internal_Use__c, Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c,
	            					Publish_date__c, Publication_name__c, Library_ID__c, Language__c,
	            					Expiration_Date__c, Created_User_Name__c, Content_URL__c, Content_URL2__c, Content_Status__c,
	            					Content_ID__c, Author__c, Article_publication_date__c, External_Summary__c
	            					FROM Reference_Content__c
	            					WHERE Id = :refContentId LIMIT 1];
	     		 
	     		if (!referContent.Custom_Reference_Content__c) { 
		            
	            	if (!isNewRecord && referContent.Id != null && referContent.Content_ID__c != null && referContent.Content_ID__c != '') {
                        //REF-2289
                        List<ContentVersion> cv = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = : referContent.Content_ID__c];
                     
                        if (cv.size() > 0) {
                            contentObject = [SELECT Id, TagCsv, Description, Language, Content_Status__c, Title,
                                            ContentDocumentId, Reference_Content_Type__c, PathOnClient, FirstPublishLocationId
                                            FROM ContentVersion
                                            WHERE ContentDocumentId = :cv[0].ContentDocumentId
                                            AND IsLatest = true];
                        }
                        
                        if (contentObject.size() > 0) {
                            referContent.Content_ID__c = contentObject[0].Id;
                            
                            if (newfile != null || ((referContent.Content_URL__c != null && referContent.Content_URL__c + '' + referContent.Content_URL2__c != contentURL) || referContent.Content_URL__c != contentURL)) {
                                
                                if (newfile != null) {  
                                    createContentVersionObject(true, contentObject[0].ContentDocumentId, contentVersionFields);
                                } else if (referContent.Content_URL__c != null && referContent.Content_URL__c != '' && referContent.Content_URL__c + referContent.Content_URL2__c != contentURL) {
                                    updateContentVersionObject(contentObject[0].Id, contentVersionFields);
                                } else if (referContent.Content_URL__c == null) {
                                    updateContentVersionObject(contentObject[0].Id, contentVersionFields);
                                }
                            } else {
                                
                                if (!test.isRunningTest() && contentObject.size() > 0) {
                                    updateContentVersionObject(contentObject[0].Id, contentVersionFields);
                                }
                            }
                        }
	                } else {		
		                 
	                	//for new RefContent record
	                    if (newfile != null) {
	                        createContentVersionObject(true, '', contentVersionFields);
	                    } else if ((selectedExistingTitle == null || selectedExistingTitle == '') && contentURL != null && contentURL != '') {   
	                        createContentVersionObject(false, '', contentVersionFields);
	                    } else if (selectedExistingTitle != null && selectedExistingTitle != '') { 
	                        
	                        for (ContentDocument contDoc : [SELECT ParentId, Title, LatestPublishedVersionId FROM ContentDocument 
	                        								WHERE Title = :selectedExistingTitle LIMIT: limits.getLimitQueryRows()]) {
	                            referContent.Content_ID__c = contDoc.LatestPublishedVersionId;
	                            versionId = contDoc.LatestPublishedVersionId;
	                            referContent.Library_ID__c = contDoc.ParentId;
	                        } 
		                       
	                        if (referContent.Content_ID__c != null) {
	                            contentObject = [SELECT Title, FirstPublishLocationId,ContentUrl, Reference_Content_Type__c,
	                            					Id, ContentDocumentId, Content_Status__c, Language
	                            					FROM ContentVersion WHERE Id = :versionId LIMIT 1];
	            				
	                            if (contentObject.size() > 0) {
	                                updateContentVersionObject(contentObject[0].Id, contentVersionFields);
	                            }
	                        }
	                    }
	                }    
	                upsert referContent;
	            } 
	            //Delete RTM
	            List<Reference_Type_Mapping__c> deleteRTM = new List<Reference_Type_Mapping__c>();
	            
	            for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name 
	            										FROM Reference_Type_Mapping__c 
	            										WHERE Reference_Content_Type__c = : referContent.Reference_Content_Type__c 
	            										AND Name In: fieldMappingsDelete]) {
	                deleteRTM.add(rtm);
	            }
	            
	            if (deleteRTM.size() > 0) {
	            	delete deleteRTM;
	            } 
	            
			    pageRef.setRedirect(true);
			    pageRef.getParameters().put('refConId',referContent.id); 
			    pageRef.getParameters().put('allowAssociation','true');
			    
     		} else { 
     			return null;
     		} 
     	} catch (Exception e) {   
     		database.rollback(sp);
     		
     		if (isNewRecord) {
     			deleteReferenceContent(refContentId); 
     		}
     		pageRef.getParameters().put('error', CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage()));
     		pageRef.setRedirect(true); 
        } 
     	return pageRef;
	} 
	
   	/**
     * Method to get Reference Library
     */
    @RemoteAction
    public static List<ReferenceLibraryWrapper> getReferenceLibrary() { 
        List<ReferenceLibraryWrapper> refLibrary;
        
        try { 
            refLibrary = new List<ReferenceLibraryWrapper>();
            refLibrary.add(new ReferenceLibraryWrapper('--None--', '--None--'));
            
             for (ContentWorkspace cw : [SELECT Id, Name FROM ContentWorkspace LIMIT :limits.getLimitQueryRows()]) {
                 refLibrary.add(new ReferenceLibraryWrapper(cw.Id, cw.Name));
            } 
        } catch (Exception e) {
            ApexPages.addmessages(e);
        }  
        return refLibrary;
    }
    
    /**
     * Method to get Reference Language
     */
    @RemoteAction
    public static List<LanguageWrapper> getLanguage() { 
        List<LanguageWrapper> refLanguage;
        
        try { 
            refLanguage = new List<LanguageWrapper>();
            refLanguage.add(new LanguageWrapper('--None--', '--None--')); 
           	Schema.DescribeFieldResult field = Reference_Content__c.Language__c.getDescribe(); //Values FROM Schema
 	 		List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
        
    		for (Schema.PicklistEntry picklistValue : picklistValues) {
            	refLanguage.add(new LanguageWrapper(picklistValue.getValue(), picklistValue.getLabel()));
        	} 
			
        } catch (Exception e) {
            ApexPages.addmessages(e);
        }  
        return refLanguage;
    }
    
    /**
     * Method to get Account Name for contact associations
     */
    @RemoteAction
    public static String getAccountName(String id) {
    	
    	for (Contact rc : [SELECT  Account.Name FROM Contact where Id = :id LIMIT 1]) { 
	            return rc.Account.Name;
        }  
    	return '';
    }
    
    /**
     * Method to delete associations
     */
    @RemoteAction
    public static String deleteRecord(String id, String obj) { 
       	String errMsg = 'Error' + ' ';
       	List<Account_Reference_Content__c> deleteAcc = new List<Account_Reference_Content__c>();
       	List<Contact_Reference_Content__c> deleteCon = new List<Contact_Reference_Content__c>();
       	
        try {
        	
        	if (obj == 'account') {
        	   
	            for (Account_Reference_Content__c rrac : [SELECT Id, Account__c FROM Account_Reference_Content__c WHERE Account__c =:id]) {
	            	deleteAcc.add(rrac);	                
	            }
			
				if (deleteAcc.size() > 0) {
	            	delete deleteAcc;
				}
        	} else {
        		
        		for (Contact_Reference_Content__c rrac : [SELECT Id, Contact__c FROM Contact_Reference_Content__c WHERE Contact__c =:id]) {
	        		deleteCon.add(rrac);	                
	        	}
		
				if (deleteCon.size() > 0) {
		        	delete deleteCon;
				}
        	} 
        } catch (Exception e) { 
            errMsg += CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage()); 
            return errMsg;
        }  
        return 'Success';
    }
    
    /**
     * Method to get Content Details
     */
    @RemoteAction
    public static List<ContentTypeWrapper> getContentDetails(String selectedcontentName) { 
        List<ContentTypeWrapper> contentDetails;  
		contentDetails = new List<ContentTypeWrapper>(); 
		String versionId;
        String contentLibraryId;
        Boolean contentTypeExists = false;
        String title = ''; 
        
        if (selectedcontentName != null && selectedcontentName != '') {
        	
            for (ContentDocument contDoc : [SELECT ParentId, Title, LatestPublishedVersionId FROM ContentDocument
            									WHERE Title = :selectedcontentName]) {
                title = contDoc.Title;
                versionId = contDoc.LatestPublishedVersionId;
                contentLibraryId = contDoc.ParentId; 
            }
            versionId = (versionId != null ? versionId : '');
            String query = 'SELECT Id, Reference_Content_Type__c, Content_Status__c, Language,ContentUrl'; 
            query += ' FROM ContentVersion WHERE Id = :versionId';
            
            for (ContentVersion cv : Database.query(String.escapeSingleQuotes(query))) {  
                contentDetails.add(new ContentTypeWrapper(String.valueOf(cv.get('Reference_Content_Type__c')),String.valueOf(cv.get('Id')), String.valueOf(cv.get('Content_Status__c')),
                										UtilityController.mapContentLanguage.get(String.valueOf(cv.get('Language'))), title, contentLibraryId,String.valueOf(cv.get('ContentUrl'))));
            }  
        }
       	 
	 	return contentDetails; 
    }     
    
    /**
     * Method to get Content Status
     */
    @RemoteAction
    public static List<StatusWrapper> getStatus() { 
        List<StatusWrapper> refStatus;
        
        try { 
            refStatus = new List<StatusWrapper>();
            refStatus.add(new StatusWrapper('--None--', '--None--')); 
           	Schema.DescribeFieldResult field = Reference_Content__c.Content_Status__c.getDescribe(); //Values FROM Schema
 	 		List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
        
    		for (Schema.PicklistEntry picklistValue : picklistValues) {
            	refStatus.add(new StatusWrapper(picklistValue.getValue(), picklistValue.getLabel()));
        	} 
			
        } catch (Exception e) {
            ApexPages.addmessages(e);
        }  
        return refStatus;
    }
    
      
    
    /**
     * Method to delete ref content in case of any error
     */ 
	public void deleteReferenceContent(Id refContentId) {
		
		if (refContentId != null) {
        	List<Reference_Content__c> refContentList = [SELECT Reference_Content_Type__c FROM Reference_Content__c WHERE Id = :refContentId LIMIT 1];
        	
			if (refContentList != null && refContentList.size() > 0) {
				delete refContentList;
			}
        }
	}	  
    /**
     * Method to update ContentVersion 
     */
	private void updateContentVersionObject(String cvId, String contentVersionFields) {  
        ContentVersion cv = new ContentVersion(Id = cvId);
        cv.ContentUrl = contentURL;
        referContent.Content_URL__c = contentURL != null && contentURL.length() > 255 ? contentURL.substring(0,254) : contentURL ;
		referContent.Content_URL2__c = contentURL != null && contentURL.length() > 255 ? contentURL.substring(255) : '';
			
        
        if (!test.isRunningTest()) {
            cv.TagCsv = ((referContent.Search_Terms_keywords__c != null && referContent.Search_Terms_keywords__c != '')
            				? referContent.Search_Terms_keywords__c.trim() : '');
            cv.Description = ((referContent.Summary__c != null && referContent.Summary__c != '')
            			? referContent.Summary__c.substring(0, Math.min(referContent.Summary__c.length(), 1000)) : '');
            cv.Title = referContent.Title__c; 
             
            if (!String.isBlank(contentVersionFields)) {
	        	List<ContentVersionFieldWrapper> lstContentVersion  = (List<ContentVersionFieldWrapper>)JSON.deserialize(contentVersionFields, List<ContentVersionFieldWrapper>.class);
	        	
				for (ContentVersionFieldWrapper lst : lstContentVersion) {
		    				
					if (lst.fieldType == 'BOOLEAN') {
						Boolean flag = false;
						
						if(!String.isBlank(contentVersionFields)) {
							flag = Boolean.valueof(lst.fieldValue); 
						}
						cv.put(lst.apiName, flag);
					} else if (lst.fieldType == 'DATE' || lst.fieldType == 'DATETIME') {  
						
						if (!String.isBlank(lst.fieldValue)) { 
							cv.put(lst.apiName, Date.valueof(lst.fieldValue));
						}
					} else {
						cv.put(lst.apiName, String.valueof(lst.fieldValue));
					}
    			} 
        	}
        
            for (String langKey : UtilityController.mapContentLanguage.keySet()) {
            	
                if (UtilityController.mapContentLanguage.get(langKey) == referContent.Language__c) {
                    cv.Language = langKey;
                }
            }
            //Add Content Types                    
            cv.Reference_Content_Type__c = referContent.Reference_Content_Type__c;
            cv.Content_Status__c = referContent.Content_Status__c;
        }  
    	update cv;
    	referContent.Content_ID__c = cv.id;
    }
    
    /**
     * Method to create ContentVersion 
     */
    private void createContentVersionObject(Boolean isFile, String existingContentDocumentId, String contentVersionFields) {  
        ContentVersion cv = new ContentVersion(); 
        
        if (isFile) {
            cv.VersionData = newfile;
            cv.PathOnClient = newFileName;
            
            if (existingContentDocumentId != '') {
		        cv.ContentDocumentId = existingContentDocumentId;
            }
        } else {
            cv.ContentUrl = contentURL;
            referContent.Content_URL__c = contentURL != null && contentURL.length() > 255 ? contentURL.substring(0,254) : contentURL ;
			referContent.Content_URL2__c = contentURL != null && contentURL.length() > 255 ? contentURL.substring(255) : '';
        }
         	
    	if (existingContentDocumentId == '') {
        	cv.FirstPublishLocationId = referContent.Library_ID__c;
    	}
             
        cv.TagCsv = ((referContent.Search_Terms_keywords__c != null && referContent.Search_Terms_keywords__c != '')
            				? referContent.Search_Terms_keywords__c.trim() : '');
        cv.Description = ((referContent.Summary__c != null && referContent.Summary__c != '')
            					? referContent.Summary__c.substring(0, Math.min(referContent.Summary__c.length(), 1000))
            					: '');
        cv.Title = referContent.Title__c;
        
        if (!String.isBlank(contentVersionFields)) {
        	List<ContentVersionFieldWrapper> lstContentVersion  = (List<ContentVersionFieldWrapper>)JSON.deserialize(contentVersionFields, List<ContentVersionFieldWrapper>.class);
        	
				for (ContentVersionFieldWrapper lst : lstContentVersion) {
	    				
					if (lst.fieldType == 'BOOLEAN') {
						Boolean flag = false;
						
						if(!String.isBlank(contentVersionFields)) {
							flag = Boolean.valueof(lst.fieldValue); 
						}
						cv.put(lst.apiName, flag);
					} else if (lst.fieldType == 'DATE' || lst.fieldType == 'DATETIME') {  
						
						if (!String.isBlank(lst.fieldValue)) { 
							cv.put(lst.apiName, Date.valueof(lst.fieldValue));
						}
					} else {
						cv.put(lst.apiName, String.valueof(lst.fieldValue));
					}
    			} 
        }
         
        for (String langKey : UtilityController.mapContentLanguage.keySet()) {
            	
            if (UtilityController.mapContentLanguage.get(langKey) == referContent.Language__c) {
                    cv.Language = langKey;
            }
        }
        //Add Content Types                    
        cv.Reference_Content_Type__c = referContent.Reference_Content_Type__c;
        cv.Content_Status__c = referContent.Content_Status__c; 
        // REF-1473 Flag set for avoid create duplicate ref content.
        ConstantsController.isRequestFromDM = true;   
       
    	insert cv;
    	 
    	referContent.Content_ID__c = cv.id;
    }
    
 	/**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getPermissionsMessage() {
		checkPermissions();
    	
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * RemoteAction to get insufficient permmission message
     */
    @RemoteAction
    public static String getAssociationPermissions(String obj, String action) {
    	
		if (action == 'INSERT') {
			
			if (obj == 'ACCOUNT') {
				checkPermissionsForInsert(true);			
			} else {
				checkPermissionsForInsert(false);			
			}
		} else {
			if (obj == 'CONTACT') {
				checkPermissionsForDeletion(true);			
			} else {
				checkPermissionsForDeletion(false);			
			}			
		}
    	
    	return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissionsForInsert(Boolean isAccountUpsert) { 
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();  
    	
		if (isAccountUpsert) {
			fieldMap.put(UtilityController.appNamespace() + 'Account_Reference_Content__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Reference_Content__c',
        										UtilityController.appNamespace() + 'Account__c'});
       		return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
		} else {
			fieldMap.put(UtilityController.appNamespace() + 'Contact_Reference_Content__c', new Set<String> { 
        										UtilityController.appNamespace() + 'Reference_Content__c',
        										UtilityController.appNamespace() + 'Contact__c'});
        	return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);  
		} 
    }
    
    /**
     * Method to check Permissions for deletion
     */
    public static Boolean checkPermissionsForDeletion(Boolean isAccountDeletion) {  
    	
    	if (Test.isRunningTest()) {
    		
    		if (isAccountDeletion) {										
    			return CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Account_Reference_Content__c'});
	        } else {
	    	 	return CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Contact_Reference_Content__c'});
	        }
    	} else {
    		return true;
    	}
    } 
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions() {
    	
    	if(Test.isRunningTest()){
	    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
	        fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String> { UtilityController.appNamespace() + 'Content_URL__c',
	        										UtilityController.appNamespace() + 'Content_URL2__c',
	        										UtilityController.appNamespace() + 'Content_ID__c',
	        										UtilityController.appNamespace() + 'Library_ID__c',
	        										UtilityController.appNamespace() + 'Allow_Social_Sharing__c',
	        										UtilityController.appNamespace() + 'Internal_Use__c',
	        										UtilityController.appNamespace() + 'Reference_Content_Type_Name__c',
	        										UtilityController.appNamespace() + 'Custom_Reference_Content__c',
	        										UtilityController.appNamespace() + 'Reference_Content_Type__c'});
	        
	    	Set<String> fieldsAPIName = new Set<String>();
	    	//fieldsAPIName.addAll(contentVersionFieldApiNames);
	    	fieldsAPIName.add(UtilityController.appNamespace() + 'Content_Status__c');
	    	fieldsAPIName.add(UtilityController.appNamespace() + 'Reference_Content_Type__c');
	    	fieldsAPIName.add('Language');
	    	fieldsAPIName.add('TagCsv');
	    	fieldsAPIName.add('Title');
	    	fieldsAPIName.add('ContentUrl');
	    	fieldsAPIName.add('Description');
	        fieldMap.put('ContentVersion', fieldsAPIName);
	        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
	        fieldMap.clear();
	        
	        fieldMap.put(UtilityController.appNamespace() + 'Reference_Content_Type_Field__c', new Set<String> { 
	        										UtilityController.appNamespace() + 'Reference_Content__c' });
	        fieldMap.put(UtilityController.appNamespace() + 'Reference_Note__c', new Set<String> { 
	        										UtilityController.appNamespace() + 'Reference_Content__c' });
	        fieldMap.put(UtilityController.appNamespace() + 'Content_Attribute__c', new Set<String> { 
	        										UtilityController.appNamespace() + 'Reference_Content__c' });
	        fieldMap.put(UtilityController.appNamespace() + 'Account_Reference_Content__c', new Set<String> { 
	        										UtilityController.appNamespace() + 'Reference_Content__c' });
	        fieldMap.put(UtilityController.appNamespace() + 'Contact_Reference_Content__c', new Set<String> { 
	        										UtilityController.appNamespace() + 'Reference_Content__c' });
	        fieldMap.put(UtilityController.appNamespace() + 'Reference_Interview__c', new Set<String> { 
	        										UtilityController.appNamespace() + 'Reference_Content__c' });
	        fieldMap.put(UtilityController.appNamespace() + 'Interview_Topic__c', new Set<String> { 
	        										UtilityController.appNamespace() + 'Reference_Interview__c' });
	        Boolean isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
			Boolean isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Reference_Type_Mapping__c',
                                                                                UtilityController.appNamespace() + 'Reference_Content__c'});
			
	        return (isUpsertPermission && isDeletePermission && isInsertPermission);
    	} else {
    		return true;
    	}
    }
    
    /**
     * Reference ContentType Wrapper Class
     */
	public class ReferenceContentTypeWrapper {
        public String Id { get; set; }
        public String Name { get; set; }
        public Boolean IsReferenceType { get; set; } 
        
        public ReferenceContentTypeWrapper(String id, String name, Boolean isReferenceType) {
            this.Id = id;
            this.Name = name; 
            this.IsReferenceType = isReferenceType;
        }
    }
    
    /**
     * Reference Library Wrapper Class
     */
    public class ReferenceLibraryWrapper {
        public String Id { get; set; }
        public String Name { get; set; } 
        
        public ReferenceLibraryWrapper(String id, String name) {
            this.Id = id;
            this.Name = name; 
        }
    }
    
    /**
     * Reference Language Wrapper Class
     */
    public class LanguageWrapper { 
        public String Name { get; set; } 
        public String Value { get; set; } 
        
        public LanguageWrapper(String value,String name) { 
            this.Name = name; 
            this.Value = value; 
        }
    }
    
    /**
     * Reference Status Wrapper Class
     */
    public class StatusWrapper { 
        public String Name { get; set; } 
        public String Value { get; set; } 
        
        public StatusWrapper(String value,String name) { 
            this.Name = name; 
            this.Value = value; 
        }
    }
   	
   	/**
     * Account Wrapper Class
     */ 
 	public class AccountWrapper { 
        public String Id { get; set; } 
        public String Name { get; set; }
        public Boolean isNewItem { get; set; } 
       	
        public AccountWrapper(String id, String name, Boolean isNew) { 
            this.Id = Id; 
            this.Name = name; 
            this.isNewItem = isNew;
        }        
     }
     
     /**
     * Contact Wrapper Class
     */
     public class ContactWrapper { 
        public String Id { get; set; } 
        public String Name { get; set; }
        public String AccountName { get; set; }
        public Boolean isNewItem { get; set; }  
       	
        public ContactWrapper(String id, String name, String accountName,Boolean isNew) { 
            this.Id = Id; 
            this.Name = name; 
            this.AccountName = accountName;  
            this.isNewItem = isNew;          
        }        
     }
     
 	/**
     * Reference ContentType Wrapper Class
     */
	public class ContentTypeWrapper { 
    	public String RefContent { get; set; }
    	public String Title { get; set; }
    	public String ContentStatus { get; set; }
    	public String Language { get; set; }
    	public String ContentType { get; set; }
    	public String LibraryID { get; set; }
    	public String ContentUrl { get; set; }
    	
	 	public ContentTypeWrapper(String refContent, String contentType, String status, String language, String title, String libId, String url) { 
	 		this.RefContent = refContent;
            this.Title = Title; 
            this.ContentStatus = status; 
            this.Language = language; 
            this.ContentType = contentType;  
            this.LibraryID = libId; 
            this.ContentUrl = url;          
        } 
    }
    
    public class CustomFieldWrapper {
        public String label { get; set; }
        public String apiName { get; set; }
        public String fieldType { get; set; } 
        public String isAccessible { get; set; } 
        public String dateValue { get; set; }
        public List<String> referenceValue { get; set; }
        public String fieldValue { get; set; }
        public Boolean isRequired { get; set; }
		public String objectName { get; set; }
		public String objectLabel { get; set; }
		public List<MultiPicklistWrapper> multiPickOptions { get; set; }
		public List<MultiPicklistWrapper> multiPickAvailOptions { get; set; }
        
        public CustomFieldWrapper(String label, String apiName, String fieldType, String isAccessible, String dateValue, List<String> referenceValue,String value,Boolean isRequired, String objectName, String objectLabel, List<MultiPicklistWrapper> mpListOptions, List<MultiPicklistWrapper> mpListAvailOptions) {
            this.label = label;
            this.apiName = apiName;
            this.fieldType = fieldType; 
            this.isAccessible = isAccessible;
            this.dateValue = dateValue;
            this.referenceValue = referenceValue;
            this.fieldValue = value;
            this.isRequired = isRequired;
			this.objectName = objectName;
			this.objectLabel = objectLabel;
			this.multiPickOptions = mpListOptions;
			this.multiPickAvailOptions = mpListAvailOptions;
        }
    }

	
    // class to get multipicklist options
    public class MultiPicklistWrapper { 
        String value { get; set; }
        String name { get; set; }
        
        public MultiPicklistWrapper(string name,String value) { 
            this.name = name; 
            this.value = value;   
        }
    }
    
    public class ContentVersionFieldWrapper {
        public String label { get; set; }
        public String apiName { get; set; }
        public String fieldType { get; set; }  
        public String dateValue { get; set; } 
     	public List<String> referenceValue { get; set; }
        public String fieldValue { get; set; }
        public Boolean isRequired { get; set; }
        
        public ContentVersionFieldWrapper(String label, String apiName, String fieldType, String dateValue,String value, List<String> referenceValue, Boolean isRequired) {
            this.label = label;
            this.apiName = apiName;
            this.fieldType = fieldType;  
            this.dateValue = dateValue;
            this.fieldValue = value;
            this.referenceValue = referenceValue;
            this.isRequired = isRequired; 
        }
    }
    
    /**
     * Reference PageParameter Wrapper Class
     */
    public class PageParameterWrapper { 
        public String Title { get; set; } 
        public String LibraryID { get; set; }
        public String ContentStatus { get; set; }
        public String Language { get; set; }
        public String ContentType { get; set; } 
        public String ContentURL { get; set; } 
        public String OldContentURL { get; set; }
        public Boolean IsCustomContentType { get; set; }
        public String SubAccount { get; set; }
        public Boolean IsInternalUse { get; set; }
        public Boolean IsAllowingSharing { get; set; }
        public Boolean IsFeatureContent { get; set; }
       	public String PublishedDate { get; set; }
       	public String ReviewDate { get; set; }
       	public String ExpirationDate { get; set; }
       	public String PublicationName { get; set; }
       	public String Author { get; set; }
       	public String ArticalPublishDate { get; set; }
       	public String SearchItem { get; set; }
       	public String Summery { get; set; }
       	public String ExternalSummery { get; set; }
       	public Boolean IsReferenceType { get; set; }
       	public Boolean IsClone { get; set; }
       	public String NativeContentType { get; set; }  
        
        public PageParameterWrapper(String refStatus, String language, String refContent, String libId) {
        	this.LibraryID = libId;
        	this.ContentStatus = refStatus;
        	this.Language = language;
        	this.ContentType = refContent;
            //REF-2401
            this.PublishedDate = DateTime.now().format('MM/dd/yyyy');
   		}
        public PageParameterWrapper(String title, String libraryId,String contentStatus, String language, String contentType, String contentURL, Boolean isCustomContentType,
        					String subAccount, Boolean internalUse, Boolean allowingSharing, Boolean featureContent, Date publishedDate, Date reviewDate, Date expriationDate,
        					String publicationName, String author, Date articalDate, String searchItem, String summey, String externalSummery, Boolean isReferenceType, String contentId) {

			//REF-2289
            if (contentURL == 'null') {
                contentURL = null;
            }
			this.Title = title;
			this.LibraryID = libraryId;
	        this.ContentStatus = contentStatus; 
	        this.Language = language;
	        this.ContentType = contentType; 
	        this.ContentURL = contentId == null ? '' : contentURL;
	        this.OldContentURL = contentURL;
	        this.IsCustomContentType = isCustomContentType;
	        this.SubAccount = subAccount;
	        this.IsInternalUse = internalUse;
	        this.IsAllowingSharing = allowingSharing;
	        this.IsFeatureContent = featureContent;
	       	this.PublishedDate = (publishedDate != null) ? DateTime.newInstance(publishedDate.year(), publishedDate.month(), publishedDate.day()).format('MM/dd/yyyy') : ''; 
	       	this.ReviewDate = (reviewDate != null) ? DateTime.newInstance(reviewDate.year(), reviewDate.month(), reviewDate.day()).format('MM/dd/yyyy') : ''; 
	       	this.ExpirationDate = (expriationDate != null) ? DateTime.newInstance(expriationDate.year(), expriationDate.month(), expriationDate.day()).format('MM/dd/yyyy') : '';  
	       	this.PublicationName = publicationName;
	       	this.Author = author;
	       	this.ArticalPublishDate = (articalDate != null) ? DateTime.newInstance(articalDate.year(), articalDate.month(), articalDate.day()).format('MM/dd/yyyy') : ''; 
	       	this.SearchItem = searchItem;
	       	this.Summery = summey;
	       	this.ExternalSummery = externalSummery;
	       	this.IsReferenceType = isReferenceType; 
	       	this.NativeContentType = contentId;    						
        }
    }
}