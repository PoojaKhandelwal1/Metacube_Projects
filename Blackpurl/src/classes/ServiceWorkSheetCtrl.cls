/**
* Author: Nidhi Sharma
* Since: September 24, 2016
* Name: SOWorkSheetWrapper
* Description: Wrapper class to handle JSON variables for SO worksheet. Created for ticket #129
**/
global with sharing class ServiceWorkSheetCtrl {
    
    public static String Application{get;}
    public static String Assests{get;}
    public static String Application_Images{get;}
    public String coHeaderId {get; private set;}
    public String customerApprovalId {get; private set;}
    public SOWorkSheetWrapper soWorkSheetObj {get; private set;}
    public CustomerApproval customerApprovalObj {get; private set;}
    
    public ServiceWorkSheetCtrl() {
    	Application = GlobalController.GetResourceURL('Application');
    	Application_Images = GlobalController.GetResourceURL('Application_Images');
    	Assests = GlobalController.GetResourceURL('Assests');
    	getPDFDetail();
    }
    
    public void getPDFDetail() {
        coHeaderId = ApexPages.currentPage().getParameters().get('id');
        customerApprovalId = ApexPages.currentPage().getParameters().get('customerApprovalId') != null ? ApexPages.currentPage().getParameters().get('customerApprovalId') : '';
    	if(String.isNotBlank(customerApprovalId)) {
        	String worksheetData = BPUtility.getDecodedString(getCustomerApprovalRec(BPUtility.getEncodedString(customerApprovalId)));
        	customerApprovalObj = (CustomerApproval)System.JSON.deserialize(worksheetData, CustomerApproval.class);
        	soWorkSheetObj = (SOWorkSheetWrapper)System.JSON.deserialize(customerApprovalObj.ApprovalDetailJson, SOWorkSheetWrapper.class);
        } else {
        	soWorkSheetObj = getSOHeaderData(coHeaderId);	
        }
    }
    
	@RemoteAction
    global static String saveCustomerApproval(String customerApprovalObj, String soHeaderIds) {
    	customerApprovalObj = BPUtility.getDecodedString(customerApprovalObj);
    	soHeaderIds = BPUtility.getDecodedString(soHeaderIds);
        return ServiceJobService.saveCustomerApproval(customerApprovalObj, soHeaderIds); 
    } 
	
    @RemoteAction
    global static String getServiceWorkSheetData(String coHeaderId) {
    	coHeaderId = BPUtility.getDecodedString(coHeaderId);
    	SOWorkSheetWrapper soWorkSheetWrapperObj = getSOHeaderData(coHeaderId);
    	
    	return BPUtility.getEncodedString(JSON.serialize(soWorkSheetWrapperObj));
    }
    
    @RemoteAction
    global static String getCustomerApprovalRec(String customerApprovalId) {
    	customerApprovalId = BPUtility.getDecodedString(customerApprovalId);
    	getCustomerApprovalJSONById(customerApprovalId);
    	List<CustomerApproval__c> customerApprovalList = [select Approval_Count__c, ApprovalDetailJson__c, ApprovalType__c, Notes__c, Section_key__c, Name, LastModifiedDate,
                                                Section_Name__c, Service_Order_Header__c, Status__c, (Select Id from Attachments) from CustomerApproval__c where Id=: customerApprovalId];
    	if(customerApprovalList.size() > 0) {
    		return BPUtility.getEncodedString(JSON.serialize(new CustomerApproval(customerApprovalList[0])));
    	}
    	return BPUtility.getEncodedString('');
    }
    
    private static String getCustomerApprovalJSONById(String customerApprovalId) {
    	List<CustomerApproval__c> customerApprovalList = [select ApprovalDetailJson__c from CustomerApproval__c where Id=: customerApprovalId];
    	if(customerApprovalList.size() > 0) {
    		return customerApprovalList[0].ApprovalDetailJson__c;	
    	}
    	return '';
    }
    private static SOWorkSheetWrapper getSOHeaderData(String coHeaderId) {
        if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        List<CO_Header__c> coHeaderList = [select Name, Status__c, Customer__c, SO_Worksheet_User_selection__c from CO_Header__c where Id=: coHeaderId];
        if(coHeaderList.size() == 0) {
            return null;
        }
        String jsonString = coHeaderList[0].SO_Worksheet_User_selection__c; 
        
        List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail> soPrintDetailListObj = 
                    (List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail>) System.JSON.deserialize(jsonString, List<SOWorkSheetWrapper.ServiceWorkSheetPrintDetail>.class);
        
        Set<Id> soHeaderIdSet = new Set<Id>();
        Set<Id> unitIdSet = new Set<Id>();
        Boolean isPrintPreview = false; 
        for(SOWorkSheetWrapper.ServiceWorkSheetPrintDetail printDetailObj : soPrintDetailListObj) {
            if(printDetailObj.IsUnitSelected) {
                unitIdSet.add(printDetailObj.UnitId);
                for(SOWorkSheetWrapper.SOInfoWrapper soInfoObj : printDetailObj.SOInfoWrapperList) {  
                    if(soInfoObj.IsSOHeaderSelected) {
                        soHeaderIdSet.add(soInfoObj.SOHeaderId);
                    }
                }
            }
            isPrintPreview = printDetailObj.IsPrintPreview;
        }
        
        List<Account> customerList = new List<Account>();
        List<Service_Order_Header__c> soHeaderList = SOQLUtil.getSODetailsByFieldName(new Map<String, String>{'CO_Header__c' => coHeaderId});
        List<Service_Order_Header__c> soHeaderRecList = new List<Service_Order_Header__c>();
        for(Service_Order_Header__c soHeaderRec : soHeaderList) {
            if(soHeaderIdSet.contains(soHeaderRec.Id)) {
                soHeaderRecList.add(soHeaderRec);
            }
        }
        List<Customer_Owned_Unit__c> unitList = SOQLUtil.getUnitDetails(unitIdSet);
        List<Business_Profile__c> businessProfileList = SOQLUtil.getBusinessProfileData(new List<id>());
        if(soHeaderList.size() > 0 && coHeaderList[0].Customer__c != null) {
            customerList = SOQLUtil.getCustomerDetailsByFieldName(new Map<String, String>{'Id' => coHeaderList[0].Customer__c});
        } 
        
        List<Individual_Tax__c> individualItemsList = [select CO_Line_Item__c, Tax_Rate__c, Form_Label__c, Sales_Tax_Item_Name__c, 
                                                                Taxable_Amount__c, Tax_Amount__c,
                                                                Applicable_Tax__c, List_Tax_items_on_forms__c
                                                                    from Individual_Tax__c 
                                                                    where Service_Order_Line_Item__r.Service_Order_Header__c IN :soHeaderIdSet];
        
        Map<String, Decimal> salesTaxNameToTaxValue = new Map<String, Decimal>();  
        salesTaxNameToTaxValue = TaxCalculation.getTaxAmountWithFormLabel(individualItemsList); 
                
        SOWorkSheetWrapper soWorkSheetWrapperObj = new SOWorkSheetWrapper(unitList, soHeaderRecList, 
                                                                    businessProfileList, customerList, 
                                                                    coHeaderList[0], isPrintPreview,
                                                                    salesTaxNameToTaxValue);
        return soWorkSheetWrapperObj;
    }
}