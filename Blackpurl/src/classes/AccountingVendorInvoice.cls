/**
 * Author: Pooja Khandelwal
 * Since: Jan. 6, 2017
 * Name: AccountingVendorInvoice
 * Description: Tempalate class for Accounting Vendor Invoice ((QB Integration))
**/ 
public with sharing class AccountingVendorInvoice {
    
    public AccountingVIHeader AccountingVIHeaderRec;
    public List<AccountingVIGroup> AccountingVIGroupsList;
    public List<OtherChargesWrapper> AccountingOtherChargesList;
    public List<AccountingFIFOBucket> AccountingPartFIFOBucketList;
    public VendorWrapper vendor;
	public AccountRefWrapper AccountRef1;
	public List<AccountingPurchaseTax> AccountingPurchaseTaxList;
	public String AppliedQBTaxCode;
    public Decimal AppliedTaxRate;
    public AccountingVendorInvoice(Vendor_Invoicing_Header__c VIHeaderRec, List<Vendor_Invoicing_Group__c> VIGroupsList, List<Part_FIFO_Bucket__c> PartFIFOBucketList) {
        this.AccountingVIHeaderRec = new AccountingVIHeader(VIHeaderRec);
        this.AccountingVIGroupsList = new List<AccountingVIGroup>();
        for(Vendor_Invoicing_Group__c VIGroupRec : VIGroupsList) {
            this.AccountingVIGroupsList.add(new AccountingVIGroup(VIGroupRec)); 
        }
         
        this.AccountingOtherChargesList = new List<OtherChargesWrapper>(); 
        for(Other_Charges__c otherCharge : VIHeaderRec.Other_Charges__r) {
            this.AccountingOtherChargesList.add(new OtherChargesWrapper(otherCharge));
        }
        
        this.AccountingPartFIFOBucketList = new List<AccountingFIFOBucket>();
        for(Part_FIFO_Bucket__c PartFIFOBucketRec : PartFIFOBucketList) {
            this.AccountingPartFIFOBucketList.add(new AccountingFIFOBucket(PartFIFOBucketRec));
        }
        this.vendor = new VendorWrapper(VIHeaderRec);
        this.AccountRef1 = new AccountRefWrapper(AccountingUtil.getChartofAccount('A/P Inventory Accrual'));
        
        Id purchaseTaxId = VIHeaderRec.Vendor__r.Purchase_Tax__r.Id;
        this.AppliedQBTaxCode = VIHeaderRec.Vendor__r.Purchase_Tax__r.Accounting_Id__c;
        this.AppliedTaxRate = VIHeaderRec.Vendor__r.Purchase_Tax__r.Rate__c;
        this.AccountingPurchaseTaxList = new List<AccountingPurchaseTax>();
        if(purchaseTaxId != null) {
            if(AccessControl.ifObjectFieldIsCreateable('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            List<Applicable_Taxes__c> applicableTaxList = [Select Name, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__r.AccountingId__c,
                            Sales_Tax_Item__r.Category__r.Income_GL__c from Applicable_Taxes__c where Sales_Tax__c =: purchaseTaxId];
            for(Applicable_Taxes__c ApplicableTaxRec : applicableTaxList) {
	            this.AccountingPurchaseTaxList.add(new AccountingPurchaseTax(ApplicableTaxRec));
	        }
        }
    }
    
    public AccountingVendorInvoice(Vendor_Invoicing_Header__c VIHeaderRec, List<Vendor_Invoicing_Group__c> VIGroupsList, List<Part_FIFO_Bucket__c> PartFIFOBucketList, List<Other_Charges__c> otherChargesList) {
        this.AccountingVIHeaderRec = new AccountingVIHeader(VIHeaderRec);
        this.AccountingVIGroupsList = new List<AccountingVIGroup>();
        for(Vendor_Invoicing_Group__c VIGroupRec : VIGroupsList) {
            this.AccountingVIGroupsList.add(new AccountingVIGroup(VIGroupRec)); 
        }
         
        this.AccountingOtherChargesList = new List<OtherChargesWrapper>();
        for(Other_Charges__c otherCharge : otherChargesList) {
            this.AccountingOtherChargesList.add(new OtherChargesWrapper(otherCharge));
        }
        
        this.AccountingPartFIFOBucketList = new List<AccountingFIFOBucket>();
        for(Part_FIFO_Bucket__c PartFIFOBucketRec : PartFIFOBucketList) {
            this.AccountingPartFIFOBucketList.add(new AccountingFIFOBucket(PartFIFOBucketRec));
        }
        this.vendor = new VendorWrapper(VIHeaderRec.Vendor__r.Vendor_AccountingId__c, VIHeaderRec.Vendor__r.Name);
        this.AccountRef1 = new AccountRefWrapper(AccountingUtil.getChartofAccount('A/P Inventory Accrual'));
        
        Id purchaseTaxId = VIHeaderRec.Vendor__r.Purchase_Tax__r.Id;
        this.AppliedQBTaxCode = VIHeaderRec.Vendor__r.Purchase_Tax__r.Accounting_Id__c;
        this.AppliedTaxRate = VIHeaderRec.Vendor__r.Purchase_Tax__r.Rate__c;
        this.AccountingPurchaseTaxList = new List<AccountingPurchaseTax>();
        if(purchaseTaxId != null) {
            if(AccessControl.ifObjectFieldIsCreateable('Applicable_Taxes__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            List<Applicable_Taxes__c> applicableTaxList = [Select Name, Sales_Tax_Item__r.Name__c, Sales_Tax_Item__r.Rate__c, Sales_Tax_Item__r.AccountingId__c,
                            Sales_Tax_Item__r.Category__r.Income_GL__c from Applicable_Taxes__c where Sales_Tax__c =: purchaseTaxId];
            for(Applicable_Taxes__c ApplicableTaxRec : applicableTaxList) {
                this.AccountingPurchaseTaxList.add(new AccountingPurchaseTax(ApplicableTaxRec));
            }
        }
    }
    
    public static Map<String, Set<String>> objectToFieldMap = new Map<String, Set<String>>{
        'VIHeader'      => new Set<String>{
                                            'Id',
                                            'Name',
                                            'Vendor__r.Name',
                                            'Vendor__c',
                                            'Owner__c',
                                            'Owner__r.Name',
                                            'Invoice_Number__c',
                                            'Status__c',
                                            'Invoice_Date__c',
                                            'Vendor__r.Purchase_Tax__r.Rate__c',
                                            'Vendor__r.Purchase_Tax__r.Id',
                                            'Vendor__r.Purchase_Tax__r.Accounting_Id__c',
                                            'Tax_Amount__c',
                                            'Tax_Amount_For_Other_Charges__c',
                                            'Vendor__r.Vendor_AccountingId__c',
                                            'CreatedDate',
                                            'Total__c',
                                            'Total_Other_Charges__c',
                                            'AccountingId__c',
                                            'AccountingResponse__c',
                                            'SyncToken__c',
                                            'Xero_Accounting_Id__c',
                                            'Vendor__r.Xero_Vendor_Accounting_Id__c'
                                         },
          
         'VIGroup'      => new Set<String>{  
                                            'Id',
                                            'Vendor_Invoicing_Header__c',
                                            'Vendor_Receiving_Group__c',
                                            'Vendor_Receiving_Group__r.Sublet__c',
                                            'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Code__c',
                                            'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Description__c',
                                            
                                            'Vendor_Receiving_Group__r.Sublet__r.Category__r.AccountingId__c',
                                            'Vendor_Receiving_Group__r.Sublet__r.Category__r.Name',
											'Vendor_Receiving_Group__r.Sublet__r.Category__r.COGS_GL__c',
             								'Vendor_Receiving_Group__r.Sublet__r.Category__r.Income_GL__c',
             								'Vendor_Receiving_Group__r.Sublet__r.Category__r.Inventory_GL__c',
             								
                                            'Vendor_Receiving_Group__r.Part__c',
                                            'Vendor_Receiving_Group__r.Part__r.Part_ID__c',
                                            'Vendor_Receiving_Group__r.Part__r.Part_Number__c',
                                            'Vendor_Receiving_Group__r.Part__r.Packaged_Part__c', 
                                            'Vendor_Receiving_Group__r.Part__r.Package_Qty__c',
                                            'Vendor_Receiving_Group__r.Part__r.Package_Unit__c',
                                            'Vendor_Receiving_Group__r.Part__r.Order_Lots__c',
                                            'Vendor_Receiving_Group__r.Part__r.Description__c',
                                            'Vendor_Receiving_Group__r.Vendor_Receiving_Header__r.Packing_Slip_Number__c',
                                            'Vendor_Receiving_Group__r.Recieved__c',
                                            'Vendor_Receiving_Group__r.Cost__c',
                                            'VI_Cost__c',
                                            'VI_Discount__c',
                                            'VI_Qty__c',
                                            'VI_SubTotal__c',
                                            'PO_Type__c',
                                            'PO_Type__r.Landed_Cost_Adjustment__c',
                                            'Packaged_Unit__c',
                                            'Vendor_Receiving_Group__r.Part__r.Category__r.AccountingId__c',
                                            'Vendor_Receiving_Group__r.Part__r.Category__r.Name',
											'Vendor_Receiving_Group__r.Part__r.Category__r.COGS_GL__c',
             								'Vendor_Receiving_Group__r.Part__r.Category__r.Income_GL__c',
             								'Vendor_Receiving_Group__r.Part__r.Category__r.Inventory_GL__c',
                                            'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Service_Order_Header__r.Invoice_Number__c',
             								'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Service_Order_Header__r.Invoice_Number__r.Invoice_Date__c'
                                        },
                                        
		'OtherCharges' => new Set<String>{
											'Name',
											'Item_Desc__c',
											'Item_Code__c',
											'Fee__c',
											'Item_Description__c',
											'Cost__c',
											'Fee__r.Category__r.Income_GL__c',
											'Notes__c',
                                            'Is_Taxable__c',
                                            'Vendor_Invoicing_Header__c'      
                                        }
         };
         
    /**
     * Name: AccountingVIHeader
     * Description: Accounting Vendor Invoice Header  class
    **/
    public class AccountingVIHeader {
        
        public String VendorName;
        public String VendorId;
        public String OwnerName;
        public String OwnerId;
        public String Status;
        public String InvoiceNumber;
        public Date InvoiceDate;
        public String VIHeaderId;
        public String VIHeaderNumber;
        
        public String AccountingId;
        public String SyncToken;
        public String AccountingResponse;
        public Date CreatedDate;
        public DateTime InvoicedDateTime;
        public Decimal TotalAmt;
        public Decimal TotalPartSubtotal;
        public Decimal TotalOtherChargeSubtotal;
        public String JournalEntryAccountingId;
        public String JournalEntrySyncToken;
        public String JournalEntryAccountingResponse;
        
         /**
         * Name: AccountingVIHeader
         * Desc: Constructor
         * @param:  (1) VIHeaderRec - Vendor_Invoicing_Header__c -  Vendor Invoice Header Record
         * @return: 
         **/
        public AccountingVIHeader(Vendor_Invoicing_Header__c VIHeaderRec) {
            
            this.VendorName = VIHeaderRec.Vendor__r.Name;
            this.VendorId = VIHeaderRec.Vendor__c;
            this.OwnerName = VIHeaderRec.Owner__r.Name;
            this.OwnerId = VIHeaderRec.Owner__c;
            this.Status = VIHeaderRec.Status__c;
            this.InvoiceNumber = (VIHeaderRec.Invoice_Number__c != null && VIHeaderRec.Invoice_Number__c.length() > 21) ? 
                                    VIHeaderRec.Invoice_Number__c.substring(0, 21) : VIHeaderRec.Invoice_Number__c; // 21 limit of field in QB to which this variable is binded
            if(VIHeaderRec.Invoice_Date__c != null) {
                this.InvoiceDate = VIHeaderRec.Invoice_Date__c; 
                //(datetime.newInstance(VIHeaderRec.Invoice_Date__c.year(), VIHeaderRec.Invoice_Date__c.month(), VIHeaderRec.Invoice_Date__c.day())).format('MM/dd/YYYY');
            }
            this.VIHeaderId = VIHeaderRec.Id;
            this.VIHeaderNumber = VIHeaderRec.Name;
            this.AccountingId = VIHeaderRec.AccountingId__c;
            this.SyncToken = VIHeaderRec.SyncToken__c;
            this.AccountingResponse = VIHeaderRec.AccountingResponse__c;
            this.CreatedDate = VIHeaderRec.CreatedDate.date();
            this.InvoicedDateTime = VIHeaderRec.Invoice_Date__c;
            this.TotalAmt = (VIHeaderRec.Total__c != null ? VIHeaderRec.Total__c : 0) + 
                            (VIHeaderRec.Total_Other_Charges__c != null ? VIHeaderRec.Total_Other_Charges__c : 0);
        	this.TotalPartSubtotal = (VIHeaderRec.Total__c != null ? VIHeaderRec.Total__c : 0);
            this.TotalOtherChargeSubtotal = (VIHeaderRec.Total_Other_Charges__c != null ? VIHeaderRec.Total_Other_Charges__c : 0);
        }
    }
    
    /**
     * Name: AccountingVIGroup
     * Description: Vendor Invoice Group Class
    **/
   public class AccountingVIGroup {
        
        public String ItemDesc;
        public String PackingNumber;
        public Decimal ReceivingQty;
        public Decimal ReceivingCost;
        public Decimal InvoiceQty;
        public Decimal InvoiceCost;
        public Decimal Discount;
        public Decimal SubTotal;
        public String VIGroupId;
        public String OrderType;
        public String PackageUnit;
        public Decimal PackageQty;
        public Decimal DiscountAmout;
        public Decimal LcaAmount;
        public String PartId;
        public String SubletId;
       
        public Decimal InvoiceTotalQty;
        public Decimal InvoiceCostMinusDiscount;
        public CategoryWrapper categoryRef;
		public String COGS_GL;
        public String Income_GL;
        public String Inventory_GL;
        
        public Boolean IsReceivingGroupSOLIInvoiced;
        public DateTime ReceivingGroupSOLIInvoicedDateTime; 

         /**
         * Name: VIGroup
         * Desc: Constructor
         * @param:  (1) VIGroupRec - Vendor_Invoicing_Group__c -  Vendor Invoice Group Record
         * @return: 
         **/
        public AccountingVIGroup(Vendor_Invoicing_Group__c VIGroupRec) {
            
            if(VIGroupRec.Vendor_Receiving_Group__r.Part__c != null) {
            	this.ItemDesc = VIGroupRec.Vendor_Receiving_Group__r.Part__r.Part_Number__c + ' - ' + VIGroupRec.Vendor_Receiving_Group__r.Part__r.Description__c; // Changed By Pooja 11 Jan 2017: Part_ID__c  -> Part_Number__c
            	
            	this.categoryRef = new CategoryWrapper(VIGroupRec.Vendor_Receiving_Group__r.Part__r.Category__r.AccountingId__c, VIGroupRec.Vendor_Receiving_Group__r.Part__r.Category__r.Name);
            	this.COGS_GL = VIGroupRec.Vendor_Receiving_Group__r.Part__r.Category__r.COGS_GL__c; // Added 17 Jan. 2017
	            this.Income_GL = VIGroupRec.Vendor_Receiving_Group__r.Part__r.Category__r.Income_GL__c; // Added 17 Jan. 2017
	            this.Inventory_GL = VIGroupRec.Vendor_Receiving_Group__r.Part__r.Category__r.Inventory_GL__c; // Added 17 Jan. 2017
            
            } else if(VIGroupRec.Vendor_Receiving_Group__r.Sublet__c != null) {
            	String code = (VIGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Code__c != null) ? 
            			VIGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Code__c : '';
            			
            	String description = (VIGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Description__c != null) ? 
            			VIGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Description__c : '';
            	this.ItemDesc = (code + ((code.length() > 0 && description.length() > 0) ? ' - ' : '') + description);
            	
            	this.categoryRef = new CategoryWrapper(VIGroupRec.Vendor_Receiving_Group__r.Sublet__r.Category__r.AccountingId__c, VIGroupRec.Vendor_Receiving_Group__r.Sublet__r.Category__r.Name);
            	this.COGS_GL = VIGroupRec.Vendor_Receiving_Group__r.Sublet__r.Category__r.COGS_GL__c;
	            this.Income_GL = VIGroupRec.Vendor_Receiving_Group__r.Sublet__r.Category__r.Income_GL__c;
	            this.Inventory_GL = VIGroupRec.Vendor_Receiving_Group__r.Sublet__r.Category__r.Inventory_GL__c;
            }
            
            this.PackingNumber = VIGroupRec.Vendor_Receiving_Group__r.Vendor_Receiving_Header__r.Packing_Slip_Number__c;
            this.ReceivingQty = VIGroupRec.Vendor_Receiving_Group__r.Recieved__c;
            this.ReceivingCost = (VIGroupRec.Vendor_Receiving_Group__r.Cost__c != null) ? VIGroupRec.Vendor_Receiving_Group__r.Cost__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            this.InvoiceCost = (VIGroupRec.VI_Cost__c != null) ? VIGroupRec.VI_Cost__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            this.Discount = VIGroupRec.VI_Discount__c;
            this.SubTotal = (VIGroupRec.VI_SubTotal__c != null) ? VIGroupRec.VI_SubTotal__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            this.VIGroupId = VIGroupRec.Id;
            if(VIGroupRec.VI_Cost__c == null || this.ReceivingQty == null || this.Discount == null) {
                this.DiscountAmout = 0.00;
            } else {
                this.DiscountAmout = ((VIGroupRec.VI_Cost__c * this.ReceivingQty * this.Discount) / 100).setScale(2, RoundingMode.HALF_UP);
            }
            
            this.OrderType = '';
            if(VIGroupRec.Vendor_Receiving_Group__r.Part__c != null) {
	            if(VIGroupRec.Vendor_Receiving_Group__r.Part__r.Packaged_Part__c) {
	                this.ReceivingQty = this.ReceivingQty / VIGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c;
	                this.OrderType = 'Ordered as ' + VIGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c + '/' + VIGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Unit__c;
	                if(VIGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c > 1) {
	                    this.OrderType += ' in Lots of ' + VIGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c;
	                }
	            } else if(VIGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c > 1) {
	                this.OrderType += 'Ordered as in Lots of ' + VIGroupRec.Vendor_Receiving_Group__r.Part__r.Order_Lots__c;
	            }
            }
            this.InvoiceQty = this.ReceivingQty;
            this.PackageUnit = VIGroupRec.Vendor_Receiving_Group__r.Part__c != null ? VIGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Unit__c : 'EA';
            this.PackageQty = (VIGroupRec.Vendor_Receiving_Group__r.Part__c != null ? VIGroupRec.Vendor_Receiving_Group__r.Part__r.Package_Qty__c : 1);
            this.LcaAmount = VIGroupRec.PO_Type__r.Landed_Cost_Adjustment__c;
            this.PartId = VIGroupRec.Vendor_Receiving_Group__r.Part__c;
            this.SubletId = VIGroupRec.Vendor_Receiving_Group__r.Sublet__c;
            this.InvoiceTotalQty = (VIGroupRec.VI_Qty__c != null) ? VIGroupRec.VI_Qty__c.setScale(2, RoundingMode.HALF_UP) : 0.00 ; // Added By Pooja 11 Jan 2017 Changed by richa 16/01/2016
            this.InvoiceCostMinusDiscount = this.InvoiceCost - (((this.InvoiceCost * this.Discount) / 100).setScale(2, RoundingMode.HALF_UP)); // Added By Pooja 11 Jan 2017
            
            this.IsReceivingGroupSOLIInvoiced = VIGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__c != null 
                                                    && VIGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Service_Order_Header__r.Invoice_Number__c != null;
            this.ReceivingGroupSOLIInvoicedDateTime = this.IsReceivingGroupSOLIInvoiced ? (VIGroupRec.Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Service_Order_Header__r.Invoice_Number__r.Invoice_Date__c) : System.now();
        
        }
    }
    
     /**
     * Name: VendorWrapper
     * Description: Vendor Class
    **/
    public class VendorWrapper{
        
        public String AccountingId;
        public String Name;
        public String XeroVendorAccountingId;
        
        public VendorWrapper(String AccountingId, String Name) {
            this.AccountingId = AccountingId;
            this.Name = Name;
        }
        
        public VendorWrapper(Vendor_Invoicing_Header__c viHeaderRec) {
            this.AccountingId = viHeaderRec.Vendor__r.Vendor_AccountingId__c;
            this.Name = viHeaderRec.Vendor__r.Name;
            this.XeroVendorAccountingId = viHeaderRec.Vendor__r.Xero_Vendor_Accounting_Id__c;
        }
    }
    
    public class AccountRefWrapper {
        public String AccountingId;
        
        public AccountRefWrapper(String AccountingId) {
            this.AccountingId = AccountingId;
        }
    }
    
    /**
     * Name: CategoryWrapper
     * Description: Category Class
    **/
    public class CategoryWrapper{
        
        public String AccountingId;
        public String Name;
        
        public CategoryWrapper(String AccountingId, String Name) {
            this.AccountingId = AccountingId;
            this.Name = Name;
        }
    }
    
    public class AccountingPurchaseTax {
    	public String SalesTaxName;
    	public Decimal SalesTaxRate;
    	public String CategoyRef;
    	public String QBTaxCodeRef;
        // Constructor
	    public AccountingPurchaseTax(Applicable_Taxes__c  applicableTaxRec) { 
	        this.SalesTaxName = applicableTaxRec.Sales_Tax_Item__r.Name__c;
	        this.SalesTaxRate = applicableTaxRec.Sales_Tax_Item__r.Rate__c;
	        this.CategoyRef = applicableTaxRec.Sales_Tax_Item__r.Category__r.Income_GL__c;
            this.QBTaxCodeRef = applicableTaxRec.Sales_Tax_Item__r.AccountingId__c;
	    }
    }
    
    public class OtherChargesWrapper {
    	public String Name;
    	public String ItemDesc;
    	public String Fee;
    	public String Notes;
    	public Decimal Cost;
    	public String CategoyRef;
    	public Boolean IsTaxable;
        
        public OtherChargesWrapper(Other_Charges__c otherChargesRec) {
            this.Name = otherChargesRec.Name;
            this.ItemDesc = (otherChargesRec.Item_Desc__c != null) ? otherChargesRec.Item_Desc__c : '';
            this.Fee = (otherChargesRec.Fee__c != null) ? otherChargesRec.Fee__c : '';
            this.Notes = (otherChargesRec.Notes__c != null) ? otherChargesRec.Notes__c : '';
            this.Cost = (otherChargesRec.Cost__c != null) ? otherChargesRec.Cost__c.setScale(2, RoundingMode.HALF_UP) : 0.00;
            this.CategoyRef = otherChargesRec.Fee__r.Category__r.Income_GL__c;
            this.IsTaxable = otherChargesRec.Is_Taxable__c;
        }
    }
    
    public class TaxRateComponent {
        public Decimal TaxAmount;
        public Decimal TaxableAmount;
        public String TaxRateAcctId;
        public Decimal TaxRatePercent;
        public TaxRateComponent(Decimal taxAmount, Decimal taxableAmount, String acctId, Decimal taxPercent) {
            this.TaxAmount = (taxAmount != null) ? taxAmount : 0;
            this.TaxableAmount = taxableAmount;
            this.TaxRateAcctId = acctId;
            this.TaxRatePercent = taxPercent;
        }
    }
}
