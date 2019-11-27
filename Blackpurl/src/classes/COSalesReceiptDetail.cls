/**
 * Author: Pooja Khandelwal
 * Since: Jun 18, 2018
 * Name: COSalesReceiptDetail
 * Description: Wrapper Class for CO Sales Receipt Detail
**/
public class COSalesReceiptDetail {
	public String Clerk {get; private set;}
	public Boolean IsTaxIncludingPricing {get; set;}
	public CustomerDetail.Company CompanyInfo {get; set;}
	public Boolean IsSignatureLineforSalesReceipt {get; set;}
	public String SalesReceiptWarrantyText {get; set;} 
	public CustomerDetail CustomerInfo {get; set;}
	public ReceiptTotalsDetail ReceiptTotals {get; set;}
	public List<TransactionDetail> Transactions {get; set;}
	public COInvoiceDetail COInvoice {get; set;}
	public List<COInvoiceItemDetail> COInvoiceItemList {get; private set;}
	
    public COSalesReceiptDetail(List<Business_Profile__c> businessProfileList, CO_Invoice_Header__c coInvoiceHeader, 
    								Map<String, Decimal> salesTaxNameToTaxValue, List<COHeaderWrapper.COKitHeader> COKHItemList,
    								List<CO_Line_Item__c> coliList, List<CO_Kit_Header__c> coKitHeadersList, 
    								List<Deal_Item__c>  dealItemList, Map<Id, List<Deal_Kit_Header__c>> dealItemIdToDKHListMap, List<Service_Order_Header__c> soHeadersList,
    								List<F_I_Product__c> dealFAndIProductList) {
    	this.Clerk = UserInfo.getName();
    	this.IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
    	if(businessProfileList.size() > 0) {
            this.CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
            this.IsSignatureLineforSalesReceipt = businessProfileList[0].Is_Signature_Line_for_Sales_Receipt__c;
            this.SalesReceiptWarrantyText = (businessProfileList[0].Sales_Receipt_Warranty_Text__c != null) ? businessProfileList[0].Sales_Receipt_Warranty_Text__c : '';
        } else {
            this.CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
        }
        this.CompanyInfo.BusinessPhone = this.CompanyInfo.FormattedBusinessPhone != null ? this.CompanyInfo.FormattedBusinessPhone: '';
        this.CompanyInfo.BusinessPhone = PrintCustomerOrderInvoiceCtrl.formatphonenumber(this.CompanyInfo.BusinessPhone);//Check
        this.CustomerInfo = new CustomerDetail(coInvoiceHeader);
        this.ReceiptTotals = new ReceiptTotalsDetail(coInvoiceHeader, salesTaxNameToTaxValue);
        this.Transactions = new List<TransactionDetail>();
        
        for(CO_Invoice_Payment__c coPaymentRec : coInvoiceHeader.CO_Invoice_Payments__r) {
        	if(coPaymentRec.Payment_Method__c != 'Cash Rounding') {
        		this.Transactions.add(new TransactionDetail(coPaymentRec));
        	}
        }
        
        this.COInvoice = new COInvoiceDetail(coInvoiceHeader);
        this.COInvoiceItemList = new List<COInvoiceItemDetail>();
        
        List<COHeaderWrapper.COKitHeader> cokhList = new List<COHeaderWrapper.COKitHeader>(); //Merchandise
        List<COHeaderWrapper.COKitHeader> dealCOKHList = new List<COHeaderWrapper.COKitHeader>(); //DealMerchandise
        for(COHeaderWrapper.COKitHeader kitHeader : COKHItemList){
        	if((String.isNotBlank(kitHeader.id) && String.isNotBlank(kitHeader.DealId)) || (String.isBlank(kitHeader.id) && kitHeader.COLIList.size() > 0 && String.isNotBlank(kitHeader.COLIList[0].DealId))) {
    			dealCOKHList.add(kitHeader);
    		} else {
    			cokhList.add(kitHeader);
    		}
        }
        
        List<ServiceDetail> services = new List<ServiceDetail>(); //Service Job Or Deal Service
        List<Decimal> claimDeductibleLines = new List<Decimal>(); //Service Job Claim Deductible Total
        DealDetails dealInfo = new DealDetails(dealItemList, dealFAndIProductList, dealItemIdToDKHListMap); // Deal Details
        for(Service_Order_Header__c soHeader : soHeadersList) {
            ServiceDetail soRec = new ServiceDetail(coInvoiceHeader.CO_Invoice_Items__r, soHeader);
            services.add(soRec);
            
            if(soRec.isDeductibleInvItem) {
            	claimDeductibleLines.add(soRec.DeductibleAmount);
            }
            
        }
        
        String itemDescription = '';
        Decimal qty = 0;
        Decimal totalPrice = 0;
        if(cokhList.size() > 0) { //Merchandise LIs
        	for(COHeaderWrapper.COKitHeader cokhRec: cokhList) {
        		for(COLineItem coliRec : cokhRec.COLIList) {
        			itemDescription = coliRec.ItemDescription;
        			qty = (cokhRec.Id == null && coliRec.IsPart && !coliRec.NonInventoryPart && coliRec.Qty > 0) ? coliRec.QtyCommitted : coliRec.Qty;
        			totalPrice = (coliRec.SubTotal == null) ? (qty * coliRec.Price) : coliRec.SubTotal;
        			COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
        		}
        	}
        }
        
        
        if(dealCOKHList.size() > 0) { //DealMerchandise LIs
        	for(COHeaderWrapper.COKitHeader dealCokhRec : dealCOKHList) {
        		for(COLineItem dealColiRec: dealCokhRec.COLIList) {
        			itemDescription = dealColiRec.ItemDescription;
        			qty = (dealCokhRec.Id == null && dealColiRec.IsPart && !dealColiRec.NonInventoryPart && dealColiRec.Qty > 0) ? dealColiRec.QtyCommitted : dealColiRec.Qty;
        			totalPrice = (dealColiRec.SubTotal == null) ? (qty * dealColiRec.Price) : dealColiRec.SubTotal;
        			COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
        		}
        	}
        }
        
        if(services.size() > 0) { //Service Job LIs
        	for(ServiceDetail serviceRec : services) {
    			for(SoliDetail soliRec : serviceRec.SOLineItems) {
					itemDescription = soliRec.ItemDesc;
        			qty = soliRec.Qty;
        			totalPrice = soliRec.TotalPrice;
        			COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
    			}
    			//ShopSupplyTotal LIs from Individual Service Jobs
    			if(serviceRec.TotalShopSupplies != null && serviceRec.TotalShopSupplies > 0) {
    				COInvoiceItemList.add(new COInvoiceItemDetail('Shop Supplies', 1, serviceRec.TotalShopSupplies));
    			}
        	}
        }
        
        if(claimDeductibleLines.size() > 0) { //ClaimDeductible LIs from Individual Service Jobs 
        	for(Decimal ClaimDeductibleAmount : claimDeductibleLines) {
        		itemDescription = 'Claim Deductible';
				qty = null;
				totalPrice = ClaimDeductibleAmount;
				COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
        	}
        }

        if(dealInfo.UnitList.size() > 0) { // Line Item From Each Unit on Deal 
        	for(DealUnitDetails dealUnit : dealInfo.UnitList) {
        		itemDescription = dealUnit.Vin;
        		qty = dealUnit.Qty;
        		totalPrice = dealUnit.DealUnitPriceAndCostTotal;
				COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
				
				// Line Item From Each Option & Fee from Unit of Deal 
				for(DealWrapper.DealKitHeader dkhRec : dealUnit.DealKitHeaderList) {
					for(DealWrapper.OptionAndFeeInfo ofRec : dkhRec.OptionAndFeeList) {
						itemDescription = ofRec.ItemDescription; 
		        		qty = (ofRec.Qty != null) ? ofRec.Qty : 0;
		        		totalPrice = ofRec.Total;
						COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
					}
	        	}
        	}
        }
        
        if(dealInfo.TradeInList.size() > 0) { // Line Item From Each Trade In OnDeal 
        	for(DealTradeInDetails dealTradeIn : dealInfo.TradeInList) {
        		itemDescription = dealTradeIn.Vin;
        		qty = dealTradeIn.Qty;
        		totalPrice = dealTradeIn.AgreedValue;
				COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
        	}
        }
        
        if(dealInfo.dealFIProductList.size() > 0) { // Line Item From Each Deal FI Product Item
        	for(DealFIProductDetails dealFIProductRec: dealInfo.dealFIProductList) {
        		itemDescription = dealFIProductRec.ItemDesc;
        		qty = dealFIProductRec.Qty;
        		totalPrice = dealFIProductRec.Price;
				COInvoiceItemList.add(new COInvoiceItemDetail(itemDescription, qty, totalPrice));
        	}
        }
    }
    
