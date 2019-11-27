/**
 * Author: Durga Singh
 * Since: July 17, 2015
 * Name: ViewCustomerCtrlTest
 * Description: Test for Controller Class of view customer.
**/
@isTest
private class ViewCustomerCtrlTest {


    /**
     * Name: getCustomerInfoTest 
     * Desc: Test to fetch customer information on customerId.
     * @param: 
     * @return: 
    **/
    
    static testMethod void getCustomerInfoTest() {
 		Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		Customer_Owned_Unit__c  customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, Customer.Id, null, null, null, 'VIN123');
		String customerInfo = BPUtility.getDecodedString(ViewCustomerCtrl.getCustomerInfo(BPUtility.getEncodedString(customer.Id)));
        
        
		CustomerDetail customers = (CustomerDetail) System.JSON.deserialize(customerInfo, CustomerDetail.class);
        system.assertEquals(customers.CustomerInfo.BusinessName , 'customerName');
        system.assertEquals(customers.CustomerInfo.HomeEmail , 'abc@abc.com');
    }
    
    /**
     * Name: getSimilarCOUsTest 
     * Desc: Test to fetch similar COUs on VIN.
     * @param: 
     * @return: 
    **/
    
    static testMethod void getSimilarCOUsTest() {
 		Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		Account customer1 = TestUtil.createCustomer(true, 'customerName1', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		
 		Unit_Make__c unitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c unitModel = testutil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
 		Customer_Owned_Unit__c  customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, customer.Id, unitMake.Id, unitModel.Id, null, 'VIN123');
 		
 		String similarCOUs = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarCOUs(BPUtility.getEncodedString('VIN123')));
     	List<CustomerOwnedUnit> CustomerOwnedUnits = (List<CustomerOwnedUnit>) System.JSON.deserialize(similarCOUs, List<CustomerOwnedUnit>.class);
        system.assertEquals(CustomerOwnedUnits.size() , 1);
        
        String similarCOUs1 = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarCOUs(BPUtility.getEncodedString('VIN1234')));
     	List<CustomerOwnedUnit> CustomerOwnedUnits1 = (List<CustomerOwnedUnit>) System.JSON.deserialize(similarCOUs1, List<CustomerOwnedUnit>.class);
        system.assertEquals(CustomerOwnedUnits1.size() , 0);
    }
    
    /**
     * Name: getsaveCOUTest 
     * Desc: Test to save COU.
     * @param: 
     * @return: 
    **/
    
    static testMethod void getsaveCOUTest() {
 		Account Customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		Account Customer1 = TestUtil.createCustomer(true, 'customerName1', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		
 		Unit_Make__c UnitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c UnitModel = testutil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
 		Customer_Owned_Unit__c  customerOwnedUnit = TestUtil.createCustomerOwnedUnit(true, Customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
 		
 		Test.starttest();
 		String similarCOUs = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarCOUs(BPUtility.getEncodedString('VIN123')));
 		String saveCOUs = BPUtility.getDecodedString(ViewCustomerCtrl.saveCOU(BPUtility.getEncodedString(Customer1.Id), BPUtility.getEncodedString(similarCOUs)));
 		Test.stoptest();
     	
     	List<CustomerOwnedUnit> CustomerOwnedUnits = (List<CustomerOwnedUnit>) System.JSON.deserialize(similarCOUs, List<CustomerOwnedUnit>.class);
        system.assertEquals(CustomerOwnedUnits.size(), 1);
    }
    
      /**
     * Name: getCOURecordByIdTest 
     * Desc: Test to getCOURecordById.
     * @param: 
     * @return: 
    **/
    
    
    static testMethod void getCOURecordByIdTest() {
 		Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		customer.Is_Customer__c = true;
 		insert customer;
 		Unit_Make__c UnitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c UnitModel = testutil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
 		Customer_Owned_Unit__c  customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, Customer.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
 		customerOwnedUnit.VIN_Number__c = 'VIN123';
 		insert customerOwnedUnit;
 		
 		string COUList = BPUtility.getDecodedString(ViewCustomerctrl.getCOURecordById(BPUtility.getEncodedString(customerOwnedUnit.Id)));
 		List<CustomerOwnedUnit> CustomerOwnedUnits = (List<CustomerOwnedUnit>) System.JSON.deserialize(COUList, List<CustomerOwnedUnit>.class);
        system.assertEquals(CustomerOwnedUnits[0].VIN , 'VIN123');
    }
    
     /**
     * Name: getRelatedCustomerByCustomerIdTest 
     * Desc: Test to getRelatedCustomerByCustomerId.
     * @param: 
     * @return: 
    **/
    
    
	static testMethod void getRelatedCustomerByCustomerIdTest() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Account customerA =  TestUtil.createCustomer(true, 'DST1', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		People__c relationship = TestUtil.createPeople(true, customer.Id, customerA.Id, 'Employee');
 		
 		
 		string relatedCustomers = BPUtility.getDecodedString(ViewCustomerctrl.getRelatedCustomerByCustomerId(BPUtility.getEncodedString(customerA.Id)));
 		List<RelatedCustomer> relatedCustomersList = (List<RelatedCustomer>) System.JSON.deserialize(relatedCustomers, List<RelatedCustomer>.class);
        system.assertEquals(relatedCustomersList.size() , 1);
        system.assertEquals(relatedCustomersList[0].Relation , 'Employer');
        
    }
    
    /**
     * Name: updateRelatedCustomerTest 
     * Desc: Test to update information for RelatedCustomer.
     * @param: 
     * @return: 
    **/
    
    
   static testMethod void updateRelatedCustomerTest() {
 		Account customer =  TestUtil.createCustomer(false, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Account customerA =  TestUtil.createCustomer(true, 'DST1', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		
 		
 		customer.ParentId = customerA.Id ;
 		insert customer;
 		People__c relationship = TestUtil.createPeople(true, customer.Id, customerA.Id, 'Friend');
 		
 		String customerInfo = BPUtility.getDecodedString(ViewCustomerCtrl.getRelatedCustomerByCustomerId(BPUtility.getEncodedString(customerA.Id)));
 		List<RelatedCustomer> customers = (List<RelatedCustomer>) System.JSON.deserialize(customerInfo, List<RelatedCustomer>.class);
 		customers[0].Relation = 'Family' ;
 		
 		String customersJSONString = System.JSON.serialize(customers);
 		String updatedCustomerRelationship =  BPUtility.getDecodedString(ViewCustomerCtrl.updateRelatedCustomer(BPUtility.getEncodedString(customersJSONString)));
 		List<RelatedCustomer> customersWithNewRelation = (List<RelatedCustomer>) System.JSON.deserialize(updatedCustomerRelationship, List<RelatedCustomer>.class);
 		system.assertEquals(customersWithNewRelation[0].Relation , 'Family');
 		
 		customers[0].Relation = null ;
 		
 		String customersJSONString1 = System.JSON.serialize(customers);
 		String updatedCustomerRelationship1 =  BPUtility.getDecodedString(ViewCustomerCtrl.updateRelatedCustomer(BPUtility.getEncodedString(customersJSONString1)));
 		List<RelatedCustomer> customersWithNewRelation1 = (List<RelatedCustomer>) System.JSON.deserialize(updatedCustomerRelationship1, List<RelatedCustomer>.class);
 		//system.assert(false, customersWithNewRelation1);
 		system.assertEquals(customersWithNewRelation1.size() , 0);
 		
    }
    
     /**
     * Name: getCustomerContactByCustomerIdTest 
     * Desc: Test to ugetCustomerContactByCustomerId.
     * @param: 
     * @return: 
    **/
    
    static testMethod void getCustomerContactByCustomerIdTest() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Contact contact = TestUtil.createContact(true, 'abc', 'last', customer.Id);
 		
 		String newContact = BPUtility.getDecodedString(ViewCustomerCtrl.getCustomerContactByCustomerId(BPUtility.getEncodedString(customer.Id)));
 		List<CustomerContact> customerContact = (List<CustomerContact>) System.JSON.deserialize(newContact, List<CustomerContact>.class);
 		//system.assert(false, newContact);
 		system.assertEquals(newContact.contains('abc'), true);
 		system.assertEquals(customerContact[0].FirstName, 'abc');
 		
    }
    
     /**
     * Name: getCustomerContactByIdTest 
     * Desc: Test to getCustomerContactById.
     * @param: 
     * @return: 
    **/
    
     static testMethod void getCustomerContactByIdTest() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Contact contact = TestUtil.createContact(true, 'abc', 'last', customer.Id);
 		
 		String newContact = BPUtility.getDecodedString(ViewCustomerCtrl.getCustomerContactById(BPUtility.getEncodedString(contact.Id)));
 		List<CustomerContact> customerContact = (List<CustomerContact>) System.JSON.deserialize(newContact, List<CustomerContact>.class);
 		//system.assert(false, newContact);
 		system.assertEquals(newContact.contains('abc'), true);
 		system.assertEquals(customerContact[0].FirstName, 'abc');
 		
    }
    
    /**
     * Name: updateCustomerContactTest 
     * Desc: Test to update information for customer contact.
     * @param: 
     * @return: 
    **/
    
    
    static testMethod void updateCustomerContactTest() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Contact contact = TestUtil.createContact(true, 'abc', 'last', customer.Id);
 		
 		String newContact = BPUtility.getDecodedString(ViewCustomerCtrl.getCustomerContactById(BPUtility.getEncodedString(contact.Id)));
 		List<CustomerContact> customerContact = (List<CustomerContact>) System.JSON.deserialize(newContact, List<CustomerContact>.class);
 		customerContact[0].FirstName = 'DST';
 		String customercontactsJSONString = System.JSON.serialize(customerContact);
 		String CustomerNewContacts = BPUtility.getDecodedString(ViewCustomerCtrl.updateCustomerContact(BPUtility.getEncodedString(customercontactsJSONString)));
 		List<CustomerContact> customerNewContact = (List<CustomerContact>) System.JSON.deserialize(CustomerNewContacts, List<CustomerContact>.class);
 		system.assertEquals(customerNewContact[0].FirstName, 'DST');
 		
    }
    
    /**
     * Name: updateCustomerContactRelationTest 
     * Desc: Test to update  relation for customer contact.
     * @param: 
     * @return: 
    **/
    
    static testMethod void updateCustomerContactRelationTest() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Contact contact = TestUtil.createContact(false, 'abc', 'last', customer.Id);
 		contact.Relationship__c = 'Friend';
 		insert contact;
 		
 		String newContact = BPUtility.getDecodedString(ViewCustomerCtrl.getCustomerContactById(BPUtility.getEncodedString(contact.Id)));
 		List<CustomerContact> customerContact = (List<CustomerContact>) System.JSON.deserialize(newContact, List<CustomerContact>.class);
 		customerContact[0].Relation = 'Family';
 		String customercontactsJSONString = System.JSON.serialize(customerContact);
 		String CustomerNewContacts = BPUtility.getDecodedString(ViewCustomerCtrl.updateCustomerContactRelation(BPUtility.getEncodedString(customercontactsJSONString)));
 		List<CustomerContact> customerNewContact = (List<CustomerContact>) System.JSON.deserialize(CustomerNewContacts, List<CustomerContact>.class);
 		system.assertEquals(customerNewContact[0].Relation, 'Family');
 		
    }
    
     /**
     * Name: removeCustomerContactRecordTest 
     * Desc: Test to remove relation for customer contact.
     * @param: 
     * @return: 
    **/
    
     static testMethod void removeCustomerContactRecordTest() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Contact contact = TestUtil.createContact(true, 'abc', 'last', customer.Id);
 		Contact contact1 = TestUtil.createContact(true, 'DST', 'last', customer.Id);
 		
 		
 		String newContact = BPUtility.getDecodedString(ViewCustomerCtrl.removeCustomerContactRecord(BPUtility.getEncodedString(customer.Id), BPUtility.getEncodedString(contact.Id)));
 		List<CustomerContact> customerContact = (List<CustomerContact>) System.JSON.deserialize(newContact, List<CustomerContact>.class);
 
 		system.assertEquals(customerContact.size(), 1);
 		
    }
    
     /**
     * Name: removeCOURecordTest 
     * Desc: Test to remove COUs records.
     * @param: 
     * @return: 
    **/
    
     static testMethod void removeCOURecordTest() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Contact contact = TestUtil.createContact(true, 'abc', 'last', customer.Id);
 		Contact contact1 = TestUtil.createContact(true, 'DST', 'last', customer.Id);
 		
 		
 		String newContact = BPUtility.getDecodedString(ViewCustomerCtrl.removeCOURecord(BPUtility.getEncodedString(customer.Id), BPUtility.getEncodedString(contact.Id)));
 		List<CustomerContact> customerContact = (List<CustomerContact>) System.JSON.deserialize(newContact, List<CustomerContact>.class);
 
 		system.assertEquals(customerContact.size(), 0);
 		
    }
    
     /**
     * Name: getMakeListTest 
     * Desc: Test to verify the retrieved Make List 
     * @param: 
     * @return:
     * @author:Nikhil 
    **/
    
    static testMethod void getMakeListTest() {
    	Unit_Make__c UnitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
    	
 		string UMList = BPUtility.getDecodedString(ViewCustomerctrl.getMakeList());
 		List<UnitMake> unitMakeList = (List<UnitMake>) System.JSON.deserialize(UMList, List<UnitMake>.class);
        system.assertEquals(unitMakeList[0].UnitMakeName,'unitMakeName');
    	
    
    
    }
    
    /**
     * Name: getModelListTest 
     * Desc: Test to verify the retrieved Model List 
     * @param: 
     * @return:
     * @author:Nikhil 
    **/
    
    static testMethod void getModelListTest() {
    	
    	Unit_Make__c unitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c unitModel = testutil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
    	
 		string UMList = BPUtility.getDecodedString(ViewCustomerctrl.getModelList(BPUtility.getEncodedString(unitMake.Id)));
 		List<UnitModel> unitModelList = (List<UnitModel>) System.JSON.deserialize(UMList, List<UnitModel>.class);
        system.assertEquals(unitModelList[0].UnitModelName,'unitModelName');
    	
    
    
    }
    
     /**
     * Name: getRelatedCustomerByCustomerIdTest 
     * Desc: Test to verify the retrieved Customer by using CustomerID 
     * @param: 
     * @return:
     * @author : Nikhil 
    **/
    
    
	static testMethod void getRelatedCustomerByCustomerId1Test() {
 		Account customer =  TestUtil.createCustomer(true, 'DST', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		Account customerA =  TestUtil.createCustomer(true, 'DST1', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual', 'ds', 'rathore', '9783764669', 'abc', 'work@work.com', 'other@other.com', '1234567890','facebook', 'twitter', 'linkedin'  );
 		
 		string customerDetail = BPUtility.getDecodedString(ViewCustomerctrl.getRelatedCustomerByCustomerId1(BPUtility.getEncodedString(customerA.Id)));
 		List<Account> customerDetailList  = (List<Account>) System.JSON.deserialize(customerDetail, List<Account>.class);
        system.assertEquals(customerDetailList.size() , 0);
        
        
    }
    
    
    
     /**
     * Name: getSubModelListTest 
     * Desc: Test to getSubModelList
     * @param: 
     * @return:
     * @author : Nikhil 
    **/
    
    
	static testMethod void getSubModelListTest() {
 		Unit_Make__c unitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c unitModel = testutil.createUnitModel(false, 'unitModelName', 'VIN', true, unitMake.Id);
 		unitModel.Sub_Model__c = 'unitSubModelName' ;
 		insert unitModel;
 		Unit_Sub_Model__c unitSubModel = new Unit_Sub_Model__c();
 		unitSubModel.Sub_Model_Name__c = 'unitSubModelName';
 		unitSubModel.Active__c = true;
 		unitSubModel.Unit_Model__c = unitModel.ID;
 		unitSubModel.VIN_Code__c = 'VIN';
 		
 		insert unitSubModel;
 		
    	
    	string USMList = BPUtility.getDecodedString(ViewCustomerctrl.getSubModelList(BPUtility.getEncodedString(unitModel.Id),BPUtility.getEncodedString(unitMake.Id)));
 		List<UnitSubModel> unitSubModelList = (List<UnitSubModel>) System.JSON.deserialize(USMList, List<UnitSubModel>.class);
        system.assertEquals(unitSubModelList[0].SubModelName,'unitSubModelName');
        
    }
    

	 /**
     * Name: getDefaultUnitCategoryTest 
     * Desc: Test to getDefaultUnitCategory
     * @param: 
     * @return:
     * @author : Nikhil 
    **/
    
    
	static testMethod void getDefaultUnitCategoryTest() {
		Account vendor = TestUtil.createVendor(true, 'Test Vendor');
       	Category__c testCategory = TestUtil.createCategory(true, 'Test Category','Unit','Test Description',true,true);
        string unitCategory = BPUtility.getDecodedString(ViewCustomerctrl.getDefaultUnitCategory());
 		Category unitCategoryList = (Category) System.JSON.deserialize(unitCategory, Category.class);
		system.assertEquals(unitCategoryList.CategoryName, 'Test Category');
		system.assertEquals(unitCategoryList.IsDefault, true);
		  
    }
    
    
   
	 /**
     * Name: getApplicableTaxListTest 
     * Desc: Test to getApplicableTaxList
     * @param: 
     * @return:
     * @author : Nikhil 
    **/
    
    
	static testMethod void getApplicableTaxListTest() { 
		
		Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Country__c country = TestUtil.createCountry(true, 'Test Country 1', true, true);
        State__c state = TestUtil.createState(true, 'Test State 1', country.Id, true);
            
        Configurations__c taxSetting = Configurations__c.getOrgDefaults();
        taxSetting.Default_Tax_on_Fee__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Labor__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Part__c = defaultSalesTax.Id;
        taxSetting.Default_Tax_on_Vendor_Product__c = defaultSalesTax.Id; 
        taxSetting.Default_Tax_on_Unit__c = defaultSalesTax.Id;
        taxSetting.Tax_Included_Pricing__c = false;
        taxSetting.Country_Id__c = country.Id;
        taxSetting.State_Id__c = state.Id;
        //taxSetting.Time_Zone__c = state.Id;
        insert taxSetting;
        
		string applicableTax = BPUtility.getDecodedString(ViewCustomerCtrl.getApplicableTaxList());
		System.assertEquals(applicableTax.contains('Test Sales Tax'), true);
	
	}
    
    
    
    /**
     * Name: getSimilarUnitsTest 
     * Desc: Test to setUnitFields
     * @param: 
     * @return:
     * @author : Nikhil 
   **/
    
    
	static testMethod void getSimilarUnitsTest() {
	
		Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		customer.Is_Customer__c = true;
 		insert customer;
 		
 		Account customer1 = TestUtil.createCustomer(false, 'customerName1', 'abc@abcd.com', 'jaipur', '1111161112', null, null, false, true,'Individual','firstname11', 'lastname11', '9999996999', 'BillingStreet1');
 		customer1.Is_Customer__c = true;
 		insert customer1;
 		
 		Account customer2 = TestUtil.createCustomer(false, 'customerName2', 'abc@abcde.com', 'jaipur', '1111151112', null, null, false, true,'Individual','firstname12', 'lastname12', '9999991999', 'BillingStreet2');
 		customer2.Is_Customer__c = true;
 		insert customer2;
 		
 		Unit_Make__c UnitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c UnitModel = testutil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, Customer.Id, UnitMake.Id, UnitModel.Id, null, null);
 		//customerOwnedUnitRec.VIN_Number__c = 'VIN123';
 		customerOwnedUnitRec.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec.Status__c = 'Active' ;
 		customerOwnedUnitRec.Plate__c = 'RJ143021';
 		//customerOwnedUnitRec.Other_Serial_No__c= 'S123456' ;
 		insert customerOwnedUnitRec;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec1 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
 		customerOwnedUnitRec1.VIN_Number__c = 'VIN123';
 		customerOwnedUnitRec1.Plate__c = 'RJ143023';
 		customerOwnedUnitRec1.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec1.Status__c = 'Active' ;
 		
 		insert customerOwnedUnitRec1;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec2 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN12356789012345');
 		customerOwnedUnitRec2.VIN_Number__c = 'VIN12356789012345';
 		customerOwnedUnitRec2.Plate__c = 'RJ143024';
 		customerOwnedUnitRec2.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec2.Status__c = 'Active' ;
 		insert customerOwnedUnitRec2;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRecA = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN12356789012344');
 		customerOwnedUnitRecA.VIN_Number__c = 'VIN12356789012344';
 		customerOwnedUnitRecA.Plate__c = 'RJ143024';
 		customerOwnedUnitRecA.Unit_Type__c ='ORDU' ; 
 		customerOwnedUnitRecA.Status__c = 'On Order' ;
 		insert customerOwnedUnitRecA;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRecB = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'TIN12356789012344');
 		customerOwnedUnitRecB.VIN_Number__c = 'TIN12356789012344';
 		//customerOwnedUnitRecB.Plate__c = 'RJ143121';
 		customerOwnedUnitRecB.Unit_Type__c ='STOCK' ; 
 		customerOwnedUnitRecB.Status__c = 'Available' ;
 		customerOwnedUnitRecB.Other_Serial_No__c= 'S123456' ;
 		insert customerOwnedUnitRecB;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRecC = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'TIN12356789012347');
 		customerOwnedUnitRecC.VIN_Number__c = 'TIN12356789012347';
 		//customerOwnedUnitRecC.Plate__c = 'RJ143121';
 		customerOwnedUnitRecC.Unit_Type__c ='STOCK' ; 
 		customerOwnedUnitRecC.Status__c = 'Available' ;
 		customerOwnedUnitRecC.Engine_Serial_No__c = 'SNO1234';
 		insert customerOwnedUnitRecC;
 		
 		//Comparision COUs
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec3 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN12356789012345');
 		customerOwnedUnitRec3.VIN_Number__c = 'VIN12356789012345';
 		customerOwnedUnitRec3.Plate__c = 'RJ143024';
 		customerOwnedUnitRec3.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec3.Status__c = 'Active' ;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec4 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'NIN12356789012345');
 		customerOwnedUnitRec4.VIN_Number__c = 'NIN12356789012345';
 		customerOwnedUnitRec4.Plate__c = 'RJ143022';
 		customerOwnedUnitRec4.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec4.Status__c = 'Active' ;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec5 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, null);
 		//customerOwnedUnitRec5.VIN_Number__c = 'VIN121';
 		customerOwnedUnitRec5.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec5.Status__c = 'Active' ;
 		customerOwnedUnitRec.Plate__c = 'RJ143021';
 		//customerOwnedUnitRec.Other_Serial_No__c= 'S123456' ;
 		
 		string unitJSONString = System.JSON.serialize(new customerOwnedUnit(customerOwnedUnitRec3));
 		string unitJSONString1 = System.JSON.serialize(new customerOwnedUnit(customerOwnedUnitRec4));
 		string unitJSONString2 = System.JSON.serialize(new customerOwnedUnit(customerOwnedUnitRec5));
		
		string similarUnits = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarUnits(BPUtility.getEncodedString(unitJSONString)));
		string similarUnits1 = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarUnits(BPUtility.getEncodedString(unitJSONString1)));
		string similarUnits2 = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarUnits(BPUtility.getEncodedString(unitJSONString2)));
		
		List<UnitSuggestion> unitSuggestionList = (List<UnitSuggestion>) System.JSON.deserialize(similarUnits, List<UnitSuggestion>.class);
		List<UnitSuggestion> unitSuggestionList1 = (List<UnitSuggestion>) System.JSON.deserialize(similarUnits1, List<UnitSuggestion>.class);
		List<UnitSuggestion> unitSuggestionList2 = (List<UnitSuggestion>) System.JSON.deserialize(similarUnits2, List<UnitSuggestion>.class);
		
		System.assertEquals(unitSuggestionList[0].PriorityNumber,1);
		System.assertEquals(unitSuggestionList1[0].PriorityNumber,4);	
	} 
	
	 /**
     * Name: getSimilarUnitsTestA 
     * Desc: Test to setUnitFields
     * @param: 
     * @return:
     * @author : Nikhil 
   **/
    
    
	static testMethod void getSimilarUnitsTestA() {
		
		Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		customer.Is_Customer__c = true;
 		insert customer;
 		
 		Account customer1 = TestUtil.createCustomer(false, 'customerName1', 'abc@abcd.com', 'jaipur', '1111161112', null, null, false, true,'Individual','firstname11', 'lastname11', '9999996999', 'BillingStreet1');
 		customer1.Is_Customer__c = true;
 		insert customer1;
 		
 		Account customer2 = TestUtil.createCustomer(false, 'customerName2', 'abc@abcde.com', 'jaipur', '1111151112', null, null, false, true,'Individual','firstname12', 'lastname12', '9999991999', 'BillingStreet2');
 		customer2.Is_Customer__c = true;
 		insert customer2;
 		
 		Unit_Make__c UnitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c UnitModel = testutil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false, Customer.Id, UnitMake.Id, UnitModel.Id, null, null);
 		//customerOwnedUnitRec.VIN_Number__c = 'VIN123';
 		customerOwnedUnitRec.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec.Status__c = 'Active' ;
 		customerOwnedUnitRec.Plate__c = 'RJ143021';
 		//customerOwnedUnitRec.Other_Serial_No__c= 'S123456' ;
 		insert customerOwnedUnitRec;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec1 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN123');
 		customerOwnedUnitRec1.VIN_Number__c = 'VIN123';
 		customerOwnedUnitRec1.Plate__c = 'RJ143023';
 		customerOwnedUnitRec1.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec1.Status__c = 'Active' ;
 		
 		insert customerOwnedUnitRec1;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec2 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN12356789012345');
 		customerOwnedUnitRec2.VIN_Number__c = 'VIN12356789012345';
 		customerOwnedUnitRec2.Plate__c = 'RJ143024';
 		customerOwnedUnitRec2.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec2.Status__c = 'Active' ;
 		insert customerOwnedUnitRec2;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRecA = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN12356789012344');
 		customerOwnedUnitRecA.VIN_Number__c = 'VIN12356789012344';
 		customerOwnedUnitRecA.Plate__c = 'RJ143024';
 		customerOwnedUnitRecA.Unit_Type__c ='ORDU' ; 
 		customerOwnedUnitRecA.Status__c = 'On Order' ;
 		insert customerOwnedUnitRecA;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRecB = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'TIN12356789012344');
 		customerOwnedUnitRecB.VIN_Number__c = 'TIN12356789012344';
 		//customerOwnedUnitRecB.Plate__c = 'RJ143121';
 		customerOwnedUnitRecB.Unit_Type__c ='STOCK' ; 
 		customerOwnedUnitRecB.Status__c = 'Available' ;
 		customerOwnedUnitRecB.Other_Serial_No__c= 'S123456' ;
 		insert customerOwnedUnitRecB;
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRecC = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'TIN12356789012347');
 		customerOwnedUnitRecC.VIN_Number__c = 'TIN12356789012347';
 		//customerOwnedUnitRecC.Plate__c = 'RJ143121';
 		customerOwnedUnitRecC.Unit_Type__c ='STOCK' ; 
 		customerOwnedUnitRecC.Status__c = 'Reserved' ;
 		customerOwnedUnitRecC.Engine_Serial_No__c = 'SNO1234';
 		insert customerOwnedUnitRecC;
 		
 		//Comparision COUs
 		Customer_Owned_Unit__c  customerOwnedUnitRec6 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'VIN12356789012444');
 		customerOwnedUnitRec6.VIN_Number__c = 'VIN12356789012444';
 		customerOwnedUnitRec6.Plate__c = 'RJ143024';
 		customerOwnedUnitRec6.Unit_Type__c ='ORDU' ; 
 		customerOwnedUnitRec6.Status__c = 'On Order' ;
 		 
 		Customer_Owned_Unit__c  customerOwnedUnitRec7 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'TIN12356789002344');
 		customerOwnedUnitRec7.VIN_Number__c = 'TIN12356789002344';
 		//customerOwnedUnitRec7.Plate__c = 'RJ143124';
 		customerOwnedUnitRec7.Unit_Type__c ='STOCK' ; 
 		customerOwnedUnitRec7.Status__c = 'Available' ;
 		customerOwnedUnitRec7.Other_Serial_No__c= 'S123456' ; 
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec8 = TestUtil.createCustomerOwnedUnit(false, Customer1.Id, UnitMake.Id, UnitModel.Id, null, 'TIN12356789022347');
 		customerOwnedUnitRec8.VIN_Number__c = 'TIN12356789022347';
 		customerOwnedUnitRec8.Unit_Type__c ='STOCK' ; 
 		customerOwnedUnitRec8.Status__c = 'Reserved' ;
 		customerOwnedUnitRec8.Engine_Serial_No__c = 'SNO1234';
		
		string unitJSONString3 = System.JSON.serialize(new customerOwnedUnit(customerOwnedUnitRec6));
		string unitJSONString4 = System.JSON.serialize(new customerOwnedUnit(customerOwnedUnitRec7));
		string unitJSONString5 = System.JSON.serialize(new customerOwnedUnit(customerOwnedUnitRec8));
		
		string similarUnits3 = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarUnits(BPUtility.getEncodedString(unitJSONString3)));
		string similarUnits4 = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarUnits(BPUtility.getEncodedString(unitJSONString4)));
		string similarUnits5 = BPUtility.getDecodedString(ViewCustomerCtrl.getSimilarUnits(BPUtility.getEncodedString(unitJSONString5)));
		
		List<UnitSuggestion> unitSuggestionList3 = (List<UnitSuggestion>) System.JSON.deserialize(similarUnits3, List<UnitSuggestion>.class);
		List<UnitSuggestion> unitSuggestionList4 = (List<UnitSuggestion>) System.JSON.deserialize(similarUnits4, List<UnitSuggestion>.class);
		List<UnitSuggestion> unitSuggestionList5 = (List<UnitSuggestion>) System.JSON.deserialize(similarUnits5, List<UnitSuggestion>.class);
	
		System.assertEquals(unitSuggestionList3[0].PriorityNumber,2);
		System.assertEquals(unitSuggestionList4[0].PriorityNumber,5);
		System.assertEquals(unitSuggestionList5[0].PriorityNumber,3);
	
	}
	
	
	 /**
     * Name: getLastVisitOrderByCustomerIdTest 
     * Desc: Test to getLastVisitOrderByCustomerId
     * @param: 
     * @return:
     * @author : Nikhil 
   **/
	static testMethod void getLastVisitOrderByCustomerIdTest() {
        PaginationSorting pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
		General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10, true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
        
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true;
        Part.Package_Qty__c = 22;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 200;
        part.Order_Lots__c = 1;   
        //part.Qty_On_Order__c = 0;  
        insert part;
       system.assertEquals(part.Packaged_Part__c,true);
       
       String lastTimeRec= viewCustomerCtrl.getLastVisitOrderByCustomerId(customer.Id);
       

	}

	static testMethod void getUnitSuggestion() {
		
		Account customer = TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
 		customer.Is_Customer__c = true;
 		insert customer;
 		
 		Unit_Make__c UnitMake =  TestUtil.createUnitMake(true, 'unitMakeName', 'VIN', true);
 		Unit_Model__c UnitModel = testutil.createUnitModel(true, 'unitModelName', 'VIN', true, unitMake.Id);
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec1 = TestUtil.createCustomerOwnedUnit(false, Customer.Id, UnitMake.Id, UnitModel.Id, null, 'TIN12356789002344');
 		customerOwnedUnitRec1.VIN_Number__c = 'TIN12356789002344';
 		customerOwnedUnitRec1.Plate__c = 'RJ143021';
 		customerOwnedUnitRec1.Unit_Type__c ='STOCK' ; 
 		customerOwnedUnitRec1.Status__c = 'Delivered' ;
 		insert customerOwnedUnitRec1;
 		UnitSuggestion similarUnits1 = new UnitSuggestion(customerOwnedUnitRec1 , 2);
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec2 = TestUtil.createCustomerOwnedUnit(false, Customer.Id, UnitMake.Id, UnitModel.Id, null, null);
 		customerOwnedUnitRec2.VIN_Number__c = 'VIN12356789002345';
 		customerOwnedUnitRec2.Unit_Type__c ='ORDU' ; 
 		customerOwnedUnitRec2.Status__c = 'Cancelled' ;
 		customerOwnedUnitRec2.Plate__c = 'RJ143051';
 		insert customerOwnedUnitRec2;
 		UnitSuggestion similarUnits2 = new UnitSuggestion(customerOwnedUnitRec2 , 1);
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec3 = TestUtil.createCustomerOwnedUnit(false, Customer.Id, UnitMake.Id, UnitModel.Id, null, null);
 		customerOwnedUnitRec3.VIN_Number__c = 'VIN12356789002346';
 		customerOwnedUnitRec3.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec3.Status__c = 'Inactive' ;
 		customerOwnedUnitRec3.Plate__c = 'RJ143061';
 		insert customerOwnedUnitRec3;
 		UnitSuggestion similarUnits3 = new UnitSuggestion(customerOwnedUnitRec3 , 3);
 		
 		Customer_Owned_Unit__c  customerOwnedUnitRec4 = TestUtil.createCustomerOwnedUnit(false, Customer.Id, UnitMake.Id, UnitModel.Id, null, null);
 		customerOwnedUnitRec4.VIN_Number__c = 'VIN12356789002347';
 		customerOwnedUnitRec4.Unit_Type__c ='COU' ; 
 		customerOwnedUnitRec4.Status__c = 'Transferred' ;
 		customerOwnedUnitRec4.Plate__c = 'RJ143071';
 		insert customerOwnedUnitRec4;
		UnitSuggestion similarUnits4 = new UnitSuggestion(customerOwnedUnitRec4 , 2);
		
		List<Customer_Owned_Unit__c> CustomerUnitList = [Select id, VIN_Number__c from Customer_Owned_Unit__c];
		
		System.assertEquals(4,CustomerUnitList.size());
	
	}

}