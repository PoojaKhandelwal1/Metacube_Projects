@isTest
public class NativeEmailControllerTest {
	public static Action__c action;
	public static EmailTemplate template;
	public static Lead testLead;
	public static String subject,body;
	public static Cadence__c cadenceLead;
	public static CadenceAction__c cadenceActionLead;
	public static Sequence_Action__c sequenceActionLead;
	static{
		//create action of type email
		action = TestDataFactory.createAction('Email');
		//creation of email template
		System.runAs ( new User(Id = UserInfo.getUserId()) ) {
			EmailTemplate validEmailTemplate = new EmailTemplate();
			validEmailTemplate.isActive = true;
			validEmailTemplate.Name = 'name';
			validEmailTemplate.DeveloperName = 'unique_name';
			validEmailTemplate.TemplateType = 'text';
			validEmailTemplate.Body='Test Body for {!Lead.Name}';
			validEmailTemplate.Subject='New {!Lead.Name}';
			validEmailTemplate.FolderId = UserInfo.getUserId();
			insert validEmailTemplate;
			template=validEmailTemplate;
			action.Template_Id__c= validEmailTemplate.id;
		}
		action.Activation_Type__c='Manual';
		action.Email_Type__c='NATIVE';
		insert action;
		//creation of cadence of type Lead
		cadenceLead = TestDataFactory.createCadence('Lead');
		Criterion c1 = TestDataFactory.createCriterion(1, 'FirstName', 'STRING', 'equals', 'Test');
		String jsonEntryString = TestDataFactory.createCadenceJSON(new List<Criterion>{c1}, CadenceConstants.CONDITION_OR, null);
		Criterion exitCriteria = TestDataFactory.createCriterion(1, 'Email', 'STRING', 'equals', 'test123@gmail.com');
		String jsonExitString = TestDataFactory.createCadenceJSON(new List<Criterion>{exitCriteria}, CadenceConstants.CONDITION_AND, null);
		cadenceLead.Entrance_Criteria__c = jsonEntryString;
		cadenceLead.Participent_Activation__c='Automatic';
		cadenceLead.matching_priority__c='P1';
		cadenceLead.Exit_Criteria__c = jsonExitString; 
		insert cadenceLead;
		//craetion of Cadence Action
		cadenceActionLead = TestDataFactory.createCadenceAction(cadenceLead.Id, action.Id);
		insert cadenceActionLead;
		//test lead which satisfy entrance criteria
		testLead = TestDataFactory.createLead(cadenceLead.Id);
		testLead.FirstName='Test';
		testLead.LastName='Lead';
		testLead.Company='Test Company';
		testLead.Email='test@gmail.com';
		insert testLead;
		sequenceActionLead=new Sequence_Action__c(CadenceAction_Id__c=cadenceActionLead.Id,Lead_Id__c=testLead.Id);
		insert sequenceActionLead;
	} 
	@isTest
	public static void testGetData(){
		Test.startTest();
		NativeEmailController.NativeEmailWrapper emailWrapper=NativeEmailController.getData(testLead.Id,template.Id);
		Test.stopTest();
		System.assertEquals('New Test Lead',emailWrapper.emailTemplateSubject);
		subject=emailWrapper.emailTemplateSubject;
		System.assertEquals('Test Body for Test Lead',emailWrapper.emailTemplateBody);
		body=emailWrapper.emailTemplateBody;
	}
	@isTest
	public static void testResolveMergeFields(){
		NativeEmailMessage message;
		Test.startTest();
		message=NativeEmailController.resolveMergeFields(testLead.Id,template.Id);
		Test.stopTest();
		System.assertEquals('New Test Lead',message.Subject);
		System.assertEquals('Test Body for Test Lead',message.Body);
	}

	@isTest
	public static void testSendEmail(){
		NativeEmailController.SendNativeEmailResult result = new NativeEmailController.SendNativeEmailResult();
		Test.startTest(); 
		result =NativeEmailController.sendEmail((String)testLead.Id,null,null,'Test Subject','test this body',(String)testLead.Id,(String)template.Id,(String)sequenceActionLead.Id);
		Test.stopTest();
		System.assertEquals(true, result.Success);
	}
}