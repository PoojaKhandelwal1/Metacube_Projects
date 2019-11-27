@isTest
public class SequenceEngineServiceTest {
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	
	/**public static String cadJsonobj;
	public static CadenceAction__c cadenceActionobj;
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;*/
	
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
		leadSeqRec.Status__c = false;
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
		contactSeqRec.Status__c = false;
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
		opportunitySeqRec.Status__c = false;
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
	
	static testMethod void activateSequencesTest1() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	
    	Test.startTest();
    	CadenceController.activateSequences(sequenceIdList);
    	Test.stopTest();
    	
    	List<Lead> leadList = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList[0].Cadence_Id__c != null));
    }
    
    static testMethod void activateSequencesTest2() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	seqRecList[0].Participent_Activation__c = 'Manual';
    	update seqRecList[0];
    	
    	Test.startTest();
    	CadenceController.activateSequences(sequenceIdList);
    	Test.stopTest();
    	
    	List<Lead> leadList = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList[0].Cadence_Id__c != null));
    }
    static testMethod void activateSequencesTest3() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[2].Id};
    	
    	Test.startTest();
    	CadenceController.activateSequences(sequenceIdList);
    	Test.stopTest();
    	
    	List<Opportunity> opportunityList = [SELECT Id, Cadence_Id__c FROM Opportunity];
    	system.assertEquals(true,  (opportunityList[0].Cadence_Id__c != null));
    }
    
    static testMethod void associateParticipantsBatchTest1() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	activateSequences(seqRecList);
    	
    	Test.startTest();
    	AssociateParticipantsBatch associateParticipantsBatch = new AssociateParticipantsBatch(seqRecList[0].Id); 
		Database.executeBatch(associateParticipantsBatch, 200);
    	Test.stopTest();
    	
    	List<Lead> leadList = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList[0].Cadence_Id__c != null));
    }
    
    static testMethod void associateParticipantsBatchTest2() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	seqRecList[0].Participent_Activation__c = 'Manual';
    	update seqRecList[0];
    	activateSequences(seqRecList);
    	
    	Test.startTest();
    	AssociateParticipantsBatch associateParticipantsBatch = new AssociateParticipantsBatch(seqRecList[0].Id); 
		Database.executeBatch(associateParticipantsBatch, 200);
    	Test.stopTest();
    	
    	List<Lead> leadList = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList[0].Cadence_Id__c != null));
    }
    
    static testMethod void sequenceTriggerToassociateParticipantsTest1() {
    	List<Lead> leadList = [SELECT Id FROM Lead];
    	leadList[0].LastName = 'Test Lead1';
    	update leadList[0];
    	
    	List<Cadence__c> seqRecList = [SELECT ID, Status__c FROM Cadence__c];
    	activateSequences(seqRecList);
    	
    	Test.startTest();
    	List<Criterion> entryCriterionList = new List<Criterion>();
		entryCriterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead1'));
		String entryCriterionJson  = TestDataFactory.createCadenceJSON(entryCriterionList, CadenceConstants.CONDITION_AND, '');
    	seqRecList[0].Entrance_Criteria__c = entryCriterionJson;
    	update seqRecList[0];
    	Test.stopTest();
    	
    	List<Lead> leadList1 = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList1[0].Cadence_Id__c != null));
    }
    
    //Need To Move in SequenceEngineTest class
    static testMethod void performLeadActionBatchTest1() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c WHERE Record_Type__c = 'Lead'];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
		
    	Test.startTest();
    	PerformLeadActionBatch led = new PerformLeadActionBatch();
		Database.executeBatch(led,100);
    	Test.stopTest();
    	
    	List<Lead> leadList = [SELECT Id FROM Lead];
    	List<Sequence_Action__c> participantActionList = [SELECT Id, Lead_Id__c FROM Sequence_Action__c WHERE 
                                                          CadenceAction_ID__r.Cadence_Id__r.Record_Type__c = 'Lead'];
    	system.assertEquals(true,  (participantActionList[0].Lead_Id__c == leadList[0].Id));
    }
    
    //Need To Move in SequenceEngineTest class
    static testMethod void performLeadActionBatchTest2() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c WHERE Record_Type__c = 'Lead'];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
		
    	Test.startTest();
    	PerformLeadActionBatch led = new PerformLeadActionBatch();
		Database.executeBatch(led,100);
		
		List<Lead> leadList = [SELECT Id FROM Lead];
		leadList[0].FirstName = 'Exit';
		update leadList[0];
		
		//PerformLeadActionBatch led1 = new PerformLeadActionBatch();
		//Database.executeBatch(led1,100);
    	Test.stopTest();
    	
    	List<Lead> leadList1 = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList1[0].Cadence_Id__c == null));
    }
    //Need To Move in SequenceEngineTest class
    static testMethod void performContactActionBatchTest1() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c WHERE Record_Type__c = 'Contact'];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
		
    	Test.startTest();
    	PerformContactActionBatch con = new PerformContactActionBatch(); 
		Database.executeBatch(con,100);
    	Test.stopTest();
    	
    	List<Contact> contactList = [SELECT Id FROM Contact WHERE Opportunity_Id__c = null];
    	List<Sequence_Action__c> participantActionList = [SELECT Id, Contact_Id__c FROM Sequence_Action__c 
                                                          WHERE CadenceAction_ID__r.Cadence_Id__r.Record_Type__c = 'Contact'];
    	system.assertEquals(true,  (participantActionList[0].Contact_Id__c == contactList[0].Id));
    }
    
    //Need To Move in SequenceEngineTest class
    static testMethod void performContactActionBatchTest2() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c WHERE Record_Type__c = 'Contact'];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
		
    	Test.startTest();
    	PerformContactActionBatch con = new PerformContactActionBatch(); 
		Database.executeBatch(con,100);
		
		List<Contact> contactList = [SELECT Id FROM Contact WHERE Opportunity_Id__c = null];
		contactList[0].FirstName = 'Exit';
		update contactList[0];
		
		//PerformContactActionBatch con1 = new PerformContactActionBatch(); 
		//Database.executeBatch(con1,100);
    	Test.stopTest();
    	
    	List<Contact> contactList1 = [SELECT Id, Cadence_Id__c FROM Contact WHERE Opportunity_Id__c = null];
    	system.assertEquals(true,  (contactList1[0].Cadence_Id__c == null));
    }
    
    //Need To Move in SequenceEngineTest class
    static testMethod void performOpportunityActionBatchTest1() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c WHERE Record_Type__c = 'Opportunity'];
    	activateSequences(seqRecList);
    	
    	List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
    	opportunityList[0].Cadence_Id__c = seqRecList[0].Id;
    	update opportunityList[0];
    	
    	List<Contact> contactList = [SELECT Id FROM Contact WHERE Opportunity_Id__c != null];
    	contactList[0].Cadence_Id__c = seqRecList[0].Id;
		update contactList[0];
		
    	Test.startTest();
    	PerformOpportunityActionBatch opportunity = new PerformOpportunityActionBatch();
		Database.executeBatch(opportunity,100);
    	Test.stopTest();
    	
    	List<Contact> contactList1 = [SELECT Id FROM Contact WHERE Opportunity_Id__c != null];
    	List<Sequence_Action__c> participantActionList = [SELECT Id, Contact_Id__c FROM Sequence_Action__c 
                                                          WHERE CadenceAction_ID__r.Cadence_Id__r.Record_Type__c = 'Opportunity'];
    	system.assertEquals(true,  (participantActionList[0].Contact_Id__c == contactList1[0].Id));
    }
    
    //Need To Move in SequenceEngineTest class
    static testMethod void performOpportunityActionBatchTest2() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c WHERE Record_Type__c = 'Opportunity'];
    	activateSequences(seqRecList);
		
		List<Opportunity> opportunityList = [SELECT Id FROM Opportunity];
    	opportunityList[0].Cadence_Id__c = seqRecList[0].Id;
    	update opportunityList[0];
    	
		List<Contact> contactList = [SELECT Id FROM Contact WHERE Opportunity_Id__c != null];
    	contactList[0].Cadence_Id__c = seqRecList[0].Id;
		update contactList[0];
		
    	Test.startTest();
    	PerformOpportunityActionBatch opportunity = new PerformOpportunityActionBatch();
		Database.executeBatch(opportunity,100);
		
		List<Opportunity> opportunityList1 = [SELECT Id FROM Opportunity];
		opportunityList1[0].Name = 'Exit';
		update opportunityList1[0];
		
		//PerformOpportunityActionBatch opportunity1 = new PerformOpportunityActionBatch();
		//Database.executeBatch(opportunity1,100);
    	Test.stopTest();
    	
    	List<Contact> contactList1 = [SELECT Id, Cadence_Id__c FROM Contact WHERE Opportunity_Id__c != null];
    	system.assertEquals(false,  (contactList1[0].Cadence_Id__c == null));
    }
    
    
    private static void activateSequences(List<Cadence__c> seqRecList) {
		for(Cadence__c sequence : seqRecList) {
			sequence.Status__c = true;
		}
		update seqRecList;
	}
	
    /**static testMethod void activateSequencesTest2() {
    	
    	List<SObject> participantList = new List<SObject>();
		List<Criterion> criterionList = new List<Criterion>();
		List<Criterion> exitCriterionList = new List<Criterion>();
		List<Id> seqIdList = new List<Id>(); 
		
		criterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead'));
		
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		
		String exitCriterion = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		 
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec.Name = 'Cadence New';
		seqRec.Entrance_Criteria__c = cadJsonobj;
		seqRec.Exit_Criteria__c=  exitCriterion;
		seqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		seqRec.matching_priority__c='P1';
		seqRec.Participent_Activation__c='Automatic';
		insert seqRec;
		seqIdList.add(seqRec.Id);
		
		
		action1= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action2= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 
		CadenceAction__C seqActionRec=TestDataFactory.createCadenceAction(seqIdList[0], action1.Id);
		seqActionRec.Day__c= 2;
		seqActionRec.Hour__c=2;
		seqActionRec.Trigger_Type__c = 'Time Based';
		insert seqActionRec;
		
		Id cuId = UserInfo.getUserID();
		
		Test.startTest();
		List<Lead> leadList = new List<Lead>();
		
		for(Integer i = 0; i < 5000; i++) {
			Lead leadRec = TestDataFactory.createLead(); 
			leadList.add(leadRec);
		}
		insert leadList;
		activateSequencesTest2Helper();
		CadenceController.activateSequences(seqIdList);
    	Test.stopTest();
    	List<Lead> leadListUpdated = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadListUpdated[0].Cadence_Id__c != null));
    }
    
    @future
    public static void activateSequencesTest2Helper() {
    	List<Lead> leadList1 = new List<Lead>();
    	for(Integer i = 0; i < 5000; i++) {
			Lead leadRec = TestDataFactory.createLead(); 
			leadList1.add(leadRec);  
		}
		insert leadList1;
    }
    */
    /**static testMethod void activateSequencesTest1() {
    	
    	List<SObject> participantList = new List<SObject>();
		List<Criterion> criterionList = new List<Criterion>();
		List<Criterion> exitCriterionList = new List<Criterion>();
		List<Id> seqIdList = new List<Id>(); 
		
		criterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead'));
		
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		
		String exitCriterion = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		 
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec.Name = 'Cadence New';
		seqRec.Entrance_Criteria__c = cadJsonobj;
		seqRec.Exit_Criteria__c=  exitCriterion;
		seqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		seqRec.matching_priority__c='P1';
		seqRec.Participent_Activation__c='Automatic';
		insert seqRec;
		seqIdList.add(seqRec.Id);
		
		
		action1= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action2= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 
		CadenceAction__C seqActionRec=TestDataFactory.createCadenceAction(seqIdList[0], action1.Id);
		seqActionRec.Day__c= 2;
		seqActionRec.Hour__c=2;
		seqActionRec.Trigger_Type__c = 'Time Based';
		insert seqActionRec;
		
		Id cuId = UserInfo.getUserID();
		
		Lead leadRec = TestDataFactory.createLead(); 
		leadRec.Email = 'Test@gmail.com';
		insert leadRec;
		
		Test.startTest();
    	CadenceController.activateSequences(seqIdList);
    	Test.stopTest();
    	List<Lead> leadList = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadList[0].Cadence_Id__c != null));
    }
    
    static testMethod void activateSequencesTest2() {
    	
    	List<SObject> participantList = new List<SObject>();
		List<Criterion> criterionList = new List<Criterion>();
		List<Criterion> exitCriterionList = new List<Criterion>();
		List<Id> seqIdList = new List<Id>(); 
		
		criterionList.add(TestDataFactory.createCriterion(1, 'LastName', 'STRING', 'equals', 'Test Lead'));
		
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		
		String exitCriterion = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		 
		Cadence__c seqRec = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		seqRec.Name = 'Cadence New';
		seqRec.Entrance_Criteria__c = cadJsonobj;
		seqRec.Exit_Criteria__c=  exitCriterion;
		seqRec.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		seqRec.matching_priority__c='P1';
		seqRec.Participent_Activation__c='Automatic';
		insert seqRec;
		seqIdList.add(seqRec.Id);
		
		
		action1= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_EMAIL);
		action2= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(CadenceConstants.ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 
		CadenceAction__C seqActionRec=TestDataFactory.createCadenceAction(seqIdList[0], action1.Id);
		seqActionRec.Day__c= 2;
		seqActionRec.Hour__c=2;
		seqActionRec.Trigger_Type__c = 'Time Based';
		insert seqActionRec;
		
		Id cuId = UserInfo.getUserID();
		
		Test.startTest();
		List<Lead> leadList = new List<Lead>();
		
		for(Integer i = 0; i < 5000; i++) {
			Lead leadRec = TestDataFactory.createLead(); 
			leadList.add(leadRec);
		}
		insert leadList;
		activateSequencesTest2Helper();
		CadenceController.activateSequences(seqIdList);
    	Test.stopTest();
    	List<Lead> leadListUpdated = [SELECT Id, Cadence_Id__c FROM Lead];
    	system.assertEquals(true,  (leadListUpdated[0].Cadence_Id__c != null));
    }
    
    @future
    public static void activateSequencesTest2Helper() {
    	List<Lead> leadList1 = new List<Lead>();
    	for(Integer i = 0; i < 5000; i++) {
			Lead leadRec = TestDataFactory.createLead(); 
			leadList1.add(leadRec);  
		}
		insert leadList1;
    }*/
}