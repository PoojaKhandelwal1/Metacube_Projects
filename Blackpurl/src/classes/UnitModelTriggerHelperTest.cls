/**
 * Author: Nidhi Sharma
 * Since: Oct 23, 2018
 * Name: UnitModelTriggerHelperTest
 * Description: test Class of UnitModelTrigger and UnitModelTriggerHelper.
**/
@isTest
public class UnitModelTriggerHelperTest {
    @isTest
    private static void createUnitModelTest() {
    	Unit_Make__c unitMake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	Unit_Model__c unitModel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
        system.assertEquals(1, [Select Id from Unit_Model__c].size());
    }
    
    @isTest
    private static void createDuplicateUnitModelInList() {
    	Unit_Make__c unitMake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	List<Unit_Model__c> unitModelList = new List<Unit_Model__c>{TestUtil.createUnitModel(false, 'unitModelName', '12A', true, unitMake.Id)};
    	unitModelList.add(TestUtil.createUnitModel(false, 'unitModelName', '12A', true, unitMake.Id));
    	try {
    		insert unitModelList;
    	} catch(system.DmlException e) {
    		system.assertEquals(true, e.getMessage().contains('Duplicate model for same make in list'));
    	}
    }
    
    @isTest
    private static void createDuplicateUnitModelExistsInDBTest() {
    	Unit_Make__c unitMake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	Unit_Model__c unitModel = TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
    	try {
    		insert TestUtil.createUnitModel(true, 'unitModelName', '12A', true, unitMake.Id);
    	} catch(system.DmlException e) {
    		system.assertEquals(true, e.getMessage().contains('Model name for this make already exists'));
    	}
    }
}