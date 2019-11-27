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
 * VF Page: ReferenceRefreshPageSLDS
 * Description: Controller for processing Profile Update records for lightning experience
 * author: Gaurav Saini (30 Aug, 2017)
 */
public with sharing class ReferenceRefreshControllerSLDS extends RefEdgeEditionFeatures {
    
    private static Custom_Settings__c cs = UtilityController.getCustomSettings();
    public String userId { get; set; }
    public String accountId { get; set; }
    public Integer pageNo { get; set; }
    public Boolean showMore { get; set; }
    public String helpAssistant { get; set; }
    public static boolean showOverlay { get; set; }
    private List<User_Mapping__c> userMappingList;
    private Date lastActivity;
    public String helpOverlay { get; set; } 
	
    public ReferenceRefreshControllerSLDS() {
    	userId = ApexPages.currentPage().getParameters().get('userId') == null
    				? Userinfo.getUserId()
    				: ApexPages.currentPage().getParameters().get('userId');
        accountId = ApexPages.currentPage().getParameters().get('accountId') != null
        			? ApexPages.currentPage().getParameters().get('accountId') : '';
        pageNo = ApexPages.currentPage().getParameters().get('pageno') != null
        			? Integer.valueOf(ApexPages.currentPage().getParameters().get('pageno')) : 0;
        showMore = ApexPages.currentPage().getParameters().get('showmore') != null
        			? (ApexPages.currentPage().getParameters().get('showmore') == 'false' ? false : true) : false;
		userMappingList = new List<User_Mapping__c>(); 
        lastActivity = Date.Today();
        showOverlay = false; 
		String checkvalr = (ApexPages.currentPage().getParameters().get('helpoverlay') == null ? '' : ApexPages.currentPage().getParameters().get('helpoverlay'));
        Map<Decimal,DMNameValueWrapper> tempMapDM = new Map<Decimal,DMNameValueWrapper>();
        tempMapDM = new Map<Decimal,DMNameValueWrapper>();

        for (Data_Mapping__c dm : WithoutSharingHelperController.getDMHelpOverlay(new List<String> {UtilityController.appNamespace() + 'ReferenceRefreshPageSLDS'})) {
            tempMapDM.put(dm.Order__c, new DMNameValueWrapper(dm.Label__c,dm.DC_Message__c));
        }
        helpOverlay = JSON.serialize(tempMapDM); 

        if (checkvalr == '' && cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) {
            helpAssistant = '';
            checkForHelpOverlay();
        }
        
    }

    /**
    *   Method to check whether to show help overlay on page or not
    *   Author : Dixita @Sept 2018 REF-1860
    **/
    public void checkForHelpOverlay() {  
        showOverlay = true;  
        userMappingList = [SELECT Id, Label__c, Count__c, User__c, Last_Used_Lightning_Page__c FROM User_Mapping__c 
                                WHERE User__c =:UserInfo.getUserId() AND Label__c =:ConstantsController.PROFILE_HELP_OVERLAY  
                                LIMIT 1];

        if (userMappingList.Size() > 0 && userMappingList[0].Count__c != null && userMappingList[0].Count__c >= cs.Help_Overlay_Count__c) {
            showOverlay = false;
        }
        
        if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userMappingList.size() > 0 && userMappingList[0].Last_Used_Lightning_Page__c != null) {
            lastActivity = UtilityController.parseLastVisitDate(userMappingList[0].Last_Used_Lightning_Page__c); 
        }         
    }
    /**
     *   Method to check whether to show help overlay on page or not
     *   Author : Dixita @Sept 2018 REF-1860
     **/
    public void userMappingRecord() {       
        //  check user mapping count and custom setting count
        DateTime todayDate = system.today();
        if (showOverlay) {
                    
            if (userMappingList.Size() > 0) { 
            
                if (userMappingList[0].Count__c != null) {     
                    
                    if (cs.Reset_Help_Assistant_Days__c != null && lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c) {
                        helpAssistant = ConstantsController.HELP_ASSISTANT;
                        userMappingList[0].Count__c = 1; 
                    } else {
                        userMappingList[0].Count__c += 1;
                    }  
                } else {
                    userMappingList[0].Count__c = 1;
                }
                userMappingList[0].Last_Used_Lightning_Page__c = todayDate.format('yyyy-MM-dd');
                             
            } else {
                User_Mapping__c umr = new User_Mapping__c();
                umr.Label__c = ConstantsController.PROFILE_HELP_OVERLAY;
                umr.Count__c = 1;
                umr.User__c = UserInfo.getUserId();
                umr.Last_Used_Lightning_Page__c = todayDate.format('yyyy-MM-dd');
                userMappingList.add(umr);
            }  
             
        } else if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 
                    && (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0) 
                    && (lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c)) {
            helpAssistant = ConstantsController.HELP_ASSISTANT;
            userMappingList[0].Count__c = 1;
            userMappingList[0].Last_Used_Lightning_Page__c = todayDate.format('yyyy-MM-dd');
            showOverlay = true;
        }

        if (userMappingList.Size() > 0 && cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) { 
            upsert userMappingList;  
        }                 
    }
    
    /**
     * method to get the list of profile update records
     * author: Gaurav Saini (30 Aug, 2017)
     */
    @RemoteAction
    public static String getProfileUpdatesList(String userId) {
    	List<ProfileUpdateWrapper> profileUpdateWrapperList = new List<ProfileUpdateWrapper>();
    	
    	for (Reference_Refresh__c rr : WithoutSharingHelperController.getRefreshRecordsOrderByAccount(userId)) {
    		
            if (rr.Is_Active__c) {
                profileUpdateWrapperList.add(new ProfileUpdateWrapper(rr, profileUpdateWrapperList.size() + 1));
            }
    	}
    	return JSON.serialize(profileUpdateWrapperList);
    }
    
    /**
     * method to get the list of profile update records for specified page number
     * author: Gaurav Saini (30 Aug, 2017)
     */
    @RemoteAction
    public static String getProfileUpdatesListForPageNo(String userId, Integer accountPageNo) {
    	List<ProfileUpdateWrapper> profileUpdateWrapperList = new List<ProfileUpdateWrapper>();
    	
    	for (Reference_Refresh__c rr : WithoutSharingHelperController.getAllRefreshRecords(userId, ((accountPageNo + 1) * 10))) {
    		
            if (rr.Is_Active__c) {
                profileUpdateWrapperList.add(new ProfileUpdateWrapper(rr, profileUpdateWrapperList.size() + 1));
            }
    	}
    	return JSON.serialize(profileUpdateWrapperList);
    }
    
    /**
     * method to get the list of profile update records when user clicks next link in pagination
     * this method is called when the current page is present in the pagination map
     * author: Gaurav Saini (30 Aug, 2017)
     */
    @RemoteAction
    public static String getAlreadyPresentProfileUpdates(String userId, String profileUpdateIdsJSON) {
    	Set<String> profileUpdateIds = (Set<String>)JSON.deserialize(profileUpdateIdsJSON, Set<String>.class);
    	List<ProfileUpdateWrapper> profileUpdateWrapperList = new List<ProfileUpdateWrapper>();
    	
    	for (Reference_Refresh__c rr : WithoutSharingHelperController.getAllRefreshRecordsAlreadyPresent(userId, profileUpdateIds)) {
    		
            if (rr.Is_Active__c) {
                profileUpdateWrapperList.add(new ProfileUpdateWrapper(rr, profileUpdateWrapperList.size() + 1));
            }
    	}
    	return JSON.serialize(profileUpdateWrapperList);
    }
    
    /**
     * method to get the list of profile update records when user clicks next link in pagination
     * this method is called when the current page number is not present in the pagination map
     * author: Gaurav Saini (30 Aug, 2017)
     */
    @RemoteAction
    public static String getAlreadyNotPresentProfileUpdates(String userId, String alreadyPresentProfileUpdateIdsJSON) {
    	Set<String> alreadyPresentProfileUpdateIds = (Set<String>)JSON.deserialize(alreadyPresentProfileUpdateIdsJSON, Set<String>.class);
    	List<ProfileUpdateWrapper> profileUpdateWrapperList = new List<ProfileUpdateWrapper>();
    	
    	for (Reference_Refresh__c rr : WithoutSharingHelperController.getAllRefreshRecordsAlreadyNotPresent(userId, alreadyPresentProfileUpdateIds)) {
    		
            if (rr.Is_Active__c) {
                profileUpdateWrapperList.add(new ProfileUpdateWrapper(rr, profileUpdateWrapperList.size() + 1));
            }
    	}
    	return JSON.serialize(profileUpdateWrapperList);
    }
    
    /**
     * method to get map of account ids and all the corresponding contact ids
     * author: Gaurav Saini (30 Aug, 2017)
     */
    @RemoteAction
    public static String getAccountContactIdsMap(List<String> accountIds) {
    	Set<String> tempAccountIds = new Set<String>();
    	tempAccountIds.addAll(accountIds);
    	Map<String, Set<String>> accountContactsMap = WithoutSharingHelperController.getAccountContacts(tempAccountIds, cs);
    	return JSON.serialize(accountContactsMap);
    }
    
    /**
     * method to get the attribute mappings for accounts and contacts
     * author: Gaurav Saini (31 Aug, 2017)
     */
    @RemoteAction
    public static String getAttMappings() {
    	List<AttributeMappingWrapper> attMappingsList = new List<AttributeMappingWrapper>();
    	
    	for (Attribute_Mapping__c attMapping : [SELECT Id, Mapping_Type__c, RelationShip_Name__c, Object__c,
    											Is_Related_Mapping__c, Inheritable__c, Filter_Label_Name__c,
    											Field__c, Field_Api_Name__c, Child_RelationShipName__c
    											FROM Attribute_Mapping__c
    											WHERE (Object__c = :ConstantsController.ACCOUNT
    												OR Object__c = :ConstantsController.CONTACT)
    											ORDER BY Filter_Label_Name__c]) {
    		attMappingsList.add(new AttributeMappingWrapper(attMapping));
    	}
    	return JSON.serialize(attMappingsList);
    }
    
    /**
     * method to get profile update detail records for the selected profile update record
     * author: Gaurav Saini (31 Aug, 2017)
     */
    @RemoteAction
    public static String getProfileUpdateDetailList(String profileUpdateId) {
    	List<ProfileUpdateDetailWrapper> profileUpdateDetailList = new List<ProfileUpdateDetailWrapper>();
    	
    	for (Reference_Refresh__c rr : WithoutSharingHelperController.getRefreshRecord(profileUpdateId)) {
    		
    		for (Reference_Refresh_Update__c rru : rr.Reference_Refresh_Updates__r) {
    			profileUpdateDetailList.add(new ProfileUpdateDetailWrapper(rru));
    		}
    	}
    	return JSON.serialize(profileUpdateDetailList);
    }
    
    /**
     * method to get the selected account details
     * author: Gaurav Saini (1 Sep, 2017)
     */
    @RemoteAction
    public static String getAccountAttributesMap(String accountId, List<String> attributesToAddAccount1,
    												List<String> attributesToExcludeForAccount1) {
    	Set<String> attIds = new Set<String>();
    	Map<String, String> labelAttributes = new Map<String, String>();
    	String attributes = '';
    	Set<String> attributesToAddAccount = new Set<String>();
    	attributesToAddAccount.addAll(attributesToAddAccount1);
    	Set<String> attributesToExcludeForAccount = new Set<String>();
    	attributesToExcludeForAccount.addAll(attributesToExcludeForAccount1);
    	
    	for (Account_Attribute__c accAtt : WithoutSharingHelperController.getAccountAttributes(accountId)) {
    		
            if (!attributesToExcludeForAccount.contains(accAtt.Id)) {
                attIds.add(accAtt.Attribute__c);
            }
    	}
    	
        if (attributesToAddAccount.size() > 0) {
            attIds.addAll(attributesToAddAccount);
        }
        
        for (Attributes_Labels__c attLabels : [SELECT Label__r.Name, Attribute__r.Parent__r.Attribute_Mapping__c,
    											Attribute__r.Parent__r.Attribute_Mapping__r.Field_Api_Name__c,
    											Attribute__r.Parent__r.Attribute_Mapping__r.Object__c,
    											Attribute__c, Attribute__r.Name
    											FROM Attributes_Labels__c
    											WHERE Attribute__c IN :attIds]) {
            
            if (!labelAttributes.containsKey(attLabels.Label__r.Name)) {
                attributes = attLabels.Attribute__r.Name;
                labelAttributes.put(attLabels.Label__r.Name, attributes);
            } else {
                attributes = labelAttributes.get(attLabels.Label__r.Name);
                attributes += ', ' + attLabels.Attribute__r.Name;
                labelAttributes.put(attLabels.Label__r.Name, attributes);
            }
            attributes = '';
        }
        return JSON.serialize(labelAttributes);
    }
    
    /**
     * method to get the selected account referenceabilities
     * author: Gaurav Saini (2 Sep, 2017)
     */
    @RemoteAction
    public static String getAccountReferenceabilities(String accountId, List<String> refTypesToExcludeAccount1) {
    	List<ReferenceabilityWrapper> refWrapperList = new List<ReferenceabilityWrapper>();
    	Set<String> refTypesToExcludeAccount = new Set<String>();
    	refTypesToExcludeAccount.addAll(refTypesToExcludeAccount1);
    	
    	for (Referenceability__c ref : [SELECT Referenceability_Type__c, Referenceability_Type__r.Name
        								FROM Referenceability__c
        								WHERE Account__c = :accountId
        								AND Contact__c = null
        								AND Id NOT IN :refTypesToExcludeAccount]) {
    		refWrapperList.add(new ReferenceabilityWrapper(ref));
    	}
    	return JSON.serialize(refWrapperList);
    }
    
    /**
     * method to get the contacts for the selected account
     * author: Gaurav Saini (2 Sep, 2017)
     */
    @RemoteAction
    public static String getContactWrapperList(List<String> tempContactIds, String attMappingListJSON,
							String attributesToExcludeContactJSON, String attributeToAddContactJSON,
							String referenceabilityTypesToExcludeContactJSON, String referenceabilityToAddContactJSON) {
    	Set<String> contactIds = new Set<String>();
    	contactIds.addAll(tempContactIds);
    	Map<String, Set<String>> attributesToExcludeContact
			= (Map<String, Set<String>>)JSON.deserialize(attributesToExcludeContactJSON, Map<String, Set<String>>.class);
    	Map<String, Set<String>> attributeToAddContact
    		= (Map<String, Set<String>>)JSON.deserialize(attributeToAddContactJSON, Map<String, Set<String>>.class);
    	Map<String, Set<String>> referenceabilityTypesToExcludeContact
    		= (Map<String, Set<String>>)JSON.deserialize(referenceabilityTypesToExcludeContactJSON, Map<String, Set<String>>.class);
    	Map<String, Set<String>> referenceabilityToAddContact
    		= (Map<String, Set<String>>)JSON.deserialize(referenceabilityToAddContactJSON, Map<String, Set<String>>.class);
    	List<Contact> contactList = WithoutSharingHelperController.getContactMapOnProfileUpadte(contactIds);
    	List<ContactWrapper> contactWrapperList = new List<ContactWrapper>();
    	Map<String, Set<String>> contactAttributes = new Map<String, Set<String>>();
    	Set<String> attributeIds = new Set<String>();
        Map<String, String> labelAttributes = new Map<String, String>();
        Map<String, String> labelNameAttributeMappingId = new Map<String, String>();
        Map<String, Attributes_Labels__c> labelAttributeslabels = new Map<String, Attributes_Labels__c>();
    	List<AttributeMappingWrapper> attMappingsContact = (List<AttributeMappingWrapper>)JSON.deserialize(attMappingListJSON, List<AttributeMappingWrapper>.class);
    	
    	for (Contact con : contactList) {
            
            if (!contactAttributes.containsKey(con.Id)) {
                contactAttributes.put(con.Id, new Set<String>());
            }
            
            for (Contact_Attribute__c conAtt : con.Contact_Attributes__r) {
                
                if (!attributesToExcludeContact.get(con.Id).contains(conAtt.Id)) {
                    attributeIds.add(conAtt.Attribute__r.Id);
                    contactAttributes.get(con.Id).add(conAtt.Attribute__r.Id);
                }
            }
            
            if (attributeToAddContact.get(con.Id).size() > 0) {
                contactAttributes.get(con.Id).addAll(attributeToAddContact.get(con.Id));
                attributeIds.addAll(attributeToAddContact.get(con.Id));
            }
        }
    	
        for (Attributes_Labels__c attLabel : [SELECT Label__r.Name, Attribute__r.Parent__r.Attribute_Mapping__c,
    											Attribute__r.Parent__r.Attribute_Mapping__r.Object__c,
    											Attribute__r.Parent__r.Attribute_Mapping__r.Field_Api_Name__c,
    											Attribute__c, Attribute__r.Id, Attribute__r.Name
    											FROM Attributes_Labels__c
    											WHERE Attribute__c In :attributeIds]) {
            labelAttributeslabels.put(attLabel.Attribute__r.Id, attLabel);
        }
    	
    	for (Contact con : contactList) {
    		labelAttributes = new Map<String, String>();
            labelNameAttributeMappingId = new Map<String, String>();
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.contactName = con.Name;
            conWrap.contactId = con.Id;
            String referenceability = '';
            
            if (con.Reference_Basic_Informations__r != null && con.Reference_Basic_Informations__r.size() > 0) {
            	conWrap.contactRefStatus = con.Reference_Basic_Informations__r[0].Referenceability_Status__c;
            }
            
            for (Referenceability__c ref : con.Referenceabilities__r) {
            	
                if (!referenceabilityTypesToExcludeContact.get(con.Id).contains(ref.Id)) {
                	
                    if (referenceability == '') {
                        referenceability += ref.Referenceability_Type__r.Name;
                    } else if (!referenceability.contains(ref.Referenceability_Type__r.Name)) {
                        referenceability += ', ' + ref.Referenceability_Type__r.Name;
                    }
                }
            }
            
            for (String refType : referenceabilityToAddContact.get(con.Id)) {
                
                if (referenceability == '') {
                    referenceability += refType;
                } else if (!referenceability.contains(refType)) {
                    referenceability += ', ' + refType;
                }
            }
            conwrap.contactReferenceability = referenceability;
        	
            if (contactAttributes.containsKey(con.Id)) {
                conWrap.attributes = new List<AttributeWrapper>();
                
                for (String attId : contactAttributes.get(con.Id)) {
                	
                    if (labelAttributeslabels.containsKey(attId)) {
                        Attributes_Labels__c attLabel = labelAttributeslabels.get(attId);
                        String attributes = '';
                        
                        if (!labelAttributes.containsKey(attLabel.Label__r.Name)) {
                            attributes = attLabel.Attribute__r.Name;
                            labelAttributes.put(attLabel.Label__r.Name, attributes);
                        } else {
                            attributes = labelAttributes.get(attLabel.Label__r.Name);
                            attributes += ', ' + attLabel.Attribute__r.Name;
                            labelAttributes.put(attLabel.Label__r.Name, attributes);
                        }
                    }
                }
                Set<String> attMappingIds = new Set<String>();
                
                for (AttributeMappingWrapper attMapping : attMappingsContact) {
                	
                    if (attMapping.isRelatedMapping) {
                        AttributeWrapper temp = new AttributeWrapper();
                        temp.attMappingId = attMapping.id;
                        temp.labelName = attMapping.filterLabelName;
                        temp.isFromMapping = true;
                        temp.isRelatedMapping = true;
                        temp.parentAttributeMappingId = attMapping.FieldAPIName;
                        conWrap.attributes.add(temp);
                    } else {
                        AttributeWrapper temp = new AttributeWrapper();
                        temp.attMappingId = attMapping.id;
                        temp.labelName = attMapping.filterLabelName;
                        temp.isFromMapping = true;
                        temp.isRelatedMapping = false;
                        
                        if (labelAttributes.containsKey(attMapping.filterLabelName)) {
                            temp.attributes = labelAttributes.get(attMapping.filterLabelName);
                            attMappingIds.add(attMapping.filterLabelName);
                        }
                        temp.parentAttributeMappingId = attMapping.FieldAPIName;
                        conWrap.attributes.add(temp);
                    }
                }
                
                for (String labelName : labelAttributes.keySet()) {
                	
                    if (!attMappingIds.contains(labelName)) {
                        AttributeWrapper attW = new AttributeWrapper();
                        attW.labelName = labelName;
                        attW.attributes = labelAttributes.get(labelName);
                        conWrap.attributes.add(attW);
                    }
                }
            }
            contactWrapperList.add(conWrap);
    	}
    	return JSON.serialize(contactWrapperList);
    }
    
    /**
     * method to save the changes made to the reference profile and deactivate the profile upate record
     * author: Gaurav Saini (8 Sep, 2017)
     */
    @RemoteAction
    public static String saveUpdates(String selectedProfileUpdateId, Boolean isQuarantined, String selectedAccountId,
    				Boolean accountNotReferenceable, String accountNotReferenceableReason, String contactsListJSON,
    				String attWrapperListJSON, String accountReferenceability, Boolean isAccountActivated) {
    	
    	Savepoint sp = Database.setSavepoint();
    	String result = '';
		showOverlay = false;
    	
    	try {
	    	//ProfileUpdateWrapper selectedProfileUpdate = (ProfileUpdateWrapper)JSON.deserialize(selectedProfileUpdateJSON, ProfileUpdateWrapper.class);
	    	List<ContactWrapper> contactsList = (List<ContactWrapper>)JSON.deserialize(contactsListJSON, List<ContactWrapper>.class);
	    	List<AttributeWrapper> attWrapperList = (List<AttributeWrapper>)JSON.deserialize(attWrapperListJSON, List<AttributeWrapper>.class);
	    	List<Reference_Refresh__c> rr = WithoutSharingHelperController.getReferenceRefreshOnrefRefreshTrigger(new Set<String> { selectedProfileUpdateId });
	    	List<Reference_Refresh_Update__c> rrUpdatesNewRecords = new List<Reference_Refresh_Update__c>();
	    	List<Reference_Basic_Information__c> updateRBI = new List<Reference_Basic_Information__c>();
	    	Set<String> inactiveContactIds = new Set<String>();
	    	Set<String> activatedContactIds = new Set<String>();
	    	Map<String, Set<String>> mappedFieldsUpdateContact = new Map<String, Set<String>>();
	    	List<Reference_Refresh_Update__c> rrUpdatesCreated = new List<Reference_Refresh_Update__c>();
	    	Boolean isAccountAttributeUpdated = false;
	        Boolean isReferenceabilityUpdated = false;
	        Set<String> contactAttributeUpdate = new Set<String>();
	        Set<String> contactReferenceabilityUpdate = new Set<String>();
            //REF-1976
            List<Reference_Note__c> listOfReferenceNotes = new List<Reference_Note__c>();
            Map<String,String> mapContactIdContactNotReferenceableReason = new Map<String,String>();
            
            if (accountNotReferenceable) {
                Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                temp.No_Longer_a_Program_Member__c = true;
                temp.Not_A_Program_Member_Reason__c = accountNotReferenceableReason;
                temp.Reference_Refresh__c = selectedProfileUpdateId;
                temp.Account__c = selectedAccountId;
                
                if (!isQuarantined) {
                    temp.Accept_Reject__c = 'Accept';
                    List<Reference_Basic_Information__c> rbi = [SELECT Referenceability_Status__c, Is_Referenceable__c, Inactive_Reason__c
                                                                FROM Reference_Basic_Information__c
                                                                WHERE Account__c = :selectedAccountId
                                                                AND Contact__c = null];
                    
                    if (rbi.size() > 0) {
                        //REF-1976
                            rbi[0].Referenceability_Status__c = 'Inactive';
                            rbi[0].Inactive_Reason__c = accountNotReferenceableReason;
                            listOfReferenceNotes.add(new Reference_Note__c(Account__c = selectedAccountId, 
                                                                           Note__c = System.Label.Reason_For_Inactive + ' ' + accountNotReferenceableReason));
                            updateRBI.add(rbi[0]);
                    }
                }
                rrUpdatesNewRecords.add(temp);
            }
            
            if (isAccountActivated) {
                Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                temp.Program_Member_Activated__c = true;
                temp.Reference_Refresh__c = selectedProfileUpdateId;
                temp.Account__c = selectedAccountId;
                
                if (!isQuarantined) {
                    temp.Accept_Reject__c = 'Accept';
                    List<Reference_Basic_Information__c> rbi = [SELECT Referenceability_Status__c, Is_Referenceable__c
                                                                FROM Reference_Basic_Information__c
                                                                WHERE Account__c = :selectedAccountId
                                                                AND Contact__c = null];
                    
                    if (rbi.size() > 0) {
                        rbi[0].Referenceability_Status__c = ConstantsController.ACTIVE;
                        updateRBI.add(rbi[0]);
                    }
                }
                rrUpdatesNewRecords.add(temp);
            }
            
            for (ContactWrapper cw : contactsList) {
                
                if (cw.contactNotReferenceable) {
                    Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                    temp.No_Longer_a_Program_Member__c = true;
                    temp.Not_A_Program_Member_Reason__c = cw.contactNotReferenceableReason;
                    temp.Reference_Refresh__c = selectedProfileUpdateId;
                    temp.Account__c = selectedAccountId;
                    temp.Contact__c = cw.contactId;
                    
                    if (!isQuarantined) {
                        temp.Accept_Reject__c = 'Accept';
                        inactiveContactIds.add(cw.contactId);
                        //REF-1976
                        mapContactIdContactNotReferenceableReason.put(cw.contactId, cw.contactNotReferenceableReason);
                    }
                    rrUpdatesNewRecords.add(temp);
                }
                
                if (cw.isContactActivated) {
                    Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
                    temp.Program_Member_Activated__c = true;
                    temp.Reference_Refresh__c = selectedProfileUpdateId;
                    temp.Account__c = selectedAccountId;
                    temp.Contact__c = cw.contactId;
                    
                    if (!isQuarantined) {
                        temp.Accept_Reject__c = 'Accept';
                        activatedContactIds.add(cw.contactId);
                    }
                    rrUpdatesNewRecords.add(temp);
                }
            }
            
            if (inactiveContactIds.size() > 0) {
                
                for (Reference_Basic_Information__c rbi : [SELECT Referenceability_Status__c, Is_Referenceable__c, Inactive_Reason__c, contact__c
                                                            FROM Reference_Basic_Information__c
                                                            WHERE Contact__c IN :inactiveContactIds]) {
                    //REF-1976
                    rbi.Referenceability_Status__c = 'Inactive';
                    rbi.Inactive_Reason__c = mapContactIdContactNotReferenceableReason.get(rbi.contact__c);
                    listOfReferenceNotes.add(new Reference_Note__c(Contact__c = rbi.contact__c, 
                                                                   Note__c = System.Label.Reason_For_Inactive + ' ' + rbi.Inactive_Reason__c));
                    updateRBI.add(rbi);
                }
            }
            
            if (activatedContactIds.size() > 0) {
                
                for (Reference_Basic_Information__c rbi : [SELECT Referenceability_Status__c, Is_Referenceable__c
                                                            FROM Reference_Basic_Information__c
                                                            WHERE Contact__c IN :activatedContactIds]) {
                    rbi.Referenceability_Status__c = ConstantsController.ACTIVE;
                    updateRBI.add(rbi);
                }
            }
            
            if (updateRBI.size() > 0) {
                WithoutSharingHelperController.updateRBI(updateRBI);
            }
            
            //REF-1976
            if (listOfReferenceNotes.size() > 0) {
                WithoutSharingHelperController.insertReferenceNotes(listOfReferenceNotes);
            }
	        
	        for (Reference_Refresh_Update__c rru : [SELECT Contact__c, Id, Referenceability__c, ReferenceabilityComment__c,
	    											Reference_Refresh__c, RecordsToBeInsertedId__c, RecordToBeDeletedId__c,
	    											Not_A_Program_Member_Reason__c, No_Longer_a_Program_Member__c, No_Change__c,
	    											Field_Api_Name_To_Be_Updated__c, Attribute__c, Account__c, Accept_Reject__c
	    											FROM Reference_Refresh_Update__c
	    											WHERE Reference_Refresh__c = :selectedProfileUpdateId]) {
	        	rrUpdatesCreated.add(rru);
	        	
	            if (rru.Account__c != null && rru.Contact__c == null && rru.Attribute__c && !isAccountAttributeUpdated) {
	                isAccountAttributeUpdated = true;
	            }
	            
	            if (rru.Account__c != null && rru.Contact__c == null && rru.Referenceability__c && !isReferenceabilityUpdated) {
	                isReferenceabilityUpdated = true;
	            }
	            
	            if (rru.Contact__c != null && rru.Attribute__c) {
	                contactAttributeUpdate.add(rru.contact__c);
	            }
	            
	            if (rru.Contact__c != null && rru.Referenceability__c) {
	                contactReferenceabilityUpdate.add(rru.contact__c);
	            }
	        }
	        
	        for (AttributeWrapper aw : attWrapperList) {
	        	
	            if (aw.isFromMapping && !aw.isRelatedMapping && aw.attributes != null && aw.attributes != '') {
	                Reference_Refresh_Update__c rru = new Reference_Refresh_Update__c();
	                rru.Account__c = selectedAccountId;
	                rru.No_Change__c = true;
	                rru.No_change_value__c = aw.attributes;
	                rru.Field_Api_Name_To_Be_Updated__c = aw.parentAttributeMappingId;
	                rru.Reference_Refresh__c = selectedProfileUpdateId;
	                rrUpdatesNewRecords.add(rru);
	            }
	        }
	    	
	    	if (!isAccountAttributeUpdated) {
	            String attValue = '';
	            
	            for (AttributeWrapper aw : attWrapperList) {
	            	
	                if (!aw.isFromMapping) {
	                	
	                    if (attValue == '') {
	                        attValue += aw.attributes;
	                    } else {
	                        attValue += ', ' + aw.attributes;
	                    }
	                }
	            }
	            
	            if (attValue != null && attValue != '') {
	                Reference_Refresh_Update__c rru = new Reference_Refresh_Update__c();
	                rru.Account__c = selectedAccountId;
	                rru.No_Change__c = true;
	                rru.Attribute__c = true;
	                rru.Reference_Refresh__c = selectedProfileUpdateId;
	                rru.No_change_value__c = attValue;
	                rrUpdatesNewRecords.add(rru);
	            }
	        }
	    	
	        if (!isReferenceabilityUpdated && accountReferenceability != '') {
	            Reference_Refresh_Update__c rru = new Reference_Refresh_Update__c();
	            rru.Account__c = selectedAccountId;
	            rru.No_Change__c = true;
	            rru.No_change_value__c = accountReferenceability;
	            rru.Referenceability__c = true;
	            rru.Reference_Refresh__c = selectedProfileUpdateId;
	            rrUpdatesNewRecords.add(rru);
	        }
	        
	        for (ContactWrapper cw : contactsList) {
	        	
	        	if (!contactReferenceabilityUpdate.contains(cw.contactId)
	            			&& cw.contactReferenceability != null
	            			&& cw.contactReferenceability != '') {
	                Reference_Refresh_Update__c rru = new Reference_Refresh_Update__c();
	                rru.Contact__c = cw.contactId;
	                rru.Account__c = selectedAccountId;
	                rru.No_Change__c = true;
	                rru.No_change_value__c = cw.contactReferenceability;
	                rru.Referenceability__c = true;
	                rru.Reference_Refresh__c = selectedProfileUpdateId;
	                rrUpdatesNewRecords.add(rru);
	            }
	            
	            if (!contactAttributeUpdate.contains(cw.contactId)) {
	                String attValue = '';
	                
	                for (AttributeWrapper aw : cw.attributes) {
	                	
	                    if (!aw.isFromMapping) {
	                    	
	                        if (attValue == '') {
	                            attValue += aw.attributes;
	                        } else {
	                            attValue += ', ' + aw.attributes;
	                        }
	                    }
	                }
	                
	                if (attValue != null && attValue != '') {
	                    Reference_Refresh_Update__c rru = new Reference_Refresh_Update__c();
	                    rru.Contact__c = cw.contactId;
	                    rru.Account__c = selectedAccountId;
	                    rru.No_Change__c = true;
	                    rru.Attribute__c = true;
	                    rru.Reference_Refresh__c = selectedProfileUpdateId;
	                    rru.No_change_value__c = attValue;
	                    rrUpdatesNewRecords.add(rru);
	                }
	            }
	            
	            for (AttributeWrapper aw : cw.attributes) {
	            	
	                if (aw.isFromMapping && !aw.isRelatedMapping && aw.attributes != null && aw.attributes != '') {
	                    Reference_Refresh_Update__c rru = new Reference_Refresh_Update__c();
	                    rru.Contact__c = cw.contactId;
	                    rru.Account__c = selectedAccountId;
	                    rru.No_Change__c = true;
	                    rru.No_change_value__c = aw.attributes;
	                    rru.Field_Api_Name_To_Be_Updated__c = aw.parentAttributeMappingId;
	                    rru.Reference_Refresh__c = selectedProfileUpdateId;
	                    rrUpdatesNewRecords.add(rru);
	                }
	            }
	        }
	        
            if (rrUpdatesNewRecords.size() > 0) {
                WithoutSharingHelperController.upsertRefreshUpdateRecords(rrUpdatesNewRecords);
            }
            
            if (!isQuarantined) {
            	rr[0].Is_Active__c = false;
            	rr[0].Reference_Refresh_Status__c = 'Profile Update Completed';
            } else {
            	rr[0].Reference_Refresh_Status__c = 'Pending Approval';
            }
            rr = WithoutSharingHelperController.upsertReferenceRefresh(rr);
	        String sendMailResult = '';
	        
            if (isQuarantined) {
                sendMailResult = sendMailTeam(rrUpdatesNewRecords);
            }
            Set<String> contactIdsTemp = new Set<String>();
            
            for (ContactWrapper cw : contactsList) {
                contactIdsTemp.add(cw.contactId);
            }
            List<Reference_Basic_Information__c> rbi = [SELECT Last_Refresh_Date__c, Last_Refresh_By__c
            											FROM Reference_Basic_Information__c
            											WHERE Id = :rr[0].Reference_Profile__c
                                                        OR Contact__c IN :contactIdsTemp];
            
            if (rbi.size() > 0) {
                
                for (Reference_Basic_Information__c refProfile : rbi) {
                    refProfile.Last_Refresh_Date__c = DateTime.now();
                    refProfile.Last_Refresh_By__c = Userinfo.getUserId();
                }
                WithoutSharingHelperController.updateRBI(rbi);
            }
            result = 'success';
            
            if (!RefEdgeEditionFeatures.isBasic && cs.Enable_Sales_Rewards_Notification__c) {
    			List<String> lstUserAction = new List<String>();
            	lstUserAction.add(ConstantsController.PROFILE_UPDATE);
	            List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);
	            
	        	if (refType.size() > 0 && refType[0].Sales_Point__c != null) {
	        		List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
				    rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
			    										Referenceability_Type__c = refType[0].Id,
			    										Transaction__c = ConstantsController.ISSUE,
			    										RewardDate__c = Date.Today(),
			    										User__c = Userinfo.getUserId()));
				    UtilityController.isUserProfileExist(Userinfo.getUserId());
				    
				    if (rewardsToBeInsert.size() > 0) {
		             	WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
		         	}
		         	
		            if (cs.User_Reward_Onscreen_Notification__c) {
			         	result = result + '***' + refType[0].Sales_Point__c + '***' + refType[0].Name;
		            }
	        	}
            }
    	} catch(Exception e) {
    		Database.rollback(sp);
    		return e.getMessage();
    	}
    	return result;
    }
    
    /**
     * method to get list of non referenceable contacts for the selected account
     * 
     * author: Gaurav Saini (18 Sep, 2017) for #625
     */
    @RemoteAction
    public static String getNonReferenceableContacts(String accountId) {
    	List<NonReferenceableContactWrapper> contacts = new List<NonReferenceableContactWrapper>();
    	contacts.add(new NonReferenceableContactWrapper(null));
    	
    	for (Contact con : WithoutSharingHelperController.getAccountContacts(accountId, cs)) {
    		
    		if (con.Reference_Basic_Informations__r != null && con.Reference_Basic_Informations__r.size() > 0) {
    			
    			if (!con.Reference_Basic_Informations__r[0].Is_Referenceable__c) {
    				contacts.add(new NonReferenceableContactWrapper(con));
    			}
    		} else {
    			contacts.add(new NonReferenceableContactWrapper(con));
    		}
    	}
    	return JSON.serialize(contacts) + '@@@' + cs.PUM_New_Contact__c;
    }
    
    private static String sendMailTeam(List<Reference_Refresh_Update__c> rrUpdatesNewRecords) {
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        List<sObject> postFeedItems = new List<sObject>();
        
		//REF-1316- Added check for CRP team member should be active
		List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam();												
        String firstId = '';
        Boolean checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Reference_Refresh_Update_Chatter__c);
        Boolean checkEmailSetting = cs.Reference_Refresh_Update_Email__c;
        Boolean checkSlackSetting = cs.Enable_Slack_Integration__c && cs.Reference_Refresh_Update_Slack__c;
        Data_Mapping__c profileUpdateNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Reference_Refresh_Update_Email__c'};
        String headerDocId = '';
        String footerDocId = '';

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Reference_Refresh_Update_Email__c') {
                profileUpdateNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();

        String notificationBody = profileUpdateNotification.DC_Message__c + '\n' + profileUpdateNotification.Default__c;
        String updatedNames = '';

        for (Reference_Refresh_Update__c rru : WithoutSharingHelperController.getRefreshUpdateRecords(rrUpdatesNewRecords)) {
            
            if (rru.Account__c != null) {
                
                if (!updatedNames.contains(rru.Account__r.Name)) {
                    updatedNames += '\n' + rru.Account__r.Name;
                }
            }
            
            if (rru.Contact__c != null) {
                
                if (!updatedNames.contains(rru.Contact__r.Name)) {
                    updatedNames += '\n' + rru.Contact__r.Name;
                }
            }
            firstId = String.valueOf(rru.id).substring(0, 3);
        }
        notificationBody = notificationBody.replace('[Account/Contact Name]', updatedNames);
        String RefRefreshURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + firstId;
        
        if (publicGroupMembers.size() > 0) {
            
            if (checkChatterSetting) {
                
                for (User gm : publicGroupMembers) {
                    String userId = gm.Id;
                    
            		if (userId.startsWith('005')) {
                    	postFeedItems.add(MailChatterController.preparePost(profileUpdateNotification.Section_Name__c, userId, notificationBody, RefRefreshURL));
            		}
                }
            }
            
            if (checkEmailSetting) {
            	
                for (User gm : publicGroupMembers) {
                    String userId = gm.Id;
                    
            		if (userId.startsWith('005')) {
                        listmail.add(MailChatterController.prepareEmail(profileUpdateNotification.Section_Name__c, userId,
                                            notificationBody + '\n\n' + profileUpdateNotification.Section_Name__c + ': ' + '<a href="'
                                            + RefRefreshURL + '">' + RefRefreshURL + '</a>', false, headerDocId, footerDocId));
            		}
                }
            }
        }

        if (checkSlackSetting) {
            Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('text', notificationBody + '\n<' + RefRefreshURL + '|' + profileUpdateNotification.Section_Name__c + '>');
            messagesList.add(tempReqBodyMap);
        }

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
        }
        
        // Insert list of postFeedItems
        if (postFeedItems.size() > 0) {
            postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
        }
        
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
        return 'success';
    }

    /**
     * method to to make contact inactive REF-1976
    */
    @RemoteAction
    public static String makeContactInactive(String selectedContactId, String contactNotReferenceableReason) {
        List<Reference_Basic_Information__c> updateRBI = [SELECT Referenceability_Status__c, Is_Referenceable__c, Inactive_Reason__c, Contact__c
                                                          FROM Reference_Basic_Information__c
                                                          WHERE Contact__c =:selectedContactId];
        List<Reference_Note__c> listOfReferenceNotes = new List<Reference_Note__c>();
        
        if (updateRBI != null) {
            updateRBI[0].Referenceability_Status__c = 'Inactive';
            updateRBI[0].Inactive_Reason__c = contactNotReferenceableReason;
            listOfReferenceNotes.add(new Reference_Note__c(Contact__c = updateRBI[0].Contact__c, 
                                                           Note__c = System.Label.Reason_For_Inactive + ' ' + updateRBI[0].Inactive_Reason__c));  
        }
        
        if (listOfReferenceNotes.size() > 0) {
            WithoutSharingHelperController.updateRBI(updateRBI);
            WithoutSharingHelperController.insertReferenceNotes(listOfReferenceNotes);
        }
        
        return selectedContactId;
    }
    
    public class ProfileUpdateWrapper {
    	public String id { get; set; }
    	public String accountId { get; set; }
    	public String accountName { get; set; }
    	public String refProfileId { get; set; }
    	public String accountRefStatus { get; set; }
    	public String lastValidatorId { get; set; }
    	public String lastValidatorName { get; set; }
    	public DateTime lastValidatedDate { get; set; }
    	public Integer recordIndex { get; set; }
    	public String ownerId { get; set; }
    	public String ownerName { get; set; }
    	public String refOwnerName { get; set; }
    	public String refOwnerId { get; set; }
    	public String accOwnerName { get; set; }
    	public String accOwnerId { get; set; }
    	public Boolean isQuarantined { get; set; }
    	public Boolean isSelected { get; set; }
    	
    	public ProfileUpdateWrapper(Reference_Refresh__c rr, Integer recordIndex) {
    		this.id = rr.Id;
    		this.accountId = rr.Reference_Account__c != null ? (String)rr.Reference_Account__c : '';
    		this.accountName = rr.Reference_Account__c != null ? rr.Reference_Account__r.Name : '';
    		this.refProfileId = rr.Reference_Profile__c != null ? (String)rr.Reference_Profile__c : '';
    		this.accountRefStatus = rr.Reference_Profile__c != null ? rr.Reference_Profile__r.Referenceability_Status__c : '';
    		this.lastValidatorId = rr.Reference_Profile__c != null && rr.Reference_Profile__r.Last_Refresh_By__c != null ? (String)rr.Reference_Profile__r.Last_Refresh_By__c : '';
    		this.lastValidatorName = rr.Reference_Profile__c != null && rr.Reference_Profile__r.Last_Refresh_By__c != null ? rr.Reference_Profile__r.Last_Refresh_By__r.Name : '';
    		this.lastValidatedDate = rr.Reference_Profile__r.Last_Refresh_Date__c;
    		this.recordIndex = recordIndex;
    		this.ownerId = rr.Reference_Refresh_Owner__c != null ? (String)rr.Reference_Refresh_Owner__c : '';
    		this.ownerName = rr.Reference_Refresh_Owner__c != null ? rr.Reference_Refresh_Owner__r.Name : '';
    		this.refOwnerName = rr.Reference_Profile__c != null && rr.Reference_Profile__r.Reference_Owner__c != null ? rr.Reference_Profile__r.Reference_Owner__r.Name : '';
    		this.refOwnerId = rr.Reference_Profile__c != null && rr.Reference_Profile__r.Reference_Owner__c != null ? (String)rr.Reference_Profile__r.Reference_Owner__c : '';
    		this.accOwnerName = rr.Reference_Account__c != null ? rr.Reference_Account__r.Owner.Name : '';
    		this.accOwnerId = rr.Reference_Account__c != null ? (String)rr.Reference_Account__r.OwnerId : '';
    		this.isQuarantined = rr.Quarantined__c;
    		this.isSelected = false;
    	}
    }
    
    public class ProfileUpdateDetailWrapper {
    	public String accountId { get; set; }
    	public String contactId { get; set; }
    	public String acceptReject { get; set; }
    	public String recordIdToInsert { get; set; }
    	public String recordIdToDelete { get; set; }
    	public String changedTo { get; set; }
    	public Boolean isAdded { get; set; }
    	public Boolean isRemoved { get; set; }
    	public Boolean isAttribute { get; set; }
    	public Boolean isReferenceability { get; set; }
    	
    	public ProfileUpdateDetailWrapper(Reference_Refresh_Update__c rru) {
    		this.accountId = rru.Account__c != null ? (String)rru.Account__c : '';
    		this.contactId = rru.Contact__c != null ? (String)rru.Contact__c : '';
    		this.acceptReject = rru.Accept_Reject__c != null ? rru.Accept_Reject__c : '';
    		this.recordIdToInsert = rru.RecordsToBeInsertedId__c != null ? rru.RecordsToBeInsertedId__c : '';
    		this.recordIdToDelete = rru.RecordToBeDeletedId__c != null ? rru.RecordToBeDeletedId__c : '';
    		this.changedTo = rru.Changed_To__c != null ? rru.Changed_To__c : '';
    		this.isAdded = rru.Added__c;
    		this.isRemoved = rru.Removed__c;
    		this.isAttribute = rru.Attribute__c;
    		this.isReferenceability = rru.Referenceability__c;
    	}
    }
    
    public class AttributeMappingWrapper {
    	public String id { get; set; }
    	public String objectName { get; set; }
    	public String mappingType { get; set; }
    	public String relationshipName { get; set; }
    	public Boolean isRelatedMapping { get; set; }
    	public Boolean inheritable { get; set; }
    	public String filterLabelName { get; set; }
    	public String field { get; set; }
    	public String fieldAPIName { get; set; }
    	public String childRelationshipName { get; set; }
    	
    	public AttributeMappingWrapper(Attribute_Mapping__c attMapping) {
    		this.id = attMapping.Id;
    		this.objectName = attMapping.Object__c;
    		this.mappingType = attMapping.Mapping_Type__c != null ? attMapping.Mapping_Type__c : '';
    		this.relationshipName = attMapping.RelationShip_Name__c != null ? attMapping.RelationShip_Name__c : '';
    		this.isRelatedMapping = attMapping.Is_Related_Mapping__c;
    		this.inheritable = attMapping.Inheritable__c;
    		this.filterLabelName = attMapping.Filter_Label_Name__c != null ? attMapping.Filter_Label_Name__c : '';
    		this.field = attMapping.Field__c != null ? attMapping.Field__c : '';
    		this.fieldAPIName = attMapping.Field_Api_Name__c != null ? attMapping.Field_Api_Name__c : '';
    		this.childRelationshipName = attMapping.Child_RelationShipName__c != null ? attMapping.Child_RelationShipName__c : '';
    	}
    }
    
    public class AttributeWrapper {
        public String labelName { get; set; }
        public String attributes { get; set; }
        public String attMappingId { get; set; }
        public Boolean isFromMapping { get; set; }
        public Boolean noChange { get; set; }
        public Boolean isRelatedMapping { get; set; }
        public String parentAttributeMappingId { get; set; }
        
        public AttributeWrapper() {
            noChange = false;
            isFromMapping = false;
        }
    }
    
    public class ReferenceabilityWrapper {
    	public String refTypeId { get; set; }
    	public String refTypeName { get; set; }
    	public Boolean noChange { get; set; }
        public Boolean updated { get; set; }
    	
    	public ReferenceabilityWrapper(Referenceability__c ref) {
    		this.refTypeId = ref.Referenceability_Type__c;
    		this.refTypeName = ref.Referenceability_Type__r.Name;
    		this.noChange = false;
    	}
    }
    
    public class ContactWrapper {
        public String contactName { get; set; }
        public String contactId { get; set; }
        public String contactReferenceability { get; set; }
        public String contactRefStatus { get; set; }
        public Boolean contactNoChange { get; set; }
        public Boolean refNoChange { get; set; }
        public Boolean refUpdated { get; set; }
        public Boolean isNotReferenceableClicked { get; set; }
        public Boolean contactNotReferenceable { get; set; }
        public String contactNotReferenceableReason { get; set; }
        public List<AttributeWrapper> attributes { get; set; }
        public Boolean isContactActivated { get; set; }
        
        public ContactWrapper() {
            this.contactNoChange = false;
            this.refNoChange = false;
            this.contactNotReferenceable = false;
            this.isNotReferenceableClicked = false;
            this.isContactActivated = false;
        }
    }
    
    public class NonReferenceableContactWrapper {
    	public String name { get; set; }
    	public string id { get; set; }
    	
    	public NonReferenceableContactWrapper(Contact con) {
    		this.name = con != null ? con.Name : '--None--';
    		this.id = con != null ? (String)con.Id : '';
    	}
    }

    /**
     * Wrapper class
    */
    public class DMNameValueWrapper {
        public String header {get;set;}
        public String value {get;set;}
        public DMNameValueWrapper(String header, String value) {
            this.value = value;
            this.header = header;
        }
    }
}