public with sharing class GenericSearchResultsWrapper {
    public String Id;
    public String Name;
    public String Description;
    public String Info;
    public AdditionalInfoWrapper AdditionalInfoObj;
    
    public GenericSearchResultsWrapper(GenericSearchUtil.SearchedSObjectWrapper resultWrapperRecord, Search_Configuration__mdt searchConfigRec) {
        this.Id = resultWrapperRecord.SearchedObj.Id;
        String displayFieldName = searchConfigRec != null ? searchConfigRec.Display_Field_Name__c : 'Name';
        String additionalDisplayField = searchConfigRec != null ? searchConfigRec.Additional_Info_To_Display__c : '';
        if(displayFieldName.contains('__r')) {
            List<String> referncedFieldNameList = displayFieldName.split('\\.');
            SOBject sobj = null;
            for(Integer i = 0; i < referncedFieldNameList.size(); i++ ) {
                if(referncedFieldNameList[i].contains('__r')) {
                    sobj = (sobj != null) ? sobj.getSobject(Constants.NAMESPACE + referncedFieldNameList[i]) : resultWrapperRecord.SearchedObj.getSobject(Constants.NAMESPACE + referncedFieldNameList[i]);
                } else {
                    this.Name = String.valueOf(sobj.get(referncedFieldNameList[i]));
                }
            }
        } else {
            this.Name = String.valueOf(resultWrapperRecord.SearchedObj.get(displayFieldName));
        }
        this.Description = (resultWrapperRecord.objectName != 'Account' && resultWrapperRecord.objectName != 'Unit_Model__c') ? (String.isNotBlank(additionalDisplayField) ? String.valueOf(resultWrapperRecord.SearchedObj.get(additionalDisplayField)) : null) : null;
        
        if(resultWrapperRecord.objectName == 'Service_Order_Header__c') {
            this.Info = (resultWrapperRecord.SearchedObj.getSobject('Transaction_Type__r') != null) ? String.valueOf(resultWrapperRecord.SearchedObj.getSobject('Transaction_Type__r').get('Code_Label__c')) : '';
            this.AdditionalInfoObj = new AdditionalInfoWrapper((Service_Order_Header__c)resultWrapperRecord.SearchedObj);
        } else {
            if(GenericSearchUtil.objectNameToObjectDisplayLabel.containsKey(resultWrapperRecord.objectName)){
                this.info = GenericSearchUtil.objectNameToObjectDisplayLabel.get(resultWrapperRecord.objectName);
            }
            if(resultWrapperRecord.objectName == 'Account' && ((Account)(resultWrapperRecord.SearchedObj)).Is_Customer__c) {
                this.info = 'Customer';
                this.AdditionalInfoObj = new AdditionalInfoWrapper((Account)resultWrapperRecord.SearchedObj);
            } else if(resultWrapperRecord.objectName == 'Part__c') {
                this.AdditionalInfoObj = new AdditionalInfoWrapper((Part__c)resultWrapperRecord.SearchedObj);
            
            } else if (resultWrapperRecord.objectName == 'Kit_Header__c'){
            
            } else if(this.Info == 'Vendor') {
                this.AdditionalInfoObj = new AdditionalInfoWrapper((Account)resultWrapperRecord.SearchedObj);
            } else if (resultWrapperRecord.objectName == 'Product__c'){
                this.AdditionalInfoObj = new AdditionalInfoWrapper((Product__c)resultWrapperRecord.SearchedObj);
            } else if(resultWrapperRecord.objectName == 'Customer_Owned_Unit__c') {
                this.AdditionalInfoObj = new AdditionalInfoWrapper((Customer_Owned_Unit__c)resultWrapperRecord.SearchedObj);
            }
        }
    }
    
    public class AdditionalInfoWrapper {
        // Start: Customer additional fields
        public String Email;
        public String Phone;
        public String Type;
        // End: Customer additional fields
        
        // Start: Part additional fields
        public String Item;
        public Decimal Qty;
        public Decimal QtyCommitted;
        public String Status;
        public Decimal Price;
        public Decimal SubTotal;
        public String Invoice;
        public String FulfillDate;
        public String PartId;
        public String VendorId;
        public boolean IsServiceKit;
        public Decimal AvailableQty;
        public Boolean NonInventoryPart;
        public String Location;
        public String VendorName;
        // End: Part additional fields
        
        // Start: SOHeader additional fields
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
        // End: SOHeader additional fields
        
        //Start: Vendor additional fields
        public String VendorCode;
        public String CategoryId;
        public String CategoryName;
        public Boolean IsCalculatePartRetailPriceFlag;
        public String RetailBaseValue;
        public Decimal RetailRate;
        public Boolean RetailRounding;
        public Decimal RetailRoundTo;
        // End: Vendor additional fields
        
        // Start: Product additional fields
        public String ProductType;
        // End: Produuct additional fields
        
        // Start: Unit additional fields
        public String VINNumber;
        public String FormattedName;
        public String StockNumber;
        public String UnitType;
        // End: Unit additional fields
        
        public AdditionalInfoWrapper(Account accRec) {
            if(accRec.Is_Customer__c) {
                this.Type = accRec.Type__c;
                if(accRec.Preferred_Email__c == null) {
	                if(accRec.Email__c != null) {
	                    this.Email = accRec.Email__c;
	                } else if(accRec.Work_Email__c != null) {
	                    this.Email = accRec.Work_Email__c;
	                } else if(accRec.Other_Email__c != null) {
	                    this.Email = accRec.Other_Email__c;
	                }
	            } else {
	                this.Email = accRec.Preferred_Email__c;
	            }
	            
	            if(accRec.Preferred_Phone__c == null) {
	                if(accRec.Home_Number__c != null) {
	                    this.Phone = accRec.Formatted_Home_number__c;
	                } else if(accRec.Mobile__c != null) {
	                    this.Phone = accRec.Formatted_Mobile_Number__c;
	                } else if(accRec.Work_Number__c != null) {
	                    this.Phone = accRec.Formatted_Work_Number__c;
	                }
	            } else {
	                this.Phone = accRec.Formatted_Preferred_Phone__c;
	            }
            } else if(accRec.Is_Vendor__c) {
                this.VendorCode = accRec.Vendor_Code__c != null ? accRec.Vendor_Code__c : '';
                this.CategoryId = accRec.Part_Category_Default__c;
                this.CategoryName = (categoryId != null) ? accRec.Part_Category_Default__r.Name : '';
                this.IsCalculatePartRetailPriceFlag = accRec.Is_Calculate_Part_Retail_Price__c;
                this.RetailBaseValue = accRec.Retail_Base_Value__c != null ? accRec.Retail_Base_Value__c : 'MSRP';
                this.RetailRate = accRec.Retail_Rate__c != null ? accRec.Retail_Rate__c : 0;
                this.RetailRounding = accRec.Retail_Rounding__c;
                this.RetailRoundTo = accRec.Retail_Round_To__c != null ? accRec.Retail_Round_To__c : 0;
            }
        }
        
        public AdditionalInfoWrapper(Part__c partRec) {
            this.Item = partRec.Part_Number__c + ' - ' + partRec.Description__c;
            this.Qty = 1;
            this.QtyCommitted = 0;
            partRec.Qty_In_Stock__c = partRec.Qty_In_Stock__c != null ? partRec.Qty_In_Stock__c : 0;
            partRec.Qty_Committed__c = partRec.Qty_Committed__c != null ? partRec.Qty_Committed__c : 0;
            this.Status = (partRec.Qty_In_Stock__c - partRec.Qty_Committed__c) > 0 ? 'In Stock' : 'Out of Stock';
            this.Price = partRec.Retail_Price__c != null ? partRec.Retail_Price__c : 0;
            this.SubTotal = this.Qty * this.price;
            this.Invoice = '';
            this.FulfillDate = String.valueOf(system.today());
            this.PartId = partRec.Id;
            this.VendorId = partRec.Vendor__c;
            this.AvailableQty = partRec.AvailableParts__c != null ?  partRec.AvailableParts__c : 0;
            this.NonInventoryPart = partRec.Non_Inventory_Part__c;
            this.Location = partRec.Location__c;
            this.VendorName = partRec.Vendor__r.Name; 
        }
        
        public AdditionalInfoWrapper(Service_Order_Header__c soHeaderRec) {
            this.SearchName = 'Appointment Service Job Search';
            this.COHeaderId = (soHeaderRec.CO_Header__c != null) ? soHeaderRec.CO_Header__c : '';
            this.CustomerId = soHeaderRec.CO_Header__c != null ? soHeaderRec.CO_Header__r.Customer__c : '';
            this.CustomerName = soHeaderRec.CO_Header__c != null ? soHeaderRec.CO_Header__r.Customer_Name__c : '';
            this.JobTypeId = soHeaderRec.Transaction_Type__c != null ? soHeaderRec.Transaction_Type__c : '';
            this.JobType = soHeaderRec.Transaction_Type__c != null ? soHeaderRec.Transaction_Type__r.Type__c : '';
            this.UnitId = soHeaderRec.Customer_Owned_Unit__c != null ? soHeaderRec.Customer_Owned_Unit__c : '';
            this.UnitDesc = soHeaderRec.Customer_Owned_Unit__c != null ? soHeaderRec.Customer_Owned_Unit__r.Formatted_Name__c : '';
            this.Concern = soHeaderRec.SO_Concern__c != null ? soHeaderRec.SO_Concern__c.split('\n') : new List<String>();
            this.KitConcern = new List<String>();
            if(soHeaderRec.Service_Order_Kit_Headers__r != null && soHeaderRec.Service_Order_Kit_Headers__r.size() > 0) {
                for(Service_Order_Kit_Header__c soKitHeaderRec : soHeaderRec.Service_Order_Kit_Headers__r) {
                    if(soKitHeaderRec.Kit_Header__c != null) {
                        this.KitConcern.addAll((soKitHeaderRec.Kit_Header__r.Concern__c != null) ? soKitHeaderRec.Kit_Header__r.Concern__c.split('\n') : new List<String>());
                    }
                }
            }
        }
        
        public AdditionalInfoWrapper(Product__c productRec) {
            this.ProductType = productRec.Type__c != null ? productRec.Type__c : '';
        }
        
        public AdditionalInfoWrapper(Customer_Owned_Unit__c unitRec) {
            this.VINNumber = unitRec.VIN_Number_Formula__c != null ? unitRec.VIN_Number_Formula__c : '';
            this.StockNumber = unitRec.Stock_Id__c != null ? unitRec.Stock_Id__c : '';
            this.FormattedName = unitRec.Formatted_Name__c != null ? unitRec.Formatted_Name__c : '';
            this.UnitType = unitRec.Unit_Type__c != null ? unitRec.Unit_Type__c : '';
        }
    }
}