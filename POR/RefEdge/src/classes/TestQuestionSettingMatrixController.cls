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
public with sharing class TestQuestionSettingMatrixController {
    
    static testMethod void myUnitTest01() {
        User u = TestDataFactory.CreateUser();
        
        //Start test method
        test.startTest();
        System.runAs(u) {
            TestDataFactory.createInterviewQuestions();
            Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
            ApexPages.currentPage().getParameters().put('customSettingId', customSetting.id);
            QuestionSettingMatrixController testObj = new QuestionSettingMatrixController();
            System.assertEquals(1,testObj.questWrapper.size());
            testObj.addQuestion();
            System.assertEquals(2,testObj.questWrapper.size());
            testObj.saveQuestions();
            testObj.questionOrder = '1_2,2_5';
            testObj.saveQuestionOrder();
            testObj.cancel();
        }
        //Stop test method
        test.stopTest();
    }
}