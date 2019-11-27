/**
 * Author: Rajat Jain
 * Since: June 5, 2018
 * Name: AccSync_FIFOBucActivitLI_Batch_SchTest 
 * Description: test Class for AccSync_FIFOBucActivitLI_Batch_SchTest.
**/

@isTest
public with sharing class AccSync_FIFOBucActivitLI_Batch_SchTest {
	static String CRON_EXP = '0 0 0 * * ? *';
	
	@testSetup
   	static void setup() {
   		TestUtil.setQuickBooksConfigurations(true); 
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, null);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        String partsJSONString = BPUtility.getDecodedString(ViewPartCtrl.getPartInfo(BPUtility.getEncodedString(part.Id)));
        PartDetailWrapper partObjRec = (PartDetailWrapper) System.JSON.deserialize(partsJSONString, PartDetailWrapper.class);
       
        String modifyCost = BPUtility.getDecodedString(ViewPartCtrl.modifyCostSummary(BPUtility.getEncodedString(System.JSON.serialize(partObjRec.PartFIFOBucketList)), 50));
        
	   	system.assertEquals(true, String.isNotBlank(vendor.Id));
   	} 
   	
   	static testmethod void partFIFOBucketActivityLITest() {
		Test.startTest();
		TestUtil.setQuickBooksConfigurations(false);
		Map<Id, Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketActivityLIIdToRecMap = new Map<Id, Part_FIFO_Bucket_Activity_Line_Item__c>([Select Id FROM Part_FIFO_Bucket_Activity_Line_Item__c]);
   		AccSync_FIFOBucActivitLI_Batch_Scheduler partFIFOBucketActivityLIObj = new AccSync_FIFOBucActivitLI_Batch_Scheduler(partFIFOBucketActivityLIIdToRecMap.keySet(), 10);
   		//system.schedule('AccSync_FIFOBucActivitLI_Batch_Scheduler', CRON_EXP, partFIFOBucketActivityLIObj);
   		partFIFOBucketActivityLIObj.execute(null);
   		Test.stopTest();
   		
        system.assertEquals(false, [Select Id, availForQBSync__c FROM Part_FIFO_Bucket_Activity_Line_Item__c][0].availForQBSync__c);
	} 
}