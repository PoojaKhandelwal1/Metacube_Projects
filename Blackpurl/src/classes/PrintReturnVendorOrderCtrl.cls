public with sharing class PrintReturnVendorOrderCtrl {
    
    public String companyLogoURL { get{return GeneralConfiguration.getCompanyLogoUrl();} private set;}
    public CustomerDetail.Company CompanyInfo{get; private set;}
    public ReturnVOHeaderWrapper returnVOHeaderRec{get; private set;}
    public VendorInfoWrapper vendorRec{get; private set;}
     
    public PrintReturnVendorOrderCtrl() {
    	String returnVOId = ApexPages.currentPage().getParameters().get('id');
    	returnVOId = BPUtility.escapeSingleQuotes(returnVOId);
    	if(!String.isBlank(returnVOId)) {
			try {
				printReturnVendorOrder(BPUtility.getEncodedString(returnVOId));
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
    }
	
	public void printReturnVendorOrder(String returnVOId) {
		returnVOId =  BPUtility.getDecodedString(returnVOId);
		List<Return_VO_Header__c> returnVOList = SOQLUtil.getReturnVOHeaderDetail(new Map<String, String>{'Id' => returnVOId  });
		if(returnVOList.size() > 0){
			returnVOHeaderRec = new ReturnVOHeaderWrapper(returnVOList[0]);
		}
		List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
		if(businessProfileList.size() > 0){
			CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
		} else{
			CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
		}
		CompanyInfo.BusinessPhone = formatphonenumber(CompanyInfo.BusinessPhone);
		if(returnVOHeaderRec.VendorId != null){
			List<Account> vendors = SOQLUtil.getVendorDetailRecord('Id', returnVOHeaderRec.VendorId);
			if(vendors.size()>0){
				vendorRec = new VendorInfoWrapper(vendors[0]);
			}
		} 
	}
	
	public class VendorInfoWrapper {
		public String VendorName{get; private set;}
	    public String VendorCode{get; private set;}
	    public String HomeEmail{get; private set;}
	    public String WorkEmail{get; private set;}
	    public String HomeNumber{get; private set;}
	    public String WorkNumber{get; private set;}
	    public String PreferredEmail{get; private set;}
	    public String PreferredPhone{get; private set;}
	    public String VendorNumber{get; private set;}
	    // Billing Address Fields
	    public String BillingStreet1{get; private set;}
	    public String BillingStreet2{get; private set;}
	    public String BillingCity{get; private set;}
	    public String BillingState{get; private set;}
	    public String BillingCountry{get; private set;}
	    public String BillingPostalCode{get; private set;}
	    
	    
	    public VendorInfoWrapper(Account vendorRec){
	    	this.VendorName = vendorRec.Name;
	    	this.VendorCode = vendorRec.Vendor_Code__c; 
	    	this.HomeEmail = (vendorRec.Email__c == null) ? '' : vendorRec.Email__c;
	    	this.WorkEmail = (vendorRec.Work_Email__c == null) ? '' : vendorRec.Work_Email__c;
	    	// Phone
	    	this.HomeNumber = (vendorRec.Home_Number__c == null ) ? '' : formatphonenumber(vendorRec.Home_Number__c);
	    	this.WorkNumber = (vendorRec.Work_Number__c == null ) ? '' : formatphonenumber(vendorRec.Work_Number__c);
	    	// Phone And Email Preffered
	    	if(vendorRec.Preferred_Email__c != null) {
	    		if(vendorRec.Preferred_Email__c == vendorRec.Email__c) {
	    			this.PreferredEmail = 'HomeEmail';
	    		} else if(vendorRec.Preferred_Email__c == vendorRec.Work_Email__c) {
	    			this.PreferredEmail = 'WorkEmail';
	    		} else if(vendorRec.Preferred_Email__c == vendorRec.Other_Email__c) {
	    			this.PreferredEmail = 'OtherEmail';
	    		}
	    	} else {
	    		this.PreferredEmail = '';
	    	}
	    	
	    	if(vendorRec.Preferred_Phone__c != null) {
	    		if(vendorRec.Preferred_Phone__c == vendorRec.Home_Number__c) {
	    			this.PreferredPhone = 'HomeNumber';
	    		} else if(vendorRec.Preferred_Phone__c == vendorRec.Mobile__c) {
	    			this.PreferredPhone = 'OtherPhone';
	    		} else if(vendorRec.Preferred_Phone__c == vendorRec.Work_Number__c) {
	    			this.PreferredPhone = 'WorkNumber';
	    		}
	    	} else {
	    		this.PreferredPhone = '';
	    	}
	    	this.VendorNumber = vendorRec.Vendor_Number__c;
	    	// Billing Address fields
	    	String billingStreet = (vendorRec.BillingStreet == null ) ? '' : vendorRec.BillingStreet;
	    	List<String> bsList = billingStreet.split('\n');
	    	this.BillingStreet1 = (bsList.size() > 0) ? bsList[0] : '';
	    	this.BillingStreet2 = (bsList.size() > 1) ? bsList[1] : '';
	    	this.BillingCity = (vendorRec.BillingCity == null) ? '' : vendorRec.BillingCity;
	    	this.BillingState = (vendorRec.BillingState == null) ? '' : vendorRec.BillingState;
	    	this.BillingCountry = (vendorRec.BillingCountry == null) ? '' : vendorRec.BillingCountry;
	    	this.BillingPostalCode = (vendorRec.BillingPostalCode == null) ? '' : vendorRec.BillingPostalCode;
	    }
	}
    	
    
    public static String formatphonenumber(String cphone) {
		String fphone = cphone.replaceAll('\\D','');
		if (fphone.length() == 10) {
			fphone = formatphonenum(fphone);
			return fphone;
		}
		else {
			return cphone;
		}
		}
		static String formatphonenum (String s) {
		s = '(' + s.substring(0, 3) + ') ' + s.substring(3, 6) + '-' + s.substring(6);
		return s;
	}
}