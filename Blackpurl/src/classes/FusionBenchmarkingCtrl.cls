/**
 * Author: Tarun Khandelwal
 * Since: August 16, 2018
 * Name: FusionBenchmarkingCtrl
 * Description: Ctrl class for Fusion Benchmarking Page
**/
global without sharing class FusionBenchmarkingCtrl {
    
    global FusionBenchmarkingCtrl(NewHomePageCtrl controller){} 
    public FusionBenchmarkingCtrl() {}
    
    @RemoteAction
    global static String getFusionBenchMarkingDetail() {
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(FusionMappingService.getFusionBenchMarkingDetail(), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveFusionBenchMarking(String jsonStr) {
        jsonStr = BPUtility.getDecodedString(jsonStr);
        try {
            return BPUtility.getEncodedString(system.JSON.serialize(FusionMappingService.saveFusionBenchMarking(jsonStr), true));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getProfitAndLossFromQB(String month, String year) {
        month = BPUtility.getDecodedString(month);
        year = BPUtility.getDecodedString(year);
        try {
            FusionReportService.getProfitAndLossFromQB(month, year);
            return BPUtility.getEncodedString('Success');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getBalanceSheetFromQB(String month, String year) {
        month = BPUtility.getDecodedString(month);
        year = BPUtility.getDecodedString(year);
        try {
            FusionReportService.getBalanceSheetFromQB(month, year);
            return BPUtility.getEncodedString('Success');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getOtherAccountInfoFromQB(String month, String year) {
        month = BPUtility.getDecodedString(month);
        year = BPUtility.getDecodedString(year);
        try {
            FusionReportService.getOtherAccountInfoFromQB(month, year);
            return BPUtility.getEncodedString('Success');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String getOtherAccountInfoFromQB_Yearly(String month, String year) {
        month = BPUtility.getDecodedString(month);
        year = BPUtility.getDecodedString(year);
        try {
            FusionReportService.getOtherAccountInfoFromQB_Yearly(month, year);
            return BPUtility.getEncodedString('Success');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String populateBlackpurlData(String month, String year) {
        return '';
    }
    
    @RemoteAction
    global static String populateBlackpurlData2(String month, String year) {
        return '';
    }
    
    @RemoteAction
    @ReadOnly
    global static String populateBlackpurlValues(String month, String year) {
        month = BPUtility.getDecodedString(month);
        year = BPUtility.getDecodedString(year);
        try {
            return BPUtility.getEncodedString(FusionReportService.populateBlackpurlData(month, year));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    @ReadOnly
    global static String populateBlackpurlValues2(String month, String year) {
        month = BPUtility.getDecodedString(month);
        year = BPUtility.getDecodedString(year);
        try {
            return BPUtility.getEncodedString(FusionReportService.populateBlackpurlData2(month, year));
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String saveFusionLineItemValues(String lineItemValuesJson) {
        lineItemValuesJson = BPUtility.getDecodedString(lineItemValuesJson);
        try {
            FusionReportService.saveFusionLineItemValues(lineItemValuesJson);
            return BPUtility.getEncodedString('Success');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
    
    @RemoteAction
    global static String populateCalculatedData() {
        try {
            FusionReportService.populateCalculatedData();
            return BPUtility.getEncodedString('Success');
        } catch(Exception e) {
            throw new BlackPurlException(BlackPurlException.getErrorMessage(e.getMessage(), e.getStackTraceString()));
        }
    }
}