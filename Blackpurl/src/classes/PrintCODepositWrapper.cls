/**
* Author: Richa Mittal
* Since: January 12, 2017
* Name: PrintCODepositWrapper
* Description: Wrapper class to handle JSON variables for Print CO Deposit.
**/
public class PrintCODepositWrapper {
     
    public StoreInfoWrapper StoreInfo{get; set;}
    public COWrapper COHeaderInfo{get; set;}
    public WorksheetSummary WorksheetTotal{get; set;}
    public Boolean IsTaxIncludePricing{get; set;}
    public List<SOWrapper> SOHeadersList{get; set;}
    public MerchandiseWrapper MerchandiseRecord{get; set;}
    public List<DepositSummary> CODepositList{get; set;}
    public CustomerInfoWrapper CustomerInfo{get; set;}
    public List<COHeaderWrapper.COKitHeader> COKHList{get; set;}
    public MerchandiseCOKHWrapper MerchandiseCOKHRecord{get; set;}
    public DealMerchandiseCOKHWrapper DealMerchandiseCOKHRecord{get; set;}
    public Boolean IsItemizedByLaborCode {get; set;}
    public PrintCustomerOrderInvoiceCtrl.DealDetails DealInfo {get; set;}

    public PrintCODepositWrapper(String coHeaderId, List<CO_Line_Item__c> coLineItemsList, List<Service_Order_Header__c> soHeaderList, List<CO_Deposit__c> depositList, 
                                List<Business_Profile__c> businessProfileList, List<Account> customerList,
                                CO_Header__c coHeaderRec, List<CO_Invoice_Payment__c> coInvoicePaymentsList, List<CO_Invoice_Payment__c> activeCOInvoicePaymentsList,
                                List<COHeaderWrapper.COKitHeader> COKHList, List<Deal_Item__c> dealItemList, List<Deal_Finance__c> dealFinanceList,
                                Map<String, Decimal> salesTaxNameToTaxValue) {  // Ticket#1845: , List<Customer_Owned_Unit__c> unitList: Removed By Pooja 1 May 2017
        
        this.COHeaderInfo = new COWrapper(coHeaderRec);                     
        this.StoreInfo = (businessProfileList.size() > 0) ? 
                                new StoreInfoWrapper(businessProfileList[0]) : 
                                new StoreInfoWrapper(new Business_Profile__c());
        
        this.MerchandiseRecord = new MerchandiseWrapper(coHeaderId, coLineItemsList);
        this.SOHeadersList = new List<SOWrapper>();
        for(Service_Order_Header__c soHeaderRec: soHeaderList) {
            if(String.isBlank(soHeaderRec.Deal__c)) { // Deal service is excluded
                List<Service_Order_Kit_Header__c> sokitHeadersList = SOQLUtil.getSOKHBySOHeaderId(soHeaderRec.Id);
                this.SOHeadersList.add(new SOWrapper(soHeaderRec, sokitHeadersList));
            }
        }
        
        this.CODepositList = new List<DepositSummary>();
        for(CO_Deposit__c depositRec: depositList) {
            if(depositRec.CO_Invoice_Header__r.Invoice_Number__c != null || depositRec.Payment_Method__c != 'Invoice') {
                this.CODepositList.add(new DepositSummary(depositRec));
            }
        }
        
        for(CO_Invoice_Payment__c activePaymentRec: activeCOInvoicePaymentsList) {
            this.CODepositList.add(new DepositSummary(activePaymentRec));
        }
        this.WorksheetTotal = new WorksheetSummary(coHeaderId, soHeaderList, coInvoicePaymentsList, depositList, salesTaxNameToTaxValue);
        
        if(customerList.size() > 0) {   
            this.CustomerInfo = new CustomerInfoWrapper(customerList[0]);                                           
        } else {
            this.CustomerInfo = new CustomerInfoWrapper(new Account());
        }
        
        this.IsTaxIncludePricing = GeneralConfiguration.getTaxIncludingPricing();
        this.IsItemizedByLaborCode = GeneralConfiguration.isCalculationMethodAvailable() && GeneralConfiguration.isItemizedByLaborCode();
        
        this.COKHList = COKHList;
        List<COHeaderWrapper.COKitHeader> merchandiseCokhList = new List<COHeaderWrapper.COKitHeader>();
        List<COHeaderWrapper.COKitHeader> dealMerchandiseCokhList = new List<COHeaderWrapper.COKitHeader>();
        
        for(COHeaderWrapper.COKitHeader cokh: COKHList) {
            if(cokh.DealId != null) {
                dealMerchandiseCokhList.add(cokh);
            } else {
                for(COLineItem coli : cokh.COLIList) {
                    if(coli.DealId != null) {
                        dealMerchandiseCokhList.add(cokh);
                    } else {
                        merchandiseCokhList.add(cokh);
                    }
                    break;
                }
            }
        }
        this.MerchandiseCOKHRecord = new MerchandiseCOKHWrapper(merchandiseCokhList);
        this.DealMerchandiseCOKHRecord = new DealMerchandiseCOKHWrapper(dealMerchandiseCokhList);
        this.DealInfo = new PrintCustomerOrderInvoiceCtrl.DealDetails(dealItemList, dealFinanceList);
            
        for(PrintCustomerOrderInvoiceCtrl.DealUnitDetails dealUnitRec : this.DealInfo.UnitList) {
            Decimal unitTotal = dealUnitRec.BaseUnitPriceTotal;
            
            for(DealWrapper.FactoryOption factoryRec : dealUnitRec.FactoryOptionList) {
                unitTotal += factoryRec.TotalPrice;
            }
            for(DealWrapper.DealerInstalledOption dealerRec : dealUnitRec.DealerOptionList) {
                unitTotal += dealerRec.TotalPrice;
            }
            dealUnitRec.DealUnitPriceAndCostTotal = unitTotal;
        }
        
        DealInfo.DealTotal = coHeaderRec.Deal_Total__c;
    }
    
