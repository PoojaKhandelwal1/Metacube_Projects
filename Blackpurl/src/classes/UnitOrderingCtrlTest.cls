@isTest
private class UnitOrderingCtrlTest {
    
    static testMethod void getVendorsListTest() {
        Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'COU';
        customerOwnedUnit.Status__c = 'Active';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        
        test.startTest();
        String jsonData = UnitOrderingCtrl.getVendorsList();
        test.stopTest();
        jsonData = BPUtility.getDecodedString(jsonData);
        List<UnitOrderingWrapper.VendorWrapper> vendorList = (List<UnitOrderingWrapper.VendorWrapper>) System.JSON.deserialize(jsonData, List<UnitOrderingWrapper.VendorWrapper>.class);
        system.assertEquals('test',vendorList[0].VendorName);
        system.assertEquals(0,vendorList[0].UnitCount);
    }
    static testMethod void getVendorDetailsTest() {
        Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'COU';
        customerOwnedUnit.Status__c = 'Active';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        
        test.startTest();
        String jsonData = UnitOrderingCtrl.getVendorDetails(BPUtility.getEncodedString(vendor.id));
        test.stopTest();
        jsonData = BPUtility.getDecodedString(jsonData);
        UnitOrderingWrapper.VendorWrapper vendorObj = (UnitOrderingWrapper.VendorWrapper) System.JSON.deserialize(jsonData, UnitOrderingWrapper.VendorWrapper.class);
        system.assertEquals('test',vendorObj.VendorName);
        system.assertEquals(0,vendorObj.UnitCount);
    }
    
     static testMethod void SetUnitPurchaseFlagForVendorTest() {
        Account vendor = TestUtil.createVendor(true,'test');
        test.startTest();
        String jsonData = UnitOrderingCtrl.SetUnitPurchaseFlagForVendor(BPUtility.getEncodedString(vendor.id));
        test.stopTest();
        jsonData = BPUtility.getDecodedString(jsonData);
        List<UnitOrderingWrapper.VendorWrapper> vendorList = (List<UnitOrderingWrapper.VendorWrapper>) System.JSON.deserialize(jsonData, List<UnitOrderingWrapper.VendorWrapper>.class);
        system.assertEquals('test',vendorList[0].VendorName);
        system.assertEquals(0,vendorList[0].UnitCount);
        
     }
     static testMethod void getActiveOrderListTest() {
        Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'On Order';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        
        test.startTest();
        String jsonData = UnitOrderingCtrl.getActiveOrderList(BPUtility.getEncodedString(vendor.id));
        test.stopTest();
        jsonData = BPUtility.getDecodedString(jsonData);
        List<UnitOrderingWrapper.UnitOrderWrapper> vendorList = (List<UnitOrderingWrapper.UnitOrderWrapper>) System.JSON.deserialize(jsonData, List<UnitOrderingWrapper.UnitOrderWrapper>.class);
        system.assertEquals('On Order',vendorList[0].Status);
    }
    static testMethod void removeOrderUnitTest(){
    	 Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'On Order';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        
        test.startTest();
        String jsonData = UnitOrderingCtrl.removeOrderUnit(BPUtility.getEncodedString(customerOwnedUnit.id),BPUtility.getEncodedString(vendor.id));
        test.stopTest();
        jsonData = BPUtility.getDecodedString(jsonData);
        List<UnitOrderingWrapper.VendorWrapper> vendorList = (List<UnitOrderingWrapper.VendorWrapper>) System.JSON.deserialize(jsonData, List<UnitOrderingWrapper.VendorWrapper>.class);
        system.assertEquals(0,vendorList.size());
        
    }
    static testMethod void getOrderHistoryListTest() {
    	 Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Received';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        
        test.startTest();
        String jsonData = UnitOrderingCtrl.getOrderHistoryList(BPUtility.getEncodedString(vendor.id));
        test.stopTest();
        jsonData = BPUtility.getDecodedString(jsonData);
        List<UnitOrderingWrapper.UnitOrderWrapper> vendorList = (List<UnitOrderingWrapper.UnitOrderWrapper>) System.JSON.deserialize(jsonData, List<UnitOrderingWrapper.UnitOrderWrapper>.class);
        system.assertEquals('Received',vendorList[0].Status);
    }
    static testMethod void getUnitDetailsTest() {
    	Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Received';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        
        test.startTest();
        String response  = UnitOrderingCtrl.getUnitDetails(BPUtility.getEncodedString(customerOwnedUnit.id));
        test.stopTest();
        response = BPUtility.getDecodedString(response);
        List<UnitOrderingWrapper.UnitDetailsWrapper> unitList = (List<UnitOrderingWrapper.UnitDetailsWrapper>) System.JSON.deserialize(response, List<UnitOrderingWrapper.UnitDetailsWrapper>.class);
        system.assertNotEquals(null,unitList[0].UnitInfo.id);
    }
    
