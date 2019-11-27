@isTest
public class VendorDetailWrapperTest {
	
	@testSetup
    private static void setupTestData() {
    	Account vendorRec = TestDataFactory.createVendor('Test Vendor');
    }
    
    @isTest
    private static void vendorDetailWrapperTest() {
    	List<Account> vendorList = [SELECT Id, Name, Preferred_Email__c, Work_Email__c, Other_Email__c FROM Account];
    	VendorDetailWrapper vendorDetailWrapper = new VendorDetailWrapper(vendorList[0]);
    	system.assertEquals(vendorDetailWrapper.VendorId, vendorList[0].Id);
    }
    
    @isTest
    private static void vendorDetailWrapperConstructorTest() {
    	VendorDetailWrapper vendorDetailWrapper = new VendorDetailWrapper();
    	system.assertEquals(vendorDetailWrapper.VendorId, null);
    }
    
    @isTest
    private static void fieldsListTest() {
    	List<String> fieldsList = VendorDetailWrapper.fieldsList();
    	system.assertEquals(fieldsList.size(), 4);
    }
}