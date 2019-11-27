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
public with sharing class ConstantsController { 
    
    // added for #603 - Gaurav Saini (29 Dec, 2016)
    // storing the account names for the RRAs which are failed because of inactive owners and are re-routed to CRP Team
    public static Set<String> failedRRAAccountNames = new Set<String>();
    public static Boolean isRbiUpdatedFromConTrigger = false;
    public static boolean fromAccount = false;
    public static boolean addParentToAccount = true;
    public static boolean addParentToContact = true;
    public static boolean addAttributesToContact = true;
    public static boolean deleteAttributeFromAccount = true;
    public static boolean addParentToContent = true;
    public static boolean fromAccountToContent = false;
    public static boolean addAttributesToContent = true;
    public static boolean addAttributesToAccount = false;
    public static boolean shouldAccountAttributeDeleteOfContact = false;
    public static boolean shouldAccountAttributeDeleteOfContent = false;
    public static boolean shouldAttributesOfContentDelete = false;
    public static boolean shouldAccountUpdate = true;
    public static boolean deleteAttributFromContact = false;
    public static boolean deleteAttributeFromContent = false;
    public static boolean updateReferenceabilityOnAccountChange = false;
    public static boolean updateRBIOnAccountChange = false;
    public static boolean updateCustomSettingWithValidation = true;
    public static boolean createRefContentRecord = true;
    public static boolean isRequestFromDM = false;
    public static boolean isCopyNominationDetailProcess = false;
    public static boolean runDuplicateRBICheck = true;
    public static boolean stopTriggerRbiOnMerge = false;
    public static boolean stopTriggerContentAccountOnMerge = false;
    public static boolean runCheckAttributeMappingEditMethod = true;
    public static boolean isNotificationSend = true;
    public static boolean accountDeletePrevious = false;
    public static boolean contactDeletePrevious = false;
    public static boolean shouldAccountAttributeDeleteOfContactOnNoMerge = true;
    public static boolean updateRBIInAccAttributes = false;
    public static boolean stopAccAttributeTrigger = false;
    public static boolean updateRBIInConAttributes = false;
    public static boolean stopConAttributeTrigger = false;
    public static boolean updateExistingAccounts = false;
    public static boolean updateExistingContacts = false;
    public static boolean enableAllEmail = true;
    public static boolean enableAllChatter = true;
    public static boolean enableAllSlack = true;
    public static string attributeId = '';
    public static boolean nomReferenceFromPage = false;
    
    public static boolean defaultManagedReferenceAccount = true;// Updated code for R11.29, Date : 21/10/2015, Tejpal
    
    public static string mergeAccountId = '';
    //Attribute Mapping Constants
    public static final String ACCOUNT = 'Account';
    public static final String CONTACT = 'Contact';
    public static final String OPPORTUNITY = 'Opportunity';
    public static final String OPPORTUNITYLINEITEM = 'OpportunityLineItem';
    public static final String REFERENCE_CONTENT = 'Reference Content';
    public static final String REFERENCE_PROFILE = 'Reference Profile';
    //R15.94
    public static final String NOTES = ' Request Notes:  '; 
    //  REF 1308
    public static String DC_FORM_IDENTIFY = 'DATACOLLECTORFORM'; 
    public static String DC_INITIAL_NOTIFICATION = 'Initial Notification'; 
    public static String DC_INITIAL_NOTIFICATIONSUB = 'Opportunity Information Request';
    public static String DC_INITIAL_NOTIFICATIONMSG = 'We would like to get further information on your Opportunity. Please use the link below to complete a quick form.Thank you!';

    public static String DC_REMINDER = 'Reminder';
    public static String DC_REMINDERSUB = 'Reminder: Opportunity Information Request';
    public static String DC_REMINDERMSG = 'This is a friendly reminder that we would like to get further information on your Opportunity. Please use the link below to complete a quick form.Thank you!';

    public static String DC_OWNER_ESCALATION = 'Escalation to Owner';
    public static String DC_OWNER_ESCALATIONSUB = 'Reminder: Opportunity Information Request';
    public static String DC_OWNER_ESCALATIONMSG = 'This is a final friendly reminder that we would like to get further information on your Opportunity. Please use the link below to complete a quick form. This is the last reminder that will be sent so your manager has also been copied on this message.Thank you!';

    public static String DC_MANAGER_ESCALATION = 'Escalation to Manager';
    public static String DC_MANAGER_ESCALATIONSUB = 'Escalation: Opportunity Information Request';
    public static String DC_MANAGER_ESCALATIONMSG = 'One of your team members has an Opportunity that we would like to get further information on. Your assistance is needed to help resolve this unanswered request.Thank you!';

    public static String DC_MANAGER_REVIEW = 'Manager Review';
    public static String DC_MANAGER_REVIEWSUB = 'Opportunity Information for Review';
    public static String DC_MANAGER_REVIEWMSG = 'One of your team members has provided information on a recent Opportunity that we would like you to review.Thank you!';

    public static String DC_CRP_TEAM_REVIEW = 'CRP Team Review';
    public static String DC_CRP_TEAM_REVIEWSUB = 'Opportunity Information for Review';
    public static String DC_CRP_TEAM_REVIEWMSG = 'A new record has been created that needs to be reviewed.Thank you!';
       
    public static String REFERENCE_CONTENT_TYPE = 'Data Collector';
    public static String OPP_ATTRIBUTE = 'Opportunity Attribute';
    public static String REFERENCE_MANAGER = 'Reference Manager';
    public static String STANDARD_USER = 'Standard User';
    // added for #1042 - Gaurav Saini (6 Oct, 2017)
    public static final String REFERENCE_PROFILE_FORM = 'Reference Profile Form';
    
    public static list<Reference_Request_Account__c> RRAInRBI{
        get{
            if(RRAInRBI == null){
                RRAInRBI = new list<Reference_Request_Account__c>();
            }
            return RRAInRBI;
        }
        set;
    }
    public static set<String> accountIdsInRBI{
        get{
            if(accountIdsInRBI == null){
                accountIdsInRBI = new Set<String>();
            }
            return accountIdsInRBI;
        }
        set;
    }
    //for copy selected att/ref when account is made reference program member
    public static set<String> attributeIdsinCopyNomi{
        get{
            if(attributeIdsinCopyNomi == null){
                attributeIdsinCopyNomi = new Set<String>();
            }
            return attributeIdsinCopyNomi;
        }
        set;
    }
    public static set<String> refIdsinCopyNomi{
        get{
            if(refIdsinCopyNomi == null){
                refIdsinCopyNomi = new Set<String>();
            }
            return refIdsinCopyNomi;
        }
        set;
    }
    public static string contactId = '';
    public static boolean copyExistingAtt = true;
    //Self Service Feedback Constants
    public static final String FEEDBACK_NOT_OCCUR = 'Use will not occur';
    public static final String FEEDBACK_YET_NOT_COMPLETED = 'Use not yet completed';
    public static final String FEEDBACK_SUCCESSFUL = 'Use completed - Successful';
    public static final String FEEDBACK_UNSUCCESSFUL = 'Use completed - Unsuccessful';
    //public static final String REFERENCE_STATUS_MSG = 'This @@@1 is not a member of the reference program. Adding @@@2 will automatically make them a reference program member with a status of @@@3. Continue?';
    public static final String REFERENCE_STATUS_MSG = System.Label.Reference_status_message;
    public static final String SELF_SERVICE_FEEDBACK_RESPONSE = 'Self Service Reference Use Feedback Response';
    public static final String CANDIDATE_CHECKED_ACCOUNT = System.Label.CANDIDATE_CHECKED_ACCOUNT;
    public static final String CANDIDATE_CHECKED_CONTACT = System.Label.CANDIDATE_CHECKED_CONTACT;
    public static final String CANDIDATE_CHECKED_ACCOUNT_Of_CONTACT = System.Label.CANDIDATE_CHECKED_ACCOUNT_Of_CONTACT;
    public static final String CANDIDATE_MEMBER_CHECK = System.Label.CANDIDATE_MEMBER_CHECK;
    public static final String DUPLICATE_RBI_CHECK_ACCOUNT = System.Label.DUPLICATE_RBI_CHECK_ACCOUNT;
    public static final String DUPLICATE_RBI_CHECK_CONTACT = System.Label.DUPLICATE_RBI_CHECK_CONTACT;
    public static final String SELECT_REFERENCEABILITY = System.Label.SELECT_REFERENCEABILITY;
    public static final String SELECT_REQUEST_FOR_ASSIGN = System.Label.SELECT_REQUEST_FOR_ASSIGN;
    public static final String ASSOCIATE_REQUEST_FOR_HIT = System.Label.ASSOCIATE_REQUEST_FOR_HIT;
    public static final String ERROR_NOMINATION_COMPLETED = System.Label.ERROR_NOMINATION_COMPLETED;
    public static final String ERROR_NOMINATION_REJECTION_NOTE = System.Label.ERROR_NOMINATION_REJECTION_NOTE;
    public static final String ERROR_NOMINATION_COMPLETED_DISPOSITION = System.Label.ERROR_NOMINATION_COMPLETED_DISPOSITION;
    public static final String ERROR_SELECT_REQUIRED_VALUE = System.Label.ERROR_SELECT_REQUIRED_VALUE;
    public static String UPDATED_SUBJECT_FOR_REF_REQUEST;
    
    public static final String CALENDAR_YEAR = 'Calendar Year';
    public static final String ALL = 'All';
    public static final String MANAGED = 'Managed';
    public static final String REP2REP = 'Peer2Peer';
    public static final String UNAVAILABLE = 'Unavailable';
    public static final String IN_PROGRESS = 'In Progress';
    public static final String APPROVED = 'Approved';
    public static final String ACCOUNT_SPECIFIED = 'Account Specified';
    public static final String DECLINED = 'Declined';
    public static final String INACTIVE = 'Inactive';
    public static final String ACTIVE = 'Active';
    public static final String CAUTION = 'Caution';
    public static final String ONHOLD = 'On Hold';
    public static final String NOT_STARTED = 'Not Started';
    public static final String NORMAL = 'normal';
    public static final String BOLD = 'bold';
    public static final String GENERAL = 'General';
    public static final String CONTENTVERSION = 'ContentVersion';
    public static final String NOMINATION = 'Nomination';
    public static final String NOMINATION_HEADER = 'NominationSectionHeader';
    public static final String COMPLETED = 'Completed';
    public static final String UNSPECIFIED = 'Unspecified';
    public static final String NO_LONGER_NEEDED = 'No Longer Needed';
    public static final String REFERENCE_LEAD = 'Reference Lead';
    public static final String REFERENCE_LEAD_HEADER = 'ReferenceLeadSectionHeader';
    public static final String NO_RESPONSE = 'No Response';
    public static final String NO_REFERENCE_MATCH = 'No Reference Match';
    public static final String NO_REFERENCE_MATCH_NOTIFICACTION_MSG = 'There are currently no References that match your request criteria.';
    public static final String NOMINATION_SUBMITTED = 'Nomination_Submitted';
    public static final String NOMINATION_APPROVED = 'Nomination_Approved';
    public static final String INVITATION_TO_CONTACT = 'Invitation_to_Contact';
    public static final String INVITATION_TO_CO_WORKER = 'Invitation_to_CoWorker';
    public static final String INVITATION_TO_CO_WORKER_CONTACT = 'Both';
    public static final String INVITATION_MESSAGE = 'Invitation';
    public static final String RLF_RESPONSE = 'RLF_Response';
    public static final String RLF_REFERRED = 'RLF_Referred_to_New_Owner';
    public static final String REQUEST_SALES = 'Request';
    public static final String PROFILE_UPDATE ='Profile_Update';
    public static final String REQUEST_APPROVED ='Request_Approved';
    public static final String Reference_Use_Feedback='Reference_Use_Feedback';
    public static final String REFERANCE_USE ='Record_Reference_Use';
    public static final String NOMINATION_REFERENCEABILITY = 'Nomination_Referenceability'; //re #1114
    
    public static final String FIELD_SELECTOR_NONIMATION_PROCESS = 'FieldSelectorNomination';//re #1133
    public static final String FIELD_SELECTOR_REQUEST_PROCESS = 'FieldSelectorRequest';//re #1133
    
    public static final String HEADER = 'Section 1 – Header';
    public static final String SUBHEADER = 'Section 2 – Sub Header';
    public static final String FREEFROMTEXT = 'Section 6 – Free Form Text';
    public static final String ATTRIBUTES = 'Section 3 – Attributes';
    public static final String CUSTOMFIELDS = 'Section 4 – Custom Fields';
    public static final String REFTYPES = 'Section 5 – Reference Activities';
    public static final String DM_REFERENCE_CONTENT = 'DMReference_Content__c';
    public static final String DMContentVersion = 'DMContentVersion';
    public static final String DEPENDENT_FILTERS = 'Dependent_Filters';
    //request status constants
    public static boolean shouldCompleteStatusChange = false;
    public static boolean shouldUnspecifiedStatusChange = false;
    public static boolean shouldArAndUrUpdate = true;
    public static boolean shouldCandidateRequestDelete = true;
    //conatants for nomination
    public static boolean shouldCandidateChecked = false;
    public static boolean shouldDataMappingProcessed = false;
    public static boolean shouldDispositionChanged = false;
    public static boolean forcecompleted = false;
    
    //constants to stop reward records created from account and contact
    public static boolean shouldRewardRecordsCreated = true;
    public static boolean shouldRewardRecordsValidatedOnDelete = true;
    public static boolean shouldRewardRecordsCreatedonFeedback = false;
    public static final String ISSUE = 'Issue';
    public static final String REDEEM = 'Redeem';
    
    //for attributeMapping fire
    public static boolean attMappingForRefContent = true; 
    public static boolean attMappingForContact = true;
    public static boolean attMappingForAccount = true;
    public static final String X_DAYS_FROM_AWARDDATE = '\'x\' days from award date';
    //Influitive constants 
    public static final String NON_REFEDGE_ACTIVITY_EVENT = 'Non-Reference Activity';
    public static final String EXPIRED_REWARD_EVENT = 'expired_rewards'; 
    public static boolean isInfluitiveNotRunning = true;
    public static boolean isfromInfluitiveBatch = false;
    public static boolean isNotFromRewardTrigger = true;
    public static boolean stopAfterInsertRBI = false;
    public static boolean isAccountSelectedfromContact = false;
	public static boolean isCallFromInfluitiveAPI = false;
    //REF-1964
    public static boolean isCallToInfluitiveAPI = false;
    //REF-2300
    public static final String Event_Error_Type = 'type';
    // Overlays Constants
    public static final String INVITATION_HELP_OVERLAY = 'Invitaion HelpOverlay'; 
    // Overlays Constants
    public static final String REQUEST_HELP_OVERLAY = 'Request HelpOverlay'; 
     public static final String PROFILE_HELP_OVERLAY = 'Profile Update HelpOverlay'; 
    
    public static final String HELP_ASSISTANT = 'Welcome back! '; 

    // Constant for Influitive Id :  ADJUSTMENT REF-1618
    public static final String ADJUSTMENT_INFL_ID  ='ADJUSTMENT ';
    //REF-1259
    public static boolean isCallFromBatchRemoveDuplicateRBI = false;
    public static String PARENT_OBJECT = 'Parent Object';
    public static String CHILD_OBJECT = 'Child Object';

    //  REF-2328
    public static boolean oppTriggerisInsert = false;
    public static boolean oppTriggerisUpdate = false;
    public static boolean oppTriggerisDelete = false;
    public static boolean oppTriggerisUndelete = false;

    public static boolean oppProductTriggerisInsert = false;
    public static boolean oppProductTriggerisUpdate = false;
    public static boolean oppProductTriggerisDelete = false;
    public static final String REF_MATCH = 'Match';
    public static final String LEAD = 'Lead';
    public static final String REFERRER_CASE = 'Case';
    public static final String REF_SEARCH_PAGE = 'RefSearch Page';
        
    public static list<Referenceability__c> RefIdSet {
        get {
            if(RefIdSet == null){
                RefIdSet = new list<Referenceability__c>();
            }
            return RefIdSet;
        }
        set;
    } 
    public static set<Id> RBIIds{
        get {
            if(RBIIds == null){
                RBIIds = new set<Id>();
            }
            return RBIIds;
        }
        set;
    }
    public static list<Hit_List__c> HitIdSet {
        get {
            if(HitIdSet == null){
                HitIdSet = new list<Hit_List__c>();
            }
            return HitIdSet;
        }
        set;
    }
    public static list<Reference_Basic_Information__c> RBIIdSet {
        get {
            if(RBIIdSet == null){
                RBIIdSet = new list<Reference_Basic_Information__c>();
            }
            return RBIIdSet;
        }
        set;
    }
    public static list<Reward__c> RewardList {
        get {
            if(RewardList == null){
                RewardList = new list<Reward__c>();
            }
            return RewardList;
        }
        set;
    }
    public static list<Reference_Request_Account_Contact__c> rracList {
        get {
            if(rracList == null){
                rracList = new list<Reference_Request_Account_Contact__c>();
            }
            return rracList;
        }
        set;
    }
    public static list<Nomination__c> NominationList {
        get {
            if(NominationList == null){
                NominationList = new list<Nomination__c>();
            }
            return NominationList;
        }
        set;
    }
    public static map<Id, decimal> RBIIdMap {
        get {
            if(RBIIdMap == null){
                RBIIdMap = new map<Id, decimal>();
            }
            return RBIIdMap;
        }
        set;
    }
    public static map<Id, Id> RewardContactMap {
        get {
            if(RewardContactMap == null){
                RewardContactMap = new map<Id, Id>();
            }
            return RewardContactMap;
        }
        set;
    }
    public static set<Id> rtMIds{
        get {
            if(rtMIds == null){
                rtMIds = new set<Id>();
            }
            return rtMIds;
        }
        set;
    }
    public static set<Id> rracIds{
        get {
            if(rracIds == null){
                rracIds = new set<Id>();
            }
            return rracIds;
        }
        set;
    }
    public static set<Id> labelIds{
        get {
            if(labelIds == null){
                labelIds = new set<Id>();
            }
            return labelIds;
        }
        set;
    }
    public static set<Id> RRLAIds{
        get {
            if(RRLAIds == null){
                RRLAIds = new set<Id>();
            }
            return RRLAIds;
        }
        set;
    }
    public static set<Id> RRLIds{
        get {
            if(RRLIds == null){
                RRLIds = new set<Id>();
            }
            return RRLIds;
        }
        set;
    }
    public static set<Id> NMLIds{
        get {
            if(NMLIds == null){
                NMLIds = new set<Id>();
            }
            return NMLIds;
        }
        set;
    }
    public static set<Id> NMLAIds{
        get {
            if(NMLAIds == null){
                NMLAIds = new set<Id>();
            }
            return NMLAIds;
        }
        set;
    }
    public static set<Id> AttributedIds{
        get {
            if(AttributedIds == null){
                AttributedIds = new set<Id>();
            }
            return AttributedIds;
        }
        set;
    }
    public static set<Id> RewardIds{
        get {
            if(RewardIds == null){
                RewardIds = new set<Id>();
            }
            return RewardIds;
        }
        set;
    }
    public static set<string> selectedAccounts{
        get {
            if(selectedAccounts == null){
                selectedAccounts = new set<string>();
            }
            return selectedAccounts;
        }
        set;
    }
    public static list<Account_Attribute__c> AccountAttsDelete{
        get{
            if(AccountAttsDelete == null){
                AccountAttsDelete= new list<Account_Attribute__c>();
            }
            return AccountAttsDelete;
        }
        set;
    }
    public static list<Contact_Attribute__c> ContactAttsDelete{
        get{
            if(ContactAttsDelete == null){
                ContactAttsDelete= new list<Contact_Attribute__c>();
            }
            return ContactAttsDelete;
        }
        set;
    }
    public static Map<String, String> localeDateFormatMap {
        get {
            Map<String, String> locale_map = new Map<String, String>();
            locale_map.put('ar', 'dd/MM/yyyy hh:mm a');
            locale_map.put('ar_AE', 'dd/MM/yyyy hh:mm a');
            locale_map.put('ar_BH', 'dd/MM/yyyy hh:mm a');
            locale_map.put('ar_JO', 'dd/MM/yyyy hh:mm a');
            locale_map.put('ar_KW', 'dd/MM/yyyy hh:mm a');
            locale_map.put('ar_LB', 'dd/MM/yyyy hh:mm a');
            locale_map.put('ar_SA', 'dd/MM/yyyy hh:mm a');
            locale_map.put('bg_BG', 'yyyy-M-d H:mm');
            locale_map.put('ca', 'dd/MM/yyyy HH:mm');
            locale_map.put('ca_ES', 'dd/MM/yyyy HH:mm');
            locale_map.put('ca_ES_EURO', 'dd/MM/yyyy HH:mm');
            locale_map.put('cs', 'd.M.yyyy H:mm');
            locale_map.put('cs_CZ', 'd.M.yyyy H:mm');
            locale_map.put('da', 'dd-MM-yyyy HH:mm');
            locale_map.put('da_DK', 'dd-MM-yyyy HH:mm');
            locale_map.put('de', 'dd.MM.yyyy HH:mm');
            locale_map.put('de_AT', 'dd.MM.yyyy HH:mm');
            locale_map.put('de_AT_EURO', 'dd.MM.yyyy HH:mm');
            locale_map.put('de_CH', 'dd.MM.yyyy HH:mm');
            locale_map.put('de_DE', 'dd.MM.yyyy HH:mm');
            locale_map.put('de_DE_EURO', 'dd.MM.yyyy HH:mm');
            locale_map.put('de_LU', 'dd.MM.yyyy HH:mm');
            locale_map.put('de_LU_EURO', 'dd.MM.yyyy HH:mm');
            locale_map.put('el_GR', 'd/M/yyyy h:mm a');
            locale_map.put('en_AU', 'd/MM/yyyy HH:mm');
            locale_map.put('en_B', 'M/d/yyyy h:mm a');
            locale_map.put('en_BM', 'M/d/yyyy h:mm a');
            locale_map.put('en_CA', 'dd/MM/yyyy h:mm a');
            locale_map.put('en_GB', 'dd/MM/yyyy HH:mm');
            locale_map.put('en_GH', 'M/d/yyyy h:mm a');
            locale_map.put('en_ID', 'M/d/yyyy h:mm a');
            locale_map.put('en_IE', 'dd/MM/yyyy HH:mm');
            locale_map.put('en_IE_EURO', 'dd/MM/yyyy HH:mm');
            locale_map.put('en_IN', 'dd/MM/yyyy');
            locale_map.put('en_NZ', 'd/MM/yyyy HH:mm');
            locale_map.put('en_SG', 'M/d/yyyy h:mm a');
            locale_map.put('en_US', 'M/d/yyyy h:mm a');
            locale_map.put('en_ZA', 'yyyy/MM/dd hh:mm a');
            locale_map.put('es', 'd/MM/yyyy H:mm');
            locale_map.put('es_AR', 'dd/MM/yyyy HH:mm');
            locale_map.put('es_BO', 'dd-MM-yyyy hh:mm a');
            locale_map.put('es_CL', 'dd-MM-yyyy hh:mm a');
            locale_map.put('es_CO', 'd/MM/yyyy hh:mm a');
            locale_map.put('es_CR', 'dd/MM/yyyy hh:mm a');
            locale_map.put('es_EC', 'dd/MM/yyyy hh:mm a');
            locale_map.put('es_ES', 'd/MM/yyyy H:mm');
            locale_map.put('es_ES_EURO', 'd/MM/yyyy H:mm');
            locale_map.put('es_GT', 'd/MM/yyyy hh:mm a');
            locale_map.put('es_HN', 'MM-dd-yyyy hh:mm a');
            locale_map.put('es_MX', 'd/MM/yyyy hh:mm a');
            locale_map.put('es_PE', 'dd/MM/yyyy hh:mm a');
            locale_map.put('es_PR', 'MM-dd-yyyy hh:mm a');
            locale_map.put('es_PY', 'dd/MM/yyyy hh:mm a');
            locale_map.put('es_SV', 'MM-dd-yyyy hh:mm a');
            locale_map.put('es_UY', 'dd/MM/yyyy hh:mm a');
            locale_map.put('es_VE', 'dd/MM/yyyy hh:mm a');
            locale_map.put('et_EE', 'd.MM.yyyy H:mm');
            locale_map.put('fi', 'd.M.yyyy H:mm');
            locale_map.put('fi_FI', 'd.M.yyyy H:mm');
            locale_map.put('fi_FI_EURO', 'd.M.yyyy H:mm');
            locale_map.put('fr', 'dd/MM/yyyy HH:mm');
            locale_map.put('fr_BE', 'd/MM/yyyy H:mm');
            locale_map.put('fr_CA', 'yyyy-MM-dd HH:mm');
            locale_map.put('fr_CH', 'dd.MM.yyyy HH:mm');
            locale_map.put('fr_FR', 'dd/MM/yyyy HH:mm');
            locale_map.put('fr_FR_EURO', 'dd/MM/yyyy HH:mm');
            locale_map.put('fr_LU', 'dd/MM/yyyy HH:mm');
            locale_map.put('fr_MC', 'dd/MM/yyyy HH:mm');
            locale_map.put('hr_HR', 'yyyy.MM.dd HH:mm');
            locale_map.put('hu', 'yyyy.MM.dd. H:mm');
            locale_map.put('hy_AM', 'M/d/yyyy h:mm a');
            locale_map.put('is_IS', 'd.M.yyyy HH:mm');
            locale_map.put('it', 'dd/MM/yyyy H.mm');
            locale_map.put('it_CH', 'dd.MM.yyyy HH:mm');
            locale_map.put('it_IT', 'dd/MM/yyyy H.mm');
            locale_map.put('iw', 'HH:mm dd/MM/yyyy');
            locale_map.put('iw_IL', 'HH:mm dd/MM/yyyy');
            locale_map.put('ja', 'yyyy/MM/dd H:mm');
            locale_map.put('ja_JP', 'yyyy/MM/dd H:mm');
            locale_map.put('kk_KZ', 'M/d/yyyy h:mm a');
            locale_map.put('km_KH', 'M/d/yyyy h:mm a');
            locale_map.put('ko', 'yyyy. M. d a h:mm');
            locale_map.put('ko_KR', 'yyyy. M. d a h:mm');
            locale_map.put('lt_LT', 'yyyy.M.d HH.mm');
            locale_map.put('lv_LV', 'yyyy.d.M HH:mm');
            locale_map.put('ms_MY', 'dd/MM/yyyy h:mm a');
            locale_map.put('nl', 'd-M-yyyy H:mm');
            locale_map.put('nl_BE', 'd/MM/yyyy H:mm');
            locale_map.put('nl_NL', 'd-M-yyyy H:mm');
            locale_map.put('nl_SR', 'd-M-yyyy H:mm');
            locale_map.put('no', 'dd.MM.yyyy HH:mm');
            locale_map.put('no_NO', 'dd.MM.yyyy HH:mm');
            locale_map.put('pl', 'yyyy-MM-dd HH:mm');
            locale_map.put('pt', 'dd-MM-yyyy H:mm');
            locale_map.put('pt_AO', 'dd-MM-yyyy H:mm');
            locale_map.put('pt_BR', 'dd/MM/yyyy HH:mm');
            locale_map.put('pt_PT', 'dd-MM-yyyy H:mm');
            locale_map.put('ro_RO', 'dd.MM.yyyy HH:mm');
            locale_map.put('ru', 'dd.MM.yyyy H:mm');
            locale_map.put('sk_SK', 'd.M.yyyy H:mm');
            locale_map.put('sl_SI', 'd.M.y H:mm');
            locale_map.put('sv', 'yyyy-MM-dd HH:mm');
            locale_map.put('sv_SE', 'yyyy-MM-dd HH:mm');
            locale_map.put('th', 'M/d/yyyy h:mm a');
            locale_map.put('th_TH', 'd/M/yyyy, H:mm ?.');
            locale_map.put('tr', 'dd.MM.yyyy HH:mm');
            locale_map.put('ur_PK', 'M/d/yyyy h:mm a');
            locale_map.put('vi_VN', 'HH:mm dd/MM/yyyy');
            locale_map.put('zh', 'yyyy-M-d ah:mm');
            locale_map.put('zh_CN', 'yyyy-M-d ah:mm');
            locale_map.put('zh_HK', 'yyyy-M-d ah:mm');
            locale_map.put('zh_TW', 'yyyy/M/d a h:mm');
            return locale_map;
        }
        private set;
    }
    public static POR_App_Configuration__c setEditionCustomSetting(){
        map < String, Schema.SObjectField > fldObjMap = schema.SObjectType.Nomination__c.fields.getMap();
        string namespace = '';
        for(String field: fldObjMap.keyset()){
            namespace = fldObjMap.get(field).getDescribe().getName();
            break;
        }
        POR_App_Configuration__c cs;
        if(namespace.contains('refedge__'))
            cs = new POR_App_Configuration__c(Namespace__c = 'refedge__', Edition_Key__c = 's414zuziUEIuvzHjECmsrzCKRp12LVwZj9MyFXAu7nR4nvYCKpFtdpqFUwSOv47VVFkBO7+cKN06J+JTSDkPctngV5m7o/aYouunR0rkKcwpibAuaNnQnZenvYTgbNvjBJ7HkBCLgV6K/aQZ6X63zEXmFSpoc2VtDtkty6KW/Dc=Pneumonultamicrosc12WlKmIfL7ggewMWGX0Qk6T6kJL8bqUB03d+i09em8CjQ=');
        else
            cs = new POR_App_Configuration__c(Namespace__c = '', Edition_Key__c = 's414zuziUEIuvzHjECmsrzCKRp12LVwZj9MyFXAu7nR4nvYCKpFtdpqFUwSOv47VVFkBO7+cKN06J+JTSDkPctngV5m7o/aYouunR0rkKcwpibAuaNnQnZenvYTgbNvjBJ7HkBCLgV6K/aQZ6X63zEXmFSpoc2VtDtkty6KW/Dc=Pneumonultamicrosc12WlKmIfL7ggewMWGX0Qk6T6kJL8bqUB03d+i09em8CjQ=');
        return cs;
    }

    /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ Map to get field discriptions for reference content and ref Profile 
​ ​ ​ ​ ​*​ ​ ​ @return :​  Map of string and object
    *   @Modified By: Rajesh REF-1537
​ ​ ​ ​ ​**/ 
    public static Map<String,Map<String, Object>> mapFieldsDetailsForDMObjects {
        get { 
        	Map<String, FieldDescription> mapFields = new Map<String, FieldDescription>(); 
            String namespace = UtilityController.appNamespace();
            Map<String,Map<String, FieldDescription>> returnMap = new Map<String,Map<String, FieldDescription>>(); 

            /* For Reference Contnets Fields*/
            mapFields.put('Id', new FieldDescription('15/18 digit salesforce ID', 'a0annnnnnnnnnnnnnn', 'REQUIRED','Leave blank when creating new Record.')); 
          	mapFields.put(namespace + 'Library_ID__c', new FieldDescription('15/18 digit salesforce ID', '058nnnnnnnnnnnnnnn', 'REQUIRED','The Salesforce CRM Library where the content will reside. Click LibraryID to see all your Libraries and their IDs.'));
            mapFields.put(namespace + 'Reference_Content_Type__c', new FieldDescription('Record', 'Case Study', 'REQUIRED','The Reference Content Type to be associated with this Reference Content record.'));
            mapFields.put(namespace + 'Title__c', new FieldDescription('Text', 'ReferenceEdge E icon', 'REQUIRED','The title that will be shown in Ref Search and on Microsites. '));
         	mapFields.put(namespace + 'Content_URL__c', new FieldDescription('URL', 'www.google.com', 'REQUIRED','Leave blank if the content will be uploaded.'));  
            mapFields.put(namespace + 'Content_Status__c', new FieldDescription('Checkbox', 'FALSE', 'DEFAULT','TRUE = Active. Inactive Reference Content does not appear in Ref Search.'));
            mapFields.put(namespace + 'Publish_date__c', new FieldDescription('Date', '21/04/2018', 'DEFAULT','Defaults to today’s date if not included.'));
            mapFields.put('OwnerId', new FieldDescription('15/18 digit salesforce ID', '005nnnnnnnnnnnnnnn', 'DEFAULT','The Content Author (User ID); if left blank this will be the User that performs the import.'));
            mapFields.put(namespace + 'Allow_Social_Sharing__c', new FieldDescription('Checkbox', 'TRUE', 'ADDITIONAL','TRUE = allow social sharing. Allows Microsite recipients to share the content item with others directly from the Microsite.'));
            mapFields.put(namespace + 'Article_publication_date__c', new FieldDescription('Date', '21/04/2018', 'ADDITIONAL',''));
            mapFields.put(namespace + 'Author__c', new FieldDescription('Text', 'John Smith', 'ADDITIONAL','255 character limit.'));
            mapFields.put(namespace + 'Custom_Reference_Content__c', new FieldDescription('Checkbox', 'FALSE', 'ADDITIONAL','TRUE = custom reference content.'));
            mapFields.put(namespace + 'Expiration_Date__c', new FieldDescription('Date', '21/04/2019', 'ADDITIONAL','The Reference Content record will be set to Inactive on this date if populated.'));
            mapFields.put(namespace + 'External_Summary__c', new FieldDescription('Text', 'External Summary text', 'ADDITIONAL','32,000 character limit. The content Summary that will show on Microsites.'));
            mapFields.put(namespace + 'Featured_Content__c', new FieldDescription('Checkbox', 'FALSE', 'ADDITIONAL','TRUE = featured content. Featured Reference Content is designated with a star in Ref Search. There is an option in Custom Settings to ensure featured content always appears first in Reference Content search results. '));
            mapFields.put(namespace + 'Internal_Use__c', new FieldDescription('Checkbox', 'FALSE', 'ADDITIONAL','TRUE = internal only content; FALSE = shareable content.'));
            mapFields.put(namespace + 'Language__c', new FieldDescription('Picklist', 'English', 'ADDITIONAL','Use "English" without the quotes for English.'));
            mapFields.put(namespace + 'Publication_name__c', new FieldDescription('Text', 'Wall Street Journal', 'ADDITIONAL','255 character limit.'));
            mapFields.put(namespace + 'Review_Date__c', new FieldDescription('Date', '21/04/2019', 'ADDITIONAL','A report is included in ReferenceEdge reports that can be scheduled to send a weekly notification to the Customer Reference Team including all Content that has reached review date in the last 7 days.'));
            mapFields.put(namespace + 'Search_Terms_keywords__c', new FieldDescription('Text', 'astronaut', 'ADDITIONAL','32,000 character limit.'));
            mapFields.put(namespace + 'Substitute_Account_Name__c', new FieldDescription('Text', 'Global Search Engine Provider', 'ADDITIONAL','255 character limit.'));
            mapFields.put(namespace + 'Summary__c', new FieldDescription('Text', 'Summary text', 'ADDITIONAL','32,000 character limit. The Reference Content summary available in Ref Search (only visible to ReferenceEdge users).'));
            mapFields.put(namespace + 'Attributes__c', new FieldDescription('15/18 digit salesforce ID', 'a04nnnnnnnnnnnnnnn', 'ATTRIBUTES','The Attribute Export in RefEdgeDM provides a comprehensive report of all Attributes and their associated 15 or 18 digit IDs. Multiple Attributes can be imported for the same Reference Content record. Create two columns for each Parent Attribute you want to include in your import file: one for the ID (this is the column that will be imported), one for the Attribute name (this makes data reviews much easier - this column is NOT imported).'));
            mapFields.put(namespace + 'Associated_Accounts__c', new FieldDescription('15/18 digit salesforce ID', '', 'ACCOUNTS','The Account Export in RefEdgeDM provides a simple report of all Accounts and their associated 15/18 digit IDs. Multiple Accounts can be associated to the same Reference Content record. Create two columns for Account - one for the ID (this is the column that will be imported), one for the \'human readable\' Account name (this makes import data reviews much easier - this column is NOT imported).'));
            returnMap.put('DMReference_Content__c',mapFields);
             /* For Reference Prfile Fields*/
            mapFields = new Map<String, FieldDescription>(); 
            mapFields.put(namespace + 'Account__c', new FieldDescription('15/18 digit salesforce ID', '001nnnnnnnnnnnnnnn', 'REQUIRED','The salesforce ID of the Account.')); 
            mapFields.put(namespace + 'Contact__c', new FieldDescription('15/18 digit salesforce ID', '003nnnnnnnnnnnnnnn', 'REQUIRED','The salesforce ID of the Contact. If the Reference Profile is for an Account then this field can be left blank.'));
            mapFields.put(namespace + 'Referenceability_Status__c', new FieldDescription('Picklist', 'Active', 'REQUIRED','Valid Status are "Active", "Caution", and "Inactive". If set to Inactive then an Inactive Reason MUST be included.')); 
            mapFields.put(namespace + 'Profile_Update_Owner__c', new FieldDescription('15/18 digit salesforce ID', '005nnnnnnnnnnnnnnn', 'ADDITIONAL','ReferenceEdge will route Profile Update notifications to this user rather than the Account Owner / Reference Owner if this field is populated.')); 
            mapFields.put(namespace + 'RUL_Activities_will_do__c', new FieldDescription('Number', '1', 'ADDITIONAL','The maximum number of uses for a given Account or Contact within the specified time period.')); 
            mapFields.put(namespace + 'RUL_Period__c', new FieldDescription('Number', '30', 'ADDITIONAL','The time period related to the maximum number of uses for a given Account or Contact.'));
            mapFields.put(namespace + 'Reference_Owner__c', new FieldDescription('15/18 digit salesforce ID', '005nnnnnnnnnnnnnnn', 'ADDITIONAL','ReferenceEdge will route requests to this user rather than the Account Owner if this field is populated.')); 
            mapFields.put(namespace + 'Inactive_Reason__c', new FieldDescription('Text', 'Contact left company.', 'ADDITIONAL','This field is required if any imported profiles include the Reference Status "Inactive". ')); 
            mapFields.put(namespace + 'Is_Referenceable__c', new FieldDescription('Checkbox', 'TRUE', 'ADDITIONAL','TRUE = Reference Program Member. Active / Caution Program Members appear in Ref Search.'));             
            mapFields.put(namespace + 'Joined_Reference_Program__c', new FieldDescription('Date', '21/04/2018', 'ADDITIONAL','Shown on Contact Reference Profiles only.')); 
            mapFields.put(namespace + 'Managed_Reference_Account__c', new FieldDescription('Checkbox', 'FALSE', 'ADDITIONAL','Only applicable to referenceable Accounts. When this checkbox is set to TRUE any Request for the use of the Account will go to the Salesforce public group "Customer Reference Team".'));             
            mapFields.put(namespace + 'Referenceability__c', new FieldDescription('15/18 digit salesforce ID', 'a0nnnnnnnnnnnnnnnn', 'ADDITIONAL','The ReferenceabilityType(s) to be associated with this Reference Profile record. Multiple Referenceability Types can be imported for the same Reference Profile record. In the \'Edit Mapping\' step Referenceability should be mapped to "ReferenceabilityType Ids1"')); 
            returnMap.put('DMReference_Basic_Information__c',mapFields);
            /* For Request Fields */
            mapFields = new Map<String, FieldDescription>(); 
            mapFields.put(namespace + 'Account__c', new FieldDescription('15/18 digit salesforce ID', '001nnnnnnnnnnnnnnn', 'REQUIRED','The salesforce ID of the Account.')); 
            mapFields.put(namespace + 'Contact__c', new FieldDescription('15/18 digit salesforce ID', '003nnnnnnnnnnnnnnn', 'REQUIRED','The salesforce ID of the Contact. If the Request is for an Account then this field can be left blank.'));
            mapFields.put(namespace + 'Reference_Type_Needed__c', new FieldDescription('15/18 digit salesforce ID or Name', 'a0nnnnnnnnnnnnnnnn or Reference Call', 'REQUIRED','The Referenceability Type to be associated with this Request record.'));
            mapFields.put(namespace + 'Feedback_Status__c', new FieldDescription('Picklist', 'Use completed - Successful', 'REQUIRED','Required if Contact is populated. Two options: “Use completed - Successful” or “Use completed - Unsuccessful”.'));
            mapFields.put(namespace + 'Feedback_Response__c', new FieldDescription('Text', 'Call was no longer needed.', 'REQUIRED','Required if Contact is populated and Use Feedback value = “Use completed - Unsuccessful”.'));
            
            mapFields.put(namespace + 'Status__c', new FieldDescription('Picklist', 'Completed', 'DEFAULT','All Historical Requests are recorded as a Completed.'));
            mapFields.put(namespace + 'Reference_Use__c', new FieldDescription('Checkbox', 'TRUE', 'DEFAULT','All Historical Requests are recorded as a Reference Use.'));
            mapFields.put(namespace + 'Process__c', new FieldDescription('Picklist', 'Managed', 'DEFAULT','All Historical Requests are recorded as managed requests.'));
            mapFields.put(namespace + 'Deadline__c', new FieldDescription('Date', '04/21/19', 'DEFAULT','Defaults to today’s date.'));
            mapFields.put(namespace + 'Project_Type__c', new FieldDescription('Picklist', 'Member', 'DEFAULT','All Historical Requests are recorded as activities by program members.'));
            mapFields.put(namespace + 'Activity_Date__c', new FieldDescription('Date', '04/21/2019', 'REQUIRED','Date when the activity occurred.'));
            
            mapFields.put(namespace + 'Opportunity__c', new FieldDescription('15/18 digit salesforce ID', '001nnnnnnnnnnnnnnn', 'ADDITIONAL','Opportunity (Opportunity ID) Associated with the Request.'));
            mapFields.put(namespace + 'Requester__c', new FieldDescription('15/18 digit salesforce ID', '005nnnnnnnnnnnnnnn', 'ADDITIONAL','The user that submitted the request (User ID) if left blank this will be the User that performs the import.'));
            mapFields.put(namespace + 'Title__c', new FieldDescription('Text', 'Case Study with ABC Company', 'ADDITIONAL','255 character limit.'));
            
            mapFields.put(namespace + 'Attributes__c', new FieldDescription('15/18 digit salesforce ID', 'a04nnnnnnnnnnnnnnn', 'ATTRIBUTES','The Attribute Export in RefEdgeDM provides a comprehensive report of all Attributes and their associated 15 or 18 digit IDs. Multiple Attributes can be imported for the same Historical Request record. Create two columns for each Parent Attribute you want to include in your import file: one for the ID (this is the column that will be imported), one for the Attribute name (this makes data reviews much easier - this column is NOT imported).'));
            
            mapFields.put(namespace + 'Accounts__c', new FieldDescription('15/18 digit salesforce ID', '', 'ACCOUNTS','The Account Export in RefEdgeDM provides a simple report of all Accounts and their associated 15/18 digit IDs. Create two columns for Account - one for the ID (this is the column that will be imported), one for the \'human readable\' Account name (this makes import data reviews much easier - this column is NOT imported).'));
            
            mapFields.put(namespace + 'Contacts__c', new FieldDescription('15/18 digit salesforce ID', '', 'CONTACTS','The Contact Export in RefEdgeDM provides a simple report of all Contacts and their associated 15/18 digit IDs. Create two columns for Contacts - one for the ID (this is the column that will be imported), one for the \'human readable\' Contact name (this makes import data reviews much easier - this column is NOT imported).'));
            
            mapFields.put(namespace + 'Label__c', new FieldDescription('15/18 digit salesforce ID', '', 'FILTERS','The Filter Export in RefEdgeDM provides a comprehensive report of all Filters and their associated 15 or 18 digit IDs. Multiple Filter can be imported for the same Historical Request record. Create two columns for each Filter you want to include in your import file: one for the ID (this is the column that will be imported), one for the Filter name (this makes data reviews much easier - this column is NOT imported).'));
            returnMap.put('DMReference_Request__c',mapFields);
            return returnMap;
        }
        private set;
    } 

    /**
     * WrapperClass for FieldDescription fields details
     */
    public class FieldDescription {
        public String fieldType, example, section, description;  
        
        //constructor FieldDetailsWrapper
        public FieldDescription(String fieldType, String example, String section, String description) {            
            this.fieldType = fieldType;
            this.example = example;
            this.section = section;           
            this.description = description; 
        }        
    }
    
    //REF2349
    public static Boolean isFromEmailChatterSettings = false;
}