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
 * Class: TestFetchFileController
 * Description: class to test AND cover FetchFileController
 * Created by: Rajesh @8 Dec 2017
 */
@isTest
    /**
     * Method to create page load data and set properties
     * Created By: Dixita
     */
    public with sharing class TestFetchFileController {    
        public static User u;
        public static Profile p;
        public static Custom_Settings__c cs;
        public static FetchFileController ffc;
        private static List<Attribute__c> attrList; 
        private static List<sObject> refList;
        private static Reference_Content_Type__c refType ;
        private static ContentVersion cv ;
        private static Reference_Content_Type__c inActiveRefType;
        private static User cw;
        private static void CreateUser() {
            p = [select id from profile where name like '%System Admin%'];
            u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
                         emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
                         localesidkey = 'en_US', profileid = p.Id,
                         timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
            insert u;
    }
    
    /**
     * Method to create Data Mapping
     * Created By: Dixita
     
    private static void createDataMapping(String objName) {        
        Map<String, Schema.SObjectType> gd = CRUDAndFLSCheckController.sObjectsMap;
        Schema.SObjectType objType = gd.get(UtilityController.appNamespace() + objName);
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map <String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Data_Mapping__c> fieldList = new List<Data_Mapping__c>();
        Integer count = 5 ;
        Integer countImp = 1;
        for (String fieldName : fieldMap.keySet()) {
            Schema.DescribeFieldResult field = fieldMap.get(fieldName).getDescribe();
            Data_Mapping__c dlMappingTemp = new Data_Mapping__c();
            
            if ((field.isCreateable() && field.isAccessible()) || field.getName() == 'Id') {  
                
                if (field.getName() == 'Id' || field.getName() == UtilityController.appNamespace() + 'Content_URL__c' || field.getName() == UtilityController.appNamespace() + 'Attributes__c' ||
                        field.getName() == UtilityController.appNamespace() + 'Library_ID__c' || field.getName() == UtilityController.appNamespace() + 'Reference_Content_Type__c' || 
                        field.getName() == UtilityController.appNamespace() + 'Attribute_Ids__c' ||
                        (field.isCreateable() && !field.isNillable() && !field.isDefaultedOnCreate())) {
                    dlMappingTemp.Required__c = true;
                    dlMappingTemp.Visible__c = true;
                    dlMappingTemp.Order__c = countImp++;  
                    
                } else if (field.getName() == UtilityController.appNamespace() + 'Language__c') {
                    dlMappingTemp.Required__c = false;
                    dlMappingTemp.Visible__c = false;                     
                } else {
                    dlMappingTemp.Required__c = false;
                    dlMappingTemp.Visible__c = true;
                    dlMappingTemp.Order__c = count++;                    
                }
                
                dlMappingTemp.Object__c = 'DM' + objName;
                dlMappingTemp.Label__c = field.getLabel();
                dlMappingTemp.Field_API_Name__c= field.getName();
                fieldList.add(dlMappingTemp);          
            }
        }
        insert fieldList;
    }*/
    
    @TestSetup
    public static void initData () {
        cs = TestDataFactory.createCustomSetting();    
        System.assertNotEquals(null,cs.id);         
    }

    /**
     * Method to test Create for RefContent
     * Created By: Dixita
     */
    public static testMethod void testForRefContent() {        
        CreateUser();
        test.startTest();
        system.runAs(u) {
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            cs.Export_Objects__c = 'Account';
            update cs;
            FetchFileController.getExportObjects();
            ffc = new FetchFileController();
            Data_Mapping__c dlMappingCV = new Data_Mapping__c();
            dlMappingCV.Required__c = false;
            dlMappingCV.Visible__c = true;
            dlMappingCV.Order__c = 3; 
            dlMappingCV.Object__c = 'DataLoaderFields';
            dlMappingCV.Label__c = 'Content URL';
            dlMappingCV.Field_API_Name__c = UtilityController.appNamespace() + 'Content_URL__c';
            ConstantsController.shouldDataMappingProcessed = true;
            insert dlMappingCV;
            FetchFileController.getFields('Reference_Content__c','false');
            FetchFileController.getFields('Reference_Content__c','false');
            FetchFileController.getFields('Account_with_Attributes__c','false');
            FetchFileController.getFields('Content_with_Attributes__c','false');
            FetchFileController.getFields('Contact_with_Attributes__c','false');
            FetchFileController.getFields('Reference_Content__c','true');
            FetchFileController.getFields('Reference_Content__c','false');
            FetchFileController.getFields('Reference_Basic_Information__c','false');
            FetchFileController.getFields('Attribute__c','false');
            FetchFileController.getFields('Reference_Request__c','false');
            System.assertEquals(dlMappingCV != null, true);
        }
        test.stopTest();
    }
    
    /**
     * Method to test Initialize RefId List For RefContent
     * Created By: Dixita
    */
    public static testMethod void testInitializeRefIdListForRefContent() {        
        CreateUser();
        test.startTest();
        system.runAs(u) {
            UtilityController.fetchData('Reference_Content__c');
            Data_Mapping__c attdmRecord = new Data_Mapping__c(Required__c = false,Visible__c = true,Object__c = 'DMReference_Content__c',Label__c = 'Attributes',Field_API_Name__c = UtilityController.appNamespace() + 'Attribute_Ids__c');
            ConstantsController.shouldDataMappingProcessed = true; 
            insert attdmRecord;
            
            ffc = new FetchFileController();
            System.assertNotEquals(null, FetchFileController.getDateFormat());
            ffc.totalRecordCountString = '12';
            ffc.setTotalCount();
            Custom_Settings__c cs = UtilityController.getCustomSettings();
            cs.Export_Object__c = 'Account';
            update cs;
            FetchFileController.getImportObjects();
            FetchFileController.getExportObjects();
            List<FetchFileController.FieldDetailsWrapper> fields = FetchFileController.getFields('Reference_Content__c','false');
            List<String> mappedFields = new List<String>();
            cv = TestDataFactory.createContentVersion(u);
            insert cv;
            
            refType = TestDataFactory.createContentType();               
            insert refType;
            inActiveRefType = TestDataFactory.createContentType();
            inActiveRefType.Name__c = 'inActiveRefType';
            inActiveRefType.Active__c = false;
            insert inActiveRefType;
            
            attrList = TestDataFactory.createAttribute();
            insert attrList;             
            
            refList = TestDataFactory.createReferenceContent();
            Reference_Content__c refCAttr = TestDataFactory.createReferenceContent().get(0);
            refCAttr.Attributes__c = attrList.get(1).Id + '';
            refList.add(refCAttr);
            insert refList;  
            
            cw = u;
            
            for (FetchFileController.FieldDetailsWrapper fieldInstance : fields) {
                mappedFields.add(fieldInstance.apiName);
            }
            String idField = mappedFields.remove(0);
            System.assertEquals(true, FetchFileController.checkPermissions(mappedFields, 'Reference_Content__c') == 'true:');
            mappedFields.add(idField);
            List<Map<String,Object>> refRecordList = createRefRecord(mappedFields);
            List<Map<String,String>> resultList = new List<Map<String,String>>();
            ffc.idListString = '';
            Integer indexSuccess = -1;
            Map<String,Map<String,String>> idListMap = new Map<String,Map<String,String>>();
            List<List<String>> errorList = new List<List<String>>();
            List<String> errorString = new List<String>();
            errorString.add('Error');
            
            for (String keys : refRecordList.get(0).keySet()) {
                errorString.add(keys);
            }  
            errorList.add(errorString); 
            
            for (Integer index = 0; index < refRecordList.size(); index++) {
                Map<String,String> result = FetchFileController.insertRecords(refRecordList.get(index), 'Reference_Content__c');   
                              
                if ((result.get('success') == 'true') && ( refRecordList.get(index).get(UtilityController.appNamespace() + 'Content_URL__c') == null || String.valueOf(refRecordList.get(index).get(UtilityController.appNamespace() + 'Content_URL__c')).trim() == '')) {
                    idListMap.put(result.get('value').trim() , new Map<String,String>{'isNew' => 'true','data' => JSON.serialize(new ContentVersion())});
                    indexSuccess = ffc.idListString.split(',').size() - 1;
                }
                resultList.add(result);
                errorString = new List<String>();
                errorString.add(result.get('value'));
                for (String key :  refRecordList.get(index).keySet()){
                    errorString.add(String.valueOf(refRecordList.get(index).get(key)));
                }
                errorList.add(errorString);
            } 
            ffc.idListString = JSON.serialize(idListMap);
            ffc.errorString = JSON.serialize(errorList);
            ffc.objectName = 'Reference_Content__c';
            ffc.initializeRefIdList();
            if (indexSuccess >= 0) {
                ffc.refToContent.get(indexSuccess).fileName = 'testFile2';       
                ffc.refToContent.get(indexSuccess).contentData = TestDataFactory.createFile();                 
                //ffc.refToContent.get(indexSuccess - 1).contentData = TestDataFactory.createFile();
                //ffc.refToContent.get(indexSuccess - 1).fileName = 'testFile2';
            }
            ffc.insertContent();   
            ffc.idListString = '';
            ffc.initializeRefIdList();
        }
        system.runAs(u) {
            List<Data_Mapping__c> delList = [SELECT Name, Id, Required__c, Label__c, Visible__c, Field_API_Name__c FROM Data_Mapping__c WHERE Object__c = 'DataLoaderFields'];
            ConstantsController.shouldDataMappingProcessed = true;
            delete delList;
            ffc = new FetchFileController();
        }
        test.stopTest();
        
    }
    
    /**
     * Method to test Initialize for Reference Profile
     * Created By: Rajesh
     */
    public static testMethod void testInitializeRBI() {  
        CreateUser();
        test.startTest();
        FetchFileController.getFields('Reference_Content__c', 'false');
        FetchFileController.getFields('Reference_Basic_Information__c', 'false');
        system.runAs(u) {
            ffc = new FetchFileController();
            ffc.totalRecordCountString = '12';
            UtilityController.fetchData('Reference_Basic_Information__c');
            FetchFileController.getFields('Reference_Content__c','false');
            ffc.setTotalCount();
            List<FetchFileController.FieldDetailsWrapper> fields = FetchFileController.getFields('Reference_Basic_Information__c', 'false');  
            List<String> mappedFields = new List<String>();
            
            for (FetchFileController.FieldDetailsWrapper fieldInstance : fields) {
                mappedFields.add(fieldInstance.apiName);
            }
            String idField = mappedFields.remove(0);
            System.assertEquals(true, FetchFileController.checkPermissions(mappedFields, 'Reference_Basic_Information__c') == 'true:');
            mappedFields.add(idField);
            List<Map<String,Object>> refRecordList = createRBIRecord(mappedFields);
            List<Map<String,String>> resultList = new List<Map<String,String>>();
            ffc.idListString = '';
            Integer indexSuccess = -1;
            
            for (Integer index = 0; index < refRecordList.size(); index++) {
                Map<String,String> result = FetchFileController.insertRecords(refRecordList.get(index), 'Reference_Basic_Information__c');   
                resultList.add(result);
            }   
        }
        system.runAs(u) {
            List<Data_Mapping__c> delList = [SELECT Name, Id, Required__c, Label__c, Visible__c, Field_API_Name__c FROM Data_Mapping__c WHERE Object__c = 'DataLoaderFields'];
            ConstantsController.shouldDataMappingProcessed = true;
            delete delList;
            ffc = new FetchFileController();
            FetchFileController.getFields('Reference_Basic_Information__c', 'false');
        }
        test.stopTest();
    }
    /**
     * Method to create Ref content Record
     * Created By: Dixita
     */
    private static List<Map<String,Object>> createRefRecord(List<String> mappedFields) {         
        List<Map<String,Object>> returnList = new List<Map<String,Object>>();        
        Map<String,Object> refRecord = new Map<String,Object>();    
        //inactive RefId  
        refRecord.put('Id', null);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', null);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', '');        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', 'www.test.com');           
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', inActiveRefType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        refRecord = new Map<String,Object>(); 
        // RefType Name Correct
        refRecord.put('Id', null);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', null);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', '');        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', 'www.test.com');           
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type_Name__c', refType.Name__c);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        refRecord.put('showBrowse',false);
        returnList.add(refRecord);
        // RefType Name InCorrect
        refRecord = new Map<String,Object>(); 
        refRecord.put('Id', null);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', null);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', '');        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', 'www.test.com');           
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type_Name__c', refType.Name__c + 'Invalid');
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        // Library Id invalid 
        refRecord = new Map<String,Object>(); 
        refRecord.put('Id', null);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', '');
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', 'www.test.com');            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', ''); 
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);        
        //date Invalid
        refRecord = new Map<String,Object>(); 
        refRecord.put('Id', null);  
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '19/18/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', 'incorrect data');
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', null );
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', 'www.test.com');            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', '');
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', ''); 
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);  
        refRecord = new Map<String,Object>(); 
        // All ok with Id 
        refRecord.put('Id', refList.get(1).Id);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(0).Id);        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        refRecord.put(UtilityController.appNamespace() + 'Search_Terms_keywords__c', 'English'); 
        refRecord.put(UtilityController.appNamespace() + 'Summary__c', 'English'); 
        returnList.add(refRecord);refRecord = new Map<String,Object>(); 
        // All ok with Id URL
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(0).Id);        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', 'www.data.com');            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        refRecord.put(UtilityController.appNamespace() + 'Search_Terms_keywords__c', 'English'); 
        refRecord.put(UtilityController.appNamespace() + 'Summary__c', 'English'); 
        returnList.add(refRecord);
        refRecord = new Map<String,Object>(); 
        // All ok with Id
        refRecord.put('Id', refList.get(0).Id);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(0).Id);        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', cv.Id); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        refRecord = new Map<String,Object>();   
        //Invalid Id
        refRecord.put('Id', 'InvalidId');
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);        
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(1).Id);
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', 'refType.Id');
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', ''); 
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        refRecord = new Map<String,Object>();
        //Invalid Attribute     
        refRecord.put('Id', '');   
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', 'attrList.get(0).Id');        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id); 
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        //Invalid refTypeId
        refRecord = new Map<String,Object>();
        refRecord.put('Id', null);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Author__c', 'Testing');
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(1).Id);
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', 'refType.Id');
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);   
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        refRecord = new Map<String,Object>(); 
        //All Ok without ID No content Data
        refRecord.put('Id', null);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Author__c', 'Testing');
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(1).Id);
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null);
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        refRecord = new Map<String,Object>();
        //All Ok without ID with Content Data
        refRecord.put('Id', null);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(1).Id);
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        refRecord = new Map<String,Object>(); 
        // All ok with Id with Content Id
        refRecord.put('Id', refList.get(0).Id);
        refRecord.put(UtilityController.appNamespace() + 'Title__c', 'test');
        refRecord.put(UtilityController.appNamespace() + 'Allow_Social_Sharing__c', true);
        refRecord.put(UtilityController.appNamespace() + 'Article_publication_date__c', '9/8/2015');
        refRecord.put(UtilityController.appNamespace() + 'Rating__c', 2);
        refRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', attrList.get(0).Id);        
        refRecord.put(UtilityController.appNamespace() + 'Content_Status__c', 'Active');
        refRecord.put(UtilityController.appNamespace() + 'Content_URL__c', null);            
        refRecord.put(UtilityController.appNamespace() + 'Reference_Content_Type__c', refType.Id);
        refRecord.put(UtilityController.appNamespace() + 'Library_ID__c', cw.Id);  
        refRecord.put(UtilityController.appNamespace() + 'Content_ID__c', null); 
        refRecord.put(UtilityController.appNamespace() + 'Language__c', 'English'); 
        returnList.add(refRecord);
        return returnList;
    }   
       
    /**
     * Method to create RBI Record
     * Created By: Dixita
     */
    private static List<Map<String,Object>> createRBIRecord(List<String> mappedFields) {         
        List<Map<String,Object>> returnList = new List<Map<String,Object>>();        
        Map<String,Object> rbiRecord = new Map<String,Object>();    
        List<Account> lstAccount = TestDataFactory.createAccounts();
        insert lstAccount; 

        List<Contact> lstContact = TestDataFactory.createContactsMore(lstAccount[0]);
        insert lstContact; 
        
        List<Attribute__c> lstAtt = TestDataFactory.createAttribute(); 
        insert lstAtt; 
        
        List<Referenceability_Type__c> lstRefType = TestDataFactory.createReferenceabilityType();
        insert lstRefType;
        
        List<Label__c> lstLbl = TestDataFactory.createLabels();
        insert lstLbl;
        
        List<Reference_Basic_Information__c> lstRBI = TestDataFactory.setUpAccountRBINew(lstAccount);
       
        rbiRecord.put('Id', String.valueof(lstRBI[0].Id));
        rbiRecord.put(UtilityController.appNamespace() + '​Account__c', String.valueof(lstAccount[0].Id));
        rbiRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', String.valueof(lstAtt[0].Id) + ',' + String.valueof(lstAtt[1].Id)); 
        rbiRecord.put(UtilityController.appNamespace() + 'Is_Referenceable__c', true); 
        rbiRecord.put(UtilityController.appNamespace() + 'Label_Ids1__c', String.valueof(lstLbl[0].Id) + ',' + String.valueof(lstLbl[1].Id));
        rbiRecord.put(UtilityController.appNamespace() + 'Reference_Program_Candidate__c', false);           
        rbiRecord.put(UtilityController.appNamespace() + 'ReferenceabilityType_Ids1__c', String.valueof(lstRefType[0].Id) + ',' + String.valueof(lstRefType[1].Id));
        rbiRecord.put(UtilityController.appNamespace() + 'Referenceability_Status__c', 'Active');  
        returnList.add(rbiRecord); 
        rbiRecord = new Map<String,Object>();
        rbiRecord.put('Id', null);
        rbiRecord.put(UtilityController.appNamespace() + '​Account__c', '' + String.valueof(lstAccount[0].Id));
        rbiRecord.put(UtilityController.appNamespace() + 'Contact__c', '' + String.valueof(lstContact[0].Id));
        rbiRecord.put(UtilityController.appNamespace() + 'Attribute_Ids__c', String.valueof(lstAtt[0].Id) + ',' + String.valueof(lstAtt[1].Id)); 
        rbiRecord.put(UtilityController.appNamespace() + 'Is_Referenceable__c', true); 
        rbiRecord.put(UtilityController.appNamespace() + 'Label_Ids1__c', String.valueof(lstLbl[0].Id) + ',' + String.valueof(lstLbl[1].Id));
        rbiRecord.put(UtilityController.appNamespace() + 'Reference_Program_Candidate__c', false);           
        rbiRecord.put(UtilityController.appNamespace() + 'ReferenceabilityType_Ids1__c', String.valueof(lstRefType[0].Id) + ',' + String.valueof(lstRefType[1].Id));
        rbiRecord.put(UtilityController.appNamespace() + 'Referenceability_Status__c', 'Active');  
        returnList.add(rbiRecord);  
        return returnList;
    }      
    /**
     * Method to create Request Record
     * Created By: Dixita
     */
    private static List<Map<String,Object>> createRequestRecord(List<String> mappedFields,Integer count) {         
        List<Map<String,Object>> returnList = new List<Map<String,Object>>();        
        Map<String,Object> requestRecord = new Map<String,Object>();    
        String namespace = UtilityController.appNamespace();
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        cs.Enable_Sales_Rewards_Notification__c = true;
        update cs;
        List<Account> lstAccount = TestDataFactory.createAccounts();
        insert lstAccount;
        List<Opportunity> lstOpp = TestDataFactory.createOpportunity(lstAccount);
        insert lstOpp;
        List<Contact> lstContact = TestDataFactory.createContacts(lstAccount);
        insert lstContact; 
        List<Attribute__c> lstAtt = TestDataFactory.createAttribute(); 
        insert lstAtt; 
        List<Label__c> lstLbl = TestDataFactory.createLabels();
        insert lstLbl;
        Attribute__c noLabelAtt = lstAtt.remove(3);
        List<Attributes_Labels__c> attLabels = TestDataFactory.setUpAttributeLabels(lstLbl,lstAtt);
        List<Referenceability_Type__c> lstRefType = TestDataFactory.createReferenceabilityType();
        lstRefType[1].Visible__c = false;
        insert lstRefType;
        List<Referenceability_Type__c> lstRefTypeUser = TestDataFactory.createUserRewardReferenceabilityType();
        insert lstRefTypeUser;
        Label__c noRefLabel = lstLbl.remove(3);
        List<Reference_Type_Mapping__c> refTypeMapping = TestDataFactory.getReferenceTypeMapping(lstLbl,lstRefType[0]);
        refTypeMapping[1].Required__c = true;
        insert refTypeMapping;

        if (count == 1) {
            // All Correct : No Requester, No Contact, No Att/Labels
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Title__c', 'Basic');
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);//No Account Id provided
            requestRecord.put(namespace + 'Account__c', '');//No Account Id provided
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Contact__c', lstContact[0].Id); 
            requestRecord.put(namespace + 'Feedback_Status__c', 'Invalid Status'); 
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Opportunity__c', lstOpp[0].Id); 
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Title__c', 'Basic');
            requestRecord.put(namespace + 'Contact__c', lstContact[0].Id); 
            requestRecord.put(namespace + 'Feedback_Status__c', 'Use completed - Successful'); 
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Label__c', noRefLabel);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Label__c', lstLbl[3].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Label__c', lstLbl[0].Id);
            requestRecord.put(namespace + 'Attribute__c', noLabelAtt);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Contact__c', 'Invalid Contact Id'); //Invalid Contact Id
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Contact__c', lstContact[2].Id); //Contact Not associate to selected Account
            returnList.add(requestRecord);
        } else if (count == 2) {
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', System.today());
            requestRecord.put(namespace + 'Contact__c', lstContact[0].Id); 
            requestRecord.put(namespace + 'Feedback_Status__c', 'Use completed - Unsuccessful'); 
            requestRecord.put(namespace + 'Feedback_Response__c', 'Use completed - Unsuccessful Response'); 
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Label__c', lstRefType[0].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Label__c', lstLbl[0].Id + ',' + lstLbl[1].Id);
            requestRecord.put(namespace + 'Attribute__c', lstAtt[0].Id + ',' + lstAtt[1].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();//Feedback_Status__c missing
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Contact__c', lstContact[0].Id); 
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Contact__c', lstContact[2].Id); 
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Requester__c', lstRefType[0].Id); //Invalid Requester
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Requester__c', 'Invalid Data'); //Invalid Requester
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[1].Id);//RefType not visible
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);//RefType not visible
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Label__c', '');
            requestRecord.put(namespace + 'Attribute__c', lstAtt[0].Id + ',' + lstAtt[1].Id);
            returnList.add(requestRecord);
        } else {
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Opportunity__c', lstOpp[0].Id); 
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Title__c', 'Basic');
            requestRecord.put(namespace + 'Label__c', lstLbl[0].Id + ',' + lstLbl[1].Id);
            requestRecord.put(namespace + 'Attribute__c', lstAtt[0].Id + ',' + lstAtt[1].Id);
            requestRecord.put(namespace + 'Contact__c', lstContact[0].Id); 
            requestRecord.put(namespace + 'Feedback_Status__c', 'Use completed - Successful'); 
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '19/28/2015');//Invalid Date
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', System.today().addDays(3));//Future Date
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            requestRecord.put(namespace + 'Activity_Date__c', '9/8/2015');
            requestRecord.put(namespace + 'Contact__c', lstContact[0].Id); 
            requestRecord.put(namespace + 'Feedback_Status__c', 'Use completed - Unsuccessful'); //Response missing
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Opportunity__c', lstLbl[0].Id); //Invalid Opportunity
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Opportunity__c', 'invaliddata'); //Invalid Opportunity
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstRefType[0].Id);
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstRefType[0].Id);//Invalid Account Id
            returnList.add(requestRecord);
            requestRecord = new Map<String,Object>();
            requestRecord.put(namespace + 'Reference_Type_Needed__c', lstAccount[0].Id);//Invalid RefType
            requestRecord.put(namespace + 'Requester__c', ''); 
            requestRecord.put(namespace + 'Account__c', lstAccount[0].Id);
            returnList.add(requestRecord);
        }
        return returnList;
    } 
    
    /**
     * Method to test Initialize for Reference Request
     * Created By: Dixita
     */
    public static testMethod void testRefRequest1() {  
        CreateUser();
        test.startTest();
        
        system.runAs(u) {
            /*Custom_Settings__c cs = UtilityController.getCustomSettings();
            cs.Enable_Custom_Data_Loader__c = true;
            update cs;*/
            ffc = new FetchFileController();
            List<Data_Mapping__c> dmRecords = UtilityController.fetchData('Reference_Request__c');
            List<String> mappedFields = new List<String>();
            for (Data_Mapping__c dm : dmRecords) {
                mappedFields.add(dm.Field_API_Name__c);
            }
            System.assertEquals('true:',FetchFileController.checkPermissions(mappedFields,'Reference_Request__c'));
            List<Map<String,Object>> refRecordList = createRequestRecord(mappedFields,1);
            List<Map<String,String>> resultList = new List<Map<String,String>>();
            List<List<String>> errorList = new List<List<String>>();
            for (Integer index = 0; index < refRecordList.size(); index++) {
                Map<String,String> result = FetchFileController.insertRecords(refRecordList.get(index), 'Reference_Request__c');   
                resultList.add(result);
                List<String> errorString = new List<String>();
                errorString.add(result.get('value'));
                for (String key :  refRecordList.get(index).keySet()){
                    errorString.add(String.valueOf(refRecordList.get(index).get(key)));
                }
                errorList.add(errorString);
            } 
            ffc.idListString = '';
            ffc.errorString = JSON.serialize(errorList);
            ffc.objectName = 'Reference_Request__c';
            System.assertNotEquals(null,ffc.initializeRefIdList());
        }
        test.stopTest();
    }
    /**
    * Method to test Initialize for Reference Request
    * Created By: Dixita
    */
    public static testMethod void testRefRequest2() {  
        CreateUser();
        test.startTest();
        
        system.runAs(u) {
            /*Custom_Settings__c cs = UtilityController.getCustomSettings();
            cs.Enable_Custom_Data_Loader__c = true;
            update cs;*/
            ffc = new FetchFileController();
            List<Data_Mapping__c> dmRecords = UtilityController.fetchData('Reference_Request__c');
            List<String> mappedFields = new List<String>();
            for (Data_Mapping__c dm : dmRecords) {
                mappedFields.add(dm.Field_API_Name__c);
            }
            System.assertEquals('true:',FetchFileController.checkPermissions(mappedFields,'Reference_Request__c'));
            List<Map<String,Object>> refRecordList = createRequestRecord(mappedFields,2);
            List<Map<String,String>> resultList = new List<Map<String,String>>();
            List<List<String>> errorList = new List<List<String>>();
            for (Integer index = 0; index < refRecordList.size(); index++) {
                Map<String,String> result = FetchFileController.insertRecords(refRecordList.get(index), 'Reference_Request__c');   
                resultList.add(result);
                List<String> errorString = new List<String>();
                errorString.add(result.get('value'));
                for (String key :  refRecordList.get(index).keySet()){
                    errorString.add(String.valueOf(refRecordList.get(index).get(key)));
                }
                errorList.add(errorString);
            } 
            ffc.idListString = '';
            ffc.errorString = JSON.serialize(errorList);
            ffc.objectName = 'Reference_Request__c';
            System.assertNotEquals(null,ffc.initializeRefIdList());
        }
        test.stopTest();
    }   
    /**
    * Method to test Initialize for Reference Request
    * Created By: Dixita
    */
    public static testMethod void testRefRequest3() {  
        CreateUser();
        test.startTest();
        
        system.runAs(u) {
            /*Custom_Settings__c cs = UtilityController.getCustomSettings();
            cs.Enable_Custom_Data_Loader__c = true;
            update cs;*/
            ffc = new FetchFileController();
            List<Data_Mapping__c> dmRecords = UtilityController.fetchData('Reference_Request__c');
            List<String> mappedFields = new List<String>();
            for (Data_Mapping__c dm : dmRecords) {
                mappedFields.add(dm.Field_API_Name__c);
            }
            System.assertEquals('true:',FetchFileController.checkPermissions(mappedFields,'Reference_Request__c'));
            List<Map<String,Object>> refRecordList = createRequestRecord(mappedFields,3);
            List<Map<String,String>> resultList = new List<Map<String,String>>();
            List<List<String>> errorList = new List<List<String>>();
            for (Integer index = 0; index < refRecordList.size(); index++) {
                Map<String,String> result = FetchFileController.insertRecords(refRecordList.get(index), 'Reference_Request__c');   
                resultList.add(result);
                List<String> errorString = new List<String>();
                errorString.add(result.get('value'));
                for (String key :  refRecordList.get(index).keySet()){
                    errorString.add(String.valueOf(refRecordList.get(index).get(key)));
                }
                errorList.add(errorString);
            } 
            ffc.idListString = '';
            ffc.errorString = JSON.serialize(errorList);
            ffc.objectName = 'Reference_Request__c';
            System.assertNotEquals(null,ffc.initializeRefIdList());
        }
        test.stopTest();
    }     

    /**
     * Method to get reference field
     * Created By: Rajesh REF-1537
     */
     public static testMethod void testGetReferenceFields() {        
        CreateUser(); 
        test.startTest();
        
        system.runAs(u) { 
            List<Reference_Content_Type__c> refConTypes = TestDataFactory.createContentTypes();
            TestDataFactory.createReferenceabilityType();
            FetchFileController.getReferenceFields('Language__c');  
            FetchFileController.getReferenceFields('Library_ID__c'); 
            FetchFileController.getReferenceFields('Referenceability__c');   
            List<Object> obj = FetchFileController.getReferenceFields('Reference_Content_Type__c');
            system.assert(obj.size() > 0);
             
        } 
    } 
}