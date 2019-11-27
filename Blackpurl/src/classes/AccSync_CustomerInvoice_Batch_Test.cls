/**
 * Author: Richa Mittal
 * Since: Jan 3, 2017
 * Name: AccSync_Customer_Batch test
 * Description: batch test Class of customer sync to QuickBooks.
**/
@isTest
public with sharing class AccSync_CustomerInvoice_Batch_Test {
	private static Integer uniqueNumber = 1;
	@testSetup
    static void setup() {
    	QuickBooks_Configurations__c qbConfig = new QuickBooks_Configurations__c();
		qbConfig.Consumer_Key__c = 'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbConfig.Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        qbConfig.OAuth_Token__c = 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj';
        qbConfig.OAuth_Token_Secret__c = 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO';
        qbConfig.Company_Id__c = '123145730762509';
		qbConfig.Enable_QuickBooks__c = true;   
		insert qbConfig;
		
		insert new General_Configurations__c(Enable_QB_Accounting__c = true);
		
    	system.assert(true,true);
    }
	
    static testmethod void test1() {
        List<Account> accList = new List<Account>();
        Account customer = AccSync_CustomerInvoice_Batch_Test.createCustomer(true, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123', null, null, false, true, null, null, null, null, null, null, null, null, null, null, null);
    	
   		Account vendor = AccSync_CustomerInvoice_Batch_Test.createVendor(true, 'Test Vendor', 'test.vendor@gmail.com', 'Jaipur', '123456789');
   		accList.add(customer);
   		accList.add(vendor);
   		accList = AccSync_CustomerInvoice_Batch_Test.createCustomersAndVendors(accList);
   		
   		for(Account acc: accList) {
   			if(acc.Is_Customer__c) {
   				customer = acc;
   			} else if(acc.Is_Vendor__c) {
   				vendor = acc;
   			}
   		}
	    Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
	    Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
	    Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
	    Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
	    
	    CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
	    CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
	    Test.startTest();
	    list<Account> customerlist = [select Id, AccountingId__c from Account where Is_Customer__c = true];
	    list<CO_Header__c> coHeaderIdlist = [select Id from CO_Header__c];
	    
	    list<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c];
	   
	     List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
	    
	    String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeaderIdlist[0].Id), BPUtility.getEncodedString('Customer')));
	    Test.stopTest();
	    
	    List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketActivityLI = [select Id, AccountingId__c, CO_Invoice_Header__c from Part_FIFO_Bucket_Activity_Line_Item__c where CO_Invoice_Header__c =: coInvoiceHeaderlist[0].Id];
	    CO_Invoice_Header__c responseCOInvoiceHeader = [select  AccountingId__c, AccountingResponse__c, Invoice_Status__c, JournalEntryAccountingId__c from CO_Invoice_Header__c where ID = :coInvoiceHeaderlist[0].Id];
   		system.assertEquals('1075', responseCOInvoiceHeader.AccountingId__c);
   		system.assertEquals('675', responseCOInvoiceHeader.JournalEntryAccountingId__c);
    }
    
    static testmethod void finalizeInvoiceWithTaxCodeSettingOnTest() {
        
        TestUtil.setQBTaxCodesConfigurations(true);
        List<Account> accList = new List<Account>();
        Account customer = AccSync_CustomerInvoice_Batch_Test.createCustomer(true, 'Test Customer', 'a.b@gmail.com', 'Jaipur', '987456123', null, null, false, true, null, null, null, null, null, null, null, null, null, null, null);
        
        Account vendor = AccSync_CustomerInvoice_Batch_Test.createVendor(true, 'Test Vendor', 'test.vendor@gmail.com', 'Jaipur', '123456789');
        accList.add(customer);
        accList.add(vendor);
        accList = AccSync_CustomerInvoice_Batch_Test.createCustomersAndVendors(accList);
        
        for(Account acc: accList) {
            if(acc.Is_Customer__c) {
                customer = acc;
            } else if(acc.Is_Vendor__c) {
                vendor = acc;
            }
        }
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Sales_Tax__c zeroSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax zero', true, true, true);
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, defaultSalesTax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, defaultSalesTax.Id, salesTaxItem1.Id);
        Part__c part = TestUtil.createPart(false, 'part1', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        part.Applicable_Tax__c = defaultSalesTax.Id;
        insert part;
        
        Part__c partWithZeroAppTax = TestUtil.createPart(false, 'part2', vendor.Id, 'Test Part2', testCategory.Id, 10, 20, 50, 100, 100);
        partWithZeroAppTax.Applicable_Tax__c = zeroSalesTax.Id;
        insert partWithZeroAppTax;
        
        Part__c partNonTaxable = TestUtil.createPart(true, 'part3', vendor.Id, 'Test Part3', testCategory.Id, 10, 20, 50, 100, 100);
        
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem1 = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 20);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, false, true, unitMake.Id, unitModel.Id);
        Kit_Header_Line_Item__c kitHeaderLineItem = TestUtil.createKitHeaderLineItem(true, false, false, KitHeader.Id, 5.0, null, partWithZeroAppTax.Id, 1, 5.0);
        CO_Line_Item__c coLineItem2 = TestUtil.createCOLineItem(true, coHeader.Id, partWithZeroAppTax.Id, 10);
        CO_Line_Item__c coLineItem3 = TestUtil.createCOLineItem(true, coHeader.Id, partNonTaxable.Id, 5);
        Test.startTest();
        list<Account> customerlist = [select Id, AccountingId__c from Account where Is_Customer__c = true];
        list<CO_Header__c> coHeaderIdlist = [select Id from CO_Header__c];
        
        list<CO_Invoice_Header__c> coInvoiceHeaderlist = [select  Status__c, Total_Payment__c from CO_Invoice_Header__c];
       
         List<CO_Invoice_Item__c> COInvoiceItems = [select Category__c, CO_Line_Item__c, isActive__c, Item_Category_Code__c, Item_ID__c, Item_Type__c, Price__c, Qty__c from CO_Invoice_Item__c];
        
        String COInvoiceItemJSON = BPUtility.getDecodedString(CustomerOrderCtrl.getCOInvoiceItemsByCOInvoiceHeaderId(BPUtility.getEncodedString(coInvoiceHeaderlist[0].Id)));
        String closedOrder = BPUtility.getDecodedString(CustomerOrderCtrl.closedorderAction(BPUtility.getEncodedString(COInvoiceItemJSON), BPUtility.getEncodedString(coHeaderIdlist[0].Id), BPUtility.getEncodedString('Customer')));
        Test.stopTest();
        
        List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketActivityLI = [select Id, AccountingId__c, CO_Invoice_Header__c from Part_FIFO_Bucket_Activity_Line_Item__c where CO_Invoice_Header__c =: coInvoiceHeaderlist[0].Id];
        CO_Invoice_Header__c responseCOInvoiceHeader = [select  AccountingId__c, AccountingResponse__c, Invoice_Status__c, JournalEntryAccountingId__c from CO_Invoice_Header__c where ID = :coInvoiceHeaderlist[0].Id];
        system.assertEquals('1075', responseCOInvoiceHeader.AccountingId__c);
        system.assertEquals('675', responseCOInvoiceHeader.JournalEntryAccountingId__c);
    }
    
    private static Account createCustomer(boolean isInsert, String customerName, String email, String billingCity, String phoneNumber, String priceLevel, String salesTax, Boolean isVendor, Boolean isCustomer, String customertype, String firstName, String lastName, String Mobile, String BillingStreet, String workEmail, String otherEmail, String workPhone, String facebookUrl, String twitterUrl, String linkedInUrl    ) {
        //if(AccessControl.ifObjectFieldIsCreateable('Account') == false) {throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);} //!Test.isRunningTest() && 
        
        Account customer = new Account();
        customer.Name = (customerName == null) ? 'Test Customer' + uniqueNumber : customerName ;
        customer.Email__c = (email == null) ? 'Test' + uniqueNumber + '@gmail.com' : email;
        customer.Phone = (phoneNumber == null) ? '123456' + uniqueNumber : phoneNumber;
        customer.BillingCity = (billingCity == null) ? 'Test Billing City' + uniqueNumber : billingCity;
        customer.Price_Level__c = priceLevel;
        customer.Sales_Tax__c = salesTax;
        customer.Is_Vendor__c = isVendor;
        customer.Is_Customer__c = isCustomer;
        customer.Type__c = customertype;
        customer.FirstName__c = firstName;
        customer.LastName__c = lastName;
        customer.Mobile__c = Mobile;
        customer.BillingStreet = BillingStreet ;
        customer.Work_Email__c = workEmail ;
        customer.Other_Email__c = otherEmail ;
        customer.Work_Number__c = workPhone ;
        customer.Facebook__c = facebookUrl ;
        customer.Twitter__c = twitterUrl ;
        customer.LinkedIn__c = linkedInUrl ;
        
        
        /*if(isInsert) {
            insert customer;
        }*/
        
        return customer;
    }
    
    private static Account createVendor(boolean isInsert, String vendorName, String email, String billingCity, String phoneNumber) {
        //if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Account') == false) {throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
        
        Account vendor = new Account();
        vendor.Name = (vendorName == null) ? 'Test Venodr' + uniqueNumber : vendorName ;
        vendor.Email__c = (email == null) ? 'Test' + uniqueNumber + '@gmail.com' : email;
        vendor.Phone = (phoneNumber == null) ? '123456' + uniqueNumber : phoneNumber;
        vendor.BillingCity = (billingCity == null) ? 'Test Billing City' + uniqueNumber : billingCity;
        vendor.Is_Vendor__c = true;
        
        /*if(isInsert) {
            insert vendor;
        }*/
        return vendor;
    }
    
    private static List<Account> createCustomersAndVendors(List<Account> accList) {
    	if(accList != null) {
    		insert accList;
    	}
    	return accList;
    }
    
}