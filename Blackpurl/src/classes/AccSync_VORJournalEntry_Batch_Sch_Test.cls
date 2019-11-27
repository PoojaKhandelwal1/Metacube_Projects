/**
 * Author: Pooja Khandelwal
 * Since: Jun 5, 2018
 * Name: AccSync_VORJournalEntry_Batch_Sch_Test
 * Description: batch scheduler test Class of Vendor Receiving JournalEntry sync to QuickBooks.
**/
@isTest
public class AccSync_VORJournalEntry_Batch_Sch_Test {
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
        createAndCommitVORHeader();
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
    
    private static testmethod void syncVORsTest() {
        TestUtil.setQuickBooksConfigurations(false);
        List<Vendor_Receiving_Header__c> vrhList= [Select Id, Status__c from Vendor_Receiving_Header__c ];
        Set<Id> setVendorReceivingIds = new Set<Id>();
        for(Vendor_Receiving_Header__c vendorReceiving : vrhList){ 
            if(vendorReceiving.Status__c == 'Stocked')  {
                setVendorReceivingIds.add(vendorReceiving.Id);
            }
        }
        
        Test.startTest();
        if(setVendorReceivingIds.size() > 0) {
            //Sync VOR Hedaer to QB which are having status stocked
            AccSync_VORJournalEntry_Batch_Scheduler vorJESync = new AccSync_VORJournalEntry_Batch_Scheduler(setVendorReceivingIds, 200);
            vorJESync.execute(null);
        }
        Test.stopTest();
        
        List<Vendor_Receiving_Header__c> vorHeaderList = [Select Id, AccountingIdForJournalEntry__c, availForQBJournalEntrySync__c from Vendor_Receiving_Header__c ];
        system.assertEquals('675', vorHeaderList[0].AccountingIdForJournalEntry__c);
    }
}