public class SequenceAction {
	@AuraEnabled public Id id {get; set;}
	@AuraEnabled public String actionCriterion {get; set;}
	@AuraEnabled public String actionCriterionPE {get; set;}
	@AuraEnabled public String actionId {get; set;}
	@AuraEnabled public String day {get; set;}
	@AuraEnabled public String fieldsToUpdateAction {get; set;}
	@AuraEnabled public String hour {get; set;}
	@AuraEnabled public String index {get; set;}
	@AuraEnabled public String name {get; set;}
	@AuraEnabled public String priority {get; set;}
	@AuraEnabled public String priorityNumber {get; set;}
	@AuraEnabled public String cadenceId {get; set;}
	@AuraEnabled public String triggerType {get; set;}
	// required extra properties for edit case
	@AuraEnabled public String actiontemplateId {get; set;}
	@AuraEnabled public String actiontype {get; set;}
	public SequenceAction(){

	}
	public SequenceAction (Id saId, string saActionCriterion, string saActionCriterionPE, string saActionId, string saDay, 
			string saFieldsToUpdateAction, string saHour, string saIndex, string  saName, string  saPriority,
			string saPriorityNumber, string saCadenceId, string saTriggerType){
		id = saId;
		actionCriterion = saActionCriterion;
		actionCriterionPE = saActionCriterionPE;
		actionId = saActionId;
		day = saDay;
		fieldsToUpdateAction = saFieldsToUpdateAction;
		hour = saHour;
		index = saIndex;
		name = saName;
		priority = saPriority;
		priorityNumber = saPriorityNumber;
		cadenceId = saCadenceId;
		triggerType = saTriggerType;
	}
}