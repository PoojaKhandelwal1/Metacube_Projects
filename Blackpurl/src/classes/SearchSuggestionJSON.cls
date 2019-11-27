public with sharing class SearchSuggestionJSON {
    
    // Method to parse the search query JSON
    public static QueryJSON parseQuery(String json) {
        return (QueryJSON) System.JSON.deserialize(json, QueryJSON.class);
    }
    
    /**
     * Name: QueryJSON
     * Description: Class to represent search query JSON
    **/
    public class QueryJSON {
        // Object label selected by user to search in
        public String ObjectLabel {get; set;}
        
        // Search text
        public String SearchText {get; set;}
        
        // Preferred object to look into or add
        public String PreferredObject {get; set;}
        
        // Preferred objects into which to look
        public String SearchableObjects {get; set;}
        
        // List of filters need to be applied on records
        public List<FilterJSON> FilterValues {get; set;}
    }
    
    /**
     * Name: FilterJSON
     * Description: Class to hold filter field and filter value for object
    **/
    public class FilterJSON {
    	// Object field API name on which filter needs to be applied
    	public String Field {get; set;}
    	
    	public String Operator {get; set;}
    	
    	// Field value by which records need to be filtered
    	public String Value {get; set;}
    	// field Value for Object To filter
    	public String FilterObject{get;set;}
    }
    
    /**
     * Name: ResultJSON
     * Description: Class to represent search reault reocrds JSON
    **/
    public class ResultJSON {
        // Record display text
        public String Name {get; set;}
        
        // Record background value (generally Id value)
        public String Value {get; set;}
        
        // Additional info for the record
        public String Description {get; set;}
        
        // Record specification
        public String Info {get; set;}
        
		//Record NonInventoryPart flag
        public Boolean NonInventoryPart; // Added By Pooja 8 Feb. 2017

        //Record Additional Info
        public AdditionalDetails AdditionalDetailsForPart;  
        
        public AdditionalInfo AdditionalInfo;
        
        public AdditionalInfoForStock AdditionalInfoForStock;
        public AdditionalInfoForSOHeader AdditionalInfoForSO; 
        // Constructor
        public ResultJSON(sObject record, String name, String value, String Description, String info, String qty, String qtyCommitted, String price, String availableQty){
            this.Name = name;
            this.Value = value;
            setAdditionalInfo(record, Description);
            
            if(info == Constants.NAMESPACE + 'Service_Order_Header__c') {
            	this.Info = (record.getSobject('Transaction_Type__r') != null) ? String.valueOf(record.getSobject('Transaction_Type__r').get('Code_Label__c')) : '';
            	this.AdditionalInfoForSO = new AdditionalInfoForSOHeader(record);
            } else {
	            // Set additional information for record as specified in custom settings
	            // set record specifications
	            setInfoForObject(info);
	              
	            if(info == Constants.NAMESPACE + 'Part__c') {
	                this.additionalDetailsForPart = new AdditionalDetails(String.valueOf(record.get(Constants.NAMESPACE + 'Part_Number__c')) + ' - ' + String.valueOf(record.get(Constants.NAMESPACE + 'Description__c')), qty, qtyCommitted, price, String.valueOf(record.get('Id')), String.valueOf(record.get(Constants.NAMESPACE + 'Vendor__c')), availableQty);
					this.NonInventoryPart = Boolean.valueOf(record.get(Constants.NAMESPACE + 'Non_Inventory_Part__c')); // Added By Pooja 8 Feb. 2017
	            
	            } else if (info == Constants.NAMESPACE + 'Kit_Header__c'){
	                this.additionalDetailsForPart = new AdditionalDetails(Boolean.valueOf(record.get(Constants.NAMESPACE + 'Service_Kit__c')));
	            
	            } else if(this.Info == 'Vendor') {
	            	String vendorCode = (record.get('Vendor_Code__c') != null) ? String.valueOf(record.get('Vendor_Code__c')) : '';
	            	String categoryId = (record.get('Part_Category_Default__c') != null) ? String.valueOf(record.get('Part_Category_Default__c')) : null;
	            	String categoryName = (categoryId != null) ? String.valueOf(record.getSobject('Part_Category_Default__r').get('Name')) : '';
	            	Boolean IsCalculatePartRetailPriceFlag = Boolean.valueOf(record.get('Is_Calculate_Part_Retail_Price__c'));
	            	String RetailBaseValue = (record.get('Retail_Base_Value__c') != null) ? String.valueOf(record.get('Retail_Base_Value__c')) : 'MSRP';
	            	Decimal RetailRate = (record.get('Retail_Rate__c') != null) ? Decimal.valueOf(String.valueOf(record.get('Retail_Rate__c'))) : 0;
	            	Boolean RetailRounding = Boolean.valueOf(record.get('Retail_Rounding__c'));
	            	Decimal RetailRoundTo = (record.get('Retail_Round_To__c') != null) ? Decimal.valueOf(String.valueOf(record.get('Retail_Round_To__c'))) : 0;
	            	this.AdditionalInfo = new AdditionalInfo(vendorCode,categoryId,categoryName,IsCalculatePartRetailPriceFlag,RetailBaseValue,RetailRate,RetailRounding,RetailRoundTo);
	            } else if (info == Constants.NAMESPACE + 'Product__c'){
	            	this.AdditionalInfo = new AdditionalInfo(String.valueOf(record.get(Constants.NAMESPACE + 'Type__c')));
	            } else if(info == Constants.NAMESPACE + 'Customer_Owned_Unit__c') {
	                this.AdditionalInfoForStock = new AdditionalInfoForStock(record);
	            }
            }
        }
        
        
        
        // Method to set the info description for object record
        // Purpose of the method is to set object lable as defined in custom labels
        private void setInfoForObject(String info){
            if( Constants.objectNameToObjectDisplayLabel.containsKey(info) ){
                this.info = Constants.objectNameToObjectDisplayLabel.get(info);
            } else {
                this.info = info;
            }
        }
        
        // Method to set the Additional info description for object record
        private void setAdditionalInfo(sObject record, String Description){
            if(record != null && Description != null && Description.length() != 0){
                String compliedDesc = '';
                Integer indexVal = 0;
                
                // Case if there is/are only '{' in description tag and no other character, 
                // so the split method does not recognise empty string and won't process in for loop
                if(Description.split('\\{').size() == 0){
                    compliedDesc = Description;
                }
                
                for(String breakWord : Description.split('\\{')){
                    if(breakWord.indexOf('}') != -1){
                        // This is the bind operator for object field value to insert here
                        String objField = breakWord.subString(0, breakWord.indexOf('}'));
                        
                        // Try getting field value from object and if the "objField" is not object field api name then
                        // Catch the SObjectException and put the value as is
                        try{
                            compliedDesc += ' ' + String.valueOf(record.get(objField)) + breakWord.subString(breakWord.indexOf('}') + 1);
                        } catch (SObjectException sObjException){
                            // indexVal != 0 check is for the case if description is '}'
                            // If only the break word has '{' in start and not an object field, then add the '{' as it should not be complied
                            compliedDesc += (((indexVal != 0) && (Description.substring(indexVal-1, indexVal)) == '{') ? '{' : '' ) + objField + '}';
                        }
                    } else if(breakWord != ''){
                        // This is the case is description starts with '{' and there is no closing brace for the one
                        // So add a opening brace
                        compliedDesc += '{' + breakWord;
                    }
                    indexVal += breakWord.length() + 1;
                }
                compliedDesc = compliedDesc.trim();
                
                this.Description = compliedDesc;
            }
        }
    }
    
    public class AdditionalInfo {
    	public String VendorCode;
    	public String CategoryId;
    	public String CategoryName;
    	public Boolean IsCalculatePartRetailPriceFlag;
    	public String RetailBaseValue;
    	public Decimal RetailRate;
    	public Boolean RetailRounding;
    	public Decimal RetailRoundTo;
        public String ProductType;
    	public AdditionalInfo(String vendorCode, String categoryId, String categoryName, Boolean IsCalculatePartRetailPriceFlag, 
    							String RetailBaseValue, Decimal RetailRate, Boolean RetailRounding, Decimal RetailRoundTo) {
    		this.VendorCode = vendorCode;
    		this.CategoryId = categoryId;
    		this.CategoryName = categoryName;
    		this.IsCalculatePartRetailPriceFlag = IsCalculatePartRetailPriceFlag;
    		this.RetailBaseValue = RetailBaseValue;
    		this.RetailRate = RetailRate;
    		this.RetailRounding = RetailRounding;
    		this.RetailRoundTo = RetailRoundTo;
    	}
    	
    	public AdditionalInfo(String productType) {
    		this.ProductType = productType;
    	}
    }
    
    public class AdditionalInfoForStock {
        public String VINNumber;
        public String FormattedName;
        public String StockNumber;
        public String UnitType;
        
        public AdditionalInfoForStock(Sobject stockUnit) {
            this.VINNumber = (stockUnit.get(Constants.NAMESPACE + 'VIN_Number_Formula__c') != null) ? 
                                String.valueOf(stockUnit.get(Constants.NAMESPACE +  'VIN_Number_Formula__c')) : '';
            this.StockNumber = (stockUnit.get(Constants.NAMESPACE + 'Stock_Id__c') != null) ? 
                                String.valueOf(stockUnit.get(Constants.NAMESPACE + 'Stock_Id__c')) : '';
            this.FormattedName = (stockUnit.get(Constants.NAMESPACE + 'Formatted_Name__c') != null) ? 
                                String.valueOf(stockUnit.get(Constants.NAMESPACE + 'Formatted_Name__c')) : '';
            this.UnitType = (stockUnit.get(Constants.NAMESPACE + 'Unit_Type__c') != null) ? 
           						String.valueOf(stockUnit.get(Constants.NAMESPACE + 'Unit_Type__c')) : '';
        }
    }
    
    public class AdditionalInfoForSOHeader {
    	public String SearchName;
    	public String COHeaderId;
    	public String CustomerId;
        public String CustomerName;
        public String JobTypeId;
        public String JobType;
        public String UnitId;
        public String UnitDesc;
        public List<String> Concern;
        public List<String> KitConcern;
        
        public AdditionalInfoForSOHeader(Sobject soHeaderRec) {
        	this.SearchName = 'Appointment Service Job Search';
        	this.COHeaderId = (soHeaderRec.get('CO_Header__c') != null) ? String.valueOf(soHeaderRec.get('CO_Header__c')) : '';
        	this.CustomerId = (soHeaderRec.getSobject('CO_Header__r') != null) ? String.valueOf(soHeaderRec.getSobject('CO_Header__r').get('Customer__c')) : '';
            this.CustomerName = (soHeaderRec.getSobject('CO_Header__r') != null) ? String.valueOf(soHeaderRec.getSobject('CO_Header__r').get('Customer_Name__c')) : '';
            
            this.JobTypeId = (soHeaderRec.getSobject('Transaction_Type__r') != null) ? String.valueOf(soHeaderRec.get('Transaction_Type__c')) : '';
            this.JobType = (soHeaderRec.getSobject('Transaction_Type__r') != null) ? String.valueOf(soHeaderRec.getSobject('Transaction_Type__r').get('Type__c')) : '';
            
            this.UnitId = (soHeaderRec.get('Customer_Owned_Unit__c') != null) ? String.valueOf(soHeaderRec.get('Customer_Owned_Unit__c')) : '';
            this.UnitDesc = (soHeaderRec.getSobject('Customer_Owned_Unit__r') != null) ? String.valueOf(soHeaderRec.getSobject('Customer_Owned_Unit__r').get('Formatted_Name__c')) : '';
        	this.Concern = (soHeaderRec.get('SO_Concern__c') != null) ? String.valueOf(soHeaderRec.get('SO_Concern__c')).split('\n') : new List<String>();
        	this.KitConcern = new List<String>();
        	if(soHeaderRec.getSobjects('Service_Order_Kit_Headers__r') != null && soHeaderRec.getSobjects('Service_Order_Kit_Headers__r').size() > 0) {
                for(Service_Order_Kit_Header__c soKitHeaderRec : (List<Service_Order_Kit_Header__c>)soHeaderRec.getSobjects('Service_Order_Kit_Headers__r')) {
                    if(soKitHeaderRec.Kit_Header__c != null) {
                        this.KitConcern.addAll((soKitHeaderRec.Kit_Header__r.Concern__c != null) ? soKitHeaderRec.Kit_Header__r.Concern__c.split('\n') : new List<String>());
                    }
                }
            }
        }
    }
    
    public class AdditionalDetails {
        
        public String Item {get; set;}
        
        public Decimal Qty {get; set;}
        
        public Decimal QtyCommitted {get; set;}
        
        public String Status {get; set;}
        
        public Decimal Price {get; set;}
        
        public Decimal SubTotal {get; set;}
        
        public String Invoice {get; set;}
        
        public String FulfillDate {get; set;}
        
        public String PartId {get; set;}
        
        public String VendorId {get; set;}
        
        public boolean IsServiceKit{get;set;}
        
        public Decimal AvailableQty {get; set;}
        
        public AdditionalDetails(String item, String qty, String qtyCommitted, String price, String partId, String vendorId, String availableQty) {
            this.Item = item;
            this.Qty = 1;
            this.QtyCommitted = 0;
            if(String.isBlank(qty)) {
            	qty = '0';
            }
            if(String.isBlank(qtyCommitted)) {
            	qtyCommitted = '0';
            }
            if(String.isBlank(availableQty)) {
            	availableQty = '0';
            }
            
            if(Decimal.valueOf(qty) - Decimal.valueOf(qtyCommitted) > 0) {
                this.Status = 'In Stock';   
            } else {
                this.Status = 'Out of Stock';
            }
            if(String.isBlank(price)) {
                this.Price = 0;
            } else {
                this.Price = Decimal.valueOf(price);
            }
            this.SubTotal = this.Qty * this.price;
            this.Invoice = '';
            this.FulfillDate = String.valueOf(system.today());
            this.PartId = partId;
            this.VendorId = vendorId;
            this.AvailableQty = Decimal.valueOf(availableQty);
        }
        public AdditionalDetails(boolean IsServiceKit){
        	
        	//system.assert()
        	this.IsServiceKit = IsServiceKit;
        }
    }
}