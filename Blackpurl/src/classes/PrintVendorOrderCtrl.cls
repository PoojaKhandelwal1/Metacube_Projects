public with sharing class PrintVendorOrderCtrl {

    public String companyLogoURL { get{return GeneralConfiguration.getCompanyLogoUrl();} private set;}
	public VendorOrderWrapper vendorOrderDetailObj {get; private set;}
    
    public PrintVendorOrderCtrl(){
    	vendorOrderDetailObj = new VendorOrderWrapper();
		
		Id voHeaderId;
		String voHeaderIdStr = ApexPages.currentPage().getParameters().get('id');
		
		if(!String.isBlank(voHeaderIdStr)) {
			try {
				voHeaderId = Id.valueOf(voHeaderIdStr);
				getVODetails(BPUtility.getEncodedString(voHeaderId));
			} catch(Exception e) {
				System.debug(e.getMessage());
			}
		}
    }
    
    /**
     * Name: getCOInvoiceDetails
     * Desc: 
     * @param:  (1) coInvoiceIdStr
     * @return: String - JSON String
    **/
    public void getVODetails(String voHeaderIdStr) {
    	if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Line_Item_Group__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectFieldIsAccessible('Vendor_Order_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
    	
        voHeaderIdStr = BPUtility.getDecodedString(voHeaderIdStr);
        Id voHeaderId = voHeaderIdStr;
        String fieldName = 'Id';
        String fieldValue = voHeaderId;
        String query;   
        query = 'SELECT '; 
        for(String fieldAPIName : VendorOrderHeader.fieldsList()){
        	fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
            query += fieldAPIName + ', ';
        }
        query = query.substring(0, query.length()-2);
	        query += ', (SELECT '; 
            for(String fieldAPIName : VendorOrderLineItemGroup.fieldsList()){
            	fieldAPIName = BPUtility.escapeSingleQuotes(fieldAPIName);
                query += fieldAPIName + ', ';
            }
            query = query.substring(0, query.length()-2);
            query += ' FROM ' + Constants.NAMESPACE + 'Vendor_Order_Line_Item_Groups__r Where Status__c != \'Cancelled\') ';
        query += ' FROM Vendor_Order_Header__c WHERE '+ fieldName +' = \'' + fieldValue + '\'';
        
        List<Vendor_Order_Header__c> voHeaders = Database.query(query);
        List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<Id>());
        
        if(voHeaders.size() > 0){
        	VendorOrderHeader vendorOrderHeader = new VendorOrderHeader(voHeaderId);
            Id vendorId = vendorOrderHeader.VendorId;
            List<Account> vendors = SOQLUtil.getVendorDetailRecord('Id', vendorId);
            //System.assert(false, voHeaders[0]);
            //System.assert(false, voHeaders[0].Vendor_Order_Line_Item_Groups__r.size());
            vendorOrderDetailObj = new VendorOrderWrapper(voHeaders[0], vendors[0], businessProfileList);
        }
    }
    
    
    public class VendorOrderWrapper{
    	public String VOName {get; private set;}
	    
	    public String VendorId{get; private set;}
	    
	    public String OwnerId{get; private set;}
	    
	    public String OwnerName{get; private set;}
	    
	    public String Status{get; private set;}
	    
	    public String OrderedDate{get; private set;}
	    
	    public VendorWrapper VendorInfo{get; private set;}
	    
	    public List<VendorOrderLineItemGroupWrapper> GroupLineItems{get; private set;}
	    
	    public CustomerDetail.Company CompanyInfo{get; private set;}
	    
	    public Decimal OrderTotal{get; private set;}
	    
	    public VendorOrderWrapper(){
	    	
	    }
	    
	    public VendorOrderWrapper(Vendor_Order_Header__c voHeader, Account vendorRec, List<Business_Profile__c> businessProfileList){
	    	VOName = voHeader.Name;
			VendorId = voHeader.Vendor__c;
			OwnerName = voHeader.Owner.Name;
			OwnerId = voHeader.OwnerId;
			Status = voHeader.Status__c;
			if(voHeader.Ordered_Date__c != null) {
				OrderedDate = (datetime.newInstance(voHeader.Ordered_Date__c.year(), voHeader.Ordered_Date__c.month(),voHeader.Ordered_Date__c.day())).format('MM/dd/YYYY');
			}
			
			this.VendorInfo = new VendorWrapper(vendorRec);
			this.GroupLineItems = new List<VendorOrderLineItemGroupWrapper>();
			for(Vendor_Order_Line_Item_Group__c VendorOrderLineItemGroupRec : voHeader.Vendor_Order_Line_Item_Groups__r){
				this.GroupLineItems.add(new VendorOrderLineItemGroupWrapper(VendorOrderLineItemGroupRec));
			} 
			
			if(businessProfileList.size() > 0) {
                this.CompanyInfo = new CustomerDetail.Company(businessProfileList[0]);
            } else {
                this.CompanyInfo = new CustomerDetail.Company(new Business_Profile__c());
            }
            this.CompanyInfo.BusinessPhone = formatphonenumber(this.CompanyInfo.BusinessPhone);
			
			OrderTotal = 0;
			for(VendorOrderLineItemGroupWrapper groupLineItem : GroupLineItems){
				OrderTotal += groupLineItem.Total;
			}
			OrderTotal = OrderTotal.setScale(2, RoundingMode.HALF_UP);
	    }
    }
    
    public class VendorWrapper{
		// Customer Name
	    public String VendorName{get; private set;}
	    
	    // Vendor Code
	    public String VendorCode{get; private set;}
	    
	    // Home Eamil Address
	    public String HomeEmail{get; private set;}
	    
	    // Work Email Address
	    public String WorkEmail{get; private set;}
	    
	    // Home Number
	    public String HomeNumber{get; private set;}
	    
	    // Work Number
	    public String WorkNumber{get; private set;}
	    
	    // Preferred Email
	    public String PreferredEmail{get; private set;}
	    
	    // Preferred Phone
	    public String PreferredPhone{get; private set;}
	    
	    // Customer Number
	    public String VendorNumber{get; private set;}
	    
	    // Billing Address Fields
	    public String BillingStreet1{get; private set;}
	    public String BillingStreet2{get; private set;}
	    public String BillingCity{get; private set;}
	    public String BillingState{get; private set;}
	    public String BillingCountry{get; private set;}
	    public String BillingPostalCode{get; private set;}
	    
	    public VendorWrapper(Account vendorRec){
	    	this.VendorName = vendorRec.Name;
	    	this.VendorCode = vendorRec.Vendor_Code__c; 
	    	
	    	// Emails
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
    
    public class VendorOrderLineItemGroupWrapper{
    	
    	// Part Number + Part desc
	    public String ItemDesc{get; private set;}
	    
	    // Need - Qty Required 
	    public Decimal Need{get; private set;}
	    
	    // Qty Unit Type
    	public String UnitType{get; private set;}
    	
    	// CO Line Item price per Qty
	    public Decimal Cost{get; private set;}
	    
	    // Need * Cost
	    public Decimal Total{get; private set;}
	    
	    public VendorOrderLineItemGroupWrapper(Vendor_Order_Line_Item_Group__c VendorOrderLineItemGroupRec){
	    	this.ItemDesc = VendorOrderLineItemGroupRec.Part__r.Part_Number__c + ' - ' + VendorOrderLineItemGroupRec.Part__r.Description__c;
	    	this.Need = VendorOrderLineItemGroupRec.Need__c.setScale(2, RoundingMode.HALF_UP);
	    	this.UnitType = VendorOrderLineItemGroupRec.Part__r.Package_Unit__c;
	    	if(String.isBlank(UnitType) && VendorOrderLineItemGroupRec.Part__r.Packaged_Part__c){
	    		this.UnitType = 'PKG';
	    	}else if(String.isBlank(UnitType) && !VendorOrderLineItemGroupRec.Part__r.Packaged_Part__c){
	    		this.UnitType = 'EA';
	    	}  
	    	this.Cost = VendorOrderLineItemGroupRec.Cost__c.setScale(2, RoundingMode.HALF_UP);
	    	this.Total = (this.Cost * this.Need).setScale(2, RoundingMode.HALF_UP);
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