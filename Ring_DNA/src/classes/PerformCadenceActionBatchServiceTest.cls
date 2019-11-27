@isTest
public class PerformCadenceActionBatchServiceTest {
	//Constants 
	Public static Final String RECORD_TYPE_CONTACT = 'Contact';
	Public static Final String ACTION_TYPE_CALL = 'Call';
    
    static testMethod void runSequenceEngineTest () {
    	Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
    	Account accountRec = TestDataFactory.createAccount();
		insert accountRec;
		Action__c actionRec = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert actionRec;
		List<SObject> participantList = new List<SObject>();
		Cadence__c seqRec = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert seqRec;
		CadenceAction__C seqActionRec = TestDataFactory.createCadenceAction(seqRec.Id, actionRec.Id);
		insert seqActionRec;
		Contact contRec = TestDataFactory.createContact(accountRec.Id, seqRec.Id);
		insert contRec; 
		participantList.add(contRec);
    	PerformCadenceActionBatchService.runSequenceEngine(RECORD_TYPE_CONTACT, participantList, null);
    }
}