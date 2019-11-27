/**
 * Author: Nidhi Sharma
 * Since: August 03, 2016
 * Name: UnitWrapper
 * Description: Wrapper class to handle JSON variables for View Unit page
**/

public without sharing class UnitWrapper { 
    
    public UnitInfoWrapper UnitInfo;
    public List<PriceAndCostTrackingWrapper> PriceAndCostTrackingWrapperList;
    public List<OwnerWrapper> OwnerList;
    public List<SalesTax> SalesTaxList;
    public List<ServiceOrderWrapper> ServiceOrdersList; // for retrieving SO's for a unit
    public VendorInfoWrapper VendorInfo;
    
    // Constructor
    public UnitWrapper(Customer_Owned_Unit__c unitRec, List<Customer_Owned_Unit__c> similarUnits, List<Sales_Tax__c> salesTaxList, List<Service_Order_Header__c> soList) {
        this.UnitInfo = new UnitInfoWrapper(unitRec);
        this.PriceAndCostTrackingWrapperList = new List<PriceAndCostTrackingWrapper>();
        this.VendorInfo = new VendorInfoWrapper(unitRec);
        this.OwnerList = new List<OwnerWrapper>();
        this.SalesTaxList = new List<SalesTax>();
        this.ServiceOrdersList = new List<ServiceOrderWrapper>(); // for retrieving SO's for a unit
        
        for(Unit_Price_Cost__c unitPriceAndCostRec : unitRec.Unit_Prices_Costs__r){
            this.PriceAndCostTrackingWrapperList.add(new PriceAndCostTrackingWrapper(unitPriceAndCostRec));
        }
        
        // Sorting of owners 
        List<Customer_Owned_Unit__c> sortedSimilarUnits = new List<Customer_Owned_Unit__c>();
        for(Customer_Owned_Unit__c similarUnitRec : similarUnits) {
            if(similarUnitRec.Id == unitRec.Id && sortedSimilarUnits.size() > 0) {
                sortedSimilarUnits.add(0, similarUnitRec); 
            } else {
                sortedSimilarUnits.add(similarUnitRec);
            }
        }
        
        for(Customer_Owned_Unit__c similarUnitRec : sortedSimilarUnits) {
            this.OwnerList.add(new OwnerWrapper(similarUnitRec));
        }
        
        for(Sales_Tax__c salesTaxRec : salesTaxList) {
            this.SalesTaxList.add(new SalesTax(salesTaxRec, false));
        }

        // Start: for retrieving SO's for a unit
        for(Service_Order_Header__c soRec : soList) {
            this.ServiceOrdersList.add(new ServiceOrderWrapper(soRec));
        }
        // End: for retrieving SO's for a unit
    }
    
    public class VendorInfoWrapper{
        
        public String VendorName;
        public String VendorEmail;
        public String VendorPhone;
        public String VendorAccount;
        public String DateOrdered;
        public String InvoiceDate;
        public String UnitOrderNo;
        public String FactoryOrderNo;
        public String VendorInvoiceNo;
        public Decimal TotalInvoice;
        public String Manufactured;
        public String ReferencedUnitId;
        
        public VendorInfoWrapper(Customer_Owned_Unit__c unitRec) {
            if(unitRec.Vendor__c != null) {
                this.VendorName = unitRec.Vendor__r.Name;
            
                if(unitRec.Vendor__r.Preferred_Email__c != null) {
                    this.VendorEmail = unitRec.Vendor__r.Preferred_Email__c;
                } else if(unitRec.Vendor__r.Email__c != null) {
                    this.VendorEmail = unitRec.Vendor__r.Email__c;
                } else if(unitRec.Vendor__r.Work_Email__c != null) {
                    this.VendorEmail = unitRec.Vendor__r.Work_Email__c;
                } else if(unitRec.Vendor__r.Other_Email__c != null) {
                    this.VendorEmail = unitRec.Vendor__r.Other_Email__c;
                }
                    
                if(unitRec.Vendor__r.Preferred_Phone__c != null) {
                    this.VendorPhone = unitRec.Vendor__r.Preferred_Phone__c;
                } else if(unitRec.Vendor__r.Home_Number__c != null) {
                    this.VendorPhone = unitRec.Vendor__r.Formatted_Home_number__c;
                } else if(unitRec.Vendor__r.Mobile__c != null) {
                    this.VendorPhone = unitRec.Vendor__r.Formatted_Mobile_Number__c;
                } else if(unitRec.Vendor__r.Work_Number__c != null) {
                    this.VendorPhone = unitRec.Vendor__r.Formatted_Work_Number__c;
                }
                
                if(unitRec.Referenced_Unit__r.CreatedDate != null) {
                    this.DateOrdered = (datetime.newInstance(unitRec.Referenced_Unit__r.CreatedDate.year(), unitRec.Referenced_Unit__r.CreatedDate.month(),unitRec.Referenced_Unit__r.CreatedDate.day())).format('MMMM dd, yyyy');
                }
                this.VendorAccount = unitRec.Vendor__r.AccountNumber;
                this.FactoryOrderNo = unitRec.Factory_Order_No__c;
                unitRec.Total_Cost__c = (unitRec.Total_Cost__c != null) ? unitRec.Total_Cost__c : 0;
                unitRec.Tax_Amount__c = (unitRec.Tax_Amount__c != null) ? unitRec.Tax_Amount__c : 0;
                this.TotalInvoice = unitRec.Total_Cost__c + unitRec.Tax_Amount__c;
                this.UnitOrderNo = (unitRec.Referenced_Unit__r.Unit_Id__c != null) ? unitRec.Referenced_Unit__r.Unit_Id__c : '';
                this.ReferencedUnitId = unitRec.Referenced_Unit__c;
                this.VendorInvoiceNo = (unitRec.Invoice_Number__c != null) ? unitRec.Invoice_Number__c : '';
                if(unitRec.Manufactured_Date__c != null){
                    this.Manufactured = (datetime.newInstance(unitRec.Manufactured_Date__c.year(), unitRec.Manufactured_Date__c.month(),unitRec.Manufactured_Date__c.day())).format('MMMM dd, yyyy');
                }
            }
            if(unitRec.Date_Stocked_In__c != null){
                 this.InvoiceDate = (datetime.newInstance(unitRec.Date_Stocked_In__c.year(), unitRec.Date_Stocked_In__c.month(),unitRec.Date_Stocked_In__c.day())).format('MMMM dd, yyyy');
            }           
        }
    }
    
    public class UnitInfoWrapper {  
        
        public String Id;
        public String Name;
        public String VIN;
        public String UnitType;
        public String UnitId;
        public String StockNumber;
        public Decimal Year;
        public String MakeModelDescription;
        public String Make;
        public String MakeName;
        public String Model;
        public String ModelName;
        public String SubModel;
        public String SubModelName;
        public String Category;
        public String CategoryName;
        public String ExteriorColour;
        public String Plate;
        public Decimal Mileage;
        public String MileageType;
        public String Status;
        public String StatusColor;
        public Boolean IsNewUnit;
        public String DateIn;
        public String DateOut;
        public Decimal Age;
        public String Location;
        public String ManufacturedDate;
        public String KeyNo;
        public String EngineSerialNo;
        public String OtherSerialNo;
        public String FactoryOrderNo;
        public String InteriorColour;
        public Boolean IsTaxable;
        public String ApplicableTax; 
        public String ApplicableTaxName;
	    public Decimal ApplicableTaxRate; 
        public Decimal Cylinders;
        public Decimal Displacement;
        public Boolean IsAutomatic;
        public Decimal Gears;
        public String Notes;
        
        public String Customer;
        public String CustomerFirstName;
        public String CustomerLastName;
        public String CustomerNickname;
        public String BusinessName;
        public Boolean IsCustomerActive;
        public String CustomerType; 
        public String HomeEmail;
        public String WorkEmail;
        public String OtherEmail;
        public String HomeNumber;
        public String OtherPhone;
        public String WorkNumber;
        public Boolean HomeNumberSMS;
        public Boolean MobileNumberSMS;
        public Boolean WorkNumberSMS;
        
        public String FormattedHomeNumber;
        public String FormattedOtherPhone;
        public String FormattedWorkNumber;
        public String LinkedInLink;
        public String FacebookLink;
        public String TwitterLink;

        public String PreferredEmail;
        public String PreferredPhone;
        public String PreferredSMS;
        
        public String BillingStreet;
        public String BillingCity;
        public String BillingState;
        public String BillingCountry;
        public String BillingPostalCode;
        public String VendorId;
        
        public String TransmissionType;
        public Decimal TotalPrice;
        public Decimal TotalCost;
        public Decimal SalesTax;
        public String RegExpiryDate;
        public List<String> AssignedTags;
        public String DealItemId;
        public String CoNumber;
        public String CoId;
        public String CustomerName;
        public String CustomerId;
        public String ComplianceDate;
        public String YearOf1stRego;
    	public String RegistrationSerial;

        public UnitInfoWrapper(Customer_Owned_Unit__c unitRec) {
            this.Id = unitRec.Id;
            this.VendorId = unitRec.Vendor__c;
            this.Name = unitRec.Name != null ? unitRec.Name : '';
            this.VIN = (unitRec.VIN_Number__c == null) ? 'VIN Unknown' : unitRec.VIN_Number__c;
            this.UnitType = (unitRec.Unit_Type__c != null) ? unitRec.Unit_Type__c : '';
            if(unitRec.Unit_Type__c == 'Stock'){
                this.UnitId = unitRec.Stock_Id__c;
            }else if(unitRec.Unit_Type__c == 'COU' || unitRec.Unit_Type__c == 'ORDU'){
                this.UnitId = unitRec.Unit_Id__c;
            }
            if(unitRec.Status__c == 'Received') {
                this.StockNumber = unitRec.ORDU_Stock_Id__c;
            } else {
                this.StockNumber = unitRec.Stock_Id__c;
            }
    		this.ComplianceDate = unitRec.Compliance_Date__c;
    		this.RegistrationSerial = unitRec.Registration_Serial__c;
    		this.YearOf1stRego = unitRec.Year_Of_1st_Rego__c;
            this.Year = unitRec.Year__c;
            this.Make = unitRec.Unit_Make__c;
            this.MakeName = (unitRec.Unit_Make__c != null) ? unitRec.Unit_Make__r.Name : '';
            
            if(unitRec.Manufactured_Date__c != null){
                this.ManufacturedDate = BPUtility.getFormatedDateTime(datetime.newInstance(unitRec.Manufactured_Date__c.year(), unitRec.Manufactured_Date__c.month(),unitRec.Manufactured_Date__c.day()));
            }
            this.Model = unitRec.Unit_Model__c;
            this.ModelName = (unitRec.Unit_Model__c != null) ? unitRec.Unit_Model__r.Name__c : '';
            
            this.SubModel = unitRec.Sub_Model__c;
            this.SubModelName = (unitRec.Sub_Model__c != null) ? unitRec.Sub_Model__r.Sub_Model_Name__c : '';
            this.MakeModelDescription = (unitRec.Sub_Model__c != null) ? unitRec.Sub_Model__r.Sub_Model_Description__c : '';
            
            this.ExteriorColour = unitRec.Colour__c;
            this.Plate = unitRec.Plate__c;
            this.Mileage = unitRec.Mileage_Value__c;
            this.MileageType = unitRec.Mileage_Type__c;
            
            this.KeyNo = unitRec.Key_No__c;
            this.EngineSerialNo = unitRec.Engine_Serial_No__c;
            this.OtherSerialNo = unitRec.Other_Serial_No__c;
            this.FactoryOrderNo = (unitRec.Factory_Order_No__c != null) ? unitRec.Factory_Order_No__c : '';
            this.InteriorColour = unitRec.Interior_Colour__c;
            this.IsTaxable = unitRec.Taxable__c;
            this.ApplicableTax = unitRec.Applicable_Tax__c;
            this.ApplicableTaxName = (unitRec.Applicable_Tax__c != null) ? unitRec.Applicable_Tax__r.Name__c : '';
            this.ApplicableTaxRate = (unitRec.Applicable_Tax__c != null && unitRec.Applicable_Tax__r.Rate__c != null) ? unitRec.Applicable_Tax__r.Rate__c : 0;
	    	this.Cylinders = unitRec.Cylinders__c;
            this.Displacement = unitRec.Displacement__c;
            this.IsAutomatic = unitRec.Automatic__c;
            this.Gears = unitRec.Gears__c;
            this.Notes = unitRec.Notes__c;
            
            this.Status = unitRec.Status__c;
            this.IsNewUnit = unitRec.New_Unit__c;
            /* added by kajal 26th april, 2017 #1937 */
            this.TotalPrice = (unitRec.Total_Price__c != null) ? unitRec.Total_Price__c : 0;
            this.TotalCost = (unitRec.Total_Cost__c != null) ? unitRec.Total_Cost__c : 0;
            this.SalesTax = unitRec.Vendor__r.Purchase_Tax__r.Rate__c;
            /* added by kajal 26th april, 2017 #1937 */
            // Added by kajal 8th may , 2017
            if(unitRec.Reg_Expiry_Date__c != null){
                this.RegExpiryDate = BPUtility.getFormatedDateTime(datetime.newInstance(unitRec.Reg_Expiry_Date__c.year(), unitRec.Reg_Expiry_Date__c.month(),unitRec.Reg_Expiry_Date__c.day()));
            }
            // Added by kajal 8th may , 2017
            this.Category = unitRec.Category__c;
            this.CategoryName = (unitRec.Category__c != null) ? unitRec.Category__r.Name : '';
            if(unitRec.Date_Stocked_In__c != null){
                this.DateIn = BPUtility.getFormatedDateTime(datetime.newInstance(unitRec.Date_Stocked_In__c.year(), unitRec.Date_Stocked_In__c.month(),unitRec.Date_Stocked_In__c.day()));
            }
            if(unitRec.Date_Stocked_Out__c != null){
                this.DateOut =  BPUtility.getFormatedDateTime(datetime.newInstance(unitRec.Date_Stocked_Out__c.year(), unitRec.Date_Stocked_Out__c.month(),unitRec.Date_Stocked_Out__c.day()));
            }
            this.Age = unitRec.Age__c;
            this.Location = unitRec.Location__c;
            
            this.Customer = unitRec.Account__c;
            
            if(this.UnitType == 'STOCK') {
                if(unitRec.Status__c == 'Available') {
                    this.StatusColor = 'Green';
                } else if(unitRec.Status__c == 'Reserved' || unitRec.Status__c == 'Sold'){
                    this.StatusColor = 'Red';
                } else if(unitRec.Status__c == 'Traded' || unitRec.Status__c == 'Delivered'){
                    this.StatusColor = 'Black';
                }
            
            } else if(this.UnitType == 'COU') {
                if(unitRec.Status__c == 'Active') {
                    this.StatusColor = 'Green';
                } else if(unitRec.Status__c == 'Inactive'){
                    this.StatusColor = 'Red';
                } else if(unitRec.Status__c == 'Transferred'){
                    this.StatusColor = 'Black';
                }
            
            } else if(this.UnitType == 'ORDU') {
                if(unitRec.Status__c == 'On Order') {
                    this.StatusColor = 'Red';
                } else if(unitRec.Status__c == 'Cancelled' || unitRec.Status__c == 'Traded'){
                    this.StatusColor = 'Black';
                }
            }
            
            if(unitRec.Account__c != null){
                this.CustomerType = unitRec.Account__r.Type__c;
                this.IsCustomerActive = unitRec.Account__r.Active__c;
                this.CustomerFirstName = (unitRec.Account__r.FirstName__c == null) ? '' : unitRec.Account__r.FirstName__c;
                this.CustomerLastName = (unitRec.Account__r.LastName__c == null) ? '' : unitRec.Account__r.LastName__c;
                this.CustomerNickname = unitRec.Account__r.Nickname__c;
                this.BusinessName = (unitRec.Account__r.Name == null) ? '' : unitRec.Account__r.Name;
                //this.CustomerEmail = (unitRec.Account__c != null) ? unitRec.Account__r.Email__c : '';
                //this.CustomerPhone = (unitRec.Account__c != null) ? unitRec.Account__r.Preferred_Phone__c : '';
                //this.CustomerSMSPhone = (unitRec.Account__c != null) ? unitRec.Account__r.Preferred_SMS__c : '';
                
                this.HomeEmail = (unitRec.Account__r.Email__c == null) ? '' : unitRec.Account__r.Email__c;
                this.WorkEmail = (unitRec.Account__r.Work_Email__c == null) ? '' : unitRec.Account__r.Work_Email__c;
                this.OtherEmail = (unitRec.Account__r.Other_Email__c == null) ? '' : unitRec.Account__r.Other_Email__c;
                
                this.HomeNumber = (unitRec.Account__r.Home_Number__c == null ) ? '' : unitRec.Account__r.Home_Number__c;
                this.OtherPhone = (unitRec.Account__r.Mobile__c == null) ? '' : unitRec.Account__r.Mobile__c;
                this.WorkNumber = (unitRec.Account__r.Work_Number__c == null) ? '' : unitRec.Account__r.Work_Number__c;
                
                this.HomeNumberSMS = unitRec.Account__r.Home_Number_SMS__c;
                this.MobileNumberSMS = unitRec.Account__r.Mobile_Number_SMS__c;
                this.WorkNumberSMS = unitRec.Account__r.Work_Number_SMS__c;
                
                
                this.FormattedHomeNumber = (unitRec.Account__r.Home_Number__c == null ) ? '' : unitRec.Account__r.Formatted_Home_number__c;
                this.FormattedOtherPhone = (unitRec.Account__r.Mobile__c == null) ? '' : unitRec.Account__r.Formatted_Mobile_Number__c;
                this.FormattedWorkNumber = (unitRec.Account__r.Work_Number__c == null) ? '' : unitRec.Account__r.Formatted_Work_Number__c;

                this.LinkedInLink = unitRec.Account__r.LinkedIn__c;
                this.FacebookLink = unitRec.Account__r.Facebook__c;
                this.TwitterLink = unitRec.Account__r.Twitter__c;
                
                this.BillingStreet = (unitRec.Account__r.BillingStreet == null) ? '' : unitRec.Account__r.BillingStreet;
                this.BillingCity = (unitRec.Account__r.BillingCity == null) ? '' : unitRec.Account__r.BillingCity;
                this.BillingState = (unitRec.Account__r.BillingState == null) ? '' : unitRec.Account__r.BillingState;
                this.BillingCountry = (unitRec.Account__r.BillingCountry == null) ? '' : unitRec.Account__r.BillingCountry;
                this.BillingPostalCode = (unitRec.Account__r.BillingPostalCode == null) ? '' : unitRec.Account__r.BillingPostalCode;
        
                if(unitRec.Account__r.Preferred_Email__c != null) {
                    if(unitRec.Account__r.Preferred_Email__c == unitRec.Account__r.Email__c) {
                        this.PreferredEmail = 'HomeEmail';
                    } else if(unitRec.Account__r.Preferred_Email__c == unitRec.Account__r.Work_Email__c) {
                        this.PreferredEmail = 'WorkEmail';
                    } else if(unitRec.Account__r.Preferred_Email__c == unitRec.Account__r.Other_Email__c) {
                        this.PreferredEmail = 'OtherEmail';
                    }
                } else {
                    this.PreferredEmail = '';
                }
                
                if(unitRec.Account__r.Preferred_Phone__c != null) {
                    if(unitRec.Account__r.Preferred_Phone__c == unitRec.Account__r.Home_Number__c) {
                        this.PreferredPhone = 'FormattedHomeNumber';
                    } else if(unitRec.Account__r.Preferred_Phone__c == unitRec.Account__r.Mobile__c) {
                        this.PreferredPhone = 'FormattedOtherPhone';
                    } else if(unitRec.Account__r.Preferred_Phone__c == unitRec.Account__r.Work_Number__c) {
                        this.PreferredPhone = 'FormattedWorkNumber';
                    }
                } else {
                    this.PreferredPhone = '';
                }
                
                if(unitRec.Account__r.Preferred_SMS__c != null) {
                    if(unitRec.Account__r.Preferred_SMS__c == unitRec.Account__r.Home_Number__c) {
                        this.PreferredSMS = 'FormattedHomeNumber';
                    } else if(unitRec.Account__r.Preferred_SMS__c == unitRec.Account__r.Mobile__c) {
                        this.PreferredSMS = 'FormattedOtherPhone';
                    } else if(unitRec.Account__r.Preferred_SMS__c == unitRec.Account__r.Work_Number__c) {
                        this.PreferredSMS = 'FormattedWorkNumber';
                    }
                } else {
                    this.PreferredSMS = '';
                }
            }
            
            this.AssignedTags = TagUtil.getTagsList(unitRec);
            
            if(this.IsAutomatic) {
                this.TransmissionType = 'Automatic';
            } else if(this.Gears > 0) {
                this.TransmissionType = 'Manual';
            }
            this.DealItemId = unitRec.Deals_Units_Junction__r.size() > 0 ? unitRec.Deals_Units_Junction__r[0].Id: null;
            this.CoNumber = unitRec.Deals_Units_Junction__r.size() > 0 ? (unitRec.Deals_Units_Junction__r != null ? unitRec.Deals_Units_Junction__r[0].Deal__r.CO_Header__r.Name : null) : null;
            this.CoId = unitRec.Deals_Units_Junction__r.size() > 0 ? (unitRec.Deals_Units_Junction__r != null ? unitRec.Deals_Units_Junction__r[0].Deal__r.CO_Header__c : null) : null;
            this.CustomerName = unitRec.Deals_Units_Junction__r.size() > 0 ? (unitRec.Deals_Units_Junction__r != null ? unitRec.Deals_Units_Junction__r[0].Deal__r.CO_Header__r.Customer__r.Name : null) : null;
            this.CustomerId = unitRec.Deals_Units_Junction__r.size() > 0 ? (unitRec.Deals_Units_Junction__r != null ? unitRec.Deals_Units_Junction__r[0].Deal__r.CO_Header__r.Customer__c : null) : null;
        }
    } 
    
    public class PriceAndCostTrackingWrapper {  

        public String Id;
        public String Type;
        public String RefNo;
        public String ItemDescription;
        public String CoHeaderId;
        public Decimal ProfiltPercentage;
        public Decimal ProfitAmount;
        public Decimal Quantity;
        public Decimal Price;
        public Decimal TotalPrice;
        public Decimal TotalCost; 
        public String UnitId;// Added by kajal - 11/17/2016 - #1293 
        
        public PriceAndCostTrackingWrapper(Unit_Price_Cost__c unitPriceAndCostRec){

            this.Id = unitPriceAndCostRec.Id;
            this.Type = unitPriceAndCostRec.Type__c != null ? unitPriceAndCostRec.Type__c : '';
            // added by subhrant 04/12
            this.RefNo = unitPriceAndCostRec.CO_Invoice_Header__c != null ? unitPriceAndCostRec.CO_Invoice_Header__r.Invoice_Number__c : 
                            (unitPriceAndCostRec.Ref_No__c != null ? unitPriceAndCostRec.Ref_No__c : '');
            this.ItemDescription = unitPriceAndCostRec.Item_Description__c != null ? unitPriceAndCostRec.Item_Description__c : '';
            this.Quantity = unitPriceAndCostRec.Qty__c != null ? unitPriceAndCostRec.Qty__c : 0;
            this.Price = unitPriceAndCostRec.Price__c != null ? unitPriceAndCostRec.Price__c : 0;
            
            this.TotalPrice = unitPriceAndCostRec.Total_Price__c != null ? unitPriceAndCostRec.Total_Price__c : 0; 
            this.TotalCost = unitPriceAndCostRec.Total_Cost__c != null ? unitPriceAndCostRec.Total_Cost__c : 0;
            this.ProfiltPercentage = unitPriceAndCostRec.Profit_Percentage__c != null ? unitPriceAndCostRec.Profit_Percentage__c : 0;
            this.ProfitAmount = unitPriceAndCostRec.Profit_Amount__c != null ? unitPriceAndCostRec.Profit_Amount__c : 0;
            this.UnitId = unitPriceAndCostRec.Customer_Owned_Unit__c;// Added by kajal - 11/17/2016 - #1293
            this.CoHeaderId = (unitPriceAndCostRec.CO_Invoice_Header__c != null) ? unitPriceAndCostRec.CO_Invoice_Header__r.CO_Header__c : null;
        }
    } 
    
    public class OwnerWrapper { 
        public String Id;
        public String CreatedDate;
        public String UnitType;
        public String UnitId;
        public String Source;
        public String CustomerName;
        
        public OwnerWrapper(Customer_Owned_Unit__c similarUnitRec){
            this.Id = similarUnitRec.Id;
            this.UnitType = similarUnitRec.Unit_Type__c;
            if(similarUnitRec.Unit_Type__c == 'Stock'){
                this.UnitId = similarUnitRec.Stock_Id__c;
            } else if(similarUnitRec.Unit_Type__c == 'COU' || similarUnitRec.Unit_Type__c == 'ORDU'){
                this.UnitId = similarUnitRec.Unit_Id__c;
            }
            this.CreatedDate = BPUtility.getFormatedDateTime(similarUnitRec.CreatedDate);
            this.Source = 'New COU'; // This is to be changed
            this.CustomerName = (similarUnitRec.Account__c != null) ? similarUnitRec.Account__r.Name : '';
        }
    } 
    
    public class SalesTax {
        
        public String ApplicableTaxName;
        public String Id;
        public Decimal TaxRate;
        public Boolean IsDefault;
        
        public SalesTax(Sales_Tax__c salesTaxRec, Boolean isDefault) {
            this.ApplicableTaxName = salesTaxRec.Name__c;
            this.Id = salesTaxRec.Id;
            this.IsDefault = isDefault;
            this.TaxRate = (salesTaxRec.Rate__c != null) ? salesTaxRec.Rate__c : 0;
        }
    }
    
    // Start: for retrieving SO's for a unit 
    public class ServiceOrderWrapper {
        public String COHeaderId;
        public String COHeaderNumber;
        public String SOType;
        public String Concern;
        public Decimal Total;
        public Decimal MileageOut;
        public String LastModified;
        
        public ServiceOrderWrapper(Service_Order_Header__c soRec) {
            this.COHeaderId = (soRec.CO_Header__r.Id != null) ? soRec.CO_Header__r.Id : '';
            this.COHeaderNumber = (soRec.CO_Header__r.Name != null) ? soRec.CO_Header__r.Name : '';
            this.SOType = (soRec.SO_Type__c != null) ? soRec.SO_Type__c : '';
            
            if(soRec.SO_Type__c == 'Deal') { // if Added by richa 26/01/2017 for retrieving SO's for a unit  
                this.SOType = 'Deal Service';
            }
            
            this.Concern = (soRec.SO_Concern__c != null) ? soRec.SO_Concern__c.replace('\n', ', ') : '';
            Decimal TaxAmount = (soRec.Tax_Amount__c != null) ? soRec.Tax_Amount__c : 0.00;
            if(soRec.SO_Type__c == 'Deal') { // this.SOType Changed by richa 26/01/2017 for retrieving SO's for a unit 
                TaxAmount = 0.00;
            }
            Decimal TotalWithoutTax = (soRec.Total__c != null) ? soRec.Total__c : 0.00;
            this.Total = TotalWithoutTax + TaxAmount;
            this.MileageOut = (soRec.Odometer_on_Departure__c != null) ? (soRec.Odometer_on_Departure__c).setScale(2, RoundingMode.HALF_UP) : 0.00;
            this.LastModified = (soRec.LastModifiedDate != null) ? String.valueOf((soRec.LastModifiedDate).date().format()) : '';
        }
    }
    // End: for retrieving SO's for a unit

    public class Documents {
        public Boolean IsPrimary;
        public String DocId;
        public String AttachmentId;
        public String AttchmentURL;
        
        public Documents(Document__c docRec) {
            this.IsPrimary = docRec.Is_Primary__c;
            this.DocId = docRec.Id;
            if(docRec.Attachments.size() > 0) {
                this.AttachmentId = docRec.Attachments[0].Id;
                this.AttchmentURL = '/servlet/servlet.FileDownload?file='+AttachmentId;
            }
        }
    }
    
    /**
     * Name: parse
     * Desc: Method to Parse JSON String to class instance
     * @param:  (1) JSONString - String - JSON String 
     * @return: UnitWrapper - Class Object
    **/
    public static UnitWrapper parse(String json) {
        return (UnitWrapper) System.JSON.deserialize(json, UnitWrapper.class);
    }
    
    /**
     * Name: fieldsListForUnitInfo
     * Desc: Method Which contains all the field list to be queried for info section
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> fieldsListForUnitInfo(){
        List<String> COUFields = new List<String>{ 'Id',
                                                    'Name', 
                                                    'VIN_Number__c', 
                                                    'Account__c',
                                                    'Account__r.Name',
                                                    'Account__r.Nickname__c',
                                                    'Account__r.Active__c',
                                                    'Account__r.Type__c',
                                                    'Account__r.FirstName__c',
                                                    'Account__r.LastName__c',
                                                    'Account__r.Email__c',
                                                    'Account__r.Home_Number__c',
                                                    'Account__r.Home_Number_SMS__c',
                                                    'Account__r.Mobile__c',
                                                    'Account__r.Mobile_Number_SMS__c', 
                                                    'Account__r.Other_Email__c',
                                                    'Account__r.Preferred_Email__c',
                                                    'Account__r.Preferred_Phone__c',
                                                    'Account__r.Preferred_SMS__c',
                                                    'Account__r.Work_Email__c',
                                                    'Account__r.Work_Number__c',
                                                    'Account__r.Work_Number_SMS__c',
                                                    'Account__r.LinkedIn__c',
                                                    'Account__r.Twitter__c',
                                                    'Account__r.Facebook__c',
                                                    'Account__r.BillingStreet',
                                                    'Account__r.BillingCity',
                                                    'Account__r.BillingState',
                                                    'Account__r.BillingCountry',
                                                    'Account__r.BillingPostalCode',
                                                    'Account__r.Formatted_Home_number__c',
                                                    'Account__r.Formatted_Mobile_Number__c',
                                                    'Account__r.Formatted_Work_Number__c',
                                                    'Account__r.Formatted_Preferred_Phone__c',
                                                    'Vendor__r.Purchase_Tax__r.Rate__c',
                                                    'Unit_Type__c',
                                                    'Colour__c',
                                                    'Mileage_Value__c',
                                                    'Plate__c',
                                                    'Submodel__c',
                                                    'Sub_Model__r.Sub_Model_Description__c',
                                                    'Sub_Model__c',
                                                    'Sub_Model__r.Sub_Model_Name__c',
                                                    'Unit_Make__c',
                                                    'Unit_Make__r.Name',
                                                    'Unit_Model__c',
                                                    'Unit_Model__r.Name__c',
                                                    'Unit_Model__r.Sub_Model__c',
                                                    'Unit_Model__r.Unit_Make__r.Name',
                                                    'Unit_Model__r.Model_Description__c',
                                                    'Year__c',
                                                    'Notes__c',
                                                    'Manufactured_Date__c',
                                                    'Mileage_Type__c',
                                                    'Key_No__c',
                                                    'Interior_Colour__c',
                                                    'Taxable__c',
                                                    'Applicable_Tax__c',
                                                    'Applicable_Tax__r.Name__c',
													'Applicable_Tax__r.Rate__c',
                                                    'Cylinders__c',
                                                    'Displacement__c',
                                                    'Automatic__c',
                                                    'Gears__c',
                                                    'Status__c',
                                                    'New_Unit__c',
                                                    'Unit_Id__c',
                                                    'Stock_Id__c',
                                                    'Category__c',
                                                    'Category__r.Name',
                                                    'Date_Stocked_In__c',
                                                    'Date_Stocked_Out__c',
                                                    'Age__c',
                                                    'Location__c',
                                                    'Engine_Serial_No__c',
                                                    'Other_Serial_No__c',
                                                    'Factory_Order_No__c',
                                                    'CreatedDate',
                                                    'Total_Cost__c',
                                                    'Tax_Amount__c',
                                                    'Total_Price__c',
                                                    'Invoice_Number__c ',
                                                    'Reg_Expiry_Date__c',
                                                    'Assigned_Tag_1__c',
                                                    'Assigned_Tag_2__c',
                                                    'Formatted_Name__c',
                                                    'Vendor__c',
                                                    'Vendor__r.Name',
                                                    'Vendor__r.Preferred_Email__c',
                                                    'Vendor__r.Email__c',
                                                    'Vendor__r.Work_Email__c',
                                                    'Vendor__r.Other_Email__c',
                                                    'Vendor__r.Preferred_Phone__c',
                                                    'Vendor__r.Home_Number__c',
                                                    'Vendor__r.Formatted_Home_number__c',
                                                    'Vendor__r.Mobile__c',
                                                    'Vendor__r.Formatted_Mobile_Number__c',
                                                    'Vendor__r.Work_Number__c',
                                                    'Vendor__r.Formatted_Work_Number__c',
                                                    'Vendor__r.AccountNumber',
                                                    'Referenced_Unit__r.Unit_Id__c',
                                                    'Referenced_Unit__r.CreatedDate',
                                                    'Referenced_Unit__c',
                                                    'ORDU_Stock_Id__c',
                                                    'DP360_Inventory_Id__c',
                                                    'Compliance_Date__c',
                                                    'Registration_Serial__c',
                                                    'Year_Of_1st_Rego__c',
                                                    '(SELECT Name, Deal__r.CO_Header__r.Name, Deal__r.CO_Header__r.Customer__r.Name FROM Deals_Units_Junction__r)'
											    	};
        return COUFields; 
    }
    
    /**
     * Name: fieldsListForUnitPriceAndCostTracking
     * Desc: Method Which contains all the field list to be queried for Price and Tax Tracking section
     * @param:  
     * @return: List<String> - Fields List
     **/
    public static List<String> fieldsListForUnitPriceAndCostTracking(){
        List<String> COUFields = new List<String>{ 'Id',
                                                    'Type__c', 
                                                    'Ref_No__c', 
                                                    'Item_Description__c',
                                                    'Qty__c',
                                                    'Price__c',
                                                    'Total_Price__c',
                                                    'Total_Cost__c',
                                                    'Profit_Amount__c',
                                                    'Profit_Percentage__c',
                                                    'Customer_Owned_Unit__c',
                                                    'CO_Invoice_Header__c',
                                                    'CO_Invoice_Header__r.Invoice_Number__c',
                                                    'CO_Invoice_Header__r.CO_Header__c'
                                                };
        return COUFields;
    }

    // Start: for retrieving SO's for a unit
    /**
     * Name: fieldsListForServiceOrders
     * Desc: Method Which contains all the field list to be queried for retrieving SO's for a unit
     * @param:  
     * @return: List<String> - Fields List
     **/
    public static List<String> fieldsListForServiceOrders(){
        List<String> COUFields = new List<String>{ 'Id',
                                                    'Name', 
                                                    'SO_Type__c', 
                                                    'SO_Concern__c',
                                                    'Total__c',
                                                    'Total_With_Tax__c',
                                                    'Tax_Amount__c',
                                                    'Odometer_on_Departure__c',
                                                    'LastModifiedDate',
                                                    'CO_Header__r.Id',
                                                    'CO_Header__r.Name'
                                                };
        return COUFields;
    }
    // End: for retrieving SO's for a unit
}