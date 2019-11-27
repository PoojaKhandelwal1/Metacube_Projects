/**
* Author: Tarun Khandelwal
* Since: Jan 13, 2016
* Name: SOHeaderPrintPreviewCtrl
* Description: Apex class which gives SO Header Info used in Print Preview Page
**/
global with sharing class SOHeaderPrintPreviewCtrl {
	
	public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    
    
    public SOHeaderPrintPreviewCtrl() {
    	Application = GlobalController.GetResourceURL('Application');
    	Application_Images = GlobalController.GetResourceURL('Application_Images');
    	Assests = GlobalController.GetResourceURL('Assests');
    }
	
			    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    private static  List<String> CardfieldsList(){
        List<String> customerFields = new List<String>{ 'Id',
                                                        'Name',
                                                        'FirstName__c',
                                                        'LastName__c',
                                                        'Active__c',
                                                        'Birth_Date__c',
                                                        'Company_Name__c',
                                                        'Facebook__c',
                                                        'Email__c',
                                                        'Home_Number__c',
                                                        'Home_Number_SMS__c',
                                                        'Is_Customer__c',
                                                        'Is_Vendor__c',
                                                        'Job_Title__c',
                                                        'LinkedIn__c',
                                                        'Mobile__c',
                                                        'Mobile_Number_SMS__c', 
                                                        'Nickname__c',
                                                        'Other_Email__c',
                                                        'Preferred_Email__c',
                                                        'Preferred_Phone__c',
                                                        'Preferred_SMS__c',
                                                        'Twitter__c',
                                                        'Type__c',
                                                        'Work_Email__c',
                                                        'Work_Number__c',
                                                        'Work_Number_SMS__c',
                                                        'SA_same_as_BA__c',
                                                        'BillingStreet',
                                                        'BillingCity',
                                                        'BillingState',
                                                        'BillingCountry',
                                                        'BillingPostalCode',
                                                        'ShippingStreet',
                                                        'ShippingCity',
                                                        'ShippingState',
                                                        'ShippingCountry',
                                                        'ShippingPostalCode',
                                                        'LastModifiedDate',
                                                        'Sales_Tax__c',
                                                        'Sales_Tax__r.Name__c',
                                                        'Price_Level__c',
                                                        'Price_Level__r.Name__c',
                                                        'Purchase_Tax__c',
                                                        'Purchase_Tax__r.Name__c',
                                                        'Orders_Lifetime__c',
                                                        'Open_Orders__c',
                                                        'Average_Spend_per_Order__c',
                                                        'Customer_Number__c'
                                                        
                                                        
                                                };
        return customerFields;
    }
    			    /**
     * Name: TaxfieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    private static  List<String> taxExemptionFields(){
      List<String> taxExemptionFields = new List<String>{'Id',
													'Sales_Tax_Item__r.Name__c'
													};
		return 	taxExemptionFields;										  
    }
    
	/**
    * Name: getPrinitngInfo
    * Desc: Method to get json string related to Prinitng Info of Service Header Order
    * @param:  (1) soHeaderId - String - Id of SO Header Record
    * @return: String - JSON String of SO Header Detail Record
    **/
    @RemoteAction 
    global static String getPrinitngInfo(String soHeaderId){
    	soHeaderId = BPUtility.getDecodedString(soHeaderId);
    	List<CO_Header__c> coHeaderRecs = new List<CO_Header__c>();
    	List<Customer_Owned_Unit__c> couRecords = new List<Customer_Owned_Unit__c>();
    	List<Account> customerList = new List<Account>();
    	List<Service_Order_Kit_Header__c> soKitHeaderList = new List<Service_Order_Kit_Header__c>();
    	
    	if(AccessControl.ifObjectFieldIsAccessible('Individual_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	List<Individual_Tax__c> individualTaxList = [select Sales_Tax_Item_Name__c, Tax_Rate__c, Service_Order_Line_Item__c, 		
    														Service_Order_Line_Item__r.Total__c, Service_Order_Line_Item__r.Tax_Percent__c	 		
    														from Individual_Tax__c		
    														where Service_Order_Line_Item__r.Service_Order_Header__c =: soHeaderId];
    	List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => soHeaderId});
    	if(soHeaderRecList.size() == 0) {
    		return BPUtility.getEncodedString('{}');
    	}
    	
    	soKitHeaderList = SOQLUtil.getSOKitHeaderByFieldName(new Map<String, String>{'Service_Order_Header__c' => soHeaderId});
    	Service_Order_Header__c soHeaderRec = soHeaderRecList[0];
    	coHeaderRecs = SOQLUtil.getCOHeaderDetails(soHeaderRec.CO_Header__c);
    	if(coHeaderRecs.size() > 0 && coHeaderRecs[0].Customer__c != null) {
	    	String customerId = coHeaderRecs[0].Customer__c;
	        String query;   
	        query = 'SELECT '; 
	        for(String fieldName : CardfieldsList()){
	        	fieldName = BPUtility.escapeSingleQuotes(fieldName);
	            query += fieldName + ', ';
	        }
	        query += '(Select ';  
	        //Child query
	        for(String fieldName : taxExemptionFields()){
	        	query += fieldName + ', ';
	        }
	        query = query.substring(0, query.length()-2);
	        query += ' FROM Tax_Exemptions__r), ';
	        
	        //Child query
	        query += '(Select Id FROM CO_Headers__r where Status__c = \'Open\') ';
	        query += ' FROM Account ';
	        query += 'WHERE Id = :customerId AND Is_Customer__c = true';
	       	customerList = Database.query(query);
        }
        //Edited by ANkit(put outside condition)
        couRecords = (soHeaderRec.Customer_Owned_Unit__c != null) ? SOQLUtil.getCOUListByFieldName('Id', soHeaderRec.Customer_Owned_Unit__c) : new List<Customer_Owned_Unit__c>();
        List<Price_Level__c> priceLevelList = new List<Price_Level__c>();
		priceLevelList = SOQLUtil.getCardDetailsForCO();
		
		List<Individual_Tax__c> individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, 
																Taxable_Amount__c, Tax_Amount__c,
																Applicable_Tax__c, List_Tax_items_on_forms__c
	    															from Individual_Tax__c where Service_Order_Line_Item__r.Service_Order_Header__c = :soHeaderId];
	    
	    Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();  
	    salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList);
	    
	    
		PrintingInfo printingInfoObj = new PrintingInfo(customerList, couRecords, coHeaderRecs, 
														soHeaderRec, soKitHeaderList, individualTaxList,
														priceLevelList, salesTaxNameToTaxValue);
		
		
        return BPUtility.getEncodedString(System.JSON.serialize(printingInfoObj));  
    }
	
	
	public class PrintingInfo {
		
		public Customer CustomerInfo;
		public CustomerOwnedUnit COUInfo;
		public COHeader COHeaderInfo;
		public SOHeaderWrapper.SOHeader SOHeaderInfo;
		public SOHeaderWrapper.SOReview SOReviewInfo;
		public List<SOHeaderWrapper.SOGrid> SOGridItems;
		public Decimal Total_Part;
		public Decimal Total_Laobur;
		public Decimal Total_Sublet;
		public Decimal Total_Other;
        public Decimal Total_ShopSupplies;
		public Decimal Total;
		public Decimal SalesTax;		
		public Decimal Deductible;
		public Decimal FinalTotal;		
		public List<IndividualTax> SalesTaxList;
		public Boolean IsTaxIncludingPricing;
		public COCardDetail CardInfo;
	
		public PrintingInfo(List<Account> customerList, List<Customer_Owned_Unit__c> couList, List<CO_Header__c> coHeaderList, Service_Order_Header__c soHeaderRec, 
								List<Service_Order_Kit_Header__c> soKitHeaderList, List<Individual_Tax__c> individualTaxList, List<Price_Level__c> priceLevelList,
								Map<String, Decimal> salesTaxNameToTaxValue) {
			this.SOGridItems = new List<SOHeaderWrapper.SOGrid>();
			
			this.CustomerInfo = (customerList.size() > 0) ? new Customer(customerList[0]) : new Customer(new Account());
			this.COUInfo = (couList.size() > 0) ? new CustomerOwnedUnit(couList[0]) : new CustomerOwnedUnit(new Customer_Owned_Unit__c());
			this.COHeaderInfo = (coHeaderList.size() > 0) ? new COHeader(coHeaderList[0]) : new COHeader(new CO_Header__c());
			this.SOHeaderInfo = new SOHeaderWrapper.SOHeader(soHeaderRec);
			this.SOReviewInfo = new SOHeaderWrapper.SOReview(soHeaderRec);
			this.Total_Part = 0;
			this.Total_Laobur = 0;
			this.Total_Sublet = 0;
			this.Total_Other = 0;
            this.Total_ShopSupplies = 0;
			this.Total = 0;
			this.SalesTax = 0;		
			this.SalesTaxList = new List<IndividualTax>();		
			this.IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
			Set<Id> soliIdSet = new Set<Id>();
			
			for(Service_Order_Kit_Header__c soKHRec : soKitHeaderList) {
				this.SOGridItems.add(new SOHeaderWrapper.SOGrid(soKHRec, soKHRec.Service_Order_Line_Items__r, true));
            	for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
            		soliIdSet.add(soliRec.Id);
            	}
			}
			for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
        		if(!soliIdSet.contains(soliRec.Id)) {
    				this.SOGridItems.add(new SOHeaderWrapper.SOGrid(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
        		}
        	} 
            
        	this.Total_Part = (soHeaderRec.Total_Parts__c != null) ? soHeaderRec.Total_Parts__c.setScale(2, RoundingMode.HALF_UP) : 0;
        	this.Total_Other = (soHeaderRec.Total_Fees__c != null) ? soHeaderRec.Total_Fees__c.setScale(2, RoundingMode.HALF_UP) : 0;
        	this.Total_Laobur = (soHeaderRec.Total_Labor__c != null) ? soHeaderRec.Total_Labor__c.setScale(2, RoundingMode.HALF_UP) : 0;
        	this.Total_Sublet = (soHeaderRec.Total_Sublet__c != null) ? soHeaderRec.Total_Sublet__c.setScale(2, RoundingMode.HALF_UP) : 0;
        	this.Total_ShopSupplies = (soHeaderRec.Total_Shop_Supplies__c != null) ? soHeaderRec.Total_Shop_Supplies__c.setScale(2, RoundingMode.HALF_UP) : 0;
            
        	this.Total = this.Total_Part + this.Total_Laobur + this.Total_Sublet + this.Total_Other + this.Total_ShopSupplies;
        	Map<String, Decimal> salesTaxItemNameToTaxValueMap = new Map<String, Decimal>();
        	for(Individual_Tax__c individualTaxRec : individualTaxList) {
        		if(!salesTaxItemNameToTaxValueMap.containsKey(individualTaxRec.Sales_Tax_Item_Name__c)) {
        			salesTaxItemNameToTaxValueMap.put(individualTaxRec.Sales_Tax_Item_Name__c, 0);
        		}
        		if(individualTaxRec.Service_Order_Line_Item__r.Total__c != null) {
        			if(individualTaxRec.Tax_Rate__c == null) {
        				individualTaxRec.Tax_Rate__c = 0;
        			}
        			Decimal oldTaxValue = salesTaxItemNameToTaxValueMap.get(individualTaxRec.Sales_Tax_Item_Name__c) + 
        						((individualTaxRec.Tax_Rate__c * individualTaxRec.Service_Order_Line_Item__r.Total__c) / 100);
        			salesTaxItemNameToTaxValueMap.put(individualTaxRec.Sales_Tax_Item_Name__c, oldTaxValue);
        		}
        	}
        	for(String salesTaxName : salesTaxItemNameToTaxValueMap.keySet()) {
        		//this.SalesTaxList.add(new IndividualTax(salesTaxName, salesTaxItemNameToTaxValueMap.get(salesTaxName)));
        	}
        	if(priceLevelList.size()> 0  && customerList.size() > 0){
        		this.CardInfo = new COCardDetail(customerList[0], priceLevelList[0]);
        	}
        	else if(customerList.size() == 0 && priceLevelList.size() > 0){
        		this.CardInfo = new COCardDetail(null, priceLevelList[0]);
        		
        	}
        	else if(customerList.size() > 0 && priceLevelList.size() == 0){
        		this.CardInfo = new COCardDetail(customerList[0], null);
        	}
        	else if(customerList.size() == 0 && priceLevelList.size() == 0){
        		this.CardInfo = new COCardDetail(null, null);
        	}
        		
        	// Populate Deductible amount - Added by TK - 03/04/2017
        	this.Deductible = 0;
        	for(SO_Payment_Role__c deductibleRec : soHeaderRec.SO_Payment_Roles__r) {
        		if(deductibleRec.RecordType.DeveloperName == 'Deductible') {
        			this.Deductible += deductibleRec.Total_Amount__c;
                }
            }	
            
            for(String taxName : salesTaxNameToTaxValue.keySet()){
		    	this.SalesTaxList.add(new IndividualTax(taxName, salesTaxNameToTaxValue.get(taxName)));
		    	this.SalesTax += salesTaxNameToTaxValue.get(taxName);
		    }
            
        	this.FinalTotal = this.Total - this.Deductible;
        	if(!isTaxIncludingPricing) {
        		this.FinalTotal += this.SalesTax;
        	}
		}	
	}
	
	public class COCardDetail {
    	public Decimal DiscountPercentage;
    	public String PartPriceBase;
    	public String PriceLevelStr;
    	public String PriceLevelName;
    	public String ExemptionTaxName;
    	public Integer TotalActiveOrders;
    	
    	public COCardDetail() {
    		
    	}
    	public COCardDetail(Account customerCardInfoRec, Price_Level__c defaultPriceLevelInfo) {
    		if(customerCardInfoRec != null){
    			this.TotalActiveOrders = (customerCardInfoRec.CO_Headers__r.size() > 0) ? customerCardInfoRec.CO_Headers__r.size() : 0;
    		}	
    		if(customerCardInfoRec != null && defaultPriceLevelInfo != null){
	    		this.PriceLevelName = (customerCardInfoRec.Price_Level__c != null) ? customerCardInfoRec.Price_Level__r.Name__c : '';
	    		this.ExemptionTaxName = '';
	    		for(Tax_Exemption__c taxExemptionRec : customerCardInfoRec.Tax_Exemptions__r) {
	    			this.ExemptionTaxName += ((taxExemptionRec.Sales_Tax_Item__c != null) ? (taxExemptionRec.Sales_Tax_Item__r.Name__c + ', ') : '');
	    		}
	    		if(this.ExemptionTaxName.length() > 2) {
	    			this.ExemptionTaxName = this.ExemptionTaxName.subString(0, this.ExemptionTaxName.length() - 2);
	    		}
    		}else if(customerCardInfoRec == null && defaultPriceLevelInfo != null){
    			this.PriceLevelName = (defaultPriceLevelInfo != null) ? defaultPriceLevelInfo.Name__c : '';
	    		this.ExemptionTaxName = '';
    		}
    	}
    }						
	public class IndividualTax {		
    	public String TaxName;		
    	public Decimal TaxValue;		
    			
    	public IndividualTax(String taxName, Decimal taxValue) {		
    		this.TaxName = taxName;		
    		this.TaxValue = (taxValue != null) ? taxValue.setScale(2, RoundingMode.HALF_UP) : 0;		
    	}		
    }
	public  class Customer {
		
		// Customer Name
    public String BusinessName;
    
    // Customer First Name
    public String FirstName;
    
    // Customer Last Name
    public String LastName; 
    
    // Active Customer
    public Boolean Active;
    
    // Birth Date
    public Date Birthdate;
    
    // Birth Month
    public Integer BirthMonth;
    
    // Birth Date
    public Integer BirthDay;
    
    // Birth Year
    public Integer BirthYear;
    
    // Company Name
    public String Company;
    
    // FaceBook Link
    public String FacebookLink;
    
    // Twitter Link 
    public String TwitterLink;
    
    // Linkedin Link
    public String LinkedInLink;
    
    // Home Eamil Address
    public String HomeEmail;
    
    // Work Email Address
    public String WorkEmail;
    
    // Other Email Address
    public String OtherEmail;
    
    // Home Number
    public String HomeNumber;
    
    // Mobile Number
    public String OtherPhone;
    
    // Work Number
    public String WorkNumber;
    
    // Is Home Number is treated as SMS ?
    public Boolean HomeNumberSMS;
    
    // Is Mobile Number is treated as SMS ?
    public Boolean MobileNumberSMS;
    
    // Is Work Number is treated as SMS ?
    public Boolean WorkNumberSMS;
    
    // Is Customer
    public Boolean IsCustomer;
    
    // Is vendor
    public Boolean IsVendor;
    
    // Job Title
    public String JobTitle;
    
    // Nick Name
    public String Nickname;
    
    // Preferred Email
    public String PreferredEmail;
    
    // Preferred Phone
    public String PreferredPhone;
    
    // Preferred SMS
    public String PreferredSMS;
    
    // Is Both Address Same - Shipping Address and Billing Address?
    public Boolean IsBothAddressSame;
    
    // Type__c
    public String Type;
    
    // Billing Address Fields
    public String BillingStreet1;
    public String BillingStreet2;
    public String BillingCity;
    public String BillingState;
    public String BillingCountry;
    public String BillingPostalCode;
    
    // Shipping Address Fields
    public String ShippingStreet1;
    public String ShippingStreet2;
    public String ShippingCity;
    public String ShippingState;
    public String ShippingCountry;
    public String ShippingPostalCode;
    
    // Id
    public String Id;
    
    // Price Level ID
    public String PriceLevelId;
    
    // Price Leel Name
    public String PriceLevelName;
    
    // SalesTax ID
    public String SalesTaxId;
    
    // Price Leel Name
    public String SalesTaxName;
    
    // SalesTax ID
    public String PurchaseTaxId;
    
    // Price Leel Name
    public String PurchaseTaxName;
    
    // Customer Number
    public String CustomerNumber;
	
		public Customer(Account customerRec) {
			this.BusinessName = customerRec.Name;
	    	this.FirstName = customerRec.FirstName__c;
	    	this.LastName = customerRec.LastName__c;
	    	
	    	this.HomeEmail = (customerRec.Email__c == null) ? '' : customerRec.Email__c;
	    	this.HomeNumber = (customerRec.Home_Number__c == null ) ? '' : customerRec.Home_Number__c;
	    	
	    	// Address fields
	    	String billingStreet = (customerRec.BillingStreet == null ) ? '' : customerRec.BillingStreet;
	    	List<String> bsList = billingStreet.split('\n');
	    	this.BillingStreet1 = (bsList.size() > 0) ? bsList[0] : '';
	    	this.BillingStreet2 = (bsList.size() > 1) ? bsList[1] : '';
	    	this.BillingCity = (customerRec.BillingCity == null) ? '' : customerRec.BillingCity;
	    	this.BillingState = (customerRec.BillingState == null) ? '' : customerRec.BillingState;
	    	this.BillingCountry = (customerRec.BillingCountry == null) ? '' : customerRec.BillingCountry;
	    	this.BillingPostalCode = (customerRec.BillingPostalCode == null) ? '' : customerRec.BillingPostalCode;
	    	
	    	String shippingStreet = (customerRec.ShippingStreet == null ) ? '' : customerRec.ShippingStreet;
	    	List<String> ssList = shippingStreet.split('\n');
	    	this.ShippingStreet1 = (ssList.size() > 0) ? ssList[0] : '';
	    	this.ShippingStreet2 = (ssList.size() > 1) ? ssList[1] : '';
	    	this.ShippingCity = (customerRec.ShippingCity == null) ? '' : customerRec.ShippingCity;
	    	this.ShippingState = (customerRec.ShippingState == null) ? '' : customerRec.ShippingState;
	    	this.ShippingCountry = (customerRec.ShippingCountry == null) ? '' : customerRec.ShippingCountry;
	    	this.ShippingPostalCode = (customerRec.ShippingPostalCode == null) ? '' : customerRec.ShippingPostalCode;
	    	this.IsBothAddressSame = customerRec.SA_same_as_BA__c;
	    	
	    	// Addtional Fields
	    	this.Birthdate = customerRec.Birth_Date__c;
	    	if(customerRec.Birth_Date__c != null) {
	    		this.BirthDay = customerRec.Birth_Date__c.day();
	    		this.BirthMonth = customerRec.Birth_Date__c.month();
	    		this.BirthYear = customerRec.Birth_Date__c.year();
	    	}
	    	 
	    	this.Active = customerRec.Active__c;
	    	this.Company = (customerRec.Company_Name__c == null) ? '' : customerRec.Company_Name__c;
	    	this.JobTitle = (customerRec.Job_Title__c == null) ? '' : customerRec.Job_Title__c;
	    	
	    	// Phone And Email
	    	this.WorkEmail = (customerRec.Work_Email__c == null) ? '' : customerRec.Work_Email__c;
	    	this.OtherEmail = (customerRec.Other_Email__c == null) ? '' : customerRec.Other_Email__c;
	    	this.OtherPhone = (customerRec.Mobile__c == null) ? '' : customerRec.Mobile__c;
	    	this.WorkNumber = (customerRec.Work_Number__c == null) ? '' : customerRec.Work_Number__c;
	    	this.HomeNumberSMS = customerRec.Home_Number_SMS__c;
	    	this.MobileNumberSMS = customerRec.Mobile_Number_SMS__c;
	    	this.WorkNumberSMS = customerRec.Work_Number_SMS__c;
	    	
	    	if(customerRec.Preferred_Email__c != null) {
	    		if(customerRec.Preferred_Email__c == customerRec.Email__c) {
	    			this.PreferredEmail = 'HomeEmail';
	    		} else if(customerRec.Preferred_Email__c == customerRec.Work_Email__c) {
	    			this.PreferredEmail = 'WorkEmail';
	    		} else if(customerRec.Preferred_Email__c == customerRec.Other_Email__c) {
	    			this.PreferredEmail = 'OtherEmail';
	    		}
	    	} else {
	    		this.PreferredEmail = '';
	    	}
	    	
	    	if(customerRec.Preferred_Phone__c != null) {
	    		if(customerRec.Preferred_Phone__c == customerRec.Home_Number__c) {
	    			this.PreferredPhone = 'HomeNumber';
	    		} else if(customerRec.Preferred_Phone__c == customerRec.Mobile__c) {
	    			this.PreferredPhone = 'OtherPhone';
	    		} else if(customerRec.Preferred_Phone__c == customerRec.Work_Number__c) {
	    			this.PreferredPhone = 'WorkNumber';
	    		}
	    	} else {
	    		this.PreferredPhone = '';
	    	}
	    	
	    	if(customerRec.Preferred_SMS__c != null) {
	    		if(customerRec.Preferred_SMS__c == customerRec.Home_Number__c) {
	    			this.PreferredSMS = 'HomeNumber';
	    		} else if(customerRec.Preferred_SMS__c == customerRec.Mobile__c) {
	    			this.PreferredSMS = 'OtherPhone';
	    		} else if(customerRec.Preferred_SMS__c == customerRec.Work_Number__c) {
	    			this.PreferredSMS = 'WorkNumber';
	    		}
	    	} else {
	    		this.PreferredSMS = '';
	    	}
	    	this.PreferredEmail = customerRec.Preferred_Email__c;
	    	this.PreferredPhone = customerRec.Preferred_Phone__c;
	    	this.IsCustomer = customerRec.Is_Customer__c;
	    	this.IsVendor = customerRec.Is_Vendor__c;
	    	this.Nickname = (customerRec.Nickname__c == null) ? '' : customerRec.Nickname__c;
	    	this.Type = customerRec.Type__c;
	    	this.FacebookLink = (customerRec.Facebook__c == null) ? '' : customerRec.Facebook__c;
	    	this.TwitterLink = (customerRec.Twitter__c == null) ? '' : customerRec.Twitter__c;
	    	this.LinkedInLink = (customerRec.LinkedIn__c == null) ? '' : customerRec.LinkedIn__c;
	    	
	    	this.Id = (customerRec.Id == null) ? '' : customerRec.Id; 
	    	
	    	this.PriceLevelId = customerRec.Price_Level__c;
	    	this.PriceLevelName = (customerRec.Price_Level__c == null) ? '' : customerRec.Price_Level__r.Name__c;
	    	this.SalesTaxId = customerRec.Sales_Tax__c;
	    	this.SalesTaxName = (customerRec.Sales_Tax__c == null) ? '' : customerRec.Sales_Tax__r.Name__c;
	    	this.PurchaseTaxId = customerRec.Purchase_Tax__c;
	    	this.PurchaseTaxName = (customerRec.Purchase_Tax__c == null) ? '' : customerRec.Purchase_Tax__r.Name__c;
	    	this.CustomerNumber = customerRec.Customer_Number__c;
		}
	}
	
	public class COHeader {
		public String COHeaderName;
		 // Customer Id 
	    public String CustomerId {get; set;}
	    
	    // Customer Name
	    public String CustomerName {get; set;}
	    
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
		public COHeader(CO_Header__c coHeaderRec) {
			this.COHeaderName = coHeaderRec.Name;
			this.CustomerId = coHeaderRec.Customer__c;
	        this.CustomerName = coHeaderRec.Customer__r.Name;
	        this.COHeaderId = coHeaderRec.Id;
	        this.Assignee = coHeaderRec.Assignee__c;
	        this.AssigneeName = coHeaderRec.Assignee__r.Name;
	        this.OrderStatus = coHeaderRec.Order_status__c;
	        this.Owner = coHeaderRec.Owner__c;
	        this.OwnerName = coHeaderRec.Owner__r.Name;
	        if(this.Owner == null) {
	            this.Owner = '';
	        }
	        this.OrderName = coHeaderRec.Name;
            if(coHeaderRec.CreatedDate != null) {
	        	this.PromisedBy = (datetime.newInstance(coHeaderRec.CreatedDate.year(), coHeaderRec.CreatedDate.month(), coHeaderRec.CreatedDate.day() + 5)).format('MMMM dd, yyyy');
	        	this.CreatedDate = coHeaderRec.CreatedDate.format('MMMM dd, yyyy hh:mm a');
	        }
	        if(coHeaderRec.LastModifiedDate != null) {
	        	this.ModifiedDate = coHeaderRec.LastModifiedDate.format('MMMM dd, yyyy hh:mm a');
	        }
            this.COType = coHeaderRec.CO_Type__c;
	        this.SellingGroup = coHeaderRec.Selling_Group__c;	
		}
	}
}