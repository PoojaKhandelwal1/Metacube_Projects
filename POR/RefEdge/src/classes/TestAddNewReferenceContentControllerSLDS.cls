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
 * Class: AddNewReferenceContentControllerSLDS
 * Description: class to Test AND cover AddNewReferenceContentControllerSLDS
 * Modified by: Rajesh @12 Sept 2017
 */
@isTest(seeAllData = false)
private class TestAddNewReferenceContentControllerSLDS {
	public static User u;
    public static Profile p;
    public static Blob blobfile;
    public static ContentVersion cv;
    public static String fileName;
    public static Reference_Content__c referObject;
    public static Reference_Content_Type__c customRefContent;
	public static AddNewReferenceContentControllerSLDS controllerObj;
	public static Reference_Content__c tempObj; 
	
    /**
     * Method to create User
     */
    private static void CreateUser() {
        p = [select id from profile where name like '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
            system.assertEquals(p.id,u.profileid);
    }
    
    /**
     * Method to create Referece Content and test miscellaneous methods for page load
     */
    public static testMethod void createRefContent() { 
    	// Insert Ref Content 
    	customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
    	insert customRefContent;
    	tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true);
    	insert tempObj;
        
        // For new content record 
        List<AddNewReferenceContentControllerSLDS.PageParameterWrapper> refWrapperList = AddNewReferenceContentControllerSLDS.getPageRecords('', false);
        	
		if (refWrapperList != null) {
			system.assertEquals(refWrapperList.size(), 1);
        }         
        // for existing record 
        refWrapperList = AddNewReferenceContentControllerSLDS.getPageRecords(tempObj.id, false);
        	
		if (refWrapperList != null) {
			system.assertEquals(refWrapperList.size(), 1);
        } 
        
        List<Reference_Content_Type__c> lstContentType = TestDataFactory.createContentTypes();
         
        List<AddNewReferenceContentControllerSLDS.ReferenceContentTypeWrapper> lstCont = AddNewReferenceContentControllerSLDS.getReferenceContentType();
        
        if (lstCont != null) {
			system.assertEquals(lstCont.size(), 5);
        }
        
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        
        List<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        
        List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
        insert refContents;
        
        List<Account_Reference_Content__c> accountContents = TestDataFactory.createAccountRefContents(new List<Account>{accounts[0]}, refContents);
        insert accountContents;
        
        system.assertEquals(AddNewReferenceContentControllerSLDS.saveAssociations(String.Valueof(accounts[0].id),contacts[0].Id, tempObj.Id),'Success'); 
        
        List<AddNewReferenceContentControllerSLDS.AccountWrapper> lst = AddNewReferenceContentControllerSLDS.getAssociatedAccounts(refContents[0].Id);
        
        if (lst != null) {
			system.assertEquals(lst.size(), 1);
        } 
        	
        Contact_Reference_Content__c obj = new Contact_Reference_Content__c(Contact__c = contacts[0].Id, Reference_Content__c = refContents[0].Id);
        insert obj;
        
        List<AddNewReferenceContentControllerSLDS.ContactWrapper> lstCon = AddNewReferenceContentControllerSLDS.getAssociatedContacts(refContents[0].Id);
        
        if (lstCont != null) {
			system.assertEquals(lstCont.size(), 5);
        } 
        
   		system.assertEquals(AddNewReferenceContentControllerSLDS.deleteRecord(String.Valueof(accounts[0].id), 'account'),'Success');         
    	system.assertNotEquals(AddNewReferenceContentControllerSLDS.getDateFormat(),''); 	 
    	system.assertEquals(AddNewReferenceContentControllerSLDS.deleteRecord(String.Valueof(contacts[0].id), 'contact'),'Success'); 
    	//system.assertEquals(controllerObj.dateString, String.valueOf(Date.today())); 
    	Schema.DescribeFieldResult field = Schema.sObjectType.Reference_Content__c.fields.getMap().get(UtilityController.appNamespace() + 'Language__c').getDescribe();  
    	 
 	 	List<Schema.PickListEntry> pickListValues = field.getPickListValues();
 	 	
 	 	system.assertEquals(AddNewReferenceContentControllerSLDS.getLanguage().size(),pickListValues.size()+1);
 	 	
 	 	List<ContentWorkspace> lstwork = [SELECT Id, Name FROM ContentWorkspace];
 	 	
 	 	system.assertEquals(AddNewReferenceContentControllerSLDS.getReferenceLibrary().size(),lstwork.size()+1); 
 	 	
 	 	     
	}
	
