/**
 * Author: Hitesh Gupta
 * Since: Aug, 18 2017
 * Name: StoreCredit
 * Description: Apex class to handle JSON related oprations of Related Store Credit entity.
**/
public with sharing class StoreCredit {
    
    public String Id;
    
	public String StoreCreditName;
	
	public String StoreCreditId;
	
    public Decimal Amount;
    
    public String Reference ;
    
	public String createdDate;
    
    public StoreCredit(Store_Credit__c storeCreditRec){
    	this.Id = storeCreditRec.Id;
    	if(storeCreditRec.CO_Invoice_Header__c != null){
    		if(storeCreditRec.CO_Invoice_Header__r.Invoice_Number__c != null){
    			this.StoreCreditName = storeCreditRec.CO_Invoice_Header__r.Invoice_Number__c;
    		}else{ 
    			this.StoreCreditName = storeCreditRec.CO_Invoice_Header__r.CO_Header__r.Name;
    		}
    		
    		this.StoreCreditId = storeCreditRec.CO_Invoice_Header__r.CO_Header__c;
    	} else if(storeCreditRec.CO_Header__c != null) {
    		this.StoreCreditName = storeCreditRec.CO_Header__r.Name;
    		this.StoreCreditId = storeCreditRec.CO_Header__c;
    	}else{
    		this.StoreCreditName = storeCreditRec.Name;
    	}
    	this.Amount = storeCreditRec.Amount__c;
    	this.Reference = storeCreditRec.Reference__c;
    	this.createdDate = BPUtility.getExtendedTimeMonthFormat(storeCreditRec.createdDate);
    }
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsList(){
        List<String> customerStoreCreditFields = new List<String>{ 'Id',
		                                                        'Name',
		                                                        'Amount__c',
		                                                        'CO_Invoice_Header__c',
		                                                        'CO_Invoice_Header__r.Invoice_Number__c',
		                                                        'CO_Invoice_Header__r.CO_Header__c',
		                                                        'CO_Invoice_Header__r.CO_Header__r.Name',
		                                                        'Customer__c',
		                                                        'Reference__c',
		                                                        'createdDate',
		                                                        'CO_Header__r.Name'
		                                                };
        return customerStoreCreditFields;
    }
    
}