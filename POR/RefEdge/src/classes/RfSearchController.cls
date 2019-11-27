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
 * Description: Class to show Accounts, Contacts and Contents and provide filteing on these records.
 * Modified By: Rajesh @JUNE 13 2017- #346
 */
public with sharing class RfSearchController extends RefEdgeEditionFeatures { 
    /**
     * Constants
     */
    private static String SPECIFIED_REQUEST_MESSAGE = 'I would like to use an account as a reference for which you are the owner.  ';
    private static String APPROVE_DECLINE_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContacts.getURL() + '?id=';
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    private static String REFERENCE_REQUEST_TASK_SUBJECT = 'Reference Use Approval Request';
    
    /**
     * Properties and variables
     */
    // added for #1135 - Gaurav Saini (2 Dec, 2017)
    public String exportObjectName { get; set; }
    public String newLine { get; set; }
    public Boolean isExportClicked { get; set; }
    // added for #835 - flag to control visibility of View details button in content details popup
    public Boolean isViewDetailsUpdateable {
        get {
            
            if (isViewDetailsUpdateable == null) {
                isViewDetailsUpdateable = Schema.sObjectType.Reference_Content__c.fields.getMap().get('Ref_Content_View_Details_Clicks__c').getDescribe().isUpdateable();
            }
            return isViewDetailsUpdateable;
        }
        set;
    }
    public String inputTextValue { get; set; }
    public String tempTextValue { get; set; }
    public List<String> selectedAccIdsSet {
        get {
            if (selectedIds != null && selectedIds != '') {
                return selectedIds.split(',');
            } else {
                return new List<String>();
            }
        }
    }
    public String helpOverlay { get; set; }
    public String helpOverlayInvitation { get; set; }
    public String selectedIds { get; set; }
    public Boolean isCRMContentUser { get; set; }
    //Instance of AttributeWrapper Class
    public AttributeWrapper attributeWrapper { get; set; }
    //Instance of ReferenceabilityWrapper Class
    public ReferenceabilityWrapper referenceabilityWrapper { get; set; }
    //Instance of AccountSearchController Class
    public AccountSearchController accountSearch { get; set; }
    //Instance of ContactSearchController Class
    public ContactSearchController contactSearch { get; set; }
    //Instance of ContentSearchController Class
    public ContentSearchController contentSearch { get; set; }
    //Instance of AssociatedRefContAccountsController Class
    public AssociatedRefContAccountsController assAccounts { get; set; }
    //Boolean variable to store whether the Account Block should display or not
    public Boolean showAccount { get; set; }
    //Boolean variable to store whether the contact Block should display or not
    public Boolean showContact { get; set; }
    //Boolean variable to store whether the Ref Content Block should display or not
    public Boolean showRefContent { get; set; }
    public String selectedId { get; set; }
    public Reference_Request__c request { get; set; }
    public Boolean refMatch { get; set; }
    public String selectedUnsepReq { get; set; }
    public String selectedCon { get; set; }
    public String selectedacc { get; set; }
    public String newAccountRequestId { get; set; }
    public String updatableReq { get; set; }
    public String rep2repId { get; set; }
    public RefSearch_Usage_Track__c trackRecord { get; set; }
    public Map<String, String> refReqContactMap { get; set; }
    public String updateReqId { get; set; }
    public String statusValue { get; set; }
    //hit list variables
    public Boolean isAccount { get; set; }
    public Boolean isContact { get; set; }
    public String hitAccount { get; set; }
    public String hitContact { get; set; }
    public Boolean showHitContacts { get; set; }
    public String changeField { get; set; }
    public String minimumStageError { get; set; }
    public Boolean showFeaturedContentIcons { get; set; }
    public List<String> filterLogicsList { get; set; }
    public Map<String, FilterLogicWrapper> filterLogics { get; set; }
    public String betweenFilterLogics { get; set; }
    public List<SelectOption> logics { get; set; }
    public List<SelectOption> logicsWithName { get; set; }
    
    public Attachment transcript { get; set; }
    public String interviewTopicId { get; set; }
    public String transcriptFileType { get; set; }
    public String downloadContentUrl { get; set; }
    public String SECUREURL { get; set; }
    public InvitationController invitationcontroller { get; set; }
    public List<Data_Mapping__c> filterList { get; set; }
    public Boolean isShowMoreLink { get; set; }
    public Map<String, Attribute_Mapping__c> attributeResults { get; set; }
    public Set<String> actionsSet ;
    public Boolean preFilter { get; set; }
    private Boolean isPreFilterApplied = false;
    //for #655 
    public Boolean preFilterForRedirection { get; set; }
    public Boolean isFilteredContent { get; set; }
    public String LabelIds { get; set; }
    public SearchRelatedMappingRecorsController relatedMappingController { get; set; }
    public String collectionName { get; set; }
    public Boolean isCollectionCreateable { get; set; }
    public Boolean isInlineEditingDisabled { get; set; }
    public Boolean isEdit { get; set; }
    public String EditRequestId { get; set; }
    public String activeTab { get; set; }
    public List<String> sectionOrder { get; set; }
    public Boolean showExportButton { get; set; }
    public Boolean showContactBlock { get; set; }
    public Set<String> attributeMapInheritableAccountIds, attributeMapInheritableContentIds, attributeMapInheritableContactIds;
    private Opportunity oppObj;
    private Unspecified_Request__c unspecReq; 
    private Reference_Request_Account__c accountReq;
    private Set<Id> refTypeIds;
    private Set<Id> updateReqList;
    private Boolean isFilterReload;
    public String forAccount { get; set; }
    public String forContent { get; set; }
    private Custom_Settings__c cs;
    public Boolean showOwner { get; set; }
    private List<AccountWrapper> accounts;
    private List<ContactWrapper> contacts;
    private List<ConetntWrapper> contents;
    private String caseId = '';
    public String leadId { get; set; }
    private String pageNameRedirection = '';
    private Map<String, Schema.SObjectField> fieldMapOpp;
    private Map<String, Schema.SObjectField> oppProductField_map;
    public Boolean isShraredContact { get; set; }
    public Boolean isAllowRelatedContent { get; set; }

    //re #362 - Custom Setting decide default value for filters (Any or All)
    public String searchFilterDefault { get; set; }
    public String opportunityId { get; set; }
   // public boolean checkVal = true;
    private String selectedAccoutsIDs = '';
    private Map<String, String> noteMap = new Map<String, String>();
    private Boolean ismakeAccountRPMAccessed = false;
    
    public Boolean isContentCollection { get; set; }
    public String selectedCollection { get; set; }
    public Boolean isBasicSearchViewSelected { get; set; }
    public Boolean manage2PeerError { get; set; }
    public Boolean showConfirmationSaveMessage { get; set; }
    public Boolean showPeer2ManagedMessage { get; set; }
    public Boolean writetoNote { get; set; }
    public String NoteValue { get; set; }
    public String subjectValue { get; set; }
    public Reference_Request_Account__c tempRRA { get; set; }
    public String errorAccountName { get; set; }
    public Boolean isSend { get; set; }
    //changes related to #864
    public Boolean fromLead { get; set; }
    public String selectedaccountReq { get; set; }
    public String STATUS_UPDATE_SUBJECT { get; set; }
    private String selectedContentCol;
    private Map<String, Referenceability_Type__c> mapReferenceType;
    private Boolean isAccountRenderFirst = true;
    private Map<String, FilterLogicWrapper> tempFilterLogicList; 
    public List<ConetntWrapper> accountContents  { get; set; }
    public Id selectedAccountId { get; set; }
    // Change related 1288
    public boolean showOveray { get; set; }
    public Boolean isUpdateRefSearchUsageCount { get; set; }
    private List<User_Mapping__c> userMappingList;
    public List<User_Mapping__c> userInvitaionMappingList;
    public Boolean showInviationOveray { get; set; }
    public String helpAssistant { get; set; }
    private String labelValue = '';
    private String labelInvitationValue = '';
    private Date lastActivity;
    private Date lastInvitationActivity;
    //REF-1975
    public String recordId { get; set; } 
    public Boolean isContactSec { get; set; }
    public Reference_Basic_Information__c  rbiRecord { get; set; }
    //  REF-2181
    public String contentAttribute { get; set; }
    public String contentTitle { get; set; }
        
    public Integer noOfSelectedAccount {
        get {
            
            if (selectedAccIdsSet != null && selectedAccIdsSet.size() > 0) {
                return selectedAccIdsSet.size();
            } else {
                return 0;
            }
        }
    }
    public Boolean isthisBasic {
        get {
            return isBasic;
        }
        set;
    }
    //getter for Period RUL Length
    public Decimal RULPeriodLength {
        get {
            
            if (RULPeriodLength == null) {
                RULPeriodLength = cs.RUL_Period__c;
            }
            return RULPeriodLength;
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
     
    //getter for numberOfRequestAccounts
    public Integer numberOfRequestAccounts {
        get {
            
            if (numberOfRequestAccounts == null) {
                numberOfRequestAccounts = Integer.valueOf(cs.Number_of_request_accounts__c);
            }
            return numberOfRequestAccounts;
        }
        set;
    }
    public List<Data_Mapping__c> basicFilterList {
        get {
            basicFilterList = new List<Data_Mapping__c>();
            
            if (filterList != null) {
                basicFilterList.addAll(filterList);
            }
            isShowMoreLink = false;
            
            for (Data_Mapping__c dm : basicFilterList) {
                
                if (dm.Field_API_Name__c == 'Referenceability') {
                    
                    if (referenceabilityWrapper.selectedReferenceabilityTypes.size() > 0) {
                        dm.Required__c = true;
                    } else {
                        dm.Required__c = false;
                    }
                } else if (dm.Field_API_Name__c == 'Content Language') {
                    
                    if (contentSearch.selectedContentLanguages.size() > 0) {
                        dm.Required__c = true;
                    } else {
                        dm.Required__c = false;
                    }
                } else if (dm.Field_API_Name__c == 'Content Types') {
                    
                    if (contentSearch.selectedContentTypes.size() > 0) {
                        dm.Required__c = true;
                    } else {
                        dm.Required__c = false;
                    }
                } else if (attributeWrapper.mapAttributesLabels != null && attributeWrapper.mapAttributesLabels.containsKey(dm.Field_API_Name__c)) {
                    
                    if (attributeWrapper.mapAttributesLabels.get(dm.Field_API_Name__c).size() > 0) {
                        dm.Required__c = true;
                    } else {
                        dm.Required__c = false;
                    }
                } else if (attributeResults != null && attributeResults.containsKey(dm.Field_API_Name__c)) {
                    
                    if (relatedMappingController.mappingSelectedValues.containsKey(attributeResults.get(dm.Field_API_Name__c).Id) 
                            && relatedMappingController.mappingSelectedValues.get(attributeResults.get(dm.Field_API_Name__c).Id).size() > 0) {
                        dm.Required__c = true;
                    } else {
                        dm.Required__c = false;
                    }
                }
            }
            
            for (Data_Mapping__c dm : basicFilterList) {
                
                if (!dm.Required__c && !dm.Visible__c) {
                    isShowMoreLink = true;
                    break;
                }
            }
            return basicFilterList;
        }
        set;
    }
    // added for REF-1341 - Gaurav Saini (4 Sep, 2018)
    private String selectedAccIdsParam { get; set; }
    
    //REF-1964
    public Boolean isRefHubMatch { get; set; } 
    public Boolean isSelectAllContacts { get; set; }
    public Map<String,ContactWrapper> mapContactIdContactWrapper = new Map<String,ContactWrapper>();
    public String selectedContactId {get; set;}
    public List<String> selectedContactIds {get; set;}
    public String preSelectedContactIds {get; set;}
    public String selectedUR {get; set;}
    //REF-2304
    public List<String> contactIdsToRemove { get; set; }
    //REF-2366
    public Boolean isFromSelectReferenceUseAttributes { get; set; }
    public String slectedAttributesFromSelectRefAttrString { get; set; }
    //REF-2645
    public Map<String,String> mapSelectReferenceUseAttributesVariables { get; set; }
    
    /**
     * Constructor
     */
    public RfSearchController() {
        reset();
        actionsSet = new Set<String>();
        //REF-2645
        mapSelectReferenceUseAttributesVariables = new Map<String,String>();
        //REF-2366
        isFromSelectReferenceUseAttributes = false;
        slectedAttributesFromSelectRefAttrString = '';
        
        if (ApexPages.currentPage().getParameters().get('fromSelectReferenceUseAttributes') != null && 
            ApexPages.currentPage().getParameters().get('fromSelectReferenceUseAttributes') == 'true' && 
            ApexPages.currentPage().getParameters().get('selectedLabelId') != null && 
            ApexPages.currentPage().getParameters().get('selectedLabelId') != '') {
            isFromSelectReferenceUseAttributes = true;
            attributeWrapper.selectedLabelId = ApexPages.currentPage().getParameters().get('selectedLabelId');
            //REF-2645
            mapSelectReferenceUseAttributesVariables.put('opportunityIdP', ApexPages.currentPage().getParameters().get('opportunityIdP'));
            mapSelectReferenceUseAttributesVariables.put('caseIdP', ApexPages.currentPage().getParameters().get('caseIdP'));
            mapSelectReferenceUseAttributesVariables.put('leadIdP', ApexPages.currentPage().getParameters().get('leadIdP'));
            mapSelectReferenceUseAttributesVariables.put('forAccountP', ApexPages.currentPage().getParameters().get('forAccountP'));
            mapSelectReferenceUseAttributesVariables.put('forContentP', ApexPages.currentPage().getParameters().get('forContentP'));
            mapSelectReferenceUseAttributesVariables.put('preFilterP', ApexPages.currentPage().getParameters().get('preFilterP'));
            mapSelectReferenceUseAttributesVariables.put('AccoutsIDsP', ApexPages.currentPage().getParameters().get('AccoutsIDsP'));
        }
        //REF-1964
        selectedUR = '';
        preSelectedContactIds = '';
        isSelectAllContacts = false;
        selectedContactIds = new List<String>();
        isRefHubMatch = false;
        selectedContactId = '';
        showExportButton = cs.Enable_Ref_Search_Export__c && hasPermissionOnEnableRefSearchExport();
        selectedAccIdsParam = ApexPages.currentPage().getParameters().get('selectedAccIdsParam') != null && ApexPages.currentPage().getParameters().get('selectedAccIdsParam') != ''
                                ? ApexPages.currentPage().getParameters().get('selectedAccIdsParam') : '';
        
        if (ApexPages.currentPage().getParameters().get('PreFilter') != null && ApexPages.currentPage().getParameters().get('PreFilter') != '' 
                && ApexPages.currentPage().getParameters().get('PreFilter') == 'true') {
            preFilter = true;
            preFilterForRedirection = true;
        }
        
        if (ApexPages.currentPage().getParameters().get('fromLead') != null) {
            fromLead = ApexPages.currentPage().getParameters().get('fromLead') == 'true' ? true : false;
        }
        
        if (ApexPages.currentPage().getParameters().get('isFilteredContent') != null && ApexPages.currentPage().getParameters().get('isFilteredContent') != '' 
                && ApexPages.currentPage().getParameters().get('isFilteredContent') == 'true') {
            isFilteredContent = true;
        }
        forAccount = ApexPages.currentPage().getParameters().get('forAccount');
        forContent = ApexPages.currentPage().getParameters().get('forContent');
        setFilters();
        String stageLabelId = '';
        String stageattId = '';
        List<Attribute__c> attributesList = [SELECT Attribute_Mapping__r.Field_Api_Name__c,
                                                (SELECT Id FROM Attributes__r LIMIT 1) 
                                                FROM Attribute__c
                                                WHERE Level__c = 0
                                                AND Attribute_Mapping__r.Field_Api_Name__c = 'StageName'
                                                AND Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY];
        
        if (attributesList.size() > 0) {
            
            for (Attribute__c root : attributesList) {
                
                for (Attribute__c att : root.Attributes__r) {
                    stageattId = att.Id;
                }
            }
            
            for (Attributes_Labels__c attLabel : [SELECT Label__c, Attribute__r.Parent__c
                                                    FROM Attributes_Labels__c
                                                    WHERE Attribute__c = :stageattId]) {
                stageLabelId = attLabel.Label__c;
                break;
            }
        }
        
        if (stageLabelId != null && stageLabelId != '') {
            accountSearch.stageLabelId = stageLabelId;
            contactSearch.stageLabelId = stageLabelId;
        }
        
        if (ApexPages.currentPage().getParameters().get('isRefMatch') == 'true' && isBasic == false) {
            setReqData();
            showHitContacts = true;
            refMatch = true;
            NoteValue = '';
            subjectValue = '';
            writetoNote = false;
            isPreFilterApplied = true;
            tempRRA = new Reference_Request_Account__c();
            sectionOrder = new List<String>();
            sectionOrder.add('contact');
            sectionOrder.add('account');
            isAccountRenderFirst = false;
            STATUS_UPDATE_SUBJECT = 'Reference Request Update';
            
            if (ApexPages.currentPage().getParameters().get('inlineeditingenable') != null && 
                        ApexPages.currentPage().getParameters().get('inlineeditingenable') == 'true') {
                isInlineEditingDisabled = true;
            } else if (ApexPages.currentPage().getParameters().get('inlineeditingenable') != null && 
                            ApexPages.currentPage().getParameters().get('inlineeditingenable') == 'false') {
                isInlineEditingDisabled = false;
            }
            
            if (ApexPages.currentPage().getParameters().get('activeTab') != null) {
                activeTab = ApexPages.currentPage().getParameters().get('activeTab');
            }
            
            //REF-1964    
            if (ApexPages.currentPage().getParameters().get('isRefHubMatch') != null &&
                ApexPages.currentPage().getParameters().get('isRefHubMatch') == 'true') {
                isRefHubMatch = true;
            }
            selectedUR = (ApexPages.currentPage().getParameters().get('selectedUR') == null ? '' : 
                          ApexPages.currentPage().getParameters().get('selectedUR'));
        } else {
            refMatch = false;
            //REF-1964
            isRefHubMatch = false;
            showContactBlock = cs.Show_Contacts_in_RefSearch__c;
            
            if (ApexPages.currentPage().getParameters().get('forAccount') == null
                        || ApexPages.currentPage().getParameters().get('forContent') == null) {
                showAccount = true;
                showContact = true;
                showRefContent = true;
                isPreFilterApplied = true;
                //checkPermissionsOnCollection();
            } else {
                showContact = false;
                
                if (ApexPages.currentPage().getParameters().get('forAccount') == 'false') {
                    
                    if (ApexPages.currentPage().getParameters().get('forContent') == 'false') {
                        showAccount = true;
                        showRefContent = true;
                        //checkPermissionsOnCollection();
                    } else {
                        showAccount = false;
                        showRefContent = true;
                        //checkPermissionsOnCollection();
                    }
                } else {
                    showAccount = true;
                    showRefContent = false;
                }
            }
            opportunityId = (ApexPages.currentPage().getParameters().get('opportunityId') == null ? '' : 
                            ApexPages.currentPage().getParameters().get('opportunityId'));
            String minimumStageValue = cs.Minimum_Sales_Stage__c;
            
            if (opportunityId != null && opportunityId != '') {
                fieldMapOpp = schema.SObjectType.Opportunity.fields.getMap();
                oppProductField_map = schema.SObjectType.OpportunityLineItem.fields.getMap();
                String theQueryOpp = 'SELECT Id, AccountId';
                
                for (String fieldName : fieldMapOpp.keyset()) {
                    Schema.DescribeFieldResult fieldDesc = fieldMapOpp.get(fieldName).getDescribe();
                    
                    if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                        String theName = fieldDesc.getName();
                        // Continue building your dynamic query String
                        theQueryOpp += ', ' + theName;
                    }
                }
                theQueryOpp += ', (SELECT PricebookEntry.Product2Id ';
                
                for (String fieldName : oppProductField_map.keyset()) {
                    Schema.DescribeFieldResult fieldDesc = oppProductField_map.get(fieldName).getDescribe();
                    
                    if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                        String theName = fieldDesc.getName();
                        // Continue building your dynamic query String
                        theQueryOpp += ', ' + theName;
                    }
                }
                theQueryOpp += ' FROM OpportunityLineItems) FROM Opportunity WHERE Id = :opportunityId';
                List<Opportunity> oppList = Database.query(String.escapeSingleQuotes(theQueryOpp));
                
                if (oppList.size() > 0) {
                    oppObj = oppList[0];
                    checkForMinimumSalesStage(minimumStageValue);
                    
                    if (!preFilter) {
                        isPreFilterApplied = true;
                    }
                }
            } else {
                isPreFilterApplied = true;
            }
            caseId = (ApexPages.currentPage().getParameters().get('caseId') == null ? '' : ApexPages.currentPage().getParameters().get('caseId'));
            leadId = (ApexPages.currentPage().getParameters().get('leadId') == null ? '' : ApexPages.currentPage().getParameters().get('leadId'));
        }
        pageNameRedirection = '' + ApexPages.currentPage().getUrl();
        //changes related to #864
        /*if (pageNameRedirection.toLowerCase().contains('rfsearchpagelead')) {
            relatedMappingController.pageName = 'lead';
            showFeaturedContentIcons = false;
        } else {
            relatedMappingController.pageName = 'RfSearch';
        }*/
        //changes related to #864
        if (fromLead) {
            showFeaturedContentIcons = false;
        }
        
        if (isFilteredContent) {
            filteredContents();
        }
        getAccounts();

        // change REF- 1288 
        userMappingList = new List<User_Mapping__c>(); 
        showOveray = false; 
        
        if (userInvitaionMappingList == null) {  
            userInvitaionMappingList = new List<User_Mapping__c>();  
        }  
        showInviationOveray = false;  
        helpAssistant = '';
        lastActivity = date.today(); 
        lastInvitationActivity = date.today();
        String checkvalr = (ApexPages.currentPage().getParameters().get('helpoverlay') == null ? '' : ApexPages.currentPage().getParameters().get('helpoverlay'));
        
        /** If help overlay is explicitly disabled, it means Ref search page can  
          * be visited agian and again by the same user from differnet processses 
          * and completing/canceling those process*/
        isUpdateRefSearchUsageCount = (String.isNotBlank(checkvalr) && checkvalr == 'false') ? false : true;  
        
        Map<Decimal,DMNameValueWrapper> tempMapDM = new Map<Decimal,DMNameValueWrapper>();
        Map<Decimal,DMNameValueWrapper> tempMapDMInvitation = new Map<Decimal,DMNameValueWrapper>();
        
        for (Data_Mapping__c dm : WithoutSharingHelperController.getDMHelpOverlay(new List<String>{UtilityController.appNamespace() + 'RfSearchPage', UtilityController.appNamespace() + 'Invitation_New'})) {
            
            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Invitation_New') {
                tempMapDMInvitation.put(dm.Order__c, new DMNameValueWrapper(dm.Label__c,dm.DC_Message__c));
            } else {
                tempMapDM.put(dm.Order__c, new DMNameValueWrapper(dm.Label__c,dm.DC_Message__c));
            }
        }
        helpOverlay = JSON.serialize(tempMapDM);
        
        helpOverlayInvitation = JSON.serialize(tempMapDMInvitation);
        
        if (!refMatch && checkvalr == '') {                        
            checkForHelpoverlay();
        }       
        checkForInvitaionHelpOverlay(); 
    }
    
    public static RefSearch_Usage_Track__c upsertRefSearchUsageTrackRecord(Boolean refMatch, String opportunityId, String leadId, String caseId, Boolean preFilter) {
    	Id userId = UserInfo.getUserId();
    	Date activityDate = Date.today();
    	String query = 'SELECT Id, User__c, Prefilter_Count__c, Filter_Applied_Count__c, Text_Search_Count__c, Refcontent_Link_Count__c, Activity_Date__c, Referrer__c, Usage_Count__c, Case__c, Lead__c, Opportunity__c FROM RefSearch_Usage_Track__c';
    	query += ' WHERE User__c =: userId AND Activity_Date__c =: activityDate';
    	RefSearch_Usage_Track__c returnRecord = null;
    	String referrer = '';
        Boolean isOpp = false,isLead = false,isCase = false;
    	if (refMatch) {
    		referrer = ConstantsController.REF_MATCH;
    	} else if (String.isNotBlank(opportunityId)) {
    		referrer = ConstantsController.OPPORTUNITY;
            query += ' AND Opportunity__c =:opportunityId';
            isOpp = true;
    	} else if (String.isNotBlank(leadId)){
    		referrer = ConstantsController.LEAD;
            query += ' AND Lead__c =:leadId';
            isLead = true;
    	} else if (String.isNotBlank(caseId)){
    		referrer = ConstantsController.REFERRER_CASE;
            query += ' AND Case__c =:caseId';
            isCase = true;
    	} else {
    		referrer = ConstantsController.REF_SEARCH_PAGE;
    	}
    	query += ' AND Referrer__c =: referrer';
    	
        List<RefSearch_Usage_Track__c> refSearchUsageTrackRecordList = Database.query(query);
		
    	List<RefSearch_Usage_Track__c> refSearchUsageTrackRecordListToUpsert = new List<RefSearch_Usage_Track__c>();
    	if (refSearchUsageTrackRecordList.size() == 0) {
    		RefSearch_Usage_Track__c refSearchUsageTrackRecord = new RefSearch_Usage_Track__c();
    		refSearchUsageTrackRecord.User__c = UserInfo.getUserId();
    		refSearchUsageTrackRecord.Activity_Date__c = Date.today();
    		refSearchUsageTrackRecord.Referrer__c = referrer;
            if (isCase) {
                refSearchUsageTrackRecord.Case__c = caseId;
            } else if (isLead) {
                refSearchUsageTrackRecord.Lead__c = leadId;
            } else if (isOpp) {
                refSearchUsageTrackRecord.Opportunity__c = opportunityId;
            }
    		refSearchUsageTrackRecord.Usage_Count__c = 1;
            if (preFilter) {
                refSearchUsageTrackRecord.Prefilter_Count__c = 1;
            }
    		refSearchUsageTrackRecordListToUpsert.add(refSearchUsageTrackRecord);
    	} else {
    		refSearchUsageTrackRecordList[0].Usage_Count__c++;
            if (preFilter) {
                refSearchUsageTrackRecordList[0].Prefilter_Count__c++;
            }
    		refSearchUsageTrackRecordListToUpsert.add(refSearchUsageTrackRecordList[0]);
    	}
    
    	if (refSearchUsageTrackRecordListToUpsert.size() > 0) {
    		upsert refSearchUsageTrackRecordListToUpsert;
            returnRecord = refSearchUsageTrackRecordListToUpsert[0];
    	}
        return returnRecord;
    }
    
    /**
    *   Method to check whether to show help overlay on page or not
    *   Author : Rajneesh (13 mar,2018) for REF-1288
    **/
    public void checkForHelpOverlay() {  
            
        if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) {

            showOveray = true;
            
            // Both account and content section
            if (showAccount && showRefContent) {                
                labelValue += 'HelpOverlay Account Contact';

            } else if (showAccount) {
                labelValue += 'HelpOverlay Account section';
                
            } else {                
                labelValue += 'HelpOverlay Content section';                    
            }
            userMappingList = [SELECT Id, Label__c, Order__c, User__c, Last_Used_Classic_Page__c FROM User_Mapping__c 
                                                    WHERE User__c =: UserInfo.getUserId() AND Label__c =: labelValue LIMIT 1];

            if (userMappingList.Size() > 0 && userMappingList[0].Order__c != null && userMappingList[0].Order__c >= cs.Help_Overlay_Count__c) {
                showOveray = false; 
            }
            
            if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userMappingList.size() > 0 && userMappingList[0].Last_Used_Classic_Page__c != null) {
                lastActivity = UtilityController.parseLastVisitDate(userMappingList[0].Last_Used_Classic_Page__c);
            }
        }        
    }

    /**
    *   Method to check whether to show help overlay on page or not
    *   Author : Rajesh  
    **/
    public void checkForInvitaionHelpOverlay() {  
        
        if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) {
               
            showInviationOveray = true; 
            labelInvitationValue = ConstantsController.INVITATION_HELP_OVERLAY;     
            userInvitaionMappingList = [SELECT Id, Label__c, Order__c, User__c, Last_Used_Classic_Page__c FROM User_Mapping__c 
                                WHERE User__c =:UserInfo.getUserId() AND Label__c =:labelInvitationValue
                                LIMIT 1];
 
            if (userInvitaionMappingList.Size() > 0 && userInvitaionMappingList[0].Order__c != null && userInvitaionMappingList[0].Order__c >= cs.Help_Overlay_Count__c) {
                showInviationOveray = false; 
            }
            
            if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userInvitaionMappingList.size() > 0 && userInvitaionMappingList[0].Last_Used_Classic_Page__c != null) {
                lastInvitationActivity = UtilityController.parseLastVisitDate(userInvitaionMappingList[0].Last_Used_Classic_Page__c); 
            }
        }        
    }

    public void userMappingRecord() {
    	if (isUpdateRefSearchUsageCount) {
            trackRecord = upsertRefSearchUsageTrackRecord(refMatch, opportunityId, leadId, caseId, isPreFilterApplied);
    	} 
        if (actionsSet == null) {
            actionsSet = new Set<String>();
        }
        if (attributeWrapper != null && attributeWrapper.attributeSelected != null && attributeWrapper.attributeSelected && actionsSet != null && !actionsSet.contains('Filter_Applied_Count__c') && trackRecord != null) {
            trackRecord.Filter_Applied_Count__c++;
            update trackRecord;
            actionsSet.add('Filter_Applied_Count__c');
        }
        //check user mapping count and custom setting count
        DateTime todayDate = system.today();
        if (showOveray) { 
            if (userMappingList.Size() > 0) { 

                if (userMappingList[0].Order__c != null) { 
                    
                    if (cs.Reset_Help_Assistant_Days__c != null 
                                && lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c) {
                        helpAssistant = ConstantsController.HELP_ASSISTANT;
                        userMappingList[0].Order__c = 1; 
                    } else {
                        userMappingList[0].Order__c += 1;
                    } 
                } else {
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
     *   Method to Manage user mapping for inviation
     *   Author : Rajesh REF-1572
    **/
    public void userInvitaionMappingRecord() {     
        //  check user mapping count and custom setting count 
        DateTime todayDate = system.today();
        if (showInviationOveray) {
            
            if (userInvitaionMappingList.Size() > 0) { 

                if (userInvitaionMappingList[0].Last_Used_Classic_Page__c != null) { 
                     
                    if (cs.Reset_Help_Assistant_Days__c != null && 
                                    lastInvitationActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c) {
                        helpAssistant = ConstantsController.HELP_ASSISTANT;
                        userInvitaionMappingList[0].Order__c = 1; 
                    } else {
                        userInvitaionMappingList[0].Order__c += 1;
                    } 
                } else {
					userInvitaionMappingList[0].Order__c = 1;
				}
                userInvitaionMappingList[0].Last_Used_Classic_Page__c = todayDate.format('yyyy-MM-dd'); 
                  
            } else {
                User_Mapping__c umr = new User_Mapping__c();
                umr.Label__c = labelInvitationValue;
                umr.Order__c = 1;
                umr.User__c = UserInfo.getUserId();
                umr.Last_Used_Classic_Page__c = todayDate.format('yyyy-MM-dd'); 
                userInvitaionMappingList.add(umr);
            }  

       } else if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 
                    && (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0) 
                    && (lastInvitationActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c)) { 
            helpAssistant = ConstantsController.HELP_ASSISTANT;
            userInvitaionMappingList[0].Order__c = 1;
            userInvitaionMappingList[0].Last_Used_Classic_Page__c = todayDate.format('yyyy-MM-dd'); 
            showInviationOveray = true;
        } 

        if (userInvitaionMappingList.Size() > 0 && cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) { 
            upsert userInvitaionMappingList;  
        }               
    }


    /** 
    *   Method to go back to opportunity record
    *   Author : Rajneesh (23 feb,2018) for REF - 1302
    **/
    public PageReference backToOpportunity() {
        PageReference oppDetail = new PageReference('/' + opportunityId);
        return oppDetail;
    }

    /**
     * method to export accounts search results
     * author: Gaurav Saini (2 Dec, 2017) for #1135
     */
    public PageReference getSearchResults() {
        isExportClicked = true;
        newLine = '\n';
        if (actionsSet != null && !actionsSet.contains('Text_Search_Count__c') && trackRecord != null) {
            trackRecord.Text_Search_Count__c++;
            update trackRecord;
            actionsSet.add('Text_Search_Count__c');
        }
        if (exportObjectName == 'SearchedAccounts') {
            getAccounts();
        } else if (exportObjectName == 'SearchedContacts') {
            getContacts();
        } else if (exportObjectName == 'SearchedContent') {
            getContents();
        }
        isExportClicked = false;
        return null;
    }
    
    /**
     * Method to reset all variables
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    private void reset() {
        isExportClicked = false;
        attributeWrapper = new AttributeWrapper();
        referenceabilityWrapper = new ReferenceabilityWrapper();
        accountSearch = new AccountSearchController();
        contactSearch = new ContactSearchController();
        contentSearch = new ContentSearchController();
        showFeaturedContentIcons = true;
        assAccounts = new AssociatedRefContAccountsController();
        invitationcontroller = new InvitationController();
        attributeMapInheritableAccountIds = new Set<String>();
        attributeMapInheritableContentIds = new Set<String>();
        attributeMapInheritableContactIds = new Set<String>();
        isBasicSearchViewSelected = true;
        sectionOrder = new List<String>();
        sectionOrder.add('account');
        sectionOrder.add('contact');
        isAccountRenderFirst = true;
        minimumStageError = '';
        inputTextValue = '';
        collectionName = '';
        selectedCollection = '';
        isContentCollection = false;
        isInlineEditingDisabled = false;
        isEdit = false;
        isPreFilterApplied = false;
        fromLead = false;
        showExportButton = false;
        EditRequestId = '';
        selectedIds = '';
        SECUREURL = 'http://';
        relatedMappingController = new SearchRelatedMappingRecorsController();
        isAccount = false;
        isContact = false;
        isShowMoreLink = false;
        showContactBlock = true;
        downloadContentUrl = '/sfc/servlet.shepherd/version/download/';
        isFilterReload = false;
        preFilter = false;
        isFilteredContent = false;
        logics = new List<SelectOption>();
        logics.add(new SelectOption('Or', ''));
        logics.add(new SelectOption('And', ''));
        logicsWithName = new List<SelectOption>();
        logicsWithName.add(new SelectOption('Or', 'Any'));
        logicsWithName.add(new SelectOption('And', 'All'));
        filterLogicsList = new List<String>();
        filterLogics = new Map<String, FilterLogicWrapper>();
        betweenFilterLogics = 'And';
        List<User> currentLoginUser = [SELECT Id, UserPermissionsSFContentUser, User.profile.name
                                        FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        isCRMContentUser = (currentLoginUser.size() > 0 ? currentLoginUser[0].UserPermissionsSFContentUser : false);
        cs = UtilityController.getCustomSettings(); 
        isShraredContact = cs.Shared_Contacts__c;
        showOwner = cs.Show_Owner_in_Ref_Search__c;
        isAllowRelatedContent = cs.Show_Related_Ref_Content_in_RefSearch__c; 
        invitationcontroller.defaultExpirationDays = (cs.Default_Expiration_Days__c != null ? cs.Default_Expiration_Days__c : 0);
        invitationcontroller.maximumExpirationDays = (cs.Maximum_Expiration_Days__c != null ? cs.Maximum_Expiration_Days__c : 0);
        accounts = new List<AccountWrapper>();
        contacts = new List<ContactWrapper>();
        contents = new List<ConetntWrapper>();
        // re #1001 -Include for account content details.
        //accountContents = new List<ConetntWrapper>();
        isCollectionCreateable = Schema.sObjectType.Content_Collection__c.isCreateable();
        refMatch = false;
    }
    
    /**
     * Method to set all Filters in left panel
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    private void setFilters() {
        attributeResults = new Map<String, Attribute_Mapping__c>();
        
        for (Attribute_Mapping__c attMap : WithoutSharingHelperController.getAttributeMappingsForRefSearch()) {
            
            if (!relatedMappingController.mappingSelectedValues.containsKey(attMap.Id)) {
                relatedMappingController.mappingSelectedValues.put(attMap.Id, new List<String>());
                relatedMappingController.mappingSelectedValuesLabel.put(attMap.Id, new List<String>());
            }
            attributeResults.put(attMap.Id, attMap);
        }
        //for filter order no
        filterList = new List<Data_Mapping__c>();
        Set<String> filterSet = new Set<String>();
        
        for (Data_Mapping__c dm : [SELECT Name, Order__c, Id, Visible__c, Required__c, Filter_RefSearch_Visible__c,
                                    Label__c, From_Mapping__c, Field_API_Name__c 
                                    FROM Data_Mapping__c WHERE Object__c = 'Filter'
                                    AND Filter_RefSearch_Visible__c = true
                                    AND Order__c != null
                                    ORDER BY Order__c, Label__c]) {
            filterList.add(dm);
            filterSet.add(dm.Field_API_Name__c);
        }
        Map<String, List<Data_Mapping__c>> tempMap = new Map<String, List<Data_Mapping__c>>();
        
        for (Data_Mapping__c dm : [SELECT Name, Order__c, Id, Visible__c, Required__c, Filter_RefSearch_Visible__c,
                                    Label__c, From_Mapping__c, Field_API_Name__c 
                                    FROM Data_Mapping__c WHERE Object__c = 'Filter'
                                    AND Filter_RefSearch_Visible__c = true
                                    AND Order__c = null
                                    ORDER BY Label__c]) {
            
            if (!tempMap.containsKey(dm.Label__c)) {
                tempMap.put(dm.Label__c, new List<Data_Mapping__c>());
            }
            tempMap.get(dm.Label__c).add(dm);
            filterSet.add(dm.Field_API_Name__c);
        }
        
        for (Label__c lbl : attributeWrapper.getAttributeLabels()) {
            
            if (!filterSet.contains(lbl.Id) && lbl.Filter_RefSearch_Visible__c) {
                
                if (!tempMap.containsKey(lbl.Name)) {
                    tempMap.put(lbl.Name, new List<Data_Mapping__c>());
                }
                tempMap.get(lbl.Name).add(new Data_Mapping__c(Label__c = lbl.Name, Field_API_Name__c = lbl.Id,
                                                                Object__c = 'Filter', Visible__c = lbl.BasicSearchView__c,
                                                                Filter_RefSearch_Visible__c = lbl.Filter_RefSearch_Visible__c));
            }
        }
        List<String> sortedfilter = new List<String>();
        sortedfilter.addAll(tempMap.keySet());
        sortedfilter.sort();
        
        for (String label : sortedfilter) {
            filterList.addAll(tempMap.get(label));
        }
        //re #362 - Custom Setting decide default value for filters (Any or All)
        searchFilterDefault = cs.RefSearch_Filters_Default__c ? 'And' : 'Or';
        
        for (Data_Mapping__c dm : filterList) {
            
            if (dm.From_Mapping__c == false) {
                filterLogicsList.add(dm.Field_API_Name__c);
                filterLogics.put(dm.Field_API_Name__c, new FilterLogicWrapper(dm.Field_API_Name__c, dm.Label__c, searchFilterDefault));
            }
        }
    }
    
    /*
     * Method to search Filtered content Tab from Custom setting
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    private void filteredContents() {
        Set<String> setReferenceContentTypes = new Set<String>();
        
        if (cs.Filtered_Content_Ids__c != null) {
            
            for (String refenceContentId : cs.Filtered_Content_Ids__c.split(',')) {
                setReferenceContentTypes.add(refenceContentId);
            }
        }

        for (Reference_Content_Type__c rct : [SELECT Id, Name__c FROM Reference_Content_Type__c WHERE Id IN :setReferenceContentTypes AND Disable_For_Filter__c = false ORDER BY Name__c]) {
            contentSearch.selectedContentTypeName = rct.Name__c;
            contentSearch.setContentTypes();
        }
    }
    
    /**
     * Method to set filters automatically when refsearch page load
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void preFilterSearch() {
        Set<String> labelIds = new Set<String>();
        
        for (Data_Mapping__c dm : WithoutSharingHelperController.getDataMappingsForPreFilter()) {
                        
            if (dm.Field_API_Name__c != null) {
                labelIds.add(dm.Field_API_Name__c);
            }
        }
        
        Map<String, Set<String>> selectedLabelMap = new Map<String, Set<String>>();
        
        if (oppObj != null && oppObj.AccountId != null) {
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Account.fields.getMap();
            List<Schema.SObjectField> fldObjMapValues = fldObjMap.values();
            String theQuery = 'SELECT Id, Name';
            
            for (Schema.SObjectField s : fldObjMapValues) {
                Schema.DescribeFieldResult fieldDesc = s.getDescribe();
                
                if (fieldDesc.getType() == Schema.DisplayType.PICKLIST || fieldDesc.getType() == Schema.DisplayType.MULTIPICKLIST) {
                    String theName = fieldDesc.getName();
                    // Continue building your dynamic query String
                    theQuery += ', ' + theName;
                }
            }
            theQuery += ' FROM Account WHERE Id = \'' + oppObj.AccountId + '\'LIMIT 1';
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
            
            for (OpportunityLineItem oppLineItem : oppObj.OpportunityLineItems) {
                oppoProducts.add(oppLineItem.PricebookEntry.Product2Id);
                oppLineItems.add(oppLineItem);
            }

            for (Attribute_Mapping__c attMapping : [SELECT Object__c, Id, Related_Object__c, Is_Related_Mapping__c, Filter_Label_Name__c, Field_Api_Name__c, 
                                Field__c, Attribute_Name__c, Is_Related_MultiSelectPicklist__c FROM Attribute_Mapping__c 
                                WHERE (Object__c = :ConstantsController.ACCOUNT OR Object__c = :ConstantsController.OPPORTUNITY)]) {
                
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
                        
                        if (fieldMapOpp.containsKey(attMapping.Field_Api_Name__c) && oppObj.get(attMapping.Field_Api_Name__c) != null) {
                            oppFieldValues.put(attMapping.Attribute_Name__c, String.valueOf(oppObj.get(attMapping.Field_Api_Name__c)));
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
                List<Attribute__c> rootLevelAttributes = [SELECT Level__c, Name, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Object__c, 
                                        Attribute_Mapping__r.Is_Related_Mapping__c, (SELECT Id, Name, Level__c, Product_ID__c FROM Attributes__r 
                                        WHERE Level__c = 1) FROM Attribute__c WHERE Level__c = 0 AND Attribute_Mapping__c IN :attMappingsAccount];
                Map<String, String> AttributeLabelMap = new Map<String, String>();
                //re #963
                Map<String, Set<String>> AttributeMap = new Map<String, Set<String>>();
                Set<String> attIds = new Set<String>();
                
                for (Attribute__c root : rootLevelAttributes) {
                    AttributeMap.put(root.Id, new Set<String>());
                    
                    for (Attribute__c att : root.Attributes__r) {
                        //attIds.add(att.Id);
                        //re #963 create map of parent and all child attributes
                        AttributeMap.get(root.Id).add(att.Id);
                        //break;
                    }
                }
                
                //re #963 iterate over map of attribute wrapper which has all Filters and associated attributes
                // we can get the mapping of child attributes and filter id
                for (String labelId : attributeWrapper.mapAllAttributesLabel.keySet()) {
                    
                    for (AttributeWrapper.AttributesLabelWrapper alw : attributeWrapper.mapAllAttributesLabel.get(labelId)) {
                        
                        if (AttributeMap.containsKey(alw.attributeLabel.Attribute__r.Parent__c) && !AttributeLabelMap.containsKey(alw.attributeLabel.Attribute__r.Parent__c)) {
                            AttributeLabelMap.put(alw.attributeLabel.Attribute__r.Parent__c, alw.attributeLabel.Label__c);
                            break;
                        }
                    }
                }
                
                //for (Attributes_Labels__c attLabel : [SELECT Label__c, Attribute__r.Parent__c FROM Attributes_Labels__c WHERE Attribute__c IN :attIds]) {
                    //AttributeLabelMap.put(attLabel.Attribute__r.Parent__c, attLabel.Label__c);
                //}
                
                for (Attribute__c root : rootLevelAttributes) {
                    
                    if (labelIds.contains(AttributeLabelMap.get(root.Id)) && accountFieldValues.containsKey(root.Name) && 
                            root.Attribute_Mapping__r.Object__c == ConstantsController.ACCOUNT) {
                                
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
                            accountSearch.stageLabelId = AttributeLabelMap.get(root.Id);
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
                
                for (String labelId : selectedLabelMap.keySet()) {
                    
                    for (AttributeWrapper.AttributesLabelWrapper alw : attributeWrapper.mapAllAttributesLabel.get(labelId)) {
                        
                        if (selectedLabelMap.get(labelId).contains(alw.attributeLabel.Attribute__c)) {
                            
                            if (alw.fontWeight == ConstantsController.NORMAL) {
                                attributeWrapper.mapAttributesLabels.get(labelId).add(alw);
                                alw.fontWeight = ConstantsController.BOLD;
                                attributeWrapper.allSelectedAttrIds.add(alw.attributeLabel.Attribute__c);
                            }
                        }
                    }
                }
            }
        }
        isPreFilterApplied = true;
        preFilter = false;
    }
    
    /**
     * Method to get searched Accounts
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public List<AccountWrapper> getAccounts() {
        
        if (isAccountRenderFirst || isShraredContact) {
            String searchText = '';
            searchText = String.escapeSingleQuotes(inputTextValue);
            tempTextValue = inputTextValue;
            Set<String> accountId = new Set<String>();
            
            if (selectedId != '' && selectedId != null) {
                
                for (String accId : selectedId.split(',')) {
                    accountId.add(accId.trim());
                }
            }

            // added for REF-1341 - Gaurav Saini (4 Sep, 2018)
            // setting selected accountIds from the page params
            if (selectedAccIdsParam != null && selectedAccIdsParam.trim() != '') {

                for (String accId : selectedAccIdsParam.split(',')) {
                    accountId.add(accId.trim());
                }
            }
            Boolean isContactContentMapping = false;
            attributeMapInheritableAccountIds = new Set<String>();
            accounts = new List<AccountWrapper>();
            
            if (isPreFilterApplied) {
                Boolean mappingSelected = false;
                Set<String> accountMappedIds = new Set<String>();
                Integer count = 0;
                Set<String> tempIds = new Set<String>();
                accountMappedIds = new Set<String>();
                Boolean isInheritableMappingFromContact, isInheritableMappingFromContent;
                isInheritableMappingFromContact = isInheritableMappingFromContent = false;
                Set<String> mappingIds = new Set<String>();
                
                //get id of attribute mapping of contact map related to #639
                for (String attMapKey : relatedMappingController.mappingContactIds.keySet()) {
                    mappingIds.add(attMapKey);
                }
                
                for (String attMapKey : relatedMappingController.mappingRelatedContactIds.keySet()) {
                    mappingIds.add(attMapKey);
                }
                
                for (String attMapKey : relatedMappingController.mappingRelatedContentIds.keySet()) {
                    mappingIds.add(attMapKey);
                }
                
                if (mappingIds.size() > 0) {
                    
                    for (Attribute_Mapping__c attMapping : [SELECT Id FROM Attribute_Mapping__c WHERE (Id IN :mappingIds) AND Inheritable__c = true]) {
                        
                        if (relatedMappingController.mappingRelatedContactIds.containsKey(attMapping.Id)) {
                            isInheritableMappingFromContact = true;
                        }
                        
                        //if attribute mapping is inheritable related to #639
                        if (relatedMappingController.mappingContactIds.containsKey(attMapping.Id)) {
                            isInheritableMappingFromContact = true;
                        }
                        
                        if (relatedMappingController.mappingRelatedContentIds.containsKey(attMapping.Id)) {
                            isInheritableMappingFromContent = true;
                        }
                    }
                }
                Set<String> inheritableAccountIds = new Set<String>();

                for (String mapKey : relatedMappingController.mappingRelatedContactIds.keySet()) {
                    
                    for (String contentIds : relatedMappingController.mappingRelatedContactIds.get(mapKey)) {

                        if (count == 0) {
                            tempIds.add(contentIds);
                        } else if (attributeMapInheritableContactIds.contains(contentIds)) {
                            tempIds.add(contentIds);
                        }
                    }
                    attributeMapInheritableContactIds = new Set<String>();
                    attributeMapInheritableContactIds.addAll(tempIds);
                    tempIds = new Set<String>();
                    ++count;
                }
                
                //store ids of searched contact (get common contact ids) related to #639
                for (String mapKey : relatedMappingController.mappingContactIds.keySet()) {
                    
                    for (String contentIds : relatedMappingController.mappingContactIds.get(mapKey)) {

                        if (count == 0) {
                            tempIds.add(contentIds);
                        } else if (attributeMapInheritableContactIds.contains(contentIds)) {
                            tempIds.add(contentIds);
                        }
                    }
                    attributeMapInheritableContactIds = new Set<String>();
                    attributeMapInheritableContactIds.addAll(tempIds);
                    tempIds = new Set<String>();
                    ++count;
                }
                
                if (isInheritableMappingFromContact) {
                    //changes regarding #722
                    String query = 'SELECT Id, AccountId FROM Contact WHERE Id In :relatedObjectIds';
                    
                    for (sObject rc : WithoutSharingHelperController.getRelatedMappingIds(query, null, attributeMapInheritableContactIds)) {
                        inheritableAccountIds.add(string.valueOf(rc.get('AccountId')));
                    }
                }

                tempIds = new Set<String>();
                count = 0;
                
                for (String mapKey : relatedMappingController.mappingRelatedContentIds.keySet()) {
                    
                    for (String contentIds : relatedMappingController.mappingRelatedContentIds.get(mapKey)) {
                        
                        if (count == 0) {
                            tempIds.add(contentIds);
                        } else if (attributeMapInheritableContentIds.contains(contentIds)) {
                            tempIds.add(contentIds);
                        }
                    }
                    attributeMapInheritableContentIds = new Set<String>();
                    attributeMapInheritableContentIds.addAll(tempIds);
                    tempIds = new Set<String>();
                    ++count;
                }
                
                if (isInheritableMappingFromContent) {
                    //changes regarding #722
                    String query = 'SELECT Account__c FROM Account_Reference_Content__c WHERE Reference_Content__c In :relatedObjectIds';
                    
                    for (sObject rc : WithoutSharingHelperController.getRelatedMappingIds(query, null, attributeMapInheritableContentIds)) {
                        inheritableAccountIds.add(string.valueOf(rc.get('Account__c')));
                    }
                }
                
                tempIds = new Set<String>();
                
                if (isInheritableMappingFromContent || isInheritableMappingFromContact) {
                    mappingSelected = true;
                    accountMappedIds.addAll(inheritableAccountIds);
                    count = 1;
                } else {
                    count = 0;
                }
                Set<String> commonAccIds = new Set<String>();
                
                for (String mapKey : relatedMappingController.mappingRelatedAccountIds.keySet()) {
                    
                    if (relatedMappingController.mappingRelatedAccountIds.get(mapKey).size() > 0) {
                        
                        for (String accIds : relatedMappingController.mappingRelatedAccountIds.get(mapKey)) {
                            
                            if (count == 0) {
                                tempIds.add(accIds);
                            } else if (accountMappedIds.contains(accIds)) {
                                tempIds.add(accIds);
                            }
                        }

                        accountMappedIds = new Set<String>();
                        accountMappedIds.addAll(tempIds);
                        tempIds = new Set<String>();
                        ++count;
                    }
                    mappingSelected = true;
                }
                tempIds = new Set<String>();
                
                //store ids of searched account (get common account ids) related to #639
                for (String mapKey : relatedMappingController.mappingAccountIds.keySet()) {
                    
                    if (relatedMappingController.mappingAccountIds.get(mapKey).size() > 0) {
                        
                        for (String accIds : relatedMappingController.mappingAccountIds.get(mapKey)) {
                            
                            if (count == 0) {
                                tempIds.add(accIds);
                            } else if (accountMappedIds.contains(accIds)) {
                                tempIds.add(accIds);
                            }
                        }

                        accountMappedIds = new Set<String>();
                        accountMappedIds.addAll(tempIds);
                        tempIds = new Set<String>();
                        ++count;
                    }
                    mappingSelected = true;
                }
                accountSearch.filterLogic = new Map<String, String>();
                
                for (FilterLogicWrapper flw : filterLogics.values()) {
                    accountSearch.filterLogic.put(flw.filterId, flw.operatorSelected);
                }
                accountSearch.betweenFilterLogic = betweenFilterLogics;
                
                for (String accId : accountMappedIds) {
                    
                    if (!inheritableAccountIds.contains(accId)) {
                        attributeMapInheritableAccountIds.add(accId);
                    } else {
                        mappingSelected = true;
                    }
                }
                contactSearch.accountIdSet = new Set<Id>();
                contentSearch.accountIdSet = new Set<Id>();
                accounts = accountSearch.listAccounts(searchText, attributeWrapper, referenceabilityWrapper, 
                                                        accountMappedIds, mappingSelected, isExportClicked);
                for (AccountWrapper aw : accounts) {
                    
                    if (accountId.contains(aw.acc.Account__r.Id)) {
                        aw.isSelected = true;
                    }
                }
                
                for (String accId : accountSearch.searchedAccountIdSet) { // done for #234
                    contactSearch.accountIdSet.add(accId);
                    contentSearch.accountIdSet.add(accId);
                }
                selectedId = '';
            }
        }
        return accounts;
    }

    /**
     * Method to get searched Contacts
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public List<ContactWrapper> getContacts() {
        isAccountRenderFirst = true;
        accounts = getAccounts();
        isAccountRenderFirst = true;
        String searchText = '';
        searchText = String.escapeSingleQuotes(inputTextValue);
        tempTextValue = inputTextValue;
        Boolean mappingSelected = false;
        Set<String> contactMappedIds = new Set<String>();
        Integer count = 0;
        Set<String> tempIds = new Set<String>();
        Set<String> inheritableAccountIds = new Set<String>();
        attributeMapInheritableContactIds = new Set<String>();
        Boolean isInheritableMapping = false;
        Set<String> mappingIds = new Set<String>();
        
        for (String attMapKey : relatedMappingController.mappingRelatedAccountIds.keySet()) {
            mappingIds.add(attMapKey);
        }
        
        //get id of attribute mapping of account map related to #639
        for (String attMapKey : relatedMappingController.mappingAccountIds.keySet()) {
            mappingIds.add(attMapKey);
        }
        
        if (mappingIds.size() > 0) {
            
            for (Attribute_Mapping__c attMapping : [SELECT Id FROM Attribute_Mapping__c WHERE Id IN :mappingIds AND Inheritable__c = true]) {
                isInheritableMapping = true;
            }
        }
        Set<String> inheritableContactIds = new Set<String>();
        
        if (isInheritableMapping) {
            //changes regarding #722
            String query = 'SELECT Id FROM Contact WHERE AccountId In :relatedObjectIds';
            
            for (sObject rc : WithoutSharingHelperController.getRelatedMappingIds(query, null, attributeMapInheritableAccountIds)) {
                inheritableContactIds.add(string.valueOf(rc.get('Id')));
            }
        }
        
        if (isInheritableMapping) {
            mappingSelected = true;
            contactMappedIds.addAll(inheritableContactIds);
            count = 1;
        } else {
            count = 0;
        }
        
        for (String mapKey : relatedMappingController.mappingRelatedContactIds.keySet()) {
            
            if (relatedMappingController.mappingRelatedContactIds.get(mapKey).size() > 0) {
                
                for (String contentIds : relatedMappingController.mappingRelatedContactIds.get(mapKey)) {

                    if (count == 0) {
                        tempIds.add(contentIds);
                    } else if (contactMappedIds.contains(contentIds)) {
                        tempIds.add(contentIds);
                    }
                }
                contactMappedIds = new Set<String>();
                contactMappedIds.addAll(tempIds);
                tempIds = new Set<String>();
                ++count;
            }
            
            if (relatedMappingController.mappingSelectedValues.containsKey(mapKey) && relatedMappingController.mappingSelectedValues.get(mapKey).size() > 0) {
                mappingSelected = true;
            }
        }
        tempIds = new Set<String>();
        
        //store ids of searched contact (get common contact ids) related to #639
        for (String mapKey : relatedMappingController.mappingContactIds.keySet()) {
            
            if (relatedMappingController.mappingContactIds.get(mapKey).size() > 0) {
                
                for (String contentIds : relatedMappingController.mappingContactIds.get(mapKey)) {

                    if (count == 0) {
                        tempIds.add(contentIds);
                    } else if (contactMappedIds.contains(contentIds)) {
                        tempIds.add(contentIds);
                    }
                }
                contactMappedIds = new Set<String>();
                contactMappedIds.addAll(tempIds);
                tempIds = new Set<String>();
                ++count;
            }
            
            if (relatedMappingController.mappingSelectedValues.containsKey(mapKey) && relatedMappingController.mappingSelectedValues.get(mapKey).size() > 0) {
                mappingSelected = true;
            }
        }
        
        for (String accId : contactMappedIds) {
            
            if (!inheritableContactIds.contains(accId)) {
                attributeMapInheritableContactIds.add(accId);
            } else {
                mappingSelected = true;
            }
        }
        contactSearch.filterLogic = new Map<String, String>();
        
        for (FilterLogicWrapper flw : filterLogics.values()) {
            contactSearch.filterLogic.put(flw.filterId, flw.operatorSelected);
        }
        contactSearch.betweenFilterLogic = betweenFilterLogics;
        
        if (contactSearch.accountId != null && refMatch) {
            contacts = contactSearch.listAccountContacts();
        } else if (!refMatch || showHitContacts) {
            contacts = contactSearch.listContacts(searchText, attributeWrapper, referenceabilityWrapper, 
                                                contactMappedIds, mappingSelected, isExportClicked);
        }
        
        //REF-1964
        if (isRefHubMatch) {
            
            for (ContactWrapper cw : contacts) {
                
                if (mapContactIdContactWrapper.containsKey(cw.con.Contact__r.Id)) {
                    cw.isSelected = mapContactIdContactWrapper.get(cw.con.Contact__r.Id).isSelected;
                }
            } 
        }
        return contacts;
    }

    /**
     * Method to get searched Reference Contents
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public List<ConetntWrapper> getContents() {
        String searchText = '';
        searchText = String.escapeSingleQuotes(inputTextValue);
        tempTextValue = inputTextValue;
        contents = new List<ConetntWrapper>();
        
        if (isPreFilterApplied) {
            Set<String> contentId = new Set<String>();
            
            if (selectedId != '' && selectedId != null) {
                
                for (String contId : selectedId.split(',')) {
                    contentId.add(contId);
                }
            }
            Boolean mappingSelected = false;
            Set<String> contentMappedIds = new Set<String>();
            Integer count = 0;
            Set<String> tempIds = new Set<String>();
            attributeMapInheritableContentIds = new Set<String>();
            Set<String> inheritableAccountIds = new Set<String>();
            Boolean isInheritableMapping = false;
            Set<String> mappingIds = new Set<String>();
            
            for (String attMapKey : relatedMappingController.mappingRelatedAccountIds.keySet()) {
                mappingIds.add(attMapKey);
            }
                
            //get id of attribute mapping of account map related to #639
            for (String attMapKey : relatedMappingController.mappingAccountIds.keySet()) {
                mappingIds.add(attMapKey);
            }
            
            if (mappingIds.size() > 0) {
                
                for (Attribute_Mapping__c attMapping : [SELECT Id FROM Attribute_Mapping__c WHERE Id IN :mappingIds AND Inheritable__c = true]) {
                    isInheritableMapping = true;
                }
            }
            Set<String> inheritableContentIds = new Set<String>();
            //changes regarding #722
            String query = 'SELECT Reference_Content__c FROM Account_Reference_Content__c WHERE Account__c In :relatedObjectIds';
            
            for (sObject rc : WithoutSharingHelperController.getRelatedMappingIds(query, null, attributeMapInheritableAccountIds)) {
                inheritableContentIds.add(string.valueOf(rc.get('Reference_Content__c')));
            }
            
            if (isInheritableMapping) {
                mappingSelected = true;
                contentMappedIds.addAll(inheritableContentIds);
                count = 1;
            } else {
                count = 0;
            }
            
            for (String mapKey : relatedMappingController.mappingRelatedContentIds.keySet()) {
                
                if (relatedMappingController.mappingRelatedContentIds.get(mapKey).size() > 0) {
                    
                    for (String contentIds : relatedMappingController.mappingRelatedContentIds.get(mapKey)) {
                        
                        if (count == 0) {
                            tempIds.add(contentIds);
                        } else if (contentMappedIds.contains(contentIds)) {
                            tempIds.add(contentIds);
                        }
                    }
                    contentMappedIds = new Set<String>();
                    contentMappedIds.addAll(tempIds);
                    tempIds = new Set<String>();
                    ++count;
                }
                
                if (relatedMappingController.mappingSelectedValues.containsKey(mapKey) && relatedMappingController.mappingSelectedValues.get(mapKey).size() > 0) {
                    mappingSelected = true;
                }
            }
            
            for (String accId : contentMappedIds) {
                
                if (!inheritableContentIds.contains(accId)) {
                    attributeMapInheritableContentIds.add(accId);
                } else {
                    mappingSelected = true;
                }
            }
            contentSearch.filterLogic = new Map<String, String>();
            
            for (FilterLogicWrapper flw : filterLogics.values()) {
                contentSearch.filterLogic.put(flw.filterId, flw.operatorSelected);
            }
            contents = contentSearch.listContents(searchText, attributeWrapper, contentMappedIds, mappingSelected, cs, isExportClicked);
            
            for (ConetntWrapper cw : contents) {
                
                if (contentId.contains(cw.refContent.Id)) {
                    cw.isSelected = true;
                }
                
                if (contentId.contains(cw.contentVersion.ContentDocumentId)) {
                    cw.isSelected = true;
                }
            }
            selectedId = null;
            
            if (contents.size() == 0) {
                contentSearch.featuredChecked = false;
            }
        }
        return contents;
    }
    
    /**
     * Method to go to on advanced Filter
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public pageReference gotoAdvancedFilter() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        tempFilterLogicList = new Map<String, FilterLogicWrapper>();
        tempFilterLogicList.putAll(filterLogics);
        return Page.SearchRelatedMappingRecords;
    }
    
    /**
     * Method to show more records on Account, Contact and Content section
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public pagereference callShowMoreLink() { 
        accountSearch.reset();
        contentSearch.reset();
        contactSearch.reset();
        
        // re #659-Reset Selected Content Ids
        if (contentSearch.selectContentDocumentId != null && contentSearch.selectContentDocumentId != '') {
            contentSearch.selectedContentIdSet.clear(); 
            
            for (String docId : contentSearch.selectContentDocumentId.split(',')) {
                contentSearch.selectedContentIdSet.add(docId);
            }
        } else {
            contentSearch.selectedContentIdSet.clear();
        }
        
        //REF-1964
        if (isSelectAllContacts) {
            isSelectAllContacts = false; 
        }          
        return null;
    }

    /**
     * Method to go back on refsearch page
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void backToReSearch() {
        accountSearch.showMoreAccountRecords = false;
        contentSearch.showMoreContentRecords = false;
        contactSearch.showMoreContactRecords = false;
        
        if (ApexPages.currentPage().getParameters().get('forAccount') != null || ApexPages.currentPage().getParameters().get('forContent') != null) {
            showHitContacts = false;
        } else {
            showHitContacts = true;
        }
        resetAllObjects();
    }

    /**
     * Method to go to on advanced search
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public pageReference gotoAdvancedSearch() {

        for (Data_Mapping__c dm : filterList) {
            
            if (dm.From_Mapping__c) {
                relatedMappingController.attributeMappingId = dm.Field_API_Name__c;
                break;
            }
        }
        
        if (relatedMappingController.attributeMappingId != null) {
            goToTheRelatedSearch();
            return Page.AttributeMappingResults;
        } else {
            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.INFO, system.label.No_Mappings_Defined));
            return null;
        }
    }
    
    /**
     * Method to go to the related search
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public pageReference goToTheRelatedSearch() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        resetAllObjects();
        Attribute_Mapping__c attMapping;
        
        for (Attribute_Mapping__c attM : WithoutSharingHelperController.getAttributeMappings(relatedMappingController.attributeMappingId)) {
            attMapping = attM;
            relatedMappingController.attMapping = attM;
            relatedMappingController.selectedFilterName = attM.Filter_Label_Name__c;
        }
        relatedMappingController.selectedValues = new Set<String>();
        relatedMappingController.hasBulkRecords = false;
        relatedMappingController.isFieldPicklistType = false;
        relatedMappingController.showSearchBox = true;
        Set<String> selectedValues = new Set<String>();
        
        if (relatedMappingController.mappingSelectedValues.containsKey(relatedMappingController.attributeMappingId)) {
            relatedMappingController.selectedValues.addAll(relatedMappingController.mappingSelectedValues.get(relatedMappingController.attributeMappingId));
            
            if (relatedMappingController.selectedValues.size() > 0) {
                selectedValues.addAll(relatedMappingController.selectedValues);
            }
        } else {
            relatedMappingController.mappingSelectedValues.put(relatedMappingController.attributeMappingId, new List<String>());
            relatedMappingController.mappingSelectedValuesLabel.put(relatedMappingController.attributeMappingId, new List<String>());
        }
        relatedMappingController.searchResults = new List<SearchRelatedMappingRecorsController.searchClass>();
        Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType objType = gd.get(relatedMappingController.attMapping.Related_Object__c);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        Map<String, Schema.SObjectField> fieldMapCustom = new Map<String, Schema.SObjectField>();
        
        for (String apiName : fieldMap.keySet()) {
            Schema.DescribeFieldResult dfr = fieldMap.get(apiName).getDescribe();
            fieldMapCustom.put(dfr.getName().toLowerCase(), fieldMap.get(apiName));
        }
        
        if (fieldMapCustom.containsKey(relatedMappingController.attMapping.Field_Api_Name__c.toLowerCase()) &&
                        (fieldMapCustom.get(relatedMappingController.attMapping.Field_Api_Name__c.toLowerCase()).getDescribe().getType() 
                        == Schema.DisplayType.PICKLIST ||
                        fieldMapCustom.get(relatedMappingController.attMapping.Field_Api_Name__c.toLowerCase()).getDescribe().getType() 
                        == Schema.DisplayType.MULTIPICKLIST)) {

            relatedMappingController.isFieldPicklistType = true;
            
            for (Schema.PicklistEntry pe : fieldMapCustom.get(attMapping.Field_Api_Name__c.toLowerCase()).getDescribe().getPickListValues()) {
                SearchRelatedMappingRecorsController.searchClass sc = new SearchRelatedMappingRecorsController.searchClass(pe.getLabel(), pe.getValue());
                
                if (selectedValues.contains(pe.getValue().tolowerCase())) {
                    sc.isSelected = true;
                    //REF-2114
                    relatedMappingController.isAttributeSelected = true;
                } else {
                    sc.isSelected = false;
                }
                relatedMappingController.searchResults.add(sc);
            }
        }
        
        if (fieldMapCustom.containsKey(relatedMappingController.attMapping.Field_Api_Name__c.toLowerCase())) {
            
            if (selectedValues.size() > 0 && !relatedMappingController.isFieldPicklistType) {
                String query = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c 
                                + ' WHERE ' + attMapping.Field_Api_Name__c + ' IN :relatedObjectIds';
                Set<String> duplicateCheck = new Set<String>();
                
                //changes regarding #722
                for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(query, attMapping, selectedValues)) {
                    
                    if (!duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                        duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
                        SearchRelatedMappingRecorsController.searchClass sc = new SearchRelatedMappingRecorsController.searchClass(
                                                        String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')));
                        sc.isSelected = true;
                        //REF-2114
                        relatedMappingController.isAttributeSelected = true;
                        relatedMappingController.searchResults.add(sc);
                    }
                }
            } else if (!relatedMappingController.isFieldPicklistType) {
                String dynamicQuery = ''; 
                                    
                Set<String> duplicateCheck = new Set<String>();
                if (attMapping.Object__c == ConstantsController.REFERENCE_PROFILE) {
                    
                    if (attMapping.Related_Object__c == 'Account') {
                        dynamicQuery = 'SELECT Id, Account__c, Account__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                                + ' WHERE Contact__c = null AND Account__c != null AND Account__r.' + attMapping.Field_Api_Name__c + ' != null '
                                + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                                + '\' AND Referenceability_Status__c != null LIMIT ' + limits.getLimitQueryRows();
                        
                        for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(dynamicQuery, attMapping, new Set<String>())) {
                            
                            if (!duplicateCheck.contains(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                                duplicateCheck.add(String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
                                SearchRelatedMappingRecorsController.searchClass sc = new SearchRelatedMappingRecorsController.searchClass(
                                                                    String.valueOf(so.getSObject('Account__r').get(attMapping.Field_Api_Name__c)), 
                                                                    String.valueOf(so.get('Account__c')));
                                relatedMappingController.searchResults.add(sc);
                            }
                            
                            if (relatedMappingController.searchResults.size() == 200) {
                                relatedMappingController.hasBulkRecords = true;
                                break;
                            }
                        }
                    } else if (attMapping.Related_Object__c == 'Contact') {
                        dynamicQuery = 'SELECT Id, Contact__c, Contact__r.Email, Contact__r.' + attMapping.Field_Api_Name__c + ' FROM Reference_Basic_Information__c '
                                + ' WHERE Contact__c != null AND Account__c != null AND Contact__r.' + attMapping.Field_Api_Name__c + ' != null '
                                + 'AND Is_Referenceable__c = true AND Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
                                + '\' AND Referenceability_Status__c != null LIMIT ' + limits.getLimitQueryRows();
                                
                        for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(dynamicQuery, attMapping, new Set<String>())) {
                        
                            if (!duplicateCheck.contains(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                                duplicateCheck.add(String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)).tolowerCase());
                                SearchRelatedMappingRecorsController.searchClass sc = new SearchRelatedMappingRecorsController.searchClass(
                                                                    String.valueOf(so.getSObject('Contact__r').get(attMapping.Field_Api_Name__c)), 
                                                                    String.valueOf(so.get('Contact__c')));
                                relatedMappingController.searchResults.add(sc);
                            }
                            
                            if (relatedMappingController.searchResults.size() == 200) {
                                relatedMappingController.hasBulkRecords = true;
                                break;
                            }
                        }
                    }
                } else {
                    dynamicQuery = 'SELECT Id,' + attMapping.Field_Api_Name__c + ' FROM ' + attMapping.Related_Object__c 
                                    + ' WHERE ' + attMapping.Field_Api_Name__c + ' != null ORDER BY ' + attMapping.Field_Api_Name__c + ' LIMIT 5000'; 
                                    //+ limits.getLimitQueryRows() + ' Offset 2000';//changes regarding #722
                    //changes regarding #722
                    for (Sobject so : WithoutSharingHelperController.getRelatedMappingIds(dynamicQuery, attMapping, new Set<String>())) {
                        
                        if (!duplicateCheck.contains(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase())) {
                            duplicateCheck.add(String.valueOf(so.get(attMapping.Field_Api_Name__c)).tolowerCase());
                            SearchRelatedMappingRecorsController.searchClass sc = new SearchRelatedMappingRecorsController.searchClass(
                                                                String.valueOf(so.get(attMapping.Field_Api_Name__c)), String.valueOf(so.get('Id')));
                            relatedMappingController.searchResults.add(sc);
                        }
                        
                        if (relatedMappingController.searchResults.size() == 200) {
                            relatedMappingController.hasBulkRecords = true;
                            break;
                        }
                    }
                }
            }
        }
        relatedMappingController.searchResults.sort();
           
        if (relatedMappingController.searchResults.size() < 200) { 
            relatedMappingController.showSearchBox = false;   
        }
        return Page.AttributeMappingResults;
    }

    /**
     * Method to search text 
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference search() {
        try {
            accountSearch.showMoreAccountRecords = false;
            contactSearch.showMoreContactRecords = false;
            contentSearch.showMoreContentRecords = false;
            //Reset Account Contact & Contents
            resetAllObjects();
            return null;
        } catch (Exception e) {
            ApexPages.addmessages(e);
            return null;
        }
    }

    /**
     * Method to go Referencibilty Results Page
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference goToReferencibiltyresults() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        return Page.Referencibiltyresults;
    }

    /**
     * Method to go Content Types Result Page
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference goToContentTypeResults() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        return Page.ContentTypeResults;
    }

    /**
     * Method to go Content Language Result Page
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference goToContentLanguageResults() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        return Page.ContentLanguageResults;
    }

    /**
     * Method to go Attribute Result Page
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference goToAttributeResults() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        return Page.AttributeResults;
    }

    /**
     * Method to go ViewAllFilterResults Page
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference goToViewAllFilterResults() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        Savepoint sp = Database.setSavepoint();
        try {
            ConstantsController.shouldDataMappingProcessed = true;
            
            for (Data_Mapping__c dm : filterList) {
                dm.Required__c = false;
            }
            filterList = WithoutSharingHelperController.upsertDataMappingsInRefSearch(filterList);
            
            for (Data_Mapping__c dm : [SELECT Field_API_Name__c FROM Data_Mapping__c WHERE From_Mapping__c = true]) {
                
                if (dm.Field_API_Name__c != null && !attributeWrapper.mapAllAttributesLabel.containsKey(dm.Field_API_Name__c)) {
                    attributeWrapper.mapAllAttributesLabel.put(dm.Field_API_Name__c, new List<AttributeWrapper.AttributesLabelWrapper>());
                    
                    if (!attributeWrapper.dependentBooleanMap.containsKey(dm.Field_API_Name__c)) {
                        attributeWrapper.dependentBooleanMap.put(dm.Field_API_Name__c, new AttributeWrapper.DependecyWrapper(attributeWrapper.mapAllAttributesLabel.get(dm.Field_API_Name__c).size()));
                    } 
                }
            }
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
        return Page.ViewAllFilterResults;
    }
    
    /**
     * Method to discard the selection of related mapped attribute
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public pageReference dontSaveTheSelections() {
        filterlogics = new Map<String, FilterLogicWrapper>();
        filterlogics.putAll(tempFilterLogicList);
        //changes related to #864
        /*if (pageNameRedirection.toLowerCase().contains('rfsearchpagelead')) {
            return Page.RfSearchPageLead;
        }*/
        return Page.RfSearchPage;
    }

    /**
     * Method called from Done button on AttributeResults Page & Referencibilty Results Page & return Search Page
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference backToSearch() {
        //Reset Account Contact & Contents
        resetAllObjects();
        //changes related to #864
        /*if (pageNameRedirection.toLowerCase().contains('rfsearchpagelead')) {
            return Page.RfSearchPageLead;
        }*/
        return Page.RfSearchPage;
    }

    /**
     * Method to go back on refsearch from Invitation
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public Pagereference backToSearchFromInvitation() {
        //Reset Account Contact & Contents
        resetAllObjects();
        //changes related to #864
        /*if (pageNameRedirection.toLowerCase().contains('rfsearchpagelead')) {
            String parameters = '';
            
            if (leadId != '' && leadId != null && leadId.trim().length() != 0) {
                parameters = '?leadId=' + leadId;
            }
            PageReference ReturnPage = new PageReference(Page.RfSearchPageLead.geturl() + parameters);
            ReturnPage.setRedirect(true);
            return ReturnPage;
        }*/

        String parameters = '';
        
        if (opportunityId != '' && opportunityId != null && opportunityId.trim().length() != 0) {
            parameters = '?OpportunityId=' + opportunityId;
        }
        
        if (caseId != '' && caseId != null && caseId.trim().length() != 0) {
            parameters = '?caseId=' + caseId;
        }
        
        //regarding ticket #809
        if (leadId != '' && leadId != null && leadId.trim().length() != 0) {
            parameters = '?leadId=' + leadId;
            if (!fromLead) {
                parameters += '&fromLead=false';
            } else if (fromLead) {
                parameters += '&fromLead=true';
            }
        }
        
        if (forAccount == 'false') {
            parameters += '&forAccount=false';
        } else if (forAccount == 'true') {
            parameters += '&forAccount=true';
        }
        
        if (forContent == 'false') {
            parameters += '&forContent=false';
        } else if (forContent == 'true') {
            parameters += '&forContent=true';
        }
        
        //re #971 added a prefilter parameter
        if (parameters != '') {
            parameters += '&preFilter=' + preFilterForRedirection;
            parameters += '&helpoverlay=false';
        } else {
        	parameters = '?helpoverlay=false';
        }
        PageReference ReturnPage = new PageReference(Page.RfSearchPage.geturl() + parameters);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to clear all Attribute Types & Referenceability Types
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void clearFilters() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        //Clear shareable
        contentSearch.sharableContent = '';
        relatedMappingController.mappingSelectedValues = new Map<String, List<String>> ();
        relatedMappingController.mappingSelectedValuesLabel = new Map<String, List<String>> ();
        relatedMappingController.mappingRelatedContentIds = new Map<String, Set<String>>();
        relatedMappingController.mappingRelatedAccountIds = new Map<String, Set<String>>();
        relatedMappingController.mappingRelatedContactIds = new Map<String, Set<String>>();
        //clear new map related to #639
        relatedMappingController.mappingAccountIds = new Map<String, Set<String>>();
        relatedMappingController.mappingContactIds = new Map<String, Set<String>>();
        attributeResults = new Map<String, Attribute_Mapping__c>();

        for (Attribute_Mapping__c attMap : WithoutSharingHelperController.getAttributeMappingsForRefSearch()) {
                            
            if (!relatedMappingController.mappingSelectedValues.containsKey(attMap.Id)) {
                relatedMappingController.mappingSelectedValues.put(attMap.Id, new List<String>());
                relatedMappingController.mappingSelectedValuesLabel.put(attMap.Id, new List<String>());
            }
            attributeResults.put(attMap.Id, attMap);
        }
        //Clear Referenceability Types
        referenceabilityWrapper.selectedReferenceabilityTypes.clear();
        referenceabilityWrapper.referenceabilityTypeWrapper = null;
        referenceabilityWrapper.mapReferenceabilityTypeWrapper = null;

        //Clear Attribute Types
        for (String str : attributeWrapper.mapAttributesLabels.keySet()) {
            attributeWrapper.mapAttributesLabels.get(str).clear();
        }
        
        for (String strAll : attributeWrapper.mapAllAttributesLabel.keySet()) {
            
            for (attributeWrapper.AttributesLabelWrapper alw : attributeWrapper.mapAllAttributesLabel.get(strAll)) {
                alw.fontWeight = ConstantsController.NORMAL;
                alw.show = true;
            }
            if (!attributeWrapper.dependentBooleanMap.containsKey(strAll)) {
                attributeWrapper.dependentBooleanMap.put(strAll, new AttributeWrapper.DependecyWrapper(attributeWrapper.mapAllAttributesLabel.get(strAll).size()));
            } 
            attributeWrapper.dependentBooleanMap.get(strAll).anyAttrHidden = false;
            attributeWrapper.dependentBooleanMap.get(strAll).size = attributeWrapper.mapAllAttributesLabel.get(strAll).size();
        }

        //Clear Content Languages
        contentSearch.selectedContentTypes.clear();
        contentSearch.contentTypes = null;
        contentSearch.mapContentTypes = null;

        //Clear Content Types
        contentSearch.selectedContentLanguages.clear();
        contentSearch.contentLanguages = null;
        contentSearch.mapContentLanguages = null;

        //Reset Account Contact & Contents
        resetAllObjects();

        //re #595 R18.46 - MOD –clicking “Clear All” clears all Filters AND clears any Text search.
        tempTextValue = '';
        inputTextValue = '';
    }

    /**
     * Method to Reset Account Contact & Contents
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void resetAllObjects() {
        accountSearch.reset();
        contactSearch.reset();
        contentSearch.reset();
        //REF-2114
        relatedMappingController.isSearchedRecords = false;
        relatedMappingController.isAttributeSelected = false;
        relatedMappingController.isHelpoverlay = true;
        invitationcontroller.reset();
    }

    /**
     * Method to Clear Referenciability
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void ClearInternalReferenciability() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        referenceabilityWrapper.clearAllReferenceabilityTypes();
        resetAllObjects();
    }
    
    /**
     * Method to clear selected attribute mapping
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void ClearMappings() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        relatedMappingController.mappingSelectedValues.put(relatedMappingController.attributeMappingId, new List<String>());
        relatedMappingController.mappingSelectedValuesLabel.put(relatedMappingController.attributeMappingId, new List<String>());
        
        if (relatedMappingController.mappingRelatedContentIds.containsKey(relatedMappingController.attributeMappingId)) {
            relatedMappingController.mappingRelatedContentIds.put(relatedMappingController.attributeMappingId, new Set<String>());
        }
        
        if (relatedMappingController.mappingRelatedAccountIds.containsKey(relatedMappingController.attributeMappingId)) {
            relatedMappingController.mappingRelatedAccountIds.put(relatedMappingController.attributeMappingId, new Set<String>());
        }
        
        if (relatedMappingController.mappingRelatedContactIds.containsKey(relatedMappingController.attributeMappingId)) {
            relatedMappingController.mappingRelatedContactIds.put(relatedMappingController.attributeMappingId, new Set<String>());
        }
        
        //clear new map related to #639
        if (relatedMappingController.mappingAccountIds.containsKey(relatedMappingController.attributeMappingId)) {
            relatedMappingController.mappingAccountIds.put(relatedMappingController.attributeMappingId, new Set<String>());
        }
        
        //clear new map related to #639
        if (relatedMappingController.mappingContactIds.containsKey(relatedMappingController.attributeMappingId)) {
            relatedMappingController.mappingContactIds.put(relatedMappingController.attributeMappingId, new Set<String>());
        }
        relatedMappingController.mappingAccountIds.remove(relatedMappingController.attributeMappingId);
        relatedMappingController.mappingContactIds.remove(relatedMappingController.attributeMappingId);
        relatedMappingController.mappingRelatedAccountIds.remove(relatedMappingController.attributeMappingId);
        relatedMappingController.mappingRelatedContactIds.remove(relatedMappingController.attributeMappingId);
        relatedMappingController.mappingRelatedContentIds.remove(relatedMappingController.attributeMappingId);
        resetAllObjects();
    }

    /**
     * Method to clear attributes
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void ClearInternalAttribute() {
        showOveray = false;
        isUpdateRefSearchUsageCount = false;
        attributeWrapper.clearSelectedAttributeTypes();
        resetAllObjects();
    }
    
    /**
     * Method for select & Continue Button use in self Service 
     * Modified By: Rekha Jangir @Jan/11/2017
     */ 
    public PageReference selectAndContinue() {
        String accountSelected = '';
        
        if (selectedIds != null && selectedIds != '') {
            accountSelected = selectedIds;
        }
        String parameters = '?AccoutsIDs=' + accountSelected;
        
        if (opportunityId.trim().length() != 0 && opportunityId != '') {
            parameters += '&OpportunityId=' + opportunityId;
        } else if (caseId.trim().length() != 0 && caseId != '') {
            parameters += '&caseId=' + caseId;
        //regarding ticket #809
        } else if (leadId.trim().length() != 0 && leadId != '') {
            parameters = '&leadId=' + leadId;
        }
        //for #655 send prefilter value to request page
        parameters += '&preFilter=' + preFilterForRedirection;
        PageReference ReturnPage = new PageReference(Page.ReferenceRequest.geturl() + parametersWithAccount(true));
        return ReturnPage;
    }
    
    /**
     * Method to discard selected Accounts 
     * Modified By: Rekha Jangir @Jan/12/2017
     */ 
    public PageReference discardReqAccount() {
        PageReference ReturnPage = new PageReference(Page.ReferenceUseRequest.geturl() + parametersWithAccount(false));
        return ReturnPage;
    }

    /**
     * Method to keep selected Accounts  
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public PageReference keepReqAccount() {
        PageReference ReturnPage = new PageReference(Page.ReferenceUseRequest.geturl() + parametersWithAccount(true));
        return ReturnPage;
    }
    
    /**
     * Method to generate url with parameters
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    private String parametersWithAccount(Boolean isAccountSelected) {

        String parameters = '';
        
        if (opportunityId.trim().length() != 0 && opportunityId != '') {
            parameters = '?OpportunityId=' + opportunityId;
        } else if (caseId.trim().length() != 0 && caseId != '') {
            parameters = '?caseId=' + caseId;
        //regarding ticket #809
        } else if (leadId.trim().length() != 0 && leadId != '') {
            parameters = '?leadId=' + leadId;
        }
        
        if (forAccount == 'false') {
            parameters += '&forAccount=' + false;
        } else if (forAccount == 'true') {
            parameters += '&forAccount=' + true;
        }
        
        if (forContent == 'false') {
            parameters += '&forContent=' + false;
        } else if (forContent == 'true') {
            parameters += '&forContent=' + true;
        }

        if (isAccountSelected) {
            String accountSelected = '';
            
            if (selectedIds != null && selectedIds != '') {
                accountSelected = selectedIds;
            }
            
            if (accountSelected == '') {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, label.Select_atleast_one_account_from_Request_Details));
                return '';
            }
            parameters = (parameters != '' ? parameters + '&AccoutsIDs=' + accountSelected : '?AccoutsIDs=' + accountSelected);
        }
        //for #655 send prefilter value to request page
        parameters = (parameters != '' ? parameters + '&preFilter=' + preFilterForRedirection : '?preFilter=' + preFilterForRedirection);
        return parameters;
    }
    
    /**
     * Method to Share Files
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public PageReference shareContents() {
        showOveray = false;        
        isUpdateRefSearchUsageCount = false;     
        invitationcontroller.defaultExpirationDays = (cs.Default_Expiration_Days__c != null ? cs.Default_Expiration_Days__c : 0);
        invitationcontroller.maximumExpirationDays = (cs.Maximum_Expiration_Days__c != null ? cs.Maximum_Expiration_Days__c : 0);
        
        if (invitationcontroller.showShareButton) {
            invitationcontroller.onLoad();
        } else {
            showInviationOveray = false;
        }
        contentSearch.showAlertMessage = false;
        invitationcontroller.selectedRefContents = '';
        
        if (selectedContentCol != null && selectedContentCol != '') {
            
            for (Related_Reference_Content__c rrcObj : [SELECT Id, Reference_Content__c FROM Related_Reference_Content__c 
                                        WHERE Content_Collection__c = :selectedContentCol AND Reference_Content__r.Content_Status__c = 'Active']) {
                
                if (invitationcontroller.selectedRefContents == '') {
                    invitationcontroller.selectedRefContents = rrcObj.Reference_Content__c;
                } else {
                    invitationcontroller.selectedRefContents = invitationcontroller.selectedRefContents + ',' + rrcObj.Reference_Content__c;
                }
            }
        }
        
        if (contentSearch.selectContentDocumentId != '' && contentSearch.selectContentDocumentId != null) {
            List<String> idSetContent = contentSearch.selectContentDocumentId.split(',');
            List<Id>idList = new List<Id>((List<Id>) idSetContent);
            Set<Id> idSetC = new Set<Id>();
            idSetC.addAll(idList);
            contentSearch.isContentShared = true;  
            List<ConetntWrapper> contList = contentSearch.getContentsNavigation(idSetC);
            
            for (ConetntWrapper contentWrap : contList) {
                
                if (invitationcontroller.selectedRefContents == '') {
                    invitationcontroller.selectedRefContents = contentWrap.refContent.Id;
                } else {
                    invitationcontroller.selectedRefContents = invitationcontroller.selectedRefContents + ',' + contentWrap.refContent.Id;
                }
            }
        } else if (contentSearch.selectContentDocumentId == null) {
            
            for (String accId : contentSearch.selectedContentIdSet) {
                
                if (!invitationcontroller.selectedRefContents.contains(accId)) {
                    
                    if (invitationcontroller.selectedRefContents == '') {
                        invitationcontroller.selectedRefContents = accId;
                    } else {
                        invitationcontroller.selectedRefContents = invitationcontroller.selectedRefContents + ',' + accId;
                    }
                }
            }
        }
        isContentCollection = false;
        
        if (invitationcontroller.selectedRefContents == '' && contentSearch.selectContentDocumentId == '') {
            contentSearch.selectedContentIdSet = new Set<String>();
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.Select_Atleast_One_Content));
            return null;
        } else { 
             // #496- POSSIBLE MOD - Internal Content for Download  
            List<Id>idList = new List<Id>((List<Id>) invitationcontroller.selectedRefContents.split(','));
            Set<Id> idSetC = new Set<Id>();
            idSetC.addAll(idList);  
            List<Reference_Content__c> lstRefContent = [SELECT Id From Reference_Content__c WHERE Id  IN :idSetC AND Internal_Use__c = true LIMIT 1];
               
            if (lstRefContent.size() > 0) {
                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.Internal_Content_Share));
                return null;
            } 
            
            String parameters = '';
            
            if (opportunityId.trim().length() != 0 && opportunityId != '') {
                invitationcontroller.opportunityId = opportunityId;
                invitationcontroller.forAccount = forAccount;
                invitationcontroller.forContent = forContent;
            }
            
            if (caseId.trim().length() != 0 && caseId != '') {
                invitationcontroller.caseId = caseId;
                invitationcontroller.forAccount = forAccount;
                invitationcontroller.forContent = forContent;
            }
            
            //regarding ticket #809
            if (leadId.trim().length() != 0 && leadId != '') {
                invitationcontroller.leadId = leadId;
                invitationcontroller.fromLead = fromLead ? 'true' : 'false';
                invitationcontroller.forAccount = forAccount;
                invitationcontroller.forContent = forContent;
            }
            invitationcontroller.pageUrl = pageNameRedirection;
            invitationcontroller.isRefcontentBlock = true;
            invitationcontroller.refresh();
            selectedContentCol = '';
            PageReference ReturnPage = new PageReference(Page.Invitation_New.geturl() + parameters);
            return ReturnPage;
        }
    }
    
    /**
     * Method to search invitation
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public Pagereference invitationToSearch() {
        invitationcontroller.showRefContents();
        invitationcontroller.showShareButton = false;
        contentSearch.cs = cs;
        
        for (Integer pageNo : contentSearch.mapContent.keySet()) {
            List<ConetntWrapper> contList = contentSearch.getContentsNavigation(contentSearch.mapContent.get(pageNo));
            
            for (ConetntWrapper contentWrap : contList) {
                contentWrap.isSelected = (invitationcontroller.contentIds.contains(contentWrap.refContent.Id) ? true : false);
            }
        }
        contentSearch.selectedContentIdSet.clear();
        contentSearch.selectedContentIdSet.addAll(invitationcontroller.contentIds);
        contentSearch.selectContentDocumentId = '';
        
        for (String id : invitationcontroller.contentIds) {
            
            if (contentSearch.selectContentDocumentId == '') {
                contentSearch.selectContentDocumentId = id;
            } else {
                contentSearch.selectContentDocumentId = contentSearch.selectContentDocumentId + ',' + id;
            }
        }
        //changes related to #864
        /*if (pageNameRedirection.toLowerCase().contains('rfsearchpagelead')) {
            return Page.RfSearchPageLead;
        }*/
        return Page.RfSearchPage;
    }
    
    /**
     * Method to create content collection
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public Pagereference createCollection() {
        try {
            
            Set<Id> refSet = new Set<Id>();
            Set<Id> idSetC = null;
            selectedContentCol = '';
            
            if (selectedCollection != null && selectedCollection != '') {
                selectedContentCol = selectedCollection;
            }
                
            if (collectionName != null && collectionName != '' && checkPermissionsOnCollection()) {
                Boolean flag = false;
                
                if (contentSearch.selectContentDocumentId != '') {
                    flag = true;
                    List<String> idSetContent = contentSearch.selectContentDocumentId.split(',');
                    List<Id> idList = new List<Id>((List<Id>) idSetContent);
                    idSetC = new Set<Id>();
                    idSetC.addAll(idList);
                }

                if (contentSearch.selectedContentIdSet.size() > 0) {
                    flag = true;
                }
                
                if (!flag) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.Select_Atleast_One_Content));
                    return null;
                }
                List<Related_Reference_Content__c> rrcList = new List<Related_Reference_Content__c>();
                Content_Collection__c contentCollection = new Content_Collection__c(Collection__c = collectionName, Active__c = true);
                insert contentCollection;
                
                for (Integer pageNo : contentSearch.mapContent.keySet()) {
                    List<ConetntWrapper> contList = contentSearch.getContentsNavigation(contentSearch.mapContent.get(pageNo));
                    
                    for (ConetntWrapper contentWrap : contList) {
                        
                        if (contentWrap.isSelected && !contentSearch.selectedContentIdSet.contains(contentWrap.refContent.Id) 
                                        && !refSet.contains(contentWrap.refContent.Id)) {
                            Related_Reference_Content__c rrcObj = new Related_Reference_Content__c(Content_Collection__c = contentCollection.Id, 
                                                    Reference_Content__c = contentWrap.refContent.Id);
                            refSet.add(contentWrap.refContent.Id);
                            rrcList.add(rrcObj);
                        }
                    }
                }
                
                if (contentSearch.selectContentDocumentId != '') {
                    
                    for (String refId : idSetC) {
                        
                        if (!refSet.contains(refId)) {
                            Related_Reference_Content__c rrcObj = new Related_Reference_Content__c(Content_Collection__c = contentCollection.Id, 
                                                        Reference_Content__c = refId);
                            refSet.add(refId);
                            rrcList.add(rrcObj);
                        }
                    }
                }
                
                //re #346 - Check for Content Document Id
                if (contentSearch.selectContentDocumentId == '') {
                
                    for (String refId : contentSearch.selectedContentIdSet) {
                        
                        if (!refSet.contains(refId)) {
                            Related_Reference_Content__c rrcObj = new Related_Reference_Content__c(Content_Collection__c = contentCollection.Id, 
                                                        Reference_Content__c = refId);
                            refSet.add(refId);
                            rrcList.add(rrcObj);
                        }
                    }
                }
                
                if (rrcList.size() > 0) {
                    insert rrcList;
                }
                collectionName = '';
            }
        } catch (Exception e) {
            ApexPages.addmessages(e);
        }
        return null;
    }

    /**
     * Method to check Permission on Export Field
     */
    private static Boolean hasPermissionOnEnableRefSearchExport() { 
        Boolean permissionGranted = false;
        Schema.DescribeSObjectResult sObj = Custom_Settings__c.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObj.fields.getMap();
        Schema.DescribeFieldResult sField = fieldMap.get(UtilityController.appNamespace() + 'Enable_Ref_Search_Export__c').getDescribe();
        
        if (sObj.isAccessible() && sField.isAccessible()) {
            permissionGranted = true;       
        } 
        return permissionGranted;                               
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissionsOnCollection() { 
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Content_Collection__c', new Set<String> { 
                                                UtilityController.appNamespace() + 'Collection__c',
                                                UtilityController.appNamespace() + 'Active__c'}); 
                                                
        fieldMap.put(UtilityController.appNamespace() + 'Related_Reference_Content__c', new Set<String> { 
                                                UtilityController.appNamespace() + 'Content_Collection__c',
                                                UtilityController.appNamespace() + 'Reference_Content__c'}); 
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false); 
    }
    /**
     * Getter for content collections
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public List<SelectOption> contentCollections {
        get {
            contentCollections = new List<SelectOption>();
            contentCollections.add(new SelectOption('', '<SELECT>'));
            
            for (Content_Collection__c cc : WithoutSharingHelperController.getContentCollections()) {
                Boolean flag = false;
                
                for (Related_Reference_Content__c rrc : cc.Related_Reference_Contents__r) {
                    flag = true;
                    break;
                }
                
                if (flag) {
                    contentCollections.add(new SelectOption(cc.Id, cc.Collection__c));
                }
            }
            return contentCollections;
        }
        set;
    }
    /**
     * Method to get minimum stage value error
     * Modified By: Rekha Jangir @Jan/11/2017
     */
    public void checkForMinimumSalesStage(String minimumStageValue) {
        Decimal minimumStageCount, opporunityStageCount, currentCount;
        
        if (oppObj != null) {
            List<String> lstPickvals = new List<String>();
            Schema.SObjectType targetType = CRUDAndFLSCheckController.sObjectsMap.get('Opportunity'); //FROM the Object Api name retrieving the SObject
            Sobject objectName = targetType.newSObject();
            Schema.sObjectType sobjectType = objectName.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap(); //get a map of fields for the passed sobject
            //grab the list of picklist values for the passed field on the sobject
            List<Schema.PicklistEntry> pickListValues = fieldMap.get('StageName').getDescribe().getPickListValues(); 
            minimumStageCount = opporunityStageCount = currentCount = 0;

            for (Schema.PicklistEntry a : pickListValues) { //for all values in the picklist list

                if (minimumStageValue == a.getValue()) {
                    minimumStageCount = currentCount;
                }
                
                if (oppObj.StageName == a.getValue()) {
                    opporunityStageCount = currentCount;
                }
                ++currentCount;
            }

            if (opporunityStageCount < minimumStageCount) {
                minimumStageError = label.MinimumSalesStage.replace('@@@', minimumStageValue);
            }
        }
    }
    
    /**
     * Method to setup all account requests and unspecified requests 
     * Modified By: Rekha Jangir @Jan/12/2017
     */ 
    private void setReqData() {
        showContact = true;
        showAccount = true;
        showHitContacts = true;
        refMatch = true;
        ismakeAccountRPMAccessed = false;
        selectedaccountReq = '';
        rep2repId = '';
        updateReqList = new Set<Id>();
        String reqId = ApexPages.currentPage().getParameters().get('RefRequestId');
        List<Reference_Request__c> tempReqList = [SELECT Requester__c, Case__c, Project_Type__c, Opportunity__r.Name, Opportunity__r.AccountId, Opportunity__c, 
                Name, (SELECT Name, CreatedById, Deadline__c, Request_Notes__c, Reference_Type_Needed__c, Unspecified_Request_Status__c, Notes__c 
                FROM Unspecified_Requests__r WHERE Specified_Account__c = null ORDER BY Deadline__c DESC),
                (SELECT Name, CreatedById, Account__c, Request_Notes__c, Deadline__c, Managed_Request__c, Approve_Deny_Notes__c,
                Project_Owner__c, Process__c, Reference_Type_Needed__c, Reference_Type_Needed__r.Name, Account__r.Name,
                Account_Request_Status__c, Reference_Owner__c FROM Reference_Request_Accounts__r WHERE Reference_Use__c = false ORDER BY Deadline__c DESC) 
                FROM Reference_Request__c WHERE Id = :reqId];
        
        if (tempReqList.size() > 0) {
            request = tempReqList[0];
            accountSearch.reqId = request.Id;
            contactSearch.reqId = request.Id;
            
            if (request.Project_Type__c == 'Candidate') {
                accountSearch.selectedType = 'Candidate';
                contactSearch.selectedType = 'Candidate';
            }
            
            if (request.Project_Type__c == null) {
                request.Project_Type__c = 'Member';
            }
        } else {
            return;
        }
        List<Referenceability_Type__c> listOfReferenceabilities = [SELECT Name, Id, Note__c, max_accounts_per_request_type__c, min_lead_time_per_request_type__c 
                                        FROM Referenceability_Type__c WHERE Visible__c = true ORDER BY Name LIMIT :limits.getLimitQueryRows()];
        mapReferenceType = new Map<String, Referenceability_Type__c>();
        
        for (Referenceability_Type__c ref : listOfReferenceabilities) {
            mapReferenceType.put(ref.Id, ref);
        }
        List<Reference_Request_Label__c> refReqLabelList = [SELECT Id, Name, Label__c, Reference_Request__c, 
                                    (SELECT Attribute__c, Reference_Request_Label__c FROM Reference_Request_Label_Attributes__r) FROM Reference_Request_Label__c 
                                    WHERE Reference_Request__c = :request.Id];
        Map<String, Set<String>> labelAttrMap = new Map<String, Set<String>>();
        refReqContactMap = new Map<String, String>();
        List<Reference_Request_Account__c> refReqAccList = WithoutSharingHelperController.getRRARecords(request.Reference_Request_Accounts__r);
        String contants = '';
        
        for (Reference_Request_Account__c reqAcc : refReqAccList) {
            contants = '';
            
            if (!refReqContactMap.containsKey(reqAcc.Id)) {
                refReqContactMap.put(reqAcc.Id, '*');
            }
            
            for (Reference_Request_Account_Contact__c con : reqAcc.Reference_Request_Account_Contacts__r) {

                if (con.Contact__c != null) {
                    contants = (contants != '' ? refReqContactMap.get(reqAcc.Id) + ', ' + con.Contact__r.Name : con.Contact__r.Name);
                    refReqContactMap.put(reqAcc.Id, contants);
                    
                    if (reqAcc.Approve_Deny_Notes__c == null || reqAcc.Approve_Deny_Notes__c == '' || 
                            (reqAcc.Approve_Deny_Notes__c != null && !reqAcc.Approve_Deny_Notes__c.contains('Contact:'))) {
                        reqAcc.Approve_Deny_Notes__c = 'Contact: ' + con.Contact__r.Name + 'Phone: ' + (con.Contact__r.Phone != null ? con.Contact__r.Phone : '') 
                                                        + 'Email: ' + (con.Contact__r.Email != null ? con.Contact__r.Email : '') + '\n' 
                                                        + (reqAcc.Approve_Deny_Notes__c != null ? reqAcc.Approve_Deny_Notes__c : '');
                    }
                    noteMap.put(reqAcc.Id, reqAcc.Approve_Deny_Notes__c);
                }
            }
        }
        
        if (!isFilterReload) {
            
            for (Reference_Request_Label__c refReq : refReqLabelList) {
                
                if (!labelAttrMap.containsKey(refReq.Label__c)) {
                    labelAttrMap.put(refReq.Label__c, new Set<String>());
                }
                
                for (Reference_Request_Label_Attribute__c refLA : refReq.Reference_Request_Label_Attributes__r) {
                    labelAttrMap.get(refReq.Label__c).add(refLA.Attribute__c);
                }
            }
            attributeWrapper.setDefaultAttributeLabels(labelAttrMap);
            refTypeIds = new Set<Id>();
            
            for (Reference_Request_Account__c rra : request.Reference_Request_Accounts__r) {
                refTypeIds.add(rra.Reference_Type_Needed__c);
            }
            
            for (Unspecified_Request__c unSpec : request.Unspecified_Requests__r) {
                refTypeIds.add(unSpec.Reference_Type_Needed__c);
            }
            referenceabilityWrapper.setDefaultReferenceabilityType(refTypeIds);
            isFilterReload = true;
        }
    }

    /**
     * Getter for all account requests and unspecified requests 
     * Modified By: Rekha Jangir @Jan/12/2017
     */ 
    public List<ReferenceRequestWrapper> allActiveReq {
        get {
            List<ReferenceRequestWrapper> allActiveReq = new List<ReferenceRequestWrapper>();
            List<ReferenceRequestWrapper> tempActiveReq = new List<ReferenceRequestWrapper>();
            ReferenceRequestWrapper temp;
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Reference_Request_Account__c.fields.getMap();
            List<Schema.PicklistEntry> picklistEntries = fldObjMap.get('Account_Request_Status__c').getDescribe().getPicklistValues();
            //Getting unSpeficified request's state list R15.70 issue
            Map<String, Schema.SObjectField> fldUnScecifiedObjMap = schema.SObjectType.Unspecified_Request__c.fields.getMap();
            List<Schema.PicklistEntry> picklistEntriesUnSceficied = fldUnScecifiedObjMap.get('Unspecified_Request_Status__c').getDescribe().getPicklistValues();
            
            for (Schema.PicklistEntry P : picklistEntriesUnSceficied) {
                
                if (ConstantsController.NO_REFERENCE_MATCH == P.getLabel()) {
                    picklistEntries.add(p);
                }
            }

            if (request != null) {
                
                for (Reference_Request_Account__c rra : request.Reference_Request_Accounts__r) {
                    
                    if (noteMap != null && noteMap.containsKey(rra.Id)) {
                        rra.Approve_Deny_Notes__c = noteMap.get(rra.Id);
                    }
                    
                    if (rra.Managed_Request__c) {
                        allActiveReq.add(new ReferenceRequestWrapper(false, false, request, rra, '', ConstantsController.MANAGED));
                    } else {
                        allActiveReq.add(new ReferenceRequestWrapper(false, false, request, rra, '', ConstantsController.REP2REP));
                        rep2repId += rra.Id + ' ';
                    }
                }
                
                for (Unspecified_Request__c unSpec : request.Unspecified_Requests__r) {
                    allActiveReq.add(new ReferenceRequestWrapper(false, false, request, unSpec, '', ConstantsController.MANAGED));
                }
                
                if (allActiveReq.size() > 2) {
                    
                    for (Integer i = 0; i < allActiveReq.size() - 1; i++) {
                        
                        for (Integer j = i + 1; j < allActiveReq.size(); j++) {
                            
                            if (allActiveReq.get(i).deadline < allActiveReq.get(j).deadline) {
                                temp = allActiveReq.get(i);
                                allActiveReq.set(i, allActiveReq.get(j));
                                allActiveReq.set(j, temp);
                            }
                        }
                    }
                }
                
                for (ReferenceRequestWrapper RRW : allActiveReq) {
                    
                    if (RRW.status == null || RRW.status == '') {
                        tempActiveReq.add(RRW);
                    }
                }
                
                for (Schema.PicklistEntry P : picklistEntries) {
                    
                    for (ReferenceRequestWrapper RRW : allActiveReq) {
                        
                        if (RRW.status == P.getLabel()) {
                            tempActiveReq.add(RRW);
                        }
                    }
                }
            }
            allActiveReq.clear();
            allActiveReq.addAll(tempActiveReq);
            return allActiveReq;
        }
        set;
    }
    
    /**
     * Method to get request details
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public PageReference getSelectedAccReqDetails() {
        Savepoint sp = Database.setSavepoint();
        String recordStatus = '';
        try {
            showPeer2ManagedMessage = false;
            Boolean isUnspecified = false;
            
            for (ReferenceRequestWrapper reqWrap : allActiveReq) {
                
                if (updateReqId != '' && reqWrap.Id == updateReqId) {
                    
                    if (reqWrap.isUr) {
                        isUnspecified = true;
                        
                        if (changeField == 'status') {
                            reqWrap.unSpec.Unspecified_Request_Status__c = statusValue;
                        } else if (changeField == 'deadLine') {
                            reqWrap.unSpec.Deadline__c = date.parse(statusValue);
                        }
                        NoteValue = (reqWrap.unSpec.Notes__c != null ? reqWrap.unSpec.Notes__c : '');
                    } else {
                        
                        if (changeField == 'status') {
                            reqWrap.rra.Account_Request_Status__c = statusValue;
                        } else if (changeField == 'deadLine') {
                            reqWrap.rra.Deadline__c = date.parse(statusValue);
                        } else if (changeField == 'process') {
                            reqWrap.rra.Process__c = statusValue;
                        }
                        statusValue = reqWrap.rra.Process__c;
                        
                        if (reqWrap.rra.Process__c == 'Managed') {
                            reqWrap.rra.Managed_Request__c = true;
                        } else {
                            reqWrap.rra.Managed_Request__c = false;
                        }
                        NoteValue = (tempRRA.Approve_Deny_Notes__c != null ? tempRRA.Approve_Deny_Notes__c : '');
                        recordStatus = reqWrap.rra.Account_Request_Status__c;
                    }
                }
            }
            
            if (updateReqId != null && updateReqId != '') {
                updateReqList.add(updateReqId);
                String contactId = '';
                
                for (ReferenceRequestWrapper reqWrap : allActiveReq) {
                    
                    if (updateReqId != '' && reqWrap.Id == updateReqId && !reqWrap.isUr && reqWrap.rrac.Contact__c != null) {
                        contactId = reqWrap.rrac.Contact__c;
                    }
                }
                List<Reference_Request_Account__c> tempRRAList = [SELECT Account__r.Name, Id, Deadline__c, Reference_Type_Needed__c, Managed_Request__c, 
                                        Account_Request_Status__c, Reference_Request_Additional_Info__r.Id, Account__c, Reference_Type_Needed__r.Name,
                                        Name, Request_Notes__c, Approve_Deny_Notes__c, Project_Owner__c, Project_Owner__r.Name, Process__c
                                        FROM Reference_Request_Account__c WHERE Id = :updateReqId];
                
                if (tempRRAList.size() > 0) {
                    tempRRA = tempRRAList[0];
                    NoteValue = tempRRA.Approve_Deny_Notes__c;

                    if (tempRRA.id == updateReqId && statusValue == ConstantsController.MANAGED && tempRRA.Process__c == ConstantsController.REP2REP) {
                        showPeer2ManagedMessage = true;
                    }
                } else {
                    tempRRA = new Reference_Request_Account__c();
                }
            }
            
            if (isUnspecified) {
                List<Unspecified_Request__c> tempURList = [SELECT Requester__c, Specified_Account__c, Unspecified_Request_Status__c,
                                                    Request_Notes__c, Reference_Type_Needed__c, Deadline__c, Reference_Request__c,
                                                    Reference_Request_Additional_Info__c, Project_Owner__c
                                                    FROM Unspecified_Request__c WHERE Id = :updateReqId];
                
                if (tempURList.size() > 0) {
                    tempRRA = new Reference_Request_Account__c(Account_Request_Status__c = tempURList[0].Unspecified_Request_Status__c,
                        Project_Owner__c = tempURList[0].Project_Owner__c);
                } else {
                    tempRRA = new Reference_Request_Account__c();
                }
            }
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
        return null;
    }
    /**
     * Method to save request list
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public pageReference saveReqList() {
        Savepoint sp = Database.setSavepoint();
        //Variable declared for #255
        Map<Id, Id> mapIds = new Map<Id, Id>();
        List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
        
        try {
            List<Reference_Request_Account__c> updateRefAcc = new List<Reference_Request_Account__c>();
            List<Unspecified_Request__c> updateUnsp = new List<Unspecified_Request__c>();
            List<Task> listTask = new List<Task>();
            List<Reference_Note__c> refNoteList = new List<Reference_Note__c>();
            Map<String, Reference_Basic_Information__c> accountRBImap = new Map<String, Reference_Basic_Information__c>();
            ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST = subjectValue;

            Map<Id, Reference_Request_Account__c> existingRRAs = new Map<Id, Reference_Request_Account__c>(
                                            [SELECT Account__c, Account_Request_Status__c, Deadline__c, Process__c,
                                            Project_Owner__c, Approve_Deny_Notes__c, Reference_Request__c, Requester__c, Reference_Type_Needed__c
                                            FROM Reference_Request_Account__c WHERE Id IN :updateReqList]);

            Map<Id, Unspecified_Request__c> existingURs = new Map<Id, Unspecified_Request__c>([SELECT Requester__c, Specified_Account__c, 
                                            Unspecified_Request_Status__c, Notes__c,Request_Notes__c, Reference_Type_Needed__c, Deadline__c,
                                            Reference_Request__c, Reference_Request_Additional_Info__c, Project_Owner__c
                                            FROM Unspecified_Request__c WHERE Id IN :updateReqList]);
            List<String> accountIdList = new List<String>();

            for (Reference_Request_Account__c rra : existingRRAs.values()) {
                accountIdList.add(rra.Account__c);
            }

            for (Reference_Basic_Information__c rbi : WithoutSharingHelperController.getAccountsRBI(accountIdList)) {
                accountRBImap.put(rbi.Account__r.Id, rbi);
            }

            for (ReferenceRequestWrapper reqWrap : allActiveReq) {

                if (updateReqList.contains(reqWrap.id)) {

                    if (reqWrap.isUR) {
                        updateUnsp.add(reqWrap.unSpec);
                    } else {

                        if (existingRRAs.containsKey(reqWrap.rra.Id)) {

                            if (existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c && reqWrap.rra.Process__c == ConstantsController.REP2REP) {
                                reqWrap.rra.Managed_Request__c = false;

                                if (accountRBImap.containsKey(reqWrap.rra.Account__c)) {
                                    listTask.add(MailChatterController.prepareTask((accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c == null 
                                                                ? accountRBImap.get(reqWrap.rra.Account__c).Account__r.OwnerId : 
                                                                accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c), 
                                                                reqWrap.rra.Account__c, reqWrap.rra.Deadline__c, REFERENCE_REQUEST_TASK_SUBJECT, 
                                                                SPECIFIED_REQUEST_MESSAGE + 
                                                                MailChatterController.prepareChatterEmailMessage(reqWrap.rra.Deadline__c, 
                                                                accountRBImap.get(reqWrap.rra.Account__c).Account__r.Name, 
                                                                mapReferenceType.get(reqWrap.rra.Reference_Type_Needed__c).Name, 
                                                                UtilityController.checkValueOfString(reqWrap.rra.Request_Notes__c)) 
                                                                + APPROVE_DECLINE_TITLE + ': ' + (APPROVE_DECLINE_LINK_URL + reqWrap.rra.Id), ''));
                                }
                            } else if (existingRRAs.get(reqWrap.rra.Id).Account_Request_Status__c != reqWrap.rra.Account_Request_Status__c ||
                                        existingRRAs.get(reqWrap.rra.Id).Deadline__c != reqWrap.rra.Deadline__c ||
                                        existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c ||
                                        existingRRAs.get(reqWrap.rra.Id).Reference_Type_Needed__c != reqWrap.rra.Reference_Type_Needed__c ||
                                        existingRRAs.get(reqWrap.rra.Id).Project_Owner__c != reqWrap.rra.Project_Owner__c ||
                                        (existingRRAs.get(reqWrap.rra.Id).Approve_Deny_Notes__c != reqWrap.rra.Approve_Deny_Notes__c && 
                                        existingRRAs.get(reqWrap.rra.Id).Approve_Deny_Notes__c != null && (reqWrap.rra.Approve_Deny_Notes__c != null 
                                        && reqWrap.rra.Approve_Deny_Notes__c != ''))) {
                                reqWrap.rra.Process__c = ConstantsController.MANAGED;
                                reqWrap.rra.Managed_Request__c = true;
                            }

                            //re #255 - Sales Reward also assign FROM Reference Match page when request completed.
                            if (reqWrap.rra.Account_Request_Status__c == ConstantsController.COMPLETED) {

                                if (RefEdgeEditionFeatures.isBasic == false && cs.Auto_Assign_Sales_Rewards__c 
                                        && cs.Enable_Sales_Rewards_Notification__c == true) {

                                    if (reqWrap.rra.Project_Owner__c != null) {
                                        mapIds.put(reqWrap.rra.Reference_Type_Needed__c, reqWrap.rra.Project_Owner__c);
                                    } else if (reqWrap.rra.Reference_Owner__c != null) {
                                        mapIds.put(reqWrap.rra.Reference_Type_Needed__c, reqWrap.rra.Reference_Owner__c);
                                    } else {
                                        mapIds.put(reqWrap.rra.Reference_Type_Needed__c, accountRBImap.get(reqWrap.rra.Account__c).Account__r.OwnerId);
                                    }
                                }
                            }

                            if (existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c && reqWrap.rra.Process__c == ConstantsController.MANAGED) {
                                reqWrap.rra.Project_Owner__c = userInfo.getUserId();
                            } else if (existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c && 
                                        reqWrap.rra.Process__c == ConstantsController.REP2REP) {
                                reqWrap.rra.Project_Owner__c = (accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c == null 
                                                                ? accountRBImap.get(reqWrap.rra.Account__c).Account__r.OwnerId 
                                                                : accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c);
                            }
                        }

                        updateRefAcc.add(reqWrap.rra);
                    }
                }
            }

            //re #255 - Sales Reward also assign FROM Reference Match page when request completed. 
            if (RefEdgeEditionFeatures.isBasic == false && cs.Auto_Assign_Sales_Rewards__c && cs.Enable_Sales_Rewards_Notification__c == true) {
                Set<Id> kSetIds = mapIds.keySet();
                Set<Id> ownerIds = new Set<Id>();
                // getting All the referencebilaty types -#255 
                Map<Id, Referenceability_Type__c> mapRefType = WithoutSharingHelperController.getSalesPointRefTypesInRefSearch(kSetIds);

                for (Id key : kSetIds) {

                    if (mapRefType != null && mapRefType.containsKey(key)) {
                        //Insert rewards records if Sale reward points not null                  
                        rewardsToBeInsert.add(new Reward__c(Amount__c = mapRefType.get(key).Sales_Point__c, 
                                                Referenceability_Type__c = mapRefType.get(key).Id, Transaction__c = ConstantsController.ISSUE,
                                                RewardDate__c = Date.Today(), User__c = mapIds.get(key)));
                        ownerIds.add(mapIds.get(key));
                    }

                }

                if (rewardsToBeInsert.size() > 0) {
                    UtilityController.isUserProfileExist(ownerIds);
                    WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
                }
            }

            Map<String, Reference_Note__c> noteMap = new Map<String, Reference_Note__c>();

            for (Reference_Note__c note : [SELECT Account_Request__c, Unspecified_Request__c, Note__c, Reference_Request__c 
                                            FROM Reference_Note__c WHERE (Account_Request__c IN :updateReqList OR Unspecified_Request__c IN :updateReqList) 
                                            AND Reference_Request__c = :request.Id]) {
                                                
                if (note.Account_Request__c != null) {
                    noteMap.put(note.Account_Request__c, note);
                } else if (note.Unspecified_Request__c != null) {
                    noteMap.put(note.Unspecified_Request__c, note);
                }
            }

            for (ReferenceRequestWrapper reqWrap : allActiveReq) {

                if (reqWrap.rra != null && existingRRAs != null && existingRRAs.containsKey(reqWrap.rra.Id)) {

                    if (writetoNote && reqWrap.rra.Approve_Deny_Notes__c != null && reqWrap.rra.Approve_Deny_Notes__c != '') {

                        if (noteMap != null && noteMap.containsKey(reqWrap.rra.Id)) {
                            Reference_Note__c tempNote = noteMap.get(reqWrap.rra.Id);
                            tempNote.Note__c = reqWrap.rra.Approve_Deny_Notes__c;
                            refNoteList.add(tempNote);
                        } else {
                            refNoteList.add(new Reference_Note__c(Account_Request__c = reqWrap.rra.Id, Note_Date__c = system.today(), 
                                    Note__c = reqWrap.rra.Approve_Deny_Notes__c, Reference_Request__c = reqWrap.rra.Reference_Request__c));
                        }
                    }
                } else if (reqWrap.unSpec != null && existingURs != null && existingURs.containsKey(reqWrap.unSpec.Id)) {

                    if (writetoNote && reqWrap.unSpec.Notes__c != null && reqWrap.unSpec.Notes__c != '') {

                        if (noteMap != null && noteMap.containsKey(reqWrap.unSpec.Id)) {
                            Reference_Note__c tempNote = noteMap.get(reqWrap.unSpec.Id);
                            tempNote.Note__c = reqWrap.unSpec.Notes__c;
                            refNoteList.add(tempNote);
                        } else {
                            refNoteList.add(new Reference_Note__c(Unspecified_Request__c = reqWrap.unSpec.Id, Note_Date__c = system.today(), 
                                        Note__c = reqWrap.unSpec.Notes__c, Reference_Request__c = reqWrap.unSpec.Reference_Request__c));
                        }
                    }
                }
            }

            updateReqList = new Set<Id>();
            ConstantsController.isNotificationSend = isSend;

            //Insert list of tasks
            if (listTask.size() > 0) {
                listTask = WithoutSharingHelperController.insertTask(listTask);
            }

            for (Reference_Request_Account__c rra : updateRefAcc) {

                for (Task lstTask : listTask) {

                    if (rra.Account__c == lstTask.WhatId) {
                        rra.Task_ID__c = lstTask.Id;
                    }
                }
            }

            if (updateUnsp.size() > 0) {
                update updateUnsp;
            }

            if (updateRefAcc.size() > 0) {
                updateRefAcc = WithoutSharingHelperController.updateRRA(updateRefAcc);
            }

            if (refNoteList.size() > 0) {
                refNoteList = WithoutSharingHelperController.upsertNotes(refNoteList);
            }

            String tempString = '';

            if (tempTextValue == '') {
                tempTextValue = 'zz0a0a0a';
            } else {
                tempString = tempTextValue;
                tempTextValue = '';
            }
            search();
            tempTextValue = tempString;
            search();
            isEdit = false;

            PageReference ReturnPage = new PageReference(Page.rfsearchpage.geturl() + '?isRefMatch=true&RefRequestId=' + request.Id 
                                            + '&activeTab=' + activeTab + '&inlineeditingenable=' + isInlineEditingDisabled);
            ReturnPage.setRedirect(true);

            return ReturnPage;
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
    }
    
    /**
     * Method to cancel request list
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public PageReference cancelReqList() {
        updateReqList = new Set<Id>();
        updatableReq = '';
        isEdit = false;
        PageReference ReturnPage = new PageReference(Page.rfsearchpage.geturl() + '?isRefMatch=true&RefRequestId=' + request.Id 
                                        + '&activeTab=' + activeTab + '&inlineeditingenable=' + isInlineEditingDisabled);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to enable requests to update
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public void enabletoUpdate() {
        
        if (updatableReq != null && updatableReq != '') {
            updateReqList.add(updatableReq);
        }
    }
    
    /**
     * Method to assign Account to a request
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public pagereference assignAccount() {
        assignAccount(false,false);
        return null;
    }

    public void assignAccount(Boolean contactChanged,Boolean isFromContact) {
        if (selectedUnsepReq != null) {
            Id objId = selectedUnsepReq;
            Schema.SObjectType token = objId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            Savepoint sp = Database.setSavepoint();
            try {
                
                if (dr.getName() == UtilityController.appNamespace() + 'Unspecified_Request__c') {
                    unspecReq = [SELECT Id, Name, CreatedById, Request_Notes__c, Deadline__c, Requester__c, Reference_Type_Needed__c, 
                                Unspecified_Request_Status__c, Reference_Request_Additional_Info__c, Project_Owner__c 
                                FROM Unspecified_Request__c WHERE Id = :selectedUnsepReq LIMIT 1];
                    
                    if (request.Project_Type__c == 'Member' && !ismakeAccountRPMAccessed) {
                        List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { selectedacc });
                        makeAccountRPM(accList[0], null);
                    }
                    Reference_Request_Account__c rra = new Reference_Request_Account__c(
                        Account__c = selectedacc,
                        Reference_Request__c = request.Id,
                        Request_Notes__c = unspecReq.Request_Notes__c,
                        Requester__c = unspecReq.Requester__c,
                        Deadline__c = unspecReq.Deadline__c,
                        Managed_Request__c = true,
                        Project_Owner__c = unspecReq.Project_Owner__c,
                        Reference_Type_Needed__c = unspecReq.Reference_Type_Needed__c,
                        Account_Request_Status__c = ConstantsController.IN_PROGRESS,
                        Reference_Request_Additional_Info__c = unspecReq.Reference_Request_Additional_Info__c);
                    rra = WithoutSharingHelperController.upsertRRA(rra);
                    accountReq = rra;
                    ConstantsController.shouldUnspecifiedStatusChange = true;
                    newAccountRequestId = rra.Id;
                    unspecReq.Specified_Account__c = rra.Id;
                    unspecReq.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                    WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> { unspecReq });
                    setReqData();

                } else if (dr.getName() == UtilityController.appNamespace() + 'Reference_Request_Account__c') {
                    accountReq = WithoutSharingHelperController.getAccountRequest(selectedUnsepReq);
                    
                    if (selectedacc != accountReq.Account__c || contactChanged) {
                        
                        if (request.Project_Type__c == 'Member' && !ismakeAccountRPMAccessed) {
                            List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { selectedacc });
                            makeAccountRPM(accList[0], null);
                        }
                        Reference_Request_Account__c newAccountReq = accountReq.clone(false, true);
                        newAccountReq.Account__c = selectedacc;
                        newAccountReq.Managed_Request__c = true;
                        newAccountReq.Process__c = ConstantsController.MANAGED;
                        newAccountReq = WithoutSharingHelperController.upsertRRA(newAccountReq);
                        newAccountRequestId = newAccountReq.Id;
                        accountReq.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                        accountReq = WithoutSharingHelperController.upsertRRA(accountReq);
                        accountReq = newAccountReq;
                        setReqData();
                    } else {
                        if (accountReq.Reference_Request_Account_Contacts__r.size() == 0 && !isFromContact) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.SELECT_DIFFERENT_ACCOUNT));
                        }
                    }
                }
            } catch (Exception e) {
                ApexPages.addmessages(e);
                Database.rollback(sp);
            }
        }
    }
    
    /**
     * Method to assign contact to a account/unspecified request
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public pagereference assignContact() {
        
        if (selectedCon != null) {
            Savepoint sp = Database.setSavepoint();
            
            try {
                Contact con = WithoutSharingHelperController.activateContactRecords(new Set<String> { selectedCon })[0];
                String tempAccId = (contactSearch.accountId != null ? contactSearch.accountId : con.AccountId);
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { tempAccId });
                
                if (request.Project_Type__c == 'Candidate') {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                    && !acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT));
                            return null;
                        }
                    }
                } else {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                && acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT));
                            return null;
                        }
                    }
                }
                Boolean flag = false;
                Boolean contactChanged = false;
                Boolean contactSame = false;
                Reference_Request_Account__c accReq;
                List<Reference_Request_Account__c> refReqAccList = WithoutSharingHelperController.getRRARecords(request.Reference_Request_Accounts__r);
                for (Reference_Request_Account__c rra : refReqAccList) {
                    
                    if (rra.Id == selectedUnsepReq) {
                        
                        if (rra.Account__c == tempAccId && (rra.Reference_Request_Account_Contacts__r.size() != 0 && rra.Reference_Request_Account_Contacts__r[0].Contact__c != selectedCon)) {    
                            makeAccountRPM(null, con);
                            contactChanged = true;
                        } else {
                            makeAccountRPM(accList[0], con);
                        }
                        selectedacc = tempAccId;
                        contactSame = rra.Reference_Request_Account_Contacts__r.size() != 0 && rra.Reference_Request_Account_Contacts__r[0].Contact__c == selectedCon;
                        assignAccount(contactChanged,true);
                        accReq = accountReq;
                        flag = true;
                    }
                }
                
                if (!flag) {
                    selectedacc = tempAccId;
                    makeAccountRPM(accList[0], con);
                    assignAccount(contactChanged,true);
                    accReq = accountReq;
                }
                if (!contactSame) {
                    Reference_Request_Account_Contact__c refReqCon = new Reference_Request_Account_Contact__c(
                    Reference_Request_Account__c = accReq.Id,
                    Contact__c = selectedCon,
                    Contact_Request_Status__c = ConstantsController.IN_PROGRESS,
                    Referenceability_Type__c = accReq.Reference_Type_Needed__c,
                    Project_Owner__c = accReq.Project_Owner__c,
                    Deadline__c = accReq.Deadline__c,
                    Contact_Title__c = con.Title,
                    Contact_Phone__c = con.Phone,
                    Contact_Email__c = con.Email);
                    refReqCon = WithoutSharingHelperController.upsertRRAC(refReqCon);
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a different Contact.'));
                }
                setReqData();
            } catch (Exception e) {
                ApexPages.addmessages(e);
                Database.rollback(sp);
                return null;
            }
        }
        return null;
    }
    
    /**
     * Method to make Account/Contact reference program member
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public void makeAccountRPM(Account acc, Contact con) {
        
        if (request.Project_Type__c == 'Member' && !ismakeAccountRPMAccessed) {
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
            ismakeAccountRPMAccessed = true;
        }
    }
    
    /**
     * Method to search account request 
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public pagereference findAccountofReq() {
        
        if (selectedUnsepReq != null) {
            Id objId = selectedUnsepReq;
            Schema.SObjectType token = objId.getSObjectType();
            Schema.DescribeSObjectResult dr = token.getDescribe();
            
            if (dr.getName() == UtilityController.appNamespace() + 'Reference_Request_Account__c') {
                accountReq = WithoutSharingHelperController.getAccountRequest(selectedUnsepReq);
            }
        }
        contactSearch.accountId = null;
        showContact = true;
        showHitContacts = true;
        showAccount = true;
        return null;
    }
    
    /**
     * Method to show both section account and contact
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public pagereference showAll() {
        contactSearch.accountId = null;
        showContact = true;
        accountSearch.showMoreAccountRecords = false;
        contentSearch.showMoreContentRecords = false;
        showHitContacts = true;
        showAccount = true;
        return null;
    }
    
    /**
     * Method to show only contact section
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public void showContactBlock() {
        contactSearch.mapAccountContact.clear();
        contactSearch.accountContactIds = new Set<String>();
        accountReq = WithoutSharingHelperController.getAccountRequest(selectedUnsepReq);
        accountSearch.showMoreAccountRecords = false;
        contentSearch.showMoreContentRecords = false;
        showAccount = false;
    }
    
    /**
     * Method to redirect on project page
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public pagereference redirectOnRequest() {
        String parameters = '?Id=' + request.Id + '&activeTab=' + activeTab;
        
        //REF-1964
        if (isRefHubMatch) {
            parameters += '&isRefHubMatch=true&selectedUR=' + selectedUR;
        }
        PageReference ReturnPage = new PageReference(Page.RefRequestProject.geturl() + parameters);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }

    /**
     * Method to create hit list record
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public PageReference createHitRecord() {
        Hit_List__c hitObj = new Hit_List__c();
        Set<String> accountIds = new Set<String>();
        Set<String> ContactIds = new Set<String>();
        Boolean recordPresent = false;
        Savepoint sp = Database.setSavepoint();
        try {

            if (isAccount) {
                hitObj.Account__c = hitAccount;
                
                for (Hit_List__c tempObj : WithoutSharingHelperController.getAccountHitListInRefSearch(hitAccount, request.id)) {
                    recordPresent = true;
                }
                
                if (recordPresent) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.ACCOUNT_ALREADY_HIT));
                    return null;
                }
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { hitAccount });
                makeAccountRPM(accList[0], null);
                hitObj.Reference_Profile__c = accList[0].Reference_Basic_Informations__r[0].Id;
                hitObj.Reference_Request__c = request.Id;
                hitObj.Opportunity__c = request.Opportunity__c;

                for (Id accId : accountSearch.mapAccount.get(accountSearch.pageIndex)) {
                    accountIds.add(accId);
                }
                accountSearch.mapAccount.remove(accountSearch.pageIndex);
                accountSearch.accountIds.removeAll(accountIds);
            } else if (isContact) {
                Contact c = WithoutSharingHelperController.activateContactRecords(new Set<String> { hitContact })[0];
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { c.AccountId });
                
                if (request.Project_Type__c == 'Candidate') {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                    && !acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT));
                            return null;
                        }
                    }
                } else {
                    
                    for (Account acc : accList) {
                        
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                                && acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT));
                            return null;
                        }
                    }
                }
                hitObj.Account__c = c.AccountId;
                hitObj.Contact__c = c.Id;
                hitObj.Email__c = c.Email;
                hitObj.Phone__c = c.Phone;
                hitObj.Reference_Profile__c = accList[0].Reference_Basic_Informations__r[0].Id;
                makeAccountRPM(accList[0], c);
                
                for (Hit_List__c tempObj : WithoutSharingHelperController.getContactHitListInRefSearch(hitContact, c.AccountId, request.id)) {
                    recordPresent = true;
                }
                
                if (recordPresent) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.CONTACT_ALREADY_HIT));
                    return null;
                }

                hitObj.Reference_Request__c = request.Id;
                hitObj.Opportunity__c = request.Opportunity__c;
                
                if (contactSearch.accountId == null) {
                    
                    for (Id contactIdT : contactSearch.mapContact.get(contactSearch.pageIndex)) {
                        ContactIds.add(contactIdT);
                    }
                    contactSearch.mapContact.remove(contactSearch.pageIndex);
                    contactSearch.contactIds.removeAll(ContactIds);
                }
                
                if (accountSearch.mapAccount.containsKey(accountSearch.pageIndex)) {
                    
                    for (Id accId : accountSearch.mapAccount.get(accountSearch.pageIndex)) {
                        accountIds.add(accId);
                    }
                    accountSearch.mapAccount.remove(accountSearch.pageIndex);
                    accountSearch.accountIds.removeAll(accountIds);
                }
                ContactIds = new Set<String>();
                
                if (contactSearch.mapAccountContact != null && contactSearch.mapAccountContact.containsKey(contactSearch.pageIndex + '+' + c.AccountId)) {
                    
                    for (ContactWrapper cw : contactSearch.mapAccountContact.get(contactSearch.pageIndex + '+' + c.AccountId)) {
                        ContactIds.add(cw.con.Contact__r.Id);
                    }
                    contactSearch.mapAccountContact.remove(contactSearch.pageIndex + '+' + c.AccountId);
                    contactSearch.accountContactIds.removeAll(ContactIds);
                }

            }
            
            if (hitObj.Account__c != null) {
                WithoutSharingHelperController.upsertHitList(hitObj);
            }
            ismakeAccountRPMAccessed = false;
        } catch (Exception e) {
            ApexPages.addmessages(e);
            database.rollback(sp);
        }
        return null;
    }
    
    /**
     * Method to reset account search section
     * for "Allow for candidates to be included on projects"   by Rekha
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public void changeAccountType() {
        accountSearch.reset();
    }
    
    /**
     * Method to reset contact search section
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public void changeContactType() {
        contactSearch.reset();
    }

    public void setContentsIds() {}
    
    /**
     * Method to change basic filter view
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public void changeBasicFilterView() {
        isBasicSearchViewSelected = !isBasicSearchViewSelected;
    }
    
    /**
     * Method to edit row when inline editing is disabled
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public void editRow() {
        
        for (ReferenceRequestWrapper refReqw : allActiveReq) {
            updateReqList.add(refReqw.Id);
        }
        isEdit = true;
    }
    
    
    /**
     * Method to get searched Reference Contents on the basis of selected account.
     * Created By: Rajesh @Sept/19/2017
     */
    public Pagereference accountAssociatedContents() { 
        accountContents = new List<ConetntWrapper>(); 
        
        if (selectedAccountId != null) { 
            accountContents = contentSearch.getContentsForAccount(selectedAccountId);
        }  
        if (actionsSet != null && !actionsSet.contains('Refcontent_Link_Count__c') && trackRecord != null) {
            trackRecord.Refcontent_Link_Count__c++;
            update trackRecord;
            actionsSet.add('Refcontent_Link_Count__c');
        }
        return null;
    }

    /**
     * Wrapper class
     */
    public class FilterLogicWrapper {
        public String filterId {
            get;
            set;
        }

        public String filterName {
            get;
            set;
        }
        public String operatorSelected {
            get;
            set;
        }
        public FilterLogicWrapper(String filterId, String name, String opselected) {
            filterName = name;
            this.filterId = filterId;
            operatorSelected = opselected;
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

    public void rollUpAttribute() {
        
        rbiRecord = new Reference_Basic_Information__c();
        if (recordId != null && recordId != '') {
            rbiRecord = [SELECT ID, Name, Account__c, Account__r.Name, Contact__c, Contact__r.Name, Attributes__c, Referenceability__c FROM Reference_Basic_Information__c WHERE Id =: recordId];
        }
        String attributes = '';

        if (rbiRecord.Account__c != null && rbiRecord.Contact__c == null){
            attributes = UtilityController.rollUpAttributeMappingRBI(rbiRecord.Account__c, true, null);
            isContactSec = false;
        } else {
            attributes = UtilityController.rollUpAttributeMappingRBI(rbiRecord.Contact__c, false, rbiRecord.Account__c);
            isContactSec = true;
        }
        
        if (rbiRecord.Attributes__c != null && attributes != '') {
            rbiRecord.Attributes__c = rbiRecord.Attributes__c+ ', '+ attributes.removeEnd(', ');
        } else if (rbiRecord.Attributes__c == null && attributes != '') {
            rbiRecord.Attributes__c = attributes.removeEnd(', ');
        }
    }
    
    /*
     * Method to select all Contacts
     * REF-1964
     * REF-2304
     */
    public void selectAllContacts() {
        selectedContactIds = new List<String>();
        contactIdsToRemove = new List<String>();
        
        for (ContactWrapper cw : contacts) {
            
            if (cw.con.Contact__r.Email != null) {
                
                if (!isSelectAllContacts && cw.isSelected) {
                    contactIdsToRemove.add(cw.con.Contact__r.Id);
                }
                cw.isSelected = isSelectAllContacts;
                mapContactIdContactWrapper.put(cw.con.Contact__r.Id, cw);
            }
            
            if (cw.isSelected) {
                selectedContactIds.add(cw.con.Contact__r.Id);
            }
        }
    }
    
    /*
     * Method to select a Contact
     * REF-1964
     */
    public void selectSingleContact() {
        selectedContactIds = new List<String>();
        
        for (ContactWrapper cw : contacts) {
            
            if (cw.con.Contact__r.Id == selectedContactId) {
                cw.isSelected = !cw.isSelected;
                
                if (isSelectAllContacts) {
                    isSelectAllContacts = false; 
                }
            }
            mapContactIdContactWrapper.put(cw.con.Contact__r.Id, cw);
            
            if (cw.isSelected) {
                selectedContactIds.add(cw.con.Contact__r.Id);
            }
        }
    }
    
    /*
     * Method to select already selected contacts
     * REF-1964
     */
    public void preSelectHubContacts() {
        List<String> listOfIds = new List<String>();
        selectedContactIds = new List<String>();
        
        if (!String.isEmpty(preSelectedContactIds)) {
            listOfIds = preSelectedContactIds.split(',');
            
            for (ContactWrapper cw : contacts) {
                
                for (String conId : listOfIds) {
                    
                    if (cw.con.Contact__r.Id == conId) {
                        cw.isSelected = true;
                        selectedContactIds.add(cw.con.Contact__r.Id);
                        mapContactIdContactWrapper.put(cw.con.Contact__r.Id, cw);
                        break;
                    }
                }
            }
        }
    }

    /*
        REF-2181
        Account Information rollup to Reference Content  
        Rajneesh (March 18, 2019)
    */
    public void inheritAccountAttribute() {
        
        Set<Id> accountIdSet = new Set<Id>();
        Set<Id> accIdSet = new Set<Id>();
        String attributes = '';
        contentAttribute = '';
        contentTitle = '';
        List<Reference_Content__c> refConRec = [SELECT Id, Name, Title__c, Attributes__c, Account__c FROM Reference_Content__c Where Id =: recordId];
        
        if (refConRec.size() > 0) {
            contentTitle = refConRec[0].Title__c;
            contentAttribute = refConRec[0].Attributes__c;
        }

        if (refConRec.size() > 0) {

            for (Account_Reference_Content__c arc : [SELECT Id, Account__c FROM Account_Reference_Content__c WHERE Reference_Content__c =: recordId]) {
                accountIdSet.add(arc.Account__c);
            }
          
            for (Reference_Basic_Information__c accRBI : [SELECT Id, Account__c FROM Reference_Basic_Information__c WHERE Account__c =: accountIdSet AND Contact__c = null]) {
                accIdSet.add(accRBI.Account__c);
            } 
          
            //	query to get Account's parent information dynamically..
            String queryString = 'SELECT Id, ';
            Set<String> fieldSet = new Set<String>();	
            List<Attribute_Mapping__c> attriMappingList = [SELECT Id, Field_Api_Name__c, RelationShip_Name__c, Object__c, Mapping_Type__c, Auto_populate__c 
            FROM Attribute_Mapping__c WHERE (Object__c = : ConstantsController.ACCOUNT OR Object__c = : ConstantsController.REFERENCE_PROFILE) 
            AND Mapping_Type__c != : ConstantsController.CHILD_OBJECT];
            Set<String> amofAccount = new Set<String>();
             
            for (Attribute_Mapping__c amRec : attriMappingList) {
              
                if (amRec.Object__c == ConstantsController.ACCOUNT && amRec.Mapping_Type__c == null && amRec.Auto_populate__c) {
                    amofAccount.add(amRec.Field_Api_Name__c);
                }
            }                        
                           
            // Iterate over Attribute Mapping object to get Account parents information
            for (Attribute_Mapping__c am : attriMappingList) {

                if (am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && !am.RelationShip_Name__c.contains('__c')) {
                    queryString += am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c + ', ';
                    fieldSet.add(am.RelationShip_Name__c.removeEnd('Id') + '.' + am.Field_Api_Name__c);
                } else if (am.Object__c == ConstantsController.ACCOUNT && am.RelationShip_Name__c != null && am.RelationShip_Name__c.contains('__c')){
                    queryString += am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c + ', ';
                    fieldSet.add(am.RelationShip_Name__c.replace('__c','__r') + '.' + am.Field_Api_Name__c);
                } else if (am.Object__c == ConstantsController.REFERENCE_PROFILE && am.RelationShip_Name__c != null && am.RelationShip_Name__c == 'Account__c' && !amofAccount.contains(am.Field_Api_Name__c)) {
                    queryString += am.Field_Api_Name__c + ', ';
                    fieldSet.add(am.Field_Api_Name__c);
                }
            }
            queryString = queryString.removeEnd(', ') + ' FROM Account WHERE Id =: accIdSet';
           
            for (sObject acc : database.query(queryString)) {                  
                    
                for (String fldName : fieldSet) {

                    if (!fldName.contains('.') && acc.get(fldName) != null) {
                        attributes += acc.get(fldName) +', ';
                        
                    } else if (fldName.contains('.') && (fldName.countMatches('.') == 1) && acc.getSObject(fldName.substringBefore('.')) != null && acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) != null 
                        && acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) != '') {
                        attributes += acc.getSObject(fldName.substringBefore('.')).get(fldName.substringAfter('.')) +', ';  
                    } 
                }
            }
        }

        if (contentAttribute != '' && attributes != '') {
            contentAttribute = contentAttribute + ', '+ attributes.removeEnd(', ');
        } else if (contentAttribute == '' && attributes != '') {
            contentAttribute = attributes.removeEnd(', ');
        }
    }
    
    //REF-2366
    public PageReference backToSelectReferenceUseAttributes() {
        PageReference pageRef = new PageReference('/apex/SelectReferenceUseAttribute');
        pageRef.getParameters().put('fromAttributeResults','true');
        pageRef.getParameters().put('selectedLabelId',attributeWrapper.selectedLabelId);
        //REF-2645
        pageRef.getParameters().put('opportunityId',mapSelectReferenceUseAttributesVariables.get('opportunityIdP'));
        pageRef.getParameters().put('caseId',mapSelectReferenceUseAttributesVariables.get('caseIdP'));
        pageRef.getParameters().put('leadId',mapSelectReferenceUseAttributesVariables.get('leadIdP'));
        pageRef.getParameters().put('forAccount',mapSelectReferenceUseAttributesVariables.get('forAccountP'));
        pageRef.getParameters().put('forContent',mapSelectReferenceUseAttributesVariables.get('forContentP'));
        pageRef.getParameters().put('PreFilter',mapSelectReferenceUseAttributesVariables.get('preFilterP'));
        pageRef.getParameters().put('AccoutsIDs',mapSelectReferenceUseAttributesVariables.get('AccoutsIDsP'));
        return pageRef;
    }
    
    public void setSelectedAttributes() {
        
        if (!String.isBlank(slectedAttributesFromSelectRefAttrString)) {
            Set<String> listOfSelectedAttributes = new Set<String>();
            listOfSelectedAttributes.addAll(slectedAttributesFromSelectRefAttrString.split(','));
            
            for (AttributeWrapper.AttributesLabelWrapper alw : attributeWrapper.mapAllAttributesLabel.get(attributeWrapper.selectedLabelId)) {
                
                if (listOfSelectedAttributes.contains(alw.attributeLabel.Attribute__c)) {
                    attributeWrapper.mapAttributesLabels.get(attributeWrapper.selectedLabelId).add(alw);
                    alw.fontWeight = ConstantsController.BOLD;
                    attributeWrapper.allSelectedAttrIds.add(alw.attributeLabel.Attribute__c);
                }
            }
        }
    }
}