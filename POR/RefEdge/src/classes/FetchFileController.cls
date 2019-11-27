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
 * VF Page: FetchFile
 * Description: RefEdgeDM controller
 * Last Modified By: Rajesh @Feb 8 2018 REF-1333
 */
   
public with sharing class FetchFileController extends RefEdgeEditionFeatures {
    /**
     * Properties and variables
     */
    public Boolean insertDone { get; set; }
    public Boolean isDataLoaderEnabled { get; set; }
    public Boolean processComplete { get; set; }
    public static String objectLabel = 'Reference Content';
    public List<List<String>> errorRecords ;
    public Map<String,String> fieldToObject ;
    public String errorString { get; set; }
    public Map<String,Map<String,String>> refIdList { get; set; }
    public List<FileContentWrapper> refToContent { get; set; }
    public String idListString { get; set;}
    public String namespace { get {
        return UtilityController.appNamespace();
    } set; }
    public String totalRecordCountString { get; set; }
    public Integer totalRecordCount { get; set; }
    public String objectName { get; set; }
    public static Map<Id, Reference_Content__c> refContentMap { get; set; }
    public Boolean isSLDS { get; set; }

    /**
     * WrapperClass for nativeContent details
     */
    public class FileContentWrapper {
        public Reference_Content__c refContent { get; set; }        
        public transient Blob contentData { get; set; }
        public String fileName { get; set; }
        public ContentVersion content;
        public String refName { get; set; }   
        public Boolean isNew { get; set; }       
        
        //WrapperClassConstructor
        public FileContentWrapper(String refId , String isNewString) {
            refContent = FetchFileController.refContentMap.get(refId);            
            refName = refContent.Title__c;     
            isNew = isNewString == 'true';  
        }        
    }
    
    /** 
     * WrapperClass for ReferenceContent fields details
     */
    public class FieldDetailsWrapper {
        public String name, apiName, dataType, objectName;
        public Boolean isRequired, isMapped,onlyShow;
        public List<String> mappedTo;        
        public ConstantsController.FieldDescription lstField;

       //constructor FieldDetailsWrapper
        public FieldDetailsWrapper(String name, String apiName, Boolean isRequired, String dataType, String objectName) {            
            this.name = name;
            this.apiName = apiName;
            this.isRequired = isRequired;           
            this.isMapped = false;
            this.dataType = dataType;
            this.objectName = objectName; 
            mappedTo = new List<String>(); 
            this.onlyShow = false;   
            if (ConstantsController.mapFieldsDetailsForDMObjects.containsKey(objectName)) {           
                lstField = (ConstantsController.FieldDescription) ConstantsController.mapFieldsDetailsForDMObjects.get(objectName).get(apiName);  
            }
        }        
    } 
    
    /**
     * WrapperClass for Requested reference fields details
     */
    public class ReferenceTypeFieldsWrapper {
        public String id;
        public String name;
        
        //constructor ReferenceTypeFieldsWrapper
        public ReferenceTypeFieldsWrapper(String id, String name) {            
            this.name = name;
            this.id = id; 
        }        
    }
    
     /**
     * WrapperClass for FieldDescription fields details
     */
    public class FieldDescription {
        public String fieldType, example, section, description;  
        
        //constructor FieldDescription
        public FieldDescription(String fieldType, String example, String section, String description) {            
            this.fieldType = fieldType;
            this.example = example;
            this.section = section;           
            this.description = description; 
        }        
    }

    /**
     * Method to get Date Format
     */
    @RemoteAction
    public static String getDateFormat() {   
        String dateFormat = ConstantsController.localeDateFormatMap.get(UserInfo.getLocale()).split(' ').get(0);
        return dateFormat; 
    }
    
    /**
     * Constructor
     */
    public FetchFileController() {
         
        if (UserInfo.getUiTheme() == 'Theme4d' || UserInfo.getUiTheme() == 'Theme4t') { 
            isSLDS = true;
        } else { 
            isSLDS = false;
        }
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        isDataLoaderEnabled = cs.Enable_Custom_Data_Loader__c;
        insertDone = false;     
        processComplete = false;
        errorString = '';
        idListString = '';
        fieldToObject = new Map<String,String>();
        errorRecords = new List<List<String>>();
    }   
    
    /**
​ ​ ​ ​ ​*​ ​  ​@description​ ​:​ Method to initialize totalRecordCount
​ ​ ​ ​ ​*​ ​ ​ @return :​ Redirect to Start Point
    *   @Modified By: Dixita @Jan 2018
​ ​ ​ ​ ​**/
    public void setTotalCount() {
         totalRecordCount = (totalRecordCountString != null && totalRecordCountString.trim() != '' ) ? Integer.valueOf(totalRecordCountString): 0 ;
    }
     
    /**
​ ​ ​ ​ ​*​ ​  ​@description​ ​:​ Method to Get Fields List
​ ​ ​ ​ ​*​ ​ ​ @return :​ Set of Fields
    *   @Modified By: Dixita Jan/2018
​ ​ ​ ​ ​**/
    public static Set<String> getImportFields() {
        Set<String> fields = new Set<String>();
        String namespace = UtilityController.appNamespace();
        fields.add('Id');
        fields.add(namespace + 'Account__c');
        fields.add(namespace + 'Attribute_Ids__c');
        fields.add(namespace + 'Contact__c');
        fields.add(namespace + 'Generic_Account__c');
        fields.add(namespace + 'Account_Level_RUL__c');
        fields.add(namespace + 'Inactive_Reason__c');
        fields.add(namespace + 'Managed_Reference_Account__c');
        fields.add(namespace + 'ReferenceabilityType_Ids1__c');
        fields.add(namespace + 'ReferenceabilityType_Ids2__c');
        fields.add(namespace + 'Profile_Update_Owner__c');
        fields.add(namespace + 'Reference_Owner__c');
        fields.add(namespace + 'Reference_Program_Candidate__c');
        fields.add(namespace + 'Is_Referenceable__c');
        fields.add(namespace + 'Referenceability_Status__c');
        fields.add(namespace + 'Ref_Profile_Summary__c');
        fields.add(namespace + 'RUL_Period__c');
        fields.add(namespace + 'RUL_Activities_will_do__c');
        fields.add(namespace + 'Roll_up_Attributes_to_All_Accounts__c');
        fields.add(namespace + 'Roll_up_Attributes_to_Primary_Account__c');
        fields.add(namespace + 'Roll_up_Referenceability_to_All_Accounts__c');
        fields.add(namespace + 'Roll_up_Referenceability_to_Primary_Acc__c');
        fields.add(namespace + 'Inherit_Attributes_from_All_Accounts__c');
        fields.add(namespace + 'Inherit_Attributes_from_Primary_Account__c');
        fields.add(namespace + 'Referenceability__c');
        return fields;
    }
    /**
​ ​ ​ ​ ​*​ ​   ​@description​ ​:​ Method to initialize ErrorRecords from ReferenceContent insert & Id for Content Upload
​ ​ ​ ​ ​*​ ​ ​ @return :​ Redirect to Start Point
    *   @Modified By: Dixita Jan/2018
​ ​ ​ ​ ​**/ 
    public PageReference initializeRefIdList() {        
        errorRecords = (List<List<String>>)JSON.deserialize(errorString, List<List<String>>.class); 
        insertDone = true;
        refToContent = (refToContent == null ? new  List<FileContentWrapper>() : refToContent);   
        objectLabel = (objectName.contains('Reference_Basic_Information')) ? 'Reference Profile' : objectName.contains('Reference_Content') ? 'Reference Content' : 'Historical Request'; 
        
        if (idListString != null && idListString != '' && idListString.trim() != '' && idListString.trim() != '{}' && objectName.contains('Reference_Content')) {
            refIdList = (Map<String,Map<String,String>>)JSON.deserialize(idListString, Map<String,Map<String,String>>.class);
            String namespace = UtilityController.appNamespace();
            List<String> neededFields = new List<String> {namespace + 'Reference_Content_Type__c', namespace + 'Content_Status__c', namespace + 'Content_ID__c', namespace + 'Content_Type__c', namespace + 'Is_File_Changed__c', namespace + 'Title__c', namespace + 'Language__c', namespace + 'Summary__c', namespace + 'Search_Terms_keywords__c', namespace + 'Library_ID__c'};                 
            String query = 'SELECT ' + String.join(neededFields, ',') + ',';
            List<Data_Mapping__c> fieldDataMapping = [SELECT Name, Id, Object__c, Order__c,Section_Name__c,Data_Collector_Name__c, Required__c, Label__c, Visible__c, Field_API_Name__c FROM Data_Mapping__c WHERE (Object__c = :ConstantsController.DM_REFERENCE_CONTENT OR Object__c = :ConstantsController.DMContentVersion)  AND Visible__c = true ORDER BY Order__c ASC NULLS LAST];

            for (Data_Mapping__c field : fieldDataMapping) {
                
                if (field.Object__c == ConstantsController.DM_REFERENCE_CONTENT && !query.contains(field.Field_API_Name__c)) {
                    query += field.Field_API_Name__c + ',';   
                }
                fieldToObject.put(field.Field_API_Name__c,field.Object__c);
            }
            query = query.removeEndIgnoreCase(',');
            Set<String> idSet = refIdList.keySet();
            query += ' FROM Reference_Content__c WHERE Id =:idSet';             
            refContentMap = new Map<Id, Reference_Content__c>( (List<Reference_Content__c> )Database.query(query));             
                
            for (String refId : refIdList.keySet()) {
                
                if (refId != null && refId != '') {
                    FileContentWrapper tempWrapper = new FileContentWrapper(refId,refIdList.get(refId).get('isNew'));
                    //#REF-1592 : Assign Previously created CV 
                    tempWrapper.content = (ContentVersion)JSON.deserialize(refIdList.get(refId).get('data'), ContentVersion.class);
                    refToContent.add(tempWrapper);    
                }   
            }
            return null;            
        } else {
            processComplete = true;
            return (sendErrorEmail());          
        }
    }
    
   /**
​ ​ ​ ​ ​*​ ​   ​@description​ ​:​ Method to upsert ContentVersion
​ ​ ​ ​ ​*​ ​ ​ @return :​ Redirect to Start Point
    *   @Modified By: Dixita @Jan 2018
​ ​ ​ ​ ​**/ 
    public PageReference insertContent() {
        
        try {
            transient List<ContentVersion> contentUpsertMap = new List<ContentVersion>();
            List<Reference_Content__c> refContentUpdateList = new List<Reference_Content__c>();
            List<Reference_Content__c> refContentDeleteList = new List<Reference_Content__c>();
            List<String> contentIds =  new List<String>();
            
            for (FileContentWrapper temp : refToContent) {
                
                if (temp.refContent.Content_ID__c != null) {
                    contentIds.add(temp.refContent.Content_ID__c);
                }
            }
            Map<Id,ContentVersion> initialContent = new Map<Id,ContentVersion>([SELECT Id, TagCsv, FirstPublishLocationId, Title, Description, Language, ContentDocumentId FROM ContentVersion WHERE Id IN :contentIds]) ;
            
            for (FileContentWrapper temp : refToContent) {
                
                //New Content Version create
                if (temp.refContent.Content_ID__c == null && temp.contentData != null) {
                    temp.content = temp.content == null ? new ContentVersion() : temp.content;                    
                    temp.content.VersionData = temp.contentData;                    
                    temp.content.PathOnClient = temp.fileName;                 
                    temp.content.Reference_Content_Type__c = temp.refContent.Reference_Content_Type__c;
                    temp.content.TagCsv = ((temp.refContent.Search_Terms_keywords__c != null && temp.refContent.Search_Terms_keywords__c != '') ? temp.refContent.Search_Terms_keywords__c.trim() : '');
                    temp.content.Description = (temp.refContent.Summary__c != null && temp.refContent.Summary__c != '')
                                        ? temp.refContent.Summary__c.substring(0, Math.min(temp.refContent.Summary__c.length(), 1000)) : '';
                    temp.content.Title = temp.refContent.Title__c;  
                    temp.content.FirstPublishLocationId = temp.refContent.Library_ID__c;
                    temp.content.Content_Status__c = temp.refContent.Content_Status__c;  
                    
                    for (String langKey : UtilityController.mapContentLanguage.keySet()) {
                        
                        if (UtilityController.mapContentLanguage.get(langKey) == temp.refContent.Language__c) {
                            temp.content.Language = langKey;
                        }
                    }
                    contentUpsertMap.add(temp.content);
                    refContentUpdateList.add(temp.refContent);                      
                } else if (temp.refContent.Content_ID__c == null && temp.contentData == null && temp.isNew) {    //In case no file was uploaded                  
                    List<String> errorInstance = new List<String>(); 
                    errorInstance.add('No Content associated');         
                        
                    for (Integer index = 1 ; index < errorRecords[0].size() ; index++) {
                        
                        String errorString = errorRecords[0].get(index);
                        if (fieldToObject.get(errorString) != null && fieldToObject.get(errorString) == ConstantsController.DM_REFERENCE_CONTENT) {
                            errorInstance.add((temp.refContent.get(errorString.replace(UtilityController.appNamespace(), '')) != null) ? String.valueOf(temp.refContent.get(errorString.replace('refedge__', ''))) : '');
                        } else if (fieldToObject.get(errorString) != null && fieldToObject.get(errorString) == ConstantsController.DMContentVersion) {
                            errorInstance.add((temp.content.get(errorString.replace(UtilityController.appNamespace(), '')) != null) ? String.valueOf(temp.content.get(errorString.replace('refedge__', ''))) : '');
                        }
                    }
                    errorRecords.add(errorInstance);                        
                    refContentDeleteList.add(temp.refContent);                                
                } else if (temp.contentData !=  null) { //Content Version Update                      
                    
                    if (!initialContent.containsKey(temp.refContent.Content_ID__c)) {
                        List<String> errorInstance = new List<String>(); 
                        errorInstance.add('Invalid Content Id');           
                            
                        for (Integer index = 1 ; index < errorRecords[0].size() ; index++) {
                            String errorString = errorRecords[0].get(index);
                            errorInstance.add((temp.refContent.get(errorString.replace(UtilityController.appNamespace(), '')) != null) ? String.valueOf(temp.refContent.get(errorString.replace('refedge__', ''))) : '');
                        }
                        errorRecords.add(errorInstance);   
                    } else {                    
                        temp.content = temp.content == null ? new ContentVersion() : temp.content;    
                        temp.content.VersionData = temp.contentData;
                        temp.content.TagCsv = initialContent.get(temp.refContent.Content_ID__c).TagCsv;
                        temp.content.Description = initialContent.get(temp.refContent.Content_ID__c).Description;
                        temp.content.Title = temp.refContent.Title__c;
                        temp.content.Language = initialContent.get(temp.refContent.Content_ID__c).Language;
                        temp.content.Reference_Content_Type__c = temp.refContent.Reference_Content_Type__c;
                        temp.content.Content_Status__c = temp.refContent.Content_Status__c;  
                        contentUpsertMap.add(temp.content);
                        refContentUpdateList.add(temp.refContent);
                    }                       
                }               
            }
            ConstantsController.isRequestFromDM = true;
            Database.UpsertResult[] contentResultList = Database.upsert(contentUpsertMap, false);
            
            for (Integer index = 0 ; index < contentResultList.size() ; index++) {
                
                if (contentResultList[index].isSuccess()) {
                    refContentUpdateList[index].Content_Id__c = contentResultList[index].getId();
                    refContentUpdateList[index].Is_File_Changed__c = true;
                } else if (refContentUpdateList[index].Content_Id__c == null || refContentUpdateList[index].Content_Id__c == '') {
                    refContentDeleteList.add(refContentUpdateList[index]);
                    List<String> errorInstance = new List<String>(); 
                    errorInstance.add(contentResultList[index].getErrors()[0].getMessage());        
                        
                    for (Integer indexError = 1 ; indexError < errorRecords[0].size() ; indexError++) {
                        String errorString = errorRecords[0].get(indexError);
                        //#REF-1592 : Error File to Include CV fields
                        if (fieldToObject.get(errorString) == ConstantsController.DM_REFERENCE_CONTENT) {
                            errorInstance.add((refContentUpdateList[index].get(errorString.replace(UtilityController.appNamespace(), '')) != null) ? String.valueOf(refContentUpdateList[index].get(errorString.replace('refedge__', ''))) : '');
                        } else {
                            errorInstance.add((contentUpsertMap[index].get(errorString.replace(UtilityController.appNamespace(), '')) != null) ? String.valueOf(contentUpsertMap[index].get(errorString.replace('refedge__', ''))) : '');
                        }
                    }
                    errorRecords.add(errorInstance);  
                }
            }
            Database.DeleteResult[] deleteResult = Database.delete(refContentDeleteList,false);
            Database.SaveResult[] refContentResultList = Database.update(refContentUpdateList, false);
            processComplete = true;
            return(sendErrorEmail());           
        } catch(Exception e) {
            return null;
        }
    }
    
   /**
​ ​ ​ ​ ​*​ ​  ​@description​ ​:​ Method to Send Email about Import Status 
​ ​ ​ ​ ​*​ ​ ​ @return :​ Redirect to Start Point
    *   @Modified By: Dixita @Jan 2018
​ ​ ​ ​ ​**/
    public PageReference sendErrorEmail() {
        String redirectURL = '';
        try {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setSubject(objectLabel + ' Import Completed');
            email.setToAddresses(new List<String>{UserInfo.getUserEmail()});

            if (errorRecords.size() > 1) {
                transient String generatedCSV = '';
            
                for (List<String> entry : errorRecords) {
                    
                    for (String dataItem : entry) {
                        generatedCSV += '"' + dataItem + '",';
                    }
                    generatedCSV = generatedCSV.removeEnd(',') + '\n';
                } 
                transient Messaging.EmailFileAttachment csvAttchment = new Messaging.EmailFileAttachment();
                transient Blob csvBlob = Blob.valueOf(generatedCSV);        
                csvAttchment.setFileName('Import Error Report.csv');
                csvAttchment.setContentType('text/csv');
                csvAttchment.setBody(CSVBlob);
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {csvAttchment});   
            }
            email.setPlainTextBody('The ' + objectLabel + ' import has completed.\n\nTotal records processed: ' + totalRecordCount + '\n\nRecords successfully imported: ' + (totalRecordCount - (errorRecords.size() - 1 )) + '\n\nFailed Records : ' + (errorRecords.size() - 1 ));
            
            if (totalRecordCount > 0) {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});   
            }
        } catch (Exception ex) {
            List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
                
            for(DescribeTabSetResult tsr : tabSetDesc) {
                List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
                    
                for(Schema.DescribeTabResult tr : tabDesc) {
                    
                    if(tr.isCustom() && tr.getLabel() == 'RefEdgeDM') {
                        redirectURL = tr.getUrl();
                    }
                }
                
            }
            PageReference retURL = new PageReference(redirectURL);
            retURL.setRedirect(true);
            return retURL;  
        } 
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.describeTabs();
                
        for(DescribeTabSetResult tsr : tabSetDesc) {
            List<Schema.DescribeTabResult> tabDesc = tsr.getTabs();
                
            for(Schema.DescribeTabResult tr : tabDesc) {
                
                if(tr.isCustom() && tr.getLabel() == 'RefEdgeDM') {
                    redirectURL = tr.getUrl();
                }
            }
            
        }
        PageReference retURL = new PageReference(redirectURL);
        retURL.setRedirect(true);
        return retURL;     
    }
    
   /**
​ ​ ​ ​ ​*​ ​   ​@description​ ​:​ Method to Send Email about Import Status
​ ​ ​ ​ ​*​ ​   @args​  :​ ​​String fieldType  field type,value : Field value
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning Object.
    *   @Modified By: Dixita @Jan 2018
​ ​ ​ ​ ​**/
    public static Object getInType(String fieldType, String value) {  
        
        try {
                       
            if (value ==  null || value.trim() == '') {
                return null;
            }    
            value = value.remove('"').removeEnd(',').trim();
            
            if (fieldType.equalsIgnoreCase('String') || 
                fieldType.equalsIgnoreCase('TextArea') ||
                fieldType.equalsIgnoreCase('Id') ||
                fieldType.equalsIgnoreCase('Picklist') ||
                fieldType.equalsIgnoreCase('Reference') ||
                fieldType.equalsIgnoreCase('Phone') ||
                fieldType.equalsIgnoreCase('Email') ||
                fieldType.equalsIgnoreCase('URL') ||
                fieldType.equalsIgnoreCase('MultiPicklist')) {
                return value;
            } else if (fieldType.equalsIgnoreCase('Currency') ||
                fieldType.equalsIgnoreCase('Double')) {
                return Decimal.valueOf(value.trim()); 
            } else if (fieldType == 'Boolean') {
                return Boolean.valueOf(value);
            } else if (fieldType == 'DateTime') { 
                return DateTime.valueOf(value);
            } else if (fieldType == 'Date') {   
                try {
                    return Date.parse(value);
                } catch(Exception e) {
                    DateTime tempDateTime = DateTime.valueOf(value); 
                    Date tempDate = tempDateTime.date();
                    return tempDate;
                }                   
            } else {
                return value;
            }
        } catch (Exception e) {
            return new Map<String,String>{'success' => 'false', 'value' => 'Invalid ' + fieldType + ' type : ' + value};
        }
    }
   /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to get available fields on Object which is used in import functioanlity
