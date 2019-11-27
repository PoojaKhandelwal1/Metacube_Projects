@isTest
public with sharing class CustomMetadataTypeUtilTest {
    static testMethod void getFilterObjectTypesTest() {
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        
        List<String> filterObjectTypesList = CustomMetadataTypeUtil.getFilterObjectTypes();
        Map<String, String> filterDisplayObjectLabelMap = CustomMetadataTypeUtil.getFilterDisplayObjectLabel();
        
        List<String> gridFilterConfigurationList = new List<String>();
        for(String str: filterObjectTypesList )
        {
            gridFilterConfigurationList.add(CustomMetadataTypeUtil.getGridFilterConfigurations(new Set<String>{str}));
        }
        System.assertEquals(gridFilterConfigurationList.size() > 0, true);
    }
}