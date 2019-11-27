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
public with sharing class TestBatchAccountAttribute {
    
    //Unit Test Method
    static testmethod void myUnitTest01() {
        try{
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            List < Account > accounts = TestDataFactory.createAccounts();
            for(Account acc : accounts){
                acc.Industry = 'Finance';
                acc.Rating = 'Cold';
            }
            insert accounts;
            TestDataFactory.createAttributeMapping();
            TestDataFactory.setUpAccountRBI(accounts);
            TestDataFactory.createAccountRatingAttributeMapping();
            
           //Start test method
            test.startTest();
                Batch_AccountAttribute batchAccountAtt = new Batch_AccountAttribute();
                ID batchprocessid = database.executebatch(batchAccountAtt);
            //Stop test method
            test.stopTest();
            list<Reference_Basic_Information__c> rbiList = [select Id from Reference_Basic_Information__c where Account__c =:accounts[0].Id];
            system.assertEquals(rbiList.size(),1);
        }catch(Exception e){
            
        }
    }
}