@isTest
public class LeadsTest {

	public static Lead testLead;
	public static Cadence__c cadenceLead;
	public static Action__c actionCall;
	public static Action__c actionSMS;
	public static CadenceAction__c cadenceActionLeadCall;
	public static CadenceAction__c cadenceActionLeadSMS;
	public static final String CUSTOM_LOGIC = '1 AND (2 AND 3)';
	//Constants 
	public static Final String ACTION_TYPE_CALL = 'Call';
	public static Final String ACTION_TYPE_SMS = 'SMS';
	static{
		actionCall = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert actionCall;
		actionSMS = TestDataFactory.createAction(ACTION_TYPE_SMS);
		insert actionSMS;
		cadenceLead = TestDataFactory.createCadence('Lead');
		cadenceLead.Name='Lead Cadence';
		cadenceLead.Participent_Activation__c='Automatic';
		Criterion entry1 = TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test');
		Criterion entry2 = TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', 'Test');
		String jsonEntryString = TestDataFactory.createCadenceJSON(new List<Criterion>{entry1,entry2}, CadenceConstants.CONDITION_AND, null);
		Criterion exitCriteria = TestDataFactory.createCriterion(1, 'Email', 'STRING', 'equals', 'test@gmail.com');
		String jsonExitString = TestDataFactory.createCadenceJSON(new List<Criterion>{exitCriteria}, CadenceConstants.CONDITION_AND, null);
		cadenceLead.Entrance_Criteria__c = jsonEntryString;
		cadenceLead.Status__c = false;
		cadenceLead.matching_priority__c='P1';
		cadenceLead.Exit_Criteria__c = jsonExitString;
		cadenceActionLeadCall = TestDataFactory.createCadenceAction(cadenceLead.Id, actionCall.Id);
		cadenceActionLeadCall.Trigger_Type__c='Immediate';
		cadenceActionLeadSMS = TestDataFactory.createCadenceAction(cadenceLead.Id, actionSMS.Id);
		cadenceActionLeadSMS.Trigger_Type__c='Immediate';
		testLead=new Lead(FirstName='Test',LastName='Test',Company='Test Company', Status='Open - Not Contacted',Priority__c=3);
		insert testLead;
	}
	@isTest
	public static void onAfterUpdate(){
		Sequence sequenceLead = TestDataFactory.createSequence(cadenceLead);
		SequenceAction sequenceActionLeadCall= TestDataFactory.createSequenceAction(cadenceActionLeadCall);
		SequenceAction sequenceActionLeadSMS= TestDataFactory.createSequenceAction(cadenceActionLeadSMS);
		//Test saveCadence
		CadenceProgressIndicatorController.saveCadence(system.JSON.serialize(sequenceLead), system.JSON.serialize(new List<SequenceAction> {sequenceActionLeadCall,sequenceActionLeadSMS}), New List<String>());
		//To get inserted cadence
		cadenceLead=[SELECT Id, Record_Type__c FROM Cadence__c WHERE Name='Lead Cadence' LIMIT 1];
		//To activate cadence
		CadenceController.activateCadence(cadenceLead.Id);
		List<Sequence_Action__c> sequenceActions=[SELECT Id, isActionPerformed__c FROM Sequence_Action__c WHERE Lead_Id__c=:testLead.Id];
		for(Sequence_Action__c sequenceAction:sequenceActions){
			sequenceAction.isActionPerformed__c=True;
		}
		update sequenceActions;
		Test.startTest();
		Database.LeadConvert leadConvert = new Database.LeadConvert();
		leadConvert.setLeadId(testLead.id);
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		leadConvert.setConvertedStatus(convertStatus.MasterLabel);
		Database.LeadConvertResult result = Database.convertLead(leadConvert);
		Test.stopTest();
		System.assert(result.isSuccess());
		List<Sequence_Action__c> contactSequenceActions=[SELECT Id FROM Sequence_Action__c WHERE Contact_Id__c!=null];
		System.assertEquals(2, contactSequenceActions.size());
	}
}