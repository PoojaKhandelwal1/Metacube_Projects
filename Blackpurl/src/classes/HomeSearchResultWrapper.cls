/**
 * Author: Tarun Khandelwal
 * Since: March 10, 2016
 * Name: HomeSearchResultWrapper
 * Description: Apex class which gives JSON format for searched result
**/
public with sharing class HomeSearchResultWrapper {
    public static ResultWrapper result;
    
    /** 
     * Name: getJSONForSObjectRecords 
     * Description: Method used to get search records JSON String
     * @param: 1. List<sObject> records : Searched Sobject record  
     *         2. String objName : Searched Object Name
     *         3. Integer totalRecordsFound : Count of searched Records
     *         4. List<HomeSearchFilterInterface.FilterLabel> filterLabelList - List of filter labels applied on UI.
     * @return: String 
     */
    public static String getJSONForSObjectRecords(List<sObject> records, String objName, Integer totalRecordsFound, List<HomeSearchFilterInterface.FilterLabel> filterLabelList,
    				 Boolean isIncludeInactiveRecords, Boolean isSummaryFormat, Set<String> searchNameSet) {
        return getJSONForSObjectRecords(records, objName, totalRecordsFound, filterLabelList, true, isIncludeInactiveRecords, isSummaryFormat, searchNameSet);
    }  
    
    /** 
     * Name: getJSONForSObjectRecords 
     * Description: Method used to get search records JSON String
     * @param: 1. List<sObject> records : Searched Sobject record 
     *         2. String objName : Searched Object Name
     *         3. Integer totalRecordsFound : Count of searched Records
     *         4. List<HomeSearchFilterInterface.FilterLabel> filterLabelList - List of filter labels applied on UI.
     * @return: String
     */
    public static String getJSONForSObjectRecords(  List<sObject> records, 
                                                    String objName, 
                                                    Integer totalRecordsFound, 
                                                    List<HomeSearchFilterInterface.FilterLabel> filterLabelList,
                                                    boolean ifToSerialzeResult, Boolean isIncludeInactiveRecords,
                                                    Boolean isSummaryFormat,
                                                    Set<String> searchNameSet
                                                ) {
                                                
        if(objName == 'Customers') {
            List<Customer> customerRecords = new List<Customer>();
            for(Account acc : (List<Account>)records) {
                customerRecords.add(new Customer(acc));
            }
            result = new ResultWrapper(totalRecordsFound, 'CustomerRecords');
            result.CustomerRecords = customerRecords;
            
        } else if(objName == 'Vendors') {
            List<Vendor> vendorRecords = new List<Vendor>();
            for(Account acc : (List<Account>)records){
                vendorRecords.add(new Vendor(acc));
            }
            result = new ResultWrapper(totalRecordsFound, 'VendorRecords');
            result.VendorRecords = vendorRecords;
        
        } else if(objName == 'People') {
            List<People> peopleRecords = new List<People>();
            for(Account acc : (List<Account>)records){
                peopleRecords.add(new People(acc));
            }
            result = new ResultWrapper(totalRecordsFound, 'PeopleRecords');
            result.PeopleRecords = peopleRecords;
            
        } else if(objName == 'Parts') {
            List<Part> partRecords = new List<Part>();
            for(Part__c partRec : (List<Part__c>)records) {
                partRecords.add(new Part(partRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'PartRecords');
            result.PartRecords = partRecords;
            
        } else if(objName == 'Kits') {
            List<KitHeader> kitRecords = new List<KitHeader>();
            for(Kit_Header__c kitHeaderRec : (List<Kit_Header__c>)records) {
                kitRecords.add(new KitHeader(kitHeaderRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'KitRecords');
            result.KitRecords = kitRecords;
            
        } else if(objName == 'Fees') {
            List<Fee> feeRecords = new List<Fee>();
            for(Fee__c feeRec : (List<Fee__c>)records) {
                feeRecords.add(new Fee(feeRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'FeeRecords');
            result.FeeRecords = feeRecords;
            
        } else if(objName == 'Labor Codes') {
            List<LabourCode> labourRecords = new List<LabourCode>();
            for(Labour_Code__c labourRec : (List<Labour_Code__c>)records) {
                labourRecords.add(new LabourCode(labourRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'LabourRecords');
            result.LabourRecords = labourRecords;
        
        } /*else if(objName == 'Sublets') {
            List<VendorProduct> vendorProductRecords = new List<VendorProduct>();
            for(Product__c subletRec : (List<Product__c>)records) {
                vendorProductRecords.add(new VendorProduct(subletRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'SubletRecords');
            result.SubletRecords = vendorProductRecords;
            
        }*/ else if(objName == 'Vendor Product') {
            List<VendorProduct> vendorProductRecords = new List<VendorProduct>();
            for(Product__c vendorProductRec : (List<Product__c>)records) {
                vendorProductRecords.add(new VendorProduct(vendorProductRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'VendorProductRecords');
            result.VendorProductRecords = vendorProductRecords;
            
        } else if(objName == 'Products') {
            List<Product> productRecords = new List<Product>();
            for(Sobject sobjRec : records) {
                productRecords.add(new Product(sobjRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'ProductRecords');
            result.ProductRecords = productRecords;
            
        } else if(objName == 'Customer Orders') {
            List<CustomerOrders> customerOrdersRecords = new List<CustomerOrders>();
            for(CO_Header__c coHeaderRec : (List<CO_Header__c>)records) {
                customerOrdersRecords.add(new CustomerOrders(coHeaderRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'CustomerOrderRecords');
            result.CustomerOrderRecords = customerOrdersRecords;
            
        } else if(objName == 'Customer Invoices') {
            List<CustomerInvoice> customerInvoiceRecords = new List<CustomerInvoice>();
            for(CO_Invoice_Header__c coInvoiceHeaderRec : (List<CO_Invoice_Header__c>)records) {
                customerInvoiceRecords.add(new CustomerInvoice(coInvoiceHeaderRec));
            }
            //System.assert(false, records);
            result = new ResultWrapper(totalRecordsFound, 'CustomerInvoiceRecords');
            result.CustomerInvoiceRecords = customerInvoiceRecords;
            
        } else if(objName == 'Customer Payments') {
            List<CO_Invoice_Payment__c> coInvoicePaymentList = new List<CO_Invoice_Payment__c>();
            List<CO_Deposit__c> coDepositList = new List<CO_Deposit__c>();
            List<CustomerPayment> customerPaymentAndDepositRecords = new List<CustomerPayment>();
            
            for(Sobject sobj : records) {
                if(sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Invoice_Payment__c') {
                    customerPaymentAndDepositRecords.add(new CustomerPayment((CO_Invoice_Payment__c)sobj));
                } else {
                    if(sobj.get(Constants.NAMESPACE + 'Payment_Method__c') != null && 
                        String.valueOf(sobj.get(Constants.NAMESPACE + 'Payment_Method__c')) != 'Invoice') {
                        customerPaymentAndDepositRecords.add(new CustomerPayment((CO_Deposit__c)sobj));
                    }
                }
            }
            
            result = new ResultWrapper(totalRecordsFound, 'CustomerPaymentRecords');
            result.CustomerPaymentRecords = customerPaymentAndDepositRecords;
            
        } /*else if(objName == 'Customer Deposits') {
            system.assert(false, records);
            for(CO_Deposit__c coDepositRec : (List<CO_Deposit__c>)records) {
                customerPaymentAndDepositRecords.add(new CustomerPayment(coDepositRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'CustomerPaymentRecords');
            result.CustomerPaymentRecords = customerPaymentAndDepositRecords;
            
        } */else if(objName == 'Customer Sales') {
            List<CustomerSales> customerSalesRecords = new List<CustomerSales>();
            Set<String> iteratedIdSet = (searchNameSet.contains('Parts Order')) ? new Set<String>() : null;
            for(Sobject sobjRec : records) {
            	if(searchNameSet.contains('Parts Order')) {
            		String Id = String.valueOf(sobjRec.get('Id'));
            		String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            		
            		if(objectName == Constants.NAMESPACE + 'CO_Header__c' && sobjRec.get(Constants.NAMESPACE +'CO_Type__c') != Constants.INTERNAL_SERVICE &&
            				!Boolean.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Hide_Merchandise_Section__c'))) && 
            				!iteratedIdSet.contains(Id)) {
            			customerSalesRecords.add(new CustomerSales(sobjRec, 'Parts Order'));
            			iteratedIdSet.add(Id);
            		} else {
		                customerSalesRecords.add(new CustomerSales(sobjRec));
		            }
            	} else {
            		customerSalesRecords.add(new CustomerSales(sobjRec));
            	}
            }
            result = new ResultWrapper(totalRecordsFound, 'CustomerSalesRecords');
            result.CustomerSalesRecords = customerSalesRecords;
            
        } else if(objName == 'Vendor Orders') {
            /*List<VendorOrder> vendorOrderRecords = new List<VendorOrder>();
            for(Vendor_Order_Header__c vendorOrderRec : (List<Vendor_Order_Header__c>)records) {
                vendorOrderRecords.add(new VendorOrder(vendorOrderRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'VendorOrderRecords');
            result.VendorOrderRecords = vendorOrderRecords;*/
            List<VendorOrder> vendorOrderAndReturnVORecords = new List<VendorOrder>();
            
            for(Sobject sobj : records) {
                if(sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Vendor_Order_Header__c') {
                    vendorOrderAndReturnVORecords.add(new VendorOrder((Vendor_Order_Header__c)sobj));
                } else {
                    vendorOrderAndReturnVORecords.add(new VendorOrder((Return_VO_Header__c)sobj));
                }
            }
            
            result = new ResultWrapper(totalRecordsFound, 'VendorOrderRecords');
            result.VendorOrderRecords = vendorOrderAndReturnVORecords;
            
        } else if(objName == 'Vendor Invoices') {
            List<VendorInvoice> vendorInvoiceRecords = new List<VendorInvoice>();
            for(Vendor_Invoicing_Header__c vendorInvoiceRec : (List<Vendor_Invoicing_Header__c>)records) {
                vendorInvoiceRecords.add(new VendorInvoice(vendorInvoiceRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'VendorInvoiceRecords');
            result.VendorInvoiceRecords = vendorInvoiceRecords;
            
        } else if(objName == 'Vendor Receivings') {
            List<VendorRecieving> vendorRecievingRecords = new List<VendorRecieving>();
            for(Vendor_Receiving_Header__c vendorRecievingRec : (List<Vendor_Receiving_Header__c>)records) {
                vendorRecievingRecords.add(new VendorRecieving(vendorRecievingRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'VendorRecievingRecords');
            result.VendorRecievingRecords = vendorRecievingRecords;
            
        } else if(objName == 'Vendor Ordering') {
            List<VendorOrdering> vendorOrderingRecords = new List<VendorOrdering>();
            for(Sobject sobjRec : records) {
                vendorOrderingRecords.add(new VendorOrdering(sobjRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'VendorOrderingRecords');
            result.VendorOrderingRecords = vendorOrderingRecords;

        } else if(objName == 'Item Categories') {
            List<Category> CategoryRecords = new List<Category>();
            for(Category__c sobjRec : (List<Category__c>)records) {
                CategoryRecords.add(new Category(sobjRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'CategoryRecords');
            result.CategoryRecords = CategoryRecords;

        } else if(objName == 'Price Levels') {
            List<PriceLevel> PriceLevelRecords = new List<PriceLevel>();
            for(Price_Level__c sobjRec : (List<Price_Level__c>)records) {
                PriceLevelRecords.add(new PriceLevel(sobjRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'PriceLevelRecords');
            result.PriceLevelRecords = PriceLevelRecords;

        } else if(objName == 'Sales Taxes') {
            List<SalesTax> SalesTaxRecords = new List<SalesTax>();
            for(Sales_Tax__c sobjRec : (List<Sales_Tax__c>)records) {
                SalesTaxRecords.add(new SalesTax(sobjRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'SalesTaxRecords');
            result.SalesTaxRecords = SalesTaxRecords;

        } else if(objName == 'Setting') {
            List<Setting> SettingRecords = new List<Setting>();
            for(Sobject sobjRec : records) {
                SettingRecords.add(new Setting(sobjRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'SettingRecords');
            result.SettingRecords = SettingRecords;

        } else if(objName == 'Users') {
            List<UserRec> UserRecords = new List<UserRec>();
            for(User userRecord : (List<User>)records) {
                UserRecords.add(new UserRec(userRecord));
            }
            result = new ResultWrapper(totalRecordsFound, 'UserRecords');
            result.UserRecords = UserRecords;
            
        } else if(objName == 'Parts Needed') { // Dinesh Kumar 10/10/2016
            List<PartNeeded> PartNeededRecords = new List<PartNeeded>();
            
            // Special case : Need Business Profile Detail - Added by TK - 10/14/2016
            List<Business_Profile__c> dealerInfoList = [select Business_Name__c from Business_Profile__c limit 1];
            Business_Profile__c dealerInfoRec;
            if(dealerInfoList.size() > 0) {
                dealerInfoRec = dealerInfoList[0]; 
            } else {
                dealerInfoRec = new Business_Profile__c();
            }
            
            for(Vendor_Order_Line_Item__c PartNeededRecord : (List<Vendor_Order_Line_Item__c>)records) {
                PartNeededRecords.add(new PartNeeded(PartNeededRecord, dealerInfoRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'PartNeededRecords');
            result.PartNeededRecords = PartNeededRecords;

        } else if(objName == 'Service Jobs') {
            List<ServiceJob> ServiceJobs = new List<ServiceJob>();
            for(Service_Order_Header__c soHeaderRec : (List<Service_Order_Header__c>)records) {
                ServiceJobs.add(new ServiceJob(soHeaderRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'ServiceJobs');
            result.ServiceJobs = ServiceJobs;
            
        } else if(objName == 'Part FIFO') {
           result = new ResultWrapper(totalRecordsFound, 'PartMovementRecords');
           result.PartMovementRecords = new List<PartMovement>();
           result.PartMovementRecords.addAll(getPartMovementRecordsFromPartFIFO(records));
        
        } else if(objName == 'Tax Detail') {
           result = new ResultWrapper(totalRecordsFound, 'TaxDetailRecords');
           result.TaxDetailRecords = new List<TaxReporting>();
           result.TaxDetailRecords.addAll(getTaxReportingFromInvoiceHeader(records));
           
        } else if(objName == 'Invoiced Items') {
            List<InvoicedItems> invoiceItems = new List<InvoicedItems>();
            
            if(isSummaryFormat != null && isSummaryFormat) {
                List<CO_Line_Item__c> coliRecList = new List<CO_Line_Item__c>();
                List<Service_Order_Line_Item__c> soliRecList = new List<Service_Order_Line_Item__c>();
                List<Option_Fee__c> optionAndFeeRecList = new List<Option_Fee__c>();
                
                Map<String, List<sObject>> entityIdToSobjectListMap = new Map<String, List<sObject>>();
                for(Sobject sobj : records) {
                    Boolean isSOLI = (sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Service_Order_Line_Item__c');
                    Boolean isOptionFee = (sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Option_Fee__c');
                    
                    if(sobj.get(Constants.NAMESPACE + 'Part__c') != null) {
                        String partId = String.valueOf(sobj.get(Constants.NAMESPACE + 'Part__c'));
                        if(!entityIdToSobjectListMap.containsKey(partId)) {
                            entityIdToSobjectListMap.put(partId, new List<sObject>());
                        }
                        entityIdToSobjectListMap.get(partId).add(sobj);
                    } else if(sobj.get(Constants.NAMESPACE + 'Fee__c') != null) {
                        String feeId = String.valueOf(sobj.get(Constants.NAMESPACE + 'Fee__c'));
                        if(!entityIdToSobjectListMap.containsKey(feeId)) {
                            entityIdToSobjectListMap.put(feeId, new List<sObject>());
                        }
                        entityIdToSobjectListMap.get(feeId).add(sobj);
                    } else if((isSOLI || isOptionFee) && sobj.get(Constants.NAMESPACE + 'Labour_Code__c') != null) {
                        String laborId = String.valueOf(sobj.get(Constants.NAMESPACE + 'Labour_Code__c'));
                        if(!entityIdToSobjectListMap.containsKey(laborId)) {
                            entityIdToSobjectListMap.put(laborId, new List<sObject>());
                        }
                        entityIdToSobjectListMap.get(laborId).add(sobj);
                    } else if(isSOLI && sobj.get(Constants.NAMESPACE + 'Sublet__c') != null) {
                        String subletId = String.valueOf(sobj.get(Constants.NAMESPACE + 'Sublet__c'));
                        if(!entityIdToSobjectListMap.containsKey(subletId)) {
                            entityIdToSobjectListMap.put(subletId, new List<sObject>());
                        }
                        entityIdToSobjectListMap.get(subletId).add(sobj);
                    } else if(isOptionFee && sobj.get(Constants.NAMESPACE + 'Product__c') != null) {
                        String productId = String.valueOf(sobj.get(Constants.NAMESPACE + 'Product__c'));
                        if(!entityIdToSobjectListMap.containsKey(productId)) {
                            entityIdToSobjectListMap.put(productId, new List<sObject>());
                        }
                        entityIdToSobjectListMap.get(productId).add(sobj);
                    }
                }
                
                for(String entityId : entityIdToSobjectListMap.keySet()) {
                    invoiceItems.add(new InvoicedItems(entityIdToSobjectListMap.get(entityId)));
                }
                
            } else {
                for(Sobject sobj : records) {
                    if(sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Line_Item__c') {
                        invoiceItems.add(new InvoicedItems((CO_Line_Item__c)sobj));
                    } else if(sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Service_Order_Line_Item__c') {
                        invoiceItems.add(new InvoicedItems((Service_Order_Line_Item__c)sobj));
                    }  else if(sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Option_Fee__c') {
                        invoiceItems.add(new InvoicedItems((Option_Fee__c)sobj));
                    }
                }
            }
            result = new ResultWrapper(totalRecordsFound, 'InvoicedItems');
            result.InvoicedItems = invoiceItems;
                
        } else if(objName == 'Technician Hours') {
            List<TechnicianHours> technicianHoursList = new List<TechnicianHours>();
            for(Hours_Logged__c hoursLoggedRec : (List<Hours_Logged__c>)records) {
                technicianHoursList.add(new TechnicianHours(hoursLoggedRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'TechnicianHourRecords');
            result.TechnicianHourRecords = technicianHoursList;
            
        } else if(objName == 'Payroll Hours') {
            List<PayrollHours> payrollHoursList = new List<PayrollHours>();
            for(Payroll_Time__c payrollHourRec : (List<Payroll_Time__c>)records) {
                payrollHoursList.add(new PayrollHours(payrollHourRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'PayrollHourRecords');
            result.PayrollHourRecords = payrollHoursList;
            
        } else if(objName == 'Technician Performance') {
            List<TechnicianPerformance> technicianPerformanceList = new List<TechnicianPerformance>();
            for(Technician__c technicianRec : (List<Technician__c>)records) {
                if(technicianRec.Payroll_Times__r.size() > 0 || technicianRec.Hours_Logged__r.size() > 0) {
                    technicianPerformanceList.add(new TechnicianPerformance(technicianRec));
                }
            }
            result = new ResultWrapper(totalRecordsFound, 'TechnicianPerformanceRecords');
            result.TechnicianPerformanceRecords = technicianPerformanceList;
            
        } else if(objName == 'Inventory Unit') {
            List<InventoryUnit> unitList = new List<InventoryUnit>();
            for(Customer_Owned_Unit__c unitRec : (List<Customer_Owned_Unit__c>)records) {
                unitList.add(new InventoryUnit(unitRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'InventoryUnits');
            result.InventoryUnits = unitList;
        //END: Added by Nidhi - #1152 - 19-10-2016
        
        } else if(objName == 'Customer Unit') {
            List<CustomerUnit> customerUnitList = new List<CustomerUnit>();
            for(Customer_Owned_Unit__c unitRec : (List<Customer_Owned_Unit__c>)records) {
                customerUnitList.add(new CustomerUnit(unitRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'CustomerUnits');
            result.CustomerUnits = customerUnitList;
        
        }else if(objName == 'Unit Deals') {
            List<UnitDeal> unitDealList = new List<UnitDeal>();
            for(Deal__c unitDealRec : (List<Deal__c>)records) {
                unitDealList.add(new UnitDeal(unitDealRec));
            }
            result = new ResultWrapper(totalRecordsFound, 'UnitDealRecords');
            result.UnitDealRecords = unitDealList;
        
        }else if(objName == 'Deal Units') {
            List<DealUnit> dealUnitList = new List<DealUnit>();
            for(Deal_Item__c dealUnitRec : (List<Deal_Item__c>)records) {
                dealUnitList.add(new DealUnit(dealUnitRec));
            }
            
            result = new ResultWrapper(totalRecordsFound, 'DealUnitRecords');
            result.DealUnitRecords = dealUnitList;
            //system.assert(false,result);
        
        } else if(objName == 'Parts Order') {
            List<PartsOrder> partsOrderList = new List<PartsOrder>();
            for(CO_Header__c coHeaderRec : (List<CO_Header__c>)records) {
                partsOrderList.add(new PartsOrder(coHeaderRec));
            }
            
            result = new ResultWrapper(totalRecordsFound, 'PartsOrderRecords');
            result.PartsOrderRecords = partsOrderList;
            //system.assert(false,result);
        
        } else if(objName == Label.Generic_Object_Label) {
            List<AnyObject> anyObjectRecords = new List<AnyObject>();
            Set<String> iteratedIdSet = (searchNameSet.contains('Parts Order')) ? new Set<String>() : null;
            for(Sobject sobjRec : records) {
            	if(searchNameSet.contains('Parts Order')) {
            		String Id = String.valueOf(sobjRec.get('Id'));
            		String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            		
            		if(objectName == Constants.NAMESPACE + 'CO_Header__c' && !iteratedIdSet.contains(Id)) {
            			anyObjectRecords.add(new AnyObject(sobjRec, 'Parts Order'));
            			iteratedIdSet.add(Id);
            		} else {
                anyObjectRecords.add(new AnyObject(sobjRec));
            }
            	} else {
            		anyObjectRecords.add(new AnyObject(sobjRec));
            	}
            }
            result = new ResultWrapper(totalRecordsFound, 'AnyObjectRecords');
            result.AnyObjectRecords = anyObjectRecords;
            
        } else {
            result = new ResultWrapper(0, 'NoMatchedRecords');
        }
        
        result.FilterLabelList = filterLabelList;
        result.IsIncludeInactiveRecords = isIncludeInactiveRecords;
        result.isSummaryFormat = isSummaryFormat;
        if(ifToSerialzeResult) {
            return System.Json.serialize(result);
        }
        return '';
    }
    
    private static List<TaxReporting> getTaxReportingFromInvoiceHeader(List<sObject> records) {
        List<TaxReporting> taxReportingRecs = new List<TaxReporting>();
        
        Map<String, Map<String,List<Decimal>>> invoiceHeaderToTaxItemMap = getTaxReportingTaxItemFields(records);
        for(sObject record : records) {
            if(record.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Vendor_Invoicing_Header__c') {
                taxReportingRecs.add(new TaxReporting((Vendor_Invoicing_Header__c) record));
            } else if(record.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Invoice_Header__c') {
                taxReportingRecs.add(new TaxReporting((CO_Invoice_Header__c)record, (invoiceHeaderToTaxItemMap.containsKey(record.Id) ? 
                                                                        invoiceHeaderToTaxItemMap.get(record.Id) :
                                                                           new Map<String, List<Decimal>>())));
            }
        }
        return taxReportingRecs;
    }
    
    private static Map<String, Map<String,List<Decimal>>> getTaxReportingTaxItemFields(List<SObject> invoiceList) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        if(AccessControl.ifObjectFieldIsAccessible('CO_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Line_Item__c> coliList = [SELECT Invoice_Number__c, 
                                               (SELECT Sales_Tax_Item_Name__c, Taxable_Amount__c, Tax_Amount__c,Tax_Rate__c FROM Individual_Taxes__r) 
                                           FROM CO_Line_Item__c WHERE Invoice_Number__c IN: invoiceList ORDER BY Invoice_Number__c];
        
        if(AccessControl.ifObjectFieldIsAccessible('Service_Order_Line_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Service_Order_Line_Item__c> soliList = [SELECT Service_Order_Header__r.Invoice_Number__c,(SELECT Sales_Tax_Item_Name__c,Taxable_Amount__c, Tax_Amount__c,Tax_Rate__c FROM Individual_Taxes__r) FROM Service_Order_Line_Item__c WHERE  Service_Order_Header__r.Invoice_Number__c in :invoiceList AND CO_Line_Item__c = null ORDER BY Service_Order_Header__r.Invoice_Number__c];
        
        if(AccessControl.ifObjectFieldIsAccessible('Option_Fee__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<Option_Fee__c> optionFeeList = [SELECT Deal__r.Invoice_Number__c,(SELECT id,Sales_Tax_Item_Name__c,Taxable_Amount__c, Tax_Amount__c,Tax_Rate__c FROM Individual_Taxes__r) FROM Option_Fee__c WHERE Deal__r.Invoice_Number__c in :invoiceList];
        
        Map<String, Map<String,List<Decimal>>> invoiceHeaderIdToTaxItemDetailMap = new Map<String, Map<String,List<Decimal>>>();
        for(CO_Line_Item__c coliRec : coliList) {
            if(!invoiceHeaderIdToTaxItemDetailMap.containsKey(coliRec.Invoice_Number__c)) {
                invoiceHeaderIdToTaxItemDetailMap.put(coliRec.Invoice_Number__c, new Map<String,List<Decimal>>());
            }
            for(Individual_Tax__c individualTax : coliRec.getSObjects(Constants.NAMESPACE +'Individual_Taxes__r')) {
                if(!invoiceHeaderIdToTaxItemDetailMap.get(coliRec.Invoice_Number__c).containsKey(individualTax.Sales_Tax_Item_Name__c)) {
                    invoiceHeaderIdToTaxItemDetailMap.get(coliRec.Invoice_Number__c).put(individualTax.Sales_Tax_Item_Name__c, new List<Decimal>{0,0});
                }
                invoiceHeaderIdToTaxItemDetailMap.get(coliRec.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[0] += individualTax.Taxable_Amount__c;
                if(isTaxIncludingPricing) {
                    invoiceHeaderIdToTaxItemDetailMap.get(coliRec.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[1] += individualTax.Tax_Amount__c;
                } else {
                    invoiceHeaderIdToTaxItemDetailMap.get(coliRec.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[1] += (individualTax.Taxable_Amount__c * individualTax.Tax_Rate__c) / 100;
                }
            }
        }
        
        for(Service_Order_Line_Item__c soliRec : soliList) {
            if(!invoiceHeaderIdToTaxItemDetailMap.containsKey(soliRec.Service_Order_Header__r.Invoice_Number__c)) {
                invoiceHeaderIdToTaxItemDetailMap.put(soliRec.Service_Order_Header__r.Invoice_Number__c, new Map<String,List<Decimal>>());
            }
            for(Individual_Tax__c individualTax : soliRec.getSObjects(Constants.NAMESPACE +'Individual_Taxes__r')) {
                if(!invoiceHeaderIdToTaxItemDetailMap.get(soliRec.Service_Order_Header__r.Invoice_Number__c).containsKey(individualTax.Sales_Tax_Item_Name__c)) {
                    invoiceHeaderIdToTaxItemDetailMap.get(soliRec.Service_Order_Header__r.Invoice_Number__c).put(individualTax.Sales_Tax_Item_Name__c, new List<Decimal>{0,0});
                }
                invoiceHeaderIdToTaxItemDetailMap.get(soliRec.Service_Order_Header__r.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[0] += individualTax.Taxable_Amount__c;
                if(isTaxIncludingPricing) {
                    invoiceHeaderIdToTaxItemDetailMap.get(soliRec.Service_Order_Header__r.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[1] += individualTax.Tax_Amount__c;
                } else {
                    invoiceHeaderIdToTaxItemDetailMap.get(soliRec.Service_Order_Header__r.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[1] += (individualTax.Taxable_Amount__c * individualTax.Tax_Rate__c) / 100;
                }
            }
        }
        
        for(Option_Fee__c optionFeeRec : optionFeeList) {
            if(!invoiceHeaderIdToTaxItemDetailMap.containsKey(optionFeeRec.Deal__r.Invoice_Number__c)) {
                invoiceHeaderIdToTaxItemDetailMap.put(optionFeeRec.Deal__r.Invoice_Number__c, new Map<String,List<Decimal>>());
            }
            for(Individual_Tax__c individualTax : optionFeeRec.getSObjects(Constants.NAMESPACE +'Individual_Taxes__r')) {
                if(!invoiceHeaderIdToTaxItemDetailMap.get(optionFeeRec.Deal__r.Invoice_Number__c).containsKey(individualTax.Sales_Tax_Item_Name__c)) {
                    invoiceHeaderIdToTaxItemDetailMap.get(optionFeeRec.Deal__r.Invoice_Number__c).put(individualTax.Sales_Tax_Item_Name__c, new List<Decimal>{0,0});
                }
                invoiceHeaderIdToTaxItemDetailMap.get(optionFeeRec.Deal__r.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[0] += individualTax.Taxable_Amount__c;
                if(isTaxIncludingPricing) {
                    invoiceHeaderIdToTaxItemDetailMap.get(optionFeeRec.Deal__r.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[1] += individualTax.Tax_Amount__c;
                } else {
                    invoiceHeaderIdToTaxItemDetailMap.get(optionFeeRec.Deal__r.Invoice_Number__c).get(individualTax.Sales_Tax_Item_Name__c)[1] += (individualTax.Taxable_Amount__c * individualTax.Tax_Rate__c) / 100;
                }
            }
        }
        
        List<Individual_Tax__c> individualTaxList = 
                   [SELECT Sales_Tax_Item_Name__c, Taxable_Amount__c, Tax_Amount__c, Tax_Rate__c, Deal_Item__r.Deal__r.Invoice_Number__c,
                           Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__r.Invoice_Number__c, F_I_Product__r.Deal_Finance__r.Deal__r.Invoice_Number__c
                        FROM Individual_Tax__c
                        WHERE Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__r.Invoice_Number__c IN: invoiceList
                            OR F_I_Product__r.Deal_Finance__r.Deal__r.Invoice_Number__c IN: invoiceList 
                            OR (Deal_Item__r.Deal__r.Invoice_Number__c IN :invoiceList AND Deal_Item__r.Type__c = 'Trade In')];
        
        for(Individual_Tax__c individualTax : individualTaxList) {
            String invoiceId;
            if(individualTax.Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__r.Invoice_Number__c != null) {
                invoiceId = individualTax.Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__r.Invoice_Number__c;
            } else if(individualTax.F_I_Product__r.Deal_Finance__r.Deal__r.Invoice_Number__c != null) {
                invoiceId = individualTax.F_I_Product__r.Deal_Finance__r.Deal__r.Invoice_Number__c;
            } else {
                invoiceId = individualTax.Deal_Item__r.Deal__r.Invoice_Number__c;
            }
            
            if(String.isNotBlank(invoiceId)) {
                if(!invoiceHeaderIdToTaxItemDetailMap.containsKey(invoiceId)) {
                    invoiceHeaderIdToTaxItemDetailMap.put(invoiceId, new Map<String,List<Decimal>>());
                }
                if(!invoiceHeaderIdToTaxItemDetailMap.get(invoiceId).containsKey(individualTax.Sales_Tax_Item_Name__c)) {
                    invoiceHeaderIdToTaxItemDetailMap.get(invoiceId).put(individualTax.Sales_Tax_Item_Name__c, new List<Decimal>{0,0});
                }
                invoiceHeaderIdToTaxItemDetailMap.get(invoiceId).get(individualTax.Sales_Tax_Item_Name__c)[0] += individualTax.Taxable_Amount__c;
                if(isTaxIncludingPricing) {
                    invoiceHeaderIdToTaxItemDetailMap.get(invoiceId).get(individualTax.Sales_Tax_Item_Name__c)[1] += individualTax.Tax_Amount__c;
                } else {
                    invoiceHeaderIdToTaxItemDetailMap.get(invoiceId).get(individualTax.Sales_Tax_Item_Name__c)[1] += (individualTax.Taxable_Amount__c * individualTax.Tax_Rate__c) / 100;
                }
            }
        }
        
        return invoiceHeaderIdToTaxItemDetailMap;
    }
    
    private static Map<String, Map<String,List<Decimal>>> getTaxReportingTaxItemFieldsForVendorInvoiceHeader(List<String> salesTaxList, List<TaxReporting> taxReportingRecsGenerated) {
       Map<String, Sales_Tax_item__c> salesTaxToChildrenSalesTaxItemMap = new Map<String, Sales_Tax_item__c>();    
       List<Applicable_Taxes__c> applicableTaxesRecs = [SELECT Sales_Tax__c,Sales_Tax_Item__c, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c FROM Applicable_Taxes__c WHERE  Sales_Tax__c in :salesTaxList];
        return null;
    }
    
    private static List<PartMovement> getPartMovementRecordsFromPartFIFO(List<sObject> records) {
        List<PartMovement> partMovementItems = new List<PartMovement>();
        Map<String, List<Part_FIFO_Bucket__c>> partIdToFifoBucketsMap = new Map<String, List<Part_FIFO_Bucket__c>>();
        Map<String, List<Part_FIFO_Bucket_Activity_Line_Item__c>> partIdToFifoBucketLineItemsMap = new Map<String, List<Part_FIFO_Bucket_Activity_Line_Item__c>>();
        for(sObject record : records) {
            if(record.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Part_FIFO_Bucket__c') {
                Part_FIFO_Bucket__c fifoBucketRec = (Part_FIFO_Bucket__c) record;
                if(fifoBucketRec.Part__c != null) {
                    if(!partIdToFifoBucketsMap.containsKey(fifoBucketRec.Part__c)) {
                        partIdToFifoBucketsMap.put(fifoBucketRec.Part__c, new List<Part_FIFO_Bucket__c>());
                    }
                    partIdToFifoBucketsMap.get(fifoBucketRec.Part__c).add(fifoBucketRec);
                }
            } else if(record.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Part_FIFO_Bucket_Activity_Line_Item__c') {
                Part_FIFO_Bucket_Activity_Line_Item__c fifoBucketLineItemRec = (Part_FIFO_Bucket_Activity_Line_Item__c) record;
                if(fifoBucketLineItemRec.Part_FIFO_Bucket__r.Part__c != null) {
                    if(!partIdToFifoBucketLineItemsMap.containsKey(fifoBucketLineItemRec.Part_FIFO_Bucket__r.Part__c)) {
                        partIdToFifoBucketLineItemsMap.put(fifoBucketLineItemRec.Part_FIFO_Bucket__r.Part__c, new List<Part_FIFO_Bucket_Activity_Line_Item__c>());
                    }
                    partIdToFifoBucketLineItemsMap.get(fifoBucketLineItemRec.Part_FIFO_Bucket__r.Part__c).add(fifoBucketLineItemRec);
                }
            }
        }
        
        // Query Part record to remove Heap Size issue.
        Map<Id, Part__c> partIdToPartRecordMap = 
            new Map<Id, Part__c>([SELECT Vendor__r.Name, Category__r.Name, Part_Type__c, Location__c, Status__c, Last_Sold__c,
                                         Last_Stocked__c, Auto_reorder_Min__c, Auto_reorder_Max__c, Part_Number__c, Description__c 
                                     FROM Part__c WHERE Id IN: partIdToFifoBucketsMap.keySet()
                                                    OR Id IN: partIdToFifoBucketLineItemsMap.keySet()]);
        
        PartMovement partMovementObject;
        //loop over all parts that have a FIFO bucket object created between the date range
        Decimal openingQty, openingCost, closingQty, closingCost, purchaseQty, purchaseCost, salesQty, salesCost, adjustedQty, adjustedCost, totalSales;
        for(String partId : partIdToFifoBucketsMap.keySet()) {
           List<Part_FIFO_Bucket__c> partFifoBuckets = partIdToFifoBucketsMap.get(partId);
           if(partFifoBuckets.size() > 0) {
               partMovementObject = new PartMovement(partIdToPartRecordMap.containsKey(partId) ? partIdToPartRecordMap.get(partId) : new Part__c());
               openingQty = openingCost = closingQty = closingCost = purchaseQty = purchaseCost = salesQty = salesCost = adjustedQty = adjustedCost = totalSales = 0;
               if(partFifoBuckets[0].Qty_In_Stock_When_Created__c != null) {
                   openingQty = partFifoBuckets[0].Qty_In_Stock_When_Created__c;
                   openingCost = openingQty * 
                        (partFifoBuckets[0].Average_Cost_When_Created__c != null? partFifoBuckets[0].Average_Cost_When_Created__c : 0);
               }
               if(partFifoBuckets[partFifoBuckets.size() - 1] != null && partFifoBuckets[partFifoBuckets.size() - 1].Qty_In_Stock_When_Created__c != null) {
                   partFifoBuckets[partFifoBuckets.size() - 1].Qty_In__c = partFifoBuckets[partFifoBuckets.size() - 1].Qty_In__c != null ? partFifoBuckets[partFifoBuckets.size() - 1].Qty_In__c : 0;
                    partFifoBuckets[partFifoBuckets.size() - 1].Average_Cost_When_Created__c = partFifoBuckets[partFifoBuckets.size() - 1].Average_Cost_When_Created__c != null? partFifoBuckets[partFifoBuckets.size() - 1].Average_Cost_When_Created__c : 0.0;
                    partFifoBuckets[partFifoBuckets.size() - 1].Cost__c = partFifoBuckets[partFifoBuckets.size() - 1].Cost__c != null ? partFifoBuckets[partFifoBuckets.size() - 1].Cost__c : 0;
                   closingQty = partFifoBuckets[partFifoBuckets.size() - 1].Qty_In_Stock_When_Created__c + (partFifoBuckets[partFifoBuckets.size() - 1].Qty_In__c);
                   closingCost = (closingQty == 0 ? 0 : (partFifoBuckets[partFifoBuckets.size() - 1].Qty_In_Stock_When_Created__c * partFifoBuckets[partFifoBuckets.size() - 1].Average_Cost_When_Created__c)
                        + (partFifoBuckets[partFifoBuckets.size() - 1].Qty_In__c * partFifoBuckets[partFifoBuckets.size() - 1].Cost__c));
               }
               for(Part_FIFO_Bucket__c fifoBucketObject : partFifoBuckets) {
                   //stores  qty values for current fifo bucket object in iteration 
                   Decimal partFifoBucketQtyIn = 0;
                   fifoBucketObject.Cost__c = fifoBucketObject.Cost__c != null ? fifoBucketObject.Cost__c : 0;
                   partFifoBucketQtyIn =  fifoBucketObject.Qty_In__c != null ? fifoBucketObject.Qty_In__c : 0;
                   
                   //Purchase Qty & Cost
                   if(fifoBucketObject.Source_Name__c == 'Vendor Receiving' || fifoBucketObject.Source_Name__c == 'Vendor Invoice') {
                       purchaseQty += partFifoBucketQtyIn;
                       purchaseCost += partFifoBucketQtyIn * fifoBucketObject.Cost__c;
                   } 
                   //Sales QTy & cost
                   else if(fifoBucketObject.Source_Name__c == 'Customer Return' || fifoBucketObject.Source_Name__c == 'Oversold') {
                       salesQty -= partFifoBucketQtyIn;
                       salesCost -= (partFifoBucketQtyIn * fifoBucketObject.Cost__c);
                       List<Coli_Fifo_Line_Item_Junction__c> coliJunction = (List<Coli_Fifo_Line_Item_Junction__c>) fifoBucketObject.getSObjects(Constants.NAMESPACE + 'Coli_Fifo_Line_Items_Junction__r');
                        if(fifoBucketObject.getSObjects(Constants.NAMESPACE + 'Coli_Fifo_Line_Items_Junction__r') != null && fifoBucketObject.getSObjects(Constants.NAMESPACE + 'Coli_Fifo_Line_Items_Junction__r').size() > 0
                            && fifoBucketObject.getSObjects(Constants.NAMESPACE + 'Coli_Fifo_Line_Items_Junction__r')[0].getSObject(Constants.NAMESPACE + 'CO_Line_Item__r') != null) {
                            
                            CO_Line_Item__c coli = (CO_Line_Item__c) (fifoBucketObject.getSObjects(Constants.NAMESPACE + 'Coli_Fifo_Line_Items_Junction__r')[0].getSObject(Constants.NAMESPACE + 'CO_Line_Item__r'));
                            totalSales -= ((coli.Price__c != null) ? (partFifoBucketQtyIn * coli.Price__c) : 0);
                        }
                   }
                   
                   //Adjusted Cost
                   if(FIFOTransaction.sourceNamesForAdjusmentSet.contains(fifoBucketObject.Source_Name__c)) {
                       adjustedQty += partFifoBucketQtyIn;
                       adjustedCost += (partFifoBucketQtyIn * fifoBucketObject.Cost__c);
                   }
               }
               
               
               // Update values for the parts already processed with fifo bucket to include chanegs in value for related activity line items
               if(partIdToFifoBucketLineItemsMap.containsKey(partId)){
                   List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOLineItemsList = partIdToFifoBucketLineItemsMap.get(partId);
                   if(partFIFOLineItemsList.size() > 0) {
                       //update opening cost
                       if(partFIFOLineItemsList[0].CreatedDate < partFifoBuckets[0].CreatedDate && 
                                partFIFOLineItemsList[0].Qty_In_Stock_When_Created__c != null) {
                           openingQty = partFIFOLineItemsList[0].Qty_In_Stock_When_Created__c;
                           openingCost = openingQty * 
                                (partFIFOLineItemsList[0].Average_Cost_When_Created__c != null ? partFIFOLineItemsList[0].Average_Cost_When_Created__c : 0);
                       }
                       
                       //update closing cost 
                       if(partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].CreatedDate >= partFifoBuckets[partFifoBuckets.size()-1].CreatedDate
                            && partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_In_Stock_When_Created__c != null) {
                            partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c = ((partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c != null) ? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c : 0);
                            partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c = ((partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c != null) ? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c : 0); 
                            partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c = partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c != null ? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c 
                                                                    : (partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Part_FIFO_Bucket__r.Cost__c != null? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Part_FIFO_Bucket__r.Cost__c : 0);
                   
                            closingQty = partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_In_Stock_When_Created__c 
                                - (partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c );
                            closingCost = (closingQty == 0 ? 0 : (partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_In_Stock_When_Created__c * partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c ) - (partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c * partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c));
                        }
                        
                        Decimal partFifoBucketLineItemQtyOut;
                        for(Part_FIFO_Bucket_Activity_Line_Item__c fifoBucketActivityLineItemObject : partFIFOLineItemsList) {
                            partFifoBucketLineItemQtyOut = fifoBucketActivityLineItemObject.Qty_Out__c != null ? fifoBucketActivityLineItemObject.Qty_Out__c: 0.0;
                            fifoBucketActivityLineItemObject.Cost__c = fifoBucketActivityLineItemObject.Cost__c != null ? fifoBucketActivityLineItemObject.Cost__c 
                                                                            : (fifoBucketActivityLineItemObject.Part_FIFO_Bucket__r.Cost__c != null? fifoBucketActivityLineItemObject.Part_FIFO_Bucket__r.Cost__c : 0);
                            //// Sales Qty And Cost
                            if(fifoBucketActivityLineItemObject.CO_Invoice_Header__c !=null) {
                               salesQty += partFifoBucketLineItemQtyOut;
                               salesCost += partFifoBucketLineItemQtyOut * fifoBucketActivityLineItemObject.Cost__c;
                               List<Coli_Fifo_Line_Item_Junction__c> coliJunction =(List<Coli_Fifo_Line_Item_Junction__c>)fifoBucketActivityLineItemObject.getSObjects(Constants.NAMESPACE + 'Coli_Fifo_Line_Items_Junction__r');
                               if( coliJunction != null && coliJunction.size() >0) {
                                   CO_Line_Item__c coli = (CO_Line_Item__c) coliJunction[0].getSObject(Constants.NAMESPACE + 'CO_Line_Item__r');
                                   totalSales +=  partFifoBucketLineItemQtyOut * (Decimal) coli.get('Price__c');
                               }
                            }
                            //Adjusted Cost
                            if(FIFOTransaction.referenceNamesForAdjusmentSet.contains(fifoBucketActivityLineItemObject.Reference__c)) {
                               adjustedQty -= partFifoBucketLineItemQtyOut;
                               adjustedCost -= partFifoBucketLineItemQtyOut * fifoBucketActivityLineItemObject.Cost__c;
                            }
                            
                            //Purchase Cost
                            if(fifoBucketActivityLineItemObject.Reference__c == 'Vendor Return') {
                                purchaseQty -= partFifoBucketLineItemQtyOut;
                                purchaseCost -= partFifoBucketLineItemQtyOut * fifoBucketActivityLineItemObject.Cost__c;
                            }
                        }
                   }
               } 
               // set properties for part movement object from above processed data
               partMovementObject.Opening_Value = openingCost;
               partMovementObject.Opening_Qty = openingQty;
               partMovementObject.Closing_Value = closingCost;
               partMovementObject.Closing_Qty = closingQty;
               partMovementObject.Purchased_Qty = purchaseQty;
               partMovementObject.Purchased_Cost = purchaseCost;
               partMovementObject.Sales_Qty = salesQty;
               partMovementObject.Cost_of_Sales = salesCost;
               partMovementObject.Adjusted_Qty = adjustedQty;
               partMovementObject.Adjusted_Cost = adjustedCost;
               partMovementObject.Total_Sales = totalSales;
               
               if(partMovementObject.Opening_Value !=0 ||  partMovementObject.Opening_Qty!=0 || partMovementObject.Closing_Value!=0 
                   || partMovementObject.Closing_Qty !=0 || partMovementObject.Purchased_Qty != 0 || partMovementObject.Purchased_Cost !=0
                   || partMovementObject.Sales_Qty !=0 || partMovementObject.Cost_of_Sales!=0 || partMovementObject.Adjusted_Qty!=0
                   || partMovementObject.Adjusted_Cost != 0 || partMovementObject.Total_Sales != 0) {
                   partMovementItems.add(partMovementObject);
               }
           }
        }
        
        //loop over all parts that do not have a part fifo object in the range
        for(String partId : partIdToFifoBucketLineItemsMap.keySet()) {
            if(!partIdToFifoBucketsMap.containsKey(partId) && partIdToFifoBucketLineItemsMap.get(partId).size() > 0) {
                partMovementObject = new PartMovement(partIdToPartRecordMap.containsKey(partId) ? partIdToPartRecordMap.get(partId) : new Part__c());
                openingQty = openingCost = closingQty = closingCost = purchaseQty = purchaseCost = salesQty = salesCost = adjustedQty = adjustedCost = totalSales = 0.0;
                Decimal partFifoBucketLineItemQtyOut;
                List<Part_FIFO_Bucket_Activity_Line_Item__c> partFIFOLineItemsList = partIdToFifoBucketLineItemsMap.get(partId);
                if(partFIFOLineItemsList.size() > 0 && partFIFOLineItemsList[0].Qty_In_Stock_When_Created__c !=null){
                   openingQty = partFIFOLineItemsList[0].Qty_In_Stock_When_Created__c;
                   openingCost = openingQty * 
                        (partFIFOLineItemsList[0].Average_Cost_When_Created__c != null? partFIFOLineItemsList[0].Average_Cost_When_Created__c : 0.0);
                }
                for(Part_FIFO_Bucket_Activity_Line_Item__c fifoBucketActivityLineItemObject 
                    : partIdToFifoBucketLineItemsMap.get(partId)) {
                    partFifoBucketLineItemQtyOut = fifoBucketActivityLineItemObject.Qty_Out__c != null ? fifoBucketActivityLineItemObject.Qty_Out__c: 0.0;
                    fifoBucketActivityLineItemObject.Cost__c = fifoBucketActivityLineItemObject.Cost__c != null ? fifoBucketActivityLineItemObject.Cost__c 
                                                                    : (fifoBucketActivityLineItemObject.Part_FIFO_Bucket__r.Cost__c != null? fifoBucketActivityLineItemObject.Part_FIFO_Bucket__r.Cost__c : 0);
                    //// Sales Qty And Cost
                    if(fifoBucketActivityLineItemObject.CO_Invoice_Header__c != null) {
                        salesQty += partFifoBucketLineItemQtyOut;
                        salesCost += partFifoBucketLineItemQtyOut * fifoBucketActivityLineItemObject.Cost__c;
                        List<Coli_Fifo_Line_Item_Junction__c> coliJunction =(List<Coli_Fifo_Line_Item_Junction__c>) fifoBucketActivityLineItemObject.getSObjects(Constants.NAMESPACE + 'Coli_Fifo_Line_Items_Junction__r');
                        if( coliJunction != null && coliJunction.size() >0) {
                            CO_Line_Item__c coli = (CO_Line_Item__c) coliJunction[0].getSObject(Constants.NAMESPACE + 'CO_Line_Item__r');
                            totalSales += partFifoBucketLineItemQtyOut * (Decimal) coli.get('Price__c');
                        }
                    }
                    //Adjusted Cost
                    if(FIFOTransaction.referenceNamesForAdjusmentSet.contains(fifoBucketActivityLineItemObject.Reference__c)) {
                        adjustedQty -= partFifoBucketLineItemQtyOut;
                        adjustedCost -= partFifoBucketLineItemQtyOut * fifoBucketActivityLineItemObject.Cost__c;
                    }
                    
                    //Purchase Cost
                    if(fifoBucketActivityLineItemObject.Reference__c == 'Vendor Return') {
                        purchaseQty -= partFifoBucketLineItemQtyOut;
                        purchaseCost -= partFifoBucketLineItemQtyOut * fifoBucketActivityLineItemObject.Cost__c;
                    }
               }
               if(partFIFOLineItemsList.size() > 0 && partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_In_Stock_When_Created__c !=null){
                    partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c = ((partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c != null) ? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c : 0);
                    partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c = ((partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c != null) ? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c : 0); 
                     partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c = partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c != null ? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c 
                                                                    : (partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Part_FIFO_Bucket__r.Cost__c != null? partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Part_FIFO_Bucket__r.Cost__c : 0);
                    closingQty = partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_In_Stock_When_Created__c 
                        - (partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c );
                    closingCost = (closingQty == 0 ? 0 : ( partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_In_Stock_When_Created__c * partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Average_Cost_When_Created__c ) - (partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Qty_Out__c * partFIFOLineItemsList[partFIFOLineItemsList.size() - 1].Cost__c));
                }
               partMovementObject.Opening_Value = openingCost;
               partMovementObject.Opening_Qty = openingQty;
               partMovementObject.Closing_Value = closingCost;
               partMovementObject.Closing_Qty = closingQty;
               partMovementObject.Purchased_Qty = purchaseQty;
               partMovementObject.Purchased_Cost = purchaseCost;
               partMovementObject.Sales_Qty = salesQty;
               partMovementObject.Cost_of_Sales = salesCost;
               partMovementObject.Adjusted_Qty = adjustedQty;
               partMovementObject.Adjusted_Cost = adjustedCost;
               partMovementObject.Total_Sales = totalSales;
               if(partMovementObject.Opening_Value !=0 ||  partMovementObject.Opening_Qty!=0 || partMovementObject.Closing_Value!=0 
                   || partMovementObject.Closing_Qty!=0 || partMovementObject.Purchased_Qty != 0 || partMovementObject.Purchased_Cost !=0
                   || partMovementObject.Sales_Qty !=0 || partMovementObject.Cost_of_Sales!=0 || partMovementObject.Adjusted_Qty!=0
                   || partMovementObject.Adjusted_Cost != 0 || partMovementObject.Total_Sales != 0) {
                   partMovementItems.add(partMovementObject);
               }
            }
        }
        partIdToFifoBucketsMap = new Map<String, List<Part_FIFO_Bucket__c>>();
        partIdToFifoBucketLineItemsMap = new Map<String, List<Part_FIFO_Bucket_Activity_Line_Item__c>>();
        
        return partMovementItems;
    }
    /**
     * Name: ResultWrapper
     * Desc: RESULT records wrapper class used to get records in json format
    **/
    public class ResultWrapper {
        
        
        public Integer Total_Records {get; private set;}
        public String RecordsVariableName {get; private set;}
        public List<HomeSearchFilterInterface.FilterLabel> FilterLabelList {get; set;}
        
        // People
        public List<Customer> CustomerRecords {get; set;}
        public List<Vendor> VendorRecords {get; set;}
        public List<People> PeopleRecords {get; set;}
        
        // Products
        public List<Part> PartRecords {get; set;}
        public List<LabourCode> LabourRecords {get; set;}
        public List<Fee> FeeRecords {get; set;}
        public List<KitHeader> KitRecords {get; set;}
        public List<Product> ProductRecords {get; set;}
        //public List<VendorProduct> SubletRecords {get; set;}
        public List<VendorProduct> VendorProductRecords {get; set;}
        // Customer Sales
        public List<CustomerSales> CustomerSalesRecords {get; set;}
        public List<CustomerOrders> CustomerOrderRecords {get; set;}
        public List<CustomerInvoice> CustomerInvoiceRecords {get; set;}
        public List<CustomerPayment> CustomerPaymentRecords {get; set;}
        
        // Vendor Orders
        public List<VendorOrder> VendorOrderRecords {get; set;}
        public List<VendorInvoice> VendorInvoiceRecords {get; set;}
        public List<VendorRecieving> VendorRecievingRecords {get; set;}
        public List<VendorOrdering> VendorOrderingRecords {get; set;}
        
        // Setting
        public List<Category> CategoryRecords {get; set;}
        public List<PriceLevel> PriceLevelRecords {get; set;}
        public List<salesTax> SalesTaxRecords {get; set;}
        public List<Setting> SettingRecords {get; set;}
        
        // User
        public List<UserRec> UserRecords {get; set;}
        //PartNeeded Dinesh Kumar 10/10/2016
        public List<PartNeeded> PartNeededRecords {get; set;}
        public List<InvoicedItems> InvoicedItems {get; set;}
        public List<TechnicianHours> TechnicianHourRecords {get; set;}
        public List<PayrollHours> PayrollHourRecords {get; set;}
        // Service Order Header
        public List<ServiceJob> ServiceJobs {get; set;}
        public List<TechnicianPerformance> TechnicianPerformanceRecords {get; set;}
        //Start: Added by Nidhi - #1152 - 19-10-2016
        // Inventory Unit
        public List<InventoryUnit> InventoryUnits {get; set;}
        //END: Added by Nidhi - #1152 - 19-10-2016        
        public List<CustomerUnit> CustomerUnits {get; set;}
        public List<UnitDeal> UnitDealRecords {get; set;}
        public List<DealUnit> DealUnitRecords {get; set;}
        public List<PartsOrder> PartsOrderRecords {get; set;}
        
        public List<PartMovement> PartMovementRecords {get; set;}
        public List<TaxReporting> TaxDetailRecords {get; set;}
        // Any Object(Generic Type)
        public List<AnyObject> AnyObjectRecords {get; set;}
        public Boolean IsIncludeInactiveRecords {get; set;}
        public Boolean IsSummaryFormat {get; set;}
        public ResultWrapper(Integer Total_Records, String RecordsVariableName){
            this.Total_Records = Total_Records;
            this.RecordsVariableName = RecordsVariableName;
        }
    }
    
    public class TechnicianPerformance {
       public String Id {get; private set;}
       public Integer Type {get; private set;}
       public String Technician {get; private set;}
       public Decimal Hours_Worked {get; private set;}
       public Decimal Hrs_Clocked_On {get; private set;}
       public String Productivity {get; private set;}
       public Decimal Clocked_Hrs_Invoiced {get; private set;}
       public Decimal Invoice_Hrs {get; private set;}
       public String Efficiency {get; private set;}
       public String Proficiency {get; private set;}
       public Decimal Uninvoiced_Clocked_Hrs {get; private set;}
       public Decimal Other_Tasks_Hrs {get; private set;}
       
       public TechnicianPerformance(Technician__c technicianRec) {
            this.Id  = technicianRec.Id;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Technician Performance');
            this.Technician  = technicianRec.Technician_Name__c;
            
            this.Hrs_Clocked_On = 0;
            this.Clocked_Hrs_Invoiced = 0;
            this.Uninvoiced_Clocked_Hrs = 0;
            this.Invoice_Hrs = 0;
            this.Other_Tasks_Hrs = 0;
            for(Hours_Logged__c hrsLoggedRec : technicianRec.Hours_Logged__r) {
                if(String.isNotBlank(hrsLoggedRec.Service_Order_Header__c)) {
                    this.Hrs_Clocked_On += (hrsLoggedRec.Calculated_Hours__c != null) ? hrsLoggedRec.Calculated_Hours__c : 0;
                    
                    if(hrsLoggedRec.Service_Order_Header__r.Work_Status__c == 'Invoiced') {
                        this.Clocked_Hrs_Invoiced += (hrsLoggedRec.Calculated_Hours__c != null) ? hrsLoggedRec.Calculated_Hours__c : 0;
                        this.Invoice_Hrs += (hrsLoggedRec.Billed_Hours__c != null) ? hrsLoggedRec.Billed_Hours__c : 0;
                    } else {
                        this.Uninvoiced_Clocked_Hrs += (hrsLoggedRec.Calculated_Hours__c != null) ? hrsLoggedRec.Calculated_Hours__c : 0;
                    }
                } else if(String.isNotBlank(hrsLoggedRec.Task__c)) {
                    this.Other_Tasks_Hrs += (hrsLoggedRec.Calculated_Hours__c != null) ? hrsLoggedRec.Calculated_Hours__c : 0;
                }
            }
            
            this.Hrs_Clocked_On = (this.Hrs_Clocked_On == null ? 0 : this.Hrs_Clocked_On).setScale(2, RoundingMode.HALF_UP);
            this.Uninvoiced_Clocked_Hrs = (this.Uninvoiced_Clocked_Hrs == null ? 0 : this.Uninvoiced_Clocked_Hrs).setScale(2, RoundingMode.HALF_UP);
            this.Clocked_Hrs_Invoiced = (this.Clocked_Hrs_Invoiced == null ? 0 : this.Clocked_Hrs_Invoiced).setScale(2, RoundingMode.HALF_UP);
            this.Invoice_Hrs = (this.Invoice_Hrs == null ? 0 : this.Invoice_Hrs).setScale(2, RoundingMode.HALF_UP);
            this.Other_Tasks_Hrs = (this.Other_Tasks_Hrs == null ? 0 : this.Other_Tasks_Hrs).setScale(2, RoundingMode.HALF_UP);
            
            Decimal eff = (this.Clocked_Hrs_Invoiced != 0) ? (this.Invoice_Hrs / this.Clocked_Hrs_Invoiced) : this.Invoice_Hrs;
            this.Efficiency = String.valueOf((eff * 100).setScale(2, RoundingMode.HALF_UP)) + '%';
            
            this.Hours_Worked = 0;
            for(Payroll_Time__c payrollTimeRec : technicianRec.Payroll_Times__r) {
                this.Hours_Worked += (payrollTimeRec.Total_Time__c != null) ? payrollTimeRec.Total_Time__c : 0;
            }
            
            this.Hours_Worked = (this.Hours_Worked == null ? 0 : this.Hours_Worked).setScale(2, RoundingMode.HALF_UP);
            Decimal prdctivity = (this.Hours_Worked != null && this.Hours_Worked != 0) ? this.Hrs_Clocked_On / this.Hours_Worked : this.Hrs_Clocked_On;
            this.Productivity = String.valueOf((prdctivity * 100).setScale(2, RoundingMode.HALF_UP)) + '%';

            Decimal prf = (prdctivity * eff * 100).setScale(2, RoundingMode.HALF_UP);
            this.Proficiency = String.valueOf(prf) + '%';
        }
    }
    
    /**
     * Name: Customer
     * Description: Sets the value of customer 
     * 
    **/
    public class Customer {
        public Integer Type {get; private set;}
        public String Customer_Number {get; private set;}
        public String Customer_Name {get; private set;}
        public String Phone_Number {get; private set;}
        public String Email {get; private set;}
        public String Owner {get; private set;}
        public String Modified {get; private set;}
        public String Status {get; private set;}
        public String Id {get; private set;}
        
        public String First_Name {get; private set;}
        public String Last_Name {get; private set;}
        public String Nickname {get; private set;}
        public String Birth_Date {get; private set;}
        public String VIP_Number {get; private set;} 
        public String Job_Title {get; private set;}
        
        public String Billing_Address {get; private set;}
        public String Billing_City {get; private set;}
        public String Billing_State {get; private set;}
        public String Shipping_Address {get; private set;}
        public String Shipping_City {get; private set;}
        public String Shipping_State {get; private set;}
        
        public String Home_Number {get; private set;}
        public String Mobile_Number {get; private set;}
        public String Other_Email {get; private set;}
        public String Work_Email {get; private set;}
        public String Work_Number {get; private set;}
        
        public String Facebook {get; private set;}
        public String LinkedIn {get; private set;}
        public String Twitter {get; private set;}
        public String Website {get; private set;}
        public String Sales_Tax {get; private set;}
        public String Price_Level {get; private set;}
        
        public Decimal Open_Orders {get; private set;}
        public Decimal Orders_Lifetime {get; private set;} 
        public Decimal Average_Spend_per_Order {get; private set;}
        public String Created {get; private set;}
        public String Parent_Account {get; private set;}
        public String Active {get; private set;}
        public String Postal_Code {get; private set;}
        public String Account_Type {get; private set;}
        public String Drivers_License {get; private set;}
        
        
        public Customer(Account acc) {
            this.Id = acc.Id;
            this.Customer_Number = acc.Customer_Number__c;
            this.Customer_Name = acc.Name;
            
            if(acc.Email__c != null) {
                this.Email = acc.Email__c;
            } else if(acc.Other_Email__c != null) {
                this.Email = acc.Other_Email__c;
            }
            
            if(acc.Type__c == 'Individual' && acc.Home_Number__c != null) {
                this.Phone_Number = acc.Formatted_Home_number__c;
            } else if(acc.Type__c == 'Business' && acc.Work_Number__c != null) {
                this.Phone_Number = acc.Formatted_Work_Number__c;
            }
            
            //this.Phone_Number = acc.Preferred_Phone__c;
            //this.Email = acc.Email__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customers');
            this.Modified = (acc.LastModifiedDate != null) ? BPUtility.getFormatedDateTime(acc.LastModifiedDate) : null;
            this.Owner = (acc.Owner.Name != null) ? acc.Owner.Name : null;
            this.Status = acc.Status__c;
                        
            this.First_Name = acc.FirstName__c;
            this.Last_Name =  acc.LastName__c;
            this.Nickname = acc.Nickname__c;
                        
            this.Birth_Date = (acc.Birth_Date__c != null) ? BPUtility.getFormatedDateTime((datetime.newInstance(acc.Birth_Date__c.year(), acc.Birth_Date__c.month(), acc.Birth_Date__c.day()))) : null;
            this.VIP_Number = acc.VIP__c;
            this.Job_Title = acc.Job_Title__c;
            
            this.Billing_Address = acc.BillingStreet;
            this.Billing_City = acc.BillingCity;
            this.Billing_State = acc.BillingState;
            this.Shipping_Address = acc.ShippingStreet;
            this.Shipping_City = acc.ShippingCity;
            this.Shipping_State = acc.ShippingState;
            
            this.Home_Number = acc.Formatted_Home_number__c;
            this.Mobile_Number = acc.Formatted_Mobile_Number__c;
            this.Other_Email = acc.Other_Email__c;
            this.Work_Email = acc.Work_Email__c;
            this.Work_Number = acc.Formatted_Work_Number__c;
            
            this.Facebook = acc.Facebook__c;
            this.LinkedIn = acc.LinkedIn__c;
            this.Twitter = acc.Twitter__c;
            this.Website = acc.Website;
            this.Sales_Tax = (acc.Sales_Tax__c != null) ? acc.Sales_Tax__r.Name__c : null;
            this.Price_Level = (acc.Price_Level__c != null) ? acc.Price_Level__r.Name__c : null;
             
            this.Open_Orders = acc.Open_Orders__c;
            this.Orders_Lifetime = acc.Orders_Lifetime__c;
            this.Average_Spend_per_Order = acc.Average_Spend_per_Order__c;
            this.Created = (acc.CreatedDate != null) ?  BPUtility.getFormatedDateTime(acc.CreatedDate) : null;
            this.Parent_Account = '';  
            this.Active = (acc.Active__c) ? 'Active' : 'Inactive';
            this.Postal_Code = acc.BillingPostalCode;
            this.Account_Type = (acc.Account_type__c != null) ? acc.Account_type__r.Name : '';
            this.Drivers_License = acc.Drivers_License__c;
        }
    }
    
    /**
     * Name: Vendor
     * Description: Sets the value of vendor
    **/
    
    public class Vendor {
        public Integer Type {get; private set;}
        public String Vendor_Code {get; private set;}
        public String Vendor_Name {get; private set;}
        public String Phone_Number {get; private set;}
        public String Email {get; private set;}
        public String Modified {get; private set;}
        public String Owner {get; private set;}
        public String Status {get; private set;}
        public String Id {get; private set;}
        
        public String Billing_Address {get; private set;}
        public String Billing_City {get; private set;}
        public String Billing_State {get; private set;}
        public String Shipping_Address {get; private set;}
        public String Shipping_City {get; private set;}
        public String Shipping_State {get; private set;}
        
        
        public String Mobile_Number {get; private set;}
        public String Other_Email {get; private set;}
        public String Work_Email {get; private set;}
        public String Work_Number {get; private set;}
        
        public String Facebook {get; private set;}
        public String LinkedIn {get; private set;}
        public String Twitter {get; private set;}
        public String Website {get; private set;}
        public String Sales_Tax {get; private set;}
        public String Price_Level {get; private set;}
        
        public Decimal Open_Orders {get; private set;}
        public Decimal Orders_Lifetime {get; private set;} 
        public Decimal Average_Spend_per_Order {get; private set;}
        public String Created {get; private set;}
        public String Parent_Account {get; private set;}
        
        
        public String Last_Order {get; private set;}
        public String Purchase_Tax {get; private set;}
        public String Vendor_Account_Number {get; private set;}
        public String Part_Category_Default {get; private set;}
        public String Unit_Category_Default {get; private set;}
        public Boolean Claims_for_Service_Work {get; private set;}
        public Boolean Flooring_Company  {get; private set;}
        public Boolean Part_Purchases {get; private set;}
        public Boolean Sublet_Purchases {get; private set;}
        public Boolean Unit_Purchases {get; private set;}
        public Boolean Warranty_Plan_Sales_on_Unit_Deals {get; private set;}
        public String Active {get; private set;}
        public String Account_Type {get; private set;}
        
            
        public Vendor(Account acc) {
            this.Id = acc.Id;
            this.Vendor_Code = acc.Vendor_Code__c;
            this.Vendor_Name = acc.Name;
            
            if(acc.Work_Email__c != null) {
                this.Email = acc.Work_Email__c;
            } else if(acc.Other_Email__c != null) {
                this.Email = acc.Other_Email__c;
            }
            
            if(acc.Work_Number__c != null) {
                this.Phone_Number = acc.Formatted_Work_Number__c;
            } else if(acc.Mobile__c != null) {
                this.Phone_Number = acc.Formatted_Mobile_Number__c;
            }
            
            //this.Phone_Number = acc.Preferred_Phone__c;
            //this.Email = acc.Email__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendors');
            this.Modified = (acc.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(acc.LastModifiedDate) : null;
            this.Owner = (acc.Owner.Name != null) ? acc.Owner.Name : null;
            this.Status = acc.Status__c;
            
            this.Billing_Address = acc.BillingStreet;
            this.Billing_City = acc.BillingCity;
            this.Billing_State = acc.BillingState;
            this.Shipping_Address = acc.ShippingStreet;
            this.Shipping_City = acc.ShippingCity;
            this.Shipping_State = acc.ShippingState;
            
            this.Mobile_Number = acc.Formatted_Mobile_Number__c;
            this.Other_Email = acc.Other_Email__c;
            this.Work_Email = acc.Work_Email__c;
            this.Work_Number = acc.Formatted_Work_Number__c;
            
            this.Facebook = acc.Facebook__c;
            this.LinkedIn = acc.LinkedIn__c;
            this.Twitter = acc.Twitter__c;
            this.Website = acc.Website;
            this.Sales_Tax = (acc.Sales_Tax__c != null) ? acc.Sales_Tax__r.Name__c : null;
            this.Price_Level = (acc.Price_Level__c != null) ? acc.Price_Level__r.Name__c : null;
            
            this.Open_Orders = acc.Open_Orders__c;
            this.Orders_Lifetime = acc.Orders_Lifetime__c;
            this.Average_Spend_per_Order = acc.Average_Spend_per_Order__c;
            this.Created = (acc.CreatedDate != null) ?  BPUtility.getFormatedDateTime(acc.CreatedDate) : null;
            this.Parent_Account = '';  //
            
            this.Last_Order = acc.Last_Visit_Order__c;
            this.Purchase_Tax = (acc.Purchase_Tax__c != null) ? acc.Purchase_Tax__r.Name__c : null;
            //this.Vendor_Account_Number = 
            this.Part_Category_Default = (acc.Part_Category_Default__c != null) ? acc.Part_Category_Default__r.Name : null;
            this.Unit_Category_Default = (acc.Unit_Category_Default__c != null) ? acc.Unit_Category_Default__r.Name : null;
            this.Claims_for_Service_Work = acc.Claims_for_Service_Work__c;
            this.Flooring_Company = acc.Flooring_Company__c;
            this.Part_Purchases = acc.Part_Purchases__c;
            this.Sublet_Purchases = acc.Sublet_Purchases__c;
            this.Unit_Purchases = acc.Unit_Purchases__c;
            this.Warranty_Plan_Sales_on_Unit_Deals = acc.Warranty_Plan_Sales_on_Unit_Deals__c;
            this.Active = (acc.Active__c) ? 'Active' : 'Inactive';
            this.Account_Type = (acc.Vendor_Account_Type__c != null) ? acc.Vendor_Account_Type__r.Name : '';
        }
    }
    
    /**
     * Name: People
     * Description: Sets the value of the People 
    **/
    public class People {
        public Integer Type {get; private set;}
        public String Id_Number {get; private set;}
        public String Name {get; private set;}
        public String Phone_Number {get; private set;}
        public String Email {get; private set;}
        public String Owner {get; private set;}
        public String Modified {get; private set;}
        public String Status {get; private set;}
        
        public String Billing_Address {get; private set;}
        public String Billing_City {get; private set;}
        public String Billing_State {get; private set;}
        public String Shipping_Address {get; private set;}
        public String Shipping_City {get; private set;}
        public String Shipping_State {get; private set;}
        
        public String Mobile_Number {get; private set;}
        public String Other_Email {get; private set;}
        public String Work_Email {get; private set;}
        public String Work_Number {get; private set;}
        
        public String Facebook {get; private set;}
        public String LinkedIn {get; private set;}
        public String Twitter {get; private set;}
        public String Website {get; private set;}
        public String Sales_Tax {get; private set;}
        public String Price_Level {get; private set;}
        
        public Decimal Open_Orders {get; private set;}
        public String Created {get; private set;}
        public String Parent_Account {get; private set;}
        public String Id {get; private set;}
        public String Active {get; private set;}
        
        public People(Account acc) {
            this.Id = acc.Id;
            this.Name = acc.Name;
            if(acc.Is_Customer__c) {
                if(acc.Type__c == 'Individual') {
                    this.Phone_Number = acc.Home_Number__c;
                } else if(acc.Type__c == 'Business') {
                    this.Phone_Number = acc.Work_Number__c;
                }
            } else if(acc.Is_Vendor__c) {
                this.Phone_Number = acc.Work_Number__c;
            }
            this.Email = acc.Email__c;
            this.Billing_Address = acc.BillingStreet;
            this.Billing_City = acc.BillingCity;
            this.Billing_State = acc.BillingState;
            this.Id_Number = acc.Id_Number__c;
            
            if(acc.Is_Customer__c) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customers');
                //this.Id_Number = acc.Customer_Number__c;
            } else {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendors');
                //this.Id_Number = acc.Vendor_Code__c;
            }
            this.Modified = (acc.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(acc.LastModifiedDate) : null;
            this.Owner = (acc.Owner.Name != null) ? acc.Owner.Name : null;
            this.Status = acc.Status__c;
            
            this.Shipping_Address = acc.ShippingStreet;
            this.Shipping_City = acc.ShippingCity;
            this.Shipping_State = acc.ShippingState; 
             
            this.Mobile_Number = acc.Mobile__c;
            this.Other_Email = acc.Other_Email__c;
            this.Work_Email = acc.Work_Email__c;
            this.Work_Number = acc.Work_Number__c;
            
            this.Facebook = acc.Facebook__c;
            this.LinkedIn = acc.LinkedIn__c;
            this.Twitter = acc.Twitter__c;
            this.Website = acc.Website;
            this.Sales_Tax = (acc.Sales_Tax__c != null) ? acc.Sales_Tax__r.Name__c : null;
            this.Price_Level = (acc.Price_Level__c != null) ? acc.Price_Level__r.Name__c : null;
            
            this.Open_Orders = acc.Open_Orders__c;
            this.Created = (acc.CreatedDate != null) ?  BPUtility.getFormatedDateTime(acc.CreatedDate) : null;
            this.Parent_Account = '';  
            this.Active = (acc.Active__c) ? 'Active' : 'Inactive';
        }
    }
    
    /**
     * Name: Part
     * Description: Sets the value of the Parts
    **/
    public class Part {
        public Integer Type {get; private set;}
        public String Part_Number {get; private set;}
        public String Description {get; private set;}
        public String Category {get; private set;}
        public Decimal Retail {get; private set;}
        public Decimal Qty_Available {get; private set;}
        public String Modified {get; private set;}
        public String Status {get; private set;}
        public String Vendor {get; private set;}
        public Decimal Cost {get; private set;}
        public String Location {get; private set;}
        public String Id {get; private set;}
        
        public Decimal Qty_In_Stock {get; private set;}
        public Decimal Qty_Committed {get; private set;} 
        public Decimal Qty_On_Order {get; private set;}
        public Decimal MSRP {get; private set;}
        public Decimal Enviro_Fee {get; private set;}
        public Decimal Average_Cost {get; private set;}
        public Decimal Package_Cost {get; private set;}
        public Decimal Package_Qty {get; private set;}
        public String Package_Unit {get; private set;}
        public String Last_Counted {get; private set;}
        public String Last_Sold {get; private set;}
        public String Last_Stocked {get; private set;}
        public Decimal Reorder_At {get; private set;}
        public Decimal Reorder_To {get; private set;}
        public Decimal Order_Lots {get; private set;}
        public String Replaced_By {get; private set;}
        public Decimal Oversold_Qty {get; private set;}
        public Decimal Oversold_Cost {get; private set;}
        public Decimal Total_Cost {get; private set;}
        public String Mfg_Part {get; private set;} // Added by richa 29/11/2016
        public String SKU {get; private set;} // Added by richa 29/11/2016 SKU_Number
        public Boolean Non_Inventory_Part {get; private set;} // Added by richa 29/11/2016
        public String Active {get; private set;}
        public String Tags {get; private set;}
        public Decimal PRD1_Qty {get; private set;}
        public Decimal PRD1_Cost {get; private set;}
        public Decimal PRD2_Qty {get; private set;}
        public Decimal PRD2_Cost {get; private set;}
        public Decimal PRD3_Qty {get; private set;}
        public Decimal PRD3_Cost {get; private set;}
        public Decimal PRD4_Qty {get; private set;}
        public Decimal PRD4_Cost {get; private set;}
        public String Part_Type {get; private set;}
        
        public Part(Part__c partRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
            this.Part_Number = partRec.Part_Number__c;
            this.Description = partRec.Description__c;
            this.Qty_Available = partRec.AvailableParts__c;
            this.Retail = partRec.Retail_Price__c;
            this.Location = partRec.Location__c;
            this.Category = partRec.Category__r.Name;
            this.Status = partRec.Status__c;
            this.Modified = (partRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(partRec.LastModifiedDate) : null;
            this.Vendor = (partRec.Vendor__c != null) ? partRec.Vendor__r.Vendor_Code__c : null;
            this.Cost = (partRec.Last_Cost__c != null) ? partRec.Last_Cost__c : null;
            this.Status = partRec.Status__c;
            this.Id = partRec.Id;
            
            this.Qty_In_Stock = partRec.Qty_In_Stock__c;
            this.Qty_Committed = partRec.Qty_Committed__c;
            this.Qty_On_Order = partRec.Qty_On_Order__c;
            this.MSRP = partRec.MSRP__c;
            this.Enviro_Fee = partRec.Enviro_Fee__c;
            this.Average_Cost = partRec.Average_Cost__c;
            this.Package_Cost =  partRec.Package_Cost__c;
            this.Package_Qty = partRec.Package_Qty__c;
            this.Package_Unit = partRec.Package_Unit__c;
            this.Last_Counted = (partRec.Last_Counted__c != null) ?  BPUtility.getFormatedDateTime(partRec.Last_Counted__c) : null;
            this.Last_Sold = (partRec.Last_Sold__c != null) ?  BPUtility.getFormatedDateTime(partRec.Last_Sold__c) : null;
            this.Last_Stocked = (partRec.Last_Stocked__c != null) ?  BPUtility.getFormatedDateTime(partRec.Last_Stocked__c) : null;
            this.Reorder_At = partRec.Auto_reorder_Min__c;
            this.ReOrder_To = partRec.Auto_reorder_Max__c;
            this.Order_Lots =  partRec.Order_Lots__c;
            this.Replaced_By = (partRec.Superseded_By__c != null) ? partRec.Superseded_By__r.Part_Number__c : null;
            this.Oversold_Qty = (partRec.Oversold_Qty__c != null) ? partRec.Oversold_Qty__c : 0;
            this.Oversold_Cost = (partRec.Oversold_Cost__c != null) ? partRec.Oversold_Cost__c : 0.00;
            this.Total_Cost = (partRec.Total_Cost__c != null) ? partRec.Total_Cost__c : 0.00;
            this.Mfg_Part = partRec.Mfg_Part__c; // Added by richa 29/11/2016
            this.SKU = partRec.SKU_Number__c; // Added by richa 29/11/2016 SKU_Number
            this.Non_Inventory_Part = partRec.Non_Inventory_Part__c; // Added by richa 29/11/2016
            this.Active = (partRec.Active__c) ? 'Active' : 'Inactive';
            
            this.PRD1_Qty = (partRec.PRD1Qty__c != null) ? partRec.PRD1Qty__c : 0;
            this.PRD1_Cost = (partRec.PRD1Cost__c != null) ? partRec.PRD1Cost__c : 0;
            this.PRD2_Qty = (partRec.PRD2Qty__c != null) ? partRec.PRD2Qty__c : 0;
            this.PRD2_Cost = (partRec.PRD2Cost__c != null) ? partRec.PRD2Cost__c : 0;
            this.PRD3_Qty = (partRec.PRD3Qty__c != null) ? partRec.PRD3Qty__c : 0;
            this.PRD3_Cost = (partRec.PRD3Cost__c != null) ? partRec.PRD3Cost__c : 0;
            this.PRD4_Qty = (partRec.PRD4Qty__c != null) ? partRec.PRD4Qty__c : 0;
            this.PRD4_Cost = (partRec.PRD4Cost__c != null) ? partRec.PRD4Cost__c : 0;
                
            String tagsNameStr1 = '';
            if(String.isNotBlank(partRec.Assigned_Tag_1__c) && partRec.Assigned_Tag_1__c.length() > 1) {
                tagsNameStr1 = partRec.Assigned_Tag_1__c.substring(1, (partRec.Assigned_Tag_1__c).length() - 1);
            }
            if(String.isNotBlank(partRec.Assigned_Tag_2__c) && partRec.Assigned_Tag_2__c.length() > 1) {
                tagsNameStr1 += (String.isNotBlank(tagsNameStr1)) ? (';' + partRec.Assigned_Tag_2__c.substring(1, (partRec.Assigned_Tag_2__c).length() - 1)) : 
                                                                    (partRec.Assigned_Tag_2__c.substring(1, (partRec.Assigned_Tag_2__c).length() - 1));
            }
            
            this.Tags = tagsNameStr1.replace(';', ',');
            this.Part_Type = (partRec.Part_Type__c != null) ? partRec.Part_Type__c :'Part';
        }
    }
    
    /**
     * Name: KitHeader
     * Description:  Sets the value of the Kit
    **/
    public class KitHeader {
        public String Id {get; private set;}
        public String Code {get; private set;}
        public Integer Type {get; private set;}
        public String Description {get; private set;}
        public Decimal Qty_Available {get; private set;}
        public Decimal Price {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        public String Active {get; private set;}
        
        public KitHeader(Kit_Header__c kitHeaderRec) {
            this.Id = kitHeaderRec.Id;
            this.Code = kitHeaderRec.Code__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Kits');
            this.Description = kitHeaderRec.Kit_Unique_Name__c;
            this.Price = kitHeaderRec.Fixed_Price__c;
            this.Qty_Available = 1;
            this.Modified = (kitHeaderRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(kitHeaderRec.LastModifiedDate) : null;
            this.Status = kitHeaderRec.Status__c;
            this.Active = (kitHeaderRec.Active__c) ? 'Active' : 'Inactive';
        }
    }
    
    
    /**
     * Name: Fee
     * Description: Sets the value of the Kit
    **/
    public class Fee {
        public String Id {get; private set;}
        public String Code {get; private set;}
        public Integer Type {get; private set;}
        public String Description {get; private set;}
        public String Category {get; private set;}
        public Decimal Price {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        public String Active {get; private set;}
        
        public Fee(Fee__c feeRec) {
            this.Id = feeRec.Id;
            this.Code = feeRec.Code__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Fees');
            this.Description = feeRec.Fee_Unique_Name__c;
            this.Category = (feeRec.Category__c != null && feeRec.Category__r.Name != null) ? feeRec.Category__r.Name : null;
            this.Price = feeRec.Price__c;
            this.Status = feeRec.Status__c;
            this.Modified = (feeRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(feeRec.LastModifiedDate) : null;
            this.Active = (feeRec.Active__c) ? 'Active' : 'Inactive';
        }
    }
    
    /**
     * Name: LabourCode
     * Description: Sets the value of LabourCode 
    **/
    public class LabourCode {
        
        public String Id {get; private set;}
        public String Code {get; private set;}
        public Integer Type {get; private set;}
        public String Description {get; private set;}
        public String Category {get; private set;}
        public Decimal Price {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        public String Hours {get; private set;}
        public String Active {get; private set;}
        
        public LabourCode(Labour_Code__c labourRec) {
            this.Id = labourRec.Id;
            this.Code = labourRec.Code__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Labor Codes');
            this.Description = labourRec.Description__c;
            this.Category = (labourRec.Category__c != null && labourRec.Category__r.Name != null) ? labourRec.Category__r.Name : null;
            this.Price = labourRec.Rate__c;
            this.Status = labourRec.Status__c;
            this.Modified = (labourRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(labourRec.LastModifiedDate) : null;
            this.Hours = (labourRec.Hours__c != null) ? String.valueOf(labourRec.Hours__c) : '0';
            this.Active = (labourRec.Active__c) ? 'Active' : 'Inactive';
        }
    }
    
    
    public class VendorProduct {
        public String Id {get; private set;}
        public String Code {get; private set;}
        public Integer Type {get; private set;}
        public String Category {get; private set;}
        public Decimal Price {get; private set;}
        public String Description {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        public String Vendor {get; private set;}
        public Decimal Cost {get; private set;}
        public String Active {get; private set;}
        public String Product_Type {get; private set;}
        public String Account_Type {get; private set;}
        
        public VendorProduct(Product__c productRec) {
            this.Id = productRec.Vendor__c;
            this.Code = productRec.Code__c;
            if(productRec.Type__c == Constants.SUBLET) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sublets');
            } else if(productRec.Type__c == Constants.FINANCING_PRODUCT) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Financing Product');
            } else if(productRec.Type__c == Constants.DEAL_PRODUCT) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Deal Product');
            } else if(productRec.Type__c == Constants.WARRANTY_PLAN) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Warranty Plan');
            }
            
            this.Description = productRec.Description__c;
            this.Price = productRec.Price__c;
            this.Modified = (productRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(productRec.LastModifiedDate) : null;
            this.Category = (productRec.Category__c != null && productRec.Category__r.Name != null) ? productRec.Category__r.Name : null;
            this.Vendor = (productRec.Vendor__c != null) ? productRec.Vendor__r.Vendor_Code__c : null;
            this.Cost = (productRec.Cost__c != null) ? productRec.Cost__c : null;
            this.Active = (productRec.Status__c == 'Active') ? 'Active' : 'Inactive';
            //this.Status = productRec.Status__c;
            this.Product_Type = productRec.Type__c;
            this.Account_Type = (productRec.Vendor__c != null && productRec.Vendor__r.Vendor_Account_Type__c != null) 
                                ? productRec.Vendor__r.Vendor_Account_Type__r.Name : null;
        }
    }
    
    /**
     * Name: Product
     * Description: Sets the value of Product by filtering out the fields of the entity
    **/
    public class Product {
        public Integer Type {get; private set;}
        public String Code {get; private set;}
        public String Description {get; private set;}
        public String Category {get; private set;}
        public Decimal Price {get; private set;}
        public Decimal Available {get; private set;}
        public String Modified {get; private set;}
        public String Status {get; private set;}
        public String Vendor {get; private set;}
        public Decimal Cost {get; private set;}
        public String Location {get; private set;}
        public String Id {get; private set;}
        public String Active {get; private set;}
        
        public Product(Sobject sobjRec) {
            this.Id = String.valueOf(sobjRec.get('Id'));
            String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            this.Active = 'Active';
            // If the entity is of part type or kit or labourcode or fee then it will be assigned from here accordingly
            if(objectName == Constants.NAMESPACE + 'Part__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
                this.Description = (sobjRec.get(Constants.NAMESPACE +'Part_Number__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Part_Number__c')) : null;
                this.Price = (sobjRec.get(Constants.NAMESPACE +'Retail_Price__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Retail_Price__c'))) : null;
                this.Code = (sobjRec.get(Constants.NAMESPACE +'Part_Number__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Part_Number__c')) : null;
                this.Available = (sobjRec.get(Constants.NAMESPACE +'AvailableParts__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'AvailableParts__c'))) : null;
                this.Category = (sobjRec.getSobject(Constants.NAMESPACE + 'Category__r') != null && sobjRec.getSobject(Constants.NAMESPACE + 'Category__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name')) : null;
                this.Location = (sobjRec.get(Constants.NAMESPACE + 'Location__c') != null) ? String.valueOf(sobjRec.get('Location__c')) : null;
                this.Vendor = (sobjRec.get(Constants.NAMESPACE +'Vendor__c') != null && String.valueOf(sobjRec.getSobject(Constants.NAMESPACE + 'Vendor__r').get(Constants.NAMESPACE +'Vendor_Code__c')) != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Vendor__r').get(Constants.NAMESPACE +'Vendor_Code__c')) : null;
                this.Cost = (sobjRec.get(Constants.NAMESPACE +'Last_Cost__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE + 'Last_Cost__c'))) : null;
                this.Active = Boolean.valueOf(String.valueOf(sobjRec.get('Active__c'))) ? 'Active' : 'Inactive';
                this.Status = String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c'));
            } else if(objectName == Constants.NAMESPACE +'Kit_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Kits');
                this.Description = (sobjRec.get(Constants.NAMESPACE +'Kit_Unique_Name__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Kit_Unique_Name__c')) : null;
                this.Price = (sobjRec.get(Constants.NAMESPACE +'Fixed_Price__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Fixed_Price__c'))) : null;
                this.Available = 1;
                this.Code = (sobjRec.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Code__c')) : null;
                this.Active = Boolean.valueOf(String.valueOf(sobjRec.get('Active__c'))) ? 'Active' : 'Inactive';
            } else if(objectName == Constants.NAMESPACE +'Labour_Code__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Labor Codes');
                this.Description = (sobjRec.get('Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                this.Category = (sobjRec.getSobject(Constants.NAMESPACE +'Category__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name')) : null;
                this.Price = (sobjRec.get(Constants.NAMESPACE +'Rate__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Rate__c'))) : null;
                this.Code = (sobjRec.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Code__c')) : null;
                this.Active = Boolean.valueOf(String.valueOf(sobjRec.get('Active__c'))) ? 'Active' : 'Inactive';
            } else if(objectName == Constants.NAMESPACE +'Fee__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Fees');
                this.Description = (sobjRec.get(Constants.NAMESPACE +'Fee_Unique_Name__c') != null) ? String.valueOf(sobjRec.get('Fee_Unique_Name__c')) : null;
                this.Category = (sobjRec.getSobject(Constants.NAMESPACE +'Category__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name')) : null;
                this.Price = (sobjRec.get(Constants.NAMESPACE +'Price__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Price__c'))) : null;
                this.Code = (sobjRec.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Code__c')) : null;
                this.Active = Boolean.valueOf(String.valueOf(sobjRec.get('Active__c'))) ? 'Active' : 'Inactive';
            } else if(objectName == Constants.NAMESPACE +'Product__c') {
                this.Id = sobjRec.get(Constants.NAMESPACE + 'Vendor__c') != null ? String.valueOf(sobjRec.get(Constants.NAMESPACE + 'Vendor__c')) : null;
                String productType = (sobjRec.get(Constants.NAMESPACE +'Type__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Type__c')) : '';
                if(productType == Constants.SUBLET) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sublets');
                } else if(productType == Constants.FINANCING_PRODUCT) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Financing Product');
                } else if(productType == Constants.DEAL_PRODUCT) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Deal Product');
                } else if(productType == Constants.WARRANTY_PLAN) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Warranty Plan');
                }
                this.Description = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                this.Category = (sobjRec.getSobject(Constants.NAMESPACE +'Category__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name')) : null;
                this.Price = (sobjRec.get(Constants.NAMESPACE +'Price__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Price__c'))) : null;
                this.Code = (sobjRec.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Code__c')) : null;
                this.Vendor = (sobjRec.get(Constants.NAMESPACE +'Vendor__c') != null && String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Vendor__r').get(Constants.NAMESPACE +'Vendor_Code__c')) != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Vendor__r').get(Constants.NAMESPACE +'Vendor_Code__c')) : null;
                this.Cost = (sobjRec.get(Constants.NAMESPACE +'Cost__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Cost__c'))) : null;
                this.Active = (String.valueOf(sobjRec.get('Status__c')) == 'Active') ? 'Active' : 'Inactive';
            } else if(objectName == Constants.NAMESPACE +'Customer_Owned_Unit__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Inventory Unit');
                //this.Description = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                this.Category = (sobjRec.getSobject(Constants.NAMESPACE +'Category__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Category__r').get('Name')) : null;
                this.Code = (sobjRec.get(Constants.NAMESPACE +'Stock_Id__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Stock_Id__c')) : null;
                this.Price = (sobjRec.get(Constants.NAMESPACE +'Total_Price__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Total_Price__c'))) : null;
                this.Cost = (sobjRec.get(Constants.NAMESPACE +'Total_Cost__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Total_Cost__c'))) : null;
                //this.Cost = (sobjRec.get(Constants.NAMESPACE +'Cost__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Cost__c'))) : null;
                this.Location = (sobjRec.get(Constants.NAMESPACE + 'Location__c') != null) ? String.valueOf(sobjRec.get('Location__c')) : null;
                this.Available = 1;
                this.Status = String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c'));
            }
            
            this.Modified =  BPUtility.getFormatedDateTime((DateTime.valueOf(String.valueOf(sobjRec.get('LastModifiedDate')))));
        }
    }
    
    public class TechnicianHours {
        public Integer Type {get; private set;}
        public String Technician {get; private set;}
        public String Clocked_Date {get; private set;}
        public String Time_In {get; private set;}
        public String Time_Out {get; private set;}
        public String Reference {get; private set;}
        public Decimal Clocked_Hours {get; private set;}
        public Decimal Billed_Hours {get; private set;}
        public String Efficiency {get; private set;}
        public String Job_Status {get; private set;}
        
        public String Job_Type {get; private set;}
        public String Customer {get; private set;}
        public String Job_Name {get; private set;}
        public String Notes {get; private set;}
        public String Id {get; private set;}
        
        public TechnicianHours(Hours_Logged__c hoursLoggedRec) {
            this.Id  = hoursLoggedRec.Id;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Technician Hours');
            this.Technician = hoursLoggedRec.Technician__r.Technician_Name__c;
            
            this.Clocked_Date = '';
            if(hoursLoggedRec.Start_Date_Time__c != null) {
                Date clockedDate = date.newinstance(hoursLoggedRec.Start_Date_Time__c.year(), hoursLoggedRec.Start_Date_Time__c.month(), hoursLoggedRec.Start_Date_Time__c.day());
                this.Clocked_Date = (clockedDate != null) ? BPUtility.getFormatedDateTime(datetime.newInstance(clockedDate.year(), 
                                                                                                         clockedDate.month(), clockedDate.day())) : '';
            }
                    
            this.Time_In = (hoursLoggedRec.Start_Date_Time__c != null) ? hoursLoggedRec.Start_Date_Time__c.format('hh:mm a'): '';
            this.Time_Out = (hoursLoggedRec.End_Date_Time__c != null) ? hoursLoggedRec.End_Date_Time__c.format('hh:mm a') : '';
            this.Reference = (hoursLoggedRec.Service_Order_Header__c != null) ? hoursLoggedRec.Service_Order_Header__r.CO_Header__r.Name : 
                                (hoursLoggedRec.Task__c != null) ? hoursLoggedRec.Task__r.Name__c : '';
            this.Clocked_Hours = hoursLoggedRec.Calculated_Hours__c;
            this.Billed_Hours = (hoursLoggedRec.Service_Order_Header__c != null) ? hoursLoggedRec.Billed_Hours__c : null;
            this.Efficiency = (hoursLoggedRec.Service_Order_Header__c != null ? (hoursLoggedRec.Service_Order_Header__r.Work_Status__c == 'Invoiced' ?
                                (String.valueOf(hoursLoggedRec.Efficiency__c * 100) + '%') : 'N/A') : '');
            this.Job_Status = (hoursLoggedRec.Service_Order_Header__c != null) ? hoursLoggedRec.Service_Order_Header__r.Work_Status__c : '';
            
            this.Job_Type = (hoursLoggedRec.Service_Order_Header__c != null) ? ((hoursLoggedRec.Service_Order_Header__r.Transaction_Type__c != null) ? 
                            hoursLoggedRec.Service_Order_Header__r.Transaction_Type__r.Code_Label__c : '') : '';
            this.Customer = (hoursLoggedRec.Service_Order_Header__c != null) ? hoursLoggedRec.Service_Order_Header__r.CO_Header__r.Customer_name__c : '';
            this.Job_Name = (hoursLoggedRec.Service_Order_Header__c != null) ? hoursLoggedRec.Service_Order_Header__r.Name__c : '';
            this.Notes = (hoursLoggedRec.Notes__c != null) ? hoursLoggedRec.Notes__c : '';
        }
    }
    
    public class PayrollHours {
        public Integer Type {get; private set;}
        public String Employee {get; private set;}
        public String Clocked_Date {get; private set;}
        public String Time_In {get; private set;}
        public String Time_Out {get; private set;}
        public Decimal Clocked_Hours {get; private set;}
        public String Id {get; private set;}
        
        public PayrollHours(Payroll_Time__c payrollHourRec) {
            this.Id  = payrollHourRec.Id;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Payroll Hours');
            this.Employee = payrollHourRec.Technician__r.Technician_Name__c;
            
            this.Clocked_Date = '';
            if(payrollHourRec.Start_Date__c != null) {
                Date clockedDate = date.newinstance(payrollHourRec.Start_Date__c.year(), payrollHourRec.Start_Date__c.month(), payrollHourRec.Start_Date__c.day());
                this.Clocked_Date = (clockedDate != null) ? BPUtility.getFormatedDateTime(datetime.newInstance(clockedDate.year(), 
                                                                                                         clockedDate.month(), clockedDate.day())) : '';
            }
                    
            this.Time_In = (payrollHourRec.Start_Date__c != null) ? payrollHourRec.Start_Date__c.format('hh:mm a'): '';
            this.Time_Out = (payrollHourRec.End_Date__c != null) ? payrollHourRec.End_Date__c.format('hh:mm a') : '';
            this.Clocked_Hours = payrollHourRec.Total_Time__c;
        }
    }
    
    public class InvoicedItems {
        public Integer Type {get; private set;}
        public String Item {get; private set;}
        public String Description {get; private set;}
        public Decimal Qty_Sold {get; private set;}
        public Decimal Total_Revenue {get; private set;}
        
        public Decimal Total_Profit {get; private set;}
        public String Last_Sale {get; private set;}
        public Decimal Average_Price {get; private set;}
        public Decimal Average_Profit {get; private set;}
        public String Category {get; private set;}
        public String Vendor {get; private set;}
        
        public String Customer {get; private set;}
        public String Invoice {get; private set;}
        public Decimal Price {get; private set;}
        public Decimal Revenue {get; private set;}
        public Decimal Profit {get; private set;}
        public String Id {get; private set;}
        public String Part_Type {get; private set;}
        
        public InvoicedItems(CO_Line_Item__c coliRec) {
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            if(String.isNotBlank(coliRec.Part__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
                this.Id = coliRec.Part__c;
                this.Category = (String.isNotBlank(coliRec.Part__r.Category__c)) ? coliRec.Part__r.Category__r.Name : '';
                this.Vendor = (String.isNotBlank(coliRec.Part__r.Vendor__c)) ? coliRec.Part__r.Vendor__r.Name : '';
            } else if(String.isNotBlank(coliRec.Fee__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Fees');
                this.Id = coliRec.Fee__c;
                this.Category = (String.isNotBlank(coliRec.Fee__r.Category__c)) ? coliRec.Fee__r.Category__r.Name : '';
            }
            this.Item = coliRec.Item_Code__c;
            this.Description = coliRec.Item_Description__c;
            this.Customer = coliRec.CO_Header__r.Customer_Name__c;
            this.Invoice = coliRec.Invoice_Number__r.Invoice_Number__c;
            this.Qty_Sold = coliRec.Qty__c;
            /*this.Price = (isTaxIncludingPricing) ? (coliRec.Price_When_Tax_Included__c != null ? coliRec.Price_When_Tax_Included__c : 0): 
                                                (coliRec.Price__c != null ? coliRec.Price__c : 0);*/
            this.Price = coliRec.Price__c != null ? coliRec.Price__c : 0;
            this.Revenue = (coliRec.Qty__c * this.Price).setScale(2, RoundingMode.HALF_UP);
            this.Profit = coliRec.Per_Item_Profit__c;
            this.Part_Type = (coliRec.Part__r.Part_Type__c != null) ? coliRec.Part__r.Part_Type__c :'Part';
        }
        
        public InvoicedItems(Service_Order_Line_Item__c soliRec) {
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            if(String.isNotBlank(soliRec.Part__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
                this.Vendor = soliRec.Part__r.Vendor__r.Name;
                this.Id = soliRec.Part__c;
                this.Category = (String.isNotBlank(soliRec.Part__r.Category__c)) ? soliRec.Part__r.Category__r.Name : '';
                this.Vendor = (String.isNotBlank(soliRec.Part__r.Vendor__c)) ? soliRec.Part__r.Vendor__r.Name : '';
            } else if(String.isNotBlank(soliRec.Fee__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Fees');
                this.Id = soliRec.Fee__c;
                this.Category = (String.isNotBlank(soliRec.Fee__r.Category__c)) ? soliRec.Fee__r.Category__r.Name : '';
            } else if(String.isNotBlank(soliRec.Labour_Code__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Labor Codes');
                this.Id = soliRec.Labour_Code__c;
                this.Category = (String.isNotBlank(soliRec.Labour_Code__r.Category__c)) ? soliRec.Labour_Code__r.Category__r.Name : '';
            }  else if(String.isNotBlank(soliRec.Sublet__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sublets');
                this.Id = soliRec.Sublet__r.Vendor__c;
                this.Category = (String.isNotBlank(soliRec.Sublet__r.Category__c)) ? soliRec.Sublet__r.Category__r.Name : '';
                this.Vendor = (String.isNotBlank(soliRec.Sublet__r.Vendor__c)) ? soliRec.Sublet__r.Vendor__r.Name : '';
            }
            this.Item = soliRec.Item_Code__c;
            this.Description = soliRec.Item_Description__c;
            this.Customer = soliRec.Service_Order_Header__r.CO_Header__r.Customer_Name__c;
            this.Invoice = soliRec.Service_Order_Header__r.Invoice_Number__r.Invoice_Number__c;
            this.Qty_Sold = soliRec.Qty_Needed__c;
            /*this.Price = (isTaxIncludingPricing) ? (soliRec.Price_When_Tax_Included__c != null ? soliRec.Price_When_Tax_Included__c : 0): 
                                                (soliRec.Kit_Price__c != null ? soliRec.Kit_Price__c : 0);*/
            this.Price = soliRec.Kit_Price__c != null ? soliRec.Kit_Price__c : 0;
            this.Revenue = (soliRec.Qty_Needed__c * this.Price).setScale(2, RoundingMode.HALF_UP);
            this.Profit = soliRec.Per_Item_Profit__c;
            this.Part_Type = (soliRec.Part__r.Part_Type__c != null) ? soliRec.Part__r.Part_Type__c :'Part';
        } 
        
        public InvoicedItems(Option_Fee__c optionAndFeeRec) {
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            if(String.isNotBlank(optionAndFeeRec.Part__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
                this.Vendor = optionAndFeeRec.Part__r.Vendor__r.Name;
                this.Id = optionAndFeeRec.Part__c;
                this.Category = (String.isNotBlank(optionAndFeeRec.Part__r.Category__c)) ? optionAndFeeRec.Part__r.Category__r.Name : '';
                this.Vendor = (String.isNotBlank(optionAndFeeRec.Part__r.Vendor__c)) ? optionAndFeeRec.Part__r.Vendor__r.Name : '';
            } else if(String.isNotBlank(optionAndFeeRec.Fee__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Fees');
                this.Id = optionAndFeeRec.Fee__c;
                this.Category = (String.isNotBlank(optionAndFeeRec.Fee__r.Category__c)) ? optionAndFeeRec.Fee__r.Category__r.Name : '';
            } else if(String.isNotBlank(optionAndFeeRec.Labour_Code__c)) {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Labor Codes');
                this.Id = optionAndFeeRec.Labour_Code__c;
                this.Category = (String.isNotBlank(optionAndFeeRec.Labour_Code__r.Category__c)) ? optionAndFeeRec.Labour_Code__r.Category__r.Name : '';
            } else if(String.isNotBlank(optionAndFeeRec.Product__c)) {
                if(optionAndFeeRec.Product__r.Type__c == 'Sublet') {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sublets');
                } else if(optionAndFeeRec.Product__r.Type__c == 'Warranty Plan') {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Warranty Plan');
                } else {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Other Product');
                }
                this.Id = optionAndFeeRec.Product__r.Vendor__c;
                this.Category = (String.isNotBlank(optionAndFeeRec.Product__r.Category__c)) ? optionAndFeeRec.Product__r.Category__r.Name : '';
                this.Vendor = (String.isNotBlank(optionAndFeeRec.Product__r.Vendor__c)) ? optionAndFeeRec.Product__r.Vendor__r.Name : '';
            }
            this.Item = optionAndFeeRec.Item_Code__c;
            this.Description = optionAndFeeRec.Item_Description__c;
            this.Customer = optionAndFeeRec.Deal__r.CO_Header__r.Customer_Name__c;
            this.Invoice = optionAndFeeRec.Deal__r.Invoice_Number__r.Invoice_Number__c;
            this.Qty_Sold = optionAndFeeRec.Qty__c;
            /*this.Price = (isTaxIncludingPricing) ? (optionAndFeeRec.Price_When_Tax_Included__c != null ? optionAndFeeRec.Price_When_Tax_Included__c : 0): 
                                                (optionAndFeeRec.Price__c != null ? optionAndFeeRec.Price__c : 0);*/
            this.Price = (optionAndFeeRec.Price__c != null ? optionAndFeeRec.Price__c : 0);                                    
            this.Revenue = (optionAndFeeRec.Qty__c * this.Price).setScale(2, RoundingMode.HALF_UP);
            this.Profit = optionAndFeeRec.Per_Item_Profit__c;
            this.Part_Type = (optionAndFeeRec.Part__r.Part_Type__c != null) ? optionAndFeeRec.Part__r.Part_Type__c :'Part';
        }
        
        public InvoicedItems(List<sObject> sObjectList) {
            this.Qty_Sold = 0;
            this.Total_Revenue = 0;
            this.Total_Profit = 0;
            DateTime lastSaleDate;
            DateTime invoiceDate;
            
            for(sObject sobj : sObjectList) {
                Boolean isSOLI = (sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Service_Order_Line_Item__c');
                Boolean isOptionFee = (sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'Option_Fee__c');
                Boolean isCOLI = (sobj.getSObjectType().getDescribe().getName() == Constants.NAMESPACE + 'CO_Line_Item__c');
                if(this.Type == null && sobj.get(Constants.NAMESPACE + 'Part__c') != null) {
                    this.Id = String.valueOf(sobj.get(Constants.NAMESPACE + 'Part__c'));
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
                    this.Item = (sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Part_Number__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Part_Number__c')) : '';
                    this.Description = (sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Description__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Description__c')) : '';
                    this.Category = (sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Category__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Part__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Part__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name')) : ''; 
                    
                    this.Vendor = (sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Vendor__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Part__r').getSobject(Constants.NAMESPACE + 'Vendor__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Part__r').getSobject(Constants.NAMESPACE + 'Vendor__r').get('Name')) : ''; 
                                     
                    this.Part_Type = (sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Part_Type__c') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Part__r').get(Constants.NAMESPACE + 'Part_Type__c')) : 'Part'; 
                    
                } else if(this.Type == null && sobj.get(Constants.NAMESPACE + 'Fee__c') != null) {
                    this.Id = String.valueOf(sobj.get(Constants.NAMESPACE + 'Fee__c'));
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Fees');
                    this.Item = (sobj.getSobject(Constants.NAMESPACE + 'Fee__r').get(Constants.NAMESPACE + 'Code__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Fee__r').get(Constants.NAMESPACE + 'Code__c')) : '';
                    this.Description = (sobj.getSobject(Constants.NAMESPACE + 'Fee__r').get(Constants.NAMESPACE + 'Description__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Fee__r').get(Constants.NAMESPACE + 'Description__c')) : '';
                    this.Category = (sobj.getSobject(Constants.NAMESPACE + 'Fee__r').get(Constants.NAMESPACE + 'Category__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Fee__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Fee__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name')) : ''; 
                
                } else if(this.Type == null && (isSOLI || isOptionFee) && sobj.get(Constants.NAMESPACE + 'Labour_Code__c') != null) {
                    this.Id = String.valueOf(sobj.get(Constants.NAMESPACE + 'Labour_Code__c'));
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Labor Codes');
                    this.Item = (sobj.getSobject(Constants.NAMESPACE + 'Labour_Code__r').get(Constants.NAMESPACE + 'Code__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Labour_Code__r').get(Constants.NAMESPACE + 'Code__c')) : '';
                    this.Description = (sobj.getSobject(Constants.NAMESPACE + 'Labour_Code__r').get(Constants.NAMESPACE + 'Description__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Labour_Code__r').get(Constants.NAMESPACE + 'Description__c')) : '';
                    this.Category = (sobj.getSobject(Constants.NAMESPACE + 'Labour_Code__r').get(Constants.NAMESPACE + 'Category__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Labour_Code__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Labour_Code__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name')) : ''; 
                
                } else if(isSOLI && this.Type == null && sobj.get(Constants.NAMESPACE + 'Sublet__c') != null) {
                    this.Id = String.valueOf(sobj.get(Constants.NAMESPACE + 'Sublet__c'));
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sublets');
                    this.Item = (sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').get(Constants.NAMESPACE + 'Code__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').get(Constants.NAMESPACE + 'Code__c')) : '';
                    this.Description = (sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').get(Constants.NAMESPACE + 'Description__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').get(Constants.NAMESPACE + 'Description__c')) : '';
                    this.Category = (sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').get(Constants.NAMESPACE + 'Category__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name')) : ''; 
                    this.Vendor = (sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').get(Constants.NAMESPACE + 'Vendor__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').getSobject(Constants.NAMESPACE + 'Vendor__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Sublet__r').getSobject(Constants.NAMESPACE + 'Vendor__r').get('Name')) : ''; 
                    
                } else if(isOptionFee && this.Type == null && sobj.get(Constants.NAMESPACE + 'Product__c') != null) {
                    if(sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Type__c') != null) {
                        if(String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Type__c')) == 'Sublet') {
                            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sublets');
                        } else if(String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Type__c')) == 'Warranty Plan') {
                            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Warranty Plan');
                        } else {
                            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Other Product');
                        }
                    }   
                    this.Id = String.valueOf(sobj.get(Constants.NAMESPACE + 'Product__c'));
                    this.Item = (sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Code__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Code__c')) : '';
                    this.Description = (sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Description__c') != null) ? 
                                String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Description__c')) : '';
                    this.Category = (sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Category__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Product__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Product__r').getSobject(Constants.NAMESPACE + 'Category__r').get('Name')) : ''; 
                    
                    this.Vendor = (sobj.getSobject(Constants.NAMESPACE + 'Product__r').get(Constants.NAMESPACE + 'Vendor__c') != null) && 
                                     (sobj.getSobject(Constants.NAMESPACE + 'Product__r').getSobject(Constants.NAMESPACE + 'Vendor__r').get('Name') != null) ?
                                     String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Product__r').getSobject(Constants.NAMESPACE + 'Vendor__r').get('Name')) : ''; 
                }
                
                Decimal qty, price = 0;
                if(isCOLI) {
                    qty = (sobj.get(Constants.NAMESPACE + 'Qty__c') != null) ? 
                                Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Qty__c'))) : 0;
                    /*if(sobj.get(Constants.NAMESPACE + 'Price_When_Tax_Included__c') != null) {
                        price = Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Price_When_Tax_Included__c')));
                    } else */
                    if(sobj.get(Constants.NAMESPACE + 'Price__c') != null) {
                        price = Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Price__c')));
                    }
                    invoiceDate = (sobj.get(Constants.NAMESPACE + 'Invoice_Number__c') != null && 
                                        sobj.getSobject(Constants.NAMESPACE + 'Invoice_Number__r').get(Constants.NAMESPACE + 'Invoice_Date__c') != null) ?
                                        Datetime.valueOf(String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Invoice_Number__r').get(Constants.NAMESPACE + 'Invoice_Date__c'))) :  
                                        null;
                    
                } else if(isSOLI) {
                    qty = (sobj.get(Constants.NAMESPACE + 'Qty_Needed__c') != null) ? 
                                Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Qty_Needed__c'))) : 0;
                    /*if(sobj.get(Constants.NAMESPACE + 'Price_When_Tax_Included__c') != null) {
                        price = Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Price_When_Tax_Included__c')));
                    } else */
                    if(sobj.get(Constants.NAMESPACE + 'Kit_Price__c') != null) {
                        price = Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Kit_Price__c')));
                    }
                    
                    invoiceDate = (sobj.get(Constants.NAMESPACE + 'Service_Order_Header__c') != null && 
                                        sobj.getSobject(Constants.NAMESPACE + 'Service_Order_Header__r').get(Constants.NAMESPACE + 'Invoice_Number__c') != null &&
                                        sobj.getSobject(Constants.NAMESPACE + 'Service_Order_Header__r').getSobject(Constants.NAMESPACE + 'Invoice_Number__r').get(Constants.NAMESPACE + 'Invoice_Date__c') != null) ?
                                        Datetime.valueOf(String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Service_Order_Header__r').getSobject(Constants.NAMESPACE + 'Invoice_Number__r').get(Constants.NAMESPACE + 'Invoice_Date__c'))) :  
                                        null;           
                } else if(isOptionFee) {
                    qty = (sobj.get(Constants.NAMESPACE + 'Qty__c') != null) ? 
                                Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Qty__c'))) : 0;
                    /*if(sobj.get(Constants.NAMESPACE + 'Price_When_Tax_Included__c') != null) {
                        price = Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Price_When_Tax_Included__c')));
                    } else */
                    if(sobj.get(Constants.NAMESPACE + 'Price__c') != null) {
                        price = Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Price__c')));
                    }
                
                    invoiceDate = (sobj.get(Constants.NAMESPACE + 'Deal__c') != null && 
                                        sobj.getSobject(Constants.NAMESPACE + 'Deal__r').get(Constants.NAMESPACE + 'Invoice_Number__c') != null &&
                                        sobj.getSobject(Constants.NAMESPACE + 'Deal__r').getSobject(Constants.NAMESPACE + 'Invoice_Number__r').get(Constants.NAMESPACE + 'Invoice_Date__c') != null) ?
                                        Datetime.valueOf(String.valueOf(sobj.getSobject(Constants.NAMESPACE + 'Deal__r').getSobject(Constants.NAMESPACE + 'Invoice_Number__r').get(Constants.NAMESPACE + 'Invoice_Date__c'))) :  
                                        null;
                }
                
                this.Total_Profit += (sobj.get(Constants.NAMESPACE + 'Per_Item_Profit__c') != null) ? 
                                        Decimal.valueOf(String.valueOf(sobj.get(Constants.NAMESPACE + 'Per_Item_Profit__c'))) : 0;
                this.Qty_Sold += qty;
                this.Total_Revenue += (qty * price);
                if(lastSaleDate == null || lastSaleDate < invoiceDate) {
                    lastSaleDate = invoiceDate;
                } 
            }
            this.Last_Sale = BPUtility.getFormatedDateTime(lastSaleDate);
            this.Average_Price = (this.Qty_Sold != 0) ? (this.Total_Revenue / ((this.Qty_Sold < 0) ? (-1) * this.Qty_Sold : this.Qty_Sold)) : 0;
            this.Average_Profit = (this.Qty_Sold != 0) ? (this.Total_Profit / ((this.Qty_Sold < 0) ? (-1) * this.Qty_Sold : this.Qty_Sold)) : 0;
        }
    }
    
    /**
     * Name: CustomerOrders
     * Description:  Sets the value of the customerOrder
    **/
    public class CustomerOrders {
        public Integer Type {get; private set;}
        public String Order_Number {get; private set;}
        public String Customer_Name {get; private set;}
        public String Status {get; private set;}
        public Decimal Total {get; private set;}
        public Decimal Deal_Total {get; private set;}
        public Decimal Balance_Due {get; private set;}
        public String Owner {get; private set;}
        public String Created {get; private set;}
        public String Modified {get; private set;}
        public String Notes {get; private set;}
        
        public Decimal Deposits {get; private set;}
        public Decimal Invoiced {get; private set;}
        public Decimal Uninvoiced {get; private set;}
        public String Id {get; private set;}
        public String Account_Type {get; private set;}
        
        public CustomerOrders(CO_Header__c coHeaderRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Orders');
            this.Order_Number =  coHeaderRec.Name;
            if(coHeaderRec.CO_Type__c == Constants.CASH_SALE){
                this.Customer_Name = Constants.CASH_SALE.toUpperCase();
            } else if(coHeaderRec.CO_Type__c == Constants.INTERNAL_SERVICE){
                this.Customer_Name = Constants.UNIT_INVENTORY;
            } else {
                this.Customer_Name = coHeaderRec.Customer__r.Name;
            }
            
            this.Status = coHeaderRec.Status__c;
            //START: Modified by nidhi
            //this.Total = (coHeaderRec.Total_Order_Value__c != null) ? coHeaderRec.Total_Order_Value__c : 0;
            this.Deal_Total = (coHeaderRec.Deal_Total__c != null) ? coHeaderRec.Deal_Total__c : 0;
            this.Total = ((coHeaderRec.Order_Total__c != null) ? coHeaderRec.Order_Total__c : 0);
            //END: Modified by nidhi
            this.Balance_Due = coHeaderRec.Total_Balance_Due__c;
            this.Owner = coHeaderRec.Owner__r.Name;
            this.Created = (coHeaderRec.CreatedDate != null) ?  BPUtility.getFormatedDateTime(coHeaderRec.CreatedDate) : null;
            this.Modified = (coHeaderRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(coHeaderRec.LastModifiedDate) : null;
            this.Notes = (coHeaderRec.Last_Comment__c != null) ? coHeaderRec.Last_Comment__c : '';
            this.Id = coHeaderRec.Id;
            this.Deposits = (coHeaderRec.Total_Deposit_And_Payment__c != null) ? coHeaderRec.Total_Deposit_And_Payment__c : 0;
            this.Invoiced = (coHeaderRec.Invoiced_Amount__c != null) ? coHeaderRec.Invoiced_Amount__c : 0;
            this.Uninvoiced = (coHeaderRec.Uninvoiced_Amount__c != null) ? coHeaderRec.Uninvoiced_Amount__c : 0;
            this.Account_Type = (coHeaderRec.Account_Type__c != null) ? coHeaderRec.Account_Type__r.Name : '';
            //this.Balance_Due = coHeaderRec.Total_Balance_Due__c;
        }
    }
    
    public class PartsOrder {
        public Integer Type {get; private set;}
        public String Order_Number {get; private set;}
        public String Customer {get; private set;}
        public String Sale_Type {get; private set;}
        public Decimal Total {get; private set;}
        public String Status {get; private set;}
        public Decimal Deposits {get; private set;}
        public Decimal Invoiced {get; private set;}
        public String Modified {get; private set;}
        public Decimal Parts {get; private set;}
        public Decimal Fees {get; private set;}
        public Decimal Sales_Tax {get; private set;}
        public Decimal Parts_Profit{get; private set;}
        public String Id {get; private set;}
        
        public PartsOrder(CO_Header__c coHeaderRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts Order');
            this.Order_Number =  coHeaderRec.Name;
            this.Customer = coHeaderRec.Customer_Name__c;
        	this.Sale_Type = coHeaderRec.Merchandise_Sale_Type__c; 
            this.Total = ((coHeaderRec.Parts_And_Accessories_Total__c != null) ? coHeaderRec.Parts_And_Accessories_Total__c : 0);
            this.Status = (coHeaderRec.Merchandise_Status__c != null) ? coHeaderRec.Merchandise_Status__c : 'Active' ;
            this.Modified = (coHeaderRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(coHeaderRec.LastModifiedDate) : null;
            this.Deposits = (coHeaderRec.Total_Deposit_And_Payment__c != null) ? coHeaderRec.Total_Deposit_And_Payment__c : 0;
            this.Invoiced = (coHeaderRec.Parts_And_Accessories_Invoiced_Total__c != null) ? coHeaderRec.Parts_And_Accessories_Invoiced_Total__c : 0;
            this.Parts = (coHeaderRec.Merchandise_Pre_Tax_Part_Total__c  != null ? coHeaderRec.Merchandise_Pre_Tax_Part_Total__c : 0);
            this.Fees = (coHeaderRec.Merchandise_Pre_Tax_Fee_Total__c != null ? coHeaderRec.Merchandise_Pre_Tax_Fee_Total__c : 0);
            this.Sales_Tax = (coHeaderRec.Parts_And_Accessories_Tax_Amount__c != null ? coHeaderRec.Parts_And_Accessories_Tax_Amount__c : 0);
            this.Parts_Profit = (coHeaderRec.Merchandise_Profit__c != null ? coHeaderRec.Merchandise_Profit__c : 0);
            this.Id = coHeaderRec.Id;
        }
    }
    
    /**
     * Name: CustomerInvoice
     * Description: Sets the Value of the Customer Invoice
    **/ 
    
    public class CustomerInvoice {
        public Integer Type {get; private set;}
        public String Invoice_Number {get; private set;}
        public String Customer_Name {get; private set;}
        public String Status {get; private set;}
        public Decimal Total {get; private set;}
        public String Order_Number {get; private set;}
        public String Owner {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Id {get; private set;}
        public Decimal Part_Total{get; private set;}
        public Decimal Fee_Total{get; private set;}
        public Decimal Lien_Payout{get; private set;}
        public Decimal Labor_Total{get; private set;}
        public Decimal Unit_Total{get; private set;}
        public Decimal Warranty_Product_Total{get; private set;}
        public Decimal Other_Product_Total{get; private set;}
        public Decimal Trade_In_Total{get; private set;}
        public Decimal Sublet_Total{get; private set;}
        public Decimal SalesTax_Total{get; private set;}
        public String Invoice_Date{get; private set;}
        public Decimal Invoice_Profit{get; private set;}
        public Decimal Deal_Profit{get; private set;}
        public Decimal Stamp_Duty_Total{get; private set;}
        public Decimal Taxable_Total{get; private set;}
        public Decimal Non_Taxable_Total{get; private set;} 
        public Decimal Commission{get; private set;}
        public String Salesperson {get; private set;}
        public String Account_Type {get; private set;}
        
        public CustomerInvoice(CO_Invoice_Header__c coInvoiceHeader) {
            this.Id = coInvoiceHeader.CO_Header__c;
            this.Invoice_Number = coInvoiceHeader.Invoice_Number__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Invoices');
            if(coInvoiceHeader.CO_Header__r.CO_Type__c == Constants.CASH_SALE){
                this.Customer_Name = Constants.CASH_SALE.toUpperCase();
            } else if(coInvoiceHeader.CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE){
                this.Customer_Name = Constants.UNIT_INVENTORY;
            } else {
                this.Customer_Name = coInvoiceHeader.CO_Header__r.Customer__r.Name;
            }
            this.Account_Type = (coInvoiceHeader.CO_Header__c != null && coInvoiceHeader.CO_Header__r.Account_Type__c != null) 
                                ? coInvoiceHeader.CO_Header__r.Account_Type__r.Name : '';
            this.Total = coInvoiceHeader.Total__c;
            this.Status = coInvoiceHeader.Status__c;
            this.Order_Number = coInvoiceHeader.CO_Header__r.Name;
            this.Owner = coInvoiceHeader.CO_Header__r.Owner__r.Name; 
            //this.Created = (coInvoiceHeader.CreatedDate != null) ? coInvoiceHeader.CreatedDate.format('MM/dd/yyyy') : null;
            this.Created = (coInvoiceHeader.CreatedDate != null) ?  BPUtility.getFormatedDateTime(coInvoiceHeader.CreatedDate) : null;
            this.Modified = (coInvoiceHeader.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(coInvoiceHeader.LastModifiedDate) : null;
            //this.Balance_Due = coInvoiceHeader.CO_Header__r.Total_Balance_Due__c;
            this.Part_Total = coInvoiceHeader.Pre_Tax_Part_Total__c;
            this.Fee_Total = coInvoiceHeader.Total_Fee_With_Shop_Supplies__c;
            this.Lien_Payout = coInvoiceHeader.Lien_Payout_Total__c;
            this.Labor_Total = coInvoiceHeader.Pre_Tax_Labour_Total__c;
            this.Sublet_Total = coInvoiceHeader.Pre_Tax_Sublet_Total__c;
            this.Unit_Total = coInvoiceHeader.Pre_Tax_Unit_Total__c;
            
            this.Warranty_Product_Total = (coInvoiceHeader.Pre_Tax_Warranty_Product_Total__c != null) ? coInvoiceHeader.Pre_Tax_Warranty_Product_Total__c : 0;
            this.Other_Product_Total = (coInvoiceHeader.Pre_Tax_Other_Product_Total__c != null) ? coInvoiceHeader.Pre_Tax_Other_Product_Total__c : 0;
            this.Trade_In_Total = (coInvoiceHeader.Pre_Tax_Trade_In_Total__c != null) ? coInvoiceHeader.Pre_Tax_Trade_In_Total__c : 0;
            
            this.SalesTax_Total = coInvoiceHeader.SalesTax_Total__c;
            this.Invoice_Date = (coInvoiceHeader.Invoice_Date__c != null) ?  BPUtility.getFormatedDateTime(coInvoiceHeader.Invoice_Date__c) : null;
            this.Invoice_Profit = coInvoiceHeader.Invoice_Profitability__c;
            this.Deal_Profit = (coInvoiceHeader.Deal_Profitability__c != null) ? coInvoiceHeader.Deal_Profitability__c : 0;
            this.Stamp_Duty_Total = (coInvoiceHeader.Stamp_Duty_Total__c != null) ? coInvoiceHeader.Stamp_Duty_Total__c : 0;
            this.Taxable_Total = (coInvoiceHeader.Taxable_Total__c != null) ? coInvoiceHeader.Taxable_Total__c : 0;
            this.Non_Taxable_Total = (coInvoiceHeader.Non_Taxable_Total__c != null) ? coInvoiceHeader.Non_Taxable_Total__c : 0;
            this.Commission = (coInvoiceHeader.Deal_Commission__c != null) ? coInvoiceHeader.Deal_Commission__c : 0;
            this.Salesperson =coInvoiceHeader.Salesperson__c; 
        }
    }
    
    /**
     * Name: CustomerPayment
     * Description: Sets the Value of the Customer Invoice
    **/ 
    
    public class CustomerPayment {
        public Integer Type {get; private set;}
        public String Payment_Number {get; private set;}
        public String Customer_Name {get; private set;}
        public Decimal Total {get; private set;}
        public String Status {get; private set;}
        public String Order_Number {get; private set;}
        public String Owner {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Payment_Method {get; private set;}
        public String Reverse_Payment_Id {get; private set;}
        public String Id {get; private set;}
        //Dinesh Kumar 07/10/2015
        public String Invoice_Number {get; private set;}
        public String Cash_Drawer {get; private set;}
        public String Account_Type {get; private set;}
        public String Payment_Date {get; private set;}
        
        public CustomerPayment(CO_Invoice_Payment__c coPaymentRec) {
            this.Id = (coPaymentRec.CO_Invoice_Header__c != null) ? coPaymentRec.CO_Invoice_Header__r.CO_Header__c : null;
            this.Payment_Number = coPaymentRec.Name;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Payments');
            if(coPaymentRec.CO_Invoice_Header__c != null) {
                if(coPaymentRec.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == Constants.CASH_SALE){
                    this.Customer_Name = Constants.CASH_SALE.toUpperCase();
                } else if(coPaymentRec.CO_Invoice_Header__r.CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE){
                    this.Customer_Name = Constants.UNIT_INVENTORY;
                } else {
                    this.Customer_Name = coPaymentRec.CO_Invoice_Header__r.CO_Header__r.Customer__r.Name;
                }
            }
            this.Total = coPaymentRec.Amount__c;
            this.Status = (coPaymentRec.CO_Invoice_Header__c != null) ? coPaymentRec.CO_Invoice_Header__r.Status__c : null;
            this.Order_Number = (coPaymentRec.CO_Invoice_Header__c != null) ? coPaymentRec.CO_Invoice_Header__r.CO_Header__r.Name : null;
            this.Owner = (coPaymentRec.CO_Invoice_Header__c != null && coPaymentRec.CO_Invoice_Header__r.CO_Header__r.Owner__c != null) ? coPaymentRec.CO_Invoice_Header__r.CO_Header__r.Owner__r.Name : null;
            this.Created =  BPUtility.getFormatedDateTime(coPaymentRec.CreatedDate);
            this.Modified =  BPUtility.getFormatedDateTime(coPaymentRec.LastModifiedDate);
            this.Payment_Method = coPaymentRec.Payment_Method__c;
            this.Reverse_Payment_Id = (coPaymentRec.Reverse_Payment_From__c != null) ? coPaymentRec.Reverse_Payment_From__r.Name : null;
            //Dinesh Kumar 07/10/2015
            this.Invoice_Number = (coPaymentRec.CO_Invoice_Header__c != null) ? coPaymentRec.CO_Invoice_Header__r.Invoice_Number__c : null;
            this.Account_Type = (coPaymentRec.CO_Invoice_Header__c != null && coPaymentRec.CO_Invoice_Header__r.CO_Header__c != null 
                                    && coPaymentRec.CO_Invoice_Header__r.CO_Header__r.Account_Type__c != null) 
                                    ? coPaymentRec.CO_Invoice_Header__r.CO_Header__r.Account_Type__r.Name : null;
            
			this.Cash_Drawer = (coPaymentRec.Cash_Drawer__c != null) ? coPaymentRec.Cash_Drawer__r.Name : '';
			this.Payment_Date = (coPaymentRec.Payment_Date__c != null) ? coPaymentRec.Payment_Date__c.format() : system.today().format();
        }
        
        public CustomerPayment(CO_Deposit__c coDepositRec) {
            this.Id = (coDepositRec.CO_Header__c != null) ? coDepositRec.CO_Header__c : null;
            this.Payment_Number = coDepositRec.Name;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Payments');
            if(coDepositRec.CO_Header__c != null) {
                if(coDepositRec.CO_Header__r.CO_Type__c == Constants.CASH_SALE){
                    this.Customer_Name = Constants.CASH_SALE.toUpperCase();
                } else if(coDepositRec.CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE){
                    this.Customer_Name = Constants.UNIT_INVENTORY;
                } else {
                    this.Customer_Name = coDepositRec.CO_Header__r.Customer__r.Name;
                }
            }
            this.Total = coDepositRec.Amount__c;
            this.Status = (coDepositRec.CO_Invoice_Header__c != null) ? coDepositRec.CO_Invoice_Header__r.Status__c : null;
            this.Order_Number = (coDepositRec.CO_Header__c != null) ? coDepositRec.CO_Header__r.Name : null;
            this.Owner = (coDepositRec.CO_Header__c != null && coDepositRec.CO_Header__r.Owner__c != null) ? coDepositRec.CO_Header__r.Owner__r.Name : null;
            this.Created =  BPUtility.getFormatedDateTime(coDepositRec.CreatedDate);
            this.Modified =  BPUtility.getFormatedDateTime(coDepositRec.LastModifiedDate);
            this.Payment_Method = coDepositRec.Payment_Method__c;
            this.Cash_Drawer = (coDepositRec.Cash_Drawer__c != null) ? coDepositRec.Cash_Drawer__r.Name : '';
            //this.Reverse_Payment_Id = (coPaymentRec.Reverse_Payment_From__c != null) ? coPaymentRec.Reverse_Payment_From__r.Name : null;
            this.Payment_Date = (coDepositRec.Payment_Date__c != null) ? coDepositRec.Payment_Date__c.format() : system.today().format();
        }
    }
    
    
    /**
     * Name: CustomerSales
     * Description: Sets the value of Customer Sales
    **/ 
    public class CustomerSales {
        
        public Integer Type {get; private set;}
        public String Id_Number {get; private set;}
        public String Name {get; private set;}
        public String Status {get; private set;}
        public Decimal Total {get; private set;}
        public Decimal Balance_Due {get; private set;}
        public String Order_Number {get; private set;}
        public String Owner {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public Decimal Deposits {get; private set;}
        public Decimal Payments {get; private set;}
        
        public String Id {get; private set;}
          
         public CustomerSales(Sobject sobjRec, String searchName) {
            this.Id = String.valueOf(sobjRec.get('Id'));
            String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            this.Id_Number = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
            this.Balance_Due = 0;
            this.Deposits = 0;
            this.Payments = 0;
            
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get(searchName);
            this.Created =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('CreatedDate'))));
            this.Modified =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('LastModifiedDate'))));
            if(objectName == Constants.NAMESPACE +'CO_Header__c') {
            	this.Name = 'Parts & accessories';
                if(sobjRec.getSobject(Constants.NAMESPACE +'Customer__r') == null) {
                    if(sobjRec.get(Constants.NAMESPACE +'CO_Type__c') == Constants.CASH_SALE) {
                        this.Name += ' - ' + Constants.CASH_SALE.toUpperCase();
                    } else if(sobjRec.get(Constants.NAMESPACE +'CO_Type__c') == Constants.INTERNAL_SERVICE) {
                        this.Name += ' - ' + Constants.UNIT_INVENTORY.toUpperCase();
                    }
                } else {
                    this.Name += (sobjRec.getSobject(Constants.NAMESPACE +'Customer__r') != null &&
                    	 sobjRec.getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null ) ? 
                    	 ' - ' + String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : null;
                }
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Merchandise_Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Merchandise_Status__c')) : 'Active';
                this.Total =  ((sobjRec.get(Constants.NAMESPACE +'Order_Total__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Order_Total__c'))) : 0); 
                this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'Owner__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
                
            }
         }
         
        public CustomerSales(Sobject sobjRec) {
            this.Id = String.valueOf(sobjRec.get('Id'));
            String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            this.Id_Number = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
            
            this.Deposits = 0;
            this.Payments = 0;
            
            
            // Matches for the Object of the CustomerSales group and then assigns to it
            if(objectName == Constants.NAMESPACE +'CO_Header__c') {
                
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Orders');
                
                if(sobjRec.getSobject(Constants.NAMESPACE +'Customer__r') == null) {
                    if(sobjRec.get(Constants.NAMESPACE +'CO_Type__c') == Constants.CASH_SALE) {
                        this.Name = Constants.CASH_SALE.toUpperCase();
                    } else if(sobjRec.get(Constants.NAMESPACE +'CO_Type__c') == Constants.INTERNAL_SERVICE) {
                        this.Name = Constants.UNIT_INVENTORY.toUpperCase();
                    }
                } else {
                    this.Name =  (sobjRec.getSobject(Constants.NAMESPACE +'Customer__r') != null &&  sobjRec.getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null ) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : null;
                }
                
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                this.Total =  ((sobjRec.get(Constants.NAMESPACE +'Order_Total__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Order_Total__c'))) : 0); 
                this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'Owner__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
                this.Balance_Due = (sobjRec.get(Constants.NAMESPACE +'Total_Balance_Due__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Total_Balance_Due__c'))) : null;
                this.Deposits = (sobjRec.get(Constants.NAMESPACE +'Total_Deposit_And_Payment__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Total_Deposit_And_Payment__c'))) : 0;
                this.Payments = (sobjRec.get(Constants.NAMESPACE +'Invoiced_Amount__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Invoiced_Amount__c'))) : 0;
                
            } else if(objectName == Constants.NAMESPACE +'CO_Invoice_Header__c') {
                this.Id = ((sobjRec.get(Constants.NAMESPACE +'CO_Header__c') != null) ? 
                                    String.valueOf(sobjRec.get(Constants.NAMESPACE +'CO_Header__c')) : '');
                
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Invoices');
                this.Id_Number = (sobjRec.get('Invoice_Number__c') != null) ? String.valueOf(sobjRec.get('Invoice_Number__c')) : null;
                
                if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') == null) {
                    if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'CO_Type__c') == Constants.CASH_SALE) {
                        this.Name = Constants.CASH_SALE.toUpperCase();
                    } else if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'CO_Type__c') == Constants.INTERNAL_SERVICE) {
                        this.Name = Constants.UNIT_INVENTORY.toUpperCase();
                    }
                } else {
                    this.Name = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null && 
                             sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : null;
                }
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                
                //this.Total =  (sobjRec.getSobject('CO_Header__r') != null &&  sobjRec.getSobject('CO_Header__r').get('Total_Order_Value__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.getSobject('CO_Header__r').get('Total_Order_Value__c'))) : null;
                
                this.Order_Number = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&
                                        sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name') != null ) ? 
                                        String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) : null;
                this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Owner__c') != null &&  sobjRec.getSobject('CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
                this.Total = (sobjRec.get(Constants.NAMESPACE +'Total__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Total__c'))) : null;
                //this.Balance_Due = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Total_Balance_Due__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Total_Balance_Due__c'))) : null;              
                
                Decimal amountPaid = (sobjRec.get(Constants.NAMESPACE +'Total_Amount_Except_Charge_Account__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Total_Amount_Except_Charge_Account__c'))) : 0;             
                
                this.Balance_Due = (this.Total != null ? this.Total : 0) - amountPaid;
            } else if(objectName == Constants.NAMESPACE +'CO_Invoice_Payment__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Payments');
                this.Id = ((sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r') != null) ? 
                                    String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').get('CO_Header__c')) : '');
                
                if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r') != null && 
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') == null) {
                    
                    if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'CO_Type__c') == Constants.CASH_SALE) {
                        this.Name = Constants.CASH_SALE.toUpperCase();
                    } else if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'CO_Type__c') == Constants.INTERNAL_SERVICE) {
                        this.Name = Constants.UNIT_INVENTORY.toUpperCase();
                    }           
                } else {
                    this.Name = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r') != null && 
                                sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
                                sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null) ? 
                                        String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : 
                                        null;
                }
                this.Total = (sobjRec.get(Constants.NAMESPACE +'Amount__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Amount__c'))) : null;
                
                this.Order_Number = ( (sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r') != null) &&  
                                      (sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) != null) ? 
                                    String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) : null;
                this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Owner__c') != null &&
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
            
            } else if(objectName == Constants.NAMESPACE +'CO_Deposit__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Payments');
                this.Id = ((sobjRec.get(Constants.NAMESPACE +'CO_Header__c') != null) ? 
                                    String.valueOf(sobjRec.get(Constants.NAMESPACE +'CO_Header__c')) : '');
                                    
                if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null && 
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') == null) {
                    
                    if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'CO_Type__c') == Constants.CASH_SALE) {
                        this.Name = Constants.CASH_SALE.toUpperCase();
                    } else if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'CO_Type__c') == Constants.INTERNAL_SERVICE) {
                        this.Name = Constants.UNIT_INVENTORY.toUpperCase();
                    }           
                } else {
                    this.Name = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  
                                sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
                                sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null) ? 
                                        String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : 
                                        null;
                }
                this.Total = (sobjRec.get(Constants.NAMESPACE +'Amount__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Amount__c'))) : null;
                
                this.Order_Number = ( (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null) &&  
                                      (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) != null) ? 
                                    String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) : null;
                this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Owner__c') != null &&
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
            } else if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                this.Id = ((sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null) ? 
                                    String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Id')) : '');
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Service Jobs');
                this.Id_Number = ((sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null) &&  
                                      (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) != null) ? 
                                    String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) : null;
                if(sobjRec.get('SO_Type__c') != null && sobjRec.get('SO_Type__c') == Constants.INTERNAL_SERVICE) {
                    this.Name = Constants.UNIT_INVENTORY;
                } else {
                    this.Name = (sobjRec.get('Name__c') != null) ? sobjRec.get('Name__c') + '': '';
                    if((sobjRec.get('Name__c') != null) && (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  
                                    sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
                                    sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null)) {
                        this.Name += ' - ';
                    }
                    this.Name += (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  
                                    sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
                                    sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null) ? 
                                            String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : 
                                            '';
                }
                
                this.Total = (sobjRec.get(Constants.NAMESPACE +'Total__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Total__c'))) : 0;
                //if(sobjRec.get(Constants.NAMESPACE +'SO_Type__c') != null && sobjRec.get(Constants.NAMESPACE +'SO_Type__c') != 'Deal') {
                    this.Total += (sobjRec.get(Constants.NAMESPACE +'Tax_Amount__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Tax_Amount__c'))) : 0;
                //} 
                
                this.Order_Number = '';
                
                this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Owner__c') != null &&
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
                
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Work_Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Work_Status__c')) : null;
            } else if(objectName == Constants.NAMESPACE +'Deal__c') {
                this.Id = ((sobjRec.get(Constants.NAMESPACE +'CO_Header__c') != null) ? 
                                    String.valueOf(sobjRec.get(Constants.NAMESPACE +'CO_Header__c')) : '');
                this.Id_Number = ((sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null) &&  
                                      (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) != null) ? 
                                    String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) : null;
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Unit Deals');
				if(sobjRec.get(Constants.NAMESPACE +'Type__c') != null){
					if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
			                sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null){
						this.Name = String.valueOf(sobjRec.get(Constants.NAMESPACE +'Type__c')) + ' ' + String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')); 							
					} else {
							this.Name = String.valueOf(sobjRec.get(Constants.NAMESPACE +'Type__c'));
					}
	
				} else {
					if((sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
				                sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null)){
						this.Name = String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')); 							
					} else {
						this.Name = null;
					}
				}				
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                this.Total =  ((sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Deal_Total__c') != null) ?  Decimal.valueOf(String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Deal_Total__c'))) : 0); 
                this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get(Constants.NAMESPACE +'Owner__c') != null &&
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
                this.Balance_Due = null;
                this.Deposits = null;
                this.Payments = null;
                this.Order_Number = null;
            }
            
            this.Created =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('CreatedDate'))));
            this.Modified =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('LastModifiedDate'))));
        }
    }   
    
    
    /**
     * Name: Category
     * Description: Sets the value of the Category
    **/ 
    
    public class Category{
        public String Id {get; private set;}
        public Integer Type {get; private set;}
        public String Code {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String OwnerId {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Description {get; private set;}
        public String Active {get; private set;}
        
        public Category(Category__c categoryRecord) {
            this.Id = categoryRecord.Id;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Item Categories');
            this.Code = categoryRecord.Unique_Category__c;
            this.Status = categoryRecord.Status__c;
            this.Owner = categoryRecord.Owner.Name;
            this.Created = (categoryRecord.CreatedDate != null) ?  BPUtility.getFormatedDateTime(categoryRecord.CreatedDate) : null;
            this.Modified = (categoryRecord.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(categoryRecord.LastModifiedDate) : null;
            this.Description = categoryRecord.Description__c;
            this.Active = (categoryRecord.Active__c) ? 'Active' : 'Inactive';
        }
    }
    
    /**
     * Name: PriceLevel
     * Description: Sets the value of the PriceLevel
    **/ 
    
    public class PriceLevel{
        public String Id {get; private set;}
        public String Code {get; private set;}
        public Integer Type {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String OwnerId {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Description {get; private set;}
        public String Active {get; private set;}
        
        public PriceLevel(Price_Level__c priceLevel) {
            this.Id = priceLevel.Id;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Price Levels');
            this.Code = priceLevel.Name__c;
            this.Status = priceLevel.Status__c;
            this.Owner = priceLevel.Owner.Name;
            this.Created = (priceLevel.CreatedDate != null) ?  BPUtility.getFormatedDateTime(priceLevel.CreatedDate): null;
            this.Modified = (priceLevel.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(priceLevel.LastModifiedDate) : null;
            this.Description = priceLevel.Description__c;
            this.Active = (priceLevel.Active__c) ? 'Active' : 'Inactive';
        }
    }
    
    /**
     * Name: SalesTax
     * Description: Sets the value of the SalesTax
    **/ 
    
    public class SalesTax{
        public String Id {get; private set;}
        public String Code {get; private set;}
        public Integer Type {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Description {get; private set;}
        public String Active {get; private set;}
        
        public SalesTax(Sales_Tax__c salesTax) {
            this.Id = salesTax.Id;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sales Taxes');
            this.Code = salesTax.Name__c;
            this.Status = salesTax.Status__c;
            this.Owner = salesTax.Owner.Name;
            this.Created = (salesTax.CreatedDate != null) ?  BPUtility.getFormatedDateTime(salesTax.CreatedDate) : null;
            this.Modified = (salesTax.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(salesTax.LastModifiedDate) : null;
            this.Description = salesTax.Forms_Label__c;
            this.Active = (salesTax.Active__c) ? 'Active' : 'Inactive';
        }
    }
    
    /**
     * Name: Setting
     * Description: Sets the value of the Setting according to its entity type
    **/ 
    
    public class Setting{
        public String Id {get; private set;}
        public Integer Type {get; private set;}
        public String Code {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String OwnerId {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Description {get; private set;}
        public String Active {get; private set;}
        
        public Setting(sObject setting) {
            this.Id = String.valueOf(setting.get('Id'));
            this.Status = String.valueOf(setting.get(Constants.NAMESPACE +'Status__c'));
            this.Owner = (setting.getSObject('Owner') != null) ? String.valueOf(setting.getSObject('Owner').get('Name')) : null;
            this.OwnerId =  (setting.getSObject('Owner') != null) ? String.valueOf(setting.getSObject('Owner').get('Id')) : null;
            this.Created =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(setting.get('CreatedDate'))));
            this.Modified =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(setting.get('LastModifiedDate'))));
            this.Active = 'Yes';
            // Checks for the Object and assigns value accordingly
            String objectName = ((Id)setting.get('Id')).getSObjectType().getDescribe().getName();
            if(objectName == Constants.NAMESPACE + 'Category__c') {
                this.Code = String.valueOf(setting.get(Constants.NAMESPACE +'Unique_Category__c'));
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Item Categories');
                this.Description = String.valueOf(setting.get(Constants.NAMESPACE +'Description__c'));
            } else if(objectName == Constants.NAMESPACE +'Price_Level__c') {
                this.Code = String.valueOf(setting.get(Constants.NAMESPACE +'Name__c'));
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Price Levels');
                this.Description = String.valueOf(setting.get(Constants.NAMESPACE +'Description__c'));
            } else if(objectName == Constants.NAMESPACE +'Sales_Tax__c') {
                this.Code = String.valueOf(setting.get(Constants.NAMESPACE +'Name__c'));
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sales Taxes');
                this.Description = String.valueOf(setting.get(Constants.NAMESPACE +'Forms_Label__c'));
            }
            this.Active = Boolean.valueOf(String.valueOf(setting.get(Constants.NAMESPACE +'Active__c'))) ? 'Active' : 'Inactive';
        }
    }
    
    /**
     * Name: VendorOrder
     * Description: Sets the value of the VendorOrder
    **/ 
    public class VendorOrder {
        
        public Integer Type {get; private set;}
        public String Order_Number {get; private set;}
        public String Vendor {get; private set;}
        public String Status {get; private set;}
        public Decimal Total {get; private set;}
        public String Owner {get; private set;}
        public String Created {get; private set;}
        public String Modified {get; private set;}
        public String Order_Type {get; private set;}
        public Decimal Received {get; private set;}
        public String Account_Type {get; private set;}
        
        public String Id {get; private set;}
        
        public VendorOrder(Vendor_Order_Header__c voHeaderRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Orders');
            this.Order_Number = voHeaderRec.Name;
            this.Vendor =  voHeaderRec.Vendor__r.Name;
            this.Status = voHeaderRec.Status__c;
            this.Total = voHeaderRec.Total__c; 
            this.Received = voHeaderRec.Total_Recieved__c; 
            this.Owner = voHeaderRec.Owner__r.Name;
            this.Created = (voHeaderRec.CreatedDate != null) ?  BPUtility.getFormatedDateTime(voHeaderRec.CreatedDate) : null;
            this.Modified = (voHeaderRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(voHeaderRec.LastModifiedDate) : null;
            this.Order_Type = (voHeaderRec.Purchase_Order_Type__c != null) ? voHeaderRec.Purchase_Order_Type__r.Code__c : null;
            this.Id = voHeaderRec.Id;
            this.Account_Type = (voHeaderRec.Vendor__c != null && voHeaderRec.Vendor__r.Vendor_Account_Type__c != null) ? voHeaderRec.Vendor__r.Vendor_Account_Type__r.Name : null;
        }
        
        public VendorOrder(Return_VO_Header__c returnVOHeaderRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Return');
            this.Order_Type = 'Return';
            this.Order_Number = returnVOHeaderRec.Name;
            this.Vendor =  returnVOHeaderRec.Vendor__r.Name;
            this.Owner = returnVOHeaderRec.Owner.Name;
            this.Status = returnVOHeaderRec.Status__c;
            this.Total = (returnVOHeaderRec.Total__c != null) ? (returnVOHeaderRec.Total__c).setScale(2, RoundingMode.HALF_UP) : 0.00; 
            //this.Received = returnVOHeaderRec.Return_Total__c; 
            this.Created = (returnVOHeaderRec.CreatedDate != null) ?  BPUtility.getFormatedDateTime(returnVOHeaderRec.CreatedDate) : null;
            this.Modified = (returnVOHeaderRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(returnVOHeaderRec.LastModifiedDate) : null;
            this.Id = returnVOHeaderRec.Id;
            this.Account_Type = (returnVOHeaderRec.Vendor__c != null && returnVOHeaderRec.Vendor__r.Vendor_Account_Type__c != null) ? returnVOHeaderRec.Vendor__r.Vendor_Account_Type__r.Name : null;
    }   
    }   
    
    /**
     * Name: VendorInvoice
     * Description: Sets the value of the VendorInvoice
    **/ 
    public class VendorInvoice {
        
        public Integer Type {get; private set;}
        public String Invoice_Number {get; private set;}
        public String Vendor {get; private set;}
        public string VendorId {get; private set;}
        public Decimal Total {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String OwnerId {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Id {get; private set;}
        public String Account_Type {get; private set;}
        
        public VendorInvoice(Vendor_Invoicing_Header__c voInvoiceRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Invoices');
            this.Invoice_Number = voInvoiceRec.Vendor_Invoice_Number__c;
            this.Vendor =  voInvoiceRec.Vendor__r.Name;
            this.Status = voInvoiceRec.Status__c;
            this.Owner = voInvoiceRec.Owner__r.Name;
            this.Created = (voInvoiceRec.CreatedDate != null) ?  BPUtility.getFormatedDateTime(voInvoiceRec.CreatedDate) : null;
            this.Modified = (voInvoiceRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(voInvoiceRec.LastModifiedDate) : null;
            this.Account_Type = (voInvoiceRec.Vendor__c != null && voInvoiceRec.Vendor__r.Vendor_Account_Type__c != null) ? voInvoiceRec.Vendor__r.Vendor_Account_Type__r.Name : null;
            this.Total = voInvoiceRec.Total_With_Tax__c;
            this.Id = voInvoiceRec.Id;
        }
    }
    
    //Dinesh Kumar 10/10/2016
    /**
     * Name: Part Needed
     * Description: Sets the value of the VendorInvoice
    **/ 
    public class PartNeeded {
        public Integer Type {get; private set;}
        public String Customer {get; private set;}
        public String Item_Description {get; private set;}
        public string Needed_For {get; private set;}
        public Decimal Qty_Needed {get; private set;}
        public String Status {get; private set;}
        public Decimal Total_Cost {get; private set;}
        public String Vendor {get; private set;}
        public String Id {get; private set;}
        public String PartId {get; private set;}
        public String CoHeaderId {get; private set;}
        public String Created {get; private set;}
        public String Modified {get; private set;}
        public String Part_Type {get; private set;}
        
        public PartNeeded(Vendor_Order_Line_Item__c partNeededRec, Business_Profile__c dealerInfoRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts Needed');
            this.Needed_For = partNeededRec.Needed_For__c;  
            this.Customer = partNeededRec.Customer__c;
            
            this.Part_Type = (partNeededRec.Part__r.Part_Type__c != null) ? partNeededRec.Part__r.Part_Type__c :'Part';
            if(partNeededRec.Part__c != null) {
            	this.Vendor = partNeededRec.Part__r.Vendor__r.Name;
            	this.Item_Description = partNeededRec.Part__r.Item_Description__c;
            } else if(partNeededRec.Sublet__c != null) {
            	this.Vendor = partNeededRec.Sublet__r.Vendor__r.Name;
            	
            	String itemDesc = (partNeededRec.Service_Order_Line_Item__r.Item_Code__c != null) ? partNeededRec.Service_Order_Line_Item__r.Item_Code__c : '';
	        	itemDesc += (partNeededRec.Service_Order_Line_Item__r.Item_Description__c != null) ? 
	        		((itemDesc.length() > 0 ? ' - ' : '' ) + partNeededRec.Service_Order_Line_Item__r.Item_Description__c) : '';
	        	this.Item_Description = itemDesc;
            	this.Part_Type = 'Sublet';
            }
            if(partNeededRec.Is_required_For_Customer__c || partNeededRec.Is_Service__c) {
                //this.Needed_For = partNeededRec.CO_Header__r.Name;    
                //this.Customer = partNeededRec.CO_Header__r.Customer__r.Name;
                this.Id = partNeededRec.CO_Header__c;
                this.CoHeaderId = partNeededRec.CO_Header__c;
            } else {
                //this.Needed_For = 'STOCK';    
                this.PartId = partNeededRec.Part__c;
                this.Id = partNeededRec.Part__c;
                //this.Customer = partNeededRec.Dealer_Name__c;
            }

                        this.Qty_Needed = partNeededRec.Qty_Needed__c;
            this.Status = 'Required';
            if(partNeededRec.Qty_Needed__c != null && partNeededRec.Cost__c != null) {
                this.Total_Cost = partNeededRec.Total_Cost__c;
            } else {
                this.Total_Cost = 0;
            }
            
            this.Created =  BPUtility.getFormatedDateTime(partNeededRec.CreatedDate);
            this.Modified =  BPUtility.getFormatedDateTime(partNeededRec.LastModifiedDate);
        }
    }
    
    /**
     * Name: User
     * Description: Sets the value of the VendorInvoice
    **/ 
    public class UserRec {
        
        public Integer Type {get; private set;}
        public String Name {get; private set;}
        public String Email {get; private set;}
        public string Status {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Id {get; private set;}
        
        public UserRec(User userRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Users');
            this.Name = userRec.Name;
            this.Email =  userRec.Email;
            this.Status = userRec.IsActive ? 'Active' : 'Inactive';
            this.Created = (userRec.CreatedDate__c != null) ? getFormattedDate(String.valueOf(userRec.CreatedDate__c)) : null;
            this.Modified = (userRec.LastModifiedDate__c != null) ? getFormattedDate(String.valueOf(userRec.LastModifiedDate__c)) : null;
            this.Id = userRec.Id;
        }
    }
    
    public class ServiceJob {
        
        public Integer Type {get; private set;}
        public String Order_Number {get; private set;}
        public String Customer {get; private set;}
        public String Job {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        public Decimal Total {get; private set;}
        public String Id {get; private set;}
        
        public Decimal Hrs_Billed {get; private set;}
        public String Technician {get; private set;}
        public Decimal Hrs_Logged {get; private set;}
        public String Unit {get; private set;}
        public String Concern {get; private set;}
        public String Job_Type {get; private set;}
        
        public Decimal Parts_Total {get; private set;}
        public Decimal Labor_Total {get; private set;}
        public Decimal Fees_Total {get; private set;}
        public Decimal Sublet_Total {get; private set;}
        public Decimal Tax_Total {get; private set;}
        public String Scheduled {get; private set;}
        public String VIN {get; private set;}
        public String Plate_Number {get; private set;}
        
        public ServiceJob(Service_Order_Header__c soHeaderRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Service Jobs');
            this.Order_Number = (soHeaderRec.CO_Header__c != null ) ? (soHeaderRec.CO_Header__r.Name) : '';
            
            if(soHeaderRec.SO_Type__c == Constants.CASH_SALE) {
                this.Customer = Constants.CASH_SALE.toUpperCase();
            } else if(soHeaderRec.SO_Type__c == Constants.INTERNAL_SERVICE){
                this.Customer = Constants.UNIT_INVENTORY;
            } else {
                this.Customer = (soHeaderRec.CO_Header__c != null && soHeaderRec.CO_Header__r.Customer__c != null) ? 
                                    (soHeaderRec.CO_Header__r.Customer__r.Name) : '';
            }
            
            this.Job = soHeaderRec.Name__c;
            this.Status = soHeaderRec.Work_Status__c;
            this.Modified = (soHeaderRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(soHeaderRec.LastModifiedDate) : null;
            this.Id = soHeaderRec.CO_Header__c;
            this.Total = (soHeaderRec.Total__c != null) ? soHeaderRec.Total__c : 0;
            /*if(soHeaderRec.Tax_Amount__c != null ) { //&& soHeaderRec.SO_Type__c != 'Deal') {
                this.Total += soHeaderRec.Tax_Amount__c;
            }*/
            
            this.Hrs_Billed = (soHeaderRec.Hrs_Billed__c != null) ? soHeaderRec.Hrs_Billed__c : 0;
            this.Technician = soHeaderRec.Technician_Name__c;
            this.Hrs_Logged = (soHeaderRec.Hrs_Logged__c != null) ? soHeaderRec.Hrs_Logged__c : 0;
            if(soHeaderRec.Customer_Owned_Unit__c != null) {
                if(soHeaderRec.Customer_Owned_Unit__r.Unit_Type__c == 'STOCK') {
                    this.Unit = soHeaderRec.Customer_Owned_Unit__r.Stock_Id__c;
                } else {
                    this.Unit = soHeaderRec.Customer_Owned_Unit__r.Unit_Id__c;
                }
                this.VIN = (soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c != null) ? soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c : '';
                this.Plate_Number = (soHeaderRec.Customer_Owned_Unit__r.Plate__c != null) ? soHeaderRec.Customer_Owned_Unit__r.Plate__c : '';
            }
            this.Concern = (soHeaderRec.SO_Concern__c != null) ? soHeaderRec.SO_Concern__c.replaceAll('\n',',') : '';
            this.Job_Type = (soHeaderRec.Transaction_Type__c != null) ? soHeaderRec.Transaction_Type__r.Code_Label__c : '';
            
            this.Parts_Total = (soHeaderRec.Total_Parts__c != null) ? soHeaderRec.Total_Parts__c : 0;
            this.Labor_Total = (soHeaderRec.Total_Labor__c != null) ? soHeaderRec.Total_Labor__c : 0;
            this.Fees_Total = (soHeaderRec.Total_Fee_With_Shop_Supplies__c != null) ? soHeaderRec.Total_Fee_With_Shop_Supplies__c : 0;
            this.Sublet_Total = (soHeaderRec.Total_Sublet__c != null) ? soHeaderRec.Total_Sublet__c : 0;
            this.Tax_Total = (soHeaderRec.Total_Tax__c != null) ? soHeaderRec.Total_Tax__c : 0;
            if(soHeaderRec.Scheduled_Date__c != null) {
                this.Scheduled =  BPUtility.getFormatedDateTime(Datetime.newInstance(soHeaderRec.Scheduled_Date__c.year(), soHeaderRec.Scheduled_Date__c.month(), soHeaderRec.Scheduled_Date__c.day()));
            }
        }
    }
    
    /**
     * Name: VendorRecieving
     * Description: Sets the value of the VendorRecieving
    **/
    public class VendorRecieving { 
        
        public Integer Type {get; private set;}
        public String Reciept_Number {get; private set;}
        public String Vendor {get; private set;}
        public Decimal Total {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        public String Account_Type {get; private set;}
        public String Id {get; private set;}
        
        public VendorRecieving(Vendor_Receiving_Header__c vrHeaderRec) {
            this.Id = vrHeaderRec.Id;
            this.Reciept_Number = vrHeaderRec.Receipt_Number__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Receivings');
            this.Vendor =  vrHeaderRec.Vendor__r.Name;
            this.Status = vrHeaderRec.Status__c;
            this.Owner = vrHeaderRec.Owner__r.Name;
            this.Created = (vrHeaderRec.CreatedDate != null) ?  BPUtility.getFormatedDateTime(vrHeaderRec.CreatedDate) : null;
            this.Modified = (vrHeaderRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(vrHeaderRec.LastModifiedDate) : null;
            this.Account_Type = (vrHeaderRec.Vendor__c != null && vrHeaderRec.Vendor__r.Vendor_Account_Type__c != null) ? vrHeaderRec.Vendor__r.Vendor_Account_Type__r.Name : null;
            this.Total = vrHeaderRec.Receiving_Total__c;
        }
        
    }
    
    //START: Added by Nidhi - #1152 - 19-10-2016
    public class InventoryUnit {
        
        public Integer Type {get; private set;}
        public String Id {get; private set;}
        //public String Name {get; private set;}
        public String Stock_Number {get; private set;}
        public Decimal Year {get; private set;}
        public String Make {get; private set;}
        public String Model {get; private set;}
        public String SubModel {get; private set;}
        public String Ext_Colour {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        public String VIN {get; private set;}
        public String New_Unit {get; private set;}
        
        public Decimal Base_Unit_Price {get; private set;}
        public Decimal Factory_Options {get; private set;}
        public Decimal Dealer_Options {get; private set;}
        public Decimal Total_Price {get; private set;}
        public Decimal Base_Unit_Cost {get; private set;}
        public Decimal Factory_Option_Cost {get; private set;}
        public Decimal Dealer_Option_Cost {get; private set;}
        public Decimal Deal_Options_WIP {get; private set;}
        public Decimal Total_Cost {get; private set;}
        
        public String Category {get; private set;}
        public String Stocked {get; private set;}
        public Decimal Age {get; private set;}
        public String Key_Number {get; private set;}
        public String Engine_Number {get; private set;}
        public String Other_Number {get; private set;}
        public String Int_Colour {get; private set;}
        public String Location {get; private set;}
        
        public String Date_Stocked_Out {get; private set;}
        public String Taxable {get; private set;}
        public String Applicable_Tax {get; private set;}
        public Decimal Cylinders {get; private set;}
        public String Automatic {get; private set;}
        public String Manufactured_Date {get; private set;}
        public Decimal Mileage {get; private set;}
        public String Plate_Number {get; private set;}
        public String Reg_Expiry {get; private set;}
        public String Tags {get; private set;}
        public String Unit_Type;
        public String Mileage_Type {get; private set;}
        public String Compliance_Date {get; private set;}
        public String Year_Of_1st_Rego {get; private set;}
        public String Registration_Serial {get; private set;}
        
        public InventoryUnit(Customer_Owned_Unit__c stockUnitRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Inventory Unit');
            this.Id = stockUnitRec.Id;
            //this.Name = stockUnitRec.Name;
            this.Stock_Number = stockUnitRec.Stock_Id__c != null ? stockUnitRec.Stock_Id__c : stockUnitRec.Unit_Number__c;
            this.Year = stockUnitRec.Year__c;
            this.Make = (stockUnitRec.Unit_Make__c != null) ? stockUnitRec.Unit_Make__r.Name : '';
            this.Model = (stockUnitRec.Unit_Model__c != null) ? stockUnitRec.Unit_Model__r.Name__c : '';
            this.SubModel = (stockUnitRec.Sub_Model__c != null) ? stockUnitRec.Sub_Model__r.Sub_Model_Name__c : '';
            this.Ext_Colour = stockUnitRec.Colour__c;
            this.Status = stockUnitRec.Status__c;
            this.Modified = (stockUnitRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(stockUnitRec.LastModifiedDate) : null;
            this.VIN = (stockUnitRec.VIN_Number_Formula__c == null) ? '' : stockUnitRec.VIN_Number_Formula__c;
            if(stockUnitRec.New_Unit__c != null) {
                if(stockUnitRec.New_Unit__c) {
                    this.New_Unit = 'Yes';
                } else {
                    this.New_Unit = 'No';
                }
            }
            
            this.Base_Unit_Price = ((stockUnitRec.Total_Base_Unit_Price__c == null) ? 0 : stockUnitRec.Total_Base_Unit_Price__c).setScale(2, RoundingMode.HALF_UP);
            this.Factory_Options = ((stockUnitRec.Total_Factory_Options_Price__c == null) ? 0 : stockUnitRec.Total_Factory_Options_Price__c).setScale(2, RoundingMode.HALF_UP);
            this.Dealer_Options = ((stockUnitRec.Total_Dealer_Options_Price__c == null) ? 0 : stockUnitRec.Total_Dealer_Options_Price__c).setScale(2, RoundingMode.HALF_UP);
            this.Total_Price = ((stockUnitRec.Total_Price__c == null) ? 0 : stockUnitRec.Total_Price__c).setScale(2, RoundingMode.HALF_UP);
            this.Base_Unit_Cost = ((stockUnitRec.Total_Base_Units_Cost__c == null) ? 0 : stockUnitRec.Total_Base_Units_Cost__c).setScale(2, RoundingMode.HALF_UP);
            this.Factory_Option_Cost = ((stockUnitRec.Total_Factory_Options_Cost__c == null) ? 0 : stockUnitRec.Total_Factory_Options_Cost__c).setScale(2, RoundingMode.HALF_UP);
            this.Dealer_Option_Cost = ((stockUnitRec.Total_Dealer_Options_Cost__c == null) ? 0 : stockUnitRec.Total_Dealer_Options_Cost__c).setScale(2, RoundingMode.HALF_UP);
            this.Deal_Options_WIP = ((stockUnitRec.Deal_Options_WIP__c == null) ? 0 : stockUnitRec.Deal_Options_WIP__c).setScale(2, RoundingMode.HALF_UP);
            this.Total_Cost = ((stockUnitRec.Total_Cost__c == null) ? 0 : stockUnitRec.Total_Cost__c).setScale(2, RoundingMode.HALF_UP);
            
            this.Location = (stockUnitRec.get(Constants.NAMESPACE + 'Location__c') != null) ? String.valueOf(stockUnitRec.get('Location__c')) : null;
            this.Category = (stockUnitRec.Category__c != null) ? stockUnitRec.Category__r.Name : '';
            if(stockUnitRec.Date_Stocked_In__c != null){
                this.Stocked =  BPUtility.getFormatedDateTime(datetime.newInstance(stockUnitRec.Date_Stocked_In__c.year(), stockUnitRec.Date_Stocked_In__c.month(),stockUnitRec.Date_Stocked_In__c.day()));
            }
            this.Age = stockUnitRec.Age__c;
            this.Key_Number = stockUnitRec.Key_No__c;
            this.Engine_Number = stockUnitRec.Engine_Serial_No__c;
            this.Other_Number = stockUnitRec.Other_Serial_No__c;
            this.Int_Colour = stockUnitRec.Interior_Colour__c;
            
            if(stockUnitRec.Date_Stocked_Out__c != null){
                this.Date_Stocked_Out =  BPUtility.getFormatedDateTime((datetime.newInstance(stockUnitRec.Date_Stocked_Out__c.year(), stockUnitRec.Date_Stocked_Out__c.month(),stockUnitRec.Date_Stocked_Out__c.day())));
            }
            this.Taxable = (stockUnitRec.Taxable__c != null) ? ((stockUnitRec.Taxable__c) ? 'Yes' : 'No') : '';
            
            if(stockUnitRec.Taxable__c) {
                this.Applicable_Tax = (stockUnitRec.Applicable_Tax__c != null) ? stockUnitRec.Applicable_Tax__r.Name__c : '';
            }
            this.Cylinders = stockUnitRec.Cylinders__c;
            this.Automatic = (stockUnitRec.Automatic__c != null) ? ((stockUnitRec.Automatic__c) ? 'Yes' : 'No') : '';
            if(stockUnitRec.Manufactured_Date__c != null){
                this.Manufactured_Date =  BPUtility.getFormatedDateTime(datetime.newInstance(stockUnitRec.Manufactured_Date__c.year(), stockUnitRec.Manufactured_Date__c.month(),stockUnitRec.Manufactured_Date__c.day()));
            }
            this.Mileage = stockUnitRec.Mileage_Value__c;
            this.Plate_Number = stockUnitRec.Plate__c;
            
            if(stockUnitRec.Reg_Expiry_Date__c != null){
                this.Reg_Expiry =  BPUtility.getFormatedDateTime(datetime.newInstance(stockUnitRec.Reg_Expiry_Date__c.year(), stockUnitRec.Reg_Expiry_Date__c.month(),stockUnitRec.Reg_Expiry_Date__c.day()));
            }
            
            String tagsNameStr1 = '';
            if(String.isNotBlank(stockUnitRec.Assigned_Tag_1__c) && stockUnitRec.Assigned_Tag_1__c.length() > 1) {
                tagsNameStr1 = stockUnitRec.Assigned_Tag_1__c.substring(1, (stockUnitRec.Assigned_Tag_1__c).length() - 1);
            }
            if(String.isNotBlank(stockUnitRec.Assigned_Tag_2__c) && stockUnitRec.Assigned_Tag_2__c.length() > 1) {
                tagsNameStr1 += (String.isNotBlank(tagsNameStr1)) ? (';' + stockUnitRec.Assigned_Tag_2__c.substring(1, (stockUnitRec.Assigned_Tag_2__c).length() - 1)) : 
                                                                    (stockUnitRec.Assigned_Tag_2__c.substring(1, (stockUnitRec.Assigned_Tag_2__c).length() - 1));
            }
            this.Tags = tagsNameStr1.replace(';', ',');
            this.Unit_Type = (stockUnitRec.Unit_Type__c == 'ORDU') ? 'Order Unit' : 'Stock Unit';
            this.Mileage_Type = stockUnitRec.Mileage_Type__c;
            this.Compliance_Date = stockUnitRec.Compliance_Date__c;
			this.Year_Of_1st_Rego = stockUnitRec.Year_Of_1st_Rego__c; 
			this.Registration_Serial = stockUnitRec.Registration_Serial__c;
        }
    }
    //END: Added by Nidhi - #1152 - 19-10-2016
    
    public class UnitDeal {
        
        public Integer Type {get; private set;}
        public String Id {get; private set;}
        public String Order_Number {get; private set;}
        public String Customer {get; private set;}
        public String Deal_Type {get; private set;}
        public Decimal Total {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        public String Delivery {get; private set;}
        public Decimal Units {get; private set;}
        public Decimal Trade_Ins {get; private set;}
        public Decimal Parts_And_Labour {get; private set;}
        public Decimal Deal_Products {get; private set;}
        public Decimal Fees {get; private set;}
        public Decimal Sales_Tax {get; private set;}
        public Decimal Lien_Payout {get; private set;}
        public Decimal Stamp_Duty {get; private set;}
        public Decimal Financing_Products {get; private set;}
        
        public UnitDeal(Deal__c dealRec) { 
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Unit Deals');
            this.Id = dealRec.CO_Header__c;
            this.Order_Number = dealRec.CO_Header__r.Name;
            this.Customer = dealRec.CO_Header__r.Customer_Name__c;
            this.Deal_Type = dealRec.Type__c;
            this.Total = dealRec.CO_Header__r.Deal_Total__c ;
            this.Status = dealRec.Status__c;
            this.Modified = (dealRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(dealRec.LastModifiedDate) : null;
            this.Delivery = (dealRec.Delivery_Date__c != null) ?  BPUtility.getFormatedDateTime(datetime.newInstance(dealRec.Delivery_Date__c.year(),dealRec.Delivery_Date__c.month(),dealRec.Delivery_Date__c.day())) : null;
            this.Units = dealRec.Pre_Tax_Unit_Price_And_Cost_Total__c;
            this.Trade_Ins = dealRec.Pre_Tax_Trade_In_Total__c;
            this.Parts_And_Labour = dealRec.Pre_Tax_Part_And_Labor_Total__c;
            this.Deal_Products = dealRec.Pre_Tax_Other_Product_Total__c;
            this.Fees = dealRec.Pre_Tax_Fee_Total__c;
            this.Sales_Tax = dealRec.Sales_Tax_Total__c;
            this.Lien_Payout = dealRec.Lien_Payout_Total__c;
            this.Stamp_Duty = dealRec.Stamp_Duty_Total__c;
            this.Financing_Products = dealRec.F_I_Total__c;
            
        }
    }
    
    public class DealUnit {
    	
    	public String 	Id 					{get; private set;}
    	public String 	Unit_Id				{get; private set;}
    	public Integer 	Type 				{get; private set;}
    	public String 	Stock_Number 		{get; private set;}
    	public String 	Make 				{get; private set;}
    	public String 	Model 				{get; private set;}
    	public String 	Submodel 			{get; private set;}
    	public Decimal 	Year 				{get; private set;}
    	public String 	Status 				{get; private set;}
    	public String	Order_Number		{get; private set;}
    	public Decimal	Total_Price			{get; private set;}
    	public String 	Deal_Type			{get; private set;}
    	public String	Customer			{get; private set;}
    	public String	Date_Sold			{get; private set;}	
    	public Decimal	Base_Price			{get; private set;}
    	public Decimal  Factory_Options		{get; private set;}
    	public Decimal	Dealer_Installed	{get; private set;}
    	public Decimal	Part_Options		{get; private set;}
    	public Decimal	Labor_Options		{get; private set;}
    	public Decimal	Sublet_Options		{get; private set;}
    	public Decimal	Fee_Options			{get; private set;}
    	public Decimal	Warranty_Options	{get; private set;}	
    	public Decimal  Other_Products		{get; private set;}
    	public Decimal 	Stamp_Duty			{get; private set;}
    	public String  	VIN					{get; private set;}
    	public String 	New_Unit			{get; private set;}
    	public String   Category			{get; private set;}
    	public String   Stocked_In			{get; private set;}
    	public Decimal	Age					{get; private set;}
    	public String	Tags				{get; private set;}
    	public Decimal	Mileage				{get; private set;}
    	public String 	Mileage_Type		{get; private set;}
    	public String	Ext_Color			{get; private set;}
    	public String	Int_Color			{get; private set;}
    	public String Compliance_Date       {get; private set;}
        public String Year_Of_1st_Rego      {get; private set;}
        public String Registration_Serial   {get; private set;}
        public String Manufactured_Date   {get; private set;}

    	public DealUnit(Deal_Item__c dealtemRec) {
    		
	    	this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Deal Units');
	    	this.Id = dealtemRec.Deal__r.CO_Header__c;
	    	this.Unit_Id = dealtemRec.Customer_Owned_Unit__r.Id;
	    	this.Stock_Number = dealtemRec.Customer_Owned_Unit__r.Stock_Id__c != null ? dealtemRec.Customer_Owned_Unit__r.Stock_Id__c : dealtemRec.Customer_Owned_Unit__r.Unit_Number__c;
	    	this.Make = (dealtemRec.Customer_Owned_Unit__r.Make_Name__c != null) ? dealtemRec.Customer_Owned_Unit__r.Make_Name__c : '';
			this.Model = (dealtemRec.Customer_Owned_Unit__r.Model_Name__c != null) ? dealtemRec.Customer_Owned_Unit__r.Model_Name__c : '';
			this.Submodel = (dealtemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c != null) ? dealtemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c : ''; 
			this.Year = dealtemRec.Customer_Owned_Unit__r.Year__c;
			this.Status = dealtemRec.Customer_Owned_Unit__r.Status__c;
			this.Order_Number = dealtemRec.Deal__r.CO_Header__r.Name; 		
			this.Deal_Type = dealtemRec.Deal__r.Type__c;			
			this.Customer = dealtemRec.Deal__r.CO_Header__r.Customer_Name__c;	
			if(dealtemRec.Deal__r.Status__c == 'Invoiced' && dealtemRec.Date_Sold__c != null){
                this.Date_Sold =  BPUtility.getFormatedDateTime(datetime.newInstance(dealtemRec.Date_Sold__c.year(), dealtemRec.Date_Sold__c.month(),dealtemRec.Date_Sold__c.day()));
            }
			this.Total_Price = ((dealtemRec.Total_Price__c == null) ? 0 : dealtemRec.Total_Price__c).setScale(2, RoundingMode.HALF_UP);	
			this.Base_Price = ((dealtemRec.Base_Price__c == null) ? 0 : dealtemRec.Base_Price__c).setScale(2, RoundingMode.HALF_UP);			
			this.Factory_Options = ((dealtemRec.Factory_Option_Total__c == null) ? 0 : dealtemRec.Factory_Option_Total__c).setScale(2, RoundingMode.HALF_UP); 	
			this.Dealer_Installed =	((dealtemRec.Dealer_Option_Total__c == null) ? 0 : dealtemRec.Dealer_Option_Total__c).setScale(2, RoundingMode.HALF_UP);
			this.Part_Options =	((dealtemRec.Part_Total__c == null) ? 0 : dealtemRec.Part_Total__c).setScale(2, RoundingMode.HALF_UP);	
			this.Labor_Options = ((dealtemRec.Labour_Total__c == null) ? 0 : dealtemRec.Labour_Total__c).setScale(2, RoundingMode.HALF_UP);		
			this.Sublet_Options = ((dealtemRec.Sublet_Total__c == null) ? 0 : dealtemRec.Sublet_Total__c).setScale(2, RoundingMode.HALF_UP);			
			this.Fee_Options =	((dealtemRec.Fee_Total__c == null) ? 0 : dealtemRec.Fee_Total__c).setScale(2, RoundingMode.HALF_UP);	
			this.Warranty_Options =	((dealtemRec.Warranty_Product_Total__c == null) ? 0 : dealtemRec.Warranty_Product_Total__c).setScale(2, RoundingMode.HALF_UP);		
			this.Other_Products = ((dealtemRec.Other_Product_Total__c == null) ? 0 : dealtemRec.Other_Product_Total__c).setScale(2, RoundingMode.HALF_UP);		
			this.Stamp_Duty = ((dealtemRec.Stamp_Duty_Total__c == null) ? 0 : dealtemRec.Stamp_Duty_Total__c).setScale(2, RoundingMode.HALF_UP);		
			this.VIN =	(dealtemRec.Customer_Owned_Unit__r.VIN_Number_Formula__c == null) ? '' : dealtemRec.Customer_Owned_Unit__r.VIN_Number_Formula__c;				
			if(dealtemRec.Customer_Owned_Unit__r.New_Unit__c != null) {
                if(dealtemRec.Customer_Owned_Unit__r.New_Unit__c) {
                    this.New_Unit = 'Yes';
                } else {
                    this.New_Unit = 'No';
                }
            }			
			this.Category = (dealtemRec.Customer_Owned_Unit__r.Category__c != null) ? dealtemRec.Customer_Owned_Unit__r.Category__r.Name : '';		
			if(dealtemRec.Customer_Owned_Unit__r.Date_Stocked_In__c != null){
                this.Stocked_In =  BPUtility.getFormatedDateTime(datetime.newInstance(dealtemRec.Customer_Owned_Unit__r.Date_Stocked_In__c.year(), dealtemRec.Customer_Owned_Unit__r.Date_Stocked_In__c.month(),dealtemRec.Customer_Owned_Unit__r.Date_Stocked_In__c.day()));
            }			
			this.Age = dealtemRec.Customer_Owned_Unit__r.Age__c;				
			String tagsNameStr1 = '';
            if(String.isNotBlank(dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_1__c) && dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_1__c.length() > 1) {
                tagsNameStr1 = dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_1__c.substring(1, (dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_1__c).length() - 1);
        }
            if(String.isNotBlank(dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_2__c) && dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_2__c.length() > 1) {
                tagsNameStr1 += (String.isNotBlank(tagsNameStr1)) ? (';' + dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_2__c.substring(1, (dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_2__c).length() - 1)) : 
                                                                    (dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_2__c.substring(1, (dealtemRec.Customer_Owned_Unit__r.Assigned_Tag_2__c).length() - 1));
    }
    
            this.Tags = tagsNameStr1.replace(';', ',');		
			this.Mileage = dealtemRec.Customer_Owned_Unit__r.Mileage_Value__c;				
			this.Mileage_Type =	dealtemRec.Customer_Owned_Unit__r.Mileage_Type__c;	
			this.Ext_Color = dealtemRec.Customer_Owned_Unit__r.Colour__c;			
			this.Int_Color = dealtemRec.Customer_Owned_Unit__r.Interior_Colour__c;	
			this.Compliance_Date = dealtemRec.Customer_Owned_Unit__r.Compliance_Date__c;
			this.Year_Of_1st_Rego = dealtemRec.Customer_Owned_Unit__r.Year_Of_1st_Rego__c; 
			this.Registration_Serial = dealtemRec.Customer_Owned_Unit__r.Registration_Serial__c;
			if(dealtemRec.Customer_Owned_Unit__r.Manufactured_Date__c != null){
                this.Manufactured_Date =  BPUtility.getFormatedDateTime(datetime.newInstance(dealtemRec.Customer_Owned_Unit__r.Manufactured_Date__c.year(), dealtemRec.Customer_Owned_Unit__r.Manufactured_Date__c.month(),dealtemRec.Customer_Owned_Unit__r.Manufactured_Date__c.day()));
            }
    	}
    }
    public class CustomerUnit {
        
        public Integer Type {get; private set;}
        public String Id {get; private set;}
        public String Unit_ID {get; private set;}
        public String Customer {get; private set;}
        public String Phone_Number {get; private set;}
        public Decimal Year {get; private set;}
        public String Make {get; private set;}
        public String Model {get; private set;}
        public String SubModel {get; private set;}
        public Decimal Mileage {get; private set;}
        public String Status {get; private set;}
        public String Modified {get; private set;}
        
        public String VIN {get; private set;}
        public String Plate_Number {get; private set;}
        public String Reg_Expiry {get; private set;}
        public String Key_Number {get; private set;}
        public String Engine_Number {get; private set;}
        public String Other_Number {get; private set;}
        public String Ext_Colour {get; private set;}
        public String Int_Colour {get; private set;}
        public String Tags {get; private set;}
        public String Account_Type {get; private set;}
        public String Compliance_Date {get; private set;}
        public String Year_Of_1st_Rego {get; private set;}
        public String Registration_Serial {get; private set;}
        public String Manufactured_Date {get; private set;}
        
        public CustomerUnit(Customer_Owned_Unit__c customerUnitRec) {
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Unit');
            this.Id = customerUnitRec.Id;
            this.Unit_ID = customerUnitRec.Unit_Number__c;
            this.Customer = (customerUnitRec.Account__r.Name != null) ? customerUnitRec.Account__r.Name : '';
            if(customerUnitRec.Account__r.Preferred_Phone__c != null) {
                this.Phone_Number = customerUnitRec.Account__r.Formatted_Preferred_Phone__c;
            } else if(customerUnitRec.Account__r.Home_Number__c != null) {
                this.Phone_Number = customerUnitRec.Account__r.Formatted_Home_number__c;
            } else if(customerUnitRec.Account__r.Mobile__c != null) {
                this.Phone_Number = customerUnitRec.Account__r.Formatted_Mobile_Number__c;
            }
            
            this.Account_Type = (customerUnitRec.Account__c != null && customerUnitRec.Account__r.Account_Type__c != null) 
                                ? customerUnitRec.Account__r.Account_Type__r.Name : '';
            this.Year = customerUnitRec.Year__c;
            this.Year = customerUnitRec.Year__c;
            this.Make = (customerUnitRec.Unit_Make__c != null) ? customerUnitRec.Unit_Make__r.Name : '';
            this.Model = (customerUnitRec.Unit_Model__c != null) ? customerUnitRec.Unit_Model__r.Name__c : '';
            this.SubModel = (customerUnitRec.Sub_Model__c != null) ? customerUnitRec.Sub_Model__r.Sub_Model_Name__c : '';
            this.Mileage = customerUnitRec.Mileage_Value__c;
            this.Status = customerUnitRec.Status__c;
            this.Modified = (customerUnitRec.LastModifiedDate != null) ?  BPUtility.getFormatedDateTime(customerUnitRec.LastModifiedDate) : null;
            
            this.VIN = (customerUnitRec.VIN_Number_Formula__c == null) ? '' : customerUnitRec.VIN_Number_Formula__c;
            this.Plate_Number = customerUnitRec.Plate__c;
            if(customerUnitRec.Reg_Expiry_Date__c != null){
                this.Reg_Expiry =  BPUtility.getFormatedDateTime(datetime.newInstance(customerUnitRec.Reg_Expiry_Date__c.year(), customerUnitRec.Reg_Expiry_Date__c.month(),customerUnitRec.Reg_Expiry_Date__c.day()));
            }
            this.Key_Number = customerUnitRec.Key_No__c;
            this.Engine_Number = customerUnitRec.Engine_Serial_No__c;
            this.Other_Number = customerUnitRec.Other_Serial_No__c;
            this.Ext_Colour = customerUnitRec.Colour__c;
            this.Int_Colour = customerUnitRec.Interior_Colour__c;
            
            String tagsNameStr1 = '';
            if(String.isNotBlank(customerUnitRec.Assigned_Tag_1__c) && customerUnitRec.Assigned_Tag_1__c.length() > 1) {
                tagsNameStr1 = customerUnitRec.Assigned_Tag_1__c.substring(1, (customerUnitRec.Assigned_Tag_1__c).length() - 1);
        }
            if(String.isNotBlank(customerUnitRec.Assigned_Tag_2__c) && customerUnitRec.Assigned_Tag_2__c.length() > 1) {
                tagsNameStr1 += (String.isNotBlank(tagsNameStr1)) ? (';' + customerUnitRec.Assigned_Tag_2__c.substring(1, (customerUnitRec.Assigned_Tag_2__c).length() - 1)) : 
                                                                    (customerUnitRec.Assigned_Tag_2__c.substring(1, (customerUnitRec.Assigned_Tag_2__c).length() - 1));
    }
    
            this.Tags = tagsNameStr1.replace(';', ',');
			this.Compliance_Date = customerUnitRec.Compliance_Date__c;
			this.Year_Of_1st_Rego = customerUnitRec.Year_Of_1st_Rego__c; 
			this.Registration_Serial = customerUnitRec.Registration_Serial__c;             
			if(customerUnitRec.Manufactured_Date__c != null){
                this.Manufactured_Date =  BPUtility.getFormatedDateTime(datetime.newInstance(customerUnitRec.Manufactured_Date__c.year(), customerUnitRec.Manufactured_Date__c.month(),customerUnitRec.Manufactured_Date__c.day()));
            }           
        }
    }
    
    /**
     * Name: VendorOrdering
     * Description: Sets the value of the VendorOrdering
    **/
    public class VendorOrdering {
        
        public String Id {get; private set;}
        public String Id_Number {get; private set;}
        public Integer Type {get; private set;}
        public String Vendor {get; private set;}
        public string VendorId {get; private set;}
        public Decimal Total {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String OwnerId {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        
        public VendorOrdering(Sobject sobjRec) {
            this.Id = String.valueOf(sobjRec.get('Id'));
            String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            
            // Checks for the  Object and assigns the value accordingly for object type
            this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
            if(objectName == Constants.NAMESPACE +'Return_VO_Header__c') {
                this.Owner = String.valueOf((sobjRec.getSobject('Owner')).get('Name'));
            } else {
            this.Owner = (sobjRec.getSobject(Constants.NAMESPACE +'Owner__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Owner__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Owner__r').get('Name')) : null;
            }
            this.Vendor = (sobjRec.getSobject(Constants.NAMESPACE +'Vendor__r') != null && sobjRec.getSobject(Constants.NAMESPACE +'Vendor__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Vendor__r').get('Name')) : null;
            this.Total = 0;
            
            if(objectName == Constants.NAMESPACE +'Vendor_Order_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Orders');
                this.Id_Number = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Total = (sobjRec.get('Total__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get('Total__c'))) : null;
            } else if(objectName == Constants.NAMESPACE +'Return_VO_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Return');
                this.Id_Number = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Total = (sobjRec.get('Total__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get('Total__c'))) : null;
            } else if(objectName == Constants.NAMESPACE +'Vendor_Receiving_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Receivings');
                this.Id_Number = (sobjRec.get('Receipt_Number__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Receipt_Number__c')) : null;
                this.Total = (sobjRec.get('Receiving_Total__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get('Receiving_Total__c'))) : null;
            } else if(objectName == Constants.NAMESPACE +'Vendor_Invoicing_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Invoices');
                this.Id_Number = (sobjRec.get('Vendor_Invoice_Number__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Vendor_Invoice_Number__c')) : null;
                this.Total = (sobjRec.get('Total_With_Tax__c') != null) ? Decimal.valueOf(String.valueOf(sobjRec.get('Total_With_Tax__c'))) : null;
            } 
             
            this.Created =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('CreatedDate'))));
            this.Modified =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('LastModifiedDate'))));
        }
     
    }
    /**
     * Name: Part Movement
     * Description: Sets the value of the Part FIFO
    **/ 
    public class PartMovement {
        public String Id {get; private set;}
        public Integer Type {get; private set;}
        public String Part_Number {get; private set;}
        public String Description {get; private set;}
        public Decimal Opening_Value {get; private set;}
        public Decimal Opening_Qty {get; private set;}
        public Decimal Purchased_Qty {get; private set;}
        public Decimal Sales_Qty {get; private set;}
        public Decimal Adjusted_Qty {get; private set;}
        public Decimal Closing_Qty {get; private set;}
        public Decimal Closing_Value {get; private set;}
        public Decimal Total_Sales {get; private set;}
        public Decimal Purchased_Cost {get; private set;}
        public Decimal Cost_of_Sales {get; private set;}
        public Decimal Adjusted_Cost {get; private set;}
        public String Last_Sold {get; private set;}
        public String Last_Stocked {get; private set;}
        public Decimal Reorder_At {get; private set;}
        public Decimal Reorder_To {get; private set;}
        public String Location {get; private set;}
        public String Vendor {get; private set;}
        public String Part_Type {get; private set;}
        public String Category {get; private set;}
        public String Status {get; private set;}
        
        public PartMovement(Part__c partRec) {
            this.Id = partRec.Id;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
            this.Vendor = partRec.Vendor__r.Name;
            this.Category = partRec.Category__r.Name;
            this.Part_Type = partRec.Part_Type__c;
            this.Location = partRec.Location__c;
            this.Status = partRec.Status__c;
            this.Last_Sold = partRec.Last_Sold__c!= null ? BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(partRec.Last_Sold__c))) : '';
            this.Last_Stocked = partRec.Last_Stocked__c != null ? BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(partRec.Last_Stocked__c))) : '';
            this.Reorder_At = partRec.Auto_reorder_Min__c;
            this.Reorder_To = partRec.Auto_reorder_Max__c;
            this.Part_Number = partRec.Part_Number__c;
            this.Description = partRec.Description__c;
        }
    }
    
    public class TaxReporting {
        public String Id {get; private set;}
        public Integer Type{get; private set;}
        public String Invoice_Type {get; private set;}
        public String Invoice_Number {get; private set;}
        public String Customer_Vendor {get; private set;}
        public String Invoice_Date {get; private set;}
        public Decimal Sub_Total  {get; private set;}
        public Decimal Tax_Total {get; private set;}
        public Decimal Invoice_Total {get; private set;}
        public Decimal Taxable_Total {get; private set;}
        public Decimal Non_Taxable_Total {get; private set;}
        public Map<String,List<Decimal>> TaxItemRecs {get; private set;}
        public String Account_Type {get; private set;}
        
        public TaxReporting(CO_Invoice_Header__c coInvoiceRec, Map<String,List<Decimal>> taxItemRecs) {
            this.Id = coInvoiceRec.CO_Header__c;
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Invoices');
            this.Invoice_Type = 'Customer Invoice';
            this.Invoice_Date = coInvoiceRec.get(Constants.NAMESPACE +'Invoice_Date__c') != null ? 
                                BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(coInvoiceRec.get('Invoice_Date__c')))) : '';
            this.Invoice_Number = coInvoiceRec.Invoice_Number__c;
            this.Customer_Vendor = coInvoiceRec.CO_Header__r.Customer_Name__c;
            this.Sub_Total = coInvoiceRec.Sub_Total__c; 
            this.Tax_Total = coInvoiceRec.SalesTax_Total__c; // TK: Need to check
            this.Invoice_Total = coInvoiceRec.Total__c;
            this.Taxable_Total = coInvoiceRec.Taxable_Total__c;
            this.Non_Taxable_Total = coInvoiceRec.Non_Taxable_Total__c;
            this.TaxItemRecs = taxItemRecs;
            this.Account_Type = (coInvoiceRec.CO_Header__c != null && coInvoiceRec.CO_Header__r.Account_Type__c != null) 
                                ? coInvoiceRec.CO_Header__r.Account_Type__r.Name : null;
        }
        
        public TaxReporting(Vendor_Invoicing_Header__c voInvoiceRec) {
            this.Id = voInvoiceRec.Id;
            this.Invoice_Type = 'Vendor Invoice';
            this.Invoice_Date = voInvoiceRec.get(Constants.NAMESPACE +'Invoice_Date__c') != null ? 
                                BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(voInvoiceRec.get('Invoice_Date__c')))) : '';
            this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Invoices');
            this.Invoice_Number = voInvoiceRec.Vendor_Invoice_Number__c;
            this.Customer_Vendor = voInvoiceRec.Vendor__r.Name;
            this.Sub_Total = voInvoiceRec.Sub_Total__c;
            this.Tax_Total = voInvoiceRec.Tax_Total__c;
            this.Invoice_Total = voInvoiceRec.Total_With_Tax__c;
            this.Taxable_Total = voInvoiceRec.Taxable_Total__c;
            this.Account_Type = (voInvoiceRec.Vendor__c != null && voInvoiceRec.Vendor__r.Vendor_Account_Type__c != null) ? voInvoiceRec.Vendor__r.Vendor_Account_Type__r.Name : null;
            this.Non_Taxable_Total = voInvoiceRec.Non_Taxable_Total__c;
            this.TaxItemRecs = new Map<String, List<Decimal>>();
            for(Individual_Tax__c individualTax : voInvoiceRec.getSObjects(Constants.NAMESPACE +'Individual_Taxes__r')){
                if(this.TaxItemRecs.containsKey(individualTax.Sales_Tax_Item_Name__c) && individualTax.Tax_Rate__c != null){
                    this.TaxItemRecs.get(individualTax.Sales_Tax_Item_Name__c)[1] += (individualTax.Tax_Rate__c * this.Taxable_Total) / 100;
                } else if(individualTax.Tax_Rate__c != null) {
                    this.TaxItemRecs.put(individualTax.Sales_Tax_Item_Name__c, new List<Decimal>{this.Taxable_Total, (individualTax.Tax_Rate__c * this.Taxable_Total) / 100 });
                }
            }
        }
    }
    /**
     * Name: AnyObject
     * Description: Sets the Value of Generic type
    **/
    public class AnyObject {
        
        public String Id {get; private set;}
        public Integer Type {get; private set;}
        public String Key {get; private set;}
        public String Summary {get; private set;}
        public String Status {get; private set;}
        public String Owner {get; private set;}
        public String OwnerId {get; private set;}
        public String Modified {get; private set;}
        public String Created {get; private set;}
        
        public AnyObject(Sobject sobjRec) {
            this.Id = String.valueOf(sobjRec.get('Id'));
            String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            
            this.Modified =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('LastModifiedDate'))));
            this.Created =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('CreatedDate'))));
            
            // Checks for the Object and assigns the value accordingly for that object
            if(objectName == 'Account') {
                if(Boolean.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Is_Customer__c')))) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customers');
                    
                } else if(Boolean.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Is_Vendor__c')))) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendors');
                }
                
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Status = String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c'));
                
            } else if(objectName == Constants.NAMESPACE + 'Part__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts');
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Part_Number__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Part_Number__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'Product__c') {
                this.Id = sobjRec.get(Constants.NAMESPACE + 'Vendor__c') != null ? String.valueOf(sobjRec.get(Constants.NAMESPACE + 'Vendor__c')) : null;
                String productType = (sobjRec.get(Constants.NAMESPACE +'Type__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Type__c')) : '';
                if(productType == Constants.SUBLET) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sublets');
                } else if(productType == Constants.FINANCING_PRODUCT) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Financing Product');
                } else if(productType == Constants.DEAL_PRODUCT) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Deal Product');
                } else if(productType == Constants.WARRANTY_PLAN) {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Warranty Plan');
                }
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Code__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'Labour_Code__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Labor Codes');
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
            
            } else if(objectName == Constants.NAMESPACE + 'Kit_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Kits');
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Code__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
            
            } else if(objectName == Constants.NAMESPACE + 'Fee__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Fees');
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Fee_Unique_Name__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Fee_Unique_Name__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                
            } else if(objectName == 'User') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Users');
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Status = (sobjRec.get('IsActive') != null) ? String.valueOf(sobjRec.get('IsActive')) : null;
                this.Status = (this.Status.toLowerCase() == 'true') ? 'Active' : 'Inactive';
                this.Summary = (sobjRec.get('Email') != null) ? String.valueOf(sobjRec.get('Email')) : null;
                this.Created = (sobjRec.get(Constants.NAMESPACE + 'CreatedDate__c') != null) ? getFormattedDate(String.valueOf(sobjRec.get(Constants.NAMESPACE + 'CreatedDate__c'))) : null;
                this.Modified = (sobjRec.get(Constants.NAMESPACE + 'LastModifiedDate__c') != null) ? getFormattedDate(String.valueOf(sobjRec.get(Constants.NAMESPACE + 'LastModifiedDate__c'))) : null;
            
            } else if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Orders');
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'CO_Invoice_Header__c') {
                this.Id = sobjRec.get(Constants.NAMESPACE + 'CO_Header__c') != null ? String.valueOf(sobjRec.get(Constants.NAMESPACE + 'CO_Header__c')) : null;
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Invoices');
                this.Key = (sobjRec.get('Invoice_Number__c') != null) ? String.valueOf(sobjRec.get('Invoice_Number__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
            
            } else if(objectName == Constants.NAMESPACE + 'CO_Invoice_Payment__c' || objectName == Constants.NAMESPACE + 'CO_Deposit__c') {
                this.Id = ((sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r') != null) ? 
                                    String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Invoice_Header__r').get('CO_Header__c')) : '');
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Payments');
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Status = 'Active';
                if(objectName == Constants.NAMESPACE + 'CO_Deposit__c') {
                    this.Id = sobjRec.get(Constants.NAMESPACE + 'CO_Header__c') != null ? String.valueOf(sobjRec.get(Constants.NAMESPACE + 'CO_Header__c')) : null;
                }
                
            } else if(objectName == Constants.NAMESPACE + 'Vendor_Order_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Orders');
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                
            }  else if(objectName == Constants.NAMESPACE + 'Return_VO_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Return');
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'Vendor_Receiving_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Receivings');
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'Vendor_Invoicing_Header__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Vendor Invoices');
                this.Key = (sobjRec.get('Vendor_Invoice_Number__c') != null) ? String.valueOf(sobjRec.get('Vendor_Invoice_Number__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null ) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'Category__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Item Categories');
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Unique_Category__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Unique_Category__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'Price_Level__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Price Levels');
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Name__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Name__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Description__c')) : null;
                
            } else if(objectName == Constants.NAMESPACE + 'Sales_Tax__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Sales Taxes');
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Name__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                this.Summary = (sobjRec.get(Constants.NAMESPACE +'Forms_Label__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Forms_Label__c')) : null;
            
            } else if(objectName == Constants.NAMESPACE + 'Customer_Owned_Unit__c') {
                if(sobjRec.get(Constants.NAMESPACE +'Unit_Type__c') != null && String.valueOf(sobjRec.get(Constants.NAMESPACE +'Unit_Type__c')) != 'COU') {
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Inventory Unit');
                } else if(sobjRec.get(Constants.NAMESPACE +'Unit_Type__c') != null && String.valueOf(sobjRec.get(Constants.NAMESPACE +'Unit_Type__c')) == 'COU'){
                    this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Customer Unit');
                    String makeName = (sobjRec.get(Constants.NAMESPACE +'Make_Name__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Make_Name__c')) : '';
                    String modelName = (sobjRec.get(Constants.NAMESPACE +'Model_Name__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Model_Name__c')) : '';
                    String submodelName = (sobjRec.getSobject(Constants.NAMESPACE + 'Sub_Model__r') != null && sobjRec.getSobject(Constants.NAMESPACE + 'Sub_Model__r').get('Sub_Model_Name__c') != null) ? 
                                            String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Sub_Model__r').get('Sub_Model_Name__c')) : '';
                    this.Summary = makeName + ' ' + modelName + ' ' + submodelName;
                }
                this.Key = (sobjRec.get(Constants.NAMESPACE +'Unit_Number__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Unit_Number__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                //this.Summary = (sobjRec.get(Constants.NAMESPACE +'Forms_Label__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Forms_Label__c')) : null;
            
            } else if(objectName == Constants.NAMESPACE + 'Vendor_Order_Line_Item__c') {
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts Needed');
                this.Key = (sobjRec.get(Constants.NAMESPACE+'Needed_For__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE + 'Needed_For__c')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                //this.Summary = (sobjRec.get(Constants.NAMESPACE +'Forms_Label__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Forms_Label__c')) : null;
                
                if(sobjRec.get(Constants.NAMESPACE +'Is_required_For_Customer__c') != null && Boolean.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Is_required_For_Customer__c'))) 
                    || (sobjRec.get(Constants.NAMESPACE +'Is_Service__c') != null && Boolean.valueOf(String.valueOf(sobjRec.get(Constants.NAMESPACE +'Is_Service__c'))))) {
                
                    this.Id = (sobjRec.get(Constants.NAMESPACE +'CO_Header__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'CO_Header__c')) : null;
                } else {
                    this.Id = (sobjRec.get(Constants.NAMESPACE +'Part__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Part__c')) : null;
                }
                
            }else if(objectName == Constants.NAMESPACE + 'Deal__c') {
                this.Id = sobjRec.getSobject(Constants.NAMESPACE + 'CO_Header__r') != null ? String.valueOf(sobjRec.get(Constants.NAMESPACE + 'CO_Header__c')) : null;
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Unit Deals');
                this.Key = (sobjRec.getSobject(Constants.NAMESPACE + 'CO_Header__r') != null && sobjRec.getSobject(Constants.NAMESPACE + 'CO_Header__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Status__c')) : null;
                if(sobjRec.get(Constants.NAMESPACE +'Type__c') != null){
					if(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
			                sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null){
						this.Summary = String.valueOf(sobjRec.get(Constants.NAMESPACE +'Type__c')) + ' ' + String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')); 							
					} else {
							this.Summary = String.valueOf(sobjRec.get(Constants.NAMESPACE +'Type__c'));
					}
                
				} else {
					if((sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
				                sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null)){
						this.Summary = String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')); 							
					} else {
						this.Summary = null;
					}
				}			
            }else if(objectName == Constants.NAMESPACE + 'Service_Order_Header__c') {
                this.Id = sobjRec.getSobject(Constants.NAMESPACE + 'CO_Header__r') != null ? String.valueOf(sobjRec.get(Constants.NAMESPACE + 'CO_Header__c')) : null;
                this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Service Jobs');
                this.Key = (sobjRec.getSobject(Constants.NAMESPACE + 'CO_Header__r') != null && sobjRec.getSobject(Constants.NAMESPACE + 'CO_Header__r').get('Name') != null) ? String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Name')) : null;
                this.Status = (sobjRec.get(Constants.NAMESPACE +'Work_Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Work_Status__c')) : null;
                //this.Summary = (sobjRec.get(Constants.NAMESPACE +'Forms_Label__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Forms_Label__c')) : null;
                if(sobjRec.get(Constants.NAMESPACE + 'SO_Type__c') != null && sobjRec.get(Constants.NAMESPACE + 'SO_Type__c') == Constants.INTERNAL_SERVICE) {
                    this.Summary = Constants.UNIT_INVENTORY;
                } else {
                    this.Summary = (sobjRec.get(Constants.NAMESPACE + 'Name__c') != null) ? sobjRec.get(Constants.NAMESPACE + 'Name__c') + '': '';
                    if((sobjRec.get(Constants.NAMESPACE + 'Name__c') != null) && (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
                            sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null)) {
                        this.Summary += ' - ';
                    }
                    this.Summary += (sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r') != null &&  
                                    sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r') != null && 
                                    sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null) ? 
                                            String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'CO_Header__r').getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : 
                                            '';
                }
            }
            
            String ownerFieldNameValue;
            String ownerFieldIdValue;
            //system.assert(false, objectName + '  ' + HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName);
            
            String ownerFieldName = HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(objectName).get('Owner');
            List<String> ownerFieldsMap = ownerFieldName.split('\\.');
            
            if( ownerFieldName.contains('CreatedBy') ){
                if(ownerFieldsMap.size() == 1) {
                    ownerFieldNameValue = (String) sobjRec.get(ownerFieldsMap[0]);
                    ownerFieldIdValue = (String) sobjRec.get(ownerFieldsMap[0]);
                } else if(ownerFieldsMap.size() == 2 && sobjRec.getSObject(ownerFieldsMap[0]) != null) {
                    ownerFieldNameValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).get(ownerFieldsMap[1]);
                    ownerFieldIdValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).get('Id');
                }
            } else if( ownerFieldName.contains('Owner') == false ){
                ownerFieldNameValue = String.valueOf(sobjRec.get(ownerFieldName));
                ownerFieldIdValue = String.valueOf(sobjRec.get(ownerFieldName));
            } else if(ownerFieldsMap.size() == 1) {
                ownerFieldNameValue = (String) sobjRec.get(ownerFieldsMap[0]);
                ownerFieldIdValue = (String) sobjRec.get(ownerFieldsMap[0]);
            } else if(ownerFieldsMap.size() == 2) {
                if(sobjRec.getSObject(ownerFieldsMap[0]) != null) {
                    ownerFieldNameValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).get(ownerFieldsMap[1]);
                    ownerFieldIdValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).get('Id');
                }
            } else if(ownerFieldsMap.size() == 3){
                if(sobjRec.getSObject(ownerFieldsMap[0]) != null && sobjRec.getSObject(ownerFieldsMap[0]).getSObject(ownerFieldsMap[1]) != null) {
                    ownerFieldNameValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).getSObject(ownerFieldsMap[1]).get(ownerFieldsMap[2]);
                    ownerFieldIdValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).getSObject(ownerFieldsMap[1]).get('Id');
                }
            } else if(ownerFieldsMap.size() == 4){
                if(sobjRec.getSObject(ownerFieldsMap[0]) != null && sobjRec.getSObject(ownerFieldsMap[0]).getSObject(ownerFieldsMap[1]) != null && sobjRec.getSObject(ownerFieldsMap[0]).getSObject(ownerFieldsMap[1]).getSObject(ownerFieldsMap[2]) != null) {
                    ownerFieldNameValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).getSObject(ownerFieldsMap[1]).getSObject(ownerFieldsMap[2]).get(ownerFieldsMap[3]);
                    ownerFieldIdValue = (String) sobjRec.getSObject(ownerFieldsMap[0]).getSObject(ownerFieldsMap[1]).getSObject(ownerFieldsMap[2]).get('Id');
                }
            }
            this.Owner = ownerFieldNameValue;
            this.OwnerId = ownerFieldIdValue;
            /* 
            if(HomeSearchUtil.objectToOwnerObjectFieldName.containsKey(objectName) && HomeSearchUtil.objectToOwnerObjectFieldName.get(objectName).contains('__c')) {
                String parentObjectFieldName = HomeSearchUtil.objectToOwnerObjectFieldName.get(objectName).split('\\.')[0];
                this.Owner = String.valueOf(sobjRec.getSobject(parentObjectFieldName).getSobject('Owner__r').get('Name'));
                this.OwnerId = String.valueOf(sobjRec.getSobject(parentObjectFieldName).getSobject('Owner__r').get('Id'));
            } else if(HomeSearchUtil.objectToOwnerObjectFieldName.containsKey(objectName)) {
                String parentObjectFieldName = HomeSearchUtil.objectToOwnerObjectFieldName.get(objectName);
                this.Owner = String.valueOf(sobjRec.getSobject(parentObjectFieldName).getSobject('Owner').get('Name'));
                this.OwnerId = String.valueOf(sobjRec.getSobject(parentObjectFieldName).getSobject('Owner').get('Id'));
            } else if(HomeSearchUtil.searchableObjectToFieldsMap.get(objectName).contains('Owner.Name')) {
                this.Owner = (sobjRec.getSobject('Owner') != null && sobjRec.getSobject('Owner').get('Name') != null) ? String.valueOf(sobjRec.getSobject('Owner').get('Name')) : null;
                this.OwnerId = (sobjRec.getSobject('Owner') != null) ? String.valueOf(sobjRec.getSobject('Owner').get('Id')) : null;
            }
            */
        }
        
        public AnyObject(Sobject sobjRec, String searchName) {
        	
            this.Id = String.valueOf(sobjRec.get('Id'));
            String objectName = ((Id)sobjRec.get('Id')).getSObjectType().getDescribe().getName();
            this.Modified =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('LastModifiedDate'))));
            this.Created =  BPUtility.getFormatedDateTime(DateTime.valueOf(String.valueOf(sobjRec.get('CreatedDate'))));
            // Checks for the Object and assigns the value accordingly for that object
            if(objectName == Constants.NAMESPACE + 'CO_Header__c') {
        		this.Type = HomeSearchUtil.displayObjectNameToTypeNumber.get('Parts Order');
        		this.Status = (sobjRec.get(Constants.NAMESPACE +'Merchandise_Status__c') != null) ? String.valueOf(sobjRec.get(Constants.NAMESPACE +'Merchandise_Status__c')) : 'Active';
        		this.Summary = 'Parts & accessories';
        		if(sobjRec.getSobject(Constants.NAMESPACE +'Customer__r') == null) {
                    if(sobjRec.get(Constants.NAMESPACE +'CO_Type__c') == Constants.CASH_SALE) {
                        this.Summary += ' - ' + Constants.CASH_SALE.toUpperCase();
                    } else if(sobjRec.get(Constants.NAMESPACE +'CO_Type__c') == Constants.INTERNAL_SERVICE) {
                        this.Summary += ' - ' + Constants.UNIT_INVENTORY.toUpperCase();
                    }
                } else {
                    this.Summary  += (sobjRec.getSobject(Constants.NAMESPACE +'Customer__r') != null &&
                    	 sobjRec.getSobject(Constants.NAMESPACE +'Customer__r').get('Name') != null ) ? 
                    	 ' - ' + String.valueOf(sobjRec.getSobject(Constants.NAMESPACE +'Customer__r').get('Name')) : null;
                }
                this.Key = (sobjRec.get('Name') != null) ? String.valueOf(sobjRec.get('Name')) : null;
            } 
            
            String ownerFieldName = HomeSearchUtil.obejctNameToMapOfSortLabelToAPIName.get(objectName).get('Owner');
            List<String> ownerFieldsMap = ownerFieldName.split('\\.');
            
            this.Owner = (String) sobjRec.getSObject(ownerFieldsMap[0]).get(ownerFieldsMap[1]);
            this.OwnerId = (String) sobjRec.getSObject(ownerFieldsMap[0]).get('Id'); 
        }
    }
    
    /**
     * Name: getDateTimeFromString
     * Desc: Get Date Time From String 
     * @param:  (1) dtStr - String - string contain date and time
     * @return: DateTime - date time Object 
    **/
    public static String getFormattedDate(String dtStr) {
        String formattedDateTime;
        if(String.isNotBlank(dtStr)) {
            Date dt = Date.valueOf(dtStr);
            formattedDateTime = BPUtility.getFormatedDateTime(DateTime.newInstance(dt.year(), dt.month(), dt.day()));
        }
        return formattedDateTime;
    } 
}
