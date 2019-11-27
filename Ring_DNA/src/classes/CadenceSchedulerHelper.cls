public class CadenceSchedulerHelper {
	public  static List<AsyncApexJob> getAllBatchJobs(Map<String, Set<String>> fieldNameToFieldValueSetMap){
        String query = 'SELECT Id, ApexClass.Name FROM AsyncApexJob WHERE JobType = \'BatchApex\'';
        
        Boolean isWhereClauseAdded = true;
        for(String fieldName : fieldNameToFieldValueSetMap.keySet()) {
        	String fieldValueSetStr = '(';
            for(String fieldValue : fieldNameToFieldValueSetMap.get(fieldName)){
                if(fieldValue != null){
                    fieldValueSetStr += '\'' + fieldValue + '\'' + ',';
                }
            }
            fieldValueSetStr = fieldValueSetStr.subString(0, fieldValueSetStr.length() - 1);
            fieldValueSetStr += ')';
                
            if(String.isNotBlank(fieldName)) {
            	fieldName = String.escapeSingleQuotes(fieldName);
            	if(isWhereClauseAdded) {
	                query += ' AND ' + fieldName + ' IN ' + fieldValueSetStr;
	            } else {
	                query += ' WHERE ' + fieldName + ' IN ' + fieldValueSetStr;
	                isWhereClauseAdded = true;
	            }
            }
        }
        return DataBase.query(query);
	}
}