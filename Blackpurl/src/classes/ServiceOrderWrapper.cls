public class ServiceOrderWrapper {
    
    public class SOWrapper {
        public SOInfo SOInfo;
        public List<SOHeaderWrapper.SOKitHeader> SOGridItems;
        public List<Attachments> AttachmentList;
        public List<HoursLogged> HoursLoggedList;
        public SOHeaderWrapper.Deductible DeductibleItem;
        public Decimal OrderTotal;
        public Decimal InvoicedAmount;
        public Decimal UninvoicedAmount;
        public Decimal TotalPayments;
        public List<CustomerApproval> CustomerApprovalList;
        
        public SOWrapper(Service_Order_Header__c soHeaderRec, List<Service_Order_Kit_Header__c> soKitHeaderList) {
            if(soHeaderRec != null) {
                this.SOInfo = new SOInfo(soHeaderRec); 
            }
            
            if(soKitHeaderList == null) {
                soKitHeaderList = new List<Service_Order_Kit_Header__c>();
            }
            
            List<DateTime> sortedDateTimeList = new List<dateTime>();
            Set<Id> soliIdSet = new Set<Id>();
            this.SOGridItems = new List<SOHeaderWrapper.SOKitHeader>();
            for(Service_Order_Kit_Header__c soKHRec : soKitHeaderList) {
                sortedDateTimeList.add( soKHRec.CreatedDate );
                
                this.SOGridItems.add(new SOHeaderWrapper.SOKitHeader(soKHRec, soKHRec.Service_Order_Line_Items__r, true));
                for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
                    soliIdSet.add(soliRec.Id);
                } 
            }
           
            Integer lastIndexValue = 0;
            for(Service_Order_Line_Item__c soliRec : soHeaderRec.Service_Order_Line_Items__r) {
                if(soliRec.Type__c == Constants.SHOP_SUPPLY) {
                    continue;
                }
                if(!soliIdSet.contains(soliRec.Id)) {
                    for(Integer i = lastIndexValue; i < sortedDateTimeList.size(); i++){
                        system.debug(i);
                        if(sortedDateTimeList[i] < soliRec.CreatedDate){
                            lastIndexValue ++;
                        } else {
                            break;
                        }
                    }
                    if(this.SOGridItems.size() > lastIndexValue){
                        this.SOGridItems.add(lastIndexValue, new SOHeaderWrapper.SOKitHeader(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
                        
                        if(sortedDateTimeList.size() > lastIndexValue){
                            sortedDateTimeList.add(lastIndexValue, soliRec.CreatedDate);
                        } else {
                            sortedDateTimeList.add(soliRec.CreatedDate);
                        }
                        
                        lastIndexValue++;
                    } else {
                        this.SOGridItems.add(new SOHeaderWrapper.SOKitHeader(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
                        lastIndexValue++;
                    }
                }
            }
            this.AttachmentList = new List<Attachments>();
            for(Attachment attchmentRec : soHeaderRec.Attachments) {
                this.AttachmentList.add(new Attachments(attchmentRec));
            }
            
            this.HoursLoggedList = new List<HoursLogged>();
            for(Hours_Logged__c hoursLogged : soHeaderRec.Hours_Logged__r) {
                this.HoursLoggedList.add(new HoursLogged(hoursLogged));
            }
            
            this.DeductibleItem = new SOHeaderWrapper.Deductible(soHeaderRec);
            this.InvoicedAmount = (soHeaderRec.CO_Header__r.Invoiced_Amount__c != null) ? soHeaderRec.CO_Header__r.Invoiced_Amount__c : 0;
            this.UninvoicedAmount = (soHeaderRec.CO_Header__r.Uninvoiced_Amount__c != null) ? soHeaderRec.CO_Header__r.Uninvoiced_Amount__c : 0;
            this.OrderTotal = (this.InvoicedAmount == null ? 0 : this.InvoicedAmount) + (this.UninvoicedAmount == null ? 0 : this.UninvoicedAmount);
            this.TotalPayments = (soHeaderRec.CO_Header__r.Total_Payment__c != null) ? soHeaderRec.CO_Header__r.Total_Payment__c : 0;
            
            this.CustomerApprovalList = new List<CustomerApproval>();
            for(CustomerApproval__c approvalRec : soHeaderRec.CustomerApprovals__r) {
                if(approvalRec.ApprovalType__c != 'Submit_Claim') {
                    this.CustomerApprovalList.add(new CustomerApproval(approvalRec));
                }
            }
        }
    }
    
    public class SOInfo {
        public Integer Level;
        public String Id;
        public String Name;
        public Decimal Total;
        public List<String> ManualConcern;
        public List<String> ManualCorrection; 
        public List<String> ManualCause;
        public List<String> KitHeaderCause;
        public List<String> KitHeaderConcern;
        public List<String> KitHeaderCorrection;
        public String TransactionTypeId;
        public String TransactionTypeLabel;
        public String TransactionType;
        public Boolean IsCompletedLinkShown;
        public String UnitId;
        public String UnitName;
        public String WorkStatus;
        public String InvoiceStatus;
        public Decimal OdometerIn;
        public String ProviderId;
        public String ProviderName;
        public String CategoryId;
        public String CategoryName;
        public Decimal OdometerOut;
        public List<String> NotesForCustomer;
        public String UNTName;
        public String ClaimStatus;
        public String DealId;
        public String VIN;
        public String StockId;
        public String UnitStatus;
        public Decimal TotalShopSupplies;
        
        public SOInfo() {
            this.Level = 1;
        }
        public SOInfo(Integer level) {
            this.Level = level;
        }
        
        public SOInfo(Service_Order_Header__c soHeaderRec) {
            this.Id = soHeaderRec.Id;
            this.Name = soHeaderRec.Name__c;
            this.ManualConcern = (soHeaderRec.SO_Concern__c != null) ? soHeaderRec.SO_Concern__c.split('\n') : new List<String>();
            this.ManualCorrection = (soHeaderRec.SO_Correction__c != null) ? soHeaderRec.SO_Correction__c.split('\n') : new List<String>();
            this.ManualCause = (soHeaderRec.SO_Cause__c != null) ? soHeaderRec.SO_Cause__c.split('\n') : new List<String>();
            if(soHeaderRec.Customer_Owned_Unit__c != null) {
                this.UnitId = soHeaderRec.Customer_Owned_Unit__c;
                this.VIN = String.isNotBlank(soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c) ? 
                            soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c : 'VIN Unknown';
                this.StockId = soHeaderRec.Customer_Owned_Unit__r.Stock_Id__c;
                this.UnitStatus = soHeaderRec.Customer_Owned_Unit__r.Status__c;
                this.UNTName = soHeaderRec.Customer_Owned_Unit__r.Unit_Id__c;
                this.UnitName = soHeaderRec.Customer_Owned_Unit__r.Formatted_Name__c;
            }
            this.KitHeaderCause = new List<String>();
            this.KitHeaderConcern = new List<String>();
            this.KitHeaderCorrection = new List<String>();
            
            if(soHeaderRec.Service_Order_Kit_Headers__r.size() > 0) {
                for(Service_Order_Kit_Header__c soKitHeaderRec : soHeaderRec.Service_Order_Kit_Headers__r) {
                    if(soKitHeaderRec.Kit_Header__c != null) {
                        this.KitHeaderCause.addAll((soKitHeaderRec.Kit_Header__r.Cause__c != null) ? soKitHeaderRec.Kit_Header__r.Cause__c.split('\n') : new List<String>());
                        this.KitHeaderConcern.addAll((soKitHeaderRec.Kit_Header__r.Concern__c != null) ? soKitHeaderRec.Kit_Header__r.Concern__c.split('\n') : new List<String>());
                        this.KitHeaderCorrection.addAll((soKitHeaderRec.Kit_Header__r.Correction__c != null) ? soKitHeaderRec.Kit_Header__r.Correction__c.split('\n') : new List<String>());
                    }
                }
            }
            this.DealId = soHeaderRec.Deal__c;
            this.TransactionTypeLabel = soHeaderRec.Transaction_Type__r.Code_Label__c;
            this.TransactionTypeId = soHeaderRec.Transaction_Type__c;
            this.TransactionType = soHeaderRec.Transaction_Type__r.Type__c;
            this.ClaimStatus = soHeaderRec.Claim_Status__c;
            
            this.IsCompletedLinkShown = true;
            List<Service_Order_Line_Item__c> soliList = soHeaderRec.Service_Order_Line_Items__r;
            for (Service_Order_Line_Item__c soli : soliList) {
                if(soli.Qty_To_Order__c > 0) {
                    this.IsCompletedLinkShown = false;
                }
            }
            this.Total = (soHeaderRec.Total__c != null) ? soHeaderRec.Total__c.setScale(2, RoundingMode.HALF_UP) : 0;
            this.TotalShopSupplies = (soHeaderRec.Total_Shop_Supplies__c != null) ? soHeaderRec.Total_Shop_Supplies__c.setScale(2, RoundingMode.HALF_UP) : 0;
            this.WorkStatus = soHeaderRec.Work_Status__c;
            
            if(soHeaderRec.CO_Invoice_Items__r.size() > 0) {
                this.InvoiceStatus = soHeaderRec.CO_Invoice_Items__r[0].Invoice_Header_Status__c;
            }
            
            this.OdometerIn = (soHeaderRec.Odometer_on_Arrival__c == null) ? 0 : soHeaderRec.Odometer_on_Arrival__c;
            this.OdometerOut = (soHeaderRec.Odometer_on_Departure__c == null) ? 0 : soHeaderRec.Odometer_on_Departure__c;
            
            this.NotesForCustomer = (soHeaderRec.SO_Notes_For_Customer__c != null) ? soHeaderRec.SO_Notes_For_Customer__c.split('\n') : new List<String>();
            this.ProviderId = soHeaderRec.Provider__c;
            this.ProviderName = (soHeaderRec.Provider__c != null) ? soHeaderRec.Provider__r.Name : '';
            
            if(soHeaderRec.Category__c != null) {
                this.CategoryName = soHeaderRec.Category__r.Name;
                this.CategoryId = soHeaderRec.Category__c;
            }
        }
        
        public List<String> getSOHeaderFieldsList(){
            List<String> soHeaderFieldsLevel1 = new List<String>{ 'Id',
                                                            'Name__c',
                                                            'Customer_Owned_Unit__c',
                                                            'Transaction_Type__c',
                                                            'Transaction_Type__r.Type__c',
                                                            'Transaction_Type__r.Code_Label__c',
                                                            'Transaction_Type__r.Type__c',
                                                            'Work_Status__c',
                                                            'SO_Cause__c',
                                                            'SO_Concern__c',
                                                            'SO_Correction__c',
                                                            'Odometer_on_Arrival__c',
                                                            'Odometer_on_Departure__c',
                                                            'Provider__c',
                                                            'Provider__r.Name',
                                                            'Category__c',
                                                            'Category__r.Name',
                                                            'Customer_Owned_Unit__r.Unit_Id__c',
                                                            'Customer_Owned_Unit__r.VIN_Number__c',
                                                            'Customer_Owned_Unit__r.Stock_Id__c',
                                                            'Customer_Owned_Unit__r.Status__c',
                                                            'Customer_Owned_Unit__r.Formatted_Name__c',
                                                            'Claim_Status__c',
                                                            'Deal__c'
                                                    };
                                                    
            List<String> soHeaderFieldsLevel2 = new List<String>{'Total__c',
                                                            'CO_Header__c',
                                                            'SO_Notes_For_Customer__c',
                                                            'Status__c',   
                                                            'SO_Notes__c',
                                                            'CO_Header__r.Invoiced_Amount__c',
                                                            'CO_Header__r.Uninvoiced_Amount__c',
                                                            'CO_Header__r.Total_Payment__c',
                                                            'Total_Parts__c',
                                                            'Total_Fees__c',
                                                            'Total_Labor__c',
                                                            'Total_Sublet__c',
                                                            'Total_Shop_Supplies__c',
                                                            'Total_Tax__c',
                                                            'Total_With_Tax__c'
                                                    };
                                                    
            List<String> soHeaderFieldList = new List<String>();
            if(this.Level == 1) {
                soHeaderFieldList = soHeaderFieldsLevel1;
            } else {
                soHeaderFieldsLevel2.addAll(soHeaderFieldsLevel1);
                soHeaderFieldList = soHeaderFieldsLevel2;
            }
            return soHeaderFieldList;
        }
    }
    
    /**
    * Name: SOKitHeader
    * Description: Apex class Service Order Kit Header
    **/
    public class SOKitHeader {
        
        public List<SOLineItem> SOLIList;
        public String ItemDescription;
        public Boolean CanItSplit;
        public String Code;
        public Boolean IsServiceKit;
        public String Id;
        public Decimal FixedPrice;
        public Decimal RetailPrice;
        public Boolean IsFixedPrice; 
        public Boolean hasChildren;
        public Boolean isFixedKitHeaderSO;
        public Decimal taxAmount;
        public Decimal Price;
        
        public SOKitHeader(Service_Order_Kit_Header__c soKitHeaderRec, List<Service_Order_Line_Item__c> soliList, Boolean hasChildren) {
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            this.SOLIList = new List<SOLineItem>();
            this.taxAmount = (soKitHeaderRec.Tax_Amount__c != null) ? soKitHeaderRec.Tax_Amount__c : 0;
            this.ItemDescription = soKitHeaderRec.Kit_Unique_Name__c;
            this.CanItSplit = soKitHeaderRec.Can_Split__c;
            this.IsServiceKit = soKitHeaderRec.Service_Kit__c;
            this.Code = soKitHeaderRec.Code__c;
            this.Id = soKitHeaderRec.Id;
            this.FixedPrice = soKitHeaderRec.Fixed_Price__c;
            this.isFixedKitHeaderSO = soKitHeaderRec.Is_Fixed_Kit_Header_SO__c;
            
            this.IsFixedPrice = soKitHeaderRec.Fixed_Price_Flag__c;
            this.Price = 0;
            Decimal soliKitPrice = 0;
            for(Service_Order_Line_Item__c soliRec : soliList) {
                if(soliRec.Type__c == Constants.SHOP_SUPPLY) {
                    continue;
                }
                this.SOLIList.add(new SOLineItem(soliRec));
                Decimal soliTax = (soliRec.Tax_Percent__c != null) ? soliRec.Tax_Percent__c : 0;
                if(hasChildren) {
                    if(isTaxIncludingPricing && String.isBlank(soliRec.Deal__c)) {
                        if(soliTax == null) {
                            soliTax = 0;
                        }
                        if(soliRec.Kit_Price__c == null) {
                            soliRec.Kit_Price__c = 0;
                        }
                        if(soliRec.Price_When_Tax_Included__c == null) {
                            soliRec.Price_When_Tax_Included__c = (soliRec.Kit_Price__c * (1 + (soliTax / 100))).setScale(2, RoundingMode.HALF_UP);
                        }
                        soliKitPrice = soliRec.Price_When_Tax_Included__c;
                    } else {
                        soliKitPrice = (soliRec.Kit_Price__c != null) ? soliRec.Kit_Price__c.SetScale(2, RoundingMode.HALF_UP) : soliRec.Kit_Price__c;
                    }
                    this.Price += (soliRec.Qty_Needed__c != null) ? (soliKitPrice * soliRec.Qty_Needed__c) : 0;
                    this.Price = this.Price.setScale(2, RoundingMode.HALF_UP);
                }
            }
            this.hasChildren = hasChildren;
            
        }
    }
    
    public static List<String> getSOLineItemFieldsList(){
        List<String> soLineItemFields = new List<String>{   'Id',
                                                            'Fixed_Price__c',
                                                            'CO_Line_Item__c',
                                                            'Item_Desc__c',
                                                            'Item_Code__c',
                                                            'Item_Description__c',
                                                            'Kit_Price__c',
                                                            'Price_When_Tax_Included__c',
                                                            'Labour_Code__c',
                                                            'Part__c',
                                                            'Part__r.AvailableParts__c',
                                                            'Qty_Needed__c',
                                                            'Qty_Committed__c',
                                                            'Retail_Price__c',
                                                            'Service_Order_Header__c',
                                                            'Service_Order_Kit_Header__c',
                                                            'Total__c',
                                                            'CreatedDate',
                                                            'CO_Line_Item__r.Special_Order__c',
                                                            'CO_Line_Item__r.Status__c',
                                                            'CO_Line_Item__r.Closed_CO_Invoice_link__c',
                                                            'CO_Line_Item__r.Oversold_Qty__c',
                                                            'CO_Line_Item__r.CO_Status__c',
                                                            'Part__r.Vendor__c',
                                                            'Part__r.Non_Inventory_Part__c',
                                                            'Fee__c',
                                                            'Qty_To_Order__c',
                                                            'Actual_Kit_Price__c',
                                                            'Tax__c',
                                                            'Tax_Percent__c',
                                                            'Labour_Tax_Amount__c',
                                                            'Kit_Price_With_Price_Level__c',
                                                            'Deal__c',
                                                            'Deal_Item__c',
                                                            'Option_Fee__c',
                                                            'CO_Line_Item__r.Vendor_Order_Header__r.Status__c',
                                                            'CO_Line_Item__r.VO_Number__c',
                                                            'Is_Environmental_Fee__c',
                                                            'Sublet__c',
                                                            'Type__c',
                                                            'Labour_Code__r.Calculate_Supplies__c',
                                                            'Labour_Code__r.Supplies_Detail__c'
                                                };
        return soLineItemFields;
    }
    
    /**
     * Name: getTTFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getTTFieldsList(){
        List<String> ttFields = new List<String>{   'Id',
                                                    'Type__c',
                                                    'Code_Label__c'
                                                };
        return ttFields;
    }
    
    public static List<String> getTechnicianFieldsList() {
        return new List<String>{ 'Id',
                                'First_Name__c',
                                'Last_Name__c',
                                'Type__c',
                                'Technician_Name__c',
                                'CreatedDate',
                                'LastModifiedDate',
                                'User__c'
                    };
    }
    
    /**
    * Name: SOLineItem
    * Description: Apex class Service Order Line Item
    **/
    public class SOLineItem {
        
        public String Id;
        public String ItemDesc;
        public String ItemCode;
        public String ItemDescription;
        public String Status;
        public Decimal QtyNeeded;
        public Decimal StockCommited;
        public Decimal StockCommitedCpy; // To reset values on UI - related to user permissions - oversell inventory
        public Decimal QtyOrder;
        public Decimal ReatilPrice;
        public Decimal SubTotal;
        public Decimal NoOfAvailablePart;
        public Decimal OversoldQty;
        public Decimal ActualAvailableParts;
        public Decimal Tax;
        
        public String PartId;
        public Boolean IsPart;
        public Boolean IsLabour;
        public Boolean IsFee;
        public Boolean IsSublet{get; set;}
        public String SOKitHeaderId;
        public Decimal KitPrice;
        public String COLineItemId;
        public Boolean IsNonInventoryPart;
        public Boolean IsEnvFee;
        
        public Boolean IsHidden;
        public Boolean IsFixedPrice;
        public Boolean isFixedKitHeaderLineItemSO;
        
        /**
        * Name: SOLineItem
        * Desc: Constructor
        * @param:   (1)soLineItemRec - Service_Order_Line_Item__c - Service Order Line Item Record
        * @return: 
        **/
        public SOLineItem(Service_Order_Line_Item__c soLineItemRec) {
            this.Id = soLineItemRec.Id; 
            this.ItemCode = soLineItemRec.Item_Code__c;
            this.ItemDescription = soLineItemRec.Item_Description__c;
            this.ItemDesc = this.ItemCode + ' - ' + this.ItemDescription;
            this.QtyNeeded = (soLineItemRec.Qty_Needed__c != null ) ? soLineItemRec.Qty_Needed__c : 0;
            
            this.PartId = soLineItemRec.Part__c;
            this.IsPart = (soLineItemRec.Part__c != null) ? true : false;
            this.IsLabour = (soLineItemRec.Labour_Code__c != null) ? true : false;
            this.IsFee = (soLineItemRec.Fee__c != null) ? true : false;
            this.IsSublet = (soLineItemRec.Sublet__c != null) ? true : false;
            
            this.isFixedKitHeaderLineItemSO = soLineItemRec.Is_Fixed_Kit_LineItem_SO__c;
            this.IsFixedPrice = soLineItemRec.Fixed_Price__c;
            this.IsHidden = soLineItemRec.Is_Hidden__c;
            if(soLineItemRec.Qty_Needed__c >= 0) {
                if(this.IsLabour || this.IsFee || this.IsSublet) {
                    this.StockCommited = this.QtyNeeded;
                } else {
                    this.StockCommited = (soLineItemRec.Qty_Committed__c != null) ? soLineItemRec.Qty_Committed__c : 0;
                }
                this.QtyOrder = this.QtyNeeded - this.StockCommited;
            } else {
                this.QtyOrder = null;
                this.StockCommited = null;
            }
            
            this.StockCommitedCpy = this.StockCommited;
            
            this.Status = getSOLIStatus(soLineItemRec, this.QtyNeeded, this.StockCommited);
            
            this.Tax = (soLineItemRec.Tax_Percent__c != null) ? soLineItemRec.Tax_Percent__c : 0;
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            if(isTaxIncludingPricing && String.isBlank(soLineItemRec.Deal__c)) {
                this.Tax = (this.Tax != null) ? this.Tax : 0;
                if(soLineItemRec.Price_When_Tax_Included__c == null) {
                    soLineItemRec.Price_When_Tax_Included__c = (soLineItemRec.Kit_Price__c * (1 + (this.Tax / 100))).setScale(2, RoundingMode.HALF_UP);
                }
                this.KitPrice = soLineItemRec.Price_When_Tax_Included__c;
            } else {
                this.KitPrice = (soLineItemRec.Kit_Price__c != null) ? soLineItemRec.Kit_Price__c.SetScale(2, RoundingMode.HALF_UP) : soLineItemRec.Kit_Price__c;
            }
            
            this.ReatilPrice = (soLineItemRec.Retail_Price__c != null) ? soLineItemRec.Retail_Price__c.SetScale(2, RoundingMode.HALF_UP) : soLineItemRec.Retail_Price__c;
            
            if(soLineItemRec.Part__c != null) {
                this.IsNonInventoryPart = soLineItemRec.Part__r.Non_Inventory_Part__c;
                this.NoOfAvailablePart = (soLineItemRec.Part__c != null) ? (soLineItemRec.Part__r.AvailableParts__c) : null;
                this.IsPart = true;
            }
            this.OversoldQty = (soLineItemRec.CO_Line_Item__c != null) ? (soLineItemRec.CO_Line_Item__r.Oversold_Qty__c) : null; 
            if(this.IsPart && (this.IsNonInventoryPart == null || this.IsNonInventoryPart == false)) {
                this.ActualAvailableParts = ((this.NoOfAvailablePart != null ? this.NoOfAvailablePart : 0) + (this.StockCommited != null ? this.StockCommited : 0) - (this.OversoldQty != null ? this.OversoldQty : 0));
            }           
            this.SOKitHeaderId = soLineItemRec.Service_Order_Kit_Header__c;
            this.COLineItemId = soLineItemRec.CO_Line_Item__c;
            this.IsEnvFee = soLineItemRec.Is_Environmental_Fee__c;
        }
    }
    
    private static String getSOLIStatus(Service_Order_Line_Item__c soLineItemRec, Decimal qtyNeeded, Decimal qtyCommitted) {
        String status;
        if(soLineItemRec.CO_Line_Item__r.Closed_CO_Invoice_link__c != null) {
            status = 'Invoiced'; 
        } else {
            if((qtyNeeded == qtyCommitted) || soLineItemRec.Part__r.Non_Inventory_Part__c) {
                status = 'In Stock';
            } else if(qtyNeeded > qtyCommitted) {
                if(soLineItemRec.CO_Line_Item__r.CO_Status__c == Constants.CO_STATUS_QUOTE) {
                    if(soLineItemRec.Part__r.AvailableParts__c >= qtyNeeded) {
                        status = 'In Stock'; 
                    } else {
                        status = 'Required'; 
                    }
                } else {
                    if(soLineItemRec.CO_Line_Item__r.Status__c != null) {
                        status = soLineItemRec.CO_Line_Item__r.Status__c;
                    } else if(!soLineItemRec.CO_Line_Item__r.Special_Order__c) {
                        status = 'Required';
                    } else {
                        status = 'Ordered';
                    }
                }
            } else if(soLineItemRec.Qty_Needed__c < 0) {
                status = 'RETURN';
            }
        }
        
        if(soLineItemRec.CO_Line_Item__c != null && soLineItemRec.CO_Line_Item__r.Closed_CO_Invoice_link__c == null 
                    && soLineItemRec.CO_Line_Item__r.Oversold_Qty__c > 0) {
            status = 'Oversold';
        }
        
        return status;
    }
    
    
    public class Attachments {
        public String UploadedDate;
        public String AttachmentName;
        public String AttachmentId;
        public String AttachmentURL;
        public String Source;
        
        public Attachments(Attachment attachmentRec) {
            this.UploadedDate = attachmentRec.CreatedDate.format('MM/dd/YYYY');
            this.AttachmentName = attachmentRec.Name;
            this.AttachmentId = attachmentRec.Id;
            this.Source = attachmentRec.Description;
            this.AttachmentURL = '/servlet/servlet.FileDownload?file='+AttachmentId;
        }
    }
    
    /**
    * Name: SOMasterData
    * Description: Apex class Service Order Master Data
    **/
    public class SOMasterData {
        public List<ServiceOrderWrapper.TTType> TTList;
        public List<ServiceOrderWrapper.Unit> COUList;
        public List<SOHeaderWrapper.VendorAsProvider> ProviderList;
        public List<ServiceOrderWrapper.SOCategory> CategoryList;
            
        /**
        * Name: SOMasterData
        * Desc: Constructor
        * @param:   (1)ttRecList - List<Transaction_Type__c> - Transaction Type List
        *           (2)couList - List<Customer_Owned_Unit__c> - Customer Owned Unit Record
        * @return:  
        **/
        public SOMasterData(List<Transaction_Type__c> ttRecList, List<Customer_Owned_Unit__c> couList, List<Account> providerList) {
            this.TTList = new List<ServiceOrderWrapper.TTType>();
            this.COUList = new List<ServiceOrderWrapper.Unit>();
            
            this.ProviderList = new List<SOHeaderWrapper.VendorAsProvider>();
            for(Account providerRec : providerList) {
                this.ProviderList.add(new SOHeaderWrapper.VendorAsProvider(providerRec));
            }
            
            for(Transaction_Type__c ttRec : ttRecList) {
                this.ttList.add(new ServiceOrderWrapper.TTType(ttRec));
            }
            for(Customer_Owned_Unit__c unitRec : couList) { 
                ServiceOrderWrapper.Unit unitObj = new ServiceOrderWrapper.Unit(unitRec);
                if(String.isNotBlank(unitObj.FormattedName)) {
                    this.COUList.add(new ServiceOrderWrapper.Unit(unitRec));
                }
            }
        }

        /**
        * Name: SOMasterData
        * Desc: Constructor
        * @param:   (1)categoryList - List<Category__c> - Category list
        * @return:
        **/
        public SOMasterData(List<Category__c> categoryList) {
            this.CategoryList = new List<ServiceOrderWrapper.SOCategory>();
            for(Category__c categoryObj : categoryList) { 
                this.CategoryList.add(new ServiceOrderWrapper.SOCategory(categoryObj));
            }
        } 
    }
    
    /**
    * Name: SOCategory
    * Description: Apex class for Service Order Category object
    **/
    public class SOCategory {
        public String Id;
        public String Name;
        public Boolean IsDefault;

        /**
        * Name: SOCategory
        * Desc: Constructor
        * @return:  
        **/
        public SOCategory(Category__c categoryRec) {
            this.Id = categoryRec.Id;
            this.Name = categoryRec.Name;
            this.IsDefault = categoryRec.Default__c;
        }
    }
    
    /**
    * Name: TTType
    * Description: Apex class Transation Type
    **/
    public class TTType {
        public String Type;
        public String Id;
        public String CodeLabel;
        public List<SOHeaderWrapper.Provider> ProviderList;
        public String InternalCategoryId;
        public String InternalCategoryName;
        public String ProviderId;
        public String ProviderName;
        
        /**
        * Name: TTType
        * Desc: Constructor
        * @param:   (1)ttRec - Transaction_Type__c - Transaction Type Record
        * @return:  
        **/
        public TTType(Transaction_Type__c ttRec) {
            this.Id = ttRec.Id;
            this.Type = ttRec.Type__c;
            this.CodeLabel = ttRec.Code_Label__c;
            this.ProviderList = new List<SOHeaderWrapper.Provider>();
            for(Provider__c providerRec : ttRec.Providers__r) {
                this.ProviderList.add(new SOHeaderWrapper.Provider(providerRec));
            }
            this.InternalCategoryId = ttRec.Internal_Category__r.Id;
            this.InternalCategoryName = ttRec.Internal_Category__r.Name;
            this.ProviderId = ttRec.Third_Party_Customer__r.Id;
            this.ProviderName = ttRec.Third_Party_Customer__r.Name;
        }   
    }
    
    public class Unit {
       public String Id;
        public String FormattedName;
        public String VIN;
        public String UnitId;
        
        public Unit(Customer_Owned_Unit__c unitRec) {
            this.Id = unitRec.Id;
            this.FormattedName = getFormattedString(unitRec).trim();
            this.VIN = unitRec.VIN_Number__c;
            this.UnitId = unitRec.Unit_Id__c;
        }
        
        private String getFormattedString(Customer_Owned_Unit__c unitRec) {
            return ((unitRec.Unit_Make__c != null) ? unitRec.Unit_Make__r.Name + ' ' : '') + 
                       ((unitRec.Unit_Model__c != null) ? unitRec.Unit_Model__r.Name__c + ' ' : '') + 
                       ((unitRec.Sub_Model__c != null && unitRec.Sub_Model__r.Sub_Model_Name__c != null) 
                                       ? unitRec.Sub_Model__r.Sub_Model_Name__c + ' ' : '') +
                       ((unitRec.Year__c != null) ? STring.valueOf(unitRec.Year__c) : '');
        }
    }
    
    public class HoursLogged {
        
        public String EmployeeId;
        public String EmployeeName;
        public String Notes;
        public String OriginalEstimate;
        public String PreviouslyLogged;
        public Decimal RemainingEstimate_D;
        public Decimal RemainingEstimate_H;
        public Decimal RemainingEstimate_M;
        public String SOHeaderId;
        public String TimeSpent;
        public Decimal TimeSpent_D;
        public Decimal TimeSpent_H;
        public Decimal TimeSpent_M;
        public String WorkPerformedDate;
        public String CreatedDate;
        public String Id;
        public String Log; 
        public String SOHeaderStatus;
        public Decimal TotalHours;
        public Boolean NotesRequired;
        public string TimeIn;
        public String TimeOut;
        public String StartDate;
        public Decimal CalculatedHours;
        
        /**
        * Name: HoursLogged
        * Desc: Constructor
        * @param:   (1)hoursLoggedRec - Hours_Logged__c - hours logged Record
        * @return: 
        **/
        public HoursLogged(Hours_Logged__c hoursLoggedRec) {
            this.Id = hoursLoggedRec.Id;
            this.EmployeeName = (hoursLoggedRec.Technician__c != null) ? hoursLoggedRec.Technician__r.Technician_Name__c : null;
            this.EmployeeId = hoursLoggedRec.Technician__c;
            this.Notes= hoursLoggedRec.Notes__c;
            this.OriginalEstimate = hoursLoggedRec.Original_Estimate__c;
            this.PreviouslyLogged = hoursLoggedRec.Previously_Logged__c;
            this.RemainingEstimate_D = hoursLoggedRec.Remaining_Estimate_d__c;
            this.RemainingEstimate_H = hoursLoggedRec.Remaining_Estimate_h__c;
            this.RemainingEstimate_M = hoursLoggedRec.Remaining_Estimate_m__c;
            this.SOHeaderId = hoursLoggedRec.Service_Order_Header__c;
            this.TimeSpent = hoursLoggedRec.Time_Spent__c;
            this.TimeSpent_D = hoursLoggedRec.Time_Spent_d__c;
            this.TimeSpent_H = hoursLoggedRec.Time_Spent_h__c;   
            this.TimeSpent_M = hoursLoggedRec.Time_Spent_m__c;
            if(hoursLoggedRec.Work_Performed_Date__c != null) {
                this.WorkPerformedDate = (DateTime.newInstance(hoursLoggedRec.Work_Performed_Date__c.Year(), hoursLoggedRec.Work_Performed_Date__c.Month(), hoursLoggedRec.Work_Performed_Date__c.Day())).format('MM/dd/yyyy');
            }
            this.TotalHours = hoursLoggedRec.Total_Hours__c;
            this.CreatedDate = hoursLoggedRec.CreatedDate.format('MMM dd, yyyy');
            this.Log = hoursLoggedRec.Name;
            this.SOHeaderStatus = hoursLoggedRec.Service_Order_Header__r.Status__c;
            this.NotesRequired = hoursLoggedRec.Notes_Required__c ;
            this.TimeIn = (hoursLoggedRec.Start_Date_Time__c != null) ? hoursLoggedRec.Start_Date_Time__c.format('h:mm a') : '';
            this.TimeOut = (hoursLoggedRec.End_Date_Time__c != null) ? hoursLoggedRec.End_Date_Time__c.format('h:mm a') : '';
            this.StartDate = (hoursLoggedRec.Start_Date_Time__c != null) ? 
                                hoursLoggedRec.Start_Date_Time__c.format(Constants.localeToDateTimeFmtMap.get(UserInfo.getLocale())) : '';
            this.CalculatedHours = hoursLoggedRec.Calculated_Hours__c;
                                
        }
    }
}