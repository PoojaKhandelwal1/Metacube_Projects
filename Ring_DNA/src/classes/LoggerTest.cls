@isTest
public class LoggerTest {
	@isTest
	public static void test_insertLog_loggerSetting_enabled(){
		Sequence_Logger__c enableLoggerSettings =new Sequence_Logger__c(IsEnabled__c=true);
		insert enableLoggerSettings;

		Logger.buildLog('Test title', 'Test description');
		Logger.insertLog();

		Logger__c logger = [Select Description__c from Logger__c];
		system.assertEquals('Test description', logger.Description__c);
	}

	public static void test_insertLog_loggerSetting_disabled(){
		Logger.buildLog('Test title', 'Test description');
		Logger.insertLog();
		Logger__c logger = [Select Description__c from Logger__c];
		system.assertEquals('', logger.Description__c);
	}
}