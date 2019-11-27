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
public with sharing class TestContentTriggerHandler {
    
    //Test method  
    static testMethod void testContentOnAfterInsert() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
            system.runAs(u) {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                Reference_Content_Type__c customRefContent = TestDataFactory.createContentType();
                insert customRefContent;
                ContentVersion cv = TestDataFactory.createContentVersion(u);
                insert cv;
                cv.Title = 'test';
                update cv;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                referObject[0].Content_ID__c = cv.Id;
                insert referObject;
                cv.Title = 'new test';
                update cv;
                List < Reference_Content__c > rcList = [select id from Reference_Content__c where Content_ID__c = : cv.Id];
                system.assertEquals(1, rcList.size());
            }
        //Stop test method
        test.stopTest();
    }
}