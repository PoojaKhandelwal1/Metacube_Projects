public class DynamicActionDetailsController {
	public static String nameSpace = CadenceConstants.NAMESPACE;
	public static String TASK_OBJECT_STRING = 'Task';

	@AuraEnabled
	public static ActionDetailController.ActionWrapper getActionWrapper() {
		ActionDetailController.ActionWrapper initActionObj = new ActionDetailController.ActionWrapper();
		initActionObj.listEmailTemplate = CadenceService.getEmailTemplates();
		if(!test.isRunningTest()){
			initActionObj.listSmsTemplate = CadenceService.getSMSTemplates();
			initActionObj.listCallTemplate = CadenceService.getCallTemplates();
			initActionObj.listVMTemplate = CadenceService.getVMTemplates();
		}
		initActionObj.wrapperTaskFields = CadenceService.getFields(TASK_OBJECT_STRING);
		initActionObj.action = new Action();
		return initActionObj; 
	}

	@AuraEnabled
	public static Id saveAction(string actWra, Task taskObj) {
		Action action = (Action)System.JSON.deserialize(actWra, Action.class); 
		if (action.type == TASK_OBJECT_STRING){
			Task taskObjToCreateJson = taskObj;
			action.taskDescription = JSON.serialize(taskObjToCreateJson);
		}
		Action__c act = ActionDetailController.getAction(action);
		upsert act;
		return act.id;
	}

	@AuraEnabled
	public static ActionDetailController.ActionDataWrapper getActionData(Id actionId) {
		ActionDetailController.ActionDataWrapper actionDataWrapper = new ActionDetailController.ActionDataWrapper();
		Action__c action = [Select Id, Name, Activation_Type__c, Task_Description__c, Template_Id__c, Template_Name__c, Type__c From Action__c where Id = :actionId];
		Action actionCls = New Action(action.Id, action.Activation_Type__c, action.Name, action.Task_Description__c,
				action.Template_Id__c, action.Template_Name__c, action.Type__c);
		actionDataWrapper.actionCls = actionCls;	
		if((action.Task_Description__c != null) && action.Task_Description__c != '') {
			Map<String, Object> taskObjs = (Map<String, Object>)JSON.deserializeUntyped(action.Task_Description__c);
			taskObjs.remove('attributes');
			List<ActionDetailController.wrapperTaskField> wrapperTaskFieldObjs = new List<ActionDetailController.wrapperTaskField>();
			for(String key : taskObjs.keySet()) {
				ActionDetailController.wrapperTaskField wrapperTaskFieldObj = new ActionDetailController.wrapperTaskField();
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
}