    /**
     * Name: CustomerDetail
     * Description: Wrapper class
     * 
    **/
    public class CustomerDetail {
    	public String CustomerName {get; private set;}
    	public String CustomerAddress1 {get; private set;}
        public String CustomerAddress2 {get; private set;}
        public String CustomerCity {get; private set;}
        public String CustomerState {get; private set;}
        public String CustomerPostal {get; private set;}
    	public CustomerDetail(CO_Invoice_Header__c coInvoiceHeader){
            this.CustomerName = (coInvoiceHeader.CO_Header__r.CO_Type__c == 'Cash Sale') ? 'Cash Sale' : ((coInvoiceHeader.CO_Header__r.CO_Type__c == 'Internal Service') ? 'Unit Inventory' : coInvoiceHeader.CO_Header__r.Customer__r.Name);
			String billingStreet = (coInvoiceHeader.CO_Header__r.Customer__r.BillingStreet == null ) ? '' : coInvoiceHeader.CO_Header__r.Customer__r.BillingStreet;
            List<String> bsList = billingStreet.split('\n');
            this.CustomerAddress1 = (bsList.size() > 0) ? bsList[0] : '';
            this.CustomerAddress2 = (bsList.size() > 1) ? bsList[1] : '';
            this.CustomerCity = coInvoiceHeader.CO_Header__r.Customer__r.BillingCity;
            this.CustomerState = coInvoiceHeader.CO_Header__r.Customer__r.BillingState;
            this.CustomerPostal = coInvoiceHeader.CO_Header__r.Customer__r.BillingPostalCode;
        }
    }
    