    public class StoreInfoWrapper {
        public String CompanyName{get; set;}
        public String Address1{get; set;}
        public String Address2{get; set;}
        public String State{get; set;}
        public String PostalCode{get; set;}
        public String Country{get; set;}
        public String City{get; set;}
        public String Address{get; set;}
        public String BusinessPhone{get; set;}
        public String BusinessEmail{get; set;}
        public String TaxId{get; set;}
        public String OrderDepositWarrantyText{get; set;}
        public Boolean IsSignatureLineforOrderDeposit{get; set;}
        
        public StoreInfoWrapper(Business_Profile__c businessProfileRec) {
            this.CompanyName = (businessProfileRec.Business_Name__c != null) ? businessProfileRec.Business_Name__c : '';
            this.Address1 = businessProfileRec.Business_Street_Address1__c != null ? (businessProfileRec.Business_Street_Address1__c).replace(',', ' ') : '';
            this.Address2 = businessProfileRec.Business_Street_Address2__c != null ? (businessProfileRec.Business_Street_Address2__c).replace(',', ' ') : '';
            this.City = businessProfileRec.Business_City__c;
            this.State = (businessProfileRec.Business_State__c != null) ? businessProfileRec.Business_State__r.Name__c : '';
            this.PostalCode = businessProfileRec.Business_Postal_Code__c;
            this.Country = (businessProfileRec.Business_Country__c != null) ? businessProfileRec.Business_Country__r.Name__c : '';
            
            this.BusinessPhone = (businessProfileRec.Business_Phone__c != null) ? businessProfileRec.Formatted_Business_Number__c : '';
            this.BusinessEmail = (businessProfileRec.Business_Email__c != null) ? businessProfileRec.Business_Email__c : '';
            this.TaxId = Configurations__c.getOrgDefaults().Tax_Id__c == null ? '' : Configurations__c.getOrgDefaults().Tax_Id__c;
            this.OrderDepositWarrantyText = (businessProfileRec.Order_Deposit_Warranty_Text__c != null) ? businessProfileRec.Order_Deposit_Warranty_Text__c : '';
            this.IsSignatureLineforOrderDeposit = businessProfileRec.is_Signature_Line_for_Order_Deposit__c;
            
            this.Address = '';
            if(this.Address1 != null) {
                this.Address += this.Address1 + ', ';
            }
            if(this.Address2 != null) {
                this.Address += this.Address2 + ', ';
            }
            if(this.City != null) {
                this.Address += this.City + ', ';
            }
            if(this.State != null) {
                this.Address += this.State + ', ';
            }
            if(this.Country != null) {
                this.Address += this.Country + ', ';
            }
            if(this.PostalCode != null) {
                this.Address += this.PostalCode + ', ';
            }
            if(this.Address.length() > 1) {
                this.Address = this.Address.subString(0, this.Address.length() - 2).replace(',', ' ');
            }
        }
    }
    
    public class COWrapper {
        public String Name{get; set;} 
        public String OrderedDate{get; set;} 
        public String OwnerName{get; set;} 
        
        public COWrapper(CO_Header__c coHeaderRec) {
            this.Name = coHeaderRec.Name;
            this.OrderedDate = string.valueOf(coHeaderRec.CreatedDate.date().format());
            this.OwnerName = coHeaderRec.Owner__r.Name;
        }
    }
    
    public class CustomerInfoWrapper {
        public String CustomerName{get; set;}
        public String Email{get; set;}
        public String Phone{get; set;}
        public String BillingStreet1{get; set;}
        public String BillingStreet2{get; set;}
        public String BillingCity{get; set;}
        public String BillingState{get; set;}
        public String BillingCountry{get; set;}
        public String BillingPostalCode{get; set;}
            
