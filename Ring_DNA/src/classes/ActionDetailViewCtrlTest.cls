@isTest
public class ActionDetailViewCtrlTest {

	public static Lead testLead;
	public static Contact cont;
	public static Cadence__c cad1;
	public static Cadence__c contactCad;
	public static Action__c action1;
	public static CadenceAction__c cadAction;
	public static Account act;

	
	//Constants 
	Public static Final String ACTION_TYPE_CALL = 'Call';
	Public static Final String RECORD_TYPE_CONTACT = 'Contact';
	Public static Final String RECORD_TYPE_LEAD = 'Lead';

	static {
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
			
		act = TestDataFactory.createAccount();
		insert act;
		action1 = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert action1;
		cad1 = TestDataFactory.createCadence(RECORD_TYPE_LEAD);
		insert cad1;
		cadAction = TestDataFactory.createCadenceAction(cad1.Id, action1.Id);
		insert cadAction;
		testLead = TestDataFactory.createLead(cad1.Id);
		insert testLead;
		contactCad = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert contactCad; 
	}

	@isTest
	static void fetchCadenceActionsTest() {
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;	
	
		Lead testLead1 = TestDataFactory.createLead(cad1.Id);
		insert testLead1;
		Cadence__c cad2 = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert cad2;
		CadenceAction__C cadAction1 = TestDataFactory.createCadenceAction(cad2.Id, action1.Id);
		insert cadAction1;
		Contact cont1 = TestDataFactory.createContact(act.Id, cad2.Id);
		insert cont1; 
		Action__c action2 = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert action2;

		ActionDetailViewCtrl.ActionDetailWrapper actionWrapper;
		Test.startTest();

		actionWrapper = ActionDetailViewCtrl.getActionData(action1.Id);
		Test.stopTest();    

		System.assertEquals(action1.Id, actionWrapper.action.Id);
	}

	@isTest
	static void deleteActionsTest() {
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;	
	
		Test.startTest();
		CadenceActionListController.deleteActions(new List<Id>{action1.Id});
		Test.stopTest();
		List<Action__c> actionList = [Select Id from Action__c where Id = : action1.Id];
		System.assertEquals(0, actionList.size());
	}


	@isTest
	static void getCadenceParticipantsDataTest() {
		Contacts.fireTrigger = false;
		
		Leads.fireTrigger = false;	
		Lead testLead1 = TestDataFactory.createLead(cad1.Id);
		testLead1.EntranceCriteria_Matched_Date__c = system.now();
		testLead1.isActivated__c = true;
		insert testLead1;
		Contact cont1 = TestDataFactory.createContact(act.Id, contactCad.Id);
		cont1.isActivated__c = false;
		cont1.EntranceCriteria_Matched_Date__c = system.now();
		insert cont1; 

		List<ActionDetailViewCtrl.ParticipantWrapper> leadWrapper = new List<ActionDetailViewCtrl.ParticipantWrapper>();
		List<ActionDetailViewCtrl.ParticipantWrapper> contactWrapper = new List<ActionDetailViewCtrl.ParticipantWrapper>();

		Test.startTest();

		leadWrapper = ActionDetailViewCtrl.getCadenceParticipantsData(cad1.Id);
		contactWrapper = ActionDetailViewCtrl.getCadenceParticipantsData(contactCad.Id);
		ActionDetailViewCtrl.togglePartActivation(JSON.serialize(leadWrapper));
		ActionDetailViewCtrl.togglePartActivation(JSON.serialize(contactWrapper));
		Test.stopTest();

		testLead1 = [Select Id, isActivated__c from Lead where Id = :testLead1.Id];
		cont1 = [Select Id, isActivated__c from Contact where Id = :cont1.Id];

		System.assertEquals(2, leadWrapper.size());
		System.assertEquals(1, contactWrapper.size());
		System.assertEquals(false, testLead1.isActivated__c);
		System.assertEquals(true, cont1.isActivated__c);
	}
}