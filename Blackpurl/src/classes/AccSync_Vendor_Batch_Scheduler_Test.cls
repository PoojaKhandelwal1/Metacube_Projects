/**
 * Author: Pooja Khandelwal
 * Since: Jun 7, 2018
 * Name: AccSync_Vendor_Batch_Scheduler_Test
 * Description: batch scheduler test Class of Vendor sync to QuickBooks.
**/
@isTest
public class AccSync_Vendor_Batch_Scheduler_Test {
    static PaginationSorting pageSort;
    @testSetup
    static void setup() {
        TestUtil.setQuickBooksConfigurations(true);
        
        Account vendorObj = TestUtil.createVendor(true, 'QB Vendor');
        system.assert(true, true);
    }
    
    private static testmethod void syncVendorsTest() {
        TestUtil.setQuickBooksConfigurations(false);
        List<Account> vendorList = [Select Id, Vendor_AvailForQBSync__c from Account];
        Set<Id> vendorIdSet = new Set<Id>();
    	for(Account vendor : vendorList) {
    		if(vendor.Vendor_AvailForQBSync__c) {
    			vendorIdSet.add(vendor.Id);
    		}
    	}  
    	
        Test.startTest();
        if(vendorIdSet.size() > 0) {
        	//Sync Vendor to QB if they are not synced yet
            AccSync_Vendor_Batch_Scheduler vendorSync = new AccSync_Vendor_Batch_Scheduler(vendorIdSet, 10);
            vendorSync.execute(null);
        }
        Test.stopTest();
        
        List<Account> vendorRecList = [Select Id, Vendor_AccountingId__c, Vendor_availForQBSync__c from Account];
        system.assertEquals('170', vendorRecList[0].Vendor_AccountingId__c); 
    }
}