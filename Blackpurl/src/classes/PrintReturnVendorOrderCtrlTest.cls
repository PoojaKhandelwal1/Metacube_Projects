@isTest
private class PrintReturnVendorOrderCtrlTest {
    @testsetup
    private static void setup(){
    	Account vendor = TestDataFactory.createVendor('Vendor001');
    	Return_VO_Header__c returnVOHeader = TestDataFactory.createReturnVOHeader(vendor.Id);
    	PageReference vfPage = Page.AccountingExport;
        Test.setCurrentPage(vfPage);
    }
    
    @isTest
    private static void testPrintReturnVendorOrderForHomeNumberAndEmail(){
    	Test.startTest();
    	Account vendor = [SELECT Preferred_Phone__c, Preferred_Email__c, Email__c, Home_Number__c FROM Account WHERE Is_vendor__c = true LIMIT 1];
    	vendor.Home_Number__c = '9999';
    	vendor.Preferred_Phone__c = vendor.Home_Number__c;
    	vendor.Preferred_Email__c = vendor.Email__c;
    	update vendor;
    	Return_VO_Header__c returnVOHeaderRec = [SELECT Id FROM Return_VO_Header__c LIMIT 1];
    	
    	ApexPages.currentPage().getParameters().put('id',returnVOHeaderRec.Id);
    	PrintReturnVendorOrderCtrl printReturnVendorOrderCtrl = new PrintReturnVendorOrderCtrl();
    	
		system.assertEquals(ApexPages.currentPage().getParameters().get('id'), returnVOHeaderRec.Id);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPrintReturnVendorOrderForMobileAndWorkEmail(){
    	Test.startTest();
    	Account vendor = [SELECT Preferred_Phone__c, Preferred_Email__c, Work_Email__c, Mobile__c FROM Account WHERE Is_vendor__c = true LIMIT 1];
    	vendor.Mobile__c = '9999';
    	vendor.Work_Email__c = 'abc@xyz.com';
    	vendor.Preferred_Phone__c = vendor.Mobile__c;
    	vendor.Preferred_Email__c = vendor.Work_Email__c;
    	update vendor;
    	Return_VO_Header__c returnVOHeaderRec = [SELECT Id FROM Return_VO_Header__c LIMIT 1];
    	
    	ApexPages.currentPage().getParameters().put('id',returnVOHeaderRec.Id);
    	PrintReturnVendorOrderCtrl printReturnVendorOrderCtrl = new PrintReturnVendorOrderCtrl();
    	
		system.assertEquals(ApexPages.currentPage().getParameters().get('id'), returnVOHeaderRec.Id);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPrintReturnVendorOrderForWorkNumberAndOtherEmail(){
    	Test.startTest();
    	Account vendor = [SELECT Preferred_Phone__c, Preferred_Email__c, Other_Email__c, Work_Number__c FROM Account WHERE Is_vendor__c = true LIMIT 1];
    	vendor.Work_Number__c = '9999999999';
    	vendor.Other_Email__c = 'abc@xyz.com';
    	vendor.Preferred_Phone__c = vendor.Work_Number__c;
    	vendor.Preferred_Email__c = vendor.Other_Email__c;
    	update vendor;
    	Return_VO_Header__c returnVOHeaderRec = [SELECT Id FROM Return_VO_Header__c LIMIT 1];
    	
    	ApexPages.currentPage().getParameters().put('id',returnVOHeaderRec.Id);
    	PrintReturnVendorOrderCtrl printReturnVendorOrderCtrl = new PrintReturnVendorOrderCtrl();
    	
		system.assertEquals(ApexPages.currentPage().getParameters().get('id'), returnVOHeaderRec.Id);
    	Test.stopTest();
    }
}