    /**
     * Name: ReceiptTotalsDetail
     * Description: Wrapper class
     * 
    **/
    public class ReceiptTotalsDetail {
    	public Decimal SubTotal {get; set;}
        public List<TaxDetail> SalesTaxList {get; private set;}
        public Decimal Total {get; set;}
        public Decimal TotalLienPayout {get; set;}
    	public ReceiptTotalsDetail(CO_Invoice_Header__c coInvoiceHeader, Map<String, Decimal> salesTaxNameToTaxValue){
            this.SubTotal = 0;
            Decimal TotalUnits = coInvoiceHeader.Unit_Total__c != null ? coInvoiceHeader.Unit_Total__c : 0;
            Decimal TotalParts = coInvoiceHeader.Part_Total__c != null ? coInvoiceHeader.Part_Total__c : 0;
            Decimal TotalLabour = coInvoiceHeader.Labour_Total__c != null ? coInvoiceHeader.Labour_Total__c : 0;
            Decimal TotalSublet = coInvoiceHeader.Sublet_Total__c != null ? coInvoiceHeader.Sublet_Total__c : 0;
            Decimal TotalFees = coInvoiceHeader.Fee_Total__c != null ? coInvoiceHeader.Fee_Total__c : 0;
            this.TotalLienPayout = coInvoiceHeader.Lien_Payout_Total__c != null ? coInvoiceHeader.Lien_Payout_Total__c : 0;
            Decimal TotalWarranty = coInvoiceHeader.Warranty_Product_Total__c != null ? coInvoiceHeader.Warranty_Product_Total__c : 0;
            Decimal TotalOtherProducts = coInvoiceHeader.Other_Product_Total__c != null ? coInvoiceHeader.Other_Product_Total__c : 0;
            Decimal StampDuty = coInvoiceHeader.Stamp_Duty_Total__c != null ? coInvoiceHeader.Stamp_Duty_Total__c : 0;
            Decimal TotalShopSupplies = coInvoiceHeader.Shop_Supplies_Total__c != null ? coInvoiceHeader.Shop_Supplies_Total__c : 0;
	        Decimal TotalDeductible = coInvoiceHeader.Deductible_Total__c != null ? coInvoiceHeader.Deductible_Total__c : 0;
	        if(coInvoiceHeader.Checkout_Type__c != 'Customer') {
            	TotalDeductible = 0;
            }
	        Decimal TotalFinanceProducts = coInvoiceHeader.F_I_Total__c != null ? coInvoiceHeader.F_I_Total__c : 0;
        
            this.SubTotal = TotalUnits + TotalParts + TotalLabour + TotalSublet + TotalFees + this.TotalLienPayout
            					+ TotalWarranty + TotalOtherProducts + StampDuty + TotalShopSupplies 
            					+ TotalDeductible + TotalFinanceProducts;
            
            this.SalesTaxList = new List<TaxDetail>();					
         	for(String taxName : salesTaxNameToTaxValue.keySet()) {
         		SalesTaxList.add(new TaxDetail(taxName, salesTaxNameToTaxValue.get(taxName)));
            } 
            
            this.Total = coInvoiceHeader.Total__c != null ? coInvoiceHeader.Total__c : 0;
            if(coInvoiceHeader.Checkout_Type__c != 'Customer') {
            	this.Total += (TotalDeductible * -1);
            }
        }
    }
    
