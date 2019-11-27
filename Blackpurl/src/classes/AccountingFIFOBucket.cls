/**
 * Author: Richa Mittal
 * Since: Dec 26, 2016
 * Name: AccountingCOInvoicePayment
 * Description: Apex class to handle JSON related oprations of paymrnt of CO Invoice for Accounting.
**/
public with sharing class AccountingFIFOBucket {
    
     public String Id {get; set;}
        
    // SourceName
    public String SourceName {get; set;}
    
    // Reference
    public String Reference {get; set;}
    
    // QtyIn
    public Decimal QtyIn {get; set;}
    
    // QtyOut
    public Decimal QtyOut {get; set;}
    
    // Variance
    public Decimal Variance {get; set;}
    
    // Cost
    public Decimal Cost {get; set;}
    
    // Total
    public Decimal Total {get; set;}
    
    // VRCost
    public Decimal VRCost {get; set;}
    
    // Is FIFO Bucket
    public Boolean IsFIFOBucket {get; set;}
    
    // PartId
    public String PartId;
    
    public String ItemDesc;
    
    public String PartNumber;
    
    // Name
    public String Name;
    
    // Name
    public Date CreatedDate;
    
    public String VendorName;
    
    //EntityRefWrapper
    public EntityRefWrapper EntityRef;
    
    public String COGS_GL;
        
    public String Income_GL;
    
    public String Inventory_GL;
    
    // AccountingId
    public String AccountingId;
    
    // SyncToken
    public String SyncToken;
    
    public String accountingResponse;
    
    public String UniqueId;
    
    // Constructor
    public AccountingFIFOBucket(Part_FIFO_Bucket__c  partFIFOBucketRec) { 
        this.Id = partFIFOBucketRec.Id;
        this.SourceName = partFIFOBucketRec.Source_Name__c != null ? partFIFOBucketRec.Source_Name__c : '';
        String ref = partFIFOBucketRec.Reference__c != null ? partFIFOBucketRec.Reference__c : '';
        if(!ref.equalsIgnoreCase('Count Adjustment') && !ref.equalsIgnoreCase('Cost Adjustment') && this.SourceName.equalsIgnoreCase('Cost Adjust')) {
        	ref = 'Cost Adjustment';
        }
        this.Reference = ref;
        this.QtyIn = partFIFOBucketRec.Qty_In__c;
        this.QtyOut = partFIFOBucketRec.Qty_Out__c;
        this.Variance = partFIFOBucketRec.Variance__c;
        this.Cost = partFIFOBucketRec.Cost__c;
        this.Total = partFIFOBucketRec.Total__c;
        this.VRCost = partFIFOBucketRec.VRCost__c;
        this.IsFIFOBucket = partFIFOBucketRec.Is_FIFO_Bucket__c;
        this.PartId = partFIFOBucketRec.Part__c;
        this.Name = partFIFOBucketRec.Name;
        this.VendorName = partFIFOBucketRec.Part__r.Vendor__r.Name;
        this.ItemDesc = partFIFOBucketRec.Part__r.Part_Number__c + ' - ' + partFIFOBucketRec.Part__r.Description__c;
        this.PartNumber = partFIFOBucketRec.Part__r.Part_Number__c;
        this.CreatedDate = DateTimeUtility.getDateFromFormattedDateStr(DateTimeUtility.getFormttedDateFromDateTime(partFIFOBucketRec.CreatedDate, 'dd/MM/yyyy'));
        
        this.EntityRef = new EntityRefWrapper(partFIFOBucketRec.Part__r.Vendor__r.Vendor_AccountingId__c, partFIFOBucketRec.Part__r.Vendor__r.Name);
        
        this.COGS_GL = partFIFOBucketRec.Part__r.Category__r.COGS_GL__c;
        this.Income_GL = partFIFOBucketRec.Part__r.Category__r.Income_GL__c;
        this.Inventory_GL = partFIFOBucketRec.Part__r.Category__r.Inventory_GL__c;
        
        this.AccountingId = partFIFOBucketRec.AccountingId__c;
        this.SyncToken = partFIFOBucketRec.SyncToken__c;
        this.accountingResponse = partFIFOBucketRec.AccountingResponse__c; 
        
        if(partFIFOBucketRec.Vendor_Invoicing_Header__c!= null){
			this.UniqueId =  partFIFOBucketRec.Vendor_Invoicing_Header__c!= null?partFIFOBucketRec.Vendor_Invoicing_Header__r.Vendor_Invoice_Number__c : null;
		}else if(partFIFOBucketRec.Vendor_Receiving_Header__c != null){
			this.UniqueId =  partFIFOBucketRec.Vendor_Receiving_Header__c!= null?partFIFOBucketRec.Vendor_Receiving_Header__r.Packing_Slip_Number__c : null;
		}else if(partFIFOBucketRec.Customer_Return__c != null){
			this.UniqueId =  (partFIFOBucketRec.Customer_Return__c != null) ? partFIFOBucketRec.Customer_Return__r.Invoice_Number__c : null;
		}else if(partFIFOBucketRec.Source_Name__c.equalsIgnoreCase('Cost Adjust') || partFIFOBucketRec.Source_Name__c.equalsIgnoreCase('Oversold') || partFIFOBucketRec.Source_Name__c.equalsIgnoreCase('Count Adjust') || partFIFOBucketRec.Source_Name__c.equalsIgnoreCase('Stock Count') ){
			this.UniqueId = partFIFOBucketRec.Unique_Id__c;
		}else{
			this.UniqueId = 'Add Part';
		}
    }
    
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> partFIFOBucketFields = new List<String>{ 'Id',
                                                        'Name', 
                                                        'Source_Name__c',
                                                        'Reference__c',
                                                        'Qty_In__c',
            											'Qty_Out__c',
            											'Variance__c',
                                                        'Cost__c',
            											'Total__c',
                                                        'VRCost__c',
                                                        'Is_FIFO_Bucket__c',
                                                        'Part__c',
            											'Part__r.Part_Id__c',
            											'Part__r.Part_Number__c',
            											'Part__r.Description__c',
                                                        'Part__r.Vendor__r.Vendor_AccountingId__c',
                                                        'Part__r.Vendor__r.Name',
            											'Part__r.Category__r.COGS_GL__c',
            											'Part__r.Category__r.Income_GL__c',
            											'Part__r.Category__r.Inventory_GL__c',
                                                        'AccountingId__c',
                                                        'SyncToken__c',
                                                        'AccountingResponse__c',
                                                        'CreatedDate',
                                                        'Vendor_Invoicing_Header__c',
                                                        'Vendor_Invoicing_Header__r.Vendor_Invoice_Number__c',
                                                        'Vendor_Receiving_Header__c',
                                                        'Vendor_Receiving_Header__r.Packing_Slip_Number__c',
                                                        'Customer_Return__c',
                                                        'Customer_Return__r.Invoice_Number__c',
                                                        'Unique_Id__c',
                                                        'Xero_Accounting_Id__c'
                                                     };
        return partFIFOBucketFields;
    }
    
    public class AccountRefWrapper{
        public String Id;
        public String Name;
        
        public AccountRefWrapper(String Id, String Name) {
            this.Id = Id;
            this.Name = Name;
        }
    } 
    
    public class EntityRefWrapper{
        public String AccountingId;
        public String Name;
        
        public EntityRefWrapper(String AccountingId, String Name) {
            this.AccountingId = AccountingId;
            this.Name = Name;
        }
    }
}
