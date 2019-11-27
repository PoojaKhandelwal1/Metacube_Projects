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
public class TestRewardSettingsController {
   
    //Unit test method
    static testMethod void unitTest01() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List < Referenceability_Type__c > refTypes = TestDataFactory.createReferenceabilityType();
        insert refTypes;
        test.startTest();
            PageReference pageRef = Page.RewardSettings;
            Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('customSettingId', customSetting.Id);
            RewardSettingsController controller = new RewardSettingsController();
            controller.editRewardSettings();
            PageReference pg = controller.returnCustomSettings();
            system.assertEquals(pg.getUrl(),'/'+customSetting.Id);
            controller.returnRewardSettings();
            controller.saveReferenceabilityTypes();
            try{
            	delete refTypes;
            	controller.saveReferenceabilityTypes();
            }
            catch(exception e){}
        test.stopTest();
        
    }
    
  
    //Unit test method for Sales Reward Minder Setting and when setting is enable
    static testMethod void salesRewardMinderSettingEnable() {
        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
        List<String> frequencies = new List<String>{'Weekly','Monthly','Quarterly','Annually'};
        
        test.startTest();
        
        PageReference pageRef = Page.RewardSettings;
        Test.setCurrentPage(pageRef);
        
        pageRef.getParameters().put('customSettingId', customSetting.Id);
        pageRef.getParameters().put('manage', 'true');
        
        customSetting.Enable_Sales_Rewards_Notification__c =  true;
        customSetting.Next_Notification_Date__c = Date.Today() +2; 
        upsert customSetting;
        RewardSettingsController controller = new RewardSettingsController();
        //controller.editRewardSettings();
        
        //All Positive Test cases
        //Enable Sales Reward Notifiation and Notification Date is after today and have frequency 'Weekly','Monthly','Quarterly'
        customSetting.Enable_Sales_Rewards_Notification__c =  true;
        customSetting.Next_Notification_Date__c = Date.Today() +2; 
       
       /* for(String frequency :frequencies){
	        customSetting.Sales_Rewards_Notification_Frequency__c = frequency;
	         upsert customSetting;
	        controller.saveSalesRewardMinderSettting();
        }*/
        customSetting.Sales_Rewards_Notification_Frequency__c = 'Annually';
	         upsert customSetting;
	        controller.saveSalesRewardMinderSettting();
         customSetting.Sales_Rewards_Notification_Frequency__c = 'Weekly';
	         upsert customSetting;
	        controller.saveSalesRewardMinderSettting();
         customSetting.Sales_Rewards_Notification_Frequency__c = 'Semi-Annually';
	         upsert customSetting;
	        controller.saveSalesRewardMinderSettting();
        // Negative Test cases
        
        //Enable Sales Reward Notifiation and Notification Date is before today
        customSetting.Next_Notification_Date__c = Date.Today() -1;
         upsert customSetting;
        controller.saveSalesRewardMinderSettting();
        
        //Disable Sales Reward Notification
        customSetting.Enable_Sales_Rewards_Notification__c =  false; 
         upsert customSetting;
        controller.saveSalesRewardMinderSettting();
        
        //Whene no frequency is selected
        customSetting.Sales_Rewards_Notification_Frequency__c = '';
         upsert customSetting;
	    controller.saveSalesRewardMinderSettting();
        
        //Cancel Button 
        PageReference pg = controller.returnRewardSettings();
         upsert customSetting;
        String csId = pg.getUrl().split('=')[1];
        system.assertEquals(csId, customSetting.Id);
         
        test.stopTest();
        
    }
}