​ ​ ​ ​ ​*​ ​  @args​  :​ ​​String objectName - Specific Object
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning List<FieldDetailsWrapper> having details with object data mapping records.
    *   @Modified By: Rajesh @Feb 8 2018 REF-1333
​ ​ ​ ​ ​**/
    @RemoteAction
    public static List<FieldDetailsWrapper> getFields(String objectName, String isExport) {
        try {

            String query = 'SELECT Name, Id, Required__c, Label__c, Visible__c, Order__c,Section_Name__c, Field_API_Name__c, Object__c FROM Data_Mapping__c WHERE Object__c = \'DM'+ objectName + '\' ORDER BY Visible__c DESC, Order__c ASC NULLS LAST';
            Map<String,String> alwaysShow = new Map<String,String>{'Accounts__c'=> 'Accounts','Contacts__c' => 'Contacts','Attributes__c' => 'Attributes','Status__c' => 'Status','Reference_Use__c' => 'Reference Use','Process__c' => 'Process','Deadline__c' => 'Deadline','Project_Type__c' => 'Project Type'};
        
            if (objectName.trim() == 'Reference_Content__c') {
                query = 'SELECT Name, Id, Required__c, Label__c, Visible__c, Order__c, Section_Name__c, Field_API_Name__c, Object__c FROM Data_Mapping__c WHERE Object__c = \'DM'+ objectName + '\' OR Object__c = \'DMContentVersion\' ORDER BY Visible__c DESC, Order__c ASC NULLS LAST';
            }
            List<Data_Mapping__c> fieldList = Database.query(query); 
            List<FieldDetailsWrapper> availableFields = new List<FieldDetailsWrapper>(); 
            
            if(objectName != 'Account_with_Attributes__c' && objectName != 'Content_with_Attributes__c' && objectName != 'Contact_with_Attributes__c'
                && !objectName.contains('with_Attributes__c') && objectName.indexOf('__c') >= 0 && objectName != 'Library__c') {
                fieldList = UtilityController.fetchData(objectName);
            }
                    
            if (objectName == 'Account_with_Attributes__c') { 
                availableFields.add(new FieldDetailsWrapper('Account Name', 'Account__r.Name', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Account ID', 'Account__c', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Ref Profile Name', 'Name', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Ref Profile ID', 'Id', True, '', ''));
            } else if (objectName == 'Content_with_Attributes__c') {
                availableFields.add(new FieldDetailsWrapper('Content Name', 'Name', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Content Title', 'Title__c', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Content Type', 'Reference_Content_Type_Name__c', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Content ID', 'Content_ID__c', True, '', ''));
            } else if (objectName == 'Contact_with_Attributes__c') {
                availableFields.add(new FieldDetailsWrapper('Contact Name', 'Contact__r.Name', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Contact ID', 'Contact__c', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Ref Profile Name', 'Name', True, '', ''));
                availableFields.add(new FieldDetailsWrapper('Ref Profile ID', 'Id', True, '', ''));
            } else if (objectName == 'Reference_Content__c') {
                Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
                Schema.SObjectType objType = gd.get(UtilityController.appNamespace() + objectName);
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                Schema.SObjectType objTypeCV = gd.get('ContentVersion');
                Schema.DescribeSObjectResult objDescribeCV = objTypeCV.getDescribe();
                Map <String, Schema.SObjectField> fieldMapCV = objDescribeCV.fields.getMap();  
                for (Data_Mapping__c field : fieldList) { 
                    
                    if (field.Visible__c && field.Object__c == 'DMReference_Content__c') {
                        Schema.DescribeFieldResult fields = fieldMap.get(field.Field_API_Name__c).getDescribe();
                        String type = String.valueOf(fieldMap.get(fields.getName()).getDescribe().getType());
                        FieldDetailsWrapper fieldObj = new FieldDetailsWrapper(field.Label__c, field.Field_API_Name__c, field.Required__c, type, field.Object__c);
                        availableFields.add(fieldObj);
                    } else if (field.Visible__c && field.Object__c == ConstantsController.DMContentVersion) {
                        Schema.DescribeFieldResult fields = fieldMapCV.get(field.Field_API_Name__c).getDescribe();
                        String type = String.valueOf(fieldMapCV.get(fields.getName()).getDescribe().getType());
                        FieldDetailsWrapper fieldObj = new FieldDetailsWrapper(field.Label__c, field.Field_API_Name__c, field.Required__c, type, field.Object__c);
                        availableFields.add(fieldObj);
                    } 
                } 
            } else if (objectName == 'Reference_Request__c') {
                for (Data_Mapping__c field : fieldList) { 
                    
                    if (field.Visible__c) {
                        FieldDetailsWrapper fieldObj = new FieldDetailsWrapper(field.Label__c, field.Field_API_Name__c, field.Required__c ,field.Section_Name__c , field.Object__c);
                        availableFields.add(fieldObj);
                    }
                } 
            } else {

                for (Data_Mapping__c field : fieldList) { 
                    Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
                    Schema.SObjectType objType = gd.get(UtilityController.appNamespace() + objectName);
                    Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                    Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

                    if (field.Visible__c) {
                        Schema.DescribeFieldResult fields = fieldMap.get(field.Field_API_Name__c).getDescribe();
                        String type = String.valueOf(fieldMap.get(fields.getName()).getDescribe().getType());
                        FieldDetailsWrapper fieldObj = new FieldDetailsWrapper(field.Label__c, field.Field_API_Name__c, field.Required__c ,type, field.Object__c);
                        availableFields.add(fieldObj);
                    }
                } 
            }

            if (isExport.equalsIgnoreCase('true') && objectName != 'Account_with_Attributes__c' && objectName != 'Content_with_Attributes__c' && objectName != 'Contact_with_Attributes__c'
                && !objectName.contains('with_Attributes__c') && objectName.indexOf('__c') >= 0 && objectName != 'Library__c') {
                Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
                Schema.SObjectType objType = gd.get(UtilityController.appNamespace() + objectName);
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
                List<FieldDetailsWrapper> finalAvailableFields = new List<FieldDetailsWrapper>(); 

                for (FieldDetailsWrapper field : availableFields) {
                    if (!field.dataType.equalsIgnoreCase('TEXTAREA') && field.objectName != ConstantsController.DMContentVersion) {
                        finalAvailableFields.add(field);
                    }
                }
                availableFields = new List<FieldDetailsWrapper>(); 
                availableFields.addAll(finalAvailableFields);
            } 

            if (objectName.trim() == 'Reference_Request__c') {
                String namespace = UtilityController.appNamespace();

                for (String field : alwaysShow.keySet()) { 
                    FieldDetailsWrapper fieldObj = new FieldDetailsWrapper(alwaysShow.get(field), namespace + field, false ,'', 'DMReference_Request__c');
                    fieldObj.onlyShow = true;
                    availableFields.add(fieldObj);
                }
            }
            return availableFields;
        } catch(Exception e) { 
            return null;
        }
    } 
       
   /**
​ ​ ​ ​ ​*​ ​   ​@description​ ​:​ ​This​ ​method​ ​used to check Object and Field level Permissions.
​ ​ ​ ​ ​*​ ​   @args​  :​ ​List<String> mappedFields containing map with field ids,​ ​String objectName - Specific Object
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning Boolean with premission.
    *   @Modified By: Dixita @Jan 2018
​ ​ ​ ​ ​**/
    @RemoteAction
    public static String checkPermissions(List<String> mappedFields, String objectName) { 
        // Removing Error from List
        if (mappedFields.size() > 0) {
            mappedFields.remove(0);  
        }
         
        // Removing Id from List
        if (mappedFields.size() > 0) {
            mappedFields.remove(0);  
        }
        Map<String,Set<String>> fieldMap = new Map<String, Set<String>>();
        Map<String,Set<String>> fieldMapCS = new Map<String, Set<String>>();
        Set<String> mappedFieldsSet = new Set<String>();
        String namespace = UtilityController.appNamespace();
        
        if (objectName != 'Reference_Request__c') {
            for (String field : mappedFields) {
                mappedFieldsSet.add(namespace + field);
            }
            fieldMap.put(objectName, mappedFieldsSet); 
            
            if (objectName.contains('Reference_Content__c')) {
                fieldMap.put(namespace + 'ContentVersion', new Set<String> {
                                            namespace + 'Language',
                                            namespace + 'Title', 
                                            namespace + 'VersionData',
                                            namespace + 'Description', 
                                            namespace + 'TagCsv'
                                        });
            }
        } else {
            for (String field : mappedFields) {
                if (field == namespace + 'Opportunity__c'
                    || field == namespace + 'Requester__c'
                    || field == namespace + 'Title__c') {
                    if (fieldMap.containsKey(namespace + 'Reference_Request__c')) {
                        fieldMap.get(namespace + 'Reference_Request__c').add(field);
                    } else {
                        fieldMap.put(namespace + 'Reference_Request__c',new Set<String>());
                        fieldMap.get(namespace + 'Reference_Request__c').add(field);
                    }
                } else if (field == namespace + 'Account__c'
                    || field == namespace + 'Activity_Date__c'
                    || field == namespace + 'Reference_Type_Needed__c') {
                    if (fieldMap.containsKey(namespace + 'Reference_Request_Account__c')) {
                        fieldMap.get(namespace + 'Reference_Request_Account__c').add(field);
                    } else {
                        fieldMap.put(namespace + 'Reference_Request_Account__c',new Set<String>());
                        fieldMap.get(namespace + 'Reference_Request_Account__c').add(field);
                    }
                } else if (field == namespace + 'Contact__c'
                    || field == namespace + 'Feedback_Status__c'
                    || field == namespace + 'Feedback_Response__c') {
                    if (fieldMap.containsKey(namespace + 'Reference_Request_Account_Contact__c')) {
                        fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(field);
                    } else {
                        fieldMap.put(namespace + 'Reference_Request_Account_Contact__c',new Set<String>());
                        fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(field);
                    }
                } else if (field != namespace + 'Label__c' && field != namespace + 'Attribute__c'){
                    if (fieldMap.containsKey(namespace + 'Reference_Request_Additional_Info__c')) {
                        fieldMap.get(namespace + 'Reference_Request_Additional_Info__c').add(field);
                    } else {
                        fieldMap.put(namespace + 'Reference_Request_Additional_Info__c',new Set<String>());
                        fieldMap.get(namespace + 'Reference_Request_Additional_Info__c').add(field);
                    }
                }
            }
            if (!fieldMap.containsKey(namespace + 'Reference_Request__c')) {
                fieldMap.put(namespace + 'Reference_Request__c',new Set<String>());
            }
            fieldMap.get(namespace + 'Reference_Request__c').add(namespace + 'Reference_Request_Status__c');
            fieldMap.get(namespace + 'Reference_Request__c').add(namespace + 'Reference_Use__c');
            fieldMap.get(namespace + 'Reference_Request__c').add(namespace + 'Project_Type__c');
            fieldMap.get(namespace + 'Reference_Request_Account__c').add(namespace + 'Managed_Request__c');
            fieldMap.get(namespace + 'Reference_Request_Account__c').add(namespace + 'Account_Request_Status__c');
            fieldMap.get(namespace + 'Reference_Request_Account__c').add(namespace + 'Process__c');
            fieldMap.get(namespace + 'Reference_Request_Account__c').add(namespace + 'Reference_Use__c');
            fieldMap.get(namespace + 'Reference_Request_Account__c').add(namespace + 'Deadline__c');
            fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(namespace + 'Activity_Date__c');
            fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(namespace + 'Contact_Request_Status__c');
            fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(namespace + 'Referenceability_Type__c');
            fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(namespace + 'Reference_Use__c');
            fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(namespace + 'Is_Feedback_Received__c');
            fieldMap.get(namespace + 'Reference_Request_Account_Contact__c').add(namespace + 'Deadline__c');
        } 
        fieldMapCS.put(namespace + 'Custom_Settings__c', new Set<String> {
                                                namespace + 'Export_Object__c',
                                                namespace + 'Enable_Custom_Data_Loader__c',
                                                namespace + 'Export_Objects__c',
                                                namespace + 'Import_Object__c',
                                                namespace + 'Import_Objects__c'});
        Boolean isUpsertPermission = CRUDAndFLSCheckController.isDeletable(new List<String> {namespace + 'Data_Mapping__c'}) && CRUDAndFLSCheckController.isUpsertable(fieldMap, true, true) && CRUDAndFLSCheckController.isUpsertable(fieldMapCS, false, true);
        
        if (!isUpsertPermission) {
            List<Apexpages.Message> msgs = ApexPages.getMessages();
            String msg = msgs.size() > 0 ? msgs[0].getDetail() : '';
            return 'false:' + msg;
        } else {
            return 'true:';
        }
    }
    
   /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to insert records (uploaded using csv) in specific objects.
​ ​ ​ ​ ​*​ ​  @args​  :​ ​Map<String,Object> containing map with uploaded reords,​ ​String objectName - Specific Object
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning map with uploaded records.
    *   @Modified By: Dixita @July 2018
​ ​ ​ ​ ​**/    
    @RemoteAction
    public static Map<String,String> insertRecords(Map<String,Object> refRecord, String objectName) {    
        System.Savepoint sv = Database.setSavepoint(); 
        Reference_Content__c refContent ;  
        ContentVersion data;
        String namespace = UtilityController.appNamespace();
        Reference_Basic_Information__c rbi;        
        Map<String, Schema.SObjectType> objectMap = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType objType = objectMap.get(namespace + objectName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();       
        Schema.SObjectType objTypeCV = objectMap.get('ContentVersion');
        Schema.DescribeSObjectResult objDescribeCV = objTypeCV.getDescribe();
        Map <String, Schema.SObjectField> fieldMapCV = objDescribeCV.fields.getMap();  
        List<String> attribueIdsList;
        List<String> accountIdsList;
        Map<String, String> mapRefType = new Map<String, String>();
        Map<String,String> resultReturn = new Map<String,String>();
        Boolean recordFalied = false;  
        String queryForGetDataMapping = 'SELECT Name, Id, Section_Name__c,Data_Collector_Name__c,Order__c, Required__c, Label__c, Object__c, Visible__c, Field_API_Name__c FROM Data_Mapping__c WHERE ( Object__c = \'DM'+ objectName + '\'';
        queryForGetDataMapping += objectName == 'Reference_Content__c' ? 'OR Object__c = \'DMContentVersion\')' : ')';
        queryForGetDataMapping +=  ' AND Visible__c = true ORDER BY Order__c ASC NULLS LAST';
        List<Data_Mapping__c> fieldDataMapping =  Database.query(queryForGetDataMapping); 
        Set<String> fieldMapping = new Set<String>();
        Set<String> fieldMappingCV = new Set<String>();
        String query = 'SELECT ';
        String queryCV = 'SELECT Id,';
                
        if (objectName == 'Reference_Content__c') {
            
            for (Data_Mapping__c field : fieldDataMapping) {
                
                if (field.Object__c == 'DMReference_Content__c') {
                    query += field.Field_API_Name__c + ',';  
                    fieldMapping.add(field.Field_API_Name__c); 
                }
                //#REF-1592
                if (field.Object__c == ConstantsController.DMContentVersion || (field.Field_API_Name__c != namespace + 'Reference_Content_Type__c' && fieldMapCV.containsKey(field.Field_API_Name__c.toLowerCase()) && fieldMapCV.get(field.Field_API_Name__c.toLowerCase()).getDescribe().isCustom())) {
                    queryCV += field.Field_API_Name__c + ',';  
                    fieldMappingCV.add(field.Field_API_Name__c);  
                }
            }
        }
         /*Condition for existing records on the basis of record IDs*/
        
        if (refRecord.keySet().contains('Id') && refRecord.get('Id') != null && String.valueOf(refRecord.get('Id')).trim() != '') {
            
            if (objectName == 'Reference_Content__c') {
                
                if (query.indexOf('Content_ID__c') < 0 ) {
                    query = query + 'Content_ID__c' + ',' ;
                }
                if (query.indexOf('Attribute_Ids__c') < 0 ) {
                    query = query + 'Attribute_Ids__c' + ',' ;
                }
                query = query.removeEnd(',');
                queryCV = queryCV.removeEnd(',');
                String idToQuery = String.valueOf(refRecord.get('Id'));
                query += ' FROM ' + objectName + ' WHERE Id = :idToQuery '; 
                
                /*Handled Reference Content Object*/
                List<Reference_Content__c> temprefList = Database.query(query);
                
                if (temprefList.size() <= 0) {
                    return new Map<String,String>{'success' => 'false', 'value' => 'Invalid Reference Content ID'};
                } else {
                    refContent = temprefList[0];
                    String contentID = String.valueOf(refContent.get(namespace + 'Content_ID__c'));
                    queryCV = queryCV + ', FirstPublishLocationId, TagCsv, Title, Description, Language, ContentDocumentId, FileType FROM ContentVersion WHERE Id =:contentID';
                    List<ContentVersion> content = Database.query(queryCV);
                    data = (content.size() > 0 ) ? content.get(0) : null;
                    
                    if (refRecord.keySet().contains(namespace + 'Attribute_Ids__c')) {
                        List<String> allAttribueIdsList = new List<String>(new Set<String>(String.valueOf(refRecord.get(namespace + 'Attribute_Ids__c')).split(',')));
                        attribueIdsList = new List<String>(); 
                        
                        for (String att : allAttribueIdsList) {
                            
                            if (refContent.Attribute_Ids__c != null && String.valueOf(refContent.Attribute_Ids__c) != '' && !String.valueOf(refContent.Attribute_Ids__c).trim().contains(att.trim())) {
                                attribueIdsList.add(att);
                            } else if (refContent.Attribute_Ids__c == null || String.valueOf(refContent.Attribute_Ids__c) == '') {
                                attribueIdsList.add(att);
                            }
                        }   
                    } 
                    
                    //REF-1157
                    if (refRecord.keySet().contains(namespace + 'Associated_Accounts__c')) {
                        accountIdsList = new List<String>(new Set<String>(String.valueOf(refRecord.get(namespace + 'Associated_Accounts__c')).split(',')));
                    }  
                }   
            } else if (objectName == 'Reference_Basic_Information__c') { 
                Set<String> fieldsAvailableRBI = getImportFields();
                
                for (Data_Mapping__c field : fieldDataMapping) {
                    if (fieldsAvailableRBI.contains(field.Field_API_Name__c))
                    query += field.Field_API_Name__c + ',';            
                }
                
                if (!query.containsIgnoreCase(UtilityController.appNamespace() + 'Attribute_Ids__c')) {
                    query += UtilityController.appNamespace() + 'Attribute_Ids__c' + ',';
                }
                query = query.removeEnd(',');
                String idToQuery = String.valueOf(refRecord.get('Id'));
                query += ' FROM ' + objectName + ' WHERE Id = :idToQuery '; 
                
                /*Handled Reference Basic Information Object*/
                mapRefType = new Map<String, String>();
                
                for (Referenceability_Type__c ref : [SELECT Id, Referenceability_no__c FROM Referenceability_Type__c 
                                                                        WHERE Referenceability_no__c != null AND Referenceability_Type__c = true AND Visible__c = true AND Sales_Reward__c = false]){  
                    mapRefType.put(String.valueOf(ref.Id).substring(0,15),String.valueOf(ref.Referenceability_no__c)); 
                    
                }
                
                
                List<Reference_Basic_Information__c> temprefList = Database.query(query);
                
                if (temprefList.size() <= 0) {
                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Reference Profile ID', 'data' => ''};
                    recordFalied = true;
                } else {
                    rbi = temprefList[0];
                } 

                if (refRecord.containsKey(namespace + 'Attribute_Ids__c')) {
                    List<String> allAttribueIdsList = new List<String>(new Set<String>(String.valueOf(refRecord.get(namespace + 'Attribute_Ids__c')).split(',')));
                    attribueIdsList = new List<String>(); 
                    
                    for (String att : allAttribueIdsList) {
                        
                        if (rbi.Attribute_Ids__c == null || String.valueOf(rbi.Attribute_Ids__c) == '') {
                            attribueIdsList.add(att);
                        } else if (rbi.Attribute_Ids__c != null && String.valueOf(rbi.Attribute_Ids__c) != '' && !String.valueOf(rbi.Attribute_Ids__c).trim().contains(att.trim())) {
                            attribueIdsList.add(att);
                        } 
                    }         
                } 
            } 
        } else {
            /*Condition for new records*/
            
            if (objectName == 'Reference_Content__c') {
                refContent = new Reference_Content__c();
            } else if (objectName == 'Reference_Basic_Information__c') {
                /*Handled Reference Basic Information Object*/
                mapRefType = new Map<String, String>();
                String contactId = '';
                
                if (refRecord.get(namespace + 'Account__c') != null 
                                            && String.valueOf(refRecord.get(namespace + 'Account__c')).trim() != '' 
                                            && refRecord.get(namespace + 'Contact__c') != null 
                                            && String.valueOf(refRecord.get(namespace + 'Contact__c')).trim() != '') {
                    contactId = String.valueOf(refRecord.get(namespace + 'Contact__c'));
                    List<Contact> contact = [SELECT Id, AccountId FROM Contact WHERE Id =:contactId]; 

                    if (contact.size() == 0) {
                        return new Map<String,String>{'success' => 'false', 'value' => 'Contact Id Invalid : ' + contactId};
                    } else if (String.valueOf(refRecord.get(namespace + 'Account__c')).trim().length() < 15 && String.valueOf(contact.get(0).AccountId).substring(0,15) != String.valueOf(refRecord.get(namespace + 'Account__c')).trim().substring(0,15)) {
                        return new Map<String,String>{'success' => 'false', 'value' => 'Contact Id : ' + contactId + ' not associated with Account Id : ' + String.valueOf(refRecord.get(namespace + 'Account__c'))};
                    }
                } else {
                    //REF-1768 - Account and Contact Id validation
                    if (refRecord.get(namespace + 'Account__c') == null 
                                                || String.valueOf(refRecord.get(namespace + 'Account__c')).trim() == '') {
                        return new Map<String,String>{'success' => 'false', 'value' => 'Account Id required'};
                    }  /*else (refRecord.get(namespace + 'Contact__c') == null 
                                                || String.valueOf(refRecord.get(namespace + 'Contact__c')).trim() == '') {
                        return new Map<String,String>{'success' => 'false', 'value' => 'Contact Id required'};
                    }*/
                }
                for (Referenceability_Type__c ref : [SELECT Id, Referenceability_no__c FROM Referenceability_Type__c WHERE Referenceability_no__c != null AND Referenceability_Type__c = true AND Visible__c = true AND Sales_Reward__c = false]) {  
                    mapRefType.put(String.valueOf(ref.Id).substring(0,15),String.valueOf(ref.Referenceability_no__c)); 
                }
                rbi = new Reference_Basic_Information__c();
            } 
        }     
        try {
            String[] attributeIds = new List<String>();
            Boolean isReferenceProgramMember = false;
            String status;
            String[] refTypeIds = new List<String>();
            Boolean isRefMemberOrCandidateExist = false;
            List<Reference_Content_Type__c> refConId = new List<Reference_Content_Type__c>();
            Map<String,Reference_Type_Mapping__c> refTypeMap = new Map<String,Reference_Type_Mapping__c>();
            List<ContentWorkspace> libId = new List<ContentWorkspace>();

            if (objectName == 'Reference_Content__c') { 

                refConId = [Select Id, Name__c, Active__c from Reference_Content_Type__c 
                                                    WHERE Id = :String.valueOf(refRecord.get(namespace + 'Reference_Content_Type__c')).trim() 
                                                    OR Name__c = :String.valueOf(refRecord.get(namespace + 'Reference_Content_Type__c')).trim()];                 
                libId = [Select Id from ContentWorkspace where Id = :String.valueOf(refRecord.get(namespace + 'Library_ID__c')).trim()];
                                
            } else if (objectName == 'Reference_Basic_Information__c') {
                status = refRecord.containsKey(namespace + 'Referenceability_Status__c') ? String.valueOf(refRecord.get(namespace + 'Referenceability_Status__c')).toLowerCase() : '';
                
                if (!isReferenceProgramMember && refRecord.containsKey(namespace + 'Is_Referenceable__c') 
                                                && Boolean.valueOf(refRecord.get(namespace + 'Is_Referenceable__c')) == true) {
                    isReferenceProgramMember = true;
                } 
                
            } else if (objectName == 'Reference_Request__c') {

                Reference_Request__c request = new Reference_Request__c();
                Reference_Request_Account__c accRequest = new Reference_Request_Account__c();
                Reference_Request_Account_Contact__c refReqAccContactObject = new Reference_Request_Account_Contact__c();
                List<Reference_Request_Label__c> requestLabels = new List<Reference_Request_Label__c>();
                List<Reference_Request_Label_Attribute__c> requestLabelsAttr = new List<Reference_Request_Label_Attribute__c>();
                Reference_Request_Additional_Info__c reqAdd = new Reference_Request_Additional_Info__c();
                Map<Id,Set<Id>> filterToAttrMap = new Map<Id,Set<Id>>();
                Id oppId,userId;
                Date activityDate = System.today();
                List<Referenceability_Type__c> refTypeId = new List<Referenceability_Type__c>();
                refTypeId = [SELECT Id, Visible__c, Request_type__c FROM Referenceability_Type__c WHERE Id = :String.valueOf(refRecord.get(namespace + 'Reference_Type_Needed__c')).trim() 
                                                    OR Name = :String.valueOf(refRecord.get(namespace + 'Reference_Type_Needed__c')).trim()]; 
                if (refTypeId.size() == 0) {
                    recordFalied = true;
                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Referenceability Type : ' + String.valueOf(refRecord.get(namespace + 'Reference_Type_Needed__c')).trim(), 'data' => ''};
                } else if (!refTypeId.get(0).Visible__c || !refTypeId.get(0).Request_type__c) {
                    recordFalied = true;
                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Referenceability Type unavailable for use', 'data' => ''};
                } 
                if (!recordFalied && refRecord.containsKey(namespace + 'Opportunity__c') && refRecord.get(namespace + 'Opportunity__c') != null && String.valueOf(refRecord.get(namespace + 'Opportunity__c')).trim() != '') {
                    try {
                        oppId = Id.valueOf(String.valueOf(refRecord.get(namespace + 'Opportunity__c')).trim());
                    }
                    catch (Exception ex) {
                        recordFalied = true;
                        resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Opportunity Id :' + String.valueOf(refRecord.get(namespace + 'Opportunity__c')).trim(), 'data' => ''};
                    }
                }

                if (!recordFalied && refRecord.containsKey(namespace + 'Requester__c') && refRecord.get(namespace + 'Requester__c') != null && String.valueOf(refRecord.get(namespace + 'Requester__c')).trim() != '') {
                    try {
                        userId = Id.valueOf(String.valueOf(refRecord.get(namespace + 'Requester__c')).trim());
                    }
                    catch (Exception ex) {
                        recordFalied = true;
                        resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Requester Id :' + String.valueOf(refRecord.get(namespace + 'Requester__c')).trim(), 'data' => ''};
                    }
                } else {
                    userId = userinfo.getuserid();
                }
                if (!recordFalied) {
                    String accountId = String.valueOf(refRecord.get(namespace + 'Account__c')).trim();
                    String contactId = refRecord.get(namespace + 'Contact__c') != null ? String.valueOf(refRecord.get(namespace + 'Contact__c')).trim() : '';
                    
                    if (accountId != null && accountId != '') {
                        //Account Id errors
                        List<Account> tempList = [SELECT Id, Name, (SELECT Name, Contact__r.Name, Contact__c, Reference_Program_Candidate__c, Account__c, Is_Referenceable__c, 
                                                    Referenceability_Status__c FROM Reference_Basic_Informations__r WHERE Contact__c = null) FROM Account WHERE Id = :accountId
                                                    LIMIT 1];
                        if (tempList.size() <= 0) { 
                            recordFalied = true;
                            resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Account Id : ' + accountId, 'data' => ''};
                        } else {
                            if (contactId != null && contactId != '') {
                                //Contact Id errors
                                List<Contact> contact = [SELECT Id, AccountId, Name, Title, Email, Phone,
                                        (SELECT Name, Account__c, Contact__r.Name, Contact__c, Reference_Program_Candidate__c,
                                            Is_Referenceable__c, Referenceability_Status__c
                                            FROM Reference_Basic_Informations__r)
                                        FROM Contact WHERE Id = :contactId LIMIT :limits.getLimitQueryRows()];
                                if (contact.size() <= 0) {
                                    recordFalied = true;
                                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Contact Id : ' + contactId, 'data' => ''};
                                } else if (contact.get(0).AccountId != accountId) {
                                    recordFalied = true;
                                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Contact Not associated to selected Account', 'data' => ''};
                                } else if (!refRecord.containsKey(namespace + 'Feedback_Status__c') || refRecord.get(namespace + 'Feedback_Status__c') == null || String.valueOf(refRecord.get(namespace + 'Feedback_Status__c')).trim() == '') {
                                    recordFalied = true;
                                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Required Field Missing : Use Feedback', 'data' => ''};
                                } else if (refRecord.containsKey(namespace + 'Feedback_Status__c') && refRecord.get(namespace + 'Feedback_Status__c') != null && String.valueOf(refRecord.get(namespace + 'Feedback_Status__c')).trim() != '' ) {
                                    
                                    if (!String.valueOf(refRecord.get(namespace + 'Feedback_Status__c')).trim().equalsIgnoreCase('Use completed - Unsuccessful') && !String.valueOf(refRecord.get(namespace + 'Feedback_Status__c')).trim().equalsIgnoreCase('Use completed - Successful')) {
                                        recordFalied = true;
                                        resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Use Feedback Value Incorrect : ' + String.valueOf(refRecord.get(namespace + 'Feedback_Status__c')).trim(), 'data' => ''};
                                    } else if (String.valueOf(refRecord.get(namespace + 'Feedback_Status__c')).trim().equalsIgnoreCase('Use completed - Unsuccessful') && (!refRecord.containsKey(namespace + 'Feedback_Response__c') || refRecord.get(namespace + 'Feedback_Response__c') == null || String.valueOf(refRecord.get(namespace + 'Feedback_Response__c')).trim() == '')) {
                                        recordFalied = true;
                                        resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Required Field Missing : Feedback Response', 'data' => ''};
                                    }
                                }
                            }

                            if (!recordFalied) {
                                if (refRecord.containsKey(namespace + 'Activity_Date__c') && refRecord.get(namespace + 'Activity_Date__c') != null && String.valueOf(refRecord.get(namespace + 'Activity_Date__c')).trim() != '') {
                                    Object val = getInType('DATE',String.valueOf(refRecord.get(namespace + 'Activity_Date__c')).trim());
                                    
                                    if (val instanceof Map<String,String>) {
                                        Database.rollback(sv);
                                        return (Map<String,String>)val;
                                    } else if (val != null) {
                                        Date dateProvided = Date.valueOf(getInType('DATE',String.valueOf(refRecord.get(namespace + 'Activity_Date__c')).trim()));
                                        
                                        if (dateProvided > activityDate) {
                                            recordFalied = true;
                                            resultReturn = new Map<String,String>{'success' => 'false', 'value' => System.Label.ACTIVITY_DATE + dateProvided, 'data' => ''};
                                        } else {
                                            activityDate = dateProvided;
                                        }
                                    }
                                } else {
                                    recordFalied = true;
                                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Required Field Missing : Activity Date', 'data' => ''};
                                }
                                if (!recordFalied) {
                                    for (Reference_Type_Mapping__c refItem : [SELECT Id, Label__c, Order__c, Reference_Content_Type__c, Referenceability_Type__c, Required__c, Visible__c, Name FROM Reference_Type_Mapping__c WHERE Referenceability_Type__c =:refTypeId.get(0).Id AND Visible__c = true]) {
                                        refTypeMap.put(refItem.Label__c == null ? refItem.Name : String.valueOf(refItem.Label__c).substring(0,15) ,refItem);
                                        
                                        if (refItem.Label__c != null && refItem.Required__c && (!refRecord.containsKey(namespace + 'Label__c') || refRecord.get(namespace + 'Label__c') == null || String.valueOf(refRecord.get(namespace + 'Label__c')).trim() == '')) {
                                            recordFalied = true;
                                            resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Required Filter Missing : ' + refItem.Label__c, 'data' => ''};
                                            break;
                                        }
                                    }
                                }

                                if (!recordFalied) {
                                        
                                    if (refRecord.containsKey(namespace + 'Label__c') && refRecord.get(namespace + 'Label__c') != null && String.valueOf(refRecord.get(namespace + 'Label__c')).trim() != '') {
                                        //Filter Id errors
                                        List<String> filterIds = String.valueOf(refRecord.get(namespace + 'Label__c')).trim().split(',');
                                        Map<String,Boolean> attMapped = new Map<String,Boolean>();
                                        // If any Attribute Ids exist
                                        
                                        if (refRecord.containsKey(namespace + 'Attribute__c') && refRecord.get(namespace + 'Attribute__c') != null && String.valueOf(refRecord.get(namespace + 'Attribute__c')).trim() != '') { 
                                            for (String attributeId : String.valueOf(refRecord.get(namespace + 'Attribute__c')).trim().split(',')) {
                                                attMapped.put(attributeId.trim().substring(0,15),false);
                                            }
                                        }
                                        Map<Id,Label__c> labels = new Map<Id,Label__c>();
                                        
                                        for (Label__c label : [SELECT Id, (SELECT Id, Attribute__c from  Attributes_Labels__r) FROM Label__c WHERE Id IN :filterIds]) {
                                            labels.put(String.valueOf(label.Id).substring(0,15),label);
                                        }
                                        
                                        for (String tempFilterId : filterIds) {
                                            String filterId = tempFilterId.trim().substring(0,15);
                                            
                                            if (!labels.containsKey(filterId)) {
                                                recordFalied = true;
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Filter Id : ' + tempFilterId.trim(), 'data' => ''};
                                                break;
                                            } else if (!refTypeMap.containsKey(filterId)) {
                                                recordFalied = true;
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Filter Id : ' + tempFilterId.trim() + ' not Visible for this Ref Type', 'data' => ''};
                                                break;
                                            } else if (attMapped.size() > 0) {
                                                filterToAttrMap.put(filterId,new Set<Id>());
                                                
                                                for (Attributes_Labels__c attrLabel : labels.get(filterId).Attributes_Labels__r) {
                                                    if (attMapped.containsKey(String.valueOf(attrLabel.Attribute__c).substring(0,15))) {
                                                        filterToAttrMap.get(filterId).add(String.valueOf(attrLabel.Attribute__c).substring(0,15));
                                                        attMapped.put(String.valueOf(attrLabel.Attribute__c).substring(0,15),true);
                                                    }
                                                }
                                            }
                                            if (refTypeMap.get(filterId).Required__c && (!filterToAttrMap.containsKey(filterId) || filterToAttrMap.get(filterId).size() <= 0)) {
                                                recordFalied = true;
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Required Filter not populated:' + tempFilterId, 'data' => ''};
                                                break;
                                            }
                                        }
                                        if (!recordFalied){
                                            for (String attId : attMapped.keySet()) {
                                                
                                                if (!attMapped.get(attId)) {
                                                    recordFalied = true;
                                                    resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'No Filter Associated to Selected Attribute included in Filters : ' + attId , 'data' => ''};
                                                    break;
                                                }
                                            }
                                        }
                                    } else if ((!refRecord.containsKey(namespace + 'Label__c') || refRecord.get(namespace + 'Label__c') == null || String.valueOf(refRecord.get(namespace + 'Label__c')).trim() == '') && (refRecord.containsKey(namespace + 'Attribute__c') && refRecord.get(namespace + 'Attribute__c') != null && String.valueOf(refRecord.get(namespace + 'Attribute__c')).trim() != '')) {
                                        recordFalied = true;
                                        resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'No Filter Associated to Selected Attribute included in Filters : ' + String.valueOf(refRecord.get(namespace + 'Attribute__c')).trim() , 'data' => ''};
                                    }
                                } 
                            }
                        }
                    } else {
                        recordFalied = true;
                        resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'No Account Id provided', 'data' => ''};
                    }                           
                }
                //Final Records Creation 
                if (!recordFalied) {
                    
                    for (Data_Mapping__c dmRecord : fieldDataMapping) {
                        
                        if (dmRecord.Data_Collector_Name__c == namespace + 'Reference_Request_Additional_Info__c' && refTypeMap.containsKey(dmRecord.Field_API_Name__c)) {
                            
                            if (refRecord.containsKey(dmRecord.Field_API_Name__c) && refRecord.get(dmRecord.Field_API_Name__c) != null && String.valueOf(refRecord.get(dmRecord.Field_API_Name__c)).trim() != '') {
                                Object val = getInType(dmRecord.Section_Name__c,String.valueOf(refRecord.get(dmRecord.Field_API_Name__c)).trim());
                                if (val instanceof Map<String,String>) {
                                    return (Map<String,String>)val;
                                } else if (val != null) {
                                    reqAdd.put(dmRecord.Field_API_Name__c,getInType(dmRecord.Section_Name__c,String.valueOf(refRecord.get(dmRecord.Field_API_Name__c)).trim()));
                                }
                            } else if (refTypeMap.get(dmRecord.Field_API_Name__c).Required__c) {
                                recordFalied = true;
                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Required Field Missing : ' + dmRecord.Label__c, 'data' => ''};
                                break;
                            }
                        }
                    }
                    if (!recordFalied) {
                        Id refReqAddInfo,RRId;
                        Database.SaveResult result = Database.insert(reqAdd, false);
                        
                        if (result.isSuccess()) {
                            refReqAddInfo = result.getId();
                            request.Opportunity__c = oppId;
                            request.Project_Type__c = ConstantsController.MANAGED;
                            request.Reference_Request_Status__c = ConstantsController.COMPLETED;
                            request.Title__c = refRecord.containsKey(namespace + 'Title__c') && refRecord.get(namespace + 'Title__c') != null && String.valueOf(refRecord.get(namespace + 'Title__c')).trim() != '' ? String.valueOf(refRecord.get(namespace + 'Title__c')).trim() : '';
                            request.Reference_Use__c = true;
                            request.Requester__c = userId;
                            result = Database.insert(request, false);
                            
                            if (result.isSuccess()) {
                                RRId = result.getId();
                                resultReturn = new Map<String,String>{'success' => 'true', 'value' => RRId, 'data' => ''}; 
                                // Check RBI Records Created or not
                                String contactId = refRecord.get(namespace + 'Contact__c') != null ? String.valueOf(refRecord.get(namespace + 'Contact__c')).trim() : '';
                        
                                if (contactId != null && contactId != '') {
                                    UtilityController.checkRBI(String.valueOf(refRecord.get(namespace + 'Account__c')).trim(), contactId,
                                                                String.valueOf(refRecord.get(namespace + 'Account__c')).trim(), true);
                                } else {
                                    UtilityController.checkRBI(String.valueOf(refRecord.get(namespace + 'Account__c')).trim(), null, null, true);
                                }
                                accRequest.Activity_Date__c = activityDate;
                                accRequest.Account__c = String.valueOf(refRecord.get(namespace + 'Account__c')).trim();
                                accRequest.Deadline__c = system.today();
                                accRequest.Reference_Use__c = true;
                                accRequest.Process__c = ConstantsController.MANAGED;
                                accRequest.Account_Request_Status__c = ConstantsController.COMPLETED;
                                accRequest.Reference_Request__c = RRId;
                                accRequest.Managed_Request__c = true;
                                accRequest.Reference_Request_Additional_Info__c = refReqAddInfo;
                                accRequest.Reference_Type_Needed__c = refTypeId[0].Id;
                                accRequest.Requester__c = request.Requester__c;
                                List<Reference_Request_Account__c> rraRecord = WithoutSharingHelperController.insertRRA(new List<Reference_Request_Account__c>{accRequest});
                                
                                if (rraRecord.size() > 0) {
                                    accRequest = rraRecord[0];

                                    if (contactId != null && contactId != '') {
                                        refReqAccContactObject.Reference_Request_Account__c = accRequest.Id;
                                        refReqAccContactObject.Activity_Date__c = accRequest.Activity_Date__c;
                                        refReqAccContactObject.Reference_Use__c = true;
                                        refReqAccContactObject.Contact__c = contactId;
                                        refReqAccContactObject.Deadline__c = system.today();
                                        refReqAccContactObject.Referenceability_Type__c = accRequest.Reference_Type_Needed__c;
                                        refReqAccContactObject.Contact_Request_Status__c = ConstantsController.COMPLETED;
                                        refReqAccContactObject.Is_Feedback_Received__c = true;
                                        refReqAccContactObject.Feedback_Status__c = String.valueOf(refRecord.get(namespace + 'Feedback_Status__c')).trim();
                                        refReqAccContactObject.Feedback_Response__c = refRecord.containsKey(namespace + 'Feedback_Response__c') ? String.valueOf(refRecord.get(namespace + 'Feedback_Response__c')).trim() : '';
                                        WithoutSharingHelperController.upsertRRAC(refReqAccContactObject);
                                    }
                                    //Reference_Request_Label__c
                                    for (String filterId : filterToAttrMap.keySet()) {
                                        requestLabels.add(new Reference_Request_Label__c(Label__c = filterId,Reference_Request__c = RRId));
                                    }
                                    List<Database.SaveResult> filterResults = Database.insert(requestLabels, false);

                                    for (Reference_Request_Label__c resultFilter : requestLabels) {
                                        
                                        for (String attrId : filterToAttrMap.get(resultFilter.Label__c)) {
                                            requestLabelsAttr.add(new Reference_Request_Label_Attribute__c (Reference_Request_Label__c = resultFilter.Id,Attribute__c = attrId));
                                        }
                                    }
                                    if (requestLabelsAttr.size() > 0) {
                                        insert requestLabelsAttr;
                                    }

                                    Custom_Settings__c cs = UtilityController.getCustomSettings();
                                    //Rewards
                                    if (RefEdgeEditionFeatures.isBasic == false && cs.Enable_Sales_Rewards_Notification__c == true) {        	
                                        List<String> lstUserAction = new List<String>();
                                        lstUserAction.add(ConstantsController.REFERANCE_USE);
                                        // Get Sales reward Referenceability  
                                        List<Referenceability_Type__c> refType = WithoutSharingHelperController.getReferenceabilityRewardDetails(lstUserAction);
                                        
                                        if (refType.size() > 0) { 
                                            List<Reward__c> rewardsToBeInsert = new List<Reward__c>();
                                            rewardsToBeInsert.add(new Reward__c(Amount__c = refType[0].Sales_Point__c,
                                                                                Referenceability_Type__c = refType[0].Id,
                                                                                Transaction__c = ConstantsController.ISSUE, 
                                                                                RewardDate__c = Date.Today(),
                                                                                User__c = request.Requester__c)); 
                                            
                                            if (rewardsToBeInsert.size() > 0) {
                                                WithoutSharingHelperController.insertRewards(rewardsToBeInsert);  
                                            }
                                        }
                                    }
                                }
                            } else {
                                Database.rollback(sv);
                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => CRUDAndFLSCheckController.getCleanSystemErrorMsg(result.getErrors()[0].getMessage()), 'data' => ''};       
                            }
                        } else {
                            Database.rollback(sv);
                            resultReturn = new Map<String,String>{'success' => 'false', 'value' => CRUDAndFLSCheckController.getCleanSystemErrorMsg(result.getErrors()[0].getMessage()), 'data' => ''};       
                        }
                    }
                }

            }
            
            if (!recordFalied && objectName != 'Reference_Request__c') {           
                
                for (String field : refRecord.keySet()) {
                    
                    if ((field != 'showBrowse' && field != 'isNew' && field != 'success' && field != 'detail' && !recordFalied) 
                            && field != namespace + 'Reference_Content_Type_Name__c' && field != namespace + 'Content_ID__c'
                            && field != namespace + 'Attributes__c' && field != namespace + 'Referenceability__c') {                            
                        //#REF-1592 : Iterate only over Reference Content fields 
                        if (objectName == 'Reference_Content__c' && fieldMapping.contains(field.trim())) { 
                            
                            if (field.equalsIgnoreCase(namespace + 'Associated_Accounts__c') && accountIdsList == null) {                        
                                accountIdsList = new List<String>(new Set<String>(String.valueOf(refRecord.get(field)).split(',')));    
                            } else if (field.equalsIgnoreCase(namespace + 'Attribute_Ids__c') && attribueIdsList == null) {                        
                                attribueIdsList = new List<String>(new Set<String>(String.valueOf(refRecord.get(field)).split(',')));    
                            } else {
                                
                                if (field == namespace + 'Library_ID__c') {
                                    
                                    if ((libId.size() <= 0 || refRecord.get(field) == null || String.valueOf(refRecord.get(field)).trim() == '') && !test.isRunningTest()) {
                                        return new Map<String,String>{'success' => 'false', 'value' => 'Invalid Library Id'};
                                    }
                                } else if (field == namespace + 'Reference_Content_Type__c') {                           
                                    
                                    if (refConId.size() <= 0 || refRecord.get(field) == null || String.valueOf(refRecord.get(field)).trim() == '' ) {
                                        return new Map<String,String>{'success' => 'false', 'value' => 'Invalid Reference Content Type Id '};
                                    } else if (!refConId.get(0).Active__c ) {
                                        return new Map<String,String>{'success' => 'false', 'value' => 'Reference Content Type inactive '};
                                    } else {
                                    
                                        if (refRecord.containsKey(namespace + 'Reference_Content_Type_Name__c') 
                                                    && refRecord.get(namespace + 'Reference_Content_Type_Name__c') != null 
                                                    && String.valueOf(refRecord.get(namespace + 'Reference_Content_Type_Name__c')) != '') {
                                            
                                            if (refConId.get(0).Name__c.trim().equalsIgnoreCase(String.valueOf(refRecord.get(namespace + 'Reference_Content_Type_Name__c')).trim())) {
                                                refContent.Reference_Content_Type_Name__c = refConId.get(0).Name__c;
                                                refContent.put(field,refConId.get(0).Id);
                                            } else {
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Reference Content Type Name Mismatch', 'data' => ''};
                                                recordFalied = true;
                                            }
                                        } else {
                                            refContent.Reference_Content_Type_Name__c = refConId.get(0).Name__c;
                                            refContent.put(field,refConId.get(0).Id);
                                        }
                                    }
                                } else if (field == namespace + 'Content_URL__c' && !recordFalied) {
                                    ContentVersion content = (data == null) ? new ContentVersion() : data;  
                                    
                                    if (data != null && data.FileType != 'LINK' && String.valueOf(refRecord.get('showBrowse')) == 'false') {
                                        return new Map<String,String>{'success' => 'false', 'value' => 'File Type Content can not be changed to URL Type Content'};  
                                    } else if (String.valueOf(refRecord.get('showBrowse')) == 'true' && data != null && data.FileType == 'LINK') { 
                                        return new Map<String,String>{'success' => 'false', 'value' => 'URL Type Content can not be changed to File Type Content'};   
                                    } else if (!refRecord.containsKey(namespace + 'Library_ID__c') || String.valueOf(refRecord.get(namespace + 'Library_ID__c')) == '') {
                                        return new Map<String,String>{'success' => 'false', 'value' => 'Invalid Library Id'};
                                    } else if (refRecord.containsKey(namespace + 'Library_ID__c') && String.valueOf(refRecord.get(namespace + 'Library_ID__c')) != '' && libId.size() <= 0 && !test.isRunningTest()) {
                                        return new Map<String,String>{'success' => 'false', 'value' => 'Invalid Library Id'};
                                    } else if (data != null && refContent.Library_ID__c != null && refRecord.containsKey(namespace + 'Library_ID__c') && String.valueOf(refContent.Library_ID__c).substring(0,15) != String.valueOf(refRecord.get(namespace + 'Library_ID__c')).trim().substring(0,15)) {
                                        return new Map<String,String>{'success' => 'false', 'value' => 'Library of Content can\'t be changed'};
                                    } else if (refConId != null && refConId.size() > 0 && refConId.get(0).Active__c ) {
                                        if (data == null) {
                                            content.FirstPublishLocationId = String.valueOf(refRecord.get(namespace + 'Library_ID__c')).trim();
                                            content.Content_Status__c = (refRecord.containsKey(namespace + 'Content_Status__c') 
                                                                            && refRecord.get(namespace + 'Content_Status__c') != null
                                                                            && String.valueOf(refRecord.get(namespace + 'Content_Status__c')).trim() != '')
                                                                            ? String.valueOf(refRecord.get(namespace + 'Content_Status__c')).trim().equalsIgnoreCase('Active') ? 'Active' : 'Inactive'
                                                                            : 'Inactive';
                                        } 
                                        content.TagCsv = ((refRecord.containsKey(namespace + 'Search_Terms_keywords__c') 
                                                            && refRecord.get(namespace + 'Search_Terms_keywords__c') != null 
                                                            && String.valueOf(refRecord.get(namespace + 'Search_Terms_keywords__c')) != '') 
                                                            ? String.valueOf(refRecord.get(namespace + 'Search_Terms_keywords__c')).trim() : '');
                                        content.Description = (refRecord.containsKey(namespace + 'Summary__c') 
                                                                && refRecord.get(namespace + 'Summary__c') != null 
                                                                && String.valueOf(refRecord.get(namespace + 'Summary__c')) != '')
                                                            ? String.valueOf(refRecord.get(namespace + 'Summary__c')).substring(0, Math.min(String.valueOf(refRecord.get(namespace + 'Summary__c')).length(), 1000)) : '';
                                        content.Title = String.valueOf(refRecord.get(namespace + 'Title__c'));  
                                        content.Reference_Content_Type__c = refConId.get(0).Id;
                                        
                                        if (refRecord.containsKey(namespace + 'Language__c')) {
                                                
                                            for (String langKey : UtilityController.mapContentLanguage.keySet()) {
                                                
                                                if (UtilityController.mapContentLanguage.get(langKey) == String.valueOf(refRecord.get(namespace + 'Language__c')).trim()) {
                                                    content.Language = langKey;
                                                    break;
                                                }
                                            }
                                        }
                                        //#REF-1592 : Populate CV Fields
                                        for (String  cvField : fieldMappingCV) {
                                            
                                            if (refRecord.containsKey(cvField)) {
                                                Object val = getInType(String.valueOf(fieldMapCV.get(cvField).getDescribe().getType()), String.valueOf(refRecord.get(cvField)));
                                
                                                if (val instanceof Map<String,String>) {
                                                    return (Map<String,String>)val;
                                                }
                                                if (val != null) { 
                                                    content.put(cvField, getInType(String.valueOf(fieldMapCV.get(cvField).getDescribe().getType()), String.valueOf(refRecord.get(cvField))));                                
                                                } 
                                            }
                                        }
                                        
                                        if (String.valueOf(refRecord.get('showBrowse')) == 'false') {
                                            content.ContentUrl = String.valueOf(refRecord.get(field));
                                            
                                            if (refRecord.get(field) != null) { 
                                                refContent.put(namespace + 'Content_URL__c', String.valueOf(refRecord.get(field)).length() > 255 ? String.valueOf(refRecord.get(field)).substring(0,254) : String.valueOf(refRecord.get(field)));
                                                refContent.put(namespace + 'Content_URL2__c', String.valueOf(refRecord.get(field)).length() > 255 ? String.valueOf(refRecord.get(field)).substring(255) : '');        
                                            }  
                                            ConstantsController.isRequestFromDM = true;
                                            Database.UpsertResult[] resultsContent = Database.upsert(new List<ContentVersion> {content}, false); 
                                            
                                            if (!resultsContent[0].isSuccess()) {
                                                return new Map<String,String>{'success' => 'false', 'value' => resultsContent[0].getErrors()[0].getMessage()};   
                                            } else {
                                                refContent.Content_ID__c = resultsContent[0].getId();
                                            }
                                        } else {

                                            if (data == null) {
                                                content.PathOnClient = String.valueOf(refRecord.get(namespace + 'Title__c')); 
                                            } 
                                            //#REF-1592 : Pass back CV record for file type data
                                            resultReturn.put('data',JSON.serialize(content));
                                        }
                                    } 
                                }
                                
                                if (field != namespace + 'Content_URL__c' && field != namespace + 'Reference_Content_Type__c' && !(field == 'Id' && (refRecord.get('Id') == null || String.valueOf(refRecord.get('Id')).trim() == '')) && !recordFalied) {
                                    Object val = getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), String.valueOf(refRecord.get(field)));
                                    
                                    if (val instanceof Map<String,String>) {
                                        return (Map<String,String>)val;
                                    }
                                    if (val != null) { 
                                        refContent.put(field, getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), String.valueOf(refRecord.get(field))));                                
                                    }                                   
                                }
                            } 
                        } else if (objectName == 'Reference_Basic_Information__c') {
                        
                            if (field.equalsIgnoreCase(namespace + 'Attribute_Ids__c') && attribueIdsList == null) {                        
                                attribueIdsList = new List<String>(new Set<String>(String.valueOf(refRecord.get(field)).split(',')));    
                            } else {
                                
                                if (!(field == 'Id' && (refRecord.get('Id') == null || String.valueOf(refRecord.get('Id')).trim() == ''))) { 
                                    Object val;
                                    val = getInType(String.valueOf(fieldMap.get(field.trim().toLowerCase()).getDescribe().getType()), String.valueOf(refRecord.get(field.trim()))); 
                                    
                                    if (val instanceof Map<String,String>) {
                                        return (Map<String,String>)val;
                                    }
                                    
                                    if (val != null) {
                                        
                                        if (field == namespace + 'ReferenceabilityType_Ids1__c' 
                                                        || field == namespace + 'ReferenceabilityType_Ids2__c') { 
                                            
                                            if (!String.isBlank(getReferenceabilityTypeCode(String.valueOf(refRecord.get(field)), mapRefType))) { 
                                                refTypeIds = new List<String>(new Set<String>(String.valueOf(refRecord.get(field)).split(',')));  
                                                rbi.put(field, getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), getReferenceabilityTypeCode(String.valueOf(refRecord.get(field)), mapRefType)));
                                            } else { 
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid or Unavailable Referenceability Types', 'data' => ''};
                                                recordFalied = true;
                                            } 
                                        } else if (field == namespace + 'Is_Referenceable__c') {
                                            
                                            if (!isRefMemberOrCandidateExist || Boolean.valueOf(refRecord.get(field)) == false) {
                                                isReferenceProgramMember = true;
                                                isRefMemberOrCandidateExist = true;
                                                rbi.put(field, getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), String.valueOf(refRecord.get(field))));
                                            } else { 
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'You cannot set Reference Program Candidate and Reference Program Member at same time.', 'data' => ''}; 
                                                recordFalied = true;
                                            }
                                        } else if (field == namespace + 'Reference_Program_Candidate__c') {
                                                
                                            if (!isRefMemberOrCandidateExist || Boolean.valueOf(refRecord.get(field)) == false) { 
                                                
                                                if (Boolean.valueOf(refRecord.get(field))) {
                                                    isRefMemberOrCandidateExist = true;
                                                }
                                                rbi.put(field, getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), String.valueOf(refRecord.get(field))));
                                            } else {
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'You cannot set Reference Program Candidate and Reference Program Member at same time.', 'data' => ''}; 
                                                recordFalied = true;
                                            }
                                        } else if (field == namespace + 'Referenceability_Status__c') {
                                            
                                            if (isReferenceProgramMember && status.toLowerCase().trim() != 'active' && status.toLowerCase().trim() != 'caution' && status.toLowerCase().trim() != 'inactive') { 
                                                
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Reference Status should be Active or Caution.', 'data' => ''}; 
                                                recordFalied = true;
                                            } else {
                                                rbi.put(field, getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), String.valueOf(refRecord.get(field))));
                                            }
                                        } else if (field == namespace + 'Roll_up_Attributes_to_All_Accounts__c'
                                                    || field == namespace + 'Roll_up_Attributes_to_Primary_Account__c'
                                                    || field == namespace + 'Roll_up_Referenceability_to_All_Accounts__c'
                                                    || field == namespace + 'Roll_up_Referenceability_to_Primary_Acc__c'
                                                    || field == namespace + 'Inherit_Attributes_from_All_Accounts__c'
                                                    || field == namespace + 'Inherit_Attributes_from_Primary_Account__c') {
                                            
                                            if ((rbi.Contact__c == null || String.valueOf(rbi.Contact__c) == '') && ((rbi.Id != null && String.valueOf(rbi.Id) != '') || !(refRecord.get(namespace + 'Contact__c') != null && String.valueOf(refRecord.get(namespace + 'Contact__c')) != '')) && refRecord.get(field) != null && String.valueOf(refRecord.get(field)) != '' && !String.valueOf(refRecord.get(field)).equalsIgnoreCase('false')) {
                                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => field.removeEnd('__c').replace('_',' ') + ' not Updatable On Account Reference Profile', 'data' => ''}; 
                                                recordFalied = true;
                                            } else {
                                                rbi.put(field, getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), String.valueOf(refRecord.get(field))));
                                            }
                                        } else {
                                            rbi.put(field, getInType(String.valueOf(fieldMap.get(field).getDescribe().getType()), String.valueOf(refRecord.get(field))));
                                        }                                 
                                    }                                   
                                }
                            }
                        }        
                    }
                } 
            }
            Database.UpsertResult result ;
            
            if (!recordFalied && objectName != 'Reference_Request__c') {
                
                if (objectName == 'Reference_Content__c') {
                    result = Database.upsert(refContent, false);
                } else if (objectName == 'Reference_Basic_Information__c') {
                    result = Database.upsert(rbi, false);
                } 
               
            
                //Insert Content Attributes For Ref Content
                if (result.isSuccess()) {
                    
                    if (refContent != null) {
                        List<Content_Attribute__c> contentAttList = new List<Content_Attribute__c>();
                        String errorIdsList = '';
                        
                        if (result.isSuccess() && attribueIdsList != null && attribueIdsList.size() > 0) {
                            Map<Id,Attribute__c> attrMap = new Map<Id,Attribute__c>();
                            List<String> tempAttrtIdsList = new List<String>();
                            
                            //re REF-1660 Just remove extra space.
                            for (String str : attribueIdsList) {
                                tempAttrtIdsList.add(str.trim());
                            }

                            attrMap = new Map<Id,Attribute__c>([SELECT Id from Attribute__c WHERE Id IN :tempAttrtIdsList]);
                         
                            for (String id : attribueIdsList) {
                                id = id.trim();
                                                        
                                if (id != '') { 
                                    
                                    if (!attrMap.keySet().contains(id.trim())) {  
                                        errorIdsList = errorIdsList == '' ? id : errorIdsList + ',' + id;                                
                                        recordFalied = true;   
                                        break;                                  
                                    } else {            
                                        Content_Attribute__c contentAtt = new Content_Attribute__c();
                                        contentAtt.Attribute__c = (Id)id;
                                        contentAtt.Reference_Content__c = result.getId();
                                        contentAttList.add(contentAtt);
                                    }
                                }
                            }                   
                        } 
                         
                        if (recordFalied) { 
                            resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Attribute Ids:' + errorIdsList, 'data' => ''};
                            // REF-1661 : Rollback the record updation or creation in case of any validation error.
                            Database.rollback(sv); 
                        } else { 
                            Database.SaveResult[] resultsContentAttributes = Database.insert(contentAttList, false);
                            resultReturn.put('success','true');
                            resultReturn.put('value',result.getId());
                        }
                          
                        /*REF-1557 - Check case for Associated Accounts for contnet*/ 
                        List<Account_Reference_Content__c> accContentsList = new List<Account_Reference_Content__c>();
                        errorIdsList = '';
                        Boolean isAccountRecordFailed = false;

                        if (recordFalied == false && result.isSuccess() && accountIdsList != null && accountIdsList.size() > 0) { 
                            Set<Id> accIdsSet = new Set<Id>();
                            Map<Id,Account> accMap = new Map<Id,Account>();
                            Map<Id,Account> newAccMap = new Map<Id,Account>();
                            List<String> tempaccountIdsList = new List<String>();
                            
                            //re REF-1660 Just remove extra space.
                            for (String str : accountIdsList) {
                                tempaccountIdsList.add(str.trim());
                            }


                            accMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :tempaccountIdsList]); 
                             
                            newAccMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :tempaccountIdsList 
                                                            AND Id NOT IN (SELECT Account__c FROM Account_Reference_Content__c 
                                                            WHERE Reference_Content__c =:refContent.Id)]);
                            
                            for (String id : accountIdsList) {
                                id = id.trim();
                                
                                if (id != '') { 
                                    
                                    if (!accMap.keySet().contains(id)) {  
                                        errorIdsList = errorIdsList == '' ? id : errorIdsList + ',' + id;                                
                                        isAccountRecordFailed = true;   
                                        break;                                  
                                    } else if (newAccMap.keySet().contains(id)) {                                                
                                        Account_Reference_Content__c  accContent = new Account_Reference_Content__c();
                                        accContent.Account__c = (Id)id;
                                        accContent.Reference_Content__c = result.getId();
                                        accContentsList.add(accContent); 
                                    }
                                } 
                            }   

                            if (isAccountRecordFailed) {
                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Account Ids:' + errorIdsList, 'data' => ''};
                                // REF-1661 : Rollback the record updation or creation in case of any validation error.
                                Database.rollback(sv); 
                            } else {
                                Database.SaveResult[] resultsContentAccounts = Database.insert(accContentsList, false);
                                resultReturn.put('success','true');
                                resultReturn.put('value',result.getId()); 
                            }  
                        } 
                        
                    } else if (rbi != null) {  
                        List<Referenceability__c> accountRefList = new List<Referenceability__c>();
                        String errorIdsList = ''; 
                        Set<Id> setRefIds = new Set<Id>(); 
                        
                        //Insert Account/Contact Attributes In the RBI
                        List<Contact_Attribute__c> contactAttList = new List<Contact_Attribute__c>();
                        List<Account_Attribute__c> accountAttList = new List<Account_Attribute__c>(); 
                        List<String> tempAttrtIdsList = new List<String>();

                        if (result.isSuccess() && attribueIdsList != null && attribueIdsList.size() > 0) { 
                            Map<Id,Attribute__c> attrMap = new Map<Id,Attribute__c>();
                            Set <String> setAttributId = new Set<String>();
                            
                            //re REF-1660 Just remove extra space. 
                            for (String str : attribueIdsList) {
                                if (str.trim() != '') {
                                    tempAttrtIdsList.add(str.trim());
                                }
                            }

                            //REF-1823 -  set 15 digit Ids 
                            for (Attribute__c att : [SELECT Id from Attribute__c WHERE Id IN :tempAttrtIdsList]) {
                                setAttributId.add(String.valueOf(att.Id).substring(0,15)); 
                            }
                            
                            for (String id : tempAttrtIdsList) {
                                id = id.trim().length() > 15 ? id.trim().substring(0,15) : id.trim();
                                                        
                                if (id != '') {  
                                    
                                    if (!setAttributId.contains(id)) {  
                                        errorIdsList = errorIdsList == '' ? id : errorIdsList + ',' + id;                                
                                        recordFalied = true;     
                                        break;                               
                                    } else {  

                                        if (rbi.Contact__c != null && String.valueOf(rbi.Contact__c) != '') {          
                                            Contact_Attribute__c contactAtt = new Contact_Attribute__c();
                                            contactAtt.Attribute__c = (Id)id;
                                            contactAtt.Account__c = rbi.Account__c;
                                            contactAtt.Contact__c = rbi.Contact__c; 
                                            contactAttList.add(contactAtt);
                                        } else { 
                                            Account_Attribute__c accountAtt = new Account_Attribute__c();
                                            accountAtt.Attribute__c = (Id)id;
                                            accountAtt.Account__c = rbi.Account__c;
                                            accountAttList.add(accountAtt);
                                        }
                                    }
                                }
                            }                   
                        }
                        
                        if (recordFalied) { 
                            resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid Attribute Ids:' + errorIdsList, 'data' => ''};
                            // REF-1661 : Rollback the record updation or creation in case of any validation error.
                            Database.rollback(sv);
                            
                        } else {
                            List<sObject> dalaList = new List<sObject>();
                            dalaList.addAll((List<sObject>)contactAttList);
                            dalaList.addAll((List<sObject>)accountAttList);
                            Database.SaveResult[] resultsContentAttributes = Database.insert(dalaList, false);
                            resultReturn.put('success','true');
                            resultReturn.put('value',result.getId()); 
                        } 
                          
                        if (!recordFalied && result.isSuccess() && refTypeIds != null && refTypeIds.size() > 0) {  

                            for (Referenceability__c ref : [SELECT Referenceability_Type__c FROM Referenceability__c 
                                                                    WHERE Account__c =:rbi.Account__c AND Contact__c =:rbi.Contact__c]){  
                                setRefIds.add(ref.Referenceability_Type__c); 
                            }
                             
                            for (String id : refTypeIds) {
                                id = id.trim().length() > 15 ? id.trim().substring(0,15) : id.trim();
                             
                                if (mapRefType.containsKey(id)) {
                                    
                                    if (!setRefIds.contains(id.trim())) {
                                        Referenceability__c ref = new Referenceability__c();
                                        ref.Account__c = rbi.Account__c;                                
                                        ref.Status__c = 'Approved'; 
                                        ref.Verified__c = Date.today();
                                        ref.Referenceability_Type__c = id;
                                        
                                        if (rbi.Contact__c != null && String.valueOf(rbi.Contact__c) != '') {
                                            ref.Contact__c = rbi.Contact__c;                                                 
                                        }
                                        accountRefList.add(ref);
                                    } 
                                } else {
                                    errorIdsList = errorIdsList == '' ? id : errorIdsList + ',' + id;                                
                                    recordFalied = true;  
                                    break; 
                                }
                            }   

                            if (recordFalied) {  
                                resultReturn = new Map<String,String>{'success' => 'false', 'value' => 'Invalid or Unavailable Referenceability Type Ids:' + errorIdsList, 'data' => ''};
                                // REF-1661 : Rollback the record updation or creation in case of any validation error.
                                Database.rollback(sv); 
                            } else {
                                Database.SaveResult[] resultsAccountRefType = Database.insert(accountRefList, false);
                                resultReturn = new Map<String,String>{'success' => 'true', 'value' => result.getId()};
                            }                
                        }    
                    }
                } else {
                Database.rollback(sv);
                resultReturn = new Map<String,String>{'success' => 'false', 'value' => CRUDAndFLSCheckController.getCleanSystemErrorMsg(result.getErrors()[0].getMessage()), 'data' => ''};             
                }
            }
            return resultReturn;
        } catch (Exception e) { 
            Database.rollback(sv);  
            return new Map<String,String>{'success' => 'false', 'value' => CRUDAndFLSCheckController.getCleanSystemErrorMsg(e.getMessage()), 'data' => ''};
        }
    }
    
    /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ Get details for reference fields 
