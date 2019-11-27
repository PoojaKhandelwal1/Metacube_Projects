/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ReturnVOCtrlTest {
    
    static testMethod void addVendorTest(){
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	insert returnVOHeaderRecord;
      	String vendorRecID = BPUtility.getEncodedString(vendor.id);
      	String returnVOHRecId = BPUtility.getEncodedString(returnVOHeaderRecord.id);
      	test.startTest();
      	String returnVOHRecordObj = ReturnVOCtrl.addVendor(vendorRecID,returnVOHRecId);
      	string newReturnVOId = ReturnVOCtrl.addVendor(null,null);
      	test.stopTest();
      	returnVOHRecordObj = BPUtility.getDecodedString(returnVOHRecordObj);
      	Return_VO_Header__c  returnVOHeaderList = [select id,Vendor__c,status__c from Return_VO_Header__c where id =: returnVOHeaderRecord.id];
      	system.assertEquals('In Progress',returnVOHeaderList.status__c);
      	system.assertEquals(vendor.id,returnVOHeaderList.Vendor__c);
      	newReturnVOId = BPUtility.getDecodedString(newReturnVOId);
      	system.assertNotEquals(returnVOHeaderList.id,newReturnVOId);
    }
    
    static testMethod void getReturnVODetailTest() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        String returnVOHRecId = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        
        test.startTest();
        String returnVOJson = ReturnVOCtrl.getReturnVODetail(returnVOHRecId);
        test.stopTest();
        
        returnVOJson = BPUtility.getDecodedString(returnVOJson);
        returnVoHeaderWrapper RVOHwrapperObj = (returnVoHeaderWrapper)json.deserialize(returnVOJson,returnVoHeaderWrapper.class);
        //system.assert(false,RVOHwrapperObj);
        system.assertEquals(returnVOLIRecord.id,RVOHwrapperObj.ReturnVOLIList[0].id);
        system.assertEquals(part.id,RVOHwrapperObj.ReturnVOLIList[0].PartId);
       	system.assertEquals(vendor.id,RVOHwrapperObj.VendorId);
        
    }
    
    static testMethod void saveRVOLITest() {
    	
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        String returnVOHRecId = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        List<Return_VO_Line_Item__c> RVLI = [select id,Part__c,Return_Qty__c,Return_VO_Header__c from Return_VO_Line_Item__c where id =:returnVOLIRecord.id ];
        String returnVOLIJson = JSON.serialize(RVLI);
       	returnVOLIJson =  BPUtility.getEncodedString(returnVOLIJson);
       	
       	test.startTest();
       	String ReturnVoDetailJson = ReturnVOCtrl.saveRVOLI(returnVOHRecId,returnVOLIJson); 
       	test.stopTest();
       	
       	ReturnVoDetailJson = BPUtility.getDecodedString(ReturnVoDetailJson);
       	returnVoHeaderWrapper RVOHwrapperObj = (returnVoHeaderWrapper)json.deserialize(ReturnVoDetailJson,returnVoHeaderWrapper.class);
       	system.assertEquals(returnVOLIRecord.Return_VO_Header__c ,RVOHwrapperObj.ReturnVOLIList[0].ReturnVOId);
    }
    
    static testMethod void saveRVOHTest() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        String RVOHJson = json.serialize(returnVOHeaderRecord);	
        RVOHJson = BPUtility.getEncodedString(RVOHJson);
        test.startTest();
        String ReturnVoHDetailJson = ReturnVOCtrl.saveRVOH(RVOHJson); 
        test.stopTest();
        ReturnVoHDetailJson = BPUtility.getDecodedString(ReturnVoHDetailJson);
        returnVoHeaderWrapper RVOHwrapperObj = (returnVoHeaderWrapper)json.deserialize(ReturnVoHDetailJson,returnVoHeaderWrapper.class);
        system.assertEquals(returnVOHeaderRecord.Id, RVOHwrapperObj.Id);
    }
    
    static testMethod void  testInsertRLVI() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	test.startTest();
    	
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord; 
        test.stopTest();
        // check part last cost in Item_Cost__c of rvoli
        Part__c partRecord  = [select id,Qty_Committed__c,Last_Cost__c from part__c where Vendor__c =: vendor.id limit 1];
        Return_VO_Line_Item__c ReturnVOLIRecordObj = [select id,Item_Cost__c from Return_VO_Line_Item__c where id =:returnVOLIRecord.id limit 1];
        system.assertEquals(10.00,partRecord.Qty_Committed__c);
        //system.assertEquals(ReturnVOLIRecordObj.Item_Cost__c,partRecord.Last_Cost__c);
        //system.assert(false,ReturnVOLIRecordObj.Item_Cost__c);
    }
    
   	static testMethod void testUpdateRLVI1() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 5;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        
        test.startTest();
        returnVOLIRecord.Return_Qty__c = 8;
        update returnVOLIRecord;
        test.stopTest();
        
        Part__c partRecord  = [select id,Qty_Committed__c,Last_Cost__c from part__c where Vendor__c =: vendor.id];
        Return_VO_Line_Item__c ReturnVOLIRecordObj = [select id,Item_Cost__c from Return_VO_Line_Item__c where id =:returnVOLIRecord.id limit 1];
        system.assertEquals(8.00,partRecord.Qty_Committed__c);
        system.assertNotEquals(5.00,partRecord.Qty_Committed__c);
        //system.assertEquals(ReturnVOLIRecordObj.Item_Cost__c,partRecord.Last_Cost__c);
    }
    
    static testMethod void testUpdateRLVI2() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 50;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
       	test.startTest();
        
        returnVOLIRecord.Return_Qty__c = 100;
        update returnVOLIRecord;
        test.stopTest();
        
        Part__c partRecord  = [select id,Qty_Committed__c,Last_Cost__c from part__c where Vendor__c =: vendor.id];
        Return_VO_Line_Item__c ReturnVOLIRecordObj = [select id,Item_Cost__c from Return_VO_Line_Item__c where id =:returnVOLIRecord.id limit 1];
        system.assertEquals(50.00,partRecord.Qty_Committed__c);
        //system.assertEquals(ReturnVOLIRecordObj.Item_Cost__c,partRecord.Last_Cost__c);
    }
    
    static testMethod void testDeleteRVLI() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 50;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        test.startTest();
        
        returnVOLIRecord.Return_Qty__c = 100;
        delete returnVOLIRecord;
        test.stopTest();
        
        Part__c partRecord  = [select id,Qty_Committed__c,Last_Cost__c from part__c where Vendor__c =: vendor.id];
        system.assertEquals(0.00,partRecord.Qty_Committed__c);
        system.assertNotEquals(100.00,partRecord.Qty_Committed__c);
        
    }
    
    static testMethod void deleteRVOLITest() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        
        String returnVOId  = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        String returnVOLIId= BPUtility.getEncodedString(returnVOLIRecord.id);
        test.startTest();
        String returnVOJson = ReturnVOCtrl.deleteRVOLI(returnVOId, returnVOLIId);
        test.stopTest();
        
        returnVOJson = BPUtility.getDecodedString(returnVOJson);
        List<Return_VO_Line_Item__c> returnVOLIList = [select id from Return_VO_Line_Item__c];
        system.assertEquals(0,returnVOLIList.size());
        
    }
    
    static testMethod void submitReturnTest() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        
        String returnVOId  = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        test.startTest();
        String returnVOJson = ReturnVOCtrl.SubmitReturn(returnVOId);
        test.stopTest();
        
        returnVOJson = BPUtility.getDecodedString(returnVOJson);
        returnVoHeaderWrapper RVOHwrapperObj = (returnVoHeaderWrapper)json.deserialize(returnVOJson,returnVoHeaderWrapper.class);
        system.assertEquals('Submitted',RVOHwrapperObj.Status);
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c];
       	system.assertEquals(partList[0].Qty_In_Stock__c, 50 );
        
       	ActiveOrder.RelatedListPaginationSorting pageSort1 = new ActiveOrder.RelatedListPaginationSorting();
        pageSort1.activeOrdersCurrentPage = 1;
        pageSort1.activeOrdersPageSize = 10;
       	List<ActiveOrder> activeOrders = ActiveOrder.getAllActiveOrdersForPart(part.Id, System.JSON.serialize(pageSort1));
       	 //system.assert(false, activeOrders ) ;
       	 system.assertEquals(activeOrders[0].Status, 'Submitted' );
       	 system.assertEquals(activeOrders[0].qty, -10 );
       	List<ActiveOrder> activeOrders1 = ActiveOrder.getAllActiveOrdersForVendor(vendor.Id, System.JSON.serialize(pageSort1));
       	system.assertEquals(activeOrders1[0].status, 'Submitted');
        
    }
    
    static testMethod void setAsApprovedReturnVOTest() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        
        String returnVOId  = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        test.startTest();
        String returnVOJsonForSubmit = ReturnVOCtrl.SubmitReturn(returnVOId);
        String returnVOJsonForApproved = ReturnVOCtrl.SetAsApprovedReturnVO(returnVOId);
        test.stopTest();
        
        returnVOJsonForApproved = BPUtility.getDecodedString(returnVOJsonForApproved);
        returnVoHeaderWrapper RVOHwrapperObj = (returnVoHeaderWrapper)json.deserialize(returnVOJsonForApproved, returnVoHeaderWrapper.class);
        system.assertEquals('Approved',RVOHwrapperObj.Status);
        List<Part__c> partList = [select Id, Part_Number__c, Qty_Committed__c, Qty_In_Stock__c, Qty_On_Order__c from Part__c];
       	system.assertEquals(partList[0].Qty_In_Stock__c, 40 );
        
       	List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOBucketList=[Select Qty_Out__c, Return_VO_Header__c, Return_VO_Line_Item__c from Part_FIFO_Bucket_Activity_Line_Item__c];
        system.assertEquals(partFIFOBucketList[0].Qty_Out__c, 10);
        //System.assertEquals(6,partFIFOBucketList.size());
        
    }
    
    static testMethod void processCreditReturnVOTest() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        
        String returnVOId  = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        test.startTest();
        String returnVOJsonForSubmit = ReturnVOCtrl.SubmitReturn(returnVOId);
        String returnVOJsonForApproved = ReturnVOCtrl.SetAsApprovedReturnVO(returnVOId);
        String returnVOJsonForProcessCredit = ReturnVOCtrl.ProcessCreditReturnVO(returnVOId);
        
        test.stopTest();
        
        returnVOJsonForProcessCredit = BPUtility.getDecodedString(returnVOJsonForProcessCredit);
        returnVoHeaderWrapper RVOHwrapperObj = (returnVoHeaderWrapper)json.deserialize(returnVOJsonForProcessCredit, returnVoHeaderWrapper.class);
        system.assertEquals('Credited',RVOHwrapperObj.Status);
        
    }
    
    static testMethod void deleteReturnVOLITest() {
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        
        String returnVOId  = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        test.startTest();
        String returnVOJsonForSubmit = ReturnVOCtrl.SubmitReturn(returnVOId);
        String returnVOJsonForDeleteReturn = ReturnVOCtrl.deleteReturnVOLI(returnVOId);
        
        test.stopTest();
        
        String response = BPUtility.getDecodedString(returnVOJsonForDeleteReturn);
        system.assertEquals('Success',response);
        
        ActiveOrder.RelatedListPaginationSorting pageSort1 = new ActiveOrder.RelatedListPaginationSorting();
        pageSort1.activeOrdersCurrentPage = 1;
        pageSort1.activeOrdersPageSize = 10;
       	List<ActiveOrder> activeOrders = ActiveOrder.getAllActiveOrdersForPart(part.Id, System.JSON.serialize(pageSort1));
       system.assertEquals(activeOrders.size(), 0);
        
    }
    
     static testMethod void saveRVOLIWithIncreaseQtyTest() {
    	
    	Account vendor = TestUtil.createVendor(true,null,null,null,null);
    	Part__c part = TestUtil.createPart(true,null,vendor.id,null,null,50,30,55,40,50);
    	Return_VO_Header__c  returnVOHeaderRecord = new Return_VO_Header__c();
       	returnVOHeaderRecord.RMA__c = 'Test';
      	returnVOHeaderRecord.Credit_Memo__c = 'test';
      	returnVOHeaderRecord.Vendor__c = vendor.id;
        insert returnVOHeaderRecord;
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecord.Id;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = part.id;
        insert returnVOLIRecord;
        String returnVOHRecId = BPUtility.getEncodedString(returnVOHeaderRecord.id);
        
        List<Return_VO_Line_Item__c> RVLI = [select id,Part__c,Return_Qty__c,Return_VO_Header__c from Return_VO_Line_Item__c where id =:returnVOLIRecord.id ];
        RVLI[0].Return_Qty__c = 100;
        update RVLI[0];
		
		RVLI = SOQLUtil.getPartActiveReturnOrderForPart(part.Id, null);
        
        ReturnVOHeaderWrapper.ReturnVoLineItemWrapper returnVOLIWrapper = new ReturnVOHeaderWrapper.ReturnVoLineItemWrapper(RVLI[0]);
        List< ReturnVOHeaderWrapper.ReturnVoLineItemWrapper> returnVOLIWrapperList = new List< ReturnVOHeaderWrapper.ReturnVoLineItemWrapper>();
       	returnVOLIWrapperList.add(returnVOLIWrapper);
        String returnVOLIWrapperJson = JSON.serialize(returnVOLIWrapperList);
       	returnVOLIWrapperJson =  BPUtility.getEncodedString(returnVOLIWrapperJson);
       	
       	test.startTest();
       	String ReturnVoDetailJson = ReturnVOCtrl.saveRVOLI(returnVOHRecId,returnVOLIWrapperJson); 
       	test.stopTest();
       	
       	ReturnVoDetailJson = BPUtility.getDecodedString(ReturnVoDetailJson);
       	returnVoHeaderWrapper RVOHwrapperObj = (returnVoHeaderWrapper)json.deserialize(ReturnVoDetailJson, returnVoHeaderWrapper.class);
       	//System.assert(false,RVOHwrapperObj);
       	system.assertEquals(50,RVOHwrapperObj.ReturnVOLIList[0].ReturnQty);
    }
    
}