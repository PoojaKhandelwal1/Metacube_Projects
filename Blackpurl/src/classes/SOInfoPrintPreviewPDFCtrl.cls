public with sharing class SOInfoPrintPreviewPDFCtrl {
	
	public String companyLogoURL { get{return GeneralConfiguration.getCompanyLogoUrl();} private set;}
			    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static String Application{get;}
    public static String Assests{get;} 
    public static String Application_Images{get;}
    
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
	public SOInfoPrintPreviewPDFCtrl(){
			Application = GlobalController.GetResourceURL('Application');
	    	Application_Images = GlobalController.GetResourceURL('Application_Images');
	    	Assests = GlobalController.GetResourceURL('Assests');
			String soHeaderId = ApexPages.currentPage().getParameters().get('id');
			soHeaderId = String.escapeSingleQuotes(soHeaderId);
			 
			List<CO_Header__c> coHeaderRecs = new List<CO_Header__c>();
			List<Customer_Owned_Unit__c> couRecords = new List<Customer_Owned_Unit__c>();
			List<Account> customerList = new List<Account>();
			List<Service_Order_Kit_Header__c> soKitHeaderList = new List<Service_Order_Kit_Header__c>();
			List<Service_Order_Header__c> soHeaderRecList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'Id' => string.escapesinglequotes(soHeaderId)});
			List<Individual_Tax__c> individualTaxList = [select Sales_Tax_Item_Name__c, Tax_Rate__c, Service_Order_Line_Item__c, 		
    														Service_Order_Line_Item__r.Total__c, Service_Order_Line_Item__r.Tax_Percent__c	 		
    														from Individual_Tax__c		
    														where Service_Order_Line_Item__r.Service_Order_Header__c =: soHeaderId];
			
			
			if(soHeaderRecList.size() != 0) {
				soKitHeaderList = SOQLUtil.getSOKitHeaderByFieldName(new Map<String, String>{'Service_Order_Header__c' => string.escapesinglequotes(soHeaderId)});
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
				couRecords = (soHeaderRec.Customer_Owned_Unit__c != null) ? SOQLUtil.getCOUListByFieldName('Id', soHeaderRec.Customer_Owned_Unit__c) : new List<Customer_Owned_Unit__c>();
	   			List<Price_Level__c> priceLevelList = new List<Price_Level__c>();
				priceLevelList = SOQLUtil.getCardDetailsForCO();
				printingInfoObj = new PrintingInfo(customerList, couRecords, coHeaderRecs, soHeaderRec, soKitHeaderList, individualTaxList,priceLevelList);
			}
		
	}
	
	public PrintingInfo printingInfoObj{set;get;}
		public class PrintingInfo {
		
		public Customer CustomerInfo{Set;get;}
		public CustomerOwnedUnit COUInfo{Set;get;}
		public COHeader COHeaderInfo{Set;get;}
		public SOHeader SOHeaderInfo{Set;get;}
		public SOReview SOReviewInfo{Set;get;}
		public List<SOGrid> SOGridItems{Set;get;}
		public Decimal Total_Part{Set;get;}
		public Decimal Total_Laobur{Set;get;}
		public Decimal Total_Sublet{Set;get;}
		public Decimal Total_Other{Set;get;}
		public Decimal Total{Set;get;}
		public Decimal SalesTax{set;get;}
		public List<IndividualTax> SalesTaxList{set;get;}
		public Boolean IsTaxIncludingPricing{set;get;}
		public COCardDetail CardInfo{set;get;}
		 /**
		 * Name: PrintingInfo
		 * Description: Constructor
		 * @Param:	(1) customerList - List<Account> - List Of Customer
		 *			(2) couList - List<Customer_Owned_Unit__c> - List of Customer Owned Unit Record
		 *			(3) coHeaderList - List<CO_Header__c> - List of Co  Header
		 *			(4) soHeaderRec -  Service_Order_Header__c - List of Service Order Header
		 *			(5) soKitHeaderList - List<Service_Order_Kit_Header__c> - List of Service Order Kit Header Record
		 * @Return:	
		 **/
		public PrintingInfo(List<Account> customerList, List<Customer_Owned_Unit__c> couList, List<CO_Header__c> coHeaderList, Service_Order_Header__c soHeaderRec, 
								List<Service_Order_Kit_Header__c> soKitHeaderList, List<Individual_Tax__c> individualTaxList, List<Price_Level__c> priceLevelList) {
			this.SOGridItems = new List<SOGrid>();
			
			this.CustomerInfo = (customerList.size() > 0) ? new Customer(customerList[0]) : new Customer(new Account());
			this.COUInfo = (couList.size() > 0) ? new CustomerOwnedUnit(couList[0]) : new CustomerOwnedUnit(new Customer_Owned_Unit__c());
			this.COHeaderInfo = (coHeaderList.size() > 0) ? new COHeader(coHeaderList[0]) : new COHeader(new CO_Header__c());
			this.SOHeaderInfo = new SOHeader(soHeaderRec);
			this.SOReviewInfo = new SOReview(soHeaderRec);
			
			this.Total_Part = 0;
			this.Total_Laobur = 0;
			this.Total_Sublet = 0;
			this.Total_Other = 0;
			this.Total = 0;
			this.SalesTax = 0;
			this.SalesTaxList = new List<IndividualTax>();
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
			this.IsTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
			
			Set<Id> soliIdSet = new Set<Id>();
			for(Service_Order_Kit_Header__c soKHRec : soKitHeaderList) {
				this.SOGridItems.add(new SOGrid(soKHRec, soKHRec.Service_Order_Line_Items__r, true));
            	for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
            		if(soliRec.Tax_Percent__c == null) {
            			soliRec.Tax_Percent__c = 0;
            		}
            		soliIdSet.add(soliRec.Id);
            		if(soliRec.Labour_Code__c != null && soliRec.Part__c == null) {
            			this.Total_Laobur += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            			if(isTaxIncludingPricing) {
                        	this.Total_Laobur += ((soliRec.Total__c * soliRec.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                        } else {
                        	this.SalesTax += (soliRec.Total__c * soliRec.Tax_Percent__c) / 100;
                        }
            		} else if(soliRec.Labour_Code__c == null && soliRec.Part__c != null) {
            			this.Total_Part += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            			if(isTaxIncludingPricing) {
	                    	this.Total_Part += ((soliRec.Total__c * soliRec.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
	                    } else {
	                    	this.SalesTax += (soliRec.Total__c * soliRec.Tax_Percent__c) / 100;
	                    }
            		} else if(soliRec.Fee__c != null) {
            			this.Total_Other += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            			if(isTaxIncludingPricing) {
                        	this.Total_Other += ((soliRec.Total__c * soliRec.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                        } else {
                        	this.SalesTax += (soliRec.Total__c * soliRec.Tax_Percent__c) / 100;
                        }
            		}
            	} 
			}
			
			for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
				if(soliRec.Tax_Percent__c == null) {
        			soliRec.Tax_Percent__c = 0;
        		}
        		if(!soliIdSet.contains(soliRec.Id)) {
    				this.SOGridItems.add(new SOGrid(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
    				if(soliRec.Labour_Code__c != null && soliRec.Part__c == null) {
            			this.Total_Laobur += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            			if(isTaxIncludingPricing) {
                        	this.Total_Laobur += ((soliRec.Total__c * soliRec.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                        } else {
                        	this.SalesTax += (soliRec.Total__c * soliRec.Tax_Percent__c) / 100;
                        }
            		} else if(soliRec.Labour_Code__c == null && soliRec.Part__c != null) {
            			this.Total_Part += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            			if(isTaxIncludingPricing) {
	                    	this.Total_Part += ((soliRec.Total__c * soliRec.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
	                    } else {
	                    	this.SalesTax += (soliRec.Total__c * soliRec.Tax_Percent__c) / 100;
	                    }
            		} else if(soliRec.Fee__c != null) {
            			this.Total_Other += (soliRec.Total__c != null) ? soliRec.Total__c : 0;
            			if(isTaxIncludingPricing) {
                        	this.Total_Other += ((soliRec.Total__c * soliRec.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                        } else {
                        	this.SalesTax += (soliRec.Total__c * soliRec.Tax_Percent__c) / 100;
                        }
            		}
        		}
        	}
        	this.Total = this.Total_Part + this.Total_Laobur + this.Total_Sublet + this.Total_Other;
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
        		this.SalesTaxList.add(new IndividualTax(salesTaxName, salesTaxItemNameToTaxValueMap.get(salesTaxName)));
        	}
        }	
	}
	
	public class IndividualTax {		
    	public String TaxName{set;get;}		
    	public Decimal TaxValue{set;get;}		
    			
    	public IndividualTax(String taxName, Decimal taxValue) {		
    		this.TaxName = taxName;		
    		this.TaxValue = (taxValue != null) ? taxValue.setScale(2, RoundingMode.HALF_UP) : 0;		
    	}		
    }		
	
	/**
	* Name: Customer
	* Description: Customer Wrapper Class
	**/
	public class Customer {
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
    public String PreferredEmail{set;get;}
    
    // Preferred Phone
    public String PreferredPhone{set;get;}
    
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
		
    /**
     * Name: fieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public  List<String> fieldsList(){
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
	
	/**
	* Name: COHeader
	* Description: COHeader Wrapper Class
	**/
		public class COHeader {
		public String COHeaderName{get; set;}
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
	    public String COType{get; set;}
    
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
	        this.PromisedBy = (datetime.newInstance(coHeaderRec.CreatedDate.year(), coHeaderRec.CreatedDate.month(), coHeaderRec.CreatedDate.day() + 5)).format('MMMM dd, yyyy');
	        this.CreatedDate = BPUtility.getExtendedDateFormat(coHeaderRec.CreatedDate);
	        this.ModifiedDate = BPUtility.getExtendedDateFormat(coHeaderRec.LastModifiedDate);
	        this.COType = coHeaderRec.CO_Type__c;
	        this.SellingGroup = coHeaderRec.Selling_Group__c;	
		}
	}

	public with sharing class CustomerOwnedUnit {
	
	// VIN Number
    public String VIN{set;get;}
    
    // Year
    public Decimal Year{set;get;}
    
    // Make
    public String Make{set;get;}
    
    // Make
    public String MakeName{set;get;}
    
    // Model
    public String ModelName{set;get;}
    
    // Model
    public String Model{set;get;}
    
    // Sub-Model
    public String SubModel{set;get;}
    
    // Sub-Model Name
    public String SubModelName{set;get;}
    
    // Parent model make name
    public String ModelMakeName{set;get;}
    
    // License Plate
    public String Plate{set;get;}
    
    // Mileage
    public Decimal Mileage{set;get;}
    
    // Color
    public String Color{set;get;}
    
    // Id
    public String Id{set;get;}
    
    public String Name{set;get;}
    
    public String StockId{set;get;}
    
    public String UnitId{set;get;}
    
    public String StatusColor{set;get;}
    
    public String UnitType{set;get;}
    
    public String Status{set;get;}
    
    public String MakeModelDescription{set;get;}
    // Constructor
    public CustomerOwnedUnit(Customer_Owned_Unit__c coUnitRec) {
    	this.VIN = coUnitRec.VIN_Number__c;
    	this.Year = coUnitRec.Year__c;
    	this.Make = coUnitRec.Unit_Make__c;
    	this.MakeName = coUnitRec.Unit_Make__r.Name;
    	this.Name = coUnitRec.Name;
    	this.UnitType = coUnitRec.Unit_Type__c;
    	this.StockId = coUnitRec.Stock_Id__c;
    	this.UnitId = coUnitRec.Unit_Id__c;
    	this.Status = coUnitRec.Status__c;
    	this.SubModel = coUnitRec.Sub_Model__c;
    	this.SubModelName = (coUnitRec.Sub_Model__c != null) ? coUnitRec.Sub_Model__r.Sub_Model_Name__c : '';
    	this.MakeModelDescription = (coUnitRec.Sub_Model__c != null) ? coUnitRec.Sub_Model__r.Sub_Model_Description__c : '';
    	
    	if(coUnitRec.Unit_Model__c != null) {
    		this.Model = coUnitRec.Unit_Model__c;
    		this.ModelName = coUnitRec.Unit_Model__r.Name__c;
    		//this.SubModel = coUnitRec.Unit_Model__c;
    		//this.SubModelName = coUnitRec.Unit_Model__r.Sub_Model__c;
    		this.ModelMakeName = coUnitRec.Unit_Model__r.Unit_Make__r.Name;
    	
    	} else {
    		this.Model = '';
    		this.ModelName = '';
    		//this.SubModel = '';
    	}
    	if(this.UnitType == 'STOCK') {
    		if(coUnitRec.Status__c == 'Available') {
    			this.StatusColor = 'Green';
    		} else if(coUnitRec.Status__c == 'Reserved' || coUnitRec.Status__c == 'Sold'){
    			this.StatusColor = 'Red';
    		} else if(coUnitRec.Status__c == 'Traded' || coUnitRec.Status__c == 'Delivered'){
    			this.StatusColor = 'Black';
    		}
    	
    	} else if(this.UnitType == 'COU') {
    		if(coUnitRec.Status__c == 'Active') {
    			this.StatusColor = 'Green';
    		} else if(coUnitRec.Status__c == 'Inactive'){
    			this.StatusColor = 'Red';
    		} else if(coUnitRec.Status__c == 'Transferred'){
    			this.StatusColor = 'Black';
    		}
    	
    	} else if(this.UnitType == 'ORDU') {
    		if(coUnitRec.Status__c == 'On Order') {
    			this.StatusColor = 'Red';
    		} else if(coUnitRec.Status__c == 'Cancelled' || coUnitRec.Status__c == 'Traded'){
    			this.StatusColor = 'Black';
    		}
    	}
    	this.Plate = coUnitRec.Plate__c;
    	this.Mileage = coUnitRec.Mileage_Value__c;
    	this.Color = coUnitRec.Colour__c;
    	this.Id = coUnitRec.Id;
    }
	}
	public class AvailableStatus {
    	public String AvailableStatus;
    	public String StatusUniqueKey;
    	
    	public AvailableStatus(String status) {
    		this.AvailableStatus = status;
    		this.StatusUniqueKey = (status != null) ? status.replaceAll(' ', '_') : null;
    	}
    }
	/**
	* Name: SOHeader
	* Description: Apex class which contains all JSON related oprations of Service Order
	**/
	public class SOHeader {
		public String Id;
		public String Name;
		public Decimal Total;
		public List<String> ManualConcern{set;get;}
		public List<String> ManualCorrection{set;get;} 
		public List<String> ManualCause{set;get;}
		
		public List<String> KitHeaderCause;
		public List<String> KitHeaderConcern{set;get;}
		public List<String> KitHeaderCorrection{Set;get;}
		
		public String PromisedBy;
		public String IsPromisedByAmPm;
		public Decimal EstimatedHours;
		public String TransactionTypeId;
		public String TransactionType;
		public String COUId;
		public String ProviderId;
		public String CategoryId;
		public String CategoryName;
		public String Stock;
		public String Status{Set;get;}
		public Boolean IsCompletedLinkShown;
		
		public String WorkStatus;
		public List<AvailableStatus> AvailableWorkStatusList;
		public String ClaimStatus;
		public List<AvailableStatus> AvailableClaimStatusList;
		
		/**
     	* Name: SOHeader
     	* Desc: Constructor
    	* @param:	(1)soHeaderRec -  Service_Order_Header__c - Service order header Record
    	* @return: 
   		**/		
		public SOHeader(Service_Order_Header__c soHeaderRec) {
			this.Id = soHeaderRec.Id;
			this.Name = soHeaderRec.Name__c;
			this.Total = 0;
			this.ManualConcern = (soHeaderRec.SO_Concern__c != null) ? soHeaderRec.SO_Concern__c.split('\n') : new List<String>();
			this.ManualCorrection = (soHeaderRec.SO_Correction__c != null) ? soHeaderRec.SO_Correction__c.split('\n') : new List<String>();
			this.ManualCause = (soHeaderRec.SO_Cause__c != null) ? soHeaderRec.SO_Cause__c.split('\n') : new List<String>();
			if(soHeaderRec.Customer_Owned_Unit__c != null) {
				this.COUId = soHeaderRec.Customer_Owned_Unit__c;
			}
			
			this.ProviderId = soHeaderRec.Provider__c;
			
			if(soHeaderRec.Category__c != null) {
				this.CategoryName = soHeaderRec.Category__r.Name;
				this.CategoryId = soHeaderRec.Category__c;
			} 
			this.KitHeaderCause = new List<String>();
			this.KitHeaderConcern = new List<String>();
			this.KitHeaderCorrection = new List<String>();
			
			if(soHeaderRec.Service_Order_Kit_Headers__r.size() > 0) {
				for(Service_Order_Kit_Header__c soKitHeaderRec : soHeaderRec.Service_Order_Kit_Headers__r) {
					if(soKitHeaderRec.Kit_Header__c != null) {
						this.KitHeaderCause = (soKitHeaderRec.Kit_Header__r.Cause__c != null) ? soKitHeaderRec.Kit_Header__r.Cause__c.split('\n') : new List<String>();
					}
					if(soKitHeaderRec.Kit_Header__c != null) {
						this.KitHeaderConcern = (soKitHeaderRec.Kit_Header__r.Concern__c != null) ? soKitHeaderRec.Kit_Header__r.Concern__c.split('\n') : new List<String>();
					}
					if(soKitHeaderRec.Kit_Header__c != null) {
						this.KitHeaderCorrection = (soKitHeaderRec.Kit_Header__r.Correction__c != null) ? soKitHeaderRec.Kit_Header__r.Correction__c.split('\n') : new List<String>();
					}
				}
			}
			this.EstimatedHours = ((soHeaderRec.Estimated_Hours__c == null) ? 0 : soHeaderRec.Estimated_Hours__c).setScale(1);
			this.Stock = 'No outstanding items';
			this.TransactionType = soHeaderRec.Transaction_Type__r.Type__c;
			this.TransactionTypeId = soHeaderRec.Transaction_Type__c;
			this.PromisedBy = (soHeaderRec.Promised_By__c != null) ? soHeaderRec.Promised_By__c.format('MM/dd/yyyy hh:mm a') : null; 
			this.IsPromisedByAmPm = soHeaderRec.IsPromisedBy_AmPm__c;
			this.Status = soHeaderRec.Status__c;
			this.IsCompletedLinkShown = true;
			
			for(Service_Order_Line_Item__c soli : soHeaderRec.Service_Order_Line_Items__r) {
				if(soli.Total__c != null) {
					this.Total += soli.Total__c;
					if(soli.Labour_Code__c != null) {
						Decimal tax = soli.Labour_Tax_Amount__c;
						this.Total += tax; 
					} else if(soli.Tax__c != null) {
						Decimal tax = soli.Total__c * soli.Tax__c / 100;
						this.Total += tax;
					}
				}
				if(soli.Qty_To_Order__c > 0) {
					this.IsCompletedLinkShown = false;
				}
			}
			
			this.WorkStatus = soHeaderRec.Work_Status__c;
			if(this.WorkStatus != null && Constants.workStatusToAvailableStatusMap.containsKey(this.WorkStatus)) {
				this.AvailableWorkStatusList = new List<AvailableStatus>();
				for(String status : Constants.workStatusToAvailableStatusMap.get(this.WorkStatus)) {
            		this.AvailableWorkStatusList.add(new AvailableStatus(status));
            	}
			} else {
				this.AvailableWorkStatusList = new List<AvailableStatus>();
			}
			
			this.ClaimStatus = soHeaderRec.Claim_Status__c;
			if(this.ClaimStatus != null && Constants.claimStatusToAvailableStatusMap.containsKey(this.ClaimStatus)) {
				this.AvailableClaimStatusList = new List<AvailableStatus>();
	            for(String status : Constants.claimStatusToAvailableStatusMap.get(this.ClaimStatus)) {
	            	this.AvailableClaimStatusList.add(new AvailableStatus(status));
	            }
			} else {
				this.AvailableClaimStatusList = new List<AvailableStatus>();
			}
			
		}
	}
	/**
	* Name: SOKitHeader
	* Description: Apex class Service Order Kit Header
	**/
	public class SOKitHeader {
		
		public List<SOLineItem> SOLIList{Set;get;}
		
		public String ItemDescription{set;get;}
		public Boolean CanItSplit;
		public String Code;
		public Boolean IsServiceKit;
		public String Id{Set;get;}
		public Decimal FixedPrice{set;get;}
		public Decimal RetailPrice;
		public Boolean IsFixedPrice; 
		public Boolean hasChildren{Set;get;}
		public Boolean isFixedKitHeaderSO;
		
		/**
     	* Name: SOKitHeader
     	* Desc: Constructor
    	* @param:	(1)soKitHeaderRec -  Service_Order_Kit_Header__c - Service order Kit Header Record
					(2)soliList -List<Service_Order_Line_Item__c>- List of Service Order Line Items
					(3)hasChildren - Boolean  - has Children or not    			
    	* @return: 
   		**/
		public SOKitHeader(Service_Order_Kit_Header__c soKitHeaderRec, List<Service_Order_Line_Item__c> soliList, Boolean hasChildren) {
			Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
			this.SOLIList = new List<SOLineItem>();
			this.ItemDescription = soKitHeaderRec.Kit_Unique_Name__c;
			this.CanItSplit = soKitHeaderRec.Can_Split__c;
			this.IsServiceKit = soKitHeaderRec.Service_Kit__c;
			this.Code = soKitHeaderRec.Code__c;
			this.Id = soKitHeaderRec.Id;
			this.isFixedKitHeaderSO = soKitHeaderRec.Is_Fixed_Kit_Header_SO__c;
			if (!isTaxIncludingPricing) {
				this.FixedPrice = (soKitHeaderRec.Fixed_Price__c != null) ? soKitHeaderRec.Fixed_Price__c.SetScale(2, RoundingMode.HALF_UP) : soKitHeaderRec.Fixed_Price__c;
			} else {
				if (soKitHeaderRec.Fixed_Price__c == null) {
					soKitHeaderRec.Fixed_Price__c = 0;
				}
				if (soKitHeaderRec.Tax_Amount__c == null) {
					soKitHeaderRec.Tax_Amount__c = 0;
				}
				//system.assert(false,soKitHeaderRec);
				this.FixedPrice = (soKitHeaderRec.Fixed_Price__c + soKitHeaderRec.Tax_Amount__c).setscale(2, RoundingMode.HALF_UP);
			}
			this.IsFixedPrice = soKitHeaderRec.Fixed_Price_Flag__c;
			for(Service_Order_Line_Item__c soliRec : soliList) {
				this.SOLIList.add(new SOLineItem(soliRec));
			}
			this.hasChildren = hasChildren;
		}
	}
	/**
	* Name: SOLineItem
	* Description: Apex class Service Order Line Item
	**/
	public class SOLineItem {
		
		public String ItemDesc{Set;get;}
		
		/* START: Added By Tarun - #170 - 09/23/2016 */
		public String ItemCode {get; set;}
    	public String ItemDescription {get; set;}		
		
		public String Status{Set;get;}
		public Decimal QtyNeeded{Set;get;}
		public Decimal StockCommited{Set;get;}
		public Decimal QtyOrder{Set;get;}
		public Decimal ReatilPrice;
		public Decimal SubTotal{Set;get;}
		public Boolean IsFixedPrice;
		public Decimal AvailablePart;
		public String PartId;
		
		public Boolean IsPart {set;get;}
		public Boolean IsLabour{set;get;}
		public Boolean IsFee{set;get;}
		public String Id;
		public String SOKitHeaderId;
		public Decimal KitPrice{Set;get;}
		public Decimal Tax{get; set;
		}
		public String VendorId;
		public String CoLineItem;
		public Boolean isFixedKitHeaderLineItemSO;
		
		/**
     	* Name: SOLineItem
     	* Desc: Constructor
    	* @param:	(1)soLineItemRec - Service_Order_Line_Item__c - Service Order Line Item Record
    	* @return: 
   		**/
		public SOLineItem(Service_Order_Line_Item__c soLineItemRec) {
			this.Id = soLineItemRec.Id; 
			this.VendorId=soLineItemRec.Part__r.Vendor__c;
			
			/* START: Added By Tarun - #170 - 09/23/2016 */
			this.ItemCode = (soLineItemRec.Item_Code__c != null) ? soLineItemRec.Item_Code__c : '';
	    	this.ItemDescription = (soLineItemRec.Item_Description__c != null) ? soLineItemRec.Item_Description__c : '';
	    	this.ItemDesc = this.ItemCode + ' - ' + this.ItemDescription;
	    	
			this.isFixedKitHeaderLineItemSO = soLineItemRec.Is_Fixed_Kit_LineItem_SO__c;
			this.QtyNeeded = (soLineItemRec.Qty_Needed__c != null ) ? soLineItemRec.Qty_Needed__c : 0;
			this.StockCommited = (soLineItemRec.Qty_Committed__c != null) ? soLineItemRec.Qty_Committed__c : 0;
			
			if(soLineItemRec.CO_Line_Item__r.Closed_CO_Invoice_link__c != null) {
				this.Status = 'Invoiced'; 
			} else {
				if(this.QtyNeeded == this.StockCommited) {
					this.Status = 'In Stock';
				} else if(this.QtyNeeded > this.StockCommited) {
					if(soLineItemRec.CO_Line_Item__c != null && !soLineItemRec.CO_Line_Item__r.Special_Order__c) {
						this.Status = 'Required';
					} else {
						this.Status = 'Ordered';
					}
				} else if(soLineItemRec.Qty_Needed__c < 0) {
		        	this.Status = 'RETURN';
		        }
			}
			
			this.QtyOrder = (this.StockCommited != null && this.QtyNeeded != null) ? (this.QtyNeeded - this.StockCommited) : 0;
			
			if(soLineItemRec.Qty_Needed__c < 0) {
				this.QtyOrder = null;
				this.StockCommited = null;
			}
			
			Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            this.Tax = soLineItemRec.Tax_Percent__c;
            if(isTaxIncludingPricing) {
                if(this.Tax == null) {
                    this.Tax = 0;
                }
                if(soLineItemRec.Kit_Price__c == null) {
                    soLineItemRec.Kit_Price__c = 0;
                }
                this.KitPrice = (soLineItemRec.Kit_Price__c * (1 + (this.Tax / 100))).setScale(2, RoundingMode.HALF_UP);
            } else {
                this.KitPrice = (soLineItemRec.Kit_Price__c != null) ? soLineItemRec.Kit_Price__c.SetScale(2, RoundingMode.HALF_UP) : soLineItemRec.Kit_Price__c;
            }
			
			this.ReatilPrice = (soLineItemRec.Retail_Price__c != null) ? soLineItemRec.Retail_Price__c.SetScale(3) : soLineItemRec.Retail_Price__c;
			this.IsFixedPrice = soLineItemRec.Fixed_Price__c;
			this.PartId = soLineItemRec.Part__c;
			this.AvailablePart = (soLineItemRec.Part__c != null) ? (soLineItemRec.Part__r.AvailableParts__c) : null;
			this.IsPart = (soLineItemRec.Part__c != null) ? true : false;
			this.IsLabour = (soLineItemRec.Labour_Code__c != null) ? true : false;
			this.IsFee = (soLineItemRec.Fee__c != null) ? true : false;
			this.SOKitHeaderId = soLineItemRec.Service_Order_Kit_Header__c;
			this.CoLineItem = (soLineItemRec.CO_Line_Item__c !=null) ? (soLineItemRec.CO_Line_Item__c ) : null;
			
			if(this.IsLabour) {
				//this.KitPrice = this.KitPrice + soLineItemRec.Labour_Tax_Amount__c;
			}
		}
	}
	public class COCardDetail {
    	public String ExemptionTaxName{set;get;}
    	public Integer TotalActiveOrders{set;get;}
    	public String PriceLevelName{set;get;}
    	
    	public COCardDetail() {
    		
    	}
    	public COCardDetail(Account customerCardInfoRec, Price_Level__c defaultPriceLevelInfo) {
			if(customerCardInfoRec != null){
				this.TotalActiveOrders = (customerCardInfoRec.CO_Headers__r.size() > 0) ? customerCardInfoRec.CO_Headers__r.size() : 0;
			}
    		if(customerCardInfoRec != null && defaultPriceLevelInfo != null){
	    		this.PriceLevelName = (customerCardInfoRec.Price_Level__c != null) ? customerCardInfoRec.Price_Level__r.Name__c : '';
	    		this.TotalActiveOrders = (customerCardInfoRec.CO_Headers__r.size() > 0) ? customerCardInfoRec.CO_Headers__r.size() : 0;
	    		this.ExemptionTaxName = '';
	    		for(Tax_Exemption__c taxExemptionRec : customerCardInfoRec.Tax_Exemptions__r) {
	    			this.ExemptionTaxName += ((taxExemptionRec.Sales_Tax_Item__c != null) ? (taxExemptionRec.Sales_Tax_Item__r.Name__c + ', ') : '');
	    		}
	    		if(this.ExemptionTaxName.length() > 2) {
	    			this.ExemptionTaxName = this.ExemptionTaxName.subString(0, this.ExemptionTaxName.length() - 2);
	    		}
    		}
    		else if(customerCardInfoRec == null && defaultPriceLevelInfo != null){
    			this.PriceLevelName = (defaultPriceLevelInfo != null) ? defaultPriceLevelInfo.Name__c : '';
	    		
	    		this.ExemptionTaxName = '';
    		}
    	}
	}	
	/**
	* Name: SOGrid
	* Description: Apex class Service Order Grid
	**/
	public class SOGrid {
		
		public SOKitHeader SOKH{Set;get;}
		
		/**
     	* Name: SOGrid
     	* Desc: Constructor
    	* @param:	(1)soKitHeaderRec -  Service_Order_Kit_Header__c - Service order Kit Header Record
					(2)soliList -List<Service_Order_Kit_Header__c> - List of Service Order Kit Header
					(3)hasChildren - Boolean  - has Children or not    			
    	* @return: 
   		**/
		public SOGrid(Service_Order_Kit_Header__c soKitHeaderRec, List<Service_Order_Line_Item__c> soliList, Boolean hasChildren) {
			this.SOKH = new SOKitHeader(soKitHeaderRec, soliList, hasChildren);
		}
	}
		/**
	* Name: SOReview
	* Description: Apex class service order review
	**/
	public class SOReview {
		
		public Decimal OdometerOnDeparture;
		public String Id;
		public List<String> KitHeaderNotes{Set;get;}
		public List<String> ManualNotes{Set;get;}
		
		/**
     	* Name: SOReview
     	* Desc: Constructor
    	* @param:	(1)soHeaderRec -  Service_Order_Header__c - Service order header Record
    	* @return: 
   		**/	
		public SOReview(Service_Order_Header__c soHeaderRec) {
			this.KitHeaderNotes = new List<String>();
			this.ManualNotes = new List<String>();
			this.Id = soHeaderRec.Id;
			this.OdometerOnDeparture = (soHeaderRec.Odometer_on_Departure__c == null) ? 0 : soHeaderRec.Odometer_on_Departure__c;
			
			if(soHeaderRec.Service_Order_Kit_Headers__r.size() > 0) {
				for(Service_Order_Kit_Header__c soKitHeaderRec : soHeaderRec.Service_Order_Kit_Headers__r) {
					if(soKitHeaderRec.Kit_Header__c != null) {
						this.KitHeaderNotes = (soKitHeaderRec.Kit_Header__r.Correction__c != null) ? soKitHeaderRec.Kit_Header__r.Correction__c.split('\n') : new List<String>();
					}
				}
			}
			this.ManualNotes = (soHeaderRec.SO_Notes_For_Customer__c != null) ? soHeaderRec.SO_Notes_For_Customer__c.split('\n') : new List<String>();
		}
	}
	
}