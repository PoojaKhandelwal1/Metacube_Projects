@isTest
public class CadenceServiceTest {
	public static final String CUSTOM_LOGIC = '1 AND (2 OR 3 OR 4)';
	Public static Final String ACTION_TYPE_CALL = 'Call';
	public static final String CUSTOM_LOGIC1 = '1 AND (2 AND 3)';
	public static final String CUSTOM_LOGIC2 = '1 OR (2 OR 3)';

	public static Cadence__c cadLeadAND;
	public static Cadence__c cadLeadOR;
	public static Cadence__c cadLeadCUSTOM;

	public static Cadence__c cadContactAND; 
	public static Cadence__c cadContactOR;

	public static Action__c action1;
	public static Action__c action2;
	public static Action__c action3;

	public static CadenceAction__c cadenceActionLeadAND;
	public static CadenceAction__c cadenceActionLeadOR;
	public static CadenceAction__c cadenceActionCUSTOM;

	public static String cadJsonAND;
	public static String cadJsonOR;
	public static String cadJsonCUSTOM; 
	static {

		cadLeadAND = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadLeadOR = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadLeadCUSTOM = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);

		List<Criterion> criterionList = new List<Criterion>();
		Criterion c1 = TestDataFactory.createCriterion(1, 'Status', 'PICKLIST', 'equals', 'Open - Not Contacted');
		Criterion c2 = TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web');
		Criterion c3 = TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test');
		Criterion c4 = TestDataFactory.createCriterion(4, 'Phone', 'STRING', 'contains', '1234567890');

		criterionList.add(c1);
		criterionList.add(c2);
		criterionList.add(c3);
		criterionList.add(c4);

