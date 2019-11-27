public with sharing class CadenceUtil {

	public static String nameSpace = CadenceConstants.NAMESPACE;
	public static List<String> getFormattedExpressoion(String input){

		input = input.deleteWhitespace();
		List<String> stringsToMatch = new List<String>{'AND', 'and', 'or', 'OR'};
		String tempStr = '';
		List<String> formattedStr = new List<String>(); 
		Boolean isValid = false;
		for(String c: input.split('')){
			if(c.equalsIgnoreCase('A') || c.equalsIgnoreCase('N')|| c.equalsIgnoreCase('D')
					|| c.equalsIgnoreCase('O') || c.equalsIgnoreCase('R')
					){
				tempStr = tempStr + c;
				if(stringsToMatch.contains(tempStr)){
					formattedStr.add(tempStr);
					tempStr='';
				}
			}
			else if(c.equals('(') || c.equals(')') || c.isNumeric()){
				formattedStr.add(c);
			}
		}

		return formattedStr;
	}

	public static List<String> infixToPostfixConversion(List<String> expression){
		Stack stack = new Stack();
		List<String> postfixExp = new List<String>();
		Integer count = 0;
		for(String s: expression){
			count++;
			if(s.isNumeric()){
				postfixExp.add(s);
			}
			else if((stack.isEmpty() || stack.peek().equals('(')) && (s.equalsIgnoreCase('AND') || s.equalsIgnoreCase('OR'))){
				stack.push(s);
			}

			else if(s.equals('(')) stack.push(s);
			else if(s.equals(')')){
				String lp = '';
				while(lp!='('){
					lp = (String)stack.pop(); 
					if(lp!='(') postfixExp.add(lp);
				} 
			} 
			else if(s.equalsIgnoreCase('AND') || s.equalsIgnoreCase('OR')){
				if(!stack.isEmpty() && (String.valueOf(stack.peek()).equalsIgnoreCase('OR') || String.valueOf(stack.peek()).equalsIgnoreCase('AND'))){
					stack.push(s);
				} 
			}
			if(count==expression.size()){
				while(!stack.isEmpty() && !(String.valueOf(stack.peek()).equals('(') || String.valueOf(stack.peek()).equals(')'))){
					postfixExp.add(String.valueOf(stack.pop()));
				} 
			}
		}
		if(!stack.isEmpty()){
			throw new CustomException('Criteria is not valid');
		}

		return postfixExp;

	}

	public static Map<String, String> getTimeDiff(DateTime newTime, DateTime oldTime ){
		Map<String, String> tdMap = new Map<String, String>();
		long  millseconds= newTime.getTime() - oldTime.getTime();
		long seconds = millseconds/1000;
		Integer min = Integer.valueof(seconds/60);
		Integer hour = min/60;
		Integer day = hour/24;
		tdMap.put('day' , String.ValueOf(day));
		hour = hour - 24* day;
		tdMap.put('hour' , String.ValueOf(hour));
		return tdMap;
	}

	public static DateTime addTimeInDate(DateTime givenDate, Integer days, Integer hours) {
		if(days != null && givenDate != null) {
			givenDate = givenDate.addDays(days);    
		}
		if(hours != null && givenDate != null) {
			givenDate = givenDate.addHours(hours);
		}
		return givenDate; 
	} 


	/**
	 * @description Get object fields data types map.
	 * @param objType - Object type to get object fields info
	 * @param fields - Set of fields for which we need data type
	 * @return Map of field name to data type.
	 */
	public static Map<String, list<String>> getObjectFieldsType(String objType) {

		Map<String, list<String>> objectFieldDataTypeMap = new Map<String, list<String>>();

		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
		for(String fieldName : fieldMap.keySet()) {
			list<String> apiList = new list<String>();
			String dataType = fieldMap.get(fieldName).getDescribe().getType().name();
			Schema.sObjectField fieldAPIName = fieldMap.get(fieldName);
			//String nameLable = fieldAPIName.getDescribe().getLabel();
			String nameLable = fieldAPIName.getDescribe().getName();
			apiList.add(fieldAPIName.getDescribe().getName());
			apiList.add(dataType);
			objectFieldDataTypeMap.put(nameLable, apiList);
		}
		return objectFieldDataTypeMap;
	}

	/**
	 * @description Get object fields data types map.
	 * @param obj - Object to set value
	 * @param fieldName - field to update
	 * @param value- value to update in obj field
	 * @param fieldType - type of field in sf
	 */
	public static void updateFieldValue(SObject obj, String fieldName, Object value, String fieldType) {
		if(fieldType.equalsIgnoreCase('currency') || fieldType.equalsIgnoreCase('double') || fieldType.equalsIgnoreCase('percent') || fieldType.equalsIgnoreCase('decimal')) {
			obj.put(fieldName, Decimal.valueOf(String.valueOf(value))); 
		} else if(fieldType.equalsIgnoreCase('boolean')) {
			obj.put(fieldName, Boolean.valueOf(value));
		} else if(fieldType.equalsIgnoreCase('date')) {
			obj.put(fieldName, date.valueOf(String.valueOf(value)));
		} else if(fieldType.equalsIgnoreCase('datetime')) {
			DateTimeCriterionEvaluator dtEval = new DateTimeCriterionEvaluator();
			obj.put(fieldName, dtEval.getDateTime(value)); 
		} else if(fieldType.equalsIgnoreCase('integer')) {
			obj.put(fieldName, (Integer.valueOf(value)));
		} else if(fieldType.equalsIgnoreCase('reference')){
			obj.put(fieldName, (ID)value);
		} else {
			obj.put(fieldName, (string)value);
		}   
	}
	/**
	 * @description - Create query to get sobject data.
	 * @param objType - sObject name string
	 * @param sObjectIdList - SObject ids list.
	 */
	public static String getObjectQuery(String objType , List<Id> sObjectIdList){

		Set<String> allowedFields = new Set<String>();
		String query = 'Select ';
		Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
		for (Schema.SObjectField field : fieldMap.values()) {
			Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			if (!fieldDescribe.isAccessible()) {
				continue; 
			}
			String fieldName = fieldDescribe.getName();
			allowedFields.add(fieldName);
		}

		if(allowedFields.size() > 0 && nameSpace != ''){
			String apiNameWithNamespace;
			for(String fld : allowedFields){
				apiNameWithNamespace = nameSpace + fld;
				if(allowedFields.contains(apiNameWithNamespace)){
					allowedFields.remove(fld); 
				}
			}
		}

		query += String.join(new List<String>(allowedFields), ',');
		query += ' FROM '+ objType + ' WHERE id  in  :sObjectIdList';
		return query;
	} 
	/**
	 * @description - Used to schedule cadenceScheduler.
	 * @param nextScheduleTime - Next schedule time
	 */
	public static void scheduleNextCadenceScheduler(Integer nextScheduleTime){
		dateTime currentDateTime = system.now();
		dateTime NextScheduleDateTime = currentDateTime.addMinutes(nextScheduleTime);
		String day = string.valueOf(NextScheduleDateTime.day());
		String month = string.valueOf(NextScheduleDateTime.month());
		String hour = string.valueOf(NextScheduleDateTime.hour());
		String minute = string.valueOf(NextScheduleDateTime.minute());
		String second = string.valueOf(NextScheduleDateTime.second());
		String year = string.valueOf(NextScheduleDateTime.year());

		String strJobName = 'Cadence-' + second + '_' + minute + '_' + hour + '_' + day + '_' + month + '_' + year;
		String strSchedule = '0 ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;

		System.schedule(strJobName, strSchedule, new CadenceScheduler());
		CadenceUtil.removeDeletedSchedulerRecords();
	}
	/**
	 * @description - Used to start cadenceScheduler.
	 */
	public static void startCadenceScheduler(){
		Integer nextScheduleTime = 1;
		List<CronTrigger> crTr = [SELECT Id,CronJobDetail.Name,CronJobDetail.Id,State FROM CronTrigger  where State != 'DELETED' AND CronJobDetail.Name LIKE '%Cadence%']; 
		if (!(crTr.size() > 0)){
			CadenceUtil.scheduleNextCadenceScheduler(nextScheduleTime);  
		}
	} 
	public static void removeDeletedSchedulerRecords(){
		List<CronTrigger> cronstodelete = [Select Id ,State from CronTrigger where State = 'DELETED'];
		for(CronTrigger CT: cronstodelete){
			System.abortjob(CT.Id);        
		}
	}
	public  static Integer getAllRunningBatch(){
		return [SELECT COUNT() FROM AsyncApexJob WHERE JobType='BatchApex' AND ApexClass.Name = 'PerformCadenceActionBatch'  AND Status IN ('Processing','Preparing','Queued')] ;
	}

	public static String getSObjectQuery(String objType){
		Set<String> allowedFields = new Set<String>();
		Map<String, Schema.SObjectField> fieldMap;
		String query = 'Select ';
		try {
			fieldMap = Schema.getGlobalDescribe().get(objType).getDescribe().fields.getMap();
		} catch(Exception e) {
			return null;
		}
		for (Schema.SObjectField field : fieldMap.values()) {
			Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
			if (!fieldDescribe.isAccessible()) {
				continue; 
			}
			String fieldName = fieldDescribe.getName();
			allowedFields.add(fieldName);
		}

		if(allowedFields.size() > 0 && nameSpace != ''){
			String apiNameWithNamespace;
			for(String fld : allowedFields){
				apiNameWithNamespace = nameSpace + fld;
				if(allowedFields.contains(apiNameWithNamespace)){
					allowedFields.remove(fld); 
				}
			}
		}

		query += String.join(new List<String>(allowedFields), ',');
		query += ' FROM '+ objType + ' ';
		return query;
	}

	/**
	 * @description - Use this method to check any object has access on perticular org.
	 * @param objList - List of object
	 * @return List<String> - list of valid object on org.
	 */
	public static List<String> getValidSObjectListInOrg(List<String> objList){
		List<String> sObjectList = new List<string>();
		for(String obj : objList){
			for (Schema.SObjectType sObjectType : Schema.getGlobalDescribe().values()) {
				String sobjName = String.valueOf(sObjectType);
				if(sobjName.contains(obj) ) {
					sObjectList.add(obj);
					break;
				}
			}
		}
		return sObjectList;
	}

	/**
	 * @description - This method return set of ids in comma seprated for where clause in SOQL.
	 * @param List<Id> - List of Ids
	 * @return String - Condition for where clause.
	 */
	public static String getWhereClauseForListOfIds(List<Id> ids){
		string  whereClause = '(';
		for(Id obj : ids){
			whereClause = whereClause + '\'' + String.valueOf(obj)  + '\',' ;
		}
		if(whereClause.length() > 1){
			whereClause = whereClause.removeEnd(',') + ')';
		}
		if(whereClause == '('){
			whereClause = '';
		}
		return whereClause;
	}
}