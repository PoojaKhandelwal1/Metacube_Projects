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
@isTest(SeeAllData=false)
public class TestAccountSearchController {
    
    //Account Search Results
    public static testMethod void RefsAttrsAndTextSearchAccountTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(accounts, new list<Contact>(), rfTypes);
        insert refers;
        List < Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,3);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[0]});
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[1]});
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[2]});
        List < Account_Attribute__c > accAtts = TestDataFactory.createAccountAttributes(accounts, childAttributes, false);
        Reference_Request__c refReq = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
        insert refReq;
        List < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq}, rfTypes);
        refReqAccs[2].Managed_Request__c = true;
        insert refReqAccs;
        RfSearchController rfsearchCon = new RfSearchController();
        rfsearchCon.attributeWrapper.selectedLabelId = labels[0].Id;
        rfsearchCon.attributeWrapper.selectAllAttributeTypes();
        rfsearchCon.referenceabilityWrapper.selectAllReferenceabilityTypes();
        rfsearchCon.inputTextValue = 'Workday';
        Id[] fixedSearchResults = new Id[accounts.size()];
        for (Integer i = 0; i < accounts.size(); i++) {
            fixedSearchResults[i] = accounts[i].Id;
        }
        Test.setFixedSearchResults(fixedSearchResults);
        rfsearchCon.search();
        system.assertEquals(5,rfsearchCon.getAccounts().size());
        rfsearchCon.inputTextValue = ' ';
        rfsearchCon.search();
    }
    
    //Account Search Results
    public static testMethod void RefsAttrsAndTextSearchAccountTestInactive() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Referenceability_Type__c > rfTypes = TestDataFactory.createReferenceabilityType();
        insert rfTypes;
        List < Referenceability__c > refers = TestDataFactory.createReferenceability(accounts, new list<Contact>(), rfTypes);
        insert refers;
        List < Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,3);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[0]});
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[1]});
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[2]});
        List < Account_Attribute__c > accAtts = TestDataFactory.createAccountAttributes(accounts, childAttributes, false);
        Reference_Request__c refReq = new Reference_Request__c(Requester__c = UserInfo.getUserId(), Reference_Request_Status__c = 'In Progress');
        insert refReq;
        List < Reference_Request_Account__c > refReqAccs = TestDataFactory.createAccountRequests(accounts, new list<Reference_Request__c>{refReq}, rfTypes);
        refReqAccs[2].Managed_Request__c = true;
        insert refReqAccs;
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Account__c IN : accounts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
            rbi.Referenceability_Status__c = 'Inactive';
        }
        update RBIAccList;
        RfSearchController rfsearchCon = new RfSearchController();
        rfsearchCon.accountSearch.selectedType = 'Inactive';
        for(String str : rfsearchCon.filterLogics.keySet()){
            rfsearchCon.filterLogics.get(str).operatorSelected = 'And';
        }
        rfsearchCon.attributeWrapper.selectedLabelId = labels[0].Id;
        rfsearchCon.attributeWrapper.selectAllAttributeTypes();
        rfsearchCon.referenceabilityWrapper.selectAllReferenceabilityTypes();
        rfsearchCon.inputTextValue = 'Workday';
        Id[] fixedSearchResults = new Id[accounts.size()];
        for (Integer i = 0; i < accounts.size(); i++) {
            fixedSearchResults[i] = accounts[i].Id;
        }
        Test.setFixedSearchResults(fixedSearchResults);
        rfsearchCon.search();
        system.assertEquals(0,rfsearchCon.getAccounts().size());
        rfsearchCon.inputTextValue = ' ';
        rfsearchCon.search();
    }
    
    //Account Search Results
    public static testMethod void RefsAttrsAndTextSearchAccountTestCandidate() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        List < Label__c > labels = TestDataFactory.createLabels();
        insert labels;
        list < Attribute__c > attributes = new list < Attribute__c >{TestDataFactory.createAttribute()[0]};
        insert attributes;
        list < Attribute__c > childAttributes = TestDataFactory.createChildAttributes(attributes, 1,3);
        insert childAttributes;
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[0]});
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[1]});
        TestDataFactory.createAttributeLabels(new list<Label__c>{labels[0]}, new list < Attribute__c >{childAttributes[2]});
        List < Account_Attribute__c > accAtts = TestDataFactory.createAccountAttributes(accounts, childAttributes, false);
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Account__c IN : accounts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
            rbi.Referenceability_Status__c = '';
            rbi.Is_Referenceable__c = false;
            rbi.Reference_Program_Candidate__c = true;
        }
        update RBIAccList;
        RfSearchController rfsearchCon = new RfSearchController();
        rfsearchCon.accountSearch.selectedType = 'Candidate';
        rfsearchCon.attributeWrapper.selectedLabelId = labels[0].Id;
        rfsearchCon.attributeWrapper.selectAllAttributeTypes();
        rfsearchCon.referenceabilityWrapper.selectAllReferenceabilityTypes();
        rfsearchCon.inputTextValue = 'Workday';
        Id[] fixedSearchResults = new Id[accounts.size()];
        for (Integer i = 0; i < accounts.size(); i++) {
            fixedSearchResults[i] = accounts[i].Id;
        }
        Test.setFixedSearchResults(fixedSearchResults);
        rfsearchCon.search();
        system.assertEquals(5,rfsearchCon.getAccounts().size());
        rfsearchCon.inputTextValue = ' ';
        rfsearchCon.search();
    }
    // showMoreAccountRecords is true and no. of accounts are more than twice of SHOWMORE_PAGE_SIZE
    public static testMethod void accountsGetNextAndPrevTest() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        accounts.addAll(TestDataFactory.createAccountsMore());
        upsert accounts;
        TestDataFactory.setUpMoreAccountRBI(accounts);
        
        AccountSearchController ascon = new AccountSearchController();
        ascon.showMoreAccountRecords = true;
        system.assertEquals(25, ascon.SHOWMORE_PAGE_SIZE);
        system.assertEquals(false, ascon.isAccountLimitExceed);
        system.assertEquals(true, ascon.showMoreAccountRecords);
        ascon.pageIndex = 1;
        ascon.selectedType = 'Active';
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, true);
        /*ascon.mapAccount.get(1)[0].isSelected = true;
        ascon.mapAccount.get(1)[1].isSelected = true;
        ascon.mapAccount.get(1)[2].isSelected = true;
        ascon.mapAccount.get(1)[3].isSelected = true;*/
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        //ascon.mapAccount.get(1)[20].isSelected = true;
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, true);
        system.assertEquals(true, accounts.size() > 0);
        ascon.getItems();
    }
    
    // showMoreAccountRecords is true and no. of accounts are more than twice of SHOWMORE_PAGE_SIZE
    public static testMethod void accountsGetNextAndPrevTestInactive() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        accounts.addAll(TestDataFactory.createAccountsMore());
        upsert accounts;
        TestDataFactory.setUpMoreAccountRBI(accounts);
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Account__c IN : accounts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
            rbi.Referenceability_Status__c = 'Inactive';
        }
        update RBIAccList;
        AccountSearchController ascon = new AccountSearchController();
        ascon.selectedType = 'Inactive';
        ascon.showMoreAccountRecords = true;
        system.assertEquals(25, ascon.SHOWMORE_PAGE_SIZE);
        system.assertEquals(false, ascon.isAccountLimitExceed);
        system.assertEquals(true, ascon.showMoreAccountRecords);
        ascon.pageIndex = 1;
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        /*ascon.mapAccount.get(1)[0].isSelected = true;
        ascon.mapAccount.get(1)[1].isSelected = true;
        ascon.mapAccount.get(1)[2].isSelected = true;
        ascon.mapAccount.get(1)[3].isSelected = true;*/
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        //ascon.mapAccount.get(1)[20].isSelected = true;
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, true);
        system.assertEquals(true, accounts.size() > 0);
        ascon.getItems();
    }
    
    // showMoreAccountRecords is true and no. of accounts are more than twice of SHOWMORE_PAGE_SIZE
    public static testMethod void accountsGetNextAndPrevTestCandidate() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Account > accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        accounts.addAll(TestDataFactory.createAccountsMore());
        upsert accounts;
        TestDataFactory.setUpMoreAccountRBI(accounts);
        List<Reference_Basic_Information__c> RBIAccList = [select Referenceability_Status__c,Is_Referenceable__c,Reference_Program_Candidate__c from Reference_Basic_Information__c where Account__c IN : accounts];
        for(Reference_Basic_Information__c rbi : RBIAccList){
            rbi.Referenceability_Status__c = '';
            rbi.Is_Referenceable__c = false;
            rbi.Reference_Program_Candidate__c = true;
        }
        update RBIAccList;
        AccountSearchController ascon = new AccountSearchController();
        ascon.selectedType = 'Candidate';
        ascon.showMoreAccountRecords = true;
        system.assertEquals(25, ascon.SHOWMORE_PAGE_SIZE);
        system.assertEquals(false, ascon.isAccountLimitExceed);
        system.assertEquals(true, ascon.showMoreAccountRecords);
        ascon.pageIndex = 1;
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        /*ascon.mapAccount.get(1)[0].isSelected = true;
        ascon.mapAccount.get(1)[1].isSelected = true;
        ascon.mapAccount.get(1)[2].isSelected = true;
        ascon.mapAccount.get(1)[3].isSelected = true;*/
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        //ascon.mapAccount.get(ascon.pageIndex)[0].isSelected = true;
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        //ascon.mapAccount.get(ascon.pageIndex)[0].isSelected = true;
        ascon.next();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        //ascon.mapAccount.get(ascon.pageIndex)[0].isSelected = true;
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        //ascon.mapAccount.get(ascon.pageIndex)[0].isSelected = false;
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, false);
        //ascon.mapAccount.get(ascon.pageIndex)[0].isSelected = false;
        ascon.previous();
        ascon.listAccounts('', new AttributeWrapper(), new ReferenceabilityWrapper(), new Set<String>(), false, true);
        system.assertEquals(true, accounts.size() > 0);
        ascon.reset();
        ascon.getItems();
    }
}