public with sharing class CreateLeadWrapper {
	
	public String dealer_id {get; set;}
   	public String dealer_deal_id {get; set;}
   	public String dealervu_deal_id {get; set;}
    public String date_replaceKey {get; set;}
   	public String time_replaceKey {get; set;}
   	public String timezone {get; set;}
   	public String source {get; set;}
   	public LeadWrapper lead {get; set;}
    
	public CreateLeadWrapper(String dealerId, String dealId, String leadId, Account customer, List<Customer_Owned_Unit__c> unitRecs, List<Customer_Owned_Unit__c> tradeIns) {
		this.dealer_id = dealerId;
		this.date_replaceKey = system.now().format('YYYY-M-dd');
		this.time_replaceKey = system.now().format('HH:mm:ss');
		this.timezone = String.valueOf(UserInfo.getTimeZone());
		this.dealer_deal_id = dealId;
		//this.dealervu_deal_id = dealId;
		this.lead = new LeadWrapper(leadId, customer, unitRecs, tradeIns);
	}
    
    public class LeadWrapper {
    	public String lead_id {get; set;}
    	public String date_replaceKey {get; set;}
      	public String time_replaceKey {get; set;}
      	public String timezone {get; set;}
      	public String lead_type {get; set;}
      	public String sperson_first_name {get; set;}
      	public String sperson_last_name {get; set;}
      	public ContactWrapper contact {get; set;}
      	public List<ProductWrapper> product {get; set;}
      	public List<TradeInWrapper> tradein {get; set;}
      	public String comment {get; set;}
    	
    	public LeadWrapper(String leadId, Account customer, List<Customer_Owned_Unit__c> unitRecs, List<Customer_Owned_Unit__c> tradeins) {
    		this.lead_id = leadId;
    		if(customer != null) {
    			this.contact = new ContactWrapper(customer);
    		}
    		if(unitRecs != null && unitRecs.size() > 0) {
    		    List<ProductWrapper> productRecs = new List<ProductWrapper>();
    		    for(Customer_Owned_Unit__c unitRec : unitRecs) {
    		        productRecs.add(new ProductWrapper(unitRec));
    		    }
    			this.product = productRecs;
    		}
    		if(tradeins != null && tradeins.size() > 0) {
                List<TradeInWrapper> tradeInRecs = new List<TradeInWrapper>();
                for(Customer_Owned_Unit__c unitRec : tradeins) {
                    tradeInRecs.add(new TradeInWrapper(unitRec));
                } 
                this.tradein = tradeInRecs;
            }
    		this.date_replaceKey = system.now().format('YYYY-M-dd');
			this.time_replaceKey = system.now().format('HH:mm:ss');
			this.timezone = String.valueOf(UserInfo.getTimeZone());
    	}
    }
    
    public class ContactWrapper {
    	public String dealervu_customer_id {get; set;}
        public String first_name {get; set;}
        public String middle_name {get; set;}
        public String last_name {get; set;}
        public String email {get; set;}
        public String address1 {get; set;}
        public String address2 {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String county {get; set;}
        public String country {get; set;}
        public String zip {get; set;}
        public String phone {get; set;}
        public String work_number {get; set;}
        public String mobile {get; set;}
        public String fax {get; set;}
        public String dob {get; set;}
    	
    	public ContactWrapper() {
    		
    	}
    	public ContactWrapper(Account customerRec) {
    		
            //this.dealervu_customer_id = '1234';
    		this.first_name = customerRec.FirstName__c;
        	this.last_name = customerRec.LastName__c;
        	
        	String billingStreet = (customerRec.BillingStreet == null ) ? '' : customerRec.BillingStreet;
	        List<String> bsList = billingStreet.split('\n');
	        this.address1 = (bsList.size() > 0) ? bsList[0] : '';
	        this.address2 = (bsList.size() > 1) ? bsList[1] : '';
	        this.city = (customerRec.BillingCity == null) ? '' : customerRec.BillingCity;
	        this.state = (customerRec.BillingState == null) ? '' : customerRec.BillingState;
	        this.country = (customerRec.BillingCountry == null) ? '' : customerRec.BillingCountry;
	        this.zip = (customerRec.BillingPostalCode == null) ? '' : customerRec.BillingPostalCode;
	        
	        this.phone = customerRec.Home_number__c;
	        this.work_number = customerRec.Work_Number__c;
	        this.mobile = customerRec.Mobile__c;
	        
	        this.dob = String.valueOf(customerRec.Birth_Date__c);
	        
	        if(String.isNotBlank(customerRec.Preferred_Email__c)) {
	        	this.email = customerRec.Preferred_Email__c;
	        } else if(String.isNotBlank(customerRec.Email__c)) {
                this.email = customerRec.Email__c;
            } else if(String.isNotBlank(customerRec.Work_Email__c)) {
                this.email = customerRec.Work_Email__c;
            } else if(String.isNotBlank(customerRec.Other_Email__c)) {
                this.email = customerRec.Other_Email__c;
            }
            
            if(String.isNotBlank(customerRec.Preferred_Email__c)) {
	        	this.email = customerRec.Preferred_Email__c;
	        } else if(String.isNotBlank(customerRec.Email__c)) {
                this.email = customerRec.Email__c;
            } else if(String.isNotBlank(customerRec.Work_Email__c)) {
                this.email = customerRec.Work_Email__c;
            } else if(String.isNotBlank(customerRec.Other_Email__c)) {
                this.email = customerRec.Other_Email__c;
            }
    	}
    }
    
    public class ProductWrapper {
    	public String internal_inventory_id {get; set;}
        public String trimid {get; set;}
        public String year {get; set;}
        public String make {get; set;}
        public String model {get; set;}
        public String color {get; set;}
        public String condition {get; set;}
        public String mileage {get; set;}
        public String category_replaceKey {get; set;}
        public String class_replaceKey {get; set;}
        public String vin {get; set;}
        public String price {get; set;}
        public String location {get; set;}
        public String stockno {get; set;}
    	
    	public ProductWrapper(Customer_Owned_Unit__c unitRec) {
    		if(unitRec != null) {
    			this.internal_inventory_id = String.isNotBlank(unitRec.DP360_Inventory_Id__c) ? unitRec.DP360_Inventory_Id__c : null;
	    		//this.trimid = null;
	    		this.year = String.valueOf(unitRec.Year__c);
		    	this.make = unitRec.Unit_Make__r.Name;
	    		this.model = unitRec.Unit_Model__r.Name__c;
	    		this.color = unitRec.Colour__c;
	    		//this.condition = null;
	    		this.mileage = String.valueOf(unitRec.Mileage_Value__c);
	    		this.category_replaceKey = unitRec.Category__r.Name;
	    		//this.class_replaceKey = null;
	    		this.vin = unitRec.VIN_Number__c;
	    		this.price = String.valueOf(unitRec.Total_Price__c);
	    		this.location = unitRec.Location__c;
	    		this.stockno = unitRec.Stock_Id__c;
    		}
    		
    	}
    }
    
    public class TradeInWrapper {
        public String year {get; set;}
        public String make {get; set;}
        public String model {get; set;}
        public String condition {get; set;}
        public String mileage {get; set;}
        public String color {get; set;}
        public String vin {get; set;}
        public Decimal payoff {get; set;}
        public String owedto {get; set;}
        public String accountnumber {get; set;}
        public String category_replaceKey {get; set;}
        public String type_replaceKey {get; set;}
        public String class_replaceKey {get; set;}
        
        
        public TradeInWrapper(Customer_Owned_Unit__c unitRec) {
            if(unitRec != null) {
                this.year = String.valueOf(unitRec.Year__c);
                this.make = unitRec.Unit_Make__r.Name;
                this.model = unitRec.Unit_Model__r.Name__c;
                this.color = unitRec.Colour__c;
                this.mileage = String.valueOf(unitRec.Mileage_Value__c);
                this.category_replaceKey = unitRec.Category__r.Name;
                this.vin = unitRec.VIN_Number__c;
            }
        }
    }
    
    public static List<String> fieldsList() {
        List<String> dealFields = new List<String>{ 'Id',
        												'DP360_Lead_Id__c',
        												'CO_Header__r.Customer__r.Id',
                                                        'CO_Header__r.Customer__r.FirstName__c',
                                                        'CO_Header__r.Customer__r.LastName__c',
                                                        'CO_Header__r.Customer__r.Birth_Date__c',
                                                        
                                                        'CO_Header__r.Customer__r.Email__c',
                                                        'CO_Header__r.Customer__r.Other_Email__c',
                                                        'CO_Header__r.Customer__r.Preferred_Email__c',
                                                        'CO_Header__r.Customer__r.Work_Email__c',
                                                        
                                                        'CO_Header__r.Customer__r.BillingStreet',
                                                        'CO_Header__r.Customer__r.BillingCity',
                                                        'CO_Header__r.Customer__r.BillingState',
                                                        'CO_Header__r.Customer__r.BillingCountry',
                                                        'CO_Header__r.Customer__r.BillingPostalCode',
                                                        
                                                        'CO_Header__r.Customer__r.Home_Number__c',
                                                        'CO_Header__r.Customer__r.Work_Number__c',
                                                        'CO_Header__r.Customer__r.Mobile__c',
                                                        
                                                        '(Select Id',
                                                        'Type__c',
                                                        'Customer_Owned_Unit__c',
	                                                    'Customer_Owned_Unit__r.Unit_Make__r.Name',
	                                                    'Customer_Owned_Unit__r.Unit_Model__r.Name__c',
	                                                    'Customer_Owned_Unit__r.Colour__c',
	                                                    'Customer_Owned_Unit__r.Year__c',
	                                                    'Customer_Owned_Unit__r.VIN_Number__c',
                                                        'Customer_Owned_Unit__r.Unit_Number__c',
                                                        'Customer_Owned_Unit__r.Mileage_Value__c',
                                                        'Customer_Owned_Unit__r.Mileage_Type__c',
                                                        'Customer_Owned_Unit__r.Total_Price__c',
                                                        'Customer_Owned_Unit__r.Location__c',
                                                        'Customer_Owned_Unit__r.Stock_Id__c',
                                                        'Customer_Owned_Unit__r.DP360_Inventory_Id__c',
                                                        'Customer_Owned_Unit__r.Category__r.Name from Deal_Items__r)'
                                                        //'CO_Header__r.Customer__r.Preferred_Phone__c'
                                                };
        return dealFields;
    }
    
}