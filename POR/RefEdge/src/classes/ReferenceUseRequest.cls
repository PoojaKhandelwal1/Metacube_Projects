/**
 * ReferenceEdge
 * 
 * Point of Reference, Inc. - Copyright 2014 All rights reserved.
 *
 * @company : Point of Reference, Inc.
 * @website : www.point-of-reference.com
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED "AS---IS" BY POINT OF REFERENCE ("POR"), 
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
 * VF Page: ReferenceUseRequest.page
 * Description: Class used to handle Reference request.
 * Last modified by: Rajesh (2 June, 2017)
 */
public with sharing class ReferenceUseRequest extends RefEdgeEditionFeatures {
    /**
     * Constants
     */
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    private static String PROJECT_TITLE = 'Reference Project';
    private static String REQUEST_SUBJECT = 'Reference Request for @@@ (' + UserInfo.getFirstName() + ' ' + UserInfo.getLastName() + ')';
    private static String REQUEST_SUBJECT_LARGEOPPORTUNITY = 'Reference Request, Large Opportunity';
    private static String REQUEST_BODY_LARGEOPP = 'A new Request has been submitted. The Opportunity associated to this Request is greater than @@@  so this Request has been switched from Peer2Peer to Managed. Here are the details:';
    private static String SPECIFIED_REQUEST_MESSAGE = 'I would like to use an account as a reference for which you are the owner.  ';
    private static String UNSPECIFIED_REQUEST_MESSAGE = 'I need assistance from the Reference Program in securing a reference.  ';
    private static String APPROVE_DECLINE_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContactsSLDS.getURL() + '?id=';
    private static String REF_PROJECT_LINK = URL.getSalesforceBaseUrl().toExternalForm() + Page.RefRequestProject.getURL() + '?id=';
    private static String REFERENCE_REQUEST_TASK_SUBJECT = 'Reference Use Approval Request';
    /**
     * Properties and variables
     */
    private Integer numberOfRequestAccounts;
    private Set<String> setRefTypesId = new Set<String>();
    private integer refRecordCount;
    private Map<String, String> mapAccountOwnerId = new Map<String, String>();
    private Map<Id, Reference_Basic_Information__c> mapAccount;
    private List<String> listAccountIds = new List<String>();
    public Reference_Request__c referenceRequest;
    public Boolean showOwner { get; set; }
    public List<Label__c> filterList { get; set; }
    public Boolean isSubmitted { get; set; }
    public String opportunityId { get; set; }
    public String caseId { get; set; }
    public Opportunity opportunity { get; set; }
    public Case caseObj { get; set; }
    // regarding ticket #809
    public Lead leadObj { get; set; }
    public String leadId { get; set; }
    public String noOFAccounts { get; set; }
    public List<ReferenceUseAccountWrapper> selectedAccounts { get; set; }
    public Boolean isMessageRender { get; set; }
    public boolean isGenInfoDisplay { get; set; }
    public Reference_Request_Account__c refRequestAccount { get; set; }
    public List<SelectOption> referenceabilityTypes { get; set; }
    public String param1 { get; set; }
    public String param2 { get; set; }
    public String param3 { get; set; }
    public String param4 { get; set; }
    public integer unspecifiefAccDelCount { get; set; }//to be removed
    public String referenceType { get; set; }
    public String deadline { get; set; }
    public string notes { get; set; }
    public Map<Id, String> referTypeNameId { get; set; }
    public string oldReferenceability { get; set; }
    public Map<Id, List<Reference_Type_Mapping__c>> referNamesOfFields { get; set; }
    public Set<String> duplicacyForAdditionalInfo { get; set; }
    public Map<Id, Referenceability_Type__c> mapReferenceType { get; set; }
    public static string minimumDeadline {
        get {
            
            if (minimumDeadline == null || minimumDeadline == '') {
                minimumDeadline = String.valueOf(UtilityController.getCustomSettings().Minimum_Deadline__c);
            }
            return minimumDeadline;
        }
        set;
    }
    public String minDeadlineLabel {
        get {
            return System.Label.Min_deadline_days.replace('@@@', minimumDeadline);
        }
        set;
    }
    public String defaultDate {
        get {
            return calculateDate(Date.today(), Integer.valueOf(UtilityController.getCustomSettings().Minimum_Deadline__c)).format();
        }
        set;
    }
    public String refDeadline { get; set; }
    private Date calculateDate(Date date1, Integer days) {
        
        while (UtilityController.isItWeekend(date1)) {
            date1 += 1;
        }
        
        while (days > 0) {
            date1 += 1;
            
            while (UtilityController.isItWeekend(date1)) {
                date1 += 1;
            }
            days--;
        }
        return date1;
    }
    public String selectedValue { get; set; }
    public Map<String, Reference_Request_Additional_Info__c> additionalFieldsInfo { get; set; }
    public String accountIdToRemoveFromList { get; set; }
    //Instance of SelectReferenceUseAttribute Class
    public SelectReferenceUseAttribute refUseAttr { get; set; }
    public string recordCounts { get; set; }
    public string genNotes { get; set; }
    public Boolean showGenNotes { get; set; }
    public Boolean isDeadlineRefBlank { get; set; }
    /*
     * This field is use to show reward points in disolving alert for sales reward issue to user
     */
    public transient Decimal rewardPoints { get; set; }
    /*
     * This field is use to show action message in disolving alert for sales reward issue to user
     */
    public transient String actionMessage { get; set; }
    public String advRoutingGrpName { get; set; }
    public String selectedGrp { get; set; }
    public String selectedAdvanceGrp { get; set; }  
    public String advanceRoutingGroups { get; set; }
    public boolean isP2PRequest { get; set; }
    public boolean isRoutingGrpExist { get; set; }
    public List<SelectOption> advRoutingGroup { get; set; }
    public List<SelectOption> selectedRoutingGroup { get; set; }
    private Boolean checkPeer2PeerEmailSetting;
    private Boolean checkPeer2PeerChatterSetting;
    private Boolean checkPeer2PeerSlackSetting;
    private Boolean checkManagedEmailSetting;
    private Boolean checkManagedChatterSetting;
    private Boolean checkManagedSlackSetting;
    private Boolean checkConvertedEmailSetting;
    private Boolean checkConvertedChatterSetting;
    private Boolean checkConvertedSlackSetting;
    private List<Reference_Request_Account__c> insertRefReqAcc;
    public List<Unspecified_Request__c> insertUnspecifiedReq;
    public String forAccount { get; set; }
    public String forContent { get; set; }
    public Set<Id> refTypeIdSet;
    private Map<Id, Referenceability_Type__c> refTypeMap;
    public Map<String, String> refTypeDeadlineMap { get; set; }
    private Map<Id, Integer> refTypeMappingMap;
    private Set<String> refNoteSet;
    private Set<String> refFieldSet;
    public String nameSpace { get; set; }
    public Custom_Settings__c cs { get; set; }
    public Map<String, sObject> territoryMap { get; set; }
    public Map<String, Map<String, String>> attMapForChatter { get; set; }
    public Map<String, Task> rraTaskMap { get; set; }
    
    // added for #626 - map to store which chatter post is created for each RRA record
    public Map<String, Set<sObject>> feedItemRRAMap { get; set; }
    
    // added for #603 - showing single message if request is re-routed
    public Boolean isRequestRerouted { get; set; }
    
    // for #655 send prefilter value to request page
    public String preFilter { get; set; }
    public boolean showOveray { get; set; }
    //REF-1603
    public String helpAssistant { get; set; } 
    public String helpOverlay { get; set; } 
    private List<User_Mapping__c> userMappingList;
    private Date lastActivity;
    //REF-2132
    public String rrIdToUploadFiles {get;set;}
    public Boolean isFromSubmitUploadFiles {get;set;}
    public Boolean isUploadFiles {get;set;}
    public Reference_Request__c refRequestInstance {get;set;}
    public Boolean attachSupportingDocuments { get;set; }
    //REF-2366
    public String selectedLabelId { get; set; }
    public Boolean isFromAttributeResults { get; set; }
    //REF-2645
    public String accountIdsString { get; set; }    
    public String mapRBIIdReferenceUseInstanceWrapperString { get; set; }
    public String refTypeIdSetString { get; set;}

    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request__c',
                     new Set<String>{UtilityController.appNamespace() + 'Content_URL__c',
                         UtilityController.appNamespace() + 'Project_Type__c',
                         UtilityController.appNamespace() + 'Reference_Request_Status__c',
                         UtilityController.appNamespace() + 'Custom_Reference_Content__c',
                         UtilityController.appNamespace() + 'Requester__c'});
        
        if (opportunityId != null && opportunityId.trim().length() > 0 && opportunityId != '') {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Opportunity__c');
        } else if (caseId != null && caseId.trim().length() != 0 && caseId != '') {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Case__c');
        } else if (leadId != null && leadId.trim().length() != 0 && leadId != '') { // regarding ticket #809
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Lead__c');
        }
        
        // re #793 - Check for Advance routing setting
        if (cs.Adv_Request_Routing__c) {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Adv_Routing_Group__c');
        }
        fieldMap.put(UtilityController.appNamespace() + 'Unspecified_Request__c',
                     new Set<String>{UtilityController.appNamespace() + 'Deadline__c',
                         UtilityController.appNamespace() + 'Unspecified_Request_Status__c',
                         UtilityController.appNamespace() + 'Reference_Type_Needed__c',
                         UtilityController.appNamespace() + 'Requester__c',
                         UtilityController.appNamespace() + 'Reference_Request__c',
                         UtilityController.appNamespace() + 'Request_Notes__c'});
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label__c',
                     new Set<String>{UtilityController.appNamespace() + 'Label__c', UtilityController.appNamespace() + 'Reference_Request__c'});
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label_Attribute__c',
                     new Set<String>{UtilityController.appNamespace() + 'Attribute__c', UtilityController.appNamespace() + 'Reference_Request_Label__c'});
        Boolean isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
        fieldMap.clear();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request__c',
                     new Set<String>{'Reference_Request_Status__c'});            
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
        return (isUpsertPermission && isInsertPermission);
    }
    
    /**
     * Constructor
     */
    public ReferenceUseRequest() {
        //REF-2645
        mapRBIIdReferenceUseInstanceWrapperString = '';
        refTypeIdSetString = '';
        accountIdsString = '';   
        //REF-2366
        selectedLabelId = '';
        isFromAttributeResults = false;
        //REF-2132
        isUploadFiles = false;
        isFromSubmitUploadFiles = false;
        rrIdToUploadFiles = ApexPages.currentPage().getParameters().get('rrId') != null
                            ? ApexPages.currentPage().getParameters().get('rrId') : '';
        
        if (!String.isBlank(rrIdToUploadFiles)) {
            refRequestInstance = [SELECT Id,Name FROM Reference_Request__c WHERE Id =: rrIdToUploadFiles][0];  
            isUploadFiles = true;
        }
        
        cs = UtilityController.getCustomSettings();
        showOwner = cs.Show_Owner_in_Ref_Search__c;
        //REF-2132
		attachSupportingDocuments = cs.Attach_Supporting_Documents_To_Requests__c;
        checkPermissions();
        
        if ((ApexPages.currentPage().getParameters().get('sfdcIFrameHost') != null
             && ApexPages.currentPage().getParameters().get('sfdcIFrameHost') != '')
            || (ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin') != null
                && ApexPages.currentPage().getParameters().get('sfdcIFrameOrigin') != '')
            || ApexPages.currentPage().getParameters().get('isdtp') == 'p1'
            || (ApexPages.currentPage().getParameters().get('retURL') != null
                && ApexPages.currentPage().getParameters().get('retURL').contains('projectone'))) {
                    system.debug('*********SF1');
                } else {
                    system.debug('********normal');
                }
        rraTaskMap = new Map<String, Task>();
        isRequestRerouted = false;
        feedItemRRAMap = new Map<String, Set<sObject>>();
        isP2PRequest = false;
        dummyReq = new Reference_Request_Account__c();  // for SF1
        fromWhere = ''; // for SF1
        pageUrl = (String) apexPages.currentPage().getUrl();    // for SF1
        noOFAccounts = '0';
        refRecordCount = 0;
        refDeadline = '';
        referTypeNameId = new Map<Id, String>();
        refRequestAccount = new Reference_Request_Account__c();
        refTypeIdSet = new Set<Id>();
        refNoteSet = new Set<String>();
        refFieldSet = new Set<String>();
        refTypeDeadlineMap = new Map<String, String>();
        nameSpace = UtilityController.appNamespace();
        init();
        duplicacyForAdditionalInfo = new Set<String>();
        referNamesOfFields = new Map<Id, List<Reference_Type_Mapping__c>>();
        additionalFieldsInfo = new Map<String, Reference_Request_Additional_Info__c>();
        List<Referenceability_Type__c> listOfReferenceabilities = [SELECT Name, Id, Note__c, max_accounts_per_request_type__c,
                                                                   min_lead_time_per_request_type__c, Managed__c
                                                                   FROM Referenceability_Type__c
                                                                   WHERE Visible__c = true AND Request_type__c = true
                                                                   AND Sales_Reward__c = false
                                                                   ORDER BY Name LIMIT :limits.getLimitQueryRows()];
        mapReferenceType = new Map<Id, Referenceability_Type__c>();
        
        for (Referenceability_Type__c ref : listOfReferenceabilities) {
            mapReferenceType.put(ref.Id, ref);
            
            if (ref.Note__c != null && ref.Note__c != '') {
                refNoteSet.add(ref.Id);
            }
        }
        refUseAttr = new SelectReferenceUseAttribute();
        isGenInfoDisplay = false;
        isMessageRender = false;
        isDeadlineRefBlank = false;
        opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        leadId = ApexPages.currentPage().getParameters().get('leadId');
        forAccount = ApexPages.currentPage().getParameters().get('forAccount');
        forContent = ApexPages.currentPage().getParameters().get('forContent');
        // for #655 send prefilter value to request page
        preFilter = ApexPages.currentPage().getParameters().get('PreFilter');
        
        if (opportunityId != null && opportunityId != '') {
            List<Opportunity> tempList = [SELECT Id, Name, AccountId, Account.Name, OwnerId
                                          FROM Opportunity WHERE Id = :opportunityId LIMIT 1];
            opportunity = tempList[0];
        }
        
        if (caseId != null && caseId != '') {
            List<Case> tempList = [SELECT Id, CaseNumber, AccountId, Account.Name, OwnerId
                                   FROM Case WHERE Id = :caseId LIMIT 1];
            caseObj = tempList[0];
        }
        
        // regarding ticket #809
        if (leadId != null && leadId != '') {
            List<Lead> tempList = [SELECT Id, Name, Company, OwnerId FROM Lead WHERE Id = :leadId LIMIT 1];
            leadObj = tempList[0];
        }
        selectedAccounts = new List<ReferenceUseAccountWrapper>();
        
        if (ApexPages.currentPage().getParameters().get('AccoutsIDs') != null && ApexPages.currentPage().getParameters().get('AccoutsIDs') != '') {
            //REF-2645
            accountIdsString = ApexPages.currentPage().getParameters().get('AccoutsIDs');
            listAccountIds = UtilityController.convertCommaSeperatedStringToArray(ApexPages.currentPage().getParameters().get('AccoutsIDs'));
            
            for (Reference_Basic_Information__c rbiAcc : WithoutSharingHelperController.getAccountsRBI(listAccountIds)) {
                refRecordCount = refRecordCount + 1;
                noOFAccounts = string.valueOf(Integer.valueOf(noOFAccounts) + 1);
                ReferenceUseAccountWrapper rraw = new ReferenceUseAccountWrapper(rbiAcc, rbiAcc.Account__r.Name, refRecordCount, rbiAcc.Managed_Reference_Account__c);
                
                // re #436 
                if (!rbiAcc.Managed_Reference_Account__c) { 
                    isP2PRequest = true;
                    refUseAttr.isP2PRequest = isP2PRequest ;
                }
                selectedAccounts.add(rraw);
            }
        }
        
        if (selectedAccounts.size() == 0) {
            refRecordCount = refRecordCount + 1;
            noOFAccounts = '1';
            ReferenceUseAccountWrapper rraw = new ReferenceUseAccountWrapper(new Reference_Basic_Information__c(), ConstantsController.UNSPECIFIED, refRecordCount, true);
            selectedAccounts.add(rraw);
            // re #436
            isP2PRequest = false; 
            refUseAttr.isP2PRequest = isP2PRequest ; 
        }
        referenceabilityTypes = new List<SelectOption>();
        referenceabilityTypes.add(new SelectOption('', '--None--'));
        refTypeMap = new Map<Id, Referenceability_Type__c>();
        Decimal minDeadlineCS = UtilityController.getCustomSettings().Minimum_Deadline__c;
        refTypeDeadlineMap.put(null, String.valueOf(minDeadlineCS));
        
        for (Referenceability_Type__c ref : listOfReferenceabilities) {
            referenceabilityTypes.add(new SelectOption(ref.Id, ref.Name));
            referTypeNameId.put(ref.Id, ref.Name);
            refTypeMap.put(ref.Id, ref);
            refTypeDeadlineMap.put(ref.Id, string.valueOf((ref.min_lead_time_per_request_type__c != null ? ref.min_lead_time_per_request_type__c : minDeadlineCS)));
        }
        referTypeNameId.put(null, '');
        refTypeMappingMap = new Map<Id, Integer>();
        
        for (String Id : refTypeMap.keySet()) {
            refTypeMappingMap.put(refTypeMap.get(Id).Id, 0);
        }
        rewardPoints = 0;
        filterList = new List<Label__c>();
        
        if (cs.Adv_Request_Routing__c && isP2PRequest) {
            refUseAttr.isAdvRouting = cs.Adv_Request_Routing__c ;
            refUseAttr.isP2PRequest = isP2PRequest ;
            //REF-2366
            refUseAttr.getMapAllAttrributesLabel();
            refUseAttr.getMapAttrributesLabels();
            refUseAttr.getMapAttributeSize();
            
            isGenInfoDisplay = true;
        }
        showOveray = false;
        lastActivity = date.today();
        userMappingList = new List<User_Mapping__c>();
        Map<Decimal,DMNameValueWrapper> tempMapDM = new Map<Decimal,DMNameValueWrapper>();
        tempMapDM = new Map<Decimal,DMNameValueWrapper>();

        for (Data_Mapping__c dm : WithoutSharingHelperController.getDMHelpOverlay(new List<String>{ UtilityController.appNamespace() + 'ReferenceUseRequest'})) {
            tempMapDM.put(dm.Order__c, new DMNameValueWrapper(dm.Label__c,dm.DC_Message__c));
        }
        helpOverlay = JSON.serialize(tempMapDM); 

        if (!isP2PRequest) {
            removeAllGroups();
        }
        
        //REF-2366
        if (ApexPages.currentPage().getParameters().get('fromAttributeResults') != null && 
            ApexPages.currentPage().getParameters().get('fromAttributeResults') == 'true' && 
            ApexPages.currentPage().getParameters().get('selectedLabelId') != null && 
            ApexPages.currentPage().getParameters().get('selectedLabelId') != '') {
            isFromAttributeResults = true;
            selectedLabelId = ApexPages.currentPage().getParameters().get('selectedLabelId');
            isGenInfoDisplay = true;
        }
        checkForHelpOverlay();
    }
    
    /**
     * Method Call from Construcor
     */
    void init() {
        param1 = '';
        param2 = '';
        param3 = '';
        param4 = '';
        selectedValue = 'The Record Clicked';
        isSubmitted = false;
        showGenNotes = false;
        minimumDeadline = String.valueOf(cs.Minimum_Deadline__c);
        checkPeer2PeerEmailSetting = cs.Request_Peer2Peer_Email__c;
        checkPeer2PeerChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Peer2Peer_Chatter__c);
        checkPeer2PeerSlackSetting = (cs.Enable_Slack_Integration__c && cs.Request_Peer2Peer_Slack__c);
        checkManagedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Managed_Chatter__c);
        checkManagedEmailSetting = cs.Request_Managed_Email__c;
        checkManagedSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_Managed_Slack__c;
        checkConvertedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Large_Opportunity_Chatter__c);
        checkConvertedEmailSetting = cs.Large_Opportunity_Email__c;
        checkConvertedSlackSetting = cs.Enable_Slack_Integration__c && cs.Large_Opportunity_Slack__c;
        numberOfRequestAccounts = Integer.valueOf(cs.Number_of_request_accounts__c);
        numberOfRequestAccounts = Integer.valueOf(cs.Number_of_request_accounts__c);
        genNotes = cs.General_Notes__c; 
        // re #436
        isRoutingGrpExist = false;
        bindRoutingGroup();
        advRoutingGrpName = (cs.Adv_Routing_Group_Lbl__c == null || cs.Adv_Routing_Group_Lbl__c == '') ? System.Label.Advanced_Routing_Group : cs.Adv_Routing_Group_Lbl__c;
    }
    
    /**
    *   Method to check whether to show help overlay on page or not
    *   Author : Rajesh for REF-1603
    **/ 
    public void checkForHelpOverlay() {  
        
        if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) {

            showOveray = true;  
            userMappingList = [SELECT Id, Label__c, Order__c, User__c, Last_Used_Classic_Page__c FROM User_Mapping__c 
                                WHERE User__c =:UserInfo.getUserId() AND Label__c =:ConstantsController.REQUEST_HELP_OVERLAY 
                                 LIMIT 1];
 
            if (userMappingList.Size() > 0 && userMappingList[0].Order__c != null 
                                                                && userMappingList[0].Order__c >= cs.Help_Overlay_Count__c) {
                showOveray = false;
            }
            
            if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userMappingList.size() > 0 
                                                                && userMappingList[0].Last_Used_Classic_Page__c != null) {
                 lastActivity = UtilityController.parseLastVisitDate(userMappingList[0].Last_Used_Classic_Page__c); 
            }
        }        
    }
    /** 
     *   Method to Manage user mapping for inviation
     *   Author : Rajesh REF-1572
    **/
    public void userMappingRecord() {
		DateTime todayDate = system.today();
        
        //  check user mapping count and custom setting count       
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
                umr.Label__c = ConstantsController.REQUEST_HELP_OVERLAY;
                umr.Order__c = 1;
                umr.User__c = UserInfo.getUserId();
                umr.Last_Used_Classic_Page__c = todayDate.format('yyyy-MM-dd');
                userMappingList.add(umr);
            }  
        } else if(cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 
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
     * Method to get Accounts
     */
    public List<SelectOption> getAccounts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('0', 'select'));
        
        for (integer i = 1; i <= numberOfRequestAccounts; i++) {
            options.add(new SelectOption('' + i, '' + i));
        }
        return options;
    }
    
    /**
     * Method to get Advance Routing group #436
     */
    public void bindRoutingGroup() {
        
        try {
            
            if (cs.Adv_Request_Routing__c == true) {
                advRoutingGroup = new List<SelectOption>();
                selectedRoutingGroup = new List<SelectOption>();
                String rountingClientValue = '';
                
                for (Advanced_Routing__c advRouting : [SELECT Adv_Routing_Client_Value__c FROM Advanced_Routing__c
                                                       WHERE Adv_Routing_Client_Value__c != null
                                                       LIMIT :limits.getLimitQueryRows()]) {
                                                           isRoutingGrpExist = true;
                                                           // REF-1464 remove double spaces
                                                           rountingClientValue = advRouting.Adv_Routing_Client_Value__c.trim().replaceAll('(\\s+)', ' ');
                                                           
                                                           advRoutingGroup.add(new SelectOption(rountingClientValue, rountingClientValue));
                                                       }
            }
        } catch (exception ex) {
            isMessageRender = true;
            Apexpages.addMessages(ex);
        }
    }
    
    /**
     * Method to add Accounts
     */
    public void addAccounts() {
        integer accounts = integer.valueOf(noOFAccounts);
        integer selectAcc = selectedAccounts.size();
        
        if (accounts > selectAcc) {
            
            for (Integer i = 0; i < (accounts - selectAcc); i++) {
                refRecordCount = refRecordCount + 1;
                ReferenceUseAccountWrapper rraw = new ReferenceUseAccountWrapper(new Reference_Basic_Information__c(), ConstantsController.UNSPECIFIED, refRecordCount, true);
                selectedAccounts.add(rraw);
            }
        }
        isDeadlineRefBlank = false;
    }
    
    /**
     * Method to remove Account from List
     */
    public void removeAccountFromList() {
        Id referenceType;
        decimal referenceCount = 0;
        showGenNotes = false;
        
        for (Integer i = 0; i < selectedAccounts.size(); i++) {
            
            if (accountIdToRemoveFromList != '' && accountIdToRemoveFromList == selectedAccounts.get(i).acc.Account__r.Id) {
                noOFAccounts = string.valueOf(integer.valueOf(noOFAccounts) - 1);
                referenceType = selectedAccounts.get(i).referenceType;
                selectedAccounts.remove(i);
                break;
            } else if (accountIdToRemoveFromList == '' && unspecifiefAccDelCount == selectedAccounts.get(i).recordCount) {
                noOFAccounts = string.valueOf(integer.valueOf(noOFAccounts) - 1);
                referenceType = selectedAccounts.get(i).referenceType;
                selectedAccounts.remove(i);
                break;
            } 
        }
        isGenInfoDisplay = false;
        Integer countSameRef = 0;
        
        for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
            
            if (referenceType == rraw.referenceType && rraw.isManaged) {
                referenceCount = referenceCount + 1;
            }
            
            // #564 - Check referenceType of managed type.
            if (rraw.isManaged || rraw.AccountName == ConstantsController.UNSPECIFIED || (refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                isGenInfoDisplay = true;
                showGenNotes = true;
            }
            
            if (rraw.referenceType == referenceType) {
                countSameRef++;
            }
        }
        
        for (String ref : refTypeMappingMap.keySet()) {
            
            if (ref == referenceType) {
                integer countRef = refTypeMappingMap.get(referenceType);
                refTypeMappingMap.put(referenceType, (countRef > 0 ? countRef - 1 : 0));
            }
        }
        
        // #564 - Check referenceType of managed type.
        if (referenceCount < 1 && countSameRef == 0) {
            
            for (Id referId : referNamesOfFields.keySet()) {
                
                if (referId == referenceType) {
                    
                    for (Reference_Type_Mapping__c mapObj : referNamesOfFields.get(referId)) {
                        
                        if (additionalFieldsInfo.containsKey(referId)) {
                            additionalFieldsInfo.remove(referId);
                        }
                    }
                    referNamesOfFields.remove(referId);
                }
            }
        }
        
        if (countSameRef == 0) {
            refTypeIdSet.remove(referenceType);
            refUseAttr.refTypeIdsSet = refTypeIdSet;
        }
        isDeadlineRefBlank = false;
        
        if (cs.Adv_Request_Routing__c && refUseAttr.mapAttributesLabels.size() > 0 && selectedAccounts.size() != 0) {
            
            for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                
                if (!rraw.isManaged) {
                    isGenInfoDisplay = true;
                }
            }
        }
        isP2PRequest = false;
        refUseAttr.isP2PRequest = isP2PRequest ;
        if (cs.Adv_Request_Routing__c && selectedAccounts.size() != 0) {
            
            for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                
                if (!rraw.isManaged && (refTypeMap.get(rraw.referenceType) == null || !Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                    isP2PRequest = true;
                    refUseAttr.isP2PRequest = isP2PRequest ;
                }
            }
        }
        if (!isP2PRequest) {
            removeAllGroups();
        }
        
    }
    
    public void addGroups() { 
        selectedGrp = selectedGrp.replace('[', '');
        selectedGrp = selectedGrp.replace(']', ''); 
        String[] listofGroups = selectedGrp.split(',');   
        
        if (listofGroups.size() > 0 && selectedGrp != '') {
            
            for (integer i = 0; i < listofGroups.size(); i++) {
                selectedRoutingGroup.add(new SelectOption(listofGroups[i],listofGroups[i]));
                
                for (integer j = 0; j < advRoutingGroup.size(); j++) {
                    
                    if (advRoutingGroup[j].getValue().trim() == listofGroups[i].trim()) {
                        advRoutingGroup.remove(j);
                    }
                }
            }
        }
        showOveray = false; 
        populateFilters(); 
    }
    
    public void removeGroups() {
        selectedAdvanceGrp = selectedAdvanceGrp.replace('[', '');
        selectedAdvanceGrp = selectedAdvanceGrp.replace(']', '');
        String[] listofGroups = selectedAdvanceGrp.split(',');
        
        if (listofGroups.size() > 0 && selectedAdvanceGrp != '') {
            
            for (integer i = 0; i < listofGroups.size(); i++) {
                advRoutingGroup.add(new SelectOption(listofGroups[i], listofGroups[i]));
                
                for (integer j = 0; j < selectedRoutingGroup.size(); j++) {
                    
                    if (selectedRoutingGroup[j].getValue().trim() == listofGroups[i].trim()) {
                        selectedRoutingGroup.remove(j);
                    }
                }
            }
        }
        populateFilters();
        showOveray = false;
    }

    public void removeAllGroups() {
    
        if (selectedAdvanceGrp != null) {
            for (integer index = 0; index < selectedRoutingGroup.size(); index++) {
                advRoutingGroup.add(new SelectOption(selectedRoutingGroup[index].getValue(), selectedRoutingGroup[index].getLabel()));
                selectedAdvanceGrp += selectedRoutingGroup[index].getLabel() + ',';
            }
            selectedAdvanceGrp.removeEnd(',');
            selectedRoutingGroup = new List<SelectOption>();
            populateFilters();
            showOveray = false;
        }
    }
    
    /**
     * Method used to get filters re #436
     */
    public void populateFilters() {
        
        try {
            
            if (selectedAdvanceGrp != '' && selectedAdvanceGrp != null) {
                filterList= new List<Label__c>();  
                String[] listofGroups = new List<String>(); 
                
                if (selectedRoutingGroup.size() > 0) {
                    advanceRoutingGroups = '';
                    
                    for (integer j = 0; j < selectedRoutingGroup.size(); j++) { 
                        listofGroups.add(selectedRoutingGroup[j].getValue().trim());
                    }
                    advanceRoutingGroups = String.join(listofGroups, ','); 
                    filterList = [SELECT Id, Name, Show_in_P2P__c, Required_in_P2P__c
                                    FROM Label__c WHERE Adv_Routing_Group__c IN :listofGroups];
                    refUseAttr.groupsIds = listofGroups;  
                    isGenInfoDisplay = true;   
                } else { 
                    refUseAttr.groupsIds = null; 
                } 
            } else { 
                refUseAttr.groupsIds = null; 
            }
        } catch (exception ex) { 
            isMessageRender = true;
            Apexpages.addMessages(ex); 
        }
    }
    
    /**
     * Method to Mass Update Accounts on modal save button
     */
    public PageReference selectAndUpdate() {
        
        try { 
            Set<Id> usedRefSet = new Set<Id>();
            decimal recordCount;
            isDeadlineRefBlank = false;
            boolean isUnspecifiedPresent = false;
            // re #564 - flag will decide that selected ref type is managed or not
            boolean isRefTypeManaged = false;
            
            // for SF1
            if (fromWhere == 'SF1') {  
                param1 = dummyReq.Reference_Type_Needed__c;
                
                if (dummyReq.Deadline__c != null) {
                    param2 = dummyReq.Deadline__c.format();
                } else {
                    param2 = '';
                }
                param3 = dummyReq.Request_Notes__c;
                referenceType = dummyReq.Reference_Type_Needed__c;
            }
            
            if (param1 == '' || param1 == null || param2 == '' || param2 == null || (cs.Request_Notes_Required__c && String.isBlank(param3))) {
                isMessageRender = true;
                String errorMsg = cs.Request_Notes_Required__c ? System.Label.Edit_popup_all_fields_must_filled1 : System.Label.Edit_popup_all_fields_must_filled;
                throw new CustomException(errorMsg);
            } else {
                Date deadline = Date.parse(param2);
                
                if (param1 != null && param1 != '') {
                    // re #1131 -Assign param1 (reference type needed) to reference type to avoid null de-reference exception
                    referenceType = param1;
                    minimumDeadline = String.valueOf(refTypeMap.get(referenceType).min_lead_time_per_request_type__c);
                }
                
                // checking for deadline date is in Weekend day or not
                if (UtilityController.isItWeekend(deadline)) {
                    isMessageRender = true;
                    throw new CustomException(System.Label.Edit_popup_deadline_date_must_not_fall_Weekend);
                }
                // checking for deadline date is in period or not
                Date lastDay = UtilityController.calculateMinimumDays(deadline, Integer.valueOf(minimumDeadline));
                
                if (lastDay.daysBetween(deadline) <= 0) {
                    isMessageRender = true;
                    throw new CustomException((System.Label.Edit_popup_invalid_past_Deadline_date).replace('Minimum_Deadline', minimumDeadline));
                }
                
                // re #564 - Allow reference Type which is Managed
                if (referenceType != null) {
                    isRefTypeManaged = Boolean.valueOf(refTypeMap.get(referenceType).Managed__c);
                }
            }
            isMessageRender = false;
            boolean isManaged = false;
            showGenNotes = false;
            refTypeIdSet = new Set<Id>();
            integer refc = 0;
            integer reftypec = 0;
            Referenceability_Type__c refType = refTypeMap.get(param1); 
            
            // re #604 - handle null value for recordcounts
            if ((recordCounts == null || recordCounts == '') || (selectedAccounts != null && selectedAccounts.size() == 1)) {
                recordCounts = (selectedAccounts[0].recordCount != null) ? string.valueof(selectedAccounts[0].recordCount) : '1';
            }  
            
            if (selectedValue == 'The Record Clicked') { 
                recordCount = decimal.valueOf(recordCounts);
                
                if (param1 != '' && param1 != null) {
                    
                    for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                        
                        if (rraw.recordCount == recordCount) {
                            
                            if (rraw.referenceType != param1) {
                                refc = 1 + refTypeMappingMap.get(param1);
                            } else {
                                refc = refTypeMappingMap.get(param1);
                            }
                        }
                    }
                    
                    if (refTypeMap.get(param1).max_accounts_per_request_type__c != null && refTypeMap.get(param1).max_accounts_per_request_type__c > 0) {
                        
                        if (refc > refTypeMap.get(param1).max_accounts_per_request_type__c) {
                            isMessageRender = true;
                            throw new CustomException((System.Label.No_of_Accounts_Per_ReqType_Error).replace('@@@', String.valueOf(refTypeMap.get(param1).max_accounts_per_request_type__c)));
                        }
                    }
                }
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts) { 
                    
                    if (rraw.recordCount == recordCount) {
                        rraw.isSelected = true;
                        
                        if (param1 != '' && param1 != null) {
                            
                            if (rraw.referenceType != param1 && refTypeMappingMap.get(rraw.referenceType) > 0) {
                                reftypec = refTypeMappingMap.get(rraw.referenceType) - 1;
                                refTypeMappingMap.put(rraw.referenceType, reftypec);
                            }
                            rraw.referenceType = param1; 
                        }
                        
                        if (param2 != '' && param2 != null) {
                            rraw.deadline = Date.parse(param2);
                            rraw.deadLineDate = param2;
                        }
                        rraw.notes = param3;
                        
                        if (rraw.accountName == ConstantsController.UNSPECIFIED) {
                            isUnspecifiedPresent = true;
                            showGenNotes = true;
                        }
                        
                        if (!isManaged) {
                            isManaged = rraw.isManaged;
                        }
                    }
                    
                    if (rraw.isManaged || rraw.accountName == ConstantsController.UNSPECIFIED || (refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                        refTypeIdSet.add(rraw.referenceType);
                    }
                } 
                refTypeMappingMap.put(param1, refc);
            } else {
                
                if (param1 != '' && param1 != null) {
                    
                    for (ReferenceUseAccountWrapper rraw: selectedAccounts) {
                        
                        for (String recordNo: recordCounts.split(',')) {
                            
                            if (rraw.recordCount == decimal.valueOf(recordNo)) {
                                
                                if (rraw.referenceType != param1) {
                                    refc = refc + 1;
                                }
                            }
                        }
                    }
                    refc = refc + refTypeMappingMap.get(param1);
                    
                    if (refTypeMap.get(param1).max_accounts_per_request_type__c != null && refTypeMap.get(param1).max_accounts_per_request_type__c > 0) {
                        
                        if (refc > refTypeMap.get(param1).max_accounts_per_request_type__c) {
                            isMessageRender = true;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, (System.Label.No_of_Accounts_Per_ReqType_Error).replace('@@@', String.valueOf(refTypeMap.get(param1).max_accounts_per_request_type__c))));
                            return null; 
                        }
                    }
                }
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                    
                    for (String recordNo : recordCounts.split(',')) {
                        
                        if ((recordNo != '' && recordNo != null) && rraw.recordCount == decimal.valueOf(recordNo)) {
                            rraw.isSelected = true;
                            
                            if (oldReferenceability == '') {
                                oldReferenceability = rraw.referenceType;
                            }
                            
                            if (param1 != '' && param1 != null) {
                                
                                if (rraw.referenceType != param1) {  
                                    // re #564 - managed referencibility type
                                    if (refTypeIdSet.contains(rraw.referenceType) && !(refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                                        refTypeIdSet.remove(rraw.referenceType); 
                                    } 
                                    
                                    if (refTypeMappingMap.get(rraw.referenceType) > 0) {
                                        reftypec = refTypeMappingMap.get(rraw.referenceType) - 1;
                                        refTypeMappingMap.put(rraw.referenceType, refTypeMappingMap.get(rraw.referenceType) - 1);
                                    }
                                } 
                                rraw.referenceType = param1;
                            }
                            
                            if (param2 != '' && param2 != null) {
                                rraw.deadline = Date.parse(param2);
                                rraw.deadLineDate = param2;
                            }
                            rraw.notes = param3;
                            
                            if (rraw.accountName == ConstantsController.UNSPECIFIED) {
                                isUnspecifiedPresent = true;
                                showGenNotes = true;
                            } 
                            
                            if (!isManaged) {
                                isManaged = rraw.isManaged;
                            }                         
                        }
                    }
                    
                    // re #564 - Allow reference Type which is Managed
                    if (rraw.isManaged || rraw.accountName == ConstantsController.UNSPECIFIED || (refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                        refTypeIdSet.add(rraw.referenceType); 
                    }
                }
                refTypeMappingMap.put(param1, refc);
            }
            refUseAttr.refTypeIdsSet = refTypeIdSet; 
            
            // if there is an uspecified request selected
            // re #564 - Allow reference Type which is Managed
            if (isUnspecifiedPresent == true || isManaged || isRefTypeManaged) {
                isGenInfoDisplay = true;
                showGenNotes = true; 
                // if a single record is selected
                Map<String, Schema.SObjectType> schemaMap = CRUDAndFLSCheckController.sObjectsMap;
                Schema.SObjectType referRequestAddInfoSchema = schemaMap.get(UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c');
                Map<String, Schema.SObjectField> fieldMap = referRequestAddInfoSchema.getDescribe().fields.getMap();
                
                for (Reference_Type_Mapping__c refer: [SELECT Id, Name, Referenceability_Type__c, Required__c, Visible__c,
                                                        Referenceability_Type__r.Name, Referenceability_Type__r.Managed__c
                                                        FROM Reference_Type_Mapping__c
                                                        WHERE Label__c = null
                                                        AND Referenceability_Type__c != null
                                                        LIMIT :limits.getLimitQueryRows()]) {
                    
                    if (fieldMap.get(refer.Name) != null && fieldMap.get(refer.Name).getDescribe().isCreateable() && fieldMap.get(refer.Name).getDescribe().isCustom()) {
                        
                        for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                            boolean fieldPresent = false; 
                            
                            // re #564 - Allow reference Type which is Managed
                            if ((rraw.isManaged || rraw.accountName == ConstantsController.UNSPECIFIED || refer.Referenceability_Type__r.Managed__c) && rraw.referenceType == refer.Referenceability_Type__c) {
                                
                                if (!referNamesOfFields.containsKey(refer.Referenceability_Type__c)) {
                                    referNamesOfFields.put(refer.Referenceability_Type__c, new List<Reference_Type_Mapping__c> ());
                                }
                                
                                for (Reference_Type_Mapping__c referMapping : referNamesOfFields.get(refer.Referenceability_Type__c)) {
                                    
                                    if (referMapping.Name != '' && refer.Name == referMapping.Name) {
                                        fieldPresent = true;
                                    }
                                }
                                
                                if (fieldPresent == false) {
                                    referNamesOfFields.get(refer.Referenceability_Type__c).add(refer);
                                }
                                
                                if (!additionalFieldsInfo.containsKey(refer.Referenceability_Type__c)) {
                                    additionalFieldsInfo.put(refer.Referenceability_Type__c, new Reference_Request_Additional_Info__c());
                                    refFieldSet.add(refer.Referenceability_Type__c);
                                }
                                usedRefSet.add(refer.Referenceability_Type__c);
                            }
                        }
                    }
                }
                
                // if all the selected requests should have a common ref type then delete all the other ref type mappings
                // and field properties delete all the other ref type mappings and field properties
                for (Id referId : referNamesOfFields.keySet()) {
                    
                    if (!usedRefSet.contains(referId)) {
                        
                        if (additionalFieldsInfo.containsKey(referId)) {
                            additionalFieldsInfo.remove(referId);
                        }
                        referNamesOfFields.remove(referId);
                    }
                }
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts) {  
                    
                    // re #564 - Allow reference Type which is Managed
                    if (rraw.isManaged || rraw.accountName == ConstantsController.UNSPECIFIED || ( refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                        
                        if (!referNamesOfFields.containsKey(rraw.referenceType) && refNoteSet.contains(rraw.referenceType)) {
                            referNamesOfFields.put(rraw.referenceType, new List<Reference_Type_Mapping__c> ());
                        }
                    }
                }
                
                for (Id refId : referNamesOfFields.keySet()) {
                    
                    if (!additionalFieldsInfo.containsKey(refId)) {
                        additionalFieldsInfo.put(refId, new Reference_Request_Additional_Info__c());
                    }
                }
            } else {  
                Set<Id> RefSet = new Set<Id>();
                boolean isManagedRefType = false;
                
                for (ReferenceUseAccountWrapper rraw: selectedAccounts) {  
                    
                    // re #564 - Allow reference Type which is Managed
                    if (rraw.isManaged || rraw.AccountName == ConstantsController.UNSPECIFIED || (refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                        isManagedRefType = true;
                        RefSet.add(rraw.referenceType);                     
                    }
                }
                
                if (isManagedRefType) {
                    
                    for (Id referId : referNamesOfFields.keySet()) {
                        
                        // re #564 - remove if selected referencibility type is managed.
                        if (!RefSet.contains(referId)) {    
                            
                            if (additionalFieldsInfo.containsKey(referId)) {
                                additionalFieldsInfo.remove(referId);
                            } 
                            referNamesOfFields.remove(referId);
                        }
                    }
                } else {
                    
                    // re #564 - remove All field/Field info if no manage request found.
                    for (Id referId : referNamesOfFields.keySet()) {                        
                        additionalFieldsInfo.remove(referId);
                        referNamesOfFields.remove(referId); 
                    }
                    showGenNotes = false;
                }
            }
            isP2PRequest = false;
            refUseAttr.isP2PRequest = isP2PRequest ;

            if (cs.Adv_Request_Routing__c && selectedAccounts.size() != 0) {
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                    
                    if (!rraw.isManaged && (refTypeMap.get(rraw.referenceType) == null || !Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                        isP2PRequest = true;
                        refUseAttr.isP2PRequest = isP2PRequest ;
                    }
                }
            }

            if (!isP2PRequest) {
                removeAllGroups();
            }
            
            //REF-2366
            refUseAttr.getMapAllAttrributesLabel();
            refUseAttr.getMapAttrributesLabels();
            refUseAttr.getMapAttributeSize();
            
            if (fromWhere == 'SF1') {
                return null;
            } else {
                return null;
            }
        } catch (Exception ex) { 
            isMessageRender = true;
            isGenInfoDisplay = false;
            Apexpages.addMessages(ex);
            return null;
        }
    }
    
    /**
     * Method to select Reference Use Attributes
     */
    public pageReference selectRefUseAttr() {
        isDeadlineRefBlank = false;
        //REF-2653
        isFromAttributeResults = false;
        showOveray = false;
        String refTypeString = '';
        
        if (refTypeIdSet.size() > 0) {
            
            for (String refId : refTypeIdSet) {
                refTypeString += (refTypeString == '' ? '' : ',') + refId;
            }
            refTypeIdSetString = JSON.serialize(refTypeString);
        }
        Integer count = 1;
        String accountValue = '';
        ReferenceUseInstanceWrapper ruiw;
        Map<String,ReferenceUseInstanceWrapper> mapRBIIdReferenceUseInstanceWrapper = new Map<String,ReferenceUseInstanceWrapper>();
        
        if (selectedAccounts.size() > 0) {
            
            for (ReferenceUseAccountWrapper ruaw : selectedAccounts) {
                
                if (ruaw.acc.Account__c != null) {
                    accountValue = String.valueOf(ruaw.acc.Account__c);
                } else {
                    accountValue = ConstantsController.UNSPECIFIED + count;
                    count ++;
                }
                ruiw = new ReferenceUseInstanceWrapper();
                ruiw.accountName = ruaw.accountName;
                ruiw.referenceType = (ruaw.referenceType != null) ? String.valueOf(ruaw.referenceType) : '';
                ruiw.deadline  = (ruaw.deadLineDate != null && ruaw.deadLineDate != '') ? String.valueOf(ruaw.deadLineDate) : '';
                ruiw.notes  = (ruaw.notes != null && ruaw.notes != '') ? String.valueOf(ruaw.notes) : '';
                ruiw.recordCount  = (ruaw.recordCount != null) ? String.valueOf(ruaw.recordCount) : '';
                ruiw.isSelected  = String.valueOf(ruaw.isSelected);
                mapRBIIdReferenceUseInstanceWrapper.put(accountValue, ruiw);
                accountValue = '';    
            }
            mapRBIIdReferenceUseInstanceWrapperString = JSON.serialize(mapRBIIdReferenceUseInstanceWrapper); 
        }
        PageReference ReturnPage = new PageReference(Page.SelectReferenceUseAttribute.geturl());
        return ReturnPage;
    }
    
    private Set<String> convertedRRAs = new Set<String>();
    
    /**
     * Method to call Submit button
     */
    public pageReference submitRequest() {
        
        if (checkPermissions()) {
            Savepoint sp = Database.setSavePoint();
            
            try {
                
                if (!validateRoutingGroup()) {  // re #436
                    return null;
                }
                convertedRRAs = new Set<String>();
                Id p2pUserId = null;
                boolean isManaged = false;
                insertRefReqAcc = new List<Reference_Request_Account__c>();
                insertUnspecifiedReq = new List<Unspecified_Request__c>();
                
                if (selectedAccounts == null || !(selectedAccounts.size() > 0)) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, SYSTEM.LABEL.Reference_Use_Request_select_Account));
                    return null;
                }
                
                // Validation Message for General Info Daisplay
                if (isGenInfoDisplay) {
                    
                    for (String str : refUseAttr.mapRequiredLabel.keyset()) {
                        
                        if (refUseAttr.mapRequiredLabel.get(str) && refUseAttr.mapAttributesLabels.get(str).size() < 1) {
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, ConstantsController.ERROR_SELECT_REQUIRED_VALUE));
                            return null;
                        }
                    }
                }
                
                // Validation Message for Ref Type & Deadline
                for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                    
                    if (rraw.referenceType == null || rraw.deadline == null) {
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.Submit_Request_all_fields_must_filled_out));
                        isDeadlineRefBlank = true;
                        return null;
                    }
                } 
                
                // re #436 - Get selected Advance Routing Groups name for mentioned request.
                if (cs.Adv_Request_Routing__c) {
                    
                    if (selectedRoutingGroup.size() > 0) {
                        advanceRoutingGroups = '';
                        
                        for (integer j = 0; j < selectedRoutingGroup.size(); j++) {
                            
                            if (j == 0) {
                                advanceRoutingGroups += selectedRoutingGroup[j].getValue().trim();
                            } else {
                                advanceRoutingGroups += ',' + selectedRoutingGroup[j].getValue().trim();
                            }
                        }
                    }
                }
                // Insert Reference Request
                referenceRequest = new Reference_Request__c(Project_Type__c = 'Member', Case__c = caseId, Lead__c = leadId, Opportunity__c = OpportunityId, Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = ConstantsController.NOT_STARTED, Adv_Routing_Group__c = advanceRoutingGroups); //re #436
                insert referenceRequest;
                cs = UtilityController.getCustomSettings();
                Boolean isAllReqManaged = false;
                Map<String, sObject> currencyMap = new Map<String, sObject>();
                boolean isCurrencyEnabled = UtilityController.isCurrencyEnabled();
                
                if (UserInfo.isMultiCurrencyOrganization() && isCurrencyEnabled) {
                    currencyMap = UtilityController.getAllCurrency();
                }
                
                if (cs.Managed_Request_Opportunity_Threshold__c != null) {
                    
                    if (UserInfo.isMultiCurrencyOrganization() && isCurrencyEnabled) {
                        decimal amount = (cs.Managed_Request_Opportunity_Threshold__c / Decimal.valueOf(string.valueOf(currencyMap.get(string.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate'))));
                        
                        for (Opportunity opp : Database.query('select Amount,CurrencyIsoCode from Opportunity where Id = : opportunityId')) {
                            
                            if (opp.Amount != null) {
                                decimal oppAmount = (opp.Amount / Decimal.valueOf(string.valueOf(currencyMap.get(string.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate'))));
                                
                                if (oppAmount > amount) {
                                    isAllReqManaged = true;
                                }
                            }
                        }
                    } else {
                        
                        for (Opportunity o : [SELECT Amount FROM Opportunity WHERE Id = :opportunityId]) {
                            
                            if (o.amount > cs.Managed_Request_Opportunity_Threshold__c) {
                                isAllReqManaged = true;
                            }
                        }
                    }
                }
                boolean isRepToRep = false;
                mapAccount = new Map<Id, Reference_Basic_Information__c>();
                
                /******************* changes start for #441 *******************/
                // map containing Ids of all the mapped attributes in the advanced routing object
                Map<String, Advanced_Routing__c> mappedAttributesMap = new Map<String, Advanced_Routing__c>();
                Map<String, Advanced_Routing__c> mappedTerritoriesMap = new Map<String, Advanced_Routing__c>();
                
                // here we are getting routing details without read premissions
                for (Advanced_Routing__c ar : WithoutSharingHelperController.getRoutingDetails()) {
                    
                    if (ar.Adv_Routing_Attribute__c != null) {
                        mappedAttributesMap.put(ar.Adv_Routing_Attribute__c, ar);
                    }
                    
                    if (ar.Territory_Id__c != null && ar.Territory_Id__c != '') {
                        mappedTerritoriesMap.put(ar.Territory_Id__c, ar);
                    }
                }
                // getting the account team object and related fields from custom settings
                String accTeamObj = cs.Adv_Rt_Acct_Team_Object__c != null ? cs.Adv_Rt_Acct_Team_Object__c : '';
                String roleField = cs.Adv_Rt_Acct_Team_Role_Picklist__c != null ? cs.Adv_Rt_Acct_Team_Role_Picklist__c : '';
                String rolesToInclude = cs.Adv_Rt_Acct_Team_Roles_to_Include__c != null ? cs.Adv_Rt_Acct_Team_Roles_to_Include__c : '';
                String routingPicklist = cs.Adv_Rt_Acct_Team_Routeby__c != null ? cs.Adv_Rt_Acct_Team_Routeby__c : '';
                String routingPicklistLabel = ''; 
                Map<String,SObject> contactToUserMap = new Map<String,SObject>();
                String contactField = cs.Adv_Rt_Acct_Team_Contact__c != null ? cs.Adv_Rt_Acct_Team_Contact__c : '';
                String userField = cs.Adv_Rt_Acct_Team_User__c != null ? cs.Adv_Rt_Acct_Team_User__c : '';
                String accountIdField = '';
                Schema.DescribeSObjectResult describeresult = Account.SObjectType.getDescribe();
                List<Schema.ChildRelationship> lstChildRelationships = describeresult.getChildRelationships();
                
                for (Schema.ChildRelationship cr : lstChildRelationships) {
                    
                    if (cr.getChildSObject().getDescribe().getName() == accTeamObj) {
                        accountIdField = cr.getField().getDescribe().getName();
                    }
                }
                
                // getting the data for account team object
                Map<String, List<sObject>> accTeamMap = new Map<String, List<sObject>>();
                List<String> selectedAccountIds = new List<String>();
                String accTeamQuery = 'SELECT Id, ';
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                    selectedAccountIds.add(rraw.acc.Account__c);
                }
                
                if (accTeamObj != '' && routingPicklist != '' && userField != '' && accountIdField != '') {
                    
                    if (contactField != null && contactField != '') {
                        accTeamQuery += contactField + ', ' + accountIdField ;
                        
                        if (roleField != null && roleField != '' && roleField != routingPicklist) { 
                            accTeamQuery += ', ' + roleField;
                        }
                        accTeamQuery += ' FROM ' + accTeamObj
                                    + ' WHERE ' + accountIdField + ' IN :selectedAccountIds ';
                        routingPicklistLabel = CRUDAndFLSCheckController.sObjectsMap.get('Contact').getDescribe().fields.getMap().get(routingPicklist).getDescribe().getLabel();
                    } else {
                        accTeamQuery += routingPicklist + ', ' + userField + ', ' + accountIdField;
                        
                        if (roleField != null && roleField != '' && roleField != routingPicklist) { 
                            accTeamQuery += ', ' + roleField;
                        }
                        accTeamQuery += ' FROM ' + accTeamObj
                                    + ' WHERE ' + accountIdField + ' IN :selectedAccountIds ';
                        routingPicklistLabel = CRUDAndFLSCheckController.sObjectsMap.get(accTeamObj).getDescribe().fields.getMap().get(routingPicklist).getDescribe().getLabel();
                    }
                    // then query user field from contact field and create a seperate map of ContactId to userId
                    List<String> contactIdsList = new List<String>();
                    Map<String, Set<String>> contactAccMap = new Map<String, Set<String>>();
                    Set<String> rolesSet = new Set<String> (rolesToInclude.split(','));
                    
                    for (sObject obj : WithoutSharingHelperController.getAccountTeamList(accTeamQuery, selectedAccountIds)) {
                        Boolean roleChecked = true;
                        if (roleField != null && roleField != '') { 
                            roleChecked = false;
                            String roles = obj.get(roleField) == null ? '' : (String)obj.get(roleField);
                            
                            for (String role : roles.split(';')) {
                                
                                if (rolesSet.contains(role)) {
                                    roleChecked = true;
                                    break;
                                }
                            }
                        }
                        if (roleChecked) {
                            if (!accTeamMap.containsKey((String)obj.get(accountIdField))) {
                                accTeamMap.put((String)obj.get(accountIdField), new List<sObject>());
                            }

                            if (contactField != null && (String)contactField != '') {
                                contactIdsList.add((String)obj.get(contactField));

                                if (!contactAccMap.containsKey((String)obj.get(contactField))) {
                                    contactAccMap.put((String)obj.get(contactField), new Set<String>());
                                }
                                contactAccMap.get((String)obj.get(contactField)).add((String)obj.get(accountIdField));
                            } else {
                                accTeamMap.get((String)obj.get(accountIdField)).add(obj);
                            }
                        }
                    }

                    if (contactIdsList != null && contactIdsList.size() > 0 && contactField != null && (String)contactField != '') {
                        String contactQuery = 'SELECT Id, ' + routingPicklist + ', '
                                            + userField + ' FROM Contact WHERE Id IN :contactIdsList';

                        for (sObject obj : WithoutSharingHelperController.getContactList(contactQuery, contactIdsList)) {

                            if (contactAccMap.containsKey((String)obj.Id) && contactAccMap.get((String)obj.Id) != null) {

                                for (String accId : contactAccMap.get((String)obj.Id)) {

                                    if (accTeamMap.containsKey(accId)) {
                                        accTeamMap.get(accId).add(obj);
                                    }
                                }
                            }
                        }
                    }
                }
                
                // added for #413 - getting the data for territories
                // map containing territory id and respective root parent id
                Map<String, String> territoryParentMap = new Map<String, String>();
                // map containing account id and associated territory ids
                Map<String, List<String>> accTerritoryMap = new Map<String, List<String>>();
                // map containing territory id and associated user ids
                Map<String, List<String>> territoryUserMap = new Map<String, List<String>>();
                
                // for territory mgmt 2.0
                if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory2')) {
                    String territoryQuery = 'SELECT ParentTerritory2Id, Name, Id, ' +
                                            '(SELECT ObjectId FROM ObjectTerritory2Associations ' +
                                            'WHERE ObjectId IN :selectedAccountIds), ' +
                                            '(SELECT UserId FROM UserTerritory2Associations ' +
                                            'WHERE IsActive = true) ' +
                                            'FROM Territory2 LIMIT ' +
                                            limits.getLimitQueryRows();
                    territoryMap = new Map<String, sObject>();
                    
                    for (sObject obj : WithoutSharingHelperController.getTerritory2List(territoryQuery, selectedAccountIds)) {
                        territoryMap.put((String)obj.get('Id'), obj);
                    }
                    
                    for (String territoryId : territoryMap.keySet()) {
                        
                        if (!territoryParentMap.containsKey(territoryId)) {
                            territoryParentMap.put(territoryId, getRootTerritory(territoryId, false));
                        }
                        
                        if (territoryMap.get(territoryId).getSObjects('ObjectTerritory2Associations') != null
                                && territoryMap.get(territoryId).getSObjects('ObjectTerritory2Associations').size() > 0) {
                            
                            for (sObject obj : territoryMap.get(territoryId).getSObjects('ObjectTerritory2Associations')) {
                                
                                if (!accTerritoryMap.containsKey((String)obj.get('ObjectId'))) {
                                    accTerritoryMap.put((String)obj.get('ObjectId'), new List<String>());
                                }
                                accTerritoryMap.get((String)obj.get('ObjectId')).add(territoryId);
                            }
                        }
                        
                        if (territoryMap.get(territoryId).getSObjects('UserTerritory2Associations') != null
                                && territoryMap.get(territoryId).getSObjects('UserTerritory2Associations').size() > 0) {
                            
                            for (sObject obj : territoryMap.get(territoryId).getSObjects('UserTerritory2Associations')) {
                                
                                if (!territoryUserMap.containsKey(territoryId)) {
                                    territoryUserMap.put(territoryId, new List<String>());
                                }
                                territoryUserMap.get(territoryId).add((String)obj.get('UserId'));
                            }
                        }
                    }
                } else if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory')) {    // for territory mgmt 1.0
                    // map containing Account Ids with respective Group Ids
                    Map<String, Set<String>> accountGroupIdsMap = new Map<String, Set<String>>();
                    Set<String> groupIdsSet = new Set<String>();
                    Set<String> territoryIdsSet = new Set<String>();
                    String territoryQuery = 'SELECT Id, ParentTerritoryId, Name ' +
                                            'FROM Territory LIMIT ' +
                                            limits.getLimitQueryRows();
                    territoryMap = new Map<String, sObject>();
                    String accShareQuery = 'SELECT Id, UserOrGroupId, RowCause, AccountId ' +
                                            'FROM AccountShare ' +
                                            'WHERE AccountId IN :selectedAccountIds ' +
                                            'AND RowCause = \'TerritoryManual\'';
                    
                    if (CRUDAndFLSCheckController.sObjectsMap.containsKey('accountshare')) {
                        
                        for (sObject accShare : WithoutSharingHelperController.getAccountShareList(accShareQuery, selectedAccountIds)) {
                            
                            if (!accTerritoryMap.containsKey((String)accShare.get('AccountId'))) {
                                accTerritoryMap.put((String)accShare.get('AccountId'), new List<String>());
                            }
                            
                            if (!accountGroupIdsMap.containsKey((String)accShare.get('AccountId'))) {
                                accountGroupIdsMap.put((String)accShare.get('AccountId'), new Set<String>());
                            }
                            accountGroupIdsMap.get((String)accShare.get('AccountId')).add((String)accShare.get('UserOrGroupId'));
                            
                            if (!groupIdsSet.contains((String)accShare.get('UserOrGroupId'))) {
                                groupIdsSet.add((String)accShare.get('UserOrGroupId'));
                            }
                        }
                    }
                    
                    if (groupIdsSet != null && groupIdsSet.size() > 0) {
                        Map<String, Group> groupsMap = new Map<String, Group>(WithoutSharingHelperController.getGroupsListForAdvRouting(groupIdsSet));
                        
                        // adding the territory id to the associated account value in account territories map
                        for (String accId : accTerritoryMap.keySet()) {
                            
                            for (String groupId : groupsMap.keySet()) {
                                
                                if (accountGroupIdsMap != null
                                        && accountGroupIdsMap.containsKey(accId)
                                        && accountGroupIdsMap.get(accId).contains(groupId)) {
                                    accTerritoryMap.get(accId).add(groupsMap.get(groupId).RelatedId);
                                    
                                    if (!territoryIdsSet.contains(groupsMap.get(groupId).RelatedId)) {
                                        territoryIdsSet.add(groupsMap.get(groupId).RelatedId);
                                    }
                                }
                            }
                        }
                    }
                    
                    for (sObject obj : WithoutSharingHelperController.getTerritory1List(territoryQuery)) {
                        territoryMap.put((String)obj.get('Id'), obj);
                    }
                    
                    for (String territoryId : territoryMap.keySet()) {
                        
                        if (!territoryParentMap.containsKey(territoryId)) {
                            territoryParentMap.put(territoryId, getRootTerritory(territoryId, true));
                        }
                    }
                    
                    String userTerritoryQuery = 'SELECT Id, UserId, TerritoryId ' +
                                                'FROM UserTerritory ' +
                                                'WHERE IsActive = true ' +
                                                'AND TerritoryId IN :territoryIdsSet';
                    
                    for (sObject obj : WithoutSharingHelperController.getUserTerritoryList(userTerritoryQuery, territoryIdsSet)) {
                        
                        if (!territoryUserMap.containsKey((String)obj.get('TerritoryId'))) {
                            territoryUserMap.put((String)obj.get('TerritoryId'), new List<String>());
                        }
                        territoryUserMap.get((String)obj.get('TerritoryId')).add((String)obj.get('UserId'));
                    }
                }
                
                // getting the list of all the selected attributes
                Set<String> tempAttIds = new Set<String>();
                Map<String, List<SelectReferenceUseAttribute.AttributesLabelWrapper>> tempAttrLblMap
                            = new Map<String, List<SelectReferenceUseAttribute.AttributesLabelWrapper>>();
                tempAttrLblMap.putAll(refUseAttr.mapAttributesLabels);
                Boolean isAnyAttributeSpecified = false;
                
                for (String filterId : tempAttrLblMap.keySet()) {
                    
                    if (!isAnyAttributeSpecified) {
                        
                        if (tempAttrLblMap.get(filterId) != null && tempAttrLblMap.get(filterId).size() > 0) {
                            isAnyAttributeSpecified = true;
                        }
                    }
                }
                
                if (tempAttrLblMap != null && tempAttrLblMap.keySet().size() > 0) {
                    
                    for (String filterId : tempAttrLblMap.keySet()) {
                        
                        if (tempAttrLblMap.get(filterId) != null
                                && tempAttrLblMap.get(filterId).size() > 0) {
                            
                            for (SelectReferenceUseAttribute.AttributesLabelWrapper attWrapper : tempAttrLblMap.get(filterId)) {
                                tempAttIds.add(attWrapper.attributeLabel.Attribute__c);
                            }
                        }
                    }
                }
                Map<String, Attribute__c> selectedAttributesMap
                        = new Map<String, Attribute__c>([SELECT Id, Name, Level__c, ParentIds__c,
                                                         Root_Parent__c, Parent__c
                                                         FROM Attribute__c
                                                         WHERE Id IN :tempAttIds]);
                // map for showing selected attributes data in the chatter post and email
                attMapForChatter = new Map<String, Map<String, String>>();
                Set<String> selectedRoutingGroupsTemp = new Set<String>();
                
                if (selectedRoutingGroup != null && selectedRoutingGroup.size() > 0) {
                    
                    for (SelectOption so : selectedRoutingGroup) {
                        selectedRoutingGroupsTemp.add(so.getLabel());
                    }
                }
                
                // loop through the selected accounts
                for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                    // if account is not managed and advanced routing is enabled then
                    // jumping into the new advanced routing flow for P2P requests
                    if (!rraw.isManaged && cs.Adv_Request_Routing__c && !isAllReqManaged && rraw.accountName != ConstantsController.UNSPECIFIED) {
                        
                        if (isAnyAttributeSpecified) {
                            
                            for (String filterId : tempAttrLblMap.keySet()) {
                                
                                if (tempAttrLblMap.get(filterId) != null && tempAttrLblMap.get(filterId).size() > 0) {
                                    
                                    // loop through the selected attributes
                                    for (SelectReferenceUseAttribute.AttributesLabelWrapper attWrapper : tempAttrLblMap.get(filterId)) {
                                        Attribute__c tempAttr = new Attribute__c();
                                        
                                        if (selectedAttributesMap != null && selectedAttributesMap.containsKey(attWrapper.attributeLabel.Attribute__c)) {
                                            tempAttr = selectedAttributesMap.get(attWrapper.attributeLabel.Attribute__c);
                                        }
                                        
                                        if (!attMapForChatter.containsKey(rraw.acc.Account__c)) {
                                            attMapForChatter.put(rraw.acc.Account__c, new Map<String, String>());
                                        }
                                        
                                        if (!attMapForChatter.get(rraw.acc.Account__c).containsKey(attWrapper.attributeLabel.Label__r.Name)) {
                                            attMapForChatter.get(rraw.acc.Account__c).put(attWrapper.attributeLabel.Label__r.Name, '');
                                        }
                                        String oldAttributesValue = attMapForChatter.get(rraw.acc.Account__c).get(attWrapper.attributeLabel.Label__r.Name);
                                        attMapForChatter.get(rraw.acc.Account__c).put(attWrapper.attributeLabel.Label__r.Name,
                                                oldAttributesValue == '' ? tempAttr.Name : oldAttributesValue + ', ' + tempAttr.Name);
                                        
                                        // checking if the selected attribute is mapped
                                        if (mappedAttributesMap != null && mappedAttributesMap.containsKey(attWrapper.attributeLabel.Attribute__c)) {
                                            
                                            // checking if account team exists on the account
                                            if (accTeamMap != null && accTeamMap.containsKey(rraw.acc.Account__c) && accTeamMap.get(rraw.acc.Account__c) != null && accTeamMap.get(rraw.acc.Account__c).size() > 0) {
                                                Boolean matchFoundInAccount = false;
                                                
                                                // loop through the acount team members
                                                for (sObject obj : accTeamMap.get(rraw.acc.Account__c)) {

                                                    // checking if the team member is a match for the selected attribute by comparing account
                                                    // team member routing picklist value to the selected attribute client routing value
                                                    if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(mappedAttributesMap.get(attWrapper.attributeLabel.Attribute__c).Adv_Routing_Client_Value__c)) {
                                                        matchFoundInAccount = true;
                                                        // send request to the team member
                                                        Reference_Request_Account__c rrAcc;
                                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (String)obj.get(userField), Project_Owner__c = (String)obj.get(userField));
                                                        rraw.isRequestCreatedForAccount = true;
                                                        
                                                        // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                        if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                            rrAcc.Managed_Request__c = true;
                                                            rrAcc.Reference_Owner__c = null;
                                                            rrAcc.Project_Owner__c = null;
                                                        }
                                                        insertRefReqAcc.add(rrAcc);
                                                        mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                        mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                        String tempAttributesValue = attMapForChatter.get(rraw.acc.Account__c).get(attWrapper.attributeLabel.Label__r.Name);
                                                        String regex = '(, ' + tempAttr.Name + ',)|(, ' + tempAttr.Name + '$)|(^' + tempAttr.Name + ',)|(^' + tempAttr.Name + '$)';
                                                        Pattern compiledRegex = Pattern.compile(regex);
                                                        Matcher regexMatcher = compiledRegex.matcher(tempAttributesValue);
                                                        Boolean isFound = regexMatcher.find();

                                                        if (isFound) {

                                                            if (regexMatcher.group(1) != null) {
                                                                tempAttributesValue = regexMatcher.replaceFirst(', ***' + tempAttr.Name + '***,');
                                                            }

                                                            if (regexMatcher.group(2) != null) {
                                                                tempAttributesValue = regexMatcher.replaceFirst(', ***' + tempAttr.Name + '***');
                                                            }

                                                            if (regexMatcher.group(3) != null) {
                                                                tempAttributesValue = regexMatcher.replaceFirst('***' + tempAttr.Name + '***,');
                                                            }

                                                            if (regexMatcher.group(4) != null) {
                                                                tempAttributesValue = regexMatcher.replaceFirst('***' + tempAttr.Name + '***');
                                                            }
                                                        }
                                                        attMapForChatter.get(rraw.acc.Account__c).put(attWrapper.attributeLabel.Label__r.Name, tempAttributesValue);
                                                    }
                                                }
                                                
                                                // if no match is found for the selected attribute in the account team
                                                if (!matchFoundInAccount) {
                                                    // send request to fallback recipient
                                                    Reference_Request_Account__c rrAcc;
                                                    
                                                    if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                    } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID), Project_Owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID));
                                                    }
                                                    rraw.isRequestCreatedForAccount = true;
                                                    
                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                }
                                            } else {
                                                // send request to fallback recipient
                                                Reference_Request_Account__c rrAcc;
                                                
                                                if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID), Project_Owner__c = (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID)));
                                                }
                                                rraw.isRequestCreatedForAccount = true;
                                                
                                                // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                    rrAcc.Managed_Request__c = true;
                                                    rrAcc.Reference_Owner__c = null;
                                                    rrAcc.Project_Owner__c = null;
                                                }
                                                insertRefReqAcc.add(rrAcc);
                                                mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                            }
                                        } else {
                                            
                                            // check for parents of the selected attribute
                                            if (selectedAttributesMap != null && selectedAttributesMap.containsKey(attWrapper.attributeLabel.Attribute__c) && selectedAttributesMap.get(attWrapper.attributeLabel.Attribute__c).ParentIds__c != null && selectedAttributesMap.get(attWrapper.attributeLabel.Attribute__c).ParentIds__c != '') {
                                                Boolean parentFoundInMappingTable = false;
                                                
                                                // loop through the parent attributes of the selected attribute
                                                for (String parentId : selectedAttributesMap.get(attWrapper.attributeLabel.Attribute__c).ParentIds__c.split(',')) {
                                                    
                                                    // checking if any aprent of the attribute is mapped
                                                    if (mappedAttributesMap.containsKey(parentId)) {
                                                        parentFoundInMappingTable = true;
                                                        
                                                        // checking if account team exists on the account
                                                        if (accTeamMap != null && accTeamMap.containsKey(rraw.acc.Account__c) && accTeamMap.get(rraw.acc.Account__c) != null && accTeamMap.get(rraw.acc.Account__c).size() > 0) {
                                                            Boolean matchFoundInAccount = false;
                                                            
                                                            // loop through the account team members
                                                            for (sObject obj : accTeamMap.get(rraw.acc.Account__c)) {

                                                                // checking if the team member is a match for the selected attribute's parent by comparing
                                                                // account team member routing picklist value to the attribute parent's client routing value
                                                                if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(mappedAttributesMap.get(parentId).Adv_Routing_Client_Value__c)) {
                                                                    matchFoundInAccount = true;
                                                                    // send request to the team member
                                                                    Reference_Request_Account__c rrAcc;
                                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (string)obj.get(userField), Project_Owner__c = (string)obj.get(userField));
                                                                    rraw.isRequestCreatedForAccount = true;
                                                                    
                                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                                        rrAcc.Managed_Request__c = true;
                                                                        rrAcc.Reference_Owner__c = null;
                                                                        rrAcc.Project_Owner__c = null;
                                                                    }
                                                                    insertRefReqAcc.add(rrAcc);
                                                                    mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                                    String tempAttributesValue = attMapForChatter.get(rraw.acc.Account__c).get(attWrapper.attributeLabel.Label__r.Name);
                                                                    String regex = '(, ' + tempAttr.Name + ',)|(, ' + tempAttr.Name + '$)|(^' + tempAttr.Name + ',)|(^' + tempAttr.Name + '$)';
                                                                    Pattern compiledRegex = Pattern.compile(regex);
                                                                    Matcher regexMatcher = compiledRegex.matcher(tempAttributesValue);
                                                                    Boolean isFound = regexMatcher.find();

                                                                    if (isFound) {

                                                                        if (regexMatcher.group(1) != null) {
                                                                            tempAttributesValue = regexMatcher.replaceFirst(', ***' + tempAttr.Name + '***,');
                                                                        }

                                                                        if (regexMatcher.group(2) != null) {
                                                                            tempAttributesValue = regexMatcher.replaceFirst(', ***' + tempAttr.Name + '***');
                                                                        }

                                                                        if (regexMatcher.group(3) != null) {
                                                                            tempAttributesValue = regexMatcher.replaceFirst('***' + tempAttr.Name + '***,');
                                                                        }

                                                                        if (regexMatcher.group(4) != null) {
                                                                            tempAttributesValue = regexMatcher.replaceFirst('***' + tempAttr.Name + '***');
                                                                        }
                                                                    }
                                                                    attMapForChatter.get(rraw.acc.Account__c).put(attWrapper.attributeLabel.Label__r.Name, tempAttributesValue);
                                                                }
                                                            }
                                                            
                                                            // if no match is found for the selected routing groups in the account team
                                                            if (!matchFoundInAccount) {
                                                                // send request to fallback recipient
                                                                Reference_Request_Account__c rrAcc;
                                                                
                                                                if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                                } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID), Project_Owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID));
                                                                }
                                                                rraw.isRequestCreatedForAccount = true;
                                                                
                                                                // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                                if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                                    rrAcc.Managed_Request__c = true;
                                                                    rrAcc.Reference_Owner__c = null;
                                                                    rrAcc.Project_Owner__c = null;
                                                                }
                                                                insertRefReqAcc.add(rrAcc);
                                                                mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                                mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                            }
                                                        } else {
                                                            // send request to fallback recipient
                                                            Reference_Request_Account__c rrAcc;
                                                            
                                                            if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                                rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                            } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                                rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID), Project_Owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID));
                                                            }
                                                            rraw.isRequestCreatedForAccount = true;
                                                            
                                                            // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                            if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                                rrAcc.Managed_Request__c = true;
                                                                rrAcc.Reference_Owner__c = null;
                                                                rrAcc.Project_Owner__c = null;
                                                            }
                                                            insertRefReqAcc.add(rrAcc);
                                                            mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                            mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // checking if any request has been created for the current account
                            if (!rraw.isRequestCreatedForAccount) {
                                Boolean isMatchFound = false;
                                
                                // checking if any territories exist on the account
                                if (accTerritoryMap != null && accTerritoryMap.containsKey(rraw.acc.Account__r.Id) && accTerritoryMap.get(rraw.acc.Account__r.Id).size() > 0) {
                                    
                                    // checking if any business groups are selected on the request page
                                    if (selectedRoutingGroupsTemp != null && selectedRoutingGroupsTemp.size() > 0) {
                                        
                                        // loop through the territories on the account
                                        for (String territoryId : accTerritoryMap.get(rraw.acc.Account__r.Id)) {
                                            
                                            // checking if the territory is a match for any of the selected business groups by checking
                                            // if the territory on the account is mapped or a child of a mapped territory and client routing value
                                            // for the mapped territory matches one of the selected business groups
                                            if (mappedTerritoriesMap != null && ((mappedTerritoriesMap.containsKey(territoryId) && selectedRoutingGroupsTemp.contains(mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c)) || (mappedTerritoriesMap.containsKey(territoryParentMap.get(territoryId)) && selectedRoutingGroupsTemp.contains(mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c)))) {
                                                String assignedUserId = '';
                                                
                                                // checking if the territory has an assigned user or not
                                                if (territoryUserMap != null && territoryUserMap.containsKey(territoryId) && territoryUserMap.get(territoryId).size() > 0) {
                                                    isMatchFound = true;
                                                    // send request to the territory assigned user
                                                    assignedUserId = territoryUserMap.get(territoryId)[0];
                                                    Reference_Request_Account__c rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = territoryMap.get(territoryId).get('Name') + ': ' + (mappedTerritoriesMap.containsKey(territoryId) ? mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c : mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = assignedUserId != '' ? assignedUserId : (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID)), Project_Owner__c = assignedUserId != '' ? assignedUserId : (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID)));
                                                    rraw.isRequestCreatedForAccount = true;
                                                    
                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                }
                                            }
                                        }
                                    }
                                }

                                // if a match is not found in the account territories
                                if (!isMatchFound && accTeamMap != null && accTeamMap.containsKey(rraw.acc.Account__c)
                                        && accTeamMap.get(rraw.acc.Account__c) != null && accTeamMap.get(rraw.acc.Account__c).size() > 0) {

                                    if (selectedRoutingGroupsTemp != null && selectedRoutingGroupsTemp.size() > 0) {

                                        for (String selectedGrpName : selectedRoutingGroupsTemp) {

                                            // loop through the acount team members
                                            for (sObject obj : accTeamMap.get(rraw.acc.Account__c)) {

                                                // checking if the team member is a match for the selected attribute by comparing account
                                                // team member routing picklist value to the selected attribute client routing value
                                                if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(selectedGrpName.trim())) {
                                                    isMatchFound = true;
                                                    // send request to the team member
                                                    Reference_Request_Account__c rrAcc;
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = routingPicklistLabel + ': ' + selectedGrpName.trim(), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (String)obj.get(userField), Project_Owner__c = (String)obj.get(userField));
                                                    rraw.isRequestCreatedForAccount = true;
                                                    
                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                if (!isMatchFound) {
                                    // send request to fallback recipient
                                    Reference_Request_Account__c rrAcc;
                                    
                                    if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                    } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID), Project_Owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID));
                                    }
                                    rraw.isRequestCreatedForAccount = true;
                                    
                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                        rrAcc.Managed_Request__c = true;
                                        rrAcc.Reference_Owner__c = null;
                                        rrAcc.Project_Owner__c = null;
                                    }
                                    insertRefReqAcc.add(rrAcc);
                                    mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                }
                            }
                        } else {
                            Boolean isMatchFound = false;
                            
                            // checking if any territories exist on the account
                            if (accTerritoryMap != null && accTerritoryMap.containsKey(rraw.acc.Account__r.Id) && accTerritoryMap.get(rraw.acc.Account__r.Id).size() > 0) {
                                
                                // checking if any business groups are selected on the request page
                                if (selectedRoutingGroupsTemp != null && selectedRoutingGroupsTemp.size() > 0) {
                                    
                                    // loop through the territories on the account
                                    for (String territoryId : accTerritoryMap.get(rraw.acc.Account__r.Id)) {
                                        
                                        // checking if the territory is a match for any of the selected business groups by checking
                                        // if the territory on the account is mapped or a child of a mapped territory and client routing value
                                        // for the mapped territory matches one of the selected business groups
                                        if (mappedTerritoriesMap != null && ((mappedTerritoriesMap.containsKey(territoryId) && selectedRoutingGroupsTemp.contains(mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c)) || (mappedTerritoriesMap.containsKey(territoryParentMap.get(territoryId)) && selectedRoutingGroupsTemp.contains(mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c)))) {
                                            String assignedUserId = '';
                                            
                                            // checking if the territory has an assigned user or not
                                            if (territoryUserMap != null && territoryUserMap.containsKey(territoryId) && territoryUserMap.get(territoryId).size() > 0) {
                                                isMatchFound = true;
                                                // send request to the territory assigned user
                                                assignedUserId = territoryUserMap.get(territoryId)[0];
                                                Reference_Request_Account__c rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = territoryMap.get(territoryId).get('Name') + ': ' + (mappedTerritoriesMap.containsKey(territoryId) ? mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c : mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = assignedUserId != '' ? assignedUserId : (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID)), Project_Owner__c = assignedUserId != '' ? assignedUserId : (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID)));
                                                rraw.isRequestCreatedForAccount = true;
                                                
                                                // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                    rrAcc.Managed_Request__c = true;
                                                    rrAcc.Reference_Owner__c = null;
                                                    rrAcc.Project_Owner__c = null;
                                                }
                                                insertRefReqAcc.add(rrAcc);
                                                mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // if a match is not found in the account territories
                            if (!isMatchFound) {
                                // REF-1929 - check for routing by picklist only
                                // checking if account team exists on the account
                                if (accTeamMap != null && accTeamMap.containsKey(rraw.acc.Account__c) && accTeamMap.get(rraw.acc.Account__c) != null && accTeamMap.get(rraw.acc.Account__c).size() > 0) {

                                    if (selectedRoutingGroupsTemp != null && selectedRoutingGroupsTemp.size() > 0) {

                                        for (String selectedGrpName : selectedRoutingGroupsTemp) {

                                            // loop through the acount team members
                                            for (sObject obj : accTeamMap.get(rraw.acc.Account__c)) {

                                                // checking if the team member is a match for the selected attribute by comparing account
                                                // team member routing picklist value to the selected attribute client routing value
                                                if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(selectedGrpName.trim())) {
                                                    isMatchFound = true;
                                                    // send request to the team member
                                                    Reference_Request_Account__c rrAcc;
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = routingPicklistLabel + ': ' + selectedGrpName.trim(), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (String)obj.get(userField), Project_Owner__c = (String)obj.get(userField));
                                                    rraw.isRequestCreatedForAccount = true;
                                                    
                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                    
                                    // if no match is found for the selected routing groups in the account team
                                    if (!isMatchFound) {
                                        // send request to fallback recipient
                                        Reference_Request_Account__c rrAcc;
                                        
                                        if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                            rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                        } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                            rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID), Project_Owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID));
                                        }
                                        rraw.isRequestCreatedForAccount = true;
                                        
                                        // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                        if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                            rrAcc.Managed_Request__c = true;
                                            rrAcc.Reference_Owner__c = null;
                                            rrAcc.Project_Owner__c = null;
                                        }
                                        insertRefReqAcc.add(rrAcc);
                                        mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                        mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                    }
                                } else {
                                    // send request to fallback recipient
                                    Reference_Request_Account__c rrAcc;
                                    
                                    if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                    } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID), Project_Owner__c = rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID));
                                    }
                                    rraw.isRequestCreatedForAccount = true;
                                    
                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                        rrAcc.Managed_Request__c = true;
                                        rrAcc.Reference_Owner__c = null;
                                        rrAcc.Project_Owner__c = null;
                                    }
                                    insertRefReqAcc.add(rrAcc);
                                    mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                                }
                            }
                        }
                    } else {    // if account is managed or advanced routing is turned off then following existing functionality
                        
                        if (rraw.accountName != ConstantsController.UNSPECIFIED) {
                            // changes for #541 - setting the ref owner null if account is managed
                            Reference_Request_Account__c rrAcc = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id, Deadline__c = rraw.deadline, Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = (rraw.acc.Managed_Reference_Account__c != null ? rraw.acc.Managed_Reference_Account__c : false), Process__c = (rraw.acc.Managed_Reference_Account__c != null ? (rraw.acc.Managed_Reference_Account__c ? ConstantsController.MANAGED : ConstantsController.REP2REP) : ConstantsController.REP2REP), Account_Request_Status__c = (rraw.acc.Managed_Reference_Account__c ? ConstantsController.NOT_STARTED : ConstantsController.IN_PROGRESS), Reference_owner__c = rraw.acc.Managed_Reference_Account__c ? null : (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID)), Project_Owner__c = (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : (rraw.acc.Managed_Reference_Account__c ? null : rraw.acc.Account__r.OwnerID)));
                            
                            if (isAllReqManaged && rrAcc.process__c == ConstantsController.REP2REP) {
                                rrAcc.Process__c = ConstantsController.MANAGED;
                                rrAcc.Managed_Request__c = true;
                                rrAcc.Account_Request_Status__c = ConstantsController.NOT_STARTED;
                                // changes for #541 - ref owner set to null for managed request
                                rrAcc.Reference_owner__c = null;
                                //rrAcc.Reference_owner__c = (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : null);
                                rrAcc.Project_Owner__c = (rraw.acc.Reference_Owner__c != null ? rraw.acc.Reference_Owner__c : null);
                                convertedRRAs.add(rrAcc.Account__c);
                            }
                            
                            if (!rraw.acc.Managed_Reference_Account__c) {
                                isRepToRep = true;
                            }
                            rraw.isRequestCreatedForAccount = true;
                            
                            // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                            if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(refTypeMap.get(rrAcc.Reference_Type_Needed__c).Managed__c) == true) {    
                                rrAcc.Managed_Request__c = true;
                                rrAcc.Reference_Owner__c = null;
                                rrAcc.Project_Owner__c = null;
                            }
                            insertRefReqAcc.add(rrAcc);
                            mapAccountOwnerId.put(rraw.acc.Account__r.Id, rraw.acc.Account__r.OwnerId);
                            mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                            setRefTypesId.add(rraw.referenceType);
                        }
                        
                        if (rraw.AccountName == ConstantsController.UNSPECIFIED) {
                            Unspecified_Request__c unRequest = new Unspecified_Request__c(Deadline__c = rraw.deadline, Unspecified_Request_Status__c = ConstantsController.NOT_STARTED,
                                                                                          Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType,
                                                                                          Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes);
                            insertUnspecifiedReq.add(unRequest);
                            setRefTypesId.add(rraw.referenceType);
                        }
                    }
                }
                Map<String, Reference_Request_Additional_Info__c> copyadditionalFieldsInfo = new Map<String, Reference_Request_Additional_Info__c>();
                copyadditionalFieldsInfo.putAll(additionalFieldsInfo);
                
                for (Id refID : copyadditionalFieldsInfo.keySet()) {
                    
                    if (!refFieldSet.contains(refID)) {
                        copyadditionalFieldsInfo.remove(refID);
                    }
                }
                
                for (Id refID : copyadditionalFieldsInfo.keySet()) {
                    
                    if (referNamesOfFields.containsKey(refID)) {
                        
                        for (Reference_Type_Mapping__c RTM : referNamesOfFields.get(refID)) {
                            
                            if (RTM.Visible__c && RTM.Required__c && (copyadditionalFieldsInfo.get(refID).get(RTM.Name) == null || string.valueOf(copyadditionalFieldsInfo.get(refID).get(RTM.Name)) == '')) {
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.Info, System.Label.ERROR_SELECT_REQUIRED_VALUE));
                                return null;
                            }
                        }
                    }
                }
                
                if (copyadditionalFieldsInfo.size() > 0) {
                    insert copyadditionalFieldsInfo.values();
                    
                    for (Unspecified_Request__c unRequest : insertUnspecifiedReq) {
                        
                        if (copyadditionalFieldsInfo.containsKey(unRequest.Reference_Type_Needed__c)) {
                            unRequest.Reference_Request_Additional_Info__c = copyadditionalFieldsInfo.get(unRequest.Reference_Type_Needed__c).Id;
                        }
                    }
                    
                    for (Reference_Request_Account__c rrAcc : insertRefReqAcc) {
                        
                        if (rrAcc.Managed_Request__c && copyadditionalFieldsInfo.containsKey(rrAcc.Reference_Type_Needed__c)) {
                            rrAcc.Reference_Request_Additional_Info__c = copyadditionalFieldsInfo.get(rrAcc.Reference_Type_Needed__c).Id;
                        }
                    }
                }
                
                if (isRepToRep) {
                    referenceRequest.Reference_Request_Status__c = ConstantsController.IN_PROGRESS;
                    update referenceRequest;
                }
                
                if (insertRefReqAcc.size() > 0) {
                    List<Reference_Request_Account__c> tempList = WithoutSharingHelperController.insertRRA(insertRefReqAcc);
                    insertRefReqAcc = new List<Reference_Request_Account__c>();
                    insertRefReqAcc = WithoutSharingHelperController.getRRARecords(tempList);
                }
                
                // added for #603 - showing onscreen message if any request is re-routed
                //                  to CRP team because of the owner being inactive
                if (ConstantsController.failedRRAAccountNames.size() > 0) {
                    String accNames = '';
                    isRequestRerouted = true;
                    
                    for (String accName : ConstantsController.failedRRAAccountNames) {
                        accNames = accNames == '' ? accName : accNames + ', ' + accName;
                    }
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, 'The Account ' + accNames
                                                               + ' does not have an active Owner. This request has been submitted and re-routed to the Customer Reference Team.'));
                }
                // resetting the set containing failed RRA acount names
                ConstantsController.failedRRAAccountNames = new Set<String>();
                
                if (insertUnspecifiedReq.size() > 0) {
                    insert insertUnspecifiedReq;
                }
                List<Reference_Request_Label__c> newRefReqLabel = new List<Reference_Request_Label__c>();
                List<Reference_Request_Label_Attribute__c> newRefReqAttr = new List<Reference_Request_Label_Attribute__c>();
                
                for (String labelId : refUseAttr.mapRequiredLabel.keySet()) {
                    Reference_Request_Label__c refLabelObj = new Reference_Request_Label__c(Label__c = labelId, Reference_Request__c = referenceRequest.Id);
                    newRefReqLabel.add(refLabelObj);
                }
                
                if (newRefReqLabel.size() > 0) {
                    insert newRefReqLabel;
                }
                
                for (Reference_Request_Label__c refObj : [SELECT Label__c, Id FROM Reference_Request_Label__c
                                                            WHERE Reference_Request__c = :referenceRequest.Id]) {
                    
                    for (SelectReferenceUseAttribute.AttributesLabelWrapper aw : refUseAttr.mapAttributesLabels.get(refObj.Label__c)) {
                        newRefReqAttr.add(new Reference_Request_Label_Attribute__c(Attribute__c = aw.attributeLabel.Attribute__c, Reference_Request_Label__c = refObj.Id));
                    }
                }
                
                if (newRefReqAttr.size() > 0) {
                    insert newRefReqAttr;
                }
                isSubmitted = true;
                isDeadlineRefBlank = false;
                
                // re #119 - Added sales rewards for User
                if (isSubmitted && RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {
                    List<String> lstUserAction = new List<String>();
                    lstUserAction.add(ConstantsController.REQUEST_SALES);
                    List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);  
                    Id ownerId;
                    
                    // re #583 - Null check for User reward points. 
                    if (refType.size() > 0 && refType[0].Sales_Point__c != null) { 
                        List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
                        
                        if (isSubmitted) { 
                            rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, Transaction__c = ConstantsController.ISSUE, 
                                                                RewardDate__c = Date.Today(), User__c = UserInfo.getUserId()));
                            UtilityController.isUserProfileExist(UserInfo.getUserId()); 
                        } 
                        
                        if (rewardsToBeInsert.size() > 0) { 
                            WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
                            
                            // re #591 NEW field Onscreen Notification allow for on/off for onscreen notification.
                            if (cs.User_Reward_Onscreen_Notification__c) {
                                rewardPoints = refType[0].Sales_Point__c; 
                                actionMessage = refType[0].Name; 
                            }
                        }
                    }            
                }
                prepareChatterEmailTaskItem();
                
                //REF-2132
                if (isFromSubmitUploadFiles) {
                    PageReference ref = new PageReference('/apex/ReferenceUseRequest');
                    ref.setRedirect(true);
                    ref.getParameters().put('rrId',referenceRequest.Id);
                    return ref;
                }
                return null;
            } catch (exception ex) {
                Database.rollback(sp);
                isMessageRender = true;
                Apexpages.addMessages(ex);
                return null;
            }
        } else {
            return null;
        }
    }
    
    /**
     * Added for #413
     * Method to get the root parent of territory
     */
    public String getRootTerritory(String territoryId, Boolean isTM1) {
        
        if (isTM1) {
            
            if (territoryMap != null
                    && territoryMap.containsKey(territoryId)
                    && territoryMap.get(territoryId).get('ParentTerritoryId') == null) {
                return (String)territoryMap.get(territoryId).get('Id');
            }
            return getRootTerritory((String)territoryMap.get(territoryId).get('ParentTerritoryId'), isTM1);
        } else {
            
            if (territoryMap != null
                    && territoryMap.containsKey(territoryId)
                    && territoryMap.get(territoryId).get('ParentTerritory2Id') == null) {
                return (String)territoryMap.get(territoryId).get('Id');
            }
            return getRootTerritory((String)territoryMap.get(territoryId).get('ParentTerritory2Id'), isTM1);
        }
    }
    
    /**
     * Validate Routing group #436,#631
     */
    public boolean validateRoutingGroup() {
        
        // re #460, #631 - Check validation for Mandatory Business group value.
        if (cs.Adv_Request_Routing__c && cs.Adv_Routing_Group_Mandatory__c 
                && isP2PRequest && advRoutingGroup.size() > 0 && selectedRoutingGroup.size() == 0) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.info,System.Label.SELECT_ASSOCIATED_FILTER.replace('@@@', advRoutingGrpName)));
            return false;
        } else { 
            selectedGrp = null;
        }
        return true;
    }
    
    /**
     * Method to change Minimum Deadline
     */
    public void changeMinimumDeadline() {
        
        if (referenceType != null && referenceType != '') {
            minimumDeadline = String.valueOf(refTypeMap.get(referenceType).min_lead_time_per_request_type__c);
        }
        refDeadline = calculateDate(Date.today(), Integer.valueOf(minimumDeadline)).format();
        dummyReq.Deadline__c = calculateDate(Date.today(), Integer.valueOf(minimumDeadline)); //for SF1
    }
    
    /**
     * Method to Return to opportunity Page  & Ref Search Page
     */
    public Pagereference returnOpportunity() {
        PageReference ReturnPage;
        
        if (opportunityId == null || opportunityId.trim().length() == 0 || opportunityId == '') {
            String parameter = '?helpoverlay=false';
            ReturnPage = new PageReference(Page.RfSearchPage.geturl() + parameter);
        } else {
            ReturnPage = new PageReference('/' + OpportunityId);
        }
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to Return to case Page  & Ref Search Page
     */
    public Pagereference returnCase() {
        PageReference ReturnPage;
        
        if (caseId == null || caseId.trim().length() == 0 || caseId == '') {
            ReturnPage = new PageReference(Page.RfSearchPage.geturl());
        } else {
            ReturnPage = new PageReference('/' + caseId);
        }
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to Return to lead Page  & Ref Search Page
     * regarding ticket #809
     * Created By: Rekha @6 April 2017
     */
    public Pagereference returnLead() {
        PageReference ReturnPage;
        
        if (leadId == null || leadId.trim().length() == 0 || leadId == '') {
            ReturnPage = new PageReference(Page.RfSearchPage.geturl());
        } else {
            ReturnPage = new PageReference('/' + leadId);
        }
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to cancel request
     * Modified By: Gaurav Saini - REF-1341 (4 Sep, 2018)
     */
    public pageReference cancelRequest() {
        /*
        string parameters = '';
       
        if (opportunityId != null && opportunityId != '' && opportunityId.trim().length() != 0) {
            parameters = '?OpportunityId=' + opportunityId;   
            parameters += '&helpoverlay=false';         
        }
        
        if (caseId != null && caseId != '' && caseId.trim().length() != 0){
            parameters = '?caseId=' + caseId;
        }
        
        // regarding ticket #809
        if (leadId != null && leadId.trim().length() != 0 && leadId != '') {
            parameters = '?leadId=' + leadId;
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
        
        // for #655 send prefilter value to request page 
        if (preFilter == 'true') {
            parameters += '&preFilter=true';
        }

        //  REF-1471
        /*if (opportunityId == null && caseId == null && leadId == null) {
            parameters = '?helpoverlay=false';
        }
        
        PageReference ReturnPage = new PageReference(Page.RfSearchPage.geturl() + parameters);
        ReturnPage.setRedirect(true);                
        */
        return null;
    }
    
    /**
     * Method to prepare Chatter, Email & task data
     */
    private List<Task> listTask = new List<Task>();
    
    private void prepareChatterEmailTaskItem() {
        Map<String, sObject> tempFeedItemRRAMap = new Map<String, sObject>();
        cs = UtilityController.getCustomSettings();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        List<GroupMember> publicGroupMembers
            = new List<GroupMember>([SELECT Id, UserOrGroupId, GroupId
                                     FROM GroupMember
                                     WHERE Group.Name = 'Customer Reference Team'
                                     AND UserOrGroupId NOT IN :UtilityController.getGuestUserId()
                                     LIMIT :limits.getLimitQueryRows()]);
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c', UtilityController.appNamespace() + 'Request_Managed_Email__c', UtilityController.appNamespace() + 'Large_Opportunity_Email__c'};
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c p2pNotification = new Data_Mapping__c();
        Data_Mapping__c managedNotification = new Data_Mapping__c();
        Data_Mapping__c convertedNotification = new Data_Mapping__c();

        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();

        for (Data_Mapping__c dm : [SELECT Field_API_Name__c, Label__c, Section_Name__c, DC_Message__c, Default__c, Visible__c
                                    FROM Data_Mapping__c
                                    WHERE Object__c = 'Notification'
                                    AND (Field_API_Name__c IN :notificationFieldNames
                                        OR Section_Name__c = 'email header doc'
                                        OR Section_Name__c = 'email footer doc')]) {

            if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c') {
                p2pNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Request_Managed_Email__c') {
                managedNotification = dm;
            } else if (dm.Field_API_Name__c == UtilityController.appNamespace() + 'Large_Opportunity_Email__c') {
                convertedNotification = dm;
            } else if (dm.Section_Name__c == 'email header doc') {
                headerDocId = dm.Field_API_Name__c;
            } else if (dm.Section_Name__c == 'email footer doc') {
                footerDocId = dm.Field_API_Name__c;
            }
        }
        String notificationBody;
        String slackMsgBody;
        Map<Id, String> userEmailMap = new Map<Id, String>();

        // Self Service Request
        for (Reference_Request_Account__c rra : insertRefReqAcc) {
            userEmailMap.put(rra.Reference_Owner__c, '');
            
            if (convertedRRAs.contains(rra.Account__c)) {
                notificationBody = convertedNotification.DC_Message__c + '\n\n' + convertedNotification.Default__c;
                notificationBody = notificationBody.replace('[Opportunity Threshold Amount]', String.valueOf(cs.Managed_Request_Opportunity_Threshold__c))
                                    .replace('[Requester Name]', rra.Requester__r.Name)
                                    .replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                    .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                    .replace('[Deadline]', rra.Deadline__c.format())
                                    .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                
                if (checkConvertedEmailSetting) {
                    
                    for (GroupMember gm : publicGroupMembers) {
                        string userId = gm.UserOrGroupId;
                        
                        if (userId.startsWith('005')) {
                            listmail.add(MailChatterController.prepareEmail(convertedNotification.Section_Name__c,
                                                                            gm.UserOrGroupId, notificationBody + '\n\n'
                                                                            + convertedNotification.Section_Name__c + ': ' + '<a href="' + REF_PROJECT_LINK
                                                                            + referenceRequest.Id + '">' + REF_PROJECT_LINK + referenceRequest.Id + '</a>',
                                                                            false, headerDocId, footerDocId));
                        }
                    }
                }
                
                if (checkConvertedChatterSetting) { 
                    
                    for (GroupMember member: publicGroupMembers) {
                        string userId = member.UserOrGroupId;
                        
                        if (userId.startsWith('005')) {
                            // added for #626 - storing the RRA id with the corresponding chatter post
                            tempFeedItemRRAMap.put(rra.Id + '-' + member.UserOrGroupId, MailChatterController.preparePost(convertedNotification.Section_Name__c,
                                                                                member.UserOrGroupId, notificationBody, REF_PROJECT_LINK + referenceRequest.Id));
                        }
                    }
                }
                
                if (checkConvertedSlackSetting) { 
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('text', notificationBody
                        + '\n<' + REF_PROJECT_LINK + referenceRequest.Id + '|'
                        + convertedNotification.Section_Name__c + '>');
                    messagesList.add(tempReqBodyMap);
                }
            }
        }
        
        for (User u : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {
            
            if (u.IsActive) {
                userEmailMap.put(u.Id, u.Email);
            }
        }
        
        for (Reference_Request_Account__c rra : insertRefReqAcc) {
            
            if (!convertedRRAs.contains(rra.Account__c)) {
                
                if (!cs.Adv_Request_Routing__c) {
                    
                    if (!rra.Managed_Request__c) {
                        notificationBody = p2pNotification.DC_Message__c + '\n\n' + p2pNotification.Default__c;
                        slackMsgBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('[User Name]', UserInfo.getName())
                                            .replace('[Selected Filter Attributes]\n', '')
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        notificationBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('Request From: [User Name]\n', '')
                                            .replace('[Selected Filter Attributes]\n', '')
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        
                        if (checkPeer2PeerEmailSetting) {
                            listmail.add(MailChatterController.prepareEmail(p2pNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                                            rra.Reference_Owner__c,
                                                                            notificationBody + '\n\n'
                                                                            + APPROVE_DECLINE_TITLE + ': ' + '<a href="'
                                                                            + APPROVE_DECLINE_LINK_URL + rra.Id + '">'
                                                                            + APPROVE_DECLINE_LINK_URL + rra.Id + '</a>',
                                                                            false, headerDocId, footerDocId));
                        }
                        
                        if (checkPeer2PeerSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Reference_Owner__c));
                            tempReqBodyMap.put('text', slackMsgBody
                                + '\n<' + APPROVE_DECLINE_LINK_URL + rra.Id + '|'
                                + APPROVE_DECLINE_TITLE + '>');
                            messagesList.add(tempReqBodyMap);
                        }
                        
                        if (checkPeer2PeerChatterSetting) {
                            // added for #626 - storing the RRA id with the corresponding chatter post
                            tempFeedItemRRAMap.put(rra.Id + '-' + rra.Reference_Owner__c, MailChatterController.preparePost(APPROVE_DECLINE_TITLE,
                                                                                        rra.Reference_Owner__c, notificationBody, APPROVE_DECLINE_LINK_URL + rra.Id));
                        }
                        rraTaskMap.put(rra.Id, MailChatterController.prepareTask(rra.Reference_Owner__c,
                                                                                    rra.Account__c, rra.Deadline__c,
                                                                                    REFERENCE_REQUEST_TASK_SUBJECT,
                                                                                    notificationBody + '\n\n'
                                                                                        + APPROVE_DECLINE_TITLE + ': ' + '<a href="'
                                                                                        + APPROVE_DECLINE_LINK_URL + rra.Id + '">'
                                                                                        + APPROVE_DECLINE_LINK_URL + rra.Id + '</a>',
                                                                                    ''));
                        listTask.add(MailChatterController.prepareTask(rra.Reference_Owner__c,
                                                                        rra.Account__c, rra.Deadline__c,
                                                                        REFERENCE_REQUEST_TASK_SUBJECT,
                                                                        notificationBody + '\n\n'
                                                                            + APPROVE_DECLINE_TITLE + ': ' + '<a href="'
                                                                            + APPROVE_DECLINE_LINK_URL + rra.Id + '">'
                                                                            + APPROVE_DECLINE_LINK_URL + rra.Id + '</a>',
                                                                        ''));
                    }
                } else {
                    
                    if (!rra.Managed_Request__c) {
                        notificationBody = p2pNotification.DC_Message__c + '\n\n' + p2pNotification.Default__c;
                        slackMsgBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('[User Name]', UserInfo.getName())
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        notificationBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('Request From: [User Name]\n', '')
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        
                        if (checkPeer2PeerEmailSetting) {
                            listmail.add(MailChatterController.prepareEmail(
                                p2pNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name), rra.Reference_Owner__c,
                                MailChatterController.prepareChatterEmailMessageForAdvanceRouting(notificationBody,
                                    attMapForChatter.containsKey(rra.Account__c) ? attMapForChatter.get(rra.Account__c) : new Map<String, String>())
                                + '\n\n' + APPROVE_DECLINE_TITLE + ': ' + '<a href="' + APPROVE_DECLINE_LINK_URL + rra.Id + '">'
                                + APPROVE_DECLINE_LINK_URL + rra.Id + '</a>',
                                false, headerDocId, footerDocId));
                        }
                        
                        if (checkPeer2PeerChatterSetting) {
                            
                            // added for #626 - storing the RRA id with the corresponding chatter post
                            tempFeedItemRRAMap.put(rra.Id + '-' + rra.Reference_Owner__c, MailChatterController.preparePost(
                                APPROVE_DECLINE_TITLE, rra.Reference_Owner__c,
                                MailChatterController.prepareChatterEmailMessageForAdvanceRouting(notificationBody,
                                    attMapForChatter.containsKey(rra.Account__c) ? attMapForChatter.get(rra.Account__c) : new Map<String, String>()),
                                APPROVE_DECLINE_LINK_URL + rra.Id));
                        }
                        
                        if (checkPeer2PeerSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Reference_Owner__c));
                            tempReqBodyMap.put('text', MailChatterController.prepareChatterEmailMessageForAdvanceRouting(slackMsgBody,
                                    attMapForChatter.containsKey(rra.Account__c) ? attMapForChatter.get(rra.Account__c) : new Map<String, String>())
                                + '\n<' + APPROVE_DECLINE_LINK_URL + rra.Id + '|'
                                + APPROVE_DECLINE_TITLE + '>');
                            messagesList.add(tempReqBodyMap);
                        }
                        rraTaskMap.put(rra.Id, MailChatterController.prepareTask(
                            rra.Reference_Owner__c,
                            rra.Account__c,
                            rra.Deadline__c,
                            REFERENCE_REQUEST_TASK_SUBJECT,
                            (mapAccount.get(rra.Account__c).Managed_Reference_Account__c
                             ? UNSPECIFIED_REQUEST_MESSAGE
                             : SPECIFIED_REQUEST_MESSAGE)
                            + MailChatterController.prepareChatterEmailMessageForAdvanceRouting(notificationBody,
                                    attMapForChatter.containsKey(rra.Account__c) ? attMapForChatter.get(rra.Account__c) : new Map<String, String>())
                            + '\n\n' + APPROVE_DECLINE_TITLE + ': '
                            + (mapAccount.get(rra.Account__c).Managed_Reference_Account__c
                               ? REF_PROJECT_LINK + referenceRequest.Id
                               : APPROVE_DECLINE_LINK_URL + rra.Id),
                            ''));
                        listTask.add(MailChatterController.prepareTask(
                            rra.Reference_Owner__c,
                            rra.Account__c,
                            rra.Deadline__c,
                            REFERENCE_REQUEST_TASK_SUBJECT,
                            (mapAccount.get(rra.Account__c).Managed_Reference_Account__c
                             ? UNSPECIFIED_REQUEST_MESSAGE
                             : SPECIFIED_REQUEST_MESSAGE)
                            + MailChatterController.prepareChatterEmailMessageForAdvanceRouting(notificationBody,
                                    attMapForChatter.containsKey(rra.Account__c) ? attMapForChatter.get(rra.Account__c) : new Map<String, String>())
                            + '\n\n' + APPROVE_DECLINE_TITLE + ': '
                            + (mapAccount.get(rra.Account__c).Managed_Reference_Account__c
                               ? REF_PROJECT_LINK + referenceRequest.Id
                               : APPROVE_DECLINE_LINK_URL + rra.Id),
                            ''));
                    }
                }
            }
        }
        
        // Managed Request
        if (!checkManagedChatterSetting) {
            
            // for the specified managed requests
            for (Reference_Request_Account__c rra : insertRefReqAcc) {
                
                if (!convertedRRAs.contains(rra.Account__c)) {
                    
                    if (rra.Managed_Request__c) {
                        notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
                        slackMsgBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('[User Name]', UserInfo.getName())
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        notificationBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('Request From: [User Name]\n', '')
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        
                        if (checkManagedEmailSetting) {
                            
                            for (GroupMember gm : publicGroupMembers) {
                                String userId = gm.UserOrGroupId;
                                
                                if (userId.startsWith('005')) {
                                    listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                                                    gm.UserOrGroupId, notificationBody + '\n\n'
                                                                                    + managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                                                                    + ': ' + '<a href="' + REF_PROJECT_LINK + referenceRequest.Id + '">' + REF_PROJECT_LINK + referenceRequest.Id + '</a>',
                                                                                    false, headerDocId, footerDocId));
                                }
                            }
                        }
                        
                        if (checkManagedSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('text', slackMsgBody
                                + '\n<' + REF_PROJECT_LINK + referenceRequest.Id + '|'
                                + managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name) + '>');
                            messagesList.add(tempReqBodyMap);
                        }
                    }
                }
            }
            
            // for the unspecified requests
            if (checkManagedEmailSetting) {
                
                for (Unspecified_Request__c ur : insertUnspecifiedReq) {
                    notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
                    notificationBody = notificationBody.replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                        .replace('[Request Type]', mapReferenceType.get(ur.Reference_Type_Needed__c).Name)
                                        .replace('[Deadline]', ur.Deadline__c.format())
                                        .replace('Request From: [User Name]\n', '')
                                        .replace('[Request Notes]', UtilityController.checkValueOfString(ur.Request_Notes__c));
                    
                    for (GroupMember member : publicGroupMembers) {
                        string userId = member.UserOrGroupId;
                        
                        if (userId.startsWith('005')) {
                            listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED), member.UserOrGroupId,
                                                                            notificationBody + '\n\n' + managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED) + ': ' + '<a href="'
                                                                                + REF_PROJECT_LINK + referenceRequest.Id + '">' + REF_PROJECT_LINK + referenceRequest.Id + '</a>', false, headerDocId, footerDocId));
                        }
                    }
                }
            }
            
            // for the unspecified requests
            if (checkManagedSlackSetting) {
                
                for (Unspecified_Request__c ur : insertUnspecifiedReq) {
                    notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
                    notificationBody = notificationBody.replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                        .replace('[Request Type]', mapReferenceType.get(ur.Reference_Type_Needed__c).Name)
                                        .replace('[Deadline]', ur.Deadline__c.format())
                                        .replace('[User Name]', UserInfo.getName())
                                        .replace('[Request Notes]', UtilityController.checkValueOfString(ur.Request_Notes__c));
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('text', notificationBody
                        + '\n<' + REF_PROJECT_LINK + referenceRequest.Id + '|'
                        + managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED) + '>');
                    messagesList.add(tempReqBodyMap);
                }
            }
        } else if (checkManagedChatterSetting) {
            
            // for the specified managed requests
            for (Reference_Request_Account__c rra : insertRefReqAcc) {
                
                if (!convertedRRAs.contains(rra.Account__c)) {
                    
                    if (rra.Managed_Request__c) {
                        notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
                        slackMsgBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('[User Name]', UserInfo.getName())
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        notificationBody = notificationBody.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                            .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                            .replace('[Deadline]', rra.Deadline__c.format())
                                            .replace('Request From: [User Name]\n', '')
                                            .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                        
                        // Prepare Emails
                        if (checkManagedEmailSetting) {
                            
                            // changes for #541 - send managed request notifications to CRP team 
                            for (GroupMember gm : publicGroupMembers) {
                                String userId = gm.UserOrGroupId;
                                
                                if (userId.startsWith('005')) {
                                    listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name), gm.UserOrGroupId,
                                                                                    notificationBody + '\n\n' + managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                                                                        + ': ' + '<a href="' + REF_PROJECT_LINK + referenceRequest.Id + '">' + REF_PROJECT_LINK + referenceRequest.Id + '</a>', false, headerDocId, footerDocId));
                                }
                            }
                        }
                        
                        if (checkManagedSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('text', slackMsgBody
                                + '\n<' + REF_PROJECT_LINK + referenceRequest.Id + '|'
                                + managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name) + '>');
                            messagesList.add(tempReqBodyMap);
                        }
                        
                        // Prepare Chatter 
                        for (GroupMember member : publicGroupMembers) {
                            String userId = member.UserOrGroupId;
                            
                            if (userId.startsWith('005')) {
                                
                                // added for #626 - storing the RRA id with the corresponding chatter post
                                tempFeedItemRRAMap.put(rra.Id + '-' + member.UserOrGroupId, MailChatterController.preparePost(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                                                                member.UserOrGroupId, notificationBody, REF_PROJECT_LINK + referenceRequest.Id));
                            }
                        }
                    }
                }
            }
            // for the unspecified requests
            for (Unspecified_Request__c ur : insertUnspecifiedReq) {
                notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
                slackMsgBody = notificationBody.replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                    .replace('[Request Type]', mapReferenceType.get(ur.Reference_Type_Needed__c).Name)
                                    .replace('[Deadline]', ur.Deadline__c.format())
                                    .replace('[User Name]', UserInfo.getName())
                                    .replace('[Request Notes]', UtilityController.checkValueOfString(ur.Request_Notes__c));
                notificationBody = notificationBody.replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                    .replace('[Request Type]', mapReferenceType.get(ur.Reference_Type_Needed__c).Name)
                                    .replace('[Deadline]', ur.Deadline__c.format())
                                    .replace('Request From: [User Name]\n', '')
                                    .replace('[Request Notes]', UtilityController.checkValueOfString(ur.Request_Notes__c));
                
                // Prepare Emails
                if (checkManagedEmailSetting) { 
                    
                    for (GroupMember member : publicGroupMembers) {
                        String userId = member.UserOrGroupId;
                        
                        if (userId.startsWith('005')) {
                            listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED), member.UserOrGroupId,
                                                                        notificationBody + '\n\n' + managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                                                        + ': ' + '<a href="' + REF_PROJECT_LINK + referenceRequest.Id + '">' + REF_PROJECT_LINK + referenceRequest.Id + '</a>', false, headerDocId, footerDocId));
                        }
                    }
                }
                
                if (checkManagedSlackSetting) { 
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('text', slackMsgBody
                        + '\n<' + REF_PROJECT_LINK + referenceRequest.Id + '|'
                        + managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED) + '>');
                    messagesList.add(tempReqBodyMap);
                }
                
                // Prepare Chatter 
                for (GroupMember member : publicGroupMembers) {
                    String userId = member.UserOrGroupId;
                    
                    if (userId.startsWith('005')) {
                        // added for #626 - storing the RRA id with the corresponding chatter post
                        tempFeedItemRRAMap.put(ur.Id + '-' + member.UserOrGroupId, MailChatterController.preparePost(managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED),
                                                                            member.UserOrGroupId, notificationBody, REF_PROJECT_LINK + referenceRequest.Id));
                    }
                }
            }
        }
        
        // Insert list of feedItemRRAMap
        if (tempFeedItemRRAMap.size() > 0) {
            // changes for #626 - Gaurav Saini (13 Dec, 2016)
            tempFeedItemRRAMap = WithoutSharingHelperController.insertPostFeedItemsMap(tempFeedItemRRAMap);
            
            for (String ids : tempFeedItemRRAMap.keySet()) {
                
                if (!feedItemRRAMap.containsKey(ids.split('-')[0])) {
                    feedItemRRAMap.put(ids.split('-')[0], new Set<sObject>());
                }
                feedItemRRAMap.get(ids.split('-')[0]).add(tempFeedItemRRAMap.get(ids));
            }
        }
        
        // Send List of emails
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
        }
        
        // Insert list of tasks
        if (rraTaskMap.size() > 0) {
            rraTaskMap = WithoutSharingHelperController.insertTaskMap(rraTaskMap);
            listTask = rraTaskMap.values();
        }
        
        // Call Method update taskId in Reference_Request_Account__c Object
        updateRefReqAccountsTaskId();
        // call method to update RRA records with appropriate feeditem Ids
        updateRefReqAccountsFeedItemId();
    }
    
    /**
     * Description: method to populate the chatter post id field on RRA record with the appropriate FeedItem Id
     * Author: Gaurav Saini (13 Dec, 2016)
     * Last Modified By: Gaurav Saini (13 Dec, 2016)
     */
    private void updateRefReqAccountsFeedItemId() {
        List<Reference_Request_Account__c> RRAsToUpdate = new List<Reference_Request_Account__c>();
        List<Unspecified_Request__c> URsToUpdate = new List<Unspecified_Request__c>();
        
        for (Reference_Request_Account__c rra : insertRefReqAcc) {
            
            if (feedItemRRAMap.containsKey(rra.Id)) {
                
                for (sObject fi : feedItemRRAMap.get(rra.Id)) {
                    
                    if (rra.Related_Feed_Item_Ids__c == null || rra.Related_Feed_Item_Ids__c == '') {
                        rra.Related_Feed_Item_Ids__c = fi.Id;
                    } else {
                        rra.Related_Feed_Item_Ids__c += ',' + fi.Id;
                    }
                }
                RRAsToUpdate.add(rra);
            }
        }
        
        //related to #867
        // for the unspecified requests
        for (Unspecified_Request__c ur : insertUnspecifiedReq) {
            
            if (feedItemRRAMap.containsKey(ur.Id)) {
                
                for (sObject fi : feedItemRRAMap.get(ur.Id)) {
                    
                    if (ur.Related_Feed_Item_Ids__c == null || ur.Related_Feed_Item_Ids__c == '') {
                        ur.Related_Feed_Item_Ids__c = fi.Id;
                    } else {
                        ur.Related_Feed_Item_Ids__c += ',' + fi.Id;
                    }
                }
                URsToUpdate.add(ur);
            }
        }
        
        // update updateRefReqAccounts;
        if (RRAsToUpdate != null && RRAsToUpdate.size() > 0) {
            RRAsToUpdate = WithoutSharingHelperController.updateRRA(RRAsToUpdate);
        }
        
        // update unspecified requests;
        if (URsToUpdate.size() > 0) {
            URsToUpdate = WithoutSharingHelperController.updateUnspecified(URsToUpdate);
        }
    }
    
    /**
     * Method to insert taskId in Reference_Request_Account__c Object
     */
    private List<Reference_Request_Account__c> updateRefReqAccounts = new List<Reference_Request_Account__c>();
    private void updateRefReqAccountsTaskId() {
        
        for (Reference_Request_Account__c rra : insertRefReqAcc) {
            
            if (!cs.Adv_Request_Routing__c) {
                
                for (Task lstTask : listTask) {
                    
                    if (rra.Account__c == lstTask.WhatId) {
                        rra.Task_ID__c = lstTask.Id;
                        updateRefReqAccounts.add(rra);
                    }
                }
            } else {
                
                if (rraTaskMap.containsKey(rra.Id) && rraTaskMap.get(rra.Id) != null) {
                    rra.Task_ID__c = rraTaskMap.get(rra.Id).Id;
                    updateRefReqAccounts.add(rra);
                }
            }
        }
        
        // update updateRefReqAccounts;
        if (updateRefReqAccounts.size() > 0) {
            updateRefReqAccounts = WithoutSharingHelperController.updateRRA(updateRefReqAccounts);
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
     * Wrapper Class
     */
    public class ReferenceUseAccountWrapper {
        public Reference_Basic_Information__c acc { get; set; }
        public integer unspecifiedCount { get; set; }
        public string accountName { get; set; }
        public integer recordCount { get; set; }
        public Id referenceType { get; set; }
        public Date deadline { get; set; }
        public string deadLineDate { get; set; }
        public string notes { get; set; }
        public boolean isSelected { get; set; }
        public boolean isManaged { get; set; }
        public string unspecifiedLabel { get; set; }
        public boolean isRequestCreatedForAccount { get; set; }
        
        public ReferenceUseAccountWrapper(Reference_Basic_Information__c acc, String accName, integer Count, boolean isManaged) {
            this.isSelected = false;
            this.isRequestCreatedForAccount = false;
            this.acc = acc;
            this.accountName = accName;
            this.recordCount = Count;
            this.isManaged = isManaged;
            
            if (accName == ConstantsController.UNSPECIFIED) {
                this.unspecifiedLabel = SYSTEM.LABEL.Unspecified;
            }
        }
    }
    
    /**
     * for SF1
     */
    public Reference_Request_Account__c dummyReq { get; set; }
    public String fromWhere { get; set; }
    private String pageUrl { get; set; }
    
    /**
     * Method to get Request Infomation
     */
    public Pagereference getRequestInfo() {
        
        for (ReferenceUseAccountWrapper rraw: selectedAccounts) {
            
            if (rraw.recordCount == integer.valueOf(recordCounts)) {
                dummyReq.Reference_Type_Needed__c = rraw.referenceType;
                
                if (rraw.deadline != null) {
                    dummyReq.Deadline__c = rraw.deadline;
                } else {
                    dummyReq.Deadline__c = calculateDate(Date.today(), Integer.valueOf(UtilityController.getCustomSettings().Minimum_Deadline__c));
                }
                dummyReq.Request_Notes__c = rraw.notes;
            }
        }
        PageReference ReturnPage = Page.SF1_RequestInfo;
        return null;
    }
    
    /**
     * Method to redirect SF1_ReferenceUseRequest
     */
    public Pagereference redirect() {
        return Page.SF1_ReferenceUseRequest;
    }
    
    /**
     * Method to redirect SF1_RequestInfo
     */
    public Pagereference redirectToInfo() {
        return Page.SF1_RequestInfo;
    }
    
    /**
     * Method to redirect SF1_SelectReferenceUseAttribute
     */
    public Pagereference getAttributeOfSelectedLabel() {
        return Page.SF1_SelectReferenceUseAttribute;
    }
    
    //REF-2132
    public void doneUploadingFiles() {
        isSubmitted = true;
        isUploadFiles = false;
    }
    
    
    /**
     * Method to go Attribute Result Page
     * REF-2366
     */
    public Pagereference goToAttributeResults() {
        PageReference pageRef = new PageReference('/apex/AttributeResults');
        pageRef.getParameters().put('fromSelectReferenceUseAttributes','true');
        pageRef.getParameters().put('selectedLabelId',selectedLabelId);
        //REF-2645
        pageRef.getParameters().put('opportunityIdP',opportunityId);
        pageRef.getParameters().put('caseIdP',caseId);
        pageRef.getParameters().put('leadIdP',leadId);
        pageRef.getParameters().put('forAccountP',forAccount);
        pageRef.getParameters().put('forContentP',forContent);
        pageRef.getParameters().put('preFilterP',preFilter);
        
        if (accountIdsString != '') {
            pageRef.getParameters().put('AccoutsIDsP',accountIdsString);  
        }
        return pageRef;
    }
    
    //REF-2366 Method to reset previous instance of page
    public void setPreviousInstanceOfPage() {
        refTypeIdSetString = (String)JSON.deserialize(refTypeIdSetString, String.class);
        
        if (!String.isBlank(refTypeIdSetString)) {
            refUseAttr.refTypeIdsSet = new Set<Id>();
            List<String> listRefTypeIds = refTypeIdSetString.split(',');
            
            for (String refId : listRefTypeIds) {
                
                if (!String.isBlank(refId) && refId != 'null') {
                    refUseAttr.refTypeIdsSet.add(Id.valueOf(refId)); 
                }  
            }
        }
        
        if (!String.isBlank(mapRBIIdReferenceUseInstanceWrapperString)) {
            Map<String,ReferenceUseInstanceWrapper> mapRBIIdReferenceUseInstanceWrapper = 
                (Map<String,ReferenceUseInstanceWrapper>)JSON.deserialize(mapRBIIdReferenceUseInstanceWrapperString, Map<String,ReferenceUseInstanceWrapper>.class);
            
            if (selectedAccounts.size() > 0) {
                
                for (ReferenceUseAccountWrapper ruaw : selectedAccounts) {
                    
                    if (mapRBIIdReferenceUseInstanceWrapper.containsKey(ruaw.acc.Account__c)) {
                        ReferenceUseInstanceWrapper ruiw = mapRBIIdReferenceUseInstanceWrapper.get(ruaw.acc.Account__c);
                        ruaw.referenceType = String.isBlank(ruiw.referenceType) ? null : Id.valueOf(ruiw.referenceType);
                        ruaw.deadLineDate = String.isBlank(ruiw.deadline) ? null : ruiw.deadline;
                        ruaw.deadline = String.isBlank(ruiw.referenceType) ? null : Date.parse(ruiw.deadline);
                        ruaw.notes = String.isBlank(ruiw.notes) ? '' : ruiw.notes;
                        ruaw.recordCount = String.isBlank(ruiw.recordCount ) ? null : Integer.valueOf(ruiw.recordCount);
                        ruaw.isSelected = Boolean.valueOf(ruiw.isSelected);
                    }
                }
                
                for (String key : mapRBIIdReferenceUseInstanceWrapper.keySet()) {
                    
                    if (key.contains(ConstantsController.UNSPECIFIED)) {
                        ReferenceUseInstanceWrapper ruiw = mapRBIIdReferenceUseInstanceWrapper.get(key);
                        ReferenceUseAccountWrapper ruaw = new ReferenceUseAccountWrapper(new Reference_Basic_Information__c(), ConstantsController.UNSPECIFIED, 0, true);
                        ruaw.referenceType = String.isBlank(ruiw.referenceType) ? null : Id.valueOf(ruiw.referenceType);
                        ruaw.deadLineDate = String.isBlank(ruiw.deadline) ? null : ruiw.deadline;
                        ruaw.deadline = String.isBlank(ruiw.referenceType) ? null : Date.parse(ruiw.deadline);
                        ruaw.notes = String.isBlank(ruiw.notes) ? '' : ruiw.notes;
                        ruaw.recordCount = String.isBlank(ruiw.recordCount ) ? null : Integer.valueOf(ruiw.recordCount);
                        ruaw.isSelected = Boolean.valueOf(ruiw.isSelected);
                        selectedAccounts.add(ruaw);
                    } 
                }
            }
        }
        refUseAttr.setLabelAtrr();
        refUseAttr.getMapAllAttrributesLabel();
        refUseAttr.getMapAttrributesLabels();
        refUseAttr.getMapAttributeSize();
        
        Map<String, Schema.SObjectType> schemaMap = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType referRequestAddInfoSchema = schemaMap.get(UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c');
        Map<String, Schema.SObjectField> fieldMap = referRequestAddInfoSchema.getDescribe().fields.getMap();
        
        List<Reference_Type_Mapping__c> listrefTypeMapping = [SELECT Id, Name, Referenceability_Type__c, Required__c, Visible__c,
                                                              Referenceability_Type__r.Name, Referenceability_Type__r.Managed__c
                                                              FROM Reference_Type_Mapping__c
                                                              WHERE Label__c = null
                                                              AND Referenceability_Type__c != null
                                                              LIMIT :limits.getLimitQueryRows()];
        
        if (listrefTypeMapping.size() > 0) {
            
            for (Reference_Type_Mapping__c refer : listrefTypeMapping) {
                
                if (fieldMap.get(refer.Name) != null && fieldMap.get(refer.Name).getDescribe().isCreateable() && fieldMap.get(refer.Name).getDescribe().isCustom()) {
                    
                    for (ReferenceUseAccountWrapper rraw : selectedAccounts) {
                        Boolean fieldPresent = false; 
                        
                        if ((rraw.isManaged || rraw.accountName == ConstantsController.UNSPECIFIED || refer.Referenceability_Type__r.Managed__c) && rraw.referenceType == refer.Referenceability_Type__c) {
                            
                            if (!referNamesOfFields.containsKey(refer.Referenceability_Type__c)) {
                                referNamesOfFields.put(refer.Referenceability_Type__c, new List<Reference_Type_Mapping__c> ());
                            }
                            
                            for (Reference_Type_Mapping__c referMapping : referNamesOfFields.get(refer.Referenceability_Type__c)) {
                                
                                if (referMapping.Name != '' && refer.Name == referMapping.Name) {
                                    fieldPresent = true;
                                }
                            }
                            
                            if (fieldPresent == false) {
                                referNamesOfFields.get(refer.Referenceability_Type__c).add(refer);
                            }
                            
                            if (!additionalFieldsInfo.containsKey(refer.Referenceability_Type__c)) {
                                additionalFieldsInfo.put(refer.Referenceability_Type__c, new Reference_Request_Additional_Info__c());
                                refFieldSet.add(refer.Referenceability_Type__c);
                            }
                        }
                    }
                }
            } 
        }
        refUseAttr.setSelectedAttributes();
    }
    
    public class ReferenceUseInstanceWrapper {
        public String accountName { get; set; }
        public String referenceType { get; set; }
        public String deadline { get; set; }
        public String notes { get; set; }
        public String recordCount { get; set; }
        public String isSelected { get; set; }
    }
}