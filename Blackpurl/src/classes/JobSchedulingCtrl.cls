/**
 * Author: Pooja Khandelwal
 * Since: Jul 27, 2017
 * Name: JobSchedulingCtrl
 * Description: Apex class to handle schedule event calendar related oprations of Job Schedule 
 **/
 global without sharing class JobSchedulingCtrl{
    
    private static DateTime StartCalendarViewDateTime;
    private static DateTime EndCalendarViewDateTime;
    private static JobSchedulingWrapper eventJsonObj;
    public string SchedulingDateFormat { get{return Constants.localeToschedulingDateFmtMap.containsKey(UserInfo.getLocale())? Constants.localeToschedulingDateFmtMap.get(UserInfo.getLocale()): Constants.localeToschedulingDateFmtMap.get('en_US'); } private set;}
    public Decimal SchedulingStartDay { get{return GeneralConfiguration.getSchedulerStartDay(); } private set;}
    global JobSchedulingCtrl(NewHomePageCtrl controller){}
    public JobSchedulingCtrl() {} 
    
    //Depricated 
    @remoteAction
    global static String loadJobSchedulingEvents(){
        return BPUtility.getEncodedString('');
    }
     
    @remoteAction
    global static String loadSchedulingEvents(String eventJson){
        eventJson = BPUtility.getDecodedString(eventJson);
        if(AccessControl.ifObjectFieldIsAccessible('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
        try {
            eventJsonObj = (JobSchedulingWrapper)System.JSON.deserialize(eventJson, JobSchedulingWrapper.class);
            if(eventJsonObj.StartCalendarViewDate != null && eventJsonObj.StartCalendarViewDate != '') {
                if(eventJsonObj.StartCalendarViewTime != null && eventJsonObj.StartCalendarViewTime != '') {
                    StartCalendarViewDateTime = getConvertedDateTime(eventJsonObj.StartCalendarViewDate, eventJsonObj.StartCalendarViewTime);
                } else {
                    StartCalendarViewDateTime = getConvertedDateTime(eventJsonObj.StartCalendarViewDate, '12:00AM');
                }
            }
            if(eventJsonObj.EndCalendarViewDate != null && eventJsonObj.EndCalendarViewDate != '') {
                if(eventJsonObj.EndCalendarViewTime != null && eventJsonObj.EndCalendarViewTime != '') {
                    EndCalendarViewDateTime = getConvertedDateTime(eventJsonObj.EndCalendarViewDate, eventJsonObj.EndCalendarViewTime);
                } else {
                    EndCalendarViewDateTime = getConvertedDateTime(eventJsonObj.EndCalendarViewDate, '11:59PM');
                }
            }
            String JSONString;
            if(eventJsonObj.Id != null) {
                List<Event> eventList = getEventWithId();
                List<JobSchedulingWrapper> eventListJson = new List<JobSchedulingWrapper>();
                if(eventList.size() > 0) {
                    if(!eventList[0].IsMultiDayEvent__c) {
                        eventListJson.add(new JobSchedulingWrapper(eventList[0]));
                    } else {
                        eventListJson.add(new JobSchedulingWrapper(eventList[0], StartCalendarViewDateTime, EndCalendarViewDateTime));
                    }
                }
                JSONString = System.JSON.serialize(eventListJson);
            } else {
                List<JobSchedulingWrapper> eventListJson = new List<JobSchedulingWrapper>();
                List<JobSchedulingWrapper> allDayEventListJson = new List<JobSchedulingWrapper>();
                
                if(eventJsonObj.AppointmentFilter || eventJsonObj.AppointmentwithserviceFilter || eventJsonObj.ReminderFilter){
                    if(eventJsonObj.CurrentView != 'Month'){
                        List<Event> eventList = getEvents(false);
                        for(Event event: eventList) {
                            eventListJson.add(new JobSchedulingWrapper(event));
                        }
                        
                        List<Event>  allDayEventList = getEvents(true);
                        for(Event allDayevent: allDayEventList) {
                            allDayEventListJson.add(new JobSchedulingWrapper(allDayevent, StartCalendarViewDateTime, EndCalendarViewDateTime));
                        }
                    }else{
                        List<Event> eventList = getEvents(false);
                        for(Event event: eventList) {
                            eventListJson.add(new JobSchedulingWrapper(event));
                        }
                        
                        List<Event> eventListAllday = getEvents(true);
                        Datetime startdate ;
                        Datetime enddate ;
                        Integer dateDiff;
                        for(Event eventRec : eventListAllday) {
                                    dateDiff =   (eventRec.StartDateTime.date()).daysBetween(eventRec.EndDateTime.date()) + 1 ;
                                    startdate = eventRec.StartDateTime.date();
                                    for(integer i =1 ; i <= dateDiff;i++ ){
                                        startdate = startdate;
                                        enddate = startdate;
                                        Event  objEvent= new Event();
                                        objEvent = eventRec;
                                        objEvent.StartDateTime = startdate;
                                        objEvent.EndDateTime = enddate;
                                        eventListJson.add(new JobSchedulingWrapper(objEvent));
                                        startdate = enddate.addDays(1);
                                   
                            }   
                        }
                    
                    
                    } 
                }
                List<List<JobSchedulingWrapper>>  allEventList = new List<List<JobSchedulingWrapper>>();
                allEventList.add(eventListJson);
                allEventList.add(allDayEventListJson);
                JSONString = System.JSON.serialize(allEventList);
            }
            return BPUtility.getEncodedString(JSONString);
        } catch(exception ex){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
            return BPUtility.getEncodedString('');
        } 
    }
    
    private static List<Event> getEvents(Boolean isAllDayEvent){
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : JobSchedulingWrapper.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Event WHERE IsMultiDayEvent__c =: isAllDayEvent';
        String eventId = eventJsonObj.Id;
        Integer calendarViewMonthNumber = eventJsonObj.CalendarViewMonthNumber;
       
        if(!isAllDayEvent) {
            if((eventJsonObj.CurrentView == 'Week' || eventJsonObj.CurrentView == '3 Days' || eventJsonObj.CurrentView == 'Day' ) &&
                      eventJsonObj.StartCalendarViewDate != null && eventJsonObj.EndCalendarViewDate != null){
                query += ' AND (StartDateTime >=: StartCalendarViewDateTime AND EndDateTime <=: EndCalendarViewDateTime)';
            } else if(eventJsonObj.CurrentView == 'Month' && calendarViewMonthNumber > 0)    {
                query += ' AND (CALENDAR_MONTH(StartDateTime) =: calendarViewMonthNumber OR CALENDAR_MONTH(EndDateTime) =: calendarViewMonthNumber)';
            }
        } else {
            if((eventJsonObj.CurrentView == 'Week' || eventJsonObj.CurrentView == '3 Days' || eventJsonObj.CurrentView == 'Day' ) &&
                      eventJsonObj.StartCalendarViewDate != null && eventJsonObj.EndCalendarViewDate != null){
                query += ' AND (StartDateTime <=: EndCalendarViewDateTime AND EndDateTime >=: StartCalendarViewDateTime)';
            } else if(eventJsonObj.CurrentView == 'Month' && calendarViewMonthNumber > 0)    {
                 query += ' AND (StartDateTime <=: EndCalendarViewDateTime AND EndDateTime >=: StartCalendarViewDateTime)';
            }
        }
        
        /**if(eventJsonObj.ViewAllFilter == false){
            query += ' AND (';
        }*/
        
        if(eventJsonObj.AppointmentFilter || eventJsonObj.AppointmentwithserviceFilter || eventJsonObj.ReminderFilter){
            query += ' AND (';
        }
        
        if(eventJsonObj.AppointmentFilter == true)  {
            query += ' (type = \'Appointment\'';
            if(eventJsonObj.AppointmentwithserviceFilter == true)   {
                query += ')';
            }else {
                query += ' AND WhatId = null)';
            }
            
            if(eventJsonObj.ReminderFilter == true) {
                query += 'OR type = \'Reminder\'';
            }
            query += ')';
        }else if(eventJsonObj.ReminderFilter == true)   { 
            query += ' type = \'Reminder\'';
            if(eventJsonObj.AppointmentwithserviceFilter == true)   {
                query += ' OR (type = \'Appointment\' AND WhatId != null)';
            }
            query += ')';
        }else if(eventJsonObj.AppointmentwithserviceFilter == true) {
            query += ' type = \'Appointment\' AND WhatId != null';
            query += ')';
        }
        
        if(eventJsonObj.Id == null){
            query += ' ORDER BY StartDateTime, EndDateTime, type';
        }
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        
        List<Event> eventList = Database.query(query);
        
        //system.assert(false, eventList);
        
        return eventList;
    }
    
    private static List<Event> getEventWithId(){
        String query;   
        query = 'SELECT '; 
        for(String fieldsName : JobSchedulingWrapper.fieldsList()){
            fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
            query += fieldsName + ', ';
        }
        query = query.substring(0, query.length()-2);
        query += ' FROM  Event';
        String eventId = eventJsonObj.Id;
       
        if(eventJsonObj.Id != null) {
            query += ' WHERE Id =: eventId';
        }
        
        query += ' LIMIT ' + SOQLUtil.getAvailableQueryRowsLimit();
        List<Event> eventList = Database.query(query);
        return eventList;
    }
    
    
    @remoteAction
    global static String saveJobSchedulingEvent(String eventJson){
        if(AccessControl.ifObjectFieldIsCreateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
        if(AccessControl.ifObjectFieldIsUpdateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }

        eventJson = BPUtility.getDecodedString(eventJson);
        try{
            
            JobSchedulingWrapper eventJsonObj = (JobSchedulingWrapper)System.JSON.deserialize(eventJson, JobSchedulingWrapper.class);
            
            DateTime StartDateTime;
            DateTime EndDateTime;
            
            if(eventJsonObj.StartDate != null && eventJsonObj.StartDate != '' &&
                eventJsonObj.ActualStartTime != null && eventJsonObj.ActualStartTime != '') {
                StartDateTime = getConvertedDateTime(eventJsonObj.StartDate, eventJsonObj.ActualStartTime);
            }
            
            if(eventJsonObj.EndDate != null && eventJsonObj.EndDate != '' && 
                eventJsonObj.ActualEndTime != null && eventJsonObj.ActualEndTime != '') {
                EndDateTime = getConvertedDateTime(eventJsonObj.EndDate, eventJsonObj.ActualEndTime);
            }
            
           
            
            Event eventObj = new Event();
            eventObj.Subject = 'Meeting'; 
            eventObj.type = eventJsonObj.Type;
            
            if(eventJsonObj.Title == null || eventJsonObj.Title == '')  {
                eventJsonObj.Title = 'no title';
            }
            eventObj.title__c = eventJsonObj.Title;

            Integer notesFieldMaxLength = 255;
            if(eventJsonObj.Notes.length() > notesFieldMaxLength) {
                eventObj.Notes__c = eventJsonObj.Notes.substring(0, (notesFieldMaxLength - 1));
                eventObj.AdditionalNotes__c = eventJsonObj.Notes.substring(notesFieldMaxLength, (eventJsonObj.Notes.length() - 1));
            } else {
                eventObj.Notes__c = eventJsonObj.Notes;
            }
            
            eventObj.StartDateTime = StartDateTime;
            eventObj.EndDateTime = EndDateTime;
            eventObj.Id = eventJsonObj.Id;
            //system.assert(false,eventObj.StartDateTime +' '+ eventObj.EndDateTime);
            // Added by gourav for allDayEvent checkbox on 10-08-17
             if( StartDateTime != null && EndDateTime != null){
                boolean dueStart = StartDateTime.isSameDay(EndDateTime);
                if(dueStart == false){
                    eventObj.IsMultiDayEvent__c = true;
                    
                }
            }
            
            if(eventObj.Id == null) { 
                if(AccessControl.ifObjectFieldIsCreateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            } else {
                if(AccessControl.ifObjectFieldIsUpdateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
            }
            upsert eventObj;
            
            String ScheduleEventList =  loadSchedulingEvents(BPUtility.getEncodedString(eventJson));     
            return ScheduleEventList;
        }catch(exception ex){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
            return BPUtility.getEncodedString('');
        } 
    }
    
    @remoteAction
    global static String deleteJobSchedulingEvent(String eventId, String eventJson){
        eventId = BPUtility.getDecodedString(eventId);
        try{
            if(AccessControl.ifObjectIsDeletable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
            Event eventObj = new Event();
            eventObj.Id = eventId;
            delete eventObj;
            
            String ScheduleEventList =  loadSchedulingEvents(eventJson);     
            return ScheduleEventList;
        }catch(exception ex){
            throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
            return BPUtility.getEncodedString('');
        } 
    }
    
    @RemoteAction
    global static void addServiceJobForJobScheduling(String eventJson) {
        eventJson = BPUtility.getDecodedString(eventJson);
        try{
            JobSchedulingWrapper eventJsonObj = (JobSchedulingWrapper)System.JSON.deserialize(eventJson, JobSchedulingWrapper.class);
            //System.assert(false,eventJsonObj );
            if(eventJsonObj.Id != null && eventJsonObj.COHeaderId != null)  {
                if(AccessControl.ifObjectFieldIsCreateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_CREATEABLE); }
                if(AccessControl.ifObjectFieldIsUpdateable('Event') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_UPDATEABLE); }
                
                Event eventObj = new Event();
                eventObj.Id = eventJsonObj.Id;
                eventObj.WhatId = eventJsonObj.COHeaderId;
                upsert eventObj;
            }
        }catch(exception ex){
            //System.assert(false,'error' + ex );
            throw new BlackPurlException(BlackPurlException.getErrorMessage(ex.getMessage(), ex.getStackTraceString()));
        } 
    }
    
    @RemoteAction
    global static String getServiceJobDetailsForForJobScheduling(String coHeaderId) {
        coHeaderId = BPUtility.getDecodedString(coHeaderId);
        try{
            if(AccessControl.ifObjectFieldIsAccessible('CO_Header__c') == false) { throw new BlackPurlException(Constants.OBJIECT_NOT_ACCESSIBLE); }
            
            String query;   
            query = 'SELECT '; 
            //fields of CO Header
            for(String fieldsName : JobSchedulingWrapper.getCOHeaderfieldsList()){
                fieldsName = BPUtility.escapeSingleQuotes(fieldsName);
                query += fieldsName + ', ';
            }
            
            // Child Query: fields of SO Header
            query += '( SELECT ';
            for(String fieldName : JobSchedulingWrapper.getSOHeaderfieldsList()){
                fieldName = BPUtility.escapeSingleQuotes(fieldName);
                query += fieldName + ', ';
            }
            
            query = query.substring(0, query.length()-2);
            query += ' FROM Service_Order_Headers__r) ';
            query += ' FROM  CO_Header__c';
            query += ' WHERE ID =: coHeaderId';
            
            List<CO_Header__c> coHeaderList = Database.query(query);
            JobSchedulingWrapper.COHeaderWrapper coHeaderRec = new JobSchedulingWrapper.COHeaderWrapper(coHeaderList[0]);
            String JSONString = System.JSON.serialize(coHeaderRec);
            return BPUtility.getEncodedString(JSONString);
        }catch(Exception e){
            return BPUtility.getEncodedString('');
        }
    }
    
    private static DateTime getConvertedDateTime(String strDate, String strTime){
        String stringDateTime = '';
        stringDateTime += strDate;
        stringDateTime += ' ' + strTime.substring(0, strTime.length()-2);
        String strTimePeriod = ' ' + strTime.substring(strTime.length()-2, strTime.length());
        stringDateTime += strTimePeriod;
        //system.assert(false, stringDateTime);
        return DateTime.parse(stringDateTime);  
    }
}