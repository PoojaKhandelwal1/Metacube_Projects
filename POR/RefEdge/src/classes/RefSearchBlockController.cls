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
 * VF Page: RfSearchLightning
 * VF Components: AccountSearchBlock, ContactSearchBlock, ContentSearchBlock
 * Description: Controller for Ref Search Lightning page 
 * Last modified by: Rekha @21 April 2017
 */
global with sharing class RefSearchBlockController extends RefEdgeEditionFeatures {
    private Custom_Settings__c cs = UtilityController.getCustomSettings();    
     
    /**
     * Properties and variables
     */

    public Boolean isViewDetailsUpdateable {        
        get {       
                    
            if (isViewDetailsUpdateable == null) {      
                isViewDetailsUpdateable = Schema.sObjectType.Reference_Content__c.fields.getMap().get(UtilityController.appNamespace() + 'Ref_Content_View_Details_Clicks__c').getDescribe().isUpdateable();       
            }       
            return isViewDetailsUpdateable;     
        }       
        set;        
    }
    public Decimal RULPeriodLength {
        get {
            
            if (RULPeriodLength == null) {
                RULPeriodLength = cs.RUL_Period__c;
            }
            return RULPeriodLength;
        }
        set;
    }
    public Decimal maxAccountRequests {
        get {
            return (cs.Number_of_request_accounts__c != null ? cs.Number_of_request_accounts__c : 0);
        }
        set;
    }
    public Decimal RULPeriodLengthContact {
        get {
            
            if (RULPeriodLengthContact == null) {
                RULPeriodLengthContact = cs.RUL_Period_Contact__c;
            }
            return RULPeriodLengthContact;
        }
        set;
    }
    public Boolean ShowFeaturedContentFirst{
        get {
            
            if (ShowFeaturedContentFirst== null) {
                ShowFeaturedContentFirst= cs.Show_Featured_Content_First__c;
            }
            return ShowFeaturedContentFirst;
        }
        set;
    }
    public Boolean isBasicEdition {
        get { return isBasic; }
        set;
    }
    // this flag is used to show/hide the contacts section on refSearch page
    // based on the Show Contacts on RefSearch checkbox accessibility
    // and its value.
    public Boolean isContactsVisible {
        get {
            Boolean isFieldAccessible = Schema.sObjectType.Custom_Settings__c.fields.getMap().
                                            get(UtilityController.appNamespace() + 'show_contacts_in_refsearch__c').
                                            getDescribe().isAccessible();
            Boolean fieldValue = cs.Show_Contacts_in_RefSearch__c;
            
            if (isFieldAccessible && fieldValue) {
                return true;
            } else {
                return false;
            }
        }
        set;
    }    
    public Boolean showOwner {        
        get {       
                    
            if (showOwner == null) {      
                showOwner = cs.Show_Owner_in_Ref_Search__c;       
            }       
            return showOwner;     
        }       
        set;        
    }
    public String refContentIds { get; set; }
    public String trackRecord { get; set; }
    public String opportunityId { get; set; }
    public String caseId { get; set; }
    public String leadId { get; set; }    
    // added for #582 - to check if user arrives from ref search tab for leads
    public Boolean fromLead { get; set; }
    public Boolean forAccount { get; set; }
    public Boolean forContent { get; set; }
    public Boolean isCRMContentUser { get; set; }
    public Boolean isCollectionCreateable { get; set; }
    public Boolean isReturned { get; set; }
    public String contactIds { get; set; }
    public String userIds { get; set; }
    public String recipientsIds {get; set; }
    public String emailSubject { get; set; }
    public String emailContent {get;set; }
    public String invitaionName { get; set; }
    public String note { get; set; }
    public String selectedMictosite { get; set; }
    public String expDate { get; set; }
    public Boolean isCcAllowed { get; set; }
    public String emailTo { get; set; }
    public String emailBcc { get; set; }
    public String emailCc { get; set; }
    public String opportunityAccount { get; set; }
    public String opportunityName { get; set; }
    public Boolean preFilter { get; set; }    
    //re #362 - Custom Setting decide default value for filters (Any or All)    
    public String searchFilterDefault { get; set; }
    // added for #809
    public Boolean allowRequestFromLead { get; set; }
    //to resolve namespace issue on package creation
    public String nameSpace {
        get {
            return UtilityController.appNamespace();
        }
        private set;
    }
    // Change related 1288
    private boolean isOverlay;
    public boolean showOveray { get; set; }
    public Boolean isUpdateRefSearchUsageCount { get; set; }
    private List<User_Mapping__c> userMappingList;
    private String labelValue = '';
    public Boolean isRefMatch { get; set; }
    //REF-1964
    public Boolean isHubMatch { get; set; }
    
    public String refRequestId { get; set; }
    public String accRequestId { get; set; }
    public String unspecRequestId { get; set; }
    public String projectType { get; set; }
    public String dateFormat { get; set; }
    public Boolean sharedContactsEnabled { get; set; }
    public String helpAssistant { get; set; }
    public String helpOverlay { get; set; }
    public Date lastActivity;
    // added for REF-1341 - Gaurav Saini (6 Sep, 2018)
    public String selectedAccIdsParam { get; set; }

    // Added for REF-1947 - Rajneesh Raj(Oct 04, 2018)    
    public Boolean showRelatedRefContent {        
        get {       
                    
            if (showRelatedRefContent == null) {      
                showRelatedRefContent = cs.Show_Related_Ref_Content_in_RefSearch__c;       
            }       
            return showRelatedRefContent;     
        }       
        set;        
    }

    /**
     * Constructor
     */
    global RefSearchBlockController() {
        refContentIds = '';
        selectedAccIdsParam = ApexPages.currentPage().getParameters().get('selectedAccIdsParam') != null
                            ? ApexPages.currentPage().getParameters().get('selectedAccIdsParam') : '';
        //system.assert(false, '==>' + selectedAccIdsParam);
        opportunityId = '';
        preFilter = false;
        caseId = '';
        leadId = '';
        fromLead = false; 
        forAccount = false;
        forContent = false;
        isRefMatch = false;
        sharedContactsEnabled = cs.Shared_Contacts__c;
        dateFormat = ConstantsController.localeDateFormatMap.containsKey(UserInfo.getLocale())
                    ? ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0) : 'yyyy-MM-dd';
        // changes for #809 - Gaurav Saini (10 Apr, 2017)
        allowRequestFromLead = cs.Request_from_Leads__c;
        refRequestId = ApexPages.currentPage().getParameters().get('rrId') != null
                        ? ApexPages.currentPage().getParameters().get('rrId') : '';
        accRequestId = ApexPages.currentPage().getParameters().get('arId') != null
                        ? ApexPages.currentPage().getParameters().get('arId') : '';
        unspecRequestId = ApexPages.currentPage().getParameters().get('urId') != null
                        ? ApexPages.currentPage().getParameters().get('urId') : '';
        projectType = ApexPages.currentPage().getParameters().get('projectType') != null
                        ? ApexPages.currentPage().getParameters().get('projectType') : '';
        
        if (ApexPages.currentPage().getParameters().get('refContentIds') != null) {
            refContentIds = ApexPages.currentPage().getParameters().get('refContentIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('isRefMatch') != null) {
            isRefMatch = ApexPages.currentPage().getParameters().get('isRefMatch') == 'true' ? true : false;
        }
        
        //REF-1964
        if (ApexPages.currentPage().getParameters().get('isHubMatch') != null) {
            isHubMatch = ApexPages.currentPage().getParameters().get('isHubMatch') == 'true' ? true : false;
        }
        
        if (ApexPages.currentPage().getParameters().get('fromLead') != null) {
            fromLead = ApexPages.currentPage().getParameters().get('fromLead') == 'true' ? true : false;
        }
        
        if (String.isNotBlank(ApexPages.currentPage().getParameters().get('opportunityId'))) {
            opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
            preFilter = true;
        }
        
        if (ApexPages.currentPage().getParameters().get('forAccount') != null) {
            forAccount = (ApexPages.currentPage().getParameters().get('forAccount') == 'true' ? true : false);
        }
        
        if (ApexPages.currentPage().getParameters().get('forContent') != null) {
            forContent = (ApexPages.currentPage().getParameters().get('forContent') == 'true' ? true : false);
        }
        
        if (ApexPages.currentPage().getParameters().get('caseId') != null) {
            caseId = ApexPages.currentPage().getParameters().get('caseId');
        } 
        
        if (ApexPages.currentPage().getParameters().get('leadId') != null) {
            leadId = ApexPages.currentPage().getParameters().get('leadId');
            fromLead = true;
        }
        
        if (ApexPages.currentPage().getParameters().get('isReturned') != null) {
            isReturned = (ApexPages.currentPage().getParameters().get('isReturned') == 'true' ? true : false);
        }
        
        if (ApexPages.currentPage().getParameters().get('contactIds') != null) {
            contactIds = ApexPages.currentPage().getParameters().get('contactIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('userIds') != null) {
            userIds = ApexPages.currentPage().getParameters().get('userIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('recipientsIds') != null) {
            recipientsIds = ApexPages.currentPage().getParameters().get('recipientsIds');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailSubject') != null) {
            emailSubject = ApexPages.currentPage().getParameters().get('emailSubject');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailContent') != null) {
            emailContent = ApexPages.currentPage().getParameters().get('emailContent');
        }
        
        if (ApexPages.currentPage().getParameters().get('invitaionName') != null) {
            invitaionName = ApexPages.currentPage().getParameters().get('invitaionName');
        }
        
        if (ApexPages.currentPage().getParameters().get('note') != null) {
            note = ApexPages.currentPage().getParameters().get('note');
        }
        
        if (ApexPages.currentPage().getParameters().get('selectedMictosite') != null) {
            selectedMictosite = ApexPages.currentPage().getParameters().get('selectedMictosite');
        }
        
        if (ApexPages.currentPage().getParameters().get('expDate') != null) {
            expDate = ApexPages.currentPage().getParameters().get('expDate');
        }
        
        if (ApexPages.currentPage().getParameters().get('isCcAllowed') != null) {
            isCcAllowed = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isCcAllowed'));
        }
        
        if (ApexPages.currentPage().getParameters().get('emailTo') != null) {
            emailTo = ApexPages.currentPage().getParameters().get('emailTo');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailBcc') != null) {
            emailBcc = ApexPages.currentPage().getParameters().get('emailBcc');
        }
        
        if (ApexPages.currentPage().getParameters().get('emailCc') != null) {
            emailCc = ApexPages.currentPage().getParameters().get('emailCc');
        }
        
        if (ApexPages.currentPage().getParameters().get('opportunityName') != null) {
            opportunityName = ApexPages.currentPage().getParameters().get('opportunityName');
        }
        
        if (ApexPages.currentPage().getParameters().get('opportunityAccount') != null) {
            opportunityAccount = ApexPages.currentPage().getParameters().get('opportunityAccount');
        }
        User currentLoginUser = [SELECT Id, UserPermissionsSFContentUser, User.Profile.Name FROM User WHERE Id = :UserInfo.getUserId() Limit 1];
        isCRMContentUser = currentLoginUser.UserPermissionsSFContentUser;
        isCollectionCreateable = Schema.sObjectType.Content_Collection__c.isCreateable();
        
        //re #362 - Custom Setting decide default value for filters (Any or All) 
        searchFilterDefault = cs.RefSearch_Filters_Default__c ? 'and' : 'or';
                
        // change REF- 1288 
        isOverlay = true;
        Map<Decimal,DMNameValueWrapper> tempMapDM = new Map<Decimal,DMNameValueWrapper>();
            
        for (Data_Mapping__c dm : WithoutSharingHelperController.getDMHelpOverlay(new List<String> { UtilityController.appNamespace() + 'RfSearchLightning' })) {
            tempMapDM.put(dm.Order__c, new DMNameValueWrapper(dm.Label__c,dm.DC_Message__c));
        }
        helpOverlay = JSON.serialize(tempMapDM);

        if (ApexPages.currentPage().getParameters().get('helpOverlay') != null) {
            isOverlay = false;
        }        
        userMappingList = new List<User_Mapping__c>();
        showOveray = false; 
        
         /** If help overlay is explicitly disabled, it means Ref search page can  
          * be visited agian and again by the same user from differnet processses 
          * and completing/canceling those process*/
        isUpdateRefSearchUsageCount = isOverlay;  
        
        lastActivity = date.today();        
        checkForHelpoverlay();   
    }

    /**
     * Method to check Permission on Export Field
     */
    @RemoteAction
    global static Boolean hasPermissionOnEnableRefSearchExport() { 
        Boolean permissionGranted = false;
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Schema.DescribeSObjectResult sObj = Custom_Settings__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObj.fields.getMap();
        Schema.DescribeFieldResult sField = fieldMap.get(UtilityController.appNamespace() + 'Enable_Ref_Search_Export__c').getDescribe();
        
        if (sObj.isAccessible() && sField.isAccessible()) {
            permissionGranted = true;       
        } 
        permissionGranted = cs.Enable_Ref_Search_Export__c && permissionGranted;
        return permissionGranted;                               
    }

    @RemoteAction
    global static String getRequestRefTypeIds(String refRequestId) {
        Set<String> refTypeIds = new Set<String>();
        List<Reference_Request__c> refRequestList = [SELECT (SELECT Reference_Type_Needed__c FROM Reference_Request_Accounts__r
                                                            WHERE Reference_Use__c = false ORDER BY Deadline__c DESC),
                                                        (SELECT Reference_Type_Needed__c FROM Unspecified_Requests__r
                                                            WHERE Specified_Account__c = null ORDER BY Deadline__c DESC)
                                                        FROM Reference_Request__c WHERE Id = :refRequestId];
        
        if (refRequestList != null && refRequestList.size() > 0) {
            
            for (Unspecified_Request__c ur : refRequestList[0].Unspecified_Requests__r) {
                refTypeIds.add(ur.Reference_Type_Needed__c);
            }
            
            for (Reference_Request_Account__c ar : refRequestList[0].Reference_Request_Accounts__r) {
                refTypeIds.add(ar.Reference_Type_Needed__c);
            }
        }
        return JSON.serialize(refTypeIds);
    }

    @RemoteAction
    global static String getRequestData(String refRequestId) {
        List<RefRequestWrapper> refRequestWrapperList = new List<RefRequestWrapper>();
        List<Reference_Request__c> refRequestList = [SELECT Id, Name, Opportunity__c, Opportunity__r.Name, Reference_Request_Status__c, Opportunity__r.Account.Name, Lead__c, Lead__r.Name,
                                                        Requester__c, Requester__r.Name, Subject__c, Title__c, Case__c, Project_Type__c, Adv_Routing_Group__c, Case__r.Account.Name, Case__r.CaseNumber,
                                                        (SELECT Id, Name, Account__c, Account__r.Name, Account_Request_Status__c, Account_f__c, Deadline__c, Request_Notes__c,
                                                            Reference_Type_Needed_f__c, Reference_Type_Needed__c, Process__c, Managed_Request__c, Reference_Owner__c,
                                                            Approve_Deny_Notes__c, Project_Owner__c, Project_Owner__r.Name, Reference_Request_Additional_Info__c, Influitive_Challenge_Id__c,
                    										Influitive_Challenge_Status__c
                                                            FROM Reference_Request_Accounts__r
                                                            WHERE Reference_Use__c = false ORDER BY Deadline__c DESC),
                                                        (SELECT Id, Unspecified_Request_Status__c, Reference_Type_Needed__c, Reference_Type_Needed_f__c, Project_Owner__c,
                                                            Reference_Request_Additional_Info__c, Deadline__c, Name, Notes__c, Request_Notes__c, Project_Owner__r.Name, Influitive_Challenge_Id__c,
                    										Influitive_Challenge_Status__c
                                                            FROM Unspecified_Requests__r
                                                            WHERE Specified_Account__c = null ORDER BY Deadline__c DESC),
                                                        (SELECT Id, Label__c FROM Reference_Request_Labels__r)
                                                        FROM Reference_Request__c WHERE Id = :refRequestId];
        
        if (refRequestList != null && refRequestList.size() > 0) {
            refRequestWrapperList.add(new RefRequestWrapper(refRequestList[0]));
        }
        return JSON.serialize(refRequestWrapperList);
    }

    @RemoteAction
    global static String getFiltersInfo(String refRequestId) {
        Map<String, Set<String>> filterSelectedAttMap = new Map<String, Set<String>>();
        Map<String, List<AttributesLabelWrapper>> resultMap = new Map<String, List<AttributesLabelWrapper>>();
        Set<String> selectedAttributesIds = new Set<String>();
        List<Reference_Request_Label__c> refReqLabelList = [SELECT Id, Name, Label__c, Reference_Request__c,
                                                            (SELECT Attribute__c, Reference_Request_Label__c
                                                                FROM Reference_Request_Label_Attributes__r)
                                                            FROM Reference_Request_Label__c
                                                            WHERE Reference_Request__c = :refRequestId];
        
        for (Reference_Request_Label__c rrl : refReqLabelList) {

            if (!filterSelectedAttMap.containsKey(rrl.Label__c)) {
                filterSelectedAttMap.put(rrl.Label__c, new Set<String>());
            }

            for (Reference_Request_Label_Attribute__c rrla : rrl.Reference_Request_Label_Attributes__r) {
                filterSelectedAttMap.get(rrl.Label__c).add(rrla.Attribute__c);
                selectedAttributesIds.add(rrla.Attribute__c);
            }
        }
        List<Attributes_Labels__c> tempAttLabelList = WithoutSharingHelperController.getAttributeLabels1(filterSelectedAttMap.keySet());
        
        for (Attributes_Labels__c attLabel : tempAttLabelList) {
            
            if (!resultMap.containsKey(attLabel.Label__c)) {
                resultMap.put(attLabel.Label__c, new List<AttributesLabelWrapper>());
            }
            resultMap.get(attLabel.Label__c).add(new AttributesLabelWrapper(attLabel));
            
            if (selectedAttributesIds.contains(attLabel.Attribute__c)) {
                resultMap.get(attLabel.Label__c).get(resultMap.get(attLabel.Label__c).size() - 1).isSelected = true;
            }
        }
        return JSON.serialize(resultMap);
    }

    /**
    *   Method to check whether to show help overlay on page or not
    *   Author : Rajneesh (14 mar,2018) for REF-1288
    **/
    public void checkForHelpOverlay() {  

        if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 && !isRefMatch && isOverlay) {
            showOveray = true;
            // Both account and content section            
            if ((((opportunityId != '' || caseId != '' || leadId != '') && forAccount)
                || ((opportunityId != '' || caseId != '' || leadId != '') && !forAccount && !forContent)
                || (opportunityId == '' && caseId == '' && leadId == '')) && ((opportunityId != '' || caseId != '' || leadId != '') && forContent)
                || ((opportunityId != '' || caseId != '' || leadId != '') && !forAccount && !forContent)
                || (opportunityId == '' && caseId == '' && leadId == '')) { 
                    labelValue += 'LightningHelpOverlay Account Contact';
            } else if (((opportunityId != '' || caseId != '' || leadId != '') && forAccount)
                || ((opportunityId != '' || caseId != '' || leadId != '') && !forAccount && !forContent)
                || (opportunityId == '' && caseId == '' && leadId == '')) {                
                    labelValue += 'LightningHelpOverlay Account section';
                    
            } else {
                labelValue += 'LightningHelpOverlay Content section';                    
            }
            userMappingList = [SELECT Id, Label__c, Order__c, User__c, Last_Used_Classic_Page__c FROM User_Mapping__c WHERE User__c =: UserInfo.getUserId() AND Label__c =: labelValue 
                                AND Last_Used_Classic_Page__c != null LIMIT 1];

            if (userMappingList.Size() > 0 && userMappingList[0].Order__c != null && userMappingList[0].Order__c >= cs.Help_Overlay_Count__c) { 
                showOveray = false;
            } 

            if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userMappingList.size() > 0 && userMappingList[0].Last_Used_Classic_Page__c != null) {
                lastActivity = UtilityController.parseLastVisitDate(userMappingList[0].Last_Used_Classic_Page__c);
            }
        }        
    }
    /**
     * Method to check Permission on Export Field
     */
    @RemoteAction
    public static String updateCount(String recordId, String field) { 
        String success = 'false';
        String query = 'SELECT Id ,' + UtilityController.appNamespace() + field + ' FROM RefSearch_Usage_Track__c';
    	query += ' WHERE Id = \'' + recordId + '\' LIMIT 1 ';
    	List<RefSearch_Usage_Track__c> returnRecord = Database.query(query);
        if (returnRecord != null && returnRecord.size()> 0) {
            returnRecord[0].put(UtilityController.appNamespace() + field , (Decimal)returnRecord[0].get(UtilityController.appNamespace() + field) + 1);
            update returnRecord; 
            success = 'true';
        }
        return success;                               
    }

    //Method to manage count in user mapping object  
    public void userMappingRecord() { 
    	if(isUpdateRefSearchUsageCount) {
    		RefSearch_Usage_Track__c trackRecordItem = RfSearchController.upsertRefSearchUsageTrackRecord(isRefMatch, opportunityId, leadId, caseId, preFilter);
            if (trackRecordItem != null) {
                trackRecord = trackRecordItem.Id;
            }
    	}
    	
    	//check user mapping count and custom setting count
        helpAssistant = '';
		DateTime todayDate = system.today();
        if (showOveray){ 

            if (userMappingList.Size() > 0) {                
                 
                userMappingList[0].Order__c += 1; 
                    
                if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c) {
                    helpAssistant = ConstantsController.HELP_ASSISTANT;
                    userMappingList[0].Order__c = 1;
                }  
                userMappingList[0].Last_Used_Classic_Page__c = todayDate.format('yyyy-MM-dd');   
                 
            } else {
                User_Mapping__c umr = new User_Mapping__c();
                umr.Label__c = labelValue;
                umr.Order__c = 1;
                umr.User__c = UserInfo.getUserId();
                umr.Last_Used_Classic_Page__c = todayDate.format('yyyy-MM-dd');
                userMappingList.add(umr);
            }  
            upsert userMappingList; 
        } else if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 
                    && (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0) 
                    && (lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c)) {
                        
            helpAssistant = ConstantsController.HELP_ASSISTANT;
            userMappingList[0].Order__c = 1;
            userMappingList[0].Last_Used_Classic_Page__c = todayDate.format('yyyy-MM-dd');
            showOveray = true;
        } 

        if (userMappingList.Size() > 0 && cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) { 
            upsert userMappingList;  
        }               
    }

    /**
     * Methods to get Accounts Ids
     */ 
    @RemoteAction
    global static String getAllAccountIds() {
        Set<Id> accountIds = new Set<Id>();
        
        // changes for #786 - moved query to w/o sharing
        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountRBIs()) {
            accountIds.add(rbi.Account__c);
        }
        return JSON.serialize(accountIds);
    }
    
    /**
     * Methods to get Accounts count
     */
    @RemoteAction
    global static Integer getTotalAccounts(Boolean isFilterAppiled, String alreadyDisplayedAccountsJson,String filteredAccountsJson) {
        return 0;
    }
    
    /**
     * Methods to get Accounts count
     */
    @RemoteAction
    global static Integer getTotalAccounts1(Boolean isFilterAppiled, String alreadyDisplayedAccountsJson,
                                            String filteredAccountsJson, String refStatus) {
        Set<String> alreadydisplayedaccountIds = (Set<String>)JSON.deserialize(alreadyDisplayedAccountsJson, Set<String>.class);
        Set<String> filteredAccounts = (Set<String>)JSON.deserialize(filteredAccountsJson, Set<String>.class);
        // changes for #786 - moved query to w/o sharing
        Integer activeRBIsCount = WithoutSharingHelperController.getAccountRBIsCount(isFilterAppiled, filteredAccounts, alreadydisplayedaccountIds, refStatus);
        return activeRBIsCount;
    }
    
    /**
     * Methods to get Active RBI
     */
    @RemoteAction
    global static List<AccountProfileWrapper> getAllActiveRBIs(Boolean isFilterAppiled,
                    String alreadyDisplayedAccountsJson, String filteredAccountsJson, Integer pageLimit) {
        return new List<AccountProfileWrapper>();
    }
    
    /**
     * Methods to get Active RBI
     */
    @RemoteAction
    global static String getAllActiveRBIs1(Boolean isFilterAppiled, String alreadyDisplayedAccountsJson,
                                            String filteredAccountsJson, Integer pageLimit) {
        return '';
    }
    
    /**
     * Methods to get Active RBI
     * author: Gaurav Saini (REF-1184)
     */
    @RemoteAction
    global static String getAllActiveRBIs2(Boolean isFilterAppiled, String alreadyDisplayedAccountsJson,
                                            String filteredAccountsJson, Integer pageLimit, Boolean isRefMatch,
                                            String refRequestId, String refStatus) {
        Set<String> alreadydisplayedaccountIds = (Set<String>)JSON.deserialize(alreadyDisplayedAccountsJson, Set<String>.class);
        Set<String> filteredAccounts = (Set<String>)JSON.deserialize(filteredAccountsJson, Set<String>.class);
        Set<String> tempAccIdSet = new Set<String>();
        List<Reference_Basic_Information__c> listAccount = new List<Reference_Basic_Information__c>();
        listAccount = WithoutSharingHelperController.getAllActiveAccountRBIs(isFilterAppiled, alreadydisplayedaccountIds,
                                                                                filteredAccounts, pageLimit, refStatus);
        
        Map<String, Integer> accountHitCountMap = new Map<String, Integer>();
        Map<String, Integer> accountAssignCountMap = new Map<String, Integer>();
        Set<String> alreadyHitAccountIds = new Set<String>();
        Set<Id> hitListAccountIds = new Set<Id>();
        
        for (Reference_Basic_Information__c acc : listAccount) {
            tempAccIdSet.add(acc.Account__c);
            hitListAccountIds.add(acc.Account__c);
        }
        List<AccountProfileWrapper> rbiList = new List<AccountProfileWrapper>();
        Map<Id, Set<Id>> accRefContentMap = new Map<Id, Set<Id>>();
        List<Account_Reference_Content__c> ARCList = new List<Account_Reference_Content__c>();
        ARCList = WithoutSharingHelperController.getARCForAccounts(tempAccIdSet);
        
        if (ARCList != null && ARCList.size() > 0) {
            
            for (Account_Reference_Content__c arc : ARCList) {
                
                if (!accRefContentMap.containsKey(arc.Account__c)) {
                    accRefContentMap.put(arc.Account__c, new Set<Id>());
                    accRefContentMap.get(arc.Account__c).add(arc.Id);
                } else {
                    accRefContentMap.get(arc.Account__c).add(arc.Id);
                }
            }
        }

        if (isRefMatch) {
            Map<Id, Account> accountsMap = new Map<Id, Account>(WithoutSharingHelperController.getAccountsForRefSearch(hitListAccountIds));

            for (Id accId : accountsMap.keySet()) {
                Integer hitCount = 0;

                for (Hit_List__c hl : accountsMap.get(accId).Hit_Lists__r) {

                    if (!hl.Released__c) {
                        hitCount += 1;
                    }

                    if (hl.Reference_Request__c == refRequestId) {
                        alreadyHitAccountIds.add(accId);
                    }
                }
                accountHitCountMap.put(accId, hitCount);
                accountAssignCountMap.put(accId, accountsMap.get(accId).Reference_Request_Accounts__r.size());
            }
        }
        
        for (Reference_Basic_Information__c acc : listAccount) {
            AccountProfileWrapper accWrapper = new AccountProfileWrapper(acc, accRefContentMap != null
                                                            && accRefContentMap.containsKey(acc.Account__c)
                                                            && accRefContentMap.get(acc.Account__c).size() > 0
                                                        ? accRefContentMap.get(acc.Account__c).size() : 0);
            
            if (accountHitCountMap.containsKey(acc.Account__c)) {
                accWrapper.hitCount = accountHitCountMap.get(acc.Account__c);
            }
            
            if (accountAssignCountMap.containsKey(acc.Account__c)) {
                accWrapper.assignCount = accountAssignCountMap.get(acc.Account__c);
            }
            
            if (alreadyHitAccountIds.contains(acc.Account__c)) {
                accWrapper.isAlreadyHit = true;
            }
            rbiList.add(accWrapper);
        }
        return JSON.serialize(rbiList);
    }
    
    /**
     * Methods to Search text
     */
    @RemoteAction
    global static String filterAccountsBySearchText1(String inputText, String alreadydisplayedaccountIdsJson,
                                                        String activeAccountIdsJson) {
        Set<String> alreadydisplayedaccountIds = (Set<String>)JSON.deserialize(alreadydisplayedaccountIdsJson, Set<String>.class);
        Set<String> activeAccountIds = (Set<String>)JSON.deserialize(activeAccountIdsJson, Set<String>.class);
        Set<String> searchedAccountIds = new Set<String>();
        Set<String> searchedAccountIds1 = new Set<String>();
        Map<String, Set<String>> searchedAccountIdsMap = new Map<String, Set<String>>();
        String rbiSOSLQuery = '';
        inputText = String.escapeSingleQuotes(inputText);
        
        if (inputText != null && inputText.trim() != '') {
            rbiSOSLQuery = 'FIND \'' + inputText + '*\' IN ALL FIELDS RETURNING '
                            + UtilityController.appNamespace() + 'Reference_Basic_Information__c(Id, Account__c '
                            + 'WHERE Is_Referenceable__c = true AND (Referenceability_Status__c != \'Inactive\' '
                            + 'AND Referenceability_Status__c != \'\') AND Account__c != null AND Contact__c = null '
                            + 'AND Account__c IN :activeAccountIds AND Account__c NOT IN :alreadydisplayedaccountIds '
                            + 'ORDER BY Account__r.Name)';
            // changes for #786 - moved query to w/o sharing
            List<List<SObject>> searchRBIList
                    = WithoutSharingHelperController.getAccountRBIsUsingSOSL(rbiSOSLQuery, activeAccountIds, alreadydisplayedaccountIds);
            
            for (Reference_Basic_Information__c acc : (List<Reference_Basic_Information__c>)searchRBIList[0]) {
                searchedAccountIds.add(acc.Account__c);
            }
            List<List<SObject>> searchAccountList
                    = WithoutSharingHelperController.getAccountSOSL(inputText, activeAccountIds, searchedAccountIds, alreadydisplayedaccountIds);
            
            for (Account acc : (List<Account>)searchAccountList[0]) {
                searchedAccountIds.add(acc.Id);
                searchedAccountIds1.add(acc.Id);
            }
        }
        searchedAccountIdsMap.put('AllIds', searchedAccountIds);
        searchedAccountIdsMap.put('NameBasedIds', searchedAccountIds1);
        return JSON.serialize(searchedAccountIdsMap);
    }
    
    /**
     * method to export all records(accounts/contacts/content) from the ref search page
     * when user clicks on export without applying any filters
     * author: Gaurav Saini (6 Dec, 2017)
     */
    @RemoteAction
    global static String getAllRecordsForExport(String objectName) {
        Set<String> allRecordIds = new Set<String>();
        
        if (objectName == 'account') {
            
            for (Reference_Basic_Information__c accRBI : WithoutSharingHelperController.getAccountRBIs()) {
                allRecordIds.add(accRBI.Account__c);
            }
        } else if (objectName == 'contact') {
            
            for (Reference_Basic_Information__c conRBI : WithoutSharingHelperController.getContactRBIs()) {
                allRecordIds.add(conRBI.Contact__c);
            }
        } else if (objectName == 'content') {
            String refContentQuery = 'SELECT Id FROM Reference_Content__c '
                                        + 'WHERE Content_Status__c != \'' + ConstantsController.INACTIVE + '\'';
            
            for (Reference_Content__c rc : WithoutSharingHelperController.getReferenceContent(refContentQuery)) {
                allRecordIds.add(rc.Id);
            }
        }
        return JSON.serialize(allRecordIds);
    }
    
    /**
     * Methods to filter ref attribute
     */  
    @RemoteAction
    global static String filterAccountsByRefAttributes1(String selectedRefJson, String filterMapJson, String alreadyDisplayedAccountsJson, String filteredAccountsJson, String filterOperationMapJson){
        return '';
    }
    
    /**
     * Methods to filter ref attribute
     */  
    @RemoteAction
    global static String filterAccountsByRefAttributes(String selectedRefJson, String filterMapJson, String alreadyDisplayedAccountsJson,
                                    String filteredAccountsJson, String filterOperationMapJson, String refStatus) {
        Set<String> alreadydisplayedaccountIds = (Set<String>)JSON.deserialize(alreadyDisplayedAccountsJson, Set<String>.class);
        Set<String> filteredAccounts = (Set<String>)JSON.deserialize(filteredAccountsJson, Set<String>.class);
        Set<String> selectedRef = (Set<String>)JSON.deserialize(selectedRefJson, Set<String>.class);
        Map<String, String> filterMap = (Map<String, String>)JSON.deserialize(filterMapJson, Map<String, String>.class);
        Map<String,String> filterOperationMap = (Map<String, String>)JSON.deserialize(filterOperationMapJson, Map<String, String>.class);
        Set<String> searchedAccountIds = new Set<String>();
        String refTypesClause = '';
        
        if (filterOperationMap.containsKey('Referenceability') && filterOperationMap.get('Referenceability') == 'and') {
            
            for (String rtw : selectedRef) {
                String refnumber = 'R' + rtw + 'R';
                
                if (refTypesClause == '') {
                    refTypesClause = ' (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                                        + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                } else {
                    refTypesClause += ' AND (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                                        + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                }
            }
        } else {
             
             for (String rtw : selectedRef) {
                String refnumber = 'R' + rtw + 'R';
                
                if (refTypesClause == '') {
                    refTypesClause = ' ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                                        + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                } else {
                    refTypesClause += ' OR ReferenceabilityType_Ids1__c LIKE \'%' + refnumber
                                        + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                }
            }
        }
        String labelClause = '';
        
        for (String label : filterMap.keySet()) {
            String labelNo = filterMap.get(label);
            labelNo = ((labelNo != null && labelNo != '') ? 'F' + labelNo + 'F' : '');
            
            if (labelClause == '') {
                labelClause = ' (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
            } else {
                labelClause += ' AND (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
            }
        }
        
        if (labelClause == '' && refTypesClause == '') {
            List<Reference_Basic_Information__c> referenceProfiles = new List<Reference_Basic_Information__c>();
            String temp = JSON.serialize(referenceProfiles);
            return temp;
        }
        String dynamicSOQL = '';
        String finalClause = '';
        
        if (labelClause != '') {
            finalClause += ' and (' + labelClause + ')';
        }
        
        if (refTypesClause != '') {
            finalClause += ' and (' + refTypesClause + ')';
        }

        if (refStatus == 'Active') {
            finalClause += ' AND Account__c NOT IN :alreadydisplayedaccountIds '
                        + 'AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE
                        + '\' AND Referenceability_Status__c != null ORDER BY Account__r.Name';
        } else if (refStatus == 'Inactive') {
            finalClause += ' AND Account__c NOT IN :alreadydisplayedaccountIds '
                        + 'AND Referenceability_Status__c = \'' + ConstantsController.INACTIVE
                        + '\' ORDER BY Account__r.Name';
        } else if (refStatus == 'Candidate') {
            finalClause += ' AND Account__c NOT IN :alreadydisplayedaccountIds '
                        + 'AND Reference_Program_Candidate__c = true ORDER BY Account__r.Name';
        }
        
        if (filteredAccounts.size() > 0) {
            dynamicSOQL = 'SELECT Account__c, Attribute_Ids__c, ReferenceabilityType_Ids1__c, '
                            + 'ReferenceabilityType_Ids2__c, Account__r.Name '
                            + 'FROM Reference_Basic_Information__c WHERE Contact__c = null '
                            + 'AND Account__c != null AND Account__c IN :filteredAccounts ' + finalClause;
        } else {
            dynamicSOQL = 'SELECT Account__c, Attribute_Ids__c, ReferenceabilityType_Ids1__c, '
                            + 'ReferenceabilityType_Ids2__c, Account__r.Name '
                            + 'FROM Reference_Basic_Information__c WHERE Contact__c = null '
                            + 'AND Account__c != null ' + finalClause;
        }
        // changes for #786 - moved query to w/o sharing
        List<Reference_Basic_Information__c> referenceProfiles
                = WithoutSharingHelperController.getAccountRBIsUsingSOQL(dynamicSOQL, filteredAccounts, alreadydisplayedaccountIds);
        String temp = JSON.serialize(referenceProfiles);
        return temp;
    }
    
    /**
     * Wrapper class
     */
    global class AccountProfileWrapper {
        /**
         * Properties and variables
         */
        public Boolean isSelected { get; set; }
        public Reference_Basic_Information__c rbi { get; set; }
        public String Owner { get; set; }
        public String AccountName { get; set; }
        public String LastUsed { get; set; }
        public Integer refContentCount { get; set; }
        public String ownerId { get; set; }
        public Boolean isAlreadyHit { get; set; }
        public Integer hitCount { get; set; }
        public Integer assignCount { get; set; }
        //  REF-1902
        public String summary { get; set; }
        
        global AccountProfileWrapper(Reference_Basic_Information__c rbi, Integer refContentCount) {
            this.rbi = rbi;
            this.refContentCount = refContentCount;
            this.isSelected = false;
            this.Owner = (rbi.Reference_Owner__c != null ? rbi.Reference_Owner__r.Name : rbi.Account__r.Owner.Name);
            this.ownerId = rbi.Account__r.OwnerId;
            this.AccountName = rbi.Account__r.Name;
            this.LastUsed = (rbi.RUL_Last_Activity_Date__c != null ? rbi.RUL_Last_Activity_Date__c.format() : '');
            this.isAlreadyHit = false;
            this.hitCount = 0;
            this.assignCount = 0;
            this.summary = (rbi.Ref_Profile_Summary__c != null ? rbi.Ref_Profile_Summary__c : '');
        }
    }
    
    /**
     * Methods to get all contact Ids
     */
    @RemoteAction
    global static String getAllContactIds() {
        Set<Id> contactIds = new Set<Id>();
        
        // changes for #786 - moved query to w/o sharing
        for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getContactRBIs()) {
            contactIds.add(rbi.Contact__c);
        }
        return JSON.serialize(contactIds);
    }
    
    /**
     * Methods to get contact counts
     */
    @RemoteAction
    global static Integer getTotalContacts(Boolean isFilterAppiled, String alreadyDisplayedContactsJson, String filteredContactsJson) {
        return 0;
    }
    
    /**
     * Methods to get contact counts
     */
    @RemoteAction
    global static Integer getTotalContacts1(Boolean isFilterAppiled, String alreadyDisplayedContactsJson, String filteredContactsJson, String refStatus) {
        Set<String> alreadyDisplayedContactIds = (Set<String>)JSON.deserialize(alreadyDisplayedContactsJson, Set<String>.class);
        Set<String> filteredContacts = (Set<String>)JSON.deserialize(filteredContactsJson, Set<String>.class);
        // changes for #786 - moved query to w/o sharing
        Integer contactRBIsCount = WithoutSharingHelperController.getContactRBIsCount(isFilterAppiled, filteredContacts, alreadyDisplayedContactIds, refStatus);
        return contactRBIsCount;
    }
    
    /**
     * Methods to get active contact RBI
     */
    @RemoteAction
    global static String getRefMatchContactIds(String accountId, String refStatus) {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        List<Contact> contactsList = WithoutSharingHelperController.getAccountContacts(accountId, cs);
        List<String> resultContactIds = new List<String>();

        for (Contact c : contactsList) {

            if (c.Reference_Basic_Informations__r != null && c.Reference_Basic_Informations__r.size() > 0) {

                if (refStatus == 'Active' && c.Reference_Basic_Informations__r[0].Is_Referenceable__c
                        && c.Reference_Basic_Informations__r[0].Referenceability_Status__c != 'Inactive'
                        && c.Reference_Basic_Informations__r[0].Referenceability_Status__c != '') {
                    resultContactIds.add(c.Id);
                } else if (refStatus == 'Inactive' && c.Reference_Basic_Informations__r[0].Is_Referenceable__c
                        && c.Reference_Basic_Informations__r[0].Referenceability_Status__c == 'Inactive') {
                    resultContactIds.add(c.Id);
                } else if (refStatus == 'Candidate' && c.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c) {
                    resultContactIds.add(c.Id);
                }
            }
        }
        return JSON.serialize(resultContactIds);
    }
    
    /**
     * Methods to get active contact RBI
     */
    @RemoteAction
    global static List<ContactProfileWrapper> getAllActiveContactRBIs(Boolean isFilterAppiled, String alreadyDisplayedContactsJson, String filteredContactsJson, Integer pageLimit) {
      return new List<ContactProfileWrapper>();
    }
    
    /**
     * Methods to get  all active contact RBI
     */
    @RemoteAction
    global static String getAllActiveContactRBIs1(Boolean isFilterAppiled, String alreadyDisplayedContactsJson, String filteredContactsJson, Integer pageLimit) {
        return '';
    }
    
    /**
     * Methods to get  all active contact RBI
     */
    @RemoteAction
    global static String getAllActiveContactRBIs2(Boolean isFilterAppiled, String alreadyDisplayedContactsJson, String filteredContactsJson,
                                                Integer pageLimit, String refRequestId, String refStatus, Boolean isRefMatch) {
        Set<String> alreadyDisplayedContactIds = (Set<String>) JSON.deserialize(alreadyDisplayedContactsJson, Set<String>.class);
        Set<String> filteredContacts = (Set<String>) JSON.deserialize(filteredContactsJson, Set<String>.class);
        List<Reference_Basic_Information__c> listContact = new List<Reference_Basic_Information__c>();
        listContact = WithoutSharingHelperController.getAllActiveContactRBIs(isFilterAppiled, alreadyDisplayedContactIds, filteredContacts, pageLimit, refStatus);
        List<ContactProfileWrapper> rbiList = new List<ContactProfileWrapper>();
        Set<Id> hitListContactIds = new Set<Id>();
        Set<String> alreadyHitContactIds = new Set<String>();
        Map<String, Integer> contactHitCountMap = new Map<String, Integer>();
        Map<String, Integer> contactAssignCountMap = new Map<String, Integer>();
        List<Hit_List__c> hitListRecords = new List<Hit_List__c>();

        for (Reference_Basic_Information__c conRbi : listContact) {
            hitListContactIds.add(conRbi.Contact__c);
        }

        if (isRefMatch) {
            Map<Id, Contact> contactsMap = WithoutSharingHelperController.getContactsinContactSearch(hitListContactIds);

            for (Id conId : contactsMap.keySet()) {
                Integer hitCount = 0;

                for (Hit_List__c hl : contactsMap.get(conId).Hit_Lists__r) {

                    if (!hl.Released__c) {
                        hitCount += 1;
                    }

                    if (String.valueOf(hl.Reference_Request__c) == refRequestId) {
                        alreadyHitContactIds.add(conId);
                    }
                }
                contactHitCountMap.put(conId, hitCount);
                contactAssignCountMap.put(conId, contactsMap.get(conId).Reference_Request_Account_Contacts__r.size());
            }
        }
        
        for (Reference_Basic_Information__c con : listContact) {
            ContactProfileWrapper conWrap = new ContactProfileWrapper(con);
            
            if (contactHitCountMap.containsKey(con.Contact__c)) {
                conWrap.hitCount = contactHitCountMap.get(con.Contact__c);
            }
            
            if (contactAssignCountMap.containsKey(con.Contact__c)) {
                conWrap.assignCount = contactAssignCountMap.get(con.Contact__c);
            }
            
            if (alreadyHitContactIds.contains(con.Contact__c)) {
                conWrap.isAlreadyHit = true;
            }
            rbiList.add(conWrap);
        }
        return JSON.serialize(rbiList);
    }

    /**
     * Methods to make account/contact reference profile when it is Hit 
     */
    public static String makeAccountRPM(Account acc, Contact con, String projectType) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            
            if (projectType == 'Member') {
                List<Reference_Basic_Information__c> updateRbi = new List<Reference_Basic_Information__c>();
                
                if (acc != null) {
                    
                    if (acc.Reference_Basic_Informations__r.size() > 0) {
                        Reference_Basic_Information__c rbi = acc.Reference_Basic_Informations__r[0];
                        
                        if (!rbi.Is_Referenceable__c || rbi.Referenceability_Status__c == 'Inactive') {
                            rbi.Is_Referenceable__c = true;
                            rbi.Referenceability_Status__c = 'Active';
                            updateRbi.add(rbi);
                        }
                    } else {
                        UtilityController.checkRBI(acc.Id, null, null, true);
                    }
                }
                
                if (con != null && con.Reference_Basic_Informations__r.size() > 0) {
                    Reference_Basic_Information__c rbi = con.Reference_Basic_Informations__r[0];
                    
                    if (!rbi.Is_Referenceable__c || rbi.Referenceability_Status__c == 'Inactive') {
                        rbi.Is_Referenceable__c = true;
                        rbi.Referenceability_Status__c = 'Active';
                        updateRbi.add(rbi);
                    }
                }
                
                if (updateRbi.size() > 0) {
                    WithoutSharingHelperController.upsertRBI(updateRbi);
                }
            }
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }
    
    /**
     * Methods to Search text 
     */
    @RemoteAction
    global static String createHitListRecord(String hitAccountId, String hitContactId, String refRequestId, String oppId, String projectType) {
        Savepoint sp = Database.setSavepoint();
        String result = '';

        try {
            Hit_List__c hitObj = new Hit_List__c();

            if (hitAccountId != null && hitAccountId != '' && hitContactId == '') {
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { hitAccountId });
                result = makeAccountRPM(accList[0], null, projectType);
                hitObj.Account__c = hitAccountId;
                hitObj.Reference_Profile__c = accList[0].Reference_Basic_Informations__r[0].Id;
                hitObj.Reference_Request__c = refRequestId;
                hitObj.Opportunity__c = oppId != '' ? oppId : null;

                if (result != 'success') {
                    return result;
                }
            } else if (hitContactId != '') {
                Contact c = WithoutSharingHelperController.activateContactRecords(new Set<String> { hitContactId })[0];
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { c.AccountId });

                if (projectType == 'Candidate') {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                    && !acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            return System.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT;
                        }
                    }
                } else {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                && acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            return System.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT;
                        }
                    }
                }
                hitObj.Account__c = c.AccountId;
                hitObj.Contact__c = c.Id;
                hitObj.Email__c = c.Email;
                hitObj.Phone__c = c.Phone;
                hitObj.Reference_Profile__c = accList[0].Reference_Basic_Informations__r[0].Id;
                hitObj.Reference_Request__c = refRequestId;
                hitObj.Opportunity__c = oppId != '' ? oppId : null;
                result = makeAccountRPM(accList[0], c, projectType);

                if (result != 'success') {
                    return result;
                }
            }

            if (hitObj.Account__c != null) {
                WithoutSharingHelperController.upsertHitList(hitObj);
            }
            result = 'success';
        } catch(Exception e) {
            Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }
    
    /**
     * Methods to assign account to selected request item
     */
    @RemoteAction
    global static String assignAccountContact(Boolean isUr, String accountId, String contactId, String oldRequestMapJson,
                                                String refRequestId, String requesterId, String projectType) {
        Savepoint sp = Database.setSavepoint();
        String result = '';
        String newRecordId = '';
        Boolean isNewAccount = true;

        try {
            Map<String, String> oldRequestMap = (Map<String, String>)JSON.deserialize(oldRequestMapJson, Map<String, String>.class);
            String projectOwner = !oldRequestMap.containsKey('ownerId') || oldRequestMap.get('ownerId') == '' ? null : oldRequestMap.get('ownerId');
            if (accountId != '' && contactId == '') {
                
                if (isUr) {
                    
                    if (projectType == 'Member') {
                        List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { accountId });
                        makeAccountRPM(accList[0], null, projectType);
                    }
                    Reference_Request_Account__c rra = new Reference_Request_Account__c(
                            Account__c = accountId,
                            Reference_Request__c = refRequestId,
                            Request_Notes__c = oldRequestMap.get('reqNotes'),
                            Requester__c = requesterId,
                            Deadline__c = Date.valueOf(oldRequestMap.get('deadline')),
                            Managed_Request__c = true,
                            Project_Owner__c = projectOwner,
                            Process__c = ConstantsController.MANAGED,
                            Reference_Type_Needed__c = oldRequestMap.get('refTypeId'),
                            Account_Request_Status__c = ConstantsController.IN_PROGRESS,
                            Reference_Request_Additional_Info__c = oldRequestMap.get('addInfoId') != '' ? oldRequestMap.get('addInfoId') : null);
                    rra = WithoutSharingHelperController.upsertRRA(rra);
                    ConstantsController.shouldUnspecifiedStatusChange = true;
                    newRecordId = rra.Id;
                    Unspecified_Request__c oldUR = new Unspecified_Request__c(Id = oldRequestMap.get('unspecRequestId'));
                    oldUR.Specified_Account__c = rra.Id;
                    oldUR.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                    WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> {oldUR});
                } else {

                    if (projectType == 'Member') {
                        List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { accountId });
                        makeAccountRPM(accList[0], null, projectType);
                    }
                    Reference_Request_Account__c rra = new Reference_Request_Account__c(
                            Account__c = accountId,
                            Reference_Request__c = refRequestId,
                            Request_Notes__c = oldRequestMap.get('reqNotes'),
                            Requester__c = requesterId,
                            Deadline__c = Date.valueOf(oldRequestMap.get('deadline')),
                            Managed_Request__c = true,
                            Project_Owner__c = projectOwner,
                            Process__c = ConstantsController.MANAGED,
                            Reference_Type_Needed__c = oldRequestMap.get('refTypeId'),
                            Account_Request_Status__c = ConstantsController.IN_PROGRESS,
                            Reference_Request_Additional_Info__c = oldRequestMap.get('addInfoId') != '' ? oldRequestMap.get('addInfoId') : null);
                    rra = WithoutSharingHelperController.upsertRRA(rra);
                    newRecordId = rra.Id;
                    Reference_Request_Account__c oldRRA = new Reference_Request_Account__c(Id = oldRequestMap.get('accRequestId'));
                    oldRRA.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                    WithoutSharingHelperController.upsertRRA(oldRRA);
                }
            } else if (accountId != '' && contactId != '') {
                Set<String> accIdsSet = new Set<String>();
                accIdsSet.add(accountId);

                if (!isUr) {
                    accIdsSet.add(oldRequestMap.get('accountId'));
                }
                Contact con = WithoutSharingHelperController.activateContactRecords(new Set<String> { contactId })[0];
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(accIdsSet);
                if (projectType == 'Candidate') {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                    && !acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            return System.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT;
                        }
                    }
                } else {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                && acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            return System.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT;
                        }
                    }
                }
                Account contactAccount;

                for (Account acc : accList) {

                    if (acc.Id == accountId) {
                        contactAccount = acc;
                    }
                }
                result = makeAccountRPM(contactAccount, con, projectType);
                
                if (result != 'success') {
                    return result;
                }
                if (!isUr && oldRequestMap.get('accountId') == accountId && oldRequestMap.containsKey('accRequestId')) {
                    isNewAccount = false;
                    newRecordId = oldRequestMap.get('accRequestId');
                }
                if (isNewAccount) {
                    Reference_Request_Account__c rra = new Reference_Request_Account__c(
                            Account__c = contactAccount.Id,
                            Reference_Request__c = refRequestId,
                            Request_Notes__c = oldRequestMap.get('reqNotes'),
                            Requester__c = requesterId,
                            Deadline__c = Date.valueOf(oldRequestMap.get('deadline')),
                            Managed_Request__c = true,
                            Process__c = ConstantsController.MANAGED,
                            Project_Owner__c = projectOwner,
                            Reference_Type_Needed__c = oldRequestMap.get('refTypeId'),
                            Account_Request_Status__c = ConstantsController.IN_PROGRESS,
                            Reference_Request_Additional_Info__c = oldRequestMap.get('addInfoId') != '' ? oldRequestMap.get('addInfoId') : null);
                    rra = WithoutSharingHelperController.upsertRRA(rra);
                    newRecordId = rra.Id;
                }
                Reference_Request_Account_Contact__c newContactRequest
                    = new Reference_Request_Account_Contact__c(Reference_Request_Account__c = newRecordId,
                        Contact__c = contactId, Contact_Request_Status__c = ConstantsController.IN_PROGRESS,
                        Referenceability_Type__c = oldRequestMap.get('refTypeId'),Project_Owner__c = projectOwner, Deadline__c = Date.valueOf(oldRequestMap.get('deadline')),
                        Contact_Title__c = con.Title, Contact_Phone__c = con.Phone, Contact_Email__c = con.Email);
                WithoutSharingHelperController.upsertRRAC(newContactRequest);

                if (isUr) {
                    ConstantsController.shouldUnspecifiedStatusChange = true;
                    Unspecified_Request__c oldUR = new Unspecified_Request__c(Id = oldRequestMap.get('unspecRequestId'));
                    oldUR.Specified_Account__c = newRecordId;
                    oldUR.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                    WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> {oldUR});
                } else if (isNewAccount) {
                    Reference_Request_Account__c oldRRA = new Reference_Request_Account__c(Id = oldRequestMap.get('accRequestId'));
                    oldRRA.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                    WithoutSharingHelperController.upsertRRA(oldRRA);
                }
            }
            result = 'success##' + newRecordId;
        } catch(Exception e) {
            Database.rollback(sp);
            result = CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
        }
        return result;
    }
    
    /**
     * Methods to Search text 
     */ 
    @RemoteAction
    global static String filterContactsBySearchText1(String inputText, String alreadyDisplayedContactIdsJson,
                                            String activeAccountIdsJson, String filterdAccountsJson, String refStatus) {
        Set<String> alreadyDisplayedContactIds = (Set<String>) JSON.deserialize(alreadyDisplayedContactIdsJson, Set<String>.class);
        Set<String> activeAccountIds = (Set<String>) JSON.deserialize(activeAccountIdsJson, Set<String>.class);
        Set<String> filterdAccounts = (Set<String>) JSON.deserialize(filterdAccountsJson, Set<String>.class);
        Set<String> searchedContactIds = new Set<String>();
        String rbiSOSLQuery = '';
        inputText = String.escapeSingleQuotes(inputText);
        String refStatusClause = '';

        if (refStatus == 'Active') {
            refStatusClause = 'Is_Referenceable__c = true AND (Referenceability_Status__c != \'Inactive\' AND Referenceability_Status__c != \'\') ';
        } else if (refStatus == 'Inactive') {
            refStatusClause = 'Is_Referenceable__c = true AND Referenceability_Status__c = \'Inactive\' ';
        } else if (refStatus == 'Candidate') {
            refStatusClause = 'Reference_Program_Candidate__c = true ';
        }
        
        if (inputText != null && inputText.trim() != '') {
            rbiSOSLQuery = 'FIND \'' + inputText + '*\' IN ALL FIELDS RETURNING '
                                                    + UtilityController.appNamespace()
                                                    + 'Reference_Basic_Information__c(Id, Contact__c '
                                                        + 'WHERE ' + refStatusClause
                                                        + 'AND Account__c != null '
                                                        + 'AND Contact__c != null '
                                                        + 'AND Contact__c IN :activeAccountIds '
                                                        + 'AND Contact__c NOT IN :alreadyDisplayedContactIds '
                                                        + 'ORDER BY Contact__r.Name), '
                                                    + 'Contact(Id, Name '
                                                        + 'WHERE Id IN :activeAccountIds '
                                                        + 'AND Id not IN :alreadyDisplayedContactIds '
                                                        + 'ORDER BY Name)';
            List<List<SObject>> searchRBIList = WithoutSharingHelperController.getContactsUsingSOSL(rbiSOSLQuery, activeAccountIds, alreadyDisplayedContactIds);            //search.query(rbiSOSLQuery);
            
            for (Reference_Basic_Information__c acc : (List<Reference_Basic_Information__c>)searchRBIList[0]) {
                searchedContactIds.add(acc.Contact__c);
            }
            
            for (Contact acc : (List<Contact>)searchRBIList[1]) {
                searchedContactIds.add(acc.Id);
            }
            
            if (filterdAccounts != null && filterdAccounts.size() > 0) {
                
                // changes for #786 - moved query to w/o sharing
                for (Contact c : WithoutSharingHelperController.getContactsForTextSearch(activeAccountIds, alreadyDisplayedContactIds, searchedContactIds, filterdAccounts)) {
                    searchedContactIds.add(c.Id);
                }
            }
        } else {
            return JSON.serialize(searchedContactIds);
        }
        return JSON.serialize(searchedContactIds);
    }
    
    /**
     * Methods to Search text 
     */
    @RemoteAction
    global static String filterContactsBySearchText(String inputText, String alreadyDisplayedContactIdsJson, String activeAccountIdsJson, String filterdAccountsJson){
        return '';
    }
    
    /**
     * Methods to get Ref Attribute 
     */
    @RemoteAction
    global static String filterContactsByRefAttributes(String selectedRefJson, String filterMapJson, String alreadyDisplayedAccountsJson, 
                                                        String filteredContactsJson, String filterOperationMapJson) {
        return '';
    }
    
    /**
     * Methods to get Ref Attribute 
     */
    @RemoteAction
    global static String filterContactsByRefAttributes1(String selectedRefJson, String filterMapJson, String alreadyDisplayedAccountsJson, 
                                                        String filteredContactsJson, String filterOperationMapJson, String refStatus) {
        Set<String> alreadyDisplayedContactIds = (Set<String>)JSON.deserialize(alreadyDisplayedAccountsJson, Set<String>.class);
        Set<String> filteredContacts = (Set<String>)JSON.deserialize(filteredContactsJson, Set<String>.class);
        Set<String> selectedRef = (Set<String>)JSON.deserialize(selectedRefJson, Set<String>.class);
        Map<String, String> filterMap = (Map<String, String>)JSON.deserialize(filterMapJson, Map<String, String>.class);
        Map<String, String> filterOperationMap = (Map<String, String>)JSON.deserialize(filterOperationMapJson, Map<String, String>.class);
        Set<String> searchedAccountIds = new Set<String>();
        String refTypesClause = '';
        
        if (filterOperationMap.containsKey('Referenceability') && filterOperationMap.get('Referenceability') == 'and') {
            
            for (String rtw : selectedRef) {
                String refnumber = 'R' + rtw + 'R';
                
                if (refTypesClause == '') {
                    refTypesClause = ' (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                } else {
                    refTypesClause += ' AND (ReferenceabilityType_Ids1__c LIKE \'%' + refnumber + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\')';
                }
            }
        } else {
            
            for (String rtw : selectedRef) {
                String refnumber = 'R' + rtw + 'R';
                
                if (refTypesClause == '') {
                    refTypesClause = ' ReferenceabilityType_Ids1__c LIKE \'%' + refnumber + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                } else {
                    refTypesClause += ' OR ReferenceabilityType_Ids1__c LIKE \'%' + refnumber + '%\' OR ReferenceabilityType_Ids2__c LIKE \'%' + refnumber + '%\'';
                }
            }
        }
        String labelClause = '';
        
        for (String label : filterMap.keySet()) {
            String labelNo = filterMap.get(label);
            labelNo = ((labelNo != null && labelNo != '') ? 'F' + labelNo + 'F' : '');
            
            if (labelClause == '') {
                labelClause = ' (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
            } else {
                labelClause += ' AND (Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\')';
            }
        }
        
        if (labelClause == '' && refTypesClause == '') {
            List<Reference_Basic_Information__c> referenceProfiles = new List<Reference_Basic_Information__c>();
            String temp = JSON.serialize(referenceProfiles);
            return temp;
        }
        String dynamicSOQL = '';
        String finalClause = '';
        
        if (labelClause != '') {
            finalClause += ' and (' + labelClause + ')';
        }
        
        if (refTypesClause != '') {
            finalClause += ' and (' + refTypesClause + ')';
        }
        
        if (refStatus == 'Active') {
            finalClause += ' AND Contact__c NOT IN :alreadyDisplayedContactIds '
                            + 'AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE
                            + '\' AND Referenceability_Status__c != null ORDER BY Contact__r.Name';
        } else if (refStatus == 'Inactive') {
            finalClause += ' AND Contact__c NOT IN :alreadyDisplayedContactIds '
                            + 'AND Referenceability_Status__c = \'' + ConstantsController.INACTIVE
                            + '\' ORDER BY Contact__r.Name';
        } else if (refStatus == 'Candidate') {
            finalClause += ' AND Contact__c NOT IN :alreadyDisplayedContactIds '
                            + 'AND Reference_Program_Candidate__c = true ORDER BY Contact__r.Name';
        }
        
        if (filteredContacts.size() > 0) {
            dynamicSOQL = 'SELECT Contact__c, Attribute_Ids__c, ReferenceabilityType_Ids1__c, ReferenceabilityType_Ids2__c '
                            + 'FROM Reference_Basic_Information__c WHERE Contact__c != null '
                            + 'AND Account__c != null AND Contact__c IN :filteredContacts ' + finalClause;
        } else {
            dynamicSOQL = 'SELECT Contact__c, Attribute_Ids__c, ReferenceabilityType_Ids1__c, ReferenceabilityType_Ids2__c '
                            + 'FROM Reference_Basic_Information__c WHERE Contact__c != null '
                            + 'AND Account__c != null ' + finalClause;
        }
        // changes for #786 - moved query to w/o sharing
        // Iterate Final Reference profiles
        List<Reference_Basic_Information__c> referenceProfiles
                = WithoutSharingHelperController.getContactRBIsUsingSOQL(dynamicSOQL, filteredContacts, alreadyDisplayedContactIds);
        return JSON.serialize(referenceProfiles);
    }
    
    /**
     * ContactProfile Wrapper class
     */
    global class ContactProfileWrapper {
        /**
         * Properties and variables
         */
        public Boolean isSelected { get; set; }
        public Reference_Basic_Information__c rbi { get; set; }
        public String Owner { get; set; }
        public String ContactName { get; set; }
        public String AccountName { get; set; }
        public String LastUsed { get; set; }
        public String ownerId { get; set; }
        public Boolean isAlreadyHit { get; set; }
        public Integer hitCount { get; set; }
        public Integer assignCount { get; set; }
        //  REF-1902
        public String summary { get; set; }
        //REF-1964
        public String ContactEmail { get; set; }
        
        global ContactProfileWrapper(Reference_Basic_Information__c rbi) {
            this.rbi = rbi;
            this.isSelected = false;
            this.Owner = (rbi.Contact__r.Owner.Name);
            this.ownerId = rbi.Contact__r.OwnerId;
            this.ContactName = rbi.Contact__r.Name;
            this.AccountName = rbi.Account__r.Name;
            this.LastUsed = (rbi.RUL_Last_Activity_Date__c != null ? rbi.RUL_Last_Activity_Date__c.format() : '');
            this.isAlreadyHit = false;
            this.hitCount = 0;
            this.assignCount = 0;
            this.summary = (rbi.Ref_Profile_Summary__c != null ? rbi.Ref_Profile_Summary__c : '');
            this.ContactEmail = (rbi.Contact__r.Email != null ? rbi.Contact__r.Email : '');
        }
    }
    
    /**
     * Methods to get contents counts
     */
    @RemoteAction
    global static Integer getTotalContents(Boolean isFilterAppiled, String alreadyDisplayedContentsJson, String filteredContentsJson, Boolean featuredChecked) {
        return 0;
    }
    
    /**
     * Methods to get contents values
     */
    @RemoteAction
    global static Integer getTotalContentsValues(Boolean isFilterAppiled, String alreadyDisplayedContentsJson,
                                        String filteredContentsJson, Boolean featuredChecked, String shareableValue) {
        Set<String> alreadyDisplayedContents = (Set<String>)JSON.deserialize(alreadyDisplayedContentsJson, Set<String>.class);
        Set<String> filteredContents = (Set<String>)JSON.deserialize(filteredContentsJson, Set<String>.class);
        // changes for #786 - moved query to w/o sharing
        Integer refContentsCount = WithoutSharingHelperController.getRefContentsCount(featuredChecked, isFilterAppiled,
                                                            shareableValue, alreadyDisplayedContents, filteredContents);
        return refContentsCount;
    }
    
    /**
     * Methods to get contents values
     */
    @RemoteAction
    global static List<ContentWrapper> getAllContents(String shareableValue, Boolean isFilterAppiled, String alreadyDisplayedContentsJson, 
                                                        String filteredContentsJson, Integer pageLimit,Boolean featuredChecked,Boolean ShowFeaturedContentFirst){
        return new List<ContentWrapper>();
    }
    
    /**
     * Methods to get contents values
     */
    @RemoteAction
    global static String getAllContents1(String shareableValue, Boolean isFilterAppiled, String alreadyDisplayedContentsJson, String filteredContentsJson, 
                                            Integer pageLimit, Boolean featuredChecked, Boolean ShowFeaturedContentFirst) {
        Set<String> alreadyDisplayedContents = (Set<String>) JSON.deserialize(alreadyDisplayedContentsJson, Set<String>.class);
        Set<String> filteredContents = (Set<String>) JSON.deserialize(filteredContentsJson, Set<String>.class);
        List<Reference_Content__c> listRefContent = new List <Reference_Content__c>();
        Set<String> tempContentIds = new Set<String>();
        Set<String> customContentIds = new Set<String>();
        Map<String, Schema.DescribeFieldResult> customContentFieldsMap = new Map<String, Schema.DescribeFieldResult>();
        Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Content_Type_Field__c');
        Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        Set<String> queryFieldsSet = new Set<String>();
        queryFieldsSet.add(UtilityController.appNamespace() + 'Reference_Content__c');
        Map<Id,Set<String>> availableFields = new Map<Id,Set<String>>();
        
        for (String field : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
            
            if (dfr.isCustom()) {
                customContentFieldsMap.put(dfr.getName(), dfr);
                queryFieldsSet.add(dfr.getName());
                
                if (String.valueOf(dfr.getType()) == 'REFERENCE') {
                    queryFieldsSet.add(dfr.getName().replace('__c','__r') + '.Name');
                }
            }
        }
        pageLimit++;
        String query = 'SELECT Id, Name, Featured_Content__c, Reference_Content_Type__r.Recorded_Reference_Type__c, '
                        + 'Reference_Content_Type__r.Custom_Content_Type__c, Number_of_Download__c, Attributes__c, '
                        + 'Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c, Language__c, '
                        + 'Reference_Content_Type_Name__c, Internal_Use__c, Expiration_Date__c, Content_ID__c, '
                        + 'Reference_Content_Type__c, Reference_Content_Type__r.Name__c, Custom_Reference_Content__c, '
                        + 'Content_Status__c, Allow_Social_Sharing__c, Publish_date__c, Content_URL__c, Content_URL2__c,'
                        + '(SELECT Id, Account__c, Account__r.Name FROM Account_Reference_Contents__r)';
        
        if (isFilterAppiled) {
            query += ' FROM Reference_Content__c WHERE Id IN :filteredContents AND Id NOT IN :alreadyDisplayedContents '
                        + 'AND (Content_Status__c != \'Inactive\' AND Content_Status__c != \'\')';
        } else {
            query += ' FROM Reference_Content__c WHERE Id NOT IN :alreadyDisplayedContents '
                        + 'AND (Content_Status__c != \'Inactive\' AND Content_Status__c != \'\')';
        }
        
        if (shareableValue == 'Internal') {
            query += ' AND Internal_Use__c = true';
        } else if (shareableValue == 'Shareable') {
            query += ' AND Internal_Use__c = false';
        }
        
        if (featuredChecked) {
            query += ' AND Featured_Content__c = true';
        }
        
        if (ShowFeaturedContentFirst) {
            query += ' ORDER BY Featured_Content__c DESC, Title__c ASC LIMIT :pageLimit';
        } else {
            query += ' ORDER BY Title__c ASC LIMIT :pageLimit';
        }
        listRefContent = WithoutSharingHelperController.getAllContents(query, filteredContents, alreadyDisplayedContents, pageLimit);
        
        for (Reference_Content__c rc : listRefContent) {
            if (rc.Custom_Reference_Content__c) {
                customContentIds.add(rc.Id);
                availableFields.put(rc.Reference_Content_Type__c, new Set<String>());
            } else {
                tempContentIds.add(rc.Content_ID__c);
            } 
        }

        Set<Id> availableFieldsKeys  = availableFields.keySet();
        
        for (Reference_Type_Mapping__c rtm : WithoutSharingHelperController.getRefTypeMapping(availableFieldsKeys)) {
            availableFields.get(rtm.Reference_Content_Type__c).add(rtm.name);                                                   
        }
        Map<Id, Reference_Content_Type_Field__c> customContentMap
                            = WithoutSharingHelperController.getRefContentTypeFields(new List<String>(customContentIds),queryFieldsSet);
        
        Map<Id, Reference_Interview__c> refInterviewMap = new Map<Id, Reference_Interview__c>();
        List<Reference_Interview__c> tempRefInterviewList = new List<Reference_Interview__c>();
        // changes for #786 - moved query to w/o sharing
        tempRefInterviewList = WithoutSharingHelperController.getRefInterviewListForInvitation();
        
        for (Reference_Interview__c ri : tempRefInterviewList) {
            refInterviewMap.put(ri.Reference_Content__c, ri);
        }
        List<ContentWrapper> contents = new List<ContentWrapper>();
        // changes for #786 - moved query to w/o sharing
        Map<Id, ContentVersion> mapContentVersion = WithoutSharingHelperController.getContentVersionMapForInvitation(tempContentIds);
        
        for (Reference_Content__c rc : listRefContent) {
            String AccountName = '';
            List<String> AccountId;
            
            if (rc.Account_Reference_Contents__r.size() == 0) {
                AccountName = '';
                AccountId = new List<String>();
            } else if (rc.Account_Reference_Contents__r.size() == 1) {
                AccountName = rc.Account_Reference_Contents__r[0].Account__r.Name;
                AccountId  = new List<String>();
                AccountId.add(rc.Account_Reference_Contents__r[0].Account__r.Id);
            } else {
                AccountName = System.Label.Multiple_Accounts;
                AccountId  = new List<String>();
                
                for (Account_Reference_Content__c arc : rc.Account_Reference_Contents__r) {
                    AccountId.add(arc.Account__c);
                }
            }
            
            if (mapContentVersion.containsKey(rc.Content_ID__c)) {
                
                if (refInterviewMap != null
                            && refInterviewMap.containsKey(rc.Id)
                            && refInterviewMap.get(rc.Id) != null) {
                    contents.add(new ContentWrapper(rc, mapContentVersion.get(rc.Content_ID__c), AccountName, AccountId, refInterviewMap.get(rc.Id)));
                } else {
                    contents.add(new ContentWrapper(rc, mapContentVersion.get(rc.Content_ID__c), AccountName, AccountId));
                }
            } else {
                
                if (refInterviewMap != null
                            && refInterviewMap.containsKey(rc.Id)
                            && refInterviewMap.get(rc.Id) != null) {
                    contents.add(new ContentWrapper(rc, new ContentVersion(), AccountName, AccountId, refInterviewMap.get(rc.Id)));
                } else if (rc.Custom_Reference_Content__c && customContentMap != null && customContentMap.containsKey(rc.Id) && customContentMap.get(rc.Id) != null) {
                    List<CustomContentTypeWrapper> customContentTypeWrapperList = new List<CustomContentTypeWrapper>();
                
                    for (String field : availableFields.get(rc.Reference_Content_Type__c)) {
                        
                        if (customContentFieldsMap.containsKey(field)) {
                            
                            if ((String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATE' || String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATETIME') && customContentMap.get(rc.Id).get(field) != null && String.valueOf(customContentMap.get(rc.Id).get(field)).trim() != '') {
                                String data = String.valueOf(customContentMap.get(rc.Id).get(field));
                                Date dateValue = date.valueOf(data);
                                Integer d = dateValue.day();
                                Integer mo = dateValue.month();
                                Integer yr = dateValue.year();
                                DateTime dateTimeValue = DateTime.newInstance(yr, mo, d);
                                data = dateTimeValue.format('MMM dd yyyy');//Format date
                                customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), data, String.valueOf(customContentFieldsMap.get(field).getType())));
                            } else if (String.valueOf(customContentFieldsMap.get(field).getType()) == 'REFERENCE' && !field.contains('Reference_Content__c')) {
                                String fieldName = field.replace('__c','__r');
                                sObject data = customContentMap.get(rc.Id).getSObject(fieldName);                              
                               // customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), String.valueOf(data.get('Name')), String.valueOf(customContentFieldsMap.get(field).getType())));
                               customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), data, String.valueOf(customContentFieldsMap.get(field).getType())));
                                
                            } else if (!field.contains('Reference_Content__c')) {
                                customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), customContentMap.get(rc.Id).get(field), String.valueOf(customContentFieldsMap.get(field).getType())));
                            }
                        }
                    }
                    contents.add(new ContentWrapper(rc, new ContentVersion(), AccountName, AccountId, customContentTypeWrapperList));
                } else {
                    contents.add(new ContentWrapper(rc, new ContentVersion(), AccountName, AccountId));
                }
            }
        }
        return JSON.serialize(contents);
    }
    
    /**
     * Methods to get filtered contents attribute
     */
    @RemoteAction
    global static String filterByContentAttribute(String attributeIdsJson) {
        Set<Id> attributeTypeIds = (Set<Id>)JSON.deserialize(attributeIdsJson, Set<Id>.class);
        // changes for #786 - moved query to w/o sharing
        List<Content_Attribute__c> contAttrList = WithoutSharingHelperController.getContentAttribute(attributeTypeIds);
        return JSON.serialize(contAttrList);
    }
    
    /**
     * Methods to get filtered search text
     */
    @RemoteAction
    global static String filterBySearchText(String inputTextValue, String filterdAccountsJson) {
        Set<String> contentIds = new Set<String>();
        Set<String> refContentIds = new Set<String>();
        Set<String> contentIdsFromRefContent = new Set<String>();
        Set<Id> filterdAccounts = (Set<Id>)JSON.deserialize(filterdAccountsJson, Set<Id>.class);
        
        if (inputTextValue.trim().length() == 0 || inputTextValue.trim().length() == 1) {
            return JSON.serialize(refContentIds);
        }
        inputTextValue = String.escapeSingleQuotes(inputTextValue);
        String SOSLQuery = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING '
                                                        + 'ContentVersion(Id), '
                                                        + UtilityController.appNamespace()
                                                        + 'Reference_Content__c(Id, Content_ID__c), '
                                                        + UtilityController.appNamespace()
                                                        + 'Reference_Content_Type_Field__c(Reference_Content__c, Id)';
        List<List<SObject>> searchList = WithoutSharingHelperController.getContentsUsingSOSL(SOSLQuery);
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
            
            // changes for #786 - moved query to w/o sharing
            for (Reference_Content__c rc : WithoutSharingHelperController.getRefContentForTextSearch(contentIds, listReferenceContent)) {
                refContentIds.add(rc.id);
            }
        }
        
        if (filterdAccounts != null && filterdAccounts.size() > 0) {
            
            // changes for #786 - moved query to w/o sharing
            for (Account_Reference_Content__c c : WithoutSharingHelperController.getAccountContent(refContentIds, filterdAccounts)) {
                refContentIds.add(c.Reference_Content__c);
            }
        }
        return JSON.serialize(refContentIds);
    }
    
    /**
     * Methods to get filtered contents type
     */
    @RemoteAction
    global static String filterByContentType(String selectedContentTypesJson, String filterOperation) {
        Set<String> selectedContentTypes = (Set<String>)JSON.deserialize(selectedContentTypesJson, Set<String>.class);
        Set<String> refContentIds = new Set<String>();
        
        if (selectedContentTypes.size() == 0) {
            return '';
        }
        String contentTypeValues = '';
        
        for (String contentTypeName : selectedContentTypes) {
            
            if (filterOperation == 'and') {
                
                if (contentTypeValues == '') {
                    contentTypeValues = 'Reference_Content_Type__r.Name__c = \'' + contentTypeName + '\'';
                } else {
                    contentTypeValues = contentTypeValues + ' AND Reference_Content_Type__r.Name__c = \'' + contentTypeName + '\'';
                }
            } else {
                
                if (contentTypeValues == '') {
                    contentTypeValues = 'Reference_Content_Type__r.Name__c = \'' + contentTypeName + '\'';
                } else {
                    contentTypeValues = contentTypeValues + ' OR Reference_Content_Type__r.Name__c = \'' + contentTypeName + '\'';
                }
            }
        }
        String refContentQuery = 'SELECT Id, Name, Content_ID__c, Content_URL__c, Content_URL2__c FROM Reference_Content__c WHERE ' + contentTypeValues;
        
        // changes for #786 - moved query to w/o sharing
        for (Reference_Content__c rc : WithoutSharingHelperController.getReferenceContent(refContentQuery)) {
            refContentIds.add(rc.id);
        }
        return JSON.serialize(refContentIds);
    }
    
    /**
     * Methods to get filtered contents language
     */
    @RemoteAction
    global static String filterByContentLanguage(String selectedContentLanguagesJson, String filterOperation) {
        Set<String> selectedContentLanguages = (Set<String>)JSON.deserialize(selectedContentLanguagesJson, Set<String>.class);
        Set<String> refContentIds = new Set<String>();
        
        if (selectedContentLanguages.size() == 0) {
            return '';
        }
        String contentLanguageValues = '';
        
        for (String contentLanguageName : selectedContentLanguages) {
            
            if (filterOperation == 'and') {
                
                if (contentLanguageValues == '') {
                    contentLanguageValues = 'Language__c = \'' + contentLanguageName + '\'';
                } else {
                    contentLanguageValues = contentLanguageValues + ' AND Language__c = \'' + contentLanguageName + '\'';
                }
            } else {
                
                if (contentLanguageValues == '') {
                    contentLanguageValues = 'Language__c = \'' + contentLanguageName + '\'';
                } else {
                    contentLanguageValues = contentLanguageValues + ' OR Language__c = \'' + contentLanguageName + '\'';
                }
            }
        }
        String refContentQuery = 'SELECT Id, Name, Content_ID__c, Content_URL__c, Content_URL2__c FROM Reference_Content__c WHERE ' + contentLanguageValues;
        
        // changes for #786 - moved query to w/o sharing
        for (Reference_Content__c rc : WithoutSharingHelperController.getReferenceContent(refContentQuery)) {
            refContentIds.add(rc.Id);
        }
        return JSON.serialize(refContentIds);
    }
    
    /**
     * Methods to get filtered contents Collections
     */
    @RemoteAction
    global static String getContentCollections() {
        List<CollectionWrapper> collectionList = new List<CollectionWrapper>();
        
        // changes for #786 - moved query to w/o sharing
        for (Content_Collection__c cc : WithoutSharingHelperController.getContentCollections()) {          
            CollectionWrapper cw = new CollectionWrapper(cc);
            if (cw.relatedRefContentIds.size() > 0) {
                collectionList.add(new CollectionWrapper(cc));
            }
        }
        
        if (collectionList != null && collectionList.size() > 0) {
            return JSON.serialize(collectionList);
        }
        return '';
    }
    
    /**
     * Collection Wrapper
     */
    global class CollectionWrapper {
        public String value { get; set; }
        public String label { get; set; }
        public List<String> relatedRefContentIds { get; set; }
        
        global CollectionWrapper(Content_Collection__c cc) {
            this.value = cc.Id;
            this.label = cc.Collection__c;
            this.relatedRefContentIds = new List<String>();
                
            for (Related_Reference_Content__c rc : cc.Related_Reference_Contents__r) {
                this.relatedRefContentIds.add(rc.Reference_Content__c);
            }
        }
    }
    
    /**
     * Method to create collections
     */
    @RemoteAction
    global static String createCollection(String collectionName, String selectedContentIdsJson) {
        
        if (checkPermissions(false, 'CreateCollection')) {
            Set<String> selectedContentIds = (Set<String>)JSON.deserialize(selectedContentIdsJson, Set<String>.class); 
            Savepoint sp = Database.setSavepoint();
            
            try {
                Content_Collection__c contentCollection = new Content_Collection__c(Collection__c = collectionName, Active__c = true);
                insert contentCollection;
                List<Related_Reference_Content__c> rrcList = new List<Related_Reference_Content__c>();
                
                for(String contentID : selectedContentIds) {
                    Related_Reference_Content__c rrcObj = new Related_Reference_Content__c(Content_Collection__c = contentCollection.Id, Reference_Content__c = contentID);
                    rrcList.add(rrcObj);
                }
                
                if (rrcList.size() > 0) {
                    insert rrcList;
                }
                return JSON.serialize(new CollectionWrapper(contentCollection));
            } catch(Exception e) {
                Database.rollback(sp);
                Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
                return '@@' + e.getMessage();
            }
        } else {
            return '@@' + CRUDAndFLSCheckController.getErrorMsg();
        }
    }
    
    /**
     * Video Wrapper
     */
    global class VideoWrapper {
        public String videoURL { get; set; }
        public String questionTitle { get; set; }
        
        global VideoWrapper(Interview_Topic__c interviewTopic) {
            this.videoURL = (interviewTopic.Video_Url_Embed__c != null && interviewTopic.Video_Url_Embed__c != '' ? interviewTopic.Video_Url_Embed__c : '');
            this.questionTitle = (interviewTopic.Question__c != null ? interviewTopic.Question__c : '');
        }
    }
    
    /**
     * Content Wrapper
     */
    global class ContentWrapper {
        public Boolean isSelected { get; set; }
        public Reference_Content__c refContent { get; set; }
        public ContentVersion contentVersion { get; set; }
        public String fileTypeImagePath { get; set; }
        public String fileType { get; set; }
        public String accountName { get; set; }
        public List<String> accountId { get; set; }
        public String contentType { get; set; }
        public String publishDate { get; set; }
        public String refContentId { get; set; }
        public String title { get; set; }
        public String refContentType { get; set; }
        public String language { get; set; }
        public Boolean allowSharing { get; set; }
        public Boolean isInterviewType { get; set; }
        public String speakerInfo { get; set; }
        public List<VideoWrapper> videoWrapList { get; set; }
        public String orgWebsite { get; set; }
        List<CustomContentTypeWrapper> customContentFieldsList { get; set; }
        public String orgDescription { get; set; }
        public String photo { get; set; }
        //Interview Type
        global ContentWrapper(Reference_Content__c refContent, ContentVersion contentVersion, String accountName, List<String> accountId, Reference_Interview__c refInterview) {
            this.isSelected = false;
            this.title = refContent.Title__c;
            this.refContent = refContent;
            this.contentVersion = contentVersion;
            this.fileType = (contentVersion.FileType != null ? contentVersion.FileType : 'UNKNOWN');
            this.fileTypeImagePath = (UtilityController.mapContentTypeImagePath.containsKey(contentVersion.FileType) ? UtilityController.mapContentTypeImagePath.get(contentVersion.FileType) : '/doctype_unknown_16.png');
            this.accountName = accountName;
            this.accountId = accountId;
            this.contentType = refContent.Reference_Content_Type__r.Name__c;
            this.publishDate = (refContent.Publish_date__c != null ? refContent.Publish_date__c.format() : '');
            this.isInterviewType = refContent.Reference_Content_Type__r.Recorded_Reference_Type__c;
            this.speakerInfo = refInterview.Speaker_info__c;
            this.orgWebsite = refInterview.Org_website__c;
            this.orgDescription = refInterview.Org_description__c;
            this.photo = refInterview.Photograph__c;
            this.videoWrapList = new List<VideoWrapper>();
            this.language = refContent.Language__c;
            Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content__c.fields.getMap().get(UtilityController.appNamespace() + 'Reference_Content_Type__c').getDescribe();
            this.refContentType = (String)(refContent.getSobject(dfr.getRelationshipName()) != null ? refContent.getSobject(dfr.getRelationshipName()).get('Name__c') : '');
            
            if (refInterview.Interview_Topics__r != null && refInterview.Interview_Topics__r.size() > 0) {
                
                for (Interview_Topic__c it : refInterview.Interview_Topics__r) {
                    this.videoWrapList.add(new VideoWrapper(it));
                }
            }
        }
        // CustomContent type
        global ContentWrapper(Reference_Content__c refContent, ContentVersion contentVersion, String accountName, List<String> accountId, List<CustomContentTypeWrapper> customContentFieldsList) {
            this.isSelected = false;
            this.refContent = refContent;
            this.contentVersion = contentVersion;
            this.fileType = (contentVersion.FileType != null ? contentVersion.FileType : 'UNKNOWN');
            this.fileTypeImagePath = (UtilityController.mapContentTypeImagePath.containsKey(contentVersion.FileType) ? UtilityController.mapContentTypeImagePath.get(contentVersion.FileType) : '/doctype_unknown_16.png');
            this.accountName = accountName;
            this.accountId = accountId;
            this.contentType = refContent.Reference_Content_Type__r.Name__c;
            this.publishDate = (refContent.Publish_date__c != null ? refContent.Publish_date__c.format() : '');
            this.title = refContent.Title__c;
            this.refContentId = refContent.Id;
            Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content__c.fields.getMap().get(UtilityController.appNamespace() + 'Reference_Content_Type__c').getDescribe();
            this.refContentType = (String)(refContent.getSobject(dfr.getRelationshipName()) != null ? refContent.getSobject(dfr.getRelationshipName()).get('Name__c') : '');
            this.language = refContent.Language__c;
            this.allowSharing = refContent.Internal_Use__c;
            this.customContentFieldsList = customContentFieldsList;
        }

        global ContentWrapper(Reference_Content__c refContent, ContentVersion contentVersion, String accountName, List<String> accountId) {
            this.isSelected = false;
            this.refContent = refContent;
            this.contentVersion = contentVersion;
            this.fileType = (contentVersion.FileType != null ? contentVersion.FileType : 'UNKNOWN');
            this.fileTypeImagePath = (UtilityController.mapContentTypeImagePath.containsKey(contentVersion.FileType) ? UtilityController.mapContentTypeImagePath.get(contentVersion.FileType) : '/doctype_unknown_16.png');
            this.accountName = accountName;
            this.accountId = accountId;
            this.contentType = refContent.Reference_Content_Type__r.Name__c;
            this.publishDate = (refContent.Publish_date__c != null ? refContent.Publish_date__c.format() : '');
            this.title = refContent.Title__c;
            this.refContentId = refContent.Id;
            Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content__c.fields.getMap().get(UtilityController.appNamespace() + 'Reference_Content_Type__c').getDescribe();
            this.refContentType = (String)(refContent.getSobject(dfr.getRelationshipName()) != null ? refContent.getSobject(dfr.getRelationshipName()).get('Name__c') : '');
            this.language = refContent.Language__c;
            this.allowSharing = refContent.Internal_Use__c;
        }
    }
    
    /**
     * Method to get related accounts for RefContent
     */
    @RemoteAction
    global static String getRelatedAccountsForRefContent(List<String> accIds) {
        List<RelatedAccountWrapper> relatedAccounts = new List<RelatedAccountWrapper>();
        
        for (Account acc : WithoutSharingHelperController.getRelatedAccountsForRefContent(accIds)) {
            
            if (acc.Reference_Basic_Informations__r != null && acc.Reference_Basic_Informations__r.size() > 0) {
                relatedAccounts.add(new RelatedAccountWrapper(acc.Id,acc.Name,
                                                                acc.Type,
                                                                acc.Phone,
                                                                acc.Reference_Basic_Informations__r[0].Is_Referenceable__c,
                                                                acc.Reference_Basic_Informations__r[0].Referenceability_Status__c));
            } else {
                relatedAccounts.add(new RelatedAccountWrapper(acc.Id,acc.Name, acc.Type, acc.Phone, false, ''));
            }
        }
        
        if (relatedAccounts != null && relatedAccounts.size() > 0) {
            return JSON.serialize(relatedAccounts);
        }
        return '';
    }
    
    /**
     * Related Account Wrapper Class
     */
    global class RelatedAccountWrapper {
        public String id { get; set; }
        public String name { get; set; }
        public String accType { get; set; }
        public String phone { get; set; }
        public Boolean isReferenceable { get; set; }
        public String referenceabilityStatus { get; set; }
        
        global RelatedAccountWrapper(String name, String accType, String phone, Boolean isReferenceable, String referenceabilityStatus) {
            this.name = name;
            this.id = '';
            this.accType = accType;
            this.phone = phone;
            this.isReferenceable = isReferenceable;
            this.referenceabilityStatus = referenceabilityStatus;
        }
        
        global RelatedAccountWrapper(String id, String name, String accType, String phone, Boolean isReferenceable, String referenceabilityStatus) {
            this.id = id;
            this.name = name;
            this.accType = accType;
            this.phone = phone;
            this.isReferenceable = isReferenceable;
            this.referenceabilityStatus = referenceabilityStatus;
        }
    }
    
    /**
     * Method to download RefContent
     */
    @RemoteAction
    global static String updateRefContentStatistics(String refContentsJSON, String actionName) {
        try {
            Set<String> refContentIds = (Set<String>)JSON.deserialize(refContentsJSON, Set<String>.class);
            List<Reference_Content__c> refContentsToUpdate = new List<Reference_Content__c>();
            List<Reference_Content__c> refContents = WithoutSharingHelperController.getRefContentList(refContentIds);
            
            if (actionName == 'open link') {

                for (Reference_Content__c rc : refContents) {
                    Decimal oldCount = rc.Ref_Content_Open_Clicks__c != null ? rc.Ref_Content_Open_Clicks__c : 0;
                    rc.Ref_Content_Open_Clicks__c = oldCount + 1;
                    refContentsToUpdate.add(rc);
                }
            } else if (actionName == 'open detail') {

                for (Reference_Content__c rc : refContents) {
                    Decimal oldCount = rc.Ref_Content_View_Details_Clicks__c != null ? rc.Ref_Content_View_Details_Clicks__c : 0;
                    rc.Ref_Content_View_Details_Clicks__c = oldCount + 1;
                    refContentsToUpdate.add(rc);
                }
            }
            
            if (refContentsToUpdate != null && refContentsToUpdate.size() > 0) {
                WithoutSharingHelperController.upsertRefContentList(refContentsToUpdate);
            }
            return 'success';
        } catch (Exception e) {
            return 'Error' + ' ' + e.getMessage();
        }
    }
    
    /**
     * Method to download RefContent
     */
    @RemoteAction
    global static String downloadRefContent(String refContentsJSON) {
        try {
            Set<String> refContentIds = (Set<String>)JSON.deserialize(refContentsJSON, Set<String>.class);
            Set<String> contentVersionIds = new Set<String>(); 
            String contentDocs = '';
            String resultUrl = ''; 
            List<Reference_Content__c> refContentsToUpdate = new List<Reference_Content__c>();
            // changes for #786 - moved query to w/o sharing
            List<Reference_Content__c> refContents = WithoutSharingHelperController.getRefContentList(refContentIds);
            
            for (Reference_Content__c rc : refContents) {
                contentVersionIds.add(rc.Content_ID__c);
            }
            // changes for #786 - moved query to w/o sharing
            Map<Id, ContentVersion> mapContentVersion = WithoutSharingHelperController.getContentVersionMapForInvitation(contentVersionIds);
            
            for (Reference_Content__c rc : refContents) {
                 
                if (mapContentVersion != null && mapContentVersion.containsKey(rc.Content_ID__c)) {
                    
                    if (mapContentVersion.get(rc.Content_ID__c).ContentDocumentId != null) {
                        
                        if (contentDocs == '') {
                            contentDocs += mapContentVersion.get(rc.Content_ID__c).ContentDocumentId;
                        } else {
                            contentDocs = contentDocs + '/' + mapContentVersion.get(rc.Content_ID__c).ContentDocumentId;
                        }
                    }
                }
                Reference_Content__c temp = rc;
                decimal downloadCount = (temp.Number_of_Download__c != null ? temp.Number_of_Download__c : 0);
                temp.Number_of_Download__c = downloadCount + 1;
                refContentsToUpdate.add(temp);
            }
            
            if (refContentsToUpdate != null && refContentsToUpdate.size() > 0) {
                WithoutSharingHelperController.upsertRefContentList(refContentsToUpdate);
            }
            
            if (contentDocs != '') {
                String baseUrl = URL.getSalesforceBaseUrl().toExternalForm().replace('visual.force.com', 'content.force.com');
                resultUrl = baseUrl + '/sfc/servlet.shepherd/document/download/' + contentDocs;
                return resultUrl;
            } else {
                return '';
            }
        } catch (Exception e) {
            return 'Error' + ' ' + e.getMessage();
        }
    }
    
    /**
     * Method to save selected Columns
     */
    @RemoteAction
    global static String saveSelectedColumns(String selectedColumnsMapJSON) {
        Map<String, List<ColumnWrapper>> selectedColumnsMap = (Map<String, List<ColumnWrapper>>)JSON.deserialize(selectedColumnsMapJSON, Map<String, List<ColumnWrapper>>.class);
        List<User_Mapping__c> UMsToUpsert = new List<User_Mapping__c>();
        
        for (String objName : selectedColumnsMap.keySet()) {
            
            if (selectedColumnsMap.get(objName) != null && selectedColumnsMap.get(objName).size() > 0) {
                
                for (ColumnWrapper col : selectedColumnsMap.get(objName)) {
                    
                    if (col.name == 'LastNDays') {
                        col.label = System.Label.Last + ' ' + '$' + ' ' + System.Label.days;
                    }
                    
                    if (col.isSelected) {
                        
                        if (col.userMapping.Id == null) {
                            UMsToUpsert.add(new User_Mapping__c(Visible__c = true,
                                                                Field_API_Name__c = col.name,
                                                                User__c = UserInfo.getUserId(),
                                                                Label__c = col.label,
                                                                Default_Value__c = col.forObject,
                                                                Order__c = col.order,
                                                                Process__c = 'Column Selector'));
                        } else {
                            col.userMapping.Visible__c = true;
                            col.userMapping.Label__c = col.label;
                            col.userMapping.Order__c = col.order;
                            UMsToUpsert.add(col.userMapping);
                        }
                    } else {
                        
                        if (col.userMapping.Id != null) {
                            col.userMapping.Visible__c = false;
                            col.userMapping.Label__c = col.label;
                            col.userMapping.Order__c = col.order;
                            UMsToUpsert.add(col.userMapping);
                        } else {
                            UMsToUpsert.add(new User_Mapping__c(Visible__c = false,
                                                                Field_API_Name__c = col.name,
                                                                User__c = UserInfo.getUserId(),
                                                                Label__c = col.label,
                                                                Default_Value__c = col.forObject,
                                                                Order__c = col.order,
                                                                Process__c = 'Column Selector'));
                        }
                    }
                }
            }
        }
        
        if (UMsToUpsert != null && UMsToUpsert.size() > 0) {
            upsert UMsToUpsert;
            return JSON.serialize(selectedColumnsMap);
        }
        return '';
    }
    
    /**
     * Method to Save user mapping
     */
    @RemoteAction
    global static String saveUserMapping(String basicFilters1JSON, String basicFilters2JSON) {
        
        if (checkPermissions(false, 'Save')) {
            List<FilterWrapper> basicFilters1 = new List<FilterWrapper>();
            List<FilterWrapper> basicFilters2 = new List<FilterWrapper>();
            
            if (basicFilters1JSON != '') {
                basicFilters1 = (List<FilterWrapper>)JSON.deserialize(basicFilters1JSON, List<FilterWrapper>.class);
            }
            
            if (basicFilters2JSON != '') {
                basicFilters2 = (List<FilterWrapper>)JSON.deserialize(basicFilters2JSON, List<FilterWrapper>.class);
            }
            List<User_Mapping__c> UMsToUpsert = new List<User_Mapping__c>();
            List<User_Mapping__c> UMsToDelete = new List<User_Mapping__c>();
            Integer i = 0;
            
            if (basicFilters1 != null && basicFilters1.size() > 0) {
                
                for (i = 0; i < basicFilters1.size(); i++) {
                    
                    if (basicFilters1.get(i).userMappingVisible) {
                        
                        if (basicFilters1.get(i).userMapping.Id == null) {
                            UMsToUpsert.add(new User_Mapping__c(Order__c = i,
                                                                Visible__c = true,
                                                                Field_API_Name__c = basicFilters1.get(i).dataMapping.Field_API_Name__c,
                                                                User__c = UserInfo.getUserId(),
                                                                Label__c = basicFilters1.get(i).dataMapping.Label__c,
                                                                Process__c = 'My Filters'));
                        } else {
                            basicFilters1.get(i).userMapping.Order__c = i;
                            UMsToUpsert.add(basicFilters1.get(i).userMapping);
                        }
                    } else if (basicFilters1.get(i).userMapping.Id != null) {
                        UMsToDelete.add(basicFilters1.get(i).userMapping);
                    }
                }
            }
            
            if (basicFilters2 != null && basicFilters2.size() > 0) {
                
                for (Integer j = i; j < basicFilters2.size() + i; j++) {
                    
                    if (basicFilters2.get(j - i).userMappingVisible) {
                        
                        if (basicFilters2.get(j - i).userMapping.Id == null) {
                            UMsToUpsert.add(new User_Mapping__c(Order__c = j,
                                                                Visible__c = true,
                                                                Field_API_Name__c = basicFilters2.get(j - i).dataMapping.Field_API_Name__c,
                                                                User__c = UserInfo.getUserId(),
                                                                Label__c = basicFilters2.get(j - i).dataMapping.Label__c,
                                                                Process__c = 'My Filters'));
                        } else {
                            basicFilters2.get(j - i).userMapping.Order__c = j;
                            UMsToUpsert.add(basicFilters2.get(j - i).userMapping);
                        }
                    } else if (basicFilters2.get(j - i).userMapping.Id != null) {
                        UMsToDelete.add(basicFilters2.get(j - i).userMapping);
                    }
                }
            }
            
            if (UMsToDelete != null && UMsToDelete.size() > 0) {
                delete UMsToDelete;
            }
            Set<FilterWrapper> resultList = new Set<FilterWrapper>();
            
            if (UMsToUpsert != null && UMsToUpsert.size() > 0) {
                upsert UMsToUpsert;
                Map<String, FilterWrapper> tempMap = new Map<String, FilterWrapper>();
                
                if (basicFilters1 != null && basicFilters1.size() > 0) {
                    
                    for (FilterWrapper fw : basicFilters1) {
                        tempMap.put(fw.userMapping.Field_API_Name__c, fw);
                    }
                }
                
                if (basicFilters2 != null && basicFilters2.size() > 0) {
                    
                    for (FilterWrapper fw : basicFilters2) {
                        tempMap.put(fw.userMapping.Field_API_Name__c, fw);
                    }
                }
                
                for (User_Mapping__c um : UMsToUpsert) {
                    
                    if (tempMap != null && tempMap.containsKey(um.Field_API_Name__c) && tempMap.get(um.Field_API_Name__c) != null) {
                        resultList.add(tempMap.get(um.Field_API_Name__c));
                    }
                }
                return JSON.serialize(resultList);
            }
            return '';
        } else {
            return CRUDAndFLSCheckController.getErrorMsg();
        }
    }
    
    /**
     * Inner classes
     */
    global class FilterWrapper implements Comparable {
        public Data_Mapping__c dataMapping { get; set; }
        public User_Mapping__c userMapping { get; set; }
        public Boolean userMappingVisible { get; set; }
        
        global FilterWrapper(Data_Mapping__c dataMapping, Boolean userMappingVisible, User_Mapping__c userMapping) {
            this.dataMapping = dataMapping;
            this.userMappingVisible = userMappingVisible;
            this.userMapping = userMapping;
        }
        
        global Integer compareTo(Object compareTo) {
            FilterWrapper filterWrapObj = (FilterWrapper) compareTo;
            if (userMapping.Order__c == filterWrapObj.userMapping.Order__c) return 0;
            if (userMapping.Order__c > filterWrapObj.userMapping.Order__c) return 1;
            return -1;
        }
    }
    
    /**
     * Method to get basic filters
     */
    @RemoteAction
    global static String getbasicFilters() {
        List<FilterWrapper> filterWrapperList = new List<FilterWrapper>();
        Map<String, User_Mapping__c> userMappingMap = new Map<String, User_Mapping__c>();
        
        // changes for #786 - moved query to w/o sharing
        for (User_Mapping__c um : WithoutSharingHelperController.getUserMappings()) { 
                userMappingMap.put(um.Field_API_Name__c, um);
        }
        Set<String> filterSet = new Set<String>();
        
        // changes for #786 - moved query to w/o sharing
        for (Data_Mapping__c dm : WithoutSharingHelperController.getDataMappings()) {
            
            if (userMappingMap != null && userMappingMap.containsKey(dm.Field_API_Name__c)) {
                filterWrapperList.add(new FilterWrapper(dm, userMappingMap.get(dm.Field_API_Name__c).Visible__c, userMappingMap.get(dm.Field_API_Name__c)));
            } else {
                filterWrapperList.add(new FilterWrapper(dm, false, new User_Mapping__c(Order__c = 999999)));
            }
            filterSet.add(dm.Field_API_Name__c);
        }
        Map<String, List<FilterWrapper>> tempMap = new Map<String, List<FilterWrapper>>();
        
        // changes for #786 - moved query to w/o sharing
        for (Data_Mapping__c dm : WithoutSharingHelperController.getDataMappings1()) {
            
            if (!tempMap.containsKey(dm.Label__c)) {
                tempMap.put(dm.Label__c, new List<FilterWrapper>());
            }
            tempMap.get(dm.Label__c).add(new FilterWrapper(dm,
                                                (userMappingMap != null && userMappingMap.containsKey(dm.Field_API_Name__c) ? userMappingMap.get(dm.Field_API_Name__c).Visible__c : false),
                                                (userMappingMap != null && userMappingMap.containsKey(dm.Field_API_Name__c) ? userMappingMap.get(dm.Field_API_Name__c) : new User_Mapping__c(Order__c = 999999))));
            filterSet.add(dm.Field_API_Name__c);
        }
        
        // changes for #786 - moved query to w/o sharing
        for (Label__c lbl : WithoutSharingHelperController.getFilters()) {
            
            if (!filterSet.contains(lbl.Id) && lbl.Filter_RefSearch_Visible__c) {
                
                if (!tempMap.containsKey(lbl.Name)) {
                    tempMap.put(lbl.Name, new List<FilterWrapper>());
                }
                
                if (userMappingMap != null && userMappingMap.containsKey(lbl.Id)) {
                    tempMap.get(lbl.Name).add(new FilterWrapper(
                                                    new Data_Mapping__c(Label__c = lbl.Name,
                                                                        Field_API_Name__c = lbl.Id,
                                                                        Object__c = 'Filter',
                                                                        Visible__c = lbl.BasicSearchView__c,
                                                                        Filter_RefSearch_Visible__c = lbl.Filter_RefSearch_Visible__c,
                                                                        From_Mapping__c = false),
                                                    userMappingMap.get(lbl.Id).Visible__c,
                                                    userMappingMap.get(lbl.Id)));
                } else {
                    tempMap.get(lbl.Name).add(new FilterWrapper(
                                                    new Data_Mapping__c(Label__c = lbl.Name,
                                                                        Field_API_Name__c = lbl.Id,
                                                                        Object__c = 'Filter',
                                                                        Visible__c = lbl.BasicSearchView__c,
                                                                        Filter_RefSearch_Visible__c = lbl.Filter_RefSearch_Visible__c,
                                                                        From_Mapping__c = false),
                                                    false,
                                                    new User_Mapping__c(Order__c = 999999)));
                }
            }
        }
        List<String> sortedfilter = new List<String>();
        sortedfilter.addAll(tempMap.keySet());
        sortedfilter.sort();
        
        for (String label : sortedfilter) {
            filterWrapperList.addAll(tempMap.get(label));
        }
        
        if (filterWrapperList != null && filterWrapperList.size() > 0) {
            filterWrapperList.sort();
            return JSON.serialize(filterWrapperList);
        } else {
            return '';
        }
    }
    
    /**
     * Method to get filter attribute
     */
    @RemoteAction
    global static Map<String, List<AttributesLabelWrapper>> getAllFilterAttributes(String filterIdsJson) {
        Set<String> filterIds = (Set<String>)JSON.deserialize(filterIdsJson, Set<String>.class);
        Map<String, List<AttributesLabelWrapper>> lstAttributeWrapper = new Map<String, List<AttributesLabelWrapper>>();
        // changes for #786 - moved query to w/o sharing
        for (Label__c label : WithoutSharingHelperController.getFilters1(filterIds)) {
            lstAttributeWrapper.put(label.Id, new List<AttributesLabelWrapper>());
            
            for (Attributes_Labels__c al : label.Attributes_Labels__r) {
                lstAttributeWrapper.get(label.Id).add(new AttributesLabelWrapper(al));
            }
        }
        return lstAttributeWrapper;
    }

    /**
     * Method to get filter dependency
     */
    @RemoteAction
    public static String getDependencyDetails() {
        try {
            Map<String, DependentFilterWrapper> lstAttributeWrapper = new Map<String, DependentFilterWrapper>();
            Map<String, List<Data_Mapping__c>> dmMap = new Map<String, List<Data_Mapping__c>>();
            for (Data_Mapping__c dmRecord : [SELECT Field_API_Name__c, Label__c, Section_Name__c, Default__c, Visible__c, Object__c
                                        FROM Data_Mapping__c
                                        WHERE Object__c = :ConstantsController.DEPENDENT_FILTERS
                                        AND From_Mapping__c = false]) {
                if (!dmMap.containsKey(dmRecord.Field_API_Name__c)) {
                    dmMap.put(dmRecord.Field_API_Name__c,new List<Data_Mapping__c>());
                }
                dmMap.get(dmRecord.Field_API_Name__c).add(dmRecord);
            }
            
            for (Label__c label : WithoutSharingHelperController.getFilters1(dmMap.keySet())) {
                Map<String,Set<String>> attributeEntry = new Map<String,Set<String>>();
                String cf = '';
                for (Attributes_Labels__c al : label.Attributes_Labels__r) {
                    Set<String> visibleFor = new Set<String>();
                    
                    for (Data_Mapping__c dmRecord : dmMap.get(label.Id)) {
                        dmRecord.Default__c = dmRecord.Default__c == null ? '' : dmRecord.Default__c; 
                        Set<String> da = new Set<String> (dmRecord.Default__c.split(';'));
                        cf = dmRecord.Label__c;
                        if (da.contains(al.Attribute__c)) {
                            visibleFor.add(dmRecord.Section_Name__c);
                        }
                    }
                    attributeEntry.put(al.Attribute__c,visibleFor);
                }
                lstAttributeWrapper.put(label.Id,new DependentFilterWrapper(cf,attributeEntry));
            }
            return JSON.serialize(lstAttributeWrapper);
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
    
    /**
     * Method to get Contact Record
     */
    @RemoteAction
    global static String getContactRecords(String attributeMapInheritableContactIdsJSON) {
        Set<String> attributeMapInheritableContactIds = (Set<String>)JSON.deserialize(attributeMapInheritableContactIdsJSON, Set<String>.class);
        Set<String> contactAccountIds = new Set<String>();
        
        // changes for #786 - moved query to w/o sharing
        for (Contact con : WithoutSharingHelperController.getContact(attributeMapInheritableContactIds)) {
            contactAccountIds.add(con.AccountId);
        }
        return JSON.serialize(contactAccountIds);
    }
    
    /**
     * Method to get Related Contact Records
     */
    @RemoteAction
    global static String getRelatedContactRecords(String attributeMapInheritableContactIdsJSON) {
        Set<String> attributeMapInheritableContactIds = (Set<String>)JSON.deserialize(attributeMapInheritableContactIdsJSON, Set<String>.class);
        Set<String> contactAccountIds = new Set<String>();
        
        // changes for #786 - moved query to w/o sharing
        for (Contact con : WithoutSharingHelperController.getContactsForAccounts(attributeMapInheritableContactIds)) {
            contactAccountIds.add(con.Id);
        }
        return JSON.serialize(contactAccountIds);
    }
    
    /**
     * Method to get Related Contact Records
     */
    @RemoteAction
    global static String getRelatedContentRecords(String attributeMapInheritableContentIdsJSON) {
        Set<String> attributeMapInheritableContentIds = (Set<String>)JSON.deserialize(attributeMapInheritableContentIdsJSON, Set<String>.class);
        Set<String> inheritableAccountIds = new Set<String>(); 
        
        // changes for #786 - moved query to w/o sharing
        for (Account_Reference_Content__c arc : WithoutSharingHelperController.getARCForAccounts1(attributeMapInheritableContentIds)) {
            inheritableAccountIds.add(arc.Reference_Content__c);
        }
        return JSON.serialize(inheritableAccountIds);
    }
    
    /**
     * Method to get Related Contact Records
     */
    @RemoteAction
    global static String getContentRecords(String attributeMapInheritableContentIdsJSON) {
        Set<String> attributeMapInheritableContentIds = (Set<String>)JSON.deserialize(attributeMapInheritableContentIdsJSON, Set<String>.class);
        Set<String> inheritableAccountIds = new Set<String>();
        
        // changes for #786 - moved query to w/o sharing
        for (Account_Reference_Content__c arc : WithoutSharingHelperController.getARCForAccounts2(attributeMapInheritableContentIds)) {
            inheritableAccountIds.add(arc.Account__c);
        }
        return JSON.serialize(inheritableAccountIds);
    }
    
    /**
     * Method to get mapping Records
     */
    @RemoteAction
    global static String getMappingRecords(String mappingIdsJSON) {
        Set<String> mappingIds = (Set<String>)JSON.deserialize(mappingIdsJSON, Set<String>.class);
        // changes for #786 - moved query to w/o sharing
        List<Attribute_Mapping__c> attMappings = WithoutSharingHelperController.getAttributeMappings(mappingIds);
        return JSON.serialize(attMappings);
    }
    
    /**
     * Method to get filter Records
     */
    @RemoteAction
    global static String filterRecords(String filterId, String selectedAttributesJSON) {
        Attribute_Mapping__c attMapping;
        Set<String> selectedValues = (Set<String>)JSON.deserialize(selectedAttributesJSON, Set<String>.class);
        Map<String, Set<String>> mappingRelatedIds = new Map<String, Set<String>>();
        
        if (filterId != '') {
            
            for (Attribute_Mapping__c attM : WithoutSharingHelperController.getAttributeMappings(filterId)) {
                attMapping = attM;
            }
            String query;
            String values = '';
            if (!attMapping.Is_Related_MultiSelectPicklist__c) {
                query = 'SELECT Id, ' + attMapping.Field_Api_Name__c
                            + ' FROM ' + attMapping.Related_Object__c
                            + ' WHERE ' + attMapping.Field_Api_Name__c + ' IN :selectedValues LIMIT 2001';
            } else {
                for (String selected : selectedValues) {
                    
                    if (values == '') {
                        values += '\'' + selected + '\'';
                    } else {
                        values += ',\'' + selected + '\'';
                    }
                }
                query = 'SELECT Id, ' + attMapping.Field_Api_Name__c
                            + ' FROM ' + attMapping.Related_Object__c
                            + ' WHERE ' + attMapping.Field_Api_Name__c + ' INCLUDES (' + values + ') LIMIT 2001';
            }
            Set<String> relatedObjectIds = new Set<String>();
            
            if (attMapping.Object__c == ConstantsController.REFERENCE_PROFILE) {
            
                if (attMapping.Related_Object__c == 'Account') {
                    query = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                            + ' WHERE Contact__c = null AND Account__c != null '
                            + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                            + '\' AND Referenceability_Status__c != null ';
                } else if (attMapping.Related_Object__c == 'Contact') {
                    query = 'SELECT Id, Contact__c, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                            + ' WHERE Contact__c != null AND Account__c != null '
                            + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                            + '\' AND Referenceability_Status__c != null ';
                }
                
                if (!attMapping.Is_Related_MultiSelectPicklist__c) {
                    
                    if (attMapping.Related_Object__c == 'Account') {
                        query += 'AND Account__r.' + attMapping.Field_Api_Name__c + ' IN :selectedValues LIMIT 2001';
                    } else if (attMapping.Related_Object__c == 'Contact') {
                        query += 'AND Contact__r.' + attMapping.Field_Api_Name__c + ' IN :selectedValues LIMIT 2001';
                    }
                } else {
                    
                    //the reference profile is queried directly 
                    if (attMapping.Related_Object__c == 'Account') {
                        query += 'AND Account__r.' + attMapping.Field_Api_Name__c + ' INCLUDES (' + values + ' ) LIMIT 2001';
                    } else if (attMapping.Related_Object__c == 'Contact') {
                        query += 'AND Contact__r.' + attMapping.Field_Api_Name__c + ' INCLUDES (' + values + ' ) LIMIT 2001';
                    }
                }
                
                for (sObject so : WithoutSharingHelperController.filterRecords(query, attMapping, values, selectedValues)) {
                        
                    if (attMapping.Related_Object__c == 'Account') {
                        relatedObjectIds.add(String.valueOf(so.get('Account__c')));
                    } else if (attMapping.Related_Object__c == 'Contact') {
                        relatedObjectIds.add(String.valueOf(so.get('Contact__c')));
                    }
                }
                
                if (attMapping.Related_Object__c == 'Account') {
                    mappingRelatedIds.put('account', relatedObjectIds);
                } else if (attMapping.Related_Object__c == 'Contact') {
                    mappingRelatedIds.put('contact', relatedObjectIds);
                }
            } else {
                for (Sobject so : WithoutSharingHelperController.getFilteredRecords(selectedValues, query)) {
                    relatedObjectIds.add(String.valueOf(so.get('Id')));
                }
                
                if (attMapping.Mapping_Type__c == 'Parent Object') {
                    
                    if (attMapping.Object__c == 'Reference Content') {
                        query = 'Select Id FROM Reference_Content__c '
                                    + 'WHERE ' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds LIMIT 2001';
                        Set<String> relatedContentIds = new Set<String>();
                        
                        for (Reference_Content__c rc : (List<Reference_Content__c>)WithoutSharingHelperController.getFilteredRecords1(relatedObjectIds, query)) {
                            relatedContentIds.add(rc.Id);
                        }
                        mappingRelatedIds.put('content', relatedContentIds);
                    }
                    
                    if (attMapping.Object__c == 'Account') {
                        Set<String> relatedAccIds = new Set<String>();
                        query = 'SELECT Id, Account__c FROM Reference_Basic_Information__c '
                                + ' WHERE Contact__c = null AND Account__c != null '
                                + 'AND Account__r.' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds LIMIT 2001';
                        
                        for (Reference_Basic_Information__c rc : (List<Reference_Basic_Information__c>)WithoutSharingHelperController.getFilteredRecords1(relatedObjectIds, query)) {
                            relatedAccIds.add(rc.Account__c);
                        }
                        mappingRelatedIds.put('account', relatedAccIds);
                    }
                    
                    if (attMapping.Object__c == 'Contact') {
                        Set<String> relatedContactIds = new Set<String>();
                        query = 'SELECT Id, Contact__c FROM Reference_Basic_Information__c '
	            			+ ' WHERE Contact__c != null AND Account__c != null '
	            			+ ' AND Contact__r.' + attMapping.RelationShip_Name__c + ' IN :relatedObjectIds LIMIT 2001';
                        
                        for (Reference_Basic_Information__c rc : (List<Reference_Basic_Information__c>)WithoutSharingHelperController.getFilteredRecords1(relatedObjectIds, query)) {
                            relatedContactIds.add(rc.Contact__c);
                        }
                        mappingRelatedIds.put('contact', relatedContactIds);
                    }
                } else if (attMapping.Mapping_Type__c == 'Child Object') {
                    
                    if (attMapping.Object__c == 'Contact') {
                        Set<String> relatedContactIds = new Set<String>();
                        query = 'Select Id, ' + attMapping.RelationShip_Name__c
                                    + ' FROM ' + attMapping.Related_Object__c
                                    + ' WHERE Id IN :relatedObjectIds '
                                    + 'AND ' + attMapping.RelationShip_Name__c + ' != null LIMIT 2001';
                        
                        for (Sobject so : WithoutSharingHelperController.getFilteredRecords1(relatedObjectIds, query)) {
                            relatedContactIds.add(String.valueOf(so.get(attMapping.RelationShip_Name__c)));
                        }
                        mappingRelatedIds.put('contact', relatedContactIds);
                    }
                    
                    if (attMapping.Object__c == 'Reference Content') {
                        Set<String> relatedContentIds = new Set<String>();
                        query = 'Select Id, ' + attMapping.RelationShip_Name__c
                                    + ' FROM ' + attMapping.Related_Object__c
                                    + ' WHERE Id IN :relatedObjectIds '
                                    + 'AND ' + attMapping.RelationShip_Name__c + ' != null LIMIT 2001';
                        
                        for (Sobject so : WithoutSharingHelperController.getFilteredRecords1(relatedObjectIds, query)) {
                            relatedContentIds.add(String.valueOf(so.get(attMapping.RelationShip_Name__c)));
                        }
                        mappingRelatedIds.put('content', relatedContentIds);
                    }
                    
                    if (attMapping.Object__c == 'Account') {
                        Set<String> relatedAccIds = new Set<String>();
                        query = 'SELECT Id, ' + attMapping.RelationShip_Name__c
                                    + ' FROM  ' + attMapping.Related_Object__c
                                    + ' WHERE Id IN :relatedObjectIds '
                                    + 'AND ' + attMapping.RelationShip_Name__c + ' != null LIMIT 2001';
                        
                        for (Sobject so : WithoutSharingHelperController.getFilteredRecords1(relatedObjectIds, query)) {
                            relatedAccIds.add(String.valueOf(so.get(attMapping.RelationShip_Name__c)));
                        }
                        mappingRelatedIds.put('account', relatedAccIds); 
                    }
                }
            }
        }
        return JSON.serialize(mappingRelatedIds);
    }
    
    /**
     * Method to get search related mapping
     */
    @RemoteAction
    global static List <RelatedMappingWrapper> searchRelatedMAppingAttributes(String filterId, String inputTextValue) {
        Attribute_Mapping__c attMapping;
        List<RelatedMappingWrapper> searchResults = new List<RelatedMappingWrapper>();
        
        if (filterId != '') {
            for (Attribute_Mapping__c attM : WithoutSharingHelperController.getAttributeMappings(filterId)) {
                attMapping = attM;
            }
            inputTextValue = String.escapeSingleQuotes(inputTextValue);
            
            if (attMapping.Object__c == ConstantsController.REFERENCE_PROFILE) {
                    
                if (attMapping.Related_Object__c == 'Account') {
                    String dynamicQuery = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                            + ' WHERE Contact__c = null AND Account__c != null AND Account__r.' + attMapping.Field_Api_Name__c + ' != null '
                            + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                            + '\' AND Referenceability_Status__c != null '
                            + ' AND Account__r.' + attMapping.Field_Api_Name__c + ' like \'%' + inputTextValue 
                            + '%\' ORDER BY Account__r.' + attMapping.Field_Api_Name__c + ' limit 201 ';
                    Set<String> duplicateCheck = new Set<String>();
                    
                    for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(dynamicQuery)) {
                        
                        if (!duplicateCheck.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                            duplicateCheck.add(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
                            RelatedMappingWrapper sc = new RelatedMappingWrapper(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)),String.valueOf(so.get('Account__c')),filterId);
                            searchResults.add(sc);
                        }
                        
                        if (searchResults.size() >= 201) {
                            break;
                        }
                    }
                } else if (attMapping.Related_Object__c == 'Contact') {
                    String dynamicQuery = 'SELECT Id, Contact__c, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                            + ' WHERE Contact__c != null AND Account__c != null AND Contact__r.' + attMapping.Field_Api_Name__c + ' != null '
                            + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                            + '\' AND Referenceability_Status__c != null '
                            + ' AND Contact__r.' + attMapping.Field_Api_Name__c + ' like \'%' + inputTextValue 
                            + '%\' ORDER BY Contact__r.' + attMapping.Field_Api_Name__c + ' limit 201 ';
                    Set<String> duplicateCheck = new Set<String>();

                    for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(dynamicQuery)) {
                    
                        if (!duplicateCheck.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                            duplicateCheck.add(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
                            RelatedMappingWrapper sc = new RelatedMappingWrapper(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)), 
                                                                String.valueOf(so.get('Contact__c')),filterId);
                            searchResults.add(sc);
                        }
                        
                        if (searchResults.size() >= 201) {
                            break;
                        }
                    }
                }
            } else {
                // changes for #786 - moved query to w/o sharing
                String query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c + ' WHERE ' + attMapping.Field_Api_Name__c + ' like \'%' + inputTextValue + '%\' ORDER BY ' + attMapping.Field_Api_Name__c + ' limit 201 ';
                Set<String> duplicateCheck = new Set<String>();
                
                // changes for #786 - moved query to w/o sharing
                for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(query)) {
                    
                    if (!duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                        duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
                        RelatedMappingWrapper sc = new RelatedMappingWrapper(String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')),filterId);
                        searchResults.add(sc);
                    }
                }   
            }
        }
        return searchResults;
    }
    
    /**
     * Method to get Related filter attribute
     */
    @RemoteAction
    global static List<RelatedMappingWrapper> getRelatedFilterAttributes(String filterId) {
        Attribute_Mapping__c attMapping;
        transient List<RelatedMappingWrapper> searchResults = new List<RelatedMappingWrapper>();
        
        if (filterId != '') {
            
            // changes for #772 - moved query to without sharing
            for (Attribute_Mapping__c attM : WithoutSharingHelperController.getAttributeMappings(filterId)) {
                attMapping = attM;
            }
            Boolean isFieldPicklistType = false;
            Set<String> selectedValues = new Set<String>();
            Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
            Schema.SObjectType objType = gd.get(attMapping.Related_Object__c);
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
            
            if (fieldMap.containsKey(attMapping.Field_Api_Name__c) &&
                (fieldMap.get(attMapping.Field_Api_Name__c).getDescribe().getType() == Schema.DisplayType.PICKLIST ||
                    fieldMap.get(attMapping.Field_Api_Name__c).getDescribe().getType() == Schema.DisplayType.MULTIPICKLIST)) {
                isFieldPicklistType = true;
                
                for (Schema.PicklistEntry pe : fieldMap.get(attMapping.Field_Api_Name__c).getDescribe().getPickListValues()) {
                    RelatedMappingWrapper sc = new RelatedMappingWrapper(pe.getLabel(), '',filterId);
                    
                    if (selectedValues.contains(pe.getLabel().tolowerCase())) {
                        sc.isSelected = true;
                    } else {
                        sc.isSelected = false;
                    }
                    searchResults.add(sc);
                }
            }
            
            if (fieldMap.containsKey(attMapping.Field_Api_Name__c)) {
                
                if (selectedValues.size() > 0 && !isFieldPicklistType) {
                    String query = 'SELECT Id, ' + attMapping.Field_Api_Name__c
                                    + ' FROM ' + attMapping.Related_Object__c
                                    + ' WHERE ' + attMapping.Field_Api_Name__c + ' IN :selectedValues';
                    Set<String> duplicateCheck = new Set<String>();
                    
                    // changes for #772 - moved query to without sharing
                    for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(query)) {
                        
                        if (!duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                            duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
                            RelatedMappingWrapper sc = new RelatedMappingWrapper(String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')),filterId);
                            sc.isSelected = true;
                            searchResults.add(sc);
                        }
                    }
                } else if (!isFieldPicklistType) {
                    
                    if (attMapping.Object__c == ConstantsController.REFERENCE_PROFILE) {
                    
                        if (attMapping.Related_Object__c == 'Account') {
                            String dynamicQuery = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                                    + ' WHERE Contact__c = null AND Account__c != null AND Account__r.' + attMapping.Field_Api_Name__c + ' != null '
                                    + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                                    + '\' AND Referenceability_Status__c != null '
                                    + ' LIMIT ' + (limits.getLimitQueryRows() - limits.getQueryRows());
                            Set<String> duplicateCheck = new Set<String>();
                            
                            for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(dynamicQuery)) {
                                
                                if (!duplicateCheck.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                                    duplicateCheck.add(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
                                    RelatedMappingWrapper sc = new RelatedMappingWrapper(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)),String.valueOf(so.get('Account__c')),filterId);
                                    searchResults.add(sc);
                                }
                                
                                if (searchResults.size() >= 201) {
                                    break;
                                }
                            }
                        } else if (attMapping.Related_Object__c == 'Contact') {
                            String dynamicQuery = 'SELECT Id, Contact__c, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                                    + ' WHERE Contact__c != null AND Account__c != null AND Contact__r.' + attMapping.Field_Api_Name__c + ' != null '
                                    + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                                    + '\' AND Referenceability_Status__c != null '
                                    + ' LIMIT ' + (limits.getLimitQueryRows() - limits.getQueryRows());
                            Set<String> duplicateCheck = new Set<String>();

                            for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(dynamicQuery)) {
                            
                                if (!duplicateCheck.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                                    duplicateCheck.add(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
                                    RelatedMappingWrapper sc = new RelatedMappingWrapper(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)), 
                                                                        String.valueOf(so.get('Contact__c')),filterId);
                                    searchResults.add(sc);
                                }
                                
                                if (searchResults.size() >= 201) {
                                    break;
                                }
                            }
                        }
                    } else {
                        String dynamicQuery = 'SELECT Id, ' + attMapping.Field_Api_Name__c
                                            + ' FROM ' + attMapping.Related_Object__c
                                            + ' WHERE ' + attMapping.Field_Api_Name__c + ' != null '
                                            + 'ORDER BY ' + attMapping.Field_Api_Name__c
                                            + ' LIMIT ' + (limits.getLimitQueryRows() - limits.getQueryRows());
                        Set<String> duplicateCheck = new Set<String>();
                        // changes for #772 - moved query to without sharing
                        for (Sobject so : WithoutSharingHelperController.getSobjectinContactSearch(dynamicQuery)) {
                            
                            if (!duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                                duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
                                RelatedMappingWrapper sc = new RelatedMappingWrapper(String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')),filterId);
                                searchResults.add(sc);
                            }
                            
                            if (searchResults.size() == 201) {
                                break;
                            }
                        }
                    }
                }
            }
        }
        return searchResults; 
    }
    
    /**
     * Method to get Filter Attributes
     */
    @RemoteAction
    global static List<AttributesLabelWrapper> getFilterAttributes(String filterId) {
        List<AttributesLabelWrapper> lstAttributeWrapper = new List<AttributesLabelWrapper>();
        
        if (filterId != '') {
            
            // changes for #786 - moved query to w/o sharing
            for (Attributes_Labels__c al : WithoutSharingHelperController.getAttributeLabels(filterId)) {
                lstAttributeWrapper.add(new AttributesLabelWrapper(al));
            }
        }
        return lstAttributeWrapper;
    }
    
    /**
     * Method to get Referenceability 
     */
    @RemoteAction
    global static List<ReferenceabilityTypeWrapper> getReferenceability() {
        List<ReferenceabilityTypeWrapper> referenceabilityTypeWrapper = new List<ReferenceabilityTypeWrapper>();
        
        // changes for #786 - moved query to w/o sharing
        for (Referenceability_Type__c rt : WithoutSharingHelperController.getRefTypes()) {
            referenceabilityTypeWrapper.add(new ReferenceabilityTypeWrapper(rt));
        }
        return referenceabilityTypeWrapper;
    }
    
    /**
     * Method to get Content Language 
     */
    @RemoteAction
    global static List<ContentLanguageWrapper> getContentLanguage() {
        List<ContentLanguageWrapper> contentLanguages = new List<ContentLanguageWrapper>();
        Schema.DescribeFieldResult field = Reference_Content__c.Language__c.getDescribe(); //Values from Schema
        List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
        
        for (Schema.PicklistEntry picklistValue : picklistValues) {
            contentLanguages.add(new ContentLanguageWrapper(picklistValue.getValue()));
        }
        return contentLanguages;
    }
    
    /**
     * Method to get Content Types
     */
    @RemoteAction
    global static List<ContentTypeWrapper> getContentTypes() {
        List<ContentTypeWrapper> contentTypes = new List<ContentTypeWrapper>();
        
        // changes for #786 - moved query to w/o sharing
        for (Reference_Content_Type__c rc : WithoutSharingHelperController.getContentTypeList()) {
            contentTypes.add(new ContentTypeWrapper(rc.Name__c));
        }
        return contentTypes;
    }
    
    /**
     * Method to get Ref content for account
     */
    @RemoteAction
    global static String getRefContentForAccount(String accId) {
        List<Account_Reference_Content__c> ARCList = WithoutSharingHelperController.getARCsForAccount(accId);
        Set<String> refContentIds = new Set<String>();
        Set<String> contentVersionIds = new Set<String>(); 
        List<ContentWrapper> contentWrapperList = new List<ContentWrapper>();
        String AccountName = '';
        if (ARCList != null && ARCList.size() > 0) {
            
            for (Account_Reference_Content__c ARC : ARCList) {
                refContentIds.add(ARC.Reference_Content__c);
                if (AccountName == '') {
                    AccountName = ARC.Account__r.Name;
                }
            }
            List<Reference_Content__c> refContentList = WithoutSharingHelperController.getRefContentForAccount(refContentIds);
            Map<Id, Reference_Interview__c> refInterviewMap = new Map<Id, Reference_Interview__c>();
            List<Reference_Interview__c> tempRefInterviewList = new List<Reference_Interview__c>();
            // changes for #786 - moved query to w/o sharing
            tempRefInterviewList = WithoutSharingHelperController.getRefInterviewListForInvitation();
            
            for (Reference_Interview__c ri : tempRefInterviewList) {
                refInterviewMap.put(ri.Reference_Content__c, ri);
            }
            Map<String, Schema.DescribeFieldResult> customContentFieldsMap = new Map<String, Schema.DescribeFieldResult>();
            Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Reference_Content_Type_Field__c');
            Map<String, Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            Set<String> queryFieldsSet = new Set<String>();
            queryFieldsSet.add(UtilityController.appNamespace() + 'Reference_Content__c');
            Map<Id,Set<String>> availableFields = new Map<Id,Set<String>>();
            
            for (String field : fieldMap.keySet()) {
                Schema.DescribeFieldResult dfr = fieldMap.get(field).getDescribe();
                
                if (dfr.isCustom()) {
                    customContentFieldsMap.put(dfr.getName(), dfr);
                    queryFieldsSet.add(dfr.getName());
                    
                    if (String.valueOf(dfr.getType()) == 'REFERENCE') {
                        queryFieldsSet.add(dfr.getName().replace('__c','__r') + '.Name');
                    }
                }
            }
            

            if (refContentList != null && refContentList.size() > 0) {
                Map<Id, Reference_Content_Type_Field__c> customContentMap
                                = WithoutSharingHelperController.getRefContentTypeFields(new List<String>(refContentIds),queryFieldsSet);
                
                for (Reference_Content__c refContent : refContentList) {
                    contentVersionIds.add(refContent.Content_ID__c);
                    if (refContent.Custom_Reference_Content__c) {
                        availableFields.put(refContent.Reference_Content_Type__c, new Set<String>());
                    } 
                }
                Set<Id> availableFieldsKeys  = availableFields.keySet();
            
                for (Reference_Type_Mapping__c rtm : WithoutSharingHelperController.getRefTypeMapping(availableFieldsKeys)) {
                    availableFields.get(rtm.Reference_Content_Type__c).add(rtm.name);                                                   
                }
                // changes for #786 - moved query to w/o sharing
                Map<Id, ContentVersion> mapContentVersion = WithoutSharingHelperController.getContentVersionMapForInvitation(contentVersionIds);
                
                for (Reference_Content__c rc : refContentList) {
                    
                    if (mapContentVersion.containsKey(rc.Content_ID__c)) {
                        if (refInterviewMap != null
                            && refInterviewMap.containsKey(rc.Id)
                            && refInterviewMap.get(rc.Id) != null) {
                            contentWrapperList.add(new ContentWrapper(rc, mapContentVersion.get(rc.Content_ID__c), AccountName, new List<String>{accId}, refInterviewMap.get(rc.Id)));
                        } else {
                            contentWrapperList.add(new ContentWrapper(rc, mapContentVersion.get(rc.Content_ID__c), AccountName, new List<String>()));
                        }
                    } else {
                        if (refInterviewMap != null
                            && refInterviewMap.containsKey(rc.Id)
                            && refInterviewMap.get(rc.Id) != null) {
                            contentWrapperList.add(new ContentWrapper(rc, new ContentVersion(), AccountName, new List<String>{accId}, refInterviewMap.get(rc.Id)));
                        } else if (rc.Custom_Reference_Content__c && customContentMap != null && customContentMap.containsKey(rc.Id) && customContentMap.get(rc.Id) != null) {
                            List<CustomContentTypeWrapper> customContentTypeWrapperList = new List<CustomContentTypeWrapper>();
                        
                            for (String field : availableFields.get(rc.Reference_Content_Type__c)) {
                                
                                if (customContentFieldsMap.containsKey(field)) {
                                    
                                    if ((String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATE' || String.valueOf(customContentFieldsMap.get(field).getType()) == 'DATETIME') && customContentMap.get(rc.Id).get(field) != null && String.valueOf(customContentMap.get(rc.Id).get(field)).trim() != '') {
                                        String data = String.valueOf(customContentMap.get(rc.Id).get(field));
                                        Date dateValue = date.valueOf(data);
                                        Integer d = dateValue.day();
                                        Integer mo = dateValue.month();
                                        Integer yr = dateValue.year();
                                        DateTime dateTimeValue = DateTime.newInstance(yr, mo, d);
                                        data = dateTimeValue.format('MMM dd yyyy');//Format date
                                        customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), data, String.valueOf(customContentFieldsMap.get(field).getType())));
                                    } else if (String.valueOf(customContentFieldsMap.get(field).getType()) == 'REFERENCE' && !field.contains('Reference_Content__c')) {
                                        String fieldName = field.replace('__c','__r');
                                        sObject data = customContentMap.get(rc.Id).getSObject(fieldName);                              
                                    // customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), String.valueOf(data.get('Name')), String.valueOf(customContentFieldsMap.get(field).getType())));
                                    customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), data, String.valueOf(customContentFieldsMap.get(field).getType())));
                                        
                                    } else if (!field.contains('Reference_Content__c')) {
                                        customContentTypeWrapperList.add(new CustomContentTypeWrapper(field, customContentFieldsMap.get(field).getLabel(), customContentMap.get(rc.Id).get(field), String.valueOf(customContentFieldsMap.get(field).getType())));
                                    }
                                }
                            }
                            contentWrapperList.add(new ContentWrapper(rc, new ContentVersion(), AccountName, new List<String>{accId}, customContentTypeWrapperList));
                        } else {
                            contentWrapperList.add(new ContentWrapper(rc, new ContentVersion(), AccountName, new List<String>()));
                        }
                    }
                }
            }
            return JSON.serialize(contentWrapperList);
        }
        return '';
    }
    
    /**
     * RefContent Wrapper classes
     */
    global class RefContentWrapper {
        public Boolean isSelected { get; set; }
        public String refContentId { get; set; }
        public String title { get; set; }
        public String refContentType { get; set; }
        public String publishDate { get; set; }
        public String language { get; set; }
        public Boolean allowSharing { get; set; }
        
        global RefContentWrapper(Reference_Content__c rc) {
            this.title = rc.Title__c;
            this.refContentId = rc.Id;
            Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content__c.fields.getMap().get(UtilityController.appNamespace() + 'Reference_Content_Type__c').getDescribe();
            this.refContentType = (String)(rc.getSobject(dfr.getRelationshipName()) != null ? rc.getSobject(dfr.getRelationshipName()).get('Name__c') : '');
            this.publishDate = (rc.Publish_date__c != null ? rc.Publish_date__c.format() : '');
            this.language = rc.Language__c;
            this.allowSharing = rc.Internal_Use__c;
        }
    }
    
    /**
     * Column Wrapper classes 
     */
    global class ColumnWrapper {
        public Boolean isSelected { get; set; }
        public String label { get; set; }
        public String forObject { get; set; }
        public String name { get; set; }
        public Integer order { get; set; }
        public User_Mapping__c userMapping { get; set; }
        
        global ColumnWrapper(User_Mapping__c um) {
            this.isSelected = um.Visible__c;
            this.name = um.Field_API_Name__c;
            this.forObject = um.Default_Value__c;
            this.label = um.Label__c;
            this.order = (Integer)um.Order__c;
            this.userMapping = um;
        }
        
        global ColumnWrapper(Boolean isSelected, String name, String forObject, String label, User_Mapping__c um, Integer orderval) {
            this.isSelected = isSelected;
            this.name = name;
            this.forObject = forObject;
            this.label = label;
            this.order = orderval;
            this.userMapping = um;
        }

        global ColumnWrapper(Boolean isSelected, String name, String forObject, String label, User_Mapping__c um) {
            this.isSelected = isSelected;
            this.name = name;
            this.forObject = forObject;
            this.label = label;
            this.userMapping = um;
        }
    }
    
    /**
     * method to get the map of selected columns for the current user
     */
    @RemoteAction
    global static String getColumnWrapperMap() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Map<String, List<ColumnWrapper>> colWrapperMap = new Map<String, List<ColumnWrapper>>();
        colWrapperMap.put('Account', new List<ColumnWrapper>());
        colWrapperMap.put('Contact', new List<ColumnWrapper>());
        colWrapperMap.put('Content', new List<ColumnWrapper>());
        // changes for #786 - moved query to w/o sharing
        List<User_Mapping__c> userMappingList = WithoutSharingHelperController.getUserMappingForColumnSelector();
        
        if (userMappingList != null && userMappingList.size() > 0) {
            
            for (User_Mapping__c um : userMappingList) {
                colWrapperMap.get(um.Default_Value__c).add(new ColumnWrapper(um));
            }
        } else {
            colWrapperMap.get('Account').add(new ColumnWrapper(false, 'AccountName', 'Account', System.Label.Account_Name, new User_Mapping__c(), 1));
            colWrapperMap.get('Account').add(new ColumnWrapper(false, 'Notice', 'Account', System.Label.Notice, new User_Mapping__c(), 2));
            colWrapperMap.get('Account').add(new ColumnWrapper(false, 'About', 'Account', System.Label.About, new User_Mapping__c(), 3));
            
            //  REF-1947
            if(cs.Show_Related_Ref_Content_in_RefSearch__c) {
                colWrapperMap.get('Account').add(new ColumnWrapper(false, 'ReferenceContent', 'Account', System.Label.Reference_Content, new User_Mapping__c(), 4));
            }
            colWrapperMap.get('Account').add(new ColumnWrapper(false, 'Tags', 'Account', System.Label.Tags, new User_Mapping__c(), 5));
            colWrapperMap.get('Account').add(new ColumnWrapper(false, 'Owner', 'Account', System.Label.Owner, new User_Mapping__c(), 6));
            
            colWrapperMap.get('Contact').add(new ColumnWrapper(false, 'ContactName', 'Contact', System.Label.Contact_Name, new User_Mapping__c(), 11));
            colWrapperMap.get('Contact').add(new ColumnWrapper(false, 'AccountName', 'Contact', System.Label.Account_Name, new User_Mapping__c(), 12));
            colWrapperMap.get('Contact').add(new ColumnWrapper(false, 'Notice', 'Contact', System.Label.Notice, new User_Mapping__c(), 13));
            colWrapperMap.get('Contact').add(new ColumnWrapper(false, 'About', 'Contact', System.Label.About, new User_Mapping__c(), 14));
            colWrapperMap.get('Contact').add(new ColumnWrapper(false, 'Tags', 'Contact', System.Label.Tags, new User_Mapping__c(), 15));
            colWrapperMap.get('Contact').add(new ColumnWrapper(false, 'Owner', 'Contact', System.Label.Owner, new User_Mapping__c(), 16));
            
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Featured', 'Content', 'Featured', new User_Mapping__c(), 21));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Share', 'Content', System.Label.Share, new User_Mapping__c(), 22));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Icon', 'Content', 'Icon', new User_Mapping__c(), 23));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Title', 'Content', System.Label.Title, new User_Mapping__c(), 24));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Type', 'Content', System.Label.Type, new User_Mapping__c(), 25));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Tags', 'Content', System.Label.Tags, new User_Mapping__c(), 26));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Account', 'Content', System.Label.Account, new User_Mapping__c(), 27));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'PublishDate', 'Content', System.Label.Publish_Date, new User_Mapping__c(), 28));
            colWrapperMap.get('Content').add(new ColumnWrapper(false, 'Language', 'Content', System.Label.Language, new User_Mapping__c(), 29));        
        }
        return JSON.serialize(colWrapperMap);
    }
    
    /**
     * method to get stage filter Id 
     * author : Gaurav Saini (3 Feb, 2017)
     */
    @RemoteAction
    global static String getStageFilterId() {
        String stageFilterId = '';
        // changes for #786 - moved query to w/o sharing
        List<Attribute__c> attList = WithoutSharingHelperController.getStageAttribute();
        
        if (attList != null && attList.size() > 0) {
            
            if (attList[0].Attributes__r != null && attList[0].Attributes__r.size() > 0) {
                // changes for #786 - moved query to w/o sharing
                List<Attributes_Labels__c> attLabelList = WithoutSharingHelperController.getStageFilterId(attList[0].Attributes__r[0].Id);
                
                if (attLabelList != null && attLabelList.size() > 0) {
                    stageFilterId = attLabelList[0].Label__c;
                }
            } 
        }
        return stageFilterId;
    }
    
    /**
     * method to get filter to attributes map for pre filter search 
     * author: Gaurav Saini (30 Jan, 2017)
     */
    @RemoteAction
    global static String getPreFilterResults(String opportunityId, Boolean showRefContent) {
        // map to store the filter id with the corresponding attribute ids which will be applied on page load
        Map<String, List<AttributesLabelWrapper>> filterAttributesMap = new Map<String, List<AttributesLabelWrapper>>();
        // list of filter ids which are associated with pre filter search
        Set<String> labelIds = new Set<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Map<String, Schema.SObjectField> fieldMapOpp = Schema.sObjectType.Opportunity.fields.getMap();
        Map<String, Schema.SObjectField> oppProductField_map = Schema.sObjectType.OpportunityLineItem.fields.getMap();
        String stageFilterId = '';
        String stageErrorMessage = '';
        
        // getting the opportunity object using dynamic SOQL query from the describe result field map
        if (opportunityId != null && opportunityId != '') {
            String theQueryOpp = 'SELECT Id, AccountId';
            
            for (String fieldName : fieldMapOpp.keyset()) {
                Schema.DescribeFieldResult fieldDesc = fieldMapOpp.get(fieldName).getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    theQueryOpp += ', ' + theName;
                }
            }
            theQueryOpp += ', (SELECT PricebookEntry.Product2Id ';
            
            for (String fieldName : oppProductField_map.keyset()) {
                Schema.DescribeFieldResult fieldDesc = oppProductField_map.get(fieldName).getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    theQueryOpp += ', ' + theName;
                }
            }
            theQueryOpp += ' FROM OpportunityLineItems) FROM Opportunity WHERE Id = :opportunityId';
            // changes for #786 - moved query to w/o sharing
            oppList = WithoutSharingHelperController.getOppForPreFilter(theQueryOpp, opportunityId);
            stageErrorMessage = checkForMinimumSalesStage(cs.Minimum_Sales_Stage__c != null ? cs.Minimum_Sales_Stage__c : '',
                                            oppList != null && oppList.size() > 0 ? oppList : new List<Opportunity>());
        }
        
        // changes for #786 - moved query to w/o sharing
        for (Data_Mapping__c dm : WithoutSharingHelperController.getDataMappingsForPreFilter()) {
            
            if (dm.Field_API_Name__c != null) {
                labelIds.add(dm.Field_API_Name__c);
            }
        }
       
        Map<String, Set<String>> selectedLabelMap = new Map<String, Set<String>>();
        
        if (oppList.size() > 0 && oppList[0].AccountId != null) {
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
            String theQuery = 'SELECT Id, Name';
            
            for (Schema.SObjectField s : fldObjMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if ((fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST)
                            && fieldDesc.getName() != 'BillingGeocodeAccuracy' && fieldDesc.getName() != 'ShippingGeocodeAccuracy') {
                    String theName = fieldDesc.getName();
                    theQuery += ', ' + theName;
                }
            }
            theQuery += ' FROM Account WHERE Id = \'' + oppList[0].AccountId + '\' LIMIT 1';
            Account account = new Account();
            List<Account> accounts = WithoutSharingHelperController.getAccountUsingDynamicSOQL(theQuery);
            
            if (accounts.size() > 0) {
                account = accounts[0];
            }
            Set<String> attMappingsAccount = new Set<String>();
            Map<String, String> accountFieldValues = new Map<String, String>();
            Map<String, String> oppFieldValues = new Map<String, String>();
            Set<String> oppoProducts = new Set<String>();
            Map<String, Set<String>> oppProductsPicklistFieldValues = new Map<String, Set<String>>();
            Map<String, String> oppProductFieldLabel = new Map<String, String>();
            List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
            
            for (OpportunityLineItem oppLineItem : oppList[0].OpportunityLineItems) {
                oppoProducts.add(oppLineItem.PricebookEntry.Product2Id);
                oppLineItems.add(oppLineItem);
            }
            
            // changes for #786 - moved query to w/o sharing
            for (Attribute_Mapping__c attMapping : WithoutSharingHelperController.getAccAndOppAttMappings()) {
                
                if (!attMapping.Is_Related_Mapping__c) {
                    
                    if (attMapping.Object__c == ConstantsController.ACCOUNT) {
                        attMappingsAccount.add(attMapping.Id);
                        
                        if (fldObjMap.containsKey(attMapping.Field_Api_Name__c) && account.get(attMapping.Field_Api_Name__c) != null) {
                            accountFieldValues.put(attMapping.Attribute_Name__c, String.valueOf(account.get(attMapping.Field_Api_Name__c)));
                        }
                    } else if ((attMapping.Field_Api_Name__c == 'StageName' && cs.Apply_Opportunity_Stage_Filter__c 
                                && showRefContent && attMapping.Object__c == ConstantsController.OPPORTUNITY) ||
                            (attMapping.Field_Api_Name__c != 'StageName' && cs.Include_Opp_Attributes_in_RefSearch__c &&
                             attMapping.Object__c == ConstantsController.OPPORTUNITY)) {
                        attMappingsAccount.add(attMapping.Id);
                        
                        if (fieldMapOpp.containsKey(attMapping.Field_Api_Name__c) && oppList[0].get(attMapping.Field_Api_Name__c) != null) {
                            oppFieldValues.put(attMapping.Attribute_Name__c, String.valueOf(oppList[0].get(attMapping.Field_Api_Name__c)));
                        }
                    }
                } else if (attMapping.Object__c == ConstantsController.OPPORTUNITY && attMapping.Related_Object__c == 'OpportunityLineItem') {
                    attMappingsAccount.add(attMapping.Id);
                    
                    if (oppProductField_map.containsKey(attMapping.Field_Api_Name__c)) {
                        oppProductFieldLabel.put(attMapping.Field_Api_Name__c, attMapping.Attribute_Name__c);
                        oppProductsPicklistFieldValues.put(attMapping.Attribute_Name__c, new Set<String>());
                    }
                }
            }
            
            for (OpportunityLineItem oppLineItem : oppLineItems) {
                
                for (String oppProfield : oppProductFieldLabel.keySet()) {
                    
                    if (oppLineItem.get(oppProfield) != null) {
                        
                        if (String.valueOf(oppLineItem.get(oppProfield)).contains(';')) {
                            
                            for (String value : String.valueOf(oppLineItem.get(oppProfield)).split(';')) {
                                oppProductsPicklistFieldValues.get(oppProductFieldLabel.get(oppProfield)).add(value.trim());
                            }
                        } else {
                            oppProductsPicklistFieldValues.get(oppProductFieldLabel.get(oppProfield)).add(String.valueOf(oppLineItem.get(oppProfield)));
                        }
                    }
                }
            }
            
            if (attMappingsAccount != null && attMappingsAccount.size() > 0) {
                // changes for #786 - moved query to w/o sharing
                List<Attribute__c> rootLevelAttributes = WithoutSharingHelperController.getRootLevelAttributes(attMappingsAccount);
                Map<String, String> attributeLabelMap = new Map<String, String>();
                Set<Id> attIds = new Set<Id>();
                
                for (Attribute__c root : rootLevelAttributes) {
                    
                    for (Attribute__c att : root.Attributes__r) {
                        attIds.add(att.Id);
                        //break;
                    }
                }
                
                // changes for #786 - moved query to w/o sharing
                for (Attributes_Labels__c attLabel : WithoutSharingHelperController.getAttributeLable(attIds)) {
                    
                    if (!attributeLabelMap.containsKey(attLabel.Attribute__r.Parent__c)) {
                        attributeLabelMap.put(attLabel.Attribute__r.Parent__c, attLabel.Label__c);
                    }
                }
                
                for (Attribute__c root : rootLevelAttributes) {
                    
                    if (labelIds.contains(AttributeLabelMap.get(root.Id)) && accountFieldValues.containsKey(root.Name)
                            && root.Attribute_Mapping__r.Object__c == ConstantsController.ACCOUNT) {
                        
                        if (!selectedLabelMap.containsKey(AttributeLabelMap.get(root.Id))) {
                            selectedLabelMap.put(AttributeLabelMap.get(root.Id), new Set<String>());
                        }
                        
                        for (Attribute__c att : root.Attributes__r) {
                            
                            if (accountFieldValues.get(root.Name) == att.Name) {
                                selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(att.Id);
                                break;
                            } else if (accountFieldValues.get(root.Name).contains(';')) {
                                
                                for (String value : accountFieldValues.get(root.Name).split(';')) {
                                    
                                    if (value.trim() == att.Name) {
                                        selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(att.Id);
                                    }
                                }
                            }
                        }
                    } else if (labelIds.contains(AttributeLabelMap.get(root.Id)) && root.Attribute_Mapping__r.Object__c == ConstantsController.OPPORTUNITY 
                            && !root.Attribute_Mapping__r.Is_Related_Mapping__c) {
                        
                        if (root.Attribute_Mapping__r.Field_Api_Name__c == 'StageName') {
                            //accountSearch.stageLabelId = AttributeLabelMap.get(root.Id);
                            stageFilterId = (String)AttributeLabelMap.get(root.Id);
                        }
                        
                        if (!selectedLabelMap.containsKey(AttributeLabelMap.get(root.Id))) {
                            selectedLabelMap.put(AttributeLabelMap.get(root.Id), new Set<String>());
                        }
                        
                        for (Attribute__c att : root.Attributes__r) {
                            
                            if (oppFieldValues.get(root.Name) != null) {
                                
                                if (oppFieldValues.get(root.Name) == att.Name) {
                                    selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(att.Id);
                                    break;
                                } else if (oppFieldValues.get(root.Name).contains(';')) {
                                    
                                    for (String value : oppFieldValues.get(root.Name).split(';')) {
                                        
                                        if (value.trim() == att.Name) {
                                            selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(att.Id);
                                        }
                                    }
                                }
                            }
                        }
                    } else if (labelIds.contains(AttributeLabelMap.get(root.Id)) && root.Attribute_Mapping__r.Object__c == ConstantsController.OPPORTUNITY 
                            && root.Attribute_Mapping__r.Is_Related_Mapping__c) {
                        
                        if (!selectedLabelMap.containsKey(AttributeLabelMap.get(root.Id))) {
                            selectedLabelMap.put(AttributeLabelMap.get(root.Id), new Set<String>());
                        }
                        
                        if (root.Attribute_Mapping__r.Field_Api_Name__c == 'Product2') {
                            
                            for (Attribute__c att : root.Attributes__r) {
                                
                                if (oppoProducts.contains(att.Product_ID__c)) {
                                    selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(att.Id);
                                }
                            }
                        } else {
                            
                            for (Attribute__c att : root.Attributes__r) {
                                
                                if (oppProductsPicklistFieldValues.containsKey(root.Name) && oppProductsPicklistFieldValues.get(root.Name) != null 
                                        && oppProductsPicklistFieldValues.get(root.Name).contains(att.Name)) {
                                    selectedLabelMap.get(AttributeLabelMap.get(root.Id)).add(att.Id);
                                }
                            }
                        }
                    }
                }
            }
        }
        Set<String> selectedAttributesIds = new Set<String>();
        Map<String, List<AttributesLabelWrapper>> resultMap = new Map<String, List<AttributesLabelWrapper>>();
        
        for (String filterId : selectedLabelMap.keySet()) {
            selectedAttributesIds.addAll(selectedLabelMap.get(filterId));
        }
        // changes for #786 - moved query to w/o sharing
        List<Attributes_Labels__c> tempAttLabelList = WithoutSharingHelperController.getAttributeLabels1(selectedLabelMap.keySet());
        
        for (Attributes_Labels__c attLabel : tempAttLabelList) {
            
            if (!resultMap.containsKey(attLabel.Label__c)) {
                resultMap.put(attLabel.Label__c, new List<AttributesLabelWrapper>());
            }
            resultMap.get(attLabel.Label__c).add(new AttributesLabelWrapper(attLabel));
            
            if (selectedAttributesIds.contains(attLabel.Attribute__c)) {
                resultMap.get(attLabel.Label__c).get(resultMap.get(attLabel.Label__c).size() - 1).isSelected = true;
            }
        } 
        return JSON.serialize(resultMap) + '@@' + stageFilterId + '@@' + stageErrorMessage;
    }

    /**
    *   REF-1608
    *   Methed will return list of AccountRBI whose "Ignore Contact Limit Reached" is checked and Its Limit is also reached.
    *   Rajneesh (sept, 28,2018)
    **/
    @RemoteAction
    global static string accountRBIWithLimitCheck(String accountIds) {
        
        Set<Id> accountIdSet = (Set<Id>)JSON.deserialize(accountIds, Set<Id>.class);
        List<Reference_Basic_Information__c> accountRBI = WithoutSharingHelperController.getAccountRBIsForRefSearch(accountIdSet);
        String accRBILimitREached = '';

        for(Reference_Basic_Information__c rbiRecord : accountRBI) {
            
            if(rbiRecord.Account_Level_RUL__c && rbiRecord.RUL_Limit_Reached__c) {
                accRBILimitREached += rbiRecord.Account__c +', ';
            }
        }
        return accRBILimitREached;
    }

    public static String checkForMinimumSalesStage(String minStageValue, List<Opportunity> oppList) {
        String resultMessage = '';
        
        if (minStageValue != '' && oppList != null && oppList.size() > 0) {
            List<Schema.PicklistEntry> oppStagePicklistValues = CRUDAndFLSCheckController.sObjectsMap.get('Opportunity').getDescribe().fields.getMap().get('StageName').getDescribe().getPickListValues();
            Integer minimumStagePosition = 0;
            Integer opporunityStagePosition = 0;
            Integer currentPosition = 0;
            
            for (Schema.PicklistEntry ple : oppStagePicklistValues) {
                
                if (minStageValue == ple.getValue()) {
                    minimumStagePosition = currentPosition;
                }
                
                if (oppList[0].StageName == ple.getValue()) {
                    opporunityStagePosition = currentPosition;
                }
                ++currentPosition;
            }
            
            if (opporunityStagePosition < minimumStagePosition) {
                resultMessage = label.MinimumSalesStage.replace('@@@', minStageValue);
            }
        }
        return resultMessage;
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isOnPageLoad, String action) {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        Boolean isDeletePermission = false;
        Boolean isUpsertPermission = false;
        
        if (isOnPageLoad || action == 'CreateCollection') {             
            fieldMap.put(UtilityController.appNamespace() + 'Content_Collection__c', new Set<String> { 
                                                    UtilityController.appNamespace() + 'Collection__c',
                                                    UtilityController.appNamespace() + 'Active__c'}); 
            fieldMap.put(UtilityController.appNamespace() + 'Related_Reference_Content__c', new Set<String> { 
                                                    UtilityController.appNamespace() + 'Content_Collection__c',
                                                    UtilityController.appNamespace() + 'Reference_Content__c'}); 
            isDeletePermission = true;
        }
        
        if (isOnPageLoad || action == 'Save') {                                     
            fieldMap.put(UtilityController.appNamespace() + 'User_Mapping__c', new Set<String> { 
                                                    UtilityController.appNamespace() + 'Order__c',
                                                    UtilityController.appNamespace() + 'Visible__c',
                                                    UtilityController.appNamespace() + 'Field_API_Name__c',
                                                    UtilityController.appNamespace() + 'User__c',
                                                    UtilityController.appNamespace() + 'Label__c',
                                                    UtilityController.appNamespace() + 'Process__c'}); 
            isDeletePermission = CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'User_Mapping__c'});
        } 
        isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);     
        return (isUpsertPermission && isDeletePermission); 
    }
  
    /**
     * Wrapper class
     */
    global class AttributesLabelWrapper {
        public Attributes_Labels__c attributeLabel { get; set; }
        public Boolean isSelected { get; set; }
        public Boolean show { get; set; }
        public String attId { get; set; }
        public String attName { get; set; }
        public String filterNo { get; set; }
        //REF-2366
        public String label { get; set; }
        public String filterId { get; set; }
        
        global AttributesLabelWrapper(Attributes_Labels__c attributeLabel) {
            this.isSelected = false;
            show = true;
            this.attId = attributeLabel.Attribute__r.Id;
            this.attributeLabel = attributeLabel;
            this.attName = attributeLabel.Attribute__r.Name;
            this.filterNo = String.valueOf(attributeLabel.Label__r.Filter_no__c);
            //REF-2366
            this.label = attributeLabel.Attribute__r.Name;
            this.filterId = attributeLabel.Label__c;
        }
    }
    
    global class FilterLogicWrapper {
        public String filterId { get; set; }
        public String filterName { get; set; }
        public String operatorSelected { get; set; }
        
        global FilterLogicWrapper(String filterId, String name, String opselected) {
            this.filterName = name;
            this.filterId = filterId;
            this.operatorSelected = opselected;
        }
    }
    
    /**
     * Wrapper class
     */
    global class ReferenceabilityTypeWrapper {
        public Referenceability_Type__c refType { get; set; }
        public Boolean isSelected { get; set; }
        public Integer indexValue { get; set; }
        
        global ReferenceabilityTypeWrapper(Referenceability_Type__c refType) {
            this.isSelected = false;
            this.refType = refType;
        }
    }
    
    /**
     * Wrapper Class Content Types
     */
    global class ContentTypeWrapper {
        public String contentTypeName { get; set; }
        public Boolean isSelected { get; set; }
        
        global ContentTypeWrapper(String contentTypeName) {
            this.isSelected = false;
            this.contentTypeName = contentTypeName;
        }
    }
    
    /**
     * Wrapper Class Content Languages
     */
    global class ContentLanguageWrapper {
        public String contentLanguageName { get; set; }
        public Boolean isSelected { get; set; }
        
        global ContentLanguageWrapper(String contentLanguageName) {
            this.isSelected = false;
            this.contentLanguageName = contentLanguageName;
        }
    }

    /**
     * Wrapper Class Dependent Filters
     */
    public class DependentFilterWrapper {
        public String cFId { get; set; }
        public Map<String,Set<String>> attribute { get; set; }
        
        public DependentFilterWrapper(String cFId,Map<String,Set<String>> attribute) {
            this.cFId = cFId;
            this.attribute = attribute;
        }
    }

    /**
     * Wrapper Classes
     */
    global class CustomContentTypeWrapper {
        String label { get; set; }
        String apiName { get; set; }
        String value { get; set; }
        String type { get; set; }

        global CustomContentTypeWrapper (String apiName, String label, Object value, String type) {
            this.apiName = apiName;
            this.label = label;
            this.type = type;
            this.value = String.valueOf(value);
        }
    }
    
    /**
     * Wrapper Class
     */
    global class RelatedMappingWrapper {
        public String label { get; set; }
        public String recId { get; set; }
        public Boolean isSelected { get; set; }
        public String filterId { get; set; }
        
        global RelatedMappingWrapper(String label, String recId) {
            this.label = label;
            this.recId = recId;
            this.isSelected = false;
        }
        global RelatedMappingWrapper(String label, String recId, String filterId) {
            this.label = label;
            this.recId = recId;
            this.isSelected = false;
            this.filterId = filterId;
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

    @RemoteAction
    public static String rollUpAttribute(String recordInfo, Boolean isAccount, String accountId) {        
        String attributes = '';

        if(recordInfo != '' && recordInfo != null && isAccount){
            attributes = UtilityController.rollUpAttributeMappingRBI(Id.valueOf(recordInfo), true, null);
        } else if(recordInfo != '' && recordInfo != null && !isAccount) {
            attributes = UtilityController.rollUpAttributeMappingRBI(Id.valueOf(recordInfo), false, Id.valueOf(accountId));
        }
        return attributes.removeEnd(', ');
    }
    
    /*
        REF-2181
        Account Information rollup to Reference Content  
        Rajneesh (March 19, 2019)
    */
	@RemoteAction
    public static String inheritAccountAttribute(String recordId) {
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        String attributes = '';
        String contentAttribute = '';
        List<Reference_Content__c> refConRec = [SELECT Id, Name, Title__c, Attributes__c, Account__c FROM Reference_Content__c Where Id =: recordId];
        
        if(refConRec.size() > 0) {
            contentAttribute = refConRec[0].Attributes__c;
        }

        if(refConRec.size() > 0) {

            for(Account_Reference_Content__c arc : [SELECT Id, Account__c FROM Account_Reference_Content__c WHERE Reference_Content__c =: recordId]) {
                accountIdSet.add(arc.Account__c);
            }
          
            for(Reference_Basic_Information__c accRBI : [SELECT Id, Account__c FROM Reference_Basic_Information__c WHERE Account__c =: accountIdSet AND Contact__c = null]) {
                accIdSet.add(accRBI.Account__c);
            } 
          
            //	query to get Account's parent information dynamically..
            String queryString = 'SELECT Id, ';
            Set<String> fieldSet = new Set<String>();	
            List<Attribute_Mapping__c> attriMappingList = [SELECT Id, Field_Api_Name__c, RelationShip_Name__c, Object__c, Mapping_Type__c, Auto_populate__c 
            FROM Attribute_Mapping__c WHERE (Object__c = : ConstantsController.ACCOUNT OR Object__c = : ConstantsController.REFERENCE_PROFILE) 
            AND Mapping_Type__c != : ConstantsController.CHILD_OBJECT];
            Set<String> amofAccount = new Set<String>();
             
            for(Attribute_Mapping__c amRec : attriMappingList) {
              
                if(amRec.Object__c == ConstantsController.ACCOUNT && amRec.Mapping_Type__c == null && amRec.Auto_populate__c) {
                    amofAccount.add(amRec.Field_Api_Name__c);
                }
            }                        
                           
            // Iterate over Attribute Mapping object to get Account parents information
            for(Attribute_Mapping__c am : attriMappingList) {

                if(am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && !am.RelationShip_Name__c.contains('__c')) {
                    queryString += am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c + ', ';
                    fieldSet.add(am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c);
                } else if(am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && am.RelationShip_Name__c.contains('__c')){
                    queryString += am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c + ', ';
                    fieldSet.add(am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c);
                } else if(am.Object__c == ConstantsController.REFERENCE_PROFILE && am.RelationShip_Name__c != null && am.RelationShip_Name__c == 'Account__c' && !amofAccount.contains(am.Field_Api_Name__c)) {
                    queryString += am.Field_Api_Name__c + ', ';
                    fieldSet.add(am.Field_Api_Name__c);
                }
            }
            queryString = queryString.removeEnd(', ') + ' FROM Account WHERE Id =: accIdSet';
           
            for(sObject acc : database.query(queryString)) {                  
                    
                for(String fldName : fieldSet) {

                    if(!fldName.contains('.') && acc.get(fldName) != null) {
                        attributes += acc.get(fldName) +', ';
                        
                    } else if(fldName.contains('.') && (fldName.countMatches('.') == 1) && acc.getSObject(fldName.substringBefore('.')) != null && acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) != null 
                        && acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) != '') {
                        attributes += acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) +', ';  
                    } 
                }
            }
        }

        if(contentAttribute != '' && attributes != '') {
            contentAttribute = contentAttribute + ', '+ attributes.removeEnd(', ');
        } else if(contentAttribute == '' && attributes != '') {
            contentAttribute = attributes.removeEnd(', ');
        }
		return contentAttribute;
    }
    
    /**
     * Method to get filter attribute by name
     * REF-2366
     */
    @RemoteAction
    global static String searchFilterAttributes(String filterId, String searchValue) {
        String tempSearchVal = searchValue.replace('*', '%') + '%';
        tempSearchVal = String.escapeSingleQuotes(tempSearchVal);
        List<AttributesLabelWrapper> lstAttributeLabelWrapper = new List<AttributesLabelWrapper>();
        List<Label__c> listOfFilters = [SELECT Id, (SELECT Name, Label__c, Id, Label__r.Name, Label__r.Filter_no__c, Attribute__c, Attribute__r.Name
                                                    FROM Attributes_Labels__r 
                                                    WHERE Attribute__c != null 
                                                    AND  Attribute__r.Name LIKE :tempSearchVal 
                                                    ORDER BY Attribute__r.Name 
                                                    LIMIT 201) 
                                        FROM Label__c 
                                        WHERE Id =:filterId
                                        LIMIT :limits.getLimitQueryRows()];
        
        if (listOfFilters.size() > 0) {
            
            for (Label__c label : listOfFilters) {
                
                if (label.Attributes_Labels__r.size() > 0) {
                    
                    for (Attributes_Labels__c al : label.Attributes_Labels__r) {
                        lstAttributeLabelWrapper.add(new AttributesLabelWrapper(al));
                    } 
                }
            }
        }
        return JSON.serialize(lstAttributeLabelWrapper);
    }
}