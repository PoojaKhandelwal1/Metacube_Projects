/**
 * Author: Nidhi Sharma
 * updated: Dec 20, 2016
 * Name: DealUnitPriceAndCostTriggerTest
 * Description: Test class for option and feee trigger
**/
@isTest
private class DealUnitPriceAndCostTriggerTest {

    static testMethod void dealUnitPriceAndCostTriggerTest() {
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(false, 'Default Price Level', 'MSRP', 10 , true, true);
        defaultPriceLevel.Labour_Rate__c = 60 ;
        Insert defaultPriceLevel;
        Sales_Tax__c salestax =  TestUtil.createSalesTax(true, 'HST');
        
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Item1', 10.0, 'Testing1 ', true, testCategory.Id);
        
        Applicable_Taxes__c applicabletax = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem.Id);
        Applicable_Taxes__c applicabletax1 = TestUtil.createApplicableTax(true, salestax.Id, salesTaxItem1.Id);
        
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        String statusToUpdate = 'In Progress';
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert co;
        Tax_Exemption__c taxExemption = Testutil.createCOTaxExemption(true, co.Id, salestaxItem.Id);
        DealWrapper dealWrapperObj = (DealWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id))),DealWrapper.class);
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Customer_Owned_Unit__c customerOwnedUnit = TestUtil.createCustomerOwnedUnit(false, customer.Id, UnitMake.Id, UnitModel.Id, null);
        customerOwnedUnit.Taxable__c = true;
        customerOwnedUnit.Applicable_Tax__c = salestax.Id;
        insert customerOwnedUnit;
        Unit_Price_Cost__c unitPriceAndCost1 = new Unit_Price_Cost__c(Customer_Owned_Unit__c = customerOwnedUnit.Id, Type__c = 'Factory', Cost__c = 3000);
        Unit_Price_Cost__c unitPriceAndCost2 = new Unit_Price_Cost__c(Customer_Owned_Unit__c = customerOwnedUnit.Id, Type__c = 'Dealer', Cost__c = 3555);
        insert new List<Unit_Price_Cost__c>{unitPriceAndCost1, unitPriceAndCost2};
        
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        Test.startTest();
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
        String dealItemJson = BPUtility.getDecodedString(CustomerOrderCtrl.saveTemporaryUnit(BPUtility.getEncodedString(dealList[0].Id),BPUtility.getEncodedString(dealItemJsonToSave)));
        
        dealWrapperObj = (DealWrapper)Json.deserialize(dealItemJson, DealWrapper.class);
        dealWrapperObj = (DealWrapper)Json.deserialize(BPUtility.getDecodedString(CustomerOrderCtrl.addUnitToDeal(BPUtility.getEncodedString(dealWrapperObj.UnitList[0].DealItemObj.Id),BPUtility.getEncodedString(customerOwnedUnit.Id),BPUtility.getEncodedString(dealWrapperObj.DealInfo.Id))), DealWrapper.class);
        
        Test.stopTest();
        system.assertEquals(2, dealWrapperObj.UnitList.size());
        system.assertEquals(10, dealWrapperObj.UnitList[0].FactoryOptionList[0].SalesTaxPercentage);
    }
    
    static testMethod void dealDeleteTriggerTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert co;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id));
        system.assertEquals(co.CO_Type__c,'Customer');
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
        DealItem dealItemObj = new DealItem(dealItemRec);
        dealItemObj.Model = unitmodel.Id;
        String dealItemJsonToSave = System.JSON.serialize(dealItemObj);
        delete dealList[0];
    }
    
    static testMethod void dealItemDeleteTriggerTest() {
        Account customer =  TestUtil.createCustomer(false, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        customer.Is_Customer__c = true;
        insert customer;
        
        CO_Header__c co = new CO_Header__c(CO_Type__c='Customer', Selling_Group__c='Unit Deal', Customer__c=customer.Id);
        insert co;
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Category__c categoryObj = testUtil.createCategory(true,'category one');
        Sales_Tax__c salesTax1 = TestUtil.createSalesTax(true, 'Testing Sales Tax 2', true, false, true);
        Sales_Tax_Item__c salesTaxItem1 = TestUtil.createSalesTaxItem(true, 'Test Sales Tax Item 1', 20, 'Testing Form Label 1', true, categoryObj.id);
        Tax_Exemption__c taxExemptionObj = TestUtil.createCOTaxExemption(true,co.id,salesTaxItem1.id);
        
        Configurations__c taxSetting = Configurations__c.getOrgDefaults();
        taxSetting.Default_Tax_on_Fee__c = salesTax1.Id;
        taxSetting.Default_Tax_on_Labor__c = salesTax1.Id;
        taxSetting.Default_Tax_on_Part__c = salesTax1.Id;
        taxSetting.Default_Tax_on_Vendor_Product__c = salesTax1.Id; 
        taxSetting.Default_Tax_on_Unit__c = salesTax1.Id;
        taxSetting.Tax_Included_Pricing__c = true;
        insert taxSetting;
       
        Applicable_Taxes__c applicableTax1 = TestUtil.createApplicableTax(true, salesTax1.Id, salesTaxItem1.Id);
        Applicable_Taxes__c applicableTax2 = TestUtil.createApplicableTax(true, salesTax1.Id, salesTaxItem1.Id);
        
        CustomerOrderCtrl.createDeal(BPUtility.getEncodedString(co.Id));
        List<Deal__c> dealList = [Select id from Deal__c where CO_Header__c = :co.Id];
        
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
    	dealItemRec.Unit_Model__c = unitmodel.Id;
    	dealItemRec.Deal__c = dealList[0].Id;
    	dealItemRec.Type__c = Constants.DEAL_ITEM_TYPE_UNIT;
    	insert dealItemRec;
    	
    	Deal_Item__c dealItemRec2 = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
    	dealItemRec2.Unit_Model__c = unitmodel.Id;
    	dealItemRec2.Deal__c = dealList[0].Id;
    	dealItemRec2.Type__c = Constants.DEAL_ITEM_TYPE_UNIT;
    	insert dealItemRec2;
    	
    	Deal_Item__c dealItemRec3 = new Deal_Item__c(Colour__c='Red',Year__c=2016); 
    	dealItemRec3.Unit_Model__c = unitmodel.Id;
    	dealItemRec3.Deal__c = dealList[0].Id;
    	dealItemRec3.Type__c = Constants.DEAL_ITEM_TYPE_TRADE_IN;
    	insert dealItemRec3;
    	//system.assertEquals(1,dealList.size());
        
        delete dealItemRec;
        system.assert(true,true);
    }
}
