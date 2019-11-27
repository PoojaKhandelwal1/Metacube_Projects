/**
 * Author: Pooja Khandelwal
 * Since: Jan. 3, 2017
 * Name: AccSync_Vendor_Batch_Test
 * Description: Test class for AccSync_Vendor_Batch
**/
@isTest
private class  AccSync_Vendor_Batch_Test {
    @testSetup
    private static void setup()	{
    	General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
    	genConfig.Enable_QB_Accounting__c = true;
    	update genConfig;
    	
    	QuickBooks_Configurations__c QBConfig = new QuickBooks_Configurations__c(Consumer_Key__c = 'qyprdFawAAiD3SLud6d5RvREaVOoAn',
    					 Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr', OAuth_Token__c = 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj', 
    					 OAuth_Token_Secret__c = 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO', Company_Id__c = '123145730762509', 
    					 End_Point_URL__c ='https://sandbox-quickbooks.api.intuit.com/v3/company/', Enable_QuickBooks__c = true);
        
        insert QBConfig;
        system.assert(true, true);
    }
    
    private static testmethod void syncVendorsToQBTest() {
    	Test.startTest();
    	Account Vendor = TestUtil.createVendor(true, 'Qb Vendor');
        Test.stopTest();
        String res = '{"WebAddr":{"URI":""},"sparse":true,"ShipAddr":{"PostalCode":"","Line2":"","Line1":"","CountrySubDivisionCode":"","Country":"","City":""},"PrimaryPhone":{},"PrimaryEmailAddr":{"Address":""},"Mobile":{},"Fax":{},"DisplayName":"Qb Vendor VDR-0001","CompanyName":"Qb Vendor","BillAddr":{"PostalCode":"","Line2":"","Line1":"","CountrySubDivisionCode":"","Country":"","City":"Jaipur"},"AlternatePhone":{},"Active":true} {"Vendor":{"BillAddr":{"Id":"296","Line1":"Metacube software Pvt ltd","Line2":"SP-6, Phase-IV","City":"Black River-City","Country":"Mauritius","CountrySubDivisionCode":"Black River","PostalCode":"111111111"},"Balance":0,"AcctNum":"VendorQuickBook1/ACQB1","Vendor1099":false,"CurrencyRef":{"value":"USD","name":"United States Dollar"},"domain":"QBO","sparse":false,"Id":"170","SyncToken":"0","MetaData":{"CreateTime":"2016-12-20T23:46:16-08:00","LastUpdatedTime":"2016-12-20T23:46:16-08:00"},"CompanyName":"VendorQuickBook1","DisplayName":"VendorQuickBook1 VDR-0012","PrintOnCheckName":"VendorQuickBook1","Active":true,"PrimaryPhone":{"FreeFormNumber":"1111111111"},"AlternatePhone":{"FreeFormNumber":"2222222222"},"Mobile":{"FreeFormNumber":"2222222222"},"Fax":{"FreeFormNumber":"3333333333"},"PrimaryEmailAddr":{"Address":"vendorquickbook1@metacube.com"},"WebAddr":{"URI":"http://www.metacube.com"}},"time":"2016-12-20T23:46:15.902-08:00"}';
        List<Account> acc = [Select Id, Vendor_AccountingResponse__c, Vendor_AccountingId__c From Account Where Is_Vendor__c = true];
        System.debug('************'+acc);
        system.assertEquals(acc[0].Vendor_AccountingResponse__c != null, true); 
    }
}