@isTest
public class TargetListControllerTest {
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	Public static Final String ACTION_TYPE_Email = 'Email';
	Public static Final String ACTION_TYPE_CALL = 'Call';
	Public static Final String ACTION_TYPE_SMS = 'SMS';
	Public static Final String ACTION_TYPE_Task = 'Task';

	public static Contact contact;

	public static Cadence__c cadenceContact;
	public static Cadence__c cadenceLead;
	public static Cadence__c cadenceobj;

	public static Action__c actionobjCall;
	public static Action__c actionobj1;
	public static Action__c actionobj;
	public static Action__c  actionobjEmail;
	public static Action__c actionobjSMS;
	public static Action__c actionobjTask;

	public static CadenceAction__c cadenceActioncontact;
	public static CadenceAction__c cadenceActionLead;
	public static CadenceAction__c cadenceActionContact2;
	public static CadenceAction__c cadenceActionLead2;
	public static CadenceAction__c cadenceActionContact3;
	public static CadenceAction__c cadenceActionContact4;
	public static CadenceAction__c cadenceActionobj1;
	public static CadenceAction__c cadenceActionobj;


	public static String cadJsonobj;
	public static String cadJsonAND;
	public static String cadJsonCUSTOM;
	public static EmailTemplate validEmailTemplate;

