/**
 * Author: Tarun Khandelwal
 * Since: August 17, 2018
 * Name: FusionMappingService
 * Description: Service class for Fusion Mapping ctrl class
**/
public without sharing class FusionMappingService {
    
    public static List<FusionLineItemWrapper> getFusionLineItems() {
        List<Fusion_Report_Line_Item__c> fusionReportLineItemList = FusionSOQLUtil.getFusionLienItem(new Map<String, String>());
        
        List<FusionLineItemWrapper> fusionLineItemObjList = new List<FusionLineItemWrapper>();
        for(Fusion_Report_Line_Item__c fusionLineItemRec : fusionReportLineItemList) {
            fusionLineItemObjList.add(new FusionLineItemWrapper(fusionLineItemRec));
        }
        return fusionLineItemObjList;
    }
    
    public static List<GeneralAccountWrapper> getGeneralAccounts() {
        List<General_Account__c> generalAccountList = FusionSOQLUtil.getGeneralAccounts(new Map<String, String>());
        
        List<GeneralAccountWrapper> generalAccountObjList = new List<GeneralAccountWrapper>();
        for(General_Account__c generalAccountRec : generalAccountList) {
            generalAccountObjList.add(new GeneralAccountWrapper(generalAccountRec));
        }
        return generalAccountObjList;
    }
    
    public static String saveFusionLineItem(String fusionLineItemId, String jsonStr) {
        if(AccessControl.ifObjectFieldIsAccessible('Fusion_Line_Item_To_GL_Account_Junction__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        if(AccessControl.ifObjectIsDeletable('Fusion_Line_Item_To_GL_Account_Junction__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_DELETABLE); }
        if(AccessControl.ifObjectFieldIsCreateable('Fusion_Line_Item_To_GL_Account_Junction__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            
        List<GeneralAccountWrapper> genAccObjList = (List<GeneralAccountWrapper>)system.JSON.deserialize(jsonStr, List<GeneralAccountWrapper>.class);
        Set<String> selectedGenAccIdSet = new Set<String>();
        for(GeneralAccountWrapper generalAccObj : genAccObjList) {
            selectedGenAccIdSet.add(generalAccObj.Id);
        }
        selectedGenAccIdSet.remove(null);
        
        List<Fusion_Line_Item_To_GL_Account_Junction__c> junctionList = [Select General_Account__c from Fusion_Line_Item_To_GL_Account_Junction__c Where Fusion_Report_Line_Item__c =: fusionLineItemId];
        Map<Id, Fusion_Line_Item_To_GL_Account_Junction__c> existingGenAccIdToJunctionRecordMap = new Map<Id, Fusion_Line_Item_To_GL_Account_Junction__c>();
        for(Fusion_Line_Item_To_GL_Account_Junction__c junctionRec : junctionList) {
            existingGenAccIdToJunctionRecordMap.put(junctionRec.General_Account__c, junctionRec);
        }
        
        List<Fusion_Line_Item_To_GL_Account_Junction__c> junctionListToDelete = new List<Fusion_Line_Item_To_GL_Account_Junction__c>();
        List<Fusion_Line_Item_To_GL_Account_Junction__c> junctionListToInsert = new List<Fusion_Line_Item_To_GL_Account_Junction__c>();
        for(GeneralAccountWrapper genAccObj : genAccObjList) {
            if(!existingGenAccIdToJunctionRecordMap.containsKey(genAccObj.Id)) {
                Fusion_Line_Item_To_GL_Account_Junction__c junctionRec = new Fusion_Line_Item_To_GL_Account_Junction__c();
	            junctionRec.Fusion_Report_Line_Item__c = fusionLineItemId;
	            junctionRec.General_Account__c = genAccObj.Id;
	            junctionListToInsert.add(junctionRec);
            }
        }
        
        for(String existingGenAccId : existingGenAccIdToJunctionRecordMap.keySet()) {
            if(!selectedGenAccIdSet.contains(existingGenAccId)) {
                junctionListToDelete.add(existingGenAccIdToJunctionRecordMap.get(existingGenAccId));
            }
        }
        
        if(junctionListToDelete.size() > 0) {
            delete junctionListToDelete;
        }
        if(junctionListToInsert.size() > 0) {
            insert junctionListToInsert;
        }
        return 'Success';
    }
    
    public static FusionBenchmarkingWrapper getFusionBenchMarkingDetail() {
        List<Fusion_Benchmarking__c> fusionBenchMarkingList = FusionSOQLUtil.getFusionBenchmarkingDetail(new Map<String, String>());
        
        FusionBenchmarkingWrapper fusionBenchMarkingObj = new FusionBenchmarkingWrapper();
        if(fusionBenchMarkingList.size() > 0) {
            fusionBenchMarkingObj = new FusionBenchmarkingWrapper(fusionBenchMarkingList[0]);
        }
        return fusionBenchMarkingObj;
    }
    
    public static String saveFusionBenchMarking(String jsonStr) {
        FusionBenchmarkingWrapper fusionObj = (FusionBenchmarkingWrapper) system.JSON.deserialize(jsonStr, FusionBenchmarkingWrapper.class);
        Fusion_Benchmarking__c fusionBenchmarkingRec = setFieldsForFusionBenchmarking(fusionObj);
        if(fusionBenchmarkingRec.Id == null) {
            if(AccessControl.ifObjectFieldIsCreateable('Fusion_Benchmarking__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        } else {
            if(AccessControl.ifObjectFieldIsUpdateable('Fusion_Benchmarking__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
        }
        upsert fusionBenchmarkingRec;
        return 'Success';
    }
    
    private static Fusion_Benchmarking__c setFieldsForFusionBenchmarking(FusionBenchmarkingWrapper fusionObj) {
        Fusion_Benchmarking__c fusionBenchmarkingRec = new Fusion_Benchmarking__c();
        fusionBenchmarkingRec.Id = fusionObj.Id;
        fusionBenchmarkingRec.Average_Technician_Prime_Labor_Cost__c = fusionObj.AverageTechnicianPrimeLaborCost;
        fusionBenchmarkingRec.Employee_No_Administration_Other__c = fusionObj.EmployeeNoAdministrationAndOther;
        fusionBenchmarkingRec.Employee_No_Parts__c = fusionObj.EmployeeNoParts;
        fusionBenchmarkingRec.Employee_No_Sales__c = fusionObj.EmployeeNoSales;
        fusionBenchmarkingRec.Employee_No_Service_Non_Technical__c = fusionObj.EmployeeNoServiceNonTechnical;
        fusionBenchmarkingRec.Employee_No_Service_Technical__c = fusionObj.EmployeeNoServiceTechnical;
        fusionBenchmarkingRec.No_Sales_People__c = fusionObj.NoSalesPeople;
        fusionBenchmarkingRec.No_of_Working_Days__c = fusionObj.NoOfWorkingDays;
        fusionBenchmarkingRec.Working_days_in_Period__c = fusionObj.WorkingDaysInPeriod;
        fusionBenchmarkingRec.No_Insurance_Contracts_Written__c = fusionObj.NoInsuranceContractsWritten;
        return fusionBenchmarkingRec;
    }
}