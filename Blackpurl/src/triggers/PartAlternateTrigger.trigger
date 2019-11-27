trigger PartAlternateTrigger on Part_Alternates__c (before insert, before update) {
    
    PartAlternateTriggerHelper.PartAlternateNewList = Trigger.new;
    PartAlternateTriggerHelper.PartAlternateOldList = Trigger.old;
    PartAlternateTriggerHelper.PartAlternateNewMap = Trigger.newMap;
    PartAlternateTriggerHelper.PartAlternateOldMap = Trigger.oldMap;
    
    Utility_TriggerSoftDisbale utilObj = new Utility_TriggerSoftDisbale('PartAlternateTrigger');
    
    if(Trigger.isBefore) {
        if(Trigger.isInsert && !utilObj.insertDisabled()) {
            PartAlternateTriggerHelper.validatiePartSelfRelation();
            PartAlternateTriggerHelper.populatePartRelationUniqueCheck();
        } else if(Trigger.isUpdate && !utilObj.updateDisabled()) {
        	PartAlternateTriggerHelper.validatiePartSelfRelation();
         	PartAlternateTriggerHelper.populatePartRelationUniqueCheck();
        }
    }       
}