@isTest
private class COSalesReceiptCtrlTest {
    @testsetup
    private static void setup(){
    	Account customer = TestDataFactory.createCustomer('Test001', 'Individual', 'Fname', 'Lname');
		CO_Header__c coHeader =  TestDataFactory.createCOHeader(customer.Id);
		CO_Invoice_Header__c coInvoiceHeader = TestDataFactory.createCOInvoiceHeader(coHeader.Id, 'Active');
    	Unit_Make__c unitMake = TestDataFactory.createUnitMake('Test Unit Make', 'Tes', true);
    	Unit_Model__c unitModel = TestDataFactory.createUnitModel('Test Unit Model', 'Tes', true, unitMake.Id);
    	Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
    	Customer_Owned_Unit__c customerOwnedUnit = TestDataFactory.createCustomerOwnedUnit(customer.Id, unitMake.Id, unitModel.Id, unitSubModel.Id, 'VIN001');
		Deal__c deal = TestDataFactory.createDeal(coHeader.Id, customerOwnedUnit.Id);
		Deal_Item__c dealItem = TestDataFactory.createDealItem(unitModel.Id, deal.Id);
		Kit_Header__c kitHeader = TestDataFactory.createKitHeader(true, true, true, true, unitMake.Id, unitModel.Id);
		Deal_Kit_Header__c dealKitHeaderRec = TestDataFactory.createDealKitHeader(coHeader.Id, dealItem.Id, kitHeader.Id);
    }
    
    @isTest
    private static void testGetCOInvoiceDetailsWithFinalize(){
    	Test.startTest();
    	COSalesReceiptCtrl coSalesReceiptCtrlObj = new COSalesReceiptCtrl();
    	CO_Invoice_Header__c coInvoiceHeaderRec = [SELECT Id FROM CO_Invoice_Header__c LIMIT 1];
    	String result = BPUtility.getDecodedString(COSalesReceiptCtrl.getCOInvoiceDetailsWithFinalize(BPUtility.getEncodedstring(coInvoiceHeaderRec.Id), true));
    	COSalesReceiptDetail coSalesReceiptDetail = (COSalesReceiptDetail)json.deserialize(result, COSalesReceiptDetail.class);
    	system.assertEquals('Test001', coSalesReceiptDetail.CustomerInfo.CustomerName);
    	Test.stopTest();
    }
}