global with sharing class DealDocumentPrintCtrl {

    global DealDocumentPrintCtrl (NewHomePageCtrl controller) {
        Application = GlobalController.GetResourceURL('Application');
        Application_Images = GlobalController.GetResourceURL('Application_Images');
        Assests = GlobalController.GetResourceURL('Assests');
    }
    
    public String companyLogoURL { get{return GeneralConfiguration.getCompanyLogoUrl();} private set;}
    public String dateFormat { get{ return BPUtility.getDateFormat();}private set;}
    
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    public String dealId;
    public static String documentType {get; set;}
    public boolean isDisplayTaxInvoice { get{return GeneralConfiguration.isDisplayTaxInvoice();} private set;}
    
    public DealDocumentDetail dealDocumentDetailRecord {get; private set;}
    public String DealDocumentDetailJson {get; private set;}
    
    global DealDocumentPrintCtrl() {
        Application = GlobalController.GetResourceURL('Application');
        Application_Images = GlobalController.GetResourceURL('Application_Images');
        Assests = GlobalController.GetResourceURL('Assests');
        dealId = ApexPages.currentPage().getParameters().get('id');
        documentType = ApexPages.currentPage().getParameters().get('documentType');        
        if(dealId  == '' || dealId == 'undefined' || dealId == null) {
            return;
        } else {
            dealId = BPUtility.getEncodedString(dealId);
            dealDocumentDetailJson = getDealDocumentDetails(dealId);
            dealDocumentDetailRecord = (DealDocumentDetail)JSON.deserialize(BPUtility.getDecodedString(dealDocumentDetailJson), DealDocumentDetail.class);
        }
    }
    
    /**
     * Name: getDealDocumentDetails
     * Desc: 
     * @param:  (1) dealIdStr
     * @return: String - JSON String
    **/
    @RemoteAction
    global static String getDealDocumentDetails(String dealIdStr) {
        String dealDetails;
        dealIdStr = BPUtility.getDecodedString(dealIdStr);
        Id dealId = dealIdStr;
        
        List<Deal__c> dealList = getDealHeaderList(new List<Id>{dealId});
        if(dealList.size() > 0) {
            Deal__c deal = dealList[0];
            Id coInvoiceHeaderId = deal.Invoice_Number__c;
            
            List<Deal_Item__c> dealItemList = getDealHeaders(new List<Id>{dealId});
            List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
            
            List<Individual_Tax__c> individualItemsList = [SELECT CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, 
                                                                Taxable_Amount__c, Tax_Amount__c,
                                                                Applicable_Tax__c, List_Tax_items_on_forms__c
                                                                FROM Individual_Tax__c WHERE Option_Fee__r.Deal__c =: deal.Id
                                                                    OR Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c =: deal.Id
                                                                    OR F_I_Product__r.Deal_Finance__r.Deal__c =: deal.Id
                                                                    OR (Deal_Item__r.Deal__c =: deal.Id AND Deal_Item__r.Type__c = 'Trade In')];
                                                                    
            List<CO_Invoice_Payment__c> coInvoicePaymentList = [SELECT Name, LastModifiedDate, Payment_Method__c, Amount__c FROM CO_Invoice_Payment__c WHERE CO_Invoice_Header__c =: coInvoiceHeaderId];
                        
            List<Deal_Finance__c> dealFinanceList = SOQLUtil.getDealFinanceRecord(new Map<String, String>{'Deal__c' => deal.Id});
            
            DealDocumentDetail dealDocumentObj = new DealDocumentDetail(businessProfileList, deal, dealItemList, individualItemsList, coInvoicePaymentList, dealFinanceList);
            dealDetails = System.JSON.serialize(dealDocumentObj,true);
        }
        
        return BPUtility.getEncodedString(dealDetails);
    }
    
     /**
     * Name: DealDocumentDetail
     * Description: Wrapper class
     * 
    **/
    public class DealDocumentDetail {
        public CustomerDetail.Company CompanyInfo {get; set;}
        public DealHeaderWrapper DealInfo {get; set;}
        public Boolean IsTaxIncludingPricing {get; set;}
        public DealWrapper.DealFinanceWrapper DealFinanceObj {get; set;}
        public String DealDocumentWarrantyText{get; set;}
        public Boolean IsSignatureLineforDealDocument{get; set;}
        public List<TransactionDetail> Transactions {get; set;}
        public List<TaxDetail> SalesTaxList {get; set;}
        public DealDetailWrapper DealDetailWrapperObj {get; set;}
        public Decimal DueFromCustomer {get; set;}
        public Decimal DueFromFinance {get; set;}
        public Decimal AmountFinanced {get; set;}
        public Decimal SubTotal {get; set;}
        public Decimal AmountPaid {get; set;}
        public Decimal BalanceDue {get; set;}
        public Decimal Total {get; set;}
        
        public DealDocumentDetail(List<Business_Profile__c> businessProfileList, Deal__c dealsInfo, List<Deal_Item__c> dealItems, List<Individual_Tax__c> individualItemsList, List<CO_Invoice_Payment__c> coInvoicePaymentList, List<Deal_Finance__c> dealFinanceList) {
            
            if(businessProfileList.size() > 0) {
                this.CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
                this.DealDocumentWarrantyText = (businessProfileList[0].Deal_Documents_Warranty_Text__c != null) ? businessProfileList[0].Deal_Documents_Warranty_Text__c : '';
                this.IsSignatureLineforDealDocument = businessProfileList[0].Is_Signature_Line_for_Deal_Documents__c;
            } else {
                this.CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
            }
            
            this.IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            this.CompanyInfo.BusinessPhone = this.CompanyInfo.FormattedBusinessPhone != null ? this.CompanyInfo.FormattedBusinessPhone: '';
            this.DealInfo = new DealHeaderWrapper(dealsInfo);
            DealDetailWrapperObj = new DealDetailWrapper(dealItems);
            
            Map<String, Decimal> salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);
            Decimal SalesTaxTotal = 0;
            this.SalesTaxList = new List<TaxDetail>();
            for(String taxName : salesTaxNameToTaxValue.keySet()){
                this.SalesTaxList.add(new TaxDetail(taxName, salesTaxNameToTaxValue.get(taxName)));
                SalesTaxTotal += salesTaxNameToTaxValue.get(taxName);
            }
            
            this.Transactions = new List<TransactionDetail>();
            
            this.AmountPaid = 0;
            Decimal amountPaidByFinance = 0;
            Decimal amountPaidByCustomer = 0;
            if(String.isNotBlank(documentType) && documentType == 'Bill of sale'){
                for(CO_Invoice_Payment__c coPaymentRec : coInvoicePaymentList) {
                    this.Transactions.add(new TransactionDetail(coPaymentRec));
                    if(coPaymentRec.Payment_Method__c != 'Charge Account') {
                    	this.AmountPaid += ((coPaymentRec.Amount__c != null) ? coPaymentRec.Amount__c : 0);
                    }
                }
            	if(this.DealInfo.Status != 'Invoiced') {
            		for(CO_Deposit__c coDepositRec : dealsInfo.CO_Deposits__r){
		            	if(coDepositRec.Payment_Method__c != 'Invoice') {
		                	if(coDepositRec.Payment_Method__c == 'Financed') {
		                		amountPaidByFinance += coDepositRec.Amount__c;
		                	} else {
		                		amountPaidByCustomer += coDepositRec.Amount__c;
		                	}
		                	
		            		this.Transactions.add(new TransactionDetail(coDepositRec));
		            		this.AmountPaid += ((coDepositRec.Amount__c != null) ? coDepositRec.Amount__c : 0);
		            	}
		            }
            	}
            } else {
                for(CO_Deposit__c coDepositRec : dealsInfo.CO_Deposits__r){
                    if(coDepositRec.Payment_Method__c != 'Invoice') {
                        if(coDepositRec.Payment_Method__c == 'Financed') {
                            amountPaidByFinance += coDepositRec.Amount__c;
                        } else {
                            amountPaidByCustomer += coDepositRec.Amount__c;
                        }
                        
                        this.Transactions.add(new TransactionDetail(coDepositRec));
                        this.AmountPaid += ((coDepositRec.Amount__c != null) ? coDepositRec.Amount__c : 0);
                    }
                }
            } 
            this.SubTotal = DealDetailWrapperObj.TotalUnits + DealDetailWrapperObj.TotalInstalledOption 
                            + DealDetailWrapperObj.TotalMerchandiseOption + DealDetailWrapperObj.TotalOtherProductsAndFee 
                            + DealDetailWrapperObj.TotalTradeIn + DealDetailWrapperObj.TotalStampDuty + DealDetailWrapperObj.TotalLienPayout;
           if(dealFinanceList.size() > 0) {
                this.DealFinanceObj = new DealWrapper.DealFinanceWrapper(dealFinanceList[0]);
                this.SubTotal += (this.DealFinanceObj !=null && this.DealFinanceObj.FIProductTotal != null) ? this.DealFinanceObj.FIProductTotal : 0;
                if(this.IsTaxIncludingPricing) {
                    this.SubTotal += (this.DealFinanceObj !=null && this.DealFinanceObj.FIProductTax != null) ? this.DealFinanceObj.FIProductTax : 0;
                }             
            }
           
           this.BalanceDue = 0;
           this.Total = 0;
           this.Total = this.SubTotal;
           
           if(!this.IsTaxIncludingPricing) { 
                this.Total += SalesTaxTotal;
           }
           this.BalanceDue = this.Total - this.AmountPaid;
           
           if(this.DealFinanceObj != null) {
                this.DealFinanceObj.DownPayment = (this.DealFinanceObj.DownPayment != null) ? this.DealFinanceObj.DownPayment : 0;
                this.AmountFinanced = this.Total - this.DealFinanceObj.DownPayment;
                if(documentType == 'Bill of sale') {
                    this.DueFromCustomer = 0;
                    this.DueFromFinance = 0;
                } else {
                    this.DueFromCustomer = this.DealFinanceObj.DownPayment - amountPaidByCustomer;
                    this.DueFromFinance = this.AmountFinanced - amountPaidByFinance;
                }
           }
        }
    }       
    
    public class DealHeaderWrapper {
        public String COType {get; private set;}
        public String DealType {get; private set;}
        public String CustomerName {get; private set;}
        public String CustomerAddress {get; private set;}
        public String CustomerAddress2 {get; private set;}
        public String CustomerCityProv {get; private set;}
        public String CustomerPostal {get; private set;}
        public String CustomerState {get; private set;}
        public String CustomerEmail {get; private set;}
        public String CustomerPhone {get; private set;}
        public String Status {get; private set;}
        public String SoldBy {get; private set;}
        public String InvoiceNumber {get; private set;}
        public String InvoiceDate {get; private set;}
        public String InvoiceStatus {get; private set;}
        public String OrderNumber {get; private set;}
        public String OrderDate {get; private set;}
        
        public String CompanyLocale {get; private set;}
        
        public DealHeaderWrapper(Deal__c dealInfo) {
            if(dealInfo != null) {
                this.COType  = dealInfo.CO_Header__r.CO_Type__c;
                this.DealType = dealInfo.Type__c;
                this.CustomerName = dealInfo.CO_Header__r.Customer__r.Name;
                String billingStreet = (dealInfo.CO_Header__r.Customer__r.BillingStreet == null ) ? '' : dealInfo.CO_Header__r.Customer__r.BillingStreet;
                if(dealInfo.CO_Header__r.Customer__r.Preferred_Email__c == null) {
                  if(dealInfo.CO_Header__r.Customer__r.Email__c != null) {
                      this.CustomerEmail = dealInfo.CO_Header__r.Customer__r.Email__c;
                  } else if(dealInfo.CO_Header__r.Customer__r.Work_Email__c != null) {
                      this.CustomerEmail = dealInfo.CO_Header__r.Customer__r.Work_Email__c;
                  } else if(dealInfo.CO_Header__r.Customer__r.Other_Email__c != null) {
                      this.CustomerEmail = dealInfo.CO_Header__r.Customer__r.Other_Email__c;
                  }
                } else {
                    this.CustomerEmail = dealInfo.CO_Header__r.Customer__r.Preferred_Email__c;
                }
                
                if(dealInfo.CO_Header__r.Customer__r.Preferred_Phone__c == null) {
                    if(dealInfo.CO_Header__r.Customer__r.Home_Number__c != null) {
                        this.CustomerPhone = dealInfo.CO_Header__r.Customer__r.Home_Number__c;
                    } else if(dealInfo.CO_Header__r.Customer__r.Mobile__c != null) {
                        this.CustomerPhone = dealInfo.CO_Header__r.Customer__r.Mobile__c;
                    } else if(dealInfo.CO_Header__r.Customer__r.Work_Number__c != null) {
                        this.CustomerPhone = dealInfo.CO_Header__r.Customer__r.Work_Number__c;
                    }
                } else {
                    this.CustomerPhone = dealInfo.CO_Header__r.Customer__r.Preferred_Phone__c;
                }
                List<String> bsList = billingStreet.split('\n');
                this.CustomerAddress = (bsList.size() > 0) ? bsList[0] : '';
                this.CustomerAddress2 = (bsList.size() > 1) ? bsList[1] : '';
                CustomerCityProv = dealInfo.CO_Header__r.Customer__r.BillingCity;
                this.CustomerCityProv = (CustomerCityProv != null && CustomerCityProv != '') ? (CustomerCityProv ) : '';
                this.CustomerPostal = dealInfo.CO_Header__r.Customer__r.BillingPostalCode;
                this.CustomerState = dealInfo.CO_Header__r.Customer__r.BillingState;
                
                this.Status = dealInfo.Status__c;
                
                this.CompanyLocale = GeneralConfiguration.getCompanyLocale();
                this.OrderNumber = (dealInfo.CO_Header__r.Name == null) ? '' : dealInfo.CO_Header__r.Name;
                this.InvoiceNumber = (dealInfo.Invoice_Number__r.Invoice_Number__c == null) ? '' : dealInfo.Invoice_Number__r.Invoice_Number__c;
                this.InvoiceDate = (dealInfo.Invoice_Number__r.Invoice_Date__c != null) ? BPUtility.getFormatedDateTime(dealInfo.Invoice_Number__r.Invoice_Date__c) : BPUtility.getFormatedDateTime(System.now());
                this.OrderDate = (dealInfo.CO_Header__r.LastModifiedDate__c != null) ? BPUtility.getFormatedDateTime(dealInfo.CO_Header__r.LastModifiedDate__c) : '';
                this.InvoiceStatus = dealInfo.Invoice_Number__r.Status__c;
                this.SoldBy =  (dealInfo.Salesperson__r.Technician_Name__c != null) ? dealInfo.Salesperson__r.Technician_Name__c : UserInfo.getName();
            }
        }

    }
    
    public class DealDetailWrapper {
        public List<DealUnitDetails> UnitList {get; private set;}
        public List<DealTradeInDetails> TradeInList {get; private set;}
        public Decimal TotalUnits {get; private set;}
        public Decimal TotalInstalledOption {get; private set;}
        public Decimal TotalMerchandiseOption {get; private set;}
        public Decimal TotalTradeIn {get; private set;}
        public Decimal TotalLienPayout {get; private set;}
        public Decimal TotalOtherProductsAndFee {get; private set;}
        public Decimal TotalStampDuty {get; private set;}
        
        public DealDetailWrapper(List<Deal_Item__c> dealItemList) {
            this.UnitList = new List<DealUnitDetails>();
            this.TradeInList = new List<DealTradeInDetails>();
            this.TotalUnits = 0;
            this.TotalInstalledOption = 0;
            this.TotalMerchandiseOption = 0;
            this.TotalTradeIn = 0;
            this.TotalLienPayout = 0;
            this.TotalOtherProductsAndFee = 0;
            this.TotalStampDuty = 0;
            
            Set<Id> dealItemIds = new Set<Id>();
            
            for(Deal_Item__c dealItemRec : dealItemList) {
                dealItemIds.add(dealItemRec.Id);
            }
            
            Map<Id, List<Deal_Kit_Header__c>> dealItemIdToDKHListMap = new Map<Id, List<Deal_Kit_Header__c>>();
            List<Deal_Kit_Header__c> dealKitHeaderList = SOQLUtil.getDealKitHeaderDetailsByDealItemId(new Set<Id>(dealItemIds));
            for(Deal_Kit_Header__c dealKitHeaderRec : dealKitHeaderList) {
                if(dealItemIdToDKHListMap.containsKey(dealKitHeaderRec.Deal_Item__c)) {
                    List<Deal_Kit_Header__c> dealKitHeaders = dealItemIdToDKHListMap.get(dealKitHeaderRec.Deal_Item__c);
                    dealKitHeaders.add(dealKitHeaderRec);
                    dealItemIdToDKHListMap.put(dealKitHeaderRec.Deal_Item__c, dealKitHeaders);
                } else {
                    dealItemIdToDKHListMap.put(dealKitHeaderRec.Deal_Item__c, new List<Deal_Kit_Header__c>{dealKitHeaderRec});
                }
            }
            
            for(Deal_Item__c dealItemRec : dealItemList) {
                //if(dealItemRec.Customer_Owned_Unit__c != null) {
                    if(String.isNotBlank(dealItemRec.Type__c) && dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_UNIT) {
                        List<Deal_Kit_Header__c> dealKitHeaders = new List<Deal_Kit_Header__c>();
                        if(dealItemIdToDKHListMap.containsKey(dealItemRec.Id)) {
                            dealKitHeaders = dealItemIdToDKHListMap.get(dealItemRec.Id);
                        }
                        this.UnitList.add(new DealUnitDetails(dealItemRec, dealKitHeaders));
                    } else if(String.isNotBlank(dealItemRec.Type__c) && dealItemRec.Type__c == Constants.DEAL_ITEM_TYPE_TRADE_IN) {
                        this.TradeInList.add(new DealTradeInDetails(dealItemRec));
                    }
                //}
            }            
            for(DealUnitDetails dealUnitRec: UnitList) {
                TotalUnits += dealUnitRec.UnitAndPriceCost;
                TotalInstalledOption += dealUnitRec.InstalledOptionCost;
                TotalMerchandiseOption += dealUnitRec.MerchandiseOptionCost;
                TotalOtherProductsAndFee += dealUnitRec.OtherProductsAndFeeCost;
                TotalStampDuty += dealUnitRec.StampDuty;
            }
            
            for(DealTradeInDetails dealTradeInRec: TradeInList) {
                TotalTradeIn += dealTradeInRec.AgreedValue;
                this.TotalLienPayout += dealTradeInRec.LienPayout;
            }
        }
    }
    
    public class DealTradeInDetails {
        public UnitDescriptionWrapper ItemDesc {get; private set;}
        public Decimal AgreedValue {get; private set;}
        public Decimal LienPayout {get; private set;}
        public Decimal SalesTax {get; private set;}
        
        public DealTradeInDetails(Deal_Item__c dealItemRec) {
            this.AgreedValue = 0;
            this.SalesTax = 0;
            this.ItemDesc = new UnitDescriptionWrapper(dealItemRec);
            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            this.AgreedValue = (dealItemRec.Agreed_Value__c != null) ? -dealItemRec.Agreed_Value__c : 0;
            this.LienPayout = dealItemRec.Lien_Payout__c != null ? dealItemRec.Lien_Payout__c : 0;
            if(dealItemRec.Default_Unit_Sales_Tax_Percentage__c == null) {
                dealItemRec.Default_Unit_Sales_Tax_Percentage__c = 0;
            }
            if(isTaxIncludingPricing) {
                this.SalesTax = this.AgreedValue - (this.AgreedValue / (1 + (dealItemRec.Default_Unit_Sales_Tax_Percentage__c / 100)));
            } else {
                this.SalesTax = ((this.AgreedValue * dealItemRec.Default_Unit_Sales_Tax_Percentage__c)/100).setScale(2, RoundingMode.HALF_UP);
            }
        }
    }
    
    public class DealUnitDetails {
        public List<DealWrapper.DealKitHeader> InstalloptionAndFeeList {get; private set;}
        public List<DealWrapper.DealKitHeader> MerchandiseOptionAndFeeList {get; private set;}
        public List<DealWrapper.DealKitHeader> OtherProductsAndFeeList {get; private set;}
        public List<DealWrapper.DealKitHeader> DealKitHeaderList {get; private set;}
        public List<DealUnitPriceCostWrapper> DealUnitPriceCost {get; private set;}
        public UnitDescriptionWrapper ItemDesc {get; private set;}
        public Decimal UnitAndPriceCost {get; private set;}
        public Decimal InstalledOptionCost {get; private set;}
        public Decimal MerchandiseOptionCost {get; private set;}
        public Decimal OtherProductsAndFeeCost {get; private set;}
        public Decimal StampDuty {get; private set;}
        
        public DealUnitDetails(Deal_Item__c dealItemRec, List<Deal_Kit_Header__c> dealKitHeaderList) {
            this.UnitAndPriceCost = 0;
            this.InstalledOptionCost = 0;
            this.MerchandiseOptionCost = 0;
            this.OtherProductsAndFeeCost = 0;
            this.InstalloptionAndFeeList = new List<DealWrapper.DealKitHeader>();
            this.MerchandiseOptionAndFeeList = new List<DealWrapper.DealKitHeader>();
            this.OtherProductsAndFeeList = new List<DealWrapper.DealKitHeader>();
            this.DealUnitPriceCost = new List<DealUnitPriceCostWrapper>();
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing(); 
 
            this.ItemDesc = new UnitDescriptionWrapper(dealItemRec);
            
            String locale = GeneralConfiguration.getCompanyLocale();
            if((String.isBlank(locale) || locale != 'Australia')) {
                this.StampDuty = 0;                       
            } else {
                this.StampDuty = (dealItemRec.Stamp_Duty_Total__c == null) ? 0 : dealItemRec.Stamp_Duty_Total__c;
            }
            
            // Case 00003637
            for(Deal_Unit_Price_Cost__c dealUnitpriceCostRec : dealItemRec.Deal_Unit_Prices_Costs__r) {
                DealUnitPriceCostWrapper dealUnitWrapperObj = new DealUnitPriceCostWrapper(dealUnitpriceCostRec);
                if(dealUnitpriceCostRec.Type__c == 'Factory' || (dealUnitWrapperObj.TotalPrice != null && dealUnitWrapperObj.TotalPrice != 0)) {
                    this.UnitAndPriceCost += dealUnitWrapperObj.TotalPrice;
                    DealUnitPriceCost.add(dealUnitWrapperObj);
                }
            }
            
            this.DealKitHeaderList = new List<DealWrapper.DealKitHeader>();
            this.DealKitHeaderList = getDealKitHeaderList(dealItemRec.Options_Fees__r, dealKitHeaderList);
            
            for(DealWrapper.DealKitHeader dealKitHeaderRec : this.DealKitHeaderList) {
                if(dealKitHeaderRec.hasChildren && dealKitHeaderRec.Price!= 0) {
                    if(dealKitHeaderRec.IsInstall) {
                        this.InstalledOptionCost += dealKitHeaderRec.Price;
                        InstalloptionAndFeeList.add(dealKitHeaderRec);
                    } else if((!dealKitHeaderRec.IsInstall)) {
                        this.MerchandiseOptionCost += dealKitHeaderRec.Price;
                        MerchandiseOptionAndFeeList.add(dealKitHeaderRec);
                    }
                } else {
                    for(DealWrapper.OptionAndFeeInfo optionAndFeeRec : dealKitHeaderRec.OptionAndFeeList) {
                        if(optionAndFeeRec.Total != 0){
                            if(optionAndFeeRec.IsInstall) {
                                this.InstalledOptionCost += optionAndFeeRec.Total;
                                InstalloptionAndFeeList.add(dealKitHeaderRec);
                            } else if((!optionAndFeeRec.IsInstall) && ((optionAndFeeRec.PartId !='' && optionAndFeeRec.PartId !=null) || (optionAndFeeRec.KitHeaderId !='' && optionAndFeeRec.KitHeaderId != null))) {
                                this.MerchandiseOptionCost += optionAndFeeRec.Total;
                                MerchandiseOptionAndFeeList.add(dealKitHeaderRec);
                            } else {
                                this.OtherProductsAndFeeCost += optionAndFeeRec.Total;
                                OtherProductsAndFeeList.add(dealKitHeaderRec);
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    public class DealUnitPriceCostWrapper {
        public String ItemDescription{get; private set;}
        public Decimal Qty{get; private set;}
        public Decimal Price{get; private set;}
        public Decimal TotalPrice{get; private set;}
        public Decimal SalesTaxPercentage{get; private set;}
        public Decimal SalesTax{get; private set;}
        
        public DealUnitPriceCostWrapper(Deal_Unit_Price_Cost__c dealUnitPrice)   {
            this.ItemDescription = (dealUnitPrice.Item_Description__c != null) ? dealUnitPrice.Item_Description__c : 'Base Unit Price';
            this.Price = ((dealUnitPrice.Price__c != null) ? dealUnitPrice.Price__c : 0).setScale(2, RoundingMode.HALF_UP);
            this.Qty = dealUnitPrice.Qty__c;
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            
            this.SalesTaxPercentage = ((dealUnitPrice.Sales_Tax_Percentage__c != null) ? dealUnitPrice.Sales_Tax_Percentage__c : 0).setScale(2, RoundingMode.HALF_UP);
            this.TotalPrice = ((dealUnitPrice.Total_Price__c != null) ? dealUnitPrice.Total_Price__c : 0).setScale(2, RoundingMode.HALF_UP);
            this.SalesTax = ((this.SalesTaxPercentage * this.Price) / 100).setScale(2, RoundingMode.HALF_UP);
            
            if(isTaxIncludingPricing) {
                this.Price = (dealUnitPrice.Price_When_Tax_Included__c != null) ? (dealUnitPrice.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP) : this.Price + this.SalesTax;
                this.TotalPrice = (this.Price * this.Qty);
                this.SalesTax = 0;
            }  
        }
    }
    
    public class UnitDescriptionWrapper {
        public String Name {get; private set;}
        public String Type {get; private set;}
        public String UnitNumber {get; private set;}
        public String VIN {get; private set;}
        public String Year {get; private set;}
        public String Make {get; private set;}
        public String Model {get; private set;}
        public String Submodel {get; private set;}
        public String Colour {get; private set;}
        public String Mileage {get; private set;}
        public String UnitName {get; private set;}
        public String COUId {get; private set;}
        public List<String> NotesList {get; private set;}
        
        public UnitDescriptionWrapper(Deal_Item__c dealItem){
            this.COUId = dealItem.Customer_Owned_Unit__c;
            this.Type = (dealItem.Type__c == null) ? '' : dealItem.Type__c;
            this.UnitNumber = (dealItem.Customer_Owned_Unit__r.Stock_Id__c == null) ? '' : dealItem.Customer_Owned_Unit__r.Stock_Id__c;
            this.VIN = (dealItem.Customer_Owned_Unit__r.VIN_Number__c == null) ? '' : dealItem.Customer_Owned_Unit__r.VIN_Number__c;
            this.Year = (dealItem.Customer_Owned_Unit__r.Year__c == null) ? (dealItem.Year__c != null ? String.valueOf(dealItem.Year__c) : '') : String.valueOf(dealItem.Customer_Owned_Unit__r.Year__c);
            this.Make = (dealItem.Customer_Owned_Unit__r.Unit_Make__r.Name == null) ? (dealItem.Unit_Make__r.Name != null ? dealItem.Unit_Make__r.Name : '') 
                        : dealItem.Customer_Owned_Unit__r.Unit_Make__r.Name;
            this.Model = (dealItem.Customer_Owned_Unit__r.Unit_Model__r.Name__c == null) ? (dealItem.Unit_Model__r.Name__c != null ? dealItem.Unit_Model__r.Name__c : '')
                         : dealItem.Customer_Owned_Unit__r.Unit_Model__r.Name__c;
            this.Submodel = (dealItem.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c == null) ? (dealItem.Sub_Model__r.Sub_Model_Name__c != null ? dealItem.Sub_Model__r.Sub_Model_Name__c : '') 
                        : dealItem.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c;
            this.Colour = (dealItem.Customer_Owned_Unit__r.Colour__c == null) ? (dealItem.Colour__c != null ? dealItem.Colour__c : '') : dealItem.Customer_Owned_Unit__r.Colour__c;
            this.Mileage = ((dealItem.Customer_Owned_Unit__r.Mileage_Value__c == null) ? 0 : dealItem.Customer_Owned_Unit__r.Mileage_Value__c) +
                            ((dealItem.Customer_Owned_Unit__r.Mileage_Type__c == null) ? 'Km' : dealItem.Customer_Owned_Unit__r.Mileage_Type__c);
                  
            this.NotesList = (dealItem.Customer_Owned_Unit__r.Notes__c == null) ? new List<String>() : (dealItem.Customer_Owned_Unit__r.Notes__c).split('\n');
            this.UnitName = this.Make;
            if(this.Model != null && this.Model != ''){
                this.UnitName += ', '+ this.Model;
            }
            if(this.Submodel != null && this.Submodel != ''){
                this.UnitName += ', '+ this.Submodel;
            }
        }
    }
    
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
    
     public class TaxDetail{
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
    
    private static List<DealWrapper.DealKitHeader> getDealKitHeaderList(List<Option_Fee__c> optionAndFeeListObj, List<Deal_Kit_Header__c> dealKitHeaders) {

        List<DealWrapper.DealKitHeader> dealKitHeaderObjList = new List<DealWrapper.DealKitHeader>();
        List<DateTime> sortedDateTimeList = new List<dateTime>();
        Set<Id> optionAndFeeIdSet = new Set<Id>();
        for(Deal_Kit_Header__c dealKitHeaderRec : dealKitHeaders) {
            sortedDateTimeList.add(dealKitHeaderRec.CreatedDate);
            
            dealKitHeaderObjList.add(new DealWrapper.DealKitHeader(dealKitHeaderRec, dealKitHeaderRec.Options_Fees__r, true));
            for(Option_Fee__c optionAndFeeRec : dealKitHeaderRec.Options_Fees__r) {
                optionAndFeeIdSet.add(optionAndFeeRec.Id);
            } 
        } 
        
        Integer lastIndexValue = 0;
        for(Option_Fee__c optionAndFeeRec : optionAndFeeListObj) {
            if(!optionAndFeeIdSet.contains(optionAndFeeRec.Id)) {
                for(Integer i = lastIndexValue; i < sortedDateTimeList.size(); i++){
                    system.debug(i);
                    if(sortedDateTimeList[i] < optionAndFeeRec.CreatedDate){
                        lastIndexValue ++;
                    } else {
                        break;
                    }
                }
                if(dealKitHeaderObjList.size() > lastIndexValue){
                    dealKitHeaderObjList.add(lastIndexValue, new DealWrapper.DealKitHeader(new Deal_Kit_Header__c(), new List<Option_Fee__c>{optionAndFeeRec}, false));
                    
                    if(sortedDateTimeList.size() > lastIndexValue){
                        sortedDateTimeList.add(lastIndexValue, optionAndFeeRec.CreatedDate);
                    } else {
                        sortedDateTimeList.add(optionAndFeeRec.CreatedDate);
                    }
                    
                    lastIndexValue++;
                } else {
                    dealKitHeaderObjList.add(new DealWrapper.DealKitHeader(new Deal_Kit_Header__c(), new List<Option_Fee__c>{optionAndFeeRec}, false));
                    lastIndexValue++;
                }
            }
        }
        return dealKitHeaderObjList;
    }
    
    public static List<Deal__c> getDealHeaderList(List<Id> dealIdsList) {
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('CO_Invoice_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }

        List<Deal__c> dealList = [SELECT    Id, 
                                            Name,
                                            Status__c,
                                            CreatedById,
                                            CreatedBy.name,
                                            CO_Header__c,
                                            CO_Header__r.Name,
                                            CO_Header__r.Status__c,
                                            CO_Header__r.CO_Type__c,
                                            CO_Header__r.Customer__c,
                                            CO_Header__r.Customer__r.Name,
                                            CO_Header__r.Customer__r.BillingStreet,
                                            CO_Header__r.Customer__r.BillingCity,
                                            CO_Header__r.Customer__r.BillingState,
                                            CO_Header__r.Customer__r.BillingPostalCode,
                                            CO_Header__r.Customer__r.BillingCountry,
                                            CO_Header__r.Customer__r.Email__c,
                                            CO_Header__r.Customer__r.Home_Number__c,
                                            CO_Header__r.Customer__r.Mobile__c,
                                            CO_Header__r.Customer__r.Preferred_Phone__c,
                                            CO_Header__r.Customer__r.Work_Number__c,
                                            CO_Header__r.Customer__r.Home_Number_SMS__c,
                                            CO_Header__r.Customer__r.Mobile_Number_SMS__c, 
                                            CO_Header__r.Customer__r.Preferred_SMS__c,
                                            CO_Header__r.Customer__r.Work_Number_SMS__c,
                                            CO_Header__r.Customer__r.Other_Email__c,
                                            CO_Header__r.Customer__r.Preferred_Email__c,
                                            CO_Header__r.Customer__r.Work_Email__c,
                                            CO_Header__r.LastModifiedDate__c,
                                            Invoice_Number__c,
                                            Invoice_Number__r.Name,
                                            Invoice_Number__r.Invoice_Number__c,
                                            Invoice_Number__r.Invoice_Date__c,
                                            Invoice_Number__r.CreatedBy.Name,
                                            Invoice_Number__r.Status__c,
                                            Invoice_Number__r.LastModifiedDate,
                                            Type__c, 
                                            Salesperson__r.Technician_Name__c,
                                            (SELECT id, Type__c FROM Deal_Items__r),
                                            (Select Name, Amount__c, Payment_Method__c, CreatedDate, LastModifiedDate  From CO_Deposits__r)
                                            FROM Deal__c 
                                            WHERE Id IN: dealIdsList
                                    ];
        return dealList;
    }
    
    private static List<Deal_Item__c> getDealHeaders(List<Id> dealIds) {
        List<Deal_Item__c> dealItemList = new List<Deal_Item__c>();
        if(AccessControl.ifObjectFieldIsAccessible('Deal__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Deal_Item__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Customer_Owned_Unit__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(dealIds != null && dealIds.size() > 0) {
    
            String query = 'SELECT Id, ';
            
            query += '(SELECT Id';
            
            query += ' FROM Deal_Items__r) FROM Deal__c WHERE Id IN: dealIds';
            List<Deal__c> dealList = Database.query(query);
            
            if(dealList.size() > 0) {
                Set<String> dealItemId = new Set<String>();
                for(Deal__c dealRec : dealList) {
                    for(Deal_Item__c dealItemRec : dealRec.Deal_Items__r)
                    dealItemId.add(dealItemRec.Id);
                }
                query = 'SELECT ';
                
                for(String fieldsName : DealItem.getDealItemFields()){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                
                query += '(SELECT ';
                
                for(String fieldsName : DealWrapper.getOptionAndFeeFields()){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                
                query = query.substring(0, query.length()-2);
                query += ' FROM Options_Fees__r), ';
                query += '(SELECT ';
                
                for(String fieldsName : DealWrapper.getDealUnitPriceCost()){
                    fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                    query += fieldsName + ', ';
                }
                query = query.substring(0, query.length()-2);
                query += ' FROM Deal_Unit_Prices_Costs__r) FROM Deal_Item__c WHERE Id IN: dealItemId';
                dealItemList = Database.query(query);
            }
        }
            
        return dealItemList;
    }
}