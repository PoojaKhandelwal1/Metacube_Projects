/**
 * Author: Gourav goyal
 * Since: July 28, 2017
 * Name: Utility_TriggerSoftDisbale Test 
 * Description: test Utility class for Disabling Triggers.
**/
@isTest
private class Utility_TriggerSoftDisbaleTest {
     /**
     * Name: insertOperationTest
     * Desc: insert triggerSoftDisable object & trigger name for disable check on dml operations
     * @param:  
     * @return: 
    **/
    
    static testmethod void insertOperationTest() {
        Trigger_Soft_Disable__c tsdObj = new Trigger_Soft_Disable__c();
        tsdObj.name = 'SOTrigger';
        tsdObj.Disable_Delete__c = true;
        tsdObj.Disable_Insert__c = true;
        tsdObj.Disable_Undelete__c = true;
        tsdObj.Disable_Update__c = true;
        insert tsdObj;
        
        test.startTest();
        Utility_TriggerSoftDisbale utsObj = new Utility_TriggerSoftDisbale('SOTrigger');
        boolean insertCheck = utsObj.insertDisabled();
        boolean updateCheck = utsObj.updateDisabled();
        boolean deleteCheck = utsObj.deleteDisabled();
        boolean beforedeleteCheck = utsObj.undeleteDisabled();
        test.stopTest();
        system.assertEquals(insertCheck,true);
        system.assertEquals(updateCheck,true);
        system.assertEquals(deleteCheck,true);
        system.assertEquals(beforedeleteCheck,true);
    }
}