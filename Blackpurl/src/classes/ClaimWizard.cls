/**
 * Author: Tarun Khandelwal
 * Since: May 16, 2016
 * Name: ClaimWizard
 * Description: Apex class to handle JSON related oprations of Claim Wizard Screen.
**/
public with sharing class ClaimWizard {
    
    public String ClaimId;
    public String ClaimNumber;
    public String ResponseDate;
    public String Notes;
    public String ClaimDisposition;
    public String SOHeaderId;
    public Decimal Total;
    public String ProviderClaimNumber;
    public Decimal DeductibleAmount;
    public Boolean IsTaxIncludingPricing;
    public List<ClaimLineItem> VarianceLineItemList;
    public List<ClaimLineItem> NonVarianceLineItemList;
    public List<CategoryItem>  InternalCategoryList;
    public String SubmittedDate;
    
    public ClaimWizard(Claim__c claimRec, List<SO_Payment_Role__c> deductibelRecordList, List<Category__c> InternalCategoryList) {
        this.ClaimId = claimRec.Id;
        this.ClaimNumber = (claimRec.Claim_Number__c != null) ? claimRec.Claim_Number__c : claimRec.Name;
        this.ResponseDate = (claimRec.Response_Date__c != null) ? 
                                BPUtility.getFormatedDateTime(datetime.newInstance(claimRec.Response_Date__c.year(), claimRec.Response_Date__c.month(),claimRec.Response_Date__c.day())) 
                                : null;
                                
        this.Notes = claimRec.Notes__c;
        this.ClaimDisposition = claimRec.Claim_Disposition__c;
        this.SOHeaderId = claimRec.Service_Order_Header__c; 
        
        this.VarianceLineItemList = new List<ClaimLineItem>();
        this.NonVarianceLineItemList = new List<ClaimLineItem>();
        this.ProviderClaimNumber = claimRec.Provider_Claim_Number__c;
        for(Claim_Line_Item__c claimLineItemRec : claimRec.Claim_Line_Items__r) {
            if(claimLineItemRec.Is_Variance__c) {
                this.VarianceLineItemList.add(new ClaimLineItem(claimLineItemRec));
            } else {
                this.NonVarianceLineItemList.add(new ClaimLineItem(claimLineItemRec));
            }
        }   
        
        this.IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
        this.InternalCategoryList = new List<CategoryItem>();
        for(Category__c categoryItem  :  InternalCategoryList){
            this.InternalCategoryList.add(new CategoryItem(categoryItem) );
        
        }
        
        this.DeductibleAmount = 0;
        for(SO_Payment_Role__c deductibleRec : deductibelRecordList) {
            this.DeductibleAmount += deductibleRec.Total_Amount__c;
        }
        this.SubmittedDate = (claimRec.CreatedDate != null) ? 
                                BPUtility.getFormatedDateTime(datetime.newInstance(claimRec.CreatedDate.year(), claimRec.CreatedDate.month(),claimRec.CreatedDate.day())) 
                                : BPUtility.getFormatedDateTime(system.now());
          
    }
    
    public class CategoryItem{
        public String Id;
        public String CategoryName; 
        public CategoryItem(Category__c Internalcategory){
            this.Id = Internalcategory.Id;
            this.CategoryName = Internalcategory.Name;
        
        }
    }
    
    public class ClaimLineItem {
        
        public String Id;
        public Decimal ApprovedPrice;
        public Decimal ApprovedQty;
        public Decimal ApprovedSubTotal;
        public Decimal ClaimedPrice;
        public Decimal ClaimedQty;
        public Decimal ClaimedSubtotal;
        public String  ServiceOrderLineItem ;
        public String  SOPaymentRole;
        public String  BillTo;
        public Decimal DeductibleAmount;  
        public Decimal Tax;  
        public Decimal TaxAmount;
        public Decimal Variance;  
        
        /* START: Added By Tarun - #170 - 09/24/2016 */
        public String ItemCode {get; set;}
        public String ItemDescription {get; set;}
      
        public String Itemdesc; 
        public String Total;
        public String Claim;
        public Decimal VarianceQuantity;
        public Decimal VarianceAmount;
        public Boolean IsVariance;
        public String PaymentStatus;
        public Decimal TotalVariance;
        public String Category;
        public String CategoryName;
        public Boolean IsKitLI;
        public String SOLIType;
        public Boolean IsCalculateSupplies;
          
        public ClaimLineItem(Claim_Line_Item__c claimLineItemRec){
            this.Id = claimLineItemRec.Id;
            this.ApprovedPrice = claimLineItemRec.Approved_Price__c !=null ? (claimLineItemRec.Approved_Price__c).setScale(2, RoundingMode.HALF_UP) : 0 ;
            this.ApprovedQty =  claimLineItemRec.Approved_Qty__c !=null ? claimLineItemRec.Approved_Qty__c : 0 ;
            this.ApprovedSubTotal =  claimLineItemRec.Approved_Subtotal__c ;
            this.ClaimedPrice = claimLineItemRec.Claimed_Price__c !=null ? (claimLineItemRec.Claimed_Price__c).setScale(2, RoundingMode.HALF_UP) : 0 ;
            this.ClaimedQty = claimLineItemRec.Claimed_Qty__c !=null ? claimLineItemRec.Claimed_Qty__c : 0 ;
            this.ClaimedSubtotal = claimLineItemRec.Claimed_Subtotal__c;
            
            /* START: Added By Tarun - #170 - 09/24/2016 */
            this.ItemCode = claimLineItemRec.Item_Code__c;
            this.ItemDescription = claimLineItemRec.Item_Description__c;
            this.Itemdesc = this.ItemCode + ' - ' + this.ItemDescription;
            
            //need to update from Parent Soli parts records
            this.ServiceOrderLineItem  = claimLineItemRec.Service_Order_Line_Item__c !=null ? claimLineItemRec.Service_Order_Line_Item__c : null ;
            this.SOPaymentRole  = claimLineItemRec.SO_Payment_Role__c;
            this.Tax = claimLineItemRec.Tax__c;
            this.TaxAmount = claimLineItemRec.Tax_Amount__c != null ? (claimLineItemRec.Tax_Amount__c).setScale(2, RoundingMode.HALF_UP) : 0;
            this.Variance = claimLineItemRec.Variance__c;
            this.Claim = claimLineItemRec.Claim__c;
            this.DeductibleAmount = ((claimLineItemRec.SO_Payment_Role__c != null && claimLineItemRec.SO_Payment_Role__r.Total_Amount__c != null) ? 
                                        (claimLineItemRec.SO_Payment_Role__r.Total_Amount__c).setScale(2, RoundingMode.HALF_UP) : null);
            this.VarianceQuantity = claimLineItemRec.Variance_Qty__c;
            this.VarianceAmount = claimLineItemRec.Variance_Amount__c;
            this.IsVariance = claimLineItemRec.Is_Variance__c; 
            this.BillTo = (String.isNotBlank(claimLineItemRec.Bill_To__c) ? claimLineItemRec.Bill_To__c : ((claimLineItemRec.SO_Payment_Role__c !=null) ? 
                        claimLineItemRec.SO_Payment_Role__r.RecordType.DeveloperName : ((claimLineItemRec.Variance_Qty__c == 0 ) ? Constants.Internal : 'Customer')));
            this.PaymentStatus =( claimLineItemRec.SO_Payment_Role__c !=null ) ? claimLineItemRec.SO_Payment_Role__r.Status__c : null;
            this.TotalVariance = claimLineItemRec.Total_Variance_Amount__c != null ? (claimLineItemRec.Total_Variance_Amount__c).setScale(2, RoundingMode.HALF_UP) : 0;
            this.Category =  claimLineItemRec.Category__c;
            this.CategoryName = claimLineItemRec.Category__r.Name;
            this.IsKitLI = claimLineItemRec.Service_Order_Line_Item__c != null ? (claimLineItemRec.Service_Order_Line_Item__r.Kit_Header_Line_Item__c != null ? true : false) : false;
            this.SOLIType = claimLineItemRec.Service_Order_Line_Item__c != null ? claimLineItemRec.Service_Order_Line_Item__r.Type__c : '';
            if(claimLineItemRec.Service_Order_Line_Item__c != null && claimLineItemRec.Service_Order_Line_Item__r.Labour_Code__c != null) {
                this.IsCalculateSupplies = claimLineItemRec.Service_Order_Line_Item__r.Labour_Code__r.Calculate_Supplies__c;
            }
        }
    }
    
    public static List<String> getClaimFieldsList(){
        List<String> claimsFields = new List<String>{ 'Id',
                                                    'Name',
                                                    'Claim_Number__c',
                                                    'Notes__c',
                                                    'Claim_Disposition__c',
                                                    'Response_Date__c',
                                                    'Service_Order_Header__c',
                                                    'Provider_Claim_Number__c',
                                                    'CreatedDate'
                                                };  
        return claimsFields;
    }
    
    
    public static List<String> getClaimLineItemFieldsList(){
        List<String> claimLineItemFieldList = new List<String>{ 'Id',
                                                            'Approved_Price__c',
                                                            'Approved_Qty__c',
                                                            'Approved_Subtotal__c',
                                                            'Claimed_Price__c',
                                                            'Claimed_Qty__c',
                                                            'Claimed_Subtotal__c',
                                                            'Item_Desc__c',
                                                            'Service_Order_Line_Item__c',
                                                            'SO_Payment_Role__c',
                                                            'Tax__c ',
                                                            'Tax_Amount__c',
                                                            'Variance__c ',
                                                            'Claim__c ',
                                                            'SO_Payment_Role__r.Total_Amount__c',
                                                            'Variance_Qty__c',
                                                            'Variance_Amount__c',
                                                            'Is_Variance__c',
                                                            'SO_Payment_Role__r.RecordType.DeveloperName',
                                                            'SO_Payment_Role__r.Status__c',
                                                            'Total_Variance_Amount__c',
                                                            'Category__c',
                                                            'Category__r.Name',
                                                            'Item_Code__c',
                                                            'Item_Description__c',
                                                            'Service_Order_Line_Item__r.Kit_Header_Line_Item__c',
                                                            'Bill_To__c',
                                                            'Service_Order_Line_Item__r.Type__c',
                                                            'Service_Order_Line_Item__r.Labour_Code__r.Calculate_Supplies__c'
                                                };  
        return claimLineItemFieldList;
    }
}