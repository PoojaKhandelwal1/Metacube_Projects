@isTest
private  class PriceFileImportTest {
	static testMethod void testPricefileImport(){
		Category__c	testCategory = TestUtil.createCategory(true, 'My Test Category', 'Part', 'part cat',true,true);
		Account testVendor = TestUtil.createVendor(true,'Test Vendor');
		List<PriceFileImportCtrl.FieldMapping>  fieldsmapList = new List<PriceFileImportCtrl.FieldMapping>();
		PriceFileImportCtrl.FieldMapping obj1  = new PriceFileImportCtrl.FieldMapping();
		obj1.PartNumber = '0001-2150';
		obj1.Description = 'Desc1';
		obj1.MSRP = '300';
		obj1.Retail = '200';
		obj1.EnviroFee = '200';
		obj1.ItemCost = '200';
		fieldsmapList.add(obj1);
		String sampleJson =  BPUtility.getEncodedString(System.JSON.serialize(fieldsmapList));
		String VendorId = BPUtility.getEncodedString(testVendor.Id);
		String Result =  PriceFileImportCtrl.importPriceFile(VendorId, sampleJson);
		PriceFileImportCtrl.UploadResult record = (PriceFileImportCtrl.UploadResult) System.JSON.deserialize(BPUtility.getDecodedString(Result), PriceFileImportCtrl.UploadResult.class);
		System.assertEquals('1',string.valueOf(record.SucessCount));
	}

}