@isTest
public class TestDataFactory {
	public static String nameSpace = CadenceConstants.NAMESPACE;
	public static Account createAccount() {
		Account acc = new Account();
		acc.Name = 'Test Account';
		return acc;
	}

	public static Contact createContact(Id accId, Id cadenceId) {
		Contact cont = new Contact();
		cont.LastName = 'Test Contact';
		cont.AccountId = accId;
		cont.Cadence_ID__c = cadenceId;
		return cont;
	}

	public static Lead createLead(Id cadenceId) {
		Lead l = new Lead();
		l.LastName = 'Test Lead';
		l.Company = 'Test Company';
		l.Cadence_Id__c = cadenceId;
		l.Priority__C = 12;
		l.isActivated__c = true;
		return l;
	}

	public static Opportunity createOpp(String name) {
		Opportunity opp= new Opportunity();
		opp.Name = name;
		opp.CloseDate = system.today();
		opp.StageName = 'Qualification';
		return opp;
	}

	public static OpportunityContactRole createOpportunityRole(Id opportunityId,Id contactId) {
		OpportunityContactRole oppRole = new OpportunityContactRole();
		oppRole.ContactId = contactId;
		oppRole.OpportunityId = opportunityId;
		return oppRole;
	}    

	public static Lead createLead() { 
		Lead l = new Lead();
		l.LastName = 'Test Lead';
		l.Company = 'Test Company';
		l.Priority__C = 12;
		return l;
	}

	public static Action__c createAction(String actionType) {
		Action__c action = new Action__c();
		action.Name = 'Test Action';
		action.Type__c = actionType;
		action.Activation_Type__c = 'Automatic';
		return action;
	}

	public static Cadence__c createCadence(String recordType) {
		Cadence__c cad = new Cadence__c();
		cad.Name = 'Test Cadence';
		cad.Record_Type__c = recordType;
		cad.Status__c = true;
		cad.Participent_Activation__c = 'Automatic'; 
		return cad;
	} 

	public static Sequence createSequence(Cadence__c cObj) {    	        
		Sequence sequence  = new Sequence(cObj.Id, cObj.Entrance_Criteria__c, '', cObj.Exit_Criteria__c, 
				'', cObj.matching_priority__c, cObj.Name, cObj.Participent_Activation__c,
				cObj.Record_Type__c, string.valueOf(cObj.Status__c), string.valueOf(cObj.Total_Participants__c));                
		return sequence;
	}

	public static CadenceAction__c createCadenceAction(Id cadId, Id actionId) {
		CadenceAction__c cadAction = new CadenceAction__c();
		cadAction.Cadence_Id__c = cadId;
		cadAction.Action_Id__c = actionId;
		cadAction.Name = 'Test Cadence Action';
		cadAction.Trigger_Type__c = 'Immediate';

		return cadAction;
	}

	public static SequenceAction createSequenceAction(CadenceAction__c cadenceAction) {
		SequenceAction sequenceAction = new SequenceAction (cadenceAction.Id, cadenceAction.Action_Criterion__c, 
				null, string.valueOf(cadenceAction.Action_Id__c), 
				string.valueOf(cadenceAction.Day__c), 
				cadenceAction.Fields_To_Update_Action__c, 
				string.valueOf(cadenceAction.Hour__c), null, 
				cadenceAction.Name, cadenceAction.Priority__c,
				null, string.valueOf(cadenceAction.Cadence_Id__c), 
				cadenceAction.Trigger_Type__c);

		return sequenceAction;
	}
	
	public static Sequence_Action__c createParticipantAction(Id participantId, Id sequenceActionId, String participantType) {
		Sequence_Action__c  participantAction = new Sequence_Action__c();
		participantAction.Name= 'demoname';
		if(participantType == 'Contact') {
			participantAction.Contact_Id__c = participantId;
		} else {
			participantAction.Lead_Id__c = participantId;
		}
		participantAction.CadenceAction_ID__c=sequenceActionId;
		participantAction.isActionPerformed__c=false;
		participantAction.Show_on_Target_List__c = false;
		return participantAction;
	}

