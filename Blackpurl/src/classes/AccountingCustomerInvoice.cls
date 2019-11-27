/**
 * Author: Pooja Khandelwal
 * Since: Dec 14, 2016
 * Name: AccountingCustomerInvoice
 * Description: Apex class to handle JSON related oprations of Customer Invoice object for Accounting.
**/
public with sharing class AccountingCustomerInvoice {
    // Co Invoice Header
    public AccountingCOInvoiceHeader AccountingCOInvoiceHeaderRec;
    
    // CO Invoice line Item
    public List<AccountingCOInvoiceItem> AccountingCOInvoiceItemsRecs;
    
    // CO Invoice Payments
    public List<AccountingCOInvoicePayment> AccountingCOInvoicePaymentsRecs;

    public Boolean IsTaxIncludingPricing;
    
    public List<TaxDetail> taxDetails;
    
    // This is created for removing rounding issue when Tax Including price market. This variable only populates when Tax Include pricing is On
    // For more detail, Please refer Ticket #4260
    public Map<String, Decimal> EntityIdToTotalSalesTaxValueMap;
    
    public Map<String, Decimal> unitIdToTaxAmountMap;
    
    // constructor
    public AccountingCustomerInvoice(CO_Invoice_Header__c coInvoiceHeaderRec, List<CO_Invoice_Item__c> coInvoiceItemList ) {
        this.AccountingCOInvoiceHeaderRec = new AccountingCOInvoiceHeader(coInvoiceHeaderRec, null);
        this.AccountingCOInvoiceItemsRecs = new List<AccountingCOInvoiceItem>();
        for(CO_Invoice_Item__c coInvoiceItemRec : coInvoiceItemList) {
            this.AccountingCOInvoiceItemsRecs.add(new AccountingCOInvoiceItem(coInvoiceItemRec));
        }
        //system.assert(false, COInvoiceItesRecs);
        this.IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        taxDetails = getSalesTaxList(coInvoiceHeaderRec);
    }
    
    // constructor
    public AccountingCustomerInvoice(CO_Invoice_Header__c coInvoiceHeaderRec, List<CO_Invoice_Item__c> coInvoiceItemList, List<CO_Invoice_Payment__c> coInvoicePaymentList, String claimNumber) {
        this.AccountingCOInvoiceHeaderRec = new AccountingCOInvoiceHeader(coInvoiceHeaderRec, claimNumber);
        this.AccountingCOInvoiceItemsRecs = new List<AccountingCOInvoiceItem>();
        for(CO_Invoice_Item__c coInvoiceItemRec : coInvoiceItemList) {
            this.AccountingCOInvoiceItemsRecs.add(new AccountingCOInvoiceItem(coInvoiceItemRec));
        }
        
        this.AccountingCOInvoicePaymentsRecs = new List<AccountingCOInvoicePayment>();
        for(CO_Invoice_Payment__c coInvoicePaymentRec : coInvoicePaymentList) {
            this.AccountingCOInvoicePaymentsRecs.add(new AccountingCOInvoicePayment(coInvoicePaymentRec));
        }
        
        //system.assert(false, COInvoiceItesRecs);
        this.IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        taxDetails = getSalesTaxList(coInvoiceHeaderRec);
    }
    
    
    
    private List<TaxDetail> getSalesTaxList(CO_Invoice_Header__c coInvoiceHeaderRec){
        
        List<TaxDetail> taxDetails = new List<TaxDetail>();
        List<Id> coliIds = new List<Id>();
        List<Id> sohIds = new List<Id>();
        List<Id> cokhIds = new List<Id>();
        List<Id> dealIds = new List<Id>();
        if(coInvoiceHeaderRec.CO_Invoice_Items__r != null) {
            for(CO_Invoice_Item__c coInvoiceItem : coInvoiceHeaderRec.CO_Invoice_Items__r) {
             
                if(coInvoiceItem.CO_Line_Item__c != null) {
                    coliIds.add(coInvoiceItem.CO_Line_Item__c);
                }
                if(coInvoiceItem.Service_Order_Header__c != null) {
                    if(!(coInvoiceItem.SO_Payment_Role__c != null && coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Deductible')) {
                        sohIds.add(coInvoiceItem.Service_Order_Header__c);
                    }
                }
                if(coInvoiceItem.CO_Kit_Header__c != null) {
                    cokhIds.add(coInvoiceItem.CO_Kit_Header__c);
                }
                if(coInvoiceItem.Deal__c != null) {
                    dealIds.add(coInvoiceItem.Deal__c);
                }
            }
        }
        
        Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>(); 
        Map<String, Sales_Tax_Item__c> salesTaxNameToSalesTax = new Map<String, Sales_Tax_Item__c>();  
        List<Sales_Tax_Item__c> salesTaxList = [select Id, AccountingId__c, Name__c, Rate__c, Category__r.AccountingId__c, Category__r.Name 
                                                from Sales_Tax_Item__c
                                                where Active__c = true];
                                                
        for(Sales_Tax_Item__c STI : salesTaxList){
            salesTaxNameToSalesTax.put(STI.Name__c, STI);
        }
        List<Individual_Tax__c> individualItemsList = 
                [SELECT CO_Line_Item__c, Service_Order_Line_Item__c, Option_Fee__c, Deal_Unit_Price_Cost__c, Deal_Unit_Price_Cost__r.Deal_Item__c, Deal_Item__c, Deal_Item__r.Pre_Tax_Agreed_Value__c, F_I_Product__c, Tax_Rate__c, 
                    Form_Label__c, Sales_Tax_Item_Name__c, Taxable_Amount__c, Tax_Amount__c, Applicable_Tax__c, List_Tax_items_on_forms__c, Per_Item_Tax_Amount__c
                  FROM Individual_Tax__c WHERE CO_Line_Item__c IN : coliIds
                            OR CO_Line_Item__r.CO_Kit_Header__c IN :cokhIds
                            OR (Service_Order_Line_Item__r.Service_Order_Header__r.Transaction_Type__r.Type__c != 'Internal' AND 
                                Service_Order_Line_Item__r.Service_Order_Header__r.Transaction_Type__r.Type__c != 'Stock Unit' AND Service_Order_Line_Item__r.Service_Order_Header__c IN :sohIds)
                            OR Option_Fee__r.Deal__c IN: dealIds
                            OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c IN: dealIds
                            OR F_I_Product__r.Deal__c IN: dealIds
                            OR (Deal_Item__r.Deal__c IN: dealIds AND Deal_Item__r.Type__c = 'Trade In')];
                            
        
        unitIdToTaxAmountMap = new Map<String, Decimal>();
        for(Individual_Tax__c indvTaxRec : individualItemsList) {
            if(String.isNotBlank(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c)) {
                Decimal taxAmount = 0.00;
                if(this.isTaxIncludingPricing) {
                    taxAmount += ((indvTaxRec.Tax_Amount__c != null) ? indvTaxRec.Tax_Amount__c : 0);
                } else if(salesTaxNameToSalesTax.containsKey(indvTaxRec.Sales_Tax_Item_Name__c) && 
                        salesTaxNameToSalesTax.get(indvTaxRec.Sales_Tax_Item_Name__c).Rate__c != null) {
                    taxAmount += ((salesTaxNameToSalesTax.get(indvTaxRec.Sales_Tax_Item_Name__c).Rate__c * indvTaxRec.Taxable_Amount__c)/100) ;
                }
            
                if(!unitIdToTaxAmountMap.containsKey(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c)) {
                    unitIdToTaxAmountMap.put(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c, 0);
                }
                unitIdToTaxAmountMap.put(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c, unitIdToTaxAmountMap.get(indvTaxRec.Deal_Unit_Price_Cost__r.Deal_Item__c) + taxAmount);
            }
        }
        
        Map<String, Decimal> taxItemToTaxableAmountMap = getTaxableAmountMap(individualItemsList);
        salesTaxNameToTaxValue = TaxCalculation.getTaxAmount(individualItemsList);
        populateEntityIdToTotalSalesTaxValueMap(individualItemsList);
        
        Decimal taxAmount;
        Decimal taxableAmount;
        for(Sales_Tax_Item__c STI : salesTaxList){
            taxAmount = 0;
            taxableAmount = 0;
            if(salesTaxNameToTaxValue.containsKey(STI.Name__c) && salesTaxNameToTaxValue.get(STI.Name__c) != null){
                taxAmount = salesTaxNameToTaxValue.get(STI.Name__c);
            }
            if(taxItemToTaxableAmountMap.containsKey(STI.Name__c) && taxItemToTaxableAmountMap.get(STI.Name__c) != null){
                taxableAmount = taxItemToTaxableAmountMap.get(STI.Name__c);
            }
            
            if(QBUtil.isQBTaxCodesEnabled) {
                taxDetails.add(new TaxDetail(STI.Id, STI.Name__c, taxAmount, taxableAmount, 
                                  salesTaxNameToSalesTax.get(STI.Name__c).AccountingId__c, 
                                  ''));
            } else {
                taxDetails.add(new TaxDetail(STI.Id, STI.Name__c, taxAmount, taxableAmount, 
                                  salesTaxNameToSalesTax.get(STI.Name__c).Category__r.AccountingId__c, 
                                  salesTaxNameToSalesTax.get(STI.Name__c).Category__r.Name));
            }
        }
        return taxDetails;
    }
    
    private void populateEntityIdToTotalSalesTaxValueMap(List<Individual_Tax__c> individualItemsList) {
        EntityIdToTotalSalesTaxValueMap = new Map<String, Decimal>();
        if(!this.IsTaxIncludingPricing) {
            return;
        }
        for(Individual_Tax__c indTaxRec : individualItemsList) {
            if(indTaxRec.Service_Order_Line_Item__c != null) {
                if(!EntityIdToTotalSalesTaxValueMap.containsKey(indTaxRec.Service_Order_Line_Item__c)) {
                    EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Service_Order_Line_Item__c, 0);
                }
                EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Service_Order_Line_Item__c, 
                    EntityIdToTotalSalesTaxValueMap.get(indTaxRec.Service_Order_Line_Item__c) + indTaxRec.Per_Item_Tax_Amount__c);
            } else if(indTaxRec.CO_Line_Item__c != null) {
                if(!EntityIdToTotalSalesTaxValueMap.containsKey(indTaxRec.CO_Line_Item__c)) {
                    EntityIdToTotalSalesTaxValueMap.put(indTaxRec.CO_Line_Item__c, 0);
                }
                EntityIdToTotalSalesTaxValueMap.put(indTaxRec.CO_Line_Item__c, EntityIdToTotalSalesTaxValueMap.get(indTaxRec.CO_Line_Item__c) + indTaxRec.Per_Item_Tax_Amount__c);
            } else if(indTaxRec.Option_Fee__c != null) {
                if(!EntityIdToTotalSalesTaxValueMap.containsKey(indTaxRec.Option_Fee__c)) {
                    EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Option_Fee__c, 0);
                }
                EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Option_Fee__c, EntityIdToTotalSalesTaxValueMap.get(indTaxRec.Option_Fee__c) + indTaxRec.Per_Item_Tax_Amount__c);
            } else if(indTaxRec.Deal_Unit_Price_Cost__c  != null) {
                if(!EntityIdToTotalSalesTaxValueMap.containsKey(indTaxRec.Deal_Unit_Price_Cost__c )) {
                    EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Deal_Unit_Price_Cost__c , 0);
                }
                EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Deal_Unit_Price_Cost__c, 
                        EntityIdToTotalSalesTaxValueMap.get(indTaxRec.Deal_Unit_Price_Cost__c) + indTaxRec.Per_Item_Tax_Amount__c);
            } else if(indTaxRec.Deal_Item__c   != null) {
                if(!EntityIdToTotalSalesTaxValueMap.containsKey(indTaxRec.Deal_Item__c)) {
                    EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Deal_Item__c, 0);
                }
                EntityIdToTotalSalesTaxValueMap.put(indTaxRec.Deal_Item__c,  EntityIdToTotalSalesTaxValueMap.get(indTaxRec.Deal_Item__c) + indTaxRec.Per_Item_Tax_Amount__c);
            } else if(indTaxRec.F_I_Product__c   != null) {
                if(!EntityIdToTotalSalesTaxValueMap.containsKey(indTaxRec.F_I_Product__c)) {
                    EntityIdToTotalSalesTaxValueMap.put(indTaxRec.F_I_Product__c, 0);
                }
                EntityIdToTotalSalesTaxValueMap.put(indTaxRec.F_I_Product__c, EntityIdToTotalSalesTaxValueMap.get(indTaxRec.F_I_Product__c) + indTaxRec.Per_Item_Tax_Amount__c);
            }
        }
    }
    
    public static Map<String, Set<String>> objectToFieldMap = new Map<String, Set<String>>{
        'COInvoiceHeader'       => new Set<String>{ 'Id',
                                            'Name', 
                                            'CO_Header__c',
                                            'CO_Header__r.Name',
                                            'CO_Header__r.CO_Type__c',
                                            'Invoice_Date__c',
                                            'Closed_Invoice_Date__c',
                                            'Invoice_Status__c',
                                            'Invoice_Number__c',
                                            'AccountingId__c',
                                            'Total_Payment__c',
                                            'Total__c',
                                            'Checkout_Type__c',
                                            'Is_Charge_Account_Payment_Exists__c',
                                            'Total_Amount_Except_Charge_Account__c',
                                            'SalesTax_Total__c',
                                            'SyncToken__c',
                                            'AccountingResponse__c',
                                            'CO_Header__r.Customer__c',
                                            'CO_Header__r.Customer__r.AccountingId__c',
                                            'CO_Header__r.Customer__r.Name',
                                            'availForQBJournalEntrySync__c',
                                            'AccountingResponseForJournalEntry__c',
                                            'JournalEntryAccountingId__c',
                                            'SyncTokenForJournalEntry__c',
                                            'AccountingIdForCOInvoicePayment__c',
                                            'SyncTokenForCOInvoicePayment__c',
                                            'AccountingResponseForCOInvoicePayment__c',
                                            'CreatedDate',
                                            'Xero_Accounting_Id__c',
                                            'Xero_CO_Invoice_Payment_Accounting_Id__c',
                                            'Xero_CO_Invoice_JE_Accounting_Id__c',
                                            'CO_Header__r.Customer__r.Xero_Customer_Accounting_Id__c',
                                            'CO_Header__r.Customer_Name__c'
                                            },
          
         'COInvoiceItem'        => new Set<String>{  'Id',
                                                    'Name', 
                                                    'Qty__c',
                                                    'CO_Invoice_Header__c',
                                                    'CO_Line_Item__c',
                                                    'isActive__c',
                                                    'Is_Invoiceable__c',
                                                    'CreatedDate',
                                                    
                                                    'CO_Line_Item__r.Part__c',
                                                    'CO_Line_Item__r.Part__r.Name',
                                                    'CO_Line_Item__r.Part__r.Part_Number__c',
                                                    'CO_Line_Item__r.Part__r.Description__c',
                                                    'CO_Line_Item__r.Part__r.Taxable__c',
                                                    'CO_Line_Item__r.Item_ID__c',
                                                    'CO_Line_Item__r.Item_Code__c',
                                                    'CO_Line_Item__r.Item_Description__c',
                                                    'CO_Line_Item__r.Qty_Committed__c',
                                                    'CO_Line_Item__r.Price__c',
                                                    'CO_Line_Item__r.Retail__c',
                                                    'CO_Line_Item__r.Tax__c',
                                                    'CO_Line_Item__r.Qty__c',
                                                    'CO_Line_Item__r.Fee__c',
                                                    'CO_Line_Item__r.Fee__r.Taxable__c',
                                                    'CO_Line_Item__r.Deal__c',

                                                    'CO_Line_Item__r.Part__r.Category__c',
                                                    'CO_Line_Item__r.Part__r.Category__r.AccountingId__c',
                                                    'CO_Line_Item__r.Part__r.Category__r.Name',
                                                    'CO_Line_Item__r.Part__r.Category__r.COGS_GL__c',
                                                    'CO_Line_Item__r.Part__r.Category__r.Income_GL__c',
                                                    'CO_Line_Item__r.Part__r.Category__r.Inventory_GL__c',
                                                    
                                                    'CO_Line_Item__r.Fee__r.Category__c',
                                                    'CO_Line_Item__r.Fee__r.Category__r.AccountingId__c',
                                                    'CO_Line_Item__r.Fee__r.Category__r.Name',
                                                    'CO_Line_Item__r.Fee__r.Category__r.COGS_GL__c',
                                                    'CO_Line_Item__r.Fee__r.Category__r.Income_GL__c',
                                                    'CO_Line_Item__r.Fee__r.Category__r.Inventory_GL__c',
                                                    
                                                    'Service_Order_Header__c',
                                                    'Service_Order_Header__r.SO_Type__c',
                                                    'Service_Order_Header__r.Name__c',
                                                    'Service_Order_Header__r.Total__c',
                                                    'Service_Order_Header__r.Tax_Amount__c',
                                                    'Service_Order_Header__r.Status__c',
                                                    'Service_Order_Header__r.Work_Status__c',
                                                    'Service_Order_Header__r.Claim_Status__c',
                                                    'Service_Order_Header__r.Transaction_Type__r.Type__c',
                                                    'Service_Order_Header__r.Provider__c',
                                                    'Service_Order_Header__r.Provider__r.Name',
                                                    'Service_Order_Header__r.Provider__r.AccountingId__c',
                                                    'Service_Order_Header__r.Provider__r.Xero_Customer_Accounting_Id__c',
                                                    'Service_Order_Header__r.Category__r.Name',
                                                    'Service_Order_Header__r.Deal__c',
                                                    'Service_Order_Header__r.Customer_Owned_Unit__r.Stock_Id__c',
                                                    'Service_Order_Header__r.Customer_Owned_Unit__r.VIN_Number_Formula__c',
                                                    'Service_Order_Header__r.Transaction_Type__r.Code_Label__c',
                                                    
                                                    'CO_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c',
                                                    'CO_Kit_Header__r.Price__c',
                                                    'CO_Kit_Header__r.Tax_Amount__c',
                                                    'CO_Kit_Header__r.Deal_Kit_Header__c',
                                                    'CO_Kit_Header__r.Deal_Kit_Header__r.Deal_Item__c',
                                                    'CO_Kit_Header__r.Deal_Kit_Header__r.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c',
                                                    'SO_Payment_Role__c',
                                                    'SO_Payment_Role__r.RecordType.DeveloperName',
                                                    'SO_Payment_Role__r.Total_Amount__c',
                                                    'SO_Payment_Role__r.Tax_Amount__c',
                                                    'SO_Payment_Role__r.Deductible_Status__c',
                                                    'SO_Payment_Role__r.Service_Order_Header__r.Name__c',
                                                    'SO_Payment_Role__r.Service_Order_Header__r.Work_Status__c',
                                                    'SO_Payment_Role__r.Claim__c',
                                                    'SO_Payment_Role__r.Claim__r.Claim_Disposition__c',
                                                    'SO_Payment_Role__r.Qty__c',
                                                    'SO_Payment_Role__r.Category__c',
                                                    'SO_Payment_Role__r.Category__r.Name',
                                                    'Deal__c',
                                                    'CO_Line_Item__r.Option_Fee__r.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c'
                                                                                                
                                            },
         'COHeader'         => new Set<String>{ 'Id', 
                                                'Customer__c',
                                                'Assignee__c',
                                                'Order_status__c',
                                                'Owner__c',
                                                'Customer__r.Name',
                                                'Assignee__r.Name',
                                                'Owner__r.Name',
                                                'Name',
                                                'CreatedDate',
                                                'LastModifiedDate',
                                                'Status__c',
                                                'Total_Deposit__c',
                                                'Total_Order_Value__c',
                                                'Total_Payment__c',
                                                'CO_Type__c',
                                                'Selling_Group__c',
                                                'Total_COLI__c',
                                                'Total_SO__c'
                                            },
        'COLineItem'            => new Set<String>{ 'Id',
                                                            'Name', 
                                                            'CO_Header__c',
                                                            'CO_Header__r.Name',
                                                            'CO_Header__r.Customer__c',
                                                            'CO_Header__r.CO_Type__c',
                                                            'CO_Header__r.Customer__r.Name',
                                                            'CO_Header__r.Owner__c',
                                                            'CO_Header__r.Owner__r.Name',
                                                            'CO_Header__r.Order_status__c',
                                                            'Item_Code__c',
                                                            'Item_Description__c',
                                                            'Qty__c',
                                                            'Qty_Committed__c',
                                                            'Price__c',
                                                            'Part__r.Name',
                                                            'Part__r.Part_Id__c',
                                                            'Part__r.Part_Number__c',
                                                            'Part__r.Description__c',
                                                            'Part__r.AvailableParts__c',
                                                            'Part__r.Vendor__c',
                                                            'Part__r.Taxable__c',
                                                            'Part__r.Category__c',
                                                            'Part__r.Category__r.AccountingId__c',
                                                            'Part__r.Category__r.Name',
                                                            'Part__r.Category__r.COGS_GL__c',
                                                            'Part__r.Category__r.Income_GL__c',
                                                            'Part__r.Category__r.Inventory_GL__c',
                                                            'Part__r.Average_Cost__c',
                                                            'Special_Order__c',
                                                            'Tax__c',
                                                            'Retail__c',
                                                            'Closed_CO_Invoice_link__c',
                                                            'VO_Number__c',
                                                            'VO_Status__c',
                                                            'Expected_Delivery_Date__c',
                                                            'CreatedDate',
                                                            'Fee__c',
                                                            'Fee__r.Fee_Unique_Name__c',
                                                            'Fixed_Price__c',
                                                            'CO_Fixed_KitLineItem__c',
                                                            'Actual_Kit_Price__c',
                                                            'Kit_Price_With_Price_Level__c',
                                                            'CO_Kit_Header__r.Id',
                                                            'Sub_Total_With_Tax__c',
                                                            'Sub_Total_Without_Tax__c',
                                                            'Tax_Amount__c',
                                                            'Oversold_Qty__c',
                                                            'Deal__c',
                                                            'Option_Fee__c',
                                                            'Price_When_Tax_Included__c',
                                                            'Fee__r.Taxable__c', 
                                                            'Fee__r.Category__c',
                                                            'Fee__r.Category__r.AccountingId__c',
                                                            'Fee__r.Category__r.Name',
                                                            'Fee__r.Category__r.COGS_GL__c',
                                                            'Fee__r.Category__r.Income_GL__c',
                                                            'Fee__r.Category__r.Inventory_GL__c',
                                                            'Fee__r.Cost_Method__c',
                                                            'Fee__r.Cost_Rate__c',
                                                            'Related_Option_And_Fees__c',
                                                            'Adjusted_Cost_Coli__c',
                                                            'Applicable_Tax__c',
                                                            'Applicable_Tax__r.Accounting_Id__c',
                                                            'Deal__r.Invoice_Number__r.CreatedDate',
                                                            'Option_Fee__r.Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c'
                                            },
                                            
        'DealItems'               => new Set<String>{
                                                        'Id',
                                                        'Deal__c', 
                                                        'Deal__r.Invoice_Number__c',
                                                        'Deal__r.Invoice_Number__r.Invoice_Date__c',
                                                        'Deal__r.Invoice_Number__r.Closed_Invoice_Date__c',
                                                        'Unit_Make__c',
                                                        'Unit_Make__r.Name',
                                                        'Unit_Model__c',
                                                        'Unit_Model__r.Name__c',
                                                        'Submodel__c',
                                                        'Sub_Model__c',
                                                        'Sub_Model__r.Sub_Model_Name__c',
                                                        'Sub_Model__r.Sub_Model_Description__c',
                                                        'Unit_Model__r.Sub_Model__c',
                                                        'Unit_Model__r.Model_Description__c',
                                                        'Year__c',
                                                        'Colour__c',
                                                        'Customer_Owned_Unit__c',
                                                        'Customer_Owned_Unit__r.Unit_Make__c',
                                                        'Customer_Owned_Unit__r.Unit_Make__r.Name',
                                                        'Customer_Owned_Unit__r.Unit_Model__c',
                                                        'Customer_Owned_Unit__r.Unit_Model__r.Name__c',
                                                        'Customer_Owned_Unit__r.Submodel__c',
                                                        'Customer_Owned_Unit__r.Submodel__r.Name__c',
                                                        'Customer_Owned_Unit__r.Sub_Model__c',
                                                        'Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c',
                                                        'Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Description__c',
                                                        'Customer_Owned_Unit__r.Colour__c',
                                                        'Customer_Owned_Unit__r.Year__c',
                                                        'Customer_Owned_Unit__r.Status__c',
                                                        'Customer_Owned_Unit__r.VIN_Number__c',
                                                        'Customer_Owned_Unit__r.Unit_Type__c',
                                                        'Customer_Owned_Unit__r.Unit_Number__c',
                                                        'Customer_Owned_Unit__r.Unit_Model__r.Sub_Model__c',
                                                        'Type__c',
                                                        'Agreed_Value__c',
                                                        'Actual_Cash_Value__c',
                                                        'Is_Stocked_In__c',
                                                        'Stocked_In_Unit__r.Category__r.Inventory_GL__c',
                                                        'Stocked_In_Unit__r.Category__r.Name',
                                                        'Approved_By__c',
                                                        'Appraisal_Method__c',
                                                        'Appraisal_Notes__c',
                                                        'Appraisal_Status__c',
                                                        'Approved_By__r.Name',
                                                        'Option_And_Fee_Status__c',
                                                        'Default_Unit_Sales_Tax_Percentage__c',
                                                        'Customer_Owned_Unit__r.Trade_In_Value__c',
                                                        'Customer_Owned_Unit__r.Sales_Tax_Credit__c',
                                                        'Customer_Owned_Unit__r.Category__r.AccountingId__c',
                                                        'Customer_Owned_Unit__r.Category__r.Name',
                                                        'Customer_Owned_Unit__r.Taxable__c',
                                                        'Customer_Owned_Unit__r.Stock_Id__c',
                                                        'Customer_Owned_Unit__r.Category__r.Inventory_GL__c',
                                                        'Customer_Owned_Unit__r.Category__r.COGS_GL__c',
                                                        'Customer_Owned_Unit__r.Category__r.Income_GL__c',
                                                        'Stamp_Duty_Total__c',
                                                        'Lien_Payout__c',
                                                        'Finance_Company__r.Name',
                                                        'Applicable_Tax__c',
                                                        'Applicable_Tax__r.Accounting_Id__c',
                                                        'Stocked_In_Unit__r.Stock_Id__c'
                                },
        'OptionAndFees'               => new Set<String>{'Id',
                                                            'Deal__c', 
                                                            'Deal__r.Is_Deal_Fulfilled__c',
                                                            'Deal_Item__c',
                                                            'Deal_Item__r.Deal__c',
                                                            'Deal_Item__r.Customer_Owned_Unit__c',
                                                            'Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c',
                                                            'Deal_Item__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c',
                                                            'Deal_Item__r.Customer_Owned_Unit__r.Category__r.COGS_GL__c',
                                                            'Deal_Item__r.Customer_Owned_Unit__r.Category__r.Income_GL__c',
                                                            'Qty__c',
                                                            'Part__c',
                                                            'Part__r.Description__c',
                                                            'Part__r.Part_Number__c',
                                                            'Part__r.AvailableParts__c',
                                                            'Fee__c',
                                                            'Fee__r.Code__c',
                                                            'Fee__r.Description__c',
                                                            'Labour_Code__c',
                                                            'Labour_Code__r.Code__c',
                                                            'Labour_Code__r.Description__c',
                                                            'Fee__r.Taxable__c',
                                                            'Fee__r.Applicable_Tax__c',
                                                            'Labour_Code__r.Taxable__c',
                                                            'Labour_Code__r.Applicable_Tax__c',
                                                            'Part__r.Taxable__c',
                                                            'Part__r.Applicable_Tax__c',
                                                            'Product__r.Description__c',
                                                            'Product__r.Code__c',
                                                            'Is_Install__c',
                                                            'Price__c',
                                                            'Item_Description__c',
                                                            'Status__c',
                                                            'Item_Code__c',
                                                            'Sales_Tax_Percentage__c',
                                                            'Product__c',
                                                            'Product__r.Type__c',
                                                            'CreatedDate',
                                                            'Deal_Kit_Header__c',
                                                            'Is_Fixed_Kit_Line_Item_CO__c',
                                                            'Is_Fixed_Price__c',
                                                            'Actual_Kit_Price__c',
                                                            'Fixed_Price__c',
                                                            'Part__r.Non_Inventory_Part__c',
                                                            'Price_When_Tax_Included__c',
                                                            'Part__r.Category__r.AccountingId__c',
                                                            'Part__r.Category__r.Name',
                                                            'Part__r.Category__r.COGS_GL__c',
                                                            'Part__r.Category__r.Income_GL__c',
                                                            'Part__r.Category__r.Inventory_GL__c',
                                                            'Fee__r.Category__r.AccountingId__c',
                                                            'Fee__r.Category__r.Name',
                                                            'Fee__r.Category__r.COGS_GL__c',
                                                            'Fee__r.Category__r.Income_GL__c',
                                                            'Fee__r.Category__r.Inventory_GL__c',
                                                            'Fee__r.Cost_Method__c',
                                                            'Fee__r.Cost_Rate__c',
                                                            'Labour_Code__r.Category__r.AccountingId__c',
                                                            'Labour_Code__r.Category__r.Name',
                                                            'Labour_Code__r.Category__r.COGS_GL__c',
                                                            'Labour_Code__r.Category__r.Income_GL__c',
                                                            'Labour_Code__r.Category__r.Inventory_GL__c',
                                                            'Product__r.Category__r.AccountingId__c',
                                                            'Product__r.Category__r.Name',
                                                            'Product__r.Taxable__c',
                                                            'Product__r.Category__r.COGS_GL__c',
                                                            'Product__r.Category__r.Income_GL__c',
                                                            'Product__r.Category__r.Inventory_GL__c',
                                                            'Product__r.Cost_Method__c',
                                                            'Product__r.Cost__c',
                                                            'Per_Item_Cost__c',
                                                            'Applicable_Tax__c',
                                                            'Applicable_Tax__r.Accounting_Id__c'
                                                            
                                },
        'DealUnitPriceCost'               => new Set<String>{'Id',
                                                            'Item_Description__c', 
                                                            'Qty__c',
                                                            'Price__c',
                                                            'Total_Price__c',
                                                            'Type__c',                                                          
                                                            'Tax_Percent__c',
                                                            'Tax_Amount__c',
                                                            'Sales_Tax_Percentage__c',
                                                            'Unit_Price_Cost__c',
                                                            'Price_When_Tax_Included__c',
                                                            'Unit_Price_Cost__r.Customer_Owned_Unit__r.Category__r.AccountingId__c',
                                                            'Unit_Price_Cost__r.Customer_Owned_Unit__r.Category__r.Name',
                                                            'Unit_Price_Cost__r.Customer_Owned_Unit__r.Taxable__c',
                                                            'Unit_Price_Cost__r.Customer_Owned_Unit__r.Category__r.COGS_GL__c',
                                                            'Unit_Price_Cost__r.Customer_Owned_Unit__r.Category__r.Income_GL__c',
                                                            'Unit_Price_Cost__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c',
                                                            'Unit_Price_Cost__r.Customer_Owned_Unit__c',
                                                            'Unit_Price_Cost__r.Cost__c',
                                                            'Unit_Price_Cost__r.Total_Cost__c',
                                                            'Applicable_Tax__c',
                                                            'Applicable_Tax__r.Accounting_Id__c'
                                                               
                                },
        'DealFIProduct'               => new Set<String>{'Id',
                                                        'Item_Description__c',
                                                        'Price_When_Tax_Included__c',
                                                        'Price__c',
                                                        'Total__c',
                                                        'Vendor_Product__c',
                                                        'Vendor_Product__r.Category__c',
                                                        'Vendor_Product__r.Category__r.AccountingId__c',
                                                        'Vendor_Product__r.Category__r.Name',
                                                        'Vendor_Product__r.Category__r.COGS_GL__c',
                                                        'Vendor_Product__r.Category__r.Income_GL__c',
                                                        'Vendor_Product__r.Category__r.Inventory_GL__c',
                                                        'Vendor_Product__r.Cost_Method__c',
                                                        'Vendor_Product__r.Cost__c',
                                                        'Applicable_Tax__c',
                                                        'Applicable_Tax__r.Accounting_Id__c',
                                                        'Sales_Tax_Percentage__c'
                                }
    };
    
    
    // Start: AccountingCOInvoiceHeader Wraaper
    public class AccountingCOInvoiceHeader{
        // CO Line Invoice Header Id
        public String COInvoiceHeaderId;
        
        // CO Line Header Id
        public String COHeaderId;
        
        public String COHeaderNumber;
        
        // Date when the Invoice is closed
        public String ClosedInvoiceDate;
        
        //Date time field for co invoice date
        public DateTime CreatedDate;
		
        // Date when CO Invoiced
        public DateTime COInvoiceDate;
        
        // Invoice Status
        public String InvoiceStatus;
        
        // Checkout Type
        public String CheckoutType;
        
        // Claim number
        public String ClaimNumber;
        
        // Customer name
        public String CustomerName;
        
        // Customer id
        public String CustomerId;
        
        // Invoice Number
        public String COInvoiceHeaderNumber;
        
        public Decimal TotalPayment;
        
        public Decimal InvoiceTotal;
        
        public Decimal TotalSalesTax;
        
        public CustomerWrapper customer;
        
        public SalesTaxWrapper salesTax;
        
        public Boolean isChargeOnAccountPaymentMethod;
        
        public Decimal totalPaymentExcludingChargeAccount;
        // Customer Invoice AccountingId
        public String AccountingId;
        
        // Customer Invoice SyncToken
        public String SyncToken;
        
        public String accountingResponse;
        
        // Customer Invoice Journal Entry AccountingId
        public String JournalEntryAccountingId;
        
        // Customer Invoice Journal Entry SyncToken
        public String JournalEntrySyncToken;
        
        public String JournalEntryAccountingResponse;
    
        public String COInvoicePaymentAccountingId;
        
        // Customer payment Journal Entry SyncToken
        public String COInvoicePaymentSyncToken;
        
        public String COInvoicePaymentAccountingResponse;
        
        public String XeroCustomerAccountingId;
        
        public String XeroAccountingId;
        
        public String XeroCOInvoicePaymentAccountingId;
        
        public String XeroCOInvoiceJEAccountingId;
        
        public String COType;
        
        public String FormattedCustomerName;
        
        // Constructor
        public AccountingCOInvoiceHeader(CO_Invoice_Header__c coInvoiceHeaderRec, String claimNumber) { 
            this.COInvoiceHeaderId = coInvoiceHeaderRec.Id;
            this.COHeaderId = coInvoiceHeaderRec.CO_Header__c;
            this.COHeaderNumber = coInvoiceHeaderRec.CO_Header__r.Name;
            if(coInvoiceHeaderRec.Invoice_Date__c != null) {
                this.ClosedInvoiceDate = DateTimeUtility.getFormttedDateFromDateTime(coInvoiceHeaderRec.Invoice_Date__c, 'dd/MM/yyyy');
            } else {
                this.ClosedInvoiceDate = '';
            }
            this.CreatedDate = coInvoiceHeaderRec.CreatedDate;
            this.COInvoiceDate = coInvoiceHeaderRec.Invoice_Date__c;
            this.InvoiceStatus = coInvoiceHeaderRec.Invoice_Status__c;
            this.CheckoutType = coInvoiceHeaderRec.Checkout_Type__c;
            this.COInvoiceHeaderNumber = (coInvoiceHeaderRec.Invoice_Number__c == null) ? '' : coInvoiceHeaderRec.Invoice_Number__c;
            this.TotalPayment = coInvoiceHeaderRec.Total_Payment__c;
            this.InvoiceTotal = coInvoiceHeaderRec.Total__c;
            this.TotalSalesTax = coInvoiceHeaderRec.SalesTax_Total__c;
            //this.customer = new CustomerWrapper(coInvoiceHeaderRec.CO_Header__r.Customer__r.AccountingId__c, coInvoiceHeaderRec.CO_Header__r.Customer__r.Name);
            this.FormattedCustomerName = coInvoiceHeaderRec.CO_Header__r.Customer_Name__c;
            if(coInvoiceHeaderRec.CO_Header__r.Customer__c == null){
                Accounting_Default_Accounts__c accDefaultAccount = Accounting_Default_Accounts__c.getOrgDefaults();
                if(coInvoiceHeaderRec.CO_Header__r.CO_Type__c == Constants.CASH_SALE){
                    this.customer = new CustomerWrapper(accDefaultAccount.Cash_Sale_Customer_Id__c, 'Cash Sale');
                    this.XeroCustomerAccountingId = accDefaultAccount.Cash_Sale_Customer_Id__c;
                }  else if(coInvoiceHeaderRec.CO_Header__r.CO_Type__c == Constants.INTERNAL_SERVICE){
                	if(coInvoiceHeaderRec.CO_Invoice_Items__r.size() > 0 && coInvoiceHeaderRec.CO_Invoice_Items__r[0] != null &&
            			coInvoiceHeaderRec.CO_Invoice_Items__r[0].Service_Order_Header__c != null && coInvoiceHeaderRec.CO_Invoice_Items__r[0].Service_Order_Header__r.Transaction_Type__r.Type__c == 'Third-Party') {
	                	this.customer = new CustomerWrapper(coInvoiceHeaderRec.CO_Invoice_Items__r[0].Service_Order_Header__r.Provider__r.AccountingId__c, coInvoiceHeaderRec.CO_Invoice_Items__r[0].Service_Order_Header__r.Provider__r.Name);
	                	this.XeroCustomerAccountingId = coInvoiceHeaderRec.CO_Invoice_Items__r[0].Service_Order_Header__r.Provider__r.Xero_Customer_Accounting_Id__c;
	                	this.FormattedCustomerName = coInvoiceHeaderRec.CO_Invoice_Items__r[0].Service_Order_Header__r.Provider__r.Name;
	                } else {
	                	this.customer = new CustomerWrapper(accDefaultAccount.Internal_Service_Customer_Id__c, 'Internal Service');
	                	this.XeroCustomerAccountingId = accDefaultAccount.Internal_Service_Customer_Id__c;
	                }
                }                                     
            }else{
                for(CO_Invoice_Item__c coInvoiceItem: coInvoiceHeaderRec.CO_Invoice_Items__r) {
                    if(coInvoiceItem.Service_Order_Header__c != null && coInvoiceItem.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Third-Party' && coInvoiceHeaderRec.Checkout_Type__c != null && coInvoiceHeaderRec.Checkout_Type__c == 'Third-Party') {
                        this.customer = new CustomerWrapper(coInvoiceItem.Service_Order_Header__r.Provider__r.AccountingId__c, coInvoiceItem.Service_Order_Header__r.Provider__r.Name);
                        this.CustomerName = coInvoiceHeaderRec.CO_Header__r.Customer__r.Name;
                        this.XeroCustomerAccountingId = coInvoiceItem.Service_Order_Header__r.Provider__r.Xero_Customer_Accounting_Id__c;
                        this.FormattedCustomerName = coInvoiceItem.Service_Order_Header__r.Provider__r.Name;
                    } else {
                        this.customer = new CustomerWrapper(coInvoiceHeaderRec.CO_Header__r.Customer__r.AccountingId__c, coInvoiceHeaderRec.CO_Header__r.Customer__r.Name);
                        this.XeroCustomerAccountingId = coInvoiceHeaderRec.CO_Header__r.Customer__r.Xero_Customer_Accounting_Id__c;
                    }
                    break;
                }
            }
            this.CustomerId = coInvoiceHeaderRec.CO_Header__r.Customer__c;
            this.ClaimNumber = claimNumber;
            this.isChargeOnAccountPaymentMethod = coInvoiceHeaderRec.Is_Charge_Account_Payment_Exists__c > 0 ? true : false;
            this.totalPaymentExcludingChargeAccount = coInvoiceHeaderRec.Total_Amount_Except_Charge_Account__c;
            this.AccountingId = coInvoiceHeaderRec.AccountingId__c;
            this.SyncToken = coInvoiceHeaderRec.SyncToken__c;
            this.accountingResponse = coInvoiceHeaderRec.AccountingResponse__c;
            
            this.JournalEntryAccountingId = coInvoiceHeaderRec.JournalEntryAccountingId__c;
            this.JournalEntrySyncToken = coInvoiceHeaderRec.SyncTokenForJournalEntry__c;
            this.JournalEntryAccountingResponse = coInvoiceHeaderRec.AccountingResponseForJournalEntry__c;

            this.COInvoicePaymentAccountingId = coInvoiceHeaderRec.AccountingIdForCOInvoicePayment__c;
            this.COInvoicePaymentSyncToken = coInvoiceHeaderRec.SyncTokenForCOInvoicePayment__c;
            this.COInvoicePaymentAccountingResponse = coInvoiceHeaderRec.AccountingResponseForCOInvoicePayment__c;
            
            this.XeroAccountingId = coInvoiceHeaderRec.Xero_Accounting_Id__c;
            this.XeroCOInvoicePaymentAccountingId = coInvoiceHeaderRec.Xero_CO_Invoice_Payment_Accounting_Id__c;
            this.XeroCOInvoiceJEAccountingId = coInvoiceHeaderRec.Xero_CO_Invoice_JE_Accounting_Id__c;
            this.COType = coInvoiceHeaderRec.CO_Header__r.CO_Type__c;
        }
        
        /**
         * Name: parse
         * Desc: Method to Parse JSON String to class instance
         * @param:  (1) JSONString - String - JSON String 
         * @return: COLineItem - Class Object 
        **/
        public COInvoiceHeader parse(String json) {
            return (COInvoiceHeader) System.JSON.deserialize(json, COInvoiceHeader.class);
        }
    }
    // End: AccountingCOInvoiceHeader Wraaper   
    
    // Start: AccountingCOInvoiceItem Wraaper
    public class AccountingCOInvoiceItem {
        public String Item;
        public String ItemCode;
        public String ItemDescription;
        public Decimal Qty;
        public String Id;
        public String COLineItemId;
        public String SOHeaderId;
        public String COKitHeaderId;
        public String SOPaymentRoleId;
        public Decimal Price;
        
        public Decimal Total;
        public String COInvoiceHeaderId;
        public String COInvoiceItemId;
        public Boolean IsActive;
        public String COInvoiceItemNumber;
        public Decimal TaxAmount;
        public Decimal QtyRequired;
        public Decimal RetailPrice;
        public Decimal Saving;
        
        // Id
        public Boolean IsInvoiceable;
        public String SOStatus;
        public Boolean IsFinalizable;
        public String CheckoutType;
        public String ItemType;
        public Boolean isTaxIncludingPricing;
        public String DealId;
        public String SkuNumber;
        public String VinNumber;
        public String ServiceJobType;
        public String ServiceJobName;
        public String SKUNumberonDealService;
        
        // Constructor
        public AccountingCOInvoiceItem(CO_Invoice_Item__c  coInvoiceItemRec) {
            this.TaxAmount = 0;
            this.IsInvoiceable = false;
            this.isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            if(coInvoiceItemRec.CO_Line_Item__c != null) {
                /* START: Added By Tarun - #170 - 09/23/2016 */
                this.ItemCode = (coInvoiceItemRec.CO_Line_Item__r.Item_Code__c != null) ? coInvoiceItemRec.CO_Line_Item__r.Item_Code__c : '';
                this.ItemDescription = (coInvoiceItemRec.CO_Line_Item__r.Item_Description__c != null) ? coInvoiceItemRec.CO_Line_Item__r.Item_Description__c : '';
                this.Item = this.ItemCode + ' - ' + this.ItemDescription;
                this.Qty = coInvoiceItemRec.CO_Line_Item__r.Qty_Committed__c;
                this.Id = coInvoiceItemRec.Id;
                this.COLineItemId = coInvoiceItemRec.CO_Line_Item__c;
                this.Price = (coInvoiceItemRec.CO_Line_Item__r.Price__c != null) ? coInvoiceItemRec.CO_Line_Item__r.Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                if(coInvoiceItemRec.CO_Line_Item__r.Price__c == null) {     
                    this.Price = 0;     
                } else {        
                    if(!isTaxIncludingPricing) {        
                        this.Price = coInvoiceItemRec.CO_Line_Item__r.Price__c.setScale(2, RoundingMode.HALF_UP);
                        if(coInvoiceItemRec.CO_Line_Item__r.Tax__c == null) {
                            coInvoiceItemRec.CO_Line_Item__r.Tax__c = 0;
                        } 
                        this.TaxAmount = ((this.Qty) * (this.Price) * (coInvoiceItemRec.CO_Line_Item__r.Tax__c / 100)).setScale(2, RoundingMode.HALF_UP);     
                    } else {        
                        if(coInvoiceItemRec.CO_Line_Item__r.Tax__c == null) {
                            coInvoiceItemRec.CO_Line_Item__r.Tax__c = 0;
                        }
                        this.Price = (coInvoiceItemRec.CO_Line_Item__r.Price__c * (1 + coInvoiceItemRec.CO_Line_Item__r.Tax__c /100)).setScale(2, RoundingMode.HALF_UP);  
                        this.TaxAmount = ((this.Qty) * (coInvoiceItemRec.CO_Line_Item__r.Price__c) * (coInvoiceItemRec.CO_Line_Item__r.Tax__c / 100)).setScale(2,RoundingMode.HALF_UP);  
                    }       
                }
                if(coInvoiceItemRec.CO_Line_Item__r.Tax__c == null) {
                    coInvoiceItemRec.CO_Line_Item__r.Tax__c = 0;
                }
                
                this.Total = ((this.Qty) * (this.Price)).setScale(2,RoundingMode.HALF_UP);
                this.isActive = coInvoiceItemRec.isActive__c;
                this.COInvoiceItemNumber = coInvoiceItemRec.Name;
                
                this.QtyRequired = coInvoiceItemRec.CO_Line_Item__r.Qty__c;
                this.RetailPrice = (coInvoiceItemRec.CO_Line_Item__r.Retail__c != null) ? coInvoiceItemRec.CO_Line_Item__r.Retail__c.setScale(2,RoundingMode.HALF_UP) : 0.00;
                if(coInvoiceItemRec.CO_Line_Item__r.Retail__c == null) {
                    coInvoiceItemRec.CO_Line_Item__r.Retail__c = 0.00;
                } 
                if(coInvoiceItemRec.CO_Line_Item__r.Price__c == null) {
                    coInvoiceItemRec.CO_Line_Item__r.Price__c = 0.00;
                }
                this.Saving = (this.QtyRequired) * (coInvoiceItemRec.CO_Line_Item__r.Retail__c - coInvoiceItemRec.CO_Line_Item__r.Price__c);
                
                if(coInvoiceItemRec.CO_Line_Item__r.Qty_Committed__c > 0) {
                    this.IsInvoiceable = true;
                } else {
                    this.IsInvoiceable = false;
                }
                
                if(coInvoiceItemRec.CO_Line_Item__r.Qty__c == coInvoiceItemRec.CO_Line_Item__r.Qty_Committed__c && coInvoiceItemRec.isActive__c){
                    this.IsFinalizable = true;
                } else {
                    this.IsFinalizable = false;
                }
                
                if(coInvoiceItemRec.CO_Line_Item__r.Qty__c < 0) {
                    this.Qty = coInvoiceItemRec.CO_Line_Item__r.Qty__c;
                    this.Total = ((this.Qty) * (this.Price)).setScale(2, RoundingMode.HALF_UP);
                    this.TaxAmount = ((this.Qty) * (this.Price) * (coInvoiceItemRec.CO_Line_Item__r.Tax__c / 100)).setScale(2, RoundingMode.HALF_UP);
                    this.IsFinalizable = true;
                    this.IsInvoiceable = true;
                }
                this.CheckoutType = Constants.CHECKOUT_TYPE_CUSTOMER;
                
                if(coInvoiceItemRec.CO_Line_Item__r.Part__c != null) {
                    this.ItemType = Constants.PART_INVOICE_ITEM_TYPE;
                } else if(coInvoiceItemRec.CO_Line_Item__r.Fee__c != null) {
                    this.ItemType = Constants.PART_INVOICE_ITEM_TYPE;
                }
            	this.SkuNumber = coInvoiceItemRec.CO_Line_Item__r.Option_Fee__c !=null ? coInvoiceItemRec.CO_Line_Item__r.Option_Fee__r.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c : '';
            } else if(coInvoiceItemRec.Service_Order_Header__c != null) {
            	this.ServiceJobType = coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c;
            	this.ServiceJobName = coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Code_Label__c;
            	if(coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Internal' || coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Stock Unit') {
                	this.SkuNumber = coInvoiceItemRec.Service_Order_Header__r.Customer_Owned_Unit__r.Stock_Id__c;
                	this.VinNumber = coInvoiceItemRec.Service_Order_Header__r.Customer_Owned_Unit__r.VIN_Number_Formula__c;
                }
                this.SOHeaderId = coInvoiceItemRec.Service_Order_Header__c;
                if(coInvoiceItemRec.SO_Payment_Role__c != null && coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Third-Party'){
                    this.SOPaymentRoleId = coInvoiceItemRec.SO_Payment_Role__c;
                    populateSOPaymentRoleFields(coInvoiceItemRec);
                } 
                else if(coInvoiceItemRec.SO_Payment_Role__c == null && coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Third-Party' ){
                    populateSOThirdParty(coInvoiceItemRec);
                } else {
                    if(coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Internal' || coInvoiceItemRec.Service_Order_Header__r.Transaction_Type__r.Type__c == 'Stock Unit') {
                        if(coInvoiceItemRec.Service_Order_Header__r.SO_Type__c == 'Internal Service') {
                            this.Item = coInvoiceItemRec.Service_Order_Header__r.Name__c + ' - INTERNAL ';
                        } else {
                            this.Item = coInvoiceItemRec.Service_Order_Header__r.Name__c + ' - INTERNAL - ' + coInvoiceItemRec.Service_Order_Header__r.Category__r.Name;
                        }
                        this.CheckoutType = Constants.CHECKOUT_TYPE_INTERNAL;
                    } else {
                        this.Item = coInvoiceItemRec.Service_Order_Header__r.Name__c;
                        this.CheckoutType = Constants.CHECKOUT_TYPE_CUSTOMER;
                    }
                    this.isActive = coInvoiceItemRec.isActive__c;
                    this.Total = coInvoiceItemRec.Service_Order_Header__r.Total__c;     
                    this.TaxAmount = (coInvoiceItemRec.Service_Order_Header__r.Tax_Amount__c != null) ? coInvoiceItemRec.Service_Order_Header__r.Tax_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                    if(isTaxIncludingPricing) {     
                        if(this.Total == null) {        
                            this.Total = 0;     
                        }       
                        if(this.TaxAmount == null) {        
                            this.TaxAmount = 0;     
                        }       
                        this.Total = this.Total + this.TaxAmount;       
                    }       
                    this.Price = this.Total;
                    if(coInvoiceItemRec.Service_Order_Header__r.Work_Status__c == Constants.SERVICE_ORDER_STATUS_TO_CHECKOUT) {
                        this.IsInvoiceable = coInvoiceItemRec.Is_Invoiceable__c;
                        this.isActive  = this.IsInvoiceable;
                        
                    } else {
                        this.isActive = false;
                    }
                    this.SOStatus = coInvoiceItemRec.Service_Order_Header__r.Status__c;
                    
                    if(coInvoiceItemRec.isActive__c &&  coInvoiceItemRec.Is_Invoiceable__c && (coInvoiceItemRec.Service_Order_Header__r.Status__c == 'Complete'|| coInvoiceItemRec.Service_Order_Header__r.Status__c == 'Reviewed')){
                        this.IsFinalizable = true;
                    } else {
                        this.IsFinalizable = false;
                    }
                    this.ItemType = Constants.WORK_SERVICE_ORDER_INVOICE_ITEM_TYPE;
                }
            } else if(coInvoiceItemRec.CO_Kit_Header__c != null){
                
                this.COKitHeaderId = coInvoiceItemRec.CO_Kit_Header__c;
                
                if(coInvoiceItemRec.CO_Kit_Header__r.Kit_Header__c != null) {
                    this.Item = coInvoiceItemRec.CO_Kit_Header__r.Kit_Header__r.Kit_Unique_Name__c;
                }
                this.isActive = coInvoiceItemRec.isActive__c;
                this.IsInvoiceable = coInvoiceItemRec.Is_Invoiceable__c;
                if(!isTaxIncludingPricing) {
                    this.Total = (coInvoiceItemRec.CO_Kit_Header__r.Price__c != null) ? coInvoiceItemRec.CO_Kit_Header__r.Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                    this.TaxAmount = (coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c != null) ? coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                }else{
                        this.TaxAmount = (coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c != null) ? coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                        this.Total = ((coInvoiceItemRec.CO_Kit_Header__r.Price__c != null) ? coInvoiceItemRec.CO_Kit_Header__r.Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00) + ((coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c != null) ? coInvoiceItemRec.CO_Kit_Header__r.Tax_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00);
                }
                if(coInvoiceItemRec.isActive__c && coInvoiceItemRec.Is_Invoiceable__c ){
                    this.IsFinalizable = true;
                } else {  
                    this.IsFinalizable = false;
                }
                this.CheckoutType = Constants.CHECKOUT_TYPE_CUSTOMER;
                this.ItemType = Constants.KIT_INVOICE_ITEM_TYPE;
                this.SkuNumber = coInvoiceItemRec.CO_Kit_Header__c != null && coInvoiceItemRec.CO_Kit_Header__r.Deal_Kit_Header__c != null && coInvoiceItemRec.CO_Kit_Header__r.Deal_Kit_Header__r.Deal_Item__c != null ?  coInvoiceItemRec.CO_Kit_Header__r.Deal_Kit_Header__r.Deal_Item__r.Customer_Owned_Unit__r.Stock_Id__c : '';
            }else if(coInvoiceItemRec.Deal__c != null){
                this.DealId = coInvoiceItemRec.Deal__c;
            }
            this.COInvoiceHeaderId = coInvoiceItemRec.CO_Invoice_Header__c;
            this.COInvoiceItemId = coInvoiceItemRec.Id;
            
            this.SKUNumberonDealService = (coInvoiceItemRec.Service_Order_Header__c !=null && coInvoiceItemRec.Service_Order_Header__r.Deal__c != null) ? coInvoiceItemRec.Service_Order_Header__r.Customer_Owned_Unit__r.Stock_Id__c : '';
        }
        
        public void populateSOPaymentRoleFields(CO_Invoice_Item__c  coInvoiceItemRec) {
            if(coInvoiceItemRec.SO_Payment_Role__r.RecordType.DeveloperName == 'Deductible') {
                if(coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c > 0) {
                    if(coInvoiceItemRec.SO_Payment_Role__r.Deductible_Status__c == 'Owing') {
                        this.Item = coInvoiceItemRec.SO_Payment_Role__r.Service_Order_Header__r.Name__c + ' - CLAIM - Deductible Adjustment';
                    } else {
                        this.Item = coInvoiceItemRec.SO_Payment_Role__r.Service_Order_Header__r.Name__c + ' - CLAIM - Deductible';
                    } 
                    this.isActive = coInvoiceItemRec.isActive__c;
                    this.Total = (coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c != null) ? coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                    this.IsInvoiceable = coInvoiceItemRec.Is_Invoiceable__c;
                    this.CheckoutType = Constants.CHECKOUT_TYPE_CUSTOMER;
                }
            }
            
            if(coInvoiceItemRec.SO_Payment_Role__r.RecordType.DeveloperName == 'Third_Party') {
                if(coInvoiceItemRec.SO_Payment_Role__r.Claim__c != null && coInvoiceItemRec.SO_Payment_Role__r.Claim__r.Claim_Disposition__c != 'Denied') {
                    this.Item = coInvoiceItemRec.SO_Payment_Role__r.Service_Order_Header__r.Name__c + ' - CLAIM - ' + coInvoiceItemRec.Service_Order_Header__r.Claim_Status__c + ' - ' + coInvoiceItemRec.Service_Order_Header__r.Provider__r.Name;
                    this.isActive = coInvoiceItemRec.isActive__c;
                    this.Total = (coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c != null) ? coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                    if(coInvoiceItemRec.SO_Payment_Role__r.Service_Order_Header__r.Work_Status__c == Constants.SERVICE_ORDER_STATUS_TO_CHECKOUT) {
                        this.IsInvoiceable = coInvoiceItemRec.Is_Invoiceable__c;
                    } else {
                        this.IsInvoiceable = false;
                    }
                    this.CheckoutType = Constants.CHECKOUT_TYPE_THIRD_PARTY;
                }
                
            }
            
            if(coInvoiceItemRec.SO_Payment_Role__r.RecordType.DeveloperName == 'Internal') {
                if(coInvoiceItemRec.Service_Order_Header__r != null) {
                    this.Item = coInvoiceItemRec.Service_Order_Header__r.Name__c + ' - CLAIM VARIANCE ' + ((coInvoiceItemRec.SO_Payment_Role__r.Category__c != null) ? (' - ' + coInvoiceItemRec.SO_Payment_Role__r.Category__r.Name) : '');
                    this.isActive = coInvoiceItemRec.isActive__c;
                    this.Total = (coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c != null) ? coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                    if(coInvoiceItemRec.SO_Payment_Role__r.Service_Order_Header__r.Work_Status__c == Constants.SERVICE_ORDER_STATUS_TO_CHECKOUT && coInvoiceItemRec.SO_Payment_Role__r.Claim__r.Claim_Disposition__c != 'Denied') {
                        this.IsInvoiceable = coInvoiceItemRec.Is_Invoiceable__c;
                    } else {
                        this.IsInvoiceable = false;
                    }
                    this.CheckoutType = Constants.CHECKOUT_TYPE_INTERNAL;
                }
            }
            
            if(coInvoiceItemRec.SO_Payment_Role__r.RecordType.DeveloperName == 'Customer') {
                if(coInvoiceItemRec.Service_Order_Header__r != null) {
                    this.Item = coInvoiceItemRec.Service_Order_Header__r.Name__c + ' - CLAIM VARIANCE -  [item/desc from the claim]';
                    this.isActive = coInvoiceItemRec.isActive__c;
                    this.Qty = coInvoiceItemRec.SO_Payment_Role__r.Qty__c;
                    this.Total = (coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c != null) ? coInvoiceItemRec.SO_Payment_Role__r.Total_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
                    if(coInvoiceItemRec.SO_Payment_Role__r.Service_Order_Header__r.Work_Status__c == Constants.SERVICE_ORDER_STATUS_TO_CHECKOUT && coInvoiceItemRec.SO_Payment_Role__r.Claim__r.Claim_Disposition__c != 'Denied') {
                        this.IsInvoiceable = coInvoiceItemRec.Is_Invoiceable__c;
                    } else {
                        this.IsInvoiceable = false;
                    }
                    this.CheckoutType = Constants.CHECKOUT_TYPE_CUSTOMER;
                }
            }
            if(this.IsInvoiceable && this.isActive) {
                this.IsFinalizable = true;
            } else {
                this.IsFinalizable = false;
            }
            
            this.TaxAmount = (coInvoiceItemRec.SO_Payment_Role__r.Tax_Amount__c == null) ? 0 : coInvoiceItemRec.SO_Payment_Role__r.Tax_Amount__c;
            if(this.isTaxIncludingPricing) {
                if(this.Total == null) {
                    this.Total = 0;
                }
                this.Total = this.Total + this.TaxAmount; 
            }
            this.ItemType = Constants.CLAIM_SERVICE_ORDER_INVOICE_ITEM_TYPE;
        }
        
       public void populateSOThirdParty(CO_Invoice_Item__c  coInvoiceItemRec) {
            this.Item = coInvoiceItemRec.Service_Order_Header__r.Name__c + ' - CLAIM - ' + ((coInvoiceItemRec.Service_Order_Header__r.Claim_Status__c !=null) ? coInvoiceItemRec.Service_Order_Header__r.Claim_Status__c : 'Unsubmitted ') + ((coInvoiceItemRec.Service_Order_Header__r.Provider__r.Name !=null ) ? ' - ' + coInvoiceItemRec.Service_Order_Header__r.Provider__r.Name : '');
            this.isActive = false;
            this.TaxAmount = (coInvoiceItemRec.Service_Order_Header__r.Tax_Amount__c != null) ? coInvoiceItemRec.Service_Order_Header__r.Tax_Amount__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            this.Total = (coInvoiceItemRec.Service_Order_Header__r.Total__c != null) ? coInvoiceItemRec.Service_Order_Header__r.Total__c : 0;       
            if(isTaxIncludingPricing) {     
                if(this.Total == null) {        
                    this.Total = 0;     
                }       
                if(this.TaxAmount == null) {        
                    this.TaxAmount = 0;     
                }       
                this.Total = this.Total + this.TaxAmount;       
            }
            this.Price = this.Total;        
            this.IsInvoiceable = false;
            this.CheckoutType = Constants.CHECKOUT_TYPE_THIRD_PARTY;
            this.ItemType = Constants.CLAIM_SERVICE_ORDER_INVOICE_ITEM_TYPE;
        }
         
        /**
         * Name: parse
         * Desc: Method to Parse JSON String to class instance
         * @param:  (1) JSONString - String - JSON String 
         * @return: COLineItem - Class Object
        **/
        public COInvoiceItem parse(String json) {
            return (COInvoiceItem) System.JSON.deserialize(json, COInvoiceItem.class);
        }
    }
    // End: AccountingCOInvoiceItem Wraaper
        
    public class CustomerWrapper{
        public String AccountingId;
        public String Name;
        
        public CustomerWrapper(String AccountingId, String Name) {
            this.AccountingId = AccountingId;
            this.Name = Name;
        }
    }
    
    public class SalesTaxWrapper {
        public String AccountingId;
        public String Name;
        
        public SalesTaxWrapper(String AccountingId, String Name) {
            this.AccountingId = AccountingId;
            this.Name = Name;
        }
    }
    
    public class TaxDetail {
        public String Id;
        public String Name;
        public Decimal TaxAmount;
        public Decimal TaxableAmount;
        public String AccountingId;
        public String CategoryName;
        
        public TaxDetail(String id, String name, Decimal taxAmount, Decimal taxableAmount, String accountingId, String categoryName) {
            this.Id = id;
            this.Name = name;
            this.TaxAmount = (taxAmount != null) ? taxAmount : 0;
            this.TaxableAmount = taxableAmount;
            this.AccountingId = accountingId;
            this.CategoryName = categoryName;
        }
    }
    
    private static Map<String, Decimal> getTaxableAmountMap(List<Individual_Tax__c> individualTaxList){
        Map<String, Decimal> taxItemToTaxAmountMap = new Map<String, Decimal>();
        for(Individual_Tax__c taxItem : individualTaxList){
            if(!taxItemToTaxAmountMap.containsKey(taxItem.Sales_Tax_Item_Name__c)){
                taxItemToTaxAmountMap.put(taxItem.Sales_Tax_Item_Name__c, 0);
            }
            taxItemToTaxAmountMap.put(taxItem.Sales_Tax_Item_Name__c, taxItemToTaxAmountMap.get(taxItem.Sales_Tax_Item_Name__c) + (taxItem.Deal_Item__c != null ? (taxItem.Deal_Item__r.Pre_Tax_Agreed_Value__c*-1) : taxItem.Taxable_Amount__c));
        }
        return taxItemToTaxAmountMap;
    }
 }