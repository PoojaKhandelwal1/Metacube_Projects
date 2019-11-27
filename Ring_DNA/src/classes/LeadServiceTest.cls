@isTest
public class LeadServiceTest {
	
	public static String cadJsonobj;
	public static CadenceAction__c cadenceActionobj;
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;
    
    @testSetup
	static void testSetupData() {
		List<Cadence__c> sequenceListToInsert = createSequence();
		createSequenceAction(sequenceListToInsert);
		createLead();
	}
	
	private static List<Cadence__c> createSequence() {
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
		leadRec.Email = 'Test12@gmail.com';
		insert leadRec;
	}
	
    static testMethod void getSequenceHistoryTest() {
    	List<Cadence__c> seqRecList = [SELECT ID FROM Cadence__c];
    	List<Id> sequenceIdList = new List<Id>{seqRecList[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
    	
    	Test.startTest();
    	List<Lead> leadList = [SELECT Id FROM Lead];
    	leadList[0].FirstName = 'Exit';
    	update leadList[0];
    	
    	Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = new LeadService().getSequenceHistory();
    	Test.stopTest();
    	
    	System.assertEquals(true, participantIdToSequenceIdHistorySetMap.get(leadList[0].Id).contains(seqRecList[0].Id));
    }
    
    static testMethod void checkExitCriteriaTest() {
		Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
    	
    	Leads.fireTrigger = false;
    	String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.LEAD_OBJECT_NAME);
    	List<Lead> leadList = Database.query(query);
    	leadList[0].FirstName = 'Exit';
    	update leadList[0];
    	Leads.fireTrigger = true;
    	
    	Test.startTest();
    	SequenceEngineWrapper sequenceEngineWrapper = new LeadService().checkExitCriteria(CadenceConstants.LEAD_OBJECT_NAME, leadList, null, seqIdToSequneceRecMap);
    	Test.stopTest();
    	
    	System.assertEquals(1, sequenceEngineWrapper.participantList.size());
    }
    
    static testMethod void unAssociateParticipantsTest() {
    	Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	CadenceController.activateSequences(sequenceIdList);
    	
    	Leads.fireTrigger = false;
    	String query = PerformCadenceActionBatchHelper.formQuery(CadenceConstants.LEAD_OBJECT_NAME);
    	List<Lead> leadList = Database.query(query);
    	leadList[0].FirstName = 'Exit';
    	update leadList[0];
    	Leads.fireTrigger = true;
    	
    	SequenceEngineWrapper sequenceEngineWrapper = new LeadService().checkExitCriteria(CadenceConstants.LEAD_OBJECT_NAME, leadList, null, seqIdToSequneceRecMap);
    	
    	Test.startTest();
    	List<SObject> unAssociatedParticipantList  = new LeadService().unAssociateParticipants(sequenceEngineWrapper, CadenceConstants.LEAD_OBJECT_NAME);
    	Test.stopTest(); 
    	
    	System.assertEquals(1, unAssociatedParticipantList.size());
    }
    
    static testMethod void checkEntryCriteriaTest() {
    	Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	activateSequences(seqIdToSequneceRecMap.values());
    	
    	List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.LEAD_OBJECT_NAME);
        
        String query = 'Select ';
        
        Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
        List<Schema.SObjectField> contactFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Lead');
        
        query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
        query = query.subString(0, query.length() - 1);
        query += ' From Lead' ;
        
    	List<Lead> leadList = Database.query(query);
    	
    	Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = new LeadService().getSequenceHistory();
    	
    	Test.startTest();
    	Map<Id, List<SObject>> sequenceIdToParticipationListMap = new LeadService().checkEntryCriteria(leadList, null, seqIdToSequneceRecMap, participantIdToSequenceIdHistorySetMap);
    	Test.stopTest();
    	
    	System.assertEquals(1, sequenceIdToParticipationListMap.get(seqIdToSequneceRecMap.values()[0].Id).size());
    }
    
    static testMethod void associateParticipantTest() {
    	Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	activateSequences(seqIdToSequneceRecMap.values());
    	
    	List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.LEAD_OBJECT_NAME);
        
        String query = 'Select ';
        
        Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
        List<Schema.SObjectField> contactFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Lead');
        
        query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
        query = query.subString(0, query.length() - 1);
        query += ' From Lead' ;
        
    	List<Lead> leadList = Database.query(query);
    	
    	Map<Id, Set<Id>> participantIdToSequenceIdHistorySetMap = new LeadService().getSequenceHistory();
    	
