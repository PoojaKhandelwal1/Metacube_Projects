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
 * VF Page: RfSearchPage.page
 * Description: Controller for content section on ref search page
 * Last modified by: Rajesh @JUNE 13 2017 -#659
 */
 
public with sharing class ContentSearchController {
    /**
     * Properties and variables
     */
    public Set<String> selectedContentIdSet;
    public String character { get; set; }
    public Boolean isContentShared { get; set; }
    public Boolean isContentSelected { get; set; }
    public List<String> alphabets { get; set; }
    private String inputTextValue;
    private transient AttributeWrapper attributeWrapper;
    public Integer pageLimit { get; set; }
    public Integer contentSize { get; set; }
    public Integer pageIndex { get; set; }
    public Integer LAST_PAGE = 0;
    public Boolean isNextRender { get; set; }
    public Set<String> contentIds { get; set; }
    //added for R14.87 start
    public String sharableContent { get; set; }
    //added for R14.87 end
    public Boolean showAlertMessage { get; set; } 
    public Map<Integer, Set<Id>> mapContent { get; set; }
    public Map<Id, ContentVersion> mapContentVersion { get; set; }
    public Map<String, String> filterLogic { get; set; }
    public Boolean featuredChecked { get; set; }
    public Set<Id> accountIdSet { get; set; }
    public Map<String, List<ContentLanguageWrapper>> mapContentLanguages { get; set; }
    public String selectedContentLanguageName { get; set; }
    public Map<String, List<ContentTypeWrapper>> mapContentTypes { get; set; }
    public String selectedContentTypeName { get; set; }
    public String hoverContentId { get; set; }
    public String hoverRefContentId { get; set; }
    public ContentVersion hoverContentVersion { get; set; }
    public Boolean customRefContent { get; set; }
    public Set<String> customContentFields;
    public List<Reference_Interview__c> refInterview { get; set; }
    public Reference_Interview__c refInterviewRecord { get; set; }
    public Map<String, Boolean> customContentTypeFieldsMap { get; set; }
    public List<Reference_Content_Type_Field__c> refContentFields { get; set; }
    public Map<String, Schema.SObjectField > fldObjMap;
    public String referenceContentTitle { get; set; }
    public List<String> customContentTypeFields { get; set; }
    public String selectContentDocumentId { get; set; } 
    public transient Custom_Settings__c cs;
    // added for #1135 - Gaurav Saini (5 Dec, 2017)
    public Set<String> allContentIds { get; set; }
    // Added new field for REF-1306
    public String internalSummary { get; set; }
    public Map<String,FieldWrapper> mapCustomContentLabels { get; set; }
    
    //Re #1354 - New variable added for maintain state 
    public Boolean isRefInterviewType { get; set; } 
    public Boolean isCustomContent { get; set; } 
    public Boolean isContentVersionId { get; set; } 
    /**
     * Constructor
     */
    public ContentSearchController() {
    	//Check User premission 
    	//checkPermissions(true, 'All'); 
        isContentShared = false;
        refInterview = new List<Reference_Interview__c>();
        inputTextValue = '';
        character = '';
        selectedContentTypeName = '';
        featuredChecked = false;
        isContentSelected = false;
        refContentFields = new List<Reference_Content_Type_Field__c>();
        customContentFields = new Set<String>();
        customContentTypeFields = new List<String>();
        mapCustomContentLabels = new Map<String,FieldWrapper>();
        selectedContentIdSet = new Set<String>();
        cs = UtilityController.getCustomSettings();
        fldObjMap = schema.SObjectType.Reference_Content_Type_Field__c.fields.getMap();
        
        for (String str : fldObjMap.keyset()) {
        	
            if (fldObjMap.get(str).getDescribe().isCreateable() && fldObjMap.get(str).getDescribe().isCustom() 
            					&& fldObjMap.get(str).getDescribe().getName() != UtilityController.appNamespace() + 'Reference_Content__c') {
                customContentFields.add(fldObjMap.get(str).getDescribe().getName());
                //Added custom labels REF-1306
                mapCustomContentLabels.put(fldObjMap.get(str).getDescribe().getName(),new FieldWrapper(fldObjMap.get(str).getDescribe().getName(), fldObjMap.get(str).getDescribe().getLabel(), String.valueOf(fldObjMap.get(str).getDescribe().getType())));
            }
        }
        alphabets = new List<String> {
            'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', System.Label.other, System.Label.All
        };
        reset();
    }
    
    /**
     * Method to set featured checkbox
     */
    public void setTheFeaturedCheckbox() {
        featuredChecked = !featuredChecked;
        reset();
    }
    
    /**
     * getter for default page size
     */
    public Integer PAGE_SIZE {
        get {
        	
            if (PAGE_SIZE == null) {
                PAGE_SIZE = 5;
            }
            return PAGE_SIZE;
        }
        set;
    }
    
    /**
     * getter for show more page size
     */
    public Integer SHOWMORE_PAGE_SIZE {
        get {
            
            if (SHOWMORE_PAGE_SIZE == null)
                SHOWMORE_PAGE_SIZE = 25;
            return SHOWMORE_PAGE_SIZE;
        }
        set;
    }
    
    /**
     * getter to Content Page Block Limit Exceed
     */
    public Boolean isContentLimitExceed {
        get {
            
            if (isContentLimitExceed == null) {
                isContentLimitExceed = false;
            }
            return isContentLimitExceed;
        }
        set;
    }
    
    /**
     * getter to show More Content Records
     */
    public Boolean showMoreContentRecords {
        get {
           
            if (showMoreContentRecords == null) {
                showMoreContentRecords = false;
            }
            return showMoreContentRecords;
        }
        set;
    }

    /**
     * Method to RESET values
     */
    public void reset() {
        isContentSelected = false;
        contentSize = 0;
        isNextRender = true;
        pageIndex = 1;
        pageLimit = PAGE_SIZE;
        LAST_PAGE = 0;
        filterLogic = new Map<String, String>();
        contentIds = new Set<String>(); 
        mapContent = new Map<Integer, Set<Id>>();
        mapContentVersion = new Map<Id, ContentVersion>();
    }

    /**
     * Method Return list of contents to RE Search Page
     */
    public List<ConetntWrapper> listContents(String searchTextValue, AttributeWrapper attriWrappController,
    											Set<String> contentIds, Boolean mappingSelected,
    											Custom_Settings__c customSettings, Boolean isExportClicked) {
        List<ConetntWrapper> listData = new List<ConetntWrapper>();
        cs = customSettings;
        inputTextValue = searchTextValue;
        attributeWrapper = attriWrappController;
        
        try {
        	
        	if (isExportClicked) {
        		listData = searchRefrenceContents(contentIds, mappingSelected, isExportClicked);
        	} else {
        		
	            // Check if map contains values
	            if (mapContent.containsKey(pageIndex) && pageIndex != 1) {
	            	
	                if (mapContent.get(pageIndex).size() < pageLimit) {
	                    isNextRender = false;
	                    isContentLimitExceed = false;
	                } else {
	                    isContentLimitExceed = true;
	                }
	                listData = getContentsNavigation(mapContent.get(pageIndex));
	            } else {
	            	listData = searchRefrenceContents(contentIds, mappingSelected, isExportClicked);
	            	
	            	if (listData.isEmpty() && mapContent.containsKey(pageIndex)) {
	            		
	            		if (mapContent.get(pageIndex).size() < pageLimit) {
		                    isNextRender = false;
		                    isContentLimitExceed = false;
		                } else {
		                    isContentLimitExceed = true;
		                }
	            		listData = getContentsNavigation(mapContent.get(pageIndex));
	            	}
	            }
        	}
            return listData;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    
   /**
    * This method is use to get Content for Next and Previous (Pagination)
    * @param idSet {Set < String >}
    * @return contWrapList {List<ConetntWrapper>}
    **/
    public List<ConetntWrapper> getContentsNavigation(Set<Id> idSet) {  
		Set<String> tempContentIds = new Set<String>();		
		List<ConetntWrapper> contWrapList = new List<ConetntWrapper>();		
		List<Reference_Content__c> listRefContent = new List<Reference_Content__c>();		
        String query = ' SELECT Id, Name, Featured_Content__c, Reference_Content_Type__r.Recorded_Reference_Type__c,';
        query += ' Reference_Content_Type__r.Custom_Content_Type__c, Number_of_Download__c,Custom_Reference_Content__c,';
        query += ' Attributes__c, Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c, Language__c,';
        query += ' Publish_date__c, Reference_Content_Type_Name__c,';
        query += ' Internal_Use__c, Expiration_Date__c,Reference_Content_Type__c, Reference_Content_Type__r.Name__c,';
        query += ' Content_Status__c, Content_ID__c, Allow_Social_Sharing__c, ';
        query += ' (SELECT Id, Account__c, Account__r.Name From Account_Reference_Contents__r LIMIT 2)';
        query += ' From Reference_Content__c WHERE Id  IN :idSet AND (Content_Status__c != \'Inactive\' AND Content_Status__c != \'\')';
        
        //start change for R14.87
        if (!isContentShared && sharableContent != null && sharableContent != '') {
        	query += ' AND Internal_Use__c = ' + String.escapeSingleQuotes(sharableContent);	
        }
        
        //end change for R14.87        
        if (featuredChecked) {
            query += ' AND Featured_Content__c = true';
        }
        
        if (cs.Show_Featured_Content_First__c) {
            query += ' ORDER BY Featured_Content__c DESC, Title__c ASC LIMIT 2001';
        } else {
            query += ' ORDER BY Title__c ASC LIMIT 2001';
        }
        listRefContent = WithoutSharingHelperController.getReferenceContent(query, idSet);//Database.query(query);
        
        //re #520 - Check content size and set page content limit.
        if (listRefContent != NULL && listRefContent.size() > pageLimit) { 
        	pageLimit = listRefContent.size();
        } 
        
        Integer contentCount = 0;
        
        for (Reference_Content__c rc : listRefContent) {
        	
            if (contentCount < pageLimit) {
                //changed because of the custom content : new requirement
                contentIds.add(rc.Id);
                tempContentIds.add(rc.Content_ID__c);
                contentCount++;
            } else {
                break;
            }
        } 													 
        mapContentVersion = WithoutSharingHelperController.getContentVersionMapForInvitation(tempContentIds);
        
        if (!mapContent.containskey(pageIndex)) {
            mapContent.put(pageIndex, new Set<Id>());
        }
        
        for (Reference_Content__c rc : listRefContent) { 
        	
            if (contWrapList.size() == pageLimit) {
                isContentLimitExceed = true;
                break;
            }
            String AccountName = '';
            String AccountId = '';
            
            if (rc.Account_Reference_Contents__r.size() == 0) {
                AccountName = '';
                AccountId = '';
            } else if (rc.Account_Reference_Contents__r.size() == 1) {
                AccountName = rc.Account_Reference_Contents__r[0].Account__r.Name;
                AccountId = '/' + rc.Account_Reference_Contents__r[0].Account__r.Id;
            } else {
                AccountName = System.Label.Multiple_Accounts;
                AccountId = Page.AssociatedRefContAccounts.geturl() + '?refContentId=' + rc.Id;
            }
            
            ConetntWrapper cw = null;
            
            if (mapContentVersion.containsKey(rc.Content_ID__c)) {
                cw = new ConetntWrapper(rc, mapContentVersion.get(rc.Content_ID__c), AccountName, AccountId);
            } else {
                cw = new ConetntWrapper(rc, new ContentVersion(), AccountName, AccountId);
            }
           
            if (cw != null && selectedContentIdSet != null && selectedContentIdSet.contains(rc.Id)) { 
            	cw.isSelected = true;
            }
            
            if (cw != null && selectContentDocumentId != null && selectContentDocumentId.contains(rc.Id)) { 
        		cw.isSelected = true;
	        } 
            contWrapList.add(cw);  
        }  
        return contWrapList;
	}
	
	/**
    * This method is use to get reference contents for Specific Account
    * @param accId {Account Ids}
    * @return contWrapList {List<ConetntWrapper>}
    **/
    public List<ConetntWrapper> getContentsForAccount(Id contentId) {   
    	List<ConetntWrapper> contWrapList = new List<ConetntWrapper>();	
    	List<Account_Reference_Content__c> ARCList = WithoutSharingHelperController.getARCsForAccount(contentId);
    	Set<String> refContentIds = new Set<String>();
    	Set<String> contentVersionIds = new Set<String>();  
    
    	if (ARCList != null && ARCList.size() > 0) {
        
        	for (Account_Reference_Content__c ARC : ARCList) {
            	refContentIds.add(ARC.Reference_Content__c);
        	}
        	List<Reference_Content__c> refContentList = WithoutSharingHelperController.getRefContentForAccount(refContentIds);
        
        	if (refContentList != null && refContentList.size() > 0) {
            
                for (Reference_Content__c refContent : refContentList) {
		            contentVersionIds.add(refContent.Content_ID__c);
                }
            	// changes for #786 - moved query to w/o sharing
        		Map<Id, ContentVersion> mapContentVersion = WithoutSharingHelperController.getContentVersionMapForInvitation(contentVersionIds);
				
				for (Reference_Content__c rc : refContentList) {
					String AccountName = '';
		            String AccountId = '';
		            
		            if (rc.Account_Reference_Contents__r.size() == 0) {
		                AccountName = '';
		                AccountId = '';
		            } else if (rc.Account_Reference_Contents__r.size() == 1) {
		                AccountName = rc.Account_Reference_Contents__r[0].Account__r.Name;
		                AccountId = '/' + rc.Account_Reference_Contents__r[0].Account__r.Id;
		            } else {
		                AccountName = System.Label.Multiple_Accounts;
		                AccountId = Page.AssociatedRefContAccounts.geturl() + '?refContentId=' + rc.Id;
		            }
		            
		            ConetntWrapper cw = null;
		            
		            if (mapContentVersion.containsKey(rc.Content_ID__c)) {
		                cw = new ConetntWrapper(rc, mapContentVersion.get(rc.Content_ID__c), AccountName, AccountId);
		            } else {
		                cw = new ConetntWrapper(rc, new ContentVersion(), AccountName, AccountId);
		            }
		           
		            if (cw != null && selectedContentIdSet != null && selectedContentIdSet.contains(rc.Id)) { 
		            	cw.isSelected = true;
		            }
		            
		            if (cw != null && selectContentDocumentId != null && selectContentDocumentId.contains(rc.Id)) { 
		        		cw.isSelected = true;
			        } 
		            contWrapList.add(cw);  
				}
        	} 
    	}  
        return contWrapList;
	}
	

    /**
     * Search refrence Contents 
     */
    public List<ConetntWrapper> searchRefrenceContents(Set<String> relatedContentIds, Boolean mappingSelected, Boolean isExportClicked) {
    	List<Reference_Content__c> listRefContent = new List<Reference_Content__c>();        
        List<ConetntWrapper> contWrapList = new List<ConetntWrapper>();        
        Set<String> tempContentIds = new Set<String>();
        
        if (!showMoreContentRecords) {
            pageLimit = PAGE_SIZE;
        }
        
        if (showMoreContentRecords && pageIndex == 1) {
            pageLimit = SHOWMORE_PAGE_SIZE;
        }
        
        if (!mapContent.containsKey(pageIndex) || isExportClicked) {
            
            if (inputTextValue.trim().length() == 0 && !isAttributeSelected() && selectedContentTypes.size() == 0 && selectedContentLanguages.size() == 0 && !mappingSelected) {
                String query = ' SELECT Id, Name,Featured_Content__c , Reference_Content_Type__r.Recorded_Reference_Type__c,';
                query += ' Reference_Content_Type__r.Custom_Content_Type__c, Number_of_Download__c,Custom_Reference_Content__c,';
                query += ' Attributes__c, Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c, Language__c,';
                query += ' Publish_date__c, Reference_Content_Type_Name__c,';
                query += ' Internal_Use__c, Expiration_Date__c,Reference_Content_Type__c, Reference_Content_Type__r.Name__c,';
                query += ' Content_Status__c, Content_ID__c, Allow_Social_Sharing__c, ';
                query += ' (Select Id, Account__c, Account__r.Name FROM Account_Reference_Contents__r LIMIT 2)';
                query += ' FROM Reference_Content__c WHERE Id NOT IN :contentIds AND (Content_Status__c != \'Inactive\' AND Content_Status__c != \'\')';
                
                //start change for R14.87
                if (sharableContent != null && sharableContent != '') {
                	query += ' AND Internal_Use__c = ' + String.escapeSingleQuotes(sharableContent);
                }//end change for R14.87
                
                if (featuredChecked) {
                    query += ' AND Featured_Content__c = true';
                }
                
                // changes for #1135 - Gaurav Saini (5 Dec, 2017)
                if (cs.Show_Featured_Content_First__c) {
                    
                    if (isExportClicked) {
                    	query += ' ORDER BY Featured_Content__c DESC, Title__c ASC LIMIT ' + Limits.getLimitQueryRows();
                    } else {
                    	query += ' ORDER BY Featured_Content__c DESC, Title__c ASC LIMIT 2001';
                    }
                } else {
                	
                	if (isExportClicked) {
                		query += ' ORDER BY Title__c ASC LIMIT ' + Limits.getLimitQueryRows();
                	} else {
                		query += ' ORDER BY Title__c ASC LIMIT 2001';
                	}
                }
                listRefContent = WithoutSharingHelperController.getReferenceContent(query,contentIds); 
            } else {
                Integer filterKey = 0;
                Map<Integer, Set<String>> mapFillterIds = new Map<Integer, Set<String>>();
                
                //Check text Selected or not and if selected fill the in the Map
                if (relatedContentIds.size() > 0) {
                    filterKey = filterKey + 1;
                    mapFillterIds.put(filterKey, relatedContentIds);
                }
                
                if (inputTextValue.trim().length() != 0) {
                    filterKey = filterKey + 1;
                    mapFillterIds.put(filterKey, filterBySearchText());
                }                
               
				//Check Attribute Selected or not and if selected fill the in the Map
                if (isAttributeSelected()) {
                    filterKey = filterKey + 1;
                    mapFillterIds.put(filterKey, filterByContentAttribute());
                }                
                
                //Check Attribute Selected or not and if selected fill the in the Map
                if (selectedContentTypes.size() > 0) {
                    filterKey = filterKey + 1;
                    mapFillterIds.put(filterKey, filterByContentType());
                }                
                
                //Check Attribute Selected or not and if selected fill the in the Map
                if (selectedContentLanguages.size() > 0) {
                    filterKey = filterKey + 1;
                    mapFillterIds.put(filterKey, filterByContentLanguage());
                }                
                //Filter the common Content ID's
                Map<String, Integer> mapFilterContentIds = new Map<String, Integer>();
                
                for (Set<String> strSet : mapFillterIds.values()) {
                    
                    for (String str : strSet) {
                        
                        if (!mapFilterContentIds.containskey(str)) {
                            mapFilterContentIds.put(str, 1);
                        } else {
                            Integer incrementVal = mapFilterContentIds.get(str) + 1;
                            mapFilterContentIds.put(str, incrementVal);
                        }
                    }
                }
                Set<String> commonFilterIds = new Set<String>(); 
                
                for (String str : mapFilterContentIds.keySet()) {
                    
                    if (mapFilterContentIds.get(str) == mapFillterIds.size()) {
                        commonFilterIds.add(str);
                    }
                }
                //Query for common Ids
                String query = 'SELECT Id, Name,Featured_Content__c , Attributes__c, Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c, Language__c,  Publish_date__c,';
                query += ' Internal_Use__c, Expiration_Date__c,Reference_Content_Type__c, Number_of_Download__c,Reference_Content_Type_Name__c,';
                query += ' Reference_Content_Type__r.Name__c, Reference_Content_Type__r.Recorded_Reference_Type__c,Custom_Reference_Content__c,';
                query += ' Reference_Content_Type__r.Custom_Content_Type__c, Content_Status__c, Content_ID__c,';
                query += ' Allow_Social_Sharing__c,(SELECT Id, Account__c, Account__r.Name FROM Account_Reference_Contents__r LIMIT 2)';
                query += ' FROM Reference_Content__c WHERE Id IN :commonFilterIds AND Id NOT IN: contentIds  AND (Content_Status__c != \'Inactive\' AND Content_Status__c != \'\')';
                
                //start change for R14.87
                if (sharableContent != null && sharableContent !=  '') {
                	query += ' AND Internal_Use__c = ' + String.escapeSingleQuotes(sharableContent);
                }//end change for R14.87
                
                if (featuredChecked) {
                    query += ' AND Featured_Content__c = true';
                }
                
                // changes for #1135 - Gaurav Saini (5 Dec, 2017)
                if (cs.Show_Featured_Content_First__c) {
                    
                    if (isExportClicked) {
                    	query += ' ORDER BY Featured_Content__c DESC, Title__c ASC LIMIT ' + Limits.getLimitQueryRows();
                    } else {
                    	query += ' ORDER BY Featured_Content__c DESC, Title__c ASC LIMIT 2001';
                    }
                } else {
                	
                	if (isExportClicked) {
                		query += ' ORDER BY Title__c ASC LIMIT ' + Limits.getLimitQueryRows();
                	} else {
                		query += ' ORDER BY Title__c ASC LIMIT 2001';
                	}
                }
                listRefContent = WithoutSharingHelperController.getReferenceContent(query, contentIds, commonFilterIds); 
            }
            
            // added for #1135 - Gaurav Saini (5 Dec, 2017)
            if (isExportClicked) {
	            allContentIds = new Set<String>();
	            
	            for (Reference_Content__c rc : listRefContent) {
	            	allContentIds.add(rc.Id);
	            }
	            allContentIds.addAll(contentIds);
            }
            
            if (pageIndex == 1) {
                contentSize = listRefContent.size();
            }
                
            if (listRefContent.size() == pageLimit) {
                LAST_PAGE = pageIndex;
                isNextRender = false;
            }
            
            Integer contentCount = 0;
            
            for (Reference_Content__c rc : listRefContent) {
                
                if (contentCount < pageLimit) {
                    //changed because of the custom content : new requirement
                    contentIds.add(rc.Id);
                    tempContentIds.add(rc.Content_ID__c);
                    contentCount++;
                } else {
                    break;
                }
            }
             
            mapContentVersion = WithoutSharingHelperController.getContentVersionMapForInvitation(tempContentIds);													
            isContentLimitExceed = false;
            
            if (!mapContent.containskey(pageIndex)) {
                mapContent.put(pageIndex, new Set<Id>());
            }
            
            for (Reference_Content__c rc : listRefContent) {
                
                if (mapContent.get(pageIndex).size() == pageLimit) {
                    isContentLimitExceed = true;
                    break;
                }
                String AccountName = '';
                String AccountId = '';
               
                if (rc.Account_Reference_Contents__r.size() == 0) {
                    AccountName = '';
                    AccountId = '';
                } else if (rc.Account_Reference_Contents__r.size() == 1) {
                    AccountName = rc.Account_Reference_Contents__r[0].Account__r.Name;
                    AccountId = '/' + rc.Account_Reference_Contents__r[0].Account__r.Id;
                } else {
                    AccountName = System.Label.Multiple_Accounts;
                    AccountId = Page.AssociatedRefContAccounts.geturl() + '?refContentId=' + rc.Id;
                }
                
                mapContent.get(pageIndex).add(rc.id);
                
                ConetntWrapper cwT = null;
                
                if (mapContentVersion.containsKey(rc.Content_ID__c)) {
                    cwT = new ConetntWrapper(rc, mapContentVersion.get(rc.Content_ID__c), AccountName, AccountId);
                } else {
                    cwT = new ConetntWrapper(rc, new ContentVersion(), AccountName, AccountId);
                } 
                
               	if (cwT != null && selectedContentIdSet != null && selectedContentIdSet.contains(rc.Id)) {
            		cwT.isSelected = true;
		        }
		         
		       	if (cwT != null && selectContentDocumentId != null && selectContentDocumentId.contains(rc.Id)) {
            		cwT.isSelected = true;
		        }  
		       
		        contWrapList.add(cwT); 
            }
            
            if (showMoreContentRecords && mapContent.get(pageIndex).size() < pageLimit) {
                LAST_PAGE = pageIndex;
                isNextRender = false;
            }
        }
        
        if (contWrapList != null && contWrapList.size() > 0) {
        	return contWrapList;
        } else {
        	return new List<ConetntWrapper>();
        }
    }
    
    /**
     * Method to Check list in map "mapAttributesLabels" Null or not
     */
    private Boolean isAttributeSelected() {
        Boolean attributeSelected = false;
        
        for (String labelId : attributeWrapper.mapAttributesLabels.keyset()) {
            
            if (attributeWrapper.mapAttributesLabels.get(labelId).size() > 0) {
                attributeSelected = true;
                break;
            }
        }
        return attributeSelected;
    }
    
    /**
     * Method to Refrence Contents ID values for Text 
     */
    public Set<String> filterBySearchText() {
        Set<String> refContentIds = new Set<String>();        
        
        if (inputTextValue.trim().length() == 0 || inputTextValue.trim().length() == 1) {
            return refContentIds;
        }
        Set<String> contentIds = new Set<String>();
        Set<String> contentIdsFromRefContent = new Set<String>();
        String SOSLQuery = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING ContentVersion(Id), ' + UtilityController.appNamespace() + 'Reference_Content__c(Id, Content_ID__c), ' + UtilityController.appNamespace() + 'Reference_Content_Type_Field__c(Reference_Content__c, Id)';
        List<List<SObject>> searchList = search.query(SOSLQuery);
        List<ContentVersion> listContentVersion = searchList[0];
        List<Reference_Content__c> listReferenceContent = searchList[1];
        List<Reference_Content_Type_Field__c> listrctf = searchList[2];
        
        for (ContentVersion cv : listContentVersion) {
            contentIds.add(cv.id);
        }
        
        for (Reference_Content__c rc : listReferenceContent) {
            
            if (rc.Content_ID__c != null && rc.Content_ID__c != '') {
                contentIdsFromRefContent.add(rc.Content_ID__c);
            }
        }
        
        for (Reference_Content_Type_Field__c rctf : listrctf) {
            refContentIds.add(rctf.Reference_Content__c);
        }
        Boolean textSetIds = contentIds.addAll(contentIdsFromRefContent);
        
        if (contentIds.size() > 0 || listReferenceContent.size() > 0) {
            
            for (Reference_Content__c rc : WithoutSharingHelperController.getReferenceContent(contentIds, listReferenceContent)) {
                refContentIds.add(rc.id);
            }
        }
        
        if (accountIdSet != null && accountIdSet.size() > 0) {
            
            for (Account_Reference_Content__c c : WithoutSharingHelperController.getAccountContent(refContentIds, accountIdSet)) { 
                refContentIds.add(c.Reference_Content__c);
            }
        }
        return refContentIds;
    }
    
    /**
     * Method to Refrence Contents ID values for selected Content language
     */
    public Set<String> filterByContentLanguage() {
        Set<String> refContentIds = new Set<String>();        
        
        if (selectedContentLanguages.size() == 0) {
            return refContentIds;
        }
        String contentLanguageValues = '';
        
        for (ContentLanguageWrapper scl : selectedContentLanguages) {
            
            if (filterLogic.containsKey('Content Language') && filterLogic.get('Content Language') == 'And') {
				
                if (contentLanguageValues == '')  {
                    contentLanguageValues = 'Language__c = \'' + scl.contentLanguageName + '\'';
                } else {
                    contentLanguageValues = contentLanguageValues + ' AND Language__c = \'' + scl.contentLanguageName + '\'';
                }
            } else {
            	
                if (contentLanguageValues == '') {
                    contentLanguageValues = 'Language__c = \'' + scl.contentLanguageName + '\'';
                } else {
                    contentLanguageValues = contentLanguageValues + ' OR Language__c = \'' + scl.contentLanguageName + '\'';
                }
            }
        }
        String refContentQuery = 'SELECT Id, Name, Content_ID__c,Custom_Reference_Content__c FROM Reference_Content__c WHERE ' + contentLanguageValues;
        
        for (Reference_Content__c rc : WithoutSharingHelperController.getReferenceContent(refContentQuery)) {  
            refContentIds.add(rc.id);
        }
        return refContentIds;
    }
    
    /**
     * Method to Refrence Contents ID values for selected Content types
     */
    public Set<String> filterByContentType() {
        Set<String> refContentIds = new Set<String>();
        
        if (selectedContentTypes.size() == 0) {
            return refContentIds;
        }
        String contentTypeValues = '';
        
        for (ContentTypeWrapper sct : selectedContentTypes) {
            
            if (filterLogic.containsKey('Content Types') && filterLogic.get('Content Types') == 'And') {
                
                if (contentTypeValues == '') {
                    contentTypeValues = 'Reference_Content_Type__r.Name__c = \'' + sct.contentTypeName + '\'';
                } else {
                    contentTypeValues = contentTypeValues + ' AND Reference_Content_Type__r.Name__c = \'' + sct.contentTypeName + '\'';
                }
            } else {
            	
                if (contentTypeValues == '') {
                    contentTypeValues = 'Reference_Content_Type__r.Name__c = \'' + sct.contentTypeName + '\'';
                } else {
                    contentTypeValues = contentTypeValues + ' OR Reference_Content_Type__r.Name__c = \'' + sct.contentTypeName + '\'';
                }
            }
        }
        String refContentQuery = 'SELECT Id, Name, Custom_Reference_Content__c, Content_ID__c FROM Reference_Content__c WHERE ' + contentTypeValues;
        
        for (Reference_Content__c rc : WithoutSharingHelperController.getReferenceContent(refContentQuery)) {//;Database.query(refContentQuery)) {
            refContentIds.add(rc.id);
        }
        return refContentIds;
    }
    
    /**
     * Method to return Refrence Contents ID for selected Attribute
     */
    public Set<String> filterByContentAttribute() {
        Set<String> refContentIds = new Set<String>();
        //Map for Search Content
        Map<Label__c, Set<String>> mapLabelContentAttrString = new Map<Label__c, Set<String>>();
        //Itrate selected attribute
        Set<Id> attributeTypeIds = new Set<Id>();
        
        for (Label__c label : attributeWrapper.getAttributeLabels()) {
            
            if (attributeWrapper.mapAttributesLabels.get(label.Id).size() > 0) {
                
                for (attributeWrapper.AttributesLabelWrapper atw : attributeWrapper.mapAttributesLabels.get(label.Id)) {
                    attributeTypeIds.add(atw.attributeLabel.Attribute__c);
                }
                mapLabelContentAttrString.put(label, new Set<String>());
            }
        }
        //Map List of Attributes form selected label 
        Map<Id, Attribute__c> mapAttribute = new Map<Id, Attribute__c> ([SELECT Id FROM Attribute__c WHERE Id IN :attributeTypeIds]);
        Map<String, List<Attribute__c>> mapLabelAttribute = new Map<String, List<Attribute__c>>();
		
        for (Attributes_Labels__c attrLabel : WithoutSharingHelperController.getAttributeLable(attributeTypeIds)) { 
            
            if (!mapLabelAttribute.containskey(attrLabel.Label__c)) {
                mapLabelAttribute.put(attrLabel.Label__c, new List<Attribute__c>());
            }
            mapLabelAttribute.get(attrLabel.Label__c).add(mapAttribute.get(attrLabel.Attribute__c));
        }
        //Map Attribute id & List Content Attribute
        Map<String, List<Content_Attribute__c>> mapContentAttribute = new Map<String, List<Content_Attribute__c>>();
      	Map<String, Set<String>> refContentAttributes = new Map<String, Set<String>>();
        
        for (Content_Attribute__c contAttr : WithoutSharingHelperController.getContentAttribute(attributeTypeIds)) {
		             
            if (!mapContentAttribute.containskey(contAttr.Attribute__c)) {
                mapContentAttribute.put(contAttr.Attribute__c, new List<Content_Attribute__c>());
            }
            mapContentAttribute.get(contAttr.Attribute__c).add(contAttr);
            
            if (!refContentAttributes.containsKey(contAttr.Reference_Content__c)) {
                refContentAttributes.put(contAttr.Reference_Content__c, new Set<String>());
            }
            refContentAttributes.get(contAttr.Reference_Content__c).add(contAttr.Attribute__c);
        }
        
        for (String contentId : refContentAttributes.keySet()) {
            Set<String> attIds = new Set<String>();
            Integer recordMatchingCondition = 0;
            
            for (String labelId : mapLabelAttribute.keySet()) {
                
                if (mapLabelAttribute.get(labelId).size() > 0) {
                    attIds.addAll(refContentAttributes.get(contentId));
                    
                    if (filterLogic.containsKey(labelId) && filterLogic.get(labelId) == 'And') {
                        Boolean recordMatched = false;
                        
                        for (Attribute__c att : mapLabelAttribute.get(labelId)) {
                            
                            if (!attIds.contains(att.Id)) {
                                recordMatched = true;
                                break;
                            }
                        }
                        
                        if (!recordMatched) {
                            ++recordMatchingCondition;
                        }
                    } else {
                        
                        for (Attribute__c att : mapLabelAttribute.get(labelId)) {
                            
                            if (attIds.contains(att.Id)) {
                                ++recordMatchingCondition;
                                break;
                            }
                        }
                    }
                }
            }
            
            if (recordMatchingCondition != 0 && recordMatchingCondition == mapLabelAttribute.size()) {
                refContentIds.add(contentId);
            } else if (mapLabelAttribute.size() == 0) {
                refContentIds.add(contentId);
            }
        }
        return refContentIds;
    }
    
    /**
     * Method to previous Link
     */
    public Pagereference previous() {
        setContents();
        
        if (pageIndex != 1) {
            pageIndex = pageIndex - 1;
            isNextRender = true;
        }
        System.debug('previous '+pageIndex);
        return null;
    }
    
    /**
     * Method to next Link
     */
    public Pagereference next() { 
       	setContents();
       	
        if (pageIndex != LAST_PAGE) {
            pageIndex = pageIndex + 1;
        } else {
            isNextRender = false;
        }
        system.debug('next '+pageIndex);
        return null;
    }
    
    /**
     * Reset Selected Content Ids -#659
     */
    public void setContents() {
    	 
        if (selectContentDocumentId != null && selectContentDocumentId != '') {
	        selectedContentIdSet.clear(); 
	        
	        for (String docId : selectContentDocumentId.split(',')) {
	        	selectedContentIdSet.add(docId);
	        }
        } else {
        	selectedContentIdSet.clear();
        }  
    }
    /**
     * Method to downLoad Files
     */
    public PageReference downloadContents() {
        showAlertMessage = false;
        List<String> idSetContent = selectContentDocumentId.split(',');
        List<Id> idList = new List<Id>( (List<Id>)idSetContent );
        Set<Id> idSetC = new Set<Id>();
        idSetC.addAll(idList);
        selectContentDocumentId = '';
        List<Reference_Content__c> updateDownloads = new List<Reference_Content__c>();
        List<ConetntWrapper> contList = getContentsNavigation(idSetC);
        
        for (ConetntWrapper contentWrap : contList) {
            String contentDocId = contentWrap.contentVersion.ContentDocumentId;
                    
            if (selectContentDocumentId == '' && contentDocId != null && contentDocId != '') {
                selectContentDocumentId = contentWrap.contentVersion.ContentDocumentId;
            } else if (contentDocId != null && contentDocId != '') {
                selectContentDocumentId = selectContentDocumentId + '/' + contentWrap.contentVersion.ContentDocumentId;
            }
            selectedContentIdSet.add(contentWrap.refContent.Id);
        } 
        idSetC = null;
        idList = null;
        idSetContent = null;
        
        if (selectedContentIdSet.size() > 0) {
            List<Reference_Content__c> tempList = WithoutSharingHelperController.getRefContentList(selectedContentIdSet);
            Set<String> contentSet = new Set<String>();
            
            for (Reference_Content__c rc : tempList) {
                contentSet.add(rc.Content_ID__c);
            }
            Map<Id, ContentVersion> tempContentMap = WithoutSharingHelperController.getContentVersionMapForInvitation(contentSet);
            
            for (Reference_Content__c rc : tempList) {
                
                if (rc.Content_ID__c != null && rc.Content_ID__c != '' && tempContentMap != null && tempContentMap.containsKey(rc.Content_ID__c)) {
                    String contentDocId = tempContentMap.get(rc.Content_ID__c).ContentDocumentId;
                    
                    if (!selectContentDocumentId.contains(contentDocId)) {
                        
                        if (selectContentDocumentId == '') {
                            selectContentDocumentId = contentDocId;
                        } else {
                            selectContentDocumentId = selectContentDocumentId + '/' + contentDocId;
                        }
                    }
                    Reference_Content__c temp = rc;
                    decimal downloadNo = (temp.Number_of_Download__c != null ? temp.Number_of_Download__c : 0);
                    temp.Number_of_Download__c = downloadNo + 1;
                    updateDownloads.add(temp);
                }
            }
        }
        
        if (updateDownloads.size() > 0) {
            WithoutSharingHelperController.upsertRefContentList(updateDownloads);
        }
        
        if (selectContentDocumentId == '') {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.Select_Atleast_One_Content));
            return null;
        } else {
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm().replace('visual.force.com', 'content.force.com');
            return new PageReference(baseUrl + '/sfc/servlet.shepherd/document/download/' + selectContentDocumentId);
        }
    }

    /**
     * Method to single download
     */
    public PageReference singleContentDownload() {

        if (hoverRefContentId != '') {
            List<Reference_Content__c> updateDownloads = new List<Reference_Content__c>();
            List<Reference_Content__c> tempList = WithoutSharingHelperController.getRefContentList(selectedContentIdSet);
                
            for (Reference_Content__c refContent : tempList) {
                Reference_Content__c temp = refContent;
                decimal downloadNo = (temp.Number_of_Download__c != null ? temp.Number_of_Download__c : 0);
                temp.Number_of_Download__c = downloadNo + 1;
                updateDownloads.add(temp);
            }
            
            if (updateDownloads.size() > 0) {
                WithoutSharingHelperController.upsertRefContentList(updateDownloads);
            }
        }
        String ContentUrl = '';
        
        if (hoverContentVersion.FileType == 'LINK') {
            ContentUrl = hoverContentVersion.ContentUrl;
        } else {
            String baseUrl = URL.getSalesforceBaseUrl().toExternalForm().replace('visual.force.com', 'content.force.com');
            ContentUrl = baseUrl + '/sfc/servlet.shepherd/document/download/' + hoverContentVersion.ContentDocumentId;
        }
        return new PageReference(ContentUrl);
    }
    
    // added for #571 - this is the ref content which the user is currently viewing
    public Reference_Content__c hoverRefContent { get; set; }
    
    // added for #1038-Get file image path
    public String fileImgPath { get; set; }
    
    /**
     * Method on Hover of content record
     * Last modified by: Gaurav Saini (15 Dec, 2016) for #571
     */
    public void fetchHoverContentItem() {
    	 
    	//Check User premission 
    	if (checkPermissions(false, 'DELETE')) {    	
	        refContentFields = new List<Reference_Content_Type_Field__c>();
	        refInterview = new List<Reference_Interview__c>();
	        refInterviewRecord = new Reference_Interview__c();
	        customContentTypeFieldsMap = new Map<String, Boolean>();
	        hoverContentVersion = new ContentVersion();
	        Boolean refContentInterviewType;
			
	        if (hoverContentId != null && hoverContentId.trim() != '') {  
	            List<ContentVersion> lstCV = WithoutSharingHelperController.getContentVersionList(hoverContentId); 
	            
	            if (lstCV.size() > 0) {
	                customRefContent = false;
	                
	                if (lstCV[0] != null) {
	                	fileImgPath = (UtilityController.mapDocumentPath.containsKey(lstCV[0].FileType) ? UtilityController.mapDocumentPath.get(lstCV[0].FileType) : '/assets/icons/doctype/unknown_60.png');
	                }
	                hoverContentVersion = lstCV[0];
	            }            
	            // added for #571 - getting ref content current counts for open/view
	            List<Reference_Content__c> tempRefContentList = [SELECT Ref_Content_Open_Clicks__c, Ref_Content_View_Details_Clicks__c,Summary__c
						    										FROM Reference_Content__c
						    										WHERE Id = :hoverRefContentId];
	            
	            if (tempRefContentList != null && tempRefContentList.size() > 0) {
	            	hoverRefContent = tempRefContentList[0];
	            }
	        } else { 
	            String refContentId;            
	            // changes for #571 - new fields for view/open count added to query
	            for (Reference_Content__c rc : [SELECT Title__c, Custom_Reference_Content__c, Reference_Content_Type__r.Name__c,
	    										Reference_Content_Type__r.Recorded_Reference_Type__c, Reference_Content_Type__c,
	    										Ref_Content_Open_Clicks__c, Ref_Content_View_Details_Clicks__c, Summary__c  
	    										FROM Reference_Content__c
	    										WHERE Id = :hoverRefContentId]) {
	            	 
	                if (rc.Custom_Reference_Content__c) {
	                    customRefContent = true;
	                    internalSummary = rc.Summary__c ;
	                } else {
	                    customRefContent = false;
	                }
	                refContentInterviewType = rc.Reference_Content_Type__r.Recorded_Reference_Type__c;
	                refContentId = rc.Reference_Content_Type__c;
	                referenceContentTitle = rc.Title__c;
	                hoverRefContent = rc;
	            }

	            if (customRefContent) {  
	                String soqlQuery = 'SELECT Id ';
	                
	                for (String s : customContentFields) {
	                    soqlQuery += ',' + s;
	                }
	                soqlQuery += ' FROM Reference_Content_Type_Field__c WHERE Reference_Content__c =  ';
	                
	                for (Reference_Content_Type_Field__c rcf : WithoutSharingHelperController.getReferenceContentTypeField(String.escapeSingleQuotes(soqlQuery), String.escapeSingleQuotes(hoverRefContentId))) { // Database.query(String.escapeSingleQuotes(soqlQuery))) {
	                    refContentFields.add(rcf); 
	                }
	               
	                Set<String> fieldMappingsDelete = new Set<String>();
	                customContentTypeFields = new List<String>();
	                
	                for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name
	                										FROM Reference_Type_Mapping__c
	                										WHERE Reference_Content_Type__c = :refContentId
	                										AND Visible__c = true
	                										ORDER BY Order__c NULLS LAST, Name]) {
	                    customContentTypeFields.add(rtm.Name);
	                    
	                    if (rtm.Required__c) {
	                        customContentTypeFieldsMap.put(rtm.Name, true);
	                    } else {
	                        customContentTypeFieldsMap.put(rtm.Name, false);
	                    }
	                }
	                
	                for (String fieldName : customContentTypeFields) {
	                    
	                    if (!customContentFields.contains(fieldName)) {
	                        fieldMappingsDelete.add(fieldName);
	                    }
	                }
	                
	                for (String fieldName : fieldMappingsDelete) {
	                    customContentTypeFieldsMap.remove(fieldName);
	                }
	                List<String> indexToBeDeleted = new List<String>();
	                
	                for (Integer index = 0; index < customContentTypeFields.size(); index++) {
	                    
	                    if (fieldMappingsDelete.contains(customContentTypeFields[index])) {
	                        indexToBeDeleted.add(customContentTypeFields[index]);
	                    }
	                }
	                
	                for (String item : indexToBeDeleted) {
	                    customContentTypeFields.remove(customContentTypeFields.indexOf(item));
	                }
	                List<Reference_Type_Mapping__c> deleteRTM = new List<Reference_Type_Mapping__c>();
	                
	                for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name
	                										FROM Reference_Type_Mapping__c
	                										WHERE Reference_Content_Type__c = :refContentId
	                										AND Name IN :fieldMappingsDelete]) {
	                    deleteRTM.add(rtm);
	                }
	                
	                if (deleteRTM.size() > 0) {
	                    delete deleteRTM;
	                }
	            } else if (refContentInterviewType) { 
	                refInterview = [SELECT Transcript__c, Reference_Content__r.Title__c, LastModifiedDate, Photograph__c,
	                					Speaker_info__c, Transcript_Content_Id__c, Org_website__c, Org_description__c, Name,
	                					(SELECT Name, Question__c, Transcript__c, Video_Url_Embed__c, Content_Id__c, Order__c
	                						FROM Interview_Topics__r ORDER BY Order__c)
	                    				FROM Reference_Interview__c WHERE Reference_Content__c = :hoverRefContentId];
	                
	                if (refInterview.size() > 0) {
	                    refInterviewRecord = refInterview[0];
	                }
	            }   
	        }	        
    	} 
    	
    	//re REF-1354 - Set variables flag for Reference content popover.     	
    	isRefInterviewType = (refInterview != null && refInterview.size() > 0) ? true : false;  
    	isCustomContent = customRefContent;
    	isContentVersionId = (hoverContentVersion != null && hoverContentVersion.Id != null) ? true : false; 
    }
    
    /**
     * method to increment the number of times the ref contnent has been opened
     * from ref search page (for link type contents only)
     * author: Gaurav Saini (15 Dec, 2016) for #571
     */
    public void incrementRefContentOpenCount() { 

        if (hoverRefContent != null && hoverRefContent.Ref_Content_Open_Clicks__c != null) {
            hoverRefContent.Ref_Content_Open_Clicks__c += 1;
        } else {
            hoverRefContent.Ref_Content_Open_Clicks__c = 1;
        }
        WithoutSharingHelperController.upsertRefContentList(new List<Reference_Content__c> { hoverRefContent });
    }
    
    /**
     * method to increment the number of times the ref contnent has been viewed
     * from ref search page (for link type contents only)
     * author: Gaurav Saini (15 Dec, 2016) for #571
     */
    public void incrementRefContentViewCount() {

        if (hoverRefContent != null && hoverRefContent.Ref_Content_View_Details_Clicks__c != null) {
            hoverRefContent.Ref_Content_View_Details_Clicks__c += 1;
        } else {
            hoverRefContent.Ref_Content_View_Details_Clicks__c = 1;
        }
        WithoutSharingHelperController.upsertRefContentList(new List<Reference_Content__c> { hoverRefContent });
    }
    
    /**
     * Method to get content Types
     */
    public List<ContentTypeWrapper> contentTypes {
        get {
            
            if (contentTypes == null) {
                contentTypes = new List<ContentTypeWrapper>();

                for (Reference_Content_Type__c rc : [SELECT Name__c, Active__c, Id FROM Reference_Content_Type__c WHERE Disable_For_Filter__c = false ORDER BY Name__c LIMIT : limits.getLimitQueryRows()]) {
                    contentTypes.add(new ContentTypeWrapper(rc.Name__c));
                }
            }
            return contentTypes;
        }
        set;
    }

    /**
     * Method to return selected content types
     */
    public List<ContentTypeWrapper> selectedContentTypes {
        get {
            
            if (selectedContentTypes == null)
                selectedContentTypes = new List<ContentTypeWrapper>();
            return selectedContentTypes;
        }
        set;
    }
    
    /**
     * Method to select Content Type
     */
    public void setContentTypes() {
      
        for (ContentTypeWrapper ctw : contentTypes) {
          
            if (ctw.contentTypeName == selectedContentTypeName) {
              
                if (ctw.fontWeight == ConstantsController.NORMAL) {
                    ctw.fontWeight = ConstantsController.BOLD;
                    selectedContentTypes.add(new ContentTypeWrapper(ctw.contentTypeName));
                    break;
                } else {
                   
                    for (Integer i = 0; i < selectedContentTypes.size(); i++) {
                      
                        if (selectedContentTypes.get(i).contentTypeName == selectedContentTypeName) {
                            ctw.fontWeight = ConstantsController.NORMAL;
                            selectedContentTypes.remove(i);
                            break;
                        }
                    }
                }
            }
        }
    }

    /**
     * Method to selectAll Content Types
     */
    public void selectAllContentTypes() {
        
        for (ContentTypeWrapper ctw : contentTypes) {
           
            if (ctw.fontWeight == ConstantsController.NORMAL) {
                ctw.fontWeight = ConstantsController.BOLD;
                selectedContentTypes.add(new ContentTypeWrapper(ctw.contentTypeName));
            }
        }
    }

    /**
     * Method to clear all selected content types
     */
    public void clearAllContentTypes() {
        selectedContentTypes.clear();
        contentTypes = null;
        mapContentTypes = null;
        reset();
    }
    
    /**
     * Method to Show by alphabets
     */
    public void showContentTypesAlphabet() {
       
        if (character.trim().length() != 0) {
            Map<String, List<ContentTypeWrapper>> tempMap = getContentTypesByAlphabat();
            contentTypes = tempMap.get(character);
        }
    }

    /**
     * Map Contains Content types By Alphabets
     */
    private Map<String, List<ContentTypeWrapper>> getContentTypesByAlphabat() {
       
        if (mapContentTypes == null) {
            mapContentTypes = new Map<String, List<ContentTypeWrapper>>();
            
            for (String s : alphabets) {
                mapContentTypes.put(s, new List<ContentTypeWrapper>());
            }
            mapContentTypes.put(ConstantsController.ALL, contentTypes);
            mapContentTypes.put('other', new List<ContentTypeWrapper>());
            String alphbets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            
            if (character.trim().length() != 0) {
                
                for (ContentTypeWrapper ctw : contentTypes) {
                    String firstLetter = ((String) ctw.contentTypeName).left(1);
                    
                    if (alphbets.contains(firstLetter)) {
                       
                        if (!mapContentTypes.containskey(firstLetter)) {
                            mapContentTypes.put(firstLetter, new List<ContentTypeWrapper>());
                        }
                        mapContentTypes.get(firstLetter).add(ctw);
                    } else {
                        mapContentTypes.get('other').add(ctw);
                    }
                }
            }
        }
        return mapContentTypes;
    }

    /**
     * Method to get Content Languages
     */
    public List<ContentLanguageWrapper> contentLanguages {
        get {
           
            if (contentLanguages == null) {
                contentLanguages = new List<ContentLanguageWrapper>();
                Schema.DescribeFieldResult field = Reference_Content__c.Language__c.getDescribe(); //Values from Schema
                List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
                
                for (Schema.PicklistEntry picklistValue : picklistValues) {
                    contentLanguages.add(new ContentLanguageWrapper(picklistValue.getValue()));
                }
            }
            return contentLanguages;
        }
        set;
    }

    /**
     * Method to return selected Content Languages
     */
    public List<ContentLanguageWrapper> selectedContentLanguages {
        get {
            
            if (selectedContentLanguages == null) {
                selectedContentLanguages = new List<ContentLanguageWrapper>();
            }
            return selectedContentLanguages;
        }
        set;
    }

    /**
     * Method to select Content Languages
     */
    public void setContentLanguages() {
        for (ContentLanguageWrapper clw : contentLanguages) {
            
            if (clw.contentLanguageName == selectedContentLanguageName) {
               
                if (clw.fontWeight == ConstantsController.NORMAL) {
                    clw.fontWeight = ConstantsController.BOLD;
                    selectedContentLanguages.add(new ContentLanguageWrapper(clw.contentLanguageName));
                    break;
                } else {
                    
                    for (Integer i = 0; i < selectedContentLanguages.size(); i++) {
                       
                        if (selectedContentLanguages.get(i).contentLanguageName == selectedContentLanguageName) {
                            clw.fontWeight = ConstantsController.NORMAL;
                            selectedContentLanguages.remove(i);
                            break;
                        }
                    }
                }
            }
        }
    }

    /**
     * Method to selectAll Content Languages
     */
    public void selectAllContentLanguages() {
        
        for (ContentLanguageWrapper clw : contentLanguages) {
            
            if (clw.fontWeight == ConstantsController.NORMAL) {
                clw.fontWeight = ConstantsController.BOLD;
                selectedContentLanguages.add(new ContentLanguageWrapper(clw.ContentLanguageName));
            }
        }
    }

    /**
     * Method to clear all selected content types
     */
    public void clearAllContentLanguages() {
        selectedContentLanguages.clear();
        contentLanguages = null;
        mapContentLanguages = null;
        reset();
    }
    
    /**
     * Method to Show by alphabets
     */
    public void showContentLanguagesAlphabet() {
        
        if (character.trim().length() != 0) {
            Map<String, List<ContentLanguageWrapper>> tempMap = getContentLanguagesByAlphabat();
            contentLanguages = tempMap.get(character);
        }
    }
    
    /**
     * Map Contains Content types By Alphabets
     */
    private Map<String, List<ContentLanguageWrapper>> getContentLanguagesByAlphabat() {
        
        if (mapContentLanguages == null) {
            mapContentLanguages = new Map<String, List<ContentLanguageWrapper>> ();

            for (String s : alphabets) {
                mapContentLanguages.put(s, new List<ContentLanguageWrapper> ());
            }
            mapContentLanguages.put(ConstantsController.ALL, contentLanguages);
            mapContentLanguages.put('other', new List<ContentLanguageWrapper> ());
            String alphbets = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
            
            if (character.trim().length() != 0) {
                
                for (ContentLanguageWrapper clw : contentLanguages) {
                    String firstLetter = ((String) clw.ContentLanguageName).left(1);
                    
                    if (alphbets.contains(firstLetter)) {
                        
                        if (!mapContentLanguages.containskey(firstLetter)) {
                            mapContentLanguages.put(firstLetter, new List<ContentLanguageWrapper> ());
                        }
                        mapContentLanguages.get(firstLetter).add(clw);
                    } else {
                        mapContentLanguages.get('other').add(clw);
                    }
                }
            }
        }
        return mapContentLanguages;
    }

    /**
     * Wrapper Class Content Types
     */
    public class ContentTypeWrapper {
        public String contentTypeName { get; set; }
        public String fontWeight { get; set; }
        public ContentTypeWrapper(String contentTypeName) {
            fontWeight = ConstantsController.NORMAL;
            this.contentTypeName = contentTypeName;
        }
    }

    /**
     * Wrapper Class Content Types
     */
    public class FieldWrapper {
        public String apiName { get; set; }
        public String label { get; set; }
        public String type { get; set; }
        public FieldWrapper(String apiName, String label, String type) {
            this.apiName = apiName;
            this.label = label;
            this.type = type;
        }
    }

    /**
     * Wrapper Class Content Languages
     */
    public class ContentLanguageWrapper {
        public String contentLanguageName { get; set; }
        public String fontWeight { get; set; }
        public ContentLanguageWrapper(String contentLanguageName) {
            fontWeight = ConstantsController.NORMAL;
            this.contentLanguageName = contentLanguageName;
        }
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isOnPageLoad, String action) {  
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Boolean isDeletePermission = true;
    	Boolean isUpsertPermission = false;
    	
    	if (isOnPageLoad || action == 'DOWNLOAD') {        		
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String> { 
            										UtilityController.appNamespace() + 'Number_of_Download__c'}); 
    	}
    	
    	if (isOnPageLoad || action == 'OPEN_CLICK') {        		
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String> { 
            										UtilityController.appNamespace() + 'Ref_Content_Open_Clicks__c'}); 
    	}
    	
    	if (isOnPageLoad || action == 'OPEN_VIEW') {        		
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Content__c', new Set<String> { 
            										UtilityController.appNamespace() + 'Ref_Content_View_Details_Clicks__c'}); 
    	}
        
        if (isOnPageLoad || action == 'DELETE') { 								
       		isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Reference_Type_Mapping__c'});
       		return isDeletePermission;
        }
        
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);  
           
        return isUpsertPermission;  
    }
}