    /**
     * Name: TaxDetail
     * Description: Wrapper class
     * 
    **/
    public class TaxDetail {
    	public String TaxName {get; private set;}
      	public Decimal TaxAmount {get; private set;}
        
        public TaxDetail(String taxName, Decimal taxAmount){
            if(taxAmount == null){
                taxAmount = 0;
            }
            this.TaxName = taxName;
            this.TaxAmount = taxAmount;
        }
    }
    
    /**
     * Name: TransactionDetail
     * Description: Wrapper class
     * 
    **/
    public class TransactionDetail {
        public boolean IsDeposit {get; private set;}
        public boolean IsPayment {get; private set;}
        public String Method {get; private set;}
        public String TransactionDate {get; private set;}
        public decimal Amount {get; private set;}
        
        public TransactionDetail(CO_Deposit__c coDepositRec) {
            IsDeposit   = true;
            IsPayment   = false;
            Method      = coDepositRec.Payment_Method__c;
            Amount      = coDepositRec.Amount__c;
            TransactionDate = BPUtility.getFormatedDateTime(coDepositRec.LastModifiedDate);
        }
        
        public TransactionDetail(CO_Invoice_Payment__c coPaymentRec) {
            IsPayment   = true;
            IsDeposit   = false;
            Method      = coPaymentRec.Payment_Method__c;
            Amount      = coPaymentRec.Amount__c;
            TransactionDate = BPUtility.getFormatedDateTime(coPaymentRec.LastModifiedDate);
        }
    }
    
    /**
     * Name: COInvoiceDetail
     * Description: Wrapper class
     * 
    **/
    public class COInvoiceDetail {
    	public String InvoiceDate {get; private set;}
    	public String InvoiceTime {get; private set;}
    	public String InvoiceNumber {get; private set;}
        
    	public COInvoiceDetail(CO_Invoice_Header__c coInvoiceHeader) {
    		if(coInvoiceHeader.Invoice_Date__c != null) {
    			this.InvoiceDate = BPUtility.getFormatedDateTime(coInvoiceHeader.Invoice_Date__c);
    			this.InvoiceTime = coInvoiceHeader.Invoice_Date__c.format('h:mma');
    		}
    		this.InvoiceNumber = (coInvoiceHeader.Invoice_Number__c == null) ? '' : coInvoiceHeader.Invoice_Number__c;
    	}
    }
    
    /**
     * Name: COInvoiceItemDetail
     * Description: Wrapper class
     * 
    **/
    public class COInvoiceItemDetail {
    	public String ItemDesc {get; private set;}
    	public Decimal Qty {get; private set;}
    	public Decimal Price {get; private set;}
        
    	public COInvoiceItemDetail(String ItemDesc, Decimal Qty, Decimal Price) {
    		this.ItemDesc = ItemDesc;
    		this.Qty = Qty;
    		this.Price = Price;
    	}
    }
    
    /**
     * Name: ServiceDetail
     * Description: Wrapper class
     * 
    **/
    public class ServiceDetail {
    	public Boolean isDeductibleInvItem {get; private set;}
    	public Decimal DeductibleAmount {get; private set;}
    	public Decimal TotalShopSupplies {get; private set;}
    	public List<SoliDetail> SOLineItems {get; private set;}
    	
