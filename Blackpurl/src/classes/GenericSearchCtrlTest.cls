/**
 * Author: Rajat Jain
 * Since: April 23, 2018
 * Name: GenericSearchCtrl test
 * Description: Controller test Class of GenericSearch.
**/

@isTest
public with sharing class GenericSearchCtrlTest {
	@testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
	
	/* Name: getSearchResultsForCustomersTest
     * Desc: Test to search customer results
     * @param: 
     * @return: 
    **/
    static testMethod void getGenericSearchResultsForCustomersTest() {
        Account customer = TestUtil.createCustomer(true, 'test', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account customer1 = TestUtil.createCustomer(true, 'customertestAccount1', 'abc1@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account customer2 = TestUtil.createCustomer(true, 'testcustomerAccount2', 'abc2@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Account customer3 = TestUtil.createCustomer(true, 'customerAccount2', 'abc2@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        
        Test.startTest();
        String searchresultJson = BPUtility.getDecodedString(CustomerOrderCtrl.getSearchResult(BPUtility.getEncodedString('{"SearchText":"test","SearchableObjects":"Customer","FilterValues":[]}')));
        List<AutoCompleteCtrl.CustomerInfoWrapper> results = (List<AutoCompleteCtrl.CustomerInfoWrapper>) System.JSON.deserialize(searchresultJson, List<AutoCompleteCtrl.CustomerInfoWrapper>.class);
        Test.stopTest();
        system.assertEquals(3, results.size());
        system.assertEquals(true, results[0].Name.equals('test'));
        system.assertEquals(true, results[1].Name.startsWith('test'));
        system.assertEquals(true, results[2].Name.contains('test'));

    }
    
    /* Name: getSearchResultsForCustomersTest
     * Desc: Test to search customer results
     * @param: 
     * @return: 
    **/
    static testMethod void getGenericSearchResultsForPartTest() {
         Account vendor = TestUtil.createVendor(true, 'Test Vendor');
         Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
         Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
         Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
         List<Part__c> partList = new List<Part__c>();
			for(Integer i=0;i<10;i++) {
			     Part__c part = TestUtil.createPart(false, 'TestPart'+i, vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
			     partList.add(part);
			}
        insert partList;
        Test.startTest();
        String searchresults = BPUtility.getDecodedString(CustomerOrderCtrl.getSearchResult(BPUtility.getEncodedString('{"SearchText":"Test","SearchableObjects":"Part__c","FilterValues":[]}')));
        Test.stopTest();
        //system.assert(false, searchresults );
        system.assertEquals(searchresults.contains('TestPart'), true);

    }
    
    /* Name: getSearchResultsForVendoesTest
     * Desc: Test to search Vendoe results
     * @param: 
     * @return: 
    **/
   /* static testMethod void getGenericSearchResultsForVendoesTest() {
        Account customer = TestUtil.createVendor(true, 'test');
        Account customer1 = TestUtil.createVendor(true, 'vendortestAccount1');
        Account customer2 = TestUtil.createVendor(true, 'testvendorAccount2');
        Account customer3 = TestUtil.createVendor(true, 'vendorAccount2');
        
        Test.startTest();
        String searchresultJson = BPUtility.getDecodedString(CustomerOrderCtrl.getSearchResult(BPUtility.getEncodedString('{"SearchText":"test","SearchableObjects":"Vendor","FilterValues":[]}')));
        List<AutoCompleteCtrl.CustomerInfoWrapper> results = (List<AutoCompleteCtrl.CustomerInfoWrapper>) System.JSON.deserialize(searchresultJson, List<AutoCompleteCtrl.CustomerInfoWrapper>.class);
        Test.stopTest();
        system.assertEquals(3, results.size());
        system.assertEquals(true, results[0].Name.equals('test'));
        system.assertEquals(true, results[1].Name.startsWith('test'));
        system.assertEquals(true, results[2].Name.contains('test'));

    }*/
    
}