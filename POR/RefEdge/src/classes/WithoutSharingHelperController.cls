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
 * Description: This class ignores the Organisation Wide sharing rules for all the code it contains.
 *              It is used for DML operations AND queries on any object WHERE the user does not have
 *              the required permissions AND still we want to perform the action.
 * Last Modified By: Gaurav Saini (16 March, 2017)
 */ 
public without sharing class WithoutSharingHelperController {
    
    /**
     * method to get reference request record for project detail page in lightning
     * author: Gaurav Saini (7 Mar, 2018) for REF-1358
     */
    public static List<Reference_Request__c> getRefRequestForProjectDetail(String requestId) {
        return [SELECT Id, Name, Opportunity__c, Opportunity__r.Name, Reference_Request_Status__c, Opportunity__r.Account.Name, Lead__c, Lead__r.Name,
                Requester__c, Requester__r.Name, Subject__c, Title__c, Case__c, Project_Type__c, Adv_Routing_Group__c, Case__r.Account.Name, Case__r.CaseNumber,
                (SELECT Id, Name, Account__c, Account__r.Name, Account_Request_Status__c, Account_f__c, Deadline__c, Request_Notes__c,
                    Reference_Type_Needed_f__c, Reference_Type_Needed__c, Process__c, Managed_Request__c, Reference_Owner__c,
                    Approve_Deny_Notes__c, Project_Owner__c, Project_Owner__r.Name, Reference_Request_Additional_Info__c, Influitive_Challenge_Id__c,
                    Influitive_Challenge_Status__c
                    FROM Reference_Request_Accounts__r),
                (SELECT Id, Unspecified_Request_Status__c, Reference_Type_Needed__c, Reference_Type_Needed_f__c, Project_Owner__r.Name,
                    Reference_Request_Additional_Info__c, Deadline__c, Name, Notes__c, Request_Notes__c, Project_Owner__c, Influitive_Challenge_Id__c,
                    Influitive_Challenge_Status__c
                    FROM Unspecified_Requests__r),
                (SELECT Id, Label__c FROM Reference_Request_Labels__r)
                FROM Reference_Request__c WHERE Id = :requestId];
    }
    
    /**
     * method to get accounts search results based on text search
     * author: Gaurav Saini (14 Dec, 2017) for #959
     */
    public static List<List<sObject>> getAccountsUsingSOSL(String soslQuery, List<String> existingRefLeadsAccIds,
                                                            List<String> alreadyPresentAccIds) {
        return Search.query(soslQuery);
    }
    
    /**
     * method to get accounts for create prospect list page
     * author: Gaurav Saini (11 Dec, 2017) for #959
     */
    public static List<Account> getAccountsForProspect(String accountsQuery, List<String> existingRefLeadsAccIds, List<String> alreadyPresentAccIds, Set<Id> relatedAccountIdSet) {
        return Database.query(accountsQuery);
    }
    
    /**
     * method to get the account team object records for advanced routing
     * author: Gaurav Saini (30 Nov, 2017) for #1171
     */
    public static List<sObject> getAccountTeamList(String accTeamQuery, List<String> selectedAccountIds) {
        return Database.query(accTeamQuery);
    }

    /**
     * method to get the Contact object records for advanced routing
     * author: Dixita Jain (3 May, 2018) for #1422
     */
    public static List<sObject> getContactList(String contactQuery, List<String> contactIdsList) {
        return Database.query(contactQuery);
    }
    
    /**
     * method to get territory records for TM2.0
     * author: Gaurav Saini (30 Nov, 2017) for #1171
     */
    public static List<sObject> getTerritory2List(String territoryQuery, List<String> selectedAccountIds) {
        return Database.query(territoryQuery);
    }
    
    /**
     * method to get territory records for TM2.0
     * author: Gaurav Saini (30 Nov, 2017) for #1171
     */
    public static List<sObject> getAccountShareList(String accShareQuery, List<String> selectedAccountIds) {
        return Database.query(accShareQuery);
    }
    
    /**
     * method to get territory groups for advanced routing
     * author: Gaurav Saini (30 Nov, 2017) for #1171
     */
    public static List<Group> getGroupsListForAdvRouting(Set<String> groupIdsSet) {
        return [SELECT Id, RelatedId
                FROM Group
                WHERE Type = 'Territory'
                AND Id IN :groupIdsSet];
    }
    
    /**
     * method to get territory records for TM1.0
     * author: Gaurav Saini (30 Nov, 2017) for #1171
     */
    public static List<sObject> getTerritory1List(String territoryQuery) {
        return Database.query(territoryQuery);
    }
    
    /**
     * method to get user territory association for advanced routing
     * author: Gaurav Saini (30 Nov, 2017) for #1171
     */
    public static List<sObject> getUserTerritoryList(String userTerritoryQuery, Set<String> territoryIdsSet) {
        return Database.query(userTerritoryQuery);
    }
    
    /**
     * method to insert reference leads
     * author: Gaurav Saini (2 Nov, 2017) for #1102
     */
    public static void insertRefLeads(List<Reference_lead__c> refLeads) {
        upsert refLeads;
    }
    
    /**
     * method to get list view id if the specified object
     * author: Gaurav Saini (2 Nov, 2017)
     */
    public static String getListViewId(String objAPIName) {
        List<ListView> listViews = [SELECT Id, Name FROM ListView WHERE sObjectType = :objAPIName];
        String result = '';
        
        if (listViews != null && listViews.size() > 0) {
            result = listViews[0].Id;
        }
        return result;
    }
    
    /**
     * method to get ref lead records which were created using the ref prospector functionality
     * author: Gaurav Saini (2 Nov, 2017) for #1102
     */
    public static List<Reference_lead__c> getExistingRefLeads() {
        return [SELECT Id, Reference_Lead_Account__c, Reference_Lead_Account__r.Name,
                Reference_Lead_Owner__c, Reference_Lead_Status__c, Reference_Lead_Owner__r.Name,
                Initial_Notification_Sent__c, Ref_Lead_Campaign_Name__c, Ref_Lead_Include_in_Campaign__c,
                Initial_Notification_Date__c, Reminder_Date__c, No_Response_Date__c,
                Reference_Lead_Owner__r.FirstName
                FROM Reference_Lead__c
                WHERE Ref_Lead_From_Opportunity__c = false
                AND Reference_Lead_Opportunity__c = null
                AND Reference_Lead_Status__c != 'Converted to Program Member'
                AND Reference_Lead_Status__c != 'Converted to Nomination'
                AND Reference_Lead_Status__c != 'No Updates'];
    }
    
    /**
     * method to get ref lead records for launching the ref prospector campaign
     * author: Gaurav Saini (1 Dec, 2017)
     */
    public static List<Reference_lead__c> getRefLeadsForLaunchCampaign() {
        return [SELECT Id, Reference_Lead_Account__c, Reference_Lead_Account__r.Name,
                Reference_Lead_Owner__c, Reference_Lead_Status__c, Reference_Lead_Owner__r.Name,
                Initial_Notification_Sent__c, Ref_Lead_Campaign_Name__c, Ref_Lead_Include_in_Campaign__c,
                Initial_Notification_Date__c, Reminder_Date__c, No_Response_Date__c,
                Reference_Lead_Owner__r.FirstName
                FROM Reference_Lead__c
                WHERE Ref_Lead_From_Opportunity__c = false
                AND Reference_Lead_Opportunity__c = null
                AND Reference_Lead_Status__c = 'Request Pending'];
    }
    
    /**
     * method to get ref lead records for the current user
     * author: Gaurav Saini (2 Nov, 2017) for #1102
     */
    public static List<Reference_Lead__c> getRefLeadsForUser() {
        return [SELECT Id, Reference_Lead_Account__c, Reference_Lead_Account__r.Name,
                Reference_Lead_Owner__c, Reference_Lead_Status__c, Reference_Profile__c,
                Nomination__c, Follow_Up_Timeframe__c, Reference_Lead_Owner__r.Name
                FROM Reference_Lead__c
                WHERE Ref_Lead_From_Opportunity__c = false
                AND Initial_Notification_Sent__c = true
                AND Reference_Lead_Opportunity__c = null
                AND Reference_Lead_Owner__c = :UserInfo.getUserId()
                AND Reference_Lead_Status__c != 'Follow Up'
                AND Reference_Lead_Status__c != 'No Updates'
                AND Reference_Lead_Status__c != 'Converted to Nomination'
                AND Reference_Lead_Status__c != 'Converted to Program Member'
                ORDER BY Reference_Lead_Account__r.Name
                LIMIT 4];
    }
    
    /**
     * method to get ref lead records for the current user for the specified page number
     * author: Gaurav Saini (13 Nov, 2017) for #1104
     */
    public static List<Reference_Lead__c> getRefLeadsForPageNo(Integer size) {
        return [SELECT Id, Reference_Lead_Account__c, Reference_Lead_Account__r.Name,
                Reference_Lead_Owner__c, Reference_Lead_Status__c, Reference_Profile__c,
                Nomination__c, Follow_Up_Timeframe__c, Reference_Lead_Owner__r.Name
                FROM Reference_Lead__c
                WHERE Ref_Lead_From_Opportunity__c = false
                AND Initial_Notification_Sent__c = true
                AND Reference_Lead_Opportunity__c = null
                AND Reference_Lead_Owner__c = :UserInfo.getUserId()
                AND Reference_Lead_Status__c != 'Follow Up'
                AND Reference_Lead_Status__c != 'No Updates'
                AND Reference_Lead_Status__c != 'Converted to Nomination'
                AND Reference_Lead_Status__c != 'Converted to Program Member'
                ORDER BY Reference_Lead_Account__r.Name
                LIMIT :size + 1];
    }
    
    /**
     * method to get reference lead records for new page
     * author: Gaurav Saini (13 Nov, 2017) for #1104
     */
    public static List<Reference_Lead__c> getRefLeadsNotPresent(List<String> refLeadIds) {
        return [SELECT Id, Reference_Lead_Account__c, Reference_Lead_Account__r.Name,
                Reference_Lead_Owner__c, Reference_Lead_Status__c, Reference_Profile__c,
                Nomination__c, Follow_Up_Timeframe__c, Reference_Lead_Owner__r.Name
                FROM Reference_Lead__c
                WHERE Ref_Lead_From_Opportunity__c = false
                AND Initial_Notification_Sent__c = true
                AND Reference_Lead_Opportunity__c = null
                AND Reference_Lead_Owner__c = :UserInfo.getUserId()
                AND Reference_Lead_Status__c != 'Follow Up'
                AND Reference_Lead_Status__c != 'No Updates'
                AND Reference_Lead_Status__c != 'Converted to Nomination'
                AND Reference_Lead_Status__c != 'Converted to Program Member'
                AND Id NOT IN :refLeadIds
                ORDER BY Reference_Lead_Account__r.Name
                LIMIT 11];
    }
    
    /**
     * method to get reference lead records for new page
     * author: Gaurav Saini (13 Nov, 2017) for #1104
     */
    public static List<Reference_Lead__c> getRefLeadsPresent(List<String> refLeadIds) {
        return [SELECT Id, Reference_Lead_Account__c, Reference_Lead_Account__r.Name,
                Reference_Lead_Owner__c, Reference_Lead_Status__c, Reference_Profile__c,
                Nomination__c, Follow_Up_Timeframe__c, Reference_Lead_Owner__r.Name
                FROM Reference_Lead__c
                WHERE Ref_Lead_From_Opportunity__c = false
                AND Initial_Notification_Sent__c = true
                AND Reference_Lead_Opportunity__c = null
                AND Reference_Lead_Owner__c = :UserInfo.getUserId()
                AND Reference_Lead_Status__c != 'Follow Up'
                AND Reference_Lead_Status__c != 'No Updates'
                AND Reference_Lead_Status__c != 'Converted to Nomination'
                AND Reference_Lead_Status__c != 'Converted to Program Member'
                AND Id IN :refLeadIds
                ORDER BY Reference_Lead_Account__r.Name];
    }
    
    /**
     * method to get RBIs
     * author: Dixita Jain(Feb, 2018) for #1220
     */
    public static List<sObject> getRBI(String query, List<Id> contactIds) {
        return Database.query(query);
    }
    /**
     * method to get list of custom settings
     * 
     * author: Gaurav Saini (5 Dec, 2016)
     */
    public static List<Custom_Settings__c> getCustomSettings2() {
        return [SELECT Id, Show_Featured_Content_First__c, Show_Contacts_in_RefSearch__c, Name, Number_of_request_accounts__c, Minimum_Deadline__c, Reminder_to_Owner__c,
                    Escalation_to_Owner_Manager__c, No_Response__c, Feedback_Message_Delay__c, Email_Enabled__c, Chatter_Enabled__c, Include_Weekends__c, Days_of_Week__c,
                    Active_Version__c, Current_Version__c, RUL_Period__c, RUL_Activities__c, Consider_No_longer_needed_a_use__c,Is_Influitive_Integration_Enabled__c,Sales_Expiration_Days__c,
                    Auto_create_delete_Reference_Content__c, Critical_Deadline_window__c, Caution_deadline_window__c, Nomination_disposition_window__c, General_Notes__c, Expire_Rewards__c,
                    Automatically_Assign_Rewards__c, Expiration_Timeframe__c, Expiration_Days__c, Default_Expiration_Days__c, Maximum_Expiration_Days__c,Shared_Contact_Field__c,
                    Organization_FiscalYearStartMonth__c, Default_Referenceablity_Status__c, Automatically_Assign_Reward_on_Feedback__c,Shared_Contact_Object__c,Expire_Sales_Rewards__c,
                    Microsite_Visit_Chatter__c, Microsite_Visit_Email__c, Nomination_Chatter__c, Nomination_Email__c, Request_Managed_Chatter__c,P2P_Approve_Without_Contact__c,
                    Reference_Refresh_Update_Chatter__c, Reference_Refresh_Update_Email__c, Reference_Update_Chatter__c, Reference_Update_Email__c,Infl_Reference_Cursor__c,Infl_Event_Fetch_DateTime__c,Influitive_API_URL__c,Influitive_Auth_Token__c,
                    Request_Managed_Email__c, Request_Peer2Peer_Chatter__c, Request_Peer2Peer_Email__c, Request_Escalation_Chatter__c, Request_Escalation_Email__c,Shared_Account_Field__c,
                    Request_Feedback_Chatter__c, Request_Feedback_Email__c, Request_No_Response_Chatter__c, Request_No_Response_Email__c, Request_Reminder_Chatter__c,Auto_Assign_Sales_Reward_on_Feedback__c,
                    Request_Reminder_Email__c, Process_Update_Chatter__c, Process_Update_Email__c, Request_Approval_Decline_Email__c, Request_Approval_Decline_Chatter__c, Managed_to_P2P_Min__c,
                    Project_Owner_Update_Email__c, RUL_Activities_Contact__c, RUL_Period_Contact__c, Project_Owner_Update_Chatter__c, Status_Update_Email__c, Status_Update_Chatter__c,
                    Check_back_in_Email__c, Check_back_in_Chatter__c, Minimum_Sales_Stage__c, Reference_Lead_No_Response_Email__c, Reference_Lead_No_Response_Chatter__c,Auto_Assign_Sales_Rewards__c,
                    Opportunity_Closed_Won_Stage__c, Manual_Automatic_Launch__c, Refresh_Wait_Days__c, Enable_Reference_Refresh__c, Quarantine_updates__c,Sales_Reward_Point_Email__c,Sales_Reward_Point_Chatter__c,
                    Prevent_selection_of_mapped_Attributes__c, Managed_Request_Opportunity_Threshold__c, Minimum_Opportunity_Size__c, Create_Reference_Profile__c,Sales_Expiration_Timeframe__c,
                    Create_Nomination__c, Client_Referenceability_check_days__c, No_Response_days__c, Last_Refresh_Date__c, Next_Refresh_launch_Date__c, cloneTriggerId__c,
                    Community_Home_Text__c, Community_Ref_Activities_Message__c, Apply_Opportunity_Stage_Filter__c, Filtered_Content_Ids__c,Opportunity_Product_Field_API_Name__c,
                    Manage_ContentVersion_Custom_Fields__c,P2P_Select_Inactive_Contacts__c,
                    Reviewed_and_Ready_to_Launch__c,Remove_Points_if_Use_will_not_occur__c, Send_reminder_for_automatic__c, Profile_Update_Reminder_Email__c, Profile_Update_Reminder_Chatter__c,
                    RLF_Reminder_Days__c,PUM_No_Response_Days__c,Reference_Profile_Section_Header__c,Minimum_Opportunity_Size_OP__c, Default_Reference_Accounts_Managed__c, Shared_Contacts__c,
                    Roll_up_Attributes_to_All_Accounts__c,Roll_up_Attributes_to_Primary_Account__c,Roll_up_Referenceability_to_All_Accounts__c,Roll_up_Referenceability_to_Primary_Acc__c,
                    Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c,Limit_Contact_Redeem__c,Initial_Notification_Email__c,Initial_Notification_Chatter__c,
                    Sales_Reward_Batch_Trigger_Id__c, Enable_Sales_Rewards_Notification__c, Next_Notification_Date__c, Last_Notification_Date__c , Adv_Request_Routing__c,
                    Adv_Routing_Default__c, Adv_Rt_Acct_Team_Role_Picklist__c, Adv_Rt_Acct_Team_Roles_to_Include__c, Adv_Rt_Acct_Team_Object__c, Adv_Rt_Acct_Team_Contact__c, Adv_Rt_Acct_Team_Routeby__c, Adv_Rt_Acct_Team_User__c, Adv_Routing_Group_Lbl__c, Adv_Routing_Group_Mandatory__c,
                    Approve_Decline_Confirmation_Chatter__c, Approve_Decline_Confirmation_Email__c, Request_from_Leads__c, Show_Summary__c,
                    Project_Account_Required__c, Project_Contact_Required__c, Project_Opportunity_Required__c, Project_Case_Required__c, Project_Notes_Required__c, Project_Subject_Required__c,
                    User_Reward_Chatter_Summary__c, User_Reward_Email_Summary__c, User_Reward_Onscreen_Notification__c,
                    RefSearch_Filters_Default__c, Export_Objects__c, Import_Objects__c, Export_Object__c, Import_Object__c, Enable_Custom_Data_Loader__c,Data_Loader_Template_Fields__c,
                    Populate_Summary_frm_Account_Description__c, Show_Related_Ref_Content_in_RefSearch__c, PUM_New_Contact__c,
                    Ref_Prosepector_Lead_Owner__c, Ref_Prospector_Campaign_Lead_Count__c, Ref_Prospector_Lead_Count__c,
                    Ref_Prospector_Body__c, Ref_Prospector_Subject__c, Ref_Prospector_Hdr_Txt__c, Ref_Prospector_SubHdr_Txt__c, Ref_Prospector_Enable__c, Help_Overlay_Count__c,
                    Account_Stages__c, Prompt_Message__c, Content_Stages__c, Enable_Ref_Search_Export__c, Show_Matching_Reference_Content_link__c, Show_Matching_Reference_Accounts_link__c, Enable_Reference_Prompt__c, Reset_Help_Assistant_Days__c,
                    Enable_Data_Collector__c, Data_Collector_Name__c, Escalate_On_Last_Reminder__c, Frequency_Of_Reminders__c, Manage_Data_Collector__c, Minimum_Opportunity_Size_DC__c, Number_Of_Reminders_To_Be_Sent__c, Opportunity_Closed_Stages__c, 
                    P2P_to_Managed_Chatter__c, P2P_to_Managed_Email__c, Managed_to_P2P_Requester_Chatter__c, Managed_to_P2P_Requester_Email__c, Managed_to_P2P_Owner_Chatter__c,
                    Managed_to_P2P_Owner_Email__c, Ref_Lead_Reminder_Chatter__c, Ref_Lead_Reminder_Email__c, Ref_Lead_Reminder_member_Chatter__c, Ref_Lead_Reminder_member_Email__c, Initial_Notification_member_Chatter__c, Initial_Notification_member_Email__c,
                    Large_Opportunity_Email__c, Large_Opportunity_Chatter__c, Profile_Created_Chatter__c, Profile_Created_Email__c, Profile_Creation_from_Ref_Lead_Chatter__c, Profile_Creation_from_Ref_Lead_Email__c,
                    Nomination_Accepted_Email__c, Nomination_Accepted_Chatter__c, Nomination_Rejected_Email__c, Nomination_Rejected_Chatter__c, Ref_Lead_Owner_Update_Email__c, Ref_Lead_Owner_Update_Chatter__c,
                    All_Reviews_to_CRP_Team__c,Enabled_Content_Integration__c, Default_Library__c, Default_Reference_Content_Type__c, Create_Advocate_Reference_Profile__c, Include_Opp_Attributes_in_RefSearch__c,
                    Refedge_P2P_Use_Adds_Ref__c, Content_import_API_reporting_email__c, Slack_Team_Ids__c, Enable_Slack_Integration__c, Slack_Enabled__c, Request_Peer2Peer_Slack__c, Request_Managed_Slack__c, Large_Opportunity_Slack__c, Request_Approval_Decline_Slack__c, 
                    Request_Reminder_Slack__c, Request_Escalation_Slack__c, Request_No_Response_Slack__c, Approve_Decline_Confirmation_Slack__c, Project_Owner_Update_Slack__c, Status_Update_Slack__c, Managed_to_P2P_Owner_Slack__c,
                    Managed_to_P2P_Requester_Slack__c, P2P_to_Managed_Slack__c, Request_Feedback_Slack__c, Microsite_Visit_Slack__c, Nomination_Slack__c, Nomination_Accepted_Slack__c, Nomination_Rejected_Slack__c,
                    Initial_Notification_Slack__c, Initial_Notification_member_Slack__c, Ref_Lead_Reminder_Slack__c, Ref_Lead_Reminder_member_Slack__c, Check_back_in_Slack__c, Ref_Lead_Owner_Update_Slack__c, Profile_Creation_from_Ref_Lead_Slack__c,
                    Reference_Refresh_Update_Slack__c, Reference_Update_Slack__c, Profile_Update_Reminder_Slack__c, Profile_Created_Slack__c, User_Reward_Slack_Summary__c, Sales_Reward_Point_Slack__c, SU_Permission_Sets__c, SU_Profiles__c,
                    DC_Initial_Notification_Email__c, DC_Reminder_Email__c, DC_Escalation_to_Owner_Email__c, DC_Escalation_to_Manager_Email__c, DC_Manager_Review_Email__c, DC_CRP_Team_Review_Email__c, 
                    DC_Initial_Notification_Chatter__c, DC_Reminder_Chatter__c, DC_Escalation_to_Owner_Chatter__c, DC_Escalation_to_Manager_Chatter__c, DC_Manager_Review_Chatter__c, DC_CRP_Team_Review_Chatter__c,
                    DC_Initial_Notification_Slack__c, DC_Reminder_Slack__c, DC_Escalation_to_Owner_Slack__c, DC_Escalation_to_Manager_Slack__c, DC_Manager_Review_Slack__c, DC_CRP_Team_Review_Slack__c ,
                    ACV_Amount_Field__c, ACV_Basis__c, RM_Permission_Sets__c, RM_Profiles__c, Attach_Supporting_Documents_To_Requests__c, Create_Nominees__c, Routing_Groups_to_Exclude__c,Show_Owner_in_Ref_Search__c, Request_Notes_Required__c
                    FROM Custom_Settings__c WHERE Active_Version__c = true ORDER BY Current_Version__c DESC LIMIT 1];
    }
    
    /**
     * method to insert reference Notes
     *
     * author: Rajesh (6 July, 2017)
     */
    public static void insertReferenceNotes(List<Reference_Note__c> notes) {
        insert notes;
    }
    
    /**
     * method to get reference content
     * Created By: Rajesh @17 April 2017
     */
    public static List<Reference_Content__c> getRefContent() {
        return [SELECT Name, Id FROM Reference_Content__c WHERE (Content_Status__c != : ConstantsController.INACTIVE 
                                                                    AND Content_Status__c != '') LIMIT: limits.getLimitQueryRows()];
    }
    
    /**
     * method to get reference request of converted lead
     * Created By: Rekha @14 April 2017
     */
    public static List<Reference_Request__c> getRefRequestsOfConvertedLead(Set<String> convertedLeads) {
        return [SELECT Id, Lead__c, Opportunity__c FROM Reference_Request__c WHERE Lead__c IN :convertedLeads];
    }
    
    /** 
     * Method used to get routing details
     * author: Rajesh (23 March, 2017) 
     */ 
    public static List<Advanced_Routing__c> getRoutingDetails() {        
        return [SELECT Name, Id, Adv_Routing_Name__c, Territory_Id__c,
                                                    Adv_Routing_Client_Value__c, Adv_Routing_Attribute__c
                                                    FROM Advanced_Routing__c
                                                    LIMIT :limits.getLimitQueryRows()];
    }

    /**
     * method to get data mappings for ref search lightning
     *
     * author: Dixita (ug, 201) for #1780
     */
    public static List<Data_Mapping__c> getDMHelpOverlay(List<String> pageNames) {
        return [SELECT Name, Order__c, Id, Visible__c, Required__c, DC_Message__c,
                Label__c, From_Mapping__c, Field_API_Name__c, Default__c
                FROM Data_Mapping__c
                WHERE Field_API_Name__c IN :pageNames
                AND Order__c != null ORDER BY Order__c NULLS LAST, Label__c];
    }

    /**
     * method to get attribute labels using filter ids for ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Attributes_Labels__c> getAttributeLabels1(Set<String> filterIds) {
        return [SELECT Id, Label__c, Attribute__c, Attribute__r.Name, Label__r.Filter_no__c
                FROM Attributes_Labels__c
                WHERE Label__c IN :filterIds];
    }
    
    /**
     * method to get root level attributes for ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Attribute__c> getRootLevelAttributes(Set<String> attMappingsAccount) {
        return [SELECT Level__c, Name, Attribute_Mapping__r.Field_Api_Name__c, Attribute_Mapping__r.Object__c,
                Attribute_Mapping__r.Is_Related_Mapping__c,
                (SELECT Id, Name, Level__c, Product_ID__c FROM Attributes__r WHERE Level__c = 1)
                FROM Attribute__c WHERE Level__c = 0
                AND Attribute_Mapping__c IN :attMappingsAccount];
    }
    
    /**
     * method to get account and opportunity attribute mappings for ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Attribute_Mapping__c> getAccAndOppAttMappings() {
        return [SELECT Object__c, Id, Related_Object__c, Is_Related_Mapping__c,
                Filter_Label_Name__c, Field_Api_Name__c, Field__c, 
                Attribute_Name__c, Is_Related_MultiSelectPicklist__c
                FROM Attribute_Mapping__c 
                WHERE (Object__c = :ConstantsController.ACCOUNT
                    OR Object__c = :ConstantsController.OPPORTUNITY)];
    }
    
    /**
     * method to get data mappings for pre filter on ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Data_Mapping__c> getDataMappingsForPreFilter() {
        return [SELECT Visible__c, Label__c, Field_API_Name__c
                FROM Data_Mapping__c
                WHERE Object__c = 'SmartSearchFilter'
                AND Visible__c = true ORDER BY Label__c];
    }
    
    /**
     * method to get oportunity for pre filter on ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Opportunity> getOppForPreFilter(String oppQuery, String opportunityId) {
        return Database.query(String.escapeSingleQuotes(oppQuery));
    }
    
    /**
     * method to get stage stage filter id
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Attributes_Labels__c> getStageFilterId(String attributeId) {
        return [SELECT Label__c FROM Attributes_Labels__c WHERE Attribute__c = :attributeId];
    } 

    /**
     * method to get Opportunity from Account ids
     *
     * author: Dixita (March, 2019)
     */
    public static List<Opportunity> getOpp(String oppQuery, Set<String> accountIds ,String stageCS) {
        return Database.query(String.escapeSingleQuotes(oppQuery));
    }
    /**
     * method to get stage attribute object
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Attribute__c> getStageAttribute() {
        return [SELECT Id, (SELECT Id FROM Attributes__r LIMIT 1)
                FROM Attribute__c
                WHERE Attribute_Mapping__r.Is_Related_Mapping__c = false
                AND Attribute_Mapping__r.Field_Api_Name__c = 'StageName'
                AND Attribute_Mapping__r.Object__c = 'Opportunity'
                AND Level__c = 0];
    }
    
    /**
     * method to get user mappings for column selector on ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<User_Mapping__c> getUserMappingForColumnSelector() {
        return [SELECT Id, Visible__c, Default_Value__c, User__c, Label__c, Field_API_Name__c, Order__c
                FROM User_Mapping__c
                WHERE Process__c = 'Column Selector'
                AND User__c = :UserInfo.getUserId() ORDER BY Order__c];
    }
    
    /**
     * method to get referenceability types for ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Referenceability_Type__c> getRefTypes() {
        return [SELECT Name, Id, Referenceability_no__c
                FROM Referenceability_Type__c
                WHERE Visible__c = true AND Referenceability_Type__c = true
                AND Sales_Reward__c = false
                ORDER BY Name LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get attribute labels for ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Attributes_Labels__c> getAttributeLabels(String filterId) {
        return [SELECT Name, Label__c, Id, Label__r.Filter_no__c, Attribute__c, Attribute__r.Name
                FROM Attributes_Labels__c
                WHERE Label__c = :filterId
                AND Attribute__c != null
                ORDER BY Attribute__r.Name
                LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get attribute mappings for ref search
     *
     * author: Gaurav Saini (21 March, 2017)
     */
    public static List<Attribute_Mapping__c> getAttributeMappings(Set<String> mappingIds) {
        return [SELECT Id FROM Attribute_Mapping__c WHERE Id IN :mappingIds AND Inheritable__c = true];
    }
    
    /**
     * method to update reference lead for reference lead form
     *
     * author: Gaurav Saini (20 March, 2017)
     */
    public static Reference_Lead__c updateRefLead(Reference_Lead__c referenceLead) {
        update referenceLead;
        return referenceLead;
    }
    
    /**
     * method to insert reference lead attributes for reference lead form
     *
     * author: Gaurav Saini (20 March, 2017)
     */
    public static void insertRefLeadReferenceabilities(List<ReferenceLeadReferenceability__c> refiRefTypeList) {
        insert refiRefTypeList;
    }
    
    /**
     * method to insert reference lead attributes for reference lead form
     *
     * author: Gaurav Saini (20 March, 2017)
     */
    public static void insertRefLeadAttributes(List<ReferenceLeadAttributes__c> refLeadFilterAttList) {
        insert refLeadFilterAttList;
    }
    
    /**List<ReferenceLeadAttributes__c> refLeadFilterAttList
     * method to insert reference lead filters for reference lead form
     *
     * author: Gaurav Saini (20 March, 2017)
     */
    public static void insertRefLeadFilters(List<ReferenceLeadFilter__c> referenceLeadFilterList) {
        insert referenceLeadFilterList;
    }
    
    /**
     * method to get related ref contents for accounts using ref content ids
     *
     * author: Gaurav Saini (20 March, 2017) for #786
     */
    public static List<Account_Reference_Content__c> getARCForAccounts2(Set<String> refContentIds) {
        return [SELECT Reference_Content__c, Account__c FROM Account_Reference_Content__c
                WHERE Reference_Content__c IN :refContentIds];
    }
    
    /**
     * method to get related ref contents for accounts using account ids
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Account_Reference_Content__c> getARCForAccounts1(Set<String> accountIds) {
        return [SELECT Reference_Content__c, Account__c FROM Account_Reference_Content__c
                WHERE Account__c IN :accountIds];
    }
    
    /**
     * method to get contacts using account ids
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Contact> getContactsForAccounts(Set<String> accountIds) {
        return [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds];
    }
    
    /**
     * method to get filters for ref search lightning
     *
     * author: Gaurav Saini (17 March, 2017) for #786 REF-2366 -limit and labelName
     */
    public static List<Label__c> getFilters1(Set<String> filterIds) {
        return [SELECT Id, (SELECT Name, Label__c, Id, Label__r.Name, Label__r.Filter_no__c, Attribute__c, Attribute__r.Name
                    FROM Attributes_Labels__r WHERE Attribute__c != null ORDER BY Attribute__r.Name LIMIT 201)
                FROM Label__c WHERE Id IN :filterIds LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get filters for ref search lightning
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Label__c> getFilters() {
        return [SELECT Id, Name, BasicSearchView__c, Filter_no__c, Filter_RefSearch_Visible__c
                FROM Label__c ORDER BY Name LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get data mappings for ref search lightning
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Data_Mapping__c> getDataMappings() {
        return [SELECT Name, Order__c, Id, Visible__c, Required__c, Filter_RefSearch_Visible__c,
                Label__c, From_Mapping__c, Field_API_Name__c
                FROM Data_Mapping__c
                WHERE Object__c = 'Filter' AND Filter_RefSearch_Visible__c = true
                AND Order__c != null ORDER BY Order__c, Label__c];
    }
    
    /**
     * method to get data mappings for ref search lightning, here the data mappings have order = null
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Data_Mapping__c> getDataMappings1() {
        return [SELECT Name, Order__c, Id, Visible__c, Required__c, Filter_RefSearch_Visible__c,
                Label__c, From_Mapping__c, Field_API_Name__c
                FROM Data_Mapping__c
                WHERE Object__c = 'Filter' AND Filter_RefSearch_Visible__c = true
                AND Order__c = null ORDER BY Label__c];
    }
    
    /**
     * method to get user mappings for ref search lightning
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<User_Mapping__c> getUserMappings() {
        return [SELECT Order__c, Visible__c, Field_API_Name__c, User__c, Label__c FROM User_Mapping__c
                WHERE Process__c = 'My Filters' AND User__c = :UserInfo.getUserId()
                AND Visible__c = true ORDER BY Order__c];
    }
    
    /**
     * method to get content collection for ref search lightning
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Content_Collection__c> getContentCollections() {
        return [SELECT Collection__c, Id, (SELECT Reference_Content__c FROM Related_Reference_Contents__r
                    WHERE Reference_Content__r.Content_Status__c != 'Inactive'
                    AND Reference_Content__r.Content_Status__c != '')
                FROM Content_Collection__c WHERE Active__c = true ORDER BY Collection__c
                LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get ref contents for text search on ref search lightning
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Reference_Content__c> getRefContentForTextSearch(Set<String> contentIds,
                                                List<Reference_Content__c> listReferenceContent) {
        return [SELECT Id, Name, Content_ID__c FROM Reference_Content__c
                WHERE (Content_ID__c IN :contentIds
                    OR Id IN :listReferenceContent)
                ORDER BY Title__c];
    }
    
    /**
     * method to get total number of active ref contents for ref search lightning
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static Integer getRefContentsCount(Boolean featuredChecked, Boolean isFilterAppiled, String shareableValue,
                                Set<String> alreadyDisplayedContents, Set<String> filteredContents) {
        
        if (featuredChecked) {
            
            if (isFilterAppiled) {
                
                if (shareableValue == 'Internal') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Internal_Use__c = true
                                            AND Featured_Content__c = true
                                            AND Id IN :filteredContents
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else if (shareableValue == 'Shareable') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Internal_Use__c = false
                                            AND Featured_Content__c = true
                                            AND Id IN :filteredContents
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Featured_Content__c = true
                                            AND Id IN :filteredContents
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                }
            } else {
                
                if (shareableValue == 'Internal') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Internal_Use__c = true
                                            AND Featured_Content__c = true
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else if (shareableValue == 'Shareable') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Internal_Use__c = false
                                            AND Featured_Content__c = true
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Featured_Content__c = true
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                }
            }
        } else {
            
            if (isFilterAppiled) {
                
                if (shareableValue == 'Internal') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Id IN :filteredContents
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND Internal_Use__c = true
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else if (shareableValue == 'Shareable') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Id IN :filteredContents
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND Internal_Use__c = false
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Id IN :filteredContents
                                            AND Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                }
            } else {
                
                if (shareableValue == 'Internal') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Id NOT IN :alreadyDisplayedContents
                                            AND Internal_Use__c = true
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else if (shareableValue == 'Shareable') {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Id NOT IN :alreadyDisplayedContents
                                            AND Internal_Use__c = false
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '')][0].get('expr0'));
                } else {
                    return Integer.valueOf([SELECT COUNT(Id) FROM Reference_Content__c
                                            WHERE Id NOT IN :alreadyDisplayedContents
                                            AND (Content_Status__c != 'Inactive'
                                                AND Content_Status__c != '') ][0].get('expr0'));
                }
            }
        }
    }
    
    /**
     * method to get contacts for text search on ref search lightning
     *
     * author: Gaurav Saini (16 March, 2017) for #786
     */
    public static List<Contact> getContactsForTextSearch(Set<String> activeAccountIds, Set<String> alreadyDisplayedContactIds,
                                                            Set<String> searchedContactIds, Set<String> filterdAccounts) {
        return [SELECT Id FROM Contact
                WHERE Id IN :activeAccountIds
                AND Id NOT IN :alreadyDisplayedContactIds
                AND Id NOT IN :searchedContactIds
                AND AccountId IN :filterdAccounts ORDER BY Name];
    }
    
    
    
    /**
     * method to get active account RBIs for ref search lightning using dynamic soql query
     *
     * author: Gaurav Saini (16 March, 2017) for #786
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsUsingSOQL(String dynamicSOQL, Set<String> filteredAccounts,
                                                            Set<String> alreadydisplayedaccountIds) {
        return Database.query(dynamicSOQL);
    }
    
    /**
     * method to get active account RBIs for ref search lightning using dynamic soql query
     *
     * author: Gaurav Saini (17 March, 2017) for #786
     */
    public static List<Reference_Basic_Information__c> getContactRBIsUsingSOQL(String dynamicSOQL, Set<String> filteredContacts,
                                                            Set<String> alreadyDisplayedContactIds) {
        return Database.query(dynamicSOQL);
    }
    
    /**
     * method to get active account RBIs for ref search lightning using sosl query
     *
     * author: Gaurav Saini (16 March, 2017) for #786
     */
    public static List<List<SObject>> getAccountRBIsUsingSOSL(String rbiSOSLQuery, Set<String> activeAccountIds,
                                                            Set<String> alreadydisplayedaccountIds) {
        return search.query(rbiSOSLQuery);
    }
    
    /**
     * method to get total number of active account RBIs for ref search lightning
     *
     * author: Gaurav Saini (16 March, 2017) for #786
     */
    public static Integer getAccountRBIsCount(Boolean isFilterAppiled, Set<String> filteredAccounts,
                                            Set<String> alreadydisplayedaccountIds, String refStatus) {
        Integer result = 0;

        if (refStatus == 'Active') {

            if (isFilterAppiled) {
                result = Integer.valueOf([SELECT COUNT_DISTINCT(Id) FROM Reference_Basic_Information__c
                                        WHERE Account__c IN :filteredAccounts
                                        AND Account__c NOT IN :alreadydisplayedaccountIds
                                        AND Contact__c = null
                                        AND Is_Referenceable__c = true
                                        AND (Referenceability_Status__c != 'Inactive' 
                                            AND Referenceability_Status__c != '')][0].get('expr0'));
            } else {
                result = Integer.valueOf([SELECT COUNT_DISTINCT(Id) FROM Reference_Basic_Information__c
                                        WHERE Account__c NOT IN :alreadydisplayedaccountIds 
                                        AND contact__c = null
                                        AND Is_Referenceable__c = true
                                        AND (Referenceability_Status__c != 'Inactive' 
                                            AND Referenceability_Status__c != '')][0].get('expr0'));
            }
        } else if (refStatus == 'Inactive') {

            if (isFilterAppiled) {
                result = Integer.valueOf([SELECT COUNT_DISTINCT(Id) FROM Reference_Basic_Information__c
                                        WHERE Account__c IN :filteredAccounts
                                        AND Account__c NOT IN :alreadydisplayedaccountIds
                                        AND Contact__c = null
                                        AND Is_Referenceable__c = true
                                        AND Referenceability_Status__c = 'Inactive'][0].get('expr0'));
            } else {
                result = Integer.valueOf([SELECT COUNT_DISTINCT(Id) FROM Reference_Basic_Information__c
                                        WHERE Account__c NOT IN :alreadydisplayedaccountIds 
                                        AND contact__c = null
                                        AND Is_Referenceable__c = true
                                        AND Referenceability_Status__c = 'Inactive'][0].get('expr0'));
            }
        } else if (refStatus == 'Candidate') {

            if (isFilterAppiled) {
                result = Integer.valueOf([SELECT COUNT_DISTINCT(Id) FROM Reference_Basic_Information__c
                                        WHERE Account__c IN :filteredAccounts
                                        AND Account__c NOT IN :alreadydisplayedaccountIds
                                        AND Contact__c = null
                                        AND Reference_Program_Candidate__c = true][0].get('expr0'));
            } else {
                result = Integer.valueOf([SELECT COUNT_DISTINCT(Id) FROM Reference_Basic_Information__c
                                        WHERE Account__c NOT IN :alreadydisplayedaccountIds 
                                        AND contact__c = null
                                        AND Reference_Program_Candidate__c = true][0].get('expr0'));
            }
        }
        return result;
    }
    
    /**
     * method to get total number of active contact RBIs for ref search lightning
     *
     * author: Gaurav Saini (16 March, 2017) for #786
     */
    public static Integer getContactRBIsCount(Boolean isFilterAppiled, Set<String> filteredContacts,
                                            Set<String> alreadyDisplayedContactIds, String refStatus) {
        Integer result = 0;

        if (refStatus == 'Active') {
            
            if (isFilterAppiled) {
                result = Integer.valueOf([SELECT COUNT(Id) FROM Reference_Basic_Information__c
                                        WHERE Contact__c IN :filteredContacts
                                        AND Contact__c NOT IN :alreadyDisplayedContactIds
                                        AND Contact__c != null
                                        AND Is_Referenceable__c = true 
                                        AND (Referenceability_Status__c != 'Inactive'
                                            AND Referenceability_Status__c != '' AND Account__c != null)][0].get('expr0'));
            } else {
                result = Integer.valueOf([SELECT COUNT(Id) FROM Reference_Basic_Information__c
                                        WHERE Contact__c NOT IN :alreadyDisplayedContactIds 
                                        AND Contact__c != null
                                        AND Is_Referenceable__c = true
                                        AND (Referenceability_Status__c != 'Inactive' 
                                            AND Referenceability_Status__c != '')
                                        AND Account__c != null][0].get('expr0'));
            }
        } else if (refStatus == 'Inactive') {
            
            if (isFilterAppiled) {
                result = Integer.valueOf([SELECT COUNT(Id) FROM Reference_Basic_Information__c
                                        WHERE Contact__c IN :filteredContacts
                                        AND Contact__c NOT IN :alreadyDisplayedContactIds
                                        AND Contact__c != null
                                        AND Is_Referenceable__c = true 
                                        AND Referenceability_Status__c = 'Inactive'
                                        AND Account__c != null][0].get('expr0'));
            } else {
                result = Integer.valueOf([SELECT COUNT(Id) FROM Reference_Basic_Information__c
                                        WHERE Contact__c NOT IN :alreadyDisplayedContactIds 
                                        AND Contact__c != null
                                        AND Is_Referenceable__c = true
                                        AND Referenceability_Status__c = 'Inactive' 
                                        AND Account__c != null][0].get('expr0'));
            }
        } else if (refStatus == 'Candidate') {
            
            if (isFilterAppiled) {
                result = Integer.valueOf([SELECT COUNT(Id) FROM Reference_Basic_Information__c
                                        WHERE Contact__c IN :filteredContacts
                                        AND Contact__c NOT IN :alreadyDisplayedContactIds
                                        AND Contact__c != null
                                        AND Reference_Program_Candidate__c = true
                                        AND Account__c != null][0].get('expr0'));
            } else {
                result = Integer.valueOf([SELECT COUNT(Id) FROM Reference_Basic_Information__c
                                        WHERE Contact__c NOT IN :alreadyDisplayedContactIds 
                                        AND Contact__c != null
                                        AND Is_Referenceable__c = true
                                        AND Reference_Program_Candidate__c = true
                                        AND Account__c != null][0].get('expr0'));
            }
        }
        return result;
    }
    
    /**
     * method to get active account RBIs for ref search lightning
     *
     * author: Gaurav Saini (16 March, 2017) for #786
     */
    public static List<Reference_Basic_Information__c> getAccountRBIs() {
        return [SELECT Account__c FROM Reference_Basic_Information__c
                WHERE Contact__c = null
                AND Is_Referenceable__c = true
                AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                    AND Referenceability_Status__c != '')
                AND Account__c != null LIMIT 49999];
    }
    
    /**
     * method to get active contact RBIs for ref search lightning
     *
     * author: Gaurav Saini (16 March, 2017) for #786
     */
    public static List<Reference_Basic_Information__c> getContactRBIs() {
        return [SELECT Contact__c, Account__c FROM Reference_Basic_Information__c
                WHERE Contact__c != null
                AND Is_Referenceable__c = true
                AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                    AND Referenceability_Status__c != '')
                AND Account__c != null LIMIT :49999];
    }
    
    /**
     * method to get related mapping filtered records for refsearchblock controller
     * 
     * author: Gaurav Saini (6 March, 2017)
     */
    public static List<sObject> getFilteredRecords(Set<String> selectedValues, String query) {
        return Database.query(query);
    }
    
    /**
     * method to get related mapping filtered records for refsearchblock controller
     * 
     * author: Gaurav Saini (6 March, 2017)
     */
    public static List<sObject> getFilteredRecords1(Set<String> relatedObjectIds, String query) {
        return Database.query(query);
    }
    
    /**
     * method to get account records along with their RBIs
     * author: Gaurav Saini (3 March, 2017) for #769
     */
    public static List<Account> getAccountAndRBI(Set<String> accIds) {
        return [SELECT Id, Name, (SELECT Reference_Program_Candidate__c, Is_Referenceable__c,
                    Referenceability_Status__c, Generic_Account__c
                    FROM Reference_Basic_Informations__r WHERE Contact__c = null)
                FROM Account WHERE Id IN :accIds];
    }
    
    /**
     * method to get referenceability types list for Issue reward page
     * author: Rajesh (01 March, 2017) for #759
     */
    public static List<Referenceability_Type__c> getRefTypesList(Boolean isSalesUser) {
        
        if (isSalesUser) {
            return [SELECT Name, Id, Sales_Point__c
                    FROM Referenceability_Type__c
                    WHERE Visible__c = true AND Sales_Reward__c = true
                    AND Sales_Point__c != null
                    ORDER BY Name
                    LIMIT :limits.getLimitQueryRows()];
        } else {
            return [SELECT Name, Id, Reward_points__c
                    FROM Referenceability_Type__c
                    WHERE Visible__c = true AND Sales_Reward__c = false
                    ORDER BY Name
                    LIMIT :limits.getLimitQueryRows()];
        }
    }  
    
    /**
     * method to get reference lead records on the basis of ref Id
     * author: Rajesh (01 March, 2017) for #759
     * Last modified by: Gaurav Saini (18 April, 2017) for #5
     */
    public static List<Reference_Lead__c> getReferenceLead(String refLeadId) {
        return [SELECT Reference_Lead_Account__r.Name, Reference_Lead_Status__c,
                Reference_Profile__c, Reference_Lead_Account__c, Nomination__c,
                // changes for #5 - added 2 new fields for opp Name and Id
                Reference_Lead_Opportunity__r.Name, Reference_Lead_Opportunity__c,
                Follow_Up_Timeframe__c, Reference_Lead_Owner__c, Reference_Lead_Owner__r.Name,
                Reference_Lead_Owner__r.Email FROM Reference_Lead__c WHERE Id = :refLeadId];
    }
    
    /**
     * method to get RBI referenceable value on the basis of account Id
     * author: Rajesh (01 March, 2017) for #759
     */
    public static List<Reference_Basic_Information__c> getRBIReferenceable(Id accountId) {
        return [SELECT Is_Referenceable__c FROM Reference_Basic_Information__c WHERE Account__c = : accountId
                AND Contact__C = null];
    }
    
    
    /**
     * method to get attribute mappings to show on ref search page filter section
     * author: Gaurav Saini (27 Feb, 2017) for #746
     */
    public static List<Attribute_Mapping__c> getAttributeMappingsForRefSearch() {  
        return [SELECT Id, field__c, Filter_Label_Name__c, Is_Related_MultiSelectPicklist__c
                FROM Attribute_Mapping__c
                WHERE Is_Related_Mapping__c = true
                AND Object__c != 'Opportunity'
                AND Related_Object__c != 'OpportunityLineItem'];
    }
    
    /**
     * method to get Reference Interview details
     * author: Rajesh (24 Feb, 2017)  
     */ 
    public static List<Reference_Interview__c> getInterviewDetails(String hoverRefContentId) {       
        return [SELECT Transcript__c, Reference_Content__r.Title__c, LastModifiedDate, Photograph__c,
                                    Speaker_info__c, Transcript_Content_Id__c, Org_website__c, Org_description__c, Name,
                                    (SELECT Name, Question__c, Transcript__c, Video_Url_Embed__c, Content_Id__c, Order__c
                                        FROM Interview_Topics__r ORDER BY Order__c)
                                    FROM Reference_Interview__c WHERE Reference_Content__c = : hoverRefContentId];
    }
    
    /**
     * method to get Ref Content Type List
     * author: Rajesh (24 Feb, 2017)  
     */ 
    public static List<Reference_Content_Type__c> getContentTypeList() {         
        return [SELECT Name__c, Active__c, Id FROM Reference_Content_Type__c WHERE Disable_For_Filter__c = false 
                ORDER BY Name__c LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get Ref Type Mapping
     * author: Rajesh (23 Feb, 2017)  
     */ 
    public static List<Reference_Type_Mapping__c> getRefTypeMpping(String refContentId, Set<String> fieldMappingsDelete) {       
        return [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name
                                                        FROM Reference_Type_Mapping__c
                                                        WHERE Reference_Content_Type__c = :refContentId
                                                        AND Name IN : fieldMappingsDelete];
    }

    /**
     * method to get Ref Type Mapping
     * author: Dixita (June, 2018)  
     */ 
    public static List<Reference_Type_Mapping__c> getRefTypeMapping (Set<Id> availableFieldsKeys) {       
        return [SELECT Visible__c, Order__c, Required__c, Reference_Content_Type__c, Name
	                										FROM Reference_Type_Mapping__c
	                										WHERE Reference_Content_Type__c IN :availableFieldsKeys
	                										AND Visible__c = true
	                										ORDER BY Order__c NULLS LAST, Name];
    }
    
    /**
     * method to get Ref Content
     * author: Rajesh (23 Feb, 2017)  
     */ 
    public static List<Reference_Type_Mapping__c> getRefTypeMpping(String refContentId) {        
        return [SELECT Visible__c, Required__c, Reference_Content_Type__c, Name
                                                        FROM Reference_Type_Mapping__c
                                                        WHERE Reference_Content_Type__c = : refContentId
                                                        AND Visible__c = true
                                                        ORDER BY Order__c NULLS LAST, Name];
    }
    
    /**
     * method to get Ref Content
     * author: Rajesh (23 Feb, 2017)  
     */ 
    public static List<Reference_Content__c> getRefContentDetails(String hoverRefContentId) {        
        return [SELECT Title__c, Custom_Reference_Content__c, Reference_Content_Type__r.Name__c,
                                            Reference_Content_Type__r.Recorded_Reference_Type__c, Reference_Content_Type__c,
                                            Ref_Content_Open_Clicks__c, Ref_Content_View_Details_Clicks__c
                                            FROM Reference_Content__c
                                            WHERE Id = : hoverRefContentId];
    }
    
    /**
     * method to get Ref Content
     * author: Rajesh (23 Feb, 2017)
     */
    public static List<ContentVersion> getContentVersionList(String hoverContentId) {
        return [SELECT Id, Title, FileType, ContentUrl, VersionNumber, PositiveRatingCount, ContentDocumentId,
                FirstPublishLocationId, CreatedDate, CreatedById, Description, ContentSize
                FROM ContentVersion
                WHERE Id = :hoverContentId];
    }
    
    /**
     * method to get Ref Content
     * author: Rajesh (23 Feb, 2017) 
     */ 
    public static List<Reference_Content__c> getRefContentList(String hoverRefContentId) {       
        return [SELECT Ref_Content_Open_Clicks__c, Ref_Content_View_Details_Clicks__c
                FROM Reference_Content__c WHERE Id = : hoverRefContentId];
    }
    
    /**
     * method to get Ref Content
     * author: Rajesh (23 Feb, 2017) 
     */ 
    public static List<Reference_Content__c> getRefContentList(Set<String> selectedContentIdSet) {       
        return [SELECT Id, Number_of_Download__c, Content_ID__c, Ref_Content_Open_Clicks__c, Ref_Content_View_Details_Clicks__c
                FROM Reference_Content__c
                WHERE Id IN :selectedContentIdSet ORDER BY Title__c ];
    }
    
    /**
     * method to get Content Attribute
     * author: Rajesh (23 Feb, 2017) 
     */ 
    public static List<Content_Attribute__c> getContentAttribute(Set<Id> attributeTypeIds) {         
        return [SELECT Name, Id, Reference_Content__c, Attribute__c
                FROM Content_Attribute__c
                WHERE Attribute__c IN :attributeTypeIds
                AND (Reference_Content__r.Content_Status__c != : ConstantsController.INACTIVE
                    AND Reference_Content__r.Content_Status__c != '')];
    }
    
    /**
     * method to get Attribute Map
     * author: Rajesh (23 Feb, 2017) 
     */ 
    public static List<Attributes_Labels__c> getAttributeLable(Set<Id> attributeTypeIds) {       
        return [SELECT Label__c, Attribute__c, Attribute__r.Parent__c
                FROM Attributes_Labels__c WHERE Attribute__c IN :attributeTypeIds];
    }
    
    /**
     * method to get Attribute Map
     * author: Rajesh (23 Feb, 2017) 
     */ 
    public static List<Attribute__c> getAttributeMap(Set<Id> attributeTypeIds) {         
        return [SELECT Id FROM Attribute__c WHERE Id IN : attributeTypeIds];
    }
    
    /**
     * method to get Account Reference Content list
     * author: Rajesh (23 Feb, 2017) 
     */
    public static List<Reference_Content__c> getReferenceContent(Set<String> contentIds, List<Reference_Content__c> listReferenceContent) {      
        return [SELECT Id, Name, Content_ID__c FROM Reference_Content__c WHERE (Content_ID__c IN : contentIds 
                                            OR Id IN : listReferenceContent) ORDER BY Title__c];
    }
    
    /**
     * method to get Account Reference Content list
     * author: Rajesh (23 Feb, 2017) 
     */
    public static List<Account_Reference_Content__c> getAccountContent(Set<String> refContentIds, Set<Id> accountIdSet) {        
        return [SELECT Reference_Content__c FROM Account_Reference_Content__c
                WHERE Reference_Content__c NOT IN :refContentIds
                AND Account__c IN :accountIdSet
                ORDER BY Reference_Content__r.Title__c];
    }
    
    /**
     * method to get contentversion map for invitation slds page
     * author: Gaurav Saini (23 Feb, 2017) for #732
     */
    public static Map<Id, ContentVersion> getContentVersionMapForInvitation(Set<String> contentVersionIds) {
        Map<Id, ContentVersion> tempMap = new Map<Id, ContentVersion>([SELECT Id, FileType, ContentSize, Title,
                                                                        LastModifiedDate, ContentDocumentId
                                                                        FROM ContentVersion
                                                                        WHERE Id IN :contentVersionIds
                                                                        LIMIT :limits.getLimitQueryRows()]);
        return tempMap;
    }
    
    /**
     * method to get reference interview records for invitation page
     * author: Gaurav Saini (23 Feb, 2017) for #732
     */
    public static List<Reference_Interview__c> getRefInterviewListForInvitation() {
        return [SELECT Transcript__c, Reference_Content__r.Title__c, Org_website__c, Photograph__c,
                Speaker_info__c, Transcript_Content_Id__c, Name, Org_description__c, Reference_Content__c,
                (SELECT Name, Question__c, Transcript__c, Video_Url_Embed__c, Content_Id__c, Order__c
                    FROM Interview_Topics__r ORDER BY Order__c)
                FROM Reference_Interview__c];
    }
    
    /**
     * method to get reference content records for invitation slds page
     * author: Gaurav Saini (23 Feb, 2017) for #732
     */
    public static List<Reference_Content__c> getRefContentsForInvitation(Set<String> contentIds) {
        return [SELECT Id, Reference_Content_Type_Name__c, Reference_Content_Type__r.Name__c,Custom_Reference_Content__c,
                Title__c, Summary__c, Content_ID__c,
                (SELECT Id, Account__c, Account__r.Name
                    FROM Account_Reference_Contents__r LIMIT 2)
                FROM Reference_Content__c
                WHERE Id IN :contentIds
                ORDER BY Title__c ASC];
    }
    
    /**
     * method to get account RBIs using dynamic SOQL for Ref search page
     * author: Gaurav Saini (23 Feb, 2017) for #732
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsUsingDynamicSOQL(String queryString,
                                                                Set<String> accountIds, Set<String> commonFilterIds) {
        return Database.query(queryString);
    }
    
    /**
     * Method used to get Reference Content feild type
     * author: Rajesh (22 Feb, 2017)
     */
    public static List<Reference_Content_Type_Field__c> getReferenceContentTypeField(String query, String getReferenceContentTypeField) {  
        return Database.query(query + '\''+getReferenceContentTypeField+'\'');
    }

    /**
     * Method used to get Reference Content field type for Multiple RefContents
     * author: Dixita (June, 2018)
     * #REF-1307
     */
    public static Map<Id,Reference_Content_Type_Field__c> getRefContentTypeFields(List<Id> customContentIds,Set<String> customContentFields) {  
        Map<Id,Reference_Content_Type_Field__c> returnList = new Map<Id,Reference_Content_Type_Field__c>();
        String soqlQuery = 'SELECT Id ';
                
        for (String s : customContentFields) {
            soqlQuery += ',' + s;
        }
        soqlQuery += ' FROM Reference_Content_Type_Field__c WHERE Reference_Content__c IN :customContentIds';
        List<Reference_Content_Type_Field__c> dataList = Database.query(soqlQuery);
        
        for (Reference_Content_Type_Field__c record : dataList) {
            returnList.put(record.Reference_Content__c,record);
        }
        return returnList;
    }
    
    /**
     * Method used to get Reference Content with String Set
     * author: Rajesh (22 Feb, 2017)
     */
    public static List<Reference_Content__c> getReferenceContent(String query, Set<String> contentIds) {
        return Database.query(query);
    }
    
    /**
     * Method used to get Reference Content with Set parameters
     * author: Rajesh (22 Feb, 2017)
     */
    public static List<Reference_Content__c> getReferenceContent(String query,Set<String> contentIds, Set<String> commonFilterIds) {  
        return Database.query(query); 
    }
    /**
     * Method used to get Reference Content
     * author: Rajesh (22 Feb, 2017)
     */
    public static List<Reference_Content__c> getReferenceContent(String query) {
        return Database.query(query);
    }
    /**
     * Method used to get Reference Content with Id sets
     * author: Rajesh (22 Feb, 2017)
     */
    public static List<Reference_Content__c> getReferenceContent(String query,Set<Id> idSet) {
        return Database.query(query);
    }
    /**
     * method to get accounts for account section on ref search page
     * author: Gaurav Saini (22 Feb, 2017)
     */
    public static List<Account> getAccountsForRefSearch(Set<Id> idSet) {
        // added reference profile to query for lightning project detail page
        return [SELECT Id,
                (SELECT Name, Reference_Type_Needed__c, Account_Request_Status__c
                    FROM Reference_Request_Accounts__r
                    WHERE Account_Request_Status__c = :ConstantsController.IN_PROGRESS
                    OR Account_Request_Status__c = :ConstantsController.ONHOLD
                    OR Account_Request_Status__c = :ConstantsController.NOT_STARTED
                    ORDER BY Deadline__c DESC),
                (SELECT Id, Reference_Request__c, Released__c FROM Hit_Lists__r),
                (SELECT Id, Reference_Content__c FROM Account_Reference_Contents__r
                    WHERE Reference_Content__r.Content_Status__c = 'Active'),
                (SELECT RUL_Last_Activity_Date__c, Default_Period_Completed_Uses__c
                    FROM Reference_Basic_Informations__r WHERE Account__c != null AND Contact__c = null)
                FROM Account
                WHERE Id IN :idSet LIMIT :idSet.size()];
    }
    
    /**
     * method to get account RBIs for account section on ref search page
     * author: Gaurav Saini (22 Feb, 2017)
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsForRefSearch(Set<Id> idSet) {
        return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name, Account__r.OwnerId,
                RUL_Limit_Reached__c, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, 
                Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                FROM Reference_Basic_Information__c
                WHERE Account__c IN :idSet
                AND Contact__c = null
                ORDER BY Account__r.Name LIMIT :idSet.size()];
    }
    
    /**
     * method to get account RBIs for export from ref search page
     * author: Gaurav Saini (4 Dec, 2017)
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsForRefSearchExport(Set<String> accountIds) {
        return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,
                Referenceability_Status__c, Ref_Profile_Summary__c
                FROM Reference_Basic_Information__c
                WHERE Account__c NOT IN :accountIds
                AND Account__c != null
                AND Contact__c = null
                AND Is_Referenceable__c = true
                AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                    AND Referenceability_Status__c != '')
                AND Contact__c = null
                ORDER BY Account__r.Name LIMIT :Limits.getLimitQueryRows()];
    }
    
    /**
     * method to get account RBIs for account section on ref search page
     * author: Gaurav Saini (22 Feb, 2017)
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsForRefSearch(Set<String> accountIds, String selectedType) {
         
        if (selectedType == 'Active') { 
            return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                    Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                    Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c NOT IN :accountIds
                    AND Account__c != null
                    AND Contact__c = null
                    AND Is_Referenceable__c = true
                    AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                        AND Referenceability_Status__c != '')
                    AND Contact__c = null
                    ORDER BY Account__r.Name LIMIT 2001];
        } else if (selectedType == 'Inactive') {
            return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                    Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                    Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c NOT IN :accountIds
                    AND Account__c != null
                    AND Contact__c = null
                    AND Referenceability_Status__c = :ConstantsController.INACTIVE
                    ORDER BY Account__r.Name LIMIT 2001];
        } else if (selectedType == 'Candidate') {
            return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                    Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                    Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c NOT IN :accountIds
                    AND Account__c != null
                    AND Contact__c = null
                    AND Reference_Program_Candidate__c = true
                    ORDER BY Account__r.Name LIMIT 2001];
        } else {
            return null;
        }
    }
    
    /**
     * method to get account RBIs for account section on ref search page
     * author: Gaurav Saini (22 Feb, 2017)
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsForRefSearch(String selectedType) {
        
        if (selectedType == 'Active') {
            return [SELECT Account__c FROM Reference_Basic_Information__c
                    WHERE Is_Referenceable__c = true
                    AND (Referenceability_Status__c != 'Inactive'
                        AND Referenceability_Status__c != '')
                    AND Account__c != null
                    AND Contact__c = null
                    ORDER BY Account__r.Name
                    LIMIT :limits.getLimitQueryRows()];
        } else if (selectedType == 'Inactive') {
            return [SELECT Account__c FROM Reference_Basic_Information__c
                    WHERE Referenceability_Status__c != 'Inactive'
                    AND Account__c != null
                    AND Contact__c = null
                    ORDER BY Account__r.Name
                    LIMIT :limits.getLimitQueryRows()];
        } else if (selectedType == 'Candidate') {
            return [SELECT Account__c FROM Reference_Basic_Information__c
                    WHERE Reference_Program_Candidate__c = true
                    AND Account__c != null
                    AND Contact__c = null
                    ORDER BY Account__r.Name
                    LIMIT :limits.getLimitQueryRows()];
        } else {
            return null;
        }
    }
    
    /**
     * method to get account RBIs for account section on ref search page
     * author: Gaurav Saini (22 Feb, 2017)
     */
    public static List<List<SObject>> getAccountRBIsForRefSearchUsingSOSL(String selectedType, String inputTextValue,
                                                                Set<String> rbiIds, Set<String> accountIds) {
        String rbiSOSLQuery = '';
        
        if (selectedType == 'Active') {
            rbiSOSLQuery = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING '
                            + UtilityController.appNamespace() + 'Reference_Basic_Information__c(Id, Account__c '
                                + 'WHERE Is_Referenceable__c = true '
                                + 'AND (Referenceability_Status__c != \'Inactive\' '
                                    + 'AND Referenceability_Status__c != \'\') '
                                + 'AND Account__c != null '
                                + 'AND Contact__c = null '
                                + 'AND Account__c IN :rbiIds '
                                + 'AND Account__c NOT IN :accountIds '
                                + 'ORDER BY Account__r.Name)';
        } else if (selectedType == 'Inactive') {
            rbiSOSLQuery = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING '
                            + UtilityController.appNamespace() + 'Reference_Basic_Information__c(Id, Account__c '
                                + 'WHERE Referenceability_Status__c = \'Inactive\' '
                                + 'AND Account__c != null '
                                + 'AND Contact__c = null '
                                + 'AND Account__c IN :rbiIds '
                                + 'AND Account__c NOT IN :accountIds '
                                + 'ORDER BY Account__r.Name)';
        } else if (selectedType == 'Candidate') {
            rbiSOSLQuery = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING '
                            + UtilityController.appNamespace() + 'Reference_Basic_Information__c(Id, Account__c '
                                + 'WHERE Reference_Program_Candidate__c = true '
                                + 'AND Account__c != null '
                                + 'AND Contact__c = null '
                                + 'AND Account__c IN :rbiIds '
                                + 'AND Account__c NOT IN :accountIds '
                                + 'ORDER BY Account__r.Name)';
        }
        
        if (rbiSOSLQuery != '') {
            return search.query(rbiSOSLQuery);
        } else {
            return null;
        }
    }
    
    public static List<List<SObject>> getAccountsForRefsearchUsingSOSL(String inputTextValue, Set<String> rbiIds,
                                                        Set<String> accountIds, Set<String> searchedAccountIds) {
        String accountSOSLQuery = 'FIND \'' + inputTextValue + '*\' IN ALL FIELDS RETURNING Account(Id '
                                        + 'WHERE Id IN :rbiIds '
                                        + 'AND Id NOT IN :searchedAccountIds '
                                        + 'AND Id NOT IN :accountIds)';
        return search.query(accountSOSLQuery);
    }
    
    /**
     * method to get account RBIs for exporting from ref search page
     * author: Gaurav Saini (4 Dec, 2017)
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsForRefSearchExport(Set<String> accountIds, Set<String> commonFilterIds) {
        return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,
                Referenceability_Status__c, Ref_Profile_Summary__c
                FROM Reference_Basic_Information__c
                WHERE Account__c IN :commonFilterIds
                AND Contact__c = null
                AND Account__c NOT IN :accountIds
                AND Is_Referenceable__c = true
                AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                    AND Referenceability_Status__c != '')
                ORDER BY Account__r.Name LIMIT :Limits.getLimitQueryRows()];
    }
    
    /**
     * method to get account RBIs for account section on ref search page
     * author: Gaurav Saini (22 Feb, 2017)
     */
    public static List<Reference_Basic_Information__c> getAccountRBIsForRefSearch(Set<String> accountIds,
                                                        String selectedType, Set<String> commonFilterIds) {
        
        if (selectedType == 'Active') {
            return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                    Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                    Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c IN :commonFilterIds
                    AND Contact__c = null
                    AND Account__c NOT IN :accountIds
                    AND Is_Referenceable__c = true
                    AND (Referenceability_Status__c != :ConstantsController.INACTIVE
                        AND Referenceability_Status__c != '')
                    ORDER BY Account__r.Name LIMIT 2001];
        } else if (selectedType == 'Inactive') {
            return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                    Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                    Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c IN :commonFilterIds
                    AND Contact__c = null
                    AND Account__c NOT IN :accountIds
                    AND Referenceability_Status__c = :ConstantsController.INACTIVE
                    ORDER BY Account__r.Name LIMIT 2001];
        } else if (selectedType == 'Candidate') {
            return [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name,
                    Account__r.OwnerId, Referenceability__c, Reference_Owner__r.Name, Reference_Owner__c,
                    Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c,
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c IN :commonFilterIds
                    AND Contact__c = null
                    AND Account__c NOT IN :accountIds
                    AND Reference_Program_Candidate__c = true
                    ORDER BY Account__r.Name LIMIT 2001];
        } else {
            return null;
        }
    }
    
    /**
     * method to get hit list records for ReminderActionPage
     * author: Gaurav Saini (20 Feb, 2017) for #732
     */
    public static List<Hit_List__c> getHitList(String hitListId) {
        return [SELECT Account__r.Name, Account__c, Contact__c, Contact__r.Name, Reference_Request__c,Released__c
                FROM Hit_List__c
                WHERE Id = :hitListId];
    }
    
    /**
     * method to insert Invitation_ReferenceContent__c records
     * (called from createInvitation method in InvitationSLDSController)
     *
     * author: Gaurav Saini (13 Feb, 2017)
     */
    public static void insertIRCList(List<Invitation_ReferenceContent__c> IRCList) {
        insert IRCList;
    }
    
    /**
     * method to get feed items
     * (created for #626)
     * author: Gaurav Saini (15 Dec, 2016)
     */
    public static List<FeedItem> getFeedItems(List<String> feedItemIds) {
        return [SELECT Id, ParentId
                    FROM FeedItem
                    WHERE Id IN :feedItemIds];
    }
    
    /**
     * method to insert feed comments on respective chatter posts
     * (created for #626)
     * author: Gaurav Saini (13 Dec, 2016)
     * Last Modified by : Rajesh for REF-1362
     */
    public static void insertFeedComments(List<sObject> feedCommentList) { 
    	List<sObject> existFeedCommentList = new List<sObject>();
    	Set<String> feedIds = new Set<String>();  
    	
    	for (sObject feedDetails : feedCommentList) {
    		feedIds.add(String.valueOf(feedDetails.get('FeedItemId'))); 
    	}  	
    	Map<Id, sObject> mapFeed = new Map<Id, sObject>([SELECT Id, Title FROM FeedItem WHERE Id IN :feedIds LIMIT :limits.getLimitQueryRows()]);
        
        for (sObject feedDetails : feedCommentList) {
         
       	if (mapFeed.containsKey(String.valueOf(feedDetails.get('FeedItemId')))) {
        		existFeedCommentList.add(feedDetails);
        	} 
    	}
    													
    	if (existFeedCommentList.size() > 0) {
    		insert existFeedCommentList;
    	}          
     }
    
    /**
     * method to insert task records from map values
     * author: Gaurav Saini (1 Aug, 2017)
     */
    public static Map<String, Task> insertTaskMap(Map<String, Task> taskMap) {
        insert taskMap.values();
        return taskMap;
    }
    
    /**
     * method to insert feed items FROM map AND return the map
     * 
     * author: Gaurav Saini (13 Dec, 2016)
     */
    public static Map<String, sObject> insertPostFeedItemsMap(Map<String, sObject> feedItemRRAMap) {
        insert feedItemRRAMap.values();
        return feedItemRRAMap;
    }
    
    public static Map<String, Set<sObject>> insertPostFeedItemsMap(Map<String, Set<sObject>> feedItemRRAMap) {
        Map<String, Set<sObject>> tempMap = new Map<String, Set<sObject>>();
        List<sObject> tempFeedItemList = new List<sObject>();
        Map<String, Set<sObject>> resultMap = new Map<String, Set<sObject>>();
        
        for (String rraId : feedItemRRAMap.keySet()) {
            
            for (sObject fi : feedItemRRAMap.get(rraId)) {
                tempFeedItemList.add(fi);
            }
            resultMap.put(rraId, new Set<sObject>());
        }
        
        if (tempFeedItemList != null && tempFeedItemList.size() > 0) {
            insert tempFeedItemList;
        }
        
        for (sObject fi1 : tempFeedItemList) {
            
            if (fi1.get('LinkUrl') != null && fi1.get('LinkUrl') != '' && String.valueOf(fi1.get('LinkUrl')).contains('id=')) {
                
                if (resultMap.containsKey(String.valueOf(fi1.get('LinkUrl')).split('id=')[1])) {
                    resultMap.get(String.valueOf(fi1.get('LinkUrl')).split('id=')[1]).add(fi1);
                }
            }
        }
        return resultMap;
        /*
        insert feedItemRRAMap.values();
        return feedItemRRAMap;
        */
    }
    
    /**
     * method to get list of attributes related to products
     * Created By : Rekha Jangir @Dec/9/2016
     */
    public static List<Attribute__c> getProductAttributes(Set<Id> products) {
        return [SELECT Id, Product_ID__c, Name FROM Attribute__c WHERE Product_ID__c IN : products LIMIT: Limits.getLimitQueryRows()];
    }
    
    /**
     * method to update Attributes
     * Created By : Rekha Jangir @Dec/9/2016
     */
    public static List<Attribute__c> updateAttributes(List<Attribute__c> atts){
        update atts;
        return atts;
    }
    
    /**
     * method to get list of custom settings using dynamic SOQL query
     * 
     * author: Gaurav Saini (5 Dec, 2016)
     */
    public static List<Custom_Settings__c> getCustomSettings1(String query) {
        return Database.query(query);
    }
    
    /**
     * method to get ref content map for after undelete trigger on content attribute object
     * 
     * author: Gaurav Saini (1 Dec, 2016)
     */
    public static Map<Id, Reference_Content__c> getRefContentMap(Set<Id> contentIds) {
        return new Map<Id, Reference_Content__c>([SELECT Id, Attributes__c FROM Reference_Content__c
                                                    WHERE Id IN :contentIds]);
    }
    
    /**
     * method to upsert reference contents for after insert trigger on content attribute object
     * 
     * author: Gaurav Saini (1 Dec, 2016)
     */
    public static List<Attribute__c> getAttributesList(Set<String> attributeIds) {
        return [SELECT Id, ParentIds__c, Level__c FROM Attribute__c WHERE Id IN :attributeIds];
    }
    
    /**
     * method to upsert reference contents for after insert trigger on content attribute object
     * 
     * author: Gaurav Saini (1 Dec, 2016)
     */
    public static List<Account> getAccountsList(Set<Id> contentIds, Set<Id> accountIds) {
        return [SELECT Id, (SELECT Attribute__c, Account__c
                        FROM Account_Attributes__r
                        WHERE Reference_Content__c IN :contentIds),
                    (SELECT Account__c, Referenceability_Status__c, Is_Referenceable__c
                        FROM Reference_Basic_Informations__r
                        WHERE Contact__c = null)
                    FROM Account WHERE Id IN :accountIds];
    }
    
    /**
     * method to upsert reference contents for after insert trigger on content attribute object
     * 
     * author: Gaurav Saini (1 Dec, 2016)
     */
    public static void upsertRefContentList(List<Reference_Content__c> refContentList) {
        upsert refContentList;
    }
    
    /**
     * method to get reference contents for after insert trigger on content attribute object
     * 
     * author: Gaurav Saini (1 Dec, 2016)
     */
    public static List<Reference_Content__c> getRefContentList(Set<Id> contentIds) {
        return [SELECT Id, Attributes__c, Attribute_Ids__c, Content_Status__c, Title__c,
                    (SELECT Id, Account__c, Reference_Content__c
                        FROM Account_Reference_Contents__r
                        WHERE Reference_Content__r.Content_Status__c != :ConstantsController.INACTIVE),
                    (SELECT Reference_Content__c, Attribute__c, Attribute__r.Name, Account__c
                        FROM Content_Attributes__r)
                    FROM Reference_Content__c
                    WHERE Id IN :contentIds];
    }
    
    /**
     * method to get guest user list
     * 
     * author: Gaurav Saini (23 Nov, 2016)
     */
    public static List<User> getGuestUserList() {
        return [SELECT UserType, Name, Id FROM User WHERE UserType = 'Guest'];
    }
    
    /**
     * method to get number of enqueued batches for schedulars
     * 
     * author: Gaurav Saini (23 Nov, 2016)
     */
    public static Integer getEnqueuedJobsCountForSchedulars() {
        return [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'BatchApex'
                AND Status IN('Processing', 'Preparing', 'Queued')];
    }
    
    /**
     * method to get redeemed rewards for Batch_ResetContactRewardPoints
     * 
     * author: Gaurav Saini (23 Nov, 2016)
     */
    public static List<Reward__c> getRewardsForResetContactPointsBatch() {
        return [SELECT Amount__c, Contact__c, Available_Points__c, Expired_Points__c, Expiration_Date__c,
                    Expired__c, Transaction__c
                    FROM Reward__c
                    WHERE Contact__c != null];
    }
    
    /**
     * method to get contact RBIs for Batch_ResetContactRewardPoints
     * 
     * author: Gaurav Saini (23 Nov, 2016)
     */
    public static List<Reference_Basic_Information__c> getRBIsForResetContactPointsBatch() {
        return [SELECT Id, Contact__c, Current_Available_Balance_Points__c, Lifetime_Points__c
                    FROM Reference_Basic_Information__c
                    WHERE Contact__c != null
                    LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get redeemed rewards for Batch_ResetContactRewardPoints
     * 
     * author: Gaurav Saini (23 Nov, 2016)
     */
    public static List<Reward__c> getRedeemedRewardsForResetContactPointsBatch() {
        return [SELECT Id, Available_Points__c FROM Reward__c WHERE Transaction__c = 'Redeem'];
    }
    
    /**
     * method to get opportunity line items for checkForAttributeMapping method of RBITriggerHandler
     * 
     * author: Gaurav Saini (22 Nov, 2016)
     */
    public static List<OpportunityLineItem> getOppLineItemsForUpdateRBI(String lineItemsQuery, Set<String> referenceAccountIds, decimal amount) {
        return Database.query(lineItemsQuery);
    }
    
    /**
     * method to get hit list for onAfterDelete method of ReferenceRequestTriggerHandler
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reference_Requests_and_Invitations__c> getRRIList() {
        return [SELECT Id FROM Reference_Requests_and_Invitations__c
                    WHERE Invitation__c = null
                    AND Reference_Request__c = null];
    }
    
    /**
     * method to get hit list for onAfterDelete method of ReferenceRequestTriggerHandler
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Hit_List__c> getHitLists(List<Hit_List__c> hitLists) {
        return [SELECT Id,Released__c FROM Hit_List__c WHERE Id IN :hitLists];
    }
    
    /**
     * method to delete request invitations for onAfterUpdate method of ReferenceRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (18 Nov, 2016)
     */
    public static void deleteRefRequestInvitations(List<Reference_Requests_and_Invitations__c> oldRRIList) {
        delete oldRRIList;
    }
    
    /**
     * method to insert request invitations for onAfterUpdate method of ReferenceRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (18 Nov, 2016)
     */
    public static void insertRefRequestInvitations(List<Reference_Requests_and_Invitations__c> newRRIList) {
        insert newRRIList;
    }
    
    /**
     * method to get request invitations for onAfterUpdate method of ReferenceRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (18 Nov, 2016)
     */
    public static List<Reference_Requests_and_Invitations__c> getRefRequestInvitations(Set<Id> oldInvitationIds) {
        return [SELECT Id FROM Reference_Requests_and_Invitations__c
                    WHERE Invitation__c IN :oldInvitationIds];
    }
    
    /**
     * method to get account request for onAfterUpdate method of ReferenceRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (18 Nov, 2016)
     */
    public static List<Reference_Request__c> getReferenceRequests1(List<Reference_Request__c> newReferenceRequests) {
        return [SELECT Id, (SELECT Account_Request_Status__c FROM Reference_Request_Accounts__r),
                    (SELECT Unspecified_Request_Status__c FROM Unspecified_Requests__r)
                    FROM Reference_Request__c
                    WHERE Id IN :newReferenceRequests];
    }
    
    /**
     * method to get account request for onBeforeDelete method of ReferenceRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (18 Nov, 2016)
     */
    public static List<Reference_Request_Account__c> getAccountRequests2(Map<Id, Reference_Request__c> oldReferenceRequestMap) {
        return [SELECT Id, (SELECT Id FROM Rewards__r), (SELECT Id FROM Hit_Lists__r)
                    FROM Reference_Request_Account__c
                    WHERE Reference_Request__c IN :oldReferenceRequestMap.keySet()];
    }
    
    /**
     * method to get account request for updateAccountDetails method
     * called in after delete of RRAccountTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (18 Nov, 2016)
     */
    public static List<Reference_Request_Account__c> getAccountRequests1(Set<Id> accountIds) {
        return [SELECT Account__c, Activity_Date__c, Account_Request_Status__c, Id
                    FROM Reference_Request_Account__c
                    WHERE Account__c IN :accountIds
                    AND ((Account_Request_Status__c = 'Completed'
                            AND Approval_Status__c != :ConstantsController.DECLINED)
                        OR Account_Request_Status__c = :ConstantsController.NO_LONGER_NEEDED)];
    }
    
    /**
     * method to get account RBIs for updateAccountDetails method
     * called in after delete of RRAccountTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static List<Reference_Basic_Information__c> getAccountReferenceProfiles(Set<Id> accountIds) {
        return [SELECT Id, Name, Account__c, Is_Referenceable__c, Referenceability_Status__c, RUL_Period__c,
                    Default_Period_Completed_Uses__c, RUL_Limit_Reached__c, RUL_Last_Updated_By__c, Reference_Program_Candidate__c,
                    RUL_Last_Activity_Date__c, RUL_Date_Available__c, RUL_Activities_will_do__c, RUL_Activities_used__c
                    FROM Reference_Basic_Information__c
                    WHERE Contact__c = null AND Generic_Account__c = false
                    AND Account__c != null
                    AND Account__c IN :accountIds];
    }
    
    /**
     * method to get contact requests for onAfterDelete method of RRAccountTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static void deleteContactRequestList(List<Reference_Request_Account_Contact__c> contactRequestList) {
        delete contactRequestList;
    }
    
    /**
     * method to get contact requests for onAfterDelete method of RRAccountTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static List<Reference_Request_Account_Contact__c> getContactRequestList(Set<Id> contactRequestIds) {
        return [SELECT Id FROM Reference_Request_Account_Contact__c WHERE Id IN :contactRequestIds];
    }
    
    /**
     * method to get account requests for onBeforeDelete method of RRAccountTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static List<Reward__c> getRewardList(Set<Id> rewardIds) {
        return [SELECT Id FROM Reward__c WHERE Id IN :rewardIds];
    }
    
    /**
     * method to get account requests for onBeforeDelete method of RRAccountTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static List<Reference_Request_Account__c> getRefRequestList(Map<Id, Reference_Request_Account__c> oldAccountRequestMap) {
        return [SELECT Id, (SELECT Id FROM Rewards__r),
                    (SELECT Id FROM Reference_Request_Account_Contacts__r)
                    FROM Reference_Request_Account__c
                    WHERE Id IN :oldAccountRequestMap.keySet()];
    }
    
    /**
     * method to get reference requests for onAfterUpdate method of UnspecifiedRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static List<Reference_Request__c> getRefRequestList(Set<Id> rrIds) {
        return [SELECT Id, Reference_Request_Status__c,
                        (SELECT Id, Account_Request_Status__c
                            FROM Reference_Request_Accounts__r
                            WHERE Account_Request_Status__c = :ConstantsController.NOT_STARTED
                            OR Account_Request_Status__c = :ConstantsController.IN_PROGRESS
                            OR Account_Request_Status__c = :ConstantsController.ONHOLD),
                        (SELECT Id, Unspecified_Request_Status__c FROM Unspecified_Requests__r)
                    FROM Reference_Request__c WHERE Id IN :rrIds];
    }
    
    /**
     * method to get map of reference requests for onAfterUpdate method of UnspecifiedRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static Map<Id, Reference_Request__c> getRefRequestMap(Set<String> allreqIds) {
        return new Map<Id, Reference_Request__c>([SELECT Id, Project_Type__c, Opportunity__c, Opportunity__r.Account.Name
                                                    FROM Reference_Request__c
                                                    WHERE Id IN :allreqIds]);
    }
    
    /**
     * method to get map of ref types for onAfterUpdate method of UnspecifiedRequestTriggerHandler
     * (added for #480)
     * 
     * author: Gaurav Saini (17 Nov, 2016)
     */
    public static Map<Id, Referenceability_Type__c> getRefTypesMap(Set<String> setRefTypeIds) {
        return new Map<Id, Referenceability_Type__c>([SELECT Id, Name
                                                        FROM Referenceability_Type__c
                                                        WHERE Visible__c = true AND Id IN :setRefTypeIds]);
    }
    
    /**
     * method to get attributes for updateAttributeOnAccountSharedContact method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Attribute__c> getAttributesForUpdateRBI() {
        return [SELECT Id, (SELECT Id FROM Attributes__r)
                    FROM Attribute__c
                    WHERE Attribute_Mapping__r.Object__c = :ConstantsController.OPPORTUNITY
                    AND Attribute_Mapping__r.Field_Api_Name__c = 'StageName'];
    }
    
    /**
     * method to get content attributes for AddAttributesFromRefContentToAccount method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Content_Attribute__c> getContentAttributesForUpdateRBI(Set<Id> refContentIds) {
        return [SELECT Reference_Content__c, Attribute__c
                    FROM Content_Attribute__c
                    WHERE Reference_Content__c IN :refContentIds
                    AND Account__c = null
                    AND Reference_Content__r.Content_Status__c != 'Inactive'
                    AND Reference_Content__r.Content_Status__c != ''];
    }
    
    /**
     * method to get content attributes for addAttributesOnContent method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Content_Attribute__c> getContentAttributesForUpdateRBI2(Set<Id> refContentIds) {
        return [SELECT Reference_Content__c, Attribute__c
                    FROM Content_Attribute__c
                    WHERE Reference_Content__c IN :refContentIds];
    }
    
    /**
     * method to get referenceabilities for updateReferenceabilitiesonAccount method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Referenceability__c> getReferenceabilitiesForUpdateRBI(Set<String> accountIds,
                                                    Map<Id, Reference_Basic_Information__c> contactsRBIMap) {
        
        return [SELECT Id, Account__c, Comment__c, Verified__c, Contact__c, Contact__r.AccountId,
                        Referenceability_Type__r.Name, Referenceability_Type__c, Status__c
                    FROM Referenceability__c
                    WHERE Contact__c IN :contactsRBIMap.keySet()
                    OR Account__c IN :accountIds
                    ORDER BY Account__c];
    }
    
    /**
     * method to get attribute mappings for checkForAttributeMapping method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Attribute_Mapping__c> getAttributeMappingsForUpdateRBI(Set<String> fieldAPINames) {
        
        return [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c, Object__c 
                    FROM Attribute_Mapping__c
                    WHERE (Object__c = :ConstantsController.ACCOUNT
                        AND (Field_Api_Name__c != null
                        AND Field_Api_Name__c IN :fieldAPINames
                        AND Auto_populate__c = true
                        AND Is_Related_Mapping__c = false))
                    OR (Object__c = :ConstantsController.OPPORTUNITY
                        AND Field_Api_Name__c != null)];
                        //AND Field_Api_Name__c != 'Product2' //re #741
                        //AND Is_Related_Mapping__c = true//REF-2186
                        
    }
    
    /**
     * method to get attributes for checkForAttributeMapping method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Attribute__c> getAttributesForUpdateRBI1(Set<String> oppMappingIds,
                                                                Map<String, List<Account>> attMappingAccount) {
        
        return [SELECT Id, Name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c,
                        Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Inheritable__c,
                        //re #741
                        (SELECT Id, Name, Product_ID__c FROM Attributes__r)
                    FROM Attribute__c
                    WHERE (Attribute_Mapping__c IN :attMappingAccount.keySet()
                    OR Attribute_Mapping__c IN :oppMappingIds)
                    AND Level__c = 0 AND Attribute_Mapping__r.Auto_populate__c = true];
    }
    
    /**
     * method to get attributes for checkAttributeMappingEdit method
     * in UtilityController called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Attribute__c> getAttributesForUpdateRBI2(Set<Id> attMappingIds) {
        
        return [SELECT Id, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c,
                        Attribute_Mapping__r.Inheritable__c, Attribute_Mapping__r.Auto_update__c,
                        Attribute_Mapping__r.Auto_delete__c, Attribute_Mapping__r.Auto_populate__c,
                        Attribute_Mapping__r.Auto_add__c,
                        (SELECT Id, Name, Parent__c FROM Attributes__r)
                    FROM Attribute__c
                    WHERE Attribute_Mapping__c IN :attMappingIds
                    AND Level__c = 0
                    LIMIT :limits.getLimitQueryRows()];
    }
    
    /**
     * method to get attribute labels for checkAttributeMappingEdit method
     * in UtilityController called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Attributes_Labels__c> getAttributeLabelsForUpdateRBI(Set<String> childAttributeToFindLabel) {
        
        return [SELECT Label__c, Attribute__c
                    FROM Attributes_Labels__c
                    WHERE Attribute__c IN :childAttributeToFindLabel
                    LIMIT: limits.getLimitQueryRows()];
    }
    
    /**
     * method to get attributes to be deleted for checkAttributeMappingEdit method
     * in UtilityController called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static List<Attribute__c> getAttributesToBeDeleted(Set<String> attributesExisting,
                                                                Map<String, List<Schema.PicklistEntry>> attMappingPicklistMap) {
        
        return [SELECT Id FROM Attribute__c
                    WHERE Id NOT IN :attributesExisting
                    AND Parent__r.Attribute_Mapping__c IN :attMappingPicklistMap.keySet()
                    AND Parent__r.Attribute_Mapping__r.Auto_delete__c = true
                    LIMIT: limits.getLimitQueryRows()];
    }
    
    /**
     * method to insert attributes for checkAttributeMappingEdit method
     * in UtilityController called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static void insertAttributesForUpdateRBI(List<Attribute__c> newAttributes) {
        insert newAttributes;
    }
    
    /**
     * method to insert attribute labels for checkAttributeMappingEdit method
     * in UtilityController called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (15 Nov, 2016)
     */
    public static void insertAttributeLabelsForUpdateRBI(List<Attributes_Labels__c> attLabels) {
        insert attLabels;
    }
    
    /**
     * method to get RBIs for checkDuplicateRBI method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reference_Basic_Information__c> getRBIsForUpdateRBI(Set<Id> contactIds, Set<Id> accountIds) {
        return [SELECT Id, Is_Referenceable__c, Contact__r.AccountId,
                        Referenceability_Status__c, Account__c, Contact__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c != null AND 
                    (Account__c IN :accountIds
                        OR Contact__c IN :contactIds)];
    }
    
    /**
     * method to get shared contact records for onUpdateAccountTypeRBI method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<sObject> getSharedContactsForUpdateRBI(Set<String> accountIDs, String query) {
        return Database.query(query);
    }
    
    /**
     * method to get shared contact records for onUpdateContactTypeRBI method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<sObject> getSharedContactsForUpdateRBI1(Set<String> sharedContactIds, String query) {
        return Database.query(query);
    }
    
    /**
     * method to delete reference notes for deleteCandidateAccRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static void deleteRefNotesForUpdateRBI(List<Reference_Note__c> referenceNotes) {
        delete referenceNotes;
    }
    
    /**
     * method to delete unspecified requests for deleteCandidateAccRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static void deleteUnspecifiedRequestsForUpdateRBI(List<Unspecified_Request__c> urList) {
        delete urList;
    }
    
    /**
     * method to get hit list for accounts for deleteCandidateAccRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Hit_List__c> getHitListsForUpdateRBI(Set<String> accountIds) {
        return [SELECT Id, Account_Request__c, Released__c FROM Hit_List__c WHERE Account__c IN :accountIds];
    }
    
    /**
     * method to delete hit lists for deleteCandidateAccRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static void deleteHitListsForUpdateRBI(List<Hit_List__c> hitList) {
        delete hitList;
    }
    
    /**
     * method to get hit list for accounts for deleteCandidateAccRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reference_Request__c> getRefRequestsForUpdateRBI(Set<Id> requestIds) {
        return [SELECT Id ,Project_Type__c ,Reference_Request_Status__c,
                    (SELECT Id,Account_Request_Status__c, Account__c, Requester__c, Requester__r.Email, Account__r.Name, Account_f__c FROM Reference_Request_Accounts__r WHERE Account_Request_Status__c = :ConstantsController.NOT_STARTED
                    OR Account_Request_Status__c = :ConstantsController.IN_PROGRESS
                    OR Account_Request_Status__c = :ConstantsController.ONHOLD),
                    (SELECT Id,Unspecified_Request_Status__c FROM Unspecified_Requests__r WHERE Unspecified_Request_Status__c = :ConstantsController.NOT_STARTED
                    OR Unspecified_Request_Status__c = :ConstantsController.IN_PROGRESS
                    OR Unspecified_Request_Status__c = :ConstantsController.ONHOLD),
                    (SELECT Id FROM Reference_Notes__r)
                    FROM Reference_Request__c
                    WHERE Id IN :requestIds];
    }
    
    /**
     * method to update reference requests from Account Request trigger
     * Created by: Rekha @20 March 2017
     */
    public static void updateRefRequests(List<Reference_Request__c> refRequestList) {
        update refRequestList;
    }
    /**
     * method to delete reference requests for deleteCandidateAccRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static void deleteRefRequestsForUpdateRBI(List<Reference_Request__c> refRequestList) {
        delete refRequestList;
    }
    
    /**
     * method to get hit list for accounts for deleteCandidateAccRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reference_Basic_Information__c> getRBIsForUpdateRBI1(Map<Id, Reference_Basic_Information__c> updateAccountFieldMapForRul) {
        return [SELECT Id, RUL_Period__c, RUL_Activities_will_do__c, Account__c, Contact__c
                    FROM Reference_Basic_Information__c
                    WHERE Contact__c != null
                    AND Account__c != null
                    AND Account__c IN :updateAccountFieldMapForRul.keySet()];
    }
    
    /**
     * method to get contact requests to delete for deleteCandidateConRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reference_Request_Account_Contact__c> getContactRequestsForUpdateRBI(Set<Id> contactIds) {
        return [SELECT Id, Contact__c, Reference_Request_Account__r.Reference_Request__r.Project_Type__c, Reference_Request_Account__c, Reference_Request_Account__r.Requester__c, Contact__r.Name, Contact_Request_Status__c FROM Reference_Request_Account_Contact__c WHERE Contact__c IN :contactIds];
    }
    
    /**
     * method to delete contact requests for deleteCandidateConRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static void deleteContactRequestsForUpdateRBI(List<Reference_Request_Account_Contact__c> contactRequests) {
        delete contactRequests;
    }
    
    /**
     * method to get hit list for contacts for deleteCandidateConRequest method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Hit_List__c> getHitListsForUpdateRBI1(Set<Id> contactIds) {
        return [SELECT Id,Released__c FROM Hit_List__c WHERE Contact__c IN :contactIds];
    }
    
    /**
     * method to get account attributes for accounts for deleteAttributeFromAccount method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Account_Attribute__c> getAccountAttributesForUpdateRBI(Set<Id> contactIds) {
        return [SELECT Id FROM Account_Attribute__c WHERE Contact__c IN :contactIds];
    }
    
    /**
     * method to get referenceabilities for updateReferenceabilityAccount method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Referenceability__c> getReferenceabilitiesForUpdateRBI(Set<String> accountIds, Set<String> contactIds) {
        return [SELECT Id, Account__c, Contact__c, Contact__r.AccountId, Referenceability_Type__r.Name,
                    Referenceability_Type__c, Status__c, Comment__c, Verified__c
                    FROM Referenceability__c WHERE Contact__c IN :contactIds
                    //for invalid query locater 
                    /*OR Account__c IN :accountIds*/];
    }
    
    /**
     * method to get attribute mappings for checkForAttributeMappingContact method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Attribute_Mapping__c> getAttMappingsForUpdateRBI(Set<String> fieldAPINames) {
        return [SELECT Field_Api_Name__c, Auto_populate__c, Auto_add__c, Auto_Update__c, Auto_delete__c
                    FROM Attribute_Mapping__c WHERE Object__c = :ConstantsController.CONTACT
                    AND Field_Api_Name__c != null
                    AND Field_Api_Name__c IN :fieldAPINames
                    AND Auto_populate__c = true
                    AND Is_Related_Mapping__c = false];
    }
    
    /**
     * method to get attributes for checkForAttributeMappingContact method
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Attribute__c> getAttributesForUpdateRBI1(Map<String, List<Contact>> attMappingContact) {
        return [SELECT Id, Name, Attribute_Mapping__r.Id, Attribute_Mapping__r.Field_Api_Name__c,
                    Attribute_Mapping__r.Auto_populate__c, Attribute_Mapping__r.Inheritable__c,
                    (SELECT Id, Name FROM Attributes__r)
                    FROM Attribute__c
                    WHERE Attribute_Mapping__c IN :attMappingContact.keySet()
                    AND Level__c = 0];
    }
    
    /**
     * method to get rewards for influitiveMembersCallout method in Infl_Member class
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reward__c> getRewardsForUpdateRBI(String conId, Set<String> eventIds) {
        return [SELECT Contact__c, Influitive_Id__c, Influitive_ID2__c
                    FROM Reward__c
                    WHERE Influitive_ID2__c IN :eventIds
                    AND Contact__c = :conId];
    }
    
    /**
     * method to get rewards for influitiveMembersCallout method in Infl_Member class
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reward__c> getContactRewardsForUpdateRBI(String conId) {
        return [SELECT Id, Transaction__c, Expired__c, Available_Points__c, Amount__c, Account__c, Contact__c
                    FROM Reward__c
                    WHERE Contact__c = :conId];
    }
    
    /**
     * method to get RBIs for influitiveMembersCallout method in Infl_Member class
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reference_Basic_Information__c> getRBIsForUpdateRBI2(String conId, String accountId) {
        return [SELECT Contact__c, Influitive_Id__c, Lifetime_Points__c, Current_Available_Balance_Points__c
                    FROM Reference_Basic_Information__c
                    WHERE Account__c = :accountId AND Generic_Account__c = false
                    AND (Contact__c = :conId
                        OR Contact__c = null)];
    }
    
    /**
     * method to get contact RBIs for influitiveMembersCallout method in Infl_Member class
     * called in afterUpdate of rbi trigger
     * 
     * author: Gaurav Saini (16 Nov, 2016)
     */
    public static List<Reference_Basic_Information__c> getContactRBIsForUpdateRBI(String conId) {
        return [SELECT Influitive_Id__c
                    FROM Reference_Basic_Information__c
                    WHERE Contact__c = :conId];
    }
    
    
    /*************************/
    
    // added for #438 - method to delete attributes
    public static void deleteAttributeFrmAccount(List<Account_Attribute__c> accuntAttribDelete) {
        delete accuntAttribDelete;
    }
    
    /****** Methods for new microsite page ******/
    
    public static Map<String, String> getRefContentThumbnailMap(List<String> refContentIds) {
        Map<String, String> resultMap = new Map<String, String>();
        List<Attachment> attList = [SELECT ParentId, Id
                                        FROM Attachment
                                        WHERE ParentId IN :refContentIds
                                        AND Name = 'documentThumbnail.jpg'];
        if (attList != null && attList.size() > 0) {
            for (Attachment att : attList) {
                resultMap.put(att.ParentId, att.Id);
            }
        }
        return resultMap;
    }
    public static List<Invitation__c> getInvitationObject(String invitationId) {
        return [SELECT Microsite__c, Is_Invitation_Expired__c, Invitation_Expiration__c, CreatedDate
                                FROM Invitation__c
                                WHERE Id = :invitationId];
    }
    public static List<Microsite__c> getMicrositeObject(String micrositeId) {
        // changes for #611 - new field added for header background color by Gaurav Saini (9 Dec, 2016)
        return [SELECT Sub_header_Copy__c, Sub_Header_Copy_Size__c, Header_Background_Color__c,
                            Sub_Header_Copy_Color__c, Sub_Header_Copy_Alignment__c,
                            Image_Alignment__c, Page_Color__c, Header_Copy_Alignment__c,
                            Header_Copy_Size__c, Header_Copy_Color__c, Header_Copy__c,
                            Footer_Link__c, Footer_Copy__c, Footer_Copy_Size__c,
                            Footer_Copy_Color__c, Footer_Copy_Alignment__c,
                            Document_Title_Color__c, Banner_image__c, Available_for_Use__c
                        FROM Microsite__c
                        WHERE Id = :micrositeId];
    }
    // Method for getting all the IRC objects
    public static List<Invitation_ReferenceContent__c> getContentRatingDetails(String invitationId, String contentId,
                                                String userId, String inviteeId, String otherRecepient) {
        if (contentId != '') {
            return [SELECT Reference_Content__c, Rating__c
                                FROM Invitation_ReferenceContent__c
                                WHERE Invitation__c = :invitationId
                                AND Reference_Content__c = :contentId];
        } else if (inviteeId != '') {
            return [SELECT Reference_Content__c, Rating__c
                                FROM Invitation_ReferenceContent__c
                                WHERE Invitation__c = :invitationId
                                AND Recipient__r.Contact__c = :inviteeId];
        } else if (userId != '') {
            return [SELECT Reference_Content__c, Rating__c
                                FROM Invitation_ReferenceContent__c
                                WHERE Invitation__c = :invitationId
                                AND Recipient__r.User__c = :userId];
        } else if (otherRecepient != '') {
            return [SELECT Reference_Content__c, Rating__c
                                FROM Invitation_ReferenceContent__c
                                WHERE Invitation__c = :invitationId
                                AND Recipient__c = :otherRecepient];
        }
        return new List<Invitation_ReferenceContent__c>();
    }
    // Method for getting the IRC object for saving the rating value
    // AND for counting number of clicks on microsite
    public static List<Invitation_ReferenceContent__c> getContentRatingDetails1(String invitationId, String refContentId,
                                                String userId, String inviteeId, String otherRecepient) {
        if (inviteeId != '') {
            return [SELECT Reference_Content__c, Rating__c, Visits_clicks__c, First_Visit__c
                                FROM Invitation_ReferenceContent__c
                                WHERE Invitation__c = :invitationId
                                AND Reference_Content__c = :refContentId
                                AND Recipient__r.Contact__c = :inviteeId];
        } else if (userId != '') {
            return [SELECT Reference_Content__c, Rating__c, Visits_clicks__c, First_Visit__c
                                FROM Invitation_ReferenceContent__c
                                WHERE Invitation__c = :invitationId
                                AND Reference_Content__c = :refContentId
                                AND Recipient__r.User__c = :userId];
        } else if (otherRecepient != '') {
            return [SELECT Reference_Content__c, Rating__c, Visits_clicks__c, First_Visit__c
                                FROM Invitation_ReferenceContent__c
                                WHERE Invitation__c = :invitationId
                                AND Reference_Content__c = :refContentId
                                AND Recipient__c = :otherRecepient];
        }
        return new List<Invitation_ReferenceContent__c>();
    }
    public static List<Reference_Content__c> getRefContents(List<String> refContentIds) {
        return [SELECT Id, Name, Attributes__c, Title__c, External_Summary__c, Substitute_Account_Name__c,
                Search_Terms_keywords__c, Review_Date__c, Language__c, Publish_date__c,
                Internal_Use__c, Expiration_Date__c, Reference_Content_Type_Name__c,
                Content_Status__c, Content_ID__c, Allow_Social_Sharing__c,
                Reference_Content_Type__r.Recorded_Reference_Type__c,Custom_Reference_Content__c
                FROM Reference_Content__c
                WHERE Id IN :refContentIds
                AND Content_Status__c != :ConstantsController.INACTIVE
                AND Content_Status__c != ''
                ORDER BY Title__c];
    }
    public static List<Reference_Interview__c> getRefInterviewList(List<String> refContentIds) {
        return [SELECT Transcript__c, Reference_Content__r.Title__c, Name, Photograph__c,
                                    Speaker_info__c, Transcript_Content_Id__c, Org_website__c,
                                    Org_description__c, Reference_Content__c,
                                    (SELECT Name, Question__c, Transcript__c, Video_Url_Embed__c, Content_Id__c, Order__c
                                        FROM Interview_Topics__r ORDER BY Order__c)
                                    FROM Reference_Interview__c
                                    WHERE Reference_Content__c IN :refContentIds];
    }
    public static Map<Id, ContentVersion> getContentVersionMap(List<String> contentVersionIds) {
        Map<Id, ContentVersion> tempMap = new Map<Id, ContentVersion>([SELECT Id, ContentUrl, Title,
                                                FileType, LastModifiedDate, ContentDocumentId, VersionData
                                                FROM ContentVersion
                                                WHERE Id IN :contentVersionIds]);
        return tempMap;
    }
    // added for #498 - for resolution of heap size exceeded exception
    public static Map<Id, ContentVersion> getContentVersionMap1(List<String> contentVersionIds) {
        Map<Id, ContentVersion> tempMap = new Map<Id, ContentVersion>([SELECT Id, ContentUrl, Title,
                                                FileType, LastModifiedDate, ContentDocumentId
                                                FROM ContentVersion
                                                WHERE Id IN :contentVersionIds]);
        return tempMap;
    }
    public static List<Reference_Content__c> getRefContentsForDownload(String refContentId) {
        return [SELECT Id, Number_of_Download__c, Content_ID__c
                    FROM Reference_Content__c
                    WHERE Id = :refContentId];
    }
    public static List<Invitee__c> getInviteeList(String invitationId, String inviteeId,
                                                String userId, String otherRecepient) {
        if (inviteeId != '') {
            return [SELECT Visits_clicks__c, First_Visit__c
                            FROM Invitee__c
                            WHERE Invitation__c = :invitationId
                            AND Contact__c = :inviteeId];
        } else if (userId != '') {
            return [SELECT Visits_clicks__c, First_Visit__c
                            FROM Invitee__c
                            WHERE Invitation__c = :invitationId
                            AND User__c = :userId];
        } else if (otherRecepient != '') {
            return [SELECT Visits_clicks__c, First_Visit__c
                            FROM Invitee__c
                            WHERE Invitation__c = :invitationId
                            AND User__c = :otherRecepient];
        }
        return new List<Invitee__c>();
    }
    
    /*****************************************/
    
    /**
     * Method to get contents using sosl query for refsearch lightning 
     */
    public static List<List<SObject>> getContentsUsingSOSL(String soslQuery) {
        return search.query(soslQuery);
    }
    /**
     * Method to get contacts using sosl query for refsearch lightning 
     */
    public static List<List<SObject>> getContactsUsingSOSL(String soslQuery, Set<string> activeAccountIds, Set<string> alreadyDisplayedContactIds) {
        return search.query(soslQuery);
    }
    /**
     * Method to get accounts 
     */
    public static List<List<SObject>> getAccountSOSL(String inputText, Set<String> activeAccountIds, Set<String> searchedAccountIds,Set<String> alreadydisplayedaccountIds) {
        String accountSOSLQuery = 'FIND \'' + inputText + '*\' IN ALL FIELDS RETURNING Account(Id WHERE Id IN : activeAccountIds AND Id NOT IN :searchedAccountIds AND Id NOT IN: alreadydisplayedaccountIds)';
        return search.query(accountSOSLQuery);
    }
    /**
     * Method to get attribute mappings for refsearch lightning
     */
    public static List<sObject> getRelatedMappingIds(String soqlQuery, Attribute_Mapping__c attMapping, Set<String> relatedObjectIds) {
        return Database.query(soqlQuery);
    }
    /**
     * Method to get attribute mappings for refsearch lightning
     */
    public static List<Attribute_Mapping__c> getAttributeMappings(String filterId) {
        return [SELECT Field_Api_Name__c, Is_Related_MultiSelectPicklist__c, Filter_Label_Name__c, Is_Related_Mapping__c, 
                        Mapping_Type__c, Object__c, Related_Object__c, RelationShip_Name__c
                        FROM Attribute_Mapping__c
                        WHERE Id = :filterId
                        AND Is_Related_Mapping__c = true];
    }
    /**
     * Method to filter records for refsearch lightning
     */
    public static List<sObject> filterRecords(String soqlQuery, Attribute_Mapping__c attMapping, String values, Set<string> selectedValues) {
        return Database.query(soqlQuery);
    }
    /**
     * Method to get list of ref contents for refsearch lightning
     */
    public static List<Reference_Content__c> getAllContents(String soqlQuery, Set<string> filteredContents, Set<string> alreadyDisplayedContents, Integer pageLimit) {
        return Database.query(soqlQuery);
    }
    /**
     * Method to get rewards
     */
    public static List<Reward__c> getRewards(Set<Id> accountIds, Set<Id> contactAccountIds) {
        List<Reward__c> rewardList = [SELECT Id, Transaction__c, Expired__c, Available_Points__c,
                                            Amount__c, Account__c, Contact__c
                                            FROM Reward__c
                                            WHERE (Account__c IN :accountIds
                                            OR Account__c IN :contactAccountIds)
                                            AND Transaction__c = 'Issue'
                                            AND Amount__c != null
                                            AND Available_Points__c != null];
        return rewardList;
    }
    /**
     * Method to get contact
     */
    public static List<Contact> getContact(string contactId){
        List<Contact> con = [SELECT Id, Name,email, title,phone,AccountId, (SELECT Id, account__c, Contact__c,RUL_Last_Activity_Date__c, Is_Referenceable__c,Referenceability_Status__c,Roll_up_Referenceability_to_All_Accounts__c,Roll_up_Referenceability_to_Primary_Acc__c FROM Reference_Basic_Informations__r WHERE Contact__c != null AND Account__c != null) FROM Contact WHERE Id = : contactId];
        return con;
    }
    /**
     * Method to get contacts
     */
    public static Map<Id, Contact> getContacts(Set<string> setContactId){
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, FirstName, LastName, email, title, Account.Name FROM Contact WHERE Id IN : setContactId]);
        return contactMap;
    }
    /**
     * Method to get all active Account RBIs for ref search page
     */
    public static List<Reference_Basic_Information__c> getAllActiveAccountRBIs(Boolean isFilterAppiled, Set<String> alreadydisplayedaccountIds,
                                                            Set<String> filteredAccounts, Integer pageLimit, String refStatus) {
        List<Reference_Basic_Information__c> result = new List<Reference_Basic_Information__c>();
        
        if (refStatus == 'Active') {
            
            if (isFilterAppiled) {
                result = [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name, Account__r.OwnerId, Referenceability__c,  Reference_Owner__r.Name, Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c FROM Reference_Basic_Information__c WHERE Account__c IN :filteredAccounts AND Account__c NOT IN :alreadydisplayedaccountIds AND contact__c = null AND Is_Referenceable__c = true AND (Referenceability_Status__c != :ConstantsController.INACTIVE AND Referenceability_Status__c != '') AND Contact__c = null
                            ORDER BY Account__r.Name LIMIT :pageLimit + 1];
            } else {
                result = [SELECT Account__c, Account__r.Id, Account__r.Name,Account__r.Owner.Name, Account__r.OwnerId, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c FROM Reference_Basic_Information__c WHERE Account__c NOT IN :alreadydisplayedaccountIds AND contact__c = null AND Is_Referenceable__c = true AND (Referenceability_Status__c != :ConstantsController.INACTIVE AND Referenceability_Status__c != '') AND Contact__c = null
                            ORDER BY Account__r.Name LIMIT :pageLimit + 1]; 
            }
        } else if (refStatus == 'Inactive') {
            
            if (isFilterAppiled) {
                result = [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name, Account__r.OwnerId, Referenceability__c,  Reference_Owner__r.Name, Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c FROM Reference_Basic_Information__c WHERE Account__c IN :filteredAccounts AND Account__c NOT IN :alreadydisplayedaccountIds AND contact__c = null AND Is_Referenceable__c = true AND Referenceability_Status__c = :ConstantsController.INACTIVE AND Contact__c = null
                            ORDER BY Account__r.Name LIMIT :pageLimit + 1];
            } else {
                result = [SELECT Account__c, Account__r.Id, Account__r.Name,Account__r.Owner.Name, Account__r.OwnerId, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c FROM Reference_Basic_Information__c WHERE Account__c NOT IN :alreadydisplayedaccountIds AND contact__c = null AND Is_Referenceable__c = true AND Referenceability_Status__c = :ConstantsController.INACTIVE AND Contact__c = null
                            ORDER BY Account__r.Name LIMIT :pageLimit + 1]; 
            }
        } else if (refStatus == 'Candidate') {
            
            if (isFilterAppiled) {
                result = [SELECT Account__c, Account__r.Id, Account__r.Name, Account__r.Owner.Name, Account__r.OwnerId, Referenceability__c,  Reference_Owner__r.Name, Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c FROM Reference_Basic_Information__c WHERE Account__c IN :filteredAccounts AND Account__c NOT IN :alreadydisplayedaccountIds AND contact__c = null AND Reference_Program_Candidate__c = true AND Contact__c = null
                            ORDER BY Account__r.Name LIMIT :pageLimit + 1];
            } else {
                result = [SELECT Account__c, Account__r.Id, Account__r.Name,Account__r.Owner.Name, Account__r.OwnerId, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c FROM Reference_Basic_Information__c WHERE Account__c NOT IN :alreadydisplayedaccountIds AND contact__c = null AND Reference_Program_Candidate__c = true AND Contact__c = null
                            ORDER BY Account__r.Name LIMIT :pageLimit + 1]; 
            }
        }
        return result;
    }
    /**
     * Method to get related active ref contents for account
     */
    public static List<Account_Reference_Content__c> getARCForAccounts(Set<String> tempAccIdSet) {
        return [SELECT Reference_Content__c, Id, Account__c FROM Account_Reference_Content__c 
                        WHERE Account__c IN :tempAccIdSet AND Reference_Content__r.Content_Status__c = 'Active'];
    }
    /**
     * Method to get accounts related to a particular ref content
     */
    public static List<Account> getRelatedAccountsForRefContent(List<String> accIds) {
        return [SELECT Id, Name, Type, Phone,
                (SELECT Name, Account__c, Generic_Account__c, Is_Referenceable__c, Contact__c,
                    Reference_Program_Candidate__c, Contact__r.Name, Referenceability_Status__c
                    FROM Reference_Basic_Informations__r
                    WHERE Contact__c = null)
                FROM Account
                WHERE Id IN :accIds
                LIMIT :limits.getLimitQueryRows()];
    }
    /**
     * Method to get ARC list related to a particular account
     */
    public static List<Account_Reference_Content__c> getARCsForAccount(String accId) {  
        return [SELECT Reference_Content__c,Account__r.Name FROM Account_Reference_Content__c
                    WHERE Account__c = :accId
                    AND Reference_Content__r.Content_Status__c = 'Active'];
    }
    /**
     * Method to get active ref contents related to a particular account
     */
    public static List<Reference_Content__c> getRefContentForAccount(Set<String> refContentIds) {
        return [SELECT Id, Name, Featured_Content__c , Reference_Content_Type__r.Recorded_Reference_Type__c,
                    Reference_Content_Type__r.Custom_Content_Type__c, Number_of_Download__c, Attributes__c,
                    Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c, Language__c,
                    Publish_date__c, Reference_Content_Type_Name__c, Internal_Use__c, Expiration_Date__c,
                    Reference_Content_Type__c, Reference_Content_Type__r.Name__c, Content_Status__c,
                    Content_ID__c, Allow_Social_Sharing__c, Custom_Reference_Content__c, Content_URL__c, Content_URL2__c,
                    (SELECT Id, Account__c, Account__r.Name FROM Account_Reference_Contents__r)
                    FROM Reference_Content__c
                    WHERE Id IN :refContentIds];
    }
    
    /**
     * Method to get all active Contact RBIs for ref search page
     */
    public static List<Reference_Basic_Information__c> getAllActiveContactRBIs(Boolean isFilterAppiled, Set<String> alreadyDisplayedContactIds,
                                                                    Set<String> filteredContacts, Integer pageLimit, String refStatus) {
        List<Reference_Basic_Information__c> result = new List<Reference_Basic_Information__c>();
        
        if (refStatus == 'Active') {
            
            if (isFilterAppiled) {
                result = [SELECT Account__c, Contact__c, Account__r.Name,Contact__r.Owner.Name,Contact__r.Email, Contact__r.OwnerId,Contact__r.Name, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Ref_Profile_Summary__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Contact__c IN :filteredContacts AND Contact__c NOT IN: alreadyDisplayedContactIds AND contact__c != null AND Is_Referenceable__c = true AND(Referenceability_Status__c != : ConstantsController.INACTIVE AND Referenceability_Status__c != '')
                            AND Account__c != null ORDER BY Contact__r.Name LIMIT :pageLimit + 1];
            } else {
                result = [SELECT Account__c, Contact__c,Account__r.Name,Contact__r.Email,Contact__r.Owner.Name, Contact__r.OwnerId,Contact__r.Name, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Ref_Profile_Summary__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Contact__c NOT IN: alreadyDisplayedContactIds AND contact__c != null AND Is_Referenceable__c = true AND(Referenceability_Status__c != : ConstantsController.INACTIVE AND Referenceability_Status__c != '') AND Account__c != null
                            ORDER BY Contact__r.Name LIMIT :pageLimit + 1];
            }
        } else if (refStatus == 'Inactive') {
            
            if (isFilterAppiled) {
                result = [SELECT Account__c, Contact__c, Account__r.Name,Contact__r.Email,Contact__r.Owner.Name, Contact__r.OwnerId,Contact__r.Name, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Ref_Profile_Summary__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Contact__c IN :filteredContacts AND Contact__c NOT IN: alreadyDisplayedContactIds AND contact__c != null AND Is_Referenceable__c = true AND Referenceability_Status__c = :ConstantsController.INACTIVE
                            AND Account__c != null ORDER BY Contact__r.Name LIMIT :pageLimit + 1];
            } else {
                result = [SELECT Account__c, Contact__c,Account__r.Name,Contact__r.Email,Contact__r.Owner.Name, Contact__r.OwnerId,Contact__r.Name, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Ref_Profile_Summary__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Contact__c NOT IN: alreadyDisplayedContactIds AND contact__c != null AND Is_Referenceable__c = true AND Referenceability_Status__c = :ConstantsController.INACTIVE AND Account__c != null
                            ORDER BY Contact__r.Name LIMIT :pageLimit + 1];
            }
        } else if (refStatus == 'Candidate') {
            
            if (isFilterAppiled) {
                result = [SELECT Account__c, Contact__c, Account__r.Name,Contact__r.Email,Contact__r.Owner.Name, Contact__r.OwnerId,Contact__r.Name, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Ref_Profile_Summary__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Contact__c IN :filteredContacts AND Contact__c NOT IN: alreadyDisplayedContactIds AND contact__c != null AND Reference_Program_Candidate__c = true
                            AND Account__c != null ORDER BY Contact__r.Name LIMIT :pageLimit + 1];
            } else {
                result = [SELECT Account__c, Contact__c,Account__r.Name,Contact__r.Email,Contact__r.Owner.Name, Contact__r.OwnerId,Contact__r.Name, Referenceability__c,  Reference_Owner__r.Name,Reference_Owner__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                            Account_Level_RUL__c, Ref_Profile_Summary__c, Referenceability_Status__c FROM Reference_Basic_Information__c WHERE Contact__c NOT IN: alreadyDisplayedContactIds AND contact__c != null AND Reference_Program_Candidate__c = true AND Account__c != null
                            ORDER BY Contact__r.Name LIMIT :pageLimit + 1];
            }
        }
        return result;
    }
    
    /**
     * Method to get related account details
     */
    public static Map<Id, Account> getRelatedAccountsRefContent(List<String> accIds) {
        Map<Id, Account> accountMap = new Map<Id, Account>( [SELECT Id, Name, (SELECT Name, Account__c, Generic_Account__c, Is_Referenceable__c, Contact__c,
                    Reference_Program_Candidate__c, Contact__r.Name, Referenceability_Status__c FROM Reference_Basic_Informations__r
                    WHERE Contact__c = null) FROM Account WHERE Id IN :accIds ORDER BY Name LIMIT :limits.getLimitQueryRows()]);
                    
        return accountMap;
    }
    
    /**
     * Method to get related account details
     */
    public static Map<Id, Reference_Basic_Information__c> getAccountsReferenceProfiles(List<String> accIds) {
        Map<Id, Reference_Basic_Information__c> accountMap = new Map<Id, Reference_Basic_Information__c>();
        for (Reference_Basic_Information__c rbi : [SELECT Account__c, Generic_Account__c, Is_Referenceable__c FROM Reference_Basic_Information__c
                    WHERE Contact__c = null AND Account__c IN :accIds]) {
            accountMap.put(rbi.Account__c, rbi);
        }
        return accountMap;
    }
    
    /**
     * Method to get User
     * Modified By: Rekha @9 March 2017 related to ticket #780
     */
    public static User getUser(string userId) {
        List<User> userList = [SELECT Id, ManagerId FROM User WHERE Id = :userId];
        
        if (userList.size() > 0) {
            return userList[0];
        } else {
            return new User();
        }
    }
    
    /**
     * Method to get all Users for Invitataion Co workers
     */
    public static List<User> getSearchedUsersForCoWorkers(string query,Set<Id> communityUsers){
        return Database.query(query);
    }
    
    /**
     * Method to get community Users for Invitataion Co workers
     * Last Modify : Rajesh @15 May 2017 (re #846)
     */
    public static Set<Id> getCommunityUsersForCoWorkers(){
        String userLicenseQuery = 'SELECT Id,UserLicenseId FROM Profile WHERE UserLicenseId IN (SELECT Id FROM UserLicense WHERE name LIKE \'%Community%\')';
        Set<Id> profileIds = new Set<Id>();
        
        for (Profile profile : Database.query(userLicenseQuery)){
            profileIds.add(profile.Id);
        }        
        return profileIds;
    }
    
    /**
     * Method to get all Users for Invitataion Co workers
     */
    public static List<User> getAllUsersForCoWorkers(Set<Id> communityUsers){
        return [SELECT Id, Name, Email FROM User WHERE IsActive = true AND Id NOT IN : communityUsers ORDER BY Name LIMIT 201];
    }
    /**
     * Method to get all selected Users for Invitataion Co workers
     */
    public static List<User> getSelectedUsersForCoWorkers(Set<String> selectedUserIdSet,Set<Id> communityUsers){
        return [SELECT Id, Name, Email FROM User WHERE Id In: selectedUserIdSet AND IsActive = true AND Id NOT IN : communityUsers ORDER BY Name LIMIT 201];
    }
    /**
     * Method to get all Contacts For Invitation
     */
    public static List<Contact> getSearchedContactsForInvitation(string query){
        return Database.query(query);
    }
    /**
     * Method to get all selected Contacts For Invitation
     */
    public static List<Contact> getSelectedContactsForInvitation(List<String> userIdSet){
        return [SELECT Id, Name, Email FROM Contact WHERE Id IN: userIdSet ORDER BY Name LIMIT 201];
    }
    /**
     * Method to get User
     */
    public static Map<Id, User> getUserMap(Set<Id> userIds){
        Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name, IsActive, Email FROM User WHERE Id IN : userIds]);
        return userMap;
    }
    /**
     * Method to update sobject's fields
     */
    public static List<Sobject> updateSobjectFields(List<Sobject> sobjects){
        update sobjects;
        return sobjects;
    }
    /**
     * Method to insert postFeedItems
     */
    public static List<sObject> insertPostFeedItems(List<sObject> postFeedItems){
        insert postFeedItems;
        return postFeedItems;
    }
    /**
     * Method to insert postFeedItems
     */
    public static Map<Id, sObject> insertPostFeedItemsMapBasic(Map<Id, sObject> postFeedItems){
        insert postFeedItems.values();
        return postFeedItems;
    }
    /**
     * Method to upsert Community Invite Contact
     */
    public static List<Community_Invite_Contact__c> upsertContactInvites(List<Community_Invite_Contact__c> cics) {
        upsert cics;
        return cics;
    }
    
    /**
     * Method to upsert Account Contact
     */
    public static void upsertReqAccountContact(Reference_Request_Account_Contact__c rra) {
        upsert rra; 
    }
    
    /**
     * Method to insert invitee records to whom the invitation request is send --- Used in InvitationController
     */
     public static List<Invitee__c> insertInvitees(List<Invitee__c> invitees){
        insert invitees;
        return invitees;
    }
    
    /**
     * Method to insert invitee records to whom the invitation request is send --- Used in InvitationController
     */
     public static void updateInvitees(List<Invitee__c> invitees){
        update invitees;
    }
    
    /**
     * Method use in ReferenceRequestController & ReferenceUseRequest Controller
     */
    public static List<Reference_Basic_Information__c> getAccountsRBI(List<String> listAccountIds) {
        Set<Id> accIds = new Set<Id>();
        for (string str : listAccountIds) {
            accIds.add((Id)str.trim());
        }
        String soql_account = 'SELECT Account__r.Id,Account__c, Account__r.Name, Account__r.OwnerId,Account__r.Owner.Name, Managed_Reference_Account__c, Referenceability__c, Attributes__c,Reference_Owner__c,Reference_Owner__r.Name FROM Reference_Basic_Information__c  WHERE Account__c != null AND Account__c In : accIds AND Contact__c = null ORDER BY Account__r.Name';
        return Database.query(soql_account);
    }
    public static Map<Id,Reference_Basic_Information__c> getSharedAccountsRBI(Set<String> listAccountIds) {
        Map<Id,Reference_Basic_Information__c> accMap = new Map<Id,Reference_Basic_Information__c>();
        for (Reference_Basic_Information__c rbi : [SELECT Id, Account__c, Is_Referenceable__c, Reference_Program_Candidate__c FROM Reference_Basic_Information__c WHERE Generic_Account__c = false AND Account__c IN : listAccountIds AND Contact__c = null]){
            accMap.put(rbi.Account__c, rbi);
        }
        return accMap;
    }
    public static List<Reference_Basic_Information__c> fetchRBIds(Set<Id> accountIds){
        return [SELECT Account__r.Name,Account__c,Att_Ref_Last_Update_By__c, Last_Att_Ref_Update__c, Attribute_Ids__c,Label_Ids1__c,Label_Ids2__c,Parent_Attributes__c, Attributes__c,Account__r.OwnerId,Reference_Owner__c,Profile_Update_Owner__c FROM Reference_Basic_Information__c WHERE Generic_Account__c = false AND Account__c in : accountIds AND Contact__c = null];
    }
    /**
     * Method to upsert RBIs 
     */
    public static List<Reference_Basic_Information__c> upsertRBI(List<Reference_Basic_Information__c> rbi){
        upsert rbi;
        return rbi;
    }
    /**
     * Method to get RBI using String query
     */
    public static List<Reference_Basic_Information__c> getRBI(String soql_rbi) {
        return Database.query(soql_rbi);
    }
    /**
     * Method to insert contact RBI FROM SelectRefUseContactsController
     */
    public static Reference_Basic_Information__c insertContactRBI(Reference_Basic_Information__c newrbi){
        insert newrbi;
        return newrbi;
    }
    /**
     * Method to update RBIs FROM batch 
     */
    public static Database.SaveResult[]  updateRBIFromBatch(List<Reference_Basic_Information__c> rbiList){
        return database.update(rbiList, false);
    }
    
    public static void updateRBI(List<Reference_Basic_Information__c> rbiList) {
        update rbiList;
    }
    
    /**
     * Method to delete attributes FROM Utility Class
     */
    public static void deleteAttributefromUtility(List<Attribute__c> attToBeDeleted){
        delete attToBeDeleted;
    }
    /**
     * Method to delete data on merge FROM Utility Class
     */
    public static void  deleteReferenceProfiles(List<Reference_Basic_Information__c>  rbis){
        delete rbis;
        Database.emptyRecycleBin( rbis );
    }
    public static void  deleteContactRequests(List<Reference_Request_Account_Contact__c>  conReqs){
        delete conReqs;
    }
    public static void  deleteNominations(List<Nomination__c>  nomis){
        delete nomis;
    }
    public static void  deleteConRefs(List<Contact_Reference_Content__c>  conRefs){
        delete conRefs;
    }
    public static void  deleteAccRefs(List<Account_Reference_Content__c>  accRefs){
        delete accRefs;
    }
    public static void  deleteHitlists(List<Hit_List__c>  hitlists){
        delete hitlists;
    }
    public static List<Reference_Basic_Information__c> getRBIonMergeProcess(){
        List<Reference_Basic_Information__c> allRBIs = [SELECT Id, Account__c, Contact__c, Lifetime_Points__c, Current_Available_Balance_Points__c, RUL_Last_Updated_By__c, RUL_Period__c, RUL_Activities_will_do__c, Joined_Reference_Program__c, Managed_Reference_Account__c, Reference_Owner__c, Referenceability_Status__c, Is_Referenceable__c, Reference_Program_Candidate__c FROM Reference_Basic_Information__c WHERE Id IN: ConstantsController.RBIIdSet];
        return allRBIs;
    }
    
    /**
     * Method to fetch Content Attributes for Utility class
     */
    public static List<Content_Attribute__c> fetchContentAttributeinUtility(Set<Id>  attributes){
        List<Content_Attribute__c> conAtts = [SELECT Id FROM Content_Attribute__c WHERE Attribute__c In :attributes];
        return conAtts;
    }
    public static void deleteContactAttributes(List<Contact_Attribute__c> conAttToBeDeleted){
        delete conAttToBeDeleted;
    }
    public static List<Contact_Attribute__c> upsertContactAttributes(List<Contact_Attribute__c> conAtts){
        upsert conAtts;
        return conAtts;
    }
    public static List<Account_Attribute__c> upsertAccountAttributes(List<Account_Attribute__c> acAtts){
        upsert acAtts;
        return acAtts;
    }
    public static List<Account_Attribute__c> deleteAccountAttributes(List<Account_Attribute__c> acAtts){
        delete acAtts;
        return acAtts;
    }
    public static void deleteAccountAttributesOnRefRefreshTrigger(Set<string> accountAttributesDeleted){
        delete [SELECT Id FROM Account_Attribute__c WHERE id In :accountAttributesDeleted];
    }
    public static void deleteContactAttributesOnRefRefreshTrigger(Set<string> contactAttributesDeleted){
        delete [SELECT Id FROM Contact_Attribute__c WHERE id In :contactAttributesDeleted];
    }
    public static List<Account_Attribute__c> getAccountAttributesOnAddAtt(String selectedAttributeId){
        List<Account_Attribute__c> accAtt = [SELECT Id, Attribute__r.Name, Account__c, Is_fromMapping__c FROM Account_Attribute__c WHERE Id = : selectedAttributeId];
        return accAtt;
    }
    public static List<Contact_Attribute__c> getContactAttributesOnAddAtt(String selectedAttributeId){
        List<Contact_Attribute__c> accAtt = [SELECT Id, Attribute__r.Name, Contact__c,Is_fromMapping__c, Contact__r.AccountId FROM Contact_Attribute__c WHERE Id = : selectedAttributeId];
        return accAtt;
    }
    public static List<Account_Attribute__c> getAccountAttributesOnAddAtt2(String accountId, Set<string> deleteAttIds){
        List<Account_Attribute__c> accAtt = [SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c, Is_fromMapping__c FROM Account_Attribute__c WHERE account__c = : AccountId AND Id NOT IN: deleteAttIds AND contact__c = null AND Reference_Content__c = null ORDER BY Attribute__r.Parent__r.Name];
        return accAtt;
    }
    public static List<Contact_Attribute__c> getContactAttributesOnAddAtt2(String ContactId, Set<string> deleteAttIds){
        List<Contact_Attribute__c> accAtt = [SELECT Attribute__r.Name, Attribute__r.Parent__r.Name,Is_fromMapping__c,From_Account__c, Attribute__r.level__c FROM Contact_Attribute__c WHERE Contact__c = : ContactId AND Id NOT IN: deleteAttIds ORDER BY Attribute__r.Parent__r.Name];
        return accAtt;
    }
    
    public static List<Account_Attribute__c> getAccountAttributesInRefCon(Set<Id> accounts){
        List<Account_Attribute__c> accAtt = [SELECT Attribute__c, Account__c, Contact__c FROM Account_Attribute__c WHERE Account__c In: accounts AND contact__c = null AND Inheritable__c = true];
        return accAtt;
    }
    public static List<Account_Attribute__c> getAccountAttributesWithContact(Set<String> accountIds,Set<String> contactIds){
        List<Account_Attribute__c> accAtt = [SELECT Id FROM Account_Attribute__c WHERE Account__c In: accountIds AND Contact__c In: contactIds];
        return accAtt;
    }
    public static List<Account_Attribute__c> getAccountAttributesWithContact1(Set<String> contactIds,Set<String> attribIds){
        List<Account_Attribute__c> accAtt = [SELECT Id FROM Account_Attribute__c WHERE Attribute__c In: attribIds AND Contact__c In: contactIds];
        return accAtt;
    }
    public static List<Account_Attribute__c> getAccountAttributesInRefConTodelete(Set<Id> accountIds,Set<Id> refContentIds){
        List<Account_Attribute__c> accAtt = [SELECT Id FROM Account_Attribute__c WHERE Account__c In: accountIds AND Reference_Content__c In: refContentIds];
        return accAtt;
    }
    public static List<Account_Attribute__c> getAllAccountAttributes(Set<String> accountId){
        List<Account_Attribute__c> accAtt = [SELECT Id, Attribute__c,Is_fromMapping__c FROM Account_Attribute__c WHERE Account__c In :accountId];
        return accAtt;
    }
    
    public static List<Account_Attribute__c> getAccountAttributesInCopyNomi(Id accountId){
        List<Account_Attribute__c> accAtt = [SELECT Id, Attribute__c,Is_fromMapping__c FROM Account_Attribute__c WHERE Account__c =:accountId AND Contact__c = null];
        return accAtt;
    }
    
    public static List<Account_Attribute__c> getAccountAttributes(String accountId){
        List<Account_Attribute__c> accAtt = [SELECT Id,Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c,Attribute__c,Is_fromMapping__c  FROM Account_Attribute__c WHERE Account__c =:accountId AND Contact__c = null AND Reference_Content__c = null];
        return accAtt;
    }
    
    public static List<Contact_Attribute__c> getContactAttributesInCopyNomi(Set<String> contactIds){
        List<Contact_Attribute__c> accAtt = [SELECT Id, Attribute__c,Contact__c, Attribute__r.Name FROM Contact_Attribute__c WHERE Contact__c In :contactIds];
        return accAtt;
    }
    /*
     * For System.QueryException: invalid query locator by Rekha
     */
    public static List<Account_Attribute__c> getAllAccountAttributesOfAccount(Set<string> accountSet){
        List<Account_Attribute__c> accAtt = [SELECT Account__c, Attribute__c,Contact__c,Reference_Content__c,Attribute__r.Name, Attribute__r.Level__c,
                                    Reference_Basic_Information__c,Inheritable__c FROM Account_Attribute__c WHERE Account__c In: accountSet];
        return accAtt;
    }
    public static List<Account_Attribute__c> getAllAccountAttributesOfAccountSharedContact(Set<string> accountSet,string contactId){
        List<Account_Attribute__c> accAtt = [SELECT Account__c, Attribute__c,Contact__c FROM Account_Attribute__c WHERE Account__c In: accountSet AND Contact__c = :contactId];
        return accAtt;
    }
    public static List<Contact_Attribute__c> getContactAttributes(List<Contact_Attribute__c> contactsAttsToBeDel){
        List<Contact_Attribute__c> deleteContactAtts = [SELECT Id FROM Contact_Attribute__c WHERE Id In: contactsAttsToBeDel];
        return deleteContactAtts;
    }
    public static List<Content_Attribute__c> deleteContentAtt(List<Content_Attribute__c> conAtts){
        delete conAtts;
        return conAtts;
    }
    public static List<Content_Attribute__c> upsertContentAtt(List<Content_Attribute__c> conAtts){
        upsert conAtts;
        return conAtts;
    }
    public static List<Account_Attribute__c> accAttInAttributeTriggerHandler(Set<String> nameChangedAttrib){
        List<Account_Attribute__c> AccAtt = [SELECT Id,Account__c FROM Account_Attribute__c WHERE Attribute__c In: nameChangedAttrib];
        return AccAtt;
    }
    public static List<Contact_Attribute__c> conAttInAttributeTriggerHandler(Set<String> nameChangedAttrib){
        List<Contact_Attribute__c> AccAtt = [SELECT Id,Contact__c FROM Contact_Attribute__c WHERE Attribute__c In: nameChangedAttrib];
        return AccAtt;
    }
    public static List<Account_Attribute__c> getAccountAttribute2(Set<String> AttIdSet){
        List<Account_Attribute__c> accAtt = [SELECT Id, Account__c, Attribute__c, Inheritable__c,Attribute__r.Parent__c,Attribute__r.level__c FROM Account_Attribute__c WHERE Attribute__c In: AttIdSet  AND Reference_Content__c = null AND Contact__c = null];
        return accAtt;
    }
    public static List<Account_Attribute__c> getAccountAttribute3(Set<Id> accountSet){
        List<Account_Attribute__c> accAtt = [SELECT Account__c, Attribute__c FROM Account_Attribute__c WHERE Account__c In: accountSet AND Reference_Content__c = null AND Contact__c = null];
        return accAtt;
    }
    public static List<Contact_Attribute__c> getContactAttribute2(Set<String> AttIdSet){
        List<Contact_Attribute__c> conAtt = [SELECT Contact__c, Attribute__c FROM Contact_Attribute__c WHERE Attribute__c In: AttIdSet];
        return conAtt;
    }
    public static List<Contact_Attribute__c> getContactAttribute3(Set<Id> conIdSet){
        List<Contact_Attribute__c> conAtt = [SELECT Contact__c, Attribute__c,Account__c,from_Account__c FROM Contact_Attribute__c WHERE Contact__c In: conIdSet];
        return conAtt;
    }
    public static List<Account_Attribute__c> getAccountAttributeinRBI1(Set<Id> accounts){
        List<Account_Attribute__c> accAtts = [SELECT name,Id,attribute__r.Name,From_Opportunity__c,Account__r.Id,Attribute__r.Id,Attribute__r.Product_ID__c,Is_fromMapping__c,Inheritable__c FROM Account_Attribute__c WHERE Account__c In : accounts AND Contact__c = null AND Reference_Content__c = null];
        return accAtts;
    }
    public static List<Contact_Attribute__c> getContactAttributesInRBI3(List<Contact> contacts){
        List<Contact_Attribute__c> conAtts = [SELECT name,Id,attribute__r.Name,Contact__r.Id,Attribute__r.Id,Is_fromMapping__c FROM Contact_Attribute__c WHERE Contact__c In :contacts];
        return conAtts;
    }
    public static List<Contact_Attribute__c> getContactAttributesInRBI4(Set<String> modifiedContactIDs){
        List<Contact_Attribute__c> conAtts = [SELECT Contact__c, Attribute__c FROM Contact_Attribute__c WHERE Contact__c In: modifiedContactIDs AND from_Account__c != true];
        return conAtts;
    }
    public static List<Contact_Attribute__c> getContactAttribute5(Set<Id>  attributes){
        List<Contact_Attribute__c> conAtts = [SELECT Id FROM Contact_Attribute__c WHERE Attribute__c In :attributes];
        return conAtts;
    }
    public static List<Account_Attribute__c> getAccountAttribute5(Set<Id>  attributes){
        List<Account_Attribute__c> conAtts = [SELECT Id FROM Account_Attribute__c WHERE Attribute__c In :attributes];
        return conAtts;
    }
    
    
    
    
    
    
    public static List<Account> getAccountOnAddAtt(String accountId, Set<string> deleteAttIds){
        List<Account> accs = [SELECT name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c, Is_fromMapping__c FROM Account_Attributes__r WHERE contact__c = null AND Reference_Content__c = null AND Id NOT IN: deleteAttIds ORDER BY Attribute__r.Parent__r.Name), (SELECT Name, Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) FROM Account WHERE Id = : accountId LIMIT 1];
        return accs;
    }
    public static List<Account> getContactAccountOnAddAtt(String accountId){
        List<Account> accs = [SELECT name, (SELECT Attribute__r.Name, Attribute__r.Parent__r.Name, Attribute__r.level__c, Is_fromMapping__c FROM Account_Attributes__r WHERE contact__c = null AND Reference_Content__c = null), (SELECT Name, Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) FROM Account WHERE Id = : accountId LIMIT 1];
        return accs;
    }
    public static List<Contact> getContactOnAddAtt(String contactId, Set<string> deleteAttIds){
        List<Contact> cons = [SELECT AccountId, Account.Name, (SELECT Attribute__r.Name, Account__r.Name, Attribute__r.Parent__r.Name,From_Account__c, Attribute__r.level__c, Is_fromMapping__c FROM Contact_Attributes__r WHERE Id NOT IN: deleteAttIds ORDER BY Attribute__r.Parent__r.Name), name, (SELECT Name, Account__c, Contact__r.Name, Contact__c, Is_Referenceable__c, Reference_Program_Candidate__c, Referenceability_Status__c,Roll_up_Attributes_to_All_Accounts__c,Roll_up_Attributes_to_Primary_Account__c FROM Reference_Basic_Informations__r) FROM Contact WHERE Id = : contactId LIMIT 1];
        return cons;
    }
    public static List<Account> getAccountInRefCon(Set<Id> accIds,Set<Id> referAttribIds){
        List<Account> accs = [SELECT Id,(SELECT Attribute__c, Account__c FROM Account_Attributes__r WHERE Reference_Content__c In: referAttribIds),(SELECT account__c,Referenceability_Status__c,Is_Referenceable__c FROM Reference_Basic_Informations__r WHERE Generic_Account__c = false AND contact__c =  null) FROM Account WHERE Id In :accIds];
        return accs;
    }
    public static List<Account> getAccountUsingDynamicSOQL(String query){
        
        return Database.query(query);
    }
    public static List<Account> getAccountUsingDynamicSOQL1(String query,Set<String> accountIds){
        
        return Database.query(query);
    }
    public static List<Contact> getContactUsingDynamicSOQL(String query){
        
        return Database.query(query);
    }
    public static List<Contact> getContactsUsingDynamicSOQL(String query,Set<Id> contactIdsForAttMapping){
        
        return Database.query(query);
    }
    public static List<Account> getAccountRecordsWithAllRelatedRecordsSharedContact(Set<String> accountIdSet){
        List<Account> acc = [SELECT Id,(SELECT Attribute__c FROM Account_Attributes__r WHERE Reference_Content__c = null AND Contact__c = null AND Inheritable__c = true),
                                    (SELECT Id,Contact__c,Account__c,Generic_Account__c, Is_Referenceable__c, Referenceability_Status__c,Reference_Program_Candidate__c
                                     FROM Reference_Basic_Informations__r WHERE Contact__c = null)
                                    FROM Account WHERE Id In :accountIdSet];
        return acc;
    }
    public static List<Contact> getCntactRecordsWithAllRelatedRecordsSharedContact(Set<string> contactIds){
        List<Contact> acc = [SELECT Id,(SELECT Contact__c, Attribute__c FROM Contact_Attributes__r WHERE From_Account__c = false),
                                    (SELECT Id,Contact__c,Account__c, Is_Referenceable__c, Referenceability_Status__c,Reference_Program_Candidate__c,
                                    Roll_up_Attributes_to_All_Accounts__c,Roll_up_Referenceability_to_All_Accounts__c,Inherit_Attributes_from_All_Accounts__c,
                                    Inherit_Attributes_from_Primary_Account__c,Roll_up_Attributes_to_Primary_Account__c,Roll_up_Referenceability_to_Primary_Acc__c
                                    FROM Reference_Basic_Informations__r),
                                    (SELECT id, Account__c, Contact__c,Referenceability_Type__c,Comment__c,Verified__c,
                                    Status__c FROM Referenceabilities__r)
                                    FROM Contact WHERE Id In :contactIds];
        return acc;
    }
    public static List<Account> getAccountRecordsWithAllRelatedRecordsSharedContactonDelete(Set<String> accountIdSet,Set<String> contactIdset){
        List<Account> acc = [SELECT Id,(SELECT Attribute__c,Contact__c,Account__c FROM Account_Attributes__r WHERE Reference_Content__c = null AND Contact__c != null AND Contact__c IN :contactIdset),
                                    (SELECT id, Account__c, Contact__c FROM Referenceabilities__r WHERE Contact__c != null AND Contact__c IN :contactIdset)
                                    FROM Account WHERE Id In :accountIdSet];
        return acc;
    }
    public static List<Contact> getCntactRecordsWithAllRelatedRecordsSharedContactonDelete(Set<string> contactIds){
        List<Contact> acc = [SELECT Id,(SELECT Contact__c, Attribute__c,Account__c FROM Contact_Attributes__r WHERE From_Account__c = true)
                                    FROM Contact WHERE Id In :contactIds];
        return acc;
    }
    //to be used in RBITriggerHandler AND get all the RBI associated to the Account
    public static List<Account> getAccountRecordsWithAllRelatedRecords(Set<String> accountIdSet){
        List<Account> acc = [SELECT Id,(SELECT Account__c, Attribute__c,Contact__c,Reference_Content__c,Attribute__r.Name, Attribute__r.Level__c,
                                    Reference_Basic_Information__c,Inheritable__c FROM Account_Attributes__r),
                                    (SELECT Reference_Content__c,Account__c FROM Account_Reference_Contents__r),
                                    (SELECT Id,Attributes__c,Contact__c,Last_Att_Ref_Update__c,Att_Ref_Last_Update_By__c,Attribute_Ids__c,
                                    ReferenceabilityType_Ids1__c, Account__c, Is_Referenceable__c, Referenceability_Status__c,Reference_Program_Candidate__c,
                                    Referenceability__c,ReferenceabilityType_Ids2__c FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true),
                                    (SELECT Referenceability_Type__c,Contact__c  FROM Referenceabilities__r)
                                    FROM Account WHERE Id In :accountIdSet];
        return acc;
    }
    public static List<Account_Attribute__c> getAccountAttributesForAccount(Set<String> accountIdSet) { 
        return [SELECT Account__c, Attribute__c,Contact__c,Reference_Content__c,Attribute__r.Name, Attribute__r.Level__c,
                                    Reference_Basic_Information__c,Inheritable__c FROM Account_Attribute__c WHERE Account__c IN :accountIdSet];
    }
    
    //for invalid query locater #662
    public static List<Account> getAccountRecordsWithAllRelatedRecordsAndOnlyAccRBI(Set<String> accountIdSet){
        List<Account> acc = [SELECT Id,(SELECT Account__c, Attribute__c,Contact__c,Reference_Content__c,Attribute__r.Name, Attribute__r.Level__c,
                                    Reference_Basic_Information__c,Inheritable__c FROM Account_Attributes__r),
                                    (SELECT Reference_Content__c,Account__c FROM Account_Reference_Contents__r),
                                    (SELECT Id,Attributes__c,Contact__c,Last_Att_Ref_Update__c,Att_Ref_Last_Update_By__c,Attribute_Ids__c,
                                    ReferenceabilityType_Ids1__c, Account__c, Is_Referenceable__c, Referenceability_Status__c,Reference_Program_Candidate__c,
                                    Referenceability__c,ReferenceabilityType_Ids2__c FROM Reference_Basic_Informations__r WHERE Contact__c = null),
                                    (SELECT Referenceability_Type__c,Contact__c  FROM Referenceabilities__r)
                                    FROM Account WHERE Id In :accountIdSet];
        return acc;
    }
    //to be used in RBITriggerHandler AND get all the RBI associated to the Account
    public static List<Account> getAccountRecordsWithAllRBIAndAtt(Set<String> accountIdSet){
        List<Account> acc = [SELECT Id,//(SELECT Account__c, Attribute__c,Contact__c,Reference_Content__c,Attribute__r.Name, Attribute__r.Level__c,
                                    //Reference_Basic_Information__c,Inheritable__c FROM Account_Attributes__r),
                                    (SELECT Reference_Content__c,Account__c FROM Account_Reference_Contents__r),
                                    (SELECT Id,Attributes__c,Contact__c,Last_Att_Ref_Update__c,Att_Ref_Last_Update_By__c,Attribute_Ids__c,Label_Ids1__c,Label_Ids2__c,
                                    Parent_Attributes__c,Account__r.OwnerId,Reference_Owner__c,Profile_Update_Owner__c,
                                    ReferenceabilityType_Ids1__c, Account__c, Is_Referenceable__c, Referenceability_Status__c,Reference_Program_Candidate__c,
                                    Referenceability__c,ReferenceabilityType_Ids2__c FROM Reference_Basic_Informations__r WHERE Contact__c = null)
                                    FROM Account WHERE Id In :accountIdSet];
        return acc;
    }
    public static List<Contact> getContactMapOnProfileUpadte(Set<string> contactIds){
        List<Contact> contactMap = [SELECT Id, Name, (SELECT Referenceability_Type__r.Name, Account__c, Contact__c FROM Referenceabilities__r),
                                                (SELECT Attribute__r.Id FROM Contact_Attributes__r WHERE From_Account__c = false),
                                                (SELECT Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c != null)
                                                FROM Contact WHERE Id In :contactIds ORDER BY Name];
        return contactMap;
    }
    public static List<Account> getAccountRecordsWithAllRBIAndRef(Set<String> accountIdSet){
        List<Account> acc = [SELECT Id,(SELECT Id,Attributes__c,Contact__c,Last_Att_Ref_Update__c,Att_Ref_Last_Update_By__c,Attribute_Ids__c,
                                    ReferenceabilityType_Ids1__c, Account__c, Is_Referenceable__c, Referenceability_Status__c,Reference_Program_Candidate__c,
                                    Account__r.OwnerId,Reference_Owner__c,Profile_Update_Owner__c,Referenceability__c,ReferenceabilityType_Ids2__c 
                                    //for invalid query locater #662
                                    FROM Reference_Basic_Informations__r WHERE Contact__c = null),
                                    (SELECT id, Account__c, Contact__c,Referenceability_Type__c,
                                    Referenceability_Type__r.Referenceability_no__c, Referenceability_Type__r.Name, 
                                    Status__c FROM Referenceabilities__r)
                                    FROM Account WHERE Id In :accountIdSet];
        return acc;
    }
    
    //to be used in RRAtriggerHandler
    public static List<Account> getAccountRecords(Set<String> accountIdSet){
        List<Account> acc = [SELECT id, name, OwnerId,
                            (SELECT Account__c,Contact__c,Reference_Content__c, Attribute__c FROM Account_Attributes__r WHERE Contact__c != null), 
                            (SELECT Name,Id, account__c,Contact__c,Reference_Owner__c, Managed_Reference_Account__c,
                            Reference_Program_Candidate__c,Is_Referenceable__c, Referenceability_Status__c 
                            FROM Reference_Basic_Informations__r WHERE Contact__c = null) 
                            FROM Account WHERE id IN: accountIdSet];
        return acc;
    }
    public static List<Account> getAccounts(Set<string> accountsIds){
        List<Account> accounts = [SELECT Id, Name FROM Account WHERE Id IN : accountsIds ORDER BY Name LIMIT: limits.getLimitQueryRows()];
        return accounts;
    }
    
    public static List<Account> getAccountRecordsforLookup(Set<String> setAccountIds, Integer recordslimit){
        List<Account> acc = [SELECT Name, Site, Type,OwnerId,(SELECT Name,Id,Generic_Account__c, Account__c, Reference_Owner__c,Managed_Reference_Account__c, Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) FROM Account WHERE Id IN: setAccountIds ORDER BY Name LIMIT :recordslimit];
        return acc;
    }
    public static List<Contact> getContactRecordsforLookup(Set<String> setContactIds, Integer recordslimit){
        List<Contact> conList = [SELECT Name, Account.Site, Account.Name,AccountId, (SELECT Id, account__c, Contact__c, Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c,Roll_up_Referenceability_to_Primary_Acc__c,Roll_up_Referenceability_to_All_Accounts__c FROM Reference_Basic_Informations__r) FROM Contact WHERE Id IN: setContactIds ORDER BY Name LIMIT :recordslimit];
        return conList;
    }
    
    public static List<Contact> getAccountContactOnAddRef(String accountId){
        List<Contact> conList = [SELECT id, name, (SELECT Id, account__c, Contact__c,Referenceability_Status__c, Is_Referenceable__c,Reference_Program_Candidate__c,Roll_up_Referenceability_to_All_Accounts__c,Roll_up_Referenceability_to_Primary_Acc__c FROM Reference_Basic_Informations__r) FROM contact WHERE accountId = : accountId ORDER BY Name];
        return conList;
    }
    public static List<Contact> getContactWithRelatedRecords(Set<String> setAccountIds){
        List<Contact> contacts = [SELECT Id, AccountId, (SELECT Contact__c, Attribute__c,From_Account__c, Account__c FROM Contact_Attributes__r), 
                            (SELECT contact__c, Account__c, Referenceability_Status__c, Is_Referenceable__c, Reference_Program_Candidate__c 
                            FROM Reference_Basic_Informations__r)
                            FROM Contact WHERE AccountId In: setAccountIds ORDER BY Name];
        return contacts;
    }
    public static List<Contact> getContactWithRelatedRecordsSharedContact(Set<String> setAccountIds,Set<string> contactIds){
        List<Contact> contacts = [SELECT Id, AccountId, (SELECT Contact__c, Attribute__c,From_Account__c, Account__c FROM Contact_Attributes__r), 
                            (SELECT contact__c,Account__c, Referenceability_Status__c, Is_Referenceable__c, Reference_Program_Candidate__c,
                            Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c FROM Reference_Basic_Informations__r)
                            FROM Contact WHERE AccountId In: setAccountIds OR Id IN :contactIds ORDER BY Name];
        return contacts;
    }

    public static List<Contact> getContactOnRefTrigger(Set<String> contactIds){
        List<Contact> conList = [SELECT Id, AccountId, (SELECT Contact__c,Last_Att_Ref_Update__c,ReferenceabilityType_Ids1__c,ReferenceabilityType_Ids2__c,Is_Referenceable__c, Referenceability_Status__c,Reference_Program_Candidate__c, Referenceability__c, Reference_Owner__c, Profile_Update_Owner__c, Last_Refresh_Date__c, Contact__r.OwnerId FROM Reference_Basic_Informations__r),(SELECT Id, Account__c,Contact__c, Referenceability_Type__c, Referenceability_Type__r.Referenceability_no__c,Referenceability_Type__r.Name, Status__c FROM Referenceabilities__r) FROM Contact WHERE Id In: contactIds];
        return conList;
    }

    public static List<Account> getAccountOnRefTrigger(Set<String> accountIds){
        List<Account> conList = [SELECT Id, (SELECT Referenceability_Status__c,Is_Referenceable__c, Reference_Program_Candidate__c FROM Reference_Basic_Informations__r WHERE Generic_Account__c = false AND Contact__c = null),(SELECT Account__c, Referenceability_Type__c, Contact__c FROM Referenceabilities__r) FROM Account WHERE Id In: accountIds];
        return conList;
    }
    public static List<Contact> getContactOnRefTrigger2(Set<String> contactIds, List<Referenceability__c> oldReferenciablities){
        List<Contact> conList = [SELECT Id,AccountId,(SELECT Contact__c,Account__c, Referenceability_Type__c, Comment__c, Verified__c FROM Referenceabilities__r WHERE Id NOT IN: oldReferenciablities), (SELECT Referenceability_Status__c, Is_Referenceable__c, Reference_Program_Candidate__c FROM Reference_Basic_Informations__r) FROM Contact WHERE Id In: contactIds];
        return conList;
    }

    public static List<Account> getAccountOnRefTrigger2(Set<String> accountIds, List<Referenceability__c> oldReferenciablities){
        List<Account> conList = [SELECT Id,(SELECT Account__c, Referenceability_Type__c, Contact__c FROM Referenceabilities__r WHERE Id NOT IN: oldReferenciablities ), (SELECT Referenceability_Status__c,Is_Referenceable__c, Reference_Program_Candidate__c FROM Reference_Basic_Informations__r WHERE Generic_Account__c = false AND Contact__c = null) FROM Account WHERE Id In: accountIds];
        return conList;
    }

    //Method to query contact SelectRefUseContactsController
    public static List<Contact> activateContactRecords(Set<String> contactIds){
        List<Contact> con = [SELECT AccountId,Phone,Email,Title,Id,FirstName, LastName,Account.Name,
                            (SELECT Contact__c,Contact__r.AccountId, Attribute__c, Attribute__r.Name,Attribute__r.Level__c,Reference_Basic_Information__c,
                            Account__c FROM Contact_Attributes__r),
                            (SELECT Id,account__c,Attribute_Ids__c,Attributes__c,Contact__c,Reference_Program_Candidate__c,Is_Referenceable__c, Label_Ids1__c,Label_Ids2__c,Parent_Attributes__c,
                            Roll_up_Attributes_to_All_Accounts__c,Roll_up_Attributes_to_Primary_Account__c,Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c,
                            Referenceability_Status__c,Contact__r.Id,Contact__r.AccountId, Contact__r.OwnerId, Reference_Owner__c, Profile_Update_Owner__c
                            FROM Reference_Basic_Informations__r) FROM Contact WHERE id IN : contactIds];
        return con;
    }
    public static Map<Id, Contact> getAccountContact(String accId){
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name, AccountId, (SELECT Name, Account__c, Contact__r.Name, Contact__c , Reference_Program_Candidate__c, Is_Referenceable__c, Referenceability_Status__c FROM Reference_Basic_Informations__r) FROM Contact WHERE AccountId = : accId ORDER BY Name LIMIT: limits.getLimitQueryRows()]);
        return contactMap;
    }
    /**
     * Method to get contacts related to an account
     */
    public static List<Contact> getAccountContacts(String accId, Custom_Settings__c cs) {
        Set<Id> contactIds = getAccountContactsForNomination(accId, cs);
        List<Contact> contacts = ([SELECT id, Name, Title, Email, Phone, AccountId,
                            (SELECT Id, Account__c, Contact__c, Name, Is_Referenceable__c, Referenceability_Status__c,
                            RUL_Last_Activity_Date__c, Reference_Program_Candidate__c, Roll_up_Referenceability_to_All_Accounts__c,
                            Roll_up_Referenceability_to_Primary_Acc__c, Referenceability__c, Attributes__c FROM Reference_Basic_Informations__r) 
                            FROM Contact WHERE AccountId = : accId OR Id IN :contactIds ORDER BY LastName LIMIT : Limits.getLimitQueryRows()]);
        return contacts;
    }
    
    /**
     * method to get all contacts for the specified accounts
     * author: Gaurav Saini (2 Sep, 2017) #919
     */
    public static Map<String, Set<String>> getAccountContacts(Set<String> accountIds, Custom_Settings__c cs) {
        Map<String, Set<String>> accountContactIdsMap = new Map<String, Set<String>>();
        Map<String, Set<String>> tempAccountContactIdsMap = new Map<String, Set<String>>();
        Set<String> contactIds = new Set<String>();
        
        for (String accId : accountIds) {
            accountContactIdsMap.put(accId, new Set<String>());
        }
        
        if (cs == null) {
            cs = UtilityController.getCustomSettings();
        }
        
        if (cs.Shared_Contacts__c && cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != ''
                    && cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != '') {
            String query = 'SELECT ' + cs.Shared_Account_Field__c + ', ' + cs.Shared_Contact_Field__c
                            + ' FROM ' + cs.Shared_Contact_Object__c
                            + ' WHERE ' + cs.Shared_Account_Field__c + ' IN :accountIds '
                            + 'AND ' + cs.Shared_Contact_Field__c +' != null';
            List<sObject> objectList = Database.query(query);
            
            if (objectList != null && objectList.size() > 0) {
                
                for (sObject obj : objectList) {
                    
                    if (!tempAccountContactIdsMap.containsKey((String)obj.get(cs.Shared_Account_Field__c))) {
                        tempAccountContactIdsMap.put((String)obj.get(cs.Shared_Account_Field__c), new Set<String>());
                    }
                    contactIds.add((String)obj.get(cs.Shared_Contact_Field__c));
                    tempAccountContactIdsMap.get((String)obj.get(cs.Shared_Account_Field__c)).add((String)obj.get(cs.Shared_Contact_Field__c));
                }
            }
        }
        /*
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact
                                    WHERE AccountId IN :accountIds
                                    LIMIT :Limits.getLimitQueryRows()];
        
        if (contacts != null && contacts.size() > 0) {
            
            for (Contact con : contacts) {
                
                if (!tempAccountContactIdsMap.containsKey(con.AccountId)) {
                    tempAccountContactIdsMap.put(con.AccountId, new Set<String>());
                }
                tempAccountContactIdsMap.get(con.AccountId).add(con.Id);
                contactIds.add(con.Id);
            }
        }
        */
        
        for (Reference_Basic_Information__c conRbi : [SELECT Id, Contact__c, Account__c
                                                        FROM Reference_Basic_Information__c
                                                        WHERE (Account__c IN :accountIds
                                                        OR Contact__c IN :contactIds)
                                                        AND Is_Referenceable__c = true
                                                        AND Contact__c != null]) {
            
            if (accountContactIdsMap.containsKey(conRbi.Account__c)) {
                accountContactIdsMap.get(conRbi.Account__c).add(conRbi.Contact__c);
            }
            
            for (String accId : tempAccountContactIdsMap.keySet()) {
                
                if (accountContactIdsMap.containsKey(accId) && tempAccountContactIdsMap.get(accId).contains(conRbi.Contact__c)) {
                    accountContactIdsMap.get(accId).add(conRbi.Contact__c);
                }
            }
        }
        return accountContactIdsMap;
    }
    
    /**
     * Method to get contact Ids related to an account
     */
    public static Set<Id> getAccountContactsForNomination(String accId, Custom_Settings__c cs) {
        
        if (cs == null) {
            cs = UtilityController.getCustomSettings();
        }
        Set<Id> contactIds = new Set<Id>();
        
        if (cs.Shared_Contacts__c && cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != '' 
                            && cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != '') {
            String query = 'SELECT ' + cs.Shared_Account_Field__c + ', ' + cs.Shared_Contact_Field__c + ' FROM ' + cs.Shared_Contact_Object__c
                                     + ' WHERE ' + cs.Shared_Account_Field__c + ' = :accId AND '+ cs.Shared_Contact_Field__c +' != null';
            List<sObject> objectList = Database.query(query);
            
            if (objectList != null && objectList.size() > 0) {
                
                for (sObject obj : objectList) {
                    contactIds.add((String)obj.get(cs.Shared_Contact_Field__c));
                }
            }
        }
        return contactIds;
    }
    /**
     * Method to get contacts related to an account on Match page
     */
    public static List<Contact> getContactsToDisplay(String accountId, Boolean isMember, Custom_Settings__c cs) {
        List<Contact> contactList = new List<Contact>();
        Set<Id> contactIds = getAccountContactsForNomination(accountId, cs);
        if (!isMember) {
            contactList = [SELECT Id, Name, AccountId, OwnerId, (SELECT Reference_Request_Account__c, Contact__c, Approval_Status__c, Deadline__c, 
                            Referenceability_Type__c, Contact_Request_Status__c FROM Reference_Request_Account_Contacts__r WHERE 
                            Contact_Request_Status__c = :ConstantsController.IN_PROGRESS
                            OR Contact_Request_Status__c = :ConstantsController.ONHOLD
                            OR Contact_Request_Status__c = :ConstantsController.NOT_STARTED
                            ORDER BY Deadline__c DESC),
                            (SELECT Account__c,Contact__c,Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, Referenceability__c, 
                            Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c 
                            FROM Reference_Basic_Informations__r
                            WHERE Reference_Program_Candidate__c = true)
                            FROM Contact
                            WHERE AccountId =: accountId OR Id IN :contactIds ORDER BY LastName];
        }
        else {
            contactList = [SELECT Id, Name, AccountId, OwnerId, (SELECT Reference_Request_Account__c, Contact__c, Approval_Status__c, Deadline__c, 
                            Referenceability_Type__c, Contact_Request_Status__c FROM Reference_Request_Account_Contacts__r WHERE 
                            Contact_Request_Status__c = :ConstantsController.IN_PROGRESS
                            OR Contact_Request_Status__c = :ConstantsController.ONHOLD
                            OR Contact_Request_Status__c = :ConstantsController.NOT_STARTED
                            ORDER BY Deadline__c DESC),
                            (SELECT Account__c,Contact__c,Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, Referenceability__c, 
                            Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c 
                            FROM Reference_Basic_Informations__r
                            WHERE Is_Referenceable__c = true AND (Referenceability_Status__c != :ConstantsController.INACTIVE AND Referenceability_Status__c != ''))
                            FROM Contact
                            WHERE AccountId =: accountId OR Id IN :contactIds ORDER BY LastName];
        }
        return contactList;
    }
    //Method use in InvitationContactsLookupController
    public static List<Contact> getInvitationContact(String soql_contact) {
        return Database.query(soql_contact);
    }
    
    public static List<Account> upsertAccount(List<Account> account) {
        upsert account;
        return account;
    }
    
    public static Contact upsertContact(Contact contact) {
        upsert contact;
        return contact;
    }
    
    public static List<Contact> upsertContacts(List<Contact> contacts) {
        upsert contacts;
        return contacts;
    }
    
    public static List<Contact> getContact(Set<String> contactIds) {
        List<Contact> contacts = [SELECT Title, Phone, Email, Name, AccountId, Account.Name FROM Contact WHERE Id IN :contactIds];
        return contacts;
    }
    
    public static List<Contact> getContactInRBI1(Set<String> accountIds) {
        List<Contact> contacts = [SELECT Id,Name,AccountId ,(SELECT Attribute__c,from_Account__c,Contact__c FROM Contact_Attributes__r WHERE from_Account__c = false),(SELECT Is_Referenceable__c,Account__c,Contact__c,Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true AND (Referenceability_Status__c = 'Active' OR Referenceability_Status__c = 'Caution')) FROM Contact WHERE AccountId In :accountIds];
        return contacts;
    }
    
    public static List<Contact> getContactInRBI1SharedContactfromBatch(Id accountId,Set<string> contactIds) {
        List<Contact> contacts = [SELECT Id,Name,AccountId ,(SELECT Attribute__c,from_Account__c,Contact__c,Account__c FROM Contact_Attributes__r),
        (SELECT Account__c, Referenceability_Type__c,Comment__c,Verified__c,Status__c, Contact__c,Referenceability_Type__r.Name FROM Referenceabilities__r),
        (SELECT Is_Referenceable__c,Account__c,Contact__c,Referenceability_Status__c,Roll_up_Referenceability_to_All_Accounts__c,
        Roll_up_Attributes_to_All_Accounts__c,Roll_up_Attributes_to_Primary_Account__c,Roll_up_Referenceability_to_Primary_Acc__c,
        Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true AND 
        (Referenceability_Status__c = 'Active' OR Referenceability_Status__c = 'Caution')) 
        FROM Contact WHERE AccountId  = :accountId OR Id IN :contactIds];
        return contacts;
    }
    
    public static List<Contact> getContactInRBI1SharedContact(Set<String> accountIds,Set<string> contactIds) {
        List<Contact> contacts = [SELECT Id,Name,AccountId ,(SELECT Attribute__c,from_Account__c,Contact__c FROM Contact_Attributes__r WHERE from_Account__c = false),
        (SELECT Account__c, Referenceability_Type__c,Comment__c,Verified__c,Status__c, Contact__c,Referenceability_Type__r.Name FROM Referenceabilities__r),
        (SELECT Is_Referenceable__c,Account__c,Contact__c,Referenceability_Status__c,Roll_up_Attributes_to_All_Accounts__c,Roll_up_Attributes_to_Primary_Account__c,
        Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true AND 
        (Referenceability_Status__c = 'Active' OR Referenceability_Status__c = 'Caution')) 
        FROM Contact WHERE AccountId In :accountIds OR Id IN :contactIds];
        return contacts;
    }
    
    
    /**
     * method to get Contact details on the basis of Account Ids
     * author: Rajesh (20 Feb, 2018) for #REF-1346
     * changes #REF-1346 Handle 50001 too many SQL */
    public static List<Contact> getContactRBITriggerHandler3(Set<String> accountIds) {
        List<Contact> contacts = new List<Contact>();
        
        try {
            contacts = [SELECT Id,AccountId ,(SELECT Attribute__c,Contact__c,From_Account__c FROM Contact_Attributes__r  WHERE from_Account__c = false)
                                                ,(SELECT Is_Referenceable__c,Account__c,Contact__c,Referenceability_Status__c FROM Reference_Basic_Informations__r 
                                                WHERE Is_Referenceable__c = true) FROM Contact WHERE Id IN (SELECT Contact__c  FROM Reference_Basic_Information__c 
                                                WHERE Is_Referenceable__c = true AND Account__c IN :accountIds)]; 
            /*contacts = [SELECT Id,AccountId ,(SELECT Attribute__c,Contact__c,From_Account__c FROM Contact_Attributes__r  WHERE from_Account__c = false)
                                                ,(SELECT Is_Referenceable__c,Account__c,Contact__c,Referenceability_Status__c FROM Reference_Basic_Informations__r 
                                                WHERE Is_Referenceable__c = true) FROM Contact WHERE Id IN (SELECT Contact__c  FROM Reference_Basic_Information__c 
                                                WHERE Is_Referenceable__c = true AND AccountId In :accountIds)]; */
        } catch(Exception ex) {
            List<String> errorMessages = new List<String>();
            errorMessages.add('Reference Profile Exception : <b>line # :' + ex.getLineNumber() + ' Type : </b>' 
                                + ex.getTypeName() + '<b> Message : </b>' + ex.getMessage());
            InflAPIAbstractHandler.sendInflExceptionEmail('Reference Profile Exception.', errorMessages);
        } 
        return contacts;
    }
    
     /**
     * method to get Contact details on the basis of Account Ids or Contact Ids
     * author: Rajesh (20 Feb, 2018) for #REF-1346
     * changes #REF-1346 Handle 50001 too many SQL */
    public static List<Contact> getContactRBITriggerHandler3SharedContact(Set<String> accountIds,Set<string> contactIds){
        List<Contact> contacts = new List<Contact>();
        
        try {
            contacts = [SELECT Id,AccountId ,(SELECT Attribute__c,Contact__c,From_Account__c FROM Contact_Attributes__r  WHERE from_Account__c = false),
                                            (SELECT Is_Referenceable__c,Account__c,Contact__c,Referenceability_Status__c,Roll_up_Attributes_to_All_Accounts__c,
                                            Roll_up_Attributes_to_Primary_Account__c,Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c 
                                            FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true),(SELECT Account__c, Referenceability_Type__c,Comment__c,
                                            Verified__c,Status__c, Contact__c,Referenceability_Type__r.Name FROM Referenceabilities__r) FROM Contact 
                                            WHERE Id IN (SELECT Contact__c  FROM Reference_Basic_Information__c 
                                                WHERE Is_Referenceable__c = true AND (Account__c IN :accountIds OR Contact__c IN :contactIds))];
        /*contacts = [SELECT Id,AccountId ,(SELECT Attribute__c,Contact__c,From_Account__c FROM Contact_Attributes__r  WHERE from_Account__c = false),
                                            (SELECT Is_Referenceable__c,Account__c,Contact__c,Referenceability_Status__c,Roll_up_Attributes_to_All_Accounts__c,
                                            Roll_up_Attributes_to_Primary_Account__c,Inherit_Attributes_from_All_Accounts__c,Inherit_Attributes_from_Primary_Account__c 
                                            FROM Reference_Basic_Informations__r WHERE Is_Referenceable__c = true),(SELECT Account__c, Referenceability_Type__c,Comment__c,
                                            Verified__c,Status__c, Contact__c,Referenceability_Type__r.Name FROM Referenceabilities__r) FROM Contact 
                                            WHERE AccountId In :accountIds OR Id IN :contactIds];*/ 
                                         
        } catch (Exception ex) { 
            List<String> errorMessages = new List<String>();
            errorMessages.add('Reference Profile Exception : <b>line # :' + ex.getLineNumber() + ' Type : </b>' 
                                + ex.getTypeName() + '<b> Message : </b>' + ex.getMessage());
            InflAPIAbstractHandler.sendInflExceptionEmail('Reference Profile Exception.', errorMessages);           
        }
        return contacts;
    }

    public static List<Referenceability__c> upsertReferenceabilities(List<Referenceability__c> refers) {
        upsert refers;
        return refers;
    }
    
    public static List<Referenceability__c> deleteReferenceabilities(List<Referenceability__c> refers) {
        delete refers;
        return refers;
    }
    
    public static List<Nomination__c> getNominations(Set<Id> nominations) {
        return [SELECT Id, Name,Note__c, CreatedById, Contact__r.Name, Contact__r.Account.Name, Account__r.Name FROM Nomination__c WHERE Id IN :nominations];
    }
    
    public static Nomination__c upsertNomination(Nomination__c nomination) {
        upsert nomination;
        return nomination;
    }
    
    public static Hit_List__c upsertHitList(Hit_List__c hitObj) {
        upsert hitObj;
        return hitObj;
    }
    
    public static List<Hit_List__c> updateHitList(List<Hit_List__c> hitObj) {
        update hitObj;
        return hitObj;
    }
    
    
    
    //referenceLeadForm
    public static Reference_Lead__c createRefLead(Reference_Lead__c refLead) {
        upsert refLead;
        Reference_Lead__c tmpObj = [SELECT Id,Nomination__c,Other_Info__c,Notification_response__c,Response_Received__c,
                                    Reference_Lead_Status__c,Nominated__c,Reference_Profile__c,Reference_Lead_Opportunity__c,
                                    No_Response_Date__c,Reference_Lead_Opportunity__r.Owner.Name,Reference_Lead_Opportunity__r.Name,
                                    Reference_Lead_Owner__c,Follow_up_timeframe__c, Reference_Lead_Account__c,Reference_Lead_Account__r.Name, 
                                    Contact__c FROM Reference_Lead__c WHERE Id =:refLead.Id];   
        return tmpObj;
    }
    
    public static List<Reference_Lead__c> getReferenceLeads(Set<String> refLeadIds) {
        List<Reference_Lead__c> refLeads = [SELECT Id, Nomination__c, Other_Info__c, Nominated__c, Reference_Lead_Account__c, Reference_Lead_Account__r.Name, Contact__c, Contact__r.Name FROM Reference_Lead__c WHERE Id IN :refLeadIds];
        return refLeads;
    }
    
    public static string returnAccountName(Reference_Lead__c refLead) {
        Reference_Lead__c tmpObj = [SELECT Reference_Lead_Account__r.Name FROM Reference_Lead__c WHERE Id =:refLead.Id];
        return tmpObj.Reference_Lead_Account__r.Name;
    }
    
    public static string returnOppName(Reference_Lead__c refLead) {
        Reference_Lead__c tmpObj = [SELECT Reference_Lead_Opportunity__r.Name FROM Reference_Lead__c WHERE Id =:refLead.Id];
        return tmpObj.Reference_Lead_Opportunity__r.Name;
    }
    
    public static string returnOppOwnerName(Reference_Lead__c refLead) {
        Reference_Lead__c tmpObj = [SELECT Reference_Lead_Opportunity__r.Owner.Name FROM Reference_Lead__c WHERE Id =:refLead.Id];
        return tmpObj.Reference_Lead_Opportunity__r.Owner.Name;
    }
    
    public static List<Reference_Lead__c> getRefLeadRecords(String query,String refLeadId) {
        List<Reference_Lead__c> refLeads = Database.query(query);
        return refLeads;
    }
    
    
    
    //method to insert reference Request Invitations
    public static void insertRefRequestInvi(List<Reference_Requests_and_Invitations__c> listNewRRI) {
        insert listNewRRI;
    }

    public static List<Task> insertTask(List<Task> listTask) {
        insert listTask;
        return listTask;
    }
    
    public static List<Reference_Note__c> upsertNotes(List<Reference_Note__c> notes) {
        upsert notes;
        return notes;
    }
    
    /**
     * Method to delete Rewards FROM Reference Request trigger
     */
    public static void deleteRewards(List<Reward__c> rewards) {
        delete rewards;
    }
    
    /**
     * Method to insert Rewards FROM RRAccountContactTriggerHandler
     */
    public static void insertRewards(List<Reward__c> rewards) {
        insert rewards;
    }
    
    public static List<Reward__c> upsertRewards(List<Reward__c> rewards) {
        upsert rewards;
        return rewards;
    }
    
    public static void updateRewards(List<Reward__c> rewards) {
        update rewards;
    }
    
    
    public static List<Reference_Content__c> getReferenceContent(Set<Id> refContentIds) {
        List<Reference_Content__c> refCon = [SELECT Associated_Accounts__c, (SELECT Account__r.Name FROM Account_Reference_Contents__r ORDER BY Account__r.Name) FROM Reference_Content__c WHERE Id IN : refContentIds];
        return refCon;
    }
    
    //Method use in MicrositePreviewController
    public static List<Account_Reference_Content__c> getAccountReferenceContent(Set<String> refConIds) {
        String soql_arc = 'SELECT Account__r.Name, Reference_Content__c,Reference_Content__r.Substitute_Account_Name__c   FROM Account_Reference_Content__c WHERE Reference_Content__c in : refConIds';
        return Database.query(soql_arc);
    }
    
    public static List<Account_Reference_Content__c> insertAccountReferenceContent(List<Account_Reference_Content__c> accountRefContents) {
        insert accountRefContents;
        return accountRefContents;
    }
    
    public static List<Contact_Reference_Content__c> insertContactReferenceContent(List<Contact_Reference_Content__c> contactRefContents) {
        insert contactRefContents;
        return contactRefContents;
    } 
    
    public static List<Reference_Refresh_Update__c> getRefreshUpdateRecords(List<Reference_Refresh_Update__c> rrUpdatesNewRecords) {
        return [SELECT Id,Account__r.Name, Contact__r.name, Account__c,Contact__c FROM Reference_Refresh_Update__c WHERE Id In :rrUpdatesNewRecords];
    }
    
    public static List<Reference_Refresh_Update__c> upsertRefreshUpdateRecords(List<Reference_Refresh_Update__c> rrUpdatesNewRecords) {
        upsert rrUpdatesNewRecords;
        return rrUpdatesNewRecords;
    }
    
    public static List<Reference_Refresh__c> upsertReferenceRefresh(List<Reference_Refresh__c> rr) {
        upsert rr;
        return rr;
    }
    
    public static List<Reference_Refresh__c> getReferenceRefreshOnrefRefreshTrigger(Set<string> parentRefreshIds) {
        List<Reference_Refresh__c> refRefreshs = [SELECT Reference_Refresh_Status__c,Quarantined__c,Reference_Profile__c,Reference_Refresh_Owner__c,(SELECT Id FROM Reference_Refresh_Updates__r LIMIT 1) FROM Reference_Refresh__c WHERE Id In :parentRefreshIds];
        return refRefreshs;
    }
    
    public static List<Reference_Refresh__c> getReferenceRefreshOnAddRef(string refRefreshId) {
        List<Reference_Refresh__c> refRefreshs = [SELECT Id, Quarantined__c, Reference_Account__c, Reference_Refresh_Owner__c, (SELECT Id, Account__c,Contact__c,RecordsToBeInsertedId__c,RecordToBeDeletedId__c, Removed__c, Added__c FROM Reference_Refresh_Updates__r WHERE Referenceability__c = true) FROM Reference_Refresh__c WHERE Id = : refRefreshId];
        return refRefreshs;
    }
    
    public static List<Reference_Refresh__c> getReferenceRefreshOnAddAtt(string refRefreshId) {
        List<Reference_Refresh__c> refRefreshs = [SELECT Id, Quarantined__c, Reference_Refresh_Owner__c, Reference_Account__c, (SELECT Id, Account__c,Contact__c,RecordsToBeInsertedId__c,RecordToBeDeletedId__c, Changed_From__c, Changed_To__c, Removed__c, Added__c FROM Reference_Refresh_Updates__r WHERE Attribute__c = true) FROM
                Reference_Refresh__c WHERE Id = : refRefreshId
            ];
        return refRefreshs;
    }
    
    public static List<Reference_Refresh__c> getRefreshRecordsOrderByAccount(String userId) {
        return [SELECT Id,Reference_Account__c,Reference_Profile__r.Last_Refresh_Date__c,Reference_Profile__r.Last_Refresh_By__r.Name,Reference_Account__r.Id,Reference_Account__r.Name,Reference_Profile__c, Reference_Profile__r.Reference_Owner__c, Reference_Profile__r.Reference_Owner__r.Name, Reference_Account__r.OwnerId, Reference_Account__r.Owner.Name, Reference_Profile__r.Referenceability_Status__c,
                                        Reference_Refresh_Owner__c,Reference_Refresh_Owner__r.Name,Is_Active__c,Reference_Refresh_Status__c ,LastModifiedDate, Quarantined__c
                                        FROM Reference_Refresh__c WHERE Reference_Refresh_Owner__c =:userId AND Reference_Refresh_Status__c != 'No Response' AND Reference_Refresh_Status__c != 'Request Pending' AND Reference_Refresh_Status__c != 'Pending Approval' AND Reference_Refresh_Status__c != 'Profile Update Completed' AND Is_Active__c = true AND Reference_Profile__c != null ORDER BY Reference_Account__r.Name LIMIT 4];
    }
    
    public static List<Reference_Refresh__c> getAllRefreshRecords(String userId, integer size) {
        return [SELECT Id,Reference_Account__c,Reference_Profile__r.Last_Refresh_Date__c,Reference_Profile__r.Last_Refresh_By__r.Name,Reference_Account__r.Id,Reference_Account__r.Name,Reference_Profile__c, Reference_Profile__r.Reference_Owner__c, Reference_Profile__r.Reference_Owner__r.Name, Reference_Account__r.OwnerId, Reference_Account__r.Owner.Name, Reference_Profile__r.Referenceability_Status__c,
                                    Reference_Refresh_Owner__c,Reference_Refresh_Owner__r.Name,Is_Active__c,Reference_Refresh_Status__c ,LastModifiedDate, Quarantined__c
                                    FROM Reference_Refresh__c WHERE Reference_Refresh_Owner__c =:userId AND 
                                    (Reference_Refresh_Status__c != 'Pending Approval' AND Reference_Refresh_Status__c != 'Profile Update Completed' AND Reference_Refresh_Status__c != 'No Response' AND Reference_Refresh_Status__c != 'Request Pending') AND Is_Active__c = true AND 
                                    Reference_Profile__c != null ORDER BY Reference_Account__r.Name LIMIT : size + 1];
    }
    
    public static List<Reference_Refresh__c> getAllRefreshRecordsAlreadyPresent(String userId,Set<String> rrId) {
        return [SELECT Id,Reference_Account__c,Reference_Profile__r.Last_Refresh_Date__c,Reference_Profile__r.Last_Refresh_By__r.Name,Reference_Refresh_Owner__r.Name,Reference_Account__r.Id,Reference_Account__r.Name,Reference_Profile__c, Reference_Profile__r.Reference_Owner__c, Reference_Profile__r.Reference_Owner__r.Name, Reference_Account__r.OwnerId, Reference_Account__r.Owner.Name, Reference_Profile__r.Referenceability_Status__c,
                                    Reference_Refresh_Owner__c,Is_Active__c,Reference_Refresh_Status__c ,LastModifiedDate, Quarantined__c
                                    FROM Reference_Refresh__c WHERE Reference_Refresh_Owner__c =:userId AND 
                                    (Reference_Refresh_Status__c != 'Pending Approval' AND Reference_Refresh_Status__c != 'Profile Update Completed' AND Reference_Refresh_Status__c != 'No Response' AND Reference_Refresh_Status__c != 'Request Pending') AND Is_Active__c = true AND Reference_Profile__c != null AND Id  In :rrId
                                    ORDER BY Reference_Account__r.Name ];
    }
    
    public static List<Reference_Refresh__c> getAllRefreshRecordsAlreadyNotPresent(String userId,Set<String> refRefreshAlreadyPresent) {
        return [SELECT Id,Reference_Account__c,Reference_Refresh_Owner__r.Name,Reference_Profile__r.Last_Refresh_By__r.Name,Reference_Profile__r.Last_Refresh_Date__c,Reference_Account__r.Id,Reference_Account__r.Name,Reference_Profile__c, Reference_Profile__r.Reference_Owner__c, Reference_Profile__r.Reference_Owner__r.Name, Reference_Account__r.OwnerId, Reference_Account__r.Owner.Name, Reference_Profile__r.Referenceability_Status__c,
                                    Reference_Refresh_Owner__c,Is_Active__c,Reference_Refresh_Status__c ,LastModifiedDate, Quarantined__c
                                    FROM Reference_Refresh__c WHERE Reference_Refresh_Owner__c =:userId AND 
                                    (Reference_Refresh_Status__c != 'Pending Approval' AND Reference_Refresh_Status__c != 'Profile Update Completed' AND Reference_Refresh_Status__c != 'No Response' AND Reference_Refresh_Status__c != 'Request Pending') AND Is_Active__c = true AND Id NOT IN :refRefreshAlreadyPresent 
                                    ORDER BY Reference_Account__r.Name LIMIT 11];
    }
    
     public static List<Reference_Refresh__c> getRefreshRecord(String selectedReferenceRefreshRecordId) {
        return [SELECT Id,(SELECT Added__c, Removed__c, Attribute__c, Referenceability__c, 
                                        Accept_Reject__c,Changed_From__c,Changed_To__c, RecordToBeDeletedId__c, RecordsToBeInsertedId__c, 
                                        Account__c, Contact__c FROM Reference_Refresh_Updates__r WHERE (Added__c = true OR Removed__c = true)) FROM Reference_Refresh__c WHERE Id =:selectedReferenceRefreshRecordId];
    }
    
    public static void deleteAccountRequest(List<Reference_Request_Account__c> accRequestList) {
        delete accRequestList;
    }
    
    //Method use in ReferenceRequestController & ReferenceUseRequest Controller
    public static List<Reference_Request_Account__c> insertRRA(List<Reference_Request_Account__c> listOfRRA) {
        insert listOfRRA;
        return listOfRRA;
    }
    
    // Method used in ReferenceRequestController & ReferenceUseRequest Controller
    public static List<Reference_Request_Account__c> getRRARecords(List<Reference_Request_Account__c> listOfRRA) {
        List<Reference_Request_Account__c> tempRecords = [SELECT Adv_Routing_Criteria__c, Task_ID__c, Requester__c, Request_Notes__c, Reference_Use__c,
                                                            Reference_Type_Needed_f__c, Reference_Type_Needed__c, Reference_Request__c,
                                                            Reference_Request_Additional_Info__c, Reference_Owner__c,Project_Owner_f__c,
                                                            Project_Owner__c,Process__c, Name, Managed_Request__c, Requester__r.Name,
                                                            LastModifiedDate, LastModifiedById, LastActivityDate, Is_Reminder_to_Owner__c,
                                                            Is_No_Response__c,Is_Escalation_to_Owner_Manager__c,Id,Deadline__c,
                                                            Approve_Deny_Notes__c, Approval_Status__c, Activity_Date__c, Account_f__c,
                                                            Account__c, Account_Request__c, Account_Request_Status__c, Related_Feed_Item_Ids__c,
                                                            (SELECT Task_ID__c, Request_notes__c, Referenceability_Type__c,
                                                                Reference_Use__c, Reference_Request_Account__c, Project_Owner__c, OwnerId, Name,
                                                                LastModifiedDate, LastModifiedById, Contact__r.Name,Contact__r.Phone,Contact__r.Email,
                                                                Is_Reminder_to_Owner__c, Is_No_Response__c, Is_Feedback_Received__c,
                                                                Is_Feedback_Notification_Send__c, Is_Escalation_to_Owner_Manager__c, Id,
                                                                Feedback_Status__c, Feedback_Response__c, Deadline__c, CreatedDate, Contact__c,
                                                                Contact_Title__c, Contact_Request__c, Contact_Request_Status__c, Contact_Phone__c,
                                                                Contact_Name__c, Contact_Email__c, Approve_Deny_Notes__c, Approval_Status__c,
                                                                Activity_Date__c FROM Reference_Request_Account_Contacts__r)
                                                            FROM Reference_Request_Account__c
                                                            WHERE Id IN :listOfRRA];
        return tempRecords;
    }
    
    
    //Method use in ReferenceRequestController & ReferenceUseRequest Controller
    public static List<Reference_Request_Account__c> updateRRA(List<Reference_Request_Account__c> listOfRRA) {
        update listOfRRA;
        return listOfRRA;
    }
    
    public static List<Unspecified_Request__c> updateUnspecified(List<Unspecified_Request__c> listOfRRA) {
        update listOfRRA;
        return listOfRRA;
    }
    
    //Method use in ReferenceRequestController & ReferenceUseRequest Controller
    public static Reference_Request_Account__c upsertRRA(Reference_Request_Account__c rra) {
        upsert rra;
        return rra;
    }
    
    public static List<Reference_Request_Account__c> upsertRRAList(List<Reference_Request_Account__c> rra) {
        upsert rra;
        return rra;
    }
    
    public static List<Reference_Request__c> getRefRequestRecords(Set<String> RRIds) {
        List<Reference_Request__c> rrList = [SELECT Name, Id, Reference_Request_Status__c,Project_Type__c, (SELECT Id FROM Unspecified_Requests__r WHERE Unspecified_Request_Status__c = :ConstantsController.NOT_STARTED
                OR Unspecified_Request_Status__c = :ConstantsController.IN_PROGRESS
                OR Unspecified_Request_Status__c = :ConstantsController.ONHOLD), (SELECT Id, Account_Request_Status__c FROM Reference_Request_Accounts__r WHERE Account_Request_Status__c = :ConstantsController.NOT_STARTED
                OR Account_Request_Status__c = :ConstantsController.IN_PROGRESS
                OR Account_Request_Status__c = :ConstantsController.ONHOLD) FROM Reference_Request__c WHERE Id IN: RRIds];
        return rrList;
    }
    
    public static List<Reference_Request_Account_Contact__c> getAccountContactRequests(Set<String> rraIds) {
        List<Reference_Request_Account_Contact__c> listRefReqAccountContact
            = new List<Reference_Request_Account_Contact__c>([
                SELECT Contact__c, Contact__r.Name, Contact__r.Phone, Contact__r.Email, Contact__r.Title, Id,
                Reference_Request_Account__c, Contact_Title__c, Contact_Phone__c, Contact_Email__c
                FROM Reference_Request_Account_Contact__c
                WHERE Reference_Request_Account__c IN :rraIds]);
        return listRefReqAccountContact;
    }
    
    public static List<Reference_Request_Account__History> getRRAHistory(String refReqAccId) {
        String fieldName = UtilityController.appNamespace().tolowerCase() +'Managed_Request__c';
        List<Reference_Request_Account__History> rraHistory = [SELECT ParentId, OldValue, NewValue FROM Reference_Request_Account__History WHERE ParentId = : refReqAccId AND Field = :fieldName
            ORDER BY CreatedDate
        ];
        return rraHistory;
    }
    
    public static List<Reference_Request_Account_Contact__c> getContactRequests(String conReqId){
        List<Reference_Request_Account_Contact__c> listRefReqAccountContact = new List<Reference_Request_Account_Contact__c> ([SELECT Id, Name,Referenceability_Type__c,
                Reference_Request_Account__r.Account__r.Name,Reference_Request_Account__r.Account_f__c, Contact__r.Name, Is_Feedback_Received__c, Feedback_Status__c,
                Reference_Request_Account__r.Reference_Type_Needed__r.Name, Reference_Request_Account__r.Reference_Type_Needed_f__c, Reference_Request_Account__r.Reference_Request__c,
                Reference_Request_Account__r.CreatedDate, Reference_Request_Account__r.Deadline__c, Feedback_Response__c,
                Reference_Request_Account__r.Account__c, Reference_Request_Account__r.Task_ID__c, Task_ID__c, Is_Feedback_Notification_Send__c
                FROM Reference_Request_Account_Contact__c
                WHERE id = : conReqId AND Reference_Use__c = false
            ]);
        return listRefReqAccountContact;
    }
    
    public static Reference_Request_Account_Contact__c upsertRRAC(Reference_Request_Account_Contact__c rrac) {
        upsert rrac;
        return rrac;
    }
    
    public static List<Reference_Request_Account_Contact__c> upsertRRACList(List<Reference_Request_Account_Contact__c> rrac) {
        upsert rrac;
        return rrac;
    }
    
    public static Reference_Request_Account__c getAccountRequest(String reqId) {
        List<Reference_Request_Account__c> accRequests = [SELECT r.Task_ID__c,
                                                    CreatedById, r.Requester__c,Reference_Request__r.Opportunity__c, r.Request_Notes__c, 
                                                    r.Reference_Use__c,Reference_Type_Needed__r.Name, r.Reference_Type_Needed_f__c, 
                                                    r.Reference_Type_Needed__c, 
                                                    r.Reference_Request__c, r.Reference_Request_Additional_Info__c, r.Project_Owner_f__c, 
                                                    r.Project_Owner__c, r.Managed_Request__c, r.Is_Reminder_to_Owner__c, r.Is_No_Response__c, 
                                                    r.Is_Escalation_to_Owner_Manager__c, r.Deadline__c, r.Approve_Deny_Notes__c, 
                                                    r.Approval_Status__c, r.Activity_Date__c, r.Account_Request__c, r.Account_Request_Status__c,
                                                     r.Account__c FROM Reference_Request_Account__c r WHERE Id = : reqId LIMIT 1];
        return (accRequests.size() > 0 ? accRequests[0] : new Reference_Request_Account__c());
    }
    
    public static List<Reference_Request_Account__c> getAccountRequests(Set<Id> reqIds) {
        // changes for #440 - new field "Criteria" added to query
        List<Reference_Request_Account__c> accRequests = [SELECT Task_ID__c, Id, CreatedDate, Requester__c, Request_Notes__c, Requester__r.Name, Requester__r.Email,
                                                                Reference_Type_Needed__r.Name, Reference_Type_Needed_f__c, Reference_Request__c, Name, Managed_Request__c, 
                                                                Deadline__c, Account__c, Account__r.Name, Account_f__c, Reference_Type_Needed__c,
                                                                Approval_Status__c, Approve_Deny_Notes__c, Is_Reminder_to_Owner__c, 
                                                                Is_Escalation_to_Owner_Manager__c, Reference_Request__r.Project_Type__c,
                                                                Is_No_Response__c, Account_Request_Status__c, Adv_Routing_Criteria__c, Reference_Owner__r.Email,
                                                                Reference_Owner__c, Related_Feed_Item_Ids__c, Reference_Request__r.Opportunity__r.Account.Name,
                                                                Reference_Request__r.Opportunity__c FROM Reference_Request_Account__c 
                                                                WHERE Id IN :reqIds];
        return accRequests;
    }
    
    public static List<Reference_Request_Account__c> getRRAccountRequests(Id reqId) {
        List<Reference_Request_Account__c> accRequests = [SELECT Name, Account__c, Deadline__c, Requester__c, Managed_Request__c, Requester__r.Name,
                                        Reference_Type_Needed__c, Approval_Status__c, Account__r.Name, Account_f__c,Reference_Type_Needed__r.Name, Reference_Type_Needed_f__c,
                                        Account_Request_Status__c FROM Reference_Request_Account__c WHERE Reference_Request__c = : reqId];
        return accRequests;
    }
    public static List<Reference_Request_Account__c> getRRAccountRequestsOfAccount(Set<String> accIds) {
        List<Reference_Request_Account__c> accRequests = [SELECT Name, Account__c, Account_f__c, Reference_Request__c, Deadline__c,Requester__c,Activity_Date__c ,Managed_Request__c, Reference_Type_Needed__c,Approval_Status__c, 
                                        Account_Request_Status__c, Reference_Request__r.Project_Type__c, (SELECT Id FROM Reference_Notes__r),(SELECT Id FROM Unspecified_Requests__r)
                                         FROM Reference_Request_Account__c WHERE Account__c In : accIds];
        return accRequests;
    }
    
    
    public static List<Reference_Request_Account_Contact__c> getRRACRecords(Set<Id> contactIds) {
        List<Reference_Request_Account_Contact__c> rracs = [SELECT Contact__c,Activity_Date__c, Id FROM Reference_Request_Account_Contact__c WHERE Contact__c In: contactIds];
        return rracs;
    }
    
    
    public static List<Reference_Request__c> getReferenceRequests(string oppId) {
        List<Reference_Request__c> referenceRequests = [SELECT Id, Name, Opportunity__r.Name, 
                                                (SELECT Name, Deadline__c, Reference_Type_Needed__c,Reference_Type_Needed__r.Name, Reference_Type_Needed_f__c, Requester__c,Requester__r.Name, Reference_Request_Additional_Info__c, Request_Notes__c, Specified_Account__c,Specified_Account__r.Name, Unspecified_Request_Status__c,Project_Owner__c,Project_Owner__r.Name FROM Unspecified_Requests__r ORDER BY CreatedDate DESC), 
                                                (SELECT Name, Account__c,Account__r.Name, Account_f__c, Deadline__c, Requester__c,Requester__r.Name,Process__c, Managed_Request__c, Reference_Type_Needed__c,Reference_Type_Needed__r.Name, Reference_Type_Needed_f__c, Approval_Status__c, Account_Request_Status__c, Reference_Owner__c, Reference_Owner__r.Name, Project_Owner__c,Project_Owner__r.Name FROM Reference_Request_Accounts__r ORDER BY CreatedDate DESC)
                                                FROM Reference_Request__c r WHERE Opportunity__c = : oppId ORDER BY CreatedDate DESC
                                                ];
        return referenceRequests;
    }
    //Shared Contact code start
    public static Map<string, Set<string>> getRelatedAccounts(Set<String> contactIds,Custom_Settings__c cs) {
        map <string, Set<string>> contactAccountMap = new Map<string, Set<string>> ();
        if (cs == null)
            cs = UtilityController.getCustomSettings();
            
        if (cs.Shared_Contacts__c && cs.Shared_Contact_Field__c != null && cs.Shared_Contact_Field__c != '' && cs.Shared_Account_Field__c != null && cs.Shared_Account_Field__c != '') {
            String objectName = cs.Shared_Contact_Object__c;
            String accountField = cs.Shared_Account_Field__c;
            String contactField = cs.Shared_Contact_Field__c;
            String query = 'SELECT ' + accountField + ', ' + contactField + ' FROM ' + objectName
                                     + ' WHERE ' + contactField + ' IN :contactIds AND '+accountField+' != null';
            List<sObject> objectList = Database.query(query);
            if (objectList != null && objectList.size() > 0) {
                
                for (sObject obj : objectList) {
                    if (!contactAccountMap.containsKey((String)obj.get(contactField))) {
                        contactAccountMap.put((String)obj.get(contactField),new Set<string>());
                    }
                    contactAccountMap.get((String)obj.get(contactField)).add((String)obj.get(accountField));
                }
            }
        }
        return contactAccountMap;
    }
    //end
    
    /**
     * Method to update Sales User Profile 
     */
    public static List<User_Profile__c> updateSalesUserProfiles(List<User_Profile__c> profiles) {
        update profiles;
        return profiles;
    }
    /**
     * Ticket : #707
     * Description : Method used to get reference profile in reward trigger 
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getRefProfilesInRewardTrigger(Set<Id> accountIssuedIds, Set<Id> contactIssuedIds, Set<Id> ChangedContactIds) {
        List<Reference_Basic_Information__c> profiles = [SELECT Id, Account__c, Contact__c, Contact__r.Name, Name, Reference_Program_Candidate__c, 
                                                Is_Referenceable__c, Referenceability_Status__c, Lifetime_Points__c, Current_Available_Balance_Points__c 
                                                FROM Reference_Basic_Information__c WHERE Account__c != null AND (Contact__c IN: ChangedContactIds 
                                                OR Contact__c IN: contactIssuedIds OR Account__c IN: accountIssuedIds) 
                                                ORDER BY Contact__r.Name LIMIT: limits.getLimitQueryRows()];
        return profiles;
    }
    /**
     * Ticket : #707
     * Description : Method used to get reference profile in utility 
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getRefProfiles(String accId, String conId) {
        List<Reference_Basic_Information__c> profiles = [SELECT Contact__c, Account__c, Is_Referenceable__c, Account__r.Name, Contact__r.Name
                                                            FROM Reference_Basic_Information__c
                                                            WHERE ((Account__c = :accId AND Contact__c = null)
                                                            OR (Contact__c = :conId AND Contact__c != null))
                                                            AND Account__c != null];
        return profiles;
    }
    /**
     * Ticket : #707
     * Description : Method used to get reference profile in utility 
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getRefProfiles(Set<String> accIdList, String conId) {
        List<Reference_Basic_Information__c> profiles = [SELECT Contact__c, Account__c, Is_Referenceable__c FROM Reference_Basic_Information__c 
                                WHERE ((Account__c IN :accIdList AND Contact__c = null) OR (Contact__c = :conId AND Contact__c != null))];
        return profiles;
    }
    /**
     * Ticket : #707
     * Description : Method used to get rewards with account in redeem reward
     * Created By : Rekha 
     */
    public static List<Reward__c> getRewardOfAccount(String accountId) {
        List<Reward__c> rewardLst = [SELECT Id, Transaction__c, Expired__c, Available_Points__c, Contact__c, Account__c, Comments__c 
                                        FROM Reward__c WHERE Account__c =: accountId AND Expired__c = false AND Available_Points__c != 0 
                                        AND Transaction__c = : ConstantsController.ISSUE ORDER BY CreatedDate];
        return rewardLst;                                       
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get rewards with contact in redeem reward
     * Created By : Rekha 
     */
    public static List<Reward__c> getRewardOfContact(String contactId) {
        List<Reward__c> rewardLst = [SELECT Id, Transaction__c, Expired__c, Available_Points__c, Contact__c, Account__c, Comments__c 
                                        FROM Reward__c WHERE Contact__c =: contactId AND Expired__c = false AND Available_Points__c != 0 
                                        AND Transaction__c = : ConstantsController.ISSUE ORDER BY CreatedDate];
        return rewardLst;                                       
    }
    /**
     * Ticket : #707
     * Description : Method used to get contact reference profiles
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getContactProfilesinContactSearch(Set<Id> idSet) {
        List<Reference_Basic_Information__c> rbiList = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, contact__r.Name, contact__r.AccountId, 
                                                        contact__r.OwnerId, Referenceability__c, Attributes__c, RUL_Activities_used__c, 
                                                        RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Account_Level_RUL__c, Default_Period_Completed_Uses__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c,
                                                         Ref_Profile_Summary__c, Account__r.Name FROM Reference_Basic_Information__c WHERE Contact__c IN: idSet AND 
                                                        Is_Referenceable__c = true AND (Referenceability_Status__c != : ConstantsController.INACTIVE 
                                                        AND Referenceability_Status__c != '') 
                                                        AND Contact__c != null ORDER BY contact__r.Name LIMIT 2001 ];
        return rbiList;                                     
    }
    /**
     * Ticket : #707
     * Description : Method used to get contacts
     * Created By : Rekha 
     */
    public static Map<Id, Contact> getContactsinContactSearch(Set<Id> idSet) {
        Map<Id, Contact> contacts = new Map<Id, Contact> ([SELECT Id, Name, AccountId, OwnerId, (SELECT Reference_Request_Account__c, Contact__c, 
                                                            Approval_Status__c, Deadline__c, Referenceability_Type__c, Contact_Request_Status__c 
                                                            FROM Reference_Request_Account_Contacts__r 
                                                            WHERE Contact_Request_Status__c = : ConstantsController.IN_PROGRESS OR 
                                                            Contact_Request_Status__c = : ConstantsController.ONHOLD 
                                                            OR Contact_Request_Status__c = : ConstantsController.NOT_STARTED ORDER BY Deadline__c DESC), 
                                                            (SELECT Id,Reference_Request__c,Released__c FROM Hit_Lists__r),
                                                            (SELECT RUL_Last_Activity_Date__c, Default_Period_Completed_Uses__c
                                                            FROM Reference_Basic_Informations__r WHERE Account__c != null AND Contact__c != null)
                                                            FROM Contact WHERE Id In: idSet]);
        return contacts;                                        
    }
    /**
     * Ticket : #707
     * Description : Method used to get contacts
     * Created By : Rekha 
     */
    public static List<sObject> getSobjectinContactSearch(String query) {
        List<sObject> objectList = Database.query(query);
        return objectList;                                      
    }
    /**
     * Ticket : #707
     * Description : Method used to get contacts
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getContactProfileSobjectinContactSearch(String dynamicSOQL, Set<String> contactIds,
                                                                                                            Set<String> commonFilterIds) {
        List<Reference_Basic_Information__c> objectList = Database.query(dynamicSOQL);
        return objectList;                                      
    }
    /**
     * Ticket : #707
     * Description : Method used to get contacts
     * Created By : Rekha 
     */
    public static List<List<SObject>> getSobjectSOSLinContactSearch(String SOSLQuery, Set<String> referenceableContactIds, Set<String> contactIds) {
        List<List<SObject>> searchList = search.query(SOSLQuery);
        return searchList;                                      
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get contact reference profiles
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getContactProfilesinContactSearch(Set<String> contactIds, String selectedType, 
                                                                            Set<String> accountContactIds, Id accountId) { 
        List<Reference_Basic_Information__c> listContact = new List<Reference_Basic_Information__c>();
        
        if (selectedType == 'Active') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                            Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                            Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                            FROM Reference_Basic_Information__c
                            WHERE Contact__c NOT IN: accountContactIds AND (contact__r.AccountId = : accountId OR Contact__c IN :contactIds) 
                            AND Is_Referenceable__c = true AND (Referenceability_Status__c != : ConstantsController.INACTIVE 
                            AND Referenceability_Status__c != '') AND Contact__c != null ORDER BY Contact__r.Name];
        } else if (selectedType == 'Inactive') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                            Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                            Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                            FROM Reference_Basic_Information__c
                            WHERE Contact__c NOT IN: accountContactIds AND (contact__r.AccountId = : accountId OR Contact__c IN :contactIds) 
                            AND Is_Referenceable__c = true AND Referenceability_Status__c = : ConstantsController.INACTIVE AND Contact__c != null
                            ORDER BY Contact__r.Name];
        } else if (selectedType == 'Candidate') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                            Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                            Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                            FROM Reference_Basic_Information__c
                            WHERE Contact__c NOT IN: accountContactIds AND (contact__r.AccountId = : accountId OR Contact__c IN :contactIds) 
                            AND Reference_Program_Candidate__c = true AND Contact__c != null ORDER BY Contact__r.Name];
        }
        return listContact;                                     
    }
    /**
     * Ticket : #707
     * Description : Method used to get account reference profiles
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getAccountProfilesinContactSearch(Set<Id> accIdSet) {
        List<Reference_Basic_Information__c> rbiList = [SELECT Account__c, Referenceability__c, Attributes__c, RUL_Activities_used__c, 
                                                    RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Account_Level_RUL__c, Default_Period_Completed_Uses__c 
                                                    FROM Reference_Basic_Information__c WHERE Contact__c = null AND Account__c != null 
                                                    AND Account__c IN: accIdSet];
        return rbiList;                                     
    }
    
    /**
     * method to get contact RBIs for export from ref search page
     * author: Gaurav Saini (5 Dec, 2017) for #1135
     */
    public static List<Reference_Basic_Information__c> getContactProfilesinContactSearchForExport(Set<String> contactIds) {
        return [SELECT Account__c, Contact__c, Contact__r.Id, Contact__r.Name, Contact__r.AccountId,
                Contact__r.OwnerId, Referenceability__c, Attributes__c, RUL_Activities_used__c,
                RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                Account_Level_RUL__c, Is_Contact_Limit_Reached__c, Referenceability_Status__c, Ref_Profile_Summary__c
                FROM Reference_Basic_Information__c
                WHERE Contact__c NOT IN :contactIds
                AND Is_Referenceable__c = true
                AND (Referenceability_Status__c != :ConstantsController.INACTIVE AND Referenceability_Status__c != '')
                AND Contact__c != null ORDER BY Contact__r.Name LIMIT :Limits.getLimitQueryRows()];
    }
    /**
     * Ticket : #707
     * Description : Method used to get contact reference profiles
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getContactProfilesinContactSearch(Set<String> contactIds, String selectedType) {
        List<Reference_Basic_Information__c> listContact = new List<Reference_Basic_Information__c>();
           
        if (selectedType == 'Active') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                            Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                            Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                            FROM Reference_Basic_Information__c
                            WHERE Contact__c NOT IN: contactIds AND Is_Referenceable__c = true AND 
                            (Referenceability_Status__c != : ConstantsController.INACTIVE AND Referenceability_Status__c != '') 
                            AND Contact__c != null ORDER BY Contact__r.Name LIMIT: 2001];
        } else if (selectedType == 'Inactive') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                            Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                            Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                            FROM Reference_Basic_Information__c
                            WHERE Contact__c NOT IN: contactIds AND Is_Referenceable__c = true AND 
                            Referenceability_Status__c = : ConstantsController.INACTIVE
                            AND Contact__c != null ORDER BY Contact__r.Name LIMIT: 2001];
        } else if (selectedType == 'Candidate') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                            Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                            Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                            FROM Reference_Basic_Information__c
                            WHERE Contact__c NOT IN: contactIds AND Reference_Program_Candidate__c = true AND Contact__c != null
                            ORDER BY Contact__r.Name LIMIT: 2001];
        }
        return listContact;                                     
    }
    
    /**
     * method to get contact RBIs for export from ref search page
     * author: Gaurav Saini (5 Dec, 2017) for #1135
     */
    public static List<Reference_Basic_Information__c> getContactProfilesinContactSearchForExport(Set<String> contactIds, Set<String> commonFilterIds) {
        return [SELECT Account__c, Contact__c, Contact__r.Id, Contact__r.Name, Contact__r.AccountId,
                Contact__r.OwnerId, Referenceability__c, Attributes__c, RUL_Activities_used__c,
                RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, Default_Period_Completed_Uses__c,
                Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                FROM Reference_Basic_Information__c
                WHERE Contact__c IN :commonFilterIds
                AND Contact__c NOT IN :contactIds
                AND Is_Referenceable__c = true
                AND (Referenceability_Status__c != :ConstantsController.INACTIVE AND Referenceability_Status__c != '') 
                AND Contact__c != null ORDER BY Contact__r.Name LIMIT :Limits.getLimitQueryRows()];
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get contact reference profiles
     * Created By : Rekha 
     */
    public static List<Reference_Basic_Information__c> getContactProfilesinContactSearch(Set<String> contactIds, String selectedType, 
                                                                                                Set<String> commonFilterIds) {
        List<Reference_Basic_Information__c> listContact = new List<Reference_Basic_Information__c>();
            
        if (selectedType == 'Active') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                    Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Contact__c IN: commonFilterIds AND contact__c NOT IN: contactIds AND Is_Referenceable__c = true 
                    AND (Referenceability_Status__c != : ConstantsController.INACTIVE AND Referenceability_Status__c != '') 
                    AND Contact__c != null ORDER BY contact__r.Name LIMIT 2001];
        } else if (selectedType == 'Inactive') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                    Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Contact__c IN: commonFilterIds AND contact__c NOT IN: contactIds AND Is_Referenceable__c = true 
                    AND Referenceability_Status__c = : ConstantsController.INACTIVE
                    AND Contact__c != null ORDER BY contact__r.Name LIMIT 2001];
        } else if (selectedType == 'Candidate') {
            listContact = [SELECT Account__c, Contact__c, Contact__r.Email, Contact__r.Id, Contact__r.Name, contact__r.AccountId, Contact__r.OwnerId, 
                    Referenceability__c, Attributes__c, RUL_Activities_used__c, RUL_Last_Activity_Date__c, RUL_Limit_Reached__c, 
                    Default_Period_Completed_Uses__c, Account_Level_RUL__c, Is_Contact_Limit_Reached__c,Referenceability_Status__c, Ref_Profile_Summary__c
                    FROM Reference_Basic_Information__c
                    WHERE Contact__c IN: commonFilterIds AND contact__c NOT IN: contactIds AND Reference_Program_Candidate__c = true 
                    AND Contact__c != null ORDER BY contact__r.Name LIMIT 2001];
        }
        return listContact;                                     
    }
    /**
     * Ticket : #707
     * Description : Method used to get contact reference profiles
     * Created By : Rekha 
     */
    public static Set<String> getContactProfileIdsinContactSearch(String selectedType) {
        Set<String> referenceableContactIds = new Set<String>();
            
        if (selectedType == 'Active') {
            
            for (Reference_Basic_Information__c rbi : [SELECT Contact__c, Id FROM Reference_Basic_Information__c 
                                                    WHERE Contact__c != null AND Is_Referenceable__c = true AND Referenceability_Status__c != 
                                                    :ConstantsController.INACTIVE AND Referenceability_Status__c != null LIMIT: limits.getLimitQueryRows()]) {
                referenceableContactIds.add(rbi.Contact__c);
            }
        } else if (selectedType == 'Inactive') {
            
            for (Reference_Basic_Information__c rbi : [SELECT Contact__c, Id FROM Reference_Basic_Information__c WHERE Contact__c != null 
                                                        AND Is_Referenceable__c = true AND Referenceability_Status__c = : ConstantsController.INACTIVE 
                                                        LIMIT: limits.getLimitQueryRows()]) {
                referenceableContactIds.add(rbi.Contact__c);
            }
        } else if (selectedType == 'Candidate') {
            
            for (Reference_Basic_Information__c rbi : [SELECT Contact__c, Id FROM Reference_Basic_Information__c WHERE Contact__c != null 
                                                        AND Reference_Program_Candidate__c = true LIMIT: limits.getLimitQueryRows()]) {
                referenceableContactIds.add(rbi.Contact__c);
            }
        }
        return referenceableContactIds;                                     
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get account reference profiles
     * Created By : Rekha 
     */
    public static List<Contact> getAccountContactsinContactSearch(Set<String> referenceableContactIds, Set<String> contactIds,
                                                                    Set<String> searchedcontactIds, Set<Id> accountIdSet) {
        List<Contact> conList = [SELECT Id FROM Contact WHERE Id In :referenceableContactIds 
                                                        AND Id NOT IN :contactIds AND Id NOT IN :searchedcontactIds 
                                                        AND AccountId IN :accountIdSet ORDER BY Name];
        return conList;                                     
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get account hit list
     * Created By : Rekha
     */
    public static List<Hit_List__c> getAccountHitListInRefSearch(String hitAccount, String requestId) {
        List<Hit_List__c> hitList = [SELECT Id, Released__c FROM Hit_List__c WHERE Account__c =: hitAccount AND Reference_Request__c =: requestId limit 1];
        return hitList;
    }
    /**
     * Ticket : #707
     * Description : Method used to get contact hit list
     * Created By : Rekha
     */
    public static List<Hit_List__c> getContactHitListInRefSearch(String hitContact, String accountId, String requestId) {
        List<Hit_List__c> hitList = [SELECT Id,Released__c FROM Hit_List__c WHERE Contact__c =: hitContact AND Account__c =: accountId
                                        AND Reference_Request__c =: requestId limit 1];
        return hitList;
    }
    /**
     * Ticket : #707
     * Description : Method used to get Ref Types for getting the sales points
     * Created By : Rekha
     */
    public static Map<Id, Referenceability_Type__c> getSalesPointRefTypesInRefSearch(Set<Id> kSetIds) {
        Map<Id, Referenceability_Type__c> mapRefType = new Map<Id, Referenceability_Type__c>([SELECT Id, Name, Sales_Point__c
                                                        FROM Referenceability_Type__c WHERE Id IN: kSetIds AND Sales_Reward__c = false 
                                                        AND Visible__c = true AND Sales_Point__c != null order by Name LIMIT: limits.getLimitQueryRows()]);
        return mapRefType;
    }
    /**
     * Ticket : #707
     * Description : Method used to upsert Data Mappings
     * Created By : Rekha
     */
    public static List<Data_Mapping__c> upsertDataMappingsInRefSearch(List<Data_Mapping__c> filterList) {
        upsert filterList;
        return filterList;
    }
    /**
     * Description : Method used to delete Data Mappings
     */
    public static void deleteDataMappingsInRefSearch(List<Data_Mapping__c> dmList) {
        delete dmList;
    }
    /**
     * Ticket : #866
     * Description : Method used to get tasks
     * Created By : Rekha
     */
    public static List<Task> fetchTask(Set<Id> TaskIds) {
        return [SELECT Status, Id, OwnerId, Description FROM Task WHERE Id IN :TaskIds];
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get task
     * Created By : Rekha
     */
    public static List<Task> fetchTask(Id TaskId) {
        return [SELECT Status, Id, OwnerId, Description FROM Task WHERE id = :TaskId];
    }
    
    /**
     * Ticket : #707
     * Description : Method used to update task
     * Created By : Rekha
     */
    public static List<Task> updateTask(List<Task> listTask) {
        update listTask;
        return listTask;
    }
    /**
     * Ticket : #707
     * Description : Method used to insert community invite
     * Created By : Rekha
     */
    public static Community_Invite__c insertCommunityInvite(Community_Invite__c comInvite) {
        insert comInvite;
        return comInvite;
    }
    /**
     * Ticket : #707
     * Description : Method used to get request hit list
     * Created By : Rekha
     */
    public static List<Hit_List__c> getRequestHitListInRefProject(String requestId) {
        List<Hit_List__c> hitList = [SELECT Referenceability_Type__c, Community_Invite__c, Reference_Request__c, Opportunity__c,
                                        Note__c, LastActivityDate, LastModifiedDate, Field1__c, Email__c, Disposition__c,
                                        Deadline__c, Contact__c, Account__c, Phone__c, Released__c, Account__r.Name, Contact__r.Name,
                                        Unspecified_Request__c, Account_Request__c
                                        FROM Hit_List__c WHERE Reference_Request__c = :requestId];
        return hitList;
    }
    
    /**
     * Ticket : #707
     * Description: Method used to get request hit list
     * Created By: Rekha
     */
    public static List<Contact> getContactsInProfileUpdateTrigger(Set<String> contactIds) {
        // changes for #769 - extra fields added to query
        List<Contact> contacts = [SELECT Id, Name, Account.Name, AccountId,
                                    (SELECT Id, Name, Contact__c, Account__c, Reference_Program_Candidate__c,
                                        Is_Referenceable__c, Roll_up_Referenceability_to_Primary_Acc__c,
                                        Roll_up_Referenceability_to_All_Accounts__c, Referenceability_Status__c 
                                        FROM Reference_Basic_Informations__r)
                                    FROM Contact WHERE Id IN :contactIds];
        return contacts;
    }
    /**
     * Ticket : #707
     * Description : Method used to get request hit list
     * Created By : Rekha
     */
    public static void updateReferenceRefresh(List<Reference_Refresh__c> rr) {
        update rr;
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get request hit list
     * Created By : Rekha
     */
    public static List<Reference_Refresh__c> getProfileUpdatesinProfileUpdateTrigger(Set<Id> profileUpdateIds) {
        List<Reference_Refresh__c> profileUpdates = [SELECT Id, Is_Active__c, Quarantined__c, Reference_Refresh_Status__c, 
                                    (SELECT Accept_Reject__c, No_Change__c FROM Reference_Refresh_Updates__r) 
                                    FROM Reference_Refresh__c WHERE Id IN :profileUpdateIds];
        return profileUpdates;
    }
    /**
     * Ticket : #707
     * Description : Method used to get request hit list
     * Created By : Rekha
     */
    public static List<Reference_Basic_Information__c> getContactReferenceProfileInProfileUpdateTrigger(String contactId) {
        List<Reference_Basic_Information__c> profiles = [SELECT Referenceability_Status__c, Is_Referenceable__c 
                                                FROM Reference_Basic_Information__c WHERE contact__c = : contactId];
        return profiles;
    }
    /**
     * Ticket : #707
     * Description : Method used to get request hit list
     * Created By : Rekha
     */
    public static List<Reference_Basic_Information__c> getAccountReferenceProfileInProfileUpdateTrigger(String accountId) {
        List<Reference_Basic_Information__c> profiles = [SELECT Referenceability_Status__c, Is_Referenceable__c 
                                        FROM Reference_Basic_Information__c WHERE Account__c = : accountId AND contact__c = null];
        return profiles;
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get request hit list
     * Created By : Rekha
     */
    public static void insertReferenceabilityInProfileUpdateTrigger(List<Referenceability__c> referenceabilityInserted) {
        insert referenceabilityInserted;
    }
    
    /**
     * Ticket : #707
     * Description : Method used to get request hit list
     * Created By : Rekha
     */
    public static void deleteReferenceabilityInProfileUpdateTrigger(Set<String> referenceabilityDeleted) {
        delete [SELECT Id FROM Referenceability__c WHERE Id In: referenceabilityDeleted];
    }
    
    /**
     * Ticket : #606
     * Description : Method used to get reference request details on the basis of reference request Id.
     * Created By : Rajesh 
     */
    public static list <Reference_Request__c> getReferenceReqDetails(Id refReqId) {
        List<Reference_Request__c> lstRefReq = [SELECT Opportunity__c, Opportunity__r.Name, Case__c, Case__r.Account.Name, 
                                                Lead__c, Lead__r.Name, Lead__r.Company,
                                                Case__r.CaseNumber, Name, Id, Opportunity__r.AccountId, Opportunity__r.Account.Name 
                                                FROM Reference_Request__c WHERE Id = :refReqId LIMIT 1];
        return lstRefReq;                                       
    }
    
    public static List<Attributes_Labels__c> fetchAttributeLabels(Set<String> attIds){
        return [SELECT Attribute__c, Attribute__r.Root_Parent__c, Attribute__r.Parent__c, Label__c,Label__r.Filter_no__c, Label__r.Name 
                FROM Attributes_Labels__c WHERE Attribute__c IN: attIds];
    }
    
    /** 
     * Description : Method used to get Sales reward Referenceability Type.
     * Created By : Rajesh 
     */
    public static List<Referenceability_Type__c> getReferenceabilityRewardDetails(List<String> refType) { 
        List<Referenceability_Type__c> listRefType = [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c WHERE Sales_Reward__c = true AND Visible__c = true  
                                                        AND Referenceability_code__c IN :refType AND Sales_Point__c != NULL LIMIT : refType.size()]; 
        return listRefType;
    }
    
    /** 
     * Description : Method used to get Sales reward Referenceability Type.
     * Created By : Rajesh (June 2 2017) 
     */
    public static List<Referenceability_Type__c> getUserRewardReferenceabilityType() { 
        List<Referenceability_Type__c> listRefType = [SELECT Name, Id, Sales_Point__c FROM Referenceability_Type__c WHERE Sales_Reward__c = true AND Visible__c = true AND Sales_Point__c != null  
                                                ORDER BY Name LIMIT :limits.getLimitQueryRows()]; 
        return listRefType;
    }
    
    /**
     *  Description : Method used to update User License.
     *  Created By : Rajesh 
     */
    public static List<User> updateUserLicense(List<User> user){
        update user;
        return user;
    } 

    /**
     * method to upsert Reference Content Type Field
     * author: Rajneesh (3 July, 2018)
     */
    public static void upsertReferenceConTypeFields(List<Reference_Content_Type_Field__c> RefContentTypeFields) {
        upsert RefContentTypeFields;
    }
}