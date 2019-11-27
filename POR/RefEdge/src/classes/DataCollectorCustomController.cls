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
    * Page: DataCollectorCustomPage
    * Description : Class used to provide functionality to create DataCollectorForm.
    * Created by: Rajneesh Raj @May 07 2018
*/

public with sharing class DataCollectorCustomController {
    
    /**
        * Properties and variables
    */ 
    public String customSettingId { get; set; }
    public Boolean isSLDS { get; set; }
    public String formName { get; set; }
    public String formHeader { get; set; }
    public String subHeader { get; set; }
    public String formDeatil { get; set; }    
    public String fieldInfo { get; set; }
    public List<WrapperClass> wrapList { get; set; }
    public String requiredFields { get; set; }
    public String requiredFieldName { get; set; }
    public String dmRecordList { get; set; }
    
    //  Constructor
    public DataCollectorCustomController() {
        
        formName = '';
        formHeader = '';
        subHeader = '';
        formDeatil = '';
        dmRecordList = '';
        
        //    Check theme(Lightning or classic)
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
            } else { 
            isSLDS = false;
        }
        
        wrapList = new List<WrapperClass>();
        requiredFields  = '';
        requiredFieldName = '';
        Map<String, String> RTMMap = new Map<String, String>();
        customSettingId = ApexPages.currentPage().getParameters().get('customSettingId') != null
        ? ApexPages.currentPage().getParameters().get('customSettingId') : '';
        List<String> reqFields = new List<String>();
        
        /*
            *    Edit Functionality...
        */    
        Set<String> fieldinUseSet = new Set<String>();
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
        
        String dmRecordId = ApexPages.currentPage().getParameters().get('customFormId') != null
        ? ApexPages.currentPage().getParameters().get('customFormId').substringBefore('?') : '';
        Map<String, List<SectionItenWrapper>> sectionItemMap = new Map<String, List<SectionItenWrapper>>();
                List<SectionWrapper> sectionInfoList = new List<SectionWrapper>();
                
        //  Check whether dmRecordId is blank (if not then its edit part)
        if(dmRecordId != '') {
            List<Data_Mapping__c> dataMapList = new List<Data_Mapping__c>();
            dataMapList = [SELECT Field_API_Name__c, Label__c, Section_Name__c, Data_Collector_Name__c, Order__c, Section_Position__c, DC_Message__c FROM Data_Mapping__c WHERE Data_Collector_Name__c =: [SELECT id, Data_Collector_Name__c FROM Data_Mapping__c WHERE id =: String.escapeSingleQuotes(dmRecordId)].Data_Collector_Name__c ORDER BY Section_Position__c, order__c];            
            
            if(dataMapList.size() > 0) {
                
                for(Data_Mapping__c dmRecord : dataMapList) { 
                    
                    if(dmRecord.Section_Name__c == ConstantsController.DC_FORM_IDENTIFY) {
                        formName = dmRecord.Data_Collector_Name__c;
                        formHeader = dmRecord.Label__c;
                        subHeader = dmRecord.Field_API_Name__c;
                    } else if(dmRecord.Order__c != null && dmRecord.Section_Position__c != null) {
                        
                        if(!sectionItemMap .containsKey(String.valueOf(dmRecord.Section_Position__c))) {                                                        
                            sectionItemMap.put(String.valueOf(dmRecord.Section_Position__c), new List<SectionItenWrapper>());                                                                                 
                        }

                        //  Check whether field is deleted or not "From the object"
                        if(RCTFIeldsSet.containskey(dmRecord.Field_API_Name__c.toLowerCase())) {
                            sectionItemMap.get(String.valueOf(dmRecord.Section_Position__c)).add(new SectionItenWrapper(RCTFIeldsSet.get(dmRecord.Field_API_Name__c.toLowerCase()), dmRecord.Field_API_Name__c, dmRecord.Section_Name__c, Integer.valueOf(dmRecord.Order__c)));
                        }   

                        fieldinUseSet.add(dmRecord.Field_API_Name__c);
                        
                    } else if(dmRecord.Order__c == null && dmRecord.Section_Position__c != null) {
                        
                        sectionInfoList.add(new SectionWrapper(dmRecord.Field_API_Name__c, Integer.valueOf(dmRecord.Section_Position__c), new List<SectionItenWrapper>()));
                    }
                }
                
                if(sectionInfoList.size() > 0) {
                    
                    for(SectionWrapper swrap : sectionInfoList) {
                        
                        if(sectionItemMap.containsKey(String.valueOf(swrap.id))) {
                            swrap.field = sectionItemMap.get(String.valueOf(swrap.id));
                        }
                    }
                }
            }
            dmRecordList = JSON.serialize(dataMapList);
            formDeatil = JSON.serialize(sectionInfoList);            
        }
        
        //        END OF EDIT SECTION  
        //              All required field need to get auto populated in first section
                
        for(Reference_Type_Mapping__c rtm : [SELECT Name, Required__c FROM Reference_Type_Mapping__c WHERE Reference_Content_Type__r.Name__c =: ConstantsController.REFERENCE_CONTENT_TYPE]) {
            
            if(fieldinUseSet.size() > 0 ) {
                
                if(!fieldinUseSet.contains(rtm.Name)) {
                    RTMMap.put(rtm.Name, rtm.Name);
                }
            } else {
                RTMMap.put(rtm.Name, rtm.Name);
            }
            
            // to check required field
            if(rtm.Required__c) {
                reqFields.add(rtm.Name);
            }
        }        
        requiredFields = JSON.serialize(reqFields);
        
        if(RTMMap.size() > 0) {
            
            Map<String, Schema.SObjectField> m = Schema.SObjectType.Reference_Content_Type_Field__c.fields.getMap(); 
            Integer fldPosition = 0;

            if(!(fieldinUseSet.size() > 0)) {
                sectionItemMap.put('0', new List<SectionItenWrapper>()); 
            }

            for(Schema.SObjectField f : m.values()) { 
                Schema.DescribeFieldResult d = f.getDescribe();
                
                if(RTMMap.containsKey(d.getName()) && requiredFields.contains(d.getName()) && !(fieldinUseSet.size() > 0)) { 
                                    //    sectionItemMap.get('0').add(new SectionItenWrapper(d.getLabel(), d.getName(), String.valueOf(d.getType()), fldPosition));
                                    //    fldPosition ++;
                                    wrapList.add(new WrapperClass(d.getLabel(), d.getName(), String.valueOf(d.getType())));
                } else if(RTMMap.containsKey(d.getName())) {
                                        wrapList.add(new WrapperClass(d.getLabel(), d.getName(), String.valueOf(d.getType()))); 
                                }
                
                if(requiredFields.contains(d.getName())) {
                    requiredFieldName += d.getLabel()+ ', ';
                }
            }
                        
            if(!(fieldinUseSet.size() > 0) && (sectionItemMap.size() > 0)) {
                    sectionInfoList.add(new SectionWrapper('', 0, new List<SectionItenWrapper>()));
                    sectionInfoList[0].field = sectionItemMap.get('0');
                    formDeatil = JSON.serialize(sectionInfoList);
            }
                        
            requiredFieldName = requiredFieldName.removeEnd(', ');            
        }            
        fieldInfo = JSON.serialize(wrapList);        
    }
    
    //  wrapper class to hold field label, type and api name of Reference_Content__c object
    public class WrapperClass {
        public String fLabel { get; set; }
        public String fAPIName { get; set; }
        public String fType { get; set; }
        
        public WrapperClass(String label, String Name, String fieldType) {
            fLabel = label;
            fAPIName = Name;
            fType = fieldType;
        }
    }
    
    //  method to save Form information to Data_Mapping__c object.
    @remoteAction
    public static string saveResult(String sectionInfo, String fname, String fheader, String fsubHeader, String dmRecordList) {
        
        String returnResult = '';
        Set<String> uniqueNameSet = new Set<String>();
        List<Data_Mapping__c> dmlistToDelete = new List<Data_Mapping__c>();
        List<Data_Mapping__c> dataMappingList = new List<Data_Mapping__c>();
        Savepoint sp = Database.setSavepoint();
                
        try {
            //  Deserialization
            if(dmRecordList != '')
            dmlistToDelete =  (List<Data_Mapping__c>)JSON.deserialize(dmRecordList, List<Data_Mapping__c>.class);        

            //  Check whether dmRecordId is blank (if not then its edit part)
            if(dmlistToDelete.size() > 0) {

                //  REF-2037
                for(Data_Mapping__c dmRecord : dmlistToDelete) {
                    
                   if(dmRecord.DC_Message__c != '' && dmRecord.DC_Message__c != null) {
                       dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Section_Name__c = dmRecord.Section_Name__c, Field_API_Name__c = dmRecord.Field_API_Name__c, DC_Message__c = dmRecord.DC_Message__c, Label__c = dmRecord.Label__c));
                   }
                }

                For(Data_Mapping__c dmRec : [SELECT Data_Collector_Name__c FROM Data_Mapping__c WHERE Data_Collector_Name__c !='' AND Section_Name__c =: ConstantsController.DC_FORM_IDENTIFY AND  Data_Collector_Name__c !=: [SELECT id, Data_Collector_Name__c FROM Data_Mapping__c WHERE id =: dmlistToDelete[0].Id].Data_Collector_Name__c]) {
                    uniqueNameSet.add(dmRec.Data_Collector_Name__c.toUpperCase());                    
                }
            } else {
                For(Data_Mapping__c dmRec : [SELECT Data_Collector_Name__c FROM Data_Mapping__c WHERE Data_Collector_Name__c !='' AND Section_Name__c =: ConstantsController.DC_FORM_IDENTIFY]) {
                    uniqueNameSet.add(dmRec.Data_Collector_Name__c.toUpperCase());
                }
            }
            
            if(uniqueNameSet.contains(fname.toUpperCase())) {
                returnResult = Label.Duplicate_Record + ' : '+fname;
            } else { 

                // check whether Name, Header,Subheader is blank
                if(fname != '' && fheader != '' && fsubHeader != '') {
                    dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Label__c = fheader, Field_API_Name__c = fsubHeader, Section_Name__c = ConstantsController.DC_FORM_IDENTIFY));
                   
                    if(dmlistToDelete.size() == 0) {
                        dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Section_Name__c = ConstantsController.DC_INITIAL_NOTIFICATION, Field_API_Name__c = ConstantsController.DC_INITIAL_NOTIFICATIONSUB, DC_Message__c = ConstantsController.DC_INITIAL_NOTIFICATIONMSG, Label__c = '1'));
                        dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Section_Name__c = ConstantsController.DC_REMINDER, Field_API_Name__c = ConstantsController.DC_REMINDERSUB, DC_Message__c = ConstantsController.DC_REMINDERMSG, Label__c = '2'));
                        dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Section_Name__c = ConstantsController.DC_OWNER_ESCALATION, Field_API_Name__c = ConstantsController.DC_OWNER_ESCALATIONSUB, DC_Message__c = ConstantsController.DC_OWNER_ESCALATIONMSG, Label__c = '3'));
                        dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Section_Name__c = ConstantsController.DC_MANAGER_ESCALATION, Field_API_Name__c = ConstantsController.DC_MANAGER_ESCALATIONSUB, DC_Message__c = ConstantsController.DC_MANAGER_ESCALATIONMSG, Label__c = '4'));  
                        dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Section_Name__c = ConstantsController.DC_MANAGER_REVIEW, Field_API_Name__c = ConstantsController.DC_MANAGER_REVIEWSUB, DC_Message__c = ConstantsController.DC_MANAGER_REVIEWMSG, Label__c = '5')); 
                        dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Section_Name__c = ConstantsController.DC_CRP_TEAM_REVIEW, Field_API_Name__c = ConstantsController.DC_CRP_TEAM_REVIEWSUB, DC_Message__c = ConstantsController.DC_CRP_TEAM_REVIEWMSG, Label__c = '6'));           
                    }
                }
                List<SectionWrapper> secList = new List<SectionWrapper>();
                //  Deserialization
                secList = (List<SectionWrapper>)JSON.deserialize(sectionInfo, List<SectionWrapper>.class);
                
                //  Iteration from list(Section and Fields in that section)
                if(secList.Size() > 0) {
                    
                    for(SectionWrapper sr : secList){
                        dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Field_API_Name__c = sr.Name, Section_Position__c = sr.id));
                        
                        // iteration to get fields associated each section
                        for(SectionItenWrapper si : sr.field) {
                            dataMappingList.add(new Data_Mapping__c(Data_Collector_Name__c = fname, Field_API_Name__c = si.fieldAPIName, Label__c = si.fieldName, Section_Name__c = si.fieldType, Section_Position__c = sr.id, Order__c = si.fieldPosition));
                        }
                    }
                }
           
                //  Insert list in Data Mapping object
                if(dataMappingList.Size() > 0) {
                    ConstantsController.shouldDataMappingProcessed = true;

                    if(dmlistToDelete.size() > 0 && CRUDAndFLSCheckController.isDeletable(new List<String> { UtilityController.appNamespace() + 'Data_Mapping__c'})) 
                        delete  dmlistToDelete;
                        insert dataMappingList;
                        returnResult = 'SUCCESS';
                }           
            }            
        } catch(exception ex) {
            returnResult = ex.getMessage() +' : '+ex.getLineNumber();
            Database.rollback(sp);
        }
        return returnResult;
    }
    
    /**
        * RemoteAction to get insufficient permmission message
    */
    @RemoteAction
    public static String getPermissionsMessage() {
        checkPermissions();     
        return CRUDAndFLSCheckController.getErrorMsg();
    }
    
    
    /**
        * Method to check Permissions
    */
    private static Boolean checkPermissions() {
        Map<String, Set<String>> fieldMap = new Map<String, Set<String>>();
        fieldMap.put(UtilityController.appNamespace() + 'Data_Mapping__c', new Set<String> { 
            UtilityController.appNamespace() + 'Field_API_Name__c',
            UtilityController.appNamespace() + 'Label__c',
            UtilityController.appNamespace() + 'Section_Name__c',
            UtilityController.appNamespace() + 'Data_Collector_Name__c',
            UtilityController.appNamespace() + 'Order__c',
        UtilityController.appNamespace() + 'Section_Position__c'});
        return CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true);
    }
    
    private class SectionWrapper {
        private String Name { get; set; }
        private Integer id { get; set; }  
        private List<SectionItenWrapper> field { get; set; }
        
        private SectionWrapper(String secNam, Integer secOrder, List<SectionItenWrapper> secWrap){
            Name = secNam;
            id = secOrder;
            field = secWrap;
        }
    }
    
    private class SectionItenWrapper {
        private String fieldName { get; set; }  
        private String fieldAPIName { get; set; }      
        private String fieldType { get; set; }
        private Integer fieldPosition { get; set; }
        
        private SectionItenWrapper(String ffName, String ffAPIN, String ffType, Integer ffpos) {
            fieldName = ffName;
            fieldAPIName = ffAPIN;
            fieldType = ffType;
            fieldPosition = ffpos;
        }
    }
}