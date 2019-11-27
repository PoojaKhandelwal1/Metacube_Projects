/**
 * Author: Pooja Khandelwal
 * Since: Jan. 3, 2017
 * Name: AccSync_ItemCategory_Batch_Test
 * Description: Test class for AccSync_ItemCategory_Batch
**/
@isTest
private class  AccSync_ItemCategory_Batch_Test {
    @testSetup
    private static void setup()	{
    	General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
    	genConfig.Enable_QB_Accounting__c = true;
    	update genConfig;
    	
    	QuickBooks_Configurations__c QBConfig = new QuickBooks_Configurations__c(Consumer_Key__c = 'qyprdFawAAiD3SLud6d5RvREaVOoAn',
    					 Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr', OAuth_Token__c = 'qyprdAVMsASHRkSalO3JwbyPdnzistYmRRfJBFbAxL6AOlDj', 
    					 OAuth_Token_Secret__c = 'TN3csfs1tTSX77SW5ysYkcVxJo1gIq8Lq3wusQKO', Company_Id__c = '123145730762509', 
    					 End_Point_URL__c ='https://sandbox-quickbooks.api.intuit.com/v3/company/', Enable_QuickBooks__c = true);
        
        insert QBConfig;
        system.assert(true,true);
    }
    
    private static testmethod void syncItemCategoriesToQBTest()	{
    	Test.startTest();
    	Category__c categoryObj =  TestUtil.createCategory(true, 'Qb Category');
    	categoryObj.Income_GL__c = '101';
    	update categoryObj;
    	
        Test.stopTest();
        String res = '{"Item":{"Name":"Category Unique1 [Labour]","Description":"Category Unique1","Active":true,"FullyQualifiedName":"Category Unique1 [Labour]","Taxable":false,"UnitPrice":0,"Type":"Service","IncomeAccountRef":{"value":"79","name":"Sales of Product Income"},"PurchaseCost":0,"ExpenseAccountRef":{"value":"80","name":"Cost of Goods Sold"},"TrackQtyOnHand":false,"domain":"QBO","sparse":false,"Id":"82","SyncToken":"2","MetaData":{"CreateTime":"2016-12-26T04:12:34-08:00","LastUpdatedTime":"2016-12-26T04:13:17-08:00"}},"time":"2016-12-26T04:13:17.367-08:00"}';
        List<Category__c> categoryRec = [Select Id, AccountingResponse__c, AccountingId__c From Category__c];
        system.assertEquals(categoryRec[0].AccountingResponse__c.contains(res), true); 
    }
}