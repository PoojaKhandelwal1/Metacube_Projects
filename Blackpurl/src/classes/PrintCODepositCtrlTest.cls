@isTest
private class PrintCODepositCtrlTest {
    static testMethod void getPrintCODepositDataTest() {
    	// Business Profile
    	Business_Profile__c businessProfileObject = new Business_Profile__c();
    	businessProfileObject.Business_Street_Address1__c = 'test street1';
    	businessProfileObject.Business_Street_Address2__c = 'test street1';
    	businessProfileObject.Business_City__c = 'test city'; 
    	businessProfileObject.Business_Name__c = 'business 1 ';
    	businessProfileObject.Business_Postal_Code__c = '302022';
    	insert businessProfileObject;
    	// Customer
    	Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
		// Vendor
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
		//Category
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        // Default Price Level
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        // Default Sales Tax
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        // Part of stock 1
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 30, 40, 1);
        // CO Header
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
        // Fee
        Fee__c fee = TestUtil.createFee(true, true, testCategory.Id, 'TestFee', coHeader1.Id, 'Fee Description', 100, true);
        // Labour Code
        Labour_Code__c labourCode = TestUtil.createLabourCode(true, true, testCategory.Id, 'Code', coHeader1.Id, 'Description', True, 10, 'LabourCodeName', 10, true);
        // SO Header
		String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader1.Id)));
		String SOHeaderDetails = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader1.Id), BPUtility.getEncodedString('soHeader')));
        SOHeaderWrapper soHeaderDetailsObj = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails, SOHeaderWrapper.class);
        
        // SO Line Items Part
        String lineitemPart = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader1.Id), BPUtility.getEncodedString(customer.Id)));
        // SO Line Items Fee
        String lineitemFee = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(fee.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader1.Id), BPUtility.getEncodedString(customer.Id)));
        // SO Line Items Labour Code
        Test.startTest();	
        String lineitemLabourCode = BPUtility.getDecodedString(CustomerOrderCtrl.addLineItems(BPUtility.getEncodedString(labourCode.Id), BPUtility.getEncodedString(soHeaderDetailsObj.SOList[0].SOHeaderInfo.Id), BPUtility.getEncodedString(coHeader1.Id), BPUtility.getEncodedString(customer.Id)));
        // CO Line Item Part
        CO_Line_Item__c coLineItemPart = new CO_Line_Item__c();
        coLineItemPart.CO_Header__c = coHeader1.Id;
        coLineItemPart.Part__c = part.Id;
        coLineItemPart.Qty__c = 2;
        // CO Line Item Fee
        CO_Line_Item__c coLineItemFee = new CO_Line_Item__c();
        coLineItemFee.CO_Header__c = coHeader1.Id;
        coLineItemFee.Fee__c = fee.Id;
        coLineItemFee.Qty__c = 1;
        // insert CO Line Items
        List<CO_Line_Item__c> coLineItemList = new List<CO_Line_Item__c>();
        coLineItemList.add(coLineItemPart);
        coLineItemList.add(coLineItemFee);
        //Test.startTest();			//Updated by Nikhil - 04/03/17
        insert coLineItemList;
        // CO Deposit
		CO_Deposit__c coDeposit1 = TestUtil.createCODeposit(true, coHeader1.Id, 'Cash', 500);
		// CO Invoice Header Active
		CO_Invoice_Header__c coinvoiceHeader1 = TestUtil.createCOInvoiceHeader(true, coHeader1.Id, 'Active');
		// CO Invoice Payment
        CO_Invoice_Payment__c coInvoicepaymentRec = new CO_Invoice_Payment__c();
        coInvoicepaymentRec.CO_Invoice_Header__c = coinvoiceHeader1.Id;
        coInvoicepaymentRec.Amount__c = 400;
        insert coInvoicepaymentRec;
        
	   	PrintCODepositCtrl PCODC = new PrintCODepositCtrl();  //added by gourav on 14-08-2017
	   	String printCODepositJSON = PrintCODepositCtrl.getPrintCODepositData(BPUtility.getEncodedString(coHeader1.Id));
	    Test.stopTest();
	    PrintCODepositWrapper printCODeposits = (PrintCODepositWrapper) System.JSON.deserialize(BPUtility.getDecodedString(printCODepositJSON), PrintCODepositWrapper.class);
		system.assertEquals(printCODeposits.CODepositList.size(), 2);
    }
}