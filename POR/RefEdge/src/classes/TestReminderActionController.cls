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
private class TestReminderActionController  {
    private static list<Hit_List__c> hitlists;
    
    //Test Method for save and Cancel
    static testMethod void testSaveAndCancel() {
      hitlists = TestDataFactory.createHitLists();
      insert hitlists;
      //Start test method
      test.startTest();
        ApexPages.currentPage().getParameters().put('Id', hitlists[0].Id);
        ApexPages.currentPage().getParameters().put('retId', hitlists[0].Id);
        ApexPages.currentPage().getParameters().put('retPage', 'hitList');
        
        ReminderActionController controller = new ReminderActionController();
        controller.reminderDate = date.today();
        controller.timeSelected = '22:00';
        controller.saveTask();
        controller.cancel();
      //Stop test method
      test.stopTest();
      system.assertEquals(controller.taskObject.IsReminderSet ,true);
    }
    
    //Test method
    static testMethod void testSaveWithError() {
      hitlists = TestDataFactory.createHitLists();
      insert hitlists;
      //Start test method
      test.startTest();
        ApexPages.currentPage().getParameters().put('Id', hitlists[0].Id);
        ApexPages.currentPage().getParameters().put('retUrl', hitlists[0].Id);
        
        ReminderActionController controller = new ReminderActionController();
        controller.reminderDate = date.today()-1;
        controller.timeSelected = '22:00';
        PageReference pg = controller.saveTask();
      //Stop test method
      test.stopTest();
      system.assertEquals(pg  ,null);
    }
    
    //Test method
    static testMethod void testSaveWithoutError() {
        hitlists = TestDataFactory.createHitLists();
        insert hitlists;
        //Start test method
        test.startTest();
            ApexPages.currentPage().getParameters().put('Id', hitlists[0].Id);
            ApexPages.currentPage().getParameters().put('retPage', 'hitList');
            
            ReminderActionController controller = new ReminderActionController();
            controller.reminderDate = date.today();
            controller.timeSelected = '22:00';
            controller.sendEmail = true;
            PageReference pg = controller.saveTask();
            controller.cancel();    
            controller.sendEmail = null;
            pg = controller.saveTask();
        //Stop test method
        test.stopTest();
        system.assertEquals(controller.taskObject.IsReminderSet ,true);
    }
}