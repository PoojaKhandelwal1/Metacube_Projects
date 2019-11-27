/**
**/ 
@isTest
private class CustomerOwnerUnitTriggerTest {

    static testMethod void customerOwnerUnitTest() {
    	 Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'Agra', '1111111112', null, null, false, true,'Individual','firstname1', 'lastname', '9999999999', 'BillingStreet');
       	Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        Unit_Model__c unitmodel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        List<Customer_Owned_Unit__c> customerOwnedUnitRecList = new List<Customer_Owned_Unit__c>();
        Customer_Owned_Unit__c customerOwnedUnitRec = TestUtil.createCustomerOwnedUnit(false,customer.id, unitmake.id,unitmodel.id,null,'123');
        customerOwnedUnitRec.Unit_Type__c = 'COU';
        customerOwnedUnitRec.Unit_Id__c = '';
        Customer_Owned_Unit__c customerOwnedUnitStockRec = TestUtil.createCustomerOwnedUnit(false,customer.id, unitmake.id,unitmodel.id,null,'1234');
        customerOwnedUnitStockRec.Unit_Type__c = 'STOCK';
        customerOwnedUnitStockRec.Status__c = 'Available';
        customerOwnedUnitStockRec.Unit_Id__c = '';
    	Customer_Owned_Unit__c customerOwnedUnitStockRec1 = TestUtil.createCustomerOwnedUnit(false,customer.id, unitmake.id,unitmodel.id,null,'1213');
        customerOwnedUnitStockRec1.Unit_Type__c = 'STOCK';
        customerOwnedUnitStockRec1.Status__c = 'Available';
        customerOwnedUnitStockRec1.Unit_Id__c = '';
    	
    	Test.startTest();
        customerOwnedUnitRecList.add(customerOwnedUnitRec);
        customerOwnedUnitRecList.add(customerOwnedUnitStockRec);
        customerOwnedUnitRecList.add(customerOwnedUnitStockRec1);
        insert customerOwnedUnitRecList;
    	Test.stopTest();
    	Customer_Owned_Unit__c customerOwnedUnitRec1 = [Select id,Unit_Id__c,Max_COU_Count__c,Max_Stock_Count__c from Customer_Owned_Unit__c where Unit_Type__c='COU' Limit 1]; 
    	
    	customerOwnedUnitStockRec = [Select id,STOCK_Id__c,Max_COU_Count__c,Max_Stock_Count__c from Customer_Owned_Unit__c where Unit_Type__c='STOCK' ORDER BY CreatedDate ASC Limit 10][0]; 
    	System.assertEquals(customerOwnedUnitRec1.Unit_Id__c,'UNT-00001');
    	System.assertEquals(customerOwnedUnitStockRec.STOCK_Id__c,'SKU-00001');
		
    	customerOwnedUnitStockRec1 = [Select id,STOCK_Id__c,Max_COU_Count__c,Max_Stock_Count__c from Customer_Owned_Unit__c where Unit_Type__c='STOCK' ORDER BY CreatedDate ASC Limit 10][0]; 
    	
    	//System.assertEquals(customerOwnedUnitStockRec1.STOCK_Id__c,'SKU-00002');
		
    }
}