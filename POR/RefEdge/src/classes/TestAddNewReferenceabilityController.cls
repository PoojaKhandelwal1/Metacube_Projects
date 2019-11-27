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
public class TestAddNewReferenceabilityController {
	
	
    // new referenceability from Account related list
	static testmethod void ReferenceabilityFromAccountTest() {
		List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        PageReference pdfPage = new PageReference('AddNewReferenceability');
        Test.setCurrentPage(pdfPage);
        ApexPages.currentPage().getParameters().put('retURL', '%'+accounts[0].Id);
        Referenceability__c refer = new Referenceability__c(account__c = accounts[0].Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(refer);
        AddNewReferenceabilityController refContObj = new AddNewReferenceabilityController(controller);
        refContObj.selectedContact = contacts[0].Id;
        refContObj.getReferenceStatus();
        system.assertEquals(refContObj.isContactsRendered, true);
        //system.assertEquals(refContObj.contacts.size(),contacts.size());
        system.assertEquals(refContObj.refer.contact__c, null);
    }
    // new referenceability from Conatct related list
    static testmethod void ReferenceabilityFromContactTest() {
       	List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        PageReference pdfPage = new PageReference('AddNewReferenceability');
        Test.setCurrentPage(pdfPage);
        ApexPages.currentPage().getParameters().put('retURL', '%'+contacts[0].Id);
        Referenceability__c refer = new Referenceability__c(contact__c = contacts[0].Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(refer);
        system.assert(controller!=null);
        AddNewReferenceabilityController refContObj = new AddNewReferenceabilityController(controller);
        system.assertEquals(refContObj.isContactsRendered, false);
        system.assertEquals(refContObj.refer.account__c, accounts[0].Id);
    }
    // Saving referenceability
    static testmethod void ReferenceabilitySaveTest() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            PageReference pdfPage = new PageReference('AddNewReferenceability');
            Test.setCurrentPage(pdfPage);
            ApexPages.currentPage().getParameters().put('retURL', contacts[0].Id);
            Referenceability__c refer = new Referenceability__c(contact__c = contacts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(refer);
            AddNewReferenceabilityController refContObj = new AddNewReferenceabilityController(controller);
            refContObj.refer.Referenceability_Type__c = rfTypes[0].Id;
            refContObj.refer.Status__c = 'Approved';
            refContObj.refer.Verified__c = System.today();
            refContObj.selectedFields = refContObj.referenceabilityTypes;
            refContObj.makeAccountMember = true;
            refContObj.makeContactMember = true;
            refContObj.selectedAccounts = new list < SelectOption >(); 
            Pagereference pgref = refContObj.save();
            refContObj.redirectToPage();
            system.assertEquals(refContObj.refer.Status__c, 'Approved');
        }catch(Exception e){
            
        }
    }
   
    // Saving and Editing referenceability
    static testmethod void ReferenceabilitySaveAndEditTest() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            TestDataFactory.setUpContactRBI(contacts);
            Reference_Basic_Information__c rbInfo2=[select id from Reference_Basic_Information__c where Contact__c = null and Account__c = :accounts[0].Id];
			Reference_Refresh__c refReference=new Reference_Refresh__c(Reference_Account__c = accounts[0].Id,Reference_Profile__c = rbInfo2.Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId());
            insert refReference;
            Reference_Refresh__c refReference2=[select id from Reference_Refresh__c where Reference_Profile__c =: rbInfo2.Id];
            PageReference pdfPage = new PageReference('AddNewReferenceability');
            Test.setCurrentPage(pdfPage);
            ApexPages.currentPage().getParameters().put('retURL', contacts[0].Id);
            ApexPages.currentPage().getParameters().put('conRefRefreshId',refReference2.Id);
            ApexPages.currentPage().getParameters().put('accRefRefreshId',refReference2.id);
            Referenceability__c refer = new Referenceability__c(contact__c = contacts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(refer);
            AddNewReferenceabilityController refContObj = new AddNewReferenceabilityController(controller);
            refContObj.showReferenceabilityForContact=true;
            refContObj.showReferenceabilityForAccount=true;
            refContObj.refer.Referenceability_Type__c = rfTypes[1].Id;
            refContObj.refer.Status__c = 'Approved';
            refContObj.refer.Verified__c = System.today();
            refContObj.makeAccountMember = true;
            refContObj.makeContactMember = true;
            Pagereference pgref = refContObj.save();
            refContObj.selectedFields.add(new SelectOption(rfTypes[0].Id, rfTypes[0].Name));
            pgref = refContObj.save();
            refContObj.getReferenceStatus();
            refContObj.cancel();
            refCOntObj.redirectToPage();
            list<Referenceability__c> referList = [select Id, Name from Referenceability__c];
            if(referList.size() > 0)
                refer = referList[0];
            ApexPages.currentPage().getParameters().put('id', refer.Id);
            ApexPages.currentPage().getParameters().put('conRefRefreshId',refReference2.Id);
            ApexPages.currentPage().getParameters().put('accRefRefreshId','');
            ApexPages.StandardController controller2 = new ApexPages.StandardController(refer);
            AddNewReferenceabilityController refContObj2 = new AddNewReferenceabilityController(controller2);
            system.assertEquals(refContObj2.refer.Status__c, 'Approved');
            system.assertEquals(refContObj2.refer.Verified__c, System.today());
            Referenceability__c refer2=[select id from Referenceability__c where contact__c =:contacts[0].Id];
            refContObj2.selectedReferenceability=refer2.id;
            refContObj2.deleteReferenceability();
        }catch(Exception e){
            
        }
    }
	