    	public ServiceDetail(List<CO_Invoice_Item__c> coInvoiceItems, Service_Order_Header__c soHeader) {
    		this.isDeductibleInvItem = false;
    		this.DeductibleAmount = 0;
    		this.TotalShopSupplies = soHeader.Total_Shop_Supplies__c;
    		this.SOLineItems = new List<SoliDetail>();
            for(CO_Invoice_Item__c coInvoiceItem : coInvoiceItems) {
                if(coInvoiceItem.Service_Order_Header__c == soHeader.Id) {
                    if(coInvoiceItem.SO_Payment_Role__r != null && coInvoiceItem.SO_Payment_Role__r.RecordType.DeveloperName == 'Deductible') {
                        this.isDeductibleInvItem = true;
                        this.DeductibleAmount = coInvoiceItem.SO_Payment_Role__r.Total_Amount__c;
                        break;
                    }
                }
            }
            if(!this.isDeductibleInvItem) {
            	for(Service_Order_Line_Item__c soliRec: soHeader.Service_Order_Line_Items__r) {
            		if(soliRec.Type__c != 'Shop Supply') {
            			this.SOLineItems.add(new SoliDetail(soliRec));
            		}
            	}
            }
    	}
    }
    
    /**
     * Name: SoliDetail
     * Description: Wrapper class
     * 
    **/
    public class SoliDetail {
    	public String ItemDesc {get; private set;}
    	public Decimal Qty {get; private set;}
    	public Decimal TotalPrice {get; private set;}
    	
    	public SoliDetail(Service_Order_Line_Item__c soliRec) {
    		this.ItemDesc = (soliRec.Item_Description__c != null) ? soliRec.Item_Description__c : '';
    		this.Qty = (soliRec.Qty_Needed__c != null ) ? soliRec.Qty_Needed__c : 0;
    		Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
    		Decimal tax = (soliRec.Tax_Percent__c != null) ? soliRec.Tax_Percent__c : 0;
    		Decimal kitprice = 0;
    		if(isTaxIncludingPricing && String.isBlank(soliRec.Deal__c)) {
                kitprice = (soliRec.Price_When_Tax_Included__c != null) ? soliRec.Price_When_Tax_Included__c : (soliRec.Kit_Price__c * (1 + (tax / 100))).setScale(2, RoundingMode.HALF_UP);
            } else {
                kitprice = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c.setScale(2, RoundingMode.HALF_UP) : 0;
            }
    		this.TotalPrice = (Qty * kitprice).setScale(2, RoundingMode.HALF_UP);
    	}
    }
    
    
    /**
     * Name: DealDetails
     * Description: Wrapper class
     * 
    **/
    public class DealDetails {
    	public List<DealUnitDetails> UnitList {get; private set;}
        public List<DealTradeInDetails> TradeInList {get; private set;}
        public List<DealFIProductDetails> dealFIProductList {get; set;}
        
        public DealDetails(List<Deal_Item__c> dealItemList, List<F_I_Product__c> dealFAndIProductList, Map<Id, List<Deal_Kit_Header__c>> dealItemIdToDKHListMap) {
        	this.UnitList = new List<DealUnitDetails>();
        	this.TradeInList = new List<DealTradeInDetails>();
        	this.dealFIProductList = new List<DealFIProductDetails>();
        	for(Deal_Item__c dealItemRec : dealItemList) {
                if(String.isNotBlank(dealItemRec.Type__c) && dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT) {
                    this.UnitList.add(new DealUnitDetails(dealItemRec, (dealItemIdToDKHListMap.containsKey(dealItemRec.Id) ? dealItemIdToDKHListMap.get(dealItemRec.Id) : new List<Deal_Kit_Header__c>())));
                } else if(String.isNotBlank(dealItemRec.Type__c) && dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
                    this.TradeInList.add(new DealTradeInDetails(dealItemRec));
                }
            }
            
            for(F_I_Product__c dealFIProductRec : dealFAndIProductList) {
        		this.dealFIProductList.add(new DealFIProductDetails(dealFIProductRec));
            }
            
        } 
    }
    
