@isTest
public class CadenceSTest { 
	public static Cadence__c cadence1;
	public static Cadence__c cadence2;
	public static Cadence__c cadenceobj;
	public static Action__c actionobj;
	public static Action__c action1;
	public static String cadJsonobj;
	public static Sequence_Action__c actionOnParticipants; 
	public static CadenceAction__c cadenceActionobj;
	public static CadenceAction__c cadenceAction1;
	public static final String CUSTOM_LOGIC = '1 OR (2 AND 3)';
	Public static Final String ACTION_TYPE_Email = 'Email';
	public static List<Lead> leadlist;
	public static EmailTemplate emailTemplateObj;
	public static EmailTemplate emailTemplateObj2;
	static {
		emailTemplateObj=[select Id, Name from EmailTemplate LIMIT 1];
	}

	@isTest 
	static void getEmailTemplatesTest(){     
		Test.startTest();

		CadenceService.getEmailTemplates();
		Test.stopTest();
		list<EmailTemplate> validEmailTemplate2=[select Id, Name from EmailTemplate where Id= :emailTemplateObj.Id];
		System.assertEquals(1, validEmailTemplate2.size(), 'List of email template size must be 1');
	}

	@isTest
	public static void getFieldsTest(){
		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		insert c1;
		Test.startTest();
		CadenceService.getFields('Contact');
		Test.stopTest();

	}

	@isTest
	public static void getFieldsWithLabelsTest() {
		List<CriterionWrapper> fieldsWithLabels;
		List<String> objectList = new List<String>();
		objectList =new List<String>{CadenceConstants.LEAD_OBJECT_NAME,CadenceConstants.DB_OBJECT_NAME };
		Test.startTest();
		fieldsWithLabels = CadenceService.getFieldsWithLabels(objectList);
		Test.stopTest();

		System.assertEquals(true, fieldsWithLabels!=null);
		System.assertEquals(true, fieldsWithLabels.size()>0);
	} 

	@isTest
	public static void getDataTypeTest(){
		String fieldsWithDataType;
		Test.startTest();
		fieldsWithDataType=CadenceService.getDataType('Account', 'Name');

		Test.stopTest();        
	}

	@isTest
	public static void setParticipantsActivationTest(){
		cadence1 = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		cadence1.Participent_Activation__c='Automatic';
		cadence1.Status__c=true;
		cadence1.matching_priority__c= 'P1';
		cadence1.Record_Type__c='Lead';
		insert cadence1; 
		Test.startTest();
		CadenceService.setParticipantsActivation(cadence1.Id, True);
		Test.stopTest();
	}
	@isTest
	public static void processObjectListTest(){
		List<Lead> leadlist= new List<Lead>();
		Lead l1= TestDataFactory.createLead();
		l1.Company='COM';
		l1.FirstName='Test#11';
		l1.LastName='lname';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Title = 'Test';
		l1.Priority__C = 12;
		insert l1;

		Lead l2 = TestDataFactory.createLead();
		l2.status = 'Open - Not Contacted';
		l2.LeadSource = 'Other';
		l2.Title = 'Test';
		l1.Company='SecondCOM';
		l1.FirstName='fname2';
		l1.LastName='lname2';
		insert l2;

		leadlist.add(l1);
		leadlist.add(l2);
		Test.startTest();
		CadenceService.processObjectList(leadList);
		Test.stopTest();
	}

	@isTest
	public static void createEmailMessageTest(){
		Contact c1= new Contact();
		c1.FirstName='fname';
		c1.LastName='lname';
		c1.Department='IT';
		c1.Email='fname@gamil.com';
		insert c1;
		Test.startTest();
		emailTemplateObj2=[select Id, Name from EmailTemplate LIMIT 1];        
		CadenceService.createEmailMessage(c1.Id, emailTemplateObj2.Id);
		Test.stopTest();
	}

	@isTest
	public static void performTaskActionTest(){
		Contact c2= new Contact();
		c2.FirstName='fname';
		c2.LastName='lname';
		c2.Department='IT';       
		insert c2;

		Task taskObj = new Task();
		taskObj.subject = 'Description';
		taskObj.Description = 'testDesc';

		String jsonString = JSON.serialize(taskObj);

		Test.startTest();
		CadenceService.performTaskAction(c2.Id, jsonString);
		Test.stopTest();
	}


