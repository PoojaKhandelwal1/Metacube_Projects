/**
 * Author: Durga Singh
 * Since: July 15, 2015
 * Name: ViewPartCtrltest
 * Description: Test for Controller Class of Part Detail Page.
**/
@isTest
private class ViewVendorCtrlTest {

    /**
     * Name: ViewVendorCtrlTest 
     * Desc: Test to fetch vendor information on vendorId.
     * @param: 
     * @return: 
    **/
    static testMethod void getVendorInfoTest() {
        
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        Account Vendor1 = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, true, false,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        
        String venderinfo = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor1.Id)));
        
        
        VendorDetail Vendor = (VendorDetail) System.JSON.deserialize(venderinfo, VendorDetail.class);
        system.assertEquals(Vendor.VendorDetailRec.VendorName , 'customerName');
        system.assertEquals(Vendor.VendorDetailRec.HomeEmail , 'abc@abc.com');
   
    }
    
     /**
     * Name: ViewVendorCtrlTest 
     * Desc: Test to fetch similar vendors for a vendor.
     * @param: 
     * @return: 
    **/
    
    static testMethod void getOtherSimilarVendorTest() {
        
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        
        Account Vendor =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764660', 'abc1');
        Account Vendor1 = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764660', 'abc1');
        Account Vendor11 = TestUtil.createCustomer(true, 'customerName', 'abc@abcd.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764660', 'abc');
        Account Vendor12 = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, true, false,'Individual', 'ds', 'rathore1', '9783764669', 'abc');
        Account Vendor2 = TestUtil.createCustomer(true, 'customerName1', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Business', 'ds1', 'rathore', '9783764669', 'abc');
        Account Vendor21 = TestUtil.createCustomer(true, 'customerName1', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Business', 'ds', 'rathore', '9783764669', 'abc');
        Account Vendor22 = TestUtil.createCustomer(true, 'customerName1', 'abc@abcd.com', 'Agra', '1111111111', null, null, true, false,'Business', 'ds', 'rathore', '9783764669', 'abc');
       	Account Vendor23 = TestUtil.createCustomer(true, 'customerName2', 'abc@abc.com', 'Agra', '1111111112', null, null, true, false,'Business', 'ds', 'rathore', '9783764669', 'abc');
       
        Test.startTest();
        String vendorJSONString = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor.Id)));
        VendorDetail vendorDetailList = (VendorDetail) System.JSON.deserialize(vendorJSONString, VendorDetail.class);
        String rootVendorJSONString = System.JSON.serialize(vendorDetailList.VendorDetailRec);
        String similarvendors = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString) ));
        Test.stopTest();
        
        List<VendorSuggestion> vendorSuggestionList = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors, List<VendorSuggestion>.class);
        system.assertEquals(vendorSuggestionList.size(), 7);
     
        
       	String vendorJSONString1 = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor23.Id)));
       	
        VendorDetail vendorDetailList1 = (VendorDetail) System.JSON.deserialize(vendorJSONString1, VendorDetail.class);
        String rootVendorJSONString1 = System.JSON.serialize(vendorDetailList1.VendorDetailRec);
        
        String similarvendors1 = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString1 )));
        
       	List<VendorSuggestion> vendorSuggestionList1 = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors1, List<VendorSuggestion>.class);
        //system.assertEquals(vendorSuggestionList1.size(), 7);
    }
    
     /**
     * Name: ViewVendorCtrlTest 
     * Desc: Test to fetch similar vendors for a vendor on other condiditon like mobile , street.
     * @param: 
     * @return: 
    **/
    
    static testMethod void getOtherSimilarVendorTestA() {
        
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        
        Account Vendor =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, true, false, 'Individual', 'ds', 'rathore', '9783764669', 'abc');
        Account Vendor1 = TestUtil.createCustomer(true, 'BST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway');
        Account Vendor11 = TestUtil.createCustomer(true, 'AST', 'abc1@abcd.com', 'up', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764669', 'highway');
        Account Vendor12 = TestUtil.createCustomer(true, 'AKT', 'abc2@gmail.com', 'mh', '1111111112', null, null, true, false,'Individual', 'ds', 'rathore1', '9783764661', 'kingsway');
        
       
        Test.startTest();
        String vendorJSONString = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor11.Id)));
        VendorDetail vendorDetailList = (VendorDetail) System.JSON.deserialize(vendorJSONString, VendorDetail.class);
        String rootVendorJSONString = System.JSON.serialize(vendorDetailList.VendorDetailRec);
        String similarvendors = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString )));
        Test.stopTest();
        
        List<VendorSuggestion> vendorSuggestionList = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors, List<VendorSuggestion>.class);
        //system.assertEquals(vendorSuggestionList.size(), 2);
        
        String vendorJSONString1 = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor1.Id)));
        VendorDetail vendorDetailList1 = (VendorDetail) System.JSON.deserialize(vendorJSONString1, VendorDetail.class);
        String rootVendorJSONString1 = System.JSON.serialize(vendorDetailList1.VendorDetailRec);
        String similarvendors1 = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString1 )));
        
        List<VendorSuggestion> vendorSuggestionList1 = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors1, List<VendorSuggestion>.class);
        //system.assertEquals(vendorSuggestionList1.size(), 2);
        List<Contact> accList = [select Id, Name from Contact limit 100];
		system.assertEquals(accList.size(), 0);
    }
    
    /**
     * Name: ViewVendorCtrlTest 
     * Desc: Test to fetch similar vendors for a vendor on other condiditon like social sites, other email and phone.
     * @param: 
     * @return: 
    **/
    
    static testMethod void getOtherSimilarVendorTestB() {
        
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        
        Account Vendor =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, true, false, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
        Account Vendor1 = TestUtil.createCustomer(true, 'AST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway', 'work@work.com','other1@other.com','1234567891', 'facebook1', 'twitter1', 'linkedin1');
        Account Vendor2 = TestUtil.createCustomer(true, 'BST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway', 'work1@work.com','work@work.com','1234567891', 'facebook1', 'twitter1', 'linkedin1');
        Account Vendor3 = TestUtil.createCustomer(true, 'CST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway', 'work1@work.com','other@other.com','1234567891', 'facebook1', 'twitter1', 'linkedin1');
        Account Vendor4 = TestUtil.createCustomer(true, 'EST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway', 'work1@work.com','other2@other.com','1234567890', 'facebook1', 'twitter1', 'linkedin1');
        Account Vendor5 = TestUtil.createCustomer(true, 'FST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway', 'work1@work.com','other2@other.com','1234567891', 'facebook', 'twitter1', 'linkedin1');
        Account Vendor6 = TestUtil.createCustomer(true, 'GST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway', 'work1@work.com','other2@other.com','1234567891', 'facebook1', 'twitter', 'linkedin1');
        Account Vendor7 = TestUtil.createCustomer(true, 'HST', 'abc@abc.com', 'Agra', '1111111111', null, null, true, false,'Individual', 'ds', 'rathore', '9783764668', 'kingsway', 'work1@work.com','other2@other.com','1234567891', 'facebook1', 'twitter1', 'linkedin');
        Account Vendor8 = TestUtil.createCustomer(true, 'DSTExtra', 'abc@abc.com', 'jaipur','1111111111', null, null, true, false, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
        
        Test.startTest();
        //String vendorJSONString = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor8.Id)));
        //String vendorJSONString = ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor8.Id));
       	// delete vendor8;
       // VendorDetail vendorDetailList = (VendorDetail) System.JSON.deserialize(vendorJSONString, VendorDetail.class);
        //String rootVendorJSONString = System.JSON.serialize(vendorDetailList.VendorDetailRec);
        //system.assert(false,rootVendorJSONString);
        
        
        string rootVendorJSONString = '{"WorkNumberSMS":false,"WorkNumber":"1234567890","WorkEmail":"work@work.com","Website":"","VendorNumber":"","VendorName":"","VendorCode":"","VendorAccountNumber":"","TwitterLink":"twitter","ShippingStreet2":"","ShippingStreet1":"","ShippingState":"","ShippingPostalCode":"","ShippingCountry":"","ShippingCity":"","SalsePriceLevelName":"","SalesTaxLevelName":"","SalesTaxLevelId":null,"SalesPriceLevelId":null,"PurchaseTaxLevelName":"","PurchaseTaxLevelId":null,"PreferredSMS":"","PreferredPhone":"","PreferredEmail":"","PartCategoryName":"","PartCategoryId":"","OtherPhone":"9783764669","OtherEmail":"other@other.com","MobileNumberSMS":false,"LinkedInLink":"linkedin","IsWarrantyPlans":false,"IsVendor":true,"IsUnitPurchases":false,"IsSubletPurchases":false,"IsPartPurchases":false,"IsFlooringCompany":false,"IsFinancingProducts":false,"IsFinanceCompany":false,"IsClaimsForServiceWork":false,"IsBothAddressSame":false,"Id":"","HomeNumberSMS":false,"HomeNumber":"","HomeEmail":"abc@abc.com","Fax":"","FacebookLink":"facebook","BillingStreet2":"","BillingStreet1":"abc","BillingState":"","BillingPostalCode":"","BillingCountry":"","BillingCity":"jaipur","Active":true}'; 
        String similarvendors = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString )));
        
        List<VendorSuggestion> vendorSuggestionList = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors, List<VendorSuggestion>.class);
        //system.assert(false,vendorSuggestionList);
        system.assertEquals(vendorSuggestionList[0].PriorityValue,3);
        
       
        string rootVendorJSONString2 = '{"WorkNumberSMS":false,"WorkNumber":"9889081440","WorkEmail":"","Website":"","VendorNumber":"","VendorName":"","VendorCode":"","VendorAccountNumber":"","TwitterLink":"https://twiittter","ShippingStreet2":"","ShippingStreet1":"","ShippingState":"","ShippingPostalCode":"","ShippingCountry":"","ShippingCity":"","SalsePriceLevelName":"","SalesTaxLevelName":"","SalesTaxLevelId":null,"SalesPriceLevelId":null,"PurchaseTaxLevelName":"","PurchaseTaxLevelId":null,"PreferredSMS":"","PreferredPhone":"","PreferredEmail":"","PartCategoryName":"","PartCategoryId":"","OtherPhone":"9666764669","OtherEmail":"","MobileNumberSMS":false,"LinkedInLink":"yliiinkeedin","IsWarrantyPlans":false,"IsVendor":true,"IsUnitPurchases":false,"IsSubletPurchases":false,"IsPartPurchases":false,"IsFlooringCompany":false,"IsFinancingProducts":false,"IsFinanceCompany":false,"IsClaimsForServiceWork":false,"IsBothAddressSame":true,"Id":"","HomeNumberSMS":false,"HomeNumber":"","HomeEmail":"wwabc@wwabc.com","Fax":"","FacebookLink":"rrfacebwwook","BillingStreet2":"","BillingStreet1":"abc","BillingState":"","BillingPostalCode":"","BillingCountry":"","BillingCity":"jaipur","Active":true}'; 
       	String similarvendors2 = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString2 )));
        
        List<VendorSuggestion> vendorSuggestionList2 = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors2, List<VendorSuggestion>.class);
        //system.assert(false,vendorSuggestionList);
        system.assertEquals(vendorSuggestionList2[0].PriorityValue,6);
        
        string rootVendorJSONString3 = '{"WorkNumberSMS":false,"WorkNumber":"1234567890","WorkEmail":"work@work.com","Website":"","VendorNumber":"","VendorName":"","VendorCode":"","VendorAccountNumber":"","TwitterLink":"twitter","ShippingStreet2":"","ShippingStreet1":"","ShippingState":"","ShippingPostalCode":"","ShippingCountry":"","ShippingCity":"","SalsePriceLevelName":"","SalesTaxLevelName":"","SalesTaxLevelId":null,"SalesPriceLevelId":null,"PurchaseTaxLevelName":"","PurchaseTaxLevelId":null,"PreferredSMS":"HomeNumber","PreferredPhone":"HomeNumber","PreferredEmail":"HomeEmail","PartCategoryName":"","PartCategoryId":"","OtherPhone":"9783764669","OtherEmail":"other@other.com","MobileNumberSMS":false,"LinkedInLink":"linkedin","IsWarrantyPlans":false,"IsVendor":true,"IsUnitPurchases":false,"IsSubletPurchases":false,"IsPartPurchases":false,"IsFlooringCompany":false,"IsFinancingProducts":false,"IsFinanceCompany":false,"IsClaimsForServiceWork":false,"IsBothAddressSame":true,"Id":"","HomeNumberSMS":false,"HomeNumber":"1234554321","HomeEmail":"abc@abc.com","Fax":"","FacebookLink":"facebook","BillingStreet2":"noway","BillingStreet1":"abc","BillingState":"","BillingPostalCode":"","BillingCountry":"","BillingCity":"jaipur","Active":true}'; 
       	String similarvendors3 = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString )));
        
        List<VendorSuggestion> vendorSuggestionList3 = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors3, List<VendorSuggestion>.class);
        //system.assert(false,vendorSuggestionList);
        system.assertEquals(vendorSuggestionList3[0].PriorityValue,3);
        
        
        Vendor vendorTempRec1 = new Vendor(Vendor);
        string rootVendorJSONString1 = System.JSON.serialize(vendorTempRec1);
       	String similarvendors1 = BPUtility.getDecodedString(ViewVendorCtrl.getOtherSimilarVendor(BPUtility.getEncodedString(rootVendorJSONString1 )));
       	
       	List<VendorSuggestion> vendorSuggestionList1 = (List<VendorSuggestion>) System.JSON.deserialize(similarvendors1, List<VendorSuggestion>.class);
       	system.assertEquals(vendorSuggestionList1[0].PriorityValue,1);
       	
        
        Test.stopTest();
        
        
        
        List<Contact> accList = [select Id, Name from Contact limit 100];
		system.assertEquals(accList.size(), 0);
       
    }
     
     /**
     * Name: saveVendorTest
     * Desc: Test to save vendoe with any updated name.
     * @param: 
     * @return: 
    **/
    
     static testMethod void saveVendorTest() {
    	General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
    	Account Vendor =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, true, false, 'Individual', 'ds', 'rathore', '9783764669', 'abc');
    	
    	String vendorJSONString = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor.Id)));
        VendorDetail vendorDetailList = (VendorDetail) System.JSON.deserialize(vendorJSONString, VendorDetail.class);
        vendorDetailList.VendorDetailRec.VendorName = 'AST' ;
        
        String rootVendorJSONString = System.JSON.serialize(vendorDetailList.VendorDetailRec);
        String newvendor = BPUtility.getDecodedString(ViewVendorCtrl.saveVendor(BPUtility.getEncodedString(rootVendorJSONString)));
        system.assertEquals(newvendor.contains('AST'), true );
        
        }
        
        /**
     * Name: getAllLookupFieldsJSONTest
     * Desc: Test to get all look up fields.
     * @param: 
     * @return: 
    **/
    
     static testMethod void getAllLookupFieldsJSONTest() {
    	
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
    	Country__c testcountry = TestUtil.createCountry(true, 'Australia', true, false);
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	
    	string allList = BPUtility.getDecodedString(ViewVendorCtrl.getAllLookupFieldsJSON());
       	system.assertEquals(allList.contains('Australia'), true);
        }
        
          /**
     * Name: setVendorFieldsTest
     * Desc: Test to set all vendors field.
     * @param: 
     * @return: 
    **/
    
     static testMethod void setVendorFieldsTest() {
    	General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
    	Account Vendor =  TestUtil.createCustomer(false, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, true, false, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
    	
    	vendor.SA_same_as_BA__c = true;
    	vendor.Preferred_Email__c = vendor.Other_Email__c;
    	vendor.Preferred_Phone__c = vendor.Work_Number__c;
    	vendor.Preferred_SMS__c = vendor.Work_Number__c;
    	vendor.shippingstreet = 'Abcs \n cccc';
    	vendor.shippingcity = 'jaipurcity';
    	vendor.shippingstate = 'Raj';
    	vendor.shippingpostalcode = '302012';
    	vendor.shippingcountry = 'India';
    	insert vendor ;

    	
    	
    	String vendorJSONString = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor.Id)));
        VendorDetail vendorDetailList = (VendorDetail) System.JSON.deserialize(vendorJSONString, VendorDetail.class);
        vendorDetailList.VendorDetailRec.VendorName = 'AST' ;
        
        String rootVendorJSONString = System.JSON.serialize(vendorDetailList.VendorDetailRec);
        String newvendor = BPUtility.getDecodedString(ViewVendorCtrl.saveVendor(BPUtility.getEncodedString(rootVendorJSONString)));
        system.assertEquals(newvendor.contains('AST'), true );
        /*
        Account Vendor1 =  TestUtil.createCustomer(false, 'SST', 'abc1@abc.com', 'jaipur', '1111111111', null, null, true, false, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'woruk@woruk.com', 'other1@other.com', '1234567890','facebuook', 'twituter', 'linkuedin'  );
    	
    	vendor1.Email__c = 'home@home.com';
    	vendor1.SA_same_as_BA__c = true;
    	vendor1.Preferred_Email__c = vendor.Email__c;
    	vendor1.Home_Number__c = '9899000812';
    	vendor1.Preferred_Phone__c = vendor.Home_Number__c;
    	vendor1.Preferred_SMS__c = vendor.Home_Number__c;
    	vendor1.shippingstreet = 'Abcs \n cccc';
    	vendor1.shippingcity = 'KAnpur';
    	vendor1.shippingstate = 'UP';
    	vendor1.shippingpostalcode = '302022';  
    	vendor1.shippingcountry = 'India';
    	insert vendor1 ;
        
        String vendorJSONString1 = BPUtility.getDecodedString(ViewVendorCtrl.getVendorInfo(BPUtility.getEncodedString(Vendor1.Id)));
        VendorDetail vendorDetailList1 = (VendorDetail) System.JSON.deserialize(vendorJSONString1, VendorDetail.class);
        vendorDetailList1.VendorDetailRec.VendorName = 'PST' ;
        
        String rootVendorJSONString1 = System.JSON.serialize(vendorDetailList1.VendorDetailRec);
        String newvendor1 = BPUtility.getDecodedString(ViewVendorCtrl.saveVendor(BPUtility.getEncodedString(rootVendorJSONString1)));
        system.assertEquals(newvendor1.contains('PST'), true );
        */
        }
}