        public CustomerInfoWrapper(Account customerRec) {
            this.CustomerName = customerRec.Name;
            if(customerRec.Preferred_Email__c == null) {
                if(customerRec.Email__c != null) {
                    this.Email = customerRec.Email__c;
                } else if(customerRec.Work_Email__c != null) {
                    this.Email = customerRec.Work_Email__c;
                } else if(customerRec.Other_Email__c != null) {
                    this.Email = customerRec.Other_Email__c;
                }
            } else {
                this.Email = customerRec.Preferred_Email__c;
            }
            
            if(customerRec.Preferred_Phone__c == null) {
                if(customerRec.Home_Number__c != null) {
                    this.Phone = customerRec.Formatted_Home_number__c;
                } else if(customerRec.Mobile__c != null) {
                    this.Phone = customerRec.Formatted_Mobile_Number__c;
                } else if(customerRec.Work_Number__c != null) {
                    this.Phone = customerRec.Formatted_Work_Number__c;
                }
            } else {
                this.Phone = customerRec.Formatted_Preferred_Phone__c;
            }
            
            String billingStreet = (customerRec.BillingStreet == null ) ? '' : customerRec.BillingStreet;
            List<String> bsList = billingStreet.split('\n');
            this.BillingStreet1 = (bsList.size() > 0) ? bsList[0].replace(',', ' ') : '';
            this.BillingStreet2 = (bsList.size() > 1) ? bsList[1].replace(',', ' ') : '';
            this.BillingCity = (customerRec.BillingCity == null) ? '' : customerRec.BillingCity;
            this.BillingState = (customerRec.BillingState == null) ? '' : customerRec.BillingState;
            this.BillingCountry = (customerRec.BillingCountry == null) ? '' : customerRec.BillingCountry;
            this.BillingPostalCode = (customerRec.BillingPostalCode == null) ? '' : customerRec.BillingPostalCode;
        }
    }
    
    public class MerchandiseWrapper {
        public List<COLIWrapper> COLIList{get; set;}
        public Decimal Total{get; set;}
        
        public MerchandiseWrapper(String coHeaderId, List<CO_Line_Item__c> coliForMerchList) {
            this.COLIList = new List<COLIWrapper>();
            for(CO_Line_Item__c coliRec : coliForMerchList) {
                this.COLIList.add(new COLIWrapper(coliRec));
            }
            this.Total = 0;
            for(COLIWrapper CW : COLIList){
                Total += CW.Total;
            } 
        }
    }
    
    public class COLIWrapper {
        public String ItemDesc{get; set;}
        public String Type{get; set;}
        public Decimal Need{get; set;}
        public Decimal StockCommited{get; set;}
        public String Status{get; set;}
        public Decimal Price{get; set;}
        public Decimal Total{get; set;}
        public Boolean IsNonInventoryPart{get; set;}
        
        public COLIWrapper (CO_Line_Item__c coliRec) {

            String itemCode = (coliRec.Item_Code__c != null) ? coliRec.Item_Code__c : '';
            String itemDescription = (coliRec.Item_Description__c != null) ? coliRec.Item_Description__c : '';
            this.ItemDesc = itemCode + ' - ' + itemDescription;
            
            if(coliRec.Part__c != null) {
                this.Type = 'Part'; 
                this.IsNonInventoryPart = coliRec.Part__r.Non_Inventory_Part__c; 
            } else if(coliRec.Fee__c != null) {
                this.Type = 'Fee';  
            }
            this.Need = (coliRec.Qty__c != null ) ? coliRec.Qty__c : 0;
            this.StockCommited = (coliRec.Qty_Committed__c != null) ? coliRec.Qty_Committed__c : 0;
            
            if(coliRec.Closed_CO_Invoice_link__c != null) {
                this.Status = 'Invoiced'; 
            } else {
                if(this.Need == this.StockCommited) {
                    this.Status = 'In Stock';
                } else if(this.Need > this.StockCommited) {
                    if(coliRec!= null && !coliRec.Special_Order__c) {
                        this.Status = 'Required';
                    } else {
                        this.Status = 'Ordered';
                    }
                } else if(coliRec.Qty__c < 0) {
                    this.Status = 'RETURN';
                }
            }
            
            if(coliRec.Fee__c != null) {
                this.Status = 'Ready';
            }
            this.Price = coliRec.Price__c != null ? coliRec.Price__c : 0;
            this.Total = this.Price * this.Need;
        }
    }
    
    public class SOWrapper {
        public List<String> CauseList{get; set;}
        public List<String> CorrectionList{get; set;}
        public List<String> ConcernList{get; set;}
        public List<String> ManualNotes{get; set;}
        public String SoHeaderInvoiceStatus{get; set;}// added by kajal 8th june 2017, #2017
        public String SoHeaderName{get; set;}
        public List<SOLIWrapper> SOLIList{get; set;}
        public Decimal Total{get; set;}
        public List<SOHeaderWrapper.SOGrid> SOGridItems{get; set;} // Added by richa 14 april
        public String Unit{get; set;}  // Ticket#1845: Added By Pooja 1 May 2017
        
