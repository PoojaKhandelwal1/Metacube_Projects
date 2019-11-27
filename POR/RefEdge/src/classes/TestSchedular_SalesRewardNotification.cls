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
public with sharing class TestSchedular_SalesRewardNotification {
	public static testMethod void testschedule() {
        Test.StartTest();
        	Schema.SObjectType objectType = CRUDAndFLSCheckController.sObjectsMap.get(UtilityController.appNamespace() + 'Hit_List__c');
			Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
	        Custom_Settings__c customSetting = TestDataFactory.createCustomSetting();
	        customSetting.Shared_Contacts__c = true;
	        customSetting.Shared_Contact_Object__c = describeResult.getName();
			customSetting.Shared_Account_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Account__c').getDescribe().getName();
			customSetting.Shared_Contact_Field__c = describeResult.fields.getMap().get(UtilityController.appNamespace() + 'Contact__c').getDescribe().getName();
			customSetting.Roll_up_Attributes_to_Primary_Account__c = true;
	        customSetting.Roll_up_Referenceability_to_Primary_Acc__c = true;
	        customSetting.Inherit_Attributes_from_All_Accounts__c = true;
			update customSetting;
            Schedular_SalesRewardNotification schedularClass = new Schedular_SalesRewardNotification();
            //Scheduling Every month 1:00 AM
            String sch = '0 0 1 * * ?';
            String scheduleId = system.schedule('Schedular_SalesRewardNotification class', sch, schedularClass);
        	for(integer i=0;i<=5;i++){
             system.schedule('Schedular_SalesRewardNotification class'+i, sch, schedularClass);
        	}
       		system.schedule('Schedular_SalesRewardNotification class9', sch, schedularClass);
            system.assert(scheduleId != null);
        Test.stopTest();
    }
}