@isTest
private class MakeModelSubModelServiceTest {
    
    @testSetup
    private static void setup() {
    	Unit_Make__c unitMakeRec = TestUtil.createUnitMake(true, 'unitMakeName', 'tes', true);
    	Unit_Model__c unitModelRec = TestUtil.createUnitModel(true, 'unitModelName', 'tes', true, unitMakeRec.Id);
    	Unit_Sub_Model__c unitSubModelRec = TestUtil.createSubModel(unitModelRec.Id);
    }
    
    @isTest
    private static void testGetMakeModelSubmodelList() {
    	Test.startTest();
    	String result = MakeModelSubModelService.getMakeModelSubmodelList();
    	MakeModelSubModelService.MakeModelSubModelListWrapper makeModelSubModelListWrapper = 
    																(MakeModelSubModelService.MakeModelSubModelListWrapper)json.deserialize
    																		(result, MakeModelSubModelService.MakeModelSubModelListWrapper.class);
    	Test.stopTest();
    	system.assertEquals(makeModelSubModelListWrapper.MakeList[0].UnitMakeName, 'unitMakeName');
    }
}