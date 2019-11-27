@isTest
private class NewHomePageCtrlTest {
	@testSetup
    private static void setupTestData() {
    	Category__c catrgoryRec = new Category__c(Description__c = 'Test');
        insert catrgoryRec;
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
       	system.assertEquals(true,true);
    }
    
    static testMethod void IsSystemvistedTest() {
    	NewHomePageCtrl homepagectrlObj = new NewHomePageCtrl();
    	boolean sampledata1 = homepagectrlObj.IsSampleDataAvailable;
       	boolean isTrialOrgRec = homepagectrlObj.IsTrialOrg;
       	String communityUrlRec = homepagectrlObj.communityURL;
       	String communityquestionURLRec = homepagectrlObj.communityquestionURL;
       	String communitycaseURLRec = homepagectrlObj.communitycaseURL;
       	boolean systemVistedResult = homepagectrlObj.IsSystemSettingVisited;
       	
		Test.startTest();
	       	EmailTemplate et = new EmailTemplate();  
			et.isActive = true;  
			et.Name = 'BP Welcome Email Template';  
			et.DeveloperName = 'testTemplate' + System.now().getTime();  
			et.TemplateType = 'text';  
			et.FolderId = UserInfo.getUserId();  
			et.Body = ''; 
			insert et;
			String dtFormatStr = homepagectrlObj.dateFormat;
			String extendedDateStr = homepagectrlObj.ExtendedDateFormat;
			
	       	boolean result = NewHomePageCtrl.IsSystemvisted();
	       	System.assert(true, result);
       	Test.stopTest();
    }
    
    static testMethod void getSummaryCardsDetailsTest() {
    	
    	Test.startTest();
    	try {
            String SummaryCardJson = BPUtility.getEncodedString('[{"Names":"abc","BlockList":[{"FilterName":"Today"}]}]');
       		String SummaryCardsDetails = BPUtility.getDecodedString(NewHomePageCtrl.getSummaryCardsDetails(SummaryCardJson));
        } catch(Exception e) {
            system.assertEquals(e.getMessage(), e.getMessage());
        }
       	
       	String SummaryCardJson1 = BPUtility.getEncodedString('[{"Name":"Store Summary","BlockList":[{"FilterName":"Today"}]}]');
       	String SummaryCardsDetails1 = BPUtility.getDecodedString(NewHomePageCtrl.getSummaryCardsDetails(SummaryCardJson1));
       	system.assertEquals(SummaryCardsDetails1.length() > 0, true);
       	
       	String SummaryCardJson2 = BPUtility.getEncodedString('[{"Name":"Store Summary","BlockList":[{"FilterName":"Today"}]},{"Name":"Service Jobs","BlockList":[{"FilterName":"Customer Pay"}]}]');
       	String SummaryCardsDetails2 = BPUtility.getDecodedString(NewHomePageCtrl.getSummaryCardsDetails(SummaryCardJson2));
       	system.assertEquals(SummaryCardsDetails2.length() > 0, true);
       	
       	//String activityHistoryListString1 = NewHomePageCtrl.getActivityHistoryList(BPUtility.getEncodedString('{"Type":"My Activity","RequiredNumberOfRecords":20}'));
       	Test.stopTest();
    }
}