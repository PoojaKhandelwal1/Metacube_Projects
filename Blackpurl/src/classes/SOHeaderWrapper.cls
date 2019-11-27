/**
* Author: Tarun Khandelwal
* Since: Dec 15, 2015
* Name: SOHeaderWrapper
* Description: Apex class which contains all JSON related oprations of Service Order
**/
public with sharing class SOHeaderWrapper {

    public Decimal OrderTotal;
    public Decimal InvoicedAmount;
    public Decimal UninvoicedAmount;
    
    public List<SOWrapper> SOList;
    public List<String> PinnedItemList;
    public SO_KLI_Recalculation.Errorhandler error;
    
    // List of CO Invoice Items
    public List<COInvoiceItem> coInvoiceItemRecs; 
    
    // List of CO Line Items
    public List<SpecialOrder> specialOrderList;
    
    // CO Invoice Header Record.
    public COInvoiceHeader coInvoiceHeaderRec;
    
    /**
     * Name: SOHeaderWrapper
     * Desc: Constructor
     * @param:  (1) soHeaderRecList - List<Service_Order_Header__c> - List of service order header
                (2)pinItems - List<String> - list of pin items
                (3)soHeaderIdToSOKIListMap -  Map<Id, List<Service_Order_Kit_Header__c>> - map of service order kit with id
                (4)coInvoiceHeader - List<CO_Invoice_Header__c> - List of  coinvoice header
                (5)coInvoiceItems - List<CO_Invoice_Item__c> - List of coinvoice item  
                (6)specialOrderList -List<CO_Line_Item__c> - List of coLine items
     * @return: 
    **/
    public SOHeaderWrapper(List<Service_Order_Header__c> soHeaderRecList, List<String> pinItems, Map<Id, List<Service_Order_Kit_Header__c>> soHeaderIdToSOKIListMap,
                                List<CO_Invoice_Header__c> coInvoiceHeader, List<CO_Invoice_Item__c> coInvoiceItems, List<Vendor_Order_Line_Item__c> specialOrderList) {
        
        this.OrderTotal = 0;
        if(soHeaderRecList.size() > 0){
            this.InvoicedAmount = soHeaderRecList[0].CO_Header__r.Invoiced_Amount__c;
            this.UninvoicedAmount = soHeaderRecList[0].CO_Header__r.Uninvoiced_Amount__c;
            this.OrderTotal = (this.InvoicedAmount == null ? 0 : this.InvoicedAmount) + (this.UninvoicedAmount == null ? 0 : this.UninvoicedAmount);
        }
         
        this.PinnedItemList = new List<String>();
        this.coInvoiceItemRecs = new List<COInvoiceItem>();
        this.specialOrderList = new List<SpecialOrder>(); 
        if(pinItems.size() > 0) {
            this.PinnedItemList.addAll(pinItems);
        }
        this.SOList = new List<SOWrapper>();
        //system.assert(false, soHeaderRecList);
        for(Service_Order_Header__c soHeaderRec : soHeaderRecList) {
            if(soHeaderIdToSOKIListMap.containsKey(soHeaderRec.Id)) {
                this.SOList.add(new SOWrapper(soHeaderRec, soHeaderIdToSOKIListMap.get(soHeaderRec.Id)));
            } else {
                this.SOList.add(new SOWrapper(soHeaderRec, new List<Service_Order_Kit_Header__c>()));
            }
        }
        
        Decimal deductibleTotal = 0;
        for(CO_Invoice_Item__c coInvoiceItemRecord : coInvoiceItems) {
            if(coInvoiceItemRecord.CO_Line_Item__c != null && coInvoiceItemRecord.CO_Line_Item__r.Qty__c <= 0) {
                //continue;
            }
            if(coInvoiceItemRecord.SO_Payment_Role__c != null && coInvoiceItemRecord.SO_Payment_Role__r.RecordType.DeveloperName == 'Deductible') {
                deductibleTotal += coInvoiceItemRecord.SO_Payment_Role__r.Total_Amount__c;
            }
            this.coInvoiceItemRecs.add(new COInvoiceItem(coInvoiceItemRecord));
        }
        
        for(COInvoiceItem coInvoiceItemObj : coInvoiceItemRecs) {
            if(coInvoiceItemObj.CheckoutType == Constants.CHECKOUT_TYPE_THIRD_PARTY) {
                coInvoiceItemObj.Total = coInvoiceItemObj.Total - deductibleTotal;
            }
        }
        
        for(CO_Invoice_Header__c coInvoiceHeaderRecord : coInvoiceHeader) {
            this.coInvoiceHeaderRec = new COInvoiceHeader(coInvoiceHeaderRecord);
        }
        for(Vendor_Order_Line_Item__c specialOrderObj : specialOrderList) {
            this.specialOrderList.add(new SpecialOrder(specialOrderObj));
        }
        this.error = (CustomerOrderCtrl.error != null) ? CustomerOrderCtrl.error : new SO_KLI_Recalculation.Errorhandler('200', 'Success');
    }
    
    /**
     * Name: getDateTimeFromString
     * Desc: Get Date Time From String 
     * @param:  (1) dtStr - String - string contain date and time
     * @return: DateTime - date time Object 
    **/
    public static DateTime getDateTimeFromString(String dtStr) {
        if(String.isBlank(dtStr)) {
            return null;
        }
        List<String> dateTimeList = dtStr.split(' ');
        Integer day = Integer.valueOf(dateTimeList[0].split('/')[1]);
        Integer month = Integer.valueOf(dateTimeList[0].split('/')[0]);
        Integer year = Integer.valueOf(dateTimeList[0].split('/')[2]);
        Integer hour = Integer.valueOf(dateTimeList[1].split(':')[0]);
        Integer min = Integer.valueOf(dateTimeList[1].split(':')[1]);
        if(hour == 12) {
            hour -= 12;
        }
        if(dateTimeList[2] == 'PM') {
            hour += 12;
        }
        return datetime.newInstance(year, month, day, hour, min, 0);
    }
    
    /**
     * Name: getSOHeaderFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getSOHeaderFieldsList(){
        List<String> soHeaderFields = new List<String>{ 'Id',
                                                        'Name__c',
                                                        'SO_Cause__c',
                                                        'SO_Concern__c',
                                                        'SO_Correction__c',
                                                        'Promised_By__c',
                                                        'Total__c',
                                                        'Stock__c',
                                                        'Estimated_Hours__c',
                                                        'Customer_Owned_Unit__c',
                                                        'Customer_Owned_Unit__r.VIN_Number__c',
                                                        'Customer_Owned_Unit__r.Unit_Id__c',
                                                        'Customer_Owned_Unit__r.Stock_Id__c',
                                                        'Customer_Owned_Unit__r.Unit_Type__c',
                                                        'Customer_Owned_Unit__r.Year__c',
                                                        'Customer_Owned_Unit__r.Unit_Make__c',
                                                        'Customer_Owned_Unit__r.Unit_Model__c',
                                                        'Customer_Owned_Unit__r.Unit_Make__r.Name',
                                                        'Customer_Owned_Unit__r.Unit_Model__r.Name__c',
                                                        'Customer_Owned_Unit__r.Unit_Model__r.Sub_Model__c',
                                                        'Customer_Owned_Unit__r.Sub_Model__c',
                                                        'Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c',
                                                        'Customer_Owned_Unit__r.Submodel__r.Name__c', // Ticket#1845: Added By Pooja 1 May 2017
                                                        'Customer_Owned_Unit__r.Colour__c',
                                                        'Customer_Owned_Unit__r.Status__c',
                                                        'Customer_Owned_Unit__r.Formatted_Name__c',
                                                        'CO_Header__c',
                                                        'Provider__c',
                                                        'Provider__r.Name',
                                                        'Category__c',
                                                        'Category__r.Name',
                                                        'Odometer_on_Arrival__c',
                                                        'Odometer_on_Departure__c',
                                                        'Transaction_Type__c',
                                                        'SO_Notes_For_Customer__c',
                                                        'Transaction_Type__r.Type__c',
                                                        'Transaction_Type__r.Code_Label__c',
                                                        'IsPromisedBy_AmPm__c',            
                                                        'Status__c',   
                                                        'SO_Notes__c',
                                                        'Work_Status__c',
                                                        'Claim_Status__c',
                                                        'Deal_Item__c',
                                                        'Deal__c',
                                                        'Scheduled_Date__c',
                                                        'CO_Header__r.Invoiced_Amount__c',
                                                        'CO_Header__r.Uninvoiced_Amount__c',
                                                        'CO_Header__r.Total_Payment__c',
                                                        'Total_Parts__c',
                                                        'Total_Fees__c',
                                                        'Total_Labor__c',
                                                        'Total_Sublet__c',
                                                        'Total_Tax__c',
                                                        'Total_With_Tax__c',
                                                        'Total_Shop_Supplies__c'
                                                };
        return soHeaderFields;
    }
    
    /**
     * Name: getSOKitHeaderFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getSOKitHeaderFieldsList(){
        List<String> soKitHeaderFields = new List<String>{  'Id',
                                                            'Kit_Header__c',
                                                            'Is_Fixed_Kit_Header_SO__c',
                                                            'Kit_Header__r.Cause__c',
                                                            'Kit_Header__r.Concern__c',
                                                            'Kit_Header__r.Correction__c',
                                                            'Can_Split__c',
                                                            'Code__c',
                                                            'Service_Kit__c',
                                                            'Description__c',
                                                            'Fixed_Price__c',
                                                            'Fixed_Price_Flag__c',
                                                            'Kit_Unique_Name__c',
                                                            'Service_Order_Header__c',
                                                            'CreatedDate',
                                                            'Actual_Kit_Price__c',
                                                            'Tax_amount__c',
                                                            'Deal_Kit_Header__c',
                                                            'Kit_Header__r.Code__c',
                                                            'Kit_Header__r.Description__c',
                                                            'Deal__c'
                                                };
        return soKitHeaderFields;
    }
    
    /**
     * Name: getSOLineItemFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getSOLineItemFieldsList(){
        List<String> soLineItemFields = new List<String>{   'Id',
                                                            'Fixed_Price__c',
                                                            'Is_Fixed_Kit_LineItem_SO__c',
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
                                                            'Status__c',
                                                            'Cost__c',
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
                                                            'Is_Hidden__c',
                                                            'Sublet__c',
                                                            'Type__c',
                                                            'Labour_Code__r.Calculate_Supplies__c',
                                                            'Labour_Code__r.Supplies_Detail__c',
                                                            'Sublet__r.Cost_Method__c',
                                                            'Sublet__r.Cost__c',
                                                            'Vendor_Order_Header__r.Status__c',
                                                            'VO_Number__c'
                                                };
        return soLineItemFields;
    }
    
    /**
     * Name: getProviderFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getProviderFieldsList(){ 
        List<String> providerFields = new List<String>{ 'Id',
                                                        'Name__c',
                                                        'Phone__c',
                                                        'Email__c',
                                                        'Transaction_Type__c'
                                                };
        return providerFields;
    }
    
    public static List<String> individualTaxFieldsList(){
        List<String> individualTaxFields = new List<String>{'Id',
                                                            'Service_Order_Line_Item__c', 
                                                            'Tax_Rate__c',
                                                            'Form_Label__c',
                                                            'Sales_Tax_Item_Name__c',
                                                            'Taxable_Amount__c',
                                                            'Tax_Amount__c'
                                                    };
        return individualTaxFields;
    }
    
    /**
     * Name: getHoursLoggedFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
    public static List<String> getHoursLoggedFieldsList(){
        List<String> hoursLoggedFields = new List<String>{ 'Id',
                                                        'Notes__c',
                                                        'Original_Estimate__c',
                                                        'Previously_Logged__c',
                                                        'Remaining_Estimate__c',
                                                        'Remaining_Estimate_d__c',
                                                        'Remaining_Estimate_h__c',
                                                        'Remaining_Estimate_m__c',
                                                        'Service_Order_Header__c',
                                                        'Time_Spent__c',
                                                        'Time_Spent_d__c',
                                                        'Time_Spent_h__c',
                                                        'Time_Spent_m__c',
                                                        'Total_Hours__c',
                                                        'CreatedDate',
                                                        'Work_Performed_Date__c',
                                                        'Service_Order_Header__r.Status__c',
                                                        'Name',
                                                        'Notes_Required__c',
                                                        'Technician__c',
                                                        'Technician__r.Technician_Name__c',
                                                        'Technician__r.First_Name__c',
                                                        'Technician__r.Last_Name__c',
                                                        'Start_Date_Time__c',
                                                        'End_Date_Time__c',
                                                        'Is_Removed__c',
                                                        'Calculated_Hours__c '
                                                };
        return hoursLoggedFields;
    }
    
    /**
     * Name: getHoursLoggedFieldsList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
     public static List<String> getCustomerApprovalList(){
        List<String> customerApprovalFields = new List<String>{ 'Id', 
                                                        'Name',
                                                        'Notes__c',
                                                        'Section_key__c',
                                                        'Section_Name__c',
                                                        'Service_Order_Header__c',
                                                        'Status__c',
                                                        'ApprovalType__c',
                                                        'ApprovalDetailJson__c',
                                                        'LastModifiedDate',
                                                        'Approval_Count__c'
                                                };
        return customerApprovalFields;
    }
    
    
    /**
     * Name: getAttachmentList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
     public static List<String> getAttachmentList(){
        List<String> attachmentFields = new List<String>{ 'Id',
                                                        'Name',
                                                        'Description',
                                                        'CreatedDate'
                                                };
        return attachmentFields;
    }
    
    /**
     * Name: getCOInvoiceItemList
     * Desc: Method Which contains all the field list to be quried
     * @param:  
     * @return: List<String> - Fields List
    **/
     public static List<String> getCOInvoiceItemList(){
        List<String> coInvoiceItemList = new List<String>{ 'Id',
                                                        'Invoice_Header_Status__c'
                                                };
        return coInvoiceItemList;
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


    public static List<String> getSOPaymentRoleFieldsList(){
        List<String> soPaymentRoleFields = new List<String>{ 'Id',
                                                        'Total_Amount__c',
                                                        'Service_Order_Header__c',
                                                        'Status__c',
                                                        'Deductible_Status__c',
                                                        'Tax_Amount__c',
                                                        'Variance__c',
                                                        'RecordTypeId ',
                                                        'RecordType.DeveloperName',
                                                        'Service_Order_Header__r.CO_Header__c'
                                                };  
        return soPaymentRoleFields;
    }
    /**

    * Name: SOWrapper
    * Description: Apex class which contains all JSON related oprations of Service Order
    **/
    public class SOWrapper {
        public SOHeader SOHeaderInfo;
        public SOSignIn SOSignInRec;
        public SOReview SOReviewRec;
        public List<SOGrid> SOGridItems;
        public List<HoursLogged> HoursLoggedList;
        public List<CustomerApproval> CustomerApprovalList;
        public List<Attachments> AttachmentList;
        public Deductible DeductibleItem;
        
        /**
        * Name: SOWrapper
        * Desc: Constructor
        * @param:   (1)soRec -  Service_Order_Header__c - Service order header Record
                    (2)soKitHeaderList -List<Service_Order_Kit_Header__c> - List of Service Order kit                   
        * @return: 
        **/
        public SOWrapper(Service_Order_Header__c soRec, List<Service_Order_Kit_Header__c> soKitHeaderList) {
            this.SOHeaderInfo = new SOHeader(soRec);
            this.SOSignInRec = new SOSignIn(soRec);
            this.SOReviewRec = new SOReview(soRec);
            this.SOGridItems = new List<SOGrid>();
            this.HoursLoggedList = new List<HoursLogged>();
            this.CustomerApprovalList = new List<CustomerApproval>();
            this.AttachmentList = new List<Attachments>();
            this.DeductibleItem = new Deductible(soRec);
            if(soKitHeaderList == null) {
                soKitHeaderList = new List<Service_Order_Kit_Header__c>();
            }
            List<DateTime> sortedDateTimeList = new List<dateTime>();
            Set<Id> soliIdSet = new Set<Id>();
            for(Service_Order_Kit_Header__c soKHRec : soKitHeaderList) {
                sortedDateTimeList.add( soKHRec.CreatedDate );
                
                this.SOGridItems.add(new SOGrid(soKHRec, soKHRec.Service_Order_Line_Items__r, true));
                for(Service_Order_Line_Item__c soliRec : sokhRec.Service_Order_Line_Items__r) {
                    soliIdSet.add(soliRec.Id);
                } 
            }
            Integer lastIndexValue = 0;
            system.debug('Sorting Started OF SOLIs -->>');
            system.debug(sortedDateTimeList);
            for(Service_Order_Line_Item__c soliRec : soRec.Service_Order_Line_Items__r) {
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
                        this.SOGridItems.add(lastIndexValue, new SOGrid(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
                        
                        if(sortedDateTimeList.size() > lastIndexValue){
                            sortedDateTimeList.add(lastIndexValue, soliRec.CreatedDate);
                        } else {
                            sortedDateTimeList.add(soliRec.CreatedDate);
                        }
                        
                        lastIndexValue++;
                    } else {
                        this.SOGridItems.add(new SOGrid(new Service_Order_Kit_Header__c(), new List<Service_Order_Line_Item__c>{soliRec}, false));
                        lastIndexValue++;
                    }
                }
            }
            
            
            for(Hours_Logged__c hoursLogged : soRec.Hours_Logged__r) {
                this.HoursLoggedList.add(new HoursLogged(hoursLogged));
            }
            for(CustomerApproval__c approvalRec : soRec.CustomerApprovals__r) {
                if(approvalRec.ApprovalType__c != 'Submit_Claim') {
                    this.CustomerApprovalList.add(new CustomerApproval(approvalRec));
                }
            }
            for(Attachment attchmentRec : soRec.Attachments) {
                this.AttachmentList.add(new Attachments(attchmentRec));
            }
        }
    }
    
    /**

    * Name: SOHeader
    * Description: Apex class which contains all JSON related oprations of Service Order
    **/
    public class SOHeader {
        public String Id;
        public String Name;
        public Decimal Total;
        public List<String> ManualConcern;
        public List<String> ManualCorrection; 
        public List<String> ManualCause;
        public List<String> KitHeaderCause;
        public List<String> KitHeaderConcern;
        public List<String> KitHeaderCorrection;
        public String PromisedBy;
        public String IsPromisedByAmPm;
        public Decimal EstimatedHours;
        public String TransactionTypeId;
        public String TransactionType;
        public String TransactionTypeLabel;
        public String COUId;
        public String VIN;
        public String UnitType;
        public String UnitId;
        public String StockId;
        public String Year;
        public String MakeName;
        public String ModelName;
        public String SubModelName;
        public String Color;
        public String Status;
        public String ProviderId;
        public String CategoryId;
        public String CategoryName;
        public String Stock;
        public String UnitStatus;
        public String StatusColor;
        public Boolean IsCompletedLinkShown;
        public String WorkStatus;
        public List<AvailableStatus> AvailableWorkStatusList;
        public String ClaimStatus;
        public List<AvailableStatus> AvailableClaimStatusList;
        public String InvoiceStatus;
        public String DealId;
        public String DealItemId;
        public String ScheduledDate;
        
        /**
        * Name: SOHeader
        * Desc: Constructor
        * @param:   (1)soHeaderRec -  Service_Order_Header__c - Service order header Record
        * @return: 
        **/     
        public SOHeader(Service_Order_Header__c soHeaderRec) {
            this.Id = soHeaderRec.Id;
            this.Name = soHeaderRec.Name__c;
            this.Total = 0;
            this.ManualConcern = (soHeaderRec.SO_Concern__c != null) ? soHeaderRec.SO_Concern__c.split('\n') : new List<String>();
            this.ManualCorrection = (soHeaderRec.SO_Correction__c != null) ? soHeaderRec.SO_Correction__c.split('\n') : new List<String>();
            this.ManualCause = (soHeaderRec.SO_Cause__c != null) ? soHeaderRec.SO_Cause__c.split('\n') : new List<String>();
            if(soHeaderRec.Customer_Owned_Unit__c != null) {
                this.COUId = soHeaderRec.Customer_Owned_Unit__c;
                this.VIN = soHeaderRec.Customer_Owned_Unit__r.VIN_Number__c;
                this.UnitType = soHeaderRec.Customer_Owned_Unit__r.Unit_Type__c;
                this.UnitId = soHeaderRec.Customer_Owned_Unit__r.Unit_Id__c;
                this.StockId = soHeaderRec.Customer_Owned_Unit__r.Stock_Id__c;
                if(soHeaderRec.Customer_Owned_Unit__r.Unit_Model__c !=null ){
                    this.ModelName = soHeaderRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c;
                }
                if(soHeaderRec.Customer_Owned_Unit__r.Sub_Model__c !=null ){
                    this.SubModelName = soHeaderRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c;
                }
                if(soHeaderRec.Customer_Owned_Unit__r.Unit_Make__c !=null ){
                    this.MakeName = soHeaderRec.Customer_Owned_Unit__r.Unit_Make__r.Name;
                }
                this.Color = soHeaderRec.Customer_Owned_Unit__r.Colour__c;
                this.UnitStatus = soHeaderRec.Customer_Owned_Unit__r.Status__c;
                
            }
            this.ProviderId = soHeaderRec.Provider__c;
            if(soHeaderRec.Category__c != null) {
                this.CategoryName = soHeaderRec.Category__r.Name;
                this.CategoryId = soHeaderRec.Category__c;
            } 
            this.KitHeaderCause = new List<String>();
            this.KitHeaderConcern = new List<String>();
            this.KitHeaderCorrection = new List<String>();
            
            if(soHeaderRec.Service_Order_Kit_Headers__r.size() > 0) {
                for(Service_Order_Kit_Header__c soKitHeaderRec : soHeaderRec.Service_Order_Kit_Headers__r) {
                    if(soKitHeaderRec.Kit_Header__c != null) {
                        this.KitHeaderCause.addAll((soKitHeaderRec.Kit_Header__r.Cause__c != null) ? soKitHeaderRec.Kit_Header__r.Cause__c.split('\n') : new List<String>());
                    }
                    if(soKitHeaderRec.Kit_Header__c != null) {
                        this.KitHeaderConcern.addAll((soKitHeaderRec.Kit_Header__r.Concern__c != null) ? soKitHeaderRec.Kit_Header__r.Concern__c.split('\n') : new List<String>());
                    }
                    if(soKitHeaderRec.Kit_Header__c != null) {
                        this.KitHeaderCorrection.addAll((soKitHeaderRec.Kit_Header__r.Correction__c != null) ? soKitHeaderRec.Kit_Header__r.Correction__c.split('\n') : new List<String>());
                    }
                }
            }
            this.EstimatedHours = ((soHeaderRec.Estimated_Hours__c == null) ? 0 : soHeaderRec.Estimated_Hours__c).setScale(1);
            this.Stock = 'No outstanding items';
            this.TransactionType = soHeaderRec.Transaction_Type__r.Type__c;
            this.TransactionTypeLabel = soHeaderRec.Transaction_Type__r.Code_Label__c;
            this.TransactionTypeId = soHeaderRec.Transaction_Type__c;
            this.PromisedBy = (soHeaderRec.Promised_By__c != null) ? soHeaderRec.Promised_By__c.format('MM/dd/yyyy hh:mm a') : null; 
            if(soHeaderRec.Scheduled_Date__c != null){
                this.ScheduledDate = (datetime.newInstance(soHeaderRec.Scheduled_Date__c.year(), soHeaderRec.Scheduled_Date__c.month(),soHeaderRec.Scheduled_Date__c.day())).format('MM/dd/YYYY');
            }
            this.IsPromisedByAmPm = soHeaderRec.IsPromisedBy_AmPm__c;
            this.Status = soHeaderRec.Status__c;
            this.IsCompletedLinkShown = true;
            List<Service_Order_Line_Item__c> soliList = soHeaderRec.Service_Order_Line_Items__r;
            for (Service_Order_Line_Item__c soli : soliList) {
                /*if (soli.Total__c != null) {
                    if (soli.Tax_Percent__c == null) {
                        soli.Tax_Percent__c = 0;
                    }
                    this.Total += (soli.Total__c != null) ? soli.Total__c : 0;
                    //START : Comented and added by nidhi - 10-11-2016
                    if(String.isBlank(soHeaderRec.Deal__c)) {
                        this.Total += ((soli.Total__c * soli.Tax_Percent__c) / 100).setScale(2, RoundingMode.HALF_UP);
                    }
                    //END : Comented and added by nidhi - 10-11-2016
                }*/
                if(soli.Qty_To_Order__c > 0) {
                    this.IsCompletedLinkShown = false;
                }
            }
            this.Total = (soHeaderRec.Total__c != null) ? soHeaderRec.Total__c.setScale(2, RoundingMode.HALF_UP) : 0;
            this.WorkStatus = soHeaderRec.Work_Status__c;
            if(this.WorkStatus != null && Constants.workStatusToAvailableStatusMap.containsKey(this.WorkStatus)) {
                this.AvailableWorkStatusList = new List<AvailableStatus>();
                for(String status : Constants.workStatusToAvailableStatusMap.get(this.WorkStatus)) {
                    this.AvailableWorkStatusList.add(new AvailableStatus(status));
                }
            } else {
                this.AvailableWorkStatusList = new List<AvailableStatus>();
            }
            
            this.ClaimStatus = soHeaderRec.Claim_Status__c;
            if(this.ClaimStatus != null && Constants.claimStatusToAvailableStatusMap.containsKey(this.ClaimStatus)) {
                this.AvailableClaimStatusList = new List<AvailableStatus>();
                for(String status : Constants.claimStatusToAvailableStatusMap.get(this.ClaimStatus)) {
                    this.AvailableClaimStatusList.add(new AvailableStatus(status));
                }
            } else {
                this.AvailableClaimStatusList = new List<AvailableStatus>();
            }
            
            // Invoice Status based on CO Invoice Item of SOHeader
            if(soHeaderRec.CO_Invoice_Items__r.size() > 0) {
                this.InvoiceStatus = soHeaderRec.CO_Invoice_Items__r[0].Invoice_Header_Status__c;
            }
            
            if(this.UnitType == 'STOCK') {
                if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Available') {
                    this.StatusColor = 'Green';
                } else if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Reserved' || soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Sold'){
                    this.StatusColor = 'Red';
                } else if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Traded' || soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Delivered'){
                    this.StatusColor = 'Black';
                }
            
            } else if(this.UnitType == 'COU') {
                if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Active') {
                    this.StatusColor = 'Green';
                } else if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Inactive'){
                    this.StatusColor = 'Red';
                } else if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Transferred'){
                    this.StatusColor = 'Black';
                }
            
            } else if(this.UnitType == 'ORDU') {
                if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'On Order') {
                    this.StatusColor = 'Red';
                } else if(soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Cancelled' || soHeaderRec.Customer_Owned_Unit__r.Status__c == 'Traded'){
                    this.StatusColor = 'Black';
                }
            }
            
            this.DealId = soHeaderRec.Deal__c;
            this.DealItemId = soHeaderRec.Deal_Item__c;
        }
    }
    
    public class AvailableStatus {
        public String AvailableStatus;
        public String StatusUniqueKey;
        
        public AvailableStatus(String status) {
            this.AvailableStatus = status;
            this.StatusUniqueKey = (status != null) ? status.replaceAll(' ', '_') : null;
        }
    }

    /**
    * Name: SOSignIn
    * Description: Apex class service order sign in 
    **/
    public class SOSignIn {
        public String Id;
        public Decimal Odometer;
        
        /**
        * Desc: Constructor
        **/ 
        public SOSignIn(Service_Order_Header__c soHeaderRec) {
            this.Id = soHeaderRec.Id;
            this.Odometer = (soHeaderRec.Odometer_on_Arrival__c == null) ? 0 : soHeaderRec.Odometer_on_Arrival__c;
        }   
    }
    
    /**
    * Name: SOReview
    * Description: Apex class service order review
    **/
    public class SOReview {
        
        public Decimal OdometerOnDeparture;
        public String Id;
        public List<String> KitHeaderNotes;
        public List<String> ManualNotes;
        
        /**
        * Name: SOReview
        * Desc: Constructor
        * @param:   (1)soHeaderRec -  Service_Order_Header__c - Service order header Record
        * @return: 
        **/ 
        public SOReview(Service_Order_Header__c soHeaderRec) {
            this.KitHeaderNotes = new List<String>();
            this.ManualNotes = new List<String>();
            this.Id = soHeaderRec.Id;
            this.OdometerOnDeparture = (soHeaderRec.Odometer_on_Departure__c == null) ? 0 : soHeaderRec.Odometer_on_Departure__c;
            
            if(soHeaderRec.Service_Order_Kit_Headers__r.size() > 0) {
                for(Service_Order_Kit_Header__c soKitHeaderRec : soHeaderRec.Service_Order_Kit_Headers__r) {
                    if(soKitHeaderRec.Kit_Header__c != null) {
                        this.KitHeaderNotes.addAll((soKitHeaderRec.Kit_Header__r.Correction__c != null) ? soKitHeaderRec.Kit_Header__r.Correction__c.split('\n') : new List<String>());
                    }
                }
            }
            this.ManualNotes = (soHeaderRec.SO_Notes_For_Customer__c != null) ? soHeaderRec.SO_Notes_For_Customer__c.split('\n') : new List<String>();
        }
    }
    
    /**
    * Name: SOGrid
    * Description: Apex class Service Order Grid
    **/
    public class SOGrid {
        
        public SOKitHeader SOKH {get; set;}
        
        /**
        * Name: SOGrid
        * Desc: Constructor
        * @param:   (1)soKitHeaderRec -  Service_Order_Kit_Header__c - Service order Kit Header Record
                    (2)soliList -List<Service_Order_Kit_Header__c> - List of Service Order Kit Header
                    (3)hasChildren - Boolean  - has Children or not             
        * @return: 
        **/
        public SOGrid(Service_Order_Kit_Header__c soKitHeaderRec, List<Service_Order_Line_Item__c> soliList, Boolean hasChildren) {
            this.SOKH = new SOKitHeader(soKitHeaderRec, soliList, hasChildren);
        }
    }
    
    /**
    * Name: SOKitHeader
    * Description: Apex class Service Order Kit Header
    **/
    public class SOKitHeader {
        
        public List<SOLineItem> SOLIList {get; set;}
        public String ItemDescription {get; set;}
        public Boolean CanItSplit;
        public String Code;
        public Boolean IsServiceKit;
        public String Id {get; set;}
        public Decimal FixedPrice;
        public Decimal RetailPrice;
        public Boolean IsFixedPrice; 
        public Boolean hasChildren;
        public Boolean isFixedKitHeaderSO;
        public Decimal taxAmount;
        public Decimal Price {get; set;} // Added by richa 14 april
        /**
        * Name: SOKitHeader
        * Desc: Constructor
        * @param:   (1)soKitHeaderRec -  Service_Order_Kit_Header__c - Service order Kit Header Record
                    (2)soliList -List<Service_Order_Line_Item__c>- List of Service Order Line Items
                    (3)hasChildren - Boolean  - has Children or not             
        * @return: 
        **/
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
            this.Price = 0; // Added by richa 14 april
            Decimal soliKitPrice = 0; // Added by richa 14 april
            for(Service_Order_Line_Item__c soliRec : soliList) {
                if(soliRec.Type__c == Constants.SHOP_SUPPLY) {
                    continue;
                }
                this.SOLIList.add(new SOLineItem(soliRec));
                // Start: Added by richa 14 april
                Decimal soliTax = (soliRec.Tax_Percent__c != null) ? soliRec.Tax_Percent__c : 0;
                if(hasChildren) {
                    if(isTaxIncludingPricing && String.isBlank(soliRec.Deal__c)) {
                        if(soliTax == null) {
                            soliTax = 0;
                        }
                        if(soliRec.Kit_Price__c == null) {
                            soliRec.Kit_Price__c = 0;
                        }
                        //soliKitPrice = (soliRec.Kit_Price__c * (1 + (soliTax / 100))).setScale(2, RoundingMode.HALF_UP);
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
                // End: Added by richa 14 april
            }
            this.hasChildren = hasChildren;
            
        }
    }
    
    /**
    * Name: SOLineItem
    * Description: Apex class Service Order Line Item
    **/
    public class SOLineItem {
        
        public String ItemDesc {get; set;}
        
        /* START: Added By Tarun - #170 - 09/23/2016 */
        public String ItemCode;
        public String ItemDescription {get; set;}
        
        public String Status{get; set;}
        public Decimal QtyNeeded {get; set;}
        public Decimal StockCommited;
        public Decimal StockCommitedCpy; // To reset values on UI - related to user permissions - oversell inventory
        public Decimal QtyOrder;
        public Decimal ReatilPrice;
        public Decimal SubTotal;
        public Boolean IsFixedPrice;
        public Decimal AvailablePart;
        public Decimal OversoldQty;
        public Decimal ActualAvailableParts;
        public String PartId;
        public Boolean IsPart {get; set;}
        public Boolean IsLabour {get; set;}
        public Boolean IsFee {get; set;}
        public String Id {get; set;}
        public String SOKitHeaderId;
        public Decimal KitPrice {get; set;}
        public String VendorId;
        public String CoLineItem;
        public Boolean isFixedKitHeaderLineItemSO;
        public Decimal Tax;
        public String DealId;
        public String DealItemId;
        public String OptionAndFeeItemId;
        public Boolean IsNonInventoryPart{get; set;}
        public String POStatus {get; set;}
        public String VONumber {get; set;}
        public Boolean IsEnvFee;
        public Boolean IsHidden;
        public Boolean IsSublet{get; set;}
        public Decimal Cost;
        public Boolean IsVariance;
        public Boolean IsBRPPart;
        
        /**
        * Name: SOLineItem
        * Desc: Constructor
        * @param:   (1)soLineItemRec - Service_Order_Line_Item__c - Service Order Line Item Record
        * @return: 
        **/
        public SOLineItem(Service_Order_Line_Item__c soLineItemRec) {
            this.Id = soLineItemRec.Id; 
            this.VendorId=soLineItemRec.Part__r.Vendor__c;
            
            /* START: Added By Tarun - #170 - 09/23/2016 */
            this.ItemCode = (soLineItemRec.Item_Code__c != null) ? soLineItemRec.Item_Code__c : '';
            this.ItemDescription = (soLineItemRec.Item_Description__c != null) ? soLineItemRec.Item_Description__c : '';
            this.ItemDesc = this.ItemCode + ' - ' + this.ItemDescription;
             
            //this.ItemDesc = soLineItemRec.Item_Desc__c;
            this.isFixedKitHeaderLineItemSO = soLineItemRec.Is_Fixed_Kit_LineItem_SO__c;
            this.QtyNeeded = (soLineItemRec.Qty_Needed__c != null ) ? soLineItemRec.Qty_Needed__c : 0;
            this.StockCommited = (soLineItemRec.Qty_Committed__c != null) ? soLineItemRec.Qty_Committed__c : 0;
            this.IsPart = (soLineItemRec.Part__c != null) ? true : false;
            this.IsLabour = (soLineItemRec.Labour_Code__c != null) ? true : false;
            this.IsFee = (soLineItemRec.Fee__c != null) ? true : false;
            this.IsSublet = (soLineItemRec.Sublet__c != null) ? true : false;

            if (this.IsLabour || this.IsFee) {
                this.StockCommited = this.QtyNeeded;
            }
            if(soLineItemRec.Sublet__c != null) {
	        	this.Status = soLineItemRec.Status__c;
	        	if(soLineItemRec.Cost__c == null) {
	        		this.Cost = 0;
	        		if(soLineItemRec.Sublet__r.Cost_Method__c == 'Fixed Cost' && soLineItemRec.Sublet__r.Cost__c != null && soLineItemRec.Qty_Needed__c !=null){
                    	this.Cost += (soLineItemRec.Sublet__r.Cost__c);
	                } else if(soLineItemRec.Sublet__r.Cost_Method__c == 'Percent Retail' && soLineItemRec.Sublet__r.Cost__c !=null && soLineItemRec.Qty_Needed__c !=null ){
	                    this.Cost += (((soLineItemRec.Kit_Price__c *  soLineItemRec.Sublet__r.Cost__c)/100));
	                }
	        	} else {
	        		this.Cost = soLineItemRec.Cost__c;
	        	}
	        } else if(soLineItemRec.CO_Line_Item__r.Closed_CO_Invoice_link__c != null) {
                this.Status = 'Invoiced'; 
            } else {
                if((this.QtyNeeded == this.StockCommited) || soLineItemRec.Part__r.Non_Inventory_Part__c) {
                    this.Status = 'In Stock';
                } else if(this.QtyNeeded > this.StockCommited) {
                    if(soLineItemRec.CO_Line_Item__r.CO_Status__c == Constants.CO_STATUS_QUOTE) {
                        if(soLineItemRec.Part__r.AvailableParts__c >= this.QtyNeeded) {
                            this.Status = 'In Stock'; 
                        } else {
                            this.Status = 'Required'; 
                        }
                    } else {
                        if(soLineItemRec.CO_Line_Item__c != null && soLineItemRec.CO_Line_Item__r.Status__c != null) {
                            this.Status = soLineItemRec.CO_Line_Item__r.Status__c;
                        } else if(soLineItemRec.CO_Line_Item__c != null && !soLineItemRec.CO_Line_Item__r.Special_Order__c) {
                            this.Status = 'Required';
                        } else {
                            this.Status = 'Ordered';
                        }
                    }
                } else if(soLineItemRec.Qty_Needed__c < 0) {
                    this.Status = 'RETURN';
                }
            }
            
            if(soLineItemRec.CO_Line_Item__c != null && soLineItemRec.CO_Line_Item__r.Closed_CO_Invoice_link__c == null 
                        && soLineItemRec.CO_Line_Item__r.Oversold_Qty__c > 0) {
                this.Status = 'Oversold';
            }
            this.QtyOrder = (this.StockCommited != null && this.QtyNeeded != null) ? (this.QtyNeeded - this.StockCommited) : 0;
            
            if(soLineItemRec.Qty_Needed__c < 0) {
                this.QtyOrder = null;
                this.StockCommited = null;
            }
            
            this.StockCommitedCpy = this.StockCommited;
            this.Tax = (soLineItemRec.Tax_Percent__c != null) ? soLineItemRec.Tax_Percent__c : 0;
            
            Boolean isTaxIncludingPricing = GeneralConfiguration.getTaxIncludingPricing();
            
            if(isTaxIncludingPricing && String.isBlank(soLineItemRec.Deal__c)) {
                if(this.Tax == null) {
                    this.Tax = 0;
                }
                if(soLineItemRec.Price_When_Tax_Included__c == null) {
                    soLineItemRec.Price_When_Tax_Included__c = (soLineItemRec.Kit_Price__c * (1 + (this.Tax / 100))).setScale(2, RoundingMode.HALF_UP);
                }
                this.KitPrice = soLineItemRec.Price_When_Tax_Included__c;
            } else {
                this.KitPrice = (soLineItemRec.Kit_Price__c != null) ? soLineItemRec.Kit_Price__c.SetScale(2, RoundingMode.HALF_UP) : soLineItemRec.Kit_Price__c;
            }
            this.ReatilPrice = (soLineItemRec.Retail_Price__c != null) ? soLineItemRec.Retail_Price__c.SetScale(2, RoundingMode.HALF_UP) : soLineItemRec.Retail_Price__c;
            this.IsFixedPrice = soLineItemRec.Fixed_Price__c;
            this.PartId = soLineItemRec.Part__c;
            if(soLineItemRec.Part__c != null) {
                this.IsNonInventoryPart = soLineItemRec.Part__r.Non_Inventory_Part__c;
            }
            this.AvailablePart = (soLineItemRec.Part__c != null) ? (soLineItemRec.Part__r.AvailableParts__c) : null;
            this.OversoldQty = (soLineItemRec.CO_Line_Item__c != null) ? (soLineItemRec.CO_Line_Item__r.Oversold_Qty__c) : null;
            this.IsPart = (soLineItemRec.Part__c != null) ? true : false;
            this.IsLabour = (soLineItemRec.Labour_Code__c != null) ? true : false;
            this.IsFee = (soLineItemRec.Fee__c != null) ? true : false;
            this.SOKitHeaderId = soLineItemRec.Service_Order_Kit_Header__c;
            this.CoLineItem = (soLineItemRec.CO_Line_Item__c !=null) ? (soLineItemRec.CO_Line_Item__c ) : null;
            this.DealId = soLineItemRec.Deal__c;
            this.DealItemId = soLineItemRec.Deal_Item__c;
            this.OptionAndFeeItemId = soLineItemRec.Option_Fee__c;
            this.POStatus = (soLineItemRec.Part__c != null) ? soLineItemRec.CO_Line_Item__r.Vendor_Order_Header__r.Status__c : 
            				(soLineItemRec.Sublet__c != null ? soLineItemRec.Vendor_Order_Header__r.Status__c : '');
            this.VONumber = (soLineItemRec.Part__c != null) ? soLineItemRec.CO_Line_Item__r.VO_Number__c : (soLineItemRec.Sublet__c != null ? soLineItemRec.VO_Number__c : '');
            this.IsEnvFee = soLineItemRec.Is_Environmental_Fee__c;
            this.IsHidden = soLineItemRec.Is_Hidden__c;
            
            if(this.IsPart && (this.IsNonInventoryPart == null || this.IsNonInventoryPart == false)) {
                this.ActualAvailableParts = ((this.AvailablePart != null ? this.AvailablePart : 0) + (this.StockCommited != null ? this.StockCommited : 0) - (this.OversoldQty != null ? this.OversoldQty : 0));
            }
        	this.IsBRPPart = soLineItemRec.Part__r != null ? BRPUtility.getAllBRPVendorsIdSet().contains(soLineItemRec.Part__r.Vendor__c): false;
        }
    }
    
    /**
    * Name: HoursLogged
    * Description: Apex class Hours Logged
    **/
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
    
    
    public class Attachments {
        public String UploadedDate;
        public String AttachmentName;
        public String AttachmentId;
        public String Source;
        
        public Attachments(Attachment attachmentRec) {
            this.UploadedDate = attachmentRec.CreatedDate.format('MM/dd/YYYY');
            this.AttachmentName = attachmentRec.Name;
            this.AttachmentId = attachmentRec.Id;
            this.Source = attachmentRec.Description;
        }
    }
    
    /**
    * Name: SOMasterData
    * Description: Apex class Service Order Master Data
    **/
    public class SOMasterData {
        public List<SOHeaderWrapper.TTType> TTList;
        public List<CustomerOwnedUnit> COUList;
        public List<SOHeaderWrapper.VendorAsProvider> ProviderList;
        public String DefaultInternalCategoryName;
        public String DefaultInternalCategoryId;
            
        /**
        * Name: SOMasterData
        * Desc: Constructor
        * @param:   (1)ttRecList - List<Transaction_Type__c> - Transaction Type List
        *           (2)couList - List<Customer_Owned_Unit__c> - Customer Owned Unit Record
        * @return:  
        **/
        public SOMasterData(List<Transaction_Type__c> ttRecList, List<Customer_Owned_Unit__c> couList, List<Account> providerList, List<Category__c> internalDefaultCategoryList) {
            this.TTList = new List<SOHeaderWrapper.TTType>();
            this.COUList = new List<CustomerOwnedUnit>();
            this.ProviderList = new List<SOHeaderWrapper.VendorAsProvider>();
            for(Transaction_Type__c ttRec : ttRecList) {
                this.ttList.add(new SOHeaderWrapper.TTType(ttRec));
            }
            for(Customer_Owned_Unit__c couRec : couList) { 
                this.COUList.add(new CustomerOwnedUnit(couRec));
            }
            for(Account providerRec : providerList) {
                this.ProviderList.add(new SOHeaderWrapper.VendorAsProvider(providerRec));
            }
            if(internalDefaultCategoryList.size() > 0) {
                DefaultInternalCategoryName = internalDefaultCategoryList[0].Name;
                DefaultInternalCategoryId = internalDefaultCategoryList[0].Id;
            }
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
        }   
    }
    
    /**
    * Name: TTType
    * Description: Apex class Transation Type
    **/
    public class VendorAsProvider {
        public String Id;
        public String Name;
        public String Email;
        public String Phone;
        public String AccountNumber;
        
        /**
        * Name: TTType
        * Desc: Constructor
        * @param:   (1)ttRec - Transaction_Type__c - Transaction Type Record
        * @return:  
        **/
        public VendorAsProvider(Account vendorRec) {
            this.Id = vendorRec.Id;
            this.Name = vendorRec.Name;
            this.Email = (vendorRec.Preferred_Email__c != null) ? vendorRec.Preferred_Email__c : vendorRec.Work_Email__c;
            this.Phone = (vendorRec.Preferred_Phone__c != null) ? vendorRec.Preferred_Phone__c : vendorRec.Work_Number__c;
            this.AccountNumber = (vendorRec.AccountNumber != null) ? vendorRec.AccountNumber : vendorRec.AccountNumber;
        }   
    }
    
    /**
    * Name: Provider
    * Description: Apex class about Provider
    **/
    public class Provider {
        public String ProviderName;
        public String ProviderEmail;
        public String Id;
        public String ProviderPhone;
        
        /**
        * Name: Provider
        * Desc: Constructor
        * @param:   (1)providerRec - Provider__c - Provider Record 
        * @return:  
        **/
        public Provider(Provider__c providerRec) {
            this.ProviderName = providerRec.Name__c;
            this.ProviderEmail = providerRec.Email__c;
            this.ProviderPhone = providerRec.Phone__c;
            this.Id = providerRec.Id;
        }
    }
    
    public class SpecialOrder {
        public String Id;
        public String PartId;
        public String COLineItemId;
        public String Item;
        public Decimal QtyNeeded;
        public String Status;
        public String PONumber;
        public String POStatus;
        public String ExpectedDelivery;
        public String ETA;
        public String VendorId;

        
        public SpecialOrder(Vendor_Order_Line_Item__c VendorOrderLineItemRec) {
            this.Id = VendorOrderLineItemRec.Id;
            this.PartId = VendorOrderLineItemRec.Part__c;
            this.COLineItemId = VendorOrderLineItemRec.CO_Line_Item__c;
            this.Item = VendorOrderLineItemRec.Part__r.Part_Number__c + ' - ' + VendorOrderLineItemRec.Part__r.Description__c;
            this.QtyNeeded = VendorOrderLineItemRec.Qty_Needed__c;
            if(VendorOrderLineItemRec.Status__c == null){
                this.Status = (VendorOrderLineItemRec.Vendor_Order_Line_Item_Group__c != null) ? 'Ordered':'Required' ; 
            }else{
                this.Status = VendorOrderLineItemRec.Status__c; 
            }
            this.PONumber = VendorOrderLineItemRec.Vendor_Order_Header__r.Name;
            this.POStatus = VendorOrderLineItemRec.Vendor_Order_Header__r.Status__c;
            this.ExpectedDelivery = (VendorOrderLineItemRec.CO_Line_Item__r.Expected_Delivery_Date__c != null) ? 
                                            DateTime.newInstance(VendorOrderLineItemRec.CO_Line_Item__r.Expected_Delivery_Date__c.year(), VendorOrderLineItemRec.CO_Line_Item__r.Expected_Delivery_Date__c.month(), VendorOrderLineItemRec.CO_Line_Item__r.Expected_Delivery_Date__c.day()).format('MM/dd/yyyy') 
                                            : null;
            this.ETA = null;
            this.VendorId = (VendorOrderLineItemRec.Part__c != null) ? VendorOrderLineItemRec.Part__r.Vendor__c : null;
        }
    }
    
    public class Deductible{
        public Decimal DeductibleAmount;
        public String DeductibleStatus;
        public String DeductibleId;
        public String SoHeaderId;
        public String CoHeaderId;

        public Deductible(Service_Order_Header__c soHeaderRec ){
            this.DeductibleAmount = 0;
            for(SO_Payment_Role__c soPaymentRoleObj : soHeaderRec.SO_Payment_Roles__r ){
                if(soPaymentRoleObj.RecordType.DeveloperName == 'Deductible'){
                    this.DeductibleAmount = soPaymentRoleObj.Total_Amount__c != null ? soPaymentRoleObj.Total_Amount__c : 0;
                    this.DeductibleStatus = soPaymentRoleObj.Deductible_Status__c;
                    this.DeductibleId = soPaymentRoleObj.Id;
                    this.SoHeaderId = soPaymentRoleObj.Service_Order_Header__c;
                    this.CoHeaderId = soPaymentRoleObj.Service_Order_Header__r.CO_Header__c;
                }
            }
         }
    }
    
    public class TechnicianWrapper{
        public String Id;
        public String FirstName;
        public String LastName;
        public String TechinicianName;

        public TechnicianWrapper(Technician__c technicianRec){
            this.Id = technicianRec.Id;
            this.FirstName = technicianRec.First_Name__c;
            this.LastName = technicianRec.Last_Name__c;
            this.TechinicianName = technicianRec.Technician_Name__c;
        }
    }
    
    public static List<String> getTechnicianFieldsList(){
        return new List<String>{ 'Id',
                                'First_Name__c',
                                'Last_Name__c',
                                'Type__c',
                                'Role__c',
                                'Working_Days__c',
                                'Technician_Name__c',
                                'CreatedDate',
                                'LastModifiedDate',
                                'User__c'
                            };
    }
}