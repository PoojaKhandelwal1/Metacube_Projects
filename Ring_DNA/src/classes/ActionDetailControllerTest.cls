@isTest
public class ActionDetailControllerTest {
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
		ActionDetailController.ActionWrapper initActionObj = ActionDetailController.getActionWrapper();

		system.assertEquals(true, initActionObj.wrapperTaskFields.size()>0);
		Test.stopTest();
	}
	@isTest
	public static void testsaveAction(){
		Test.startTest();        
		Id actionId = ActionDetailController.saveAction(system.JSON.serialize(act), listTask.get(0));
		ActionDetailController.getActionById(actionId);        
		system.assertNotEquals(null, actionId);
		Test.stopTest();
	}

	@isTest
	public static void getFieldsWithLabelsTest() {
		List<CriterionWrapper> fieldsWithLabels;
		List<String> objectList = new List<String>();
		objectList =new List<String>{CadenceConstants.LEAD_OBJECT_NAME,CadenceConstants.DB_OBJECT_NAME };
		Test.startTest();
		fieldsWithLabels = CadenceService.getFieldsWithLabels(objectList);
		Test.stopTest();

		System.assertEquals(true, fieldsWithLabels!=null);
		System.assertEquals(true, fieldsWithLabels.size()>0);
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
		actionWrap = ActionDetailController.getActionData(action.Id);
		Test.stopTest();
		System.assertEquals(true, actionWrap!=null);
	}

	@isTest
	static void updateFieldValueTest() {

		Account act = new Account();  
		Contact con= new Contact();

		Test.startTest();
		ActionDetailController.updateFieldValue(act, 'Name', 'Test', '');
		ActionDetailController.updateFieldValue(act,'AnnualRevenue','1500', 'currency');
		ActionDetailController.updateFieldValue(act, 'SLAExpirationDate__c', '2018-08-13', 'Date');
		ActionDetailController.updateFieldValue(act, 'NumberOfEmployees', '20', 'Number');
		ActionDetailController.updateFieldValue(con, 'EntranceCriteria_Matched_Date__c', '2018-08-13 02:22:26' ,'datetime');
		ActionDetailController.updateFieldValue(con, 'AccountId', 'act.Id', 'ID');

		Test.stopTest();
		System.assertEquals(true, act.AnnualRevenue != null);
		System.assertEquals('Test', act.Name);
	}

	public static boolean numberValidate(Integer int1, Integer int2) {
		if (int1 >=  int2){
			return true;
		} else {
			return false;
		}
	}
}