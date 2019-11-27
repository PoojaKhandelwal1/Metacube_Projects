@isTest
private class ActivityHistoryTest {

    @testSetup
    private static void setupTestData() {
    	User testUser = TestDataFactory.createUser('a@b.c', 'Sharma', 'en_US', 'Shantanu.Sharma@metacube.com', 'sshar', 'America/Los_Angeles');
		User_Group__c userGroup = TestDataFactory.createUserGroup('Test User Group', testUser.Id);
  		List<User_Group__c> userGroupList = [SELECT Id from User_Group__c];
  		String userId = UserInfo.getUserId();
  		List<String> usersList = new List<String>();
  		usersList.add(userId);
  		
  		UserSettingCtrl.assignUserToGroup(BPUtility.getEncodedString(System.JSON.serialize(usersList)), BPUtility.getEncodedString(userGroupList[0].Id));
        Account vendor = TestDataFactory.createVendor('Test Vendor');
        Category__c testCategory = TestDataFactory.createCategory('Test Category');
        Price_Level__c defaultPriceLevel = TestDataFactory.samplePriceLevel('Default Price Level');
        defaultPriceLevel.Part_Price_Base__c = 'MSRP';
        defaultPriceLevel.Discount_Markup__c = 10;
        defaultPriceLevel.Default__c = true;  
        insert defaultPriceLevel;
        
        Sales_Tax__c defaultSalesTax = TestDataFactory.createSalesTax('Test Sales Tax');
        Account customer = TestDataFactory.createCustomer('Test Customer', 'Individual', 'Test', 'Customer');
        CO_Header__c coHeader = TestDataFactory.createCoHeader(customer.Id);
        Vendor_Order_Header__c voHeader = TestDataFactory.createVendorOrderHeader(vendor.Id);  
        Part__c part2 = TestDataFactory.createPart(vendor.Id, 10, 20, 50, 100, 2, testCategory.Id);
        CO_Line_Item__c coLineItemRec = TestDataFactory.sampleCoLineItem(coHeader.Id, 2);
        coLineItemRec.Part__c = part2.Id;
        insert coLineItemRec;
        
        Vendor_Order_Line_Item__c voLineItem = TestDataFactory.sampleVendorOrderLineItem(voHeader.Id);
        voLineItem.Part__c = part2.Id;
        voLineItem.Qty_Ordered__c = 250;
        insert voLineItem;
	}
    
    static testMethod void createActivityHistoryTest() {
    	CO_Header__c coHeader = [SELECT Id from CO_Header__c LIMIT 1];
    	Account customer = [SELECT Id from Account WHERE Is_Customer__c = true LIMIT 1];
    	Account vendor = [SELECT Id from Account WHERE Is_Vendor__c = true LIMIT 1];
    	Vendor_Order_Header__c voHeader = [SELECT Id from Vendor_Order_Header__c LIMIT 1];
        Test.startTest();
        ActivityHistory.createActivityHistory('Checkout Quick Sale', 'Customer Invoice', coHeader.Id, 'Customer', customer.Id, null);
        ActivityHistory.createActivityHistory('Submit Vendor Order', 'Vendor Order', voHeader.Id, 'Vendor', vendor.Id, null);
        ActivityHistory.createActivityHistory('Checkout Quick Sale', 'Customer Invoice', coHeader.Id, 'Customer', null, null);
        Test.stopTest();
        system.assertEquals(1, [SELECT Id from Vendor_Order_Line_Item__c].size());
    }
    
    static testMethod void getActivityHistoryFieldListTest() {
    	system.assertEquals(6, ActivityHistory.getActivityHistoryFieldList().size());
    }
    
    static testMethod void getActivityHistoryListTest() {
    	String json = '{"Type":"My Activity","RequiredNumberOfRecords":2}';
    	String result = ActivityHistory.getActivityHistoryList(json);
    	List<ActivityHistory.ActivityHistoryWrapper> activityHistoryWrapperList = (List<ActivityHistory.ActivityHistoryWrapper>)
    	                                               System.json.deserialize(result, List<ActivityHistory.ActivityHistoryWrapper>.class);
    	system.assertEquals(0, activityHistoryWrapperList.size());
    }
    
    static testMethod void getActivityHistoryListTestWithTypeStoreActivity() {
    	String json = '{"Type":"Store Activity","RequiredNumberOfRecords":3}';
    	String result = ActivityHistory.getActivityHistoryList(json);
    	List<ActivityHistory.ActivityHistoryWrapper> activityHistoryWrapperList = (List<ActivityHistory.ActivityHistoryWrapper>)
                                                       System.json.deserialize(result, List<ActivityHistory.ActivityHistoryWrapper>.class);
    	system.assertEquals(0, activityHistoryWrapperList.size());
    }
    
    static testMethod void getActivityHistoryListTestWithTypeIntegration() {
    	String json = '{"Type":"Integration","RequiredNumberOfRecords":1}';
    	String result = ActivityHistory.getActivityHistoryList(json);
    	List<ActivityHistory.ActivityHistoryWrapper> activityHistoryWrapperList = (List<ActivityHistory.ActivityHistoryWrapper>)
                                                       System.json.deserialize(result, List<ActivityHistory.ActivityHistoryWrapper>.class);
    	system.assertEquals(0, activityHistoryWrapperList.size());
    }
}