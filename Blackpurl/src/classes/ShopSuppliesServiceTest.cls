@isTest 
public class ShopSuppliesServiceTest {
	
	@testSetup
    private static void setupTestData() {
    	List<Account> customerList = new List<Account>();
    	for(Integer i = 0; i < 5; i++) {
    		customerList.add(TestDataFactory.sampleCustomer('Test Customer' + i, 'Individual', 'Test', 'Customer' + i));
    	}
    	insert customerList;
    	
    	List<CO_Header__c> coHeaderList = new List<CO_Header__c>();
        for(Integer i = 0; i < 5; i++) {
    		coHeaderList.add(TestDataFactory.sampleCoHeader(customerList[i].Id));
    	}
    	insert coHeaderList;
    	
    	List<Service_Order_Header__c> serviceOrderList = new List<Service_Order_Header__c>();
		for(Integer i = 0; i < 5; i++) {
    		serviceOrderList.add(TestDataFactory.sampleSOHeader(coHeaderList[i].Id));
    	}
    	insert serviceOrderList; 
    	
    	Category__c categoryRec = TestDataFactory.sampleCategory('Test Category');
    	categoryRec.Type__c = 'Labour';
    	insert categoryRec;
    	
    	Labour_Code__c labourCodeRec = TestDataFactory.sampleLabourCode(categoryRec.Id, 'Test code', coHeaderList[0].Id, true, 2, 'Test code name', 2, true);
    	labourCodeRec.Calculate_Supplies__c = true;
    	insert labourCodeRec;
    }
    
    @isTest
    private static void calculateShopSuppliesTest() {
    	Labour_Code__c labourCodeRec = [SELECT Id, Calculate_Supplies__c FROM Labour_Code__c LIMIT 1];
    	Service_Order_Header__c serviceOrderHeaderRec = [SELECT Id FROM Service_Order_Header__c LIMIT 1];
    	ShopSuppliesService.calculateShopSupplies(labourCodeRec, serviceOrderHeaderRec.Id);
    	
    	serviceOrderHeaderRec = [SELECT Id, (SELECT Id FROM Service_Order_Line_Items__r) FROM Service_Order_Header__c LIMIT 1];
    	List<Service_Order_Line_Item__c> serviceOrderLineItemList = serviceOrderHeaderRec.Service_Order_Line_Items__r;
    	system.assertEquals(0, serviceOrderLineItemList.size());
    }
    
    @isTest
    private static void calculateShopSuppliesWithLabourCodeTest() {
    	Labour_Code__c labourCodeRec = [Select Id, Calculate_Supplies__c from Labour_Code__c LIMIT 1];
    	Service_Order_Header__c serviceOrderHeaderRec = [Select Id, (Select Id from Service_Order_Line_Items__r) from Service_Order_Header__c LIMIT 1];
    	Service_Order_Line_Item__c serviceOrderLineItemRec = TestDataFactory.sampleServiceOrderLineItem(serviceOrderHeaderRec.Id);
    	serviceOrderLineItemRec.Labour_Code__c = labourCodeRec.Id;
    	insert serviceOrderLineItemRec;
    	
    	ShopSuppliesService.calculateShopSupplies(labourCodeRec, serviceOrderHeaderRec.Id);
    	serviceOrderHeaderRec = [Select Id, (Select Id, Kit_Price__c from Service_Order_Line_Items__r) from Service_Order_Header__c LIMIT 1];
    	List<Service_Order_Line_Item__c> serviceOrderLineItemList = serviceOrderHeaderRec.Service_Order_Line_Items__r;
    	system.assertEquals(2.000, serviceOrderLineItemList[0].Kit_Price__c);
    }
    
    @isTest
    private static void calculateShopSuppliesWithSeviceOrderTypeTest() {
    	Labour_Code__c labourCodeRec = [Select Id, Calculate_Supplies__c from Labour_Code__c LIMIT 1];
    	Service_Order_Header__c serviceOrderHeaderRec = [Select Id from Service_Order_Header__c LIMIT 1];
    	serviceOrderHeaderRec.SO_Type__c = 'Internal Service';
    	update serviceOrderHeaderRec;
    	
    	ShopSuppliesService.calculateShopSupplies(labourCodeRec, serviceOrderHeaderRec.Id);
    	serviceOrderHeaderRec = [SELECT Id, (SELECT Id from Service_Order_Line_Items__r) FROM Service_Order_Header__c LIMIT 1];
    	List<Service_Order_Line_Item__c> serviceOrderLineItemList = serviceOrderHeaderRec.Service_Order_Line_Items__r;
    	system.assertEquals(0, serviceOrderLineItemList.size());
    }
    
    @isTest
    private static void calculateShopSuppliesWithTypeTest() {
    	Labour_Code__c labourCodeRec = [Select Id, Calculate_Supplies__c from Labour_Code__c LIMIT 1];
    	Service_Order_Header__c serviceOrderHeaderRec = [Select Id from Service_Order_Header__c LIMIT 1];
    	Service_Order_Line_Item__c serviceOrderLineItemRec = TestDataFactory.sampleServiceOrderLineItem(serviceOrderHeaderRec.Id);
    	serviceOrderLineItemRec.Type__c = 'Shop Supply';
    	insert serviceOrderLineItemRec;
    	
    	ShopSuppliesService.calculateShopSupplies(labourCodeRec, serviceOrderHeaderRec.Id);
    	List<Service_Order_Header__c> serviceOrderHeaderList = [Select Id from Service_Order_Header__c];
    	system.assertEquals(5, serviceOrderHeaderList.size());
    }
}