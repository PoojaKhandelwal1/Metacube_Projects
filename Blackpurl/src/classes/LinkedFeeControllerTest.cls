@isTest
private class LinkedFeeControllerTest {

    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
    }
    
    
    static testMethod void getLinkedFeeListTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Linked_Fee__c Linkedfee = TestUtil.createLinkedFee(True, 'Description', Fee.Id, 'Service Job', 200);
        
        
        Test.startTest();
        String LinkedFeeJSON = BPUtility.getDecodedString(LinkedFeeController.getLinkedFeeList(BPUtility.getEncodedString('Service Job')));
        List<LinkedFeeWrapper> linkedFeeDetails = (List<LinkedFeeWrapper>) System.JSON.deserialize(LinkedFeeJSON, List<LinkedFeeWrapper>.class);
        system.assertEquals(linkedFeeDetails[0].RelatedTo, 'Service Job');
        LinkedFeeController.getOverViewDetails();
        String jsonStr = System.Json.serialize(linkedFeeDetails[0]);
        BPUtility.getDecodedString(LinkedFeeController.saveLinkedFee(BPUtility.getEncodedString(jsonStr)));
        String LinkedFeeJSON1 = BPUtility.getDecodedString(LinkedFeeController.getLinkedFeeList(BPUtility.getEncodedString('Service Job')));
        List<LinkedFeeWrapper> linkedFeeDetails1 = (List<LinkedFeeWrapper>) System.JSON.deserialize(LinkedFeeJSON1, List<LinkedFeeWrapper>.class);
    	system.assertEquals(linkedFeeDetails1[0].Price, 200);
    	Test.stopTest();
    	
    	String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
    	String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList.size(), 1) ;
        BPUtility.getDecodedString(LinkedFeeController.getFeeList());
        
        BPUtility.getDecodedString(LinkedFeeController.deleteLinkedFee(BPUtility.getEncodedString(linkedFee.Id), BPUtility.getEncodedString('Service Job')));
        String LinkedFeeJSON2 = BPUtility.getDecodedString(LinkedFeeController.getLinkedFeeList(BPUtility.getEncodedString('Service Job')));
        List<LinkedFeeWrapper> linkedFeeDetails2 = (List<LinkedFeeWrapper>) System.JSON.deserialize(LinkedFeeJSON2, List<LinkedFeeWrapper>.class);
    	system.assertEquals(linkedFeeDetails2.size(), 0);
    }
    
     static testMethod void permissionUserTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Fee__c fee = TestUtil.createFee(True, True, testCategory.Id, 'FeeCode', CoHeader.Id, 'Description', 100, True);
        Linked_Fee__c Linkedfee = TestUtil.createLinkedFee(True, 'Description', Fee.Id, 'Service Job', 200);
        
        User Defaultuser = TestUtil.createUser(true, 'a@b.com', 'Testing ', 'en_US', 'testUse123r@force.com', 'Test U');
         User_Group__c usergrp = new User_Group__c(); 
         usergrp.Service_job__c = 'Primary'; 
         insert usergrp;
         User_To_Group__c UserAssign = new User_To_Group__c(); 
         UserAssign.User__c = Defaultuser.id;
         UserAssign.User_Group__c = usergrp.Id;
        	Insert UserAssign ;
        	system.runas(DefaultUser)   {

    	String soHeader = BPUtility.getDecodedString(CustomerOrderCtrl.createSOHeader(BPUtility.getEncodedString(coHeader.Id)));
    	String SOHeaderDetails1 = BPUtility.getDecodedString(CustomerOrderCtrl.getSOHeaderDetails(BPUtility.getEncodedString(coHeader.Id), BPUtility.getEncodedString(null)));
        SOHeaderWrapper soHeaderDetailsObj1 = (SOHeaderWrapper) System.JSON.deserialize(SOHeaderDetails1, SOHeaderWrapper.class);
        system.assertEquals(soHeaderDetailsObj1.SOList[0].SOGridItems[0].SOKH.SOLIList.size(), 1) ;
        	}
    	
    }
}