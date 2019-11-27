/**
 * Author: Tarun Khandelwal
 * Since: July 09, 2016
 * Name: BPUtility
 * Description: Utility class which is used for generic methods used in application
**/
public with sharing class BPUtility {
    
    public static String getDecodedString(String str) {
    	if(String.isBlank(str)) {
			return str;
		}
    	return (EncodingUtil.base64Decode(str) != null) ? EncodingUtil.base64Decode(str).toString() : null;
    }
	
	public static String getEncodedString(String str) {
		if(String.isBlank(str)) {
			return str;
		}
    	return getEncodedStr(Blob.valueOf(str));
    }
	    
    public static String getEncodedStr(Blob blobStr) {
    	return EncodingUtil.base64Encode(blobStr);
    }
    
    public static String escapeSingleQuotes(String inputStr) {
    	if(String.isNotBlank(inputStr)) {
    		inputStr = String.escapeSingleQuotes(inputStr);
    	}
    	return inputStr;
    }
    
    public static Map<String, String> objectAPINameToActiveFlagAPIName = 
    				new Map<String, String> {'Account' => 'Active__c',
    										 'Customer' => 'Active__c',
    										 'Vendor' => 'Active__c',
			    							 Constants.NAMESPACE + 'Part__c' => 'Active__c',
			    							 Constants.NAMESPACE + 'Labour_Code__c' => 'Active__c',
			    							 Constants.NAMESPACE + 'Fee__c' => 'Active__c',
			    							 Constants.NAMESPACE + 'Kit_Header__c' => 'Active__c',
			    							 Constants.NAMESPACE + 'Category__c' => 'Active__c',
			    							 Constants.NAMESPACE + 'Price_Level__c' => 'Active__c',
			    							 Constants.NAMESPACE + 'Sales_Tax__c' => 'Active__c',
			    							 Constants.NAMESPACE + 'Sales_Tax_Item__c' => 'Active__c'
			    		}; 
    
    public static String getFormatedDateTime(Date dateToConvert) {
        return BPUtility.getFormatedDateTime(datetime.newInstance(dateToConvert.year(), dateToConvert.month(), dateToConvert.day()) );
    }
                        
  	public static String getFormatedDateTime(DateTime dateRec){
    	String userLocale = UserInfo.getLocale();
    	if(!Constants.localeToDateTimeFmtMap.containsKey(userLocale)){
    		return dateRec.format(Constants.localeToDateTimeFmtMap.get('en_US'));
    	}
    	return dateRec.format(Constants.localeToDateTimeFmtMap.get(userLocale));
    }
    
    public static String getFormatedDateAndTime(datetime dateRec){
    	String userLocale = UserInfo.getLocale();
    	if(!Constants.localeToDateTimeFmtMap.containsKey(userLocale)){
    		return dateRec.format(Constants.localeToDateAndTimeFmtMap.get('en_US'));
    	}
    	return dateRec.format(Constants.localeToDateAndTimeFmtMap.get(userLocale));
    }
    
    public static String getDateFormat(){
   		String userLocale = UserInfo.getLocale();
   		if(!Constants.localeToDateTimeFmtOnPageMap.containsKey(userLocale)){
    		return Constants.localeToDateTimeFmtOnPageMap.get('en_US');
    	}
   		return Constants.localeToDateTimeFmtOnPageMap.get(userLocale);
   	
   			
   }
   
   public static String getExtendedDateFormat(datetime dateRec){
   		String userLocale = UserInfo.getLocale();
   		if(!Constants.localeToDateTimeMonthFmt.containsKey(userLocale)){
    		return dateRec.format(Constants.localeToDateTimeMonthFmt.get('en_US'));
    	}
   		return  dateRec.format(Constants.localeToDateTimeMonthFmt.get(userLocale));
   			
   } 
   
   public static String getExtendedDateFormatWithoutTime(datetime dateRec){
   		String userLocale = UserInfo.getLocale();
   		if(!Constants.localeToDateTimeMonthFmt.containsKey(userLocale)){
   			
    		return dateRec.format(Constants.localeToDateTimeMonthFmt.get('en_US').substring(0,Constants.localeToDateTimeMonthFmt.get('en_US').length()-8));
    	}
   		return  dateRec.format(Constants.localeToDateTimeMonthFmt.get(userLocale).substring(0,Constants.localeToDateTimeMonthFmt.get('en_US').length()-8));
   			
   }
   
   public static String getExtendedMonthFormat(datetime dateRec){
   		String userLocale = UserInfo.getLocale();
   		if(!Constants.localeToDateMonthTimeFmtMap.containsKey(userLocale)){
   			
    		return dateRec.format(Constants.localeToDateMonthTimeFmtMap.get('en_US'));
    	}
   		return  dateRec.format(Constants.localeToDateMonthTimeFmtMap.get(userLocale));
   			
   } 
   public static String getExtendedTimeMonthFormat(datetime dateRec){
   		String userLocale = UserInfo.getLocale();
   		if(!Constants.localeToDateTimeExtendedMonthFmt.containsKey(userLocale)){
    		return dateRec.format(Constants.localeToDateTimeExtendedMonthFmt.get('en_US'));
    	}
   		return  dateRec.format(Constants.localeToDateTimeExtendedMonthFmt.get(userLocale));
   			
   } 
   
   public static String getExportFormatedDateTime(datetime dateRec){
    	String userLocale = UserInfo.getLocale();
    	//Constants.localeToDateTimeFmtMap.get(userLocale);
    	if(!Constants.localeToExportFmtMap.containsKey(userLocale)){
    		return dateRec.format(Constants.localeToExportFmtMap.get('en_US'));
    	}
    	return dateRec.format(Constants.localeToExportFmtMap.get(userLocale));
    }
   
    
    public static DateTime createDateTimeFromStr(DateTime dtValue, String timeStr) {
        if(String.isNotBlank(timeStr)) {
            List<String> timeSubStrList = timeStr.split(' ');
            if(timeSubStrList.size() > 1) {
                Integer hoursValue = Integer.valueOf(timeSubStrList[0].split(':')[0]);
                hoursValue = (hoursValue == 12) ? (hoursValue - 12) : hoursValue; 
                dtValue = dtValue.addHours(hoursValue);
                dtValue = dtValue.addMinutes(Integer.valueOf(timeSubStrList[0].split(':')[1]));
                
                if(timeSubStrList[1] == 'PM') {
                    dtValue = dtValue.addHours(12);
                }
            }
        }
        return dtValue;
    }
    
    public static String convertListIntoString(List<String> strList) {
        String returnStr = '';
        if(strList.size() == 0) { 
            returnStr = null;
        }
        for(String subStr : strList) {
            subStr = (subStr.contains('\n')) ? subStr.replaceAll('\n', '') : subStr;
            returnStr += (subStr != null) ? (subStr + '\n') : '';
        }
        return returnStr;
    }
    
     public static String getCurrentUserTZSIDKey() {
        List<User> userList = [Select TimeZoneSidKey FROM User where Id =: UserInfo.getUserId()];
        return userList[0].TimeZoneSidKey;
    }
    
   	public static String getSectionNameBySectionId(String sectionId) {
   		String objectName = (Id.valueOf(sectionId)).getSObjectType().getDescribe().getName();
        if(!objectNameToSectionNameMap.containsKey(objectName)) {
            return '';
        }
        return objectNameToSectionNameMap.get(objectName);
   	}
    
    public static Map<String, String> objectNameToSectionNameMap = new Map<String, String>{
        Constants.NAMESPACE + 'Service_Order_Header__c' => 'Service',
        Constants.NAMESPACE + 'Deal__c' => 'Deal',
        Constants.NAMESPACE + 'Deal_Finance__c' => 'Financing',
        Constants.NAMESPACE + 'Product__c' => 'Vendor product',
        Constants.NAMESPACE + 'CO_Header__c' => 'All'
    };
    
    public static Map<String, String> getLocaleStaticResourceData() {
        Map<String, String> localizedMap = new Map<String, String>();
        String userLocale = UserInfo.getLocale();
        List<StaticResource> staticResourceList = [SELECT SystemModStamp FROM StaticResource WHERE Name = 'Locale' limit 1];
        if(staticResourceList.size() > 0) {
            String urlFileRef = '/resource/' + String.valueOf(((DateTime)staticResourceList[0].get('SystemModStamp')).getTime())
                            + '/Locale/locale-' + userLocale + '.json';
	        PageReference pageRef = new PageReference(urlFileRef);
	        String resJsonBody;
	        try {
	        	if(!Test.isRunningTest()) {
	        		resJsonBody = pageRef.getContent().toString().replaceAll('\UFEFF', '');
	        	} else {
	        		resJsonBody = '{"Test" : "Test"}';
	        	}
	        } catch(Exception e) {
	            urlFileRef = '/resource/' + String.valueOf(((DateTime)staticResourceList[0].get('SystemModStamp')).getTime())
                            + '/Locale/locale-en_US.json';
                pageRef = new PageReference(urlFileRef);
                resJsonBody = pageRef.getContent().toString().replaceAll('\UFEFF', '');
	        }
	        localizedMap = (Map<String, String>) system.JSON.deserialize(resJsonBody, Map<String, String>.class);
        }
		return localizedMap;
    }
    
    /* This method is used to add idle time to salesforce execution similar to a thread sleep
    *  accepts a integer value of delay interval in milliseconds  
    */
    public static void sleepSystem(Integer delayInMilliseconds) {
        Long startingTime = System.now().getTime();
        delayInMilliseconds = delayInMilliseconds != null ? delayInMilliseconds : 0;  
        while (System.now().getTime() - startingTime < delayInMilliseconds)  {
                    // Do nothing until desired delay has passed
         }
    }
    
    /*
    * to format a date into a date string with separator passed as argument
    * like : dd(Separator)MM(Separator)YYYY
    */
    public static String getFormatedDateTimewithSeparator(Date dateObj, String separator) {
       String dateString =  BPUtility.getFormatedDateTime(datetime.newInstance(dateObj.year(), dateObj.month(), dateObj.day()) );
       return dateString.replace('/', separator);
    }
}