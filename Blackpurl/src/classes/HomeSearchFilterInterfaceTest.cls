@isTest
private class HomeSearchFilterInterfaceTest {
    
    static testMethod void getFilterListTest() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.id, defaultSalesTax.Id, true, false,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        List<Account> customerList = [select Name, Email__c, Phone, BillingCity, Price_Level__c, Sales_Tax__c , Type__c from Account];
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        
        filterWrapper.Type.objects = new Set<String>{'Vendor Receivings','Sublets','Vendor Invoices','Vendor Orders','Parts','Kits','Fees','Labor Codes', 'Customers', 'Customer Orders','Sales Taxes', 'Users', 'Vendors','User', 'Customer Payments','Customer Invoices', 'Vendor Ordering','Inventory Unit','Customer Unit','Parts Needed','Service Jobs' };
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('3', UserInfo.getUserId(), null);
        filterWrapper.People_Name = 'Harley';
        filterWrapper.SearchText = 'Test Search Text';
        filterWrapper.Status = 'Active';
        filterWrapper.ModifiedDate = new HomeSearchFilterWrapper.BetweenFilter('2', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('3', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        
        // Customer
        filterWrapper.People_Id = customer.Id;
        filterWrapper.People_Email = 'abc@abc.com';
        filterWrapper.People_Phone = '111' ;
        filterWrapper.People_Country = 'India';
        filterWrapper.People_StateProv = 'Rajasthan';
        filterWrapper.People_BillingCity = 'Jaipur';
        filterWrapper.People_BillingAddress = 'H.N 11';
        filterWrapper.People_PriceLevel = defaultPriceLevel.Id ;
        filterWrapper.People_SalesTax = defaultSalesTax.Id ;
        
        // Vendor
        filterWrapper.Vendor_PurchaseSalesTax = '3';
        
        // Product
        filterWrapper.Product_Item = 'code';
        filterWrapper.Product_Description = 'Description';
        filterWrapper.Product_Category = testCategory.Id;
        filterWrapper.Product_Price = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Product_QtyAvailable = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        // Part
        filterWrapper.Part_Location = 'Test Part Location';
        filterWrapper.Part_Cost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_AverageCost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_InStock = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_Committed = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_OnOrder = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_PackagedPart = '2' ;
        filterWrapper.Part_LastCounted = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Part_LastSold = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Part_LastStocked = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Part_ReorderAt = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_ReorderTo = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_Vendor = 'Test Vendor';
        filterWrapper.Part_NonInventory = '1' ;
        filterWrapper.Part_MfgPart = '101' ;
        filterWrapper.Part_SKUNumber = '1111' ;
        filterWrapper.Part_OversoldCost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Part_OversoldQty = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        // Kits
        filterWrapper.Kit_FixedPrice = '1' ;
        filterWrapper.Kit_ServiceKit = '1' ;
        filterWrapper.Kit_KitPrice = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        // Customer Sales
        filterWrapper.Customer_Sales_Id = 'Customer Sales Id';
        filterWrapper.Customer_Sales_Customer = 'customerName';
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        // Customer Orders
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('5', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('5', '-5', '15');
        filterWrapper.Customer_Order_Status = 'In Progress';
        filterWrapper.Customer_Order_Deal_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        // Customer Invoices
        filterWrapper.CO_Invoice_Header_Customer_Order = 'CO Invoice Header Customer Order' ;
        filterWrapper.CO_Invoice_Header_Part_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.CO_Invoice_Header_Labour_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.CO_Invoice_Header_Fee_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.CO_Invoice_Header_Sublet_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.CO_Invoice_Header_Unit_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.CO_Invoice_Header_SalesTax_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        // Customer Payments
        filterWrapper.CO_Payment_Customer_Order = 'Payment Customer Order';
        filterWrapper.CO_Payment_Payment_Method = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        //Vendor Ordering - Group
        filterWrapper.Vendor_Ordering_Id = 'Vendor Id' ;
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        //Vendor Order
        filterWrapper.Vendor_Order_Purchase_Order = 'Vendor Purchase Order';
        filterWrapper.Vendor_Order_Total_Recieved = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        
        //Vendor Recievings
        filterWrapper.Vendor_Receiving_Header_Status = 'Vendor Receiving Header Status';
        
        //Vendor Invoices
        filterWrapper.Vendor_Invoicing_Header_Status = 'Vendor Invoicing Header Status';
        
        // Settings
        filterWrapper.Settings_Name = 'Settings Name';
        
        //Inventory Units
        filterWrapper.Inventory_Unit_VIN = 'Inventory_Unit_VIN';
        filterWrapper.Inventory_Unit_Stock_Number = 'Inventory_Unit_Stock_Number';
        filterWrapper.Inventory_Unit_Year = 'Inventory_Unit_Year';
        filterWrapper.Inventory_Unit_Make = 'Inventory_Unit_Make';
        filterWrapper.Inventory_Unit_Model = 'Inventory_Unit_Model';
        filterWrapper.Inventory_Unit_SubModel = 'Inventory_Unit_SubModel';
        filterWrapper.Inventory_Unit_Ext_Colour = 'Inventory_Unit_Ext_Colour';
        filterWrapper.Inventory_Unit_New_Unit = 'Inventory_Unit_New_Unit';
        filterWrapper.Inventory_Unit_Location = 'Inventory_Unit_Location';
        filterWrapper.Inventory_Unit_Category = 'Inventory_Unit_Category';
        
        filterWrapper.Inventory_Unit_Base_Unit_Price = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Factory_Options = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Dealer_Options = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Total_Price = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Base_Unit_Cost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Factory_Option_Cost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Dealer_Option_Cost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Total_Cost = new HomeSearchFilterWrapper.BetweenFilter('5', '12', '15');
        filterWrapper.Inventory_Unit_Stocked_In = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        
        filterWrapper.Inventory_Unit_Key_Number = 'Inventory_Unit_Key_Number';
        filterWrapper.Inventory_Unit_Engine_Number = 'Inventory_Unit_Engine_Number';
        filterWrapper.Inventory_Unit_Other_Number = 'Inventory_Unit_Other_Number';
        filterWrapper.Inventory_Unit_Int_Colour = 'Inventory_Unit_Int_Colour';
        
        filterWrapper.Inventory_Unit_Stocked_Out = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Inventory_Unit_Taxable = 'Inventory_Unit_Taxable';
        filterWrapper.Inventory_Unit_Applicable_Tax = 'Inventory_Unit_Applicable_Tax';
        filterWrapper.Inventory_Unit_Cylinders = new HomeSearchFilterWrapper.BetweenFilter('5', '1000', '5000');
        filterWrapper.Inventory_Unit_Automatic = 'Inventory_Unit_Automatic';
        filterWrapper.Inventory_Unit_Manufactured_Date = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Inventory_Unit_Mileage = new HomeSearchFilterWrapper.BetweenFilter('5', '1000', '5000');
        filterWrapper.Inventory_Unit_Plate_Number = 'Inventory_Unit_Plate_Number';
        filterWrapper.Inventory_Unit_Reg_Expiry = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        
        //Customer Units
        filterWrapper.Customer_Unit_Unit_ID = 'Customer_Unit_Unit_ID';
        filterWrapper.Customer_Unit_Customer = 'Customer_Unit_Customer';
        filterWrapper.Customer_Unit_Year = 'Customer_Unit_Year'; 
        filterWrapper.Customer_Unit_Make = 'Customer_Unit_Make';
        filterWrapper.Customer_Unit_Model = 'Customer_Unit_Model';
        filterWrapper.Customer_Unit_SubModel = 'Customer_Unit_SubModel';
        filterWrapper.Customer_Unit_Mileage = new HomeSearchFilterWrapper.BetweenFilter('5', '1000', '5000');
        
        
        filterWrapper.Customer_Unit_VIN = 'Customer_Unit_VIN';
        filterWrapper.Customer_Unit_Plate_Number = 'Customer_Unit_Plate_Number';
        filterWrapper.Customer_Unit_Reg_Expiry = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Customer_Unit_Key_Number = 'Customer_Unit_Key_Number';
        filterWrapper.Customer_Unit_Engine_Number = 'Customer_Unit_Engine_Number';
        filterWrapper.Customer_Unit_Other_Number = 'Customer_Unit_Other_Number';
        filterWrapper.Customer_Unit_Ext_Colour = 'Customer_Unit_Ext_Colour';
        filterWrapper.Customer_Unit_Int_Colour = 'Customer_Unit_Int_Colour';
        
        // Service Jobs
        filterWrapper.Service_Job_Scheduled = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Service_Job_Job_Type = '3';
        
        Map<String, List<HomeSearchFilterInterface.FieldFilter>> FilterListMap = HomeSearchFilterInterface.getFilterList(filterWrapper);
        System.assertEquals(FilterListMap.size()>0,true);
        List<HomeSearchFilterInterface.FilterLabel> FilterLabelList = HomeSearchFilterInterface.getFilterLabelList(filterWrapper);
        System.assertEquals(FilterLabelList.size()>0,true);
    }
    
    static testMethod void getFilterListTestA() {
        Account vendor = TestUtil.createVendor(true, 'Test Vendor');
        Category__c testCategory = TestUtil.createCategory(true, 'Test Category');
        
        Part__c part = TestUtil.createPart(true, 'TestPart', vendor.Id, 'TestPart', testCategory.Id, 10, 20, 50, 100, 100);
        Price_Level__c defaultPriceLevel = TestUtil.createPriceLevel(true, 'Default Price Level', 'MSRP', 10 , true, true);
        Sales_Tax__c defaultSalesTax = TestUtil.createSalesTax(true, 'Test Sales Tax', true, true, true);
        Account customer =  TestUtil.createCustomer(true, 'customerName', 'abc@abc.com', 'jaipur', '1111111111', defaultPriceLevel.id, defaultSalesTax.Id, true, false,'Individual');
        CO_Header__c coHeader = TestUtil.createCOHeader(true, customer.Id);
        CO_Line_Item__c coLineItem = TestUtil.createCOLineItem(true, coHeader.Id, part.Id, 150);
        
        Vendor_Order_Header__c voHeader = TestUtil.createVendorOrderHeader(false, vendor.Id);
        Vendor_Order_Line_Item__c voLineItem = TestUtil.createVendorOrderLineItem(false, voHeader.Id, part.Id, 150);
        
        List<Account> customerList = [select Name, Email__c, Phone, BillingCity, Price_Level__c, Sales_Tax__c , Type__c from Account];
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        
        filterWrapper.Type.objects = new Set<String>{'Vendor Receivings','Sublets','Vendor Invoices','Vendor Orders','Parts','Kits','Fees','Labor Codes', 'Customer Orders','Sales Taxes', 'Users', 'Vendors','User', 'Customer Payments','Customer Invoices', 'Vendor Ordering','Inventory Unit','Customer Unit','Parts Needed','Service Jobs' };
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('2', UserInfo.getUserId(), null);
        filterWrapper.People_Name = 'Harley';
        filterWrapper.SearchText = 'Test Search Text';
        filterWrapper.Status = null;
        filterWrapper.ModifiedDate = new HomeSearchFilterWrapper.BetweenFilter('5', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.CreatedDate = new HomeSearchFilterWrapper.BetweenFilter('8', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        
        // Customer
        filterWrapper.People_Id = customer.Id;
        filterWrapper.People_Email = 'abc@abc.com';
        filterWrapper.People_Phone = '111' ;
        filterWrapper.People_Country = 'India';
        filterWrapper.People_StateProv = 'Rajasthan';
        filterWrapper.People_BillingCity = 'Jaipur';
        filterWrapper.People_BillingAddress = 'H.N 11';
        filterWrapper.People_PriceLevel = defaultPriceLevel.Id ;
        filterWrapper.People_SalesTax = defaultSalesTax.Id ;
        
        // Vendor
        filterWrapper.Vendor_PurchaseSalesTax = '3';
        
        // Product
        filterWrapper.Product_Item = 'code';
        filterWrapper.Product_Description = 'Description';
        filterWrapper.Product_Category = testCategory.Id;
        filterWrapper.Product_Price = new HomeSearchFilterWrapper.BetweenFilter('4', '50', '150');
        filterWrapper.Product_QtyAvailable = new HomeSearchFilterWrapper.BetweenFilter('1', '12', '15');
        
        // Part
        filterWrapper.Part_Location = 'Test Part Location';
        filterWrapper.Part_Cost = new HomeSearchFilterWrapper.BetweenFilter('4', '12', '15');
        filterWrapper.Part_AverageCost = new HomeSearchFilterWrapper.BetweenFilter('4', '12', null);
        filterWrapper.Part_InStock = new HomeSearchFilterWrapper.BetweenFilter('4', '50', null);
        filterWrapper.Part_Committed = new HomeSearchFilterWrapper.BetweenFilter('4', '12', '15');
        filterWrapper.Part_OnOrder = new HomeSearchFilterWrapper.BetweenFilter('4', '12', '15');
        filterWrapper.Part_PackagedPart = '1' ;
        filterWrapper.Part_LastCounted = new HomeSearchFilterWrapper.BetweenFilter('4', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Part_LastSold = new HomeSearchFilterWrapper.BetweenFilter('4', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Part_LastStocked = new HomeSearchFilterWrapper.BetweenFilter('4', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Part_ReorderAt = new HomeSearchFilterWrapper.BetweenFilter('4', '12', '15');
        filterWrapper.Part_ReorderTo = new HomeSearchFilterWrapper.BetweenFilter('3', '12', '15');
        filterWrapper.Part_Vendor = 'Test Vendor';
        filterWrapper.Part_NonInventory = '2' ;
        filterWrapper.Part_MfgPart = '101' ;
        filterWrapper.Part_SKUNumber = '1111' ;
        filterWrapper.Part_OversoldCost = new HomeSearchFilterWrapper.BetweenFilter('3', '12', '15');
        filterWrapper.Part_OversoldQty = new HomeSearchFilterWrapper.BetweenFilter('3', '12', '15');
        
        // Kits
        filterWrapper.Kit_FixedPrice = '2' ;
        filterWrapper.Kit_ServiceKit = '2' ;
        filterWrapper.Kit_KitPrice = new HomeSearchFilterWrapper.BetweenFilter('4', '150', '250');
        
        // Customer Sales
        filterWrapper.Customer_Sales_Id = 'Customer Sales Id';
        filterWrapper.Customer_Sales_Customer = 'customerName';
        filterWrapper.Customer_Sales_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '2000', '4000');
        filterWrapper.Customer_Sales_Balance_Due = new HomeSearchFilterWrapper.BetweenFilter('1', '0', null);
        
        // Customer Orders
        filterWrapper.Customer_Order_Payments = new HomeSearchFilterWrapper.BetweenFilter('4', '-55', '15');
        filterWrapper.Customer_Order_Deposits = new HomeSearchFilterWrapper.BetweenFilter('4', '-5', '15');
        filterWrapper.Customer_Order_Status = 'In Progress';
        filterWrapper.Customer_Order_Deal_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '2000', '4000');
        
        // Customer Invoices
        filterWrapper.CO_Invoice_Header_Customer_Order = 'CO Invoice Header Customer Order' ;
        filterWrapper.CO_Invoice_Header_Part_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '3000', '4000');
        filterWrapper.CO_Invoice_Header_Labour_Total = new HomeSearchFilterWrapper.BetweenFilter('2', '3000', '4000');
        filterWrapper.CO_Invoice_Header_Fee_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '3000', '4000');
        filterWrapper.CO_Invoice_Header_Sublet_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '3000', '4000');
        filterWrapper.CO_Invoice_Header_Unit_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '500', '1500');
        filterWrapper.CO_Invoice_Header_SalesTax_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '500', '1500');
        
        // Customer Payments
        filterWrapper.CO_Payment_Customer_Order = 'Payment Customer Order';
        filterWrapper.CO_Payment_Payment_Method = new HomeSearchFilterWrapper.BetweenFilter('10', '500', '1500');
        
        //Vendor Ordering - Group
        filterWrapper.Vendor_Ordering_Id = voHeader.Id ;
        filterWrapper.Vendor_Ordering_Vendor = 'Test Vendor';
        filterWrapper.Vendor_Ordering_Total = new HomeSearchFilterWrapper.BetweenFilter('4', '1000', null);
        
        //Vendor Order
        filterWrapper.Vendor_Order_Purchase_Order = 'Vendor Purchase Order';
        filterWrapper.Vendor_Order_Total_Recieved = new HomeSearchFilterWrapper.BetweenFilter('4', '500', '1500');
        
        //Vendor Recievings
        filterWrapper.Vendor_Receiving_Header_Status = 'Vendor Receiving Header Status';
        
        //Vendor Invoices
        filterWrapper.Vendor_Invoicing_Header_Status = 'Vendor Invoicing Header Status';
        
        // Settings
        filterWrapper.Settings_Name = 'Settings Name';
        
        //Inventory Units
        filterWrapper.Inventory_Unit_VIN = 'Inventory_Unit_VIN';
        filterWrapper.Inventory_Unit_Stock_Number = 'Inventory_Unit_Stock_Number';
        filterWrapper.Inventory_Unit_Year = 'Inventory_Unit_Year';
        filterWrapper.Inventory_Unit_Make = 'Inventory_Unit_Make';
        filterWrapper.Inventory_Unit_Model = 'Inventory_Unit_Model';
        filterWrapper.Inventory_Unit_SubModel = 'Inventory_Unit_SubModel';
        filterWrapper.Inventory_Unit_Ext_Colour = 'Inventory_Unit_Ext_Colour';
        filterWrapper.Inventory_Unit_New_Unit = 'Inventory_Unit_New_Unit';
        filterWrapper.Inventory_Unit_Location = 'Inventory_Unit_Location';
        filterWrapper.Inventory_Unit_Category = 'Inventory_Unit_Category';
        
        filterWrapper.Inventory_Unit_Base_Unit_Price = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Factory_Options = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Dealer_Options = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Total_Price = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Base_Unit_Cost = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Factory_Option_Cost = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Dealer_Option_Cost = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Total_Cost = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        filterWrapper.Inventory_Unit_Stocked_In = new HomeSearchFilterWrapper.BetweenFilter('6', '1000', null);
        
        filterWrapper.Inventory_Unit_Key_Number = 'Inventory_Unit_Key_Number';
        filterWrapper.Inventory_Unit_Engine_Number = 'Inventory_Unit_Engine_Number';
        filterWrapper.Inventory_Unit_Other_Number = 'Inventory_Unit_Other_Number';
        filterWrapper.Inventory_Unit_Int_Colour = 'Inventory_Unit_Int_Colour';
        
        filterWrapper.Inventory_Unit_Stocked_Out = new HomeSearchFilterWrapper.BetweenFilter('7', '12', '15');
        filterWrapper.Inventory_Unit_Taxable = 'Inventory_Unit_Taxable';
        filterWrapper.Inventory_Unit_Applicable_Tax = 'Inventory_Unit_Applicable_Tax';
        filterWrapper.Inventory_Unit_Cylinders = new HomeSearchFilterWrapper.BetweenFilter('4', '1000', '5000');
        filterWrapper.Inventory_Unit_Automatic = 'Inventory_Unit_Automatic';
        filterWrapper.Inventory_Unit_Manufactured_Date = new HomeSearchFilterWrapper.BetweenFilter('3', '10', '15');
        filterWrapper.Inventory_Unit_Mileage = new HomeSearchFilterWrapper.BetweenFilter('2', '1000', '5000');
        filterWrapper.Inventory_Unit_Plate_Number = 'Inventory_Unit_Plate_Number';
        filterWrapper.Inventory_Unit_Reg_Expiry = new HomeSearchFilterWrapper.BetweenFilter('2', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        
        //Customer Units
        filterWrapper.Customer_Unit_Unit_ID = 'Customer_Unit_Unit_ID';
        filterWrapper.Customer_Unit_Customer = 'Customer_Unit_Customer';
        filterWrapper.Customer_Unit_Year = 'Customer_Unit_Year'; 
        filterWrapper.Customer_Unit_Make = 'Customer_Unit_Make';
        filterWrapper.Customer_Unit_Model = 'Customer_Unit_Model';
        filterWrapper.Customer_Unit_SubModel = 'Customer_Unit_SubModel';
        filterWrapper.Customer_Unit_Mileage = new HomeSearchFilterWrapper.BetweenFilter('1', '1000', null);
        
        
        filterWrapper.Customer_Unit_VIN = 'Customer_Unit_VIN';
        filterWrapper.Customer_Unit_Plate_Number = 'Customer_Unit_Plate_Number';
        filterWrapper.Customer_Unit_Reg_Expiry = new HomeSearchFilterWrapper.BetweenFilter('2', ((DateTime.now().addDays(-5)).format('MM/dd/YYYY')), ((DateTime.now()).format('MM/dd/YYYY')));
        filterWrapper.Customer_Unit_Key_Number = 'Customer_Unit_Key_Number';
        filterWrapper.Customer_Unit_Engine_Number = 'Customer_Unit_Engine_Number';
        filterWrapper.Customer_Unit_Other_Number = 'Customer_Unit_Other_Number';
        filterWrapper.Customer_Unit_Ext_Colour = 'Customer_Unit_Ext_Colour';
        filterWrapper.Customer_Unit_Int_Colour = 'Customer_Unit_Int_Colour';
        
        // Service Jobs
        filterWrapper.Service_Job_Scheduled = new HomeSearchFilterWrapper.BetweenFilter('1', '12', null);
        filterWrapper.Service_Job_Job_Type = '2';
        
        Map<String, List<HomeSearchFilterInterface.FieldFilter>> FilterListMap = HomeSearchFilterInterface.getFilterList(filterWrapper);
        System.assertEquals(FilterListMap.size()>0,true);
        List<HomeSearchFilterInterface.FilterLabel> FilterLabelList = HomeSearchFilterInterface.getFilterLabelList(filterWrapper);
        System.assertEquals(FilterLabelList.size()>0,true);
    }
    
    static testMethod void getFilterListTestB() {
        HomeSearchFilterWrapper filterWrapper = new HomeSearchFilterWrapper();
        
        filterWrapper.Type.objects = new Set<String>{};
        filterWrapper.Owner = new HomeSearchFilterWrapper.OwnerFilter('1', UserInfo.getUserId(), null);
        filterWrapper.Status = 'Stocked';
        
        filterWrapper.Service_Job_Job_Type = '4';
        
        Map<String, List<HomeSearchFilterInterface.FieldFilter>> FilterListMap = HomeSearchFilterInterface.getFilterList(filterWrapper);
        System.assertEquals(FilterListMap.size()>0,true);
    }   
}