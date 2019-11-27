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
@isTest(seeAllData = false)
public with sharing class TestAddNewReferenceContentController {

    public static User u;
    public static Profile p;
    public static Blob blobfile;
    public static ContentVersion cv;
    public static String fileName;
    public static Reference_Content__c referObject;
    public static Reference_Content_Type__c customRefContent;
    
    public static list < Reference_Type_Mapping__c > rtmapping;
    //public static Reference_Content_Type__c refConType;
    public static AddNewReferenceContentController controllerObj;
    
    //Test Method
    /*static testMethod void testSaveContentMethod() {
        CreateUser();
        //Start test Method
        test.startTest();
        system.runAs(u) {
            referObject = new Reference_Content__c();
            referObject.Title__c = 'text';
            referObject.Search_Terms_keywords__c = 'test';
            cv = UploadContentVersion();
            ApexPages.StandardController controller = new ApexPages.StandardController(referObject);
            controllerObj = new AddNewReferenceContentController(controller);
            controllerObj.newfile = createFile();
            controllerObj.newFileName = 'text';
            controllerObj.LibraryId = u.Id;
            
            //controllerObj.referContent.Content_Type__c='000000000000000';
            
            controllerObj.saveContent();
            controllerObj.selectedcontentName = 'First';
            controllerObj.findContentVersionDetails();
            system.assertEquals(referObject.Title__c, 'text');
        }
        //Stop test Method
        test.stopTest();
    }*/
    static testMethod void testSaveContentMethodForNewForCustomRefContent(){
    	CreateUser();
    	test.startTest();
        system.runAs(u) {
        	POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        	insert cs;
        	cv = UploadContentVersion();
        	createReferObject();
        	rtmapping = createReferenceTypeMapping();
            insert rtmapping;
        	ApexPages.StandardController controller = new ApexPages.StandardController(new Reference_Content__c());
        	controllerObj = new AddNewReferenceContentController(controller);
        	controllerObj.customReferenceContentTypeId = customRefContent.Id;
        	controllerObj.CustomRefContent = true;
        	controllerObj.showCustomContentFields();
        	controllerObj.saveContent();
        	controllerObj.selectedcontentName = 'test';
        	controllerObj.findContentVersionDetails();
        	 system.assertEquals(controllerObj.selectedcontentName, 'test');
        }
        test.stopTest();
    }
    static testMethod void testSaveContentMethodForNewForCustomContent(){
    	CreateUser();
    	test.startTest();
        system.runAs(u) {
        	POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        	insert cs;
        	cv = UploadContentVersion();
        	createReferObject();
        	ApexPages.StandardController controller = new ApexPages.StandardController(new Reference_Content__c());
        	controllerObj = new AddNewReferenceContentController(controller);
        	controllerObj.customReferenceContentTypeId = customRefContent.Id;
        	controllerObj.CustomRefContent = false;
        	controllerObj.newfile = createFile();
            controllerObj.newFileName = 'text';
            controllerObj.LibraryId = u.Id;
            controllerObj.selectedcontentName = 'First Content Version';
        	controllerObj.saveContent();
        	 system.assertEquals(controllerObj.selectedcontentName, 'First Content Version');
        }
        test.stopTest();
    }
    //Test Method
    static testMethod void testSaveContentMethodForEdit() {
        CreateUser();
        //Start Test method
        test.startTest();
        system.runAs(u) {
        	POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        	insert cs;
            cv = UploadContentVersion();
            insert cv;
            referObject = createReferObject();
            rtmapping = createReferenceTypeMapping();
            insert rtmapping;
            ApexPages.StandardController controller = new ApexPages.StandardController(referObject);
            controllerObj = new AddNewReferenceContentController(controller);
            controllerObj.customReferenceContentTypeId = customRefContent.Id ;
            controllerObj.CustomRefContent = false;
            controllerObj.saveContent();
            system.assertEquals(referObject.Title__c, 'tempObj');
            //for no document attached
          /*  cv = UploadContentVersion();
            insert cv;
            referObject = createReferObject();
            controller = new ApexPages.StandardController(referObject);
            controllerObj = new AddNewReferenceContentController(controller);
            controllerObj.LibraryId = u.Id;
            controllerObj.selectedcontentName = 'First Content Version';
            controllerObj.saveContent();
            cv = UploadContentVersion();
            insert cv;
            referObject = createReferObject();
            controller = new ApexPages.StandardController(referObject);
            controllerObj = new AddNewReferenceContentController(controller);
            controllerObj.selectedcontentName = 'First Content Version';
            controllerObj.changeLibraryOptions();
            controllerObj.saveContent();*/
        }
        //Stop test Method
        test.stopTest();
    }
    //Craetion of user
    private static void CreateUser() {
        p = [select id from profile where name like '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
    }
    //Method to Upload Content Version
    private static ContentVersion UploadContentVersion() {
        cv = new ContentVersion();
        cv.VersionData = createFile();
        cv.PathOnClient = 'text';
        cv.FirstPublishLocationId = u.Id;
        cv.Title = 'First Content Version';
        return cv;
    }
    //Creation of file
    private static Blob createFile() {
        string file = 'Testing base 64 encode';
        Blob blobfile1 = Blob.valueOf(file);
        return blobfile1;
    }
    static list < Reference_Type_Mapping__c > createReferenceTypeMapping() {
        list < Reference_Type_Mapping__c > tempRefMapping = new list < Reference_Type_Mapping__c > ();
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Reference_Content_Type__c = customRefContent.Id, Name = 'OwnerId'));
        return tempRefMapping;
    }
    //Creation of Reference_Content record
    private static Reference_Content__c createReferObject() {
        customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c= true);
        insert customRefContent;
        Reference_Content__c tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c= customRefContent.Id,Custom_Reference_Content__c = true);
        insert tempObj;
        return tempObj;
    }
    
    //private static Reference_Content_Type__c createRefContentTypeObject() {
        
        //return tempObj;
    //}
    static testMethod void testCustomContentFields(){
       CreateUser();
    	test.startTest();
        system.runAs(u) {
        	POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
        	insert cs;
        	cv = UploadContentVersion();
            insert cv;
            list < ContentDocument > contentDocumnts = [select Id from ContentDocument where LatestPublishedVersionId = : cv.Id];
            System.debug('contentDocumnts : '+contentDocumnts);
            Reference_Content__c rc=createReferObject();
            customRefContent.Recorded_Reference_Type__c=false;
            update customRefContent;
            rc.Content_ID__c=cv.id;
            rc.Content_URL__c='/';
            update rc;
            //System.debug('rc : '+rc+' cv: '+cv);
        	ApexPages.StandardController controller = new ApexPages.StandardController(rc);
            customRefContent.Recorded_Reference_Type__c=true;
        	controllerObj = new AddNewReferenceContentController(controller);
        	controllerObj.customReferenceContentTypeId = null;
        	controllerObj.CustomRefContent = false;
           	//if new file is null
        	controllerObj.newfile = null;//createFile();
            controllerObj.newFileName = 'text';
            controllerObj.LibraryId = u.Id;
            controllerObj.selectedcontentName = 'First Content Version';
            controllerObj.changeLibraryOptions();
        	controllerObj.saveContent();
            controllerObj.showCustomContentFields();
            controllerObj.referContent.Internal_Use__c=true;
            controllerObj.hideSocialSharing();
            system.assertEquals(true, controllerObj.internalUse);
            // if customReferenceContentTypeId not null butRecorded_Reference_Type__c is true
            //if new file is null
            
        	controllerObj.newfile = null;//createFile();
            controllerObj.newFileName =null;// 'text';
            controllerObj.customReferenceContentTypeId = customRefContent.Id;
            controllerObj.referContent.Internal_Use__c=false;
            customRefContent.Recorded_Reference_Type__c=true;
            controllerObj.RecordedRefContent=false;
            system.assertEquals(false, controllerObj.RecordedRefContent);
            controllerObj.showCustomContentFields();
            controllerObj.hideSocialSharing();
            system.assertEquals(false, controllerObj.internalUse);
			system.assertEquals(controllerObj.selectedcontentName, 'First Content Version');
        }
        test.stopTest();
    }
}