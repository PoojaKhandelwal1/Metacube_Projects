/**
 * Author: Tarun Khandelwal
 * Since: August 23, 2018
 * Name: FusionReportService
 * Description: Service class for Fusion Report Ctrl
**/
public without sharing class FusionReportService {
    
    private static String QB_TOTOL_ASSETS = 'total assets';
    private static String QB_NET_INCOME = 'net earnings';
    private static String QB_TOTAL_EXPENSES = 'total expenses';
    
    public static void getBalanceSheetFromQB(String month, String year) {
        Map<String, Decimal> objKeyToNetIncomeMap = getReportData(month, year, true, 'BalanceSheet', new Set<String>{QB_TOTOL_ASSETS});
        Map<String, Decimal> objKeyToNetIncomeYearlyMap = getReportData(month, year, false, 'BalanceSheet', new Set<String>{QB_TOTOL_ASSETS});
        
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{'HDNet_Account__c' => 'Total Assets'});
        if(fusionLineItemList.size() > 0) {
            fusionLineItemList[0].Monthly_Value__c = objKeyToNetIncomeMap.containsKey(QB_TOTOL_ASSETS) ? objKeyToNetIncomeMap.get(QB_TOTOL_ASSETS) : 0;
            fusionLineItemList[0].Yearly_Value__c = objKeyToNetIncomeYearlyMap.containsKey(QB_TOTOL_ASSETS) ? objKeyToNetIncomeYearlyMap.get(QB_TOTOL_ASSETS) : 0;
            update fusionLineItemList;
        }
    }
    
    public static void getProfitAndLossFromQB(String month, String year) {
        Map<String, Decimal> objKeyToNetIncomeMap = getReportData(month, year, true, 'ProfitAndLoss', new Set<String>{QB_NET_INCOME, QB_TOTAL_EXPENSES});
        Map<String, Decimal> objKeyToNetIncomeYearlyMap = getReportData(month, year, false, 'ProfitAndLoss', new Set<String>{QB_NET_INCOME, QB_TOTAL_EXPENSES});
        
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{'Source__c' => 'Quickbooks'});
        List<Fusion_Report_Line_Item__c> fusionLineItemListToUpdate = new List<Fusion_Report_Line_Item__c>();
        if(fusionLineItemList.size() > 0) {
            for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
                if(fusionLineItemRec.HDNet_Account__c == 'Net Profit') {
                    fusionLineItemRec.Monthly_Value__c = objKeyToNetIncomeMap.containsKey(QB_NET_INCOME) ? objKeyToNetIncomeMap.get(QB_NET_INCOME) : 0;
                    fusionLineItemRec.Yearly_Value__c = objKeyToNetIncomeYearlyMap.containsKey(QB_NET_INCOME) ? objKeyToNetIncomeYearlyMap.get(QB_NET_INCOME) : 0;
                    fusionLineItemListToUpdate.add(fusionLineItemRec);
                } else if(fusionLineItemRec.HDNet_Account__c == 'Total Dealership Expense') {
                    fusionLineItemRec.Monthly_Value__c = objKeyToNetIncomeMap.containsKey(QB_TOTAL_EXPENSES) ? objKeyToNetIncomeMap.get(QB_TOTAL_EXPENSES) : 0;
                    fusionLineItemRec.Yearly_Value__c = objKeyToNetIncomeYearlyMap.containsKey(QB_TOTAL_EXPENSES) ? objKeyToNetIncomeYearlyMap.get(QB_TOTAL_EXPENSES) : 0;
                    fusionLineItemListToUpdate.add(fusionLineItemRec);
                }
            }
        }
        if(fusionLineItemListToUpdate.size() > 0) {
            update fusionLineItemListToUpdate;
        }
    }
    
    public static void getOtherAccountInfoFromQB(String month, String year) {
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{'Source__c' => 'Quickbooks'});
        Set<String> mappedAccountsNameSet = getMappedAccountsNameSet(fusionLineItemList);
        Map<String, Decimal> GLAccountNameToAmountMap = getAccountsInfo(month, year, true);
        updateAccountsInfoInBP(fusionLineItemList, GLAccountNameToAmountMap, true);
    }
    
    public static void getOtherAccountInfoFromQB_Yearly(String month, String year) {
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{'Source__c' => 'Quickbooks'});
        Set<String> mappedAccountsNameSet = getMappedAccountsNameSet(fusionLineItemList);
        Map<String, Decimal> GLAccountNameToAmountMap = getAccountsInfo(month, year, false);
        updateAccountsInfoInBP(fusionLineItemList, GLAccountNameToAmountMap, false);
    }
    
    private static Set<String> getMappedAccountsNameSet(List<Fusion_Report_Line_Item__c> fusionLineItemList) {
        Set<String> mappedAccountsNameSet = new Set<String>();
        for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
            for(Fusion_Line_Item_To_GL_Account_Junction__c junctionRec : fusionLineItemRec.Fusion_Line_Item_To_GL_Account_Junctions__r) {
                mappedAccountsNameSet.add(junctionRec.General_Account__r.Account_Name__c);
            }
        }
        mappedAccountsNameSet.remove(null);
        return mappedAccountsNameSet;
    }
    
    private static Map<String, Decimal> getAccountsInfo(String month, String year, Boolean isMonthly) {
        String startDate = getStartDateForMonth(month, year, isMonthly);
        String endDate = getEndDateForMonth(month, year);
        
        HttpResponse res = QuickbookConnector.getRequestFromQuickBooks('reports/ProfitAndLoss?start_date='+startDate+'&end_date='+endDate, null);
        QBReportWrapper responseObj = (QBReportWrapper)system.JSON.deserialize(res.getBody(), QBReportWrapper.class);
        
        Map<String, Decimal> GLAccountNameToAmountMap = new Map<String, Decimal>();
        if(responseObj != null && responseObj.Rows != null && responseObj.Rows.Row != null) {
            for(QBReportWrapper.cls_Row rowObj : responseObj.Rows.Row) {
                if(rowObj.Rows != null) {
                    for(QBReportWrapper.cls_Row innerRowObj : rowObj.Rows.Row) {
                        if(innerRowObj.ColData != null && innerRowObj.ColData.size() > 1) {
                            Decimal amount = (String.isNotBlank(innerRowObj.ColData[1].value) ? Decimal.valueOf(innerRowObj.ColData[1].value) : 0);
                            GLAccountNameToAmountMap.put(innerRowObj.ColData[0].value, amount);
                        }
                    }
                }
            }
        }
        return GLAccountNameToAmountMap;
    }
    
    private static void updateAccountsInfoInBP(List<Fusion_Report_Line_Item__c> fusionLineItemList, Map<String, Decimal> GLAccountNameToAmountMap,
                                                Boolean isMonthly) {
        for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
            if(fusionLineItemRec.Order_Number__c != 1 && fusionLineItemRec.Order_Number__c != 2 && fusionLineItemRec.Order_Number__c != 3) {
                Decimal amount = 0;
                for(Fusion_Line_Item_To_GL_Account_Junction__c junctionRec : fusionLineItemRec.Fusion_Line_Item_To_GL_Account_Junctions__r) {
                    String uniqueKey = (junctionRec.General_Account__r.Account_Number__c != null ? junctionRec.General_Account__r.Account_Number__c + ' ' : '') +
                                (junctionRec.General_Account__r.Account_Name__c != null ? junctionRec.General_Account__r.Account_Name__c : ''); 
                    if(GLAccountNameToAmountMap.containsKey(uniqueKey)) {
                        amount += GLAccountNameToAmountMap.get(uniqueKey);
                    }
                }
                if(isMonthly) {
                    fusionLineItemRec.Monthly_Value__c = amount;
                } else {
                    fusionLineItemRec.Yearly_Value__c = amount;
                }
            }
        }
        if(fusionLineItemList.size() > 0) {
            update fusionLineItemList;
        }
    }
    
    // BlackPurl Data
    public static String populateBlackpurlData(String month, String year) {
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{'Source__c' => 'Blackpurl'});
        Map<Integer, Set<String>> orderNumberToSetOfMappedGLsIdMap = new Map<Integer, Set<String>>();
        
        Map<Integer, Decimal> orderNumberToMontlyAmountMap = new Map<Integer, Decimal>();
        Map<Integer, Decimal> orderNumberToYearlyAmountMap = new Map<Integer, Decimal>();
        
        Date monthStartDate = getStartDateForMonth_BP(month, year);
        Date monthEndDate = getEndDateForMonth_BP(month, year);
        
        Date yearStartDate = getStartDateForYear_BP(year);
        Date yearEndDate = monthEndDate;
        
        for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
            if(!orderNumberToSetOfMappedGLsIdMap.containsKey(Integer.valueOf(fusionLineItemRec.Order_Number__c))) {
                orderNumberToSetOfMappedGLsIdMap.put(Integer.valueOf(fusionLineItemRec.Order_Number__c), new Set<String>{});
            }
            for(Fusion_Line_Item_To_GL_Account_Junction__c junctionRec : fusionLineItemRec.Fusion_Line_Item_To_GL_Account_Junctions__r) {
                orderNumberToSetOfMappedGLsIdMap.get(Integer.valueOf(fusionLineItemRec.Order_Number__c)).add(junctionRec.General_Account__r.Accounting_Id__c);
            }
            orderNumberToMontlyAmountMap.put(Integer.valueOf(fusionLineItemRec.Order_Number__c), 0);
            orderNumberToYearlyAmountMap.put(Integer.valueOf(fusionLineItemRec.Order_Number__c), 0);
        }
        
        // Line 11
        List<Customer_Owned_Unit__c> unitList = 
                [SELECT Id FROM Customer_Owned_Unit__c WHERE (Status__c = 'Available' OR Status__c = 'Reserved')
                    AND Category__r.Inventory_GL__c IN: orderNumberToSetOfMappedGLsIdMap.get(11)];
        
        orderNumberToMontlyAmountMap.put(11, unitList.size());
        orderNumberToYearlyAmountMap.put(11, unitList.size());
        
        // Line 12
        unitList = [SELECT Id FROM Customer_Owned_Unit__c WHERE (Status__c = 'Available' OR Status__c = 'Reserved')
                    AND Category__r.Inventory_GL__c IN: orderNumberToSetOfMappedGLsIdMap.get(12)];
        
        orderNumberToMontlyAmountMap.put(12, unitList.size());
        orderNumberToYearlyAmountMap.put(12, unitList.size());
        
        // Line 30 to 36 - New units
        // Line 42 - Used Units
        List<Deal_Item__c> dealItemList = 
            [SELECT Customer_Owned_Unit__r.Category__r.Inventory_GL__c, Customer_Owned_Unit__r.New_Unit__c, 
                    Deal__r.Invoice_Number__r.Invoice_Date_Formula__c FROM Deal_Item__c 
                WHERE Customer_Owned_Unit__r.Unit_Type__c = 'STOCK' AND
                      Customer_Owned_Unit__r.Status__c = 'Sold' AND
                      Customer_Owned_Unit__r.Category__c != null AND 
                      Deal__r.Invoice_Number__r.Invoice_Date_Formula__c >= : yearStartDate AND
                      Deal__r.Invoice_Number__r.Invoice_Date_Formula__c <= : yearEndDate];
        
        for(Deal_Item__c dealItemRec : dealItemList) {
            String inventoryGL = dealItemRec.Customer_Owned_Unit__r.Category__r.Inventory_GL__c;
            Date invoiceDate = dealItemRec.Deal__r.Invoice_Number__r.Invoice_Date_Formula__c;
            if(String.isNotBlank(inventoryGL) && invoiceDate != null) {
                if(dealItemRec.Customer_Owned_Unit__r.New_Unit__c) {
                    for(Integer orderNumber : newSoldUnitOrderNumberList) {
                        if(orderNumberToSetOfMappedGLsIdMap.get(orderNumber).contains(inventoryGL)) {
                            if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                                orderNumberToMontlyAmountMap.put(orderNumber, orderNumberToMontlyAmountMap.get(orderNumber) + 1);
                            }
                            orderNumberToYearlyAmountMap.put(orderNumber, orderNumberToYearlyAmountMap.get(orderNumber) + 1);
                        }
                    }
                } else {
                    if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                        orderNumberToMontlyAmountMap.put(42, orderNumberToMontlyAmountMap.get(42) + 1);             
                    }
                    orderNumberToYearlyAmountMap.put(42, orderNumberToYearlyAmountMap.get(42) + 1); 
                }
            }
        }
        
        // Line 38, 39
        List<Option_Fee__c> optionFeeList = 
            [SELECT Price__c, Qty__c, Part__c, Labour_Code__c, Deal_Item__r.Customer_Owned_Unit__r.New_Unit__c, 
                Deal_Item__r.Deal__r.Invoice_Number__r.Invoice_Date_Formula__c FROM Option_Fee__c 
                WHERE (Part__c != null OR Labour_Code__c != null) AND
                      Deal_Item__r.Type__c = 'Unit' AND
                      Deal_Item__r.Customer_Owned_Unit__r.Unit_Type__c = 'STOCK' AND
                      Deal_Item__r.Customer_Owned_Unit__r.Status__c = 'Sold' AND 
                      Deal_Item__r.Deal__r.Invoice_Number__r.Invoice_Date_Formula__c >=: yearStartDate AND
                      Deal_Item__r.Deal__r.Invoice_Number__r.Invoice_Date_Formula__c <=: yearEndDate];
        
        for(Option_Fee__c optionFeeRec : optionFeeList) {
            optionFeeRec.Qty__c = (optionFeeRec.Qty__c != null) ? optionFeeRec.Qty__c : 0;
            optionFeeRec.Price__c = (optionFeeRec.Price__c != null) ? optionFeeRec.Price__c : 0;
            Date invoiceDate = optionFeeRec.Deal_Item__r.Deal__r.Invoice_Number__r.Invoice_Date_Formula__c;
            
            if(invoiceDate != null) {
                if(optionFeeRec.Deal_Item__r.Customer_Owned_Unit__r.New_Unit__c) {
                    if(optionFeeRec.Part__c != null) {
                        if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                            orderNumberToMontlyAmountMap.put(38, orderNumberToMontlyAmountMap.get(38) + + (optionFeeRec.Qty__c * optionFeeRec.Price__c));
                        }
                        orderNumberToYearlyAmountMap.put(38, (orderNumberToYearlyAmountMap.get(38) + (optionFeeRec.Qty__c * optionFeeRec.Price__c)));
                    } else if(optionFeeRec.Labour_Code__c != null) {
                        if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                            orderNumberToMontlyAmountMap.put(39, orderNumberToMontlyAmountMap.get(39) + + (optionFeeRec.Qty__c * optionFeeRec.Price__c));
                        }
                        orderNumberToYearlyAmountMap.put(39, (orderNumberToYearlyAmountMap.get(39) + (optionFeeRec.Qty__c * optionFeeRec.Price__c)));
                    }
                } else {
                    if(optionFeeRec.Part__c != null) {
                        if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                            orderNumberToMontlyAmountMap.put(43, orderNumberToMontlyAmountMap.get(43) + + (optionFeeRec.Qty__c * optionFeeRec.Price__c));
                        }
                        orderNumberToYearlyAmountMap.put(43, (orderNumberToYearlyAmountMap.get(43) + (optionFeeRec.Qty__c * optionFeeRec.Price__c)));
                    } else if(optionFeeRec.Labour_Code__c != null) {
                        if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                            orderNumberToMontlyAmountMap.put(44, orderNumberToMontlyAmountMap.get(44) + + (optionFeeRec.Qty__c * optionFeeRec.Price__c));
                        }
                        orderNumberToYearlyAmountMap.put(44, (orderNumberToYearlyAmountMap.get(44) + (optionFeeRec.Qty__c * optionFeeRec.Price__c)));
                    }
                }
            }     
        }
        
        // Line 45, 46
        dealItemList = [SELECT Deal__c, Deal__r.Type__c, Customer_Owned_Unit__r.New_Unit__c, Deal__r.Invoice_Number__r.Invoice_Date_Formula__c 
                            FROM Deal_Item__c 
                            WHERE Customer_Owned_Unit__c != null AND
                                  Customer_Owned_Unit__r.Unit_Type__c = 'STOCK' AND
                                  Deal__r.Type__c = 'Financed' AND
                                  Deal__r.Invoice_Number__c != null AND
                                  Deal__r.Invoice_Number__r.Invoice_Date_Formula__c >=: yearStartDate AND
                                  Deal__r.Invoice_Number__r.Invoice_Date_Formula__c <=: yearEndDate];
        
        Set<Id> newUnitDealSet = new Set<Id>();
        Set<Id> usedUnitDealSet = new Set<Id>();
        Set<Id> newUnitDealYearSet = new Set<Id>();
        Set<Id> usedUnitDealYearSet = new Set<Id>();
        for(Deal_Item__c dealItemRec : dealItemList) {
            Date invoiceDate = dealItemRec.Deal__r.Invoice_Number__r.Invoice_Date_Formula__c;
            if(invoiceDate != null) {
                if(dealItemRec.Customer_Owned_Unit__r.New_Unit__c) {
                    if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                        newUnitDealSet.add(dealItemRec.Deal__c);
                    }
                    newUnitDealYearSet.add(dealItemRec.Deal__c);
                } else if(!dealItemRec.Customer_Owned_Unit__r.New_Unit__c) {
                    if(invoiceDate >= monthStartDate && invoiceDate <= monthEndDate) {
                        usedUnitDealSet.add(dealItemRec.Deal__c);
                    }
                    usedUnitDealYearSet.add(dealItemRec.Deal__c);
                }
            }
        }
        orderNumberToMontlyAmountMap.put(45, newUnitDealSet.size());
        orderNumberToMontlyAmountMap.put(46, usedUnitDealSet.size());
        orderNumberToYearlyAmountMap.put(45, newUnitDealYearSet.size());
        orderNumberToYearlyAmountMap.put(46, usedUnitDealYearSet.size());
        
        // Line 50
        List<AggregateResult> dealFinanceAggregateList = 
                [SELECT SUM(Amount_Financed__c) AMOUNT from Deal__c
                    WHERE Type__c = 'Financed' AND
                          Invoice_Number__c != null AND
                          Invoice_Number__r.Invoice_Date_Formula__c >=: yearStartDate AND
                          Invoice_Number__r.Invoice_Date_Formula__c <=: yearEndDate];
        
        if(dealFinanceAggregateList.size() > 0) {
            Decimal amount = (dealFinanceAggregateList[0].get('AMOUNT') != null) ? (Decimal)dealFinanceAggregateList[0].get('AMOUNT') : 0;
            orderNumberToYearlyAmountMap.put(50, amount);
        }
        
        // Line 50
        dealFinanceAggregateList = [SELECT SUM(Amount_Financed__c) AMOUNT from Deal__c
                                    WHERE Type__c = 'Financed' AND
                                          Invoice_Number__c != null AND
                                          Invoice_Number__r.Invoice_Date_Formula__c >=: monthStartDate AND
                                          Invoice_Number__r.Invoice_Date_Formula__c <=: monthEndDate];
        
        if(dealFinanceAggregateList.size() > 0) {
            Decimal amount = (dealFinanceAggregateList[0].get('AMOUNT') != null) ? (Decimal)dealFinanceAggregateList[0].get('AMOUNT') : 0;
            orderNumberToMontlyAmountMap.put(50, amount);
        }
        
        // Line 67, 68, 69, 71
        List<AggregateResult> hoursLoggedAggregateList = 
                [SELECT SUM(Billed_Hours__c) BillHours, SUM(Calculated_Hours__c) CalculateHours FROM Hours_Logged__c 
                            WHERE Service_Order_Header__c != null AND 
                                  Start_Date_Time__c >=: monthStartDate AND Start_Date_Time__c <=: monthEndDate];
        
        if(hoursLoggedAggregateList.size() > 0) {
            if(hoursLoggedAggregateList[0].get('BillHours') != null) {
                Decimal totalHours = (hoursLoggedAggregateList[0].get('BillHours') != null) ? (Decimal)hoursLoggedAggregateList[0].get('BillHours') : 0;
                orderNumberToMontlyAmountMap.put(69, totalHours);
            }
            if(hoursLoggedAggregateList[0].get('CalculateHours') != null) {
                Decimal calHours = (hoursLoggedAggregateList[0].get('CalculateHours') != null) ? (Decimal)hoursLoggedAggregateList[0].get('CalculateHours') : 0;
                orderNumberToMontlyAmountMap.put(67, calHours);
            }
        }
        
        // Line 67, 68, 71
        hoursLoggedAggregateList = [SELECT SUM(Billed_Hours__c) BillHours, SUM(Calculated_Hours__c) CalculateHours FROM Hours_Logged__c 
                                    WHERE Service_Order_Header__c != null AND 
                                          Start_Date_Time__c >=: yearStartDate AND Start_Date_Time__c <=: yearEndDate];
        
        if(hoursLoggedAggregateList.size() > 0) {
            if(hoursLoggedAggregateList[0].get('BillHours') != null) {
                Decimal totalHours = (hoursLoggedAggregateList[0].get('BillHours') != null) ? (Decimal)hoursLoggedAggregateList[0].get('BillHours') : 0;
                orderNumberToYearlyAmountMap.put(69, totalHours);
            }
            if(hoursLoggedAggregateList[0].get('CalculateHours') != null) {
                Decimal calHours = (hoursLoggedAggregateList[0].get('CalculateHours') != null) ? (Decimal)hoursLoggedAggregateList[0].get('CalculateHours') : 0;
                orderNumberToYearlyAmountMap.put(67, calHours);
            }
        }
                
        // Line 71
        List<AggregateResult> serviceJobAggregateList = 
                    [SELECT count(Id) TotalSO from Service_Order_Header__c 
                        WHERE Invoice_Number__c != null AND
                              Invoice_Number__r.Invoice_Date_Formula__c >=: monthStartDate AND 
                              Invoice_Number__r.Invoice_Date_Formula__c <=: monthEndDate];
        
        if(serviceJobAggregateList.size() > 0) {
            Decimal totalSO = (serviceJobAggregateList[0].get('TotalSO') != null) ? (Decimal)serviceJobAggregateList[0].get('TotalSO') : 0;
            orderNumberToMontlyAmountMap.put(71, totalSO);
        }
        
        serviceJobAggregateList = [SELECT count(Id) TotalSO from Service_Order_Header__c 
                                    WHERE Invoice_Number__c != null AND
                                          Invoice_Number__r.Invoice_Date_Formula__c >=: yearStartDate AND 
                                          Invoice_Number__r.Invoice_Date_Formula__c <=: yearEndDate];
        
        if(serviceJobAggregateList.size() > 0) {
            Decimal totalSO = (serviceJobAggregateList[0].get('TotalSO') != null) ? (Decimal)serviceJobAggregateList[0].get('TotalSO') : 0;
            orderNumberToYearlyAmountMap.put(71, totalSO);
        }
        return System.JSON.serialize(new FusionLineItemWrapper.LineItemValueWrapper(orderNumberToMontlyAmountMap, orderNumberToYearlyAmountMap));
    }
    
    private static Set<Integer> blackpurlDataLineItemSet2 = new Set<Integer>{63, 64, 65, 66, 68}; 
    
    public static String populateBlackpurlData2(String month, String year) {
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{'Source__c' => 'Blackpurl'});
        Map<Integer, Set<String>> orderNumberToSetOfMappedGLsIdMap = new Map<Integer, Set<String>>();
        
        Map<Integer, Decimal> orderNumberToMontlyAmountMap = new Map<Integer, Decimal>();
        Map<Integer, Decimal> orderNumberToYearlyAmountMap = new Map<Integer, Decimal>();
        
        Date monthStartDate = getStartDateForMonth_BP(month, year);
        Date monthEndDate = getEndDateForMonth_BP(month, year);
        
        Date yearStartDate = getStartDateForYear_BP(year);
        Date yearEndDate = monthEndDate;
        
        for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
            Integer orderNumber = Integer.valueOf(fusionLineItemRec.Order_Number__c);
            if(blackpurlDataLineItemSet2.contains(orderNumber)) {
                if(!orderNumberToSetOfMappedGLsIdMap.containsKey(orderNumber)) {
                    orderNumberToSetOfMappedGLsIdMap.put(orderNumber, new Set<String>{});
                }
                for(Fusion_Line_Item_To_GL_Account_Junction__c junctionRec : fusionLineItemRec.Fusion_Line_Item_To_GL_Account_Junctions__r) {
                    orderNumberToSetOfMappedGLsIdMap.get(orderNumber).add(junctionRec.General_Account__r.Accounting_Id__c);
                }
                orderNumberToMontlyAmountMap.put(orderNumber, 0);
                orderNumberToYearlyAmountMap.put(orderNumber, 0);
            }
        }
        
        // Line 63, 65
        List<AggregateResult> partAggregateList = [SELECT SUM(Inventory_Valuation__c) AMOUNT, SUM(PRD4Cost__c) COST 
                                                    from Part__c WHERE Part_Type__c = 'Part'];
        if(partAggregateList.size() > 0) {
            Decimal amount = (partAggregateList[0].get('AMOUNT') != null) ? (Decimal)partAggregateList[0].get('AMOUNT') : 0;
            orderNumberToMontlyAmountMap.put(63, amount);
            orderNumberToYearlyAmountMap.put(63, amount);
            
            Decimal cost = (partAggregateList[0].get('COST') != null) ? (Decimal)partAggregateList[0].get('COST') : 0;
            orderNumberToMontlyAmountMap.put(65, cost);
            orderNumberToYearlyAmountMap.put(65, cost);
        }
        
        // Line 64, 66
        partAggregateList = [SELECT SUM(Inventory_Valuation__c) AMOUNT, SUM(PRD4Cost__c) COST from Part__c WHERE Part_Type__c = 'Merchandise'];
        if(partAggregateList.size() > 0) {
            Decimal amount = (partAggregateList[0].get('AMOUNT') != null) ? (Decimal)partAggregateList[0].get('AMOUNT') : 0;
            orderNumberToMontlyAmountMap.put(64, amount);
            orderNumberToYearlyAmountMap.put(64, amount);
            
            Decimal cost = (partAggregateList[0].get('COST') != null) ? (Decimal)partAggregateList[0].get('COST') : 0;
            orderNumberToMontlyAmountMap.put(66, cost);
            orderNumberToYearlyAmountMap.put(66, cost);
        }
        
        // Line 65 and 66
        /*List<Part__c> partList = [SELECT PRD4Cost__c, PRD4Qty__c, Part_Type__c from Part__c WHERE PRD4Cost__c != 0 AND PRD4Cost__c != null 
                                        AND PRD4Qty__c != 0 AND PRD4Qty__c != null];
        for(Part__c partRec : partList) {
            if(partRec.Part_Type__c == 'Part') {
                orderNumberToMontlyAmountMap.put(65, orderNumberToMontlyAmountMap.get(65) + (partRec.PRD4Cost__c * partRec.PRD4Qty__c));
                orderNumberToYearlyAmountMap.put(65, orderNumberToYearlyAmountMap.get(65) + (partRec.PRD4Cost__c * partRec.PRD4Qty__c));
            } else if(partRec.Part_Type__c == 'Merchandise') {
                orderNumberToMontlyAmountMap.put(66, orderNumberToMontlyAmountMap.get(66) + (partRec.PRD4Cost__c * partRec.PRD4Qty__c));
                orderNumberToYearlyAmountMap.put(66, orderNumberToYearlyAmountMap.get(66) + (partRec.PRD4Cost__c * partRec.PRD4Qty__c));
            }
        }*/
        
        // Line 68
        List<AggregateResult> payrollList = [SELECT SUM(Total_Time__c) WorkedHours from Payroll_Time__c 
                                                WHERE Technician__c != null AND
                                                      Payroll_Date__c >=: monthStartDate AND 
                                                      Payroll_Date__c <=: monthEndDate];
        
        if(payrollList.size() > 0) {
            Decimal workedHours = (payrollList[0].get('WorkedHours') != null) ? (Decimal)payrollList[0].get('WorkedHours') : 0;
            orderNumberToMontlyAmountMap.put(68, workedHours);
        }
        
        payrollList = [SELECT SUM(Total_Time__c) WorkedHours from Payroll_Time__c 
                            WHERE Technician__c != null AND
                                  Payroll_Date__c >=: yearStartDate AND 
                                  Payroll_Date__c <=: yearEndDate];
        
        if(payrollList.size() > 0) {
            Decimal workedHours = (payrollList[0].get('WorkedHours') != null) ? (Decimal)payrollList[0].get('WorkedHours') : 0;
            orderNumberToYearlyAmountMap.put(68, workedHours);
        }
        return System.JSON.serialize(new FusionLineItemWrapper.LineItemValueWrapper(orderNumberToMontlyAmountMap, orderNumberToYearlyAmountMap));
    }
    
    public static void saveFusionLineItemValues(String lineItemValuesJson) {
        FusionLineItemWrapper.LineItemValueWrapper lineItemValueWrapperObj = (FusionLineItemWrapper.LineItemValueWrapper) System.JSON.deserialize(lineItemValuesJson, FusionLineItemWrapper.LineItemValueWrapper.class);
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{'Source__c' => 'Blackpurl'});
        for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
            Integer orderNumber = Integer.valueOf(fusionLineItemRec.Order_Number__c);
            if(lineItemValueWrapperObj.OrderNumberToMontlyAmountMap.containsKey(orderNumber)) {
                fusionLineItemRec.Monthly_Value__c = lineItemValueWrapperObj.OrderNumberToMontlyAmountMap.get(orderNumber);
            }
            if(lineItemValueWrapperObj.OrderNumberToYearlyAmountMap.containsKey(orderNumber)) {
                fusionLineItemRec.Yearly_Value__c = lineItemValueWrapperObj.OrderNumberToYearlyAmountMap.get(orderNumber);
            }
        }
        
        if(fusionLineItemList.size() > 0) {
            update fusionLineItemList;
        }
    }
    
    private static List<Integer> newSoldUnitOrderNumberList = new List<Integer> {30, 31, 32, 33, 34, 35, 36};
    
    public static void populateCalculatedData() {
        List<Fusion_Report_Line_Item__c> fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>{});
        Map<Integer, Fusion_Report_Line_Item__c> orderNumberToFusionLineItemMap = new Map<Integer, Fusion_Report_Line_Item__c>();
        for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
            orderNumberToFusionLineItemMap.put(Integer.valueOf(fusionLineItemRec.Order_Number__c), fusionLineItemRec);
        }
        
        List<Fusion_Report_Line_Item__c> fusionLineItemListToUpdate = new List<Fusion_Report_Line_Item__c>();
        for(Integer orderNumber : calculatedValuesMap.keyset()) {
            Decimal monthlyAmount = 0;
            Decimal yearlyAmount = 0;
            for(Integer relatedOrderNumber : calculatedValuesMap.get(orderNumber)) {
                monthlyAmount += orderNumberToFusionLineItemMap.get(relatedOrderNumber).Monthly_Value__c;
                yearlyAmount += orderNumberToFusionLineItemMap.get(relatedOrderNumber).Yearly_Value__c;
            }
            Fusion_Report_Line_Item__c fusionRec = orderNumberToFusionLineItemMap.get(orderNumber);
            fusionRec.Monthly_Value__c = monthlyAmount;
            fusionRec.Yearly_Value__c = yearlyAmount;
            fusionLineItemListToUpdate.add(fusionRec);
        }
        
        if(fusionLineItemListToUpdate.size() > 0) {
            update fusionLineItemListToUpdate;
        }
    }
    
    
    private static Map<Integer, List<Integer>> calculatedValuesMap = new Map<Integer, List<Integer>> {
            13 => new List<Integer>{14, 15, 16, 17, 18, 19, 20},
            21 => new List<Integer>{22, 23, 24, 25, 26, 27, 28},
            29 => new List<Integer>{30, 31, 32, 33, 34, 35, 36},
            55 => new List<Integer>{51, 52, 53, 54},
            61 => new List<Integer>{57, 58, 59, 60}
    };
    
    private static Map<String, Decimal> getReportData(String month, String year, Boolean isMonthly, String reportObject, Set<String> objKeyToFindSet) {
        String startDate = getStartDateForMonth(month, year, isMonthly);
        String endDate = getEndDateForMonth(month, year);
        
        HttpResponse res = QuickbookConnector.getRequestFromQuickBooks('reports/'+reportObject+'?start_date='+startDate+'&end_date='+endDate, null);
        QBReportWrapper responseObj = (QBReportWrapper)system.JSON.deserialize(res.getBody(), QBReportWrapper.class);
        return parseResponse(responseObj, objKeyToFindSet);
    }
    
    public static Map<String, Decimal> parseResponse(QBReportWrapper responseObj, Set<String> objKeyToFindSet) {
        Map<String, Decimal> objKetToAmountMap = new Map<String, Decimal>();
        if(responseObj != null && responseObj.Rows != null && responseObj.Rows.Row != null) {
            for(QBReportWrapper.cls_Row rowObj : responseObj.Rows.Row) {
                if(rowObj != null && rowObj.Summary != null && rowObj.Summary.ColData != null) {
                    List<QBReportWrapper.cls_ColData> colObjList = rowObj.Summary.ColData;
                    if(colObjList.size() > 1 && colObjList[0].value != null && objKeyToFindSet.contains(colObjList[0].value.toLowerCase())) {
                        objKetToAmountMap.put(colObjList[0].value.toLowerCase(), (String.isNotBlank(colObjList[1].value)) ? Decimal.valueof(colObjList[1].value) : 0);
                    }
                }
            }
        }
        return objKetToAmountMap;
    }
    
    private static Date getStartDateForMonth_BP(String month, String year) {
        return Date.newInstance(Integer.valueOf(year), monthsMap.get(month), 1);
    }
    
    private static Date getEndDateForMonth_BP(String month, String year) {
        return date.newinstance(Integer.valueOf(year), monthsMap.get(month), Date.daysInMonth(Integer.valueOf(year), monthsMap.get(month)));
    }
    
    private static Date getStartDateForYear_BP(String year) {
        return Date.newInstance(Integer.valueOf(year), 1, 1);
    }
    
    private static String getStartDateForMonth(String month, String year, Boolean isMonthly) {
        String startDateString;
        if(isMonthly) {
            startDateString = year + '-' + monthsMap.get(month) + '-' + '1';
        } else {
            startDateString = year + '-' + monthsMap.get('January') + '-' + '1';
        }
        return startDateString;
    }
    
    private static String getEndDateForMonth(String month, String year) {
        Integer numberDays = Date.daysInMonth(Integer.valueOf(year), monthsMap.get(month));
        return year + '-' + monthsMap.get(month) + '-' + String.valueOf(numberDays);
    }
    
    private static Map<String, Integer> monthsMap = new Map<String, Integer>{
       'January'  => 1,
       'February' => 2,
       'March' => 3,
       'April' => 4,
       'May' => 5,
       'June'  => 6,
       'July' => 7,
       'August' => 8,
       'September' => 9,
       'October' => 10,
       'November' => 11,
       'December' => 12
    };
}