    static testMethod void saveUnitDetailsTest() {
    	Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Received';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        String query;   
        query = 'SELECT '; 
        for(String fieldName : UnitWrapper.fieldsListForUnitInfo()){
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Customer_Owned_Unit__c ';
        List<Customer_Owned_Unit__c> couList = new List<Customer_Owned_Unit__c>();
        couList = Database.query(query);
        Customer_Owned_Unit__c couObj = new Customer_Owned_Unit__c();
        if(couList.size()>0){
        	couObj = couList[0];
        }
        UnitOrderingWrapper.UnitDetailsWrapper unitObj = new UnitOrderingWrapper.UnitDetailsWrapper(couObj);
        String jsonString = System.JSON.serialize(unitObj);
        jsonString = BPUtility.getEncodedString(jsonString);
        test.startTest();
        String response = UnitOrderingCtrl.saveUnitDetails(jsonString);
        test.stopTest();
        response = BPUtility.getDecodedString(response);
        List<UnitOrderingWrapper.VendorWrapper> vendorList = (List<UnitOrderingWrapper.VendorWrapper>) System.JSON.deserialize(response, List<UnitOrderingWrapper.VendorWrapper>.class);
        system.assertEquals(1,vendorList.size());
    }
    
	static testMethod void savePriceAndCostTest() {
		Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        CO_Header__c coHeader = TestUtil.createCOHeader(true,acc.id);
        CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true,coHeader.id,'Active');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Received';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        Unit_Price_Cost__c upc = new Unit_Price_Cost__c();
		upc.Type__c = 'Factory';
		upc.Customer_Owned_Unit__c = customerOwnedUnit.id;
		upc.CO_Invoice_Header__c = coInvoiceHeader.id;
		insert upc;
		String query;   
        query = 'SELECT '; 
        for(String fieldName : UnitWrapper.fieldsListForUnitPriceAndCostTracking()){
            query += fieldName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Unit_Price_Cost__c ';
        List<Unit_Price_Cost__c> upcList = new List<Unit_Price_Cost__c>();
        upcList = Database.query(query);
        Unit_Price_Cost__c upcObj = new Unit_Price_Cost__c();
        if(upcList.size()>0){
        	upcObj = upcList[0];
        }
        
		UnitWrapper.PriceAndCostTrackingWrapper priceAndCost = new UnitWrapper.PriceAndCostTrackingWrapper(upcObj);
		String jsonString = System.JSON.serialize(priceAndCost);
		jsonString = BPUtility.getEncodedString(jsonString);
		test.startTest();
        String response = UnitOrderingCtrl.savePriceAndCost(BPUtility.getEncodedString(customerOwnedUnit.id),jsonString);
        test.stopTest();
        response = BPUtility.getDecodedString(response);
        List<UnitOrderingWrapper.UnitDetailsWrapper> unitList = (List<UnitOrderingWrapper.UnitDetailsWrapper>) System.JSON.deserialize(response, List<UnitOrderingWrapper.UnitDetailsWrapper>.class);
        system.assertEquals('Agra',unitList[0].UnitInfo.BillingCity);
	}
	static testMethod void removePriceAndCostTest() {
		Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        CO_Header__c coHeader = TestUtil.createCOHeader(true,acc.id);
        CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true,coHeader.id,'Active');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Received';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        Unit_Price_Cost__c upc = new Unit_Price_Cost__c();
		upc.Type__c = 'Factory';
		upc.Customer_Owned_Unit__c = customerOwnedUnit.id;
		upc.CO_Invoice_Header__c = coInvoiceHeader.id;
		insert upc;
		test.startTest();
        String response = UnitOrderingCtrl.removePriceAndCost(BPUtility.getEncodedString(customerOwnedUnit.id),BPUtility.getEncodedString(upc.id));
        UnitOrderingCtrl uoc = new UnitOrderingCtrl();
        test.stopTest();
        response = BPUtility.getDecodedString(response);
        List<UnitOrderingWrapper.UnitDetailsWrapper> unitList = (List<UnitOrderingWrapper.UnitDetailsWrapper>) System.JSON.deserialize(response, List<UnitOrderingWrapper.UnitDetailsWrapper>.class);
        system.assertEquals('Agra',unitList[0].UnitInfo.BillingCity);
	}
	static testMethod void saveUnitReceivingTest() {
		Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        CO_Header__c coHeader = TestUtil.createCOHeader(true,acc.id);
        CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true,coHeader.id,'Active');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'On Order';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        customerOwnedUnit = [SELECT Unit_Number__c, Cylinders__c, Stock_Id__c, VIN_Number__c, Year__c, Make_Name__c,Model_Detail__c, Unit_Model__r.Name__c, Sub_Model__r.Sub_Model_Name__c, Factory_Order_No__c, Status__c, CreatedDate, Stocked_In_DateTime__c, Total_Cost__c, Vendor__r.Purchase_Tax__r.Rate__c,Tax_Amount__c, Invoice_Number__c, Compliance_Date__c, Registration_Serial__c, Year_Of_1st_Rego__c FROM Customer_Owned_Unit__c
        WHERE Id =: customerOwnedUnit.Id];
        UnitOrderingWrapper.UnitOrderWrapper uow = new UnitOrderingWrapper.UnitOrderWrapper(customerOwnedUnit);
        List<UnitOrderingWrapper.UnitOrderWrapper> uowList = new List<UnitOrderingWrapper.UnitOrderWrapper>();
        uowList.add(uow);
        String jsonString = System.JSON.serialize(uowList);
		jsonString = BPUtility.getEncodedString(jsonString);
		test.startTest();
		String response = UnitOrderingCtrl.receiveUnit(jsonString);
        test.StopTest();
        system.assertEquals('SUCCESS',response);
        
	}
	static testMethod void saveUnitReceivingTestTwo() {
		Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        CO_Header__c coHeader = TestUtil.createCOHeader(true,acc.id);
        CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true,coHeader.id,'Active');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Traded';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        customerOwnedUnit = [SELECT Unit_Number__c, Stock_Id__c, Cylinders__c, VIN_Number__c, Year__c, Make_Name__c,Model_Detail__c, Unit_Model__r.Name__c, Sub_Model__r.Sub_Model_Name__c, Factory_Order_No__c, Status__c, CreatedDate, Stocked_In_DateTime__c, Total_Cost__c, Vendor__r.Purchase_Tax__r.Rate__c,Tax_Amount__c, Invoice_Number__c, Compliance_Date__c, Registration_Serial__c, Year_Of_1st_Rego__c FROM Customer_Owned_Unit__c
        WHERE Id =: customerOwnedUnit.Id];
        UnitOrderingWrapper.UnitOrderWrapper uow = new UnitOrderingWrapper.UnitOrderWrapper(customerOwnedUnit);
        List<UnitOrderingWrapper.UnitOrderWrapper> uowList = new List<UnitOrderingWrapper.UnitOrderWrapper>();
        uowList.add(uow);
        String jsonString = System.JSON.serialize(uowList);
		jsonString = BPUtility.getEncodedString(jsonString);
		test.startTest();
		String response = UnitOrderingCtrl.receiveUnit(jsonString);
        test.StopTest();
        system.assertEquals('SUCCESS',response);
        
        
	}
	static testMethod void getUnitCategoryListTest() {
		Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        CO_Header__c coHeader = TestUtil.createCOHeader(true,acc.id);
        CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true,coHeader.id,'Active');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Traded';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        Category__c category = testUtil.createCategory(true,'test category','Unit','test description',true,true);
        test.startTest();
        String response = UnitOrderingCtrl.getUnitCategoryList();
        test.stopTest();
        response = BPUtility.getDecodedString(response);
        List<CategoryService.CategoryWrapper> categoryList = (List<CategoryService.CategoryWrapper>) System.JSON.deserialize(response, List<CategoryService.CategoryWrapper>.class);
        system.assertEquals(true,categoryList[0].IsDefault);
	}
	static testMethod void applySortingOnActiveOrderListTest() {
		Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        CO_Header__c coHeader = TestUtil.createCOHeader(true,acc.id);
        CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true,coHeader.id,'Active');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'On Order';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        UnitOrderingWrapper.SortingAttrs sortAttrs= new UnitOrderingWrapper.SortingAttrs();
        sortAttrs.FieldLabel = 'Status';
        sortAttrs.SortingOrder = 'ASC';
        String jsonString = system.json.serialize(sortAttrs);
        test.startTest();
		String response = UnitOrderingCtrl.applySortingOnActiveOrderList(BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(jsonString));
        test.StopTest();
        response = BPUtility.getDecodedString(response);
		List<UnitOrderingWrapper.UnitOrderWrapper> unitList = (List<UnitOrderingWrapper.UnitOrderWrapper>) System.JSON.deserialize(response, List<UnitOrderingWrapper.UnitOrderWrapper>.class);
        system.assertEquals(1,unitList.size());
		
	}
	
	static testMethod void applySortingOnOrderHistoryListTest() {
		Account vendor = TestUtil.createVendor(false,'test');
        vendor.Unit_Purchases__c = true;
        insert vendor;
        Account acc = TestUtil.createCustomer(true, 'Test Customer', 'test@test.com', 'NY', '5214789630');
        CO_Header__c coHeader = TestUtil.createCOHeader(true,acc.id);
        CO_Invoice_Header__c coInvoiceHeader = TestUtil.createCOInvoiceHeader(true,coHeader.id,'Active');
        Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
        customerOwnedUnit.Unit_Type__c = 'ORDU';
        customerOwnedUnit.Status__c = 'Cancelled';
        customerOwnedUnit.Mileage_Type__c = 'Km';
        customerOwnedUnit.Vendor__c = vendor.id;
        insert customerOwnedUnit;
        UnitOrderingWrapper.SortingAttrs sortAttrs= new UnitOrderingWrapper.SortingAttrs();
        sortAttrs.FieldLabel = 'Status';
        sortAttrs.SortingOrder = 'ASC';
        String jsonString = system.json.serialize(sortAttrs);
        test.startTest();
		String response = UnitOrderingCtrl.applySortingOnOrderHistoryList(BPUtility.getEncodedString(vendor.Id),BPUtility.getEncodedString(jsonString));
        test.StopTest();
        response = BPUtility.getDecodedString(response);
        //system.assert(false,response);
		List<UnitOrderingWrapper.UnitOrderWrapper> unitList = (List<UnitOrderingWrapper.UnitOrderWrapper>) System.JSON.deserialize(response, List<UnitOrderingWrapper.UnitOrderWrapper>.class);
        system.assertEquals(1,unitList.size());
	}
}