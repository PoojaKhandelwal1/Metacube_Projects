/** 
* Author: Tarun Khandelwal
* Since: May 16, 2018 
* Name: SchedulerSOQLUtil 
* Description: Apex class which contains all SOQL related operation for Scheduler
**/
public without sharing class SchedulerSOQLUtil {
	
	public static List<Event> getAppointmentWithIds(Set<String> appointmentIdSet) {
        String query = 'SELECT '; 
        for(String fieldsName : AppointmentWrapper.getAppointmentFieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Event' + (appointmentIdSet != null && appointmentIdSet.size() > 0 ? ' WHERE Id In: appointmentIdSet' : '');
       
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        List<Event> eventList = Database.query(query);
        return eventList;
    }
    
    public static List<Event> getAppointmentWithinPeriod(DateTime fromDate, DateTime toDate) {
    	String query = 'SELECT ';
        for(String fieldsName : AppointmentDayWrapper.getAppointmentFieldsList()) {
        	fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Event WHERE Type = \'Appointment\' AND StartDateTime >= :fromDate AND StartDateTime <= :toDate';
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Technician__c> getTechnicianList(DateTime toDateTime) {
        Date toDate = date.newinstance(toDateTime.year(), toDateTime.month(), toDateTime.day());
        DateTime nextDate = toDateTime.addDays(1);
        String query = 'SELECT ';  
        for(String fieldsName : TechnicianDetailWrapper.getTechnicianFieldsList()) {
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';  
        }
        
        // Leaves Child Query
        query += '(SELECT ';  
        for(String fieldName : LeaveWrapper.getLeaveFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Leaves__r WHERE (From_Date__c <= : toDate AND To_Date__c >=: toDate) Order BY From__c ASC), ' ;
        
        // Activity Child Query
        query += '(SELECT ';
        for(String fieldName : AppointmentWrapper.getAppointmentFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Activities__r WHERE StartDateTime >= : toDateTime AND StartDateTime < :nextDate AND Estimated_Hours__c > 0) '; 
        
        query += ' From Technician__c WHERE Type__c = \'Technician\' AND Active__c = true';
        if(AccessControl.ifObjectFieldIsAccessible('Technician__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Event> getAppoitmentList(Map<String, List<String>> fieldValueToOperatorAndFieldValueListMap, DateTime currentDate) {
        String query = 'SELECT ';  
        for(String fieldName : AppointmentWrapper.getAppointmentFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        DateTime nextDate = currentDate.addDays(1);
        
        query += ' From Event WHERE Type = \'Appointment\' AND StartDateTime >= :currentDate AND StartDateTime <= :nextDate ';
        for(String fieldName : fieldValueToOperatorAndFieldValueListMap.keySet()) {
            List<String> fieldList = fieldValueToOperatorAndFieldValueListMap.get(fieldName);
            if(fieldList.size() == 2) {
                if(fieldList[1] == null) {
	                query += ' AND ' + fieldName + fieldList[0] + ' null ';
	            } else {
	                query += ' AND ' + fieldName + fieldList[0] + '\'' + fieldList[1] + '\'';
	            }
            }
            
        }
        query += ' ORDER BY StartDateTime ASC';
        
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
    
    public static List<Event> getAppointmentListBySOId(List<Id> sectionIdList) {
    	String query = 'SELECT ';
        for(String fieldName : AppointmentWrapper.getAppointmentFieldsList()) {
            fieldName = BPUtility.escapeSingleQuotes(fieldName);
            query += fieldName + ', ';  
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM Event WHERE Service_Order_Header__c IN: sectionIdList';
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        return Database.query(query);
    }
}