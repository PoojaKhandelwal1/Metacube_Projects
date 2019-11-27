/**
 * Author: Tarun Khandelwal
 * Since: April 9, 2014
 * Name: COHeader
 * Description: Used to convert COHeader serialize and deserialize operations
**/
public with sharing class COHeader { 
    
    // Customer Id 
    public String CustomerId {get; set;}
    
    // Customer Name
    public String CustomerName {get; set;}
    
    // Customer Store Credit
    public Decimal CustomerStoreCredit {get; set;}
    
    // COHeader Id
    public String COHeaderId{get; set;}
    
    // Assignee
    public String Assignee{get; set;}
    
    // Assignee Name
    public String AssigneeName{get; set;}
    
    //Order Status
    public String OrderStatus{get; set;}
    
    // Owner
    public String Owner{get; set;}
    
    // Owner Name
    public String OwnerName{get; set;}
    
    // Order Name
    public String OrderName{get; set;}
    
    //Promised By
    public String PromisedBy;
    
    // Created Date
    public String CreatedDate;
    
    // Modified Date
    public String ModifiedDate;
    
    // CO Type
    public String COType;
    
    public String SellingGroup;

	public Boolean HideMerchandiseSection;// Added by Kajal - 14th june 2017 #2344
	
    public Decimal OrderTotal;
    public Decimal InvoicedAmount;
    public Decimal UninvoicedAmount;
    public Decimal TotalPayments;
    public Decimal TotalBalanceDue;
    // Constructor
    public COHeader(CO_Header__c coHeaderObj) {
        this.CustomerId = coHeaderObj.Customer__c;
        if(coHeaderObj.CO_Type__c == Constants.CASH_SALE){
			this.CustomerName = Constants.CASH_SALE;
		} else if(coHeaderObj.CO_Type__c == Constants.INTERNAL_SERVICE){
			this.CustomerName = Constants.UNIT_INVENTORY.toLowerCase().capitalize();
		} else {
			this.CustomerName = coHeaderObj.Customer__r.Name;
		}
		this.CustomerStoreCredit = 0;
		if(coHeaderObj.Customer__r.Total_Store_Credit__c != null){
			this.CustomerStoreCredit = coHeaderObj.Customer__r.Total_Store_Credit__c;
		}
        this.COHeaderId = coHeaderObj.Id;
        this.Assignee = coHeaderObj.Assignee__c;
        this.AssigneeName = coHeaderObj.Assignee__r.Name;
        this.OrderStatus = coHeaderObj.Order_status__c;
        this.Owner = coHeaderObj.Owner__c;
        this.OwnerName = coHeaderObj.Owner__r.Name;
        if(this.Owner == null) {
            this.Owner = '';
        }
        this.OrderName = coHeaderObj.Name;
        this.PromisedBy = (datetime.newInstance(coHeaderObj.CreatedDate.year(), coHeaderObj.CreatedDate.month(), coHeaderObj.CreatedDate.day() + 5)).format('MMMM dd, yyyy');
        this.CreatedDate = BPUtility.getExtendedDateFormat(coHeaderObj.CreatedDate);
        this.ModifiedDate = BPUtility.getExtendedDateFormat(coHeaderObj.LastModifiedDate);
        this.COType = coHeaderObj.CO_Type__c;
        this.SellingGroup = coHeaderObj.Selling_Group__c;
        this.HideMerchandiseSection = coHeaderObj.Hide_Merchandise_Section__c;// Added by Kajal - 14th june 2017 #2344
        this.OrderTotal = (coHeaderObj.Order_Total__c != null) ? coHeaderObj.Order_Total__c : 0;
        this.InvoicedAmount = (coHeaderObj.Invoiced_Amount__c != null) ? coHeaderObj.Invoiced_Amount__c : 0;
        this.UninvoicedAmount = (coHeaderObj.Uninvoiced_Amount__c != null) ? coHeaderObj.Uninvoiced_Amount__c : 0;
        this.TotalPayments = 0;
        this.TotalBalanceDue = this.InvoicedAmount - this.TotalPayments;
    }
    
    public COHeader(String COHeaderId, String OrderName) {
    	this.COHeaderId = COHeaderId;
    	this.OrderName = OrderName;
    }
    
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> COHeaderFieldList = new List<String>{ 'Id', 
                                                        'Customer__c',
                                                        'Assignee__c',
                                                        'Order_status__c',
                                                        'Owner__c',
                                                        'Customer__r.Name',
                                                        'Customer_Name__c',
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
                                                        'Total_SO__c',
                                                        'Deal_Total__c',
                                                        'NumberOfDeals__c',
                                                        'TotalNumberOfSOHeader__c', 
                                                        'TotalNumberOfCOLI__c',
                                                        'Total_SO_Tax_Amount__c',
                                                        'Total_COLI_Clearfix__c',
                                                        'Uninvoiced_Amount__c',
                                                        'Invoiced_Amount__c',
                                                        'Order_Total__c',
                                                        'Merchandise_Total__c',
                                                        'Hide_Merchandise_Section__c',
                                                        'Deal_Header_Total__c', // BPGlobalHeaderCtrlTest: getActiveCustomerOrdersByIdTest: Added By Pooja 7 Jul 2017
                                                        'Service_Order_Subtotal__c', // BPGlobalHeaderCtrlTest: getActiveCustomerOrdersByIdTest: Added By Pooja 7 Jul 2017
                                                        'Customer__r.Total_Store_Credit__c'
                                                };//Hide_Merchandise_Section__c Added by Kajal - 14th june 2017 #2344
        return COHeaderFieldList;
    }
    
}