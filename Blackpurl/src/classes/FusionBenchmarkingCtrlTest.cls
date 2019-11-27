/**
 * Author: Rajat Jain
 * updated: May 25, 2018
 * Name: FusionBenchmarkingCtrlTest
 * Description: It includes scenario based test cases for FusionBenchmarkingCtrlTest.
**/

@isTest
private with sharing class FusionBenchmarkingCtrlTest {
	
	@testSetup
   	static void setup() {
		BPScriptUtility.insertFusionLineItems();
		List<Fusion_Benchmarking__c> fusionBenchmarkingListToBeInserted = new List<Fusion_Benchmarking__c>();
		fusionBenchmarkingListToBeInserted.add(new Fusion_Benchmarking__c(Average_Technician_Prime_Labor_Cost__c=18.00, Employee_No_Administration_Other__c=16.00, Employee_No_Parts__c=15.00, Employee_No_Sales__c=12.00, Employee_No_Service_Non_Technical__c=14.00, Employee_No_Service_Technical__c=13.00, No_Sales_People__c=17.00));
		insert fusionBenchmarkingListToBeInserted;
		List<Fusion_Benchmarking__c> fusionBenchmarkingList = [Select Id from Fusion_Benchmarking__c];
		system.assert(fusionBenchmarkingList.size() > 0);
	}
	
	static testMethod void getFusionBenchMarkingDetailTest() {
		new FusionBenchmarkingCtrl();
		new FusionBenchmarkingCtrl(new NewHomePageCtrl());
		Test.startTest();
		String benchMarkingList = BPUtility.getDecodedString(FusionBenchmarkingCtrl.getFusionBenchMarkingDetail());
		FusionBenchmarkingWrapper benchMarkingWrapperObj =(FusionBenchmarkingWrapper) System.JSON.deserialize(benchMarkingList, FusionBenchmarkingWrapper.class);
		system.assertEquals(benchMarkingWrapperObj.AverageTechnicianPrimeLaborCost , 18.00);
		Test.stopTest(); 
	} 
	
	static testMethod void saveFusionBenchMarking() {
		Test.startTest();
		List<Fusion_Benchmarking__c> fusionBenchmarkingList = [Select Id,Average_Technician_Prime_Labor_Cost__c,Employee_No_Administration_Other__c,Employee_No_Parts__c,Employee_No_Sales__c,Employee_No_Service_Non_Technical__c,Employee_No_Service_Technical__c,No_Sales_People__c from Fusion_Benchmarking__c];
		List<FusionBenchmarkingWrapper> fusionBenchmarkingWrapperList = new List<FusionBenchmarkingWrapper>();
		for(Fusion_Benchmarking__c benchMarkingObj : fusionBenchmarkingList) {
			fusionBenchmarkingWrapperList.add(new FusionBenchmarkingWrapper(benchMarkingObj));
		}
		String jsonStr = BPUtility.getEncodedString(System.Json.serialize(fusionBenchmarkingWrapperList[0]));
		String resultJson = BPUtility.getDecodedString(FusionBenchmarkingCtrl.saveFusionBenchMarking(jsonStr));
		String result =(String) System.JSON.deserialize(resultJson, String.class);
		system.assertEquals('Success',result);
		
		try {
			String resultJs = BPUtility.getDecodedString(FusionBenchmarkingCtrl.saveFusionBenchMarking(''));
		} catch(Exception e) {
			System.debug('error' + e);
		}
		Test.stopTest(); 
	}    
}