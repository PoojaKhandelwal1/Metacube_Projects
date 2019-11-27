@isTest
public class ActionListCtrlTest {

	public static Lead testLead;
	public static Contact cont;
	public static Cadence__c cad1;
	public static Action__c action1;
	public static CadenceAction__c cadAction;
	public static Account act;

	//Constants 
	Public static Final String ACTION_TYPE_CALL = 'Call';
	Public static Final String RECORD_TYPE_CONTACT = 'Contact';
	Public static Final String RECORD_TYPE_LEAD = 'Lead';

	static {
		act = TestDataFactory.createAccount();
		insert act;
		action1 = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert action1;
		cad1 = TestDataFactory.createCadence(RECORD_TYPE_LEAD);
		insert cad1;
		cadAction = TestDataFactory.createCadenceAction(cad1.Id, action1.Id);
		insert cadAction;

	}

	@isTest
	static void fetchCadenceActionsTest() {

		Lead testLead1 = TestDataFactory.createLead(cad1.Id);
		// insert testLead1; 
		Cadence__c cad2 = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert cad2;
		CadenceAction__C cadAction1 = TestDataFactory.createCadenceAction(cad2.Id, action1.Id);
		insert cadAction1;
		Contact cont1 = TestDataFactory.createContact(act.Id, cad2.Id);
		//  insert cont1; 
		Action__c action2 = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert action2;

		List<CadenceActionListController.ActionWrapper> actionWrarpper;
		Test.startTest();

		actionWrarpper = CadenceActionListController.fetchCadenceActions();

		Test.stopTest();    

		System.assertEquals(2, actionWrarpper.size());
	}

	@isTest
	static void deleteActionsTest() {
		Test.startTest();
		CadenceActionListController.deleteActions(new List<Id>{action1.Id});
		Test.stopTest();
		List<Action__c> actionList = [Select Id from Action__c where Id = : action1.Id];
		//Action in not deleted because it is used in cadence
		System.assertEquals(0, actionList.size());
	}

	@isTest
	static void deleteCadence() {
		Cadence__c cad2 = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		insert cad2;
		Test.startTest();
		CadenceActionListController.deleteCadences(new List<Id>{cad2.Id});
		Test.stopTest();
		List<Cadence__c> cadList = [Select Id from Cadence__c where Id = : cad2.Id];
		System.assertEquals(0, cadList.size());
	}

	@isTest
	static void getCadenceDataTest(){
		Cadence__c cad4 = TestDataFactory.createCadence(RECORD_TYPE_CONTACT);
		cad4.Name='contact';
		cad4.Status__c=true;
		cad4.Record_Type__c='Contact';
		cad4.Participent_Activation__c='Automatic';
		insert cad4; 
		Test.startTest();
		CadenceActionListController.getCadenceData();
		Test.stopTest();
	}

}