	static {
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
		validEmailTemplate=[select Id, isActive, Name, DeveloperName, TemplateType, FolderId, Subject from EmailTemplate LIMIT 1][0];

		cadenceContact = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);               
		cadenceLead = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);

		List<Criterion> criterionList = new List<Criterion>();
		criterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test#11'));
		criterionList.add(TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
		criterionList.add(TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test'));

		cadJsonAND = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		cadJsonCUSTOM = TestDataFactory.createCadJsonWithNameCriterions('Rest#11', 'Rest#11', CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);

		cadenceContact.Entrance_Criteria__c = cadJsonAND;
		cadenceContact.Exit_Criteria__c = cadJsonCUSTOM;
		cadenceContact.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadenceContact.Participent_Activation__c='Automatic';
		cadenceContact.matching_priority__c = 'P1';


		cadenceLead.Entrance_Criteria__c = cadJsonAND;
		cadenceLead.Exit_Criteria__c = cadJsonCUSTOM;
		cadenceLead.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadenceLead.Participent_Activation__c='Automatic';
		cadenceLead.matching_priority__c = 'P1';  

		insert cadenceContact;
		insert cadenceLead;

		//Action Type Email
		actionobjEmail= TestDataFactory.createAction(ACTION_TYPE_Email);
		actionobjEmail.Template_Id__c= validEmailTemplate.Id;
		actionobjEmail.Activation_Type__c = 'Manual';        
		insert  actionobjEmail;

		cadenceActioncontact=TestDataFactory.createCadenceAction(cadenceContact.Id, actionobjEmail.Id);
		cadenceActionLead=TestDataFactory.createCadenceAction(cadenceLead.Id, actionobjEmail.Id);
		cadenceActioncontact.Trigger_Type__c = 'Immediate';
		cadenceActionLead.Trigger_Type__c = 'Immediate';      

		insert cadenceActioncontact;
		insert cadenceActionLead;

		//Action type Call
		actionobjCall= TestDataFactory.createAction(ACTION_TYPE_CALL);        
		actionobjCall.Activation_Type__c = 'Manual';          
		insert actionobjCall;

		cadenceActionContact2=TestDataFactory.createCadenceAction(cadenceContact.Id,  actionobjCall.Id);
		cadenceActionLead2=TestDataFactory.createCadenceAction(cadenceLead.Id,  actionobjCall.Id);
		cadenceActionContact2.Trigger_Type__c = 'Immediate';
		cadenceActionLead2.Trigger_Type__c = 'Immediate';                  
		insert cadenceActionContact2;
		insert cadenceActionLead2;

		//Action type SMS
		actionobjSMS= TestDataFactory.createAction(ACTION_TYPE_SMS);        
		actionobjSMS.Activation_Type__c = 'Manual';          
		insert actionobjSMS;

		cadenceActionContact3=TestDataFactory.createCadenceAction(cadenceContact.Id,  actionobjSMS.Id);       
		cadenceActionContact3.Trigger_Type__c = 'Immediate';                        
		insert cadenceActionContact3;

		//Action type Task
		actionobjTask= TestDataFactory.createAction(ACTION_TYPE_Task);        
		actionobjTask.Activation_Type__c = 'Manual';          
		insert actionobjTask;

		cadenceActionContact4=TestDataFactory.createCadenceAction(cadenceContact.Id,  actionobjTask.Id);      
		cadenceActionContact4.Trigger_Type__c = 'Immediate';                  
		insert cadenceActionContact4;

	}

	@isTest
	static void getTargetListforSObjectForEmailTest(){
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;

		Account account= new Account();
		account.Name='DemoAccount';
		insert account;

		Contact contact= new Contact();
		contact.FirstName='Test#11';
		contact.LastName='name';
		contact.Department='IT';
		contact.LeadSource= 'Web';
		contact.AccountId= account.Id;
		contact.Title='Test';       
		insert contact;

		Lead lead= TestDataFactory.createLead();
		lead.Company='COM';
		lead.FirstName='Test#11';
		lead.LastName='lname';
		lead.Status = 'Open - Not Contacted';
		lead.LeadSource = 'Web';
		lead.Title = 'Test';
		insert lead;

		Sequence_Action__c paContact= new  Sequence_Action__c();
		Sequence_Action__c paLead= new  Sequence_Action__c();
		paContact.CadenceAction_ID__c= cadenceActioncontact.Id;
		paContact.Contact_Id__c= contact.Id;
		paLead.CadenceAction_ID__c= cadenceActionLead.Id;
		paLead.Lead_Id__c= lead.Id;
		insert paContact;
		insert paLead;

		List<Id> paList = new List<Id>();
		paList.add(paLead.Id);

		Test.startTest();        

		CadenceController.updateParticipants(cadenceContact.Id);
		CadenceController.updateParticipants(cadenceLead.Id); 

		TargetListController.getTargetListforSObject('Contact', '');
		TargetListController.getTargetListforSObject('Lead', '');
		List<TargetListController.TargetListWrapper> contactTargetList = TargetListController.getTargetListforSObject('Contact', '');
		List<TargetListController.TargetListWrapper> leadTargetList = TargetListController.getTargetListforSObject('Lead', '');

		Test.stopTest();
		System.assertEquals(1,contactTargetList.size() );
		System.assertEquals(actionobjEmail.Template_Id__c, contactTargetList.get(0).emailTempId);
		System.assertEquals(1, leadTargetList.size());

		paContact=[Select Id,CadenceAction_ID__c from Sequence_Action__c where Id =:paContact.Id][0];
		paLead=[Select Id,CadenceAction_ID__c from Sequence_Action__c where Id =:paLead.Id][0];
		System.assertEquals(paContact.CadenceAction_ID__c, cadenceActioncontact.Id, 'Action on participants, CadenceActionId is not null');
		System.assertEquals(paLead.CadenceAction_ID__c, cadenceActionLead.Id, 'Action on participants, CadenceActionId is not null');    

	} 

	@isTest
	static void getTargetListforSObjectForCallTest(){
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;

		Account accountCall= new Account();
		accountCall.Name='DemoAccount';
		insert accountCall;

		Contact contactCall= new Contact();
		contactCall.FirstName='Test#11';
		contactCall.LastName='name';
		contactCall.Department='IT';
		contactCall.LeadSource= 'Web';
		contactCall.AccountId= accountCall.Id;
		contactCall.Title='Test';       
		insert contactCall;

		Lead leadCall= TestDataFactory.createLead();
		leadCall.Company='COM';
		leadCall.FirstName='Test#11';
		leadCall.LastName='lname';
		leadCall.Status = 'Open - Not Contacted';
		leadCall.LeadSource = 'Web';
		leadCall.Title = 'Test';
		insert leadCall;

		Sequence_Action__c paContactCall= new  Sequence_Action__c();
		Sequence_Action__c paLeadCall= new  Sequence_Action__c();
		paContactCall.CadenceAction_ID__c= cadenceActioncontact2.Id;
		paContactCall.Contact_Id__c= contactCall.Id;
		paLeadCall.CadenceAction_ID__c= cadenceActionLead2.Id;
		paLeadCall.Lead_Id__c= leadCall.Id;
		insert paContactCall;
		insert paLeadCall;

		Test.startTest();        

		CadenceController.updateParticipants(cadenceContact.Id);
		CadenceController.updateParticipants(cadenceLead.Id); 

		TargetListController.getTargetListforSObject('Contact', '');
		TargetListController.getTargetListforSObject('Lead', '');

		List<TargetListController.TargetListWrapper> contactTargetListCall= TargetListController.getTargetListforSObject('Contact', '');
		List<TargetListController.TargetListWrapper> leadTargetListCall = TargetListController.getTargetListforSObject('Lead', '');
		Test.stopTest();
		System.assertEquals(1,contactTargetListCall.size());
		System.assertEquals(1,leadTargetListCall.size() );

	} 

	@isTest
	static void getTargetListforSObjectForSMSTest(){
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
		Account accountSMS= new Account();
		accountSMS.Name='DemoAccount';
		insert accountSMS;

		Contact contactSMS= new Contact();
		contactSMS.FirstName='Test#11';
		contactSMS.LastName='name';
		contactSMS.Department='IT';
		contactSMS.LeadSource= 'Web';
		contactSMS.AccountId= accountSMS.Id;
		contactSMS.Title='Test';       
		insert contactSMS;

		Test.startTest();        
		CadenceController.updateParticipants(cadenceContact.Id);

		TargetListController.getTargetListforSObject('Contact', '');
		List<TargetListController.TargetListWrapper> contactTargetListSMS= TargetListController.getTargetListforSObject('Contact', '');
		Test.stopTest();
		System.assertEquals(1,contactTargetListSMS.size());

	}


	@isTest
	static void getTargetListforSObjectForTaskTest(){  
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
		Account accountTask= new Account();
		accountTask.Name='DemoAccount';
		insert accountTask;

		Contact contactTask= new Contact();
		contactTask.FirstName='Test#11';
		contactTask.LastName='name';
		contactTask.Department='IT';
		contactTask.LeadSource= 'Web';
		contactTask.AccountId= accountTask.Id;
		contactTask.Title='Test';       
		insert contactTask;

		Test.startTest(); 
		CadenceController.updateParticipants(cadenceContact.Id);
		TargetListController.getTargetListforSObject('Contact', '');
		List<TargetListController.TargetListWrapper> contactTargetListTask = TargetListController.getTargetListforSObject('Contact', ''); 
		Test.stopTest();
		System.assertEquals(1,contactTargetListTask.size() );

	} 

	@isTest
	static void getTargetListTest(){
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
		Test.startTest();
		TargetListController.getTargetList('');
		Test.stopTest();

	}

	@isTest
	static void deletePATest(){
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
		Contact con= new Contact();
		con.FirstName='name';
		con.LastName='name';
		con.Department='IT';
		insert con;
		Cadence__c  cadenceobj = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		insert cadenceobj;
		actionobj1= TestDataFactory.createAction(ACTION_TYPE_Email);
		actionobj1.Template_Id__c= validEmailTemplate.Id;
		actionobj1.Activation_Type__c = 'Manual';
		insert actionobj1;

		cadenceActionobj1=TestDataFactory.createCadenceAction(cadenceobj.Id, actionobj1.Id);
		cadenceActionobj1.Trigger_Type__c = 'Immediate';
		insert cadenceActionobj1;

		Sequence_Action__c paObj= new  Sequence_Action__c();
		paobj.Name='samplePA';
		paObj.CadenceAction_ID__c= cadenceActionobj1.Id; 
		insert paobj;
		Task t= new Task();
		t.Description= paobj.Name;
		t.Status='Deferred';
		t.WhoId= con.Id;
		insert t;
		Test.startTest();       
		TargetListController.deletePA(new List<Id>{paobj.Id});
		Test.stopTest();
		List<Sequence_Action__c> pa= [Select Id from Sequence_Action__c where Id = : paobj.Id];
	}

	@isTest
	static void getDaysToPerformActionTest(){  
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
		cadenceobj = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		List<Criterion> criterionList = new List<Criterion>();
		criterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test#11'));
		criterionList.add(TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
		criterionList.add(TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test'));

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		cadJsonCUSTOM = TestDataFactory.createCadJsonWithNameCriterions('Rest#11', 'Rest#11', CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);
		cadenceobj.Entrance_Criteria__c= cadJsonobj;
		cadenceobj.Exit_Criteria__c=cadJsonCUSTOM;
		cadenceobj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadenceobj.matching_priority__c='P1';
		cadenceobj.Participent_Activation__c='Automatic';
		insert cadenceobj;

		actionobj= TestDataFactory.createAction(ACTION_TYPE_Email);
		actionobj.Template_Id__c= validEmailTemplate.Id;
		actionobj.Activation_Type__c = 'Automatic';
		insert actionobj;

		cadenceActionobj=TestDataFactory.createCadenceAction(cadenceobj.Id, actionobj.Id);
		cadenceActionobj.Day__c= 2;
		cadenceActionobj.Hour__c=2;
		cadenceActionobj.Trigger_Type__c = 'Immediate';
		insert cadenceActionobj;

		Lead lead= new Lead();
		lead.Company='COM';
		lead.FirstName='Test#11';
		lead.LastName='lname';
		lead.Status = 'Open - Not Contacted';
		lead.LeadSource = 'Web';
		lead.Title = 'Test';        
		insert lead;      
		Test.startTest();   
		CadenceController.updateParticipants(cadenceobj.Id);
		CadenceService.setParticipantsActivation(cadenceobj.Id,true);
		Test.stopTest();
		lead = [Select Id, EntranceCriteria_Matched_Date__c, Cadence_Id__c from Lead where Id = :lead.Id];
		TargetListController.getDaysToPerformAction(lead, cadenceActionobj);

	}

	@isTest
	public static void getTargetListInitDataTest(){
		Contacts.fireTrigger = false;
		Leads.fireTrigger = false;
		
		String str = '';
		TargetListController.getTargetListInitData(str);
	}

}