        public Decimal ShopSupplyTotal {get; private set;}
        public Set<String> ShopSupplyDetailSet {get; private set;}
        
        public SOWrapper(Service_Order_Header__c soHeaderRec) {
            this.CauseList = (soHeaderRec.SO_Cause__c != null) ? soHeaderRec.SO_Cause__c.split('\n') : new List<String>();
            this.CorrectionList = (soHeaderRec.SO_Correction__c != null) ? soHeaderRec.SO_Correction__c.split('\n') : new List<String>();
            this.ConcernList = (soHeaderRec.SO_Concern__c != null) ? soHeaderRec.SO_Concern__c.split('\n') : new List<String>();
            this.ManualNotes = (soHeaderRec.SO_Notes_For_Customer__c != null) ? soHeaderRec.SO_Notes_For_Customer__c.split('\n') : new List<String>();
            this.SOLIList = new List<SOLIWrapper>();
            for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
                this.SOLIList.add(new SOLIWrapper(soliRec));
            }
            this.Total = 0;
            for(SOLIWrapper SW : SOLIList){
                Total += SW.Total;
            } 
            this.SoHeaderName = soHeaderRec.Name__c;
            this.SoHeaderInvoiceStatus = soHeaderRec.Work_Status__c;
            
            Unit = '';
            if(soHeaderRec.Customer_Owned_Unit__c != null) {
                Boolean showDash = false;
                if(soHeaderRec.Customer_Owned_Unit__r.Year__c != null){
                    Unit += soHeaderRec.Customer_Owned_Unit__r.Year__c;
                }
                if(soHeaderRec.Customer_Owned_Unit__r.Unit_Make__r.Name !=null && soHeaderRec.Customer_Owned_Unit__r.Unit_Make__r.Name !=''){
                    Unit += ' ' + soHeaderRec.Customer_Owned_Unit__r.Unit_Make__r.Name;
                    showDash = true;
                }
                if(soHeaderRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c != null && soHeaderRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c !=''){
                    Unit += ' ' + soHeaderRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c;
                    showDash = true;
                }
                if(soHeaderRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c != null && soHeaderRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c !=''){ // Added by richa 06/02/2017
                    Unit += ' ' + soHeaderRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c;
                    showDash = true;
                }
                if(showDash) {
                        Unit += ' - ';
                    }
                if(soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c != null){
                    Unit += soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c ;
                } else  {
                    Unit += 'VIN unknown';
                }                   
            }else   {
                Unit = 'No Unit Selected';
            }
        }
        
        
        public SOWrapper(Service_Order_Header__c soRec, List<Service_Order_Kit_Header__c> soKitHeaderList) {
            this.CauseList = (soRec.SO_Cause__c != null) ? soRec.SO_Cause__c.split('\n') : new List<String>();
            this.CorrectionList = (soRec.SO_Correction__c != null) ? soRec.SO_Correction__c.split('\n') : new List<String>();
            this.ConcernList = (soRec.SO_Concern__c != null) ? soRec.SO_Concern__c.split('\n') : new List<String>();
            this.ManualNotes = (soRec.SO_Notes_For_Customer__c != null) ? soRec.SO_Notes_For_Customer__c.split('\n') : new List<String>();
            this.SOLIList = new List<SOLIWrapper>();
            for(Service_Order_Line_Item__c soliRec : soRec.Service_Order_Line_Items__r) {
                this.SOLIList.add(new SOLIWrapper(soliRec));
            }
            
            this.ShopSupplyTotal = (soRec.Total_Shop_Supplies__c != null) ? soRec.Total_Shop_Supplies__c : 0;
            this.Total = soRec.Total__c;
            this.SoHeaderName = soRec.Name__c;
            this.SoHeaderInvoiceStatus = soRec.Work_Status__c;
            this.SOGridItems = new List<SOHeaderWrapper.SOGrid>();
            List<DateTime> sortedDateTimeList = new List<dateTime>();
            Set<Id> soliIdSet = new Set<Id>();
            for(Service_Order_Kit_Header__c soKHRec : soKitHeaderList) {
                sortedDateTimeList.add( soKHRec.CreatedDate );
                this.SOGridItems.add(new SOHeaderWrapper.SOGrid(soKHRec, soKHRec.Service_Order_Line_Items__r, true));
                for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
                    soliIdSet.add(soliRec.Id);
                } 
            }
            Integer lastIndexValue = 0;
            system.debug('Sorting Started OF SOLIs -->>');
            system.debug(sortedDateTimeList);
            
