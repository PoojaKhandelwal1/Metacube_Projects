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
private class TestBatch_DataUpdate_RefContent {
    
    //Unit test01
    static testMethod void testSaveContentMethodForNewForCustomContent(){
        User u = TestDataFactory.CreateUser();
        insert u;
        test.startTest();
            system.runAs(u) {
                POR_App_Configuration__c cs = ConstantsController.setEditionCustomSetting();
                insert cs;
                ContentVersion cv = TestDataFactory.createContentVersion(u);
                Reference_Content_Type__c customRefContent = TestDataFactory.createContentType();
                insert customRefContent;
                list<Reference_Content__c> refContent = TestDataFactory.createReferenceContent();
                refContent[0].Reference_Content_Type__c= customRefContent.Id;
                refContent[0].Custom_Reference_Content__c = true;
                insert refContent;
                Batch_DataUpdate_RefContent batchRefContUpdate = new Batch_DataUpdate_RefContent();
                ID batchprocessid = database.executebatch(batchRefContUpdate);
            }
        test.stopTest();
        list<Reference_Content__c> rcList = [select Id from Reference_Content__c where Reference_Content_Type_Name__c != null];
        system.assert(rcList.size() > 0);
    }
}