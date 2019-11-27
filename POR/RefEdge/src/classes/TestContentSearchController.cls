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
public class TestContentSearchController {
	
    //Content Search Results
    public static testMethod void RefsAttrsAndTextSearchContentTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List < ContentVersion > nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        list<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        list<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        list<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        list<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        test.startTest();
            list<Account_Attribute__c> accAtts = TestDataFactory.createAccountAttributes(accounts, childAttributes, false);
            list<Content_Attribute__c> conAtts = TestDataFactory.createContentAttributes(contents,childAttributes);
            
            RfSearchController rfsearchCon = new RfSearchController();
            rfsearchCon.attributeWrapper.selectedLabelId = labels[0].Id;
            rfsearchCon.attributeWrapper.selectAllAttributeTypes();
            rfsearchCon.contentSearch.selectedContentTypeName = 'Analyst Report';
            rfsearchCon.contentSearch.setContentTypes();
            rfsearchCon.contentSearch.selectedContentLanguageName = 'English';
            rfsearchCon.contentSearch.setContentLanguages();
            rfsearchCon.contentSearch.sharableContent = 'true';
            rfsearchCon.inputTextValue = 'con';
            Id[] fixedSearchResults = new Id[contents.size()];
            for (Integer i = 0; i < contents.size(); i++) {
                fixedSearchResults[i] = contents[i].Id;
            }
            Test.setFixedSearchResults(fixedSearchResults);
            rfsearchCon.search();
            system.assertEquals(true, rfsearchCon.getContents().size() != null);
            rfsearchCon.contentSearch.searchRefrenceContents(new set<String>(), false, true);
            Set<id> ids = new Set<Id>();
            
