public class Action {
	@AuraEnabled public Id id {get; set;}
	@AuraEnabled public string activationType {get; set;}
	@AuraEnabled public string name {get; set;}
	@AuraEnabled public string taskDescription {get; set;}
	@AuraEnabled public string templateId {get; set;}
	@AuraEnabled public string templateName {get; set;}
	@AuraEnabled public string type {get; set;}
	@AuraEnabled public string emailType {get; set;}
	@AuraEnabled public string deliveryPreference {get; set;}

	public Action (){
	}

	public Action (Id actionId, string actionActivationType, string actionName, string actionTaskDescription, 
			string ActionTemplateId, string actionTemplateName, string actionType){
		id = actionId;
		activationType = actionActivationType;
		name = actionName;
		taskDescription = actionTaskDescription;
		templateId = ActionTemplateId;
		templateName = actionTemplateName;
		type = actionType;
	}
	public Action (Id actionId, string actionActivationType, string actionName, string actionTaskDescription, 
			string ActionTemplateId, string actionTemplateName, string actionType, string actioEmailType,
			string actionDeliveryPreference){
		id = actionId;
		activationType = actionActivationType;
		name = actionName;
		taskDescription = actionTaskDescription;
		templateId = ActionTemplateId;
		templateName = actionTemplateName;
		type = actionType;
		emailType = actioEmailType;
		deliveryPreference = actionDeliveryPreference;
	}
}