    	Map<Id, List<SObject>> sequenceIdToParticipationListMap = new LeadService().checkEntryCriteria(leadList, null, seqIdToSequneceRecMap, participantIdToSequenceIdHistorySetMap);
    	
    	Test.startTest();
    	List<SObject> leadList1 = new LeadService().associateParticipant(sequenceIdToParticipationListMap);
    	Test.stopTest();
    	
    	System.assertEquals(seqIdToSequneceRecMap.values()[0].Id, leadList1[0].get('Cadence_Id__c'));
    }
    
    static testMethod void createParticipantActionsTest() {
    	Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	CadenceController.activateSequences(sequenceIdList); 
    	
    	List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.LEAD_OBJECT_NAME);
        
        String query = 'Select ';
        
        Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
        List<Schema.SObjectField> contactFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Lead');
        
        query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
        query = query.subString(0, query.length() - 1);
        query += ' From Lead' ;
        
    	List<Lead> leadList = Database.query(query);
    	
    	Test.startTest();
    	new LeadService().createParticipantActions(leadList, seqIdToSequneceRecMap);
    	Test.stopTest();
    	
    	List<Sequence_Action__c> participantActionList = [SELECT Id, Lead_Id__c FROM Sequence_Action__c WHERE 
                                                          CadenceAction_ID__r.Cadence_Id__r.Record_Type__c = 'Lead'];
    	system.assertEquals(true,  (participantActionList[0].Lead_Id__c == leadList[0].Id));
    }
    
    static testMethod void performParticipantActionsTest() {
		Map<Id, Cadence__c> seqIdToSequneceRecMap = new Map<Id, Cadence__c>([SELECT Id, Name, Entrance_Criteria__c, Entrance_Criteria_PE__c, Exit_Criteria__c, Exit_Criteria_PE__c,
                                       Participent_Activation__c, Record_Type__c, Status__c, matching_priority__c, CreatedDate,LastModifiedDate,
                                       (SELECT Id, Name, Action_Criterion__c, Action_Criteria_PE__c, Action_Id__c,
                                        Cadence_Id__c, Day__c, Hour__c, Trigger_Type__c, Fields_To_Update_Action__c, Action_Id__r.Activation_Type__c, 
                                        Action_Id__r.Task_Description__c, Action_Id__r.Template_Id__c, Action_Id__r.Type__c  
                                        FROM CadenceActions__r order by Index__c) 
                                       FROM Cadence__c]);

    	List<Id> sequenceIdList = new List<Id>{seqIdToSequneceRecMap.values()[0].Id};
    	CadenceController.activateSequences(sequenceIdList); 
    	
    	List<String> participantTypeToParentObjectList = PerformCadenceActionBatchHelper.getParticipantTypeToParentObjectListMap().get(CadenceConstants.LEAD_OBJECT_NAME);
        
        String query = 'Select ';
        
        Map <String, Schema.SObjectType> globalDescribedSchemaMap = Schema.getGlobalDescribe();
        List<Schema.SObjectField> contactFieldList = PerformCadenceActionBatchHelper.getFieldListFromGlobalDescribedSchemaMap(globalDescribedSchemaMap, 'Lead');
        
        query = PerformCadenceActionBatchHelper.addFieldsInQuery(query, globalDescribedSchemaMap, contactFieldList, participantTypeToParentObjectList);
        query = query.subString(0, query.length() - 1);
        query += ' From Lead' ;
        
    	List<Lead> leadList = Database.query(query);
    	
    	new LeadService().createParticipantActions(leadList, seqIdToSequneceRecMap);
		
		Map<Id, List<Sequence_Action__c>> participantIdToUnperformedParticipantActionsMap = SequenceEngineHelper.getUnPerformedParticipantActions(leadList, 'Lead');
		
		Test.startTest();
    	Map<Id, List<Sequence_Action__c>> participantIdToPerformedParticipantActionsMap = new LeadService().performParticipantActions(leadList, participantIdToUnperformedParticipantActionsMap, seqIdToSequneceRecMap, 'Lead');
    	Test.stopTest();
    	
    	system.assertEquals(1, participantIdToPerformedParticipantActionsMap.get(leadList[0].Id).size());
    }
    
    private static void activateSequences(List<Cadence__c> seqRecList) {
		for(Cadence__c sequence : seqRecList) {
			sequence.Status__c = true;
		}
		update seqRecList;
	}
}