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
 * Class: NewProjectController
 * Description: class to test AND cover NewProjectController 
 * Modified by: Rekha Jangir @3 July 2017
 */
@isTest(seeAllData = false)
private class TestNewProjectController {
    public static User u;
    public static Profile p;
    public static List<Referenceability_Type__c> rfTypes = setUpRFTypes();
    
    /*
     * Method to cover Constructor AND add Account Request and contact request creation method
     * Modified By: Rekha Jangir @3 July 2017
     */
    static testMethod void testCreateAccountRequestMember() {
        createUser();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account account = new Account(Name = 'Metacube');
        insert account;
        Nomination__c nomi = new Nomination__c(Account__c = account.Id);
        insert nomi;
        Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id);
        insert contact;
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = account.Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contact.AccountId, Contact__c =  contact.Id ));
        insert RBIAccList;
        insert rfTypes;
        //Start test method
        test.startTest();
            system.runAs(u) {
                
                NewProjectController controller = new NewProjectController();
                //Account Request
                controller.accName = 'New Metacube';
                controller.setAccountID();
                controller.accName = 'Meta';
                controller.setAccountID();
                controller.accName = 'Metacube';
                controller.setAccountID();
                controller.tempRef = nomi;
                controller.setAccountID();
                controller.refReqAccountObject.Request_Notes__c = 'test';
                controller.refReqAccountObject.Reference_Type_Needed__c = rfTypes.get(0).Id;
                controller.refReqAccountObject.Deadline__c = date.today();
                //Contact Request
                controller.refReqAccContactObject.Contact__c = contact.Id;
                controller.getReferenceStatus();
                controller.selectedContact = contact.Id;
                controller.getReferenceStatus();
                controller.saveContent();
            }
        //Stop test method
        test.stopTest();
        List<Reference_Request_Account__c> listRRA = [SELECT Id FROM Reference_Request_Account__c WHERE Account__c = :account.Id];
        system.assertEquals(1, listRRA.size());
    }
    
    /*
     * Method to cover Constructor AND add Candidate type Account Request and contact request creation method
     * Modified By: Rekha Jangir @3 July 2017
     */
    static testMethod void testCreateAccountRequestCandidate() {
        createUser();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        Account account = new Account(Name = 'Metacube');
        insert account;
        Account account1 = new Account(Name = 'Metacube');
        insert account1;
        Nomination__c nomi = new Nomination__c(Account__c = account.Id);
        insert nomi;
        Contact contact = new Contact(FirstName = 'con1', LastName = 'test', AccountID = account.Id);
        insert contact;
        List<Reference_Basic_Information__c> RBIAccList = new list<Reference_Basic_Information__c>();
        RBIAccList.add(new Reference_Basic_Information__c(Reference_Program_Candidate__c = true, Account__c = account.Id));
        RBIAccList.add(new Reference_Basic_Information__c(Reference_Program_Candidate__c = true, Account__c = account1.Id));
        RBIAccList.add(new Reference_Basic_Information__c(Referenceability_Status__c = 'Active', Is_Referenceable__c = true, Account__c = contact.AccountId, Contact__c =  contact.Id ));
        insert RBIAccList;
        insert rfTypes;
        //Start test method
        test.startTest();
            system.runAs(u) {
                NewProjectController controller = new NewProjectController();
                controller.projectType = 'Candidate';
                controller.accName = 'Metacube';
                controller.setAccountID();
                controller.accName = 'Meta';
                controller.setAccountID();
                delete account1;
                controller.accName = 'Meta';
                controller.setAccountID();
                controller.accName = 'Metacube';
                controller.setAccountID();
                controller.refReqAccountObject.Request_Notes__c = 'test';
                controller.refReqAccountObject.Reference_Type_Needed__c = rfTypes.get(0).Id;
                controller.refReqAccountObject.Deadline__c = date.today();
                //Contact Request
                controller.refReqAccContactObject.Contact__c = contact.Id;
                controller.getReferenceStatus();
                controller.selectedContact = contact.Id;
                controller.getReferenceStatus();
                controller.saveContent();
                controller.refReqAccContactObject.Contact__c = null;
                controller.saveContent();
            }
        //Stop test method
        test.stopTest();
        List<Reference_Request_Account__c> listRRA = [SELECT Id FROM Reference_Request_Account__c WHERE Account__c = :account.Id];
        system.assertEquals(1, listRRA.size());
    }
    
	/*
     * Method to cover Constructor AND add unspecified request creation method
     * Modified By: Rekha Jangir @3 July 2017
     */
    static testMethod void testCreateUnspecifiedRequestCandidate() {
        createUser();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        
        insert rfTypes;
        //Start test method
        test.startTest();
            system.runAs(u) {
                NewProjectController controller = new NewProjectController();
                controller.projectType = 'Candidate';
                controller.refReqAccountObject.Request_Notes__c = 'test';
                controller.refReqAccountObject.Reference_Type_Needed__c = rfTypes.get(0).Id;
                controller.refReqAccountObject.Deadline__c = date.today();
                controller.saveContent();
                controller.setBlankAccountContact();
                controller.cancel();
            }
        //Stop test method
        test.stopTest();
        List<Unspecified_Request__c> listUR = [SELECT Id FROM Unspecified_Request__c WHERE Reference_Type_Needed__c = :rfTypes.get(0).Id];
        system.assertEquals(1, listUR.size());
    }
    
    /*
     * Method to cover exceptions
     * Modified By: Rekha Jangir @3 July 2017
     */
    static testMethod void testExceptions() {
        createUser();
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        customSetting.Project_Account_Required__c = true;
        customSetting.Project_Contact_Required__c = true;
        customSetting.Project_Opportunity_Required__c = true;
        customSetting.Project_Notes_Required__c = true;
        customSetting.Project_Subject_Required__c = true;
        update customSetting;
        insert rfTypes;
        //Start test method
        test.startTest();
            system.runAs(u) {
                NewProjectController controller = new NewProjectController();
                controller.saveContent();
            }
        //Stop test method
        test.stopTest();
        List<Unspecified_Request__c> listUR = [SELECT Id FROM Unspecified_Request__c WHERE Reference_Type_Needed__c = :rfTypes.get(0).Id];
        system.assertEquals(0, listUR.size());
    }
    //Creation of User record
    private static void CreateUser() {
        p = [SELECT id FROM profile WHERE name LIKE '%System Admin%'];
        u = new User(alias = 'jpusr', email = 'japnalocal@newtest.com',
            emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p.Id,
            timezonesidkey = 'America/Los_Angeles', username = 'japnalocal@newtest.com');
    }
    
    //Creation of Referenceability_Type records
    private static List<Referenceability_Type__c> setUpRFTypes() {
        List<Referenceability_Type__c> rftypesLst = new List<Referenceability_Type__c>();
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType1'));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType2'));
        rftypesLst.add(new Referenceability_Type__c(Name = 'RFType3'));
        return rftypesLst;
    }
}