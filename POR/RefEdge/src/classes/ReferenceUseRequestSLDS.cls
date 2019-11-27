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
 * VF Page: ReferenceUseRequestSLDS.page
 * Description : controller for submitting a Reference Use Request
 * Last modified by: Rekha @1 June 2017
 */ 
global with sharing class ReferenceUseRequestSLDS extends RefEdgeEditionFeatures {
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
    private static String REFERENCE_REQUEST_SUBJECT = 'Self Service Reference Request';
    private static String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.SelectReferenceUseContactsSLDS.getURL() + '?id=';
    
    /**
     * Properties and variables
     */
    public String accountIds { get; set; }
    public String forAccount { get; set; }
    public String forContent { get; set; }
    public String opportunityId { get; set; }
    public String caseId { get; set; }
    public String helpAssistant { get; set; }
    public String helpOverlay { get; set; }
    public boolean showOveray { get; set; }
    
    //regarding ticket #809
    public String leadId { get; set; }
    public Boolean isThisBasic {
        get {
            return isBasic;
        }
        set;
    }
    public string userDateFormat {
        get {
            return (ConstantsController.localeDateFormatMap != null
                            && ConstantsController.localeDateFormatMap.containsKey(UserInfo.getLocale())
                        ? ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0) : 'dd-MM-yyyy');
        }
        set;
    }
    public string oppName { get; set; }
    public string oppAccName { get; set; }
    //regarding ticket #809
    public string leadName { get; set; }
    public string leadCompany { get; set; }
    public string caseName { get; set; }
    public string caseAccName { get; set; }
    public string accId { get; set; }
    public string salesRewardMsg {
        get {
            return ConstantsController.REQUEST_SALES;
        }
        set;
    }
    public Boolean isAdvRouting { get; set; }
    public Boolean isMandatory { get; set; }
    public String businessGrpName { get; set; }
    public Boolean isAccountSelected { get; set; }
    public static Map<String, Set<sObject>> feedItemRRAMap { get; set; }
    //to resolve namespace issue on package creation
    public String nameSpace {
        get {
            return UtilityController.appNamespace();
        }
        private set;
    }
    // added for #575 - territories map
    public Map<String, sObject> territoryMap { get; set; }
    private List<User_Mapping__c> userMappingList;
    private Date lastActivity;
    public Custom_Settings__c cs { get;set; }
    //REF-2132
    public String firstPublishLocationIdForCV { get;set; }
    public Boolean attachSupportingDocuments { get;set; }

    /**
     * Constructor
     */
    global ReferenceUseRequestSLDS() { 
        cs = UtilityController.getCustomSettings();
        accountIds = ApexPages.currentPage().getParameters().get('accountIds');  
        isAccountSelected = (accountIds != null && accountIds != '' ? true : false);
        opportunityId = (ApexPages.currentPage().getParameters().get('opportunityId') != null ? ApexPages.currentPage().getParameters().get('opportunityId') : '');
        caseId = (ApexPages.currentPage().getParameters().get('caseId') != null ? ApexPages.currentPage().getParameters().get('caseId') : '');
        leadId = (ApexPages.currentPage().getParameters().get('leadId') != null ? ApexPages.currentPage().getParameters().get('leadId') : '');
        forAccount = ApexPages.currentPage().getParameters().get('forAccount');
        forContent = ApexPages.currentPage().getParameters().get('forContent');

         //REF-2132
        firstPublishLocationIdForCV = String.valueOf(UserInfo.getUserId());
		attachSupportingDocuments = cs.Attach_Supporting_Documents_To_Requests__c;

        //Check User premissions
        //checkPermissions(true,'PAGE_LOAD', opportunityId, caseId, leadId);
        
        if (opportunityId != null && opportunityId != '') {
            List<Opportunity> tempList = [SELECT Id, Name, AccountId, Account.Name, OwnerId
                                            FROM Opportunity
                                            WHERE Id = :opportunityId LIMIT 1];
            
            if (tempList.size() > 0) {
                oppAccName = tempList[0].Account.Name;
                oppName = tempList[0].Name;
                accId = tempList[0].AccountId;
            }
        }
        
        if (caseId != null && caseId != '') {
            List<Case> tempList = [SELECT Id, CaseNumber, AccountId, Account.Name, OwnerId
                                    FROM Case WHERE Id = :caseId LIMIT 1];
            
            if (tempList.size() > 0) {
                caseName = tempList[0].CaseNumber;
                caseAccName = tempList[0].Account.Name;
                accId = tempList[0].AccountId;
            }
        }
        
        //regarding ticket #809
        if (leadId != null && leadId != '') {
            List<Lead> tempList = [SELECT Id, Name, Company, OwnerId FROM Lead WHERE Id = :leadId LIMIT 1];
            
            if (tempList.size() > 0) {
                leadName = tempList[0].Name;
                leadCompany = tempList[0].Company;
            }
        }
        
        isAdvRouting = cs.Adv_Request_Routing__c;
        isMandatory = cs.Adv_Routing_Group_Mandatory__c;
        businessGrpName = (cs.Adv_Routing_Group_Lbl__c == null || cs.Adv_Routing_Group_Lbl__c == '') ? System.Label.Advanced_Routing_Group : cs.Adv_Routing_Group_Lbl__c;  
        
        userMappingList = new List<User_Mapping__c>(); 
        lastActivity = Date.Today();
        showOveray = false; 
        Map<Decimal,DMNameValueWrapper> tempMapDM = new Map<Decimal,DMNameValueWrapper>();
        tempMapDM = new Map<Decimal,DMNameValueWrapper>();

        for (Data_Mapping__c dm : WithoutSharingHelperController.getDMHelpOverlay(new List<String> {UtilityController.appNamespace() + 'ReferenceUseRequestSLDS'})) {
            tempMapDM.put(dm.Order__c, new DMNameValueWrapper(dm.Label__c,dm.DC_Message__c));
        }
        helpOverlay = JSON.serialize(tempMapDM); 

        if (cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) {
            helpAssistant = '';
            checkForHelpOverlay();
        }
        
    }

    /**
    *   Method to check whether to show help overlay on page or not
    *   Author : Rajesh (27 May,2018) for REF-1572
    **/
    public void checkForHelpOverlay() {  
        showOveray = true;  
        userMappingList = [SELECT Id, Label__c, Count__c, User__c, Last_Used_Lightning_Page__c FROM User_Mapping__c 
                                WHERE User__c =:UserInfo.getUserId() AND Label__c =:ConstantsController.REQUEST_HELP_OVERLAY  
                                LIMIT 1];

        if (userMappingList.Size() > 0 && userMappingList[0].Count__c != null && userMappingList[0].Count__c >= cs.Help_Overlay_Count__c) {
            showOveray = false;
        }
        
        if (cs.Reset_Help_Assistant_Days__c != null && cs.Reset_Help_Assistant_Days__c > 0 && userMappingList.size() > 0 && userMappingList[0].Last_Used_Lightning_Page__c != null) {
            lastActivity = UtilityController.parseLastVisitDate(userMappingList[0].Last_Used_Lightning_Page__c);
        }         
    }
    /**
     *   Method to check whether to show help overlay on page or not
     *   Author : Rajesh (27 May,2018) for REF-1572
     **/
    public void userMappingRecord() {       
    	DateTime todayDate = system.today();
    	
        //  check user mapping count and custom setting count
        if (showOveray) {
                    
            if (userMappingList.Size() > 0) { 
            
                if (userMappingList[0].Count__c != null) {     
                    
                    if (cs.Reset_Help_Assistant_Days__c != null && lastActivity.daysBetween(Date.today()) > cs.Reset_Help_Assistant_Days__c) {
                        helpAssistant = ConstantsController.HELP_ASSISTANT;
                        userMappingList[0].Count__c = 1; 
                    }  else {
                        userMappingList[0].Count__c += 1;
                    }  
                } else {
                    userMappingList[0].Count__c = 1;
                }
                userMappingList[0].Last_Used_Lightning_Page__c = todayDate.format('yyyy-MM-dd');
                             
            } else {
                User_Mapping__c umr = new User_Mapping__c();
                umr.Label__c = ConstantsController.REQUEST_HELP_OVERLAY;
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
            showOveray = true;
        } 

        if (userMappingList.Size() > 0 && cs.Help_Overlay_Count__c != null && cs.Help_Overlay_Count__c > 0) { 
            upsert userMappingList;  
        }                 
    }

    /**
     * Method to get Advance Routing group  : DEPRECATED
     */
    global static List<AdvRoutingGroups> getRoutingGroup() {
            return null;
    }

    /**
     * Method to get Advance Routing group #436
     */
    @RemoteAction
    global static String getRoutingGroup1() {
        
        try {
            Custom_Settings__c cs  = UtilityController.getCustomSettings();
            List<AdvRoutingGroups> listRoutingGrp = new List<AdvRoutingGroups>();
            
            if (cs.Adv_Request_Routing__c) {
                
                for (Advanced_Routing__c advRouting : [SELECT Adv_Routing_Client_Value__c FROM Advanced_Routing__c
                                                        WHERE Adv_Routing_Client_Value__c != null
                                                        LIMIT :limits.getLimitQueryRows()]) {
                    listRoutingGrp.add(new AdvRoutingGroups(advRouting.Adv_Routing_Client_Value__c.trim(), advRouting.Adv_Routing_Client_Value__c.trim()));
                }
                return JSON.serialize(listRoutingGrp);
            } else {
                return '';
            }
        } catch (exception e) {
            return 'Error: ' + CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage());
        }
    }
    
    /**
     * Get Custom settings
     */
    @RemoteAction
    global static Custom_Settings__c fetchCS() {
        return UtilityController.getCustomSettings();
    }
    
    /**
     * RemoteAction to submit request
     * REF-2132 returned Reference Request id in result
     */
    @RemoteAction
    global static String submitRequest(String accountsJSON, String fieldMapJSON, String filterJSON,
                                        String refTypeIdSetJSON, String refTypesJson, String opportunityId,
                                        String caseId, String isBasicValueAndRoutingGroup) {
        String leadId = '';
        String routingGroup = '';
        String inactiveUserInfoMsg = '';
        Set<String> selectedRoutingGroups = new Set<String>();
        //REF-2132
        String refRequestId = '';
        
        //regarding ticket #809
        if (caseId != null && caseId != '' && caseId.substring(0, 3) == '00Q') {
            leadId = caseId;
            caseId = '';
        }
        
        if (checkPermissions(true,'SAVE', opportunityId, caseId, leadId)) {                                 
            Savepoint sp = Database.setSavePoint();
            
            try {
                Boolean isBasic = true;
                // Here we are splits input parameter to get both parameters(IsBasic and Routing Groups)
                List<String> lstForBasicAndGrp = isBasicValueAndRoutingGroup.split('@@');
                
                if (lstForBasicAndGrp.size() > 0) {
                    
                    if (lstForBasicAndGrp.size() > 1) {
                        
                        if (lstForBasicAndGrp[0] == 'false') {
                            isBasic = false;
                        }
                        routingGroup = lstForBasicAndGrp[1];
                        
                        for (String groupName : routingGroup.split(',')) {
                            selectedRoutingGroups.add(groupName);
                        }
                    } else {
                        
                        if (lstForBasicAndGrp[0] == 'false') {
                            isBasic = false;
                        }                   
                    }
                }
                Set<String> refFieldSet = (Set<String>)JSON.deserialize(refTypeIdSetJSON, Set<String>.class);
                Map<string, RefTypeWrapper> listOfReferenceabilities = (Map<string, RefTypeWrapper>)JSON.deserialize(refTypesJson, Map<string, RefTypeWrapper>.class);
                Map<string, LabelWrapper> filterWrapperMap = (Map<string, LabelWrapper>)JSON.deserialize(filterJSON, Map<string, LabelWrapper>.class);
                Map<string, RefAddiFieldWrapper> fieldWrapperMap = (Map<string, RefAddiFieldWrapper>)JSON.deserialize(fieldMapJSON, Map<string, RefAddiFieldWrapper>.class);
                Map<integer, ReferenceUseAccountWrapper> selectedAccounts = (Map<integer, ReferenceUseAccountWrapper>)JSON.deserialize(accountsJSON, Map<integer, ReferenceUseAccountWrapper>.class);
                Set<String> convertedRRAs = new Set<String>();
             
                List<Reference_Request_Account__c> insertRefReqAcc = new List<Reference_Request_Account__c>();
                List<Unspecified_Request__c> insertUnspecifiedReq = new List<Unspecified_Request__c>();
                Reference_Request__c referenceRequest = new Reference_Request__c(Project_Type__c = 'Member',
                                                                    //regarding ticket #809
                                                                    Lead__c = ((leadId == '' || (leadId.length() != 15 && leadId.length() != 18))
                                                                                ? null : (Id)leadId),
                                                                    Case__c = ((caseId == '' || (caseId.length() != 15 && caseId.length() != 18))
                                                                                ? null : (Id)caseId),
                                                                    Opportunity__c = ((opportunityId == '' || (opportunityId.length() != 15 && opportunityId.length() != 18))
                                                                                ? null : (Id)opportunityId),
                                                                    Requester__c = UserInfo.getUserId(),
                                                                    Reference_Request_Status__c = (isBasic
                                                                                ? ConstantsController.IN_PROGRESS : ConstantsController.NOT_STARTED), 
                                                                    Adv_Routing_Group__c = routingGroup);
                insert referenceRequest;
                //REF-2132
                refRequestId = referenceRequest.Id;
                Custom_Settings__c cs = UtilityController.getCustomSettings();
                Boolean isAllReqManaged = false;
                Map<String, sObject> currencyMap = new Map<String, sObject>();
                Boolean isCurrencyEnabled = UtilityController.isCurrencyEnabled();
                
                if (UserInfo.isMultiCurrencyOrganization() && isCurrencyEnabled && !isBasic) {
                    currencyMap = UtilityController.getAllCurrency();
                }
                
                if (cs.Managed_Request_Opportunity_Threshold__c != null && opportunityId != '' && !isBasic) { 
                    
                    if (UserInfo.isMultiCurrencyOrganization() && isCurrencyEnabled) {
                        decimal amount = (cs.Managed_Request_Opportunity_Threshold__c / Decimal.valueOf(string.valueOf(currencyMap.get(string.valueOf(cs.get('CurrencyIsoCode'))).get('ConversionRate'))));
                        
                        for (Opportunity opp : Database.query('SELECT Amount, CurrencyIsoCode FROM Opportunity WHERE Id = :opportunityId')) {
                            
                            if (opp.Amount != null) {
                                decimal oppAmount = (opp.Amount / Decimal.valueOf(string.valueOf(currencyMap.get(string.valueOf(opp.get('CurrencyIsoCode'))).get('ConversionRate'))));
                                
                                if (oppAmount > amount) {
                                    isAllReqManaged = true;
                                }
                            }
                        }
                    } else {
                        
                        for (Opportunity o : [SELECT amount FROM Opportunity WHERE Id = :opportunityId]) {
                            
                            if (o.amount > cs.Managed_Request_Opportunity_Threshold__c) {
                                isAllReqManaged = true;
                            }
                        }
                    }
                }
                Boolean isRepToRep = false;
                Map<Id, Reference_Basic_Information__c> mapAccount = new Map<Id, Reference_Basic_Information__c>();
                Map<String, String> mapAccountOwnerId = new Map<String, String>();
                
                /******************* changes start for #441 *******************/
                // map containing Ids of all the mapped attributes in the advanced routing object
                Map<String, Advanced_Routing__c> mappedAttributesMap = new Map<String, Advanced_Routing__c>();
                Map<String, Advanced_Routing__c> mappedTerritoriesMap = new Map<String, Advanced_Routing__c>();
                
                for (Advanced_Routing__c ar : WithoutSharingHelperController.getRoutingDetails()) {
                    
                    if (ar.Adv_Routing_Attribute__c != null) {
                        mappedAttributesMap.put(ar.Adv_Routing_Attribute__c, ar);
                    }
                    
                    if (ar.Territory_Id__c != null && ar.Territory_Id__c != '') {
                        mappedTerritoriesMap.put(ar.Territory_Id__c, ar);
                    }
                }
                // getting the account team object and related fields from custom settings
                Map<String,SObject> contactToUserMap = new Map<String,SObject>();
                String contactField = cs.Adv_Rt_Acct_Team_Contact__c != null ? cs.Adv_Rt_Acct_Team_Contact__c : '';
                String accTeamObj = cs.Adv_Rt_Acct_Team_Object__c != null ? cs.Adv_Rt_Acct_Team_Object__c : '';
                String routingPicklist = cs.Adv_Rt_Acct_Team_Routeby__c != null ? cs.Adv_Rt_Acct_Team_Routeby__c : '';
                String routingPicklistLabel = '';
                String roleField = cs.Adv_Rt_Acct_Team_Role_Picklist__c != null ? cs.Adv_Rt_Acct_Team_Role_Picklist__c : '';
                String rolesToInclude = cs.Adv_Rt_Acct_Team_Roles_to_Include__c != null ? cs.Adv_Rt_Acct_Team_Roles_to_Include__c : '';
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
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts.values()) {
                    selectedAccountIds.add(rraw.rbi.Account__c);
                }
                String accTeamQuery = 'SELECT Id, ';
                
                if (accTeamObj != '' && routingPicklist != '' && userField != '' && accountIdField != '') {
                    //// query contact field instead of user field if contact field not null
                    
                    if (contactField != null && contactField != '') {
                        accTeamQuery += contactField + ', ' + accountIdField;
                        
                        if (roleField != null && roleField != '' && roleField != routingPicklist) { 
                            accTeamQuery += ', ' + roleField;
                        }
                        accTeamQuery += ' FROM ' + accTeamObj 
                                    + ' WHERE ' + accountIdField + ' IN :selectedAccountIds';
                        routingPicklistLabel = CRUDAndFLSCheckController.sObjectsMap.get('Contact').getDescribe().fields.getMap().get(routingPicklist).getDescribe().getLabel();
                    } else {
                        accTeamQuery += routingPicklist + ', ' + userField + ', ' + accountIdField;
                        
                        if (roleField != null && roleField != '' && roleField != routingPicklist) { 
                            accTeamQuery += ', ' + roleField;
                        }
                        accTeamQuery += ' FROM ' + accTeamObj
                                    + ' WHERE ' + accountIdField + ' IN :selectedAccountIds';
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
                //added for #413 - getting the data for territories
                Map<String, String> territoryParentMap = new Map<String, String>();
                Map<String, List<String>> accTerritoryMap = new Map<String, List<String>>();
                Map<String, List<String>> territoryUserMap = new Map<String, List<String>>();
                Map<String, sObject> territoryMap;
                
                if (CRUDAndFLSCheckController.sObjectsMap.containsKey('territory2')) {          // for territory mgmt 2.0
                    String territoryQuery = 'SELECT ParentTerritory2Id, Name, Id, ' +
                                                '(SELECT ObjectId FROM ObjectTerritory2Associations ' +
                                                        'WHERE ObjectId IN :selectedAccountIds), ' +
                                                '(SELECT UserId FROM UserTerritory2Associations) ' +
                                                'FROM Territory2 LIMIT ' +
                                                limits.getLimitQueryRows();
                    territoryMap = new Map<String, sObject>();
                    
                    for (sObject obj : WithoutSharingHelperController.getTerritory2List(territoryQuery, selectedAccountIds)) {
                        territoryMap.put((String)obj.get('Id'), obj);
                    }
                    
                    for (String territoryId : territoryMap.keySet()) {
                        
                        if (!territoryParentMap.containsKey(territoryId)) {
                            territoryParentMap.put(territoryId, getRootTerritory(territoryId, territoryMap, false));
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
                            territoryParentMap.put(territoryId, getRootTerritory(territoryId, territoryMap, true));
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
                Boolean isAnyAttributeSpecified = false;
                
                for (String filterId : filterWrapperMap.keySet()) {
                    
                    if (filterWrapperMap.get(filterId).selectedAttIds != null && filterWrapperMap.get(filterId).selectedAttIds.size() > 0) {
                        isAnyAttributeSpecified = true;
                        
                        for (String attId : filterWrapperMap.get(filterId).selectedAttIds) {
                            tempAttIds.add(attId);
                        }
                    }
                }
                Map<String, Attribute__c> selectedAttributesMap
                        = new Map<String, Attribute__c>([SELECT Id, Name, Level__c, ParentIds__c,
                                                            Root_Parent__c, Parent__c
                                                            FROM Attribute__c
                                                            WHERE Id IN :tempAttIds]);
                
                // map for showing selected attributes data in the chatter post and email
                Map<String, Map<String, String>> attMapForChatter = new Map<String, Map<String, String>>();
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts.values()) {
                    
                    if (!rraw.isManaged && cs.Adv_Request_Routing__c && !isAllReqManaged && rraw.accountName != ConstantsController.UNSPECIFIED && !isBasic) {
                        
                        if (isAnyAttributeSpecified) {
                            
                            for (String filterId : filterWrapperMap.keySet()) {
                                
                                if (filterWrapperMap.get(filterId) != null && filterWrapperMap.get(filterId).selectedAttIds.size() > 0) {
                                    
                                    for (String attId : filterWrapperMap.get(filterId).selectedAttIds) {
                                        Attribute__c tempAttr = new Attribute__c();
                                        
                                        if (selectedAttributesMap != null && selectedAttributesMap.containsKey(attId)) {
                                            tempAttr = selectedAttributesMap.get(attId);
                                        }

                                        if (!attMapForChatter.containsKey(rraw.rbi.Account__c)) {
                                            attMapForChatter.put(rraw.rbi.Account__c, new Map<String, String>());
                                        }
                                        
                                        if (!attMapForChatter.get(rraw.rbi.Account__c).containsKey(filterWrapperMap.get(filterId).labelName)) {
                                            attMapForChatter.get(rraw.rbi.Account__c).put(filterWrapperMap.get(filterId).labelName, '');
                                        }
                                        String oldAttributesValue = attMapForChatter.get(rraw.rbi.Account__c).get(filterWrapperMap.get(filterId).labelName);
                                        attMapForChatter.get(rraw.rbi.Account__c).put(filterWrapperMap.get(filterId).labelName,
                                                oldAttributesValue == '' ? tempAttr.Name : oldAttributesValue + ', ' + tempAttr.Name);
                                        
                                        if (mappedAttributesMap != null && mappedAttributesMap.containsKey(attId)) {
                                            
                                            if (accTeamMap != null && accTeamMap.containsKey(rraw.rbi.Account__c) && accTeamMap.get(rraw.rbi.Account__c) != null && accTeamMap.get(rraw.rbi.Account__c).size() > 0) {
                                                Boolean matchFoundInAccount = false;
                                                
                                                for (sObject obj : accTeamMap.get(rraw.rbi.Account__c)) {

                                                    if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(mappedAttributesMap.get(attId).Adv_Routing_Client_Value__c)) {
                                                        matchFoundInAccount = true;
                                                        Reference_Request_Account__c rrAcc;
                                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (String)obj.get(userField), Project_Owner__c = (String)obj.get(userField));
                                                        rraw.isRequestCreatedForAccount = true;
                                                        
                                                        // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                        if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                            rrAcc.Managed_Request__c = true;
                                                            rrAcc.Reference_Owner__c = null;
                                                            rrAcc.Project_Owner__c = null;
                                                        }
                                                        insertRefReqAcc.add(rrAcc);
                                                        mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                        mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                        String tempAttributesValue = attMapForChatter.get(rraw.rbi.Account__c).get(filterWrapperMap.get(filterId).labelName);
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
                                                        attMapForChatter.get(rraw.rbi.Account__c).put(filterWrapperMap.get(filterId).labelName, tempAttributesValue);
                                                    }
                                                }
                                                
                                                if (!matchFoundInAccount) {
                                                    Reference_Request_Account__c rrAcc;
                                                    
                                                    if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                    } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID), Project_Owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)));
                                                    }
                                                    rraw.isRequestCreatedForAccount = true;
                                                    
                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                    mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                }
                                            } else {
                                                Reference_Request_Account__c rrAcc;
                                                
                                                if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID), Project_Owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)));
                                                }
                                                rraw.isRequestCreatedForAccount = true;
                                                
                                                // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                    rrAcc.Managed_Request__c = true;
                                                    rrAcc.Reference_Owner__c = null;
                                                    rrAcc.Project_Owner__c = null;
                                                }
                                                insertRefReqAcc.add(rrAcc);
                                                mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                            }
                                        } else {
                                            
                                            if (selectedAttributesMap != null && selectedAttributesMap.containsKey(attId) && selectedAttributesMap.get(attId).ParentIds__c != null && selectedAttributesMap.get(attId).ParentIds__c != '') {
                                                Boolean parentFoundInMappingTable = false;
                                                
                                                for (String parentId : selectedAttributesMap.get(attId).ParentIds__c.split(',')) {
                                                    
                                                    if (mappedAttributesMap.containsKey(parentId)) {
                                                        parentFoundInMappingTable = true;
                                                        
                                                        if (accTeamMap != null && accTeamMap.containsKey(rraw.rbi.Account__c) && accTeamMap.get(rraw.rbi.Account__c) != null && accTeamMap.get(rraw.rbi.Account__c).size() > 0) {
                                                            Boolean matchFoundInAccount = false;
                                                            
                                                            for (sObject obj : accTeamMap.get(rraw.rbi.Account__c)) {

                                                                if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(mappedAttributesMap.get(parentId).Adv_Routing_Client_Value__c)) {
                                                                    matchFoundInAccount = true;
                                                                    Reference_Request_Account__c rrAcc;
                                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (String)obj.get(userField), Project_Owner__c = (String)obj.get(userField));
                                                                    rraw.isRequestCreatedForAccount = true;
                                                                    
                                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                                        rrAcc.Managed_Request__c = true;
                                                                        rrAcc.Reference_Owner__c = null;
                                                                        rrAcc.Project_Owner__c = null;
                                                                    }
                                                                    insertRefReqAcc.add(rrAcc);
                                                                    mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                                    mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                                    String tempAttributesValue = attMapForChatter.get(rraw.rbi.Account__c).get(filterWrapperMap.get(filterId).labelName);
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
                                                                    attMapForChatter.get(rraw.rbi.Account__c).put(filterWrapperMap.get(filterId).labelName, tempAttributesValue);
                                                                }
                                                            }
                                                            
                                                            if (!matchFoundInAccount) {
                                                                Reference_Request_Account__c rrAcc;
                                                                
                                                                if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                                } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID), Project_Owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)));
                                                                }
                                                                rraw.isRequestCreatedForAccount = true;
                                                                
                                                                // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                                if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                                    rrAcc.Managed_Request__c = true;
                                                                    rrAcc.Reference_Owner__c = null;
                                                                    rrAcc.Project_Owner__c = null;
                                                                }
                                                                insertRefReqAcc.add(rrAcc);
                                                                mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                                mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                            }
                                                        } else {
                                                            Reference_Request_Account__c rrAcc;
                                                            
                                                            if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                                                rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.MANAGED, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                                            } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                                                rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = tempAttr != null ? (tempAttr.Root_Parent__c + ': ' + tempAttr.Name) : '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID), Project_Owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)));
                                                            }
                                                            rraw.isRequestCreatedForAccount = true;
                                                            
                                                            // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                            if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                                rrAcc.Managed_Request__c = true;
                                                                rrAcc.Reference_Owner__c = null;
                                                                rrAcc.Project_Owner__c = null;
                                                            }
                                                            insertRefReqAcc.add(rrAcc);
                                                            mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                            mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            if (!rraw.isRequestCreatedForAccount) {
                                Boolean isMatchFound = false;
                                
                                if (accTerritoryMap != null && accTerritoryMap.containsKey(rraw.rbi.Account__r.Id) && accTerritoryMap.get(rraw.rbi.Account__r.Id).size() > 0) {
                                    
                                    if (selectedRoutingGroups != null && selectedRoutingGroups.size() > 0) {
                                        
                                        for (String territoryId : accTerritoryMap.get(rraw.rbi.Account__r.Id)) {
                                            
                                            if (mappedTerritoriesMap != null && ((mappedTerritoriesMap.containsKey(territoryId) && selectedRoutingGroups.contains(mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c)) || (mappedTerritoriesMap.containsKey(territoryParentMap.get(territoryId)) && selectedRoutingGroups.contains(mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c)))) {
                                                String assignedUserId = '';
                                                
                                                if (territoryUserMap != null && territoryUserMap.containsKey(territoryId) && territoryUserMap.get(territoryId).size() > 0) {
                                                    isMatchFound = true;
                                                    assignedUserId = territoryUserMap.get(territoryId)[0];
                                                    Reference_Request_Account__c rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = territoryMap.get(territoryId).get('Name') + ': ' + (mappedTerritoriesMap.containsKey(territoryId) ? mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c : mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = assignedUserId != '' ? assignedUserId : (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)), Project_Owner__c = assignedUserId != '' ? assignedUserId : (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)));
                                                    rraw.isRequestCreatedForAccount = true;
                                                    
                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed   
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }               
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                    mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                if (!isMatchFound && accTeamMap != null && accTeamMap.containsKey(rraw.rbi.Account__c)
                                        && accTeamMap.get(rraw.rbi.Account__c) != null && accTeamMap.get(rraw.rbi.Account__c).size() > 0) {

                                    if (selectedRoutingGroups != null && selectedRoutingGroups.size() > 0) {

                                        for (String selectedGrpName : selectedRoutingGroups) {

                                            for (sObject obj : accTeamMap.get(rraw.rbi.Account__c)) {

                                                if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(selectedGrpName.trim())) {
                                                    isMatchFound = true;
                                                    Reference_Request_Account__c rrAcc;
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = routingPicklistLabel + ': ' + selectedGrpName.trim(), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (String)obj.get(userField), Project_Owner__c = (String)obj.get(userField));
                                                    rraw.isRequestCreatedForAccount = true;

                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                    mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                if (!isMatchFound) {
                                    Reference_Request_Account__c rrAcc;
                                    
                                    if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                    } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID), Project_Owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID));
                                    }
                                    rraw.isRequestCreatedForAccount = true;
                                    
                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                        rrAcc.Managed_Request__c = true;
                                        rrAcc.Reference_Owner__c = null;
                                        rrAcc.Project_Owner__c = null;
                                    }
                                    insertRefReqAcc.add(rrAcc);
                                    mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                    mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                }
                            }
                        } else {
                            Boolean isMatchFound = false;
                            
                            if (accTerritoryMap != null && accTerritoryMap.containsKey(rraw.rbi.Account__r.Id) && accTerritoryMap.get(rraw.rbi.Account__r.Id).size() > 0) {
                                
                                if (selectedRoutingGroups != null && selectedRoutingGroups.size() > 0) {
                                    
                                    for (String territoryId : accTerritoryMap.get(rraw.rbi.Account__r.Id)) {
                                        
                                        if (mappedTerritoriesMap != null && ((mappedTerritoriesMap.containsKey(territoryId) && selectedRoutingGroups.contains(mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c)) || (mappedTerritoriesMap.containsKey(territoryParentMap.get(territoryId)) && selectedRoutingGroups.contains(mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c)))) {
                                            String assignedUserId = '';
                                            
                                            if (territoryUserMap != null && territoryUserMap.containsKey(territoryId) && territoryUserMap.get(territoryId).size() > 0) {
                                                isMatchFound = true;
                                                assignedUserId = territoryUserMap.get(territoryId)[0];
                                                Reference_Request_Account__c rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = territoryMap.get(territoryId).get('Name') + ': ' + (mappedTerritoriesMap.containsKey(territoryId) ? mappedTerritoriesMap.get(territoryId).Adv_Routing_Client_Value__c : mappedTerritoriesMap.get(territoryParentMap.get(territoryId)).Adv_Routing_Client_Value__c), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = assignedUserId != '' ? assignedUserId : (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)), Project_Owner__c = assignedUserId != '' ? assignedUserId : (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID)));
                                                rraw.isRequestCreatedForAccount = true;
                                                
                                                // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                    rrAcc.Managed_Request__c = true;
                                                    rrAcc.Reference_Owner__c = null;
                                                    rrAcc.Project_Owner__c = null;
                                                }
                                                insertRefReqAcc.add(rrAcc);
                                                mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                            }
                                        }
                                    }
                                }
                            }

                            if (!isMatchFound) {

                                if (accTeamMap != null && accTeamMap.containsKey(rraw.rbi.Account__c) && accTeamMap.get(rraw.rbi.Account__c) != null && accTeamMap.get(rraw.rbi.Account__c).size() > 0) {

                                    if (selectedRoutingGroups != null && selectedRoutingGroups.size() > 0) {

                                        for (String selectedGrpName : selectedRoutingGroups) {

                                            for (sObject obj : accTeamMap.get(rraw.rbi.Account__c)) {

                                                if ((String)obj.get(routingPicklist) != null && ((String)obj.get(routingPicklist)).contains(selectedGrpName.trim())) {
                                                    isMatchFound = true;
                                                    Reference_Request_Account__c rrAcc;
                                                    rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = routingPicklistLabel + ': ' + selectedGrpName.trim(), Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = (String)obj.get(userField), Project_Owner__c = (String)obj.get(userField));
                                                    rraw.isRequestCreatedForAccount = true;

                                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                                        rrAcc.Managed_Request__c = true;
                                                        rrAcc.Reference_Owner__c = null;
                                                        rrAcc.Project_Owner__c = null;
                                                    }
                                                    insertRefReqAcc.add(rrAcc);
                                                    mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                                    mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }

                                if (!isMatchFound) {
                                    Reference_Request_Account__c rrAcc;
                                    
                                    if (cs.Adv_Routing_Default__c == 'Send to CRP Team') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = true, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.NOT_STARTED, Reference_owner__c = null, Project_Owner__c = null);
                                    } else if (cs.Adv_Routing_Default__c == 'Send to Owner') {
                                        rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline, Adv_Routing_Criteria__c = '', Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType, Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes, Managed_Request__c = false, Process__c = ConstantsController.REP2REP, Account_Request_Status__c = ConstantsController.IN_PROGRESS, Reference_owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID), Project_Owner__c = rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c ? null : rraw.rbi.Account__r.OwnerID));
                                    }
                                    rraw.isRequestCreatedForAccount = true;
                                    
                                    // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                                    if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true) {    
                                        rrAcc.Managed_Request__c = true;
                                        rrAcc.Reference_Owner__c = null;
                                        rrAcc.Project_Owner__c = null;
                                    }
                                    insertRefReqAcc.add(rrAcc);
                                    mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                                    mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                                }
                            }
                        }
                    } else {
                        
                        if (rraw.accountName != system.label.No_Account_Specified) {
                            Reference_Request_Account__c rrAcc = new Reference_Request_Account__c(Account__c = rraw.rbi.Account__r.Id, Deadline__c = rraw.deadline,
                                Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType,
                                Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes,
                                Managed_Request__c = (rraw.rbi.Managed_Reference_Account__c != null && !isBasic ? rraw.rbi.Managed_Reference_Account__c : false),
                                Process__c = (rraw.rbi.Managed_Reference_Account__c != null && !isBasic ? (rraw.rbi.Managed_Reference_Account__c ? ConstantsController.MANAGED : ConstantsController.REP2REP) : ConstantsController.REP2REP),
                                Account_Request_Status__c = (rraw.rbi.Managed_Reference_Account__c && !isBasic ? ConstantsController.NOT_STARTED : ConstantsController.IN_PROGRESS),
                                Reference_owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c && !isBasic ? null : rraw.rbi.Account__r.OwnerID)),
                                Project_Owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : (rraw.rbi.Managed_Reference_Account__c && !isBasic ? null : rraw.rbi.Account__r.OwnerID)));
                            
                            if (isAllReqManaged && rrAcc.process__c == ConstantsController.REP2REP && !isBasic) {
                                rrAcc.Process__c = ConstantsController.MANAGED;
                                rrAcc.Managed_Request__c = true; 
                                rrAcc.Account_Request_Status__c = ConstantsController.NOT_STARTED;
                                rrAcc.Reference_owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : null);
                                rrAcc.Project_Owner__c = (rraw.rbi.Reference_Owner__c != null ? rraw.rbi.Reference_Owner__c : null);
                                convertedRRAs.add(rrAcc.Account__c);
                            }

                            if (!rraw.rbi.Managed_Reference_Account__c) {
                                isRepToRep = true; 
                            }
                            rraw.isRequestCreatedForAccount = true;
                            
                            // re #564 Check Managed flag for Reference Type to make Request Type Always Managed
                            if (rrAcc.Reference_Type_Needed__c != null && Boolean.valueOf(listOfReferenceabilities.get(rrAcc.Reference_Type_Needed__c).isManaged) == true && !isBasic) {    
                                rrAcc.Managed_Request__c = true;
                                rrAcc.Reference_Owner__c = null;
                                rrAcc.Project_Owner__c = null;
                            }
                            insertRefReqAcc.add(rrAcc);
                            mapAccountOwnerId.put(rraw.rbi.Account__r.Id, rraw.rbi.Account__r.OwnerId);
                            //changes related to #713
                            rraw.rbi.Account__r.Name = rraw.accountName;
                            mapAccount.put(rraw.rbi.Account__r.Id, rraw.rbi);
                        }
                        
                        if (rraw.AccountName == system.label.No_Account_Specified && !isBasic) {
                            Unspecified_Request__c unRequest = new Unspecified_Request__c(Deadline__c = rraw.deadline, Unspecified_Request_Status__c = ConstantsController.NOT_STARTED,
                                                                    Reference_Request__c = referenceRequest.Id, Reference_Type_Needed__c = rraw.referenceType,
                                                                    Requester__c = UserInfo.getUserId(), Request_Notes__c = rraw.notes);
                            insertUnspecifiedReq.add(unRequest);
                        }
                    }
                }
                Map<String, Reference_Request_Additional_Info__c> copyadditionalFieldsInfo = new Map<String, Reference_Request_Additional_Info__c>();
                
                if (!isBasic) {
                    
                    for (String refId : fieldWrapperMap.keySet()) {
                        
                        if (refFieldSet.contains(refId)) {
                            copyadditionalFieldsInfo.put(refId, fieldWrapperMap.get(refId).addInfo);
                        }
                    }
                    
                    if (copyadditionalFieldsInfo.size() > 0) {
                        insert copyadditionalFieldsInfo.values();
                        
                        for (Unspecified_Request__c unRequest : insertUnspecifiedReq) {
                            
                            if (copyadditionalFieldsInfo.containsKey(unRequest.Reference_Type_Needed__c))
                                unRequest.Reference_Request_Additional_Info__c = copyadditionalFieldsInfo.get(unRequest.Reference_Type_Needed__c).Id;
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
                    
                    for (String accName : ConstantsController.failedRRAAccountNames) {
                        
                        if (accNames == '') {
                            accNames = accName;
                        } else {
                            accNames = accNames + ', ' + accName;
                        }
                    }
                    
                    inactiveUserInfoMsg = 'The Account ' + accNames
                                            + ' does not have an active Owner. '
                                            + 'This request has been submitted and re-routed to the Customer Reference Team.';
                }
                
                // resetting the set containing failed RRA acount names
                ConstantsController.failedRRAAccountNames = new Set<String>();
                
                if (insertUnspecifiedReq.size() > 0 && !isBasic) {
                    insert insertUnspecifiedReq;
                }
                List<Reference_Request_Label__c> newRefReqLabel = new List<Reference_Request_Label__c>();
                List<Reference_Request_Label_Attribute__c> newRefReqAttr = new List<Reference_Request_Label_Attribute__c>();
                
                if (!isBasic) {
                    
                    for (String labelId : filterWrapperMap.keyset()) {
                        
                        if (filterWrapperMap.get(labelId).visible) {
                            newRefReqLabel.add(new Reference_Request_Label__c(Label__c = labelId, Reference_Request__c = referenceRequest.Id));
                        }
                    }
                    
                    if (newRefReqLabel.size() > 0) {
                        insert newRefReqLabel;
                    }
                    
                    for (Reference_Request_Label__c refObj : [SELECT Label__c, Id FROM Reference_Request_Label__c
                                                                WHERE Reference_Request__c = :referenceRequest.Id]) {
                        
                        if (filterWrapperMap.containsKey(refObj.Label__c)) { 
                            
                            for (String attId : filterWrapperMap.get(refObj.Label__c).selectedAttIds) {
                                newRefReqAttr.add(new Reference_Request_Label_Attribute__c(Attribute__c = attId, Reference_Request_Label__c = refObj.Id));
                            }
                        }
                    }
                    
                    if (newRefReqAttr.size() > 0) {
                        insert newRefReqAttr;
                    }
                }
                Map<Id, Referenceability_Type__c> mapReferenceType = new Map<Id, Referenceability_Type__c>();
                
                for (RefTypeWrapper rtw : listOfReferenceabilities.values()) {
                    mapReferenceType.put(rtw.ref.Id, rtw.ref);
                }
                
                if (isBasic) {
                    prepareChatterEmailTaskItem1(insertRefReqAcc, mapAccount, mapReferenceType, mapAccountOwnerId);
                } else {
                    prepareChatterEmailTaskItem(insertRefReqAcc, insertUnspecifiedReq, convertedRRAs, mapAccount, referenceRequest.Id, mapReferenceType, mapAccountOwnerId, attMapForChatter);
                }
                
                if (insertRefReqAcc.size() > 0 || insertUnspecifiedReq.size() > 0) {
                    List<String> lstUserAction = new List<String>();
                    lstUserAction.add(ConstantsController.REQUEST_SALES);
                    List<Referenceability_Type__c> refTypes = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);  
                     
                    // re #583 - Null check for User reward points.  
                    if (refTypes.size() > 0 && refTypes[0].Sales_Point__c != null && RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {
                        List<Reward__c> rewardsToBeInsert = new List<Reward__c>(); 
                        rewardsToBeInsert.add(new Reward__c(Amount__c = refTypes[0].Sales_Point__c, Referenceability_Type__c = refTypes[0].Id, Transaction__c = ConstantsController.ISSUE, 
                                                             RewardDate__c = Date.Today(), User__c = UserInfo.getUserId()));
                        UtilityController.isUserProfileExist(UserInfo.getUserId());
                        
                        if (rewardsToBeInsert.size() > 0) {  
                            WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
                        }
                        
                        // re #591 NEW field Onscreen Notification__c allow for on/off for onscreen notification.
                        // changes for #603 - Gaurav Saini (30 Dec, 2016)
                        // sending the info message for inactive owner for RRA
                        if (cs.User_Reward_Onscreen_Notification__c) {
                            return 'success:' + refTypes[0].Sales_Point__c + ':' + inactiveUserInfoMsg + ':' + refRequestId;
                        } else {                    
                            return 'success:' + ':' + inactiveUserInfoMsg + ':' + refRequestId;
                        }
                    }
                }
            } catch (DMLException e) {
                Database.rollback(sp);
                system.debug('Exception --------' + e.getDmlMessage(0));
                return e.getDmlMessage(0);
            } catch (EmailException e) {
                Database.rollback(sp);
                system.debug('Exception --------' + e.getDmlMessage(0));
                return e.getDmlMessage(0);
            } catch(Exception e) {
                Database.rollback(sp);
                system.debug('Exception --------' + e.getMessage() + '         ' + e.getLineNumber() + ' Type : </b>' + e.getTypeName());
                return e.getMessage();
            }
            return 'success:' + ':' + inactiveUserInfoMsg + ':' + refRequestId;
        } else {
            return  CRUDAndFLSCheckController.getErrorMsg(); // re #785
        }
    }
    
    /**
     * method to get the root parent of a territory using the territory Id
     */
    public static String getRootTerritory(String territoryId, Map<String, sObject> territoryMap, Boolean isTM1) {
        
        if (isTM1) {
            
            if (territoryMap != null
                    && territoryMap.containsKey(territoryId)
                    && territoryMap.get(territoryId).get('ParentTerritoryId') == null) {
                return (String)territoryMap.get(territoryId).get('Id');
            }
            return getRootTerritory((String)territoryMap.get(territoryId).get('ParentTerritoryId'), territoryMap, isTM1);
        } else {
            
            if (territoryMap != null
                    && territoryMap.containsKey(territoryId)
                    && territoryMap.get(territoryId).get('ParentTerritory2Id') == null) {
                return (String)territoryMap.get(territoryId).get('Id');
            }
            return getRootTerritory((String)territoryMap.get(territoryId).get('ParentTerritory2Id'), territoryMap, isTM1);
        }
    }
    
    private static void prepareChatterEmailTaskItem1(List<Reference_Request_Account__c> insertRefReqAccounts,
                            Map<Id, Reference_Basic_Information__c> mapAccount,
                            Map<Id, Referenceability_Type__c> mapReferenceType,
                            Map<String, String> mapAccountOwnerId) {
        
        Map<String, sObject> tempFeedItemRRAMap = new Map<String, sObject>();
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        List<sObject> postFeedItems = new List<sObject>();
        feedItemRRAMap = new Map<String, Set<sObject>>();
        List<Task> listTask = new List<Task>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean checkChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Peer2Peer_Chatter__c);
        Boolean checkEmailSetting = cs.Request_Peer2Peer_Email__c;
        Boolean checkSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_Peer2Peer_Slack__c;

        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();
        Map<Id, String> userEmailMap = new Map<Id, String>();

        for (Reference_Request_Account__c rra : insertRefReqAccounts) {
            userEmailMap.put(rra.Reference_Owner__c, '');
        }

        for (User u : WithoutSharingHelperController.getUserMap(userEmailMap.keySet()).values()) {

            if (u.IsActive) {
                userEmailMap.put(u.Id, u.Email);
            }
        }

        // changes for #603 - getting the userid from RRA objbect instead of mapAccountOwnerId
        for (Reference_Request_Account__c rra : insertRefReqAccounts) {
            
            // Prepare FeedItem List
            if (checkChatterSetting) {
                tempFeedItemRRAMap.put(rra.Id + '-' + rra.Reference_Owner__c, MailChatterController.preparePost(APPROVE_DECLINE_TITLE,
                                        //mapAccountOwnerId.get(rra.Account__c),
                                        rra.Reference_Owner__c,
                                        SPECIFIED_REQUEST_MESSAGE
                                            + MailChatterController.prepareChatterEmailMessage(rra.Deadline__c,
                                                        mapAccount.get(rra.Account__c).Account__r.Name,
                                                        mapReferenceType.get(rra.Reference_Type_Needed__c).Name,
                                                        UtilityController.checkValueOfString(rra.Request_Notes__c)),
                                        LINK_URL + rra.Id));
            }
            
            // Prepare Mail List
            if (checkEmailSetting) {
                listmail.add(MailChatterController.prepareEmail(REFERENCE_REQUEST_SUBJECT,
                                        //mapAccountOwnerId.get(rra.Account__c),
                                        rra.Reference_Owner__c,
                                        SPECIFIED_REQUEST_MESSAGE
                                            + MailChatterController.prepareChatterEmailMessage(rra.Deadline__c,
                                                        mapAccount.get(rra.Account__c).Account__r.Name,
                                                        mapReferenceType.get(rra.Reference_Type_Needed__c).Name,
                                                        UtilityController.checkValueOfString(rra.Request_Notes__c))
                                            + APPROVE_DECLINE_TITLE + ': ' + '<a href="' + LINK_URL
                                            + rra.Id + '">' + LINK_URL + rra.Id + '</a>',
                                        false));
            }
            
            // Prepare Mail List
            if (checkSlackSetting) {
                Map<String, String> tempReqBodyMap = new Map<String, String>();
                tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Reference_Owner__c));
                tempReqBodyMap.put('text', SPECIFIED_REQUEST_MESSAGE
                                        + MailChatterController.prepareChatterEmailMessage(rra.Deadline__c,
                                            mapAccount.get(rra.Account__c).Account__r.Name,
                                            mapReferenceType.get(rra.Reference_Type_Needed__c).Name,
                                            UtilityController.checkValueOfString(rra.Request_Notes__c))
                                        + '<' + LINK_URL + rra.Id + '|' + APPROVE_DECLINE_TITLE + '>');
                messagesList.add(tempReqBodyMap);
            }
            
            // Prepare Task List
            listTask.add(MailChatterController.prepareTask(rra.Reference_Owner__c,  //mapAccountOwnerId.get(rra.Account__c),
                                        rra.Account__c, rra.Deadline__c, REFERENCE_REQUEST_TASK_SUBJECT,
                                        SPECIFIED_REQUEST_MESSAGE
                                            + MailChatterController.prepareChatterEmailMessage(rra.Deadline__c,
                                                        mapAccount.get(rra.Account__c).Account__r.Name,
                                                        mapReferenceType.get(rra.Reference_Type_Needed__c).Name,
                                                        UtilityController.checkValueOfString(rra.Request_Notes__c))
                                            + APPROVE_DECLINE_TITLE + ': ' + LINK_URL + rra.Id,
                                        ''));
        }

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
        }
        
        //Insert list of postFeedItems
        if (tempFeedItemRRAMap.size() > 0) {
            tempFeedItemRRAMap = WithoutSharingHelperController.insertPostFeedItemsMap(tempFeedItemRRAMap);
            postFeedItems = new List<sObject>();
            
            for (String ids : tempFeedItemRRAMap.keySet()) {
                
                if (!feedItemRRAMap.containsKey(ids.split('-')[0])) {
                    feedItemRRAMap.put(ids.split('-')[0], new Set<sObject>());
                }
                feedItemRRAMap.get(ids.split('-')[0]).add(tempFeedItemRRAMap.get(ids));
                postFeedItems.add(tempFeedItemRRAMap.get(ids));
            }
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
        updateRefReqAccountsTaskId(insertRefReqAccounts,listTask);
        // call method to update RRA records with appropriate feeditem Ids
        updateRefReqAccountsFeedItemId(insertRefReqAccounts);
    }
    
    /**
     * Method to prepare Chatter, Email & Task data
     */
    private static void prepareChatterEmailTaskItem(List<Reference_Request_Account__c> insertRefReqAcc,
                                                List<Unspecified_Request__c> insertUnspecifiedReq,
                                                Set<String> convertedRRAs,
                                                Map<Id, Reference_Basic_Information__c> mapAccount,
                                                Id refReqId, Map<Id, Referenceability_Type__c> mapReferenceType,
                                                Map<String, String> mapAccountOwnerId,
                                                Map<String, Map<String, String>> attMapForChatter) {
        
        feedItemRRAMap = new Map<String, Set<sObject>>();
        Map<String, sObject> tempFeedItemRRAMap = new Map<String, sObject>();
        List<sObject> postFeedItems = new List<sObject>();
        List<Task> listTask = new List<Task>();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean checkPeer2PeerEmailSetting = cs.Request_Peer2Peer_Email__c;
        Boolean checkPeer2PeerChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Peer2Peer_Chatter__c);
        Boolean checkPeer2PeerSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_Peer2Peer_Slack__c;
        Boolean checkManagedEmailSetting = cs.Request_Managed_Email__c;
        Boolean checkManagedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Request_Managed_Chatter__c);
        Boolean checkManagedSlackSetting = cs.Enable_Slack_Integration__c && cs.Request_Managed_Slack__c;
        Boolean checkConvertedEmailSetting = cs.Large_Opportunity_Email__c;
        Boolean checkConvertedChatterSetting = (UtilityController.isNativeChatterSetting && cs.Large_Opportunity_Chatter__c);
        Boolean checkConvertedSlackSetting = cs.Enable_Slack_Integration__c && cs.Large_Opportunity_Slack__c;
        List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
        String headerDocId = '';
        String footerDocId = '';
        Data_Mapping__c p2pNotification = new Data_Mapping__c();
        Data_Mapping__c managedNotification = new Data_Mapping__c();
        Data_Mapping__c convertedNotification = new Data_Mapping__c();
        Set<String> notificationFieldNames = new Set<String>{UtilityController.appNamespace() + 'Request_Peer2Peer_Email__c', UtilityController.appNamespace() + 'Request_Managed_Email__c', UtilityController.appNamespace() + 'Large_Opportunity_Email__c'};

        Map<String, Object> slackReqBody = new Map<String, Object>();
        slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
        slackReqBody.put('orgId', UserInfo.getOrganizationId());
        List<Map<String, String>> messagesList = new List<Map<String, String>>();
        Map<Id, String> userEmailMap = new Map<Id, String>();

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
        
        //REF-1316- Added check for CRP team member should be active
        List<User> publicGroupMembers = UtilityController.getCustomerReferenceTeam(); 
        //Self Service Request
        for (Reference_Request_Account__c rra : insertRefReqAcc) {
            userEmailMap.put(rra.Reference_Owner__c, '');
            
            if (convertedRRAs.contains(rra.Account__c)) {
                String notificationBody = convertedNotification.DC_Message__c + '\n\n' + convertedNotification.Default__c;
                notificationBody = notificationBody.replace('[Opportunity Threshold Amount]', String.valueOf(cs.Managed_Request_Opportunity_Threshold__c))
                                    .replace('[Requester Name]', rra.Requester__r.Name)
                                    .replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name)
                                    .replace('[Request Type]', mapReferenceType.get(rra.Reference_Type_Needed__c).Name)
                                    .replace('[Deadline]', rra.Deadline__c.format())
                                    .replace('[Request Notes]', UtilityController.checkValueOfString(rra.Request_Notes__c));
                
                if (checkConvertedEmailSetting) {
                    
                    for (User gm : publicGroupMembers) {
                        String userId = gm.Id;
                        
                        if (userId.startsWith('005')) {
                            listmail.add(MailChatterController.prepareEmail(convertedNotification.Section_Name__c,
                                                        userId, notificationBody + '\n\n'
                                                        + convertedNotification.Section_Name__c + ': ' + '<a href="' + REF_PROJECT_LINK
                                                        + refReqId + '">' + REF_PROJECT_LINK + refReqId + '</a>',
                                                        false, headerDocId, footerDocId));
                        }
                    }
                }
                
                if (checkConvertedChatterSetting) {
                    
                    for (User member : publicGroupMembers) {
                        String userId = member.Id;
                        
                        if (userId.startsWith('005')) {
                            
                            // added for #693 - storing the RRA id with the corresponding chatter post
                            tempFeedItemRRAMap.put(rra.Id + '-' + userId, MailChatterController.preparePost(convertedNotification.Section_Name__c,
                                                        userId, notificationBody, REF_PROJECT_LINK + refReqId));
                        }
                    }
                }
                
                if (checkConvertedSlackSetting) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('text', notificationBody
                            + '\n<' + REF_PROJECT_LINK + refReqId + '|'
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
        String slackMsgBody;
        
        for (Reference_Request_Account__c rra : insertRefReqAcc) {
            
            if (!convertedRRAs.contains(rra.Account__c)) {
                
                if (!cs.Adv_Request_Routing__c) {
                    
                    // changes for #603 - checking whether the request is managed and not the account
                    if (!rra.Managed_Request__c) {
                        String notificationBody = p2pNotification.DC_Message__c + '\n\n' + p2pNotification.Default__c;
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
                                                rra.Reference_Owner__c, notificationBody + '\n\n'
                                                    + APPROVE_DECLINE_TITLE + ': ' + '<a href="' + APPROVE_DECLINE_LINK_URL
                                                    + rra.Id + '">' + APPROVE_DECLINE_LINK_URL + rra.Id + '</a>',
                                                false, headerDocId, footerDocId));
                        }
                        
                        if (checkPeer2PeerChatterSetting) {
                            // added for #693 - storing the RRA id with the corresponding chatter post
                            tempFeedItemRRAMap.put(rra.Id + '-' + rra.Reference_Owner__c, MailChatterController.preparePost(APPROVE_DECLINE_TITLE,
                                                        rra.Reference_Owner__c, notificationBody, APPROVE_DECLINE_LINK_URL + rra.Id));
                        }
                        
                        if (checkPeer2PeerSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Reference_Owner__c));
                            tempReqBodyMap.put('text', slackMsgBody
                                    + '\n<' + APPROVE_DECLINE_LINK_URL + rra.Id + '|'
                                    + APPROVE_DECLINE_TITLE + '>');
                            messagesList.add(tempReqBodyMap);
                        }
                        listTask.add(MailChatterController.prepareTask(rra.Reference_Owner__c, rra.Account__c, rra.Deadline__c,
                                                                        REFERENCE_REQUEST_TASK_SUBJECT,
                                                                        notificationBody + '\n\n'
                                                                            + APPROVE_DECLINE_TITLE + ': '
                                                                            + (mapAccount.get(rra.Account__c).Managed_Reference_Account__c
                                                                                    ? REF_PROJECT_LINK + refReqId
                                                                                    : APPROVE_DECLINE_LINK_URL + rra.Id),
                                                                        ''));
                    }
                } else {

                    if (!rra.Managed_Request__c) {
                        String notificationBody = p2pNotification.DC_Message__c + '\n\n' + p2pNotification.Default__c;
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
                            listmail.add(MailChatterController.prepareEmail(p2pNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                rra.Reference_Owner__c,
                                                MailChatterController.prepareChatterEmailMessageForAdvanceRouting(notificationBody,
                                                        attMapForChatter.containsKey(rra.Account__c) ? attMapForChatter.get(rra.Account__c) : new Map<String, String>())
                                                    + '\n\n' + APPROVE_DECLINE_TITLE + ': ' + '<a href="' + APPROVE_DECLINE_LINK_URL
                                                    + rra.Id + '">' + APPROVE_DECLINE_LINK_URL + rra.Id + '</a>',
                                                false, headerDocId, footerDocId));
                        }
                        
                        if (checkPeer2PeerChatterSetting) {
                            
                            // added for #693 - storing the RRA id with the corresponding chatter post
                            tempFeedItemRRAMap.put(rra.Id + '-' + rra.Reference_Owner__c, MailChatterController.preparePost(APPROVE_DECLINE_TITLE,
                                                        rra.Reference_Owner__c,
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
                        listTask.add(MailChatterController.prepareTask(rra.Reference_Owner__c, rra.Account__c, rra.Deadline__c,
                                                                        REFERENCE_REQUEST_TASK_SUBJECT,
                                                                        MailChatterController.prepareChatterEmailMessageForAdvanceRouting(notificationBody,
                                                                                attMapForChatter.containsKey(rra.Account__c) ? attMapForChatter.get(rra.Account__c) : new Map<String, String>())
                                                                            + '\n\n' + APPROVE_DECLINE_TITLE + ': '
                                                                            + (mapAccount.get(rra.Account__c).Managed_Reference_Account__c
                                                                                    ? REF_PROJECT_LINK + refReqId
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
                    
                    // changes for #603 - checking whether the request is managed and not the account
                    //if (mapAccount.get(rra.Account__c).Managed_Reference_Account__c) {
                    if (rra.Managed_Request__c) {
                        String notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
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
                            
                            // changes for #603 - null check applied for rra ref owner and not account ref owner
                            //if (mapAccount.get(rra.Account__c).Reference_Owner__c != null) {
                            if (rra.Reference_Owner__c != null) {
                                listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                    // changes for #603 - setting the ref owner from request record as the recipient for the notification
                                                    //mapAccount.get(rra.Account__c).Reference_Owner__c,
                                                    rra.Reference_Owner__c, notificationBody + '\n\n'
                                                        + PROJECT_TITLE + ': ' + '<a href="' + REF_PROJECT_LINK
                                                        + refReqId + '">' + REF_PROJECT_LINK + refReqId + '</a>',
                                                    false, headerDocId, footerDocId));
                            } else {
                                
                                for (User gm : publicGroupMembers) {
                                    String userId = gm.Id;
                                    
                                    if (userId.startsWith('005')) {
                                        listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                                    userId, notificationBody + '\n\n'
                                                                        + PROJECT_TITLE + ': ' + '<a href="' + REF_PROJECT_LINK
                                                                        + refReqId + '">' + REF_PROJECT_LINK + refReqId + '</a>',
                                                                    false, headerDocId, footerDocId));
                                    }
                                }
                            }
                        }

                        if (checkManagedSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();
                            tempReqBodyMap.put('text', slackMsgBody
                                    + '\n<' + REF_PROJECT_LINK + refReqId + '|'
                                    + managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name) + '>');

                            if (rra.Reference_Owner__c != null) {
                                tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Reference_Owner__c));
                            }
                            messagesList.add(tempReqBodyMap);
                        }
                    }
                }
            }
            
            // for the unspecified requests
            if (checkManagedEmailSetting) {
                
                for (Unspecified_Request__c ur : insertUnspecifiedReq) {
                    String notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
                    notificationBody = notificationBody.replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                        .replace('[Request Type]', mapReferenceType.get(ur.Reference_Type_Needed__c).Name)
                                        .replace('[Deadline]', ur.Deadline__c.format())
                                        .replace('Request From: [User Name]\n', '')
                                        .replace('[Request Notes]', UtilityController.checkValueOfString(ur.Request_Notes__c));
                    
                    for (User member : publicGroupMembers) {
                        String userId = member.Id;
                        
                        if (userId.startsWith('005')) {
                            listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED),
                                                    userId, notificationBody + '\n\n'
                                                        + PROJECT_TITLE + ': ' + '<a href="' + REF_PROJECT_LINK
                                                        + refReqId + '">' + REF_PROJECT_LINK + refReqId + '</a>',
                                                    false, headerDocId, footerDocId));
                        }
                    }
                }
            }

            if (checkManagedSlackSetting) {

                for (Unspecified_Request__c ur : insertUnspecifiedReq) {
                    String notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
                    notificationBody = notificationBody.replace('[Requested Account]', ConstantsController.UNSPECIFIED)
                                        .replace('[Request Type]', mapReferenceType.get(ur.Reference_Type_Needed__c).Name)
                                        .replace('[Deadline]', ur.Deadline__c.format())
                                        .replace('[User Name]', UserInfo.getName())
                                        .replace('[Request Notes]', UtilityController.checkValueOfString(ur.Request_Notes__c));
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('text', notificationBody
                            + '\n<' + REF_PROJECT_LINK + refReqId + '|'
                            + managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED) + '>');
                    messagesList.add(tempReqBodyMap);
                }
            }
        } else if (checkManagedChatterSetting) {
            
            // for the specified managed requests
            for (Reference_Request_Account__c rra : insertRefReqAcc) {
                
                if (!convertedRRAs.contains(rra.Account__c)) {
                    
                    // changes for #603 - checking whether the request is managed and not the account
                    //if (mapAccount.get(rra.Account__c).Managed_Reference_Account__c) {
                    if (rra.Managed_Request__c) {
                        String notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
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
                        
                        //Prepare Emails
                        if (checkManagedEmailSetting) {
                            
                            // changes for #603 - null check applied for rra ref owner and not account ref owner
                            //if (mapAccount.get(rra.Account__c).Reference_Owner__c != null) {
                            if (rra.Reference_Owner__c != null) {
                                listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                        // changes for #603 - setting the ref owner from request record as the recipient for the notification
                                                        //mapAccount.get(rra.Account__c).Reference_Owner__c,
                                                        rra.Reference_Owner__c, notificationBody + '\n\n'
                                                            + PROJECT_TITLE + ': ' + '<a href="' + REF_PROJECT_LINK
                                                            + refReqId + '">' + REF_PROJECT_LINK + refReqId + '</a>',
                                                        false, headerDocId, footerDocId));
                            } else {
                                
                                for (User gm : publicGroupMembers) {
                                    String userId = gm.Id;
                                    
                                    if (userId.startsWith('005')) {
                                        listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                                userId, notificationBody + '\n\n'
                                                                    + PROJECT_TITLE + ': ' + '<a href="' + REF_PROJECT_LINK
                                                                    + refReqId + '">' + REF_PROJECT_LINK + refReqId + '</a>',
                                                                false, headerDocId, footerDocId));
                                    }
                                }
                            }
                        }

                        if (checkManagedSlackSetting) {
                            Map<String, String> tempReqBodyMap = new Map<String, String>();

                            if (rra.Reference_Owner__c != null) {
                                tempReqBodyMap.put('userEmail', userEmailMap.get(rra.Reference_Owner__c));
                            }
                            tempReqBodyMap.put('text', slackMsgBody
                                    + '\n<' + REF_PROJECT_LINK + refReqId + '|'
                                    + managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name) + '>');
                            messagesList.add(tempReqBodyMap);
                        }
                        
                        //Prepare Chatter
                        if (rra.Reference_Owner__c != null) {
                            
                            // added for #693 - storing the RRA id with the corresponding chatter post
                            tempFeedItemRRAMap.put(rra.Id + '-' + rra.Reference_Owner__c, MailChatterController.preparePost(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                    rra.Reference_Owner__c, notificationBody, REF_PROJECT_LINK + refReqId));
                        } else {
                            
                            for (User member : publicGroupMembers) {
                                String userId = member.Id;
                                
                                if (userId.startsWith('005')) {
                                    
                                    // added for #693 - storing the RRA id with the corresponding chatter post
                                    tempFeedItemRRAMap.put(rra.Id + '-' + userId, MailChatterController.preparePost(managedNotification.Section_Name__c.replace('[Requested Account]', mapAccount.get(rra.Account__c).Account__r.Name),
                                                            userId, notificationBody, REF_PROJECT_LINK + refReqId));
                                }
                            }
                        }
                    }
                }
            }
            
            //for the unspecified requests
            for (Unspecified_Request__c ur : insertUnspecifiedReq) {
                String notificationBody = managedNotification.DC_Message__c + '\n\n' + managedNotification.Default__c;
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
                
                //Prepare Emails
                if (checkManagedEmailSetting) {
                    
                    for (User member : publicGroupMembers) {
                        String userId = member.Id;
                        
                        if (userId.startsWith('005')) {
                            listmail.add(MailChatterController.prepareEmail(managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED),
                                                    userId, notificationBody + '\n\n'
                                                        + PROJECT_TITLE + ': ' + '<a href="' + REF_PROJECT_LINK
                                                        + refReqId + '">' + REF_PROJECT_LINK + refReqId + '</a>',
                                                    false, headerDocId, footerDocId));
                        }
                    }
                }

                if (checkManagedSlackSetting) {
                    Map<String, String> tempReqBodyMap = new Map<String, String>();
                    tempReqBodyMap.put('text', slackMsgBody
                            + '\n<' + REF_PROJECT_LINK + refReqId + '|'
                            + managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED) + '>');
                    messagesList.add(tempReqBodyMap);
                }
                
                //Prepare Chatter
                for (User member : publicGroupMembers) {
                    String userId = member.Id;
                    
                    if (userId.startsWith('005')) {
                        tempFeedItemRRAMap.put(ur.Id + '-' + userId, MailChatterController.preparePost(managedNotification.Section_Name__c.replace('[Requested Account]', ConstantsController.UNSPECIFIED),
                                                    userId, notificationBody, REF_PROJECT_LINK + refReqId));
                    }
                }
            }
        }
        
        //Insert list of postFeedItems
        if (tempFeedItemRRAMap.size() > 0) {
            // changes for #693 - Gaurav Saini (5 Apr, 2017)
            tempFeedItemRRAMap = WithoutSharingHelperController.insertPostFeedItemsMap(tempFeedItemRRAMap);
            postFeedItems = new List<sObject>();
            
            for (String ids : tempFeedItemRRAMap.keySet()) {
                
                if (!feedItemRRAMap.containsKey(ids.split('-')[0])) {
                    feedItemRRAMap.put(ids.split('-')[0], new Set<sObject>());
                }
                feedItemRRAMap.get(ids.split('-')[0]).add(tempFeedItemRRAMap.get(ids));
                postFeedItems.add(tempFeedItemRRAMap.get(ids));
            }
        }
        
        //Send List of emails
        if (listmail.size() > 0) {
            Messaging.sendEmail(listmail);
        }
        
        //Insert list of tasks
        if (listTask.size() > 0) {
            listTask = WithoutSharingHelperController.insertTask(listTask);
        }

        if (messagesList != null && messagesList.size() > 0) {
            slackReqBody.put('messages', messagesList);
            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
        }
        //Call Method update taskId in Reference_Request_Account__c Object
        updateRefReqAccountsTaskId(insertRefReqAcc, listTask);
        // call method to update RRA records with appropriate feeditem Ids
        updateRefReqAccountsFeedItemId(insertRefReqAcc);
    }
    
    /**
     * Description: method to populate the chatter post id field on RRA record with the appropriate FeedItem Id
     * Author: Gaurav Saini (5 Apr, 2017)
     */
    private static void updateRefReqAccountsFeedItemId(List<Reference_Request_Account__c> insertRefReqAcc) {
        List<Reference_Request_Account__c> RRAsToUpdate = new List<Reference_Request_Account__c>();
        
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
        
        // update updateRefReqAccounts;
        if (RRAsToUpdate != null && RRAsToUpdate.size() > 0) {
            RRAsToUpdate = WithoutSharingHelperController.updateRRA(RRAsToUpdate);
        }
    }
    
    /**
     * Method to insert taskId in Reference_Request_Account__c Object
     */
    private static void updateRefReqAccountsTaskId(List<Reference_Request_Account__c> insertRefReqAcc, List<Task> listTask) {
        List<Reference_Request_Account__c> updateRefReqAccounts = new List<Reference_Request_Account__c>();
        
        for (Reference_Request_Account__c rra : insertRefReqAcc) {
            
            for (Task lstTask : listTask) {
                
                if (rra.Id == lstTask.Description.split('id=')[1]) {
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
     * RemoteAction to get request wrapper list REF-2496
     */
    @RemoteAction
    public static String getAccountRquestss(String accountIds) {
        List<String> listAccountIds = (accountIds != null && accountIds != '' ? accountIds.split(',') : new List<String>());
        List<ReferenceUseAccountWrapper> reqWL = new List<ReferenceUseAccountWrapper>();
        Integer refRecordCount = 0;
        
        for (Reference_Basic_Information__c rbiAcc : WithoutSharingHelperController.getAccountsRBI(listAccountIds)) {
            refRecordCount = refRecordCount + 1;
            reqWL.add(new ReferenceUseAccountWrapper(rbiAcc, rbiAcc.Account__r.Name, refRecordCount, rbiAcc.Managed_Reference_Account__c));
        }
        
        if (reqWL.size() == 0) {
            reqWL.add(new ReferenceUseAccountWrapper(new Reference_Basic_Information__c(), system.label.No_Account_Specified, 1, true));
        }
        return JSON.serialize(reqWL);
    }
    
    // Deprecated REF-2496
    @RemoteAction
    global static List<ReferenceUseAccountWrapper> getAccountRquests(String accountIds) {
        List<String> listAccountIds = (accountIds != null && accountIds != '' ? accountIds.split(',') : new List<String>());
        List<ReferenceUseAccountWrapper> reqWL = new List<ReferenceUseAccountWrapper>();
        Integer refRecordCount = 0;
        
        for (Reference_Basic_Information__c rbiAcc : WithoutSharingHelperController.getAccountsRBI(listAccountIds)) {
            refRecordCount = refRecordCount + 1;
            reqWL.add(new ReferenceUseAccountWrapper(rbiAcc, rbiAcc.Account__r.Name, refRecordCount, rbiAcc.Managed_Reference_Account__c));
        }
        
        if (reqWL.size() == 0) {
            reqWL.add(new ReferenceUseAccountWrapper(new Reference_Basic_Information__c(), system.label.No_Account_Specified, 1, true));
        }
        return reqWL;
    }

    /**
     * RemoteAction to get all referenceability types
     */
    @RemoteAction
    global static String getRefTypes1 (String mindeadLine) {
        List<RefTypeWrapper> listOfReferenceabilities = new List<RefTypeWrapper>();
        
        for (Referenceability_Type__c ref : [SELECT Name, Id, Note__c, max_accounts_per_request_type__c,
                                                min_lead_time_per_request_type__c, Managed__c 
                                                FROM Referenceability_Type__c
                                                WHERE Visible__c = true AND Request_type__c = true
                                                AND Sales_Reward__c = false
                                                ORDER BY Name LIMIT :limits.getLimitQueryRows()]) {
            listOfReferenceabilities.add(new RefTypeWrapper(ref, mindeadLine));
        }
        return JSON.serialize(listOfReferenceabilities);
    }
    
    /**
     * RemoteAction to get all referenceability types
     */
    global static List<RefTypeWrapper> getRefTypes(String mindeadLine) {
        return null;
    }
    
    /**
     * RemoteAction to calculate date
     */
    @RemoteAction
    global static date calculateDate(String dwJSON) {
        return date.today();
    }
    
    /**
     * RemoteAction to calculate date
     */
    @RemoteAction
    global static String calculateDateNew(String dwJSON) {
        DateWrapper dw = (DateWrapper)JSON.deserialize(dwJSON, DateWrapper.class);
        //date date1 = dw.deadLineDate;
        date date1 = Date.today();
        Integer days = dw.days;
        
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
        String result = date1.month() + '/' + date1.day() + '/' + date1.year();
        return result;
    }
    
    /**
     * RemoteAction to check for Weekend
     */
    @RemoteAction
    global static String checkforWeekend(String dwJSON) {
        
        try {
            DateWrapper dw = (DateWrapper)JSON.deserialize(dwJSON, DateWrapper.class);
            date deadLineDate = dw.deadLineDate;
            Integer minimumDeadline = dw.days;
            String errorMessage = '';
            
            if (UtilityController.isItWeekend(deadLineDate)) {
                errorMessage += System.Label.Edit_popup_deadline_date_must_not_fall_Weekend;
            }
            // checking for deadline date is in period or not
            Date lastDay = UtilityController.calculateMinimumDays(deadLineDate, Integer.valueOf(minimumDeadline));
            
            if (lastDay.daysBetween(deadLineDate) <= 0) {
                errorMessage += (System.Label.Edit_popup_invalid_past_Deadline_date).replace('Minimum_Deadline', '' + minimumDeadline);
            }
            return errorMessage;
        } catch(Exception e) {
            system.debug('Exception --------' + e.getMessage() + '         ' + e.getLineNumber() + ' Type : </b>' + e.getTypeName());
            return e.getMessage().substringBefore('at [');
        }
    }
    
    /**
     * RemoteAction to get all additional fields : DEPRECATED
     */
    global static Map<String, FieldWrapper> getAddFields() {
        return null;
    }

    /**
     * RemoteAction to get all additional fields
     */
    @RemoteAction
    global static String getAddFields1() {
        Map<String, Schema.SObjectType> schemaMap = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType referRequestAddInfoSchema = schemaMap.get(UtilityController.appNamespace() + 'Reference_Request_Additional_Info__c');
        Map<String, Schema.SObjectField> fieldMap = referRequestAddInfoSchema.getDescribe().fields.getMap();
        Map<String, FieldWrapper> fieldWrapperMap = new Map<String, FieldWrapper>();
        
        for (String field : fieldMap.keySet()) {
            Schema.DescribeFieldResult fieldObj = fieldMap.get(field).getDescribe();
            
            if (fieldObj.isCreateable() && fieldObj.isCustom()) {
                fieldWrapperMap.put(field, new FieldWrapper(fieldObj));
            }
        }
        return JSON.serialize(fieldWrapperMap);
    }
    
    /**
     * RemoteAction to get additional fields for ref types : DEPRECATED
     */
    global static Map<String, RefAddiFieldWrapper> getRefAddFields(String fieldMapJSON, String accountJSON, String refNoteSetJSON) { 
        return null;
    }
    /**
     * RemoteAction to get additional fields for ref types
     */
    @RemoteAction
    global static String getRefAddFields1(String fieldMapJSON, String accountJSON, String refNoteSetJSON) { 
        Map<Id, Referenceability_Type__c> refTypeMap = new Map<Id, Referenceability_Type__c>(); 
        Set<String> refNoteSet = (Set<String>)JSON.deserialize(refNoteSetJSON, Set<String>.class);
        Map<String, FieldWrapper> fieldWrapperMap = (Map<String, FieldWrapper>)JSON.deserialize(fieldMapJSON, Map<String, FieldWrapper>.class);
        Map<Integer, ReferenceUseAccountWrapper> selectedAccounts = (Map<Integer, ReferenceUseAccountWrapper>)JSON.deserialize(accountJSON, Map<Integer, ReferenceUseAccountWrapper>.class);
        Map<String, RefAddiFieldWrapper> refAddFieldMap = new Map<String, RefAddiFieldWrapper>();
        List<Referenceability_Type__c> listOfReferenceabilities = [SELECT Name, Id, Managed__c
                                                                   FROM Referenceability_Type__c
                                                                   WHERE Visible__c = true AND Request_type__c = true
                                                                   AND Managed__c = true
                                                                   AND Sales_Reward__c = false
                                                                   ORDER BY Name LIMIT :limits.getLimitQueryRows()];
                                                                  
        for (Referenceability_Type__c ref : listOfReferenceabilities) { 
            refTypeMap.put(ref.Id, ref); 
        }
        
        for (Reference_Type_Mapping__c refer : [SELECT Id, Name, Referenceability_Type__c, Referenceability_Type__r.Name,
                                                    Required__c, Visible__c
                                                    FROM Reference_Type_Mapping__c
                                                    WHERE Label__c = null
                                                    AND Referenceability_Type__c != null
                                                    LIMIT :limits.getLimitQueryRows()]) {
            
            if (fieldWrapperMap != null && fieldWrapperMap.containsKey(refer.Name.toLowerCase()) && fieldWrapperMap.get(refer.Name.toLowerCase()) != null) {
                
                for (ReferenceUseAccountWrapper rraw : selectedAccounts.values()) {
                    Boolean fieldPresent = false;
                    
                    if ((rraw.isManaged || rraw.accountName == system.label.No_Account_Specified || (refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) && rraw.referenceType == refer.Referenceability_Type__c) {
                        
                        if (!refAddFieldMap.containsKey(rraw.referenceType)) {
                            refAddFieldMap.put(rraw.referenceType, new RefAddiFieldWrapper(rraw.referenceType));
                        }
                            
                        for (ReferenceTypeMappingWrapper referMapping : refAddFieldMap.get(refer.Referenceability_Type__c).referNamesOfFields) {
                            
                            if (referMapping.name != '' && refer.Name == referMapping.name) {
                                fieldPresent = true;
                            }
                        }
                        
                        if (fieldPresent == false) {
                            refAddFieldMap.get(refer.Referenceability_Type__c).referNamesOfFields.add(new ReferenceTypeMappingWrapper(refer));
                        }
                    }
                }
            }
        }
        
        for (ReferenceUseAccountWrapper rraw : selectedAccounts.values()) {
            
            if (rraw.isManaged || rraw.accountName == system.label.No_Account_Specified || (refTypeMap.get(rraw.referenceType) != null && Boolean.valueOf(refTypeMap.get(rraw.referenceType).Managed__c))) {
                
                if (!refAddFieldMap.containsKey(rraw.referenceType) && refNoteSet.contains(rraw.referenceType)) {
                    refAddFieldMap.put(rraw.referenceType, new RefAddiFieldWrapper(rraw.referenceType));
                }
            }
        }
        return JSON.serialize(refAddFieldMap);
    }
    
    /**
     *  RemoteAction to get Filters for ref types : Deprecated
     */
    global static Map<String, LabelWrapper> getFilters(String paraValues) { 
        return null;
    }

    /**
     *  RemoteAction to get Filters for ref types
     */
    @RemoteAction
    global static String getFilters1(String paraValues) { 
        List<String> lstRefTypeAndRoutingGrp = paraValues.split('@@');
        String grpNames = ''; 
        String refTypeIdsSetJSON = '';
        String isPToPRequest = 'false';
        Map<String, LabelWrapper> refFilterMap = new Map<String, LabelWrapper>(); 
        
        if (lstRefTypeAndRoutingGrp.size() > 1) { 
            refTypeIdsSetJSON = lstRefTypeAndRoutingGrp[0];
            grpNames = lstRefTypeAndRoutingGrp[1]; 
            isPToPRequest = lstRefTypeAndRoutingGrp[2]; 
        } else if (lstRefTypeAndRoutingGrp.size() == 1) {
            refTypeIdsSetJSON = lstRefTypeAndRoutingGrp[0];
        } else {
            return JSON.serialize(refFilterMap);
        }
             
        Set<String> refTypeIdsSet = (Set<String>)JSON.deserialize(refTypeIdsSetJSON, Set<String>.class);
        
        Custom_Settings__c cs = UtilityController.getCustomSettings(); 
         
        for (Reference_Type_Mapping__c refer : [SELECT Id, Name, Referenceability_Type__c, Label__c, Label__r.Name,
                                                    Visible__c, Required__c
                                                    FROM Reference_Type_Mapping__c
                                                    WHERE Referenceability_Type__c IN :refTypeIdsSet
                                                    AND (Visible__c = true OR Required__c = true)
                                                    AND Label__c != null
                                                    ORDER BY Label__r.Name
                                                    LIMIT :limits.getLimitQueryRows()]) {
            
            if (refFilterMap.containsKey(refer.Label__c) ) {
                
                if (!refFilterMap.get(refer.Label__c).required) {
                    refFilterMap.put(refer.Label__c, new LabelWrapper(refer));
                }
            } else {
                refFilterMap.put(refer.Label__c, new LabelWrapper(refer));
            }
        }
       
        if (cs != null && cs.Adv_Request_Routing__c && !String.isEmpty(grpNames)) { 
            List<String> grpNameslist = grpNames.Split(',');
             
            for (Label__c lbl : [SELECT Id, Name, CreatedDate, Description__c, Required__c, Visible__c,
                                Filter_RefSearch_Visible__c, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                FROM Label__c WHERE Adv_Routing_Group__c IN :grpNameslist
                                OR (Adv_Routing_Group__c = null AND Show_in_P2P__c = true)
                                LIMIT :limits.getLimitQueryRows()]) {
                refFilterMap.put(lbl.Id, new LabelWrapper(lbl.Name, (String)lbl.Id, (Boolean)lbl.Required_in_P2P__c, (Boolean)lbl.Show_in_P2P__c));
            }  
           
        } else if (cs != null && cs.Adv_Request_Routing__c && isPToPRequest == 'true') {
             
            for (Label__c lbl : [SELECT Id, Name, CreatedDate, Description__c, Required__c, Visible__c,
                                Filter_RefSearch_Visible__c, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                FROM Label__c WHERE (Adv_Routing_Group__c = null AND Show_in_P2P__c = true)
                                LIMIT :limits.getLimitQueryRows()]) {
                                    
                refFilterMap.put(lbl.Id, new LabelWrapper(lbl.Name, (String)lbl.Id, (Boolean)lbl.Required_in_P2P__c, (Boolean)lbl.Show_in_P2P__c));
            }
        }  
        return JSON.serialize(refFilterMap);
    }    
    
    global static Map<String, LabelWrapper> getMandatoryFilters() {
        return new Map<String, LabelWrapper>();
    }
    
    @RemoteAction
    global static Map<String, LabelWrapper> getMandatoryFilters(Boolean isAccountSelected) {
        Map<String, LabelWrapper> refFilterMap = new Map<String, LabelWrapper>();
        Custom_Settings__c cs = UtilityController.getCustomSettings(); 
         
        if (isAccountSelected || cs.Adv_Request_Routing__c) {
            
            for (Label__c lbl : [SELECT Id, Name, CreatedDate, Description__c, Required__c, Visible__c,
                                    Filter_RefSearch_Visible__c, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                    FROM Label__c
                                    WHERE (Adv_Routing_Group__c = null AND Show_in_P2P__c = true)
                                    LIMIT :limits.getLimitQueryRows()]) {
                refFilterMap.put(lbl.Id, new LabelWrapper(lbl.Name, (String)lbl.Id, (Boolean)lbl.Required_in_P2P__c, (Boolean)lbl.Show_in_P2P__c));
            } 
        }
        getRoutigGrpFilters('');
          
        return refFilterMap;
    }
    
    @RemoteAction
    global static Map<String, LabelWrapper> getRoutigGrpFilters(String grpNames) {  
        List<String> grpNameslist = grpNames.Split(',');
        Map<String, LabelWrapper> refFilterMap = new Map<String, LabelWrapper>();
         
        for (Label__c lbl : [SELECT Id, Name, CreatedDate, Description__c, Required__c, Visible__c,
                                Filter_RefSearch_Visible__c, Show_in_P2P__c, Required_in_P2P__c, Adv_Routing_Group__c
                                FROM Label__c WHERE Adv_Routing_Group__c IN :grpNameslist
                                OR (Adv_Routing_Group__c = null AND Show_in_P2P__c = true)
                                LIMIT :limits.getLimitQueryRows()]) {
            refFilterMap.put(lbl.Id, new LabelWrapper(lbl.Name, (String)lbl.Id, (Boolean)lbl.Required_in_P2P__c, (Boolean)lbl.Show_in_P2P__c));
        }  
         
        return refFilterMap;
    }
    
    /**
     * Method to get Filters for ref types : Deprecated
     */
    global static Map<String, List<AttributesLabelWrapper>> getAllFilterAttributes(String filterIdsJson) {   
        return null;
    }

    /**
     * RemoteAction to get Filters for ref types
     * REF-2366 Limit attribute labels to 201
     */
    @RemoteAction
    global static String getAllFilterAttributes1(String filterIdsJson) {   
        Set<String> filterIds = (Set<String>)JSON.deserialize(filterIdsJson, Set<String>.class);
        Map<String, List<AttributesLabelWrapper>> lstAttributeWrapper = new Map<String, List<AttributesLabelWrapper>>();
        
        for (Label__c label : [SELECT Id, (SELECT Name, Label__c, Id, Label__r.Filter_no__c, Attribute__c, Attribute__r.Name
                                            FROM Attributes_Labels__r WHERE Attribute__c != null
                                            ORDER BY Attribute__r.Name LIMIT 201) FROM Label__c WHERE Id IN :filterIds
                                            LIMIT :limits.getLimitQueryRows()]) {
            lstAttributeWrapper.put(label.Id, new List<AttributesLabelWrapper>());
            
            for (Attributes_Labels__c al : label.Attributes_Labels__r) {
                lstAttributeWrapper.get(label.Id).add(new AttributesLabelWrapper(al));
            }
        }
        return JSON.serialize(lstAttributeWrapper);
    }
    
    /**
     * Wrapper Class
     */
    global class RefAddiFieldWrapper {
        public String refId { get; set; }
        public List<ReferenceTypeMappingWrapper> referNamesOfFields { get; set; }
        public Reference_Request_Additional_Info__c addInfo { get; set; }
        
        public RefAddiFieldWrapper(String refId) {
            this.refId = refId;
            this.addInfo = new Reference_Request_Additional_Info__c();
            this.referNamesOfFields = new List<ReferenceTypeMappingWrapper>();
        }
    }
    
    /**
     * Wrapper Class
     */
    global class ReferenceTypeMappingWrapper {
        public String name { get; set; }
        public Boolean visible { get; set; }
        public Boolean required { get; set; }
        
        public ReferenceTypeMappingWrapper(Reference_Type_Mapping__c obj) {
            this.name = obj.Name.toLowerCase();
            this.visible = obj.Visible__c;
            this.required = obj.Required__c;
        }
    }
    
    /**
     * Wrapper Class
     */
    global class FieldWrapper {
        public String name { get; set; }
        public String label { get; set; }
        public String inlineHelpText { get; set; }
        public String type { get; set; }
        public List<String> picklistValues { get; set; }
        
        public FieldWrapper(Schema.DescribeFieldResult field) {
            this.name = field.getName();
            this.label = field.getLabel();
            this.inlineHelpText = field.getInlineHelpText();
            this.type = String.valueOf(field.getType());
            this.picklistValues = new List<String>();
            
            if (this.type == 'PICKLIST' || this.type == 'MULTIPICKLIST') {
                
                for (Schema.PicklistEntry f : field.getPicklistValues()) {
                    picklistValues.add(String.valueOf(f.value));
                }
            }
        }
    }
    
    /**
     * Method to check Permissions
     */
    public static Boolean checkPermissions(Boolean isOnPageLoad, String action, String opportunityId, String caseId, String leadId) { 
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>(); 
        Boolean isUpsertPermission = false; 
        Boolean isInsertPermission = false;
        
        if (isOnPageLoad || action == 'SAVE') {                                     
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Request__c', new Set<String> { 
                                                    UtilityController.appNamespace() + 'Project_Type__c',
                                                    UtilityController.appNamespace() + 'Requester__c', 
                                                    UtilityController.appNamespace() + 'Reference_Request_Status__c'});
            
            if (opportunityId != null && opportunityId.trim().length() > 0 && opportunityId != '') {
                fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Opportunity__c'); 
            } else if (caseId != null && caseId.trim().length() != 0 && caseId != '') {
                fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Case__c'); 
            //regarding ticket #809
            } else if (leadId != null && leadId.trim().length() != 0 && leadId != '') {
                fieldMap.get(UtilityController.appNamespace() + 'Reference_Request__c').add(UtilityController.appNamespace() + 'Lead__c'); 
            }                                       
            isUpsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, false, true);
            fieldMap.clear();                                       
            fieldMap.put(UtilityController.appNamespace() + 'Unspecified_Request__c', new Set<String> { 
                                                    UtilityController.appNamespace() + 'Deadline__c',
                                                    UtilityController.appNamespace() + 'Unspecified_Request_Status__c',
                                                    UtilityController.appNamespace() + 'Reference_Request__c',
                                                    UtilityController.appNamespace() + 'Reference_Type_Needed__c',
                                                    UtilityController.appNamespace() + 'Requester__c',
                                                    UtilityController.appNamespace() + 'Request_Notes__c'});
                                                    
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label__c', new Set<String> { 
                                                    UtilityController.appNamespace() + 'Label__c',
                                                    UtilityController.appNamespace() + 'Reference_Request__c' });
                                                    
            fieldMap.put(UtilityController.appNamespace() + 'Reference_Request_Label_Attribute__c', new Set<String> { 
                                                    UtilityController.appNamespace() + 'Attribute__c',
                                                    UtilityController.appNamespace() + 'Reference_Request_Label__c' });
                                                    
            isInsertPermission = CRUDAndFLSCheckController.isUpsertable(fieldMap, true, false);                                         
                                                     
        } 
                   
        return  isUpsertPermission;  
    }
    /**
     * Wrapper Class
     */
    global class DateWrapper {
        public Date deadLineDate { get; set; }
        public Integer days { get; set; }
        
        public DateWrapper() {}
    }
    
    /**
     * Wrapper Class
     */
    global class RefTypeWrapper {
        public Referenceability_Type__c ref { get; set; }
        public String name { get; set; }
        public String minDeadline { get; set; }
        public Integer maxRequest { get; set; }
        public String note { get; set; }
        public Boolean isManaged { get; set; }
        
        public RefTypeWrapper(Referenceability_Type__c ref, String minDeadlineCS) {
            this.ref = ref;
            this.name = ref.Name;
            this.note = ref.Note__c;
            this.minDeadline = (ref.min_lead_time_per_request_type__c != null ? String.valueOf(ref.min_lead_time_per_request_type__c) : minDeadlineCS);
            this.maxRequest  = (ref.max_accounts_per_request_type__c != null ? Integer.valueOf(ref.max_accounts_per_request_type__c) : 0);
            this.isManaged = ref.Managed__c;
        }
    }
    
    /**
     * Wrapper Class
     */
    global class ReferenceUseAccountWrapper {
        public Reference_Basic_Information__c rbi { get; set; }
        public Boolean isCollapsed { get; set; }
        public String accountName { get; set; }
        public integer recordCount { get; set; }
        public Id referenceType { get; set; }
        public String referenceTypeName { get; set; }
        public Date deadline { get; set; }
        public String deadLineDate { get; set; }
        public String notes { get; set; }
        public Boolean isSelected { get; set; }
        public Boolean isManaged { get; set; }
        public Boolean isRequestCreatedForAccount { get; set; }
        
        public ReferenceUseAccountWrapper(Reference_Basic_Information__c acc, String accName, Integer Count, Boolean isManaged) {
            this.isSelected = false;
            this.rbi = acc;
            this.accountName = accName;
            this.recordCount = Count;
            this.referenceTypeName = '';
            this.isManaged = isManaged;
            this.isCollapsed = true;
            this.isRequestCreatedForAccount = false;
        }
    }
    
    /**
     * Wrapper Class
     */
    global class LabelWrapper {
        public String labelName { get; set; }
        public String labelId { get; set; }
        public String selectedAttributes { get; set; }
        public Set<String> selectedAttIds { get; set; }
        public Boolean required { get; set; }
        public Boolean visible { get; set; }
        
        public LabelWrapper(Reference_Type_Mapping__c rtm) {
            this.labelName = rtm.Label__r.Name;
            this.labelId = rtm.Label__c;
            this.required = rtm.Required__c;
            this.visible = rtm.Visible__c;
            selectedAttIds = new Set<String>();
            selectedAttributes = '';
        }
        
        public LabelWrapper(String name, String id, Boolean req, Boolean isVisible) {
            this.labelName = name;
            this.labelId = id;
            this.required = req;
            this.visible = isVisible;
            selectedAttIds = new Set<String>();
            selectedAttributes = '';
        }
    }
    
    /**
     * Wrapper class
     */
    global class AttributesLabelWrapper {
        public Attributes_Labels__c attributeLabel { get; set; }
        public Boolean isSelected { get; set; }
        public String attId { get; set; }
        public String attName { get; set; }
        
        public AttributesLabelWrapper(Attributes_Labels__c attributeLabel) {
            isSelected = false;
            this.attId = attributeLabel.Attribute__r.Id;
            this.attributeLabel = attributeLabel;
            this.attName = attributeLabel.Attribute__r.Name;
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
    
    global class AdvRoutingGroups { 
        String value { get; set; }
        String name { get; set; }
        
        public AdvRoutingGroups(string name,String value) { 
            this.name = name; 
            this.value = value;   
        }
    }
    
    //REF-2132
    @RemoteAction
    public static String getFilesAssociatedWithReferenceRequest(String requestId) {
        List<ContentDocumentLink> listOfCDL = new List<ContentDocumentLink>();
        List<ContentDocument> listOfFile = new List<ContentDocument>();
        List<String> listOfDocumentId = new List<String>();
        
        if (!String.isBlank(requestId)) {
            listOfCDL = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: requestId];
            
            if (listOfCDL.size() > 0) {
                
                for (ContentDocumentLink cdl : listOfCDL) {
                    
                    if (!String.isBlank(String.valueOf(cdl.ContentDocumentId))) {
                        listOfDocumentId.add(cdl.ContentDocumentId);
                    }
                }
                
                if (listOfDocumentId.size() > 0) {
                    listOfFile = [SELECT Id, Title, PublishStatus, LatestPublishedVersionId, ParentId, ContentSize, FileExtension, FileType 
                                   FROM ContentDocument 
                                   WHERE Id IN: listOfDocumentId];
                }
                
            }
        }
        
        if (listOfFile.size() > 0) {
            return JSON.serialize(listOfFile);
        }
        return null;
    }
    
    /**
     * REF-2366 get filter attributes by name
     */
    @RemoteAction
    global static String getFilterAttributesByName(String filterId, String searchValue) {
        String tempSearchVal = searchValue.replace('*', '%') + '%';
        tempSearchVal = String.escapeSingleQuotes(tempSearchVal);
        Map<String, List<AttributesLabelWrapper>> lstAttributeWrapper = new Map<String, List<AttributesLabelWrapper>>();
        List<Label__c> listOfFilters = [SELECT Id, (SELECT Name, Label__c, Id, Label__r.Filter_no__c, Attribute__c, Attribute__r.Name
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
                lstAttributeWrapper.put(label.Id, new List<AttributesLabelWrapper>());
                
                if (label.Attributes_Labels__r.size() > 0) {
                    
                    for (Attributes_Labels__c al : label.Attributes_Labels__r) {
                        lstAttributeWrapper.get(label.Id).add(new AttributesLabelWrapper(al));
                    } 
                }
            }
        }
        
        return JSON.serialize(lstAttributeWrapper);
    }
}