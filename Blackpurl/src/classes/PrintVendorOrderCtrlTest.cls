@isTest
private class PrintVendorOrderCtrlTest {
    @testsetup
    private static void setup(){
    	PageReference vfPage = Page.AccountingExport;
        Test.setCurrentPage(vfPage);
        
        Account vendor = TestDataFactory.createVendor('Vendor001');
    	Vendor_Order_Header__c vendorOrderHeader = TestDataFactory.createVendorOrderHeader(vendor.Id);
    	vendorOrderHeader.Ordered_Date__c = date.newInstance(2018, 11, 21);
		update vendorOrderHeader;
		
    	Category__c categoryRec = TestDataFactory.createCategory('category001');
    	Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 100, categoryRec.Id);
    	Vendor_Order_Line_Item_Group__c vendorOrderLineItemGroup = TestDataFactory.createVendorOrderLineItemGroup(vendorOrderHeader.Id, part.Id);
    }
    
    @isTest
    private static void testPrintVendorOrderForHomeNumberAndEmail(){
    	Test.startTest();
    	Account vendor = [SELECT Preferred_Phone__c, Preferred_Email__c, Email__c, Home_Number__c FROM Account WHERE Is_vendor__c = true LIMIT 1];
    	vendor.Home_Number__c = '9999';
    	vendor.Preferred_Phone__c = vendor.Home_Number__c;
    	vendor.Preferred_Email__c = vendor.Email__c;
    	update vendor;
    	Vendor_Order_Header__c vendorOrderHeader = [SELECT Id FROM Vendor_Order_Header__c LIMIT 1];
    	ApexPages.currentPage().getParameters().put('id',vendorOrderHeader.Id);
    	PrintVendorOrderCtrl printVendorOrderCtrlObj = new PrintVendorOrderCtrl();
    	system.assertEquals(ApexPages.currentPage().getParameters().get('id'), vendorOrderHeader.Id);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPrintVendorOrderForMobileAndWorkEmail(){
    	Test.startTest();
    	Account vendor = [SELECT Preferred_Phone__c, Preferred_Email__c, Work_Email__c, Mobile__c FROM Account WHERE Is_vendor__c = true LIMIT 1];
    	vendor.Mobile__c = '9999';
    	vendor.Work_Email__c = 'abc@xyz.com';
    	vendor.Preferred_Phone__c = vendor.Mobile__c;
    	vendor.Preferred_Email__c = vendor.Work_Email__c;
    	update vendor;
    	Vendor_Order_Header__c vendorOrderHeader = [SELECT Id FROM Vendor_Order_Header__c LIMIT 1];
    	ApexPages.currentPage().getParameters().put('id',vendorOrderHeader.Id);
    	PrintVendorOrderCtrl printVendorOrderCtrlObj = new PrintVendorOrderCtrl();
    	system.assertEquals(ApexPages.currentPage().getParameters().get('id'), vendorOrderHeader.Id);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPrintVendorOrderForWorkNumberAndOtherEmail(){
    	Test.startTest();
    	Account vendor = [SELECT Preferred_Phone__c, Preferred_Email__c, Other_Email__c, Work_Number__c FROM Account WHERE Is_vendor__c = true LIMIT 1];
    	vendor.Work_Number__c = '9999999999';
    	vendor.Other_Email__c = 'abc@xyz.com';
    	vendor.Preferred_Phone__c = vendor.Work_Number__c;
    	vendor.Preferred_Email__c = vendor.Other_Email__c;
    	update vendor;
    	Vendor_Order_Header__c vendorOrderHeader = [SELECT Id FROM Vendor_Order_Header__c LIMIT 1];
    	ApexPages.currentPage().getParameters().put('id',vendorOrderHeader.Id);
    	PrintVendorOrderCtrl printVendorOrderCtrlObj = new PrintVendorOrderCtrl();
    	system.assertEquals(ApexPages.currentPage().getParameters().get('id'), vendorOrderHeader.Id);
    	Test.stopTest();
    }
}