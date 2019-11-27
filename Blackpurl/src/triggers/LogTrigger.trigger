/**
 * Author: Rajat Jain
 * Since: May 22, 2018
 * Name: LogTrigger
 * Description: Trigger executes after insert event of Log object
**/
trigger LogTrigger on Log__c (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert) { 
        LogTriggerHelper.afterInsert(trigger.new);
   	}
}