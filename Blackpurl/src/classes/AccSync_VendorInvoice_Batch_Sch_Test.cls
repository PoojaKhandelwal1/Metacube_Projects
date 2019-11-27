/**
 * Author: Pooja Khandelwal
 * Since: Jun 6, 2018
 * Name: AccSync_VendorInvoice_Batch_Sch_Test
 * Description: batch scheduler test Class of Vendor Invoicing (Bill) sync to QuickBooks.
**/
@isTest
public class AccSync_VendorInvoice_Batch_Sch_Test {
    static PaginationSorting pageSort;
    @testSetup
    static void setup() {
        TestUtil.setQuickBooksConfigurations(true);
        
        // Create pageSort Rec
        pageSort = new PaginationSorting();
        pageSort.CurrentPage = 1;
        pageSort.PageSize = 10;
        pageSort.Sorting = new List < PaginationSorting.SortAttrs > {
            new PaginationSorting.SortAttrs('Item', 'ASC')
        };
        
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'QB Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'QB Test Sales Tax', true, true, true);
        Account vendorObj = TestUtil.createVendor(true, 'QB Vendor');
        Account customer =  TestUtil.createCustomer(true, 'QB Customer', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        Category__c categoryObj =  TestUtil.createCategory(true, 'Qb Category');
        Part__c partRec =  TestUtil.createPart(true, 'QBPartNumberPo1', vendorObj.Id, 'QB Part', categoryObj.Id);
        
        createCOHeaderRecAndAddLIs(customer, partRec);
        createAndFinalizeVOHeader(vendorObj, partRec);
        createVORAndVIHeaders();
        system.assert(true, true);
    }
    
    private static void createCOHeaderRecAndAddLIs(Account customer, Part__c partRec) {
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, partRec.Id, 150);
    }
    
    private static void createAndFinalizeVOHeader(Account vendorObj, Part__c partRec) {
        Vendor_Order_Header__c VOHeader = TestUtil.createVendorOrderHeader(true, vendorObj.Id);
        
        // groupAllSimilarVOLineItem
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendorObj.Id), BPUtility.getEncodedString(partRec.Id),
                                    BPUtility.getEncodedString(VOHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
                                    BPUtility.getEncodedString(System.JSON.serialize(pageSort)), 
                                    BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
                                    
        // Finalize VendorOrder
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(VOHeader.Id), 
                                        BPUtility.getEncodedString(vendorObj.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)),
                                        BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));                         
    }
    
    @future
    private static void createVORAndVIHeaders() {
    	createAndCommitVORHeader();
    	createAndFinalizeVIHeader();
    }
    
    private static void createAndCommitVORHeader() {
        List<Account> vendorList = [Select Id from Account WHERE Is_Vendor__c = true];
        List<Part__c> partList = [Select Id from Part__c];
        Vendor_Order_Header__c VOHeader = [Select Id from Vendor_Order_Header__c ];
        
        // Create VendorOrderReceivingHeader Rec
        Id vorId = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addVendor(BPUtility.getEncodedString(vendorList[0].Id), BPUtility.getEncodedString(null)));
        
        // Create VOR Line Items and add them to receiving subsection
        String VendorOrderReceiveItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.receiveVendorOrderItems(BPUtility.getEncodedString(VOHeader.Id), BPUtility.getEncodedString(vorId), true));
        String allLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.addAllLineItemsToItemSubsection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(VOHeader.Id), BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving vendorOrderReceivingRec = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(allLineItems, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        String UpdatedItemsSubsection = BPUtility.getDecodedString(VendorOrderReceivingCtrl.updateItemsSection(BPUtility.getEncodedString(vorId), BPUtility.getEncodedString(partList[0].id), BPUtility.getEncodedString(vendorOrderReceivingRec.VORGroupList[0].Id), 10, 8000, BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        VendorOrderReceivingCtrl.VendorOrderReceiving voLineReceiveItems = (VendorOrderReceivingCtrl.VendorOrderReceiving)System.JSON.deserialize(UpdatedItemsSubsection, VendorOrderReceivingCtrl.VendorOrderReceiving.class);
        
        // Commit Vendor Receiving action
        String commitLineItems = BPUtility.getDecodedString(VendorOrderReceivingCtrl.commitRecevingAction(BPUtility.getEncodedString(vorId)));
    }
    
    private static void createAndFinalizeVIHeader() {
    	List<Account> vendorList = [Select Id from Account WHERE Is_Vendor__c = true];
        List<Vendor_Receiving_Header__c> VORHeader = [Select Id, Vendor__r.Name From Vendor_Receiving_Header__c Where vendor__r.Id =: vendorList[0].Id];
        
        // Create VendorOrderInvoicinHeader Rec and vendor to it
        Vendor_Invoicing_Header__c VIHeader = TestUtil.createVendorInvoiceHeader(true, vendorList[0].Id, 'In Progress');
        String vendorInvoices = BPUtility.getDecodedString(VendorInvoicingCtrl.addVendor(BPUtility.getEncodedString(vendorList[0].Id), BPUtility.getEncodedString(VIHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        // add receiving items to subsection
        String addedVendorInvoice = BPUtility.getDecodedString(VendorInvoicingCtrl.addToItemsSubsection(BPUtility.getEncodedString(VIHeader.Id), BPUtility.getEncodedString(VORHeader[0].Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        // Update VIGroup List Records
        List<Vendor_Invoicing_Group__c> VIGList = [select Id, VI_Cost__c from Vendor_Invoicing_Group__c where Vendor_Invoicing_Header__c =: VIHeader.Id];
        VIGList[0].VI_Cost__c = 10000;
        update VIGList;
        
        // Finalize Vendor Invoice
        String finalaizedInvoice = VendorInvoicingCtrl.finalizeInvoiceAction(BPUtility.getEncodedString(VIHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)));
    }
    
    private static testmethod void syncVIHeadersTest() {
        TestUtil.setQuickBooksConfigurations(false);
        List<Vendor_Invoicing_Header__c> viHeaderList = [Select Id, Status__c from Vendor_Invoicing_Header__c];
        Set<Id> setVendorInvoiceIds = new Set<Id>();
        for(Vendor_Invoicing_Header__c vendorInvoice : viHeaderList){ 
            if(vendorInvoice.Status__c == 'Invoiced')   {
                setVendorInvoiceIds.add(vendorInvoice.Id);
            }
        }
        
        Test.startTest();
        if(setVendorInvoiceIds.size() > 0) {
        	//Sync VI Hedaer to QB which are having status Invoiced
            AccSync_VendorInvoice_Batch_Scheduler viHeaderSync = new AccSync_VendorInvoice_Batch_Scheduler(setVendorInvoiceIds, 10);
            viHeaderSync.execute(null);
        }
        Test.stopTest();
        
        List<Vendor_Invoicing_Header__c> viList = [Select Id, Status__c, Total__c, Invoice_Number__c, AccountingResponse__c, AccountingId__c from Vendor_Invoicing_Header__c];
        system.assertEquals('689', viList[0].AccountingId__c); 
    }
}