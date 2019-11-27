public with sharing class COLIWrapper {
    
    public String Item {get; set;}
    public String ItemCode {get; set;}
    public String ItemDescription {get; set;}
    public Decimal Qty {get; set;}
    public Decimal QtyCpy; // Copy of Qty To Handle Oversold Conditions for Cash Sale on UI
    public Decimal QtyCommitted {get; set;}
    public Decimal StockCommitedCpy; // Copy of QtyCommitted To reset values on UI - related to user permissions - oversell inventory
    public String Status {get; set;}
    public Decimal Price {get; set;}
    public Decimal SubTotal {get; set;}
    public String Invoice {get; set;}
    public String FulfillDate {get; set;}
    public String CoLineItemId {get; set;}
    public String PartId {get; set;}
    public Boolean isSpecialOrder {get; set;}
    public Decimal Tax {get; set;}
    public Decimal Retail {get; set;}
    public Decimal AvaliablePartsQty {get; set;}
    public Boolean NonInventoryPart {get; set;}
    public String VOStatus {get; set;}
    public String POStatus {get; set;}
    public String VONumber {get; set;}
    public String ExpectedDeliveryDate {get; set;}
    public List<VOHeader> VOHeaderList {get; set;}
    public String FeeId {get; set;}
    public String VendorId {get; set;}
    public Boolean IsFixedPrice {get; set;}
    public Boolean IsFixedPriceForCO {get; set;}
    public Decimal ActualKitPrice {get; set;}
    public Decimal QtyOrder {get; set;}
    public Decimal OversoldQty {get; set;}
    public Decimal ActualAvailableParts {get; set;}
    public String DealId{get;set;}
    public String OptionAndFeeItemId;
    public Boolean IsNonInventoryPart;
    public Decimal ActualRetailPrice;
    public String EntityType;
	public Boolean IsBRPPart;

    public COLIWrapper(CO_Line_Item__c coLineItemObj) {
        Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        
        this.ItemCode = (coLineItemObj.Item_Code__c != null) ? coLineItemObj.Item_Code__c : '';
        this.ItemDescription = (coLineItemObj.Item_Description__c != null) ? coLineItemObj.Item_Description__c : '';
        this.Item = this.ItemCode + ' - ' + this.ItemDescription;
        this.ActualRetailPrice = (coLineItemObj.Actual_Retail_Price__c != null) ? coLineItemObj.Actual_Retail_Price__c : 0;
        
        this.Qty = (coLineItemObj.Qty__c == null) ? 1 : coLineItemObj.Qty__c; // Default Value = 1
        
        this.QtyCommitted = coLineItemObj.Qty_Committed__c; // Default Value = 0
        if(coLineItemObj.Qty__c == null) {
            coLineItemObj.Qty__c = 0;
        } 
        if(coLineItemObj.Qty_Committed__c == null) {
            coLineItemObj.Qty_Committed__c = 0;
        }
        if(coLineItemObj.Closed_CO_Invoice_link__c != null) {
            this.Status = 'Invoiced'; 
        } else {
            if((coLineItemObj.Qty__c == coLineItemObj.Qty_Committed__c) || 
                            coLineItemObj.Part__r.Non_Inventory_Part__c) {
                if(coLineItemObj.Oversold_Qty__c != null && coLineItemObj.Oversold_Qty__c > 0){
                    this.Status = 'Oversold';
                } else{
                    this.Status = 'In Stock';   
                }
            } else if(coLineItemObj.Vendor_Order_Header__c != null) {
                if(coLineItemObj.Vendor_Order_Header__r.Status__c  == 'Received' && coLineItemObj.Qty__c == coLineItemObj.Qty_Committed__c) {
                    this.Status = 'In Stock'; 
                } else if(coLineItemObj.Status__c != null) {
                    this.Status = coLineItemObj.Status__c;
                } 
            } else if(coLineItemObj.Qty__c < 0) {
                this.Status = 'RETURN';
            } else if(coLineItemObj.CO_Status__c == Constants.CO_STATUS_QUOTE || 
            	COLineItemTriggerHelper.getMerchandiseCommitOrderControlSetting(coLineItemObj) == Constants.UNCOMIITTED) {
                if(coLineItemObj.Part__r.AvailableParts__c >= coLineItemObj.Qty__c) {
                    this.Status = 'In Stock'; 
                } else {
                    this.Status = 'Required'; 
                }
            } else if(coLineItemObj.Qty__c > coLineItemObj.Qty_Committed__c ){
                if(coLineItemObj.Status__c != null) {
                    this.Status = coLineItemObj.Status__c;
                }
            }
            if(coLineItemObj.Fee__c != null) {
                this.Status = 'Ready';
            }
        }
        
        if(coLineItemObj.Tax__c == null) {
            coLineItemObj.Tax__c = 0;
        }
 
        if(coLineItemObj.Price__c == null) {
            this.Price = 0;
        } else { 
            if(isTaxIncludingPricing && String.isBlank(coLineItemObj.Deal__c)) {
                this.Price = (coLineItemObj.Price_When_Tax_Included__c != null) ? (coLineItemObj.Price_When_Tax_Included__c).setScale(2, RoundingMode.HALF_UP) : 
                                                    (coLineItemObj.Price__c * (1 + coLineItemObj.Tax__c /100)).setScale(2, RoundingMode.HALF_UP);
            } else {
                this.Price = coLineItemObj.Price__c.setScale(2, RoundingMode.HALF_UP);
            }
        }
        
        this.SubTotal = (this.Qty * this.Price).setScale(2, RoundingMode.HALF_UP);
        
        if(coLineItemObj.Closed_CO_Invoice_link__c != null) {
            this.Invoice = coLineItemObj.Closed_CO_Invoice_link__c;
        } else {
            this.Invoice = '';
        } 
        
        this.FulfillDate = String.valueOf(system.today());
        if(coLineItemObj.Id != null) {
            this.CoLineItemId = coLineItemObj.Id;
        }
        this.PartId = coLineItemObj.Part__c;
        this.isSpecialOrder = coLineItemObj.Special_Order__c;
        this.Tax = coLineItemObj.Tax__c;
        this.Retail = (coLineItemObj.Retail__c != null) ? coLineItemObj.Retail__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
        this.AvaliablePartsQty = coLineItemObj.Part__r.AvailableParts__c;
        
        this.VOStatus = coLineItemObj.VO_Status__c;
        this.POStatus = coLineItemObj.Vendor_Order_Header__r.Status__c;
        this.VONumber = coLineItemObj.VO_Number__c;
        if(coLineItemObj.Expected_Delivery_Date__c != null) {
            this.ExpectedDeliveryDate = BPUtility.getFormatedDateTime(datetime.newInstance(coLineItemObj.Expected_Delivery_Date__c.year(), coLineItemObj.Expected_Delivery_Date__c.month(), coLineItemObj.Expected_Delivery_Date__c.day()));
        }
        this.VOHeaderList = new List<VOHeader>();
        
        this.FeeId = coLineItemObj.Fee__c;
        
        this.EntityType = (coLineItemObj.Part__c != null) ? 'Part' : (coLineItemObj.Is_Environmental_Fee__c ? 'Env Fee' : (coLineItemObj.Fee__c != null ? 'Fee' : ''));
        this.IsFixedPrice = (coLineItemObj.Fixed_Price__c == null) ? false : coLineItemObj.Fixed_Price__c;
        if(coLineItemObj.Part__c != null) {
            this.NonInventoryPart = coLineItemObj.Part__r.Non_Inventory_Part__c;
            this.IsNonInventoryPart = coLineItemObj.Part__r.Non_Inventory_Part__c;
            if(coLineItemObj.Part__r.Vendor__c != null) {
                this.VendorId = coLineItemObj.Part__r.Vendor__c;    
            }
        }
        this.DealId = coLineItemObj.Deal__c;
        this.ActualKitPrice = (coLineItemObj.Actual_Kit_Price__c != null) ? coLineItemObj.Actual_Kit_Price__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
        this.IsFixedPriceForCO = coLineItemObj.CO_Fixed_KitLineItem__c;
        this.QtyOrder = (this.Qty != null && this.QtyCommitted != null) ? (this.Qty < 0 ? null :(this.Qty - this.QtyCommitted)) : 0;
        if(this.QtyOrder == null) {
            this.QtyCommitted = null;
        }
        
        this.StockCommitedCpy = this.QtyCommitted ;
        this.QtyCpy = this.Qty;
        this.OversoldQty = coLineItemObj.Oversold_Qty__c;
        if(this.EntityType == 'Part' && (this.IsNonInventoryPart == null || this.IsNonInventoryPart == false)) {
            this.ActualAvailableParts = ((this.AvaliablePartsQty != null ? this.AvaliablePartsQty : 0) + (this.QtyCommitted != null ? this.QtyCommitted : 0) - (this.OversoldQty != null ? this.OversoldQty : 0));
        }
        this.IsBRPPart = coLineItemObj.Part__r != null ? BRPUtility.getAllBRPVendorsIdSet().contains(coLineItemObj.Part__r.Vendor__c): false;
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: COLineItem - Class Object
    **/
    public static COLIWrapper parse(String json) {
        return (COLIWrapper) System.JSON.deserialize(json, COLIWrapper.class);
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> COLineItemFields = new List<String>{   'Id',
                                                            'Name', 
                                                            'CO_Header__c',
                                                            'CO_Header__r.Name',
                                                            'CO_Header__r.Customer__c',
                                                            'CO_Header__r.CO_Type__c',
                                                            'CO_Header__r.Customer__r.Name',
                                                            'CO_Header__r.Customer_Name__c',
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
                                                            'Part__r.Non_Inventory_Part__c',
                                                            'Deal__c',
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
                                                            'Status__c',
                                                            'Option_Fee__c',
                                                            'Related_Option_And_Fees__c',
                                                            'Vendor_Order_Header__c',
                                                            'Vendor_Order_Header__r.Status__c',
                                                            'Actual_Retail_Price__c',
                                                            'Price_When_Tax_Included__c',
                                                            'CO_Status__c',
                                                            'Merchandise_Commit_Order_controls__c',
                                                            'Is_In_Merch_Section__c',
                                                            'Is_Environmental_Fee__c'
                                                    };
        return COLineItemFields;
    }
    
    public static List<String> individualTaxFieldsList(){
        List<String> individualTaxFields = new List<String>{'Id',
                                                            'CO_Line_Item__c', 
                                                            'Tax_Rate__c',
                                                            'Form_Label__c',
                                                            'Sales_Tax_Item_Name__c',
                                                            'Taxable_Amount__c',
                                                            'Tax_Amount__c'
                                                    };
        return individualTaxFields;
    }
    
    public class VOHeader{ 
        
        public String VOHeaderId;
        public String VOHeaderName;
        
        public VOHeader(Vendor_Order_Header__c voHeaderRec) {
            this.VOHeaderId = voHeaderRec.Id;
            this.VOHeaderName = voHeaderRec.Name;
        }
    }
}