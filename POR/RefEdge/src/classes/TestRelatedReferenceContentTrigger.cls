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
public with sharing class TestRelatedReferenceContentTrigger {
    //Test method for delete operation
    static testMethod void testDeleteOperation() {
        User u = TestDataFactory.createUser();
        insert u;
        //Start test method
        test.startTest();
        System.runAs(u) {
            try {
                Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
                ContentVersion cv = TestDataFactory.createContentVersion(u);
                insert cv;
                list<Reference_Content__c> referObject = TestDataFactory.createReferenceContent();
                referObject[0].Content_ID__c = cv.Id;
                insert referObject;
                Content_Collection__c conCollection = new Content_Collection__c(Active__c = true, Collection__c = 'test collection');
                insert conCollection;
                Related_Reference_Content__c relatedRefCon = new Related_Reference_Content__c(Content_Collection__c = conCollection.Id, Reference_Content__c = referObject[0].Id);
                insert relatedRefCon;
                Related_Reference_Content__c relatedRefCon1 = new Related_Reference_Content__c(Content_Collection__c = conCollection.Id, Reference_Content__c = referObject[0].Id);
                try {
                    insert relatedRefCon1;
                }
                catch(Exception e){
					system.assertEquals(e.getMessage().contains(System.Label.Junction_already_exists), false);
                }
            } catch (System.DmlException e) {
            }
        }
        //Stop test method
        test.stopTest();
    }
}