public with sharing class VendorService {
    
    public static Integer MAX_RECORDS_UPDATE_LIMIT = 500;
    
	public static void syncVendors(Set<Id> vendorIds){
        AccSync_Vendor_Batch.runVendorsForSync(vendorIds, 10, 0, null);
    }
    
    public static List<Log__c> syncAccountingServer(AccountingVendor vendorRecord, List<Account> accountListToUpdate, Set<Id> vendorRecordIdSetToRetry, Integer retryAttemptNumber){
    	List<Log__c> errorLogToInsert = new List<Log__c>();
    	if(QBUtil.isQBEnabled()) {
	        errorLogToInsert = syncToQuickBooks(vendorRecord, accountListToUpdate, vendorRecordIdSetToRetry, retryAttemptNumber);
    	}
    	return errorLogToInsert;
    }
    public static QuickBooksVendor readFromQuickBooks(AccountingVendor vendorRecord, List<Log__c> errorLogList) {
        try {
            if(vendorRecord.SyncToken != null && String.isNotBlank(vendorRecord.AccountingId)) {
                HttpResponse getResponse = QuickbookConnector.getRequestFromQuickBooks('vendor', vendorRecord.AccountingId);
                if(getResponse.getStatusCode() == 200) { 
                    ResponseQuickBooksVendor vendorGetResponse = (ResponseQuickBooksVendor)System.JSON.deserialize(getResponse.getBody(), ResponseQuickBooksVendor.class);
                    return vendorGetResponse.Vendor;
                } else {
                    errorLogList.add(new LogService().createErrorLog('VendorService', 'readFromQuickBooks()', getResponse.getBody(), getResponse.getStatusCode(), null, 
                          vendorRecord + '', LogService.QuickBooks, false));
                }
            } else if(vendorRecord.accountingResponse != null && String.isBlank(vendorRecord.AccountingId)) {
                QuickBookQueryService.ResponseQuickBooks qbQueryResponse = QuickBookQueryService.getRecordsByFieldName('Vendor', 'DisplayName', '\''+getQuickbooksVendorDisplayNameFromCustomerRecord(vendorRecord)+'\'', '=', 0, null);
                
                if(qbQueryResponse != null && qbQueryResponse.Vendor != null && qbQueryResponse.Vendor.size() == 1) { 
                   return qbQueryResponse.Vendor[0];
                }
                
            } 
        } catch (Exception e) {
            errorLogList.add(new LogService().createErrorLog('VendorService', 'readFromQuickBooks()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              vendorRecord+'', LogService.QuickBooks, false,'Info'));
        }
        return null; 
    }
    
	public static List<Log__c> syncToQuickBooks(AccountingVendor vendorRecord, List<Account> accountListToUpdate, Set<Id> vendorRecordIdSetToRetry, Integer retryAttempt) {
        Account acc = new Account();
        acc.Id = vendorRecord.Id;
        List<Log__c> errorLogList = new List<Log__c>();
		try {
            QuickBooksVendor qbVendor = readFromQuickBooks(vendorRecord, errorLogList);
            if(qbVendor != null) {  // true when we have a successful read from QB  for the vendor 
                //On a retry for read time out, check if the timed out request,actually went on to be successful 
                if(retryAttempt > 0 && (Integer.valueOf(vendorRecord.SyncToken) + 1 == Integer.valueOf(qbVendor.SyncToken)) ) { 
                    acc.Vendor_AccountingId__c = qbVendor.Id;
                    acc.Vendor_SyncToken__c = qbVendor.SyncToken;
                    acc.Vendor_AvailForQBSync__c = false;
                    acc.Vendor_AccountingLastSyncTime__c = system.now();
                    acc.Vendor_QB_Updated_Fields__c = null;
                    acc.Vendor_AccountingResponse__c = qbVendor + ' ' + LogService.METHOD_PARAM_SEPERATOR +'\n\n' + 'Sync request succeed on previous request';
                    accountListToUpdate.add(acc);
                    if(vendorRecordIdSetToRetry.contains(vendorRecord.Id)) {
	                    vendorRecordIdSetToRetry.remove(vendorRecord.Id);
	                }
                    return errorLogList;
                }
                vendorRecord.SyncToken = qbVendor.SyncToken;
                vendorRecord.AccountingId = qbVendor.Id;
            }
			QuickBooksVendor QV = new QuickBooksVendor(vendorRecord);
			String vendorJSONBody = system.JSON.serialize(QV, true);
			acc.Vendor_AccountingResponse__c = vendorJSONBody;
			HttpResponse res = QuickbookConnector.sendRequestToQuickBooks('vendor', vendorJSONBody);
			System.debug(res);
			if(res.getStatusCode() == 200) { 
	        	String resParams = res.getBody();
	        	ResponseQuickBooksVendor responceQV = (ResponseQuickBooksVendor)System.JSON.deserialize(resParams, ResponseQuickBooksVendor.class);
	        	acc.Vendor_AccountingId__c = responceQV.Vendor.Id;
	        	acc.Vendor_SyncToken__c = responceQV.Vendor.SyncToken;
	        	acc.Vendor_AccountingResponse__c += '\n\n' + resParams;
	        	acc.Vendor_AvailForQBSync__c = false;
	        	acc.Vendor_AccountingLastSyncTime__c = system.now();
	        	acc.Vendor_QB_Updated_Fields__c = null;
	        	if(vendorRecordIdSetToRetry.contains(vendorRecord.Id)) {
                    vendorRecordIdSetToRetry.remove(vendorRecord.Id);
                }
	        } else {
	        	acc.Vendor_AccountingResponse__c = res.getBody();
	        	acc.Vendor_AccountingResponse__c += '\n\n' + res.getStatus();
	        	errorLogList.add(new LogService().createErrorLog('VendorService', 'syncToQuickBooks() - saveRequest', res.getBody(), res.getStatusCode(), null, 
                                              QV + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QuickBooks, false));
	        }
		}catch(Exception e) {
        	acc.Vendor_AvailForQBSync__c = true;
        	acc.Vendor_AccountingResponse__c = e.getMessage();
            if(e.getTypeName() == 'System.CalloutException' && e.getMessage() == Constants.READ_TIMED_OUT_ERROR_MESSAGE) {
                vendorRecordIdSetToRetry.add(vendorRecord.Id);
                if(retryAttempt == null || retryAttempt == 0) {
                    errorLogList.add(new LogService().createErrorLog('VendorService', 'syncToQuickBooks()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              vendorRecord + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QuickBooks, false, 'Info'));
                } else if(retryAttempt == QuickbookConnector.QUICKBOOKS_MAX_RETRY_COUNT){
                    errorLogList.add(new LogService().createErrorLog('VendorService', 'syncToQuickBooks()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              vendorRecord + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QuickBooks, false, 'Error'));
                }
            } else {
                errorLogList.add(new LogService().createErrorLog('VendorService', 'syncToQuickBooks()', e.getMessage(), LogService.NOT_APPLICABLE, e.getStackTraceString(), 
                                              vendorRecord + LogService.METHOD_PARAM_SEPERATOR + accountListToUpdate, LogService.QuickBooks, false));
            }
        }
        if(accountListToUpdate.size() > MAX_RECORDS_UPDATE_LIMIT){
        	AccSync_Vendor_Batch.updateVendors(accountListToUpdate);
        	accountListToUpdate = new List<Account>();
        }
        accountListToUpdate.add(acc);
        return errorLogList;
    } 
    public static String getQuickbooksVendorDisplayNameFromCustomerRecord(AccountingVendor vendorRecord) {
        String vendorDisplayName = vendorRecord.VendorName;
        vendorDisplayName = ((vendorDisplayName.trim().length() > 90) ? vendorDisplayName.trim().substring(0,90) : vendorDisplayName.trim());
        vendorDisplayName = vendorDisplayName + ' ' + vendorRecord.VendorNumber;
        return vendorDisplayName;
    }
    /*
    *   START : Quickbooks Vendor wrapper
    */
    public class QuickBooksVendor {
         
     	public String Id;
     	public String SyncToken;
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
    	public String AcctNum;
    	
    	public QuickBooksVendor(AccountingVendor vendorRecord) {
    	    String updatedFields = vendorRecord.QBUpdatedField;
    		this.Id = vendorRecord.AccountingId;
    		this.SyncToken = vendorRecord.SyncToken;
    		this.sparse = true;
    		
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Name')) || String.isBlank(vendorRecord.AccountingId)) {
    		    vendorRecord.VendorName = ((vendorRecord.VendorName.trim().length() > 90) ? vendorRecord.VendorName.trim().substring(0,90) : vendorRecord.VendorName.trim());
    		    this.DisplayName = vendorRecord.VendorName + ' ' + vendorRecord.VendorNumber;
    		    if(String.isNotBlank(vendorRecord.VendorName)) {
    		        this.CompanyName = ((vendorRecord.VendorName.trim().length() > 50) ? vendorRecord.VendorName.trim().substring(0,50) : vendorRecord.VendorName.trim());
    		    }
    		}
    		
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Active__c'))) {
                this.Active = vendorRecord.Active;
            }
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Work_Number__c'))) {
                this.PrimaryPhone = new QuickBooksPhoneWrapper(vendorRecord.WorkNumber);
            }
            if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Mobile__c'))) {
                this.AlternatePhone = new QuickBooksPhoneWrapper(vendorRecord.OtherPhone);
                this.Mobile = new QuickBooksPhoneWrapper(vendorRecord.OtherPhone);
            }
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Fax'))) {
                this.Fax = new QuickBooksPhoneWrapper(vendorRecord.Fax);
            }
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Email__c'))) {
                this.PrimaryEmailAddr = new QuickBooksEmailWrapper(vendorRecord.WorkEmail);
            }
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('Website'))) {
                if(String.isNotBlank(vendorRecord.Website) && !(vendorRecord.Website.startsWithIgnoreCase('http://') || vendorRecord.Website.startsWithIgnoreCase('https://'))){
	                vendorRecord.Website = 'http://'+vendorRecord.Website;
	            }
	            this.WebAddr = new QuickBooksWebAddrWrapper(vendorRecord.Website);
            }
    		if(String.isBlank(updatedFields) || (String.isNotBlank(updatedFields) && updatedFields.contains('AccountNumber'))) {
                this.AcctNum = vendorRecord.VendorAccountNumber;
            }
    		
    		QuickBooksAddressWrapper qbBillingAddObj = new QuickBooksAddressWrapper(vendorRecord.BillingStreet1, vendorRecord.BillingStreet2,
                                                        vendorRecord.BillingCity, vendorRecord.BillingCountry,
                                                        vendorRecord.BillingState, vendorRecord.BillingPostalCode, updatedFields, true);
    		if(qbBillingAddObj.Line1 != null || qbBillingAddObj.Line2 != null || qbBillingAddObj.City != null || qbBillingAddObj.Country != null
    		      || qbBillingAddObj.CountrySubDivisionCode != null || qbBillingAddObj.PostalCode != null) {
                this.BillAddr = qbBillingAddObj;
            }
            
            QuickBooksAddressWrapper qbShippingAddObj = new QuickBooksAddressWrapper(vendorRecord.ShippingStreet1, vendorRecord.ShippingStreet2,
                                                        vendorRecord.ShippingCity, vendorRecord.ShippingCountry,
                                                        vendorRecord.ShippingState, vendorRecord.ShippingPostalCode, updatedFields, false);
            if(qbShippingAddObj.Line1 != null || qbShippingAddObj.Line2 != null || qbShippingAddObj.City != null || qbShippingAddObj.Country != null
                  || qbShippingAddObj.CountrySubDivisionCode != null || qbShippingAddObj.PostalCode != null) {
                this.ShipAddr = qbShippingAddObj;
            }
    		/*this.BillAddr = new QuickBooksAddressWrapper(vendorRecord.BillingStreet1, vendorRecord.BillingStreet2,
    													vendorRecord.BillingCity, vendorRecord.BillingCountry,
    													vendorRecord.BillingState, vendorRecord.BillingPostalCode, updatedFields, true);
    		this.ShipAddr = new QuickBooksAddressWrapper(vendorRecord.ShippingStreet1, vendorRecord.ShippingStreet2,
    													vendorRecord.ShippingCity, vendorRecord.ShippingCountry,
    													vendorRecord.ShippingState, vendorRecord.ShippingPostalCode, updatedFields, false);*/
    		
    	}
    }
     
     public class QuickBooksPhoneWrapper {
     	public String FreeFormNumber;
     	public QuickBooksPhoneWrapper(String freeFormNumber) {
     		if(String.isNotBlank(freeFormNumber)) {
     			this.FreeFormNumber = ((freeFormNumber.trim().length() > 21) ? freeFormNumber.trim().substring(0,21) : freeFormNumber.trim());    
     		}
    	}
     }
     
     public class QuickBooksEmailWrapper{
     	public String Address;
     	public QuickBooksEmailWrapper(String Address) {
    		this.Address = Address;
    	}
     }
     
     public class QuickBooksWebAddrWrapper{
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
                              
            if(String.isNotBlank(this.Line1) && this.Line1.trim().length() > 255) {
                this.Line1 = this.Line1.substring(0, 255);
            }
            if(String.isNotBlank(this.Line2) && this.Line2.trim().length() > 255) {
                this.Line2 = this.Line2.substring(0, 255);
            }
            if(String.isNotBlank(this.City) && this.City.trim().length() > 255) {
                this.City = this.City.substring(0, 255);
            }
            if(String.isNotBlank(this.Country) && this.Country.trim().length() > 255) {
                this.Country = this.Country.substring(0, 255);
            }
            if(String.isNotBlank(this.CountrySubDivisionCode) && this.CountrySubDivisionCode.trim().length() > 255) {
                this.CountrySubDivisionCode = this.CountrySubDivisionCode.substring(0, 255);
            }
            if(String.isNotBlank(this.PostalCode) && this.PostalCode.trim().length() > 31)  {
                this.PostalCode = this.PostalCode.substring(0, 31);
            }
        }
    } 
     
    public class ResponseQuickBooksVendor {
     	public QuickBooksVendor vendor;
    }
}