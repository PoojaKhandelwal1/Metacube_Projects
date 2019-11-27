/**
 * Author: Richa Mittal
 * Since: August 12, 2016
 * Name: GlobalSearchResultsWrapper
 * Description: Class is used for the Creating Json For Search Results
**/
public with sharing class GlobalSearchResultsWrapper {
    public Integer TotalRecords;
    public List<GlobalSearchRecordWrapper> searchRecords;
    
    public GlobalSearchResultsWrapper(Integer TotalRecords, List<Sobject> searchedObjList){
        this.TotalRecords = TotalRecords;
        this.searchRecords = new List<GlobalSearchRecordWrapper>();
        for(Sobject sObj : searchedObjList) {
            this.searchRecords.add(new GlobalSearchRecordWrapper(sObj));
        }
    }
    
    public class GlobalSearchRecordWrapper{
        public String Id;
        public Integer Type;
        public String ObjectName; 
        public String AdditionalInfo1;
        public String AdditionalInfo2;
        public String AdditionalInfo3;
        public String AdditionalInfo4;
        public String AdditionalInfo5;
        public String AdditionalInfoLabel1;
        public String AdditionalInfoLabel2;
        public String AdditionalInfoLabel3;
        public String AdditionalInfoLabel4;
        public String AdditionalInfoLabel5;
        public String ItemName;
        public String LastModifiedDate;
        
        /**
         * Name:GlobalSearchResultsWrapper 
         * Description: Constructor
        **/
        public GlobalSearchRecordWrapper(Sobject searchedObj) {
            String objName = String.valueOf(searchedObj.getSObjectType());
            if(objName == 'Account') {
                if(((searchedObj.get(Constants.NAMESPACE +'Is_Customer__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Is_Customer__c')) : null) == 'true') {
                    this.Type = 1;
                    this.ObjectName = 'Customer';
                } else if(((searchedObj.get(Constants.NAMESPACE +'Is_Vendor__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Is_Vendor__c')) : null) == 'true') {
                    this.Type = 2;
                    this.ObjectName = 'Vendor';
                }
                
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.ItemName = (searchedObj.get('Name') != null) ? String.valueOf(searchedObj.get('Name')) : '';
                this.AdditionalInfoLabel1 = 'Email';
                this.AdditionalInfoLabel2 = 'Phone';
                
                if(searchedObj.get(Constants.NAMESPACE +'Preferred_Email__c') != '' && searchedObj.get(Constants.NAMESPACE +'Preferred_Email__c') != null) {
                    this.AdditionalInfo1 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Preferred_Email__c'));
                } else if(searchedObj.get(Constants.NAMESPACE +'Work_Email__c') != '' && searchedObj.get(Constants.NAMESPACE +'Work_Email__c') != null) {
                    this.AdditionalInfo1 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Work_Email__c'));
                } else {
                    if(((searchedObj.get(Constants.NAMESPACE +'Is_Customer__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Is_Customer__c')) : null) == 'true') {
                        if(searchedObj.get(Constants.NAMESPACE +'Email__c') != '' && searchedObj.get(Constants.NAMESPACE +'Email__c') != null) {
                            this.AdditionalInfo1 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Email__c'));
                        } else if(searchedObj.get(Constants.NAMESPACE +'Other_Email__c') != '' && searchedObj.get(Constants.NAMESPACE +'Other_Email__c') != null) {
                            this.AdditionalInfo1 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Other_Email__c'));
                        }
                    } else if(((searchedObj.get(Constants.NAMESPACE +'Is_Vendor__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Is_Vendor__c')) : null) == 'true') {
                        if(searchedObj.get(Constants.NAMESPACE +'Other_Email__c') != '' && searchedObj.get(Constants.NAMESPACE +'Other_Email__c') != null) {
                            this.AdditionalInfo1 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Other_Email__c'));
                        }
                    }
                } 
                
                if(searchedObj.get(Constants.NAMESPACE +'Preferred_Phone__c') != '' && searchedObj.get(Constants.NAMESPACE +'Preferred_Phone__c') != null) {
                    this.AdditionalInfo2 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Formatted_Preferred_Phone__c'));
                } else if(searchedObj.get(Constants.NAMESPACE +'Work_Number__c') != '' && searchedObj.get(Constants.NAMESPACE +'Work_Number__c') != null) {
                    this.AdditionalInfo2 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Formatted_Work_Number__c'));
                } else {
                    if(((searchedObj.get(Constants.NAMESPACE +'Is_Customer__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Is_Customer__c')) : null) == 'true') { 
                        if(searchedObj.get(Constants.NAMESPACE +'Home_Number__c') != '' && searchedObj.get(Constants.NAMESPACE +'Home_Number__c') != null) {
                            this.AdditionalInfo2 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Formatted_Home_number__c'));
                        } else if(searchedObj.get(Constants.NAMESPACE +'Mobile__c') != '' && searchedObj.get(Constants.NAMESPACE +'Mobile__c') != null) {
                            this.AdditionalInfo2 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Formatted_Mobile_Number__c'));
                        }
                    } else if(((searchedObj.get(Constants.NAMESPACE +'Is_Vendor__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Is_Vendor__c')) : null) == 'true') {
                        if(searchedObj.get(Constants.NAMESPACE +'Mobile__c') != '' && searchedObj.get(Constants.NAMESPACE +'Mobile__c') != null) {
                            this.AdditionalInfo2 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Formatted_Mobile_Number__c'));
                        }
                    }
                }
            } else if(objName == Constants.NAMESPACE + 'Part__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 3;
                this.ObjectName = 'Part';
                this.ItemName = ((searchedObj.get(Constants.NAMESPACE +'Part_Number__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Part_Number__c')) : '') + ((searchedObj.get(Constants.NAMESPACE +'Part_Number__c') != null) && (searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? ' - ' : '') + ((searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Description__c')) : '');
	    		this.AdditionalInfo2 = (searchedObj.get(Constants.NAMESPACE +'AvailableParts__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'AvailableParts__c')) : null;
	    		this.AdditionalInfoLabel2 = 'available';
	    		this.AdditionalInfo1 = (searchedObj.getSObject(Constants.NAMESPACE +'Vendor__r').get('Name') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'Vendor__r').get('Name')) : null;
	    		this.AdditionalInfoLabel1 = 'Vendor Name';
	    		this.AdditionalInfo3 = (searchedObj.get(Constants.NAMESPACE +'Location__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Location__c')) : null;
	    		this.AdditionalInfoLabel3 = 'Location';
            } else if(objName == Constants.NAMESPACE + 'Kit_Header__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 4;
                this.ItemName = ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Code__c')) : '') + ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) && (searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? ' - ' : '') + ((searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Description__c')) : '');
                if(((searchedObj.get(Constants.NAMESPACE +'Service_Kit__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Service_Kit__c')) : null) == 'true') {
                    this.AdditionalInfo1 = 'Service';
                    this.ObjectName = 'Service Kit';
                } else {
                    this.AdditionalInfo1 = 'General';
                    this.ObjectName = 'Kit';
                }
                this.AdditionalInfoLabel1 = 'Type';
            } else if(objName == Constants.NAMESPACE + 'Fee__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 5;
                this.ObjectName = 'Fee';
                this.ItemName = ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Code__c')) : '') + ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) && (searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? ' - ' : '') + ((searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Description__c')) : '');
                this.AdditionalInfo1 = ((searchedObj.get(Constants.NAMESPACE +'Price__c') != null) ? ((Decimal)searchedObj.get(Constants.NAMESPACE +'Price__c') < 0 ? '($'+ String.valueOf((Decimal)searchedObj.get(Constants.NAMESPACE +'Price__c') * -1) + ')' : '$'+ String.valueOf(searchedObj.get(Constants.NAMESPACE +'Price__c'))) : null);
                this.AdditionalInfoLabel1 = 'Price';
            } else if(objName == Constants.NAMESPACE + 'Labour_Code__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 6;
                this.ObjectName = 'Labor Code';
                this.ItemName = ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Code__c')) : '') + ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) && (searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? ' - ' : '') + ((searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Description__c')) : '');
                this.AdditionalInfo1 = (searchedObj.get(Constants.NAMESPACE +'Hours__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Hours__c')) : null;
                this.AdditionalInfoLabel1 = 'Hours';
            } else if(objName == 'User') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 7;
                this.ObjectName = 'User';
                this.ItemName = (searchedObj.get('Name') != null) ? String.valueOf(searchedObj.get('Name')) : '';
                this.AdditionalInfo1 = (searchedObj.get('Email') != null) ? String.valueOf(searchedObj.get('Email')) : null;
                this.AdditionalInfo2 = (searchedObj.get('Phone') != null) ? String.valueOf(searchedObj.get('Phone')) : null;
                this.AdditionalInfoLabel1 = 'Email';
                this.AdditionalInfoLabel2 = 'Phone';
            } else if(objName == Constants.NAMESPACE + 'CO_Header__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 8;
                this.ObjectName = 'Customer Order';
                this.ItemName = (searchedObj.get('Name') != null) ? String.valueOf(searchedObj.get('Name')) : '';
                this.AdditionalInfo1 = (searchedObj.get(Constants.NAMESPACE +'Customer_Name__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Customer_Name__c')) : null;
                Decimal DealTotal = (searchedObj.get(Constants.NAMESPACE + 'Deal_Header_Total__c') != null) ? (Decimal)(searchedObj.get(Constants.NAMESPACE + 'Deal_Header_Total__c')) : 0.00;
                this.AdditionalInfo2 = ((Decimal)searchedObj.get(Constants.NAMESPACE + 'NumberOfDeals__c') > 0) ? (DealTotal < 0 ? '($'+ String.valueOf(DealTotal * -1) + ')' : '$'+ String.valueOf(DealTotal)) : null;
                this.AdditionalInfoLabel2 = 'Deal';
                Decimal SOTotalWithTax = ((searchedObj.get(Constants.NAMESPACE + 'Service_Order_Subtotal__c') != null) ? (Decimal)(searchedObj.get(Constants.NAMESPACE + 'Service_Order_Subtotal__c')) : 0.00).setScale(2, RoundingMode.HALF_UP);
                
                this.AdditionalInfo3 = ((Decimal)searchedObj.get(Constants.NAMESPACE + 'TotalNumberOfSOHeader__c') > 0) ? (SOTotalWithTax < 0 ? '($'+ String.valueOf(SOTotalWithTax * -1) + ')' : '$'+ String.valueOf(SOTotalWithTax)) : null;
                this.AdditionalInfoLabel3 = 'Service';
                
                Decimal MerchTotal = (searchedObj.get(Constants.NAMESPACE + 'Merchandise_Total__c') != null) ? ((Decimal)searchedObj.get(Constants.NAMESPACE + 'Merchandise_Total__c')).setScale(2, RoundingMode.HALF_UP) : 0.00;
                this.AdditionalInfo4 = ( ((Decimal)searchedObj.get(Constants.NAMESPACE + 'TotalNumberOfCOLI__c') > 0) && 
                                          ((String.valueOf(searchedObj.get(Constants.NAMESPACE + 'Selling_Group__c')) == 'Part Sale') ||
                                          (String.valueOf(searchedObj.get(Constants.NAMESPACE + 'Selling_Group__c')) == 'Cash Sale') ||
                                            ((String.valueOf(searchedObj.get(Constants.NAMESPACE + 'Selling_Group__c')) != 'Internal Service')))) ? 
                                        (MerchTotal < 0 ? '($'+ String.valueOf(MerchTotal * -1) + ')' : '$'+ String.valueOf(MerchTotal)) : null;
                
                this.AdditionalInfoLabel4 = 'Merchandise';
                this.LastModifiedDate = (searchedObj.get('LastModifiedDate') != null) ? ((DateTime)searchedObj.get('LastModifiedDate')).format('MMMM d,  yyyy') : '';
                this.AdditionalInfo5 = (searchedObj.get(Constants.NAMESPACE + 'Order_status__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE + 'Order_status__c')) : '';
                
            } else if(objName == Constants.NAMESPACE + 'CO_Invoice_Header__c') {
                this.Id = (searchedObj.getSobject(Constants.NAMESPACE +'CO_Header__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Id') != null) ? String.valueOf(searchedObj.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Id')) : null;
                this.Type = 9;
                this.ObjectName = 'Customer Invoice';
                this.ItemName = (searchedObj.get(Constants.NAMESPACE + 'Invoice_Number__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE + 'Invoice_Number__c')) : '';
                this.AdditionalInfo1 = (searchedObj.getSobject(Constants.NAMESPACE +'CO_Header__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'CO_Header__r').get('Customer_Name__c') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'CO_Header__r').get('Customer_Name__c')) : null;
                this.AdditionalInfoLabel1 = 'Customer Name';
                  
            } else if(objName == Constants.NAMESPACE + 'Vendor_Order_Header__c' || objName == Constants.NAMESPACE + 'Return_VO_Header__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                if(objName == Constants.NAMESPACE + 'Return_VO_Header__c') {
                    this.Type = 22;
                    this.ObjectName = 'Vendor Return';
                } else {
                this.Type = 10;
                this.ObjectName = 'Vendor Order';
                }
                this.ItemName = (searchedObj.get('Name') != null) ? String.valueOf(searchedObj.get('Name')) : '';
                this.AdditionalInfo1 = (searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r').get('Name') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'Vendor__r').get('Name')) : null;
                this.AdditionalInfoLabel1 = 'Vendor Name';
                
            } else if(objName == Constants.NAMESPACE + 'Vendor_Receiving_Header__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 11;
                this.ObjectName = 'Vendor Receiving';
                this.ItemName = (searchedObj.get('Name') != null) ? String.valueOf(searchedObj.get('Name')) : '';
                this.AdditionalInfo1 = (searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r').get('Name') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'Vendor__r').get('Name')) : null;
                this.AdditionalInfoLabel1 = 'Vendor Name';
                
            } else if(objName == Constants.NAMESPACE + 'Vendor_Invoicing_Header__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 12;
                this.ObjectName = 'Vendor Invoice';
                this.ItemName = (searchedObj.get('Name') != null) ? String.valueOf(searchedObj.get('Name')) : '';
                this.AdditionalInfo1 = (searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r').get('Name') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'Vendor__r').get('Name')) : null;
                this.AdditionalInfoLabel1 = 'Vendor Name';
                
            } else if(objName == Constants.NAMESPACE + 'Category__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 13;
                this.ObjectName = 'Item Category';
                this.ItemName = ((searchedObj.get('Name') != null) ? String.valueOf(searchedObj.get('Name')) : '') + ((searchedObj.get('Name') != null) && (searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? ' - ' : '') + ((searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Description__c')) : '');
                this.AdditionalInfo1 = (searchedObj.get(Constants.NAMESPACE +'Type__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Type__c')) : null;
                this.AdditionalInfoLabel1 = 'Category Type';
                
            } else if(objName == Constants.NAMESPACE + 'Price_Level__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 14;
                this.ObjectName = 'Price Level';
                this.ItemName = (searchedObj.get(Constants.NAMESPACE +'Name__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Name__c')) : '';
                this.AdditionalInfo1 = ((searchedObj.get(Constants.NAMESPACE +'Discount_Markup__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Discount_Markup__c')) : null)+ '%';
                this.AdditionalInfoLabel1 = 'Discount Markup';
                
            } else if(objName == Constants.NAMESPACE + 'Sales_Tax__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 15;
                this.ObjectName = 'Sales Tax';
                this.ItemName = (searchedObj.get(Constants.NAMESPACE +'Name__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Name__c')) : '';
                this.AdditionalInfo1 = ((searchedObj.get(Constants.NAMESPACE +'Rate__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Rate__c')) : null)+ '%';
                this.AdditionalInfoLabel1 = 'Rate';
                
            } else if(objName == Constants.NAMESPACE + 'Product__c') {
                this.Id = (searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r').get('Id') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'Vendor__r').get('Id')) : null;
                String productType = (searchedObj.get(Constants.NAMESPACE +'Type__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Type__c')) : '';
                if(productType == Constants.SUBLET) {
                    this.Type = 16;
                    this.ObjectName = Constants.SUBLET;
                } else if(productType == Constants.FINANCING_PRODUCT) {
                    this.Type = 19;
                    this.ObjectName = Constants.FINANCING_PRODUCT;
                } else if(productType == Constants.DEAL_PRODUCT) {
                    this.Type = 20;
                    this.ObjectName = Constants.DEAL_PRODUCT;
                } else if(productType == Constants.WARRANTY_PLAN) {
                    this.Type = 21;
                    this.ObjectName = Constants.WARRANTY_PLAN;
                }
                this.ItemName = ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Code__c')) : '') + ((searchedObj.get(Constants.NAMESPACE +'Code__c') != null) && (searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? ' - ' : '') + ((searchedObj.get(Constants.NAMESPACE +'Description__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Description__c')) : '');
                this.AdditionalInfo1 = (searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'Vendor__r').get('Name') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'Vendor__r').get('Name')) : null;
                this.AdditionalInfoLabel1 = 'Vendor Name';
                
            } else if(objName == Constants.NAMESPACE + 'Customer_Owned_Unit__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 18;
                this.ObjectName = 'Unit';
                this.ItemName = ((searchedObj.get(Constants.NAMESPACE +'VIN_Number__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'VIN_Number__c')) : '');
                this.AdditionalInfo1 = ((searchedObj.get(Constants.NAMESPACE +'Unit_Type__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Unit_Type__c')) : '');
                this.AdditionalInfoLabel1 = 'Type';
                
                this.AdditionalInfo2 = ((searchedObj.get(Constants.NAMESPACE +'Unit_Number__c') != null) ? String.valueOf(searchedObj.get(Constants.NAMESPACE +'Unit_Number__c')) : '');
                this.AdditionalInfoLabel2 = 'Unit Number';
                
                this.AdditionalInfo3 = '';
                if(searchedObj.get(Constants.NAMESPACE +'Make_Name__c') != null){
                    this.AdditionalInfo3 = String.valueOf(searchedObj.get(Constants.NAMESPACE +'Make_Name__c'));
                }
                if(searchedObj.get(Constants.NAMESPACE +'Model_Name__c') != null){
                    this.AdditionalInfo3 = this.AdditionalInfo3 + ' ' +String.valueOf(searchedObj.get(Constants.NAMESPACE +'Model_Name__c'));
                }
                if(searchedObj.getSObject(Constants.NAMESPACE +'Sub_Model__r') != null && searchedObj.getSObject(Constants.NAMESPACE +'Sub_Model__r').get('Sub_Model_Name__c') != null){
                    this.AdditionalInfo3 = this.AdditionalInfo3 + ' ' +String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'Sub_Model__r').get('Sub_Model_Name__c'));
                }
                this.AdditionalInfoLabel3 = '';
                
            } else if(objName == Constants.NAMESPACE + 'Technician__c') {
                this.Id = String.valueOf(searchedObj.get('Id'));
                this.Type = 23;
                this.ObjectName = 'Technician';
                this.ItemName = (searchedObj.get('Technician_Name__c') != null) ? String.valueOf(searchedObj.get('Technician_Name__c')) : '';
                this.AdditionalInfo1 = (searchedObj.getSobject(Constants.NAMESPACE +'User__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'User__r').get('Email') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'User__r').get('Email')) : null;
                this.AdditionalInfo2 = (searchedObj.getSobject(Constants.NAMESPACE +'User__r') != null && searchedObj.getSobject(Constants.NAMESPACE +'User__r').get('Phone') != null) ? String.valueOf(searchedObj.getSObject(Constants.NAMESPACE +'User__r').get('Phone')) : null;
                this.AdditionalInfoLabel1 = 'Email';
                this.AdditionalInfoLabel2 = 'Phone';
            }
        }
    }   
    /**
     * Name: GlobalQueryJSON
     * Description: Class to represent global search query JSON
    **/
    public class GlobalQueryJSON {
        // Search text
        public String GlobalSearchText {get; set;}
        
        // Object label selected by user to search in
        public String GlobalSearchKeyword {get; set;}
        
        // Object label selected by user to search in
        public String GlobalSearchKeywordKey{get; set;}
        
    }
}