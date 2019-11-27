@isTest
public with sharing class TestDataFactory {
    
    // A static constant integer to hold uniqueness among current context vendor codes
    private static Integer uniqueNumber = 1;
    
    /**
     * Name: sampleVendor
     * Desc: Method to create sample Vendor record
     * @param: String vendorName - Name of vendor
     * @return: sample Vendor record
    **/
    public static Account sampleVendor(String vendorName){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Account') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Account vendor = new Account();
        vendor.Name = (vendorName == null) ? 'Test Vendor' + uniqueNumber : vendorName ;
        vendor.Email__c = 'Test' + uniqueNumber + '@gmail.com';
        vendor.Phone =  '123456' + uniqueNumber;
        vendor.BillingCity = 'Test Billing City' + uniqueNumber;
        vendor.Is_Vendor__c = true;
        return vendor;
    }
    
    /**
     * Name: createVendor
     * Desc: Method to insert sample Vendor record
     * @param: String vendorName - Name of vendor
     * @return: Sample Vendor record
    **/
    public static Account createVendor(String vendorName){
        Account vendor = sampleVendor(vendorName);
        insert vendor;
        return vendor;
    }
    
    /**
     * Name: samplePriceLevel
     * Desc: Method to create sample Price Level record
     * @param: String priceLevelName - Name of price level
     * @return: sample Price Level record
    **/
    public static Price_Level__c samplePriceLevel(String priceLevelName){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Price_Level__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Price_Level__c priceLevel = new Price_Level__c();
        priceLevel.Name__c = (priceLevelName == null) ?  'Test Price Level' + uniqueNumber :  priceLevelName ;
        priceLevel.Part_Price_Base__c = 'Cost';
        priceLevel.Active__c = true; 
        priceLevel.Discount_Markup__c = 0;
        return priceLevel;
    }
    
    /**
     * Name: createPriceLevel
     * Desc: Method to insert sample Price Level record
     * @param: String priceLevelName - Name of price level
     * @return: Sample Price Level record
    **/
    public static Price_Level__c createPriceLevel(String priceLevelName){
        Price_Level__c priceLevel = samplePriceLevel(priceLevelName);
        insert priceLevel;
        return priceLevel;
    }
    
    /**
     * Name: sampleCategory
     * Desc: Method to create sample Category record
     * @param: String categoryName - Name of category
     * @return: sample category record
    **/
    public static Category__c sampleCategory(String categoryName){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Category__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Category__c categoryRec = new Category__c();
        categoryRec.Name = (categoryName == null) ? 'Test Category' + uniqueNumber : categoryName;
        categoryRec.Type__c = 'Test Labour ';
        categoryRec.Description__c = 'Test Description ' + uniqueNumber ; 
        categoryRec.Active__c = true ;
        categoryRec.OwnerId = UserInfo.getUserId();
        return categoryRec;
    }
    
    /**
     * Name: createCategory
     * Desc: Method to insert sample Category record
     * @param: String categoryName - Name of Category
     * @return: Sample Category record
    **/
    public static Category__c createCategory(String categoryName){
        Category__c categoryRec = sampleCategory(categoryName);
        insert categoryRec;
        return categoryRec;
    }
    
    /**
     * Name: sampleSalesTax
     * Desc: Method to create sample Sales Tax record
     * @param: String salesTaxName - Name of Sales Tax
     * @return: sample Sales Tax record
    **/
    public static Sales_Tax__c sampleSalesTax(String salesTaxName){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Sales_Tax__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Sales_Tax__c salesTax = new Sales_Tax__c();
        salesTax.Name__c = (salesTaxName == null) ? 'Test Sales Tax' + uniqueNumber : salesTaxName;
        salesTax.Forms_List_Taxes__c = true ;
        salesTax.Active__c = true ;
        return salesTax;
    }
    
    /**
     * Name: createSalesTax
     * Desc: Method to insert sample Sales Tax record
     * @param: String salesTaxName - Name of Sales Tax
     * @return: Sample Sales Tax record
    **/
    public static Sales_Tax__c createSalesTax(String salesTaxName){
        Sales_Tax__c salesTax = sampleSalesTax(salesTaxName);
        insert salesTax;
        return salesTax;
    }
    
    /**
     * Name: sampleCoHeader
     * Desc: Method to create sample CO Header record
     * @param: String customer - Name of Sales Tax
     * @return: sample CO Header record
    **/
    public static CO_Header__c sampleCoHeader(String customerId){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('CO_Header__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        CO_Header__c coHeader = new CO_Header__c();
        coHeader.Customer__c = customerId;
        coHeader.Owner__c = UserInfo.getUserId();
        return coHeader;
    }
    
    /**
     * Name: createCoHeader
     * Desc: Method to insert sample CO Header record
     * @param: String customer - Name of CO Header
     * @return: Sample CO Header record
    **/
    public static CO_Header__c createCoHeader(String customerId){
        CO_Header__c coHeader = sampleCoHeader(customerId);
        insert coHeader;
        return coHeader;
    }
    
    /**
     * Name: sampleCoLineItem
     * Desc: Method to create sample CO Line Item record
     * @param: String coHeader - Name of CO Header
     * @return: sample CO Line Item record
    **/
    public static CO_Line_Item__c sampleCoLineItem(String coHeaderId, Integer quantity){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('CO_Line_Item__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        CO_Line_Item__c coLineItem = new CO_Line_Item__c();
        coLineItem.CO_Header__c = (coHeaderId == null) ? '' : coHeaderId;
        //coLineItem.Part__c = '';
        coLineItem.Qty__c = quantity;
        return coLineItem;
    }
    
    /**
     * Name: createCoLineItem
     * Desc: Method to insert sample CO Line Item record
     * @param: String coHeader - Name of CO Header
     * @return: Sample CO Line Item record
    **/
    public static CO_Line_Item__c createCoLineItem(String coHeaderId, Integer quantity){
        CO_Line_Item__c coLineItem = new CO_Line_Item__c();
        coLineItem = sampleCoLineItem(coHeaderId, quantity);
        insert coLineItem;
        return coLineItem;
    }
    
    /**
     * Name: samplePart
     * Desc: Method to create sample Part record
     * @param: String vendorId - Id of Vendor
               Integer averageCost - Average Cost of part
               Integer LastCost - Last Cost of part
               Integer MSRP - 
               Integer retailPrice - 
               Integer qtyInStock - 
     * @return: Sample Part record
    **/
    public static Part__c samplePart(String vendorId, Integer averageCost, Integer lastCost, Integer MSRP, Integer retailPrice, Integer qtyInStock, String categoryId){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Part__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Part__c part = new Part__c();
        part.Part_Number__c = 'Test Part 123' + uniqueNumber;
        part.Description__c = 'This is test ' + uniqueNumber + ' Part';
        part.Category__c = categoryId;
        part.Vendor__c = vendorId;
        part.Order_Lots__c = 1;
        part.Average_Cost__c = averageCost;
        part.Last_Cost__c = lastCost;
        part.MSRP__c = MSRP;
        part.Retail_Price__c = retailPrice;
        part.Qty_In_Stock__c = qtyInStock;
        return part;
    }
    
    /**
     * Name: createPart
     * Desc: Method to insert sample Part record
     * @param: String vendorId - Id of Vendor
               Integer averageCost - Average Cost of part
               Integer LastCost - Last Cost of part
               Integer MSRP - 
               Integer retailPrice - 
               Integer qtyInStock -   
     * @return: Sample Part record
    **/
    public static Part__c createPart(String vendorId, Integer averageCost, Integer LastCost, Integer MSRP, Integer retailPrice, Integer qtyInStock, String categoryId){
        Part__c part = samplePart(vendorId, averageCost, LastCost, MSRP, retailPrice, qtyInStock, categoryId);
        insert part;
        return part;
    }
    
    public static Vendor_Invoicing_Header__c sampleVIHeader(Id vendorId, String status){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Vendor_Invoicing_Header__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Vendor_Invoicing_Header__c viHeader = new Vendor_Invoicing_Header__c();
        viHeader.Vendor__c = vendorId;
        viHeader.Status__c = status;
        viHeader.Owner__c = UserInfo.getUserId();
        return viHeader; 
    }  
    
    public static Vendor_Invoicing_Header__c createVIHeader(Id vendorId, String Status){
        Vendor_Invoicing_Header__c viHeader = sampleVIHeader(vendorId, Status);
        insert viHeader;
        return viHeader;
    }
    
    public static Accounting_Data_Migration__c sampleAccountMigration(String MYObObjectName, String objectName){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Accounting_Data_Migration__c') == false){
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Accounting_Data_Migration__c accountMigrateData = new Accounting_Data_Migration__c();
        accountMigrateData.Object_Name__c = objectName;
        accountMigrateData.MYOB_Object_Name__c = MYObObjectName;
        accountMigrateData.Last_Synched_Date__c = DateTime.newInstance(2016,06,13);                                                                                  
        return accountMigrateData;                     
    }
    
    public static Accounting_Data_Migration__c createAccountingMigration(String MYObObjectName, String objectName){
        Accounting_Data_Migration__c accountDataMigrate = sampleAccountMigration(MYObObjectName, objectName);
        insert accountDataMigrate;
        return accountDataMigrate;
    }
    
    /**
    * Name: sampleCountry
    * Desc: Method to create sample Country record
    * @param: String countryName - Name of Country
    * @return: sample Country record
    **/
    public static Country__c sampleCountry(String countryName){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Country__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Country__c countryRec = new Country__c();
        countryRec.Name__c = (countryName == null) ? 'India' + uniqueNumber : countryName;
        countryRec.Visible__c = true; 
        return countryRec;
    }
   
    /**
    * Name: createCountry
    * Desc: Method to insert sample Country record
    * @param: String countryName - Name of Country
    * @return: Sample Country record
    **/
    public static Country__c createCountry(String countryName){
        Country__c countryRec = sampleCountry(countryName);
        insert countryRec;
        return countryRec;
    }
    
    /**
    * Name: sampleState
    * Desc: Method to create sample State record
    * @param: String stateName - Name of State
    * @return: sample State record
    **/
    public static State__c sampleState(String stateName, String countryId){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('State__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        State__c stateRec = new State__c();
        stateRec.Name__c = (stateName == null) ? 'Maharastra' + uniqueNumber : stateName;
        stateRec.Country__c = countryId ; 
        return stateRec;
    }
   
    /**  
    * Name: createState
    * Desc: Method to insert sample State record
    * @param: String stateName - Name of State
    * @return: Sample State record
    **/
    public static State__c createState(String stateName, String countryId){
        State__c stateRec = sampleState(stateName, countryId);
        insert stateRec;
        return stateRec;
    }
   
    /**  
    * Name: sampleTimezone
    * Desc: Method to create sample Timezone record
    * @param: String timezoneLabel - Name of Timezone
    * @return: Sample Timezone record
    **/
    public static Timezone__c sampleTimezone(String timezoneLabel, String countryId, String stateId) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Timezone__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Timezone__c timezone = new Timezone__c();
        timezone.Country__c = countryId;
        timezone.State__c = stateId;
        timezone.Timezone_Label__c = (timezoneLabel == null) ? 'IST' + uniqueNumber : timezoneLabel;
        return timezone;
    }
   
    /**  
    * Name: createTimezone
    * Desc: Method to insert sample Timezone record
    * @param: String timezoneLabel - Name of Timezone
    * @return: Sample Timezone record
    **/
    public static Timezone__c createTimezone(String timezoneLabel, String countryId, String stateId) {
       Timezone__c timezone = sampleTimezone(timezoneLabel, countryId, stateId);
       insert timezone;
       return timezone;
    }
   
    /**  
    * Name: sampleCustomer
    * Desc: Method to create sample Customer record
    * @param: String customerName - Name of Customer
    * @return: Sample Customer record
    **/
    public static Account sampleCustomer(String customerName, String customerType, String firstName, String lastName) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Account') == false) {throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
        
        Account customer = new Account();
        customer.Name = (customerName == null) ? 'Test Customer' + uniqueNumber : customerName ;
        customer.Email__c = 'Test' + uniqueNumber + '@gmail.com';
        customer.Phone = '123456' + uniqueNumber;
        customer.BillingCity = 'Test Billing City' + uniqueNumber;
        customer.Is_Customer__c = true;
        customer.Type__c = customerType;
        customer.FirstName__c = firstName;
        customer.LastName__c = lastName;
        return customer;
    }
   
    /**  
    * Name: createCustomer
    * Desc: Method to insert sample Customer record
    * @param: String customerName - Name of Customer
    * @return: Sample Customer record
    **/
    public static Account createCustomer(String customerName, String customerType, String firstName, String lastName) {
        Account customer = sampleCustomer(customerName, customerType, firstname, lastName);
        insert customer;
        return customer;
    }
   
    public static Return_VO_Header__c sampleReturnVOHeader(String vendorId){
        Return_VO_Header__c returnVOHeaderRecord = new Return_VO_Header__c();
        returnVOHeaderRecord.RMA__c = 'Test';
        returnVOHeaderRecord.Credit_Memo__c = 'test';
        returnVOHeaderRecord.Vendor__c = vendorId;
        return returnVOHeaderRecord;
    }
   
    public static Return_VO_Header__c createReturnVOHeader(String vendorId){
        Return_VO_Header__c returnVOHeaderRecord = sampleReturnVOHeader(vendorId);
        insert returnVOHeaderRecord;
        return returnVOHeaderRecord;
    }
   
    public static Return_VO_Line_Item__c sampleReturnVOLineItem(String returnVOHeaderRecordId, String partId){
        Return_VO_Line_Item__c returnVOLIRecord = new Return_VO_Line_Item__c();
        returnVOLIRecord.Return_VO_Header__c = returnVOHeaderRecordId;
        returnVOLIRecord.Return_Qty__c = 10;
        returnVOLIRecord.Part__c = partId;
        return returnVOLIRecord;
    }
   
    public static Return_VO_Line_Item__c createReturnVOLineItem(String returnVOHeaderRecordId, String partId){
        Return_VO_Line_Item__c returnVOLIRecord = sampleReturnVOLineItem(returnVOHeaderRecordId, partId);
        insert returnVOLIRecord;
        return returnVOLIRecord;
    }
   
    public static Customer_Owned_Unit__c sampleCustomerOwnedUnit(String accountId, String UnitMakeId, String UnitModelId, String subModelId, String VIN){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Customer_Owned_Unit__c customerOwnedUnits = new Customer_Owned_Unit__c();
        customerOwnedUnits.Account__c = accountId ;
        customerOwnedUnits.Unit_Make__c = UnitMakeId ;
        customerOwnedUnits.Unit_Model__c = UnitModelId;
        customerOwnedUnits.Sub_Model__c = subModelId;
        customerOwnedUnits.VIN_Number__c = VIN ;
        customerOwnedUnits.Unit_Type__c = 'COU';
        customerOwnedUnits.Status__c  = 'Active'; 
        return customerOwnedUnits;
    }
   
    public static Customer_Owned_Unit__c createCustomerOwnedUnit(String accountId, String UnitMakeId, String UnitModelId, String subModelId, String VIN){
        Customer_Owned_Unit__c customerOwnedUnits = sampleCustomerOwnedUnit(accountId, UnitMakeId, UnitModelId, subModelId, VIN);
        insert customerOwnedUnits;
        return customerOwnedUnits;
    }
    
    public static Customer_Owned_Unit__c sampleCustomerOwnedUnit(String accountId, String VIN){
        Unit_Make__c unitMake = TestDataFactory.createUnitMake('Unit Make', 'Te1', true);
        Unit_Model__c unitModel = TestDataFactory.createUnitModel('Unit Model', 'Te1', true, unitMake.Id);
        Unit_Sub_Model__c unitSubModel = TestDataFactory.createSubModel(unitModel);
        Customer_Owned_Unit__c customerOwnedUnit = new Customer_Owned_Unit__c();
        customerOwnedUnit.Account__c = accountId ;
        customerOwnedUnit.Unit_Make__c = unitMake.Id;
        customerOwnedUnit.Unit_Model__c = UnitModel.Id;
        customerOwnedUnit.Sub_Model__c = unitSubModel.Id;
        customerOwnedUnit.VIN_Number__c = VIN ;
        customerOwnedUnit.Unit_Type__c = 'COU';
        customerOwnedUnit.Status__c  = 'Active'; 
        return customerOwnedUnit;
    }
    
    public static Customer_Owned_Unit__c createCustomerOwnedUnit(String accountId, String VIN){
        Customer_Owned_Unit__c customerOwnedUnit = sampleCustomerOwnedUnit(accountId, VIN);
        insert customerOwnedUnit;
        return customerOwnedUnit;
    }
    
    //@todo - TK
    public static void sampleCOInvoiceItem(String categoryId, String coInvoiceHeaderId, String coLineItemId, Boolean isActive){
        /*if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Item__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }   
        CO_Invoice_Item__c coInvoiceItemRec = new CO_Invoice_Item__c();
        coInvoiceItemRec.Category__c = categoryId;
        coInvoiceItemRec.CO_Invoice_Header__c = coInvoiceHeaderId;
        coInvoiceItemRec.CO_Line_Item__c = coLineItemId;
        coInvoiceItemRec.isActive__c = isActive;
        return coInvoiceItemRec; */
    }
   
    public static void createCOInvoiceLineItem(String categoryId, String coInvoiceHeaderId, String coLineItemId, Boolean isActive){
        /*CO_Invoice_Item__c coInvoiceItemRec = new CO_Invoice_Item__c();
        coInvoiceItemRec = sampleCOInvoiceItem(categoryId, coInvoiceHeaderId, coLineItemId, isActive);
        insert coInvoiceItemRec;
        return coInvoiceItemRec;*/
    }
   
    public static Unit_Make__c sampleUnitMake(String unitMakeName, String VINCode, Boolean isActive){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Unit_Make__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Unit_Make__c unitMake = new Unit_Make__c();
        unitMake.Name = (unitMakeName == null) ? 'Test Unit Make ' : unitMakeName;
        unitMake.VIN_Code__c = (VINCode == null) ? 'TES' : VINCode;
        unitMake.Active__c = isActive;
        return unitMake;
    }
   
    public static Unit_Make__c createUnitMake(String unitMakeName, String VINCode, boolean isActive){
        Unit_Make__c unitMake = sampleUnitMake(unitMakeName, VINCode, isActive);
        insert unitMake;
        return unitMake;
    }
   
    public static Unit_Model__c sampleUnitModel(String unitModelName, String VINCode, boolean isActive, String unitMakeId){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Unit_Model__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Unit_Model__c unitModel = new Unit_Model__c();
        unitModel.Name__c = (unitModelName == null) ? 'Test Unit Model ' : unitModelName;
        unitModel.VIN_Code__c = (VINCode == null) ? 'TES' : VINCode;
        unitModel.Active__c = (isActive == null) ? true : isActive;
        unitModel.Unit_Make__c = (unitMakeId == null) ? '' : unitMakeId;
        return unitModel;
    }
   
    public static Unit_Model__c createUnitModel(String unitModelName, String VINCode, boolean isActive, String unitMakeId){
        Unit_Model__c unitModel = sampleUnitModel(unitModelName, VINCode, isActive, unitMakeId);
        insert unitModel;
        return unitModel;
    }
   
    public static Unit_Sub_Model__c sampleSubModel(Unit_Model__c unitModel){
        Unit_Sub_Model__c unitSubModel = new Unit_Sub_Model__c();
        unitSubModel.Sub_Model_Name__c = 'unitSubModelName';
        unitSubModel.Active__c = true;
        unitSubModel.Unit_Model__c = unitModel.ID;
        unitSubModel.VIN_Code__c = 'VIN';
        return unitSubModel;
    }
   
    public static Unit_Sub_Model__c createSubModel(Unit_Model__c unitModel){
        Unit_Sub_Model__c unitSubModel = sampleSubModel(unitModel);
        insert unitSubModel;
        return unitSubModel;
    }
   
    public static CO_Invoice_Header__c sampleCOInvoiceHeader(String coHeaderId, String status){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('CO_Invoice_Header__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        CO_Invoice_Header__c coInvoiceHeaderRec = new CO_Invoice_Header__c();
        coInvoiceHeaderRec.CO_Header__c = coHeaderId;
        coInvoiceHeaderRec.Invoice_Status__c = status;
        return coInvoiceHeaderRec;
    }
   
    public static CO_Invoice_Header__c createCOInvoiceHeader(String coHeaderId, String status){
        CO_Invoice_Header__c coInvoiceHeaderRec = sampleCOInvoiceHeader(coHeaderId, status);
        insert coInvoiceHeaderRec;
        return coInvoiceHeaderRec;
    }
    
    public static Event sampleEventForMorning(Id customerId, Id customerOwnedUnitId){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Event') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Event eventRec = new Event();
        eventRec.Subject = 'Test Event';
        eventRec.Customer__c = customerId;
        eventRec.Customer_Owned_Unit__c = customerOwnedUnitId;
        eventRec.StartDateTime = datetime.newInstance(2018, 7, 9, 8, 0, 0);
        eventRec.Estimated_Hours__c = 2;
        eventRec.DurationInMinutes = 120;
        eventRec.Description = 'Test Description'; 
        eventRec.Event_Concern__c = null;
        eventRec.Appointment_Day_Segment__c = 'Morning';
        return eventRec;
    }
   
    public static Event createEventForMorning(Id customerId , Id customerOwnedUnitId){
        Event event = sampleEventForMorning(customerId, customerOwnedUnitId);
        insert event;
        return event;
    }
   
    public static Event sampleEventForAfternoon(Id customerId, Id customerOwnedUnitId){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Event') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Event eventRec = new Event();
        eventRec.Subject = 'Test Event';
        eventRec.Customer__c = customerId;
        eventRec.Customer_Owned_Unit__c = customerOwnedUnitId;
        eventRec.StartDateTime = datetime.newInstance(2018, 7, 9, 13, 0, 0);
        eventRec.Estimated_Hours__c = 2;
        eventRec.DurationInMinutes = 120;
        eventRec.Description = 'Test Description'; 
        eventRec.Event_Concern__c = null;
        eventRec.Appointment_Day_Segment__c = 'Afternoon';
        return eventRec;
    }
    
    public static Event createEventForAfternoon(Id customerId , Id customerOwnedUnitId){
        Event event = sampleEventForAfternoon(customerId, customerOwnedUnitId);
        insert event;
        return event;
    }
   
    public static Technician__c sampleTechnician(){
        Technician__c technician = new Technician__c(First_Name__c = 'Test', Last_Name__c = 'Name');
        technician.Technician_Name__c = 'Test Name';
        technician.Type__c = 'Technician';
        technician.Active__c = true;
        technician.Working_Days__c = 'Monday; Tuesday; Wednesday; Thursday; Friday';
        return technician;
    }
   
    public static Technician__c createTechnician(){
        Technician__c technician = sampleTechnician();
        insert technician;
        return technician;
    }
   
    public static Leave__c sampleLeave(Id technicianId){
        Leave__c leave = new Leave__c(Name = 'Annual Leave', Technician__c = technicianId);
        leave.From__c = datetime.newInstance(2018, 7, 9, 13, 30, 0);
        leave.To__c = datetime.newInstance(2018, 7, 9, 14, 30, 0);
        return leave;
    }
   
    public static Leave__c createLeave(Id technicianId){
        Leave__c leave = sampleLeave(technicianId);
        insert leave;
        return leave;
    }
   
    public static Form__c sampleForm(){
        Form__c form = new Form__c();
        form.Name = 'Test deal Form';
        form.Description__c = 'Test deal form';
        form.Grouping_Name__c = 'Deal';
        form.Is_Manual_Upload__c = true;
        form.Is_Active__c = true;
        return form;
    }
   
    public static Form__c createForm(){
        Form__c form = sampleForm();
        insert form;
        return form;
    }
   
    public static Attachment sampleAttachment(Id parentId) {
        Attachment attachment = new Attachment();
        attachment.ParentId = parentId;
        attachment.Body = EncodingUtil.base64Decode('Test Attachment body');
        attachment.Name = 'Test Attachment';
        return Attachment;
    }
    
    public static Attachment createAttachment(Id parentId){
        Attachment attachment = sampleAttachment(parentId);
        insert attachment;
        return attachment;
    }
    
    public static Service_Order_Header__c sampleSOHeader(String coHeaderId){
        Service_Order_Header__c soHeaderRec = new Service_Order_Header__c();
        soHeaderRec.Name__c = 'Test SO Header';
        soHeaderRec.CO_Header__c = coHeaderId;
        return soHeaderRec;
    }
    
    public static Service_Order_Header__c createSOHeader(String coHeaderId){
        Service_Order_Header__c soHeaderRec = sampleSOHeader(coHeaderId);
        insert soHeaderRec;
        return soHeaderRec;
    }
    
    public static Cash_Drawer__c sampleCashDrawer(String cashDrawerName){
        Cash_Drawer__c cashDrawerRec = new Cash_Drawer__c();
        cashDrawerRec.Name =  cashDrawerName;
        cashDrawerRec.Active__c = true;
        return cashDrawerRec;
    }
    
    public static Cash_Drawer__c createCashDrawer(String cashDrawerName){
        Cash_Drawer__c cashDrawerRec = sampleCashDrawer(cashDrawerName);
        insert cashDrawerRec;
        return cashDrawerRec;
    }
    
    public static CO_Invoice_Payment__c sampleCOInvoicePayment(String cashDrawerId, String coInvoiceHeaderId){
        CO_Invoice_Payment__c coInvoicePaymentRec = new CO_Invoice_Payment__c();
        coInvoicePaymentRec.CO_Invoice_Header__c = coInvoiceHeaderId;
        coInvoicePaymentRec.Cash_Drawer__c = cashDrawerId;
        return coInvoicePaymentRec;
    }
    
    public static CO_Invoice_Payment__c createCOInvoicePayment(String cashDrawerId, String coInvoiceHeaderId){
        CO_Invoice_Payment__c coInvoicePaymentRec = sampleCOInvoicePayment(cashDrawerId, coInvoiceHeaderId);
        insert coInvoicePaymentRec;
        return coInvoicePaymentRec;
    }
    
    public static CO_Deposit__c sampleCODeposit(String coHeaderId, String cashDrawerId, String paymentMethod, Decimal amount){
        CO_Deposit__c coDepositRec = new CO_Deposit__c();
        coDepositRec.CO_Header__c = coHeaderId;
        coDepositRec.Cash_Drawer__c = cashDrawerId;
        coDepositRec.Payment_Method__c = paymentMethod;
        coDepositRec.Amount__c = amount;
        return coDepositRec;
    }
    
    public static CO_Deposit__c createCODeposit(String coHeaderId, String cashDrawerId, String paymentMethod, Decimal amount){
        CO_Deposit__c coDepositRec = sampleCODeposit(coHeaderId, cashDrawerId, paymentMethod, amount);
        insert coDepositRec;
        return coDepositRec;
    }
    
    public static Cash_Reconciliation__c sampleCashReconciliation(String cashReconcilationStatus){
        Cash_Reconciliation__c cashReconciliationRec = new Cash_Reconciliation__c();
        cashReconciliationRec.Status__c = cashReconcilationStatus;
        return cashReconciliationRec;
    }
    
    public static Cash_Reconciliation__c createCashReconciliation(String cashReconciliationStatus){
        Cash_Reconciliation__c cashReconciliationRec = sampleCashReconciliation(cashReconciliationStatus);
        insert cashReconciliationRec;
        return cashReconciliationRec; 
    }
    
    public static Cash_Drawer_Reconciliation__c sampleCashDrawerReconciliation(String cashDrawerId, String cashReconciliationId){
        Cash_Drawer_Reconciliation__c cashDrawerReconciliationRec = new Cash_Drawer_Reconciliation__c();
        cashDrawerReconciliationRec.Cash_Drawer__c = cashDrawerId;
        cashDrawerReconciliationRec.Cash_Reconciliation__c = cashReconciliationId;
        return cashDrawerReconciliationRec;
    }
    
    public static Cash_Drawer_Reconciliation__c createCashDrawerReconciliation(String cashDrawerId, String cashReconciliationId){
        Cash_Drawer_Reconciliation__c cashDrawerReconciliationRec = sampleCashDrawerReconciliation(cashDrawerId, cashReconciliationId);
        insert cashDrawerReconciliationRec;
        return cashDrawerReconciliationRec;
        
    }
    
    public static Cash_Reconciliation_Payment__c sampleCashReconciliationPayment(String cashDrawerReconciliationId, String cashReconciliationId){
        Cash_Reconciliation_Payment__c cashReconciliationPaymentRec = new Cash_Reconciliation_Payment__c();
        cashReconciliationPaymentRec.Cash_Drawer_Reconciliation__c = cashDrawerReconciliationId;
        cashReconciliationPaymentRec.Cash_Reconciliation__c = cashReconciliationId;
        return cashReconciliationPaymentRec;
    }
    
    public static Cash_Reconciliation_Payment__c createCashReconciliationPayment(String cashDrawerReconciliationId, String cashReconciliationId){
        Cash_Reconciliation_Payment__c cashReconciliationPaymentRec = TestDataFactory.sampleCashReconciliationPayment(cashDrawerReconciliationId, cashReconciliationId);
        insert cashReconciliationPaymentRec;
        return cashReconciliationPaymentRec;
    }
    
    public static Shop_Settings__c sampleShopSettings(String day){
        Shop_Settings__c shopSettingsRec = new Shop_Settings__c();
        shopSettingsRec.Name = 'Monday';
        shopSettingsRec.From_Time__c = '8:00AM';
        shopSettingsRec.To_Time__c = '5:00PM';
        shopSettingsRec.Day__c = day;
        shopSettingsRec.Is_Working__c = true;
        return shopSettingsRec;
    }
    
    public static Shop_Settings__c createShopSettings(String day){
        Shop_Settings__c shopSettingsRec = sampleShopSettings(day);
        insert shopSettingsRec;
        return shopSettingsRec;
    }
    
    public static Event sampleEventWithServiceHeader(Id customerId, Id customerOwnedUnitId, Id serviceHeaderId){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Event') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Event eventRec = new Event();
        eventRec.Subject = 'Test Event';
        eventRec.Customer__c = customerId;
        eventRec.Customer_Owned_Unit__c = customerOwnedUnitId;
        eventRec.StartDateTime = datetime.newInstance(2018, 7, 9, 13, 0, 0);
        eventRec.Estimated_Hours__c = 2;
        eventRec.DurationInMinutes = 120;
        eventRec.Description = 'Test Description'; 
        eventRec.Event_Concern__c = null;
        eventRec.Appointment_Day_Segment__c = 'Afternoon';
        eventRec.Service_Order_Header__c = serviceHeaderId;
        return eventRec;
    }
    
    public static Event createEventWithServiceHeader(Id customerId , Id customerOwnedUnitId, Id serviceHeaderId){
        Event event = sampleEventWithServiceHeader(customerId, customerOwnedUnitId, serviceHeaderId);
        insert event;
        return event;
    }
    
    public static Notes__c sampleNotes(){
        Notes__c notes = new Notes__c();
        notes.Description__c = 'Test Description';
        return notes;
    } 
    
    public static Notes__c createNotes(){
        Notes__c notes = sampleNotes();
        insert notes;
        return notes;
    }
    
    public static Linked_Form__c sampleLinkedForm(String formId, String productId, String groupingName){
        Linked_Form__c linkedForm = new Linked_Form__c();
        linkedForm.Form__c = formId;
        linkedForm.Vendor_Product__c = productId;
        linkedForm.Grouping_Name__c = groupingName;
        return linkedForm;
    }
    
    public static Linked_Form__c createLinkedForm(String formId, String productId, String groupingName){
        Linked_Form__c linkedForm = sampleLinkedForm(formId, productId, groupingName);
        insert linkedForm;
        return linkedForm;
    }
    
     public static Product__c sampleProduct(String categoryId, String productCode, String vendorId){
        Product__c product = new Product__c();
        product.Category__c = categoryId;
        product.Code__c = productCode;
        product.Vendor__c = vendorId ;
        return product;
    }
    
    public static Product__c createProduct(String categoryId, String productCode, String vendorId){
        Product__c product = sampleProduct(categoryId, productCode, vendorId);
        insert product;
        return product;
    }
    
    public static CO_Form__c sampleCOForm(String soHeaderId, String coHeaderId){
        CO_Form__c coForm = new CO_Form__c();
        coForm.Service_Order_Header__c = soHeaderId;
        coForm.CO_Header__c = coHeaderId;
        coForm.Is_Editable__c = true;
        return coForm;
    }
    
    public static CO_Form__c createCOForm(String soHeaderId, String coHeaderId){
        CO_Form__c coForm = sampleCOForm(soHeaderId, coHeaderId);
        insert coForm;
        return coForm;
    }
    
    public static Customer_Owned_Unit__c sampleStockUnit(String unitMakeId, String unitModelId, String subModelId, String VIN){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Customer_Owned_Unit__c') == false) {
            throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Customer_Owned_Unit__c stockUnit = new Customer_Owned_Unit__c();
        stockUnit.Unit_Make__c = UnitMakeId ;
        stockUnit.Unit_Model__c = UnitModelId;
        stockUnit.Sub_Model__c = subModelId;
        stockUnit.VIN_Number__c = VIN ;
        stockUnit.Unit_Type__c = 'STOCK';
        return stockUnit;
    }
    
    public static Customer_Owned_Unit__c createStockUnit(String unitMakeId, String unitModelId, String subModelId, String VIN){
        Customer_Owned_Unit__c stockUnit = sampleStockUnit(unitMakeId, unitModelId, subModelId, VIN);
        insert stockUnit;
        return stockUnit;
    }
    
    public static Deal__c sampleDeal(String coHeaderId, String unitId){
        Deal__c dealRec = new Deal__c(CO_Header__c = coHeaderId, Status__c = Constants.QUOTATION, Type__c = Constants.CASH_DEAL);
        dealRec.Unit_Status__c = Constants.TEMPORARY;
        return dealRec;
    }
    
    public static Deal__c createDeal(String coHeaderId, String unitId){
        Deal__c dealRec = sampleDeal(coHeaderId, unitId);
        insert dealRec;
        CustomerOrderCtrl.addUnitToDeal(null, BPUtility.getEncodedString(unitId), BPUtility.getEncodedString(dealRec.Id));
        return dealRec;
    }
    
    public static CustomerApproval__c sampleCustomerApproval(String status, String notesId){
        CustomerApproval__c customerApproval = new CustomerApproval__c();
        customerApproval.Status__c = status;
        customerApproval.Notes__c = notesId;
        return customerApproval;
    }
    
    public static CustomerApproval__c createCustomerApproval(String status, String notesId){
        CustomerApproval__c customerApproval = sampleCustomerApproval(status, notesId);
        insert customerApproval;
        return customerApproval;
    }
    
    public static Internal_Comment__c sampleInternalComment(Id coHeaderId, String comment){
        Internal_Comment__c internalComment = new Internal_Comment__c();
        internalComment.CO_Header__c = coHeaderId;
        internalComment.Comment__c = comment;
        return internalComment;
    }
    
    public static Internal_Comment__c createInternalComment(Id coHeaderId, String comment){
        Internal_Comment__c internalComment = sampleInternalComment(coHeaderId, comment);
        insert internalComment;
        return internalComment;
    }
    
    public static DP360_Configuration__c createDP360Configuration(){
        DP360_Configuration__c DP360Config = new DP360_Configuration__c(Dealer_Id__c = '100', End_Point_URL__c = 'https://www.google.com', 
        											Last_Synched_Date__c = system.today() - 10);
        insert DP360Config;
        return DP360Config;
    }
    
    public static Task__c sampleTask(){
        Task__c task = new Task__c(); 
        return task;
    }
    
    public static Task__c createTask(){
        Task__c task = sampleTask();
        insert task;
        return task;
    }
    
    public static Hours_Logged__c sampleHoursLogged(String technicianId, String soHeaderId, String taskId){
        Hours_Logged__c hoursLogged = new Hours_Logged__c(Technician__c = technicianId, Start_Date_Time__c = system.today(), 
        													Service_Order_Header__c = soHeaderId, Task__c = taskId);
        return hoursLogged;
    }
    
    public static Hours_Logged__c createHoursLogged(String technicianId, String soHeaderId, String taskId){
        Hours_Logged__c hoursLogged = sampleHoursLogged(technicianId, soHeaderId, taskId);
        insert hoursLogged;
        return hoursLogged;
    }
    
    public static Payroll_Time__c samplePayrollTime(String technicianId){
        Payroll_Time__c payrollTime = new Payroll_Time__c(Start_Date__c = system.today(), Technician__c = technicianId);
        return payrollTime;
    }
    
    public static Payroll_Time__c createPayrollTime(String technicianId){
        Payroll_Time__c payrollTime = samplePayrollTime(technicianId);
        insert payrollTime;
        return payrollTime;
    }
    
    public static Logged_In_Device__c sampleLoggedInDevice(){
        Logged_In_Device__c loggedInDevice = new Logged_In_Device__c();
        return loggedInDevice;
    }
    
    public static Logged_In_Device__c createLoggedInDevice(){
        Logged_In_Device__c loggedInDevice = sampleLoggedInDevice();
        insert loggedInDevice ;
        return loggedInDevice;
    }
    
    public static Fee__c sampleFee(Boolean isActive, String categoryId, String code, String coHeaderId, String description, 
    								Decimal price, Boolean isTaxable){
        Fee__c fee = new Fee__c();
        fee.Active__c = isActive;
        fee.Category__c = categoryId;
        fee.Code__c = code;
        fee.CO_Header__c = coHeaderId;
        fee.Description__c = description;
        fee.Price__c = price;
        fee.Taxable__c= isTaxable;
        return fee;
    }
    
    public static Fee__c createFee(Boolean isActive, String categoryId, String code , String coHeaderId, String description, Decimal price, Boolean isTaxable){
        Fee__c fee = sampleFee(isActive, categoryId, code, coHeaderId, description, price, isTaxable);
        insert fee;
        return fee;
    }
    
    public static Vendor_Order_Header__c sampleVendorOrderHeader(String vendorId) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Header__c') == false) {
        	throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }
        Vendor_Order_Header__c vendorOrderHeader = new Vendor_Order_Header__c();    
        vendorOrderHeader.Vendor__c = vendorId;
        vendorOrderHeader.Owner__c = UserInfo.getUserId();
        return vendorOrderHeader;
    }
    
    public static Vendor_Order_Header__c createVendorOrderHeader(String vendorId){
        Vendor_Order_Header__c vendorOrderHeader = sampleVendorOrderHeader(vendorId);
        insert vendorOrderHeader ;
        return vendorOrderHeader;
    }
    
    public static Vendor_Order_Line_Item_Group__c sampleVendorOrderLineItemGroup(String vendorOrderHeaderId, String partId) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Vendor_Order_Line_Item_Group__c') == false) {
        		throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
       	} 
        Vendor_Order_Line_Item_Group__c vendorOrderLineItemGroup = new Vendor_Order_Line_Item_Group__c(); 
        vendorOrderLineItemGroup.Vendor_Order_Header__c = vendorOrderHeaderId;
        vendorOrderLineItemGroup.Part__c = partId;
        vendorOrderLineItemGroup.Need__c = 0;
        return vendorOrderLineItemGroup;
    }
    
    public static Vendor_Order_Line_Item_Group__c createVendorOrderLineItemGroup(String vendorOrderHeaderId, String partId){
        Vendor_Order_Line_Item_Group__c vendorOrderLineItemGroup = sampleVendorOrderLineItemGroup(vendorOrderHeaderId, partId);
        insert vendorOrderLineItemGroup ;
        return vendorOrderLineItemGroup;
    }
    
    public static QuickBooks_Configurations__c sampleQBConfig(){
        QuickBooks_Configurations__c qbConfig = QuickBooks_Configurations__c.getOrgDefaults();
        qbConfig.Consumer_Key__c =  'qyprdFawAAiD3SLud6d5RvREaVOoAn';
        qbConfig.End_Point_URL__c = 'https://sandbox-quickbooks.api.intuit.com/v3/company/';
        qbConfig.Consumer_Secret__c = 'q3JPBvXRxwRWldrpEQzXlByXs7joEglmCBhRPinr';
        qbConfig.OAuth_Token__c = 'lEMGSBPH1EHYnBvd9EdvcEhiYzNCBSaNeuzl16pW';
        qbConfig.OAuth_Token_Secret__c = 'qyprda2rZrHpkhUupn1WM5gY7Txg0IgCLRSht1gAtwY41oyY';
        qbConfig.Company_Id__c = '123145730762509';
        qbConfig.Access_Token_Generation_Date__c = system.today().addDays(-155);
        return qbConfig;
    }
    
    public static QuickBooks_Configurations__c createQBConfig(){
        QuickBooks_Configurations__c qbConfig = sampleQBConfig();
        insert qbConfig;
        return qbConfig;
    }
    
    public static General_Configurations__c sampleGeneralConfig(Integer pageSize) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('General_Configurations__c') == false) {
        	throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
       	}
        General_Configurations__c genConfig = new General_Configurations__c(Related_List_Page_Size__c = pageSize);
        genConfig.Enable_QB_Accounting__c = true;
        return genConfig;
    }
    
    public static General_Configurations__c createGeneralConfig(Integer pageSize) {
        General_Configurations__c genConfig = sampleGeneralConfig(pageSize);
        insert genConfig;
        return genConfig;
    }
    
    public static Tag__c sampleTag(String tagName) {
        Tag__c tag = new Tag__c();
        tag.Name__c = tagName;
        return tag;
    }
    
    public static Tag__c createTag(String tagName) {
        Tag__c tag = sampleTag(tagName);
        insert tag;
        return tag;
    }
    
    public static Labour_Code__c sampleLabourCode(String categoryId, String code, String coHeaderId, Boolean isFixedRate, Decimal hours, String labourCodeName, Decimal rate, Boolean isTaxable ) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Labour_Code__c') == false) {
        	throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);
        }  
        Labour_Code__c labourCode = new Labour_Code__c();
        LabourCode.Active__c = true;
        LabourCode.Category__c = categoryId;
        LabourCode.Code__c = code;
        LabourCode.CO_Header__c = coHeaderId;
        LabourCode.Description__c = 'Test Description';
        LabourCode.Fixed_Rate__c = isFixedRate;
        LabourCode.Hours__c = hours;
        LabourCode.Name__c = labourCodeName;
        LabourCode.Rate__c = rate;
        LabourCode.Taxable__c = isTaxable;
        return labourCode;
    }
    
    public static Labour_Code__c createLabourCode(String categoryId, String code, String coHeaderId, Boolean isFixedRate, Decimal hours, 
    												String labourCodeName, Decimal rate, Boolean isTaxable ) {
        Labour_Code__c labourCode = sampleLabourCode(categoryId, code, coHeaderId, isFixedRate, hours, labourCodeName, rate, isTaxable);
        insert labourCode;
        return labourCode;
    }
    
    public static Service_Order_Line_Item__c sampleServiceOrderLineItem(String serviceOrderHeaderId) {
        Service_Order_Line_Item__c serviceOrderLineItem = new Service_Order_Line_Item__c();
        serviceOrderLineItem.Service_Order_Header__c = serviceOrderHeaderId;
        return serviceOrderLineItem;
    }
    
    public static Service_Order_Line_Item__c createServiceOrderLineItem(String serviceOrderHeaderId) {
        Service_Order_Line_Item__c serviceOrderLineItem = sampleServiceOrderLineItem(serviceOrderHeaderId);
        insert serviceOrderLineItem;
        return serviceOrderLineItem;
    }
    
    public static Reconciliation_Payment__mdt sampleReconciliationPayment(String paymentType){
        Reconciliation_Payment__mdt reconciliationPayment = new Reconciliation_Payment__mdt();
        reconciliationPayment.Active__c = true;
        reconciliationPayment.Icon_Link__c = '';
        reconciliationPayment.Order_Number__c = 12;
        reconciliationPayment.Payment_Method__c = 'VISA';
        reconciliationPayment.Type__c = paymentType;
        return reconciliationPayment;
    }
    
    public static Deal_Item__c sampleDealItem(String unitModelId, String dealId){
        Deal_Item__c dealItemRec = new Deal_Item__c(Colour__c='Red',Year__c = 2019); 
        dealItemRec.Unit_Model__c = unitModelId;
        dealItemRec.Deal__c = dealId;
        return dealItemRec;
    }
    
    public static Deal_Item__c createDealItem(String unitModelId, String dealId){
        Deal_Item__c dealItemRec = sampleDealItem(unitModelId, dealId);
        insert dealItemRec;
        return dealItemRec;
    }
    
    public static Kit_Header__c sampleKitHeader(Boolean active, Boolean canSplit, Boolean isFixedPriceFlag, Boolean isServiceKit, 
    											String unitMakeId, String unitModelId){
        Kit_Header__c KitHeader = new Kit_Header__c();
        KitHeader.Active__c = active;
        KitHeader.Can_Split__c = canSplit;
        KitHeader.Cause__c = 'Cause';
        KitHeader.Code__c = 'Code';
        KitHeader.Concern__c = 'Concern';
        KitHeader.Correction__c = 'Correction';
        KitHeader.Description__c = 'Description';
        KitHeader.Fixed_Price__c = 50;
        KitHeader.Fixed_Price_Flag__c = isFixedPriceFlag;
        KitHeader.Service_Kit__c = isServiceKit;
        KitHeader.Make__c = unitMakeId;
        KitHeader.Model__c = unitModelId;
        return KitHeader;
    }
    
    public static Kit_Header__c createKitHeader(Boolean active, Boolean canSplit, Boolean isFixedPriceFlag, Boolean isServiceKit, String unitMakeId, String unitModelId){
        Kit_Header__c kitHeader = sampleKitHeader(active, cansplit, isFixedPriceFlag, isServiceKit, unitMakeId, unitModelId);
        insert kitHeader;
        return kitHeader;
    }
    
    public static Deal_Kit_Header__c sampleDealKitHeader(String coHeaderId, String dealItemId, String kitHeaderId){
        Deal_Kit_Header__c dealKitHeaderRec = new Deal_Kit_Header__c();
        dealKitHeaderRec.CO_Header__c = coHeaderId;
        dealKitHeaderRec.Deal_Item__c = dealItemId;
        dealKitHeaderRec.Actual_Kit_Price__c = 25;
        dealKitHeaderRec.Kit_Header__c = kitHeaderId;
        return dealKitHeaderRec;
    }
    
    public static Deal_Kit_Header__c createDealKitHeader(String coHeaderId, String dealItemId, String kitHeaderId){
        Deal_Kit_Header__c dealKitHeaderRec = sampleDealKitHeader(coHeaderId, dealItemId, kitHeaderId);
        insert dealKitheaderRec;
        return dealKitheaderRec;
    }
    
    public static Sales_Tax_Item__c sampleSalesTaxItem(String salesTaxItemName, Decimal rate, String formsLabel, String categoryId, Boolean isTaxPart){
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Sales_Tax_Item__c') == false) {throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}      
        Sales_Tax_Item__c salesTaxItem = new Sales_Tax_Item__c(); 
        salesTaxItem.Name__c = (salesTaxItemName != null) ?  salesTaxItemName : 'Test Sales Tax Item' + uniqueNumber;
        salesTaxItem.Rate__c = (rate == 0) ? uniqueNumber : rate;
        salesTaxItem.Forms_Label__c = (formsLabel == null) ? 'Test Form Label' + uniqueNumber : formsLabel;
        salesTaxItem.Active__c = true; 
        salesTaxItem.Category__c = categoryId;
        salesTaxItem.Tax_Parts__c = isTaxPart;
        return salesTaxItem;
    }
    
    public static Sales_Tax_Item__c createSalesTaxItem(String salesTaxItemName, Decimal rate, String formsLabel, String categoryId, Boolean isTaxPart){
        Sales_Tax_Item__c salesTaxItem = sampleSalesTaxItem(salesTaxItemName, rate, formsLabel, categoryId, isTaxPart);
        insert salesTaxItem;
        return salesTaxItem;
    }
    
    public static QB_Tax_Rate__c sampleQBTaxRate(){
        QB_Tax_Rate__c taxRateRec = new QB_Tax_Rate__c();
        taxRateRec.Name = 'TaxRate';
        taxRateRec.Rate_Value__c = 5;
        taxRateRec.Accounting_Id__c = '' + 0 + '';
        taxRateRec.Is_Active__c = true;
        return taxRateRec;
    }
    
    public static QB_Tax_Rate__c createQBTaxRate(){
        QB_Tax_Rate__c taxRateRec = sampleQBTaxRate();
        insert taxRateRec;
        return taxRateRec;
    }
    
    public static QB_TaxCode__c sampleQBTaxCode(){
        QB_TaxCode__c qbSalesTaxCode = new QB_TaxCode__c();
        qbSalesTaxCode.Name = 'TaxCode';
        qbSalesTaxCode.Is_Active__c = true;
        qbSalesTaxCode.Is_Taxable__c = true;
        qbSalesTaxCode.Accounting_Id__c = ''+ 0 + '';
        qbSalesTaxCode.Applicable_QB_Tax_Rates__c = ''+ 0 + '';
        qbSalesTaxCode.Tax_Applicable_On__c = 'Sales';
        return qbSalesTaxCode;
    }
    
    public static QB_TaxCode__c createQBTaxCode() {
        QB_TaxCode__c qbSalesTaxCode = sampleQBTaxCode();
        insert qbSalesTaxCode;
        return qbSalesTaxCode;
    }
    
    public static BP_Configurations__c sampleBpConfiguration(){
        BP_Configurations__c bpConfig = new BP_Configurations__c();
        return bpConfig;
    }
    
    public static BP_Configurations__c createBpConfiguration(){
        BP_Configurations__c bpConfig = sampleBpConfiguration();
        insert bpConfig;
        return bpConfig;
    }
    
    public static Reporting__c sampleReporting(){
        Reporting__c reportObj = new Reporting__c();
        reportObj.Is_Reporting__c = true;
        return reportObj;
    }
    
    public static Reporting__c createReporting(){
        Reporting__c reportObj = sampleReporting();
        insert reportObj;
        return reportObj;
    }
    
    public static Recent_Vendor__c sampleRecentVendor(String vendorId){
        Recent_Vendor__c recentVendorRec = new Recent_Vendor__c();
        recentVendorRec.Vendor__c = vendorId;
        return recentVendorRec;
    }
    
    public static Recent_Vendor__c createRecentVendor(String vendorId){
    	Recent_Vendor__c recentVendorRec = sampleRecentVendor(vendorId);
    	insert recentVendorRec;
    	return recentVendorRec;
    }
    
    public static CO_Invoice_Item__c sampleCoInvoiceItem(String categoryId, String coInvoiceHeaderId) {
    	CO_Invoice_Item__c coInvoiceItemObj = new CO_Invoice_Item__c();
    	coInvoiceItemObj.Category__c = categoryId;
    	coInvoiceItemObj.CO_Invoice_Header__c = coInvoiceHeaderId;
    	return coInvoiceItemObj;
    }
    
    public static CO_Invoice_Item__c createCoInvoiceItem(String categoryId, String coInvoiceHeaderId) {
    	CO_Invoice_Item__c coInvoiceItemObj = sampleCoInvoiceItem(categoryId, coInvoiceHeaderId);
    	insert coInvoiceItemObj;
    	return coInvoiceItemObj;
    }
    
    public static Business_Profile__c sampleBusinessProfile(String stateId, String countryId){
    	Business_Profile__c businessProfileObject = new Business_Profile__c();
        businessProfileObject.Business_Street_Address1__c = 'test street1';
        businessProfileObject.Business_Street_Address2__c = 'test street1';
        businessProfileObject.Business_City__c = 'test city'; 
        businessProfileObject.Business_Name__c = 'expectedDealerName';
        businessProfileObject.Business_Postal_Code__c = '302022';
        businessProfileObject.Business_Phone__c = '1235678921';
        businessProfileObject.Business_State__c = stateId;
        businessProfileObject.Business_Country__c = countryId; 
        businessProfileObject.Business_Email__c = 'abc@test.com';
        businessProfileObject.Same_As_Business_Address__c = true;
        businessProfileObject.Shipping_City__c = 'jaipur'; 
	    businessProfileObject.Company_Name_Optional__c = 'Metacube optional';
	    businessProfileObject.Shipping_Country__c = countryId; 
	    businessProfileObject.Shipping_State__c = stateId;
	    businessProfileObject.Shipping_Street_Address1__c = 'street 1';
	    businessProfileObject.Shipping_Street_Address2__c = 'street 2';
	    businessProfileObject.Shipping_Postal_Code__c = '302012';
	    return businessProfileObject;
    }
    
    public static Business_Profile__c createBusinessProfile(String stateId, String countryId){
    	Business_Profile__c businessProfileObject = sampleBusinessProfile(stateId, countryId);
    	insert businessProfileObject;
    	return businessProfileObject;
    }
    
    public static Vendor_Receiving_Header__c sampleVendorReceivingHeader(String vIHeaderId, String vendorId) {
    	Vendor_Receiving_Header__c vRHeaderObj = new Vendor_Receiving_Header__c();
    	vRHeaderObj.In_Progress_VI__c = vIHeaderId;
    	vRHeaderObj.Vendor__c = vendorId;
    	return vRHeaderObj;
    }
    
     public static Vendor_Receiving_Header__c createVendorReceivingHeader(String vIHeaderId, String vendorId) {
    	Vendor_Receiving_Header__c vRHeaderObj = sampleVendorReceivingHeader(vIHeaderId, vendorId);
    	insert vRHeaderObj;
    	return vRHeaderObj;
     }
     
     public static Vendor_Receiving_Group__c sampleVendorReceivingGroup(String vRHeaderId) {
    	Vendor_Receiving_Group__c vRGroupObj = new Vendor_Receiving_Group__c();
    	vRGroupObj.Vendor_Receiving_Header__c = vRHeaderId;
    	return vRGroupObj;
     }
    
     public static Vendor_Receiving_Group__c createVendorReceivingGroup(String vRHeaderId) {
    	Vendor_Receiving_Group__c vRGroupObj = sampleVendorReceivingGroup(vRHeaderId);
    	insert vRGroupObj;
    	return vRGroupObj;
     }
     
     public static String getNamespace(String className) {
        ApexClass testClass  = [Select Id, NamespacePrefix from apexclass where name = :className];
        if(testClass.NamespacePrefix == null){
            return '';
        }
       return testClass.NamespacePrefix+'__';
    }
    
    public static void createNameSpaceInGeneralConfig() {
        General_Configurations__c genConfig = General_Configurations__c.getInstance();
        genConfig.Namespace__c = getNamespace('TestDataFactory');
        insert genConfig;
    }
    
     public static User sampleUser(String email, String lastName, String localeSidKey, String userName, String alias, String timeZoneSidKey) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('User') == false) {throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
        User testUser = new User();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
        testUser.Email = email;
        testUser.LastName = lastName;
        testUser.LocaleSidKey = localeSidKey;
        testUser.Username = userName + Math.round(Math.random()*1000);
        testUser.Alias = alias;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.ProfileId = p.Id;
        testUser.TimeZoneSidKey = timeZoneSidKey;
        testUser.EmailEncodingKey = 'UTF-8';   
        return testUser;
    }
    
    public static User createUser(String email, String lastName, String localeSidKey, String userName, String alias, String timeZoneSidKey) {
        User testUser = sampleUser(email, lastName, localeSidKey, userName, alias, timeZoneSidKey);
        insert testUser;
        return testUser;
    }
    
    public static User_Group__c sampleUserGroup(String name, String userId) {
    	User_Group__c userGroup = new User_Group__c();
		userGroup.name = name;
		userGroup.OwnerId = userId;
		userGroup.Colour_Code__c = 'rgba(255,100,88,1)';
		userGroup.Accounting_settings_export__c = 'Primary';
		userGroup.Costs__c = 'Primary';
		userGroup.Customer_invoicing__c = 'Primary';
		userGroup.customers__c = 'Primary';
		userGroup.Deal__c = 'Primary';
		userGroup.fees__c = 'Primary';
		userGroup.Internal_Service__c = 'Primary';
		userGroup.kits__c = 'Secondary';
		userGroup.labor__c = 'Secondary';
		userGroup.Merchandise__c = 'Primary';
		userGroup.Override_price__c = 'Primary';
		userGroup.Oversell_inventory__c = 'Primary';
		userGroup.parts__c = 'Primary';
		userGroup.Price_file_import__c = 'Secondary';
		userGroup.Price_Levels__c = 'Secondary';
		userGroup.quick_sale__c = 'Secondary';
		userGroup.Returns__c = 'Secondary';
		userGroup.Sales_Taxes__c = 'Secondary';
		userGroup.Service_job__c = 'Secondary';
		userGroup.Special_order__c = 'None';
		userGroup.Special_order__c = 'None';
		userGroup.Special_order__c = 'None';
		userGroup.stock_units__c = 'Secondary';
		userGroup.System_Settings__c = 'Primary';
		userGroup.Vendor_invoicing__c = 'Primary';
		userGroup.Vendor_order__c = 'Primary';
		userGroup.vendor_products__c = 'Primary';
		userGroup.Vendor_receiving__c = 'Primary';
		userGroup.vendors__c = 'Primary';
		return userGroup;
    }
    
    public static User_Group__c createUserGroup(String name, String userId) {
    	User_Group__c userGroup = sampleUserGroup(name, userId);
    	insert userGroup;
    	return userGroup;
    }
     
    public static SO_Payment_Role__c sampleSOPaymentRole(String name, String soHeaderId, String deductibleStatus, Decimal totalAmount){
     	String strRecordTypeId = [Select Id From RecordType Where SobjectType =: Constants.NAMESPACE + 'SO_Payment_Role__c' and Name = :name].Id;
     	SO_Payment_Role__c soPaymentRole = new SO_Payment_Role__c();
     	soPaymentRole.RecordTypeId = strRecordTypeId;
     	soPaymentRole.Service_Order_Header__c = soHeaderId;
     	soPaymentRole.Deductible_Status__c = deductibleStatus;
     	soPaymentRole.Total_Amount__c = totalAmount;
     	return soPaymentRole;
    }
     
    public static SO_Payment_Role__c createSOPaymentRole(String name, String soHeaderId, String deductibleStatus, Decimal totalAmount){
     	SO_Payment_Role__c soPaymentRole = sampleSOPaymentRole(name, soHeaderId, deductibleStatus, totalAmount);
     	insert soPaymentRole;
        return soPaymentRole;
    }
     
    public static Vendor_Order_Line_Item__c sampleVendorOrderLineItem(String voHeaderId) {
        Vendor_Order_Line_Item__c vOLineItem = new Vendor_Order_Line_Item__c();
        vOLineItem.Vendor_Order_Header__c = voHeaderId;
        return 	vOLineItem;
    }
     
    public static Vendor_Order_Line_Item__c createVendorOrderLineItem(String voHeaderId) {
        Vendor_Order_Line_Item__c vOLineItem  = sampleVendorOrderLineItem(voHeaderId);
        insert vOLineItem;
        return vOLineItem;
    }
     
    public static Activity_History__c sampleActivityHistory() {
        Activity_History__c activityHistory = new Activity_History__c();
        return 	activityHistory;
    }
     
    public static Activity_History__c createActivityHistory() {
        Activity_History__c activityHistory  = sampleActivityHistory();
        insert activityHistory;
        return activityHistory;
    }
     
    public static Part_Alternates__c samplePartReverseAlternates(String alternatePartId, String partId, String relation) {
        if(!Test.isRunningTest() && AccessControl.ifObjectFieldIsCreateable('Part_Alternates__c') == false) {throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE);}
        Part_Alternates__c partAlternates = new Part_Alternates__c();       
        partAlternates.Alternate_Part_ID__c = PartId;
        partAlternates.Part_ID__c = alternatePartId;
        partAlternates.Relation__c = relation;
        partAlternates.Alternate_Preferred__c = true;
        return partAlternates;
    }
    
    public static Part_Alternates__c createPartReverseAlternates(String alternatePartId, String partId, String relation) {
    	Part_Alternates__c partAlternates = samplePartReverseAlternates(alternatePartId, partId, relation);
    	insert partAlternates;
    	return partAlternates;
    }
    
    public static Configurations__c sampleConfigurations() {
    	Configurations__c taxSetting = Configurations__c.getOrgDefaults();
    	return taxSetting;
    }
    
    public static Configurations__c createConfigurations() {
    	Configurations__c taxSetting = sampleConfigurations();
    	insert taxSetting;
    	return taxSetting;
    }
    
    public static Deal_Unit_Price_Cost__c sampleDealUnitPriceCost(String typeOfDeal, Integer quantity, Decimal price) {
    	Deal_Unit_Price_Cost__c dealUnitPrice = new Deal_Unit_Price_Cost__c();
    	dealUnitPrice.Type__c = typeOfDeal;
    	dealUnitPrice.Qty__c = quantity;
    	dealUnitPrice.Price__c = price;
    	return dealUnitPrice;
    }
    
    public static Deal_Unit_Price_Cost__c createDealUnitPriceCost(String typeOfDeal, Integer quantity, Decimal price) {
    	Deal_Unit_Price_Cost__c dealUnitPrice = sampleDealUnitPriceCost(typeOfDeal, quantity, price);
    	insert dealUnitPrice;
    	return dealUnitPrice;
    }
    
    public static Option_Fee__c sampleOptionFee(String dealItemRecId, String partId, Integer quantity) {
    	Option_Fee__c optionFee = new Option_Fee__c();
    	optionFee.Deal_Item__c = dealItemRecId;
    	optionFee.Part__c = partId;
    	optionFee.Qty__c = quantity;
    	return optionFee;
    }
    
    public static Option_Fee__c createOptionFee(String dealItemRecId, String partId, Integer quantity) {
    	Option_Fee__c optionFee = sampleOptionFee(dealItemRecId, partId, quantity);
    	insert optionFee;
    	return optionFee;
    }
    
    public static AutoNumberHolder__c sampleAutoNumberHolder() {
    	AutoNumberHolder__c autoNumber = new AutoNumberHolder__c();
    	return autoNumber;
    }
    
    public static AutoNumberHolder__c createAutoNumberHolder() {
    	AutoNumberHolder__c autoNumber = sampleAutoNumberHolder();
    	insert autoNumber;
    	return autoNumber;
    }
    
    public static Individual_Tax__c sampleIndividualTax(String name, Decimal tax) {
    	Individual_Tax__c individualTax = new Individual_Tax__c();
    	individualTax.Sales_Tax_Item_Name__c = name;
    	individualTax.Tax_Rate__c = tax;
    	return individualTax;
    }
    
    public static Individual_Tax__c createIndividualTax(String name, Decimal tax) {
    	Individual_Tax__c individualTax = sampleIndividualTax(name, tax);
    	insert individualTax;
    	return individualTax;
    }
    
    public static Service_Order_Kit_Header__c sampleSOKitHeader(String code){
    	Service_Order_Kit_Header__c soKitHeader = new Service_Order_Kit_Header__c();
		soKitHeader.Can_Split__c = true;
		soKitHeader.Service_Kit__c = true;
		soKitHeader.Code__c = code;
		soKitHeader.Fixed_Price__c = 100;
		soKitHeader.Is_Fixed_Kit_Header_SO__c = true; 
		soKitHeader.Fixed_Price_Flag__c = true;
    	return soKitHeader;
    }
    
    public static Service_Order_Kit_Header__c createSOKitHeader(String code){
    	Service_Order_Kit_Header__c soKitHeader = sampleSOKitHeader(code);
    	insert soKitHeader;
    	return soKitHeader;
    }
    
    public static F_I_Product__c sampleFIProduct(String dealId){
    	F_I_Product__c fIProduct = new F_I_Product__c();	
    	fIProduct.Deal__c = dealId;
    	return fIProduct;
    }
    
    public static F_I_Product__c createFIProduct(String dealId){
    	F_I_Product__c fIProduct = sampleFIProduct(dealId);
    	insert fIProduct;
    	return fIProduct;
    }
    
    public static CO_Kit_Header__c sampleCOKitHeader(String coHeaderId){
    	CO_Kit_Header__c coKitHeader = new CO_Kit_Header__c();
    	coKitHeader.CO_Header__c = coHeaderId;
    	return coKitHeader;
    }
    
    public static CO_Kit_Header__c createCOKitHeader(String coHeaderId){
    	CO_Kit_Header__c coKitHeader = sampleCOKitHeader(coHeaderId);
    	insert coKitHeader;
    	return coKitHeader;
    }
    
    public static Transaction_Type__c sampleTransactionType(String code, String type){
    	Transaction_Type__c transactionType = new Transaction_Type__c();
        transactionType.Code__c = Code;
        transactionType.Type__c = Type;
        return transactionType;
    }
    
    public static Transaction_Type__c createTransactionType(String code, String type){
    	Transaction_Type__c transactionType = sampleTransactionType(code, type);
    	insert transactionType;
    	return transactionType;
    }
    
    public static IFW_IntegrationConfig__c sampleIFWConfigForXero(){
        IFW_IntegrationConfig__c IFWConfigObj = new IFW_IntegrationConfig__c();
        IFWConfigObj.Integration_Name__c = 'Xero';
        IFWConfigObj.Auth_Scheme__c = 'OAuth1.0';
        IFWConfigObj.Bearer_Token__c = 'Xero';
        IFWConfigObj.Certificate_Name__c = 'XeroCertificate';
        IFWConfigObj.Enabled__c = true;  
        IFWConfigObj.Consumer_Key__c ='CH6SWMBW9G14BQK09TMVKMJ6BGP0BO';
        IFWConfigObj.Consumer_Secret__c ='MRYY4BJQSCXOO5REKHKWHWGHDLXQ8G';
        IFWConfigObj.Password__c ='Welcome@123';
        IFWConfigObj.Subscriber_Rec_Id__c ='a2G1K';
        IFWConfigObj.Timeout__c = 5000;
        IFWConfigObj.Username__c ='richa.mittal@metacube.com';
        return IFWConfigObj;
    }
    
    public static IFW_IntegrationConfig__c createIFWConfigForXero(){
        IFW_IntegrationConfig__c IFWConfigObj = sampleIFWConfigForXero();
        insert IFWConfigObj;
        return IFWConfigObj;
    }
    
    public static IFW_IntegrationConfigItem__c sampleIFWConfigItemForXero(String IFWConfigObjId){
    	IFW_IntegrationConfigItem__c IFWConfigItemObj = new IFW_IntegrationConfigItem__c();
        IFWConfigItemObj.Endpoint_URL__c = 'https://api.xero.com/api.xro/2.0/ManualJournals';
        IFWConfigItemObj.HTTP_Method__c = 'POST';
        IFWConfigItemObj.Timeout__c = 5000;
        IFWConfigItemObj.IFW_IntegrationConfig__c = IFWConfigObjId;
        IFWConfigItemObj.Subscriber_Record_Id__c = 'a2G1K000003YyYkUAK';
        IFWConfigItemObj.Entity_Name__c = 'Journal Entry';
        IFWConfigItemObj.Entity_Action__c = 'Create;Update';
        return IFWConfigItemObj;
    }
    
    public static IFW_IntegrationConfigItem__c createIFWConfigItemForXero(String IFWConfigObjId){
    	IFW_IntegrationConfigItem__c IFWConfigItemObj = sampleIFWConfigItemForXero(IFWConfigObjId);
    	insert IFWConfigItemObj;
    	return IFWConfigItemObj;
    }
}