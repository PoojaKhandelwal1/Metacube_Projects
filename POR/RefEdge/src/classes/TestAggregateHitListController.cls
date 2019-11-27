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
private class TestAggregateHitListController {
    //Unit Test method
    static testMethod void testSaveAndDelete() {
        list<Hit_List__c> hitlists = TestDataFactory.createHitLists();
        insert hitlists;
        //Start test method
        test.startTest();
            AggregateHitListController controller = new AggregateHitListController();
            system.assertEquals(controller.hitListRecords.size(), 3);
            controller.UpdateHitRecordId = hitlists[0].id;
            controller.asterikValue = true;
            controller.saveTheRecord();
            system.assertEquals(controller.setCon, null);
            system.assertEquals(controller.hitListRecords.size(), 3);
            controller.queryHitRecords();
            controller.hitRecordId = hitlists[2].id;
            controller.delHitRecord();
            database.delete(hitlists[0]);
            controller.UpdateHitRecordId = hitlists[0].id;
            controller.asterikValue = true;
            controller.saveTheRecord();
            controller.hitRecordId = hitlists[0].id;
            controller.delHitRecord();
            controller.editRow();
            list<Hit_List__c> tempList = [select Id from Hit_List__c];
        //stop test method  
        test.stopTest();
        system.assertEquals(tempList.size(),1);
    }
}