​ ​ ​ ​ ​*​ ​  @args​  :​ ​​String objectName - Specific Object
​ ​ ​ ​ ​*​ ​ ​ @return :​  ReferenceTypeFieldsWrapper
    *   @Modified By: Rajesh
​ ​ ​ ​ ​**/
    @RemoteAction
    public static List<ReferenceTypeFieldsWrapper> getReferenceFields(String objectName) { 
        List<ReferenceTypeFieldsWrapper> availableFields = new List<ReferenceTypeFieldsWrapper>();
        String namespace = UtilityController.appNamespace();

        if (objectName == namespace + 'Library_ID__c') {
            
            for (ContentWorkspace cw : [SELECT Id, Name FROM ContentWorkspace LIMIT :limits.getLimitQueryRows()]) {
                 availableFields.add(new ReferenceTypeFieldsWrapper(cw.Id,cw.Name));
            }
        } else if (objectName == namespace + 'Language__c') {
            Schema.DescribeFieldResult field = Reference_Content__c.Language__c.getDescribe();  
            List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
        
            for (Schema.PicklistEntry picklistValue : picklistValues) {  
                availableFields.add(new ReferenceTypeFieldsWrapper(picklistValue.getValue(),picklistValue.getLabel())); 
            } 
        } else if (objectName == namespace + 'Referenceability__c') {
            for (Referenceability_Type__c ref : [SELECT Id, Name, Referenceability_Type__c, Referenceability_no__c FROM Referenceability_Type__c 
                                                                        WHERE Referenceability_no__c != null AND Referenceability_Type__c = true AND Visible__c = true AND Sales_Reward__c = false]) {
                availableFields.add(new ReferenceTypeFieldsWrapper(ref.Id, ref.Name));
            }
        } else { 
            
            for (Reference_Content_Type__c rc : [SELECT Id, Name__c FROM Reference_Content_Type__c
                                                    WHERE Active__c = true AND  Recorded_Reference_Type__c = false 
                                                    ORDER BY Name__c LIMIT :limits.getLimitQueryRows()]) {
                availableFields.add(new ReferenceTypeFieldsWrapper(rc.Id, rc.Name__c));
            }
        }
          
        return availableFields; 
    } 
    
   /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to get Referenceability Type code on the basis of ReferenceabilityType Ids
    *​ ​  @args​  :​ ​String refType: String with comma seprated referenceability Ids, Map mapRefType : With Ref Code with Ids
