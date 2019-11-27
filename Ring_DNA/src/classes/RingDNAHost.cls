public class RingDNAHost {

	private static Map<String, String> baseUriMap = new Map<String, String>{
				'local' => 'https://<development.host>',
				'qa' => 'https://qa.ringdna.com',
				'production' => 'https://app.ringdna.com'
	};

	public static Map<String, String> getBaseUri() {
		Map<String, String> dataFromCustomSetting = new Map<String, String>();
		String baseUrl = '';

		RingDNAEnvironment__c[] environments = [SELECT value__c From RingDNAEnvironment__c];
		// There should only be one of these.
		if(! environments.isEmpty()){ 
			RingDNAEnvironment__c environment = environments[0];
			String environmentString = environment.value__c;
			baseUrl = baseUriMap.get(environmentString);
		}

		SequenceSettings__c[] sequenceSettings = [SELECT ApiKey__c, ApiSecret__c From SequenceSettings__c];
		String apiKey = '';
		String apiSecret = '';
		if(! sequenceSettings.isEmpty()){ 
			SequenceSettings__c sequenceSetting = sequenceSettings[0];
			apiKey = sequenceSetting.ApiKey__c == null ? '' : sequenceSetting.ApiKey__c;
			apiSecret = sequenceSetting.ApiSecret__c == null ? '' : sequenceSetting.ApiSecret__c;
		}
		dataFromCustomSetting.put('Host', baseUrl);
		dataFromCustomSetting.put('ApiKey', apiKey);
		dataFromCustomSetting.put('ApiSecret', apiSecret);
		return dataFromCustomSetting;
	}
}