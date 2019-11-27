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
 * VF Page: AddNewReferenceContent.page
 * Description: Controller for creating new reference records or editing existing records.
 * Modified by: Rekha @Feb 3 2017
 */
public with sharing class AddNewReferenceContentController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables 
     */
    public Reference_Content__c referContent { get; set; }
    public Boolean isNewReferContent { get; set; }
    
    //list to store the name of the libraries for the custom pick list 
    public List<SelectOption> libraries { get; set; }
    
    //Custom Content Types picklist
    public List<SelectOption> CustomRefcontentTypes { get; set; }
    public String newFileName { get; set; }
    public transient blob newfile { get; set; }
    public Boolean CustomRefContent { get; set; }
    public Boolean RecordedRefContent { get; set; }
    public Boolean IscontentURL { get; set; }
    public Boolean IsContentType { get; set; }
    public Boolean IsFileType { get; set; }
    public Boolean IsCustomContentType { get; set; }
    public Boolean IsRecordedContentType { get; set; }
    public string ContentURL { get; set; }
    public Map<String, Boolean> customContentTypeFieldsMap { get; set; }
    public List<String> customContentTypeFields { get; set; }
    public Boolean internalUse { get; set; }
    public string customReferenceContentTypeId { get; set; }
    public List<SelectOption> customReferenceContentType { get; set; }
    public string contentTitleNames { get; set; }  
    // changes for #592 by Gaurav Saini (8 Dec, 2016)
    public String libraryId { get; set; }
    public string selectedcontentName { get; set; }
    public Reference_Content_Type_Field__c refContentField { get; set; }
    private Set<String> fieldMappingsDelete;
    private Set<String> fieldsPresentOnRefContentType;
    public ContentVersion tempContentVersion { get; set; }
    private Map<String, Schema.SObjectField> fldObjMap;
    public List<String> contentVersionFieldApiNames { get; set; }
    public Boolean showLibrary { get; set; }
    public Boolean IsReferenceType { get; set; }
    public Id refContentId { get; set; } 
    public Boolean isError { get; set; }
    public Boolean isAllowAssociation { get; set; }
    //Clone
    public String isReferenceContentClone { get; set; }
    private List<Reference_Note__c> referenceNotes = new List<Reference_Note__c>();
    private List<Account_Reference_Content__c> associatedAccounts = new List<Account_Reference_Content__c>();
    private List<Contact_Reference_Content__c> associatedContacts = new List<Contact_Reference_Content__c>();
    private List<Content_Attribute__c> contentAttributes = new List<Content_Attribute__c>();
    private List<Reference_Interview__c> referenceInterviews = new List<Reference_Interview__c>();
    private List<Interview_Topic__c> interviewTopics = new List<Interview_Topic__c>();
    public Boolean isSLDS { get; set; }
    // re #1041 - Added return URL 
    public string returnUrl { get; set; }
    public Boolean isExistingContnet { get; set; }
    //REF-2401
    public String tempPublishdate { get; set; }

    /**
     * Constructor
     */
    public AddNewReferenceContentController(ApexPages.StandardController controller) {
    	if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') {
            system.debug('*********SF1');
            isSLDS = true;
        } else {
            system.debug('********normal');
            isSLDS = false;
        }
       
        if (!isSLDS) {
	        isNewReferContent = true; 
	        isReferenceContentClone = Apexpages.Currentpage().getparameters().get('clone'); 
	        
	        // re #1041 - check and get return URL
         	if (ApexPages.currentPage().getParameters().get('retURL') != null) {
		        returnUrl = ApexPages.currentPage().getParameters().get('retURL');
	        } else {
		        returnUrl = System.URL.getSalesforceBaseURL().toExternalForm();
	        }
            
            //REF-2401
	        tempPublishdate = '';
	        customContentTypeFields = new List<String>();
	        referContent = (Reference_Content__c)controller.getRecord();
	        CustomRefcontentTypes = new List<SelectOption>();
	        libraries = new List<SelectOption>();
	        tempContentVersion = new ContentVersion();
	        contentVersionFieldApiNames = new List<String>();
	        IscontentURL = true;
	        IsContentType = true;
	        IsFileType = true;
	        internalUse = false;
	        IsCustomContentType = true;
	        IsRecordedContentType = true;
	        showLibrary = true;
	        IsReferenceType = false;
	        fieldsPresentOnRefContentType = new Set<String>();
	        customReferenceContentType = new List<SelectOption>();
	        refContentField = new Reference_Content_Type_Field__c();
	        selectedcontentName = '';
	        Custom_Settings__c cs = UtilityController.getCustomSettings();
	        Set<String> setContentFields = new Set<String>();
	        isExistingContnet = false;
	        checkPermissions();
	        
	        if (cs.Manage_ContentVersion_Custom_Fields__c != null) {
	            
	            for (String str : cs.Manage_ContentVersion_Custom_Fields__c.split(',')) {
	                setContentFields.add(str.trim());
	            }
	        }
	        // FROM the Object API name retrieving the sObject
	        Schema.SObjectType targetType1 = CRUDAndFLSCheckController.sObjectsMap.get('ContentVersion');
	        Sobject Object_name1 = targetType1.newSObject();
	        // grab the sobject that was passed
	        Schema.sObjectType sobject_type1 = Object_name1.getSObjectType();
	        Schema.DescribeSObjectResult sobject_describe1 = sobject_type1.getDescribe();
	        
	        for (String str : sobject_describe1.fields.getMap().keyset()) {
	            Schema.DescribeFieldResult sField = sobject_describe1.fields.getMap().get(str).getDescribe();
	            
	            if (sField.isCreateable() && sField.isCustom()
		                && sField.getName() != UtilityController.appNamespace() + 'Reference_Content_Type__c'
		                && sField.getName() != UtilityController.appNamespace() + 'Content_Status__c') {
	                
	                if ((sField.isCreateable() && !sField.isNillable() && !sField.isDefaultedOnCreate()) || setContentFields.contains(sField.getName())) { 
	                    contentVersionFieldApiNames.add(sField.getName());
	    			}
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
	        CustomRefContent = false;
	        
	        if (referContent.Id != null) { 
	            // changes for #444 - new field "External Summary" added
	            referContent = [SELECT Allow_Social_Sharing__c, Featured_Content__c, Substitute_Account_Name__c,
	            					Reference_Content_Type_Name__c, Custom_Reference_Content__c, Reference_Content_Type__c,
	            					Reference_Content_Type__r.Recorded_Reference_Type__c, Reference_Content_Type__r.Name__c,
	            					Internal_Use__c, Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c,
	            					Publish_date__c, Publication_name__c, Library_ID__c, Language__c,
	            					Expiration_Date__c, Created_User_Name__c, Content_URL__c, Content_URL2__c, Content_Status__c,
	            					Content_ID__c, Author__c, Article_publication_date__c, External_Summary__c
	            					FROM Reference_Content__c
	            					WHERE Id = :referContent.Id LIMIT 1];
	            
	            isNewReferContent = false;
	            IsReferenceType = referContent.Reference_Content_Type__r.Recorded_Reference_Type__c;
	            
	            if (isReferenceContentClone == '1') {
	            	
	            	// Clone reference notes
	            	for(Reference_Note__c rn : [SELECT Note__c, Note_Date__c, Reference_Content__c FROM Reference_Note__c
	            								WHERE Reference_Content__c = :referContent.Id]) {
	            		referenceNotes.add(rn.clone(false, true));
	            	}
	            	
	            	// Clone associated accounts
	            	for(Account_Reference_Content__c arc : [SELECT Account__c, Reference_Content__c FROM Account_Reference_Content__c
	            											WHERE Reference_Content__c = :referContent.Id]) {
	            		associatedAccounts.add(arc.clone(false, true));
	            	}
	            	
	            	// Clone associated contacts
	            	for(Contact_Reference_Content__c crc : [SELECT Contact__c, Reference_Content__c FROM Contact_Reference_Content__c
	            											WHERE Reference_Content__c = : referContent.Id]) {
	            		associatedContacts.add(crc.clone(false, true));
	            	}
	            	
	            	// Clone Content Attribute
	            	for(Content_Attribute__c ca : [SELECT Account__c, Attribute__c, From_Account__c, Is_fromMapping__c, Reference_Content__c
	            									FROM Content_Attribute__c
	            									WHERE Reference_Content__c = :referContent.Id
	            									AND Is_fromMapping__c = false
	            									AND From_Account__c = false]) {
	            		contentAttributes.add(ca.clone(false, true));
	            	}
	            	
	            	// Clone Reference Interview
	            	for(Reference_Interview__c ri : [SELECT Transcript__c, Transcript_Content_Id__c, SystemModstamp, Speaker_info__c,
	        											Reference_Content__c, Photograph__c, Org_website__c, Org_description__c, Name,
	        											(SELECT Question__c, Transcript__c, Order__c, Content_Id__c, Content_File__c,
	        												Active__c, Language__c, Length__c, Reference_Interview__c, Interview_Question__c,
	        												Video_URL__c, Video_Url_Embed__c
	        												FROM Interview_Topics__r)
	    												FROM Reference_Interview__c
	    												WHERE Reference_Content__c = :referContent.Id]) {
	            		referenceInterviews.add(ri.clone(false, true));
	            		
	            		for (Interview_Topic__c it : ri.Interview_Topics__r) {
	            			interviewTopics.add(it.clone(false, true));
	            		}
	            	}
	            	referContent = referContent.clone(false, true);
	            	isNewReferContent = true;
	            	referContent.Content_ID__c = null;
	            	referContent.Content_URL__c = null;
					referContent.Content_URL2__c = null;
	            }
	            internalUse = referContent.Internal_Use__c;
	            
	            for (Reference_Content_Type__c rc : [SELECT Name__c, Active__c, Id FROM Reference_Content_Type__c
	        											WHERE Id = :referContent.Reference_Content_Type__c]) {
	                customReferenceContentType.add(new SelectOption(rc.Id, rc.Name__c));
	            }
	            
	            if (!referContent.Reference_Content_Type__r.Recorded_Reference_Type__c) {
	                
	                for (Reference_Content_Type__c rc : [SELECT Name__c, Active__c, Id FROM Reference_Content_Type__c
	            											WHERE Active__c = true
	            											AND Id != :referContent.Reference_Content_Type__c
	            											AND Recorded_Reference_Type__c = false
	            											ORDER BY Name__c]) {
	                    customReferenceContentType.add(new SelectOption(rc.Id, rc.Name__c));
	                }
	            }
	            
	            for (ContentWorkspace cw : [SELECT Id, name FROM ContentWorkspace
	            							WHERE Id = :referContent.Library_ID__c ORDER BY Name
	            							LIMIT :limits.getLimitQueryRows()]) {
	                libraries.add(new SelectOption(cw.Id, cw.Name));
	            }
	            
	            if (referContent.Content_ID__c != null) {
	                IsCustomContentType = false;
	                IsRecordedContentType = false;
	                ContentURL = referContent.Content_URL__c + (referContent.Content_URL2__c == null ? '' : referContent.Content_URL2__c);
                    
                    //REF-2289
                    if (ContentURL == 'null') {
                        ContentURL = null;
                    }
	                selectedcontentName = referContent.Title__c;
	                String query = 'SELECT Id ';
	                
	                for (String fieldName : contentVersionFieldApiNames) {
	                    query += ', ' + fieldName;
	                }
	                query += ' FROM ContentVersion WHERE Id = \'' + String.escapeSingleQuotes(referContent.Content_ID__c) + '\'';
	                
	                for (ContentVersion cv : database.query(query)) {
	                    tempContentVersion = cv;
	                }
	                
	                if (referContent.Content_URL__c != null || (referContent.Content_URL2__c != null && referContent.Content_URL2__c != '')) {
	                    IscontentURL = true;
	                    IsContentType = false;
	                    IsFileType = false;
	                } else {
	                    IscontentURL = false;
	                    IsContentType = false;
	                    IsFileType = true;
	                }
	            } else if (referContent.Custom_Reference_Content__c) {
	                IscontentURL = false;
	                IsContentType = false;
	                IsFileType = false;
	                IsRecordedContentType = false;
	                IsCustomContentType = false;
	                CustomRefContent = true;
	                string refContentId = referContent.Id;
	                showLibrary = false;
	                customContentTypeFieldsMap = new Map<String, Boolean>();
	                
	                for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Order__c, Required__c, Reference_Content_Type__c, Name
	                										FROM Reference_Type_Mapping__c
	                										WHERE Reference_Content_Type__c = :referContent.Reference_Content_Type__c
	                										AND Visible__c = true
	                										ORDER BY Order__c NULLS LAST, Name]) {
	                    
	                    if (rtm.Required__c) {
	                        customContentTypeFieldsMap.put(rtm.Name, true);
	                    } else {
	                        customContentTypeFieldsMap.put(rtm.Name, false);
	                    }
	                    customContentTypeFields.add(rtm.Name);
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
	            } else if (referContent.Reference_Content_Type__r.Recorded_Reference_Type__c) {
	                IscontentURL = false;
	                IsContentType = false;
	                IsFileType = false;
	                IsRecordedContentType = false;
	                IsCustomContentType = false;
	                // added for #592 - not showing Library picklist if the ref content is of interview type
	                showLibrary = false;
	            }
	        } else {
	        	// added for #592 - adding a none option to the list of available libraries
		        libraries.add(new SelectOption('', '--None--'));
	        	
	            for (ContentWorkspace cw : [SELECT Id, Name FROM ContentWorkspace LIMIT :limits.getLimitQueryRows()]) {
	                libraries.add(new SelectOption(cw.Id, cw.Name));
	            }
	            customReferenceContentType.add(new SelectOption('', '--None--'));
	            
	            for (Reference_Content_Type__c rc : [SELECT Name__c, Active__c, Id FROM Reference_Content_Type__c
	            										WHERE Active__c = true ORDER BY Name__c]) {
	                customReferenceContentType.add(new SelectOption(rc.Id, rc.Name__c));
	            }
	        }
        }
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
    	
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
    	fieldsAPIName.addAll(contentVersionFieldApiNames);
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
    }
    
    /**
     * Method to find ContentVersion details
     */
    public void findContentVersionDetails() {
    	
        try {
        	
            if (selectedcontentName != null && selectedcontentName != '') {
                contentTitleNames = '';
                string titleName = selectedcontentName.replace('\\', '\\\\');
                titleName = '%' + titleName + '%';
                
                for (ContentDocument cd : [SELECT Title FROM ContentDocument
                							WHERE Title LIKE :titleName AND PublishStatus != 'R'
                							LIMIT 100]) {
					
                    if (contentTitleNames == '') {
                        contentTitleNames = cd.Title;
                    } else {
                        contentTitleNames = contentTitleNames + ',' + cd.Title;
                    }
                }
            }
        } catch (Exception e) {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
            Apexpages.addMessage(message);
        }
    }
    
    /**
     * Method to save the Content
     */
    public PageReference saveContent() {   
    	 
    	if (checkPermissions()) {
    		isError = false;
    	  
    	 	/*if (uploadedFileJSON != null) {
            	newfile = EncodingUtil.base64Decode(uploadedFileJSON);
    	 	}*/  
	        ConstantsController.createRefContentRecord = false;
	        transient List<ContentVersion> contentObject = new List<ContentVersion>();
	        
	        // changes for #592 - adding a validation if user saves without selecting a library for ref content
	        //						if it is not custom content or interview type
	        if (libraryId == null || libraryId == '') {
	        	
	        	if (!CustomRefContent && !IsReferenceType) {
	        		ApexPages.addMessage(new ApexPages.Message(Apexpages.severity.Error, System.Label.SELECT_LIBRARY));
	        		isError = true;
	        		return null;
	        	}
	        } else {
		        referContent.Library_ID__c = libraryId;
	        }
			if (referContent.Summary__c != null && referContent.Summary__c.length() > 4000) {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Summary_Limit);
	            Apexpages.addMessage(message);
	            isError = true;
	            return null;
	        }
	        String versionId;
	         
	        //re #358
	        if (newfile == null && (ContentURL == null || ContentURL.trim() == '')
	        			&& selectedcontentName.trim() == '' && !CustomRefContent && !IsReferenceType) {
	        	ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.UPLOAD_CONTENT_OR_URL);
	            Apexpages.addMessage(message);
	            isError = true;
	            return null;
	        } else {

				// REF-1467	
				if (newfile != null) {
					referContent.Is_File_Changed__c = true;
				} else if (ContentURL != null && ContentURL.trim() != '' && ContentURL.length() > 510) {
					ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, 'Content URL too long : data value too large(Max length = 510)');
					Apexpages.addMessage(message);
					isError = true;
					return null;
				}     	
	            
	            if (referContent.Id != null) {
	            	List<Attachment> attachmentsList = [SELECT ParentId, Name, Id, Body FROM Attachment
														WHERE Name = 'documentThumbnail.jpg' AND ParentId = :referContent.Id];
					if (attachmentsList != null && attachmentsList.size() > 0) {
						delete attachmentsList;
					}
	            }
	        }
	        
	        if (customReferenceContentTypeId == null || customReferenceContentTypeId == '') {
	            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.SELECT_REFERENCE_CONTENT_TYPE);
	            Apexpages.addMessage(message);
	            isError = true;
	            return null;
	        }
			
	        // changes for #30 - not allowing the user to activate the ref content while saving a new ref interview type record
	        if (IsReferenceType && referContent.Content_Status__c == 'Active') {
	        	Boolean isRefContentValid = false;
	        	
	        	if (referContent.Id != null && string.valueOf(referContent.Id) != '') {
	    			List<Reference_Interview__c> tempList2 = [SELECT Id, Reference_Content__c,
				        										(SELECT Id, Reference_Interview__c, Video_Url_Embed__c
				        											FROM Interview_Topics__r)
				    											FROM Reference_Interview__c
				    											WHERE Reference_Content__c = :referContent.Id];
	        		
	        		if (tempList2 != null && tempList2.size() > 0) {
	        			Reference_Interview__c tempRefInterview = tempList2[0];
	        			
	        			if (tempRefInterview.Interview_Topics__r != null && tempRefInterview.Interview_Topics__r.size() > 0) {
	        				
	        				for (Interview_Topic__c it : tempRefInterview.Interview_Topics__r) {
	        					
	        					if (it.Video_Url_Embed__c != null && it.Video_Url_Embed__c != '') {
	        						isRefContentValid = true;
	        						break;
	        					}
	        				}
	        			}
	        		}
	        	}
	        	
	        	if (!isRefContentValid) {
		        	ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Restrict_Ref_Interview_Record_Without_Video);
		            Apexpages.addMessage(message);
		            isError = true;
		            return null;
	        	}
	        }
	        referContent.Reference_Content_Type__c = customReferenceContentTypeId;
	        referContent.Custom_Reference_Content__c = CustomRefContent;
	        
	        // this field is populated to be helpful in refSearch
	        for (SelectOption so : customReferenceContentType) {
	        	
	            if (so.getValue() == customReferenceContentTypeId) {  
	                referContent.Reference_Content_Type_Name__c = so.getLabel();
	            }
	        }
	        
	        if (referContent.Internal_Use__c) {
	            referContent.Allow_Social_Sharing__c = false;
	        }
	        
	        if (referContent.Allow_Social_Sharing__c) {
	            referContent.Internal_Use__c = false;
	        }
	        Savepoint sp = Database.setSavepoint();
	        
	        try {
	            
	            if (!CustomRefContent) {
	                
	                // for edit purpose & clone
	                if (referContent.Id != null && referContent.Content_ID__c != null && referContent.Content_ID__c != '') { 
	                	List<ContentVersion> lstContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :referContent.Content_ID__c];
	                	
	                	//re #1041 - Check for content version list
	                	if (lstContentVersion.size() > 0) {
		                	ContentVersion cv = lstContentVersion[0];
		                    contentObject = [SELECT Id, TagCsv, Description, Language, Content_Status__c, Title,
		                    					ContentDocumentId, Reference_Content_Type__c, PathOnClient, FirstPublishLocationId
		                    					FROM ContentVersion
		                    					WHERE ContentDocumentId = :cv.ContentDocumentId
		                    					AND IsLatest = true];
							referContent.Content_ID__c = contentObject[0].Id; 
	                		referContent.Content_URL2__c = referContent.Content_URL2__c == null ? '' : referContent.Content_URL2__c;
		                    if (newfile != null || ((referContent.Content_URL__c != null && referContent.Content_URL__c + '' + referContent.Content_URL2__c != ContentURL) || referContent.Content_URL__c != ContentURL)) {
		                	
		                        if (newfile != null) {
		                            createContentVersionObject(true, contentObject[0].ContentDocumentId);
		                        } else if (referContent.Content_URL__c != null && referContent.Content_URL__c != '' && referContent.Content_URL__c + referContent.Content_URL2__c != ContentURL) {
	                                updateContentVersionObject(contentObject[0].Id);
		                        }
		                    } else {
		                    	
		                        if (!test.isRunningTest() && contentObject.size() > 0) {
		                            updateContentVersionObject(contentObject[0].Id);
		                        }
		                    }
	                	}
	                } else {		
	                	
	                	//for new RefContent record
	                    if (newfile != null) {
	                        createContentVersionObject(true, '');
	                    } else if (ContentURL != null && ContentURL != '' && isExistingContnet != true) {
	                        createContentVersionObject(false, '');
	                    } else if (selectedcontentName != null && selectedcontentName != '') {
	                        String title;
	                        
	                        for (ContentDocument contDoc : [SELECT ParentId, Title, LatestPublishedVersionId FROM ContentDocument 
	                        								WHERE Title = : selectedcontentName LIMIT: limits.getLimitQueryRows()]) {
	                            referContent.Content_ID__c = contDoc.LatestPublishedVersionId;
	                            versionId = contDoc.LatestPublishedVersionId;
	                            referContent.Library_ID__c = contDoc.ParentId;
	                        }
	                        
	                        for (Reference_Content__c oldReferContent : [SELECT Content_ID__c FROM Reference_Content__c
                    														LIMIT :limits.getLimitQueryRows()]) {
	                        	 
	                            //if the content is associated with another reference content then display an error that content is already associated 
	                            //with another reference content
	                            if (referContent.Content_ID__c == oldReferContent.Content_ID__c) {
	                                selectedcontentName = null;
	                                ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.Select_Another_Content);
	                                Apexpages.addMessage(message);
	                                isError = true;
	                                return null;
	                            }
	                        }
	                        
	                        if (referContent.Content_ID__c != null) {
	                            contentObject = [SELECT Title, FirstPublishLocationId,ContentUrl, Reference_Content_Type__c,
	                            					Id, ContentDocumentId, Content_Status__c, Language
	                            					FROM ContentVersion WHERE Id = :versionId LIMIT 1];
                				
	                            if (contentObject.size() > 0) {
	                                updateContentVersionObject(contentObject[0].Id);
	                            }
	                        }
	                    }
	                }
	                upsert referContent;
	            } else {
	            	
	                if (customContentTypeFieldsMap != null) {
	                	
	                    for (String fieldName : customContentTypeFieldsMap.keySet()) {
	                    	
	                        if (customContentTypeFieldsMap.get(fieldName) && (refContentField.get(fieldName) == null || refContentField.get(fieldName) == '')) {
	                            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.FILL_REQUIRED_FIELDS);
	                            Apexpages.addMessage(message);
	                            isError = true;
	                            return null;
	                        }
	                    }
		                upsert referContent;
		                
	                    if (refContentField.Reference_Content__c == null) {
	                        refContentField.Reference_Content__c = referContent.Id;
	                    }
	                    upsert refContentField;
	                } else {
		                upsert referContent;
	                }
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
	            //If cloning
	            if (isReferenceContentClone == '1') {
	            	
	                //Insert reference notes
	                for (Reference_Note__c record : referenceNotes) {
						record.Reference_Content__c = referContent.id;
					}
					insert referenceNotes;
					
					//Insert content attributes
					for (Content_Attribute__c record : contentAttributes) {
						record.Reference_Content__c = referContent.id;
					}
					insert contentAttributes;
					
					//Insert associated accounts
					for (Account_Reference_Content__c record : associatedAccounts) {
						record.Reference_Content__c = referContent.id;
					}
					insert associatedAccounts;
					
					//Insert associated contacts
					for (Contact_Reference_Content__c record : associatedContacts) {
						record.Reference_Content__c = referContent.id;
					}
					insert associatedContacts;    
	
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
	            
	            if (isAllowAssociation != null && isAllowAssociation) {
	            	return new Pagereference(Page.AddAssociatedAccountsAndContacts.getUrl() + '?refConId='+referContent.id); 
	            } else { 
	            	return new Pagereference('/' + referContent.id);
	            }
	            
	        } catch (exception e) { 
				
				//	REF-1814
				if(!e.getMessage().contains(system.label.DC_Reference_Content_Type)) {
					ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, e.getMessage());
					Apexpages.addMessage(message);
				}
	            database.rollback(sp);
	            isError = true;
	            return null;
	        }
        } else {
        	return null;
        }
    }
    
    /**
     * Method to create ContentVersion 
     */
    private void createContentVersionObject(Boolean isFile, String existingContentDocumentId) {
        ContentVersion cv = new ContentVersion();
        
        if (isFile) {
            cv.VersionData = newfile;
            cv.PathOnClient = newFileName;
            
            if (existingContentDocumentId != '') {
		        cv.ContentDocumentId = existingContentDocumentId;
            }
        } else {
            cv.ContentUrl = ContentURL;
            referContent.Content_URL__c = ContentURL != null && ContentURL.length() > 255 ? ContentURL.substring(0,254) : ContentURL ;
			referContent.Content_URL2__c = ContentURL != null && ContentURL.length() > 255 ? ContentURL.substring(255) : '';
        }
        
        if (!test.isRunningTest()) {
        	
        	if (existingContentDocumentId == '') {
            	cv.FirstPublishLocationId = referContent.Library_ID__c;
        	}
            	
            cv.TagCsv = ((referContent.Search_Terms_keywords__c != null && referContent.Search_Terms_keywords__c != '')
            				? referContent.Search_Terms_keywords__c.trim() : '');
            cv.Description = ((referContent.Summary__c != null && referContent.Summary__c != '')
            					? referContent.Summary__c.substring(0, Math.min(referContent.Summary__c.length(), 1000))
            					: '');
            cv.Title = referContent.Title__c;
            
            for (String fieldName : contentVersionFieldApiNames) {
                cv.put(fieldName, tempContentVersion.get(fieldName));
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
       
    	insert cv;
    	referContent.Content_ID__c = cv.id;
    }
    
    /**
     * Method to update ContentVersion 
     */
    private void updateContentVersionObject(string cvId) {
        ContentVersion cv = new ContentVersion(Id = cvId);
        cv.ContentUrl = ContentURL;
        referContent.Content_URL__c = ContentURL != null && ContentURL.length() > 255 ? ContentURL.substring(0,254) : ContentURL ;
		referContent.Content_URL2__c = ContentURL != null && ContentURL.length() > 255 ? ContentURL.substring(255) : '';
		
        if (!test.isRunningTest()) {
            cv.TagCsv = ((referContent.Search_Terms_keywords__c != null && referContent.Search_Terms_keywords__c != '')
            				? referContent.Search_Terms_keywords__c.trim() : '');
            cv.Description = ((referContent.Summary__c != null && referContent.Summary__c != '')
            			? referContent.Summary__c.substring(0, Math.min(referContent.Summary__c.length(), 1000)) : '');
            cv.Title = referContent.Title__c;
            
            for (String fieldName : contentVersionFieldApiNames) {
                cv.put(fieldName, tempContentVersion.get(fieldName));
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
     * Method to change the Library options
     */
    public void changeLibraryOptions() {   
        String versionId;
        String contentLibraryId;
        Boolean contentTypeExists = false;
        isNewReferContent = true;
        
        if (selectedcontentName != null && selectedcontentName != '') {
        	
            for (ContentDocument contDoc : [SELECT ParentId, Title, LatestPublishedVersionId FROM ContentDocument
            									WHERE Title = :selectedcontentName]) {
                referContent.Title__c = contDoc.Title;
                versionId = contDoc.LatestPublishedVersionId;
                contentLibraryId = contDoc.ParentId;
                libraries = new List<SelectOption>();
                // added for #592 - adding a none option to the list of available libraries
	        	//libraries.add(new SelectOption('', '--None--'));
                isNewReferContent = false;
            }
            versionId = (versionId != null ? versionId : '');
            String query = 'SELECT Id, Reference_Content_Type__c, Content_Status__c, Language, ContentUrl';
            
            for (String fieldName : contentVersionFieldApiNames) {
                query += ',' + fieldName;
            }
            query += ' FROM ContentVersion WHERE Id = :versionId';
            
            for (ContentVersion cv : Database.query(String.escapeSingleQuotes(query))) {
                tempContentVersion = cv;
                customReferenceContentTypeId = String.valueOf(cv.get('Reference_Content_Type__c'));
                referContent.Content_Status__c = String.valueOf(cv.get('Content_Status__c'));
                referContent.Language__c = UtilityController.mapContentLanguage.get(String.valueOf(cv.get('Language')));
                // re #REF-1600 : Content URL added in case of existing contnet.
                ContentURL =  String.valueOf(cv.get('ContentUrl'));
            }
            
            for (ContentWorkspace cw : [SELECT Id, Name FROM ContentWorkspace WHERE Id = :contentLibraryId
            							ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
                libraries.add(new SelectOption(cw.Id, cw.Name));
            }
            
            isExistingContnet = true;
        }
        disableOptions();
    }
    
    /**
     * Method to disable options
     */
    public void disableOptions() {
        IscontentURL = true;
        IsContentType = true;
        IsFileType = true;
        IsRecordedContentType = true;
        IsCustomContentType = true;
        
        if (newFileName != null) {
            IscontentURL = false;
            IsContentType = false;
            IsFileType = true;
            IsRecordedContentType = false;
            IsCustomContentType = false;
        } else if (ContentURL != null && ContentURL != '') {
            IscontentURL = true;
            IsContentType = false;
            IsFileType = false;
            IsRecordedContentType = false;
            IsCustomContentType = false;
        } else if (selectedcontentName != null && selectedcontentName != '') {
            IscontentURL = false;
            IsContentType = true;
            IsFileType = false;
            IsRecordedContentType = false;
            IsCustomContentType = false;
        } else if (CustomRefContent) {
            IscontentURL = false;
            IsContentType = false;
            IsFileType = false;
            IsRecordedContentType = false;
            IsCustomContentType = true;
        }
        //REF-2401
        if (!String.isBlank(tempPublishdate)) {
        	referContent.Publish_date__c = convertToDate(tempPublishdate); 
        } else {
            referContent.Publish_date__c = Date.today();
        }
    }
    
    /**
     * Method to show custom Content Fields
     */
    public PageReference showCustomContentFields() {
        string customRefContentName;
        
        for (SelectOption so : customReferenceContentType) {
        	
            if (so.getValue() == customReferenceContentTypeId) {
                customRefContentName = so.getLabel();
            }
        }
        
        if (customReferenceContentTypeId == null || customReferenceContentTypeId == '') {
            ApexPages.Message message = new ApexPages.message(ApexPages.severity.ERROR, System.Label.SELECT_REFERENCE_CONTENT_TYPE);
            Apexpages.addMessage(message);
            return null;
        } else {
            List<Reference_Content_Type__c> rcts = [SELECT Recorded_Reference_Type__c
            										FROM Reference_Content_Type__c WHERE Id = :customReferenceContentTypeId];
			
            if (rcts.size() > 0) {
            	
                if (rcts[0].Recorded_Reference_Type__c) { 
                    showLibrary = false;
                    IscontentURL = false;
                    IsContentType = false;
                    IsFileType = false;
                    IsRecordedContentType = false;
                    IsCustomContentType = false;
                    newfile = null;
                    ContentURL = '';
                    selectedcontentName = '';
                    CustomRefContent = false;
                    customContentTypeFieldsMap = new Map<String, Boolean>();
                    customContentTypeFields = new List<String>();
                    internalUse = false;
                    referContent.Internal_Use__c = false;
                    IsReferenceType = true;
                    return null;
                } else {
                	IsReferenceType = false;
                }
                
                if (CustomRefContent) {
                    showLibrary = false;
                    IscontentURL = false;
                    IsContentType = false;
                    IsFileType = false;
                    IsRecordedContentType = false;
					internalUse = true;
                    referContent.Internal_Use__c = true;
					referContent.Allow_Social_Sharing__c = false;
                    referContent.Reference_Content_Type__c = customReferenceContentTypeId;
                    customContentTypeFieldsMap = new Map<String, Boolean>();
                    customContentTypeFields = new List<String>();
                    fieldMappingsDelete = new Set<String>();
                    
                    for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Order__c, Required__c, Reference_Content_Type__c, Name
															FROM Reference_Type_Mapping__c
															WHERE Reference_Content_Type__c = :customReferenceContentTypeId
															AND Visible__c = true
															ORDER BY Order__c, Name]) {
                        customContentTypeFieldsMap.put(rtm.Name, rtm.Required__c);
                        customContentTypeFields.add(rtm.Name);
                    }
                    
                    for (String fieldName : customContentTypeFieldsMap.keySet()) {
                    	
                        if (!fieldsPresentOnRefContentType.contains(fieldName)) {
                            fieldMappingsDelete.add(fieldName);
                        }
                    }
                    
                    for (String fieldName : fieldMappingsDelete) {
                        customContentTypeFieldsMap.remove(fieldName);
                        integer listCount = 0;
                        integer position = 0;
                        
                        for (String field : customContentTypeFields) {
                        	
                            if (field == fieldName) {
                                position = listCount;
                            }
                            ++listCount;
                        }
                        customContentTypeFields.remove(position);
                    }
                } else {
                    internalUse = false;
                    referContent.Internal_Use__c = false;
                    customContentTypeFieldsMap = new Map<String, Boolean>();
                    customContentTypeFields = new List<String>();
                    disableOptions();
                    showLibrary = true;
                }
            }
        }
        return null;
    }
    
    /**
     * Method to hide Social sharing
     */
    public void hideSocialSharing() {
    	
        if (referContent.Internal_Use__c) {
            internalUse = true;
        } else {
            internalUse = false;
        }
    }
    
    //REF-2401
    public void setPublishDate() {
        referContent.Publish_date__c = convertToDate(tempPublishdate);
    }
    
    public Date convertToDate(String dateString) {
        List<String> dateValues = dateString.split('/');
        return date.newInstance(Integer.valueOf(dateValues[2]), Integer.valueOf(dateValues[0]), Integer.valueOf(dateValues[1]));
    }
}