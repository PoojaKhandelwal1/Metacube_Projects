@isTest 
public class RingDNAApiCallouts_test {
	public static String sessionId;
	public static String accountId;
	public static String userId;
	public static String host;
	public static final String HTTP_METHOD = 'GET';
	public static final String BASE_URL = 'api/v2/app';
	public static final String ACCOUNT_DETAILS_PATH = 'salesforce/verify';
	public static final String CALL_NOTE_TEMPLATES_PATH = 'callNoteTemplates';
	public static final String SMS_TEMPLATES_PATH = 'smsTemplates';
	public static final String VOICEMAIL_DROPS_PATH = 'voicemailDrops';
	static{
		Account acc = TestDataFactory.createAccount();
		insert acc;
		System.assertNotEquals(null, acc);
		accountId = acc.id;
		sessionId = userinfo.getSessionId();
		userId = userinfo.getUserId();
		RingDNAEnvironment__c RingDNAEnviron2 = new RingDNAEnvironment__c(value__c='local');
		insert RingDNAEnviron2;
		System.assertNotEquals(null, RingDNAEnviron2);

	}
	static testMethod void VoicemailDropsTest(){
		Test.setMock(HttpCalloutMock.class, new AccountDetailsMockClass());
		test.startTest();
		// Set mock callout class 
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts();
		test.stopTest();
	} 
	static testMethod void VoicemailDropsTest2(){
		test.startTest();  
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts();
		Test.setMock(HttpCalloutMock.class, new VoicemailDropsMockCallout());
		testRingDNAApiCallout.getVoicemailDrops(); 
		test.stopTest();
	}

	static testMethod void SMSTemplatesTest(){

		test.startTest();
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts();
		Test.setMock(HttpCalloutMock.class, new SMSTemplatesMockCallout());
		testRingDNAApiCallout.getSMSTemplatesUpdated();
		testRingDNAApiCallout.getSMSTemplates();
		test.stopTest();
	}
	static testMethod void CallNoteTemplatesTest(){
		test.startTest();
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts();
		Test.setMock(HttpCalloutMock.class, new CallNoteTemplatesMockCallout());
		testRingDNAApiCallout.getCallNoteTemplates();
		testRingDNAApiCallout.getCallNoteTemplatesUpdated();
		test.stopTest();
	}
	static testMethod void SendNativeEmailTest(){
		test.startTest();
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts();
		Test.setMock(HttpCalloutMock.class, new SendNativeEmailMockCallout());
		testRingDNAApiCallout.sendNativeEmail('test@gmail.com','Test Name','Test body',accountId,'Test Subject', 'UserId');
		test.stopTest();
	}
	static testMethod void SendNativeMassEmailTest(){
		test.startTest();
		RingDNAApiCallouts testRingDNAApiCallout = new RingDNAApiCallouts(true);
		Test.setMock(HttpCalloutMock.class, new SendNativeMassEmailMockCallout());

		List<NativeEmailMessage> nativeEmailMessageList = new List<NativeEmailMessage>();
		NativeEmailMessage nativeEmailMessage = new NativeEmailMessage();
		nativeEmailMessage.ActionId = accountId;
		nativeEmailMessage.MailTo = 'test@gmail.com';
		nativeEmailMessage.Body = 'body mail 1';
		nativeEmailMessage.UserId = userId;
		nativeEmailMessageList.add(nativeEmailMessage);
		List<NativeEmailRespose> sendNativeMassEmailList = testRingDNAApiCallout.sendNativeMassEmail(nativeEmailMessageList);

		system.assertEquals(1, sendNativeMassEmailList.size());
		test.stopTest();
	}
}