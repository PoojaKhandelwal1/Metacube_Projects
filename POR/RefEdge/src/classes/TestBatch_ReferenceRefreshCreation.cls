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
public with sharing class TestBatch_ReferenceRefreshCreation {
    
    static testMethod void testBatchMethod(){
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            insert accounts;
            TestDataFactory.setUpAccountRBI(accounts);
            list<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c where Account__C IN : accounts];
            rbiList[0].Last_Refresh_Sent__c = date.today().addDays(-3);
            rbiList[1].Last_Att_Ref_Update__c = date.today().addDays(-4);
            update rbiList;
            test.startTest();
                Batch_ReferenceRefreshCreation batchConAcc = new Batch_ReferenceRefreshCreation();
                ID batchprocessid = database.executebatch(batchConAcc);
            //Stop test method
            test.stopTest();
            rbiList = [select Id from Reference_Basic_Information__c];
            system.assertEquals(rbiList.size(),6);
        }catch(Exception e){
            
        }
    }
}