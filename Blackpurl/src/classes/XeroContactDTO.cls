public with sharing class XeroContactDTO extends BaseXeroDTO {
	public String Name {get; set;}
    public String FirstName {get; set;}
    public String LastName {get; set;}
    public String ContactID {get; set;}
    public String SFId {get; set;}
    public String ContactNumber {get; set;}
    public String AccountNumber {get; set;}
    public String ContactStatus {get; set;}
    public String EmailAddress {get; set;}
    public String TaxNumber{get; set;}
    
    public List<AddressWrapper> Addresses {get; set;}
    
    public List<PhoneWrapper> Phones {get; set;}
    public String Website{get; set;}
    
    public XeroContactDTO(String contactId) {
    	this.ContactID = contactId;
    }
    
    public XeroContactDTO(AccountingVendor vendorRecord) {
    	this.Phones = new List<PhoneWrapper>();
    	this.Addresses = new List<AddressWrapper>();
    	String updatedFields = vendorRecord.QBUpdatedField;
    	this.SFId = vendorRecord.Id;
    	this.ContactID = vendorRecord.XeroAccountingId;
    	this.ContactNumber = vendorRecord.VendorNumber;
    	
    	if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Vendor_Tax_Id__c'))) {
            vendorRecord.VendorTaxNumber = String.isNotBlank(vendorRecord.VendorTaxNumber) ? vendorRecord.VendorTaxNumber.abbreviate(49): vendorRecord.VendorTaxNumber;
            this.TaxNumber = vendorRecord.VendorTaxNumber;
        }
    	
    	if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Name'))) {
        	this.Name = vendorRecord.VendorName + ' ' + vendorRecord.VendorNumber;
        }
    	
    	if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('AccountNumber'))) {
            this.AccountNumber = vendorRecord.VendorAccountNumber;
        }
    	this.ContactStatus = 'ACTIVE';
    	
    	if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('Email__c') || updatedFields.contains('Work_Email__c') || updatedFields.contains('Preferred_Email__c') ||  updatedFields.contains('Other_Email__c')))) {
            this.EmailAddress = vendorRecord.VendorEmailToSync;
        }
    	
    	AddressWrapper billingAddressObj = new AddressWrapper(vendorRecord.BillingStreet1, vendorRecord.BillingStreet2,
                                                        vendorRecord.BillingCity, vendorRecord.BillingCountry,
                                                        vendorRecord.BillingState, vendorRecord.BillingPostalCode, updatedFields, true, 'POBOX');
		if(billingAddressObj.AddressLine1 != null || billingAddressObj.AddressLine2 != null || billingAddressObj.City != null || billingAddressObj.Country != null
		      || billingAddressObj.Region != null || billingAddressObj.PostalCode != null) {
            this.Addresses.add(billingAddressObj);
        }
        
        AddressWrapper shippingAddressObj = new AddressWrapper(vendorRecord.ShippingStreet1, vendorRecord.ShippingStreet2,
                                                        vendorRecord.ShippingCity, vendorRecord.ShippingCountry,
                                                        vendorRecord.ShippingState, vendorRecord.ShippingPostalCode, updatedFields, false, 'STREET');
            if(shippingAddressObj.AddressLine1 != null || shippingAddressObj.AddressLine2 != null || shippingAddressObj.City != null || shippingAddressObj.Country != null
                  || shippingAddressObj.Region != null || shippingAddressObj.PostalCode != null) {
                this.Addresses.add(shippingAddressObj);
            }
        
    	if(String.isNotBlank(vendorRecord.WorkNumber) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Work_Number__c')))) {
            this.Phones.add(new PhoneWrapper(vendorRecord.FormattedWorkNumber, 'DEFAULT'));
        }
        if(String.isNotBlank(vendorRecord.OtherPhone) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Mobile__c')))) {
            this.Phones.add(new PhoneWrapper(vendorRecord.FormattedOtherPhone, 'MOBILE'));
        }
		if(String.isNotBlank(vendorRecord.Fax) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Fax')))) {
            this.Phones.add(new PhoneWrapper(vendorRecord.Fax, 'FAX'));
        }
        
        if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Website'))) {
            if(String.isNotBlank(vendorRecord.Website) && !(vendorRecord.Website.startsWithIgnoreCase('http://') || vendorRecord.Website.startsWithIgnoreCase('https://'))){
                vendorRecord.Website = 'http://'+vendorRecord.Website;
            }
            this.Website = vendorRecord.Website;
        }
    }
    
     public XeroContactDTO(AccountingCustomer customerRecord) {
    	this.Phones = new List<PhoneWrapper>();
    	this.Addresses = new List<AddressWrapper>();
    	String updatedFields = customerRecord.QBUpdatedField;
    	this.SFId = customerRecord.Id;
    	this.ContactID = customerRecord.XeroAccountingId; 
    	this.ContactNumber = customerRecord.CustomerNumber;
    	
    	if(customerRecord.Type == 'Individual' && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('FirstName__c'))))) {
        	this.FirstName = customerRecord.FirstName;
        }
    	if(customerRecord.Type == 'Individual' && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('LastName__c'))))) {
        	this.LastName = customerRecord.LastName;
        }
    	if((customerRecord.Type == 'Individual' && !customerRecord.IsProvider) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('FirstName__c') || updatedFields.contains('LastName__c'))))) {
        	this.Name = customerRecord.FirstName + ' ' + customerRecord.LastName + ' ' + customerRecord.CustomerNumber;
        }
        else if((customerRecord.Type == 'Business' || customerRecord.IsProvider) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('Name'))))) {
        	this.Name = customerRecord.BusinessName + ' ' + customerRecord.CustomerNumber;
        }
    	this.ContactStatus = 'ACTIVE';
    	
    	if((String.isBlank(updatedFields) && String.isNotBlank(customerRecord.CustomerPreferredEmail)) || (String.isNotBlank(updatedFields) && updatedFields.contains('Preferred_Email__c') || String.isNotBlank(customerRecord.CustomerPreferredEmail))) {	
    		this.EmailAddress = customerRecord.CustomerPreferredEmail;
    	} else {
	    		if(customerRecord.Type == 'Individual') {
	    			if((String.isBlank(updatedFields) && String.isNotBlank(customerRecord.HomeEmail)) || (String.isNotBlank(updatedFields) && updatedFields.contains('Email__c'))) {
	            		this.EmailAddress = customerRecord.HomeEmail;
		        	} else if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Other_Email__c'))) {
		        		this.EmailAddress = customerRecord.OtherEmail;	
		        	}  
	    		} else if(customerRecord.Type == 'Business') {
	    		 	if((String.isBlank(updatedFields) && String.isNotBlank(customerRecord.WorkEmail))|| (String.isNotBlank(updatedFields) && updatedFields.contains('Work_Email__c'))) {
		            	this.EmailAddress = customerRecord.WorkEmail;
		        	} else if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Other_Email__c')))
	    		 		this.EmailAddress = customerRecord.OtherEmail;	
	    		 }  
    	}
    	AddressWrapper billingAddressObj = new AddressWrapper(customerRecord.BillingStreet1, customerRecord.BillingStreet2,
                                                        customerRecord.BillingCity, customerRecord.BillingCountry,
                                                        customerRecord.BillingState, customerRecord.BillingPostalCode, updatedFields, true, 'POBOX');
		if(billingAddressObj.AddressLine1 != null || billingAddressObj.AddressLine2 != null || billingAddressObj.City != null || billingAddressObj.Country != null
		      || billingAddressObj.Region != null || billingAddressObj.PostalCode != null) {
            this.Addresses.add(billingAddressObj);
        }
        
        AddressWrapper shippingAddressObj = new AddressWrapper(customerRecord.ShippingStreet1, customerRecord.ShippingStreet2,
                                                        customerRecord.ShippingCity, customerRecord.ShippingCountry,
                                                        customerRecord.ShippingState, customerRecord.ShippingPostalCode, updatedFields, false, 'STREET');
            if(shippingAddressObj.AddressLine1 != null || shippingAddressObj.AddressLine2 != null || shippingAddressObj.City != null || shippingAddressObj.Country != null
                  || shippingAddressObj.Region != null || shippingAddressObj.PostalCode != null) {
                this.Addresses.add(shippingAddressObj);
            }
        if(customerRecord.Type == 'Individual'){
	    	if(String.isNotBlank(customerRecord.HomeNumber) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Home_Number__c')))) {
	            this.Phones.add(new PhoneWrapper(customerRecord.FormattedHomeNumber, 'DEFAULT'));
	        }
	        if(String.isNotBlank(customerRecord.OtherPhone) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Mobile__c')))) {
	            this.Phones.add(new PhoneWrapper(customerRecord.FormattedOtherPhone, 'MOBILE'));
	        }
        }
        else if(customerRecord.Type == 'Business'){
	    	if(String.isNotBlank(customerRecord.WorkNumber) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Work_Number__c')))) {
	            this.Phones.add(new PhoneWrapper(customerRecord.FormattedWorkNumber, 'DEFAULT'));
	        }
	        if(String.isNotBlank(customerRecord.OtherPhone) && (String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Mobile__c')))) {
	            this.Phones.add(new PhoneWrapper(customerRecord.FormattedOtherPhone, 'MOBILE'));
	        }
        }
    }
    
    public class AddressWrapper {
        public String AddressLine1;
        public String AddressLine2;
        public String City;
        public String Country;
        public String Region;
        public String PostalCode;
        public String AddressType;
        
        public AddressWrapper() {}
        
        public AddressWrapper(String Line1, String Line2, String City, String Country, String Region, String PostalCode,
                          String updatedFields, Boolean isBillingAddress, String AddressType) {
            if(isBillingAddress) {
                if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('BillingStreet') || 
                        updatedFields.contains('BillingCity') || updatedFields.contains('BillingCountry') || updatedFields.contains('BillingState')
                        || updatedFields.contains('BillingPostalCode')))) {
                    this.AddressLine1 = Line1;
                    this.AddressLine2 = Line2;
                    this.City = City;
                    this.Country = Country;
                    this.Region = Region;
                    this.PostalCode = PostalCode;
                    this.AddressType = AddressType;
                }
            } else {
                if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('ShippingStreet') || 
                        updatedFields.contains('ShippingCity') || updatedFields.contains('ShippingCountry') || updatedFields.contains('ShippingState')
                        || updatedFields.contains('ShippingPostalCode')))) {
                    
                    this.AddressLine1 = Line1;
                    this.AddressLine2 = Line2;
                    this.City = City;
                    this.Country = Country;
                    this.Region = Region;
                    this.PostalCode = PostalCode;
                    this.AddressType = AddressType;
                }
            }        
                              
            if(String.isNotBlank(this.AddressLine1) && this.AddressLine1.trim().length() > 255) {
                this.AddressLine1 = this.AddressLine1.substring(0, 255);
            }
            if(String.isNotBlank(this.AddressLine2) && this.AddressLine2.trim().length() > 255) {
                this.AddressLine2 = this.AddressLine2.substring(0, 255);
            }
            if(String.isNotBlank(this.City) && this.City.trim().length() > 255) {
                this.City = this.City.substring(0, 255);
            }
            if(String.isNotBlank(this.Country) && this.Country.trim().length() > 255) {
                this.Country = this.Country.substring(0, 255);
            }
            if(String.isNotBlank(this.Region) && this.Region.trim().length() > 255) {
                this.Region = this.Region.substring(0, 255);
            }
            if(String.isNotBlank(this.PostalCode) && this.PostalCode.trim().length() > 31)  {
                this.PostalCode = this.PostalCode.substring(0, 31);
            }
        }
    } 
    
    public class PhoneWrapper {
    	public String PhoneNumber;
        public String PhoneType;
        
        public PhoneWrapper() {}
        
        public PhoneWrapper(String PhoneNumber, String PhoneType) {
        	if(String.isNotBlank(PhoneNumber)) {
        		this.PhoneNumber = PhoneNumber;
        	}
            this.PhoneType = PhoneType;
        }
    }
}
