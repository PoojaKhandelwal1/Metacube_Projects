@isTest
public class CadenceActionListControllerTest { 
	Public static Final String ACTION_TYPE_CALL = 'Call';

	public static Cadence__c cadence1;
	public static Cadence__c cadence2;
	public static Cadence__c cadenceobj;
	public static Action__c actionobj;
	public static String cadJsonobj;
	public static Sequence_Action__c actionOnParticipants; 
	public static CadenceAction__c cadenceActionobj;
	public static CadenceAction__c cadenceAction1;
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	Public static Final String ACTION_TYPE_Email = 'Email';
	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;

	public static CadenceAction__c cadenceAction;


	@isTest
	public static void deleteActionTest(){
		cadenceobj = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		List<Criterion> criterionList = new List<Criterion>();
		criterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test#11'));
		criterionList.add(TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
		criterionList.add(TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test'));

		List<Criterion> exitCriterionList = new List<Criterion>();
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		exitCriterionList.add(TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', 'Lead'));
		String exitCriterion = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		cadenceobj.Entrance_Criteria__c= cadJsonobj;
		cadenceobj.Exit_Criteria__c=exitCriterion;
		cadenceobj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadenceobj.matching_priority__c='P1';
		cadenceobj.Participent_Activation__c='Automatic';
		insert cadenceobj;

		action1= TestDataFactory.createAction(ACTION_TYPE_CALL);
		action2= TestDataFactory.createAction(ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 
		List<Id> actionIdListForDelete  = new List<Id>();
		actionIdListForDelete.add(action1.Id);
		actionIdListForDelete.add(action2.Id);
		actionIdListForDelete.add(action3.Id);

		cadenceActionobj=TestDataFactory.createCadenceAction(cadenceobj.Id, action1.Id);
		cadenceActionobj.Day__c= 2;
		cadenceActionobj.Hour__c=2;
		cadenceActionobj.Trigger_Type__c = 'Time Based';
		insert cadenceActionobj;

		Lead l = TestDataFactory.createLead(cadenceobj.id);
		insert l;

		Test.startTest();
		CadenceActionListController.deleteActions(actionIdListForDelete);
		Test.stopTest();
		List<Action__c> actions = [Select Id from Action__c where Id IN :actionIdListForDelete];
		System.assertEquals(actions.size(), 0);    
	} 
}