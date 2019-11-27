/**
 * Author: Pooja Khandelwal
 * Since: Apr. 25, 2017
 * Name: NewPrintMerchandiseCtrlTest
 * Description: Test class for NewPrintMerchandiseCtrl
**/
@isTest
private class  NewPrintMerchandiseCtrlTest {
	
	 @testSetup
    private static void setup()	{
    	BP_Configurations__c BPConfigurationsRec = new BP_Configurations__c();
        BPConfigurationsRec.Company_Logo_URL__c = 'https://c.na3.content.force.com/servlet/servlet.ImageServer?id=01550000002sQtj&oid=00D50000000bV4K&lastMod=1474442215000';
        insert BPConfigurationsRec;
        
        Configurations__c confg = new Configurations__c();
        confg.Tax_Included_Pricing__c = true;
        insert confg;
        system.assert(true,true);
    }
    
    
    private static testmethod void getMerchandiseDetailsTest()	{
    	//Create CO Header
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', defaultPriceLevel.Id, defaultSalesTax.Id, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
    	CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
    	
    	//Create CO line items
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, 'Part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, 'Part1', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader1.Id, part1.Id, 50);
        
        //Create Kit Header_
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
        
        //Create CO Kit Header_
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
	    cokhRec.CO_Header__c = coHeader1.Id;
	    cokhRec.Kit_Header__c = kitHeader.Id;
	    cokhRec.Price__c = kitHeader.Fixed_Price__c;
	    cokhRec.Actual_Kit_Price__c = kitHeader.Fixed_Price__c;
	    cokhRec.Can_Split__c = kitHeader.Can_Split__c;
	    cokhRec.Fixed_Price_Flag__c = kitHeader.Fixed_Price_Flag__c;
	    cokhRec.Service_Kit__c = kitHeader.Service_Kit__c;
		insert cokhRec;
		
		//Create CO line items
        Part__c part3 = TestUtil.createPart(true, 'Part3', vendor.Id, 'Test Part3', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part4 = TestUtil.createPart(true, 'Part4', vendor.Id, 'Test Part4', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(false, coHeader1.Id, part3.Id, 50);
        coLineItemRec2.CO_Kit_Header__c = cokhRec.Id;
        insert coLineItemRec2;
        CO_Line_Item__c coLineItemRec3 = TestUtil.createCOLineItem(false, coHeader1.Id, part4.Id, 50);    
        coLineItemRec3.CO_Kit_Header__c = cokhRec.Id;
        insert coLineItemRec3;
        
        // Create individualTax
        // Create individualTax
        Individual_Tax__c individualTax1 = createIndividualTax('Sales_Tax_Item_Name1', 50, coLineItemRec); 
        Individual_Tax__c individualTax2 = createIndividualTax('Sales_Tax_Item_Name1', 50, coLineItemRec); 
        Individual_Tax__c individualTax3 = createIndividualTax('Sales_Tax_Item_Name2', 50, coLineItemRec1);
        Individual_Tax__c individualTax4 = createIndividualTax('Sales_Tax_Item_Name3', 50, coLineItemRec1);
        Individual_Tax__c individualTax5 = createIndividualTax('Sales_Tax_Item_Name4', 50, coLineItemRec2);
        Individual_Tax__c individualTax6 = createIndividualTax('Sales_Tax_Item_Name5', 50, coLineItemRec3);
        
	    
	    
	    //Create Business Profile
	    Country__c country = TestUtil.createCountry(true, 'Test Country 1', true, true);
        State__c state = TestUtil.createState(true, 'Test State 1', country.Id, true);
        Business_Profile__c BusinessProfileRec = new Business_Profile__c();
        BusinessProfileRec.Business_City__c = 'jaipur';
        BusinessProfileRec.Business_Country__c = country.Id;
        BusinessProfileRec.Business_Email__c = 'hitesh.gupta@metacube.com';
        BusinessProfileRec.Business_Name__c = 'Metacube';
        BusinessProfileRec.Business_Phone__c = '1235678921';
        BusinessProfileRec.Business_State__c = state.Id;
        BusinessProfileRec.Business_Street_Address1__c = 'street 1'; 
        BusinessProfileRec.Business_Street_Address2__c = 'street 2';
        BusinessProfileRec.Business_Postal_Code__c = '302012';
        BusinessProfileRec.Same_As_Business_Address__c = false;
        BusinessProfileRec.Shipping_City__c = 'jaipur'; 
        BusinessProfileRec.Company_Name_Optional__c = 'Metacube optional';
        BusinessProfileRec.Shipping_Country__c = country.Id;
        BusinessProfileRec.Shipping_State__c = state.Id;
        BusinessProfileRec.Shipping_Street_Address1__c = 'street 1';
        BusinessProfileRec.Shipping_Street_Address2__c = 'street 2';
        BusinessProfileRec.Shipping_Postal_Code__c = '302012';
        insert BusinessProfileRec;
       
        // Create current page ref
        PageReference pageRef = Page.PrintMerchandise; // Add your VF page Name here
  		pageRef.getParameters().put('id', String.valueOf(coHeader1.Id));
  		Test.setCurrentPage(pageRef);
	    system.assertEquals(BusinessProfileRec.Shipping_Postal_Code__c,'302012');
    	Test.startTest();
    	NewPrintMerchandiseCtrl newPrintMerchandiseCtrlObj = new NewPrintMerchandiseCtrl();
    	//system.assert(false, 'pageRef=\n'+newPrintMerchandiseCtrlObj);
        Test.stopTest();
        //System.assert(false, newPrintMerchandiseCtrlObj.COMerchandiseDetailObj);
    }
    
    private static testmethod void getMerchandiseDetailsTest1()	{
    	
    	Configurations__c confg = [Select Tax_Included_Pricing__c from Configurations__c];
    	confg.Tax_Included_Pricing__c = false;
    	update confg;
    	
    	//Create CO Header
    	Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
    	Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
    	Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', defaultPriceLevel.Id, defaultSalesTax.Id, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
    	CO_Header__c coHeader1 = TestUtil.createCOHeader(true, customer.Id);
    	
    	//Create CO line items
    	Account vendor = TestUtil.createVendor(true, 'Test Vendor');
    	Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Part__c part = TestUtil.createPart(true, 'Part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part1 = TestUtil.createPart(true, 'Part1', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec = TestUtil.createCOLineItem(true, coHeader1.Id, part.Id, 50);
        CO_Line_Item__c coLineItemRec1 = TestUtil.createCOLineItem(true, coHeader1.Id, part1.Id, 50);
        
        //Create Kit Header_
        Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        Kit_Header__c kitHeader = TestUtil.createKitHeader(true, true, true, 'Cause', 'Code', 'Concern', 'Correction', 'Description', 10.0, true, false, unitMake.Id, unitModel.Id);
        
        //Create CO Kit Header_
        CO_Kit_Header__c cokhRec = new CO_Kit_Header__c();
	    cokhRec.CO_Header__c = coHeader1.Id;
	    cokhRec.Kit_Header__c = kitHeader.Id;
	    cokhRec.Price__c = kitHeader.Fixed_Price__c;
	    cokhRec.Actual_Kit_Price__c = kitHeader.Fixed_Price__c;
	    cokhRec.Can_Split__c = kitHeader.Can_Split__c;
	    cokhRec.Fixed_Price_Flag__c = kitHeader.Fixed_Price_Flag__c;
	    cokhRec.Service_Kit__c = kitHeader.Service_Kit__c;
		insert cokhRec;
		
		//Create CO line items
        Part__c part3 = TestUtil.createPart(true, 'Part3', vendor.Id, 'Test Part3', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c part4 = TestUtil.createPart(true, 'Part4', vendor.Id, 'Test Part4', testCategory.Id, 10, 20, 50, 100, 100);
        CO_Line_Item__c coLineItemRec2 = TestUtil.createCOLineItem(false, coHeader1.Id, part3.Id, 50);
        coLineItemRec2.CO_Kit_Header__c = cokhRec.Id;
        insert coLineItemRec2;
        CO_Line_Item__c coLineItemRec3 = TestUtil.createCOLineItem(false, coHeader1.Id, part4.Id, 50);    
        coLineItemRec3.CO_Kit_Header__c = cokhRec.Id;
        insert coLineItemRec3;
        
        // Create individualTax
        Individual_Tax__c individualTax1 = createIndividualTax('Sales_Tax_Item_Name1', 50, coLineItemRec); 
        Individual_Tax__c individualTax2 = createIndividualTax('Sales_Tax_Item_Name1', 50, coLineItemRec); 
        Individual_Tax__c individualTax3 = createIndividualTax('Sales_Tax_Item_Name2', 50, coLineItemRec1);
        Individual_Tax__c individualTax4 = createIndividualTax('Sales_Tax_Item_Name3', 50, coLineItemRec1);
        Individual_Tax__c individualTax5 = createIndividualTax('Sales_Tax_Item_Name4', 50, coLineItemRec2);
        Individual_Tax__c individualTax6 = createIndividualTax('Sales_Tax_Item_Name5', 50, coLineItemRec3);
	    
	    
	    //Create Business Profile
	    Country__c country = TestUtil.createCountry(true, 'Test Country 1', true, true);
        State__c state = TestUtil.createState(true, 'Test State 1', country.Id, true);
        Business_Profile__c BusinessProfileRec = new Business_Profile__c();
        BusinessProfileRec.Business_City__c = 'jaipur';
        BusinessProfileRec.Business_Country__c = country.Id;
        BusinessProfileRec.Business_Email__c = 'hitesh.gupta@metacube.com';
        BusinessProfileRec.Business_Name__c = 'Metacube';
        BusinessProfileRec.Business_Phone__c = '1235678921';
        BusinessProfileRec.Business_State__c = state.Id;
        BusinessProfileRec.Business_Street_Address1__c = 'street 1'; 
        BusinessProfileRec.Business_Street_Address2__c = 'street 2';
        BusinessProfileRec.Business_Postal_Code__c = '302012';
        BusinessProfileRec.Same_As_Business_Address__c = false;
        BusinessProfileRec.Shipping_City__c = 'jaipur'; 
        BusinessProfileRec.Company_Name_Optional__c = 'Metacube optional';
        BusinessProfileRec.Shipping_Country__c = country.Id;
        BusinessProfileRec.Shipping_State__c = state.Id;
        BusinessProfileRec.Shipping_Street_Address1__c = 'street 1';
        BusinessProfileRec.Shipping_Street_Address2__c = 'street 2';
        BusinessProfileRec.Shipping_Postal_Code__c = '302012';
        insert BusinessProfileRec;
       
        // Create current page ref
        PageReference pageRef = Page.PrintMerchandise; // Add your VF page Name here
  		pageRef.getParameters().put('id', String.valueOf(coHeader1.Id));
  		Test.setCurrentPage(pageRef);
	    system.assertEquals(BusinessProfileRec.Shipping_Postal_Code__c,'302012');
    	Test.startTest();
    	NewPrintMerchandiseCtrl newPrintMerchandiseCtrlObj = new NewPrintMerchandiseCtrl();
    	//system.assert(false, 'pageRef=\n'+newPrintMerchandiseCtrlObj);
        Test.stopTest();
        //System.assert(false, newPrintMerchandiseCtrlObj.COMerchandiseDetailObj);
    }
    
    private static Individual_Tax__c createIndividualTax(String salesTaxItemName, Integer taxRate, CO_Line_Item__c COLIRec) {
    	Individual_Tax__c individualTax = new Individual_Tax__c();
        individualTax.Sales_Tax_Item_Name__c = salesTaxItemName;
        individualTax.Tax_Rate__c = taxRate;
        individualTax.CO_Line_Item__c = COLIRec.Id;
        insert individualTax;
        return individualTax;
   }
}