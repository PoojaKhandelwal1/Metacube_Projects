@isTest
public with sharing class RuleCriterionMatcherTest {
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	Public static Final String ACTION_TYPE_CALL = 'Call';
	Public static Final String ACTION_TYPE_Email = 'Email';
	public static final String CUSTOM_LOGIC1 = '1 AND (2 AND 3)';
	public static final String CUSTOM_LOGIC2 = '1 OR (2 OR 3)';

	public static Cadence__c cadLeadAND;
	public static Cadence__c cadLeadOR;
	public static Cadence__c cadLeadCUSTOM;

	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;

	public static CadenceAction__c cadenceActionLeadAND;
	public static CadenceAction__c cadenceActionLeadOR;
	public static CadenceAction__c cadenceActionCUSTOM;

	public static String cadJsonAND;
	public static String cadJsonOR;
	public static String cadJsonCUSTOM; 

	static {

		cadLeadAND = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadLeadOR = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadLeadCUSTOM = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);

		List<Criterion> criterionList = new List<Criterion>();
		criterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test#11'));
		criterionList.add(TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
		criterionList.add(TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test'));

		cadJsonAND = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		cadJsonOR = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_OR, '');
		cadJsonCUSTOM = TestDataFactory.createCadJsonWithNameCriterions('Rest#11', 'Rest#11', CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);

		cadLeadAND.Entrance_Criteria__c = cadJsonAND;
		cadLeadAND.Exit_Criteria__c = cadJsonCUSTOM;
		cadLeadAND.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadLeadAND.Participent_Activation__c='Automatic';
		cadLeadAND.matching_priority__c = 'P1';

		cadLeadOR.Entrance_Criteria__c = cadJsonOR;
		cadLeadOR.Exit_Criteria__c =  cadJsonCUSTOM;
		cadLeadOR.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadLeadOR.Participent_Activation__c = 'Automatic';
		cadLeadOR.matching_priority__c = 'P2';

		cadLeadCUSTOM.Entrance_Criteria__c = cadJsonCUSTOM;
		cadLeadCUSTOM.Exit_Criteria__c = cadJsonAND;
		cadLeadCUSTOM.Entrance_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadLeadCUSTOM.Participent_Activation__c='Automatic';
		cadLeadCUSTOM.matching_priority__c = 'P3';

		insert cadLeadAND;
		insert cadLeadOR;
		insert cadLeadCUSTOM;

		action1= TestDataFactory.createAction(ACTION_TYPE_Email);
		action2= TestDataFactory.createAction(ACTION_TYPE_Email);
		action3= TestDataFactory.createAction(ACTION_TYPE_Email);
		action1.Template_Id__c= '00Xf4000001cPpjEAE';
		action2.Template_Id__c= '00Xf4000001cPpjEAE';
		action3.Template_Id__c= '00Xf4000001cPpjEAE';

		action1.Activation_Type__c = 'Automatic';
		action2.Activation_Type__c = 'Automatic';
		action3.Activation_Type__c = 'Automatic';
		insert action1;
		insert action2;
		insert action3; 

		cadenceActionLeadAND=TestDataFactory.createCadenceAction(cadLeadAND.Id, action1.Id);
		cadenceActionLeadOR=TestDataFactory.createCadenceAction(cadLeadOR.Id, action2.Id);
		cadenceActionCUSTOM=TestDataFactory.createCadenceAction(cadLeadCUSTOM.Id, action3.Id);

		cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
		cadenceActionLeadOR.Trigger_Type__c = 'Immediate';
		cadenceActionCUSTOM.Trigger_Type__c = 'Immediate';
		insert cadenceActionLeadAND;
		insert cadenceActionLeadOR;
		insert cadenceActionCUSTOM;

	}

	@isTest 
	static void leadMatchesCriterionTest() {
		Lead l1= new Lead();
		l1.Company='COM';
		l1.FirstName='Test#11';
		l1.LastName='lname';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Title = 'Test';
		insert l1;

		Lead l2 = TestDataFactory.createLead();
		l2.status = 'Open - Not Contacted';
		l2.LeadSource = 'Other';
		l2.Title = 'SecondTest';
		l2.Company='SecondCOM';
		l2.FirstName='fname2';
		l2.LastName='lname2';
		insert l2;

		Test.startTest();
		CadenceController.updateParticipants(cadLeadAND.Id);
		CadenceController.updateParticipants(cadLeadOR.Id);
		Test.stopTest();

		l1 = [Select Id, Cadence_Id__c from Lead where Id = :l1.Id];

		l2 = [Select Id, Cadence_Id__c from Lead where Id = :l2.Id];

		System.assertEquals(cadLeadOR.Id, l2.Cadence_Id__c, 'Cadence lookup will not populate as its criterion not matches');
		// Deactivate cadence
		CadenceService.setParticipantsActivation(cadLeadAND.Id,false);
		l1 = [Select Id, isActivated__c, Cadence_Id__c from Lead where Id = :l1.Id];
		// Activate cadence
		CadenceService.setParticipantsActivation(cadLeadAND.Id,true);
		l1 = [Select Id, isActivated__c, Cadence_Id__c from Lead where Id = :l1.Id];
		System.assertEquals(true, l1.isActivated__c, 'lead activated through cadence');
		// Perform email Actions
		EmailTemplate et=[Select id from EmailTemplate where name = 'Sales: New Customer Email' limit 1];
		cadenceService.createEmailMessage(l1.Id,et.Id);
		// Perform Task Action
		String taskDesc = '{"attributes":{"type":"Task"},"Status":"Not Started","CallType":"Internal","Subject":"Test Sub"}';
		cadenceService.performTaskAction(l1.Id,taskDesc);
		// Update field 
		CadenceUtil.updateFieldValue(l1, 'isActivated__c', false, 'boolean');
		CadenceUtil.updateFieldValue(l1, 'FirstName', 'fName', 'String');
		System.assertEquals(false, l1.isActivated__c, 'lead deactivaed through cadence');

	}  

	@isTest 
	static void leadNotMatchesCriterionTest() {

		Lead l3 = TestDataFactory.createLead();
		l3.status = 'Closed- Converted';
		l3.LeadSource = 'Web23';
		l3.Title = 'demoTe';
		insert l3;

		Test.startTest();
		CadenceController.updateParticipants(cadLeadAND.Id);
		Test.stopTest();

		l3 = [Select Id, Cadence_Id__c from Lead where Id = :l3.Id];

		System.assertEquals(null, l3.Cadence_Id__c , 'Cadence lookup will not populate as its criterion not matches');

	}


	@isTest 
	static void leadMatchesCustomCriterionTest() {

		Lead l4 = TestDataFactory.createLead();
		l4.FirstName = 'Rest#11';
		l4.LastName = 'Rest#11';
		insert l4;

		Test.startTest();
		CadenceController.updateParticipants(cadLeadCUSTOM.Id);
		Test.stopTest();

		l4 = [Select Id, Cadence_Id__c from Lead where Id = :l4.Id];

		System.assertEquals(cadLeadCUSTOM.Id, l4.Cadence_Id__c, 'Cadence lookup will populate as its criterion matches');

	}


	@isTest 
	static void leadNotMatchesCustomCriterionTest() {

		Lead l5 = TestDataFactory.createLead();
		l5.FirstName = 'Rest';
		l5.LastName = 'Rest';
		insert l5;

		Test.startTest();
		CadenceController.updateParticipants(cadLeadCUSTOM.Id);
		Test.stopTest();

		l5 = [Select Id, Cadence_Id__c from Lead where Id = :l5.Id];

		System.assertEquals(null, l5.Cadence_Id__c, 'Cadence lookup will not populate as its criterion not matches');

	}
}