/**
 * Author: Tarun Khandelwal
 * Since: Aug 20, 2016
 * Name: Utility_TriggerSoftDisbale
 * Description: Utility class for Disabling Triggers
**/
public with sharing class Utility_TriggerSoftDisbale {
  
  private Trigger_Soft_Disable__c custSetting;
    
    public Utility_TriggerSoftDisbale(String triggerName) {
        List<Trigger_Soft_Disable__c> custSettingList = Trigger_Soft_Disable__c.getAll().values();

        for(Trigger_Soft_Disable__c custSettingRec : custSettingList){
            if(custSettingRec.Name == triggerName){
                custSetting = custSettingRec;
                break;
            }
        }
    }
    
    public boolean insertDisabled() {
        return custSetting != null && custSetting.disable_insert__c;
    }
  
  public boolean updateDisabled() {
        return custSetting != null && custSetting.disable_update__c;
    }
    
    public boolean deleteDisabled() {
        return custSetting != null && custSetting.disable_delete__c;
    }
    
    public boolean undeleteDisabled() {
        return custSetting != null && custSetting.disable_undelete__c;
    }
}