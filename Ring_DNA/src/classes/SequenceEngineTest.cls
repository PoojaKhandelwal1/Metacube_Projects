@isTest
public class SequenceEngineTest {
	
	public static String cadJsonobj;
	public static CadenceAction__c cadenceActionobj;
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;
	
	static testMethod void processSequencesForLeadTest() {
		List<SObject> participantList = new List<SObject>();
		List<Criterion> criterionList = new List<Criterion>();
		List<Criterion> exitCriterionList = new List<Criterion>();
		
		Cadence__c cadenceobj = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		criterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test#11'));
		criterionList.add(TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
		criterionList.add(TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test'));
		
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

		action1= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action2= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			EmailTemplate validEmailTemplate = new EmailTemplate();
			validEmailTemplate.isActive = true;
			validEmailTemplate.Name = 'name';
			validEmailTemplate.DeveloperName = 'unique_name';
			validEmailTemplate.TemplateType = 'text';
			validEmailTemplate.Body='Test Body for {!Lead.Name}';
			validEmailTemplate.Subject='New {!Lead.Name}';
			validEmailTemplate.FolderId = UserInfo.getUserId();
			insert validEmailTemplate;
			EmailTemplate template = validEmailTemplate;
			action1.Template_Id__c= validEmailTemplate.id;
		}
		action1.Activation_Type__c='Manual';
		action1.Email_Type__c='NATIVE';
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 

		CadenceAction__C seqActionRec=TestDataFactory.createCadenceAction(cadenceobj.Id, action1.Id);
		seqActionRec.Day__c= 2;
		seqActionRec.Hour__c=2;
		seqActionRec.Trigger_Type__c = 'Time Based';
		insert seqActionRec;
		
		

		Lead leadRec = TestDataFactory.createLead(cadenceobj.Id);
		leadRec.Email = 'test@gmail.com';
		insert leadRec;
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		participantList.add(leadRec);

		Test.startTest();
		SequenceEngine.processSequences(CadenceConstants.LEAD_OBJECT_NAME,participantList,null,true);
		Test.stopTest();
	}
	
	static testMethod void processSequencesForLeadByTriggerTest() {
		List<SObject> participantList = new List<SObject>();
		List<Criterion> criterionList = new List<Criterion>();
		List<Criterion> exitCriterionList = new List<Criterion>();
		
		Cadence__c cadenceobj = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		criterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test#11'));
		criterionList.add(TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
		criterionList.add(TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test'));
		
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

		action1= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action2= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 
		
		CadenceAction__C seqActionRec=TestDataFactory.createCadenceAction(cadenceobj.Id, action1.Id);
		seqActionRec.Day__c= 2;
		seqActionRec.Hour__c=2;
		seqActionRec.Trigger_Type__c = 'Time Based';
		insert seqActionRec;
		
		Id cuId = UserInfo.getUserID();

		Lead leadRec = TestDataFactory.createLead(cadenceobj.Id);
		leadRec.Email = 'test@gmail.com';
		insert leadRec;
		Sequence_Action__c participantAction = TestDataFactory.createParticipantAction(leadRec.Id, seqActionRec.Id, CadenceConstants.LEAD_OBJECT_NAME);
		insert participantAction;
		participantList.add(leadRec);

		Test.startTest();
		SequenceEngine.processSequences(CadenceConstants.LEAD_OBJECT_NAME,participantList,null,true);
		Test.stopTest();
	}
}