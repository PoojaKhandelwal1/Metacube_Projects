/**
 * Author: Tarun Khandelwal
 * Since: August 23, 2018
 * Name: FusionReportCtrl
 * Description: Ctrl class for Fusion Report Page
**/
public without sharing class FusionReportCtrl {
    
    public List<Fusion_Report_Line_Item__c> fusionLineItemList {get; set;}
    public Map<Integer, Decimal> lineItemNoToMonthValueMap {get; set;}
    public Map<Integer, Decimal> lineItemNoToYearValueMap {get; set;}
	public String csvString {get; set;}
	
    public FusionReportCtrl() {
        lineItemNoToMonthValueMap = new Map<Integer, Decimal>();
        lineItemNoToYearValueMap = new Map<Integer, Decimal>();
        populateFusionLineItemData();
        populateUserEnterData();
        populateOtherData();
        populateCSVData();
    }
    
    private void populateCSVData() {
    	csvString = 'HDNet Accounts,Monthly,YTD\n';
    	for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionLineItemList) {
    		csvString += fusionLineItemRec.HDNet_Account__c + ',' + lineItemNoToMonthValueMap.get(Integer.valueOf(fusionLineItemRec.Order_Number__c)) + ',' +
    				lineItemNoToYearValueMap.get(Integer.valueOf(fusionLineItemRec.Order_Number__c)) +'\n';
    	}
    }
    
    private void populateFusionLineItemData() {
        fusionLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>());
    }
    
    private void populateUserEnterData() {
        List<Fusion_Benchmarking__c> fusionBenchMarkingList = FusionSOQLUtil.getFusionBenchmarkingDetail(new Map<String, String>());
        if(fusionBenchMarkingList.size() > 0) {
            for(Integer orderNumber : lineItemNumberToFieldAPINameMap.keySet()) {
                lineItemNoToMonthValueMap.put(orderNumber, Decimal.valueOf(String.valueOf(fusionBenchMarkingList[0].get(lineItemNumberToFieldAPINameMap.get(orderNumber)))));
                lineItemNoToYearValueMap.put(orderNumber, Decimal.valueOf(String.valueOf(fusionBenchMarkingList[0].get(lineItemNumberToFieldAPINameMap.get(orderNumber)))));
            }
        }
    }
    
    private void populateOtherData() {
        for(Fusion_Report_Line_Item__c fusionReportLineItemRec : fusionLineItemList) {
            if(!lineItemNumberToFieldAPINameMap.containsKey(Integer.valueOf(fusionReportLineItemRec.Order_Number__c))) {
                lineItemNoToMonthValueMap.put(Integer.valueOf(fusionReportLineItemRec.Order_Number__c), 
                        (fusionReportLineItemRec.Monthly_Value__c != null) ? fusionReportLineItemRec.Monthly_Value__c : 0);
                lineItemNoToYearValueMap.put(Integer.valueOf(fusionReportLineItemRec.Order_Number__c), 
                    (fusionReportLineItemRec.Yearly_Value__c != null) ? fusionReportLineItemRec.Yearly_Value__c : 0 );
            }
        }
    }
    
    private Map<Integer, String> lineItemNumberToFieldAPINameMap = new Map<Integer, String>{
        5 => 'Working_days_in_Period__c',
        6 => 'Employee_No_Sales__c',
        7 => 'Employee_No_Service_Technical__c',
        8 => 'Employee_No_Service_Non_Technical__c',
        9 => 'Employee_No_Parts__c',
        10 => 'Employee_No_Administration_Other__c',
        37 => 'No_Sales_People__c',
        48 => 'No_Insurance_Contracts_Written__c',
        70 => 'No_of_Working_Days__c',
        78 => 'Average_Technician_Prime_Labor_Cost__c'
    };
}