@isTest
public class CadenceSelectorTest {
	public static Action__c action1;
	public static Action__c action2;
	public static Cadence__c cadence1;
	public static CadenceAction__c cadenceAction1;
	public static Sequence_Action__c actionOnParticipants;   
	Public static Final String ACTION_TYPE_Email = 'Email';
	Public static Final String ACTION_TYPE_Task = 'Task';

	@isTest
	static void getparticipantsActionsTest(){
		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		insert c1;

		Lead l1= new Lead();
		l1.Company='COM';
		l1.FirstName='fname';
		l1.LastName='lname';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Title = 'Test';
		insert l1;

		action1= TestDataFactory.createAction(ACTION_TYPE_Email);
		insert action1;

		action1= TestDataFactory.createAction(ACTION_TYPE_Task);
		insert action1;

		cadence1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadence1.Participent_Activation__c='Automatic';
		cadence1.Status__c=true;
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c='Lead';
		insert cadence1;        
		cadenceAction1=TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceAction1.Name='democadenceaction';
		cadenceAction1.Trigger_Type__c= 'Immediate';       
		insert cadenceAction1;

		actionOnParticipants = new Sequence_Action__c();
		actionOnParticipants.Name= 'demoname';
		actionOnParticipants.Lead_Id__c= l1.Id;
		actionOnParticipants.CadenceAction_ID__c=cadenceAction1.Id;
		actionOnParticipants.isActionPerformed__c=True;
		insert actionOnParticipants;

		Test.startTest();
		CadenceSelector.getParticipantActions();
		CadenceSelector.getCadenceById(cadence1.Id);
		CadenceSelector.getSobjectListByIds('Contact',new list<Id>{c1.Id});
		CadenceSelector.getParticipantActionsByCadenceActionsIds(new list<Id>{cadenceAction1.Id});
		CadenceSelector.getParticipantsOfCadence(cadence1.Id, 'contact');        
		CadenceSelector.getParticipantsOfUser('Contact');       
		CadenceSelector.getParticipantsWithCadenceActionsOfUser('Contact');
		CadenceSelector.getCadenceActionsByIds(new list<Id>{cadenceAction1.Id});
		CadenceSelector.getQueryForObject('Contact');
		CadenceSelector.getParticipantActions(new set<Id>{actionOnParticipants.id});
		Test.stopTest();


	}
	@isTest
	static void getAllPublicGroupTest(){
		Test.startTest();     

		//Create Parent Group
		Group grp = new Group();
		grp.name = 'Test Group1';
		grp.Type = 'Regular'; 
		Insert grp; 

		//Create Group Member
		GroupMember grpMem1 = new GroupMember();
		grpMem1.UserOrGroupId = UserInfo.getUserId();
		grpMem1.GroupId = grp.Id;
		Insert grpMem1;


		List<Group> pGroup = CadenceSelector.getAllPublicGroup();
		String objType = 'Contact';
		Id pgId = pGroup[0].Id;
		List<SObject> lstSObj = CadenceSelector.getParticipantsWithCadenceActionsOfPublicGroup(objType, pgId);
		Test.stopTest();
	}

	@isTest
	static void deleteparticipantsActionsTest(){
		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		insert c1;


		Action__c action1= TestDataFactory.createAction(ACTION_TYPE_Task);
		insert action1;

		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadence1.Participent_Activation__c='Automatic';
		cadence1.Status__c=true;
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c= CadenceConstants.CONTACT_OBJECT_NAME;
		insert cadence1;        

		CadenceAction__c cadenceAction =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceAction.Name='democadenceaction';
		cadenceAction.Trigger_Type__c= 'Immediate';       
		insert cadenceAction;

		Sequence_Action__c  actionOnParticipant = new Sequence_Action__c();
		actionOnParticipant.Name= 'demoname';
		actionOnParticipant.Contact_Id__c = c1.Id;
		actionOnParticipant.CadenceAction_ID__c=cadenceAction.Id;
		actionOnParticipant.isActionPerformed__c=false;
		insert actionOnParticipant;

		Test.startTest();
		CadenceSelector.DeleteParticipantAction(new set<Id>{c1.id});
		Integer records = [Select COUNT() from Sequence_Action__c];
		System.assertEquals(0,records);
		Test.stopTest();
	}
}