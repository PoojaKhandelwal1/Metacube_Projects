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
public with sharing class TestInterviewTopicExtension {
    
    public static list < Reference_Interview__c > rrAIntList;
    public static list < Reference_Content__c > rrACntList;
    public static list < Interview_Topic__c > intrTopicList;
    public static list < Interview_Question__c > intrQueList;
    
    //Unit Test Method 1
    static testMethod void myUnitTest01() {
        User u = TestDataFactory.CreateUser();
        insert u;
        //Start test method
        test.startTest();
        System.runAs(u) {
            Reference_Content_Type__c customRefContent = TestDataFactory.createContentType();
            insert customRefContent;
            list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
            referObject[0].Reference_Content_Type__c = customRefContent.Id;
            insert referObject;
            intrQueList = TestDataFactory.createInterviewQuestions();
            rrAIntList = TestDataFactory.createReferenceInterview(referObject);
            insert rrAIntList;
            
            setUpInterviewTopic();
            ApexPages.currentPage().getParameters().put('retUrl', referObject[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(intrTopicList[0]);
            InterviewTopicExtension testObj = new InterviewTopicExtension(sc);
            testObj.ContentType = 'audio/mp3';
            testObj.contentFileName = 'audio/mp3';
            testObj.contentFile = TestDataFactory.createFile();
            
            testObj.save();
            testObj.cancel();
            
            system.assertEquals(testObj.returl, referObject[0].Id);
            testObj.ContentType = 'audio123';
            testObj.save();
        }
        //Stop test method
        test.stopTest();
    }
    //Interview_Topic Setup
    private static void setUpInterviewTopic() {
        intrTopicList = new List < Interview_Topic__c >();
        intrTopicList.add( new Interview_Topic__c(Interview_Question__c = intrQueList[0].Id,Question__c = 'Test Interview1',Reference_Interview__c = rrAIntList[0].Id,Video_URL__c='https://www.youtube.com/watch?v=0GWWcwpGosw'));
        insert intrTopicList;
    }
}