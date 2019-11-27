/**
 * Author: Durga Singh
 * Since: July 22, 2015
 * Name: ViewPartRelatedListCtrlTest
 * Description: test Class for complete part functionality and other alternate/replace parts.
**/
@isTest
private class ViewPartRelatedListCtrlTest {
     
      /**
     * Name: getPaginatedActiveOrdersForPartTest 
     * Desc: Test to fetch active orders for part.
     * @param: 
     * @return: 
    **/

    static testMethod void getPaginatedActiveOrdersForPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Vendor_Order_Header__c VendorOrderHeader =  TestUtil.createVendorOrderHeader(true, vendor.Id);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Vendor_Order_Line_Item__c VendorOrderLineItem = TestUtil.createVendorOrderLineItem(true, vendorOrderHeader.Id, part.Id, 300);
        
        ActiveOrder.RelatedListPaginationSorting pageSort = new ActiveOrder.RelatedListPaginationSorting();
        pageSort.activeOrdersCurrentPage = 1;
        pageSort.activeOrdersPageSize = 10;
        //System.JSON.serialize(part.Id, System.JSON.serialize(pageSort));
        String activeOrders = BPUtility.getDecodedString(ViewPartRelatedListCtrl.getPaginatedActiveOrdersForPart(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        ViewPartRelatedListCtrl.AllActiveOrdersWrapper activeOrdersList = (ViewPartRelatedListCtrl.AllActiveOrdersWrapper) System.JSON.deserialize(activeOrders, ViewPartRelatedListCtrl.AllActiveOrdersWrapper.class);
        system.assertEquals(activeOrdersList.TotalActiveOrders, 0 );
    }
    
          /**
     * Name: getAllAlternatePartsForPartTest 
     * Desc: Test to fetch total number of alternate parts for part.
     * @param: 
     * @return: 
    **/

    static testMethod void getAllAlternatePartsForPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partD = TestUtil.createPart(true, 'partD', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partC.Id, partA.Id, 'Alternate');
        Part_Alternates__c partsAlternate2 = TestUtil.createPartAlternates(true, partD.Id, partA.Id, 'Replaces');
        

        Integer alternatePartNumbers = ViewPartRelatedListCtrl.getTotalAlternatePartsForPart(BPUtility.getEncodedString(partA.Id));
        system.assertEquals(alternatePartNumbers, 3 );
     }
    
          /**
     * Name: getPaginatedAlternatePartsForPartTest 
     * Desc: Test to fetch alternate parts for part.
     * @param: 
     * @return: 
    **/

