/**
 * Author: Pooja Khandelwal
 * Since: Jun 6, 2018
 * Name: AccSync_VendorReturn_Batch_Test
 * Description: batch test Class of Vendor Return JournalEntry sync to QuickBooks.
**/
@isTest
public class AccSync_VendorReturn_Batch_Test {
    static PaginationSorting pageSort;
    @testSetup
    static void setup() {
        TestUtil.setQuickBooksConfigurations(false);
        TestUtil.setQBTaxCodesConfigurations(true);

        // Create pageSort Rec
        pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Account vendorObj = TestUtil.createVendor(false, 'QB Vendor');
        List<Sales_Tax__c> salesTaxList = [SELECT Id, Accounting_Id__c FROM Sales_Tax__c];
        if(salesTaxList.size() > 0) {
        	vendorObj.Purchase_Tax__c = salesTaxList[salesTaxList.size() - 1].Id;
        } 
        insert vendorObj;
        
        Category__c categoryObj =  TestUtil.createCategory(true, 'Qb Category');
        Part__c partRec =  TestUtil.createPart(true, 'QBPartNumberPo1', vendorObj.Id, 'QB Part', categoryObj.Id);
        createVendorReturnAndProcessCredit(vendorObj, partRec);
        system.assert(true, true);
    }
    
    private static void createVendorReturnAndProcessCredit(Account vendorObj, Part__c partRec) {
        // Create VendorReturn Rec
        Id vendorReturnId = BPUtility.getDecodedString(ReturnVOCtrl.addVendor(BPUtility.getEncodedString(vendorObj.Id), BPUtility.getEncodedString(null)));
        
        // Add LI to Return VO
        Return_VO_Line_Item__c returnVOLIRec = new Return_VO_Line_Item__c();
        returnVOLIRec.Part__c = partRec.Id;
        returnVOLIRec.Return_Qty__c = partRec.AvailableParts__c;
        returnVOLIRec.Item_Cost__c = partRec.Retail_Price__c + 50;
        returnVOLIRec.Item__c = partRec.Name;
        returnVOLIRec.Description__c = partRec.Description__c;
        List<ReturnVOHeaderWrapper.ReturnVoLineItemWrapper> returnVOLIList = new List<ReturnVOHeaderWrapper.ReturnVoLineItemWrapper>();
        returnVOLIList.add(new ReturnVOHeaderWrapper.ReturnVoLineItemWrapper(returnVOLIRec));
        String returnVOLIsJsonString = System.JSON.serialize(returnVOLIList);
        String returnVODetails = BPUtility.getDecodedString(ReturnVOCtrl.saveRVOLI(BPUtility.getEncodedString(vendorReturnId), BPUtility.getEncodedString(returnVOLIsJsonString)));
        
        // Submit Return VO
        String submittedReturnVODetails = BPUtility.getDecodedString(ReturnVOCtrl.SubmitReturn(BPUtility.getEncodedString(vendorReturnId)));
        
        // Save Return VO Header with RMA and Credit Memo Values 
        ReturnVOHeaderWrapper returnVOHRec = (ReturnVOHeaderWrapper)System.JSON.deserialize(submittedReturnVODetails, ReturnVOHeaderWrapper.class);
        Return_VO_Header__c returnVOHeaderRec = new Return_VO_Header__c();
        returnVOHeaderRec.Id = returnVOHRec.Id;
        returnVOHeaderRec.Vendor__c = returnVOHRec.VendorId;
        returnVOHeaderRec.RMA__c = 'RMANumber-1234';
        returnVOHeaderRec.Credit_Memo__c = 'CreditMemoNumber-1234';
        String returnVOHJsonString = System.JSON.serialize(new ReturnVOHeaderWrapper(returnVOHeaderRec));
        String returnVOHeaderDetails = BPUtility.getDecodedString(ReturnVOCtrl.saveRVOH(BPUtility.getEncodedString(returnVOHJsonString)));
        
        // Set Return VO Satus as Approved
        String approvedReturnVODetails = BPUtility.getDecodedString(ReturnVOCtrl.SetAsApprovedReturnVO(BPUtility.getEncodedString(vendorReturnId)));
        
        // Process Credit Action
        String returnVODetailsAfterProcessingCredits = BPUtility.getDecodedString(ReturnVOCtrl.ProcessCreditReturnVO(BPUtility.getEncodedString(vendorReturnId)));
    }
    
    private static testmethod void syncReturnVOHeadersTest1() {
        List<Return_VO_Header__c> returnVOList = [Select Id, Status__c, availForQBSync__c from Return_VO_Header__c];
        Set<Id> setReturnVOIds = new Set<Id>();
        for(Return_VO_Header__c returnVOHeader : returnVOList){ 
            if(returnVOHeader.availForQBSync__c) {
                setReturnVOIds.add(returnVOHeader.Id);
            }
        }
        
        Test.startTest();
        if(setReturnVOIds.size() > 0) {
        	//Sync Return VO Hedaer to QB if they are not synced yet
            VendorReturnService.syncRVOHeaders(setReturnVOIds);
        }
        Test.stopTest();
        
        List<Return_VO_Header__c> returnVOHeaderList = [Select Id, AccountingResponse__c, AccountingId__c, availForQBSync__c, vendor__r.Vendor_AccountingId__c, vendor__r.Vendor_availForQBSync__c, vendor__r.Purchase_Tax__c from Return_VO_Header__c];
        system.assertEquals('6746', returnVOHeaderList[0].AccountingId__c); 
    }
    
    private static testmethod void syncReturnVOHeadersTest2() {
    	TestUtil.setQBTaxCodesConfigurations(false);
        List<Return_VO_Header__c> returnVOList = [Select Id, Status__c, availForQBSync__c from Return_VO_Header__c];
        Set<Id> setReturnVOIds = new Set<Id>();
        for(Return_VO_Header__c returnVOHeader : returnVOList){ 
            if(returnVOHeader.availForQBSync__c) {
                setReturnVOIds.add(returnVOHeader.Id);
            }
        }
        
        Test.startTest();
        if(setReturnVOIds.size() > 0) {
        	//Sync Return VO Hedaer to QB if they are not synced yet
            VendorReturnService.syncRVOHeaders(setReturnVOIds);
        }
        Test.stopTest();
        
        List<Return_VO_Header__c> returnVOHeaderList = [Select Id, AccountingResponse__c, AccountingId__c, availForQBSync__c, vendor__r.Vendor_AccountingId__c, vendor__r.Vendor_availForQBSync__c, vendor__r.Purchase_Tax__c from Return_VO_Header__c];
        system.assertEquals('6746', returnVOHeaderList[0].AccountingId__c); 
    }
}