	public static String createCadenceJSON(List<Criterion> criterionList, String condition, String priorityFormula) {

		Map<Integer, Criterion> criterionMap = new Map<Integer, Criterion>();
		for(Criterion crit : criterionList) {
			criterionMap.put(crit.Id, crit);
		}

		CriterionSet cs= new CriterionSet();
		cs.criterionPriorityFormula='';
		if(condition.containsIgnoreCase('AND')) {
			cs.condition = CadenceConstants.CONDITION_AND;
		} else if(condition.containsIgnoreCase('OR')) {
			cs.condition = CadenceConstants.CONDITION_OR;
		} else {
			cs.condition = CadenceConstants.CONDITION_CUSTOM;
			cs.criterionPriorityFormula = priorityFormula;
		}

		cs.executionCriterion = 'Conditions are met';
		cs.criterions = criterionMap;

		String criterionJSON = JSON.serialize(cs);
		return criterionJSON;

	}

	public static Criterion createCriterion(Integer id, String fieldName, String fieldDataType, String operation, String value){
		Criterion c = new Criterion();
		c.id = id;
		c.fieldName = fieldName;
		c.fieldDataType = fieldDataType;
		c.operation = operation;
		c.value = value;
		return c;
	}

	public static String createCadJsonWithNameCriterions(String firstName, String lastName, String condition, String priorityFormula) {
		List<Criterion> criterionList = new List<Criterion>();
		Criterion c1 = TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', firstName);
		Criterion c2 = TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', lastName);
		Criterion c3 = TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Rest');
		criterionList.add(c1);
		criterionList.add(c2);
		criterionList.add(c3);
		return createCadenceJSON(criterionList, condition, priorityFormula);
	}

	public static String createCadJsonWithNameCriterionsForOpp(String firstName, String condition, String priorityFormula) {
		List<Criterion> criterionList = new List<Criterion>();
		Criterion c1 = TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', firstName);
		criterionList.add(c1);
		return createCadenceJSON(criterionList, condition, priorityFormula);
	}

	public static String createCadJsonWithSmallerOperatorCriterions(String firstName, String lastName, String condition, String priorityFormula) {
		String priority = nameSpace+'Priority__c';
		List<Criterion> criterionList = new List<Criterion>();
		Criterion c1 = TestDataFactory.createCriterion(1, priority , 'Number', 'less_than', '8');
		criterionList.add(c1);
		return createCadenceJSON(criterionList, condition, priorityFormula);
	}

	public static String createCadJsonWithGreaterOperatorCriterions(String firstName, String lastName, String condition, String priorityFormula) {
		String priority = nameSpace+'Priority__c';
		List<Criterion> criterionList = new List<Criterion>();
		Criterion c1 = TestDataFactory.createCriterion(1, priority , 'Number', 'greater', '5');
		criterionList.add(c1);
		return createCadenceJSON(criterionList, condition, priorityFormula);
	}
	public static String createCadJsonWithNameCriterionsForOppRole(String values, String condition, String  priorityFormula) {
		List<Criterion> criterionList = new List<Criterion>(); 
		Criterion c1 = TestDataFactory.createCriterion(1, 'OpportunityContactRole.Role', 'PICKLIST', 'equals', values);
		criterionList.add(c1);
		return createCadenceJSON(criterionList, condition, priorityFormula);
	}
	public static String createCadJsonWithConditionalCriterionsForOpp(String values, String condition, String priorityFormula,string operator) {
		List<Criterion> criterionList = new List<Criterion>();
		Criterion c1 = TestDataFactory.createCriterion(1, 'Amount', 'Number', operator, values);
		Criterion c2 = TestDataFactory.createCriterion(1, 'CloseDate', 'Date', operator, String.valueof(System.today()));
		criterionList.add(c1);
		criterionList.add(c2);
		return createCadenceJSON(criterionList, condition, priorityFormula); 
	}
}