    static testMethod void getPaginatedAlternatePartsForPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        //System.JSON.serialize(partA.Id, System.JSON.serialize(pageSort));
        String alternateParts = BPUtility.getDecodedString(ViewPartRelatedListCtrl.getPaginatedAlternatePartsForPart(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort) )));
        ViewPartRelatedListCtrl.AllAlternatePartsWrapper alternatePartsList = (ViewPartRelatedListCtrl.AllAlternatePartsWrapper) System.JSON.deserialize(alternateParts, ViewPartRelatedListCtrl.AllAlternatePartsWrapper.class);
        system.assertEquals(alternatePartsList.TotalAlternateParts, 1);
    }
    
          /**
     * Name: addAlternatePartToPartTest 
     * Desc: Test to add alternate part for a part.
     * @param: 
     * @return: 
    **/

    static testMethod void addAlternatePartToPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
       // Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartsAdded = BPUtility.getDecodedString(ViewPartRelatedListCtrl.addAlternatePartToPart(BPUtility.getEncodedString('[{"AlternatePartId":"'+partB.Id+'","Relation":"Alternate","PartId":"'+partA.Id+'"}]')));
        
        List<AlternatePart.AlternatePartWrapper> alternatePartsList = (List<AlternatePart.AlternatePartWrapper> ) System.JSON.deserialize(alternatePartsAdded, List<AlternatePart.AlternatePartWrapper> .class);
        system.assertequals(alternatePartsList[0].AlternatePartRecord.AlternatePartNumber, 'partB');
        String alternateParts = BPUtility.getDecodedString(CustomerOrderCtrl.getAlternatePartsList(BPUtility.getEncodedString(partA.Id)));
        List<AlternatePart.AlternatePartWrapper> alternatePartsList1 = (List<AlternatePart.AlternatePartWrapper> ) System.JSON.deserialize(alternateParts, List<AlternatePart.AlternatePartWrapper> .class);
        system.assertEquals(alternatePartsList1.size(), 2 );
    }
    
    
    
          /**
     * Name: addAlternatePartToPartTestA
     * Desc: Test to add alternate part for a part which is already added.
     * @param: 
     * @return: 
    **/

    static testMethod void addAlternatePartToPartTestA() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
       // Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartsAdded = BPUtility.getDecodedString(ViewPartRelatedListCtrl.addAlternatePartToPart(BPUtility.getEncodedString('[{"AlternatePartId":"'+partB.Id+'","Relation":"Alternate","PartId":"'+partA.Id+'"}]')));
        String alternatePartsAdded1 = BPUtility.getDecodedString(ViewPartRelatedListCtrl.addAlternatePartToPart(BPUtility.getEncodedString('[{"AlternatePartId":"'+partB.Id+'","Relation":"Replaces","PartId":"'+partA.Id+'"}]')));
        
        List<AlternatePart.AlternatePartWrapper> alternatePartsList = (List<AlternatePart.AlternatePartWrapper> ) System.JSON.deserialize(alternatePartsAdded1, List<AlternatePart.AlternatePartWrapper> .class);
        //ayushi
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 0);
        //Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        //AlternatePart alternatePartConstructor1 = new AlternatePart(partsAlternate , true);
        //AlternatePart alternatePartConstructor2 = new AlternatePart(partsAlternate , false);
        //ayushi
        //system.assertequals(alternatePartsList[0].ErrorMsg, 'Part is already added as Alternate Part.');
       
        system.assertequals(alternatePartsList[0].ErrorMsg, 'Part is already added as Alternate Part.');
       
    }
    
          /**
     * Name: addAlternatePartToPartTestB for more condition
     * Desc: Test to add alternate part for a part which is replacing same part.
     * @param: 
     * @return: 
    **/

    static testMethod void addAlternatePartToPartTestB() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        //Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Replaces');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartsAdded = BPUtility.getDecodedString(ViewPartRelatedListCtrl.addAlternatePartToPart(BPUtility.getEncodedString('[{"AlternatePartId":"'+partA.Id+'","Relation":"Alternate","PartId":"'+partB.Id+'"}]')));
        //String alternatePartsAdded1 = ViewPartRelatedListCtrl.addAlternatePartToPart('[{"AlternatePartId":"'+partB.Id+'","Relation":"Replaces","PartId":"'+partA.Id+'"}]');
        
        List<AlternatePart.AlternatePartWrapper> alternatePartsList = (List<AlternatePart.AlternatePartWrapper> ) System.JSON.deserialize(alternatePartsAdded, List<AlternatePart.AlternatePartWrapper> .class);
        //system.assert(false,  alternatePartsList);
        system.assertequals(alternatePartsList[0].AlternatePartRecord.AlternatePartNumber, 'partA');
       
    }
    
    //ayushi start
    /**
     * Name: addAlternatePartToPartTest 
     * Desc: Test to add alternate part for a part for case partAlternate.Alternate_Part_ID__r.Qty_On_Order__c > 0.
     * @param: 
     * @return: 
    **/
    static testMethod void addAlternatePartToPartTestC() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 0);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 0);
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartsAdded = BPUtility.getDecodedString(ViewPartRelatedListCtrl.addAlternatePartToPart(BPUtility.getEncodedString('[{"AlternatePartId":"'+partB.Id+'","Relation":"Alternate","PartId":"'+partA.Id+'"}]')));
        List<AlternatePart.AlternatePartWrapper> alternatePartsList = (List<AlternatePart.AlternatePartWrapper> ) System.JSON.deserialize(alternatePartsAdded, List<AlternatePart.AlternatePartWrapper> .class);
        system.assertequals(alternatePartsList[0].AlternatePartRecord.AlternatePartNumber, 'partB');
    }
    //ayushi end
    
              /**
     * Name: updateDefaultAlternatePartTest
     * Desc: Test to update alternate part as a default.
     * @param: 
     * @return: 
    **/

    static testMethod void updateDefaultAlternatePartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partC.Id, partA.Id, 'Alternate');
        //Part_Alternates__c partsAlternate2 = TestUtil.createPartAlternates(true, partA.Id, partA.Id, 'Alternate');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String defaultAlternatePart = BPUtility.getDecodedString(ViewPartRelatedListCtrl.updateDefaultAlternatePart(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(partsAlternate1.Id), true ));
        system.assertEquals(defaultAlternatePart, '2' );
       
    }
    
                  /**
     * Name: updateDefaultAlternatePartTestA
     * Desc: Test to update alternate part as a default where part itself a alternate part.
     * @param: 
     * @return: 
    **/

    static testMethod void updateDefaultAlternatePartTestA() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        //Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partC.Id, partA.Id, 'Alternate');
        //Part_Alternates__c partsAlternate2 = TestUtil.createPartAlternates(true, partA.Id, partA.Id, 'Alternate');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String defaultAlternatePart = BPUtility.getDecodedString(ViewPartRelatedListCtrl.updateDefaultAlternatePart(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(partsAlternate.Id), true ));
        system.assertEquals(defaultAlternatePart, '1' );
       
    }
    
                      /**
     * Name: updateDefaultAlternatePartTestB
     * Desc: Test to update alternate part as a default where alternate part is preferred .
     * @param: 
     * @return: 
    **/

    static testMethod void updateDefaultAlternatePartTestB() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        //Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partA.Id, partB.Id, 'Alternate');
        Part_Alternates__c partReverseAlternate = Testutil.createPartReverseAlternates(true, partB.Id, partA.Id, 'Alternate', true);
        Part_Alternates__c partsAlternate2 = TestUtil.createPartAlternates(false, partC.Id, partA.Id, 'Alternate');
        partsAlternate2.Preferred__c = true ;
        insert partsAlternate2;
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String defaultAlternatePart = BPUtility.getDecodedString(ViewPartRelatedListCtrl.updateDefaultAlternatePart(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(partsAlternate.Id), true ));
        //system.assert(false, defaultAlternatePart);
        system.assertEquals(defaultAlternatePart, '2,' );
       
    }
    
                  /**
     * Name: updateAlternatePartRelationTest
     * Desc: Test to update relation for alternate part  for condition where relation is Replaces.
     * @param: 
     * @return: 
    **/

    static testMethod void updateAlternatePartRelationTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        //Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        //Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        //Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partA.Id, partB.Id, 'Alternate');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartsAdded = BPUtility.getDecodedString(ViewPartRelatedListCtrl.addAlternatePartToPart(BPUtility.getEncodedString('[{"AlternatePartId":"'+partA.Id+'","Relation":"Alternate","PartId":"'+partB.Id+'"}]')));
        String alternatePartRelation = BPUtility.getDecodedString(ViewPartRelatedListCtrl.updateAlternatePartRelation(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(partB.Id), BPUtility.getEncodedString('Replaces' )));
        //ViewPartRelatedListCtrl.AllAlternatePartsWrapper alternatePartsList = (ViewPartRelatedListCtrl.AllAlternatePartsWrapper) System.JSON.deserialize(alternatePartRelation, ViewPartRelatedListCtrl.AllAlternatePartsWrapper.class);
        //system.assert(false, alternatePartRelation );
        //system.assertEquals(alternatePartsList.TotalAlternateParts, null);
        system.assertEquals(true, true);
    }
    
          /**
     * Name: updateAlternatePartRelationTestA
     * Desc: Test to update relation for alternate part.
     * @param: 
     * @return: 
    **/

    static testMethod void updateAlternatePartRelationTestA() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partC.Id, partB.Id, 'Alternate');
        Part_Alternates__c partsAlternate2 = TestUtil.createPartAlternates(true, partA.Id, partB.Id, 'Alternate');
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartRelation = BPUtility.getDecodedString(ViewPartRelatedListCtrl.updateAlternatePartRelation(BPUtility.getEncodedString(partB.Id), BPUtility.getEncodedString(partsAlternate.Id), BPUtility.getEncodedString('Alternate' )));
        //system.assert(false, alternatePartRelation );
        system.assertEquals(alternatePartRelation, '{}' );
       
    }
    
       /**
     * Name: removeAlternatePartRelationTest
     * Desc: Test to remove relation for alternate part.
     * @param: 
     * @return: 
    **/

    static testMethod void removeAlternatePartRelationTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partC.Id, partA.Id, 'Alternate');
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartRelation = BPUtility.getDecodedString(ViewPartRelatedListCtrl.removeAlternatePartRelation(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(partsAlternate.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)) ));
        ViewPartRelatedListCtrl.AllAlternatePartsWrapper alternatePartsList = (ViewPartRelatedListCtrl.AllAlternatePartsWrapper) System.JSON.deserialize(alternatePartRelation, ViewPartRelatedListCtrl.AllAlternatePartsWrapper.class);
        //system.assert(false, alternatePartsList );
        system.assertEquals(alternatePartsList.TotalAlternateParts, 1 );
       
    }
    
     /**
     * Name: getPaginatedTaxExemptionsForPartTest
     * Desc: Test to fetch Tax exemption for part
     * @param: 
     * @return: 
    **/

    static testMethod void getPaginatedTaxExemptionsForPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Part__c part = TestUtil.createPart(true, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Tax__c partTax = Testutil.createPartTax(true, salesTaxItem.Id, part.Id);
        
        TaxExemption.RelatedListPaginationSorting pageSort = new TaxExemption.RelatedListPaginationSorting();
        pageSort.taxExemptionsCurrentPage = 1;
        pageSort.taxExemptionsPageSize = 10;
        //System.JSON.serialize(part.Id, System.JSON.serialize(pageSort));
        String taxExemptions = BPUtility.getDecodedString(ViewPartRelatedListCtrl.getPaginatedTaxExemptionsForPart(BPUtility.getENcodedString(part.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        ViewPartRelatedListCtrl.AllTaxExemptionsWrapper taxExemptionList = (ViewPartRelatedListCtrl.AllTaxExemptionsWrapper) System.JSON.deserialize(taxExemptions, ViewPartRelatedListCtrl.AllTaxExemptionsWrapper.class);
        //system.assert(false, taxExemptionList);
        system.assertNotEquals(taxExemptionList, null);
    }
    
    /**
     * Name: getTotalTaxExemptionsForPartTest
     * Desc: Test to fetch total Tax exemption for part
     * @param: 
     * @return: 
    **/

    static testMethod void getTotalTaxExemptionsForPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax_Item__c salesTaxItem = TestUtil.createSalesTaxItem(true, 'Test Item', 8.0, 'Testing ', true, testCategory.Id);
        Part__c part = TestUtil.createPart(true, 'part', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Tax__c partTax = Testutil.createPartTax(true, salesTaxItem.Id, part.Id);
        
        TaxExemption.RelatedListPaginationSorting pageSort = new TaxExemption.RelatedListPaginationSorting();
        pageSort.taxExemptionsCurrentPage = 1;
        pageSort.taxExemptionsPageSize = 10;
        //System.JSON.serialize(part.Id, System.JSON.serialize(pageSort));
        Integer taxExemptions =ViewPartRelatedListCtrl.getTotalTaxExemptionsForPart(BPUtility.getEncodedString(part.Id));
        //ViewPartRelatedListCtrl.AllTaxExemptionsWrapper taxExemptionList = (ViewPartRelatedListCtrl.AllTaxExemptionsWrapper) System.JSON.deserialize(taxExemptions, ViewPartRelatedListCtrl.AllTaxExemptionsWrapper.class);
        //system.assert(false, taxExemptionList);
        system.assertEquals(taxExemptions, 500 );
    }
    

    
          /**
     * Name: getPaginatedActiveOrdersForPartTest 
     * Desc: Test to fetch active orders for part.
     * @param: 
     * @return: 
    **/

    static testMethod void getPaginatedActiveOrdersForPartTestPositive() {
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Vendor_Order_Header__c VendorOrderHeader =  TestUtil.createVendorOrderHeader(true, vendor.Id);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        ActiveOrder.RelatedListPaginationSorting pageSort = new ActiveOrder.RelatedListPaginationSorting();
        pageSort.activeOrdersCurrentPage = 1;
        pageSort.activeOrdersPageSize = 10;
        //System.JSON.serialize(part.Id, System.JSON.serialize(pageSort));
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;

        String groupLineItems = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String activeOrders = BPUtility.getDecodedString( ViewPartRelatedListCtrl.getPaginatedActiveOrdersForPart(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        ViewPartRelatedListCtrl.AllActiveOrdersWrapper activeOrdersList = (ViewPartRelatedListCtrl.AllActiveOrdersWrapper) System.JSON.deserialize(activeOrders, ViewPartRelatedListCtrl.AllActiveOrdersWrapper.class);
        system.assertEquals(activeOrdersList.TotalActiveOrders, 1 );
    }
    
              /**
     * Name: getPaginatedActiveOrdersForPartTest 
     * Desc: Test to fetch active orders for part.
     * @param: 
     * @return: 
    **/

    static testMethod void getPaginatedActiveOrdersForPartTestNegative() {
        General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Vendor_Order_Header__c VendorOrderHeader =  TestUtil.createVendorOrderHeader(true, vendor.Id);
        Part__c part = TestUtil.createPart(true, '123', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Account customer = TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true, 'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        
        ActiveOrder.RelatedListPaginationSorting pageSort = new ActiveOrder.RelatedListPaginationSorting();
        pageSort.activeOrdersCurrentPage = 1;
        pageSort.activeOrdersPageSize = 10;
        //System.JSON.serialize(part.Id, System.JSON.serialize(pageSort));
        
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;

        String activeOrders = BPUtility.getDecodedString(ViewPartRelatedListCtrl.getPaginatedActiveOrdersForPart(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        ViewPartRelatedListCtrl.AllActiveOrdersWrapper activeOrdersList = (ViewPartRelatedListCtrl.AllActiveOrdersWrapper) System.JSON.deserialize(activeOrders, ViewPartRelatedListCtrl.AllActiveOrdersWrapper.class);
        system.assertEquals(activeOrdersList.TotalActiveOrders, 0 );
    }
    
    // Start: Added by richa 30/01/2017
    static testMethod void changeAlternatePartRelationTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        
        Part__c partC = TestUtil.createPart(true, 'partC', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate1 = TestUtil.createPartAlternates(true, partC.Id, partA.Id, 'Alternate');
        Part_Alternates__c partsAlternate3 = TestUtil.createPartAlternates(true, partA.Id, partB.Id, 'Alternate');
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        AlternatePart.SortAttrs sortAttrs = new AlternatePart.SortAttrs();
        sortAttrs.fieldName = 'Item';
        sortAttrs.sortDirection = 'ASC';
        
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        pageSort.sorting = new List<AlternatePart.SortAttrs> {
            sortAttrs
        };
        String pageSortJson = System.JSON.serialize(pageSort);
        
        String alternateOrderRelation = 'Replaces';
        String alternateOrderRelation1 = 'Replaced By';
        
        String alternatePartJSON = ViewPartRelatedListCtrl.changeAlternatePartRelation(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(partsAlternate.Id), BPUtility.getEncodedString(alternateOrderRelation), BPUtility.getEncodedString(pageSortJson));
        //ViewPartRelatedListCtrl.AllAlternatePartsWrapper alternatePartObj = (ViewPartRelatedListCtrl.AllAlternatePartsWrapper) System.JSON.deserialize(BPUtility.getDecodedString(alternatePartJSON), ViewPartRelatedListCtrl.AllAlternatePartsWrapper.class);
        
        
        String alternatePartJSON1 = ViewPartRelatedListCtrl.changeAlternatePartRelation(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(partsAlternate1.Id), BPUtility.getEncodedString(alternateOrderRelation1), BPUtility.getEncodedString(pageSortJson));
        ViewPartRelatedListCtrl.AllAlternatePartsWrapper alternatePartObj1 = (ViewPartRelatedListCtrl.AllAlternatePartsWrapper) System.JSON.deserialize(BPUtility.getDecodedString(alternatePartJSON1), ViewPartRelatedListCtrl.AllAlternatePartsWrapper.class);
        
        system.assertEquals(2, alternatePartObj1.TotalAlternateParts);
    }
    
    static testMethod void getPaginatedActiveSalesOrdersForPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Part__c partA = TestUtil.createPart(true, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        
        ActiveSalesOrder.RelatedListPaginationSorting pageSort = new ActiveSalesOrder.RelatedListPaginationSorting();
        ActiveSalesOrder.SortAttrs sortAttrs = new ActiveSalesOrder.SortAttrs();
        sortAttrs.fieldName = 'Item';
        sortAttrs.sortDirection = 'ASC';
        
        pageSort.activeSalesOrdersCurrentPage = 1;
        pageSort.activeSalesOrdersPageSize = 10;
        pageSort.sorting = new List<ActiveSalesOrder.SortAttrs> {
            sortAttrs
        };
        String pageSortJson = System.JSON.serialize(pageSort);
        
        
        String PaginatedActiveSalesOrdersJSON = ViewPartRelatedListCtrl.getPaginatedActiveSalesOrdersForPart(BPUtility.getEncodedString(partA.Id), BPUtility.getEncodedString(pageSortJson));
        ViewPartRelatedListCtrl.AllActiveSalesOrdersWrapper PaginatedActiveSalesOrders = (ViewPartRelatedListCtrl.AllActiveSalesOrdersWrapper) System.JSON.deserialize(BPUtility.getDecodedString(PaginatedActiveSalesOrdersJSON), ViewPartRelatedListCtrl.AllActiveSalesOrdersWrapper.class);
         
        system.assertEquals(0, PaginatedActiveSalesOrders.TotalActiveSalesOrders);
    }
    
    static testMethod void setViewPartRelatedListCtrlFieldsTest() {
        Australian_Market__c ausMarket = new Australian_Market__c();
        ausMarket.Sales_Tax_Rate__c = 5;
        insert ausMarket;
        
        General_Configurations__c genConfig = new General_Configurations__c();
        genConfig.Home_Search_Grid_Page_Size__c = 10;
        genConfig.Related_List_Page_Size__c = 10;
        genConfig.Is_Widget_Removeable__c = true;
        genConfig.Load_New_Customer_Order__c = false;
        genConfig.Load_New_UI__c = true;
        genConfig.Load_New_View_Customer__c = false;
        
        insert genConfig;
        
        ViewPartRelatedListCtrl abc = new ViewPartRelatedListCtrl();
         
        system.assertEquals(10, abc.Home_Search_Grid_Page_Size);
        system.assertEquals(10, abc.Related_List_Page_Size);
        system.assertEquals(true, abc.Is_Widget_Removeable);
        system.assertEquals(false, abc.Load_New_Customer_Order);
        system.assertEquals(true, abc.Load_New_UI);
        system.assertEquals(false, abc.Load_New_View_Customer);
        system.assertEquals(5, abc.Sales_Tax_Rate);
    }
    // End: Added by richa 30/01/2017
    
    static testMethod void getPaginatedActiveOrderStatusForPartTest() {
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        //System.JSON.serialize(pageSort)
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true ;
        Part.Package_Qty__c = 22 ;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 100;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;


        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
       
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        List<CO_Header__c> coList = [select Order_Total__c from CO_Header__c];
        //system.assert(false, coList);
        

        String groupLineItems = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        ActiveOrder.RelatedListPaginationSorting pageSort1 = new ActiveOrder.RelatedListPaginationSorting();
        pageSort1.activeOrdersCurrentPage = 1;
        pageSort1.activeOrdersPageSize = 10;
       List<ActiveOrder> activeOrders = ActiveOrder.getAllActiveOrdersForPart(part.Id, System.JSON.serialize(pageSort1));
       system.assertEquals(activeOrders[0].Status, 'On Order' );
       system.assertEquals(activeOrders[0].TotalOrder, 3080.00000);
       List<ActiveOrder> activeOrders1 = ActiveOrder.getAllActiveOrdersForVendor(vendor.Id, System.JSON.serialize(pageSort1));
       //system.assert(false, activeOrders1 );
       system.assertEquals(activeOrders1[0].VoligStatus, 'On Order');
       system.assertEquals(activeOrders1[0].TotalOrder, 3080.00000);
       List<ActiveOrder> activeOrders2 = ActiveOrder.getAllActiveOrdersForCustomer(customer.Id, System.JSON.serialize(pageSort1));
       //system.assert(false, activeOrders2);
        system.assertEquals(activeOrders2[0].VoligStatus, 'On Order');
        system.assertEquals(activeOrders2[0].TotalOrder, 3080.00000);
       
    }
    
 static testMethod void  ActiveVOStatusForPartOnCancelTest () {
     
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        //System.JSON.serialize(pageSort)
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true ;
        Part.Package_Qty__c = 22 ;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 100;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;


        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
       
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
       /* Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        */

        String groupLineItems = BPUtility.getDecodedString(VendorOrderCtrl.addVendor(BPUtility.getEncodedString(vendor.Id),  BPUtility.getEncodedString(null), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        List<Vendor_Order_Header__c> voHeader12 = [select Status__c,    Vendor__c from Vendor_Order_Header__c Limit 100];
        //system.assert(false, voHeader12);
        String similarlineitem = BPUtility.getDecodedString(VendorOrderCtrl.groupAllVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(voHeader12[0].Id), true,  BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        ActiveOrder.RelatedListPaginationSorting pageSort1 = new ActiveOrder.RelatedListPaginationSorting();
        pageSort1.activeOrdersCurrentPage = 1;
        pageSort1.activeOrdersPageSize = 10;
       List<ActiveOrder> activeOrders = ActiveOrder.getAllActiveOrdersForPart(part.Id, System.JSON.serialize(pageSort1));
       system.assertEquals(activeOrders[0].Status, 'Open');
       List<ActiveOrder> activeOrders1 = ActiveOrder.getAllActiveOrdersForVendor(vendor.Id, System.JSON.serialize(pageSort1));
       system.assertEquals(activeOrders1[0].Status, 'Open');
    }
    
    
     static testMethod void getPaginatedActiveOrderStatusForViewscreens() {
    	General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        //System.JSON.serialize(pageSort)
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.Order_Status__c = 'Open';
        insert coHeader;
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true ;
        Part.Package_Qty__c = 22 ;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 100;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;


        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
       
        PO_Type__c POType = TestUtil.createPurchaseOrder(true, 'purchaseOrderCode', vendor.Id, true, 2);
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        voHeader.Purchase_Order_Type__c = POType.Id;
        insert voHeader;
        

        String groupLineItems = BPUtility.getDecodedString(VendorOrderCtrl.groupAllSimilarVOLineItem(BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        String finalizedLineItems = BPUtility.getDecodedString(VendorOrderCtrl.finalizeVendorOrder(BPUtility.getEncodedString(voHeader.Id), BPUtility.getEncodedString(vendor.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort)), BPUtility.getEncodedString(System.JSON.serialize(pageSort))));
        
        VendorOrderLineItemWrapper voLineItems = (VendorOrderLineItemWrapper) System.JSON.deserialize(finalizedLineItems, VendorOrderLineItemWrapper.class);
        ActiveOrder.RelatedListPaginationSorting pageSort1 = new ActiveOrder.RelatedListPaginationSorting();
        pageSort1.activeOrdersCurrentPage = 1;
        pageSort1.activeOrdersPageSize = 10;
        String activeOrders1 =BPUtility.getDecodedString( ViewPartRelatedListCtrl.getPaginatedActiveSalesOrdersForPart(BPUtility.getEncodedString(part.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort1))));
        ViewPartRelatedListCtrl.AllActiveSalesOrdersWrapper activesalesrecord = (ViewPartRelatedListCtrl.AllActiveSalesOrdersWrapper) System.JSON.deserialize(activeOrders1,  ViewPartRelatedListCtrl.AllActiveSalesOrdersWrapper.class);
        system.assertEquals(activesalesrecord.activeSalesOrders[0].TotalOrderValue, 8250 );
       	system.assertEquals(activesalesrecord.activeSalesOrders[0].Status, 'Ordered');
       
       String customerInfo = BPUtility.getDecodedString( NewViewCustomerCtrl.getActiveOrdersListByCustomerId(BPUtility.getEncodedString(customer.Id), BPUtility.getEncodedString(System.JSON.serialize(pageSort1))));
       NewViewCustomerCtrl.ActiveOrderJSONWrapper activesalesrecord2 = (NewViewCustomerCtrl.ActiveOrderJSONWrapper) System.JSON.deserialize(customerInfo,  NewViewCustomerCtrl.ActiveOrderJSONWrapper.class);
       //system.assert(false, )
       system.assertEquals(activesalesrecord2.ActiveSalesOrderList[0].TotalOrderValue, 8250 );
       system.assertEquals(activesalesrecord2.ActiveSalesOrderList[0].Status, 'Open' );
       
       
       List<ActiveOrder> activeOrders2 = ActiveOrder.getAllActiveOrdersForCustomer(customer.Id, System.JSON.serialize(pageSort1));
       //system.assert(false, activeOrders2);
       	system.assertEquals(activeOrders2[0].VoligStatus, 'On Order');
      	system.assertEquals(activeOrders2[0].TotalOrder, 3080.00000);
       
    }
    
   static testMethod void partPricesControlByVendorTest() {
    	General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        //System.JSON.serialize(pageSort)
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.Order_Status__c = 'Open';
        insert coHeader;
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true ;
        Part.Package_Qty__c = 22 ;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 100;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;
		Test.starttest();
		vendor.Retail_Base_Value__c = 'MSRP';
		Vendor.Retail_Rate__c = 10;
		vendor.Retail_Rounding__c =  true ;
		vendor.Retail_Round_To__c = 95;
		vendor.Is_Calculate_Part_Retail_Price__c = true;
        update vendor ;
        Test.stoptest();
        
        List<Part__c> partList = [select Id, Retail_Price__c, MSRP__c, Average_Cost__c, Last_Cost__c from Part__c where Id = :part.id ];
        system.assertEquals(partList[0].MSRP__c, 50);
        System.assertEquals(partList[0].Retail_Price__c, 55.95);
        
 
        
    }
    
       static testMethod void partPricesControlByVendorTestA() {
    	General_Configurations__c genConfig = Testutil.createGeneralConfig(10, true);
        VendorPaginationSorting pageSort = new VendorPaginationSorting();
        pageSort.ChangesCount = 0;
        pageSort.CurrentPage = 1;  
        pageSort.PageSize =  10;
        //System.JSON.serialize(pageSort)
        
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', null, null, false, true,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(false, customer.Id);
        coHeader.Order_Status__c = 'Open';
        insert coHeader;
        Part__c part = TestUtil.createPart(false, 'partNumberP01', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part.Packaged_Part__c = true ;
        Part.Package_Qty__c = 22 ;
        Part.Auto_reorder_Min__c = 0;
        part.Auto_reorder_Max__c = 100;
        part.Order_Lots__c = 1;
        //part.Qty_On_Order__c = 0;
        insert part;
		Test.starttest();
		vendor.Retail_Base_Value__c = 'Item Cost';
		Vendor.Retail_Rate__c = 10;
		vendor.Retail_Rounding__c =  false ;
		vendor.Retail_Round_To__c = 95;
		vendor.Is_Calculate_Part_Retail_Price__c = true;
        update vendor ;
        Test.stoptest();
        
        List<Part__c> partList = [select Id, Retail_Price__c, MSRP__c, Average_Cost__c, Last_Cost__c from Part__c where Id = :part.id ];
        system.assertEquals(partList[0].Last_Cost__c, 20);
        System.assertEquals(partList[0].Retail_Price__c, 22);
        system.assertEquals(partlist[0].MSRP__c, 50);
    }
    
 static testMethod void supersededPartTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Part__c partA = TestUtil.createPart(false, 'partA', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        partA.Mfg_Part__c ='abc';
        partA.SKU_Number__c = 'xyz';
        insert partA ;
        
        Part__c partB = TestUtil.createPart(true, 'partB', vendor.Id, 'Test Part', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partc = TestUtil.createPart(true, 'abc', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        Part__c partg = TestUtil.createPart(true, 'xyz', vendor.Id, 'Test Part1', testCategory.Id, 10, 20, 50, 100, 100);
        
        Part__c partd = TestUtil.createPart(false, 'partd', vendor.Id, 'Test Part2', testCategory.Id, 10, 20, 50, 100, 100);
        partd.Mfg_Part__c ='abc';
        Insert partd ;
        Part__c parte = TestUtil.createPart(false, 'parte', vendor.Id, 'Test Part3', testCategory.Id, 10, 20, 50, 100, 100);
        parte.SKU_Number__c = 'xyz';
        Insert parte;
        Part__c partf = TestUtil.createPart(true, 'partf', vendor.Id, 'Test Part3', testCategory.Id, 10, 20, 50, 100, 100);
        Part_Alternates__c partsAlternate2 = TestUtil.createPartAlternates(true, partf.Id, partA.Id, 'Replaces');
       // Part_Alternates__c partsAlternate = TestUtil.createPartAlternates(true, partB.Id, partA.Id, 'Alternate');
        
        
        AlternatePart.RelatedListPaginationSorting pageSort = new AlternatePart.RelatedListPaginationSorting();
        pageSort.alternatePartsCurrentPage = 1;
        pageSort.alternatePartsPageSize = 10;
        String alternatePartsAdded = BPUtility.getDecodedString(ViewPartRelatedListCtrl.addAlternatePartToPart(BPUtility.getEncodedString('[{"AlternatePartId":"'+partB.Id+'","Relation":"Alternate","PartId":"'+partA.Id+'"}]')));
        
        List<AlternatePart.AlternatePartWrapper> alternatePartsList = (List<AlternatePart.AlternatePartWrapper> ) System.JSON.deserialize(alternatePartsAdded, List<AlternatePart.AlternatePartWrapper> .class);
        system.assertequals(alternatePartsList[0].AlternatePartRecord.AlternatePartNumber, 'partB');
        String alternateParts = BPUtility.getDecodedString(CustomerOrderCtrl.getAlternatePartsList(BPUtility.getEncodedString(partA.Id)));
        List<PartAlternateWrapper> alternatePartsList1 = (List<PartAlternateWrapper> ) System.JSON.deserialize(alternateParts, List<PartAlternateWrapper> .class);
        system.assertEquals(alternatePartsList1[0].RelationShip, 'Active Part' );
        system.assertEquals(alternatePartsList1[0].ItemDesc, 'partA-Test Part' );
        system.assertEquals(alternatePartsList1[1].RelationShip, 'Replaces' );
        system.assertEquals(alternatePartsList1[1].ItemDesc, 'partf-Test Part3' );
        system.assertEquals(alternatePartsList1[2].RelationShip, 'Alternate' );
        system.assertEquals(alternatePartsList1[2].ItemDesc, 'partB-Test Part' );
        system.assertEquals(alternatePartsList1[3].RelationShip, 'Actual MFG Part#' );
        system.assertEquals(alternatePartsList1[3].ItemDesc, 'abc-Test Part1' );
        system.assertEquals(alternatePartsList1[4].RelationShip, 'Actual SKU #' );
        system.assertEquals(alternatePartsList1[4].ItemDesc, 'xyz-Test Part1' );
        system.assertEquals(alternatePartsList1[5].RelationShip, 'Same MFG Part#' );
        system.assertEquals(alternatePartsList1[5].ItemDesc, 'partd-Test Part2' );
        system.assertEquals(alternatePartsList1[6].RelationShip, 'Same SKU #' );
        system.assertEquals(alternatePartsList1[6].ItemDesc, 'parte-Test Part3' );
    }
    
     public class VendorPaginationSorting {
        
        // Change count
        public Integer ChangesCount;
        
        // Current page number
        public Integer CurrentPage;
        
        // page size
        public Integer PageSize;
        
        // Sorting Attrs
        public List<SortAttrs> Sorting;
    }
      // SortAttrs for sorting attributes
    public class SortAttrs {
        
        // Field name
        public String FieldName;
        
        // Sort direction
        public String SortDirection;
        
        public SortAttrs(String FieldName, String SortDirection){
            this.FieldName = FieldName;
            this.SortDirection = SortDirection;
        }
    }
}