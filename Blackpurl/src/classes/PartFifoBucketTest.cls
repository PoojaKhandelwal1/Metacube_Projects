@isTest
private class PartFifoBucketTest {
    @testSetup
    private static void setupTestData() {
        TestUtil.createNameSpaceInGeneralConfig();
        List<General_Configurations__c> config = [SELECT Id FROM General_Configurations__c LIMIT : SOQLUtil.getAvailableQueryRowsLimit()];
    	System.assertNotEquals(0, config.size());
    }
    static testMethod void PartFIFOBucketTest() {
        Account customer = TestUtil.createCustomer(true, 'testcustomer', 'customer@gmail.com', 'Jaipur', '8058704475');
        Account vendor = TestUtil.createVendor(true, 'testvendor');
        Category__c categoryObject = TestUtil.createCategory(true, 'Test', '    Miscellaneous', 'Test description', true, true);
        Part__c partObject1 = TestUtil.createPart(true, '101', vendor.id, 'test1', categoryObject.id, 200, 200, 100, 20, 20);
        Part__c partObject2 = TestUtil.createPart(true, '102', vendor.id, 'test2', categoryObject.id, 201, 200, 100, 20, 20);
        Part__c partObject3 = TestUtil.createPart(true, '103', vendor.id, 'test3', categoryObject.id, 202, 100, 10, 2, 2);
        List<Part__c> partList = new List<Part__c> ();
        partList.add(partObject1);
        partList.add(partObject2);
        partList.add(partObject3);
        List<String> partidList = new List<String>{partObject1.id,partObject2.id,partObject3.id};
        List<Part_FIFO_Bucket__c> partFIFOBucketList=[Select id,Remaining_Qty__c,CreatedDate,Is_FIFO_Bucket__c,Customer_Return__c,Cost__c,Vendor_Receiving_Header__c,Total__c,Type__c,Part__r.Part_Number__c,Qty_In__c,Qty_Out__c,Vendor_Invoicing_Header__r.Vendor__c,Vendor_Invoicing_Header__r.Vendor__r.Name,Vendor_Invoicing_Header__c,Source_Name__c from Part_FIFO_Bucket__c  where Part__c in :partidList];
        PartFifoBucket fifobucket = new PartFifoBucket(partFIFOBucketList.get(0));
        PartFifoBucket.getPartFIFOBucketList();
        PartFifoBucket.getPartFIFOBucketLineItemList();
        CO_Header__c coheaderobject =  TestUtil.createCOHeader(true, customer.id);
        CO_Invoice_Header__c  coInvoiceHeaderObject = TestUtil.createCOInvoiceHeader(true, coheaderobject.id, 'Stocked');
        
        /*Part_FIFO_Bucket_Activity_Line_Item__c partActivityLineitem = new Part_FIFO_Bucket_Activity_Line_Item__c();
        partActivityLineitem.CO_Invoice_Header__c = coInvoiceHeaderObject.id;
        CO_Line_Item__c coLineItem = createCOLineItem
        partActivityLineitem.Part_Adjustment__c=partObject1.id;
        partActivityLineitem.Part_FIFO_Bucket__c = partObject1.id;
        partActivityLineitem.Qty_Out__c = 20;
        */
        System.assertEquals(true,true); 
        //Added by Nidhi - 20-0-2016
        partFIFOBucketList[0].Source_Name__c = 'Oversold';
        partFIFOBucketList[0].Part__c = partObject1.Id;
        update partFIFOBucketList[0];
        
        partList = [Select Oversold_Qty__c, Oversold_Cost__c, (Select id, Qty_In__c, Qty_Out__c, Total__c from Part_FIFO_Buckets__r) from Part__c where Id = :partObject1.Id];
        for(Part__c partRec : partList) {
			Decimal oversoldQty = 0;
			Decimal oversoldCost = 0;
			for(Part_FIFO_Bucket__c partFIFOBucketRec : partRec.Part_FIFO_Buckets__r) {
				oversoldQty += ((partFIFOBucketRec.Qty_In__c != null) ? partFIFOBucketRec.Qty_In__c : 0.00) - ((partFIFOBucketRec.Qty_Out__c != null) ? partFIFOBucketRec.Qty_Out__c : 0.00);
				oversoldCost += (partFIFOBucketRec.Total__c != null) ? partFIFOBucketRec.Total__c : 0.00;
			}
			system.assertEquals(oversoldQty, partRec.Oversold_Qty__c);
			system.assertEquals(oversoldCost, partRec.Oversold_Cost__c);
		}
    }
}