    /**
     * Name: DealUnitDetails
     * Description: Wrapper class
     * 
    **/
    public class DealUnitDetails {
    	public String Vin {get; private set;}
	    public Decimal Qty {get; private set;}
	    public Decimal DealUnitPriceAndCostTotal {get; private set;}
	    //public List<OptionAndFeeDetail> OptionAndFeeList {get; private set;}
	    public List<DealWrapper.DealKitHeader> DealKitHeaderList {get; private set;}
	    
	    public DealUnitDetails(Deal_Item__c dealItemRec, List<Deal_Kit_Header__c> dkhList) {
	    	this.Vin = (dealItemRec.Customer_Owned_Unit__r.VIN_Number__c == null) ? 'VIN Unknown ' : dealItemRec.Customer_Owned_Unit__r.VIN_Number__c;
	    	this.Qty = null;
	    	this.DealUnitPriceAndCostTotal = 0;
	    	//this.OptionAndFeeList = new List<OptionAndFeeDetail>();
	    	
	    	List<DealWrapper.FactoryOption> FactoryOptionList = new List<DealWrapper.FactoryOption>();
            List<DealWrapper.DealerInstalledOption> DealerOptionList = new List<DealWrapper.DealerInstalledOption>();
            Decimal BaseUnitPriceTotal = 0;
    		Decimal BaseUnitPriceTax = 0;
    		Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
    
	    	for(Deal_Unit_Price_Cost__c DealUnitpriceCostRec : dealItemRec.Deal_Unit_Prices_Costs__r) {
                DealUnitpriceCostRec.Price__c = (DealUnitpriceCostRec.Price__c == null) ? 0 : DealUnitpriceCostRec.Price__c;
                DealUnitpriceCostRec.Qty__c = (DealUnitpriceCostRec.Qty__c == null) ? 0 : DealUnitpriceCostRec.Qty__c;
                DealUnitpriceCostRec.Sales_Tax_Percentage__c = (DealUnitpriceCostRec.Sales_Tax_Percentage__c == null) ? 0 : DealUnitpriceCostRec.Sales_Tax_Percentage__c;
                    
                if(DealUnitpriceCostRec.Type__c == 'Factory') {
                    DealWrapper.FactoryOption factoryOptionRec = new DealWrapper.FactoryOption(DealUnitpriceCostRec);
                    factoryOptionRec.SalesTax = ((DealUnitpriceCostRec.Sales_Tax_Percentage__c.setScale(2, RoundingMode.HALF_UP)) * DealUnitpriceCostRec.Price__c.setScale(2, RoundingMode.HALF_UP) * (DealUnitpriceCostRec.Qty__c) / 100).setScale(2, RoundingMode.HALF_UP);
                    FactoryOptionList.add(factoryOptionRec);
                } else if(DealUnitpriceCostRec.Type__c == 'Dealer') {
                    DealWrapper.DealerInstalledOption dealerInstalledOptionRec = new DealWrapper.DealerInstalledOption(DealUnitpriceCostRec);
                    dealerInstalledOptionRec.SalesTax = ((DealUnitpriceCostRec.Sales_Tax_Percentage__c.setScale(2, RoundingMode.HALF_UP)) * DealUnitpriceCostRec.Price__c.setScale(2, RoundingMode.HALF_UP) * (DealUnitpriceCostRec.Qty__c) / 100).setScale(2, RoundingMode.HALF_UP);
                    DealerOptionList.add(dealerInstalledOptionRec);
                } else if(DealUnitpriceCostRec.Type__c == 'Base') {
                    Decimal salesTax = ((DealUnitpriceCostRec.Sales_Tax_Percentage__c * DealUnitpriceCostRec.Price__c) / 100).setScale(2, RoundingMode.HALF_UP);
                    BaseUnitPriceTax += salesTax;
                    
                    if(isTaxIncludingPricing) {
	                    BaseUnitPriceTotal += (DealUnitpriceCostRec.Price_When_Tax_Included__c != null) ? (DealUnitpriceCostRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP) : 
	                    	DealUnitpriceCostRec.Price__c + salesTax;
                    } else {
                    	BaseUnitPriceTotal += DealUnitpriceCostRec.Price__c;
            		}
                }
            }
            BaseUnitPriceTotal = BaseUnitPriceTotal.setScale(2, RoundingMode.HALF_UP);
            BaseUnitPriceTax = BaseUnitPriceTax.setScale(2, RoundingMode.HALF_UP);
            
            Decimal unitTotal = BaseUnitPriceTotal;
            for(DealWrapper.FactoryOption factoryRec : FactoryOptionList) {
                unitTotal += factoryRec.TotalPrice;
            }
            for(DealWrapper.DealerInstalledOption dealerRec : DealerOptionList) {
                unitTotal += dealerRec.TotalPrice;
            }
            this.DealUnitPriceAndCostTotal = unitTotal;
            
            /*for(Option_Fee__c optionAndFeeRec : dealItemRec.Options_Fees__r) {
                this.OptionAndFeeList.add(new OptionAndFeeDetail(optionAndFeeRec));
            }*/
            
            this.DealKitHeaderList = new List<DealWrapper.DealKitHeader>();
            this.DealKitHeaderList = PrintCustomerOrderInvoiceCtrl.getDealKitHeaderList(dealItemRec.Options_Fees__r, dkhList);
	    }
    }
    
