@isTest
public class DynamicActionDetailsControllerTest {
	public static Action__C act; 
	public static List<Task> listTask;
	Public static Final String ACTION_TYPE_Email = 'Email';
	Public static Final String ACTION_TYPE_Call = 'Call';
	Public static Final String ACTION_TYPE_SMS = 'SMS';
	Public static Final String ACTION_TYPE_Voicemail = 'Call+Voicemail';
	public static EmailTemplate validEmailTemplate;
	static {
		validEmailTemplate=[select Id, isActive, Name, DeveloperName, TemplateType, FolderId, Subject from EmailTemplate LIMIT 1][0];
		Action__c actionObj = TestDataFactory.createAction(ACTION_TYPE_Email);
		actionObj.Name = 'testName';
		actionObj.Type__c = 'Task';
		actionobj.Template_Id__c=validEmailTemplate.Id;
		actionObj.Activation_Type__c = 'Automatic';
		act = actionObj;
		Task taskObj = new Task();
		taskObj.subject = 'Description';
		taskObj.Description = 'testDesc';
		listTask = new List<Task>();
		listTask.add(taskObj);
	}

	@isTest
	public static void testInitCadenceActionData(){
		Action__c callAction = new Action__c();
		callAction.Name = 'Test callAction';
		callAction.Type__c = 'Call';
		callAction.Activation_Type__c = 'Manual';
		callAction.Task_Description__c = '{"attributes":{"type":"Task"},"Status":"Deferred","CallDisposition":"Working","CallDurationInSeconds":2,"RecurrenceRegeneratedType":"After due date"}})';
		insert callAction;
		Action__c smsAction = new Action__c();
		smsAction.Name = 'Test smsAction';
		smsAction.Type__c = 'SMS';
		smsAction.Activation_Type__c = 'Manual';
		smsAction.Task_Description__c = '{"attributes":{"type":"Task"},"Status":"Deferred","CallDisposition":"Working","CallDurationInSeconds":2,"RecurrenceRegeneratedType":"After due date"}})';
		insert smsAction;
		Action__c vmAction = new Action__c();
		vmAction.Name = 'Test vmAction';
		vmAction.Type__c = 'Call+Voicemail';
		vmAction.Activation_Type__c = 'Manual';
		vmAction.Task_Description__c = '{"attributes":{"type":"Task"},"Status":"Deferred","CallDisposition":"Working","CallDurationInSeconds":2,"RecurrenceRegeneratedType":"After due date"}})';
		insert vmAction;
		Test.startTest();
		ActionDetailController.ActionWrapper initActionObj = DynamicActionDetailsController.getActionWrapper();
		system.assertEquals(true, initActionObj.wrapperTaskFields.size()>0);
		Test.stopTest();
	}

	@isTest
	public static void testsaveAction(){
		Test.startTest();        
		Id actionId = DynamicActionDetailsController.saveAction(system.JSON.serialize(act), listTask.get(0));        
		system.assertNotEquals(null, actionId);
		Test.stopTest();
	}

	@isTest
	static void getActionDataTest() {

		Action__c action = new Action__c();
		action.Name = 'Test Action';
		action.Type__c = 'Call';
		action.Activation_Type__c = 'Manual';
		action.Task_Description__c = '{"attributes":{"type":"Task"},"Status":"Deferred","CallDisposition":"Working","CallDurationInSeconds":2,"RecurrenceRegeneratedType":"After due date"}})';
		insert action;
		ActionDetailController.ActionDataWrapper actionWrap;
		Test.startTest();
		actionWrap = DynamicActionDetailsController.getActionData(action.Id);
		Test.stopTest();

		System.assertEquals(true, actionWrap!=null);
	}

}