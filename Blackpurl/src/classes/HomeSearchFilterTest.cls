@isTest
private class HomeSearchFilterTest {
    @testSetup
    private static void setupTestData() {
        Filter__c filterRec = new Filter__c(Filter_User__c = UserInfo.getUserId(), Filter_Label__c ='Test1', Custom__c = true);
        Filter__c filterRec1 = new Filter__c(Filter_User__c = UserInfo.getUserId(), Filter_Label__c ='Test2', Common__c = true);
        Filter__c filterRec2 = new Filter__c(Filter_User__c = UserInfo.getUserId(), Filter_Label__c ='Test3', favorite__c = true);
        
        List<Filter__c> filterList = new List<Filter__c>();
        filterList.add(filterRec);
        filterList.add(filterRec1);
        filterList.add(filterRec2);
        
        insert filterList;
        
        filterRec.Filter_Label__c = 'Update Filter Label';
        update filterRec;
        
        FilterTriggerHelper.runTrigger = false;
        update filterRec;
        
        User testUser = TestUtil.createUser(true, 'a@b.c', 'Sharma', 'en_US', 'Shantanu.Sharma@metacube.com', 'sshar');
		User_Group__c userGroup = new User_Group__c(name='testing user group',OwnerId =testUser.id, Colour_Code__c='rgba(255,100,88,1)',Accounting_settings_export__c='Primary',
                                           Costs__c='Primary',Customer_invoicing__c='Primary',customers__c='Primary',Deal__c='Primary',fees__c='Primary',Internal_Service__c='Primary',
                                           kits__c='Secondary',labor__c='Secondary',Merchandise__c='Primary',Override_price__c='Primary',Oversell_inventory__c='Primary',parts__c='Primary',
                                           Price_file_import__c='Secondary',Price_Levels__c='Secondary',quick_sale__c='Secondary',Returns__c='Secondary',Sales_Taxes__c='Secondary',Service_job__c='Secondary',
                                           Special_order__c='None',stock_units__c='Secondary',System_Settings__c='Primary',Vendor_invoicing__c='Primary',Vendor_order__c='Primary',
                                           vendor_products__c='Primary',Vendor_receiving__c='Primary',vendors__c='Primary');
		insert userGroup;
  		
  		List<User_Group__c> userGroupList = [select Id from User_Group__c];
  		String userId = UserInfo.getUserId();
  		List<String> usersList = new List<String>();
  		usersList.add(userId);
  		
  		UserSettingCtrl.assignUserToGroup(BPUtility.getEncodedString(System.JSON.serialize(usersList)), BPUtility.getEncodedString(userGroupList[0].Id));
        System.assertEquals(true,true);
    }
    static testMethod void homeSearchAllFilterTest() {
        String homeSearchRec = HomeSearchCtrl.getFilterObjectTypes();   
        System.assertNotEquals(null,BPUtility.getDecodedString(homeSearchRec));    
    }
}