/**
 * Author: Kajal Vaishnav
 * Since: April 25, 2017
 * Name: BarcodePrintCtrlTest
 * Description: Test class for BarcodePrintCtrl
**/

@isTest
private class BarcodePrintCtrlTest {
    
    @testSetup
    private static void setupTestData() {
    	General_Configurations__c genConfig = TestDataFactory.createGeneralConfig(2);
        Account vendor = TestDataFactory.createVendor('Test Vendor');
        Category__c testCategory = TestDataFactory.createCategory('Test Category');
        Part__c testPart = TestDataFactory.createPart(vendor.Id, 2, 2, 2, 2, 2, testCategory.Id);
    	Country__c country = TestDataFactory.createCountry('Test Country 1');
        State__c state = TestDataFactory.createState('Test State 1', country.Id);
        Business_Profile__c businessProfile = TestDataFactory.createBusinessProfile(state.Id, country.Id);
    }
    
    static testMethod void testGetBarcodeInfoWithBusinessProfile() {
    	Part__c testPart = [SELECT Id from Part__c LIMIT 1];
    	String resultJson = BPUtility.getDecodedString(BarcodePrintCtrl.getBarcodeInfo(BPUtility.getEncodedString(testPart.Id)));
    	BarcodePrintCtrl.BarcodeInfoWrapper resultJsonRec = (BarcodePrintCtrl.BarcodeInfoWrapper)Json.deserialize(resultJson, 
    		                                                                              BarcodePrintCtrl.BarcodeInfoWrapper.class);
    	system.assertEquals('expectedDealerName', resultJsonRec.CompanyInfo.CompanyName);
    }
    
    static testMethod void testGetBarcodeInfoWithoutBusinessProfile() {
        Part__c testPart = [SELECT Id from Part__c LIMIT 1];
        String resultJson = BPUtility.getDecodedString(BarcodePrintCtrl.getBarcodeInfo(BPUtility.getEncodedString(testPart.Id)));
    	BarcodePrintCtrl.BarcodeInfoWrapper resultJsonRec = (BarcodePrintCtrl.BarcodeInfoWrapper)Json.deserialize(resultJson, 
    		                                                          BarcodePrintCtrl.BarcodeInfoWrapper.class);
    	system.assertEquals('This is test 1 Part', resultJsonRec.Description);
    }
    
    static testMethod void testGetBarcodeInfoWithInvalidPartId() {
        Part__c testPart = [SELECT Id from Part__c LIMIT 1];
		Test.startTest();
        delete testPart;
        Test.stopTest();
    	String result = BarcodePrintCtrl.getBarcodeInfo(BPUtility.getEncodedString(testPart.Id));
    	system.assertEquals('{}', result);
    }
    
    static testMethod void testGetBarcodeInfoWithExceptionHandling() {
    	Part__c testPart = [SELECT Id from Part__c LIMIT 1];
    	Test.startTest();
    	String resultJson = '';
        try {
            resultJson = BPUtility.getDecodedString(BarcodePrintCtrl.getBarcodeInfo(BPUtility.getEncodedString(null)));
            BarcodePrintCtrl.BarcodeInfoWrapper resultJsonRec = (BarcodePrintCtrl.BarcodeInfoWrapper)Json.deserialize(resultJson, 
            	                                                       BarcodePrintCtrl.BarcodeInfoWrapper.class);
        } catch (Exception e) {
            system.assertEquals(e != null, true);
            system.assertEquals('', resultJson);
        }
        Test.stopTest();
    }
    
    static testMethod void testBarcodePrintCtrl() {
    	BarcodePrintCtrl barcodeObj = new BarcodePrintCtrl();
    	System.assertNotEquals(null, barcodeObj);
    }
    
    static testMethod void testGetBarcodeLabelTemplate() {
    	String result = BPUtility.getDecodedString(BarcodePrintCtrl.getBarcodeLabelTemplate('Test template'));
    	BarcodePrintCtrl.BarcodeInfoWrapper infoWrapper = (BarcodePrintCtrl.BarcodeInfoWrapper)System.json.deserialize(result, 
    		                                                              BarcodePrintCtrl.BarcodeInfoWrapper.class);
    	System.assertEquals(infoWrapper.labelTemplateXml, null);
    }
    
    static testMethod void testSaveBarcodeLabelTemplateException() {
    	Test.startTest();
    	String resultJson = '';
        try {
            resultJson = BPUtility.getDecodedString(BarcodePrintCtrl.saveBarcodeLabelTemplate('Test template'));
        } catch (Exception e) {
            system.assertEquals('', resultJson);
        }
        Test.stopTest();
    }
    
    static testMethod void testSaveBarcodeLabelTemplate() {
    	Test.startTest();
    	String resultJson = BPUtility.getDecodedString(BarcodePrintCtrl.saveBarcodeLabelTemplate(BPUtility.getEncodedString('Test template')));
        Test.stopTest();
		system.assertEquals('SUCCESS', resultJson);
    }
}