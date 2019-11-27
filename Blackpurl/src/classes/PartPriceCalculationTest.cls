@isTest
private class PartPriceCalculationTest {
    @testsetup
    private static void setup(){
    	Category__c categoryRec = TestDataFactory.createCategory('Test Category');
        Account Customer = TestDataFactory.createCustomer('Test Name', 'Individual', 'Fname', 'Lname');
    	CO_Header__c coHeader = TestDataFactory.createCOHeader(customer.Id);
        Fee__c fee = TestDataFactory.createFee(True, categoryRec.Id, 'FeeCode', coHeader.Id, 'Description', 100, true);
        CO_Line_Item__c coLineItemRec1 = new CO_Line_Item__c();
        coLineItemRec1.CO_Header__c = coHeader.Id;
        coLineItemRec1.Fee__c = fee.Id;
        insert coLineItemRec1;
        
		CO_Line_Item__c coLineItemRec2 = new CO_Line_Item__c();
        coLineItemRec2.CO_Header__c = coHeader.Id;
        coLineItemRec2.Fee__c = fee.Id;
        insert coLineItemRec2;        
        Price_Level__c priceLevel = TestDataFactory.createPriceLevel('Test Price Level');
        
		Account vendor = TestDataFactory.createVendor('Test Vendor');
		Part__c part = TestDataFactory.createPart(vendor.Id,  10, 20, 50, 100, 100, categoryRec.Id); 
		
    }
    
    @isTest
    private static void testPartPriceCalculationForAverageCost(){
    	Test.startTest();
    	Part__c part = [SELECT Average_Cost__c FROM Part__c LIMIT 1];
    	part.Average_Cost__c = 10;
    	update part;
    	Price_Level__c priceLevel = [SELECT Part_Price_Base__c, Discount_Markup__c FROM Price_Level__c LIMIT 1];
    	priceLevel.Part_Price_Base__c = 'Average Cost';
    	priceLevel.Discount_Markup__c = 20;
    	update priceLevel;
    	List<CO_Line_Item__c> coLineItemRec = new List<CO_Line_Item__c>([SELECT Id, Retail__c, Price__c FROM CO_Line_Item__c]);
    	Map<Id, Sobject> colineItemIdToPartRecordMap = new Map<Id, Sobject>();
    	colineItemIdToPartRecordMap.put(coLineItemRec[0].Id, part);
    	colineItemIdToPartRecordMap.put(coLineItemRec[1].Id, part);
    	PartPriceCalculation.onPriceLevelAssignment(priceLevel.Part_Price_Base__c, priceLevel.Discount_Markup__c, coLineItemRec, colineItemIdToPartRecordMap);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPartPriceCalculationForPrice(){
    	Test.startTest();
    	Part__c part = [SELECT Retail_Price__c FROM Part__c LIMIT 1];
    	part.Retail_Price__c = 10;
    	update part;
    	Price_Level__c priceLevel = [SELECT Part_Price_Base__c, Discount_Markup__c FROM Price_Level__c LIMIT 1];
    	priceLevel.Part_Price_Base__c = 'Price';
    	priceLevel.Discount_Markup__c = 20;
    	update priceLevel;
    	List<CO_Line_Item__c> coLineItemRec = new List<CO_Line_Item__c>([SELECT Id, Retail__c, Price__c FROM CO_Line_Item__c]);
    	Map<Id, Sobject> colineItemIdToPartRecordMap = new Map<Id, Sobject>();
    	colineItemIdToPartRecordMap.put(coLineItemRec[0].Id, part);
    	colineItemIdToPartRecordMap.put(coLineItemRec[1].Id, part);
    	PartPriceCalculation.onPriceLevelAssignment(priceLevel.Part_Price_Base__c, priceLevel.Discount_Markup__c, coLineItemRec, colineItemIdToPartRecordMap);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPartPriceCalculationForMSRP(){
    	Test.startTest();
    	Part__c part = [SELECT MSRP__c FROM Part__c LIMIT 1];
    	part.MSRP__c = 10;
    	update part;
    	Price_Level__c priceLevel = [SELECT Part_Price_Base__c, Discount_Markup__c FROM Price_Level__c LIMIT 1];
    	priceLevel.Part_Price_Base__c = 'MSRP';
    	priceLevel.Discount_Markup__c = 20;
    	update priceLevel;
    	List<CO_Line_Item__c> coLineItemRec = new List<CO_Line_Item__c>([SELECT Id, Retail__c, Price__c FROM CO_Line_Item__c]);
    	Map<Id, Sobject> colineItemIdToPartRecordMap = new Map<Id, Sobject>();
    	colineItemIdToPartRecordMap.put(coLineItemRec[0].Id, part);
    	colineItemIdToPartRecordMap.put(coLineItemRec[1].Id, part);
    	PartPriceCalculation.onPriceLevelAssignment(priceLevel.Part_Price_Base__c, priceLevel.Discount_Markup__c, coLineItemRec, colineItemIdToPartRecordMap);
    	Test.stopTest();
    }
    
    @isTest
    private static void testPartPriceCalculationForCost(){
    	Test.startTest();
    	Part__c part = [SELECT Last_Cost__c FROM Part__c LIMIT 1];
    	part.Last_Cost__c = 10;
    	update part;
    	Price_Level__c priceLevel = [SELECT Part_Price_Base__c, Discount_Markup__c FROM Price_Level__c LIMIT 1];
    	priceLevel.Part_Price_Base__c = 'Cost';
    	priceLevel.Discount_Markup__c = 20;
    	update priceLevel;
    	List<CO_Line_Item__c> coLineItemRec = new List<CO_Line_Item__c>([SELECT Id, Retail__c, Price__c FROM CO_Line_Item__c]);
    	Map<Id, Sobject> colineItemIdToPartRecordMap = new Map<Id, Sobject>();
    	colineItemIdToPartRecordMap.put(coLineItemRec[0].Id, part);
    	colineItemIdToPartRecordMap.put(coLineItemRec[1].Id, part);
    	PartPriceCalculation.onPriceLevelAssignment(priceLevel.Part_Price_Base__c, priceLevel.Discount_Markup__c, coLineItemRec, colineItemIdToPartRecordMap);
    	Test.stopTest();
    }
}