	@isTest
	public static void assignCadenceToParticipantsTest(){
		cadenceobj = TestDataFactory.createCadence(CadenceConstants.LEAD_OBJECT_NAME);
		List<Criterion> criterionList = new List<Criterion>();
		criterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test#11'));
		criterionList.add(TestDataFactory.createCriterion(2, 'LeadSource', 'PICKLIST', 'equals', 'Web'));
		criterionList.add(TestDataFactory.createCriterion(3, 'Title', 'STRING', 'contains', 'Test'));

		List<Criterion> exitCriterionList = new List<Criterion>();
		exitCriterionList.add(TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Exit'));
		exitCriterionList.add(TestDataFactory.createCriterion(2, 'LastName', 'STRING', 'equals', 'Lead'));
		String exitCriterion = TestDataFactory.createCadenceJSON(exitCriterionList, CadenceConstants.CONDITION_AND, ''); 

		cadJsonobj = TestDataFactory.createCadenceJSON(criterionList, CadenceConstants.CONDITION_AND, '');
		cadenceobj.Entrance_Criteria__c= cadJsonobj;
		cadenceobj.Exit_Criteria__c=exitCriterion;
		cadenceobj.Exit_Criteria_PE__c = RuleCriterionMatcher.getPostFixExpression(CUSTOM_LOGIC);
		cadenceobj.matching_priority__c='P1';
		cadenceobj.Participent_Activation__c='Automatic';
		insert cadenceobj;

		actionobj= TestDataFactory.createAction(ACTION_TYPE_Email);
		actionobj.Template_Id__c= '00Xf4000001cPpjEAE';
		actionobj.Activation_Type__c = 'Automatic';
		insert actionobj;

		cadenceActionobj=TestDataFactory.createCadenceAction(cadenceobj.Id, actionobj.Id);
		cadenceActionobj.Day__c= 2;
		cadenceActionobj.Hour__c=2;
		cadenceActionobj.Trigger_Type__c = 'Immediate';
		insert cadenceActionobj;

		Lead l1= new Lead();
		l1.Company='COM';
		l1.FirstName='Test#11';
		l1.LastName='lname';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Title = 'Test';      

		insert l1;
		Test.startTest();
		CadenceController.updateParticipants(cadenceobj.Id);
		CadenceService.setParticipantsActivation(cadenceobj.Id,true);          
		Test.stopTest();
		l1 = [Select Id, Cadence_Id__c from Lead where Id = :l1.Id];
		l1.EntranceCriteria_Matched_Date__c = system.now();
		System.assertEquals(cadenceobj.Id, l1.Cadence_Id__c, 'Cadence lookup will populate as its criterion matches');    
		CadenceService.assignCadenceToParticipants(new Map<Id,Cadence__c>{ cadenceobj.Id => cadenceobj }, new List<Lead>{l1}, New Map<Id, SObject>(), 'lead');
	} 

	@isTest
	public static void getRemainingParticipantActionsTest(){
		Contact c4= new Contact();
		c4.FirstName='fname';
		c4.LastName='lname';
		c4.Department='IT';       
		insert c4;
		Lead l1= new Lead();
		l1.Company='COM';
		l1.FirstName='Test#11';
		l1.LastName='lname';
		l1.Status = 'Open - Not Contacted';
		l1.LeadSource = 'Web';
		l1.Title = 'Test';        
		insert l1;       
		Test.startTest();
		CadenceService.getRemainingParticipantActions(new Set<Id>{c4.Id}, 'contact');
		Test.stopTest();
	}

	@isTest
	public static void deleteSobjectsByIdsTest(){
		Contact c3= new Contact();
		c3.FirstName='fname';
		c3.LastName='lname';
		c3.Department='IT';       
		insert c3;
		Test.startTest();
		CadenceService.deleteSobjectsByIds('contact', new List<Id>{c3.Id});
		Test.stopTest();
	}
}