		cadJsonAND = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, CUSTOM_LOGIC1);
		cadJsonOR = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_OR, CUSTOM_LOGIC2);
		cadJsonCUSTOM = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_CUSTOM, CUSTOM_LOGIC);


		cadLeadAND.Entrance_Criteria__c = cadJsonAND;

		cadLeadOR.Entrance_Criteria__c =  cadJsonOR;
		cadLeadOR.Exit_Criteria__c = cadLeadOR.Entrance_Criteria__c;

		cadLeadCUSTOM.Entrance_Criteria__c = cadJsonCUSTOM;

		cadLeadOR.Participent_Activation__c = 'Automatic';

		insert cadLeadOR;

		action1= TestDataFactory.createAction(ACTION_TYPE_CALL);
		action2= TestDataFactory.createAction(ACTION_TYPE_CALL);
		action3= TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert action1;
		action2.Activation_Type__c = 'Automatic';
		insert action2;
		insert action3; 

		cadenceActionLeadOR=TestDataFactory.createCadenceAction(cadLeadOR.Id, action2.Id);
		cadenceActionLeadOR.Trigger_Type__c = 'Immediate';
		insert cadenceActionLeadOR;
	}
	@isTest
	public static void testMethod1(){
		Lead l1= new Lead();
		l1.Company='Test#121';
		l1.FirstName='Test#121';
		l1.LastName='Test#121';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Phone = '1212121212';
		l1.Title = 'Test';
		insert l1;

	}

	@isTest
	public static void unMappedParticipateTest(){
		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadence1.Participent_Activation__c='Automatic';
		cadence1.Status__c=true;
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c='Lead';
		String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
		cadence1.Entrance_Criteria__c = entryJson;
		cadence1.Exit_Criteria__c = exitJson;
		insert cadence1;

		action1= TestDataFactory.createAction('Email');
		action1.Template_Id__c= '00Xf4000001cPpjEAE';
		action1.Activation_Type__c = 'Automatic';
		action1.Type__c ='Task';
		insert action1;
		System.assertNotEquals(null, action1);

		cadenceActionLeadAND =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceActionLeadAND.Day__c= 2;
		cadenceActionLeadAND.Hour__c=2;
		cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
		insert cadenceActionLeadAND;

		System.assertNotEquals(null, cadenceActionLeadAND);

		Lead l1= TestDataFactory.createLead();
		l1.Company='COM';
		l1.FirstName='Test#11';
		l1.LastName='lname';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Title = 'Test';
		insert l1;
		System.assertNotEquals(null, l1.id);

		Lead l2= TestDataFactory.createLead();
		l2.Company='COM2';
		l2.FirstName='Test#12';
		l2.LastName='lname2';
		l2.Status = 'Open - Not Contacted';
		l2.LeadSource = 'Web';
		l2.Title = 'Test';
		insert l2;
		System.assertNotEquals(null, l2.id);


		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		insert c1;
		System.assertNotEquals(null, c1.id);

		Contact c2= new Contact();
		c2.FirstName='fname2';
		c2.LastName='lname2';
		c2.Department='IT';
		insert c2;
		System.assertNotEquals(null, c2.id);

		Sequence_Action__c seqAction  =  new Sequence_Action__c();
		seqAction.CadenceAction_Id__c = cadenceActionLeadAND.id;
		seqAction.isActionPerformed__c =false;
		seqAction.Lead_Id__c =l1.id;
		insert seqAction;

		System.assertNotEquals(null, seqAction.id);

		Sequence_Action__c seqAction2  =  new Sequence_Action__c();
		seqAction2.CadenceAction_Id__c = cadenceActionLeadAND.id;
		seqAction2.isActionPerformed__c =false;
		seqAction2.Contact_Id__c =c1.id; 
		insert seqAction2;

		System.assertNotEquals(null, seqAction2.id);

		map<id,id > mapofleadCadence =  new map<id,id>{l2.id =>cadence1.id};
		map<id,id > mapofleadCadence2 =  new map<id,id>{c1.id =>cadence1.id};
		list<Lead> listoflead  = new list<Lead>();
		listoflead.add(l1); 

		list<contact> listofcon  = new list<contact>();
		listofcon.add(c1);    
		Test.startTest();
		CadenceService.processParticipantsWithCadences(listoflead, New Map<Id, SObject> (),'Lead',false);
		CadenceService.processParticipantsWithCadences(listofcon,New Map<Id, SObject> (),'Contact',false);
		CadenceService.deleteUnperformedPartActions(mapofleadCadence,'Lead');
		CadenceService.deleteUnperformedPartActions(mapofleadCadence2,'Contact');
		List<Sequence_Action__c> listOfLeadseq = new List<Sequence_Action__c>{seqAction};
		List<Sequence_Action__c> listOfcontactseq = new List<Sequence_Action__c>{seqAction2};

		Set<Id> Ids = new Set<Id>();
		Ids.add(c1.id);
		CadenceService.getParticipantSequenceHistory(Ids,'Contact');

		Ids = new Set<Id>();
		Ids.add(l1.id);
		CadenceService.getParticipantSequenceHistory(Ids,'Lead');

		CadenceService.createHistoryObject(cadence1.Id,c1.Id,'Contact');

		Map<Id, Cadence__c> cadMap = new Map<Id, Cadence__c>();
		cadMap.put(cadence1.Id, cadence1);
		List<Id> sequenceIds = new List<Id>();
		sequenceIds.add(cadence1.Id);
		cadMap = CadenceService.removeCadencefromMap(cadMap,sequenceIds);
		System.assertEquals(0,cadMap.size());


		CadenceController.getCadenceData(cadence1.Id);


		Task taskObj = CadenceService.getEmailTask(seqAction.Id, 'testAction', l1.id, l1.id );

		insert taskObj;
		update taskObj;
		System.assertEquals(taskObj.WhoId, l1.id);
		System.assertEquals(taskObj.Sequence_Action__c, seqAction.Id);
		System.assertEquals(taskObj.TaskSubtype, 'Email');
		List<Task> tasksToCreate = new List<Task>();
		tasksToCreate.add(taskObj);
		String tasksJson = JSON.serialize(tasksToCreate); 
		CadenceService.createTasks(tasksJson);
		CadenceService.updateActionOnParticipantExpectedDate(system.now(), 0, listOfLeadseq);

		Test.stopTest();
	}

	@isTest
	public static void OpportunityTest(){
		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c=CadenceConstants.OPPORTUNITY_OBJECT_NAME;
		String entryJson = TestDataFactory.createCadJsonWithNameCriterionsForOpp('Test',  CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterionsForOpp('Test1',  CadenceConstants.CONDITION_AND, '');
		cadence1.Entrance_Criteria__c = entryJson;
		cadence1.Exit_Criteria__c = exitJson;
		insert cadence1;

		action1= TestDataFactory.createAction('Email');
		action1.Template_Id__c= '00Xf4000001cPpjEAE';
		action1.Activation_Type__c = 'Automatic';
		insert action1;
		System.assertNotEquals(null, action1);

		cadenceActionLeadAND =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceActionLeadAND.Day__c= 0;
		cadenceActionLeadAND.Hour__c= 0;
		cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
		cadenceActionLeadAND.Fields_To_Update_Action__c = '{"sobjectType":"Lead","IsPrivate":"false"}';
		insert cadenceActionLeadAND;

		System.assertNotEquals(null, cadenceActionLeadAND.Id);

		Opportunity opportunity = TestDataFactory.createOpp('Test-opp-01');
		insert opportunity;
		System.assertNotEquals(null, opportunity.Id); 

		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		c1.Opportunity_Id__c = opportunity.Id;
		insert c1;
		System.assertNotEquals(null, c1.Id);

		Sequence_Action__c seqAction  =  new Sequence_Action__c();
		seqAction.CadenceAction_Id__c = cadenceActionLeadAND.id;
		seqAction.isActionPerformed__c =false;
		seqAction.Contact_Id__c = c1.Id;
		insert seqAction;
		System.assertNotEquals(null, seqAction.Id);

		OpportunityContactRole oppRol = TestDataFactory.createOpportunityRole(opportunity.Id,c1.Id);
		insert oppRol;
		System.assertNotEquals(null, oppRol.Id);

		Test.startTest();
		PerformCadenceActionBatch con=new PerformCadenceActionBatch(new List<string>{CadenceConstants.CONTACT_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME});
		Database.executeBatch(con,500);

		// Schedule batch for lead
		PerformCadenceActionBatch led=new PerformCadenceActionBatch(new List<string>{CadenceConstants.LEAD_OBJECT_NAME, CadenceConstants.DB_OBJECT_NAME});
		Database.executeBatch(led,500);

		// Schedule batch for opportunity
		PerformCadenceActionBatch opp =new PerformCadenceActionBatch(new List<string>{CadenceConstants.OPPORTUNITY_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME,CadenceConstants.CONTRACT_OBJECT_NAME,CadenceConstants.PRICE_BOOK_OBJECT_NAME});
		Database.executeBatch(opp,500);

		List<SObject> objList = new List<SObject>{opportunity}; 
		Map<Id, List<Sequence_Action__c>> seqList = new Map<Id, List<Sequence_Action__c>>();
		seqList.put(c1.Id,new List<Sequence_Action__c>{seqAction});
		CadenceService.updateSObjectFields(objList,seqList ,CadenceConstants.OPPORTUNITY_OBJECT_NAME,false);

		System.assertEquals(opportunity.IsPrivate,false);
		Test.stopTest(); 

	}

	@isTest
	static void OpportunityExitTest(){
		Opportunity opportunity = TestDataFactory.createOpp('Test-opp-01');

		insert New List<opportunity>{opportunity};
		System.assertNotEquals(null, opportunity.Id); 

		Contact c1= new Contact();
		c1.FirstName='Test';
		c1.LastName='Contact for Role1';
		c1.Department='IT';
		c1.Opportunity_Id__c = opportunity.Id;


		insert new List<Contact>{c1};
		System.assertNotEquals(null, c1.Id);

		OpportunityContactRole oppRol = new OpportunityContactRole(Role='Decision Maker',ContactId=c1.Id,OpportunityId=opportunity.id);
		insert new List<OpportunityContactRole>{oppRol};
		System.assertNotEquals(null, oppRol.Id);

		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c=CadenceConstants.OPPORTUNITY_OBJECT_NAME;
		String entryJson = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Decision Maker', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterionsForOppRole('Business User', CadenceConstants.CONDITION_AND, '');
		cadence1.Entrance_Criteria__c = entryJson;
		cadence1.Exit_Criteria__c = exitJson;

		insert cadence1;
		System.assertNotEquals(null, cadence1);

		c1.Cadence_ID__c = cadence1.Id;
		update c1; 

		action1= TestDataFactory.createAction('Email');
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			EmailTemplate validEmailTemplate = new EmailTemplate();
			validEmailTemplate.isActive = true;
			validEmailTemplate.Name = 'name';
			validEmailTemplate.DeveloperName = 'unique_name_addSomethingSpecialHere';
			validEmailTemplate.TemplateType = 'text';
			validEmailTemplate.FolderId = UserInfo.getUserId();
			insert validEmailTemplate;
			System.assertNotEquals(null, validEmailTemplate);
			action1.Template_Id__c= validEmailTemplate.id;
		}
		action1= TestDataFactory.createAction('Email');
		action1.Template_Id__c= null;
		action1.Activation_Type__c = 'Automatic';

		insert action1;
		System.assertNotEquals(null, action1);

		CadenceAction__c cadenceAction = TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceAction.Day__c= 0;
		cadenceAction.Hour__c= 0;
		cadenceAction.Trigger_Type__c = 'Immediate';
		cadenceAction.Fields_To_Update_Action__c = '{"sobjectType":"Lead","IsPrivate":"true"}';
		insert cadenceAction;
		System.assertNotEquals(null, cadenceAction.Id);


		Sequence_Action__c seqAction  =  new Sequence_Action__c();
		seqAction.CadenceAction_Id__c = cadenceAction.id;
		seqAction.isActionPerformed__c =false;
		seqAction.Contact_Id__c = c1.Id;
		insert seqAction;

		Map<Id, List<Sequence_Action__c>> partActionsMap =  CadenceService.getRemainingParticipantAction(new Set<Id>{c1.Id}, CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		Test.startTest();
		// Schedule batch for opportunity
		PerformCadenceActionBatch oppBatch =new PerformCadenceActionBatch(new List<string>{CadenceConstants.OPPORTUNITY_OBJECT_NAME, CadenceConstants.ACCOUNT_OBJECT_NAME,CadenceConstants.CONTRACT_OBJECT_NAME,CadenceConstants.PRICE_BOOK_OBJECT_NAME});
		Database.executeBatch(oppBatch,500);

		CadenceService.updateSObjectFields(New List<Contact>{c1}, partActionsMap, CadenceConstants.OPPORTUNITY_OBJECT_NAME , false);
		System.assertNotEquals(opportunity.IsPrivate, true);

		CadenceActionListController.deleteCadences(new List<Id>{cadence1.Id});
		System.assertNotEquals(null, cadence1.Id);

		Test.stopTest();
	}    

	@isTest
	public static void mapToWrapperObjTest(){
		Map<String, String> apiMap = New Map<String, String>();
		apiMap.put('key', 'value');
		Test.startTest();
		CadenceService.mapToWrapperObj(apiMap);
		Test.stopTest(); 

	}

	@isTest
	public static void createNativeEmailMessageTest(){
		EmailTemplate emailTemplate = [select Id, Name from EmailTemplate LIMIT 1];
		List<Id> emailTemplateIdList = new List<Id>();
		emailTemplateIdList.add(emailTemplate.Id);
		List<NativeEmailMessage> nativeEmailMsgList = new List<NativeEmailMessage>();
		Boolean isNativeEmail;
		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		insert c1;
		Test.startTest();
		CadenceService.createNativeEmailMessage('test@gmail.com',emailTemplate.Id, c1.Id, c1.Id, 'testName', c1.Id );
		Test.stopTest(); 
	}

	@isTest
	public static void getTemplateTest(){
		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c=CadenceConstants.OPPORTUNITY_OBJECT_NAME;
		String entryJson = TestDataFactory.createCadJsonWithNameCriterionsForOpp('Test',  CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterionsForOpp('Test1',  CadenceConstants.CONDITION_AND, '');
		cadence1.Entrance_Criteria__c = entryJson;
		cadence1.Exit_Criteria__c = exitJson;
		insert cadence1;

		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		insert c1;

		c1.Department = 'Sales';
		update c1;

		action1= TestDataFactory.createAction('Email');
		action1.Template_Id__c= '00Xf4000001cPpjEAE';
		action1.Activation_Type__c = 'Automatic';
		insert action1;
		System.assertNotEquals(null, action1);

		cadenceActionLeadAND =TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceActionLeadAND.Day__c= 0;
		cadenceActionLeadAND.Hour__c= 0;
		cadenceActionLeadAND.Trigger_Type__c = 'Immediate';
		cadenceActionLeadAND.Fields_To_Update_Action__c = '{"sobjectType":"Lead","IsPrivate":"false"}';
		insert cadenceActionLeadAND;

		System.assertNotEquals(null, cadenceActionLeadAND.Id);

		Test.startTest();
		CadenceService.getSMSTemplates();
		CadenceService.getCallTemplates();
		CadenceService.getVMTemplates();
		CadenceService.getEmailTemplates();
		CadenceService.getUserWrapperList();
		CadenceService.getDandBCompanyWrapperList();
		CadenceService.getFields('Contact');
		CadenceService.getFieldsWithLabelsForUpdate(new List<String>{CadenceConstants.CONTACT_OBJECT_NAME,CadenceConstants.ACCOUNT_OBJECT_NAME}); 
		CadenceService.setParticipantsActivation(cadence1.Id,true);
		CadenceService.getCadenceParticipants(cadence1.Id,CadenceConstants.OPPORTUNITY_OBJECT_NAME);
		Test.stopTest(); 
	}

	@IsTest
	public static void sendNativeEmailTroughTriggerTest(){
		RingDNAApiCallouts obj = new RingDNAApiCallouts();
		List<NativeEmailMessage> nativeEmailMessageList = new List<NativeEmailMessage>();
		NativeEmailMessage nativeEmailMessage = new NativeEmailMessage();
		nativeEmailMessage.ActionId = action1.Id;
		nativeEmailMessage.MailTo = 'test@gmail.com';
		nativeEmailMessage.Body = 'body mail 1';
		nativeEmailMessage.UserId = action1.Id;
		nativeEmailMessageList.add(nativeEmailMessage);
		CadenceService.SendNativeEmail(nativeEmailMessageList);
		CadenceService.sendNativeEmailTroughTrigger(JSON.serialize(nativeEmailMessageList));
	}
	
	@IsTest
	public static void showOnTargetListActionTimeUpdateTest() {
		Cadence__c cadence1 = TestDataFactory.createCadence(CadenceConstants.CONTACT_OBJECT_NAME);
		cadence1.matching_priority__c = 'P1';
		cadence1.Record_Type__c = CadenceConstants.CONTACT_OBJECT_NAME;
		String entryJson = TestDataFactory.createCadJsonWithNameCriterions('Test', 'Test', CadenceConstants.CONDITION_AND, '');
		String exitJson = TestDataFactory.createCadJsonWithNameCriterions('Test1', 'Test1', CadenceConstants.CONDITION_AND, '');
		cadence1.Entrance_Criteria__c = entryJson;
		cadence1.Exit_Criteria__c = exitJson;
		insert cadence1;

		Contact c1 = new Contact();
		c1.FirstName = 'Test';
		c1.LastName = 'Test';
		c1.Department = 'IT';
		insert c1;

		action1 = TestDataFactory.createAction('Task');
		insert action1;
		System.assertNotEquals(null, action1);

		action2 = TestDataFactory.createAction(ACTION_TYPE_CALL);
		insert action2;
		System.assertNotEquals(null, action2);

		CadenceAction__c cadenceAction = TestDataFactory.createCadenceAction(cadence1.Id, action1.Id);
		cadenceAction.Day__c = 0;
		cadenceAction.Hour__c = 0;
		cadenceAction.Trigger_Type__c = 'Immediate';
		insert cadenceAction;
		System.assertNotEquals(null, cadenceAction.Id);


		CadenceAction__c cadenceAction1 = TestDataFactory.createCadenceAction(cadence1.Id, action2.Id);
		cadenceAction1.Day__c = 0;
		cadenceAction1.Hour__c = 0;
		cadenceAction1.Trigger_Type__c = 'Immediate';
		insert cadenceAction1;
		System.assertNotEquals(null, cadenceAction1.Id);


		Sequence_Action__c seqAction = new Sequence_Action__c();
		seqAction.CadenceAction_Id__c = cadenceAction.id;
		seqAction.isActionPerformed__c = false;
		seqAction.Contact_Id__c = c1.Id;
		insert seqAction;

		Sequence_Action__c seqAction1 = new Sequence_Action__c();
		seqAction1.CadenceAction_Id__c = cadenceAction1.id;
		seqAction1.isActionPerformed__c = false;
		seqAction1.Contact_Id__c = c1.Id;
		insert seqAction1;


		Test.startTest();
		//Schedule batch for contact
		PerformCadenceActionBatch con = new PerformCadenceActionBatch(new List < string > {
			CadenceConstants.CONTACT_OBJECT_NAME,
			CadenceConstants.ACCOUNT_OBJECT_NAME
		});
		Database.executeBatch(con, 100);
		CadenceService.updateActionOnParticipantExpectedDate(seqAction.Actual_Execution_Date__c, (Integer) seqAction.CadenceAction_Id__r.Index__c, new List < Sequence_Action__c > {
			seqAction
		});
		Test.stopTest();
	}
	
}