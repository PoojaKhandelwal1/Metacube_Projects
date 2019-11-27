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
 * Page: ReferenceRequest.page
 * Description: Request submission page for basic edition
 * Last modified by: Gaurav Saini (20 April, 2017) for #702
 */
public with sharing class ReferenceRequestController extends RefEdgeEditionFeatures {
    /**
     * Constants
     */
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    private static String REFERENCE_REQUEST_SUBJECT = 'Self Service Reference Request';
    private static String REFERENCE_REQUEST_MESSAGE = 'I would like to use an account as a reference for which you are the owner.  ';
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContactsSLDS.getURL() + '?id=';
    private static String REFERENCE_REQUEST_TASK_SUBJECT = 'Reference Use Approval Request';
    
    /**
     * Properties and variables
     */
    public Boolean isMessageRender { get; set; }
    public String param1 { get; set; }
    public String param2 { get; set; }
    public String param3 { get; set; }
    public String param4 { get; set; }
    public String selectedIds { get; set; }
    public String OpportunityId { get; set; }
    public String caseId { get; set; }
    public Opportunity opportunity { get; set; }
    public Case caseObj { get; set; }
    // regarding ticket #809
    public Lead leadObj { get; set; }
    public String leadId { get; set; }
    public List<ReferenceRequestAccountWrapper> selectedAccounts { get; set; }
    public String selectedValue { get; set; }
    public Reference_Request_Account__c refRequestAccount { get; set; }
    public List<SelectOption> referenceabilityTypes { get; set; }
    public Boolean isSubmitted { get; set; }
    public Map<String, String> referTypeNameId { get; set; }
    public String refDeadline { get; set; }
    public Map<String, String> refTypeDeadlineMap { get; set; }
    public String referenceType { get; set; }
    public Boolean isDeadlineRefBlank { get; set; }
    public String nameSpace { get; set; }
    public String accountIdToRemoveFromList { get; set; }
    public static String minimumDeadline {
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
            return calculateDate(system.today(), Integer.valueOf(UtilityController.getCustomSettings().Minimum_Deadline__c)).format();
        }
        set;
    }
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
    private String forAccount;
    private String forContent;
    // for #655 send prefilter value to request page
    private String preFilter;
    private Boolean checkChatterSetting;
    private Boolean checkEmailSetting;
    private List<String> listAccountIds = new List<String>();
    private Integer numberOfRequestAccounts;
    private Map<Id, Referenceability_Type__c> refTypeMap;
    private Map<Id, Integer> refTypeMappingMap;
    private List<Reference_Request_Account__c> insertRefReqAccounts = new List<Reference_Request_Account__c>();
    private List<Reference_Request_Account__c> updateRefReqAccounts = new List<Reference_Request_Account__c>();
    private List<sObject> postFeedItems = new List<sObject>();
    // added for #913 - map to store which chatter post is created for each RRA record
    public Map<Id, sObject> feedItemRRAMap { get; set; }
    private List<Task> listTask = new List<Task>();
    private Map<Id, Reference_Basic_Information__c> mapAccount;
    private Map<Id, Referenceability_Type__c> mapReferenceType;
    private Set<String> setRefTypesId = new Set<String>();
    // for SF1
    public Reference_Request_Account__c dummyReq { get; set; }
    public String fromWhere { get; set; }
    private String pageUrl;
    public boolean showOveray { get; set; }
    //REF-1603
    public String helpAssistant { get; set; }  
    private List<User_Mapping__c> userMappingList;
    private Custom_Settings__c cs ;
    private Date lastActivity;
    /**
     * Constructor
     */
    public ReferenceRequestController() {
        isMessageRender = false;
        isDeadlineRefBlank = false;
        selectedIds = '';
        refDeadline = '';
        init();
        dummyReq = new Reference_Request_Account__c(); // for SF1
        fromWhere = ''; // for SF1
        pageUrl = (String) apexPages.currentPage().getUrl(); // for SF1
        refRequestAccount = new Reference_Request_Account__c();
        refTypeDeadlineMap = new Map<String, String>();
        referTypeNameId = new Map<String, String>();
        opportunityId = ApexPages.currentPage().getParameters().get('opportunityId');
        caseId = ApexPages.currentPage().getParameters().get('caseId');
        leadId = ApexPages.currentPage().getParameters().get('leadId');
        forAccount = ApexPages.currentPage().getParameters().get('forAccount');
        forContent = ApexPages.currentPage().getParameters().get('forContent');
        // for #655 send prefilter value to request page
        preFilter = ApexPages.currentPage().getParameters().get('PreFilter');
        nameSpace = UtilityController.appNamespace();
        feedItemRRAMap = new Map<Id, sObject>();
        
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
        
        if (ApexPages.currentPage().getParameters().get('AccoutsIDs') != null
                    && ApexPages.currentPage().getParameters().get('AccoutsIDs') != '') {
            listAccountIds = UtilityController.convertCommaSeperatedStringToArray(ApexPages.currentPage().getParameters().get('AccoutsIDs'));
            selectedAccounts = new List<ReferenceRequestAccountWrapper>();
            
            for (Reference_Basic_Information__c acc : WithoutSharingHelperController.getAccountsRBI(listAccountIds)) {
                ReferenceRequestAccountWrapper rraw = new ReferenceRequestAccountWrapper(acc, new Reference_Request_Account__c());
                selectedAccounts.add(rraw);
            }
        }
        referenceabilityTypes = new List<SelectOption>();
        referenceabilityTypes.add(new SelectOption('', '--None--'));
        Decimal minDeadlineCS = UtilityController.getCustomSettings().Minimum_Deadline__c;
        refTypeDeadlineMap.put(null, String.valueOf(minDeadlineCS));
        refTypeMap = new Map<Id, Referenceability_Type__c>();
        
        for (Referenceability_Type__c refType : [SELECT Name, min_lead_time_per_request_type__c,
                                                    max_accounts_per_request_type__c, Id
                                                    FROM Referenceability_Type__c
                                                    WHERE Visible__c = true AND Request_type__c = true
                                                    AND Sales_Reward__c = false
                                                    ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            referenceabilityTypes.add(new SelectOption(refType.Id, refType.Name));
            refTypeMap.put(refType.Id, refType);
            referTypeNameId.put(refType.Id, refType.Name);
            refTypeDeadlineMap.put(refType.Id, String.valueOf((refType.min_lead_time_per_request_type__c != null 
                                            ? refType.min_lead_time_per_request_type__c : minDeadlineCS)));
        }
        referTypeNameId.put(null, '');
        refTypeMappingMap = new Map<Id, Integer>();
        
        for (String Id : refTypeMap.keySet()) {
            refTypeMappingMap.put(refTypeMap.get(Id).Id, 0);
        }
        checkPermissions();
        showOveray = false;
        lastActivity = date.today();
        userMappingList = new List<User_Mapping__c>();
        checkForHelpOverlay();
    }
    
    /**
     * Method Call FROM Construcor
     */
    void init() {
        param1 = '';
        param2 = '';
        param3 = '';
        param4 = '';
        selectedValue = 'The Record Clicked';
        isSubmitted = false;
        cs = UtilityController.getCustomSettings();
        minimumDeadline = String.valueOf(cs.Minimum_Deadline__c);
        checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Peer2Peer_Chatter__c);
        checkEmailSetting = cs.Request_Peer2Peer_Email__c;
        numberOfRequestAccounts = Integer.valueOf(cs.Number_of_request_accounts__c);
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
 
            if (userMappingList.Size() > 0 && userMappingList[0].Order__c != null && userMappingList[0].Order__c >= cs.Help_Overlay_Count__c) {
                showOveray = false;
            }
            
            if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userMappingList.size() > 0 && userMappingList[0].Last_Used_Classic_Page__c != null) {
                lastActivity = Date.parse(userMappingList[0].Last_Used_Classic_Page__c);
            }  
        }        
    }

    /** 
     *   Method to Manage user mapping for inviation
     *   Author : Rajesh REF-1572
    **/
    public void userMappingRecord() {  
        //  check user mapping count and custom setting count
        
         if (showOveray) { 
            
            if (userMappingList.Size() > 0) {  

                if (userMappingList[0].Order__c != null) {  
                
                    if (cs.Reset_Help_Assistant_Days__c != null && lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c) {
                        helpAssistant = ConstantsController.HELP_ASSISTANT;
                        userMappingList[0].Order__c = 1; 
                    } else {
                        userMappingList[0].Order__c += 1;
                    } 
                } else {
                    userMappingList[0].Order__c = 1; 
                } 
                userMappingList[0].Last_Used_Classic_Page__c = system.today().format(); 
                 
            } else {
                User_Mapping__c umr = new User_Mapping__c();
                umr.Label__c = ConstantsController.REQUEST_HELP_OVERLAY;
                umr.Order__c = 1;
                umr.User__c = UserInfo.getUserId();
                umr.Last_Used_Classic_Page__c = system.today().format(); 
                userMappingList.add(umr);
            } 
        } else if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0 
                    && (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0) 
                    && (lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c)) {
            helpAssistant = ConstantsController.HELP_ASSISTANT;
            userMappingList[0].Order__c = 1;
            userMappingList[0].Last_Used_Classic_Page__c = system.today().format();
            showOveray = true;
        } 

        if (userMappingList.Size() > 0 && cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) { 
            upsert userMappingList;  
        }               
    }

    /**
     * Method to Cancel & Return on search Page
     * Modified By: Rekha Jangir @Jan/12/2017
     */
    public Pagereference redirectToSearchPage() {
        String parameters = '';
         
        if (opportunityId != '' && opportunityId != null && opportunityId.trim().length() != 0) {
            parameters = '?OpportunityId=' + opportunityId;
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
        PageReference ReturnPage = new PageReference(Page.RfSearchPage.geturl() + parameters);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to remove Account FROM List
     */
    public void removeAccountFromList() {
        
        for (Integer i = 0; i < selectedAccounts.size(); i++) {
            
            if (accountIdToRemoveFromList == selectedAccounts.get(i).acc.Account__r.Id) {
                selectedAccounts.remove(i);
                break;
            }
        }
        isDeadlineRefBlank = false;
    }
    
    /**
     * Method to Mass Update Accounts on modal save button
     */
    public void selectAndUpdate() {
        
        try {
            isDeadlineRefBlank = false;
            
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
                param4 = accountIdToRemoveFromList;
                
                if (selectedValue != 'The Record Clicked') {
                    
                    for (ReferenceRequestAccountWrapper rraw : selectedAccounts) {
                        rraw.isSelected = true;
                    }
                }
            }
            
            if (param1 == '' || param1 == null || param2 == '' || param2 == null) {
                isMessageRender = true;
                throw new CustomException(System.Label.Edit_popup_all_fields_must_filled);
            } else {
                Date deadline = Date.parse(param2);
                
                if (param1 != null && param1 != '') {
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
            }
            isMessageRender = false;
            integer refc = 0;
            integer reftypec = 0;
            Referenceability_Type__c refType = refTypeMap.get(param1);
            
            if (selectedValue == 'The Record Clicked') {
                
                if (param1 != '' && param1 != null) {
                    
                    for (ReferenceRequestAccountWrapper rraw: selectedAccounts) {
                        
                        if (rraw.acc.account__c == param4 && rraw.isSelected) {
                            
                            if (rraw.refRequestAccount.Reference_Type_Needed__c != param1) {
                                refc = 1 + refTypeMappingMap.get(param1);
                            } else {
                                refc = refTypeMappingMap.get(param1);
                            }
                        }
                    }
                    
                    if (refTypeMap.get(param1).max_accounts_per_request_type__c != null && refTypeMap.get(param1).max_accounts_per_request_type__c > 0) {
                        
                        if (refc > refTypeMap.get(param1).max_accounts_per_request_type__c) {
                            isMessageRender = true;
                            throw new CustomException((System.Label.No_of_Accounts_Per_ReqType_Error).replace('@@@', 
                                                String.valueOf(refTypeMap.get(param1).max_accounts_per_request_type__c)));
                        }
                    }
                }
                
                for (ReferenceRequestAccountWrapper rraw : selectedAccounts) {
                    
                    if (rraw.acc.account__c == param4 && rraw.isSelected) {
                        
                        if (param1 != '' && param1 != null) {
                            
                            if (rraw.refRequestAccount.Reference_Type_Needed__c != param1 
                                            && refTypeMappingMap.get(rraw.refRequestAccount.Reference_Type_Needed__c) > 0) {
                                reftypec = refTypeMappingMap.get(rraw.refRequestAccount.Reference_Type_Needed__c) - 1;
                                refTypeMappingMap.put(rraw.refRequestAccount.Reference_Type_Needed__c, reftypec);
                            }
                            rraw.refRequestAccount.Reference_Type_Needed__c = param1;
                            refRequestAccount.Reference_Type_Needed__c = param1;
                        }
                        
                        if (param2 != '' && param2 != null) {
                            rraw.refRequestAccount.Deadline__c = Date.parse(param2);
                        }
                        rraw.refRequestAccount.Request_Notes__c = param3;
                    }
                }
                refTypeMappingMap.put(param1, refc);
            } else {
                
                if (param1 != '' && param1 != null) {
                    
                    for (ReferenceRequestAccountWrapper rraw : selectedAccounts) {
                        
                        if (rraw.isSelected) {
                            
                            if (rraw.refRequestAccount.Reference_Type_Needed__c != param1) {
                                refc = refc + 1;
                            }
                        }
                    }
                    refc = refc + refTypeMappingMap.get(param1);
                    
                    if (refTypeMap.get(param1).max_accounts_per_request_type__c != null
                                && refTypeMap.get(param1).max_accounts_per_request_type__c > 0) {
                        
                        if (refc > refTypeMap.get(param1).max_accounts_per_request_type__c) {
                            isMessageRender = true;
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, 
                                                (System.Label.No_of_Accounts_Per_ReqType_Error).replace('@@@', 
                                                String.valueOf(refTypeMap.get(param1).max_accounts_per_request_type__c))));
                            return;
                        }
                    }
                }
                
                for (ReferenceRequestAccountWrapper rraw : selectedAccounts) {
                    
                    if (rraw.isSelected) {
                        
                        if (param1 != '' && param1 != null) {
                            
                            if (rraw.refRequestAccount.Reference_Type_Needed__c != param1) {
                                
                                if (refTypeMappingMap.get(rraw.refRequestAccount.Reference_Type_Needed__c) > 0) {
                                    reftypec = refTypeMappingMap.get(rraw.refRequestAccount.Reference_Type_Needed__c) - 1;
                                    refTypeMappingMap.put(rraw.refRequestAccount.Reference_Type_Needed__c, 
                                                        refTypeMappingMap.get(rraw.refRequestAccount.Reference_Type_Needed__c) - 1);
                                }
                            }
                            rraw.refRequestAccount.Reference_Type_Needed__c = param1;
                        }
                        
                        if (param2 != '' && param2 != null) {
                            rraw.refRequestAccount.Deadline__c = Date.parse(param2);
                        }
                        rraw.refRequestAccount.Request_Notes__c = param3;
                    }
                }
                refTypeMappingMap.put(param1, refc);
            }
        } catch (Exception e) {
            isMessageRender = true;
            Apexpages.addMessages(e);
        }
    }
    
    /**
     * Method to change Minimum Deadline
     */
    public void changeMinimumDeadline() {
        
        if (referenceType != null && referenceType != '') {
            minimumDeadline = String.valueOf(refTypeMap.get(referenceType).min_lead_time_per_request_type__c);
        }
        refDeadline = calculateDate(system.today(), Integer.valueOf(minimumDeadline)).format();
        dummyReq.Deadline__c = calculateDate(system.today(), Integer.valueOf(minimumDeadline)); //for SF1
    }
    
    /**
     * Method to check Permissions
     */
    public Boolean checkPermissions() {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request__c', new Set<String> {
                                                UtilityController.appNamespace() + 'Project_Type__c',
                                                UtilityController.appNamespace() + 'Requester__c',
                                                UtilityController.appNamespace() + 'Reference_Request_Status__c'});
        
        if (opportunityId != null && opportunityId.trim().length() > 0 && opportunityId != '') {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Opportunity__c'); 
        } else if (caseId != null && caseId.trim().length() != 0 && caseId != '') {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Case__c'); 
        // regarding ticket #809
        } else if (leadId != null && leadId.trim().length() != 0 && leadId != '') {
            fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Lead__c'); 
        }
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
    
    /**
     * Method to call Submit button
     */
    public Pagereference submitRequest() {
        
        if (checkPermissions()) {
            Savepoint sp = Database.setSavepoint();
            List<String> accIds = selectedIds.split(',');
            
            try {
                
                if (selectedAccounts == null || selectedAccounts.size() == 0) {
                    Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.ERROR, System.Label.No_selected_records));
                    return null;
                }
                mapAccount = new Map<Id, Reference_Basic_Information__c>();
                insertRefReqAccounts = new List<Reference_Request_Account__c>();
                
                for (ReferenceRequestAccountWrapper rraw : selectedAccounts) {
                    
                    // for SF1
                    if (fromWhere == 'SF1') {
                        rraw.isSelected = true;
                    }
                    
                    if (rraw.isSelected) {
                        
                        if (rraw.refRequestAccount.Reference_Type_Needed__c == null || rraw.refRequestAccount.Deadline__c == null) {
                            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, System.Label.Submit_Request_all_fields_must_filled_out));
                            isDeadlineRefBlank = true;
                            return null;
                        }
                    }
                }
                
                if (numberOfRequestAccounts != null) {
                    
                    if (accIds.size() > numberOfRequestAccounts) {
                        Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, 
                                    (System.Label.Limit_number_of_request_accounts).replace('***', 
                                    String.valueOf(numberOfRequestAccounts))));
                        return null;
                    }
                }
                // Insert ReferenceRequest //regarding ticket #809
                Reference_Request__c referenceRequest
                            = new Reference_Request__c(Project_Type__c = 'Member', Case__c = caseId, Lead__c = leadId,
                                                        Opportunity__c = OpportunityId, Requester__c = UserInfo.getUserId(),
                                                        Reference_Request_Status__c = ConstantsController.IN_PROGRESS);
                insert referenceRequest;
                
                // Insert ReferenceRequestAccounts
                for (ReferenceRequestAccountWrapper rraw : selectedAccounts) {
                    
                    // for SF1
                    if (fromWhere == 'SF1') {
                        rraw.isSelected = true;
                    } else {
                        rraw.isSelected = false;
                        
                        for (String accId : accIds) {
                            
                            if (rraw.acc.Account__r.Id == accId) {
                                rraw.isSelected = true;
                            }
                        }
                    }
                    
                    if (rraw.isSelected) {
                        
                        if (rraw.refRequestAccount.Reference_Type_Needed__c != null || rraw.refRequestAccount.Deadline__c != null) {
                            Reference_Request_Account__c rrAcc
                                        = new Reference_Request_Account__c(Account__c = rraw.acc.Account__r.Id,
                                                                            Deadline__c = rraw.refRequestAccount.Deadline__c,
                                                                            Reference_Request__c = referenceRequest.Id,
                                                                            Reference_Type_Needed__c = rraw.refRequestAccount.Reference_Type_Needed__c,
                                                                            Requester__c = UserInfo.getUserId(),
                                                                            Account_Request_Status__c = ConstantsController.IN_PROGRESS,
                                                                            Process__c = ConstantsController.REP2REP,
                                                                            Reference_owner__c = (rraw.acc.Reference_Owner__c != null
                                                                                ? rraw.acc.Reference_Owner__c : rraw.acc.Account__r.OwnerID),
                                                                            Request_Notes__c = rraw.refRequestAccount.Request_Notes__c);
                            insertRefReqAccounts.add(rrAcc);
                            setRefTypesId.add(rraw.refRequestAccount.Reference_Type_Needed__c);
                        }
                    }
                    mapAccount.put(rraw.acc.Account__r.Id, rraw.acc);
                }
                mapReferenceType = new Map<Id, Referenceability_Type__c>();
                
                for (String refId : refTypeMap.keySet()) {
                    
                    if (setRefTypesId.contains(refId)) {
                        mapReferenceType.put(refId, refTypeMap.get(refId));
                    }
                }
                
                if (insertRefReqAccounts.size() > 0) {
                    List<Reference_Request_Account__c> tempList = WithoutSharingHelperController.insertRRA(insertRefReqAccounts);
                    insertRefReqAccounts = new List<Reference_Request_Account__c>();
                    insertRefReqAccounts = WithoutSharingHelperController.getRRARecords(tempList);
                }
                // Insert Chatter, Email & task
                prepareChatterEmailTaskItem();
                isSubmitted = true;
                isDeadlineRefBlank = false;
            } catch (Exception e) {
                Database.rollback(sp);
                ApexPages.addMessages(e);
            }
        }
        return null;
    }
    
    /**
     * Method to Return to opportunity Page  & Ref Search Page
     */
    public Pagereference returnOpportunity() {
        PageReference ReturnPage;
        
        if (opportunityId != null && opportunityId.trim().length() > 0 && opportunityId != '') {
            ReturnPage = new PageReference('/' + OpportunityId);
        } else if (caseId != null && caseId.trim().length() != 0 && caseId != '') {
            ReturnPage = new PageReference('/' + caseId);
        // regarding ticket #809
        } else if (leadId != null && leadId.trim().length() != 0 && leadId != '') {
            ReturnPage = new PageReference('/' + leadId);
        } else {
            ReturnPage = new PageReference(Page.RfSearchPage.geturl());
        }
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    
    /**
     * Method to prepare Chatter , Email & task data
     */
    private void prepareChatterEmailTaskItem() {
        
        try {
            List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
            
            for (Reference_Request_Account__c rra : insertRefReqAccounts) {
                
                // changes for #603 - setting the recipient for chatter post, task and email
                //                      from RRA record rather than mapAccountOwnerId
                if (checkChatterSetting) {
                    // Prepare FeedItem List
                    // changes for #913
                    feedItemRRAMap.put(rra.Id, MailChatterController.preparePost(APPROVE_DECLINE_TITLE,
                                        rra.Reference_Owner__c,
                                        REFERENCE_REQUEST_MESSAGE
                                            + MailChatterController.prepareChatterEmailMessage(rra.Deadline__c,
                                                    mapAccount.get(rra.Account__c).Account__r.Name,
                                                    mapReferenceType.get(rra.Reference_Type_Needed__c).Name,
                                                    UtilityController.checkValueOfString(rra.Request_Notes__c)),
                                        LINK_URL + rra.Id));
                }
                
                if (checkEmailSetting) {
                    // Prepare Mail List
                    listmail.add(MailChatterController.prepareEmail(REFERENCE_REQUEST_SUBJECT,
                                    rra.Reference_Owner__c,
                                    REFERENCE_REQUEST_MESSAGE
                                        + MailChatterController.prepareChatterEmailMessage(rra.Deadline__c,
                                                    mapAccount.get(rra.Account__c).Account__r.Name,
                                                    mapReferenceType.get(rra.Reference_Type_Needed__c).Name,
                                                    UtilityController.checkValueOfString(rra.Request_Notes__c))
                                        + APPROVE_DECLINE_TITLE + ': ' + '<a href="'
                                        + LINK_URL + rra.Id + '">' + LINK_URL + rra.Id + '</a>',
                                    false));
                }
                // Prepare Task List
                listTask.add(MailChatterController.prepareTask(rra.Reference_Owner__c, rra.Account__c,
                                rra.Deadline__c, REFERENCE_REQUEST_TASK_SUBJECT,
                                REFERENCE_REQUEST_MESSAGE
                                    + MailChatterController.prepareChatterEmailMessage(rra.Deadline__c,
                                                mapAccount.get(rra.Account__c).Account__r.Name,
                                                mapReferenceType.get(rra.Reference_Type_Needed__c).Name,
                                                UtilityController.checkValueOfString(rra.Request_Notes__c))
                                    + APPROVE_DECLINE_TITLE + ': ' + LINK_URL + rra.Id,
                                ''));
            }
            
            // Insert list of postFeedItems
            //if (postFeedItems.size() > 0) {
                //postFeedItems = WithoutSharingHelperController.insertPostFeedItems(postFeedItems);
            //}
            // Insert list of feedItemRRAMap
            if (feedItemRRAMap.size() > 0) {
                // changes for #913
                feedItemRRAMap = WithoutSharingHelperController.insertPostFeedItemsMapBasic(feedItemRRAMap);
            }
            
            // Send List of emails
            if (listmail.size() > 0) {
                Messaging.sendEmail(listmail);
            }
            
            // Insert list of tasks
            if (listTask.size() > 0) {
                listTask = WithoutSharingHelperController.insertTask(listTask);
            }
            // Call Method update taskId in Reference_Request_Account__c Object
            updateRefReqAccountsTaskId();
            // call method to update RRA records with appropriate feeditem Ids
            updateRefReqAccountsFeedItemId();
        } catch (exception e) {
            Apexpages.addMessages(e);
        }
    }
    
    /**
     * Description: method to populate the chatter post id field on RRA record with the appropriate FeedItem Id
     * Created By: Rekha @7 July 2017 re #913
     */
    private void updateRefReqAccountsFeedItemId() {
        List<Reference_Request_Account__c> RRAsToUpdate = new List<Reference_Request_Account__c>();
        
        for (Reference_Request_Account__c rra : insertRefReqAccounts) {
            
            if (feedItemRRAMap.containsKey(rra.Id)) {
                
                if (rra.Related_Feed_Item_Ids__c == null || rra.Related_Feed_Item_Ids__c == '') {
                    rra.Related_Feed_Item_Ids__c = feedItemRRAMap.get(rra.Id).Id;
                } else {
                    rra.Related_Feed_Item_Ids__c += ',' + feedItemRRAMap.get(rra.Id).Id;
                }
            }
            RRAsToUpdate.add(rra);
        }
        
        // update updateRefReqAccounts;
        if (RRAsToUpdate != null && RRAsToUpdate.size() > 0) {
            RRAsToUpdate = WithoutSharingHelperController.updateRRA(RRAsToUpdate);
        }
    }
    
    /**
     * Method to insert taskId in Reference_Request_Account__c Object
     */
    private void updateRefReqAccountsTaskId() {
        
        for (Reference_Request_Account__c rra : WithoutSharingHelperController.getRRARecords(insertRefReqAccounts)) {
            
            for (Task lstTask : listTask) {
                
                if (rra.Account__c == lstTask.WhatId) {
                    rra.Task_ID__c = lstTask.Id;
                    updateRefReqAccounts.add(rra);
                }
            }
        }
        
        if (updateRefReqAccounts.size() > 0) {
            updateRefReqAccounts = WithoutSharingHelperController.updateRRA(updateRefReqAccounts);
        }
    }
    
    /**
     * Wrapper Class
     */
    public class ReferenceRequestAccountWrapper {
        public Reference_Basic_Information__c acc { get; set; }
        public Reference_Request_Account__c refRequestAccount { get; set; }
        public boolean isSelected { get; set; }
        
        public ReferenceRequestAccountWrapper(Reference_Basic_Information__c acc, Reference_Request_Account__c refRequestAccount) {
            this.isSelected = false;
            this.acc = acc;
            this.refRequestAccount = refRequestAccount;
        }
    }
    
    /**
     * Method to get Request Infomation
     */
    public Pagereference getRequestInfo() {
        
        for (ReferenceRequestAccountWrapper rraw : selectedAccounts) {
            
            if (rraw.acc.account__c == accountIdToRemoveFromList) {
                rraw.isSelected = true;
                dummyReq.Reference_Type_Needed__c = rraw.refRequestAccount.Reference_Type_Needed__c;
                
                if (rraw.refRequestAccount.Deadline__c != null) {
                    dummyReq.Deadline__c = rraw.refRequestAccount.Deadline__c;
                } else {
                    dummyReq.Deadline__c = calculateDate(system.today(), Integer.valueOf(UtilityController.getCustomSettings().Minimum_Deadline__c));
                }
                dummyReq.Request_Notes__c = rraw.refRequestAccount.Request_Notes__c;
            } else {
                rraw.isSelected = false;
            }
        }
        return null;
    }
    
    /**
     * Method to redirect SF1_RequestInfoBasic
     */
    public Pagereference redirectToInfo() {
        return Page.SF1_RequestInfoBasic;
    }
    
    /**
     * Method to redirect to SF1_ReferenceRequest
     */
    public Pagereference redirect() {
        return Page.SF1_ReferenceRequest;
    }
}