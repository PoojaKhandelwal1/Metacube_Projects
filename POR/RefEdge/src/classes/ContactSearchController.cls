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
 * Class: RFSearchController
 * Description : Class called FROM RFSearchController to manage contact section filtering
 * Modified by: Rekha @Feb 13 2017
 */
public with sharing class ContactSearchController {
    /**
     * Properties and variables
     */
    private String inputTextValue;
    private transient AttributeWrapper attributeWrapper;
    private transient ReferenceabilityWrapper referenceabilityWrapper;
    public Id accountId { get; set; }
    public Map<Integer, Set<Id>> mapContact { get; set; }
    public Integer contactSize { get; set; }
    public Map<String, List<ContactWrapper>> mapAccountContact { get; set; }
    public Map<String, Reference_Basic_Information__c> mapAccountRBIofContactRBI { get; set; }
    public Integer pageLimit { get; set; }
    public Integer pageIndex { get; set; }
    public Map<String, String > filterLogic { get; set; }
    public String betweenFilterLogic { get; set; }
    public Integer LAST_PAGE = 0;
    public Set<String> accountContactIds;
    public Boolean isNextRender { get; set; }
	public Set<String> contactIds { get; set; }
	public String stageLabelId { get; set; }
    public String reqId { get; set; }
    public Set<Id> accountIdSet { get; set; }
    public transient Set<String> referenceableContactIds;
    public String selectedType { get; set; }
    // added for #1135 - Gaurav Saini (5 Dec, 2017)
    public Set<String> allContactIds { get; set; }
    
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
        	
            if (SHOWMORE_PAGE_SIZE == null) {
                SHOWMORE_PAGE_SIZE = 25;
            }
            return SHOWMORE_PAGE_SIZE;
        }
        set;
    }
    /**
     * getter to Contact Page Block Limit Exceed
     */
    public Boolean isContactLimitExceed {
        get {
        	
            if (isContactLimitExceed == null) {
                isContactLimitExceed = false;
            }
            return isContactLimitExceed;
        }
        set;
    }
    /**
     * getter to show More Contact Records
     */
    public Boolean showMoreContactRecords {
        get {
        	
            if (showMoreContactRecords == null) {
                showMoreContactRecords = false;
            }
            return showMoreContactRecords;
        }
        set;
    }
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Active', 'Active'));
        options.add(new SelectOption('Inactive', 'Inactive'));
        return options;
    }
    /**
     * Constructor
     */
    public ContactSearchController() {
        inputTextValue = '';
        selectedType = 'Active';
        stageLabelId = '';
        reset();
    }
    
    /**
     * Method to RESET values
     */
    public void reset() {
        isNextRender = true;
        pageIndex = 1;
        pageLimit = PAGE_SIZE;
        LAST_PAGE = 0;
        contactSize = 0;
        filterLogic = new Map<String, String>();
        contactIds = new Set<String>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        //betweenFilterLogic = cs.RefSearch_Filters_Default__c ? 'And' : 'Or';
        betweenFilterLogic = 'And'; 
        accountContactIds = new Set<String>();
        mapContact = new Map<Integer, Set<Id>>();
        mapAccountContact = new Map<String, List<ContactWrapper>>();
        mapAccountRBIofContactRBI = new Map<String, Reference_Basic_Information__c>();
    }

    /**
     * Method Return list of Contacts to RE Search Page
     */
    public List<ContactWrapper> listContacts(String searchTextValue, AttributeWrapper attriWrappController,
    								ReferenceabilityWrapper refeWrappController, Set<String> relatedContactIds,
    								Boolean mappingSelected, Boolean isExportClicked) {
        List<ContactWrapper> listData = null;
        inputTextValue = searchTextValue;
        attributeWrapper = attriWrappController;
        referenceabilityWrapper = refeWrappController;
        
        try {
        	
        	if (isExportClicked) {
        		listData = searchContacts(relatedContactIds, mappingSelected, isExportClicked);
        	} else {
	        	
	            //Check if map contains values
	            if (mapContact.containsKey(pageIndex) && pageIndex != 1) {
	            	
	                if (mapContact.get(pageIndex).size() < pageLimit) {
	                    isNextRender = false;
	                    isContactLimitExceed = false;
	                } else {
	                    isContactLimitExceed = true;
	                }
	                listData = getContactsNavigation(mapContact.get(pageIndex));
	            } else {
	            	listData = searchContacts(relatedContactIds, mappingSelected, isExportClicked);
	            	
	            	if (listData.isEmpty()) {
	            		listData = getContactsNavigation(mapContact.get(pageIndex));
	            	}
	            }
        	}
            //Call Search Method
            return listData;
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    /**
     * Get Previous and Next Contacts for Pagination
     * @return idSet {Set} 
     * @return conWrapList {List<ContactWrapper>}
     **/
    private List<ContactWrapper> getContactsNavigation(Set<Id> idSet) {
		List<ContactWrapper> conWrapList = new List<ContactWrapper>();
		//Getting RBI List 
	 	List<Reference_Basic_Information__c> rbiList = WithoutSharingHelperController.getContactProfilesinContactSearch(idSet);
	 	
	 	//Getting Contact map
     	Map<Id, Contact> contacts = WithoutSharingHelperController.getContactsinContactSearch(idSet);
     	
        for (Reference_Basic_Information__c acc : rbiList) {
            integer hitSize = 0;
            Boolean isAlreadyHit = false;
            
            for (Hit_List__c hit : contacts.get(acc.Contact__c).Hit_Lists__r) {
            	
            	if (!hit.Released__c) {
            		hitSize += 1;
            	}
            	
        		if (hit.Reference_Request__c == reqId) {
        			isAlreadyHit = true;
        		}
            }

            if (contacts.get(acc.Contact__c).Reference_Request_Account_Contacts__r.size() > 0) {
                conWrapList.add(new ContactWrapper(acc, contacts.get(acc.Contact__c).Reference_Request_Account_Contacts__r.size(), hitSize,isAlreadyHit));
            } else {
                conWrapList.add(new ContactWrapper(acc, hitSize,isAlreadyHit));
            }
        }
        return conWrapList;
	}

	/**
     * Method Return list of Contacts to Ref Match page for specific Account
     */
    public List<ContactWrapper> listAccountContacts() {
        try {
            mapContact.clear();
            contactIds.clear();
            
            if (mapAccountContact.containsKey(pageIndex + '+' + accountId) && pageIndex != 1) {
            	
                if (mapAccountContact.get(pageIndex + '+' + accountId).size() < pageLimit) {
                    isNextRender = false;
                    isContactLimitExceed = false;
                } else {
                    isContactLimitExceed = true;
                }
                return mapAccountContact.get(pageIndex + '+' + accountId);
            }
            searchAccountContacts();
            return mapAccountContact.get(pageIndex + '+' + accountId);
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
	/**
     * Method to search Contact for specific Account
     */
    public void searchAccountContacts() {
        List<ContactWrapper> contactWrpList = new List<ContactWrapper>();
        Set<Id> tempContactIds = new Set<Id>();
        
        if (!showMoreContactRecords) {
            pageLimit = PAGE_SIZE;
        }
        
        if (showMoreContactRecords && pageIndex == 1) {
            pageLimit = SHOWMORE_PAGE_SIZE;
        }
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Set<String> contactIds = new Set<String>();
        
        if (cs.Shared_Contacts__c && cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != '' 
        				&& cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != '') {
            String objectName = cs.Shared_Contact_Object__c;
            String accountField = cs.Shared_Account_Field__c;
            String contactField = cs.Shared_Contact_Field__c;
            String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
                                     + ' WHERE ' + accountField+ ' = \'' + accountId + '\' AND '+contactField +' != null';
            List<sObject> objectList = WithoutSharingHelperController.getSobjectinContactSearch(query);
            
            if (objectList != null && objectList.size() > 0) {
            	
                for (sObject obj : objectList) {
                    contactIds.add((String)obj.get(contactField));
                }
            }
        }
        
        if (!mapAccountContact.containsKey(pageIndex + '+' + accountId)) {
            List<Reference_Basic_Information__c> listContact = WithoutSharingHelperController.getContactProfilesinContactSearch(contactIds, selectedType,
            																			accountContactIds, accountId);
            
            if (pageIndex == 1) {
                contactSize = listContact.size();
            }
            
            if (listContact.size() == pageLimit) {
                isNextRender = false;
            }
            Set<Id> accIdSet = new Set<Id>();
            
            for (Reference_Basic_Information__c acc : listContact) {
                accIdSet.add(acc.Account__c);
            }
            mapAccountRBIofContactRBI = mapAccountRBIofContactRBI == null ? new Map<String, Reference_Basic_Information__c>() : mapAccountRBIofContactRBI;
            
            if (accIdSet.size() > 0) {
            	
                for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountProfilesinContactSearch(accIdSet)) {
                    mapAccountRBIofContactRBI.put(rbi.Account__c, rbi);
                }
            }
            
            for (Reference_Basic_Information__c acc : listContact) {
            	
                if (!mapAccountRBIofContactRBI.containsKey(acc.Account__c)) {
                    mapAccountRBIofContactRBI.put(acc.Account__c, new Reference_Basic_Information__c());
                }
            }
            
            for (Reference_Basic_Information__c rbiCon : listContact) {
            	
                if (tempContactIds.size() < pageLimit) {
                    accountContactIds.add(rbiCon.Contact__c);
                    tempContactIds.add(rbiCon.Contact__c);
                } else {
                    break;
                }
            }
            Map<Id, Contact> contactMap = WithoutSharingHelperController.getContactsinContactSearch(tempContactIds);
            isContactLimitExceed = false;
            
            if (!mapAccountContact.containskey(pageIndex + '+' + accountId)) {
                mapAccountContact.put(pageIndex + '+' + accountId, new List<ContactWrapper>());
            }
            
            for (Reference_Basic_Information__c rbiCon : listContact) {
            	
                if (mapAccountContact.get(pageIndex + '+' + accountId).size() == pageLimit) {
                    isContactLimitExceed = true;
                    break;
                }
                integer hitSize = 0;
                Boolean isAlreadyHit = false;
                
                for (Hit_List__c hit : contactMap.get(rbiCon.Contact__c).Hit_Lists__r) {
                	
                	if (!hit.Released__c) {
                		hitSize += 1;
                	}
                	
            		if (reqId != null && hit.Reference_Request__c == reqId) {
            			isAlreadyHit = true;
            		}
                }
                
                if (contactMap.get(rbiCon.Contact__c).Reference_Request_Account_Contacts__r.size() > 0) {
                    mapAccountContact.get(pageIndex + '+' + accountId).add(new ContactWrapper(rbiCon, 
                    						contactMap.get(rbiCon.Contact__c).Reference_Request_Account_Contacts__r.size(), hitSize, isAlreadyHit));
                } else {
                    mapAccountContact.get(pageIndex + '+' + accountId).add(new ContactWrapper(rbiCon, hitSize, isAlreadyHit));
                }
            }
            
            if (showMoreContactRecords && mapAccountContact.get(pageIndex + '+' + accountId).size() < pageLimit) {
                LAST_PAGE = pageIndex;
                isNextRender = false;
            }
        }
    }
    
	/**
     * Chk list in map "mapAttributesLabels" Null or not
     */
    public List<ContactWrapper> searchContacts(Set<String> relatedContactIds, Boolean mappingSelected, Boolean isExportClicked) {
        List<Reference_Basic_Information__c> listContact = new List<Reference_Basic_Information__c>();
        Set<Id> tempContactIds = new Set<Id>();
        List<ContactWrapper> contactWrapList = new List<ContactWrapper>();
        
        if (!showMoreContactRecords) {
            pageLimit = PAGE_SIZE;
        }
        
        if (showMoreContactRecords && pageIndex == 1) {
            pageLimit = SHOWMORE_PAGE_SIZE;
        }
        
        if (!mapContact.containsKey(pageIndex) || isExportClicked) {
        	
            if (inputTextValue.trim().length() == 0 && !isAttributeSelected() 
            					&& referenceabilityWrapper.selectedReferenceabilityTypes.size() == 0 
            					&& !mappingSelected) {
            	
            	// changes for #1135 - Gaurav Saini (5 Dec, 2017)
                if (isExportClicked) {
                	listContact = WithoutSharingHelperController.getContactProfilesinContactSearchForExport(contactIds);
                } else {
	            	listContact = WithoutSharingHelperController.getContactProfilesinContactSearch(contactIds, selectedType);
                }
            } else {
                Set<String> commonFilterIds = new Set<String>();
               
                if (inputTextValue.trim().length() > 1) {
                    commonFilterIds = filterContactsBySearchText(relatedContactIds);
                	
                	// changes for #642 - added parameter mappingSelected for
                	//						checking if filter is already applied on refsearch page
                	// changes for #687 - setting the mappingSelected parameter to true if
                	//						any contact is present in previous results (16 Jan, 2017)
                    if (commonFilterIds.size() > 0) {
                        commonFilterIds = filteredContactIds(commonFilterIds, true);
                    }
                } else {
                    commonFilterIds.addAll(relatedContactIds);
                    
                    if (!mappingSelected || commonFilterIds.size() > 0) {
	                    commonFilterIds = filteredContactIds(commonFilterIds, mappingSelected);
                    }
                }
                
                // changes for #1135 - Gaurav Saini (5 Dec, 2017)
                if (isExportClicked) {
                	listContact = WithoutSharingHelperController.getContactProfilesinContactSearchForExport(contactIds, commonFilterIds);
                } else {
	                //Resultant contacts
	                listContact = WithoutSharingHelperController.getContactProfilesinContactSearch(contactIds, selectedType, commonFilterIds);
                }
            }
            
            // added for #1135 - Gaurav Saini (5 Dec, 2017)
            if (isExportClicked) {
	            allContactIds = new Set<String>();
	            
	            for (Reference_Basic_Information__c conRBI : listContact) {
	            	allContactIds.add(conRBI.Contact__c);
	            }
	            allContactIds.addAll(contactIds);
            }
            
            if (pageIndex == 1) {
                contactSize = listContact.size();
            }
            
            if (listContact.size() == pageLimit) {
                isNextRender = false;
            }
            Set<Id> accIdSet = new Set<Id>();
            
            for (Reference_Basic_Information__c acc : listContact) {
                accIdSet.add(acc.Account__c);
            }
            mapAccountRBIofContactRBI = mapAccountRBIofContactRBI == null ? new Map<String, Reference_Basic_Information__c>() : mapAccountRBIofContactRBI;
            
            if (accIdSet.size() > 0) {
            	
                for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountProfilesinContactSearch(accIdSet)) {
                    mapAccountRBIofContactRBI.put(rbi.Account__c, rbi);
                }
            }
            
            for (Reference_Basic_Information__c acc : listContact) {
            	
                if (!mapAccountRBIofContactRBI.containsKey(acc.Account__c)) {
                    mapAccountRBIofContactRBI.put(acc.Account__c, new Reference_Basic_Information__c());
                }
            }
            
            for (Reference_Basic_Information__c acc : listContact) {
            	
                if (tempContactIds.size() < pageLimit) {
                    contactIds.add(acc.Contact__c);
                    tempContactIds.add(acc.Contact__c);
                } else {
                    break;
                }
            }
            
            Map<Id, Contact> contactMap = WithoutSharingHelperController.getContactsinContactSearch(tempContactIds);
            isContactLimitExceed = false;
            
            if (!mapContact.containskey(pageIndex)) {
                mapContact.put(pageIndex, new Set<Id>());
            }
            
            for (Reference_Basic_Information__c con : listContact) {
            	
                if (mapContact.get(pageIndex).size() == pageLimit) {
                    isContactLimitExceed = true;
                    break;
                }
                integer hitSize = 0;
                Boolean isAlreadyHit = false;
                
                for (Hit_List__c hit : contactMap.get(con.Contact__c).Hit_Lists__r) {
                	
                	if (!hit.Released__c) {
                		hitSize += 1;
                	}
                	
            		if (reqId != null && hit.Reference_Request__c == reqId) {
            			isAlreadyHit = true;
            		}
                }
                
                mapContact.get(pageIndex).add(con.Contact__c);
                
                if (contactMap.get(con.Contact__c).Reference_Request_Account_Contacts__r.size() > 0) {
                    contactWrapList.add(new ContactWrapper(con, contactMap.get(con.Contact__c).Reference_Request_Account_Contacts__r.size(), 
                    									hitSize, isAlreadyHit));
                } else {
                    contactWrapList.add(new ContactWrapper(con, hitSize, isAlreadyHit));
                }
            }
            
            if (showMoreContactRecords && mapContact.get(pageIndex).size() < pageLimit) {
                LAST_PAGE = pageIndex;
                isNextRender = false;
            }
        }
        
        if (contactWrapList != null && contactWrapList.size() > 0) {
        	return contactWrapList;
        } else {
        	return new List<ContactWrapper>();
        }
    }

    /**
     * Method to Check list in map "mapAttributesLabels" Null or not
     */
    private Boolean isAttributeSelected() {
        Boolean attributeSelected = false;
        
        for (String labelId : attributeWrapper.mapAttributesLabels.keyset()) {
        	
            if ((stageLabelId == null || stageLabelId == '') || (stageLabelId != '' && labelId != stageLabelId)) {
            	
	            if (attributeWrapper.mapAttributesLabels.get(labelId).size() > 0) {
	                attributeSelected = true;
	                break;
	            }
            }
        }
        return attributeSelected;
    }

    /**
     * Method to return Contact IDs for Text
     */
    public Set<String> filterContactsBySearchText(Set<String> relatedContactIds) {
        Set<String> searchedcontactIds = new Set<String>();
        Set<String> rbiContactIds = new Set<String>();
        referenceableContactIds = new Set<String>();
        
        if (relatedContactIds.size() == 0) {
			referenceableContactIds = WithoutSharingHelperController.getContactProfileIdsinContactSearch(selectedType);
        } else {
            referenceableContactIds.addAll(relatedContactIds);
        }
        
        String SOSLQuery = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING ' + UtilityController.appNamespace() 
        							+ 'Reference_Basic_Information__c(Id, Contact__c, Contact__r.Name, Account__c WHERE Contact__c IN :referenceableContactIds '
        							+ ' AND Contact__c NOT IN :contactIds AND Contact__c != null ORDER BY Contact__r.Name)';
        String SOSLQuery1 = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING Contact(Id, Name WHERE Id IN :referenceableContactIds ' 
        							+ ' AND Id NOT IN :contactIds ORDER BY Name)';

        List<List<SObject>> searchList = WithoutSharingHelperController.getSobjectSOSLinContactSearch(SOSLQuery, referenceableContactIds, contactIds);
        
        for (Reference_Basic_Information__c acc : (List<Reference_Basic_Information__c>) searchList[0]) {
            searchedcontactIds.add(acc.Contact__c);
        }
        searchList = WithoutSharingHelperController.getSobjectSOSLinContactSearch(SOSLQuery1, referenceableContactIds, contactIds);
        
        for (Contact c : (List<Contact>) searchList[0]) {
            searchedcontactIds.add(c.Id);
        }

        if (accountIdSet != null && accountIdSet.size() > 0) {
        	
            for (Contact c : WithoutSharingHelperController.getAccountContactsinContactSearch(referenceableContactIds, contactIds, 
            																				searchedcontactIds, accountIdSet)) {
                searchedcontactIds.add(c.Id);
            }
        }
        return searchedcontactIds;
    }

    /**
     * Method to return final Contact ids(Text, Referenceability & Attribute)
     * Last modified for #642 - added parameter mappingSelected for checking
     *							if filter is already applied on refsearch page
     */
    public Set<String> filteredContactIds(Set<String> commonFilterIds, Boolean mappingSelected) {
        Set<String> setContactIds = new Set<String>();
        //Selected Labels
        Set<String> setLabelIds = new Set<String>();
        String labelClause = '';
        
        for (Label__c label : attributeWrapper.getAttributeLabels()) {
        	
            if ((stageLabelId == null || stageLabelId == '') || (stageLabelId != '' && label.Id != stageLabelId)) {
	           
	            if (attributeWrapper.mapAttributesLabels.get(label.Id).size() > 0) {
	                String labelNo = String.escapeSingleQuotes(label.Filter_no__c != null ? 'F' + String.valueOf(label.Filter_no__c) + 'F' : '');
	                
	                if (betweenFilterLogic == 'And') {
	                	
	                    if (labelClause == '') {
	                        labelClause = ' (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
	                    } else {
	                        labelClause += ' AND (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
	                    }
	                } else {
	                	
	                    if (labelClause == '') {
	                        labelClause = ' Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\'';
	                    } else {
	                        labelClause += ' OR Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\'';
	                    }
	                }
	                setLabelIds.add(label.Id);
	            }
            }
        }

        //Selected Referenceability Types
        String refTypesClause = '';
        
        if (filterLogic.containsKey('Referenceability') && filterLogic.get('Referenceability') == 'And') {
        	
            for (referenceabilityWrapper.ReferenceabilityTypeWrapper rtw : referenceabilityWrapper.selectedReferenceabilityTypes) {
                String refnumber = String.escapeSingleQuotes(rtw.refType.Referenceability_no__c != null ? 'R' 
                											+ String.valueOf(rtw.refType.Referenceability_no__c) + 'R' : '');
                
                if (refTypesClause == '') {
                    refTypesClause = ' (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber 
                    					+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                } else {
                    refTypesClause += ' AND (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber 
                    					+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                }
            }
        } else {
        	
            for (referenceabilityWrapper.ReferenceabilityTypeWrapper rtw : referenceabilityWrapper.selectedReferenceabilityTypes) {
                String refnumber = String.escapeSingleQuotes(rtw.refType.Referenceability_no__c != null ? 'R' 
                												+ String.valueOf(rtw.refType.Referenceability_no__c) + 'R' : '');
                												
                if (refTypesClause == '') {
                    refTypesClause = ' ReferenceabilityType_Ids1__c LIKE \'%' + refnumber 
                    					+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                } else {
                    refTypesClause += ' OR ReferenceabilityType_Ids1__c LIKE \'%' + refnumber 
                    					+ '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                }
            }
        }

        //If Labels & Referenceability Types are not selected
        if (labelClause == '' && refTypesClause == '') {
            return commonFilterIds;
        }

        //Create final dynamic Query	
        String dynamicSOQL = '';
        String finalClause = '';
        
        if (betweenFilterLogic == 'And') {
        	
            if (labelClause != '') {
                finalClause += ' AND (' + labelClause + ')';
            }
            
            if (refTypesClause != '') {
                finalClause += ' AND (' + refTypesClause + ')';
            }
        } else {
        	
            if (refTypesClause != '' && labelClause != '') {
                finalClause = ' AND ( (' + refTypesClause + ') OR (' + labelClause + ') )';
            }
            
            if (labelClause != '') {
                finalClause += ' AND (' + labelClause + ')';
            }
            
            if (refTypesClause != '') {
                finalClause += ' AND (' + refTypesClause + ')';
            }
        }
        
        if (selectedType == 'Active') {
            finalClause += ' AND  Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
            				+ '\' AND Referenceability_Status__c != null AND Contact__c NOT IN :contactIds ORDER BY contact__r.Name';
        } else if (selectedType == 'Inactive') {
            finalClause += ' AND  Referenceability_Status__c = \'' + ConstantsController.INACTIVE 
            				+ '\' AND Contact__c NOT IN :contactIds ORDER BY contact__r.Name';
        } else if (selectedType == 'Candidate') {
            finalClause += ' AND  Reference_Program_Candidate__c = true AND Contact__c NOT IN :contactIds ORDER BY contact__r.Name';
        }
        
        // changes for #642 - checking if any related mapping filter is already applied or not
        if (mappingSelected) {
            dynamicSOQL = 'SELECT Contact__c, Attribute_Ids__c FROM Reference_Basic_Information__c WHERE Contact__c != null AND Account__c != null ' 
            				+ ' AND Contact__c IN :commonFilterIds ' + finalClause;
        } else {
            dynamicSOQL = 'SELECT Contact__c, Attribute_Ids__c FROM Reference_Basic_Information__c WHERE Contact__c != null AND Account__c != null ' + finalClause;
        }
        Map<String, Boolean> labelLogicMap = new Map<String, Boolean>();
       
        //Iterate Fianl Reference profiles
        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getContactProfileSobjectinContactSearch(dynamicSOQL, contactIds, commonFilterIds)) {
        	
            if (setLabelIds.size() > 0) {
            	
                if (rbi.Attribute_Ids__c != null && rbi.Attribute_Ids__c != '') {
                    Set<String> setAttribute = new Set<String>();
                    setAttribute.addAll(rbi.Attribute_Ids__c.split(','));
                    Integer selectedlabelCount = 0;
                    Integer recordMatchCount = 0;
                    
                    for (String labelId : setLabelIds) {
                        labelLogicMap.put(labelId, false);
                        selectedlabelCount++;
                        
                        if (filterLogic.containsKey(labelId) && filterLogic.get(labelId) == 'And') {
                            Boolean notMatched = false;
                            
                            for (attributeWrapper.AttributesLabelWrapper atw : attributeWrapper.mapAttributesLabels.get(labelId)) {
                            	
                                if (!setAttribute.contains(atw.attributeLabel.Attribute__c)) {
                                    notMatched = true;
                                    break;
                                }
                            }
                            
                            if (!notMatched) {
                                recordMatchCount++;
                                labelLogicMap.put(labelId, true);
                            }
                        } else {
                        	
                            for (attributeWrapper.AttributesLabelWrapper atw : attributeWrapper.mapAttributesLabels.get(labelId)) {
                            	
                                if (setAttribute.contains(atw.attributeLabel.Attribute__c)) {
                                    recordMatchCount++;
                                    labelLogicMap.put(labelId, true);
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (selectedlabelCount != 0) {
                    	
                        if (betweenFilterLogic == 'And') {
                            Boolean checkResult = true;
                            
                            for (Boolean flag : labelLogicMap.values()) {
                                checkResult = (checkResult && flag);
                            }
                            
                            if (checkResult) {
                                setContactIds.add(rbi.Contact__c);
                            }
                        } else {
                            Boolean checkResult = false;
                            
                            for (Boolean flag : labelLogicMap.values()) {
                                checkResult = (checkResult || flag);
                            }
                            
                            if (checkResult) {
                                setContactIds.add(rbi.Contact__c);
                            }
                        }
                    }
                }
            } else {
                setContactIds.add(rbi.Contact__c);
            }
        }
        return setContactIds;
    }

    /**
     * Method to previous Link
     */
    public Pagereference previous() {
    	
        if (pageIndex != 1) {
            pageIndex = pageIndex - 1;
            isNextRender = true;
        }
        return null;
    }

    /**
     * Method to next Link
     */
    public Pagereference next() {

        if (pageIndex != LAST_PAGE) {
            pageIndex = pageIndex + 1;
        } else {
            isNextRender = false;
        }
        return null;
    }
}