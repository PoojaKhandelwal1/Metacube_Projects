public with sharing class ReturnVOHeaderWrapper {
   
   public String Id {get;private set;}
   public String Name {get;private set;}
   public String VendorId {get;private set;}
   public String VendorName {get;private set;}
   public String Status {get;private set;}
   public String ReturnedDate {get;private set;}
   public String CreatedDate {get;private set;}
   public String SubmittedDate {get;private set;}
   public String RMANumber {get;private set;}
   public String CreditMemoNumber {get;private set;}
   public Decimal SubTotal {get;private set;}
   public Decimal Tax {get;private set;}
   public Decimal Total {get;private set;}
   public String OwnerName {get;private set;}
   public List<ReturnVoLineItemWrapper> ReturnVOLIList {get;private set;}
   
    
    public ReturnVOHeaderWrapper(Return_VO_Header__c returnVOHeaderRec){
    	this.Id = returnVOHeaderRec.Id;
    	this.Name = returnVOHeaderRec.Name;
    	this.VendorId = returnVOHeaderRec.Vendor__c != null ? returnVOHeaderRec.Vendor__c : '';
    	this.VendorName = returnVOHeaderRec.Vendor__r.Name != null ? returnVOHeaderRec.Vendor__r.Name : '';
    	this.Status = returnVOHeaderRec.Status__c;
    	this.ReturnedDate = returnVOHeaderRec.Returned_Date__c != null ? BPUtility.getFormatedDateTime(datetime.newInstance(returnVOHeaderRec.Returned_Date__c.year(), returnVOHeaderRec.Returned_Date__c.month(), returnVOHeaderRec.Returned_Date__c.day())) : BPUtility.getFormatedDateTime(System.Now());
    	this.SubmittedDate = returnVOHeaderRec.Submitted_Date__c != null ? BPUtility.getFormatedDateTime(datetime.newInstance(returnVOHeaderRec.Submitted_Date__c.year(), returnVOHeaderRec.Submitted_Date__c.month(), returnVOHeaderRec.Submitted_Date__c.day())) : '';
    	this.CreatedDate = returnVOHeaderRec.CreatedDate != null ? BPUtility.getFormatedDateTime(returnVOHeaderRec.CreatedDate) : '';
    	this.RMANumber = returnVOHeaderRec.RMA__c ;
    	this.CreditMemoNumber = returnVOHeaderRec.Credit_Memo__c ;
    	this.SubTotal = returnVOHeaderRec.SubTotal__c != null ? returnVOHeaderRec.SubTotal__c : 0;
    	this.Tax = returnVOHeaderRec.Tax__c != null ? returnVOHeaderRec.Tax__c : 0;
    	this.Total = returnVOHeaderRec.Return_Total__c != null ? returnVOHeaderRec.Return_Total__c : 0;
    	this.OwnerName = returnVOHeaderRec.owner.name;
    	this.ReturnVOLIList = new List<ReturnVoLineItemWrapper>();
    	
    	
    	for(Return_VO_Line_Item__c returnVOLineItemRec  : returnVOHeaderRec.Return_VO_Line_Items__r){
			this.ReturnVOLIList.add(new ReturnVoLineItemWrapper(returnVOLineItemRec));
		}
    } 
    
    
    
    
    
   public class ReturnVoLineItemWrapper {
   
   	   public String Id {get;private set;}
	   public String Name {get;private set;}
	   public String Item {get;private set;}
	   public String Description {get;private set;}
	   public String ItemDescription {get;private set;}
	   public Decimal ReturnQty {get;private set;}
	   public Decimal ItemCost {get;private set;}
	   public Decimal InventoryCost {get;private set;}
	   public String ReturnVOId {get;private set;}
	   public String PartId {get;private set;}
	   public Decimal partAvailableQty {get;private set;}
	   public String UnitType{get; private set;}
	   
	   public ReturnVoLineItemWrapper(Return_VO_Line_Item__c returnVOLIRec){
	   	this.Id = returnVOLIRec.Id;
	   	this.Name = returnVOLIRec.Name;
	   	this.Item = returnVOLIRec.Item__c;
	   	this.Description = returnVOLIRec.Description__c;
	   	this.ItemDescription = returnVOLIRec.Item_Desc__c;
	   	this.ReturnQty = returnVOLIRec.Return_Qty__c != null ? returnVOLIRec.Return_Qty__c : 0;
	   	this.ItemCost = returnVOLIRec.Item_Cost__c != null ? returnVOLIRec.Item_Cost__c : 0;
	   	this.InventoryCost = returnVOLIRec.Inventory_Cost__c != null ? returnVOLIRec.Inventory_Cost__c : 0;
	   	this.ReturnVOID = returnVOLIRec.Return_VO_Header__c ;
	   	this.PartId = returnVOLIRec.Part__c ;
	   	this.partAvailableQty = returnVOLIRec.Part__c != null ? returnVOLIRec.Part__r.Qty_In_Stock__c : 0;
	   	this.UnitType = 'EA';
	   	if(String.isBlank(returnVOLIRec.Part__r.Package_Unit__c) && returnVOLIRec.Part__r.Packaged_Part__c){
    		this.UnitType = 'PKG';
    	}else{
    		this.UnitType = returnVOLIRec.Part__r.Package_Unit__c;
    	}
	   	
	   }
	   
	}
	
	public static List<String> getReturnVOFieldList(){
        List<String> returnVOFields = new List<String>{ 
        											'Id',
        											'Name',
        											'Vendor__c',
        											'Vendor__r.Name',
        											'Status__c',
        											'CreatedDate',
        											'Returned_Date__c',
        											'Submitted_Date__c',
        											'RMA__c',
        											'Credit_Memo__c',
        											'SubTotal__c',
        											'Tax__c',
        											'Return_Total__c',
        											'Owner.name',
        											'Total__c'
        };
        return returnVOFields;
    }
    
    
    public static List<String> getReturnVOLIFieldList(){
        List<String> returnVOLIFields = new List<String>{ 
        											'Id',
        											'Name',
        											'Item__c',
        											'Description__c',
        											'Item_Desc__c',
        											'Return_Qty__c',
        											'Item_Cost__c',
        											'Inventory_Cost__c',
        											'Return_VO_Header__c',
        											'Part__c',
        											'Part__r.Qty_In_Stock__c',
        											'Part__r.Package_Unit__c',
        											'Part__r.Packaged_Part__c'
        };
        
        return returnVOLIFields;
    }
}