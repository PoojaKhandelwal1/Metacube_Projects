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
public with sharing class TestInterviewTopicTrigger {
    static testmethod void createInterviewTopic(){
        User u = TestDataFactory.CreateUser();
        //Start test method
        test.startTest();
        system.runAs(u) {
            List<Reference_Content__c> referencecontents = TestDataFactory.createReferenceContent();
            insert referencecontents;
            Reference_Interview__c refIq = new Reference_Interview__c();
            refIq.Reference_Content__c = referencecontents[0].id;
            refIq.Speaker_info__c = 'Test Speaker';
            insert refIq;
            try{
                Interview_Question__c iq = new Interview_Question__c();
                iq.Question__C = 'What is your name ?';
                iq.Language__c = 'En_US';
                insert iq;
                
                Interview_Topic__c interviewTopic = new Interview_Topic__c();
                interviewTopic.Interview_Question__c = iq.id;
                interviewTopic.Reference_Interview__c = refIq.Id;
                insert interviewTopic;
                System.assert(interviewTopic.id !=null);
            }catch(Exception e){
                System.debug('Error '+e.getMessage());
            }   
        }
    }
}