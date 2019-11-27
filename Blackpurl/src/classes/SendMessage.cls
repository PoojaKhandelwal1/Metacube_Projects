public class SendMessage {
	
	
    public static String send(String dstNumber, String text) {
        String api_key = SMS_Configuration__c.getOrgDefaults().AuthId__c;
        String api_token = SMS_Configuration__c.getOrgDefaults().AuthToken__c;
        String srcNumber = SMS_Configuration__c.getOrgDefaults().Source_Number__c;
        if(String.isBlank(srcNumber)) {
        	return 'Source Number does not exists';
        }
        if(String.isNotBlank(api_key) && String.isNotBlank(api_token)) {
            SMSRestApi api = new SMSRestApi(api_key, api_token, 'v1');
            
            Map<String, String> params = new Map<String, String> ();
            params.put('src', srcNumber);
            params.put('dst', dstNumber);
            params.put('text', text);
            MessageResponse msg = api.sendMessage(params);
            if(Constants.smsRespCodeToErrMsgMap.containsKey(msg.server_code)) {
                return Constants.smsRespCodeToErrMsgMap.get(msg.server_code);
            }
        	return msg.message;
        } else {
        	return Constants.smsRespCodeToErrMsgMap.get(401);
        }
        return Constants.smsRespCodeToErrMsgMap.get(500);
    } 
   	
   	/** 
     * Name: getAreacodeFromCountry
     *@author : Nikhil
     * Desc: To get AreaCode Information related to the customer
     * @param: (1) countryName  
     * @return: String - Areacode related to the country 
    **/
    public static String getAreacodeFromCountry(String countryName) {
		String areaCode;
		if(AccessControl.ifObjectFieldIsAccessible('Country_Area_Code__mdt') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
		String query = 'SELECT Area_Code__c, Country__c FROM Country_Area_Code__mdt';
		if(countryName != null) {
			countryName = BPUtility.escapeSingleQuotes(countryName);
			query += ' WHERE Country__c =: countryName';
		}
		query += ' ORDER BY Label ASC';
		query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
		
		List<Country_Area_Code__mdt> countryWithAreaCodeList = Database.query(query);
		if (countryWithAreaCodeList.size() > 0){
		areaCode = countryWithAreaCodeList[0].Area_Code__c;
		
		return areaCode;
		}
		else {
			return null;
		}
		
	}
	
}