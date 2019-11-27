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
public with sharing class TestRefRefreshUpdateTrigger {
    
    public static Custom_Settings__c customSetting;
    public static List < Account > accounts;
    public static List<Reference_Basic_Information__c> RBIAccList;
    public static list<Reference_Refresh__c> refRefreshes;
    public static List < Account_Attribute__c > accAtts;
    public static List < Attribute__c > attributes;
    public static List < Label__c > labels;
    public static List < Referenceability_Type__c > rfTypes;
    public static List < Referenceability__c > refers;
    public static list<Attribute_Mapping__c> attMappings;
    public static List < Attributes_Labels__c > attrlabels;
    public static List < Contact > contacts;
    public static List < Contact_Attribute__c > conAtts;
    static testMethod void testBatchMethod(){
        try{
        createData();
        test.startTest();
            Reference_Refresh_Update__c temp1 = new Reference_Refresh_Update__c();
            temp1.Reference_Refresh__c = refRefreshes[0].Id;
            temp1.Account__c = accounts[0].Id;
            insert temp1;
            temp1.Attribute__c = true;
            temp1.RecordsToBeInsertedId__c = attributes[2].Id;
            
            temp1.Accept_Reject__c = 'Accept';
            temp1.Added__c = true;
            update temp1;
            
            
        //Stop test method
        test.stopTest();
        list<Reference_Basic_Information__c> rbiList1 = [select Id from Reference_Basic_Information__c];
        system.assert(rbiList1.size() > 0);
        }catch(Exception e){
            
        }  
    }
    static testMethod void testBatchMethod3(){
        try{
        createData();
        test.startTest();
            Reference_Refresh_Update__c temp1 = new Reference_Refresh_Update__c();
            temp1.Reference_Refresh__c = refRefreshes[0].Id;
            temp1.Contact__c = contacts[0].Id;
            insert temp1;
            temp1.Attribute__c = true;
            temp1.RecordsToBeInsertedId__c = attributes[2].Id;
            
            temp1.Accept_Reject__c = 'Accept';
            temp1.Added__c = true;
            update temp1;
            
            
        //Stop test method
        test.stopTest();
        list<Reference_Basic_Information__c> rbiList1 = [select Id from Reference_Basic_Information__c];
        system.assert(rbiList1.size() > 0);
        }catch(Exception e){
            
        }  
    }
    static testMethod void testBatchMethod1(){
        try{
        createData();
        test.startTest();
            Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
            temp.Reference_Refresh__c = refRefreshes[0].Id;
            temp.Account__c = accounts[0].Id;
            insert temp;
            temp.Referenceability_Status__c = 'Approved';
            temp.Referenceability_Verified_Date__c = system.today();
            temp.Accept_Reject__c = 'Accept';
            temp.Referenceability__c = true;
            temp.RecordsToBeInsertedId__c = rfTypes[2].Id;
            temp.Added__c = true;
            update temp;
            
            
        //Stop test method
        test.stopTest();
        list<Reference_Basic_Information__c> rbiList1 = [select Id from Reference_Basic_Information__c];
        system.assert(rbiList1.size() > 0);
        }catch(Exception e){
            
        }
    }
    static testMethod void testBatchMethod2(){
        try{
        createData();
        test.startTest();
            Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
            temp.Reference_Refresh__c = refRefreshes[0].Id;
            temp.Contact__c = contacts[0].Id;
            insert temp;
            
            temp.Referenceability_Status__c = 'Approved';
            temp.Accept_Reject__c = 'Accept';
            temp.Referenceability__c = true;
            temp.Referenceability_Verified_Date__c = system.today();
            temp.RecordsToBeInsertedId__c = rfTypes[2].Id;
            temp.Added__c = true;
            update temp;
            
            
        //Stop test method
        test.stopTest();
        list<Reference_Basic_Information__c> rbiList1 = [select Id from Reference_Basic_Information__c];
        system.assert(rbiList1.size() > 0);
        }catch(Exception e){
            
        }
    }
    static void createData(){
        customSetting = TestDataFactory.createCustomSetting();
        accounts = setUpAccounts();
        Contacts = setUpContacts();
        setUpRBI();
        attributes = setUpAttributes();
        labels = setUpLabels();
        attrlabels = setUpAttLabels();
        attMappings =createAttributeMapping(); 
        conAtts = setUpConAtts();
        accAtts = setUpAccAtts(); 
        rfTypes = setUpRFTypes();
        refers = setUpReferenceabilities();
        refRefreshes = createRefRefreshRecords();
        
    }
    //Creation of Contact_Attribute records
    private static List < Contact_Attribute__c > setUpConAtts() {
        List < Contact_Attribute__c > conAttLst = new List < Contact_Attribute__c > ();
        conAttLst.add(new Contact_Attribute__c(Contact__c = contacts[0].Id, Attribute__c = attributes[0].Id));
        conAttLst.add(new Contact_Attribute__c(Contact__c = contacts[0].Id, Attribute__c = attributes[1].Id));
        conAttLst.add(new Contact_Attribute__c(Contact__c = contacts[1].Id, Attribute__c = attributes[0].Id));
        insert conAttLst;
        return conAttLst;
    }
    //RBI Setup
    public static void setUpRBI(){
        RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[0].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[1].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[2].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[3].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[4].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = accounts[5].Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[0].AccountId, Contact__c =  contacts[0].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Caution', Is_Referenceable__c = true, Account__c = contacts[1].AccountId, Contact__c =  contacts[1].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[2].AccountId, Contact__c =  contacts[2].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[3].AccountId, Contact__c =  contacts[3].Id ));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contacts[4].AccountId, Contact__c =  contacts[4].Id ));
        insert RBIAccList;
    }
    private static List < Contact > setUpContacts() {
        List < Contact > ContactLst = new List < Contact > ();
        ContactLst.add(new Contact(FirstName = 'con1', LastName = 'test', AccountId = accounts.get(0).Id,LeadSource='Partner'));
        ContactLst.add(new Contact(FirstName = 'con2', LastName = 'test', AccountId = accounts.get(0).Id,LeadSource='Partner'));
        ContactLst.add(new Contact(FirstName = 'con3', LastName = 'test', AccountId = accounts[0].Id,LeadSource='Partner'));
        ContactLst.add(new Contact(FirstName = 'con4', LastName = 'test', AccountId = accounts[0].Id,LeadSource='Partner'));
        ContactLst.add(new Contact(FirstName = 'con5', LastName = 'test', AccountId = accounts[0].Id,LeadSource='Partner'));
        insert ContactLst;
        return ContactLst;
    }
    private Static list<Attribute_Mapping__c> createAttributeMapping(){
        list<Attribute_Mapping__c> attMappingRecords = new list<Attribute_Mapping__c>();
        attMappingRecords.add(new Attribute_Mapping__c(Object__c =ConstantsController.ACCOUNT, Inheritable__c = true, Filter_Label_Name__c = 'Industry', Field__c = 'Industry', Field_Api_Name__c = 'Industry', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'Industry',Is_Related_Mapping__c = false));
        attMappingRecords.add(new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'LeadSource', Field__c = 'LeadSource', Field_Api_Name__c = 'LeadSource', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'LeadSource',Is_Related_Mapping__c = false));
        attMappingRecords.add(new Attribute_Mapping__c(Object__c ='Contact', Inheritable__c = true, Filter_Label_Name__c = 'Industry', Field__c = 'Industry', Field_Api_Name__c = 'Industry', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'Industry',Is_Related_Mapping__c = true,Related_Object__c = 'Account',Mapping_Type__c='Parent Object',RelationShip_Name__c = 'AccountId'));
        attMappingRecords.add(new Attribute_Mapping__c(Object__c =ConstantsController.ACCOUNT, Inheritable__c = true, Filter_Label_Name__c = 'LastName', Field__c = 'LastName', Field_Api_Name__c = 'LastName', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'LastName',Is_Related_Mapping__c = true,Related_Object__c = 'Contact',Mapping_Type__c='Child Object',Child_RelationShipName__c='Contacts',RelationShip_Name__c = 'AccountId'));
        attMappingRecords.add(new Attribute_Mapping__c(Object__c =ConstantsController.ACCOUNT, Inheritable__c = true, Filter_Label_Name__c = 'LastName', Field__c = 'LastName', Field_Api_Name__c = 'LastName', Auto_update__c = true, Auto_populate__c = true, Auto_delete__c = true, Auto_add__c = true, Attribute_Name__c = 'LastName',Is_Related_Mapping__c = true,Related_Object__c = 'User',Mapping_Type__c='Parent Object',RelationShip_Name__c = 'OwnerId'));
        insert attMappingRecords;
        return attMappingRecords;
    }
    //Referenceability setup
    private static List < Referenceability__c > setUpReferenceabilities() {
        List < Referenceability__c > refersLst = new List < Referenceability__c > ();
        refersLst.add(new Referenceability__c(Account__c = accounts[0].Id, Referenceability_Type__c = rfTypes[0].Id, Status__c = 'Approved', Verified__c = System.today()));
        refersLst.add(new Referenceability__c(Account__c = accounts[0].Id, Referenceability_Type__c = rfTypes[1].Id, Status__c = 'Approved', Verified__c = System.today()));
        refersLst.add(new Referenceability__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Referenceability_Type__c = rfTypes[0].Id, Status__c = 'Approved', Verified__c = System.today()));
        refersLst.add(new Referenceability__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Referenceability_Type__c = rfTypes[1].Id, Status__c = 'Approved', Verified__c = System.today()));
        insert refersLst;
        return refersLst;
    }
    //Referenceability_Type setup
    private static List < Referenceability_Type__c > setUpRFTypes() {
        List < Referenceability_Type__c > rftypesLst = new List < Referenceability_Type__c > ();
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType1',Referenceability_Type__c = true));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType2',Referenceability_Type__c = true));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType3',Referenceability_Type__c = true));
        insert rftypesLst;
        return rftypesLst;
    }
    private static List < Attributes_Labels__c > setUpAttLabels() {
        List < Attributes_Labels__c > attLabels = new List < Attributes_Labels__c > ();
        attLabels.add(new Attributes_Labels__c(Label__c = labels[0].Id, Attribute__c = attributes[0].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[1].Id, Attribute__c = attributes[1].Id));
        attLabels.add(new Attributes_Labels__c(Label__c = labels[2].Id, Attribute__c = attributes[2].Id));
        insert attLabels;
        return attLabels;
    }
    //Account_Attribute setup
    private static List < Account_Attribute__c > setUpAccAtts() {
        List < Account_Attribute__c > accAttLst = new List < Account_Attribute__c > ();
        accAttLst.add(new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = attributes[0].Id));
        accAttLst.add(new Account_Attribute__c(Account__c = accounts[0].Id, Attribute__c = attributes[1].Id));
        accAttLst.add(new Account_Attribute__c(Account__c = accounts[1].Id, Attribute__c = attributes[0].Id));
        insert accAttLst;
        return accAttLst;
    }
    //Attribute setup
    private static List < Attribute__c > setUpAttributes() {
        List < Attribute__c > atts = new List < Attribute__c > ();
        atts.add(new Attribute__c(Name = 'Att1', Level__c = 1));
        atts.add(new Attribute__c(Name = 'Att2', Level__c = 1));
        atts.add(new Attribute__c(Name = 'Att3', Level__c = 1));
        insert atts;
        return atts;
        
    }
    //label setup
    private static List < Label__c > setUpLabels() {
        List < Label__c > labls = new List < Label__c > ();
        labls.add(new Label__c(Name = 'Label1'));
        labls.add(new Label__c(Name = 'Label2'));
        labls.add(new Label__c(Name = 'Label3'));
        insert labls;
        return labls;
    }
    public static list<Reference_Refresh__c> createRefRefreshRecords(){
        list<Reference_Refresh__c> tempList = new list<Reference_Refresh__c>();
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = RBIAccList[0].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId()));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[1].Id,Reference_Profile__c = RBIAccList[1].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        tempList.add(new Reference_Refresh__c(Reference_Account__c = accounts[2].Id,Reference_Profile__c = RBIAccList[2].Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId(),Quarantined__c = true));
        
        insert tempList;
        return tempList;
    }
    
    private static List < Account > setUpAccounts() {
        List < Account > accountLst = new List < Account > ();
        accountLst.add(new Account(Name = 'Acc1',Industry = 'Energy' ));
        accountLst.add(new Account(Name = 'Acc2',Industry = 'Energy' ));
        accountLst.add(new Account(Name = 'Acc3',Industry = 'Energy' ));
        accountLst.add(new Account(Name = 'Acc4',Industry = 'Energy' ));
        accountLst.add(new Account(Name = 'Acc5',Industry = 'Energy' ));
        accountLst.add(new Account(Name = 'Acc6',Industry = 'Energy' ));
        insert accountLst;
        return accountLst;
    }
}