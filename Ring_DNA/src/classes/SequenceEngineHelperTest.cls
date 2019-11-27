@isTest
public class SequenceEngineHelperTest {
	
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	
	@testSetup
	static void testSetupData() {
		List<Cadence__c> sequenceListToInsert = createSequences();
		createSequenceAction(sequenceListToInsert);
		createLead();
		Contact contact = createContact(null);
		Opportunity opp = createOpportunity();
		Contact opportunityContact = createContact(opp.Id);
		createOpportunityContactRole(opp.Id, opportunityContact.id);
		
	}
	
	private static List<Cadence__c> createSequences() {
		List<Criterion> entryCriterionList = new List<Criterion>();
		entryCriterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead'));
		String entryCriterionJson  = TestDataFactory.createCadenceJSON(entryCriterionList, CadenceConstants.CONDITION_AND, '');
		
		List<Criterion> exitCriterionList = new List<Criterion>();
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		String exitCriterionJson = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 
		
        List<Cadence__c> sequenceListToInsert = new List<Cadence__c>();
		Cadence__c leadSeqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		leadSeqRec.Name = 'Cadence New';
		leadSeqRec.Entrance_Criteria__c = entryCriterionJson;
		leadSeqRec.Exit_Criteria__c=  exitCriterionJson;
		leadSeqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		leadSeqRec.matching_priority__c = 'P1';
		leadSeqRec.Participent_Activation__c = 'Automatic';
        sequenceListToInsert.add(leadSeqRec);
        
        entryCriterionList = new List<Criterion>();
        entryCriterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Contact'));
		entryCriterionJson  = TestDataFactory.createCadenceJSON(entryCriterionList, CadenceConstants.CONDITION_AND, '');
        Cadence__c contactSeqRec = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		contactSeqRec.Name = 'Cadence New';
		contactSeqRec.Entrance_Criteria__c = entryCriterionJson;
		contactSeqRec.Exit_Criteria__c=  exitCriterionJson;
		contactSeqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		contactSeqRec.matching_priority__c = 'P1';
		contactSeqRec.Participent_Activation__c = 'Automatic';
        sequenceListToInsert.add(contactSeqRec);
        
        
        exitCriterionList = new List<Criterion>();
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'Name', 'STRING', 'equals', 'Exit'));
		exitCriterionJson = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, '');
        entryCriterionList = new List<Criterion>();
        entryCriterionList.add(TestDataFactory.createCriterion(1, 'Name', 'STRING', 'equals', 'Test Opportunity'));
		entryCriterionJson  = TestDataFactory.createCadenceJSON(entryCriterionList, CadenceConstants.CONDITION_AND, '');
        Cadence__c opportunitySeqRec = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		opportunitySeqRec.Name = 'Cadence New';
		opportunitySeqRec.Entrance_Criteria__c = entryCriterionJson;
		opportunitySeqRec.Exit_Criteria__c=  exitCriterionJson;
		opportunitySeqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		opportunitySeqRec.matching_priority__c = 'P1';
		opportunitySeqRec.Participent_Activation__c = 'Automatic';
        sequenceListToInsert.add(opportunitySeqRec);
        
		insert sequenceListToInsert;
		return sequenceListToInsert;
	}
	
	private static void createSequenceAction(List<Cadence__c> sequenceList) {
		Action__c action = createAction();
		
        List<CadenceAction__C> seqActionListToInsert = new List<CadenceAction__C>();
        for(Cadence__c sequence : sequenceList) {
            CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(sequence.id, action.Id);
            seqActionRec.Day__c = 2;
            seqActionRec.Hour__c = 2;
            seqActionRec.Trigger_Type__c = 'Time Based';
            seqActionListToInsert.add(seqActionRec);
        }
		insert seqActionListToInsert;
	}
	 
	private static Action__c createAction() {
		Action__c action = TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action.Activation_Type__c = 'Automatic';
		insert action;
		return action;
	}
	
	private static void createLead() {
		Lead leadRec = TestDataFactory.createLead(); 
		leadRec.Email = 'Test@gmail.com';
		insert leadRec;
	}
	
	private static Contact createContact(Id opportunityId) {
		Contact cont = new Contact();
		if(opportunityId == null) {
			cont.LastName = 'Test Contact';
			cont.Email = 'Test1@gmail.com';
			insert cont;
		} else {
			cont.LastName = 'Test Opportunity Contact';
			cont.Email = 'Test2@gmail.com';
			cont.Opportunity_Id__c = opportunityId;
			insert cont;
		}
		return cont;
	}
	
	private static Opportunity createOpportunity() {
		Opportunity opp = TestDataFactory.createOpp('Test Opportunity'); 
		insert opp;
		return opp;
	}
	
	private static void createOpportunityContactRole(Id opportunityId, Id contactId) {
		OpportunityContactRole oppRole = TestDataFactory.createOpportunityRole(opportunityId, contactId); 
		insert oppRole;
	}
	
    static testMethod void getParticipantListForContactToCreateParticipantActionsTest() {
    	Contacts.fireTrigger = false;
    	Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
    	List<Contact> participantList = [SELECT Id, Cadence_Id__c FROM Contact];
    	List<Cadence__c> seqRecList = [SELECT ID, Status__c FROM Cadence__c];
    	sequenceIdToSequenceMap.put(seqRecList[0].Id,seqRecList[0]);
		
		Test.startTest();
    	List<Contact> contactList = SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantList, sequenceIdToSequenceMap, CadenceConstants.CONTACT_OBJECT_NAME);
    	Test.stopTest();
    	system.assertEquals(contactList.size(), 0);
    }
    
    static testMethod void getParticipantListForLeadToCreateParticipantActionsTest() {
    	Leads.fireTrigger = false;
    	Map<Id, Cadence__c> sequenceIdToSequenceMap = new Map<Id, Cadence__c>();
    	List<Lead> participantList = [SELECT Id, Cadence_Id__c FROM Lead];
    	List<Cadence__c> seqRecList = [SELECT ID, Status__c FROM Cadence__c];
    	sequenceIdToSequenceMap.put(seqRecList[0].Id,seqRecList[0]);
		
		Test.startTest();
    	List<Lead> leadList = SequenceEngineHelper.getParticipantListToCreateParticipantActions(participantList, sequenceIdToSequenceMap, CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest();
    	system.assertEquals(leadList.size(), 1);
    }
    
    static testMethod void deleteUnPerformedParticipantActionsTest() {
		List<Lead> leadList = [SELECT Id, Cadence_Id__c FROM Lead];
		Test.startTest();
    	SequenceEngineHelper.deleteUnPerformedParticipantActions(leadList);
    	Test.stopTest();
    }
    
    public static String sessionId;
	public static String accountId;
	public static String userId;
	static{
		Account acc = TestDataFactory.createAccount();
		insert acc;
		System.assertNotEquals(null, acc);
		accountId = acc.id;
		sessionId = userinfo.getSessionId();
		userId = userinfo.getUserId();
	}
	
	static testMethod void SendNativeEmailTest(){
		test.startTest();
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts(true);
		Test.setMock(HttpCalloutMock.class, new SendNativeMassEmailMockCallout());

		List<NativeEmailMessage> nativeEmailMessageList = new List<NativeEmailMessage>();
		NativeEmailMessage nativeEmailMessage = new NativeEmailMessage();
		nativeEmailMessage.ActionId = accountId;
		nativeEmailMessage.MailTo = 'test@gmail.com';
		nativeEmailMessage.Body = 'body mail 1';
		nativeEmailMessage.UserId = userId;
		nativeEmailMessageList.add(nativeEmailMessage);
		SequenceEngineHelper.SendNativeEmail(nativeEmailMessageList);
		test.stopTest();
		//system.assertEquals(1, sendNativeMassEmailList.size());
	}
	
	static testMethod void sendNativeEmailTroughTriggerTest() {
		test.startTest();
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts(true);
		Test.setMock(HttpCalloutMock.class, new SendNativeMassEmailMockCallout());

		List<NativeEmailMessage> nativeEmailMessageList = new List<NativeEmailMessage>();
		NativeEmailMessage nativeEmailMessage = new NativeEmailMessage();
		nativeEmailMessage.ActionId = accountId;
		nativeEmailMessage.MailTo = 'test@gmail.com';
		nativeEmailMessage.Body = 'body mail 1';
		nativeEmailMessage.UserId = userId;
		nativeEmailMessageList.add(nativeEmailMessage);
		SequenceEngineHelper.sendNativeEmailTroughTrigger(JSON.serialize(nativeEmailMessageList));
		test.stopTest();
	}
}