    // Saving and Editing referenceability
    static testmethod void ReferenceabilitySaveAndEditTest2() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Referenceability_Type__c> rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        List<Account> accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List<Contact> contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        Reference_Basic_Information__c rbInfo2 = [select id from Reference_Basic_Information__c where Contact__c = null and Account__c = :accounts[0].Id];
		Reference_Refresh__c refReference = new Reference_Refresh__c(Quarantined__c = false,Reference_Account__c = accounts[0].Id,Reference_Profile__c = rbInfo2.Id,Reference_Refresh_Status__c = 'Request Sent',Is_Active__c= true,Reference_Refresh_Owner__c = Userinfo.getUserId());
        insert refReference;
        Reference_Refresh__c refReference2 = [select id from Reference_Refresh__c where Reference_Profile__c =: rbInfo2.Id];
        Reference_Refresh_Update__c temp = new Reference_Refresh_Update__c();
        temp.Reference_Refresh__c = refReference2.Id;
        temp.Added__c = true;
        temp.Referenceability__c = true;
        temp.Account__c = accounts[0].Id;
        insert temp;
        Reference_Refresh_Update__c temp1 = new Reference_Refresh_Update__c();
        temp1.Reference_Refresh__c = refReference2.Id;
        temp1.Contact__c = contacts[0].Id;
        temp1.Referenceability__c = true;
        temp1.Added__c = true;
        insert temp1;
        PageReference pdfPage = new PageReference('AddNewReferenceability');
        Test.setCurrentPage(pdfPage);
        ApexPages.currentPage().getParameters().put('retURL', contacts[0].Id);
        ApexPages.currentPage().getParameters().put('conRefRefreshId', refReference2.Id);
        ApexPages.currentPage().getParameters().put('accRefRefreshId', refReference2.id);
        Referenceability__c refer = new Referenceability__c(contact__c = contacts[0].Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(refer);
        AddNewReferenceabilityController refContObj = new AddNewReferenceabilityController(controller);
        refContObj.showReferenceabilityForContact = true;
        refContObj.showReferenceabilityForAccount = true;
        refContObj.refer.Referenceability_Type__c = rfTypes[1].Id;
        refContObj.refer.Status__c = 'Approved';
        refContObj.refer.Verified__c = System.today();
        refContObj.refer.Account__c = accounts[0].Id;
        refContObj.refer.Contact__c = contacts[0].Id;
        Pagereference pgref = refContObj.save();
        refContObj.selectedFields.add(new SelectOption(rfTypes[0].Id, rfTypes[0].Name));
        pgref = refContObj.save();
        List<Referenceability__c> testReferenceabilityList = [SELECT Id, Contact__c FROM Referenceability__c
        														WHERE Contact__c = :contacts[0].Id];
		system.assertEquals(1, testReferenceabilityList.size());
    }
    
    static testmethod void ReferenceabilitySharedSaveTest() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
    		Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
			sObject obj = objectType.newSObject();
			Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
			customSetting.Shared_Contacts__c = true;
			customSetting.Shared_Contact_Object__c = describeResult.getName();
			customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
			customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
			customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
	        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
	        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
			update customSetting;
			
            List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
            insert rfTypes;
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            List < Contact > contacts = TestDataFactory.createContacts(accounts);
            insert contacts;
            obj.put(UtilityController.appNamespace() + 'Account__c', accounts[1].Id);
			obj.put(UtilityController.appNamespace() + 'Contact__c', contacts[0].Id);
			List<sObject> objectList = new List<sObject>();
			objectList.add(obj);
			insert obj;
            PageReference pdfPage = new PageReference('AddNewReferenceability');
            Test.setCurrentPage(pdfPage);
            ApexPages.currentPage().getParameters().put('retURL', contacts[0].Id);
            Referenceability__c refer = new Referenceability__c(contact__c = contacts[0].Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(refer);
            AddNewReferenceabilityController refContObj = new AddNewReferenceabilityController(controller);
            refContObj.refer.Referenceability_Type__c = rfTypes[0].Id;
            refContObj.refer.Status__c = 'Approved';
            refContObj.refer.Verified__c = System.today();
            refContObj.selectedFields = refContObj.referenceabilityTypes;
            refContObj.makeAccountMember = true;
            refContObj.makeContactMember = true;
            refContObj.getAccountReferenceStatus();
            //refContObj.selectedAccounts.add(); 
            Pagereference pgref = refContObj.save();
            refContObj.redirectToPage();
            system.assertEquals(refContObj.refer.Status__c, 'Approved');
        }catch(Exception e){
            
        }
    }
    
}