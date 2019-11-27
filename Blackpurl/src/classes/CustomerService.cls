global with sharing class CustomerService {
	
	public static Integer MAX_RECORDS_UPDATE_LIMIT = 500;
    
	global static void syncCustomers(Set<Id> customerIds, Set<Id> vendorIds) {
		if(customerIds.size() > 0 && vendorIds.size() > 0) {
			AccSync_Customer_Batch.runCustomersAndVendorsForSync(customerIds, vendorIds, 10, null);
		} else if(customerIds.size() > 0) {
			AccSync_Customer_Batch.runCustomersForSync(customerIds, 10, 0, null);
		}
    }
    
    public static List<Log__c> syncAccountingServer(AccountingCustomer customerRecord, List<Account> accountListToUpdate, Set<Id> customerRecordIdSetToRetry, Integer retrialAttemptNumber){
    	List<Log__c> errorLogToInsert = new List<Log__c>();
    	if(QBUtil.isQBEnabled()) {
    		errorLogToInsert = syncToQuickBooks(customerRecord, accountListToUpdate, customerRecordIdSetToRetry, retrialAttemptNumber);
    	}
    	return errorLogToInsert;
    }
    
	public static QuickBooksCustomer readFromQuickBooks(AccountingCustomer customerRecord, List<Log__c> errorLogList) {
        try {
            if(customerRecord.SyncToken != null && String.isNotBlank(customerRecord.AccountingId)) { 
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('customer', customerRecord.AccountingId);
                if(getResponse.getStatusCode() == 200) { 
                    ResponseQuickBooksCustomer customerGetResponce = (ResponseQuickBooksCustomer)System.JSON.deserialize(getResponse.getBody(), ResponseQuickBooksCustomer.class);
                    return customerGetResponce.Customer;
                } else {
                    errorLogList.add(new LogService().createErrorLog('CustomerService', 'readFromQuickBooks()', getResponse.getBody(), getResponse.getStatusCode(), null, 
                                              customerRecord+'', LogService.QUICKBOOKS, false)); 
                }
            } else if(customerRecord.accountingResponse != null && String.isBlank(customerRecord.AccountingId)) {
                //Check if the customer already exists on quickbooks
                QuickBookQueryService.ResponseQuickBooks qbQueryResponse = QuickBookQueryService.getRecordsByFieldName('Customer', 'DisplayName', '\''+getQuickbooksCustomerDisplayNameFromCustomerRecord(customerRecord)+'\'', '=', 0, null);
                
                if(qbQueryResponse != null && qbQueryResponse.Customer != null && qbQueryResponse.Customer.size() == 1) { 
                    return qbQueryResponse.Customer[0];
                }
            } 
        } catch (Exception e) {
            errorLogList.add(new LogService().createErrorLog('CustomerService', 'readFromQuickBooks()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              customerRecord+'', LogService.QuickBooks, false,'Info'));
        }
        return null;
    }
    
	public static List<Log__c> syncToQuickBooks(AccountingCustomer customerRecord, List<Account> accountListToUpdate, Set<Id> customerRecordIdSetToRetry, Integer retrialAttemptNumber) {
        Account acc = new Account();
        acc.Id = customerRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>();
        try{
			QuickBooksCustomer qbCustomer = readFromQuickBooks(customerRecord, errorLogList);
            if(qbCustomer != null) {  // true when we have a successful read from QB  for the customer 
                //On a retry for read time out, check if the timed out request,actually went on to be successful 
                if(retrialAttemptNumber > 0 && (Integer.valueOf(customerRecord.SyncToken) + 1 == Integer.valueOf(qbCustomer.SyncToken)) ) { 
                    acc.AccountingId__c = qbCustomer.Id;
                    acc.SyncToken__c = qbCustomer.SyncToken;
                    acc.availForQBSync__c = false;
                    acc.accountingLastSyncTime__c = system.now();
                    acc.QB_Updated_Fields__c = null;
                    acc.AccountingResponse__c = qbCustomer + ' ' + LogService.METHOD_PARAM_SEPERATOR +'\n\n' + 'Sync request succeed on previous request';
                    accountListToUpdate.add(acc);
                    if(customerRecordIdSetToRetry.contains(customerRecord.Id)) {
	                    customerRecordIdSetToRetry.remove(customerRecord.Id);
	                }
                    return errorLogList;
                }
                customerRecord.SyncToken = qbCustomer.SyncToken;
                customerRecord.AccountingId = qbCustomer.Id;
            }
			QuickBooksCustomer QC = new QuickBooksCustomer(customerRecord);
			String customerJSONBody = system.JSON.serialize(QC, true);
			HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('customer', customerJSONBody);
			system.debug(res);
			acc.AccountingResponse__c = customerJSONBody;
    		if(res.getStatusCode() == 200) {
	        	String resParams = res.getBody();
	        	acc.AccountingResponse__c += res.getBody();
	        	ResponseQuickBooksCustomer customerPostResponse = (ResponseQuickBooksCustomer)system.JSON.deserialize(resParams, ResponseQuickBooksCustomer.class);
	        	acc.AccountingId__c = customerPostResponse.Customer.Id; 
	        	acc.SyncToken__c = customerPostResponse.Customer.SyncToken;
	        	acc.AccountingResponse__c += resParams;
	        	acc.availForQBSync__c = false;
	        	acc.accountingLastSyncTime__c = system.now();
	        	acc.QB_Updated_Fields__c = null;
                if(customerRecordIdSetToRetry.contains(customerRecord.Id)) {
	        	    customerRecordIdSetToRetry.remove(customerRecord.Id);
	        	}
	        } else {
	        	acc.AccountingResponse__c += res.getBody();
	        	acc.AccountingResponse__c += '\n\n'+res.getStatus();
	        	errorLogList.add(new LogService().createErrorLog('CustomerService', 'syncToQuickBooks() -  post request to save', res.getBody(), res.getStatusCode(), null, 
                                          customerJSONBody + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QUICKBOOKS,false));
	        }
			
	 	} catch(Exception e) {
 			acc.availForQBSync__c = true;
    		acc.AccountingResponse__c = e.getMessage();
    		
            if(e.getTypeName() == 'System.CalloutException' && e.getMessage() == Constants.READ_TIMED_OUT_ERROR_MESSAGE) {
                customerRecordIdSetToRetry.add(customerRecord.Id);
                if(retrialAttemptNumber == null || retrialAttemptNumber == 0) {
	                errorLogList.add(new LogService().createErrorLog('CustomerService', 'syncToQuickBooks() - First sync retry', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
	                                              customerRecord + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QUICKBOOKS,false, 'Info'));
	            } else if(retrialAttemptNumber == QuickbookConnector.QUICKBOOKS_MAX_RETRY_COUNT) {
	                errorLogList.add(new LogService().createErrorLog('CustomerService', 'syncToQuickBooks() - Last retry attempt', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
	                                              customerRecord + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QUICKBOOKS,false, 'Error'));
	            }
            } else {
                errorLogList.add(new LogService().createErrorLog('CustomerService', 'syncToQuickBooks()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              customerRecord + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QUICKBOOKS, false));
            }
        }
        if(accountListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
        	AccSync_Customer_Batch.updateCustomers(accountListToUpdate);
        	accountListToUpdate = new List<Account>();
        }
        accountListToUpdate.add(acc);
        
        return errorLogList;
    } 
    public static String getQuickbooksCustomerDisplayNameFromCustomerRecord(AccountingCustomer customerRecord) {
        String customerDisplayName;
        if(customerRecord.Type != null && customerRecord.Type == 'Individual' && !customerRecord.IsProvider) {
            customerDisplayName = customerRecord.FirstName + ' ' + customerRecord.LastName;
        } else if((customerRecord.Type != null && customerRecord.Type == 'Business') || customerRecord.IsProvider) {
            customerDisplayName = customerRecord.BusinessName;
        }

        if(String.isNotBlank(customerDisplayName)) {
            if(customerDisplayName.trim().length() > 90) {
                customerDisplayName =  customerDisplayName.substring(0,90) + customerRecord.CustomerNumber;
            } else {
                customerDisplayName =  customerDisplayName + ' ' + customerRecord.CustomerNumber;
            }
        }
        return customerDisplayName;
    }
    public class QuickBooksCustomer{
     	public String Id;
     	public String SyncToken;
    	public String GivenName;
    	public String MiddleName;
    	public String FamilyName;
    	public String DisplayName;
    	public String CompanyName;
    	public Boolean Active;
    	public Boolean sparse;
    	public QuickBooksPhoneWrapper PrimaryPhone;
    	public QuickBooksPhoneWrapper AlternatePhone;
    	public QuickBooksPhoneWrapper Mobile;
    	public QuickBooksPhoneWrapper Fax;
    	public QuickBooksEmailWrapper PrimaryEmailAddr;
    	public QuickBooksWebAddrWrapper WebAddr;
    	public QuickBooksAddressWrapper BillAddr;
    	public QuickBooksAddressWrapper ShipAddr;
    	
    	public QuickBooksCustomer(AccountingCustomer customerRecord) {
    	    String updatedFields = customerRecord.QBUpdatedField;
    		this.Id = customerRecord.AccountingId;
    		this.SyncToken = customerRecord.SyncToken;
    		this.sparse = true;
    		
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('FirstName__c'))) {
    		    this.GivenName = customerRecord.FirstName; 
    		}
    		if(String.isNotBlank(this.GivenName) &&  this.GivenName.trim().length() > 25){
    			this.GivenName = this.GivenName.substring(0,25);
    		}
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('LastName__c'))) {
                this.FamilyName = customerRecord.LastName;
    		}
    		if(String.isNotBlank(this.FamilyName) && this.FamilyName.trim().length() > 25) {
    			this.FamilyName =  this.FamilyName.substring(0,25);
    		}
    		
    		if(customerRecord.Type != null && customerRecord.Type == 'Individual' && !customerRecord.IsProvider) {
		   		this.DisplayName = customerRecord.FirstName + ' ' + customerRecord.LastName;
		   	} else if((customerRecord.Type != null && customerRecord.Type == 'Business') || customerRecord.IsProvider) {
		   		this.DisplayName = customerRecord.BusinessName;
		   	}
   	
    		if(String.isNotBlank(this.DisplayName))	{
    			if(this.DisplayName.trim().length() > 90) {
    				this.DisplayName =  this.DisplayName.substring(0,90) + customerRecord.CustomerNumber;
    			} else {
    				this.DisplayName =  this.DisplayName + ' ' + customerRecord.CustomerNumber;
    			}
    		}
    		if(customerRecord.Type != null && customerRecord.Type == 'Individual') {
    			this.CompanyName = customerRecord.Company;
    		} else if(customerRecord.Type != null && customerRecord.Type == 'Business') {
    			this.CompanyName = customerRecord.BusinessName;
    		}
    		if(String.isNotBlank(this.CompanyName) && this.CompanyName.trim().length() > 50) {
    			this.CompanyName =  this.CompanyName.substring(0,50);
    		}
    		
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Active__c'))) {
                this.Active = customerRecord.Active;
            }
    		if(customerRecord.Type == 'Business') {
    			if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Work_Number__c'))) {
	                this.PrimaryPhone = new QuickBooksPhoneWrapper(customerRecord.WorkNumber);
	            }
    		
	            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Work_Email__c'))) {
	                this.PrimaryEmailAddr = new QuickBooksEmailWrapper(customerRecord.WorkEmail);
	            }
    		} else if(customerRecord.Type == 'Individual') {
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Home_Number__c'))) {
	                this.PrimaryPhone = new QuickBooksPhoneWrapper(customerRecord.HomeNumber);
	            }
	            
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Email__c'))) {
	                this.PrimaryEmailAddr = new QuickBooksEmailWrapper(customerRecord.HomeEmail);
	            }
    		}
            
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Mobile__c'))) {
                this.AlternatePhone = new QuickBooksPhoneWrapper(customerRecord.OtherPhone);
                this.Mobile = new QuickBooksPhoneWrapper(customerRecord.OtherPhone);
            }
            
            QuickBooksAddressWrapper qbBillingAddObj = new QuickBooksAddressWrapper(customerRecord.BillingStreet1, customerRecord.BillingStreet2,
                                                        customerRecord.BillingCity, customerRecord.BillingCountry,
                                                        customerRecord.BillingState, customerRecord.BillingPostalCode, updatedFields, true);
            if(qbBillingAddObj.Line1 != null || qbBillingAddObj.Line2 != null || qbBillingAddObj.City != null || qbBillingAddObj.Country != null
                  || qbBillingAddObj.CountrySubDivisionCode != null || qbBillingAddObj.PostalCode != null) {
                this.BillAddr = qbBillingAddObj;
            }
            
            QuickBooksAddressWrapper qbShippingAddObj = new QuickBooksAddressWrapper(customerRecord.ShippingStreet1, customerRecord.ShippingStreet2,
                                                        customerRecord.ShippingCity, customerRecord.ShippingCountry,
                                                        customerRecord.ShippingState, customerRecord.ShippingPostalCode, updatedFields, false);
            if(qbShippingAddObj.Line1 != null || qbShippingAddObj.Line2 != null || qbShippingAddObj.City != null || qbShippingAddObj.Country != null
                  || qbShippingAddObj.CountrySubDivisionCode != null || qbShippingAddObj.PostalCode != null) {
                this.ShipAddr = qbShippingAddObj;
            }
    		/*this.BillAddr = new QuickBooksAddressWrapper(customerRecord.BillingStreet1, customerRecord.BillingStreet2,
    													customerRecord.BillingCity, customerRecord.BillingCountry,
    													customerRecord.BillingState, customerRecord.BillingPostalCode, updatedFields, true);
    		this.ShipAddr = new QuickBooksAddressWrapper(customerRecord.ShippingStreet1, customerRecord.ShippingStreet2,
    													customerRecord.ShippingCity, customerRecord.ShippingCountry,
    													customerRecord.ShippingState, customerRecord.ShippingPostalCode, updatedFields, false);*/
    	}
     }
     
     public class QuickBooksPhoneWrapper{
     	public String FreeFormNumber;
     	public QuickBooksPhoneWrapper(String FreeFormNumber) {
			this.FreeFormNumber = FreeFormNumber;  
			if(!String.isBlank(this.FreeFormNumber) &&  this.FreeFormNumber.trim().length() > 21)	{
    			this.FreeFormNumber =  this.FreeFormNumber.substring(0,21);
    		}  		
    	}
     }
     
     public class QuickBooksEmailWrapper{
     	public String Address;
     	public QuickBooksEmailWrapper(String Address) {
    		this.Address = Address;
    	}
     }
     
     public class QuickBooksWebAddrWrapper {
     	public String URI;
     	public QuickBooksWebAddrWrapper(String URI) { 
    		this.URI = URI;
    	}
     } 
     
     public class QuickBooksAddressWrapper {
     	public String Line1;
     	public String Line2;
     	public String City;
     	public String Country;
     	public String CountrySubDivisionCode;
     	public String PostalCode;
     	
     	public QuickBooksAddressWrapper() {
     	    
     	}
     	public QuickBooksAddressWrapper(String Line1, String Line2, String City, String Country, String CountrySubDivisionCode, String PostalCode,
     	                  String updatedFields, Boolean isBillingAddress) {
     	                      
            if(isBillingAddress) {
                if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('BillingStreet') || 
		                updatedFields.contains('BillingCity') || updatedFields.contains('BillingCountry') || updatedFields.contains('BillingState')
		                || updatedFields.contains('BillingPostalCode')))) {
                    this.Line1 = Line1;
                    this.Line2 = Line2;
                    this.City = City;
                    this.Country = Country;
                    this.CountrySubDivisionCode = CountrySubDivisionCode;
                    this.PostalCode = PostalCode;
                }
            } else {
                if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && (updatedFields.contains('ShippingStreet') || 
	                    updatedFields.contains('ShippingCity') || updatedFields.contains('ShippingCountry') || updatedFields.contains('ShippingState')
	                    || updatedFields.contains('ShippingPostalCode')))) {
                    
                    this.Line1 = Line1;
                    this.Line2 = Line2;
                    this.City = City;
                    this.Country = Country;
                    this.CountrySubDivisionCode = CountrySubDivisionCode;
                    this.PostalCode = PostalCode;
                }
            }	                      
    		if(String.isNotBlank(this.Line1) && this.Line1.trim().length() > 500) {
    			this.Line1 =  this.Line1.substring(0,500);
    		}
    		if(String.isNotBlank(this.Line2) && this.Line2.trim().length() > 500) {
    			this.Line2 =  this.Line2.substring(0,500);
    		}
    		if(String.isNotBlank(this.City) && this.City.trim().length() > 255) {
    			this.City =  this.City.substring(0,255);
    		}
    		if(String.isNotBlank(this.Country) && this.Country.trim().length() > 255) {
    			this.Country =  this.Country.substring(0,255);
    		}
    		if(String.isNotBlank(this.CountrySubDivisionCode) && this.CountrySubDivisionCode.trim().length() > 255)	{
    			this.CountrySubDivisionCode =  this.CountrySubDivisionCode.substring(0,255);
    		}
    		if(String.isNotBlank(this.PostalCode) && this.PostalCode.trim().length() > 31)	{
    			this.PostalCode =  this.PostalCode.substring(0,31);
    		}
        }
    }
     
    public class ResponseQuickBooksCustomer{
        public QuickBooksCustomer customer;
    }
}