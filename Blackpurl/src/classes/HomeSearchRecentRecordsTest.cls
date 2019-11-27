@isTest
private class HomeSearchRecentRecordsTest {

    @testSetup
    private static void setupTestData() {
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
  		system.assert(true,true);
    }
    
    static testMethod void testGetOrgBlankSearchResults_NameInAscendingOrder(){
        
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Name', 'ASC')
        };
        
        List<SObject> records = HomeSearchRecentRecords.getOrgBlankSearchResults(pageSort, new HomeSearchFilterWrapper()); //Added by Nikhil - 06/03/17
        for(SObject obj : records){
            if(obj.getSObjectType() == acc.getSObjectType())
                System.assertEquals('Test Customer', obj.get(Schema.Account.Name));         
        }
    }
    
    static testMethod void testGetOrgBlankSearchResults_TypeInDescOrder(){
        
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Type', 'DESC')
        };
        
        List<SObject> records = HomeSearchRecentRecords.getOrgBlankSearchResults(pageSort, new HomeSearchFilterWrapper()); //Added by Nikhil - 06/03/17
        for(SObject obj : records){
            if(obj.getSObjectType() == testCategory.getSObjectType())
                System.assertEquals('Test Category', obj.get(Schema.Category__c.Name));         
        }
    }
}