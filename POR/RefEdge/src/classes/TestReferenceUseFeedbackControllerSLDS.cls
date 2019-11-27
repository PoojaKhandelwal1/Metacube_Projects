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
 * Class : ReferenceUseFeedbackControllerSLDS
 * Description :Test class for ReferenceUse Feedback Lightning page
 * Modified by: Rajesh @25 April 2017
 */ 
@isTest
private class TestReferenceUseFeedbackControllerSLDS {
  public static Custom_Settings__c customSetting;
    public static List<Referenceability_Type__c> refTypes;
    public static List<Account> accounts;
    public static List<Contact> contacts;
    public static List<Opportunity> opps;
    public static List<Reference_Request__c> refReqs;
    public static List<Task> tasks;
    public static List<Reference_Request_Account__c> refReqAccs;
    
    static testMethod void createContactReferenceabilityTypesTest() {
        createData();
		List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId = :refReqAccs[0].Account__c];
		
        selectContactToApproveRefRequest();
        List<Referenceability__c> newlyInsertedContactReferenceabilityList1 = [SELECT Id FROM Referenceability__c WHERE Contact__c IN: contactList];
        system.assertEquals(newlyInsertedContactReferenceabilityList1.size(), 1); 
        
        createAccountRequest();
        selectContactToApproveRefRequest();
        List<Referenceability__c> newlyInsertedContactReferenceabilityList2 = [SELECT Id FROM Referenceability__c WHERE Contact__c IN: contactList];
        system.assertEquals(newlyInsertedContactReferenceabilityList2.size(), 1); 
    }
    
    private static void createAccountRequest() {
    	List<Reference_Request_Account__c> refRequestAcc = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refRequestAcc){
            rra.Task_ID__c = tasks[0].Id;
            rra.Account_Request_Status__c = 'Completed';
        }
        refRequestAcc[1].Approve_Deny_Notes__c = 'Approved';
        refRequestAcc[1].Approval_Status__c = 'Approved';
        refRequestAcc[2].Approve_Deny_Notes__c = 'Declined';
        refRequestAcc[2].Approval_Status__c = 'Declined';
        insert refRequestAcc;
    }
    
    private static void selectContactToApproveRefRequest() {
    	Contact con = [SELECT Id,AccountId FROM Contact WHERE AccountId = :refReqAccs[0].Account__c];
        PageReference pageRef = Page.SelectReferenceUseContacts;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', refReqAccs[0].Id);
        ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[0]);
        String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
        SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
        SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, con.Id, true);
    }
        
    /* Test method to test GetPageDetails */  
    static testMethod void TestToGetPageDetails() {
        createData();
        //Start Test Method
        Test.startTest();
            Contact con = [SELECT Id,AccountId FROM Contact WHERE AccountId = :refReqAccs[0].Account__c];
            PageReference pageRef = Page.SelectReferenceUseContacts;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', refReqAccs[0].Id);
            ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[0]);
            String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, con.Id, true);
            Reference_Request_Account_Contact__c rrac = [SELECT Id, Feedback_Status__c, Task_ID__c FROM Reference_Request_Account_Contact__c 
                                    WHERE Reference_Request_Account__c = : refReqAccs[0].Id];
            rrac.Feedback_Status__c = ConstantsController.FEEDBACK_SUCCESSFUL;
            rrac.Task_ID__c = tasks[0].Id;
            update rrac;
            
            pageRef = Page.ReferenceUseFeedback;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', rrac.Id);
            ReferenceUseFeedbackControllerSLDS RUFObj = new ReferenceUseFeedbackControllerSLDS();
            ReferenceUseFeedbackControllerSLDS.getPageDetails(rrac.Id); 
            List<ReferenceUseFeedbackControllerSLDS.PageInputWrapper> inputWrapperList = ReferenceUseFeedbackControllerSLDS.getPageDetails(rrac.Id);
            system.assertNotEquals(ReferenceUseFeedbackControllerSLDS.getDateFormat(), ''); 
            system.assertEquals(inputWrapperList.size(), 1); 
        //Stop Test Method
        Test.stopTest();
    }
    
    /* Test method to test SendUpdate */ 
    static testMethod void TestForSetUpdate() {
      createData();
      Boolean isWeekend = false;
      //Start Test Method
      Test.startTest();
          Contact con = [SELECT Id,AccountId FROM Contact WHERE AccountId = :refReqAccs[0].Account__c];
          PageReference pageRef = Page.SelectReferenceUseContacts;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('id', refReqAccs[0].Id);
          ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[0]);
          String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, con.Id, true);
          Reference_Request_Account_Contact__c rrac = [SELECT Id, Feedback_Status__c, Task_ID__c FROM Reference_Request_Account_Contact__c 
                                  WHERE Reference_Request_Account__c = : refReqAccs[0].Id];
          rrac.Feedback_Status__c = ConstantsController.FEEDBACK_SUCCESSFUL;
          rrac.Task_ID__c = tasks[0].Id;
          update rrac;
          
          pageRef = Page.ReferenceUseFeedback;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('id', rrac.Id);
          ReferenceUseFeedbackControllerSLDS RUFObj = new ReferenceUseFeedbackControllerSLDS();
          ReferenceUseFeedbackControllerSLDS.getPageDetails(rrac.Id); 
          List<ReferenceUseFeedbackControllerSLDS.PageInputWrapper> inputWrapperList = ReferenceUseFeedbackControllerSLDS.getPageDetails(rrac.Id); 
          isWeekend = isItWeekend(Date.valueOf(inputWrapperList[0].useDate));
          
          String result = ReferenceUseFeedbackControllerSLDS.sendUpdate(rrac.Id, ConstantsController.FEEDBACK_YET_NOT_COMPLETED, 
                                          ConstantsController.FEEDBACK_YET_NOT_COMPLETED,inputWrapperList[0].useDate,
                                          inputWrapperList[0].requesterId,inputWrapperList[0].requesterId);
                                           
          if (isWeekend) {
             system.assertEquals(true,result.contains('Error'));
          } else {
             system.assertEquals(false,result.contains('Error'));
          }  
           Date dt = Date.valueOf(inputWrapperList[0].useDate).addDays(2); 
                                         
           if (isWeekend) {
             result = ReferenceUseFeedbackControllerSLDS.sendUpdate(rrac.Id, ConstantsController.FEEDBACK_YET_NOT_COMPLETED, 
                                          ConstantsController.FEEDBACK_YET_NOT_COMPLETED,String.valueOf(dt),
                                          inputWrapperList[0].requesterId,inputWrapperList[0].requesterId);
              system.assertEquals(false,result.contains('Error'));
           } 
           
          result = ReferenceUseFeedbackControllerSLDS.sendUpdate(rrac.Id,'Use will not occur','Use will not occur', inputWrapperList[0].useDate,
                                    inputWrapperList[0].requesterId,inputWrapperList[0].requesterId); 
                                    
          system.assertEquals(false,result.contains('Error'));
                                
      //Stop Test Method
      Test.stopTest();
  }
  
  /* Test method to test SendUpdate */ 
    static testMethod void TestForGetPageError() {
      createData();
      Boolean isWeekend = false;
      //Start Test Method
      Test.startTest();
          Contact con = [SELECT Id,AccountId FROM Contact WHERE AccountId = :refReqAccs[0].Account__c];
          PageReference pageRef = Page.SelectReferenceUseContacts;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('id', refReqAccs[0].Id);
          ApexPages.StandardController sc = new ApexPages.standardController(refReqAccs[0]);
          String contactsJSON = SelectRefUseContactsControllerSLDS.fetchContacts(refReqAccs[0].Account__c);
            SelectRefUseContactsControllerSLDS.CustomSettingWrapper customSettingsJSON = SelectRefUseContactsControllerSLDS.fetchCS();
            SelectRefUseContactsControllerSLDS.approve(refReqAccs[0].Id, 'test acc name', 'approving', contactsJSON, customSettingsJSON, con.Id, true);
          Reference_Request_Account_Contact__c rrac = [SELECT Id, Feedback_Status__c, Task_ID__c FROM Reference_Request_Account_Contact__c 
                                  WHERE Reference_Request_Account__c = : refReqAccs[0].Id];
          rrac.Feedback_Status__c = ConstantsController.FEEDBACK_SUCCESSFUL;
          rrac.Task_ID__c = tasks[0].Id;
          update rrac;
          
          pageRef = Page.ReferenceUseFeedback;
          Test.setCurrentPage(pageRef);
          ApexPages.currentPage().getParameters().put('id', rrac.Id);
          ReferenceUseFeedbackControllerSLDS RUFObj = new ReferenceUseFeedbackControllerSLDS();
          ReferenceUseFeedbackControllerSLDS.getPageDetails(rrac.Id); 
          List<ReferenceUseFeedbackControllerSLDS.PageInputWrapper> inputWrapperList = ReferenceUseFeedbackControllerSLDS.getPageDetails(rrac.Id); 
          isWeekend = isItWeekend(Date.valueOf(inputWrapperList[0].useDate));
           
          String result = ReferenceUseFeedbackControllerSLDS.sendUpdate(rrac.Id,'Use will not occur','Use will not occur', inputWrapperList[0].useDate,
                                    inputWrapperList[0].requesterId,Null); 
                                    
          system.assertEquals(true,result.contains('Error'));
                                
      //Stop Test Method
      Test.stopTest();
  }
  
    
     /* Test method to test getFeedbackStatus */
  static testMethod void TestforGetFeedbackStatus() {
      createData();
      //Start Test Method
      Test.startTest(); 
          
          List < Reference_Request_Account_Contact__c > refReqCons = TestDataFactory.createContactRequests(contacts, refReqAccs, refTypes);         
          insert refReqCons;
          
          List<ReferenceUseFeedbackControllerSLDS.FeedbackStatus> inputWrapperList = ReferenceUseFeedbackControllerSLDS.getFeedbackStatus(); 
          system.assertEquals(5,inputWrapperList.size());
      //Stop Test Method
      Test.stopTest();
  }
    
    /**
     * Method to Check whether deadline is Offday or Not
     */
    public static Boolean isItWeekend(Date deadline) {
        Boolean isItOffDay = false;
        DateTime deadlineDateTime = Datetime.newInstance(deadline.year(), deadline.month(), deadline.day());
        Custom_Settings__c cs = UtilityController.getCustomSettings();
        Boolean checkIncludeWeekends = cs.Include_Weekends__c;
        
        if (checkIncludeWeekends) {
          
            for (String days: cs.Days_of_Week__c.split(';')) {
              
                if (deadlineDateTime.format('EEEE') == days) {
                    isItOffDay = true;
                    break;
                }
            }
        }
        return isItOffDay;
    }
    
     /* Custom_Settings SetUp */ 
    private static void createData() {
        customSetting = TestDataFactory.createCustomSetting(); 
        customSetting.Sales_Reward_Point_Chatter__c = true; 
        customSetting.Sales_Reward_Point_Email__c = true; 
        customSetting.Enable_Sales_Rewards_Notification__c = true;  
        customSetting.Refedge_P2P_Use_Adds_Ref__c = true; 
        update customSetting;
        TestDataFactory.createCustomNotifications();
        refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        accounts = TestDataFactory.createAccounts();
        insert accounts;
        TestDataFactory.setUpAccountRBI(accounts);
        contacts = TestDataFactory.createContacts(accounts);
        insert contacts;
        TestDataFactory.setUpContactRBI(contacts);
        opps = TestDataFactory.createOpportunity(accounts);
        insert opps;
        tasks = TestDataFactory.createTask();
        insert tasks;
        refReqs = new list<Reference_Request__c>{TestDataFactory.createReferenceRequest()[0]};
        refReqs[0].Opportunity__c = opps[0].Id;
        insert refReqs;
        refReqAccs = TestDataFactory.createAccountRequests(accounts, refReqs, refTypes);
        for(Reference_Request_Account__c rra : refReqAccs){
            rra.Task_ID__c = tasks[0].Id;
            rra.Account_Request_Status__c = 'Completed';
        }
        refReqAccs[1].Approve_Deny_Notes__c = 'Approved';
        refReqAccs[1].Approval_Status__c = 'Approved';
        refReqAccs[2].Approve_Deny_Notes__c = 'Declined';
        refReqAccs[2].Approval_Status__c = 'Declined';
        insert refReqAccs;
    }
}