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
/**
 * Related class: ContentDocumentTriggerHandler
 * Description: test class for DML operations on ContentDocument object
 * author: Gaurav Saini (12 Dec, 2017) for #1186
 */
@isTest(SeeAllData=true)
public with sharing class TestContentDocumentTriggerHandler {
    
    public static testmethod void testContentUpdate() {
    	User testUser = TestDataFactory.createUser();
    	insert testUser;
        ContentVersion testCV = TestDataFactory.createContentVersion1(testUser);
        insert testCV;
        List<Reference_Content__c> refContentList = TestDataFactory.createReferenceContent();
        refContentList[0].Content_ID__c = testCV.Id;
        insert refContentList;
        System.assertEquals(testCV.Id, refContentList[0].Content_ID__c);
        testCV = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :testCV.Id];
        List<ContentDocument> cdList = [SELECT Id, IsArchived FROM ContentDocument WHERE Id = :testCV.ContentDocumentId];
        cdList[0].IsArchived = true;
        update cdList;
        System.assertNotEquals(0, cdList.size());
        cdList[0].IsArchived = false;
        update cdList;
    }
}