    /**
     * Name: DealTradeInDetails
     * Description: Wrapper class
     * 
    **/
    public class DealTradeInDetails {
    	public String Vin {get; private set;}
      	public Decimal Qty {get; private set;}
      	public Decimal AgreedValue {get; private set;}
      
      	public DealTradeInDetails(Deal_Item__c dealItemRec) {
	      	this.Vin = (dealItemRec.Customer_Owned_Unit__r.VIN_Number__c == null) ? 'VIN Unknown ' : dealItemRec.Customer_Owned_Unit__r.VIN_Number__c;
	  		this.Qty = null;
	        this.AgreedValue = (dealItemRec.Agreed_Value__c != null) ? -dealItemRec.Agreed_Value__c : 0;
		}
    }
    
    /**
     * Name: OptionAndFeeDetail
     * Description: Wrapper class
     * 
    **/
    public class OptionAndFeeDetail {
    	public String ItemDesc {get; private set;}
      	public Decimal Qty {get; private set;}
      	public Decimal TotalPrice {get; private set;}
      
      	public OptionAndFeeDetail(Option_Fee__c optionAndFeeRec) {
	      	this.ItemDesc = (optionAndFeeRec.Item_Description__c != null) ? optionAndFeeRec.Item_Description__c : '';
	  		this.Qty = (optionAndFeeRec.Qty__c != null) ? optionAndFeeRec.Qty__c : 0;
	  		Decimal Price = (optionAndFeeRec.Price__c != null) ? optionAndFeeRec.Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
	    	Decimal SalesTaxPercentage = optionAndFeeRec.Sales_Tax_Percentage__c != null ? optionAndFeeRec.Sales_Tax_Percentage__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
	    	Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
	    	if(isTaxIncludingPricing) {
            	Price = (optionAndFeeRec.Price_When_Tax_Included__c != null) ? optionAndFeeRec.Price_When_Tax_Included__c.setScale(2, RoundingMode.HALF_UP) :(Price * (1 + SalesTaxPercentage /100)).setScale(2, RoundingMode.HALF_UP);
	    	} 	    	
	    	this.TotalPrice = 0;
	    	if(Price == null) {
	    		Price = 0;
	    	}
    		this.TotalPrice = Price * this.Qty;
	    	this.TotalPrice = this.TotalPrice.setScale(2, RoundingMode.HALF_UP);
		}
    }
    
    /**
     * Name: DealTradeInDetails
     * Description: Wrapper class
     * 
    **/
    public class DealFIProductDetails {
    	public String ItemDesc {get; private set;}
      	public Decimal Qty {get; private set;}
      	public Decimal Price {get; private set;}
      
      	public DealFIProductDetails(F_I_Product__c dealFIProductRec ) {
	      	this.ItemDesc = (dealFIProductRec.Vendor_Product__r.Description__c != null) ? dealFIProductRec.Vendor_Product__r.Description__c : '';
	  		this.Qty = null;
	  		Boolean IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
	        this.Price = dealFIProductRec.Price__c;//IsTaxIncludingPricing ? dealFIProductRec.Price_When_Tax_Included__c : dealFIProductRec.Price__c;
		}
    }
}