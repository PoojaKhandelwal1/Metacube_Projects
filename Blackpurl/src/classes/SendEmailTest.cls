@isTest
private class SendEmailTest {

    static testMethod void emailTest() {
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        Transaction_Type__c transactionType =  TestUtil.createTransactionType(false, 'Third-Party', 'Third-Party');
        //transactionType.Third_Party_Customer__c = customer.Id;
        insert transactionType ;
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        part.Packaged_Part__c = false;
        part.Qty_On_Order__c = 0;
        part.Order_Lots__c = 2;
        insert part;
        
        Test.startTest();
        String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
        List<Service_Order_Header__c> soHeaderList = [select Id from Service_Order_Header__c limit 1];
        List<String> emailStrList = new List<String>{'test@test.com'};
       	SendEmail.send(emailStrList, 'Test Subject', 'Test Body', soHeaderList[0].Id);
       	SendEmail.sendSupportMail(emailStrList, 'Test Subject', 'Test Body');
       	
       	SendEmail.send(new List<String>(), 'Test Subject', 'Test Body', soHeaderList[0].Id);
       	SendEmail.sendSupportMail(new List<String>(), 'Test Subject', 'Test Body');
        Test.stopTest();
        
        system.assertEquals(1, [select Id from Service_Order_Header__c limit 1].size());
    }
}