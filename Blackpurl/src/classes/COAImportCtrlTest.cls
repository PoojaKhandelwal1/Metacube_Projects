/**
 * Author: Pooja Khandelwal
 * Since: Apr. 25, 2017
 * Name: COAImportCtrlTest
 * Description: Test class for COAImportCtrl
**/
@isTest
private class  COAImportCtrlTest {
    private static testmethod void importCOAFileTest()	{
    	List<COAImportCtrl.FieldMapping> recordList = new List<COAImportCtrl.FieldMapping>();
    	
    	COAImportCtrl.FieldMapping record1 = new COAImportCtrl.FieldMapping();
    	record1.AccountNumber = '0001-2150';
    	record1.AccountDescription = 'ROUBAIX PRO TIRE 700X23/25C';
    	record1.AccountType = 'TIRE';
    	recordList.add(record1);
    	
    	COAImportCtrl.FieldMapping record2 = new COAImportCtrl.FieldMapping();
    	record2.AccountNumber = '00014-1154';
    	record2.AccountDescription = 'SW TURBO ROAD TUBELESS TIRE 700X24C';
    	record2.AccountType = 'TIRE';
    	recordList.add(record2);
    	
    	COAImportCtrl.FieldMapping record3 = new COAImportCtrl.FieldMapping();
    	record3.AccountNumber = '00014-3213';
    	record3.AccountDescription = 'ALL CONDITION ARM TIRE 700X23C';
    	record3.AccountType = 'TIRE';
    	recordList.add(record3);
    	
    	COAImportCtrl.FieldMapping record4 = new COAImportCtrl.FieldMapping();
    	record4.AccountNumber = '00014-3215';
    	record4.AccountDescription = 'ALL CONDITION ARM TIRE 700X25C';
    	record4.AccountType = 'TIRE';
    	recordList.add(record4);
    	
    	COAImportCtrl.FieldMapping record5 = new COAImportCtrl.FieldMapping();
    	record5.AccountNumber = '\',\'';
    	record5.AccountDescription = '\',\'';
    	record5.AccountType = '\',\'';
    	recordList.add(record5);
    	
    	Test.startTest();
    	String ImportCOAResultJson =  BPUtility.getDecodedString(COAImportCtrl.importCOAFile(BPUtility.getEncodedString(System.JSON.serialize(recordList))));
    	COAImportCtrl.UploadResult ImportCOAResult = (COAImportCtrl.UploadResult) System.JSON.deserialize(ImportCOAResultJson, COAImportCtrl.UploadResult.class);
        Test.stopTest();
    	system.assertEquals('0',ImportCOAResult.ErrorCount); 
    	system.assertEquals('5',ImportCOAResult.NewRecords);
    	system.assertEquals('5',ImportCOAResult.SucessCount);
    }
}