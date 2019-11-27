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
    * VF Page: DataCollectorPageSLDS
    * Description: Class to get feedback.
    * Created By: Rajneesh (may 25, 2018)
*/

public with sharing class DataCollectorControllerSLDS {
    
    /**
        * Properties and variables
    */
    public Boolean refContentSec { get; set; }
    public Boolean isPreview { get; set; }
    public String refContentRecord { get; set; }
    public Boolean isError { get; set; }
    public String strValue { get; set; }
    public String deletedRecordMsg { get; set; }
    public String fieldOfRefContent { get; set; }
    public String StatusOptions { get; set; }
    public Boolean isNote {get;set;}
    public String currentUser { get; set; } 
    public Boolean noIdAssociated { get; set; }
    public String dmForMsgMap { get; set; }
    public String customSettingId { get; set; }
    public Boolean isSave { get; set; }
    public String contentId { get; set; }

    //to resolve namespace issue on package creation
    public String nameSpace {
        get {
            return UtilityController.appNamespace();
        }
        private set;
    }
    
    //  Constructor
    public DataCollectorControllerSLDS () {
           
        Id currentLoggedUser = UserInfo.getUserId();
        currentUser = JSON.serialize(currentLoggedUser);
        customSettingId = '';
        refContentSec = false;
        isPreview = false;
        isSave = false;
        isError = false;
        refContentRecord = '';
        strValue = '';
        deletedRecordMsg = '';
        isNote = false;
        noIdAssociated = false;
     
        // Get Reference Content Id from url
        contentId = ApexPages.currentPage().getParameters().get('id') != null ? ApexPages.currentPage().getParameters().get('id') : '';    
        customSettingId = ApexPages.currentPage().getParameters().get('customSettingId');

        String dmRecordId = ApexPages.currentPage().getParameters().get('customFormId') != null ? ApexPages.currentPage().getParameters().get('customFormId').substringBefore('?') : '';               
        
        //Set for CRP team member
        Set<id> userIdSet = new Set<id>();
        
        for(user usr :  UtilityController.getCustomerReferenceTeam()) {
            userIdSet.add(usr.Id);
        }        
        
        //	Check whether loggedIn user is part of crp team
        if(userIdSet.contains(currentLoggedUser)) {
            isSave = true;
        }

        Reference_Content__c referenceRecord = new Reference_Content__c();
        List<Reference_Content__c> refContList = new List<Reference_Content__c>();
        
        if(contentId != '' || dmRecordId != '') {
            
            if (contentId != '') {
                refContList = [SELECT Id, Name, Opportunity__c, Title__c, Data_Collector_Name__c, Opportunity__r.ownerId, Opportunity__r.Name, Opportunity__r.Owner.ManagerId, Opportunity__r.StageName, Content_Status__c, Internal_Use__c,
                                opportunity__r.AccountId, Opportunity__r.owner.Name, opportunity__r.Account.Name, Data_Collector_Status__c FROM Reference_Content__c WHERE id =: String.escapeSingleQuotes(contentId)];
                
                if(refContList.Size() > 0) {
                    referenceRecord = refContList[0];
                    refContentRecord = JSON.serialize(refContList[0]);
                    } else {
                    deletedRecordMsg = label.Reference_Content_Deleted;
                    isNote = true;
                }
                
                if(referenceRecord.Opportunity__r.Owner.ManagerId == currentLoggedUser && !userIdSet.contains(currentLoggedUser)) {
                    refContentSec = true;
                }               
            }
            
            if (contentId != '') {
                strValue = referenceRecord.Data_Collector_Name__c;
                } else if(dmRecordId != ''){
                isPreview = true;
                strValue = [SELECT id, Data_Collector_Name__c FROM Data_Mapping__c WHERE id =: String.escapeSingleQuotes(dmRecordId)].Data_Collector_Name__c;
            }
            } else {
            noIdAssociated = true;
        }
    }
    
    public class SectionWrapper {
        public String Name { get; set; }
        public String id { get; set; } 
        public List<SectionItemWrapper> Field { get; set; }
        
        public SectionWrapper(string nam, Integer secId) {
            Name = nam;
            id = String.valueOf(secId);
            Field = new List<SectionItemWrapper>();
        }
    }
    
    public class SectionItemWrapper {
        public String fieldAPIName { get; set; }   
        public String fieldId { get; set; }
        public String fieldLabel { get; set; }
        public String fieldType { get; set; }
        public List<String> options { get; set; } 
        public String objectName { get; set; }
        public String objectLabel { get; set; }
        public String SelectedValue { get; set; }
        public List<MultiPicklistWrapper> multiPickOptions { get; set; }
        
        public SectionItemWrapper(String clApiName, string clId, String clLabel, String clType, List<String> optList, String objName, String objLabel, String selectVal, List<MultiPicklistWrapper> mpListOptions) {
            fieldAPIName = clApiName;
            fieldId = String.valueOf(clId);
            fieldLabel = clLabel;
            fieldType = clType;
            options = optList;
            objectName = objName;
            objectLabel = objLabel;
            SelectedValue = selectVal;
            multiPickOptions = mpListOptions;
        }
    }
    
    // class to get multipicklist options
    public class MultiPicklistWrapper { 
        String value { get; set; }
        String name { get; set; }
        
        public MultiPicklistWrapper(string name,String value) { 
            this.name = name; 
            this.value = value;   
        }
    }
    
    //  Method to get referenceContent field and picklist value information
    @RemoteAction
    public static String getRefContentFieldAndPicklist() {
        
        List<SectionItemWrapper> refConInfoList = new List<SectionItemWrapper>();
        Map<String, Schema.SObjectField> m = Schema.SObjectType.Reference_Content__c.fields.getMap();
        List<String> optionList = new List<String>();
        List<MultiPicklistWrapper> mploptions = new List<MultiPicklistWrapper>();
        
        for(Schema.SObjectField f : m.values()) {
            Schema.DescribeFieldResult d = f.getDescribe();
            
            if(d.getName() == UtilityController.appNamespace() +'Title__c') {
                refConInfoList.add(new SectionItemWrapper(d.getName(), '2', d.getLabel(), String.valueOf(d.getType()), optionList, '', '', '', mploptions));
                } else if(d.getName() == UtilityController.appNamespace() +'Content_Status__c') {
                Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content__c.fields.getMap().get(d.getName()).getDescribe();
                List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
                
                for (Schema.PicklistEntry fopt : ple) {
                    optionList.add(String.valueOf(fopt.value));
                }
                refConInfoList.add(new SectionItemWrapper(d.getName(), '3', d.getLabel(), String.valueOf(d.getType()), optionList, '', '', '', mploptions));
                } else if(d.getName() == UtilityController.appNamespace() +'Internal_Use__c') {
                refConInfoList.add(new SectionItemWrapper(d.getName(), '1', d.getLabel(), String.valueOf(d.getType()), optionList, '', '', '', mploptions));
            } 
        }
        return JSON.serialize(refConInfoList);
    }
    
    
    //  Method to get form information like Sections, Fields and other information which is used in this page
    @RemoteAction
    public static List<String> getReferenceContentInfo(String RefContentRec, String isPreview, String formName) {
        
        List<String> strList = new List<String>();
        Reference_Content_Type_Field__c rcTypeField = new Reference_Content_Type_Field__c();       
        String strValue = formName;     
        // map for section id and list of field
        Map<string, List<Data_Mapping__c>> fieldMap = new Map<String, List<Data_Mapping__c>>();
        List<SectionWrapper> secWrapList = new List<SectionWrapper>();
        String queryVal = 'SELECT id, ';
        Map<String, Data_Mapping__c> dmMap = new Map<String, Data_Mapping__c>();
        List<Data_Mapping__c>  dmList = [SELECT Field_API_Name__c, DC_Message__c, Label__c, Section_Name__c, Data_Collector_Name__c, Order__c, Section_Position__c FROM Data_Mapping__c WHERE Data_Collector_Name__c =: strValue ORDER BY Section_Position__c];
        List<String> dateTimeField = new List<String>();
        Set<String> multiSelectSet = new Set<String>();
        List<SectionItemWrapper> msplSelectVal = new List<SectionItemWrapper>();
        
        //    Check whether any record with the passes name is or not
        if(dmList.Size() > 0) {
            
            // Iterate the list 
            for(Data_Mapping__c dm : dmList) {                      
                
                //    for Form Name, Header and Sub Header
                if(dm.Order__c == null && dm.Section_Position__c == null && dm.Section_Name__c == ConstantsController.DC_FORM_IDENTIFY){
                    //  Form Name
                    strList.add(dm.Data_Collector_Name__c);
                    //  Form Header
                    strList.add(dm.Label__c);
                    //  Form SubHeader
                    strList.add(dm.Field_API_Name__c);
                }                
                
                //    To populate map                        
                if(dm.Order__c == null && dm.Section_Position__c == null && (dm.Section_Name__c == ConstantsController.DC_MANAGER_REVIEW  || dm.Section_Name__c == ConstantsController.DC_CRP_TEAM_REVIEW )){
                    dmMap.put(dm.Section_Name__c, dm);
                }
                
                //    for section information
                if(dm.Section_Position__c != null && dm.Order__c == null) {
                    secWrapList.add(new SectionWrapper(dm.Field_API_Name__c, Integer.valueOf(dm.Section_Position__c)));
                }                
                
                //    for field Information
                if(dm.Section_Position__c != null && dm.Order__c != null) {
                    
                    if(!fieldMap.containsKey(String.valueOf(dm.Section_Position__c))) {
                        fieldMap.put(String.valueOf(dm.Section_Position__c), new List<Data_Mapping__c>());
                    }
                    fieldMap.get(String.valueOf(dm.Section_Position__c)).add(dm);
                }
            }
            
            //  REF-1932
            //  Set contains all the fields of Reference_Content_Type_Field__c
            Map<String, String> RCTFIeldsSet = new Map<String, String>();
            Map<String, Schema.SObjectField> schemaFieldMap = Reference_Content_Type_Field__c.SObjectType.getDescribe().fields.getMap();

            for(Schema.SObjectField fldApi : schemaFieldMap.values()) {
                Schema.DescribeFieldResult d = fldApi.getDescribe();      
                    if(d.getName().contains('__c')){
                            RCTFIeldsSet.put(d.getName().toLowerCase(), d.getLabel());                      
                    }
            }
            
            for(SectionWrapper sw : secWrapList) {
                
                if(fieldMap.containsKey(sw.id)) {
                    
                    for(Data_Mapping__c dmfld : fieldMap.get(sw.id)) {
                        
                        //  Check whether field is deleted or not " From the object"
                        if(RCTFIeldsSet.containsKey(dmfld.Field_API_Name__c.toLowerCase())) {
                            
                            if(dmfld.Section_Name__c == 'PICKLIST' || dmfld.Section_Name__c == 'MULTIPICKLIST') {
                                List<String> optionList = new List<String>();
                                List<MultiPicklistWrapper> mploptions = new List<MultiPicklistWrapper>();
                                Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap().get(dmfld.Field_API_Name__c).getDescribe(); 
                                
                                List<Schema.PicklistEntry> ple = dfr.getPicklistValues();
                                
                                for (Schema.PicklistEntry f : ple) {
                                    
                                    if(dmfld.Section_Name__c == 'PICKLIST') {
                                        optionList.add(String.valueOf(f.value));
                                        } else {
                                        mploptions.add(new MultiPicklistWrapper(String.valueOf(f.value).trim(), String.valueOf(f.value).trim()));
                                        multiSelectSet.add(dmfld.Field_API_Name__c);
                                    }                                    
                                }
                                sw.Field.add(new SectionItemWrapper(dmfld.Field_API_Name__c, String.valueOf(dmfld.Order__c), RCTFIeldsSet.get(dmfld.Field_API_Name__c.toLowerCase()), dmfld.Section_Name__c, optionList, '', '', '', mploptions));
                                
                                }  else if(dmfld.Section_Name__c == 'REFERENCE') {
                                String ObjectName = '';
                                Schema.DescribeFieldResult dfr = Schema.sObjectType.Reference_Content_Type_Field__c.fields.getMap().get(dmfld.Field_API_Name__c).getDescribe(); 
                                
                                if(dfr.getReferenceTo().size() > 1) {
                                    ObjectName =  string.valueOf(dfr.getReferenceTo()[1]);
                                    } else {
                                    ObjectName =  string.valueOf(dfr.getReferenceTo()[0]);
                                }
                                queryVal += dmfld.Field_API_Name__c.replace('__c','__r') +'.Name, '; 
                                sw.Field.add(new SectionItemWrapper(dmfld.Field_API_Name__c, String.valueOf(dmfld.Order__c), RCTFIeldsSet.get(dmfld.Field_API_Name__c.toLowerCase()), dmfld.Section_Name__c, new List<String>(), ObjectName, dfr.getLabel(), dmfld.Field_API_Name__c.replace('__c','__r'), new List<MultiPicklistWrapper>()));
                                
                                } else if(dmfld.Section_Name__c == 'DATETIME' || dmfld.Section_Name__c == 'DATE') {
                                dateTimeField.add(dmfld.Field_API_Name__c);
                                sw.Field.add(new SectionItemWrapper(dmfld.Field_API_Name__c, String.valueOf(dmfld.Order__c), RCTFIeldsSet.get(dmfld.Field_API_Name__c.toLowerCase()), dmfld.Section_Name__c, new List<String>(), '','','', new List<MultiPicklistWrapper>()));
                                }else {
                                sw.Field.add(new SectionItemWrapper(dmfld.Field_API_Name__c, String.valueOf(dmfld.Order__c), RCTFIeldsSet.get(dmfld.Field_API_Name__c.toLowerCase()), dmfld.Section_Name__c, new List<String>(), '','','', new List<MultiPicklistWrapper>()));
                            }                         
                            queryVal += dmfld.Field_API_Name__c +', '; 
                        }
                        
                    }
                }
            }
            queryVal = queryVal.removeEnd(', ');
            
            if(isPreview == 'false') {
                Reference_Content__c referenceRecord = (Reference_Content__c)JSON.deserialize(RefContentRec, Reference_Content__c.class);
                queryVal += ' FROM Reference_Content_Type_Field__c WHERE Reference_Content__c = \''+referenceRecord.Id+'\'ORDER By createddate LIMIT 1';
                
                if(referenceRecord.Data_Collector_Status__c == 'New' && referenceRecord.id != null) {
                    rcTypeField.Reference_Content__c = referenceRecord.id;
                    
                    if(multiSelectSet.size() > 0) {
                        List<MultiPicklistWrapper> mploptions = new List<MultiPicklistWrapper>();

                        for(String str : multiSelectSet) {                              
                            msplSelectVal.add(new SectionItemWrapper(str, '', '', '', new List<String>(), '', '', '', mploptions));
                        }  
                    }
                } else {
                    rcTypeField = database.query(queryVal);
                    
                    if(multiSelectSet.size() > 0) {  
                        
                        for(String str : multiSelectSet) {                            
                            
                            List<MultiPicklistWrapper> mploptions = new List<MultiPicklistWrapper>();
                            
                            if(rcTypeField.get(str) != null) {
                                
                                if(String.valueOf(rcTypeField.get(str)).contains(';')) {
                                    
                                    for(String pickval : String.valueOf(rcTypeField.get(str)).split(';')) {
                                        mploptions.add(new MultiPicklistWrapper(pickval.trim(), pickval.trim()));
                                    }
                                    } else {
                                    mploptions.add(new MultiPicklistWrapper(String.valueOf(rcTypeField.get(str)).trim(), String.valueOf(rcTypeField.get(str)).trim()));
                                }
                            }
                            msplSelectVal.add(new SectionItemWrapper(str, '', '', '', new List<String>(), '', '', '', mploptions));
                        } 
                    }
                }
            }           
            
            strList.add(JSON.serialize(rcTypeField));
            strList.add(JSON.serialize(secWrapList));     
            strList.add(JSON.serialize(dmMap));
            strList.add(JSON.serialize(dateTimeField));
            strList.add(JSON.serialize(msplSelectVal));
        }
        return strList;
    }
    
    //     Method to get Date Format
    @RemoteAction
    public static String getDateFormat() {   
        String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
        return dateFormat; 
    }
    
    public class DateConvert {
        public String fieldApi;
        public String value;
    }
    
    @RemoteAction
    public static String saveResult(String recordVal, String refContent, String currentUser, String dmMsgMap, String dtMap, String multiPicVal) {
        
        Reference_Content_Type_Field__c rctf = new Reference_Content_Type_Field__c();            
        Reference_Content__c refCont =  new Reference_Content__c();
        Map<String, Data_Mapping__c> dmMap = new Map<String, Data_Mapping__c>();
        Id currentLoggedUser = null;
        String returnResult = '';
        List<DateConvert> dateTimeMap = new List<DateConvert>(); 
        List<SectionItemWrapper>  multiPicFldValues = new List<SectionItemWrapper>();
        Decimal rewardPoints = 0;
        String actionMessage = ''; 
        
        try{
            dateTimeMap = (List<DateConvert>)JSON.deserialize(dtMap, List<DateConvert>.class);
            rctf = (Reference_Content_Type_Field__c)JSON.deserialize(recordVal, Reference_Content_Type_Field__c.class); 
            multiPicFldValues = (List<SectionItemWrapper>)JSON.deserialize(multiPicVal, List<SectionItemWrapper>.class); 
            system.debug('Field MultipickList with Values : ' + multiPicFldValues );
            
            if(multiPicFldValues.size() > 0) {
            
                for(SectionItemWrapper fldMPL : multiPicFldValues) {
                    String mplVal = '';
                    
                    if(fldMPL.multiPickOptions.size() > 0) {
                        
                        for(MultiPicklistWrapper picVal : fldMPL.multiPickOptions) {
                            mplVal += picVal.name+ ';';
                        }
                        mplVal.removeEnd(';');
                    }
                    rctf.put(fldMPL.fieldAPIName, mplVal);
                }
            }
            
            if(dateTimeMap.size() > 0) {
                
                for(DateConvert dc : dateTimeMap) {
                    
                    if(dc.value.contains('-')) {
                        
                        if(dc.value.contains('T')) {
                            list<String> lstSplitDate = dc.value.split('T')[0].split('-');
                            rctf.put(dc.fieldApi , date.newinstance(Integer.valueOf(lstSplitDate[0]), Integer.valueOf(lstSplitDate[1]), Integer.valueOf(lstSplitDate[2])));
                            } else {
                            list<String> lstSplitDate = dc.value.split('-');
                            rctf.put(dc.fieldApi , date.newinstance(Integer.valueOf(lstSplitDate[0]), Integer.valueOf(lstSplitDate[1]), Integer.valueOf(lstSplitDate[2])));
                        }
                        
                        } else {
                        rctf.put(dc.fieldApi , date.parse(dc.value));
                    }
                }
            }
            
            refCont =  (Reference_Content__c)JSON.deserialize(refContent, Reference_Content__c.class);
            dmMap = (Map<String, Data_Mapping__c>)JSON.deserialize(dmMsgMap, Map<String, Data_Mapping__c>.class);
            currentLoggedUser = Id.valueOf(currentUser.replace('\"',''));
            
            //Set for CRP team member
            Set<id> userIdSet = new Set<id>();
            
            for(user usr :  UtilityController.getCustomerReferenceTeam()) {
                userIdSet.add(usr.Id);
            }
            
            Custom_Settings__c cs = UtilityController.getCustomSettings();
                
            if(refCont.Data_Collector_Status__c != null && refCont.Data_Collector_Status__c == 'New') {
                refCont.Data_Collector_Status__c = 'In Progress';
                RefEdge_Configuration_Protected__c protectedAppConfig = RefEdge_Configuration_Protected__c.getOrgDefaults();
                List<sObject> postFeedItems = new List<sObject>();
                List<MailChatterController.EmailMessage> emailstoSentList = new List<MailChatterController.EmailMessage>();
                String LINK_URL = URL.getSalesforceBaseUrl().toExternalForm() + Page.DataCollectorPage.getURL() + '?id=';
                List<Map<String, String>> messagesList = new List<Map<String, String>>();
	        
		        // Set userEmailMap for users - whom we want to send 'Slack' notifications
	    		Map<Id, String> userEmailMap = UtilityController.getUserEmailMapForSlackNotification(cs, new List<Reference_Content__c>{refCont}, ConstantsController.DC_MANAGER_REVIEW);
	    		
                // REF-1893	
                if(refCont.Opportunity__r.Owner.ManagerId != null && !cs.All_Reviews_to_CRP_Team__c && (cs.DC_Manager_Review_Email__c 
						|| cs.DC_Manager_Review_Chatter__c || cs.DC_Manager_Review_Slack__c)) {
                    DCManagerReviewNotification(cs, refCont, dmMap, postFeedItems, emailstoSentList, messagesList, userEmailMap, LINK_URL, protectedAppConfig);
                } else if(cs.DC_CRP_Team_Review_Email__c || cs.DC_CRP_Team_Review_Chatter__c || cs.DC_CRP_Team_Review_Slack__c) {
                    DCCRPTeamReviewNotification(cs, refCont, dmMap, userIdSet, postFeedItems, emailstoSentList, messagesList, LINK_URL, protectedAppConfig);
                }
                
                //Send List of emails
                if(emailstoSentList.Size() > 0) {                    
                    List<Messaging.SingleEmailMessage> listmail = new List<Messaging.SingleEmailMessage>();
                    
                    for(MailChatterController.EmailMessage mem : emailstoSentList) {
                        listmail.add(MailChatterController.prepareEmail(mem.subject, mem.targetObjectId, mem.body, true));
                    }
                    
                    if(listmail.size() > 0) {
                        Messaging.sendEmail(listmail);
                    }
                }
                
                //Insert list of postFeedItems
                if (postFeedItems.size() > 0) {
                    insert postFeedItems;
                }   
                
                //Send List of slack notifications
	            if (messagesList.size() > 0) {
	                Map<String, Object> slackReqBody = new Map<String, Object>();
		            slackReqBody.put('teamId', cs.Slack_Team_Ids__c);
		            slackReqBody.put('orgId', UserInfo.getOrganizationId());
		            slackReqBody.put('messages', messagesList);
		            UtilityController.postMsgToSlack(JSON.serialize(slackReqBody));
	            }
                
            } else if(refCont.Data_Collector_Status__c != null && refCont.Data_Collector_Status__c == 'In Progress' && (refCont.Opportunity__r.Owner.ManagerId == currentLoggedUser ||      userIdSet.contains(currentLoggedUser))) {
                refCont.Data_Collector_Status__c = 'Reviewed';
            }
            
            // update reference content and Reference Content Type Field to the database. 
            WithoutSharingHelperController.upsertReferenceConTypeFields(new List<Reference_Content_Type_Field__c> { rctf });            
            WithoutSharingHelperController.upsertRefContentList(new List<Reference_Content__c> { refCont });
            
            returnResult = 'SUCCESS';
            
            // Start: Add sales rewards for User
            if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c) {
	            List<String> lstUserAction = new List<String>();
	            lstUserAction.add(ConstantsController.REFERENCE_CONTENT_TYPE);
	            List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);  
	            
	            // Null check for User reward points. 
	            if (refType.size() > 0 && refType[0].Sales_Point__c != null) { 
	                List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
	                
                    rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c, Referenceability_Type__c = refType[0].Id, Transaction__c = ConstantsController.ISSUE, 
                                                        RewardDate__c = Date.Today(), User__c = UserInfo.getUserId()));
                    UtilityController.isUserProfileExist(UserInfo.getUserId()); 
	                
	                if (rewardsToBeInsert.size() > 0) { 
	                    WithoutSharingHelperController.insertRewards(rewardsToBeInsert);
	                    // NEW field Onscreen Notification allow for on/off for onscreen notification.
	                    if (cs.User_Reward_Onscreen_Notification__c) {
	                        rewardPoints = refType[0].Sales_Point__c; 
	                        actionMessage = refType[0].Name; 
	                        returnResult += ',' + actionMessage + ',' + rewardPoints;
	                    }
	                }
            	} 
            }
            // End: Add sales rewards for User
		} catch(exception ex) {
            returnResult = ex.getMessage();
        }    
        return returnResult;    
    }
    
    private static void DCManagerReviewNotification(Custom_Settings__c cs, Reference_Content__c refCont, Map<String, Data_Mapping__c> dmMap, 
    													List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList, 
    													List<Map<String, String>> messagesList, Map<Id, String> userEmailMap, String LINK_URL, 
    													RefEdge_Configuration_Protected__c protectedAppConfig) {
    	String notificationSubject = dmMap.get(ConstantsController.DC_MANAGER_REVIEW).Field_API_Name__c != null ? dmMap.get(ConstantsController.DC_MANAGER_REVIEW).Field_API_Name__c : ConstantsController.DC_MANAGER_REVIEWSUB;      
    	String targetObjectId = refCont.Opportunity__r.Owner.ManagerId;
    	String notificationBody = (dmMap.get(ConstantsController.DC_MANAGER_REVIEW).DC_Message__c != null ? dmMap.get(ConstantsController.DC_MANAGER_REVIEW).DC_Message__c : ConstantsController.DC_MANAGER_REVIEWMSG)+ 
            							MailChatterController.prepareChatterEmailRFContentMessage(refCont.Opportunity__r.Name, refCont.Opportunity__r.StageName);

    	// for chatter Notification
        if(UtilityController.isNativeChatterSetting && cs.DC_Manager_Review_Chatter__c) {
            postFeedItems.add(MailChatterController.preparePostForRefedgeUser(notificationSubject, targetObjectId, notificationBody, 
            						LINK_URL+refCont.Id, protectedAppConfig.User_Id__c));
        }
        
        // for email Notification
        if(cs.DC_Manager_Review_Email__c) {
        	MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(notificationSubject, targetObjectId, notificationBody, 
	        												'Link : ' + '<a href="' + LINK_URL +refCont.Id+ '">' + LINK_URL +refCont.Id + '</a>'); 
	        emailstoSentList.add(email);		
        }
        
        // for slack Notification
        if (cs.DC_Manager_Review_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
            Map<String, String> tempReqBodyMap = new Map<String, String>();
            tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL + refCont.Id + '|' + notificationSubject + '>');
            tempReqBodyMap.put('userEmail', userEmailMap.get(targetObjectId));
            messagesList.add(tempReqBodyMap);
        }
    }
    
    private static void DCCRPTeamReviewNotification(Custom_Settings__c cs, Reference_Content__c refCont, Map<String, Data_Mapping__c> dmMap, Set<id> userIdSet, 
    													List<sObject> postFeedItems, List<MailChatterController.EmailMessage> emailstoSentList, 
    													List<Map<String, String>> messagesList, String LINK_URL, 
    													RefEdge_Configuration_Protected__c protectedAppConfig) {
		// Create reference Note in absence of Opportunity owner manager
        List<Reference_Note__c> refNote = new List<Reference_Note__c>();
        
        for(Reference_Note__c rfn : [SELECT Id, Note__c FROM Reference_Note__c WHERE Reference_Content__c =: refCont.Id]) {
            
            if(rfn.Note__c.contains(label.No_Manager_Message)) {
                refNote.add(rfn);
            }
        }
        
        if(refNote.size() == 0) {
            Reference_Note__c refRec = new Reference_Note__c();
            refRec.Note__c = label.No_Manager_Message;
            refRec.Reference_Content__c = refCont.Id;
            WithoutSharingHelperController.insertReferenceNotes(new List<Reference_Note__c> { refRec });
        }
        
        if(userIdSet.size() > 0) {
        	String notificationSubject = dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).Field_API_Name__c != null ? dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).Field_API_Name__c : ConstantsController.DC_CRP_TEAM_REVIEWSUB;      
	        String notificationBody = (dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).DC_Message__c != null ? dmMap.get(ConstantsController.DC_CRP_TEAM_REVIEW).DC_Message__c : ConstantsController.DC_CRP_TEAM_REVIEWMSG)+ 
                    						MailChatterController.prepareChatterEmailRFContentMessage(refCont.Opportunity__r.Name, refCont.Opportunity__r.StageName);
	        
            for(Id userId : userIdSet) {
                // for chatter Notification
                if(UtilityController.isNativeChatterSetting && cs.DC_CRP_Team_Review_Chatter__c) {
                    postFeedItems.add(MailChatterController.preparePostForRefedgeUser(notificationSubject, userId, notificationBody, 
                    						LINK_URL+refCont.Id, protectedAppConfig.User_Id__c));
                }
                
                // for email Notification
                if(cs.DC_CRP_Team_Review_Email__c) {
                	MailChatterController.EmailMessage email = MailChatterController.prepareEmailMessage(notificationSubject, userId, notificationBody,
	                												'Link : ' + '<a href="' + LINK_URL +refCont.Id+ '">' + LINK_URL +refCont.Id + '</a>'  ); 
	                emailstoSentList.add(email);
                }
            }
            
            // for slack Notification
            if (cs.DC_CRP_Team_Review_Slack__c && cs.Enable_Slack_Integration__c && cs.Nomination_Slack__c) {
	            Map<String, String> tempReqBodyMap = new Map<String, String>();
                tempReqBodyMap.put('text', notificationBody + '\n<' + LINK_URL + refCont.Id + '|' + notificationSubject + '>');
	            messagesList.add(tempReqBodyMap);
	        }
        }  
  	}
}