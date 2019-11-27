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
public with sharing class TestReferenceInterviewEditExtension {
    public static list < Reference_Interview__c > rrAIntList;
    
    //Unit Test Method 1
    static testMethod void myUnitTest01() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        System.runAs(u) {
            list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            insert referObject;
            rrAIntList = TestDataFactory.createReferenceInterview(referObject);
            insert rrAIntList;
            ApexPages.currentPage().getParameters().put('retUrl', referObject[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(rrAIntList[0]);
            ReferenceInterviewEditExtension testObj = new ReferenceInterviewEditExtension(sc);
            testObj.transcript = TestDataFactory.createFile();
            testObj.transcriptName = 'test file';
            testObj.save();
            testObj.cancel();
            System.assertEquals(testObj.retUrl,referObject[0].Id);
        }
        //Stop test method
        test.stopTest();
    }
    
    //Unit Test Method 2
    static testMethod void myUnitTest02() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        System.runAs(u) {
            list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            insert referObject;
            rrAIntList = TestDataFactory.createReferenceInterview(referObject);
            insert rrAIntList;
            ApexPages.currentPage().getParameters().put('retUrl', referObject[0].Id);
            Reference_Interview__c refInt = new Reference_Interview__c(Speaker_info__c  =  'sss',Reference_Content__c = referObject[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(refInt);
            ReferenceInterviewEditExtension testObj = new ReferenceInterviewEditExtension(sc);
            System.assertEquals(testObj.retUrl,referObject[0].Id);
        }
        //Stop test method
        test.stopTest();
    }
}