	/**
     * Method to test Save Reference Content
     */
	public static testMethod void testSaveReferenceContent() { 
		customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
    	insert customRefContent; 
    	tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true);
    	insert tempObj;
    	
		String jSONString = '{"ContentStatus":"Active","ContentType":"'+customRefContent.Id+'","ContentURL":"www.google.com","ExternalSummery":"Salesforce ","IsAllowingSharing":true,"IsCustomContentType":false,"IsFeatureContent":true,"IsInternalUse":false,"IsReferenceType":false,"Language":"French","LibraryID":"058i0000000aVD1AAM","OldContentURL":"www.google.com","SearchItem":"Salesforce Stack Exchange i","Summery":"Salesforce ","Title":"New Reference Content"}';
 	 	String results = AddNewReferenceContentControllerSLDS.saveReferenceContent(jSONString, false, tempObj.Id, 'Test',true,null);
 	 	 
 	 	system.assertEquals(false, results.contains('Error')); 
 	 	
 	 	// Create Content related value to Clone
 	 	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts; 
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        
 	 	List<Attribute__c> attributes = new List<Attribute__c>{TestDataFactory.createAttribute()[0]};
        insert attributes;
        List<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1,6);
        insert childAttributes;
        List<Attribute__c> childAttributes1 = new List<Attribute__c>();
        childAttributes1.add(childAttributes[0]);
        childAttributes1.add(childAttributes[1]);
        List<Reference_Content__c> lstefContent = new List<Reference_Content__c>();
        lstefContent.add(tempObj);
        
        TestDataFactory.createContentAttributes(lstefContent, childAttributes1); 
        
        Reference_Note__c referNotes = new Reference_Note__c(Note_Date__c = Date.Today(), Account__c = accounts[0].Id, Note__c = 'test Notes');
        insert referNotes;
        
     	Account_Reference_Content__c accountReferObject = new Account_Reference_Content__c(Reference_Content__c = lstefContent[0].Id, Account__c = accounts[0].Id);
        insert accountReferObject;
		
		Contact_Reference_Content__c conReferObject = new Contact_Reference_Content__c(Reference_Content__c = lstefContent[0].Id, Contact__c = contacts[0].id);
		insert conReferObject;		 
		   
 	 	results = AddNewReferenceContentControllerSLDS.saveReferenceContent(jSONString, true, tempObj.Id, 'Test',true,null); 
 	 	 
 	 	system.assertEquals(false, results.contains('Error')); 	  
	}
	
	/**
     * Method to Get Content Details
     */
	public static testMethod void testGetContentDetails() {
	 	User u = TestDataFactory.CreateUser();
		test.startTest(); 
        system.runAs(u) {   
    		ContentVersion contentVersion = new ContentVersion();
    		Schema.SObjectType targetTypes = CRUDAndFLSCheckController.sObjectsMap.get('ContentVersion');
	        Sobject Object_names = targetTypes.newSObject(); 
	        Schema.sObjectType sobject_types = Object_names.getSObjectType();
	        Schema.DescribeSObjectResult r = sobject_types.getDescribe(); 
	        
            Map<String,Schema.SObjectField> M = r.fields.getMap();
           
            for (String fieldName : M.keySet()) { 
                Schema.SObjectField field = M.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe(); 
               
              	if (!F.isNillable() && String.valueOf(f.getName()).contains('__c') && !String.valueOf(f.getName()).contains('Reference_Content_Type__c')) {
              		 
              		if (String.valueOf(f.getType()) == 'DATE' || String.valueOf(f.getType()) == 'DATETIME') {
              			 contentVersion.put(f.getName(),Date.today());
              		} else if (String.valueOf(f.getType()) == 'PICKLIST') {
              			contentVersion.put(f.getName(),null);
              		} else if (String.valueOf(f.getType()) == 'BOOLEAN') {  
              			contentVersion.put(f.getName(), true);
              		} else {
              			contentVersion.put(f.getName(),'Test');
              		}
              	} else if (String.valueOf(f.getName()) == 'VersionData') {
              		contentVersion.put(f.getName(),Blob.valueOf('Test Content'));
              	} else if (String.valueOf(f.getName()) == 'Title' || String.valueOf(f.getName()) == 'PathOnClient' || String.valueOf(f.getName()) == 'Title') {
              		contentVersion.put(f.getName(),'Test');
              	}
           	} 
            
	    	insert contentVersion;		  
	    	
	    	List<AddNewReferenceContentControllerSLDS.ContentTypeWrapper> lstCon = AddNewReferenceContentControllerSLDS.getContentDetails('Test'); 
	    	
	    	if (lstCon != null) {
				system.assertEquals(lstCon.size(), 1);
	        }  
        }
    	test.stopTest();
	}
	
	/**
     * Method to Get Ref Status
     */
	public static testMethod void testGetStatus() {
		Schema.DescribeFieldResult field = Schema.sObjectType.Reference_Content__c.fields.getMap().get(UtilityController.appNamespace() + 'Content_Status__c').getDescribe();  
    	 
 	 	List<Schema.PickListEntry> pickListValues = field.getPickListValues();
 	 	
 	 	system.assertEquals(AddNewReferenceContentControllerSLDS.getStatus().size(),pickListValues.size() + 1); 
	}
	
	/**
     * Method to Create ContentVersion
     */
	public static testMethod void testcreateContentVersion() {  
		User u = TestDataFactory.createUser();
		test.startTest(); 
        system.runAs(u) { 
			customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
	    	insert customRefContent; 
	    	tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true);
	    	insert tempObj;
	    	
			String jSONString = '{"ContentStatus":"Active","ContentType":"'+customRefContent.Id+'","ContentURL":"www.google.com","ExternalSummery":"Salesforce ","IsAllowingSharing":true,"IsCustomContentType":false,"IsFeatureContent":true,"IsInternalUse":false,"IsReferenceType":false,"Language":"French","LibraryID":"058i0000000aVD1AAM","OldContentURL":"www.google.com","SearchItem":"Salesforce Stack Exchange i","Summery":"Salesforce ","Title":"New Reference Content"}';
	 	 	String results = AddNewReferenceContentControllerSLDS.saveReferenceContent(jSONString, false, tempObj.Id, 'Test',true,null);
	 	 	  
	 	  
	 	 	ApexPages.StandardController controller = new ApexPages.StandardController(new Reference_Content__c());
	    	AddNewReferenceContentControllerSLDS controllerObj = new AddNewReferenceContentControllerSLDS(controller); 
	    	controllerObj.isNewRecord = true;  
	    	controllerObj.newfile = createFile();
	        controllerObj.newFileName = 'text';
	        controllerObj.refContentId = Id.valueOf(results); 
	    	controllerObj.createContentVersion();	  
	    	
	    	controllerObj.isNewRecord = true;  
	    	controllerObj.newfile = null; 
	        controllerObj.refContentId = Id.valueOf(results); 
	    	controllerObj.createContentVersion();	
	    	
	    	controllerObj.isNewRecord = false;  
	    	controllerObj.newfile = createFile();
	        controllerObj.newFileName = 'text';
	        controllerObj.refContentId = Id.valueOf(results); 
	    	controllerObj.createContentVersion();	   
	    	
	    	tempObj = new Reference_Content__c(title__c = 'tempObj01',  Reference_Content_Type__c = customRefContent.Id,Content_URL__c = 'www.test.com');
	    	insert tempObj;
	    	system.assertNotEquals(null, tempObj.id);
	    	
			jSONString = '{"ContentStatus":"Active","ContentType":"'+customRefContent.Id+'","ContentURL":"www.google.com","ExternalSummery":"Salesforce ","IsAllowingSharing":true,"IsCustomContentType":false,"IsFeatureContent":true,"IsInternalUse":false,"IsReferenceType":false,"Language":"French","LibraryID":"058i0000000aVD1AAM","OldContentURL":"www.google.com","SearchItem":"Salesforce Stack Exchange i","Summery":"Salesforce ","Title":"New Reference Content"}';
	 	 	results = AddNewReferenceContentControllerSLDS.saveReferenceContent(jSONString, false, tempObj.Id, 'Test',true,null);
	 	 	
	 	 	ContentVersion cv = new ContentVersion();
    		Schema.SObjectType targetTypes = CRUDAndFLSCheckController.sObjectsMap.get('ContentVersion');
	        Sobject Object_names = targetTypes.newSObject(); 
	        Schema.sObjectType sobject_types = Object_names.getSObjectType();
	        Schema.DescribeSObjectResult r = sobject_types.getDescribe(); 
	        
            Map<String,Schema.SObjectField> M = r.fields.getMap();
           
            for (String fieldName : M.keySet()) { 
                Schema.SObjectField field = M.get(fieldName);
                Schema.DescribeFieldResult F = field.getDescribe(); 
               
              	if (!F.isNillable() && String.valueOf(f.getName()).contains('__c') && !String.valueOf(f.getName()).contains('Reference_Content_Type__c')) {
              		 
              		if (String.valueOf(f.getType()) == 'DATE' || String.valueOf(f.getType()) == 'DATETIME') {
              			 cv.put(f.getName(),Date.today());
              		} else if (String.valueOf(f.getType()) == 'PICKLIST') {
              			cv.put(f.getName(),null);
              		} else if (String.valueOf(f.getType()) == 'BOOLEAN') {  
              			cv.put(f.getName(), true);
              		} else {
              			cv.put(f.getName(),'Test');
              		}
              	} else if (String.valueOf(f.getName()) == 'VersionData') {
              		cv.put(f.getName(),Blob.valueOf('Test Content'));
              	} else if (String.valueOf(f.getName()) == 'Title' || String.valueOf(f.getName()) == 'PathOnClient' || String.valueOf(f.getName()) == 'Title') {
              		cv.put(f.getName(),'Test Doc');
              	}
           	} 
            
	    	insert cv;	 
	 	 	controllerObj.isNewRecord = false;  
	    	controllerObj.newfile = null; 
	        controllerObj.refContentId = Id.valueOf(results); 
	        controllerObj.selectedExistingTitle='Test Doc';
	    	controllerObj.createContentVersion();  
        } 
	}
	
	/**
     * Method to Get Account Name
     */
	public static testMethod void testGetAccountName() {		
		Account acc = new Account(Name='UCO Bank', Industry = 'Agricultures', AccountSource = 'Web');
		insert acc;
		
		Contact con = new Contact(LeadSource = 'Partner',FirstName = 'Alon', LastName = 'Raz',AccountId = acc.Id, Email = 'alon@test.test');
		insert con;
		
		system.assertEquals(AddNewReferenceContentControllerSLDS.getAccountName(con.Id), 'UCO Bank'); 
	} 
	
	/**
     * Method to Call Constructor
     */
	public static testMethod void testToCallConstructor() {
		customRefContent = new Reference_Content_Type__c(Name__c = 'test', Active__c = true, Custom_Content_Type__c = true);
    	insert customRefContent;
    	tempObj = new Reference_Content__c(title__c = 'tempObj',  Reference_Content_Type__c = customRefContent.Id,Custom_Reference_Content__c = true);
    	insert tempObj;
    	
    	List<Reference_Type_Mapping__c> tempRefMapping = new List<Reference_Type_Mapping__c>();
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Reference_Content_Type__c = customRefContent.Id, Name = 'OwnerId'));
        insert tempRefMapping;
        
    	List<Reference_Content__c> content = [SELECT Allow_Social_Sharing__c, Featured_Content__c, Substitute_Account_Name__c,
				            					Reference_Content_Type_Name__c, Custom_Reference_Content__c, Reference_Content_Type__c,
				            					Reference_Content_Type__r.Recorded_Reference_Type__c, Reference_Content_Type__r.Name__c,
				            					Internal_Use__c, Title__c, Summary__c, Search_Terms_keywords__c, Review_Date__c,
				            					Publish_date__c, Publication_name__c, Library_ID__c, Language__c,
				            					Expiration_Date__c, Created_User_Name__c, Content_URL__c, Content_URL2__c, Content_Status__c,
				            					Content_ID__c, Author__c, Article_publication_date__c, External_Summary__c
				            					FROM Reference_Content__c LIMIT 1];
				            					
		system.assertEquals(AddNewReferenceContentControllerSLDS.isContentAlreadyExist(content[0].Content_ID__c),true); 
				            					
		ApexPages.StandardController controller = new ApexPages.StandardController(content[0]);
        AddNewReferenceContentControllerSLDS controllerObj = new AddNewReferenceContentControllerSLDS(controller); 
        
        controllerObj.deleteReferenceContent(tempObj.id);
    	
    	content = [SELECT Title__c FROM Reference_Content__c WHERE Id = :tempObj.id];
    	
    	system.assertEquals(content.size(), 0); 
	}
	
	/**
     * Method to Check Interview Topics
     */
	public static testMethod void testCheckInterviewTopics() {
		
		List<Reference_Content__c> refContents = TestDataFactory.createReferenceContent();
		insert refContents;
		
		List<Reference_Interview__c> refInterviewList = TestDataFactory.createReferenceInterview(refContents);
		insert refInterviewList; 
		List<Interview_Question__c> intrQueList = TestDataFactory.createInterviewQuestions();
		List<Interview_Topic__c>  intrTopicList = new List<Interview_Topic__c>();
        intrTopicList.add( new Interview_Topic__c(Interview_Question__c = intrQueList[0].Id,Question__c = 'Test Interview1',Reference_Interview__c = refInterviewList[0].Id,Video_URL__c='https://www.youtube.com/watch?v=0GWWcwpGosw'));
        insert intrTopicList;
        
		system.assertEquals(false, AddNewReferenceContentControllerSLDS.checkInterviewTopics(refContents[0].id));
	} 
	
	/**
     * Method to Check Premissions
     */
	public static testMethod void testGetAssociationPermissions() {
		
		 
        system.assertEquals('', AddNewReferenceContentControllerSLDS.getAssociationPermissions('Account', 'UPDATE'));
		system.assertEquals('', AddNewReferenceContentControllerSLDS.getAssociationPermissions('Account', 'INSERT'));
		system.assertEquals('', AddNewReferenceContentControllerSLDS.getAssociationPermissions('CONTACT', 'UPDATE'));
		system.assertEquals('', AddNewReferenceContentControllerSLDS.getAssociationPermissions('CONTACT', 'INSERT'));
		
		system.assertEquals(true,AddNewReferenceContentControllerSLDS.checkPermissionsForInsert(true));
		system.assertEquals(true,AddNewReferenceContentControllerSLDS.checkPermissionsForInsert(false));
		
		system.assertEquals(true, AddNewReferenceContentControllerSLDS.checkPermissionsForDeletion(true));
		system.assertEquals(true, AddNewReferenceContentControllerSLDS.checkPermissionsForDeletion(false));
		
		system.assertEquals(true, AddNewReferenceContentControllerSLDS.checkPermissions());
		
		
	} 
	
	
	/**
     * Method to Upload Content Version
     */ 
    private static ContentVersion UploadContentVersion() {
        cv = new ContentVersion();
        cv.VersionData = createFile();
        cv.PathOnClient = 'text';
        cv.FirstPublishLocationId = u.Id;
        cv.Title = 'First Content Version';
        system.assertEquals('First Content Version',cv.Title);
        return cv;
    } 
    
    /**
     * Creation of file
     */
    private static Blob createFile() {
        string file = 'Testing base 64 encode';
        system.assertEquals('Testing base 64 encode',file);
        Blob blobfile1 = Blob.valueOf(file);
        return blobfile1;
    }
    
    /**
     * create Reference Typ eMapping
     */
    static List<Reference_Type_Mapping__c> createReferenceTypeMapping() {
        List<Reference_Type_Mapping__c> tempRefMapping = new List<Reference_Type_Mapping__c>();
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = false, Reference_Content_Type__c = customRefContent.Id, Name = 'OwnerId'));
        tempRefMapping.add(new Reference_Type_Mapping__c(Visible__c = true, Required__c = true, Reference_Content_Type__c = customRefContent.Id, Name = 'OwnerId'));
        system.assertEquals(2,tempRefMapping.size());
        return tempRefMapping;
    }
}