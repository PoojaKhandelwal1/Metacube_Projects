public with sharing class ActionDetailController {

	public static String nameSpace = CadenceConstants.NAMESPACE;
	public static String TASK_OBJECT_STRING = 'Task';

	@AuraEnabled
	public static ActionDetailController.ActionWrapper getActionWrapper() {
		ActionDetailController.ActionWrapper initActionObj = new ActionDetailController.ActionWrapper();
		initActionObj.wrapperTaskFields = CadenceService.getFields(TASK_OBJECT_STRING);
		initActionObj.action = new Action();
		return initActionObj; 
	}

	public class ActionWrapper {
		@AuraEnabled public List<EmailTemplate> listEmailTemplate;
		@AuraEnabled public List<WrapperTemplateObj> listSmsTemplate;
		@AuraEnabled public List<WrapperTemplateObj> listCallTemplate;
		@AuraEnabled public List<WrapperTemplateObj> listVMTemplate;
		@AuraEnabled public List<CriterionWrapper> wrapperTaskFields;
		@AuraEnabled public Action action;
		public ActionWrapper(){
			listEmailTemplate = new List<EmailTemplate>();
			wrapperTaskFields = new List<CriterionWrapper>();
			listSmsTemplate = new List<WrapperTemplateObj>();
			listCallTemplate = new List<WrapperTemplateObj>();
			listVMTemplate = new List<WrapperTemplateObj>();
			action = new Action();
		}
	}

	@AuraEnabled
	public static Id saveAction(string actWra, Task taskObj) {
		Action action = (Action)System.JSON.deserialize(actWra, Action.class); 
		if (action.type == TASK_OBJECT_STRING){
			Task taskObjToCreateJson = taskObj;
			action.taskDescription = JSON.serialize(taskObjToCreateJson);
		}
		Action__c act = getAction(action);
		upsert act;
		return act.id;
	}

	public static Action__c getAction(Action actionCls){
		Action__c action = new Action__c();
		action.Name = actionCls.name;
		action.Activation_Type__c = actionCls.activationType;
		action.Task_Description__c = actionCls.taskDescription;
		action.Template_Id__c = actionCls.templateId;
		action.Template_Name__c = actionCls.templateName;
		action.Type__c = actionCls.type;
		action.Id = actionCls.id;
		action.Email_Type__C = actionCls.emailType;
		action.Delivery_Preference__c = actionCls.deliveryPreference;
		return action;
	}

	public class WrapperTemplateObj{
		@AuraEnabled public String Id;
		@AuraEnabled public String Name;
	}

	public class wrapperTaskField {
		@AuraEnabled public String key;
		@AuraEnabled public String value;
		@AuraEnabled public String apiName;
		@AuraEnabled public String dataType;
		@AuraEnabled public List<String> listPicklistValues;
	}

	public static void updateFieldValue(SObject obj, String fieldName, String value, String fieldType) {
		if(fieldType.equalsIgnoreCase('currency') || fieldType.equalsIgnoreCase('double') || fieldType.equalsIgnoreCase('percent') || fieldType.equalsIgnoreCase('decimal')) {
			obj.put(fieldName, Decimal.valueOf(value)); 
		} else if(fieldType.equalsIgnoreCase('boolean')) {
			obj.put(fieldName, boolean.valueOf(value));
		} else if(fieldType.equalsIgnoreCase('date')) {
			obj.put(fieldName, date.valueOf(value));
		} else if(fieldType.equalsIgnoreCase('datetime')) {
			obj.put(fieldName, datetime.valueOf(value));
		} else if(fieldType.equalsIgnoreCase('integer') || fieldType.equalsIgnoreCase('Number') ) {
			obj.put(fieldName, Integer.valueOf(value));
		} else if(fieldType.equalsIgnoreCase('reference')){
			obj.put(fieldName, ID.valueOf(value));
		} else {
			obj.put(fieldName, value);
		}   
	}

	@AuraEnabled
	public static ActionDetailController.ActionDataWrapper getActionData(Id actionId) {
		ActionDetailController.ActionDataWrapper actionDataWrapper = new ActionDetailController.ActionDataWrapper();
		Action__c action = [Select Id, Name, Activation_Type__c, Email_Type__C, Delivery_Preference__c, Task_Description__c, Template_Id__c, Template_Name__c, Type__c From Action__c where Id = :actionId];
		Action actionCls = New Action(action.Id, action.Activation_Type__c, action.Name, action.Task_Description__c,
				action.Template_Id__c, action.Template_Name__c, action.Type__c, action.Email_Type__C, action.Delivery_Preference__c);
		actionDataWrapper.actionCls = actionCls;	
		if((action.Task_Description__c != null) && action.Task_Description__c != '') {
			Map<String, Object> taskObjs = (Map<String, Object>)JSON.deserializeUntyped(action.Task_Description__c);
			taskObjs.remove('attributes');
			List<wrapperTaskField> wrapperTaskFieldObjs = new List<wrapperTaskField>();
			for(String key : taskObjs.keySet()) {
				wrapperTaskField wrapperTaskFieldObj = new wrapperTaskField();
				wrapperTaskFieldObj.key = key;
				wrapperTaskFieldObj.value = String.valueOf(taskObjs.get(key));
				wrapperTaskFieldObjs.add(wrapperTaskFieldObj);
			}
			actionDataWrapper.taskList = wrapperTaskFieldObjs;              
		}
		return actionDataWrapper;
	}
	@AuraEnabled
	public static Action getActionById(Id actionId) {
		Action__c action = [Select Id, Name, Activation_Type__c, Task_Description__c, Template_Id__c, 
		                    Template_Name__c, Type__c From Action__c where Id = :actionId];

		Action actionCls = New Action(action.Id, action.Activation_Type__c, action.Name, action.Task_Description__c,
				action.Template_Id__c, action.Template_Name__c, action.Type__c);
		return actionCls;
	}

	public class ActionDataWrapper {
		@AuraEnabled public Action actionCls;
		@AuraEnabled public List<wrapperTaskField> taskList; 
	}
}