public with sharing class DataExportUtil {
    
    public static final String CUSTOMERS_ACCOUNTING_OBJECT_NAME = 'Customers Card';
    public static final String VENDORS_ACCOUNTING_OBJECT_NAME = 'Supplier Card';
    public static final String SALES_INVOICE_ACCOUNTING_OBJECT_NAME = 'Customer Order Sales Invoices'; 
    public static final String PAYMENT_ACCOUNTING_OBJECT_NAME = 'ReceiveMoneyTxn_Payment';  
    public static final String DEPOSITS_ACCOUNTING_OBJECT_NAME = 'ReceiveMoneyTxn_Deposit';
    public static final String VENDOR_RECEIVING_ACCOUNTING_OBJECT_NAME = 'General Journal Entries';
    public static final String VENDOR_INVOICING_ACCOUNTING_OBJECT_NAME = 'Vendor Invoicing';
    public static String fileSeparator = '\t';
    public static String fileDateTimeFormat = 'yyyy-MM-dd\'T\'hh:mm:ss\'Z\'';
    
    public static String getUnitDescription(Deal_Item__c dealItemRec) {
        String unitDesc = ''; 
        if(dealItemRec.Customer_Owned_Unit__c != null) {
            if(dealItemRec.Customer_Owned_Unit__r.Unit_Make__r.Name !=null && dealItemRec.Customer_Owned_Unit__r.Unit_Make__r.Name !=''){
                unitDesc += dealItemRec.Customer_Owned_Unit__r.Unit_Make__r.Name + ' ';
            }
            if(dealItemRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c != null && dealItemRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c !=''){
                unitDesc += dealItemRec.Customer_Owned_Unit__r.Unit_Model__r.Name__c + ' ';
            }
            if(dealItemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c != null && dealItemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c !=''){ 
                unitDesc += dealItemRec.Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c;
            }
        }
        return unitDesc;
    }
        
    public static Accounting_Data_Migration__c getDateRange(String timePeriodForFilter, DateTime Last_Synched_Date, DateTime fromDate, DateTime toDate, List<Accounting_Data_Migration__c> dataMigrationList) {
        Date startDate, endDate;
        Date todayDate = Date.today();
        Accounting_Data_Migration__c dataMigration = new Accounting_Data_Migration__c();
        if(dataMigrationList.size() > 0) {
            dataMigration = dataMigrationList[0];
        }
        if(timePeriodForFilter == 'ALL_SINCE_LAST_EXORTED') {
            if(Last_Synched_Date != null) {
                startDate = Date.newInstance(Last_Synched_Date.year(), Last_Synched_Date.month(), Last_Synched_Date.day());
            } else {
                List<User> usersList = [SELECT CreatedDate FROM User limit: SOQLUtil.getAvailableQueryRowsLimit()];
                if(usersList.size() > 0) {
                    startDate = Date.newinstance(usersList[0].CreatedDate.year(), usersList[0].CreatedDate.month(), usersList[0].CreatedDate.day());
                }
            }  
            endDate = todayDate;
        } else if(timePeriodForFilter == 'THIS_WEEK') {
            startDate = todayDate.toStartOfWeek();
            endDate = todayDate;
        } else if(timePeriodForFilter == 'THIS_MONTH') {
            startDate = todayDate.toStartOfMonth();
            endDate = todayDate;
        } else if(timePeriodForFilter == 'LAST_WEEK') {
            startDate = todayDate.toStartofWeek().addDays(-7);
            endDate = startDate.addDays(6);
        } else if(timePeriodForFilter == 'LAST_MONTH') {
            Integer lastMonthNumber = todayDate.month() - 1;
            if(lastMonthNumber == 0) {
                lastMonthNumber = 12;
                startDate = Date.newInstance(todayDate.year() - 1, lastMonthNumber, 1);
                Integer noOfDays = Date.daysInMonth(todayDate.year() - 1, lastMonthNumber);
                endDate = Date.newInstance(todayDate.year() - 1, lastMonthNumber, noOfDays);
            } else {
                startDate = Date.newInstance(todayDate.year(), lastMonthNumber, 1);
                Integer noOfDays = Date.daysInMonth(todayDate.year(), lastMonthNumber);
                endDate = Date.newInstance(todayDate.year(), lastMonthNumber, noOfDays);
            }
        } else if(timePeriodForFilter == 'SPECIFIC_DATE_RANGE') {
            startDate = Date.newInstance(fromDate.year(), fromDate.month(), fromDate.day());
            endDate = Date.newInstance(toDate.year(), toDate.month(), toDate.day());
        }
        dataMigration.Start_Date__c = startDate;
        dataMigration.End_Date__c = endDate;
        return dataMigration;
    }
    
    public static Accounting_Data_Migration__c getAccountingDataMigrationRec(String objNameToExport) {
        List<Accounting_Data_Migration__c> accountingDataMigrationList = 
                [Select Last_Synched_Date__c, Start_Date__c, End_Date__c from Accounting_Data_Migration__c where Object_Name__c =: objNameToExport];
        if(accountingDataMigrationList.size() > 0) {
            return accountingDataMigrationList[0];
        } 
        return new Accounting_Data_Migration__c(Object_Name__c = objNameToExport);
    }
    
    public static Attachment createAttachment(String cardsData, String attchNamePrefix, Accounting_Data_Migration__c dataMigration, Integer numberOfRecords) {
        Attachment attachment = new Attachment(); 
        attachment.Body = Blob.valueOf(cardsData);
        attachment.Name = attchNamePrefix + DateTime.now().format(fileDateTimeFormat) + '.TXT';
        attachment.ParentId = dataMigration.Id; 
        attachment.ContentType = 'text/csv';
        attachment.Description = System.JSON.serialize(new UserSettingCtrl.AttachmentDescriptionJsonWrapper(dataMigration.Start_Date__c, dataMigration.End_Date__c, numberOfRecords));
        return attachment;
    }  
     
    public static String createQuery(List<String> recordIds, String fieldNameToFilter, String timePeriodForFilter, DateTime Last_Synched_Date, 
                                                        DateTime fromDate, DateTime toDate, String objName) {
        String objectAPIName = (objName == 'Customers' || objName == 'Vendors') ? 'Account' : 
                                    (objName == 'CO_KLI' ? Constants.NAMESPACE +'CO_Line_Item__c' : 
                                    (objName == 'StockInTradedUnit' ? Constants.NAMESPACE +'Deal_Item__c' : (Constants.NAMESPACE + objName)));
        String query = 'SELECT ';
        query += (objNameToStandardFieldsMap.containsKey(objName)) ? objNameToStandardFieldsMap.get(objName) : '';
        
        Map<String, Schema.SObjectField> objectFieldsMap = Schema.getGlobalDescribe().get(objectAPIName).getDescribe().Fields.getMap();
        for(String fieldName : objectFieldsMap.keySet()) {
            if(fieldName.endsWith('__c')) {
                query += ' , ' + fieldName; 
            }
        }
         
        query += ' FROM ' + objectAPIName;
        String whereClause = (objectNameToFilterMap.containsKey(objName)) ? objectNameToFilterMap.get(objName) : '';
        if(timePeriodForFilter != null) {
            whereClause += (whereClause.length() > 0) ? ' AND' : ' WHERE';
            String timeFieldToMatch = 'LastModifiedDate';
            if(objectNameToTimeFieldMap.containsKey(objectAPIName)) {
                timeFieldToMatch = objectNameToTimeFieldMap.get(objectAPIName);
            }
    		if(objectNameToDateFieldMap.containsKey(objectAPIName)) {
    		    timeFieldToMatch = objectNameToDateFieldMap.get(objectAPIName); 
    		}
            /*String timeFieldToMatch = (objectAPIName == Constants.NAMESPACE + 'Part_FIFO_Bucket__c') ? 'CreatedDate' : 
                                    ((objectAPIName == Constants.NAMESPACE + 'Return_VO_Line_Item__c') ? 'Return_VO_Header__r.Credited_Date__c' : 'LastModifiedDate'); */
            if(timePeriodForFilter == 'ALL_SINCE_LAST_EXORTED' && Last_Synched_Date != null) {
                whereClause += ' ' + timeFieldToMatch + ' >: Last_Synched_Date';
    		} else if(timePeriodForFilter == 'SPECIFIC_DATE_RANGE' && fromDate != null && toDate != null) {
    			if(objectNameToDateFieldMap.containsKey(objectAPIName)) {
	    			whereClause += ' ' + timeFieldToMatch + ' >= ' + fromDate.format('yyyy-MM-dd');
	    			whereClause += ' AND ' + timeFieldToMatch + ' <= ' + toDate.addDays(1).format('yyyy-MM-dd');
    			} else {
                	whereClause += ' ' + timeFieldToMatch + ' >= ' + fromDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
	    			whereClause += ' AND ' + timeFieldToMatch + ' <= ' + toDate.addDays(1).format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    			}
            } else {
                whereClause += ' ' + timeFieldToMatch + ' = ' + timePeriodForFilter;
            }
        }
        if(recordIds != null && recordIds.size() > 0) {
            whereClause += (whereClause.length() > 0) ? ' AND' : ' WHERE';
            if(objName == 'Service_Order_Line_Item__c' || objName == 'Service_Order_Header__c') {
                whereClause += ' ' + fieldNameToFilter + ' IN :soHeaderIdList ';
            } else if(objName == 'CO_KLI') {
                whereClause += ' ' + fieldNameToFilter + ' IN :cokitHeaderIdList ';
            } else if(objName == 'Deal_Item__c' || objName == 'F_I_Product__c') {
                whereClause += ' ' + fieldNameToFilter + ' IN :dealIdList ';
            } else {
                whereClause += ' ' + fieldNameToFilter + ' IN ' + recordIds;
            }
        }
        query += whereClause + ' ORDER BY ';
        query += (objectNameToOrderByFieldMap.containsKey(objName)) ? objectNameToOrderByFieldMap.get(objName) : 'LastModifiedDate';
        return query;
    } 
    
    private static Map<String, String> objectNameToTimeFieldMap = new Map<String, String> {
        Constants.NAMESPACE + 'Part_FIFO_Bucket__c' => 'CreatedDate',
        Constants.NAMESPACE + 'Return_VO_Line_Item__c' => 'Return_VO_Header__r.Credited_Date__c',
	    Constants.NAMESPACE + 'Vendor_Invoicing_Group__c' => 'Vendor_Invoicing_Header__r.LastModifiedDate'
	};
	
	public static Map<String, String> objectNameToDateFieldMap = new Map<String, String> {
        Constants.NAMESPACE + 'CO_Invoice_Payment__c' => 'Payment_Date__c',
	    Constants.NAMESPACE + 'CO_Deposit__c' => 'Payment_Date__c'
    };
    
    public static Map<String, String> exportDisplayObjectNameToObjectNameMap = new Map<String, String>{'Customers Card' => 'Customers',
                                                                                    'ReceiveMoneyTxn_Deposit'       => 'Money Received',
                                                                                    'Customer Order Sales Invoices' => 'Customer Invoices',
                                                                                    'Supplier Card'                 => 'Vendors',
                                                                                    'General Journal Entries'       => 'Journal Entries',
                                                                                    'Vendor Invoicing'              => 'Vendor Invoices'
                                                                                };
                                                                                
    /*Note: Add only those custom fields that are fetch from related object, all entity custom firlds are fetch through describe call */
    public static Map<String, String> objNameToStandardFieldsMap = new Map<String, String>{'Customers'  => 'Id, Name, Website, Fax, Description, ' +
                                                                                                            'BillingStreet, BillingCity, BillingState, BillingPostalCode, '+
                                                                                                            'BillingCountry, ShippingStreet, ShippingCity, ShippingState, '+
                                                                                                            'ShippingPostalCode, ShippingCountry',
                                                                                                            
                                            'Individual_Tax__c'     => 'Id, Name, Service_Order_Line_Item__r.Service_Order_Header__c, Deal_Unit_Price_Cost__r.Deal_Item__r.Is_Stocked_In__c,'+
                                                                        'Option_Fee__r.Deal__c, Deal_Unit_Price_Cost__r.Deal_Item__c, Deal_Unit_Price_Cost__r.Deal_Item__r.Deal__c, '+
                                                                        'Deal_Item__r.Deal__c, CO_Line_Item__r.CO_Kit_Header__c, F_I_Product__r.Deal__c',
                                            
                                            'Vendors'               => 'Id, Name, Website, Fax, Description, Purchase_Tax__r.Name__c, BillingStreet, BillingCity, '+
                                                                        'BillingState, BillingPostalCode, BillingCountry, ShippingStreet, ShippingCity, ShippingState, '+
                                                                        'ShippingPostalCode, ShippingCountry',
                                                                        
                                            'CO_KLI'                => 'Id, Name, CreatedDate, CO_Kit_Header__r.CO_Header__r.Name, CO_Kit_Header__r.Deal__c,'+
                                                                        'Part__r.Part_Number__c, '+
                                                                        'Part__r.Description__c, '+
                                                                        'Part__r.Last_Cost__c, '+
                                                                        'Part__r.Category__r.COGS_GL__c, '+
                                                                        'Part__r.Category__r.Income_GL__c, '+
                                                                        'Part__r.Category__r.Inventory_GL__c, '+
                                                                        'Part__r.Applicable_Tax__r.Name__c, '+
																		'Deal__r.Invoice_Number__c, '+
																		'Deal__r.Invoice_Number__r.CreatedDate, '+
																		'Invoice_Number__r.CreatedDate, '+
																		'Fee__r.Code__c, '+
                                                                        'Fee__r.Description__c, '+
                                                                        'Fee__r.Cost_Rate__c, '+
                                                                        'Fee__r.Cost_Method__c,'+
                                                                        'Fee__r.Category__r.COGS_GL__c, '+
                                                                        'Fee__r.Category__r.Income_GL__c, '+
                                                                        'Fee__r.Category__r.Inventory_GL__c, '+
                                                                        'Fee__r.Applicable_Tax__r.Name__c',
                                                                                                    
                                            'Service_Order_Line_Item__c' => 'Id, Name, CreatedDate, Service_Order_Header__r.CO_Header__r.Name, Service_Order_Header__r.Deal_Item__c,'+
                                                                        
                                                                        'Service_Order_Header__r.Transaction_Type__r.Part_Category__r.Income_GL__c,'+
                                                                        'Service_Order_Header__r.Transaction_Type__r.Part_Category__r.COGS_GL__c,'+
                                                                        'Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.Income_GL__c,'+
                                                                        'Service_Order_Header__r.Transaction_Type__r.Labour_Category__r.COGS_GL__c,'+
                                                                        'Service_Order_Header__r.Deal__c, '+
																		'Service_Order_Header__r.Deal__r.Invoice_Number__c, '+
																		'Service_Order_Header__r.Deal__r.Invoice_Number__r.CreatedDate, '+
																		'Service_Order_Header__r.Invoice_Number__r.CreatedDate, '+
																		'Service_Order_Header__r.Invoice_Number__c, '+
																		'Part__r.Part_Number__c, '+
                                                                        'Part__r.Description__c, '+
                                                                        'Part__r.Last_Cost__c, '+
                                                                        'Part__r.Category__r.COGS_GL__c, '+
                                                                        'Part__r.Category__r.Income_GL__c, '+
                                                                        'Part__r.Category__r.Inventory_GL__c, '+
                                                                        'Part__r.Applicable_Tax__r.Name__c, '+
                                                                        
                                                                        'Fee__r.Code__c, '+
                                                                        'Fee__r.Description__c, '+
                                                                        'Fee__r.Cost_Rate__c, '+
                                                                        'Fee__r.Cost_Method__c,'+
                                                                        'Fee__r.Category__r.COGS_GL__c, '+
                                                                        'Fee__r.Category__r.Income_GL__c, '+
                                                                        'Fee__r.Category__r.Inventory_GL__c, '+
                                                                        'Fee__r.Applicable_Tax__r.Name__c,'+
                                                                        
                                                                        'Labour_Code__r.Code__c, '+
                                                                        'Labour_Code__r.Description__c, '+
                                                                        'Labour_Code__r.Cost_Rate__c, '+
                                                                        'Labour_Code__r.Cost_Method__c,'+
                                                                        'Labour_Code__r.Category__r.COGS_GL__c, '+
                                                                        'Labour_Code__r.Category__r.Income_GL__c, '+
                                                                        'Labour_Code__r.Category__r.Inventory_GL__c, '+
                                                                        'Labour_Code__r.Applicable_Tax__r.Name__c,'+
                                                                        
                                                                        'Sublet__r.Code__c, '+
                                                                        'Sublet__r.Description__c, '+
                                                                        'Sublet__r.Cost__c, '+
                                                                        'Sublet__r.Cost_Method__c,'+
                                                                        'Sublet__r.Category__r.COGS_GL__c, '+
                                                                        'Sublet__r.Category__r.Income_GL__c, '+
                                                                        'Sublet__r.Category__r.Inventory_GL__c, '+
                                                                        'Sublet__r.Applicable_Tax__r.Name__c,'+
                                                                        
                                                                        '(Select Avg_Cost__c, Adjusted_Cost_Coli__c from CO_Line_Items__r), '+
																		'(SELECT Total_Variance_Amount__c, Category__r.COGS_GL__c, Category__r.Income_GL__c, '+
        																'Category__r.Inventory_GL__c FROM Claim_Line_Items__r WHERE SO_Payment_Role__r.RecordType.DeveloperName = \'Internal\')',
                                                                        
                                            'StockInTradedUnit' => 'Id, CreatedDate, Stocked_In_Unit__r.CreatedDate, Deal__r.CO_Header__r.Customer_Name__c, Deal__r.CO_Header__r.Name, Customer_Owned_Unit__r.Sales_Tax_Credit__c, '+   //Deal__r.Total__c, Deal__r.Deal_Tax_Total__c, Deal__r.CO_Header__c, Deal__r.CO_Header__r.Deal_Total__c, 
                                                                'Customer_Owned_Unit__r.Category__r.COGS_GL__c,Customer_Owned_Unit__r.Applicable_Tax__r.Name__c,'+
                                                                'Customer_Owned_Unit__r.Category__r.Income_GL__c, Stocked_In_Unit__r.Category__r.Inventory_GL__c, Customer_Owned_Unit__r.Category__r.Inventory_GL__c,'+
                                                                'Customer_Owned_Unit__r.Year__c,Customer_Owned_Unit__r.Unit_Make__r.Name,'+
                                                                'Customer_Owned_Unit__r.Unit_Model__r.Name__c, Customer_Owned_Unit__r.Trade_In_Value__c, '+
                                                                'Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c,'+
                                                                'Customer_Owned_Unit__r.VIN_Number__c,Customer_Owned_Unit__r.Stock_Id__c',
                                                                        
                                            'Deal_Item__c' => 'Id, Deal__r.CO_Header__r.Customer_Name__c, Deal__r.CO_Header__r.Name, Stocked_In_Unit__r.Sales_Tax_Credit__c, '+ //Deal__r.Total__c, Deal__r.Deal_Tax_Total__c, Deal__r.CO_Header__c, Deal__r.CO_Header__r.Deal_Total__c, 
                                                                'Customer_Owned_Unit__r.Category__r.COGS_GL__c,Customer_Owned_Unit__r.Applicable_Tax__r.Name__c,'+
                                                                'Customer_Owned_Unit__r.Category__r.Income_GL__c, Customer_Owned_Unit__r.Category__r.Inventory_GL__c,'+
                                                                'Customer_Owned_Unit__r.Year__c,Customer_Owned_Unit__r.Unit_Make__r.Name, Customer_Owned_Unit__r.Sales_Tax_Credit__c, '+
                                                                'Customer_Owned_Unit__r.Unit_Model__r.Name__c, Customer_Owned_Unit__r.Trade_In_Value__c, '+
                                                                'Customer_Owned_Unit__r.Sub_Model__r.Sub_Model_Name__c, Stocked_In_Unit__r.Category__r.Inventory_GL__c,'+
                                                                'Customer_Owned_Unit__r.VIN_Number__c,Customer_Owned_Unit__r.Stock_Id__c,'+
                                                                'Deal__r.Invoice_Number__r.Invoice_Date__c, Finance_Company__r.Name,'+
    															'Deal__r.Invoice_Number__r.Invoice_Number__c, Finance_Company__r.Vendor_Code__c, ' +
    															'Deal__r.Is_Deal_Fulfilled__c, ' + 
                                                                '(Select Item_Code__c, Item_Description__c, Price__c, Qty__c,Per_Item_Cost__c,'+
    															'Deal__c, '+
    															'Deal__r.Is_Deal_Fulfilled__c, '+
    															'Fee__r.Category__r.COGS_GL__c, '+
                                                                'Fee__r.Category__r.Income_GL__c, '+
                                                                'Fee__r.Category__r.Inventory_GL__c, '+
                                                                
                                                                'Product__r.Category__r.COGS_GL__c, '+
                                                                'Product__r.Category__r.Income_GL__c, '+
                                                                'Product__r.Category__r.Inventory_GL__c, '+
                                                                
                                                                'Fee__r.Applicable_Tax__r.Name__c,'+
                                                                'Labour_Code__r.Applicable_Tax__r.Name__c,'+
                                                                'Product__r.Applicable_Tax__r.Name__c, Product__r.Type__c, Product__r.Cost__c, Product__r.Cost_Method__c,'+
                                                                'Part__r.Applicable_Tax__r.Name__c,'+
                                                                
                                                                'Sales_Tax_Percentage__c, Price_When_Tax_Included__c from Options_Fees__r), '+
                                                                '(Select Item_Description__c, Total_Price__c, Tax_Amount__c, Price_When_Tax_Included__c, Qty__c, Price__c, '+
                                                                'Unit_Price_Cost__r.Qty__c, Unit_Price_Cost__r.Total_Cost__c, Type__c,'+    
                                                                'Sales_Tax_Percentage__c, Applicable_Tax__r.Name__c from Deal_Unit_Prices_Costs__r Order By Type__c)',
                                            
                                            'F_I_Product__c' => 'Vendor_Product__r.Applicable_Tax__r.Name__c,' +
                                                        'Vendor_Product__r.Category__c, Vendor_Product__r.Category__r.AccountingId__c, Vendor_Product__r.Category__r.Name,' +
                                                        'Vendor_Product__r.Category__r.COGS_GL__c, Vendor_Product__r.Category__r.Income_GL__c, Vendor_Product__r.Category__r.Inventory_GL__c,' +
                                                        'Vendor_Product__r.Cost_Method__c, Vendor_Product__r.Cost__c',
                                                
                                            'CO_Invoice_Item__c' => 'Id, Name, CreatedDate, CO_Invoice_Header__r.Name, CO_Invoice_Header__r.Invoice_Number__c, '+
                                                                        'CO_Invoice_Header__r.Invoice_Status__c, CO_Invoice_Header__r.Invoice_Date__c, '+
                                                                        'CO_Invoice_Header__r.Checkout_Type__c, CO_Invoice_Header__r.Total_Amount_Except_Charge_Account__c,' +
                                                                        'CO_Invoice_Header__r.CO_Header__r.Order_Total__c,'+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Name, CO_Invoice_Header__r.CO_Header__r.Customer__r.Name, '+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c, CO_Line_Item__r.CO_Header__r.Name, '+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c, Service_Order_Header__r.Deal__c ,'+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c, '+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c,Service_Order_Header__r.Deal_Item__c,'+
                                                                        'Service_Order_Header__r.Deal_Item__r.Deal__c,Service_Order_Header__r.Total__c,SO_Payment_Role__r.Total_Amount__c,'+
                                                                        'SO_Payment_Role__r.RecordType.DeveloperName,Service_Order_Header__r.Provider__r.Name,Service_Order_Header__r.Provider__r.Vendor_Code__c,'+
																		'Service_Order_Header__r.Job_Type__c, Service_Order_Header__r.Customer_Owned_Unit__r.Category__r.Inventory_GL__c,'+
                                                                        //'Service_Order_Header__r.Customer_Owned_Unit__r.Stock_Id__c,'+
																		//'Service_Order_Header__r.Customer_Owned_Unit__r.Applicable_Tax__r.Name__c,'+
																		'Service_Order_Header__r.Transaction_Type__r.Type__c,' +
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer_Name__c,CO_Invoice_Header__r.Total__c,'+
                                                                        'CO_Kit_Header__r.Deal__c,'+
                                                                        'CO_Line_Item__r.Deal__c, '+
                                                                        'CO_Line_Item__r.Price__c,'+
                                                                        'CO_Line_Item__r.Qty__c,'+
                                                                        'CO_Line_Item__r.Tax__c, '+
                                                                        'CO_Line_Item__r.Adjusted_Cost_Coli__c, '+
                                                                        'CO_Line_Item__r.Part__r.Part_Number__c,'+
                                                                        'CO_Line_Item__r.Part__r.Description__c, '+
                                                                        'CO_Line_Item__r.Part__r.Last_Cost__c, '+
                                                                        'CO_Line_Item__r.Part__r.Category__r.COGS_GL__c, '+
                                                                        'CO_Line_Item__r.Part__r.Category__r.Income_GL__c, '+
                                                                        'CO_Line_Item__r.Part__r.Category__r.Inventory_GL__c, '+
                                                                        'CO_Line_Item__r.Part__r.Applicable_Tax__r.Name__c,'+
                                                                        'CO_Line_Item__r.Price_When_Tax_Included__c,'+
                                                                        
                                                                        'CO_Line_Item__r.Fee__r.Code__c,'+
                                                                        'CO_Line_Item__r.Fee__r.Description__c, '+
                                                                        'CO_Line_Item__r.Fee__r.Cost_Rate__c, '+
                                                                        'CO_Line_Item__r.Fee__r.Cost_Method__c, '+
                                                                        'CO_Line_Item__r.Fee__r.Category__r.COGS_GL__c, '+
                                                                        'CO_Line_Item__r.Fee__r.Category__r.Income_GL__c, '+
                                                                        'CO_Line_Item__r.Fee__r.Category__r.Inventory_GL__c, '+
                                                                        'CO_Line_Item__r.Fee__r.Applicable_Tax__r.Name__c,'+
                                                                        
                                                                        'CO_Line_Item__r.Deal__r.Invoice_Number__r.CreatedDate, '+
																		'CO_Line_Item__r.Deal__r.Invoice_Number__c, '+
																		'CO_Line_Item__r.Invoice_Number__r.CreatedDate, '+
																		'CO_Line_Item__r.Invoice_Number__c, '+
																		//'CO_Invoice_Header__r.CO_Header__r.Customer__r.Sales_Tax__r.Name__c, '+
                                                                        'CO_Line_Item__r.Avg_Cost__c, '+
                                                                        'CO_Invoice_Header__r.CO_Header__r.CO_Type__c, CO_Invoice_Header__r.SalesTax_Total__c',
                                                                        
                                            'CO_Invoice_Payment__c' => 'Name, CreatedDate, CO_Invoice_Header__r.CO_Header__r.Name, '+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer_Name__c, CO_Invoice_Header__r.CO_Header__r.CO_Type__c, ' +
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.FirstName__c, CO_Invoice_Header__r.CO_Header__r.Customer__r.Type__c, '+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.LastName__c, CO_Invoice_Header__r.CO_Header__r.Customer__r.Name, '+
                                                                        'CO_Invoice_Header__r.CO_Header__r.Customer__r.Customer_Number__c',
                                            
                                            'Store_Credit__c' => 'Name, CreatedDate, Customer__r.Name, Customer__r.FirstName__c, Customer__r.LastName__c, '+
                                                                        'Customer__r.Customer_Number__c, Customer__r.Type__c',
                                                                                                    
                                            'CO_Deposit__c' => 'Name, CreatedDate, CO_Header__r.Customer__r.Name, CO_Header__r.Customer__r.FirstName__c, CO_Header__r.Name,'+
                                                                'CO_Header__r.CO_Type__c, CO_Header__r.Customer__r.Type__c,'+
                                                                'CO_Header__r.Customer__r.LastName__c, CO_Header__r.Customer__r.Customer_Number__c, CO_Header__r.Customer_Name__c', 
                                                    
                                            'Vendor_Invoicing_Group__c' => 'Id, Name, CreatedDate, Vendor_Receiving_Group__r.Recieved__c, Vendor_Receiving_Group__r.Cost__c, '+
                                                    'Vendor_Receiving_Group__r.Part__c, ' +
                                                    'Vendor_Receiving_Group__r.Part__r.Part_Number__c, '+
                                                    'Vendor_Receiving_Group__r.Part__r.Description__c, '+
                                                    'Vendor_Receiving_Group__r.Part__r.Category__r.COGS_GL__c, '+
                                                    'Vendor_Receiving_Group__r.Part__r.Category__r.Income_GL__c, '+
                                                    'Vendor_Receiving_Group__r.Part__r.Category__r.Inventory_GL__c, '+
                                                    'Vendor_Receiving_Group__r.Part__r.Package_Qty__c, '+
                                                    'Vendor_Receiving_Group__r.Part__r.Packaged_Part__c, '+
                                                    
                                                    'Vendor_Receiving_Group__r.Sublet__c, '+
                                                    'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Code__c, ' +
                                                    'Vendor_Receiving_Group__r.Service_Order_Line_Item__r.Item_Description__c, ' +
                                                    'Vendor_Receiving_Group__r.Sublet__r.Category__r.Inventory_GL__c, '+
                                                    
                                                    'Vendor_Invoicing_Header__r.Name, Vendor_Invoicing_Header__r.Status__c, '+
                                                    'Vendor_Invoicing_Header__r.Invoice_Number__c, Vendor_Invoicing_Header__r.Invoice_Date__c, '+
                                                    'Vendor_Invoicing_Header__r.Vendor__r.Name, Vendor_Invoicing_Header__r.Vendor__r.LastName__c, '+
                                                    'Vendor_Invoicing_Header__r.Vendor__r.Vendor_Code__c, Vendor_Invoicing_Header__r.Vendor__r.Type__c, '+
                                                    'Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__c,' + 
                                                    'Vendor_Invoicing_Header__r.Applicable_Purchase_Tax_Name__c, Vendor_Invoicing_Header__r.Total__c, '+
                                                    'Vendor_Invoicing_Header__r.Vendor__r.Purchase_Tax__r.Rate__c',
                                                    
                                            'Vendor_Receiving_Group__c' => 'Name, CreatedDate, Vendor_Receiving_Header__r.Name, Vendor_Receiving_Header__r.Vendor__r.Name, '+
                                                    'Vendor_Receiving_Header__r.Packing_Slip_Number__c, Vendor_Receiving_Header__r.Finalized_Date__c, Part__r.Part_Number__c, '+
                                                    'Part__r.Description__c, Part__r.Category__r.Inventory_GL__c, Vendor_Receiving_Header__r.Vendor__r.Sales_Tax__r.Name__c, ' +
                                                    'Service_Order_Line_Item__r.Item_Code__c, Service_Order_Line_Item__r.Item_Description__c, Sublet__r.Category__r.Inventory_GL__c',
                                            
                                            'Part_FIFO_Bucket__c' => 'Id, Name, CreatedDate, Part__r.Part_Number__c, Part__r.Part_ID__c, Part__r.Category__r.Inventory_GL__c, ' +
                                                    'Part__r.Category__r.COGS_GL__c, Customer_Return__r.Invoice_Number__c, ' +
                                                    '(Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, ' +
                                                    'CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r where (CO_Invoice_Header__c = null AND Return_VO_Header__c = null))',
                                                    
                                            'Part_FIFO_Bucket_Activity_Line_Item__c' => 'Name, Part_Adjustment__r.Unique_Id__c, Part_FIFO_Bucket__r.Unique_Id__c, LastModifiedDate, CreatedDate, Part_FIFO_Bucket__r.Qty_In__c, ' +
                                                    'Part_FIFO_Bucket__r.Part__r.Category__r.Inventory_GL__c, Part_FIFO_Bucket__r.Cost__c, Part_FIFO_Bucket__r.Part__r.Part_ID__c, ' +
                                                    'Part_FIFO_Bucket__r.Reference__c, Part_FIFO_Bucket__r.Source_Name__c,Return_VO_Header__r.RMA__c',
                                            
                                            'Unit_Price_Cost__c' => 'Name, CreatedDate, Customer_Owned_Unit__r.Stock_Id__c, Customer_Owned_Unit__r.Referenced_Unit__r.Unit_Id__c, '+ 
                                                                        'Customer_Owned_Unit__r.Unit_Id__c, Customer_Owned_Unit__r.Category__r.Inventory_GL__c',
                                            
                                            'Customer_Owned_Unit__c' => 'Name, Referenced_Unit__r.Unit_Id__c,Referenced_Unit__r.Vendor__r.Name,Vendor__r.Name,' +
                                                                        'Referenced_Unit__r.Vendor__r.Purchase_Tax__r.Name__c, Referenced_Unit__r.Vendor__r.Purchase_Tax__r.Rate__c,' +
                                                                        'Category__r.Inventory_GL__c, Unit_Make__r.Name, Unit_Model__r.Name__c, Sub_Model__r.Sub_Model_Name__c,' +
                                                                        'Vendor__r.Vendor_Code__c, Referenced_Unit__r.Vendor__r.Vendor_Code__c',
                                                                        
                                            'Return_VO_Line_Item__c' => 'Id, Name, Return_VO_Header__r.Status__c, Return_VO_Header__r.Submitted_Date__c,' +
													'Part__r.Part_Number__c, Part__r.Description__c,Part__r.Category__r.Inventory_GL__c, Return_VO_Header__r.Vendor__r.Vendor_Code__c,' +
													'Return_VO_Header__r.Credit_Memo__c, Return_VO_Header__r.Vendor__r.Name, Return_VO_Header__r.Name, Return_VO_Header__r.Return_Total__c, ' +
                                                    'Return_VO_Header__r.Vendor__r.Purchase_Tax__r.Rate__c, Return_VO_Header__r.Vendor__r.Purchase_Tax__r.Name__c, ' +
													'Return_VO_Header__r.Credited_Date__c,Return_VO_Header__r.Returned_Date__c,Return_VO_Header__r.RMA__c, Return_VO_Header__r.AccountingId__c, ' +
                                                    '(Select Name, Part_FIFO_Bucket__c, Qty_Out__c, CO_Line_Item__c, Part_Adjustment__r.Unique_Id__c,Type__c, Part_Adjustment__c, ' +
													'CreatedDate, Reference__c, Unique_Id__c, CO_Invoice_Header__c From Part_FIFO_Bucket_Activity_Line_Items__r)',
													
                                            'Service_Order_Header__c' => 'Id, (Select Id, Provider_Claim_Number__c From Claims__r), (Select Id, Total_Amount__c, RecordType.DeveloperName From SO_Payment_Roles__r ' +
                                                    'where RecordType.DeveloperName = \'Deductible\')'
                                            };
                                                                            
    public static Map<String, String> objectNameToFilterMap = new Map<String, String>{'Customers'   => ' WHERE (Is_Customer__c = true OR Is_Used_For_Accouting__c = true) ',
                                            'Vendors'       => ' WHERE Is_Vendor__c = true',
                                            
                                            'CO_Invoice_Item__c' => ' WHERE ((CO_Invoice_Header__r.Invoice_Status__c = \'Closed\') AND ((((CO_Line_Item__r.Is_In_Merch_Section__c = true) AND '+
                                                            '(CO_Line_Item__r.Avg_Cost__c != 0)) OR ((CO_Line_Item__r.Service_Order_Line_Item__c = null) AND '+
                                                            '((CO_Line_Item__r.Related_Option_And_Fees__c != null) OR (CO_Line_Item__r.Deal__c != null)))) OR (CO_Kit_Header__c != null) OR (Service_Order_Header__c != null) OR (Deal__c != null)))',
                                            
                                            'StockInTradedUnit' => ' WHERE Type__c = \'Trade In\' AND Is_Stocked_In__c = true',
                                            
                                            'CO_Invoice_Payment__c' => ' WHERE Payment_Method__c NOT IN (\'Deposit\', \'Use Deposit\', \'Use Deal Deposit\', \'Charge Account\') AND Amount__c != 0',
                                            
                                            'Store_Credit__c' => ' WHERE Amount__c != 0 AND CO_Invoice_Header__c = null',
                                            
                                            'CO_Deposit__c' => ' WHERE Amount__c != 0 AND Payment_Method__c != \'Invoice\' ',
                                            
                                            'Vendor_Invoicing_Group__c' => ' WHERE VI_Cost__c != 0 AND VI_Qty__c != 0 AND Vendor_Receiving_Group__c != null AND Vendor_Invoicing_Header__r.Status__c = \'Invoiced\'',
                                            
                                            'Vendor_Receiving_Group__c' => ' WHERE Cost__c != 0 AND Recieved__c != 0 AND Vendor_Receiving_Header__r.Status__c = \'Stocked\'',
                                            
                                            'Part_FIFO_Bucket__c' => ' WHERE (Reference__c LIKE \'%Adjustment\' OR Reference__c Like \'re%\' OR Source_Name__c = \'Oversold\') AND (Vendor_Invoicing_Header__c = null AND Vendor_Receiving_Header__c = null AND Customer_Return__c = null)',
                                            
                                            'Part_FIFO_Bucket_Activity_Line_Item__c' => ' WHERE (Reference__c = \'Count Adjustment\' OR Reference__c = \'Cost Adjustment\') ' +
                                                                                                 'AND (CO_Invoice_Header__c = null AND Return_VO_Header__c = null)',
                                            
                                            'Unit_Price_Cost__c' => ' WHERE Customer_Owned_Unit__c != null AND Customer_Owned_Unit__r.Unit_Type__c = \'STOCK\' AND Ref_No__c Like \'UA-%\' ' +
                                                                                         'AND Total_Cost__c != 0 AND Total_Cost__c != null AND Type__c != \'Dealer\'',
                                            'Customer_Owned_Unit__c' => ' WHERE Unit_Type__c = \'STOCK\' AND Referenced_Unit__c != null',                                            
                                            'Return_VO_Line_Item__c' => ' WHERE Return_VO_Header__r.Status__c = \'Credited\''
                                        };
                                        
    public static Map<String, String> objectNameToOrderByFieldMap = new Map<String, String>{'Customers' => 'LastName__c',
                                                                                    'Vendors'   => 'Name',
                                                                                    'StockInTradedUnit' => 'Deal__r.CO_Header__r.Name',
                                                                                    'Deal_Item__c' => 'Type__c',
                                                                                    'CO_Invoice_Item__c' => 'CO_Invoice_Header__r.Invoice_Number__c',
                                                                                    'CO_Invoice_Payment__c' => 'Payment_Date__c',
                                                                                    'Store_Credit__c' => 'LastModifiedDate',
                                                                                    'CO_Deposit__c' => 'Payment_Date__c',
                                                                                    'Vendor_Invoicing_Group__c' => 'Vendor_Invoicing_Header__r.Invoice_Number__c',
                                                                                    'Vendor_Receiving_Group__c' => 'Vendor_Receiving_Header__r.Packing_Slip_Number__c',
                                                                                    'Part_FIFO_Bucket__c' => 'LastModifiedDate',
                                                                                    'Return_VO_Line_Item__c' => 'Return_VO_Header__r.Name'
                                                                                };
                                                            
    public static Map<String, List<String>> objNameToOrderedCardFieldMap = new Map<String, List<String>>{
                            'Customers' => new List<String>{'First_Name__c', 'Last_Name__c','Card_Id__c','Addr1_Line_1__c','Addr1_Line_2__c','Addr1_City__c','Addr1_State__c','Addr1_Postcode__c',
                                                            'Addr1_Country__c','Phone_No_1__c','Phone_No_2__c','Fax_No__c','Email__c','WWW__c',
                                                            'Addr2_Line_1__c','Addr2_Line_2__c','Addr2_City__c','Addr2_State__c','Addr2_Postcode__c','Addr2_Country__c',
                                                            'SP_Layout__c','Use_Cust_Tax__c'},
                            'Vendors' => new List<String>{'Name', 'Card_Id__c', 'Addr1_Line_1__c', 'Addr1_Line_2__c','Addr1_City__c','Addr1_State__c','Addr1_Postcode__c',
                                                            'Addr1_Country__c','Phone_No_1__c','Phone_No_2__c','Fax_No__c','Email__c','WWW__c',
                                                            'Addr2_Line_1__c','Addr2_Line_2__c','Addr2_City__c','Addr2_State__c','Addr2_Postcode__c','Addr2_Country__c', 'Tax_Code__c',
                                                            'SP_Layout__c','Use_Supp_Tax__c'},
                                                            
                            'CO_Invoice_Payment__c' => new List<String>{'Deposit_Account__c','Date__c','Last_Name__c','First_Name__c','Memo__c','Allocation_Account_No__c',
                                                            'Amount__c','Payment_Method__c','Name_On_Card__c','Card_ID__c'},
                                                            
                            'CO_Deposit__c' => new List<String>{'Deposit_Account__c','Date__c','Last_Name__c','First_Name__c','Memo__c','Allocation_Account_No__c',
                                                            'Amount__c','Payment_Method__c','Name_On_Card__c','Card_ID__c'},
                            
                            'Part_FIFO_Bucket__c' => new List<String>{'Journal_Number__c','Date__c','Memo__c','Reporting__c','Inclusive__c','Account_No__c',
                                                            'Is_Credit__c','Amount__c','Tax_Code__c','Allocation_Memo__c'},
                                                            
                            'CO_Invoice_Item__c' => new List<String>{'Last_Name__c','First_Name__c','Invoice_No__c','Date__c',
                                                                'Inclusive__c','Memo__c','Description__c','Account_No__c','Amount__c','Tax_Code__c','Tax_Amount__c',
                                                                'Card_ID__c'},
                                                                
                            'Vendor_Receiving_Group__c' => new List<String>{'Journal_Number__c','Date__c','Memo__c','Reporting__c','Inclusive__c','Account_No__c',
                                                                'Is_Credit__c','Amount__c','Tax_Code__c','Allocation_Memo__c'},
                                                                                                    
                            'Customer Sales Invoice Payment' => new List<String>{'Last_Name__c','First_Name__c','Account_No__c','Id_No__c',
                                                                'Date__c','Invoice_No__c','Amount__c','Memo__c','Card_ID__c'},
                                                                
                            'Customer Sales GL' => new List<String>{'Journal_Number__c','Date__c','Memo__c','Reporting__c','Inclusive__c','Account_No__c',
                                                                'Amount__c','Is_Credit__c','Tax_Code__c','Allocation_Memo__c'},
                                                                
                            'Vendor Invoice' => new List<String>{'Last_Name__c','Date__c','Supplier_Invoice_No__c','Inclusive__c','Memo__c','Description__c','Account_No__c',
                                                                    'Amount__c','Tax_Code__c','Tax_Amount__c','Payment_Status__c','Card_ID__c'}                                         
                            };
    
    public static String createImportableText(Map<Integer, Map<String,String>> cardRecords, String objectName) {
        String headerLengthRowString = '';
        String headerRowString = '';
        String contentsString = '';
        Map<String, String> cardSFFieldToAccountingFieldsMap = (objNameToCardSFFieldToAccountingFieldsMap.containsKey(objectName)) ? objNameToCardSFFieldToAccountingFieldsMap.get(objectName) : new Map<String, String>();
        for(Integer indexVal : cardRecords.keySet()){
            Map<String, String> card = cardRecords.get(indexVal);
            contentsString += '\n';
            
            for(String fieldSFName : objNameToOrderedCardFieldMap.get(objectName)){
                if(indexVal == 1){
                    headerLengthRowString += (headerLengthRowString.length() == 0) ? '{}' : fileSeparator;
                    headerRowString += cardSFFieldToAccountingFieldsMap.get(fieldSFName) + fileSeparator;
                }
                
                String value = (card.get(fieldSFName) != null) ? card.get(fieldSFName) : '';
                value = value.replace('\r\n', ' ').replace('\n', ' ').replace('\r', ' ');
                contentsString += value + fileSeparator;
            }
            contentsString = contentsString.subString(0, contentsString.length() - 1);
        }
        return ((headerLengthRowString.length() != 0) ? (headerLengthRowString.subString(0, headerLengthRowString.length()-1) + '\n') : '')
                   + ((headerRowString.length() != 0) ? (headerRowString.subString(0, headerRowString.length()-1)) : '') 
                   + contentsString;
    }
    
    public static String createImportableTextForInvoice(Integer indexVal, Map<String,String> invoiceItemRecord, Map<String, String> invoiceItemSFFieldToAccountingFieldsMap, String objectName) {
        String headerLengthRowString = '';
        String headerRowString = '';
        String contentsString = '\n';
        
        // Create file header with software voInvoice object fields
        if(invoiceItemRecord.size() > 0){
            for(String invoiceItemFieldSFName : objNameToOrderedCardFieldMap.get(objectName)){
                // Populate 1st row for file which is for purpose of total object fields
                if(indexVal == 1){
                    headerLengthRowString += (headerLengthRowString.length() == 0) ? '{}' : fileSeparator;
                    headerRowString += invoiceItemSFFieldToAccountingFieldsMap.get(invoiceItemFieldSFName) + fileSeparator;
                }
                
                // Now populate voInvoice records data text
                String value = (invoiceItemRecord.get(invoiceItemFieldSFName) != null) ? invoiceItemRecord.get(invoiceItemFieldSFName) : '';
                value = value.replace('\r\n', ' ').replace('\n', ' ').replace('\r', ' ');
                contentsString += value + fileSeparator;
            }
            
            headerLengthRowString = (indexVal == 1) ? headerLengthRowString.subString(0, headerLengthRowString.length()-1) + '\n' : headerLengthRowString;
            headerRowString = (indexVal == 1) ? headerRowString.subString(0, headerRowString.length()-1) : headerRowString;
            contentsString = contentsString.subString(0, contentsString.length() - 1);
        }
        
        return headerLengthRowString + headerRowString + contentsString;
    }
    
    public static Map<String, Map<String, String>> objNameToCardSFFieldToAccountingFieldsMap = new Map<String, Map<String, String>>{
                                                                        'Customers' => new Map<String, String>{'Card_Id__c'     =>  'Card ID',
                                                                                                         'Card_Status__c'   =>  'Card Status',
                                                                                                         'First_Name__c'    =>  'First Name',
                                                                                                         'Last_Name__c'     =>  'Co./Last Name',
                                                                                                         'Addr1_Line_1__c'  =>  'Addr 1 - Line 1',
                                                                                                         'Addr1_Line_2__c'  =>  'Addr 1 - Line 2',
                                                                                                         'Addr1_Line_3__c'  =>  'Addr 1 - Line 3',
                                                                                                         'Addr1_Line_4__c'  =>  'Addr 1 - Line 4',
                                                                                                         'Addr1_City__c'    =>  'Addr 1 - City',
                                                                                                         'Addr1_State__c'   =>  'Addr 1 - State',
                                                                                                         'Addr1_Postcode__c'=>  'Addr 1 - Postcode',
                                                                                                         'Addr1_Country__c' =>  'Addr 1 - Country',
                                                                                                         'Addr2_Line_1__c'  =>  'Addr 2 - Line 1',
                                                                                                         'Addr2_Line_2__c'  =>  'Addr 2 - Line 2',
                                                                                                         'Addr2_Line_3__c'  =>  'Addr 2 - Line 3',
                                                                                                         'Addr2_Line_4__c'  =>  'Addr 2 - Line 4',
                                                                                                         'Addr2_City__c'    =>  'Addr 2 - City',
                                                                                                         'Addr2_State__c'   =>  'Addr 2 - State',
                                                                                                         'Addr2_Postcode__c'=>  'Addr 2 - Postcode',
                                                                                                         'Addr2_Country__c' =>  'Addr 2 - Country',
                                                                                                         'Addr3_Line_1__c'  =>  'Addr 3 - Line 1',
                                                                                                         'Addr3_Line_2__c'  =>  'Addr 3 - Line 2',
                                                                                                         'Addr3_Line_3__c'  =>  'Addr 3 - Line 3',
                                                                                                         'Addr3_Line_4__c'  =>  'Addr 3 - Line 4',
                                                                                                         'Addr3_City__c'    =>  'Addr 3 - City',
                                                                                                         'Addr3_State__c'   =>  'Addr 3 - State',
                                                                                                         'Addr3_Postcode__c'=>  'Addr 3 - Postcode',
                                                                                                         'Addr3_Country__c' =>  'Addr 3 - Country',
                                                                                                         'Addr4_Line_1__c'  =>  'Addr 4 - Line 1',
                                                                                                         'Addr4_Line_2__c'  =>  'Addr 4 - Line 2',
                                                                                                         'Addr4_Line_3__c'  =>  'Addr 4 - Line 3',
                                                                                                         'Addr4_Line_4__c'  =>  'Addr 4 - Line 4',
                                                                                                         'Addr4_City__c'    =>  'Addr 4 - City',
                                                                                                         'Addr4_State__c'   =>  'Addr 4 - State',
                                                                                                         'Addr4_Postcode__c'=>  'Addr 4 - Postcode',
                                                                                                         'Addr4_Country__c' =>  'Addr 4 - Country',
                                                                                                         'WWW__c'           =>  'Addr 1 - WWW',
                                                                                                         'Email__c'         =>  'Addr 1 - Email',
                                                                                                         'Other_Email__c'   =>  'Addr 2 - Email',
                                                                                                         'Phone_No_1__c'    =>  'Addr 1 - Phone No. 1',
                                                                                                         'Phone_No_2__c'    =>  'Addr 1 - Phone No. 2',
                                                                                                         'Phone_No_3__c'    =>  'Addr 1 - Phone No. 3',
                                                                                                         'Fax_No__c'        =>  'Addr 1 - Fax No.',
                                                                                                         'Notes__c'         =>  'Notes',
                                                                                                         'SP_Layout__c'     =>  'Sales/Purchase Layout',
                                                                                                         'Use_Cust_Tax__c'  =>  'Use Customer\'s Tax Code'
                                                                                                        },
                                                                'Vendors' => new Map<String, String>{    'Name'     =>  'Co./Last Name',
                                                                                                         'Card_Id__c'       =>  'Card ID',
                                                                                                         'Addr1_Line_1__c'  =>  'Addr 1 - Line 1',
                                                                                                         'Addr1_Line_2__c'  =>  'Addr 1 - Line 2',
                                                                                                         'Addr1_City__c'    =>  'Addr 1 - City',
                                                                                                         'Addr1_State__c'   =>  'Addr 1 - State',
                                                                                                         'Addr1_Postcode__c'=>  'Addr 1 - Postcode',
                                                                                                         'Addr1_Country__c' =>  'Addr 1 - Country',
                                                                                                         'Phone_No_1__c'    =>  'Addr 1 - Phone No. 1',
                                                                                                         'Phone_No_2__c'    =>  'Addr 1 - Phone No. 2',
                                                                                                         'Fax_No__c'        =>  'Addr 1 - Fax No.',
                                                                                                         'Email__c'         =>  'Addr 1 - Email',
                                                                                                         'WWW__c'           =>  'Addr 1 - WWW',
                                                                                                         'Addr2_Line_1__c'  =>  'Addr 2 - Line 1',
                                                                                                         'Addr2_Line_2__c'  =>  'Addr 2 - Line 2',
                                                                                                         'Addr2_City__c'    =>  'Addr 2 - City',
                                                                                                         'Addr2_State__c'   =>  'Addr 2 - State',
                                                                                                         'Addr2_Postcode__c'=>  'Addr 2 - Postcode',
                                                                                                         'Addr2_Country__c' =>  'Addr 2 - Country',
                                                                                                         'Tax_Code__c'      =>  'Tax Code',
                                                                                                         'SP_Layout__c'     =>  'Sales/Purchase Layout',
                                                                                                         'Use_Supp_Tax__c'  =>  'Use Supplier\'s Tax Code'  
                                                                                                         },
                                                                'CO_Invoice_Payment__c' => new Map<String, String>{'Deposit_Account__c'     =>  'Deposit Account',
                                                                                                         'Date__c'                  =>  'Date',
                                                                                                         'Last_Name__c'             =>  'Co./Last Name',
                                                                                                         'First_Name__c'            =>  'First Name',
                                                                                                         'Memo__c'                  =>  'Memo',
                                                                                                         'Allocation_Account_No__c' =>  'Allocation Account No.',
                                                                                                         'Amount__c'                =>  'Amount',
                                                                                                         'Payment_Method__c'        =>  'Payment Method',
                                                                                                         'Name_On_Card__c'          =>  'Name On Card',
                                                                                                         'Card_ID__c'               =>  'Card ID'
                                                                                                         },
                                                                                                         
                                                                'CO_Deposit__c' => new Map<String, String>{'Deposit_Account__c'     =>  'Deposit Account',
                                                                                                         'Date__c'                  =>  'Date',
                                                                                                         'Last_Name__c'             =>  'Co./Last Name',
                                                                                                         'First_Name__c'            =>  'First Name',
                                                                                                         'Memo__c'                  =>  'Memo',
                                                                                                         'Allocation_Account_No__c' =>  'Allocation Account No.',
                                                                                                         'Amount__c'                =>  'Amount',
                                                                                                         'Payment_Method__c'        =>  'Payment Method',
                                                                                                         'Name_On_Card__c'          =>  'Name On Card',
                                                                                                         'Card_ID__c'               =>  'Card ID'
                                                                                                         },
                                                                'Vendor_Receiving_Group__c' => new Map<String, String>{  'Journal_Number__c'   =>  'Journal Number',
                                                                                                          'Date__c'             =>  'Date',
                                                                                                          'Memo__c'             =>  'Memo',
                                                                                                          'Reporting__c'        =>  'GST (BAS) Reporting',
                                                                                                          'Inclusive__c'        =>  'Inclusive',
                                                                                                          'Account_No__c'       =>  'Account Number',
                                                                                                          'Is_Credit__c'        =>  'Is Credit',
                                                                                                          'Amount__c'           =>  'Amount',
                                                                                                          'Tax_Code__c'         =>  'Tax Code',
                                                                                                          'Allocation_Memo__c'  =>  'Allocation Memo'
                                                                                                        },
                                                                                                        
                                                                'Part_FIFO_Bucket__c'   => new Map<String, String>{  'Journal_Number__c'   =>  'Journal Number',
                                                                                                          'Date__c'             =>  'Date',
                                                                                                          'Memo__c'             =>  'Memo',
                                                                                                          'Reporting__c'        =>  'GST (BAS) Reporting',
                                                                                                          'Inclusive__c'        =>  'Inclusive',
                                                                                                          'Account_No__c'       =>  'Account Number',
                                                                                                          'Is_Credit__c'        =>  'Is Credit',
                                                                                                          'Amount__c'           =>  'Amount',
                                                                                                          'Tax_Code__c'         =>  'Tax Code',
                                                                                                          'Allocation_Memo__c'  =>  'Allocation Memo'
                                                                                                        },
                                                                                                        
                                                                'Vendor Invoice'    => new Map<String, String>{  'Last_Name__c'         =>  'Co./Last Name',
                                                                                                                'Date__c'               =>  'Date',
                                                                                                                'Supplier_Invoice_No__c'=>  'Supplier Invoice No.',
                                                                                                                'Inclusive__c'          =>  'Inclusive',
                                                                                                                'Memo__c'               =>  'Memo',
                                                                                                                'Description__c'        =>  'Description',
                                                                                                                'Account_No__c'         =>  'Account Number',
                                                                                                                'Amount__c'             =>  'Amount',
                                                                                                                'Tax_Code__c'           =>  'Tax Code',
                                                                                                                'Tax_Amount__c'         =>  'Tax Amount',
                                                                                                                'Payment_Status__c'     =>  'Payment Status',
                                                                                                                'Card_ID__c'            =>  'Card ID'
                                                                                                            }                                                                              
                                                                                                    };
                                                                                                    
}