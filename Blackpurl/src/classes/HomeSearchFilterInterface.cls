/**
 * Author: 
 * Since: 
 * Name: HomeSearchFilterInterface
 * Description: Home Search Filter Apex Class
**/
public with sharing class HomeSearchFilterInterface {
    private static String objectName;
    private static Set<String> ACTIVE_SERVICE_JOB_STATUS_SET = new Set<String> {'Ready', 'In Progress', 'On Hold'};
     /**
     * Name: getFilterList
     * Desc: Getting Filter List 
     * @param:  (1) homeSerachFilterObj - HomeSearchFilterWrapper - Home Search Filter Wrapper Record
     * @return: Map<String, List<FieldFilter>>
    **/
    public static Map<String, List<FieldFilter>> getFilterList(HomeSearchFilterWrapper homeSerachFilterObj) {
        Map<String, List<FieldFilter>> objectFilterJSON = new Map<String, List<FieldFilter>>();
        
        System.debug('@#@#@#@homeSerachFilterObj.Type.Objects BEOFER:  ' + homeSerachFilterObj.Type.Objects);
        // If nothing selected in object, then add 'Any' generic search
        if(homeSerachFilterObj.Type.Objects == null || homeSerachFilterObj.Type.Objects.size() == 0) {
            homeSerachFilterObj.Type.Objects = new Set<String>{Label.Generic_Object_Label};
        }
        
        System.debug('@#@#@#@homeSerachFilterObj.Type.Objects MID:  ' + homeSerachFilterObj.Type.Objects);
        // If Customer and Vendor both are added in list, then combine them to 'People'
        // method Should be generari using looping
        boolean isAddedPeople = false;
        if(homeSerachFilterObj.Type.Objects.contains('Customers') && homeSerachFilterObj.Type.Objects.contains('Vendors')) {
            isAddedPeople = true;
            homeSerachFilterObj.Type.Objects.remove('Customers');  
            homeSerachFilterObj.Type.Objects.remove('Vendors');
        }
        if(isAddedPeople) {
            Set<String> objectsSet = new Set<String>(homeSerachFilterObj.Type.Objects);
            objectsSet.add('People');
            homeSerachFilterObj.Type.Objects = new Set<String>(objectsSet);
        }
        System.debug('@#@#@#@homeSerachFilterObj.Type.Objects AFTER:  ' + homeSerachFilterObj.Type.Objects);
        
        Set<String> objectSet = new Set<String>();
        if(homeSerachFilterObj.Type.Objects.size() == 0 || (homeSerachFilterObj.Type.Objects.size() == 1 && homeSerachFilterObj.Type.Objects.contains(Label.Generic_Object_Label))) {
            objectSet = HomeSearchUtil.displayObjectNameToTypeNumber.keySet();
        } else {
            objectSet = homeSerachFilterObj.Type.Objects;
        }
        
        Set<String> objectNameSet = new Set<String>();
        for(String objName : objectSet) {
            objectNameSet.add(objName);
        }
        
        if(objectSet.contains('Customer Payments')) {
            objectNameSet.add('Customer Deposits');
        }
        if(objectSet.contains('Vendor Orders')) {
            objectNameSet.add('Vendor Return');
        }
        if(objectSet.contains('Invoiced Items')) {
            objectNameSet.add('SOLI');
            objectNameSet.add('Option and Fee');
        }
        if(objectSet.contains('Part FIFO')) {
            objectNameSet.add('Part FIFO Line Item');
        }
        if(objectSet.contains('Tax Detail')) {
            if(homeSerachFilterObj.Tax_Detail_Invoice_Type == '0') {
                objectNameSet.add('Tax Detail Customer Invoices');
                objectNameSet.add('Tax Detail Vendor Invoices');
            } else if(homeSerachFilterObj.Tax_Detail_Invoice_Type == 'Customer Invoice') {
                objectNameSet.add('Tax Detail Customer Invoices');
            } else if(homeSerachFilterObj.Tax_Detail_Invoice_Type == 'Vendor Invoice') {
                objectNameSet.add('Tax Detail Vendor Invoices');
            }
        }
        
        for(String objName : objectNameSet) {
            List<FieldFilter> filterJSON = new List<FieldFilter>();
            
            //For People Vendor and Cutomers
            if(objName == 'People' || objName == 'Customers'  || objName == 'Vendors'){
                if(objName == 'Customers') {
                    filterJSON.add(new FieldFilter('Is_Customer__c', '=', 'true'));
                } else if(objName == 'Vendors') {
                    filterJSON.add(new FieldFilter('Is_Vendor__c', '=', 'true'));
                } else if(objName == 'People') {
                    filterJSON.add(new FieldFilter('', '=', '(Is_Customer__c = true OR Is_Vendor__c = true)'));
                }
                
                if(!String.isBlank(homeSerachFilterObj.People_BillingAddress)) {
                    filterJSON.add(new FieldFilter('BillingStreet', 'Like','\'%' + homeSerachFilterObj.People_BillingAddress + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.People_BillingCity)){
                    filterJSON.add(new FieldFilter('BillingCity', 'Like','\'%' + homeSerachFilterObj.People_BillingCity + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.People_Country)){
                    filterJSON.add(new FieldFilter('BillingCountry', 'Like','\'%' + homeSerachFilterObj.People_Country + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.People_StateProv)){
                    filterJSON.add(new FieldFilter('BillingState', 'Like','\'%' + homeSerachFilterObj.People_StateProv + '%\''));
                }
				if(!String.isBlank(homeSerachFilterObj.Customers_Drivers_License)){
					filterJSON.add(new FieldFilter('Drivers_License__c', 'Like','\'%' + homeSerachFilterObj.Customers_Drivers_License + '%\''));
				}
                if(!String.isBlank(homeSerachFilterObj.People_Email)){
                    filterJSON.add(new FieldFilter('',  '', (' (Preferred_Email__c Like \'%' + homeSerachFilterObj.People_Email + '%\''
                                                        + ' OR Email__c Like \'%' + homeSerachFilterObj.People_Email + '%\''
                                                        + ' OR Other_Email__c Like \'%' + homeSerachFilterObj.People_Email + '%\''
                                                        + ' OR Work_Email__c Like \'%' + homeSerachFilterObj.People_Email + '%\')') ));
                }
                if(!String.isBlank(homeSerachFilterObj.People_Id)) {
                    filterJSON.add(new FieldFilter('', '=', '(Vendor_Code__c LIKE \'%' + homeSerachFilterObj.People_Id + '%\' OR Customer_Number__c LIKE \'%' + homeSerachFilterObj.People_Id + '%\')'));
                }
                if(!String.isBlank(homeSerachFilterObj.People_Name)){
                    filterJSON.add(new FieldFilter('Name', 'Like','\'%' + homeSerachFilterObj.People_Name + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.People_Phone)){
                    filterJSON.add(new FieldFilter('',  '', (' (Preferred_Phone__c Like \'%' + homeSerachFilterObj.People_Phone + '%\''
                                                        + ' OR Phone Like \'%' + homeSerachFilterObj.People_Phone + '%\''
                                                        + ' OR Home_Number__c Like \'%' + homeSerachFilterObj.People_Phone + '%\''
                                                        + ' OR Preferred_SMS__c Like \'%' + homeSerachFilterObj.People_Phone + '%\''
                                                        + ' OR Work_Number__c Like \'%' + homeSerachFilterObj.People_Phone + '%\''
                                                        + ' OR Mobile__c Like \'%' + homeSerachFilterObj.People_Phone + '%\')') ));
                }
                if(!String.isBlank(homeSerachFilterObj.People_PriceLevel) && homeSerachFilterObj.People_PriceLevel != '0'){
                    filterJSON.add(new FieldFilter('Price_Level__c', '=', '\'' + homeSerachFilterObj.People_PriceLevel + '\''));
                }
                if(!String.isBlank(homeSerachFilterObj.People_SalesTax) && homeSerachFilterObj.People_SalesTax != '0'){
                    filterJSON.add(new FieldFilter('Sales_Tax__c', '=', '\'' + homeSerachFilterObj.People_SalesTax +'\''));
                }
                //Purhcase tax
                if(objName == 'Vendors' && !String.isBlank(homeSerachFilterObj.Vendor_PurchaseSalesTax) && homeSerachFilterObj.Vendor_PurchaseSalesTax != '0'){
                    filterJSON.add(new FieldFilter('Purchase_Tax__c', '=', '\'' + homeSerachFilterObj.Vendor_PurchaseSalesTax + '\''));
                }
                if(objName == 'Customers' && !String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                    filterJSON.add(new FieldFilter('Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
                }
                if(objName == 'Vendors' && !String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0') {
                    filterJSON.add(new FieldFilter('Vendor_Account_Type__c', '=', '\'' + homeSerachFilterObj.Vendor_AccountType +'\''));
                }
            }
            
            if(objName == 'Technician Performance') {
                if(!String.isBlank(homeSerachFilterObj.TechinicianPerformance_Technician)) {
                    filterJSON.add(new FieldFilter('Technician_Name__c', 'LIKE', '\'' + homeSerachFilterObj.TechinicianPerformance_Technician + '%\''));
                }
                
                if(homeSerachFilterObj.TechinicianPerformance_Date != null && !String.isBlank(homeSerachFilterObj.TechinicianPerformance_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.TechinicianPerformance_Date, 'Start_Date__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
            }
            if(objName == 'Part FIFO') {
                if(homeSerachFilterObj.Part_FIFO_Date != null && String.isNotBlank(homeSerachFilterObj.Part_FIFO_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Part_FIFO_Date, 'CreatedDate', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Category) && homeSerachFilterObj.Part_FIFO_Category != '0') {
                    filterJSON.add(new FieldFilter('Part__r.Category__c', '=', '\'' + homeSerachFilterObj.Part_FIFO_Category + '\''));
                }
                
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Part_Type) && homeSerachFilterObj.Part_FIFO_Part_Type != '0') {
                    filterJSON.add(new FieldFilter('Part__r.Part_Type__c', 'LIKE', '\'' + homeSerachFilterObj.Part_FIFO_Part_Type + '%\''));
                }
                
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Vendor)) {
                    filterJSON.add(new FieldFilter('Part__r.Vendor__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Part_FIFO_Vendor + '%\''));
                }
                filterJSON.add(new FieldFilter('Is_FIFO_Bucket__c', '=', true ));
            }
            if(objName == 'Part FIFO Line Item') {
                if(homeSerachFilterObj.Part_FIFO_Date != null && String.isNotBlank(homeSerachFilterObj.Part_FIFO_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Part_FIFO_Date, 'CreatedDate', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Category) && homeSerachFilterObj.Part_FIFO_Category != '0') {
                    filterJSON.add(new FieldFilter('Part_FIFO_Bucket__r.Part__r.Category__c', '=', '\'' + homeSerachFilterObj.Part_FIFO_Category + '\''));
                }
                
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Part_Type) && homeSerachFilterObj.Part_FIFO_Part_Type != '0') {
                    filterJSON.add(new FieldFilter('Part_FIFO_Bucket__r.Part__r.Part_Type__c', 'LIKE', '\'' + homeSerachFilterObj.Part_FIFO_Part_Type + '%\''));
                }
                
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Vendor)) {
                    filterJSON.add(new FieldFilter('Part_FIFO_Bucket__r.Part__r.Vendor__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Part_FIFO_Vendor + '%\''));
                }
                filterJSON.add(new FieldFilter('Part_FIFO_Bucket__r.Is_FIFO_Bucket__c', '=', true));
            }
            if(objName == 'Invoiced Items') {
                filterJSON.add(new FieldFilter('Is_In_Merch_Section__c', '=', 'true'));
                filterJSON.add(new FieldFilter('Deal__c', '=', 'null'));
                filterJSON.add(new FieldFilter('Invoice_Number__c', '!=', 'null'));
                
                if(homeSerachFilterObj.InvoicedItem_InvoiceDate != null && !String.isBlank(homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.InvoicedItem_InvoiceDate, 'Invoice_Number__r.Invoice_Date__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_InvoicedBy)) {
                    filterJSON.add(new FieldFilter('Invoice_Number__r.CreatedBy.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_InvoicedBy + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Category) && homeSerachFilterObj.InvoicedItem_Category != '0') {
                    filterJSON.add(new FieldFilter('(Part__r.Category__r.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Category + '%\' OR Fee__r.Category__r.Name LIKE \'' + 
                                                         homeSerachFilterObj.InvoicedItem_Category +  '%\')'));
                }
                
                if(homeSerachFilterObj.InvoicedItem_Quantity !=null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption) && homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.InvoicedItem_Quantity, 'Qty__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.InvoicedItem_Revenue != null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption) && homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.InvoicedItem_Revenue, 'Revenue__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Type) && homeSerachFilterObj.InvoicedItem_Type != 'All') {
                    if(homeSerachFilterObj.InvoicedItem_Type == 'Part') {
                        filterJSON.add(new FieldFilter('Part__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Fee') {
                        filterJSON.add(new FieldFilter('Fee__c', '!=', 'null'));
                    } else {
                        filterJSON.add(new FieldFilter('Fee__c', '=', 'null'));
                        filterJSON.add(new FieldFilter('Part__c', '=', 'null'));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Item)) {
                    filterJSON.add(new FieldFilter('(Part__r.Part_Number__c', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Item + 
                                                        '%\' OR Fee__r.Code__c LIKE \'' + homeSerachFilterObj.InvoicedItem_Item +  '%\')'));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Customer)) {
                    filterJSON.add(new FieldFilter('CO_Header__r.Customer_Name__c', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Customer + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Vendor)) {
                    filterJSON.add(new FieldFilter('Part__r.Vendor__r.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Vendor + '%\''));
                }
            }
            
            if(objName == 'SOLI') {
                filterJSON.add(new FieldFilter('Service_Order_Header__r.Deal__c', '=', 'null'));
                filterJSON.add(new FieldFilter('Service_Order_Header__r.Invoice_Number__c', '!=', 'null'));
                
                if(homeSerachFilterObj.InvoicedItem_InvoiceDate != null && !String.isBlank(homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.InvoicedItem_InvoiceDate, 'Service_Order_Header__r.Invoice_Number__r.Invoice_Date__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.InvoicedItem_Quantity !=null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption) && homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.InvoicedItem_Quantity, 'Qty_Needed__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_InvoicedBy)) {
                    filterJSON.add(new FieldFilter('Service_Order_Header__r.Invoice_Number__r.CreatedBy.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_InvoicedBy + '%\''));
                }
                
                
                if(homeSerachFilterObj.InvoicedItem_Revenue != null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption) && homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.InvoicedItem_Revenue, 'Revenue__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Type) && homeSerachFilterObj.InvoicedItem_Type != 'All') {
                    if(homeSerachFilterObj.InvoicedItem_Type == 'Part') {
                        filterJSON.add(new FieldFilter('Part__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Labor') {
                        filterJSON.add(new FieldFilter('Labour_Code__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Fee') {
                        filterJSON.add(new FieldFilter('Fee__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Sublet') {
                        filterJSON.add(new FieldFilter('Sublet__c', '!=', 'null'));
                        filterJSON.add(new FieldFilter('Sublet__r.Type__c', '=', '\'Sublet\''));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Unit') {
                        filterJSON.add(new FieldFilter('Customer_Owned_Unit__c', '!=', 'null'));
                    } else {
                        filterJSON.add(new FieldFilter('Part__c', '=', 'null'));
                        filterJSON.add(new FieldFilter('Fee__c', '=', 'null'));
                        filterJSON.add(new FieldFilter('Sublet__c', '=', 'null'));
                        filterJSON.add(new FieldFilter('Labour_Code__c', '=', 'null'));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Category) && homeSerachFilterObj.InvoicedItem_Category != '0') {
                    filterJSON.add(new FieldFilter('(Part__r.Category__r.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Item + '%\' OR Fee__r.Category__r.Name LIKE \'' + 
                                                         homeSerachFilterObj.InvoicedItem_Item +  '%\'' +
                                                         ' OR Labour_Code__r.Category__r.Name LIKE \'' + homeSerachFilterObj.InvoicedItem_Item +  
                                                         '%\' OR Sublet__r.Category__r.Name LIKE \'' 
                                                         + homeSerachFilterObj.InvoicedItem_Item +  '%\')'));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Item)) {
                    filterJSON.add(new FieldFilter('(Part__r.Part_Number__c', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Item + '%\' OR Fee__r.Code__c LIKE \'' + homeSerachFilterObj.InvoicedItem_Item +  '%\'' +
                                                         ' OR Labour_Code__r.Code__c LIKE \'' + homeSerachFilterObj.InvoicedItem_Item +  '%\' OR Sublet__r.Code__c LIKE \'' 
                                                         + homeSerachFilterObj.InvoicedItem_Item +  '%\')'));
                }
                
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Customer)) {
                    filterJSON.add(new FieldFilter('Service_Order_Header__r.CO_Header__r.Customer_Name__c', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Customer + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Vendor)) {
                    filterJSON.add(new FieldFilter('(Part__r.Vendor__r.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Vendor + '%\' OR '+
                                    'Sublet__r.Vendor__r.Name LIKE \'' + homeSerachFilterObj.InvoicedItem_Vendor + '%\')'));
                }
            }
            
            if(objName == 'Option and Fee') {
                filterJSON.add(new FieldFilter('Deal__r.Invoice_Number__c', '!=', 'null'));
                
                if(homeSerachFilterObj.InvoicedItem_InvoiceDate != null && !String.isBlank(homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.InvoicedItem_InvoiceDate, 'Deal__r.Invoice_Number__r.Invoice_Date__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.InvoicedItem_Quantity !=null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption) && homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.InvoicedItem_Quantity, 'Qty__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.InvoicedItem_Revenue != null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption) && homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.InvoicedItem_Revenue, 'Revenue__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_InvoicedBy)) {
                    filterJSON.add(new FieldFilter('Deal__r.Invoice_Number__r.CreatedBy.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_InvoicedBy + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Item)) {
                    filterJSON.add(new FieldFilter('(Part__r.Part_Number__c', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Item + '%\' OR Fee__r.Code__c LIKE \'' + homeSerachFilterObj.InvoicedItem_Item +  '%\'' +
                                                         ' OR Labour_Code__r.Code__c LIKE \'' + homeSerachFilterObj.InvoicedItem_Item +  '%\' OR Product__r.Code__c LIKE \'' 
                                                         + homeSerachFilterObj.InvoicedItem_Item +  '%\')'));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Category) && homeSerachFilterObj.InvoicedItem_Category != '0') {
                    filterJSON.add(new FieldFilter('(Part__r.Category__r.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Item + '%\' OR Fee__r.Category__r.Name LIKE \'' + 
                                                         homeSerachFilterObj.InvoicedItem_Item +  '%\'' +
                                                         ' OR Labour_Code__r.Category__r.Name LIKE \'' + homeSerachFilterObj.InvoicedItem_Item +  
                                                         '%\' OR Product__r.Category__r.Name LIKE \'' 
                                                         + homeSerachFilterObj.InvoicedItem_Item +  '%\')'));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Type) && homeSerachFilterObj.InvoicedItem_Type != 'All') {
                    if(homeSerachFilterObj.InvoicedItem_Type == 'Part') {
                        filterJSON.add(new FieldFilter('Part__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Labor') {
                        filterJSON.add(new FieldFilter('Labour_Code__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Fee') {
                        filterJSON.add(new FieldFilter('Fee__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Sublet') {
                        filterJSON.add(new FieldFilter('Product__c', '!=', 'null'));
                        filterJSON.add(new FieldFilter('Product__r.Type__c', '=', '\'Sublet\''));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Warranty Product') {
                        filterJSON.add(new FieldFilter('Product__c', '!=', 'null'));
                        filterJSON.add(new FieldFilter('Product__r.Type__c', '=', '\'Warranty Plan\''));
                    } else if(homeSerachFilterObj.InvoicedItem_Type == 'Other Product') {
                        filterJSON.add(new FieldFilter('Product__c', '!=', 'null'));
                        filterJSON.add(new FieldFilter('', '', 'Product__r.Type__c NOT IN (\'Sublet\', \'Warranty Plan\')'));
                    } else {
                        filterJSON.add(new FieldFilter('Part__c', '=', 'null'));
                        filterJSON.add(new FieldFilter('Labour_Code__c', '=', 'null'));
                        filterJSON.add(new FieldFilter('Fee__c', '=', 'null'));
                        filterJSON.add(new FieldFilter('Product__c', '=', 'null'));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Customer)) {
                    filterJSON.add(new FieldFilter('Deal__r.CO_Header__r.Customer_Name__c', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Customer + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Vendor)) {
                    filterJSON.add(new FieldFilter('(Part__r.Vendor__r.Name', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Vendor + '%\' OR '+
                                    'Product__r.Vendor__r.Name LIKE \'' + homeSerachFilterObj.InvoicedItem_Vendor + '%\')'));
                }
            }
            
            if((objName == 'Invoiced Items' || objName == 'SOLI' || objName == 'Option and Fee') && homeSerachFilterObj.InvoicedItem_Type == 'Part') {
                if(!String.isBlank(homeSerachFilterObj.Part_Type) && homeSerachFilterObj.Part_Type != 'All') {
                    filterJSON.add(new FieldFilter('Part__r.Part_Type__c', '=', '\'' + homeSerachFilterObj.Part_Type + '\''));
                }
            }
            
            if(objName == 'Technician Hours') {
                if(!String.isBlank(homeSerachFilterObj.TechinicianHours_ItemType) && homeSerachFilterObj.TechinicianHours_ItemType != 'All') {
                    if(homeSerachFilterObj.TechinicianHours_ItemType == 'Service Jobs') {
                        filterJSON.add(new FieldFilter('Service_Order_Header__c', '!=', 'null'));
                    } else if(homeSerachFilterObj.TechinicianHours_ItemType == 'Other Tasks') {
                        filterJSON.add(new FieldFilter('Task__c', '!=', 'null'));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.TechinicianHours_Technician)) {
                    filterJSON.add(new FieldFilter('Technician__r.Technician_Name__c', 'LIKE', '\'' + homeSerachFilterObj.TechinicianHours_Technician + '%\''));
                }
                
                if(homeSerachFilterObj.TechinicianHours_Date != null && !String.isBlank(homeSerachFilterObj.TechinicianHours_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.TechinicianHours_Date, 'Start_Date_Time__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.TechinicianHours_JobType) && homeSerachFilterObj.TechinicianHours_JobType != '0'){
                    String jobType;
                    if(homeSerachFilterObj.TechinicianHours_JobType == '1') {
                        jobType = 'Customer Pay';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '2') {
                        jobType = 'Third-Party Pay';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '3') {
                        jobType = 'Internal Expense';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '4') {
                        jobType = 'Deal';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '5') {
                        jobType = 'Quote';
                    } 
                    filterJSON.add(new FieldFilter('Service_Order_Header__r.Transaction_Type__r.Code_Label__c', '=', '\'' + jobType + '\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Customer)) {
                    filterJSON.add(new FieldFilter('Service_Order_Header__r.CO_Header__r.Customer_Name__c', 'LIKE', '\'' + homeSerachFilterObj.InvoicedItem_Customer + '%\''));
                }
            }
            
            if(objName == 'Payroll Hours') {
                if(!String.isBlank(homeSerachFilterObj.Payroll_Employee)) {
                    filterJSON.add(new FieldFilter('Technician__r.Technician_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Payroll_Employee + '%\''));
                }
                
                if(homeSerachFilterObj.Payroll_Date != null && !String.isBlank(homeSerachFilterObj.Payroll_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Payroll_Date, 'Start_Date__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
            }

            //For User
            if(objName == 'User') {
                filterJSON.add(new FieldFilter('IsActive', '=', 'true'));
            }
            
            // Parts
            if(objName == 'Parts') {
                if(!String.isBlank(homeSerachFilterObj.Product_Item)) {
                    filterJSON.add(new FieldFilter('Part_Number__c', 'Like', '\'%' + homeSerachFilterObj.Product_Item + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Description)){
                    filterJSON.add(new FieldFilter('Description__c', 'Like', '\'%' + homeSerachFilterObj.Product_Description + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Category) && homeSerachFilterObj.Product_Category != '0') {
                    filterJSON.add(new FieldFilter('Category__c', '=', '\'' + homeSerachFilterObj.Product_Category + '\''));
                }
                
                if(homeSerachFilterObj.Product_Price != null && !String.isBlank(homeSerachFilterObj.Product_Price.SelectedOption) && homeSerachFilterObj.Product_Price.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Product_Price, 'Retail_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                  
                if(homeSerachFilterObj.Product_QtyAvailable != null && !String.isBlank(homeSerachFilterObj.Product_QtyAvailable.SelectedOption) && homeSerachFilterObj.Product_QtyAvailable.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Product_QtyAvailable, 'AvailableParts__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_Location)) {
                    filterJSON.add(new FieldFilter('Location__c', 'Like', '\'%' + homeSerachFilterObj.Part_Location + '%\''));
                }
                
                
                if(homeSerachFilterObj.Part_Cost != null && !String.isBlank(homeSerachFilterObj.Part_Cost.SelectedOption) && homeSerachFilterObj.Part_Cost.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_Cost, 'Last_Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_AverageCost !=null && !String.isBlank(homeSerachFilterObj.Part_AverageCost.SelectedOption) && homeSerachFilterObj.Part_AverageCost.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_AverageCost, 'Average_Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                
                if(homeSerachFilterObj.Part_InStock !=null && !String.isBlank(homeSerachFilterObj.Part_InStock.SelectedOption) && homeSerachFilterObj.Part_InStock.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_InStock, 'Qty_In_Stock__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_Committed !=null && !String.isBlank(homeSerachFilterObj.Part_Committed.SelectedOption) && homeSerachFilterObj.Part_Committed.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_Committed, 'Qty_Committed__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_OnOrder !=null && !String.isBlank(homeSerachFilterObj.Part_OnOrder.SelectedOption) && homeSerachFilterObj.Part_OnOrder.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_OnOrder, 'Qty_On_Order__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_OversoldCost != null && !String.isBlank(homeSerachFilterObj.Part_OversoldCost.SelectedOption) && homeSerachFilterObj.Part_OversoldCost.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_OversoldCost, 'Oversold_Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_OversoldQty !=null && !String.isBlank(homeSerachFilterObj.Part_OversoldQty.SelectedOption) && homeSerachFilterObj.Part_OversoldQty.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_OversoldQty, 'Oversold_Qty__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD1Qty != null && String.isNotBlank(homeSerachFilterObj.Part_PRD1Qty.SelectedOption) && homeSerachFilterObj.Part_PRD1Qty.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD1Qty, 'PRD1Qty__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }

                if(homeSerachFilterObj.Part_PRD1Cost != null && !String.isBlank(homeSerachFilterObj.Part_PRD1Cost.SelectedOption) && homeSerachFilterObj.Part_PRD1Cost.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD1Cost, 'PRD1Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD2Qty != null && !String.isBlank(homeSerachFilterObj.Part_PRD2Qty.SelectedOption) && homeSerachFilterObj.Part_PRD2Qty.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD2Qty, 'PRD2Qty__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }

                if(homeSerachFilterObj.Part_PRD2Cost != null && !String.isBlank(homeSerachFilterObj.Part_PRD2Cost.SelectedOption) && homeSerachFilterObj.Part_PRD2Cost.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD2Cost, 'PRD2Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD3Qty != null && !String.isBlank(homeSerachFilterObj.Part_PRD3Qty.SelectedOption) && homeSerachFilterObj.Part_PRD3Qty.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD3Qty, 'PRD3Qty__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }

                if(homeSerachFilterObj.Part_PRD3Cost != null && !String.isBlank(homeSerachFilterObj.Part_PRD3Cost.SelectedOption) && homeSerachFilterObj.Part_PRD3Cost.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD3Cost, 'PRD3Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD4Qty != null && !String.isBlank(homeSerachFilterObj.Part_PRD4Qty.SelectedOption) && homeSerachFilterObj.Part_PRD4Qty.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD4Qty, 'PRD4Qty__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }

                if(homeSerachFilterObj.Part_PRD4Cost != null && !String.isBlank(homeSerachFilterObj.Part_PRD4Cost.SelectedOption) && homeSerachFilterObj.Part_PRD4Cost.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_PRD4Cost, 'PRD4Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_PackagedPart) && homeSerachFilterObj.Part_PackagedPart != '0') {
                    if(homeSerachFilterObj.Part_PackagedPart == '1') {
                        filterJSON.add(new FieldFilter('Packaged_Part__c', '=', true));
                    } else if(homeSerachFilterObj.Part_PackagedPart == '2') {
                        filterJSON.add(new FieldFilter('Packaged_Part__c', '=', false));
                    } 
                }
                
                if(homeSerachFilterObj.Part_LastCounted !=null && !String.isBlank(homeSerachFilterObj.Part_LastCounted.SelectedOption) && homeSerachFilterObj.Part_LastCounted.SelectedOption != '0') {
                    List<FieldFilter> lastCountedFilterJSON = getDateFilter(homeSerachFilterObj.Part_LastCounted, 'Last_Counted__c', true);
                    if(lastCountedFilterJSON.size() > 0) {
                        filterJSON.addAll(lastCountedFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.Part_LastSold !=null && !String.isBlank(homeSerachFilterObj.Part_LastSold.SelectedOption) && homeSerachFilterObj.Part_LastSold.SelectedOption != '0') {
                    List<FieldFilter> lastSoldFilterJSON = getDateFilter(homeSerachFilterObj.Part_LastSold, 'Last_Sold__c', true);
                    if(lastSoldFilterJSON.size() > 0) {  
                        filterJSON.addAll(lastSoldFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.Part_LastStocked !=null && !String.isBlank(homeSerachFilterObj.Part_LastStocked.SelectedOption) && homeSerachFilterObj.Part_LastStocked.SelectedOption != '0') {
                    List<FieldFilter> lastStockFilterJSON = getDateFilter(homeSerachFilterObj.Part_LastStocked, 'Last_Stocked__c', true);
                    if(lastStockFilterJSON.size() > 0) {
                        filterJSON.addAll(lastStockFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.Part_ReorderAt !=null && !String.isBlank(homeSerachFilterObj.Part_ReorderAt.SelectedOption) && homeSerachFilterObj.Part_ReorderAt.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_ReorderAt, 'Auto_reorder_Min__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Part_ReorderTo !=null && !String.isBlank(homeSerachFilterObj.Part_ReorderTo.SelectedOption) && homeSerachFilterObj.Part_ReorderTo.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Part_ReorderTo, 'Auto_reorder_Max__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_Vendor)) {
                    filterJSON.add(new FieldFilter('Vendor__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Part_Vendor + '%\''));
                }
                
                // Start: Added by richa 29/11/2016
                if(!String.isBlank(homeSerachFilterObj.Part_MfgPart)) {
                    filterJSON.add(new FieldFilter('Mfg_Part__c', 'Like', '\'%' + homeSerachFilterObj.Part_MfgPart + '%\''));
                }
                
                
                if(!String.isBlank(homeSerachFilterObj.Part_SKUNumber)) {
                    filterJSON.add(new FieldFilter('SKU_Number__c', 'Like', '\'%' + homeSerachFilterObj.Part_SKUNumber + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_NonInventory) && homeSerachFilterObj.Part_NonInventory != '0') {
                    if(homeSerachFilterObj.Part_NonInventory == '1') {
                        filterJSON.add(new FieldFilter('Non_Inventory_Part__c', '=', true));
                    } else if(homeSerachFilterObj.Part_NonInventory == '2') {
                        filterJSON.add(new FieldFilter('Non_Inventory_Part__c', '=', false));
                    } 
                }
                if(!String.isBlank(homeSerachFilterObj.Part_Type) && homeSerachFilterObj.Part_Type != 'All') {
                    filterJSON.add(new FieldFilter('Part_Type__c', '=', '\'' + homeSerachFilterObj.Part_Type + '\''));
                }
            }
            
            // Kits
            if(objName == 'Kits'){
                if(!String.isBlank(homeSerachFilterObj.Product_Item)) {
                    filterJSON.add(new FieldFilter('Code__c', 'Like', '\'%' + homeSerachFilterObj.Product_Item + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Description)){
                    filterJSON.add(new FieldFilter('Description__c', 'Like', '\'%' + homeSerachFilterObj.Product_Description + '%\''));
                }
                
                if(homeSerachFilterObj.Product_Price !=null && !String.isBlank(homeSerachFilterObj.Product_Price.SelectedOption) && homeSerachFilterObj.Product_Price.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Product_Price, 'Fixed_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Kit_KitPrice !=null && !String.isBlank(homeSerachFilterObj.Kit_KitPrice.SelectedOption) && homeSerachFilterObj.Kit_KitPrice.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Kit_KitPrice, 'Fixed_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Kit_FixedPrice) && homeSerachFilterObj.Kit_FixedPrice != '0') {
                    if(homeSerachFilterObj.Kit_FixedPrice == '1') {
                        filterJSON.add(new FieldFilter('Fixed_Price_Flag__c', '=', true));
                    } else if(homeSerachFilterObj.Kit_FixedPrice == '2') {
                        filterJSON.add(new FieldFilter('Fixed_Price_Flag__c', '=', false));
                    } 
                }
                
                if(!String.isBlank(homeSerachFilterObj.Kit_ServiceKit) && homeSerachFilterObj.Kit_ServiceKit != '0') {
                    if(homeSerachFilterObj.Kit_ServiceKit == '1') {
                        filterJSON.add(new FieldFilter('Service_Kit__c', '=', true));
                    } else if(homeSerachFilterObj.Kit_ServiceKit == '2') {
                        filterJSON.add(new FieldFilter('Service_Kit__c', '=', false));
                    } 
                }
            }
            
            // Fees
            if(objName == 'Fees'){
                if(!String.isBlank(homeSerachFilterObj.Product_Item)) {
                    filterJSON.add(new FieldFilter('Code__c', 'Like', '\'%' + homeSerachFilterObj.Product_Item + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Description)){
                    filterJSON.add(new FieldFilter('Description__c', 'Like', '\'%' + homeSerachFilterObj.Product_Description + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Category) && homeSerachFilterObj.Product_Category != '0') {
                    filterJSON.add(new FieldFilter('Category__c', '=', '\'' + homeSerachFilterObj.Product_Category + '\''));
                }
                
                if(homeSerachFilterObj.Product_Price !=null && !String.isBlank(homeSerachFilterObj.Product_Price.SelectedOption) && homeSerachFilterObj.Product_Price.SelectedOption != '0' && !String.isBlank(homeSerachFilterObj.Product_Price.Value1)) {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Product_Price, 'Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
            }
            
            // Labour Codes
            if(objName == 'Labor Codes'){
                if(!String.isBlank(homeSerachFilterObj.Product_Item)) {
                    filterJSON.add(new FieldFilter('Code__c', 'Like', '\'%' + homeSerachFilterObj.Product_Item + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Description)){
                    filterJSON.add(new FieldFilter('Description__c', 'Like', '\'%' + homeSerachFilterObj.Product_Description + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Category) && homeSerachFilterObj.Product_Category != '0') {
                    filterJSON.add(new FieldFilter('Category__c', '=', '\'' + homeSerachFilterObj.Product_Category + '\''));
                }
                
                if(homeSerachFilterObj.Product_Price !=null && !String.isBlank(homeSerachFilterObj.Product_Price.SelectedOption) && homeSerachFilterObj.Product_Price.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Product_Price, 'Rate__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
            }
            
            if(objName == 'Customer Orders') {
                if(homeSerachFilterObj.Customer_Sales_Id != null && homeSerachFilterObj.Customer_Sales_Id != ''){
                    filterJSON.add(new FieldFilter('Name', 'Like', '\'%' + homeSerachFilterObj.Customer_Sales_Id + '%\''));
                }
                
                if(homeSerachFilterObj.Customer_Sales_Total !=null && !String.isBlank(homeSerachFilterObj.Customer_Sales_Total.SelectedOption) && homeSerachFilterObj.Customer_Sales_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Sales_Total, 'Order_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Customer_Sales_Balance_Due !=null && !String.isBlank(homeSerachFilterObj.Customer_Sales_Balance_Due.SelectedOption) && homeSerachFilterObj.Customer_Sales_Balance_Due.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Sales_Balance_Due, 'Total_Balance_Due__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Customer_Order_Payments !=null && !String.isBlank(homeSerachFilterObj.Customer_Order_Payments.SelectedOption) && homeSerachFilterObj.Customer_Order_Payments.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Order_Payments, 'Invoiced_Amount__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                    filterJSON.add(new FieldFilter('Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
                }
                if(homeSerachFilterObj.Customer_Order_Deposits !=null && !String.isBlank(homeSerachFilterObj.Customer_Order_Deposits.SelectedOption) && homeSerachFilterObj.Customer_Order_Deposits.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Order_Deposits, 'Total_Deposit_And_Payment__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Customer_Order_Deal_Total !=null && !String.isBlank(homeSerachFilterObj.Customer_Order_Deal_Total.SelectedOption) && homeSerachFilterObj.Customer_Order_Deal_Total.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Order_Deal_Total, 'Deal_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList); 
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Sales_Customer)) {
                    filterJSON.add(new FieldFilter('Customer_Name__c', 'Like', '\'%' +homeSerachFilterObj.Customer_Sales_Customer + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Order_Notes)) {
                    filterJSON.add(new FieldFilter('Last_Comment__c', 'Like', '\'%' +homeSerachFilterObj.Customer_Order_Notes + '%\''));
                }
            }
            
            if(objName == 'Customer Invoices') {
                if(homeSerachFilterObj.Customer_Sales_Id != null && homeSerachFilterObj.Customer_Sales_Id != ''){
                    filterJSON.add(new FieldFilter('Invoice_Number__c', 'Like', '\'%' + homeSerachFilterObj.Customer_Sales_Id + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Sales_Customer)) {
                    filterJSON.add(new FieldFilter('CO_Header__r.Customer__r.Name', 'Like', '\'%' + homeSerachFilterObj.Customer_Sales_Customer + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                    filterJSON.add(new FieldFilter('CO_Header__r.Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
                }
                if(!String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Salesperson)) {  
                    filterJSON.add(new FieldFilter('Salesperson__c', 'Like', '\'%' + homeSerachFilterObj.CO_Invoice_Header_Salesperson + '%\''));
                }
                if(homeSerachFilterObj.Customer_Sales_Total !=null && !String.isBlank(homeSerachFilterObj.Customer_Sales_Total.SelectedOption) && homeSerachFilterObj.Customer_Sales_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Sales_Total, 'Total_Payment__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }

                if(!String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Customer_Order)) {
                    filterJSON.add(new FieldFilter('CO_Header__r.Name', 'Like', '\'%' + homeSerachFilterObj.CO_Invoice_Header_Customer_Order + '%\''));
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Commission != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Commission.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Commission.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_Commission, 'Deal_Commission__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                //START : Added by nidhi - 22-10-2016
                if(homeSerachFilterObj.CO_Invoice_Header_Part_Total != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Part_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Part_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_Part_Total, 'Part_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Fee_Total != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Fee_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Fee_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_Fee_Total, 'Fee_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Labour_Total != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Labour_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Labour_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_Labour_Total, 'Labour_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Sublet_Total != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_Sublet_Total, 'Sublet_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Unit_Total != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Unit_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Unit_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_Unit_Total, 'Unit_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total, 'Lien_Payout_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total != null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total, 'SalesTax_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.COInvoice_InvoiceDate != null && !String.isBlank(homeSerachFilterObj.COInvoice_InvoiceDate.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.COInvoice_InvoiceDate, 'Invoice_Date__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                
                filterJSON.add(new FieldFilter('Status__c', '=', '\'Closed\''));
            }
            
            if(objName == 'Customer Payments' || objName == 'Customer Deposits') {
                if(homeSerachFilterObj.Customer_Sales_Id != null && homeSerachFilterObj.Customer_Sales_Id != ''){
                    filterJSON.add(new FieldFilter('Invoice_Number__c', 'Like', '\'%' + homeSerachFilterObj.Customer_Sales_Id + '%\''));
                }
                if(homeSerachFilterObj.CO_Payment_Payment_Method !=null && !String.isBlank(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption) && homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption != '0') {
                    if(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption != '10' && homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption != '9') {
                    filterJSON.add(new FieldFilter('Payment_Method__c', '=', '\'' + optionValueToPaymentMethodMap.get(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption) + '\''));
                    } else {
                        filterJSON.add(new FieldFilter('Payment_Method__c', 'IN', '('+ optionValueToPaymentMethodMap.get(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption)+')'));
                    }
                }
                if(homeSerachFilterObj.Customer_Sales_Total !=null && !String.isBlank(homeSerachFilterObj.Customer_Sales_Total.SelectedOption) && homeSerachFilterObj.Customer_Sales_Total.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Sales_Total, 'Amount__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.CO_Payment_Cash_Drawer) && homeSerachFilterObj.CO_Payment_Cash_Drawer != '0'){
                    filterJSON.add(new FieldFilter('Cash_Drawer__c', '=', '\'' + homeSerachFilterObj.CO_Payment_Cash_Drawer + '\''));
                }
                
                if(homeSerachFilterObj.CO_Payment_Payment_Date != null && String.isNotBlank(homeSerachFilterObj.CO_Payment_Payment_Date.SelectedOption) && homeSerachFilterObj.CO_Payment_Payment_Date.SelectedOption != '0') {
                    List<FieldFilter> paymentDateFilterJSON = getDateFilter(homeSerachFilterObj.CO_Payment_Payment_Date, 'Payment_Date__c', false);
                    if(paymentDateFilterJSON.size() > 0) {
                        filterJSON.addAll(paymentDateFilterJSON); 
                    }
                }
				
				if(objName == 'Customer Payments') {
                    if(!String.isBlank(homeSerachFilterObj.CO_Payment_Customer_Order)) {
                        filterJSON.add(new FieldFilter('CO_Invoice_Header__r.CO_Header__r.Name', 'Like', '\'%' + homeSerachFilterObj.CO_Payment_Customer_Order + '%\''));
                    }
                    if(!String.isBlank(homeSerachFilterObj.Customer_Sales_Customer)) {
                        filterJSON.add(new FieldFilter('CO_Invoice_Header__r.CO_Header__r.Customer__r.Name', 'Like', '\'%' + homeSerachFilterObj.Customer_Sales_Customer + '%\''));
                    }
                    if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                        filterJSON.add(new FieldFilter('CO_Invoice_Header__r.CO_Header__r.Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
                    }
                    
                } else if(objName == 'Customer Deposits') {
                    filterJSON.add(new FieldFilter('Payment_Method__c', '!=', '\'Invoice\''));
                    if(!String.isBlank(homeSerachFilterObj.CO_Payment_Customer_Order)) {
                        filterJSON.add(new FieldFilter('CO_Header__r.Name', 'Like', '\'%' + homeSerachFilterObj.CO_Payment_Customer_Order + '%\''));
                    }
                    if(!String.isBlank(homeSerachFilterObj.Customer_Sales_Customer)) {
                        filterJSON.add(new FieldFilter('CO_Header__r.Customer__r.Name', 'Like', '\'%' + homeSerachFilterObj.Customer_Sales_Customer + '%\''));
                    }
                    if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                        filterJSON.add(new FieldFilter('CO_Header__r.Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
                }
                }
            }   
            
            if(objName == 'Vendor Ordering' || objName == 'Vendor Orders' || objName == 'Vendor Return' || objName == 'Vendor Receivings'|| objName == 'Vendor Invoices'){
                if(!String.isBlank(homeSerachFilterObj.Vendor_Invoicing_Header_Status) && homeSerachFilterObj.Vendor_Invoicing_Header_Status !=null ){
                    //filterJSON.add(new FieldFilter('Name', '=', '\''+homeSerachFilterObj.Customer_Sales_Id));
                }
                if(!String.isBlank(homeSerachFilterObj.Vendor_Order_Purchase_Order) && homeSerachFilterObj.Vendor_Order_Purchase_Order !='0' ){
                    filterJSON.add(new FieldFilter('Purchase_Order_Type__c', '=', '\''+homeSerachFilterObj.Vendor_Order_Purchase_Order + '\''));
                }
                /*if( homeSerachFilterObj.Vendor_Order_Total_Recieved != null ){
                        //Need To add
                }*/
                if(!String.isBlank(homeSerachFilterObj.Vendor_Ordering_Id)){    
                    filterJSON.add(new FieldFilter('Name', 'LIKE', '\'' + homeSerachFilterObj.Vendor_Ordering_Id + '%\''));
                }
                /*if(homeSerachFilterObj.Vendor_Ordering_Total !=null ){
                        //Need To add 
                }*/
                if(!String.isBlank(homeSerachFilterObj.Vendor_Ordering_Vendor)){
                    filterJSON.add(new FieldFilter('Vendor__r.Name', 'Like', '\'%'+ homeSerachFilterObj.Vendor_Ordering_Vendor + '%\''));
                }
                if(objName == 'Vendor Invoices'){
                    if(homeSerachFilterObj.Vendor_Ordering_Total !=null &&  !String.isBlank(homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption) && homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption != '0'){
                        List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Vendor_Ordering_Total, 'Total__c');
                        if(numericFilterList.size() > 0) {
                            filterJSON.addAll(numericFilterList);
                        }
                    }
                    if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0') {
                        filterJSON.add(new FieldFilter('Vendor__r.Vendor_Account_Type__c', '=', '\'' + homeSerachFilterObj.Vendor_AccountType +'\''));
                    }
                }
                if(objName == 'Vendor Orders' || objName == 'Vendor Return'){
                    if(homeSerachFilterObj.Vendor_Ordering_Total !=null && !String.isBlank(homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption) && homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption != '0'){
                        List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Vendor_Ordering_Total, 'Total__c');
                        if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                        }
                    }
                    if(objName == 'Vendor Orders') {
                      if(homeSerachFilterObj.Vendor_Order_Total_Recieved !=null && !String.isBlank(homeSerachFilterObj.Vendor_Order_Total_Recieved.SelectedOption) && homeSerachFilterObj.Vendor_Order_Total_Recieved.SelectedOption != '0'){
                          List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Vendor_Order_Total_Recieved, 'Total_Recieved__c');
                          if(numericFilterList.size() > 0) {
                              filterJSON.addAll(numericFilterList);
                          }
                      }
                    }
                    if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0') {
                        filterJSON.add(new FieldFilter('Vendor__r.Vendor_Account_Type__c', '=', '\'' + homeSerachFilterObj.Vendor_AccountType +'\''));
                    }
                }
                if(objName == 'Vendor Receivings'){
                    if(homeSerachFilterObj.Vendor_Ordering_Total !=null && !String.isBlank(homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption) && homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption != '0'){
                        List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Vendor_Ordering_Total, 'Receiving_Total__c');
                        if(numericFilterList.size() > 0) {
                            filterJSON.addAll(numericFilterList);
                        }
                    }
                    if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0') {
                        filterJSON.add(new FieldFilter('Vendor__r.Vendor_Account_Type__c', '=', '\'' + homeSerachFilterObj.Vendor_AccountType +'\''));
                    }
                }  
            }  
            if(objName == 'Inventory Unit') {
                //filterJSON.add(new FieldFilter('Unit_Type__c', '!=', '\'COU\''));
                //system.assert(false, homeSerachFilterObj);
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Year)){   
                    filterJSON.add(new FieldFilter('Year__c', '=',  homeSerachFilterObj.Inventory_Unit_Year));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Reg_Expiry !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Reg_Expiry.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Reg_Expiry.SelectedOption != '0') {
                    List<FieldFilter> regExpiryDateFilterJSON = getDateFilter(homeSerachFilterObj.Inventory_Unit_Reg_Expiry, 'Reg_Expiry_Date__c', false);
                    if(regExpiryDateFilterJSON.size() > 0) {
                        filterJSON.addAll(regExpiryDateFilterJSON);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Make)){   
                    filterJSON.add(new FieldFilter('Unit_Make__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Make + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Model)){   
                    filterJSON.add(new FieldFilter('Unit_Model__r.Name__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Model + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_SubModel)){   
                    filterJSON.add(new FieldFilter('Sub_Model__r.Sub_Model_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_SubModel + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Ext_Colour)){   
                    filterJSON.add(new FieldFilter('Colour__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Ext_Colour + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_New_Unit) && homeSerachFilterObj.Inventory_Unit_New_Unit != '0'){   
                    filterJSON.add(new FieldFilter('New_Unit__c', '=', ((homeSerachFilterObj.Inventory_Unit_New_Unit == 'Yes') ? true : false)));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price, 'Total_Base_Unit_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Inventory_Unit_Factory_Options !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Factory_Options.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Factory_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Factory_Options, 'Total_Factory_Options_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Inventory_Unit_Dealer_Options !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Dealer_Options.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Dealer_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Dealer_Options, 'Total_Dealer_Options_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Total_Price !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Total_Price.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Total_Price.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Total_Price, 'Total_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost, 'Total_Base_Units_Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost, 'Total_Factory_Options_Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost, 'Total_Dealer_Options_Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Inventory_Unit_Deal_Options_WIP !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Deal_Options_WIP.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Deal_Options_WIP.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Deal_Options_WIP, 'Deal_Options_WIP__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Total_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Total_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Total_Cost.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Total_Cost, 'Total_Cost__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Location)){   
                    filterJSON.add(new FieldFilter('Location__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Location + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Category) && homeSerachFilterObj.Inventory_Unit_Category != '0'){   
                    filterJSON.add(new FieldFilter('Category__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Category + '%\''));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Stocked_In !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Stocked_In.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Inventory_Unit_Stocked_In, 'Date_Stocked_In__c', false);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Age != null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Age.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Age.SelectedOption != '0'){   
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Age, 'Age__c');
                    if(numericFilterList.size() > 0) {
                       filterJSON.addAll(numericFilterList);
                    }  
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Key_Number)){   
                    filterJSON.add(new FieldFilter('Key_No__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Key_Number + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Engine_Number)){
                    filterJSON.add(new FieldFilter('Engine_Serial_No__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Engine_Number + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Other_Number)){   
                    filterJSON.add(new FieldFilter('Other_Serial_No__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Other_Number + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Int_Colour)){   
                    filterJSON.add(new FieldFilter('Interior_Colour__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Int_Colour + '%\''));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Stocked_Out !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Stocked_Out.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Stocked_Out.SelectedOption != '0') {
                    List<FieldFilter> stockOutFilterJSON = getDateFilter(homeSerachFilterObj.Inventory_Unit_Stocked_Out, 'Date_Stocked_Out__c', false);
                    if(stockOutFilterJSON.size() > 0) {
                        filterJSON.addAll(stockOutFilterJSON);
                    }
                }
            
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Taxable) && homeSerachFilterObj.Inventory_Unit_Taxable != '0'){   
                    filterJSON.add(new FieldFilter('Taxable__c', '=', ((homeSerachFilterObj.Inventory_Unit_Taxable == 'Yes') ? true : false)));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Applicable_Tax)){   
                    filterJSON.add(new FieldFilter('Applicable_Tax__r.Name__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Applicable_Tax + '%\''));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Cylinders !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Cylinders.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Cylinders.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Cylinders, 'Cylinders__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Automatic) && homeSerachFilterObj.Inventory_Unit_Automatic != '0'){   
                    filterJSON.add(new FieldFilter('Automatic__c', '=', ((homeSerachFilterObj.Inventory_Unit_Automatic == 'Yes') ? true : false)));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Manufactured_Date !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Manufactured_Date.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Manufactured_Date.SelectedOption != '0') {
                    List<FieldFilter> manufactureDateFilterJSON = getDateFilter(homeSerachFilterObj.Inventory_Unit_Manufactured_Date, 'Manufactured_Date__c', false);
                    if(manufactureDateFilterJSON.size() > 0) {
                        filterJSON.addAll(manufactureDateFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Mileage !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Mileage.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Mileage.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Inventory_Unit_Mileage, 'Mileage_Value__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Plate_Number)){   
                    filterJSON.add(new FieldFilter('Plate__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Plate_Number + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_VIN)){   
                    filterJSON.add(new FieldFilter('VIN_Number_Formula__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_VIN + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Unit_Type) && homeSerachFilterObj.Inventory_Unit_Unit_Type != '0') {
                    if(homeSerachFilterObj.Inventory_Unit_Unit_Type == 'ORDU') {
                        filterJSON.add(new FieldFilter('Unit_Type__c', '=', '\'' + homeSerachFilterObj.Inventory_Unit_Unit_Type + '\''));
                        filterJSON.add(new FieldFilter('Status__c', '!=', '\'Cancelled\''));
                    } else {
                        filterJSON.add(new FieldFilter('Unit_Type__c', '=', '\'' + homeSerachFilterObj.Inventory_Unit_Unit_Type + '\''));
                    }
                } else {
                    filterJSON.add(new FieldFilter('((Unit_Type__c', '=', '\'STOCK\') OR (Unit_Type__c = \'ORDU\' AND Status__c != \'Cancelled\'))'));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Compliance_Date)){   
                    filterJSON.add(new FieldFilter('Compliance_Date__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Compliance_Date + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Year_Of_1st_Rego)){   
                    filterJSON.add(new FieldFilter('Year_Of_1st_Rego__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Year_Of_1st_Rego + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Registration_Serial)){   
                    filterJSON.add(new FieldFilter('Registration_Serial__c', 'LIKE', '\'' + homeSerachFilterObj.Inventory_Unit_Registration_Serial + '%\''));
                }
            }
                
            if(objName == 'Customer Unit') {
                filterJSON.add(new FieldFilter('Unit_Type__c', '=', '\'COU\''));
                
                if(homeSerachFilterObj.Customer_Unit_Reg_Expiry !=null && !String.isBlank(homeSerachFilterObj.Customer_Unit_Reg_Expiry.SelectedOption) && homeSerachFilterObj.Customer_Unit_Reg_Expiry.SelectedOption != '0') {
                    List<FieldFilter> regExpiryDateFilterJSON = getDateFilter(homeSerachFilterObj.Customer_Unit_Reg_Expiry, 'Reg_Expiry_Date__c', false);
                    if(regExpiryDateFilterJSON.size() > 0) {
                        filterJSON.addAll(regExpiryDateFilterJSON);
                    }
                }
            
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Unit_ID)){   
                    filterJSON.add(new FieldFilter('Unit_Number__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Unit_ID + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Year)){   
                    filterJSON.add(new FieldFilter('Year__c', '=',  homeSerachFilterObj.Customer_Unit_Year));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Make)){   
                    filterJSON.add(new FieldFilter('Unit_Make__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Make + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                    filterJSON.add(new FieldFilter('Account__r.Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Customer)){   
                    filterJSON.add(new FieldFilter('Account__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Customer + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Model)){   
                    filterJSON.add(new FieldFilter('Unit_Model__r.Name__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Model + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_SubModel)){   
                    filterJSON.add(new FieldFilter('Sub_Model__r.Sub_Model_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_SubModel + '%\''));
                }
                
                if(homeSerachFilterObj.Customer_Unit_Mileage !=null && !String.isBlank(homeSerachFilterObj.Customer_Unit_Mileage.SelectedOption) && homeSerachFilterObj.Customer_Unit_Mileage.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Customer_Unit_Mileage, 'Mileage_Value__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_VIN)){   
                    filterJSON.add(new FieldFilter('VIN_Number_Formula__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_VIN + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Plate_Number)){   
                    filterJSON.add(new FieldFilter('Plate__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Plate_Number + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Key_Number)){   
                    filterJSON.add(new FieldFilter('Key_No__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Key_Number + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Engine_Number)){   
                    filterJSON.add(new FieldFilter('Engine_Serial_No__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Engine_Number + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Other_Number)){   
                    filterJSON.add(new FieldFilter('Other_Serial_No__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Other_Number + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Ext_Colour)){   
                    filterJSON.add(new FieldFilter('Colour__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Ext_Colour + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Int_Colour)){   
                    filterJSON.add(new FieldFilter('Interior_Colour__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Int_Colour + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Compliance_Date)){   
                    filterJSON.add(new FieldFilter('Compliance_Date__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Compliance_Date + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Year_Of_1st_Rego)){   
                    filterJSON.add(new FieldFilter('Year_Of_1st_Rego__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Year_Of_1st_Rego + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Registration_Serial)){   
                    filterJSON.add(new FieldFilter('Registration_Serial__c', 'LIKE', '\'' + homeSerachFilterObj.Customer_Unit_Registration_Serial + '%\''));
                }
                if(homeSerachFilterObj.Customer_Unit_Manufactured_Date != null && !String.isBlank(homeSerachFilterObj.Customer_Unit_Manufactured_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Customer_Unit_Manufactured_Date, 'Manufactured_Date__c', false);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
            }
            
            if(objName == 'Parts Needed') {
                filterJSON.add(new FieldFilter('Vendor_Order_Line_Item_Group__c', '=', 'null'));
                filterJSON.add(new FieldFilter('Vendor_Order_Header__c', '=', 'null'));
                //filterJSON.add(new FieldFilter('Part__c', '!=', 'null'));
                if(!String.isBlank(homeSerachFilterObj.Part_Type) && homeSerachFilterObj.Part_Type != 'All') {
                    filterJSON.add(new FieldFilter('Part__r.Part_Type__c', '=', '\'' + homeSerachFilterObj.Part_Type + '\''));
                }
            }
                    
            if(objName == 'Service Jobs') {
                if(homeSerachFilterObj.Service_Job_Scheduled !=null && !String.isBlank(homeSerachFilterObj.Service_Job_Scheduled.SelectedOption) && homeSerachFilterObj.Service_Job_Scheduled.SelectedOption != '0') {
                    List<FieldFilter> scheduledDateFilterJSON = getDateFilter(homeSerachFilterObj.Service_Job_Scheduled, 'Scheduled_Date__c', false);
                    if(scheduledDateFilterJSON.size() > 0) {
                        filterJSON.addAll(scheduledDateFilterJSON);
                    }
                }
                
                if(String.isNotBlank(homeSerachFilterObj.Service_Job_Job_Type) && homeSerachFilterObj.Service_Job_Job_Type != '0') {
                    filterJSON.add(new FieldFilter('Transaction_Type__r.Code_Label__c', '=', '\'' + homeSerachFilterObj.Service_Job_Job_Type + '\''));
                } else if(String.isNotBlank(homeSerachFilterObj.Service_Job_TransactionType)){
                    if(homeSerachFilterObj.Service_Job_TransactionType == 'Internal') {
                        filterJSON.add(new FieldFilter('', '', 'Transaction_Type__r.Type__c IN (\'Internal\', \'Stock Unit\')')); 
                    } else {
                        filterJSON.add(new FieldFilter('Transaction_Type__r.Type__c', '=', '\'' + homeSerachFilterObj.Service_Job_TransactionType + '\'')); 
                    } 
                }
                if(!String.isBlank(homeSerachFilterObj.Service_Job_VIN) && homeSerachFilterObj.Service_Job_VIN != '0'){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.VIN_Number__c', 'LIKE', '\'' + homeSerachFilterObj.Service_Job_VIN + '%\''));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Service_Job_Plate_Number) && homeSerachFilterObj.Service_Job_Plate_Number != '0'){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Plate__c', 'LIKE', '\'' + homeSerachFilterObj.Service_Job_Plate_Number + '%\''));
                }
            }
            
            // Vendor Product
            if(objName == 'Vendor Product'){
                if(!String.isBlank(homeSerachFilterObj.Product_Type) && homeSerachFilterObj.Product_Type != '0'){
                    String productType;
                    if(homeSerachFilterObj.Product_Type == '1') {
                        productType = Constants.DEAL_PRODUCT;
                    } else if(homeSerachFilterObj.Product_Type == '2') {
                        productType = Constants.FINANCING_PRODUCT;
                    } else if(homeSerachFilterObj.Product_Type == '3') {
                        productType = Constants.SUBLET;
                    } else if(homeSerachFilterObj.Product_Type == '4') {
                        productType = Constants.WARRANTY_PLAN;
                    } 
                    filterJSON.add(new FieldFilter('Type__c', '=', '\'' + productType + '\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Item)) {
                    filterJSON.add(new FieldFilter('Code__c', 'Like', '\'%' + homeSerachFilterObj.Product_Item + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Description)){
                    filterJSON.add(new FieldFilter('Description__c', 'Like', '\'%' + homeSerachFilterObj.Product_Description + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Category) && homeSerachFilterObj.Product_Category != '0') {
                    filterJSON.add(new FieldFilter('Category__c', '=', '\'' + homeSerachFilterObj.Product_Category + '\''));
                }
                
                if(homeSerachFilterObj.Product_Price !=null && !String.isBlank(homeSerachFilterObj.Product_Price.SelectedOption) && homeSerachFilterObj.Product_Price.SelectedOption != '0') {
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Product_Price, 'Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0') {
                    filterJSON.add(new FieldFilter('Vendor__r.Vendor_Account_Type__c', '=', '\'' + homeSerachFilterObj.Vendor_AccountType +'\''));
                }
            }
            
            if(objName != 'Invoiced Items' && objName != 'SOLI' && objName != 'Option and Fee') {
            //For All Standards Objects
                if(homeSerachFilterObj.Owner !=null && homeSerachFilterObj.Owner.SelectedOption != null && !String.isBlank(homeSerachFilterObj.Owner.SelectedOption) && homeSerachFilterObj.Owner.SelectedOption != '0') {
                    FieldFilter ff = getOwnerFilter(homeSerachFilterObj.Owner, objName);
                    if(ff != null) {
                        filterJSON.add(ff);
                    }
                }
                
                if(homeSerachFilterObj.ModifiedDate != null && !String.isBlank(homeSerachFilterObj.ModifiedDate.SelectedOption) && homeSerachFilterObj.ModifiedDate.SelectedOption != '0') {
                    List<FieldFilter> modifiedFilterJSON = getDateFilter(homeSerachFilterObj.ModifiedDate, 'LastModifiedDate', true);
                    if(modifiedFilterJSON.size() > 0) {
                        filterJSON.addAll(modifiedFilterJSON);
                    }
                }
                
                if(homeSerachFilterObj.CreatedDate != null && !String.isBlank(homeSerachFilterObj.CreatedDate.SelectedOption) && homeSerachFilterObj.CreatedDate.SelectedOption != '0') {
                    List<FieldFilter> createdFilterJSON = getDateFilter(homeSerachFilterObj.CreatedDate, 'CreatedDate', true);
                    if(createdFilterJSON.size() > 0) {
                        filterJSON.addAll(createdFilterJSON); 
                    }
				}  
                if(homeSerachFilterObj.Status != null && (!String.isBlank(homeSerachFilterObj.Status) && homeSerachFilterObj.Status !='0') ) {
                    if(objName == 'Customer Payments' || objName == 'Customer Deposits') {
                        filterJSON.add(new FieldFilter('CO_Invoice_Header__r.Status__c', '=', '\'' + homeSerachFilterObj.Status + '\''));
                    } else if(objName == 'Service Jobs') {
                        if(homeSerachFilterObj.Status == 'Active') {
                            filterJSON.add(new FieldFilter('', '', 'Work_Status__c IN (\'Ready\', \'In Progress\', \'On Hold\')')); 
                        } else if(homeSerachFilterObj.Status == 'Open') {
                            filterJSON.add(new FieldFilter('', '', 'Work_Status__c IN (\'New\', \'Ready\', \'In Progress\', \'On Hold\')')); 
                        } else {
                            filterJSON.add(new FieldFilter('Work_Status__c', '=', '\'' + homeSerachFilterObj.Status + '\''));
                        }
                    } else if(objName == 'Parts Needed'){
                        // Nothing should be added because all Part Needed are in Required status.
                    } else if(objName == 'Vendor Orders' && homeSerachFilterObj.Status == 'Active') {
                        filterJSON.add(new FieldFilter('', '', 'Status__c IN (\'Open\', \'Locked\', \'On Order\', \'Partially Received\')'));
                    }  else if(objName == 'Vendor Return' && homeSerachFilterObj.Status == 'Active') {
                        filterJSON.add(new FieldFilter('', '', 'Status__c IN (\'In Progress\', \'Submitted\', \'Approved\')'));
                    } else if(objName == 'Inventory Unit' && homeSerachFilterObj.Status == 'In Stock') { 
                        filterJSON.add(new FieldFilter('', '', 'Status__c IN (\'Available\', \'Reserved\')')); 
                    }  else if(objName == 'Deal Units') {
                        if(homeSerachFilterObj.Status == 'Active') {
                            filterJSON.add(new FieldFilter('', '', 'Customer_Owned_Unit__r.Status__c IN (\'Available\', \'Reserved\')')); 
                    } else {
                            filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Status__c', '=', '\'' + homeSerachFilterObj.Status + '\''));
                        }
                    } else {
                        if(objName == 'Customer Orders' && homeSerachFilterObj.Include_Quotes != null && homeSerachFilterObj.Include_Quotes) {
                            filterJSON.add(new FieldFilter('', '', 'Order_Status__c IN (\''+ homeSerachFilterObj.Status +'\', \'Quote\')'));
                        }  else if(objName == 'Parts Order') {
							if(homeSerachFilterObj.Status == 'Uninvoiced') {
								filterJSON.add(new FieldFilter('', '', 'Merchandise_Status__c  IN (\'Active\', \'Partially Invoiced\')'));
							} else {
								filterJSON.add(new FieldFilter('Merchandise_Status__c', '=', '\'' + homeSerachFilterObj.Status + '\''));
							}
						} else {
							filterJSON.add(new FieldFilter('Status__c', '=', '\'' + homeSerachFilterObj.Status + '\''));
						}
                    } 
                } else if(objName == 'Customer Orders' && (homeSerachFilterObj.Include_Quotes == null || !homeSerachFilterObj.Include_Quotes)) {
                    filterJSON.add(new FieldFilter('Status__c', '!=', '\'' + 'Quote' + '\''));
                } else if(objName == 'Unit Deals') {
					filterJSON.add(new FieldFilter('Status__c', '!=', '\'' + 'Invoiced' + '\''));
				} 
                if(homeSerachFilterObj.IncludeInactiveRecords == null || !homeSerachFilterObj.IncludeInactiveRecords) {
                    if(objName == 'Parts') {
                        filterJSON.add(new FieldFilter('Active__c', '=',  true ));
                    } else if(objName == 'Customers' || objName == 'Vendors' || objName == 'Labor Codes' || objName == 'Fees' || objName == 'Kits' 
                                                        || objName == 'Item Categories' || objName == 'Price Levels' || objName == 'Sales Taxes'){
                        filterJSON.add(new FieldFilter('Status__c', '=', '\'' + 'Active' + '\''));
                    } 
                }
            }
            if(objName == 'Tax Detail Customer Invoices') {
                if(homeSerachFilterObj.Tax_Detail_Invoice_Date != null && String.isNotBlank(homeSerachFilterObj.Tax_Detail_Invoice_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Tax_Detail_Invoice_Date, 'Invoice_Date__c', true);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                    filterJSON.add(new FieldFilter('CO_Header__r.Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
                }
                filterJSON.add(new FieldFilter('Status__c', '=', '\'Closed\''));
            }
            if(objName == 'Tax Detail Vendor Invoices') {
                if(homeSerachFilterObj.Tax_Detail_Invoice_Date != null && String.isNotBlank(homeSerachFilterObj.Tax_Detail_Invoice_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Tax_Detail_Invoice_Date, 'Invoice_Date__c', false);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Customer_AccountType != '0') {
                    filterJSON.add(new FieldFilter('Vendor__r.Vendor_Account_Type__c', '=', '\'' + homeSerachFilterObj.Customer_AccountType +'\''));
            }
            }
            if(objName == 'Unit Deals') {
            	if(!String.isBlank(homeSerachFilterObj.Unit_Deals_Customer)){   
                    filterJSON.add(new FieldFilter('CO_Header__r.Customer_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Unit_Deals_Customer + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Unit_Deals_Order_Number)){   
                    filterJSON.add(new FieldFilter('CO_Header__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Unit_Deals_Order_Number + '%\''));
                }
                if(homeSerachFilterObj.Unit_Deals_Total !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Total.SelectedOption) && homeSerachFilterObj.Unit_Deals_Total.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Total, 'CO_Header__r.Deal_Total__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					}
				}
				if(!String.isBlank(homeSerachFilterObj.Unit_Deals_Deal_Type) && homeSerachFilterObj.Unit_Deals_Deal_Type != '0'){
                	String dealType;
                	if(homeSerachFilterObj.Unit_Deals_Deal_Type == '1') {
                		dealType = Constants.CASH_DEAL;
                	} else if(homeSerachFilterObj.Unit_Deals_Deal_Type == '2') {
                		dealType = Constants.FINANCED;
                	}	
                    filterJSON.add(new FieldFilter('Type__c', '=', '\'' + dealType + '\''));
                }
                if(homeSerachFilterObj.Unit_Deals_Delivery != null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Delivery.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Unit_Deals_Delivery, 'Delivery_Date__c', false);
                    if(stockInFilterJSON.size() > 0) { 
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Units !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Units.SelectedOption) && homeSerachFilterObj.Unit_Deals_Units.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Units, 'Pre_Tax_Unit_Price_And_Cost_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Lien_payout !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Lien_payout.SelectedOption) && homeSerachFilterObj.Unit_Deals_Lien_payout.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Lien_payout, 'Lien_Payout_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Trade_Ins !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Trade_Ins.SelectedOption) && homeSerachFilterObj.Unit_Deals_Trade_Ins.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Trade_Ins, 'Pre_Tax_Trade_In_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Parts_And_Labour !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Parts_And_Labour.SelectedOption) && homeSerachFilterObj.Unit_Deals_Parts_And_Labour.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Parts_And_Labour, 'Pre_Tax_Part_And_Labor_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Other_Products !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Other_Products.SelectedOption) && homeSerachFilterObj.Unit_Deals_Other_Products.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Other_Products, 'Pre_Tax_Other_Product_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Fees !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Fees.SelectedOption) && homeSerachFilterObj.Unit_Deals_Fees.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Fees, 'Pre_Tax_Fee_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Stamp_Duty !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Stamp_Duty.SelectedOption) && homeSerachFilterObj.Unit_Deals_Stamp_Duty.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Stamp_Duty, 'Stamp_Duty_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Financing_Products !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Financing_Products.SelectedOption) && homeSerachFilterObj.Unit_Deals_Financing_Products.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Financing_Products, 'F_I_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Sales_Tax !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Sales_Tax.SelectedOption) && homeSerachFilterObj.Unit_Deals_Sales_Tax.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Unit_Deals_Sales_Tax, 'Sales_Tax_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
            }
            
            if(objName == 'Deal Units') {
            	filterJSON.add(new FieldFilter('Type__c', '=', '\'' + 'Unit' + '\''));
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Stock_Number)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Stock_Id__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Stock_Number + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Make)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Make_Name__c ', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Make + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Model)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Model_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Model + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Submodel)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Submodel + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Year)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Year__c', '=',  homeSerachFilterObj.Deal_Units_Year));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Order_Number)){   
                    filterJSON.add(new FieldFilter('Deal__r.CO_Header__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Order_Number + '%\''));
                }
                if(homeSerachFilterObj.Deal_Units_Total_Price !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Total_Price.SelectedOption) && homeSerachFilterObj.Deal_Units_Total_Price.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Total_Price, 'Total_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Deal_Type) && homeSerachFilterObj.Deal_Units_Deal_Type != '0'){
                    String dealType;
                    if(homeSerachFilterObj.Deal_Units_Deal_Type == '1') {
                        dealType = Constants.CASH_DEAL;
                    } else if(homeSerachFilterObj.Deal_Units_Deal_Type == '2') {
                        dealType = Constants.FINANCED;
                    }   
                    filterJSON.add(new FieldFilter('Deal__r.Type__c', '=', '\'' + dealType + '\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Deal_Customer)){   
                    filterJSON.add(new FieldFilter('Deal__r.CO_Header__r.Customer_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Deal_Customer + '%\''));
                }
                if(homeSerachFilterObj.Deal_Units_Date_Sold != null && !String.isBlank(homeSerachFilterObj.Deal_Units_Date_Sold.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Deal_Units_Date_Sold, 'Date_Sold__c', false);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Base_Price !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Base_Price.SelectedOption) && homeSerachFilterObj.Deal_Units_Base_Price.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Base_Price, 'Base_Price__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Factory_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Factory_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Factory_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Factory_Options, 'Factory_Option_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Dealer_Installed !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Dealer_Installed.SelectedOption) && homeSerachFilterObj.Deal_Units_Dealer_Installed.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Dealer_Installed, 'Dealer_Option_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Part_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Part_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Part_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Part_Options, 'Part_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Labor_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Labor_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Labor_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Labor_Options, 'Labour_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Sublet_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Sublet_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Sublet_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Sublet_Options, 'Sublet_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Fee_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Fee_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Fee_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Fee_Options, 'Fee_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Warranty_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Warranty_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Warranty_Options.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Warranty_Options, 'Warranty_Product_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Other_Products !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Other_Products.SelectedOption) && homeSerachFilterObj.Deal_Units_Other_Products.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Other_Products, 'Other_Product_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Stamp_Duty !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Stamp_Duty.SelectedOption) && homeSerachFilterObj.Deal_Units_Stamp_Duty.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Stamp_Duty, 'Stamp_Duty_Total__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_VIN)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.VIN_Number_Formula__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_VIN + '%\''));
                }
                 if(!String.isBlank(homeSerachFilterObj.Deal_Units_New_Unit) && homeSerachFilterObj.Deal_Units_New_Unit != '0'){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.New_Unit__c', '=', ((homeSerachFilterObj.Deal_Units_New_Unit == 'Yes') ? true : false)));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Category)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Category__r.Name', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Category + '%\''));
                }
                if(homeSerachFilterObj.Deal_Units_Stocked_In != null && !String.isBlank(homeSerachFilterObj.Deal_Units_Stocked_In.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Deal_Units_Stocked_In, 'Customer_Owned_Unit__r.Date_Stocked_In__c', false);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Age != null && !String.isBlank(homeSerachFilterObj.Deal_Units_Age.SelectedOption) && homeSerachFilterObj.Deal_Units_Age.SelectedOption != '0'){   
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Age, 'Customer_Owned_Unit__r.Age__c');
                    if(numericFilterList.size() > 0) {
                       filterJSON.addAll(numericFilterList);
                    }  
                }
                //Tags
                if(homeSerachFilterObj.Deal_Units_Mileage !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Mileage.SelectedOption) && homeSerachFilterObj.Deal_Units_Mileage.SelectedOption != '0'){
                    List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Deal_Units_Mileage, 'Customer_Owned_Unit__r.Mileage_Value__c');
                    if(numericFilterList.size() > 0) {
                        filterJSON.addAll(numericFilterList);
                    }
                }     
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Mileage_Type)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Mileage_Type__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Mileage_Type + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Ext_Color)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Colour__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Ext_Color + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Int_Color)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Interior_Colour__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_VIN + '%\''));
                }
                if(homeSerachFilterObj.Include_Quotes == null || !homeSerachFilterObj.Include_Quotes) {
                    filterJSON.add(new FieldFilter('Deal__r.Status__c', '!=', '\'Quotation\''));
                }
		if(!String.isBlank(homeSerachFilterObj.Deal_Units_Compliance_Date)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Compliance_Date__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Compliance_Date + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Year_Of_1st_Rego)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Year_Of_1st_Rego__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Year_Of_1st_Rego + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Registration_Serial)){   
                    filterJSON.add(new FieldFilter('Customer_Owned_Unit__r.Registration_Serial__c', 'LIKE', '\'' + homeSerachFilterObj.Deal_Units_Registration_Serial + '%\''));
                }
                if(homeSerachFilterObj.Deal_Units_Manufactured_Date != null && !String.isBlank(homeSerachFilterObj.Deal_Units_Manufactured_Date.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Deal_Units_Manufactured_Date, 'Customer_Owned_Unit__r.Manufactured_Date__c', false);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
                }
            }
            
            if(objName == 'Parts Order') {
            	filterJSON.add(new FieldFilter('Hide_Merchandise_Section__c', '=', false));
            	filterJSON.add(new FieldFilter('CO_Type__c', '!=', '\'Internal Service\''));
            	if(!String.isBlank(homeSerachFilterObj.Parts_Order_Order_Number)){   
                    filterJSON.add(new FieldFilter('Name', 'LIKE', '\'' + homeSerachFilterObj.Parts_Order_Order_Number + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Parts_Order_Customer)){   
                    filterJSON.add(new FieldFilter('Customer_Name__c', 'LIKE', '\'' + homeSerachFilterObj.Parts_Order_Customer + '%\''));
                }
                if(!String.isBlank(homeSerachFilterObj.Parts_Order_Sale_Type)){   
                	if(homeSerachFilterObj.Parts_Order_Sale_Type == 'Quote') {
                		filterJSON.add(new FieldFilter('Status__c', 'LIKE', '\'' + homeSerachFilterObj.Parts_Order_Sale_Type + '%\''));
                	} else {
                    filterJSON.add(new FieldFilter('Merchandise_Sale_Type__c', 'LIKE', '\'' + homeSerachFilterObj.Parts_Order_Sale_Type + '%\''));
                }
                    
                }
                if(homeSerachFilterObj.Parts_Order_Total !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Total.SelectedOption) && homeSerachFilterObj.Parts_Order_Total.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Parts_Order_Total, 'Parts_And_Accessories_Total__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					}
				}
                if(homeSerachFilterObj.Parts_Order_Deposits !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Deposits.SelectedOption) && homeSerachFilterObj.Parts_Order_Deposits.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Parts_Order_Deposits, 'Total_Deposit__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					}
				}
                if(homeSerachFilterObj.Parts_Order_Invoiced !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Invoiced.SelectedOption) && homeSerachFilterObj.Parts_Order_Invoiced.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Parts_Order_Invoiced, 'Parts_And_Accessories_Invoiced_Total__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					}
				}
                if(homeSerachFilterObj.Parts_Order_Modified != null && !String.isBlank(homeSerachFilterObj.Parts_Order_Modified.SelectedOption)) {
                    List<FieldFilter> stockInFilterJSON = getDateFilter(homeSerachFilterObj.Parts_Order_Modified, 'LastModifiedBy', false);
                    if(stockInFilterJSON.size() > 0) {
                        filterJSON.addAll(stockInFilterJSON);
                    }
				}
				if(homeSerachFilterObj.Parts_Order_Parts !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Parts.SelectedOption) && homeSerachFilterObj.Parts_Order_Parts.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Parts_Order_Parts, 'Merchandise_Pre_Tax_Part_Total__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					} 
				}
				if(homeSerachFilterObj.Parts_Order_Fees !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Fees.SelectedOption) && homeSerachFilterObj.Parts_Order_Fees.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Parts_Order_Fees, 'Merchandise_Pre_Tax_Fee_Total__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					}
				}
				if(homeSerachFilterObj.Parts_Order_Sales_Tax !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Sales_Tax.SelectedOption) && homeSerachFilterObj.Parts_Order_Sales_Tax.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Parts_Order_Sales_Tax, 'Parts_And_Accessories_Tax_Amount__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					}
				}
				if(homeSerachFilterObj.Parts_Order_Parts_Profit !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Parts_Profit.SelectedOption) && homeSerachFilterObj.Parts_Order_Parts_Profit.SelectedOption != '0'){
					List<FieldFilter> numericFilterList = getNumericFilter(homeSerachFilterObj.Parts_Order_Parts_Profit, 'Merchandise_Profit__c');
					if(numericFilterList.size() > 0) {
						filterJSON.addAll(numericFilterList);
					}
				}
            }
            objectFilterJSON.put(objName, filterJSON);
        }
        system.debug('********************'+objectFilterJSON);
        return objectFilterJSON;
    }
    
    /**
     * Name: getNumericFilter
     * Desc: Getting List of Field Filter according to parameter
     * @param:  (1) numericJSON - HomeSearchFilterWrapper.BetweenFilter - Between Filter Record
     *          (2) fieldName - String - Name of Field
     * @return: List<FieldFilter> - List of Field Filter Record
     **/
    private static List<FieldFilter> getNumericFilter(HomeSearchFilterWrapper.BetweenFilter numericJSON, String fieldName) {
        List<FieldFilter> numericFilterList = new List<FieldFilter>();
        
        if(numericJSON.SelectedOption == '0' || String.isBlank(numericJSON.Value1)) {
            return numericFilterList;
        } else if(numericJSON.SelectedOption == '1') {
            numericFilterList.add(new FieldFilter(fieldName, '=', Decimal.ValueOf(numericJSON.Value1)));
        } else if(numericJSON.SelectedOption == '2') {
            numericFilterList.add(new FieldFilter(fieldName, '!=', Decimal.ValueOf(numericJSON.Value1)));
        } else if(numericJSON.SelectedOption == '3') {
            numericFilterList.add(new FieldFilter(fieldName, '>', Decimal.ValueOf(numericJSON.Value1)));
        } else if(numericJSON.SelectedOption == '4') {
            numericFilterList.add(new FieldFilter(fieldName, '<', Decimal.ValueOf(numericJSON.Value1)));
        } else if(numericJSON.SelectedOption == '5' && !String.isBlank(numericJSON.Value2)) {
            numericFilterList.add(new FieldFilter(fieldName, '>=',  Decimal.ValueOf(numericJSON.Value1)));
            numericFilterList.add(new FieldFilter(fieldName, '<=',  Decimal.ValueOf(numericJSON.Value2)));
        }
        return numericFilterList;
    }
        
    /**
     * Name: getOwnerFilter
     * Desc: Getting FieldFilter according to parameter
     * @param:  (1) ownerJSON - HomeSearchFilterWrapper.OwnerFilter - Owner Filter JSON String 
     *          (2) objName - String - Object Name 
     * @return: FieldFilter - Field Filter Record
    **/ 
    private static FieldFilter getOwnerFilter(HomeSearchFilterWrapper.OwnerFilter ownerJSON, String objName) {
        FieldFilter ownerFilter;
        
        String ownerFieldName = 'OwnerId';
        if(HomeSearchUtil.objectToOwnerObjectFieldName.containsKey(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName))) {
            String ownerFieldNameFromMap = HomeSearchUtil.objectToOwnerObjectFieldName.get(HomeSearchUtil.displayObjectNameToObjectAPINameMap.get(objName));
            ownerFieldName = (ownerFieldNameFromMap.endsWith('__c')) ? ownerFieldNameFromMap : (ownerFieldNameFromMap + '.' + ownerFieldName);
            ownerFieldName = ownerFieldName;
        }
        if(objName == 'Users') {
            ownerFieldName = 'CreatedById';
        }
        
        if(ownerJSON.SelectedOption == '1') {
            ownerFilter = new FieldFilter(ownerFieldName, '=', '\'' + UserInfo.getUserId() + '\'');
        } else if(ownerJSON.SelectedOption == '2'){
            ownerFilter = new FieldFilter(ownerFieldName, '!=', '\'' + UserInfo.getUserId() + '\'');
        } else if(ownerJSON.SelectedOption == '3'){
            if(ownerJSON.OwnerId != null) {
                ownerFilter = new FieldFilter(ownerFieldName, '=', '\'' + ownerJSON.OwnerId + '\'');
            }
        }
        return ownerFilter;
    }
    
    /**
     * Name: getStatusFilter
     * Desc: Getting Status of Filter  according to parameter
     * @param:  (1) statusStr - String - Status String 
     *          (2) objName - String - Object Name 
     * @return: FieldFilter - Field Filter Record
    **/ 
    /*private static FieldFilter getStatusFilter(String statusStr, String objName) {
        FieldFilter filter;
        
        if(objName == 'Customers' || objName == 'Vendors' || objName == 'People') {
            statusStr = (statusStr == '1') ? 'true' : ((statusStr == '2') ? 'false' : 'ANY');
            if(statusStr != 'ANY') {
                filter = new FieldFilter('Active__c', '=', statusStr);
            }
        } else if(objName == 'Parts') {
            statusStr = (statusStr == '1') ? '> 0' : ((statusStr == '2') ? '< 0' : 'ANY');
            if(statusStr != 'ANY') {
                filter = new FieldFilter('AvailableParts__c', '', statusStr);
            }
        }
        
        return filter;
    }*/ 
    
    /**
     * Name: getDateFilter
     * Desc: Getting Date Filter
     * @param:  (1) dateJSON - HomeSearchFilterWrapper.BetweenFilter - Between Filter Record
     *          (2) fieldName - String - Field Name 
     * @return: List<FieldFilter> - List Of Field Filter Record
    **/ 
    private static List<FieldFilter> getDateFilter(HomeSearchFilterWrapper.BetweenFilter dateJSON, String fieldName, Boolean isDateTimeField) {
        List<FieldFilter> dateFilterList = new List<FieldFilter>();
        
        if(dateJSON.SelectedOption == '1') {
            dateFilterList.add(new FieldFilter(fieldName, '=', 'TODAY'));
        } else if(dateJSON.SelectedOption == '2') {
            dateFilterList.add(new FieldFilter(fieldName, '=', 'YESTERDAY'));
        } else if(dateJSON.SelectedOption == '3') {
            dateFilterList.add(new FieldFilter(fieldName, '=', 'LAST_N_DAYS:7'));
        } else if(dateJSON.SelectedOption == '4') {
            dateFilterList.add(new FieldFilter(fieldName, '=', 'LAST_N_DAYS:30'));
        } else if(dateJSON.SelectedOption == '5' && (dateJSON.Value1 != null && dateJSON.Value1.trim().length() != 0) && (dateJSON.Value2 != null && dateJSON.Value2.trim().length() != 0)) {
            system.debug('dateJSON.Value1   ' + dateJSON.Value1 +'\n\n' + getDateFromString(dateJSON.Value1));
            DateTime dtValue = getDateFromString(dateJSON.Value1);
            if(isDateTimeField) {
                dateFilterList.add(new FieldFilter(fieldName, '>=', dtValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')));
            } else {
                dateFilterList.add(new FieldFilter(fieldName, '>=', dtValue.format('yyyy-MM-dd')));
            }
            
            dtValue = getDateFromString(dateJSON.Value2);
            dtValue = dtValue.addDays(1); // This is done since for a date passed as end date, we get the start 00 hrs of end date
                                          // and we need to include all records for date that which will be before 00 hrs of next date to end date
            if(isDateTimeField) {
                dateFilterList.add(new FieldFilter(fieldName, '<=', dtValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')));
            } else {
                dateFilterList.add(new FieldFilter(fieldName, '<', dtValue.format('yyyy-MM-dd')));
            }
        } else if(dateJSON.SelectedOption == '6') {
            dateFilterList.add(new FieldFilter(fieldName, '=', 'NEXT_N_DAYS:30'));
        } else if(dateJSON.SelectedOption == '7') {
            dateFilterList.add(new FieldFilter(fieldName, '=', 'TOMORROW'));
        } else if(dateJSON.SelectedOption == '8') {
            dateFilterList.add(new FieldFilter(fieldName, '=', 'NEXT_N_DAYS:7'));
        }
        return dateFilterList;
    }   
    
     /**
     * Name: getDateFromString
     * Desc: Getting Date From Given String 
     * @param:  (1) dtStr - String  - Date String
     * @return: DateTime- DateTime Object
     **/    
    public static DateTime getDateFromString(String dtStr) {
        String dateFormat = BPUtility.getDateFormat();
        List<String> dateFormatCharacter = dateFormat.split('/');
        Integer dayIndex;
        Integer monthIndex;
        Integer yearIndex;
        for(Integer index = 0; index < dateFormatCharacter.size(); index++ ){
            if(dateFormatCharacter[index].contains('dd')){
                dayIndex = index;
            }else if(dateFormatCharacter[index].contains('mm')){
                monthIndex = index;
            }else if(dateFormatCharacter[index].contains('yy')){
                yearIndex = index;
            }
        }
        
        Integer day = Integer.valueOf(dtStr.split('/')[dayIndex]);
        Integer month = Integer.valueOf(dtStr.split('/')[monthIndex]);
        Integer year = Integer.valueOf(dtStr.split('/')[yearIndex]);
        
        return datetime.newInstance(year, month, day, 0, 0 , 0);
    }
        
    /**
     * Name: getFilterLabelList
     * Desc: Getting List Filter Label
     * @param:  (1) homeSerachFilterObj - HomeSearchFilterWrapper  -Home Search Filter Wrapper Record
     * @return: List<FilterLabel> - List Of Filter Label Record
     **/    
    public static List<FilterLabel> getFilterLabelList(HomeSearchFilterWrapper homeSerachFilterObj) {
        List<FilterLabel> filterLables = new List<FilterLabel>();
        if(homeSerachFilterObj.Type.Objects != null && homeSerachFilterObj.Type.Objects.size() > 0) {
            List<String> objectList = new List<String>();
            for(String objName : homeSerachFilterObj.Type.Objects) {
                if(objName != 'Any') {
                    objectList.add(objName);
                }
            }
            if(objectList.size() == 1) {
                filterLables.add(new FilterLabel('Type', 'Type', objectList[0]));
            } else if(objectList.size() > 1) {
                String types = '';
                for(String typeStr : objectList) {
                    types += typeStr + ', ';
                }
                types = types.subString(0, types.length() - 2);
                filterLables.add(new FilterLabel('Type', 'Type', types));
            }
        }
        
        if(!String.isBlank(homeSerachFilterObj.SearchText)) {
            filterLables.add(new FilterLabel('SearchText', 'Contains', homeSerachFilterObj.SearchText));
        }
        
        if(!homeSerachFilterObj.Type.Objects.contains('Invoiced Items') && !homeSerachFilterObj.Type.Objects.contains('SOLI') &&
                    !homeSerachFilterObj.Type.Objects.contains('Option and Fee')) {
        if(homeSerachFilterObj.Owner !=null && !String.isBlank(homeSerachFilterObj.Owner.SelectedOption) && homeSerachFilterObj.Owner.SelectedOption != '0') {
            String ownerLabelName = optionValueToOwnerKeyMap.containsKey(homeSerachFilterObj.Owner.SelectedOption) ? optionValueToOwnerKeyMap.get(homeSerachFilterObj.Owner.SelectedOption) : homeSerachFilterObj.Owner.SelectedOption;
            if(ownerLabelName == '3') {
                filterLables.add(new FilterLabel('Owner', 'Owner', homeSerachFilterObj.Owner.OwnerName));
            } else {
                filterLables.add(new FilterLabel('Owner', 'Owner', ownerLabelName));
            }
            
        }
        
        if(!String.isBlank(homeSerachFilterObj.Status) && homeSerachFilterObj.Status != '0') {
            String statusName = optionValueToStatusKeyMap.containsKey(homeSerachFilterObj.Status) ? optionValueToStatusKeyMap.get(homeSerachFilterObj.Status) : homeSerachFilterObj.Status;
            filterLables.add(new FilterLabel('Status', 'Status', statusName));
        }
        
        if(homeSerachFilterObj.ModifiedDate !=null && !String.isBlank(homeSerachFilterObj.ModifiedDate.SelectedOption) && homeSerachFilterObj.ModifiedDate.SelectedOption != '0') {
            String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.ModifiedDate.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.ModifiedDate.SelectedOption) : homeSerachFilterObj.ModifiedDate.SelectedOption;
            if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.ModifiedDate.Value1) && !String.isBlank(homeSerachFilterObj.ModifiedDate.Value2)) {
                filterLables.add(new FilterLabel('ModifiedDate', 'Modified', homeSerachFilterObj.ModifiedDate.Value1 + ' To ' + homeSerachFilterObj.ModifiedDate.Value2));
            } else if(modifiedLabelName != '5'){
                filterLables.add(new FilterLabel('ModifiedDate', 'Modified', modifiedLabelName));
            }
        }
        
        if(homeSerachFilterObj.CreatedDate !=null && !String.isBlank(homeSerachFilterObj.CreatedDate.SelectedOption) && homeSerachFilterObj.CreatedDate.SelectedOption != '0') {
            String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.CreatedDate.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.CreatedDate.SelectedOption) : homeSerachFilterObj.CreatedDate.SelectedOption;
            if(modifiedLabelName == '5' && !String.isBlank(HomeSerachFilterObj.CreatedDate.Value1) && !String.isBlank(homeSerachFilterObj.CreatedDate.Value2)) {
                filterLables.add(new FilterLabel('CreatedDate', 'Created', homeSerachFilterObj.CreatedDate.Value1 + ' To ' + homeSerachFilterObj.CreatedDate.Value2));
            } else if(modifiedLabelName != '5'){
                filterLables.add(new FilterLabel('CreatedDate', 'Created', modifiedLabelName));
            }
        }
        
            if(homeSerachFilterObj.IncludeInactiveRecords !=null && homeSerachFilterObj.IncludeInactiveRecords) {
                filterLables.add(new FilterLabel('IncludeInactiveRecords', '', 'Include Inactive'));
            }
        }
        
        // Customers AND Vendors
        if(homeSerachFilterObj.Type.Objects.contains('People') ||homeSerachFilterObj.Type.Objects.contains('Customers')  || homeSerachFilterObj.Type.Objects.contains('Vendors') ){
            if(!String.isBlank(homeSerachFilterObj.People_BillingAddress)) {
                filterLables.add(new FilterLabel('People_BillingAddress', 'Billing Address', homeSerachFilterObj.People_BillingAddress));
            }
            if(!String.isBlank(homeSerachFilterObj.People_BillingCity)){
                filterLables.add(new FilterLabel('People_BillingCity', 'Billing City', homeSerachFilterObj.People_BillingCity));
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Customers')) {
                if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0'){
                    if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Account_Type__c> accountTypeList= [select Name from Account_Type__c where Id =: homeSerachFilterObj.Customer_AccountType];
                    filterLables.add(new FilterLabel('Customer_AccountType', 'Account Type', accountTypeList[0].Name));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Vendors')) {
                if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0'){
                    if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Account_Type__c> accountTypeList= [select Name from Account_Type__c where Id =: homeSerachFilterObj.Vendor_AccountType];
                    filterLables.add(new FilterLabel('Vendor_AccountType', 'Account Type', accountTypeList[0].Name));
                }
            }
            
            if(!String.isBlank(homeSerachFilterObj.People_Country)){
                filterLables.add(new FilterLabel('People_Country', 'Billing Country', homeSerachFilterObj.People_Country));
            }
			if(!String.isBlank(homeSerachFilterObj.Customers_Drivers_License)){
				filterLables.add(new FilterLabel('Customers_Drivers_License', 'Drivers License', homeSerachFilterObj.Customers_Drivers_License));
			}
            if(!String.isBlank(homeSerachFilterObj.People_StateProv)){
                filterLables.add(new FilterLabel('People_StateProv', 'Billing State', homeSerachFilterObj.People_StateProv));
            }
            if(!String.isBlank(homeSerachFilterObj.People_Email)){
                filterLables.add(new FilterLabel('People_Email', 'Email', homeSerachFilterObj.People_Email));
            }
            if(!String.isBlank(homeSerachFilterObj.People_Id)) {
                filterLables.add(new FilterLabel('People_Id', 'Id', homeSerachFilterObj.People_Id));
            }
            if(!String.isBlank(homeSerachFilterObj.People_Name)){
                filterLables.add(new FilterLabel('People_Name', 'Name', homeSerachFilterObj.People_Name));
            }
            if(!String.isBlank(homeSerachFilterObj.People_Phone)){
                filterLables.add(new FilterLabel('People_Phone', 'Phone', homeSerachFilterObj.People_Phone));
            }
            if(!String.isBlank(homeSerachFilterObj.People_PriceLevel)  && homeSerachFilterObj.People_PriceLevel != '0'){
                if(AccessControl.ifObjectFieldIsAccessible('Price_Level__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Price_Level__c> pricelist= [select Name__c from Price_Level__c where Id =: homeSerachFilterObj.People_PriceLevel];
                filterLables.add(new FilterLabel('People_PriceLevel', 'Price level', pricelist[0].Name__c));
            }
            if(!String.isBlank(homeSerachFilterObj.People_SalesTax) && homeSerachFilterObj.People_SalesTax != '0'){
                if(AccessControl.ifObjectFieldIsAccessible('Sales_Tax__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                List<Sales_Tax__c> saleslist= [select Name__c from Sales_Tax__c where Id =: homeSerachFilterObj.People_SalesTax];
                filterLables.add(new FilterLabel('People_SalesTax', 'Sales Tax', saleslist[0].Name__c));
            }
        }
            
            
        if(homeSerachFilterObj.Type.Objects.contains('Customer Orders') || homeSerachFilterObj.Type.Objects.contains('Customer Invoices') || homeSerachFilterObj.Type.Objects.contains('Customer Payments') || homeSerachFilterObj.Type.Objects.contains('Customer Deposits') || homeSerachFilterObj.Type.Objects.contains('Unit Deals')){              
                if(!String.isBlank(homeSerachFilterObj.Customer_Sales_Customer)){
                    filterLables.add(new FilterLabel('Customer_Sales_Customer', 'Customer', homeSerachFilterObj.Customer_Sales_Customer));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Sales_Id)){
                    filterLables.add(new FilterLabel('Customer_Sales_Id', 'Id', homeSerachFilterObj.Customer_Sales_Id));
                }
                if(homeSerachFilterObj.Customer_Sales_Balance_Due !=null && !String.isBlank(homeSerachFilterObj.Customer_Sales_Balance_Due.SelectedOption) && homeSerachFilterObj.Customer_Sales_Balance_Due.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Customer_Sales_Balance_Due.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Customer_Sales_Balance_Due.SelectedOption) : homeSerachFilterObj.Customer_Sales_Balance_Due.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Customer_Sales_Balance_Due', 'Balance Due', homeSerachFilterObj.Customer_Sales_Balance_Due.Value1 + ' To ' + homeSerachFilterObj.Customer_Sales_Balance_Due.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Customer_Sales_Balance_Due', 'Balance Due', modifiedLabelName + ' ' + homeSerachFilterObj.Customer_Sales_Balance_Due.Value1));
                    }
                }
                if(homeSerachFilterObj.Customer_Order_Payments !=null && !String.isBlank(homeSerachFilterObj.Customer_Order_Payments.SelectedOption) && homeSerachFilterObj.Customer_Order_Payments.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Customer_Order_Payments.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Customer_Order_Payments.SelectedOption) : homeSerachFilterObj.Customer_Order_Payments.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Customer_Order_Payments', 'Invoiced', homeSerachFilterObj.Customer_Order_Payments.Value1 + ' To ' + homeSerachFilterObj.Customer_Order_Payments.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Customer_Order_Payments', 'Invoiced', modifiedLabelName + ' ' + homeSerachFilterObj.Customer_Order_Payments.Value1));
                    }
                }
                if(homeSerachFilterObj.Customer_Order_Deposits !=null && !String.isBlank(homeSerachFilterObj.Customer_Order_Deposits.SelectedOption) && homeSerachFilterObj.Customer_Order_Deposits.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Customer_Order_Deposits.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Customer_Order_Deposits.SelectedOption) : homeSerachFilterObj.Customer_Order_Deposits.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Customer_Order_Deposits', 'Deposit', homeSerachFilterObj.Customer_Order_Deposits.Value1 + ' To ' + homeSerachFilterObj.Customer_Order_Deposits.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Customer_Order_Deposits', 'Deposit', modifiedLabelName + ' ' + homeSerachFilterObj.Customer_Order_Deposits.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Customer_Sales_Total !=null && !String.isBlank(homeSerachFilterObj.Customer_Sales_Total.SelectedOption) && homeSerachFilterObj.Customer_Sales_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Customer_Sales_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Customer_Sales_Total.SelectedOption) : homeSerachFilterObj.Customer_Sales_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Customer_Sales_Total', 'Total', homeSerachFilterObj.Customer_Sales_Total.Value1 + ' To ' + homeSerachFilterObj.Customer_Sales_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Customer_Sales_Total', 'Total', modifiedLabelName + ' ' + homeSerachFilterObj.Customer_Sales_Total.Value1));
                    }
                }
                if(!String.isBlank( homeSerachFilterObj.CO_Invoice_Header_Customer_Order)){
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Customer_Order', 'Customer Order', homeSerachFilterObj.CO_Invoice_Header_Customer_Order));
                }
                
                if(!String.isBlank( homeSerachFilterObj.CO_Payment_Customer_Order)){
                    filterLables.add(new FilterLabel('CO_Payment_Customer_Order', 'Customer Order', homeSerachFilterObj.CO_Payment_Customer_Order));
            }
        
                if(homeSerachFilterObj.CO_Payment_Payment_Method !=null && !String.isBlank(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption) && homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption != '0' ){
                    String paymentLabelName = '';
                    if(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption == '10') {
                        paymentLabelName = Constants.CASH_CREDIT_ONLY_LABEL; 
                    } else {
                        paymentLabelName = optionValueToPaymentMethodMap.containsKey(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption) ? optionValueToPaymentMethodMap.get(homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption) : homeSerachFilterObj.CO_Payment_Payment_Method.SelectedOption;
                    }
                    filterLables.add(new FilterLabel('CO_Payment_Payment_Method', 'Payment Method', paymentLabelName));
                }
                
                if(homeSerachFilterObj.Type.Objects.contains('Customer Payments') || homeSerachFilterObj.Type.Objects.contains('Customer Deposits')) {              
                    if(!String.isBlank(homeSerachFilterObj.CO_Payment_Cash_Drawer) && homeSerachFilterObj.CO_Payment_Cash_Drawer != '0'){
                        if(AccessControl.ifObjectFieldIsAccessible('Cash_Drawer__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                        List<Cash_Drawer__c> cashDrawerList = [select Name from Cash_Drawer__c where Id =: homeSerachFilterObj.CO_Payment_Cash_Drawer];
                        filterLables.add(new FilterLabel('CO_Payment_Cash_Drawer', 'Cash Drawer', cashDrawerList[0].Name));
                    }
                    if(homeSerachFilterObj.CO_Payment_Payment_Date !=null && String.isNotBlank(homeSerachFilterObj.CO_Payment_Payment_Date.SelectedOption) && homeSerachFilterObj.CO_Payment_Payment_Date.SelectedOption != '0') {
                        String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.CO_Payment_Payment_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.CO_Payment_Payment_Date.SelectedOption) : homeSerachFilterObj.CO_Payment_Payment_Date.SelectedOption;
                        if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.CO_Payment_Payment_Date.Value1) && !String.isBlank(homeSerachFilterObj.CO_Payment_Payment_Date.Value2)) {
                            filterLables.add(new FilterLabel('CO_Payment_Payment_Date', 'Payment Date', homeSerachFilterObj.CO_Payment_Payment_Date.Value1 + ' To ' + homeSerachFilterObj.CO_Payment_Payment_Date.Value2));
                        } else if(modifiedLabelName != '5') {
                            filterLables.add(new FilterLabel('CO_Payment_Payment_Date', 'Payment Date', modifiedLabelName));
                        }
                    }
                }
                
                if(homeSerachFilterObj.Type.Objects.contains('Customer Orders') || homeSerachFilterObj.Type.Objects.contains('Customer Invoices') 
                    || homeSerachFilterObj.Type.Objects.contains('Customer Payments') || homeSerachFilterObj.Type.Objects.contains('Customer Deposits')) {              
                    if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0'){
                        if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                        List<Account_Type__c> accountTypeList= [select Name from Account_Type__c where Id =: homeSerachFilterObj.Customer_AccountType];
                        filterLables.add(new FilterLabel('Customer_AccountType', 'Account Type', accountTypeList[0].Name));
                    }
                }
                
                if(homeSerachFilterObj.Type.Objects.contains('Customer Invoices')) {    
                    if(homeSerachFilterObj.COInvoice_InvoiceDate !=null && !String.isBlank(homeSerachFilterObj.COInvoice_InvoiceDate.SelectedOption) && homeSerachFilterObj.COInvoice_InvoiceDate.SelectedOption != '0') {
                        String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.COInvoice_InvoiceDate.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.COInvoice_InvoiceDate.SelectedOption) : homeSerachFilterObj.COInvoice_InvoiceDate.SelectedOption;
                        if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.COInvoice_InvoiceDate.Value1) && !String.isBlank(homeSerachFilterObj.COInvoice_InvoiceDate.Value2)) {
                            filterLables.add(new FilterLabel('COInvoice_InvoiceDate', 'Invoice Date', homeSerachFilterObj.COInvoice_InvoiceDate.Value1 + ' To ' + homeSerachFilterObj.COInvoice_InvoiceDate.Value2));
                        } else if(modifiedLabelName != '5') {
                            filterLables.add(new FilterLabel('COInvoice_InvoiceDate', 'Invoice Date', modifiedLabelName));
                        }
                    }
                }
            }
        
            if(homeSerachFilterObj.Type.Objects.contains('Customer Orders')) {
                if(homeSerachFilterObj.Customer_Order_Deal_Total !=null && !String.isBlank(homeSerachFilterObj.Customer_Order_Deal_Total.SelectedOption) && homeSerachFilterObj.Customer_Order_Deal_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Customer_Order_Deal_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Customer_Order_Deal_Total.SelectedOption) : homeSerachFilterObj.Customer_Order_Deal_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Customer_Order_Deal_Total', 'Deal Total', homeSerachFilterObj.Customer_Order_Deal_Total.Value1 + ' To ' + homeSerachFilterObj.Customer_Order_Deal_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Customer_Order_Deal_Total', 'Deal Total', modifiedLabelName + ' ' + homeSerachFilterObj.Customer_Order_Deal_Total.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Include_Quotes !=null && homeSerachFilterObj.Include_Quotes) {
                    filterLables.add(new FilterLabel('Include_Quotes', '', 'Include Quotes'));
            }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Order_Notes)){  
                    filterLables.add(new FilterLabel('Customer_Order_Notes', 'Notes', homeSerachFilterObj.Customer_Order_Notes));
                }
            }
        
            if(homeSerachFilterObj.Type.Objects.contains('Customer Invoices')) {
                if(homeSerachFilterObj.CO_Invoice_Header_Part_Total !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Part_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Part_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_Part_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_Part_Total.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_Part_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Part_Total', 'Part Total', homeSerachFilterObj.CO_Invoice_Header_Part_Total.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_Part_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Part_Total', 'Part Total', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_Part_Total.Value1));
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Fee_Total !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Fee_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Fee_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_Fee_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_Fee_Total.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_Fee_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Fee_Total', 'Fee Total', homeSerachFilterObj.CO_Invoice_Header_Fee_Total.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_Fee_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Fee_Total', 'Fee Total', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_Fee_Total.Value1));
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Labour_Total !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Labour_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Labour_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_Labour_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_Labour_Total.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_Labour_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Labour_Total', 'Labour Total', homeSerachFilterObj.CO_Invoice_Header_Labour_Total.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_Labour_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Labour_Total', 'Labour Total', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_Labour_Total.Value1));
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Unit_Total !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Unit_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Unit_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_Unit_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_Unit_Total.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_Unit_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Unit_Total', 'Unit Total', homeSerachFilterObj.CO_Invoice_Header_Unit_Total.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_Unit_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Unit_Total', 'Unit Total', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_Unit_Total.Value1));
                    }
                }
                
                if(homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_LienPayout_Total', 'Lien Payout', homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_LienPayout_Total', 'Lien Payout', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_LienPayout_Total.Value1));
                    }
                }
                
                if(homeSerachFilterObj.CO_Invoice_Header_Sublet_Total !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Sublet_Total', 'Sublet Total', homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Sublet_Total', 'Sublet Total', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_Sublet_Total.Value1));
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_SalesTax_Total', 'SalesTax Total', homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_SalesTax_Total', 'SalesTax Total', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_SalesTax_Total.Value1));
                    }
                }
                if(homeSerachFilterObj.CO_Invoice_Header_Commission !=null && !String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Commission.SelectedOption) && homeSerachFilterObj.CO_Invoice_Header_Commission.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.CO_Invoice_Header_Commission.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.CO_Invoice_Header_Commission.SelectedOption) : homeSerachFilterObj.CO_Invoice_Header_Commission.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Commission', 'Commission', homeSerachFilterObj.CO_Invoice_Header_Commission.Value1 + ' To ' + homeSerachFilterObj.CO_Invoice_Header_Commission.Value2));
                    } else {
                        filterLables.add(new FilterLabel('CO_Invoice_Header_Commission', 'Commission', modifiedLabelName + ' ' + homeSerachFilterObj.CO_Invoice_Header_Commission.Value1));
            }
                }
                if(!String.isBlank(homeSerachFilterObj.CO_Invoice_Header_Salesperson)){ 
                    filterLables.add(new FilterLabel('CO_Invoice_Header_Salesperson', 'Salesperson', homeSerachFilterObj.CO_Invoice_Header_Salesperson));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Vendor Orders') || homeSerachFilterObj.Type.Objects.contains('Vendor Return') || homeSerachFilterObj.Type.Objects.contains('Vendor Receivings')  || homeSerachFilterObj.Type.Objects.contains('Vendor Invoices') ){
                    
                if(!String.isBlank(homeSerachFilterObj.Vendor_Invoicing_Header_Status)){
                    filterLables.add(new FilterLabel('Vendor_Invoicing_Header_Status', 'Status', homeSerachFilterObj.Vendor_Invoicing_Header_Status));
                }
                if(!String.isBlank(homeSerachFilterObj.Vendor_Order_Purchase_Order) && homeSerachFilterObj.Vendor_Order_Purchase_Order != '0'){
                    //filterJSON.add(new FieldFilter('Purchase_Order_Type__c', '=', homeSerachFilterObj.Vendor_Order_Purchase_Order));
                    if(AccessControl.ifObjectFieldIsAccessible('PO_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<PO_Type__c> PuchaseOrderList = [select Code__c from PO_Type__c where Id =: homeSerachFilterObj.Vendor_Order_Purchase_Order];
                    if(PuchaseOrderList.size() > 0) {
                        filterLables.add(new FilterLabel('Vendor_Order_Purchase_Order', 'Purchase Order', PuchaseOrderList[0].Code__c));
                    } else {
                        filterLables.add(new FilterLabel('Vendor_Order_Purchase_Order', 'Purchase Order', ''));
                    }
                }
                if(homeSerachFilterObj.Vendor_Order_Total_Recieved !=null && !String.isBlank(homeSerachFilterObj.Vendor_Order_Total_Recieved.SelectedOption) && homeSerachFilterObj.Vendor_Order_Total_Recieved.SelectedOption != '0' ){
                    
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Vendor_Order_Total_Recieved.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Vendor_Order_Total_Recieved.SelectedOption) : homeSerachFilterObj.Vendor_Order_Total_Recieved.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Vendor_Order_Total_Recieved', ' Receving Total', homeSerachFilterObj.Vendor_Order_Total_Recieved.Value1 + ' To ' + homeSerachFilterObj.Vendor_Order_Total_Recieved.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Vendor_Order_Total_Recieved', ' Receving Total', modifiedLabelName + ' ' + homeSerachFilterObj.Vendor_Order_Total_Recieved.Value1));
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Vendor_Ordering_Id)){    
                    filterLables.add(new FilterLabel('Vendor_Ordering_Id', 'ID', homeSerachFilterObj.Vendor_Ordering_Id));
                }
                
                if(homeSerachFilterObj.Vendor_Ordering_Total !=null && !String.isBlank(homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption) && homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption != '0'){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption) : homeSerachFilterObj.Vendor_Ordering_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Vendor_Ordering_Total', 'Total', homeSerachFilterObj.Vendor_Ordering_Total.Value1 + ' To ' + homeSerachFilterObj.Vendor_Ordering_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Vendor_Ordering_Total', 'Total', modifiedLabelName + ' ' + homeSerachFilterObj.Vendor_Ordering_Total.Value1));
                    }
                    //system.Assert(false,filterLables);
                }
                
                if(!String.isBlank(homeSerachFilterObj.Vendor_Ordering_Vendor)){
                    filterLables.add(new FilterLabel('Vendor_Ordering_Vendor', 'Vendor', homeSerachFilterObj.Vendor_Ordering_Vendor));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0'){
                    if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Account_Type__c> accountTypeList= [select Name from Account_Type__c where Id =: homeSerachFilterObj.Vendor_AccountType];
                    filterLables.add(new FilterLabel('Vendor_AccountType', 'Account Type', accountTypeList[0].Name));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Parts') || homeSerachFilterObj.Type.Objects.contains('Kits') || homeSerachFilterObj.Type.Objects.contains('Labor Codes') || homeSerachFilterObj.Type.Objects.contains('Fees') || homeSerachFilterObj.Type.Objects.contains('Vendor Product')){
                if(!String.isBlank(homeSerachFilterObj.Product_Item)) {
                    filterLables.add(new FilterLabel('Product_Item', 'Item', homeSerachFilterObj.Product_Item));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Description)){
                    filterLables.add(new FilterLabel('Product_Description', 'Description', homeSerachFilterObj.Product_Description));
                }
                if(!String.isBlank(homeSerachFilterObj.Product_Category) && homeSerachFilterObj.Product_Category != '0'){
                    if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Category__c> categoryList = [select Name from Category__c where Id =: homeSerachFilterObj.Product_Category];
                    filterLables.add(new FilterLabel('Product_Category', 'Category', categoryList[0].Name));
                }
                
                if(homeSerachFilterObj.Product_Price !=null && !String.isBlank(homeSerachFilterObj.Product_Price.SelectedOption)&& homeSerachFilterObj.Product_Price.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Product_Price.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Product_Price.SelectedOption) : homeSerachFilterObj.Product_Price.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Product_Price.Value1) && !String.isBlank(homeSerachFilterObj.Product_Price.Value2)) {
                        filterLables.add(new FilterLabel('Product_Price', 'Price', homeSerachFilterObj.Product_Price.Value1 + ' To ' + homeSerachFilterObj.Product_Price.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Product_Price.Value1)){
                        filterLables.add(new FilterLabel('Product_Price', 'Price', modifiedLabelName + ' ' + homeSerachFilterObj.Product_Price.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Type.Objects.contains('Vendor Product')) {
                    if(!String.isBlank(homeSerachFilterObj.Vendor_AccountType) && homeSerachFilterObj.Vendor_AccountType != '0'){
                        if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                        List<Account_Type__c> accountTypeList= [select Name from Account_Type__c where Id =: homeSerachFilterObj.Vendor_AccountType];
                        filterLables.add(new FilterLabel('Vendor_AccountType', 'Account Type', accountTypeList[0].Name));
                    }
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Technician Hours')) {
                if(!String.isBlank(homeSerachFilterObj.TechinicianHours_ItemType)){   
                    filterLables.add(new FilterLabel('TechinicianHours_ItemType', 'Item Type', homeSerachFilterObj.TechinicianHours_ItemType));
                }
                
                if(!String.isBlank(homeSerachFilterObj.TechinicianHours_Technician)) {
                    filterLables.add(new FilterLabel('TechinicianHours_Technician', 'Technician', homeSerachFilterObj.TechinicianHours_Technician));
                }
                if(homeSerachFilterObj.TechinicianHours_Date !=null && !String.isBlank(homeSerachFilterObj.TechinicianHours_Date.SelectedOption) && homeSerachFilterObj.TechinicianHours_Date.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.TechinicianHours_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.TechinicianHours_Date.SelectedOption) : homeSerachFilterObj.TechinicianHours_Date.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.TechinicianHours_Date.Value1) && !String.isBlank(homeSerachFilterObj.TechinicianHours_Date.Value2)) {
                        filterLables.add(new FilterLabel('TechinicianHours_Date', 'Clocked Date', homeSerachFilterObj.TechinicianHours_Date.Value1 + ' To ' + homeSerachFilterObj.TechinicianHours_Date.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('TechinicianHours_Date', 'Clocked Date', modifiedLabelName));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.TechinicianHours_JobType) && homeSerachFilterObj.TechinicianHours_JobType != '0'){   
                    String jobType;
                    if(homeSerachFilterObj.TechinicianHours_JobType == '1') {
                        jobType = 'Customer Pay';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '2') {
                        jobType = 'Third-Party';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '3') {
                        jobType = 'Internal';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '4') {
                        jobType = 'Deal';
                    } else if(homeSerachFilterObj.TechinicianHours_JobType == '5') {
                        jobType = 'Quote';
                    } 
                    filterLables.add(new FilterLabel('TechinicianHours_JobType', 'Job Type', jobType));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Customer)) {
                    filterLables.add(new FilterLabel('InvoicedItem_Customer', 'Customer', homeSerachFilterObj.InvoicedItem_Customer));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Payroll Hours')) {
                if(!String.isBlank(homeSerachFilterObj.Payroll_Employee)) {
                    filterLables.add(new FilterLabel('Payroll_Employee', 'Employee', homeSerachFilterObj.Payroll_Employee));
                }
                
                if(homeSerachFilterObj.Payroll_Date !=null && !String.isBlank(homeSerachFilterObj.Payroll_Date.SelectedOption) && homeSerachFilterObj.Payroll_Date.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Payroll_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Payroll_Date.SelectedOption) : homeSerachFilterObj.Payroll_Date.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Payroll_Date.Value1) && !String.isBlank(homeSerachFilterObj.Payroll_Date.Value2)) {
                        filterLables.add(new FilterLabel('Payroll_Date', 'Payroll Date', homeSerachFilterObj.Payroll_Date.Value1 + ' To ' + homeSerachFilterObj.Payroll_Date.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Payroll_Date', 'Payroll Date', modifiedLabelName));
                    }
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Parts')) {
                
                if(homeSerachFilterObj.Product_QtyAvailable !=null && !String.isBlank(homeSerachFilterObj.Product_QtyAvailable.SelectedOption) && homeSerachFilterObj.Product_QtyAvailable.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Product_QtyAvailable.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Product_QtyAvailable.SelectedOption) : homeSerachFilterObj.Product_QtyAvailable.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Product_QtyAvailable.Value1) && !String.isBlank(homeSerachFilterObj.Product_QtyAvailable.Value2)) {
                        filterLables.add(new FilterLabel('Product_QtyAvailable', 'Qty Available', homeSerachFilterObj.Product_QtyAvailable.Value1 + ' To ' + homeSerachFilterObj.Product_QtyAvailable.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Product_QtyAvailable.Value1)){
                        filterLables.add(new FilterLabel('Product_QtyAvailable', 'Qty Available', modifiedLabelName + ' ' + homeSerachFilterObj.Product_QtyAvailable.Value1));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_Location)) {
                    filterLables.add(new FilterLabel('Part_Location', 'Location', homeSerachFilterObj.Part_Location));
                }
                
                if(homeSerachFilterObj.Part_Cost !=null && !String.isBlank(homeSerachFilterObj.Part_Cost.SelectedOption) && homeSerachFilterObj.Part_Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_Cost.SelectedOption) : homeSerachFilterObj.Part_Cost.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_Cost.Value1) && !String.isBlank(homeSerachFilterObj.Part_Cost.Value2)) {
                        filterLables.add(new FilterLabel('Part_Cost', 'Cost', homeSerachFilterObj.Part_Cost.Value1 + ' To ' + homeSerachFilterObj.Part_Cost.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_Cost.Value1)){
                        filterLables.add(new FilterLabel('Part_Cost', 'Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Part_Cost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_AverageCost !=null && !String.isBlank(homeSerachFilterObj.Part_AverageCost.SelectedOption) && homeSerachFilterObj.Part_AverageCost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_AverageCost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_AverageCost.SelectedOption) : homeSerachFilterObj.Part_AverageCost.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_AverageCost.Value1) && !String.isBlank(homeSerachFilterObj.Part_AverageCost.Value2)) {
                        filterLables.add(new FilterLabel('Part_AverageCost', 'Average Cost', homeSerachFilterObj.Part_AverageCost.Value1 + ' To ' + homeSerachFilterObj.Part_AverageCost.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_AverageCost.Value1)){
                        filterLables.add(new FilterLabel('Part_AverageCost', 'Average Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Part_AverageCost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_InStock !=null && !String.isBlank(homeSerachFilterObj.Part_InStock.SelectedOption)&& homeSerachFilterObj.Part_InStock.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_InStock.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_InStock.SelectedOption) : homeSerachFilterObj.Part_InStock.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_InStock.Value1) && !String.isBlank(homeSerachFilterObj.Part_InStock.Value2)) {
                        filterLables.add(new FilterLabel('Part_InStock', 'In Stock', homeSerachFilterObj.Part_InStock.Value1 + ' To ' + homeSerachFilterObj.Part_InStock.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_InStock.Value1)){
                        filterLables.add(new FilterLabel('Part_InStock', 'In Stock', modifiedLabelName + ' ' + homeSerachFilterObj.Part_InStock.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_Committed !=null && !String.isBlank(homeSerachFilterObj.Part_Committed.SelectedOption) && homeSerachFilterObj.Part_Committed.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_Committed.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_Committed.SelectedOption) : homeSerachFilterObj.Part_Committed.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_Committed.Value1) && !String.isBlank(homeSerachFilterObj.Part_Committed.Value2)) {
                        filterLables.add(new FilterLabel('Part_Committed', 'Commited Qty', homeSerachFilterObj.Part_Committed.Value1 + ' To ' + homeSerachFilterObj.Part_Committed.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_Committed.Value1)){
                        filterLables.add(new FilterLabel('Part_Committed', 'Commited Qty', modifiedLabelName + ' ' + homeSerachFilterObj.Part_Committed.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_OnOrder !=null && !String.isBlank(homeSerachFilterObj.Part_OnOrder.SelectedOption) && homeSerachFilterObj.Part_OnOrder.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_OnOrder.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_OnOrder.SelectedOption) : homeSerachFilterObj.Part_OnOrder.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_Cost.Value1) && !String.isBlank(homeSerachFilterObj.Part_Cost.Value2)) {
                        filterLables.add(new FilterLabel('Part_OnOrder', 'On Order', homeSerachFilterObj.Part_OnOrder.Value1 + ' To ' + homeSerachFilterObj.Part_OnOrder.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_OnOrder.Value1)){
                        filterLables.add(new FilterLabel('Part_OnOrder', 'On Order', modifiedLabelName + ' ' + homeSerachFilterObj.Part_OnOrder.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_OversoldQty !=null && !String.isBlank(homeSerachFilterObj.Part_OversoldQty.SelectedOption) && homeSerachFilterObj.Part_OversoldQty.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_OversoldQty.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_OversoldQty.SelectedOption) : homeSerachFilterObj.Part_OversoldQty.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_Cost.Value1) && !String.isBlank(homeSerachFilterObj.Part_Cost.Value2)) {
                        filterLables.add(new FilterLabel('Part_OversoldQty', 'Oversold Qty', homeSerachFilterObj.Part_OversoldQty.Value1 + ' To ' + homeSerachFilterObj.Part_OversoldQty.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_OversoldQty.Value1)){
                        filterLables.add(new FilterLabel('Part_OversoldQty', 'Oversold Qty', modifiedLabelName + ' ' + homeSerachFilterObj.Part_OversoldQty.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_OversoldCost !=null && !String.isBlank(homeSerachFilterObj.Part_OversoldCost.SelectedOption) && homeSerachFilterObj.Part_OversoldCost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_OversoldCost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_OversoldCost.SelectedOption) : homeSerachFilterObj.Part_OversoldCost.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_OversoldCost.Value1) && !String.isBlank(homeSerachFilterObj.Part_OversoldCost.Value2)) {
                        filterLables.add(new FilterLabel('Part_OversoldCost', 'Oversold Cost', homeSerachFilterObj.Part_OversoldCost.Value1 + ' To ' + homeSerachFilterObj.Part_OversoldCost.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_OversoldCost.Value1)){
                        filterLables.add(new FilterLabel('Part_OversoldCost', 'Oversold Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Part_OversoldCost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD1Qty !=null && !String.isBlank(homeSerachFilterObj.Part_PRD1Qty.SelectedOption) && homeSerachFilterObj.Part_PRD1Qty.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD1Qty.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD1Qty.SelectedOption) : homeSerachFilterObj.Part_PRD1Qty.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD1Qty.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD1Qty.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD1Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD1') + 'Qty', homeSerachFilterObj.Part_PRD1Qty.Value1 + ' To ' + homeSerachFilterObj.Part_PRD1Qty.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD1Qty.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD1Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD1') + 'Qty', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD1Qty.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD1Cost !=null && !String.isBlank(homeSerachFilterObj.Part_PRD1Cost.SelectedOption) && homeSerachFilterObj.Part_PRD1Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD1Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD1Cost.SelectedOption) : homeSerachFilterObj.Part_PRD1Cost.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD1Cost.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD1Cost.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD1Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD1') + 'Cost', homeSerachFilterObj.Part_PRD1Cost.Value1 + ' To ' + homeSerachFilterObj.Part_PRD1Cost.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD1Cost.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD1Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD1') + 'Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD1Cost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD2Qty !=null && !String.isBlank(homeSerachFilterObj.Part_PRD2Qty.SelectedOption) && homeSerachFilterObj.Part_PRD2Qty.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD2Qty.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD2Qty.SelectedOption) : homeSerachFilterObj.Part_PRD2Qty.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD2Qty.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD2Qty.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD2Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD2') + 'Qty', homeSerachFilterObj.Part_PRD2Qty.Value1 + ' To ' + homeSerachFilterObj.Part_PRD2Qty.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD2Qty.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD2Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD2') + 'Qty', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD2Qty.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD2Cost !=null && !String.isBlank(homeSerachFilterObj.Part_PRD2Cost.SelectedOption) && homeSerachFilterObj.Part_PRD2Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD2Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD2Cost.SelectedOption) : homeSerachFilterObj.Part_PRD2Cost.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD2Cost.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD2Cost.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD2Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD2') + 'Cost', homeSerachFilterObj.Part_PRD2Cost.Value1 + ' To ' + homeSerachFilterObj.Part_PRD2Cost.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD2Cost.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD2Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD2') + 'Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD2Cost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD3Qty !=null && !String.isBlank(homeSerachFilterObj.Part_PRD3Qty.SelectedOption) && homeSerachFilterObj.Part_PRD3Qty.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD3Qty.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD3Qty.SelectedOption) : homeSerachFilterObj.Part_PRD3Qty.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD3Qty.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD3Qty.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD3Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD3') + 'Qty', homeSerachFilterObj.Part_PRD3Qty.Value1 + ' To ' + homeSerachFilterObj.Part_PRD3Qty.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD3Qty.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD3Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD3') + 'Qty', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD3Qty.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD3Cost !=null && !String.isBlank(homeSerachFilterObj.Part_PRD3Cost.SelectedOption) && homeSerachFilterObj.Part_PRD3Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD3Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD3Cost.SelectedOption) : homeSerachFilterObj.Part_PRD3Cost.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD3Cost.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD3Cost.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD3Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD3') + 'Cost', homeSerachFilterObj.Part_PRD3Cost.Value1 + ' To ' + homeSerachFilterObj.Part_PRD3Cost.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD3Cost.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD3Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD3') + 'Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD3Cost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD4Qty !=null && !String.isBlank(homeSerachFilterObj.Part_PRD4Qty.SelectedOption) && homeSerachFilterObj.Part_PRD4Qty.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD4Qty.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD4Qty.SelectedOption) : homeSerachFilterObj.Part_PRD4Qty.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD4Qty.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD4Qty.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD4Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD4') + 'Qty', homeSerachFilterObj.Part_PRD4Qty.Value1 + ' To ' + homeSerachFilterObj.Part_PRD4Qty.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD4Qty.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD4Qty', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD4') + 'Qty', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD4Qty.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_PRD4Cost !=null && !String.isBlank(homeSerachFilterObj.Part_PRD4Cost.SelectedOption) && homeSerachFilterObj.Part_PRD4Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_PRD4Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_PRD4Cost.SelectedOption) : homeSerachFilterObj.Part_PRD4Cost.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_PRD4Cost.Value1) && !String.isBlank(homeSerachFilterObj.Part_PRD4Cost.Value2)) {
                        filterLables.add(new FilterLabel('Part_PRD4Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD4') + 'Cost', homeSerachFilterObj.Part_PRD4Cost.Value1 + ' To ' + homeSerachFilterObj.Part_PRD4Cost.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Part_PRD4Cost.Value1)){
                        filterLables.add(new FilterLabel('Part_PRD4Cost', HomeSearchUtil.agingPeriodsToPeriodValueMap.get('PRD4') + 'Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Part_PRD4Cost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_LastCounted !=null && !String.isBlank(homeSerachFilterObj.Part_LastCounted.SelectedOption) && homeSerachFilterObj.Part_LastCounted.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Part_LastCounted.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Part_LastCounted.SelectedOption) : homeSerachFilterObj.Part_LastCounted.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_LastCounted.Value1) && !String.isBlank(homeSerachFilterObj.Part_LastCounted.Value2)) {
                        filterLables.add(new FilterLabel('Part_LastCounted', 'Last Count', homeSerachFilterObj.Part_LastCounted.Value1 + ' To ' + homeSerachFilterObj.Part_LastCounted.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Part_LastCounted', 'Last Count', modifiedLabelName));
                    }
                }
                
                if(homeSerachFilterObj.Part_LastSold !=null && !String.isBlank(homeSerachFilterObj.Part_LastSold.SelectedOption) && homeSerachFilterObj.Part_LastSold.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Part_LastSold.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Part_LastSold.SelectedOption) : homeSerachFilterObj.Part_LastSold.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_LastSold.Value1) && !String.isBlank(homeSerachFilterObj.Part_LastSold.Value2)) {
                        filterLables.add(new FilterLabel('Part_LastSold', 'Last Sold', homeSerachFilterObj.Part_LastSold.Value1 + ' To ' + homeSerachFilterObj.Part_LastSold.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Part_LastSold', 'Last Sold', modifiedLabelName));
                    }
                }
                
                if(homeSerachFilterObj.Part_LastStocked !=null && !String.isBlank(homeSerachFilterObj.Part_LastStocked.SelectedOption) && homeSerachFilterObj.Part_LastStocked.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Part_LastStocked.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Part_LastStocked.SelectedOption) : homeSerachFilterObj.Part_LastStocked.SelectedOption;
                    system.debug('$$$$$$$$$$$$$'+ modifiedLabelName);
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_LastStocked.Value1) && !String.isBlank(homeSerachFilterObj.Part_LastStocked.Value2)) {
                        filterLables.add(new FilterLabel('Part_LastStocked', 'Last Stock', homeSerachFilterObj.Part_LastStocked.Value1 + ' To ' + homeSerachFilterObj.Part_LastStocked.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Part_LastStocked', 'Last Stock', modifiedLabelName));
                    }
                      
                }
                
                if(homeSerachFilterObj.Part_ReorderAt !=null && !String.isBlank(homeSerachFilterObj.Part_ReorderAt.SelectedOption) && homeSerachFilterObj.Part_ReorderAt.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_ReorderAt.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_ReorderAt.SelectedOption) : homeSerachFilterObj.Part_ReorderAt.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_ReorderAt.Value1) && !String.isBlank(homeSerachFilterObj.Part_ReorderAt.Value2)) {
                        filterLables.add(new FilterLabel('Part_ReorderAt', 'Reorder At', homeSerachFilterObj.Part_ReorderAt.Value1 + ' To ' + homeSerachFilterObj.Part_ReorderAt.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Part_ReorderAt', 'Reorder At', modifiedLabelName + ' ' + homeSerachFilterObj.Part_ReorderAt.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Part_ReorderTo !=null && !String.isBlank(homeSerachFilterObj.Part_ReorderTo.SelectedOption) && homeSerachFilterObj.Part_ReorderTo.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Part_ReorderTo.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Part_ReorderTo.SelectedOption) : homeSerachFilterObj.Part_ReorderTo.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Part_ReorderTo.Value1) && !String.isBlank(homeSerachFilterObj.Part_ReorderTo.Value2)) {
                        filterLables.add(new FilterLabel('Part_ReorderTo', 'Reorder To', homeSerachFilterObj.Part_ReorderTo.Value1 + ' To ' + homeSerachFilterObj.Part_ReorderTo.Value2));
                    } else{
                        filterLables.add(new FilterLabel('Part_ReorderTo', 'Reorder To', modifiedLabelName + ' ' + homeSerachFilterObj.Part_ReorderTo.Value1));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_Vendor)) {
                    filterLables.add(new FilterLabel('Part_Vendor', 'Vendor', homeSerachFilterObj.Part_Vendor));
                }   
                
                if(!String.isBlank(homeSerachFilterObj.Part_PackagedPart) && homeSerachFilterObj.Part_PackagedPart != '0') {
                    if(homeSerachFilterObj.Part_PackagedPart == '1') {
                        filterLables.add(new FilterLabel('Part_PackagedPart', 'Packaged Part', 'Yes'));
                    } else if(homeSerachFilterObj.Part_PackagedPart == '2'){
                        filterLables.add(new FilterLabel('Part_PackagedPart', 'Packaged Part', 'No'));
                    }
                }
                
                
                // Start: Added by richa 29/11/2016
                if(!String.isBlank(homeSerachFilterObj.Part_MfgPart)) {
                    filterLables.add(new FilterLabel('Part_MfgPart', 'Mfg Part', homeSerachFilterObj.Part_MfgPart));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_SKUNumber)) {
                    filterLables.add(new FilterLabel('Part_SKUNumber', 'SKU', homeSerachFilterObj.Part_SKUNumber));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_NonInventory) && homeSerachFilterObj.Part_NonInventory != '0') {
                    if(homeSerachFilterObj.Part_NonInventory == '1') {
                        filterLables.add(new FilterLabel('Part_NonInventory', 'Non Inventory Part', 'Yes'));
                    } else if(homeSerachFilterObj.Part_NonInventory == '2'){
                        filterLables.add(new FilterLabel('Part_NonInventory', 'Non Inventory Part', 'No'));
                    }
                }
                
                if(homeSerachFilterObj.AssignedTags != null && homeSerachFilterObj.AssignedTags.size() > 0) {
                    filterLables.add(getTagsFilterLabel(homeSerachFilterObj.AssignedTags));
                }
                // End: Added by richa 29/11/2016
                if(!String.isBlank(homeSerachFilterObj.Part_Type) && homeSerachFilterObj.Part_Type != 'All') {
                    filterLables.add(new FilterLabel('Part_Type', 'Part Type', homeSerachFilterObj.Part_Type));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Parts Needed') && homeSerachFilterObj.Part_Type != 'All') {
                if(!String.isBlank(homeSerachFilterObj.Part_Type)) {
                    filterLables.add(new FilterLabel('Part_Type', 'Part Type', homeSerachFilterObj.Part_Type));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Kits')) {
                if(homeSerachFilterObj.Kit_FixedPrice == '1') {
                    filterLables.add(new FilterLabel('Kit_FixedPrice', 'Fixed Price', 'Yes'));
                } else if(homeSerachFilterObj.Kit_FixedPrice == '2'){
                    filterLables.add(new FilterLabel('Kit_FixedPrice', 'Fixed Price', 'No'));
                }
                
                if(homeSerachFilterObj.Kit_ServiceKit == '1') {
                    filterLables.add(new FilterLabel('Kit_ServiceKit', 'Service Part', 'Yes'));
                } else if(homeSerachFilterObj.Kit_ServiceKit == '2'){
                    filterLables.add(new FilterLabel('Kit_ServiceKit', 'Service Part', 'No'));
                }
                
                if(homeSerachFilterObj.Kit_KitPrice !=null && !String.isBlank(homeSerachFilterObj.Kit_KitPrice.SelectedOption) && homeSerachFilterObj.Kit_KitPrice.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Kit_KitPrice.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Kit_KitPrice.SelectedOption) : homeSerachFilterObj.Kit_KitPrice.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Kit_KitPrice.Value1) && !String.isBlank(homeSerachFilterObj.Kit_KitPrice.Value2)) {
                        filterLables.add(new FilterLabel('Kit_KitPrice', 'Kit Price', homeSerachFilterObj.Kit_KitPrice.Value1 + ' To ' + homeSerachFilterObj.Kit_KitPrice.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Kit_KitPrice', 'Kit Price', modifiedLabelName + ' ' + homeSerachFilterObj.Kit_KitPrice.Value1));
                    }
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Inventory Unit')) {
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_VIN)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_VIN', 'VIN', homeSerachFilterObj.Inventory_Unit_VIN));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Unit_Type) && homeSerachFilterObj.Inventory_Unit_Unit_Type != '0') { 
                    String unitType = (homeSerachFilterObj.Inventory_Unit_Unit_Type == 'ORDU') ? 'Order Unit' : 'Stock Unit';
                    filterLables.add(new FilterLabel('Inventory_Unit_Unit_Type', 'Unit Type', unitType));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Stock_Number)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Stock_Number', 'Stock Number', homeSerachFilterObj.Inventory_Unit_Stock_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Year)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Year', 'Year', homeSerachFilterObj.Inventory_Unit_Year));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Make) && homeSerachFilterObj.Inventory_Unit_Make != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Make', 'Make', homeSerachFilterObj.Inventory_Unit_Make));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Model) && homeSerachFilterObj.Inventory_Unit_Model != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Model', 'Model', homeSerachFilterObj.Inventory_Unit_Model));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_SubModel) && homeSerachFilterObj.Inventory_Unit_SubModel != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_SubModel', 'SubModel', homeSerachFilterObj.Inventory_Unit_SubModel));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Ext_Colour)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Ext_Colour', 'Ext Colour', homeSerachFilterObj.Inventory_Unit_Ext_Colour));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_New_Unit) && homeSerachFilterObj.Inventory_Unit_New_Unit != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_New_Unit', 'New Unit', homeSerachFilterObj.Inventory_Unit_New_Unit));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Base_Unit_Price.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Base_Unit_Price', 'Base Unit Price', homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Base_Unit_Price', 'Base Unit Price', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Factory_Options !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Factory_Options.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Factory_Options.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Factory_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Factory_Options.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Factory_Options.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Factory_Options.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Factory_Options.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Factory_Options', 'Factory Options', homeSerachFilterObj.Inventory_Unit_Factory_Options.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Factory_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Factory_Options', 'Factory Options', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Factory_Options.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Dealer_Options !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Dealer_Options.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Dealer_Options.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Dealer_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Dealer_Options.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Dealer_Options.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Dealer_Options.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Dealer_Options.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Dealer_Options', 'Dealer Options', homeSerachFilterObj.Inventory_Unit_Dealer_Options.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Dealer_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Dealer_Options', 'Dealer Options', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Dealer_Options.Value1));
                    }
                }
                if(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Base_Unit_Price.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Total_Price.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Total_Price.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Total_Price.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Total_Price.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Total_Price.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Total_Price.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Total_Price', 'Total Price', homeSerachFilterObj.Inventory_Unit_Total_Price.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Total_Price.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Total_Price', 'Total Price', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Total_Price.Value1));
                    }
                }  
                
                if(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Base_Unit_Cost', 'Base Unit Cost', homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Base_Unit_Cost', 'Base Unit Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Base_Unit_Cost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Factory_Option_Cost', 'Factory Option Cost', homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Factory_Option_Cost', 'Factory Option Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Factory_Option_Cost.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Dealer_Option_Cost', 'Dealer Option Cost', homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Dealer_Option_Cost', 'Dealer Option Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Dealer_Option_Cost.Value1));
                    }
                }  
                if(homeSerachFilterObj.Inventory_Unit_Total_Cost !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Total_Cost.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Total_Cost.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Total_Cost.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Total_Cost.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Total_Cost.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Total_Cost.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Total_Cost.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Total_Cost', 'Total Cost', homeSerachFilterObj.Inventory_Unit_Total_Cost.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Total_Cost.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Inventory_Unit_Total_Cost', 'Total Cost', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Total_Cost.Value1));
                    }
                }              
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Location)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Location', 'Location', homeSerachFilterObj.Inventory_Unit_Location));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Category)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Total_Price', 'Category', homeSerachFilterObj.Inventory_Unit_Category));
                }
                if(homeSerachFilterObj.Inventory_Unit_Stocked_In !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Stocked_In.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Stocked_In.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Inventory_Unit_Stocked_In.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Inventory_Unit_Stocked_In.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Stocked_In.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Stocked_In.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Stocked_In.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Stocked_In', 'Stocked', homeSerachFilterObj.Inventory_Unit_Stocked_In.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Stocked_In.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Inventory_Unit_Stocked_In', 'Stocked', modifiedLabelName));
                    }
                } 
                
                if(homeSerachFilterObj.Inventory_Unit_Age != null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Age.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Age.SelectedOption != '0'){   
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Age.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Age.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Age.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Age.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Age.Value2)) {
                       filterLables.add(new FilterLabel('Inventory_Unit_Age', 'Age', homeSerachFilterObj.Inventory_Unit_Age.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Age.Value2));
                   } else {
                       filterLables.add(new FilterLabel('Inventory_Unit_Age', 'Age', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Age.Value1));
                   }
                }
               
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Key_Number)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Key_Number', 'Key Number', homeSerachFilterObj.Inventory_Unit_Key_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Engine_Number)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Engine_Number', 'Engine Number', homeSerachFilterObj.Inventory_Unit_Engine_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Other_Number)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Other_Number', 'Other Number', homeSerachFilterObj.Inventory_Unit_Other_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Int_Colour)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Int_Colour', 'Int Colour', homeSerachFilterObj.Inventory_Unit_Int_Colour));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Stocked_Out !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Stocked_Out.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Stocked_Out.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Inventory_Unit_Stocked_Out.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Inventory_Unit_Stocked_Out.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Stocked_Out.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Stocked_Out.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Stocked_Out.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Stocked_Out', 'Stocked Out', homeSerachFilterObj.Inventory_Unit_Stocked_Out.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Stocked_Out.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Inventory_Unit_Stocked_Out', 'Stocked Out', modifiedLabelName));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Taxable) && homeSerachFilterObj.Inventory_Unit_Taxable != '0') {
                    filterLables.add(new FilterLabel('Inventory_Unit_Taxable', 'Taxable', homeSerachFilterObj.Inventory_Unit_Taxable));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Applicable_Tax) && homeSerachFilterObj.Inventory_Unit_Taxable != '0') {
                    filterLables.add(new FilterLabel('Inventory_Unit_Applicable_Tax', 'Applicable Tax', homeSerachFilterObj.Inventory_Unit_Applicable_Tax));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Cylinders !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Cylinders.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Cylinders.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Cylinders.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Cylinders.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Cylinders.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Cylinders.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Cylinders.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Cylinders', 'Cylinder', homeSerachFilterObj.Inventory_Unit_Cylinders.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Cylinders.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Cylinders.Value1)){
                        filterLables.add(new FilterLabel('Inventory_Unit_Cylinders', 'Cylinder', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Cylinders.Value1));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Automatic) && homeSerachFilterObj.Inventory_Unit_Automatic != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Automatic', 'Automatic', homeSerachFilterObj.Inventory_Unit_Automatic));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Manufactured_Date !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Manufactured_Date.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Manufactured_Date.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Inventory_Unit_Manufactured_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Inventory_Unit_Manufactured_Date.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Manufactured_Date.SelectedOption;
                    if( modifiedLabelName == '5'  && !String.isBlank(HomeSerachFilterObj.Inventory_Unit_Manufactured_Date.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Manufactured_Date.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Manufactured_Date', 'Manufactured Date', homeSerachFilterObj.Inventory_Unit_Manufactured_Date.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Manufactured_Date.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Inventory_Unit_Manufactured_Date', 'Manufactured Date', modifiedLabelName));
                    }
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Mileage !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Mileage.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Mileage.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Inventory_Unit_Mileage.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Inventory_Unit_Mileage.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Mileage.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Mileage.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Mileage.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Mileage', 'Mileage', homeSerachFilterObj.Inventory_Unit_Mileage.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Mileage.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Mileage.Value1)){
                        filterLables.add(new FilterLabel('Inventory_Unit_Mileage', 'Mileage', modifiedLabelName + ' ' + homeSerachFilterObj.Inventory_Unit_Mileage.Value1));
                    }
                }
                               
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Plate_Number)){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Plate_Number', 'Plate Number', homeSerachFilterObj.Inventory_Unit_Plate_Number));
                }
                
                if(homeSerachFilterObj.Inventory_Unit_Reg_Expiry !=null && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Reg_Expiry.SelectedOption) && homeSerachFilterObj.Inventory_Unit_Reg_Expiry.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Inventory_Unit_Reg_Expiry.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Inventory_Unit_Reg_Expiry.SelectedOption) : homeSerachFilterObj.Inventory_Unit_Reg_Expiry.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Reg_Expiry.Value1) && !String.isBlank(homeSerachFilterObj.Inventory_Unit_Reg_Expiry.Value2)) {
                        filterLables.add(new FilterLabel('Inventory_Unit_Reg_Expiry', 'Reg Expiry', homeSerachFilterObj.Inventory_Unit_Reg_Expiry.Value1 + ' To ' + homeSerachFilterObj.Inventory_Unit_Reg_Expiry.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Inventory_Unit_Reg_Expiry', 'Reg Expiry', modifiedLabelName));
                    }
                }
                
                if(homeSerachFilterObj.AssignedTags != null && homeSerachFilterObj.AssignedTags.size() > 0) {
                    filterLables.add(getTagsFilterLabel(homeSerachFilterObj.AssignedTags));
                }
				
				if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Compliance_Date) && homeSerachFilterObj.Inventory_Unit_Compliance_Date != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Compliance_Date', 'Compliance Date', homeSerachFilterObj.Inventory_Unit_Compliance_Date));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Year_Of_1st_Rego) && homeSerachFilterObj.Inventory_Unit_Year_Of_1st_Rego != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Year_Of_1st_Rego', 'Year of 1st Rego', homeSerachFilterObj.Inventory_Unit_Year_Of_1st_Rego));
                }
                if(!String.isBlank(homeSerachFilterObj.Inventory_Unit_Registration_Serial) && homeSerachFilterObj.Inventory_Unit_Registration_Serial != '0'){   
                    filterLables.add(new FilterLabel('Inventory_Unit_Registration_Serial', 'Registration Serial#', homeSerachFilterObj.Inventory_Unit_Registration_Serial));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Customer Unit')) {               
                if(homeSerachFilterObj.Customer_Unit_Reg_Expiry != null && !String.isBlank(homeSerachFilterObj.Customer_Unit_Reg_Expiry.SelectedOption) && homeSerachFilterObj.Customer_Unit_Reg_Expiry.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Customer_Unit_Reg_Expiry.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Customer_Unit_Reg_Expiry.SelectedOption) : homeSerachFilterObj.Customer_Unit_Reg_Expiry.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Customer_Unit_Reg_Expiry.Value1) && !String.isBlank(homeSerachFilterObj.Customer_Unit_Reg_Expiry.Value2)) {
                        filterLables.add(new FilterLabel('Customer_Unit_Reg_Expiry', 'Reg Expiry', homeSerachFilterObj.Customer_Unit_Reg_Expiry.Value1 + ' To ' + homeSerachFilterObj.Customer_Unit_Reg_Expiry.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Customer_Unit_Reg_Expiry', 'Reg Expiry', modifiedLabelName));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Unit_ID) && homeSerachFilterObj.Customer_Unit_Unit_ID != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Unit_ID', 'Unit ID', homeSerachFilterObj.Customer_Unit_Unit_ID));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Customer) && homeSerachFilterObj.Customer_Unit_Customer != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Customer', 'Customer', homeSerachFilterObj.Customer_Unit_Customer));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Year) && homeSerachFilterObj.Customer_Unit_Year != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Year', 'Year', homeSerachFilterObj.Customer_Unit_Year));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Make) && homeSerachFilterObj.Customer_Unit_Make != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Make', 'Make', homeSerachFilterObj.Customer_Unit_Make));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Model) && homeSerachFilterObj.Customer_Unit_Model != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Model', 'Model', homeSerachFilterObj.Customer_Unit_Model));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_SubModel) && homeSerachFilterObj.Customer_Unit_SubModel != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_SubModel', 'SubModel', homeSerachFilterObj.Customer_Unit_SubModel));
                }
                if(homeSerachFilterObj.Customer_Unit_Mileage !=null && !String.isBlank(homeSerachFilterObj.Customer_Unit_Mileage.SelectedOption) && homeSerachFilterObj.Customer_Unit_Mileage.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Customer_Unit_Mileage.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Customer_Unit_Mileage.SelectedOption) : homeSerachFilterObj.Customer_Unit_Mileage.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Customer_Unit_Mileage.Value1) && !String.isBlank(homeSerachFilterObj.Customer_Unit_Mileage.Value2)) {
                        filterLables.add(new FilterLabel('Customer_Unit_Mileage', 'Mileage', homeSerachFilterObj.Customer_Unit_Mileage.Value1 + ' To ' + homeSerachFilterObj.Customer_Unit_Mileage.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Mileage.Value1)){
                        filterLables.add(new FilterLabel('Customer_Unit_Mileage', 'Mileage', modifiedLabelName + ' ' + homeSerachFilterObj.Customer_Unit_Mileage.Value1));
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_VIN) && homeSerachFilterObj.Customer_Unit_VIN != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_VIN', 'VIN', homeSerachFilterObj.Customer_Unit_VIN));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Plate_Number) && homeSerachFilterObj.Customer_Unit_Plate_Number != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Plate_Number', 'Plate Number', homeSerachFilterObj.Customer_Unit_Plate_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Key_Number) && homeSerachFilterObj.Customer_Unit_Key_Number != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Key_Number', 'Key Number', homeSerachFilterObj.Customer_Unit_Key_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Engine_Number) && homeSerachFilterObj.Customer_Unit_Engine_Number != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Engine_Number', 'Engine Number', homeSerachFilterObj.Customer_Unit_Engine_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Other_Number) && homeSerachFilterObj.Customer_Unit_Other_Number != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Other_Number', 'Other Number', homeSerachFilterObj.Customer_Unit_Other_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Ext_Colour) && homeSerachFilterObj.Customer_Unit_Ext_Colour != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Ext_Colour', 'Ext Colour', homeSerachFilterObj.Customer_Unit_Ext_Colour));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Int_Colour) && homeSerachFilterObj.Customer_Unit_Int_Colour != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Int_Colour', 'Int Colour', homeSerachFilterObj.Customer_Unit_Int_Colour));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Compliance_Date) && homeSerachFilterObj.Customer_Unit_Compliance_Date != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Compliance_Date', 'Compliance Date', homeSerachFilterObj.Customer_Unit_Compliance_Date));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Year_Of_1st_Rego) && homeSerachFilterObj.Customer_Unit_Year_Of_1st_Rego != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Year_Of_1st_Rego', 'Year of 1st Rego', homeSerachFilterObj.Customer_Unit_Year_Of_1st_Rego));
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_Unit_Registration_Serial) && homeSerachFilterObj.Customer_Unit_Registration_Serial != '0'){   
                    filterLables.add(new FilterLabel('Customer_Unit_Registration_Serial', 'Registration Serial#', homeSerachFilterObj.Customer_Unit_Registration_Serial));  
                }
                if(homeSerachFilterObj.Customer_Unit_Manufactured_Date !=null && !String.isBlank(homeSerachFilterObj.Customer_Unit_Manufactured_Date.SelectedOption) && homeSerachFilterObj.Customer_Unit_Manufactured_Date.SelectedOption != '0') {
					String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Customer_Unit_Manufactured_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Customer_Unit_Manufactured_Date.SelectedOption) : homeSerachFilterObj.Customer_Unit_Manufactured_Date.SelectedOption;
					if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Customer_Unit_Manufactured_Date.Value1) && !String.isBlank(homeSerachFilterObj.Customer_Unit_Manufactured_Date.Value2)) {
						filterLables.add(new FilterLabel('Customer_Unit_Manufactured_Date', 'Manufactured Date', homeSerachFilterObj.Customer_Unit_Manufactured_Date.Value1 + ' To ' + homeSerachFilterObj.Customer_Unit_Manufactured_Date.Value2));
					} else if(modifiedLabelName != '5'){
						filterLables.add(new FilterLabel('Customer_Unit_Manufactured_Date', 'Manufactured Date', modifiedLabelName));
					}
                }
                if(homeSerachFilterObj.AssignedTags != null && homeSerachFilterObj.AssignedTags.size() > 0) {
                    filterLables.add(getTagsFilterLabel(homeSerachFilterObj.AssignedTags));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0'){
                    if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Account_Type__c> accountTypeList= [select Name from Account_Type__c where Id =: homeSerachFilterObj.Customer_AccountType];
                    filterLables.add(new FilterLabel('Customer_AccountType', 'Account Type', accountTypeList[0].Name));
            }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Service Jobs')) {
                if(homeSerachFilterObj.Service_Job_Scheduled !=null && !String.isBlank(homeSerachFilterObj.Service_Job_Scheduled.SelectedOption) && homeSerachFilterObj.Service_Job_Scheduled.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Service_Job_Scheduled.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Service_Job_Scheduled.SelectedOption) : homeSerachFilterObj.Service_Job_Scheduled.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Service_Job_Scheduled.Value1) && !String.isBlank(homeSerachFilterObj.Service_Job_Scheduled.Value2)) {
                        filterLables.add(new FilterLabel('Service_Job_Scheduled', 'Scheduled', homeSerachFilterObj.Service_Job_Scheduled.Value1 + ' To ' + homeSerachFilterObj.Service_Job_Scheduled.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Service_Job_Scheduled', 'Scheduled', modifiedLabelName));
                    }
                }
                
                if(String.isNotBlank(homeSerachFilterObj.Service_Job_Job_Type) && homeSerachFilterObj.Service_Job_Job_Type != '0') {
                    filterLables.add(new FilterLabel('Service_Job_Job_Type', 'Job Type', homeSerachFilterObj.Service_Job_Job_Type));
                } else if(String.isNotBlank(homeSerachFilterObj.Service_Job_TransactionType)) {
                    filterLables.add(new FilterLabel('Service_Job_TransactionType', 'Type', homeSerachFilterObj.Service_Job_TransactionType));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Service_Job_VIN) && homeSerachFilterObj.Service_Job_VIN != '0') {   
                    filterLables.add(new FilterLabel('Service_Job_VIN','VIN',homeSerachFilterObj.Service_Job_VIN));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Service_Job_Plate_Number) && homeSerachFilterObj.Service_Job_Plate_Number != '0') {   
                    filterLables.add(new FilterLabel('Service_Job_Plate_Number','Plate Number',homeSerachFilterObj.Service_Job_Plate_Number));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Vendor Product')) {
                String productType;
                if(homeSerachFilterObj.Product_Type == '1') {
                    productType = Constants.DEAL_PRODUCT;
                    filterLables.add(new FilterLabel('Product_Type', 'Product Type', productType));
                } else if(homeSerachFilterObj.Product_Type == '2'){
                    productType = Constants.FINANCING_PRODUCT;
                    filterLables.add(new FilterLabel('Product_Type', 'Product Type', productType));
                } else if(homeSerachFilterObj.Product_Type == '3'){
                    productType = Constants.SUBLET;
                    filterLables.add(new FilterLabel('Product_Type', 'Product Type', productType));
                } else if(homeSerachFilterObj.Product_Type == '4'){
                    productType = Constants.WARRANTY_PLAN;
                    filterLables.add(new FilterLabel('Product_Type', 'Product Type', productType));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Technician Performance')) {
                if(!String.isBlank(homeSerachFilterObj.TechinicianPerformance_Technician)) {
                    filterLables.add(new FilterLabel('TechinicianPerformance_Technician', 'Technician', homeSerachFilterObj.TechinicianPerformance_Technician));
                }
                
                if(homeSerachFilterObj.TechinicianPerformance_Date !=null && !String.isBlank(homeSerachFilterObj.TechinicianPerformance_Date.SelectedOption) && homeSerachFilterObj.TechinicianPerformance_Date.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.TechinicianPerformance_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.TechinicianPerformance_Date.SelectedOption) : homeSerachFilterObj.TechinicianPerformance_Date.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.TechinicianPerformance_Date.Value1) && !String.isBlank(homeSerachFilterObj.TechinicianPerformance_Date.Value2)) {
                        filterLables.add(new FilterLabel('TechinicianPerformance_Date', 'Date', homeSerachFilterObj.TechinicianPerformance_Date.Value1 + ' To ' + homeSerachFilterObj.TechinicianPerformance_Date.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('TechinicianPerformance_Date', 'Date', modifiedLabelName));
                    }
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Invoiced Items') || homeSerachFilterObj.Type.Objects.contains('SOLI') || homeSerachFilterObj.Type.Objects.contains('Option and Fee')) {
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Type)){   
                    filterLables.add(new FilterLabel('InvoicedItem_Type', 'Item Type', homeSerachFilterObj.InvoicedItem_Type));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Item)){
                    filterLables.add(new FilterLabel('InvoicedItem_Item', 'Item', homeSerachFilterObj.InvoicedItem_Item));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Customer)){
                    filterLables.add(new FilterLabel('InvoicedItem_Customer', 'Customer', homeSerachFilterObj.InvoicedItem_Customer));
                }
                
                if(homeSerachFilterObj.InvoicedItem_InvoiceDate !=null && !String.isBlank(homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption) && homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption) : homeSerachFilterObj.InvoicedItem_InvoiceDate.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.InvoicedItem_InvoiceDate.Value1) && !String.isBlank(homeSerachFilterObj.InvoicedItem_InvoiceDate.Value2)) {
                        filterLables.add(new FilterLabel('InvoicedItem_InvoiceDate', 'Invoice Date', homeSerachFilterObj.InvoicedItem_InvoiceDate.Value1 + ' To ' + homeSerachFilterObj.InvoicedItem_InvoiceDate.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('InvoicedItem_InvoiceDate', 'Invoice Date', modifiedLabelName));
                    }
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Category)){
                    filterLables.add(new FilterLabel('InvoicedItem_Category', 'Category', homeSerachFilterObj.InvoicedItem_Category));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_InvoicedBy)){
                    filterLables.add(new FilterLabel('InvoicedItem_InvoicedBy', 'Invoiced by', homeSerachFilterObj.InvoicedItem_InvoicedBy));
                }
                
                if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Vendor)){
                    filterLables.add(new FilterLabel('InvoicedItem_Vendor', 'Vendor', homeSerachFilterObj.InvoicedItem_Vendor));
                }
                
                if(homeSerachFilterObj.InvoicedItem_Quantity !=null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption)&& homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption) : homeSerachFilterObj.InvoicedItem_Quantity.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.InvoicedItem_Quantity.Value1) && !String.isBlank(homeSerachFilterObj.InvoicedItem_Quantity.Value2)) {
                        filterLables.add(new FilterLabel('InvoicedItem_Quantity', 'Quantity', homeSerachFilterObj.InvoicedItem_Quantity.Value1 + ' To ' + homeSerachFilterObj.InvoicedItem_Quantity.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.InvoicedItem_Quantity.Value1)){
                        filterLables.add(new FilterLabel('InvoicedItem_Quantity', 'Quantity', modifiedLabelName + ' ' + homeSerachFilterObj.InvoicedItem_Quantity.Value1));
                    }
                }
                
                if(homeSerachFilterObj.InvoicedItem_Revenue !=null && !String.isBlank(homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption) && homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption) : homeSerachFilterObj.InvoicedItem_Revenue.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('InvoicedItem_Revenue', 'Revenue', homeSerachFilterObj.InvoicedItem_Revenue.Value1 + ' To ' + homeSerachFilterObj.InvoicedItem_Revenue.Value2));
                    } else {
                        filterLables.add(new FilterLabel('InvoicedItem_Revenue', 'Revenue', modifiedLabelName + ' ' + homeSerachFilterObj.InvoicedItem_Revenue.Value1));
                    }
                }

                if(homeSerachFilterObj.IsSummaryFormat !=null && homeSerachFilterObj.IsSummaryFormat) {
                    filterLables.add(new FilterLabel('IsSummaryFormat', '', 'Summary Format'));
                }
                
                if(!String.isBlank(homeSerachFilterObj.Part_Type) && homeSerachFilterObj.Part_Type != 'All') {
                    filterLables.add(new FilterLabel('Part_Type', 'Part Type', homeSerachFilterObj.Part_Type));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Part FIFO')) {
                if(homeSerachFilterObj.Part_FIFO_Date !=null && String.isNotBlank(homeSerachFilterObj.Part_FIFO_Date.SelectedOption) && homeSerachFilterObj.Part_FIFO_Date.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Part_FIFO_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Part_FIFO_Date.SelectedOption) : homeSerachFilterObj.Part_FIFO_Date.SelectedOption;
                    if(modifiedLabelName == '5' && String.isNotBlank(homeSerachFilterObj.Part_FIFO_Date.Value1) && String.isNotBlank(homeSerachFilterObj.Part_FIFO_Date.Value2)) {
                        filterLables.add(new FilterLabel('Part_FIFO_Date', 'Date', homeSerachFilterObj.Part_FIFO_Date.Value1 + ' To ' + homeSerachFilterObj.Part_FIFO_Date.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Part_FIFO_Date', 'Date', modifiedLabelName));
                    }
                }
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Category) && homeSerachFilterObj.Part_FIFO_Category != '0'){
                    if(AccessControl.ifObjectFieldIsAccessible('Category__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Category__c> categoryList = [select Name from Category__c where Id =: homeSerachFilterObj.Part_FIFO_Category];
                    filterLables.add(new FilterLabel('Part_FIFO_Category', 'Category', categoryList[0].Name));
                }
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Vendor)){
                    filterLables.add(new FilterLabel('Part_FIFO_Vendor', 'Vendor', homeSerachFilterObj.Part_FIFO_Vendor));
                }
                if(String.isNotBlank(homeSerachFilterObj.Part_FIFO_Part_Type) && homeSerachFilterObj.Part_FIFO_Part_Type != '0') {
                    filterLables.add(new FilterLabel('Part_FIFO_Part_Type', 'Part Type', homeSerachFilterObj.Part_FIFO_Part_Type));
                }
            }
            
            if(homeSerachFilterObj.Type.Objects.contains('Tax Detail')) {
                if(String.isNotBlank(homeSerachFilterObj.Tax_Detail_Invoice_Type) && homeSerachFilterObj.Tax_Detail_Invoice_Type != '0') {
                    filterLables.add(new FilterLabel('Tax_Detail_Invoice_Type', 'Invoice Type', homeSerachFilterObj.Tax_Detail_Invoice_Type));
                }
                if(homeSerachFilterObj.Tax_Detail_Invoice_Date != null && String.isNotBlank(homeSerachFilterObj.Tax_Detail_Invoice_Date.SelectedOption) && homeSerachFilterObj.Tax_Detail_Invoice_Date.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Tax_Detail_Invoice_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Tax_Detail_Invoice_Date.SelectedOption) : homeSerachFilterObj.Tax_Detail_Invoice_Date.SelectedOption;
                    if(modifiedLabelName == '5' && String.isNotBlank(homeSerachFilterObj.Tax_Detail_Invoice_Date.Value1) && String.isNotBlank(homeSerachFilterObj.Tax_Detail_Invoice_Date.Value2)) {
                        filterLables.add(new FilterLabel('Tax_Detail_Invoice_Date', 'Invoice Date', homeSerachFilterObj.Tax_Detail_Invoice_Date.Value1 + ' To ' + homeSerachFilterObj.Tax_Detail_Invoice_Date.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Tax_Detail_Invoice_Date', 'Invoice Date', modifiedLabelName));
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Customer_AccountType) && homeSerachFilterObj.Customer_AccountType != '0'){
                    if(AccessControl.ifObjectFieldIsAccessible('Account_Type__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
                    List<Account_Type__c> accountTypeList= [select Name from Account_Type__c where Id =: homeSerachFilterObj.Customer_AccountType];
                    filterLables.add(new FilterLabel('Customer_AccountType', 'Account Type', accountTypeList[0].Name));
                }
            }
            if(homeSerachFilterObj.Type.Objects.contains('Deal Units')) {
                if(homeSerachFilterObj.Deal_Units_Base_Price !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Base_Price.SelectedOption) && homeSerachFilterObj.Deal_Units_Base_Price.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Base_Price.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Base_Price.SelectedOption) : homeSerachFilterObj.Deal_Units_Base_Price.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Base_Price', 'Base Price', homeSerachFilterObj.Deal_Units_Base_Price.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Base_Price.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Base_Price', 'Base Price', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Base_Price.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Factory_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Factory_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Factory_Options.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Factory_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Factory_Options.SelectedOption) : homeSerachFilterObj.Deal_Units_Factory_Options.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Factory_Options', 'Factory Options', homeSerachFilterObj.Deal_Units_Factory_Options.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Factory_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Factory_Options', 'Factory Options', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Factory_Options.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Dealer_Installed !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Dealer_Installed.SelectedOption) && homeSerachFilterObj.Deal_Units_Dealer_Installed.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Dealer_Installed.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Dealer_Installed.SelectedOption) : homeSerachFilterObj.Deal_Units_Dealer_Installed.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Dealer_Installed', 'Dealer Installed', homeSerachFilterObj.Deal_Units_Dealer_Installed.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Dealer_Installed.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Dealer_Installed', 'Dealer Installed', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Dealer_Installed.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Part_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Part_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Part_Options.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Part_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Part_Options.SelectedOption) : homeSerachFilterObj.Deal_Units_Part_Options.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Part_Options', 'Part Options', homeSerachFilterObj.Deal_Units_Part_Options.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Part_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Part_Options', 'Part Options', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Part_Options.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Labor_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Labor_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Labor_Options.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Labor_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Labor_Options.SelectedOption) : homeSerachFilterObj.Deal_Units_Labor_Options.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Labor_Options', 'Labor Options', homeSerachFilterObj.Deal_Units_Labor_Options.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Labor_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Labor_Options', 'Labor Options', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Labor_Options.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Sublet_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Sublet_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Sublet_Options.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Sublet_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Sublet_Options.SelectedOption) : homeSerachFilterObj.Deal_Units_Sublet_Options.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Sublet_Options', 'Sublet Options', homeSerachFilterObj.Deal_Units_Sublet_Options.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Sublet_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Sublet_Options', 'Sublet Options', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Sublet_Options.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Fee_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Fee_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Fee_Options.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Fee_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Fee_Options.SelectedOption) : homeSerachFilterObj.Deal_Units_Fee_Options.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Fee_Options', 'Fee Options', homeSerachFilterObj.Deal_Units_Fee_Options.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Fee_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Fee_Options', 'Fee Options', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Fee_Options.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Warranty_Options !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Warranty_Options.SelectedOption) && homeSerachFilterObj.Deal_Units_Warranty_Options.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Warranty_Options.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Warranty_Options.SelectedOption) : homeSerachFilterObj.Deal_Units_Warranty_Options.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Warranty_Options', 'Warranty Options', homeSerachFilterObj.Deal_Units_Warranty_Options.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Warranty_Options.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Warranty_Options', 'Warranty Options', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Warranty_Options.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Other_Products !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Other_Products.SelectedOption) && homeSerachFilterObj.Deal_Units_Other_Products.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Other_Products.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Other_Products.SelectedOption) : homeSerachFilterObj.Deal_Units_Other_Products.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Other_Products', 'Other Products', homeSerachFilterObj.Deal_Units_Other_Products.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Other_Products.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Other_Products', 'Other Products', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Other_Products.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Stamp_Duty !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Stamp_Duty.SelectedOption) && homeSerachFilterObj.Deal_Units_Stamp_Duty.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Stamp_Duty.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Stamp_Duty.SelectedOption) : homeSerachFilterObj.Deal_Units_Stamp_Duty.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Stamp_Duty', 'Stamp Duty', homeSerachFilterObj.Deal_Units_Stamp_Duty.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Stamp_Duty.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Stamp_Duty', 'Stamp Duty', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Stamp_Duty.Value1));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Total_Price !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Total_Price.SelectedOption) && homeSerachFilterObj.Deal_Units_Total_Price.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Total_Price.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Total_Price.SelectedOption) : homeSerachFilterObj.Deal_Units_Total_Price.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Total_Price', 'Total Price', homeSerachFilterObj.Deal_Units_Total_Price.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Total_Price.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Deal_Units_Total_Price', 'Total Price', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Total_Price.Value1));
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_VIN)) {
                    filterLables.add(new FilterLabel('Deal_Units_VIN', 'VIN', homeSerachFilterObj.Deal_Units_VIN));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Category)) {
                    filterLables.add(new FilterLabel('Deal_Units_Category', 'Category', homeSerachFilterObj.Deal_Units_Category));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Mileage_Type)) {
                    filterLables.add(new FilterLabel('Deal_Units_Mileage_Type', 'Mileage Type', homeSerachFilterObj.Deal_Units_Mileage_Type));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Ext_Color)) {
                    filterLables.add(new FilterLabel('Deal_Units_Ext_Color', 'Ext Color', homeSerachFilterObj.Deal_Units_Ext_Color));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Int_Color)) {
                    filterLables.add(new FilterLabel('Deal_Units_Int_Color', 'Int Color', homeSerachFilterObj.Deal_Units_Int_Color));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Model)) {
                    filterLables.add(new FilterLabel('Deal_Units_Model', 'Model', homeSerachFilterObj.Deal_Units_Model));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Submodel)) {
                    filterLables.add(new FilterLabel('Deal_Units_Submodel', 'Submodel', homeSerachFilterObj.Deal_Units_Submodel));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Make)) {
                    filterLables.add(new FilterLabel('Deal_Units_Make', 'Make', homeSerachFilterObj.Deal_Units_Make));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Stock_Number)) {
                    filterLables.add(new FilterLabel('Deal_Units_Stock_Number', 'Stock Number', homeSerachFilterObj.Deal_Units_Stock_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Order_Number)) {
                    filterLables.add(new FilterLabel('Deal_Units_Order_Number', 'Order Number', homeSerachFilterObj.Deal_Units_Order_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Deal_Customer)) {
                    filterLables.add(new FilterLabel('Deal_Units_Deal_Customer', 'Customer', homeSerachFilterObj.Deal_Units_Deal_Customer));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Year)){   
                    filterLables.add(new FilterLabel('Deal_Units_Year', 'Year', homeSerachFilterObj.Deal_Units_Year));
                }
                if(homeSerachFilterObj.Deal_Units_Date_Sold !=null && String.isNotBlank(homeSerachFilterObj.Deal_Units_Date_Sold.SelectedOption) && homeSerachFilterObj.Deal_Units_Date_Sold.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Deal_Units_Date_Sold.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Deal_Units_Date_Sold.SelectedOption) : homeSerachFilterObj.Deal_Units_Date_Sold.SelectedOption;
                    if(modifiedLabelName == '5' && String.isNotBlank(homeSerachFilterObj.Deal_Units_Date_Sold.Value1) && String.isNotBlank(homeSerachFilterObj.Deal_Units_Date_Sold.Value2)) {
                        filterLables.add(new FilterLabel('Deal_Units_Date_Sold', 'Date Sold', homeSerachFilterObj.Deal_Units_Date_Sold.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Date_Sold.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Date_Sold', 'Date Sold', modifiedLabelName));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Stocked_In !=null && String.isNotBlank(homeSerachFilterObj.Deal_Units_Stocked_In.SelectedOption) && homeSerachFilterObj.Deal_Units_Stocked_In.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Deal_Units_Stocked_In.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Deal_Units_Stocked_In.SelectedOption) : homeSerachFilterObj.Deal_Units_Stocked_In.SelectedOption;
                    if(modifiedLabelName == '5' && String.isNotBlank(homeSerachFilterObj.Deal_Units_Stocked_In.Value1) && String.isNotBlank(homeSerachFilterObj.Deal_Units_Stocked_In.Value2)) {
                        filterLables.add(new FilterLabel('Deal_Units_Stocked_In', 'Stocked In', homeSerachFilterObj.Deal_Units_Stocked_In.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Stocked_In.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Deal_Units_Stocked_In', 'Stocked In', modifiedLabelName));
                    }
                }
                if(homeSerachFilterObj.Deal_Units_Age !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Age.SelectedOption)&& homeSerachFilterObj.Deal_Units_Age.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Deal_Units_Age.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Deal_Units_Age.SelectedOption) : homeSerachFilterObj.Deal_Units_Age.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Deal_Units_Age.Value1) && !String.isBlank(homeSerachFilterObj.Deal_Units_Age.Value2)) {
                        filterLables.add(new FilterLabel('Deal_Units_Age', 'Age', homeSerachFilterObj.Deal_Units_Age.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Age.Value2));
                    } else if(!String.isBlank(homeSerachFilterObj.Deal_Units_Age.Value1)){
                        filterLables.add(new FilterLabel('Deal_Units_Age', 'Age', modifiedLabelName + ' ' + homeSerachFilterObj.Deal_Units_Age.Value1));
                    }
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Deal_Type) && homeSerachFilterObj.Deal_Units_Deal_Type != '0') {
                    String dealType;
                    if(homeSerachFilterObj.Deal_Units_Deal_Type == '1') {
                        dealType = Constants.CASH_DEAL;
                    } else if(homeSerachFilterObj.Deal_Units_Deal_Type == '2') {
                        dealType = Constants.FINANCED;
                    }
                    filterLables.add(new FilterLabel('Deal_Units_Deal_Type', 'Deal Type', dealType));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_New_Unit) && homeSerachFilterObj.Deal_Units_New_Unit != '0'){   
                    filterLables.add(new FilterLabel('Deal_Units_New_Unit', 'New Unit', homeSerachFilterObj.Deal_Units_New_Unit));
                }
                if(homeSerachFilterObj.AssignedTags != null && homeSerachFilterObj.AssignedTags.size() > 0) {
					filterLables.add(getTagsFilterLabel(homeSerachFilterObj.AssignedTags));
            	}
            	if(homeSerachFilterObj.Include_Quotes != null && homeSerachFilterObj.Include_Quotes) {
                    filterLables.add(new FilterLabel('Include_Quotes', '', 'Include Quotes'));
            	}
		if(!String.isBlank(homeSerachFilterObj.Deal_Units_Compliance_Date) && homeSerachFilterObj.Deal_Units_Compliance_Date != '0'){   
                    filterLables.add(new FilterLabel('Deal_Units_Compliance_Date', 'Compliance Date', homeSerachFilterObj.Deal_Units_Compliance_Date));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Year_Of_1st_Rego) && homeSerachFilterObj.Deal_Units_Year_Of_1st_Rego != '0'){   
                    filterLables.add(new FilterLabel('Deal_Units_Year_Of_1st_Rego', 'Year of 1st Rego', homeSerachFilterObj.Deal_Units_Year_Of_1st_Rego));
                }
                if(!String.isBlank(homeSerachFilterObj.Deal_Units_Registration_Serial) && homeSerachFilterObj.Deal_Units_Registration_Serial != '0'){   
                    filterLables.add(new FilterLabel('Deal_Units_Registration_Serial', 'Registration Serial#', homeSerachFilterObj.Deal_Units_Registration_Serial));
                }
                if(homeSerachFilterObj.Deal_Units_Manufactured_Date !=null && !String.isBlank(homeSerachFilterObj.Deal_Units_Manufactured_Date.SelectedOption) && homeSerachFilterObj.Deal_Units_Manufactured_Date.SelectedOption != '0') {
					String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Deal_Units_Manufactured_Date.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Deal_Units_Manufactured_Date.SelectedOption) : homeSerachFilterObj.Deal_Units_Manufactured_Date.SelectedOption;
					if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Deal_Units_Manufactured_Date.Value1) && !String.isBlank(homeSerachFilterObj.Deal_Units_Manufactured_Date.Value2)) {
						filterLables.add(new FilterLabel('Deal_Units_Manufactured_Date', 'Manufactured Date', homeSerachFilterObj.Deal_Units_Manufactured_Date.Value1 + ' To ' + homeSerachFilterObj.Deal_Units_Manufactured_Date.Value2));
					} else if(modifiedLabelName != '5'){
						filterLables.add(new FilterLabel('Deal_Units_Manufactured_Date', 'Manufactured Date', modifiedLabelName));
					}
                }
          }
            
            if(homeSerachFilterObj.Type.Objects.contains('Parts Order')) {
                if(!String.isBlank(homeSerachFilterObj.Parts_Order_Order_Number) && homeSerachFilterObj.Parts_Order_Order_Number != '0'){   
                    filterLables.add(new FilterLabel('Parts_Order_Order_Number', 'Order Number', homeSerachFilterObj.Parts_Order_Order_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Parts_Order_Customer) && homeSerachFilterObj.Parts_Order_Customer != '0'){   
                    filterLables.add(new FilterLabel('Parts_Order_Customer', 'Customer', homeSerachFilterObj.Parts_Order_Customer));
                }
                if(!String.isBlank(homeSerachFilterObj.Parts_Order_Sale_Type) && homeSerachFilterObj.Parts_Order_Sale_Type != '0'){   
                    filterLables.add(new FilterLabel('Parts_Order_Sale_Type', 'Sale Type', homeSerachFilterObj.Parts_Order_Sale_Type));
                }
                if(homeSerachFilterObj.Parts_Order_Total !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Total.SelectedOption) && homeSerachFilterObj.Parts_Order_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Parts_Order_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Parts_Order_Total.SelectedOption) : homeSerachFilterObj.Parts_Order_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Total', 'Total', homeSerachFilterObj.Parts_Order_Total.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Parts_Order_Total', 'Total', modifiedLabelName + ' ' + homeSerachFilterObj.Parts_Order_Total.Value1));
                    }
                }
                /*if(homeSerachFilterObj.Parts_Order_Status !=null && String.isNotBlank(homeSerachFilterObj.Parts_Order_Status.SelectedOption) && homeSerachFilterObj.Parts_Order_Status.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Parts_Order_Status.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Parts_Order_Status.SelectedOption) : homeSerachFilterObj.Parts_Order_Status.SelectedOption;
                    if(modifiedLabelName == '5' && String.isNotBlank(homeSerachFilterObj.Parts_Order_Status.Value1) && String.isNotBlank(homeSerachFilterObj.Parts_Order_Status.Value2)) {
                        filterLables.add(new FilterLabel('Parts_Order_Status', 'CO_Type__c', homeSerachFilterObj.Parts_Order_Status.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Status.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Status', 'CO_Type__c', modifiedLabelName));
                    }
                }*/
                if(homeSerachFilterObj.Parts_Order_Deposits !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Deposits.SelectedOption) && homeSerachFilterObj.Parts_Order_Deposits.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Parts_Order_Deposits.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Parts_Order_Deposits.SelectedOption) : homeSerachFilterObj.Parts_Order_Deposits.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Deposits', 'Deposits', homeSerachFilterObj.Parts_Order_Deposits.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Deposits.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Parts_Order_Deposits', 'Deposits', modifiedLabelName + ' ' + homeSerachFilterObj.Parts_Order_Deposits.Value1));
                    }
                }
                if(homeSerachFilterObj.Parts_Order_Invoiced !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Invoiced.SelectedOption) && homeSerachFilterObj.Parts_Order_Invoiced.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Parts_Order_Invoiced.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Parts_Order_Invoiced.SelectedOption) : homeSerachFilterObj.Parts_Order_Invoiced.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Invoiced', 'Invoiced', homeSerachFilterObj.Parts_Order_Invoiced.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Invoiced.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Parts_Order_Invoiced', 'Invoiced', modifiedLabelName + ' ' + homeSerachFilterObj.Parts_Order_Invoiced.Value1));
                    }
                }
                if(homeSerachFilterObj.Parts_Order_Modified !=null && String.isNotBlank(homeSerachFilterObj.Parts_Order_Modified.SelectedOption) && homeSerachFilterObj.Parts_Order_Modified.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Parts_Order_Modified.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Parts_Order_Modified.SelectedOption) : homeSerachFilterObj.Parts_Order_Modified.SelectedOption;
                    if(modifiedLabelName == '5' && String.isNotBlank(homeSerachFilterObj.Parts_Order_Modified.Value1) && String.isNotBlank(homeSerachFilterObj.Parts_Order_Modified.Value2)) {
                        filterLables.add(new FilterLabel('Parts_Order_Modified', 'Modified', homeSerachFilterObj.Parts_Order_Modified.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Modified.Value2));
                    } else if(modifiedLabelName != '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Modified', 'Modified', modifiedLabelName)); 
                    }
                }
                
                if(homeSerachFilterObj.Parts_Order_Parts !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Parts.SelectedOption) && homeSerachFilterObj.Parts_Order_Parts.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Parts_Order_Parts.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Parts_Order_Parts.SelectedOption) : homeSerachFilterObj.Parts_Order_Parts.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Parts', 'Parts', homeSerachFilterObj.Parts_Order_Parts.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Parts.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Parts_Order_Parts', 'Parts', modifiedLabelName + ' ' + homeSerachFilterObj.Parts_Order_Parts.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Parts_Order_Fees !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Fees.SelectedOption) && homeSerachFilterObj.Parts_Order_Fees.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Parts_Order_Fees.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Parts_Order_Fees.SelectedOption) : homeSerachFilterObj.Parts_Order_Fees.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Fees', 'Fees', homeSerachFilterObj.Parts_Order_Fees.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Fees.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Parts_Order_Fees', 'Fees', modifiedLabelName + ' ' + homeSerachFilterObj.Parts_Order_Fees.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Parts_Order_Sales_Tax !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Sales_Tax.SelectedOption) && homeSerachFilterObj.Parts_Order_Sales_Tax.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Parts_Order_Sales_Tax.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Parts_Order_Sales_Tax.SelectedOption) : homeSerachFilterObj.Parts_Order_Sales_Tax.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Sales_Tax', 'Sales Tax', homeSerachFilterObj.Parts_Order_Sales_Tax.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Sales_Tax.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Parts_Order_Sales_Tax', 'Sales Tax', modifiedLabelName + ' ' + homeSerachFilterObj.Parts_Order_Sales_Tax.Value1));
                    }
                }
                
                if(homeSerachFilterObj.Parts_Order_Parts_Profit !=null && !String.isBlank(homeSerachFilterObj.Parts_Order_Parts_Profit.SelectedOption) && homeSerachFilterObj.Parts_Order_Parts_Profit.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Parts_Order_Parts_Profit.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Parts_Order_Parts_Profit.SelectedOption) : homeSerachFilterObj.Parts_Order_Parts_Profit.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Parts_Order_Parts_Profit', 'Profit', homeSerachFilterObj.Parts_Order_Parts_Profit.Value1 + ' To ' + homeSerachFilterObj.Parts_Order_Parts_Profit.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Parts_Order_Parts_Profit', 'Profit', modifiedLabelName + ' ' + homeSerachFilterObj.Parts_Order_Parts_Profit.Value1));
                    }
                }
                
            }
            
           if(homeSerachFilterObj.Type.Objects.contains('Unit Deals')) {
           		if(!String.isBlank(homeSerachFilterObj.Unit_Deals_Order_Number)) {
                    filterLables.add(new FilterLabel('Unit_Deals_Order_Number', 'Order Number', homeSerachFilterObj.Deal_Units_Order_Number));
                }
                if(!String.isBlank(homeSerachFilterObj.Unit_Deals_Customer)) {
                    filterLables.add(new FilterLabel('Unit_Deals_Customer', 'Customer', homeSerachFilterObj.Deal_Units_Deal_Customer));
                }
				if(!String.isBlank(homeSerachFilterObj.Unit_Deals_Deal_Type) && homeSerachFilterObj.Unit_Deals_Deal_Type != '0') {
                    String dealType;
                    if(homeSerachFilterObj.Unit_Deals_Deal_Type == '1') {
                        dealType = Constants.CASH_DEAL;
                    } else if(homeSerachFilterObj.Unit_Deals_Deal_Type == '2') {
                        dealType = Constants.FINANCED;
                    }
                    filterLables.add(new FilterLabel('Unit_Deals_Deal_Type', 'Deal Type', dealType));
                }
				if(homeSerachFilterObj.Unit_Deals_Total !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Total.SelectedOption) && homeSerachFilterObj.Unit_Deals_Total.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Total.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Total.SelectedOption) : homeSerachFilterObj.Unit_Deals_Total.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Total', 'Total', homeSerachFilterObj.Unit_Deals_Total.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Total.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Total', 'Total', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Total.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Delivery !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Delivery.SelectedOption) && homeSerachFilterObj.Unit_Deals_Delivery.SelectedOption != '0') {
                    String modifiedLabelName = optionValueToModifiedKeyMap.containsKey(homeSerachFilterObj.Unit_Deals_Delivery.SelectedOption) ? optionValueToModifiedKeyMap.get(homeSerachFilterObj.Unit_Deals_Delivery.SelectedOption) : homeSerachFilterObj.Part_LastSold.SelectedOption;
                    if(modifiedLabelName == '5' && !String.isBlank(homeSerachFilterObj.Unit_Deals_Delivery.Value1) && !String.isBlank(homeSerachFilterObj.Unit_Deals_Delivery.Value2)) {
                        filterLables.add(new FilterLabel('Unit_Deals_Delivery', 'Delivery', homeSerachFilterObj.Unit_Deals_Delivery.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Delivery.Value2));
                    } else if(modifiedLabelName != '5'){
                        filterLables.add(new FilterLabel('Unit_Deals_Delivery', 'Delivery', modifiedLabelName));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Units !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Units.SelectedOption) && homeSerachFilterObj.Unit_Deals_Units.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Units.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Units.SelectedOption) : homeSerachFilterObj.Unit_Deals_Units.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Units', 'Units', homeSerachFilterObj.Unit_Deals_Units.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Units.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Units', 'Units', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Units.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Lien_payout !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Lien_payout.SelectedOption) && homeSerachFilterObj.Unit_Deals_Lien_payout.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Lien_payout.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Lien_payout.SelectedOption) : homeSerachFilterObj.Unit_Deals_Lien_payout.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Lien_payout', 'Lien Payout', homeSerachFilterObj.Unit_Deals_Lien_payout.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Lien_payout.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Lien_payout', 'Lien Payout', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Lien_payout.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Trade_Ins !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Trade_Ins.SelectedOption) && homeSerachFilterObj.Unit_Deals_Trade_Ins.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Trade_Ins.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Trade_Ins.SelectedOption) : homeSerachFilterObj.Unit_Deals_Trade_Ins.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Trade_Ins', 'Trade Ins', homeSerachFilterObj.Unit_Deals_Trade_Ins.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Trade_Ins.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Trade_Ins', 'Trade Ins', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Trade_Ins.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Parts_And_Labour !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Parts_And_Labour.SelectedOption) && homeSerachFilterObj.Unit_Deals_Parts_And_Labour.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Parts_And_Labour.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Parts_And_Labour.SelectedOption) : homeSerachFilterObj.Unit_Deals_Parts_And_Labour.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Parts_And_Labour', 'Parts And Labour', homeSerachFilterObj.Unit_Deals_Parts_And_Labour.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Parts_And_Labour.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Parts_And_Labour', 'Parts And Labour', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Parts_And_Labour.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Other_Products !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Other_Products.SelectedOption) && homeSerachFilterObj.Unit_Deals_Other_Products.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Other_Products.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Other_Products.SelectedOption) : homeSerachFilterObj.Unit_Deals_Other_Products.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Other_Products', 'Deal Products', homeSerachFilterObj.Unit_Deals_Other_Products.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Other_Products.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Other_Products', 'Deal Products', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Other_Products.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Fees !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Fees.SelectedOption) && homeSerachFilterObj.Unit_Deals_Fees.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Fees.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Fees.SelectedOption) : homeSerachFilterObj.Unit_Deals_Fees.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Fees', 'Fees', homeSerachFilterObj.Unit_Deals_Fees.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Fees.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Fees', 'Fees', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Fees.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Stamp_Duty !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Stamp_Duty.SelectedOption) && homeSerachFilterObj.Unit_Deals_Stamp_Duty.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Stamp_Duty.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Stamp_Duty.SelectedOption) : homeSerachFilterObj.Unit_Deals_Stamp_Duty.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Stamp_Duty', 'Stamp Duty', homeSerachFilterObj.Unit_Deals_Stamp_Duty.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Stamp_Duty.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Stamp_Duty', 'Stamp Duty', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Stamp_Duty.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Financing_Products !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Financing_Products.SelectedOption) && homeSerachFilterObj.Unit_Deals_Financing_Products.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Financing_Products.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Financing_Products.SelectedOption) : homeSerachFilterObj.Unit_Deals_Financing_Products.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Financing_Products', 'Financing Products', homeSerachFilterObj.Unit_Deals_Financing_Products.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Financing_Products.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Financing_Products', 'Financing Products', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Financing_Products.Value1));
                    }
                }
                if(homeSerachFilterObj.Unit_Deals_Sales_Tax !=null && !String.isBlank(homeSerachFilterObj.Unit_Deals_Sales_Tax.SelectedOption) && homeSerachFilterObj.Unit_Deals_Sales_Tax.SelectedOption != '0' ){
                    String modifiedLabelName = optionValueToNumberValueLabelMap.containsKey(homeSerachFilterObj.Unit_Deals_Sales_Tax.SelectedOption) ? optionValueToNumberValueLabelMap.get(homeSerachFilterObj.Unit_Deals_Sales_Tax.SelectedOption) : homeSerachFilterObj.Unit_Deals_Sales_Tax.SelectedOption;
                    if(modifiedLabelName == '5') {
                        filterLables.add(new FilterLabel('Unit_Deals_Sales_Tax', 'Sales Tax', homeSerachFilterObj.Unit_Deals_Sales_Tax.Value1 + ' To ' + homeSerachFilterObj.Unit_Deals_Sales_Tax.Value2));
                    } else {
                        filterLables.add(new FilterLabel('Unit_Deals_Sales_Tax', 'Sales Tax', modifiedLabelName + ' ' + homeSerachFilterObj.Unit_Deals_Sales_Tax.Value1));
                    }
                }
            } 
            
        return filterLables;
    }
    
    private static FilterLabel getTagsFilterLabel(List<String> searchableTagsList) {
        FilterLabel filterLabelObj;
        if(searchableTagsList != null && searchableTagsList.size() > 0) {
            String tagStr = '';
            for(String searchTagStr : searchableTagsList) {
                tagStr += (searchTagStr + ', ');
            }
            tagStr = tagStr.subString(0, tagStr.length()-2);
            filterLabelObj = new FilterLabel('AssignedTags', 'Tags', tagStr);
        }
        return filterLabelObj;
    }
    
    public static Map<String, String> optionValueToStatusKeyMap = new Map<String, String>{  '0' => 'Any',
                                                                                            '1' => 'Active',
                                                                                            '2' => 'Inactive'
                                                                                        };
    
    public static Map<String, String> optionValueToOwnerKeyMap = new Map<String, String>{   '0' => 'Any',
                                                                                            '1' => 'Owned by me',
                                                                                            '2' => 'Not owned by me'
                                                                                        };
    
    public static Map<String, String> optionValueToModifiedKeyMap = new Map<String, String>{    '0' => 'Anytime',
                                                                                                '1' => 'Today',
                                                                                                '2' => 'Yesterday',
                                                                                                '3' => 'Last 7 days',
                                                                                                '4' => 'Last 30 days',
                                                                                                '6' => 'Next 30 days',
                                                                                                '7' => 'Tomorrow',
                                                                                                '8' => 'Next 7 days'
                                                                                                
                                                                                        };
                                                                                        
    public static Map<String, String> optionValueToNumberValueLabelMap = new Map<String, String>{   '0' => 'Any',
                                                                                                    '1' => 'Equal To',
                                                                                                    '2' => 'Not Equal To',
                                                                                                    '3' => 'Greater Than',
                                                                                                    '4' => 'Less Than'
                                                                                                };                                                                                  
    
    public static Map<String, String> optionValueToPaymentMethodMap = new Map<String, String>{  '0' => 'Any',
                                                                                                '1' => 'Cash',
                                                                                                '2' => 'Debit',
                                                                                                '3' => 'Cheque',
                                                                                                '4' => 'Visa',
                                                                                                '5' => 'Mastercard',
                                                                                                '6' => 'Amex',
                                                                                                '7' => 'Gift Card',
                                                                                                '8' => 'Charge Account',
                                                                                                '9' => '\'Use Deposit\', \'Use Deal Deposit\'',
                                                                                                '10' => '\'Cash\', \'Debit\', \'Cheque\', \'Visa\', \'Mastercard\', \'Amex\', \'Gift Card\'',
                                                                                                '11' => 'Cash Rounding',
                                                                                                '12' => 'Store Credit',
                                                                                                '13' => 'Direct Deposit'};
                                                                                                
     /**
     * Name: FieldFilter
     * Description: Field Filter Wrapper Class
     **/
    public class FieldFilter {
        
        public String FieldName;
        public String Operator;
        public Object FieldValue;
        
         /**
         * Name: FieldFilter
         * Desc: Constructor
         * @param:  (1) fieldName - String  - Field Name
         *          (2) operator - String  - Operator String
         *          (3) value - Object - Value Object
         * @return:
         **/
        public FieldFilter(String fieldName, String operator, Object value){
            this.FieldName = fieldName;
            this.Operator = operator;
            this.FieldValue = value;
         }
    }
     
    /**
     * Name: FieldLabel
     * Description: Field Label Wrapper Class
    **/
    public class FilterLabel {
        
        public String Key;
        public String Label;
        public String Value;
        
        /**
         * Name: FilterLabel
         * Desc: Constructor
         * @param:  (1) key - String  - Key String
         *          (2) label - String  - Operator String
         *          (3) value - String - Value String
         * @return:
         **/
        public FilterLabel(String key, String label, String value) {
            this.Key = key;
            this.Label = label;
            this.Value = value;
        }
    }
}