            ShopSupplyDetailSet = new Set<String>();
            for(Service_Order_Line_Item__c soliRec : soRec.Service_Order_Line_Items__r) {
                if(!soliIdSet.contains(soliRec.Id)) {
                    for(Integer i = lastIndexValue; i < sortedDateTimeList.size(); i++){
                        system.debug(i);
                        if(sortedDateTimeList[i] < soliRec.CreatedDate){
                            lastIndexValue ++;
                        } else {
                            break;
                        }
                    }
                    if(this.SOGridItems.size() > lastIndexValue){
                        this.SOGridItems.add(lastIndexValue, new SOHeaderWrapper.SOGrid(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
                        
                        if(sortedDateTimeList.size() > lastIndexValue){
                            sortedDateTimeList.add(lastIndexValue, soliRec.CreatedDate);
                        } else {
                            sortedDateTimeList.add(soliRec.CreatedDate);
                        }
                        
                        lastIndexValue++;
                    } else {
                        this.SOGridItems.add(new SOHeaderWrapper.SOGrid(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
                        lastIndexValue++;
                    }
                    
                    if(soliRec.Labour_Code__c != null && soliRec.Labour_Code__r.Calculate_Supplies__c && soliRec.Labour_Code__r.Supplies_Detail__c != null) {
                        for(String shopSupplyDetailStr : soliRec.Labour_Code__r.Supplies_Detail__c.split('\n')) {
                            ShopSupplyDetailSet.add(shopSupplyDetailStr);
                        }
                    }
                }
            }
            
            Unit = '';
            if(soRec.Customer_Owned_Unit__c != null) {
                Boolean showDash = false;
                if(soRec.Customer_Owned_Unit__r.Year__c != null){
                    Unit += soRec.Customer_Owned_Unit__r.Year__c;
                }
                if(soRec.Customer_Owned_Unit__r.Unit_Make__r.Name !=null && soRec.Customer_Owned_Unit__r.Unit_Make__r.Name !=''){
                    Unit += ' ' + soRec.Customer_Owned_Unit__r.Unit_Make__r.Name;
                    showDash = true;
                }
                if(soRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c != null && soRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c !=''){
                    Unit += ' ' + soRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c;
                    showDash = true;
                }
                if(soRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c != null && soRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c !=''){ // Added by richa 06/02/2017
                    Unit += ' ' + soRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c;
                    showDash = true;
                }
                if(showDash) {
                        Unit += ' - ';
                    }
                if(soRec.Customer_Owned_Unit__r.VIN_Number__c != null){
                    Unit += soRec.Customer_Owned_Unit__r.VIN_Number__c ;
                } else  {
                    Unit += 'VIN unknown';
                }                           
            }else   {
                Unit = 'No Unit Selected';
            }
        }
    }
    
    public class SOLIWrapper {
        public String ItemDesc{get; set;}
        public String Type{get; set;}
        public Decimal Need{get; set;}
        public Decimal StockCommited{get; set;}
        public String Status{get; set;}
        public Decimal Price{get; set;}
        public Decimal Total{get; set;}
        public Boolean IsNonInventoryPart{get; set;}
        
        public SOLIWrapper(Service_Order_Line_Item__c soliRec) {
            String itemCode = (soliRec.Item_Code__c != null) ? soliRec.Item_Code__c : '';
            String itemDescription = (soliRec.Item_Description__c != null) ? soliRec.Item_Description__c : '';
            this.ItemDesc = itemCode + ' - ' + itemDescription;
            
            if(soliRec.Part__c != null) {
                this.Type = 'Part'; 
                this.IsNonInventoryPart = soliRec.Part__r.Non_Inventory_Part__c;
            } else if(soliRec.Labour_Code__c != null) {
                this.Type = 'Labor';    
            } else if(soliRec.Fee__c != null) {
                this.Type = 'Fee';  
            }
            this.Need = (soliRec.Qty_Needed__c != null ) ? soliRec.Qty_Needed__c : 0;
            this.StockCommited = (soliRec.Qty_Committed__c != null) ? soliRec.Qty_Committed__c : 0;
            
            if(soliRec.CO_Line_Item__r.Closed_CO_Invoice_link__c != null) {
                this.Status = 'Invoiced'; 
            } else {
                if(this.Need == this.StockCommited) {
                    this.Status = 'In Stock';
                } else if(this.Need > this.StockCommited) {
                    if(soliRec.CO_Line_Item__c != null && !soliRec.CO_Line_Item__r.Special_Order__c) {
                        this.Status = 'Required';
                    } else {
                        this.Status = 'Ordered';
                    }
                } else if(soliRec.Qty_Needed__c < 0) {
                    this.Status = 'RETURN';
                }
            }
            if(soliRec.Labour_Code__c != null || soliRec.Fee__c != null) {
                this.Status = 'Ready';
            }
            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            if(isTaxIncludingPricing && String.isBlank(soliRec.Deal__c)) { // && String.isBlank(soliRec.Deal__c) Added by richa 15 april
                if(soliRec.Tax_Percent__c == null) {
                    soliRec.Tax_Percent__c = 0;
                }
                if(soliRec.Kit_Price__c == null) {
                    soliRec.Kit_Price__c = 0;
                }
                this.Price = (soliRec.Kit_Price__c * (1 + (soliRec.Tax_Percent__c / 100))).setScale(2, RoundingMode.HALF_UP);
            } else {
                this.Price = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c.SetScale(2, RoundingMode.HALF_UP) : soliRec.Kit_Price__c;
            }
            if(this.Price == null) {
                this.Price = 0;
            }
            this.Total = this.Price * this.Need;
        }
    }
    
    public class WorksheetSummary {
        public Decimal TotalPart{get; set;}
        public Decimal TotalLabor{get; set;}
        public Decimal TotalSublet{get; set;}
        public Decimal TotalFee{get; set;}
        public Decimal SubTotal{get; set;}
        public Decimal SalesTax{get; set;}
        public Decimal Total{get; set;}
        public Decimal AmountPaid{get; set;}
        public Decimal BalanceDue{get; set;}
        public Decimal TotalShopSupplies {get; private set;}
        public Decimal TotalUnits {get; private set;}
        public Decimal TotalTradeIns {get; private set;}
        public Decimal TotalLienPayout {get; private set;}
        public Decimal TotalWarranty {get; private set;}
        public Decimal TotalOtherProducts {get; private set;}
        public Decimal StampDuty {get; private set;}
        public Decimal TotalFinanceProducts {get; private set;}
        public List<TaxDetail> SalesTaxList{get; set;}
        
        public WorksheetSummary(String coHeaderId, List<Service_Order_Header__c> soHeaderList, 
                                    List<CO_Invoice_Payment__c> coInvoicePaymentsList, 
                                    List<CO_Deposit__c> depositList,
                                    Map<String, Decimal> salesTaxNameToTaxValue) {
            this.TotalPart = 0;
            this.TotalLabor = 0;
            this.TotalSublet = 0;
            this.TotalFee = 0;
            this.SubTotal = 0;
            this.SalesTax = 0;
            this.Total = 0;
            this.AmountPaid = 0;
            this.BalanceDue = 0;
            this.TotalShopSupplies = 0;
            this.TotalUnits = 0;
            this.TotalTradeIns = 0;
            this.TotalLienPayout = 0;
            this.TotalWarranty = 0;
            this.TotalOtherProducts = 0;
            this.StampDuty = 0;
            this.TotalFinanceProducts = 0;
            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            for(Service_Order_Header__c soHeaderRec : soHeaderList) {
                if(String.isBlank(soHeaderRec.Deal__c)) { // Exclude deal service
                    this.TotalPart += (soHeaderRec.Total_Parts__c != null) ? soHeaderRec.Total_Parts__c : 0;
                    this.TotalLabor += (soHeaderRec.Total_Labor__c != null) ? soHeaderRec.Total_Labor__c : 0;
                    this.TotalFee += (soHeaderRec.Total_Fees__c != null) ? soHeaderRec.Total_Fees__c : 0;
                    this.TotalSublet += (soHeaderRec.Total_Sublet__c != null) ? soHeaderRec.Total_Sublet__c : 0;
                    this.TotalShopSupplies += (soHeaderRec.Total_Shop_Supplies__c != null) ? soHeaderRec.Total_Shop_Supplies__c : 0;
                }
            }
                
            List<CO_Line_Item__c> coLineItems = SOQLUtil.getCOLineItemByFieldValue(new Map<String, String>{'CO_Header__c' => coHeaderId,
                                                                                            'Service_Order_Line_Item__c' => null,
                                                                                            'Deal__c' => null});
            if(!isTaxIncludingPricing) {
                for(CO_Line_Item__c coLineItemRec : coLineItems) {
                    if(coLineItemRec.Part__c != null) {
                            this.TotalPart += (coLineItemRec.Qty__c * coLineItemRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(coLineItemRec.Fee__c != null) {
                            this.TotalFee += (coLineItemRec.Qty__c * coLineItemRec.Price__c).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            } else {
                for(CO_Line_Item__c coLineItemRec : coLineItems) {
                    if(coLineItemRec.Part__c != null) {
                        this.TotalPart += (coLineItemRec.Qty__c * coLineItemRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    } else if(coLineItemRec.Fee__c != null) {
                        this.TotalFee += (coLineItemRec.Qty__c * coLineItemRec.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP);
                    }
                }
            }
            
            List<Deal__c> dealList = [SELECT Fee_Total__c, F_I_Tax_Total__c, F_I_Total__c, Labour_Total__c, Lien_Payout_Total__c, Other_Product_Total__c, 
                                        Part_Total__c, Product_Total__c, Stamp_Duty_Total__c, Sublet_Total__c, Trade_In_Total__c, 
                                        Unit_Price_And_Cost_Total__c, Warranty_Product_Total__c FROM Deal__c WHERE CO_Header__c =: coHeaderId];
            
            for(Deal__c dealRec: dealList) {
                this.TotalPart += (dealRec.Part_Total__c != null) ? dealRec.Part_Total__c : 0;
                this.TotalLabor += (dealRec.Labour_Total__c != null) ? dealRec.Labour_Total__c : 0;
                this.TotalFee += (dealRec.Fee_Total__c != null) ? dealRec.Fee_Total__c : 0;
                this.TotalSublet += (dealRec.Sublet_Total__c != null) ? dealRec.Sublet_Total__c : 0;
                this.StampDuty += (dealRec.Stamp_Duty_Total__c != null) ? dealRec.Stamp_Duty_Total__c : 0;
                this.TotalUnits += (dealRec.Unit_Price_And_Cost_Total__c != null) ? dealRec.Unit_Price_And_Cost_Total__c : 0;
                this.TotalTradeIns += (dealRec.Trade_In_Total__c != null) ? dealRec.Trade_In_Total__c : 0;
                this.TotalLienPayout += (dealRec.Lien_Payout_Total__c != null) ? dealRec.Lien_Payout_Total__c : 0;
                this.TotalWarranty += (dealRec.Warranty_Product_Total__c != null) ? dealRec.Warranty_Product_Total__c : 0;
                this.TotalOtherProducts += (dealRec.Other_Product_Total__c != null) ? dealRec.Other_Product_Total__c : 0;
                Decimal totalFIProduct = (dealRec.F_I_Total__c != null) ? dealRec.F_I_Total__c : 0;
                Decimal totalFIProductTax = (dealRec.F_I_Tax_Total__c != null) ? dealRec.F_I_Tax_Total__c : 0;
                this.TotalFinanceProducts += isTaxIncludingPricing ? (totalFIProduct + totalFIProductTax) : totalFIProduct;
            }
            this.Total = this.SubTotal = this.TotalLabor + this.TotalPart + this.TotalFee + this.TotalSublet + this.TotalShopSupplies + this.StampDuty +
                                            this.TotalUnits + this.TotalTradeIns + this.TotalLienPayout + this.TotalWarranty + this.TotalOtherProducts + this.TotalFinanceProducts;
            this.SalesTaxList = new List<TaxDetail>();
            for(String taxName : salesTaxNameToTaxValue.keySet()){
                this.SalesTaxList.add(new TaxDetail(taxName, salesTaxNameToTaxValue.get(taxName)));
                if(!isTaxIncludingPricing) {
                    this.Total = this.Total + salesTaxNameToTaxValue.get(taxName);
                }
            }
            
            for(CO_Invoice_Payment__c coInvoicePaymentRec: coInvoicePaymentsList) {
                if(coInvoicePaymentRec.Payment_Method__c != 'Charge Account') {
                    this.AmountPaid += coInvoicePaymentRec.Amount__c;
                }
            }
            
            for(CO_Deposit__c depositRec: depositList) {
                this.AmountPaid += depositRec.Amount__c;
            }
            
            this.BalanceDue = this.Total - this.AmountPaid;
            this.TotalPart = this.TotalPart.setScale(2, RoundingMode.HALF_UP);
            this.TotalLabor = this.TotalLabor.setScale(2, RoundingMode.HALF_UP);
            this.TotalSublet = this.TotalSublet.setScale(2, RoundingMode.HALF_UP);
            this.TotalFee = this.TotalFee.setScale(2, RoundingMode.HALF_UP);
            this.SubTotal = this.SubTotal.setScale(2, RoundingMode.HALF_UP);
            this.SalesTax = this.SalesTax.setScale(2, RoundingMode.HALF_UP);
            this.Total = this.Total.setScale(2, RoundingMode.HALF_UP);
            this.AmountPaid = this.AmountPaid.setScale(2, RoundingMode.HALF_UP);
            this.BalanceDue = this.BalanceDue.setScale(2, RoundingMode.HALF_UP);
            this.TotalShopSupplies = this.TotalShopSupplies.setScale(2, RoundingMode.HALF_UP);
            this.StampDuty = this.StampDuty.setScale(2, RoundingMode.HALF_UP);
            this.TotalUnits = this.TotalUnits.setScale(2, RoundingMode.HALF_UP);
            this.TotalTradeIns = this.TotalTradeIns.setScale(2, RoundingMode.HALF_UP);
            this.TotalLienPayout = this.TotalLienPayout.setScale(2, RoundingMode.HALF_UP);
            this.TotalWarranty = this.TotalWarranty.setScale(2, RoundingMode.HALF_UP);
            this.TotalOtherProducts = this.TotalOtherProducts.setScale(2, RoundingMode.HALF_UP);
            this.TotalFinanceProducts = this.TotalFinanceProducts.setScale(2, RoundingMode.HALF_UP);
        }
    }
    
    public class SOInfoWrapper {
        public String SOHeaderId{get; set;}
        public String Name{get; set;}
        public Boolean IsSOHeaderSelected{get; set;}
        
        public SOInfoWrapper(Service_Order_Header__c serviceOrderRec) {
            this.SOHeaderId = serviceOrderRec.Id;
            this.Name = serviceOrderRec.Name__c;
            this.IsSOHeaderSelected = true;     
        }
    }
    
    public class DepositSummary {
        public String depositType{get; set;}
        public String CreatedDate{get; set;}
        public Decimal Amount{get; set;}
        
        public DepositSummary(CO_Deposit__c depositRec) {
            this.depositType = depositRec.CO_Invoice_Header__r.Invoice_Number__c != null ? depositRec.CO_Invoice_Header__r.Invoice_Number__c : depositRec.Payment_Method__c;
            this.CreatedDate = string.valueOf(depositRec.CreatedDate.date().format());
            this.Amount = depositRec.Amount__c;     
        }
        
        public DepositSummary(CO_Invoice_Payment__c activePaymentRec) {
            this.depositType = activePaymentRec.CO_Invoice_Header__r.Invoice_Number__c != null ? activePaymentRec.CO_Invoice_Header__r.Invoice_Number__c : activePaymentRec.Payment_Method__c;
            this.CreatedDate = string.valueOf(activePaymentRec.CreatedDate.date().format());
            this.Amount = activePaymentRec.Amount__c;     
        }
    }
    
    public class TaxDetail{
        public String TaxName{get; set;}
        public Decimal TaxAmount{get; set;}
        
        public TaxDetail(String taxName, Decimal taxAmount){
            if(taxAmount == null){
                taxAmount = 0;
            }
            this.TaxName = taxName;
            this.TaxAmount = taxAmount;
        }
    }
    
    public class MerchandiseCOKHWrapper {
        public List<COHeaderWrapper.COKitHeader> MerchandiseCOKHList{get; set;}
        public Decimal Total{get; set;}
        
        public MerchandiseCOKHWrapper(List<COHeaderWrapper.COKitHeader> MerchandiseCOKHList) {
            this.MerchandiseCOKHList = MerchandiseCOKHList;
            this.Total = 0;
            for(COHeaderWrapper.COKitHeader cokh : MerchandiseCOKHList){
                for(COLineItem coli: cokh.COLIList) {
                    this.Total += (coli.SubTotal != null) ? (coli.SubTotal) : (coli.Qty * coli.Price);
                }
            }
        }
    }
    
    public class DealMerchandiseCOKHWrapper {
        public List<COHeaderWrapper.COKitHeader> DealMerchandiseCOKHList{get; set;}
        public Decimal Total{get; set;}
        
        public DealMerchandiseCOKHWrapper(List<COHeaderWrapper.COKitHeader> DealMerchandiseCOKHList) {
            this.DealMerchandiseCOKHList = DealMerchandiseCOKHList;
            this.Total = 0;
            for(COHeaderWrapper.COKitHeader cokh : DealMerchandiseCOKHList){
                for(COLineItem coli: cokh.COLIList) {
                    this.Total += (coli.SubTotal != null) ? (coli.SubTotal) : (coli.Qty * coli.Price);
                }
            }
        }
    }
    
    public static String formatphonenumber(String cphone) {
        String fphone = cphone.replaceAll('\\D','');
        if (fphone.length() == 10) {
            fphone = formatphonenum(fphone);
            return fphone;
        } else {
            return cphone;
        }
    }
        
    static String formatphonenum(String s) {
        s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
        return s;
    }
    
    public static List<String> getCustomerFieldsList() {
        List<String> customerFields = new List<String>{'Id',
                                                        'Name',
                                                        'FirstName__c',
                                                        'LastName__c',
                                                        'Email__c',
                                                        'Home_Number__c',
                                                        'Mobile__c',
                                                        'Preferred_Phone__c',
                                                        'Work_Number__c',
                                                        'Home_Number_SMS__c',
                                                        'Mobile_Number_SMS__c', 
                                                        'Preferred_SMS__c',
                                                        'Work_Number_SMS__c',
                                                        'Other_Email__c',
                                                        'Preferred_Email__c',
                                                        'Work_Email__c',
                                                        'BillingStreet',
                                                        'BillingCity',
                                                        'BillingState',
                                                        'BillingCountry',
                                                        'BillingPostalCode',
                                                        'Formatted_Home_number__c'
                                                };
        return customerFields;
    }
}