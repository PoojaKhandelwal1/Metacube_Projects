@isTest 
public class VendorOrderExportCtrlTest {
	
	@testSetup
    private static void setupTestData() {
    	IFW_IntegrationConfig__c ifwIntegration = TestUtil.createIFWConfigForXero(); 
		IFW_IntegrationConfigItem__c ifwConfigItem = TestUtil.createIFWConfigItemForXero('Journal Entry', ifwIntegration.Id);
        Account vendorRec = TestDataFactory.createVendor('Test Vendor');
        Vendor_Order_Header__c vOHeaderRec = TestDataFactory.createVendorOrderHeader(vendorRec.Id);
        Category__c categoryRec = TestDataFactory.createCategory('Test category');
        
        Part__c partRec = TestDataFactory.createPart(vendorRec.Id, 10, 10, 10, 10, 2, categoryRec.Id);
        Vendor_Order_Line_Item_Group__c vendorOrderLineItemGroupRec = TestDataFactory.createVendorOrderLineItemGroup(vOHeaderRec.Id, partRec.Id);
    }
      
    @isTest
    private static void genericVendorOrderExportCtrlTest() {
    	Vendor_Order_Header__c vOHeaderRec = [SELECT Id from Vendor_Order_Header__c LIMIT 1];
    	PageReference pageRef = Page.VendorOrderExport;
  		pageRef.getParameters().put('id', String.valueOf(vOHeaderRec.Id));
  		pageRef.getParameters().put('type', 'Generic');
  		Test.setCurrentPage(pageRef);
  		VendorOrderExportCtrl vendorOrderExportCtrl = new VendorOrderExportCtrl();
  		system.assertEquals(vendorOrderExportCtrl.contentType, 'text/csv#Vendor Order.csv');
    }
    
    @isTest
    private static void partsCanadaVendorOrderExportCtrlTest() {
    	Vendor_Order_Header__c vOHeaderRec = [SELECT Id from Vendor_Order_Header__c LIMIT 1];
    	PageReference pageRef = Page.VendorOrderExport;
  		pageRef.getParameters().put('id', String.valueOf(vOHeaderRec.Id));
  		pageRef.getParameters().put('type', 'Parts Canada');
  		Test.setCurrentPage(pageRef);
  		VendorOrderExportCtrl vendorOrderExportCtrl = new VendorOrderExportCtrl();
  		system.assertEquals(vendorOrderExportCtrl.contentType, 'text/csv#Vendor Order.csv');
    }
    
    @isTest
    private static void hDnetAustraliaVendorOrderExportCtrlTest() {
    	Vendor_Order_Header__c vOHeaderRec = [SELECT Id from Vendor_Order_Header__c LIMIT 1];
    	PageReference pageRef = Page.VendorOrderExport;
  		pageRef.getParameters().put('id', String.valueOf(vOHeaderRec.Id));
  		pageRef.getParameters().put('type', 'HDnet Australia');
  		Test.setCurrentPage(pageRef);
  		VendorOrderExportCtrl vendorOrderExportCtrl = new VendorOrderExportCtrl();
  		system.assertEquals(vendorOrderExportCtrl.contentType, 'text/plain/#Vendor Order.txt');
    }
    
    @isTest
    private static void bossWebVendorOrderExportCtrlTest() {
    	Vendor_Order_Header__c vOHeaderRec = [SELECT Id, Name from Vendor_Order_Header__c LIMIT 1];
    	PageReference pageRef = Page.VendorOrderExport;
  		pageRef.getParameters().put('id', String.valueOf(vOHeaderRec.Id));
  		pageRef.getParameters().put('type', 'BossWeb');
  		Test.setCurrentPage(pageRef);
  		VendorOrderExportCtrl vendorOrderExportCtrl = new VendorOrderExportCtrl();
  		system.assertEquals(vendorOrderExportCtrl.contentType.contains('.txt'), true);
    }
}