            for(Reference_Content__c content :contents){
                ids.add(content.id);
            }
            Reference_Content__c rcn =  contents[0];
            rfsearchCon.contentSearch.mapContent.put(1,ids);
            rfsearchCon.contentSearch.selectContentDocumentId = rcn.id;
            //rfsearchCon.contentSearch.shareContents();
            rfsearchCon.contentSearch.downloadContents();
        test.stopTest();
    }

    // other Metods
    public static testMethod void callOtherMethods() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List < ContentVersion > nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        list<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        list<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        list<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        list<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        test.startTest();
            list<Account_Attribute__c> accAtts = TestDataFactory.createAccountAttributes(accounts, childAttributes, false);
            list<Content_Attribute__c> conAtts = TestDataFactory.createContentAttributes(contents,childAttributes);
            ContentSearchController cscon = new ContentSearchController();
            cscon.showMoreContentRecords = true;
            cscon.contentTypes = null;
            cscon.contentLanguages = null;
            cscon.pageIndex = 1;
            cscon.previous();
            cscon.next();
            cscon.hoverContentId = contents[0].Content_ID__c;
            cscon.fetchHoverContentItem();
            cscon.hoverContentId = '';
            cscon.hoverRefContentId = contents[0].Id;
            cscon.fetchHoverContentItem();
            cscon.hoverRefContentId = contents[1].Id;
            cscon.fetchHoverContentItem();
            cscon.singleContentDownload();
            
            system.assertEquals(true, contents.size() > 0);
        test.stopTest();
    }

    //Method to set Content Types & Content Language
    static testMethod void setContentTypesAndLanguagesTest() {
         List < ContentVersion > nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        list<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        //Start test method
        test.startTest();
            ContentSearchController contObj = new ContentSearchController();
            //Content Type
            contObj.selectedContentTypeName = 'Analyst Report';
            contObj.setContentTypes();
            contObj.setContentTypes();
            //Content Language
            contObj.selectedContentLanguageName = 'English';
            contObj.setContentLanguages();
            system.assertEquals(contObj.selectedContentLanguages.size(), 1);
            contObj.setContentLanguages();
            system.assertEquals(contObj.selectedContentLanguages.size(), 0);
        //Stop test method
        test.stopTest();
    }
    static testMethod void checkForMiscellaneousMethods(){
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        list<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        list<Reference_Basic_Information__c> rbiList = TestDataFactory.setUpAccountRBI(accounts);
        List < ContentVersion > nativeContents = TestDataFactory.setUpNativeContents();
        insert nativeContents;
        list<Reference_Content__c> contents = TestDataFactory.setUpContents(nativeContents);
        insert contents;
        list<Attribute__c> attributes = TestDataFactory.createAttribute();
        insert attributes;
        list<Attribute__c> childAttributes = TestDataFactory.createChildAttributes(attributes, 1, 1);
        insert childAttributes;
        list<Label__c> labels = TestDataFactory.createLabels();
        insert labels;
        Reference_Content_Type__c createContentType = TestDataFactory.createContentType();
        insert createContentType;
        TestDataFactory.createAttributeLabels(labels, childAttributes);
        test.startTest();
            list<Account_Attribute__c> accAtts = TestDataFactory.createAccountAttributes(accounts, childAttributes, false);
            list<Content_Attribute__c> conAtts = TestDataFactory.createContentAttributes(contents,childAttributes);
            ContentSearchController cscon = new ContentSearchController();
            cscon.setTheFeaturedCheckbox();
            integer i = cscon.SHOWMORE_PAGE_SIZE;
            boolean tesr = cscon.isContentLimitExceed;
            cscon.selectedContentTypeName = 'test';
            cscon.setContentTypes();
            cscon.setContentTypes();
            cscon.selectAllContentTypes();
            cscon.showContentTypesAlphabet();
            cscon.filterByContentType();
            system.assertEquals(true, contents.size() > 0);
        test.stopTest();
    }
    //Method Clear All Content Types & Content Language
    static testMethod void clearAllReferenceabilityTypesTest() {
        //Start test method
        test.startTest();
            ContentSearchController contObj = new ContentSearchController();
            contObj.selectAllContentTypes();
            contObj.clearAllContentTypes();
            system.assertEquals(contObj.selectedContentTypes.size(), 0);
            contObj.selectAllContentLanguages();
            contObj.clearAllContentLanguages();
            system.assertEquals(contObj.selectedContentLanguages.size(), 0);
        //Stop test method
        test.stopTest();
    }

    //Method to show lang & Type by alphabet
    static testMethod void showAlphabetTest() {
        //Start test method
        test.startTest();
            ContentSearchController contObj = new ContentSearchController();
            contObj.character = 'A';
            contObj.showContentTypesAlphabet();
            contObj.showContentLanguagesAlphabet();
            //system.assertEquals(1, contObj.contentTypes.size()); 
            system.assertEquals(0, contObj.contentLanguages.size());
            contObj.character = 'All';
            contObj.showContentTypesAlphabet();
            contObj.showContentLanguagesAlphabet();
            contObj.character = 'other';
            contObj.showContentTypesAlphabet();
            contObj.showContentLanguagesAlphabet();
        //Stop test method
        test.stopTest();
    }

    //Account Setup
  /*  private static List < Account > setUpAccounts() {
        List < Account > accountLst = new List < Account > ();
        accountLst.add(new Account(Name = 'Acc1'));
        accountLst.add(new Account(Name = 'Acc2'));
        accountLst.add(new Account(Name = 'Acc3'));
        accountLst.add(new Account(Name = 'Acc4'));
        accountLst.add(new Account(Name = 'Acc5'));
        accountLst.add(new Account(Name = 'Acc6'));
        return accountLst;
    }
    
    //Creation of Reference_Basic_Information records
    public static void setUpRBI(){
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[1].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[2].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[3].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[4].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[5].Id));
        insert RBIAccList;
    }
    //SetUp Native Contents
    private static Blob createBlobFile() {
        String file = 'Testing File';
        Blob b = Blob.valueOf(file);
        return b;
    }

    //Creation of ContentVersion records
    private static List < ContentVersion > setUpNativeContents() {
        List < ContentVersion > ContentVersionLst = new List < ContentVersion > ();
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version1', PathOnClient = 'text', VersionData = createBlobFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version2', PathOnClient = 'text', VersionData = createBlobFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version3', PathOnClient = 'text', VersionData = createBlobFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version4', PathOnClient = 'text', VersionData = createBlobFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version5', PathOnClient = 'text', VersionData = createBlobFile()));
        ContentVersionLst.add(new ContentVersion(Title = 'Content Version6', PathOnClient = 'text', VersionData = createBlobFile()));
        return ContentVersionLst;
    }

    //Reference Content Setup
    private static List < Reference_Content__c > setUpContents() {
        List < Reference_Content__c > ContentLst = new List < Reference_Content__c > ();
        ContentLst.add(new Reference_Content__c(Title__c = 'cont1', Content_Status__c = 'Active', Language__c = 'English', Content_ID__c = nativeContents[0].Id,library_Id__c = userInfo.getUserId()));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont2', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[1].Id,library_Id__c = userInfo.getUserId()));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont3', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[2].Id,library_Id__c = userInfo.getUserId()));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont4', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[3].Id,library_Id__c = userInfo.getUserId()));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont5', Content_Status__c = 'Active',  Language__c = 'English', Content_ID__c = nativeContents[4].Id,library_Id__c = userInfo.getUserId()));
        ContentLst.add(new Reference_Content__c(Title__c = 'cont6', Content_Status__c = 'Active', Language__c = 'English', Content_ID__c = nativeContents[5].Id,library_Id__c = userInfo.getUserId()));
        return ContentLst;
    }

    //Creation of Attribute records
    private static List < Attribute__c > setUpAttributes() {
        List < Attribute__c > atts = new List < Attribute__c > ();
        atts.add(new Attribute__c(Name = 'Att1', Level__c = 1));
        atts.add(new Attribute__c(Name = 'Att2', Level__c = 1));
        atts.add(new Attribute__c(Name = 'Att3', Level__c = 1));
        return atts;
    }

    //Creation of Label records
    private static List < Label__c > setUpLabels() {
        List < Label__c > labls = new List < Label__c > ();
        labls.add(new Label__c(Name = 'Label1'));
        labls.add(new Label__c(Name = 'Label2'));
        labls.add(new Label__c(Name = 'Label3'));
        return labls;
    }

    //Creation of Attributes_Labels records
    private static List < Attributes_Labels__c > setUpAttLabels() {
        List < Attributes_Labels__c > attLabels = new List < Attributes_Labels__c > ();
        attLabels.add(new Attributes_Labels__c(Label__c = labels[0].Id, Attribute__c = attributes[0].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[0].Id, Attribute__c = attributes[1].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[1].Id, Attribute__c = attributes[1].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[1].Id, Attribute__c = attributes[2].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[2].Id, Attribute__c = attributes[0].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[2].Id, Attribute__c = attributes[1].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[2].Id, Attribute__c = attributes[2].Id));
        return attLabels;
    }

    //Creation of Account_Attribute records
    private static List < Account_Attribute__c > setUpAccAtts() {
        List < Account_Attribute__c > accAttLst = new List < Account_Attribute__c > ();
        accAttLst.add(new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = attributes[0].Id));
        accAttLst.add(new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = attributes[1].Id));
        accAttLst.add(new Account_Attribute__c(Account__c = accounts[1].Id, Attribute__c = attributes[0].Id));
        return accAttLst;
    }
    
    //Creation of Content_Attribute records
    private static List < Content_Attribute__c > setUpConAtts() {
        List < Content_Attribute__c > conAttLst = new List < Content_Attribute__c > ();
        conAttLst.add(new Content_Attribute__c(Reference_Content__c = contents[0].Id, Attribute__c = attributes[0].Id));
        conAttLst.add(new Content_Attribute__c(Reference_Content__c = contents[0].Id, Attribute__c = attributes[1].Id));
        conAttLst.add(new Content_Attribute__c(Reference_Content__c = contents[1].Id, Attribute__c = attributes[0].Id));
        return conAttLst;
    }

    // Include Weekends = false
    private static Custom_Settings__c setUpCustomSetting1() {
        Custom_Settings__c testSettings = new Custom_Settings__c(
            Name = 'Test1', Current_Version__c = '3.3.3', Active_Version__c = true, Email_Enabled__c = true,
            Chatter_Enabled__c = true, Include_Weekends__c = false, Days_of_Week__c = 'Saturday;Sunday',
            Minimum_Deadline__c = 4, Reminder_to_Owner__c = 3, Escalation_to_Owner_Manager__c = 2, No_Response__c = 1,
            Feedback_Message_Delay__c = 2,    
            RUL_Activities__c = 3, RUL_Period__c = 99
        );
        return testSettings;
    }*/
}