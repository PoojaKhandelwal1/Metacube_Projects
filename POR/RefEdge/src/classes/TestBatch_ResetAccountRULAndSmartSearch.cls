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
 public class TestBatch_ResetAccountRULAndSmartSearch {

     //Unit test method
    static testmethod void myUnitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<Account> accounts = TestDataFactory.createAccounts();

        for(Account acc : accounts){
            acc.Industry = 'Banking';
            acc.Rating = 'Cold';
        }
        insert accounts;
        TestDataFactory.createAttributeMapping();
        TestDataFactory.createAccountRatingAttributeMapping();
        TestDataFactory.setUpAccountRBI(accounts);
        List<Label__c> labelList = TestDataFactory.createLabels();
        insert labelList;
        List<Data_Mapping__c> dmList = TestDataFactory.createDataMappings();

        for (Data_Mapping__c dm : dmList) {
            dm.Object__c = 'SmartSearchFilter';
            dm.Field_API_Name__c = String.valueOf(labelList[0]);         
        }
        insert dmList;
        List<Reference_Request__c> refReqs = TestDataFactory.createReferenceRequest();
        insert refReqs;
        refReqs = TestDataFactory.createMoreReferenceRequest();
        insert refReqs;
        List<Referenceability_Type__c> refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        List<Reference_Request_Account__c> refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);

        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Activity_Date__c = system.today();
            rra.Reference_Use__c = true;
            rra.Managed_Request__c = true;
            rra.Account_Request_Status__c = 'Completed'; 
        }
        insert refReqAccs;
        //Start test method
        test.startTest();
            Batch_ResetAccountRULAndSmartSearchCount batchAccountRUL = new Batch_ResetAccountRULAndSmartSearchCount();
            ID batchprocessid = database.executebatch(batchAccountRUL);
        //Stop test method
        test.stopTest();
        List<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c where Account__c =:accounts[0].Id];
        system.assertEquals(rbiList.size(),1);
    }    
 }