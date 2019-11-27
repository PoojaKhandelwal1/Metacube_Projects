/**
 * Author: Nidhi Sharma
 * Since: Oct 23, 2018
 * Name: UnitMakeTriggerHelperTest
 * Description: test Class of UnitMakeTrigger and UnitMakeTriggerHelper.
**/
@isTest
public class UnitMakeTriggerHelperTest {
    @isTest
    private static void createUnitMakeTest() {
    	Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
        system.assertEquals(1, [Select Id from Unit_Make__c].size());
    }
    
    @isTest
    private static void createDuplicateUnitMakeInList() {
    	List<Unit_Make__c> unitmakeList = new List<Unit_Make__c>{TestUtil.createUnitMake(false, 'unitMakeName', '12A', true)};
    	unitmakeList.add(TestUtil.createUnitMake(false, 'unitMakeName', '12A', true));
    	try {
    		insert unitmakeList;
    	} catch(system.DmlException e) {
    		system.assertEquals(true, e.getMessage().contains('Duplicate make in list'));
    	}
    }
    
    @isTest
    private static void createDuplicateUnitMakeExistsInDBTest() {
    	Unit_Make__c unitmake = TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	try {
    		insert TestUtil.createUnitMake(true, 'unitMakeName', '12A', true);
    	} catch(system.DmlException e) {
    		system.assertEquals(true, e.getMessage().contains('Make already exists'));
    	}
    }
}