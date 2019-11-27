public class Logger {
	private static List<Logger__c> logInstances = new List<Logger__c>();

	public static void buildLog(String title, String description){
		logInstances.add(new Logger__c(Title__c = title, Description__c = description));
	}

	public static void insertLog(){
		List<Sequence_Logger__c> enableLoggerSettings = [SELECT IsEnabled__c FROM Sequence_Logger__c LIMIT 1];
		if(enableLoggerSettings.size() > 0 && enableLoggerSettings[0].IsEnabled__c && logInstances.size() > 0){
			insert logInstances;
			logInstances.clear();
		}
	}
}