​ ​ ​ ​ ​*​ ​ ​ @return :​ Return String with comma ref Code Ids
    *   @Modified By: Rajesh
    *   @Reference Ticket Number: #1126 
​ ​ ​ ​ ​**/
    public static String getReferenceabilityTypeCode(String refType, Map<String, String> mapRefType) { 
        String refTypeIds = '';  
        List<String> refCodeValues = refType.split(',');
            
        for (String code : refCodeValues) { 
            code = (code.length() > 15 ) ? code.substring(0,15) : code; 
            refTypeIds += (mapRefType != null) ? ((mapRefType.containsKey(code.trim()) ? 'R'+ mapRefType.get(code.trim()) + 'R' : '') + ',') : '';  
        }    
        return refTypeIds.removeEnd(',');
    }
    
   /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to get List OF Objects For Import. 
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning List<Map<String,String>> with object lable and name.
    *   @Modified By: Dixita @Jan/05/2018
    *   @Reference Ticket Number: #1262 
​ ​ ​ ​ ​**/       
    @RemoteAction
    public static List<Map<String,String>> getImportObjects() {
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        List<String> importObjectsNames = new List<String>();
        List<Map<String,String>> importObjects = new List<Map<String,String>>();
        
        if (cs.Import_Object__c == null || cs.Import_Object__c == '') {
                cs.Import_Object__c = '';
                
                if (cs.Import_Objects__c != null && cs.Import_Objects__c != '') {
                    List<String> existingVal = cs.Import_Objects__c.split(';'); 
                    
                    for (String val : existingVal) {
                        cs.Import_Object__c = cs.Import_Object__c + val + ',';
                    }
                    cs.Import_Objects__c = '';
            }
        }
         
        if (cs.Import_Object__c != null && cs.Import_Object__c!= '') {
            importObjectsNames = cs.Import_Object__c.split(','); 
            importObjectsNames.sort();

            for (String names : importObjectsNames) {
                importObjects.add(new Map<String,String>{'label' => UtilityController.getAvailableObjects().get('import').get(names), 'apiName' => names});
            } 
        }
        return importObjects;
    }
    
   /**
​ ​ ​ ​ ​*​ ​  @description​ ​:​ ​This​ ​method​ ​used to get List oF Objects For Export.
​ ​ ​ ​ ​*​ ​  @args​  :​ ​Map<String,Object> containing map with uploaded reords,​ ​String objectName - Specific Object
​ ​ ​ ​ ​*​ ​ ​ @return :​ returning map with uploaded records.
    *   @Modified By: Dixita @Jan/05/2018
​ ​ ​ ​ ​**/   
    @RemoteAction
    public static List<Map<String,String>> getExportObjects() {        
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        List<String> exportObjectsNames = new List<String>();
        List<Map<String,String>> exportObjects = new List<Map<String,String>>();
        
        if (cs.Export_Object__c == null || cs.Export_Object__c == '') {
            cs.Export_Object__c = '';
        } else {
            cs.Export_Object__c += ',' ;
        }
        if (cs.Export_Objects__c != null && cs.Export_Objects__c != '') {
            List<String> existingVal = cs.Export_Objects__c.split(','); 
            
            for (String val : existingVal) {
                cs.Export_Object__c = cs.Export_Object__c + val + ',';
            }
            cs.Export_Objects__c = '';
        }
        cs.Export_Object__c = cs.Export_Object__c.removeEnd(',');
        if (cs.Export_Object__c != null && cs.Export_Object__c!= '') {
            exportObjectsNames = cs.Export_Object__c.split(','); 
            exportObjectsNames.sort();
        
            for (String names : exportObjectsNames) {
                exportObjects.add(new Map<String,String>{'label' => UtilityController.getAvailableObjects().get('export').get(names), 'apiName' => names});
            }
        }
        return exportObjects;
    }
}