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
 * Page: RefRequestProject
 * Description : RefRequestProject class handle Reference Request operations
 * Modified by: Dixita @Aug 2018
 */
public with sharing class RefRequestProjectController extends RefEdgeEditionFeatures {
    /**
     * Properties
     */
    public Reference_Request__c refRequestObj { get; set; }    
    public Set<Id> refTypeIds { get; set; }    
    public List<String> fieldAPINames { get; set; }    
    public String rrAcc { get; set; }    
    public String Ureq { get; set; }
    public Boolean isUr { get; set; }
    public String urRefName { get; set; }
    public String arRefName { get; set; }
    public String refName { get; set; }
    public String reqId { get; set; }
    public Map<String, Id> unReqaddInfoMap { get; set; }
    public Map<String, Reference_Request_Account__c> rrAccountReq { get; set; }
    public Reference_Request_Additional_Info__c rrAddInfo { get; set; }
    public Boolean showInfo { get; set; }
    public Boolean showNoFieldMessage { get; set; }
    public SelectProjectUseAttribute refUseAttr { get; set; }
    public Map<String, Boolean> fieldRequiredMap { get; set; }
    public Boolean isMessageRender { get; set; }
    public List<ReferenceRequestWrapper> allAccountReq { get; set; }
    public Map<String, String> fieldAPILabelMap { get; set; }
    public Map<String, Boolean> fieldVisibleMap { get; set; }
    public Set<String> updatedReqIds { get; set; }
    public Boolean isSend { get; set; }   
    public List<Hit_List__c> hitListRecords { get; set; }
    public String updateReqId { get; set; }
    public String statusValue { get; set; }
    public String changeField { get; set; }
    public String hitRecordId { get; set; }
    public String hitRecordRequestId { get; set; }
    public Boolean hitRecordIsUR { get; set; }
    public Reference_Request_Account__c tempRRA { get; set; }
    public String OWNER_UPDATE_SUBJECT { get; set; }
    public String STATUS_UPDATE_SUBJECT { get; set; }
    public String PROCESS_UPDATE_SUBJECT { get; set; }
    public Boolean writetoNote { get; set; }
    public String NoteValue { get; set; }
    public String subjectValue { get; set; }
    public String errorAccountName { get; set; }
    public Boolean manage2PeerError { get; set; }
    public Boolean showConfirmationSaveMessage { get; set; }
    public Boolean showPeer2ManagedMessage { get; set; }
    public Boolean isDispositionSet { get; set; }
    public String dispositionStatus { get; set; }
    public String Subject { get; set; }
    public List<ContactWrapper> contacts { get; set; }
    public String accountId { get; set; }
    public String contactId { get; set; } 
    public String selectedaccountReq { get; set; }
    public Boolean isInlineEditingDisabled { get; set; }
    public Boolean isEdit { get; set; }
    public Reference_Basic_Information__c isAccountLevelLimit { get; set; }
    public Boolean isContactBlock { get; set; } 
    public List<Community_Invite_Contact__c> communityInviteContacts{ get; set; }
    public Map<String, Reference_Basic_Information__c> contactRBIMap { get; set; }
	public Map<String, Community_Invite__c> communityInviteMap { get; set; }
    public String communityIdtoDelete { get; set; }
    public String communityDetails { get; set; }
    public String communityDeadline { get; set; }
    public String referencePostedWith { get; set; }
    public String communitysubjectValue { get; set; }
    public String communitywithValue { get; set; }
    public String communitydeadlineValue { get; set; }
    public String communitydetailsValue { get; set; }
    public String communityReferencTypeName { get; set; }
    public String communityReferencTypeIcon { get; set; }
    public String communityReferencTypeImage { get; set; }
    public String communityReferencTypeId { get; set; }
    public Boolean isRequestAssociatedToCommunity { get; set; }
    public String activeTab { get; set; }
    public String communityHitListRecordId { get; set; }
    public Map<String, Boolean> showPostLink { get; set; }
    public String editThenSendEmailBody { get; set; }
    public String EditThenSend { get; set; }
    public Boolean isFromWorkspace { get; set; }
    public Integer matchedMembers { get; set; }
    public Boolean includeReferenceability { get; set; }
    private Boolean attributesToBePostedToCommunity { get; set; }
    public String currentPage { get; set; }
    public Boolean isProComm { get; set; }
    public String advRoutingGrpName { get; set; }
    public Boolean isInfluitiveEnabled { get;set; }
    public Custom_Settings__c cs { get; set; }
    public List<Label__c> filterList{ get; set; }
    public Decimal RULPeriodLengthContact {
        get {
            if (RULPeriodLengthContact == null) {
                RULPeriodLengthContact = cs.RUL_Period_Contact__c;
            }
            return RULPeriodLengthContact;
        }
        set;
    }
    public integer updateReqSetSize {
        get {
            return updatedReqIds.size();
        }
        set;
    } 
    /**
     * Vaiables and Constants
     */
    private static String SPECIFIED_REQUEST_MESSAGE = 'I would like to use an account as a reference for which you are the owner.  ';
    private static String APPROVE_DECLINE_LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContacts.getURL() + '?id=';
    private static String APPROVE_DECLINE_TITLE = 'Approve/Decline';
    private static String REFERENCE_REQUEST_TASK_SUBJECT = 'Reference Use Approval Request';
    private String addInfoQuery = '';
    private Set<Id> rrLabelIds = new Set<Id>();
    private Set<String> fieldNames = new Set<String>();
    private Set<String> labelAttribute = new Set<String>();
    private List<Reference_Request_Label_Attribute__c> newRefReqAttr;
    private List<Reference_Request_Label_Attribute__c> deleteRefReqAttr;
    private Map<String, List<Reference_Request_Label_Attribute__c>> rrLabelAttr;
    private List<Unspecified_Request__c> updateUnsp;
    private List<Reference_Request_Account__c> updateRefAcc;
    private Boolean checkPeer2PeerEmailSetting;
    private Boolean checkPeer2PeerChatterSetting;
    private Boolean checkManagedEmailSetting;
    private Boolean checkManagedChatterSetting; 
    private Set<String> fieldRTMDelete;
    private Map<String, Referenceability_Type__c> mapReferenceType;
    public Set<Id> refAttribIds = new Set<Id>();
   	private List<Referenceability_Type__c> listOfReferenceabilities;
   	private List<Task> listTask = new List<Task>();
    public Boolean isSLDS { get; set; }
    public Boolean isSLDSSet { get; set; }
    public Boolean writeDetailsBackToContact { get; set; }
    public Boolean isEditThenSend { get; set; }
    // added for REF-1542 - Gaurav Saini (1 Sep, 2018)
    public Boolean isRefTypeError { get; set; }
    //REF-1964
    public String isRefHubMatch { get; set; }
    public String selectedContactIds { get; set; }
    public List<Contact> listOfSelectedContacts { get; set; }
    public String contactIdToRemove { get; set; }
    public String participantLimit {get;set;}
    public List<Community_Invite_Contact__c> listOfCICForAdvocates {get;set;}
    public String inflDeadlineDate {get;set;}
    public List<SelectOption> referenceabilityTypes { get; set; }
    public Map<String, String> refTypeDeadlineMap { get; set; }
    private Map<Id, Referenceability_Type__c> refTypeMap;
    public Map<Id, String> referTypeNameId { get; set; }
    public String refTypeNeeded { get; set; }
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
    public String assignedContactId { get; set; }
    public String refDays { get; set; }
    public Boolean isChallengeError { get; set; }
    public String challengeError { get; set; }
    public String updatedChallengeStatus { get; set; }
    public Boolean hasChallengeId { get;set; }
    //REF-2132
    public Boolean attachSupportingDocuments { get;set; }
    //REF-2302
    public Boolean targetChallengeToAllAdvocates { get;set; }
    
    /**
     * Constructor
     */
    public RefRequestProjectController(ApexPages.StandardController stdController) { 
        NoteValue = '';
        isRefTypeError = false;
        subjectValue = '';
        writetoNote = false;
        Subject = '';
        accountId = '';
        isRequestAssociatedToCommunity = false;
        contactId = '';
        isEdit = false;
        hitRecordIsUR = false;
        isInlineEditingDisabled = false;
        selectedaccountReq = '';
        isDispositionSet = false;
        isChallengeCreated = false;
        isInfluitiveEnabled = false;
        isFromWorkspace = false;
        attributesToBePostedToCommunity = false;
        includeReferenceability = true;
        communityIdtoDelete = '';
        currentPage = 'RefRequestProject';
        isSLDS = false;
        isSLDSSet = false;
        writeDetailsBackToContact = false;
        isEditThenSend = false;
        List<EmailTemplate> templist = [SELECT Id, Subject, body, HTMLValue FROM EmailTemplate 
                                        WHERE DeveloperName = 'Community_Reference_Opportunity_Invitation'];
        
        if (templist.size() > 0) {
            editThenSendEmailBody = templist[0].body;
        }
        
        if (editThenSendEmailBody.contains('refedge__')) {
            editThenSendEmailBody = editThenSendEmailBody.replace('refedge__', '');
        }
        showPostLink = new Map<String, Boolean>();
        communitysubjectValue = 'New Reference Opportunity Available';
        OWNER_UPDATE_SUBJECT = ' is now managing your Request';
        STATUS_UPDATE_SUBJECT = 'Reference Request Update';
        PROCESS_UPDATE_SUBJECT = 'We received your reference request and found a matching account. A request has been sent to the owner for a response,' 
                                    + ' which will be sent to you directly.';
        fieldAPILabelMap = new Map<String, String>();
        newRefReqAttr = new List<Reference_Request_Label_Attribute__c>();
        rrAddInfo = new Reference_Request_Additional_Info__c();
        refTypeIds = new Set<Id>();
        showInfo = false;
        isSend = true;
        communityHitListRecordId = '';
        isContactBlock = false;
        contacts = new List<ContactWrapper>();
        hitListRecords = new List<Hit_List__c>();
        Set<String> communityContactId = new Set<String>();
        
        for (User u: [SELECT ProfileId, Name, Email, ContactId, AccountId FROM User WHERE Profile.UserLicense.Name = 'Customer Community'
                AND Profile.UserType = 'CspLitePortal' AND ContactId != null AND IsActive = true ORDER BY Name]) {
            communityContactId.add(u.ContactId);
        }
        showNoFieldMessage = false;
        updatedReqIds = new Set<String>();
        fieldAPINames = new List<String>();
        fieldRequiredMap = new Map<String, Boolean>();
        fieldVisibleMap = new Map<String, Boolean>();
        deleteRefReqAttr = new List<Reference_Request_Label_Attribute__c>();
        rrAccountReq = new Map<String, Reference_Request_Account__c>();
        refRequestObj = (Reference_Request__c)stdController.getRecord();
        tempRRA = new Reference_Request_Account__c();
        cs = UtilityController.getCustomSettings();
		
        //REF-2132
		attachSupportingDocuments = cs.Attach_Supporting_Documents_To_Requests__c;
        //REF-1964
        updatedChallengeStatus = '';
        isChallengeError = false;
        challengeError = '';
        assignedContactId = '';
        selectedContactIds = '';
        listOfSelectedContacts = new List<Contact>();
        isRefHubMatch = 'false';
        contactIdToRemove = '';
        participantLimit = '';
        hasChallengeId = false;
        
        inflDeadlineDate = '';
        refTypeNeeded = '';
        refDeadline = '';
        minimumDeadline = String.valueOf(cs.Minimum_Deadline__c);
        List<Referenceability_Type__c> listOfReferenceabilities = [SELECT Name, Id, Note__c, max_accounts_per_request_type__c,
                                                                   min_lead_time_per_request_type__c, Managed__c
                                                                   FROM Referenceability_Type__c
                                                                   WHERE Visible__c = true AND Request_type__c = true
                                                                   AND Sales_Reward__c = false
                                                                   ORDER BY Name LIMIT :limits.getLimitQueryRows()];
        refTypeDeadlineMap = new Map<String, String>();
        referTypeNameId = new Map<Id, String>();
        referenceabilityTypes = new List<SelectOption>();
        refTypeMap = new Map<Id, Referenceability_Type__c>();
        Decimal minDeadlineCS = UtilityController.getCustomSettings().Minimum_Deadline__c;
        refTypeDeadlineMap.put(null, String.valueOf(minDeadlineCS));
        
        for (Referenceability_Type__c ref : listOfReferenceabilities) {
            referenceabilityTypes.add(new SelectOption(ref.Id, ref.Name));
            referTypeNameId.put(ref.Id, ref.Name);
            refTypeMap.put(ref.Id, ref);
            refTypeDeadlineMap.put(ref.Id, string.valueOf((ref.min_lead_time_per_request_type__c != null ? ref.min_lead_time_per_request_type__c : minDeadlineCS)));
        }
        
        if (ApexPages.currentPage().getParameters().get('isRefHubMatch') != null &&
            ApexPages.currentPage().getParameters().get('isRefHubMatch') == 'true') {
                isRefHubMatch = 'true';
        }
        selectRefType = (ApexPages.currentPage().getParameters().get('selectedUR') == null ? '' : 
                          ApexPages.currentPage().getParameters().get('selectedUR'));

        
        isInfluitiveEnabled = (cs.Is_Influitive_Integration_Enabled__c != null && cs.Is_Influitive_Integration_Enabled__c) ? true : false;
        activeTab = '';
        
        if (ApexPages.currentPage().getParameters().get('activeTab') != null || ApexPages.currentPage().getParameters().get('activeTab') != '') {
            activeTab = ApexPages.currentPage().getParameters().get('activeTab');
            isFromWorkspace = true;
        }
        checkPeer2PeerEmailSetting = cs.Request_Peer2Peer_Email__c;
        checkPeer2PeerChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Peer2Peer_Chatter__c);
        checkManagedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Managed_Chatter__c);
        checkManagedEmailSetting = cs.Request_Managed_Email__c;
        
        for (Hit_List__c hl : WithoutSharingHelperController.getRequestHitListInRefProject(refRequestObj.Id)) {
            hitListRecords.add(hl);            
            
            showPostLink.put(hl.Id, (hl.Contact__c != null && communityContactId.contains(hl.Contact__c) && hl.Community_Invite__c == null) ? true : false );
            
            /*if (hl.Contact__c != null && communityContactId.contains(hl.Contact__c) && hl.Community_Invite__c == null) {
                showPostLink.put(hl.Id, true);
            } else {
                showPostLink.put(hl.Id, false);
            }*/
        }
        setAccountRequest();
        unReqaddInfoMap = new Map<String, Id>();
        rrLabelAttr = new Map<String, List<Reference_Request_Label_Attribute__c>>();
        
        for (Reference_Request_Account__c rraObj : refRequestObj.Reference_Request_Accounts__r) {
            refTypeIds.add(rraObj.Reference_Type_Needed__c);
            rrAccountReq.put(rraObj.Id, rraObj);
        }
        
        for (Unspecified_Request__c urObj : refRequestObj.Unspecified_Requests__r) {
            refTypeIds.add(urObj.Reference_Type_Needed__c);
            unReqaddInfoMap.put(urObj.Id, urObj.Reference_Request_Additional_Info__r.Id);
        }
        Set<Id> labelIds = new Set<Id>();
        
        for (Reference_Request_Label__c rrLabel : refRequestObj.Reference_Request_Labels__r) {
            rrLabelIds.add(rrLabel.Id);
            labelIds.add(rrLabel.Label__c);
        }
        
        for (Reference_Request_Label_Attribute__c tempObj : [SELECT Reference_Request_Label__c, Attribute__r.Name, Attribute__c, 
                                                    Reference_Request_Label__r.Label__r.Name, 
                                                    Reference_Request_Label__r.Label__c FROM Reference_Request_Label_Attribute__c 
                                                    WHERE Reference_Request_Label__c IN : rrLabelIds]) {
            refAttribIds.add(tempObj.Attribute__c);
            labelAttribute.add(tempObj.Reference_Request_Label__r.Label__c + ',' + tempObj.Attribute__c);
            
            if (!rrLabelAttr.containsKey(tempObj.Reference_Request_Label__r.Label__c)) {
                rrLabelAttr.put(tempObj.Reference_Request_Label__r.Label__c, new List<Reference_Request_Label_Attribute__c>());
            }
            rrLabelAttr.get(tempObj.Reference_Request_Label__r.Label__c).add(tempObj);
        }
        //re #439
        advRoutingGrpName = (cs.Adv_Routing_Group_Lbl__c == null || cs.Adv_Routing_Group_Lbl__c == '') 
                                ? System.Label.Advanced_Routing_Group : cs.Adv_Routing_Group_Lbl__c;
    
        List<String> listofGroups = new List<String>();   
        
        if (cs.Adv_Request_Routing__c && refRequestObj.Adv_Routing_Group__c != null) {  
            
            for (String key : refRequestObj.Adv_Routing_Group__c.split(',')) {
                listofGroups.add(key.trim());
            }  
        }  
        Boolean isP2PRequest = false;
        for (ReferenceRequestWrapper RRW : allAccountReq) {
            if (RRW.processStatus == ConstantsController.REP2REP) {
                isP2PRequest = true;
                break;
            } 
        }
        refUseAttr = new SelectProjectUseAttribute(refTypeIds, labelIds, refAttribIds, refRequestObj.Id, cs.Adv_Request_Routing__c, listofGroups, isP2PRequest);
        
        for (Reference_Type_Mapping__c tempObj : [SELECT Label__c, Visible__c, Required__c, Referenceability_Type__c, Referenceability_Type__r.Id, Name 
                        FROM Reference_Type_Mapping__c WHERE Referenceability_Type__c IN : refTypeIds AND (Visible__c = true OR Required__c = true)]) {
            
            if (tempObj.Label__c == null) {
            
                if (!fieldNames.contains(tempObj.Name)) {
                    fieldAPINames.add((tempObj.Name).tolowerCase());
                    fieldNames.add(tempObj.Name);
                }
            
                if (!fieldRequiredMap.containskey((tempObj.Name).tolowerCase() + tempObj.Referenceability_Type__r.Id)) {
                    fieldRequiredMap.put((tempObj.Name).tolowerCase() + tempObj.Referenceability_Type__r.Id, tempObj.Required__c);
                }
                
                if (!fieldVisibleMap.containsKey((tempObj.Name).tolowerCase() + tempObj.Referenceability_Type__r.Id)) {
                    fieldVisibleMap.put((tempObj.Name).tolowerCase() + tempObj.Referenceability_Type__r.Id, tempObj.Visible__c);
                }
            }
        }
        
        for (String fieldName : fieldAPINames) {
            
            for (String refId : refTypeIds) {
                
                if (!fieldRequiredMap.containskey(fieldName + refId)) {
                    fieldRequiredMap.put(fieldName + refId, false);
                }
                    
                if (!fieldVisibleMap.containsKey(fieldName + refId)) {
                    fieldVisibleMap.put(fieldName + refId, false);
                }
            }
        }
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Reference_Request_Additional_Info__c.fields.getMap();
        
        for (String fieldName : M.keySet()) {
            fieldAPILabelMap.put(fieldName, m.get(fieldName).getDescribe().getLabel());
        }
        listOfReferenceabilities = [SELECT Id, Name, Sales_Point__c, Note__c, max_accounts_per_request_type__c, min_lead_time_per_request_type__c 
                                    FROM Referenceability_Type__c WHERE Visible__c = true ORDER BY Name LIMIT : limits.getLimitQueryRows()];
        mapReferenceType = new Map<String, Referenceability_Type__c>();
        
        for (Referenceability_Type__c ref : listOfReferenceabilities) {
            mapReferenceType.put(ref.Id, ref);
        }
        isProComm = isProCom; 
        
        if (isProCom) {
            CRUDAndFLSCheckController.isDeletable(new List<String> {
                                                        UtilityController.appNamespace() + 'Community_Invite_Contact__c'});
        }
        CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Reference_Type_Mapping__c'});
        refresh();
    }

    public Pagereference reset() {
        return new PageReference(Page.RefRequestProjectSLDS.getURL() + '?id=' + refRequestObj.Id);
    }

    /**
     * Method to referesh query
     */
    public void refresh() {
        Set<String> contactIds = new Set<String>();
        contactRBIMap = new Map<String, Reference_Basic_Information__c>();
        communityInviteMap = new Map<String, Community_Invite__c>();
        
        for (Community_Invite__c commInvite : [SELECT Referenceability_Type__c, Reference_Request__c FROM Community_Invite__c 
                                                    WHERE Reference_Request__c = :refRequestObj.Id]) {
            communityInviteMap.put(commInvite.Referenceability_Type__c, commInvite);
        }
        //REF-1964
        communityInviteContacts = [SELECT Response__c, Referenceability_Type__c, Contact__c, Contact__r.AccountId, Contact__r.Phone,
                                   Contact__r.Email, Challenge_Id__c 
                                   FROM Community_Invite_Contact__c 
                                   WHERE Community_Invite__r.Reference_Request__c = :refRequestObj.Id
                                   AND Challenge_Id__c = null
                                   ORDER BY Response__c, Referenceability_Type__c, 
                                   Contact__r.Account.Name, Contact__r.LastName];
        
        for (Community_Invite_Contact__c CIC : communityInviteContacts) {
            contactIds.add(CIC.Contact__c);
            contactRBIMap.put(CIC.Contact__c, new Reference_Basic_Information__c());
        }
        
        for (Reference_Basic_Information__c rbi : [SELECT Contact__c, RUL_Last_Activity_Date__c FROM Reference_Basic_Information__c 
                                                    WHERE Contact__c IN : contactIds]) {
            contactRBIMap.put(rbi.Contact__c, rbi);
        }
    }
    /**
     * Method to referesh query
     */
    public void displayFieldInfo() {
        String addInfoId;
        showInfo = false;
        showNoFieldMessage = false;
        fieldRTMDelete = new Set<String>();
        
        if (CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Reference_Type_Mapping__c'})) {
        	
	        if (isUr) {
	            refName = urRefName;
	            
	            if (unReqaddInfoMap.get(Ureq) != null) {
	                addInfoId = unReqaddInfoMap.get(Ureq);
	                addInfoQuery = 'SELECT Id,';
	                Set<String> fieldNamesPresent = new Set<String>();
	                
	                for (String fieldName : fieldAPINames) {
	                    
	                    if (fieldAPILabelMap.containsKey(fieldName)) {
	                       
	                        if (fieldVisibleMap.containsKey(fieldName + refName) && fieldVisibleMap.get(fieldName + refName)) {
	                            showInfo = true;
	                        }
	                        addInfoQuery = addInfoQuery + fieldName + ',';
	                        fieldNamesPresent.add(fieldName);
	                    } else {
	                        fieldRTMDelete.add(fieldName);
	                    }
	                }
	                fieldAPINames = new List<String>();
	                fieldAPINames.addAll(fieldNamesPresent);
	                List<Reference_Type_Mapping__c> deleteRTM = new List<Reference_Type_Mapping__c>();
	                
	                for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name FROM Reference_Type_Mapping__c 
								WHERE Referenceability_Type__c IN : refTypeIds AND Name IN : fieldRTMDelete]) {
	                    deleteRTM.add(rtm);
	                }
	                
	                if (deleteRTM.size() > 0) {
	                    delete deleteRTM;
	                }
	                
	                if (showInfo == false) {
	                    showNoFieldMessage = true;
	                }
	                
	                addInfoQuery = addInfoQuery.substring(0, addInfoQuery.length() - 1);
	                addInfoQuery = addInfoQuery + ' FROM Reference_Request_Additional_Info__c WHERE Id = :addInfoId';
	                
	                if (Database.query(addInfoQuery).size() > 0) {
	                    rrAddInfo = Database.query(addInfoQuery);
	                }
	            }
	            
	            for (String fieldName : fieldAPINames) {
	                
	                if (fieldVisibleMap.containsKey(fieldName + refName) && fieldVisibleMap.get(fieldName + refName)) {
	                    showInfo = true;
	                }
	            }
	            
	            if (showInfo == false) {
	                showNoFieldMessage = true;
	            }
	        } else if (!isUr) {
	        	
	            if (rrAccountReq.get(rrAcc) != null && rrAccountReq.get(rrAcc).Managed_Request__c) {
	                refName = arRefName;
	               
	                if (rrAccountReq.get(rrAcc).Reference_Request_Additional_Info__r.Id != null) {
	                    addInfoId = rrAccountReq.get(rrAcc).Reference_Request_Additional_Info__r.Id;
	                    addInfoQuery = 'SELECT Id,';
	                    Set<String> fieldNamesPresent = new Set<String>();
	                    
	                    for (String fieldName : fieldAPINames) {
	                    	
	                        if (fieldAPILabelMap.containsKey(fieldName)) {
	                        	
	                            if (fieldVisibleMap.containsKey(fieldName + refName) && fieldVisibleMap.get(fieldName + refName)) {
	                                showInfo = true;
	                            }
	                            addInfoQuery = addInfoQuery + fieldName + ',';
	                            fieldNamesPresent.add(fieldName);
	                        } else {
	                            fieldRTMDelete.add(fieldName);
	                        }
	                    }
	                    fieldAPINames = new List<String>();
	                    fieldAPINames.addAll(fieldNamesPresent);
	                    List<Reference_Type_Mapping__c> deleteRTM = new List<Reference_Type_Mapping__c>();
	                    
	                    for (Reference_Type_Mapping__c rtm : [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name FROM Reference_Type_Mapping__c 
	                    										WHERE Referenceability_Type__c IN : refTypeIds AND Name IN : fieldRTMDelete]) {
	                        deleteRTM.add(rtm);
	                    }
	                    
	                    if (deleteRTM.size() > 0) {
	                        delete deleteRTM;
	                    }
	                        
	                    if (showInfo == false) {
	                        showNoFieldMessage = true;
	                    }
	                    addInfoQuery = addInfoQuery.substring(0, addInfoQuery.length() - 1);
	                    addInfoQuery = addInfoQuery + ' FROM Reference_Request_Additional_Info__c WHERE Id = : addInfoId';
	                    
	                    if (Database.query(addInfoQuery).size() > 0) {
	                        rrAddInfo = Database.query(addInfoQuery);
	                    }
	                }
	                
	                for (String fieldName : fieldAPINames) {
	                	
	                    if (fieldVisibleMap.containsKey(fieldName + refName) && fieldVisibleMap.get(fieldName + refName)) {
	                        showInfo = true;
	                    }
	                }
	                
	                if (showInfo == false) {
	                    showNoFieldMessage = true;
	                }
	            }
	        }
        }
    }

    /**
     * Method to reset the All Account Request of the Requested Reference Request from Database 
     * REF-1964 added challengeid and challenge staus in ur query
     */
    private void setAccountRequest() {
        selectedaccountReq = '';
        List<Reference_Request__c> temprefRequestObjList = [SELECT Id, Name, Requester__r.Email, Title__c, Requester__c, Reference_Request_Status__c, Case__c, 
                                                        Opportunity__r.Name,Opportunity__c,Opportunity__r.Account.Name, Project_Type__c, Adv_Routing_Group__c, 
                                                        (SELECT Id, Label__c FROM Reference_Request_Labels__r), Lead__c,
                                                        (SELECT Id, Deadline__c, Reference_Type_Needed__c, Managed_Request__c,Account_Request_Status__c, 
                                                        Reference_Request_Additional_Info__r.Id, Account__c, 
                                                        Reference_Type_Needed__r.Name, Account__r.Name, Name, Request_Notes__c, Approve_Deny_Notes__c, 
                                                        Project_Owner__c, Project_Owner__r.Name, Reference_Request__c,  
                                                        Process__c, Requester__c, Task_ID__c, Influitive_Challenge_Id__c, Influitive_Challenge_Status__c
                                                        FROM Reference_Request_Accounts__r), 
                                                        (SELECT Id, Deadline__c, Notes__c, Reference_Type_Needed__c, 
                                                        Unspecified_Request_Status__c, Reference_Request__c, Reference_Request_Additional_Info__r.Id, Request_Notes__c,
                                                        Project_Owner__c, Reference_Type_Needed__r.Name, Requester__c, Influitive_Challenge_Status__c, 
                                                        Influitive_Challenge_Id__c, Reference_Type_Needed__r.Referenceability_code__c
                                                        FROM Unspecified_Requests__r 
                                                        WHERE Specified_Account__c = null), (SELECT Id, Name, CreatedById, 
                                                        LastModifiedDate,LastModifiedById, Note__c FROM Reference_Notes__r) 
                                                        FROM Reference_Request__c WHERE id = : refRequestObj.Id LIMIT 1];
        
        if (temprefRequestObjList.size() > 0) {
            refRequestObj = temprefRequestObjList[0];
            referencePostedWith = refRequestObj.Opportunity__r.Account.Name;
            List<ReferenceRequestWrapper> tempActiveReq = new List<ReferenceRequestWrapper>();
            
            if (refRequestObj.Project_Type__c == null) {
                refRequestObj.Project_Type__c = 'Member';
            }
            ReferenceRequestWrapper temp;
            Map<String, Schema.SObjectField> fldObjMap = schema.SObjectType.Reference_Request_Account__c.fields.getMap();
            List<Schema.PicklistEntry> picklistEntries = fldObjMap.get('Account_Request_Status__c').getDescribe().getPicklistValues();
            //Getting unSpeficified request's state list
            Map<String, Schema.SObjectField> fldUnScecifiedObjMap = schema.SObjectType.Unspecified_Request__c.fields.getMap();
            List<Schema.PicklistEntry> picklistEntriesUnSceficied = fldUnScecifiedObjMap.get('Unspecified_Request_Status__c').getDescribe().getPicklistValues();
            
            for (Schema.PicklistEntry P : picklistEntriesUnSceficied) {
            	
                if (ConstantsController.NO_REFERENCE_MATCH == P.getLabel()) {
                	picklistEntries.add(p);
            	}
            }
            Set<String>rraIds = new Set<String>();
            Map<String, Reference_Request_Account_Contact__c> AccountContactRequestMap = new Map<String, Reference_Request_Account_Contact__c>();
            
            for (Reference_Request_Account__c rra : refRequestObj.Reference_Request_Accounts__r) {
                rraIds.add(rra.Id);
                AccountContactRequestMap.put(rra.Id, new Reference_Request_Account_Contact__c());
            }
            
            for (Reference_Request_Account_Contact__c rrac : WithoutSharingHelperController.getAccountContactRequests(rraIds)) {
                AccountContactRequestMap.put(rrac.Reference_Request_Account__c, rrac);
            }
            allAccountReq = new List<ReferenceRequestWrapper>();
            
            for (Reference_Request_Account__c rra : refRequestObj.Reference_Request_Accounts__r) {
                
                if (AccountContactRequestMap.get(rra.Id).Contact__c != null) {
                    
                    if (rra.Approve_Deny_Notes__c == null || rra.Approve_Deny_Notes__c == '' || (rra.Approve_Deny_Notes__c != null 
                    		&& !rra.Approve_Deny_Notes__c.contains('Contact:'))) {
                        rra.Approve_Deny_Notes__c = 'Contact: ' + AccountContactRequestMap.get(rra.Id).Contact__r.Name + 'Phone: ' 
							                        + (AccountContactRequestMap.get(rra.Id).Contact__r.Phone != null 
							                        	? AccountContactRequestMap.get(rra.Id).Contact__r.Phone : '') + 'Email: ' 
							                        + (AccountContactRequestMap.get(rra.Id).Contact__r.Email != null 
							                        	? AccountContactRequestMap.get(rra.Id).Contact__r.Email : '') + '\n' 
							                        + (rra.Approve_Deny_Notes__c != null ? rra.Approve_Deny_Notes__c : '');
                    }
                }
                
                if (rra.Managed_Request__c) {
                    allAccountReq.add(new ReferenceRequestWrapper(false, false, refRequestObj, rra, 
                    								AccountContactRequestMap.get(rra.Id), '', ConstantsController.MANAGED));
                } else {
                    allAccountReq.add(new ReferenceRequestWrapper(false, false, refRequestObj, rra, 
                    								AccountContactRequestMap.get(rra.Id), '', ConstantsController.REP2REP));
                }
            }
            
            for (Unspecified_Request__c unSpec : refRequestObj.Unspecified_Requests__r) {
                allAccountReq.add(new ReferenceRequestWrapper(false, false, refRequestObj, unSpec, '', ConstantsController.MANAGED));
            }
            
            //sort according to the Deadline
            if (allAccountReq.size() > 2) {
            	
                for (integer i = 0; i < allAccountReq.size() - 1; i++) {
                	
                    for (integer j = i + 1; j < allAccountReq.size(); j++) {
                    	
                        if (allAccountReq.get(i).deadline < allAccountReq.get(j).deadline) {
                            temp = allAccountReq.get(i);
                            allAccountReq.Set(i, allAccountReq.get(j));
                            allAccountReq.Set(j, temp);
                        }
                    }
                }
            }
            
            for (ReferenceRequestWrapper RRW : allAccountReq) {

                if (RRW.status == null || RRW.status == '') {
                    tempActiveReq.add(RRW);
                }
            }
            
            for (Schema.PicklistEntry P : picklistEntries) {
            	
                for (ReferenceRequestWrapper RRW : allAccountReq) {
                    
                    if (RRW.status == P.getLabel()) {
                        tempActiveReq.add(RRW);
                    }
                }
            }
            allAccountReq.clear();
            allAccountReq.addAll(tempActiveReq);
        }
    }
    /**
     * Method to redirect on UpdateRequestInformation
     */
    public PageReference EditInformation() {
    	checkPermissionsRequestFields();
        return Page.UpdateRequestInformation;
    }
	
    /**
     * Method to check Permissions for create community invite and invite attributes
     */
    private Boolean checkPermissionsRequestFields() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
    	Set<String> allFields = new Set<String>();
    	
    	for (String str : fieldAPINames) {
    		allFields.add(str);
    	}
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c', allFields);
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
    }    
    
    /**
     * Method to redirect on RfSearchPage
     */
    public PageReference goToRefMatch() {
        try {
            String parameters = '?RefRequestId=' + refRequestObj.Id + '&isRefMatch=true&activeTab=' 
            					+ activeTab + '&inlineeditingenable=' + isInlineEditingDisabled;
            PageReference ReturnPage = new PageReference(Page.RfSearchPage.geturl() + parameters);
            ReturnPage.setRedirect(true);
            return ReturnPage;
        } catch (System.Exception e) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, e.getMessage()));
            return null;
        }
    }
    /**
     * Method to redirect on addRequest
     */
    public pageReference addRequest() {
        PageReference ReturnPage = new PageReference(Page.addRequest.geturl() + '?id=' + refRequestObj.Id);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    /**
     * Method to redirect on SelectProjectUseAttribute
     */
    public pageReference selectProjUseAttr() {
    	checkPermissionsFilterAtt();
        PageReference ReturnPage = Page.SelectProjectUseAttribute;
        return ReturnPage;
    }
    
    /**
     * Method to save changes on requests
     */
    public PageReference saveChanges() {
        Savepoint sp = Database.setSavepoint();  
        try {
        	if (checkPermissionsRequestFields()) {
	            upsert rrAddInfo;
	            updateUnsp = new List<Unspecified_Request__c>();
	            updateRefAcc = new List<Reference_Request_Account__c>();
	            
	            for (Unspecified_Request__c unSpec : refRequestObj.Unspecified_Requests__r) {
	               
	                if (unSpec.Reference_Type_Needed__c == refName) {
	                    unSpec.Reference_Request_Additional_Info__c = rrAddInfo.Id;
	                    updateUnsp.add(unSpec);
	                }
	            }
	            
	            for (Reference_Request_Account__c accRequest : refRequestObj.Reference_Request_Accounts__r) {
	                
	                if (accRequest.Managed_Request__c && accRequest.Reference_Type_Needed__c == refName) {
	                    accRequest.Reference_Request_Additional_Info__c = rrAddInfo.Id;
	                    updateRefAcc.add(accRequest);
	                }
	            }
	
	            if (updateRefAcc.size() > 0) {
	                updateRefAcc = WithoutSharingHelperController.updateRRA(updateRefAcc);
	            }
	            
	            if (updateUnsp.size() > 0) {
	                WithoutSharingHelperController.updateUnspecified(updateUnsp);
	            }
	            
	            PageReference ReturnPage = new PageReference(Page.RefRequestProject.getUrl() + '?id=' + refRequestObj.Id);
        
                //REF-2304
                if (isRefHubMatch == 'true') {
                    ReturnPage.getParameters().put('isRefHubMatch', 'true');
                }
	            ReturnPage.setRedirect(true);
	            return ReturnPage;
        	}
        	return null;
        } catch (System.Exception e) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, e.getMessage()));
            Database.rollback(sp);
            return null;
        }
    }
    /**
     * Method to redirect on RefRequestProject
     */
    public PageReference backToSearch() {
        PageReference ReturnPage = new PageReference(Page.RefRequestProject.getUrl() + '?id=' + refRequestObj.Id);
        
        //REF-2304
        if (isRefHubMatch == 'true') {
            ReturnPage.getParameters().put('isRefHubMatch', 'true');
        }
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    /**
     * Method to redirect on ReferenceWorkSpace
     */
    public pageReference backToWorkspace() {
        String parameters = '?activeTab=' + activeTab;
        PageReference ReturnPage = new PageReference(Page.ReferenceWorkSpace.geturl() + parameters);
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
 
    public void dummyOnCompleteHandler() {
        system.debug('inside onComplete handler...');
    }
    
    /**
     * Method to cancel updates
     */
    public PageReference cancelUpdate() {
        updatedReqIds = new Set<String>();
        isEdit = false;
        PageReference ReturnPage = new PageReference(Page.RefRequestProject.geturl() + '?Id=' + refRequestObj.Id + '&activeTab=' + activeTab);
        
        //REF-2304
        if (isRefHubMatch == 'true') {
            ReturnPage.getParameters().put('isRefHubMatch', 'true');
        }
        ReturnPage.setRedirect(true);
        return ReturnPage;
    }
    /**
     * Method to edit each row 
     */
    public void editRow() {
        isEdit = true;
    }
    /**
     * Method to cancel request inline editing process 
     */
    public void cancelRequestEdit() {
        refRequestObj = [SELECT Id, Name, Title__c, Requester__c, Reference_Request_Status__c, Project_Type__c, Case__c, 
								        	Opportunity__c, Opportunity__r.Account.Name, Lead__c,
								        	(SELECT Id, Label__c FROM Reference_Request_Labels__r), 
								        	(SELECT Id, Deadline__c, Reference_Type_Needed__c, Managed_Request__c,
								            Account_Request_Status__c, Reference_Request_Additional_Info__r.Id, 
								            Account__c, Reference_Type_Needed__r.Name, Account__r.Name, Name,
								            Request_Notes__c, Project_Owner__c, Project_Owner__r.Name, Process__c, 
								            Approve_Deny_Notes__c FROM Reference_Request_Accounts__r), 
								            (SELECT Id, Deadline__c, Notes__c, Reference_Type_Needed__c, Unspecified_Request_Status__c, 
								            Reference_Request_Additional_Info__r.Id, Request_Notes__c,
								            Project_Owner__c FROM Unspecified_Requests__r WHERE Specified_Account__c = null), 
								            (SELECT Id, Name, CreatedById, LastModifiedDate,
								            LastModifiedById, Note__c FROM Reference_Notes__r) 
								            FROM Reference_Request__c WHERE id = : refRequestObj.Id LIMIT 1][0];
        isEdit = false;
    }
    
    /**
     * Method to save request inline editing process 
     */
    public void saveRequestEdit() {
        List<Reference_Request__c> reqList = new List<Reference_Request__c>();
        
        if (!isInlineEditingDisabled) {
            refRequestObj.Title__c = Subject;
        }       
        reqList.add(refRequestObj);
        update reqList;
        isEdit = false;
    }
    
    /**
     * Method to redirect back to Reference Use Request Page on done
     */
    public Pagereference backToRequest() {
        Savepoint sp = Database.setSavepoint();
        
        if (!attributesToBePostedToCommunity) {
            try {
            	
                if (currentPage == 'PostToCommunityPage') {
                    refUseAttr.tempList.clear();
                    
                    for (String key : refUseAttr.tempmapAttributesLabels.keySet()) {
                        refUseAttr.mapAttributesLabels.get(key).clear();
                        refUseAttr.mapAttributesLabels.get(key).addAll(refUseAttr.tempmapAttributesLabels.get(key));
                        
                        for (SelectProjectUseAttribute.AttributesLabelWrapper alw : refUseAttr.tempmapAttributesLabels.get(key)) {
                            refUseAttr.tempList.add(alw.attributeLabel.Attribute__c);
                        }
                    }
                    getMatchingCommunityContacts();
                    return Page.PostToCommunityPage;
                } else {
                	
                	if (checkPermissionsFilterAtt()) {
	                    Set<String> labelIds = new Set<String>();
	                    List<Reference_Request_Label__c> newRefLabels = new List<Reference_Request_Label__c>();
	                    Reference_Request_Label__c tempObj;
	                    
	                    for (String str : refUseAttr.mapRequiredLabel.keyset()) {
	                        
	                        if (refUseAttr.mapRequiredLabel.get(str) && refUseAttr.tempmapAttributesLabels.get(str).size() < 1) {
	                            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, ConstantsController.ERROR_SELECT_REQUIRED_VALUE));
	                            return null;
	                        }
	                    }
	                    refUseAttr.tempList.clear();
	                    
	                    for (String key : refUseAttr.tempmapAttributesLabels.keySet()) {
	                        refUseAttr.mapAttributesLabels.get(key).clear();
	                        refUseAttr.mapAttributesLabels.get(key).addAll(refUseAttr.tempmapAttributesLabels.get(key));
	                        
	                        for (SelectProjectUseAttribute.AttributesLabelWrapper alw : refUseAttr.tempmapAttributesLabels.get(key)) {
	                            refUseAttr.tempList.add(alw.attributeLabel.Attribute__c);
	                        }
	                    }
	                    Set<String> selectLabelAttr = new Set<String>();
	                    
	                    if (refRequestObj.Reference_Request_Labels__r.size() > 0) {
	                    	
	                        for (Reference_Request_Label__c refObj : refRequestObj.Reference_Request_Labels__r) {
	                            labelIds.add(refObj.Label__c);
	                            
	                            if (refUseAttr.mapAttributesLabels.get(refObj.Label__c) != null) {
	                                
	                                for (SelectProjectUseAttribute.AttributesLabelWrapper aw : refUseAttr.mapAttributesLabels.get(refObj.Label__c)) {
	                                    selectLabelAttr.add(refObj.Label__c + ',' + aw.attributeLabel.Attribute__c);
	                                    
	                                    if (!labelAttribute.contains(refObj.Label__c + ',' + aw.attributeLabel.Attribute__c)) {
	                                        newRefReqAttr.add(new Reference_Request_Label_Attribute__c(Attribute__c = aw.attributeLabel.Attribute__c, 
	                                        													Reference_Request_Label__c = refObj.Id));
	                                    }
	                                }
	                            }
	                        }
	                        
	                        for (String labelId : refUseAttr.mapAttributesLabels.keySet()) {
	                        	
	                            if (!labelIds.contains(labelId)) {
	                                tempObj = new Reference_Request_Label__c(Reference_Request__c = refRequestObj.Id, Label__c = labelId);
	                                newRefLabels.add(tempObj);
	                                labelIds.add(labelId);
	                            }
	                        }
	                        
	                        if (newRefLabels.size() > 0) {
	                            insert newRefLabels;
	                        }
	                            
	                        for (Reference_Request_Label__c refLabel : newRefLabels) {
	                        	
	                            if (refUseAttr.mapAttributesLabels.get(refLabel.Label__c) != null) {
	                            	
	                                for (SelectProjectUseAttribute.AttributesLabelWrapper aw : refUseAttr.mapAttributesLabels.get(refLabel.Label__c)) {
	                                    selectLabelAttr.add(refLabel.Label__c + ',' + aw.attributeLabel.Attribute__c);
	                                    
	                                    if (!labelAttribute.contains(refLabel.Label__c + ',' + aw.attributeLabel.Attribute__c)) {
	                                        newRefReqAttr.add(new Reference_Request_Label_Attribute__c(Attribute__c = aw.attributeLabel.Attribute__c, 
	                                        Reference_Request_Label__c = refLabel.Id));
	                                    }
	                                }
	                            }
	                        }
	                    } else {
	                       
	                        for (String labelId : refUseAttr.mapAttributesLabels.keySet()) {
	                            
	                            if (!labelIds.contains(labelId)) {
	                                tempObj = new Reference_Request_Label__c(Reference_Request__c = refRequestObj.Id, Label__c = labelId);
	                                newRefLabels.add(tempObj);
	                                labelIds.add(labelId);
	                            }
	                        }
	                       
	                        if (newRefLabels.size() > 0) {
	                            insert newRefLabels;
	                        }
	                        
	                        for (Reference_Request_Label__c refLabel : newRefLabels) {
	                            
	                            if (refUseAttr.mapAttributesLabels.get(refLabel.Label__c) != null) {
	                                
	                                for (SelectProjectUseAttribute.AttributesLabelWrapper aw : refUseAttr.mapAttributesLabels.get(refLabel.Label__c)) {
	                                    selectLabelAttr.add(refLabel.Label__c + ',' + aw.attributeLabel.Attribute__c);
	                                    
	                                    if (!labelAttribute.contains(refLabel.Label__c + ',' + aw.attributeLabel.Attribute__c)) {
	                                        newRefReqAttr.add(new Reference_Request_Label_Attribute__c(Attribute__c = aw.attributeLabel.Attribute__c, 
	                                        Reference_Request_Label__c = refLabel.Id));
	                                    }
	                                }
	                            }
	                        }
	                    }
	                    
	                    if (newRefReqAttr.size() > 0) {
	                        upsert newRefReqAttr;
	                    }
	                    
	                    for (String labelAtt : labelAttribute) {
	                        
	                        if (!selectLabelAttr.contains(labelAtt)) {
	                            
	                            if (rrLabelAttr.get(labelAtt.split(',')[0]) != null) {
	                               
	                                for (Reference_Request_Label_Attribute__c rraLabAtt : rrLabelAttr.get(labelAtt.split(',')[0])) {
	                                   
	                                    if (rraLabAtt.Attribute__c == labelAtt.split(',')[1]) {
	                                        deleteRefReqAttr.add(rraLabAtt);
	                                    }
	                                }
	                            }
	                        }
	                    }
	                    
	                    if (deleteRefReqAttr.size() > 0) {
	                        delete deleteRefReqAttr;
	                    }
	                    
	                    PageReference ReturnPage = new PageReference(Page.RefRequestProject.getUrl() + '?id=' + refRequestObj.Id + '&activeTab=' + activeTab);
                        
                        //REF-2304
                        if (isRefHubMatch == 'true') {
                            ReturnPage.getParameters().put('isRefHubMatch', 'true');
                        }
	                    ReturnPage.setRedirect(true);
	                    return ReturnPage;
	                }
                }
            } catch (Exception e) {
                Apexpages.addMessages(e);
                Database.rollback(sp);
            }
        } else {
            return Page.PostToCommunityPage;
        }
        return null;
    }
	/**
     * Method to check Permissions for filter attributes
     */
    private Boolean checkPermissionsFilterAtt() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label__c', new Set<String> {
        										UtilityController.appNamespace() + 'Reference_Request__c',
        										UtilityController.appNamespace() + 'Label__c'});
        fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label_Attribute__c', new Set<String> {
        										UtilityController.appNamespace() + 'Reference_Request_Label__c',
        										UtilityController.appNamespace() + 'Attribute__c'});
        Boolean isDeletePermission = 
        				CRUDAndFLSCheckController.isDeletable(new List<String> {UtilityController.appNamespace() + 'Reference_Request_Label_Attribute__c'});
        return (isDeletePermission && CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false));
    }    
    /**
     * BMethod to redirect back to Reference Use Request Page on cancel
     */
    public Pagereference backToRequestOnCancel() {
        
        for (String key : refUseAttr.mapAttributesLabels.keySet()) {
            refUseAttr.tempmapAttributesLabels.get(key).clear();
            refUseAttr.tempmapAttributesLabels.get(key).addAll(refUseAttr.mapAttributesLabels.get(key));
            
            for (SelectProjectUseAttribute.AttributesLabelWrapper alw : refUseAttr.tempmapAttributesLabels.get(key)) {
                refUseAttr.tempList.add(alw.attributeLabel.Attribute__c);
            }
        }
        
        for (String key : refUseAttr.mapAllAttributesLabel.keySet()) {
           
            for (SelectProjectUseAttribute.AttributesLabelWrapper alw : refUseAttr.mapAllAttributesLabel.get(key)) {
               
                if (refUseAttr.tempList.contains(alw.attributeLabel.Attribute__c)) {
                    alw.fontWeight = ConstantsController.BOLD;
                } else {
                    alw.fontWeight = ConstantsController.NORMAL;
                }
            }
        }
        
        if (currentPage == 'PostToCommunityPage') {
            return Page.PostToCommunityPage;
        } else {
            PageReference ReturnPage = new PageReference(Page.RefRequestProject.getUrl() + '?id=' + refRequestObj.Id + '&activeTab=' + activeTab);
            
            //REF-2304
            if (isRefHubMatch == 'true') {
                ReturnPage.getParameters().put('isRefHubMatch', 'true');
            }
            ReturnPage.setRedirect(true);
            return ReturnPage;
        }
    }
    /**
     * Method to set request Id 
     */
    public void setParam() {
        updatedReqIds.add(reqId);
        hasChallengeId = false;
        
        if (hitRecordRequestId != '') {
            
            if (!hitRecordIsUR) {
                //REF-1964
                List<Reference_Request_Account__c> listOfRRA = [SELECT Reference_Type_Needed_f__c, Reference_Type_Needed__r.Icon__c, Deadline__c,
                                                                Community_Invite__c, Reference_Type_Needed__c 
                                                                FROM Reference_Request_Account__c 
                                                                WHERE Id = : hitRecordRequestId];
                
                if (listOfRRA.size() > 0) {
                    communityReferencTypeName = listOfRRA[0].Reference_Type_Needed_f__c;
                    communityReferencTypeIcon = listOfRRA[0].Reference_Type_Needed__r.Icon__c;
                    communityReferencTypeId = listOfRRA[0].Reference_Type_Needed__c;
                    communityDeadline = listOfRRA[0].Deadline__c.format();
                    
                    if (communityInviteMap != null && communityInviteMap.containsKey(communityReferencTypeId)) {
                        isRequestAssociatedToCommunity = true;
                    } else {
                        isRequestAssociatedToCommunity = false;
                    } 
                }
                isUr = false;
            } else {
                
                //REF-1964
                List<Unspecified_Request__c> listOfUR = [SELECT Reference_Type_Needed_f__c, Reference_Type_Needed__r.Icon__c, Deadline__c,
                                                         Community_Invite__c, Reference_Type_Needed__c,Influitive_Challenge_Id__c, Unspecified_Request_Status__c 
                                                         FROM Unspecified_Request__c 
                                                         WHERE Id = : hitRecordRequestId];
                
                if (listOfUR.size() > 0) {
                    communityReferencTypeName = listOfUR[0].Reference_Type_Needed_f__c;
                    communityReferencTypeId = listOfUR[0].Reference_Type_Needed__c;
                    communityReferencTypeIcon = listOfUR[0].Reference_Type_Needed__r.Icon__c;
                    communityDeadline = listOfUR[0].Deadline__c.format();
                    
                    if (communityInviteMap != null && communityInviteMap.containsKey(communityReferencTypeId)) {
                        isRequestAssociatedToCommunity = true;
                    } else {
                        isRequestAssociatedToCommunity = false;
                    }
        			listOfCICForAdvocates = new List<Community_Invite_Contact__c>();
                    
                    if (listOfUR[0].Influitive_Challenge_Id__c != null && !String.isEmpty(listOfUR[0].Influitive_Challenge_Id__c)) {
                        hasChallengeId = true;
                        
                        if (listOfUR[0].Unspecified_Request_Status__c != 'Account Specified') {
                            getRelatedCICByChallengeId(listOfUR[0].Influitive_Challenge_Id__c);
                        }
                    }
                    isUr = true;
                }
            }
            
            if (communityReferencTypeId != null && communityReferencTypeId != '') {
                String fixedFileName = 'communityPic.jpg';
                List<attachment> currentPictures = [SELECT Id FROM Attachment WHERE parentId =: communityReferencTypeId AND name =: fixedFileName LIMIT 1];
                
                if (currentPictures.size() != 0) {
                    communityReferencTypeImage = currentPictures.get(0).Id;
                }
            }
           
            if (editThenSendEmailBody.contains('{!Community_Invite__c.Referenceability_Type_f__c}') && communityReferencTypeName != null) {
                editThenSendEmailBody.replace('{!Community_Invite__c.Referenceability_Type_f__c}', communityReferencTypeName);
            }
        }
        isContactBlock = false;
    }
    /**
     * Method to display contacts of any Account
     */
    public void displayContact() {
        isContactBlock = true;
        contacts.clear();
        isAccountLevelLimit = new Reference_Basic_Information__c();
        
        for (Reference_Basic_Information__c rbi : [SELECT Account_Level_RUL__c FROM Reference_Basic_Information__c 
        											WHERE Generic_Account__c = false AND Account__c =: accountId]) {
            isAccountLevelLimit = rbi;
        }
        List<Contact> contactList = new List<Contact>();
        
        if (refRequestObj.Project_Type__c == 'Candidate') {
            contactList = WithoutSharingHelperController.getContactsToDisplay(accountId, false, cs);
        } else {
            contactList = WithoutSharingHelperController.getContactsToDisplay(accountId, true, cs);
        }
        
        for (Contact con : contactList) {
            
            if (con.Reference_Basic_Informations__r.size() > 0) {
                contacts.add(new ContactWrapper(con.Reference_Basic_Informations__r[0], con.Reference_Request_Account_Contacts__r.size(), 0, false));
            }
        }
    }
    /**
     * Method to assign contact
     */
    public void assignContact() {
        Boolean continueEx = true;
        if (contactId != null) {
            Savepoint sp = Database.setSavepoint();
            try {            	
                Contact con = WithoutSharingHelperController.activateContactRecords(new Set<String> { contactId })[0];
                List<Account> accList = WithoutSharingHelperController.getAccountRecords(new Set<String> { accountId });
                
                if (refRequestObj.Project_Type__c == 'Candidate') {
                	
                    for (Account acc : accList) {
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                        		&& !acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT));
                            continueEx = false;
                        }
                    }
                } else {
                	
                    for (Account acc: accList) {
                    	
                        if ((acc.Reference_Basic_Informations__r.size() <= 0) || (acc.Reference_Basic_Informations__r.size() > 0 
                        		&& acc.Reference_Basic_Informations__r[0].Reference_Program_Candidate__c)) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT));
                            continueEx = false;
                        }
                    }
                }
                if (continueEx) {
                    Reference_Request_Account__c accReq;
                    
                    for (Reference_Request_Account__c rra: refRequestObj.Reference_Request_Accounts__r) {
                        
                        if (rra.Id == selectedaccountReq) {
                            
                            if (rra.Account__c == accountId) {
                                accReq = rra;
                            }
                        }
                    }
                    Reference_Request_Account_Contact__c refReqCon = new Reference_Request_Account_Contact__c(
                        Reference_Request_Account__c = accReq.Id, Contact__c = contactId, Contact_Request_Status__c = ConstantsController.IN_PROGRESS, 
                        Referenceability_Type__c = accReq.Reference_Type_Needed__c, Deadline__c = accReq.Deadline__c, 
                        Contact_Title__c = con.Title, Contact_Phone__c = con.Phone, Contact_Email__c = con.Email);
                        
                    refReqCon = WithoutSharingHelperController.upsertRRAC(refReqCon);
                    setAccountRequest();
                    isContactBlock = false;
                }
            } catch (Exception e) {
                ApexPages.addmessages(e);
                Database.rollback(sp);
            }
        }
    }
    /**
     * Method to get request details when click on Save button from reference request show detail in popup.
     */
    public void getSelectedAccReqDetails() {
        Savepoint sp = Database.setSavepoint();
        try {
            isRefTypeError = false;
            updateUnsp = new List<Unspecified_Request__c>();
            String recordStatus = '';
            showConfirmationSaveMessage = false;
            manage2PeerError = false;
            showPeer2ManagedMessage = false;
            Boolean isUnspecified = false;
            //Setting status, Getting notes.
            
            for (ReferenceRequestWrapper reqWrap: allAccountReq) {
               
                if (updateReqId != '' && reqWrap.Id == updateReqId) {
                   
                    if (reqWrap.isUr) {

                        if (reqWrap.unSpec.Reference_Type_Needed__c == null) {
                            isRefTypeError = true;
                            throw new CustomException(System.Label.No_Reference_Type_Specified);
                        }
                        //if request is unspecified
                        isUnspecified = true;
                       
                        if (changeField == 'status') {
                            reqWrap.unSpec.Unspecified_Request_Status__c = statusValue;
                        } else if (changeField == 'deadLine') {
                            reqWrap.unSpec.Deadline__c = date.parse(statusValue);
                        }
                        NoteValue = reqWrap.unSpec.Notes__c;
                    } else {

                        if (reqWrap.rra.Reference_Type_Needed__c == null) {
                            isRefTypeError = true;
                            throw new CustomException(System.Label.No_Reference_Type_Specified);
                        }

                        //if request is AccountRequest
                        if (changeField == 'status') {
                            reqWrap.rra.Account_Request_Status__c = statusValue;
                        } else if (changeField == 'deadLine') {
                            reqWrap.rra.Deadline__c = date.parse(statusValue);
                        } else if (changeField == 'process') {
                            reqWrap.rra.Process__c = statusValue;
                        }
                        //Setting status val process
                        statusValue = reqWrap.rra.Process__c;
                        
                        if (reqWrap.rra.Process__c == 'Managed') {
                            reqWrap.rra.Managed_Request__c = true;
                        } else {
                            reqWrap.rra.Managed_Request__c = false;
                        }
                        NoteValue = tempRRA.Approve_Deny_Notes__c;
                        
                      recordStatus = reqWrap.rra.Account_Request_Status__c;
                    }
                }
            }
            
            if (updateReqId != null && updateReqId != '') {
                updatedReqIds.add(updateReqId);
                String contactId = '';
                
                //Getting contactId for ARR 
                for (ReferenceRequestWrapper reqWrap: allAccountReq) {
                	
                    if (updateReqId != '' && reqWrap.Id == updateReqId && !reqWrap.isUr && reqWrap.rrac.Contact__c != null) {
                        contactId = reqWrap.rrac.Contact__c;
                    }
                }
                
                //Get ARR Based on id
                List<Reference_Request_Account__c> tempList = [SELECT Account__r.Name, Id, Deadline__c, Reference_Type_Needed__c, 
					                	Managed_Request__c, Account_Request_Status__c,
					                    Reference_Request_Additional_Info__r.Id, Account__c, Reference_Type_Needed__r.Name,
					                    Name, Request_Notes__c, Approve_Deny_Notes__c, Project_Owner__c, Project_Owner__r.Name, Process__c,Reference_Owner__c
					                    FROM Reference_Request_Account__c WHERE Id = : updateReqId];
                
                if (tempList.size() > 0) {
                    //tempRRA is current page instance Reference_Request_Account__c
                    tempRRA = tempList[0];                     
                    NoteValue = tempRRA.Approve_Deny_Notes__c;
                    
                    if (tempRRA.id == updateReqId && statusValue == ConstantsController.REP2REP && tempRRA.Process__c == ConstantsController.MANAGED) {
                        showConfirmationSaveMessage = true;
                        
                        if (cs.Managed_to_P2P_Min__c != null && tempRRA.Deadline__c.addDays(-integer.valueOf(cs.Managed_to_P2P_Min__c)) < date.today()) {
                            manage2PeerError = true;
                            errorAccountName = tempRRA.Account__r.Name;
                            
                            for (ReferenceRequestWrapper reqWrap: allAccountReq) {
                               
                                if (reqWrap.Id == tempRRA.Id) {
                                    reqWrap.rra.Process__c = ConstantsController.MANAGED;
                                    break;
                                }
                            }
                        }
                    } else if (tempRRA.id == updateReqId && statusValue == ConstantsController.MANAGED && tempRRA.Process__c == ConstantsController.REP2REP) {
                        showPeer2ManagedMessage = true;
                    }                    
                } else {
                    tempRRA = new Reference_Request_Account__c();
                }
            }
            
            if (isUnspecified) {
                List<Unspecified_Request__c> tempList = [SELECT Requester__c, Specified_Account__c, Unspecified_Request_Status__c,
										                    Request_Notes__c, Reference_Type_Needed__c, Deadline__c, Reference_Request__c,
										                    Reference_Request_Additional_Info__c, Project_Owner__c
										                    FROM Unspecified_Request__c WHERE Id = : updateReqId];
                
                if (tempList.size() > 0) {
                    tempRRA = new Reference_Request_Account__c(Account_Request_Status__c = tempList[0].Unspecified_Request_Status__c,
                        Project_Owner__c = tempList[0].Project_Owner__c);
                } else {
                    tempRRA = new Reference_Request_Account__c();
                }
            }
            
            if (updateUnsp.size() > 0) {
                WithoutSharingHelperController.updateUnspecified(updateUnsp);
                setAccountRequest();
            }
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
    }
    
    /**
     * Method to save all changes made to the specified request when click on done or send button from popup
     */
    public pageReference saveReqList() {
        Savepoint sp = Database.setSavepoint();
        try {
            updateUnsp = new List<Unspecified_Request__c>();
            updateRefAcc = new List<Reference_Request_Account__c>();
            Map<Id, Id> mapIds = new Map<Id, Id>(); 
            String userId;
            listTask = new List<Task>();
            
            List<Reference_Note__c> refNoteList = new List<Reference_Note__c>();
            Map<String, Reference_Basic_Information__c> accountRBImap = new Map<String, Reference_Basic_Information__c>();
            ConstantsController.UPDATED_SUBJECT_FOR_REF_REQUEST = subjectValue;
            
            Map<Id, Reference_Request_Account__c> existingRRAs = new Map<Id, Reference_Request_Account__c>(
			                	[SELECT Account__c, Account_Request_Status__c, Deadline__c, Process__c, Reference_Request_Additional_Info__c,
			                    Project_Owner__c, Approve_Deny_Notes__c, Reference_Request__c, Requester__c, Reference_Type_Needed__c
			                    FROM Reference_Request_Account__c WHERE Id IN :updatedReqIds
                                OR Reference_Request__c = :refRequestObj.Id]);
            
            Map<Id,Unspecified_Request__c> existingURs = new Map<Id, Unspecified_Request__c>(
						                	[SELECT Requester__c, Specified_Account__c, Unspecified_Request_Status__c, Notes__c,
						                    Request_Notes__c, Reference_Type_Needed__c, Deadline__c, Reference_Request__c,
						                    Reference_Request_Additional_Info__c, Project_Owner__c
						                    FROM Unspecified_Request__c WHERE Id IN :updatedReqIds
                                            OR Reference_Request__c = :refRequestObj.Id]);
            List<String> accountIdList = new List<String>();
            // added for REF-1542 - Gaurav Saini (1 Sep, 2018)
            Map<Id, Id> refTypeAddInfoMap = new Map<Id, Id>();

            for (Unspecified_Request__c ur : existingURs.values()) {

                if (!updatedReqIds.contains(ur.Id)) {
                    refTypeAddInfoMap.put(ur.Reference_Type_Needed__c, ur.Reference_Request_Additional_Info__c);
                }
            }

            for (Reference_Request_Account__c rra : existingRRAs.values()) {
                accountIdList.add(rra.Account__c);

                if (!updatedReqIds.contains(rra.Id)) {
                    refTypeAddInfoMap.put(rra.Reference_Type_Needed__c, rra.Reference_Request_Additional_Info__c);
                }
            }
            
            for (Reference_Basic_Information__c rbi: WithoutSharingHelperController.getAccountsRBI(accountIdList)) {
                accountRBImap.put(rbi.Account__r.Id, rbi);
            }

            for (ReferenceRequestWrapper reqWrap : allAccountReq) {

                if (updatedReqIds.contains(reqWrap.id)) {

                    if (reqWrap.isUR) {

						if (existingURs.containsKey(reqWrap.unSpec.Id) && existingURs.get(reqWrap.unSpec.Id).Reference_Type_Needed__c 
																			!= reqWrap.unSpec.Reference_Type_Needed__c) {

                    		if (communityInviteMap != null && communityInviteMap.containsKey(reqWrap.unSpec.Reference_Type_Needed__c)) {
                    			reqWrap.unSpec.Community_Participate__c = true;
                    			reqWrap.unSpec.Community_Invite__c = communityInviteMap.get(reqWrap.unSpec.Reference_Type_Needed__c).Id;
                    		}
                            reqWrap.unSpec.Reference_Request_Additional_Info__c = refTypeAddInfoMap.containsKey(reqWrap.rra.Reference_Type_Needed__c)
                                                                                    ? refTypeAddInfoMap.get(reqWrap.rra.Reference_Type_Needed__c) : null;
                    	}
                        updateUnsp.add(reqWrap.unSpec);
                    } else {

                        if (existingRRAs.containsKey(reqWrap.rra.Id)) {

                            if (reqWrap.rrac.Id != null && isEditThenSend) {
                                String contactPhone = reqWrap.rra.Approve_Deny_Notes__c.substringBetween('Phone:', '\n');
                                String contactEmail = reqWrap.rra.Approve_Deny_Notes__c.substringBetween('Email:', '\n');

                                if (contactPhone != null && contactPhone.trim() != '') {
                                    reqWrap.rrac.Contact_Phone__c = contactPhone.trim();
                                }

                                if (contactEmail != null && contactEmail.trim() != '') {
                                    reqWrap.rrac.Contact_Email__c = contactEmail.trim();
                                }
                                reqWrap.rrac = WithoutSharingHelperController.upsertRRAC(reqWrap.rrac);

                                if (writeDetailsBackToContact) {
                                    Contact requestedContact = new Contact(Id = reqWrap.rrac.Contact__c);

                                    if (contactEmail != null && contactEmail.trim() != '') {
                                        requestedContact.Email = contactEmail.trim();
                                    }

                                    if (contactPhone != null && contactPhone.trim() != '') {
                                        requestedContact.Phone = contactPhone.trim();
                                    }
                                    WithoutSharingHelperController.upsertContacts(new List<Contact> { requestedContact });
                                }
                            }
                            
                            if (existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c && reqWrap.rra.Process__c == ConstantsController.REP2REP) {
                                reqWrap.rra.Managed_Request__c = false;
                                
                                if (accountRBImap.containsKey(reqWrap.rra.Account__c)) {
                                    listTask.add(MailChatterController.prepareTask((accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c == null 
                                    					? accountRBImap.get(reqWrap.rra.Account__c).Account__r.OwnerId 
                                    					: accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c), 
                                    					reqWrap.rra.Account__c, reqWrap.rra.Deadline__c, REFERENCE_REQUEST_TASK_SUBJECT, 
                                    					SPECIFIED_REQUEST_MESSAGE + 
                                    					MailChatterController.prepareChatterEmailMessage(reqWrap.rra.Deadline__c, 
                                    					accountRBImap.get(reqWrap.rra.Account__c).Account__r.Name, 
                                    					mapReferenceType.get(reqWrap.rra.Reference_Type_Needed__c).Name, 
                                    					UtilityController.checkValueOfString(reqWrap.rra.Request_Notes__c)) + APPROVE_DECLINE_TITLE + ': ' 
                                    					+ (APPROVE_DECLINE_LINK_URL + reqWrap.rra.Id), ''));
                                }
                            } else if (existingRRAs.get(reqWrap.rra.Id).Account_Request_Status__c != reqWrap.rra.Account_Request_Status__c ||
		                                existingRRAs.get(reqWrap.rra.Id).Deadline__c != reqWrap.rra.Deadline__c ||
		                                existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c ||
		                                existingRRAs.get(reqWrap.rra.Id).Reference_Type_Needed__c != reqWrap.rra.Reference_Type_Needed__c ||
		                                existingRRAs.get(reqWrap.rra.Id).Project_Owner__c != reqWrap.rra.Project_Owner__c ||
		                                (existingRRAs.get(reqWrap.rra.Id).Approve_Deny_Notes__c != reqWrap.rra.Approve_Deny_Notes__c && 
		                                existingRRAs.get(reqWrap.rra.Id).Approve_Deny_Notes__c != null && (reqWrap.rra.Approve_Deny_Notes__c != null && 
		                                reqWrap.rra.Approve_Deny_Notes__c != ''))) {
                                reqWrap.rra.Process__c = ConstantsController.MANAGED;
                                reqWrap.rra.Managed_Request__c = true;
                            }
                            
                            //re #172
                            if (existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c && reqWrap.rra.Process__c == ConstantsController.MANAGED 
                            		&& existingRRAs.get(reqWrap.rra.Id).Project_Owner__c== reqWrap.rra.Project_Owner__c) {
                                reqWrap.rra.Project_Owner__c = userInfo.getUserId();
                            } else if (existingRRAs.get(reqWrap.rra.Id).Process__c != reqWrap.rra.Process__c 
                            						&& reqWrap.rra.Process__c == ConstantsController.REP2REP) {
                                reqWrap.rra.Project_Owner__c = (accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c == null 
                                						? accountRBImap.get(reqWrap.rra.Account__c).Account__r.OwnerId : 
                                						accountRBImap.get(reqWrap.rra.Account__c).Reference_Owner__c);
                            }
							
							if (existingRRAs.get(reqWrap.rra.Id).Reference_Type_Needed__c != reqWrap.rra.Reference_Type_Needed__c) {
								
	                    		if (communityInviteMap != null && communityInviteMap.containsKey(reqWrap.rra.Reference_Type_Needed__c)) {
	                    			reqWrap.rra.Community_Participate__c = true;
	                    			reqWrap.rra.Community_Invite__c = communityInviteMap.get(reqWrap.rra.Reference_Type_Needed__c).Id;
	                    		}
                                reqWrap.rra.Reference_Request_Additional_Info__c = refTypeAddInfoMap.containsKey(reqWrap.rra.Reference_Type_Needed__c)
                                                                                    ? refTypeAddInfoMap.get(reqWrap.rra.Reference_Type_Needed__c) : null;
	                    	}
	                    	
	                    	//re #674/#212- Assign user rewards if request status set to completed 
                    	 	//If Account has Project owner then reward assign to Project Owner,If not then Reference Owner 
                    	 	//      present then assign rewards to Refrence Owner,
                    		//If both not present then assign to Account owner.	                    		
	                    	if (reqWrap.rra.Account_Request_Status__c == ConstantsController.COMPLETED) {
	                    		mapIds.put(reqWrap.rra.Reference_Type_Needed__c, (reqWrap.rra.Project_Owner__c != null) ? reqWrap.rra.Project_Owner__c : 
												(reqWrap.rra.Reference_Owner__c != null) ? reqWrap.rra.Reference_Owner__c : 
												accountRBImap.get(reqWrap.rra.Account__c).Account__r.OwnerId);
	                    	}
                        }
                        updateRefAcc.add(reqWrap.rra);
                    }
                }
            }
            
            //REF-2652 limit notes to be created either for AR or UR depending on the current request, insert new notes
            for (ReferenceRequestWrapper reqWrap: allAccountReq) {
                
                if (reqWrap.rra != null && existingRRAs != null && existingRRAs.containsKey(reqWrap.rra.Id) && 
                    String.valueOf(reqWrap.rra.Id).substring(0,15) == String.valueOf(selectRefType).substring(0,15)) {
                    
                    if (writetoNote && reqWrap.rra.Approve_Deny_Notes__c != null && reqWrap.rra.Approve_Deny_Notes__c != '') {
                        refNoteList.add(new Reference_Note__c(Account_Request__c = reqWrap.rra.Id, Note_Date__c = system.today(), 
                        Note__c = reqWrap.rra.Approve_Deny_Notes__c, Reference_Request__c = reqWrap.rra.Reference_Request__c));
                    }
                } else if (reqWrap.unSpec != null && existingURs != null && existingURs.containsKey(reqWrap.unSpec.Id) && 
                           String.valueOf(reqWrap.unSpec.Id).substring(0,15) == String.valueOf(selectRefType).substring(0,15)) {
                    
                    if (writetoNote && reqWrap.unSpec.Notes__c != null && reqWrap.unSpec.Notes__c != '') {
                        refNoteList.add(new Reference_Note__c(Unspecified_Request__c = reqWrap.unSpec.Id, Note_Date__c = system.today(), 
                        Note__c = reqWrap.unSpec.Notes__c, Reference_Request__c = reqWrap.unSpec.Reference_Request__c));
                    }
                }
            }
            updatedReqIds = new Set<String>();
            ConstantsController.isNotificationSend = isSend;
            
            //Insert list of tasks
            if (listTask.size() > 0) {
                listTask = WithoutSharingHelperController.insertTask(listTask);
            }
            
            for (Reference_Request_Account__c rra: updateRefAcc) {
            	
                for (Task lstTask: listTask) {
                	
                    if (rra.Account__c == lstTask.WhatId) {
                        rra.Task_ID__c = lstTask.Id;
                    }
                }
            }
            
            if (updateUnsp.size() > 0) {
                WithoutSharingHelperController.updateUnspecified(updateUnsp);
            }
            
            if (updateRefAcc.size() > 0) {
                updateRefAcc = WithoutSharingHelperController.updateRRA(updateRefAcc);
            }
            
            if (refNoteList.size() > 0) {
                refNoteList = WithoutSharingHelperController.upsertNotes(refNoteList);
            }
            
            // Re #674-Assign User rewards   
            if (mapIds.size() > 0) { 
            	assignUserRewards(mapIds);
            }    
            
            setAccountRequest();
            isEdit = false;
            PageReference ReturnPage = new PageReference(Page.RefRequestProject.geturl() + '?Id=' + refRequestObj.Id + '&activeTab=' + activeTab);
            
            //REF-2304
            if (isRefHubMatch == 'true') {
                ReturnPage.getParameters().put('isRefHubMatch', 'true');
            }
            ReturnPage.setRedirect(true);
            return ReturnPage;
        } catch (Exception e) {
            ApexPages.Message msg = new ApexPages.Message(Apexpages.Severity.ERROR, e.getMessage() );
            ApexPages.addMessage(msg);
            Database.rollback(sp);
        }
        return null;
    }
     /**
     * Method to assign user rewards to designated User -re #674
     */
    private void assignUserRewards(Map<Id, Id> mapIds) {
    	
    	if (RefEdgeEditionFeatures.isBasic == false && cs.Auto_Assign_Sales_Rewards__c && cs.Enable_Sales_Rewards_Notification__c ==  true) {
    		Set<Id> kSetIds = mapIds.keySet(); 
    		List<Reward__c> rewardsToBeInsert = new List<Reward__c>();  
			Set<Id> ownerIds = new Set<Id>();  
			 
	        for (Id key: kSetIds) { 
	        		            		            	
				if (mapReferenceType != null && mapReferenceType.containsKey(key) && mapReferenceType.get(key).Sales_Point__c != null) {				           	 
				 	//Insert rewards records if Sale reward points not null 				 
				 	rewardsToBeInsert.add(new Reward__c(Amount__c = mapReferenceType.get(key).Sales_Point__c, 
				 							Referenceability_Type__c = mapReferenceType.get(key).Id, 
				 							Transaction__c = ConstantsController.ISSUE, RewardDate__c = Date.Today(), User__c = mapIds.get(key)));
				    ownerIds.add(mapIds.get(key));
		 		}
	        } 
	         
			if (rewardsToBeInsert.size() > 0) {
			 	UtilityController.isUserProfileExist(ownerIds); 
			 	WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
			}
    	}
    }
    /**
     * Method to update HitList Record
     */
    public void updateHitRecords() {    	
        Savepoint sp = Database.setSavepoint();
        try {
            List<Hit_List__c> updatedHitList = new List<Hit_List__c>();
            
            if (hitRecordId != null && hitRecordId != '') {
                List<Reference_Request_Account__c> accReqs = new List<Reference_Request_Account__c>();
                List<Reference_Request_Account_Contact__c> accConReqs = new List<Reference_Request_Account_Contact__c>();
                Map<Id, Unspecified_Request__c> updateUnspec = new Map <Id, Unspecified_Request__c>();
                Reference_Request_Account_Contact__c contactRequest;
                Reference_Request_Account__c accReq;
                
                for (Hit_List__c hitObject: hitListRecords) {
                    
                    if (hitObject.Id == hitRecordId) {
                        Reference_Basic_Information__c RBI = [SELECT Reference_Owner__c FROM Reference_Basic_Information__c WHERE Contact__c = null 
                        AND Account__c = : hitObject.Account__c LIMIT 1];
                        hitObject.Disposition__c = dispositionStatus;
                        
                        if (dispositionStatus == 'Released: Contact Declined') {
                            hitObject.Released__c = true;
                            Task taskObject = new Task();
                            taskObject.Subject = 'declined reference activity';
                            taskObject.WhatId = hitObject.Account__c;
                            taskObject.OwnerId = Userinfo.getUserId();
                            taskObject.Priority = ConstantsController.NORMAL;
                            taskObject.Status = ConstantsController.COMPLETED;
                            WithoutSharingHelperController.insertTask(new List<Task> { taskObject });
                        } else if (dispositionStatus == 'Released: Contact Unresponsive' || dispositionStatus == 'Released: No Longer Needed') {
                            hitObject.Released__c = true;
                        } else if (dispositionStatus == 'Agreed') {
                            hitObject.Released__c = true;
                            
                            if (hitRecordRequestId != null && hitRecordRequestId != '') {
                                
                                for (ReferenceRequestWrapper rraw: allAccountReq) {
                                   
                                    if (rraw.Id != null && rraw.Id == hitRecordRequestId) {
                                        
                                        if (hitRecordIsUR) {
                                            accReq = new Reference_Request_Account__c();
                                            accReq.Account__c = hitObject.Account__c;
                                            accReq.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                                            accReq.Deadline__c = rraw.unSpec.Deadline__c;
                                            accReq.Reference_Request__c = hitObject.Reference_Request__c;
                                            accReq.Request_Notes__c = rraw.unSpec.Request_Notes__c;
                                            accReq.Requester__c = rraw.unSpec.Requester__c;
                                            accReq.Reference_Type_Needed__c = rraw.unSpec.Reference_Type_Needed__c;
                                            accReq.Reference_Request_Additional_Info__c = rraw.unSpec.Reference_Request_Additional_Info__c;
                                            accReq.Managed_Request__c = true;
                                            accReq.Project_Owner__c = RBI.Reference_Owner__c;
                                            accReqs.add(accReq);
                                        } else {
                                            accReq = new Reference_Request_Account__c();
                                            accReq.Account__c = hitObject.Account__c;
                                            accReq.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                                            accReq.Deadline__c = rraw.rra.Deadline__c;
                                            accReq.Reference_Request__c = hitObject.Reference_Request__c;
                                            accReq.Request_Notes__c = rraw.rra.Request_Notes__c;
                                            accReq.Requester__c = rraw.rra.Requester__c;
                                            accReq.Reference_Type_Needed__c = rraw.rra.Reference_Type_Needed__c;
                                            accReq.Reference_Request_Additional_Info__c = rraw.rra.Reference_Request_Additional_Info__c;
                                            accReq.Managed_Request__c = true;
                                            accReq.Project_Owner__c = RBI.Reference_Owner__c;
                                            accReqs.add(accReq);
                                            rraw.rra.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                                            accReqs.add(rraw.rra);
                                        }
                                    }
                                }
                            }
                            if (accReqs.size() > 0) {
                                accReqs = WithoutSharingHelperController.upsertRRAList(accReqs);
                            }
                            
                            if (hitObject.Contact__c != null) {
                            	
                                for (Reference_Request_Account__c rra: accReqs) {
                                	
                                    if (rra.Account_Request_Status__c != ConstantsController.UNAVAILABLE) {
                                        contactRequest = new Reference_Request_Account_Contact__c();
                                        contactRequest.Contact__c = hitObject.Contact__c;
                                        contactRequest.Contact_Email__c = hitObject.Email__c;
                                        contactRequest.Contact_Phone__c = hitObject.Phone__c;
                                        contactRequest.Deadline__c = rra.Deadline__c;
                                        contactRequest.Project_Owner__c = rra.Project_Owner__c;
                                        contactRequest.Contact_Request_Status__c = rra.Account_Request_Status__c;
                                        contactRequest.Reference_Request_Account__c = rra.Id;
                                        contactRequest.Referenceability_Type__c = rra.Reference_Type_Needed__c;
                                        contactRequest.Request_notes__c = rra.Request_Notes__c;
                                        accConReqs.add(contactRequest);
                                    }
                                }
                            }
                            
                            for (Reference_Request_Account__c rra: accReqs) {
                                
                                for (ReferenceRequestWrapper rraw: allAccountReq) {
                                   
                                    if (rraw.isUR && rraw.Id == hitRecordRequestId && hitRecordIsUR) {
                                        
                                        if (rraw.unSpec.Deadline__c == rra.Deadline__c && rraw.unSpec.Reference_Type_Needed__c == rra.Reference_Type_Needed__c 
                                        			&& rraw.unSpec.Request_Notes__c == rra.Request_Notes__c) {
                                            rraw.unSpec.Specified_Account__c = rra.Id;
                                            rraw.unSpec.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                                            updateUnspec.put(rraw.unSpec.Id, rraw.unSpec);
                                        }
                                    }
                                }
                            }
                            
                            if (updateUnspec.size() > 0) {
                                ConstantsController.shouldUnspecifiedStatusChange = true;
                                WithoutSharingHelperController.updateUnspecified(updateUnspec.values());
                            }
                            
                            if (accConReqs.size() > 0) {
                                accConReqs = WithoutSharingHelperController.upsertRRACList(accConReqs);
                            }
                        }
                        updatedHitList.add(hitObject);
                    }
                }
            }
            
            for (Hit_List__c hit: [SELECT Id, Note__c FROM Hit_List__c WHERE Id IN : hitListRecords]) {
                for (Hit_List__c hit1: hitListRecords) {
                	if (hitRecordId != null && hitRecordId != '') {
                		 if (hit1.Id != hitRecordId && hit1.Note__c != hit.Note__c && hit.Id == hit1.Id) {
	                        updatedHitList.add(hit1);
	                    }
                	} else {                		
	                    if (hit1.Note__c != hit.Note__c && hit.Id == hit1.Id) {
	                        updatedHitList.add(hit1);
	                    }
                	}                   
                }
            }
            
            if (updatedHitList.size() > 0) {
                WithoutSharingHelperController.updateHitList(updatedHitList);
                hitListRecords = new List<Hit_List__c>();
                hitListRecords = [SELECT Referenceability_Type__c, Reference_Request__c, Opportunity__c, Note__c, 
			                					LastActivityDate, LastModifiedDate, Field1__c, 
			            						Email__c, Disposition__c, Deadline__c, Contact__c, Account__c, Phone__c, Released__c FROM Hit_List__c 
			            						WHERE Reference_Request__c = : refRequestObj.Id];
            }
            setAccountRequest();
            isEdit = false;
            hitRecordId = '';
        } catch (Exception e) {
        	Apexpages.addMessages(e);
            Database.rollback(sp);
        }
    }
    /**
     * Method to assign Hit Record to request
     */
    public void assignHitRecord() {
        Savepoint sp = Database.setSavepoint();
        try {
            
            if (hitRecordId != '' && hitRecordId != null) {
                Reference_Request_Account__c accReq;
                List<Hit_List__c> hitObjectList = [SELECT id, deadline__c, Email__c, Phone__c, disposition__c, released__c, Contact__c, referenceability_type__c, 
                	Unspecified_Request__c, Account__c, Account_Request__c, note__c, Reference_Request__c FROM Hit_List__c WHERE Id = : hitRecordId LIMIT 1];
                
                if (hitObjectList.size() > 0) {
                	Hit_List__c hitObject = hitObjectList[0];
					List<Reference_Basic_Information__c> rbiAccList = [SELECT Reference_Owner__c FROM Reference_Basic_Information__c WHERE Account__c != null 
	            														AND Account__c = : hitObject.Account__c AND contact__c = null LIMIT 1];
	                Reference_Basic_Information__c rbiAcc = rbiAccList[0];
	                
	                if (hitRecordIsUR) {
	                    Unspecified_Request__c unspecifiedRequest = [SELECT Requester__c, Specified_Account__c, Unspecified_Request_Status__c, Request_Notes__c, 
	                    											Reference_Type_Needed__c, Deadline__c, Reference_Request__c, 
	                    											Reference_Request_Additional_Info__c, 
	                    											Project_Owner__c FROM Unspecified_Request__c WHERE Id = : hitRecordRequestId LIMIT 1 ][0];
	                    accReq = new Reference_Request_Account__c();
	                    accReq.Account__c = hitObject.Account__c;
	                    accReq.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
	                    accReq.Deadline__c = unspecifiedRequest.Deadline__c;
	                    accReq.Reference_Request__c = unspecifiedRequest.Reference_Request__c;
	                    accReq.Request_Notes__c = unspecifiedRequest.Request_Notes__c;
	                    accReq.Requester__c = unspecifiedRequest.Requester__c;
	                    accReq.Reference_Type_Needed__c = unspecifiedRequest.Reference_Type_Needed__c;
	                    accReq.Reference_Request_Additional_Info__c = unspecifiedRequest.Reference_Request_Additional_Info__c;
	                    accReq.Managed_Request__c = true;
	                    accReq.Process__c = ConstantsController.MANAGED;
	                    accReq.Project_Owner__c = rbiAcc.Reference_Owner__c;
	                    WithoutSharingHelperController.upsertRRA(accReq);
	                    unspecifiedRequest.Specified_Account__c = accReq.Id;
	                    unspecifiedRequest.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
	                    ConstantsController.shouldUnspecifiedStatusChange = true;
	                    WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> {unspecifiedRequest});
	                } else {
	                    Reference_Request_Account__c accRefReq = [SELECT Request_Notes__c, Requester__c, Account_Request_Status__c, Reference_Type_Needed__c, 
	                    										Deadline__c, Reference_Request__c, Reference_Request_Additional_Info__c, 
	                    										Project_Owner__c FROM Reference_Request_Account__c 
	                											WHERE Id = : hitRecordRequestId LIMIT 1][0];
	                    accReq = new Reference_Request_Account__c();
	                    accReq.Account__c = hitObject.Account__c;
	                    accReq.Account_Request_Status__c = accRefReq.Account_Request_Status__c;
	                    accReq.Deadline__c = accRefReq.Deadline__c;
	                    accReq.Process__c = ConstantsController.MANAGED;
	                    accReq.Reference_Request__c = accRefReq.Reference_Request__c;
	                    accReq.Request_Notes__c = accRefReq.Request_Notes__c;
	                    accReq.Requester__c = accRefReq.Requester__c;
	                    accReq.Reference_Type_Needed__c = accRefReq.Reference_Type_Needed__c;
	                    accReq.Reference_Request_Additional_Info__c = accRefReq.Reference_Request_Additional_Info__c;
	                    accReq.Managed_Request__c = true;
	                    accReq.Project_Owner__c = rbiAcc.Reference_Owner__c;
	                    WithoutSharingHelperController.upsertRRA(accReq);
	                    accRefReq.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
	                    WithoutSharingHelperController.upsertRRA(accRefReq);
	                }
	                
	                if (hitObject.contact__c != null) {
	                    Reference_Request_Account_Contact__c contactRequest = new Reference_Request_Account_Contact__c();
	                    contactRequest.Contact__c = hitObject.Contact__c;
	                    contactRequest.Contact_Email__c = hitObject.Email__c;
	                    contactRequest.Contact_Phone__c = hitObject.Phone__c;
	                    contactRequest.Deadline__c = accReq.Deadline__c;
	                    contactRequest.Project_Owner__c = accReq.Project_Owner__c;
	                    contactRequest.Contact_Request_Status__c = accReq.Account_Request_Status__c;
	                    contactRequest.Reference_Request_Account__c = accReq.Id;
	                    contactRequest.Referenceability_Type__c = accReq.Reference_Type_Needed__c;
	                    contactRequest.Request_notes__c = accReq.Request_Notes__c;
	                    WithoutSharingHelperController.upsertRRAC(contactRequest);
	                }
	                setAccountRequest();
	                
	                if (isDispositionSet) {
	                    hitObject.Disposition__c = 'Agreed';
	                    hitObject.Released__c = true;
	                    update hitObject;
	                    WithoutSharingHelperController.updateHitList(new List<Hit_List__c> {hitObject});
	                }
	                hitListRecords = new List<Hit_List__c>();
	                hitListRecords = [SELECT Referenceability_Type__c, Reference_Request__c, Opportunity__c, Note__c, LastActivityDate, 
                					LastModifiedDate, Field1__c, Email__c, Disposition__c, Deadline__c, Contact__c, Account__c, Phone__c, 
                					Released__c FROM Hit_List__c WHERE Reference_Request__c = : refRequestObj.Id];
	            }
            }
            hitRecordId = '';
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
    }
    /**
     * Method to release HitList Records
     */
    public void releaseHitRecords() {
        Savepoint sp = Database.setSavepoint();
        try {
            List<Hit_List__c> updateHitList = new List<Hit_List__c>();
            
            for (hit_list__c hitRecord: hitListRecords) {
            	
                if (hitRecord.Disposition__c == null || hitRecord.Disposition__c == '') {
                    hitRecord.Disposition__c = 'Released: No Longer Needed';
                    hitRecord.Released__c = true;
                    updateHitList.add(hitRecord);
                }
            }
            
            if (updateHitList.size() > 0) {
                WithoutSharingHelperController.updateHitList(updateHitList);
                hitListRecords = new List<Hit_List__c>();
                hitListRecords = [SELECT Referenceability_Type__c, Reference_Request__c, Opportunity__c, Note__c, LastActivityDate, 
                				LastModifiedDate, Field1__c, Email__c, Disposition__c, Deadline__c, Contact__c, Account__c, Phone__c, 
                				Released__c FROM Hit_List__c WHERE Reference_Request__c = : refRequestObj.Id];
            }
            hitRecordId = '';
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
    }
    
    /**
     * Method to cancel hitlist
     */
    public void cancelHitList() {
        hitListRecords = [SELECT Referenceability_Type__c, Reference_Request__c, Opportunity__c, Note__c, LastActivityDate, LastModifiedDate, Field1__c, Email__c, 
        				Disposition__c, Deadline__c, Contact__c, Account__c, Phone__c, Released__c FROM Hit_List__c WHERE Reference_Request__c = : refRequestObj.Id];
        isEdit = false;
    }
    /**
     * Method to redirect on PostToCommunityPage
     */
    public PageReference redirectPostCommunity() {
    	checkPermissionsCommunity();
        getMatchingCommunityContacts();
        currentPage = 'PostToCommunityPage';
        return Page.PostToCommunityPage;
    }
    Map<String,User> contactEmailMap  = new Map<String,User>();
    /**
     * Method to get Number of Community Members Matching the Criteria
     */
    public void getMatchingCommunityContacts() {
        Set<String> setContactIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        contactEmailMap = new Map<String,User>();
        
        for (User u: [SELECT Name, Email, Id, AccountId, ContactId, Contact.firstName, Contact.Name, Contact.Email FROM User 
        				WHERE Profile.UserLicense.Name = 'Customer Community' AND IsActive = true]) {
            contactIds.add(u.ContactId);
            contactEmailMap.put(u.ContactId, u);
        }
        String refTypesClause = '';
        
        if (includeReferenceability && communityReferencTypeId != null && communityReferencTypeId != '') {
            List<Referenceability_Type__c> refTypeOfCommunityList = [SELECT Id,Referenceability_no__c 
            									FROM Referenceability_Type__c WHERE Visible__c = true AND Id = : communityReferencTypeId];
            
            if (refTypeOfCommunityList.size() > 0) {
            	Referenceability_Type__c refTypeOfCommunity = refTypeOfCommunityList[0];
	            String refnumber = String.escapeSingleQuotes(refTypeOfCommunity.Referenceability_no__c != null ? 'R' 
	            					+ String.valueOf(refTypeOfCommunity.Referenceability_no__c) + 'R' : '');
	            refTypesClause = 'AND ReferenceabilityType_Ids1__c LIKE \'%' + refnumber+ '%\'';
            }
        }
        String labelClause = '';
        Set<String> setLabelIds = new Set<String>();
        
        for (String labelId: refUseAttr.mapAttributesLabels.keySet()) {
        	
            if (refUseAttr.mapAttributesLabels.get(labelId).size() > 0) {
                String labelNo = String.escapeSingleQuotes(refUseAttr.mapAttributesLabels.get(labelId)[0].attributeLabel.Label__r.Filter_no__c != null 
                					? 'F' + String.valueOf(refUseAttr.mapAttributesLabels.get(labelId)[0].attributeLabel.Label__r.Filter_no__c) + 'F' : '');
                
                if (labelClause == '') {
                    labelClause = ' Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\'';
                } else {
                    labelClause += ' OR Label_Ids1__c LIKE \'%' + labelNo + '%\' OR Label_Ids2__c LIKE \'%' + labelNo + '%\'';
                }
                setLabelIds.add(labelId);
            }
        }
        
        if (labelClause != '') {
            labelClause = 'AND ( '+labelClause+' )';
        }
        String dynamicSOQL = 'SELECT Contact__c, Attribute_Ids__c FROM Reference_Basic_Information__c WHERE Contact__c != null AND Account__c != null ' 
        						+ labelClause +' '+refTypesClause+' AND  Referenceability_Status__c != \'' + ConstantsController.INACTIVE 
        						+ '\' AND Referenceability_Status__c != null AND Contact__c IN :contactIds ORDER BY contact__r.Name';

        Map<String, Boolean> labelLogicMap = new Map<String, Boolean>();
        
        for (Reference_Basic_Information__c rbi: Database.query(dynamicSOQL)) {
            
            if (setLabelIds.size() > 0) {
               
                if (rbi.Attribute_Ids__c != null && rbi.Attribute_Ids__c != '') {
                    Set<String> setAttribute = new Set<String>();
                    setAttribute.addAll(rbi.Attribute_Ids__c.split(','));
                    Integer selectedlabelCount = 0;
                    Integer recordMatchCount = 0;
                    
                    for (String labelId: setLabelIds) {
                        labelLogicMap.put(labelId, false);
                        selectedlabelCount++;
                        
                        for (SelectProjectUseAttribute.AttributesLabelWrapper atw: refUseAttr.mapAttributesLabels.get(labelId)) {
                            
                            if (setAttribute.contains(atw.attributeLabel.Attribute__c)) {
                                recordMatchCount++;
                                labelLogicMap.put(labelId, true);
                                break;
                            }
                        }
                    }
                    
                    if (selectedlabelCount != 0) {
                        Boolean checkResult = true;
                        
                        for (Boolean flag: labelLogicMap.values()) {
                            checkResult = (checkResult && flag);
                        }
                        
                        if (checkResult) {
                            setContactIds.add(rbi.Contact__c);
                        }
                    }
                }
            } else {
                setContactIds.add(rbi.Contact__c);
            }
        }
        matchedMembers = setContactIds.size();
        
        for (String con : contactEmailMap.keySet()) {
        	
            if (!setContactIds.contains(con)) {
                contactEmailMap.remove(con);
            }
        }
    }
    /**
     * Method to assign Hit Record to request
     */
    public void assignCommunityContactRecord() {
        Boolean continueEx = true;
        Savepoint sp = Database.setSavepoint();
        try {
            
            if (communityIdtoDelete != '' && communityIdtoDelete != null) {
                Reference_Request_Account__c accReq;
                List<Community_Invite_Contact__c> communityContacts = [SELECT Contact__c, Contact__r.Phone, Contact__r.Email, Contact__r.AccountId 
                														FROM Community_Invite_Contact__c WHERE Id = : communityIdtoDelete];
                if (communityContacts.size() > 0) {
                    Community_Invite_Contact__c communityObject = communityContacts[0];
                    List<Reference_Basic_Information__c> rbiAccList = [SELECT account__c, Contact__c, Reference_Owner__c, Is_Referenceable__c, 
                    										Reference_Program_Candidate__c,  Referenceability_Status__c FROM Reference_Basic_Information__c 
                    										WHERE ((Contact__c = null AND Account__c != null AND 
                    										Account__c = : communityObject.Contact__r.AccountId) 
                    										Or (Contact__c = :communityObject.Contact__c))];
                    Reference_Basic_Information__c con;
                    Reference_Basic_Information__c acc;
                    
                    for (Reference_Basic_Information__c rbi : rbiAccList) {
                        
                        if (rbi.Contact__c == null) {
                            acc = rbi;
                        }
                        
                        if (rbi.Contact__c != null && rbi.Contact__c == communityObject.Contact__c) {
                            con = rbi;
                        }
                    }
                    
                    if (refRequestObj.Project_Type__c == 'Candidate') {
                        
                        if (!con.Reference_Program_Candidate__c) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT));
                            continueEx = false;
                        } else if (!acc.Reference_Program_Candidate__c) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT));
                            continueEx = false;
                        }
                    } else {
                       
                        if (con.Reference_Program_Candidate__c) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.CANDIDATE_NOT_CHECKED_CONTACT_ACCOUNT));
                            continueEx = false;
                        } else if (acc.Reference_Program_Candidate__c) {
                            Apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, system.Label.MEMBER_NOT_CHECKED_CONTACT_ACCOUNT));
                            continueEx = false;
                        }
                    }
                    if (continueEx) {
                        if (hitRecordIsUR) {
                            Unspecified_Request__c unspecifiedRequest = [SELECT Requester__c, Specified_Account__c, Unspecified_Request_Status__c, Request_Notes__c, 
                                                                        Reference_Type_Needed__c, Deadline__c, Reference_Request__c, 
                                                                        Reference_Request_Additional_Info__c, 
                                                                        Project_Owner__c FROM Unspecified_Request__c WHERE Id = : hitRecordRequestId LIMIT 1][0];
                            accReq = new Reference_Request_Account__c();
                            accReq.Account__c = communityObject.Contact__r.AccountId;
                            accReq.Account_Request_Status__c = ConstantsController.IN_PROGRESS;
                            accReq.Deadline__c = unspecifiedRequest.Deadline__c;
                            accReq.Reference_Request__c = unspecifiedRequest.Reference_Request__c;
                            accReq.Request_Notes__c = unspecifiedRequest.Request_Notes__c;
                            accReq.Requester__c = unspecifiedRequest.Requester__c;
                            accReq.Reference_Type_Needed__c = unspecifiedRequest.Reference_Type_Needed__c;
                            accReq.Reference_Request_Additional_Info__c = unspecifiedRequest.Reference_Request_Additional_Info__c;
                            accReq.Managed_Request__c = true;
                            accReq.Process__c = ConstantsController.MANAGED;
                            accReq.Project_Owner__c = acc.Reference_Owner__c;
                            
                            WithoutSharingHelperController.upsertRRA(accReq);
                            
                            unspecifiedRequest.Specified_Account__c = accReq.Id;
                            unspecifiedRequest.Unspecified_Request_Status__c = ConstantsController.ACCOUNT_SPECIFIED;
                            ConstantsController.shouldUnspecifiedStatusChange = true;
                            
                            WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c> { unspecifiedRequest });
                        } else {
                            Reference_Request_Account__c accRefReq = [SELECT Request_Notes__c, Requester__c, Account_Request_Status__c, Reference_Type_Needed__c, 
                                                                        Deadline__c, Reference_Request__c, Reference_Request_Additional_Info__c, Project_Owner__c 
                                                                        FROM Reference_Request_Account__c WHERE Id = : hitRecordRequestId LIMIT 1][0];
                            accReq = new Reference_Request_Account__c();
                            accReq.Account__c = communityObject.Contact__r.AccountId;
                            accReq.Account_Request_Status__c = accRefReq.Account_Request_Status__c;
                            accReq.Deadline__c = accRefReq.Deadline__c;
                            accReq.Process__c = ConstantsController.MANAGED;
                            accReq.Reference_Request__c = accRefReq.Reference_Request__c;
                            accReq.Request_Notes__c = accRefReq.Request_Notes__c;
                            accReq.Requester__c = accRefReq.Requester__c;
                            accReq.Reference_Type_Needed__c = accRefReq.Reference_Type_Needed__c;
                            accReq.Reference_Request_Additional_Info__c = accRefReq.Reference_Request_Additional_Info__c;
                            accReq.Managed_Request__c = true;
                            accReq.Project_Owner__c = acc.Reference_Owner__c;
                            
                            WithoutSharingHelperController.upsertRRA(accReq);
                            
                            accRefReq.Account_Request_Status__c = ConstantsController.UNAVAILABLE;
                            
                            WithoutSharingHelperController.upsertRRA(accRefReq);
                        }
                        
                        if (communityObject.contact__c != null) {
                            Reference_Request_Account_Contact__c contactRequest = new Reference_Request_Account_Contact__c();
                            contactRequest.Contact__c = communityObject.Contact__c;
                            contactRequest.Contact_Email__c = communityObject.Contact__r.Email;
                            contactRequest.Contact_Phone__c = communityObject.Contact__r.Phone;
                            contactRequest.Deadline__c = accReq.Deadline__c;
                            contactRequest.Project_Owner__c = accReq.Project_Owner__c;
                            contactRequest.Contact_Request_Status__c = accReq.Account_Request_Status__c;
                            contactRequest.Reference_Request_Account__c = accReq.Id;
                            contactRequest.Referenceability_Type__c = accReq.Reference_Type_Needed__c;
                            contactRequest.Request_notes__c = accReq.Request_Notes__c;
                            
                            WithoutSharingHelperController.upsertRRAC(contactRequest);
                        }
                        setAccountRequest();
                    }
                }
            }
            communityIdtoDelete = '';
        } catch (Exception e) {
            Apexpages.addMessages(e);
            Database.rollback(sp);
        }
    }
    public String selectRefType { get; set; }
    public Boolean isChallengeCreated { get; set; }
    
    /**
     * Method to delete the community invite Contact records
     */
    public void communityInviteContactRecordDeletion() {
       
        if (communityIdtoDelete != '' && CRUDAndFLSCheckController.isDeletable(new List<String> {
        												UtilityController.appNamespace() + 'Community_Invite_Contact__c'})) {
            Community_Invite_Contact__c cic = [SELECT id FROM Community_Invite_Contact__c WHERE Id = : communityIdtoDelete];
            delete cic;
            refresh();
        }
    }
    
    /**
     * Method to check Permissions for create community invite and invite attributes
     */
    private Boolean checkPermissionsCommunity() {
    	Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Community_Invite_Attribute__c', new Set<String> {
        										UtilityController.appNamespace() + 'Community_Invite__c',
        										UtilityController.appNamespace() + 'Filter__c',
        										UtilityController.appNamespace() + 'Attribute__c'});
        fieldMap.put(UtilityController.appNamespace() + 'Community_Invite__c', new Set<String>());
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);
    }
    /**
     * Method to create the community invite records on post to community
     */
    public PageReference communityInviteRecordCreation() {
        Savepoint sp = Database.setSavepoint();
        try {
        	
	        if (checkPermissionsCommunity()) {
	            Community_Invite__c comInvite = new Community_Invite__c();
	            comInvite.Referenceability_Type__c = (communityReferencTypeId != '' ? communityReferencTypeId : null);
	            
	            if (communitydeadlineValue.contains('-')) {
	                comInvite.Community_Participate_Deadline__c = date.valueOf(communitydeadlineValue);
	            } else {
	                comInvite.Community_Participate_Deadline__c = date.parse(communitydeadlineValue);
	            }
	            comInvite.Community_Participate_Details__c = communitydetailsValue;
	            comInvite.Community_Participate_With__c = communitywithValue;
	            comInvite.Org_Instance_URl__c = URl.getSalesforceBaseUrl().toExternalForm();
	           
	            if (communityHitListRecordId == '') {
	                
	                if (!hitRecordIsUR) {
	                   
	                    for (Reference_Request_Account__c rra: [SELECT Account__c, (SELECT Id, Contact__c, Contact__r.Email, Contact__r.Phone 
	                    										FROM Reference_Request_Account_Contacts__r) FROM Reference_Request_Account__c 
	                    										WHERE Id = : hitRecordRequestId]) {
	                        comInvite.Account__c = rra.Account__c;
	                    }
	                }
	            } else {
	                
	                for (Hit_List__c hl: [SELECT Contact__c FROM Hit_List__c WHERE Id = : communityHitListRecordId]) {
	                    comInvite.contact__c = hl.contact__c;
	                }
	            }
	            comInvite.Reference_Request__c = refRequestObj.Id;
                comInvite = WithoutSharingHelperController.insertCommunityInvite(comInvite);
				
				if (communityInviteMap != null && comInvite.Referenceability_Type__c != null && !communityInviteMap.containsKey(comInvite.Referenceability_Type__c)) {
	            	communityInviteMap.put(comInvite.Referenceability_Type__c, comInvite);
				}
	            List<Community_Invite_Contact__c> newCICrecords = new List<Community_Invite_Contact__c>();
	            
	            for (String conId : contactEmailMap.keySet()) {
	                newCICrecords.add(new Community_Invite_Contact__c(Community_Invite__c = comInvite.Id, Contact__c = conId));
	            }
	            
	            if (newCICrecords.size() > 0) {
	                WithoutSharingHelperController.upsertContactInvites(newCICrecords);
	            }
	            List<Reference_Request_Account__c> updateRRA = new List<Reference_Request_Account__c>();
	            List<Unspecified_Request__c> updateUR = new List<Unspecified_Request__c>();
	            List<Hit_List__c> updateHitList = new List<Hit_List__c>();
	            
	            for (Reference_Request_Account__c rra : [SELECT Id, Community_Participate__c, Community_Invite__c FROM
	                    Reference_Request_Account__c WHERE Reference_Request__c = : refRequestObj.Id AND Reference_Type_Needed__c = : communityReferencTypeId AND
	                    Account_Request_Status__c != 'No Response' AND Account_Request_Status__c != 'Unavailable' AND Account_Request_Status__c != 'Completed' 
	                    AND Account_Request_Status__c != 'Give Up - Contact Unresponsive' AND Account_Request_Status__c != 'Give Up - Contact Left Company'
	                    AND Account_Request_Status__c != 'Give Up - Service Issues' AND Account_Request_Status__c != 'Give Up - Legal Won\'t Approve'
	                ]) {
	                rra.Community_Participate__c = true;
	                rra.Community_Invite__c = comInvite.Id;
	                updateRRA.add(rra);
	            }
	            
	            for (Unspecified_Request__c rra : [SELECT Id, Community_Participate__c, Community_Invite__c FROM Unspecified_Request__c
	                    WHERE Reference_Request__c = : refRequestObj.Id AND Reference_Type_Needed__c = : communityReferencTypeId AND
	                    Unspecified_Request_Status__c != 'No Longer Needed' AND Unspecified_Request_Status__c != 'Account Specified'
	                ]) {
	                rra.Community_Participate__c = true;
	                rra.Community_Invite__c = comInvite.Id;
	                updateUR.add(rra);
	            }
	            
	            for (Hit_List__c rra : [SELECT Id, Community_Invite__c FROM Hit_List__c WHERE Id = : communityHitListRecordId]) {
	                rra.Community_Invite__c = comInvite.Id;
	                updateHitList.add(rra);
	            }
	            
	            if (updateRRA.size() > 0) {
	                WithoutSharingHelperController.upsertRRAList(updateRRA);
	            }
	                
	            if (updateUR.size() > 0) {
	                WithoutSharingHelperController.updateUnspecified(updateUR);
	            }
	                
	            if (updateHitList.size() > 0) {
	                WithoutSharingHelperController.updateHitList(updateHitList);
	            }
	                
	            isRequestAssociatedToCommunity = true;
	            associateAttributesToCI(comInvite);
	            
	            if (isSend || EditThenSend == 'true') {
	                sendCommunityMailToCommMembers(comInvite);
	            }
	                
	            PageReference ReturnPage = new PageReference(Page.RefRequestProject.geturl() + '?Id=' + refRequestObj.Id + '&activeTab=' + activeTab);
                
                //REF-2304
                if (isRefHubMatch == 'true') {
                    ReturnPage.getParameters().put('isRefHubMatch', 'true');
                }
	            ReturnPage.setRedirect(true);
	            return ReturnPage;
	        }
	        return null;
        } catch (exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
            return null;
        }
    }
    /**
     * Method to associates attributes to community invite
     */
    private void associateAttributesToCI(Community_Invite__c comInvite) {
        try {
            List<Community_Invite_Attribute__c> comInviteAttribute = new List<Community_Invite_Attribute__c>();
            
            for (String labelId: refUseAttr.mapAttributesLabels.keySet()) {
                
                for (SelectProjectUseAttribute.AttributesLabelWrapper aw: refUseAttr.mapAttributesLabels.get(labelId)) {
                    comInviteAttribute.add(new Community_Invite_Attribute__c(Filter__c = labelId, Attribute__c = aw.attributeLabel.Attribute__c, 
                    						Community_Invite__c = comInvite.Id));
                }
            }
            insert comInviteAttribute;
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }
    /**
     * Method to send the emails to community members
     */
    public String editedBody { get; set; }
    private void sendCommunityMailToCommMembers(Community_Invite__c comInvite) {
        try {
            List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
            String body = ''; 
            
            for (String conId : contactEmailMap.keySet()) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                //Email subject
                mail.setSubject(communitysubjectValue);
                
                //Prepare body for email
                body = (EditThenSend == 'true' ? editedBody : editThenSendEmailBody);
                
                if (body.contains('refedge__')) {
                    body = body.replace('refedge__', '');
                }
                
                //Replace Body
                if (body.contains('{!Contact.FirstName}')) {
                    body = body.replace('{!Contact.FirstName},', (contactEmailMap.get(conId).Contact.firstName != null 
                    					? contactEmailMap.get(conId).Contact.firstName + ',' : ''));
                }
                
                if (body.contains('{!Community_Invite__c.Referenceability_Type_f__c}')) {
                    body = body.replace('{!Community_Invite__c.Referenceability_Type_f__c}', (includeReferenceability ? communityReferencTypeName : 'n/a'));
                }
                
                if (body.contains('{!Community_Invite__c.Community_Participate_With__c}')) {
                    body = body.replace('{!Community_Invite__c.Community_Participate_With__c}', comInvite.Community_Participate_With__c);
                }
                
                if (body.contains('{!Community_Invite__c.Community_Participate_Deadline__c}')) {
                    body = body.replace('{!Community_Invite__c.Community_Participate_Deadline__c}', String.valueOf(comInvite.Community_Participate_Deadline__c));
                }
                
                if (body.contains('{!Community_Invite__c.Community_Participate_Details__c}')) {
                    body = body.replace('{!Community_Invite__c.Community_Participate_Details__c}', comInvite.Community_Participate_Details__c);
                }
                
                if (body.contains('{!Community_Invite__c.Community_Yes_Im_In_Link__c}')) {
                    body = body.replace('{!Community_Invite__c.Community_Yes_Im_In_Link__c}', '<a href="' + UtilityController.getCommunityUrl() + '/apex/' 
                    					+ UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' + comInvite.Id + '&response=yes">Yes, I\'m in!</a> ');
                } else {
                    body += '\n\n<a href="' + UtilityController.getCommunityUrl() + '/apex/' + UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' 
                    					+ comInvite.Id + '&response=yes">Yes, I\'m in!</a> ';
                }
                
                if (body.contains('{!Community_Invite__c.Community_No_Thanks_Link__c}')) {
                    body = body.replace('{!Community_Invite__c.Community_No_Thanks_Link__c}', '<a href="' + UtilityController.getCommunityUrl() + '/apex/' 
                    					+ UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' + comInvite.Id + '&response=no">No Thanks</a> ');
                } else {
                    body += '\n\n<a href="' + UtilityController.getCommunityUrl() + '/apex/' + UtilityController.appNamespace() + 'RefedgeCommunityHome?Id=' 
                    					+ comInvite.Id + '&response=no">No Thanks</a> ';
                }
                
                if (body.contains('{!Community_Invite__c.Community_Participate_Link__c}')) {
                    body = body.replace('{!Community_Invite__c.Community_Participate_Link__c}', '<a href="' + UtilityController.getCommunityUrl() + '/apex/' 
                						+ UtilityController.appNamespace() + 'RefedgeCommunityHome">Go to the Customer Reference Community</a> ');
                } else { 
                	body += '\n\n<a href="' + UtilityController.getCommunityUrl() + '/apex/' + UtilityController.appNamespace() 
                							+ 'RefedgeCommunityHome">Go to the Customer Reference Community</a> ';
                }
                
                if (body.contains('{')) {
                    body = body.replace('{', '');
                }
                
                if (body.contains('}')) {
                    body = body.replace('}', '');
                }
                mail.setHtmlBody(MailChatterController.setEmailTemplateBody(body));
                
                //Email Id's for selected contacts
                String[] toAddresses = new String[] {
                    (contactEmailMap.get(conId).Contact.Email != null ? contactEmailMap.get(conId).Contact.Email : contactEmailMap.get(conId).Email)
                };
                mail.setToAddresses(toAddresses);
                listmail.add(mail);
            }
            //}
            if (listmail.size() > 0) {
                Messaging.sendEmail(listmail);
            }

        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }
        
    /**
     * Method to redirect to rfsearch match page
     * REF-1964
     */
    public PageReference goToRefHubMatch() {
        try {
            String parameters = '?RefRequestId=' + refRequestObj.Id + '&isRefMatch=true&isRefHubMatch=true' + '&selectedUR=' 
                				+ selectRefType + '&activeTab=' + activeTab + '&inlineeditingenable=' + isInlineEditingDisabled;
            PageReference ReturnPage = new PageReference(Page.RfSearchPage.geturl() + parameters);
            ReturnPage.setRedirect(true);
            return ReturnPage;
        } catch (System.Exception e) {
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, e.getMessage()));
            return null;
        }
    }
    
    /**
     * Method to get information of selected contacts
     * REF-1964
     */
    public void getSelectedContactInfo() {
        List<String> listOfIds = new List<String>();
        
        if (!String.isEmpty(selectedContactIds)) {
            listOfIds = selectedContactIds.split(',');
            listOfSelectedContacts = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id IN : listOfIds];
            listOfCICForAdvocates = new List<Community_Invite_Contact__c>();
        }
    }
    
    /**
     * Method to remove selected contact
     * REF-1964
     */
    public void removeSelectedContact() {
        List<Contact> tempContact = new List<Contact>();
        Integer count = 0;
        
        if (listOfSelectedContacts.size() > 0) {
            tempContact.addAll(listOfSelectedContacts);
            
            for (Contact con : listOfSelectedContacts) {
                
                if (con.Id == contactIdToRemove) {
                    tempContact.remove(count);
                    break;
                }
                count++;
            }
            listOfSelectedContacts = new List<Contact>();
            listOfSelectedContacts.addAll(tempContact);
        }
        
    }
    
    /**
     * Method to post challenge request at influitive
     * REF-1964
     */
    public void postChallengeInInfluitive() {
        isChallengeError  = false;
        challengeError = '';
        RefRequestProjectControllerSLDS.InfluitiveWrapper influtiveWrap = new RefRequestProjectControllerSLDS.InfluitiveWrapper();
        influtiveWrap.accountName = 'Unspecified';
        influtiveWrap.participantLimit = participantLimit;
        influtiveWrap.unspecifiedRequestId = selectRefType;
        Date temp = Date.today();
        String startAt = temp.year() + '-' + temp.month() + '-' + temp.day();
        influtiveWrap.startAt = startAt;
        List<String> tempList = inflDeadlineDate.split('/');
        influtiveWrap.endAt = tempList[2] + '-' + tempList[0] + '-' + tempList[1];
        List<Referenceability_Type__c> listOfRefType = [SELECT Id,Referenceability_code__c,Name
                                                        FROM Referenceability_Type__c 
                                                        WHERE Id =: refTypeNeeded];
        
        if (listOfRefType.size() > 0) {
            
            if (listOfRefType[0].Referenceability_code__c != null && !String.isEmpty(listOfRefType[0].Referenceability_code__c)) {
                influtiveWrap.templateCode = listOfRefType[0].Referenceability_code__c;
                
                Infl_CreateReferenceResponse response = Infl_Reference.createReferenceChallenge(influtiveWrap, listOfSelectedContacts);
                
                if (response != null) {
                    
                    if (response.errors != null) {
                        
                        if (response.errors.template_code != null) {
                            isChallengeError  = true;
                            //REF-2301
                            challengeError = String.format(Label.Error_Challenge_Template_Not_Available, new List<String> {listOfRefType[0].Name});
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
                        } else {
                            isChallengeError  = true;
                            challengeError = 'Error';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
                        }
                        
                    } else {
                        
                        if (response.uuid != null && response.uuid != '') {
                            influtiveWrap.challengeId = response.uuid;
                            listOfCICForAdvocates = createCommunityInviteContactRecords(influtiveWrap,listOfSelectedContacts);
                            listOfSelectedContacts = new List<Contact>();
                            setAccountRequest();
                            
                        } else if (response.uuid != null && response.uuid == '') {
                            isChallengeError  = true;
                            challengeError = 'Empty uuid recieved!';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
                        } else {
                            isChallengeError  = true;
                            challengeError = 'No uuid in response from Hub!';
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
                        }
                    }
                } else {
                    isChallengeError  = true;
                    challengeError = 'Error';
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
                }
            } else {
                isChallengeError  = true;
                //REF-2301
                challengeError = String.format(Label.Error_No_Referenceability_Code_On_Referenceability_Type, new List<String> {listOfRefType[0].Name});
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
            }
        }
    }
    
    /**
     * Method to create CIC record for posted challenge
     * REF-1964
     */
    public List<Community_Invite_Contact__c> createCommunityInviteContactRecords(RefRequestProjectControllerSLDS.InfluitiveWrapper influtiveWrap, List<Contact> listOfSelectedContacts) {
        Savepoint sp = Database.setSavepoint();
        Set<String> contactIds = new Set<String>();
        ConstantsController.isCallToInfluitiveAPI = true;
        
        if (listOfSelectedContacts.size() > 0) {
            
            for (Contact con : listOfSelectedContacts) {
                contactIds.add(con.Id);
            }
        }
        List<Community_Invite_Contact__c> listOfCIC = new List<Community_Invite_Contact__c>();
        String result = '';        
        List<String> tempList = influtiveWrap.endAt.split('-');
        Date dateInstance = Date.newinstance(Integer.valueOf(tempList[0]),Integer.valueOf(tempList[1]),Integer.valueOf(tempList[2]));
        
        try {
            Unspecified_Request__c ur = [SELECT Id, Name, Reference_Request__c, Reference_Type_Needed__c, Reference_Type_Needed_f__c, 
                                         Unspecified_Request_Status__c, Community_Invite__c, Influitive_Challenge_Id__c,
                                         Influitive_Challenge_Status__c, Notes__c, Deadline__c 
                                         FROM Unspecified_Request__c
                                         WHERE Id =: influtiveWrap.unspecifiedRequestId];
            
            Community_Invite__c comInvite = new Community_Invite__c();
            comInvite.Referenceability_Type__c = refTypeNeeded;
            comInvite.Reference_Request__c = ur.Reference_Request__c;
            comInvite.Unspecified_Request__c = ur.Id;
            comInvite = WithoutSharingHelperController.insertCommunityInvite(comInvite);
            
            if (contactIds.size() > 0) {
                
                for (String conId : contactIds) {
                    Community_Invite_Contact__c newCIC = new Community_Invite_Contact__c();
                    newCIC.Community_Invite__c = comInvite.Id;
                    newCIC.Contact__c = conId;
                    //newCIC.Response__c = 'No Response';
                    newCIC.Challenge_Id__c = influtiveWrap.challengeId;
                    listOfCIC.add(newCIC);
                }
                Set<String> CICIds = new Set<String>();
                
                if (listOfCIC.size() > 0) {
                    WithoutSharingHelperController.upsertContactInvites(listOfCIC);
                    
                    for (Community_Invite_Contact__c cic : listOfCIC) {
                        CICIds.add(cic.Id);
                    }
                }
                
                if (CICIds.size() > 0) {
                    listOfCIC  = [SELECT Id,Account_f__c,Challenge_Id__c,Contact_Name__c,Referenceability_Type__c,
                                  Response__c,Community_Invite__c,Contact__c
                                  FROM Community_Invite_Contact__c
                                  WHERE Id IN: CICIds]; 
                }
            }
            
            ur.Community_Invite__c = comInvite.Id;
            ur.Influitive_Challenge_Id__c = influtiveWrap.challengeId;
            ur.Reference_Type_Needed__c = refTypeNeeded;
            ur.Deadline__c = dateInstance;
            ur.Unspecified_Request_Status__c = 'In Progress';
            ur.Influitive_Challenge_Status__c = 'Unpublish';
            WithoutSharingHelperController.updateUnspecified(new List<Unspecified_Request__c>{ur});
            
        } catch(Exception e) {
            result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
            Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, result));
            Database.rollback(sp);
            return null;
        }
        return listOfCIC;
    }
    
    /**
     * Method to change Minimum Deadline
     * REF-1964
     */
    public void changeMinimumDeadline() {
        minimumDeadline = String.valueOf(refTypeMap.get(refTypeNeeded).min_lead_time_per_request_type__c);
        refDeadline = calculateDate(Date.today(), Integer.valueOf(minimumDeadline)).format();
    }
    
    public void setRefTypeNeeded() {
        minimumDeadline = String.valueOf(refTypeMap.get(refTypeNeeded).min_lead_time_per_request_type__c);
        
        if (refTypeDeadlineMap.containsKey(refTypeNeeded)) {
            refDays = String.valueOf(refTypeDeadlineMap.get(refTypeNeeded));
        }
    }
    
    /**
     * Method to get CICs for UR
     * REF-1964
     */
    public void getRelatedCICByChallengeId(String challengeId) {
        List<Community_Invite_Contact__c> listCIC = [SELECT Id, Account_f__c, Challenge_Id__c, Contact_Name__c, Referenceability_Type__c,
                              						 Response__c, Community_Invite__c, Contact__c 
                                                     FROM Community_Invite_Contact__c 
                                                     WHERE Challenge_Id__c =: challengeId];
        
        if (listCIC.size() > 0) {
            listOfCICForAdvocates.addAll(listCIC);
        }
    }
    
    /**
     * Method to assign contact to the challenge request
     * REF-1964
     */
    public void assignAdvocateToChallenge() {
        Savepoint sp = Database.setSavepoint();
        Reference_Request_Account__c accReq = new Reference_Request_Account__c();
        Reference_Request_Account_Contact__c conReq = new Reference_Request_Account_Contact__c();
        List<Unspecified_Request__c> urToUpdate = [SELECT Id, Name, Reference_Request__c, Reference_Type_Needed__c, Reference_Type_Needed_f__c, 
                                                   Unspecified_Request_Status__c, Community_Invite__c, Influitive_Challenge_Id__c,
                                                   Influitive_Challenge_Status__c, Notes__c, Deadline__c
                                                   FROM Unspecified_Request__c
                                                   WHERE Id =: selectRefType];
        List<Contact> conInstance = [SELECT Id, FirstName, LastName, Email, AccountId 
                                     FROM Contact 
                                     WHERE Id =: assignedContactId];
        
        if (conInstance.size() > 0 && urToUpdate.size() > 0) {
            List<Referenceability_Type__c> refType = [SELECT Id,Reward_points__c,Referenceability_code__c 
                                                      FROM Referenceability_Type__c 
                                                      WHERE Id =: urToUpdate[0].Reference_Type_Needed__c];
            try {
                ConstantsController.isCallToInfluitiveAPI = true;
                accReq.Account__c = conInstance[0].AccountId;
                accReq.Reference_Request__c = urToUpdate[0].Reference_Request__c;
                accReq.Reference_Type_Needed__c = urToUpdate[0].Reference_Type_Needed__c;
                accReq.Influitive_Challenge_Id__c = urToUpdate[0].Influitive_Challenge_Id__c;
                accReq.Influitive_Challenge_Status__c = urToUpdate[0].Influitive_Challenge_Status__c;
                accReq.Account_Request_Status__c = 'In Progress';
                accReq.Reference_Use__c = true;
                accReq.Process__c = ConstantsController.MANAGED;
                accReq.Deadline__c = system.today();
                WithoutSharingHelperController.upsertRRA(accReq);
                conReq.influitiveId__c = accReq.Influitive_Challenge_Id__c;
                conReq.Referenceability_Type__c = accReq.Reference_Type_Needed__c;
                conReq.Reference_Request_Account__c = accReq.Id;
                conReq.Activity_Date__c = system.today();
                conReq.Reference_Use__c = true;
                conReq.Deadline__c = system.today();
                conReq.Contact__c = conInstance[0].Id;
                conReq.Contact_Request_Status__c = 'In Progress';
                WithoutSharingHelperController.upsertReqAccountContact(conReq);
                urToUpdate[0].Specified_Account__c = accReq.Id;
                urToUpdate[0].Unspecified_Request_Status__c = 'Account Specified';
                ConstantsController.shouldUnspecifiedStatusChange = true;
                WithoutSharingHelperController.updateUnspecified(urToUpdate);
                //Issue Reward
                Reward__c reward = new Reward__c();
                reward.Account__c = accReq.Account__c;
                reward.Contact__c = conReq.Contact__c;
                reward.Referenceability_Type__c = accReq.Reference_Type_Needed__c;
                reward.Transaction__c = ConstantsController.ISSUE;
                reward.RewardDate__c = Date.today();
                reward.Automatically_Assigned__c = true;
                reward.Account_Request__c = accReq.Id;
                reward.Contact_Request__c = conReq.Id;
                reward.Amount__c = refType[0].Reward_points__c == null ? 0 : refType[0].Reward_points__c;
                String typeCode = refType[0].Referenceability_code__c == null ? 'Non Reference Activity' : refType[0].Referenceability_code__c;
                WithoutSharingHelperController.upsertRewards(new List<Reward__c> {reward});
                //syncRewards(reward.Id,typeCode);
                listOfCICForAdvocates = new List<Community_Invite_Contact__c>();
                setAccountRequest();
            } catch(Exception e) {
                String result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, result));
                Database.rollback(sp);
            }
        }
    }
    
    /**
     * Method to sync rewards with influitive
     * REF-1964
     */
    @future(callout=true)
    public static void syncRewards(String rewardId, String typeCode) {
        List<Reward__c> listOfRewards = [SELECT Id, Influitive_ID2__c,Contact__c, Contact__r.Email, Amount__c
                                        FROM Reward__c
                                        WHERE Id =: rewardId];
        
        if (listOfRewards.size() > 0) {
            String rewardHubId = Infl_Event.syncRewardAtHub(listOfRewards[0],typeCode);
            
            if (!String.isBlank(rewardHubId)) {
                listOfRewards[0].Influitive_ID2__c = rewardHubId;
                WithoutSharingHelperController.upsertRewards(listOfRewards);
            }
        }
    }
    
    /**
     * Method to sync challenge status with influitive
     * REF-1964
     */
    public void updateChallengeStatus() {
        Infl_CreateReferenceResponse response = null;
        
        if (!String.isEmpty(updatedChallengeStatus)) {
            
            if(!String.isEmpty(selectRefType)) {
                List<Unspecified_Request__c> urToUpdate = [SELECT Id, Influitive_Challenge_Id__c, Influitive_Challenge_Status__c
                                                           FROM Unspecified_Request__c
                                                           WHERE Id =: selectRefType];
                
                if (urToUpdate.size() > 0) {
                    
                    if (updatedChallengeStatus == urToUpdate[0].Influitive_Challenge_Status__c) {
                        isChallengeError  = true;
                        challengeError = 'Challenge Status not changed!';
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
                    } else {
                        urToUpdate[0].Influitive_Challenge_Status__c = updatedChallengeStatus;
                        response = Infl_Reference.changeReferenceChallengeStatus(updatedChallengeStatus, urToUpdate[0].Influitive_Challenge_Id__c, null);
                        
                        if (response != null && response.status != null && response.status != '') {
                            Savepoint sp = Database.setSavepoint();
                            try {
                                WithoutSharingHelperController.updateUnspecified(urToUpdate);
                                setAccountRequest();
                            } catch (Exception e) {
                                String result = e.getLineNumber() + '---' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getmessage());
                                Apexpages.addMessage(new Apexpages.Message(Apexpages.severity.INFO, result));
                                Database.rollback(sp);
                            }
                        }
                    }                    
                }
            }
        } else {
            isChallengeError  = true;
            challengeError = 'Challenge Status cannot be empty';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,challengeError));
        }
    }
}